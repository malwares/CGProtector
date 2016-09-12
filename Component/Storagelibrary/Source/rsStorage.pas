{*******************************************************}
{                                                       }
{                Delphi VCL Extensions                  }
{                   Storage library                     }
{                                                       }
{         Copyright (c) 2000-2007 Deepsoftware          }
{                                                       }
{           www - http://www.deepsoftware.com           }
{              email - ray@deepsoftware.com             }
{                                                       }
{*******************************************************}
unit rsStorage;

interface

{$I rsStorage.inc}

uses Classes, SysUtils, SyncObjs,
     {$IFDEF RSL_WIN}
       Windows, ShlObj,
     {$ELSE}
       {$IFNDEF RSL_REALKYLIX}Windows, ShellAPI,{$ENDIF}
     {$ENDIF}
     {$IFDEF RSL_KYLIX}Types,{$ENDIF}
     {$IFDEF RSL_D6GE}Variants,{$ENDIF}
     {$IFDEF RSL_TRIAL}
       {$IFDEF RSL_WIN}Dialogs, ShellApi,{$ENDIF}
     {$ENDIF}
     rsConst;

Const
  cMaxItemCount = 16384;

  kvtUnknown  = $0000;
  kvtString   = $0001;
  kvtBuffer   = $0002;
  kvtInteger  = $0003;
  kvtDouble   = $0004;
  kvtCurrency = $0005;
  kvtDateTime = $0006;
  kvtBool     = $0007;
  kvtPoint    = $0008;
{$IFDEF RSL_INT64}
  kvtInt64    = $0009;
{$ENDIF}
  kvtPointer  = $000A;
  kvtLastIndex= $000B; // using in DecryptKey for catching errors

Const
//errors
  SErrGetKeyValue = 'Can''t read value of key "%s" as %s type.';
  SErrSetKeyValue = 'Can''t write value of key "%s" as %s type.';

{$IFDEF RSL_CB3}
var
  CSectionSeparators: set of char = ['\','/'];
{$ELSE}
  CSectionSeparators = ['\','/'];
{$ENDIF}

type
  TrsStorage = class;

  TrsSectionItem = record
    Name: RSLString;
    Id: integer;
    ParentId: integer;
  end;
  PrsSectionItem = ^TrsSectionItem;

  TrsSectionItemList = array[0..cMaxItemCount-1] of TrsSectionItem;
  PrsSectionItemList = ^TrsSectionItemList;


  PrsKeyValue = ^TrsKeyValue;
  TrsKeyValue = record
    Options: word;
    case kvType:word of
     kvtInteger:  (VInteger: integer);
     kvtDouble:   (VDouble: double);
     kvtCurrency: (VCurrency: currency);
     kvtDateTime: (VDateTime: TDateTime);
     kvtBool:     (VBoolean: LongBool);
     kvtUnknown:  (VUnknown: Pointer);
     kvtPoint:    (X,Y: Longint);
{$IFDEF RSL_INT64}
     kvtInt64:    (VInt64: Int64);
{$ENDIF}
     kvtString:   (VString: Pointer);
     kvtBuffer:   (VBuffer: Pointer);  //ansistring
     kvtPointer:  (VPointer: Pointer); // rslstring
  end;
{$IFNDEF RSL_D3}
  {$EXTERNALSYM TrsKeyValue}

  (*$HPPEMIT '#pragma pack(push, 4)' *)
  (*$HPPEMIT 'struct TrsKeyValue' *)
  (*$HPPEMIT '{' *)
  (*$HPPEMIT ' Word Options;' *)
  (*$HPPEMIT ' Word kvType;' *)
  (*$HPPEMIT ' union' *)
  (*$HPPEMIT '  {' *)
  (*$HPPEMIT '   void *VPointer;' *)
  (*$HPPEMIT '   void *VBuffer;' *)
  (*$HPPEMIT '   void *VString;' *)
  (*$HPPEMIT '   struct { LONG X; LONG Y; };' *)
  (*$HPPEMIT '   void *VUnknown;' *)
  (*$HPPEMIT '   BOOL VBoolean;' *)
  (*$HPPEMIT '   System::TDateTimeBase VDateTime;' *)
  (*$HPPEMIT '   System::CurrencyBase VCurrency;' *)
  (*$HPPEMIT '   double VDouble;' *)
{$IFDEF RSL_INT64}
  (*$HPPEMIT '   __int64 VInt64;' *)
{$ENDIF}
  (*$HPPEMIT '   int VInteger;' *)
  (*$HPPEMIT '   };' *)
  (*$HPPEMIT '};' *)
  (*$HPPEMIT '#pragma pack(pop)' *)
{$ENDIF}

  TrsKeyItem = record
    Name: RSLString;
    SectionId: integer;
    Value: TrsKeyValue;
  end;
  PrsKeyItem = ^TrsKeyItem;

  TrsKeyValueList = array[0..cMaxItemCount-1] of TrsKeyValue;
  PrsKeyValueList = ^TrsKeyValueList;

  TrsKeyItemList = array[0..cMaxItemCount-1] of TrsKeyItem;
  PrsKeyItemList = ^TrsKeyItemList;


  TrsStorageOption = (soSaveOnClose, soSaveEmptySection);
  TrsStorageOptions = set of TrsStorageOption;

  TrsIniCompactOption = (coHexStr);
  TrsIniCompactOptions = set of TrsIniCompactOption;


  TrsKeyWrapper = class
  private
    FStorage: TrsStorage;
    FCacheSectionIdx: integer;
    FMemStream: TMemoryStream;
    function GetKeyType: word;
    procedure SetKeyType(const Value: word);
    function GetKeyOptions: word;
    procedure SetKeyOptions(const Value: word);
    function GetName: RSLString;
    function GetSectionName: RSLString;
    function GetSectionFullName: RSLString;
    function GetSectionLevel: integer;
    function GetFullName: RSLString;
  protected
    procedure TempClassesActive(const Value: boolean);
    function SectionIndex: integer;

    function GetAsBoolean: boolean;
    function GetAsCurrency: Currency;
    function GetAsDateTime: TDateTime;
    function GetAsFloat: Double;
    {$IFDEF RSL_INT64}
    function GetAsInt64: Int64;
    {$ENDIF}
    function GetAsInteger: integer;
    function GetAsPoint: TPoint;
    function GetAsPointer: Pointer; //25.01.02
    function GetAsString: RSLString;
    function GetAsVariant: Variant;

    procedure SetAsBoolean(const Value: boolean);
    procedure SetAsCurrency(const Value: currency);
    procedure SetAsDateTime(const Value: TDateTime);
    procedure SetAsFloat(const Value: Double);
    {$IFDEF RSL_INT64}
    procedure SetAsInt64(const Value: Int64);
    {$ENDIF}
    procedure SetAsInteger(const Value: integer);
    procedure SetAsPoint(const Value: TPoint);
    procedure SetAsPointer(const Value: Pointer); //25.01.02
    procedure SetAsString(const Value: RSLString);
    procedure SetAsVariant(const Value: Variant);

  public
    PKeyItem: PrsKeyItem;

    constructor Create(AOwner: TrsStorage);
    destructor Destroy; override;
    procedure Clear;
    procedure AssignValueTo(PKey: PrsKeyValue);
    procedure AssignValue(PKey: PrsKeyValue);
    function EqualValue(PKey: PrsKeyValue): boolean;

    function GetAsArray(var Values: Variant): integer; //21.01.02
    function GetAsBuffer(var Buffer; const Count: Longint): Longint;
    function GetAsStream(Stream: TStream): integer;
    procedure GetComponentProps(Instance: TComponent);
    function GetPersistentProps(Instance: TPersistent): boolean;

    procedure SetAsArray(const Values: variant); //21.01.02
    procedure SetAsBuffer(const Buffer; const Count: Longint);
    procedure SetAsStream(Stream: TStream);
    function SetComponentProps(Instance: TComponent): TComponent;
    function SetPersistentProps(Instance: TPersistent): boolean;

    property AsBoolean: boolean read GetAsBoolean write SetAsBoolean;
    property AsCurrency: currency read GetAsCurrency write SetAsCurrency;
    property AsDateTime: TDateTime read GetAsDateTime write SetAsDateTime;
    property AsFloat: Double read GetAsFloat write SetAsFloat;
    {$IFDEF RSL_INT64}
    property AsInt64: Int64 read GetAsInt64 write SetAsInt64;
    {$ENDIF}
    property AsInteger: Integer read GetAsInteger write SetAsInteger;
    property AsPoint: TPoint read GetAsPoint write SetAsPoint;
    property AsPointer: Pointer read GetAsPointer write SetAsPointer;
    property AsString: RSLString read GetAsString write SetAsString;
    property AsVariant: Variant read GetAsVariant write SetAsVariant;

    property KeyType: word read GetKeyType write SetKeyType;
    property KeyOptions: word read GetKeyOptions write SetKeyOptions;
    property Name: RSLString read GetName;
    property FullName: RSLString read GetFullName;
    property SectionName: RSLString read GetSectionName;
    property SectionFullName: RSLString read GetSectionFullName;
    property SectionLevel: integer read GetSectionLevel;
    property Storage: TrsStorage read FStorage write FStorage;
  end;

  TrsSectionWrapper = class
  private
    FStorage: TrsStorage;
    FSectionIndex: integer;
    function GetId: integer;
    function GetName: RSLString;
    function GetParentId: integer;
    function GetFullName: RSLString;
    procedure SetSectionIndex(const Value: integer);
    function GetLevel: integer;
  protected
    PSectionItem: PrsSectionItem;
    property SectionIndex: integer read FSectionIndex write SetSectionIndex;
  public
    constructor Create(AOwner: TrsStorage);
    destructor Destroy; override;

    property Name: RSLString read GetName;
    property FullName: RSLString read GetFullName;
    property Level: integer read GetLevel;
    property Id: integer read GetId;
    property ParentId: integer read GetParentId;
  end;


  TrsStorageDataProgressEvent = procedure (Sender: TObject; Percent: integer) of object;

  TrsStorageData = class(TComponent)
  private
    FStorageList: TList;
    FCurrentStorageIdx: integer;
    FOnBeforeSave: TNotifyEvent;
    FOnAfterLoad: TNotifyEvent;
    FOnAfterSave: TNotifyEvent;
    FOnBeforeLoad: TNotifyEvent;
    FOnProgress: TrsStorageDataProgressEvent;
    FPreviousPercent: integer;
    procedure SetStorage(AStorage: TrsStorage);
    procedure UnlinkStorage(AStorage: TrsStorage);
    function GetStorage: TrsStorage;
  protected
    ProgressItemCount: integer;
    ProgressItemCurrent: integer;
    procedure DoProgress; virtual;
    procedure InternalLoad; virtual;
    procedure InternalSave; virtual;
    procedure Notification(AComponent: TComponent; Operation: TOperation); override;

    procedure Load;
    procedure Save;
  public
    constructor Create(AOwner: TComponent); override;
    destructor Destroy; override;
    property Storage: TrsStorage read GetStorage;
  published
    property OnAfterLoad: TNotifyEvent read FOnAfterLoad write FOnAfterLoad;
    property OnAfterSave: TNotifyEvent read FOnAfterSave write FOnAfterSave;
    property OnBeforeLoad: TNotifyEvent read FOnBeforeLoad write FOnBeforeLoad;
    property OnBeforeSave: TNotifyEvent read FOnBeforeSave write FOnBeforeSave;
    property OnProgress: TrsStorageDataProgressEvent read FOnProgress write FOnProgress;
  end;


  TrsStreamEvent = procedure (Sender: TObject; Stream: TStream; var DoStandard: boolean) of object;

  TrsStreamDataOption = (doAutoName,doAutoCreateDir);
  TrsStreamDataOptions = set of TrsStreamDataOption;
  TrsStreamFileDir = (fdCustom, fdApplication {$IFDEF RSL_WIN}, fdWindows, fdUserProfile{$ENDIF});

  TrsInternalFileLoad = (iflNone, iflAlways, iflNoRealFile);

  TrsStreamData = class(TrsStorageData)
  private
    FInternalFile: TMemoryStream;
    FFileName: string;
    FOptions: TrsStreamDataOptions;
    FOnLoadFromStream: TrsStreamEvent;
    FOnSaveToStream: TrsStreamEvent;
    FStream: TMemoryStream;
    FFileDir: TrsStreamFileDir;
{$IFDEF RSL_UNICODE}
    FUnicode: boolean;
{$ENDIF}
    FInternalFileName: string;
    FInternalFileLoad: TrsInternalFileLoad;
    procedure SetFileDir(const Value: TrsStreamFileDir);
    procedure SetOptions(const Value: TrsStreamDataOptions);
    procedure SetFileName(const Value: string);
    procedure SetInternalFileName(const Value: string);
  protected
    Buffer: array[1..CRSBufferSize] of AnsiChar;
    BufferStart: integer;
    FExtension: string;
    FHexStrSeparator: string;
    FCurStream: TStream;
    procedure BufferClear;
    procedure BufferFlush;
    procedure BufferWrite(const Buf; Count: Longint);
    procedure BufferWriteFmt(const MaxLength: integer; const Fmt: string; const Args: array of const);
    procedure BufferWriteStr(const Value: string);
    procedure BufferWriteEOL;
{$IFDEF RSL_UNICODE}
    procedure BufferWriteStrW(const Value: RSLString);
    procedure BufferWriteCharW(const Value: RSLChar);
    procedure BufferWriteCharsW(const Values: array of RSLChar);
    property Unicode: boolean read FUnicode write FUnicode default False;
{$ENDIF}
    procedure BufferWriteStrA(const Value: AnsiString);
    procedure BufferWriteFmtA(const MaxLength: integer; const Fmt: AnsiString; const Args: array of const);

    procedure CheckCreateDirs(const Value: string);
    function GetFileName: string;
    procedure InternalLoad; override;
    procedure InternalSave; override;
    procedure LoadFromStream(Stream: TStream); virtual;
    procedure SaveToStream(Stream: TStream); virtual;
    procedure DefineProperties(Filer: TFiler); override;
    procedure ReadData(Stream: TStream);
    procedure WriteData(Stream: TStream);
  public
    constructor Create(AOwner: TComponent); override;
    destructor Destroy; override;
    property FileDir: TrsStreamFileDir read FFileDir write SetFileDir default fdApplication;
    property FileName: string read FFileName write SetFileName;
    property FullFileName: string read GetFileName;
    property InternalFile: TMemoryStream read FInternalFile;
    property InternalFileName: string read FInternalFileName write SetInternalFileName;
    property InternalFileLoad: TrsInternalFileLoad read FInternalFileLoad write FInternalFileLoad default iflNone;
    property Options: TrsStreamDataOptions read FOptions write SetOptions default [doAutoName];
    property OnLoadFromStream: TrsStreamEvent read FOnLoadFromStream write FOnLoadFromStream;
    property OnSaveToStream: TrsStreamEvent read FOnSaveToStream write FOnSaveToStream;
  end;

  TrsClientNotification = (scnNone, scnClear, scnLoad,
                           scnSectionAdd, scnSectionDelete, scnSectionModify, scnSectionClear,
                           scnRootSectionChanged, scnKeyAdd, scnKeyDelete, scnKeyModify,
                           scnKeyValueModify);
  TrsClientNotifications = set of TrsClientNotification;

  TrsStorageClient = class(TComponent)
  private
  protected
    FActive: Boolean;
    FNotifications: TrsClientNotifications;
    FStorage: TrsStorage;
    procedure SetActive(const Value: Boolean); virtual;
    procedure SetStorage(const Value: TrsStorage); virtual;
    procedure Notification(AComponent: TComponent; Operation: TOperation); override;
    procedure rsNotification(const Value: TrsClientNotification; WParam, LParam: Longint); virtual;
  public
    constructor Create(AOwner: TComponent); override;
    property Active: Boolean read FActive write SetActive default True;
    property Storage: TrsStorage read FStorage write SetStorage;
  end;

  TrsClientItemData = array [0..cMaxItemCount-1] of Pointer;
  PrsClientItemData = ^TrsClientItemData;

  TrsClientItem = record
    Exists: boolean;
    Count: integer;
    Capacity: integer;
    Data: PrsClientItemData;
  end;
{$IFNDEF RSL_D3}
  {$EXTERNALSYM TrsClientItem}

  (*$HPPEMIT '#pragma pack(push, 4)' *)
  (*$HPPEMIT 'struct TrsClientItem' *)
  (*$HPPEMIT '{' *)
  (*$HPPEMIT ' bool Exists;' *)
  (*$HPPEMIT ' int Count;' *)
  (*$HPPEMIT ' int Capacity;' *)
  (*$HPPEMIT ' void * *Data;' *)
  (*$HPPEMIT '};' *)
  (*$HPPEMIT '#pragma pack(pop)' *)
{$ENDIF}

  PrsClientItem = ^TrsClientItem;

  TrsClientList = class
  private
    FList: TList;
    FItems: array [Low(TrsClientNotification)..High(TrsClientNotification)] of TrsClientItem;
    FActive: boolean;
    function GetClient(Index: integer): TrsStorageClient;
  protected
    procedure AddToArray(Cn: TrsClientNotification; Instance: TrsStorageClient);
    procedure DeleteFromArray(Cn: TrsClientNotification; Instance: TrsStorageClient);
  public
    constructor Create;
    destructor Destroy; override;
    procedure Clear;
    function Add(Instance: TrsStorageClient): integer;
    function IndexOf(Instance: TrsStorageClient): integer;
    procedure Remove(Instance: TrsStorageClient);
    procedure Delete(Index: integer);
    function Count: integer;
    function NotificationExist(const Value: TrsClientNotification): boolean;
    procedure DoNotification(const Value: TrsClientNotification; WParam,LParam: Longint);
    property Clients[Index: integer]: TrsStorageClient read GetClient;
    property Active: boolean read FActive write FActive default True;
  end;

  TrsEncryptor = class(TComponent)
  private
    FActive: boolean;
    FEncryptAll: boolean;
    FStorage: TrsStorage;
    FEncryptKeys: TStrings;
    FTempKeyType: Word;
    procedure SetStorage(AStorage: TrsStorage);
    procedure SetActive(const Value: boolean);
    procedure SetEncryptKeys(const Value: TStrings);
  protected
    procedure Notification(AComponent: TComponent; Operation: TOperation); override;

    function DecryptBuffer(PData: Pointer; Count: integer): integer; virtual;
    function EncryptBuffer(PData: Pointer; Count: integer): integer; virtual;
    function CalcDecryptBufferSize(const SourceCount: integer): integer; virtual;
    function CalcEncryptBufferSize(const SourceCount: integer): integer; virtual;
  public
    constructor Create(AOwner: TComponent); override;
    destructor Destroy; override;
    property Storage: TrsStorage read FStorage;

    procedure DoDecrypt; virtual;
    procedure DoDecryptAll; virtual;
    procedure DoDecryptKey(const Key: RSLString); virtual;
    procedure DoDecryptSection(const Section: RSLString); virtual;
    function GetDecryptedKey(const Key: RSLString): AnsiString; virtual;
    function GetDecryptedValue(const Value: String): String; virtual;

    procedure DoEncrypt; virtual;
    procedure DoEncryptAll; virtual;
    procedure DoEncryptKey(const Key: RSLString); virtual;
    procedure DoEncryptSection(const Section: RSLString); virtual;
    function GetEncryptedKey(const Key: RSLString): AnsiString; virtual;
    function GetEncryptedValue(const Value: String): String; virtual;
    function IsSameEncryptedKey(const Key, Value: RSLString): boolean; virtual;
  published
    property Active: boolean read FActive write SetActive default True;
    property EncryptKeys: TStrings read FEncryptKeys write SetEncryptKeys;
    property EncryptAll: boolean read FEncryptAll write FEncryptAll default False;
  end;

  TrsCompressor = class(TComponent)
  private
    FActive: boolean;
    FStorage: TrsStorage;
    procedure SetActive(const Value: boolean);
  protected
    procedure Notification(AComponent: TComponent; Operation: TOperation); override;
  public
    constructor Create(AOwner: TComponent); override;
    destructor Destroy; override;
    property Storage: TrsStorage read FStorage;

    procedure StreamComress(Source, Dest: TStream); virtual;
    procedure StreamDecompress(Source, Dest: TStream); virtual;
    function IsCompressed(Stream: TStream): boolean; virtual;
  published
    property Active: boolean read FActive write SetActive default True;
  end;

  TrsStorageState = (ssClearing, ssLoading, ssMerging, ssSaving, ssSavingChanges);
  TrsStorageStates = set of TrsStorageState;

  TrsStorageKeyEvent = procedure (Sender: TObject; const Key: RSLString) of object;

  TrsStorage = class(TComponent)
  private
    FActive: boolean;

    FCacheSectionName: RSLString; //one cell cache for SectionFind in KeyFindAddItem
    FCacheSectionIdx: integer;
    FCacheSectionId: integer;

    FCacheKeyName: RSLString;  //one cell cache for Key in KeyFindAddItem
    FCacheKeyIdx: integer;
    FCacheKeySectionId: integer;

    FKeyList: PrsKeyItemList;
    FKeyCapacity: integer;
    FKeyCount: integer;
    FKeyBeginIdx: integer;
    FKeyEndIdx: integer;

    {for KeyFirst, Last, Next, Prior}
    FKeyIndex: integer;
    FKeyIterationsBegin: integer;
    FKeyIterationsEnd: integer;
    {/for KeyFirst, Last, Next, Prior}

    FLazyActive: boolean;

    FOnAfterLoad: TNotifyEvent;
    FOnAfterSave: TNotifyEvent;
    FOnBeforeLoad: TNotifyEvent;
    FOnBeforeSave: TNotifyEvent;
    FOptions: TrsStorageOptions;
    FRootSection: RSLString;
    FStorageData: TrsStorageData;

    FPreferStartSection: integer; // 0-None; 1-Root; 2-Current;

    FSectionList: PrsSectionItemList;
    FSectionCapacity: integer;
    FSectionCount: integer;
    FSectionMaxId: integer;
    FSectionIdx: integer;
    FSectionChildBeginIdx: integer;
    FSectionChildEndIdx: integer;
    FSectionWrapper: TrsSectionWrapper;
    FSectionIndex: integer; // for SectionFirst, Last, Next, Prior

    FKeyWrapper: TrsKeyWrapper;
    FOnKeyDeletion: TrsStorageKeyEvent;

    FClientList: TrsClientList;
    FOnKeyAdd: TrsStorageKeyEvent;
    FEncryptor: TrsEncryptor;
    FLock: TCriticalSection;
    FCurrentStates: TrsStorageStates;

    function  GetValue(const Key: RSLString): Variant;
    procedure SetActive(const Value: boolean);
    procedure SetRootSection(const Value: RSLString);
    procedure SetStorageData(const Value: TrsStorageData);
    procedure SetValue(const Key: RSLString; const Value: variant);
    procedure StorageLinkDestroying;
{$IFDEF RSL_AUTOLINKREFERENCES}
    procedure rsGlobalComponentProc(Instance: TComponent);
{$ENDIF}
    function GetKeyType(const Key: RSLString): integer;
    procedure SetKeyType(const Key: RSLString; const Value: integer);
    function GetKeyOptions(const Key: RSLString): word;
    procedure SetKeyOptions(const Key: RSLString; const Value: word);
    procedure DoEncrypt;
    procedure DoDecrypt;
    function GetVersion: string;
    procedure SetEncryptor(const Value: TrsEncryptor);
  protected
    procedure SectionChildCorrectIdxIns(Const Idx: integer);
    procedure SectionChildCorrectIdxDel(Const Idx: integer);
    function  SectionCurrentId: integer;
    function  SectionItemInsert(const Index,Count:integer): boolean;
    function  SectionItemDelete(const Index,Count:integer): boolean;
    procedure SectionSetCapacity(const Value:integer);
    function  SectionFind(const Section: RSLString; const CanAdd: boolean): integer;
    function  SectionFindIdxEx(Const ParentId: integer; Section: RSLString): integer;
    function  SectionFindById(RngBegin,RngEnd:integer; const Id:integer): integer;
    function  SectionFindRange(const ParentId:integer; var RngBegin,RngEnd:integer):boolean;
    procedure SectionChildDel(const SectionIdx: integer; const SelfDelete:boolean);
    procedure SectionListGrow(const MinDelta: integer);
    function  SectionFullName(Idx: integer): RSLString; //renamed from SectionName 18-10-2000
    function  SectionLevel(Idx: integer): integer; // 07/05/2002
    function  SubSectionAddEx(const ParentId: integer; Section: RSLString): integer;
    procedure RecursionSectionSaveToStream(const SectionId: integer; Stream: TStream);
    procedure RecursionSectionLoadFromStream(Stream: TStream);

    procedure KeyOnDeletion(const Idx: integer); dynamic;
    procedure KeyOnAdd(const Idx: integer); dynamic;
    procedure KeyCorrectIdxIns(const Idx: integer);
    procedure KeyCorrectIdxDel(const Idx: integer);
    function  KeyItemInsert(const Index,Count:integer): boolean;
    function  KeyItemDelete(const Index,Count:integer): boolean;
    procedure KeySetCapacity(const Value:integer);
    function  KeyFindIdx(RngBegin,RngEnd:integer; const SectionId:integer; const Key: RSLString):integer;
    function  KeyAdd(RngBegin,RngEnd:integer; const SectionId: integer; const Key: RSLString): integer;
    procedure KeyValueFinalize(const Idx: integer; const WithName: boolean);
    procedure KeyListGrow(const MinDelta: integer);
    function  KeyFindRange(const SectionId:integer; var RngBegin,RngEnd:integer):boolean;
    function  KeyFindAddItem(const Key: RSLString; const CanAdd:boolean): integer;

    {for access from StorageData}
    function  GetKeyItem(const Idx: integer): PrsKeyItem;
    function  GetSectionItem(const Idx: integer): PrsSectionItem;
    function  GetKeyRange(var RangeBegin,RangeEnd: integer): boolean;
    function  GetSectionChildRange(var RangeBegin,RangeEnd: integer): boolean;
    property  KeyCountAll: integer read FKeyCount write FKeyCount;
    property  SectionCountAll: integer read FSectionCount write FSectionCount;
    property  SectionMaxId: integer read FSectionMaxId write FSectionMaxId;

    property CurrentStates: TrsStorageStates read FCurrentStates write FCurrentStates;
  protected
    procedure Loaded; override;
    procedure Notification(AComponent: TComponent; Operation: TOperation); override;
  public
    constructor Create(AOwner: TComponent); override;
    destructor Destroy; override;

    procedure Close;
    procedure Clear;
    procedure ClearAll;
    procedure Load;
    procedure Merge;
    procedure Open;
    procedure Save;
    procedure SaveChanges(DefaultData: TrsStorageData);

    function  ChangeDownRootSection(const Section: RSLString): boolean;
    function  ChangeUpRootSection: boolean;

    function  KeyCount: integer;
    procedure KeyDelete(const Key: RSLString);
    function  KeyExist(const Key: RSLString): boolean;
    procedure KeyList(Strings: TStrings);
    procedure KeyRename(const OldName,NewName: RSLString);
    property  KeyOptions[const Key: RSLString]: word read GetKeyOptions write SetKeyOptions;
    property  KeyType[const Key: RSLString]: integer read GetKeyType write SetKeyType;
    property  KeyWrapper: TrsKeyWrapper read FKeyWrapper;
    function  KeyFirst: integer;
    function  KeyNext: integer;
    function  KeyPrior: integer;
    function  KeyLast: integer;

    procedure Lock;
    procedure Unlock;

    function  SectionAdd(const Section: RSLString): boolean;
    procedure SectionClear(const Section: RSLString);
    function  SectionCount: integer;
    procedure SectionDelete(const Section: RSLString);
    function  SectionExist(const Section: RSLString): boolean;
    procedure SectionList(Strings: TStrings);
    function  SectionName: RSLString; //18-10-2000
    procedure SectionRename(const OldName,NewName: RSLString);
    procedure SectionSaveToStream(const Section: RSLString; Stream: TStream);
    procedure SectionLoadFromStream(const Section: RSLString; Stream: TStream);
    property  SectionWrapper: TrsSectionWrapper read FSectionWrapper;
    function  SectionFirst: integer;
    function  SectionNext: integer;
    function  SectionPrior: integer;
    function  SectionLast: integer;

    function  ReadArray(const Key: RSLString; var Values: Variant): integer;
    function  ReadBoolean(const Key: RSLString; const DefValue:boolean): boolean;
    function  ReadBuffer(const Key: RSLString; var Buffer; const Count: Longint): Longint;
    function  ReadComponent(const Key: RSLString; Instance: TComponent): TComponent;
    function  ReadCurrency(const Key: RSLString; const DefValue: Currency): Currency;
    function  ReadDateTime(const Key: RSLString; const DefValue:TDateTime): TDateTime;
    function  ReadFloat(const Key: RSLString; const DefValue:double): double;
{$IFDEF RSL_INT64}
    function  ReadInt64(const Key: RSLString; const DefValue: Int64): Int64;
{$ENDIF}
    function  ReadInteger(const Key: RSLString; const DefValue:integer): integer;
    function  ReadPersistent(const Key: RSLString; Instance: TPersistent): boolean;
    function  ReadPoint(const Key: RSLString): TPoint;
    function  ReadPointer(const Key: RSLString; const DefValue: Pointer): Pointer;
    function  ReadStream(const Key: RSLString; Stream: TStream): integer;
    function  ReadString(const Key: RSLString; const DefValue: RSLString): RSLString;
    function  ReadStrings(const Key: RSLString; Strings: TStrings): boolean;
    function  ReadText(const Key: RSLString; const DefValue:string):string;

    procedure WriteArray(const Key: RSLString; const Values: Variant);   //21.01.02
    procedure WriteBoolean(const Key: RSLString; const Value: boolean);
    procedure WriteBuffer(const Key: RSLString; const Buffer; const Count: Longint);
    procedure WriteComponent(const Key: RSLString; Instance: TComponent);
    procedure WriteCurrency(const Key: RSLString; const Value: Currency);
    procedure WriteDateTime(const Key: RSLString; const Value:TDateTime);
    procedure WriteFloat(const Key: RSLString; const Value:double);
{$IFDEF RSL_INT64}
    procedure WriteInt64(const Key: RSLString; const Value: Int64);
{$ENDIF}
    procedure WriteInteger(const Key: RSLString; const Value:integer);
    procedure WritePersistent(const Key: RSLString; Instance: TPersistent);
    procedure WritePoint(const Key: RSLString; const Point:TPoint);
    procedure WritePointer(const Key: RSLString; const Value: Pointer);
    procedure WriteStream(const Key: RSLString; Stream: TStream);
    procedure WriteString(const Key: RSLString; const Value: RSLString);
    procedure WriteStrings(const Key: RSLString; Strings: TStrings);
    procedure WriteText(const Key: RSLString; const Value:string);

    property Values[const Key: RSLString]: variant read GetValue write SetValue; default;
    property Version: string read GetVersion;

{$IFDEF RSL_STORAGE_PUBLICLINK}
    property Encryptor: TrsEncryptor read FEncryptor write SetEncryptor;
    property StorageData: TrsStorageData read FStorageData write SetStorageData;
{$ENDIF}
  published
    property Active: boolean read FActive write SetActive;
{$IFNDEF RSL_STORAGE_PUBLICLINK}
    property Encryptor: TrsEncryptor read FEncryptor write SetEncryptor;
    property StorageData: TrsStorageData read FStorageData write SetStorageData;
{$ENDIF}
    property RootSection: RSLString read FRootSection write SetRootSection;
    property Options: TrsStorageOptions read FOptions write FOptions default [soSaveOnClose];

    property OnAfterLoad: TNotifyEvent read FOnAfterLoad write FOnAfterLoad;
    property OnAfterSave: TNotifyEvent read FOnAfterSave write FOnAfterSave;
    property OnBeforeLoad: TNotifyEvent read FOnBeforeLoad write FOnBeforeLoad;
    property OnBeforeSave: TNotifyEvent read FOnBeforeSave write FOnBeforeSave;
    property OnKeyAdd: TrsStorageKeyEvent read FOnKeyAdd write FOnKeyAdd;
    property OnKeyDeletion: TrsStorageKeyEvent read FOnKeyDeletion write FOnKeyDeletion;
  end;



implementation

uses rsUtils, rsLZRWCompression;


procedure FinalizeKeyValue(Value: PrsKeyValue);
begin
  case Value^.kvType of
    kvtString: RSLString(Value^.VString) := '';
    kvtBuffer: AnsiString(Value^.VBuffer) := '';
    else Value.VInteger := 0;
  end;
end;

{ TrsStorage }
{$WARNINGS OFF}
constructor TrsStorage.Create(AOwner: TComponent);
{$IFDEF RSL_AUTOLINKREFERENCES}
var
  TempData: TrsStorageData;
  TempEncryptor: TrsEncryptor;
{$ENDIF}
begin
  inherited Create(AOwner);
{$IFDEF RSL_TRIAL}
  if not (csDesigning in ComponentState) then begin
    if MessageBox(0,
                  'You use trial version of Storage library. Would you like to register Storage library now?',
                  'Registration', MB_YESNO)=IDYES
      then ShellExecute(0, 'open', 'https://secure.element5.com/register.html?productid=104785', nil, nil, SW_SHOWDEFAULT);
  end;
{$ENDIF}
  FLock := TCriticalSection.Create;
  FActive := csDesigning in ComponentState;
  FOptions := [soSaveOnClose];
  SectionSetCapacity(0);
  KeySetCapacity(0);
  FCacheSectionName := '';
  FCacheKeyName := '';
  FClientList := TrsClientList.Create;
{$IFDEF RSL_AUTOLINKREFERENCES}
  if csDesigning in ComponentState then begin
    TempData := TrsStorageData(rsGlobalFindComponent(TrsStorageData, AOwner, nil));
    if (TempData<>nil) and (TempData.Storage=nil) then StorageData := TempData;
    rsGlobalFindComponent(TrsStorageClient, AOwner, rsGlobalComponentProc);

    TempEncryptor := TrsEncryptor(rsGlobalFindComponent(TrsEncryptor, AOwner, nil));
    if (TempEncryptor<>nil) and (TempEncryptor.Storage=nil) then Encryptor := TempEncryptor;
  end;
{$ENDIF}
  FKeyWrapper := TrsKeyWrapper.Create(Self);
  FSectionWrapper := TrsSectionWrapper.Create(Self);
  FCurrentStates := [];
end;
{$WARNINGS ON}


function TrsStorage.ChangeDownRootSection(const Section: RSLString): boolean;
var
  i: integer;
begin
  FPreferStartSection := 2;
  i := SectionFind(Section, False);
  Result := i>=0;
  if Result then begin
    FSectionIdx := i;
    i := FSectionList^[i].Id;

    if FRootSection='' then FRootSection := Section
     else FRootSection := FRootSection + '\' + Section;

    SectionFindRange(i, FSectionChildBeginIdx, FSectionChildEndIdx);
    KeyFindRange(i, FKeyBeginIdx, FKeyEndIdx);
  end;
end;


function TrsStorage.ChangeUpRootSection: boolean;
var
  i,sectId: integer;
begin
  if FSectionIdx>=0 then begin
    sectId := FSectionList^[FSectionIdx].ParentId;
    FSectionIdx := SectionFindById(0, FSectionIdx, sectId);

    if FSectionIdx>=0 then begin
      for i:=Length(FRootSection) downto 1 do
       if IsSectionSeparator(FRootSection[i]) then begin
         Delete(FRootSection, i, Length(FRootSection)-i+1); // 11.12.2001
         Break;                                             // 11.12.2001
       end;
    end else FRootSection := '';

    SectionFindRange(sectId, FSectionChildBeginIdx, FSectionChildEndIdx);
    KeyFindRange(sectId, FKeyBeginIdx, FKeyEndIdx);
    Result := True;
  end else Result := False;
end;


procedure TrsStorage.Clear;
begin
  FClientList.Active := False;
  SectionChildDel(FSectionIdx, False);
  FKeyBeginIdx := -1;
  FKeyEndIdx := -1;
  FClientList.Active := True;
  FClientList.DoNotification(scnSectionClear, Longint(SectionFullName(FSectionIdx)), 0);
end;


procedure TrsStorage.ClearAll;
begin
  Include(FCurrentStates, ssClearing);
  try
    FClientList.Active := False;
    KeySetCapacity(0);
    SectionSetCapacity(0);
    FKeyBeginIdx := -1;
    FKeyEndIdx := -1;
    FClientList.Active := True;
    FClientList.DoNotification(scnClear, 0, 0);
  finally
    Exclude(FCurrentStates, ssClearing);
  end;
end;


procedure TrsStorage.Close;
begin
  if FActive then begin
    if (soSaveOnClose in Options) and not (csDesigning in ComponentState) then Save;
    FActive := False;
  end;
  FKeyWrapper.TempClassesActive(False);
end;


destructor TrsStorage.Destroy;
begin
  Close;
  ClearAll;
  FClientList.Free;
  FKeyWrapper.Free;
  FSectionWrapper.Free;
  StorageData := nil;
  Encryptor := nil;
  FLock.Free;
  inherited Destroy;
end;


function TrsStorage.GetKeyItem(const Idx: integer): PrsKeyItem;
begin
  Result := @FKeyList^[Idx];
end;


function TrsStorage.GetKeyOptions(const Key: RSLString): word;
begin
  if KeyFindAddItem(Key, False)>=0
    then Result := FKeyWrapper.KeyOptions
    else Result := 0;
end;


function TrsStorage.GetKeyRange(var RangeBegin, RangeEnd: integer): boolean;
begin
  RangeBegin := FKeyBeginIdx;
  RangeEnd := FKeyEndIdx;
  Result := (RangeBegin>=0) and (RangeEnd>RangeBegin);
end;


function TrsStorage.GetKeyType(const Key: RSLString): integer;
begin
  if KeyFindAddItem(Key, False)>=0
    then Result := FKeyWrapper.KeyType
    else Result := -1;
end;


function TrsStorage.GetSectionChildRange(var RangeBegin, RangeEnd: integer): boolean;
begin
  RangeBegin := FSectionChildBeginIdx;
  RangeEnd := FSectionChildEndIdx;
  Result := (RangeBegin>=0) and (RangeEnd>RangeBegin);
end;


function TrsStorage.GetSectionItem(const Idx: integer): PrsSectionItem;
begin
  if (Idx>=0) and (Idx<FSectionCount)
   then Result := @FSectionList^[Idx]
   else Result := nil;
end;


function TrsStorage.GetValue(const Key: RSLString): Variant;
begin
  if KeyFindAddItem(Key, False)>=0 then Result := FKeyWrapper.GetAsVariant
   else Result := Unassigned;
end;



function TrsStorage.KeyAdd(RngBegin, RngEnd: integer; const SectionId: integer; const Key: RSLString): integer;
var
  i,e: integer;
begin
  if RngBegin<0 then i:=0 else i:=RngBegin;
  if (RngEnd>=FKeyCount) or (RngEnd<0) then e:=FKeyCount-1 else e:=RngEnd;

  While (i<=e) and
        ((FKeyList^[i].SectionId<SectionId) or
         ((FKeyList^[i].SectionId=SectionId) and
         (RSLCompareText(FKeyList^[i].Name, Key)<0))) do Inc(i);

  if KeyItemInsert(i,1) then begin
    FKeyList^[i].Name := Key;
    FKeyList^[i].SectionId := SectionId;
    FKeyList^[i].Value.kvType := kvtUnknown;
    FKeyList^[i].Value.VUnknown := nil;
    Result := i;

    KeyCorrectIdxIns(i);

    KeyOnAdd(Result);
  end else Result := -1;
end;


procedure TrsStorage.KeyCorrectIdxDel(const Idx: integer);
var
  b,e: integer;
begin
  b := FKeyBeginIdx;
  e := FKeyEndIdx;
    if (Idx>=b) and (Idx<e)
      then begin
        Dec(e);
        if e<=b then begin
          b := -1;
          e := -1;
        end;
      end else
    if Idx<b then begin
      Dec(b);
      Dec(e);
    end;
  FKeyBeginIdx := b;
  FKeyEndIdx := e;
end;


procedure TrsStorage.KeyCorrectIdxIns(const Idx: integer);
var
  b,e: integer;
begin
  b := FKeyBeginIdx;
  e := FKeyEndIdx;
    if (e<=b) and (SectionCurrentId = FKeyList^[Idx].SectionId)
      then begin
        b := Idx;
        e := Idx+1;
      end else
    if (Idx>=b) and (Idx<=e)
      then Inc(e)
      else
    if Idx<b then begin
      Inc(b);
      Inc(e);
    end;
  FKeyBeginIdx := b;
  FKeyEndIdx := e;
end;


function TrsStorage.KeyCount: integer;
begin
  Result := FKeyEndIdx - FKeyBeginIdx;
end;


procedure TrsStorage.KeyDelete(const Key: RSLString);
var
  i: integer;
begin
  i := KeyFindAddItem(Key, False);
  if i>=0 then begin
    KeyItemDelete(i,1);
    KeyCorrectIdxDel(i);
  end;
end;


function TrsStorage.KeyExist(const Key: RSLString): boolean;
begin
   Result := KeyFindAddItem(Key, False)>=0;
end;


function TrsStorage.KeyFindAddItem(const Key: RSLString; const CanAdd: boolean): integer;
var
  i,TempSectionId: integer;
  TempKeyBegin,TempKeyEnd: integer;
  aKeyName, aSectionName: RSLString;
begin
  Result := -1;

  aKeyName := Key;
  aSectionName := '';
  for i:=Length(Key) downto 1 do
    if IsSectionSeparator(Key[i]) then begin
      aSectionName := Copy(Key, 1, i-1);
      aKeyName := Copy(Key, i+1, Length(Key)-i);
      Break;
    end;

  if (Length(aSectionName)=0) and
     (Length(Key)>0) and
     IsSectionSeparator(Key[1])
    then begin
      i := -1;
    end else
  if Length(aSectionName)>0 then begin
    if (RSLCompareText(FCacheSectionName, aSectionName)=0) and
       (FCacheSectionIdx<FSectionCount) and
       (FSectionList^[FCacheSectionIdx].Id=FCacheSectionId)
      then begin
        i := FCacheSectionIdx;
      end else begin
        if Length(aSectionName)=0 then i := -1
         else begin
           i := SectionFind(aSectionName, CanAdd);
           if i>=0 then begin
             FCacheSectionName := aSectionName;
             FCacheSectionIdx := i;
             FCacheSectionId := FSectionList^[i].Id;
           end else Exit;
         end;
      end;
  end else i := FSectionIdx;

  if i<0 then TempSectionId := 0
   else TempSectionId := FSectionList^[i].Id;

   if (FCacheKeySectionId=TempSectionId) and
     (RSLCompareText(aKeyName, FCacheKeyName)=0) and
     (FCacheKeyIdx<FKeyCount) and
     (FKeyList^[FCacheKeyIdx].SectionId=TempSectionId) and
     (RSLCompareText(aKeyName, FKeyList^[FCacheKeyIdx].Name)=0)
   then begin
     Result := FCacheKeyIdx;
     FKeyWrapper.PKeyItem := @FKeyList^[Result];
     Exit;
   end;

  if i<>FSectionIdx then begin
    if CanAdd then KeyFindRange(TempSectionId, TempKeyBegin, TempKeyEnd)
     else begin
       TempKeyBegin := 0;
       TempKeyEnd := FKeyCount;
     end;
  end else begin
    TempKeyBegin := FKeyBeginIdx;
    TempKeyEnd := FKeyEndIdx;
  end;

  Result := KeyFindIdx(TempKeyBegin, TempKeyEnd-1, TempSectionId, aKeyName);
  if CanAdd and (Result<0) then
    Result := KeyAdd(TempKeyBegin, TempKeyEnd-1, TempSectionId, aKeyName);

  if Result>=0 then begin
    FCacheKeyIdx := Result;
    FCacheKeySectionId := TempSectionId;
    FCacheKeyName := aKeyName;
    FKeyWrapper.PKeyItem := @FKeyList^[Result];
  end;
end;


function TrsStorage.KeyFindIdx(RngBegin, RngEnd: integer; const SectionId: integer;
                               const Key: RSLString): integer;
var
  b,e,c: integer;
  p: PrsKeyItem;
begin
  b := RngBegin;
  e := RngEnd;
  while b <= e do begin
    Result := (b + e) shr 1;
    p := @FKeyList^[Result];
    c := p^.SectionId-SectionId;
    if c < 0 then b := Result + 1
     else
    if c > 0 then e := Result - 1
     else begin
       c := RSLCompareText(Key, p^.Name);
       if c=0 then Exit
        else
       if c>0 then b := Result + 1
        else e := Result - 1;
     end;
  end;
  Result := -1;
end;


function TrsStorage.KeyFindRange(const SectionId: integer; var RngBegin,RngEnd: integer): boolean;
var
  b,e,i,c: integer;
begin
  Result := False;
  i := 0; //off warning only
  b := 0;
  e := FKeyCount-1;
  if FKeyCount>0 then
    while b <= e do begin
      i := (b + e) shr 1;
      c := FKeyList^[i].SectionId-SectionId;
      if c < 0 then b := i + 1
       else
      if c > 0 then e := i - 1
       else begin
         Result := True;
         Break;
       end;
    end;

  if not Result then begin
    RngBegin := -1;
    RngEnd := -1;
  end else begin
    b := i;
    While (b>=0) and (FKeyList^[b].SectionId=SectionId) do Dec(b);
    Inc(b);
    e := i;
    While (e<FKeyCount) and (FKeyList^[e].SectionId=SectionId) do Inc(e);
    RngBegin := b;
    RngEnd := e;
  end;
end;


function TrsStorage.KeyItemDelete(const Index, Count: integer): boolean;
var
  i: integer;
begin
  for i:=Index to Index+Count-1 do begin
    KeyOnDeletion(i);
    KeyValueFinalize(i, True);
  end;
  Move(FKeyList^[Index+Count],FKeyList^[Index], (FKeyCount-(Index+Count))*SizeOf(TrsKeyItem));
  FillChar(FKeyList^[FKeyCount-Count], SizeOf(TrsKeyItem)*Count, 0);
  Dec(FKeyCount,Count);
  KeyListGrow(0);
  Result := True;
end;


function TrsStorage.KeyItemInsert(const Index, Count: integer): boolean;
begin
  if (FKeyCapacity-FKeyCount)<Count then KeyListGrow(Count);
  Result := (Index>=0) and (Index<FKeyCapacity);
  if Result then begin
    Move(FKeyList^[Index], FKeyList^[Index+Count], (FKeyCount-Index)*SizeOf(TrsKeyItem));
    FillChar(FKeyList^[Index], SizeOf(TrsKeyItem)*Count, 0);
    Inc(FKeyCount,Count);
  end;
end;

//UNICODE NO
procedure TrsStorage.KeyList(Strings: TStrings);
var
  i: integer;
begin
  Strings.Clear;
  if FKeyEndIdx>FKeyBeginIdx then
    for i:=FKeyBeginIdx to FKeyEndIdx-1 do Strings.Add(FKeyList^[i].Name);
end;


procedure TrsStorage.KeyListGrow(const MinDelta: integer);
var
  Delta: integer;
begin
  if (FKeyCapacity-FKeyCount)>0
   then begin
     if FKeyCount>0 then Delta := (FKeyCount-FKeyCapacity) div 2
      else Delta := FKeyCount-FKeyCapacity;
   end else begin
     if FKeyCapacity > 64 then Delta := FKeyCapacity div 4
      else if FKeyCapacity > 16 then Delta := 16
       else Delta := 8;
   end;

  if (Delta>0) and (MinDelta>Delta) then Delta := MinDelta
   else
  if (Delta<0) and (MinDelta<Delta) then Delta := MinDelta;

  if Delta<>0 then KeySetCapacity(FKeyCapacity + Delta);
end;


procedure TrsStorage.KeySetCapacity(const Value: integer);
var i: integer;
begin
  if Value<FKeyCount then
    for i:=Value to FKeyCount-1 do begin
      KeyOnDeletion(i);
      KeyValueFinalize(i, True);
    end;
  ReallocMem(FKeyList, Value * SizeOf(TrsKeyItem));

  if Value>FKeyCapacity then
    FillChar(FKeyList^[FKeyCapacity], SizeOf(TrsKeyItem)*(Value-FKeyCapacity), 0);

  FKeyCapacity := Value;
  if Value=0 then begin
    FKeyCount := 0;
    FKeyList := nil;
  end;
end;


procedure TrsStorage.KeyValueFinalize(const Idx: integer; const WithName: boolean);
begin
  with FKeyList^[Idx] do begin
    if WithName then Name := '';
    FinalizeKeyValue(@Value);
  end;
end;


procedure TrsStorage.Load;
begin
  Include(FCurrentStates, ssLoading);
  try
    ClearAll;
    Merge;
  finally
    Exclude(FCurrentStates, ssLoading);
  end;
end;


procedure TrsStorage.Loaded;
begin
  inherited Loaded;
  if FLazyActive then Load;
end;


procedure TrsStorage.Notification(AComponent: TComponent; Operation: TOperation);
begin
  inherited Notification(AComponent, Operation);
  if Operation=opRemove then begin
    if AComponent=FStorageData then begin
      StorageLinkDestroying;
      FStorageData := nil;
    end else
    if AComponent=FEncryptor then begin
      StorageLinkDestroying;
      FEncryptor := nil;
    end else begin
      if (AComponent is TrsStorageClient) and (FClientList.IndexOf(TrsStorageClient(AComponent))>=0)
       then FClientList.Remove(TrsStorageClient(AComponent));
    end;
  end;
end;


procedure TrsStorage.Open;
begin
  if not FActive then begin
    if not (csDesigning in ComponentState) then begin
      FLazyActive := (csLoading in ComponentState);
      if not FLazyActive then Load;
    end;
    FActive := True;
  end;
end;


function TrsStorage.ReadComponent(const Key: RSLString; Instance: TComponent): TComponent;
begin
  if KeyFindAddItem(Key, False)<0 then Result := nil
   else Result := FKeyWrapper.SetComponentProps(Instance);
end;


function TrsStorage.ReadCurrency(const Key: RSLString; const DefValue: Currency): Currency;
begin
  if KeyFindAddItem(Key, False)<0 then Result := DefValue
   else Result := FKeyWrapper.GetAsCurrency;
end;


function TrsStorage.ReadBoolean(const Key: RSLString; const DefValue: boolean): boolean;
begin
  if KeyFindAddItem(Key, False)<0 then Result := DefValue
   else Result := FKeyWrapper.GetAsBoolean;
end;


function TrsStorage.ReadBuffer(const Key: RSLString; var Buffer; const Count: Longint): Longint;
begin
 if KeyFindAddItem(Key, False)<0 then Result := 0
  else Result := FKeyWrapper.GetAsBuffer(Buffer, Count);
end;


function TrsStorage.ReadDateTime(const Key: RSLString; const DefValue: TDateTime): TDateTime;
begin
  if KeyFindAddItem(Key, False)<0 then Result := DefValue
   else Result := FKeyWrapper.GetAsDateTime;
end;


function TrsStorage.ReadFloat(const Key: RSLString; const DefValue: double): double;
begin
  if KeyFindAddItem(Key, False)<0 then Result := DefValue
   else Result := FKeyWrapper.GetAsFloat;
end;


{$IFDEF RSL_INT64}
function TrsStorage.ReadInt64(const Key: RSLString; const DefValue: Int64): Int64;
begin
  if KeyFindAddItem(Key, False)<0 then Result := DefValue
   else Result := FKeyWrapper.GetAsInt64;
end;
{$ENDIF}


function TrsStorage.ReadInteger(const Key: RSLString; const DefValue: integer): integer;
begin
  if KeyFindAddItem(Key, False)<0 then Result := DefValue
   else Result := FKeyWrapper.GetAsInteger;
end;


function TrsStorage.ReadPoint(const Key: RSLString): TPoint;
begin
  if KeyFindAddItem(Key, False)>=0 then Result := FKeyWrapper.GetAsPoint;
end;


function TrsStorage.ReadStream(const Key: RSLString; Stream: TStream): integer;
begin
  if KeyFindAddItem(Key, False)<0 then Result := 0
    else Result := FKeyWrapper.GetAsStream(Stream);
end;


function TrsStorage.ReadString(const Key: RSLString; const DefValue: RSLString): RSLString;
begin
  if KeyFindAddItem(Key, False)<0 then Result := DefValue
   else Result := FKeyWrapper.GetAsString;
end;


function TrsStorage.ReadText(const Key: RSLString; const DefValue: string): string;
begin
  if KeyFindAddItem(Key, False)<0 then Result := DefValue
   else Result := FKeyWrapper.GetAsString;
end;


{$IFDEF RSL_AUTOLINKREFERENCES}
procedure TrsStorage.rsGlobalComponentProc(Instance: TComponent);
begin
  if TrsStorageClient(Instance).Storage=nil
    then TrsStorageClient(Instance).Storage := Self;
end;
{$ENDIF}


procedure TrsStorage.Save;
begin
  Include(FCurrentStates, ssSaving);
  try
    if Assigned(OnBeforeSave) then OnBeforeSave(self);
    if Assigned(StorageData) then begin
      DoEncrypt;
      StorageData.SetStorage(Self);
      StorageData.Save;
      DoDecrypt;
    end;
    if Assigned(OnAfterSave) then OnAfterSave(self);
  finally
    Exclude(FCurrentStates, ssSaving);
  end;
end;


function TrsStorage.SectionAdd(const Section: RSLString):boolean;
var
  i: integer;
begin
  i := SectionFind(Section, True);
  Result := i>=0;
  if Result then FClientList.DoNotification(scnSectionAdd, Longint(SectionFullName(i)), 0);
end;


procedure TrsStorage.SectionChildCorrectIdxDel(const Idx: integer);
var
  b,e: integer;
begin
  b := FSectionChildBeginIdx;
  e := FSectionChildEndIdx;
  if (Idx>=b) and (Idx<e)
    then begin
      Dec(e);
      if e<=b then begin
        b := -1;
        e := -1;
      end;
    end else
  if Idx<b then begin
    Dec(b);
    Dec(e);
  end;
  FSectionChildBeginIdx := b;
  FSectionChildEndIdx := e;
end;


procedure TrsStorage.SectionChildCorrectIdxIns(const Idx: integer);
var
  b,e: integer;
begin
  b := FSectionChildBeginIdx;
  e := FSectionChildEndIdx;
  if (e<=b) and (SectionCurrentId = FSectionList^[Idx].ParentId)
    then begin
      b := Idx;
      e := Idx+1;
    end else
  if (Idx>=b) and {(Idx<e)  //}(Idx<=e) // correct at 18/10/2001
    then Inc(e)
    else
  if Idx<b then begin
    Inc(b);
    Inc(e);
  end;
  FSectionChildBeginIdx := b;
  FSectionChildEndIdx := e;
end;


procedure TrsStorage.SectionChildDel(const SectionIdx: integer; const SelfDelete:boolean);
var
  id,i,b,e: integer;
begin
  if SectionIdx<0 then id := 0 else id := FSectionList^[SectionIdx].Id;
  if SectionFindRange(id,b,e) then begin
    for i:=e-1 downto b do SectionChildDel(i,False);
    SectionItemDelete(b,e-b);
  end;

  if KeyFindRange(id,b,e) then KeyItemDelete(b,e-b);
  if SelfDelete and (SectionIdx>=0) then SectionItemDelete(SectionIdx,1);
end;


function TrsStorage.SectionCount: integer;
begin
  Result := FSectionChildEndIdx - FSectionChildBeginIdx;
end;


function TrsStorage.SectionCurrentId: integer;
begin
 if FSectionIdx<0 then Result := 0
  else  Result := FSectionList^[FSectionIdx].Id;
end;


procedure TrsStorage.SectionDelete(const Section: RSLString);
var
  i: integer;
  s: RSLString;
begin
  i := SectionFind(Section, False);
  if i>=0 then begin
    s := SectionFullName(i);
    SectionChildDel(i, True);
    SectionChildCorrectIdxDel(i);
    if FSectionIdx=i then RootSection := '';
    FClientList.DoNotification(scnSectionDelete, Longint(s), 0);
  end;
end;


function TrsStorage.SectionExist(const Section: RSLString): boolean;
begin
  Result := SectionFind(Section, False)>=0;
end;


function TrsStorage.SectionFind(const Section: RSLString; const CanAdd: boolean): integer;
var
  TempIdx,TempId, bIdx: integer;
  s: RSLString;
begin
  Result := -1;
  if Length(Section)=0 then Exit;

  bIdx := 1;

  case FPreferStartSection of
    1: begin
         TempIdx := -1;
         TempId := 0;
         FPreferStartSection := 0;
       end;
    2: begin
         TempIdx := FSectionIdx;
         TempId := SectionCurrentId;
         FPreferStartSection := 0;
       end;
    else begin
      if IsSectionSeparator(Section[bIdx]) then begin
        TempIdx := -1;
        TempId := 0;
        Inc(bIdx);
      end else begin
        TempIdx := FSectionIdx;
        TempId := SectionCurrentId;
      end;
    end;
  end;

  While IsSectionSeparator(Section[bIdx]) do Inc(bIdx);

  if bIdx<=Length(Section) then // 26.05.2002
    While True do begin
      s := GetNameBetweenSeparators(Section, bIdx);

      TempIdx := SectionFindIdxEx(TempId, s);
      if TempIdx<0 then begin
        if CanAdd then begin
           TempIdx := SubSectionAddEx(TempId, s);
           if TempIdx<0 then Exit
            else begin
              SectionChildCorrectIdxIns(TempIdx);
              TempId := FSectionList^[TempIdx].Id;
            end;
        end else Exit;
      end else TempId := FSectionList^[TempIdx].Id;

      if bIdx>=Length(Section) then Break     //18.03.2002 >=
       else Inc(bIdx);
    end;

  Result := TempIdx;
end;


function TrsStorage.SectionFindById(RngBegin, RngEnd: integer; const Id: integer): integer;
var
  safe: integer;
begin
  Result := -1;
  if RngBegin<0 then RngBegin := 0;
  if RngEnd>=FSectionCount then RngEnd := FSectionCount-1;
  if RngEnd<RngBegin then Exit;

  safe := FSectionList^[RngEnd].Id;
  if safe=Id then begin
    Result := RngEnd;
    Exit;
  end;
  FSectionList^[RngEnd].Id := Id;

  While FSectionList^[RngBegin].Id<>Id do Inc(RngBegin);

  if RngBegin<>RngEnd then Result := RngBegin;

  FSectionList^[RngEnd].Id := safe;
end;


function TrsStorage.SectionFindIdxEx(const ParentId: integer; Section: RSLString): integer;
var
  i,b,e,c: integer;
begin
  Result := -1;
  if Length(Section)=0 then Exit;

  b := 0;
  e := FSectionCount-1;
  while b <= e do begin
    i := (b + e) shr 1;
    c := FSectionList^[i].ParentId-ParentId;
    if c < 0 then b := i + 1
     else
    if c > 0 then e := i - 1
     else begin
       c := RSLCompareText(Section, FSectionList^[i].Name);
       if c=0 then begin
         Result := i;
         Exit;
       end else
       if c < 0 then e := i - 1  //r
        else
       if c > 0 then b := i + 1; //r
     end;
  end;
end;


function TrsStorage.SectionFindRange(const ParentId: integer;
                                     var RngBegin,RngEnd: integer): boolean;
var
  i,b,e,c: integer;
begin
  Result := False;
  i:=0; // off warning about i
  b := 0;
  e := FSectionCount-1;
  if FSectionCount>0 then
    while b <= e do begin
      i := (b + e) shr 1;
      c := FSectionList^[i].ParentId-ParentId;
      if c < 0 then b := i + 1
       else
      if c > 0 then e := i - 1
       else begin
         Result := True;
         Break;
       end;
    end;

  if not Result then begin
    RngBegin := -1;
    RngEnd := -1;
  end else begin
    b := i;
    While (b>=0) and (FSectionList^[b].ParentId=ParentId) do Dec(b);
    Inc(b);
    e := i;
    While (e<FSectionCount) and (FSectionList^[e].ParentId=ParentId) do Inc(e);
    RngBegin := b;
    RngEnd := e;
  end;
end;


function TrsStorage.SectionFullName(Idx: integer): RSLString;
begin
 Result := '';
 if Idx<FSectionCount then
   While True do
     if Idx<0 then Break
      else
     if FSectionList^[Idx].ParentId>0
      then begin
        Result := '\' + FSectionList^[Idx].Name + Result;
        Idx := SectionFindById(0,Idx-1,FSectionList^[Idx].ParentId);
      end else begin
        Result := FSectionList^[Idx].Name + Result;
        Break;
      end;
end;


function TrsStorage.SectionItemDelete(const Index,Count: integer): boolean;
var
  i: integer;
begin
  for i:=Index to Index+Count-1 do FSectionList^[i].Name := '';
  Move(FSectionList^[Index+Count],FSectionList^[Index], (FSectionCount-(Index+Count))*SizeOf(TrsSectionItem));
  FillChar(FSectionList^[FSectionCount-Count], SizeOf(TrsSectionItem)*Count, 0);
  Dec(FSectionCount,Count);
  SectionListGrow(0);
  Result := True;
end;


function TrsStorage.SectionItemInsert(const Index,Count: integer): boolean;
begin
  if (FSectionCapacity-FSectionCount)<Count then SectionListGrow(Count);
  Result := (Index>=0) and (Index<FSectionCapacity);
  if Result then begin
    Move(FSectionList^[Index], FSectionList^[Index+Count], (FSectionCount-Index)*SizeOf(TrsSectionItem));
    FillChar(FSectionList^[Index], SizeOf(TrsSectionItem)*Count, 0);
    Inc(FSectionCount, Count);
  end;
end;


procedure TrsStorage.SectionList(Strings: TStrings);
var
  i: integer;
begin
  Strings.Clear;
  if FSectionChildEndIdx>FSectionChildBeginIdx then
   for i:=FSectionChildBeginIdx to FSectionChildEndIdx-1 do Strings.Add(FSectionList^[i].Name);
end;


procedure TrsStorage.SectionListGrow(const MinDelta: integer);
var
  Delta: integer;
begin
  if (FSectionCapacity-FSectionCount)>0
   then begin
     if FSectionCount>0 then Delta := (FSectionCount-FSectionCapacity) div 2
      else Delta := FSectionCount-FSectionCapacity;
   end else begin
     if FSectionCapacity > 64 then Delta := FSectionCapacity div 4
      else if FSectionCapacity > 16 then Delta :=16
       else Delta := 8;
   end;

  if (Delta>0) and (MinDelta>Delta) then Delta := MinDelta
   else
  if (Delta<0) and (MinDelta<Delta) then Delta := MinDelta;

  if Delta<>0 then SectionSetCapacity(FSectionCapacity + Delta);
end;


function TrsStorage.SectionName: RSLString;
begin
  if FSectionIdx>=0 then Result := FSectionList^[FSectionIdx].Name
   else Result := '';
end;


procedure TrsStorage.SectionSetCapacity(const Value: integer);
var
  i: integer;
begin
  if Value<FSectionCount then
    for i:=Value to FSectionCount-1 do
      with FSectionList^[i] do begin
        Name := '';
      end;

  ReallocMem(FSectionList, Value * SizeOf(TrsSectionItem));
  if Value>FSectionCapacity then begin
    FillChar(FSectionList^[FSectionCapacity], sizeOf(TrsSectionItem)*(Value-FSectionCapacity),0);
  end;
  FSectionCapacity := Value;
  if Value=0 then begin
    FSectionCount := 0;
    FSectionList := nil;
    FRootSection := '';
    FSectionMaxId := 0;
    FSectionIdx := -1;
    FSectionChildBeginIdx := -1;
    FSectionChildEndIdx := -1;
  end;
end;


procedure TrsStorage.SetActive(const Value: boolean);
begin
  if FActive<>Value then begin
    if Value then Open else Close;
  end;
end;


procedure TrsStorage.SetKeyOptions(const Key: RSLString; const Value: word);
begin
  if KeyFindAddItem(Key, False)>=0 then FKeyWrapper.KeyOptions := Value;
end;


procedure TrsStorage.SetKeyType(const Key: RSLString; const Value: integer);
begin
  if KeyFindAddItem(Key, False)>=0 then FKeyWrapper.KeyType := Value;
end;


procedure TrsStorage.SetRootSection(const Value: RSLString);
var
  i: integer;
begin
//  if CompareText(FRootSection,Value)<>0 then begin    //12.12.2001
    FPreferStartSection := 1;
    if Length(Value)=0 then begin
     i := 0;
     FSectionIdx := -1;
    end else begin
      i := SectionFind(Value, True);
      FSectionIdx := i;  // 26.05.2002, because RootSection := '\'; not work
      if FSectionIdx>=0
        then i := FSectionList^[i].Id
        else i := 0;
    end;
    FRootSection := Value;
    SectionFindRange(i, FSectionChildBeginIdx, FSectionChildEndIdx);
    KeyFindRange(i, FKeyBeginIdx, FKeyEndIdx);
    FClientList.DoNotification(scnRootSectionChanged, Longint(Value), 0);
//  end;                                                //12.12.2001
end;


procedure TrsStorage.SetStorageData(const Value: TrsStorageData);
begin
  if FStorageData<>Value then begin
    if FStorageData<>nil then FStorageData.SetStorage(nil);
    FStorageData := Value;
    if FStorageData<>nil then FStorageData.SetStorage(Self);
  end;
end;


procedure TrsStorage.SetValue(const Key: RSLString; const Value: variant);
begin
  if KeyFindAddItem(Key,True)>=0 then FKeyWrapper.SetAsVariant(Value);
end;


procedure TrsStorage.StorageLinkDestroying;
begin
  if csDestroying in ComponentState then Close;
end;


function TrsStorage.SubSectionAddEx(const ParentId: integer; Section: RSLString): integer;
var
  i,e: integer;
begin
  Result := -1;
  if Length(Section)=0 then Exit;

  i := 0;
  e := FSectionCount-1;
  if ParentId=SectionCurrentId then begin
    if FSectionChildBeginIdx>0 then i := FSectionChildBeginIdx;
    if FSectionChildEndIdx>FSectionChildBeginIdx then e := FSectionChildEndIdx-1;
  end;

 if i<FSectionCount then
  While (i<=e) and
        ((FSectionList^[i].ParentId<ParentId) or
         ((FSectionList^[i].ParentId=ParentId) and
         (RSLCompareText(Section, FSectionList^[i].Name)>0))) do Inc(i);

  if SectionItemInsert(i,1) then begin
    FSectionList^[i].Name := Section;
    FSectionList^[i].ParentId := ParentId;
    Inc(FSectionMaxId);
    FSectionList^[i].Id := FSectionMaxId;
    Result := i;
  end;
end;


procedure TrsStorage.WriteComponent(const Key: RSLString; Instance: TComponent);
begin
  if KeyFindAddItem(Key, True)>=0 then FKeyWrapper.GetComponentProps(Instance);
end;


procedure TrsStorage.WriteCurrency(const Key: RSLString; const Value: Currency);
begin
  if KeyFindAddItem(Key, True)>=0 then  FKeyWrapper.SetAsCurrency(Value);
end;


procedure TrsStorage.WriteBoolean(const Key: RSLString; const Value: boolean);
begin
  if KeyFindAddItem(Key, True)>=0 then  FKeyWrapper.SetAsBoolean(Value);
end;


procedure TrsStorage.WriteBuffer(const Key: RSLString; const Buffer; const Count: Integer);
begin
  if KeyFindAddItem(Key, True)>=0 then FKeyWrapper.SetAsBuffer(Buffer, Count);
end;


procedure TrsStorage.WriteDateTime(const Key: RSLString; const Value: TDateTime);
begin
  if KeyFindAddItem(Key, True)>=0 then FKeyWrapper.SetAsDateTime(Value);
end;


procedure TrsStorage.WriteFloat(const Key: RSLString; const Value: double);
begin
  if KeyFindAddItem(Key, True)>=0 then FKeyWrapper.SetAsFloat(Value);
end;


{$IFDEF RSL_INT64}
procedure TrsStorage.WriteInt64(const Key: RSLString; const Value: Int64);
begin
  if KeyFindAddItem(Key, True)>=0 then FKeyWrapper.SetAsInt64(Value);
end;
{$ENDIF}


procedure TrsStorage.WriteInteger(const Key: RSLString; const Value: integer);
begin
  if KeyFindAddItem(Key, True)>=0 then FKeyWrapper.SetAsInteger(Value);
end;


procedure TrsStorage.WritePoint(const Key: RSLString; const Point: TPoint);
begin
  if KeyFindAddItem(Key, True)>=0 then FKeyWrapper.SetAsPoint(Point);
end;


procedure TrsStorage.WriteStream(const Key: RSLString; Stream: TStream);
begin
  if KeyFindAddItem(Key, True)>=0 then FKeyWrapper.SetAsStream(Stream);
end;


procedure TrsStorage.WriteString(const Key: RSLString; const Value: RSLString);
begin
  if KeyFindAddItem(Key, True)>=0 then FKeyWrapper.SetAsString(Value);
end;


procedure TrsStorage.WriteText(const Key: RSLString; const Value: string);
begin
  if KeyFindAddItem(Key, True)>=0 then FKeyWrapper.SetAsString(Value);
end;

procedure TrsStorage.DoDecrypt;
begin
  if Assigned(FEncryptor) and FEncryptor.Active then begin
    FEncryptor.SetStorage(Self);
    FEncryptor.DoDecrypt;
  end;
end;


procedure TrsStorage.DoEncrypt;
begin
  if Assigned(FEncryptor) and FEncryptor.Active then begin
    FEncryptor.SetStorage(Self);
    FEncryptor.DoEncrypt;
  end;
end;

function TrsStorage.ReadPersistent(const Key: RSLString; Instance: TPersistent): boolean;
begin
  if KeyFindAddItem(Key, False)<0 then Result := False
   else Result := FKeyWrapper.SetPersistentProps(Instance);
end;

procedure TrsStorage.WritePersistent(const Key: RSLString; Instance: TPersistent);
begin
  if KeyFindAddItem(Key, True)>=0 then FKeyWrapper.GetPersistentProps(Instance);
end;

function TrsStorage.GetVersion: string;
begin
  Result := SRSLibVersion;
end;


function TrsStorage.ReadArray(const Key: RSLString; var Values: Variant): integer;
begin
 if KeyFindAddItem(Key, False)<0 then Result := 0
  else Result := FKeyWrapper.GetAsArray(Values);
end;

procedure TrsStorage.WriteArray(const Key: RSLString; const Values: Variant);
begin
  if KeyFindAddItem(Key, True)>=0 then FKeyWrapper.SetAsArray(Values);
end;


function TrsStorage.ReadPointer(const Key: RSLString; const DefValue: Pointer): Pointer;
begin
  if KeyFindAddItem(Key, False)>=0 then Result := FKeyWrapper.GetAsPointer
   else Result := DefValue;
end;

procedure TrsStorage.WritePointer(const Key: RSLString; const Value: Pointer);
begin
  if KeyFindAddItem(Key, True)>=0 then FKeyWrapper.SetAsPointer(Value);
end;

procedure TrsStorage.KeyOnDeletion(const Idx: integer);
begin
  FKeyWrapper.PKeyItem := @FKeyList^[Idx];
  FClientList.DoNotification(scnKeyDelete, Longint(FKeyList^[Idx].Name), 0);
  if Assigned(FOnKeyDeletion) then FOnKeyDeletion(Self, FKeyList^[Idx].Name);
end;

procedure TrsStorage.KeyOnAdd(const Idx: integer);
begin
  FKeyWrapper.PKeyItem := @FKeyList^[Idx];
  FClientList.DoNotification(scnKeyAdd, Longint(FKeyList^[Idx].Name), 0);
  if Assigned(FOnKeyAdd) then FOnKeyAdd(Self, FKeyList^[Idx].Name);
end;

procedure TrsStorage.KeyRename(const OldName, NewName: RSLString);
var
  i,n: integer;
  POld, PNew: PrsKeyItem;
begin
  n := KeyFindAddItem(NewName, True);
  PNew := FKeyWrapper.PKeyItem;
  i := KeyFindAddItem(OldName, False);
  POld := FKeyWrapper.PKeyItem;
  if n>=0 then begin
    if i>=0 then begin
      {copy value to new key}
      FKeyWrapper.PKeyItem := POld;
      FKeyWrapper.AssignValueTo(@PNew^.Value);
      {delete old key}
      KeyItemDelete(i,1);
      KeyCorrectIdxDel(i);
    end else begin
      KeyItemDelete(n, 1);
      KeyCorrectIdxDel(n);
    end;
  end;
end;


procedure TrsStorage.SectionRename(const OldName, NewName: RSLString);
var
  newSIdx, oldSIdx: integer;
  stream: TMemoryStream;
begin
  FClientList.Active := False;
  stream := TMemoryStream.Create;
  try
    oldSIdx := SectionFind(OldName, False);
    if oldSIdx<0 then Exit; // no old section

    newSIdx := SectionFind(NewName, True);
    if newSIdx<0 then Exit; // ?? cannot create new section?

    SectionSaveToStream(oldName, stream);
    stream.Position := 0;
    SectionLoadFromStream(newName, stream);

    // delete old section
    oldSIdx := SectionFind(OldName, False);
    SectionChildDel(oldSIdx, True);
    SectionChildCorrectIdxDel(oldSIdx);
  finally
    stream.Free;
    FClientList.Active := True;
  end;
end;

procedure TrsStorage.SetEncryptor(const Value: TrsEncryptor);
begin
  if FEncryptor<>Value then begin
    if FEncryptor<>nil then FEncryptor.SetStorage(nil);
    FEncryptor := Value;
    if FEncryptor<>nil then FEncryptor.SetStorage(Self);
  end;
end;

procedure TrsStorage.SectionLoadFromStream(const Section: RSLString; Stream: TStream);
var
  safeRootSection: RSLString;
  i: integer;
begin
  safeRootSection := RootSection;
  i := SectionFind(Section, True);
  RootSection := SectionFullName(i);
  try
    Clear;
    if Stream.Position<Stream.Size then RecursionSectionLoadFromStream(Stream);
  finally
    RootSection := safeRootSection;
  end;
end;


procedure TrsStorage.SectionSaveToStream(const Section: RSLString; Stream: TStream);
var
  i: integer;
begin
  i := SectionFind(Section, False);
  if i>=0 then i := FSectionList^[i].Id
    else
  if Length(Section)=0 then i := 0
    else Exit;

  RecursionSectionSaveToStream(i, Stream);
end;

procedure TrsStorage.RecursionSectionSaveToStream(const SectionId: integer; Stream: TStream);
var
  i, k, iSectBegin, iSectEnd, iKeyBegin, iKeyEnd: integer;
  b: byte;
  w: word;
begin
  SectionFindRange(SectionId, iSectBegin, iSectEnd);
  i := iSectEnd-iSectBegin;
  Stream.Write(i, SizeOf(Integer));

  KeyFindRange(SectionId, iKeyBegin, iKeyEnd);
  i := iKeyEnd - iKeyBegin;
  Stream.Write(i, SizeOf(Integer));

  if iSectEnd>iSectBegin then
    for i:=iSectBegin to iSectEnd-1 do begin
      b := Length(FSectionList^[i].Name);
      Stream.Write(b, SizeOf(Byte));
      k := b*SizeOf(RSLChar);
      Stream.Write(Pointer(FSectionList^[i].Name)^, k);
      RecursionSectionSaveToStream(FSectionList^[i].Id, Stream);
    end;

  if iKeyEnd>iKeyBegin then
    for i:=iKeyBegin to iKeyEnd-1 do begin
      b := Length(FKeyList^[i].Name);
      Stream.Write(b, SizeOf(Byte)); // name length
      k := b*SizeOf(RSLChar);
      Stream.Write(Pointer(FKeyList^[i].Name)^, k); //name
      w := FKeyList^[i].Value.kvType;
      Stream.Write(w, SizeOf(Word)); // data type
      with FKeyList^[i].Value do
        case kvType of
          kvtPointer:  Stream.Write(VPointer, SizeOf(Pointer));
          kvtInteger:  Stream.Write(VInteger, SizeOf(Integer));
          kvtDouble:   Stream.Write(VDouble, SizeOf(Double));
          kvtCurrency: Stream.Write(VCurrency, SizeOf(Currency));
          kvtDateTime: Stream.Write(VDateTime, SizeOf(TDateTime));
          kvtBool:     Stream.Write(VBoolean, SizeOf(Integer));
          kvtPoint:    begin
                         Stream.Write(X, SizeOf(Longint));
                         Stream.Write(Y, SizeOf(Longint));
                       end;
          kvtBuffer:   begin
                         k := Length(AnsiString(VBuffer));
                         Stream.Write(k, SizeOf(Integer));
                         Stream.Write(Pointer(VBuffer)^, k);
                       end;
          kvtString:   begin
                         k := Length(RSLString(VString));
                         k := k*SizeOf(RSLChar);
                         Stream.Write(k, SizeOf(Integer));
                         Stream.Write(Pointer(RSLString(VString))^, k);
                       end;
          {$IFDEF RSL_INT64}
          kvtInt64:    Stream.Write(VInt64, SizeOf(Int64));
          {$ENDIF}
        end; // of case
    end; // of for
end;

procedure TrsStorage.RecursionSectionLoadFromStream(Stream: TStream);
var
  i, k, iSectCount, iKeyCount, iKeyIdx: integer;
  s: RSLString;
  b: byte;
begin
  Stream.Read(iSectCount, SizeOf(Integer));
  Stream.Read(iKeyCount, SizeOf(Integer));

  if iSectCount>0 then
    for i:=0 to iSectCount-1 do begin
      Stream.Read(b, SizeOf(Byte)); //name length
      SetString(s, nil, b);
      Stream.Read(Pointer(s)^, b*SizeOf(RSLChar));

      SectionAdd(s);
      ChangeDownRootSection(s);
      RecursionSectionLoadFromStream(Stream);
      ChangeUpRootSection;
    end;

  if iKeyCount>0 then
    for i:=0 to iKeyCount-1 do begin
      Stream.Read(b, SizeOf(Byte)); //name length
      SetString(s, nil, b);
      Stream.Read(Pointer(s)^, b*SizeOf(RSLChar));

      iKeyIdx := KeyAdd(FKeyBeginIdx, FKeyEndIdx-1, SectionCurrentId, s);
      if iKeyIdx>=0 then begin
        Stream.Read(FKeyList^[iKeyIdx].Value.kvType, SizeOf(Word));
        with FKeyList^[iKeyIdx].Value do
          case kvType of
            kvtPointer:  Stream.Read(VPointer, SizeOf(Pointer));
            kvtInteger:  Stream.Read(VInteger, SizeOf(Integer));
            kvtDouble:   Stream.Read(VDouble, SizeOf(Double));
            kvtCurrency: Stream.Read(VCurrency, SizeOf(Currency));
            kvtDateTime: Stream.Read(VDateTime, SizeOf(TDateTime));
            kvtBool:     Stream.Read(VBoolean, SizeOf(Integer));
            kvtPoint:    begin
                           Stream.Read(X, SizeOf(Longint));
                           Stream.Read(Y, SizeOf(Longint));
                         end;
            kvtBuffer:   begin
                           Stream.Read(k, SizeOf(Integer));
                           SetString(AnsiString(VBuffer), nil, k);
                           Stream.Read(Pointer(VBuffer)^, k);
                         end;
            kvtString:   begin
                           Stream.Read(k, SizeOf(Integer));
                           SetString(RSLString(VString), nil, k div SizeOf(RSLChar));
                           Stream.Read(Pointer(VString)^, k);
                         end;
            {$IFDEF RSL_INT64}
            kvtInt64:    Stream.Read(VInt64, SizeOf(Int64));
            {$ENDIF}
          end; // of case

      end else;
    end;
end;

procedure TrsStorage.SectionClear(const Section: RSLString);
var
  s: RSLString;
begin
  s := RootSection;
  RootSection := Section;
  Clear;
  RootSection := s;
end;

{ TrsStorageData }

constructor TrsStorageData.Create(AOwner: TComponent);
{$IFDEF RSL_AUTOLINKREFERENCES}
var
  fs: TrsStorage;
{$ENDIF}
begin
  inherited Create(AOwner);
  FStorageList := TList.Create;
  FCurrentStorageIdx := -1;
{$IFDEF RSL_AUTOLINKREFERENCES}
  if csDesigning in ComponentState then begin
    fs := TrsStorage(rsGlobalFindComponent(TrsStorage, AOwner, nil));
    if (fs<>nil) and (fs.StorageData=nil) then fs.StorageData := self;
  end;
{$ENDIF}
end;

destructor TrsStorageData.Destroy;
begin
  if not (csDesigning in ComponentState) then
    while FStorageList.Count>0 do
      UnlinkStorage(FStorageList.Last);
  FStorageList.Free;
  inherited Destroy;
end;


procedure TrsStorageData.DoProgress;
var
  i: integer;
begin
  if Assigned(FOnProgress) and (ProgressItemCount>0) then begin
    i := (ProgressItemCurrent*100) div ProgressItemCount;
    if (i-FPreviousPercent)>0 then begin
      FOnProgress(Self, i);
      FPreviousPercent := i;
    end;
  end;
end;

function TrsStorageData.GetStorage: TrsStorage;
begin
  if (FCurrentStorageIdx>=0) and (FCurrentStorageIdx<FStorageList.Count)
    then Result := FStorageList.Items[FCurrentStorageIdx]
    else Result := nil;
end;

procedure TrsStorageData.InternalLoad;
begin
end;

procedure TrsStorageData.InternalSave;
begin
end;

procedure TrsStorageData.Load;
begin
  if Assigned(FOnBeforeLoad) then FOnBeforeLoad(Self);
  if Storage<>nil then
    try
      ProgressItemCount := 0;
      ProgressItemCurrent := 0;
      FPreviousPercent := -1;
      InternalLoad;
    finally
      Storage.RootSection := '';
      if Assigned(FOnAfterLoad) then FOnAfterLoad(Self);
    end;
end;

procedure TrsStorageData.Notification(AComponent: TComponent; Operation: TOperation);
begin
  inherited Notification(AComponent, Operation);
  if (Operation=opRemove) and (FStorageList.IndexOf(AComponent)>=0)
   then begin
     if not (csDesigning in ComponentState) and
        (csDestroying in ComponentState) and
        (Storage<>nil)
      then begin
        UnlinkStorage(AComponent as TrsStorage);
      end else FStorageList.Remove(AComponent);
   end;
end;

procedure TrsStorageData.Save;
var
  s: RSLString;
begin
  if Assigned(FOnBeforeSave) then FOnBeforeSave(Self);
  if Storage<>nil then
    try
      s := Storage.RootSection;
      Storage.RootSection := '';
      ProgressItemCount := 0;
      ProgressItemCurrent := 0;
      FPreviousPercent := -1;
      InternalSave;
    finally
      Storage.RootSection := s;
      if Assigned(FOnAfterSave) then FOnAfterSave(Self);
    end;
end;

procedure TrsStorageData.SetStorage(AStorage: TrsStorage);
var
  i: integer;
begin
  i := FStorageList.IndexOf(AStorage);
  if (AStorage<>nil) and (i<0)
    then begin
      i := FStorageList.Add(AStorage);
      FreeNotification(AStorage);
    end;
  FCurrentStorageIdx := i;
end;



procedure TrsStorageData.UnlinkStorage(AStorage: TrsStorage);
var
  i: integer;
begin
  i := FStorageList.IndexOf(AStorage);
  if i>=0 then begin
    AStorage.StorageLinkDestroying;
    AStorage.StorageData := nil;
    FStorageList.Delete(i);
  end;
end;

{ TrsStorageClient }

constructor TrsStorageClient.Create(AOwner: TComponent);
begin
  inherited;
  FActive := True;
end;

procedure TrsStorageClient.Notification(AComponent: TComponent; Operation: TOperation);
begin
  inherited Notification(AComponent, Operation);
  if (AComponent=FStorage) AND (Operation=opRemove) then FStorage := nil;
end;

procedure TrsStorageClient.rsNotification(const Value: TrsClientNotification; WParam, LParam: Longint);
begin
{}
end;

procedure TrsStorageClient.SetActive(const Value: Boolean);
begin
  FActive := Value;
end;

procedure TrsStorageClient.SetStorage(const Value: TrsStorage);
begin
  if FStorage<>Value then begin
    if FStorage<>nil then FStorage.FClientList.Remove(self);

    FStorage := Value;

    if FStorage <> nil then begin
      FreeNotification(FStorage);
      FStorage.FClientList.Add(self);
    end;
  end;
end;



{ TrsStreamData }

procedure TrsStreamData.BufferClear;
begin
  BufferStart := 1;
end;


procedure TrsStreamData.BufferFlush;
begin
  if BufferStart>1 then begin
    FCurStream.Write(Buffer, BufferStart-1);
    BufferStart := 1;
  end;
end;


procedure TrsStreamData.BufferWrite(const Buf; Count: Integer);
begin
  if (Count + BufferStart) >= CRSBufferSize then BufferFlush;
  if Count>=CRSBufferSize then FCurStream.Write(Buf,Count)
   else begin
     Move(Buf, Buffer[BufferStart], Count);
     Inc(BufferStart, Count);
   end;
end;

{$IFDEF RSL_UNICODE}
procedure TrsStreamData.BufferWriteCharW(const Value: RSLChar);
begin
  if BufferStart >= (CRSBufferSize-2) then BufferFlush;
  Buffer[BufferStart] := AnsiChar(Word(Value) and $FF);
  Buffer[BufferStart+1] := AnsiChar((Word(Value) shr 8) and $FF);
  Inc(BufferStart, 2);
end;

procedure TrsStreamData.BufferWriteCharsW(const Values: array of RSLChar);
var
  Count: integer;
begin
  Count := SizeOf(Values);
  if (Count + BufferStart) >= CRSBufferSize then BufferFlush;
  if Count>=CRSBufferSize then FCurStream.Write(Values, Count)
   else begin
     Move(Values, Buffer[BufferStart], Count);
     Inc(BufferStart, Count);
   end;
end;

procedure TrsStreamData.BufferWriteStrW(const Value: RSLString);
var
  Count: integer;
begin
  Count := Length(Value)*SizeOf(RSLChar);
  if (Count + BufferStart) >= CRSBufferSize then BufferFlush;
  if Count>=CRSBufferSize then FCurStream.Write(Pointer(Value)^, Count)
   else begin
     Move(Pointer(Value)^, Buffer[BufferStart], Count);
     Inc(BufferStart, Count);
   end;
end;
{$ENDIF}

procedure TrsStreamData.BufferWriteEOL;
const
  CMaxEolLength = 4; // WideChar #13#10
begin
  if BufferStart >= (CRSBufferSize-CMaxEolLength) then BufferFlush;
{$IFDEF RSL_WIN}
  Buffer[BufferStart] := #13;
  Inc(BufferStart);
  {$IFDEF RSL_UNICODE}
  if Unicode then begin
    Buffer[BufferStart] := #0;
    Inc(BufferStart);
  end;
  {$ENDIF}
{$ENDIF}

  Buffer[BufferStart] := #10;
  Inc(BufferStart);
  {$IFDEF RSL_UNICODE}
  if Unicode then begin
    Buffer[BufferStart] := #0;
    Inc(BufferStart);
  end;
  {$ENDIF}
end;

procedure TrsStreamData.BufferWriteFmt(const MaxLength: integer;
  const Fmt: string; const Args: array of const);
var
  i: integer;
  s: string;
begin
  if (MaxLength + BufferStart) >= CRSBufferSize then BufferFlush;
  if MaxLength>=CRSBufferSize then begin
    s := Format(Fmt,Args);
    FCurStream.Write(PChar(s)^,Length(s)*SizeOf(Char));
  end else begin
    i := FormatBuf(Buffer[BufferStart], MaxInt, Pointer(AnsiString(Fmt))^, Length(Fmt), Args);
    Inc(BufferStart, i*SizeOf(Char));
  end;
end;


procedure TrsStreamData.BufferWriteFmtA(const MaxLength: integer;
  const Fmt: AnsiString; const Args: array of const);
var
  i: integer;
  s: AnsiString;
begin
  if (MaxLength + BufferStart) >= CRSBufferSize then BufferFlush;
  if MaxLength>=CRSBufferSize then begin
    s := AnsiString(Format(String(Fmt),Args));
    FCurStream.Write(PAnsiChar(s)^,Length(s));
  end else begin
    i := FormatBuf(Buffer[BufferStart], MaxInt, Pointer(Fmt)^, Length(Fmt), Args);
    Inc(BufferStart, i);
  end;
end;

procedure TrsStreamData.BufferWriteStr(const Value: string);
var
  Count: integer;
begin
  Count := Length(Value)*Sizeof(Char);
  if Count=0 then Exit;
  if (Count + BufferStart) >= CRSBufferSize then BufferFlush;
  if Count>=CRSBufferSize then FCurStream.Write(Pointer(Value)^, Count)
   else begin
     Move(Pointer(Value)^, Buffer[BufferStart], Count);
     Inc(BufferStart, Count);
   end;
end;


procedure TrsStreamData.BufferWriteStrA(const Value: AnsiString);
var
  Count: integer;
begin
  Count := Length(Value);
  if Count=0 then Exit;
  if (Count + BufferStart) >= CRSBufferSize then BufferFlush;
  if Count>=CRSBufferSize then FCurStream.Write(Pointer(Value)^, Count)
   else begin
     Move(Pointer(Value)^, Buffer[BufferStart], Count);
     Inc(BufferStart, Count);
   end;
end;

procedure TrsStreamData.CheckCreateDirs(const Value: string);
var
  buf: array[0..RSMAX_PATH] of char;
  p: PChar;
  saveC: char;
begin
  Move(PChar(Value)^, buf, (Length(Value)+1)*SizeOf(Char));
  p := buf;
  While True do begin
   While not (p^ in [#0,'\','/']) do inc(p);
   saveC := p^;
   p^ := #0;
   if (p>Buf) and ((p-1)^<>':') then begin
   {$IFDEF RSL_WIN}  CreateDirectory(buf, nil); {$ENDIF}
   {$IFDEF RSL_KYLIX} CreateDir(buf); {$ENDIF}
   end;
   p^ := saveC;
   if p^=#0 then Break
    else Inc(p);
  end;
end;


constructor TrsStreamData.Create(AOwner: TComponent);
begin
  inherited Create(AOwner);
  FStream := TMemoryStream.Create;
  FOptions := [doAutoName];
  FFileDir := fdApplication;
{$IFDEF RSL_UNICODE}
  FUnicode := False;
{$ENDIF}
  FInternalFile := TMemoryStream.Create;
  FInternalFileLoad := iflNone;
end;


procedure TrsStreamData.DefineProperties(Filer: TFiler);

  function DoWrite: Boolean;
  var
    Item: TrsStreamData;
  begin
    Item := TrsStreamData(Filer.Ancestor);
    if Item = nil
      then Result := FInternalFile.Size<>0
      else
    if Item.FInternalFile.Size<>FInternalFile.Size
      then Result := True
      else Result := not CompareMem(Item.FInternalFile.Memory, FInternalFile.Memory, FInternalFile.Size);
  end;

begin
  inherited DefineProperties(Filer);
  Filer.DefineBinaryProperty('InternalFile', ReadData, WriteData, DoWrite);
end;

destructor TrsStreamData.Destroy;
begin
  inherited Destroy; //really needed in first position, because Save in TrsStorageData.Destroy
  FStream.Free;
  FInternalFile.Free;
end;


function TrsStreamData.GetFileName: string;
var
  s: string;
{$IFDEF RSL_WIN}
  Dir: array[0..RSMAX_PATH] of char;
  i: integer;
  ItemIDList: PItemIDList;
{$ENDIF}
begin
  case FFileDir of
   fdCustom:  Result := ExtractFilePath(FFileName);
   fdApplication:
              begin
                Result := ExtractFilePath(ParamStr(0));
              end;
{$IFDEF RSL_WIN}
   fdWindows: begin
                i := GetWindowsDirectory(Dir, RSMAX_PATH);
                SetString(Result, Dir, i);
              end;
   fdUserProfile:
              begin
                if (SHGetSpecialFolderLocation(0, CSIDL_APPDATA, ItemIDList)=NOERROR) and
                   SHGetPathFromIDList(ItemIDList, dir)
                  then Result := dir
                  else Result := '';
              end;
{$ENDIF}
  end;

  if (Length(Result)>0) and (Result[Length(Result)]<>CDirSeparator) then Result := Result + CDirSeparator;
  if (FFileDir<>fdCustom) and (Length(FFileName)>0) and (Length(ExtractFileDrive(FFileName))=0) then begin
    Result := Result + ExtractFilePath(FFileName);
    if (Length(Result)>0) and (Result[Length(Result)]<>CDirSeparator) then Result := Result + CDirSeparator;
  end;

  if doAutoName in Options
   then s := ExtractFileName(ParamStr(0))
   else s := ExtractFileName(FFileName);

  while (Length(s)>0) and (s[1]=CDirSeparator) do Delete(s, 1, 1);
  Result := Result + s;

  s := ExtractFileExt(FFileName);
  if s='' then s := FExtension;
  Result := ChangeFileExt(Result, s);
end;



procedure TrsStreamData.InternalLoad;
var
  tmpFileName: string;
  FFile: TFileStream;
  DoStandard, flRealFile: boolean;
  ResultStream: TMemoryStream;
begin
  FStream.Clear;
  DoStandard := not Assigned(FOnLoadFromStream);
  if Assigned(FOnLoadFromStream) then FOnLoadFromStream(Self, FStream, DoStandard);

  ResultStream := FStream;
  if DoStandard then begin
    tmpFileName := GetFileName;
    flRealFile := FileExists(tmpFileName);

    if (InternalFileLoad=iflAlways) or ((InternalFileLoad=iflNoRealFile) and (not flRealFile))
      then ResultStream := FInternalFile //load from internal file
      else
    if flRealFile then begin // load from real file
      FFile := TFileStream.Create(tmpFileName, fmOpenRead or fmShareDenyWrite);
      try
        FStream.LoadFromStream(FFile);
      finally
        FFile.Free;
      end;
    end;
  end;

  ResultStream.Position := 0;
  if ResultStream.Size>0 then begin
    LoadFromStream(ResultStream); // 09.04.2001
    if DoStandard and (ResultStream<>FInternalFile) then //fix internalfile clearing
      ResultStream.Clear; // 04.02.2003 free memory
  end;
end;


procedure TrsStreamData.InternalSave;
var
  DoStandard: boolean;
  s: string;
begin
  FStream.Clear;
  SaveToStream(FStream);
  FStream.Position := 0;
  DoStandard := not Assigned(FOnSaveToStream);
  if Assigned(FOnSaveToStream) then FOnSaveToStream(Self, FStream, DoStandard);

  if DoStandard then begin
    s := GetFileName;
    if doAutoCreateDir in Options then CheckCreateDirs(ExtractFilePath(s));
    FStream.SaveToFile(s);
  end;
end;


procedure TrsStreamData.LoadFromStream(Stream: TStream);
begin
  FCurStream := Stream;
end;

procedure TrsStreamData.SaveToStream(Stream: TStream);
begin
  FCurStream := Stream;
end;


procedure TrsStreamData.SetFileDir(const Value: TrsStreamFileDir);
begin
  FFileDir := Value;
end;

procedure TrsStreamData.SetFileName(const Value: string);
begin
  if FFileName <> Value then begin
    FFileName := Value;
    if csDesigning in ComponentState then begin
      if (ExtractFileDrive(Value)<>'') and
         (ExtractFileDir(Value)<>'') and
         (FileDir<>fdCustom) then FileDir := fdCustom;
      if (ExtractFileName(Value)<>'') and (doAutoName in Options)
        then Options := Options - [doAutoName];
    end;
  end;
end;

procedure TrsStreamData.SetInternalFileName(const Value: string);
begin
  if Value<>FInternalFileName then begin
    if FileExists(Value) then begin
      FInternalFile.LoadFromFile(Value);
      FInternalFile.Position := 0;
      FInternalFileName := Value;
      if (csDesigning in ComponentState) and (FInternalFileLoad=iflNone)
        then FInternalFileLoad := iflNoRealFile;
    end else begin
      FInternalFile.Clear;
      FInternalFileName := '';
      if csDesigning in ComponentState then FInternalFileLoad := iflNone;
    end;
  end;
end;

procedure TrsStreamData.ReadData(Stream: TStream);
var
  b: byte;
  i: integer;
  ms: TMemoryStream;
begin
  Stream.Read(b, SizeOf(b)); // read version info
  Stream.Read(b, SizeOf(b)); // read flags
  Stream.Read(i, SizeOf(i)); // read size of data

  ms := TMemoryStream.Create;
  try
    ms.SetSize(i);
    Stream.Read(ms.Memory^, i); // read data
    ms.Position := 0;
    rsLZRWStreamDecompression(ms, FInternalFile);
    FInternalFile.Position := 0;
  finally
    ms.Free;
  end;
end;

procedure TrsStreamData.WriteData(Stream: TStream);
var
  b: byte;
  i: integer;
  ms: TMemoryStream;
begin
  b := 1;
  Stream.Write(b, SizeOf(b)); // write version info
  b := 1;
  Stream.Write(b, SizeOf(b)); // write flags ($1 - compressed)

  ms := TMemoryStream.Create;
  try
    FInternalFile.Position := 0;
    rsLZRWStreamCompression(FInternalFile, ms);
    FInternalFile.Position := 0;
    i := ms.Size;
    Stream.Write(i, SizeOf(i)); // write size of data
    Stream.Write(ms.Memory^, i); // write data
  finally
    ms.Free;
  end;
end;

{ TrsKeyWrapper }

procedure TrsKeyWrapper.Clear;
begin
  if Assigned(PKeyItem) then
    FinalizeKeyValue(@PKeyItem^.Value);
end;

destructor TrsKeyWrapper.Destroy;
begin
//  Clear; 
  TempClassesActive(False);
  inherited;
end;


function TrsKeyWrapper.GetAsFloat: Double;
begin
  with PKeyItem^.Value do
    case kvType of
      kvtString:   Result := StrToFloat(RSLString(VString));
      kvtInteger:  Result := VInteger;
      kvtUnknown,
      kvtDouble:   Result := VDouble;
      kvtCurrency: Result := VCurrency;
  {$IFDEF RSL_INT64}
      kvtInt64:    Result := VInt64;
  {$ENDIF}
      else begin
        if (kvType=kvtBuffer) and (Length(AnsiString(PKeyItem^.Value.VBuffer))=SizeOf(Double)) then begin
          Result := Double(VBuffer^);
        end else begin
          rsError(egGetKeyValue, Format(SErrGetKeyValue,[FullName, 'float']));
          Result := 0.0;
        end;
      end;
    end;
end;

{$IFDEF RSL_INT64}

function TrsKeyWrapper.GetAsInt64: Int64;
begin
  with PKeyItem^.Value do
    case kvType of
      kvtString:  Result := StrToInt64(RSLString(VString));
      kvtInteger: Result := VInteger;
      kvtDouble:  Result := Round(VDouble);
      kvtCurrency:Result := Round(VCurrency);
      kvtUnknown,
      kvtInt64:   Result := VInt64;
      else begin
        if (kvType=kvtBuffer) and (Length(AnsiString(PKeyItem^.Value.VBuffer))=SizeOf(Int64)) then begin
          Result := Int64(VBuffer^);
        end else begin
          rsError(egGetKeyValue, Format(SErrGetKeyValue,[FullName, 'Int64']));
          Result := 0;
        end;
      end;
    end;
end;
{$ENDIF}


function TrsKeyWrapper.GetAsInteger: integer;
begin
  with PKeyItem^.Value do
    case kvType of
      kvtString:  Result := StrToInt(RSLString(VString));
      kvtUnknown,
      kvtInteger: Result := VInteger;
      kvtDouble:  Result := Round(VDouble);
      kvtCurrency:Result := Round(VCurrency);
      kvtDateTime:Result := Round(VDateTime);
      kvtBool:    if VBoolean then Result := 1 else Result := 0;
  {$IFDEF RSL_INT64}
      kvtInt64:   Result := VInt64;
  {$ENDIF}
      else begin
        if (kvType=kvtBuffer) and (Length(AnsiString(PKeyItem^.Value.VBuffer))=SizeOf(Integer)) then begin
          Result := Integer(VBuffer^);
        end else begin
          rsError(egGetKeyValue, Format(SErrGetKeyValue,[FullName, 'integer']));
          Result := 0;
        end;
      end;
    end;
end;


function TrsKeyWrapper.GetAsString: RSLString;
begin
  with PKeyItem^.Value do
    case kvType of
      kvtUnknown: Result := '';
      kvtBuffer:  Result := RSLString(BinBufToHexStr(VBuffer, Length(AnsiString(VBuffer))));
      kvtString:  Result := RSLString(VString);
      kvtPointer,
      kvtInteger: Result := IntToStr(VInteger);
      kvtDouble:  Result := FloatToStr(VDouble);
      kvtCurrency:Result := CurrToStr(VCurrency);
      kvtDateTime:Result := DateTimeToStr(VDateTime);
      kvtPoint:   Result := Format('(%d,%d)',[X, Y]);
      kvtBool:    if VBoolean
                    then Result := RSBooleanIdentsTrue
                    else Result := RSBooleanIdentsFalse;
  {$IFDEF RSL_INT64}
      kvtInt64:   Result := IntToStr(VInt64);
  {$ENDIF}
      else begin
        rsError(egGetKeyValue, Format(SErrGetKeyValue,[FullName, 'string']));
        Result := '';
      end;
    end;
end;


function TrsKeyWrapper.GetAsVariant: Variant;
begin
with PKeyItem^.Value do
  case kvType of
    kvtInteger:  Result := VInteger;
    kvtDouble:   Result := VDouble;
    kvtCurrency: Result := VCurrency;
    kvtDateTime: Result := VDateTime;
    kvtBool:     Result := VBoolean;
    kvtBuffer:   Result := AnsiString(VBuffer);
    kvtString:   Result := RSLString(VString);
    kvtPoint,
    kvtUnknown:  Result := Unassigned;
{$IFDEF RSL_INT64}
    //DONE: возвращать int64 только начиная с какой версии дельфи?
  {$IFDEF RSL_D6GE}
    kvtInt64:    Result := VInt64;
  {$ELSE}
    kvtInt64:    Result := Unassigned;
  {$ENDIF}
{$ENDIF}
    kvtPointer:  Result := Integer(VPointer);
    else Result := Unassigned;
  end;
end;

procedure TrsKeyWrapper.GetComponentProps(Instance: TComponent);
var
  size: integer;
begin
  Clear;
  TempClassesActive(True);

  FMemStream.WriteComponent(Instance);
  size := FMemStream.Size;
  with PKeyItem^.Value do begin
    kvType := kvtBuffer;
    SetLength(AnsiString(VBuffer), size);
    FMemStream.Position := 0;
    FMemStream.ReadBuffer(VBuffer^, size);
  end;
end;


procedure TrsKeyWrapper.SetAsFloat(const Value: Double);
begin
  Clear;
  with PKeyItem^.Value do begin
    kvType := kvtDouble;
    VDouble := Value;
  end;
end;

{$IFDEF RSL_INT64}
procedure TrsKeyWrapper.SetAsInt64(const Value: Int64);
begin
  Clear;
  with PKeyItem^.Value do begin
    kvType := kvtInt64;
    VInt64 := Value;
  end;
end;
{$ENDIF}

procedure TrsKeyWrapper.SetAsInteger(const Value: integer);
begin
  Clear;
  with PKeyItem^.Value do begin
    kvType := kvtInteger;
    VInteger := Value;
  end;
end;


procedure TrsKeyWrapper.SetAsString(const Value: RSLString);
begin
  Clear;
  with PKeyItem^.Value do begin
    kvType := kvtString;
    RSLString(VString) := Value;
  end;
end;

procedure TrsKeyWrapper.SetAsVariant(const Value: Variant);
begin
  with PKeyItem^.Value do begin
    Clear;
    case VarType(Value) of
     varEmpty,
     varNull:     begin kvType := kvtUnknown;  VUnknown := nil; end;
     varByte,
     varSmallint,
     varInteger:  begin kvType := kvtInteger;  VInteger := Value; end;
     varSingle,
     varDouble:   begin kvType := kvtDouble;   VDouble  := Value; end;
     varCurrency: begin kvType := kvtCurrency; VCurrency := Value; end;
     varDate:     begin kvType := kvtDateTime; VDateTime := Value; end;
     varBoolean:  begin kvType := kvtBool;     VBoolean := Value; end;
     varOleStr,
     varString:   begin
                    kvType := kvtString;
                    RSLString(VString) := RSLString(Value);
                  end;
{$IFDEF RSL_INT64}
  {$IFDEF RSL_D6GE}
     varInt64:   begin
                   kvType := kvtInt64;
                   VInt64 := Value;
                 end;
  {$ENDIF}
{$ENDIF}
{$ifdef RSL_BDS6}
     varUString: begin
                    kvType := kvtString;
                    RSLString(VString) := RSLString(Value);
                 end;
{$endif}
    end;
  end;
end;

function TrsKeyWrapper.SetComponentProps(Instance: TComponent): TComponent;
begin
  TempClassesActive(True);
  with PKeyItem^.Value do begin
    FMemStream.WriteBuffer(VBuffer^, Length(AnsiString(VBuffer)));
    FMemStream.Position := 0;
    Result := FMemStream.ReadComponent(Instance);
  end;
end;


{$IFDEF RSL_CB4LE}
type
  THackReader = class(TReader);
{$ELSE}
type
  THackWriter = class(TWriter);
  THackReader = class(TReader);
{$ENDIF}


function TrsKeyWrapper.GetPersistentProps(Instance: TPersistent): boolean;
var
{$IFDEF RSL_CB4LE}
  p: pointer;
{$ENDIF}
  size: integer;
  FWriter: TWriter;
begin
  TempClassesActive(True);
  FWriter := TWriter.Create(FMemStream, 4096);
  try
{$IFDEF RSL_CB4LE} // hacking: calculate address of WriteProperties method in Delphi3,4,CBulder3,4
    p := @TWriter.WriteCollection;
    if PByte(p)^=$FF then begin //skip jmp table (for package)
      Inc(PByte(p), $2);
      p := Pointer(PInteger(p)^);
      p := Pointer(PInteger(p)^);
    end;
  {$IFDEF RSL_CB3}
    Inc(PByte(p), $47);
  {$ELSE}
    Inc(PByte(p), $37);
  {$ENDIF}
    if PByte(PChar(p)-1)^<>$E8 then begin Result := False; exit; end;
    Inc(PByte(p), PInteger(p)^+4);
    if PByte(p)^<>$55 then begin Result := False; exit; end;
    asm
      push eax
      push edx
      mov eax, FWriter
      mov edx, Instance
      call p
      pop edx
      pop eax
    end;
{$ELSE}
    THackWriter(FWriter).WriteProperties(Instance);
{$ENDIF}

    FWriter.WriteListEnd;
    FWriter.FlushBuffer;

    Clear;
    size := FMemStream.Size;
    PKeyItem^.Value.kvType := kvtBuffer;
    SetLength(AnsiString(PKeyItem^.Value.VBuffer), size);
    FMemStream.Position := 0;
    FMemStream.ReadBuffer(PKeyItem^.Value.VBuffer^, size);
    Result := True;
  finally
   FWriter.Free;
  end;
end;


function TrsKeyWrapper.SetPersistentProps(Instance: TPersistent): boolean;
var
{$IFDEF RSL_CB3LE}
  p: pointer;
{$ENDIF}
  FReader: TReader;
begin
  TempClassesActive(True);
  FReader := TReader.Create(FMemStream, 4096);
  try
    FMemStream.Write(PAnsiChar(PKeyItem^.Value.VBuffer)^, Length(AnsiString(PKeyItem^.Value.VBuffer)));

  // hacking: calculate address of ReadProperty method in Delphi3, CBuilder3
  {$IFDEF RSL_CB3LE}
    p := @TReader.ReadCollection;
    if PByte(p)^=$FF then begin  //skip jmp table (for package)
      Inc(PByte(p), $2);
      p := Pointer(PInteger(p)^);
      p := Pointer(PInteger(p)^);
    end;

    {$IFDEF RSL_CB3}
      Inc(PByte(p), $6A);
    {$ELSE}
      Inc(PByte(p), $62);
    {$ENDIF}
    if PByte(PChar(p)-1)^<>$E8 then begin Result := False; Exit; end;
    Inc(PByte(p), PInteger(p)^+4);
    if PByte(p)^<>$55 then begin Result := False; Exit; end;
  {$ENDIF}

    FMemStream.Position := 0;
    if FMemStream.Size>0 then  // 09.04.2001
      while not FReader.EndOfList do
    {$IFDEF RSL_CB3LE}
        asm
         push eax
         push edx
         mov eax, FReader
         mov edx, Instance
         call p
         pop edx
         pop eax
        end;
    {$ELSE}
       THackReader(FReader).ReadProperty(Instance);
    {$ENDIF}
       Result := True;
  finally
    FReader.Free;
  end;
end;



procedure TrsKeyWrapper.TempClassesActive(const Value: boolean);
begin
  if Value then begin
    if FMemStream=nil then FMemStream := TMemoryStream.Create
     else FMemStream.Clear;
  end else begin
    if FMemStream<>nil then begin FMemStream.Free; FMemStream := nil; end;
  end;
end;


procedure TrsKeyWrapper.AssignValueTo(PKey: PrsKeyValue);
begin
  FinalizeKeyValue(PKey);
  with PKeyItem^.Value do begin
    PKey^.Options := Options;
    PKey^.kvType := kvType;
    case kvType of
      kvtUnknown:  PKey^.VUnknown := nil;
      kvtBuffer:   AnsiString(PKey^.VBuffer) := AnsiString(VBuffer);
      kvtString:   RSLString(PKey^.VString) := RSLString(VString);
      kvtInteger:  PKey^.VInteger := VInteger;
      kvtDouble:   PKey^.VDouble := VDouble;
      kvtCurrency: PKey^.VCurrency := VCurrency;
      kvtDateTime: PKey^.VDateTime := VDateTime;
      kvtBool:     PKey^.VBoolean := VBoolean;
      kvtPoint:    begin PKey^.X := X; PKey^.Y := Y; end;
  {$IFDEF RSL_INT64}
      kvtInt64:    PKey^.VInt64 := VInt64;
  {$ENDIF}
      kvtPointer:  PKey^.VPointer := VPointer;
    end;
  end;
end;

function TrsKeyWrapper.GetAsDateTime: TDateTime;
begin
  with PKeyItem^.Value do
    case kvType of
      kvtString:   Result := StrToDateTime(RSLString(VString));
      kvtInteger:  Result := VInteger;
      kvtDouble:   Result := TDateTime(VDouble);
      kvtUnknown,
      kvtDateTime: Result := VDateTime;
  {$IFDEF RSL_INT64}
      kvtInt64:    Result := VInt64;
  {$ENDIF}
      else begin
        if (kvType=kvtBuffer) and (Length(AnsiString(PKeyItem^.Value.VBuffer))=SizeOf(TDateTime)) then begin
          Result := TDateTime(VBuffer^);
        end else begin
          rsError(egGetKeyValue, Format(SErrGetKeyValue,[FullName, 'DateTime']));
          Result := 0;
        end;
      end;
    end;
end;

procedure TrsKeyWrapper.SetAsDateTime(const Value: TDateTime);
begin
  Clear;
  with PKeyItem^.Value do begin
    kvType := kvtDateTime;
    VDateTime := Value;
  end;
end;

function TrsKeyWrapper.GetAsBoolean: boolean;
begin
  with PKeyItem^.Value do
    case kvType of
      kvtString:   begin
                     if RSLCompareText(RSBooleanIdentsTrue, RSLString(VString))=0
                      then Result := True
                      else
                     if RSLCompareText(RSBooleanIdentsFalse, RSLString(VString))=0
                      then Result := False
                      else begin
                        Result := False; // off warning only
                        rsError(egGetKeyValue, Format(SErrGetKeyValue,[FullName, 'boolean']));
                      end;
                   end;
      kvtInteger:  Result := VInteger<>0;
      kvtDouble,
      kvtCurrency: Result := VCurrency<>0.0;
      kvtUnknown,
      kvtBool: Result := VBoolean;
  {$IFDEF RSL_INT64}
      kvtInt64: Result := VInt64<>0;
  {$ENDIF}
      else begin
        rsError(egGetKeyValue, Format(SErrGetKeyValue,[FullName, 'boolean']));
        Result := False; // off warning only
      end;
    end;
end;

function TrsKeyWrapper.GetAsCurrency: Currency;
begin
  with PKeyItem^.Value do
    case kvType of
      kvtString:   Result := StrToCurr(RSLString(VString));
      kvtInteger:  Result := VInteger;
      kvtUnknown,
      kvtDouble,
      kvtCurrency: Result := VCurrency;
  {$IFDEF RSL_INT64}
      kvtInt64: Result := VInt64;
  {$ENDIF}
      else begin
        if (kvType=kvtBuffer) and (Length(AnsiString(PKeyItem^.Value.VBuffer))=SizeOf(Currency)) then begin
          Result := Currency(VBuffer^);
        end else begin
          rsError(egGetKeyValue, Format(SErrGetKeyValue,[FullName, 'currency']));
          Result := 0; // off warning only
        end;
      end;
    end;
end;

procedure TrsKeyWrapper.SetAsBoolean(const Value: boolean);
begin
  Clear;
  with PKeyItem^.Value do begin
    kvType := kvtBool;
    VBoolean := Value;
  end;
end;

procedure TrsKeyWrapper.SetAsCurrency(const Value: currency);
begin
  Clear;
  with PKeyItem^.Value do begin
    kvType := kvtCurrency;
    VCurrency := Value;
  end;
end;

function TrsKeyWrapper.GetAsBuffer(var Buffer; const Count: Integer): Longint;
begin
  with PKeyItem^.Value do
    case kvType of
      kvtString:begin
                  Result := Length(RSLString(VString))*SizeOf(RSLChar);
                  if Count>0 then  begin
                    if Count<Result then Result := Count;
                    Move(VString^, Buffer, Result);
                  end;
                end;
      kvtBuffer:begin
                  Result := Length(AnsiString(VBuffer));
                  if Count>0 then  begin
                    if Count<Result then Result := Count;
                    Move(VBuffer^, Buffer, Result);
                  end;
                end;
      else Result := 0;
    end;
end;


procedure TrsKeyWrapper.SetAsBuffer(const Buffer; const Count: Integer);
begin
  Clear;
  with PKeyItem^.Value do begin
    kvType := kvtBuffer;
    SetLength(AnsiString(VBuffer), Count);
    Move(Buffer, VBuffer^, Count);
  end;
end;

function TrsKeyWrapper.GetAsPoint: TPoint;
begin
  with PKeyItem^.Value do
    if kvType in [kvtUnknown,kvtPoint] then begin
       Result.x := X;
       Result.y := Y;
    end else rsError(egGetKeyValue, Format(SErrGetKeyValue,[FullName, 'point']));
end;

procedure TrsKeyWrapper.SetAsPoint(const Value: TPoint);
begin
  Clear;
  with PKeyItem^.Value do begin
    kvType := kvtPoint;
    X := Value.x;
    Y := Value.y;
  end;
end;

procedure TrsKeyWrapper.AssignValue(PKey: PrsKeyValue);
begin
  FinalizeKeyValue(@PKeyItem^.Value);
  with PKeyItem^.Value do begin
    Options := PKey^.Options;
    kvType := PKey^.kvType;
    case kvType of
      kvtUnknown:  VUnknown := nil;
      kvtBuffer:   AnsiString(VBuffer) := AnsiString(PKey^.VBuffer);
      kvtString:   RSLString(VString) := RSLString(PKey^.VString);
      kvtInteger:  VInteger := PKey^.VInteger;
      kvtDouble:   VDouble := PKey^.VDouble;
      kvtCurrency: VCurrency := PKey^.VCurrency;
      kvtDateTime: VDateTime := PKey^.VDateTime;
      kvtBool:     VBoolean := PKey^.VBoolean;
      kvtPoint:    begin X := PKey^.X; Y := PKey^.Y; end;
  {$IFDEF RSL_INT64}
      kvtInt64:    VInt64 := PKey^.VInt64;
  {$ENDIF}
      kvtPointer:  VPointer := PKey^.VPointer;
    end;
  end;
end;


procedure TrsStreamData.SetOptions(const Value: TrsStreamDataOptions);
begin
  FOptions := Value;
end;


function TrsKeyWrapper.GetAsArray(var Values: Variant): integer;
var
   i, iLen, iType, iInt: integer;
   iFloat: double;
   iCurrency: currency;
   iDate: TDateTime;
   iBool: boolean;
   iByte: Byte;
   iSmallint: Smallint;
   iSingle: Single;
   iAString: AnsiString;
   iRSLString: RSLString;
begin
  TempClassesActive(True);
  FMemStream.WriteBuffer(PKeyItem^.Value.VBuffer^, Length(AnsiString(PKeyItem^.Value.VBuffer)));
  FMemStream.Position := 0;

  Result := Unassigned;
  if FMemStream.Size = 0 then Exit;

  FMemStream.Read(iLen, SizeOf(iLen));
  Result := iLen;
  Values := VarArrayCreate([0,iLen-1], varVariant);
  VarArrayLock(Values);
  try
    for i:=0 to iLen-1 do begin
      FMemStream.Read(iType, SizeOf(iType));
      case iType of
        varSmallint:
          begin
            FMemStream.Read(iSmallint, SizeOf(iSmallint));
            Values[i] := iSmallint;
          end;
        varSingle:
          begin
            FMemStream.Read(iSingle, SizeOf(iSingle));
            Values[i] := iSingle;
          end;
        varString,
        varOleStr:
          begin
            FMemStream.Read(iInt, SizeOf(iInt));
            if (iInt or Integer($80000000))>0 then begin
              iInt := iInt and $7FFFFFFF;
              SetLength(iRSLString, iInt div SizeOf(RSLChar));
              if iInt>0 then FMemStream.Read(Pointer(iRSLString)^, iInt)
                else iRSLString := '';
              Values[i] := iRSLString;
            end else begin
              SetLength(iAString, iInt);
              if iInt>0 then FMemStream.Read(Pointer(iAString)^, iInt)
                else iAString := '';
              Values[i] := iAString;
            end;
          end;
        varInteger:
          begin
            FMemStream.Read(iInt, SizeOf(iInt));
            Values[i] := iInt;
          end;
        varDouble:
          begin
            FMemStream.Read(iFloat, SizeOf(iFloat));
            Values[i] := iFloat;
          end;
        varCurrency:
          begin
            FMemStream.Read(iCurrency, SizeOf(iCurrency));
            Values[i] := iCurrency;
          end;
       varBoolean:
          begin
            FMemStream.Read(iBool, SizeOf(iBool));
            Values[i] := iBool;
          end;
       varDate:
          begin
            FMemStream.Read(iDate, SizeOf(iDate));
            Values[i] := iDate;
          end;
       varByte:
          begin
            FMemStream.Read(iByte, SizeOf(iByte));
            Values[i] := iByte;
          end;
      end;
    end;
  finally
    VarArrayUnlock(Values);
  end;
end;

procedure TrsKeyWrapper.SetAsArray(const Values: variant);
var
   iH, iL, iLen: integer;
   iInt, i: integer;
   iFloat: double;
   iCurrency: currency;
   iDate: TDateTime;
   iBool: boolean;
   iByte: Byte;
   iSmallint: Smallint;
   iSingle: Single;
   iAString: AnsiString;
   iRSLString: RSLString;
begin
  Clear;
  TempClassesActive(True);

  iH := VarArrayHighBound(Values,1);
  iL := VarArrayLowBound(Values,1);
  iLen := iH -iL + 1;

  FMemStream.Write(iLen, SizeOf(iLen));
  for i := iL to iH do begin
    iInt := VarType(Values[i]);
    FMemStream.Write(iInt, SizeOf(iInt));
    case iInt of
      varSmallint:
        begin
          iSmallint := Values[i];
          FMemStream.Write(iSmallint, SizeOf(iSmallint));
        end;
      varSingle:
        begin
          iSingle := Values[i];
          FMemStream.Write(iSingle, SizeOf(iSingle));
        end;
{$ifdef RSL_BDS6}
     varUString,
{$endif}
      varString,
      varOleStr:
        begin
          iRSLString := Values[i];
          if IsUnicodeString(iRSLString) then begin
            iInt := Length(iRSLString)*SizeOf(RSLChar);
            iLen := iInt or Integer($80000000);
            FMemStream.Write(iLen, SizeOf(iLen));
            if iInt > 0 then FMemStream.Write(Pointer(iRSLString)^, iInt);
          end else begin
            iAString := AnsiString(iRSLString);
            iInt := Length(iAString);
            FMemStream.Write(iInt, SizeOf(iInt));
            if iInt > 0 then FMemStream.Write(Pointer(iAString)^, iInt);
          end;
        end;
      varInteger:
        begin
          iInt := Values[i];
          FMemStream.Write(iInt, SizeOf(iInt));
        end;
      varDouble:
        begin
          iFloat := Values[i];
          FMemStream.Write(iFloat, SizeOf(iFloat));
        end;
      varCurrency:
        begin
          iCurrency := Values[i];
          FMemStream.Write(iCurrency, SizeOf(iCurrency));
        end;
      varBoolean:
        begin
          iBool := Values[i];
          FMemStream.Write(iBool, SizeOf(iBool));
        end;
      varDate:
        begin
          iDate := Values[i];
          FMemStream.Write(iDate, SizeOf(iDate));
        end;
      varByte:
        begin
          iByte := Values[i];
          FMemStream.Write(iByte, SizeOf(iByte));
        end;
      else begin
          rsError(egSetKeyValue, Format(SErrSetKeyValue,[FullName, 'array']));
          Exit;
      end;
    end;
  end;

  PKeyItem^.Value.kvType := kvtBuffer;
  SetLength(AnsiString(PKeyItem^.Value.VBuffer), FMemStream.Size);
  FMemStream.Position := 0;
  FMemStream.ReadBuffer(PKeyItem^.Value.VBuffer^, FMemStream.Size);
end;


function TrsKeyWrapper.GetAsPointer: Pointer;
begin
  with PKeyItem^.Value do
    if kvType in [kvtInteger,kvtPointer,kvtString,kvtBuffer] then begin
      Result := VPointer;
    end else begin
      Result := nil;
      rsError(egGetKeyValue, Format(SErrGetKeyValue,[FullName, 'pointer']));
    end;
end;

procedure TrsKeyWrapper.SetAsPointer(const Value: Pointer);
begin
  Clear;
  with PKeyItem^.Value do begin
    kvType := kvtPointer;
    VPointer := Value;
  end;
end;

function TrsKeyWrapper.GetKeyType: word;
begin
  Result := PKeyItem^.Value.kvType;
end;

procedure TrsKeyWrapper.SetKeyType(const Value: word);
begin
  PKeyItem^.Value.kvType := Value;
end;

function TrsKeyWrapper.GetKeyOptions: word;
begin
  Result := PKeyItem^.Value.Options;
end;

procedure TrsKeyWrapper.SetKeyOptions(const Value: word);
begin
  PKeyItem^.Value.Options := Value;
end;

function TrsKeyWrapper.GetName: RSLString;
begin
  Result := PKeyItem^.Name;
end;


constructor TrsKeyWrapper.Create(AOwner: TrsStorage);
begin
  FStorage := AOwner;
end;

function TrsKeyWrapper.GetAsStream(Stream: TStream): integer;
begin
  with PKeyItem^.Value do
    case kvType of
      kvtString:begin
                  Result := Length(RSLString(VString))*SizeOf(RSLChar);
                  if Result>0 then Stream.Write(VString^, Result);
                end;
      kvtBuffer:begin
                  Result := Length(AnsiString(VBuffer));
                  if Result>0 then Stream.Write(VBuffer^, Result);
                end;
      else Result := 0;
    end;
end;

procedure TrsKeyWrapper.SetAsStream(Stream: TStream);
var
  size: integer;
begin
  Clear;
  with PKeyItem^.Value do begin
    kvType := kvtBuffer;
    size := Stream.Size;
    SetLength(AnsiString(VBuffer), size);
    Stream.Position := 0;
    Stream.ReadBuffer(VBuffer^, size);
  end;
end;

function TrsKeyWrapper.GetSectionName: RSLString;
var
  i: integer;
begin
  Result := '';
  if (not Assigned(PKeyItem)) or (not Assigned(Storage)) then Exit;

  i := SectionIndex;
  if i>=0 then Result := Storage.GetSectionItem(i)^.Name;
end;

function TrsKeyWrapper.GetSectionFullName: RSLString;
var
  i: integer;
begin
  Result := '';
  if (not Assigned(PKeyItem)) or (not Assigned(Storage)) then Exit;

  i := SectionIndex;
  if i>=0 then Result := Storage.SectionFullName(i);
end;

function TrsKeyWrapper.GetSectionLevel: integer;
var
  i: integer;
begin
  Result := 0;
  if (not Assigned(PKeyItem)) or (not Assigned(Storage)) then Exit;

  i := SectionIndex;
  if i>=0 then Result := Storage.SectionLevel(i);
end;

function TrsKeyWrapper.SectionIndex: integer;
begin
  if (FCacheSectionIdx>=0) and
     (FCacheSectionIdx<Storage.SectionCountAll) and
     (Storage.FSectionList^[FCacheSectionIdx].Id = PKeyItem^.SectionId)
   then Result := FCacheSectionIdx
   else begin
     Result := Storage.SectionFindById(0, Storage.SectionCountAll-1, PKeyItem^.SectionId);
     FCacheSectionIdx := Result;
   end;
end;

function TrsKeyWrapper.GetFullName: RSLString;
begin
  Result := '\' + SectionFullName + '\' + Name;
end;

function TrsKeyWrapper.EqualValue(PKey: PrsKeyValue): boolean;
begin
  Result := False;
  with PKeyItem^.Value do begin
    if kvType<>PKey^.kvType then Exit;

    case kvType of
      kvtUnknown:;
      kvtBuffer:   if not CompareMem(VBuffer, PKey^.VBuffer, Length(AnsiString(PKey^.VBuffer))) then Exit;
      kvtString:   if RSLString(VString) <> RSLString(PKey^.VString) then Exit;
      kvtInteger:  if VInteger <> PKey^.VInteger then Exit;
      kvtDouble:   if VDouble <> PKey^.VDouble then Exit;
      kvtCurrency: if VCurrency <> PKey^.VCurrency then Exit;
      kvtDateTime: if not RSLSameDateTime(VDateTime, PKey^.VDateTime) then Exit;
      kvtBool:     if VBoolean <> PKey^.VBoolean then Exit;
      kvtPoint:    if (X<>PKey^.X) or (Y<>PKey^.Y) then Exit;
  {$IFDEF RSL_INT64}
      kvtInt64:    if VInt64 <> PKey^.VInt64 then Exit;
  {$ENDIF}
      kvtPointer:  if VPointer <> PKey^.VPointer then Exit;
    end;
  end;
  Result := True;
end;

{ TrsClientList }

function TrsClientList.Add(Instance: TrsStorageClient): integer;
var
  cl: TrsClientNotification;
begin
  Result := FList.IndexOf(Instance);
  if Result<0 then begin
    Result := FList.Add(Instance);
    for cl:=Low(TrsClientNotification) to High(TrsClientNotification) do
      if cl in Instance.FNotifications then AddToArray(cl, Instance);
  end;
end;

procedure TrsClientList.AddToArray(Cn: TrsClientNotification; Instance: TrsStorageClient);
var
  Item: PrsClientItem;
  i: integer;
begin
  Item := @FItems[Cn];
  if Item^.Count=Item^.Capacity then begin
    i := Item^.Capacity;
    if i=0 then i := 2
     else i := i * 2;
    ReallocMem(Item^.Data, i*SizeOf(Pointer));
    FillChar(Item^.Data^[Item.Count], (i-Item^.Capacity)*SizeOf(Pointer), 0);
    Item^.Capacity := i;
  end;
  Item^.Data^[Item^.Count] := Instance;
  Inc(Item^.Count);
  Item^.Exists := True;
end;

procedure TrsClientList.Clear;
var
  cl: TrsClientNotification;
begin
  FList.Clear;
  for cl:=Low(TrsClientNotification) to High(TrsClientNotification) do begin
    FItems[cl].Exists := False;
    FItems[cl].Count := 0;
    FreeMem(FItems[cl].Data, FItems[cl].Capacity*SizeOf(Pointer));
    FItems[cl].Capacity := 0;
    FItems[cl].Data := nil;
  end;
end;

function TrsClientList.Count: integer;
begin
  Result := FList.Count;
end;

constructor TrsClientList.Create;
begin
  FList := TList.Create;
  FillChar(FItems, SizeOf(TrsClientItem)*(Ord(High(TrsClientNotification))-Ord(Low(TrsClientNotification))), 0);
  FActive := True;
end;

procedure TrsClientList.Delete(Index: integer);
var
  Instance: TrsStorageClient;
  cl: TrsClientNotification;
begin
  if (Index>=0) and (Index<FList.Count) then begin
    Instance := FList.Items[Index];
    for cl:=Low(TrsClientNotification) to High(TrsClientNotification) do begin
      if cl in Instance.FNotifications then DeleteFromArray(cl, Instance);
    end;
  end;
end;


procedure TrsClientList.DeleteFromArray(Cn: TrsClientNotification; Instance: TrsStorageClient);
var
  Item: PrsClientItem;
  i,k: integer;
begin
  Item := @FItems[Cn];
  k := -1;
  for i:=0 to Item^.Count-1 do //find instance in the array
    if Item^.Data^[i]=Instance then begin
      k := i;
      Break;
    end;

  if k>=0 then begin
    if k<(Item^.Count-1) then
      Move(Item^.Data^[k+1], Item^.Data^[k], SizeOf(Pointer)*(Item^.Count-k-1));
    Item^.Count := Item^.Count - 1;
    if Item^.Count=0 then Item^.Exists := False;
  end;
end;

destructor TrsClientList.Destroy;
begin
  Clear;
  FList.Free;
  inherited;
end;

procedure TrsClientList.DoNotification(const Value: TrsClientNotification; WParam,LParam: Longint);
var
  Item: PrsClientItem;
  i: integer;
begin
  Item := @FItems[Value];
  if Active and Item^.Exists then
    for i:=0 to Item^.Count-1 do
      if TrsStorageClient(Item^.Data^[i]).Active then
        TrsStorageClient(Item^.Data^[i]).rsNotification(Value, WParam, LParam);
end;

function TrsClientList.GetClient(Index: integer): TrsStorageClient;
begin
  Result := FList.Items[Index];
end;

function TrsClientList.IndexOf(Instance: TrsStorageClient): integer;
begin
  Result := FList.IndexOf(Instance);
end;

function TrsClientList.NotificationExist(const Value: TrsClientNotification): boolean;
begin
  Result := FItems[Value].Exists;
end;


procedure TrsClientList.Remove(Instance: TrsStorageClient);
var
  i: integer;
begin
  i := FList.IndexOf(Instance);
  if i>=0 then Delete(i);
end;


{ TrsEncryptor }

function TrsEncryptor.CalcDecryptBufferSize(const SourceCount: integer): integer;
begin
  Result := -1;
end;

function TrsEncryptor.CalcEncryptBufferSize(const SourceCount: integer): integer;
begin
  Result := -1;
end;

constructor TrsEncryptor.Create(AOwner: TComponent);
{$IFDEF RSL_AUTOLINKREFERENCES}
var
  fs: TrsStorage;
{$ENDIF}
begin
  inherited Create(AOwner);
{$IFDEF RSL_AUTOLINKREFERENCES}
  if csDesigning in ComponentState then begin
    fs := TrsStorage(rsGlobalFindComponent(TrsStorage, AOwner, nil));
    if (fs<>nil) and (fs.Encryptor=nil) then fs.Encryptor := self;
  end;
{$ENDIF}
  FEncryptKeys := TStringList.Create;
  FActive := True;
  FEncryptAll := False;
end;


function TrsEncryptor.DecryptBuffer(PData: Pointer; Count: integer): integer;
begin
  Result := -1;
end;

destructor TrsEncryptor.Destroy;
begin
  if not (csDesigning in ComponentState) and (Storage<>nil) then begin
    Storage.StorageLinkDestroying;
    Storage.Encryptor := nil;
  end;
  FEncryptKeys.Free;
  inherited Destroy;
end;

procedure TrsEncryptor.DoDecrypt;
var
  i: integer;
  s: RSLString;
begin
  if FStorage=nil then Exit;

  if EncryptAll then DoDecryptAll
    else begin
      for i:=0 to FEncryptKeys.Count-1 do begin
        s := FEncryptKeys.Strings[i];
        if FStorage.KeyExist(s)
          then DoDecryptKey(s)
          else
        if FStorage.SectionExist(s)
          then DoDecryptSection(s);
      end;
    end;
end;

procedure TrsEncryptor.DoDecryptAll;
var
  ms: TMemoryStream;
  oldSize, i: integer;
  buf: PAnsiChar;
begin
  ms := TMemoryStream.Create;
  Storage.ReadStream('\', ms);
  // enlarge stream for destination data
  oldSize := ms.Size;
  i := CalcDecryptBufferSize(oldSize) - ms.Size;
  if i>0 then begin
    GetMem(buf, i);
    FillChar(buf^, i, 0);
    ms.Write(buf^, i);
    FreeMem(buf, i);
  end;
  if ms.Size>0 then begin
    i := DecryptBuffer(ms.Memory, oldSize);
    if i<>ms.Size then ms.Size := i;
    Storage.RootSection := '';
    ms.Position := 0;
    Storage.SectionLoadFromStream('', ms);
  end;
  ms.Free;
end;

//done: unicode fix  TrsEncryptor.DoDecryptKey
procedure TrsEncryptor.DoDecryptKey(const Key: RSLString);
var
  s: AnsiString;
  sValue: RSLString;
begin
  s := GetDecryptedKey(Key);
  if (Length(s)=0) and (FTempKeyType=0) then Exit;

  Storage.KeyWrapper.Clear;
  with Storage.KeyWrapper.PKeyItem^.Value do begin
    kvType := FTempKeyType;
    if kvType=kvtString
     then begin
       SetLength(sValue, Length(s) div SizeOf(RSLChar));
       Move(Pointer(s)^, Pointer(sValue)^, Length(s));
       RSLString(VString) := sValue;
     end else
    if kvType=kvtBuffer
     then begin
       AnsiString(VBuffer) := s;
//       SetString(RSLString(VString), PChar(s), Length(s));
     end else Move(Pointer(s)^, VDouble, SizeOf(double));
  end;
end;

procedure TrsEncryptor.DoDecryptSection(const Section: RSLString);
var
  ms: TMemoryStream;
  s: RSLString;
  oldSize, i: integer;
  buf: PAnsiChar;
begin
  s := Section;
  if (Length(s)>0) then begin
    if not (Char(s[1]) in CSectionSeparators) then s := '\' + s;
    if Char(s[Length(s)]) in CSectionSeparators then Delete(s, Length(s), 1);
  end;

  if not Storage.SectionExist(s) then Exit;

  ms := TMemoryStream.Create;

  Storage.ReadStream(s+'\', ms);

  // enlarge stream for destination data
  oldSize := ms.Size;
  i := CalcDecryptBufferSize(oldSize) - ms.Size;
  if i>0 then begin
    GetMem(buf, i);
    FillChar(buf^, i, 0);
    ms.Write(buf^, i);
    FreeMem(buf, i);
  end;
  i := DecryptBuffer(ms.Memory, oldSize);
  if i<>ms.Size then ms.Size := i;

  ms.Position := 0;
  Storage.SectionLoadFromStream(s, ms);

  ms.Free;
end;

procedure TrsEncryptor.DoEncrypt;
var
  i: integer;
  s: RSLString;
begin
  if FStorage=nil then Exit;

  if EncryptAll then DoEncryptAll
    else begin
      for i:=0 to FEncryptKeys.Count-1 do begin
        s := FEncryptKeys.Strings[i];
        if FStorage.KeyExist(s)
          then DoEncryptKey(s)
          else
        if FStorage.SectionExist(s)
          then DoEncryptSection(s);
      end;
    end;
end;

procedure TrsEncryptor.DoEncryptAll;
var
  ms: TMemoryStream;
  oldSize, i: integer;
  buf: PAnsiChar;
begin
  ms := TMemoryStream.Create;
  Storage.RootSection := '';
  Storage.SectionSaveToStream('', ms);

  // enlarge stream for destination data
  oldSize := ms.Size;
  i := CalcEncryptBufferSize(oldSize) - ms.Size;
  if i>0 then begin
    GetMem(buf, i);
    FillChar(buf^, i, 0);
    ms.Write(buf^, i);
    FreeMem(buf, i);
  end;
  i := EncryptBuffer(ms.Memory, oldSize);
  if i<>ms.Size then ms.Size := i;

  Storage.ClearAll;
  Storage.WriteStream('\', ms);
  ms.Free;
end;

//DONE: unicode fix TrsEncryptor.DoEncryptKey
procedure TrsEncryptor.DoEncryptKey(const Key: RSLString);
var
  s: AnsiString;
begin
  s := GetEncryptedKey(Key);
  if (Length(s)=0) and (FTempKeyType=0) then Exit;

  if FTempKeyType=kvtBuffer
   then Storage.KeyWrapper.SetAsBuffer(Pointer(s)^, Length(s))
   else
  if FTempKeyType=kvtString
   then Storage.KeyWrapper.SetAsString(RSLString(s))
   else Storage.KeyWrapper.AsVariant := s;
end;

procedure TrsEncryptor.DoEncryptSection(const Section: RSLString);
var
  ms: TMemoryStream;
  s: RSLString;
  oldSize, i: integer;
  buf: PAnsiChar;
begin
  s := Section;
  if (Length(s)>0) then begin
    if not (Char(s[1]) in CSectionSeparators) then s := '\' + s;
    if Char(s[Length(s)]) in CSectionSeparators then Delete(s, Length(s), 1);
  end;

  if not Storage.SectionExist(s) then Exit;

  ms := TMemoryStream.Create;
  Storage.SectionSaveToStream(s, ms);

  // enlarge stream for destination data
  oldSize := ms.Size;
  i := CalcEncryptBufferSize(oldSize) - ms.Size;
  if i>0 then begin
    GetMem(buf, i);
    FillChar(buf^, i, 0);
    ms.Write(buf^, i);
    FreeMem(buf, i);
  end;
  i := EncryptBuffer(ms.Memory, oldSize);
  if i<>ms.Size then ms.Size := i;

  Storage.SectionClear(s);
  Storage.WriteStream(s+'\', ms);
  ms.Free;
end;


function TrsEncryptor.EncryptBuffer(PData: Pointer; Count: integer): integer;
begin
  Result := -1;
end;

//done: unicode fix TrsEncryptor.GetDecryptedKey
function TrsEncryptor.GetDecryptedKey(const Key: RSLString): AnsiString;
var
  p: pointer;
  size, oldSize, i: integer;
  s: AnsiString;
begin
  FTempKeyType := 0;
  Result := '';
  if not Storage.KeyExist(Key) then Exit;

  with Storage.KeyWrapper.PKeyItem^.Value do begin
    if kvType=kvtString then begin
      s := AnsiString(RSLString(VString));
      p := Pointer(s);
      size := Length(s);
    end else
    if kvType=kvtBuffer then begin
      p := VBuffer;
      size := Length(AnsiString(VBuffer));
    end else begin
      Exit;
{$IFDEF RSL_KYLIX} p := nil; size := 0; {$ENDIF}
    end;
  end;

  Result := Base64ToStr(p, size);
  if Length(Result)=0 then Exit;

  // enlarge string for destination data
  oldSize := Length(Result);
  i := CalcDecryptBufferSize(oldSize);
  if i>oldSize then begin
    SetLength(Result, i);
    FillChar(PAnsiChar(PAnsiChar(Result)+oldSize)^, i-oldSize, 0);
  end;
  i := DecryptBuffer(Pointer(Result), oldSize);
  if i<=0 then begin
    Result := '';
    Exit;
  end;
  if i<>Length(Result) then SetLength(Result, i);

  if PWord(Result)^ >= kvtLastIndex then begin
    Result := '';
    Exit;
  end;
  FTempKeyType := PWord(Result)^;  // I am know that this is bad way in programming...
  Delete(Result, 1, SizeOf(FTempKeyType));
end;

//done: unicode fix TrsEncryptor.GetDecryptedValue
function TrsEncryptor.GetDecryptedValue(const Value: String): String;
var
  p: pointer;
  size, oldSize, i: integer;
  sValue: AnsiString;
begin
  Result := '';
  size := Length(Value)*SizeOf(Char);
  if size=0 then Exit;

  p := Pointer(Value);
  sValue := Base64ToStr(p, size);
  if Length(sValue)=0 then Exit;

  // enlarge string for destination data
  oldSize := Length(sValue);
  i := CalcDecryptBufferSize(oldSize);
  if i>oldSize then begin
    SetLength(sValue, i);
    FillChar(PAnsiChar(PAnsiChar(sValue)+oldSize)^, i-oldSize, 0);
  end;
  i := DecryptBuffer(Pointer(sValue), oldSize);
  if i=0 then begin
    Exit;
  end;
  if i<>Length(sValue) then SetLength(sValue, i);

  if PWord(sValue)^ >= kvtLastIndex then begin
    Exit;
  end;

  Delete(sValue, 1, SizeOf(FTempKeyType));
  Result := String(sValue);
end;

//done: unicode fix  TrsEncryptor.GetEncryptedKey
function TrsEncryptor.GetEncryptedKey(const Key: RSLString): AnsiString;
var
  p: pointer;
  i,size, oldSize: integer;
//  sA: AnsiString;
begin
  Result := '';
  FTempKeyType := 0;
  if not Storage.KeyExist(Key) then Exit;

  with Storage.KeyWrapper.PKeyItem^.Value do begin
    case kvType of
      kvtString:
           begin
//             sA := AnsiString(RSLString(VString));
             p := Pointer(RSLString(VString));
             size := Length(RSLString(VString))*SizeOf(Char);
           end;
      kvtBuffer:
           begin
             p := VBuffer;
             size := Length(AnsiString(VBuffer));
           end;
      else begin
        p := @VDouble;
        size := SizeOf(Double);
      end;
    end;
    FTempKeyType := kvType;
  end;

  i := size+SizeOf(Storage.KeyWrapper.PKeyItem^.Value.kvType);
  SetLength(Result, i);

  PWord(Result)^ := Storage.KeyWrapper.PKeyItem^.Value.kvType;
  Move(p^, Pointer(Integer(Result)+SizeOf(Storage.KeyWrapper.PKeyItem^.Value.kvType))^, size);

  // enlarge string for destination data
  oldSize := Length(Result);
  i := CalcEncryptBufferSize(oldSize);
  if i>oldSize then begin
    SetLength(Result, i);
    FillChar(PAnsiChar(PAnsiChar(Result)+oldSize)^, i-oldSize, 0);
  end;
  i := EncryptBuffer(Pointer(Result), oldSize);
  if i<>Length(Result) then SetLength(Result, i);

  Result := StrToBase64(Pointer(Result), i);
end;

//DONE: unicode fix  TrsEncryptor.GetEncryptedValue
function TrsEncryptor.GetEncryptedValue(const Value: String): String;
var
  p: pointer;
  i,size, oldSize: integer;
  sValue: AnsiString;
begin
  Result := '';
  size := Length(Value)*SizeOf(Char);
  if size=0 then Exit;

  p := Pointer(Value);
  i := size+SizeOf(FTempKeyType);
  SetLength(sValue, i);

  PWord(sValue)^ := kvtString;
  Move(p^, Pointer(PAnsiChar(sValue)+SizeOf(FTempKeyType))^, size);

  // enlarge string for destination data
  oldSize := Length(sValue);
  i := CalcEncryptBufferSize(oldSize);
  if i>oldSize then begin
    SetLength(sValue, i);
    FillChar(PAnsiChar(PAnsiChar(sValue)+oldSize)^, i-oldSize, 0);
  end;
  i := EncryptBuffer(Pointer(sValue), oldSize);
  if i<>Length(sValue) then SetLength(sValue, i);

  sValue := StrToBase64(Pointer(sValue), i);
  Result := String(sValue);
end;

function TrsEncryptor.IsSameEncryptedKey(const Key, Value: RSLString): boolean;
begin
  Result := False;
  if not Storage.KeyExist(Key) then Exit;
  Result := GetEncryptedValue(Value) = Storage.KeyWrapper.AsString;
end;

procedure TrsEncryptor.Notification(AComponent: TComponent; Operation: TOperation);
begin
  inherited Notification(AComponent, Operation);
  if (AComponent=FStorage) AND (Operation=opRemove)
   then begin
     if not (csDesigning in ComponentState) and
        (csDestroying in ComponentState) and
        (Storage<>nil)
      then begin
        Storage.StorageLinkDestroying;
        Storage.Encryptor := nil;
      end;
     FStorage := nil;
   end;
end;

procedure TrsEncryptor.SetActive(const Value: boolean);
begin
  FActive := Value;
end;

procedure TrsEncryptor.SetEncryptKeys(const Value: TStrings);
begin
  FEncryptKeys.Assign(Value);
end;

procedure TrsEncryptor.SetStorage(AStorage: TrsStorage);
begin
  FStorage := AStorage;
  if FStorage<>nil then FreeNotification(FStorage);
end;

function TrsStorage.SectionLevel(Idx: integer): integer;
begin
 Result := 0;
 if Idx<FSectionCount then
   While True do
     if Idx<0 then Break
       else begin
         Inc(Result);
         if FSectionList^[Idx].ParentId>0
           then Idx := SectionFindById(0,Idx-1,FSectionList^[Idx].ParentId)
           else Break;
       end;
end;

procedure TrsStorage.Lock;
begin
  FLock.Enter;
end;

procedure TrsStorage.Unlock;
begin
  FLock.Leave;
end;

function TrsStorage.KeyFirst: integer;
begin
  if Length(RootSection)=0
    then begin
      FKeyIterationsBegin := 0;
      FKeyIterationsEnd := FKeyCount-1;
    end else begin
      FKeyIterationsBegin := FKeyBeginIdx;
      FKeyIterationsEnd := FKeyEndIdx-1;
    end;

  if (FKeyIterationsBegin>=0) and (FKeyIterationsEnd>=FKeyIterationsBegin)
    then begin
      FKeyIndex := FKeyIterationsBegin;
      FKeyWrapper.PKeyItem := @FKeyList^[FKeyIndex];
    end else FKeyIndex := -1;
  Result := FKeyIndex;
end;

function TrsStorage.KeyLast: integer;
begin
  if Length(RootSection)=0
    then begin
      FKeyIterationsBegin := 0;
      FKeyIterationsEnd := FKeyCount-1;
    end else begin
      FKeyIterationsBegin := FKeyBeginIdx;
      FKeyIterationsEnd := FKeyEndIdx-1;
    end;

  if (FKeyIterationsBegin>=0) and (FKeyIterationsEnd>=FKeyIterationsBegin)
    then begin
      FKeyIndex := FKeyIterationsEnd;
      FKeyWrapper.PKeyItem := @FKeyList^[FKeyIndex];
    end else FKeyIndex := -1;
  Result := FKeyIndex;
end;

function TrsStorage.KeyNext: integer;
begin
  if FKeyIndex>=0 then begin
    Inc(FKeyIndex);
    if FKeyIndex<=FKeyIterationsEnd then begin
      FKeyWrapper.PKeyItem := @FKeyList^[FKeyIndex];
    end else FKeyIndex := -1;
  end;
  Result := FKeyIndex;
end;

function TrsStorage.KeyPrior: integer;
begin
  if FKeyIndex>FKeyIterationsBegin then begin
    Dec(FKeyIndex);
    FKeyWrapper.PKeyItem := @FKeyList^[FKeyIndex];
  end else FKeyIndex := -1;
  Result := FKeyIndex;
end;

{ TrsSectionWrapper }

constructor TrsSectionWrapper.Create(AOwner: TrsStorage);
begin
  FStorage := AOwner;
end;

destructor TrsSectionWrapper.Destroy;
begin
  inherited;
end;

function TrsSectionWrapper.GetFullName: RSLString;
begin
  Result := '';
  if (not Assigned(PSectionItem)) or (not Assigned(FStorage)) then Exit;
  Result := FStorage.SectionFullName(FSectionIndex);
end;

function TrsSectionWrapper.GetId: integer;
begin
  Result := PSectionItem^.Id;
end;

function TrsSectionWrapper.GetLevel: integer;
begin
  Result := 0;
  if (not Assigned(PSectionItem)) or (not Assigned(FStorage)) then Exit;
  Result := FStorage.SectionLevel(SectionIndex);
end;

function TrsSectionWrapper.GetName: RSLString;
begin
  Result := PSectionItem^.Name;
end;

function TrsSectionWrapper.GetParentId: integer;
begin
  Result := PSectionItem^.ParentId;
end;

function TrsStorage.SectionFirst: integer;
begin
  if FSectionCount>0
    then FSectionIndex := 0
    else FSectionIndex := -1;
  FSectionWrapper.SectionIndex := FSectionIndex;
  Result := FSectionIndex;
end;

function TrsStorage.SectionLast: integer;
begin
  if FSectionCount>0
    then FSectionIndex := FSectionCount-1
    else FSectionIndex := -1;
  FSectionWrapper.SectionIndex := FSectionIndex;
  Result := FSectionIndex;
end;

function TrsStorage.SectionNext: integer;
begin
  if FSectionIndex>=0 then begin
    Inc(FSectionIndex);
    if FSectionIndex>=FSectionCount then FSectionIndex := -1;
    FSectionWrapper.SectionIndex := FSectionIndex;
  end;
  Result := FSectionIndex;
end;

function TrsStorage.SectionPrior: integer;
begin
  if FSectionIndex>0
    then Dec(FSectionIndex)
    else FSectionIndex := -1;
  FSectionWrapper.SectionIndex := FSectionIndex;
  Result := FSectionIndex;
end;

procedure TrsSectionWrapper.SetSectionIndex(const Value: integer);
begin
  FSectionIndex := Value;
  if FSectionIndex>=0
   then PSectionItem := @FStorage.FSectionList^[FSectionIndex]
   else PSectionItem := nil;
end;

procedure TrsStorage.Merge;
begin
  if not (ssLoading in FCurrentStates)
    then Include(FCurrentStates, ssMerging);
  try
    if Assigned(OnBeforeLoad) then OnBeforeLoad(self);
    if Assigned(StorageData) then begin
      FClientList.Active := False;
      StorageData.SetStorage(Self);
      StorageData.Load;
      DoDecrypt;
      FClientList.Active := True;
      FClientList.DoNotification(scnLoad, 0, 0);
    end;
    if Assigned(OnAfterLoad) then OnAfterLoad(self);
  finally
    Exclude(FCurrentStates, ssMerging);
  end;
end;

{ TrsCompressor }

constructor TrsCompressor.Create(AOwner: TComponent);
{$IFDEF RSL_AUTOLINKREFERENCES}
//compr var fs: TrsStorage;
{$ENDIF}
begin
  inherited Create(AOwner);
  FActive := True;
{$IFDEF RSL_AUTOLINKREFERENCES}
  if csDesigning in ComponentState then begin
  end;
{$ENDIF}
end;

destructor TrsCompressor.Destroy;
begin
  if not (csDesigning in ComponentState) and (Storage<>nil) then begin
    Storage.StorageLinkDestroying;
//compr    Storage.Compressor := nil;
  end;
  inherited Destroy;
end;

function TrsCompressor.IsCompressed(Stream: TStream): boolean;
begin
  Result := False;
end;

procedure TrsCompressor.Notification(AComponent: TComponent; Operation: TOperation);
begin
  inherited Notification(AComponent, Operation);
  if (AComponent=FStorage) AND (Operation=opRemove)
   then begin
     if not (csDesigning in ComponentState) and
        (csDestroying in ComponentState) and
        (Storage<>nil)
      then begin
        Storage.StorageLinkDestroying;
      end;
     FStorage := nil;
   end;
end;

procedure TrsCompressor.SetActive(const Value: boolean);
begin
  FActive := Value;
end;


procedure TrsCompressor.StreamComress(Source, Dest: TStream);
begin
end;

procedure TrsCompressor.StreamDecompress(Source, Dest: TStream);
begin
end;

const
  CSAddon = '.Item';

function TrsStorage.ReadStrings(const Key: RSLString; Strings: TStrings): boolean;
var
  s, saveRoot, sectName: RSLString;
  i: integer;
begin
  sectName := '';
  for i:=Length(Key) downto 1 do
    if IsSectionSeparator(Key[i]) then begin
      sectName := Copy(Key, 1, i-1);
      Break;
    end;

  saveRoot := RootSection;
  try

    RootSection := sectName;
    Strings.Clear;

    i:=0;
    s := Key + CSAddon;
    while True do begin
      if KeyFindAddItem(s + IntToStr(i), False)>=0
        then Strings.Add(FKeyWrapper.AsString)
        else Break;
      Inc(i);
    end;
    Result := i>0;

  finally
    RootSection := saveRoot;
  end;
end;

procedure TrsStorage.WriteStrings(const Key: RSLString; Strings: TStrings);
var
  saveRoot, kName, sectName, s, s1: RSLString;
  i, keyIndex, iDigits: integer;
begin
  kName := Key;
  sectName := '';
  for i:=Length(Key) downto 1 do
    if IsSectionSeparator(Key[i]) then begin
      sectName := Copy(Key, 1, i-1);
      kName := Copy(Key, i+1, Length(Key)-i);
      Break;
    end;

  saveRoot := RootSection;
  try
    RootSection := sectName;

    {delete previous items if exist}
    keyIndex := KeyFirst;
    while keyIndex>=0 do begin
      s := FKeyWrapper.Name;
      iDigits := Length(s);
      while (iDigits>0) and (s[iDigits] in [RSLChar('0')..RSLChar('9')]) do Dec(iDigits);
      iDigits := Length(s)-iDigits;

      if RSLCompareText(kName+CSAddon, Copy(s, 1, Length(s)-iDigits))=0
        then begin
          s1 := Copy(s, Length(s)-iDigits+1, iDigits);
          if StrToIntDef(s1, 0)>=Strings.Count
            then KeyDelete(s);
        end else
      if CompareText(kName, s)=0
        then begin
          KeyDelete(s);
        end;

      keyIndex := KeyNext;
    end;

    {save new items}
    for i:=0 to Strings.Count-1 do begin
      s := kName + CSAddon + IntToStr(i);
      WriteString(s, Strings[i]);
    end;

  finally
    RootSection := saveRoot;
  end;
end;

//save difference data only
procedure TrsStorage.SaveChanges(DefaultData: TrsStorageData);
const
  CIBitChanged = $80;
var
  intSt: TrsStorage;
  i: integer;
  sFullName: string;
begin
  Include(FCurrentStates, ssSavingChanges);

  intSt := TrsStorage.Create(Owner);
  try
    intSt.StorageData := DefaultData;
    intSt.Load;


    {update keys in intSt that changed from defaults}
    i:=0;
    While i<KeyCountAll do begin
      FKeyWrapper.PKeyItem := GetKeyItem(i);
      sFullName := FKeyWrapper.FullName;
      if intSt.KeyExist(sFullName)
        then begin
          {check key for changes}
          if not FKeyWrapper.EqualValue(@intSt.FKeyWrapper.PKeyItem^.Value)
            then begin
              intSt.KeyWrapper.AssignValue(@FKeyWrapper.PKeyItem^.Value);
              intSt.KeyWrapper.KeyOptions := intSt.KeyWrapper.KeyOptions or CIBitChanged;
            end;
        end else begin
          {add key to intSt}
          intSt.Values[sFullName] := Unassigned;
          intSt.KeyWrapper.AssignValue(@FKeyWrapper.PKeyItem^.Value);
          intSt.KeyWrapper.KeyOptions := intSt.KeyWrapper.KeyOptions or CIBitChanged;
        end;
      Inc(i);
    end;

    {delete keys in intSt that not changed (check by zero CIBitChanged)}
    i:=0;
    While i<intSt.KeyCountAll do begin
      intSt.KeyWrapper.PKeyItem := intSt.GetKeyItem(i);
      if (intSt.KeyWrapper.KeyOptions and CIBitChanged)=0
        then begin
          intSt.KeyDelete(intSt.KeyWrapper.FullName);
        end else Inc(i);
    end;


    intSt.StorageData := StorageData;
    intSt.Save;
  finally
    intSt.Free;
    Exclude(FCurrentStates, ssSavingChanges);
  end;
end;

end.
