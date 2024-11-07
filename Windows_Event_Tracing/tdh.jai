// #include <wmistr.h>
// #include <evntrace.h>
// #include <evntcons.h>

// @WindowVersionIfDefRemoved Around various procedures and macros. Depending on your windows version some procedures
// might not be available (you will get a compile time link error so you will know!)

TDHSTATUS  :: u32;
TDH_HANDLE :: HANDLE;

EVENT_MAP_ENTRY :: struct {
    OutputOffset: u32;
    union {
        Value: u32;        // For u32 value (valuemap and bitmap).
        InputOffset: u32;  // For String value (patternmap or valuemap in WBEM).
    }
}

EVENTMAP_INFO_FLAG :: enum_flags s32 {
    MANIFEST_VALUEMAP   :: 0x1;
    MANIFEST_BITMAP     :: 0x2;
    MANIFEST_PATTERNMAP :: 0x4;
    WBEM_VALUEMAP       :: 0x8;
    WBEM_BITMAP         :: 0x10;
    WBEM_FLAG           :: 0x20;
    WBEM_NO_MAP         :: 0x40;
}
MAP_FLAGS :: EVENTMAP_INFO_FLAG;

MAP_VALUETYPE :: enum s32 {
    ULONG;
    STRING;
}
EVENTMAP_ENTRY_VALUETYPE :: MAP_VALUETYPE;

EVENT_MAP_INFO :: struct {
    NameOffset: u32;
    Flag: MAP_FLAGS;
    EntryCount: u32;
    union {
        MapEntryValueType: MAP_VALUETYPE;
        FormatStringOffset: u32 ;
    };
    MapEntryArray: [ANYSIZE_ARRAY] EVENT_MAP_ENTRY; // Size == EntryCount
}

TDH_IN_TYPE :: enum s32 {
    NULL;
    UNICODESTRING;
    ANSISTRING;
    INT8;
    UINT8;
    INT16;
    UINT16;
    INT32;
    UINT32;
    INT64;
    UINT64;
    FLOAT;
    DOUBLE;
    BOOLEAN;
    BINARY;
    GUID;
    POINTER;
    FILETIME;
    SYSTEMTIME;
    SID;
    HEXINT32;
    HEXINT64;
    MANIFEST_COUNTEDSTRING;
    MANIFEST_COUNTEDANSISTRING;
    RESERVED24;
    MANIFEST_COUNTEDBINARY;

    // End of winmeta intypes.
    // Start of TDH intypes for WBEM. These types cannot be used in manifests.

    COUNTEDSTRING :: 300;
    COUNTEDANSISTRING;
    REVERSEDCOUNTEDSTRING;
    REVERSEDCOUNTEDANSISTRING;
    NONNULLTERMINATEDSTRING;
    NONNULLTERMINATEDANSISTRING;
    UNICODECHAR;
    ANSICHAR;
    SIZET;
    HEXDUMP;
    WBEMSID;
};

TDH_OUT_TYPE :: enum s32 {
    NULL;
    STRING;
    DATETIME;
    BYTE;
    UNSIGNEDBYTE;
    SHORT;
    UNSIGNEDSHORT;
    INT;
    UNSIGNEDINT;
    LONG;
    UNSIGNEDLONG;
    FLOAT;
    DOUBLE;
    BOOLEAN;
    GUID;
    HEXBINARY;
    HEXINT8;
    HEXINT16;
    HEXINT32;
    HEXINT64;
    PID;
    TID;
    PORT;
    IPV4;
    IPV6;
    SOCKETADDRESS;
    CIMDATETIME;
    ETWTIME;
    XML;
    ERRORCODE;
    WIN32ERROR;
    NTSTATUS;
    HRESULT;
    CULTURE_INSENSITIVE_DATETIME;
    JSON;
    UTF8;
    PKCS7_WITH_TYPE_INFO;
    CODE_POINTER;
    DATETIME_UTC;

    // End of winmeta outtypes.
    // Start of TDH outtypes for WBEM.

    REDUCEDSTRING :: 300;
    NOPRINT;
};

// #define TDH_OUTYTPE_ERRORCODE TDH_OUTTYPE_ERRORCODE // ?

