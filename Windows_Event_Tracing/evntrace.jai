#scope_file 
// @Cleanup: Decide what to do about W vs A. Probably get rid of W stuff and just use A>
USE_W_VERSIONS :: false; // In windows headers this is ifdef with "defined(_UNICODE) || defined(UNICODE)"
#scope_export

EventTraceGuid                :: GUID.{0x68fdd900, 0x4a3e, 0x11d1, .[0x84, 0xf4, 0x00, 0x00, 0xf8, 0x04, 0x64, 0xe3]}; // Used to identify a event tracing session. 68fdd900-4a3e-11d1-84f4-0000f80464e3
SystemTraceControlGuid        :: GUID.{0x9e814aad, 0x3204, 0x11d2, .[0x9a, 0x82, 0x00, 0x60, 0x08, 0xa8, 0x69, 0x39]}; // Used to specify event tracing for kernel. 9e814aad-3204-11d2-9a82-006008a86939
EventTraceConfigGuid          :: GUID.{0x01853a65, 0x418f, 0x4f36, .[0xae, 0xfc, 0xdc, 0x0f, 0x1d, 0x2f, 0xd2, 0x35]}; // Used to report system configuration records. 01853a65-418f-4f36-aefc-dc0f1d2fd235
DefaultTraceSecurityGuid      :: GUID.{0x0811c1af, 0x7a07, 0x4a06, .[0x82, 0xed, 0x86, 0x94, 0x55, 0xcd, 0xf7, 0x13]}; // Specifies the default event tracing security. 0811c1af-7a07-4a06-82ed-869455cdf713
PrivateLoggerNotificationGuid :: GUID.{0x3595ab5c, 0x042a, 0x4c8e, .[0xb9, 0x42, 0x2d, 0x05, 0x9b, 0xfe, 0xb1, 0xb1]}; // Used for private cross-process logger notifications. 3595ab5c-042a-4c8e-b942-2d059bfeb1b1

//
// System Provider GUIDs
//
SystemIoFilterProviderGuid   :: GUID.{0xfbd09363, 0x9e22, 0x4661, .[0xb8, 0xbf, 0xe7, 0xa3, 0x4b, 0x53, 0x5b, 0x8c]}; // fbd09363-9e22-4661-b8bf-e7a34b535b8c
SystemObjectProviderGuid     :: GUID.{0xfebd7460, 0x3d1d, 0x47eb, .[0xaf, 0x49, 0xc9, 0xee, 0xb1, 0xe1, 0x46, 0xf2]}; // febd7460-3d1d-47eb-af49-c9eeb1e146f2
SystemPowerProviderGuid      :: GUID.{0xc134884a, 0x32d5, 0x4488, .[0x80, 0xe5, 0x14, 0xed, 0x7a, 0xbb, 0x82, 0x69]}; // c134884a-32d5-4488-80e5-14ed7abb8269
SystemHypervisorProviderGuid :: GUID.{0xbafa072a, 0x918a, 0x4bed, .[0xb6, 0x22, 0xbc, 0x15, 0x20, 0x97, 0x09, 0x8f]}; // bafa072a-918a-4bed-b622-bc152097098f
SystemLockProviderGuid       :: GUID.{0x721ddfd3, 0xdacc, 0x4e1e, .[0xb2, 0x6a, 0xa2, 0xcb, 0x31, 0xd4, 0x70, 0x5a]}; // 721ddfd3-dacc-4e1e-b26a-a2cb31d4705a
SystemConfigProviderGuid     :: GUID.{0xfef3a8b6, 0x318d, 0x4b67, .[0xa9, 0x6a, 0x3b, 0x0f, 0x6b, 0x8f, 0x18, 0xfe]}; // fef3a8b6-318d-4b67-a96a-3b0f6b8f18fe
SystemCpuProviderGuid        :: GUID.{0xc6c5265f, 0xeae8, 0x4650, .[0xaa, 0xe4, 0x9d, 0x48, 0x60, 0x3d, 0x85, 0x10]}; // c6c5265f-eae8-4650-aae4-9d48603d8510
SystemSchedulerProviderGuid  :: GUID.{0x599a2a76, 0x4d91, 0x4910, .[0x9a, 0xc7, 0x7d, 0x33, 0xf2, 0xe9, 0x7a, 0x6c]}; // 599a2a76-4d91-4910-9ac7-7d33f2e97a6c
SystemProfileProviderGuid    :: GUID.{0xbfeb0324, 0x1cee, 0x496f, .[0xa4, 0x09, 0x2a, 0xc2, 0xb4, 0x8a, 0x63, 0x22]}; // bfeb0324-1cee-496f-a409-2ac2b48a6322
SystemIoProviderGuid         :: GUID.{0x3d5c43e3, 0x0f1c, 0x4202, .[0xb8, 0x17, 0x17, 0x4c, 0x00, 0x70, 0xdc, 0x79]}; // 3d5c43e3-0f1c-4202-b817-174c0070dc79
SystemMemoryProviderGuid     :: GUID.{0x82958ca9, 0xb6cd, 0x47f8, .[0xa3, 0xa8, 0x03, 0xae, 0x85, 0xa4, 0xbc, 0x24]}; // 82958ca9-b6cd-47f8-a3a8-03ae85a4bc24
SystemRegistryProviderGuid   :: GUID.{0x16156bd9, 0xfab4, 0x4cfa, .[0xa2, 0x32, 0x89, 0xd1, 0x09, 0x90, 0x58, 0xe3]}; // 16156bd9-fab4-4cfa-a232-89d1099058e3
SystemProcessProviderGuid    :: GUID.{0x151f55dc, 0x467d, 0x471f, .[0x83, 0xb5, 0x5f, 0x88, 0x9d, 0x46, 0xff, 0x66]}; // 151f55dc-467d-471f-83b5-5f889d46ff66
SystemAlpcProviderGuid       :: GUID.{0xfcb9baaf, 0xe529, 0x4980, .[0x92, 0xe9, 0xce, 0xd1, 0xa6, 0xaa, 0xdf, 0xdf]}; // fcb9baaf-e529-4980-92e9-ced1a6aadfdf
SystemSyscallProviderGuid    :: GUID.{0x434286f7, 0x6f1b, 0x45bb, .[0xb3, 0x7e, 0x95, 0xf6, 0x23, 0x04, 0x6c, 0x7c]}; // 434286f7-6f1b-45bb-b37e-95f623046c7c
SystemInterruptProviderGuid  :: GUID.{0xd4bbee17, 0xb545, 0x4888, .[0x85, 0x8b, 0x74, 0x41, 0x69, 0x01, 0x5b, 0x25]}; // d4bbee17-b545-4888-858b-744169015b25
SystemTimerProviderGuid      :: GUID.{0x4f061568, 0xe215, 0x499f, .[0xab, 0x2e, 0xed, 0xa0, 0xae, 0x89, 0x0a, 0x5b]}; // 4f061568-e215-499f-ab2e-eda0ae890a5b

// #define KERNEL_LOGGER_NAMEW         L"NT Kernel Logger"
// #define GLOBAL_LOGGER_NAMEW         L"GlobalLogger"
// #define EVENT_LOGGER_NAMEW          L"EventLog"
// #define DIAG_LOGGER_NAMEW           L"DiagLog"

KERNEL_LOGGER_NAMEA :: "NT Kernel Logger";
GLOBAL_LOGGER_NAMEA :: "GlobalLogger";
EVENT_LOGGER_NAMEA  :: "EventLog";
DIAG_LOGGER_NAMEA   :: "DiagLog";

MAX_MOF_FIELDS :: 16;  // Limit of USE_MOF_PTR fields

TRACEHANDLE :: u64;

 //types for event data going to System Event Logger
SYSTEM_EVENT_TYPE :: 1;

//
// predefined generic event types (0x00 to 0x09 reserved).
//

EVENT_TRACE_TYPE_INFO           :: 0x00;  // Info or point event
EVENT_TRACE_TYPE_START          :: 0x01;  // Start event
EVENT_TRACE_TYPE_END            :: 0x02;  // End event
EVENT_TRACE_TYPE_STOP           :: 0x02;  // Stop event (WinEvent compatible)
EVENT_TRACE_TYPE_DC_START       :: 0x03;  // Collection start marker
EVENT_TRACE_TYPE_DC_END         :: 0x04;  // Collection end marker
EVENT_TRACE_TYPE_EXTENSION      :: 0x05;  // Extension/continuation
EVENT_TRACE_TYPE_REPLY          :: 0x06;  // Reply event
EVENT_TRACE_TYPE_DEQUEUE        :: 0x07;  // De-queue event
EVENT_TRACE_TYPE_RESUME         :: 0x07;  // Resume event (WinEvent compatible)
EVENT_TRACE_TYPE_CHECKPOINT     :: 0x08;  // Generic checkpoint event
EVENT_TRACE_TYPE_SUSPEND        :: 0x08;  // Suspend event (WinEvent compatible)
EVENT_TRACE_TYPE_WINEVT_SEND    :: 0x09;  // Send Event (WinEvent compatible)
EVENT_TRACE_TYPE_WINEVT_RECEIVE :: 0XF0;  // Receive Event (WinEvent compatible)

//
// Predefined Event Tracing Levels for Software/Debug Tracing
//
//
// Trace Level is u8 and passed in through the EnableLevel parameter
// in EnableTrace API. It is retrieved by the provider using the
// GetTraceEnableLevel macro.It should be interpreted as an integer value
// to mean everything at or below that level will be traced.
//
// Here are the possible Levels.
//

TRACE_LEVEL_NONE        :: 0;   // Tracing is not on
TRACE_LEVEL_CRITICAL    :: 1;   // Abnormal exit or termination
TRACE_LEVEL_FATAL       :: 1;   // Deprecated name for Abnormal exit or termination
TRACE_LEVEL_ERROR       :: 2;   // Severe errors that need logging
TRACE_LEVEL_WARNING     :: 3;   // Warnings such as allocation failure
TRACE_LEVEL_INFORMATION :: 4;   // Includes non-error cases(e.g.,Entry-Exit)
TRACE_LEVEL_VERBOSE     :: 5;   // Detailed traces from intermediate steps
TRACE_LEVEL_RESERVED6   :: 6;
TRACE_LEVEL_RESERVED7   :: 7;
TRACE_LEVEL_RESERVED8   :: 8;
TRACE_LEVEL_RESERVED9   :: 9;


//
// Event types for Process & Threads
//

EVENT_TRACE_TYPE_LOAD      :: 0x0A;      // Load image
EVENT_TRACE_TYPE_TERMINATE :: 0x0B;      // Terminate Process

//
// Event types for IO subsystem
//

