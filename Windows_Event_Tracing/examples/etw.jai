//
// Port of "Example using ETW to collect real-time info about Windows processes" by mmozeiko. Port by Charles Taylor.
// Original Source: https://gist.github.com/mmozeiko/299fc8ff993b9c671eb7fd5c7bd87d51
// 

#import,dir "../../Windows_Event_Tracing"; // :BlastedModuleOrganization

context_pointer: *#Context;

running := true;

Trace_Data :: struct {
    Properties: EVENT_TRACE_PROPERTIES;
    SessionName: [1024] u8;
}

trace: Trace_Data;
trace_handle: TRACEHANDLE;
trace_thread: HANDLE;

main :: () {
    context_pointer = *context;

    EXIT_FAILURE :: 1;
    if !IsElevated() {
        log_error("Using ETW with NT kernel logger requires elevated process!");
        exit(EXIT_FAILURE);
    }

    if !EnableProfilePrivilge() {
        log_error("Cannot enable profiling privilege for process!");
        exit(EXIT_FAILURE);
    }

    // min = 122'100, max = 1'000'000'000, in nanoseconds
    if !StartTraceSession(122100) {
        log_error("Cannot start ETW session for NT kernel logger!");
        exit(EXIT_FAILURE);
    }

    // Setup Ctrl+C handler
    SetConsoleCtrlHandler(CtrlHandler, .TRUE);

    print("Running...\n");
    // Wait for Ctrl+C
    while running {
        Sleep(10);
    }

    print("Stopping...\n");
    StopTraceSession();

    print("Done!\n");
}

// Declared in the Windows_Event_Tracing module now.
IsElevated :: is_process_elevated;
EnableProfilePrivilge :: enable_profile_privilege;


// Structures from "C:\Program Files (x86)\Windows Kits\10\Include\10.0.19041.0\km\wmicore.mof" (in Windows DDK)
//
// NOTE(Charles): Members marked :FlexibleArrayMember were defined as a "fleixble array member" in c code. Ie: 
// `wchar_t FileName[];`. I have just declared as one character, and you take the pointer. 

Image_Load :: struct {
    ImageBase: u64;
    ImageSize: u64;
    ProcessId: u32;
    ImageChecksum: u32;
    TimeDateStamp: u32;
    Reserved0: u32;
    DefaultBase: u64;
    Reserved1: u32;
    Reserved2: u32;
    Reserved3: u32;
    Reserved4: u32;
    FileName: u16; // :FlexibleArrayMember
};

Process_TypeGroup1 :: struct {
    UniqueProcessKey:   u64;
    ProcessId:          u32;
    ParentId:           u32;
    SessionId:          u32;
    ExitStatus:         s32;
    DirectoryTableBase: u64;
    Flags:              u32;
    Unknown1:           u64;
    Unknown2:           u32;
    UserSID:            SID;    // variable length
    // CHAR ImageFileName[];    // follows UserSID
    // WHCAR CommandLine[];     // follows ImageFileName
    // WHCAR PackageFullName[]; // follows CommandLine
    // WHCAR ApplicationId[];   // follows PackageFullName
};

Thread_TypeGroup1 :: struct {
    ProcessId: u32;
    TThreadId: u32;
    StackBase: u64;
    StackLimit: u64;
    UserStackBase: u64;
    UserStackLimit: u64;
    Affinity: u64;
    Win32StartAddr: u64;
    TebBase: u64;
    SubProcessTag: u32;
    BasePriority: u8;
    PagePriority: u8;
    IoPriority: u8;
    ThreadFlags: u8;
    ThreadName: u16; // :FlexibleArrayMember
};

CSwitch :: struct {
    NewThreadId: u32;
    OldThreadId: u32;
    NewTHreadPriority: s8;
    OldThreadPriority: s8;
    PreviousCState: u8;
    SpareByte: s8;
    OldThreadWaitReason: s8;
    OldThreadWaitMode: s8;
    OldThreadState: s8;
    OldThreadWaitIdealProcessor: s8;
    NewThreadWaitTime: u32;
    Reserved: u32;
};

