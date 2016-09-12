////////////////////////////////////////////////////////////////////////////
// PaxCompiler
// Site: http://www.paxcompiler.com
// Author: Alexander Baranovsky (paxscript@gmail.com)
// ========================================================================
// Copyright (c) Alexander Baranovsky, 2006-2008. All rights reserved.
// Code Version: 2.4
// ========================================================================
// Unit: PAXCOMP_STDLIB.pas
// ========================================================================
////////////////////////////////////////////////////////////////////////////

{$I PaxCompiler.def}
{$O-}
{$R-}
unit PAXCOMP_STDLIB;
interface
{$I-}
uses
{$IFDEF LINUX}
{$IFDEF FPC}
   DynLibs,
{$ELSE}
  QForms,
{$ENDIF}
{$ELSE}
  Windows,
{$ENDIF}

{$IFDEF VARIANTS}
  Variants,
{$ENDIF}
  TypInfo,
  SysUtils,
  Classes,
  PAXCOMP_CONSTANTS,
  PAXCOMP_SYS,
  PAXCOMP_SYMBOL_REC,
  PAXCOMP_BASESYMBOL_TABLE,
  PAXCOMP_CLASSLST,
  PAXCOMP_TRYLST,
  PAXCOMP_EVENT,
  PAXCOMP_MAP,
  PAXCOMP_PAUSE;

type
  TPaxClassFactoryRec = class
  private
    PaxClassRec: TPaxClassRec;
    fClassName: ShortString;
    fParentClass: TClass;
    Processed: Boolean;
    function GetDelphiClass: TClass;
    function GetVMTPtr: PVMT;
  public
    pti_parent: PTypeInfo;
    MethodTableSize: Integer;
    FieldTableSize: Integer;
    FieldClassTable: PFieldClassTable;
    FullClassName: String;
    constructor Create(const AFullClassName: String);
    destructor Destroy; override;
    procedure SetInstanceSize(value: Integer);
    procedure SetParentClass(AClass: TClass);
    property DelphiClass: TClass read GetDelphiClass;
    property VMTPtr: PVMT read GetVMTPtr;
  end;

  TPaxClassFactory = class(TTypedList)
  private
    function GetRecord(I: Integer): TPaxClassFactoryRec;
    procedure Reset;
  public
    ForceCreate: Boolean;
    constructor Create;
    function CreatePaxClass(const AFullClassName: String;
                            AnInstanceSize: Integer;
                            ParentClass: TClass): TClass;
    function CreateCloneClass(const AFullClassName: String;
                              ParentClass: TClass): TClass;
    function FindRecord(AClass: TClass): TPaxClassFactoryRec;
    function FindRecordByFullName(const AFullClassName: String): TPaxClassFactoryRec;
    function LookupFullName(const AFullClassName: String): TClass;
    procedure SetupParents(ClassList: TClassList);
    procedure SetupStdVirtuals(ClassList: TClassList; CodePtr: Pointer);
    procedure AddInheritedMethods; overload;
    procedure AddInheritedMethods(SourceClass: TClass); overload;
    procedure AddOverridenMethods(AProg: Pointer; ScriptMapTable: TMapTable);
    procedure AddVirtualMethod(SourceClass: TClass;
                              SourceMethodAddress: Pointer);
    function AddOverridenMethod(SourceClass: TClass;
                                SourceMethodAddress,
                                InheritedMethodAddress: Pointer): Boolean;
    procedure RaiseError(const Message: string; params: array of Const);
    property Records[I: Integer]: TPaxClassFactoryRec read GetRecord; default;
  end;

  TScriptClassRec = class
  public
    ClassId: Integer;
    AncestorId: Integer;
    Processed: Boolean;
    PClass: TClass;
    VirtualMethodList: TIntegerList;
    constructor Create;
    destructor Destroy; override;
  end;

  TScriptClassList = class(TTypedList)
  private
    function GetRecord(I: Integer): TScriptClassRec;
  public
    procedure Reset;
    function Add: TScriptClassRec;
    function FindClass(ClassId: Integer): TScriptClassRec;
    property Records[I: Integer]: TScriptClassRec read GetRecord; default;
  end;

function GetVirtualMethodCount(AClass: TClass): Integer;
function GetVirtualMethod(AClass: TClass; const Index: Integer): Pointer;
function GetVirtualMethodOffset(AClass: TClass; Address: Pointer): Integer;

function VirtualMethodIndex(P: PPointerArray; A: Pointer): Integer;

var
  H_PascalNamespace: Integer;

  H_Writeln: Integer;
  H_WriteBool: Integer;
  H_WriteByteBool: Integer;
  H_WriteWordBool: Integer;
  H_WriteLongBool: Integer;
  H_WriteInteger: Integer;
  H_WriteInt64: Integer;
  H_WriteByte: Integer;
  H_WriteWord: Integer;
  H_WriteCardinal: Integer;
  H_WriteSmallInt: Integer;
  H_WriteShortInt: Integer;
  H_WriteAnsiString: Integer;
  H_WriteShortString: Integer;
  H_WriteAnsiChar: Integer;
  H_WriteWideChar: Integer;
  H_WriteWideString: Integer;
  H_WriteUnicString: Integer;
  H_WriteDouble: Integer;
  H_WriteSingle: Integer;
  H_WriteCurrency: Integer;
  H_WriteExtended: Integer;
  H_WriteVariant: Integer;
  H_WriteObject: Integer;
  H_TObject: Integer;
  H_TClass: Integer;
  H_TInterfacedObject: Integer;

  H_QueryInterface,
  H_AddRef,
  H_Release,

  H_TGUID: Integer;
  H_PGUID: Integer;
  H_IUnknown: Integer;
  H_IDispatch: Integer;

  H_TVarRec: Integer;
  H_PExtended: Integer;
  H_PShortString: Integer;
  H_PString: Integer;
  H_PVariant: Integer;
  H_Unassigned: Integer;

  H_TMethod: Integer;

  Id_CondHalt: Integer;

  Id_ToParentClass: Integer;
  Id_UpdateInstance: Integer;
  Id_DestroyInherited: Integer;

  ID_Prog: Integer;

  Id_WriteBool: Integer;
  Id_WriteByteBool: Integer;
  Id_WriteWordBool: Integer;
  Id_WriteLongBool: Integer;
  Id_WriteAnsiChar: Integer;
  Id_WriteByte: Integer;
  Id_WriteWord: Integer;
  Id_WriteCardinal: Integer;
  Id_WriteSmallInt: Integer;
  Id_WriteShortInt: Integer;
  Id_WriteInt: Integer;
  Id_WriteInt64: Integer;
  Id_WriteDouble: Integer;
  Id_WriteSingle: Integer;
  Id_WriteCurrency: Integer;
  Id_WriteExtended: Integer;
  Id_WriteString: Integer;
  Id_WriteShortString: Integer;
  Id_WriteWideChar: Integer;
  Id_WriteWideString: Integer;
  Id_WriteUnicString: Integer;
  Id_WriteVariant: Integer;
  Id_WriteObject: Integer;

  Id_PrintEx: Integer;

  Id_DynArrayLength: Integer;
  Id_AnsiStringLength: Integer;

  Id_SetStringLength: Integer;
  Id_SetWideStringLength: Integer;
  Id_SetUnicStringLength: Integer;
  Id_SetShortStringLength: Integer;

  Id_LoadProc: Integer;
  Id_LoadSeg: Integer;
  Id_LoadClassRef: Integer;

  Id_TypeInfo,

  Id_AnsiStringFromPAnsiChar: Integer;
  Id_AnsiStringFromPWideChar: Integer;
  Id_WideStringFromPAnsiChar: Integer;
  Id_WideStringFromPWideChar: Integer;
  Id_UnicStringFromPWideChar: Integer;
  Id_AnsiStringFromAnsiChar: Integer;
  Id_WideStringFromAnsiChar: Integer;
  Id_UnicStringFromAnsiChar: Integer;
  Id_WideStringFromWideChar: Integer;
  Id_UnicStringFromWideChar: Integer;
  Id_AnsiStringFromWideChar: Integer;

  Id_UnicStringFromPAnsiChar: Integer;

  Id_AnsiStringAssign: Integer;
  Id_AnsiStringAddition: Integer;
  Id_ShortStringAddition: Integer;
  Id_WideStringAddition: Integer;
  Id_UnicStringAddition: Integer;
  Id_ShortStringAssign: Integer;
  Id_WideStringAssign: Integer;
  Id_UnicStringAssign: Integer;
  Id_AnsiStringClr: Integer;
  Id_WideStringClr: Integer;
  Id_UnicStringClr: Integer;
  Id_InterfaceClr: Integer;
  Id_ClassClr: Integer = 0; 

  Id_StringAddRef: Integer;
  Id_WideStringAddRef: Integer;
  Id_UnicStringAddRef: Integer;
  Id_VariantAddRef: Integer;
  Id_DynarrayAddRef: Integer;
  Id_InterfaceAddRef: Integer;

  Id_ShortStringFromAnsiString: Integer;
  Id_ShortStringFromWideString: Integer;
  Id_ShortStringFromPWideChar: Integer;
  Id_ShortStringFromUnicString: Integer;
  Id_AnsiStringFromShortString: Integer;
  Id_UnicStringFromWideString: Integer;
  Id_WideStringFromShortString: Integer;
  Id_WideStringFromUnicString: Integer;
  Id_UnicStringFromShortString: Integer;
  Id_AnsiStringFromWideString: Integer;
  Id_AnsiStringFromUnicString: Integer;
  Id_WideStringFromAnsiString: Integer;
  Id_UnicStringFromAnsiString: Integer;
  Id_StrInt: Integer;
  Id_StrDouble: Integer;
  Id_StrSingle: Integer;
  Id_StrExtended: Integer;
  Id_DecStringCounter: Integer;
  Id_AnsiStringEquality: Integer;
  Id_AnsiStringNotEquality: Integer;
  Id_ShortStringEquality: Integer;
  Id_ShortStringNotEquality: Integer;
  Id_WideStringEquality: Integer;
  Id_UnicStringEquality: Integer;
  Id_WideStringNotEquality: Integer;
  Id_UnicStringNotEquality: Integer;
  Id_ShortstringHigh: Integer;
  Id_AnsiStringGreaterThan: Integer;
  Id_AnsiStringGreaterThanOrEqual: Integer;
  Id_AnsiStringLessThan: Integer;
  Id_AnsiStringLessThanOrEqual: Integer;
  Id_ShortStringGreaterThan: Integer;
  Id_ShortStringGreaterThanOrEqual: Integer;
  Id_ShortStringLessThan: Integer;
  Id_ShortStringLessThanOrEqual: Integer;
  Id_WideStringGreaterThan: Integer;
  Id_UnicStringGreaterThan: Integer;
  Id_WideStringGreaterThanOrEqual: Integer;
  Id_UnicStringGreaterThanOrEqual: Integer;
  Id_WideStringLessThan: Integer;
  Id_UnicStringLessThan: Integer;
  Id_WideStringLessThanOrEqual: Integer;
  Id_UnicStringLessThanOrEqual: Integer;
  Id_Int64Multiplication: Integer;
  Id_Int64Division: Integer;
  Id_Int64Modulo: Integer;
  Id_Int64LeftShift: Integer;
  Id_Int64RightShift: Integer;
  Id_Int64LessThan: Integer;
  Id_Int64LessThanOrEqual: Integer;
  Id_Int64GreaterThan: Integer;
  Id_Int64GreaterThanOrEqual: Integer;
  Id_Int64Equality: Integer;
  Id_Int64NotEquality: Integer;
  Id_Int64Abs: Integer;
  Id_VariantClr: Integer;
  Id_VariantAssign: Integer;
  Id_VariantFromPAnsiChar: Integer;
  Id_VariantFromPWideChar: Integer;
  Id_VariantFromInterface: Integer;

  Id_OleVariantAssign: Integer;

  Id_ClassAssign: Integer;

  Id_VariantFromClass: Integer; // JS only
  Id_VariantFromPointer: Integer; // JS only
  Id_ClassFromVariant: Integer; // JS only

  Id_InterfaceFromClass,
  Id_InterfaceCast,
  Id_InterfaceAssign,

  Id_VariantFromAnsiString: Integer;
  Id_VariantFromWideString: Integer;
  Id_VariantFromUnicString: Integer;
  Id_VariantFromShortString: Integer;
  Id_VariantFromAnsiChar: Integer;
  Id_VariantFromWideChar: Integer;
  Id_VariantFromInt: Integer;
  Id_VariantFromInt64: Integer;
  Id_VariantFromByte: Integer;
  Id_VariantFromBool: Integer;
  Id_VariantFromWord: Integer;
  Id_VariantFromCardinal: Integer;
  Id_VariantFromSmallInt: Integer;
  Id_VariantFromShortInt: Integer;
  Id_VariantFromDouble: Integer;
  Id_VariantFromCurrency: Integer;
  Id_VariantFromSingle: Integer;
  Id_VariantFromExtended: Integer;

  Id_AnsiStringFromInt: Integer; // JS only
  Id_AnsiStringFromDouble: Integer; // JS only
  Id_AnsiStringFromSingle: Integer; // JS only
  Id_AnsiStringFromExtended: Integer; // JS only
  Id_AnsiStringFromBoolean: Integer; // JS only

  Id_UnicStringFromInt: Integer; // JS only
  Id_UnicStringFromDouble: Integer; // JS only
  Id_UnicStringFromSingle: Integer; // JS only
  Id_UnicStringFromExtended: Integer; // JS only
  Id_UnicStringFromBoolean: Integer; // JS only

  Id_FuncObjFromVariant: Integer; // JS only

  Id_PushContext: Integer; // JS only
  Id_PopContext: Integer; // JS only
  Id_FindContext: Integer; // JS only

  Id_AnsiStringFromVariant: Integer;
  Id_WideStringFromVariant: Integer;
  Id_UnicStringFromVariant: Integer;
  Id_ShortStringFromVariant: Integer;
  Id_DoubleFromVariant: Integer;
  Id_CurrencyFromVariant: Integer;
  Id_SingleFromVariant: Integer;
  Id_ExtendedFromVariant: Integer;
  Id_IntFromVariant: Integer;
  Id_Int64FromVariant: Integer;
  Id_ByteFromVariant: Integer;
  Id_WordFromVariant: Integer;
  Id_CardinalFromVariant: Integer;
  Id_SmallIntFromVariant: Integer;
  Id_ShortIntFromVariant: Integer;
  Id_BoolFromVariant: Integer;
  Id_ByteBoolFromVariant: Integer;
  Id_WordBoolFromVariant: Integer;
  Id_LongBoolFromVariant: Integer;
  Id_VariantAddition: Integer;
  Id_VariantSubtraction: Integer;
  Id_VariantMultiplication: Integer;
  Id_VariantDivision: Integer;
  Id_VariantIDivision: Integer;
  Id_VariantModulo: Integer;
  Id_VariantLeftShift: Integer;
  Id_VariantRightShift: Integer;
  Id_VariantAnd: Integer;
  Id_VariantOr: Integer;
  Id_VariantXor: Integer;
  Id_VariantLessThan: Integer;
  Id_VariantLessThanOrEqual: Integer;
  Id_VariantGreaterThan: Integer;
  Id_VariantGreaterThanOrEqual: Integer;
  Id_VariantEquality: Integer;
  Id_VariantNotEquality: Integer;
  Id_StructEquality: Integer;
  Id_StructNotEquality: Integer;
  Id_VariantNegation: Integer;
  Id_VariantAbs: Integer;
  Id_VariantNot: Integer;
  Id_VarArrayGet1: Integer;
  Id_VarArrayPut1: Integer;
  Id_VarArrayGet2: Integer;
  Id_VarArrayPut2: Integer;
  Id_VarArrayGet3: Integer;
  Id_VarArrayPut3: Integer;
  Id_DynarrayClr: Integer;
  Id_DynarrayAssign: Integer;
  Id_CreateEmptyDynarray: Integer;

  Id_OleVariantFromVariant: Integer;
  Id_OleVariantFromPAnsiChar: Integer;
  Id_OleVariantFromPWideChar: Integer;
  Id_OleVariantFromAnsiString: Integer;
  Id_OleVariantFromWideString: Integer;
  Id_OleVariantFromUnicString: Integer;
  Id_OleVariantFromShortString: Integer;
  Id_OleVariantFromAnsiChar: Integer;
  Id_OleVariantFromWideChar: Integer;
  Id_OleVariantFromInt: Integer;
  Id_OleVariantFromInt64: Integer;
  Id_OleVariantFromByte: Integer;
  Id_OleVariantFromBool: Integer;
  Id_OleVariantFromWord: Integer;
  Id_OleVariantFromCardinal: Integer;
  Id_OleVariantFromSmallInt: Integer;
  Id_OleVariantFromShortInt: Integer;
  Id_OleVariantFromDouble: Integer;
  Id_OleVariantFromCurrency: Integer;
  Id_OleVariantFromSingle: Integer;
  Id_OleVariantFromExtended: Integer;
  Id_OleVariantFromInterface: Integer;

  Id_SetInclude: Integer;
  Id_SetIncludeInterval: Integer;
  Id_SetExclude: Integer;
  Id_SetUnion: Integer;
  Id_SetDifference: Integer;
  Id_SetIntersection: Integer;
  Id_SetSubset: Integer;
  Id_SetSuperset: Integer;
  Id_SetEquality: Integer;
  Id_SetInequality: Integer;
  Id_SetMembership: Integer;

  Id_ClassName: Integer;
  Id_OnCreateObject: Integer;
  Id_OnAfterObjectCreation: Integer;

  Id_GetAnsiStrProp: Integer;
  Id_SetAnsiStrProp: Integer;
  Id_GetWideStrProp: Integer;
  Id_SetWideStrProp: Integer;
  Id_GetUnicStrProp: Integer;
  Id_SetUnicStrProp: Integer;
  Id_GetOrdProp: Integer;
  Id_SetOrdProp: Integer;
  Id_GetInterfaceProp: Integer;
  Id_SetInterfaceProp: Integer;
  Id_GetSetProp: Integer;
  Id_SetSetProp: Integer;
  Id_GetFloatProp: Integer;
  Id_SetFloatProp: Integer;
  Id_GetVariantProp: Integer;
  Id_SetVariantProp: Integer;
  Id_GetInt64Prop: Integer;
  Id_SetInt64Prop: Integer;
  Id_GetEventProp: Integer;
  Id_SetEventProp: Integer;
  Id_SetEventProp2: Integer;
  Id_CreateMethod: Integer;

  Id_CreateObject: Integer;
  Id_DestroyObject: Integer;

  Id_TryOn: Integer;
  Id_TryOff: Integer;
  Id_Raise: Integer;
  Id_Exit: Integer;
  Id_CondRaise: Integer;
  Id_BeginExceptBlock: Integer;
  Id_EndExceptBlock: Integer;

  Id_GetClassByIndex: Integer;

  Id_CheckPause: Integer;
  Id_InitSub: Integer;
  Id_EndSub: Integer;

  Id_IntOver: Integer;
  Id_BoundError: Integer;

  Id_AssignTVarRec: Integer;
  Id_TObject_Destroy: Integer;

  Id_ErrAbstract: Integer;
  Id_RecordAssign: Integer;

  Id_TObject_Free: Integer;
  Id_TObject_GetInterface: Integer;

  CURR_FMUL_ID: Integer;

{$IFDEF TRIAL}
var strShowTrial: array[0..10] of Char;
{$ENDIF}
  GlobalSymbolTable: TBaseSymbolTable;

type
  TMyInterfacedObject = class(TInterfacedObject);

procedure _CreateObject(C: TClass;
                        var X: TObject); stdcall;
procedure _DestroyObject(Self: TObject; OuterMost: ShortInt);

procedure _SetAnsiStrProp(PropInfo: PPropInfo; Instance: TObject;
                      const value: AnsiString); stdcall;
procedure _SetWideStrProp(PropInfo: PPropInfo; Instance: TObject;
                      const value: WideString); stdcall;
procedure _SetUnicStrProp(PropInfo: PPropInfo; Instance: TObject;
                      const value: UnicString); stdcall;

procedure _WideStringFromPWideChar(source: PWideChar; var dest: WideString); stdcall;

implementation

uses
  PAXCOMP_PROG,
  PAXCOMP_TYPEINFO,
  Math;

{$IFDEF TRIAL}
procedure ShowTrial;
var a: array[0..50] of ansichar;
    b: array[0..20] of ansichar;
begin
  a[00] := 'T';
  a[01] := 'h';
  a[02] := 'i';
  a[03] := 's';
  a[04] := ' ';
  a[05] := 'i';
  a[06] := 's';
  a[07] := ' ';
  a[08] := 'a';
  a[09] := 'n';
  a[10] := ' ';
  a[11] := 'e';
  a[12] := 'v';
  a[13] := 'a';
  a[14] := 'l';
  a[15] := 'u';
  a[16] := 'a';
  a[17] := 't';
  a[18] := 'i';
  a[19] := 'o';
  a[20] := 'n';
  a[21] := ' ';
  a[22] := 'c';
  a[23] := 'o';
  a[24] := 'p';
  a[25] := 'y';
  a[26] := ' ';
  a[27] := 'o';
  a[28] := 'f';
  a[29] := ' ';
  a[30] := 'p';
  a[31] := 'a';
  a[32] := 'x';
  a[33] := 'C';
  a[34] := 'o';
  a[35] := 'm';
  a[36] := 'p';
  a[37] := 'i';
  a[38] := 'l';
  a[39] := 'e';
  a[40] := 'r';
  a[41] := '.';
  a[42] :=  #0;

  b[00] := 'p';
  b[01] := 'a';
  b[02] := 'x';
  b[03] := 'C';
  b[04] := 'o';
  b[05] := 'm';
  b[06] := 'p';
  b[07] := 'i';
  b[08] := 'l';
  b[09] := 'e';
  b[10] := 'r';
  b[11] := #0;

{$IFDEF LINUX}
{$IFDEF FPC}
// I will give you a better call for FPC/LINUX //
{$ELSE}
  Application.MessageBox(PChar(S), 'paxCompiler', [smbOK]);
{$ENDIF}
{$ELSE}
  MessageBox(GetActiveWindow(), PChar(String(a)), PChar(String(b)),
  MB_ICONEXCLAMATION or MB_OK);
{$ENDIF}

end;
{$ENDIF}

procedure _BeginSub;
begin
end;

procedure _Write;
begin
end;

procedure _Writeln;
begin
  writeln;
end;

procedure _WriteBool(value: Boolean);
begin
  write(value);
end;

procedure _WriteByteBool(value: ByteBool);
begin
  write(value);
end;

procedure _WriteWordBool(value: WordBool);
begin
  write(value);
end;

procedure _WriteLongBool(value: LongBool);
begin
  write(value);
end;

procedure _WriteAnsiChar(value: AnsiChar);
begin
  write(value);
end;

{$IFDEF VARIANTS}
procedure _WriteWideChar(value: WideChar);
begin
  write(value);
end;
{$ELSE}
procedure _WriteWideChar(value: WideChar);
var
  S: AnsiString;
begin
  S := value;
  write(S);
end;
{$ENDIF}

procedure _WriteByte(value: Byte; L: Integer);
begin
  if L = 0 then
    write(value)
  else
    write(value:L);
end;

procedure _WriteWord(value: Word; L: Integer);
begin
  if L = 0 then
    write(value)
  else
    write(value:L);
end;

procedure _WriteCardinal(value: Cardinal; L: Integer);
begin
  if L = 0 then
    write(value)
  else
    write(value:L);
end;

procedure _WriteSmallInt(value: SmallInt; L: Integer);
begin
  if L = 0 then
    write(value)
  else
    write(value:L);
end;

procedure _WriteShortInt(value: ShortInt; L: Integer);
begin
  if L = 0 then
    write(value)
  else
    write(value:L);
end;

procedure _WriteInt(value: Integer; L: Integer);
begin
  if L = 0 then
    write(value)
  else
    write(value:L);
end;

procedure _WriteInt64(value: Int64; L: Integer);
begin
  if L = 0 then
    write(value)
  else
    write(value:L);
end;

procedure _WriteDouble(value: Double; L1, L2: Integer);
begin
  if L1 > 0 then
  begin
    if L2 > 0 then
      write(value:L1:L2)
    else
      write(value:L1);
  end
  else
    write(value);
end;

procedure _WriteSingle(value: Single; L1, L2: Integer);
begin
  if L1 > 0 then
  begin
    if L2 > 0 then
      write(value:L1:L2)
    else
      write(value:L1);
  end
  else
    write(value);
end;

procedure _WriteCurrency(value: Currency; L1, L2: Integer);
begin
  if L1 > 0 then
  begin
    if L2 > 0 then
      write(value:L1:L2)
    else
      write(value:L1);
  end
  else
    write(value);
end;

procedure _WriteExtended(value: Extended; L1, L2: Integer);
begin
  if L1 > 0 then
  begin
    if L2 > 0 then
      write(value:L1:L2)
    else
      write(value:L1);
  end
  else
    write(value);
end;

procedure _WriteString(const value: AnsiString; L: Integer);
begin
  if L = 0 then
    write(value)
  else
    write(value:L);
end;

procedure _WriteShortString(const value: ShortString; L: Integer);
begin
  if L = 0 then
    write(value)
  else
    write(value:L);
end;

{$IFDEF VARIANTS}
procedure _WriteWideString(const value: WideString; L: Integer);
begin
  if L = 0 then
    write(value)
  else
    write(value:L);
end;
{$ELSE}
procedure _WriteWideString(const value: WideString; L: Integer);
var
  S: AnsiString;
begin
  S := value;
  if L = 0 then
    write(S)
  else
    write(S:L);
end;
{$ENDIF}

{$IFDEF VARIANTS}
procedure _WriteUnicString(const value: UnicString; L: Integer);
begin
  if L = 0 then
    write(value)
  else
    write(value:L);
end;
{$ELSE}
procedure _WriteUnicString(const value: UnicString; L: Integer);
var
  S: AnsiString;
begin
  S := value;
  if L = 0 then
    write(S)
  else
    write(S:L);
end;
{$ENDIF}

procedure _WriteVariant(const value: Variant; L1, L2: Integer);
var
  S1: ShortString;
  S2: String;
begin
  if L1 > 0 then
  begin
{$IFDEF FPC}
    S1 := VarToStr(value);
{$ELSE}
    if L2 > 0 then
      STR(value:L1:L2, S1)
    else
      STR(value:L1, S1);
    write(S1);
{$ENDIF}
  end
  else
  begin
    if VarType(value) = varEmpty then
      S2 := 'undefined'
    else
      S2 := VarToStr(value);
    write(S2);
  end;
end;

procedure _WriteObject(const value: TObject);
begin
  write('[' + value.ClassName + ']');
end;

procedure _PrintEx(P: TProgram; Address: Pointer; Kind: Integer; FT: Integer; L1, L2: Integer); stdcall;
var
  S: String;
  S2: ShortString;
label
  ByRef;
begin
  if Kind = KindCONST then
  begin
    if FT in UnsignedIntegerTypes then
    begin
      if L1 > 0 then
        STR(Cardinal(Address):L1, S2)
      else
        STR(Cardinal(Address), S2);
       S := String(S2);
    end
    else if FT in OrdinalTypes then
    begin
      if L1 > 0 then
        STR(Integer(Address):L1, S2)
      else
        STR(Integer(Address), S2);
       S := String(S2);
    end
    else if FT = typeANSICHAR then
    begin
      S := String(AnsiChar(Byte(Address)));
    end
    else if FT = typePANSICHAR then
    begin
      S := String(StrPas(PAnsiChar(Address)));
    end
    else if FT = typeANSICHAR then
    begin
      S := String(AnsiChar(Byte(Address)));
    end
    else if FT = typeWIDECHAR then
    begin
      S := String(WideChar(Word(Address)));
    end
    else if FT = typePWIDECHAR then
    begin
      S := WideString(PWideChar(Address));
    end
    else
      goto ByRef;
  end
  else // Kind = KindVAR
  begin

