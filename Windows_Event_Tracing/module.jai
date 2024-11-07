//
// Bindings and helpers to Event Tracing for Windows (ETW) api.
//


//
// To succsefully run on windows we have to have an "elevated" process, ie "Run as administrator", and our process
// needs some additional privilige. Helpers to do that: 
//

is_process_elevated :: () -> bool {
    result := false;

    token: HANDLE;
    if OpenProcessToken(GetCurrentProcess(), TOKEN_QUERY, *token) {
        elevation: TOKEN_ELEVATION;
        size: u32;
        if GetTokenInformation(token, .TokenElevation, *elevation, size_of(TOKEN_ELEVATION), *size) {
            result = elevation.TokenIsElevated != 0;
        }
        CloseHandle(token);
    }

    return result;
}

enable_profile_privilege :: () -> bool {
    result := false;

    token: HANDLE;
    if OpenProcessToken(GetCurrentProcess(), TOKEN_ADJUST_PRIVILEGES, *token)
    {
        luid: LUID;
        if LookupPrivilegeValue(null, "SeSystemProfilePrivilege", *luid) { // SE_SYSTEM_PROFILE_NAME
            tp: TOKEN_PRIVILEGES;
            tp.PrivilegeCount = 1;
            tp.Privileges[0].Luid = luid;
            tp.Privileges[0].Attributes = SE_PRIVILEGE_ENABLED;
            if AdjustTokenPrivileges(token, .FALSE, *tp, size_of(TOKEN_PRIVILEGES), null, null) {
                result = true;
            }
        }
        CloseHandle(token);
    }

    return result;
}


//
// Windows headers do not include definitions for a lot of data returned by events. So here we define what we need
// 

Event_Provider :: struct {
    name: string;
    description: string;
    id: GUID;
}

// This is probably not useful and should be deleted. If you want this kind of information you can use the tdh procedures
find_event_provider :: (guid: GUID) -> bool, Event_Provider {
    event_provider: *Event_Provider;
    for EVENT_PROVIDERS {
        if it.id == guid {
            return true, it;
        }
    }

    return false, .{};
}

// http://www.geoffchappell.com/studies/windows/km/ntoskrnl/api/etw/callouts/hookid.htm
StackWalkGuid :: GUID.{ 0xDEF2FE46, 0x7BD6, 0x4B80, .[0xBD, 0x94, 0xF5, 0x7F, 0xE2, 0x0D, 0x0C, 0xE3] };