EVENT_TRACE_TYPE_IO_READ            :: 0x0A;
EVENT_TRACE_TYPE_IO_WRITE           :: 0x0B;
EVENT_TRACE_TYPE_IO_READ_INIT       :: 0x0C;
EVENT_TRACE_TYPE_IO_WRITE_INIT      :: 0x0D;
EVENT_TRACE_TYPE_IO_FLUSH           :: 0x0E;
EVENT_TRACE_TYPE_IO_FLUSH_INIT      :: 0x0F;
EVENT_TRACE_TYPE_IO_REDIRECTED_INIT :: 0x10;

//
// Event types for Memory subsystem
//

EVENT_TRACE_TYPE_MM_TF  :: 0x0A;      // Transition fault
EVENT_TRACE_TYPE_MM_DZF :: 0x0B;      // Demand Zero fault
EVENT_TRACE_TYPE_MM_COW :: 0x0C;      // Copy on Write
EVENT_TRACE_TYPE_MM_GPF :: 0x0D;      // Guard Page fault
EVENT_TRACE_TYPE_MM_HPF :: 0x0E;      // Hard page fault
EVENT_TRACE_TYPE_MM_AV  :: 0x0F;      // Access violation

//
// Event types for Network subsystem, all protocols
//

EVENT_TRACE_TYPE_SEND       :: 0x0A;     // Send
EVENT_TRACE_TYPE_RECEIVE    :: 0x0B;     // Receive
EVENT_TRACE_TYPE_CONNECT    :: 0x0C;     // Connect
EVENT_TRACE_TYPE_DISCONNECT :: 0x0D;     // Disconnect
EVENT_TRACE_TYPE_RETRANSMIT :: 0x0E;     // ReTransmit
EVENT_TRACE_TYPE_ACCEPT     :: 0x0F;     // Accept
EVENT_TRACE_TYPE_RECONNECT  :: 0x10;     // ReConnect
EVENT_TRACE_TYPE_CONNFAIL   :: 0x11;     // Fail
EVENT_TRACE_TYPE_COPY_TCP   :: 0x12;     // Copy in PendData
EVENT_TRACE_TYPE_COPY_ARP   :: 0x13;     // NDIS_STATUS_RESOURCES Copy
EVENT_TRACE_TYPE_ACKFULL    :: 0x14;     // A full data ACK
EVENT_TRACE_TYPE_ACKPART    :: 0x15;     // A Partial data ACK
EVENT_TRACE_TYPE_ACKDUP     :: 0x16;     // A Duplicate data ACK


//
// Event Types for the Header (to handle internal event headers)
//

EVENT_TRACE_TYPE_GUIDMAP    :: 0x0A;
EVENT_TRACE_TYPE_CONFIG     :: 0x0B;
EVENT_TRACE_TYPE_SIDINFO    :: 0x0C;
EVENT_TRACE_TYPE_SECURITY   :: 0x0D;
EVENT_TRACE_TYPE_DBGID_RSDS :: 0x40;

//
// Event Types for Registry subsystem
//

EVENT_TRACE_TYPE_REGCREATE             :: 0x0A;     // NtCreateKey
EVENT_TRACE_TYPE_REGOPEN               :: 0x0B;     // NtOpenKey
EVENT_TRACE_TYPE_REGDELETE             :: 0x0C;     // NtDeleteKey
EVENT_TRACE_TYPE_REGQUERY              :: 0x0D;     // NtQueryKey
EVENT_TRACE_TYPE_REGSETVALUE           :: 0x0E;     // NtSetValueKey
EVENT_TRACE_TYPE_REGDELETEVALUE        :: 0x0F;     // NtDeleteValueKey
EVENT_TRACE_TYPE_REGQUERYVALUE         :: 0x10;     // NtQueryValueKey
EVENT_TRACE_TYPE_REGENUMERATEKEY       :: 0x11;     // NtEnumerateKey
EVENT_TRACE_TYPE_REGENUMERATEVALUEKEY  :: 0x12;     // NtEnumerateValueKey
EVENT_TRACE_TYPE_REGQUERYMULTIPLEVALUE :: 0x13;     // NtQueryMultipleValueKey
EVENT_TRACE_TYPE_REGSETINFORMATION     :: 0x14;     // NtSetInformationKey
EVENT_TRACE_TYPE_REGFLUSH              :: 0x15;     // NtFlushKey
EVENT_TRACE_TYPE_REGKCBCREATE          :: 0x16;     // KcbCreate
EVENT_TRACE_TYPE_REGKCBDELETE          :: 0x17;     // KcbDelete
EVENT_TRACE_TYPE_REGKCBRUNDOWNBEGIN    :: 0x18;     // KcbRundownBegin
EVENT_TRACE_TYPE_REGKCBRUNDOWNEND      :: 0x19;     // KcbRundownEnd
EVENT_TRACE_TYPE_REGVIRTUALIZE         :: 0x1A;     // VirtualizeKey
EVENT_TRACE_TYPE_REGCLOSE              :: 0x1B;     // NtClose (KeyObject)
EVENT_TRACE_TYPE_REGSETSECURITY        :: 0x1C;     // SetSecurityDescriptor (KeyObject)
EVENT_TRACE_TYPE_REGQUERYSECURITY      :: 0x1D;     // QuerySecurityDescriptor (KeyObject)
EVENT_TRACE_TYPE_REGCOMMIT             :: 0x1E;     // CmKtmNotification (TRANSACTION_NOTIFY_COMMIT)
EVENT_TRACE_TYPE_REGPREPARE            :: 0x1F;     // CmKtmNotification (TRANSACTION_NOTIFY_PREPARE)
EVENT_TRACE_TYPE_REGROLLBACK           :: 0x20;     // CmKtmNotification (TRANSACTION_NOTIFY_ROLLBACK)
EVENT_TRACE_TYPE_REGMOUNTHIVE          :: 0x21;     // NtLoadKey variations + system hives

//
// Event types for system configuration records
//
EVENT_TRACE_TYPE_CONFIG_CPU             :: 0x0A;     // CPU Configuration
EVENT_TRACE_TYPE_CONFIG_PHYSICALDISK    :: 0x0B;     // Physical Disk Configuration
EVENT_TRACE_TYPE_CONFIG_LOGICALDISK     :: 0x0C;     // Logical Disk Configuration
EVENT_TRACE_TYPE_CONFIG_NIC             :: 0x0D;     // NIC Configuration
EVENT_TRACE_TYPE_CONFIG_VIDEO           :: 0x0E;     // Video Adapter Configuration
EVENT_TRACE_TYPE_CONFIG_SERVICES        :: 0x0F;     // Active Services
EVENT_TRACE_TYPE_CONFIG_POWER           :: 0x10;     // ACPI Configuration
EVENT_TRACE_TYPE_CONFIG_NETINFO         :: 0x11;     // Networking Configuration
EVENT_TRACE_TYPE_CONFIG_OPTICALMEDIA    :: 0x12;     // Optical Media Configuration
EVENT_TRACE_TYPE_CONFIG_PHYSICALDISK_EX :: 0x13;     // Physical Disk Extended Configuration

EVENT_TRACE_TYPE_CONFIG_IRQ             :: 0x15;     // IRQ assigned to devices
EVENT_TRACE_TYPE_CONFIG_PNP             :: 0x16;     // PnP device info
EVENT_TRACE_TYPE_CONFIG_IDECHANNEL      :: 0x17;     // Primary/Secondary IDE channel Configuration
EVENT_TRACE_TYPE_CONFIG_NUMANODE        :: 0x18;     // Numa configuration
EVENT_TRACE_TYPE_CONFIG_PLATFORM        :: 0x19;     // Platform Configuration
EVENT_TRACE_TYPE_CONFIG_PROCESSORGROUP  :: 0x1A;     // Processor Group Configuration
EVENT_TRACE_TYPE_CONFIG_PROCESSORNUMBER :: 0x1B;     // ProcessorIndex -> ProcNumber mapping
EVENT_TRACE_TYPE_CONFIG_DPI             :: 0x1C;     // Display DPI Configuration
EVENT_TRACE_TYPE_CONFIG_CI_INFO         :: 0x1D;     // Display System Code Integrity Information
EVENT_TRACE_TYPE_CONFIG_MACHINEID       :: 0x1E;     // SQM Machine Id
EVENT_TRACE_TYPE_CONFIG_DEFRAG          :: 0x1F;     // Logical Disk Defragmenter Information
EVENT_TRACE_TYPE_CONFIG_MOBILEPLATFORM  :: 0x20;     // Mobile Platform Configuration
EVENT_TRACE_TYPE_CONFIG_DEVICEFAMILY    :: 0x21;     // Device Family Information
EVENT_TRACE_TYPE_CONFIG_FLIGHTID        :: 0x22;     // Flights on the machine
EVENT_TRACE_TYPE_CONFIG_PROCESSOR       :: 0x23;     // CentralProcessor records
EVENT_TRACE_TYPE_CONFIG_VIRTUALIZATION  :: 0x24;     // virtualization config info
EVENT_TRACE_TYPE_CONFIG_BOOT            :: 0x25;     // boot config info

//
// Event types for Optical IO subsystem
//

EVENT_TRACE_TYPE_OPTICAL_IO_READ       :: 0x37;
EVENT_TRACE_TYPE_OPTICAL_IO_WRITE      :: 0x38;
EVENT_TRACE_TYPE_OPTICAL_IO_FLUSH      :: 0x39;
EVENT_TRACE_TYPE_OPTICAL_IO_READ_INIT  :: 0x3a;
EVENT_TRACE_TYPE_OPTICAL_IO_WRITE_INIT :: 0x3b;
EVENT_TRACE_TYPE_OPTICAL_IO_FLUSH_INIT :: 0x3c;

//
// Event types for Filter Manager
//

EVENT_TRACE_TYPE_FLT_PREOP_INIT        :: 0x60;   // Minifilter preop initiation
EVENT_TRACE_TYPE_FLT_POSTOP_INIT       :: 0x61;   // Minifilter postop initiation
EVENT_TRACE_TYPE_FLT_PREOP_COMPLETION  :: 0x62;   // Minifilter preop completion
EVENT_TRACE_TYPE_FLT_POSTOP_COMPLETION :: 0x63;   // Minifilter postop completion
EVENT_TRACE_TYPE_FLT_PREOP_FAILURE     :: 0x64;   // Minifilter failed preop
EVENT_TRACE_TYPE_FLT_POSTOP_FAILURE    :: 0x65;   // Minifilter failed postop

//
// Enable flags for Kernel Events
//
EVENT_TRACE_FLAG_PROCESS            :: 0x00000001;  // process start & end
EVENT_TRACE_FLAG_THREAD             :: 0x00000002;  // thread start & end
EVENT_TRACE_FLAG_IMAGE_LOAD         :: 0x00000004;  // image load

EVENT_TRACE_FLAG_DISK_IO            :: 0x00000100;  // physical disk IO
EVENT_TRACE_FLAG_DISK_FILE_IO       :: 0x00000200;  // requires disk IO