ReadyThread :: struct {
    TThreadId: u32;
    AdjustReason: s8;
    AdjustIncrement: s8;
    Flag: s8;
    Reserved: s8;
};

SampledProfile :: struct {
    InstructionPointer: u64;
    ThreadId: u32;
    Count: u16;
    Reserved: u16;
};

StackWalk_Event :: struct {
    EventTimeStamp: u64;
    StackProcess: u32;
    StackThread: u32;
    Stack: u64; // max 192 entries :FlexibleArrayMember
};

TraceEventRecordCallback :: (event: *EVENT_RECORD) #c_call {
    // @TODO(Charles): This callback runs on the same thread as where ProcessTrace was called. Which for us is a secodary
    // thread. We then probably shouldn't be reusing the main thread context!
    push_context,defer_pop context_pointer;
    // print("TraceEventRecordCallback running on thread with id %\n", GetCurrentThreadId());

    tsc := event.EventHeader.TimeStamp.QuadPart;
    cpu := event.BufferContext.ProcessorNumber;

    provider := *event.EventHeader.ProviderId;
    opcode   := event.EventHeader.EventDescriptor.Opcode;

    if provider == ImageLoadGuid {
        if opcode == EVENT_TRACE_TYPE_LOAD || opcode == EVENT_TRACE_TYPE_DC_START {
            data := cast(*Image_Load) event.UserData;
            filename := *data.FileName;
            print("[%] Image Load, FileName=%, ProcessId=%\n", tsc, wide_to_utf8(filename,, temp), data.ProcessId);
        } else if opcode == EVENT_TRACE_TYPE_END || opcode == EVENT_TRACE_TYPE_DC_END {
            data := cast(*Image_Load) event.UserData;
            filename := *data.FileName;
            print("[%] Image Unload, FileName=%, ProcessId=%\n", tsc, wide_to_utf8(filename,, temp), data.ProcessId);
        }
    } else if provider == ProcessGuid {
        if opcode == EVENT_TRACE_TYPE_START || opcode == EVENT_TRACE_TYPE_DC_START {
            data := cast(*Process_TypeGroup1) event.UserData;
            sid  := *data.UserSID;
            sidlen := GetLengthSid(sid); // 8 + 4 * sid.SubAuthorityCount
            filename := cast(*u8) sid + sidlen;
            cmdline := cast(*u16)(filename + c_style_strlen(filename) + 1);
            print("[%] Process Start, ProcessId=%, ImageFileName=%, CommandLine=%\n", tsc, data.ProcessId, filename, wide_to_utf8(cmdline,, temp));
        } else if opcode == EVENT_TRACE_TYPE_END || opcode == EVENT_TRACE_TYPE_DC_END {
            data := cast(*Process_TypeGroup1) event.UserData;
            print("[%] Process Stop, ProcessId=%\n", tsc, data.ProcessId);
        }
    } else if provider == ThreadGuid {
        if opcode == EVENT_TRACE_TYPE_START || opcode == EVENT_TRACE_TYPE_DC_START {
            data := cast(*Thread_TypeGroup1) event.UserData;
            print("[%] Thread Start, ProcessId=%, ThreadId=%, ThreadName=%\n", tsc, data.ProcessId, data.TThreadId, wide_to_utf8(*data.ThreadName,, temp));
        } else if opcode == EVENT_TRACE_TYPE_END || opcode == EVENT_TRACE_TYPE_DC_END {
            data := cast(*Thread_TypeGroup1) event.UserData;
            print("[%] Thread Stop, ProcessId=%, ThreadId=%, ThreadName=%\n", tsc, data.ProcessId, data.TThreadId, wide_to_utf8(*data.ThreadName,, temp));
        } else if opcode == 0x24 { // PERFINFO_LOG_TYPE_CONTEXTSWAP
            data := cast(*CSwitch) event.UserData;
            print("[%] Context Switch, NewThreadId=%, OldThreadId=%, CPU=%\n", tsc, data.NewThreadId, data.OldThreadId, cpu);
        } else if (opcode == 0x32) { // PERFINFO_LOG_TYPE_READY_THREAD
            data := cast(*ReadyThread) event.UserData;
            print("[%] Ready Thread, ThreadId=%\n", tsc, data.TThreadId);
        }
    } else if provider == PerfInfoGuid {
        if opcode == 0x2e { // PERFINFO_LOG_TYPE_SAMPLED_PROFILE
            data := cast(*SampledProfile) event.UserData;
            print("[%] Sampled Profile, ThreadId=%, InstructionPointer=%, Count=%, CPU=%\n", tsc, data.ThreadId, formatInt(data.InstructionPointer, base = 16, minimum_digits = 16), data.Count, cpu);
        }
    } else if provider == StackWalkGuid {
        if opcode == 0x20 { // PERFINFO_LOG_TYPE_STACKWALK
            data := cast(*StackWalk_Event) event.UserData;
            stack := *data.Stack;
            count := (event.UserDataLength - size_of(type_of(data.*))) / size_of(type_of(stack[0]));
            print("[%] Stack Walk, TimeStamp=%, ProcessId=%, ThreadId=%, Count=%, CPU=%\n", tsc, data.EventTimeStamp, data.StackProcess, data.StackThread, count, cpu);
            // stack[0..count-1]
        }
    }
}