// From https://docs.microsoft.com/en-us/windows/win32/etw/nt-kernel-logger-constants:
// "The following values define the possible class GUIDs for kernel events that an NT Kernel Logger session can trace." 
ALPCGuid             :: GUID.{ 0x45d8cccd, 0x539f, 0x4b72, .[0xa8, 0xb7, 0x5c, 0x68, 0x31, 0x42, 0x60, 0x9a] }; // 45d8cccd-539f-4b72-a8b7-5c683142609a
DiskIoGuid           :: GUID.{ 0x3d6fa8d4, 0xfe05, 0x11d0, .[0x9d, 0xda, 0x00, 0xc0, 0x4f, 0xd7, 0xba, 0x7c] }; // 3d6fa8d4-fe05-11d0-9dda-00c04fd7ba7c
// This one is already defined below from evntrace.h?
// EventTraceConfigGuid :: GUID.{ 0x01853a65, 0x418f, 0x4f36, .[0xae, 0xfc, 0xdc, 0x0f, 0x1d, 0x2f, 0xd2, 0x35] }; // 01853a65-418f-4f36-aefc-dc0f1d2fd235
FileIoGuid           :: GUID.{ 0x90cbdc39, 0x4a3e, 0x11d1, .[0x84, 0xf4, 0x00, 0x00, 0xf8, 0x04, 0x64, 0xe3] }; // 90cbdc39-4a3e-11d1-84f4-0000f80464e3
ImageLoadGuid        :: GUID.{ 0x2cb15d1d, 0x5fc1, 0x11d2, .[0xab, 0xe1, 0x00, 0xa0, 0xc9, 0x11, 0xf5, 0x18] }; // 2cb15d1d-5fc1-11d2-abe1-00a0c911f518
PageFaultGuid        :: GUID.{ 0x3d6fa8d3, 0xfe05, 0x11d0, .[0x9d, 0xda, 0x00, 0xc0, 0x4f, 0xd7, 0xba, 0x7c] }; // 3d6fa8d3-fe05-11d0-9dda-00c04fd7ba7c
PerfInfoGuid         :: GUID.{ 0xce1dbfb4, 0x137e, 0x4da6, .[0x87, 0xb0, 0x3f, 0x59, 0xaa, 0x10, 0x2c, 0xbc] }; // ce1dbfb4-137e-4da6-87b0-3f59aa102cbc
ProcessGuid          :: GUID.{ 0x3d6fa8d0, 0xfe05, 0x11d0, .[0x9d, 0xda, 0x00, 0xc0, 0x4f, 0xd7, 0xba, 0x7c] }; // 3d6fa8d0-fe05-11d0-9dda-00c04fd7ba7c
RegistryGuid         :: GUID.{ 0xae53722e, 0xc863, 0x11d2, .[0x86, 0x59, 0x00, 0xc0, 0x4f, 0xa3, 0x21, 0xa1] }; // AE53722E-C863-11d2-8659-00C04FA321A1
SplitIoGuid          :: GUID.{ 0xd837ca92, 0x12b9, 0x44a5, .[0xad, 0x6a, 0x3a, 0x65, 0xb3, 0x57, 0x8a, 0xa8] }; // d837ca92-12b9-44a5-ad6a-3a65b3578aa8
TcpIpGuid            :: GUID.{ 0x9a280ac0, 0xc8e0, 0x11d1, .[0x84, 0xe2, 0x00, 0xc0, 0x4f, 0xb9, 0x98, 0xa2] }; // 9a280ac0-c8e0-11d1-84e2-00c04fb998a2
ThreadGuid           :: GUID.{ 0x3d6fa8d1, 0xfe05, 0x11d0, .[0x9d, 0xda, 0x00, 0xc0, 0x4f, 0xd7, 0xba, 0x7c] }; // 3d6fa8d1-fe05-11d0-9dda-00c04fd7ba7c
UdpIpGuid            :: GUID.{ 0xbf3a50c5, 0xa9c9, 0x4988, .[0xa0, 0x05, 0x2d, 0xf0, 0xb7, 0xc8, 0x0f, 0x80] }; // bf3a50c5-a9c9-4988-a005-2df0b7c80f80

// An attempt at figuring out what the heck all the events are. Maybe there are api calls to help do this, eg TdhEnumerateProviders?
EVENT_PROVIDERS :: Event_Provider.[
    // Defined in evntrace.h
    .{ "EventTrace"               , "Used to identify a event tracing session.", EventTraceGuid }, 
    .{ "SystemTraceControl"       , "Used to specify event tracing for kernel.", SystemTraceControlGuid }, 
    .{ "EventTraceConfig"         , "Used to report system configuration records.", EventTraceConfigGuid }, 
    .{ "DefaultTraceSecurity"     , "Specifies the default event tracing security.", DefaultTraceSecurityGuid }, 
    .{ "PrivateLoggerNotification", "Used for private cross-process logger notifications.", PrivateLoggerNotificationGuid }, 

    // From "kernel-logger-constants" above
    .{ "ALPC"            , "", ALPCGuid },
    .{ "DiskIo"          , "", DiskIoGuid },
    // .{ "EventTraceConfig", "", EventTraceConfigGuid },
    .{ "FileIo"          , "", FileIoGuid },
    .{ "ImageLoad"       , "", ImageLoadGuid },
    .{ "PageFault"       , "", PageFaultGuid },
    .{ "PerfInfo"        , "", PerfInfoGuid },
    .{ "Process"         , "", ProcessGuid },
    .{ "Registry"        , "", RegistryGuid },
    .{ "SplitIo"         , "", SplitIoGuid },
    .{ "TcpIp"           , "", TcpIpGuid },
    .{ "Thread"          , "", ThreadGuid },
    .{ "UdpIp"           , "", UdpIpGuid },
];

// Not found where documented, but it seems like kernel produced events always have these pid/tid
KERNEL_PROCESS_ID :: 0xFFFFFFFF;
KERNEL_THREAD_ID  :: 0xFFFFFFFF;