ByRef:

    case FT of
      typeBOOLEAN: if Boolean(Address^) then
                     S := 'true'
                   else
                     S := 'false';
      typeBYTE, typeENUM:
      begin
        if L1 > 0 then
          STR(Byte(Address^):L1, S2)
        else
          STR(Byte(Address^), S2);
        S := String(S2);
      end;
      typeANSICHAR: S := String(AnsiChar(Address^));
      typeANSISTRING:
        begin
          S := String(AnsiString(Address^));
          while Length(S) < L1 do
            S := S + ' ';
        end;
      typeUNICSTRING:
        begin
          S := String(UnicString(Address^));
          while Length(S) < L1 do
            S := S + ' ';
        end;
      typeWORD:
      begin
        if L1 > 0 then
          STR(Word(Address^):L1, S2)
        else
          STR(Word(Address^), S2);
        S := String(S2);
      end;
      typeINTEGER:
      begin
        if L1 > 0 then
          STR(Integer(Address^):L1, S2)
        else
          STR(Integer(Address^), S2);
        S := String(S2);
      end;
      typeDOUBLE:
      begin
        if (L1 > 0) and (L2 > 0) then
          STR(Double(Address^):L1:L2, S2)
        else if L1 > 0 then
          STR(Double(Address^):L1, S2)
        else
          STR(Double(Address^), S2);
        S := String(S2);
      end;
      typePOINTER: S := Format('%x', [Cardinal(Address^)]);
      typeRECORD: S := '[record]';
      typeARRAY: S := '[array]';
      typePROC: S := '[proc]';
      typeSET: S := '[set]';
      typeSHORTSTRING:
        begin
          S := String(ShortString(Address^));
          while Length(S) < L1 do
            S := S + ' ';
        end;
      typeSINGLE:
      begin
        if (L1 > 0) and (L2 > 0) then
          STR(Single(Address^):L1:L2, S2)
        else if L1 > 0 then
          STR(Single(Address^):L1, S2)
        else
          STR(Single(Address^), S2);
         S := String(S2);
      end;
      typeEXTENDED:
      begin
        if (L1 > 0) and (L2 > 0) then
          STR(Extended(Address^):L1:L2, S2)
        else if L1 > 0 then
          STR(Extended(Address^):L1, S2)
        else
          STR(Extended(Address^), S2);
         S := String(S2);
      end;
      typeCLASS:
        if Integer(Address^) = 0 then
          S := 'nil'
        else
          S := '[Object: ' + TObject(Address^).ClassName + ']';
      typeCLASSREF:
        if Integer(Address^) = 0 then
          S := 'nil'
        else
          S := '[Class ref: ' + TClass(Address^).ClassName + ']';
      typeWIDECHAR: S := WideChar(Address^);
      typeWIDESTRING: S := WideString(Address^);
      typeVARIANT, typeOLEVARIANT:
      begin
        if (L1 > 0) and (L2 > 0) then
        begin
          {$IFDEF FPC}
          S2 := VarToStr(Variant(Address^));           
          {$ELSE}
          STR(Variant(Address^):L1:L2, S2);
          {$ENDIF}
          S := String(S2);
        end
        else if L1 > 0 then
        begin
          {$IFDEF FPC}
          S2 := VarToStr(Variant(Address^)); 
          {$ELSE}
          STR(Variant(Address^):L1, S2);
          {$ENDIF}
          S := String(S2);
        end
        else
          S := VarToStr(Variant(Address^));
      end;
      typeDYNARRAY: S := '[dynarray]';
      typeINT64:
      begin
        if L1 > 0 then
          STR(Int64(Address^):L1, S2)
        else
          STR(Int64(Address^), S2);
        S := String(S2);
      end;
      typeINTERFACE: S := '[interface]';
      typeCARDINAL:
      begin
        if L1 > 0 then
          STR(Cardinal(Address^):L1, S2)
        else
          STR(Cardinal(Address^), S2);
        S := String(S2);
      end;
      typeEVENT: S := '[event]';
      typeCURRENCY:
      begin
        if (L1 > 0) and (L2 > 0) then
          STR(Currency(Address^):L1:L2, S2)
        else if L1 > 0 then
          STR(Currency(Address^):L1, S2)
        else
          STR(Currency(Address^), S2);
        S := String(S2);
      end;
      typeSMALLINT:
      begin
        if L1 > 0 then
          STR(SmallInt(Address^):L1, S2)
        else
          STR(SmallInt(Address^), S2);
        S := String(S2);
      end;
      typeSHORTINT:
      begin
        if L1 > 0 then
          STR(ShortInt(Address^):L1, S2)
        else
          STR(ShortInt(Address^), S2);
        S := String(S2);
      end;
      typeWORDBOOL: if WordBool(Address^) then
                      S := 'true'
                    else
                      S := 'false';
      typeLONGBOOL: if LongBool(Address^) then
                      S := 'true'
                    else
                      S := 'false';
      typeBYTEBOOL: if ByteBool(Address^) then
                      S := 'true'
                    else
                      S := 'false';
    else
      S := '';
    end;
  end;

  if Assigned(P.OnPrint) then
  begin
    P.OnPrint(P.Owner, S);
    Exit;
  end;

{$IFDEF CONSOLE}
  write(S);
  Exit;
{$ENDIF}
{$IFDEF LINUX}
  Application.MessageBox(PChar(S), 'paxCompiler', [smbOK]);
{$ELSE}
  MessageBox(GetActiveWindow(), PChar(S), PChar('paxCompiler'), MB_ICONEXCLAMATION or MB_OK);
{$ENDIF}
end;

procedure _GetMem(var P: Pointer; Size: Integer);
begin
  GetMem(P, Size);
end;

procedure _FreeMem(P: Pointer; Size: Integer);
begin
  FreeMem(P, Size);
end;

// -------- ORDINAL FUNCTIONS --------------------------------------------------

function _Odd(X: Integer): Boolean;
begin
  result := Odd(X);
end;

//--------- SET ROUTINES ------------------------------------------------------

type
  TSetBytes = array[1..SizeOf(TByteSet)] of Byte;

function UpdateSet(const S: TByteSet; L: Integer): TByteSet;
var
  I: Integer;
begin
  FillChar(result, SizeOf(result), 0);
  for I := 1 to L do
    TSetBytes(result)[I] := TSetBytes(S)[I];
end;

procedure _SetInclude(var S: TByteSet; value: Integer); stdcall;
begin
  Include(S, value);
end;

procedure _SetIncludeInterval(var S: TByteSet; B1, B2: Integer); stdcall;
var
  value: Integer;
begin
  for value:=B1 to B2 do
    Include(S, value);
end;

procedure _SetExclude(var S: TByteSet; value: Integer); stdcall;
begin
  Exclude(S, value);
end;

procedure _SetUnion(var S1: TByteSet; var S2: TByteSet;
                    var R: TByteSet;
                    SZ1, SZ2: Integer); stdcall;
var
  L: Integer;
  Res: TByteSet;
begin
  if SZ2 < SZ1 then
    L := SZ2
  else
    L := SZ1;
  Res := UpdateSet(S1, L) + UpdateSet(S2, L);
  Move(Res, R, L);
end;

procedure _SetDifference(var S1: TByteSet; var S2: TByteSet;
                         var R: TByteSet;
                         SZ1, SZ2: Integer); stdcall;
var
  L: Integer;
  Res: TByteSet;
begin
  if SZ2 < SZ1 then
    L := SZ2
  else
    L := SZ1;
  Res := UpdateSet(S1, L) - UpdateSet(S2, L);
  Move(Res, R, L);
end;

procedure _SetIntersection(var S1: TByteSet; var S2: TByteSet;
                           var R: TByteSet;
                           SZ1, SZ2: Integer); stdcall;
var
  L: Integer;
  Res: TByteSet;
begin
  if SZ2 < SZ1 then
    L := SZ2
  else
    L := SZ1;
  Res := UpdateSet(S1, L) * UpdateSet(S2, L);
  Move(Res, R, L);
end;

function _SetSubset(var S1: TByteSet; var S2: TByteSet;
                    SZ1, SZ2: Integer): Boolean; stdcall;
var
  L: Integer;
begin
  if SZ2 < SZ1 then
    L := SZ2
  else
    L := SZ1;
  result := UpdateSet(S1, L) <= UpdateSet(S2, L);
end;

function _SetSuperset(var S1: TByteSet; var S2: TByteSet;
                      SZ1, SZ2: Integer): Boolean; stdcall;
var
  L: Integer;
begin
  if SZ2 < SZ1 then
    L := SZ2
  else
    L := SZ1;
  result := UpdateSet(S1, L) >= UpdateSet(S2, L);
end;

function _SetEquality(const S1: TByteSet; const S2: TByteSet;
                      SZ1, SZ2: Integer): Boolean; stdcall;
var
  L, I: Integer;
begin
  if SZ2 < SZ1 then
    L := SZ2
  else
    L := SZ1;
  result := true;
  for I := 1 to L do
    if TSetBytes(S1)[I] <> TSetBytes(S2)[I] then
    begin
      result := false;
      Exit;
    end;
end;

function _SetInequality(const S1: TByteSet; const S2: TByteSet;
                      SZ1, SZ2: Integer): Boolean; stdcall;
var
  L, I: Integer;
begin
  if SZ2 < SZ1 then
    L := SZ2
  else
    L := SZ1;
  result := false;
  for I := 1 to L do
    if TSetBytes(S1)[I] <> TSetBytes(S2)[I] then
    begin
      result := true;
      Exit;
    end;
end;

function _SetMembership(I: Integer; var S: TByteSet): Boolean; stdcall;
begin
  result := I in S;
end;

//--------- AnsiString ROUTINES ----------------------------------------------------

type
  PStringRec = ^TStringRec;
  TStringRec = packed record
    RefCount: Longint;
    Length: Longint;
  end;

procedure _DecStringCounter(var S: AnsiString);
var
  P: PStringRec;
  D: Pointer;
begin
  D := Pointer(S);
  if D <> nil then
  begin
    P := PStringRec(Integer(D) - sizeof(TStringRec));
    if P^.RefCount > 0 then
      if InterlockedDecrement(P^.refCount) = 0 then
        FreeMem(P);
  end;
end;

procedure RestoreESI_EDI; assembler;
asm
  pop esi
  pop edi
end;

procedure _LoadClassRef(P: TProgram;
                        C: TClass); stdcall;
begin
  P.RootProg.PassedClassRef := C;
end;

procedure _LoadSeg(P: TProgram;
                   FullProcName: PChar); stdcall;
var
  S: String;
  I: Integer;
  CurrProg: TProgram;
  MR: TMapRec;
  Code, Data: Pointer;
begin
  S := FullProcName;
  P := P.RootProg;
  for I := 0 to P.ProgList.Count - 1 do
  begin
    CurrProg := TProgram(P.ProgList[I].Prog);
    if CurrProg.GetAddress(S, MR) <> nil then
    begin
      Code := CurrProg.CodePtr;
      Data := CurrProg.DataPtr;
      asm
        push Code
        push Data
        call RestoreESI_EDI
      end;
    end;
  end;
end;

procedure _LoadProc(P: TProgram;
      ProcHandle: Integer; ProcName: PChar; DllName: PChar;
      OverCount: Integer); stdcall;
var
  H: THandle;
  Address: Pointer;
  I: Integer;
  Ext: String;
  MR: TMapRec;
label
  ProcessDll;
begin
  Address := nil;

  Ext := ExtractFileExt(DllName);
  if StrEql(Ext, '.' + PCU_FILE_EXT) then
  begin
    Address := P.RootProg.ProgList.LoadAddress(DllName, ProcName, true, OverCount, MR);
    if Address = nil then
    begin
      if MR <> nil then
        if MR.SubDesc.DllName <> '' then
        begin
          DllName := PChar(MR.SubDesc.DllName);
          ProcName := PChar(MR.SubDesc.AliasName);
          goto ProcessDll;
        end;

      raise Exception.Create(Format(errProcNotFoundInPCU,
        [String(ProcName), String(DllName)]));
    end;

    P.SetAddress(ProcHandle, Address);

    Exit;
  end;

ProcessDll:

  if Assigned(P.OnLoadProc) then
  begin
    P.OnLoadProc(P.Owner, ProcName, DllName, Address);
    if Address <> nil then
    begin
      P.SetAddress(ProcHandle, Address);
      Exit;
    end;
  end;

  I := P.DllList.IndexOf(DllName);
  if I = - 1 then
  begin
    {$IFDEF LINUX}
    H := HMODULE(dynlibs.LoadLibrary(DLLName));
    Address := dynlibs.GetProcedureAddress(H, ProcName);
    {$ELSE}
    H := LoadLibrary(DllName);
    Address := GetProcAddress(H, ProcName);
    {$ENDIF}
    if Address <> nil then
      P.DllList.AddObject(DllName, TObject(H));
  end
  else
  begin
    H := Cardinal(P.DllList.Objects[I]);
   {$IFDEF LINUX}
    Address := dynlibs.GetProcedureAddress(H, ProcName);
    {$ELSE}
    Address := GetProcAddress(H, PChar(ProcName));
    {$ENDIF}
  end;

 if H = 0 then
   raise Exception.Create(Format(errDllNotFound, [String(DllName)]));

 if Address = nil then
   raise Exception.Create(Format(errProcNotFound,
     [String(ProcName), String(DllName)]));

 P.SetAddress(ProcHandle, Address);
end;

procedure _AnsiStringFromPAnsiChar(source: PAnsiChar; var dest: AnsiString); stdcall;
begin
  dest := source;
end;

procedure _AnsiStringFromPWideChar(source: PWideChar; var dest: AnsiString); stdcall;
begin
  dest := AnsiString(WideString(source));
end;

procedure _WideStringFromPAnsiChar(source: PAnsiChar; var dest: WideString); stdcall;
begin
  dest := WideString(AnsiString(source));
end;

procedure _UnicStringFromPAnsiChar(source: PAnsiChar; var dest: UnicString); stdcall;
begin
  dest := String(AnsiString(source));
end;

procedure _WideStringFromPWideChar(source: PWideChar; var dest: WideString); stdcall;
var
  P: Pointer;
  I, L: Integer;
begin
  P := ShiftPointer(source, - 4);
  L := Integer(P^) div 2;

  P := Source;

  Dest := '';

  for I:= 1 to L do
  begin
    dest := dest + WideChar(P^);
    Inc(Integer(P), 2);
  end;
end;

procedure _UnicStringFromPWideChar(source: PWideChar; var dest: UnicString); stdcall;
var
  P: Pointer;
  I, L: Integer;
begin
  P := ShiftPointer(source, - 4);
  L := Integer(P^) div 2;

  P := Source;

  Dest := '';

  for I:= 1 to L do
  begin
    dest := dest + WideChar(P^);
    Inc(Integer(P), 2);
  end;
end;

procedure _AnsiStringFromAnsiChar(source: AnsiChar; var dest: AnsiString); stdcall;
begin
  dest := source;
end;

procedure _WideStringFromAnsiChar(source: AnsiChar; var dest: WideString); stdcall;
begin
  dest := WideString(source);
end;

procedure _UnicStringFromAnsiChar(source: AnsiChar; var dest: UnicString); stdcall;
begin
  dest := UnicString(source);
end;

procedure _WideStringFromWideChar(source: WideChar; var dest: WideString);
stdcall;
begin
  dest := source;
end;

procedure _UnicStringFromWideChar(source: WideChar; var dest: UnicString);
stdcall;
begin
  dest := source;
end;

procedure _AnsiStringFromWideChar(source: WideChar; var dest: AnsiString);
stdcall;
begin
  dest := AnsiString(source);
end;

procedure _AnsiStringAssign(var source: AnsiString; var dest: AnsiString); stdcall;
begin
  dest := source;
end;

procedure _WideStringAssign(var source: WideString; var dest: WideString);
stdcall;
begin
  dest := source;
end;

procedure _UnicStringAssign(var source: UnicString; var dest: UnicString);
stdcall;
begin
  dest := source;
end;

procedure _ShortStringAssign(const source: ShortString; var dest: ShortString);
stdcall;
begin
  dest := source;
end;

procedure _ShortStringFromAnsiString(var Dest: ShortString; var Source: AnsiString);
stdcall;
begin
  Dest := Source;
end;

procedure _ShortStringFromWideString(var Dest: ShortString; var Source: WideString);
stdcall;
begin
  Dest := ShortString(Source);
end;

procedure _ShortStringFromPWideChar(var Dest: ShortString; Source: PWideChar);
stdcall;
begin
  Dest := ShortString(WideString(Source));
end;

procedure _ShortStringFromUnicString(var Dest: ShortString; var Source: UnicString);
stdcall;
begin
  Dest := ShortString(Source);
end;

procedure _AnsiStringFromShortString(var Dest: AnsiString; Source: ShortString); stdcall;
begin
  Dest := Source;
end;

procedure _UnicStringFromWideString(var Dest: UnicString; var Source: WideString); stdcall;
begin
  Dest := Source;
end;

procedure _WideStringFromShortString(var Dest: WideString; Source: ShortString);
stdcall;
begin
  Dest := WideString(Source);
end;

procedure _WideStringFromUnicString(var Dest: WideString; var Source: UnicString);
stdcall;
begin
  Dest := Source;
end;

procedure _UnicStringFromShortString(var Dest: UnicString; Source: ShortString);
stdcall;
begin
  Dest := UnicString(Source);
end;

procedure _AnsiStringFromWideString(var Dest: AnsiString; var Source: WideString);
stdcall;
begin
  Dest := AnsiString(Source);
end;

procedure _AnsiStringFromUnicString(var Dest: AnsiString; var Source: UnicString);
stdcall;
begin
  Dest := AnsiString(Source);
end;

procedure _WideStringFromAnsiString(var Dest: WideString; var Source: AnsiString);
stdcall;
begin
  Dest := WideString(Source);
end;

procedure _UnicStringFromAnsiString(var Dest: UnicString; var Source: AnsiString);
stdcall;
begin
  Dest := UnicString(Source);
end;

procedure _AnsiStringAddition(var s1: AnsiString; var s2: AnsiString; var dest: AnsiString);
stdcall;
begin
  dest := s1 + s2;
end;

procedure _ShortStringAddition(const s1, s2: ShortString; dest: ShortString);
stdcall;
begin
  dest := s1 + s2;
end;

procedure _WideStringAddition(var s1: WideString; var s2: WideString;
                              var dest: WideString); stdcall;
begin
  dest := s1 + s2;
end;

procedure _UnicStringAddition(var s1: UnicString; var s2: UnicString;
                              var dest: UnicString); stdcall;
begin
  dest := s1 + s2;
end;

procedure _AnsiStringEquality(var s1: AnsiString; var s2: AnsiString; var dest: Boolean);
stdcall;
begin
  dest := s1 = s2;
end;

procedure _AnsiStringNotEquality(var s1: AnsiString; var s2: AnsiString; var dest: Boolean);
stdcall;
begin
  dest := s1 <> s2;
end;

procedure _ShortStringEquality(const s1: ShortString; const s2: ShortString;
                               var dest: Boolean); stdcall;
begin
  dest := s1 = s2;
end;

procedure _ShortStringNotEquality(const s1: ShortString; const s2: ShortString;
                                  var dest: Boolean); stdcall;
begin
  dest := s1 <> s2;
end;

procedure _WideStringEquality(var s1: WideString; var s2: WideString;
                              var dest: Boolean); stdcall;
begin
  dest := s1 = s2;
end;

procedure _UnicStringEquality(var s1: UnicString; var s2: UnicString;
                              var dest: Boolean); stdcall;
begin
  dest := s1 = s2;
end;

procedure _WideStringNotEquality(var s1: WideString; var s2: WideString;
                                 var dest: Boolean); stdcall;
begin
  dest := s1 <> s2;
end;

procedure _UnicStringNotEquality(var s1: UnicString; var s2: UnicString;
                                 var dest: Boolean); stdcall;
begin
  dest := s1 <> s2;
end;

procedure _AnsiStringGreaterThan(var s1: AnsiString; var s2: AnsiString; var dest: Boolean);
stdcall;
begin
  dest := s1 > s2;
end;

procedure _AnsiStringGreaterThanOrEqual(var s1: AnsiString; var s2: AnsiString;
                                    var dest: Boolean); stdcall;
begin
  dest := s1 >= s2;
end;

procedure _AnsiStringLessThan(var s1: AnsiString; var s2: AnsiString; var dest: Boolean);
stdcall;
begin
  dest := s1 < s2;
end;

procedure _AnsiStringLessThanOrEqual(var s1: AnsiString; var s2: AnsiString;
                                 var dest: Boolean); stdcall;
begin
  dest := s1 <= s2;
end;

procedure _ShortStringGreaterThan(const s1: ShortString; const s2: ShortString;
                                  var dest: Boolean);
stdcall;
begin
  dest := s1 > s2;
end;

procedure _ShortStringGreaterThanOrEqual(const s1: ShortString;
                               const s2: ShortString; var dest: Boolean); stdcall;
begin
  dest := s1 >= s2;
end;

procedure _ShortStringLessThan(const s1: ShortString; const s2: ShortString;
                               var dest: Boolean); stdcall;
begin
  dest := s1 < s2;
end;

procedure _ShortStringLessThanOrEqual(const s1: ShortString; const s2: ShortString;
                                 var dest: Boolean); stdcall;
begin
  dest := s1 <= s2;
end;

procedure _WideStringGreaterThan(var s1: WideString; var s2: WideString;
                                                    var dest: Boolean); stdcall;
begin
  dest := s1 > s2;
end;

procedure _UnicStringGreaterThan(var s1: UnicString; var s2: UnicString;
                                 var dest: Boolean); stdcall;
begin
  dest := s1 > s2;
end;

procedure _WideStringGreaterThanOrEqual(var s1: WideString; var s2: WideString;
                                                    var dest: Boolean); stdcall;
begin
  dest := s1 >= s2;
end;

procedure _UnicStringGreaterThanOrEqual(var s1: UnicString; var s2: UnicString;
                                                    var dest: Boolean); stdcall;
begin
  dest := s1 >= s2;
end;

procedure _WideStringLessThan(var s1: WideString; var s2: WideString;
                              var dest: Boolean);stdcall;
begin
  dest := s1 < s2;
end;

procedure _UnicStringLessThan(var s1: UnicString; var s2: UnicString;
                              var dest: Boolean);stdcall;
begin
  dest := s1 < s2;
end;

procedure _WideStringLessThanOrEqual(var s1: WideString; var s2: WideString;
                                 var dest: Boolean); stdcall;
begin
  dest := s1 <= s2;
end;

procedure _UnicStringLessThanOrEqual(var s1: UnicString; var s2: UnicString;
                                 var dest: Boolean); stdcall;
begin
  dest := s1 <= s2;
end;

//////////////

procedure _SetStringLength(var S: AnsiString; L: Integer); stdcall;
begin
  SetLength(S, L);
end;

procedure _SetShortStringLength(var S: ShortString; L: Integer); stdcall;
begin
  SetLength(S, L);
end;

procedure _SetWideStringLength(var S: WideString; L: Integer); stdcall;
begin
  SetLength(S, L);
end;

procedure _SetUnicStringLength(var S: UnicString; L: Integer); stdcall;
begin
  SetLength(S, L);
end;

procedure _AnsiStringClr(var S: AnsiString); stdcall;
begin
  S := '';
end;

procedure _WideStringClr(var S: WideString); stdcall;
begin
  S := '';
end;

procedure _UnicStringClr(var S: UnicString); stdcall;
begin
  S := '';
end;

procedure _InterfaceClr(var I: IUnknown); stdcall;
begin
  I := nil;
end;

function _LengthString(const S: AnsiString): Integer;
begin
  result := Length(S);
end;

function _LengthShortString(const S: ShortString): Integer;
begin
  result := Length(S);
end;

function _LengthWideString(const S: WideString): Integer;
begin
  result := Length(S);
end;

function _Copy(const S: AnsiString; Index, Count:Integer): AnsiString;
begin
  result := Copy(S, Index, Count);
end;

procedure _Insert(Source: AnsiString; var S: AnsiString; Index: Integer);
begin
  Insert(Source, S, Index);
end;

function _PosString(const Substr: AnsiString; const S: AnsiString): Integer;
begin
  result := Pos(Substr, S);
end;

function _PosChar(c: AnsiChar; const S: AnsiString): Integer;
var
  I: Integer;
begin
  for I:=1 to Length(s) do
    if s[I] = c then
    begin
      result := I;
      Exit;
    end;
  result := -1;
end;

procedure _StrInt(var S: AnsiString; L1, L2: Integer; value: Integer); stdcall;
begin
  if L1 > 0 then
    Str(value:L1, S)
  else
    Str(value, S);
end;

procedure _StrDouble(var S: AnsiString; L2, L1: Integer; value: Double); stdcall;
begin
  if L1 > 0 then
  begin
    if L2 > 0 then
      Str(value:L1:L2, S)
    else
      Str(value:L1, S);
  end
  else
    Str(value, S);
end;

procedure _StrSingle(var S: AnsiString; L2, L1: Integer; value: Single); stdcall;
begin
  if L1 > 0 then
  begin
    if L2 > 0 then
      Str(value:L1:L2, S)
    else
      Str(value:L1, S);
  end
  else
    Str(value, S);
end;

procedure _StrExtended(var S: AnsiString; L2, L1: Integer; value: Extended); stdcall;
begin
  if L1 > 0 then
  begin
    if L2 > 0 then
      Str(value:L1:L2, S)
    else
      Str(value:L1, S);
  end
  else
    Str(value, S);
end;

procedure _ValInt(const S: String; var V: Integer; var Code: Integer);
begin
  Val(S, V, Code);
end;

procedure _ValDouble(const S: String; var V: Double; var Code: Integer);
begin
  Val(S, V, Code);
end;

procedure _ShortstringHigh(const P: Shortstring; var result: Integer); stdcall;
begin
  result := Length(P) - 1;
end;

procedure _Delete(var S: AnsiString; Index, Count:Integer);
begin
  Delete(S, Index, Count);
end;

// unic string routines

function _UnicLength(const S: UnicString): Integer;
begin
  result := Length(S);
end;

procedure _UnicDelete(var S: UnicString; Index, Count: Integer);
begin
  Delete(S, Index, Count);
end;

function _UnicCopy(const S: UnicString; Index, Count: Integer): UnicString;
begin
  result := Copy(S, Index, Count);
end;

procedure _UnicInsert(Source: UnicString; var S: UnicString; Index: Integer);
begin
  Insert(Source, S, Index);
end;

procedure _UnicValInt(const S: UnicString; var V: Integer; var Code: Integer);
begin
  Val(S, V, Code);
end;

procedure _UnicValDouble(const S: UnicString; var V: Double; var Code: Integer);
begin
  Val(S, V, Code);
end;

function _UnicPos(const Substr: UnicString; const S: UnicString): Integer;
begin
  result := Pos(Substr, S);
end;

// INT64 ROUTINES ///////////////////////////////////////

procedure _Int64Multiplication(var v1: Int64; var v2: Int64; var dest: Int64);
stdcall;
begin
  dest := v1 * v2;
end;

procedure _Int64Division(var v1: Int64; var v2: Int64; var dest: Int64);
stdcall;
begin
  dest := v1 div v2;
end;

procedure _Int64Modulo(var v1: Int64; var v2: Int64; var dest: Int64);
stdcall;
begin
  dest := v1 mod v2;
end;

procedure _Int64LeftShift(var v1: Int64; var v2: Int64; var dest: Int64);
stdcall;
begin
  dest := v1 shl v2;
end;

procedure _Int64RightShift(var v1: Int64; var v2: Int64; var dest: Int64);
stdcall;
begin
  dest := v1 shr v2;
end;

procedure _Int64LessThan(var v1: Int64; var v2: Int64; var dest: Boolean);
stdcall;
begin
  dest := v1 < v2;
end;

procedure _Int64LessThanOrEqual(var v1: Int64; var v2: Int64;
                                  var dest: Boolean); stdcall;
begin
  dest := v1 <= v2;
end;

procedure _Int64GreaterThan(var v1: Int64; var v2: Int64;
                              var dest: Boolean); stdcall;
begin
  dest := v1 > v2;
end;

procedure _Int64GreaterThanOrEqual(var v1: Int64; var v2: Int64;
                                     var dest: Boolean); stdcall;
begin
  dest := v1 >= v2;
end;

procedure _Int64Equality(var v1: Int64; var v2: Int64;
                           var dest: Boolean); stdcall;
begin
  dest := v1 = v2;
end;

procedure _Int64NotEquality(var v1: Int64; var v2: Int64;
                              var dest: Boolean); stdcall;
begin
  dest := v1 <> v2;
end;

procedure _Int64Abs(var v1: Int64; var dest: Int64); stdcall;
begin
  dest := Abs(v1);
end;
// VARIANT ROUTINES ///////////////////////////////////////

procedure _VariantClr(var V: Variant); stdcall;
begin
  VarClear(V);
end;

procedure _VariantAssign(var source: Variant; var dest: Variant); stdcall;
begin
  if VarIsNull(source) then
    VarClear(dest);
  dest := source;
end;

procedure _OleVariantAssign(var source: Variant; var dest: OleVariant); stdcall;
begin
  dest := source;
end;

procedure _VariantFromInterface(const source: IDispatch; var dest: Variant); stdcall;
begin
  dest := Source;
end;

procedure _OleVariantFromInterface(const source: IDispatch; var dest: OleVariant); stdcall;
begin
  dest := Source;
end;

procedure _VariantFromPAnsiChar(source: PAnsiChar; var dest: Variant); stdcall;
begin
  dest := AnsiString(Source);
end;

procedure _VariantFromPWideChar(source: PWideChar; var dest: Variant); stdcall;
begin
  dest := WideString(Source);
end;

procedure _OleVariantFromPAnsiChar(source: PAnsiChar; var dest: OleVariant); stdcall;
begin
  dest := AnsiString(Source);
end;

procedure _OleVariantFromPWideChar(source: PWideChar; var dest: OleVariant); stdcall;
begin
  dest := WideString(Source);
end;

procedure _VariantFromAnsiString(var Dest: Variant; var Source: AnsiString); stdcall;
begin
  Dest := Source;
end;

