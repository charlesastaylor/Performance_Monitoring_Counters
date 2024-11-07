// @WindowVersionIfDefRemoved

// #include <wmistr.h>
// #include <evntrace.h>
// #include <evntprov.h>

EVENT_HEADER_EXT_TYPE :: enum u16 {
    RELATED_ACTIVITYID :: 0x0001;
    SID                :: 0x0002;
    TS_ID              :: 0x0003;
    INSTANCE_INFO      :: 0x0004;
    STACK_TRACE32      :: 0x0005;
    STACK_TRACE64      :: 0x0006;
    PEBS_INDEX         :: 0x0007;
    PMC_COUNTERS       :: 0x0008;
    PSM_KEY            :: 0x0009;
    EVENT_KEY          :: 0x000A;
    EVENT_SCHEMA_TL    :: 0x000B;
    PROV_TRAITS        :: 0x000C;
    PROCESS_START_KEY  :: 0x000D;
    CONTROL_GUID       :: 0x000E;
    QPC_DELTA          :: 0x000F;
    CONTAINER_ID       :: 0x0010;
    STACK_KEY32        :: 0x0011;
    STACK_KEY64        :: 0x0012;
    MAX                :: 0x0013;
}

EVENT_HEADER_EXTENDED_DATA_ITEM :: struct {
    Reserved1: u16;
    ExtType: EVENT_HEADER_EXT_TYPE;
    // NOTE(Charles): The definition of this struct in relogger.h just used USHORT Linkage and doesn't do the whack bitfield
    // thing? That is what I am doing here...
    // struct {
    //     u16  Linkage             :  1;       // Indicates additional extended data item
    //     u16  Reserved2           : 15;
    // };
    Linkage: u16;
    DataSize: u16;                       // Size of extended info data
    DataPtr: u64;                        // Pointer to extended info data
}

//
// Structures for extended items.
//

EVENT_EXTENDED_ITEM_INSTANCE :: struct {
    InstanceId: u32;
    ParentInstanceId: u32;
    ParentGuid: GUID;
}

EVENT_EXTENDED_ITEM_RELATED_ACTIVITYID :: struct {
    RelatedActivityId: GUID;
}

EVENT_EXTENDED_ITEM_TS_ID :: struct {
    SessionId: u32;
}

EVENT_EXTENDED_ITEM_STACK_TRACE32 :: struct {
    MatchId: u64;
    Address: [ANYSIZE_ARRAY] u32;
}

EVENT_EXTENDED_ITEM_STACK_TRACE64 :: struct {
    MatchId: u64;
    Address: [ANYSIZE_ARRAY] u64;
}

EVENT_EXTENDED_ITEM_STACK_KEY32 :: struct {
    MatchId: u64;
    StackKey: u32;
    Padding: u32;
}

EVENT_EXTENDED_ITEM_STACK_KEY64 :: struct {
    MatchId: u64;
    StackKey: u64;
}

EVENT_EXTENDED_ITEM_PEBS_INDEX :: struct {
    PebsIndex: u64;
}

EVENT_EXTENDED_ITEM_PMC_COUNTERS :: struct {
    Counter: [ANYSIZE_ARRAY] u64;
}

EVENT_EXTENDED_ITEM_PROCESS_START_KEY :: struct {
    ProcessStartKey: u64;
}

EVENT_EXTENDED_ITEM_EVENT_KEY :: struct {
    Key: u64;
}

EVENT_HEADER_PROPERTY_XML             :: 0x0001;
EVENT_HEADER_PROPERTY_FORWARDED_XML   :: 0x0002;
EVENT_HEADER_PROPERTY_LEGACY_EVENTLOG :: 0x0004;
EVENT_HEADER_PROPERTY_RELOGGABLE      :: 0x0008;

EVENT_HEADER_FLAG :: enum_flags u16 {
    EXTENDED_INFO   :: 0x0001;
    PRIVATE_SESSION :: 0x0002;
    STRING_ONLY     :: 0x0004;
    TRACE_MESSAGE   :: 0x0008;
    NO_CPUTIME      :: 0x0010;
    _32_BIT_HEADER  :: 0x0020;
    _64_BIT_HEADER  :: 0x0040;
    DECODE_GUID     :: 0x0080; // ProviderId is decode GUID.
    CLASSIC_HEADER  :: 0x0100;
    PROCESSOR_INDEX :: 0x0200;
}

EVENT_HEADER :: struct {
    Size: u16;
    HeaderType: u16;
    Flags: EVENT_HEADER_FLAG;
    EventProperty: u16;
    ThreadId: u32;
    ProcessId: u32;
    TimeStamp: LARGE_INTEGER;
    ProviderId: GUID;
    EventDescriptor: EVENT_DESCRIPTOR;
    union {
        struct {
            KernelTime: u32; // Kernel Mode CPU ticks
            UserTime: u32;   // User mode CPU ticks
        }
        ProcessorTime: u64; // Processor Clock for private session events
    }
    ActivityId: GUID;
}