EVENT_TRACE_FLAG_MEMORY_PAGE_FAULTS :: 0x00001000;  // all page faults
EVENT_TRACE_FLAG_MEMORY_HARD_FAULTS :: 0x00002000;  // hard faults only

EVENT_TRACE_FLAG_NETWORK_TCPIP      :: 0x00010000;  // tcpip send & receive

EVENT_TRACE_FLAG_REGISTRY           :: 0x00020000;  // registry calls
EVENT_TRACE_FLAG_DBGPRINT           :: 0x00040000;  // DbgPrint(ex) Calls

//
// Enable flags for Kernel Events on Vista and above
//
EVENT_TRACE_FLAG_PROCESS_COUNTERS :: 0x00000008;  // process perf counters
EVENT_TRACE_FLAG_CSWITCH          :: 0x00000010;  // context switches
EVENT_TRACE_FLAG_DPC              :: 0x00000020;  // deferred procedure calls
EVENT_TRACE_FLAG_INTERRUPT        :: 0x00000040;  // interrupts
EVENT_TRACE_FLAG_SYSTEMCALL       :: 0x00000080;  // system calls

EVENT_TRACE_FLAG_DISK_IO_INIT     :: 0x00000400;  // physical disk IO initiation
EVENT_TRACE_FLAG_ALPC             :: 0x00100000;  // ALPC traces
EVENT_TRACE_FLAG_SPLIT_IO         :: 0x00200000;  // split io traces (VolumeManager)

EVENT_TRACE_FLAG_DRIVER           :: 0x00800000;  // driver delays
EVENT_TRACE_FLAG_PROFILE          :: 0x01000000;  // sample based profiling
EVENT_TRACE_FLAG_FILE_IO          :: 0x02000000;  // file IO
EVENT_TRACE_FLAG_FILE_IO_INIT     :: 0x04000000;  // file IO initiation

//
// Enable flags for Kernel Events on Win7 and above
//
EVENT_TRACE_FLAG_DISPATCHER     :: 0x00000800;  // scheduler (ReadyThread)
EVENT_TRACE_FLAG_VIRTUAL_ALLOC  :: 0x00004000;  // VM operations

//
// Enable flags for Kernel Events on Win8 and above
//
EVENT_TRACE_FLAG_VAMAP          :: 0x00008000;  // map/unmap (excluding images)
EVENT_TRACE_FLAG_NO_SYSCONFIG   :: 0x10000000;  // Do not do sys config rundown

//
// Enable flags for Kernel Events on Threshold and above
//
EVENT_TRACE_FLAG_JOB            :: 0x00080000;  // job start & end
EVENT_TRACE_FLAG_DEBUG_EVENTS   :: 0x00400000;  // debugger events (break/continue/...)

//
// Pre-defined Enable flags for everybody else
//
EVENT_TRACE_FLAG_EXTENSION      :: 0x80000000;  // Indicates more flags
EVENT_TRACE_FLAG_FORWARD_WMI    :: 0x40000000;  // Can forward to WMI
EVENT_TRACE_FLAG_ENABLE_RESERVE :: 0x20000000;  // Reserved

Trace_Enable_Flags :: enum_flags u32 {
    // Kernel Events
    PROCESS            :: 0x00000001;  // process start & end
    THREAD             :: 0x00000002;  // thread start & end
    IMAGE_LOAD         :: 0x00000004;  // image load

    DISK_IO            :: 0x00000100;  // physical disk IO
    DISK_FILE_IO       :: 0x00000200;  // requires disk IO

    MEMORY_PAGE_FAULTS :: 0x00001000;  // all page faults
    MEMORY_HARD_FAULTS :: 0x00002000;  // hard faults only

    NETWORK_TCPIP      :: 0x00010000;  // tcpip send & receive

    REGISTRY           :: 0x00020000;  // registry calls
    DBGPRINT           :: 0x00040000;  // DbgPrint(ex) Calls

    // Kernel Events on Vista and above
    PROCESS_COUNTERS :: 0x00000008;  // process perf counters
    CSWITCH          :: 0x00000010;  // context switches
    DPC              :: 0x00000020;  // deferred procedure calls
    INTERRUPT        :: 0x00000040;  // interrupts
    SYSTEMCALL       :: 0x00000080;  // system calls

    DISK_IO_INIT     :: 0x00000400;  // physical disk IO initiation
    ALPC             :: 0x00100000;  // ALPC traces
    SPLIT_IO         :: 0x00200000;  // split io traces (VolumeManager)

    DRIVER           :: 0x00800000;  // driver delays
    PROFILE          :: 0x01000000;  // sample based profiling
    FILE_IO          :: 0x02000000;  // file IO
    FILE_IO_INIT     :: 0x04000000;  // file IO initiation

    // Kernel Events on Win7 and above
    DISPATCHER     :: 0x00000800;  // scheduler (ReadyThread)
    VIRTUAL_ALLOC  :: 0x00004000;  // VM operations

    // Kernel Events on Win8 and above
    VAMAP          :: 0x00008000;  // map/unmap (excluding images)
    NO_SYSCONFIG   :: 0x10000000;  // Do not do sys config rundown

    // Kernel Events on Threshold and above
    JOB            :: 0x00080000;  // job start & end
    DEBUG_EVENTS   :: 0x00400000;  // debugger events (break/continue/...)

    // Pre-defined flags for everybody else
    EXTENSION      :: 0x80000000;  // Indicates more flags
    FORWARD_WMI    :: 0x40000000;  // Can forward to WMI
    ENABLE_RESERVE :: 0x20000000;  // Reserved
}

//
// Logger Mode flags
//
EVENT_TRACE_FILE_MODE_NONE       :: 0x00000000;  // Logfile is off
EVENT_TRACE_FILE_MODE_SEQUENTIAL :: 0x00000001;  // Log sequentially
EVENT_TRACE_FILE_MODE_CIRCULAR   :: 0x00000002;  // Log in circular manner
EVENT_TRACE_FILE_MODE_APPEND     :: 0x00000004;  // Append sequential log

EVENT_TRACE_REAL_TIME_MODE       :: 0x00000100;  // Real time mode on
EVENT_TRACE_DELAY_OPEN_FILE_MODE :: 0x00000200;  // Delay opening file
EVENT_TRACE_BUFFERING_MODE       :: 0x00000400;  // Buffering mode only
EVENT_TRACE_PRIVATE_LOGGER_MODE  :: 0x00000800;  // Process Private Logger
EVENT_TRACE_ADD_HEADER_MODE      :: 0x00001000;  // Add a logfile header

EVENT_TRACE_USE_GLOBAL_SEQUENCE  :: 0x00004000;  // Use global sequence no.
EVENT_TRACE_USE_LOCAL_SEQUENCE   :: 0x00008000;  // Use local sequence no.

EVENT_TRACE_RELOG_MODE           :: 0x00010000;  // Relogger

EVENT_TRACE_USE_PAGED_MEMORY     :: 0x01000000;  // Use pageable buffers

//
// Logger Mode flags on XP and above
//

EVENT_TRACE_FILE_MODE_NEWFILE     :: 0x00000008;  // Auto-switch log file
EVENT_TRACE_FILE_MODE_PREALLOCATE :: 0x00000020;  // Pre-allocate mode

//
// Logger Mode flags on Vista and above
//

EVENT_TRACE_NONSTOPPABLE_MODE     :: 0x00000040;  // Session cannot be stopped (Autologger only)
EVENT_TRACE_SECURE_MODE           :: 0x00000080;  // Secure session
EVENT_TRACE_USE_KBYTES_FOR_SIZE   :: 0x00002000;  // Use KBytes as file size unit
EVENT_TRACE_PRIVATE_IN_PROC       :: 0x00020000;  // In process private logger

EVENT_TRACE_MODE_RESERVED         :: 0x00100000;  // Reserved bit, used to signal Heap/Critsec tracing

//
// Logger Mode flags on Win7 and above
//

EVENT_TRACE_NO_PER_PROCESSOR_BUFFERING :: 0x10000000;  // Use this for low frequency sessions.

//
// Logger Mode flags on Win8 and above
//

EVENT_TRACE_SYSTEM_LOGGER_MODE         :: 0x02000000;  // Receive events from SystemTraceProvider
EVENT_TRACE_ADDTO_TRIAGE_DUMP          :: 0x80000000;  // Add ETW buffers to triage dumps
EVENT_TRACE_STOP_ON_HYBRID_SHUTDOWN    :: 0x00400000;  // Stop on hybrid shutdown
EVENT_TRACE_PERSIST_ON_HYBRID_SHUTDOWN :: 0x00800000; // Persist on hybrid shutdown

//
// Logger Mode flags on Blue and above
//

EVENT_TRACE_INDEPENDENT_SESSION_MODE :: 0x08000000;  // Independent logger session

//
// Logger Mode flags on Redstone and above
//

EVENT_TRACE_COMPRESSED_MODE :: 0x04000000; // Compressed logger session.

//
// ControlTrace Codes
//

EVENT_TRACE_CONTROL_QUERY  :: 0;
EVENT_TRACE_CONTROL_STOP   :: 1;
EVENT_TRACE_CONTROL_UPDATE :: 2;

//
// Flush ControlTrace Codes for XP and above
//

EVENT_TRACE_CONTROL_FLUSH :: 3;       // Flushes all the buffers

//
// Supported for RS5 and above.
//

EVENT_TRACE_CONTROL_INCREMENT_FILE :: 4; // Causes a session with EVENT_TRACE_FILE_MODE_NEWFILE
                                         // to switch to the next file before the automatic
                                         // switching criteria is met

//
// Supported for Manganese and above.
//

EVENT_TRACE_CONTROL_CONVERT_TO_REALTIME :: 5;  // Transitions from file mode tracing to real-time.

//
// Flags used by WMI Trace Message
// Note that the order or value of these flags should NOT be changed as they are processed
// in this order.
//

TRACE_MESSAGE_SEQUENCE              :: 1;  // Message should include a sequence number
TRACE_MESSAGE_GUID                  :: 2;  // Message includes a GUID
TRACE_MESSAGE_COMPONENTID           :: 4;  // Message has no GUID, Component ID instead
TRACE_MESSAGE_TIMESTAMP             :: 8;  // Message includes a timestamp
TRACE_MESSAGE_PERFORMANCE_TIMESTAMP :: 16; // *Obsolete* Clock type is controlled by the logger
TRACE_MESSAGE_SYSTEMINFO            :: 32; // Message includes system information TID,PID

//
// Vista flags set by system to indicate provider pointer size.
//

TRACE_MESSAGE_POINTER32 :: 0x0040;   // Message logged by 32 bit provider
TRACE_MESSAGE_POINTER64 :: 0x0080;   // Message logged by 64 bit provider

TRACE_MESSAGE_FLAG_MASK :: 0xFFFF;   // Only the lower 16 bits of flags are placed in the message
                                     // those above 16 bits are reserved for local processing
