//
// Module to enable collecting Performance-Monitoring Counters (PMCs) thread-safe, continuously on a running program.
//
// Inspired (and significantly aided!) by "The Computer Enhance 2024 International Event Tracing for Windows Halloween
// Spooktacular Challenge".
//

// @Incomplete:
// - Casey has updated his version to 1) Use a service, I think to avoid needing the user app to have admin rights, 2) remove mapping of pmc names, and start defining counter names explicitly?
// - Add linux support, should be 1000x simpler than getting windows working with ETW. Atm the api implementations in this file are windows specific!
// - Support nested regions. Not sure what will happen atm, but it for sure won't work!

// @TODO(Charles) Fixes: 
// - :ReusingMarkerWithNewTracer Now we support multiple tracer objects we have to be more careful with whether our traced_threads are being used with the correct tracer (and maybe the event_handler needs to check too?)

// NOTE(Charles): Changing collected sources after start_tracing.
// I tried to implement some "set_new_sources" procedure you could call after you had started a session with start_tracing.
// The hope was that I could keep everything else running, TraceSetInformation the new sources to collect and be done.
// However, calling TraceSetInformation(TracePmcCounterListInfo) for a second time fails saying it has already been set.
// It seems to acheive this I would have to stop the current trace, start a new one setting the new sources. I did try
// do this, but it got very messy trying to handle the edge cases that then crop up in our event handling, so instead if
// you want to change sources at runtime you should just stop your trace session and start a new one.

#assert OS == .WINDOWS "Only windows supported atm"; // :LinuxSupport

LOG_EVENTS :: false; // For debugging. Print trace of handled events.

// NOTE(Charles): It seems we can choose to name our trace provided we then use the trace handle as first param in, eg,
// ControlTrace. Using KERNEL_LOGGER_NAME also seems to work and then we pass 0 as first param. :shrug:
// TRACE_NAME := cast(string) KERNEL_LOGGER_NAMEA;
TRACE_NAME :: "ASpookyTrace";
// @Incomplete: The trace name should probably be configurable, or at least not always the same. Pretty sure it
// will break if two programs run using this module at same time atm.

PMC_Source :: struct {
    name: string;
    id: u32;
}

PMC_Tracer :: struct {
    started := false;

    trace: Trace_Data; // @BadName?

    session_trace_handle:  TRACEHANDLE;
    consumer_trace_handle: TRACEHANDLE;

    event_processing_thread: Thread;
    event_processing_thread_context: *#Context;

    sources: [] PMC_Source;

    MAX_TRACED_THREADS :: 256; // Arbritrary atm, need to figure out want to do this per thread etc
    traced_threads_data: [MAX_TRACED_THREADS] PMC_Traced_Thread_Data;
    next_traced_thread_index := 1; // 0 means invalid, these ids are currently assigned at runtime, but could be made static.

    // @TODO(Charles): Dynamically allocate this based on GetSystemInfo.dwNumberofProcessors
    active_regions: [MAX_CPU_INDEX] PMC_Active_Region_Data; // Indexed by the cpu_index as reported by ETW. 
    paused_regions: [..] Paused_Region_Data; // Store info about threads that have been context switched out. Maybe should just record this in the traced_threads_data though?
    // NOTE(Charles): Caseys equivalent of paused_regions uses a linked list where the pointers point data statically defined
    // by the caller.

    MAX_CPU_INDEX :: 64; // Wut if thread ripper or something?
}

// PMC_Traced_Thread just tracks an id the data is in a separate struct stored in a array on PMC_Tracer. With the way
// PMC_Traced_Thread instances are statically defined, we could just store all the data on there and take pointers to it?

INVALID_TRACED_THREAD_ID :: 0;

PMC_Traced_Thread :: struct {
    id: int;
}

MAX_PMC :: 8; // We are limited by what the cpu supports, on my intel its 4, on some amds it's more. Probably never more than 8...

PMC_Traced_Thread_Data :: struct {
    is_complete := false;

    start_time: float64;
    stop_time:  float64;

    pmcs:       [MAX_PMC] u64; // The pmc values accumulate while this thread was active
    pmcs_start: [MAX_PMC] u64; // The pmc at the start of execution, either the actual start, or after a context switch. Need a separate array rather than reusing pmcs because the counter values across cores will be different!
    // @TODO: Do the - on open, + on close trick to only keep one array here.
}