// It looks like there is this base enum and then depending on the "provider" you have to use different set of constants?
// Same as WINEVENT_OPCODE from winmeta.h
EVENT_TRACE_TYPE :: enum {
    INFO           :: 0x00;  // Info or point event
    START          :: 0x01;  // Start event
    END            :: 0x02;  // End event
    STOP           :: 0x02;  // Stop event (WinEvent compatible)
    DC_START       :: 0x03;  // Collection start marker
    DC_END         :: 0x04;  // Collection end marker
    EXTENSION      :: 0x05;  // Extension/continuation
    REPLY          :: 0x06;  // Reply event
    DEQUEUE        :: 0x07;  // De-queue event
    RESUME         :: 0x07;  // Resume event (WinEvent compatible)
    CHECKPOINT     :: 0x08;  // Generic checkpoint event
    SUSPEND        :: 0x08;  // Suspend event (WinEvent compatible)
    WINEVT_SEND    :: 0x09;  // Send Event (WinEvent compatible)
    WINEVT_RECEIVE :: 0XF0;  // Receive Event (WinEvent compatible)
}

Thread_Opcode :: enum u8 {
    // START
    // END
    // DC_START
    // DC_END
    CONTEXT_SWITCH :: 36;
    READY :: 50;
}

PerfInfo_Opcode :: enum u8 {
    SAMPLED_PROFILE :: 46; // 0x2e
    SYS_CALL_ENTER  :: 51;
    SYS_CALL_EXIT   :: 52;
    DPC_THREADED    :: 66;
    ISR             :: 67;
    DPC             :: 68;
    DPC_TIMER       :: 69;

    // There are others not listed on msdn. According to chatgpt they are for internal use.
}

Context_Switch_Thread_State :: enum s8 {
    Initialized   :: 0;
    Ready         :: 1;
    Running       :: 2;
    Standby       :: 3;
    Terminated    :: 4;
    Waiting       :: 5;
    Transition    :: 6;
    DeferredReady :: 7; // (added for Windows Server 2003)
}

Context_Switch_Wait_Mode :: enum s8 {
    KernelMode :: 0;
    UserMode   :: 1;
}

Context_Switch_Wait_Reason :: enum s8 {
    Executive         :: 0;
    FreePage          :: 1;
    PageIn            :: 2;
    PoolAllocation    :: 3;
    DelayExecution    :: 4;
    Suspended         :: 5;
    UserRequest       :: 6;
    WrExecutive       :: 7;
    WrFreePage        :: 8;
    WrPageIn          :: 9;
    WrPoolAllocation  :: 10;
    WrDelayExecution  :: 11;
    WrSuspended       :: 12;
    WrUserRequest     :: 13;
    WrEventPair       :: 14;
    WrQueue           :: 15;
    WrLpcReceive      :: 16;
    WrLpcReply        :: 17;
    WrVirtualMemory   :: 18;
    WrPageOut         :: 19;
    WrRendezvous      :: 20;
    WrKeyedEvent      :: 21;
    WrTerminated      :: 22;
    WrProcessInSwap   :: 23;
    WrCpuRateControl  :: 24;
    WrCalloutStack    :: 25;
    WrKernel          :: 26;
    WrResource        :: 27;
    WrPushLock        :: 28;
    WrMutex           :: 29;
    WrQuantumEnd      :: 30;
    WrDispatchInt     :: 31;
    WrPreempted       :: 32;
    WrYieldExecution  :: 33;
    WrFastMutex       :: 34;
    WrGuardedMutex    :: 35;
    WrRundown         :: 36;
    MaximumWaitReason :: 37;
}

Context_Switch_User_Data :: struct {
    NewThreadId: u32;
    OldThreadId: u32;
    NewThreadPriority: s8;
    OldThreadPriority: s8;
    PreviousCState:    u8;
    SpareByte:         s8;
    OldThreadWaitReason: Context_Switch_Wait_Reason;
    OldThreadWaitMode:   Context_Switch_Wait_Mode;
    OldThreadState:      Context_Switch_Thread_State;
    OldThreadWaitIdealProcessor: s8;
    NewThreadWaitTime: u32;
    Reserved: u32;
}


//
// Some wrappers/helpers for working with ETW
// 

