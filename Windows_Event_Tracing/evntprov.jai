EVENT_MIN_LEVEL :: 0;    // Lowest value for an event level is 0.
EVENT_MAX_LEVEL :: 0xff; // Highest value for an event level is 255.

// EVENT_ACTIVITY_CTRL values for the ControlCode parameter of EventActivityIdControl.
EVENT_ACTIVITY_CTRL_GET_ID        :: 1; // EventActivityIdControl will return the current thread's activity ID.
EVENT_ACTIVITY_CTRL_SET_ID        :: 2; // EventActivityIdControl will set the current thread's activity ID.
EVENT_ACTIVITY_CTRL_CREATE_ID     :: 3; // EventActivityIdControl will generate and return a new activity ID. @CommentsRemoved
EVENT_ACTIVITY_CTRL_GET_SET_ID    :: 4; // EventActivityIdControl will set the current thread's activity ID and return the previous activity ID.
EVENT_ACTIVITY_CTRL_CREATE_SET_ID :: 5; // EventActivityIdControl will generate a new activity ID, set the current thread's activity ID to the new value, and return the previous activity ID.

MAX_EVENT_DATA_DESCRIPTORS       :: 128; // The maximum number of EVENT_DATA_DESCRIPTORs that can be used in an event. Used with EventWrite, EventWriteTransfer, EventWriteEx.
MAX_EVENT_FILTER_DATA_SIZE       :: 1024; // The maximum data size for many of the filter types. Used with EVENT_FILTER_DESCRIPTOR.
MAX_EVENT_FILTER_PAYLOAD_SIZE    :: 4096; // The maximum data size for an event payload filter. Used with EVENT_FILTER_DESCRIPTOR of type EVENT_FILTER_TYPE_PAYLOAD.
MAX_EVENT_FILTER_EVENT_NAME_SIZE :: 4096; // The maximum data size for a name-based filter. Used with EVENT_FILTER_DESCRIPTOR for name-based filters.

MAX_EVENT_FILTERS_COUNT :: 13; // The maximum number of filters that can be provided in a call to EnableTraceEx2. Used with ENABLE_TRACE_PARAMETERS.

MAX_EVENT_FILTER_PID_COUNT :: 8; // The maximum number of process IDs in a PID filter. Used with EVENT_FILTER_DESCRIPTOR of type EVENT_FILTER_TYPE_PID.

MAX_EVENT_FILTER_EVENT_ID_COUNT :: 64; // The maximum number of event IDs in an event ID or stackwalk filter. Used with EVENT_FILTER_DESCRIPTOR of type EVENT_FILTER_TYPE_EVENT_ID or EVENT_FILTER_TYPE_STACKWALK.

// EVENT_FILTER_TYPE values for the Type field of EVENT_FILTER_DESCRIPTOR.
EVENT_FILTER_TYPE_NONE               :: 0x00000000;
EVENT_FILTER_TYPE_SCHEMATIZED        :: 0x80000000; // Provider-side.
EVENT_FILTER_TYPE_SYSTEM_FLAGS       :: 0x80000001; // Internal use only.
EVENT_FILTER_TYPE_TRACEHANDLE        :: 0x80000002; // Initiate rundown.
EVENT_FILTER_TYPE_PID                :: 0x80000004; // Process ID.
EVENT_FILTER_TYPE_EXECUTABLE_NAME    :: 0x80000008; // EXE file name.
EVENT_FILTER_TYPE_PACKAGE_ID         :: 0x80000010; // Package ID.
EVENT_FILTER_TYPE_PACKAGE_APP_ID     :: 0x80000020; // Package Relative App Id (PRAID).
EVENT_FILTER_TYPE_PAYLOAD            :: 0x80000100; // TDH payload filter.
EVENT_FILTER_TYPE_EVENT_ID           :: 0x80000200; // Event IDs.
EVENT_FILTER_TYPE_EVENT_NAME         :: 0x80000400; // Event name (TraceLogging only).
EVENT_FILTER_TYPE_STACKWALK          :: 0x80001000; // Event IDs for stack.
EVENT_FILTER_TYPE_STACKWALK_NAME     :: 0x80002000; // Event name for stack (TraceLogging only).
EVENT_FILTER_TYPE_STACKWALK_LEVEL_KW :: 0x80004000; // Filter stack collection by level and keyword.
EVENT_FILTER_TYPE_CONTAINER          :: 0x80008000; // Filter by Container ID.

/*
EVENT_DATA_DESCRIPTOR_TYPE values for the Type field of EVENT_DATA_DESCRIPTOR.
Note that the Type field is ignored by default. ETW will only check the Type
field if a provider has opted-in via a call to EventSetInformation.
*/
EVENT_DATA_DESCRIPTOR_TYPE_NONE               :: 0; // Event data (payload).
EVENT_DATA_DESCRIPTOR_TYPE_EVENT_METADATA     :: 1; // TraceLogging event decoding information.
EVENT_DATA_DESCRIPTOR_TYPE_PROVIDER_METADATA  :: 2; // Manually-attached provider traits. For use with operating systems that do not support attaching provider traits via EventSetInformation. This data will be ignored if provider traits have been configured via EventSetInformation.
EVENT_DATA_DESCRIPTOR_TYPE_TIMESTAMP_OVERRIDE :: 3; // 64-bit event timestamp override. For use when relogging. Note that logging events out of timestamp order may lead to event ordering issues during trace processing. 

