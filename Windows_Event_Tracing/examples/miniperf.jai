//
// Port of the windows part of mmozeiko's "miniperf" - https://gist.github.com/mmozeiko/bd5923bcd9d20b5b9946691932ec95fa
//

// Not finished! But I have enough working that I can use this example to keep going with main event.
// I'll hopefully return to this and finish it up:
// - Get the ipc "LoopFun" working. Probably requires using release mode (or custom build options) so
//   the output assembly is correct. So:
// - Do some hack thing so that the SumArray works in release, eg return the sum from a no_inline, or print
//   something
// - Get DataAccess working
// - There will likely still be the issue that on my amd chip you are not allowed 6 counters, but will be
//   fine as a direct port.

DO_EXAMPLE_PROGRAM :: true; // miniperf_example.c is at the bottom of the file, set this to true to compile it, or leave as false and import this file as module.


//
// Interface
//

Counter :: enum s32 {
    CycleCount;
    Instructions;
    BranchMisses;
    BranchCount;
    DataMisses;
    DataAccess;

    COUNT;
};

MiniPerfResult :: struct {
    ElapsedTime: float64;
    ContextSwitches: u64;
    Counters: [Counter.COUNT] u64;
}

MiniPerfFun :: #type (Arg: *void);

// IMPORTANT NOTES
//
// == WINDOWS ==
//
// * Must run process as "administrator"
//
// * Check available counters with "wpr -pmcsources" command. If you see only "Timer" there
//   then that means Windows ETW does have PMU counters available. On AMD system you might
//   need to disble Virtualization in BIOS (be aware that prevents using WSL2)
//
// * ETW is setup to report PMU counters for every context switch. Code calculates delta
//   between measurements for target thread, and returns accumulated values.
//

// Runs function with argument and return measured PMU counter values execution of function is pinned to one CPU core
// MiniPerf :: (Fun: *MiniPerfFun, Arg: *void) -> MiniPerfResult

//
// Implementation
//

MiniPerfContext :: struct {
    Result: MiniPerfResult;
    ThreadId: u32;
    CpuIndex: u32;
    CountersUsed: [] u32;
    CounterCount: u64;

    Fun: MiniPerfFun;
    Arg: *void;

    // NOTE(Charles): We use float 64 and Basic.seconds_since_init here insteat of doing QPC, QPF stuff directly.
    StartTime: float64;
    EndTime: float64;
}

MP_ThreadGuid    :: ThreadGuid;
MP_PageFaultGuid :: PageFaultGuid;

// Skylake+ can have 4 generic counters + 3 fixed (cycles, instructions, refcycles)
MP_IntelCounters :: string.[
    /* [MP_CycleCount]   = */ "UnhaltedCoreCyclesFixed",
    /* [MP_Instructions] = */ "InstructionsRetiredFixed",
    /* [MP_BranchMisses] = */ "BranchMispredictions",
    /* [MP_BranchCount]  = */ "BranchInstructions",
    // on Intel can use L3 cache counters
    /* [MP_DataMisses]   = */ "LLCMisses",
    /* [MP_DataAccess]   = */ "LLCReference",
];

// NOTE(Charles): My AMD Ryzen 9 5900HX doesn't have TotalCycles, and also seemingly doesn't support 6 counters.
// Setting TracePmcCounterListInfo with the 5 below returns ERROR_INCORRECT_SIZE "Incorrect size argument".
// I am leaving the code the same as the original however.

// AMD Zen can have 6 generic counters
MP_AmdCounters :: string.[
    /* [MP_CycleCount]   */ "TotalCycles",
    /* [MP_Instructions] */ "TotalIssues",
    /* [MP_BranchMisses] */ "BranchMispredictions",
    /* [MP_BranchCount]  */ "BranchInstructions",
    // on AMD can use L1 cache counters
    /* [MP_DataMisses]   */ "DcacheMisses",
    /* [MP_DataAccess]   */ "DcacheAccesses",
];

MP_ArmCounters :: string.[
    /* [MP_CycleCount]   */ "TotalCycles",
    /* [MP_Instructions] */ "TotalIssues",
    /* [MP_BranchMisses] */ "BranchMispredictions",
    /* [MP_BranchCount]  */ "BranchInstructions",
    /* [MP_DataMisses]   */ "DcacheMisses",
    /* [MP_DataAccess]   */ "DcacheAccesses",
];

// @TODO(Charles): Do I need to do something better about jai contexts with the c_call stuff here? :WhatDoAboutContexts
// If change to jai threads then the threads we create at least wont have that issue, the ETW callback will still though.