EVENT_RECORD :: struct {
    EventHeader: EVENT_HEADER;
    BufferContext: ETW_BUFFER_CONTEXT;
    ExtendedDataCount: u16;
    UserDataLength: u16;
    ExtendedData: *EVENT_HEADER_EXTENDED_DATA_ITEM;
    UserData: *void;
    UserContext: *void;
}

EVENT_ENABLE_PROPERTY_SID                       :: 0x00000001;
EVENT_ENABLE_PROPERTY_TS_ID                     :: 0x00000002;
EVENT_ENABLE_PROPERTY_STACK_TRACE               :: 0x00000004;
EVENT_ENABLE_PROPERTY_PSM_KEY                   :: 0x00000008;
EVENT_ENABLE_PROPERTY_IGNORE_KEYWORD_0          :: 0x00000010;
EVENT_ENABLE_PROPERTY_PROVIDER_GROUP            :: 0x00000020;
EVENT_ENABLE_PROPERTY_ENABLE_KEYWORD_0          :: 0x00000040;
EVENT_ENABLE_PROPERTY_PROCESS_START_KEY         :: 0x00000080;
EVENT_ENABLE_PROPERTY_EVENT_KEY                 :: 0x00000100;
EVENT_ENABLE_PROPERTY_EXCLUDE_INPRIVATE         :: 0x00000200;
EVENT_ENABLE_PROPERTY_ENABLE_SILOS              :: 0x00000400;
EVENT_ENABLE_PROPERTY_SOURCE_CONTAINER_TRACKING :: 0x00000800;

//
// Consumer API
//

PROCESS_TRACE_MODE_REAL_TIME     : u32 : 0x00000100;
PROCESS_TRACE_MODE_RAW_TIMESTAMP : u32 : 0x00001000;
PROCESS_TRACE_MODE_EVENT_RECORD  : u32 : 0x10000000;

GetEventProcessorIndex :: inline (EventRecord: *EVENT_RECORD) -> u32 #c_call {
    if (EventRecord.EventHeader.Flags & .PROCESSOR_INDEX) != 0 {
        return EventRecord.BufferContext.ProcessorIndex;
    } else {
        return EventRecord.BufferContext.ProcessorNumber;
    }
}

//
// Provider Trait APIs
//

ETW_PROVIDER_TRAIT_TYPE :: enum s32 {
    EtwProviderTraitTypeGroup  :: 1; // Provider group GUID.
    EtwProviderTraitDecodeGuid :: 2; // Decode GUID (when different from control GUID)
    EtwProviderTraitTypeMax;
}

EtwGetTraitFromProviderTraits :: inline (ProviderTraits: *void, TraitType: u8, Trait: **void, Size: *u16) #c_call {
    Basic :: #import "Basic";
    Basic.assert(false, "Not implemented, port it yourself you filthy animal!");
    /*
    USHORT const ByteCount = *(USHORT UNALIGNED*)ProviderTraits;
    PUCHAR Ptr = (PUCHAR)ProviderTraits;
    UCHAR const* PtrEnd = Ptr + ByteCount;

    *Trait = NULL;
    *Size = 0;

    //
    // Abort on invalid size.
    //

    if (ByteCount < 3) {
        return;
    }

    //
    // Skip byte counts
    //

    Ptr += 2;

    //
    // Skip the Provider Name, including the Null termination
    //

    Ptr += strnlen((PCSTR)Ptr, ByteCount - 3u);
    Ptr += 1;

    //
    // Loop through the rest of the traits until one of the
    // desired type is located.
    //

    while (Ptr < PtrEnd) {
        USHORT const TraitByteCount = *(USHORT const UNALIGNED*)Ptr;

        //
        // Abort on invalid trait size.
        //

        if (TraitByteCount < 3) {
            return;
        }

        if ((Ptr[2] == TraitType) &&
            (Ptr + TraitByteCount <= PtrEnd)) {

            *Trait = (PVOID)(Ptr + 3);
            *Size = TraitByteCount - 3u;
            return;
        }

        Ptr += TraitByteCount;
    }
    */
}

//
// Event Security APIs
//

EVENTSECURITYOPERATION :: enum s32 {
    SetDACL;
    SetSACL;
    AddDACL;
    AddSACL;
    Max;
}

// @Incomplete: Requires SID, SECURITY_DESCRIPTOR and dependant declarations!

// EventAccessControl :: (Guid: *GUID, Operation: u32, Sid: *SID, Rights: u32, AllowOrDeny: BOOLEAN) -> u32 #foreign advapi32;
// EventAccessQuery :: (Guid: *GUID, Buffer: *SECURITY_DESCRIPTOR, BufferSize: *u32) -> u32 #foreign advapi32;
EventAccessRemove :: (Guid: *GUID) -> u32 #foreign advapi32;