// Wrapper for TraceQueryInformation
//
// NOTE(Charles): Calling all possible classes it seems most just don't work...:
/*
    ti := type_info(TRACE_QUERY_INFO_CLASS);
    for ti.values {
        info_class := cast(TRACE_QUERY_INFO_CLASS) it;
        success, query_data := trace_query_information(info_class);
        if success  print_color("%: % bytes of data\n", info_class, query_data.count, color = .GREEN);
        else        print("%: Failed!\n", info_class);
    }
*/
// @TODO(Charles): It seems the reason for the above is that for some classes querying for the size
// of output data is not supported. Eg for TraceMaxPmcCounterQuery any attempt to query data size fails
// but if you just pass a pointer to u32 it correctly returns result. Do something about this!
// nocheckin refactor this to be useful and not a total waste of time!
trace_query_information :: (info_class: TRACE_INFO_CLASS, trace_handle := cast(TRACEHANDLE) 0) -> bool, [] u8 {
    buffer_size: u32;
    result := TraceQueryInformation(trace_handle, info_class, null, 0, *buffer_size);
    if result == ERROR_NOT_SUPPORTED  return false, .[];

    if result != ERROR_BAD_LENGTH {
        log_error("Calling TraceQueryInformation with class % to query data size failed with error %: '%'", info_class, result, System.get_error_string(xx result));
        return false, .[];
    }

    if buffer_size == 0  return true, .[]; // No data

    buffer := NewArray(buffer_size, u8, false);

    buffer_size = 0; // ?
    result = TraceQueryInformation(trace_handle, info_class, buffer.data, xx buffer.count, *buffer_size);
    if result != ERROR_SUCCESS {
        log_error("Calling TraceQueryInformation witih class % to get % bytes of data failed with error %: '%'", info_class, buffer.count, result, System.get_error_string(xx result));
        array_free(buffer);
        return false, .[];   
    }

    return true, buffer;
}

tdh_get_event_information :: (event: *EVENT_RECORD) -> *TRACE_EVENT_INFO {
    buffer_size: u32;
    result := TdhGetEventInformation(event, 0, null, null, *buffer_size);
    assert(result == ERROR_INSUFFICIENT_BUFFER);

    trace_event_info := cast(*TRACE_EVENT_INFO) alloc(buffer_size);
    memset(xx trace_event_info, 0, buffer_size);

    result = TdhGetEventInformation(event, 0, null, trace_event_info, *buffer_size);
    if result != ERROR_SUCCESS {
        print("TdhGetEventInformation failed with error %: '%'\n", result, System.get_error_string(xx result));
        assert(false);
    }

    return trace_event_info;
}

// @BadName
TEI_STRING :: (info: *TRACE_EVENT_INFO, offset: u32) -> string #expand {
    wide_string := ifx offset then cast(*u16) (cast(*u8)info + offset) else null;
    s := wide_to_utf8_new(wide_string);
    return s;
}