// @TODO(Charles): Track how many times this region was context switched
PMC_Trace_Result :: struct {
    time_taken: float64;
    pmc_count: int;
    // You can always just look these names up in PMC_Tracer.sources, maybe not worth returning? Also, if we just
    // return the valus can return array view instead of copying into another array?
    pmc_names:  [MAX_PMC] string; 
    pmc_values: [MAX_PMC] u64;
}

Trace_Data :: struct {
    Properties: EVENT_TRACE_PROPERTIES;
    SessionName: [1024] u8;
}

// We trigger custom START, STOP events to mark with our custom data, but then use SYS_CALL_ENTER/EXIT to collect pmcs.
// The order of events is START, SYS_CALL_EXIT, SYS_CALL_ENTER, STOP. The SYS_CALL_* events are triggered before/after
// our TraceEvent call which triggers START/STOP.
PMC_Active_Region_Event_Type :: enum {
    NONE;

    START;
    STOP;

    SYS_CALL_ENTER;
    SYS_CALL_EXIT;
}

// Data to track our currently active pmc regions
PMC_Active_Region_Data :: struct {
    type: PMC_Active_Region_Event_Type;
    traced_thread_id := 0; 
    thread_index := -1;
    windows_thread_id: u32;
}

// When the thread an active region is running on gets context switched out we need to store some
// data so we can then continue tracking when the thread is switched back in.
Paused_Region_Data :: struct {
    using active_region_data: PMC_Active_Region_Data;

    // @TODO(Charles): When got context switches working decide whether even need this struct or just keep
    // array of PMC_Active_Region_Data.
}

is_pmc_collection_supported :: () -> bool {
    if !is_process_elevated() {
        log_error("PMC collection using ETW with NT kernel logger requires elevated process!");
        return false;
    }

    if !enable_profile_privilege() {
        log_error("PMC collection use ETW requires profiling privilege, but we failed to enable it!");
        return false;
    }

    return true;
}

get_max_simultaneous_pmc_sources :: () -> int {
    count: u32;
    out_size: u32;
    status := Check(TraceQueryInformation(0, .TraceMaxPmcCounterQuery, *count, size_of(u32), *out_size));
    assert(status == ERROR_SUCCESS);
    assert(out_size == size_of(u32));

    return count;
}

// @Cleanup: map_pmc_names allocatoes an array of PMC_Source and then start_tracing takes an array view and just saves 
// the array view (ie doesn't copy the actual array). This is awkward! We can only have MAX_PMCS pmcs anyway so we could
// easily just have fixed sized arrays and avoid having to think about who is allocating! (Eg, this is what casey)

map_pmc_names :: (pmc_names: [] string) -> bool, [] PMC_Source {
    available_pmcs := get_available_pmcs(,, temp);

    pmc_sources := NewArray(pmc_names.count, PMC_Source);

    // This is weird...
    for name, name_index: pmc_names {
        found := false;
        for pmc: available_pmcs {
            if pmc.name == name {
                found = true;
                pmc_sources[name_index] = pmc;
                pmc_sources[name_index].name = name; 
                break;
            }
        }

        // Could return the ones we did find, with someway to check if each requested name was found, for now if we fail
        // to find one, just return failure
        if !found {
            array_free(pmc_sources);
            return false, .[];
        }
    }    

    return true, pmc_sources;
}

get_available_pmcs :: () -> [] PMC_Source {
    success, buffer := trace_query_information(.TraceProfileSourceListInfo,, temp);
    assert(success);

    // Could cache this, for now just look it up everytime.
    available_pmcs: [..] PMC_Source;

    // The size of each PROFILE_SOURCE_INFO entry is variable, based on the length of the string it contains so we 
    // have to iterate thus.
    cursor := buffer.data;
    while true {
        source := cast(*PROFILE_SOURCE_INFO) cursor;

        pmc := array_add(*available_pmcs);
        pmc.name = Windows_Utf8.wide_to_utf8(source.Description.data);
        pmc.id = source.Source;

        // NOTE(Charles): Code to query for the current interval, and also record the min/max interval of source. I no 
        // longer track this info as it wasn't useful for my purposes.
        #if false {
            interval: TRACE_PROFILE_INTERVAL;
            interval.Source = source.Source;

            buffer_size: u32;
            result := TraceQueryInformation(0, .TraceSampledProfileIntervalInfo, *interval, size_of(type_of(interval)), *buffer_size);
            assert(result == 0);
            assert(buffer_size == size_of(TRACE_PROFILE_INTERVAL));

            pmc.interval = interval.Interval;
            pmc.min_interval = source.MinInterval;
            pmc.max_interval = source.MaxInterval;
        }

        if source.NextEntryOffset == 0  break;
        cursor += source.NextEntryOffset;
    }

    return available_pmcs; // Q: Is anything useful lost returning view of dynamic array?
}

