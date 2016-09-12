////////////////////////////////////////////////////////////////////////////
// PaxCompiler
// Site: http://www.paxcompiler.com
// Author: Alexander Baranovsky (paxscript@gmail.com)
// ========================================================================
// Copyright (c) Alexander Baranovsky, 2006-2008. All rights reserved.
// Code Version: 2.4
// ========================================================================
// Unit: PAXCOMP_BASESYMBOL_TABLE.pas
// ========================================================================
////////////////////////////////////////////////////////////////////////////

{$I PaxCompiler.def}
{$O-}
{$R-}
unit PAXCOMP_BASESYMBOL_TABLE;
interface
uses
{$IFDEF VARIANTS}
  Variants,
{$ENDIF}
{$IFNDEF LINUX}
  Windows,
{$ENDIF}
  TypInfo,
  SysUtils,
  Classes,
  PAXCOMP_CONSTANTS,
  PAXCOMP_SYS,
  PAXCOMP_VAROBJECT,
  PAXCOMP_HEADER_PARSER,
  PAXCOMP_MAP,
  PAXCOMP_SYMBOL_REC;
type
  TBaseSymbolTable = class
  private
    LastCard: Integer;
    procedure CheckMemory(p: Pointer; Size: Cardinal);
    procedure UpdateSomeTypeList(const TypeName: String; TypeId: Integer);
  protected
    function GetRecord(I: Integer): TSymbolRec; virtual;
  public
    A: TList;
    Card: Integer;

    ResultId: Integer;
    TrueId: Integer;
    FalseId: Integer;
    NilId: Integer;
    EventNilId: Integer;
    EmptySetId: Integer;
    EmptyStringId: Integer;
    CurrExceptionObjectId: Integer;
    LastShiftValue: Integer;
    LastClassIndex: Integer;

    VarObjects: TVarObjectList;
    HashArray: THashArray;
    HeaderParser: THeaderParser;
    GuidList: TGuidList;
    SomeTypeList: TSomeTypeList;
    ExternList: TExternList;

    LastSubId: Integer;
    LastVarId: Integer;

    constructor Create;
    destructor Destroy; override;
    function AddRecord: TSymbolRec; virtual;
    procedure Reset; virtual;

    function AddAnsiCharConst(Value: AnsiChar): TSymbolRec;
    function AddWideCharConst(Value: Integer): TSymbolRec;
    function AddPAnsiCharConst(const Value: AnsiString): TSymbolRec;
    function AddShortStringConst(const Value: String): TSymbolRec;
    function AddPWideCharConst(const Value: WideString): TSymbolRec;
    function AddByteConst(Value: Byte): TSymbolRec;
    function AddWordConst(Value: Word): TSymbolRec;
    function AddIntegerConst(Value: Integer): TSymbolRec;
    function AddInt64Const(Value: Int64): TSymbolRec;
    function AddCardinalConst(Value: Cardinal): TSymbolRec;
    function AddSmallIntConst(Value: SmallInt): TSymbolRec;
    function AddShortIntConst(Value: ShortInt): TSymbolRec;
    function AddEnumConst(TypeId, Value: Integer): TSymbolRec;
    function AddPointerConst(TypeId: Integer; Value: Pointer): TSymbolRec;
    function AddRecordConst(TypeId: Integer; const Value: Variant): TSymbolRec;
    function AddArrayConst(TypeId: Integer; const Value: Variant): TSymbolRec;
    function AddSetConst(TypeId: Integer; const Value: Variant): TSymbolRec;
    function AddClassConst(TypeId: Integer; Value: TObject): TSymbolRec;
    function AddClassRefConst(TypeId: Integer; Value: TClass): TSymbolRec;
    function AddSetVar(TypeId: Integer; const Value: Variant): TSymbolRec;
    function AddDoubleConst(Value: Double): TSymbolRec;
    function AddCurrencyConst(Value: Currency): TSymbolRec;
    function AddSingleConst(Value: Single): TSymbolRec;
    function AddExtendedConst(Value: Extended): TSymbolRec;
    function AddBooleanConst(Value: Boolean): TSymbolRec;
    function AddByteBoolConst(Value: Boolean): TSymbolRec;
    function AddWordBoolConst(Value: Boolean): TSymbolRec;
    function AddLongBoolConst(Value: Boolean): TSymbolRec;
    function AddVariantConst(const Value: Variant): TSymbolRec;
    function AddOleVariantConst(const Value: OleVariant): TSymbolRec;

    function AddTMethodVar(Level: Integer): TSymbolRec;
    function AddCurrencyVar(Level: Integer): TSymbolRec;
    function AddDoubleVar(Level: Integer): TSymbolRec;
    function AddSingleVar(Level: Integer): TSymbolRec;
    function AddExtendedVar(Level: Integer): TSymbolRec;
    function AddInt64Var(Level: Integer): TSymbolRec;
    function AddStringVar(Level: Integer): TSymbolRec;
    function AddInterfaceVar(Level: Integer): TSymbolRec;
    function AddClassVar(Level: Integer): TSymbolRec;
    function AddWideStringVar(Level: Integer): TSymbolRec;
    function AddUnicStringVar(Level: Integer): TSymbolRec;
    function AddVariantVar(Level: Integer): TSymbolRec;
    function AddOleVariantVar(Level: Integer): TSymbolRec;
    function AddShortStringVar(Level, TypeId: Integer): TSymbolRec;
    function AddDynarrayVar(Level, TypeId: Integer): TSymbolRec;
    function AddBooleanVar(Level: Integer): TSymbolRec;
    function AddByteBoolVar(Level: Integer): TSymbolRec;
    function AddWordBoolVar(Level: Integer): TSymbolRec;
    function AddLongBoolVar(Level: Integer): TSymbolRec;
    function AddIntegerVar(Level: Integer): TSymbolRec;
    function AddCardinalVar(Level: Integer): TSymbolRec;
    function AddSmallIntVar(Level: Integer): TSymbolRec;
    function AddShortIntVar(Level: Integer): TSymbolRec;
    function AddByteVar(Level: Integer): TSymbolRec;
    function AddWordVar(Level: Integer): TSymbolRec;
    function AddPointerVar(Level: Integer): TSymbolRec;
    function AddVoidVar(Level: Integer; SZ: Integer): TSymbolRec;
    function AddClassRefVar(Level: Integer): TSymbolRec;
    function AddLabel: TSymbolRec;
    function AddPointerType(SourceTypeId: Integer): TSymbolRec;

    function AddEndOfClassHeader(ClassId: Integer): TSymbolRec;

    function GetDataSize(UpperId: Integer = MaxInt - 1): Integer;

    function LookUpEnumItem(const S: String; EnumTypeId: Integer;
                            UpCase: Boolean): Integer;

    function LookupNamespace(const S: String;
                             i_Level: Integer; UpCase: Boolean): Integer;
    function LookupFullName(const S: String; UpCase: Boolean): Integer;
    function LookupFullNameEx(const S: String; UpCase: Boolean;
                              OverCount: Integer): Integer;
    function LookUpType(const S: String; i_Level: Integer; UpCase: Boolean): Integer; overload;
    function LookUpType(const S: String; UpCase: Boolean): Integer; overload;
    function LookupParentMethodBase(SubId: Integer; UpCase: Boolean): Integer;
    function LookupParentMethod(SubId: Integer; UpCase: Boolean): Integer;

    function LookUpTypeEx(const S: String;
             i_Level: Integer; UpCase: Boolean; LowBound: Integer): Integer;
    function LookUp(const S: String; Level: Integer; UpCase: Boolean; UpperBoundId: Integer = MaxInt): Integer;
    function LookUps(const S: String; LevelStack: TIntegerStack; UpCase: Boolean; UpperBoundId: Integer = MaxInt): Integer;
    function LookUpsEx(const S: String; LevelStack: TIntegerStack; var LevelId: Integer; UpCase: Boolean): Integer;
    function LookUpsExcept(const S: String; LevelStack: TIntegerStack; LevelId: Integer; UpCase: Boolean): Integer;
    function LookUpAll(const S: String; Level: Integer; UpCase: Boolean): TIntegerList;
    function LookUpSub(const S: String; Level: Integer; UpCase: Boolean): TIntegerList;
    function LookupAnotherDeclaration(Id: Integer; UpCase: Boolean;
                                      var BestID: Integer): Integer;
    function LookupForwardDeclaration(Id: Integer; UpCase: Boolean;
                            var BestID: Integer): Integer;
    function LookupForwardDeclarations(Id: Integer;
                                       UpCase: Boolean): TIntegerList;
    function RegisterNamespace(LevelId: Integer;
                               const NamespaceName: String): Integer;
    function RegisterArrayType(LevelId: Integer;
                               const TypeName: String;
                               RangeTypeId, ElemTypeId: Integer;
                               Align: Integer): Integer;
    function RegisterDynamicArrayType(LevelId: Integer;
                                      const TypeName: String;
                                      ElemTypeId: Integer): Integer;
    function FindInterfaceTypeId(const GUID: TGUID): Integer;
    function RegisterInterfaceType(LevelId: Integer;
                                   const TypeName: String;
                                   const GUID: TGUID): Integer; overload;
    function RegisterInterfaceType(LevelId: Integer;
                                   pti: PTypeInfo): Integer; overload;
    procedure RegisterSupportedInterface(TypeId: Integer;
                                         const SupportedInterfaceName: String;
                                         const i_GUID: TGUID); overload;
    procedure RegisterSupportedInterface(TypeId,
                                         InterfaceTypeId: Integer); overload;

    function RegisterClassType(LevelId: Integer;
                               const TypeName: String; i_AncestorID: Integer): Integer; overload;
    function RegisterClassType(LevelId: Integer;
                               C: TClass): Integer; overload;
    function RegisterClassTypeForImporter(LevelId: Integer;
                                          C: TClass): Integer; overload;
    function RegisterClassTypeForImporter(LevelId: Integer;
                                          const TypeName: String): Integer; overload;
    procedure RegisterClassTypeInfos(ClassId: Integer;
                                     C: TClass);
    function RegisterClassReferenceType(LevelId: Integer;
                               const TypeName: String;
                               OriginClassId: Integer): Integer;
    function RegisterProperty(LevelId: Integer; const PropName: String;
                              PropTypeID, i_ReadId, i_WriteId: Integer;
                              i_IsDefault: Boolean): Integer;
    function RegisterInterfaceProperty(LevelId: Integer;
                                       const PropName: String;
                                       PropTypeID,
                                       ReadIndex,
                                       WriteIndex: Integer): Integer;
    function RegisterRecordType(LevelId: Integer;
                                const TypeName: String;
                                Align: Integer): Integer;
    function RegisterRTTIType(LevelId: Integer;
                              pti: PTypeInfo): Integer;
    function RegisterTypeAlias(LevelId:Integer;
                               const TypeName: String;
                               OriginTypeId: Integer): Integer; overload;
    function RegisterTypeAlias(LevelId:Integer;
                               const Declaration: String): Integer; overload;
    function RegisterTypeField(LevelId: Integer; const FieldName: String;
                               FieldTypeID: Integer;
                               FieldOffset: Integer = -1): Integer;
    function RegisterTypeFieldEx(LevelId: Integer;
                               const Declaration: String;
                               FieldOffset: Integer = -1): Integer;
    function RegisterVariantRecordTypeField(LevelId: Integer;
                                const Declaration: String;
                                VarCnt: Int64): Integer; overload;
    function RegisterVariantRecordTypeField(LevelId: Integer;
                                const FieldName: String;
                                FieldTypeID: Integer;
                                VarCnt: Int64): Integer; overload;

    function RegisterSubrangeType(LevelId: Integer;
                                  const TypeName: String;
                                  TypeBaseId: Integer;
                                  B1, B2: Integer): Integer;

    function RegisterEnumType(LevelId: Integer;
                              const TypeName: String;
                              TypeBaseId: Integer): Integer;
    function RegisterEnumValue(EnumTypeId: Integer;
                               const FieldName: String;
                               const i_Value: Integer): Integer;
    function RegisterPointerType(LevelId: Integer;
                                 const TypeName: String;
                                 OriginTypeId: Integer): Integer;

    function RegisterShortStringType(LevelId: Integer;
                                     const TypeName: String;
                                     L: Integer): Integer;

    function RegisterSetType(LevelId: Integer;
                             const TypeName: String;
                             OriginTypeId: Integer): Integer;

    function CreateEmptySet: TSymbolRec;

    function RegisterProceduralType(LevelId: Integer;
                                    const TypeName: String;
                                    HSub: Integer): Integer;
    function RegisterEventType(LevelId: Integer;
                               const TypeName: String;
                               HSub: Integer): Integer;
    function RegisterVariable(LevelId: Integer;
                              const Declaration: String; Address: Pointer): Integer; overload;
    function RegisterVariable(LevelId: Integer; const VarName: String;
                              VarTypeID: Integer; i_Address: Pointer): Integer; overload;
    function RegisterObject(LevelId: Integer;
                            const ObjectName: String;
                            TypeId: Integer;
                            i_Address: Pointer): Integer;
    function RegisterConstant(LevelId: Integer;
                              const Declaration: String): Integer; overload;
    function RegisterConstant(LevelId: Integer; const i_Name: String; i_TypeID: Integer;
                              const i_Value: Variant): Integer; overload;
    function RegisterConstant(LevelId: Integer; const i_Name: String;
                              const i_Value: Variant): Integer; overload;
    function RegisterRoutine(LevelId: Integer;
                             const SubName: String; ResultTypeID: Integer;
                             CallConvention: Integer; i_Address: Pointer): Integer;
    function RegisterMethod(LevelId: Integer;
                            const SubName: String; ResultTypeID: Integer;
                            CallConvention: Integer;
                            i_Address: Pointer;
                            IsShared: Boolean = false;
                            i_CallMode: Integer = cmNONE;
                            i_MethodIndex: Integer = 0): Integer;
    function RegisterConstructor(LevelId: Integer;
                                 const SubName: String; i_Address: Pointer;
                                 i_CallMode: Integer = cmNONE): Integer;
    function RegisterDestructor(LevelId: Integer;
                                const SubName: String; i_Address: Pointer;
                                i_CallMode: Integer = cmNONE): Integer;
    function RegisterParameter(HSub: Integer; ParamTypeID: Integer;
                               const DefaultValue: Variant;
                               InitByRef: Boolean = false;
                               ParameterName: String = '';
                               Tag: Integer = 0): Integer;
    function RegisterHeader(LevelId: Integer;
                            const Header: String; Address: Pointer;
                            MethodIndex: Integer = 0): Integer;
    procedure RegisterMember(LevelId: Integer; const MemberName: String;
                             i_Address: Pointer);
    function RegisterTypeDeclaration(LevelId: Integer;
      const Declaration: String): Integer;
    procedure RegisterSpace(K: Integer);

    function RestorePositiveIndex(L: Integer): Integer;
    function FindMaxMethodIndex(IntfId: Integer): Integer;

    function GetResultId(SubId: Integer): Integer;
    function GetSelfId(SubId: Integer): Integer;
    function GetParamId(SubId, ParamNumber: Integer): Integer;
    function GetSizeOfLocals(SubId: Integer): Integer;
    function GetSizeOfLocalsEx(SubId: Integer): Integer;
    function GetSizeOfParams(SubId: Integer): Integer;
    function GetSizeOfSetType(SetTypeId: Integer): Integer;
    function CheckSetTypes(T1, T2: Integer): Boolean;
    function GetLowBoundRec(TypeID: Integer): TSymbolRec;
    function GetHighBoundRec(TypeID: Integer): TSymbolRec;
    procedure GetArrayTypeInfo(ArrayTypeId: Integer; var RangeTypeId: Integer; var ElemTypeId: Integer);
    function IsZeroBasedAnsiCharArray(Id: Integer): Boolean;
    function IsZeroBasedWideCharArray(Id: Integer): Boolean;
    function GetTypeBase(TypeId: Integer): Integer;
    function GetPatternSubId(ProcTypeID: Integer): Integer;
    function EqualHeaders(SubId1, SubId2: Integer): Boolean;
    function GetShiftsOfDynamicFields(ATypeId: Integer): TIntegerList;
    function GetTypesOfDynamicFields(ATypeId: Integer): TIntegerList;
    function HasDynamicFields(ATypeId: Integer): Boolean;
    function TerminalTypeOf(TypeID: Integer): Integer;
    function FindDefaultPropertyId(i_TypeId: Integer): Integer;
    function FindConstructorId(i_TypeId: Integer): Integer;
    function FindConstructorIdEx(i_TypeId: Integer): Integer;
    function FindDestructorId(i_TypeId: Integer): Integer;
    function FindDestructorIdEx(i_TypeId: Integer): Integer;
    function Inherits(T1, T2: Integer): Boolean;
    function Supports(T1, T2: Integer): Boolean;

    function GetFinalAddress(P: Pointer; StackFrameNumber: Integer;
                             Id: Integer): Pointer;

    function GetStrVal(Address: Pointer;
                       TypeId: Integer;
                       TypeMapRec: TTypeMapRec = nil): String;

    function GetValueAsString(P: Pointer;
                              StackFrameNumber: Integer;
                              Id: Integer;
                              TypeMapRec: TTypeMapRec = nil): String;

    procedure CheckVariantData (const V);
    function GetVal(Address: Pointer;
                    TypeId: Integer): Variant;
    function GetValue(P: Pointer; StackFrameNumber: Integer;
                      Id: Integer): Variant;
                      
    procedure PutVal(Address: Pointer;
                     TypeId: Integer; const Value: Variant);
    procedure PutValue(P: Pointer; StackFrameNumber: Integer;
                       Id: Integer; const Value: Variant);

    function GetLocalCount(SubId: Integer): Integer;
    function GetLocalId(SubId, LocalVarNumber: Integer): Integer;

    function GetGlobalCount(NamespaceId: Integer): Integer;
    function GetGlobalId(NamespaceId, GlobalVarNumber: Integer): Integer;

    function GetFieldCount(Id: Integer; TypeMapRec: TTypeMapRec = nil): Integer;

    function GetFieldDescriptorId(Id,
                                  FieldNumber: Integer;
                                  TypeMapRec: TTypeMapRec = nil): Integer;

    function GetFieldDescriptorIdByName(Id: Integer; const FieldName: String): Integer;
    function GetFieldName(Id, FieldNumber: Integer): String;
    function GetFieldAddress(P: Pointer;
                             StackFrameNumber,
                             Id,
                             FieldNumber: Integer;
                             TypeMapRec: TTypeMapRec = nil
                             ): Pointer;
    function GetFieldValueAsString(P: Pointer;
                                   StackFrameNumber: Integer;
                                   Id: Integer;
                                   FieldNumber: Integer;
                                   TypeMapRec: TTypeMapRec = nil
                                   ): String;

    function GetPublishedPropCount(Id: Integer): Integer;
    function GetPublishedPropDescriptorId(Id, PropNumber: Integer): Integer;
    function GetPublishedPropName(Id, PropNumber: Integer): String;
    function GetPublishedPropValueAsString(P: Pointer; StackFrameNumber: Integer;
                    Id, PropNumber: Integer): String;

    function GetArrayItemAddress(P: Pointer; StackFrameNumber, Id,
                                 Index: Integer): Pointer;
    function GetArrayItemValueAsString(P: Pointer; StackFrameNumber: Integer;
                                  Id, Index: Integer): String;
    function GetDynArrayItemAddress(P: Pointer;
                                    StackFrameNumber: Integer;
                                    Id, Index: Integer): Pointer;
    function GetDynArrayItemValueAsString(P: Pointer; StackFrameNumber: Integer;
                                     Id, Index: Integer): String;

    function IsParam(SubId, Id: Integer): Boolean;
    function IsVar(LevelId, Id: Integer): Boolean;
    function IsConst(LevelId, Id: Integer): Boolean;
    function IsType(LevelId, Id: Integer): Boolean;
    function IsProcedure(LevelId, Id: Integer): Boolean;
    function IsFunction(LevelId, Id: Integer): Boolean;
    function IsConstructor(ClassId, Id: Integer): Boolean;
    function IsDestructor(ClassId, Id: Integer): Boolean;
    function IsTypeField(LevelId, Id: Integer): Boolean;
    function IsProperty(ClassId, Id: Integer): Boolean;
    function IsNamespace(LevelId, Id: Integer): Boolean;

    function FindPAnsiCharConst(const S: String; LimitId: Integer): Integer;
    function FindPWideCharConst(const S: String; LimitId: Integer): Integer;

    function RegisterDummyType(LevelId: Integer;
                               const TypeName: String): Integer;
    function RegisterSomeType(LevelId: Integer;
                              const TypeName: String): Integer;

    function GetAlignmentSize(TypeId, DefAlign: Integer): Integer;
    procedure SetVisibility(C: TClass; const MemberName: String; value: Integer);
    function FindClassTypeId(Cls: TClass): Integer;

    procedure SaveNamespaceToStream(LevelId: Integer; S: TStream); overload;
    procedure SaveNamespaceToStream(const NamespaceName: String; S: TStream); overload;

    procedure SaveNamespaceToFile(LevelId: Integer; const FileName: String); overload;
    procedure SaveNamespaceToFile(const NamespaceName, FileName: String); overload;

    procedure LoadNamespaceFromStream(S: TStream);
    procedure LoadNamespaceFromFile(const FileName: String);

    procedure ResolveExternList(CheckProc: TCheckProc; Data: Pointer);
    procedure AddScriptFields(ClassId: Integer; FieldList: TMapFieldList);

    procedure ExtractMembers(Id: Integer; L: TStrings;
                             Lang: TPaxLang = lngPascal);

    procedure ExtractParameters(Id: Integer; L: TStrings;
                               Lang: TPaxLang = lngPascal);

    procedure ExtractParametersEx(Id: Integer; L: TStrings; Upcase: Boolean);
    function ValueStr(I: Integer): String;
    procedure AddTypes(const TypeName: String; L: TStrings;
                       ErrorIndex: Integer; Upcase: Boolean);

    procedure CreateInterfaceMethodList(IntfId: Integer;
                                        L: TIntegerList); overload;
    procedure CreateInterfaceMethodList(ClassId, IntfId: Integer;
                                        InterfaceMethodIds,
                                        ClassMethodIds: TIntegerList); overload;

    procedure ProcessClassFactory(AClassFactory: Pointer;
                                  AProg: Pointer);
    procedure HideClass(C: TClass);

    procedure RaiseError(const Message: string; params: array of const);
    property Records[I: Integer]: TSymbolRec read GetRecord; default;
  end;

var
  GlobalAlignment: Integer = 8;

  RaiseE: Boolean = true;
  REG_OK: Boolean = true;
  REG_ERROR: String;
  DllDefined: Boolean = false;

  H_TByteSet: Integer = -1;

  StdCard: Integer = 0;
  StdSize: Integer = 0;
  SR0: TSymbolRec = nil;

  GlobalCurrExceptionObjectId: Integer = -1;

  JS_JavaScriptNamespace: Integer = 0;
  JS_GetPropertyId: Integer = 0;
  JS_PutPropertyId: Integer = 0;
  JS_GetArrPropertyId: Integer = 0;
  JS_PutArrPropertyId: Integer = 0;

  JS_GetPropertyAsObjectId: Integer = 0;

  JS_ObjectClassId: Integer = 0;
  JS_BooleanClassId: Integer = 0;
  JS_FunctionClassId: Integer = 0;
  JS_StringClassId: Integer = 0;
  JS_NumberClassId: Integer = 0;
  JS_DateClassId: Integer = 0;
  JS_ArrayClassId: Integer = 0;
  JS_MathClassId: Integer = 0;

  JS_FunctionCallId: Integer = 0;
  JS_TempNamespaceId: Integer = 0;

  JS_GetGenericPropertyId: Integer = 0;
  JS_PutGenericPropertyId: Integer = 0;

  JS_ToObjectId: Integer = 0;
  JS_GetNextPropId: Integer = 0;
  JS_TypeOfId: Integer = 0;
  JS_VoidId: Integer = 0;
  JS_FindFuncId: Integer = 0;
  JS_AssignProgId: Integer = 0;
  JS_ClearReferencesId: Integer = 0;

type
  TGetOleProp =
     procedure (const D: Variant; PropName: PChar;
                var Result: Variant;
                ParamCount: Integer); stdcall;

  TPutOleProp =
    procedure (const D: Variant; PropName: PChar;
               const Value: Variant;
               ParamCount: Integer); stdcall;

var
  GetOlePropProc: TGetOleProp = nil;
  PutOlePropProc: TPutOleProp = nil;

implementation

uses
  PAXCOMP_PROG,
  PAXCOMP_STDLIB;

{$IFNDEF LINUX}
function GetReadableSize(Address, Size: DWord): DWord;
const
  ReadAttributes = [PAGE_READONLY, PAGE_READWRITE, PAGE_WRITECOPY, PAGE_EXECUTE,
    PAGE_EXECUTE_READ, PAGE_EXECUTE_READWRITE, PAGE_EXECUTE_WRITECOPY];
var
  MemInfo: TMemoryBasicInformation;
  Tmp: DWord;
begin
  Result := 0;
  if (VirtualQuery(Pointer(Address), MemInfo, SizeOf(MemInfo)) = SizeOf(MemInfo)) and
    (MemInfo.State = MEM_COMMIT) and (MemInfo.Protect in ReadAttributes) then
  begin
    Result := (MemInfo.RegionSize - (Address - DWord(MemInfo.BaseAddress)));
    if (Result < Size) then
    begin
      repeat
        Tmp := GetReadableSize((DWord(MemInfo.BaseAddress) + MemInfo.RegionSize), (Size - Result));
        if (Tmp > 0) then Inc(Result, Tmp)
        else Result := 0;
      until (Result >= Size) or (Tmp = 0);
    end;
  end;
end;

function IsValidBlockAddr(Address, Size: DWord): Boolean;
begin
  try
    Result := (GetReadableSize(Address, Size) >= Size);
  except
    Result := false;
  end;
end;
{$ENDIF}

procedure TBaseSymbolTable.CheckMemory(p: Pointer; Size: Cardinal);
begin
{$IFNDEF LINUX}
  if not IsValidBlockAddr(Cardinal(p), Size) then
    raise EAbort.Create(errMemoryNotInitialized);
{$ENDIF}
end;

constructor TBaseSymbolTable.Create;
begin
  inherited;
  A := TList.Create;
  HeaderParser := THeaderParser.Create;
  Card := -1;
  VarObjects := TVarObjectList.Create(Self);
  HashArray := THashArray.Create;
  GuidList := TGuidList.Create;
  SomeTypeList := TSomeTypeList.Create;
  ExternList := TExternList.Create;
  LastCard := 0;
end;

destructor TBaseSymbolTable.Destroy;
var
  I: Integer;
begin
  VarObjects.Free;
  for I := A.Count - 1 downto 0 do
    TSymbolRec(A[I]).Free;
  A.Free;
  HeaderParser.Free;
  HashArray.Free;
  GuidList.Free;
  SomeTypeList.Free;
  ExternList.Free;
  inherited;
end;

procedure TBaseSymbolTable.Reset;
var
  I: Integer;
  R: TSymbolRec;
begin
  VarObjects.Clear;
  ExternList.Clear;
  SomeTypeList.Clear;

  for I:=0 to A.Count - 1 do
    Records[I].Free;
  A.Clear;
  Card := -1;

  for I:=0 to Types.Count - 1 do
  begin
    R := AddRecord;
    R.Name := Types[I].Name;
    R.Kind := KindTYPE;
    R.Completed := true;
  end;

  while Card < typePANSICHAR - 1 do
    AddRecord;

  RegisterPointerType(0, 'PCHAR', typeANSICHAR);
  RegisterPointerType(0, 'PVOID', typeVOID);
  RegisterPointerType(0, 'PWIDECHAR', typeWIDECHAR);

  with AddRecord do
  begin
    NilId := Id;
    Kind := KindCONST;
    TypeId := typePOINTER;
    Level := 0;
    Value := 0;
  end;

  with AddBooleanConst(false) do
  begin
    FalseId := Id;
    Name := 'false';
    Level := typeBOOLEAN;
  end;

  with AddBooleanConst(true) do
  begin
    TrueId := Id;
    Name := 'true';
    Level := typeBOOLEAN;
  end;

  with AddByteBoolConst(Low(ByteBool)) do
    Level := typeBYTEBOOL;
  with AddByteBoolConst(High(ByteBool)) do
    Level := typeBYTEBOOL;

  with AddWordBoolConst(Low(WordBool)) do
    Level := typeWORDBOOL;
  with AddWordBoolConst(High(WordBool)) do
    Level := typeWORDBOOL;

  with AddLongBoolConst(Low(LongBool)) do
    Level := typeLONGBOOL;
  with AddLongBoolConst(High(LongBool)) do
    Level := typeLONGBOOL;

  with AddAnsiCharConst(Low(AnsiChar)) do
    Level := typeANSICHAR;
  with AddAnsiCharConst(High(AnsiChar)) do
    Level := typeANSICHAR;

  with AddByteConst(Low(Byte)) do
    Level := typeBYTE;
  with AddByteConst(High(Byte)) do
    Level := typeBYTE;

  with AddWordConst(Low(Word)) do
    Level := typeWORD;
  with AddWordConst(High(Word)) do
    Level := typeWORD;

  with AddIntegerConst(Low(Integer)) do
    Level := typeINTEGER;
  with AddIntegerConst(High(Integer)) do
    Level := typeINTEGER;

  with AddInt64Const(Low(Int64)) do
    Level := typeINT64;
  with AddInt64Const(High(Int64)) do
    Level := typeINT64;

  with AddCardinalConst(Low(Cardinal)) do
    Level := typeCARDINAL;
  with AddCardinalConst(High(Cardinal)) do
    Level := typeCARDINAL;

  with AddSmallIntConst(Low(SmallInt)) do
    Level := typeSMALLINT;
  with AddSmallIntConst(High(SmallInt)) do
    Level := typeSMALLINT;

  with AddShortIntConst(Low(ShortInt)) do
    Level := typeSHORTINT;
  with AddShortIntConst(High(ShortInt)) do
    Level := typeSHORTINT;

  Records[typePOINTER].PatternId := typeVOID;

  R := AddRecord;
  R.Kind := KindVAR;
  ResultID := R.Id;

  R := AddRecord;
  R.Kind := KindNONE;
  R.TypeId := typePOINTER;
  R.Shift := H_SelfPtr;

  R := AddRecord;
  R.Kind := KindVAR;
  R.TypeId := typePOINTER;
  R.Shift := H_ExceptionPtr;
  R.Host := true;
  CurrExceptionObjectId := R.Id;
  GlobalCurrExceptionObjectId := CurrExceptionObjectId;

  R := AddRecord;
  R.Kind := KindNONE;
  R.TypeId := typeINTEGER;
  R.Shift := H_ByteCodePtr;

  R := AddRecord;
  R.Kind := KindNONE;
  R.TypeId := typeINTEGER;
  R.Shift := H_Flag;

  LastShiftValue := H_Flag + 4;

  R := CreateEmptySet;
  EmptySetId := R.Id;

  H_TByteSet := RegisterSetType(0, '$$', typeBYTE);

  EmptyStringId := AddPAnsiCharConst('').Id;

  with AddRecord do
  begin
    EventNilId := Id;
    Kind := KindVAR;
    TypeId := typeEVENT;
    Level := 0;
    Value := 0;
    Shift := LastShiftValue;
    Inc(LastShiftValue, SizeOf(TMethod));
  end;

  if LastShiftValue <> FirstShiftValue then
    RaiseError(errInternalError, []);
    
  LastClassIndex := -1;