PROPERTY_FLAGS :: enum_flags s32 {
   Struct           :: 0x1;  // Type is struct.
   ParamLength      :: 0x2;  // Length field is index of param with length.
   ParamCount       :: 0x4;  // Count field is index of param with count.
   WBEMXmlFragment  :: 0x8;  // WBEM extension flag for property.
   ParamFixedLength :: 0x10; // Length of the parameter is fixed.
   ParamFixedCount  :: 0x20; // Count of the parameter is fixed.
   HasTags          :: 0x40; // The Tags field has been initialized.
   HasCustomSchema  :: 0x80; // Type is described with a custom schema.
}

EVENT_PROPERTY_INFO :: struct {
    Flags: PROPERTY_FLAGS;
    NameOffset: u32;
    union {
        nonStructType: struct {
            InType: u16;
            OutType: u16;
            MapNameOffset: u32;
        }
        structType: struct {
            StructStartIndex: u16;
            NumOfStructMembers: u16;
            padding: u32;
        }
        customSchemaType: struct {
            // Data of this field is described by a user-defined serialization protocol such as Bond or Protocol Buffers. InType and OutType
            // should be set for best-effort decoding by decoders that do not understand the schema, e.g. InType could be set to
            // TDH_INTYPE_BINARY so that a decoder can properly extract or skip the raw serialized data even if it can't parse it. The
            // CustomSchemaOffset points at a structure laid out as:
            // UINT16 Protocol; // User-defined value from 5..31
            // UINT16 Length;
            // BYTE SchemaData[Length];
            InType: u16;
            OutType: u16;
            CustomSchemaOffset: u32;
        }
    }
    union {
        count: u16;
        countPropertyIndex: u16;
    }
    union {
        length: u16;
        lengthPropertyIndex: u16;
    }
    union {
        Reserved: u32;
        struct {
            Tags: u32; // Low 28 bits.
        }
    }
}

DECODING_SOURCE :: enum s32 {
    XMLFile;
    Wbem;
    WPP;
    Tlg;
    Max;
}

TEMPLATE_FLAGS :: enum s32 {
    EVENT_DATA   :: 1; // Used when custom xml is not specified.
    USER_DATA    :: 2; // Used when custom xml is specified.
    CONTROL_GUID :: 4; // EventGuid contains the manifest control GUID.
}

// @CommentsRemoved
TRACE_EVENT_INFO :: struct {
    ProviderGuid: GUID;
    EventGuid: GUID;
    EventDescriptor: EVENT_DESCRIPTOR;
    DecodingSource: DECODING_SOURCE;
    ProviderNameOffset: u32;
    LevelNameOffset: u32;
    ChannelNameOffset: u32;
    KeywordsNameOffset: u32;
    TaskNameOffset: u32;
    OpcodeNameOffset: u32;
    EventMessageOffset: u32;
    ProviderMessageOffset: u32;
    BinaryXMLOffset: u32;
    BinaryXMLSize: u32;

    union {
        EventNameOffset: u32;
        ActivityIDNameOffset: u32;
    }

    union {
        EventAttributesOffset: u32;
        RelatedActivityIDNameOffset: u32;
    };

    PropertyCount: u32;
    TopLevelPropertyCount: u32; // Range == [0, PropertyCount]
    union {
        Flags: TEMPLATE_FLAGS;
        struct {
            // u32 Reserved : 4; // TEMPLATE_FLAGS values
            // u32 Tags : 28;
            ReservedAndTags: u32; // Low 4 bits "Reserved", high 28 bits "Tags"
        };
    }
    EventPropertyInfoArray: [ANYSIZE_ARRAY] EVENT_PROPERTY_INFO; // Size == PropertyCount
}

PROPERTY_DATA_DESCRIPTOR :: struct {
    PropertyName: u64; // Pointer to property name.
    ArrayIndex: u32;   // Array Index.
    Reserved: u32;
}

//
// ETW Payload Filtering Tdh support
//

//
// Payload filtering definitions
//

//
// TDH_PAYLOADFIELD_OPERATORs are used to build Payload filters.
//
//    BETWEEN uses a closed interval: [LowerBound <= FieldValue <= UpperBound].
//    Floating-point comparisons are not supported.
//    String comparisons are case-sensitive.
//    Values are converted based on the manifest field type.
//