MiniPerf__Callback :: (Event: *EVENT_RECORD) #c_call {
    dummy_context: #Context;
    push_context,defer_pop dummy_context; // :WhatDoAboutContexts

    Provider := *Event.EventHeader.ProviderId;
    Opcode   := Event.EventHeader.EventDescriptor.Opcode;
    CpuIndex := GetEventProcessorIndex(Event);
    mp_context  := cast(*MiniPerfContext) Event.UserContext;

    if (Provider == MP_ThreadGuid) && Opcode == 0x24 && CpuIndex == mp_context.CpuIndex {
        assert(Event.UserDataLength >= 24);
        limit := Event.ExtendedDataCount-1;

        NewThreadId := (cast(*u32)(cast(*u8)Event.UserData + 0)).*;
        OldThreadId := (cast(*u32)(cast(*u8)Event.UserData + 4)).*;
        ThreadId    := mp_context.ThreadId;

        for 0..cast(int)Event.ExtendedDataCount-1 {
            Item := Event.ExtendedData + it;
            if Item.ExtType == .PMC_COUNTERS {
                assert(Item.DataSize == size_of(u64) * mp_context.CounterCount);

                // NOTE(Charles): Pmc.Counter is a [1] u64 in jai bindings, set the length correctly to an array view.
                Pmc := cast(*EVENT_EXTENDED_ITEM_PMC_COUNTERS) Item.DataPtr;
                Pmc_Counter : [] u64 = Pmc.Counter;
                Pmc_Counter.count = xx mp_context.CounterCount;

                num_counters := Item.DataSize / size_of(u64);
                for c: 0..num_counters-1 {
                    Counter := mp_context.CountersUsed[c];
                    mp_context.Result.Counters[Counter] -= ifx NewThreadId == ThreadId then Pmc_Counter[c] else 0;
                    mp_context.Result.Counters[Counter] += ifx OldThreadId == ThreadId then Pmc_Counter[c] else 0;
                }
            }
        }

        mp_context.Result.ContextSwitches += cast(u64) (OldThreadId == ThreadId);
    }
}

MiniPerf__ProcessThread :: (Arg: *void) -> u32 #c_call {
    Session := cast(TRACEHANDLE) Arg;
    ProcessTrace(*Session, 1, null, null);
    return 0;
}

MiniPerf__FunThread :: (Arg: *void) -> u32 #c_call {
    // :WhatDoAboutContexts
    dummy_context: #Context;
    push_context dummy_context {
        mp_context := cast(*MiniPerfContext) Arg;
        mp_context.StartTime = seconds_since_init();
        mp_context.Fun(mp_context.Arg);
        mp_context.EndTime = seconds_since_init();
        return 0;
    }
}