end;

function TBaseSymbolTable.RegisterNamespace(LevelId: Integer;
                                        const NamespaceName: String): Integer;
begin
  result := LookupNamespace(NamespaceName, LevelId, true);
  if result > 0 then
  begin
    HeaderParser.NamespaceId := result;
    Exit;
  end;

  LastCard := Card;

  with AddRecord do
  begin
    Name := NamespaceName;
    Kind := KindNAMESPACE;
    Host := true;
    Level := LevelId;
    result := Id;
  end;
  HeaderParser.NamespaceId := result;
end;

function TBaseSymbolTable.RegisterTypeDeclaration(LevelId: Integer;
  const Declaration: String): Integer;
begin
  HeaderParser.Init(Declaration, Self, LevelId);
  HeaderParser.Call_SCANNER;
  result := HeaderParser.Register_TypeDeclaration;
end;

procedure TBaseSymbolTable.UpdateSomeTypeList(const TypeName: String; TypeId: Integer);
var
  I, Id: Integer;
  R: TSymbolRec;
begin
  I := SomeTypeList.IndexOf(TypeName);
  if I = -1 then
    Exit;

  Id := SomeTypeList[I].Id;
  SomeTypeList.Delete(I);

  for I := Card downto StdCard do
  begin
    R := Records[I];
    if R.PatternId = Id then
       R.PatternId := TypeId;
  end;

  Records[Id].Kind := KindNONE;
  Records[Id].Name := '';
end;

function TBaseSymbolTable.RegisterSubrangeType(LevelId: Integer;
                                           const TypeName: String;
                                           TypeBaseId: Integer;
                                           B1, B2: Integer): Integer;
begin
  if SomeTypeList.Count > 0 then
    UpdateSomeTypeList(TypeName, Card + 1);

  LastCard := Card;

  if not TypeBaseId in OrdinalTypes then
  begin
    result := 0;
    RaiseError(errInternalError, []);
    Exit;
  end;

  with AddRecord do
  begin
    Name := TypeName;
    Kind := KindTYPE;
    TypeID := TypeBaseId;
    Host := true;
    Shift := 0;
    Level := LevelId;
    result := Id;

    Completed := true;
  end;

  with AddRecord do
  begin
    Kind := KindCONST;
    TypeID := TypeBaseId;
    Host := true;
    Shift := 0;
    Level := result;
    Value := B1;
  end;

  with AddRecord do
  begin
    Kind := KindCONST;
    TypeID := TypeBaseId;
    Host := true;
    Shift := 0;
    Level := result;
    Value := B2;
  end;
end;

function TBaseSymbolTable.RegisterEnumType(LevelId: Integer;
                                       const TypeName: String;
                                       TypeBaseId: Integer): Integer;
begin
  LastCard := Card;

  if TypeName <> '' then
  begin
    result := LookUpType(TypeName, LevelId, true);
    if (result > 0) and (Records [Result].Level = LevelID) then
      Exit;
  end;
  
  if SomeTypeList.Count > 0 then
    UpdateSomeTypeList(TypeName, Card + 1);

  with AddRecord do
  begin
    Name := TypeName;
    Kind := KindTYPE;
    TypeID := typeENUM;
    Host := true;
    Shift := 0;
    Level := LevelId;
    PatternId := TypeBaseId;
    result := Id;
  end;
end;

function TBaseSymbolTable.RegisterEnumValue(EnumTypeId: Integer;
                                        const FieldName: String;
                                        const i_Value: Integer): Integer;
begin
  with AddRecord do
  begin
    Name := FieldName;
    Kind := KindCONST;
    TypeID := EnumTypeId;
    Host := true;
    Shift := 0;
    Level := Records[EnumTypeId].Level;
    OwnerId := TypeId;

    Value := i_Value;

    result := Id;
  end;

  if EnumTypeId > 0 then
    Records[EnumTypeId].Count := Records[EnumTypeId].Count + 1;
end;

function TBaseSymbolTable.RegisterArrayType(LevelId: Integer;
                                        const TypeName: String;
                                        RangeTypeId, ElemTypeId: Integer;
                                        Align: Integer): Integer;
begin
  LastCard := Card;

  if SomeTypeList.Count > 0 then
    UpdateSomeTypeList(TypeName, Card + 1);

  with AddRecord do
  begin
    Name := TypeName;
    Kind := KindTYPE;
    TypeID := typeARRAY;
    Host := true;
    Shift := 0;
    Level := LevelId;

    DefaultAlignment := Align;

    result := Id;

    Completed := true;
  end;

  with AddRecord do
  begin
    Kind := KindTYPE;
    TypeID := typeALIAS;
    Host := true;
    Shift := 0;
    Level := result;
    PatternId := RangeTypeId;
  end;

  with AddRecord do
  begin
    Kind := KindTYPE;
    TypeID := typeALIAS;
    Host := true;
    Shift := 0;
    Level := result;
    PatternId := ElemTypeId;
  end;
end;

function TBaseSymbolTable.RegisterTypeAlias(LevelId:Integer;
                                            const TypeName: String;
                                            OriginTypeId: Integer): Integer;
begin
  LastCard := Card;

  result := LookupType(TypeName, LevelId, true);
  if result > 0 then
  begin
    if Records[result].Level = LevelId then
      if result > OriginTypeId then
        Exit;
  end;

  if SomeTypeList.Count > 0 then
    UpdateSomeTypeList(TypeName, Card + 1);

  with AddRecord do
  begin
    Name := TypeName;
    Kind := KindTYPE;
    TypeID := typeALIAS;
    Host := true;
    Shift := 0;
    Level := LevelId;
    PatternId := OriginTypeId;
    result := Id;
  end;
end;

function TBaseSymbolTable.RegisterTypeAlias(LevelId:Integer;
                                            const Declaration: String): Integer;
var
  TypeName: String;
begin
  HeaderParser.Init(Declaration, Self, LevelId);
  HeaderParser.Call_SCANNER;
  TypeName := HeaderParser.Parse_Ident;
  result := HeaderParser.Register_TypeAlias(TypeName);
end;

function TBaseSymbolTable.RegisterPointerType(LevelId: Integer;
                                          const TypeName: String;
                                          OriginTypeId: Integer): Integer;
begin
  LastCard := Card;

  if SomeTypeList.Count > 0 then
    UpdateSomeTypeList(TypeName, Card + 1);

  with AddRecord do
  begin
    Name := TypeName;
    Kind := KindTYPE;
    TypeID := typePOINTER;
    Host := true;
    Shift := 0;
    Level := LevelId;

    PatternId := OriginTypeId;

    result := Id;

    Completed := true;
  end;
end;

function TBaseSymbolTable.RegisterDynamicArrayType(LevelId: Integer;
                                                   const TypeName: String;
                                                   ElemTypeId: Integer): Integer;
begin
  LastCard := Card;

  if SomeTypeList.Count > 0 then
    UpdateSomeTypeList(TypeName, Card + 1);

  with AddRecord do
  begin
    Name := TypeName;
    Kind := KindTYPE;
    TypeID := typeDYNARRAY;
    Host := true;
    Shift := 0;
    Level := LevelId;
    PatternId := ElemTypeId;
    result := Id;

    Completed := true;
  end;
end;

function TBaseSymbolTable.RegisterShortStringType(LevelId: Integer;
                                              const TypeName: String;
                                              L: Integer): Integer;
begin
  LastCard := Card;

  if SomeTypeList.Count > 0 then
    UpdateSomeTypeList(TypeName, Card + 1);

  with AddRecord do
  begin
    Name := TypeName;
    Kind := KindTYPE;
    TypeID := typeSHORTSTRING;
    Host := true;
    Shift := 0;
    Level := LevelId;
    Count := L;
    result := Id;

    Completed := true;
  end;
end;

function TBaseSymbolTable.RegisterSetType(LevelId: Integer;
                                      const TypeName: String;
                                      OriginTypeId: Integer): Integer;
begin
  LastCard := Card;

  if SomeTypeList.Count > 0 then
    UpdateSomeTypeList(TypeName, Card + 1);

  with AddRecord do
  begin
    Name := TypeName;
    Kind := KindTYPE;
    TypeID := typeSET;
    Host := true;
    Shift := 0;
    Level := LevelId;

    PatternId := OriginTypeId;

    result := Id;

    Completed := true;
  end;
end;

function TBaseSymbolTable.RegisterProceduralType(LevelId: Integer;
                                             const TypeName: String;
                                             HSub: Integer): Integer;
var
  I, SubId: Integer;
begin
  LastCard := Card;

  SubId := -1;
  for I:=Card downto 1 do
    if Records[I].Shift = HSub then
    begin
      SubId := I;
      Break;
    end;

  if SubId = -1 then
  begin
    result := 0;
    RaiseError(errInternalError, []);
    Exit;
  end;

  if SomeTypeList.Count > 0 then
    UpdateSomeTypeList(TypeName, Card + 1);

  with AddRecord do
  begin
    Name := TypeName;
    Kind := KindTYPE;
    TypeID := typePROC;
    Host := true;
    Shift := 0;
    Level := LevelId;

    PatternId := SubId;

    result := Id;

    Completed := true;
  end;
end;

function TBaseSymbolTable.RegisterEventType(LevelId: Integer;
                                            const TypeName: String;
                                            HSub: Integer): Integer;
var
  I, SubId: Integer;
begin
  LastCard := Card;

  SubId := -1;
  for I:=Card downto 1 do
    if Records[I].Shift = HSub then
    begin
      SubId := I;
      Break;
    end;

  if SubId = -1 then
  begin
    result := 0;
    RaiseError(errInternalError, []);
    Exit;
  end;

  if SomeTypeList.Count > 0 then
    UpdateSomeTypeList(TypeName, Card + 1);

  with AddRecord do
  begin
    Name := TypeName;
    Kind := KindTYPE;
    TypeID := typeEVENT;
    Host := true;
    Shift := 0;
    Level := LevelId;

    PatternId := SubId;

    result := Id;

    Completed := true;
  end;
end;

function TBaseSymbolTable.FindInterfaceTypeId(const GUID: TGUID): Integer;
var
  I: Integer;
begin
  I := GuidList.IndexOf(GUID);
  if I = -1 then
    result := 0
  else
    result := GuidList[I].Id;
end;

function TBaseSymbolTable.RegisterInterfaceType(LevelId: Integer;
                                                const TypeName: String;
                                                const GUID: TGUID): Integer;
var
  D: packed record
       D1, D2: Double;
     end;
begin
  LastCard := Card;

//  result := FindInterfaceTypeId(GUID);
  result := LookUpType(TypeName, LevelId, true);

  if result > 0 then
    Exit;

  if SomeTypeList.Count > 0 then
    UpdateSomeTypeList(TypeName, Card + 1);

  with AddRecord do
  begin
    Name := TypeName;
    Kind := KindTYPE;
    TypeID := typeINTERFACE;
    Host := true;
    Shift := 0;
    Level := LevelId;
    AncestorId := 0;
    result := Id;

    GuidList.Add(GUID, result, TypeName);
  end;

  Move(GUID, D, SizeOf(GUID));
  AddDoubleConst(D.D1);
  AddDoubleConst(D.D2);

  if not GuidsAreEqual(IUnknown, GUID) then
{$IFDEF VARIANTS}
    if not GuidsAreEqual(IInterface, GUID) then
{$ENDIF}
      RegisterSupportedInterface(result, 'IUnknown', IUnknown);
end;

function TBaseSymbolTable.RegisterInterfaceType(LevelId: Integer;
                                                pti: PTypeInfo): Integer;
var
  TypeData: PTypeData;
  L: TList;
  p: PTypeInfo;
  d: PTypeData;
  I: Integer;
begin
  LastCard := Card;

  result := 0;
  TypeData := GetTypeData(pti);
  if TypeData <> nil then
    if ifHasGuid in TypeData^.IntfFlags then
    begin
      L := TList.Create;
      try
{$IFDEF FPC}
        p := TypeData^.IntfParent;
{$ELSE}
        p := TypeData^.IntfParent^;
{$ENDIF}
        while p <> nil do
        begin
          L.Insert(0, p);
          d := GetTypeData(p);
          if d <> nil then
{$IFDEF FPC}
            p := d^.IntfParent
{$ELSE}
            p := d^.IntfParent^
{$ENDIF}
          else
            p := nil;
        end;
        for I := 0 to L.Count - 1 do
          RegisterInterfaceType(LevelId, L[I]);
      finally
        L.Free;
      end;

      result := RegisterInterfaceType(LevelId, String(pti^.Name), TypeData^.Guid);
    end;
end;

procedure TBaseSymbolTable.RegisterSupportedInterface(TypeId: Integer;
                             const SupportedInterfaceName: String;
                             const i_GUID: TGUID);
var
  InterfaceTypeId: Integer;
begin
  LastCard := Card;

  InterfaceTypeId := LookupType(SupportedInterfaceName, true);

  if InterfaceTypeId = 0 then
  begin
    ExternList.Add(TypeId, SupportedInterfaceName, erGUID);
    Exit;
  end;

  with Records[TypeId] do
  begin
    if SupportedInterfaces = nil then
      SupportedInterfaces := TGuidList.Create;
    SupportedInterfaces.Add(i_GUID, InterfaceTypeId, SupportedInterfaceName);
  end;
end;

procedure TBaseSymbolTable.RegisterSupportedInterface(TypeId,
                                                      InterfaceTypeId: Integer);
var
  SupportedInterfaceName: String;
  GUID: TGUID;
  D: record
       D1, D2: Double;
     end;
begin
  if Records[InterfaceTypeId].FinalTypeId <> typeINTERFACE then
    Exit;
    
  LastCard := Card;

  SupportedInterfaceName := Records[InterfaceTypeId].Name;
  D.D1 := Records[InterfaceTypeId + 1].Value;
  D.D2 := Records[InterfaceTypeId + 2].Value;
  Move(D, GUID, SizeOf(TGUID));

  with Records[TypeId] do
  begin
    if SupportedInterfaces = nil then
      SupportedInterfaces := TGuidList.Create;
    SupportedInterfaces.Add(GUID, InterfaceTypeId, SupportedInterfaceName);
  end;
end;

procedure TBaseSymbolTable.RegisterClassTypeInfos(ClassId: Integer;
                                                  C: TClass);
  procedure SetAncestor;
  var
    I: Integer;
    S: String;
    ParentClass: TClass;
  begin
    ParentClass := C.ClassParent;

    if DllDefined then
      S := ParentClass.ClassName
    else
      S := '';

    for I:=ClassId - 1 downto H_TObject do
      with Records[I] do
      if PClass <> nil then
      begin
        if DllDefined then
        begin
          if Kind = KindTYPE then if Name = S then
          begin
            Records[ClassId].AncestorId := I;
            Exit;
          end
        end
        else
        if PClass = ParentClass then
        begin
          Records[ClassId].AncestorId := I;
          Exit;
        end;
      end;

    Records[ClassId].AncestorId := H_TObject;
  end;

var
  UnresolvedPropIds: TIntegerList;
  UnresolvedTypes: TList;

  procedure RegisterPublishedProperty(Index: Integer; ppi: PPropInfo);
  var
    TypeData: PTypeData;
    pti: PTypeInfo;
    T: Integer;
  begin
    if ppi = nil then
      Exit;

  {$ifdef fpc}
      pti := ppi^.PropType;
  {$else}
      pti := ppi.PropType^;
  {$endif}

    T := 0;

    case pti^.Kind of
      tkInteger: T := typeINTEGER;
      tkFloat:
      begin
        TypeData := GetTypeData(pti);
        case TypeData^.FloatType of
          ftSingle: T := typeSINGLE;
          ftDouble: T := typeDOUBLE;
          ftExtended: T := typeEXTENDED;
        end;
      end;
      tkChar: T := typeANSICHAR;
      tkString: T := typeSHORTSTRING;
      tkLString: T := typeANSISTRING;
{$IFDEF UNIC}
      tkUString: T := typeUNICSTRING;
{$ENDIF}
      tkVariant: T := typeVARIANT;
      else
        T := LookupType(String(pti^.Name), 0, true);
    end;

    with AddRecord do
    begin
      Name := String(ppi^.Name);
      Kind := KindPROP;
      TypeID := T;
      Host := true;
      Shift := 0;
      Level := ClassId;
      IsPublished := true;
      PropIndex := Index;
    end;

    if T = 0 then
    begin
      UnresolvedPropIds.Add(Card);
      UnresolvedTypes.Add(pti);
    end;
  end;

  function RegisterPublishedProperties: Integer;
  var
    pti: PTypeInfo;
    ptd: PTypeData;
    I, nProps: Integer;
    pProps: PPropList;
    ppi: PPropInfo;
  begin
    result := 0;
    pti := C.ClassInfo;
    if pti = nil then Exit;
    ptd := GetTypeData(pti);
    nProps := ptd^.PropCount;
    if nProps > 0 then begin
      GetMem(pProps, SizeOf(PPropInfo) * nProps);
      GetPropInfos(pti, pProps);
    end
    else
      pProps := nil;
    for I:=0 to nProps - 1 do
    begin
  {$ifdef fpc}
      ppi := pProps^[I];
  {$else}
      ppi := pProps[I];
  {$endif}
      RegisterPublishedProperty(I, ppi);
    end;
    if pProps <> nil then
      FreeMem(pProps, SizeOf(PPropInfo) * nProps);
    result := nProps;
  end;

var
  I, K, T: Integer;
  pti: PTypeInfo;
begin
  Records[ClassId].PClass := C;
  Records[ClassId + 1].Value := Integer(C); // classref var

  if C <> TObject then
    SetAncestor;

  UnresolvedPropIds := TIntegerList.Create;
  UnresolvedTypes := TList.Create;

  try
    RegisterPublishedProperties;
    AddEndOfClassHeader(ClassId);

    for I:=0 to UnresolvedTypes.Count - 1 do
    begin
      pti := UnresolvedTypes[I];
      K := UnresolvedPropIds[I];

      T := RegisterRTTIType(0, pti);
      if T = 0 then
      begin
        Records[K].Name := '';
        Records[K].Kind := KindNONE;
      end
      else
        Records[K].TypeID := T;
    end;

  finally
    UnresolvedPropIds.Free;
    UnresolvedTypes.Free;
  end;
end;

function TBaseSymbolTable.RegisterClassTypeForImporter(LevelId: Integer;
                                                       C: TClass): Integer;
begin
  result := RegisterClassType(LevelId, C.ClassName, H_TObject);
  AddVoidVar(0, MaxPublishedProps * 4);
end;

function TBaseSymbolTable.RegisterClassTypeForImporter(LevelId: Integer;
                                                       const TypeName: String): Integer;
begin
  result := RegisterClassType(LevelId, TypeName, H_TObject);
  AddVoidVar(0, MaxPublishedProps * 4);
end;

function TBaseSymbolTable.RegisterClassType(LevelId: Integer;
                                            const TypeName: String;
                                            i_AncestorId: Integer): Integer;
var
  ClassRefTypeId: Integer;
begin
  if SomeTypeList.Count > 0 then
    UpdateSomeTypeList(TypeName, Card + 1);

  LastCard := Card;

  Inc(LastClassIndex);
  with AddRecord do
  begin
    Name := TypeName;
    Kind := KindTYPE;
    TypeID := typeCLASS;
    Host := true;
    Shift := 0;
    Level := LevelId;
    ClassIndex := LastClassIndex;
    AncestorId := i_AncestorId;

    result := Id;
  end;

  AddClassRefVar(0);
  ClassRefTypeId := RegisterClassReferenceType(0, '', result);
  Records[result + 1].TypeId := ClassRefTypeId;
end;

function TBaseSymbolTable.RegisterClassType(LevelId: Integer;
                                            C: TClass): Integer;

var
  UnresolvedPropIds: TIntegerList;
  UnresolvedTypes: TList;

  procedure RegisterPublishedProperty(Index: Integer; ppi: PPropInfo);
  var
    TypeData: PTypeData;
    pti: PTypeInfo;
    T: Integer;
  begin
    if ppi = nil then
      Exit;

  {$ifdef fpc}
      pti := ppi^.PropType;
  {$else}
      pti := ppi.PropType^;
  {$endif}

    T := 0;

    case pti^.Kind of
      tkInteger: T := typeINTEGER;
      tkFloat:
      begin
        TypeData := GetTypeData(pti);
        case TypeData^.FloatType of
          ftSingle: T := typeSINGLE;
          ftDouble: T := typeDOUBLE;
          ftExtended: T := typeEXTENDED;
        end;
      end;
      tkChar: T := typeANSICHAR;
      tkString: T := typeSHORTSTRING;
{$IFDEF UNIC}
      tkUString: T := typeUNICSTRING;
{$ENDIF}
      tkLString: T := typeANSISTRING;
      tkVariant: T := typeVARIANT;
      else
        T := LookupType(String(pti^.Name), 0, true);
    end;

    with AddRecord do
    begin
      Name := String(ppi^.Name);
      Kind := KindPROP;
      TypeID := T;
      Host := true;
      Shift := 0;
      Level := result;
      IsPublished := true;
      PropIndex := Index;
    end;

    if T = 0 then
    begin
      UnresolvedPropIds.Add(Card);
      UnresolvedTypes.Add(pti);
    end;
  end;

  function RegisterPublishedProperties: Integer;
  var
    pti: PTypeInfo;
    ptd: PTypeData;
    I, nProps: Integer;
    pProps: PPropList;
    ppi: PPropInfo;
  begin
    result := 0;
    pti := C.ClassInfo;
    if pti = nil then Exit;
    ptd := GetTypeData(pti);
    nProps := ptd^.PropCount;
    if nProps > 0 then begin
      GetMem(pProps, SizeOf(PPropInfo) * nProps);
      GetPropInfos(pti, pProps);
    end
    else
      pProps := nil;
    for I:=0 to nProps - 1 do
    begin
  {$ifdef fpc}
      ppi := pProps^[I];
  {$else}
      ppi := pProps[I];
  {$endif}
      RegisterPublishedProperty(I, ppi);
    end;
    if pProps <> nil then
      FreeMem(pProps, SizeOf(PPropInfo) * nProps);
    result := nProps;
  end;

  procedure SetAncestor;
  var
    I: Integer;
    S: String;
    ParentClass: TClass;
  begin
    ParentClass := C.ClassParent;

    if DllDefined then
      S := ParentClass.ClassName
    else
      S := '';

    for I:=result - 1 downto H_TObject do
      with Records[I] do
      if PClass <> nil then
      begin
        if DllDefined then
        begin
          if Kind = KindTYPE then if Name = S then
          begin
            Records[result].AncestorId := I;
            Exit;
          end
        end
        else
        if PClass = ParentClass then
        begin
          Records[result].AncestorId := I;
          Exit;
        end;
      end;
{
    if AncestorRequired then
      ExternList.Add(result, ParentClass.ClassName, erAncestorId)
    else
}
    Records[result].AncestorId := H_TObject;
  end;

  procedure RegisterAncestors(Cls: TClass);
  var
    ParentClass: TClass;
    Id: Integer;
  begin
    ParentClass := Cls.ClassParent;
    if ParentClass = nil then
      Exit;
    Id := FindClassTypeId(ParentClass);
    if Id > 0 then
      Exit;
    RegisterClassType(LevelId, ParentClass);
    RegisterAncestors(ParentClass);
  end;

var
  I, K, T: Integer;
  pti: PTypeInfo;
  S: String;
  R: TSymbolRec;
  AlreadyExists: Boolean;
  K1, K2, KK: Integer;
begin
  LastCard := Card;

  AlreadyExists := false;
  result := FindClassTypeId(C);
  T := result;

  if result > 0 then
  begin
    if result < FirstLocalId then
      if Card >= FirstLocalId then
      begin
        Records[result].Level := LevelId;
        Exit;
      end;

    AlreadyExists := true;
  end;

  if not AlreadyExists then
    RegisterAncestors(C);

  S := C.ClassName;

  result := RegisterClassType(LevelId, S, 0);

  if AlreadyExists then
  begin
    Records[T].Name := '@@';
    Records[T].PClass := nil;
    Records[T].ClassIndex := -1;
    Records[T + 1].Value := 0;

    for KK := 1 to 2 do
    begin
      if KK = 1 then
      begin
        K1 := 1;
        K2 := GlobalSymbolTable.Card;
      end
      else
      begin
        K1 := FirstLocalId + 1;
        K2 := Card;
      end;

      for I := K1 to K2 do
      begin
        R := Records[I];

        if R.TypeID = T then
          R.TypeID := result;
        if R.PatternID = T then
          R.PatternID := result;
        if R.AncestorID = T then
          R.AncestorID := result;
      end;
    end;
  end;

  Records[result].PClass := C;
  if S <> TObject.ClassName then
    SetAncestor;

  Records[Result + 1].Value := Integer(C); // classref var

  UnresolvedPropIds := TIntegerList.Create;
  UnresolvedTypes := TList.Create;

  try

    K := RegisterPublishedProperties;
    for I:=1 to K do // reserve place for ppi
      AddPointerVar(0);

    AddEndOfClassHeader(result);

    for I:=0 to UnresolvedTypes.Count - 1 do
    begin
      pti := UnresolvedTypes[I];
      K := UnresolvedPropIds[I];

      T := RegisterRTTIType(0, pti);
      if T = 0 then
      begin
        Records[K].Name := '';
        Records[K].Kind := KindNONE;
      end
      else
        Records[K].TypeID := T;
    end;

  finally
    UnresolvedPropIds.Free;
    UnresolvedTypes.Free;
  end;
end;

function TBaseSymbolTable.RegisterClassReferenceType(LevelId: Integer;
                                                     const TypeName: String;
                                                     OriginClassId: Integer): Integer;
begin
  if SomeTypeList.Count > 0 then
    UpdateSomeTypeList(TypeName, Card + 1);

  LastCard := Card;

  with AddRecord do
  begin
    Name := TypeName;
    Kind := KindTYPE;
    TypeID := typeCLASSREF;
    Host := true;
    Shift := 0;
    Level := LevelId;
    PatternId := OriginClassId;
    result := Id;

    Completed := true;
  end;
end;

function TBaseSymbolTable.RegisterRecordType(LevelId: Integer;
                                             const TypeName: String;
                                             Align: Integer): Integer;
begin
  if SomeTypeList.Count > 0 then
    UpdateSomeTypeList(TypeName, Card + 1);

  LastCard := Card;

  with AddRecord do
  begin
    Name := TypeName;
    Kind := KindTYPE;
    TypeID := typeRECORD;
    Host := true;
    Shift := 0;
    Level := LevelId;
    DefaultAlignment := Align;

    result := Id;
  end;
end;

function TBaseSymbolTable.RegisterRTTIType(LevelId: Integer;
                                           pti: PTypeInfo): Integer;
var
  TypeData, td, ptd: PTypeData;
  S: String;
  I, T, K1, K2: Integer;

  pParam: PParamData;
  pTypeString: ^ShortString;

  ParamIds: array[0..20] of Integer;
  ParamRef: array[0..20] of Boolean;
  H_Sub: Integer;
begin
  LastCard := Card;

  S := String(pti^.Name);
  result := LookupType(S, LevelId, true);
  if result > 0 then
    Exit;

  case pti^.Kind of
    tkInteger:
    begin
      result := RegisterTypeAlias(LevelId, String(pti^.Name), typeINTEGER);
    end;
    tkInt64:
    begin
      result := RegisterTypeAlias(LevelId, String(pti^.Name), typeINT64);
    end;
    tkFloat:
    begin
      TypeData := GetTypeData(pti);
      with TypeData^ do
      case FloatType of
        ftSingle: result := RegisterTypeAlias(LevelId, String(pti^.Name), typeSINGLE);
        ftDouble: result := RegisterTypeAlias(LevelId, String(pti^.Name), typeDOUBLE);
        ftExtended: result := RegisterTypeAlias(LevelId, String(pti^.Name), typeEXTENDED);
      end
    end;
    tkEnumeration:
    begin
      S := String(pti^.Name);
      K1 := Card;
      T := RegisterEnumType(LevelId, S, typeINTEGER);
      K2 := Card;
      if K1 <> K2 then
      begin
        TypeData := GetTypeData(pti);
        with TypeData^ do
        begin
