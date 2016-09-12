////////////////////////////////////////////////////////////////////////////
// PaxCompiler
// Site: http://www.paxcompiler.com
// Author: Alexander Baranovsky (paxscript@gmail.com)
// ========================================================================
// Copyright (c) Alexander Baranovsky, 2006-2008. All rights reserved.
// Code Version: 2.4
// ========================================================================
// Unit: PAXCOMP_TYPEINFO.pas
// ========================================================================
////////////////////////////////////////////////////////////////////////////

{$I PaxCompiler.def}
unit PAXCOMP_TYPEINFO;
interface

uses
  TypInfo,
  SysUtils,
  Classes,
  PAXCOMP_SYS,
  PAXCOMP_MAP;

type
  ShortStringBase = string[255];

  TParamData = record
    Flags: TParamFlags;
    ParamName: ShortString;
    TypeName: ShortString;
  end;

  TTypeInfoContainer = class;
  TTypeDataContainer = class;
  TClassTypeDataContainer = class;
  TMethodTypeDataContainer = class;

  TFieldDataContainer = class
  private
    procedure SaveToStream(S: TStream);
    procedure LoadFromStream(S: TStream);
  public
    Id: Integer; // not saved to stream
    Offset: Cardinal;    { Offset of field in the class data. }
    ClassIndex: Word;    { Index in the FieldClassTable. }
    Name: ShortString;
    FullFieldTypeName: ShortString;
    // PCU only
    Vis: TClassVisibility;
  end;

  TFieldListContainer = class(TTypedList)
  private
    function GetRecord(I: Integer): TFieldDataContainer;
  public
    function Add: TFieldDataContainer;
    procedure SaveToStream(S: TStream);
    procedure LoadFromStream(S: TStream);
    property Records[I: Integer]: TFieldDataContainer read GetRecord; default;
  end;

  TAnotherPropRec = class //PCU only
  public
    Vis: TClassVisibility;
    PropName: ShortString;
    ParamNames: TStringList;
    ParamTypes: TStringList;
    PropType: ShortString;
    ReadName: ShortString;
    WriteName: ShortString;
    IsDefault: Boolean;
    constructor Create;
    destructor Destroy; override;
    procedure SaveToStream(S: TStream);
    procedure LoadFromStream(S: TStream);
  end;

  TAnotherPropList = class(TTypedList)
  private
    function GetRecord(I: Integer): TAnotherPropRec;
  public
    function Add: TAnotherPropRec;
    procedure SaveToStream(S: TStream);
    procedure LoadFromStream(S: TStream);
    property Records[I: Integer]: TAnotherPropRec read GetRecord; default;
  end;

  TPropDataContainer = class
  private
    Owner: TTypeDataContainer;
    function GetCount: Integer;
    function GetSize: Integer;
  public
    PropData: TPropData;
    PropList: array of TPropInfo;
    PropTypeIds: array of Integer;
    ReadNames: TStringList;
    WriteNames: TStringList;
    PropTypeNames: TStringList;
    constructor Create(AOwner: TTypeDataContainer);
    destructor Destroy; override;
    procedure SaveToStream(S: TStream);
    procedure SaveToBuff(S: TStream);
    procedure LoadFromStream(S: TStream);
    property Count: Integer read GetCount;
    property Size: Integer read GetSize;
  end;

  TParamListContainer = class
  private
    Owner: TMethodTypeDataContainer;
    function GetCount: Integer;
    function GetSize: Integer;
  public
    ParamList: array of TParamData;
    constructor Create(AOwner: TMethodTypeDataContainer);
    destructor Destroy; override;
    procedure SaveToStream(S: TStream);
    procedure SaveToBuff(S: TStream);
    procedure LoadFromStream(S: TStream);
    property Count: Integer read GetCount;
    property Size: Integer read GetSize;
  end;

  TTypeDataContainer = class
  private
    Owner: TTypeInfoContainer;
    function GetTypeDataSize: Integer; virtual;
    function GetSize: Integer; virtual;
  public
    TypeData: TTypeData;
    constructor Create(AOwner: TTypeInfoContainer);
    destructor Destroy; override;
    procedure SaveToStream(S: TStream); virtual;
    procedure SaveToBuff(S: TStream); virtual;
    procedure LoadFromStream(S: TStream); virtual;
    property TypeDataSize: Integer read GetTypeDataSize;
    property Size: Integer read GetSize;
  end;

  TMethodTypeDataContainer = class(TTypeDataContainer)
  private
    function GetTypeDataSize: Integer; override;
    function GetSize: Integer; override;
  public
    MethodKind: TMethodKind;
    ParamCount: Byte;
    ParamListContainer: TParamListContainer;
    // extra data
    ResultType: ShortString;
    OwnerTypeName: ShortString;
    MethodTableIndex: Integer;
    ResultTypeId: Integer;
    CallConv: Byte;
    OverCount: Byte;
    Address: Pointer; // not saved to stream
    constructor Create(AOwner: TTypeInfoContainer);
    destructor Destroy; override;
    procedure SaveToStream(S: TStream); override;
    procedure SaveToBuff(S: TStream); override;
    procedure LoadFromStream(S: TStream); override;
  end;

  TClassTypeDataContainer = class(TTypeDataContainer)
  private
    function GetTypeDataSize: Integer; override;
    function GetSize: Integer; override;
  public
    // info about published members
    PropDataContainer: TPropDataContainer;
    MethodTableCount: Integer;
    MethodTableSize: Integer;
    FieldTableCount: Integer;
    FieldTableSize: Integer;
    FullParentName: ShortString;
    FieldListContainer: TFieldListContainer;
    // PCU only
    AnotherFieldListContainer: TFieldListContainer;
    AnotherPropList: TAnotherPropList;
    SupportedInterfaces: TStringList;

    constructor Create(AOwner: TTypeInfoContainer);
    destructor Destroy; override;
    procedure SaveToStream(S: TStream); override;
    procedure SaveToBuff(S: TStream); override;
    procedure LoadFromStream(S: TStream); override;
  end;

  TInterfaceTypeDataContainer = class(TTypeDataContainer)
  private
    function GetTypeDataSize: Integer; override;
    function GetSize: Integer; override;
  public
    PropDataContainer: TPropDataContainer;
    FullParentName: ShortString;
    GUID: TGUID;
    SubDescList: TSubDescList;
    constructor Create(AOwner: TTypeInfoContainer);
    destructor Destroy; override;
    procedure SaveToStream(S: TStream); override;
    procedure SaveToBuff(S: TStream); override;
    procedure LoadFromStream(S: TStream); override;
  end;

  TSetTypeDataContainer = class(TTypeDataContainer)
  private
    function GetSize: Integer; override;
  public
    FullCompName: ShortString;
    procedure SaveToStream(S: TStream); override;
    procedure SaveToBuff(S: TStream); override;
    procedure LoadFromStream(S: TStream); override;
  end;

  TEnumTypeDataContainer = class(TTypeDataContainer)
  private
    function GetTypeDataSize: Integer; override;
    function GetSize: Integer; override;
  public
    NameList: array of ShortString;
    EnumUnitName: ShortString;

    //pcu only
    ValueList: array of Integer;
    procedure SaveToStream(S: TStream); override;
    procedure SaveToBuff(S: TStream); override;
    procedure LoadFromStream(S: TStream); override;
  end;

  TArrayTypeDataContainer = class(TTypeDataContainer)
  private
    function GetSize: Integer; override;
  public
    FullRangeTypeName: ShortString;
    FullElemTypeName: ShortString;
    B1: Integer;
    B2: Integer;
    FinRangeTypeId: Integer;
    procedure SaveToStream(S: TStream); override;
    procedure SaveToBuff(S: TStream); override;
    procedure LoadFromStream(S: TStream); override;
  end;

  TRecordTypeDataContainer = class(TTypeDataContainer)
  private
    function GetSize: Integer; override;
  public
    FieldListContainer: TFieldListContainer;
    constructor Create(AOwner: TTypeInfoContainer);
    destructor Destroy; override;
    procedure SaveToStream(S: TStream); override;
    procedure SaveToBuff(S: TStream); override;
    procedure LoadFromStream(S: TStream); override;
  end;

  TAliasTypeDataContainer = class(TTypeDataContainer)
  public
    FullSourceTypeName: ShortString;
    procedure SaveToStream(S: TStream); override;
    procedure LoadFromStream(S: TStream); override;
  end;

  TPointerTypeDataContainer = class(TTypeDataContainer)
  public
    FullOriginTypeName: ShortString;
    procedure SaveToStream(S: TStream); override;
    procedure LoadFromStream(S: TStream); override;
  end;

  TClassRefTypeDataContainer = class(TTypeDataContainer)
  public
    FullOriginTypeName: ShortString;
    procedure SaveToStream(S: TStream); override;
    procedure LoadFromStream(S: TStream); override;
  end;

  TDynArrayTypeDataContainer = class(TTypeDataContainer)
  public
    FullElementTypeName: ShortString;
    procedure SaveToStream(S: TStream); override;
    procedure LoadFromStream(S: TStream); override;
  end;

  TProceduralTypeDataContainer = class(TTypeDataContainer)
  public
    SubDesc: TSubDesc;
    constructor Create(AOwner: TTypeInfoContainer);
    destructor Destroy; override;
    procedure SaveToStream(S: TStream); override;
    procedure LoadFromStream(S: TStream); override;
  end;

  TTypeInfoContainer = class
  private
    Buff: Pointer;
    Processed: Boolean;
    function GetSize: Integer;
    function GetPosTypeData: Integer;
  public
    TypeInfo: TTypeInfo;
    TypeDataContainer: TTypeDataContainer;
    FullName: ShortString;
    FinTypeId: Byte;
    constructor Create(AFinTypeId: Integer);
    destructor Destroy; override;
    procedure SaveToStream(S: TStream);
    procedure SaveToBuff(S: TStream);
    procedure LoadFromStream(S: TStream;
                             FinTypeId: Byte);
    procedure RaiseError(const Message: string; params: array of Const);
    property Size: Integer read GetSize;
    property PosTypeData: Integer read GetPosTypeData;
    property TypeInfoPtr: Pointer read Buff;
  end;

  TSetTypeInfoContainer = class(TTypeInfoContainer)
  public
    constructor Create(const AName: String);
  end;

  TEnumTypeInfoContainer = class(TTypeInfoContainer)
  public
    constructor Create(const AName: String);
  end;

  TClassTypeInfoContainer = class(TTypeInfoContainer)
  public
    constructor Create(const AName: String);
  end;

  TMethodTypeInfoContainer = class(TTypeInfoContainer)
  public
    constructor Create(const AName: String);
  end;

  TInterfaceTypeInfoContainer = class(TTypeInfoContainer)
  public
    constructor Create(const AName: String);
  end;

  TArrayTypeInfoContainer = class(TTypeInfoContainer)
  public
    constructor Create(const AName: String);
  end;

  TRecordTypeInfoContainer = class(TTypeInfoContainer)
  public
    constructor Create(const AName: String);
  end;

  TAliasTypeInfoContainer = class(TTypeInfoContainer)
  public
    constructor Create(const AName: String);
  end;

  TPointerTypeInfoContainer = class(TTypeInfoContainer)
  public
    constructor Create(const AName: String);
  end;

  TClassRefTypeInfoContainer = class(TTypeInfoContainer)
  public
    constructor Create(const AName: String);
  end;

  TDynArrayTypeInfoContainer = class(TTypeInfoContainer)
  public
    constructor Create(const AName: String);
  end;

  TProceduralTypeInfoContainer = class(TTypeInfoContainer)
  public
    constructor Create(const AName: String);
  end;

  TPaxTypeInfoList = class(TTypedList)
  private
    function GetRecord(I: Integer): TTypeInfoContainer;
    procedure RaiseError(const Message: string; params: array of Const);
  public
    destructor Destroy; override;
    procedure SetFieldOffsets(ASymbolTable: Pointer);
    function LookupFullName(const FullName: String): TTypeInfoContainer;
    procedure CopyToBuff;
    procedure SaveToStream(S: TStream);
    procedure SaveToBuff(S: TStream);
    procedure LoadFromStream(S: TStream);
    procedure AddToProgram(AProg: Pointer);
    function FindMethodFullName(Address: Pointer): String;
    function Processed: Boolean;
    property Records[I: Integer]: TTypeInfoContainer read GetRecord; default;
  end;