procedure _OleVariantFromAnsiString(var Dest: OleVariant; var Source: AnsiString); stdcall;
begin
  Dest := Source;
end;

procedure _OleVariantFromVariant(var Dest: OleVariant; var Source: Variant); stdcall;
begin
  Dest := Source;
end;

procedure _VariantFromWideString(var Dest: Variant; var Source: WideString);
stdcall;
begin
  Dest := Source;
end;

procedure _VariantFromUnicString(var Dest: Variant; var Source: UnicString);
stdcall;
begin
  Dest := Source;
end;

procedure _OleVariantFromWideString(var Dest: OleVariant; var Source: WideString);
stdcall;
begin
  Dest := Source;
end;

procedure _OleVariantFromUnicString(var Dest: OleVariant; var Source: UnicString);
stdcall;
begin
  Dest := Source;
end;

procedure _VariantFromShortString(var Dest: Variant; var Source: ShortString);
stdcall;
begin
  Dest := Source;
end;

procedure _OleVariantFromShortString(var Dest: OleVariant; var Source: ShortString);
stdcall;
begin
  Dest := Source;
end;

procedure _VariantFromAnsiChar(source: AnsiChar; var dest: Variant); stdcall;
begin
  dest := source;
end;

procedure _OleVariantFromAnsiChar(source: AnsiChar; var dest: OleVariant); stdcall;
begin
  dest := source;
end;

procedure _VariantFromWideChar(source: WideChar; var dest: Variant); stdcall;
begin
  dest := source;
end;

procedure _OleVariantFromWideChar(source: WideChar; var dest: OleVariant); stdcall;
begin
  dest := source;
end;

procedure _VariantFromInt(source: Integer; var dest: Variant); stdcall;
begin
  dest := source;
end;

procedure _OleVariantFromInt(source: Integer; var dest: OleVariant); stdcall;
begin
  dest := source;
end;

{$IFDEF VARIANTS}
procedure _VariantFromInt64(var source: Int64; var dest: Variant); stdcall;
begin
  dest := source;
end;
procedure _OleVariantFromInt64(var source: Int64; var dest: OleVariant); stdcall;
begin
  dest := source;
end;

{$ELSE}
procedure _VariantFromInt64(var source: Int64; var dest: Variant); stdcall;
begin
  dest := Integer(source);
end;
procedure _OleVariantFromInt64(var source: Int64; var dest: OleVariant); stdcall;
begin
  dest := Integer(source);
end;
{$ENDIF}

procedure _VariantFromByte(source: Byte; var dest: Variant); stdcall;
begin
  dest := source;
end;

procedure _OleVariantFromByte(source: Byte; var dest: OleVariant); stdcall;
begin
  dest := source;
end;

procedure _VariantFromBool(source: Boolean; var dest: Variant); stdcall;
begin
  dest := source;
end;

procedure _OleVariantFromBool(source: Boolean; var dest: OleVariant); stdcall;
begin
  dest := source;
end;

procedure _VariantFromWord(source: Word; var dest: Variant); stdcall;
begin
  dest := source;
end;

procedure _OleVariantFromWord(source: Word; var dest: OleVariant); stdcall;
begin
  dest := source;
end;

procedure _VariantFromCardinal(source: Cardinal; var dest: Variant); stdcall;
begin
{$IFDEF VARIANTS}
  dest := source;
{$ELSE}
  dest := Integer(source);
{$ENDIF}
end;

{$IFDEF VARIANTS}
procedure _OleVariantFromCardinal(source: Cardinal; var dest: OleVariant); stdcall;
begin
  dest := source;
end;
{$ELSE}
procedure _OleVariantFromCardinal(source: Integer; var dest: OleVariant); stdcall;
begin
  dest := source;
end;
{$ENDIF}

procedure _VariantFromSmallInt(source: SmallInt; var dest: Variant); stdcall;
begin
  dest := source;
end;

procedure _OleVariantFromSmallInt(source: SmallInt; var dest: OleVariant); stdcall;
begin
  dest := source;
end;

procedure _VariantFromShortInt(source: ShortInt; var dest: Variant); stdcall;
begin
  dest := source;
end;

procedure _OleVariantFromShortInt(source: ShortInt; var dest: OleVariant); stdcall;
begin
  dest := source;
end;

procedure _VariantFromDouble(var source: Double; var dest: Variant); stdcall;
begin
  dest := source;
end;

procedure _OleVariantFromDouble(var source: Double; var dest: OleVariant); stdcall;
begin
  dest := source;
end;

procedure _VariantFromCurrency(var source: Currency; var dest: Variant); stdcall;
begin
  dest := source;
end;

procedure _OleVariantFromCurrency(var source: Currency; var dest: OleVariant); stdcall;
begin
  dest := source;
end;

procedure _VariantFromSingle(var source: Single; var dest: Variant); stdcall;
begin
  dest := source;
end;

procedure _OleVariantFromSingle(var source: Single; var dest: OleVariant); stdcall;
begin
  dest := source;
end;

procedure _VariantFromExtended(var source: Extended; var dest: Variant); stdcall;
begin
  dest := source;
end;

procedure _OleVariantFromExtended(var source: Extended; var dest: OleVariant); stdcall;
begin
  dest := source;
end;

procedure _AnsiStringFromInt(var source: Integer;
                         var dest: AnsiString); stdcall; //JS only
begin
  dest := AnsiString(IntToStr(source));
end;

procedure _AnsiStringFromDouble(var source: Double;
                            var dest: AnsiString); stdcall; //JS only
begin
  dest := AnsiString(FloatToStr(source));
end;

procedure _AnsiStringFromSingle(var source: Single;
                            var dest: AnsiString); stdcall; //JS only
begin
  dest := AnsiString(FloatToStr(source));
end;

procedure _AnsiStringFromExtended(var source: Extended;
                              var dest: AnsiString); stdcall; //JS only
begin
  dest := AnsiString(FloatToStr(source));
end;

procedure _AnsiStringFromBoolean(var source: Boolean;
                             var dest: AnsiString); stdcall; //JS only
begin
  if source then
    dest := 'true'
  else
    dest := 'false';
end;

procedure _UnicStringFromInt(var source: Integer;
                         var dest: UnicString); stdcall; //JS only
begin
  dest := IntToStr(source);
end;

procedure _UnicStringFromDouble(var source: Double;
                            var dest: UnicString); stdcall; //JS only
begin
  dest := FloatToStr(source);
end;

procedure _UnicStringFromSingle(var source: Single;
                            var dest: UnicString); stdcall; //JS only
begin
  dest := FloatToStr(source);
end;

procedure _UnicStringFromExtended(var source: Extended;
                              var dest: UnicString); stdcall; //JS only
begin
  dest := FloatToStr(source);
end;

procedure _UnicStringFromBoolean(var source: Boolean;
                             var dest: UnicString); stdcall; //JS only
begin
  if source then
    dest := 'true'
  else
    dest := 'false';
end;

procedure _AnsiStringFromVariant(var source: Variant; var dest: AnsiString); stdcall;
begin
  dest := AnsiString(source);
end;

procedure _WideStringFromVariant(var source: Variant; var dest: WideString);
stdcall;
begin
  dest := source;
end;

procedure _UnicStringFromVariant(var source: Variant; var dest: UnicString);
stdcall;
begin
  dest := source;
end;

procedure _ShortStringFromVariant(var source: Variant; P: Pointer);
stdcall;
begin
  ShortString(P^) := ShortString(source);
end;

procedure _DoubleFromVariant(var source: Variant; var dest: Double); stdcall;
begin
  dest := source;
end;

procedure _CurrencyFromVariant(var source: Variant; var dest: Currency); stdcall;
begin
  dest := source;
end;

procedure _SingleFromVariant(var source: Variant; var dest: Single); stdcall;
begin
  dest := source;
end;

procedure _ExtendedFromVariant(var source: Variant; var dest: Extended); stdcall;
begin
  dest := source;
end;

procedure _IntFromVariant(var source: Variant; var dest: Integer); stdcall;
begin
  dest := source;
end;

{$IFDEF VARIANTS}
procedure _Int64FromVariant(var source: Variant; var dest: Int64); stdcall;
begin
  dest := source;
end;
{$ELSE}
procedure _Int64FromVariant(var source: Variant; var dest: Int64); stdcall;
begin
  dest := Integer(source);
end;
{$ENDIF}

procedure _ByteFromVariant(var source: Variant; var dest: Byte); stdcall;
begin
  dest := source;
end;

procedure _WordFromVariant(var source: Variant; var dest: Word); stdcall;
begin
  dest := source;
end;

procedure _CardinalFromVariant(var source: Variant; var dest: Cardinal); stdcall;
begin
  dest := source;
end;

procedure _SmallIntFromVariant(var source: Variant; var dest: SmallInt); stdcall;
begin
  dest := source;
end;

procedure _ShortIntFromVariant(var source: Variant; var dest: ShortInt); stdcall;
begin
  dest := source;
end;

procedure _BoolFromVariant(var source: Variant; var dest: Boolean); stdcall;
begin
  dest := source;
end;

procedure _ByteBoolFromVariant(var source: Variant; var dest: ByteBool); stdcall;
begin
  dest := source;
end;

procedure _WordBoolFromVariant(var source: Variant; var dest: WordBool); stdcall;
begin
  dest := source;
end;

procedure _LongBoolFromVariant(var source: Variant; var dest: LongBool); stdcall;
begin
  dest := source;
end;

procedure _StructEquality(P1, P2: Pointer; SZ: Integer; var dest: Boolean); stdcall;
begin
  dest := CompareMem(P1, P2, SZ);
end;

procedure _StructNotEquality(P1, P2: Pointer; SZ: Integer; var dest: Boolean); stdcall;
begin
  dest := not CompareMem(P1, P2, SZ);
end;

// VARIANT OPERATORS

procedure _VariantAddition(Language: Integer;
  var v1: Variant; var v2: Variant; var dest: Variant); stdcall;
begin
  dest := v1 + v2;
end;

procedure _VariantSubtraction(Language: Integer;
  var v1: Variant; var v2: Variant; var dest: Variant); stdcall;
begin
  dest := v1 - v2;
end;

procedure _VariantMultiplication(Language: Integer;
  var v1: Variant; var v2: Variant; var dest: Variant); stdcall;
begin
  dest := v1 * v2;
end;

procedure _VariantDivision(Language: Integer;
  var v1: Variant; var v2: Variant; var dest: Variant); stdcall;
begin
  dest := v1 / v2;
end;

procedure _VariantIDivision(Language: Integer;
  var v1: Variant; var v2: Variant; var dest: Variant); stdcall;
begin
  dest := v1 div v2;
end;

procedure _VariantModulo(Language: Integer;
  var v1: Variant; var v2: Variant; var dest: Variant); stdcall;
begin
  dest := v1 mod v2;
end;

procedure _VariantLeftShift(Language: Integer;
  var v1: Variant; var v2: Variant; var dest: Variant); stdcall;
begin
  dest := v1 shl v2;
end;

procedure _VariantRightShift(Language: Integer;
  var v1: Variant; var v2: Variant; var dest: Variant); stdcall;
begin
  dest := v1 shr v2;
end;

procedure _VariantAnd(Language: Integer;
  var v1: Variant; var v2: Variant; var dest: Variant); stdcall;
begin
  dest := v1 and v2;
end;

procedure _VariantOr(Language: Integer;
  var v1: Variant; var v2: Variant; var dest: Variant); stdcall;
begin
  dest := v1 or v2;
end;

procedure _VariantXor(Language: Integer;
  var v1: Variant; var v2: Variant; var dest: Variant); stdcall;
begin
  dest := v1 xor v2;
end;

procedure _VariantLessThan(Language: Integer;
  var v1: Variant; var v2: Variant; var dest: Boolean); stdcall;
begin
  dest := v1 < v2;
end;

procedure _VariantLessThanOrEqual(Language: Integer;
  var v1: Variant; var v2: Variant; var dest: Boolean); stdcall;
begin
  dest := v1 <= v2;
end;

procedure _VariantGreaterThan(Language: Integer;
  var v1: Variant; var v2: Variant; var dest: Boolean); stdcall;
begin
  dest := v1 > v2;
end;

procedure _VariantGreaterThanOrEqual(Language: Integer;
  var v1: Variant; var v2: Variant; var dest: Boolean); stdcall;
begin
  dest := v1 >= v2;
end;

procedure _VariantEquality(Language: Integer;
  var v1: Variant; var v2: Variant; var dest: Boolean); stdcall;
begin
  dest := v1 = v2;
end;

procedure _VariantNotEquality(Language: Integer;
  var v1: Variant; var v2: Variant; var dest: Boolean); stdcall;
begin
  dest := v1 <> v2;
end;

procedure _VariantNot(var v1: Variant; var dest: Variant); stdcall;
begin
  dest := not v1;
end;

procedure _VariantNegation(var v1: Variant; var dest: Variant); stdcall;
begin
  dest := - v1;
end;

procedure _VariantAbs(var v1: Variant; var dest: Variant); stdcall;
begin
  if v1 >= 0 then
    dest := v1
  else
    dest := -v1;
end;

procedure _VarArrayPut1(var V: Variant; var value: Variant; const I1: Variant);
stdcall;
begin
  V[I1] := value;
end;

procedure _VarArrayGet1(var V: Variant; var result: Variant; const I1: Variant);
stdcall;
begin
  result := V[I1];
end;

procedure _VarArrayPut2(var V: Variant; var value: Variant; const I2, I1: Variant);
stdcall;
begin
  V[I1, I2] := value;
end;

procedure _VarArrayGet2(var V: Variant; var result: Variant; const I2, I1: Variant);
stdcall;
begin
  result := V[I1, I2];
end;

procedure _VarArrayPut3(var V: Variant; var value: Variant; const I3, I2, I1: Variant);
stdcall;
begin
  V[I1, I2, I3] := value;
end;

procedure _VarArrayGet3(var V: Variant; var result: Variant; const I3, I2, I1: Variant);
stdcall;
begin
  result := V[I1, I2, I3];
end;

function GetPaxInterface(Self: TObject; const GUID: TGUID; var obj: Pointer): Boolean;
var
  PaxInfo: PPaxInfo;
  P: TProgram;
  ClassRec: TClassRec;
  IntfList: TIntfList;
  I, SZ: Integer;
begin
  PaxInfo := GetPaxInfo(Self.ClassType);
  if PaxInfo = nil then
    raise Exception.Create(errInternalError);

  P := TProgram(PaxInfo^.Prog);
  ClassRec := P.ClassList[PaxInfo^.ClassIndex];
  IntfList := ClassRec.IntfList;
  I := IntfList.IndexOf(GUID);
  if I = -1 then
    result := false
  else
  begin
    SZ := Self.InstanceSize - IntfList.Count * 4;
    Obj := ShiftPointer(Self, SZ + I * 4);
    result := true;
  end;
end;

procedure _InterfaceFromClass(var Dest: IUnknown;
                              var GUID: TGUID;
                              var Source: TObject); stdcall;
begin
  if IsPaxObject(Source) then
  begin
    if TMyInterfacedObject(Source).RefCount = -1 then
      TMyInterfacedObject(Source)._AddRef;
    if not GetPaxInterface(Source, GUID, Pointer(Dest)) then
      raise Exception.Create(errIncompatibleTypesNoArgs);
    Dest._AddRef;
    Exit;
  end;

  if not Source.GetInterface(GUID, Dest) then
    raise Exception.Create(errIncompatibleTypesNoArgs);
end;

procedure _InterfaceCast(var Dest: IUnknown;
                         var GUID: TGUID;
                         var Source: IUnknown); stdcall;
begin
  if Source.QueryInterface(GUID, Dest) <> 0 then
    raise Exception.Create(errIncompatibleTypesNoArgs);
end;

procedure _InterfaceAssign(var Dest: IUnknown;
                           var Source: IUnknown); stdcall;
begin
  Dest := Source;
end;

// PASCAL ARITHMETIC ROUTINES ///////////////////////////////////////

function _ArcTan(const X: Extended): Extended;
begin
  result := ArcTan(X);
end;

function _Cos(const X: Extended): Extended;
begin
  result := Cos(X);
end;

function _Exp(X: Extended): Extended;
begin
  result := Exp(X);
end;

function _Frac(X: Extended): Extended;
begin
  result := Frac(X);
end;

function _Int(X: Extended): Extended;
begin
  result := Int(X);
end;

function _Ln(X: Extended): Extended;
begin
  result := Ln(X);
end;

function _Sin(X: Extended): Extended;
begin
  result := Sin(X);
end;

function _Sqr(X: Extended): Extended;
begin
  result := Sqr(X);
end;

function _Sqrt(X: Extended): Extended;
begin
  result := Sqrt(X);
end;

function _Trunc(X: Extended): Integer;
begin
  result := Trunc(X);
end;

function _Power(const Base, Exponent: Extended): Extended;
begin
  result := Power(Base, Exponent);
end;

// PASCAL MISCELLANEOUS ROUTINES ////////////////////////////////////

procedure _FillChar(var X; Count: Integer; Value: Byte);
begin
  FillChar(X, Count, Value);
end;

function _Random: Double;
begin
  result := Random;
end;

function _Random1(N: Integer): Integer;
begin
  result := Random(N);
end;

function _HiInt(N: Integer): Byte;
begin
  result := Hi(N);
end;

function _HiWord(N: Word): Byte;
begin
  result := Hi(N);
end;

function _LoInt(N: Integer): Byte;
begin
  result := Lo(N);
end;

function _LoWord(N: Word): Byte;
begin
  result := Lo(N);
end;

{$IFDEF FPC}
function _UpCase(Ch: AnsiChar): AnsiChar;
begin
  result := Upcase(Ch);
end;
{$ENDIF}

function GetClassByIndex(P: TProgram; I: Integer): TClass;
begin
  result := P.ClassList[I].PClass;
end;

procedure _Is(PClass: TClass; Instance: TObject;
              var result: Boolean); stdcall;
begin
  result := Instance is PClass;
end;

procedure _ToParentClass(P: TProgram;
                         Instance: TObject); stdcall;
var
  C: TClass;
begin
  C := Instance.ClassType;
  P.SavedClass := C;
  while IsPaxClass(C) do
    C := C.ClassParent;
  Move(C, Pointer(Instance)^, 4);
end;

procedure _UpdateInstance(P: TProgram;
                          Instance: TObject); stdcall;
var
  C: TClass;
begin
  C := P.SavedClass;
  Move(C, Pointer(Instance)^, 4);
  P.SavedClass := nil;
end;

procedure _DestroyInherited(Instance: TObject);
var
  C, Temp: TClass;
begin
  Temp := Instance.ClassType;
  C := Instance.ClassParent;
  Move(C, Pointer(Instance)^, 4);
  asm
    xor edx, edx
    mov eax, instance
    mov ecx, [eax]
    mov ecx, [ecx - $04]
    call ecx
  end;
  Move(Temp, Pointer(Instance)^, 4);
end;

procedure _ClassName(PClass: TClass; result: PShortString); stdcall;
begin
  result^ := PClass.ClassName;
end;

procedure _OnCreateObject(P: TProgram; Instance: TObject); stdcall;
begin
  if Assigned(P.OnCreateObject) then
    P.OnCreateObject(P.Owner, Instance);
end;

procedure _OnAfterObjectCreation(P: TProgram; Instance: TObject); stdcall;
var
  VMT: PVMT;
begin
  VMT := GetVmtFromObject(Instance);
  VMT^.AfterConstruction(Instance);

  if Assigned(P.OnAfterObjectCreation) then
    P.OnAfterObjectCreation(P.Owner, Instance);
end;

function _InitInstance(Self: TClass; Instance: Pointer): TObject;
var
  IntfTable: PInterfaceTable;
  ClassPtr: TClass;
  I: Integer;
begin
  with Self do
  begin
    ClassPtr := Self;
    while ClassPtr <> nil do
    begin
      IntfTable := ClassPtr.GetInterfaceTable;
      if IntfTable <> nil then
        for I := 0 to IntfTable.EntryCount-1 do
        with IntfTable.Entries[I] do
        begin
          if VTable <> nil then
            PInteger(@PAnsiChar(Instance)[IOffset])^ := Integer(VTable);
        end;
      ClassPtr := ClassPtr.ClassParent;
    end;
    Result := Instance;
  end;
end;

procedure _CreateObject(C: TClass;
                        var X: TObject); stdcall;
var
  Size: Integer;
  ClassRec: TClassRec;
  IntfList: TIntfList;
  Ptr: Pointer;
  I, ClassIndex: Integer;
  PaxInfo: PPaxInfo;
  P: TProgram;
label
  Again;
begin
  Again:

  PaxInfo := GetPaxInfo(C);
  if PaxInfo = nil then
    raise Exception.Create(errInternalError);
  P := TProgram(PaxInfo^.Prog);

  if P.RootProg.PassedClassRef <> nil then
  begin
    C := P.RootProg.PassedClassRef;
    P.RootProg.PassedClassRef := nil;
    goto Again;
  end;

  ClassIndex := PaxInfo^.ClassIndex;

  if ClassIndex = -1 then
    raise Exception.Create(errInternalError);

  ClassRec := TProgram(P).ClassList[ClassIndex];
  Size := C.InstanceSize;
  X := AllocMem(Size);
  Pointer(Pointer(X)^) := C;

  IntfList := ClassRec.IntfList;
  if IntfList.Count > 0 then
  begin
    Ptr := ShiftPointer(X, Size - IntfList.Count * 4);
    for I:=0 to IntfList.Count - 1 do
    begin
      Pointer(Ptr^) := IntfList[I].Buff;
      Ptr := ShiftPointer(Ptr, 4);
    end;
  end;

  X := _InitInstance(C, X);
end;

procedure ClearStrProps(X: TObject);
var
  pti: PTypeInfo;
  ptd: PTypeData;
  Loop, nProps: Integer;
  pProps: PPropList;
  ppi: PPropInfo;
begin
  pti := X.ClassInfo;
  if pti = nil then Exit;
  ptd := GetTypeData(pti);
  if ptd = nil then Exit;
  nProps := ptd^.PropCount;
  if nProps = 0 then
    Exit;
  GetMem(pProps, SizeOf(PPropInfo) * nProps);
  GetPropInfos(pti, pProps);
  for Loop:=0 to nProps - 1 do
  begin
{$ifdef fpc}
    ppi := pProps^[Loop];
{$else}
    ppi := pProps[Loop];
{$endif}
    case ppi^.PropType^.Kind of
      tkLString: _SetAnsiStrProp(ppi, X, '');
      tkWString: _SetWideStrProp(ppi, X, '');
{$IFDEF UNIC}
      tkUString: _SetUnicStrProp(ppi, X, '');
{$ENDIF}
    end;
  end;
  FreeMem(pProps, SizeOf(PPropInfo) * nProps);
end;

procedure _DestroyObject(Self: TObject; OuterMost: ShortInt);
var
  PaxInfo: PPaxInfo;
  ClassRec: TClassRec;
  _ProgOffset, _Self: Integer;
  Data, Code: Pointer;
  P, RootProg, TargetProg: TProgram;
  C: TClass;
  VMT: PVMT;
  I: Integer;
  FullName: String;
begin
  C := Self.ClassType;

  VMT := GetVMTFromClass(C);
  if OuterMost <> 0 then
    if not C.InheritsFrom(TInterfacedObject) then
      VMT^.BeforeDestruction(Self);

  PaxInfo := GetPaxInfo(C);
  if PaxInfo = nil then
    raise Exception.Create(errInternalError);

  P := TProgram(PaxInfo^.Prog);

  if Assigned(P.OnDestroyObject) then
    if OuterMost <> 0 then
      P.OnDestroyObject(P.Owner, Self);

  ClassRec := P.ClassList[PaxInfo^.ClassIndex];
  _ProgOffset := ClassRec.DestructorProgOffset;

  if C.InheritsFrom(TPersistent) then
    ClearStrProps(Self);

  TargetProg := nil;
  if _ProgOffset = 0 then
  begin
    FullName := ClassRec.FullName;
    RootProg := P.RootProg;
    for I := 0 to RootProg.ProgList.Count - 1 do
    begin
      TargetProg := TProgram(RootProg.ProgList[I].Prog);
      ClassRec := TargetProg.ClassList.Lookup(FullName);
      if ClassRec <> nil then
      begin
        _ProgOffset := ClassRec.DestructorProgOffset;
        break;
      end;
    end;
  end
  else
    TargetProg := P;

  if _ProgOffset > 0 then
  begin
    Data := TargetProg.DataPtr;
    Code := TargetProg.CodePtr;

    asm
      push esi
      push edi
      push ebx

      mov esi, Data;
      mov edi, Code;
    end;

    _Self  := Integer(Self);
    asm
      push eax
      mov eax, _Self
      mov ebx, edi
      add ebx, _ProgOffset
      call ebx
      pop eax
    end;

    asm
      pop ebx
      pop edi
      pop esi
    end;

  end;

  if OuterMost = 0 then
    Exit;

  _ToParentClass(P, Self);
  Self.CleanupInstance;
  _UpdateInstance(P, Self);
  FreeMem(Pointer(Self), Self.InstanceSize);

  if Assigned(P.OnAfterObjectDestruction) then
    P.OnAfterObjectDestruction(P.Owner, C);
end;

procedure _ErrAbstract(S: PAnsiChar); stdcall;
begin
  raise Exception.Create(Format(ErrAbstractMethodCall, [S]));
end;

// processing try-except-finally

procedure _TryOn(P: TProgram; TryBlockNumber: Integer; _EBP, _ESP: Integer);
stdcall;
var
  R: TTryRec;
begin
  with P.RootProg do
    P.SetAddress(H_ExceptionPtr, @ P.fCurrException);

  P.RootTryStack.Push(TryBlockNumber, P);

  R := P.TryList[TryBlockNumber];
  R._EBP := _EBP;
  R._ESP := _ESP;
  R.ESP0 := P.RootESP0;
  R.SaveStackFrame;
end;

procedure _TryOff(P: TProgram; TryBlockNumber: Integer); stdcall;
begin
  P := P.RootProg;

  if P.RootTryStack.Count = 0 then
    Exit;
  P.RootTryStack.Pop;
  P.SetAddress(H_ExceptionPtr, @ P.fCurrException);
end;

procedure _Raise(P: TProgram; E: Exception; RaiseMode: Integer); stdcall;
var
  CE: TExceptionClass;
begin
  if RaiseMode = 0 then
  begin
  end
  else
  begin
    if P.RootTryStack.Count > 0 then
      P.RootTryStack.Pop;
  end;

  if P.RootTryStack.Count > 0 then
    P.TryList[P.RootTryStack.Top.TryBlockNumber].SaveStackFrame;

  if E <> nil then
    raise E
  else
  begin
    Integer(CE) := Integer(P.RootCurrException.ClassType);
    E := CE.Create(P.RootCurrException.Message);
    raise E;
  end;
end;

procedure _Exit(P: TProgram; Level: Integer); stdcall;
var
  E: PaxExitException;
  TryRec: TTryRec;
begin
  E := PaxExitException.Create('');
  P.ExitLevelId := Level;
  P.RootExceptionIsAvailableForHostApplication := false;

  if P.RootTryStack.Count > 0 then
  begin
    TryRec := P.TryList[P.RootTryStack.Top.TryBlockNumber];
    while TryRec.TryKind <> tryFinally do
    begin
      P.RootTryStack.Pop;
      if P.RootTryStack.Count > 0 then
        TryRec := P.TryList[P.RootTryStack.Top.TryBlockNumber]
      else
        raise E;
    end;

    TryRec.SaveStackFrame;
  end;

  raise E;
end;

procedure _CondRaise(P: TProgram; var IsExit: Boolean; SubId: Integer); stdcall;
var
  E: Exception;
  CE: TExceptionClass;
  I, K, LevelId: Integer;
  Temp1: Integer;
  Temp2: Pointer;
begin
  IsExit := false;

  if P.RootProcessingExceptBlock then
    Exit;

  if P.RootCurrException <> nil then
  begin
    IsExit := P.RootCurrException is PaxExitException;
    if IsExit then
    begin
      K := 0;
      if P.RootTryStack.Count > 0 then
      begin
        LevelId := P.ExitLevelId;
        for I := 0 to P.RootTryStack.Count - 1 do
        begin
          if P.RootTryStack[I].Prog <> P then
            continue;

          if P.TryList[P.RootTryStack[I].TryBlockNumber].Level = LevelId then
            Inc(K);
        end;
      end;

      if K = 0 then
        Exit
      else if K = 1 then
      begin
        if P.RootTryStack.Count > 0 then
          P.RootTryStack.Pop;

        P.ExitLevelId := 0;
        P.RootCurrException.Free;
        P.RootCurrException := nil;

        Exit;
      end;

      P.RootTryStack.Pop;

      _Exit(P, P.ExitLevelId);
    end;

    Integer(CE) := Integer(P.RootCurrException.ClassType);
    E := CE.Create(P.RootCurrException.Message);

    Temp1 := P.RootTryStack.Top.TryBlockNumber;
    Temp2 := P.RootTryStack.Top.Prog;

    P.RootTryStack.Pop;

    if P.RootTryStack.Count > 0 then
    begin
      P.RootExceptionIsAvailableForHostApplication := false;
      while (P.TryList[P.RootTryStack.Top.TryBlockNumber].TryKind = tryFinally) and (P.RootTryStack.Count > 0) do
      begin
        if P.TryList[P.RootTryStack.Top.TryBlockNumber].Level <> SubId then
        begin
          P.RootTryStack.Push(Temp1, Temp2);
          Exit;
        end;
        P.RootTryStack.Pop;

        if P.RootTryStack.Count = 0 then
          break;
      end;
    end
    else
      P.RootExceptionIsAvailableForHostApplication := true;

    raise E;
  end;