//        if (MinValue < 256) and (MaxValue < 256) then
          for I:= MinValue to MaxValue do
          begin
            S := GetEnumName(pti, I);
            RegisterEnumValue(T, S, I);
          end;
        end;
      end;
      result := T;
    end;
    tkSet:
    begin
      TypeData := GetTypeData(pti);
      S := String(TypeData^.CompType^.Name);
      case TypeData^.CompType^.Kind of
        tkInteger:
        begin
          result := RegisterSetType(LevelId, String(pti^.Name), typeINTEGER);
        end;
        tkChar:
        begin
          result := RegisterSetType(LevelId, String(pti^.Name), typeANSICHAR);
        end;
        tkWChar:
        begin
          result := RegisterSetType(LevelId, String(pti^.Name), typeWIDECHAR);
        end;
        tkEnumeration:
        begin
          K1 := Card;
          T := RegisterEnumType(LevelId, S, typeINTEGER);
          K2 := Card;
          if K1 <> K2 then
          begin
{$ifdef fpc}
            td := GetTypeData(TypeData^.CompType);
{$else}
            td := GetTypeData(TypeData^.CompType^);
{$endif}
            with td^ do
              if (MinValue < 256) and (MaxValue < 256) then
              for I:= MinValue to MaxValue do
              begin
{$ifdef fpc}
                S := GetEnumName(TypeData^.CompType, I);
{$else}
                S := GetEnumName(TypeData^.CompType^, I);
{$endif}
                RegisterEnumValue(T, S, I);
              end;
          end;
          result := RegisterSetType(LevelId, String(pti^.Name), T);
        end;
      end;
    end;
    tkClass:
    begin
      TypeData := GetTypeData(pti);
      result := RegisterClassType(LevelId, TypeData^.ClassType);
    end;
    tkInterface:
    begin
      TypeData := GetTypeData(pti);
      if TypeData <> nil then
        if ifHasGuid in TypeData^.IntfFlags then
          result := RegisterInterfaceType(LevelId, pti);
    end;
    tkChar:
    begin
      result := RegisterTypeAlias(LevelId, String(pti^.Name), typeANSICHAR);
    end;
    tkString:
    begin
      result := RegisterTypeAlias(LevelId, String(pti^.Name), typeSHORTSTRING);
    end;
    tkLString:
    begin
      result := RegisterTypeAlias(LevelId, String(pti^.Name), typeANSISTRING);
    end;
{$IFDEF UNIC}
    tkUString:
    begin
      result := RegisterTypeAlias(LevelId, String(pti^.Name), typeUNICSTRING);
    end;
{$ENDIF}
    tkWString:
    begin
      result := RegisterTypeAlias(LevelId, String(pti^.Name), typeWIDESTRING);
    end;
    tkVariant:
    begin
      result := RegisterTypeAlias(LevelId, String(pti^.Name), typeVARIANT);
    end;
    tkMethod:
    begin
      S := String(pti^.Name);

      result := LookUpType(S, 0, true);
      if result > 0 then
        Exit;

      ptd := GetTypeData(pti);

      pParam := PParamData(@(ptd^.ParamList));
      I := 0;
      while I <= ptd^.ParamCount - 1 do
      begin
        ParamRef[I] := false;
        if pfVar in pParam^.Flags then
        begin
          ParamRef[I] := true;
        end
        else if pfConst in pParam^.Flags then
        begin
        end
        else if pfOut in pParam^.Flags then
        begin
          ParamRef[I] := true;
        end;

        if pfArray in pParam^.Flags then
        begin
          result := H_TMethod;
          Exit;
        end;

        pTypeString := ShiftPointer(pParam, SizeOf(TParamFlags) +
                                    Length(pParam^.ParamName) + 1);

        T := LookUpType(String(pTypeString^), 0, true);
        if T = 0 then
        begin
          result := H_TMethod;
          Exit;
        end;
        ParamIds[I] := T;

        if Records[T].FinalTypeId in [typeRECORD, typeARRAY] then
          ParamRef[I] := true;

        pParam := ShiftPointer(pTypeString, Length(pTypeString^) + 1);
        Inc(I);
      end;

      T := typeVOID;
      if ptd^.MethodKind = mkFunction then
      begin
        pTypeString := Pointer(pParam);
        T := LookUpType(String(pTypeString^), 0, true);
        if T = 0 then
        begin
          result := H_TMethod;
          Exit;
        end;
      end;

      H_Sub := RegisterRoutine(0, '', T, ccREGISTER, nil);

      K1 := I;
      for I:=0 to K1 - 1 do
        RegisterParameter(H_Sub, ParamIds[I], Unassigned, ParamRef[I]);

      result := RegisterEventType(0, S, H_Sub);
    end;
    else
      Exit;
  end;
end;

function TBaseSymbolTable.RegisterProperty(LevelId: Integer; const PropName: String;
                                       PropTypeID, i_ReadId, i_WriteId: Integer;
                                       i_IsDefault: Boolean): Integer;
var
  I: Integer;
begin
  with AddRecord do
  begin
    Name := PropName;
    Count := 0;
    Kind := KindPROP;
    TypeID := PropTypeID;
    Host := true;
    Shift := 0;
    Level := LevelId;

    if i_ReadId <= 0 then
      ReadId := - i_ReadId
    else
    begin
      ReadId := -1;
      for I:=Card downto 1 do
        if Records[I].Shift = i_ReadId then
        begin
          ReadId := I;
          Break;
        end;

      if ReadId = -1 then
      begin
        result := 0;
        RaiseError(errInternalError, []);
        Exit;
      end;
    end;

    if i_WriteId <= 0 then
      WriteId := - i_WriteId
    else
    begin
      WriteId := -1;
      for I:=Card downto 1 do
        if Records[I].Shift = i_WriteId then
        begin
          WriteId := I;
          Break;
        end;

      if WriteId = -1 then
      begin
        result := 0;
        RaiseError(errInternalError, []);
        Exit;
      end;
    end;

    IsDefault := i_IsDefault;

    result := Id;
  end;

  with AddRecord do
  begin
    Kind := KindVAR;
    TypeID := PropTypeID;
    Host := true;
    Shift := 0;
    Level := result;
  end;
end;

function TBaseSymbolTable.RegisterInterfaceProperty(LevelId: Integer;
                                   const PropName: String;
                                   PropTypeID,
                                   ReadIndex,
                                   WriteIndex: Integer): Integer;
var
  I: Integer;
  R: TSymbolRec;
  exists: Boolean;
begin
  with AddRecord do
  begin
    Name := PropName;
    Count := 0;
    Kind := KindPROP;
    TypeID := PropTypeID;
    Host := true;
    Shift := 0;
    Level := LevelId;

    result := Id;

    if ReadIndex <= 0 then
      ReadId := 0
    else
    begin
      exists := false;
      for I:=Card downto 1 do
      begin
        R := Records[I];
        if R.Level = LevelId then
        if R.MethodIndex = ReadIndex then
        begin
          ReadId := I;
          exists := true;
          Break;
        end;
      end;

      if not exists then
      begin
        result := 0;
        RaiseError(errInternalError, []);
        Exit;
      end;
    end;

    if WriteIndex <= 0 then
      WriteId := 0
    else
    begin
      exists := false;
      for I:=Card downto 1 do
      begin
        R := Records[I];
        if R.Level = LevelId then
        if R.MethodIndex = WriteIndex then
        begin
          WriteId := I;
          exists := true;
          Break;
        end;
      end;

      if not exists then
      begin
        result := 0;
        RaiseError(errInternalError, []);
        Exit;
      end;
    end;
  end;

  with AddRecord do
  begin
    Kind := KindVAR;
    TypeID := PropTypeID;
    Host := true;
    Shift := 0;
    Level := result;
  end;
end;

function TBaseSymbolTable.RegisterTypeFieldEx(LevelId: Integer;
                                              const Declaration: String;
                                              FieldOffset: Integer = -1): Integer;
var
  FieldName, FieldTypeName: String;
  FieldTypeId: Integer;
begin
  HeaderParser.Init(Declaration, Self, LevelId);
  HeaderParser.Call_SCANNER;
  FieldName := HeaderParser.Parse_Ident;
  HeaderParser.Match(':');
  FieldTypeName := HeaderParser.CurrToken;
  FieldTypeId := HeaderParser.LookupId(FieldTypeName);
  result := RegisterTypeField(LevelId, FieldName, FieldTypeId, FieldOffset);
end;

function TBaseSymbolTable.RegisterTypeField(LevelId: Integer;
                                            const FieldName: String;
                                            FieldTypeID: Integer;
                                            FieldOffset: Integer = -1): Integer;
var
  J, S: Integer;
  DefAlign, CurrAlign, J1, FT, FT1: Integer;
  R: TSymbolRec;
begin
  with AddRecord do
  begin
    Name := FieldName;
    Kind := KindTYPE_FIELD;
    TypeID := FieldTypeId;
    Host := true;
    Shift := FieldOffset;
    Level := LevelId;

    result := - Id;
  end;

  if FieldOffset = -1 then
  begin
    S := 0;
    if Records[LevelId].IsPacked then
    begin
      for J:=LevelId + 1 to Card do
      begin
        R := Records[J];

        if R = SR0 then
          break;

        if (R.Kind = KindTYPE_FIELD) and (R.Level = LevelId) then
        begin
          R.Shift := S;
          Inc(S, R.Size);
        end;
      end;
    end
    else
    begin
      DefAlign := Records[LevelId].DefaultAlignment;
      J1 := -1;

      for J:=LevelId + 1 to Card do
      begin
        R := Records[J];

        if R = SR0 then
          break;

        if (R.Kind = KindTYPE_FIELD) and (R.Level = LevelId) then
        begin
          CurrAlign := GetAlignmentSize(R.TypeId, DefAlign);

          if J1 > 0 then
          begin
            FT1 := Records[J-1].FinalTypeId;
            FT := R.FinalTypeId;
            if FT = FT1 then
            begin
              CurrAlign := 1;
              J1 := -1;
            end
            else
              J1 := J;
          end
          else
            J1 := J;

          if CurrAlign > 1 then
            while S mod CurrAlign <> 0 do
              Inc(S);

          R.Shift := S;
          Inc(S, R.Size);
        end;
      end; // for-loop
    end;
  end;
end;

function TBaseSymbolTable.RegisterVariantRecordTypeField(LevelId: Integer;
                                const Declaration: String;
                                VarCnt: Int64): Integer;
var
  FieldName: String;
begin
  HeaderParser.Init(Declaration, Self, LevelId);
  HeaderParser.Call_SCANNER;
  FieldName := HeaderParser.Parse_Ident;
  result := HeaderParser.Register_VariantRecordTypeField(FieldName, VarCnt);
end;

function TBaseSymbolTable.RegisterVariantRecordTypeField(LevelId: Integer;
                                const FieldName: String;
                                FieldTypeID: Integer;
                                VarCnt: Int64): Integer;
var
  J, S: Integer;
  DefAlign, CurrAlign, J1, FT, FT1, VJ, VK, VS: Integer;
  VarPathList: TVarPathList;
  Path: TVarPath;
  R: TSymbolRec;
begin
  with AddRecord do
  begin
    Name := FieldName;
    Kind := KindTYPE_FIELD;
    TypeID := FieldTypeId;
    Host := true;
    Level := LevelId;
    VarCount := VarCnt;

    result := - Id;
  end;

  VarPathList := TVarPathList.Create;
  try
    for J:=LevelId + 1 to Card do
    begin
      R := Records[J];
      if R = SR0 then
        break;

      if (R.Kind = KindTYPE_FIELD) and (R.Level = LevelId) then
        if R.VarCount > 0 then
          VarPathList.Add(J, R.VarCount);
    end;

    S := 0;
    if Records[LevelId].IsPacked then
    begin
      for J:=LevelId + 1 to Card do
      begin
        R := Records[J];
        if R = SR0 then
          break;

        if (R.Kind = KindTYPE_FIELD) and (R.Level = LevelId) then
        begin
          if R.VarCount > 0 then
            break;

          R.Shift := S;
          Inc(S, R.Size);
        end;
      end;

      // process variant part

      VS := S;
      for VK :=0 to VarPathList.Count - 1 do
      begin
        Path := VarPathList[VK];
        S := VS;

        for VJ := 0 to Path.Count - 1 do
        begin
          J := Path[VJ].Id;
          Records[J].Shift := S;
          Inc(S, Records[J].Size);
        end;
      end;
    end
    else
    begin
      DefAlign := Records[LevelId].DefaultAlignment;
      J1 := -1;

      for J:=LevelId + 1 to Card do
      begin
        R := Records[J];
        if R = SR0 then
          break;

        if (R.Kind = KindTYPE_FIELD) and (R.Level = LevelId) then
        begin
          if R.VarCount > 0 then
            break;

          CurrAlign := GetAlignmentSize(R.TypeId, DefAlign);

          if J1 > 0 then
          begin
            FT1 := Records[J-1].FinalTypeId;
            FT := R.FinalTypeId;
            if FT = FT1 then
            begin
              CurrAlign := 1;
              J1 := -1;
            end
            else
              J1 := J;
          end
          else
            J1 := J;

          if CurrAlign > 1 then
            while S mod CurrAlign <> 0 do
              Inc(S);

          R.Shift := S;
          Inc(S, R.Size);
        end;
      end; // for-loop

      // process variant part

      VS := S;
      for VK :=0 to VarPathList.Count - 1 do
      begin
        S := VS;
        Path := VarPathList[VK];

        for VJ := 0 to Path.Count - 1 do
        begin
          J := Path[VJ].Id;
          CurrAlign := GetAlignmentSize(Records[J].TypeId, DefAlign);

          if J1 > 0 then
          begin
            FT1 := Records[J-1].FinalTypeId;
            FT := Records[J].FinalTypeId;
            if FT = FT1 then
            begin
              CurrAlign := 1;
              J1 := -1;
            end
            else
              J1 := J;
          end
          else
            J1 := J;

          if CurrAlign > 1 then
            while S mod CurrAlign <> 0 do
              Inc(S);

          Records[J].Shift := S;
          Inc(S, Records[J].Size);
        end;
      end;
    end;

  finally
    VarPathList.Free;
  end;
end;

function TBaseSymbolTable.RegisterVariable(LevelId: Integer;
                                           const Declaration: String; Address: Pointer): Integer;
var
  VarName: String;
begin
  HeaderParser.Init(Declaration, Self, LevelId);
  HeaderParser.Call_SCANNER;
  VarName := HeaderParser.Parse_Ident;
  result := HeaderParser.Register_Variable(VarName, Address);
end;

function TBaseSymbolTable.RegisterVariable(LevelId: Integer; const VarName: String;
                                           VarTypeID: Integer; i_Address: Pointer): Integer;
begin
  LastCard := Card;

  result := LastShiftValue;
  with AddRecord do
  begin
    Name := VarName;
    Kind := KindVAR;
    TypeID := VarTypeID;

    Host := true;
    Shift := LastShiftValue;
    Level := LevelId;

    Address := i_Address;
  end;
  Inc(LastShiftValue, SizeOf(Pointer));

  LastVarId := Card;
end;

function TBaseSymbolTable.RegisterObject(LevelId: Integer;
                                         const ObjectName: String;
                                         TypeId: Integer;
                                         i_Address: Pointer): Integer;
var
  X: TObject;
  C: TComponent;
  I, Offset: Integer;
  S, FieldTypeName: String;
  FAddress: Pointer;
  FieldTypeId: Integer;
begin
  if ObjectName = '' then
  begin
    result := 0;
    if i_Address <> nil then
    begin
      X := TObject(i_Address^);
      if X is TComponent then
      begin
        C := X as TComponent;
        for I := 0 to C.ComponentCount - 1 do
        begin
          S := C.Components[I].Name;
          FieldTypeName := C.Components[I].ClassName;
          FieldTypeId := LookupType(FieldTypeName, true);
          FAddress := C.FieldAddress(S);
          if FieldTypeId > 0 then
            RegisterObject(LevelId, S, FieldTypeId, FAddress);
        end;
      end;
    end;
    Exit;
  end;

  result := RegisterVariable(LevelId, ObjectName, TypeId, i_Address);
  if i_Address <> nil then
  begin
    X := TObject(i_Address^);
    if X is TComponent then
    begin
      C := X as TComponent;
      for I := 0 to C.ComponentCount - 1 do
      begin
        S := C.Components[I].Name;
        FAddress := C.FieldAddress(S);
        if FAddress <> nil then
        begin
          FieldTypeName := C.Components[I].ClassName;
          Offset := Integer(FAddress) - Integer(C);
          FieldTypeId := LookupType(FieldTypeName, true);
          if FieldTypeId > 0 then
            RegisterTypeField(TypeId, S, FieldTypeId, Offset);
        end;
      end;
    end;
  end;
end;

procedure TBaseSymbolTable.RegisterMember(LevelId: Integer; const MemberName: String;
                                          i_Address: Pointer);
begin
  RegisterVariable(LevelId, MemberName, typeINTEGER, i_Address);
end;

function TBaseSymbolTable.RegisterConstant(LevelId: Integer;
                                           const Declaration: String): Integer;
var
  ConstName: String;
begin
  HeaderParser.Init(Declaration, Self, LevelId);
  HeaderParser.Call_SCANNER;
  ConstName := HeaderParser.Parse_Ident;
  result := HeaderParser.Register_Constant(ConstName);
end;

function TBaseSymbolTable.RegisterConstant(LevelId: Integer;
                                       const i_Name: String; i_TypeID: Integer; const i_Value: Variant): Integer;
var
  R: TSymbolRec;
  FT: Integer;
  VCardinal: Cardinal;
begin
  LastCard := Card;

  if Records[i_TypeID].HasPAnsiCharType then
    FT := typePANSICHAR
  else if Records[i_TypeID].HasPWideCharType then
    FT := typePWIDECHAR
  else
    FT := Records[i_TypeID].FinalTypeId;

  case FT of
    typeENUM: R := AddEnumConst(i_TypeId, Integer(i_Value));
    typeANSICHAR: R := AddAnsiCharConst(AnsiChar(Integer(i_Value)));
    typePANSICHAR: R := AddPAnsiCharConst(AnsiString(i_Value));
    typePWIDECHAR: R := AddPWideCharConst(i_Value);
    typeANSISTRING: R := AddPAnsiCharConst(AnsiString(i_Value));
    typeSHORTSTRING: R := AddShortStringConst(i_Value);
    typeUNICSTRING: R := AddPWideCharConst(i_Value);
    typeBYTE: R := AddByteConst(i_Value);
    typeWORD: R := AddWordConst(i_Value);
    typeINTEGER:
    begin
      if Abs(i_Value) > MaxInt then
      begin
        R := AddInt64Const({$IfNDef VARIANTS} integer (i_Value) {$Else} i_Value {$EndIf});
        R.TypeID := typeINTEGER;
      end
      else
        R := AddIntegerConst(i_Value);
    end;
{$IFDEF VARIANTS}
    typeINT64: R := AddInt64Const(i_Value);
{$ELSE}
    typeINT64: R := AddInt64Const(Integer(i_Value));
{$ENDIF}

    typeCARDINAL: R := AddCardinalConst(i_Value);
    typeSMALLINT: R := AddSmallIntConst(i_Value);
    typeSHORTINT: R := AddShortIntConst(i_Value);
    typeDOUBLE: R := AddDoubleConst(i_Value);
    typeSINGLE: R := AddSingleConst(i_Value);
    typeEXTENDED: R := AddExtendedConst(i_Value);
    typeCURRENCY: R := AddCurrencyConst(i_Value);
    typeBOOLEAN: R := AddBooleanConst(i_Value);
    typeBYTEBOOL: R := AddByteBoolConst(i_Value);
    typeWORDBOOL: R := AddWordBoolConst(i_Value);
    typeLONGBOOL: R := AddLongBoolConst(i_Value);
    typeVARIANT: R := AddVariantConst(i_Value);
    typeOLEVARIANT: R := AddOleVariantConst(i_Value);
    typeRECORD: R := AddRecordConst(i_TypeId, i_Value);
    typeARRAY: R := AddArrayConst(i_TypeId, i_Value);
    typeSET: R := AddSetConst(I_TypeId, i_Value);
    typeCLASS:
    begin
      VCardinal := i_Value;
      R := AddClassConst(I_TypeId, TObject(VCardinal));
    end;
    typeCLASSREF:
    begin
      VCardinal := i_Value;
      R := AddClassRefConst(I_TypeId, TClass(VCardinal));
      writeln(TClass(VCardinal).ClassName);
    end;
    typePOINTER, typeVOID:
    begin
      VCardinal := i_Value;
      R := AddPointerConst(i_TypeId, Pointer(VCardinal));
    end;
  else
    begin
      result := 0;
      RaiseError(errIncompatibleTypesNoArgs, []);
      Exit;
    end;
  end;

  R.Level := LevelId;
  R.Name := i_Name;
//  R.Host := true;
  result := R.Id;
end;

function TBaseSymbolTable.RegisterConstant(LevelId: Integer;
                                       const i_Name: String; const i_Value: Variant): Integer;
var
  TypeID: Integer;
  VT: Integer;
begin
  LastCard := Card;

  VT := VarType(i_Value);

  case VT of
    varEmpty: typeId := typeVARIANT;
    varBoolean: TypeId := typeBOOLEAN;
    varInteger, varByte, varSmallInt: TypeId := typeINTEGER;
{$IFDEF VARIANTS}
    varShortInt, varWord, varLongWord: TypeId := typeINTEGER;
{$ENDIF}
{$IFDEF UNIC}
    varUString: typeId := typeUNICSTRING;
{$ENDIF}
    varString: TypeId := typeANSISTRING;
    varDouble: TypeId := typeDOUBLE;
    varCurrency: TypeId := typeCURRENCY;
  else
    begin
      result := 0;
      RaiseError(errIncompatibleTypesNoArgs, []);
      Exit;
    end;
  end;
  result := RegisterConstant(LevelId, i_Name, TypeId, i_Value);
end;

function TBaseSymbolTable.RegisterRoutine(LevelId: Integer;
                                      const SubName: String; ResultTypeID: Integer;
                                      CallConvention: Integer;
                                      i_Address: Pointer): Integer;
var
  SubID: Integer;
begin
  result := LastShiftValue;
  with AddRecord do
  begin
    Name := SubName;
    Count := 0;
    Kind := KindSUB;
    TypeID := ResultTypeID;
    Host := true;
    Shift := LastShiftValue;
    Level := LevelId;
    CallConv := CallConvention;

    if not (CallConvention in [ccSTDCALL, ccREGISTER,
                               ccCDECL, ccPASCAL,
                               ccSAFECALL, ccMSFASTCALL]) then
    begin
      RaiseError(errInternalError, []);
      Exit;
    end;

    SubId := Id;

    Address := i_Address;
  end;
  Inc(LastShiftValue, SizeOf(Pointer));

  with AddRecord do
  begin
    Kind := KindVAR;
    TypeID := ResultTypeID;

    Host := true;

    Shift := 0;
    Level := SubId;
  end;

  with AddRecord do
  begin
    Kind := KindNONE;
    Host := true;
    Shift := 0;
    Level := SubId;
  end;

  LastSubId := SubId;
end;

function TBaseSymbolTable.RestorePositiveIndex(L: Integer): Integer;
var
  R: TSymbolRec;
  SupportedInterfaces: TGuidList;
  I, IntfId, temp: Integer;
begin
  R := Records[L];
  SupportedInterfaces := R.SupportedInterfaces;

  result := -1;

  if SupportedInterfaces <> nil then
  begin
    for I:=0 to SupportedInterfaces.Count - 1 do
    begin
//      Idx := GuidList.IndexOf(SupportedInterfaces[I].GUID);
//      if Idx >= 0 then
      begin
        IntfId := SupportedInterfaces[I].Id;
        temp := FindMaxMethodIndex(IntfId);
        if temp > result then
          result := temp;
      end;
    end
  end
  else
    result := 3;
end;

function TBaseSymbolTable.FindMaxMethodIndex(IntfId: Integer): Integer;
var
  I, temp: Integer;
  R: TSymbolRec;
begin
  result := -1;
  for I:= IntfId + 1 to Card do
  begin
    R := Records[I];

    if R = SR0 then
      break;
    if R.Kind = KindNAMESPACE then
      break;

    if R.Level = IntfId then
      if R.MethodIndex > 0 then
      begin
        temp := R.MethodIndex;
        if temp > result then
          result := temp
      end;
  end;

  if result = -1 then
    result := RestorePositiveIndex(IntfId);
end;

function TBaseSymbolTable.RegisterMethod(LevelId: Integer;
                                     const SubName: String; ResultTypeID: Integer;
                                     CallConvention: Integer;
                                     i_Address: Pointer;
                                     IsShared: Boolean = false;
                                     i_CallMode: Integer = cmNONE;
                                     i_MethodIndex: Integer = 0): Integer;
var
  SubID: Integer;
  PositiveIndex: Integer;
  NegativeIndex: Integer;
begin
  NegativeIndex := 0;

  if i_MethodIndex < 0 then
  begin
    NegativeIndex := i_MethodIndex;

    PositiveIndex := RestorePositiveIndex(LevelId);
    if PositiveIndex = -1 then
      RaiseError(errInternalError, []);
    i_MethodIndex := Abs(i_MethodIndex) + PositiveIndex;
  end;

  result := LastShiftValue;
  with AddRecord do
  begin
    Name := SubName;
    Count := 0;
    Kind := KindSUB;
    TypeID := ResultTypeID;
    Host := true;
    Shift := LastShiftValue;
    Level := LevelId;
    CallConv := CallConvention;
    IsSharedMethod := IsShared;

    if not (CallConvention in [ccSTDCALL, ccREGISTER, ccCDECL,
                               ccPASCAL, ccSAFECALL, ccMSFASTCALL]) then
    begin
      RaiseError(errInternalError, []);
      Exit;
    end;

    SubId := Id;

    Address := i_Address;
    CallMode := i_CallMode;
    MethodIndex := i_MethodIndex;
    NegativeMethodIndex := NegativeIndex;
  end;
  Inc(LastShiftValue, SizeOf(Pointer));

  with AddRecord do
  begin
    Kind := KindVAR;
    TypeID := ResultTypeID;

    Host := true;

    Shift := 0;
    Level := SubId;
  end;

  with AddRecord do
  begin
    Kind := KindNONE;
    Host := true;
    Shift := 0;
    Level := SubId;
  end;

  LastSubId := SubId;
end;

function TBaseSymbolTable.RegisterConstructor(LevelId: Integer;
                                          const SubName: String; i_Address: Pointer;
                                          i_CallMode: Integer = cmNONE): Integer;
var
  SubID: Integer;
begin
  result := LastShiftValue;
  with AddRecord do
  begin
    Name := SubName;
    Count := 0;
    Kind := KindCONSTRUCTOR;
    TypeID := LevelID;
    Host := true;
    Shift := LastShiftValue;
    Level := LevelId;
    CallConv := ccREGISTER;

    SubId := Id;

    Address := i_Address;
    CallMode := i_CallMode;
  end;
  Inc(LastShiftValue, SizeOf(Pointer));

  with AddRecord do
  begin
    Kind := KindVAR;
    TypeID := LevelID;
    Host := true;
    Shift := 0;
    Level := SubId;
  end;

  with AddRecord do
  begin
    Kind := KindNONE;
    Host := true;
    Shift := 0;
    Level := SubId;
  end;

  LastSubId := SubId;
end;

function TBaseSymbolTable.RegisterDestructor(LevelId: Integer;
                                             const SubName: String;
                                             i_Address: Pointer;
                                             i_CallMode: Integer = cmNONE): Integer;
var
  SubID: Integer;
begin
  result := LastShiftValue;
  with AddRecord do
  begin
    Name := SubName;
    Count := 0;
    Kind := KindDESTRUCTOR;
    TypeID := typeVOID;
    Host := true;
    Shift := LastShiftValue;
    Level := LevelId;
    CallConv := ccREGISTER;

    SubId := Id;

    Address := i_Address;
    CallMode := i_CallMode;
  end;

  Inc(LastShiftValue, SizeOf(Pointer));

  with AddRecord do
  begin
    Kind := KindVAR;
    TypeID := LevelID;
    Host := true;
    Shift := 0;
    Level := SubId;
  end;

  with AddRecord do
  begin
    Kind := KindNONE;
    Host := true;
    Shift := 0;
    Level := SubId;
  end;

  LastSubId := SubId;
end;

function TBaseSymbolTable.RegisterHeader(LevelId: Integer;
                               const Header: String; Address: Pointer;
                               MethodIndex: Integer = 0): Integer;
var
  TypeId, I, J, L, P, ElemTypeId, SubId, ReadId, WriteId, PropId: Integer;
  IsMethod: Boolean;
  ParamMod: TParamMod;
  S: String;
  Tag: Integer;
  OverList: TIntegerList;
  C: TClass;
  OpenArray: Boolean;