print_trace_event_info :: (info: *TRACE_EVENT_INFO) {
    new_context := context;
    new_context.allocator = temp;
    push_context,defer_pop new_context;

    provider_string, event_string: string;
    for EVENT_PROVIDERS {
        if it.id == info.ProviderGuid  provider_string = it.name;
        if it.id == info.EventGuid     event_string    = it.name;
    }

    print("TRACE_EVENT_INFO:\n");
    print("  Provider: %\n", provider_string);
    print("  Event:    %\n", event_string);

    assert(info.EventDescriptor.Id == 0);
    // assert(info.EventDescriptor.Version == 0); // Isn't zero, but apparently not meaningful?
    assert(info.EventDescriptor.Channel == 0);
    assert(info.EventDescriptor.Level == 0);
    assert(info.EventDescriptor.Task == 0);
    assert(info.EventDescriptor.Keyword == 0);
    print("  Opcode: 0x%\n", formatInt(info.EventDescriptor.Opcode, base=16));

    // EventDescriptor
    assert(info.DecodingSource == .Wbem, "Unhandled decoding source == %", info.DecodingSource);
    // print("  ProviderName: %\n", wide_to_utf8_new(TEI_PROVIDER_NAME(info)));
    if info.ProviderNameOffset  print("  ProviderName: %\n", TEI_STRING(info, info.ProviderNameOffset));
    if info.LevelNameOffset     print("  LevelName:    %\n", TEI_STRING(info, info.LevelNameOffset));
    if info.ChannelNameOffset   print("  ChannelName:  %\n", TEI_STRING(info, info.ChannelNameOffset));
    if info.KeywordsNameOffset  print("  KeywordsName: %\n", TEI_STRING(info, info.KeywordsNameOffset));

    print("  TaskName (\"DisplayName\"):     %\n", TEI_STRING(info, info.TaskNameOffset));
    print("  OpcodeName (\"EventTypeName\"): %\n", TEI_STRING(info, info.OpcodeNameOffset));

    if info.EventMessageOffset     print("  EventMessage:    %\n", TEI_STRING(info, info.EventMessageOffset));
    if info.ProviderMessageOffset  print("  ProviderMessage: %\n", TEI_STRING(info, info.ProviderMessageOffset));

    assert(info.BinaryXMLOffset == 0 && info.BinaryXMLSize == 0);

    // Only valid for Wbem events
    if info.ActivityIDNameOffset         print("  ActivityIDName:        %\n", TEI_STRING(info, info.ActivityIDNameOffset));
    if info.RelatedActivityIDNameOffset  print("  RelatedActivityIDName: %\n", TEI_STRING(info, info.RelatedActivityIDNameOffset));

    assert(info.TopLevelPropertyCount == info.PropertyCount, "TopLevelPropertyCount (%) != PropertyCount (%)", info.TopLevelPropertyCount, info.PropertyCount);
    assert(info.Flags == 0);

    print("  Properties:\n");

    properties : [] EVENT_PROPERTY_INFO = info.EventPropertyInfoArray;
    properties.count = info.PropertyCount;

    // This property information can be used to decode EVENT_RECORD.UserData. Could be done programatically, but for our
    // uses it's enough to just hardcode the types.
    for * properties {
        name := wide_to_utf8_new(TEI_PROPERTY_NAME(info, it));
        print("    %: %", it_index, name);

        assert(it.Flags == 0, "Property % had non zero flags %", name, it.Flags);
        assert(it.nonStructType.MapNameOffset == 0);
        in_type  := cast(TDH_IN_TYPE)  it.nonStructType.InType;
        out_type := cast(TDH_OUT_TYPE) it.nonStructType.OutType;

        print(" InType == %, OutType == %, count == %, length == %\n", in_type, out_type, it.count, it.length);

        assert(it.Tags == 0);
    }

    print("\n");
}


//
// Some other win32 helpers
//

// Check win32 call for error
Check :: (result: u32, $call := #caller_code, loc := #caller_location) -> u32 #expand {
    #import "Compiler";
    System :: #import "System";

    call_string :: #run -> string {
        root := compiler_get_nodes(call);

        call_string := "Unknown";

        if root.kind == {
            case .PROCEDURE_CALL;
            proc_call  := cast(*Code_Procedure_Call) root;
            expression := proc_call.arguments_sorted[0];

            if expression.kind == .PROCEDURE_CALL {
                call := cast(*Code_Procedure_Call) expression;
                if call.procedure_expression.kind == .IDENT {
                    call_string = (cast(*Code_Ident) call.procedure_expression).name;
                }
            }

            case .IDENT;
            call_string = (cast(*Code_Ident) root).name;
        }

        return call_string;
    };

    if result != ERROR_SUCCESS {
        log_error("%:%: Win32 call '%' failed with error 0x%: '%'", loc.fully_pathed_filename, loc.line_number, call_string, formatInt(result, base = 16), System.get_error_string(xx result), loc = loc);
    }
    return result;
}

win32_get_process_id_from_thread_id :: (thread_id: u32) -> u32, bool {
    THREAD_QUERY_INFORMATION : u32 : 0x0040;
    kernel32 :: #system_library "Kernel32";
    GetProcessIdOfThread :: (Thread: HANDLE) -> u32 #foreign kernel32;

    process_id: u32;
    thread_handle := OpenThread(THREAD_QUERY_INFORMATION, .FALSE, thread_id);
    if thread_handle {
        process_id = GetProcessIdOfThread(thread_handle);
    }

    return process_id, process_id != 0;
}