PAYLOAD_OPERATOR :: enum s32 {
    // For integers, comparison can be one of:
    EQ :: 0;
    NE :: 1;
    LE :: 2;
    GT :: 3;
    LT :: 4;
    GE :: 5;
    BETWEEN :: 6;    // Two values: lower/upper bounds
    NOTBETWEEN :: 7; // Two values: lower/upper bounds
    MODULO :: 8;     // For periodically sampling a field

    // For strings:
    CONTAINS      :: 20; // Substring identical to Value
    DOESNTCONTAIN :: 21; // No substring identical to Value

    // For strings or other non-integer values
    IS    :: 30;         // Field is identical to Value
    ISNOT :: 31;         // Field is NOT identical to Value
    INVALID :: 32;
}

PAYLOAD_FILTER_PREDICATE :: struct {
    FieldName: *u16;
    CompareOp: u16;  // PAYLOAD_OPERATOR
    Value: *u16;     // One or two values (i.e., two for BETWEEN operations)
}

MAX_PAYLOAD_PREDICATES :: 8;

TdhCreatePayloadFilter :: (ProviderGuid: *GUID, EventDescriptor: *EVENT_DESCRIPTOR, EventMatchANY: BOOLEAN, PayloadPredicateCount: u32, PayloadPredicates: *PAYLOAD_FILTER_PREDICATE, PayloadFilter: **void) -> TDHSTATUS #foreign tdh;
TdhDeletePayloadFilter :: (PayloadFilter: **void) -> TDHSTATUS #foreign tdh;
TdhAggregatePayloadFilters :: (PayloadFilterCount: u32, PayloadFilterPtrs: **void, EventMatchALLFlags: *BOOLEAN, EventFilterDescriptor: *EVENT_FILTER_DESCRIPTOR) -> TDHSTATUS #foreign tdh;
TdhCleanupPayloadEventFilterDescriptor :: (EventFilterDescriptor: *EVENT_FILTER_DESCRIPTOR) -> TDHSTATUS #foreign tdh;

//
// Provider-side filters.
//

PROVIDER_FILTER_INFO :: struct {
    Id: u8;
    Version: u8;
    MessageOffset: u32;
    Reserved: u32;
    PropertyCount: u32;
    EventPropertyInfoArray: [ANYSIZE_ARRAY] EVENT_PROPERTY_INFO; // Size == PropertyCount
}

// Provider Enumeration.

EVENT_FIELD_TYPE :: enum s32 {
    EventKeywordInformation :: 0;
    EventLevelInformation;
    EventChannelInformation;
    EventTaskInformation;
    EventOpcodeInformation;
    EventInformationMax;
}

PROVIDER_FIELD_INFO :: struct {
    NameOffset: u32;                  // English only.
    DescriptionOffset: u32;           // Localizable String.
    Value: u64;
}

PROVIDER_FIELD_INFOARRAY :: struct {
    NumberOfElements:  u32;
    FieldType: EVENT_FIELD_TYPE;
    FieldInfoArray: [ANYSIZE_ARRAY] PROVIDER_FIELD_INFO;
}

TRACE_PROVIDER_INFO :: struct {
    ProviderGuid: GUID;
    SchemaSource: u32;
    ProviderNameOffset: u32;
}

PROVIDER_ENUMERATION_INFO :: struct {
    NumberOfProviders: u32;
    Reserved: u32;
    TraceProviderInfoArray: [ANYSIZE_ARRAY] TRACE_PROVIDER_INFO; // Size == NumberOfProviders
}

PROVIDER_EVENT_INFO :: struct {
    NumberOfEvents: u32;
    Reserved: u32;
    EventDescriptorsArray: [ANYSIZE_ARRAY] EVENT_DESCRIPTOR; // Size == NumberOfEvents
}

TDH_CONTEXT_TYPE :: enum s32 {
    WPP_TMFFILE;       // LPCWSTR path to the TMF file for a WPP event.
    WPP_TMFSEARCHPATH; // LPCWSTR semicolon-separated list of directories to search for the TMF file for a WPP event. Only files with the name [ProviderId].TMF will be found during the search.
    WPP_GMT;           // Integer value. If set to 1, the TdhGetWppProperty and TdhGetWppMessage functions will format a event's timestamp in UTC (GMT). By default, the timestamp is formatted in local time.
    POINTERSIZE;       // Integer value, set to 4 or 8. Used when decoding POINTER or SIZE_T fields on WPP events that do not set a pointer size in the event header. If the event does not set a pointer size in the event header and this is not set, the decoder will use the pointer size of the current process.
    PDB_PATH;          // LPCWSTR semicolon-separated list of PDB files to be search for decoding information when decoding an event using TdhGetWppProperty or TdhGetWppMessage. (Not used by TdhGetProperty or TdhGetEventInformation.)
    MAXIMUM;
}