begin
  LastCard := Card;

  result := 0;

  HeaderParser.Init(Header, Self, LevelId);
  if not HeaderParser.Parse then
  begin
    if RaiseE then
      raise Exception.Create(errSyntaxError);

    REG_OK := false;
    Exit;
  end;

  IsMethod := (LevelId > 0) and (Records[LevelId].Kind = KindTYPE);

  if IsMethod then
    L := Records[LevelId].Level
  else
    L := LevelId;

  if HeaderParser.IsProperty then
  begin
    if HeaderParser.ReadIdent <> '' then
    begin
      ReadId := Lookup(HeaderParser.ReadIdent, LevelId, true);
      if ReadId > 0 then
      begin
        if Records[ReadId].Kind = KindTYPE_FIELD then
          ReadId := - ReadId
        else
          ReadId := Records[ReadId].Shift;
      end;
    end
    else
      ReadId := 0;

    if HeaderParser.WriteIdent <> '' then
    begin
      WriteId := Lookup(HeaderParser.WriteIdent, LevelId, true);
      if WriteId > 0 then
      begin
        if Records[WriteId].Kind = KindTYPE_FIELD then
          WriteId := - WriteId
        else
          WriteId := Records[WriteId].Shift;
      end;
    end
    else
      WriteId := 0;

    if HeaderParser.ResType = '' then
    begin
      PropId := Lookup(HeaderParser.Name, LevelId, true);

      if PropId = 0 then
        ExternList.Add(0,
                       Records[LevelId].FullName + '.' + HeaderParser.ResType,
                       ePropertyInBaseClassId);
      Exit;
    end;


    TypeId := LookupType(HeaderParser.ResType, L, true);

    if TypeId = 0 then
      ExternList.Add(Card + 1,
                     HeaderParser.ResType,
                     erTypeId);

    if (HeaderParser.ReadIdent <> '') and (ReadId = 0) then
      ExternList.Add(Card + 1,
                     Records[LevelId].FullName + '.' + HeaderParser.ReadIdent,
                     erReadId);

    if (HeaderParser.WriteIdent <> '') and (WriteId = 0) then
      ExternList.Add(Card + 1,
                     Records[LevelId].FullName + '.' + HeaderParser.WriteIdent,
                     erWriteId);

    RegisterProperty(LevelId, HeaderParser.Name,
         TypeId, ReadId, WriteId, HeaderParser.IsDefault);

    Exit;
  end;

  case HeaderParser.KS of
    ksPROCEDURE:
    begin
      if IsMethod then
      begin
        result := RegisterMethod(LevelId, HeaderParser.Name, TypeVOID, HeaderParser.CC,
                       Address, HeaderParser.IsShared,
                       HeaderParser.CallMode,
                       MethodIndex);
        if HeaderParser.IsFakeMethod then
          Self[LastSubId].IsFakeMethod := true;

        C := Records[LevelId].PClass;
        if C <> nil then
        begin
          MethodIndex := VirtualMethodIndex(PPointerArray(C), Address) + 1;
          if MethodIndex > 0 then
            Records[LastSubId].MethodIndex := MethodIndex
          else if HeaderParser.IsAbstract then
            Records[LastSubId].CallMode := cmNONE;
        end;
      end
      else
        result := RegisterRoutine(LevelId, HeaderParser.Name, TypeVOID, HeaderParser.CC,
                        Address);
    end;
    ksFUNCTION:
    begin
      TypeId := LookupType(HeaderParser.ResType, L, true);
      if TypeId = 0 then
      begin
        ExternList.Add(Card + 1,
                       HeaderParser.ResType,
                       erTypeId);
      end;
      if IsMethod then
      begin
        result := RegisterMethod(LevelId, HeaderParser.Name, TypeId, HeaderParser.CC,
                       Address, HeaderParser.IsShared,
                       HeaderParser.CallMode,
                       MethodIndex);
        if HeaderParser.IsFakeMethod then
          Self[LastSubId].IsFakeMethod := true;
        C := Records[LevelId].PClass;
        if C <> nil then
        begin
          MethodIndex := VirtualMethodIndex(PPointerArray(C), Address) + 1;
          if MethodIndex > 0 then
            Records[LastSubId].MethodIndex := MethodIndex
          else if HeaderParser.IsAbstract then
            Records[LastSubId].CallMode := cmNONE;
        end;
      end
      else
        result := RegisterRoutine(LevelId, HeaderParser.Name, TypeId, HeaderParser.CC,
                        Address);
    end;
    ksCONSTRUCTOR:
    begin
      result := RegisterConstructor(LevelId, HeaderParser.Name, Address, HeaderParser.CallMode);
      C := Records[LevelId].PClass;
      if C <> nil then
      begin
        MethodIndex := VirtualMethodIndex(PPointerArray(C), Address) + 1;
        if MethodIndex > 0 then
        begin
          Records[LastSubId].MethodIndex := MethodIndex;
        end;
      end;
    end;
    ksDESTRUCTOR:
    begin
      result := RegisterMethod(LevelId, HeaderParser.Name, TypeVOID,
                HeaderParser.CC, Address, false,
                HeaderParser.CallMode,
                0);
      Records[LastSubId].Kind := kindDESTRUCTOR;
    end;
  end;

  if HeaderParser.IsOverloaded then
  begin
    OverList := LookupAll(HeaderParser.Name, LevelId, true);
    Records[LastSubId].OverCount := OverList.Count;
    OverList.Free;
  end;

  for I:=1 to HeaderParser.NP do
  begin
    OpenArray := false;
    S := HeaderParser.Types[I];
    TypeId := LookupType(S, L, true);
    if TypeId = 0 then
    begin
      P := Pos('ARRAY OF ', S);
      if P = 1 then
      begin
        OpenArray := true;

        Delete(S, 1, 9);
        if StrEql(S, 'CONST') then
          ElemTypeId := H_TVarRec
        else
          ElemTypeId := LookupType(S, L, true);

        if ElemTypeId = 0 then
        begin
          ExternList.Add(Card + 1,
                         S,
                         erTypeId);
        end;

        SubId := -1;
        for J:=Card downto 1 do
          if Records[J].Shift = result then
          begin
            SubId := J;
            Break;
          end;

        if SubId = -1 then
        begin
          RaiseError(errInternalError, []);
          Exit;
        end;

        TypeId := RegisterDynamicArrayType(SubId, 'T' + S + 'Array', ElemTypeId);
      end
      else
      begin
        ExternList.Add(Card + 1,
                       S,
                       erTypeId);
      end;
    end;

    ParamMod := HeaderParser.Mods[I];

    Tag := 0;
    if HeaderParser.Optionals[I] then
      Tag := 1;

    if ParamMod = pmByRef then
      RegisterParameter(result, TypeId, HeaderParser.Values[I], true, HeaderParser.Params[I], Tag)
    else if ParamMod = pmConst then
    begin
      RegisterParameter(result, TypeId, HeaderParser.Values[I], false, HeaderParser.Params[I], Tag);
      Records[Card].IsConst := true;
    end
    else
      RegisterParameter(result, TypeId, HeaderParser.Values[I], false, HeaderParser.Params[I], Tag);
    if OpenArray then
      Records[Card].IsOpenArray := true;
  end;
end;

function TBaseSymbolTable.RegisterParameter(HSub: Integer; ParamTypeID: Integer;
                                        const DefaultValue: Variant;
                                        InitByRef: Boolean = false;
                                        ParameterName: String = '';
                                        Tag: Integer = 0): Integer;
var
  I, SubId: Integer;
begin
  result := LastShiftValue;

  SubId := -1;
  for I:=Card downto 1 do
    if Records[I].Shift = HSub then
    begin
      SubId := I;
      Break;
    end;

  if SubId = -1 then
  begin
    RaiseError(errInternalError, []);
    Exit;
  end;

  Inc(Records[SubId].Count);

  with AddRecord do
  begin
    Kind := KindVAR;
    TypeID := ParamTypeId;

    Host := true;
    Param := true;
    Shift := 0;
    Level := SubId;
    ByRef := InitByRef;
    Value := DefaultValue;
    Optional := VarType(Value) <> varEmpty;

    Name := ParameterName;

    if Tag = 1 then
      Optional := true;

    if InitByRef and Optional then
      RaiseError(errDefaultParameterMustBeByValueOrConst, [Name]);
  end;
end;

function TBaseSymbolTable.GetResultId(SubId: Integer): Integer;
begin
  result := SubId + 1;
end;

function TBaseSymbolTable.GetSelfId(SubId: Integer): Integer;
begin
  result := SubId + 2;
end;

function TBaseSymbolTable.GetParamId(SubId, ParamNumber: Integer): Integer;
var
  I, K: Integer;
  RI: TSymbolRec;
begin
  K := -1;
  for I:=SubId + 3 to Card do
  begin
    RI := Records[I];
    if RI.Param and (RI.Level = SubId) then
    begin
      Inc(K);
      if K = ParamNumber then
      begin
        result := I;
        Exit;
      end;
    end;
  end;
  result := -1;
  RaiseError(errInvalidIndex, [ParamNumber]);
end;

function TBaseSymbolTable.GetRecord(I: Integer): TSymbolRec;
begin
  result := TSymbolRec(A[I]);
end;

function TBaseSymbolTable.AddRecord: TSymbolRec;
begin
  Inc(Card);
  result := TSymbolRec.Create(Self);
  result.Id := Card;
  A.Add(result);
end;

function TBaseSymbolTable.CreateEmptySet: TSymbolRec;
var
  T: Integer;
begin
  T := RegisterSetType(0, '$$', typeVOID);

  result := AddRecord;
  result.Kind := kindCONST;
  result.TypeId := T;
  result.Value := 0;
  result.Level := 0;

  result.Shift := LastShiftValue;
  result.FinSize := 32;
  Inc(LastShiftValue, result.FinSize);
end;

function TBaseSymbolTable.AddIntegerConst(Value: Integer): TSymbolRec;
begin
  result := AddRecord;
  result.Kind := kindCONST;
  result.TypeId := typeINTEGER;
  result.Value := Value;
  result.Level := 0;
end;

function TBaseSymbolTable.AddCardinalConst(Value: Cardinal): TSymbolRec;
begin
  result := AddRecord;
  result.Kind := kindCONST;
  result.TypeId := typeCARDINAL;
{$IFDEF VARIANTS}
  result.Value := Value;
{$ELSE}
  result.Value := Integer(Value);
{$ENDIF}
  result.Level := 0;
end;

function TBaseSymbolTable.AddSmallIntConst(Value: SmallInt): TSymbolRec;
begin
  result := AddRecord;
  result.Kind := kindCONST;
  result.TypeId := typeSMALLINT;
  result.Value := Value;
  result.Level := 0;
end;

function TBaseSymbolTable.AddShortIntConst(Value: ShortInt): TSymbolRec;
begin
  result := AddRecord;
  result.Kind := kindCONST;
  result.TypeId := typeSHORTINT;
  result.Value := Value;
  result.Level := 0;
end;

{$IFDEF VARIANTS}
function TBaseSymbolTable.AddInt64Const(Value: Int64): TSymbolRec;
begin
  result := AddRecord;
  result.Kind := kindCONST;
  result.TypeId := typeINT64;
  result.Value := Value;
  result.Level := 0;

  result.Shift := LastShiftValue;
  result.FinSize := SizeOf(Int64);
  Inc(LastShiftValue, result.FinSize);
end;
{$ELSE}
function TBaseSymbolTable.AddInt64Const(Value: Int64): TSymbolRec;
begin
  result := AddRecord;
  result.Kind := kindCONST;
  result.TypeId := typeINT64;
  result.Value := Integer(Value);
  result.Level := 0;

  result.Shift := LastShiftValue;
  result.FinSize := SizeOf(Int64);
  Inc(LastShiftValue, result.FinSize);
end;
{$ENDIF}

function TBaseSymbolTable.AddEnumConst(TypeId, Value: Integer): TSymbolRec;
begin
  result := AddRecord;
  result.Kind := kindCONST;
  result.TypeId := TypeId;
  result.Value := Value;
  result.Level := 0;
end;

function TBaseSymbolTable.AddPointerConst(TypeId: Integer; Value: Pointer): TSymbolRec;
begin
  result := AddRecord;
  result.Kind := kindCONST;
  result.TypeId := TypeId;
{$IFDEF VARIANTS}
  result.Value := Cardinal(Value);
{$ELSE}
  result.Value := Integer(Value);
{$ENDIF}
  result.Level := 0;
end;

function TBaseSymbolTable.AddRecordConst(TypeId: Integer; const Value: Variant): TSymbolRec;
begin
  result := AddRecord;
  result.Kind := kindCONST;
  result.TypeId := TypeId;
  result.Value := Value;
  result.Level := 0;
end;

function TBaseSymbolTable.AddArrayConst(TypeId: Integer; const Value: Variant): TSymbolRec;
begin
  result := AddRecord;
  result.Kind := kindCONST;
  result.TypeId := TypeId;
  result.Value := Value;
  result.Level := 0;
end;

function TBaseSymbolTable.AddSetConst(TypeId: Integer; const Value: Variant): TSymbolRec;
begin
  result := AddRecord;
  result.Kind := kindCONST;
  result.TypeId := TypeId;
  result.Value := Value;
  result.Level := 0;

//  result.Shift := LastShiftValue;
//  Records[TypeId].Completed := true;
//  Inc(LastShiftValue, Records[result.Id].Size);
end;

function TBaseSymbolTable.AddClassConst(TypeId: Integer; Value: TObject): TSymbolRec;
begin
  result := AddRecord;
  result.Kind := kindCONST;
  result.TypeId := TypeId;
  result.Value := Integer(Value);
  result.Level := 0;
  result.MustBeAllocated := true;
end;

function TBaseSymbolTable.AddClassRefConst(TypeId: Integer; Value: TClass): TSymbolRec;
begin
  result := AddRecord;
  result.Kind := kindCONST;
  result.TypeId := TypeId;
  result.Value := Integer(Value);
  result.Level := 0;
  result.MustBeAllocated := true;
end;

function TBaseSymbolTable.AddSetVar(TypeId: Integer; const Value: Variant): TSymbolRec;
begin
  result := AddRecord;
  result.Kind := kindVAR;
  result.TypeId := TypeId;
  result.Value := Value;
  result.Level := 0;

//  result.Shift := LastShiftValue;
//  Records[TypeId].Completed := true;
//  Inc(LastShiftValue, Records[result.Id].Size);
end;

function TBaseSymbolTable.AddAnsiCharConst(Value: AnsiChar): TSymbolRec;
begin
  result := AddRecord;
  result.Kind := kindCONST;
  result.TypeId := typeANSICHAR;
  result.Value := Ord(Value);
  result.Level := 0;
end;

function TBaseSymbolTable.AddWideCharConst(Value: Integer): TSymbolRec;
begin
  result := AddRecord;
  result.Kind := kindCONST;
  result.TypeId := typeWIDECHAR;
  result.Value := Value;
  result.Level := 0;
end;

function TBaseSymbolTable.AddPAnsiCharConst(const Value: AnsiString): TSymbolRec;
var
  SZ: Integer;
begin
  result := AddRecord;
  result.Kind := kindCONST;
  result.TypeId := typePANSICHAR;
  result.Value := Value;
  result.Level := 0;

  SZ := 0;
  Inc(SZ, SizeOf(Pointer)); // pointer to string literal
  Inc(SZ, SizeOf(Pointer)); // ref counter
  Inc(SZ, SizeOf(Pointer)); // length
  // reserve place for literal
  Inc(SZ, Length(Value) + 1);

  result.Shift := LastShiftValue;
  Inc(LastShiftValue, SZ);
end;

function TBaseSymbolTable.AddShortStringConst(const Value: String): TSymbolRec;
begin
  result := AddRecord;
  result.Kind := kindCONST;
  result.TypeId := typeSHORTSTRING;
  result.Value := Value;
  result.Level := 0;
end;

function TBaseSymbolTable.AddPWideCharConst(const Value: WideString): TSymbolRec;
var
  SZ: Integer;
begin
  result := AddRecord;
  result.Kind := kindCONST;
  result.TypeId := typePWIDECHAR;
  result.Value := Value;
  result.Level := 0;

  SZ := 0;
  Inc(SZ, SizeOf(Pointer)); // pointer to string literal
  Inc(SZ, SizeOf(Pointer)); // length

  // reserve place for literal
  Inc(SZ, Length(Value) * 2 + 1);

  result.Shift := LastShiftValue;
  Inc(LastShiftValue, SZ);
end;

function TBaseSymbolTable.AddByteConst(Value: Byte): TSymbolRec;
begin
  result := AddRecord;
  result.Kind := kindCONST;
  result.TypeId := typeBYTE;
  result.Value := Ord(Value);
  result.Level := 0;
end;

function TBaseSymbolTable.AddWordConst(Value: Word): TSymbolRec;
begin
  result := AddRecord;
  result.Kind := kindCONST;
  result.TypeId := typeWORD;
  result.Value := Ord(Value);
  result.Level := 0;
end;

function TBaseSymbolTable.AddBooleanConst(Value: Boolean): TSymbolRec;
begin
  result := AddRecord;
  result.Kind := kindCONST;
  result.TypeId := typeBOOLEAN;
  result.Value := Abs(Integer(Value));
  result.Level := 0;
end;

function TBaseSymbolTable.AddByteBoolConst(Value: Boolean): TSymbolRec;
begin
  result := AddRecord;
  result.Kind := kindCONST;
  result.TypeId := typeBYTEBOOL;
  result.Value := Abs(Integer(Value));
  result.Level := 0;
end;

function TBaseSymbolTable.AddWordBoolConst(Value: Boolean): TSymbolRec;
begin
  result := AddRecord;
  result.Kind := kindCONST;
  result.TypeId := typeWORDBOOL;
  result.Value := Abs(Integer(Value));
  result.Level := 0;
end;

function TBaseSymbolTable.AddLongBoolConst(Value: Boolean): TSymbolRec;
begin
  result := AddRecord;
  result.Kind := kindCONST;
  result.TypeId := typeLONGBOOL;
  result.Value := Abs(Integer(Value));
  result.Level := 0;
end;

function TBaseSymbolTable.AddDoubleConst(Value: Double): TSymbolRec;
begin
  result := AddRecord;
  result.Kind := kindCONST;
  result.TypeId := typeDOUBLE;
  result.Value := Value;
  result.Level := 0;

  result.Shift := LastShiftValue;
  result.FinSize := SizeOf(Double);
  Inc(LastShiftValue, result.FinSize);
end;

function TBaseSymbolTable.AddCurrencyConst(Value: Currency): TSymbolRec;
begin
  result := AddRecord;
  result.Kind := kindCONST;
  result.TypeId := typeCURRENCY;
  result.Value := Value;
  result.Level := 0;

  result.Shift := LastShiftValue;
  result.FinSize := SizeOf(Currency);
  Inc(LastShiftValue, result.FinSize);
end;

function TBaseSymbolTable.AddSingleConst(Value: Single): TSymbolRec;
begin
  result := AddRecord;
  result.Kind := kindCONST;
  result.TypeId := typeSINGLE;
  result.Value := Value;
  result.Level := 0;

  result.Shift := LastShiftValue;
  result.FinSize := SizeOf(Single);
  Inc(LastShiftValue, result.FinSize);
end;

function TBaseSymbolTable.AddExtendedConst(Value: Extended): TSymbolRec;
begin
  result := AddRecord;
  result.Kind := kindCONST;
  result.TypeId := typeEXTENDED;
  result.Value := Value;
  result.Level := 0;

  result.Shift := LastShiftValue;
  result.FinSize := SizeOf(Extended);
  Inc(LastShiftValue, result.FinSize);
end;

function TBaseSymbolTable.AddVariantConst(const Value: Variant): TSymbolRec;
begin
  result := AddRecord;
  result.Kind := kindCONST;
  result.TypeId := typeVARIANT;
  result.SetVariantValue(Value);
  result.Level := 0;

  result.Shift := LastShiftValue;
  result.FinSize := SizeOf(Variant);
  Inc(LastShiftValue, result.FinSize);
end;

function TBaseSymbolTable.AddOleVariantConst(const Value: OleVariant): TSymbolRec;
begin
  result := AddRecord;
  result.Kind := kindCONST;
  result.TypeId := typeOLEVARIANT;
  result.SetVariantValue(Value);
  result.Level := 0;

  result.Shift := LastShiftValue;
  result.FinSize := SizeOf(OleVariant);
  Inc(LastShiftValue, result.FinSize);
end;

function TBaseSymbolTable.AddTMethodVar(Level: Integer): TSymbolRec;
begin
  result := AddRecord;
  result.Kind := kindVAR;
  result.TypeId := H_TMethod;
  result.Value := 0.0;
  result.Level := Level;

  result.Shift := LastShiftValue;
  result.FinSize := SizeOf(TMethod);
  Inc(LastShiftValue, result.FinSize);
end;

function TBaseSymbolTable.AddDoubleVar(Level: Integer): TSymbolRec;
begin
  result := AddRecord;
  result.Kind := kindVAR;
  result.TypeId := typeDOUBLE;
  result.Value := 0.0;
  result.Level := Level;

  result.Shift := LastShiftValue;
  result.FinSize := SizeOf(Double);
  Inc(LastShiftValue, result.FinSize);
end;

function TBaseSymbolTable.AddCurrencyVar(Level: Integer): TSymbolRec;
begin
  result := AddRecord;
  result.Kind := kindVAR;
  result.TypeId := typeCURRENCY;
  result.Value := 0.0;
  result.Level := Level;

  result.Shift := LastShiftValue;
  result.FinSize := SizeOf(Currency);
  Inc(LastShiftValue, result.FinSize);
end;

function TBaseSymbolTable.AddSingleVar(Level: Integer): TSymbolRec;
begin
  result := AddRecord;
  result.Kind := kindVAR;
  result.TypeId := typeSINGLE;
  result.Value := 0.0;
  result.Level := Level;

  result.Shift := LastShiftValue;
  result.FinSize := SizeOf(Single);
  Inc(LastShiftValue, result.FinSize);
end;

function TBaseSymbolTable.AddExtendedVar(Level: Integer): TSymbolRec;
begin
  result := AddRecord;
  result.Kind := kindVAR;
  result.TypeId := typeEXTENDED;
  result.Value := 0.0;
  result.Level := Level;

  result.Shift := LastShiftValue;
  result.FinSize := SizeOf(Extended);
  Inc(LastShiftValue, result.FinSize);
end;

function TBaseSymbolTable.AddInt64Var(Level: Integer): TSymbolRec;
begin
  result := AddRecord;
  result.Kind := kindVAR;
  result.TypeId := typeINT64;
  result.Value := 0;
  result.Level := Level;

  result.Shift := LastShiftValue;
  result.FinSize := SizeOf(Int64);
  Inc(LastShiftValue, result.FinSize);
end;

function TBaseSymbolTable.AddStringVar(Level: Integer): TSymbolRec;
begin
  result := AddRecord;
  result.Kind := kindVAR;
  result.TypeId := typeANSISTRING;
  result.Value := '';
  result.Level := Level;
  result.Name := '@';

  result.Shift := LastShiftValue;
  result.FinSize := SizeOf(String);
  Inc(LastShiftValue, result.FinSize);
end;

function TBaseSymbolTable.AddInterfaceVar(Level: Integer): TSymbolRec;
begin
  result := AddRecord;
  result.Kind := kindVAR;
  result.TypeId := H_IUnknown;
  result.Level := Level;
  result.Name := '@';

  result.Shift := LastShiftValue;
  result.FinSize := SizeOf(IUnknown);
  Inc(LastShiftValue, result.FinSize);
end;

function TBaseSymbolTable.AddClassVar(Level: Integer): TSymbolRec;
begin
  result := AddRecord;
  result.Kind := kindVAR;
  result.TypeId := typeCLASS;
  result.Level := Level;
  result.Name := '@';

  result.Shift := LastShiftValue;
  result.FinSize := SizeOf(Pointer);
  Inc(LastShiftValue, result.FinSize);
end;

function TBaseSymbolTable.AddWideStringVar(Level: Integer): TSymbolRec;
begin
  result := AddRecord;
  result.Kind := kindVAR;
  result.TypeId := typeWIDESTRING;
  result.Value := '';
  result.Level := Level;
  result.Name := '@';

  result.Shift := LastShiftValue;
  result.FinSize := SizeOf(WideString);
  Inc(LastShiftValue, result.FinSize);
end;

function TBaseSymbolTable.AddUnicStringVar(Level: Integer): TSymbolRec;
begin
  result := AddRecord;
  result.Kind := kindVAR;
  result.TypeId := typeUNICSTRING;
  result.Value := '';
  result.Level := Level;
  result.Name := '@';

  result.Shift := LastShiftValue;
  result.FinSize := SizeOf(UnicString);
  Inc(LastShiftValue, result.FinSize);
end;

function TBaseSymbolTable.AddVariantVar(Level: Integer): TSymbolRec;
begin
  result := AddRecord;
  result.Kind := kindVAR;
  result.TypeId := typeVARIANT;
  result.Value := '';
  result.Level := Level;
  result.Name := '@';

  result.Shift := LastShiftValue;
  result.FinSize := SizeOf(Variant);
  Inc(LastShiftValue, result.FinSize);
end;

function TBaseSymbolTable.AddOleVariantVar(Level: Integer): TSymbolRec;
begin
  result := AddRecord;
  result.Kind := kindVAR;
  result.TypeId := typeOLEVARIANT;
  result.Value := '';
  result.Level := Level;
  result.Name := '@';

  result.Shift := LastShiftValue;
  result.FinSize := SizeOf(OleVariant);
  Inc(LastShiftValue, result.FinSize);
end;

function TBaseSymbolTable.AddShortStringVar(Level, TypeId: Integer): TSymbolRec;
begin
  result := AddRecord;
  result.Kind := kindVAR;
  result.TypeId := TypeId;
  result.Value := '';
  result.Level := Level;
end;

function TBaseSymbolTable.AddDynarrayVar(Level, TypeId: Integer): TSymbolRec;
begin
  result := AddRecord;
  result.Kind := kindVAR;
  result.TypeId := TypeId;
  result.Level := Level;

  result.Shift := LastShiftValue;
  result.FinSize := SizeOf(Pointer);
  Inc(LastShiftValue, result.FinSize);
end;

function TBaseSymbolTable.AddIntegerVar(Level: Integer): TSymbolRec;
begin
  result := AddRecord;
  result.Kind := kindVAR;
  result.TypeId := typeINTEGER;
  result.Value := 0;
  result.Level := Level;

  result.Shift := LastShiftValue;
  result.FinSize := SizeOf(Integer);
  Inc(LastShiftValue, result.FinSize);
end;

function TBaseSymbolTable.AddCardinalVar(Level: Integer): TSymbolRec;
begin
  result := AddRecord;
  result.Kind := kindVAR;
  result.TypeId := typeCARDINAL;
  result.Value := 0;
  result.Level := Level;

  result.Shift := LastShiftValue;
  result.FinSize := SizeOf(Cardinal);
  Inc(LastShiftValue, result.FinSize);
end;

function TBaseSymbolTable.AddSmallIntVar(Level: Integer): TSymbolRec;
begin
  result := AddRecord;
  result.Kind := kindVAR;
  result.TypeId := typeSMALLINT;
  result.Value := 0;
  result.Level := Level;

  result.Shift := LastShiftValue;
  result.FinSize := SizeOf(SmallInt);
  Inc(LastShiftValue, result.FinSize);
end;

function TBaseSymbolTable.AddShortIntVar(Level: Integer): TSymbolRec;
begin
  result := AddRecord;
  result.Kind := kindVAR;
  result.TypeId := typeSHORTINT;
  result.Value := 0;
  result.Level := Level;

  result.Shift := LastShiftValue;
  result.FinSize := SizeOf(ShortInt);
  Inc(LastShiftValue, result.FinSize);
end;

function TBaseSymbolTable.AddByteVar(Level: Integer): TSymbolRec;
begin
  result := AddRecord;
  result.Kind := kindVAR;
  result.TypeId := typeBYTE;
  result.Value := 0;
  result.Level := Level;

  result.Shift := LastShiftValue;
  result.FinSize := SizeOf(Byte);
  Inc(LastShiftValue, result.FinSize);
end;

function TBaseSymbolTable.AddWordVar(Level: Integer): TSymbolRec;
begin
  result := AddRecord;
  result.Kind := kindVAR;
  result.TypeId := typeWORD;
  result.Value := 0;
  result.Level := Level;

  result.Shift := LastShiftValue;
  result.FinSize := SizeOf(Word);
  Inc(LastShiftValue, result.FinSize);
end;

function TBaseSymbolTable.AddBooleanVar(Level: Integer): TSymbolRec;
begin
  result := AddRecord;
  result.Kind := kindVAR;
  result.TypeId := typeBOOLEAN;
  result.Value := 0;
  result.Level := Level;

  result.Shift := LastShiftValue;
  result.FinSize := SizeOf(Boolean);
  Inc(LastShiftValue, result.FinSize);
end;

function TBaseSymbolTable.AddByteBoolVar(Level: Integer): TSymbolRec;
begin
  result := AddRecord;
  result.Kind := kindVAR;
  result.TypeId := typeBYTEBOOL;
  result.Value := 0;
  result.Level := Level;

  result.Shift := LastShiftValue;
  result.FinSize := SizeOf(ByteBool);
  Inc(LastShiftValue, result.FinSize);
end;

function TBaseSymbolTable.AddWordBoolVar(Level: Integer): TSymbolRec;
begin
  result := AddRecord;
  result.Kind := kindVAR;
  result.TypeId := typeWORDBOOL;
  result.Value := 0;
  result.Level := Level;

  result.Shift := LastShiftValue;
  result.FinSize := SizeOf(WordBool);
  Inc(LastShiftValue, result.FinSize);
end;

function TBaseSymbolTable.AddLongBoolVar(Level: Integer): TSymbolRec;
begin
  result := AddRecord;
  result.Kind := kindVAR;
  result.TypeId := typeLONGBOOL;
  result.Value := 0;
  result.Level := Level;

  result.Shift := LastShiftValue;
  result.FinSize := SizeOf(LongBool);
  Inc(LastShiftValue, result.FinSize);
end;

function TBaseSymbolTable.AddPointerVar(Level: Integer): TSymbolRec;
begin
  result := AddRecord;
  result.Kind := kindVAR;
  result.TypeId := typePOINTER;
  result.Level := Level;

  result.Shift := LastShiftValue;
  result.FinSize := SizeOf(Pointer);
  Inc(LastShiftValue, result.FinSize);
end;

function TBaseSymbolTable.AddVoidVar(Level: Integer; SZ: Integer): TSymbolRec;
begin
  result := AddRecord;
  result.Kind := kindVAR;
  result.TypeId := typeVOID;
  result.Level := Level;

  result.Shift := LastShiftValue;
  result.FinSize := SZ;
  Inc(LastShiftValue, result.FinSize);
end;

function TBaseSymbolTable.AddClassRefVar(Level: Integer): TSymbolRec;
begin
  result := AddRecord;
  result.Kind := kindVAR;
  result.TypeId := typeCLASSREF;
  result.Value := 0;
  result.Level := Level;

  result.Shift := LastShiftValue;
  result.FinSize := SizeOf(Pointer);
  Inc(LastShiftValue, result.FinSize);