procedure Register_TYPEINFO(H_Namespace: Integer);
function FinTypeToTypeKind(FinTypeId: Integer): TTypeKind;

implementation

uses
  PAXCOMP_CONSTANTS,
  PAXCOMP_SYMBOL_REC,
  PAXCOMP_BASESYMBOL_TABLE,
  PAXCOMP_STDLIB,
  PAXCOMP_CLASSLST,
  PAXCOMP_PROG;

function FinTypeToTypeKind(FinTypeId: Integer): TTypeKind;
begin
  result := tkUnknown;
  case FinTypeId of
    typeWIDESTRING: result := tkWString;
{$IFDEF UNIC}
    typeUNICSTRING: result := tkUString;
{$ENDIF}
    typeVARIANT, typeOLEVARIANT: result := tkVariant;
    typeANSISTRING: result := tkLString;
    typeINTEGER, typeBYTE, typeWORD, typeCARDINAL,
    typeSMALLINT, typeSHORTINT: result := tkInteger;
    typeANSICHAR: result := tkChar;
    typeENUM, typeBOOLEAN, typeBYTEBOOL, typeWORDBOOL, typeLONGBOOL: result := tkEnumeration;
    typeSET: result := tkSet;
    typeWIDECHAR: result := tkWChar;
    typeSINGLE, typeDOUBLE, typeEXTENDED: result := tkFloat;
    typeSHORTSTRING: result := tkString;
    typeEVENT: result := tkMethod;
    typeCLASS: result := tkClass;
    typeINT64: result := tkInt64;
    typeDYNARRAY: result := tkDynArray;
    typeINTERFACE: result := tkInterface;
    typeRECORD: result := tkRecord;
    typeARRAY: result := tkArray;
  end;
end;

// TAnotherPropRec -------------------------------------------------------------

constructor TAnotherPropRec.Create;
begin
  inherited;
  ParamNames := TStringList.Create;
  ParamTypes := TStringList.Create;
end;

destructor TAnotherPropRec.Destroy;
begin
  ParamNames.Free;
  ParamTypes.Free;
  inherited;
end;

procedure TAnotherPropRec.SaveToStream(S: TStream);
begin
  S.Write(Vis, SizeOf(Vis));
  SaveShortStringToStream(PropName, S);
  SaveStringListToStream(ParamNames, S);
  SaveStringListToStream(ParamTypes, S);
  SaveShortStringToStream(PropType, S);
  SaveShortStringToStream(ReadName, S);
  SaveShortStringToStream(WriteName, S);
  S.Write(IsDefault, SizeOf(IsDefault));
end;

procedure TAnotherPropRec.LoadFromStream(S: TStream);
begin
  S.Read(Vis, SizeOf(Vis));
  PropName := LoadShortStringFromStream(S);
  LoadStringListFromStream(ParamNames, S);
  LoadStringListFromStream(ParamTypes, S);
  PropType := LoadShortStringFromStream(S);
  ReadName := LoadShortStringFromStream(S);
  WriteName := LoadShortStringFromStream(S);
  S.Read(IsDefault, SizeOf(IsDefault));
end;

// TAnotherPropList ------------------------------------------------------------

function TAnotherPropList.GetRecord(I: Integer): TAnotherPropRec;
begin
  result := TAnotherPropRec(L[I]);
end;

function TAnotherPropList.Add: TAnotherPropRec;
begin
  result := TAnotherPropRec.Create;
  L.Add(result);
end;

procedure TAnotherPropList.SaveToStream(S: TStream);
var
  I, K: Integer;
begin
  K := Count;
  S.Write(K, SizeOf(K));
  for I := 0 to K - 1 do
    Records[I].SaveToStream(S);
end;

procedure TAnotherPropList.LoadFromStream(S: TStream);
var
  I, K: Integer;
  R: TAnotherPropRec;
begin
  S.Read(K, SizeOf(K));
  for I := 0 to K - 1 do
  begin
    R := Add;
    R.LoadFromStream(S);
  end;