TraceProcessThread :: (arg: *void) -> u32 #c_call {
    ProcessTrace(*trace_handle, 1, null, null);
    return 0;
}

StartTraceSession :: (interval: u64) -> bool {
    // print("StartTraceSession running on thread with id %\n", GetCurrentThreadId());

    sysinfo: SYSTEM_INFO;
    GetSystemInfo(*sysinfo);

    p := *trace.Properties;

    // Stop existing trace, in case it is running
    p.* = .{};
    p.Wnode.BufferSize = size_of(type_of(trace));
    p.Wnode.Guid       = SystemTraceControlGuid;
    p.LogFileMode      = EVENT_TRACE_REAL_TIME_MODE;
    p.LoggerNameOffset = size_of(type_of(trace.Properties));
    ControlTraceA(0, KERNEL_LOGGER_NAMEA, p, EVENT_TRACE_CONTROL_STOP);

    // Setup trace properties
    p.* = .{};
    p.Wnode.BufferSize = size_of(type_of(trace));
    p.Wnode.Guid = SystemTraceControlGuid;
    p.Wnode.ClientContext = .QPC;
    p.Wnode.Flags = .TRACED_GUID;
    p.BufferSize = 1024; // 1MiB
    p.MinimumBuffers = 2 * sysinfo.dwNumberOfProcessors;
    p.MaximumBuffers = p.MinimumBuffers + 20;
    p.LogFileMode = EVENT_TRACE_REAL_TIME_MODE | EVENT_TRACE_SYSTEM_LOGGER_MODE;
    p.LoggerNameOffset = size_of(type_of(trace.Properties));
    p.FlushTimer = 1;
    p.EnableFlags = 0
        | EVENT_TRACE_FLAG_IMAGE_LOAD   // dll/exe load & unload
        | EVENT_TRACE_FLAG_PROCESS      // process start/stop
        | EVENT_TRACE_FLAG_THREAD       // thread start/stop
        // | EVENT_TRACE_FLAG_CSWITCH      // thread context switches // NOTE(Charles): I have disabled the context switch one because it is so spammy it seems to prevent ctrl-c being detected, and eventually the program crashes?!
        | EVENT_TRACE_FLAG_PROFILE      // sampled based profiling
    ;

    ERROR_SUCCESS : u32 : 0;

    if (p.EnableFlags & EVENT_TRACE_FLAG_PROFILE) {
        // Set sampling interval
        ProfileTime :: 0x00;
        pinterval: TRACE_PROFILE_INTERVAL;
        pinterval.Source = ProfileTime;
        interval_to_use := ifx interval == 0 then 1000000 else interval;
        pinterval.Interval = cast(u32) (interval_to_use / 100);
        if TraceSetInformation(0, .TraceSampledProfileIntervalInfo, *pinterval, size_of(type_of(pinterval))) != ERROR_SUCCESS {
            return false;
        }
    }

    // Start the trace
    session: TRACEHANDLE;
    if StartTraceA(*session, KERNEL_LOGGER_NAMEA, p) != ERROR_SUCCESS {
        return false;
    }

    // For which events ETW should collect stack (StackWalk_Event)
    stack: CLASSIC_EVENT_ID;
    stack.EventGuid = PerfInfoGuid;
    stack.Type = 0x2e; // PERFINFO_LOG_TYPE_SAMPLED_PROFILE
    if TraceSetInformation(session, .TraceStackTracingInfo, *stack, size_of(type_of(stack))) != ERROR_SUCCESS {
        ControlTraceA(0, KERNEL_LOGGER_NAMEA, p, EVENT_TRACE_CONTROL_STOP);
        CloseTrace(trace_handle);
        return false;
    }

    logfile: EVENT_TRACE_LOGFILEA;
    logfile.LoggerName = KERNEL_LOGGER_NAMEA;
    logfile.ProcessTraceMode = PROCESS_TRACE_MODE_EVENT_RECORD | PROCESS_TRACE_MODE_RAW_TIMESTAMP | PROCESS_TRACE_MODE_REAL_TIME;
    logfile.EventRecordCallback = TraceEventRecordCallback;

    // Open trace for processing
    trace_handle = OpenTraceA(*logfile);
    if trace_handle == INVALID_PROCESSTRACE_HANDLE {
        ControlTraceA(0, KERNEL_LOGGER_NAMEA, p, EVENT_TRACE_CONTROL_STOP);
        return false;
    }

    // Start processing in background thread
    trace_thread = CreateThread(null, 0, xx TraceProcessThread, null, 0, null);
    if trace_thread == null {
        ControlTraceA(0, KERNEL_LOGGER_NAMEA, p, EVENT_TRACE_CONTROL_STOP);
        CloseTrace(trace_handle);
        return false;
    }

    return true;
}