//
// Maximum size allowed for a single TraceMessage message.
//
// N.B. This limit was increased from 8K to 64K in Win8.
//

TRACE_MESSAGE_MAXIMUM_SIZE :: (64 * 1024);

//
// Flags to indicate to consumer which fields
// in the EVENT_TRACE_HEADER are valid
//

EVENT_TRACE_USE_PROCTIME  :: 0x0001;    // ProcessorTime field is valid
EVENT_TRACE_USE_NOCPUTIME :: 0x0002;    // No Kernel/User/Processor Times

// TRACE_HEADER_FLAG values are used in the Flags field of EVENT_TRACE_HEADER structure while calling into TraceEvent API
TRACE_HEADER_FLAG :: enum_flags u32 {
    USE_TIMESTAMP :: 0x00000200;
    TRACED_GUID   :: 0x00020000; // denotes a trace
    LOG_WNODE     :: 0x00040000; // request to log Wnode
    USE_GUID_PTR  :: 0x00080000; // Guid is actually a pointer
    USE_MOF_PTR   :: 0x00100000; // MOF data are dereferenced
}

//
// Keywords to be used for the System ALPC Provider.
//

SYSTEM_ALPC_KW_GENERAL :: 0x0000000000000001;

//
// Keywords to be used for the System Config Provider.
//

SYSTEM_CONFIG_KW_SYSTEM   :: 0x0000000000000001;
SYSTEM_CONFIG_KW_GRAPHICS :: 0x0000000000000002;
SYSTEM_CONFIG_KW_STORAGE  :: 0x0000000000000004;
SYSTEM_CONFIG_KW_NETWORK  :: 0x0000000000000008;
SYSTEM_CONFIG_KW_SERVICES :: 0x0000000000000010;
SYSTEM_CONFIG_KW_PNP      :: 0x0000000000000020;
SYSTEM_CONFIG_KW_OPTICAL  :: 0x0000000000000040;

//
// Keywords to be used for the System CPU Provider.
//

SYSTEM_CPU_KW_CONFIG       :: 0x0000000000000001;
SYSTEM_CPU_KW_CACHE_FLUSH  :: 0x0000000000000002;
SYSTEM_CPU_KW_SPEC_CONTROL :: 0x0000000000000004;

//
// Keywords to be used for the System Hypervisor Provider.
//

SYSTEM_HYPERVISOR_KW_PROFILE    :: 0x0000000000000001;
SYSTEM_HYPERVISOR_KW_CALLOUTS   :: 0x0000000000000002;
SYSTEM_HYPERVISOR_KW_VTL_CHANGE :: 0x0000000000000004;

//
// Keywords to be used for the System Interrupt Provider.
//

SYSTEM_INTERRUPT_KW_GENERAL         :: 0x0000000000000001;
SYSTEM_INTERRUPT_KW_CLOCK_INTERRUPT :: 0x0000000000000002;
SYSTEM_INTERRUPT_KW_DPC             :: 0x0000000000000004;
SYSTEM_INTERRUPT_KW_DPC_QUEUE       :: 0x0000000000000008;
SYSTEM_INTERRUPT_KW_WDF_DPC         :: 0x0000000000000010;
SYSTEM_INTERRUPT_KW_WDF_INTERRUPT   :: 0x0000000000000020;
SYSTEM_INTERRUPT_KW_IPI             :: 0x0000000000000040;

//
// Keywords to be used for the System IO Provider.
//

SYSTEM_IO_KW_DISK         :: 0x0000000000000001;
SYSTEM_IO_KW_DISK_INIT    :: 0x0000000000000002;
SYSTEM_IO_KW_FILENAME     :: 0x0000000000000004;
SYSTEM_IO_KW_SPLIT        :: 0x0000000000000008;
SYSTEM_IO_KW_FILE         :: 0x0000000000000010;
SYSTEM_IO_KW_OPTICAL      :: 0x0000000000000020;
SYSTEM_IO_KW_OPTICAL_INIT :: 0x0000000000000040;
SYSTEM_IO_KW_DRIVERS      :: 0x0000000000000080;
SYSTEM_IO_KW_CC           :: 0x0000000000000100;
SYSTEM_IO_KW_NETWORK      :: 0x0000000000000200;

//
// Keywords to be used for the System IoFilter Provider.
//

SYSTEM_IOFILTER_KW_GENERAL :: 0x0000000000000001;
SYSTEM_IOFILTER_KW_INIT    :: 0x0000000000000002;
SYSTEM_IOFILTER_KW_FASTIO  :: 0x0000000000000004;
SYSTEM_IOFILTER_KW_FAILURE :: 0x0000000000000008;

//
// Keywords to be used for the System SpinLock Provider.
//

SYSTEM_LOCK_KW_SPINLOCK          :: 0x0000000000000001;
SYSTEM_LOCK_KW_SPINLOCK_COUNTERS :: 0x0000000000000002;
SYSTEM_LOCK_KW_SYNC_OBJECTS      :: 0x0000000000000004;

//
// Keywords to be used for the System Memory Provider.
//

SYSTEM_MEMORY_KW_GENERAL       :: 0x0000000000000001;
SYSTEM_MEMORY_KW_HARD_FAULTS   :: 0x0000000000000002;
SYSTEM_MEMORY_KW_ALL_FAULTS    :: 0x0000000000000004;
SYSTEM_MEMORY_KW_POOL          :: 0x0000000000000008;
SYSTEM_MEMORY_KW_MEMINFO       :: 0x0000000000000010;
SYSTEM_MEMORY_KW_PFSECTION     :: 0x0000000000000020;
SYSTEM_MEMORY_KW_MEMINFO_WS    :: 0x0000000000000040;
SYSTEM_MEMORY_KW_HEAP          :: 0x0000000000000080;
SYSTEM_MEMORY_KW_WS            :: 0x0000000000000100;
SYSTEM_MEMORY_KW_CONTMEM_GEN   :: 0x0000000000000200;
SYSTEM_MEMORY_KW_VIRTUAL_ALLOC :: 0x0000000000000400;
SYSTEM_MEMORY_KW_FOOTPRINT     :: 0x0000000000000800;
SYSTEM_MEMORY_KW_SESSION       :: 0x0000000000001000;
SYSTEM_MEMORY_KW_REFSET        :: 0x0000000000002000;
SYSTEM_MEMORY_KW_VAMAP         :: 0x0000000000004000;
SYSTEM_MEMORY_KW_NONTRADEABLE  :: 0x0000000000008000;

//
// Keywords to be used for the System Object Provider.
//

SYSTEM_OBJECT_KW_GENERAL :: 0x0000000000000001;
SYSTEM_OBJECT_KW_HANDLE  :: 0x0000000000000002;

//
// Keywords to be used for the System Power Provider.
//

SYSTEM_POWER_KW_GENERAL          :: 0x0000000000000001;
SYSTEM_POWER_KW_HIBER_RUNDOWN    :: 0x0000000000000002;
SYSTEM_POWER_KW_PROCESSOR_IDLE   :: 0x0000000000000004;
SYSTEM_POWER_KW_IDLE_SELECTION   :: 0x0000000000000008;
SYSTEM_POWER_KW_PPM_EXIT_LATENCY :: 0x0000000000000010;

//
// Keywords to be used for the System Process Provider.
//

SYSTEM_PROCESS_KW_GENERAL       :: 0x0000000000000001;
SYSTEM_PROCESS_KW_INSWAP        :: 0x0000000000000002;
SYSTEM_PROCESS_KW_FREEZE        :: 0x0000000000000004;
SYSTEM_PROCESS_KW_PERF_COUNTER  :: 0x0000000000000008;
SYSTEM_PROCESS_KW_WAKE_COUNTER  :: 0x0000000000000010;
SYSTEM_PROCESS_KW_WAKE_DROP     :: 0x0000000000000020;
SYSTEM_PROCESS_KW_WAKE_EVENT    :: 0x0000000000000040;
SYSTEM_PROCESS_KW_DEBUG_EVENTS  :: 0x0000000000000080;
SYSTEM_PROCESS_KW_DBGPRINT      :: 0x0000000000000100;
SYSTEM_PROCESS_KW_JOB           :: 0x0000000000000200;
SYSTEM_PROCESS_KW_WORKER_THREAD :: 0x0000000000000400;
SYSTEM_PROCESS_KW_THREAD        :: 0x0000000000000800;
SYSTEM_PROCESS_KW_LOADER        :: 0x0000000000001000;

//
// Keywords to be used for the System Profile Provider.
//

SYSTEM_PROFILE_KW_GENERAL     :: 0x0000000000000001;
SYSTEM_PROFILE_KW_PMC_PROFILE :: 0x0000000000000002;

//
// Keywords to be used for the System Registry Provider.
//

SYSTEM_REGISTRY_KW_GENERAL      :: 0x0000000000000001;
SYSTEM_REGISTRY_KW_HIVE         :: 0x0000000000000002;
SYSTEM_REGISTRY_KW_NOTIFICATION :: 0x0000000000000004;

//
// Keywords to be used for the System Scheduler Provider.
//

SYSTEM_SCHEDULER_KW_XSCHEDULER      :: 0x0000000000000001;
SYSTEM_SCHEDULER_KW_DISPATCHER      :: 0x0000000000000002;
SYSTEM_SCHEDULER_KW_KERNEL_QUEUE    :: 0x0000000000000004;
SYSTEM_SCHEDULER_KW_SHOULD_YIELD    :: 0x0000000000000008;
SYSTEM_SCHEDULER_KW_ANTI_STARVATION :: 0x0000000000000010;
SYSTEM_SCHEDULER_KW_LOAD_BALANCER   :: 0x0000000000000020;
SYSTEM_SCHEDULER_KW_AFFINITY        :: 0x0000000000000040;
SYSTEM_SCHEDULER_KW_PRIORITY        :: 0x0000000000000080;
SYSTEM_SCHEDULER_KW_IDEAL_PROCESSOR :: 0x0000000000000100;
SYSTEM_SCHEDULER_KW_CONTEXT_SWITCH  :: 0x0000000000000200;
SYSTEM_SCHEDULER_KW_COMPACT_CSWITCH :: 0x0000000000000400;

//
// Keywords to be used for the System Syscall Provider.
//

SYSTEM_SYSCALL_KW_GENERAL :: 0x0000000000000001;

//
// Keywords to be used for the System Timer Provider.
//

SYSTEM_TIMER_KW_GENERAL     :: 0x0000000000000001;
SYSTEM_TIMER_KW_CLOCK_TIMER :: 0x0000000000000002;

//
// Schematized Filter ID for the Pool Tag Filter on the System Memory Provider.
//

SYSTEM_MEMORY_POOL_FILTER_ID :: 1;


// typedef enum {
//     EtwCompressionModeRestart = 0,
//     EtwCompressionModeNoDisable = 1,
//     EtwCompressionModeNoRestart = 2
// } ETW_COMPRESSION_RESUMPTION_MODE;