MiniPerf :: (Fun: MiniPerfFun, Arg: *void) -> MiniPerfResult {
    Status: u32;

    mp_context: MiniPerfContext;

    // Find PMU counters by looking up available names

    CounterSources: [Counter.COUNT] u32;
    CountersUsed:   [Counter.COUNT] u32;
    CounterCount: u64;

    if CounterCount == 0 {
        CounterNames: [] string;

        // NOTE(Charles): In the c version this is uses _M_AMD64. Afaict that just means x64 and not amd specifically,
        // wasn't totally clear though!
        #if CPU == .X64 {
            #import "Machine_X64";

            cpu_info := get_cpu_info();

            if cpu_info.vendor ==  {
                case .INTEL; CounterNames = MP_IntelCounters;
                case .AMD;   CounterNames = MP_AmdCounters;
                case;
                    assert(false, "Unknown CPU vendor %", cpu_info.vendor);
                    return mp_context.Result;
            }
        } else #if CPU == .ARM64 {
            CounterNames = MP_ArmCounters;
        } else {
            #assert false "Unknown arhcitecture";
        }

        BufferSize: u32;

        // How much memory needed to query PMU counter names
        Status = TraceQueryInformation(0, .TraceProfileSourceListInfo, null, 0, *BufferSize);
        assert(Status == ERROR_BAD_LENGTH);

        Buffer := NewArray(BufferSize, u8, false);
        defer array_free(Buffer); // NOTE(Charles): Just use temporary allocator?

        // Get PMU counter names
        Status = TraceQueryInformation(0, .TraceProfileSourceListInfo, Buffer.data, BufferSize, *BufferSize);
        assert(Status == ERROR_SUCCESS);

        Offset: u64;
        while true {
            Info := cast(*PROFILE_SOURCE_INFO)(Buffer.data + Offset);

            for 0..cast(u32)Counter.COUNT-1 {
                Description := wide_to_utf8(Info.Description.data,, temp);

                if Description == CounterNames[it] {
                    CounterSources[CounterCount] = Info.Source;
                    CountersUsed[CounterCount] = it;
                    CounterCount += 1;
                    break;
                }
            }

            if Info.NextEntryOffset == 0  break;

            Offset += Info.NextEntryOffset;
        }
    }

    mp_context.CountersUsed = CountersUsed;
    mp_context.CounterCount = CounterCount;
    mp_context.Fun = Fun;
    mp_context.Arg = Arg;

    trace :: struct {
        // NOTE(Charles): C version uses _V2, and sets the corresponding VERSIONED_PROPERTIES flag in WNode.Flags. But doesn't set any
        // other "v2" properties and doesn't appear necessary?
        // Properties: EVENT_TRACE_PROPERTIES_V2;
        Properties: EVENT_TRACE_PROPERTIES;
        Name: [1024] u8;
    }
    Trace: trace;

    TraceName := "MiniPerf";

    // Start trace, capture context switches
    Properties := *Trace.Properties;

    // Properties.* = .{};
    Properties.Wnode.BufferSize = size_of(type_of(Trace));
    Properties.Wnode.ClientContext = .CPU_CYCLE;
    // Properties.Wnode.Flags = .TRACED_GUID | .VERSIONED_PROPERTIES;
    Properties.Wnode.Flags = .TRACED_GUID;
    Properties.LogFileMode = EVENT_TRACE_REAL_TIME_MODE | EVENT_TRACE_SYSTEM_LOGGER_MODE;
    Properties.EnableFlags = EVENT_TRACE_FLAG_CSWITCH;
    // NOTE(Charles): The original code has this, but it looks like a mistake and we want to point to the Name field instead.
    // Properties.LoggerNameOffset = size_of(type_of(Trace));
    Properties.LoggerNameOffset = size_of(type_of(Trace.Properties));

    TraceHandle: TRACEHANDLE;
    Status = StartTraceA(*TraceHandle, TraceName.data, cast(*EVENT_TRACE_PROPERTIES) Properties);
    if Status == ERROR_ALREADY_EXISTS {
        // Stop existing trace in case it is already running
        Status = ControlTraceA(0, TraceName.data, xx Properties, EVENT_TRACE_CONTROL_STOP);
        assert(Status == ERROR_SUCCESS || Status == ERROR_MORE_DATA);

        Status = StartTraceA(*TraceHandle, TraceName.data, xx Properties);
    }

    if Status != ERROR_SUCCESS {
        // ERROR_ACCESS_DENIED -> need to run with admin privileges
        // ERROR_NO_SYSTEM_RESOURCES -> too many system traces already running

        // Just run the function, which will measure time
        MiniPerf__FunThread(xx *mp_context);

    } else {
        // Enable PMU counters if there are any (otherwise only context switch count will be captured)
        if CounterCount != 0 {
            if CounterCount > 4 {
                // print("@Temp: CounterCount == % is over limit for Charles' cpu, limiting to 4\n", CounterCount);
                CounterCount = 4;
                mp_context.CounterCount = CounterCount;
            }
            // for 0..CounterCount-1  print("%: % %, ", it, mp_context.CountersUsed[it], cast(Counter) mp_context.CountersUsed[it]);
            // print("\n");

            CounterSourcesDataLength := cast(u32) (CounterCount * size_of(type_of(CounterSources[0])));
            Status = TraceSetInformation(TraceHandle, .TracePmcCounterListInfo, CounterSources.data, CounterSourcesDataLength);
            // If this triggers ERROR_BUSY = 0xaa, then I believe that that someone else is collecting PMU counters
            // in the system, and I'm not sure how or if at all you to forcefully stop/reconfigure it. Rebooting helps.
            if Status == ERROR_BUSY {
                log_error("TraceSetInformation(TracePmcCounterListInfo) failed with ERROR_BUSY. Probably someone else is collecting PMCs, rebooting can help...");
                exit(123);
            }
            assert(Status == ERROR_SUCCESS, "TraceSetInformation failed to set pmcs to collect with error %: %", Status, System.get_error_string(xx Status));

            // Collect PMU counters on context switch event
            EventId := CLASSIC_EVENT_ID.{ EventGuid = MP_ThreadGuid, Type = 0x24 };
            Status = TraceSetInformation(TraceHandle, .TracePmcEventListInfo, *EventId, size_of(type_of(EventId)));
            assert(Status == ERROR_SUCCESS);
        }

        Log: EVENT_TRACE_LOGFILEA;
        Log.LoggerName = Trace.Name.data;
        Log.EventRecordCallback = MiniPerf__Callback;
        Log.ProcessTraceMode = PROCESS_TRACE_MODE_EVENT_RECORD | PROCESS_TRACE_MODE_RAW_TIMESTAMP | PROCESS_TRACE_MODE_REAL_TIME;
        Log.Context = *mp_context;

        // Open trace for processing incoming events
        Session := OpenTraceA(*Log);
        assert(Session != INVALID_PROCESSTRACE_HANDLE);

        // Start ETW processing thread
        ProcessingThread := CreateThread(null, 0, xx MiniPerf__ProcessThread, xx Session, 0, null);
        assert(ProcessingThread != null);

        // Execute target function
        // It will happen on thread so there is a context switch right at the start of execution to capture initial PMU counter values
        {
            // create suspended thread so we know ThreadId is fully available
            FunThread := CreateThread(null, 0, xx MiniPerf__FunThread, xx *mp_context, CREATE_SUSPENDED, *mp_context.ThreadId);
            assert(FunThread != null);

            // Pin thread to one CPU core
            mp_context.CpuIndex = SetThreadIdealProcessor(FunThread, MAXIMUM_PROCESSORS);
            ThreadAffinityMask := (cast(u64) 1) << mp_context.CpuIndex;
            SetThreadAffinityMask(FunThread, ThreadAffinityMask);

            // Now allow thread to run, thus force context switch for target thread
            ResumeThread(FunThread);

            WaitForSingleObject(FunThread, INFINITE);
            CloseHandle(FunThread);
        }

        // Stop producing new events
        Status = ControlTraceA(TraceHandle, null, xx Properties, EVENT_TRACE_CONTROL_STOP);
        assert(Status == ERROR_SUCCESS);

        // Closes trace processing, this will make ETW to process all the pending events in buffers
        Status = CloseTrace(Session);
        assert(Status == ERROR_SUCCESS || Status == ERROR_CTX_CLOSE_PENDING);

        // Wait until ETW processing thread finishes with callbacks
        WaitForSingleObject(ProcessingThread, INFINITE);
        CloseHandle(ProcessingThread);
    }

    mp_context.Result.ElapsedTime = mp_context.EndTime - mp_context.StartTime;

    // print("Result == %\n", mp_context.Result);

    return mp_context.Result;
}