print_available_pmcs :: () {
    pmcs := get_available_pmcs(,, temp);

    print("Available pmcs:\n");
    for pmcs  print("  %: %\n", it. id, it.name);
}

// To start with we just had one global PMC_Tracer object in this module. I have now changed it to (like Caseys) take
// a PMC_Tracer object as paramter to api calls to enable me to change pmc sources at runtime. These are versions of api
// calls that don't require passing in a user supplied object so existing examples work. 
// @TODO(Charles): Decide if it's worth keeping these wrappers or require a user supplied tracer object.
default_tracer: PMC_Tracer;
start_tracing :: (pmc_sources: [] PMC_Source) -> bool { return start_tracing(*default_tracer, pmc_sources); }
stop_tracing  :: () { stop_tracing(*default_tracer); }
start_counting_pmcs :: (traced_thread: *PMC_Traced_Thread) { start_counting_pmcs(*default_tracer, traced_thread); }
stop_counting_pmcs  :: (traced_thread: *PMC_Traced_Thread) { stop_counting_pmcs(*default_tracer, traced_thread); }
CountPmcsScoped :: (traced_thread: *PMC_Traced_Thread) #expand {
    start_counting_pmcs(*default_tracer, traced_thread);
    `defer stop_counting_pmcs(*default_tracer, traced_thread);
}
is_complete     :: (traced_thread: *PMC_Traced_Thread) -> bool { return is_complete(*default_tracer, traced_thread); }
get_result      :: (traced_thread: *PMC_Traced_Thread) -> PMC_Trace_Result { return get_result(*default_tracer, traced_thread); }
wait_for_result :: (traced_thread: *PMC_Traced_Thread) -> PMC_Trace_Result { return wait_for_result(*default_tracer, traced_thread); }
print_result    :: (using result: *PMC_Trace_Result) { print_result(*default_tracer, result); }

start_tracing :: (using tracer: *PMC_Tracer, pmc_sources: [] PMC_Source) -> bool {
    assert(started == false);

    my_process_id = Windows.GetCurrentProcessId();

    sources = pmc_sources;
    
    status: u32;

    p := *trace.Properties;

    // Start the trace
    {
        // Always try stop trace with our name incase one wasn't shut down properly. ControlTrace will modify the properties
        // parameter so we make sure to reset, and refill in our required values before calling StartTrace.
        // NOTE(Charles): In theory we should be able to call StartTrace, check for return code ERROR_ALREADY_EXISTS, and
        // only then stop the existing trace, but I think I found that doesn't always work so am just always attempting a 
        // stop.
        p.* = .{};
        p.Wnode.BufferSize = size_of(type_of(trace));
        p.LoggerNameOffset = size_of(type_of(trace.Properties));

        status = ControlTraceA(0, TRACE_NAME.data, xx p, EVENT_TRACE_CONTROL_STOP);
        assert(status == ERROR_SUCCESS || status == Windows.ERROR_MORE_DATA || status == ERROR_WMI_INSTANCE_NOT_FOUND);

        p.* = .{};
        p.Wnode.BufferSize = size_of(type_of(trace));
        p.LoggerNameOffset = size_of(type_of(trace.Properties));
        p.Wnode.ClientContext = .QPC; // @MiniPerf uses .CPU. Maybe that is better, but I am not currently using the timestamps anyway
        p.Wnode.Flags = .TRACED_GUID; // @MiniPerf has .VERSIONED_PROPERTIES as well (because it uses _V2)
        p.LogFileMode  = EVENT_TRACE_REAL_TIME_MODE | EVENT_TRACE_SYSTEM_LOGGER_MODE;
        p.EnableFlags |= .CSWITCH;
        p.EnableFlags |= .SYSTEMCALL;
        p.EnableFlags |= MY_ENABLE_FLAG;


        // NOTE(Charles): :TraceEventNotEnoughMemory
        // At some point while doing invaders thing I found TraceEvent would fail without NOT_ENOUGH_MEMORY. Martins to the
        // rescue he wrote the message included below. Something about how many events are getting triggered while running
        // invaders is causing the buffers to get full and we fail. As a hack solution I have just bumped the buffer size up.
        // It had to be bumped quite significanlty, probably most of the events filling these buffers aren't the ones we care
        // about... Martins message:
        /*
            Not enough memory happens if the trace processing callback is not able to process incoming events fast enough.
            And when ETW buffers fill up, the new events are dropped with that error. You can try increasing buffer size or
            count (BufferSize/Min/MaximumBuffers) - but that won't help if your processing thread stalls on something or just
            stops completely. That's the nature of ETW - you must be able to dequeue events fast enough to not lose them.
            If you're performing complex processing of events, then it makes sense to dump them to file and then read them
            back for expensive processing later, when you finish with trace capture.
            
            For me this kind of error happens typically in situation when I'm debugging code in callback, stepping through
            it pauses threads in debugger, so buffers fill up pretty quickly.
            
            If you want real time stats about how full are buffers, then you can set up BufferCallback in EVENT_TRACE_LOGFILE
            structure, and then you'll see the numbers from BufferSize/Filled members in callback argument.
            
            Also you can call ControlTrace with QUERY code to get EventsLost count in properties buffer.
        */
        // @Hack set high enough that invaders works, for more realisitic uses of this module it could be much smaller.
        p.BufferSize = 1024; // Kb. Default is 64. Range is [4, 16384]
        // p.MinimumBuffers = 1;

        // p.FlushTimer = 1;

        status = Check(StartTraceA(*session_trace_handle, TRACE_NAME.data, xx p));
        assert(status == ERROR_SUCCESS);

        // @TODO(Charles): Check user gave us <= get_max_simultaneous_pmc_sources (assuming that get_max_simultaneous_pmc_sources works
        // relialby...)

        // Set which pmcs to collect
        source_ids := NewArray(sources.count, u32,, temp);
        for sources  source_ids[it_index] = it.id;

        source_ids_bytes := cast(u32) (source_ids.count * size_of(u32));
        status = Check(TraceSetInformation(session_trace_handle, .TracePmcCounterListInfo, source_ids.data, source_ids_bytes));
        if status != ERROR_SUCCESS {
            log_error("Failed to set pmc sources to %, source_ids == %", sources, source_ids);
            return false;
        }

        // To get PMCs attached to an event we also have to tell etw which events should have pmcs enabled
        events_to_collect_pmcs := CLASSIC_EVENT_ID.[
            .{EventGuid = PerfInfoGuid, Type = xx PerfInfo_Opcode.SYS_CALL_ENTER},
            .{EventGuid = PerfInfoGuid, Type = xx PerfInfo_Opcode.SYS_CALL_EXIT},

            .{EventGuid = ThreadGuid, Type = xx Thread_Opcode.CONTEXT_SWITCH},
        ];

        information_length := cast(u32) (events_to_collect_pmcs.count * size_of(CLASSIC_EVENT_ID));

        status = Check(TraceSetInformation(session_trace_handle, .TracePmcEventListInfo, xx events_to_collect_pmcs.data, information_length));
        if status != ERROR_SUCCESS {
            if status == ERROR_INCORRECT_SIZE {
                log_error("Tried to set TracePmcEventListInfo with % events but it seems that is too many? InformationLength == %", events_to_collect_pmcs.count, information_length);
            } else {
                log_error("TraceSetInformation with class TracePmcEventListInfo failed with error %: '%'", status, System.get_error_string(xx status));
            }
            return false;
        }
    }

    // Open trace for processing incoming events
    {
        logfile: EVENT_TRACE_LOGFILEA;
        logfile.LoggerName = TRACE_NAME.data;
        logfile.ProcessTraceMode = PROCESS_TRACE_MODE_EVENT_RECORD | PROCESS_TRACE_MODE_RAW_TIMESTAMP | PROCESS_TRACE_MODE_REAL_TIME;
        logfile.EventRecordCallback = event_handler;
        logfile.Context = tracer;
        logfile.BufferCallback = buffer_callback;

        consumer_trace_handle = OpenTraceA(*logfile);
        assert(consumer_trace_handle != INVALID_PROCESSTRACE_HANDLE);
    }

    // Start event processing thread
    {
        event_processing_thread.data = tracer;
        thread_init(*event_processing_thread, event_processing_thread_proc);
        thread_start(*event_processing_thread);
    }

    started = true;
    return true;
}

stop_tracing :: (using tracer: *PMC_Tracer) {
    // Stop the trace
    ControlTraceA(session_trace_handle, TRACE_NAME.data, xx *trace.Properties, EVENT_TRACE_CONTROL_STOP);

    // Close processing loop, this will wait until all pending buffers are flushed
    // and TraceEventRecordCallback called on all pending events in buffers
    CloseTrace(consumer_trace_handle);

    // Wait for event processing thread to exit
    if !thread_is_done(*event_processing_thread, -1) {
        assert(false, "thread_is_done returned false?!");
    }

    reset(tracer);
}

reset :: (tracer: *PMC_Tracer) {
    array_reset(*tracer.paused_regions);
    tracer.* = .{};
}

CountPmcsScoped :: (tracer: *PMC_Tracer, traced_thread: *PMC_Traced_Thread) #expand {
    start_counting_pmcs(tracer, traced_thread);
    `defer stop_counting_pmcs(tracer, traced_thread);
}