end;

// TFieldDataContainer ---------------------------------------------------------

procedure TFieldDataContainer.SaveToStream(S: TStream);
begin
  S.Write(Offset, SizeOf(Offset));
  S.Write(ClassIndex, SizeOf(ClassIndex));
  SaveShortStringToStream(Name, S);
  SaveShortStringToStream(FullFieldTypeName, S);
  S.Write(Vis, SizeOf(Vis));
end;

procedure TFieldDataContainer.LoadFromStream(S: TStream);
begin
  S.Read(Offset, SizeOf(Offset));
  S.Read(ClassIndex, SizeOf(ClassIndex));
  Name := LoadShortStringFromStream(S);
  FullFieldTypeName := LoadShortStringFromStream(S);
  S.Read(Vis, SizeOf(Vis));
end;

// TFieldListContainer ---------------------------------------------------------

function TFieldListContainer.GetRecord(I: Integer): TFieldDataContainer;
begin
  result := TFieldDataContainer(L[I]);
end;

function TFieldListContainer.Add: TFieldDataContainer;
begin
  result := TFieldDataContainer.Create;
  L.Add(result);
end;

procedure TFieldListContainer.SaveToStream(S: TStream);
var
  I, K: Integer;
begin
  K := Count;
  S.Write(K, SizeOf(K));
  for I := 0 to K - 1 do
    Records[I].SaveToStream(S);
end;

procedure TFieldListContainer.LoadFromStream(S: TStream);
var
  I, K: Integer;
  R: TFieldDataContainer;
begin
  S.Read(K, SizeOf(K));
  for I := 0 to K - 1 do
  begin
    R := Add;
    R.LoadFromStream(S);
  end;
end;

// TParamListContainer ---------------------------------------------------------

constructor TParamListContainer.Create(AOwner: TMethodTypeDataContainer);
begin
  inherited Create;
  Owner := AOwner;
end;

destructor TParamListContainer.Destroy;
begin
  inherited;
end;

function TParamListContainer.GetCount: Integer;
begin
  result := Length(ParamList);
end;

function TParamListContainer.GetSize: Integer;
var
  I: Integer;
begin
  result := 0;
  for I := 0 to Count - 1 do
  begin
    Inc(result, SizeOf(ParamList[I].Flags));
    Inc(result, Length(ParamList[I].ParamName) + 1);
    Inc(result, Length(ParamList[I].TypeName) + 1);
  end;
end;

procedure TParamListContainer.SaveToStream(S: TStream);
var
  I, K: Integer;
begin
  K := Count;
  S.Write(K, SizeOf(Integer));
  for I := 0 to Count - 1 do
  with ParamList[I] do
  begin
    S.Write(Flags, SizeOf(Flags));
    SaveShortStringToStream(ParamName, S);
    SaveShortStringToStream(TypeName, S);
  end;
end;

procedure TParamListContainer.SaveToBuff(S: TStream);
var
  I: Integer;
begin
  for I := 0 to Count - 1 do
  with ParamList[I] do
  begin
    S.Write(Flags, SizeOf(Flags));
    SaveShortStringToStream(ParamName, S);
    SaveShortStringToStream(TypeName, S);
  end;
end;

procedure TParamListContainer.LoadFromStream(S: TStream);
var
  I, K: Integer;
begin
  S.Read(K, SizeOf(Integer));
  SetLength(ParamList, K);
  for I := 0 to Count - 1 do
  with ParamList[I] do
  begin
    S.Read(Flags, SizeOf(Flags));
    ParamName := LoadShortStringFromStream(S);
    TypeName := LoadShortStringFromStream(S);
  end;
end;

// TPropDataContainer -------------------------------------------------------

constructor TPropDataContainer.Create(AOwner: TTypeDataContainer);
begin
  Owner := AOwner;
  ReadNames := TStringList.Create;
  WriteNames := TStringList.Create;
  PropTypeNames := TStringList.Create;
  inherited Create;
end;

function PropInfoSize(const PropInfo: TPropInfo): Integer;
begin
  result := SizeOf(TPropInfo) - SizeOf(ShortString) +
            Length(PropInfo.Name) + 1;
end;

destructor TPropDataContainer.Destroy;
begin
  ReadNames.Free;
  WriteNames.Free;
  PropTypeNames.Free;
  inherited;
end;

function TPropDataContainer.GetCount: Integer;
begin
  result := PropData.PropCount;
end;

function TPropDataContainer.GetSize: Integer;
var
  I: Integer;
begin
  result := SizeOf(TPropData);
  for I := 0 to Count - 1 do
    Inc(result,  PropInfoSize(PropList[I]));
end;

procedure TPropDataContainer.SaveToStream(S: TStream);
var
  I, SZ: Integer;
begin
  S.Write(PropData, SizeOf(TPropData));
  for I := 0 to Count - 1 do
  begin
    SZ := PropInfoSize(PropList[I]);
    S.Write(SZ, SizeOf(Integer));
    S.Write(PropList[I], SZ);
  end;
  SaveStringListToStream(ReadNames, S);
  SaveStringListToStream(WriteNames, S);
  SaveStringListToStream(PropTypeNames, S);
  for I := 0 to Count - 1 do
    S.Write(PropTypeIds[I], SizeOf(PropTypeIds[I]));
end;

procedure TPropDataContainer.SaveToBuff(S: TStream);
var
  I: Integer;
begin
  S.Write(PropData, SizeOf(TPropData));
  for I := 0 to Count - 1 do
    S.Write(PropList[I], PropInfoSize(PropList[I]));
end;

procedure TPropDataContainer.LoadFromStream(S: TStream);
var
  I, SZ: Integer;
begin
  S.Read(PropData, SizeOf(TPropData));
  SetLength(PropList, PropData.PropCount);
  for I := 0 to PropData.PropCount - 1 do
  begin
    S.Read(SZ, SizeOf(Integer));
    S.Read(PropList[I], SZ);
  end;
  LoadStringListFromStream(ReadNames, S);
  LoadStringListFromStream(WriteNames, S);
  LoadStringListFromStream(PropTypeNames, S);
  SetLength(PropTypeIds, PropData.PropCount);
  for I := 0 to PropData.PropCount - 1 do
    S.Read(PropTypeIds[I], SizeOf(PropTypeIds));
end;

// TTypeDataContainer -------------------------------------------------------

constructor TTypeDataContainer.Create(AOwner: TTypeInfoContainer);
begin
  Owner := AOwner;
  inherited Create;
end;

destructor TTypeDataContainer.Destroy;
begin
  inherited;
end;

function TTypeDataContainer.GetTypeDataSize: Integer;
begin
  result := SizeOf(TypeData);
end;

function TTypeDataContainer.GetSize: Integer;
begin
  result := SizeOf(TypeData);
end;

procedure TTypeDataContainer.SaveToStream(S: TStream);
begin
  S.Write(TypeData, SizeOf(TypeData));
end;

procedure TTypeDataContainer.SaveToBuff(S: TStream);
begin
  S.Write(TypeData, SizeOf(TypeData));
end;

procedure TTypeDataContainer.LoadFromStream(S: TStream);
begin
  S.Read(TypeData, SizeOf(TypeData));
end;

// TMethodTypeDataContainer ----------------------------------------------------

constructor TMethodTypeDataContainer.Create(AOwner: TTypeInfoContainer);
begin
  inherited;
  ParamListContainer := TParamListContainer.Create(Self);
end;

destructor TMethodTypeDataContainer.Destroy;
begin
  ParamListContainer.Free;
  inherited;
end;

function TMethodTypeDataContainer.GetTypeDataSize: Integer;
begin
  result := SizeOf(MethodKind) + SizeOf(ParamCount);
end;

function TMethodTypeDataContainer.GetSize: Integer;
begin
  result := TypeDataSize + ParamListContainer.Size +
    Length(ResultType) + 1;
end;