#scope_file 

#import,dir "../../Windows_Event_Tracing";

#import "Basic";
using,except(CreateThread) Windows :: #import "Windows";
#import "Windows_Utf8";
System :: #import "System";


// CreateThread in Windows has slighlty wrong param types. This probably wasn't worth it and should just cast at the
// call site.
CreateThread :: (threadAttributes: *SECURITY_ATTRIBUTES, stackSize: u64, startAddress: THREAD_START_ROUTINE, parameter: *void, creation_flags: Creation_Flags, threadIdReturn: *u32) -> HANDLE #foreign kernel32;
THREAD_START_ROUTINE :: #type (lpThreadParameter: *void) -> u32;

kernel32 :: #system_library "kernel32";
MAXIMUM_PROCESSORS : u32 : 64;
SetThreadIdealProcessor :: (hThread: HANDLE, dwIdealProcessor: u32) -> u32 #foreign kernel32;
SetThreadAffinityMask :: (hThread: HANDLE, dwThreadAffinityMask: u64) -> u64 #foreign kernel32;


//
// miniperf_example.c
//

#scope_export

#if DO_EXAMPLE_PROGRAM {
    //
    // On Windows this example code must be compiled with with clang-cl:
    //   clang-cl.exe -O2 miniperf_example.c
    //
    // NOTE(Charles): Using either x64 or llvm backend I get 15% branch misses, not a million miles away from expected
    // 20%. Using llvm in -release, code is opitmized and doesn't behave as intended. If you cared you could compile
    // the example being more precies with LLVM_Options to match the above comment.

    // #import "miniperf";

    DO_SUM_ARRAY   :: true;  // Uses BranchCount, BranchMisses
    DO_LOOP_FUN    :: false; // Uses Instructions, CycleCount
    DO_DATA_ACCESS :: false; // Uses DataMisses, DataAccess. NOTE(Charles): This one compiles and runs, but DataMisses is always zero?

    main :: () {
        Perf: MiniPerfResult;

        #if DO_SUM_ARRAY {
            RandomizeArray();

            Perf = MiniPerf(SumArray, null);
            print("[%s] sum on random array, branch misses = %0%%, %M of %M total, context switches=%\n",
                formatFloat(Perf.ElapsedTime, width = 6, trailing_width = 3),
                formatFloat(Perf.Counters[Counter.BranchMisses] * 100.0 / Perf.Counters[Counter.BranchCount], width = 6, trailing_width = 2),
                formatInt(Perf.Counters[Counter.BranchMisses] / 1000000, minimum_digits = 2),
                formatInt(Perf.Counters[Counter.BranchCount] / 1000000, minimum_digits = 3),
                Perf.ContextSwitches);

            SortArray();

            Perf = MiniPerf(SumArray, null);
            print("[%s] sum on sorted array, branch misses = %0%%, %K of %M total, context switches=%\n",
                formatFloat(Perf.ElapsedTime, width = 6, trailing_width = 3),
                formatFloat(Perf.Counters[Counter.BranchMisses] * 100.0 / Perf.Counters[Counter.BranchCount], width = 6, trailing_width = 2),
                formatInt(Perf.Counters[Counter.BranchMisses] / 1000, minimum_digits = 2),
                formatInt(Perf.Counters[Counter.BranchCount] / 1000000, minimum_digits = 3),
                Perf.ContextSwitches);
        }
            
        #if DO_LOOP_FUN {
            for 1..3 {
                Perf = MiniPerf(LoopFun, cast(*void) it);
                print("[%s] loop with expected ipc=%, measured IPC = %, %M insn in %M cycles, context switches=%\n",
                    formatFloat(Perf.ElapsedTime, width = 6, trailing_width = 3),
                    it,
                    formatFloat(cast(float64)Perf.Counters[Counter.Instructions] / Perf.Counters[Counter.CycleCount], trailing_width = 2),
                    (Perf.Counters[Counter.Instructions] / 1000000),
                    (Perf.Counters[Counter.CycleCount] / 1000000),
                    Perf.ContextSwitches);
            }
        }

        #if DO_DATA_ACCESS {
            Data := alloc(8 * CACHE_SIZE);
            memset(Data, 0xff, 8 * CACHE_SIZE);

            // 2*N out of total 8*N accesses = 25% miss ratio
            {
                Perf = MiniPerf(DataAccess, Data);
                print("Perf == %\n", Perf);
                print("[%s] data -> %0%%, miss = %M, total = %M, context switches=%\n",
                    formatFloat(Perf.ElapsedTime, width = 6, trailing_width = 3),
                    formatFloat(Perf.Counters[Counter.DataMisses] * 100.0 / Perf.Counters[Counter.DataAccess], width = 5, trailing_width = 2),
                    (Perf.Counters[Counter.DataMisses] / 1000000),
                    (Perf.Counters[Counter.DataAccess] / 1000000),
                    Perf.ContextSwitches);
            }
        }
    }

    // @TODO(Charles): Is it possible or useful to make a jai equivalent of this?
    // #define DO_NOT_OPTIMIZE(var) __asm__ __volatile__("" : "+r"(var))

    // Array size to test branch prediction on
    SUM_COUNT :: 100 * 1000 * 1000;

    // Expected count of cycles for loop when testing IPC
    CYCLE_COUNT :: 1000 * 1000 * 1000;

    arr: [SUM_COUNT] u8;

    // Sums all the values in array for values smaller than 128
    //
    // clang generates code that for each iteration does either
    // 2 or 3 branches depending if comparison is true or false
    // 
    // 2 branches if comparison is false:
    //   * 1 loop iteration condition
    //   * 1 for arr[i] comparison and jump back to loop beginning)
    //
    // 3 branches if comparison is true:
    //   * 1 loop iteration condition
    //   * 1 for arr[i] comparison
    //   * 1 for unconditional jump back to loop beginning
    //
    // This means for uniformly random values in array, it will do
    // total of 2.5*N branches, out of which N will be unpredictable
    //
    // We expect CPU to take 50% of unpredictable branches correctly
    // that means 0.5*N of branch misses, 0.5/2.5 = 1/5 = 20% misses
    //
    // If array is sorted, then the branch inside will be very predictable
    // and mispredict will be close to 0% for the same 2.5*N of total branches

    SumArray :: (Arg: *void) {
        result: u64;
        // DO_NOT_OPTIMIZE(result);

        for 0..SUM_COUNT-1 {
            if arr[it] < 128 {
                // DO_NOT_OPTIMIZE(result); // force compiler to generate actual branch
                result += arr[it];
            }
        }

        // DO_NOT_OPTIMIZE(result);
    }