// EVENT_WRITE_FLAG values for the Flag parameter of EventWriteEx and EtwWriteEx. @CommentsRemoved
EVENT_WRITE_FLAG_NO_FAULTING :: 0x00000001;
EVENT_WRITE_FLAG_INPRIVATE   :: 0x00000002;

// A REGHANDLE represents an event provider session. It is opened with EventRegister and closed with EventUnregister.
REGHANDLE :: u64;


// EVENT_DATA_DESCRIPTOR is used with EventWrite to provide user data items.
EVENT_DATA_DESCRIPTOR :: struct {
    Ptr: u64;   // Pointer to data. Set to (u64)(ULONG_PTR)pData.
    Size: u32;  // Size of data in bytes.
    union {
        Reserved: u32; // Set to 0 if not using a special data item type.
        struct {
            Type: u8;     // Default is EVENT_DATA_DESCRIPTOR_TYPE_NONE, meaning normal payload data.
            Reserved1: u8;
            Reserved2: u16;
        }
    }
}

// EVENT_DESCRIPTOR describes and categorizes an event. Note that for TraceLogging events, the Id and Version fields are
// not meaningful and should be ignored.
// @CommentsRemoved
EVENT_DESCRIPTOR :: struct {
    Id: u16;
    Version: u8;
    Channel: u8;
    Level: u8;
    Opcode: u8;
    Task: u16;
    Keyword: u64;
}


// EVENT_FILTER_DESCRIPTOR describes a filter data item for EnableTraceEx2.
EVENT_FILTER_DESCRIPTOR :: struct {
    Ptr: u64;  // Pointer to filter data. Set to (u64)(ULONG_PTR)pData.
    Size: u32; // Size of filter data in bytes.
    Type: u32; // EVENT_FILTER_TYPE value.

}

// Defines the header data that must precede the filter data. The filter data layout is defined in the instrumentation manifest.
EVENT_FILTER_HEADER :: struct {
    Id: u16;
    Version: u8;
    Reserved: [5] u8;
    InstanceId: u64;
    Size: u32;
    NextOffset: u32;
}

// EVENT_FILTER_EVENT_ID is used to pass EventId filter for stack walk filters.
EVENT_FILTER_EVENT_ID :: struct {
    FilterIn: BOOLEAN;
    Reserved: u8;
    Count: u16;
    Events: [ANYSIZE_ARRAY] u16;
}

// @CommentsRemoved
EVENT_FILTER_EVENT_NAME :: struct {
    MatchAnyKeyword: u64;
    MatchAllKeyword: u64;
    Level: u8;
    FilterIn: BOOLEAN;
    NameCount: u16;
    Names: [ANYSIZE_ARRAY] u8; // utf-8
}

// @CommentsRemoved
EVENT_FILTER_LEVEL_KW :: struct {
    MatchAnyKeyword: u64;
    MatchAllKeyword: u64;
    Level: u8;
    FilterIn: BOOLEAN;
}


// EVENT_INFO_CLASS values for the InformationClass parameter of EventSetInformation.
EVENT_INFO_CLASS :: enum s32 {
    EventProviderBinaryTrackInfo;
    EventProviderSetReserved1; 
    EventProviderSetTraits;
    EventProviderUseDescriptorType;
    MaxEventInfo;
}

// @CommentsRemoved From all procedures below

PENABLECALLBACK :: #type (SourceId: *GUID, IsEnabled: u32, Level: u8, MatchAnyKeyword: u64, MatchAllKeyword: u64, FilterData: *EVENT_FILTER_DESCRIPTOR, CallbackContext: *void) #c_call;

//
// Registration APIs
//

EventRegister :: (ProviderId: *GUID, EnableCallback: PENABLECALLBACK, CallbackContext: *void, RegHandle: *REGHANDLE) -> u32 #foreign advapi32;
EventUnregister :: (RegHandle: REGHANDLE) -> u32 #foreign advapi32;
EventSetInformation :: (RegHandle: REGHANDLE, InformationClass: EVENT_INFO_CLASS, EventInformation: *void, InformationLength: u32) -> u32 #foreign advapi32;
EventEnabled :: (RegHandle: REGHANDLE, EventDescriptor: *EVENT_DESCRIPTOR) -> BOOLEAN #foreign advapi32;
EventProviderEnabled :: (RegHandle: REGHANDLE, Level: u8, Keyword: u64) -> BOOLEAN #foreign advapi32;

//
// Writing (Publishing/Logging) APIs
//