start_counting_pmcs :: (using tracer: *PMC_Tracer, traced_thread: *PMC_Traced_Thread) {
    // NOTE(Charles): I used to automatically init here if we weren't, I've changed that for now so you are required to
    // explicitly init with the pmc sources you want. Maybe the auto init would be better somehow though?
    assert(started);

    if traced_thread.id == INVALID_TRACED_THREAD_ID {
        // Atm we just store data in one array for all threads so atomic_add here. We could maybe have separate arrays
        // per thread? Then we would want to track the thread_index on the PMC_Traced_Thread.
        traced_thread.id = atomic_add(*next_traced_thread_index, 1);
    } else {
        // :ReusingMarkerWithNewTracer

        // Reusing an already used trace (eg in a real time per frame application), check the trace has completed, reset
        // it if so.
        data := *traced_threads_data[traced_thread.id];
        // assert(data.is_complete == true, "Tried to reuse traced thread with id % before it has completed", traced_thread.id);
        data.is_complete = false;
        for * data.pmcs  it.* = 0;
    }

    data := *traced_threads_data[traced_thread.id];
    data.start_time = seconds_since_init(); // Is it worth using the timestamps of our events rather than timing like this?

    event: Event;
    event.Size = size_of(Event);
    event.Guid = MY_GUID;
    event.Class.Type = MY_START_OPCODE;
    
    event.traced_thread_id = traced_thread.id;
    event.thread_index = context.thread_index;

    status := Check(TraceEvent(session_trace_handle, *event));
    assert(status != ERROR_NOT_ENOUGH_MEMORY, "TraceEvent failed due to ETW buffers being full. See comment above."); // :TraceEventNotEnoughMemory
    assert(status == ERROR_SUCCESS);
}