//
// Trace header for all legacy events.
//

EVENT_TRACE_HEADER :: struct {       // overlays WNODE_HEADER
    Size: u16;                       // Size of entire record
    union {
        FieldTypeFlags: u16;         // Indicates valid fields
        struct {
            HeaderType: u8;          // Header type - internal use only
            MarkerFlags: u8;         // Marker - internal use only
        }
    }
    union {
        Version: u32;
        Class: struct {
            Type: u8;                 // event type
            Level: u8;                // trace instrumentation level
            Version: u16;             // version of trace record
        }
    }
    ThreadId: u32;                    // Thread Id
    ProcessId: u32;                   // Process Id
    TimeStamp: LARGE_INTEGER;         // time when event happens
    union {
        Guid: GUID;                   // Guid that identifies event
        GuidPtr: u64;           // use with WNODE_FLAG_USE_GUID_PTR
    }
    union {
        struct {
            KernelTime: u32;          // Kernel Mode CPU ticks
            UserTime: u32;            // User mode CPU ticks
        }
        ProcessorTime: u64;           // Processor Clock
        struct {
            ClientContext: u32;       // Reserved
            Flags: TRACE_HEADER_FLAG; // Event Flags
        }
    }
}

//
// This header is used to trace and track transaction co-relations
//
EVENT_INSTANCE_HEADER :: struct {
    Size: u16;
    union {
        FieldTypeFlags: u16;     // Indicates valid fields
        struct {
            HeaderType: u8;         // Header type - internal use only
            MarkerFlags: u8;        // Marker - internal use only
        }
    }
    union {
        Version: u32;
        Class: struct {
            Type: u8;
            Level: u8;
            Version: u16;
        }
    }
    ThreadId: u32;
    ProcessId: u32;
    TimeStamp: LARGE_INTEGER;
    RegHandle: u64;
    InstanceId: u32;
    ParentInstanceId: u32;
    union {
        struct {
            KernelTime: u32;             // Kernel Mode CPU ticks
            UserTime: u32;               // User mode CPU ticks
        }
        ProcessorTime: u64;          // Processor Clock
        struct {
            EventId: u32;                // Event ID
            Flags: u32;                  // Trace header Flags
        }
    }
    ParentRegHandle: u64;
}

//
// Following are structures and macros for use with USE_MOF_PTR
//

// Trace data types
ETW_NULL_TYPE_VALUE                        :: 0;
ETW_OBJECT_TYPE_VALUE                      :: 1;
ETW_STRING_TYPE_VALUE                      :: 2;
ETW_SBYTE_TYPE_VALUE                       :: 3;
ETW_BYTE_TYPE_VALUE                        :: 4;
ETW_INT16_TYPE_VALUE                       :: 5;
ETW_UINT16_TYPE_VALUE                      :: 6;
ETW_INT32_TYPE_VALUE                       :: 7;
ETW_UINT32_TYPE_VALUE                      :: 8;
ETW_INT64_TYPE_VALUE                       :: 9;
ETW_UINT64_TYPE_VALUE                      :: 10;
ETW_CHAR_TYPE_VALUE                        :: 11;
ETW_SINGLE_TYPE_VALUE                      :: 12;
ETW_DOUBLE_TYPE_VALUE                      :: 13;
ETW_BOOLEAN_TYPE_VALUE                     :: 14;
ETW_DECIMAL_TYPE_VALUE                     :: 15;
// Extended types
ETW_GUID_TYPE_VALUE                        :: 101;
ETW_ASCIICHAR_TYPE_VALUE                   :: 102;
ETW_ASCIISTRING_TYPE_VALUE                 :: 103;
ETW_COUNTED_STRING_TYPE_VALUE              :: 104;
ETW_POINTER_TYPE_VALUE                     :: 105;
ETW_SIZET_TYPE_VALUE                       :: 106;
ETW_HIDDEN_TYPE_VALUE                      :: 107;
ETW_BOOL_TYPE_VALUE                        :: 108;
ETW_COUNTED_ANSISTRING_TYPE_VALUE          :: 109;
ETW_REVERSED_COUNTED_STRING_TYPE_VALUE     :: 110;
ETW_REVERSED_COUNTED_ANSISTRING_TYPE_VALUE :: 111;
ETW_NON_NULL_TERMINATED_STRING_TYPE_VALUE  :: 112;
ETW_REDUCED_ANSISTRING_TYPE_VALUE          :: 113;
ETW_REDUCED_STRING_TYPE_VALUE              :: 114;
ETW_SID_TYPE_VALUE                         :: 115;
ETW_VARIANT_TYPE_VALUE                     :: 116;
ETW_PTVECTOR_TYPE_VALUE                    :: 117;
ETW_WMITIME_TYPE_VALUE                     :: 118;
ETW_DATETIME_TYPE_VALUE                    :: 119;
ETW_REFRENCE_TYPE_VALUE                    :: 120;


// #define DEFINE_TRACE_MOF_FIELD(MOF, ptr, length, type) \
//     (MOF)->DataPtr  = (u64)(ULONG_PTR) ptr; \
//     (MOF)->Length   = (u32) length; \
//     (MOF)->DataType = (u32) type;

MOF_FIELD :: struct {
    DataPtr: u64;    // Pointer to the field. Up to 64-bits only
    Length: u32;     // Length of the MOF field
    DataType: u32;   // Type of data
}

// #if !defined(_EVNTRACE_KERNEL_MODE) || defined(_WMIKM_)

//
// This is the header for every logfile. The memory for LoggerName
// and LogFileName must be contiguous adjacent to this structure
// Allows both user-mode and kernel-mode to understand the header.
//
// TRACE_LOGFILE_HEADER32 and TRACE_LOGFILE_HEADER64 structures
// are also provided to simplify cross platform decoding of the
// header event.
//

TRACE_LOGFILE_HEADER :: struct {
    BufferSize: u32;         // Logger buffer size in Kbytes
    union {
        Version: u32;            // Logger version
        VersionDetail: struct {
            MajorVersion: u8;
            MinorVersion: u8;
            SubVersion: u8;
            SubMinorVersion: u8;
        }
    }
    ProviderVersion: u32;    // defaults to NT version
    NumberOfProcessors: u32; // Number of Processors
    EndTime: LARGE_INTEGER;  // Time when logger stops
    TimerResolution: u32;    // assumes timer is constant!!!
    MaximumFileSize: u32;    // Maximum in Mbytes
    LogFileMode: u32;        // specify logfile mode
    BuffersWritten: u32;     // used to file start of Circular File
    union {
        LogInstanceGuid: GUID;           // For RealTime Buffer Delivery
        struct {
            StartBuffers: u32;       // Count of buffers written at start.
            PointerSize: u32;        // Size of pointer type in bits
            EventsLost: u32;         // Events lost during log session
            CpuSpeedInMHz: u32;      // Cpu Speed in MHz
        }
    }
// #if defined(_WMIKM_)
//     PWCHAR          LoggerName;
//     PWCHAR          LogFileName;
//     RTL_TIME_ZONE_INFORMATION TimeZone;
// #else
    LoggerName: *u16;
    LogFileName: *u16;
    TimeZone: TIME_ZONE_INFORMATION;
// #endif
    BootTime: LARGE_INTEGER;
    PerfFreq: LARGE_INTEGER;           // Reserved
    StartTime: LARGE_INTEGER;          // Reserved
    ReservedFlags: u32;      // ClockType
    BuffersLost: u32;
}

/*
TRACE_LOGFILE_HEADER32 :: struct {
    u32           BufferSize;         // Logger buffer size in Kbytes
    union {
        u32       Version;            // Logger version
        struct {
            u8   MajorVersion;
            u8   MinorVersion;
            u8   SubVersion;
            u8   SubMinorVersion;
        } VersionDetail;
    };
    u32           ProviderVersion;    // defaults to NT version
    u32           NumberOfProcessors; // Number of Processors
    LARGE_INTEGER   EndTime;            // Time when logger stops
    u32           TimerResolution;    // assumes timer is constant!!!
    u32           MaximumFileSize;    // Maximum in Mbytes
    u32           LogFileMode;        // specify logfile mode
    u32           BuffersWritten;     // used to file start of Circular File
    union {
        GUID LogInstanceGuid;           // For RealTime Buffer Delivery
        struct {
            u32   StartBuffers;       // Count of buffers written at start.
            u32   PointerSize;        // Size of pointer type in bits
            u32   EventsLost;         // Events lost during log session
            u32   CpuSpeedInMHz;      // Cpu Speed in MHz
        };
    };
#if defined(_WMIKM_)
    ULONG32         LoggerName;
    ULONG32         LogFileName;
    RTL_TIME_ZONE_INFORMATION TimeZone;
#else
    ULONG32         LoggerName;
    ULONG32         LogFileName;
    TIME_ZONE_INFORMATION TimeZone;
#endif
    LARGE_INTEGER   BootTime;
    LARGE_INTEGER   PerfFreq;           // Reserved
    LARGE_INTEGER   StartTime;          // Reserved
    u32           ReservedFlags;      // ClockType
    u32           BuffersLost;
}

typedef struct _TRACE_LOGFILE_HEADER64 {
    u32           BufferSize;         // Logger buffer size in Kbytes
    union {
        u32       Version;            // Logger version
        struct {
            u8   MajorVersion;
            u8   MinorVersion;
            u8   SubVersion;
            u8   SubMinorVersion;
        } VersionDetail;
    };
    u32           ProviderVersion;    // defaults to NT version
    u32           NumberOfProcessors; // Number of Processors
    LARGE_INTEGER   EndTime;            // Time when logger stops
    u32           TimerResolution;    // assumes timer is constant!!!
    u32           MaximumFileSize;    // Maximum in Mbytes
    u32           LogFileMode;        // specify logfile mode
    u32           BuffersWritten;     // used to file start of Circular File
    union {
        GUID LogInstanceGuid;           // For RealTime Buffer Delivery
        struct {
            u32   StartBuffers;       // Count of buffers written at start.
            u32   PointerSize;        // Size of pointer type in bits
            u32   EventsLost;         // Events lost during log session
            u32   CpuSpeedInMHz;      // Cpu Speed in MHz
        };
    };
#if defined(_WMIKM_)
    u64         LoggerName;
    u64         LogFileName;
    RTL_TIME_ZONE_INFORMATION TimeZone;
#else
    u64         LoggerName;
    u64         LogFileName;
    TIME_ZONE_INFORMATION TimeZone;
#endif
    LARGE_INTEGER   BootTime;
    LARGE_INTEGER   PerfFreq;           // Reserved
    LARGE_INTEGER   StartTime;          // Reserved
    u32           ReservedFlags;      // ClockType
    u32           BuffersLost;
} TRACE_LOGFILE_HEADER64, *PTRACE_LOGFILE_HEADER64;
*/