procedure TMethodTypeDataContainer.SaveToStream(S: TStream);
begin
  S.Write(MethodKind, SizeOf(MethodKind));
  S.Write(ParamCount, SizeOf(ParamCount));
  ParamListContainer.SaveToStream(S);
  SaveShortStringToStream(ResultType, S);
  SaveShortStringToStream(OwnerTypeName, S);
  S.Write(MethodTableIndex, SizeOf(MethodTableIndex));
  S.Write(ResultTypeId, SizeOf(ResultTypeId));
  S.Write(CallConv, SizeOf(CallConv));
  S.Write(OverCount, SizeOf(OverCount));
end;

procedure TMethodTypeDataContainer.SaveToBuff(S: TStream);
begin
  S.Write(MethodKind, SizeOf(MethodKind));
  S.Write(ParamCount, SizeOf(ParamCount));
  ParamListContainer.SaveToBuff(S);
  SaveShortStringToStream(ResultType, S);
end;

procedure TMethodTypeDataContainer.LoadFromStream(S: TStream);
begin
  S.Read(MethodKind, SizeOf(MethodKind));
  S.Read(ParamCount, SizeOf(ParamCount));
  ParamListContainer.LoadFromStream(S);
  ResultType := LoadShortStringFromStream(S);
  OwnerTypeName := LoadShortStringFromStream(S);
  S.Read(MethodTableIndex, SizeOf(MethodTableIndex));
  S.Read(ResultTypeId, SizeOf(ResultTypeId));
  S.Read(CallConv, SizeOf(CallConv));
  S.Read(OverCount, SizeOf(OverCount));
end;

// TClassTypeDataContainer -----------------------------------------------------

constructor TClassTypeDataContainer.Create(AOwner: TTypeInfoContainer);
begin
  inherited;

  PropDataContainer := TPropDataContainer.Create(Self);
  FieldListContainer := TFieldListContainer.Create;

  AnotherFieldListContainer := TFieldListContainer.Create;
  AnotherPropList := TAnotherPropList.Create;
  SupportedInterfaces := TStringList.Create;

end;

destructor TClassTypeDataContainer.Destroy;
begin
  PropDataContainer.Free;
  FieldListContainer.Free;

  AnotherFieldListContainer.Free;
  AnotherPropList.Free;
  SupportedInterfaces.Free;

  inherited;
end;

function TClassTypeDataContainer.GetTypeDataSize: Integer;
begin
  result := SizeOf(TypeData.ClassType) +
            SizeOf(TypeData.ParentInfo) +
            SizeOf(TypeData.PropCount) +
            Length(TypeData.UnitName) + 1;
end;

function TClassTypeDataContainer.GetSize: Integer;
begin
  result := TypeDataSize +
            PropDataContainer.Size;
end;

procedure TClassTypeDataContainer.SaveToStream(S: TStream);
var
  K: Integer;
begin
  K := TypeDataSize;
  S.Write(K, SizeOf(K));
  S.Write(TypeData, TypeDataSize);
  PropDataContainer.SaveToStream(S);
  S.Write(MethodTableCount, SizeOf(MethodTableCount));
  S.Write(MethodTableSize, SizeOf(MethodTableSize));
  S.Write(FieldTableCount, SizeOf(FieldTableCount));
  S.Write(FieldTableSize, SizeOf(FieldTableSize));
  SaveShortStringToStream(FullParentName, S);
  FieldListContainer.SaveToStream(S);
  AnotherFieldListContainer.SaveToStream(S);
  AnotherPropList.SaveToStream(S);
  SaveStringListToStream(SupportedInterfaces, S);
end;

procedure TClassTypeDataContainer.SaveToBuff(S: TStream);
begin
  S.Write(TypeData, TypeDataSize);
  PropDataContainer.SaveToBuff(S);
end;

procedure TClassTypeDataContainer.LoadFromStream(S: TStream);
var
  K: Integer;
begin
  S.Read(K, SizeOf(K));
  S.Read(TypeData, K);
  PropDataContainer.LoadFromStream(S);
  S.Read(MethodTableCount, SizeOf(MethodTableCount));
  S.Read(MethodTableSize, SizeOf(MethodTableSize));
  S.Read(FieldTableCount, SizeOf(FieldTableCount));
  S.Read(FieldTableSize, SizeOf(FieldTableSize));
  FullParentName := LoadShortStringFromStream(S);
  FieldListContainer.LoadFromStream(S);
  AnotherFieldListContainer.LoadFromStream(S);
  AnotherPropList.LoadFromStream(S);
  LoadStringListFromStream(SupportedInterfaces, S);
end;

// TSetTypeDataContainer -------------------------------------------------

function TSetTypeDataContainer.GetSize: Integer;
begin
  result := SizeOf(TypeData);
end;

procedure TSetTypeDataContainer.SaveToStream(S: TStream);
begin
  S.Write(TypeData, SizeOf(TypeData));
  SaveShortStringToStream(FullCompName, S);
end;

procedure TSetTypeDataContainer.SaveToBuff(S: TStream);
begin
  S.Write(TypeData, SizeOf(TypeData));
end;

procedure TSetTypeDataContainer.LoadFromStream(S: TStream);
begin
  S.Read(TypeData, SizeOf(TypeData));
  FullCompName := LoadShortStringFromStream(S);
end;


// TEnumTypeDataContainer ------------------------------------------------------

function TEnumTypeDataContainer.GetTypeDataSize: Integer;
begin
  result := SizeOf(TOrdType) +
            SizeOf(Longint) + // min value
            SizeOf(Longint) + // max value
            SizeOf(Pointer); // base type
end;

function TEnumTypeDataContainer.GetSize: Integer;
begin
  result := GetTypeDataSize;

{
  for I := 0 to Length(NameList) - 1 do
    Inc(result, Length(NameList[I]) + 1);
}
  Inc(result, 256);

  Inc(result, Length(EnumUnitName) + 1);
end;

procedure TEnumTypeDataContainer.SaveToStream(S: TStream);
var
  I, K: Integer;
begin
  S.Write(TypeData, GetTypeDataSize);
  K := Length(NameList);
  S.Write(K, SizeOf(K));
  for I := 0 to K - 1 do
    SaveShortStringToStream(NameList[I], S);
  SaveShortStringToStream(EnumUnitName, S);
  for I := 0 to K - 1 do
    S.Write(ValueList[I], SizeOf(ValueList[I]));
end;

procedure TEnumTypeDataContainer.SaveToBuff(S: TStream);
var
  I, K, Z: Integer;
  B: Byte;
begin
  S.Write(TypeData, GetTypeDataSize);
  K := Length(NameList);
  Z := 0;
  for I := 0 to K - 1 do
  begin
    SaveShortStringToStream(NameList[I], S);
    Inc(z, Length(NameList[I]) + 1);
  end;
  B := 0;
  while Z < 256 do
  begin
    Inc(Z);
    S.Write(B, 1);
  end;
  SaveShortStringToStream(EnumUnitName, S);
end;

procedure TEnumTypeDataContainer.LoadFromStream(S: TStream);
var
  I, K: Integer;
begin
  S.Read(TypeData, GetTypeDataSize);
  S.Read(K, SizeOf(K));
  SetLength(NameList, K);
  for I := 0 to K - 1 do
    NameList[I] := LoadShortStringFromStream(S);
  EnumUnitName := LoadShortStringFromStream(S);
  SetLength(ValueList, K);
  for I := 0 to K - 1 do
    S.Read(ValueList[I], SizeOf(ValueList[I]));
end;

// TInterfaceTypeDataContainer -------------------------------------------------

constructor TInterfaceTypeDataContainer.Create(AOwner: TTypeInfoContainer);
begin
  inherited;
  PropDataContainer := TPropDataContainer.Create(Self);
  SubDescList := TSubDescList.Create;
end;

destructor TInterfaceTypeDataContainer.Destroy;
begin
  PropDataContainer.Free;
  SubDescList.Free;
  inherited;
end;

function TInterfaceTypeDataContainer.GetTypeDataSize: Integer;
begin
  result := SizeOf(TypeData.IntfParent) +
            SizeOf(TypeData.IntfFlags) +
            SizeOf(TypeData.Guid) +
            Length(TypeData.IntfUnit) + 1;
end;

function TInterfaceTypeDataContainer.GetSize: Integer;
begin
  result := TypeDataSize +
            PropDataContainer.Size;
end;

procedure TInterfaceTypeDataContainer.SaveToStream(S: TStream);
var
  K: Integer;