/*
Decoding configuration parameters used with TdhGetDecodingParameter,
TdhSetDecodingParameter, TdhGetEventInformation, TdhGetProperty,
TdhGetPropertySize, and TdhEnumerateProviderFilters.

Note that the TDH_CONTEXT_WPP_GMT and TDH_CONTEXT_PDB_PATH parameter types are
only used by TdhGetDecodingParameter and TdhSetDecodingParameter. They are
ignored by TdhGetEventInformation and TdhGetProperty.
*/
TDH_CONTEXT :: struct {
    ParameterValue: u64; // For GMT or POINTERSIZE, directly stores the parameter's integer value. For other types, stores an LPCWSTR pointing to a nul-terminated string with the parameter value.
    ParameterType: TDH_CONTEXT_TYPE;
    ParameterSize: u32; // Reserved. Set to 0.
}

TdhGetEventInformation :: (Event: *EVENT_RECORD, TdhContextCount: u32, TdhContext: *TDH_CONTEXT, Buffer: *TRACE_EVENT_INFO, BufferSize: *u32) -> TDHSTATUS #foreign tdh;

TdhGetEventMapInformation :: (pEvent: *EVENT_RECORD, pMapName: *u16, pBuffer: *EVENT_MAP_INFO, pBufferSize: *u32) -> TDHSTATUS #foreign tdh;
TdhGetPropertySize :: (pEvent: *EVENT_RECORD, TdhContextCount: u32, pTdhContext: *TDH_CONTEXT, PropertyDataCount: u32, pPropertyData: *PROPERTY_DATA_DESCRIPTOR, pPropertySize: *u32) -> TDHSTATUS #foreign tdh;
TdhGetProperty :: (pEvent: *EVENT_RECORD, TdhContextCount: u32, pTdhContext: *TDH_CONTEXT, PropertyDataCount: u32, pPropertyData: *PROPERTY_DATA_DESCRIPTOR, BufferSize: u32, pBuffer: *u8) -> TDHSTATUS #foreign tdh;
TdhEnumerateProviders :: (pBuffer: PROVIDER_ENUMERATION_INFO, pBufferSize: *u32) -> TDHSTATUS #foreign tdh;
// TdhEnumerateProvidersForDecodingSource :: (filter: DECODING_SOURCE, buffer: *PROVIDER_ENUMERATION_INFO, bufferSize: u32, bufferRequired: *u32) -> TDHSTATUS #foreign tdh;
TdhQueryProviderFieldInformation :: (pGuid: *GUID, EventFieldValue: u64, EventFieldType: EVENT_FIELD_TYPE, pBuffer: *PROVIDER_FIELD_INFOARRAY, pBufferSize: *u32) -> TDHSTATUS #foreign tdh;
TdhEnumerateProviderFieldInformation :: (pGuid: *GUID, EventFieldType: EVENT_FIELD_TYPE, pBuffer: *PROVIDER_FIELD_INFOARRAY, pBufferSize: *u32) -> TDHSTATUS #foreign tdh;
TdhEnumerateProviderFilters :: (Guid: *GUID, TdhContextCount: u32, TdhContext: *TDH_CONTEXT, FilterCount: *u32, Buffer: **PROVIDER_FILTER_INFO, BufferSize: *u32) -> TDHSTATUS #foreign tdh;
TdhLoadManifest :: (Manifest: *u16) -> TDHSTATUS #foreign tdh;
TdhLoadManifestFromMemory :: (pData: *void, cbData: u32) -> TDHSTATUS #foreign tdh;
TdhUnloadManifest :: (Manifest: *u16) -> TDHSTATUS #foreign tdh;
TdhUnloadManifestFromMemory :: (pData: *void, cbData: u32) -> TDHSTATUS #foreign tdh;
TdhFormatProperty :: (EventInfo: *TRACE_EVENT_INFO, MapInfo: *EVENT_MAP_INFO, PointerSize: u32, PropertyInType: u16, PropertyOutType: u16, PropertyLength: u16, UserDataLength: u16, UserData: *u8, BufferSize: *u32, Buffer: *u16, UserDataConsumed: *u16) -> TDHSTATUS #foreign tdh;