//
// Bindings.
// 
// NOTE(Charles): I have maintained most of what was present in the original headers. Some exceptions are warning and region
// pragmas have been deleted. Some #ifdefs that looked unimportant have also gone, eg _APISET_EVENTING. Other ifdefs where
// I don't totally understand I have left verbatim but commented out, eg _WMIKM_. 
//
// Enums have had their members renamed to be jai style.
// 
// @CommentsRemoved: Where original comments were very long they have been removed. Refer to c headers. This might not
// have been a good idea... ETW is super under documented in general and sometimes header comments are all there is.
//
// @TODO(Charles): Remove all *W prefixed stuff and just use A?
//

#load "evntrace.jai";
#load "evntcons.jai";
#load "evntprov.jai";
#load "tdh.jai";

// @Incomplete: The above headers have been ported in their entirity, the below eg wmistr, have only been done as needed.

// Some windows error codes that modules/Windows does not define (from winerror.h)
ERROR_SUCCESS             :: 0;

ERROR_NOT_ENOUGH_MEMORY   :: 8;
ERROR_BAD_LENGTH          :: 24;
ERROR_NOT_SUPPORTED       :: 50;
ERROR_INSUFFICIENT_BUFFER :: 122;
ERROR_BUSY                :: 170;
ERROR_INCORRECT_SIZE      :: 1462;
ERROR_WMI_INSTANCE_NOT_FOUND :: 4201;
ERROR_CTX_CLOSE_PENDING   :: 7007;

ANYSIZE_ARRAY :: 1; // From ntdef.h

//~
// wmistr.h
WNODE_HEADER :: struct {
    BufferSize: u32;        // Size of entire buffer inclusive of this u32
    ProviderId: u32;        // Provider Id of driver returning this buffer
    union {
        HistoricalContext: u64;  // Logger use
        struct {
            Version: u32;           // Reserved
            Linkage: u32;           // Linkage field reserved for WMI
        }
    }

    union {
        CountLost: u32;           // Reserved
        KernelHandle: HANDLE;     // Kernel handle for data block
        TimeStamp: LARGE_INTEGER; // Timestamp as returned in units of 100ns since 1/1/1601
    }
    Guid: GUID;                  // Guid for data block returned with results
    ClientContext: enum u32 { // This determines the format of EVENT_RECORD.TimeStamp 
        QPC;       // Query performance counter
        SYSTEM;
        CPU_CYCLE; // ?
    };
    Flags: WNODE_FLAG = .TRACED_GUID; // NOTE(Charles): Defaulted to value it appears we always want?
}

// @CommentsRemoved
WNODE_FLAG :: enum_flags u32 {
    ALL_DATA              :: 0x00000001;
    SINGLE_INSTANCE       :: 0x00000002;
    SINGLE_ITEM           :: 0x00000004;
    EVENT_ITEM            :: 0x00000008;
    FIXED_INSTANCE_SIZE   :: 0x00000010;
    TOO_SMALL             :: 0x00000020;
    INSTANCES_SAME        :: 0x00000040;
    STATIC_INSTANCE_NAMES :: 0x00000080;
    INTERNAL              :: 0x00000100;
    USE_TIMESTAMP         :: 0x00000200;
    PERSIST_EVENT         :: 0x00000400;
    EVENT_REFERENCE       :: 0x00002000;
    ANSI_INSTANCENAMES    :: 0x00004000;
    METHOD_ITEM           :: 0x00008000;
    PDO_INSTANCE_NAMES    :: 0x00010000;
    TRACED_GUID           :: 0x00020000;
    LOG_WNODE             :: 0x00040000;
    USE_GUID_PTR          :: 0x00080000;
    USE_MOF_PTR           :: 0x00100000;
    NO_HEADER             :: 0x00200000;
    SEND_DATA_BLOCK       :: 0x00400000;
    VERSIONED_PROPERTIES  :: 0x00800000;
    SEVERITY_MASK         :: 0xff000000;
}