end;

function TBaseSymbolTable.AddLabel: TSymbolRec;
begin
  result := AddRecord;
  result.Kind := kindLABEL;
  result.Level := 0;
end;

function TBaseSymbolTable.AddPointerType(SourceTypeId: Integer): TSymbolRec;
begin
  result := AddRecord;
  result.Kind := kindTYPE;
  result.TypeId := typePOINTER;
  result.Level := Records[SourceTypeId].Level;
  result.PatternId := SourceTypeId;
end;

function TBaseSymbolTable.AddEndOfClassHeader(ClassId: Integer): TSymbolRec;
begin
  result := AddRecord;
  result.Name := '*' + Records[ClassId].Name;
  result.Kind := kindEND_CLASS_HEADER;
  result.Level := ClassId;
end;

function TBaseSymbolTable.LookupNamespace(const S: String;
                                          i_Level: Integer; UpCase: Boolean): Integer;
var
  I, J: Integer;
  ok: Boolean;
  List: TIntegerList;
begin
  List := HashArray.GetList(S);

  result := 0;
  for J := List.Count - 1 downto 0 do
  begin
    I := List[J];
    with Records[I] do
    if (Kind = KindNAMESPACE) and (Level = i_Level) then
    begin
      if UpCase then
        ok := StrEql(Name, S)
      else
        ok := Name = S;
      if ok then
      begin
        result := I;
        Exit;
      end;
    end;
  end;

  if Self <> GlobalSymbolTable then
    result := GlobalSymbolTable.LookupNamespace(S, i_Level, Upcase);
end;

function TBaseSymbolTable.LookupFullName(const S: String; UpCase: Boolean): Integer;
var
  I, J: Integer;
  ok: Boolean;
  RI: TSymbolRec;
  List: TIntegerList;
begin
  List := HashArray.GetList(ExtractName(S));

  result := 0;
  for J := List.Count - 1 downto 0 do
  begin
    I := List[J];
    RI := Records[I];
    begin
      if UpCase then
        ok := StrEql(RI.FullName, S)
      else
        ok := RI.FullName = S;
      if ok then
      begin
        result := I;
        Exit;
      end;
    end;
  end;

  if Self <> GlobalSymbolTable then
    result := GlobalSymbolTable.LookupFullName(S, Upcase);
end;

function TBaseSymbolTable.LookupFullNameEx(const S: String; UpCase: Boolean;
                                           OverCount: Integer): Integer;
var
  I, J: Integer;
  ok: Boolean;
  RI: TSymbolRec;
  List: TIntegerList;
begin
  if OverCount = 0 then
  begin
    result := LookupFullName(S, Upcase);
    Exit;
  end;

  List := HashArray.GetList(ExtractName(S));

  result := 0;
  for J := List.Count - 1 downto 0 do
  begin
    I := List[J];
    RI := Records[I];
    begin
      if UpCase then
        ok := StrEql(RI.FullName, S)
      else
        ok := RI.FullName = S;
      if ok then
      if RI.OverCount = OverCount then
      begin
        result := I;
        Exit;
      end;
    end;
  end;

  if Self <> GlobalSymbolTable then
    result := GlobalSymbolTable.LookupFullNameEx(S, Upcase, OverCount);
end;

function TBaseSymbolTable.LookUpType(const S: String;
    i_Level: Integer; UpCase: Boolean): Integer;
var
  I, J: Integer;
  ok: Boolean;
  List: TIntegerList;
begin
  result := Types.IndexOf(S);
  if result > 0 then
    Exit;

  List := HashArray.GetList(S);

  result := 0;

  for J := List.Count - 1 downto 0 do
  begin
    I := List[J];
    with Records[I] do
    if (Kind = KindTYPE) and (Level = i_Level) then
    begin
      if UpCase then
        ok := StrEql(Name, S)
      else
        ok := Name = S;
      if ok then
      begin
        result := I;
        Exit;
      end;
    end;
  end;

  for J := List.Count - 1 downto 0 do
  begin
    I := List[J];
    with Records[I] do
    if Kind = KindTYPE then
    begin
      if UpCase then
        ok := StrEql(Name, S)
      else
        ok := Name = S;
      if ok then
      begin
        result := I;
        Exit;
      end;
    end;
  end;

  if Self <> GlobalSymbolTable then
    result := GlobalSymbolTable.LookUpType(S, i_Level, Upcase);
end;

function TBaseSymbolTable.LookUpType(const S: String; UpCase: Boolean): Integer;
var
  I, J: Integer;
  ok: Boolean;
  List: TIntegerList;
begin
  result := Types.IndexOf(S);
  if result > 0 then
    Exit;

  List := HashArray.GetList(S);

  result := 0;

  for J := List.Count - 1 downto 0 do
  begin
    I := List[J];
    with Records[I] do
    if Kind = KindTYPE then
    begin
      if UpCase then
        ok := StrEql(Name, S)
      else
        ok := Name = S;
      if ok then
      begin
        result := I;
        Exit;
      end;
    end;
  end;

  if Self <> GlobalSymbolTable then
    result := GlobalSymbolTable.LookUpType(S, Upcase);
end;

function TBaseSymbolTable.LookUpTypeEx(const S: String;
    i_Level: Integer; UpCase: Boolean; LowBound: Integer): Integer;
var
  I, J: Integer;
  ok: Boolean;
  List: TIntegerList;
begin
  result := Types.IndexOf(S);
  if result > 0 then
    if result >= LowBound then
    Exit;

  List := HashArray.GetList(S);

  result := 0;

  for J := List.Count - 1 downto 0 do
  begin
    I := List[J];
    if I < LowBound then
      continue;

    with Records[I] do
    if (Kind = KindTYPE) and (Level = i_Level) then
    begin
      if UpCase then
        ok := StrEql(Name, S)
      else
        ok := Name = S;
      if ok then
      begin
        result := I;
        Exit;
      end;
    end;
  end;

  for J:=List.Count - 1 downto 0 do
  begin
    I := List[J];

    if I < LowBound then
      continue;

    with Records[I] do
    if Kind = KindTYPE then
    begin
      if UpCase then
        ok := StrEql(Name, S)
      else
        ok := Name = S;
      if ok then
      begin
        result := I;
        Exit;
      end;
    end;
  end;

  if Self <> GlobalSymbolTable then
    result := GlobalSymbolTable.LookUpTypeEx(S, i_Level, Upcase, LowBound);
end;

function TBaseSymbolTable.LookupParentMethodBase(SubId: Integer; UpCase: Boolean): Integer;
var
  I, J, Level, TempLevel: Integer;
  ok: Boolean;
  List: TIntegerList;
  R: TSymbolRec;
  Name, Signature: String;
begin
  Name := Records[SubId].Name;
  Signature := Records[SubId].SignatureBrief;
  Level := Records[SubId].Level;

  List := HashArray.GetList(Name);

  result := 0;

  for J:=List.Count - 1 downto 0 do
  begin
    I := List[J];
    R := Records[I];
    if R.Kind in KindSUBS then
    begin
      TempLevel := R.Level;

      if TempLevel = 0 then
        continue;
      if Level = TempLevel then
        continue;
      if Records[TempLevel].ClassIndex = -1 then
        continue;
      if not Inherits(Level, TempLevel) then
        continue;

      if UpCase then
        ok := StrEql(R.Name, Name)
      else
        ok := R.Name = Name;
      if ok then
      begin

        if UpCase then
          ok := StrEql(R.SignatureBrief, Signature)
        else
          ok := R.SignatureBrief = Signature;

        if ok then
        begin
          result := I;
          Exit;
        end;
      end;
    end;
  end;
end;

function TBaseSymbolTable.LookupParentMethod(SubId: Integer; UpCase: Boolean): Integer;
var
  I, J, Level: Integer;
  ok: Boolean;
  List: TIntegerList;
  R: TSymbolRec;
  Name, Signature: String;
  C, CA: TClass;
label
  Again;
begin
  Name := Records[SubId].Name;
  Signature := Records[SubId].SignatureBrief;

  List := HashArray.GetList(Name);
  C := Records[Records[SubId].Level].PClass;

  result := 0;
  Level := Records[SubId].Level;

Again:

  if C = nil then
    Exit;

  for J:=List.Count - 1 downto 0 do
  begin
    I := List[J];
    R := Records[I];
    if R.Kind in KindSUBS then
    begin
      CA := Records[Records[I].Level].PClass;

      if CA = nil then
        continue;

      if C = CA then
        continue;

      if not C.InheritsFrom(CA) then
        continue;

      if UpCase then
        ok := StrEql(R.Name, Name)
      else
        ok := R.Name = Name;
      if ok then
      begin

        if UpCase then
          ok := StrEql(R.SignatureBrief, Signature)
        else
          ok := R.SignatureBrief = Signature;

        if ok then
        begin
          result := I;
          Exit;
        end;
      end;
    end;
  end;

  if Level > 0 then
    if Records[Level].AncestorId > 0 then
    begin
      Level := Records[Level].AncestorId;
      C := Records[Level].PClass;
      goto Again;
    end;
end;

function TBaseSymbolTable.LookUpEnumItem(const S: String; EnumTypeId: Integer;
                          UpCase: Boolean): Integer;
var
  I: Integer;
  R: TSymbolRec;
  ok: Boolean;
begin
  result := 0;

  for I:=EnumTypeId + 1 to Card do
  begin
    R := Records[I];

    if R = SR0 then
     Exit;

    if R.Kind = KindCONST then
    if R.OwnerId = EnumTypeId then
    begin
     if UpCase then
        ok := StrEql(R.Name, S)
      else
        ok := R.Name = S;
      if ok then
      begin
        result := I;
        Exit;
      end;
    end;
  end;
end;

function TBaseSymbolTable.LookUp(const S: String; Level: Integer; UpCase: Boolean;
        UpperBoundId: Integer = MaxInt): Integer;
var
  I, J: Integer;
  Ok: Boolean;
  InterfaceTypeId: Integer;
  R: TSymbolRec;
  List: TIntegerList;
begin
  List := HashArray.GetList(S);

  result := 0;

  for J:=List.Count - 1 downto 0 do
  begin
    I := List[J];
    R := Records[I];

    if I < UpperBoundId then
    if (R.Level = Level) and (not R.InternalField) then
    if R.Kind <> KindNONE then
    begin
     if UpCase then
        ok := StrEql(R.Name, S)
      else
        ok := R.Name = S;
      if ok then
      begin
        result := I;
        Exit;
      end;
    end;
  end;

  if Level > 0 then
  begin
    if Records[Level].AncestorId > 0 then
    begin
      result := LookUp(S, Records[Level].AncestorId, Upcase);
      if result > 0 then
        Exit;
    end;
  end;

  if Assigned(Records[Level].SupportedInterfaces) then
  begin
    for I := 0 to Records[Level].SupportedInterfaces.Count - 1 do
    begin
      InterfaceTypeId := Records[Level].SupportedInterfaces[I].Id;
      result := LookUp(S, InterfaceTypeId, Upcase);
      if result > 0 then
        Exit;
    end;
  end;

  if result = 0 then
    if Self <> GlobalSymbolTable then
      if Level <= GlobalSymbolTable.Card then
        result := GlobalSymbolTable.LookUp(S, Level, Upcase, UpperBoundId);
end;

function TBaseSymbolTable.LookUpAll(const S: String; Level: Integer; UpCase: Boolean): TIntegerList;
var
  I, J: Integer;
  Ok: Boolean;
  R: TSymbolRec;
  List: TIntegerList;
begin
  List := HashArray.GetList(S);

  result := TIntegerList.Create;
  for J:=List.Count - 1 downto 0 do
  begin
    I := List[J];

    R := Records[I];

    if (R.Level = Level) and (not R.InternalField) then
    if R.Kind <> KindNONE then
    begin
      if UpCase then
        ok := StrEql(R.Name, S)
      else
        ok := R.Name = S;
      if ok then
        result.Insert(0, I);
    end;
  end;
end;

function TBaseSymbolTable.LookUpSub(const S: String; Level: Integer; UpCase: Boolean): TIntegerList;

  function HasAtLevel(const S: String; Level: Integer; UpCase: Boolean): Boolean;
  var
    I, J: Integer;
    Ok: Boolean;
    R: TSymbolRec;
    List: TIntegerList;
  begin
    List := HashArray.GetList(S);

    result := false;

    for J:=List.Count - 1 downto 0 do
    begin
      I := List[J];
      R := Records[I];
      if (R.Level = Level) and (R.Kind in kindSUBS) then
      begin
        if UpCase then
          ok := StrEql(R.Name, S)
        else
          ok := R.Name = S;
        if ok then
          begin
            result := true;
            Exit;
          end;
      end;
    end;
  end;

  procedure DoIt(const S: String; Level: Integer; UpCase: Boolean; Fin: Boolean = false);
  var
    I, J: Integer;
    Ok: Boolean;
    R: TSymbolRec;
    List: TIntegerList;
//    HasVirtual: Boolean;
  begin
    List := HashArray.GetList(S);

//    HasVirtual := false;

    for J:=List.Count - 1 downto 0 do
    begin
      I := List[J];

      R := Records[I];

      if (R.Level = Level) and (R.Kind in KindSUBS) then
      begin
        if UpCase then
          ok := StrEql(R.Name, S)
        else
          ok := R.Name = S;
        if ok then
        begin
          result.Insert(0, I);
//          if R.IsVirtual then
//            HasVirtual := true;
        end;
      end;
    end;

//    if not HasVirtual then
//      Exit;

    if Fin then
      Exit;

    Level := Records[Level].AncestorId;
    while not ((Level = 0) or (Level = H_TObject)) do
    begin
      if HasAtLevel(S, Level, Upcase) then
      begin
        DoIt(S, Level, upcase, true);
        Exit;
      end;
      Level := Records[Level].AncestorId;
    end;
  end;

begin
  result := TIntegerList.Create;
  DoIt(S, Level, Upcase);
end;

function TBaseSymbolTable.LookUps(const S: String; LevelStack: TIntegerStack;
                                  UpCase: Boolean;
                                  UpperBoundId: Integer = MaxInt): Integer;
var
  I, R: Integer;
begin
  for I:=LevelStack.Count - 1 downto 0 do
  begin
    R := LookUp(S, LevelStack[I], upcase, UpperBoundId);
    if R > 0 then
    begin
      result := R;
      Exit;
    end;
  end;
  result := 0;
end;

function TBaseSymbolTable.LookUpsEx(const S: String; LevelStack: TIntegerStack; var LevelId: Integer; UpCase: Boolean): Integer;
var
  I, R: Integer;
begin
  for I:=LevelStack.Count - 1 downto 0 do
  begin
    R := LookUp(S, LevelStack[I], upcase, MaxInt);
    if R > 0 then
    begin
      result := R;
      LevelId := LevelStack[I];
      Exit;
    end;
  end;
  result := 0;
end;

function TBaseSymbolTable.LookUpsExcept(const S: String; LevelStack: TIntegerStack; LevelId: Integer; UpCase: Boolean): Integer;
var
  I, R: Integer;
begin
  for I:=LevelStack.Count - 1 downto 0 do
  begin
    if LevelId = LevelStack[I] then
      continue;

    R := LookUp(S, LevelStack[I], upcase, MaxInt);
    if R > 0 then
    begin
      result := R;
      Exit;
    end;
  end;
  result := 0;
end;

function TBaseSymbolTable.LookupAnotherDeclaration(Id: Integer; UpCase: Boolean;
                                                   var BestID: Integer): Integer;
var
  I, J, Level: Integer;
  Name, SignatureEx: String;
  Ok: Boolean;
  RI: TSymbolRec;
  List: TIntegerList;
begin
  Level := Records[Id].Level;
  Name := Records[Id].Name;
  SignatureEx := Records[Id].SignatureEx;

  BestId := 0;

  List := HashArray.GetList(Name);

  for J := List.Count - 1 downto 0 do
  begin
    I := List[J];

    if I = Id then
      continue;

    RI := Records[I];
    if (RI.Level = Level) and
       (RI.Kind in kindSUBS) then
    begin
      if UpCase then
        ok := StrEql(RI.Name, Name)
      else
        ok := (RI.Name = Name);

      if ok then
      begin
        BestId := I;

        if UpCase then
          ok := StrEql(RI.SignatureEx, SignatureEx)
        else
          ok := RI.SignatureEx = SignatureEx;
      end;

      if ok then
      begin
        result := I;
        Exit;
      end;
    end;
  end;

  result := 0;
end;

function TBaseSymbolTable.LookupForwardDeclaration(Id: Integer; UpCase: Boolean;
                                                   var BestID: Integer): Integer;
var
  I, J, Level: Integer;
  Name, SignatureEx: String;
  Ok: Boolean;
  RI: TSymbolRec;
  List: TIntegerList;
begin
  Level := Records[Id].Level;
  Name := Records[Id].Name;
  SignatureEx := Records[Id].SignatureEx;

  BestId := 0;

  List := HashArray.GetList(Name);

  for J := List.Count - 1 downto 0 do
  begin
    I := List[J];
    RI := Records[I];
    if RI.IsForward and (RI.Level = Level) and
      (RI.Kind in kindSUBS) then
    begin
      if UpCase then
        ok := StrEql(RI.Name, Name)
      else
        ok := (RI.Name = Name);

      if ok then
      begin
        BestId := I;

        if UpCase then
          ok := StrEql(RI.SignatureEx, SignatureEx)
        else
          ok := RI.SignatureEx = SignatureEx;
      end;

      if ok then
      begin
        result := I;
        Exit;
      end;
    end;
  end;

  result := 0;
end;

function TBaseSymbolTable.LookupForwardDeclarations(Id: Integer;
                                          UpCase: Boolean): TIntegerList;
var
  I, J, Level: Integer;
  Ok: Boolean;
  Name: String;
  R: TSymbolRec;
  List: TIntegerList;
begin
  result := nil;

  Level := Records[Id].Level;
  Name := Records[Id].Name;

  List := HashArray.GetList(Name);

  for J := List.Count - 1 downto 0 do
  begin
    I := List[J];

    R := Records[I];
    if R.IsForward and (R.Level = Level) and
      (R.Kind in KindSUBS) then
    begin
      if UpCase then
        ok := StrEql(R.Name, Name)
      else
        ok := (R.Name = Name);
      if ok then
      begin
        if result = nil then
          result := TIntegerList.Create;

        result.Add(I);
      end;
    end;
  end;
end;

function TBaseSymbolTable.GetDataSize(UpperId: Integer = MaxInt - 1): Integer;
var
  I: Integer;
  R: TSymbolRec;
  K1, K2, KK: Integer;
begin
  result := FirstShiftValue;

  Inc(UpperId);

  for KK := 1 to 2 do
  begin
    if KK = 1 then
    begin
      K1 := Types.Count;
      K2 := GlobalSymbolTable.Card;
    end
    else
    begin
      K1 := FirstLocalId + 1;
      K2 := Card;
    end;

    for I := K1 to K2 do
    begin

      if I = UpperId then
        break;

      R := Records[I];

      if R.UnionId <> 0 then
        Continue;

      if R.Kind in [KindTYPE, KindTYPE_FIELD, KindLABEL] then
        Continue;

      if R.OverScript then
      begin
        Inc(result, SizeOf(Pointer));
        continue;
      end;

      if (R.Shift > 0) and
         (not R.Param) and (not R.Local) and (not R.InternalField) then
      begin
        if R.Kind = kindSUB then
          Inc(result, SizeOf(Pointer))
        else if R.Host then
          Inc(result, SizeOf(Pointer))
        else if (R.Kind = KindCONST) and R.HasPAnsiCharType then // literal
        begin
          Inc(result, SizeOf(Pointer));
          Inc(result, SizeOf(Pointer));
          Inc(result, SizeOf(Pointer));
          Inc(result, Length(R.Value) + 1);
        end
        else if (R.Kind = KindCONST) and R.HasPWideCharType then // literal
        begin
          Inc(result, SizeOf(Pointer));
          Inc(result, SizeOf(Pointer));
          Inc(result, Length(R.Value) * 2 + 1);
        end
        else
          Inc(result, R.Size);
      end;
    end;
  end;
end;

function TBaseSymbolTable.GetSizeOfLocals(SubId: Integer): Integer;
var
  I: Integer;
  R: TSymbolRec;
begin
  result := 0;
  for I := SubId + 1 to Card do
  begin
    R := Records[I];

    if R.UnionId <> 0 then
      Continue;

    if (R.Kind = KindVAR) and (R.Level = SubId) and R.Local then
      Inc(result, R.Size);
  end;

  result := Abs(result);

  if Records[SubId].ExtraParamNeeded then
  begin
    if Records[SubId].CallConv in [ccREGISTER, ccMSFASTCALL] then
    begin
      if Records[GetResultId(SubId)].Register = 0 then
        Dec(result, 4);
    end
    else
      Dec(result, 4);
  end;

end;

function TBaseSymbolTable.GetSizeOfLocalsEx(SubId: Integer): Integer;
begin
  result := GetSizeOfLocals(SubId);
  while (result mod 4 <> 0) do
    Inc(result);
end;

function TBaseSymbolTable.GetSizeOfParams(SubId: Integer): Integer;
var
  I, J, SZ, RegCount, SelfId: Integer;
  R: TSymbolRec;
  FinTypeId: Integer;
begin
  result := 0;
  RegCount := 0;

  SelfId := GetSelfId(SubId);
  if Records[SelfId].Name <> '' then
  begin
    if Records[SubId].CallConv in [ccREGISTER, ccMSFASTCALL] then
      Inc(RegCount)
    else
      Inc(result, 4);
  end;

  for J:=0 to Records[SubId].Count - 1 do
  begin
    I := GetParamId(SubId, J);
    R := Records[I];

    if Records[SubId].CallConv in [ccREGISTER, ccMSFASTCALL] then
    begin
      if R.Register > 0 then
      begin
        Inc(RegCount);

        if R.FinalTypeId = typeDYNARRAY then
        if R.IsOpenArray then
        begin
          Inc(RegCount);
          if RegCount > 3 then
            Inc(result, 4);
        end;

        continue;
      end;
    end;

    if R.ByRef then
      Inc(result, SizeOf(Pointer))
    else
    begin
      SZ := R.Size;

      FinTypeId := R.FinalTypeId;

      if FinTypeId = typeDYNARRAY then
        Inc(SZ, 4);

      while SZ mod 4 <> 0 do
        Inc(SZ);

      Inc(result, SZ);
    end;
  end;

  result := Abs(result);

  if Records[SubId].ExtraParamNeeded then
  begin
    if Records[SubId].CallConv = ccREGISTER then
    begin
      if RegCount >= 3 then
        Inc(result, 4);
    end
    else
      Inc(result, 4);
  end;

  if Records[SubId].CallConv = ccSAFECALL then
    Inc(result, 4);
end;

function TBaseSymbolTable.GetSizeOfSetType(SetTypeId: Integer): Integer;
var
  FT, OriginTypeId: Integer;
  B2: TSymbolRec;
  I: Cardinal;
begin
  OriginTypeId := Records[SetTypeId].PatternId;
  if OriginTypeId <= 1 then
  begin
    result := 32;
    Exit;
  end;

  FT := Records[OriginTypeId].FinalTypeId;

  if FT = typeENUM then
  begin
    result := 1;
    Exit;
  end;

  if not (FT in OrdinalTypes) then
  begin
    result := 32;
    Exit;
  end;

  B2 := GetHighBoundRec(OriginTypeId);
  I := B2.Value;
  if I < 8 then
    result := 1
  else if I < 16 then
    result := 2
  else if I < 32 then
    result := 4
  else if I < 64 then
    result := 8
  else if I < 128 then
    result := 16
  else
    result := 32;
end;

function TBaseSymbolTable.CheckSetTypes(T1, T2: Integer): Boolean;
var
  P1, P2, F1, F2: Integer;
begin
  result := true;

  if T2 = H_TByteSet then
    Exit;

  P1 := Records[T1].PatternId;
  P2 := Records[T2].PatternId;

  if (P1 > 1) and (P2 > 1) then
  begin
    F1 := Records[P1].FinalTypeId;
    F2 := Records[P2].FinalTypeId;

    if F1 <> F2 then
    begin
      if (F1 in IntegerTypes) and (F2 in IntegerTypes) then
      begin
        // ok
      end
      else
        result := false;
    end
    else if (F1 = typeENUM) and (F2 = typeENUM)then
    begin
      if P1 <> P2 then
        if Records[T2].Name <> '$$' then
          result := false;
    end;
  end;
end;

function TBaseSymbolTable.GetLowBoundRec(TypeID: Integer): TSymbolRec;
var
  I: Integer;
  RI: TSymbolRec;
begin
  result := nil;

  if Records[TypeID].Kind <> kindTYPE then
  begin
    RaiseError(errInternalError, []);
    Exit;
  end;

  if Records[TypeID].TypeID = typeALIAS then
    TypeID := Records[TypeID].TerminalTypeId;

  case Records[TypeID].FinalTypeId of
    typeBOOLEAN, typeBYTEBOOL, typeWORDBOOL, typeLONGBOOL:
    begin
      result := Records[FalseId];
      Exit;
    end;
    typeINTEGER, typeANSICHAR, typeBYTE, typeWORD, typeCARDINAL,
    typeSMALLINT, typeSHORTINT,
    typeINT64:
    begin
      for I:=TypeID + 1 to Card do
      begin
        RI := Records[I];

        if RI = SR0 then
          break;

        if RI.Level = TypeID then
        begin
          result := RI;
          Exit;
        end;
      end;
    end;
    typeENUM:
    begin
      if Records[TypeID].IsSubrangeEnumType then
      begin
        result := Records[TypeID + 1];
        Exit;
      end;

      for I:=TypeID + 1 to Card do
      begin
        RI := Records[I];

        if RI = SR0 then
          break;

        if RI.OwnerId = TypeID then
        begin
          result := RI;
          Exit;
        end;
      end;
    end;
  else
    begin
      RaiseError(errInternalError, []);
      Exit;
    end;
  end;

  RaiseError(errInternalError, []);
end;

function TBaseSymbolTable.GetHighBoundRec(TypeID: Integer): TSymbolRec;
var
  I: Integer;
  RI: TSymbolRec;
begin
  result := nil;

  if Records[TypeID].TypeID = typeALIAS then
    TypeID := Records[TypeID].TerminalTypeId;

  case Records[TypeID].FinalTypeId of
    typeBOOLEAN, typeBYTEBOOL, typeWORDBOOL, typeLONGBOOL:
    begin
      result := Records[TrueId];
      Exit;
    end;
    typeINTEGER, typeANSICHAR, typeBYTE, typeWORD, typeCARDINAL,
    typeSMALLINT, typeSHORTINT,
    typeINT64:
    begin
      for I:=GetLowBoundRec(TypeID).Id + 1 to Card do
      begin
        RI := Records[I];
        if RI = SR0 then
          break;

        if RI.Level = TypeID then
        begin
          result := RI;
          Exit;
        end;
      end;
    end;
    typeENUM:
    begin
      if Records[TypeID].IsSubrangeEnumType then
      begin
        result := Records[TypeID + 2];
        Exit;
      end;

      for I:=TypeID + 1 to Card do
      begin
        RI := Records[I];

        if RI = SR0 then
          break;

        if RI.Kind = KindCONST then
        if RI.OwnerId = TypeID then
          result := RI;
      end;
      Exit;
    end;
  else
    begin
      RaiseError(errInternalError, []);
      Exit;
    end;
  end;

  RaiseError(errInternalError, []);
end;

function TBaseSymbolTable.IsZeroBasedAnsiCharArray(Id: Integer): Boolean;
var
  ArrayTypeId, RangeTypeId, ElemTypeId: Integer;
begin
  if Records[Id].FinalTypeId <> typeARRAY then
  begin
    result := false;
    Exit;
  end;

  ArrayTypeId := Records[Id].TerminalTypeId;

  GetArrayTypeInfo(ArrayTypeId, RangeTypeId, ElemTypeId);
  result := (Records[ElemTypeId].FinalTypeId = typeANSICHAR) and
            (GetLowBoundRec(RangeTypeId).Value = 0);
end;

function TBaseSymbolTable.IsZeroBasedWideCharArray(Id: Integer): Boolean;
var
  ArrayTypeId, RangeTypeId, ElemTypeId: Integer;
begin
  if Records[Id].FinalTypeId <> typeARRAY then
  begin
    result := false;
    Exit;
  end;

  ArrayTypeId := Records[Id].TerminalTypeId;

  GetArrayTypeInfo(ArrayTypeId, RangeTypeId, ElemTypeId);
  result := (Records[ElemTypeId].FinalTypeId = typeWIDECHAR) and
            (GetLowBoundRec(RangeTypeId).Value = 0);
end;

procedure TBaseSymbolTable.GetArrayTypeInfo(ArrayTypeId: Integer; var RangeTypeId: Integer;
                                                              var ElemTypeId: Integer);
var
  I, K: Integer;
begin
  if Records[ArrayTypeID].TypeID = typeALIAS then
    ArrayTypeID := Records[ArrayTypeID].TerminalTypeId;

  if Records[ArrayTypeID].ReadId <> 0 then
  begin
    RangeTypeId := Records[ArrayTypeID].ReadId;
    ElemTypeId := Records[ArrayTypeID].WriteId;
    Exit;
  end;

  ElemTypeId := 0;
  RangeTypeId := 0;

  K := Card;
  if ArrayTypeId < GlobalSymbolTable.Card then
    K := GlobalSymbolTable.Card;

  for I:=ArrayTypeId + 1 to K do
    if Records[I].Level = ArrayTypeId then
    begin
      RangeTypeId := I;
      break;
    end;

  for I:=K downto ArrayTypeId + 1 do
    if Records[I].Level = ArrayTypeId then
    begin
      ElemTypeId := I;
      break;
    end;

  if (RangeTypeId = 0) or (ElemTypeId = 0) then
  Begin
    RaiseError(errInternalError, []);
    Exit;
  end;

  if Records[RangeTypeId].TypeID = typeALIAS then
    RangeTypeId := Records[RangeTypeId].TerminalTypeId;

  if Records[ElemTypeId].TypeID = typeALIAS then
    ElemTypeId := Records[ElemTypeId].TerminalTypeId;

  Records[ArrayTypeID].ReadId := RangeTypeId;
  Records[ArrayTypeID].WriteId := ElemTypeId;