begin
  K := TypeDataSize;
  S.Write(K, SizeOf(K));
  S.Write(TypeData, TypeDataSize);
  PropDataContainer.SaveToStream(S);
  SaveShortStringToStream(FullParentName, S);
  SubDescList.SaveToStream(S);
  S.Write(GUID, SizeOf(GUID));
end;

procedure TInterfaceTypeDataContainer.SaveToBuff(S: TStream);
begin
  S.Write(TypeData, TypeDataSize);
  PropDataContainer.SaveToBuff(S);
end;

procedure TInterfaceTypeDataContainer.LoadFromStream(S: TStream);
var
  K: Integer;
begin
  S.Read(K, SizeOf(K));
  S.Read(TypeData, K);
  PropDataContainer.LoadFromStream(S);
  FullParentName := LoadShortStringFromStream(S);
  SubDescList.LoadFromStream(S);
  S.Read(GUID, SizeOf(GUID));
end;

// TArrayTypeDataContainer -----------------------------------------------------

function TArrayTypeDataContainer.GetSize: Integer;
begin
  result := SizeOf(TypeData);
  Inc(result, Length(FullRangeTypeName) + 1);
  Inc(result, Length(FullElemTypeName) + 1);
  Inc(result, SizeOf(B1));
  Inc(result, SizeOf(B2));
  Inc(result, SizeOf(FinRangeTypeId));
end;

procedure TArrayTypeDataContainer.SaveToStream(S: TStream);
begin
  S.Write(TypeData, SizeOf(TypeData));
  SaveShortStringToStream(FullRangeTypeName, S);
  SaveShortStringToStream(FullElemTypeName, S);
  S.Write(B1, SizeOf(B1));
  S.Write(B2, SizeOf(B2));
  S.Write(FinRangeTypeId, SizeOf(FinRangeTypeId));
end;

procedure TArrayTypeDataContainer.SaveToBuff(S: TStream);
begin
  SaveToStream(S);
end;

procedure TArrayTypeDataContainer.LoadFromStream(S: TStream);
begin
  S.Read(TypeData, SizeOf(TypeData));
  FullRangeTypeName := LoadShortStringFromStream(S);
  FullElemTypeName := LoadShortStringFromStream(S);
  S.Read(B1, SizeOf(B1));
  S.Read(B2, SizeOf(B2));
  S.Read(FinRangeTypeId, SizeOf(FinRangeTypeId));
end;

// TRecordTypeDataContainer ----------------------------------------------------

constructor TRecordTypeDataContainer.Create(AOwner: TTypeInfoContainer);
begin
  inherited;
  FieldListContainer := TFieldListContainer.Create;
end;

destructor TRecordTypeDataContainer.Destroy;
begin
  FieldListContainer.Free;
  inherited;
end;

function TRecordTypeDataContainer.GetSize: Integer;
begin
  result := SizeOf(TypeData);
end;

procedure TRecordTypeDataContainer.SaveToStream(S: TStream);
begin
  S.Write(TypeData, SizeOf(TypeData));
  FieldListContainer.SaveToStream(S);
end;

procedure TRecordTypeDataContainer.SaveToBuff(S: TStream);
begin
  S.Write(TypeData, SizeOf(TypeData));
end;

procedure TRecordTypeDataContainer.LoadFromStream(S: TStream);
begin
  S.Read(TypeData, SizeOf(TypeData));
  FieldListContainer.LoadFromStream(S);
end;

// TAliasTypeDataContainer -----------------------------------------------------

procedure TAliasTypeDataContainer.SaveToStream(S: TStream);
begin
  S.Write(TypeData, SizeOf(TypeData));
  SaveShortStringToStream(FullSourceTypeName, S);
end;

procedure TAliasTypeDataContainer.LoadFromStream(S: TStream);
begin
  S.Read(TypeData, SizeOf(TypeData));
  FullSourceTypeName := LoadShortStringFromStream(S);
end;

// TPointerTypeDataContainer ---------------------------------------------------

procedure TPointerTypeDataContainer.SaveToStream(S: TStream);
begin
  S.Write(TypeData, SizeOf(TypeData));
  SaveShortStringToStream(FullOriginTypeName, S);
end;

procedure TPointerTypeDataContainer.LoadFromStream(S: TStream);
begin
  S.Read(TypeData, SizeOf(TypeData));
  FullOriginTypeName := LoadShortStringFromStream(S);
end;

// TClassRefTypeDataContainer --------------------------------------------------

procedure TClassRefTypeDataContainer.SaveToStream(S: TStream);
begin
  S.Write(TypeData, SizeOf(TypeData));
  SaveShortStringToStream(FullOriginTypeName, S);
end;

procedure TClassRefTypeDataContainer.LoadFromStream(S: TStream);
begin
  S.Read(TypeData, SizeOf(TypeData));
  FullOriginTypeName := LoadShortStringFromStream(S);
end;

// TDynArrayTypeDataContainer --------------------------------------------------

procedure TDynArrayTypeDataContainer.SaveToStream(S: TStream);
begin
  S.Write(TypeData, SizeOf(TypeData));
  SaveShortStringToStream(FullElementTypeName, S);
end;

procedure TDynArrayTypeDataContainer.LoadFromStream(S: TStream);
begin
  S.Read(TypeData, SizeOf(TypeData));
  FullElementTypeName := LoadShortStringFromStream(S);
end;

// TProceduralTypeDataContainer ------------------------------------------------

constructor TProceduralTypeDataContainer.Create(AOwner: TTypeInfoContainer);
begin
  inherited;
  SubDesc := TSubDesc.Create;
end;

destructor TProceduralTypeDataContainer.Destroy;
begin
  SubDesc.Free;
  inherited;
end;

procedure TProceduralTypeDataContainer.SaveToStream(S: TStream);
begin
  S.Write(TypeData, SizeOf(TypeData));
  SubDesc.SaveToStream(S);
end;

procedure TProceduralTypeDataContainer.LoadFromStream(S: TStream);
begin
  S.Read(TypeData, SizeOf(TypeData));
  SubDesc.LoadFromStream(S);
end;

// TEnumTypeInfoContainer ------------------------------------------------------

constructor TEnumTypeInfoContainer.Create(const AName: String);
begin
  inherited Create(0);
  TypeInfo.Kind := tkEnumeration;
  TypeInfo.Name := ShortString(AName);
  TypeDataContainer.Free;
  TypeDataContainer := TEnumTypeDataContainer.Create(Self);
  FinTypeId := typeENUM;
end;

// TSetTypeInfoContainer -----------------------------------------------------

constructor TSetTypeInfoContainer.Create(const AName: String);
begin
  inherited Create(0);
  TypeInfo.Kind := tkSet;
  TypeInfo.Name := ShortString(AName);
  TypeDataContainer.Free;
  TypeDataContainer := TSetTypeDataContainer.Create(Self);
  FinTypeId := typeSET;
end;

// TClassTypeInfoContainer -----------------------------------------------------

constructor TClassTypeInfoContainer.Create(const AName: String);
begin
  inherited Create(0);
  TypeInfo.Kind := tkClass;
  TypeInfo.Name := ShortString(AName);
  TypeDataContainer.Free;
  TypeDataContainer := TClassTypeDataContainer.Create(Self);
  FinTypeId := typeCLASS;
end;

// TInterfaceTypeInfoContainer -----------------------------------------------------

constructor TInterfaceTypeInfoContainer.Create(const AName: String);
begin
  inherited Create(0);
  TypeInfo.Kind := tkInterface;
  TypeInfo.Name := ShortString(AName);
  TypeDataContainer.Free;
  TypeDataContainer := TInterfaceTypeDataContainer.Create(Self);
  FinTypeId := typeINTERFACE;
end;

// TMethodTypeInfoContainer -----------------------------------------------------

constructor TMethodTypeInfoContainer.Create(const AName: String);
begin
  inherited Create(0);
  TypeInfo.Kind := tkMethod;
  TypeInfo.Name := ShortString(AName);
  TypeDataContainer.Free;
  TypeDataContainer := TMethodTypeDataContainer.Create(Self);
  FinTypeId := typeEVENT;
end;