#if DO_LOOP_FUN {
    // Perform a loop that executes in CYCLE_COUNT cycles (with small overhead for loop counter).
    // Loop is executed with expected IPC 1, 2 or 3
    LoopFun :: no_inline (Arg: *void) {
        ipc := cast(u64) Arg;

        // @Incomplete: C version supports arm.
        #assert CPU == .X64 "Only x64 supported atm. It might be possible to do on arm with my Arm_Assembler module, not sure!";

        // The c version uses recursive macro expansion to insert the inline assembly, we use compile time code generation.
        // NOTE(Charles): There is almost certainly a cleaner way to do this with Code, but string insertion is easy!
        generate_code :: (ipc: int, iterations: int) -> string #compile_time {
            assert(ipc >= 1 && ipc <= 3, "Invalid value for ipc == %", ipc);

            builder: String_Builder;

            append(*builder, "#asm {\n");
            // if ipc >= 1  append(*builder, "    var1: gpr === 9;\n");
            // if ipc >= 2  append(*builder, "    var2: gpr === 10;\n");
            // if ipc >= 3  append(*builder, "    var3: gpr === 11;\n");

            // These three operations can execute in same cycle on modern machine
            for 0..iterations-1 {
                if ipc >= 1  append(*builder, "    shl.d var1;");       // OP1(var1)
                if ipc >= 2  append(*builder, "    shl.d var2;");       // OP2(var2)
                if ipc >= 3  append(*builder, "    add.d var3, var3;"); // OP3(var3)
                append(*builder, "\n");
            }

            print_to_builder(*builder, "}\n");

            s := builder_to_string(*builder);
            return s;
        }

        count := CYCLE_COUNT / 500;

        OPERATIONS_PER_ITERATION :: 5; // @TEMP

        var1, var2, var3: u32;

        #asm {
            mov a:, 0;
            shl.d a;
            shl.d a;
            shl.d a;
            shl.d a;
            shl.d a;
        }

        if ipc == {
            case 1; for 0..count  #insert #run generate_code(1, OPERATIONS_PER_ITERATION);
            case 2; for 0..count  #insert #run generate_code(2, OPERATIONS_PER_ITERATION);
            case 3; for 0..count  #insert #run generate_code(3, OPERATIONS_PER_ITERATION);
            case; assert(false, "Unexpected arg, ipc == %", ipc);
        }

        print("%, %, %\n", var1, var2, var3);
    }
}

    DATA_ITER_COUNT :: 1000 * 1000;
    CACHE_SIZE      :: 32 * 1024;
    CACHE_LINE      :: 64;

    DataAccess :: (Arg: *void) {
        // volatile uint8_t* Data = (uint8_t*)Arg;
        Data := cast(*u8)Arg; // volatile?

        Sum: u32;
        // DO_NOT_OPTIMIZE(Sum);

        for 0..DATA_ITER_COUNT-1 {
            i := 0;

            // 6*N data accesses that are in cache
            while i < (6 * CACHE_SIZE) {
                defer i += CACHE_LINE;
                Sum += Data[0];
            }
            // DO_NOT_OPTIMIZE(Sum);

            i = 0;

            // 2*N data accessses that are not in cache
            while i < (2 * CACHE_SIZE) {
                defer i += CACHE_LINE;
                Sum += Data[CACHE_SIZE+i];
            }
            // DO_NOT_OPTIMIZE(Sum);
        }
        // DO_NOT_OPTIMIZE(Sum);
    }

    // Sorts array with counting sort
    SortArray :: () {
        offset: u64;
        counts: [256] u32;
        for 0..SUM_COUNT-1 {
            counts[arr[it]] += 1;
        }

        for i: 0..255 {
            for c: 0..counts[i]-1 {
                arr[offset] = cast(u8) i;
                offset += 1;
            }
        }
    }

    // Fill array with random values
    RandomizeArray :: () {
        random : u32 = 1;
        for 0..SUM_COUNT-1 {
            arr[it] = cast(u8)(random >> 24);
            random = 0x01000193 * random + 0x811c9dc5;
        }
    }
}