end;

procedure _BeginExceptBlock(P: TProgram); stdcall;
begin
//  P.ProcessingExceptBlock := true;
end;

procedure _EndExceptBlock(P: TProgram); stdcall;
begin
  P.RootProcessingExceptBlock := false;

  if Assigned(P.RootCurrException) then
    P.RootCurrException.Free;
  P.RootCurrException := nil;
end;

// processing breakpoints

procedure _CheckPause(P: TProgram);
var
  SourceLine, ModuleIndex: Integer;
  HasBreakpoint: Boolean;
begin
  if not P.IsRootProg then
    Exit;

  SourceLine := P.GetSourceLine;
  ModuleIndex := P.GetModuleIndex;

  HasBreakpoint :=
    P.RunTimeModuleList.BreakpointList.IndexOf(ModuleIndex, SourceLine) >= 0;

  if HasBreakpoint then
    P.Pause
  else
  begin
    if P.RunMode = rmRUN then
    begin
    end
    else if P.RunMode = rmTRACE_INTO then
      P.Pause
    else if P.RunMode = rmSTEP_OVER then
    begin
      if P.RootInitCallStackCount >= P.RootCallStackId.Count then
        P.Pause;
    end else if P.RunMode = rmRUN_TO_CURSOR then
    begin
      if P.RunTimeModuleList.TempBreakpoint.SourceLine = SourceLine then
        if P.RunTimeModuleList.TempBreakpoint.ModuleIndex = ModuleIndex then
          P.Pause;
    end;
  end;
end;

// processing pause

procedure _Pause(P: TProgram; ProgOffset, _EBP, _ESP: Integer); stdcall;
begin
  if Assigned(P.OnPauseUpdated) then
  begin
    P.IsPauseUpdated := true;
    P.PauseRec.ProgOffset := 1;
    try
      P.OnPauseUpdated(P.Owner, P.GetModuleName, P.GetSourceLine);
    finally
      P.PauseRec.ProgOffset := 0;
      P.RemovePause;
      P.RootInitCallStackCount := P.RootCallStackId.Count;
      P.IsPauseUpdated := false;
    end;
    Exit;
  end;

  P.PauseRec._EBP := _EBP;
  P.PauseRec._ESP := _ESP;
  P.PauseRec.ESP0 := P.RootESP0;
  P.PauseRec.ProgOffset := ProgOffset;
  P.PauseRec.SaveStackFrame;

  P.RootExceptionIsAvailableForHostApplication := false;

  raise TPauseException.Create;
end;

procedure _InitSub(P: TProgram; SubId: Integer; _EBP: Integer);
var
  N: Integer;
begin
  N := P.GetByteCodeLine;
  P.RootCallStackId.Push(SubId);
  P.RootCallStackEBP.Push(_EBP);
  P.RootCallStackNCall.Push(N);
end;

procedure _EndSub(P: TProgram);
begin
  P.RootCallStackId.Pop;
  P.RootCallStackEBP.Pop;
  P.RootCallStackNCall.Pop;

  if P.RunMode = rmSTEP_OVER then
  begin
    if P.RootInitCallStackCount >= P.RootCallStackId.Count then
      P.Pause;
  end;
end;

// processing halt

procedure _Halt(P: TProgram; ExitCode: Integer); stdcall;
begin
  P.RootExceptionIsAvailableForHostApplication := false;
  P.ExitCode := ExitCode;
  raise THaltException.Create(ExitCode);
end;

// processing CondHalt

procedure _CondHalt(P: TProgram); stdcall;
begin
  if P.IsHalted then
  begin
    P.RootExceptionIsAvailableForHostApplication := false;
    raise THaltException.Create(P.ExitCode);
  end;
end;

// processing of published properties

procedure _GetAnsiStrProp(PropInfo: PPropInfo; Instance: TObject;
                      var result: AnsiString); stdcall;
begin
{$IFDEF UNIC}
  Result := GetAnsiStrProp(Instance, PropInfo);
{$ELSE}
  result := GetStrProp(Instance, PropInfo);
{$ENDIF}
end;

procedure _SetAnsiStrProp(PropInfo: PPropInfo; Instance: TObject;
                      const value: AnsiString); stdcall;
begin
{$IFDEF UNIC}
  SetAnsiStrProp(Instance, PropInfo, Value);
{$ELSE}
  SetStrProp(Instance, PropInfo, Value);
{$ENDIF}
end;

procedure _GetWideStrProp(PropInfo: PPropInfo; Instance: TObject;
                      var result: WideString); stdcall;
begin
{$IFDEF VARIANTS}
  result := GetWideStrProp(Instance, PropInfo);
{$ELSE}
  result := '';
{$ENDIF}
end;

procedure _SetWideStrProp(PropInfo: PPropInfo; Instance: TObject;
                      const value: WideString); stdcall;
begin
{$IFDEF VARIANTS}
  SetWideStrProp(Instance, PropInfo, Value);
{$ENDIF}
end;

procedure _GetUnicStrProp(PropInfo: PPropInfo; Instance: TObject;
                      var result: UnicString); stdcall;
begin
{$IFDEF VARIANTS}
  {$IFDEF UNIC}
    result := GetUnicodeStrProp(Instance, PropInfo);
  {$ELSE}
    result := GetWideStrProp(Instance, PropInfo);
  {$ENDIF}
{$ELSE}
  result := '';
{$ENDIF}
end;

procedure _SetUnicStrProp(PropInfo: PPropInfo; Instance: TObject;
                      const value: UnicString); stdcall;
begin
{$IFDEF VARIANTS}
  {$IFDEF UNIC}
    SetUnicodeStrProp(Instance, PropInfo, Value);
  {$ELSE}
    SetWideStrProp(Instance, PropInfo, Value);
  {$ENDIF}
{$ENDIF}
end;

procedure _GetOrdProp(PropInfo: PPropInfo; Instance: TObject;
                      var result: Integer); stdcall;
begin
  result := GetOrdProp(Instance, PropInfo);
end;

procedure _SetOrdProp(PropInfo: PPropInfo; Instance: TObject; value: Integer);
stdcall;
begin
  SetOrdProp(Instance, PropInfo, Value);
end;

{$IFDEF VARIANTS}
procedure _GetInterfaceProp(PropInfo: PPropInfo; Instance: TObject;
                      var result: IInterface); stdcall;
begin
{$IFDEF FPC}
{$IFDEF LINUX}
{$ELSE}
  result := GetInterfaceProp(Instance, PropInfo);
{$ENDIF}
{$ELSE}
  result := GetInterfaceProp(Instance, PropInfo);
{$ENDIF}
end;
 
procedure _SetInterfaceProp(PropInfo: PPropInfo; Instance: TObject; value: IInterface);
stdcall;
begin
{$IFDEF FPC}
{$IFDEF LINUX}
{$ELSE}
  SetInterfaceProp(Instance, PropInfo, Value);
{$ENDIF}
{$ELSE}
  SetInterfaceProp(Instance, PropInfo, Value);
{$ENDIF}
end;
{$ELSE}
procedure _GetInterfaceProp(PropInfo: PPropInfo; Instance: TObject;
                      var result: IUnknown); stdcall;
begin
//  result := GetInterfaceProp(Instance, PropInfo);
end;

procedure _SetInterfaceProp(PropInfo: PPropInfo; Instance: TObject; value: IUnknown);
stdcall;
begin
//  SetInterfaceProp(Instance, PropInfo, Value);
end;
{$ENDIF}

procedure _GetSetProp(PropInfo: PPropInfo;  Instance: TObject;
                       var result: TByteSet); stdcall;
var
  I: Integer;
begin
  I := GetOrdProp(Instance, PropInfo);
  result := Int32ToByteSet(I);
end;

procedure _SetSetProp(PropInfo: PPropInfo; Instance: TObject;
                      var value: TByteSet); stdcall;
var
  I: Integer;
begin
  I := ByteSetToInt32(value);
  SetOrdProp(Instance, PropInfo, I);
end;

procedure _GetFloatProp(PropInfo: PPropInfo; Instance: TObject;
                        var result: Extended); stdcall;
begin
  result := GetFloatProp(Instance, PropInfo);
end;

procedure _SetFloatProp(PropInfo: PPropInfo; Instance: TObject;
                        var value: Extended); stdcall;
begin
  SetFloatProp(Instance, PropInfo, Value);
end;

procedure _GetVariantProp(PropInfo: PPropInfo; Instance: TObject;
                          var result: Variant); stdcall;
begin
  result := GetVariantProp(Instance, PropInfo);
end;

procedure _SetVariantProp(PropInfo: PPropInfo; Instance: TObject;
                           var value: Variant); stdcall;
begin
  SetVariantProp(Instance, PropInfo, Value);
end;

procedure _GetInt64Prop(PropInfo: PPropInfo; Instance: TObject;
                        var result: Int64); stdcall;
begin
  result := GetInt64Prop(Instance, PropInfo);
end;

procedure _SetInt64Prop(PropInfo: PPropInfo; Instance: TObject;
                        var value: Int64); stdcall;
begin
  SetInt64Prop(Instance, PropInfo, Value);
end;

procedure _GetEventProp(PropInfo: PPropInfo; Instance: TObject;
                        var N: TMethod); stdcall;
begin
  N := GetMethodProp(Instance, PropInfo);
end;

procedure _SetEventProp(P: TProgram; PropInfo: PPropInfo;
                        Instance: TObject;
                        Code: Pointer;
                        Data: TObject;
                        CallConv: Integer;
                        RetSize: Integer); stdcall;
var
  M: TMethod;
  ER: TEventHandlerRec;

  B, B1, B2: Integer;
begin
  if Data = nil then
  begin
    M.Code := nil;
    M.Data := nil;
    SetMethodProp(Instance, PropInfo, M);
    Exit;
  end;

  B  := Integer(Code);
  B1 := Integer(P.CodePtr);
  B2 := B1 + P.CodeSize;

  if (B >= B1) and (B <= B2) then
  begin
    ER := P.EventHandlerList.Add(P, Code, Data, CallConv, RetSize);
    M.Code := @ TEventHandlerRec.Invoke;
    M.Data := ER;
  end
  else
  begin
    M.Code := Code;
    M.Data := Data;
  end;

  SetMethodProp(Instance, PropInfo, M);
end;

procedure _SetEventProp2(P: TProgram; PropInfo: PPropInfo;
                         Instance: TObject;
                         var N: TMethod); stdcall;
var
  M: TMethod;
  ER: TEventHandlerRec;

  B, B1, B2: Integer;
begin
  B  := Integer(N.Code);
  B1 := Integer(P.CodePtr);
  B2 := B1 + P.CodeSize;

  if (B >= B1) and (B <= B2) then
  begin
    ER := P.EventHandlerList.Add(P, N.Code, TObject(N.Data), ccREGISTER, 0);
    M.Code := @ TEventHandlerRec.Invoke;
    M.Data := ER;
  end
  else
  begin
    M := N;
  end;

  SetMethodProp(Instance, PropInfo, M);
end;

procedure _CreateMethod(Data, Code: Pointer; var M: TMethod); stdcall;
begin
  M.Code := Code;
  M.Data := Data;
end;

procedure _RecordAssign(source: Pointer; dest: Pointer; Size: Integer); stdcall;
begin
  Move(dest^, source^, Size);
end;

//------------------ Dynamic array support routines ----------------------------

type
  DynarrayInteger = array of Integer;
  DynarrayWord = array of Word;
  DynarrayBoolean = array of Boolean;
  DynarrayByte = array of Byte;
  DynarrayChar = array of AnsiChar;
  DynarrayWideChar = array of WideChar;
  DynarrayString = array of AnsiString;
  DynarrayShortString = array of ShortString;
  DynarrayWideString = array of WideString;
  DynarrayUnicString = array of UnicString;
  DynarrayDouble = array of Double;
  DynarraySingle = array of Single;
  DynarrayExtended = array of Extended;
  DynarrayVariant = array of Variant;
  DynarrayPointer = array of Pointer;
  DynarrayTVarRec = array of TVarRec;

procedure _CreateEmptyDynarray(var A: Pointer); stdcall;
var
  P: Pointer;
begin
  P := AllocMem(2 * SizeOf(Integer));
  Integer(P^) := 1;
  P := ShiftPointer(P, SizeOf(Integer));
  Integer(P^) := 0;
  P := ShiftPointer(P, SizeOf(Integer));
  A := P;
end;

procedure _DynarraySetLength(var A: Pointer; L: Integer;
                             ElFinalTypeID, ElTypeID, ElSize: Integer); stdcall;
var
  P: Pointer;
begin
  case ElFinalTypeID of
    typeBOOLEAN: SetLength(DynarrayBoolean(A), L);
    typeBYTE: SetLength(DynarrayByte(A), L);
    typeANSICHAR: SetLength(DynarrayChar(A), L);
    typeANSISTRING: SetLength(DynarrayString(A), L);
    typeWORD: SetLength(DynarrayWord(A), L);
    typeINTEGER: SetLength(DynarrayInteger(A), L);
    typeCARDINAL: SetLength(DynarrayInteger(A), L);
    typeDOUBLE: SetLength(DynarrayDouble(A), L);
    typePOINTER: SetLength(DynarrayPointer(A), L);
    typeENUM: SetLength(DynarrayInteger(A), L);
    typePROC: SetLength(DynarrayPointer(A), L);
    typeSHORTSTRING: SetLength(DynarrayShortString(A), L);
    typeSINGLE: SetLength(DynarraySingle(A), L);
    typeEXTENDED: SetLength(DynarrayExtended(A), L);
    typeCLASS: SetLength(DynarrayPointer(A), L);
    typeCLASSREF: SetLength(DynarrayPointer(A), L);
    typeWIDECHAR: SetLength(DynarrayWideChar(A), L);
    typeWIDESTRING: SetLength(DynarrayWideString(A), L);
    typeUNICSTRING: SetLength(DynarrayUnicString(A), L);
    typeVARIANT: SetLength(DynarrayVariant(A), L);
    typeDYNARRAY: SetLength(DynarrayPointer(A), L);
    else
    begin
      if ElTypeID = H_TVarRec then
      begin
        SetLength(DynarrayTVarRec(A), L);
        Exit;
      end;

      P := AllocMem(L * ElSize + 2 * SizeOf(Integer));
      Integer(P^) := 1;
      P := ShiftPointer(P, SizeOf(Integer));
      Integer(P^) := L;
      P := ShiftPointer(P, SizeOf(Integer));
      A := P;
    end;
  end;
end;

function _DynarrayLength(P: Pointer): Integer;
begin
  if P = nil then
    result := 0
  else
  begin
    P := ShiftPointer(P, - SizeOf(Integer));
    result := Integer(P^);
  end;
end;

procedure _DynarrayHigh(var P: Pointer; var result: Integer); stdcall;
begin
  result := _DynarrayLength(P) - 1;
end;

function _DynarrayRefCount(P: Pointer): Integer;
begin
  if P = nil then
    result := -1
  else
  begin
    P := ShiftPointer(P, - 2 * SizeOf(Integer));
    result := Integer(P^);
  end;
end;

function _DynarrayIncRefCount(P: Pointer): Integer;
begin
  if P <> nil then
  begin
    P := ShiftPointer(P, - 2 * SizeOf(Integer));
    result := Integer(P^) + 1;
    Integer(P^) := result;
  end
  else
    result := 0;
end;

function _DynarrayDecRefCount(P: Pointer): Integer;
begin
  if P <> nil then
  begin
    P := ShiftPointer(P, - 2 * SizeOf(Integer));
    result := Integer(P^) - 1;
    Integer(P^) := result;
  end
  else
    result := 0;
end;

procedure FreeDynarrayTVarRec(const A: DynarrayTVarRec);
var
  I: Integer;
begin
  for I:=0 to Length(A) - 1 do
  begin
    case A[I].VType of
      vtExtended:
        Dispose(PExtended(A[I].VExtended));
      vtString:
        Dispose(PShortString(A[I].VString));
      vtVariant:
        Dispose(PVariant(A[I].VVariant));
      vtWideString:
        Dispose(PWideString(A[I].VWideString));
      {$IFDEF UNIC}
      vtUnicodeString:
        Dispose(PUnicString(A[I].VUnicodeString));
      {$ENDIF}
    end;
  end;
end;

procedure _DynarrayClr(var A: Pointer; FinalTypeID, TypeID, ElSize: Integer);
stdcall;
var
  P: Pointer;
  K, L: Integer;
begin
  case FinalTypeID of
    typeANSISTRING: DynarrayString(A) := nil;
    typeWIDESTRING: DynarrayWideString(A) := nil;
    typeUNICSTRING: DynarrayUnicString(A) := nil;
    typeVARIANT: DynarrayVariant(A) := nil;
    else
    begin
      if A <> nil then
      begin
        if TypeID = H_TVarRec then
        begin
          K := _DynarrayRefCount(A);
          if K = 1 then
          begin
            FreeDynarrayTVarRec(A);
            DynarrayTVarRec(A) := nil;
            Exit;
          end;
        end;

        K := _DynarrayRefCount(A);
        if K > 1 then
        begin
          _DynarrayDecRefCount(A);
          Exit;
        end;

        L := _DynarrayLength(A);
        P := ShiftPointer(A, - 2 * SizeOf(Integer));
        FreeMem(P, L * ElSize + 2);
        A := nil;
      end;
    end;
  end;
end;

procedure _DynarrayAssign(var Source, Dest: Pointer;
                          FinalTypeID, TypeID, ElSize: Integer); stdcall;
var
  K: Integer;
begin
  if Source = nil then
  begin
    _DynArrayClr(Dest, FinalTypeId, TypeId, ElSize);
    Exit;
  end;
  _DynarrayIncRefCount(Source);
  if Dest <> nil then
  begin
    K := _DynarrayDecRefCount(Dest);
    if K = 0 then
      _DynArrayClr(Dest, FinalTypeId, TypeId, ElSize);
  end;
  Dest := Source;
end;

procedure _AssignTVarRec(Address: Pointer; var Dest: TVarRec; TypeID: Integer);
stdcall;
var
  WS: WideString;
begin
  case TypeId of
    typeINTEGER:
    begin
      Dest.VType := vtInteger;
      Dest.VInteger := Integer(Address^);
    end;
    typeBYTE:
    begin
      Dest.VType := vtInteger;
      Dest.VInteger := Byte(Address^);
    end;
    typeWORD:
    begin
      Dest.VType := vtInteger;
      Dest.VInteger := Word(Address^);
    end;
    typeSHORTINT:
    begin
      Dest.VType := vtInteger;
      Dest.VInteger := ShortInt(Address^);
    end;
    typeSMALLINT:
    begin
      Dest.VType := vtInteger;
      Dest.VInteger := SmallInt(Address^);
    end;
    typeCARDINAL:
    begin
      Dest.VType := vtInt64;
      New(PInt64(Dest.VInt64));
      Dest.VInt64^ := Cardinal(Address^);
    end;
    typeINT64:
    begin
      Dest.VType := vtInt64;
      New(PInt64(Dest.VInt64));
      Dest.VInt64^ := Int64(Address^);
    end;
    typeCURRENCY:
    begin
      Dest.VType := vtCurrency;
      New(PCurrency(Dest.VCurrency));
      Dest.VCurrency^ := Currency(Address^);
    end;
    typeBOOLEAN:
    begin
      Dest.VType := vtBoolean;
      Dest.VBoolean := Boolean(Address^);
    end;
    typeANSICHAR:
    begin
      Dest.VType := vtChar;
      Dest.VChar := AnsiChar(Address^);
    end;
    typeDOUBLE, typeSINGLE, typeEXTENDED:
    begin
      Dest.VType := vtExtended;
      New(PExtended(Dest.VExtended));
      case TypeId of
        typeDOUBLE: PExtended(Dest.VExtended)^ := PDouble(Address)^;
        typeSINGLE: PExtended(Dest.VExtended)^ := PSingle(Address)^;
        typeEXTENDED: PExtended(Dest.VExtended)^ := PExtended(Address)^;
      end;
    end;
    typeSHORTSTRING:
    begin
      Dest.VType := vtString;
      New(PShortString(Dest.VString));
      PShortString(Dest.VString)^ := PShortString(Address)^;
    end;
    typePOINTER:
    begin
      Dest.VType := vtPointer;
      Dest.VPointer := Pointer(Address^);
    end;
    typePANSICHAR:
    begin
      Dest.VType := vtPChar;
      Dest.VPChar := Pointer(Address^);
    end;
    typeCLASS:
    begin
      Dest.VType := vtObject;
      Dest.VObject := TObject(Address^);
    end;
    typeCLASSREF:
    begin
      Dest.VType := vtClass;
      Dest.VClass := TClass(Address^);
    end;
    typeWIDECHAR:
    begin
      Dest.VType := vtWideChar;
      Dest.VWideChar := WideChar(Address^);
    end;
    typePWIDECHAR:
    begin
//      Dest.VType := vtPWideChar;
//      Dest.VPWideChar := Pointer(Address^);

      Dest.VType := vtString;
      New(PShortString(Dest.VString));

      _WideStringFromPWideChar(PWideChar(Pointer(Address^)), WS);

      PShortString(Dest.VString)^ := ShortString(WS);

    end;
    typeANSISTRING:
    begin
      Dest.VType := vtString;
      New(PShortString(Dest.VString));
      PShortString(Dest.VString)^ := PAnsiString(Address)^;
    end;
    typeVARIANT:
    begin
      Dest.VType := vtVariant;
      New(PVariant(Dest.VVariant));
      PVariant(Dest.VVariant)^ := PVariant(Address)^;
    end;
    typeWIDESTRING:
    begin
//      Dest.VType := vtWideString;
//      New(PWideString(Dest.VWideString));
//      PWideString(Dest.VWideString)^ := PWideString(Address)^;

      Dest.VType := vtString;
      New(PShortString(Dest.VString));
      PShortString(Dest.VString)^ := ShortString(PWideString(Address)^);
    end;
    typeUNICSTRING:
    begin
{
      Dest.VType := vtUnicodeString;
      New(PUnicString(Dest.VUnicodeString));
      PUnicString(Dest.VUnicodeString)^ := PUnicString(Address)^;
}
      Dest.VType := vtString;
      New(PShortString(Dest.VString));
      PShortString(Dest.VString)^ := ShortString(PUnicString(Address)^);
    end;
  end;
end;

procedure _IntOver; stdcall;
begin
  raise EIntOverflow.Create(errIntegerOverflow);
end;

procedure _BoundError; stdcall;
begin
  raise ERangeError.Create(errRangeCheckError);
end;

procedure _StringAddRef(var S: Pointer); stdcall;
var
  P: PStringRec;
begin
  if S <> nil then
  begin
    P := Pointer(Integer(S) - Sizeof(TStringRec));
    InterlockedIncrement(P^.RefCount);
  end;
end;

procedure _UnicStringAddRef(var S: Pointer); stdcall;
begin
  _StringAddRef(S);
end;


{$IFDEF LINUX}
procedure _WideStringAddRef(var S: PWideChar); stdcall;
begin
  _StringAddRef(S);
end;
{$ELSE}

function SysAllocStringLen(P: PWideChar; Len: Integer): PWideChar; stdcall;
  external 'oleaut32.dll' name 'SysAllocStringLen';
function _WStrAddRef(var str: PWideChar): Pointer;
asm
        MOV     EDX,[EAX]
        TEST    EDX,EDX
        JE      @@1
        PUSH    EAX
        MOV     ECX,[EDX-4]
        SHR     ECX,1
        PUSH    ECX
        PUSH    EDX
        CALL    SysAllocStringLen
        POP     EDX
//      TEST    EAX,EAX
//      JE      WStrError
        MOV     [EDX],EAX
@@1:
end;

procedure _WideStringAddRef(var S: PWideChar); stdcall;
begin
  _WStrAddRef(S);
end;

{$ENDIF}

procedure _DynarrayAddRef(P: Pointer); stdcall;
begin
  _DynarrayIncRefCount(P);
end;

procedure _InterfaceAddRef(var I: Pointer); stdcall;
begin
  IUnknown(I)._AddRef;
end;

procedure _VariantAddRef(var V: Variant); stdcall;
var
  VT: Integer;
begin
  VT := VarType(V);
  if VT = varString then
    _StringAddRef(TVarData(V).VString)
  else if VT = varOleStr then
    _StringAddRef(Pointer(TVarData(V).VOleStr))
  else if VT = varUnknown then
    _InterfaceAddRef(TVarData(V).VUnknown);
end;

function TObject_InstanceSize(Self: TObject): Integer;
begin
  result := Self.InstanceSize;
end;

function TObject_ClassName(IsClass: Integer; P: Pointer): ShortString; stdcall;
var
  X: TObject;
  S: String;
begin
  if IsClass = 1 then
  begin
    S := TClass(P).ClassName;
    result := ShortString(S);
  end
  else
  begin
    X := TObject(P);
    S := X.ClassName;
    result := ShortString(S);
  end;
end;

function GetRefCount(Self: TInterfacedObject): Integer;
begin
  result := Self.RefCount;
end;

function _Round(E: Extended): Int64;
begin
  result := Round(E);
end;

procedure Dummy;
begin
end;

// TPaxClassFactoryRec -------

constructor TPaxClassFactoryRec.Create(const AFullClassName: String);
begin
  inherited Create;
  FillChar(PaxClassRec, SizeOf(PaxClassRec), 0);
  FieldClassTable := nil;
  FullClassName := AFullClassName;
end;

destructor TPaxClassFactoryRec.Destroy;
begin
  if MethodTableSize > 0 then
    FreeMem(VMTPtr^.MethodTable, MethodTableSize);
  if FieldTableSize > 0 then
    FreeMem(VMTPtr^.FieldTable, FieldTableSize);
  if FieldClassTable <> nil then
    DestroyFieldClassTable(FieldClassTable);

  inherited;
end;

function TPaxClassFactoryRec.GetDelphiClass: TClass;
begin
  result := PaxClassRec.VMT.SelfPtr;
end;

function TPaxClassFactoryRec.GetVMTPtr: PVMT;
begin
  result := @ PaxClassRec.VMT;
end;

procedure TPaxClassFactoryRec.SetInstanceSize(value: Integer);
begin
  PaxClassRec.VMT.InstanceSize := value;
end;

function _NewInstance(Self: TClass): TObject;
var
  S: Integer;
begin
  S := Self.InstanceSize;
  result := Self.InitInstance(AllocMem(S));
end;

procedure TPaxClassFactoryRec.SetParentClass(AClass: TClass);
var
  ParentVMT: PVMT;
begin
  fParentClass := AClass;

  ParentVMT := GetVmtFromClass(AClass);
  PaxClassRec.VMT.IntfTable := ParentVMT.IntfTable;
  PaxClassRec.VMT.AutoTable := ParentVMT.AutoTable;
  PaxClassRec.VMT.InitTable := ParentVMT.InitTable;
  PaxClassRec.VMT.TypeInfo := ParentVMT.TypeInfo;
  PaxClassRec.VMT.FieldTable := ParentVMT.FieldTable;
  PaxClassRec.VMT.MethodTable := ParentVMT.MethodTable;
  PaxClassRec.VMT.DynamicTable := ParentVMT.DynamicTable;

  PaxClassRec.VMT.NewInstance := ParentVMT.NewInstance;
  PaxClassRec.VMT.SafeCallException := ParentVMT.SafeCallException;
  PaxClassRec.VMT.AfterConstruction := ParentVMT.AfterConstruction;
  PaxClassRec.VMT.BeforeDestruction := ParentVMT.BeforeDestruction;
  PaxClassRec.VMT.Dispatch := ParentVMT.Dispatch;
  PaxClassRec.VMT.DefaultHandler := ParentVMT.DefaultHandler;
end;

// TPaxClassFactory -----------------------------------

constructor TPaxClassFactory.Create;
begin
  inherited;
  ForceCreate := false;
end;

procedure TPaxClassFactory.RaiseError(const Message: string; params: array of Const);
begin
  raise Exception.Create(Format(Message, params));
end;

procedure _AfterConstruction(Self: TObject);
begin
end;

procedure _BeforeDestruction(Self: TObject);
begin
end;

function TPaxClassFactory.CreatePaxClass(const AFullClassName: String;
                                         AnInstanceSize: Integer;
                                         ParentClass: TClass): TClass;
var
  PaxClassObject: TPaxClassFactoryRec;