// #endif // !_EVNTRACE_KERNEL_MODE || _WMIKM_

//
// Instance Information to track parent child relationship of Instances.
//

EVENT_INSTANCE_INFO :: struct {
    RegHandle: HANDLE;
    InstanceId: u32;
}

// #if !defined(_EVNTRACE_KERNEL_MODE)

//
// Structures that have UNICODE and ANSI versions are defined here
//

//
// Logger configuration and running statistics. This structure is used
// by user-mode callers, such as PDH library
//

EVENT_TRACE_PROPERTIES :: struct {
    Wnode: WNODE_HEADER;

    // data provided by caller
    BufferSize: u32;                   // buffer size for logging (kbytes)
    MinimumBuffers: u32;               // minimum to preallocate
    MaximumBuffers: u32;               // maximum buffers allowed
    MaximumFileSize: u32;              // maximum logfile size (in MBytes)
    LogFileMode: u32;                  // sequential, circular
    FlushTimer: u32;                   // buffer flush timer, in seconds
    EnableFlags: Trace_Enable_Flags;   // trace enable flags
    union {
        AgeLimit: s32;                 // unused
        FlushThreshold: s32;           // Number of buffers to fill before flushing
    }

    // data returned to caller
    NumberOfBuffers: u32;              // no of buffers in use
    FreeBuffers: u32;                  // no of buffers free
    EventsLost: u32;                   // event records lost
    BuffersWritten: u32;               // no of buffers written to file
    LogBuffersLost: u32;               // no of logfile write failures
    RealTimeBuffersLost: u32;          // no of rt delivery failures
    LoggerThreadId: HANDLE;              // thread id of Logger
    LogFileNameOffset: u32;            // Offset to LogFileName
    LoggerNameOffset: u32;             // Offset to LoggerName
}

EVENT_TRACE_PROPERTIES_V2 :: struct {
    Wnode: WNODE_HEADER;                  // Always have WNODE_FLAG_VERSIONED_PROPERTIES.

    // data provided by caller
    BufferSize: u32;                    // buffer size for logging (kbytes)
    MinimumBuffers: u32;                // minimum to preallocate
    MaximumBuffers: u32;                // maximum buffers allowed
    MaximumFileSize: u32;               // maximum logfile size (in MBytes)
    LogFileMode: u32;                   // sequential, circular
    FlushTimer: u32;                    // buffer flush timer, in seconds
    EnableFlags: Trace_Enable_Flags;    // trace enable flags
    union {
        AgeLimit: s32;                  // unused
        FlushThreshold: s32;            // Number of buffers to fill before flushing
    }

    // data returned to caller
    NumberOfBuffers: u32;               // no of buffers in use
    FreeBuffers: u32;                   // no of buffers free
    EventsLost: u32;                    // event records lost
    BuffersWritten: u32;                // no of buffers written to file
    LogBuffersLost: u32;                // no of logfile write failures
    RealTimeBuffersLost: u32;           // no of rt delivery failures
    LoggerThreadId: HANDLE;               // thread id of Logger
    LogFileNameOffset: u32;             // Offset to LogFileName
    LoggerNameOffset: u32;              // Offset to LoggerName

    // V2 data
    /*
    union {
        struct {
            // u32 VersionNumber : 8;     // Should be set to 2 for this version.
            __pad: [3] u8;
        }
        V2Control: u32;
    }
    */
    VersionNumber: u32 = 2; // NOTE(Charles): Set the default, and get rid seemingly pointless union/struct stuff above.

    FilterDescCount: u32;               // Number of filters
    FilterDesc: *EVENT_FILTER_DESCRIPTOR; // Only applicable for Private Loggers
    union {
        struct {
            // u32 Wow : 1; // Logger was started by a WOW64 process (output only).
            // u32 QpcDeltaTracking : 1; // QPC delta tracking events are enabled.
            // u32 LargeMdlPages : 1; // Buffers allocated via large MDL pages.
            // u32 ExcludeKernelStack : 1; // Exclude kernel stack from stack walk.
            __BitField: u32;
        }
        V2Options: u64;
    }
}

//
// Data Provider structures
//
// Used by RegisterTraceGuids()
//
TRACE_GUID_REGISTRATION :: struct {
    Guid: *GUID;              // Guid of data block being registered or updated.
    RegHandle: HANDLE;        // Guid Registration Handle is returned.
}

//
// Data consumer structures
//

// #endif // !_EVNTRACE_KERNEL_MODE

TRACE_GUID_PROPERTIES :: struct {
    Guid: GUID;
    GuidType: u32;
    LoggerId: u32;
    EnableLevel: u32;
    EnableFlags: u32;
    IsEnable: BOOLEAN;
}

ETW_BUFFER_CONTEXT :: struct {
    union {
        struct {
            ProcessorNumber: u8;
            Alignment: u8;
        }
        ProcessorIndex: u16;
    }
    LoggerId: u16;
}

//
// Provider Information Flags used on Vista and above.
//
TRACE_PROVIDER_FLAG_LEGACY     :: 0x00000001;
TRACE_PROVIDER_FLAG_PRE_ENABLE :: 0x00000002;

//
// Enable Information for Provider Instance
// Used on Vista and above
//
TRACE_ENABLE_INFO :: struct {

    IsEnabled: u32;
    Level: u8;
    Reserved1: u8;
    LoggerId: u16;
    EnableProperty: u32;
    Reserved2: u32;
    MatchAnyKeyword: u64;
    MatchAllKeyword: u64;
}

//
// Instance Information for Provider
// Used on Vista and above
//
TRACE_PROVIDER_INSTANCE_INFO :: struct {
    NextOffset: u32;
    EnableCount: u32;
    Pid: u32;
    Flags: u32;
}

//
// GUID Information Used on Vista and above
//
TRACE_GUID_INFO :: struct {
    InstanceCount: u32;
    Reserved: u32;
}

PROFILE_SOURCE_INFO :: struct {
    NextEntryOffset: u32;
    Source: u32;
    MinInterval: u32;
    MaxInterval: u32;
    Reserved: u64;
    Description: [ANYSIZE_ARRAY] u16;
}

ETW_PMC_COUNTER_OWNER_TYPE :: enum {
    Free;
    Untagged;
    Tagged;
    TaggedWithSource;
}

ETW_PMC_COUNTER_OWNER :: struct {
    OwnerType: ETW_PMC_COUNTER_OWNER_TYPE;
    ProfileSource: u32;
    OwnerTag: u32;
}

ETW_PMC_COUNTER_OWNERSHIP_STATUS :: struct {
    ProcessorNumber: u32;
    NumberOfCounters: u32;
    CounterOwners: [ANYSIZE_ARRAY] ETW_PMC_COUNTER_OWNER;
}

ETW_PMC_SESSION_INFO :: struct {
    NextEntryOffset: u32;
    LoggerId: u16;
    Reserved: u16;
    ProfileSourceCount: u32;
    HookIdCount: u32;

    // These two fields follow as a u32 blob after the initial header.
    // u32 ProfileSources[]; // Count indicated by ProfileSourceCount
    // u16 HookIds[]; // Count indicated by HookIdCount
}

//
// An EVENT_TRACE consists of a fixed header (EVENT_TRACE_HEADER) and
// optionally a variable portion pointed to by MofData. The datablock
// layout of the variable portion is unknown to the Logger and must
// be obtained from WBEM CIMOM database.
//

EVENT_TRACE :: struct {
    Header: EVENT_TRACE_HEADER;             // Event trace header
    InstanceId: u32;         // Instance Id of this event
    ParentInstanceId: u32;   // Parent Instance Id.
    ParentGuid: GUID;         // Parent Guid;
    MofData: *void;            // Pointer to Variable Data
    MofLength: u32;          // Variable Datablock Length
    union {
        ClientContext: u32;
        BufferContext: ETW_BUFFER_CONTEXT;
    }
}

EVENT_CONTROL_CODE_DISABLE_PROVIDER :: 0;
EVENT_CONTROL_CODE_ENABLE_PROVIDER  :: 1;
EVENT_CONTROL_CODE_CAPTURE_STATE    :: 2;

// #endif /* WINAPI_FAMILY_PARTITION(WINAPI_PARTITION_APP | WINAPI_PARTITION_SYSTEM | WINAPI_PARTITION_GAMES) */

// #if !defined(_EVNTRACE_KERNEL_MODE)

// #if WINAPI_FAMILY_PARTITION(WINAPI_PARTITION_APP | WINAPI_PARTITION_SYSTEM | WINAPI_PARTITION_GAMES)

PEVENT_TRACE_BUFFER_CALLBACKW :: #type (Logfile: *EVENT_TRACE_LOGFILEW) -> u32 #c_call;
PEVENT_TRACE_BUFFER_CALLBACKA :: #type (Logfile: *EVENT_TRACE_LOGFILEA) -> u32 #c_call;

PEVENT_CALLBACK :: #type (pEvent: *EVENT_TRACE) #c_call;
PEVENT_RECORD_CALLBACK :: #type (EventRecord: *EVENT_RECORD) #c_call;

ETW_BUFFER_HEADER :: struct {
    Reserved1: [4] u32;
    TimeStamp: LARGE_INTEGER; // Time of flush
    Reserved2: [4] u32;
    ClientContext: ETW_BUFFER_CONTEXT;
    Reserved3: u32;
    FilledBytes: u32; // Number of bytes written to the buffer.  Essentially the filled length of the buffer.
    Reserved4: [5] u32;
}

// Structure passed to the BufferCallback containing information on the
// current state of the processing session.
ETW_BUFFER_CALLBACK_INFORMATION :: struct {
    TraceHandle: TRACEHANDLE;
    LogfileHeader: *TRACE_LOGFILE_HEADER;
    BuffersRead: u32;
}

PETW_BUFFER_CALLBACK :: #type (Buffer: *ETW_BUFFER_HEADER, BufferSize: u32, ConsumerInfo: *ETW_BUFFER_CALLBACK_INFORMATION, CallbackContext: *void) -> BOOL #c_call;

ETW_PROCESS_TRACE_MODES :: enum {
    NONE :: 0;
    RAW_TIMESTAMP :: 0x00000001;
}

// Configuration options to pass into OpenTrace style functions.
ETW_OPEN_TRACE_OPTIONS :: struct {
    ProcessTraceModes: ETW_PROCESS_TRACE_MODES;

    // This callback will be called for each event in time order.
    // If left NULL, all event playback code will be bypassed.
    EventCallback: PEVENT_RECORD_CALLBACK;
    EventCallbackContext: *void;

    // This callback will get called once buffer processing is complete.
    BufferCallback: PETW_BUFFER_CALLBACK;
    BufferCallbackContext: *void;
}

PETW_BUFFER_COMPLETION_CALLBACK :: #type (Buffer: *ETW_BUFFER_HEADER, CallbackContext: *void) #c_call;