end;

function TBaseSymbolTable.GetTypeBase(TypeId: Integer): Integer;
begin
  result := Records[TypeId].PatternId;
end;

function TBaseSymbolTable.GetPatternSubId(ProcTypeID: Integer): Integer;
begin
  result := Records[ProcTypeID].PatternId;
end;

function TBaseSymbolTable.EqualHeaders(SubId1, SubId2: Integer): Boolean;

  function CompareTypes(T1, T2: Integer): Boolean;
  var
    F1, F2: Integer;
  begin
    result := false;
    F1 := Records[T1].FinalTypeId;
    F2 := Records[T2].FinalTypeId;
    if F1 <> F2 then
      Exit;
    if F1 = typeDYNARRAY then
    begin
      T1 := Records[T1].TerminalTypeId;
      T2 := Records[T2].TerminalTypeId;
      T1 := Records[T1].PatternId;
      T2 := Records[T2].PatternId;
      result := CompareTypes(T1, T2);
      Exit;
    end;
    result := true;
  end;

var
  I: Integer;
begin
  result := false;
  if not CompareTypes(Records[SubId1].TypeId, Records[SubId2].TypeId) then
    Exit;
  if Records[SubId1].Count <> Records[SubId2].Count then
    Exit;
  for I:=0 to Records[SubId1].Count - 1 do
    if not CompareTypes(Records[GetParamId(SubId1, I)].TypeID, Records[GetParamId(SubId2, I)].TypeID) then
      Exit;
  result := true;
end;

procedure TBaseSymbolTable.RaiseError(const Message: string; params: array of Const);
var
  I: Integer;
begin
  if RaiseE then
  begin
    raise Exception.Create(Format(Message, params));
  end
  else
  begin
    if Self = GlobalSymbolTable then
    begin
      if LastCard > 0 then
        for I:= GlobalSymbolTable.LastCard + 1 to GlobalSymbolTable.Card do
          GlobalSymbolTable[I].Name := '';
    end;

    REG_ERROR := Format(Message, params);
    REG_OK := false;

    if Message = errUndeclaredIdentifier then
      REG_ERROR := '';
  end;
end;

function TBaseSymbolTable.GetShiftsOfDynamicFields(ATypeId: Integer): TIntegerList;
var
  S: Integer;
procedure GetArrayShifts(TypeID: Integer); forward;

procedure GetRecordShifts(TypeID: Integer);
var
  I, T: Integer;
  RI: TSymbolRec;
begin
  for I:=TypeId + 1 to Card do
  begin
    RI := Records[I];

    if RI = SR0 then
      break;

    if (RI.Kind = KindTYPE_FIELD) and (RI.Level = TypeId) then
    begin
      T := RI.FinalTypeId;
      case T of
        typeANSISTRING, typeWIDESTRING, typeUNICSTRING, typeDYNARRAY, typeVARIANT, typeOLEVARIANT:
          result.Add(RI.Shift + S);
        typeRECORD:
        begin
          Inc(S, RI.Shift);
          TypeID := TerminalTypeOf(RI.TypeID);
          GetRecordShifts(TypeId);
        end;
        typeARRAY:
        begin
          Inc(S, RI.Shift);
          TypeID := TerminalTypeOf(RI.TypeID);
          GetArrayShifts(TypeId);
        end;
      end;
    end;
  end;
end;

procedure GetArrayShifts(TypeID: Integer);
var
  RangeTypeId, ElemTypeId, H1, H2, T, I, ElemSize: Integer;
begin
  GetArrayTypeInfo(TypeId, RangeTypeId, ElemTypeId);
  H1 := GetLowBoundRec(RangeTypeId).Value;
  H2 := GetHighBoundRec(RangeTypeId).Value;

  ElemSize := Records[ElemTypeId].Size;

  T := Records[ElemTypeId].FinalTypeId;

  case T of
    typeANSISTRING, typeWIDESTRING, typeUNICSTRING, typeDYNARRAY, typeVARIANT, typeOLEVARIANT:
      for I:=0 to H2 - H1 do
        result.Add(I * SizeOf(Pointer) + S);
    typeRECORD:
    begin
      for I:=0 to H2 - H1 do
      begin
        TypeID := TerminalTypeOf(ElemTypeId);
        GetRecordShifts(TypeId);
        Inc(S, ElemSize);
      end;
    end;
    typeARRAY:
      for I:=0 to H2 - H1 do
      begin
        TypeID := TerminalTypeOf(ElemTypeId);
        GetArrayShifts(TypeId);
        Inc(S, ElemSize);
      end;
  end;
end;

var
  T: Integer;
begin
  result := TIntegerList.Create;
  S := 0;
  T := Records[ATypeId].FinalTypeId;
  case T of
    typeRECORD: GetRecordShifts(ATypeId);
    typeARRAY: GetArrayShifts(ATypeId);
  end;
end;

function TBaseSymbolTable.GetTypesOfDynamicFields(ATypeId: Integer): TIntegerList;

  procedure GetArrayTypes(TypeID: Integer); forward;

  procedure GetRecordTypes(TypeID: Integer);
  var
    I, T: Integer;
    RI: TSymbolRec;
  begin
    for I:=TypeId + 1 to Card do
    begin
      RI := Records[I];

      if RI = SR0 then
        break;

      if (RI.Kind = KindTYPE_FIELD) and (RI.Level = TypeId) then
      begin
        T := RI.FinalTypeId;
        case T of
          typeANSISTRING, typeWIDESTRING, typeUNICSTRING, typeDYNARRAY, typeVARIANT, typeOLEVARIANT:
            result.Add(RI.TerminalTypeId);
          typeRECORD:
          begin
            TypeID := TerminalTypeOf(RI.TypeID);
            GetRecordTypes(TypeId);
          end;
          typeARRAY:
          begin
            TypeID := TerminalTypeOf(RI.TypeID);
            GetArrayTypes(TypeId);
          end;
        end;
      end;
    end;
  end;

  procedure GetArrayTypes(TypeID: Integer);
  var
    RangeTypeId, ElemTypeId, H1, H2, T, I: Integer;
  begin
    GetArrayTypeInfo(TypeId, RangeTypeId, ElemTypeId);
    H1 := GetLowBoundRec(RangeTypeId).Value;
    H2 := GetHighBoundRec(RangeTypeId).Value;

    T := Records[ElemTypeId].FinalTypeId;

    case T of
      typeANSISTRING, typeWIDESTRING, typeUNICSTRING, typeDYNARRAY, typeVARIANT, typeOLEVARIANT:
        for I:=0 to H2 - H1 do
          result.Add(Records[ElemTypeId].TerminalTypeId);
      typeRECORD:
      begin
        for I:=0 to H2 - H1 do
        begin
          TypeID := TerminalTypeOf(ElemTypeId);
          GetRecordTypes(TypeId);
        end;
      end;
      typeARRAY:
        for I:=0 to H2 - H1 do
        begin
          TypeID := TerminalTypeOf(ElemTypeId);
          GetArrayTypes(TypeId);
        end;
    end;
  end;
begin
  result := TIntegerList.Create;
  case Records[ATypeId].FinalTypeId of
    typeRECORD: GetRecordTypes(ATypeId);
    typeARRAY: GetArrayTypes(ATypeId);
  end;
end;

function TBaseSymbolTable.HasDynamicFields(ATypeId: Integer): Boolean;
var
  L: TIntegerList;
begin
  L := GetShiftsOfDynamicFields(ATypeID);
  result := L.Count > 0;
  L.Free;
end;

function TBaseSymbolTable.TerminalTypeOf(TypeID: Integer): Integer;
begin
  result := TypeID;
  if Records[result].TypeID = typeALIAS then
    result := Records[result].TerminalTypeId;
end;

function TBaseSymbolTable.FindDefaultPropertyId(i_TypeId: Integer): Integer;
var
  I: Integer;
  RI: TSymbolRec;
begin
  for I:=i_TypeId + 1 to Card do
  begin
    RI := Records[I];

    if RI = SR0 then
      break;

    if RI.Kind = KindNAMESPACE then
      break;

    with RI do
    if (Kind = kindPROP) and (Level = i_TypeId) and IsDefault then
    begin
      result := I;
      Exit;
    end;
  end;

  if Records[i_TypeId].AncestorId > 0 then
    result := FindDefaultPropertyId(Records[i_TypeId].AncestorId)
  else
    result := 0;
end;

function TBaseSymbolTable.FindConstructorId(i_TypeId: Integer): Integer;
var
  I: Integer;
  RI: TSymbolRec;
begin
  result := 0;

  for I:=i_TypeId + 1 to Card do
  begin
    RI := Records[I];

    if RI = SR0 then
      break;

    with RI do
    if (Kind = kindCONSTRUCTOR) and (Level = i_TypeId) then
    begin
      result := I;
      Exit;
    end;
  end;
end;

function TBaseSymbolTable.FindConstructorIdEx(i_TypeId: Integer): Integer;
begin
  result := FindConstructorId(I_TypeId);

  if result = 0 then
    if Records[i_TypeId].AncestorId <> 0 then
      result := FindConstructorIdEx(Records[i_TypeId].AncestorId);
end;

function TBaseSymbolTable.FindDestructorId(i_TypeId: Integer): Integer;
var
  I: Integer;
  RI: TSymbolRec;
begin
  for I:=i_TypeId + 1 to Card do
  begin
    RI := Records[I];

    if RI = SR0 then
      break;

    with RI do
    if (Kind = kindDESTRUCTOR) and (Level = i_TypeId) then
    begin
      result := I;
      Exit;
    end;
  end;
  result := 0;
end;

function TBaseSymbolTable.FindDestructorIdEx(i_TypeId: Integer): Integer;
begin

  result := FindDestructorId(i_TypeId);
  if result = 0 then
    if Records[i_TypeId].AncestorId <> 0 then
      result := FindDestructorIdEx(Records[i_TypeId].AncestorId);
end;

function TBaseSymbolTable.Inherits(T1, T2: Integer): Boolean;
begin
  T1 := Records[T1].TerminalTypeId;
  T2 := Records[T2].TerminalTypeId;

  result := (T1 = T2);
  if not result then
    result := Records[T1].Inherits(T2);
end;

function TBaseSymbolTable.Supports(T1, T2: Integer): Boolean;
var
  I: Integer;
  GuidList: TGuidList;
begin
  T1 := Records[T1].TerminalTypeId;
  T2 := Records[T2].TerminalTypeId;

  result := (T1 = T2);

  if result then
    Exit;

  if T1 = H_IUnknown then
  begin
    result := true;
    Exit;
  end;

  GuidList := Records[T2].SupportedInterfaces;

  if GuidList = nil then
  begin
    result := true;
    Exit;
  end;

  if GuidList.HasId(T1) then
  begin
    result := true;
    Exit;
  end;

  for I:=0 to GuidList.Count - 1 do
    if Supports(GuidList[I].Id, T1) then
    begin
      result := true;
      Exit;
    end;
end;

function TBaseSymbolTable.RegisterDummyType(LevelId: Integer;
                                            const TypeName: String): Integer;
begin
  result := LookupType(TypeName, LevelId, true);
  if result > 0 then
    Exit;

  with AddRecord do
  begin
    Name := TypeName;
    Kind := KindTYPE;
    TypeID := typeVOID;
    Host := true;
    Shift := 0;
    Level := LevelId;

    result := Id;
  end;
end;

function TBaseSymbolTable.RegisterSomeType(LevelId: Integer;
                                           const TypeName: String): Integer;
begin
  with AddRecord do
  begin
    Name := TypeName;
    Kind := KindTYPE;
    TypeID := typeVOID;
    Host := true;
    Shift := 0;
    Level := LevelId;

    result := Id;
  end;

  SomeTypeList.Add(TypeName, result);
end;

function TBaseSymbolTable.GetLocalCount(SubId: Integer): Integer;
var
  I, SelfId: Integer;
  RI: TSymbolRec;
begin
  result := 0;
  SelfId := GetSelfId(SubId);
  for I:=SubId + 1 to Card do
  begin
    RI := Self[I];
    if RI.Level = SubId then
      if RI.Kind = KindVAR then
        if RI.OwnerId = 0 then
          if RI.PatternId = 0 then
          if RI.Local then
          begin
            if RI.Name <> '' then
              if RI.Name <> '@' then
                Inc(result);
          end
          else if I = SelfId then
          begin
            if RI.Name <> '' then
              Inc(result);
          end;
    if RI.Kind = kindNAMESPACE then
      break;
  end;
end;

function TBaseSymbolTable.GetLocalId(SubId, LocalVarNumber: Integer): Integer;
var
  I, K, SelfId: Integer;
  RI: TSymbolRec;
begin
  K := -1;
  SelfId := GetSelfId(SubId);
  for I:=SubId + 1 to Card do
  begin
    RI := Self[I];
    if RI.Level = SubId then
      if RI.Kind = KindVAR then
        if RI.OwnerId = 0 then
          if RI.PatternId = 0 then
          if RI.Local then
          begin
            if RI.Name <> '' then
              if RI.Name <> '@' then
              begin
                Inc(K);
                if K = LocalVarNumber then
                begin
                  result := I;
                  Exit;
                end;
              end;
          end
          else if I = SelfId then
          begin
            if RI.Name <> '' then
            begin
              Inc(K);
              if K = LocalVarNumber then
              begin
                result := I;
                Exit;
              end;
            end;
          end;
  end;

  result := 0;
  RaiseError(errInvalidIndex, [LocalVarNumber]);
end;

function TBaseSymbolTable.IsParam(SubId, Id: Integer): Boolean;
var
  R: TSymbolRec;
begin
  R := Self[Id];
  result := (R.Level = SubId) and
             R.Param and
            (GetSelfId(SubId) <> Id);
end;

function TBaseSymbolTable.IsVar(LevelId, Id: Integer): Boolean;
var
  R: TSymbolRec;
begin
  if Self[LevelId].Kind = KindSUB then
    if GetSelfId(LevelId) = Id then
    begin
      result := Self[Id].Name <> '';
      Exit;
    end;

  result := false;

  R := Self[Id];
  if R.Level = LevelId then
    if R.Kind = KindVAR then
      if R.OwnerId = 0 then
        if R.Name <> '' then
          if R.Name <> '@' then
            result := true;
end;

function TBaseSymbolTable.IsConst(LevelId, Id: Integer): Boolean;
var
  R: TSymbolRec;
begin
  R := Self[Id];
  result := (R.Kind = KindCONST) and (R.Level = LevelId) and
            (R.Name <> '');
end;

function TBaseSymbolTable.IsType(LevelId, Id: Integer): Boolean;
var
  R: TSymbolRec;
begin
  R := Self[Id];
  result := (R.Kind = KindTYPE) and (R.Level = LevelId) and
            (R.Name <> '');
end;

function TBaseSymbolTable.IsNamespace(LevelId, Id: Integer): Boolean;
var
  R: TSymbolRec;
begin
  R := Self[Id];
  result := (R.Kind = KindNAMESPACE) and (R.Level = LevelId);
end;

function TBaseSymbolTable.IsTypeField(LevelId, Id: Integer): Boolean;
var
  R: TSymbolRec;
begin
  R := Self[Id];
  result := (R.Kind = KindTYPE_FIELD) and (R.Level = LevelId);
end;

function TBaseSymbolTable.IsProperty(ClassId, Id: Integer): Boolean;
var
  R: TSymbolRec;
begin
  R := Self[Id];
  result := (R.Kind = KindPROP) and (R.Level = ClassId);
end;

function TBaseSymbolTable.IsProcedure(LevelId, Id: Integer): Boolean;
var
  R: TSymbolRec;
begin
  R := Self[Id];
  result := (R.Kind = KindSUB) and (R.Level = LevelId) and
            (R.FinalTypeId = typeVOID);
  if result then
    result := Self[Id].Name <> '';
end;

function TBaseSymbolTable.IsFunction(LevelId, Id: Integer): Boolean;
var
  R: TSymbolRec;
begin
  R := Self[Id];
  result := (R.Kind = KindSUB) and (R.Level = LevelId) and
            (R.FinalTypeId <> typeVOID);
  if result then
    result := Self[Id].Name <> '';
end;

function TBaseSymbolTable.IsConstructor(ClassId, Id: Integer): Boolean;
var
  R: TSymbolRec;
begin
  R := Self[Id];
  result := (R.Kind = KindCONSTRUCTOR) and
            (R.Level = ClassId);
end;

function TBaseSymbolTable.IsDestructor(ClassId, Id: Integer): Boolean;
var
  R: TSymbolRec;
begin
  R := Self[Id];
  result := (R.Kind = KindDESTRUCTOR) and
            (R.Level = ClassId);
end;

function TBaseSymbolTable.GetGlobalCount(NamespaceId: Integer): Integer;
var
  I: Integer;
  RI: TSymbolRec;
begin
  result := 0;
  for I:=NamespaceId + 1 to Card do
  begin
    RI := Self[I];
    if RI.Level = NamespaceId then
      if RI.OwnerId = 0 then
        if RI.IsGlobalVar then
          if RI.Name <> '' then
            if RI.Name <> '@' then
              Inc(result);
  end;
end;

function TBaseSymbolTable.GetGlobalId(NamespaceId, GlobalVarNumber: Integer): Integer;
var
  I, K: Integer;
  RI: TSymbolRec;
begin
  K := -1;
  for I:=NamespaceId + 1 to Card do
  begin
    RI := Self[I];
    if RI.Level = NamespaceId then
      if RI.OwnerId = 0 then
        if RI.IsGlobalVar then
          if RI.Name <> '' then
            if RI.Name <> '@' then
            begin
              Inc(K);
              if K = GlobalVarNumber then
              begin
                result := I;
                Exit;
              end;
            end;
  end;
  result := 0;
  RaiseError(errInvalidIndex, [GlobalVarNumber]);
end;

function TBaseSymbolTable.GetFieldCount(Id: Integer; TypeMapRec: TTypeMapRec = nil): Integer;
var
  T, FinTypeId, I: Integer;
  R: TSymbolRec;
begin
  result := 0;
  if Id = 0 then
    Exit;
  FinTypeId := Self[Id].FinalTypeId;
  if FinTypeId = typeCLASS then
  begin
    if TypeMapRec <> nil then
      if TypeMapRec.Completed then
      begin
        result := TypeMapRec.Fields.Count;
        Exit;
      end;

    T := Self[Id].TerminalTypeId;
    for I:=T + 1 to Card do
    begin
      R := Self[I];
      if (R.Level = T) and (R.Kind = KindTYPE_FIELD) then
      begin
        Inc(result);
        if TypeMapRec <> nil then
          TypeMapRec.Fields.Add(I);
      end
      else if R.Kind = kindNAMESPACE then
        break;
    end;
    Inc(result, GetFieldCount(Self[T].AncestorId, TypeMapRec));
  end
  else if FinTypeId = typeRECORD then
  begin
    T := Self[Id].TerminalTypeId;
    for I:=T + 1 to Card do
    begin
      R := Self[I];
      if (R.Level = T) and (R.Kind = KindTYPE_FIELD) then
      begin
        Inc(result);
        if TypeMapRec <> nil then
          TypeMapRec.Fields.Add(I);
      end
      else if R.Kind = kindNAMESPACE then
        break;
    end;
  end;
end;

function TBaseSymbolTable.GetPublishedPropCount(Id: Integer): Integer;
var
  T, FinTypeId, I: Integer;
  R: TSymbolRec;
begin
  result := 0;
  if Id = 0 then
    Exit;
  FinTypeId := Self[Id].FinalTypeId;
  if FinTypeId = typeCLASS then
  begin
    T := Self[Id].TerminalTypeId;
    while not Self[T].Host do
      T := Self[T].AncestorId;

    for I:=T + 1 to Card do
    begin
      R := Self[I];
      if (R.Level = T) and (R.Kind = KindPROP) and
         R.IsPublished and
         (not (R.FinalTypeId in [typeEVENT, typeRECORD])) then
        Inc(result)
      else if R.Kind = kindNAMESPACE then
        break;
    end;
  end
  else
    Exit;
end;

function TBaseSymbolTable.GetPublishedPropDescriptorId(Id, PropNumber: Integer): Integer;
var
  T, FinTypeId, I: Integer;
  R: TSymbolRec;
begin
  result := 0;
  if Id = 0 then
    Exit;
  FinTypeId := Self[Id].FinalTypeId;
  if FinTypeId = typeCLASS then
  begin
    T := Self[Id].TerminalTypeId;

    while not Self[T].Host do
      T := Self[T].AncestorId;

    result := -1;
    for I:=T + 1 to Card do
    begin
      R := Self[I];
      if (R.Level = T) and (R.Kind = KindPROP) and
         R.IsPublished and
         (not (R.FinalTypeId in [typeEVENT, typeRECORD])) then
        begin
          Inc(result);
          if result = PropNumber then
          begin
            result := I;
            Exit;
          end;
        end
      else if R.Kind = kindNAMESPACE then
        break;
    end;
  end
  else
    RaiseError(errClassTypeRequired, []);
end;

function TBaseSymbolTable.GetPublishedPropName(Id, PropNumber: Integer): String;
var
  PropDescriptorId: Integer;
begin
  PropDescriptorId := GetPublishedPropDescriptorId(Id, PropNumber);
  result := Self[PropDescriptorId].Name;
end;

function TBaseSymbolTable.GetPublishedPropValueAsString(P: Pointer; StackFrameNumber: Integer;
                                           Id, PropNumber: Integer): String;
var
  OwnerAddress: Pointer;
  TypeId, PropDescriptorId: Integer;
  X: TObject;
  PropName: String;
  V: Variant;
begin
  try
    TypeId := Self[Id].TerminalTypeId;
    PropDescriptorId := GetPublishedPropDescriptorId(TypeId, PropNumber);

    OwnerAddress := GetFinalAddress(P, StackFrameNumber, Id);
    if OwnerAddress = nil then
      result := errError
    else
    begin
      X := TObject(OwnerAddress^);
      if X = nil then
        result := errError
      else
      begin
        if X = nil then
          result := errError
        else
        begin
          PropName := Records[PropDescriptorId].Name;
          if GetPropInfo(X, PropName) = nil then
            result := errError
          else
          begin
            V := GetPropValue(X, PropName, true);
            result := VarToStr(V);
          end;
        end;
      end;
    end;
  except
    result := errError;
  end;
end;

function TBaseSymbolTable.GetFieldDescriptorId(Id,
                                               FieldNumber: Integer;
                                               TypeMapRec: TTypeMapRec = nil
                                               ): Integer;
var
  T, FinTypeId, I, J, K: Integer;
  R: TSymbolRec;
  L: TIntegerList;
begin
  result := 0;
  FinTypeId := Self[Id].FinalTypeId;

  if FinTypeId = typeCLASS then
  begin
    T := Self[Id].TerminalTypeId;

    if TypeMapRec <> nil then
      if TypeMapRec.TypeId = T then
        if TypeMapRec.Completed then
        begin
          result := TypeMapRec.Fields[FieldNumber];
          Exit;
        end;

    L := TIntegerList.Create;

    try
      L.Add(T);

      T := Self[T].AncestorId;
      while T <> 0 do
      begin
        L.Insert(0, T);
        T := Self[T].AncestorId;
      end;

      K := -1;
      for I:=0 to L.Count - 1 do
      begin
        T := L[I];
        for J:=T + 1 to Card do
        begin
          R := Self[J];
          if (R.Level = T) and (R.Kind = KindTYPE_FIELD) then
          begin
            Inc(K);
            if K = FieldNumber then
            begin
              result := J;
              Exit;
            end;
          end;
        end;
      end;

    finally
      L.Free;
    end;
  end
  else if FinTypeId = typeRECORD then
  begin
    T := Self[Id].TerminalTypeId;

    if TypeMapRec <> nil then
      if TypeMapRec.TypeId = T then
        if TypeMapRec.Completed then
        begin
          result := TypeMapRec.Fields[FieldNumber];
          Exit;
        end;

    K := -1;
    for J:=T + 1 to Card do
    begin
      R := Self[J];
      if (R.Level = T) and (R.Kind = KindTYPE_FIELD) then
      begin
        Inc(K);
        if K = FieldNumber then
        begin
          result := J;
          Exit;
        end;
      end;
    end;
  end;
end;

function TBaseSymbolTable.GetFieldDescriptorIdByName(Id: Integer; const FieldName: String): Integer;
var
  T, FinTypeId, I, J: Integer;
  R: TSymbolRec;
  L: TIntegerList;
begin
  result := 0;
  FinTypeId := Self[Id].FinalTypeId;

  if FinTypeId = typeCLASS then
  begin
    T := Self[Id].TerminalTypeId;
    L := TIntegerList.Create;

    try
      L.Add(T);

      T := Self[T].AncestorId;
      while T <> 0 do
      begin
        L.Insert(0, T);
        T := Self[T].AncestorId;
      end;

      for I:=0 to L.Count - 1 do
      begin
        T := L[I];
        for J:=T + 1 to Card do
        begin
          R := Self[J];
          if (R.Level = T) and (R.Kind = KindTYPE_FIELD) then
          begin
            if StrEql(R.Name, FieldName) then
            begin
              result := J;
              Exit;
            end;
          end;
        end;
      end;

    finally
      L.Free;
    end;
  end
  else if FinTypeId = typeRECORD then
  begin
    T := Self[Id].TerminalTypeId;
    for J:=T + 1 to Card do
    begin
      R := Self[J];
      if (R.Level = T) and (R.Kind = KindTYPE_FIELD) then
      begin
        if StrEql(R.Name, FieldName) then
        begin
          result := J;
          Exit;
        end;
      end;
    end;
  end;
end;

function TBaseSymbolTable.GetFieldName(Id, FieldNumber: Integer): String;
var
  FieldDescriptorId: Integer;
begin
  FieldDescriptorId := GetFieldDescriptorId(Id, FieldNumber);
  result := Self[FieldDescriptorId].Name;
end;

function TBaseSymbolTable.GetFieldAddress(P: Pointer;
                                          StackFrameNumber,
                                          Id,
                                          FieldNumber: Integer;
                                          TypeMapRec: TTypeMapRec = nil
                                          ): Pointer;
var
  FieldDescriptorId, Shift: Integer;
  X: TObject;
begin
  result := GetFinalAddress(P, StackFrameNumber, Id);

  try
    CheckMemory(Result, sizeof (TObject));
    if Self[Id].FinalTypeId = typeCLASS then
    begin
      X := TObject(result^);
      if X = nil then
      begin
        result := nil;
        Exit;
      end;

{$IFNDEF FPC}
      CheckMemory (pointer (integer (pointer (X)^) + vmtSelfPtr), - vmtSelfPtr);
      if pointer (pointer (integer (pointer (X)^) + vmtSelfPtr)^) <> pointer(pointer (X)^) then
        raise EAbort.Create (errNotValidObject);
{$ENDIF}
      result := Pointer(X);
    end;
  except
    result := nil;
  end;

  if result = nil then
    Exit;

  FieldDescriptorId := GetFieldDescriptorId(Id, FieldNumber, TypeMapRec);
  Shift := Self[FieldDescriptorId].Shift;

  result := ShiftPointer(result, Shift);
end;

function TBaseSymbolTable.GetStrVal(Address: Pointer;
                                    TypeId: Integer;
                                    TypeMapRec: TTypeMapRec = nil): String;
var
  B: Byte;
  W: Word;
  X: TObject;
  C: TClass;
  P: Pointer;
  V: Variant;
  FinTypeId: Integer;
  I, K: Integer;
  FieldAddress: Pointer;
  FieldDescriptorId, FieldTypeId, FieldShift: Integer;
  RangeTypeId, ElemTypeId, K1, K2: Integer;
begin
  FinTypeId := Self[TypeId].FinalTypeId;

  if TypeMapRec <> nil then
    if TypeMapRec.TypeId <> TypeId then
      TypeMapRec := nil;

  try

    case FinTypeId of
      typeBOOLEAN, typeBYTEBOOL, typeWORDBOOL, typeLONGBOOL:
      begin
        CheckMemory(Address, sizeof(Byte));
        B := Byte(Address^);
        if B <> 0 then
          result := 'true'
        else
          result := 'false';
      end;
      typeBYTE, typeENUM:
      begin
        CheckMemory(Address, SizeOf(Byte));
        B := Byte(Address^);
        result := IntToStr(B);
      end;
      typeANSICHAR:
      begin
        CheckMemory(Address, SizeOf(Byte));
        B := Byte(Address^);
        result := String(AnsiChar(B));
      end;
      typeSET:
      begin
        CheckMemory(Address, SizeOf(TByteSet));
        TypeId := Self[TypeId].PatternId;
        FinTypeId := Self[TypeId].FinalTypeId;
        result := ByteSetToString(TByteSet(Address^), FinTypeId);
      end;
      typeINTEGER:
        begin
          CheckMemory(Address, SizeOf(Integer));
          result := IntToStr(Integer(Address^));
        end;
      typeCARDINAL:
        begin
          CheckMemory(Address, SizeOf(Cardinal));
          result := IntToStr(Cardinal(Address^));
        end;
      typeSMALLINT:
        begin
          CheckMemory (Address, sizeof(SmallInt));
          result := IntToStr(SmallInt(Address^));
        end;
      typeSHORTINT:
        begin
          CheckMemory (Address, sizeof (ShortInt));
          result := IntToStr(ShortInt(Address^));
        end;
      typeEVENT:
      begin
        FieldTypeId := typePOINTER;
        FieldShift := SizeOf(Pointer);
        FieldAddress := Address;

        result := Self[TypeId].Name + '(';
        result := result + GetStrVal(FieldAddress, FieldTypeId);

        result := result + ',';

        FieldAddress := ShiftPointer(Address, FieldShift);
        result := result + GetStrVal(FieldAddress, FieldTypeId);

        result := result + ')';
      end;
      typeRECORD:
      begin
        result := Self[TypeId].Name + '(';
        K := GetFieldCount(TypeId, TypeMapRec);
        for I:=0 to K - 1 do
        begin
          FieldDescriptorId := GetFieldDescriptorId(TypeId, I, TypeMapRec);

          FieldTypeId := Self[FieldDescriptorId].TypeId;
          FieldShift := Self[FieldDescriptorId].Shift;

          FieldAddress := ShiftPointer(Address, FieldShift);

          result := result + GetStrVal(FieldAddress, FieldTypeId);
          if I < K - 1 then
            result := result + ',';
        end;
        result := result + ')';
      end;
      typeCLASS:
      begin
        // Check pointer to object
        CheckMemory (Address, sizeof (TObject));
        X := TObject(Address^);
        if Assigned(X) then
        begin
          result := Self[TypeId].Name + '(';
          K := GetFieldCount(TypeId, TypeMapRec);
          for I:=0 to K - 1 do
          begin
            FieldDescriptorId := GetFieldDescriptorId(TypeId, I, TypeMapRec);

            FieldTypeId := Self[FieldDescriptorId].TypeId;
            FieldShift := Self[FieldDescriptorId].Shift;