// WMI request codes
WMIDPREQUESTCODE :: enum {
// #ifndef _WMIKM_
    WMI_GET_ALL_DATA        :: 0;
    WMI_GET_SINGLE_INSTANCE :: 1;
    WMI_SET_SINGLE_INSTANCE :: 2;
    WMI_SET_SINGLE_ITEM     :: 3;
    WMI_ENABLE_EVENTS       :: 4;
    WMI_DISABLE_EVENTS      :: 5;
    WMI_ENABLE_COLLECTION   :: 6;
    WMI_DISABLE_COLLECTION  :: 7;
    WMI_REGINFO             :: 8;
    WMI_EXECUTE_METHOD      :: 9;
    WMI_CAPTURE_STATE       :: 10;
// #endif
}
//~


#scope_module

#import "Basic";
#import "Windows_Utf8";
System :: #import "System";
using,except(TIME_ZONE_INFORMATION) Windows :: #import "Windows";

// modules/Windows doesn't fully define this, we make our own version!
TIME_ZONE_INFORMATION :: struct {
    Bias: s32;
    StandardName: [32] u16;
    StandardDate: SYSTEMTIME;
    StandardBias: s32;
    DaylightName: [32] u16;
    DaylightDate: SYSTEMTIME;
    DaylightBias: s32;
}

advapi32 :: #system_library "advapi32";

//
// Other windows bindings used internally by this module
//

TOKEN_INFORMATION_CLASS :: enum s32 {
    TokenUser :: 1;
    TokenGroups;
    TokenPrivileges;
    TokenOwner;
    TokenPrimaryGroup;
    TokenDefaultDacl;
    TokenSource;
    TokenType;
    TokenImpersonationLevel;
    TokenStatistics;
    TokenRestrictedSids;
    TokenSessionId;
    TokenGroupsAndPrivileges;
    TokenSessionReference;
    TokenSandBoxInert;
    TokenAuditPolicy;
    TokenOrigin;
    TokenElevationType;
    TokenLinkedToken;
    TokenElevation;
    TokenHasRestrictions;
    TokenAccessInformation;
    TokenVirtualizationAllowed;
    TokenVirtualizationEnabled;
    TokenIntegrityLevel;
    TokenUIAccess;
    TokenMandatoryPolicy;
    TokenLogonSid;
    TokenIsAppContainer;
    TokenCapabilities;
    TokenAppContainerSid;
    TokenAppContainerNumber;
    TokenUserClaimAttributes;
    TokenDeviceClaimAttributes;
    TokenRestrictedUserClaimAttributes;
    TokenRestrictedDeviceClaimAttributes;
    TokenDeviceGroups;
    TokenRestrictedDeviceGroups;
    TokenSecurityAttributes;
    TokenIsRestricted;
    TokenProcessTrustLevel;
    TokenPrivateNameSpace;
    TokenSingletonAttributes;
    TokenBnoIsolation;
    TokenChildProcessFlags;
    TokenIsLessPrivilegedAppContainer;
    TokenIsSandboxed;
    TokenIsAppSilo;
    MaxTokenInfoClass;
}

TOKEN_ELEVATION :: struct {
    TokenIsElevated: u32;
}

TOKEN_QUERY             : u32 : 0x0008;
TOKEN_ADJUST_PRIVILEGES : u32 : 0x0020;

LUID_AND_ATTRIBUTES :: struct {
    Luid: LUID;
    Attributes: u32;
}

TOKEN_PRIVILEGES :: struct {
    PrivilegeCount: u32;
    Privileges: [ANYSIZE_ARRAY] LUID_AND_ATTRIBUTES;
}

SE_PRIVILEGE_ENABLED :: 0x00000002;

kernel32 :: #system_library "kernel32";

OpenProcessToken :: (ProcessHandle: *void, DesiredAccess: u32, TokenHandle: **void) -> s32 #foreign kernel32;
GetTokenInformation :: (TokenHandle: HANDLE, TokenInformationClass: TOKEN_INFORMATION_CLASS, TokenInformation: *void, TokenInformationLength: u32, ReturnLength: *u32) -> BOOL #foreign advapi32;
LookupPrivilegeValue :: (lpSystemName: *u8, lpName: *u8, lpLuid: *LUID) -> BOOL #foreign advapi32 "LookupPrivilegeValueA";
AdjustTokenPrivileges :: (TokenHandle: *void, DisableAllPrivileges: BOOL, NewState: *TOKEN_PRIVILEGES, BufferLength: u32, PreviousState: *TOKEN_PRIVILEGES, ReturnLength: *u32) -> BOOL #foreign advapi32;