stop_counting_pmcs :: (using tracer: *PMC_Tracer, traced_thread: *PMC_Traced_Thread) {
    assert(started);

    assert(traced_thread.id != INVALID_TRACED_THREAD_ID, "Invalid trace id");

    data := *traced_threads_data[traced_thread.id];
    data.stop_time = seconds_since_init();

    event: Event;
    event.Size = size_of(Event);
    event.Guid = MY_GUID;
    event.Class.Type = MY_STOP_OPCODE;
    
    event.traced_thread_id = traced_thread.id;
    event.thread_index = context.thread_index;

    status := Check(TraceEvent(session_trace_handle, *event));
    assert(status != ERROR_NOT_ENOUGH_MEMORY, "TraceEvent failed due to ETW buffers being full. See comment above."); // :TraceEventNotEnoughMemory
    assert(status == ERROR_SUCCESS);
}

is_complete :: (using tracer: *PMC_Tracer, traced_thread: *PMC_Traced_Thread) -> bool {
    assert(traced_thread.id != INVALID_TRACED_THREAD_ID, "Invalid trace id");

    data := *traced_threads_data[traced_thread.id];
    return data.is_complete;
}

get_result :: (using tracer: *PMC_Tracer, traced_thread: *PMC_Traced_Thread) -> PMC_Trace_Result {
    assert(traced_thread.id != INVALID_TRACED_THREAD_ID, "Invalid trace id");

    data := *traced_threads_data[traced_thread.id];
    result: PMC_Trace_Result;
    result.time_taken = data.stop_time - data.start_time;
    result.pmc_values = data.pmcs;
    result.pmc_count = sources.count;

    for sources  result.pmc_names[it_index] = it.name;

    return result;
}