// TArrayTypeInfoContainer -----------------------------------------------------

constructor TArrayTypeInfoContainer.Create(const AName: String);
begin
  inherited Create(0);
  TypeInfo.Kind := tkArray;
  TypeInfo.Name := ShortString(AName);
  TypeDataContainer.Free;
  TypeDataContainer := TArrayTypeDataContainer.Create(Self);
  FinTypeId := typeARRAY;
end;

// TRecordTypeInfoContainer ----------------------------------------------------

constructor TRecordTypeInfoContainer.Create(const AName: String);
begin
  inherited Create(0);
  TypeInfo.Kind := tkRecord;
  TypeInfo.Name := ShortString(AName);
  TypeDataContainer.Free;
  TypeDataContainer := TRecordTypeDataContainer.Create(Self);
  FinTypeId := typeRECORD;
end;

// TAliasTypeInfoContainer -----------------------------------------------------

constructor TAliasTypeInfoContainer.Create(const AName: String);
begin
  inherited Create(0);
  TypeInfo.Kind := tkUnknown;
  TypeInfo.Name := ShortString(AName);
  TypeDataContainer.Free;
  TypeDataContainer := TAliasTypeDataContainer.Create(Self);
  FinTypeId := typeALIAS;
end;

// TPointerTypeInfoContainer ---------------------------------------------------

constructor TPointerTypeInfoContainer.Create(const AName: String);
begin
  inherited Create(0);
  TypeInfo.Kind := tkUnknown;
  TypeInfo.Name := ShortString(AName);
  TypeDataContainer.Free;
  TypeDataContainer := TPointerTypeDataContainer.Create(Self);
  FinTypeId := typePOINTER;
end;

// TClassRefTypeInfoContainer --------------------------------------------------

constructor TClassRefTypeInfoContainer.Create(const AName: String);
begin
  inherited Create(0);
  TypeInfo.Kind := tkUnknown;
  TypeInfo.Name := ShortString(AName);
  TypeDataContainer.Free;
  TypeDataContainer := TClassRefTypeDataContainer.Create(Self);
  FinTypeId := typeCLASSREF;
end;

// TDynArrayTypeInfoContainer --------------------------------------------------

constructor TDynArrayTypeInfoContainer.Create(const AName: String);
begin
  inherited Create(0);
  TypeInfo.Kind := tkDynArray;
  TypeInfo.Name := ShortString(AName);
  TypeDataContainer.Free;
  TypeDataContainer := TDynArrayTypeDataContainer.Create(Self);
  FinTypeId := typeDYNARRAY;
end;

// TProceduralTypeInfoContainer ------------------------------------------------

constructor TProceduralTypeInfoContainer.Create(const AName: String);
begin
  inherited Create(0);
  TypeInfo.Kind := tkUnknown;
  TypeInfo.Name := ShortString(AName);
  TypeDataContainer.Free;
  TypeDataContainer := TProceduralTypeDataContainer.Create(Self);
  FinTypeId := typePROC;
end;

// TTypeInfoContainer -------------------------------------------------------

constructor TTypeInfoContainer.Create(AFinTypeId: Integer);
begin
  inherited Create;
  TypeDataContainer := TTypeDataContainer.Create(Self);
  FinTypeId := AFinTypeId;
end;

destructor TTypeInfoContainer.Destroy;
begin
  if Assigned(Buff) then
    FreeMem(Buff, Size);
  TypeDataContainer.Free;
  inherited;
end;

function TTypeInfoContainer.GetSize: Integer;
begin
  result := SizeOf(TTypeKind) + Length(TypeInfo.Name) + 1 +
    TypeDataContainer.Size;
end;

function TTypeInfoContainer.GetPosTypeData: Integer;
begin
  result := SizeOf(TTypeKind) + Length(TypeInfo.Name) + 1;
end;

procedure TTypeInfoContainer.SaveToStream(S: TStream);
begin
  S.Write(TypeInfo.Kind, SizeOf(TTypeKind));
  SaveShortStringToStream(TypeInfo.Name, S);
  TypeDataContainer.SaveToStream(S);
  SaveShortStringToStream(FullName, S);
end;

procedure TTypeInfoContainer.SaveToBuff(S: TStream);
begin
  S.Write(TypeInfo.Kind, SizeOf(TTypeKind));
  SaveShortStringToStream(TypeInfo.Name, S);
  TypeDataContainer.SaveToBuff(S);
end;

procedure TTypeInfoContainer.LoadFromStream(S: TStream;
                                            FinTypeId: Byte);
begin
  S.Read(TypeInfo.Kind, SizeOf(TTypeKind));
  TypeInfo.Name := LoadShortStringFromStream(S);

  TypeDataContainer.Free;

  case FinTypeId of
    typeCLASS: TypeDataContainer := TClassTypeDataContainer.Create(Self);
    typeINTERFACE: TypeDataContainer := TInterfaceTypeDataContainer.Create(Self);
    typeEVENT: TypeDataContainer := TMethodTypeDataContainer.Create(Self);
    typeSET: TypeDataContainer := TSetTypeDataContainer.Create(Self);
    typeENUM: TypeDataContainer := TEnumTypeDataContainer.Create(Self);
    typeARRAY: TypeDataContainer := TArrayTypeDataContainer.Create(Self);
    typeRECORD: TypeDataContainer := TRecordTypeDataContainer.Create(Self);
    typeALIAS: TypeDataContainer := TAliasTypeDataContainer.Create(Self);
    typePOINTER: TypeDataContainer := TPointerTypeDataContainer.Create(Self);
    typeCLASSREF: TypeDataContainer := TClassRefTypeDataContainer.Create(Self);
    typeDYNARRAY: TypeDataContainer := TDynArrayTypeDataContainer.Create(Self);
    typePROC: TypeDataContainer := TProceduralTypeDataContainer.Create(Self);
  else
    TypeDataContainer := TTypeDataContainer.Create(Self);
  end;
  TypeDataContainer.LoadFromStream(S);
  FullName := LoadShortStringFromStream(S);
end;

procedure TTypeInfoContainer.RaiseError(const Message: string; params: array of Const);
begin
  raise Exception.Create(Format(Message, params));
end;


// TPaxTypeInfoList ------------------------------------------------------------

destructor TPaxTypeInfoList.Destroy;
begin
  inherited;
end;

function TPaxTypeInfoList.GetRecord(I: Integer): TTypeInfoContainer;
begin
  result := TTypeInfoContainer(L[I]);
end;

procedure TPaxTypeInfoList.SaveToStream(S: TStream);
var
  I, K: Integer;
begin
  K := Count;
  S.Write(K, SizeOf(Integer));
  for I:=0 to K - 1 do
  begin
    S.Write(Records[I].FinTypeId, SizeOf(Records[I].FinTypeId));
    Records[I].SaveToStream(S);
  end;
end;

procedure TPaxTypeInfoList.SaveToBuff(S: TStream);
var
  I: Integer;
begin
  for I:=0 to Count - 1 do
  begin
    Records[I].SaveToBuff(S);
  end;
end;

procedure TPaxTypeInfoList.LoadFromStream(S: TStream);
var
  I, K: Integer;
  R: TTypeInfoContainer;
  FinTypeId: Byte;
begin
  Clear;

  S.Read(K, SizeOf(Integer));
  for I:=0 to K - 1 do
  begin
    S.Read(FinTypeId, SizeOf(Byte));

    case FinTypeId of
      typeCLASS: R := TClassTypeInfoContainer.Create('');
      typeINTERFACE: R := TInterfaceTypeInfoContainer.Create('');
      typeEVENT: R := TMethodTypeInfoContainer.Create('');
      typeSET: R := TSetTypeInfoContainer.Create('');
      typeENUM: R := TEnumTypeInfoContainer.Create('');
      typeARRAY: R := TArrayTypeInfoContainer.Create('');
      typeRECORD: R := TRecordTypeInfoContainer.Create('');
      typeALIAS: R := TAliasTypeInfoContainer.Create('');
      typePOINTER: R := TPointerTypeInfoContainer.Create('');
      typeCLASSREF: R := TClassRefTypeInfoContainer.Create('');
      typeDYNARRAY: R := TDynArrayTypeInfoContainer.Create('');
      typePROC: R := TProceduralTypeInfoContainer.Create('');
    else
      R := TTypeInfoContainer.Create(FinTypeId);
    end;

    R.LoadFromStream(S, FinTypeId);

    L.Add(R);
  end;