{$IFNDEF FPC}
            // Check VMT for readability and to see if it's a true VMT
            CheckMemory (pointer (integer (pointer (X)^) + vmtSelfPtr), - vmtSelfPtr);
            if pointer (pointer (integer (pointer (X)^) + vmtSelfPtr)^) <> pointer(pointer (X)^) then
              raise EAbort.Create (errNotValidObject);
{$ENDIF}

            FieldAddress := ShiftPointer(Pointer(X), FieldShift);

            result := result + GetStrVal(FieldAddress, FieldTypeId);
            if I < K - 1 then
              result := result + ',';
          end;
          result := result + ')';
        end
        else
          result := 'nil';
      end;
      typeCLASSREF:
      begin
        CheckMemory (Address, sizeof (TClass));
        C := TClass(Address^);
        if Assigned(C) then
          result := Self[TypeId].Name
        else
          result := 'nil';
      end;
      typePOINTER:
      begin
        CheckMemory (Address, sizeof (Cardinal));
        result := Format('%x', [Cardinal(Address^)]);
      end;
      typeINTERFACE:
      begin
        CheckMemory (Address, sizeof (Cardinal));
        if Cardinal(Address^) = 0 then
          result := 'nil'
        else
          result := Format('%x', [Cardinal(Address^)]);
      end;
      typePROC:
      begin
        CheckMemory (Address, sizeof (Cardinal));
        result := Format('%x', [Cardinal(Address^)]);
      end;
      typeARRAY:
      begin
        result := Self[TypeId].Name + '(';

        GetArrayTypeInfo(TypeId, RangeTypeId, ElemTypeId);
        FieldShift := Self[ElemTypeId].Size;

        K1 := GetLowBoundRec(RangeTypeId).Value;
        K2 := GetHighBoundRec(RangeTypeId).Value;

        for I:=K1 to K2 do
        begin
          FieldAddress := ShiftPointer(Address, (I - K1) * FieldShift);
          result := result + GetStrVal(FieldAddress, ElemTypeId);
          if I < K2 then
            result := result + ',';
        end;

        result := result + ')';
      end;
      typeDYNARRAY:
      begin
        CheckMemory (Address, sizeof (Pointer));
        Address := Pointer(Address^);

        if Address = nil then
        begin
          result := 'nil';
          Exit;
        end;

        result := Self[TypeId].Name + '(';

        ElemTypeId := Self[TypeId].PatternId;
        FieldShift := Self[ElemTypeId].Size;

        P := ShiftPointer(Address, - SizeOf(Integer));

        K1 := 0;
        K2 := Integer(P^);

        for I:=K1 to K2 - 1 do
        begin
          FieldAddress := ShiftPointer(Address, (I - K1) * FieldShift);
          result := result + GetStrVal(FieldAddress, ElemTypeId);
          if I < K2 - 1 then
            result := result + ',';
        end;

        result := result + ')';
      end;
      typeANSISTRING:
        begin
          // Check pointer to string
          CheckMemory (Address, sizeof (AnsiString));
          if pointer (Address^) <> nil then
          begin
            // First check to be able to access length of string and the ref count integer
            CheckMemory(pointer(integer(Address^) - sizeof(integer) * 2), sizeof(integer) * 2);

            // Let's check if contents are accesible
            I := Integer(pointer(integer(Address^) - sizeof(integer))^);
            // I contains length of string
            if I = 0 then
            begin
              result := '';
              Exit;
            end;
            CheckMemory (pointer(Address^), I + 1);
            result := String(AnsiString(Address^));
          end
          else
          begin
            result := '';
            Exit;
          end;
        end;
     typeWIDESTRING:
       begin
         CheckMemory (Address, sizeof (WideString));
         if pointer (Address^) <> nil then
           begin
             // First check to be able to length if WideString in bytes
             CheckMemory(pointer(integer(Address^) - sizeof(integer)), sizeof(integer));

             // Let's check if contents are accesible
             I := Integer(pointer(integer(Address^) - sizeof(integer))^);
             // I contains length of string in bytes
             if I = 0 then
             begin
               result := '';
               Exit;
             end;
             CheckMemory (pointer(Address^), I + SizeOf (WideChar)); // One extra WideChar for #0
             result := WideString(Address^);
           end
           else Result := '';
       end;
     typeUNICSTRING:
       begin
         CheckMemory (Address, sizeof (UnicString));
         if pointer (Address^) <> nil then
           begin
             // First check to be able to length if WideString in bytes
             CheckMemory(pointer(integer(Address^) - sizeof(integer)), sizeof(integer));

             // Let's check if contents are accesible
             I := Integer(pointer(integer(Address^) - sizeof(integer))^);
             // I contains length of string in bytes
             if I = 0 then
             begin
               result := '';
               Exit;
             end;
             CheckMemory (pointer(Address^), I + SizeOf (WideChar)); // One extra WideChar for #0
             result := UnicString(Address^);
           end
           else Result := '';
       end;
      typeSHORTSTRING:
        begin
          CheckMemory (Address, sizeof (ShortString));
          result := String(ShortString(Address^));
        end;
      typeWIDECHAR:
      begin
        CheckMemory(Address, sizeof(WideChar));
        W := Word(Address^);
        result := WideChar(W);
      end;
      typeWORD:
      begin
        CheckMemory(Address, sizeof(Word));
        W := Word(Address^);
        result := IntToStr(W);
      end;
      typeINT64:
        begin
          CheckMemory (Address, sizeof (Int64));
          result := IntToStr(Int64(Address^));
        end;
      typeSINGLE:
        begin
          CheckMemory (Address, sizeof (Single));
          result := FloatToStr(Single(Address^));
        end;
      typeDOUBLE:
        begin
          CheckMemory (Address, sizeof (Double));
          result := FloatToStr(Double(Address^));
        end;
      typeEXTENDED:
        begin
          CheckMemory (Address, sizeof (Extended));
          result := FloatToStr(Extended(Address^));
        end;
      typeCURRENCY:
        begin
          CheckMemory (Address, sizeof (Extended));
          result := CurrToStr(Currency(Address^));
        end;
      typeVARIANT, typeOLEVARIANT:
        begin
          try
            begin
              CheckMemory (Address, sizeof (Variant));
              CheckVariantData (Address^);
              result := VarToStr(Variant(Address^));
            end
          finally
            { Variant is residing within the context of script,
              if we don't clean the TVarData before leaving the scope
              Delphi code will add cleanup code that will either free
              memory it shouldn't or even try to cleanup garbage, causing trouble regardless.
              The variant we evaluated was done so for temporary reasons anc copied for memory
              residing on the stack, as such, not cleanup is fine. Script should cleanup
              when the variant leaves its own scope }
            FillChar (V, Sizeof (V), 0);
          end;
        end
      else
        result := '';
    end;
  except
    result := errInvalidValue;
  end;
end;

procedure TBaseSymbolTable.CheckVariantData (const V);
var
  I: Integer;