TdhOpenDecodingHandle :: (Handle: *TDH_HANDLE) -> TDHSTATUS #foreign tdh;
TdhSetDecodingParameter :: (Handle: TDH_HANDLE, TdhContext: *TDH_CONTEXT) -> TDHSTATUS #foreign tdh;
TdhGetDecodingParameter :: (Handle: TDH_HANDLE, TdhContext: *TDH_CONTEXT) -> TDHSTATUS #foreign tdh;
TdhGetWppProperty :: (Handle: TDH_HANDLE, EventRecord: *EVENT_RECORD, PropertyName: *u16, BufferSize: *u32, Buffer: *u8) -> TDHSTATUS #foreign tdh;
TdhGetWppMessage :: (Handle: TDH_HANDLE, EventRecord: *EVENT_RECORD, BufferSize: *u32, Buffer: *u8) -> TDHSTATUS #foreign tdh;
TdhCloseDecodingHandle :: (Handle: TDH_HANDLE) -> TDHSTATUS #foreign tdh;
TdhLoadManifestFromBinary :: (BinaryPath: *u16) -> TDHSTATUS #foreign tdh;
TdhEnumerateManifestProviderEvents :: (ProviderGuid: *GUID, Buffer: *PROVIDER_EVENT_INFO, BufferSize: *u32) -> TDHSTATUS #foreign tdh;
TdhGetManifestEventInformation :: (ProviderGuid: *GUID, EventDescriptor: *EVENT_DESCRIPTOR, Buffer: *TRACE_EVENT_INFO, BufferSize: *u32) -> TDHSTATUS #foreign tdh;

//
//  Helper macros to access strings from variable length Tdh structures.
//
// NOTE(Charles): I've directly ported (some of) these macros. But we could do better jai things really.

EMI_MAP_NAME :: (MapInfo: *EVENT_MAP_INFO) -> *u16 #expand {
    return ifx MapInfo.NameOffset then cast(*u16)(cast(*u8) MapInfo + MapInfo.NameOffset) else null;
}

/*
PWSTR EMI_MAP_FORMAT(PEVENT_MAP_INFO MapInfo) {
    if ((MapInfo.Flag & EVENTMAP_INFO_FLAG_MANIFEST_PATTERNMAP) && (MapInfo.FormatStringOffset)) {
        return (PWSTR)((PBYTE)MapInfo + MapInfo.FormatStringOffset);
    } else {
        return null;
    }
}

PWSTR EMI_MAP_OUTPUT(PEVENT_MAP_INFO MapInfo, PEVENT_MAP_ENTRY Map) {
    return (Map.OutputOffset == 0) ? null : (PWSTR)((PBYTE)MapInfo + Map.OutputOffset);
}

PWSTR EMI_MAP_INPUT(PEVENT_MAP_INFO MapInfo, PEVENT_MAP_ENTRY Map) {
    if ((MapInfo.Flag & EVENTMAP_INFO_FLAG_MANIFEST_PATTERNMAP) && (Map.InputOffset != 0)) {
        return (PWSTR)((PBYTE)MapInfo + Map.InputOffset);
    } else {
        return null;
    }
}
*/

TEI_MAP_NAME :: (EventInfo: *TRACE_EVENT_INFO, Property: *EVENT_PROPERTY_INFO) -> *u16 #expand {
    return ifx Property.nonStructType.MapNameOffset then cast(*u16) (cast(*u8) EventInfo + Property.nonStructType.MapNameOffset) else null;
}

TEI_PROPERTY_NAME :: (EventInfo: *TRACE_EVENT_INFO, Property: *EVENT_PROPERTY_INFO) -> *u16 #expand {
    return ifx Property.NameOffset then cast(*u16) (cast(*u8) EventInfo + Property.NameOffset) else null;
}

TEI_PROVIDER_NAME :: (EventInfo: *TRACE_EVENT_INFO) -> *u16 #expand {
    return ifx EventInfo.ProviderNameOffset then cast(*u16) (cast(*u8) EventInfo + EventInfo.ProviderNameOffset) else null;
}