// #endif /* WINAPI_FAMILY_PARTITION(WINAPI_PARTITION_APP | WINAPI_PARTITION_SYSTEM | WINAPI_PARTITION_GAMES) */

// #if WINAPI_FAMILY_PARTITION(WINAPI_PARTITION_APP | WINAPI_PARTITION_SYSTEM | WINAPI_PARTITION_GAMES)

//
// Prototype for service request callback. Data providers register with WMI
// by passing a service request callback function that is called for all
// wmi requests.

WMIDPREQUEST :: #type (RequestCode: WMIDPREQUESTCODE, RequestContext: *void, BufferSize: *u32, Buffer: *void) -> u32 #c_call;

// #endif /* WINAPI_FAMILY_PARTITION(WINAPI_PARTITION_APP | WINAPI_PARTITION_SYSTEM | WINAPI_PARTITION_GAMES) */

// #if WINAPI_FAMILY_PARTITION(WINAPI_PARTITION_APP | WINAPI_PARTITION_SYSTEM)

EVENT_TRACE_LOGFILEW :: struct {
    LogFileName: *u16;      // Logfile Name
    LoggerName: *u16;       // LoggerName
    CurrentTime: s64;      // timestamp of last event
    BuffersRead: u32;      // buffers read to date
    union {
        LogFileMode: u32;  // Mode of the logfile
        ProcessTraceMode: u32;  // Processing flags used on Vista and above
    }
    CurrentEvent: EVENT_TRACE;     // Current Event from this stream.
    LogfileHeader: TRACE_LOGFILE_HEADER;    // logfile header structure
    BufferCallback: PEVENT_TRACE_BUFFER_CALLBACKW; // callback before each buffer is read
    //
    // following variables are filled for BufferCallback.
    //
    BufferSize: u32;
    Filled: u32;
    EventsLost: u32;
    //
    // following needs to be propagated to each buffer
    //
    union {
        EventCallback: PEVENT_CALLBACK; // Callback with EVENT_TRACE
        EventRecordCallback: PEVENT_RECORD_CALLBACK; // Callback with EVENT_RECORD on Vista and above
    }

    IsKernelTrace: u32;    // TRUE for kernel logfile

    Context: *void;          // reserved for internal use
};

EVENT_TRACE_LOGFILEA :: struct {
    LogFileName: *u8;      // Logfile Name
    LoggerName: *u8;       // LoggerName
    CurrentTime: s64;      // timestamp of last event
    BuffersRead: u32;      // buffers read to date
    union {
        LogFileMode: u32;      // Mode of the logfile
        ProcessTraceMode: u32; // Processing flags
    }
    CurrentEvent: EVENT_TRACE;     // Current Event from this stream
    LogfileHeader: TRACE_LOGFILE_HEADER;    // logfile header structure
    BufferCallback: PEVENT_TRACE_BUFFER_CALLBACKA; // callback before each buffer is read

    //
    // following variables are filled for BufferCallback.
    //
    BufferSize: u32;
    Filled: u32;
    EventsLost: u32;
    //
    // following needs to be propagated to each buffer
    //
    union {
        EventCallback: PEVENT_CALLBACK;  // callback for every event
        EventRecordCallback: PEVENT_RECORD_CALLBACK;
    }

    IsKernelTrace: u32;  // TRUE for kernel logfile

    Context: *void;        // reserved for internal use
};


//
// Define generic structures
//

#if USE_W_VERSIONS {
    PEVENT_TRACE_BUFFER_CALLBACK :: PEVENT_TRACE_BUFFER_CALLBACKW;
    EVENT_TRACE_LOGFILE          :: EVENT_TRACE_LOGFILEW;
    KERNEL_LOGGER_NAME           :: KERNEL_LOGGER_NAMEW;
    GLOBAL_LOGGER_NAME           :: GLOBAL_LOGGER_NAMEW;
    EVENT_LOGGER_NAME            :: EVENT_LOGGER_NAMEW;
} else {
    PEVENT_TRACE_BUFFER_CALLBACK :: PEVENT_TRACE_BUFFER_CALLBACKA;
    EVENT_TRACE_LOGFILE          :: EVENT_TRACE_LOGFILEA;
    KERNEL_LOGGER_NAME           :: KERNEL_LOGGER_NAMEA;
    GLOBAL_LOGGER_NAME           :: GLOBAL_LOGGER_NAMEA;
    EVENT_LOGGER_NAME            :: EVENT_LOGGER_NAMEA;
}

//
// Logger control APIs
//

// Use the routine below to start an event trace session
StartTraceW :: (TraceHandle: *TRACEHANDLE, InstanceName: *u16, Properties: *EVENT_TRACE_PROPERTIES) -> u32 #foreign advapi32;
StartTraceA :: (TraceHandle: *TRACEHANDLE, InstanceName: *u8 , Properties: *EVENT_TRACE_PROPERTIES) -> u32 #foreign advapi32;

// Use the routine below to stop an event trace session
StopTraceW :: (TraceHandle: TRACEHANDLE, InstanceName: *u16, Properties: *EVENT_TRACE_PROPERTIES) -> u32 #foreign advapi32;
StopTraceA :: (TraceHandle: TRACEHANDLE, InstanceName: *u8 , Properties: *EVENT_TRACE_PROPERTIES) -> u32 #foreign advapi32;

// Use the routine below to query the properties of an event trace session
QueryTraceW :: (TraceHandle: TRACEHANDLE, InstanceName: *u16, Properties: *EVENT_TRACE_PROPERTIES) -> u32 #foreign advapi32;
QueryTraceA :: (TraceHandle: TRACEHANDLE, InstanceName: *u8 , Properties: *EVENT_TRACE_PROPERTIES) -> u32 #foreign advapi32;

// Use the routine below to update certain properties of an event trace session
UpdateTraceW :: (TraceHandle: TRACEHANDLE, InstanceName: *u16, Properties: *EVENT_TRACE_PROPERTIES) -> u32 #foreign advapi32;
UpdateTraceA :: (TraceHandle: TRACEHANDLE, InstanceName: *u8 , Properties: *EVENT_TRACE_PROPERTIES) -> u32 #foreign advapi32;


// Use the routine below to request that all active buffers an event trace
// session be "flushed", or written out.
FlushTraceW :: (TraceHandle: TRACEHANDLE, InstanceName: *u16, Properties: *EVENT_TRACE_PROPERTIES) -> u32 #foreign advapi32;
FlushTraceA :: (TraceHandle: TRACEHANDLE, InstanceName: *u8 , Properties: *EVENT_TRACE_PROPERTIES) -> u32 #foreign advapi32;

// Generic trace control routine
ControlTraceW :: (TraceHandle: TRACEHANDLE, InstanceName: *u16, Properties: *EVENT_TRACE_PROPERTIES, ControlCode: u32) -> u32 #foreign advapi32;
ControlTraceA :: (TraceHandle: TRACEHANDLE, InstanceName: *u8 , Properties: *EVENT_TRACE_PROPERTIES, ControlCode: u32) -> u32 #foreign advapi32;

QueryAllTracesW :: (PropertyArray: **EVENT_TRACE_PROPERTIES, PropertyArrayCount: u32, LoggerCount: *u32) -> u32 #foreign advapi32;
QueryAllTracesA :: (PropertyArray: **EVENT_TRACE_PROPERTIES, PropertyArrayCount: u32, LoggerCount: *u32) -> u32 #foreign advapi32;

//
// Data Provider Enable APIs
//
EnableTrace :: (Enable: u32, EnableFlag: u32, EnableLevel: u32, ControlGuid: *GUID, TraceHandle: TRACEHANDLE) -> u32 #foreign advapi32;
EnableTraceEx :: (ProviderId: *GUID, SourceId: *GUID, TraceHandle: TRACEHANDLE, IsEnabled: u32, Level: u8, MatchAnyKeyword: u64, MatchAllKeyword: u64, EnableProperty: u32, EnableFilterDesc: *EVENT_FILTER_DESCRIPTOR) -> u32 #foreign advapi32;

ENABLE_TRACE_PARAMETERS_VERSION   :: 1;
ENABLE_TRACE_PARAMETERS_VERSION_2 :: 2;

ENABLE_TRACE_PARAMETERS_V1 :: struct {
    Version: u32;
    EnableProperty: u32;
    ControlFlags: u32;
    SourceId: GUID;
    EnableFilterDesc: *EVENT_FILTER_DESCRIPTOR;
}

ENABLE_TRACE_PARAMETERS :: struct {
    Version: u32;
    EnableProperty: u32;
    ControlFlags: u32;
    SourceId: GUID;
    EnableFilterDesc: *EVENT_FILTER_DESCRIPTOR;
    FilterDescCount: u32;
}

EnableTraceEx :: (TraceHandle: TRACEHANDLE, ProviderId: *GUID, ControlCode: u32, Level: u8, MatchAnyKeyword: u64, MatchAllKeyword: u64, Timeout: u32, EnableParameters: *ENABLE_TRACE_PARAMETERS) -> u32 #foreign advapi32;


TRACE_INFO_CLASS :: TRACE_QUERY_INFO_CLASS;

// TRACE_QUERY_INFO_CLASS/TRACE_INFO_CLASS @CommentsRemoved
// This enumeration contains values that are passed to one or more of the
// ETW query/set APIs: EnumerateTraceGuidsEx, TraceSetInformation, TraceQueryInformation.
TRACE_QUERY_INFO_CLASS :: enum {
    TraceGuidQueryList :: 0;
    TraceGuidQueryInfo :: 1;
    TraceGuidQueryProcess :: 2;
    TraceStackTracingInfo :: 3;
    TraceSystemTraceEnableFlagsInfo :: 4;
    TraceSampledProfileIntervalInfo :: 5;
    TraceProfileSourceConfigInfo :: 6;
    TraceProfileSourceListInfo :: 7;
    TracePmcEventListInfo :: 8;
    TracePmcCounterListInfo :: 9;
    TraceSetDisallowList :: 10;
    TraceVersionInfo :: 11;
    TraceGroupQueryList :: 12;
    TraceGroupQueryInfo :: 13;
    TraceDisallowListQuery :: 14;
    TraceInfoReserved15 :: 15;
    TracePeriodicCaptureStateListInfo :: 16;
    TracePeriodicCaptureStateInfo :: 17;
    TraceProviderBinaryTracking :: 18;
    TraceMaxLoggersQuery :: 19;
    TraceLbrConfigurationInfo :: 20;
    TraceLbrEventListInfo :: 21;
    TraceMaxPmcCounterQuery :: 22;
    TraceStreamCount :: 23;
    TraceStackCachingInfo :: 24;
    TracePmcCounterOwners :: 25;
    TraceUnifiedStackCachingInfo :: 26;
    TracePmcSessionInformation :: 27;
    MaxTraceSetInfoClass;
}