end;

function TPaxTypeInfoList.LookupFullName(const FullName: String): TTypeInfoContainer;
var
  I: Integer;
begin
  result := nil;
  for I := 0 to Count - 1 do
    if StrEql(FullName, String(Records[I].FullName)) then
    begin
      result := Records[I];
     Exit;
    end;
end;

procedure TPaxTypeInfoList.CopyToBuff;
var
  S: TMemoryStream;
  I, SZ: Integer;
begin
  for I := 0 to Count - 1 do
  begin
    SZ := Records[I].Size;
    Records[I].Buff := AllocMem(SZ);
    S := TMemoryStream.Create;
    try
      Records[I].SaveToBuff(S);
      S.Position := 0;
      S.Read(Records[I].Buff^, SZ);
    finally
      S.Free;
    end;
  end;
end;

procedure TPaxTypeInfoList.SetFieldOffsets(ASymbolTable: Pointer);
var
  I, J, Id: Integer;
  ClassTypeDataContainer: TClassTypeDataContainer;
  FieldListContainer: TFieldListContainer;
  SymbolTable: TBaseSymbolTable;
begin
  SymbolTable := TBaseSymbolTable(ASymbolTable);
  for I:=0 to Count - 1 do
    if Records[I].TypeInfo.Kind = tkClass then
    begin
      ClassTypeDataContainer := Records[I].TypeDataContainer as
        TClassTypeDataContainer;
      FieldListContainer := ClassTypeDataContainer.FieldListContainer;
      for J := 0 to FieldListContainer.Count - 1 do
      begin
        Id := FieldListContainer[J].Id;
        FieldListContainer[J].Offset := SymbolTable[Id].Shift;
      end;
    end;
end;

procedure TPaxTypeInfoList.AddToProgram(AProg: Pointer);
var
  ClassFactory: TPaxClassFactory;
  I, J, JJ: Integer;
  R: TPaxClassFactoryRec;
  C: TClass;
  ptd: PTypeData;
  pti, pti_parent: PTypeInfo;
  Record_Parent, Record_Temp: TTypeInfoContainer;
  PropDataContainer: TPropDataContainer;
  Prog: TProgram;
  FullName: String;
  ppi: PPropInfo;
  Z, ZZ: Integer;

  ClassTypeInfoContainer: TClassTypeInfoContainer;
  ClassTypeDataContainer: TClassTypeDataContainer;

  MethodTypeInfoContainer: TMethodTypeInfoContainer;
  MethodTypeDataContainer: TMethodTypeDataContainer;

  InterfaceTypeDataContainer: TInterfaceTypeDataContainer;
  SetTypeDataContainer: TSetTypeDataContainer;
  EnumTypeDataContainer: TEnumTypeDataContainer;

  MethodTableIndex: Integer;
  PMethod: PVmtMethod;

  FieldListContainer: TFieldListContainer;
  PField: PVmtField;
  ClassRec: TClassRec;
  P: Pointer;
  RI: TTypeInfoContainer;
  ParentPropCount: Integer;
  MR, SomeMR: TMapRec;
  FileName, ProcName: String;
begin
  Prog := TProgram(AProg);
  ClassFactory := Prog.ProgClassFactory;

  CopyToBuff;

  for I:=0 to Count - 1 do
    Records[I].Processed := false;

  repeat

    for I:=0 to Count - 1 do
    begin
      RI := Records[I];
      if RI.Processed then
        continue;

      case RI.TypeInfo.Kind of
        tkEnumeration:
        begin
          pti := RI.Buff;
          ptd := ShiftPointer(pti, RI.PosTypeData);
          ptd^.BaseType := @ RI.Buff;

          RI.Processed := true;
        end;
        tkSet:
        begin
          RI.Processed := true;

          pti := RI.Buff;
          ptd := ShiftPointer(pti, RI.PosTypeData);

          SetTypeDataContainer := RI.TypeDataContainer as
                                    TSetTypeDataContainer;

          Record_Temp := LookupFullName(String(SetTypeDataContainer.FullCompName));
          if Record_Temp = nil then
            ptd^.CompType := nil
          else
            ptd^.CompType := @ Record_Temp.buff;

        end;
        tkMethod:
        begin
          RI.Processed := true;

          MethodTypeInfoContainer := TMethodTypeInfoContainer(RI);
          MethodTypeDataContainer := TMethodTypeDataContainer(MethodTypeInfoContainer.TypeDataContainer);
          if MethodTypeDataContainer.OwnerTypeName = '' then
            continue;

          Record_Temp := LookupFullName(String(MethodTypeDataContainer.OwnerTypeName));
          if Record_Temp = nil then
            RaiseError(errInternalError, []);
          R := ClassFactory.FindRecordByFullName(String(MethodTypeDataContainer.OwnerTypeName));
          if R = nil then
            RaiseError(errInternalError, []);

//        if R.VMTPtr^.MethodTable = nil then
          if R.MethodTableSize = 0 then
          begin
            R.MethodTableSize := (Record_Temp.TypeDataContainer as
                                  TClassTypeDataContainer).MethodTableSize;
            R.VMTPtr^.MethodTable := AllocMem(R.MethodTableSize);
            PVmtMethodTable(R.VMTPtr^.MethodTable)^.Count :=
               (Record_Temp.TypeDataContainer as
                TClassTypeDataContainer).MethodTableCount;
          end;

          PMethod := ShiftPointer(R.VMTPtr^.MethodTable, SizeOf(Word));

          MethodTableIndex := MethodTypeDataContainer.MethodTableIndex;

          for J := 0 to MethodTableIndex - 1 do
            PMethod := ShiftPointer(PMethod, GetMethodSize(PMethod));

          PMethod^.Name := MethodTypeInfoContainer.TypeInfo.Name;
          FullName := String(MethodTypeDataContainer.OwnerTypeName) + '.' +
                      String(PMethod^.Name);
          PMethod^.Address := Prog.GetAddress(FullName, MR);

          if PMethod^.Address = nil then
          begin
            FileName := ExtractOwner(FullName) + '.' + PCU_FILE_EXT;
            ProcName := Copy(FullName, PosCh('.', FullName) + 1, Length(FullName));
            PMethod^.Address := Prog.RootProg.ProgList.LoadAddress(FileName, ProcName, false,
              MethodTypeDataContainer.OverCount, SomeMR);
          end;

          {$ifdef WIN32}
          PMethod^.Size := SizeOf(Word) +
                           SizeOf(Pointer) +
                           Length(PMethod^.Name) + 1;
          {$endif}

          MethodTypeDataContainer.Address := PMethod^.Address;
        end;
        tkInterface:
        begin
          RI.Processed := true;

          pti := RI.Buff;
          ptd := ShiftPointer(pti, RI.PosTypeData);

          InterfaceTypeDataContainer := RI.TypeDataContainer as
                                    TInterfaceTypeDataContainer;

          Record_Parent := LookupFullName(String(InterfaceTypeDataContainer.FullParentName));
          if Record_Parent = nil then
            ptd^.IntfParent := nil
          else
            ptd^.IntfParent := @ Record_Parent.buff;

          Z := RI.TypeDataContainer.TypeDataSize +
               SizeOf(TPropData);

          PropDataContainer := InterfaceTypeDataContainer.PropDataContainer;

          for J := 0 to PropDataContainer.Count - 1 do
          begin
            ZZ := 0;
            if J > 0 then
              for JJ := 0 to J - 1 do
                Inc(ZZ, PropInfoSize(PropDataContainer.PropList[JJ]));

            ppi := ShiftPointer(ptd, Z + ZZ);

            ppi^.NameIndex := J;

            Record_Temp := LookupFullName(PropDataContainer.PropTypeNames[J]);
            if Record_Temp = nil then
            begin
              ppi^.PropType := nil;
            end
            else
              {$IFDEF FPC}
              ppi^.PropType := PPTypeInfo(@Record_Temp.Buff)^;
              {$ELSE}
              ppi^.PropType := PPTypeInfo(@Record_Temp.Buff);
              {$ENDIF}
          end;
        end;
        tkClass:
        begin
          R := ClassFactory.FindRecordByFullName(String(RI.FullName));

          if R = nil then
            RaiseError(errInternalError, []);

          ClassTypeInfoContainer := RI as
                                    TClassTypeInfoContainer;
          ClassTypeDataContainer := RI.TypeDataContainer as
                                    TClassTypeDataContainer;

          if ClassTypeDataContainer.FieldTableCount > 0 then
          begin
            if R.FieldClassTable = nil then
              R.FieldClassTable :=
                CreateFieldClassTable(ClassTypeDataContainer.FieldTableCount);