TEI_LEVEL_NAME :: (EventInfo: *TRACE_EVENT_INFO) -> *u16 #expand {
    return ifx EventInfo.LevelNameOffset then cast(*u16) (cast(*u8) EventInfo + EventInfo.LevelNameOffset) else null;
}

TEI_CHANNEL_NAME :: (EventInfo: *TRACE_EVENT_INFO) -> *u16 #expand {
    return ifx EventInfo.ChannelNameOffset then cast(*u16) (cast(*u8) EventInfo + EventInfo.ChannelNameOffset) else null;
}

TEI_KEYWORDS_NAME :: (EventInfo: *TRACE_EVENT_INFO) -> *u16 #expand {
    return ifx EventInfo.KeywordsNameOffset then cast(*u16) (cast(*u8) EventInfo + EventInfo.KeywordsNameOffset) else null;
}

TEI_TASK_NAME :: (EventInfo: *TRACE_EVENT_INFO) -> *u16 #expand {
    return ifx EventInfo.TaskNameOffset then cast(*u16) (cast(*u8) EventInfo + EventInfo.TaskNameOffset) else null;
}

TEI_OPCODE_NAME :: (EventInfo: *TRACE_EVENT_INFO) -> *u16 #expand {
    return ifx EventInfo.OpcodeNameOffset then cast(*u16) (cast(*u8) EventInfo + EventInfo.OpcodeNameOffset) else null;
}

TEI_EVENT_MESSAGE :: (EventInfo: *TRACE_EVENT_INFO) -> *u16 #expand {
    return ifx EventInfo.EventMessageOffset then cast(*u16) (cast(*u8) EventInfo + EventInfo.EventMessageOffset) else null;
}

TEI_PROVIDER_MESSAGE :: (EventInfo: *TRACE_EVENT_INFO) -> *u16 #expand {
    return ifx EventInfo.ProviderMessageOffset then cast(*u16) (cast(*u8) EventInfo + EventInfo.ProviderMessageOffset) else null;
}

TEI_ACTIVITYID_NAME :: (EventInfo: *TRACE_EVENT_INFO) -> *u16 #expand {
    return ifx EventInfo.ActivityIDNameOffset then cast(*u16) (cast(*u8) EventInfo + EventInfo.ActivityIDNameOffset) else null;
}

TEI_RELATEDACTIVITYID_NAME :: (EventInfo: *TRACE_EVENT_INFO) -> *u16 #expand {
    return ifx EventInfo.RelatedActivityIDNameOffset then cast(*u16) (cast(*u8) EventInfo + EventInfo.RelatedActivityIDNameOffset) else null;
}

/*
PWSTR PFI_FILTER_MESSAGE(PPROVIDER_FILTER_INFO FilterInfo) {
    return (FilterInfo.MessageOffset == 0) ? null : (PWSTR)((PBYTE)FilterInfo + FilterInfo.MessageOffset);
}

PWSTR PFI_PROPERTY_NAME(PPROVIDER_FILTER_INFO FilterInfo, PEVENT_PROPERTY_INFO Property) {
    return (Property.NameOffset == 0) ? null : (PWSTR)((PBYTE)FilterInfo + Property.NameOffset);
}

PWSTR PFI_FIELD_NAME(PPROVIDER_FIELD_INFOARRAY FieldInfoArray, PPROVIDER_FIELD_INFO FieldInfo) {
    return (FieldInfo.NameOffset == 0) ? null : (PWSTR)((PBYTE)FieldInfoArray + FieldInfo.NameOffset);
}

PWSTR PFI_FIELD_MESSAGE(PPROVIDER_FIELD_INFOARRAY FieldInfoArray, PPROVIDER_FIELD_INFO FieldInfo) {
    return (FieldInfo.DescriptionOffset == 0) ? null : (PWSTR)((PBYTE)FieldInfoArray + FieldInfo.DescriptionOffset);
}

PWSTR PEI_PROVIDER_NAME(PPROVIDER_ENUMERATION_INFO ProviderEnum, PTRACE_PROVIDER_INFO ProviderInfo) {
    return (ProviderInfo.ProviderNameOffset == 0) ? null : (PWSTR)((PBYTE)ProviderEnum + ProviderInfo.ProviderNameOffset);
}
*/

#scope_file

tdh :: #system_library "tdh";