begin
  if (TVarData (V).VType and varByRef <> 0) or
       (TVarData (V).VType and varArray <> 0)
    then raise EAbort.Create('varArray of varByRef not supported in debugger');
  case TVarData (V).VType and varTypeMask of
    varEmpty, varNull,
    varSmallInt, varInteger, varSingle,
    varDouble, varCurrency, varDate,
    varError, varBoolean,
    {$IFDEF VARIANTS}
    varShortInt, varWord, varLongWord, varInt64,
    {$ENDIF}
    varByte : { Everything all right, this types won't cause trouble };
    varOleStr:
      begin
        with TVarData (V) do
          begin
            CheckMemory (pointer (integer (VOleStr) - sizeof (integer)), sizeof (integer));
            I := integer (pointer (integer (VOleStr) - sizeof (integer))^);
            CheckMemory (VOleStr, I + sizeof (WideChar));
          end;
      end;
    varString:
      begin
        with TVarData (V) do
          begin
            CheckMemory (pointer (integer (VString) - sizeof (integer) * 2), sizeof (integer) * 2);
            I := integer (pointer (integer (VString) - sizeof (integer))^);
            CheckMemory (VString, I + sizeof (Char));
          end;
      end;
     else
       RaiseError(errInvalidVariantType, []);
  end;
end;

function TBaseSymbolTable.GetVal(Address: Pointer;
                                 TypeId: Integer): Variant;
var
  FinTypeId, SZ: Integer;
begin
  FinTypeId := Self[TypeId].FinalTypeId;

  try

    SZ := Types.GetSize(TypeId);
    if SZ > 0 then
      CheckMemory(Address, SZ);

    case FinTypeId of
      typeBOOLEAN: result := Boolean(Address^);
      typeBYTEBOOL: result := ByteBool(Address^);
      typeBYTE, typeENUM, typeANSICHAR: result := Byte(Address^);
      typeINTEGER, typeLONGBOOL: result := Integer(Address^);
{$IFDEF VARIANTS}
      typeCARDINAL: result := Cardinal(Address^);
{$ELSE}
      typeCARDINAL: result := Integer(Address^);
{$ENDIF}
      typeSMALLINT: result := SmallInt(Address^);
      typeSHORTINT: result := ShortInt(Address^);
{$IFDEF VARIANTS}
      typePOINTER, typeINTERFACE, typeCLASS, typeCLASSREF: result := Cardinal(Address^);
{$ELSE}
      typePOINTER, typeINTERFACE, typeCLASS, typeCLASSREF: result := Integer(Address^);
{$ENDIF}
      typeANSISTRING: result := AnsiString(Address^);
      typeWIDESTRING: result := WideString(Address^);
      typeUNICSTRING: result := UnicString(Address^);
      typeSHORTSTRING: result := ShortString(Address^);
      typeWORD, typeWIDECHAR, typeWORDBOOL: result := Word(Address^);
      {$IFDEF VARIANTS}
      typeINT64: result := Int64(Address^);
      {$ELSE}
      typeINT64: result := Integer(Address^);
      {$ENDIF}
      typeSINGLE: result := Single(Address^);
      typeDOUBLE: result := Double(Address^);
      typeEXTENDED: result := Extended(Address^);
      typeVARIANT, typeOLEVARIANT:
      begin
        CheckVariantData (Address^);
        result := Variant(Address^);
      end;
       else
         RaiseError(errIncompatibleTypesNoArgs, []);
    end;

  except
    result := Unassigned;
  end;
end;

procedure TBaseSymbolTable.PutVal(Address: Pointer;
                                  TypeId: Integer; const Value: Variant);
var
  B: Byte;
  FinTypeId: Integer;
  W: Word;
begin
  FinTypeId := Self[TypeId].FinalTypeId;

  case FinTypeId of
    typeBOOLEAN, typeBYTEBOOL:
    begin
      CheckMemory(Address, SizeOf(Byte));
      if Value then
        B := 1
      else
        B := 0;
      Byte(Address^) := B;
    end;
    typeBYTE, typeENUM:
    begin
      CheckMemory(Address, SizeOf(Byte));
      Byte(Address^) := Value;
    end;
    typeANSICHAR:
    begin
      CheckMemory(Address, SizeOf(Byte));
      Byte(Address^) := Byte(Value);
    end;
    typeINTEGER, typeLONGBOOL:
      begin
        CheckMemory (Address, sizeof (integer));
        Integer(Address^) := Integer(Value);
      end;
    typeCARDINAL:
      begin
        CheckMemory (Address, sizeof (Cardinal));
        Cardinal(Address^) := Value;
      end;
    typeSMALLINT:
      begin
        CheckMemory (Address, sizeof (SmallInt));
        SmallInt(Address^) := Value;
      end;
    typeSHORTINT:
      begin
        CheckMemory (Address, sizeof (ShortInt));
        ShortInt(Address^) := Value;
      end;
    typePOINTER, typeINTERFACE, typeCLASS, typeCLASSREF:
    begin
      CheckMemory (Address, sizeof (Cardinal));
      Cardinal(Address^) := Value;
    end;
    typeANSISTRING:
      begin
        // Check pointer to string
        CheckMemory (Address, sizeof (AnsiString));
        AnsiString(Address^) := AnsiString(Value);
      end;
   typeWIDESTRING:
     begin
       CheckMemory (Address, sizeof (WideString));
       WideString(Address^) := Value;
     end;
   typeUNICSTRING:
     begin
       CheckMemory (Address, sizeof (UnicString));
       UnicString(Address^) := Value;
     end;
    typeSHORTSTRING:
      begin
        CheckMemory (Address, sizeof (ShortString));
        ShortString(Address^) := ShortString(Value);
      end;
    typeWORD, typeWIDECHAR, typeWORDBOOL:
    begin
      CheckMemory(Address, SizeOf(Word));
      W := Word(Value);
      Word(Address^) := W;
    end;
    typeINT64:
      begin
        CheckMemory (Address, sizeof (Int64));
        {$IFDEF VARIANTS}
        Int64(Address^) := Value;
        {$ELSE}
        Int64(Address^) := Integer(Value);
        {$ENDIF}
      end;
    typeSINGLE:
      begin
        CheckMemory (Address, sizeof (Single));
        Single(Address^) := Value;
      end;
    typeDOUBLE:
      begin
        CheckMemory (Address, sizeof (Double));
        Double(Address^) := Value;
      end;
    typeEXTENDED:
      begin
        CheckMemory (Address, sizeof (Extended));
        Extended(Address^) := Value;
      end;
    typeVARIANT, typeOLEVARIANT:
      begin
        CheckMemory (Address, sizeof (Variant));
        CheckVariantData (Address^);
        Variant(Address^) := Value;
      end;
     else
       RaiseError(errIncompatibleTypesNoArgs, []);
  end;
end;

procedure TBaseSymbolTable.PutValue(P: Pointer; StackFrameNumber: Integer;
                                   Id: Integer; const Value: Variant);
var
  Address: Pointer;
  TypeId: Integer;
begin
  Address := GetFinalAddress(P, StackFrameNumber, Id);
  TypeId := Self[Id].TerminalTypeId;

  if Address = nil then
    Exit;

  PutVal(Address, TypeId, Value);
end;

function TBaseSymbolTable.GetValue(P: Pointer; StackFrameNumber: Integer;
                                   Id: Integer): Variant;
var
  Address: Pointer;
  TypeId: Integer;
begin
  Address := GetFinalAddress(P, StackFrameNumber, Id);
  TypeId := Self[Id].TerminalTypeId;

  if Address = nil then
    Exit;

  result := GetVal(Address, TypeId);
end;

function TBaseSymbolTable.GetValueAsString(P: Pointer;
                                           StackFrameNumber: Integer;
                                           Id: Integer;
                                           TypeMapRec: TTypeMapRec = nil): String;
var
  Address: Pointer;
  TypeId: Integer;
begin
  result := '';
  Address := GetFinalAddress(P, StackFrameNumber, Id);
  TypeId := Self[Id].TerminalTypeId;

  if Address = nil then
    Exit;

  result := GetStrVal(Address, TypeId, TypeMapRec);
end;

function TBaseSymbolTable.GetFieldValueAsString(P: Pointer;
                                                StackFrameNumber: Integer;
                                                Id: Integer;
                                                FieldNumber: Integer;
                                                TypeMapRec: TTypeMapRec = nil
                                                ): String;
var
  FieldAddress: Pointer;
  TypeId, FieldDescriptorId, FieldTypeId: Integer;
begin
  TypeId := Self[Id].TerminalTypeId;
  FieldDescriptorId := GetFieldDescriptorId(TypeId, FieldNumber, TypeMapRec);
  FieldTypeId := Self[FieldDescriptorId].TypeID;

  FieldAddress := GetFieldAddress(P, StackFrameNumber, Id, FieldNumber, TypeMapRec);

  if FieldAddress = nil then
    result := errInvalidValue
  else
    result := GetStrVal(FieldAddress, FieldTypeId);
end;

function TBaseSymbolTable.GetArrayItemAddress(P: Pointer; StackFrameNumber, Id,
                                              Index: Integer): Pointer;
var
  TypeId, RangeTypeId, ElemTypeId, Shift, K1: Integer;
begin
  result := GetFinalAddress(P, StackFrameNumber, Id);
  TypeId := Self[Id].TerminalTypeId;
  GetArrayTypeInfo(TypeId, RangeTypeId, ElemTypeId);
  Shift := Self[ElemTypeId].Size;
  K1 := GetLowBoundRec(RangeTypeId).Value;
  result := ShiftPointer(result, (Index - K1) * Shift);
end;


function TBaseSymbolTable.GetArrayItemValueAsString(P: Pointer; StackFrameNumber: Integer;
                                               Id, Index: Integer): String;
var
  Address: Pointer;
  TypeId, RangeTypeId, ElemTypeId: Integer;
begin
  Address := GetArrayItemAddress(P, StackFrameNumber, Id, Index);
  TypeId := Self[Id].TerminalTypeId;
  GetArrayTypeInfo(TypeId, RangeTypeId, ElemTypeId);
  result := GetStrVal(Address, ElemTypeId);
end;


function TBaseSymbolTable.GetDynArrayItemAddress(P: Pointer;
                                    StackFrameNumber: Integer;
                                    Id, Index: Integer): Pointer;
var
  TypeId, ElemTypeId, Shift: Integer;
begin
  result := GetFinalAddress(P, StackFrameNumber, Id);
  result := Pointer(result^);
  if result = nil then
    Exit;

  TypeId := Self[Id].TerminalTypeId;
  ElemTypeId := Self[TypeId].PatternId;
  Shift := Self[ElemTypeId].Size;

  result := ShiftPointer(result, Index * Shift);
end;

function TBaseSymbolTable.GetDynArrayItemValueAsString(P: Pointer; StackFrameNumber: Integer;
                                               Id, Index: Integer): String;
var
  Address: Pointer;
  TypeId, ElemTypeId: Integer;
begin
  Address := GetDynArrayItemAddress(P, StackFrameNumber, Id, Index);
  TypeId := Self[Id].TerminalTypeId;
  ElemTypeId := Self[TypeId].PatternId;
  result := GetStrVal(Address, ElemTypeId);
end;

function TBaseSymbolTable.GetFinalAddress(P: Pointer; StackFrameNumber: Integer;
                                          Id: Integer): Pointer;

var
  Shift: Integer;
  EBP_Value: Integer;
begin
  result := nil;

  if TProgram(P).RootCallStackEBP.Count > 0 then
    EBP_Value := TProgram(P).RootCallStackEBP[StackFrameNumber]
  else
    EBP_Value := 0;

  Shift := Self[Id].Shift;

  if Self[Id].Param then
  begin
    if EBP_Value = 0 then
      Exit;

    result := TProgram(P).PauseRec.GetPtr(EBP_Value, Shift);
    if Self[Id].ByRef then
      result := Pointer(result^);
  end
  else if Self[Id].Local then
  begin
    if EBP_Value = 0 then
      Exit;

    result := TProgram(P).PauseRec.GetPtr(EBP_Value, Shift);
    if Self[Id].ByRef then
      result := Pointer(result^);
  end
  else if Self[Id].IsGlobalVar then
  begin
    result := TProgram(P).GetAddress(Shift);
    if Self[Id].ByRef or Self[Id].Host then
      result := Pointer(result^);
  end;
end;

function TBaseSymbolTable.FindPAnsiCharConst(const S: String; LimitId: Integer): Integer;
var
  I: Integer;
  R: TSymbolRec;
begin
  for I:=Types.Count to LimitId do
  begin
    R := Records[I];
    if R.Kind = KindCONST then
      if R.HasPAnsiCharType then
        if R.Value = S then
        begin
          result := I;
          Exit;
        end;
  end;
  result := 0;
end;

function TBaseSymbolTable.FindPWideCharConst(const S: String; LimitId: Integer): Integer;
var
  I: Integer;
  R: TSymbolRec;
begin
  for I:=Types.Count to LimitId do
  begin
    R := Records[I];
    if R.Kind = KindCONST then
      if R.HasPWideCharType then
        if R.Value = S then
        begin
          result := I;
          Exit;
        end;
  end;
  result := 0;
end;

function TBaseSymbolTable.GetAlignmentSize(TypeId, DefAlign: Integer): Integer;
var
  FT, J, temp,
  RangeTypeId, ElemTypeId: Integer;
  R: TSymbolRec;
  K: Integer;
begin
  if DefAlign = 1 then
  begin
    result := DefAlign;
    Exit;
  end;

  FT := Records[TypeId].FinalTypeId;
  if FT in (OrdinalTypes +
    [typeCLASS, typeCLASSREF, typePOINTER,
     typeANSISTRING, typeWIDESTRING, typeUNICSTRING, typeDYNARRAY, typeINTERFACE]) then
  begin
    result := Types.GetSize(FT);
    if result > DefAlign then
      result := DefAlign;
  end
  else if FT = typeSET then
  begin
    result := GetSizeOfSetType(TypeId);
    if result > 4 then
       result := 1;
  end
  else if FT = typeSINGLE then
  begin
    result := 4;
    if result > DefAlign then
      result := DefAlign;
  end
  else if FT in [typeDOUBLE, typeCURRENCY, typeEXTENDED] then
  begin
    result := 8;
    if result > DefAlign then
      result := DefAlign;
  end
  else if FT = typeSHORTSTRING then
    result := 1
  else if FT = typeARRAY then
  begin
    TypeId := Records[TypeId].TerminalTypeId;
    if Records[TypeId].IsPacked then
    begin
      result := 1;
      Exit;
    end;

    GetArrayTypeInfo(TypeId, RangeTypeId, ElemTypeId);
    result := GetAlignmentSize(ElemTypeId, DefAlign);
  end
  else if FT = typeRECORD then
  begin
    TypeId := Records[TypeId].TerminalTypeId;
    if Records[TypeId].IsPacked then
    begin
      result := 1;
      Exit;
    end;

    K := Card;
    if Self = GlobalSymbolTable then
      K := GlobalSymbolTable.Card;

    result := 0;
    for J:= TypeId + 1 to K do
    begin
      R := Records[J];

      if (R.Kind = KindTYPE_FIELD) and (R.Level = TypeId) then
      begin
        temp := GetAlignmentSize(R.TypeId, DefAlign);
        if temp > result then
          result := temp;
      end;
    end;
  end
  else
    result := DefAlign;
end;

function TBaseSymbolTable.FindClassTypeId(Cls: TClass): Integer;
var
  I, J: Integer;
  S: String;
  R: TSymbolRec;
  ok: Boolean;
  List: TIntegerList;
begin
  if StdCard = 0 then
  begin
    if DllDefined then
      S := Cls.ClassName
    else
      S := '';

    for I:= Card downto 1 do
      with Records[I] do
        if DllDefined then
        begin
          if Kind = KindTYPE then if Name = S then
          begin
            result := I;
            Exit;
          end;
        end
        else if PClass = Cls then
        begin
          result := I;
          Exit;
        end;

    result := 0;
    Exit;
  end;

  S := Cls.ClassName;

  List := HashArray.GetList(S);

  for J:=List.Count - 1 downto 0 do
  begin
    I := List[J];
    R := Records[I];
    if DllDefined then
      ok := StrEql(R.Name, S) and (R.Kind = KindTYPE)
    else
      ok := R.PClass = Cls;
    if ok then
    begin
      result := I;
      Exit;
    end;
  end;

  result := 0;
end;

procedure TBaseSymbolTable.SetVisibility(C: TClass; const MemberName: String; value: Integer);
var
  Id: Integer;
  Vis: TClassVisibility;
begin
  Vis := cvPublic;

  if Value = 0 then
    Vis := cvPublic
  else if Value = 1 then
    Vis := cvProtected
  else if Value = 2 then
    Vis := cvPrivate
  else
    RaiseError(errIncorrectValue, []);

  Id := FindClassTypeId(C);
  if Id > 0 then
  begin
    id := Lookup(MemberName, Id, true);
    if Id > 0 then
      Records[Id].Vis := Vis;
  end;
end;

procedure TBaseSymbolTable.SaveNamespaceToStream(LevelId: Integer; S: TStream);

var
  BeginId, EndId: Integer;

function IsExternalId(Id: Integer): Boolean;
begin
  if Id > EndId then
    result := true
  else if Id < BeginId then
  begin
    if Id < StdCard then
      result := false
    else
      result := true;
  end
  else
    result := false;
end;

var
  Writer: TWriter;
  ExternRec: TExternRec;
  R: TSymbolRec;
  I: Integer;
  CurrOffset: Integer;
  GUID: TGUID;
begin
  CurrOffset := GetDataSize(LevelId);

  Writer := TWriter.Create(S, 4096 * 4);
  ExternRec := TExternRec.Create;

  try

    BeginId := LevelId;
    EndId := Card;

    for I := LevelId + 1 to Card do
      if Records[I].Kind = KindNAMESPACE then
      begin
        EndId := I - 1;
        break;
      end;

    Writer.Write(StreamVersion,  SizeOf(StreamVersion));
    Writer.Write(BeginId,     SizeOf(Integer));
    Writer.Write(EndId,       SizeOf(Integer));
    Writer.Write(CurrOffset,  SizeOf(Integer));

    for I := LevelId to EndId do
    begin
      R := Records[I];
      R.SaveToStream(Writer);

      if (R.Kind = KindTYPE) and (R.TypeId = typeINTERFACE) then
      begin
        GUID := GuidList.GetGuidByID(I);
        Writer.Write(GUID, SizeOf(GUID));
      end;

      if IsExternalId(R.TypeId) then
      begin
        ExternRec.Id := R.Id;
        ExternRec.FullName := Records[R.TypeId].FullName;
        ExternRec.RecKind := erTypeId;

        ExternRec.SaveToStream(Writer);
      end;

      if IsExternalId(R.PatternId) then
      begin
        ExternRec.Id := R.Id;
        ExternRec.FullName := Records[R.PatternId].FullName;
        ExternRec.RecKind := erPatternId;

        ExternRec.SaveToStream(Writer);
      end;

      if IsExternalId(R.AncestorId) then
      begin
        ExternRec.Id := R.Id;
        ExternRec.FullName := Records[R.AncestorId].FullName;
        ExternRec.RecKind := erAncestorId;

        ExternRec.SaveToStream(Writer);
      end;

      if IsExternalId(R.ReadId) then
      begin
        ExternRec.Id := R.Id;
        ExternRec.FullName := Records[R.ReadId].FullName;
        ExternRec.RecKind := erReadId;
        ExternRec.SaveToStream(Writer);
      end;

      if IsExternalId(R.WriteId) then
      begin
        ExternRec.Id := R.Id;
        ExternRec.FullName := Records[R.WriteId].FullName;
        ExternRec.RecKind := erWriteId;
        ExternRec.SaveToStream(Writer);
      end;

    end;

  finally

    Writer.Free;
    ExternRec.Free;

  end;
end;

procedure TBaseSymbolTable.LoadNamespaceFromStream(S: TStream);

var
  OldNamespaceId, OldEndId: Integer;

function IsExternalId(Id: Integer): Boolean;
begin
  if Id > OldEndId then
    result := true
  else if Id < OldNamespaceId then
  begin
    if Id > StdCard then
      result := true
    else
      result := false;
  end
  else
    result := false;
end;

function IsInternalId(Id: Integer): Boolean;
begin
  result := (Id >= OldNamespaceId) and (Id <= OldEndId);
end;

var
  I, J, NamespaceId, K, Delta: Integer;
  R: TSymbolRec;
  ClearNextVal: Boolean;
  Reader: TReader;
  ExternRec: TExternRec;
  CurrOffset, OldOffset, DeltaOffset: Integer;
  First: Boolean;
  CurrStreamVersion: Integer;
  GUID: TGUID;
  GuidRec: TGuidRec;
  C: TClass;
begin
  C := nil;
  
  First := true;

  CurrOffset := GetDataSize;

  Reader := TReader.Create(S, 4096 * 4);
  ExternRec := TExternRec.Create;

  try
    Reader.Read(CurrStreamVersion,  SizeOf(StreamVersion));
    if CurrStreamVersion <> StreamVersion then
      RaiseError(errIncorrectStreamVersion, []);

    Reader.Read(OldNamespaceId, SizeOf(Integer));
    Reader.Read(OldEndId,       SizeOf(Integer));
    Reader.Read(OldOffset,      SizeOf(Integer));

    K := OldEndId - OldNamespaceId + 1;

    R := AddRecord;
    NamespaceId := R.Id;

    Delta := NamespaceId - OldNamespaceId;
    DeltaOffset := CurrOffset - OldOffset;

    R.LoadFromStream(Reader);
    R.Update;

    ClearNextVal := false;

    for I := 2 to K do
    begin
      R := AddRecord;

      R.LoadFromStream(Reader);
      R.Update;

      if (R.Kind = KindTYPE) and (R.TypeId = typeINTERFACE) then
      begin
        Reader.Read(GUID, SizeOf(GUID));
        GuidList.Add(GUID, R.Id, R.Name);

        if R.SupportedInterfaces <> nil then
          for J := R.SupportedInterfaces.Count - 1 downto 0 do
          begin
            GuidRec := R.SupportedInterfaces[J];

            if IsExternalId(GuidRec.Id) then
            begin
              ExternList.Add(R.Id, GuidRec.Name, erGUID);
              R.SupportedInterfaces.Delete(J);
            end
            else if IsInternalId(GuidRec.Id) then
              GuidRec.Id := GuidRec.Id + Delta;
          end;
      end;

      if IsInternalId(R.Level) then
        R.Level := R.Level + Delta;

      if R.Shift > 0 then
        if R.Kind <> kindTYPE_FIELD then
        begin
          R.Shift := R.Shift + DeltaOffset;

          if First then
          begin
            while R.Shift < CurrOffset do
            begin
              R.Shift := R.Shift + 1;
              Inc(DeltaOffset);
            end;

            First := false;
          end;
        end;

      if IsInternalId(R.OwnerId) then
        R.OwnerId := R.OwnerId + Delta;

      if IsExternalId(R.TypeId) then
      begin
        ExternRec.LoadFromStream(Reader);
        J := LookupFullName(ExternRec.FullName, true);
        if J > 0 then
          R.TypeID := J
        else
        begin
          ExternRec.Id := R.Id;
          ExternList.Add(ExternRec.Id, ExternRec.FullName, ExternRec.RecKind);
        end;
      end
      else if IsInternalId(R.TypeID) then
        R.TypeId := R.TypeId + Delta;

      if IsExternalId(R.PatternId) then
      begin
        ExternRec.LoadFromStream(Reader);
        J := LookupFullName(ExternRec.FullName, true);
        if J > 0 then
          R.PatternID := J
        else
        begin
          ExternRec.Id := R.Id;
          ExternList.Add(ExternRec.Id, ExternRec.FullName, ExternRec.RecKind);
        end;
      end
      else if IsInternalId(R.PatternID) then
        R.PatternId := R.PatternId + Delta;

      if IsExternalId(R.AncestorId) then
      begin
        ExternRec.LoadFromStream(Reader);
        J := LookupFullName(ExternRec.FullName, true);
        if J > 0 then
          R.AncestorID := J
        else
        begin
          ExternRec.Id := R.Id;
          ExternList.Add(ExternRec.Id, ExternRec.FullName, ExternRec.RecKind);
        end;
      end
      else if IsInternalId(R.AncestorID) then
        R.AncestorId := R.AncestorId + Delta;

      if IsExternalId(R.ReadId) then
      begin
        ExternRec.LoadFromStream(Reader);
        J := LookupFullName(ExternRec.FullName, true);
        if J > 0 then
          R.ReadId := J
        else
        begin
          ExternRec.Id := R.Id;
          ExternList.Add(ExternRec.Id, ExternRec.FullName, ExternRec.RecKind);
        end;
      end
      else if IsInternalId(R.ReadId) then
        R.ReadId := R.ReadId + Delta;

      if IsExternalId(R.WriteId) then
      begin
        ExternRec.LoadFromStream(Reader);
        J := LookupFullName(ExternRec.FullName, true);
        if J > 0 then
          R.WriteId := J
        else
        begin
          ExternRec.Id := R.Id;
          ExternList.Add(ExternRec.Id, ExternRec.FullName, ExternRec.RecKind);
        end;
      end
      else if IsInternalId(R.WriteId) then
        R.WriteId := R.WriteId + Delta;

      if ClearNextVal then
      begin
        R.Value := Integer(C);
        ClearNextVal := false;
      end;

      if R.ClassIndex <> -1 then
      begin
        Inc(LastClassIndex);
        R.ClassIndex := LastClassIndex;

        C := Classes.GetClass(R.Name);

        R.PClass := C;
        ClearNextVal := true;
      end;
    end;

  finally

    Reader.Free;
    ExternRec.Free;

  end;

  LastShiftValue := GetDataSize;

end;

procedure TBaseSymbolTable.ResolveExternList(CheckProc: TCheckProc; Data: Pointer);
var
  I, J, PositiveIndex: Integer;
  GD: TGUID;
  RJ: TSymbolRec;
begin
  for I := 0 to ExternList.Count - 1 do
  with ExternList[I] do
  begin
    if Id = 0 then
      continue;

    if RecKind = erGUID then
    begin
      J := LookupType(FullName, true);

      if J = 0 then
      begin
        if Assigned(CheckProc) then
          if not CheckProc(FullName, Data, erNone) then
            continue;

        RaiseError(errUndeclaredInterface, [FullName]);
      end;

      if Records[Id].SupportedInterfaces = nil then
         Records[Id].SupportedInterfaces := TGuidList.Create;

      GD := GuidList.GetGuidByID(J);

      Records[Id].SupportedInterfaces.Add(GD, J, FullName);

      // recreate positive method indexes

      PositiveIndex := -1;

      for J := Id to Card do
      begin
        RJ := Records[J];

        if RJ = SR0 then
          break;

        if RJ.Kind = kindNAMESPACE then
          break;

        if (RJ.Level = Id) and (RJ.Kind = kindSUB) and
           (RJ.NegativeMethodIndex < 0) then
           begin
             if PositiveIndex = -1 then
               PositiveIndex := RestorePositiveIndex(Id);

             if PositiveIndex = -1 then
               RaiseError(errInternalError, []);
             RJ.MethodIndex := Abs(RJ.NegativeMethodIndex) + PositiveIndex;
           end;
      end;

      continue;
    end;

    if RecKind = erTypeId then
    begin
      if PosCh('.', FullName) > 0 then
        J := LookupFullName(FullName, true)
      else
        J := LookupType(FullName, 0, true)
    end
    else
      J := LookupFullName(FullName, true);

    if J > 0 then
    begin
      case RecKind of
        erTypeId: Records[Id].TypeID := J;
        erPatternId: Records[Id].PatternID := J;
        erAncestorId: Records[Id].AncestorID := J;
        erReadId: Records[Id].ReadID := J;
        erWriteId: Records[Id].WriteID := J;
      end;
    end
    else
    begin
      case RecKind of
        ePropertyInBaseClassId:
        begin
          if Assigned(CheckProc) then
            if not CheckProc(FullName, Data, RecKind) then
              continue;

          RaiseError(errPropertyDoesNotExistsInTheBaseClass, [FullName]);
        end;
        erTypeId:
        begin
          if Assigned(CheckProc) then
            if not CheckProc(FullName, Data, RecKind) then
              continue;

          RaiseError(errTypeNotFound, [FullName]);
        end
      else
        begin
          if Assigned(CheckProc) then
            if not CheckProc(FullName, Data, RecKind) then
              continue;

          RaiseError(errUndeclaredIdentifier, [FullName]);
        end;
      end;
    end;
  end;

  if Self <> GlobalSymbolTable then
    GlobalSymbolTable.ResolveExternList(CheckProc, Data);
end;

procedure TBaseSymbolTable.SaveNamespaceToFile(LevelId: Integer; const FileName: String);
var
  F: TFileStream;
begin
  F := TFileStream.Create(FileName, fmCreate);
  try
    SaveNamespaceToStream(LevelId, F);
  finally
    F.Free;
  end;
end;

procedure TBaseSymbolTable.SaveNamespaceToStream(const NamespaceName: String; S: TStream);
var
  Id: Integer;
begin
  Id := LookupNamespace(NamespaceName, 0, true);
  if Id = 0 then
    RaiseError(errUndeclaredIdentifier, [NamespaceName]);
  SaveNamespaceToStream(Id, S);
end;

procedure TBaseSymbolTable.SaveNamespaceToFile(const NamespaceName, FileName: String);
var
  Id: Integer;
begin
  Id := LookupNamespace(NamespaceName, 0, true);
  if Id = 0 then
    RaiseError(errUndeclaredIdentifier, [NamespaceName]);
  SaveNamespaceToFile(Id, FileName);
end;

procedure TBaseSymbolTable.LoadNamespaceFromFile(const FileName: String);
var
  F: TFileStream;
begin
  if not FileExists(FileName) then
    RaiseError(errFileNotFound, [FileName]);
  F := TFileStream.Create(FileName, fmOpenRead);
  try
    LoadNamespaceFromStream(F);
  finally
    F.Free;
  end;
end;

procedure TBaseSymbolTable.AddScriptFields(ClassId: Integer; FieldList: TMapFieldList);
var
  I: Integer;
  RI: TSymbolRec;
begin
  for I := ClassId + 1 to Card do
  begin
    RI := Records[I];
    if RI.Level = ClassId then
      if RI.Kind = kindTYPE_FIELD then
        FieldList.Add(RI.Name, RI.Shift);
  end;
  ClassId := Records[ClassId].AncestorId;
  if ClassId > 0 then
    if not Records[ClassId].Host then
      AddScriptFields(ClassId, FieldList);
end;

procedure TBaseSymbolTable.ExtractMembers(Id: Integer; L: TStrings;
                                          Lang: TPaxLang = lngPascal);

  function ExtractParams(R: TSymbolRec): String;
  var
    LP: TStringList;
    J: Integer;
  begin
    result := '';
    if R.Count > 0 then
    begin
      LP := TStringList.Create;
      try
        ExtractParameters(R.Id, LP, Lang);
        for J := 0 to LP.Count - 1 do
        begin
          result := result + LP[J];
          if J <> LP.Count - 1 then
            case Lang of
              lngBasic:
                result := result + ', ';
            else
              result := result + '; ';
            end;
        end;
      finally
        LP.Free;
      end;
    end;
  end;

var
  T, I, K: Integer;
  R: TSymbolRec;
  S, P: String;
begin
  if Records[Id].Kind = kindNAMESPACE then
    T := Id
  else
  begin
    T := Records[Id].TerminalTypeId;
    if T in [0, typeVOID] then
      Exit;
  end;
  if T > FirstLocalId then
    K := Card
  else
    K := GlobalSymbolTable.Card;

  for I:= T + 1 to K do
  begin
    R := Records[I];
    if R.Level = T then
    begin
      S := R.Name;
      if IsValidName(S) then
      case R.Kind of
        kindCONSTRUCTOR:
        begin
          P := ExtractParams(R);
          case Lang of
            lngBasic:
            begin
              S := 'Sub ' + R.Name + '(' + P + ')';
            end
            else
            begin
              if P = '' then
                S := 'constructor ' + R.Name + ';'
              else
                S := 'constructor ' + R.Name + '(' + P + ');';
            end;
          end;
          if L.IndexOf(S) = -1 then
            L.AddObject(S, TObject(R.Id));
        end;
        kindDESTRUCTOR:
        begin
          case Lang of
            lngBasic:
            begin
              S := 'Sub ' + R.Name + '()';
            end;
            else
            begin
              S := 'destructor ' + R.Name + ';';
            end;
          end;
          if L.IndexOf(S) = -1 then
            L.AddObject(S, TObject(R.Id));
        end;
        kindSUB:
        begin
          P := ExtractParams(R);

          case Lang of
            lngBasic:
            begin
              if R.TypeId in [0, typeVOID] then
                S := 'Sub ' + R.Name + '(' + P + ')'
              else
                S := 'Function ' + R.Name + '(' + P + ') As ' +
                     Records[R.TypeId].NativeName;
            end;
            else
            begin
              if R.TypeId in [0, typeVOID] then
              begin
                if P = '' then
                  S := 'procedure ' + R.Name + ';'
                else
                  S := 'procedure ' + R.Name + '(' + P + ');';
              end
              else
              begin
                if P = '' then
                  S := 'function ' + R.Name + ': ' +
                     Records[R.TypeId].NativeName + ';'
                else
                  S := 'function ' + R.Name + '(' + P + '): ' +
                     Records[R.TypeId].NativeName + ';';
              end;
            end;
          end;

          if L.IndexOf(S) = -1 then
            L.AddObject(S, TObject(R.Id));
        end;
        kindTYPE_FIELD:
        begin
          case Lang of
            lngBasic:
              S := 'Dim ' + R.Name + 'As ' + Records[R.TypeId].NativeName;
            else
              S := 'field ' + R.Name + ': ' + Records[R.TypeId].NativeName + ';';
          end;
          if L.IndexOf(S) = -1 then
            L.AddObject(S, TObject(R.Id));
        end;
        kindPROP:
        begin
          case Lang of
            lngBasic:
              S := 'Property ' + R.Name + 'As ' + Records[R.TypeId].NativeName;
            else
              S := 'property ' + R.Name + ': ' + Records[R.TypeId].NativeName + ';';
          end;
          if L.IndexOf(S) = -1 then
            L.AddObject(S, TObject(R.Id));
        end;
        kindVAR:
        begin
          case Lang of
            lngBasic:
              S := 'Dim ' + R.Name + 'As ' + Records[R.TypeId].NativeName;
            else
              S := 'var ' + R.Name + ': ' + Records[R.TypeId].NativeName + ';';
          end;
          if L.IndexOf(S) = -1 then
            L.AddObject(S, TObject(R.Id));
        end;
        kindCONST:
        begin
          case Lang of
            lngBasic:
              S := 'Const ' + R.Name + 'As ' +
                    Records[R.TypeId].NativeName + '= ' +
                    ValueStr(R.Id);
            else
              S := 'const ' + R.Name + ': ' +
                    Records[R.TypeId].NativeName + '= ' +
                    ValueStr(R.Id) +
                    ';';
          end;
          if L.IndexOf(S) = -1 then
            L.AddObject(S, TObject(R.Id));
        end;
        kindTYPE:
        begin
          case Lang of
            lngBasic:
              S := 'Type ' + R.Name;
            else
              S := 'type ' + R.Name + ';';
          end;
          if L.IndexOf(S) = -1 then
            L.AddObject(S, TObject(R.Id));
        end;
      end;
    end;
  end;

  if Records[T].AncestorId > 0 then
    ExtractMembers(Records[T].AncestorId, L);

//  if Records[T].FinalTypeId <> typeINTERFACE then
//    Exit;

  if Records[T].SupportedInterfaces = nil then
    Exit;

  for I:=0 to Records[T].SupportedInterfaces.Count - 1 do
    ExtractMembers(Records[T].SupportedInterfaces[I].Id, L);
end;

function TBaseSymbolTable.ValueStr(I: Integer): String;
var
  VarObject: TVarObject;
begin
  if IsVarObject(Records[I].Value) then
  begin
    VarObject := VariantToVarObject(Records[I].Value);
    result := VarObject.ToStr;
  end
  else if VarType(Records[I].Value) = varEmpty then
    result := ''
  else
    result := VarToStr(Records[I].Value);
  ReplaceCh(result, #0, '_');

  if result = '' then
    result := '''' + ''''
  else if Records[I].FinalTypeId in [typePOINTER,
                                     typeCLASS,
                                     typeCLASSREF,
                                     typeINTERFACE] then
       if result = '0' then 
          result := 'nil';
end;

procedure TBaseSymbolTable.ExtractParameters(Id: Integer; L: TStrings;
                                             Lang: TPaxLang = lngPascal);
var
  I, J, K: Integer;
  R: TSymbolRec;
  S: String;
begin
  K := Records[Id].Count;
  J := 0;
  for I := Id + 1 to Card do
    if IsParam(Id, I) then
    begin
      Inc(J);

      R := Records[I];
      S := R.Name;
      if not IsValidName(S) then
      begin
        S := Copy(Records[R.TypeId].Name, 1, 1);
        if L.IndexOf(S) >= 0 then
          S := S + Chr(J);
      end;

      case Lang of
        lngBasic:
        begin
          S := S + ' As ' +
               Records[R.TypeId].NativeName;
          if R.ByRef then
            S := 'ByRef ' + S
          else if R.IsConst then
            S := 'Const ' + S;
        end;
        else
        begin
          S := S + ': ' +
               Records[R.TypeId].NativeName;
          if R.ByRef then
            S := 'var ' + S
          else if R.IsConst then
            S := 'const ' + S;
        end;
      end;

      if R.Optional then
      begin
        S := S + '= ' + ValueStr(I);
      end;

      L.AddObject(S, TObject(R.Id));
      if J = K then
        break;
    end;
end;

procedure TBaseSymbolTable.ExtractParametersEx(Id: Integer; L: TStrings; Upcase: Boolean);
var
  OverList: TIntegerList;
  I: Integer;
begin
  OverList := LookUpAll(Records[Id].Name,
                        Records[Id].Level,
                        Upcase);
  try
    for I := 0 to OverList.Count - 1 do
    begin
      ExtractParameters(OverList[I], L);
      if I <> OverList.Count - 1 then
        L.Add(PARAMS_DELIMITER);
    end;
  finally
    OverList.Free;
  end;
end;

procedure TBaseSymbolTable.AddTypes(const TypeName: String; L: TStrings;
                                    ErrorIndex: Integer; Upcase: Boolean);
var
  I, J, K1, K2: Integer;
  List: TIntegerList;
  RI: TSymbolRec;
  ok: Boolean;
  R: TUndeclaredTypeRec;
begin
  K1 := L.Count;

  List := HashArray.GetList(TypeName);
  for J := List.Count - 1 downto 0 do
  begin
    I := List[J];
    RI := Records[I];
    if RI.Kind = kindTYPE then
    begin
      if UpCase then
        ok := StrEql(RI.Name, TypeName)
      else
        ok := RI.Name = TypeName;
      if ok then
      begin
        if L.IndexOf(RI.FullName) = -1 then
        begin
          R := TUndeclaredTypeRec.Create;
          R.Id := I;
          R.ErrorIndex := ErrorIndex;
          L.AddObject(RI.FullName, R);
        end;
      end;
    end;
  end;

  K2 := L.Count;
  if K1 = K2 then
    if L.IndexOf(TypeName) = -1 then
    begin
      R := TUndeclaredTypeRec.Create;
      R.Id := 0;
      R.ErrorIndex := ErrorIndex;
      L.AddObject(TypeName, R);
    end;
end;

procedure TBaseSymbolTable.CreateInterfaceMethodList(IntfId: Integer;
                                                     L: TIntegerList);
var
  I: Integer;
  R: TSymbolRec;
begin
  repeat
    IntfId := Records[IntfId].TerminalTypeId;
    if IntfId = H_IUnknown then
    begin
      L.Add(H_QueryInterface);
      L.Add(H_AddRef);
      L.Add(H_Release);
      break;
    end;

    for I:= IntfId + 1 to Card do
    begin
      R := Records[I];
      if R.Level = IntfId then
        if R.Kind = kindSUB then
          L.Add(I);
    end;
    if Records[IntfId].SupportedInterfaces = nil then
      break;
    if Records[IntfId].SupportedInterfaces.Count = 0 then
      break;

    IntfId := Records[IntfId].SupportedInterfaces[0].Id;

  until false;
end;

procedure TBaseSymbolTable.CreateInterfaceMethodList(ClassId, IntfId: Integer;
                                                     InterfaceMethodIds,
                                                     ClassMethodIds: TIntegerList);
var
  I, J, Id, MethodIndex: Integer;
  R, RR: TSymbolRec;
  Buff: array[1..1000] of Integer;
begin
  InterfaceMethodIds.Clear;
  ClassMethodIds.Clear;
  CreateInterfaceMethodList(IntfId, InterfaceMethodIds);
  FillChar(Buff, SizeOf(Buff), 0);

  repeat

    I := Card;
    while I > ClassId do
    begin
      R := Records[I];
      if R = SR0 then
      begin
        I := GlobalSymbolTable.Card;
        R := Records[I];
      end;

      if R.Level = ClassId then
        if R.Kind = kindSUB then
        begin
          for J := InterfaceMethodIds.Count - 1 downto 0 do
          begin
            RR := Records[InterfaceMethodIds[J]];
            if StrEql(R.Name, RR.Name) and StrEql(R.Signature, RR.Signature) then
            begin
              InterfaceMethodIds.RemoveAt(J);

              MethodIndex := RR.MethodIndex;

              Buff[MethodIndex] := I;

              R.PatternId := RR.Id;

              break;
            end;
          end;
        end;
      Dec(I);
    end;

    if Records[ClassId].AncestorId = 0 then
      break;

    if Records[ClassId].AncestorId = H_TObject then
      break;

    ClassId := Records[ClassId].AncestorId;

  until false;

  if InterfaceMethodIds.Count > 0 then
    Exit;

  for I:=1 to 1000 do
  begin
    Id := Buff[I];

    if Id = 0 then
      break;

    ClassMethodIds.Add(Id);
  end;
end;

procedure TBaseSymbolTable.ProcessClassFactory(AClassFactory: Pointer;
                                               AProg: Pointer);

  var
    ScriptClassList: TScriptClassList;

  procedure BuildScriptClassList;
  var
    I, LevelId: Integer;
    R: TSymbolRec;
    ScriptClassRec: TScriptClassRec;
  begin
    for I:=FirstLocalId + 1 to Card do
    begin
      R := Records[I];

      if R.ClassIndex <> -1 then
      begin
        if R.Host then
          continue;

        if ScriptClassList.FindClass(R.Id) = nil then
        begin
          ScriptClassRec := ScriptClassList.Add;
          ScriptClassRec.ClassId := R.Id;
          ScriptClassRec.PClass := R.PClass;
          ScriptClassRec.AncestorId := R.AncestorId;
          continue;
        end;
      end;

      if R.Kind in [kindSUB, kindCONSTRUCTOR] then
        if R.CallMode > 0 then
        begin
          LevelId := R.Level;

          if LevelId = 0 then
            continue;

          if Records[LevelId].Host then
            continue;

          ScriptClassRec := ScriptClassList.FindClass(LevelId);
          if ScriptClassRec = nil then
          begin
            ScriptClassRec := ScriptClassList.Add;
            ScriptClassRec.ClassId := LevelId;
            ScriptClassRec.PClass := Records[LevelId].PClass;
            ScriptClassRec.AncestorId := Records[LevelId].AncestorId;
          end;
          ScriptClassRec.VirtualMethodList.Add(R.Id);
        end;
    end;
  end;

var
  ClassFactory: TPaxClassFactory;
  ClassFactoryRec: TPaxClassFactoryRec;
  I, J, SubId, CallMode: Integer;
  R, RA, RR: TSymbolRec;
  C, CA: TClass;
  ScriptClassRec, AncestorScriptClassRec: TScriptClassRec;
  VirtualMethodList: TIntegerList;
  b: Boolean;
  P: PPointerArray;
  MethodIndex: Integer;
  Prog: TProgram;
  MapRec: TMapRec;
  Name, FullName, Signature: String;
  Address: Pointer;
  OverCount: Integer;
  II, JJ, temp: Integer;
  Found: Boolean;
  MR, SomeMR: TMapRec;
  FileName, ProcName: String;
begin
  ClassFactory := TPaxClassFactory(AClassFactory);
  Prog := TProgram(AProg);

  Prog.ForceMappingEvents;

  ClassFactory.SetupParents(Prog.ClassList);
  ClassFactory.AddInheritedMethods;

  ScriptClassList := TScriptClassList.Create;
  try
    BuildScriptClassList;

    repeat
      b := false;

      for I:=0 to ScriptClassList.Count - 1 do
      begin
        ScriptClassRec := ScriptClassList[I];
        if ScriptClassRec.Processed then
          continue;

        if Records[ScriptClassRec.AncestorId].Host then
        begin
          ScriptClassRec.Processed := true;
          b := true;
        end
        else
        begin
          AncestorScriptClassRec := ScriptClassList.FindClass(ScriptClassRec.AncestorId);
          if AncestorScriptClassRec.Processed then
          begin
            ScriptClassRec.Processed := true;
            b := true;
          end
          else
            continue;
        end;

        C := Records[ScriptClassRec.ClassId].PClass;
        P := PPointerArray(C);

        VirtualMethodList := ScriptClassRec.VirtualMethodList;
        for J:=0 to VirtualMethodList.Count - 1 do
        begin
          SubId := VirtualMethodList[J];
          CallMode := Records[SubId].CallMode;
          Name := Records[SubId].Name;
          FullName := Records[SubId].FullName;
          Signature := Records[SubId].Signature;
          OverCount := Records[SubId].OverCount;
          Address := Prog.GetAddressEx(FullName, OverCount, MR);

          if Address = nil then
          begin
            FileName := ExtractOwner(FullName) + '.' + PCU_FILE_EXT;
            ProcName := Copy(FullName, PosCh('.', FullName) + 1, Length(FullName));
            Address := Prog.RootProg.ProgList.LoadAddress(FileName, ProcName, false, OverCount, SomeMR);
          end;

          if CallMode = cmVIRTUAL then
          begin
            MethodIndex := VirtualMethodIndex(P, Address);
            if MethodIndex = -1 then
              MethodIndex := GetVirtualMethodCount(C) + 1
            else
              Inc(MethodIndex); // method index starts from 1, not 0

            Records[SubId].MethodIndex := MethodIndex;
            P^[MethodIndex - 1] := Address;

            MapRec := Prog.ScriptMapTable.LookupEx(FullName, OverCount);
            if MapRec <> nil then
              MapRec.SubDesc.MethodIndex := MethodIndex;

            for II:=0 to ScriptClassList.Count - 1 do
            begin
              CA := ScriptClassList[II].PClass;
              if CA.InheritsFrom(C) and (C <> CA) then
              begin
                Found := false;
                for JJ:=0 to ScriptClassList[II].VirtualMethodList.Count - 1 do
                begin
                  temp := ScriptClassList[II].VirtualMethodList[JJ];
                  RR := Records[temp];
                  if RR.MethodIndex = 0 then
                    if StrEql(Name, RR.Name) then
                      if StrEql(Signature, RR.Signature) then
                      begin
                        Found := true;

                        RR.MethodIndex := MethodIndex;
                        PPointerArray(CA)^[MethodIndex - 1] := Prog.GetAddress(RR.FullName, MR);

                        MapRec := Prog.ScriptMapTable.LookupEx(RR.FullName, RR.OverCount);
                        if MapRec <> nil then
                          MapRec.SubDesc.MethodIndex := MethodIndex;

                        break;
                      end;
                end;

                if not Found then
                  PPointerArray(CA)^[MethodIndex - 1] := Address;
              end;
            end;
          end;
        end;
      end;

      if b = false then
        break;

    until false;

    // process overriden methods

    ScriptClassList.Reset;

    repeat
      b := false;

      for I:=0 to ScriptClassList.Count - 1 do
      begin
        ScriptClassRec := ScriptClassList[I];
        if ScriptClassRec.Processed then
          continue;

        if Records[ScriptClassRec.AncestorId].Host then
        begin
          ScriptClassRec.Processed := true;
          b := true;
        end
        else
        begin
          AncestorScriptClassRec := ScriptClassList.FindClass(ScriptClassRec.AncestorId);
          if AncestorScriptClassRec.Processed then
          begin
            ScriptClassRec.Processed := true;
            b := true;
          end
          else
            continue;
        end;

        C := Records[ScriptClassRec.ClassId].PClass;
        P := PPointerArray(C);

        VirtualMethodList := ScriptClassRec.VirtualMethodList;
        for J:=0 to VirtualMethodList.Count - 1 do
        begin
          SubId := VirtualMethodList[J];
          CallMode := Records[SubId].CallMode;
          Name := Records[SubId].Name;
          FullName := Records[SubId].FullName;
          Signature := Records[SubId].Signature;
          OverCount := Records[SubId].OverCount;
          Address := Prog.GetAddress(FullName, MR);

          if CallMode = cmOVERRIDE then
          begin
            MethodIndex := Records[SubId].MethodIndex;
            if MethodIndex = 0 then
            begin
              temp := LookupParentMethod(SubId, true);
              if temp = 0 then
                RaiseError(errInternalError, []);
              if Records[temp].MethodIndex = 0 then
                RaiseError(errInternalError, []);
              MethodIndex := Records[temp].MethodIndex;
              Records[SubId].MethodIndex := MethodIndex;
            end;

            P^[MethodIndex - 1] := Address;

            MapRec := Prog.ScriptMapTable.LookupEx(FullName, OverCount);
            if MapRec <> nil then
              MapRec.SubDesc.MethodIndex := MethodIndex;

            for II:=0 to ScriptClassList.Count - 1 do
            begin
              CA := ScriptClassList[II].PClass;
              if CA.InheritsFrom(C) and (C <> CA) then
              begin
                Found := false;
                for JJ:=0 to ScriptClassList[II].VirtualMethodList.Count - 1 do
                begin
                  temp := ScriptClassList[II].VirtualMethodList[JJ];
                  RR := Records[temp];
                  if RR.MethodIndex = 0 then
                    if StrEql(Name, RR.Name) then
                      if StrEql(Signature, RR.Signature) then
                      begin
                        Found := true;
                        RR.MethodIndex := MethodIndex;
                        PPointerArray(CA)^[MethodIndex - 1] := Prog.GetAddress(RR.FullName, MR);

                        MapRec := Prog.ScriptMapTable.LookupEx(RR.FullName, RR.OverCount);
                        if MapRec <> nil then
                          MapRec.SubDesc.MethodIndex := MethodIndex;

                        break;
                      end;
                end;
                if not Found then
                  PPointerArray(CA)^[MethodIndex - 1] := Address;
              end;
            end;
          end;
        end;
      end;

      if b = false then
        break;

    until false;

  finally
    ScriptClassList.Free;
  end;
end;

procedure TBaseSymbolTable.RegisterSpace(K: Integer);
var
  I: Integer;
begin
  for I:=1 to K do AddRecord;
end;

procedure TBaseSymbolTable.HideClass(C: TClass);
var
  I: Integer;
  R: TSymbolRec;
begin
  for I := 1 to Card do
  begin
    R := Records[I];
    if R = SR0 then
      continue;
    if R.PClass <> nil then
      if R.PClass = C then
        if R.Kind = KindTYPE then
        begin
          R.Name := '@' + R.Name;
          Exit;
        end;
  end;
end;

end.