begin
  PaxClassObject := TPaxClassFactoryRec.Create(AFullClassName);
  PaxClassObject.fClassName := ShortString(ExtractName(AFullClassName));
  PaxClassObject.fParentClass := ParentClass;
  PaxClassObject.PaxClassRec.VMT.SelfPtr := GetClassFromVMT(@PaxClassObject.PaxClassRec.VMT);
  PaxClassObject.PaxClassRec.VMT.Parent := @ PaxClassObject.fParentClass;
  PaxClassObject.PaxClassRec.VMT.ClassName := @ PaxClassObject.fClassName;
  PaxClassObject.PaxClassRec.VMT.InstanceSize := AnInstanceSize;
  PaxClassObject.PaxClassRec.VMT.NewInstance := @_NewInstance;
  PaxClassObject.PaxClassRec.VMT.AfterConstruction := @_AfterConstruction;
  PaxClassObject.PaxClassRec.VMT.BeforeDestruction := @_BeforeDestruction;
  PaxClassObject.PaxClassRec.VMT.Destroy := @_DestroyObject;
  L.Add(PaxClassObject);

  result := PaxClassObject.DelphiClass;

  PaxClassObject.PaxClassRec.PaxInfo.PaxSignature := strPaxSignature;
end;

function TPaxClassFactory.CreateCloneClass(const AFullClassName: String;
                                           ParentClass: TClass): TClass;
var
  PaxClassObject: TPaxClassFactoryRec;
  ParentVMT: PVMT;
begin
  ParentVMT := GetVmtFromClass(ParentClass);

  PaxClassObject := TPaxClassFactoryRec.Create(AFullClassName);
  PaxClassObject.fClassName := ShortString(ExtractName(AFullClassName));
  PaxClassObject.fParentClass := ParentClass;
  PaxClassObject.PaxClassRec.VMT.SelfPtr := GetClassFromVMT(@PaxClassObject.PaxClassRec.VMT);
  PaxClassObject.PaxClassRec.VMT.IntfTable := ParentVMT.IntfTable;
  PaxClassObject.PaxClassRec.VMT.AutoTable := ParentVMT.AutoTable;

  PaxClassObject.PaxClassRec.VMT.Parent := @ PaxClassObject.fParentClass;
  PaxClassObject.PaxClassRec.VMT.ClassName := @ PaxClassObject.fClassName;
  PaxClassObject.PaxClassRec.VMT.InstanceSize := ParentClass.InstanceSize;
  PaxClassObject.PaxClassRec.VMT.NewInstance := ParentVMT.NewInstance;
  PaxClassObject.PaxClassRec.VMT.AfterConstruction := ParentVMT.AfterConstruction;
  PaxClassObject.PaxClassRec.VMT.BeforeDestruction := ParentVMT.BeforeDestruction;
  PaxClassObject.PaxClassRec.VMT.Destroy := ParentVMT.Destroy;
  L.Add(PaxClassObject);
  result := PaxClassObject.DelphiClass;

  PaxClassObject.PaxClassRec.PaxInfo.PaxSignature := strPaxSignature;
end;

{
  TVmt = packed record
    SelfPtr           : TClass;              // -76	pointer to virtual method table (or nil)
    IntfTable         : Pointer;             // -72	pointer to interface table (or nil)
    AutoTable         : Pointer;             // -68	pointer to Automation information table (or nil)
    InitTable         : Pointer;             // -64	pointer to instance initialization table (or nil)
    TypeInfo          : Pointer;             // -60	pointer to type information table (or nil)
    FieldTable        : Pointer;             // -56	pointer to field definition table (or nil)
    MethodTable       : Pointer;             // -52	pointer to method definition table (or nil)
    DynamicTable      : Pointer;             // -48	pointer to dynamic method table (or nil)
    ClassName         : PShortString;        // -44	pointer to short string containing class name
    InstanceSize      : Cardinal;            // -40	instance size in bytes
    Parent            : PClass;              // -36	pointer to a pointer to ancestor class (or nil)
    SafeCallException : PSafeCallException;  // -32	pointer to entry point of SafecallException method (or nil)
    AfterConstruction : PAfterConstruction;  // -28	entry point of AfterConstruction method
    BeforeDestruction : PBeforeDestruction;  // -24	entry point of BeforeDestruction method
    Dispatch          : PDispatch;           // -20	entry point of Dispatch method
    DefaultHandler    : PDefaultHandler;     // -16	entry point of DefaultHandler method
    NewInstance       : PNewInstance;        // -12	entry point of NewInstance method
    FreeInstance      : PFreeInstance;       // -8	entry point of FreeInstance method
    Destroy           : PDestroy;            // -4	entry point of Destroy destructor
  end;
}

function TPaxClassFactory.GetRecord(I: Integer): TPaxClassFactoryRec;
begin
  result := TPaxClassFactoryRec(L[I]);
end;

function TPaxClassFactory.FindRecord(AClass: TClass): TPaxClassFactoryRec;
var
  I: Integer;
begin
  result := nil;
  for I:=0 to Count - 1 do
    if Records[I].DelphiClass = AClass then
    begin
      result := Records[I];
      break;
    end;
end;

function TPaxClassFactory.FindRecordByFullName(const AFullClassName: String): TPaxClassFactoryRec;
var
  I: Integer;
begin
  result := nil;
  for I:=0 to Count - 1 do
    if StrEql(Records[I].FullClassName, AFullClassName) then
    begin
      result := Records[I];
      break;
    end;
end;

function TPaxClassFactory.LookupFullName(const AFullClassName: String): TClass;
var
  I: Integer;
begin
  result := nil;
  for I:=0 to Count - 1 do
    if StrEql(Records[I].FullClassName, AFullClassName) then
    begin
      result := Records[I].DelphiClass;
      break;
    end;
end;

procedure TPaxClassFactory.Reset;
var
  I: Integer;
begin
  for I:=0 to Count - 1 do
    Records[I].Processed := false;
end;

procedure TPaxClassFactory.SetupStdVirtuals(ClassList: TClassList;
                                            CodePtr: Pointer);
var
  I: Integer;
  ClassRec: TClassRec;
  FactoryRec: TPaxClassFactoryRec;
  P: Pointer;
begin
  for I:=0 to ClassList.Count - 1 do
  begin
    ClassRec := ClassList[I];
    if not ClassRec.Host then
    begin
      FactoryRec := FindRecord(ClassRec.PClass);

      if ClassRec.SafeCallExceptionProgOffset > 0 then
      begin
        P := ShiftPointer(CodePtr, ClassRec.SafeCallExceptionProgOffset);
        FactoryRec.GetVMTPtr^.SafeCallException := P;
      end;
      if ClassRec.AfterConstructionProgOffset > 0 then
      begin
        P := ShiftPointer(CodePtr, ClassRec.AfterConstructionProgOffset);
        FactoryRec.GetVMTPtr^.AfterConstruction := P;
      end;
      if ClassRec.BeforeDestructionProgOffset > 0 then
      begin
        P := ShiftPointer(CodePtr, ClassRec.BeforeDestructionProgOffset);
        FactoryRec.GetVMTPtr^.BeforeDestruction := P;
      end;
      if ClassRec.DispatchProgOffset > 0 then
      begin
        P := ShiftPointer(CodePtr, ClassRec.DispatchProgOffset);
        FactoryRec.GetVMTPtr^.Dispatch := P;
      end;
      if ClassRec.DefaultHandlerProgOffset > 0 then
      begin
        P := ShiftPointer(CodePtr, ClassRec.DefaultHandlerProgOffset);
        FactoryRec.GetVMTPtr^.DefaultHandler := P;
      end;
      if ClassRec.NewInstanceProgOffset > 0 then
      begin
        P := ShiftPointer(CodePtr, ClassRec.NewInstanceProgOffset);
        FactoryRec.GetVMTPtr^.NewInstance := P;
      end;
      if ClassRec.FreeInstanceProgOffset > 0 then
      begin
        P := ShiftPointer(CodePtr, ClassRec.FreeInstanceProgOffset);
        FactoryRec.GetVMTPtr^.FreeInstance := P;
      end;
    end;
  end;
end;

procedure TPaxClassFactory.SetupParents(ClassList: TClassList);
var
  I, J: Integer;
  ClassFactoryRec, ParentFactoryRec: TPaxClassFactoryRec;
  ClassRec, ParentClassRec: TClassRec;
  C: TClass;
  b: Boolean;
  S: String;
begin
  Reset;

  repeat
    b := false;

    for I:=0 to Count - 1 do
    begin
      ClassFactoryRec := Records[I];
      if ClassFactoryRec.Processed then
        continue;

      C := ClassFactoryRec.DelphiClass;
      J := ClassList.FindClass(C);
      if J = -1 then
        raise Exception.Create(errInternalError);

      ClassRec := ClassList[J];
      ParentClassRec := ClassList.Lookup(ClassRec.ParentFullName);

      if ParentClassRec = nil then
        RaiseError(errInternalError, []);

      if ParentClassRec.Host then // parent is host
      begin
        if ParentClassRec.PClass = nil then
        begin
          S := ExtractName(ClassRec.ParentFullName);
          ParentClassRec.PClass := Classes.GetClass(S);
          if ParentClassRec.PClass = nil then
            RaiseError(errClassIsNotRegistered, [S]);
        end;

        b := true;
        ClassFactoryRec.SetParentClass(ParentClassRec.PClass);
        ClassFactoryRec.Processed := true;
      end
      else
      begin
        ParentFactoryRec := FindRecord(ParentClassRec.PClass);

        if ParentFactoryRec = nil then
          raise Exception.Create(errInternalError);

        if ParentFactoryRec.Processed then
        begin
          b := true;
          ClassFactoryRec.SetParentClass(ParentClassRec.PClass);
          ClassFactoryRec.Processed := true;
        end;
      end;
    end;

    if b = false then
      break;

  until false;
end;

procedure TPaxClassFactory.AddInheritedMethods;
var
  I: Integer;
  ClassFactoryRec, ParentFactoryRec: TPaxClassFactoryRec;
  C: TClass;
  b: Boolean;
begin
  Reset;

  repeat
    b := false;

    for I:=0 to Count - 1 do
    begin
      ClassFactoryRec := Records[I];
      if ClassFactoryRec.Processed then
        continue;
      C := ClassFactoryRec.DelphiClass;

      ParentFactoryRec := FindRecord(C.ClassParent);
      if ParentFactoryRec = nil then // parent is host
      begin
        b := true;
        AddInheritedMethods(C);
        ClassFactoryRec.Processed := true;
      end
      else if ParentFactoryRec.Processed then
      begin
        b := true;
        AddInheritedMethods(C);
        ClassFactoryRec.Processed := true;
      end;
    end;

    if b = false then
      break;

  until false;
end;

procedure TPaxClassFactory.AddOverridenMethods(AProg: Pointer; ScriptMapTable: TMapTable);
var
  I, J, K: Integer;
  ClassFactoryRec, ParentFactoryRec: TPaxClassFactoryRec;
  C: TClass;
  b: Boolean;
  MapRec, SomeMR: TMapRec;
  P: Pointer;
  Prog: TProgram;
  S, FileName, ProcName: String;
begin
  Reset;

  Prog := TProgram(AProg);

  repeat
    b := false;

    for I:=0 to Count - 1 do
    begin
      ClassFactoryRec := Records[I];
      if ClassFactoryRec.Processed then
        continue;
      C := ClassFactoryRec.DelphiClass;

      ParentFactoryRec := FindRecord(C.ClassParent);

      if (ParentFactoryRec = nil) or ((ParentFactoryRec <> nil) and (ParentFactoryRec.Processed)) then
      begin
        b := true;
        ClassFactoryRec.Processed := true;

        for J:=0 to ScriptMapTable.Count - 1 do
        begin
          MapRec := ScriptMapTable[J];
          if MapRec.SubDesc.MethodIndex > 0 then
          begin
            S := ExtractClassName(MapRec.FullName);
            if not StrEql(S, String(ClassFactoryRec.fClassName)) then
              continue;

            if MapRec.Offset = 0 then
            begin
              FileName := ExtractOwner(MapRec.FullName) + '.' + PCU_FILE_EXT;
              ProcName := Copy(MapRec.FullName, PosCh('.', MapRec.FullName) + 1, Length(MapRec.FullName));
              P := Prog.RootProg.ProgList.LoadAddress(FileName, ProcName, false, 0, SomeMR);
            end
            else
              P := ShiftPointer(Prog.CodePtr, MapRec.Offset);

            C := ClassFactoryRec.DelphiClass;
            PPointerArray(C)^[MapRec.SubDesc.MethodIndex - 1] := P;

            for K:=0 to Count - 1 do
              if K <> I then
              if Records[K].DelphiClass.InheritsFrom(C) then
                PPointerArray(Records[K].DelphiClass)^[MapRec.SubDesc.MethodIndex - 1] := P;
          end;
        end;
      end;
    end;

    if b = false then
      break;

  until false;
end;

{
procedure TPaxClassFactory.AddOverridenMethods(AProg: Pointer; ScriptMapTable: TMapTable);
var
  I, J, K: Integer;
  ClassFactoryRec, ParentFactoryRec: TPaxClassFactoryRec;
  C: TClass;
  b: Boolean;
  MapRec: TMapRec;
  P: Pointer;
  Prog: TProgram;
  S: AnsiString;
begin
  Reset;

  Prog := TProgram(AProg);

  repeat
    b := false;

    for I:=0 to Count - 1 do
    begin
      ClassFactoryRec := Records[I];
      if ClassFactoryRec.Processed then
        continue;
      C := ClassFactoryRec.DelphiClass;

      ParentFactoryRec := FindRecord(C.ClassParent);
      if ParentFactoryRec = nil then // parent is host
      begin
        b := true;
        ClassFactoryRec.Processed := true;
      end
      else if ParentFactoryRec.Processed then
      begin
        b := true;
        ClassFactoryRec.Processed := true;

        for J:=0 to ScriptMapTable.Count - 1 do
        begin
          MapRec := ScriptMapTable[J];
          if MapRec.MethodIndex > 0 then
          begin
            S := ExtractClassName(MapRec.FullName);
            if not StrEql(S, ClassFactoryRec.fClassName) then
              continue;

            P := ShiftPointer(Prog.CodePtr, MapRec.Offset);
            C := ClassFactoryRec.DelphiClass;
            PPointerArray(C)^[MapRec.MethodIndex - 1] := P;

            for K:=0 to Count - 1 do
              if Records[K].DelphiClass.InheritsFrom(C) then
                PPointerArray(Records[K].DelphiClass)^[MapRec.MethodIndex - 1] := P;
          end;
        end;
      end;
    end;

    if b = false then
      break;

  until false;
end;
}

function VirtualMethodIndex(P: PPointerArray; A: Pointer): Integer;
const
  VMTPackageJump : word = $25FF;
var
  I: Integer;
  CurrA: Pointer;
begin
  if ModuleIsPackage and (A <> nil) and (PWord (A)^ = VMTPackageJump)
    then A := PPointer (PPointer (Integer (A) + sizeof (VMTPackageJump))^)^;

  result := -1;
  for I:=0 to MaxVirtuals do
  begin
    CurrA := P^[I];
    if CurrA = A then
    begin
      result := I;
      Exit;
    end
    else if CurrA = nil then
      Exit;
  end;
end;

function GetVirtualMethodCount(AClass: TClass): Integer;
var
  P: PPointerArray;
  I: Integer;
begin
  P := PPointerArray(AClass);
  result := 0;
  for I:=0 to MaxVirtuals do
    if P^[I] <> nil then
      Inc(result)
    else
      break;
end;

function GetVirtualMethod(AClass: TClass; const Index: Integer): Pointer;
begin
  Result := PPointer(Integer(AClass) + Index * SizeOf(Pointer))^;
end;

function GetVirtualMethodOffset(AClass: TClass; Address: Pointer): Integer;
var
  I: Integer;
  P: Pointer;
begin
  for I:=0 to GetVirtualMethodCount(AClass) - 1 do
  begin
    P := GetVirtualMethod(AClass, I);
    if P = Address then
    begin
      result := I * 4;
      Exit;
    end;
  end;
  result := -1;
end;

procedure TPaxClassFactory.AddInheritedMethods(SourceClass: TClass);
var
  P, Q: PPointerArray;
  I, K: Integer;
begin
  if SourceClass.ClassParent = nil then
    Exit;

  P := PPointerArray(SourceClass.ClassParent);
  K := GetVirtualMethodCount(SourceClass.ClassParent);

  Q := PPointerArray(SourceClass);
  for I:=0 to K - 1 do
    Q^[I] := P^[I];
end;

procedure TPaxClassFactory.AddVirtualMethod(SourceClass: TClass;
                                            SourceMethodAddress: Pointer);
var
  P: PPointerArray;
  K: Integer;
begin
  P := PPointerArray(SourceClass);
  K := GetVirtualMethodCount(SourceClass);
  P^[K] := SourceMethodAddress;
end;

function TPaxClassFactory.AddOverridenMethod(SourceClass: TClass;
                                          SourceMethodAddress,
                                          InheritedMethodAddress: Pointer): Boolean;
var
  P: PPointerArray;
  I: Integer;
begin
  result := false;
  if SourceClass.ClassParent = nil then
    Exit;

  P := PPointerArray(SourceClass.ClassParent);
  I := VirtualMethodIndex(P, InheritedMethodAddress);

  if I = -1 then
    Exit;

  P := PPointerArray(SourceClass);
  P^[I] := SourceMethodAddress;

  result := true;
end;

//--  TScriptClassRec ----------------------------------------------------------

constructor TScriptClassRec.Create;
begin
  inherited;
  Processed := false;
  VirtualMethodList := TIntegerList.Create;
end;

destructor TScriptClassRec.Destroy;
begin
  VirtualMethodList.Free;
  inherited;
end;

//--  TScriptClassList ---------------------------------------------------------

function TScriptClassList.Add: TScriptClassRec;
begin
  result := TScriptClassRec.Create;
  L.Add(result);
end;

procedure TScriptClassList.Reset;
var
  I: Integer;
begin
  for I:=0 to Count - 1 do
    Records[I].Processed := false;
end;

function TScriptClassList.FindClass(ClassId: Integer): TScriptClassRec;
var
  I: Integer;
begin
  result := nil;
  for I:=0 to Count - 1 do
    if Records[I].ClassId = ClassId then
    begin
      result := Records[I];
      Exit;
    end;
end;

function TScriptClassList.GetRecord(I: Integer): TScriptClassRec;
begin
  result := TScriptClassRec(L[I]);
end;

//------------------------------------------------------------------------------

procedure TMyInterfacedObject_AddRef(Self: TObject); stdcall;
begin
  TMyInterfacedObject(Self)._AddRef;
end;

procedure TMyInterfacedObject_Release(Self: TObject); stdcall;
begin
  TMyInterfacedObject(Self)._Release;
end;

function TObject_GetInterface(Self: TObject; const IID: TGUID; out Obj): Boolean;
begin
  result := Self.GetInterface(IID, Obj);
end;

procedure Set_ExitCode(P: TProgram; value: Integer); stdcall;
begin
  P.ExitCode := value;
end;

function Get_ExitCode(P: TProgram): Integer; stdcall;
begin
  result := P.ExitCode;
end;

var
  H_Namespace, H_Sub, H: Integer;
  H_R0_7, H_TGUID_D4, H_TEntries: Integer;

const
  ByRef = true;

initialization

  GlobalSymbolTable := TBaseSymbolTable.Create;
  with GlobalSymbolTable do
  begin
    Reset;

    RegisterRoutine(0, strWrite, typeVOID,  ccREGISTER, @_Write);

    H_Sub := RegisterRoutine(0, strWriteln, typeVOID, ccREGISTER, @_Writeln);
    H_Writeln := H_Sub;

    H_Sub := RegisterRoutine(0, '', typeVOID, ccREGISTER, @_WriteBool);
    Id_WriteBool := LastSubId;
    RegisterParameter(H_Sub, typeBOOLEAN, Unassigned);
    H_WriteBool := H_Sub;

    H_Sub := RegisterRoutine(0, '', typeVOID, ccREGISTER, @_WriteByteBool);
    Id_WriteByteBool := LastSubId;
    RegisterParameter(H_Sub, typeBYTEBOOL, Unassigned);
    H_WriteByteBool := H_Sub;

    H_Sub := RegisterRoutine(0, '', typeVOID, ccREGISTER, @_WriteWordBool);
    Id_WriteWordBool := LastSubId;
    RegisterParameter(H_Sub, typeWORDBOOL, Unassigned);
    H_WriteWordBool := H_Sub;

    H_Sub := RegisterRoutine(0, '', typeVOID, ccREGISTER, @_WriteLongBool);
    Id_WriteLongBool := LastSubId;
    RegisterParameter(H_Sub, typeLONGBOOL, Unassigned);
    H_WriteLongBool := H_Sub;

    H_Sub := RegisterRoutine(0, '', typeVOID, ccREGISTER, @_WriteAnsiChar);
    Id_WriteAnsiChar := LastSubId;
    RegisterParameter(H_Sub, typeANSICHAR, Unassigned);
    H_WriteAnsiChar := H_Sub;

    H_Sub := RegisterRoutine(0, '', typeVOID, ccREGISTER, @_WriteByte);
    Id_WriteByte := LastSubId;
    RegisterParameter(H_Sub, typeBYTE, Unassigned);
    RegisterParameter(H_Sub, typeINTEGER, Unassigned);
    H_WriteByte := H_Sub;

    H_Sub := RegisterRoutine(0, '', typeVOID, ccREGISTER, @_WriteWord);
    Id_WriteWord := LastSubId;
    RegisterParameter(H_Sub, typeWORD, Unassigned);
    RegisterParameter(H_Sub, typeINTEGER, Unassigned);
    H_WriteWord := H_Sub;

    H_Sub := RegisterRoutine(0, '', typeVOID, ccREGISTER, @_WriteCardinal);
    Id_WriteCardinal := LastSubId;
    RegisterParameter(H_Sub, typeCARDINAL, Unassigned);
    RegisterParameter(H_Sub, typeINTEGER, Unassigned);
    H_WriteCardinal := H_Sub;

    H_Sub := RegisterRoutine(0, '', typeVOID, ccREGISTER, @_WriteSmallInt);
    Id_WriteSmallInt := LastSubId;
    RegisterParameter(H_Sub, typeSMALLINT, Unassigned);
    RegisterParameter(H_Sub, typeINTEGER, Unassigned);
    H_WriteSmallInt := H_Sub;

    H_Sub := RegisterRoutine(0, '', typeVOID, ccREGISTER, @_WriteShortInt);
    Id_WriteShortInt := LastSubId;
    RegisterParameter(H_Sub, typeSHORTINT, Unassigned);
    RegisterParameter(H_Sub, typeINTEGER, Unassigned);
    H_WriteShortInt := H_Sub;

    H_Sub := RegisterRoutine(0, '', typeVOID, ccREGISTER, @_WriteInt);
    Id_WriteInt := LastSubId;
    RegisterParameter(H_Sub, typeINTEGER, Unassigned);
    RegisterParameter(H_Sub, typeINTEGER, Unassigned);
    H_WriteInteger := H_Sub;

    H_Sub := RegisterRoutine(0, '', typeVOID, ccREGISTER, @_WriteInt64);
    Id_WriteInt64 := LastSubId;
    RegisterParameter(H_Sub, typeINT64, Unassigned);
    RegisterParameter(H_Sub, typeINTEGER, Unassigned);
    H_WriteInt64 := H_Sub;

    H_Sub := RegisterRoutine(0, '', typeVOID, ccREGISTER, @_WriteDouble);
    Id_WriteDouble := LastSubId;
    RegisterParameter(H_Sub, typeDOUBLE, Unassigned);
    RegisterParameter(H_Sub, typeINTEGER, Unassigned);
    RegisterParameter(H_Sub, typeINTEGER, Unassigned);
    H_WriteDouble := H_Sub;

    H_Sub := RegisterRoutine(0, '', typeVOID, ccREGISTER, @_WriteSingle);
    Id_WriteSingle := LastSubId;
    RegisterParameter(H_Sub, typeSINGLE, Unassigned);
    RegisterParameter(H_Sub, typeINTEGER, Unassigned);
    RegisterParameter(H_Sub, typeINTEGER, Unassigned);
    H_WriteSingle := H_Sub;

    H_Sub := RegisterRoutine(0, '', typeVOID, ccREGISTER, @_WriteCurrency);
    Id_WriteCurrency := LastSubId;
    RegisterParameter(H_Sub, typeCURRENCY, Unassigned);
    RegisterParameter(H_Sub, typeINTEGER, Unassigned);
    RegisterParameter(H_Sub, typeINTEGER, Unassigned);
    H_WriteCurrency := H_Sub;

    H_Sub := RegisterRoutine(0, '', typeVOID, ccREGISTER, @_WriteExtended);
    Id_WriteExtended := LastSubId;
    RegisterParameter(H_Sub, typeEXTENDED, Unassigned);
    RegisterParameter(H_Sub, typeINTEGER, Unassigned);
    RegisterParameter(H_Sub, typeINTEGER, Unassigned);
    H_WriteExtended := H_Sub;

    H_Sub := RegisterRoutine(0, '', typeVOID, ccREGISTER, @_WriteString);
    Id_WriteString := LastSubId;
    RegisterParameter(H_Sub, typeANSISTRING, Unassigned);
    Records[Card].IsConst := true;
    RegisterParameter(H_Sub, typeINTEGER, Unassigned);
    H_WriteAnsiString := H_Sub;

    H_Sub := RegisterRoutine(0, '', typeVOID, ccREGISTER, @_WriteShortString);
    Id_WriteShortString := LastSubId;
    RegisterParameter(H_Sub, typeSHORTSTRING, Unassigned);
    RegisterParameter(H_Sub, typeINTEGER, Unassigned);
    H_WriteShortString := H_Sub;

    H_Sub := RegisterRoutine(0, '', typeVOID, ccREGISTER, @_WriteWideChar);
    Id_WriteWideChar := LastSubId;
    RegisterParameter(H_Sub, typeWIDECHAR, Unassigned);
    H_WriteWideChar := H_Sub;

    H_Sub := RegisterRoutine(0, '', typeVOID, ccREGISTER, @_WriteWideString);
    Id_WriteWideString := LastSubId;
    RegisterParameter(H_Sub, typeWIDESTRING, Unassigned);
    RegisterParameter(H_Sub, typeINTEGER, Unassigned);
    H_WriteWideString := H_Sub;

    H_Sub := RegisterRoutine(0, '', typeVOID, ccREGISTER, @_WriteVariant);
    Id_WriteVariant := LastSubId;
    RegisterParameter(H_Sub, typeVARIANT, Unassigned);
    RegisterParameter(H_Sub, typeINTEGER, Unassigned);
    RegisterParameter(H_Sub, typeINTEGER, Unassigned);
    H_WriteVariant := H_Sub;

    H_Sub := RegisterRoutine(0, '', typeVOID, ccREGISTER, @_WriteObject);
    Id_WriteObject := LastSubId;
    RegisterParameter(H_Sub, typeCLASS, Unassigned);
    H_WriteObject := H_Sub;

//--------- SET ROUTINES -------------------------------------------------------

    RegisterRoutine(0, '', typeVOID, ccSTDCALL, @_SetInclude);
    Id_SetInclude := LastSubId;

    RegisterRoutine(0, '', typeVOID, ccSTDCALL, @_SetIncludeInterval);
    Id_SetIncludeInterval := LastSubId;

    RegisterRoutine(0, '', typeVOID,  ccSTDCALL, @_SetExclude);
    Id_SetExclude := LastSubId;

    RegisterRoutine(0, '', typeVOID, ccSTDCALL,  @_SetUnion);
    Id_SetUnion := LastSubId;

    H_Sub := RegisterRoutine(0, '', typeVOID, ccSTDCALL, @_SetDifference);
    Id_SetDifference := LastSubId;

    RegisterRoutine(0, '', typeVOID, ccSTDCALL, @_SetIntersection);
    Id_SetIntersection := LastSubId;

    RegisterRoutine(0, '', typeBOOLEAN, ccSTDCALL, @_SetSubset);
    Id_SetSubset := LastSubId;

    RegisterRoutine(0, '', typeBOOLEAN, ccSTDCALL, @_SetSuperset);
    Id_SetSuperset := LastSubId;

    RegisterRoutine(0, '', typeBOOLEAN, ccSTDCALL, @_SetEquality);
    Id_SetEquality := LastSubId;

    RegisterRoutine(0, '', typeBOOLEAN, ccSTDCALL, @_SetInequality);
    Id_SetInequality := LastSubId;

    RegisterRoutine(0, '', typeBOOLEAN, ccSTDCALL, @_SetMembership);
    Id_SetMembership := LastSubId;

    RegisterRoutine(0, '', typeVOID, ccSTDCALL, @ _LoadProc);
    Id_LoadProc := LastSubId;