wait_for_result :: (using tracer: *PMC_Tracer, traced_thread: *PMC_Traced_Thread) -> PMC_Trace_Result {
    while !is_complete(tracer, traced_thread) {
        // print("Not complete, sleeping...\n");
        // @TODO(Charles): Casey specfically spins here and doesn't sleep. Check why?
        sleep_milliseconds(100);
    }

    return get_result(tracer, traced_thread);
}

print_result :: (using tracer: *PMC_Tracer, using result: *PMC_Trace_Result) {
    print("PMC_Trace took %s\n", formatFloat(time_taken, trailing_width = 2));
    for 0..sources.count-1 {
        print("  %: %\n", pmc_names[it], pmc_values[it]);
    }
}

#scope_file

event_processing_thread_proc :: (thread: *Thread) -> s64 {
    #assert OS == .WINDOWS; // :WindowsOnly
    assert(GetCurrentThreadId() == cast(u32) thread.windows_thread_id);
    // print("process_events has thread index %, windows_thread_id %\n", thread.index, thread.windows_thread_id);

    pmc_tracer := cast(*PMC_Tracer) thread.data;
    pmc_tracer.event_processing_thread_context = *context;
    status := Check(ProcessTrace(*pmc_tracer.consumer_trace_handle, 1, null, null));

    return 0;
}

// Casey says to RegisterTraceGuids our own guid, but we can just reuse an existing one and use opcodes those providers
// don't ever use?
MY_GUID :: ThreadGuid;
MY_START_OPCODE : u8 : 253;
MY_STOP_OPCODE  : u8 : 254;
MY_ENABLE_FLAG :: Trace_Enable_Flags.CSWITCH; // Is this necessary?