//          if R.VMTPtr^.FieldTable = nil then
            if R.FieldTableSize = 0 then
            begin
              R.FieldTableSize := ClassTypeDataContainer.FieldTableSize;
              R.VMTPtr^.FieldTable := AllocMem(R.FieldTableSize);
            end;

            FieldListContainer :=
              ClassTypeDataContainer.FieldListContainer;

            PVmtFieldTable(R.VMTPtr^.FieldTable)^.Count :=
               FieldListContainer.Count;
            {$ifdef WIN32}
            P := ShiftPointer(R.VMTPtr^.FieldTable,
              SizeOf(Word));
            Pointer(P^) := R.FieldClassTable;
            PField := ShiftPointer(R.VMTPtr^.FieldTable,
              SizeOf(Word) + SizeOf(Pointer));

            {$else}
            PField := ShiftPointer(R.VMTPtr^.FieldTable,
              SizeOf(Word) + SizeOf(Word));
            {$endif}

            for J := 0 to FieldListContainer.Count - 1 do
            begin
              // set up PField

              PField^.Name := FieldListContainer[J].Name;
              PField^.Offset := FieldListContainer[J].Offset;
              PField^.ClassIndex := J;

              ClassRec := Prog.ClassList.Lookup(String(FieldListContainer[J].FullFieldTypeName));
              if ClassRec <> nil then
              begin
                if ClassRec.Host then
                  R.FieldClassTable^.Classes[J] := @ ClassRec.PClass;
              end;

              PField := ShiftPointer(PField, GetFieldSize(PField));
            end;
          end;

          pti := RI.Buff;
          R.VMTPtr^.TypeInfo := pti;
          C := R.VMTPtr^.SelfPtr;
          ptd := ShiftPointer(pti, RI.PosTypeData);
          ptd^.ClassType := C;

          C := C.ClassParent;
          if IsPaxClass(C) then
          begin
            Record_Parent := LookupFullName(String(ClassTypeDataContainer.FullParentName));
            if not Record_Parent.Processed then
              continue;

            if Record_Parent = nil then
            begin
              ClassRec := Prog.ClassList.Lookup(String(ClassTypeDataContainer.FullParentName));
              pti_parent := nil;
              if ClassRec = nil then
                RaiseError(errInternalError, []);
              pti_parent := C.ClassInfo;
            end
            else
              pti_parent := Record_Parent.buff;
          end
          else
          begin
            pti_parent := C.ClassInfo;
          end;

          RI.Processed := true;

          R.pti_parent := pti_parent;
          ptd^.ParentInfo := @ R.pti_parent;
          ptd^.PropCount := RI.TypeDataContainer.TypeData.PropCount;
          ptd^.UnitName := RI.TypeDataContainer.TypeData.UnitName;

          Z := RI.TypeDataContainer.TypeDataSize +
               SizeOf(TPropData);

          PropDataContainer :=
            TClassTypeDataContainer(RI.TypeDataContainer).PropDataContainer;

          if pti_parent <> nil then
            ParentPropCount := GetTypeData(pti_parent)^.PropCount
          else
            ParentPropCount := 0;

          Inc(ptd^.PropCount, ParentPropCount);

          for J := 0 to PropDataContainer.Count - 1 do
          begin
            ZZ := 0;
            if J > 0 then
              for JJ := 0 to J - 1 do
                Inc(ZZ, PropInfoSize(PropDataContainer.PropList[JJ]));

            ppi := ShiftPointer(ptd, Z + ZZ);

            ppi^.NameIndex := J + ParentPropCount;

            Record_Temp := LookupFullName(PropDataContainer.PropTypeNames[J]);
            if Record_Temp = nil then
            begin
//            ClassRec := Prog.ClassList.Lookup(String(ClassTypeDataContainer.FullParentName));
              ClassRec := Prog.ClassList.Lookup(PropDataContainer.PropTypeNames[J]);
              if ClassRec = nil then
                RaiseError(errInternalError, []);
              ClassRec.PClass_pti := ClassRec.PClass.ClassInfo;
              ppi^.PropType := @ ClassRec.PClass_pti;
            end
            else
             {$IFDEF FPC}
              ppi^.PropType := PPTypeInfo(@Record_Temp.Buff)^;
              {$ELSE}
              ppi^.PropType := PPTypeInfo(@Record_Temp.Buff);
              {$ENDIF}

            FullName := PropDataContainer.ReadNames[J];
            if Length(FullName) > 0 then
            begin
              ppi^.GetProc := Prog.GetAddress(FullName, MR);
              if ppi^.GetProc = nil then
              begin
                FileName := ExtractOwner(FullName) + '.' + PCU_FILE_EXT;
                ProcName := Copy(FullName, PosCh('.', FullName) + 1, Length(FullName));
                ppi^.GetProc := Prog.RootProg.ProgList.LoadAddress(FileName, ProcName, false, 0, SomeMR);
              end;
            end;
            FullName := PropDataContainer.WriteNames[J];
            if Length(FullName) > 0 then
            begin
              ppi^.SetProc := Prog.GetAddress(FullName, MR);
              if ppi^.SetProc = nil then
              begin
                FileName := ExtractOwner(FullName) + '.' + PCU_FILE_EXT;
                ProcName := Copy(FullName, PosCh('.', FullName) + 1, Length(FullName));
                ppi^.SetProc := Prog.RootProg.ProgList.LoadAddress(FileName, ProcName, false, 0, SomeMR);
              end;
            end;

             ppi^.Index := Integer($80000000);  // no index
          end;
        end; // tkClass
        else
          begin
            RI.Processed := true;
          end;
      end; // case
    end; // i-loop

  until Processed;
end;

function TPaxTypeInfoList.Processed: Boolean;
var
  I: Integer;
begin
  result := true;
  for I := 0 to Count - 1 do
    if not Records[I].Processed then
    begin
      result := false;
      Exit;
    end;
end;

function TPaxTypeInfoList.FindMethodFullName(Address: Pointer): String;
var
  I: Integer;
  MethodTypeDataContainer: TMethodTypeDataContainer;
begin
  result := '';

  for I := 0 to Count - 1 do
    if Records[I].TypeInfo.Kind = tkMethod then
    begin
      MethodTypeDataContainer := Records[I].TypeDataContainer as
        TMethodTypeDataContainer;
      if MethodTypeDataContainer.Address = Address then
      begin
        result := String(Records[I].FullName);
        Exit;
      end;
    end;
end;

procedure TPaxTypeInfoList.RaiseError(const Message: string; params: array of Const);
begin
  raise Exception.Create(Format(Message, params));
end;

procedure _TypeInfo(P: TProgram; FullTypeName: PChar; var result: PTypeInfo); stdcall;
var
  R: TTypeInfoContainer;
begin
  R := P.ProgTypeInfoList.LookupFullName(FullTypeName);
  if R = nil then
    result := nil
  else
    result := @ R.TypeInfo;
end;

var
  Unassigned: Variant;

procedure Register_TYPEINFO(H_Namespace: Integer);
var
  H_Sub: Integer;
begin
  with GlobalSymbolTable do
  begin
    H_Sub := RegisterRoutine(H_Namespace, 'TypeInfo', typeVOID, ccSTDCALL, nil);
    RegisterParameter(H_Sub, typePOINTER, Unassigned, false, 'X');

    RegisterRoutine(0, '', typeVOID, ccSTDCALL, @ _TypeInfo);
    Id_TypeInfo := LastSubId;
  end;
end;

end.