//--------- AnsiString ROUTINES ----------------------------------------------------

    RegisterRoutine(0, '', typeVOID, ccSTDCALL, @ _AnsiStringFromPAnsiChar);
    Id_AnsiStringFromPAnsiChar := LastSubId;

    RegisterRoutine(0, '', typeVOID, ccSTDCALL, @_WideStringFromPAnsiChar);
    Id_WideStringFromPAnsiChar := LastSubId;

    RegisterRoutine(0, '', typeVOID, ccSTDCALL, @_WideStringFromPWideChar);
    Id_WideStringFromPWideChar := LastSubId;

    RegisterRoutine(0, '', typeVOID, ccSTDCALL, @_AnsiStringFromAnsiChar);
    Id_AnsiStringFromAnsiChar := LastSubId;

    RegisterRoutine(0, '', typeVOID, ccSTDCALL, @_WideStringFromAnsiChar);
    Id_WideStringFromAnsiChar := LastSubId;

    RegisterRoutine(0, '', typeVOID, ccSTDCALL, @ _WideStringFromWideChar);
    Id_WideStringFromWideChar := LastSubId;

    RegisterRoutine(0, '', typeVOID, ccSTDCALL, @ _AnsiStringFromWideChar);
    Id_AnsiStringFromWideChar := LastSubId;

    RegisterRoutine(0, '', typeVOID, ccSTDCALL, @_AnsiStringAssign);
    Id_AnsiStringAssign := LastSubId;

    RegisterRoutine(0, '', typeVOID, ccSTDCALL, @_WideStringAssign);
    Id_WideStringAssign := LastSubId;

    RegisterRoutine(0, '', typeVOID, ccSTDCALL, @_AnsiStringAddition);
    Id_AnsiStringAddition := LastSubId;

    RegisterRoutine(0, '', typeVOID, ccSTDCALL, @_WideStringAddition);
    Id_WideStringAddition := LastSubId;

    RegisterRoutine(0, '', typeVOID, ccSTDCALL, @_ShortStringAssign);
    Id_ShortStringAssign := LastSubId;

    RegisterRoutine(0, '', typeVOID, ccSTDCALL, @_ShortStringAddition);
    Id_ShortStringAddition := LastSubId;

    RegisterRoutine(0, '', typeVOID, ccSTDCALL, @_AnsiStringClr);
    Id_AnsiStringClr := LastSubId;

    RegisterRoutine(0, '', typeVOID, ccSTDCALL, @_WideStringClr);
    Id_WideStringClr := LastSubId;

    RegisterRoutine(0, '', typeVOID, ccSTDCALL, @_InterfaceClr);
    Id_InterfaceClr := LastSubId;

    RegisterRoutine(0, '', typeVOID, ccSTDCALL, @_StringAddRef);
    Id_StringAddRef := LastSubId;

    RegisterRoutine(0, '', typeVOID, ccSTDCALL, @_WideStringAddRef);
    Id_WideStringAddRef := LastSubId;

    RegisterRoutine(0, '', typeVOID, ccSTDCALL, @_DynarrayAddRef);
    Id_DynarrayAddRef := LastSubId;

    RegisterRoutine(0, '', typeVOID, ccSTDCALL, @_InterfaceAddRef);
    Id_InterfaceAddRef := LastSubId;

    RegisterRoutine(0, '', typeVOID, ccSTDCALL, @_VariantAddRef);
    Id_VariantAddRef := LastSubId;

    RegisterRoutine(0, '', typeVOID, ccSTDCALL, @_ShortStringFromAnsiString);
    Id_ShortStringFromAnsiString := LastSubId;

    RegisterRoutine(0, '', typeVOID, ccSTDCALL, @_ShortStringFromWideString);
    Id_ShortStringFromWideString := LastSubId;

    RegisterRoutine(0, '', typeVOID, ccSTDCALL, @_AnsiStringFromShortString);
    Id_AnsiStringFromShortString := LastSubId;

    RegisterRoutine(0, '', typeVOID, ccSTDCALL, @_WideStringFromShortString);
    Id_WideStringFromShortString := LastSubId;

    RegisterRoutine(0, '', typeVOID, ccSTDCALL, @_AnsiStringFromWideString);
    Id_AnsiStringFromWideString := LastSubId;

    RegisterRoutine(0, '', typeVOID, ccSTDCALL, @_WideStringFromAnsiString);
    Id_WideStringFromAnsiString := LastSubId;

    H_Sub := RegisterRoutine(0, '', typeVOID, ccSTDCALL, @_StrInt);
    Id_StrInt := LastSubId;
    RegisterParameter(H_Sub, typeANSISTRING, Unassigned, ByRef);
    RegisterParameter(H_Sub, typeINTEGER, Unassigned);
    RegisterParameter(H_Sub, typeINTEGER, Unassigned);
    RegisterParameter(H_Sub, typeINTEGER, Unassigned);

    H_Sub := RegisterRoutine(0, '', typeVOID, ccSTDCALL, @_StrDouble);
    Id_StrDouble := LastSubId;
    RegisterParameter(H_Sub, typeANSISTRING, Unassigned, ByRef);
    RegisterParameter(H_Sub, typeINTEGER, Unassigned);
    RegisterParameter(H_Sub, typeINTEGER, Unassigned);
    RegisterParameter(H_Sub, typeDOUBLE, Unassigned);

    H_Sub := RegisterRoutine(0, '', typeVOID, ccSTDCALL, @_StrSingle);
    Id_StrSingle := LastSubId;
    RegisterParameter(H_Sub, typeANSISTRING, Unassigned, ByRef);
    RegisterParameter(H_Sub, typeINTEGER, Unassigned);
    RegisterParameter(H_Sub, typeINTEGER, Unassigned);
    RegisterParameter(H_Sub, typeSINGLE, Unassigned);

    H_Sub := RegisterRoutine(0, '', typeVOID, ccSTDCALL, @_StrExtended);
    Id_StrExtended := LastSubId;
    RegisterParameter(H_Sub, typeANSISTRING, Unassigned, ByRef);
    RegisterParameter(H_Sub, typeINTEGER, Unassigned);
    RegisterParameter(H_Sub, typeINTEGER, Unassigned);
    RegisterParameter(H_Sub, typeEXTENDED, Unassigned);

    RegisterRoutine(0, '', typeVOID, ccREGISTER, @_DecStringCounter);
    Id_DecStringCounter := LastSubId;

    RegisterRoutine(0, '', typeVOID, ccSTDCALL, @_AnsiStringEquality);
    Id_AnsiStringEquality := LastSubId;

    RegisterRoutine(0, '', typeVOID, ccSTDCALL, @_AnsiStringNotEquality);
    Id_AnsiStringNotEquality := LastSubId;

    RegisterRoutine(0, '', typeVOID, ccSTDCALL, @_ShortStringEquality);
    Id_ShortStringEquality := LastSubId;

    RegisterRoutine(0, '', typeVOID, ccSTDCALL, @_ShortStringNotEquality);
    Id_ShortStringNotEquality := LastSubId;

    RegisterRoutine(0, '', typeVOID, ccSTDCALL, @_WideStringEquality);
    Id_WideStringEquality := LastSubId;

    RegisterRoutine(0, '', typeVOID, ccSTDCALL, @_WideStringNotEquality);
    Id_WideStringNotEquality := LastSubId;

    RegisterRoutine(0, '', typeINTEGER, ccSTDCALL, @_ShortstringHigh);
    Id_ShortstringHigh := LastSubId;

    RegisterRoutine(0, '', typeVOID, ccSTDCALL, @ _AnsiStringGreaterThan);
    Id_AnsiStringGreaterThan := LastSubId;

    RegisterRoutine(0, '', typeVOID, ccSTDCALL, @_AnsiStringGreaterThanOrEqual);
    Id_AnsiStringGreaterThanOrEqual := LastSubId;

    RegisterRoutine(0, '', typeVOID, ccSTDCALL, @_AnsiStringLessThan);
    Id_AnsiStringLessThan := LastSubId;

    RegisterRoutine(0, '', typeVOID, ccSTDCALL, @_AnsiStringLessThanOrEqual);
    Id_AnsiStringLessThanOrEqual := LastSubId;

    RegisterRoutine(0, '', typeVOID, ccSTDCALL, @ _ShortStringGreaterThan);
    Id_ShortStringGreaterThan := LastSubId;

    RegisterRoutine(0, '', typeVOID, ccSTDCALL, @_ShortStringGreaterThanOrEqual);
    Id_ShortStringGreaterThanOrEqual := LastSubId;

    RegisterRoutine(0, '', typeVOID, ccSTDCALL, @_ShortStringLessThan);
    Id_ShortStringLessThan := LastSubId;

    RegisterRoutine(0, '', typeVOID, ccSTDCALL, @_ShortStringLessThanOrEqual);
    Id_ShortStringLessThanOrEqual := LastSubId;

    RegisterRoutine(0, '', typeVOID, ccSTDCALL, @ _WideStringGreaterThan);
    Id_WideStringGreaterThan := LastSubId;

    RegisterRoutine(0, '', typeVOID, ccSTDCALL, @_WideStringGreaterThanOrEqual);
    Id_WideStringGreaterThanOrEqual := LastSubId;

    RegisterRoutine(0, '', typeVOID, ccSTDCALL, @_WideStringLessThan);
    Id_WideStringLessThan := LastSubId;

    RegisterRoutine(0, '', typeVOID, ccSTDCALL, @_WideStringLessThanOrEqual);
    Id_WideStringLessThanOrEqual := LastSubId;

    RegisterRoutine(0, '', typeVOID, ccSTDCALL, @_SetStringLength);
    Id_SetStringLength := LastSubId;

    RegisterRoutine(0, '', typeVOID, ccSTDCALL, @_SetWideStringLength);
    Id_SetWideStringLength := LastSubId;

    RegisterRoutine(0, '', typeVOID, ccSTDCALL, @_SetShortStringLength);
    Id_SetShortStringLength := LastSubId;

//--------- INT64 ROUTINES -----------------------------------------------------

    RegisterRoutine(0, '', typeVOID, ccSTDCALL, @ _Int64Multiplication);
    Id_Int64Multiplication := LastSubId;

    RegisterRoutine(0, '', typeVOID, ccSTDCALL, @ _Int64Division);
    Id_Int64Division := LastSubId;

    RegisterRoutine(0, '', typeVOID, ccSTDCALL, @ _Int64Modulo);
    Id_Int64Modulo := LastSubId;

    RegisterRoutine(0, '', typeVOID, ccSTDCALL, @ _Int64LeftShift);
    Id_Int64LeftShift := LastSubId;

    RegisterRoutine(0, '', typeVOID, ccSTDCALL, @ _Int64RightShift);
    Id_Int64RightShift := LastSubId;

    RegisterRoutine(0, '', typeVOID, ccSTDCALL, @ _Int64LessThan);
    Id_Int64LessThan := LastSubId;

    RegisterRoutine(0, '', typeVOID, ccSTDCALL, @ _Int64LessThanOrEqual);
    Id_Int64LessThanOrEqual := LastSubId;

    RegisterRoutine(0, '', typeVOID, ccSTDCALL, @ _Int64GreaterThan);
    Id_Int64GreaterThan := LastSubId;

    RegisterRoutine(0, '', typeVOID, ccSTDCALL, @ _Int64GreaterThanOrEqual);
    Id_Int64GreaterThanOrEqual := LastSubId;

    RegisterRoutine(0, '', typeVOID, ccSTDCALL, @ _Int64Equality);
    Id_Int64Equality := LastSubId;

    RegisterRoutine(0, '', typeVOID, ccSTDCALL, @ _Int64NotEquality);
    Id_Int64NotEquality := LastSubId;

    RegisterRoutine(0, '', typeVOID, ccSTDCALL, @ _Int64Abs);
    Id_Int64Abs := LastSubId;
    
//--------- VARIANT ROUTINES ---------------------------------------------------

    RegisterRoutine(0, '', typeVOID, ccSTDCALL, @_OleVariantFromVariant);
    Id_OleVariantFromVariant := LastSubId;

    RegisterRoutine(0, '', typeVOID, ccSTDCALL, @_VariantClr);
    Id_VariantClr := LastSubId;

    RegisterRoutine(0, '', typeVOID, ccSTDCALL, @ _VariantAssign);
    Id_VariantAssign := LastSubId;

    RegisterRoutine(0, '', typeVOID, ccSTDCALL, @ _OleVariantAssign);
    Id_OleVariantAssign := LastSubId;

    RegisterRoutine(0, '', typeVOID, ccSTDCALL, @_VariantFromPAnsiChar);
    Id_VariantFromPAnsiChar := LastSubId;

    RegisterRoutine(0, '', typeVOID, ccSTDCALL, @_OleVariantFromPAnsiChar);
    Id_OleVariantFromPAnsiChar := LastSubId;

    RegisterRoutine(0, '', typeVOID, ccSTDCALL, @_VariantFromInterface);
    Id_VariantFromInterface := LastSubId;

    RegisterRoutine(0, '', typeVOID, ccSTDCALL, @_OleVariantFromInterface);
    Id_OleVariantFromInterface := LastSubId;

    RegisterRoutine(0, '', typeVOID, ccSTDCALL, @_VariantFromAnsiString);
    Id_VariantFromAnsiString := LastSubId;

    RegisterRoutine(0, '', typeVOID, ccSTDCALL, @_OleVariantFromAnsiString);
    Id_OleVariantFromAnsiString := LastSubId;

    RegisterRoutine(0, '', typeVOID, ccSTDCALL, @_VariantFromWideString);
    Id_VariantFromWideString := LastSubId;

    RegisterRoutine(0, '', typeVOID, ccSTDCALL, @_OleVariantFromWideString);
    Id_OleVariantFromWideString := LastSubId;

    RegisterRoutine(0, '', typeVOID, ccSTDCALL, @_VariantFromShortString);
    Id_VariantFromShortString := LastSubId;

    RegisterRoutine(0, '', typeVOID, ccSTDCALL, @_OleVariantFromShortString);
    Id_OleVariantFromShortString := LastSubId;

    RegisterRoutine(0, '', typeVOID, ccSTDCALL, @_VariantFromAnsiChar);
    Id_VariantFromAnsiChar := LastSubId;

    RegisterRoutine(0, '', typeVOID, ccSTDCALL, @_OleVariantFromAnsiChar);
    Id_OleVariantFromAnsiChar := LastSubId;

    RegisterRoutine(0, '', typeVOID, ccSTDCALL, @_VariantFromWideChar);
    Id_VariantFromWideChar := LastSubId;

    RegisterRoutine(0, '', typeVOID, ccSTDCALL, @_OleVariantFromWideChar);
    Id_OleVariantFromWideChar := LastSubId;

    RegisterRoutine(0, '', typeVOID, ccSTDCALL, @_VariantFromInt);
    Id_VariantFromInt := LastSubId;

    RegisterRoutine(0, '', typeVOID, ccSTDCALL, @_OleVariantFromInt);
    Id_OleVariantFromInt := LastSubId;

    RegisterRoutine(0, '', typeVOID, ccSTDCALL, @_VariantFromInt64);
    Id_VariantFromInt64 := LastSubId;

    RegisterRoutine(0, '', typeVOID, ccSTDCALL, @_OleVariantFromInt64);
    Id_OleVariantFromInt64 := LastSubId;

    RegisterRoutine(0, '', typeVOID, ccSTDCALL, @ _VariantFromByte);
    Id_VariantFromByte := LastSubId;

    RegisterRoutine(0, '', typeVOID, ccSTDCALL, @ _OleVariantFromByte);
    Id_OleVariantFromByte := LastSubId;

    RegisterRoutine(0, '', typeVOID, ccSTDCALL, @_VariantFromBool);
    Id_VariantFromBool := LastSubId;

    RegisterRoutine(0, '', typeVOID, ccSTDCALL, @_OleVariantFromBool);
    Id_OleVariantFromBool := LastSubId;

    RegisterRoutine(0, '', typeVOID, ccSTDCALL, @_VariantFromWord);
    Id_VariantFromWord := LastSubId;

    RegisterRoutine(0, '', typeVOID, ccSTDCALL, @_OleVariantFromWord);
    Id_OleVariantFromWord := LastSubId;

    RegisterRoutine(0, '', typeVOID, ccSTDCALL, @_VariantFromCardinal);
    Id_VariantFromCardinal := LastSubId;

    RegisterRoutine(0, '', typeVOID, ccSTDCALL, @_OleVariantFromCardinal);
    Id_OleVariantFromCardinal := LastSubId;

    RegisterRoutine(0, '', typeVOID, ccSTDCALL, @_VariantFromSmallInt);
    Id_VariantFromSmallInt := LastSubId;

    RegisterRoutine(0, '', typeVOID, ccSTDCALL, @_OleVariantFromSmallInt);
    Id_OleVariantFromSmallInt := LastSubId;

    RegisterRoutine(0, '', typeVOID, ccSTDCALL, @_VariantFromShortInt);
    Id_VariantFromShortInt := LastSubId;

    RegisterRoutine(0, '', typeVOID, ccSTDCALL, @_OleVariantFromShortInt);
    Id_OleVariantFromShortInt := LastSubId;

    RegisterRoutine(0, '', typeVOID, ccSTDCALL, @_VariantFromDouble);
    Id_VariantFromDouble := LastSubId;

    RegisterRoutine(0, '', typeVOID, ccSTDCALL, @_OleVariantFromDouble);
    Id_OleVariantFromDouble := LastSubId;

    RegisterRoutine(0, '', typeVOID, ccSTDCALL, @_VariantFromCurrency);
    Id_VariantFromCurrency := LastSubId;

    RegisterRoutine(0, '', typeVOID, ccSTDCALL, @_OleVariantFromCurrency);
    Id_OleVariantFromCurrency := LastSubId;

    RegisterRoutine(0, '', typeVOID, ccSTDCALL, @_VariantFromSingle);
    Id_VariantFromSingle := LastSubId;

    RegisterRoutine(0, '', typeVOID, ccSTDCALL, @_OleVariantFromSingle);
    Id_OleVariantFromSingle := LastSubId;

    RegisterRoutine(0, '', typeVOID, ccSTDCALL, @_VariantFromExtended);
    Id_VariantFromExtended := LastSubId;

    RegisterRoutine(0, '', typeVOID, ccSTDCALL, @_OleVariantFromExtended);
    Id_OleVariantFromExtended := LastSubId;

    {$IFDEF UNIC}
    RegisterRoutine(0, '', typeVOID, ccSTDCALL, @_UnicStringFromInt);
    Id_UnicStringFromInt := LastSubId; // js only

    RegisterRoutine(0, '', typeVOID, ccSTDCALL, @_UnicStringFromDouble);
    Id_UnicStringFromDouble := LastSubId; // js only

    RegisterRoutine(0, '', typeVOID, ccSTDCALL, @_UnicStringFromSingle);
    Id_UnicStringFromSingle := LastSubId; // js only

    RegisterRoutine(0, '', typeVOID, ccSTDCALL, @_UnicStringFromExtended);
    Id_UnicStringFromExtended := LastSubId; // js only

    RegisterRoutine(0, '', typeVOID, ccSTDCALL, @_UnicStringFromBoolean);
    Id_UnicStringFromBoolean := LastSubId; // js only
    {$ELSE}
    RegisterRoutine(0, '', typeVOID, ccSTDCALL, @_AnsiStringFromInt);
    Id_AnsiStringFromInt := LastSubId; // js only

    RegisterRoutine(0, '', typeVOID, ccSTDCALL, @_AnsiStringFromDouble);
    Id_AnsiStringFromDouble := LastSubId; // js only

    RegisterRoutine(0, '', typeVOID, ccSTDCALL, @_AnsiStringFromSingle);
    Id_AnsiStringFromSingle := LastSubId; // js only

    RegisterRoutine(0, '', typeVOID, ccSTDCALL, @_AnsiStringFromExtended);
    Id_AnsiStringFromExtended := LastSubId; // js only

    RegisterRoutine(0, '', typeVOID, ccSTDCALL, @_AnsiStringFromBoolean);
    Id_AnsiStringFromBoolean := LastSubId; // js only
    {$ENDIF}

    RegisterRoutine(0, '', typeVOID, ccSTDCALL, @_AnsiStringFromVariant);
    Id_AnsiStringFromVariant := LastSubId;

    RegisterRoutine(0, '', typeVOID, ccSTDCALL, @_WideStringFromVariant);
    Id_WideStringFromVariant := LastSubId;

    RegisterRoutine(0, '', typeVOID, ccSTDCALL, @_ShortStringFromVariant);
    Id_ShortStringFromVariant := LastSubId;

    RegisterRoutine(0, '', typeVOID, ccSTDCALL, @_DoubleFromVariant);
    Id_DoubleFromVariant := LastSubId;

    RegisterRoutine(0, '', typeVOID, ccSTDCALL, @_CurrencyFromVariant);
    Id_CurrencyFromVariant := LastSubId;

    RegisterRoutine(0, '', typeVOID, ccSTDCALL, @_SingleFromVariant);
    Id_SingleFromVariant := LastSubId;

    RegisterRoutine(0, '', typeVOID, ccSTDCALL, @_ExtendedFromVariant);
    Id_ExtendedFromVariant := LastSubId;

    RegisterRoutine(0, '', typeVOID, ccSTDCALL, @_IntFromVariant);
    Id_IntFromVariant := LastSubId;

    RegisterRoutine(0, '', typeVOID, ccSTDCALL, @_Int64FromVariant);
    Id_Int64FromVariant := LastSubId;

    RegisterRoutine(0, '', typeVOID, ccSTDCALL, @_ByteFromVariant);
    Id_ByteFromVariant := LastSubId;

    RegisterRoutine(0, '', typeVOID, ccSTDCALL, @_WordFromVariant);
    Id_WordFromVariant := LastSubId;

    RegisterRoutine(0, '', typeVOID, ccSTDCALL, @_CardinalFromVariant);
    Id_CardinalFromVariant := LastSubId;

    RegisterRoutine(0, '', typeVOID, ccSTDCALL, @_SmallIntFromVariant);
    Id_SmallIntFromVariant := LastSubId;

    RegisterRoutine(0, '', typeVOID, ccSTDCALL, @_ShortIntFromVariant);
    Id_ShortIntFromVariant := LastSubId;

    RegisterRoutine(0, '', typeVOID, ccSTDCALL, @_BoolFromVariant);
    Id_BoolFromVariant := LastSubId;

    RegisterRoutine(0, '', typeVOID, ccSTDCALL, @_ByteBoolFromVariant);
    Id_ByteBoolFromVariant := LastSubId;

    RegisterRoutine(0, '', typeVOID, ccSTDCALL, @_WordBoolFromVariant);
    Id_WordBoolFromVariant := LastSubId;

    RegisterRoutine(0, '', typeVOID, ccSTDCALL, @_LongBoolFromVariant);
    Id_LongBoolFromVariant := LastSubId;

    RegisterRoutine(0, '', typeVOID, ccSTDCALL, @ _VariantAddition);
    Id_VariantAddition := LastSubId;

    RegisterRoutine(0, '', typeVOID, ccSTDCALL, @ _VariantSubtraction);
    Id_VariantSubtraction := LastSubId;

    RegisterRoutine(0, '', typeVOID, ccSTDCALL, @ _VariantMultiplication);
    Id_VariantMultiplication := LastSubId;

    RegisterRoutine(0, '', typeVOID, ccSTDCALL, @ _VariantDivision);
    Id_VariantDivision := LastSubId;

    RegisterRoutine(0, '', typeVOID, ccSTDCALL, @ _VariantIDivision);
    Id_VariantIDivision := LastSubId;

    RegisterRoutine(0, '', typeVOID, ccSTDCALL, @ _VariantModulo);
    Id_VariantModulo := LastSubId;

    RegisterRoutine(0, '', typeVOID, ccSTDCALL, @ _VariantLeftShift);
    Id_VariantLeftShift := LastSubId;

    RegisterRoutine(0, '', typeVOID, ccSTDCALL, @ _VariantRightShift);
    Id_VariantRightShift := LastSubId;

    RegisterRoutine(0, '', typeVOID, ccSTDCALL, @ _VariantAnd);
    Id_VariantAnd := LastSubId;

    RegisterRoutine(0, '', typeVOID, ccSTDCALL, @ _VariantOr);
    Id_VariantOr := LastSubId;

    RegisterRoutine(0, '', typeVOID, ccSTDCALL, @ _VariantXor);
    Id_VariantXor := LastSubId;

    RegisterRoutine(0, '', typeVOID, ccSTDCALL, @ _VariantLessThan);
    Id_VariantLessThan := LastSubId;

    RegisterRoutine(0, '', typeVOID, ccSTDCALL, @ _VariantLessThanOrEqual);
    Id_VariantLessThanOrEqual := LastSubId;

    RegisterRoutine(0, '', typeVOID, ccSTDCALL, @ _VariantGreaterThan);
    Id_VariantGreaterThan := LastSubId;

    RegisterRoutine(0, '', typeVOID, ccSTDCALL, @ _VariantGreaterThanOrEqual);
    Id_VariantGreaterThanOrEqual := LastSubId;

    RegisterRoutine(0, '', typeVOID, ccSTDCALL, @ _VariantEquality);
    Id_VariantEquality := LastSubId;

    RegisterRoutine(0, '', typeVOID, ccSTDCALL, @ _VariantNotEquality);
    Id_VariantNotEquality := LastSubId;

    RegisterRoutine(0, '', typeVOID, ccSTDCALL, @ _VariantNegation);
    Id_VariantNegation := LastSubId;

    RegisterRoutine(0, '', typeVOID, ccSTDCALL, @ _VariantAbs);
    Id_VariantAbs := LastSubId;

    RegisterRoutine(0, '', typeVOID, ccSTDCALL, @ _VariantNot);
    Id_VariantNot := LastSubId;

    RegisterRoutine(0, '', typeVOID, ccSTDCALL, @ _VarArrayGet1);
    Id_VarArrayGet1 := LastSubId;

    RegisterRoutine(0, '', typeVOID, ccSTDCALL, @ _VarArrayPut1);
    Id_VarArrayPut1 := LastSubId;

    RegisterRoutine(0, '', typeVOID, ccSTDCALL, @ _VarArrayGet2);
    Id_VarArrayGet2 := LastSubId;

    RegisterRoutine(0, '', typeVOID, ccSTDCALL, @ _VarArrayPut2);
    Id_VarArrayPut2 := LastSubId;

    RegisterRoutine(0, '', typeVOID, ccSTDCALL, @ _VarArrayGet3);
    Id_VarArrayGet3 := LastSubId;

    RegisterRoutine(0, '', typeVOID, ccSTDCALL, @ _VarArrayPut3);
    Id_VarArrayPut3 := LastSubId;

    RegisterRoutine(0, '', typeVOID, ccSTDCALL, @ _InterfaceFromClass);
    Id_InterfaceFromClass := LastSubId;

    RegisterRoutine(0, '', typeVOID, ccSTDCALL, @ _InterfaceCast);
    Id_InterfaceCast := LastSubId;

    RegisterRoutine(0, '', typeVOID, ccSTDCALL, @ _InterfaceAssign);
    Id_InterfaceAssign := LastSubId;

//------------------ Dynamic array support routines ----------------------------
    RegisterRoutine(0, 'SetLength', typeVOID, ccSTDCALL, nil);

    RegisterRoutine(0, '', typeVOID, ccREGISTER, @_CondHalt);
    Id_CondHalt := LastSubId;

    RegisterRoutine(0, '_toParentClass', typeVOID, ccSTDCALL, @_ToParentClass);
    Id_ToParentClass := LastSubId;

    RegisterRoutine(0, '', typeVOID, ccSTDCALL, @_UpdateInstance);
    Id_UpdateInstance := LastSubId;

    RegisterRoutine(0, '', typeVOID, ccSTDCALL, @_BeginExceptBlock);
    Id_BeginExceptBlock := LastSubId;

    // reserved
//  RegisterRoutine(0, '', typeVOID, ccSTDCALL, @Dummy);
    RegisterRoutine(0, '', typeVOID, ccREGISTER, @_DestroyInherited);
    Id_DestroyInherited := LastSubId;

    H_Sub := RegisterRoutine(0, _strDynarraySetLength, typeVOID, ccSTDCALL,
                             @ _DynarraySetLength);
    RegisterParameter(H_Sub, typeDYNARRAY, Unassigned, ByRef);
    RegisterParameter(H_Sub, typeINTEGER, Unassigned);
    RegisterParameter(H_Sub, typeINTEGER, Unassigned);
    RegisterParameter(H_Sub, typeINTEGER, Unassigned);
    RegisterParameter(H_Sub, typeINTEGER, Unassigned);

    H_Sub := RegisterRoutine(0, '', typeVOID, ccSTDCALL,
                             @ _CreateEmptyDynarray);
    Id_CreateEmptyDynarray := LastSubId;
    RegisterParameter(H_Sub, typeDYNARRAY, Unassigned, ByRef);

    H_Sub := RegisterRoutine(0, '', typeVOID, ccSTDCALL,
                             @ _DynarrayClr);
    Id_DynarrayClr := LastSubId;
    RegisterParameter(H_Sub, typeDYNARRAY, Unassigned, ByRef);
    RegisterParameter(H_Sub, typeINTEGER, Unassigned);
    RegisterParameter(H_Sub, typeINTEGER, Unassigned);
    RegisterParameter(H_Sub, typeINTEGER, Unassigned);

    H_Sub := RegisterRoutine(0, '', typeVOID, ccSTDCALL,
                             @ _DynarrayAssign);
    Id_DynarrayAssign := LastSubId;
    RegisterParameter(H_Sub, typeDYNARRAY, Unassigned, ByRef);
    RegisterParameter(H_Sub, typeDYNARRAY, Unassigned, ByRef);
    RegisterParameter(H_Sub, typeINTEGER, Unassigned);
    RegisterParameter(H_Sub, typeINTEGER, Unassigned);
    RegisterParameter(H_Sub, typeINTEGER, Unassigned);

    H_Sub := RegisterRoutine(0, _strDynarrayHigh, typeINTEGER, ccSTDCALL,
                             @_DynarrayHigh);
    RegisterParameter(H_Sub, typeDYNARRAY, Unassigned, ByRef);
    RegisterParameter(H_Sub, typeINTEGER, Unassigned, ByRef);