EnumerateTraceGuidsEx :: (TraceQueryInfoClass: TRACE_QUERY_INFO_CLASS, InBuffer: *void, InBufferSize: u32, OutBuffer: *void, OutBufferSize: u32, ReturnLength: *u32) -> u32 #foreign advapi32;

CLASSIC_EVENT_ID :: struct {
    EventGuid: GUID;
    Type: u8;
    Reserved: [7] u8;
}

TRACE_STACK_CACHING_INFO :: struct {
    Enabled: BOOLEAN;
    CacheSize: u32;
    BucketCount: u32;
}

TRACE_PROFILE_INTERVAL :: struct {
    Source: u32;
    Interval: u32;
}

TRACE_VERSION_INFO :: struct {
    EtwTraceProcessingVersion: u8;
    Reserved: u8;
}

TRACE_PERIODIC_CAPTURE_STATE_INFO :: struct {
    CaptureStateFrequencyInSeconds: u32;
    ProviderCount: u16;
    Reserved: u16;
}

TraceSetInformation :: (SessionHandle: TRACEHANDLE, InformationClass: TRACE_INFO_CLASS, TraceInformation: *void, InformationLength: u32) -> u32 #foreign advapi32;
TraceQueryInformation :: (SessionHandle: TRACEHANDLE, InformationClass: TRACE_INFO_CLASS, TraceInformation: *void, InformationLength: u32, ReturnLength: *u32) -> u32 #foreign advapi32;


//
// Data Provider APIs
//


CreateTraceInstanceId :: (RegHandle: HANDLE, InstInfo: *EVENT_INSTANCE_INFO) -> u32 #foreign advapi32;

// Use the routine below to generate and record an event trace
TraceEvent :: (TraceHandle: TRACEHANDLE, EventTrace: *EVENT_TRACE_HEADER) -> u32 #foreign advapi32;
TraceEventInstance :: (TraceHandle: TRACEHANDLE, EventTrace: *EVENT_INSTANCE_HEADER, InstInfo: *EVENT_INSTANCE_INFO, ParentInstInfo: *EVENT_INSTANCE_INFO) -> u32 #foreign advapi32;

// Use the routine below to register a guid for tracing.
RegisterTraceGuidsW :: (RequestAddress: WMIDPREQUEST, RequestContext: *void, ControlGuid: *GUID, GuidCount: u32, TraceGuidReg: *TRACE_GUID_REGISTRATION, MofImagePath: *u16, MofResourceName: *u16, RegistrationHandle: *TRACEHANDLE) -> u32 #foreign advapi32;
RegisterTraceGuidsA :: (RequestAddress: WMIDPREQUEST, RequestContext: *void, ControlGuid: *GUID, GuidCount: u32, TraceGuidReg: *TRACE_GUID_REGISTRATION, MofImagePath: *u8 , MofResourceName: *u8 , RegistrationHandle: *TRACEHANDLE) -> u32 #foreign advapi32;


EnumerateTraceGuids :: (GuidPropertiesArray: **TRACE_GUID_PROPERTIES, PropertyArrayCount: u32, GuidCount: *u32) -> u32 #foreign advapi32;
UnregisterTraceGuids :: (RegistrationHandle: TRACEHANDLE) -> u32 #foreign advapi32;
GetTraceLoggerHandle :: (Buffer: *void) -> TRACEHANDLE #foreign advapi32;
GetTraceEnableLevel :: (TraceHandle: TRACEHANDLE) -> u8 #foreign advapi32;
GetTraceEnableFlags :: (TraceHandle: TRACEHANDLE) -> u32 #foreign advapi32;


//
// Data Consumer APIs and structures start here
//

// NOTE(Charles): Some of the below are marked ETW_APP_DECLSPEC_DEPRECATED in the c header, hard to tell with the
// #ifdefness what this means, I have preserved the info with a comment.

OpenTraceW :: (Logfile: *EVENT_TRACE_LOGFILEW) -> TRACEHANDLE #foreign advapi32; // ETW_APP_DECLSPEC_DEPRECATED
ProcessTrace :: (HandleArray: *TRACEHANDLE, HandleCount: u32, StartTime: *FILETIME, EndTime: *FILETIME) -> u32 #foreign advapi32; // ETW_APP_DECLSPEC_DEPRECATED
CloseTrace :: (TraceHandle: TRACEHANDLE) -> u32 #foreign advapi32; // ETW_APP_DECLSPEC_DEPRECATED

// NOTE(Charles): The below fail to be found in advapi32 on my system. Not exactly sure why?
// OpenTraceFromBufferStream :: (Options: *ETW_OPEN_TRACE_OPTIONS, BufferCompletionCallback: PETW_BUFFER_COMPLETION_CALLBACK, BufferCompletionContext: *void) -> TRACEHANDLE #foreign advapi32; // ETW_APP_DECLSPEC_DEPRECATED
// OpenTraceFromRealTimeLogger :: (LoggerName: *u16, Options: *ETW_OPEN_TRACE_OPTIONS, LogFileHeader: *TRACE_LOGFILE_HEADER) -> TRACEHANDLE #foreign advapi32; // ETW_APP_DECLSPEC_DEPRECATED
// OpenTraceFromRealTimeLoggerWithAllocationOptions :: (LoggerName: *u16, Options: *ETW_OPEN_TRACE_OPTIONS, AllocationSize: *u32, MemoryPartitionHandle: HANDLE, LogFileHeader: *TRACE_LOGFILE_HEADER) -> TRACEHANDLE #foreign advapi32; // ETW_APP_DECLSPEC_DEPRECATED
// OpenTraceFromFile :: (LogFileName: *u16, Options: *ETW_OPEN_TRACE_OPTIONS, LogFileHeader: *TRACE_LOGFILE_HEADER) -> TRACEHANDLE #foreign advapi32; // ETW_APP_DECLSPEC_DEPRECATED
// ProcessTraceBufferIncrementReference :: (TraceHandle: TRACEHANDLE, Buffer: *ETW_BUFFER_HEADER) -> u32 #foreign advapi32; // ETW_APP_DECLSPEC_DEPRECATED
// ProcessTraceBufferDecrementReference :: (Buffer: *ETW_BUFFER_HEADER) -> u32 #foreign advapi32; // ETW_APP_DECLSPEC_DEPRECATED
// ProcessTraceAddBufferToBufferStream :: (TraceHandle: TRACEHANDLE, Buffer: *ETW_BUFFER_HEADER, BufferSize: u32) -> u32 #foreign advapi32; // ETW_APP_DECLSPEC_DEPRECATED


//
// Structures and enums for QueryTraceProcessingHandle
//

ETW_PROCESS_HANDLE_INFO_TYPE :: enum {
    PartitionInformation :: 1;
    PartitionInformationV2 :: 2;
    LastDroppedTimes :: 3;
    LogFileHeader :: 4;
    ProcessHandleInfoMax;
}

ETW_TRACE_PARTITION_INFORMATION :: struct {
    PartitionId: GUID;
    ParentId: GUID;
    QpcOffsetFromRoot: s64;
    PartitionType: u32;
}

ETW_TRACE_PARTITION_INFORMATION_V2 :: struct {
    QpcOffsetFromRoot: s64;
    PartitionType: u32;
    PartitionId: *u16;
    ParentId: *u16;
}

QueryTraceProcessingHandle :: (ProcessingHandle: TRACEHANDLE, InformationClass: ETW_PROCESS_HANDLE_INFO_TYPE, InBuffer: *void, InBufferSize: u32, OutBuffer: *void, OutBufferSize: u32, ReturnLength: u32) -> u32 #foreign advapi32; // ETW_APP_DECLSPEC_DEPRECATED


//
// Data Consumer APIs and structures start here
//

OpenTraceA :: (Logfile: *EVENT_TRACE_LOGFILEA) -> TRACEHANDLE #foreign advapi32;
SetTraceCallback :: (pGuid: *GUID, EventCallback: PEVENT_CALLBACK) -> u32 #foreign advapi32;
RemoveTraceCallback :: (pGuid: *GUID) -> u32 #foreign advapi32;


//
// The routines for tracing Messages follow
//

// @Incomplete: TraceMessage takes var args, not sure how to do that?

// TraceMessage :: (LoggerHandle: TRACEHANDLE, MessageFlags: u32, MessageGuid: *GUID, MessageNumber: u16, ...) -> u32 #foreign advapi32;
// TraceMessageVa :: (LoggerHandle: TRACEHANDLE, MessageFlags: u32, MessageGuid: *GUID, MessageNumber: u16, MessageArgList: va_list) -> u32 #foreign advapi32;

INVALID_PROCESSTRACE_HANDLE :: #run cast(TRACEHANDLE) INVALID_HANDLE_VALUE;

//
// Define the encoding independent routines
#if USE_W_VERSIONS {
    RegisterTraceGuids :: RegisterTraceGuidsW;
    StartTrace         :: StartTraceW;
    ControlTrace       :: ControlTraceW;
// #if defined(__TRACE_W2K_COMPATIBLE)
    // #define StopTrace(a,b,c)        ControlTraceW((a),(b),(c), EVENT_TRACE_CONTROL_STOP)
    // #define QueryTrace(a,b,c)       ControlTraceW((a),(b),(c), EVENT_TRACE_CONTROL_QUERY)
    // #define UpdateTrace(a,b,c)      ControlTraceW((a),(b),(c), EVENT_TRACE_CONTROL_UPDATE)
// #else
    StopTrace   :: StopTraceW;
    QueryTrace  :: QueryTraceW;
    UpdateTrace :: UpdateTraceW;
// #endif
// #if (NTDDI_VERSION >= NTDDI_WINXP)
    FlushTrace :: FlushTraceW;
// #endif // NTDDI_VERSION >= NTDDI_WINXP
    QueryAllTraces :: QueryAllTracesW;
    OpenTrace      :: OpenTraceW;

} else {

    RegisterTraceGuids :: RegisterTraceGuidsA;
    StartTrace         :: StartTraceA;
    ControlTrace       :: ControlTraceA;
// #if defined(__TRACE_W2K_COMPATIBLE)
    // #define StopTrace(a,b,c)        ControlTraceA((a),(b),(c), EVENT_TRACE_CONTROL_STOP)
    // #define QueryTrace(a,b,c)       ControlTraceA((a),(b),(c), EVENT_TRACE_CONTROL_QUERY)
    // #define UpdateTrace(a,b,c)      ControlTraceA((a),(b),(c), EVENT_TRACE_CONTROL_UPDATE)
// #else
    StopTrace   :: StopTraceA;
    QueryTrace  :: QueryTraceA;
    UpdateTrace :: UpdateTraceA;
// #endif
// #if (NTDDI_VERSION >= NTDDI_WINXP)
    FlushTrace  :: FlushTraceA;
// #endif // NTDDI_VERSION >= NTDDI_WINXP
    QueryAllTraces :: QueryAllTracesA;
    OpenTrace      :: OpenTraceA;
}