EventWrite :: (RegHandle: REGHANDLE, EventDescriptor: *EVENT_DESCRIPTOR, UserDataCount: u32, UserData: *EVENT_DATA_DESCRIPTOR) -> u32 #foreign advapi32;
EventWriteTransfer :: (RegHandle: REGHANDLE, EventDescriptor: EVENT_DESCRIPTOR, ActivityId: *GUID, RelatedActivityId: *GUID, UserDataCount: u32, UserData: *EVENT_DATA_DESCRIPTOR) -> u32 #foreign advapi32;
EventWriteEx :: (RegHandle: REGHANDLE, EventDescriptor: *EVENT_DESCRIPTOR, Filter: u64, Flags: u32, ActivityId: *GUID, RelatedActivityId: *GUID, UserDataCount: u32, UserData: *EVENT_DATA_DESCRIPTOR) -> u32 #foreign advapi32;
EventWriteString :: (RegHandle: REGHANDLE, Level: u8, Keyword: u64, String: *u16) -> u32 #foreign advapi32;
EventActivityIdControl :: (ControlCode: u32, ActivityId: *GUID) -> u32 #foreign advapi32;

EventDataDescCreate :: (EventDataDescriptor: *EVENT_DATA_DESCRIPTOR, DataPtr: *void, DataSize: u32) {
    EventDataDescriptor.Ptr = cast(u64) DataPtr;
    EventDataDescriptor.Size = DataSize;
    EventDataDescriptor.Reserved = 0; // Reserved MUST be initialized.
}

EventDescCreate :: (EventDescriptor: *EVENT_DESCRIPTOR, Id: u16, Version: u8, Channel: u8, Level: u8, Task: u16, Opcode: u8, Keyword: u64) {
    EventDescriptor.Id      = Id;
    EventDescriptor.Version = Version;
    EventDescriptor.Channel = Channel;
    EventDescriptor.Level   = Level;
    EventDescriptor.Task    = Task;
    EventDescriptor.Opcode  = Opcode;
    EventDescriptor.Keyword = Keyword;
}

EventDescZero :: (EventDescriptor: *EVENT_DESCRIPTOR) {
    memset(EventDescriptor, 0, size_of(EVENT_DESCRIPTOR));
}

//
// Macros to extract info from an Event Descriptor
//

EventDescGetId      :: (EventDescriptor: *EVENT_DESCRIPTOR) -> u16 #expand { return (EventDescriptor.Id); }
EventDescGetVersion :: (EventDescriptor: *EVENT_DESCRIPTOR) -> u8  #expand { return (EventDescriptor.Version); }
EventDescGetTask    :: (EventDescriptor: *EVENT_DESCRIPTOR) -> u16 #expand { return (EventDescriptor.Task); }
EventDescGetOpcode  :: (EventDescriptor: *EVENT_DESCRIPTOR) -> u8  #expand { return (EventDescriptor.Opcode); }
EventDescGetChannel :: (EventDescriptor: *EVENT_DESCRIPTOR) -> u8  #expand { return (EventDescriptor.Channel); }
EventDescGetLevel   :: (EventDescriptor: *EVENT_DESCRIPTOR) -> u8  #expand { return (EventDescriptor.Level); }
EventDescGetKeyword :: (EventDescriptor: *EVENT_DESCRIPTOR) -> u64 #expand { return (EventDescriptor.Keyword); }

//
// Macros to set info into an Event Descriptor
//

EventDescSetId :: (EventDescriptor: *EVENT_DESCRIPTOR, Id: u16) -> *EVENT_DESCRIPTOR #expand {
    EventDescriptor.Id = Id;
    return EventDescriptor;
}

EventDescSetVersion :: (EventDescriptor: *EVENT_DESCRIPTOR, Version: u8) -> *EVENT_DESCRIPTOR #expand {
    EventDescriptor.Version = Version;
    return EventDescriptor;
}

EventDescSetTask :: (EventDescriptor: *EVENT_DESCRIPTOR, Task: u16) -> *EVENT_DESCRIPTOR #expand {
    EventDescriptor.Task = Task;
    return EventDescriptor;
}

EventDescSetOpcode :: (EventDescriptor: *EVENT_DESCRIPTOR, Opcode: u8) -> *EVENT_DESCRIPTOR #expand {
    EventDescriptor.Opcode = Opcode;
    return EventDescriptor;
}

EventDescSetLevel :: (EventDescriptor: *EVENT_DESCRIPTOR,  Level: u8) -> *EVENT_DESCRIPTOR #expand {
    EventDescriptor.Level = Level;
    return EventDescriptor;
}

EventDescSetChannel :: (EventDescriptor: *EVENT_DESCRIPTOR, Channel: u8) -> *EVENT_DESCRIPTOR #expand {
    EventDescriptor.Channel = Channel;
    return EventDescriptor;
}

EventDescSetKeyword :: (EventDescriptor: *EVENT_DESCRIPTOR, Keyword: u64) -> *EVENT_DESCRIPTOR #expand {
    EventDescriptor.Keyword = Keyword;
    return EventDescriptor;
}


EventDescOrKeyword :: (EventDescriptor: *EVENT_DESCRIPTOR, Keyword: u64) -> *EVENT_DESCRIPTOR #expand {
    EventDescriptor.Keyword |= Keyword;
    return EventDescriptor;
}