//------------------------------------------------------------------------------

{$IFDEF MSWINDOWS}
    RegisterRoutine(0, strGetTickCount, typeINTEGER, ccREGISTER, @GetTickCount);
{$ENDIF}

    RegisterRoutine(0, '', typePOINTER, ccREGISTER, @GetClassByIndex);
    Id_GetClassByIndex := LastSubId;

    RegisterRoutine(0, '', typeVOID, ccSTDCALL, @_PrintEx);
    Id_PrintEx := LastSubId;

// processing IS

    H_Sub := RegisterRoutine(0, _strIs, typeVOID, ccSTDCALL, @_Is);
    RegisterParameter(H_Sub, typePOINTER, Unassigned);
    RegisterParameter(H_Sub, typeINTEGER, Unassigned);
    RegisterParameter(H_Sub, typeBOOLEAN, Unassigned, ByRef);

    RegisterRoutine(0, '', typeVOID, ccSTDCALL, @_ClassName);
    Id_ClassName := LastSubId;

    RegisterRoutine(0, '', typeVOID, ccSTDCALL, @_OnCreateObject);
    Id_OnCreateObject := LastSubId;

    RegisterRoutine(0, '', typeVOID, ccSTDCALL, @_OnAfterObjectCreation);
    Id_OnAfterObjectCreation := LastSubId;

// processing of published properties

    RegisterRoutine(0, '', typeVOID, ccSTDCALL, @_GetAnsiStrProp);
    Id_GetAnsiStrProp := LastSubId;

    RegisterRoutine(0, '', typeVOID, ccSTDCALL, @_SetAnsiStrProp);
    Id_SetAnsiStrProp := LastSubId;

    RegisterRoutine(0, '', typeVOID, ccSTDCALL, @_GetWideStrProp);
    Id_GetWideStrProp := LastSubId;

    RegisterRoutine(0, '', typeVOID, ccSTDCALL, @_SetWideStrProp);
    Id_SetWideStrProp := LastSubId;

    RegisterRoutine(0, '', typeVOID, ccSTDCALL, @_GetOrdProp);
    Id_GetOrdProp := LastSubId;

    RegisterRoutine(0, '', typeVOID, ccSTDCALL, @_SetOrdProp);
    Id_SetOrdProp := LastSubId;

    RegisterRoutine(0, '', typeVOID, ccSTDCALL, @_GetInterfaceProp);
    Id_GetInterfaceProp := LastSubId;

    RegisterRoutine(0, '', typeVOID, ccSTDCALL, @_SetInterfaceProp);
    Id_SetInterfaceProp := LastSubId;

    RegisterRoutine(0, '', typeVOID, ccSTDCALL, @_GetSetProp);
    Id_GetSetProp := LastSubId;

    RegisterRoutine(0, '', typeVOID, ccSTDCALL, @_SetSetProp);
    Id_SetSetProp := LastSubId;

    RegisterRoutine(0, '', typeVOID, ccSTDCALL, @_GetFloatProp);
    Id_GetFloatProp := LastSubId;

    RegisterRoutine(0, '', typeVOID, ccSTDCALL, @_SetFloatProp);
    Id_SetFloatProp := LastSubId;

    RegisterRoutine(0, '', typeVOID, ccSTDCALL, @_GetVariantProp);
    Id_GetVariantProp := LastSubId;

    RegisterRoutine(0, '', typeVOID, ccSTDCALL, @_SetVariantProp);
    Id_SetVariantProp := LastSubId;

    RegisterRoutine(0, '', typeVOID, ccSTDCALL, @_GetInt64Prop);
    Id_GetInt64Prop := LastSubId;

    RegisterRoutine(0, '', typeVOID, ccSTDCALL, @ _SetInt64Prop);
    Id_SetInt64Prop := LastSubId;

    RegisterRoutine(0, '', typeVOID, ccSTDCALL, @ _GetEventProp);
    Id_GetEventProp := LastSubId;

    RegisterRoutine(0, '', typeVOID, ccSTDCALL, @ _SetEventProp);
    Id_SetEventProp := LastSubId;

    RegisterRoutine(0, '', typeVOID, ccSTDCALL, @ _SetEventProp2);
    Id_SetEventProp2 := LastSubId;

    RegisterRoutine(0, '', typeVOID, ccSTDCALL, @ _CreateMethod);
    Id_CreateMethod := LastSubId;

// processing try-except-finally

    H_Sub := RegisterRoutine(0, '', typeVOID, ccSTDCALL, @_TryOn);
    Id_TryOn := LastSubId;

    H_Sub := RegisterRoutine(0, '', typeVOID, ccSTDCALL, @ _TryOff);
    Id_TryOff := LastSubId;

    H_Sub := RegisterRoutine(0, '', typeVOID, ccSTDCALL, @_Raise);
    Id_Raise := LastSubId;

    H_Sub := RegisterRoutine(0, '', typeVOID, ccSTDCALL, @_Exit);
    Id_Exit := LastSubId;

    H_Sub := RegisterRoutine(0, '', typeVOID, ccSTDCALL, @_CondRaise);
    Id_CondRaise := LastSubId;

    H_Sub := RegisterRoutine(0, '', typeVOID, ccSTDCALL, @_EndExceptBlock);
    Id_EndExceptBlock := LastSubId;

// processing pause

    H_Sub := RegisterRoutine(0, _strPause, typeVOID, ccSTDCALL, @_Pause);
    RegisterParameter(H_Sub, typePOINTER, Unassigned);
    RegisterParameter(H_Sub, typeINTEGER, Unassigned);
    RegisterParameter(H_Sub, typeINTEGER, Unassigned);
    RegisterParameter(H_Sub, typeINTEGER, Unassigned);

    RegisterRoutine(0, 'pause', typeVOID, ccSTDCALL, nil);

    RegisterRoutine(0, '', typeVOID, ccREGISTER, @_InitSub);
    Id_InitSub := LastSubId;

    RegisterRoutine(0, '', typeVOID, ccREGISTER, @_EndSub);
    Id_EndSub := LastSubId;

// processing halt

    H_Sub := RegisterRoutine(0, _strHalt, typeVOID, ccSTDCALL, @_Halt);
    RegisterParameter(H_Sub, typePOINTER, Unassigned);
    RegisterParameter(H_Sub, typeINTEGER, Unassigned);

    RegisterRoutine(0, 'halt', typeVOID, ccSTDCALL, nil);
    RegisterRoutine(0, 'abort', typeVOID, ccSTDCALL, nil);

    RegisterRoutine(0, 'print', typeVOID, ccSTDCALL, nil);
    RegisterRoutine(0, 'println', typeVOID, ccSTDCALL, nil);

// processing breakpoints

    RegisterRoutine(0, '', typeVOID, ccREGISTER, @_CheckPause);
    Id_CheckPause := LastSubId;

// processing integer overflow

    RegisterRoutine(0, '', typeVOID, ccSTDCALL, @_IntOver);
    Id_IntOver := LastSubId;

// processing bound error

    RegisterRoutine(0, '', typeVOID, ccSTDCALL, @_BoundError);
    Id_BoundError := LastSubId;

    RegisterRoutine(0, '', typeVOID, ccSTDCALL, @ _CreateObject);
    Id_CreateObject := LastSubId;

    RegisterRoutine(0, '', typeVOID, ccSTDCALL, @ _ErrAbstract);
    Id_ErrAbstract := LastSubId;

    RegisterRoutine(0, '', typeVOID, ccSTDCALL, @ _RecordAssign);
    Id_RecordAssign := LastSubId;

    CURR_FMUL_ID := RegisterConstant(0, '_10000.0', typeSINGLE, 10000.0);

/////////////////////////////////////////////////////////////////////
/// PASCAL NAMESPASCE ///////////////////////////////////////////////
/////////////////////////////////////////////////////////////////////

    H_Namespace := RegisterNamespace(0, StrPascalNamespace);
    H_PascalNamespace := H_Namespace;

    H_Sub := RegisterRoutine(H_Namespace, 'GetMem', typeVOID, ccREGISTER,
                            @_GetMem);
    RegisterParameter(H_Sub, typePOINTER, Unassigned, ByRef, 'P');
    RegisterParameter(H_Sub, typeINTEGER, Unassigned, false, 'Size');

    H_Sub := RegisterRoutine(H_Namespace, 'FreeMem', typeVOID, ccREGISTER,
                             @_FreeMem);
    RegisterParameter(H_Sub, typePOINTER, Unassigned, false, 'P');
    RegisterParameter(H_Sub, typeINTEGER, Unassigned, false, 'Size');

    H_Sub := RegisterRoutine(H_Namespace, 'AllocMem', typePOINTER, ccREGISTER,
                             @AllocMem);
    RegisterParameter(H_Sub, typeCARDINAL, Unassigned, false, 'Size');

// PASCAL ARITHMETIC ROUTINES ///////////////////////////////////////

    H_Sub := RegisterRoutine(H_Namespace, 'Abs', typeVOID, ccSTDCALL, nil);
    RegisterParameter(H_Sub, typeVOID, Unassigned, ByRef, 'X');

    H_Sub := RegisterRoutine(H_Namespace, 'ArcTan', typeEXTENDED, ccREGISTER,
                             @_ArcTan);
    RegisterParameter(H_Sub, typeEXTENDED, Unassigned, false, 'X');

    H_Sub := RegisterRoutine(H_Namespace, 'Cos', typeEXTENDED, ccREGISTER, @_Cos);
    RegisterParameter(H_Sub, typeEXTENDED, Unassigned, false, 'X');

    H_Sub := RegisterRoutine(H_Namespace, 'Exp', typeEXTENDED, ccREGISTER, @_Exp);
    RegisterParameter(H_Sub, typeEXTENDED, Unassigned, false, 'X');

    H_Sub := RegisterRoutine(H_Namespace, 'Frac', typeEXTENDED, ccREGISTER, @_Frac);
    RegisterParameter(H_Sub, typeEXTENDED, Unassigned, false, 'X');

    H_Sub := RegisterRoutine(H_Namespace, 'Int', typeEXTENDED, ccREGISTER, @_Int);
    RegisterParameter(H_Sub, typeEXTENDED, Unassigned, false, 'X');

    H_Sub := RegisterRoutine(H_Namespace, 'Ln', typeEXTENDED, ccREGISTER, @_Ln);
    RegisterParameter(H_Sub, typeEXTENDED, Unassigned, false, 'X');

    RegisterConstant(H_Namespace, 'Pi', typeEXTENDED, Pi);

    H_Sub := RegisterRoutine(H_Namespace, 'Sin', typeEXTENDED, ccREGISTER, @_Sin);
    RegisterParameter(H_Sub, typeEXTENDED, Unassigned, false, 'X');

    H_Sub := RegisterRoutine(H_Namespace, 'Sqr', typeEXTENDED, ccREGISTER, @_Sqr);
    RegisterParameter(H_Sub, typeEXTENDED, Unassigned, false, 'X');

    H_Sub := RegisterRoutine(H_Namespace, 'Sqrt', typeEXTENDED, ccREGISTER, @_Sqrt);
    RegisterParameter(H_Sub, typeEXTENDED, Unassigned, false, 'X');

    H_Sub := RegisterRoutine(H_Namespace, 'Trunc', typeINTEGER, ccREGISTER, @_Trunc);
    RegisterParameter(H_Sub, typeEXTENDED, Unassigned, false, 'X');

    H_Sub := RegisterRoutine(H_Namespace, 'Power', typeEXTENDED, ccREGISTER, @_Power);
    RegisterParameter(H_Sub, typeEXTENDED, Unassigned, false, 'Base');
    RegisterParameter(H_Sub, typeEXTENDED, Unassigned, false, 'Exponent');

/////////////////////////////////////////////////////////////////////

    RegisterRoutine(H_Namespace, 'New', typeVOID, ccSTDCALL, nil);
    RegisterRoutine(H_Namespace, 'Dispose', typeVOID, ccSTDCALL, nil);
    RegisterRoutine(H_Namespace, 'Inc', typeVOID, ccSTDCALL, nil);
    RegisterRoutine(H_Namespace, 'Dec', typeVOID, ccSTDCALL, nil);
    RegisterRoutine(H_Namespace, 'Pred', typeVOID, ccSTDCALL, nil);
    RegisterRoutine(H_Namespace, 'Succ', typeVOID, ccSTDCALL, nil);
    RegisterRoutine(H_Namespace, 'Ord', typeVOID, ccSTDCALL, nil);
    RegisterRoutine(H_Namespace, 'Chr', typeVOID, ccSTDCALL, nil);
    RegisterRoutine(H_Namespace, 'Low', typeVOID, ccSTDCALL, nil);
    RegisterRoutine(H_Namespace, 'High', typeVOID, ccSTDCALL, nil);
    RegisterRoutine(H_Namespace, 'Assigned', typeVOID, ccSTDCALL, nil);

    H_Sub := RegisterRoutine(H_Namespace, 'Odd', typeBOOLEAN, ccREGISTER, @_Odd);
    RegisterParameter(H_Sub, typeINTEGER, Unassigned, false, 'X');

// PASCAL AnsiString ROUTINES ///////////////////////////////////////

    H_Sub := RegisterRoutine(H_Namespace, 'Length', typeINTEGER, ccREGISTER,
                             @_DynarrayLength);
    Id_DynArrayLength := LastSubId;
    RegisterParameter(H_Sub, typeDYNARRAY, Unassigned, false, 'X');

    H_Sub := RegisterRoutine(H_Namespace, 'Length', typeINTEGER, ccREGISTER,
                             @_LengthString);
    Id_AnsiStringLength := LastSubId;
    RegisterParameter(H_Sub, typeANSISTRING, Unassigned, false, 'S');

    H_Sub := RegisterRoutine(H_Namespace, 'Length', typeINTEGER, ccREGISTER,
                             @ _LengthShortString);
    RegisterParameter(H_Sub, typeSHORTSTRING, Unassigned, false, 'S');

    H_Sub := RegisterRoutine(H_Namespace, 'Length', typeINTEGER, ccREGISTER,
                             @_LengthWideString);
    RegisterParameter(H_Sub, typeWIDESTRING, Unassigned, false, 'S');

    H_Sub := RegisterRoutine(H_Namespace, 'Delete', typeVOID, ccREGISTER,
                             @_Delete);
    RegisterParameter(H_Sub, typeANSISTRING, Unassigned, ByRef, 'S');
    RegisterParameter(H_Sub, typeINTEGER, Unassigned, false, 'Index');
    RegisterParameter(H_Sub, typeINTEGER, Unassigned, false, 'Count');

    H_Sub := RegisterRoutine(H_Namespace, 'Insert', typeVOID, ccREGISTER,
                             @_Insert);
    RegisterParameter(H_Sub, typeANSISTRING, Unassigned, false, 'Substr');
    RegisterParameter(H_Sub, typeANSISTRING, Unassigned, ByRef, 'Dest');
    RegisterParameter(H_Sub, typeINTEGER, Unassigned, false, 'Index');

    RegisterRoutine(H_Namespace, 'Str', typeVOID, ccSTDCALL, nil);

    H_Sub := RegisterRoutine(H_Namespace, 'Val', typeVOID, ccREGISTER, @_ValInt);
    RegisterParameter(H_Sub, typeSTRING, Unassigned, false, 'S');
    RegisterParameter(H_Sub, typeINTEGER, Unassigned, ByRef, 'V');
    RegisterParameter(H_Sub, typeINTEGER, Unassigned, ByRef, 'Code');

    H_Sub := RegisterRoutine(H_Namespace, 'Val', typeVOID, ccREGISTER,
                             @_ValDouble);
    RegisterParameter(H_Sub, typeSTRING, Unassigned, false, 'X');
    RegisterParameter(H_Sub, typeDOUBLE, Unassigned, ByRef, 'V');
    RegisterParameter(H_Sub, typeINTEGER, Unassigned, ByRef, 'Code');

    H_Sub := RegisterRoutine(H_Namespace, 'Copy', typeANSISTRING, ccREGISTER,
                             @_Copy);
    RegisterParameter(H_Sub, typeANSISTRING, Unassigned, false, 'S');
    RegisterParameter(H_Sub, typeINTEGER, Unassigned, false, 'Index');
    RegisterParameter(H_Sub, typeINTEGER, Unassigned, false, 'Count');

    H_Sub := RegisterRoutine(H_Namespace, 'Pos', typeINTEGER, ccREGISTER,
                            @_PosString);
    RegisterParameter(H_Sub, typeANSISTRING, Unassigned, false, 'Substr');
    RegisterParameter(H_Sub, typeANSISTRING, Unassigned, false, 'Str');

    H_Sub := RegisterRoutine(H_Namespace, 'Pos', typeINTEGER, ccREGISTER, @_PosChar);
    RegisterParameter(H_Sub, typeANSICHAR, Unassigned, false, 'Ch');
    RegisterParameter(H_Sub, typeANSISTRING, Unassigned, false, 'Str');

/////////////////////////////////////////////////////////////////////
// PASCAL MISCELLANEOUS ROUTINES ////////////////////////////////////

    H_Sub := RegisterRoutine(H_Namespace, 'SizeOf', typeVOID, ccSTDCALL, nil);
    RegisterParameter(H_Sub, typeVOID, Unassigned, ByRef, 'X');

    H_Sub := RegisterRoutine(H_Namespace, 'Move', typeVOID, ccREGISTER, @Move);
    RegisterParameter(H_Sub, typePVOID, Unassigned, false, 'Source');
    RegisterParameter(H_Sub, typePVOID, Unassigned, ByRef, 'Dest');
    RegisterParameter(H_Sub, typeINTEGER, Unassigned, false, 'Count');

    H_Sub := RegisterRoutine(H_Namespace, 'FillChar', typeVOID, ccREGISTER,
                             @_FillChar);
    RegisterParameter(H_Sub, typePVOID, Unassigned, ByRef, 'X');
    RegisterParameter(H_Sub, typeINTEGER, Unassigned, false, 'Count');
    RegisterParameter(H_Sub, typeANSICHAR, Unassigned, false, 'Value');

    H_Sub := RegisterRoutine(H_Namespace, 'FillChar', typeVOID, ccREGISTER,
                             @_FillChar);
    RegisterParameter(H_Sub, typePVOID, Unassigned, ByRef, 'X');
    RegisterParameter(H_Sub, typeINTEGER, Unassigned, false, 'Count');
    RegisterParameter(H_Sub, typeBYTE, Unassigned, false, 'Value');

{$IFDEF FPC}
    H_Sub := RegisterRoutine(H_Namespace, 'Upcase', typeANSICHAR, ccREGISTER,
                             @_Upcase);
{$ELSE}
    H_Sub := RegisterRoutine(H_Namespace, 'Upcase', typeANSICHAR, ccREGISTER,
                             @Upcase);
{$ENDIF}

    RegisterParameter(H_Sub, typeANSICHAR, Unassigned, false, 'C');

    RegisterRoutine(H_Namespace, 'Randomize', typeVOID, ccREGISTER, @Randomize);

    H_Sub := RegisterRoutine(H_Namespace, 'Random', typeINTEGER, ccREGISTER,
                             @_Random1);
    RegisterParameter(H_Sub, typeINTEGER, Unassigned, false, 'X');

    RegisterRoutine(H_Namespace, 'Random', typeDOUBLE, ccREGISTER, @_Random);

    H_Sub := RegisterRoutine(H_Namespace, 'Hi', typeBYTE, ccREGISTER, @_HiInt);
    RegisterParameter(H_Sub, typeINTEGER, Unassigned, false, 'X');

    H_Sub := RegisterRoutine(H_Namespace, 'Hi', typeBYTE, ccREGISTER, @_HiWord);
    RegisterParameter(H_Sub, typeWORD, Unassigned, false, 'X');

    H_Sub := RegisterRoutine(H_Namespace, 'Lo', typeBYTE, ccREGISTER, @_LoInt);
    RegisterParameter(H_Sub, typeINTEGER, Unassigned, false, 'X');

    H_Sub := RegisterRoutine(H_Namespace, 'Lo', typeBYTE, ccREGISTER, @_LoWord);
    RegisterParameter(H_Sub, typeWORD, Unassigned, false, 'X');

    H_Sub := RegisterRoutine(H_Namespace, 'Round', typeINT64, ccREGISTER, @_Round);
    RegisterParameter(H_Sub, typeEXTENDED, Unassigned, false, 'X');

    {$IFDEF TRIAL}

    strShowTrial[0] := '_';
    strShowTrial[1] := '_';
    strShowTrial[2] := '_';
    strShowTrial[3] := '9';
    strShowTrial[4] := '^';
    strShowTrial[5] := '*';
    strShowTrial[6] := #0;

    RegisterRoutine(0, strShowTrial, typeVOID, ccREGISTER, @ShowTrial);

   {$ENDIF}

    H := RegisterRecordType(0, 'TPoint', 1);
    RegisterTypeField(H, 'X', typeINTEGER);
    RegisterTypeField(H, 'Y', typeINTEGER);

    H := RegisterRecordType(0, 'TRect', 1);
    RegisterTypeField(H, 'Left', typeINTEGER);
    RegisterTypeField(H, 'Top', typeINTEGER);
    RegisterTypeField(H, 'Right', typeINTEGER);
    RegisterTypeField(H, 'Bottom', typeINTEGER);

// PASCAL CLASSES ROUTINES /////////////////////////////////////////////////////

    RegisterTypeAlias(H_Namespace, 'Real', typeDOUBLE);
    RegisterTypeAlias(H_Namespace, 'TDateTime', typeDOUBLE);
    RegisterTypeAlias(H_Namespace, 'Longint', typeINTEGER);
    RegisterTypeAlias(H_Namespace, 'THandle', typeCARDINAL);
    RegisterTypeAlias(H_Namespace, 'LongWord', typeCARDINAL);
    RegisterTypeAlias(H_Namespace, 'HRESULT', typeINTEGER);
    RegisterTypeAlias(H_Namespace, 'HMODULE', typeINTEGER);

    RegisterPointerType(H_Namespace, 'PLongint', typeINTEGER);
    RegisterPointerType(H_Namespace, 'PInteger', typeINTEGER);
    RegisterPointerType(H_Namespace, 'PCardinal', typeCARDINAL);
    RegisterPointerType(H_Namespace, 'PWord', typeWORD);
    RegisterPointerType(H_Namespace, 'PByte', typeBYTE);
    RegisterPointerType(H_Namespace, 'PInt64', typeINT64);
    RegisterPointerType(H_Namespace, 'PLongWord', typeCARDINAL);
    RegisterPointerType(H_Namespace, 'PSingle', typeSINGLE);
    RegisterPointerType(H_Namespace, 'PDouble', typeDOUBLE);
    RegisterPointerType(H_Namespace, 'PExtended', typeEXTENDED);
    RegisterPointerType(H_Namespace, 'PCurrency', typeCURRENCY);
    RegisterPointerType(H_Namespace, 'PDate', typeDOUBLE);
    RegisterPointerType(H_Namespace, 'PVariant', typeVARIANT);
    RegisterPointerType(H_Namespace, 'PPointer', typePOINTER);
    RegisterPointerType(H_Namespace, 'PBoolean', typeBOOLEAN);
    RegisterPointerType(H_Namespace, 'PPWideChar', typePWIDECHAR);
    RegisterTypeAlias(  H_Namespace, 'PAnsiChar', typePANSICHAR);
    RegisterPointerType(H_Namespace, 'PPChar', typePANSICHAR);
    RegisterPointerType(H_Namespace, 'PPAnsiChar', typePANSICHAR);

{
  PGUID = ^TGUID;
  TGUID = packed record
    D1: LongWord;
    D2: Word;
    D3: Word;
    D4: array[0..7] of Byte;
  end;
}

    H_R0_7 := RegisterSubrangeType(0, '%0-7', typeINTEGER, 0, 7);
    H_TGUID_D4 := RegisterArrayType(0, '%TGUID_D4', H_R0_7, typeBYTE, 1);

    H_TGUID := RegisterRecordType(0, 'TGUID', 1);
    RegisterTypeField(H_TGUID, 'D1', typeCARDINAL);
    RegisterTypeField(H_TGUID, 'D2', typeWORD);
    RegisterTypeField(H_TGUID, 'D3', typeWORD);
    RegisterTypeField(H_TGUID, 'D4', H_TGUID_D4);

    H_PGUID := RegisterPointerType(0, 'PGUID', H_TGUID);

    H_IUnknown := RegisterInterfaceType(0, 'IUnknown', IUnknown);
    RegisterHeader(H_IUnknown, 'function QueryInterface(const IID: TGUID; out Obj): HResult; stdcall;', nil, 1);
    H_QueryInterface := LastSubId;
    RegisterHeader(H_IUnknown, 'function _AddRef: Integer; stdcall;', nil, 2);
    H_AddRef := LastSubId;
    RegisterHeader(H_IUnknown, 'function _Release: Integer; stdcall;', nil, 3);
    H_Release := LastSubId;

    RegisterTypeAlias(0, 'IInterface', H_IUNKNOWN);

    H_IDispatch := RegisterInterfaceType(0, 'IDispatch', IDispatch);
    RegisterHeader(H_IDispatch,
     'function GetTypeInfoCount(out Count: Integer): HResult; stdcall;', nil, 4);
    RegisterHeader(H_IDispatch,
     'function GetTypeInfo(Index, LocaleID: Integer; out TypeInfo): HResult; stdcall;', nil, 5);
    RegisterHeader(H_IDispatch,
      'function GetIDsOfNames(const IID: TGUID; Names: Pointer;' +
      'NameCount, LocaleID: Integer; DispIDs: Pointer): HResult; stdcall;', nil, 6);
    RegisterHeader(H_IDispatch,
      'function Invoke(DispID: Integer; const IID: TGUID; LocaleID: Integer;' +
      'Flags: Word; var Params; VarResult, ExcepInfo, ArgErr: Pointer): HResult; stdcall;', nil, 7);

// TObject

    H_TObject := RegisterClassType(0, TObject);
    H_TClass := RegisterClassReferenceType(0, 'TClass', H_TObject);

    RegisterConstructor(H_TObject, 'Create', @TObject.Create);
    RegisterDestructor(H_TObject, 'Destroy', @TObject.Destroy);
    Id_TObject_Destroy := LastSubId;
    RegisterMethod(H_TObject, 'Free', typeVOID, ccREGISTER, @TObject.Free);
    Id_TObject_Free := LastSubId;

    RegisterMethod(H_TObject, 'ClassName', typeSHORTSTRING, ccSTDCALL,
                   @TObject_ClassName);
    RegisterMethod(H_TObject, 'ClassType', H_TClass, ccREGISTER,
                   @TObject.ClassType, true);
    RegisterMethod(H_TObject, 'ClassParent', H_TClass, ccREGISTER,
                   @TObject.ClassParent, true);
    RegisterMethod(H_TObject, 'InstanceSize', typeINTEGER, ccREGISTER,
                   @TObject_InstanceSize);

    RegisterHeader(H_TObject, 'function SafeCallException(ExceptObject: TObject; ExceptAddr: Pointer): HResult; virtual;',
      @TObject.SafeCallException);
    RegisterHeader(H_TObject, 'procedure AfterConstruction; virtual;',
      @TObject.AfterConstruction);
    RegisterHeader(H_TObject, 'procedure BeforeDestruction; virtual;',
      @TObject.BeforeDestruction);
    RegisterHeader(H_TObject, 'procedure Dispatch(var Message); virtual;',
      @TObject.Dispatch);
    RegisterHeader(H_TObject, 'procedure DefaultHandler(var Message); virtual;',
      @TObject.DefaultHandler);
    RegisterHeader(H_TObject, 'class function NewInstance: TObject; virtual;',
      @TObject.NewInstance);
    RegisterHeader(H_TObject, 'procedure FreeInstance; virtual;',
      @TObject.FreeInstance);

    H_Sub := RegisterMethod(H_TObject, 'FieldAddress', typePOINTER, ccREGISTER,
                            @TObject.FieldAddress);
    RegisterParameter(H_Sub, typeSHORTSTRING, Unassigned, false, 'Name');

    H_Sub := RegisterMethod(H_TObject, 'InheritsFrom', typeBOOLEAN, ccREGISTER,
                            @TObject.InheritsFrom, true);
    RegisterParameter(H_Sub, H_TClass, Unassigned, false, 'AClass');

    H_Sub := RegisterMethod(H_TObject, 'MethodAddress', typePOINTER, ccREGISTER,
                            @TObject.MethodAddress, true);
    RegisterParameter(H_Sub, typeSHORTSTRING, Unassigned, false, 'Name');

    H_Sub := RegisterMethod(H_TObject, 'MethodName', typeSHORTSTRING, ccREGISTER,
                            @TObject.MethodName, true);
    RegisterParameter(H_Sub, typePOINTER, Unassigned, false, 'Address');

    RegisterHeader(H_TObject, 'function GetInterface(const IID: TGUID; out Obj): Boolean;',
             @ TObject_GetInterface);
    Id_TObject_GetInterface := LastSubId;