event_handler :: (event: *EVENT_RECORD) #c_call {
    pmc_tracer := cast(*PMC_Tracer) event.UserContext;

    push_context,defer_pop pmc_tracer.event_processing_thread_context;

    cpu_index := GetEventProcessorIndex(event);

    using event.EventHeader; // using pog!

    // The TimeStamp here depends on Clock_Resolution, atm we are set to QPC so can't convert this to a time like this.
    /*
    filetime := FILETIME.{QuadPart = xx TimeStamp.QuadPart};
    time := filetime_to_apollo(filetime);
    ct := to_calendar(time);
    */
    
    opcode := EventDescriptor.Opcode;

    active_region := *pmc_tracer.active_regions[cpu_index];

    if ProviderId == MY_GUID {
        assert(MY_GUID == ThreadGuid); // Using ThreadGuid for our start/stop, but also now want to look at context switches...

        if opcode == {
            case MY_START_OPCODE;
                assert(event.ExtendedDataCount == 0, "Omg we had extended data in our start/stop markers?!");
                assert(event.UserDataLength == size_of(Event_User_Data), "UserDataLength == %, but size_of(Event_User_Data) == %", event.UserDataLength, size_of(Event_User_Data));
                user_data := cast(*Event_User_Data) event.UserData;

                assert(active_region.type == .NONE, "[%] Received START event when last event was %?!", cpu_index, active_region.type);
                active_region.type = .START;
                active_region.traced_thread_id = user_data.traced_thread_id;
                active_region.thread_index = user_data.thread_index;
                active_region.windows_thread_id = ThreadId;

                #if LOG_EVENTS  print("[%] [%] Start\n", cpu_index, active_region.windows_thread_id);

            case MY_STOP_OPCODE;
                #if LOG_EVENTS  print("[%] [%] Stop\n", cpu_index, active_region.windows_thread_id);

                traced_thread_data := *pmc_tracer.traced_threads_data[active_region.traced_thread_id];

                // if traced_thread_data.sources_id != pmc_tracer.sources_id {
                //     print("STOP received for old sources id %, current is %\n", traced_thread_data.sources_id, pmc_tracer.sources_id);
                //     return;
                // }

                if active_region.type == .SYS_CALL_ENTER {
                    // Pmc values are updated during SYS_CALL_ENTER event now.
                } else if active_region.type == .START {
                    // NOTE(Charles): When I started trying to handle multiple threads I started hitting assertions
                    // in the event handler because a context switch had happened and the cpu_index our event was 
                    // happening on didn't match where it thought it should be. When this happened all following runs
                    // of the program would not receive any kernel events and we would hit an assertion here. I found that
                    // having the program succesfully exit once would then make future runs work, so just handling this
                    // error like this!
                    //
                    // @TODO(Charles): This should now be fixed. Delete comment and tidy up if so!
                    log_error("[%] Received STOP event when last event was START, the SysCallExit/Enter events were not recorded?", cpu_index);
                } else {
                    assert(false, "[%] Received STOP event when last event was %", cpu_index, active_region.type);
                }

                active_region.type = .NONE;
                traced_thread_data.is_complete = true;

            case xx Thread_Opcode.CONTEXT_SWITCH;
                assert(ProcessId == KERNEL_PROCESS_ID); // Useless!
                    
                assert(event.UserData != null);
                data := cast(*Context_Switch_User_Data) event.UserData;

                old_thread_pid := win32_get_process_id_from_thread_id(data.OldThreadId);
                new_thread_pid := win32_get_process_id_from_thread_id(data.NewThreadId);

                // Ignore context switches from this event processing thread! 
                event_processing_tid := cast(u32) pmc_tracer.event_processing_thread.windows_thread_id;

                // Handle an active thread getting switched out
                if old_thread_pid == my_process_id && data.OldThreadId != event_processing_tid {
                    // print("[%] [%] ContextSwitch Out with WaitReason == %, WaitMode == %\n", cpu_index, data.OldThreadId, data.OldThreadWaitReason, data.OldThreadWaitMode);
                    if active_region.type != .NONE {
                        #if LOG_EVENTS  print("[%] [%] ContextSwitch Out for active region == %\n", cpu_index, data.OldThreadId, active_region.*);
    
                        // On switch out record accumulated pmcs from last start to now
                        pmc_counters := get_pmc_counters(event);
                        // assert(pmc_counters.count == pmc_tracer.sources.count);

                        traced_thread_data := *pmc_tracer.traced_threads_data[active_region.traced_thread_id];
                        for pmc_counters  traced_thread_data.pmcs[it_index] += (it - traced_thread_data.pmcs_start[it_index]);

                        paused_region := array_add(*pmc_tracer.paused_regions);
                        paused_region.active_region_data = active_region.*;
                        active_region.* = .{};
                    } else {
                        // This will hit for threads we are expecting to have active regions, but we haven't entered
                        // the region yet. So not an error.
                        // log_error("[%] [%] ContextSwitch Out triggered on thread we weren't tracking?", cpu_index, data.OldThreadId);
                    }
                }

                // Handle a paused region getting switched back in
                if new_thread_pid == my_process_id && data.NewThreadId != event_processing_tid {
                    // print("[%] [%] ContextSwitch In\n", cpu_index, data.NewThreadId);

                    assert(active_region.type == .NONE, "ContextSwitch in on cpu_index % but we had an active region of type % on this cpu?!", cpu_index, active_region.type);

                    for * pmc_tracer.paused_regions {
                        if it.windows_thread_id == data.NewThreadId {
                            #if LOG_EVENTS  print("[%] [%] ContextSwitch In for paused region == %\n", cpu_index, data.NewThreadId, it.*);

                            active_region.* = it.active_region_data;

                            // On switch in record start pmcs values for later use
                            pmc_counters := get_pmc_counters(event);
                            // assert(pmc_counters.count == pmc_tracer.sources.count);

                            traced_thread_data := *pmc_tracer.traced_threads_data[active_region.traced_thread_id];
                            for pmc_counters  traced_thread_data.pmcs_start[it_index] = it;

                            array_unordered_remove_by_index(*pmc_tracer.paused_regions, it_index); // Q: Is it safe to remove here? Should be as we are breaking?
                            break;
                        }
                    }
                }

        }
    } else if ProviderId == PerfInfoGuid {
        assert(ProcessId == KERNEL_PROCESS_ID);
        assert(ThreadId  == KERNEL_THREAD_ID);

        perfinfo_opcode := cast(PerfInfo_Opcode) opcode;
        if perfinfo_opcode == {
            case .SYS_CALL_EXIT;
                if active_region.type == .START {
                    #if LOG_EVENTS  print("[%] [%] SysCallExit\n", cpu_index, active_region.windows_thread_id);

                    traced_thread_data := *pmc_tracer.traced_threads_data[active_region.traced_thread_id];

                    pmc_counters := get_pmc_counters(event);
                    // assert(pmc_counters.count == pmc_tracer.sources.count);

                    for pmc_counters  traced_thread_data.pmcs_start[it_index] = it;

                    active_region.type = .SYS_CALL_EXIT;
                }

            case .SYS_CALL_ENTER;
                pmc_counters := get_pmc_counters(event);

                if active_region.type == .SYS_CALL_EXIT {
                    #if LOG_EVENTS  print("[%] [%] SysCallEnter\n", cpu_index, active_region.windows_thread_id);

                    traced_thread_data := *pmc_tracer.traced_threads_data[active_region.traced_thread_id];
                    for pmc_counters  traced_thread_data.pmcs[it_index] += (it - traced_thread_data.pmcs_start[it_index]);

                    active_region.type = .SYS_CALL_ENTER;
                }
        }
    }
}