StopTraceSession :: () {
    // Stop the trace
    ControlTraceA(0, KERNEL_LOGGER_NAMEA, *trace.Properties, EVENT_TRACE_CONTROL_STOP);

    // Close processing loop, this will wait until all pending buffers are flushed
    // and TraceEventRecordCallback called on all pending events in buffers
    CloseTrace(trace_handle);

    // Wait for processing thread to finish
    WaitForSingleObject(trace_thread, INFINITE);
}

CtrlHandler :: (type: DWORD) -> BOOL #c_call {
    running = false;
    return .TRUE;
}

kernel32 :: #system_library "kernel32";
advapi32 :: #system_library "advapi32";

HandlerRoutine_Type :: #type (dwCtrlType: u32) -> BOOL #c_call;
SetConsoleCtrlHandler :: (HandlerRoutine: HandlerRoutine_Type, Add: BOOL) -> BOOL #foreign kernel32;

SID_IDENTIFIER_AUTHORITY :: struct {
    Value: [6] u8;
}

SID :: struct {
   Revision: u8;
   SubAuthorityCount: u8;
   IdentifierAuthority: SID_IDENTIFIER_AUTHORITY;
   SubAuthority: [ANYSIZE_ARRAY] u32;
}

GetLengthSid :: (pSid: *SID) -> u32 #foreign advapi32;


#import "Basic";
#import "Windows";
#import "Windows_Utf8";
System :: #import "System";