// TInterfacedObject
    H_TInterfacedObject := RegisterClassType(0, TInterfacedObject);
    RegisterSupportedInterface(H_TInterfacedObject, 'IUnknown', IUnknown);
    RegisterConstructor(H_TInterfacedObject, 'Create', @TInterfacedObject.Create);
    RegisterHeader(H_TInterfacedObject, 'class function NewInstance: TObject; override;',
       @TInterfacedObject.NewInstance);

    RegisterHeader(H_TInterfacedObject, 'function __GetRefCount: Integer;', @GetRefCount);
    RegisterHeader(H_TInterfacedObject, 'property RefCount: Integer read __GetRefCount;', nil);

    RegisterHeader(H_TInterfacedObject, 'function QueryInterface(const IID: TGUID; out Obj): HResult; stdcall;',
       @TMyInterfacedObject.QueryInterface);
    RegisterHeader(H_TInterfacedObject, 'function _AddRef: Integer; stdcall;',
       @TMyInterfacedObject_AddRef);
    RegisterHeader(H_TInterfacedObject, 'function _Release: Integer; stdcall;',
       @TMyInterfacedObject_Release);

// TInterfacedClass
    RegisterClassReferenceType(0, 'TInterfacedClass', H_TInterfacedObject);

    H_PExtended := RegisterPointerType(0, 'PExtended', typeEXTENDED);
    H_PShortString := RegisterPointerType(0, 'PShortString', typeSHORTSTRING);
    H_PString := RegisterPointerType(0, 'PString', typeANSISTRING);
    H_PVariant := RegisterPointerType(0, 'PVariant', typeVARIANT);

    RegisterConstant(0, 'vtInteger', typeINTEGER, vtInteger);
    RegisterConstant(0, 'vtBoolean', typeINTEGER, vtBoolean);
    RegisterConstant(0, 'vtChar', typeINTEGER, vtChar);
    RegisterConstant(0, 'vtExtended', typeINTEGER, vtExtended);
    RegisterConstant(0, 'vtString', typeINTEGER, vtString);
    RegisterConstant(0, 'vtPointer', typeINTEGER, vtPointer);
    RegisterConstant(0, 'vtPChar', typeINTEGER, vtPChar);
    RegisterConstant(0, 'vtObject', typeINTEGER, vtObject);
    RegisterConstant(0, 'vtClass', typeINTEGER, vtClass);
    RegisterConstant(0, 'vtWideChar', typeINTEGER, vtWideChar);
    RegisterConstant(0, 'vtPWideChar', typeINTEGER, vtPWideChar);
    RegisterConstant(0, 'vtAnsiString', typeINTEGER, vtAnsiString);
    RegisterConstant(0, 'vtCurrency', typeINTEGER, vtCurrency);
    RegisterConstant(0, 'vtVariant', typeINTEGER, vtVariant);
    RegisterConstant(0, 'vtInterface', typeINTEGER, vtInterface);
    RegisterConstant(0, 'vtWideString', typeINTEGER, vtWideString);
    RegisterConstant(0, 'vtInt64', typeINTEGER, vtInt64);

    H_TVarRec := RegisterRecordType(0, 'TVarRec', 1);
    RegisterTypeField(H_TVarRec, 'VInteger', typeINTEGER, 0);
    RegisterTypeField(H_TVarRec, 'VBoolean', typeBOOLEAN, 0);
    RegisterTypeField(H_TVarRec, 'VChar', typeANSICHAR, 0);
    RegisterTypeField(H_TVarRec, 'VExtended', H_PExtended, 0);
    RegisterTypeField(H_TVarRec, 'VString', H_PShortString, 0);
    RegisterTypeField(H_TVarRec, 'VPointer', typePOINTER, 0);
    RegisterTypeField(H_TVarRec, 'VPChar', typePANSICHAR, 0);
    RegisterTypeField(H_TVarRec, 'VObject', H_TObject, 0);
    RegisterTypeField(H_TVarRec, 'VClass', H_TClass, 0);
    RegisterTypeField(H_TVarRec, 'VWideChar', typeWIDECHAR, 0);
    RegisterTypeField(H_TVarRec, 'VAnsiString', H_PSTRING, 0);
    RegisterTypeField(H_TVarRec, 'VCurrency', typePOINTER, 0);
    RegisterTypeField(H_TVarRec, 'VVariant', H_PVARIANT, 0);
    RegisterTypeField(H_TVarRec, 'VInterface', typePOINTER, 0);
    RegisterTypeField(H_TVarRec, 'VWideString', typePOINTER, 0);
    RegisterTypeField(H_TVarRec, 'VInt64', typePOINTER, 0);

    RegisterTypeField(H_TVarRec, 'VType', typeINTEGER, 4);

    RegisterRoutine(0, '', typeVOID, ccSTDCALL, @ _AssignTVarRec);
    Id_AssignTVarRec := LastSubId;

    RegisterConstant(0, 'Null', typeVARIANT, Null);
    H_Unassigned := RegisterConstant(0, strUnassigned, typeVARIANT, Unassigned);

    RegisterConstant(0, 'MaxInt', typeINTEGER, MaxInt);

    H_TMethod := RegisterRecordType(0, 'TMethod', 1);
    RegisterTypeField(H_TMethod, 'Code', typePOINTER, 0);
    RegisterTypeField(H_TMethod, 'Data', typePOINTER, 4);

//    RegisterClassType(0, TPersistent);
//    RegisterClassType(0, TComponent);

    RegisterTypeAlias(H_Namespace, 'TVarType', typeWORD);
    RegisterPointerType(H_Namespace, 'PWideString', typeWIDESTRING);
    RegisterTypeAlias(H_Namespace, 'DWORD', typeCARDINAL);
    RegisterTypeAlias(H_Namespace, 'AnsiString', typeANSISTRING);
    RegisterTypeAlias(H_Namespace, 'AnsiChar', typeANSICHAR);

    RegisterConstant (H_Namespace, 'MaxLongInt', typeINTEGER, MaxLongInt);
    RegisterTypeAlias (H_Namespace, 'IInvokable', H_IUNKNOWN);
    H_Sub := RegisterRecordType (H_Namespace, 'TDispatchMessage', 8);
    RegisterTypeField(H_Sub, 'MsgID', typeWORD, 0);
    RegisterPointerType (H_Namespace, 'PAnsiString', typeANSISTRING);
    H := RegisterTypeAlias (H_Namespace, 'UCS2Char', typeWIDECHAR);
    RegisterPointerType (H_Namespace, 'PUCS2Char', H);
    H := RegisterTypeAlias (H_Namespace, 'UCS4Char', typeINTEGER); // typeLONGWORD
    RegisterPointerType (H_Namespace, 'PUCS4Char', H);
    H_Sub := RegisterArrayType (H_Namespace, 'TUCS4CharArray',
      RegisterSubrangeType (0, '%TUCS4CharArray', typeINTEGER, 0, $effffff),
      H,
      8
    );
    RegisterPointerType (H_Namespace, 'PUCS4CharArray', H_Sub);
    RegisterDynamicArrayType (H_Namespace, 'UCS4String', H);
    H_Sub := RegisterTypeAlias (H_Namespace, 'UTF8String', typeANSISTRING);
    RegisterPointerType (H_Namespace, 'PUTF8String', H_Sub);
    H_Sub := RegisterArrayType (H_Namespace, 'IntegerArray',
      RegisterSubrangeType (0, '%IntegerArray', typeINTEGER, 0, $effffff),
      typeINTEGER,
      8
    );
    RegisterPointerType (H_Namespace, 'PIntegerArray', H_Sub);
    H_Sub := RegisterArrayType (H_Namespace, 'PointerArray',
      RegisterSubRangeType (0, '%PointerArray', typeINTEGER, 0, 512*1024*1024 - 2),
      typePOINTER,
      8
    );
    RegisterPointerType (H_Namespace, 'PPointerArray', H_Sub);
    RegisterDynamicArrayType (H_Namespace, 'TBoundArray', typeINTEGER);
    H_Sub := RegisterArrayType (H_Namespace, 'TPCharArray',
      RegisterSubRangeType (0, '%TPCharArray', typeINTEGER, 0, (MaxLongint div SizeOf(PChar))-1),
      typePANSICHAR,
      1
    );
    RegisterPointerType (H_Namespace, 'PPCharArray', H_Sub);
    RegisterPointerType (H_Namespace, 'PSmallInt', typeSMALLINT);
    RegisterPointerType (H_Namespace, 'PShortInt', typeSHORTINT);
    H := RegisterPointerType (H_Namespace, 'PDispatch', H_IDispatch);
    RegisterPointerType (H_Namespace, 'PPDispatch', H);
    RegisterPointerType (H_Namespace, 'PError', typeINTEGER); //typeLONGWORD
    RegisterPointerType (H_Namespace, 'PWordBool', typeWORDBOOL);
    H := RegisterPointerType (H_Namespace, 'PUnknown', H_IUnknown);
    RegisterPointerType (H_Namespace, 'PPUnknown', H);
    RegisterPointerType (H_Namespace, 'POleVariant', typeOLEVARIANT);
    RegisterPointerType (H_Namespace, 'PDateTime', typeDOUBLE);
    H_Sub := RegisterRecordType (H_Namespace, 'TVarArrayBound', 1);
    RegisterTypeField (H_Sub, 'ElementCount', typeINTEGER);
    RegisterTypeField (H_Sub, 'LowBound', typeINTEGER);
    H_Sub := RegisterArrayType (H_Namespace, 'TVarArrayBoundArray',
      RegisterSubRangeType (H_Namespace, '%TVarArrayBoundArray', typeBYTE, H_Namespace, H_Namespace),
      H_Sub,
      8
    );
    RegisterPointerType (H_Namespace, 'PVarArrayBoundArray', H_Sub);
    H := RegisterArrayType (H_Namespace, 'TVarArrayCoorArray',
      RegisterSubRangeType (H_Namespace, '%TVarArrayCoorArray', typeBYTE, H_Namespace, H_Namespace),
      typeINTEGER,
      8
    );
    RegisterPointerType (H_Namespace, 'PVarArrayCoorArray', H);

    H := RegisterRecordType (H_Namespace, 'TVarArray', 1);
    RegisterTypeField (H, 'DimCount', typeWORD);
    RegisterTypeField (H, 'Flags', typeWORD);
    RegisterTypeField (H, 'ElementSize', typeINTEGER);
    RegisterTypeField (H, 'LockCount', typeINTEGER);
    RegisterTypeField (H, 'Data', typePOINTER);
    RegisterTypeField (H, 'Bounds', H_Sub);
    RegisterPointerType (0, 'PVarArray', H);
    H_Sub := RegisterRecordType(0, 'TVarData', 1);
    RegisterVariantRecordTypeField(H_Sub, 'VType: TVarType',           01);
    RegisterVariantRecordTypeField(H_Sub, 'Reserved1: Word',         0101);
    RegisterVariantRecordTypeField(H_Sub, 'Reserved2: Word',       010101);
    RegisterVariantRecordTypeField(H_Sub, 'Reserved3: Word',       010101);
    RegisterVariantRecordTypeField(H_Sub, 'VSmallInt: SmallInt', 01010101);
    RegisterVariantRecordTypeField(H_Sub, 'VInteger: Integer',   02010101);
    RegisterVariantRecordTypeField(H_Sub, 'VSingle: Single',     03010101);
    RegisterVariantRecordTypeField(H_Sub, 'VDouble: Double',     04010101);
    RegisterVariantRecordTypeField(H_Sub, 'VCurrency: Currency', 05010101);
    RegisterVariantRecordTypeField(H_Sub, 'VDate: TDateTime',    06010101);
    RegisterVariantRecordTypeField(H_Sub, 'VOleStr: PWideChar',  07010101);
    RegisterVariantRecordTypeField(H_Sub, 'VDispatch: Pointer',  08010101);
    RegisterVariantRecordTypeField(H_Sub, 'VError: HRESULT',     09010101);
    RegisterVariantRecordTypeField(H_Sub, 'VBoolean: WordBool',  10010101);
    RegisterVariantRecordTypeField(H_Sub, 'VUnknown: Pointer',   11010101);
    RegisterVariantRecordTypeField(H_Sub, 'VShortInt: ShortInt', 12010101);
    RegisterVariantRecordTypeField(H_Sub, 'VByte: Byte',         13010101);
    RegisterVariantRecordTypeField(H_Sub, 'VWord: Word',         14010101);
    RegisterVariantRecordTypeField(H_Sub, 'VLongWord: LongWord', 15010101);
    RegisterVariantRecordTypeField(H_Sub, 'VInt64: Int64',       16010101);
    RegisterVariantRecordTypeField(H_Sub, 'VString: Pointer',    17010101);
    RegisterVariantRecordTypeField(H_Sub, 'VAny: Pointer',       18010101);
    RegisterVariantRecordTypeField(H_Sub, 'VArray: Pointer',     19010101);
    RegisterVariantRecordTypeField(H_Sub, 'VPointer: Pointer',   20010101);
    RegisterPointerType (H_Namespace, 'PVarData', H_Sub);
    RegisterTypeAlias (H_Namespace, 'TVarOp', typeINTEGER);
    H_Sub := RegisterRecordType (H_Namespace, 'TCallDesc', 1);
    RegisterTypeField (H_Sub, 'CallType', typeBYTE);
    RegisterTypeField (H_Sub, 'ArgCount', typeBYTE);
    RegisterTypeField (H_Sub, 'NamedArgCount', typeBYTE);
    H := RegisterDynamicArrayType (0, '%ArgTypes',
      RegisterSubRangeType (0, '%%ArgTypes', typeINTEGER, 0, 255)
    );
    RegisterTypeField (H_Sub, 'ArgTypes', H);
    RegisterPointerType (H_Namespace, 'PCallDesc', H_Sub);

    H := RegisterRecordType (H_Namespace, 'TDispDesc', 1);
    RegisterTypeField (H, 'DispID', typeINTEGER);
    RegisterTypeField (H, 'ResType', typeBYTE);
    RegisterTypeField (H, 'CallDesc', H_Sub);
    RegisterPointerType (H_Namespace, 'PDispDesc', H);

    {
    TDynArrayTypeInfo
    PDynArrayTypeInfo
    }
    RegisterPointerType (H_Namespace, 'PVarRec', H_TVarRec);
    H := RegisterEnumType (H_Namespace, 'TTextLineBreakStyle', typeINTEGER);
    RegisterEnumValue (H, 'tlbsLF', H_Namespace);
    RegisterEnumValue (H, 'tlbsCRLF', 1);
    H := RegisterTypeAlias (H_Namespace, 'HRSRC', typeCARDINAL); // THandle
    RegisterTypeAlias (H_Namespace, 'TResourceHandle', H);
    H := RegisterTypeAlias (H_Namespace, 'HINST', typeCARDINAL); // THandle
    RegisterTypeAlias (H_Namespace, 'HGLOBAL', H);
    H := RegisterPointerType(H_Namespace, 'PCardinal', typeCARDINAL); // redefined
    H_Sub := RegisterRecordType (H_Namespace, 'TResStringRec', 1);
    RegisterTypeField (H_Sub, 'Module', H);
    RegisterTypeField (H_Sub, 'Identifier', typeINTEGER);
    RegisterPointerType (H_Namespace, 'PResStringRec', H_Sub);

    H := RegisterRoutine (H_Namespace, '%TThreadFunc', typeINTEGER, ccREGISTER, Nil);
    RegisterParameter (H, typePOINTER, Unassigned);
    H_Sub := RegisterProceduralType (H_Namespace, 'TThreadFunc', H);
    H := RegisterRoutine (H_Namespace, 'BeginThread', typeINTEGER, ccREGISTER, @BeginThread);
    RegisterParameter (H, typePointer, Unassigned); // SecurityAttributes: Pointer;
    RegisterParameter (H, typeCARDINAL, Unassigned); // StackSize: LongWord;
    RegisterParameter (H, H_Sub, Unassigned); //ThreadFunc: TThreadFunc;
    RegisterParameter (H, typePOINTER, Unassigned); //Parameter: Pointer;
    RegisterParameter (H, typeCARDINAL, Unassigned); //CreationFlags: LongWord;
    RegisterParameter (H, typeCARDINAL, Unassigned, ByRef); // var ThreadId: LongWord
    H := RegisterRoutine (H_Namespace, 'EndThread', typeVOID, ccREGISTER, @EndThread);
    RegisterParameter (H, typeINTEGER, Unassigned); // EndThread(ExitCode: Integer);

    {
    H_Sub := RegisterClass (H_Namespace, TAggregatedObject);
    H_Sub := RegisterClass (H_Namespace, TContainedObject);
    }

    RegisterConstant(H_Namespace, 'varEmpty', varEmpty);
    RegisterConstant(H_Namespace, 'varNull', varNull);
    RegisterConstant(H_Namespace, 'varSmallint', varSmallint);
    RegisterConstant(H_Namespace, 'varInteger', varInteger);
    RegisterConstant(H_Namespace, 'varSingle', varSingle);
    RegisterConstant(H_Namespace, 'varDouble', varDouble);
    RegisterConstant(H_Namespace, 'varCurrency', varCurrency);
    RegisterConstant(H_Namespace, 'varDate', varDate);
    RegisterConstant(H_Namespace, 'varOleStr', varOleStr);
    RegisterConstant(H_Namespace, 'varDispatch', varDispatch);
    RegisterConstant(H_Namespace, 'varError', varError);
    RegisterConstant(H_Namespace, 'varBoolean', varBoolean);
    RegisterConstant(H_Namespace, 'varVariant', varVariant);
    RegisterConstant(H_Namespace, 'varUnknown', varUnknown);
{$IFDEF VARIANTS}
    RegisterConstant(H_Namespace, 'varShortInt', varShortInt);
{$ENDIF}
    RegisterConstant(H_Namespace, 'varByte', varByte);
{$IFDEF VARIANTS}
    RegisterConstant(H_Namespace, 'varWord', varWord);
    RegisterConstant(H_Namespace, 'varLongWord', varLongWord);
    RegisterConstant(H_Namespace, 'varInt64', varInt64);
{$ENDIF}
    RegisterConstant(H_Namespace, 'varStrArg', varStrArg);
    RegisterConstant(H_Namespace, 'varString', varString);
    RegisterConstant(H_Namespace, 'varAny', varAny);
    RegisterConstant(H_Namespace, 'varTypeMask', varTypeMask);
    RegisterConstant(H_Namespace, 'varArray', varArray);
    RegisterConstant(H_Namespace, 'varByRef', varByRef);

    H := RegisterRecordType (H_Namespace, 'TInterfaceEntry', 1);
    RegisterTypeField(H, 'IID', H_TGUID);
    RegisterTypeField(H, 'VTable', typePOINTER);
    RegisterTypeField(H, 'IOffset', typeINTEGER);
    RegisterTypeField(H, 'ImplGetter', typeINTEGER);
    RegisterPointerType(H_Namespace, 'PInterfaceEntry', H);

    H_TEntries := RegisterArrayType(0, '',
      RegisterSubrangeType(0, '', typeINTEGER, 0, 9999), H, 1);

    H := RegisterRecordType (H_Namespace, 'TInterfaceTable', 1);
    RegisterTypeField(H, 'EntryCount', typeINTEGER);
    RegisterTypeField(H, 'Entries', H_TEntries);

    H_Sub := RegisterRoutine(0, '', typeVOID, ccREGISTER, @_WriteUnicString);
    Id_WriteUnicString := LastSubId;
    RegisterParameter(H_Sub, typeUNICSTRING, Unassigned);
    RegisterParameter(H_Sub, typeINTEGER, Unassigned);
    H_WriteUnicString := H_Sub;

    RegisterRoutine(0, '', typeVOID, ccSTDCALL, @_UnicStringFromPAnsiChar);
    Id_UnicStringFromPAnsiChar := LastSubId;

    RegisterRoutine(0, '', typeVOID, ccSTDCALL, @_UnicStringFromPWideChar);
    Id_UnicStringFromPWideChar := LastSubId;

    RegisterRoutine(0, '', typeVOID, ccSTDCALL, @_UnicStringFromAnsiChar);
    Id_UnicStringFromAnsiChar := LastSubId;

    RegisterRoutine(0, '', typeVOID, ccSTDCALL, @ _UnicStringFromWideChar);
    Id_UnicStringFromWideChar := LastSubId;

    RegisterRoutine(0, '', typeVOID, ccSTDCALL, @_ShortStringFromUnicString);
    Id_ShortStringFromUnicString := LastSubId;

    RegisterRoutine(0, '', typeVOID, ccSTDCALL, @_UnicStringFromShortString);
    Id_UnicStringFromShortString := LastSubId;

    RegisterRoutine(0, '', typeVOID, ccSTDCALL, @_AnsiStringFromUnicString);
    Id_AnsiStringFromUnicString := LastSubId;

    RegisterRoutine(0, '', typeVOID, ccSTDCALL, @_UnicStringFromAnsiString);
    Id_UnicStringFromAnsiString := LastSubId;

    RegisterRoutine(0, '', typeVOID, ccSTDCALL, @_WideStringFromUnicString);
    Id_WideStringFromUnicString := LastSubId;

    RegisterRoutine(0, '', typeVOID, ccSTDCALL, @_UnicStringFromWideString);
    Id_UnicStringFromWideString := LastSubId;

    RegisterRoutine(0, '', typeVOID, ccSTDCALL, @_VariantFromUnicString);
    Id_VariantFromUnicString := LastSubId;

    RegisterRoutine(0, '', typeVOID, ccSTDCALL, @_UnicStringFromVariant);
    Id_UnicStringFromVariant := LastSubId;

    RegisterRoutine(0, '', typeVOID, ccSTDCALL, @_OleVariantFromUnicString);
    Id_OleVariantFromUnicString := LastSubId;

    RegisterRoutine(0, '', typeVOID, ccSTDCALL, @_UnicStringAddition);
    Id_UnicStringAddition := LastSubId;

    RegisterRoutine(0, '', typeVOID, ccSTDCALL, @_UnicStringAssign);
    Id_UnicStringAssign := LastSubId;

    RegisterRoutine(0, '', typeVOID, ccSTDCALL, @_UnicStringEquality);
    Id_UnicStringEquality := LastSubId;

    RegisterRoutine(0, '', typeVOID, ccSTDCALL, @_UnicStringNotEquality);
    Id_UnicStringNotEquality := LastSubId;

    RegisterRoutine(0, '', typeVOID, ccSTDCALL, @ _UnicStringGreaterThan);
    Id_UnicStringGreaterThan := LastSubId;

    RegisterRoutine(0, '', typeVOID, ccSTDCALL, @_UnicStringGreaterThanOrEqual);
    Id_UnicStringGreaterThanOrEqual := LastSubId;

    RegisterRoutine(0, '', typeVOID, ccSTDCALL, @_UnicStringLessThan);
    Id_UnicStringLessThan := LastSubId;

    RegisterRoutine(0, '', typeVOID, ccSTDCALL, @_UnicStringLessThanOrEqual);
    Id_UnicStringLessThanOrEqual := LastSubId;

    RegisterRoutine(0, '', typeVOID, ccSTDCALL, @_UnicStringClr);
    Id_UnicStringClr := LastSubId;

    RegisterRoutine(0, '', typeVOID, ccSTDCALL, @_UnicStringAddRef);
    Id_UnicStringAddRef := LastSubId;

    RegisterRoutine(0, '', typeVOID, ccSTDCALL, @_SetUnicStringLength);
    Id_SetUnicStringLength := LastSubId;

    RegisterRoutine(0, '', typeVOID, ccSTDCALL, @_VariantFromPWideChar);
    Id_VariantFromPWideChar := LastSubId;

    RegisterRoutine(0, '', typeVOID, ccSTDCALL, @_OleVariantFromPWideChar);
    Id_OleVariantFromPWideChar := LastSubId;

    RegisterRoutine(0, '', typeVOID, ccSTDCALL, @_GetUnicStrProp);
    Id_GetUnicStrProp := LastSubId;

    RegisterRoutine(0, '', typeVOID, ccSTDCALL, @_SetUnicStrProp);
    Id_SetUnicStrProp := LastSubId;

    RegisterRoutine(0, '', typeVOID, ccSTDCALL, @ _AnsiStringFromPWideChar);
    Id_AnsiStringFromPWideChar := LastSubId;

    RegisterRoutine(0, '', typeVOID, ccSTDCALL, @_ShortStringFromPWideChar);
    Id_ShortStringFromPWideChar := LastSubId;

    {$IFDEF UNIC}
    // Length, Pos, Copy, Insert, Delete

    H_Sub := RegisterRoutine(H_Namespace, 'Length', typeINTEGER, ccREGISTER,
                             @_UnicLength);
    RegisterParameter(H_Sub, typeUNICSTRING, Unassigned, false, 'S');

    H_Sub := RegisterRoutine(H_Namespace, 'Delete', typeVOID, ccREGISTER,
                             @_UnicDelete);
    RegisterParameter(H_Sub, typeUNICSTRING, Unassigned, ByRef, 'S');
    RegisterParameter(H_Sub, typeINTEGER, Unassigned, false, 'Index');
    RegisterParameter(H_Sub, typeINTEGER, Unassigned, false, 'Count');

    H_Sub := RegisterRoutine(H_Namespace, 'Insert', typeVOID, ccREGISTER,
                             @_UnicInsert);
    RegisterParameter(H_Sub, typeUNICSTRING, Unassigned, false, 'Substr');
    RegisterParameter(H_Sub, typeUNICSTRING, Unassigned, ByRef, 'Dest');
    RegisterParameter(H_Sub, typeINTEGER, Unassigned, false, 'Index');

    H_Sub := RegisterRoutine(H_Namespace, 'Val', typeVOID, ccREGISTER,
                             @_UnicValInt);
    RegisterParameter(H_Sub, typeUNICSTRING, Unassigned, false, 'S');
    RegisterParameter(H_Sub, typeINTEGER, Unassigned, ByRef, 'V');
    RegisterParameter(H_Sub, typeINTEGER, Unassigned, ByRef, 'Code');

    H_Sub := RegisterRoutine(H_Namespace, 'Val', typeVOID, ccREGISTER,
                             @_UnicValDouble);
    RegisterParameter(H_Sub, typeUNICSTRING, Unassigned, false, 'X');
    RegisterParameter(H_Sub, typeDOUBLE, Unassigned, ByRef, 'V');
    RegisterParameter(H_Sub, typeINTEGER, Unassigned, ByRef, 'Code');

    H_Sub := RegisterRoutine(H_Namespace, 'Copy', typeUNICSTRING, ccREGISTER,
                             @_UnicCopy);
    RegisterParameter(H_Sub, typeUNICSTRING, Unassigned, false, 'S');
    RegisterParameter(H_Sub, typeINTEGER, Unassigned, false, 'Index');
    RegisterParameter(H_Sub, typeINTEGER, Unassigned, false, 'Count');

    H_Sub := RegisterRoutine(H_Namespace, 'Pos', typeINTEGER, ccREGISTER,
                            @_UnicPos);
    RegisterParameter(H_Sub, typeUNICSTRING, Unassigned, false, 'Substr');
    RegisterParameter(H_Sub, typeUNICSTRING, Unassigned, false, 'Str');

    {$ENDIF}

    ID_Prog := RegisterClassType(0, TProgram);
    RegisterHeader(ID_Prog, 'procedure __Set_ExitCode(value: Integer); stdcall;',
      @Set_ExitCode);
    RegisterHeader(ID_Prog, 'function __Get_ExitCode: Integer; stdcall;',
      @Get_ExitCode);
    RegisterHeader(ID_Prog, 'property ExitCode: Integer read __Get_ExitCode write __Set_ExitCode;', nil);

    RegisterRoutine(0, '', typeVOID, ccSTDCALL, @ _StructEquality);
    Id_StructEquality := LastSubId;

    RegisterRoutine(0, '', typeVOID, ccSTDCALL, @ _StructNotEquality);
    Id_StructNotEquality := LastSubId;

    Register_TYPEINFO(H_Namespace);

    RegisterRoutine(0, '', typeVOID, ccSTDCALL, @ _LoadSeg);
    Id_LoadSeg := LastSubId;

    RegisterRoutine(0, '', typeVOID, ccSTDCALL, @ _LoadClassRef);
    Id_LoadClassRef := LastSubId;

    StdCard := GlobalSymbolTable.Card;
    StdSize := GlobalSymbolTable.GetDataSize;

    SR0 := GlobalSymbolTable[0];
  end;
finalization
  GlobalSymbolTable.Free;

end.