buffer_callback :: (logfile: *EVENT_TRACE_LOGFILEA) -> u32 #c_call {
    using,except(Context) logfile;

    pmc_tracer := cast(*PMC_Tracer) logfile.Context;
    push_context,defer_pop pmc_tracer.event_processing_thread_context;

    // print("BufferSize == %, Filled == %\n", BufferSize, Filled);

    if EventsLost > 0 {
        log_error("ETW lost % events due to buffers being full. BufferSize == %, Filled == %", EventsLost, BufferSize, Filled);
    }

    // This seems to be triggered once per buffer when it has been flushed, EventsLost seems to always be zero, I guess we
    // are losing events because we ran out of buffers. You can ControlTrace to get stats about buffers which might
    // be more useful for properly handling :TraceEventNotEnoughMemory
    #if false {
        status_ := Check(ControlTraceA(session_trace_handle, TRACE_NAME.data, xx *trace.Properties, EVENT_TRACE_CONTROL_QUERY));
        assert(status_ == ERROR_SUCCESS);
        print("propreties == %\n", trace.Properties); // NumberofBuffers, FreeBuffers, EventsLost, BuffersWritten
    }

    // Return 1 to carry on, 0 will terminate ProcessTrace.
    return 1;
}


get_pmc_counters :: (event: *EVENT_RECORD) -> [] u64 {
    pmc_counters: [] u64;

    count := cast(int) event.ExtendedDataCount;
    for 0..count-1 {
        item := event.ExtendedData + it;
        assert(item.ExtType == .PMC_COUNTERS, "Unexpected type %", item.ExtType);

        pmc_counters.data  = cast(*u64) item.DataPtr;
        pmc_counters.count = item.DataSize / size_of(u64);
    } 

    return pmc_counters;
}

my_process_id: u32;

#import,dir "Windows_Event_Tracing";
using Windows :: #import "Windows"; // Using because we want operator== for guid
Windows_Utf8  :: #import "Windows_Utf8";

Event_User_Data :: struct {
    traced_thread_id := INVALID_TRACED_THREAD_ID;
    thread_index: int; // Just used for debugging atm
}

Event :: struct {
    #as using header: EVENT_TRACE_HEADER;
    using user_data: Event_User_Data;
}


#import "Basic";
#import "Atomics";
#import "Thread";
System :: #import "System";
