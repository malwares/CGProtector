////////////////////////////////////////////////////////////////////////////
// PaxCompiler
// Site: http://www.paxcompiler.com
// Author: Alexander Baranovsky (paxscript@gmail.com)
// ========================================================================
// Copyright (c) Alexander Baranovsky, 2006-2008. All rights reserved.
// Code Version: 2.4
// ========================================================================
// Unit: PaxRegister.pas
// ========================================================================
////////////////////////////////////////////////////////////////////////////

{$I PaxCompiler.def}
unit PaxRegister;
interface

uses
  SysUtils,
  Classes,
  TypInfo,
  PAXCOMP_CONSTANTS,
  PAXCOMP_SYS,
  PAXCOMP_FORBID,
  PAXCOMP_SYMBOL_REC,
  PAXCOMP_BASESYMBOL_TABLE,
  PAXCOMP_STDLIB;

const
  _ccSTDCALL = 1;
  _ccREGISTER = 2;
  _ccCDECL = 3;
  _ccPASCAL = 4;
  _ccSAFECALL = 5;
  _ccMSFASTCALL = 6;

  _visPUBLIC = 0;
  _visPROTECTED = 1;
  _visPRIVATE = 2;

  _cmNONE = 0;
  _cmVIRTUAL = 1;
  _cmOVERRIDE = 2;

  _typeVOID = 1;
  _typeBOOLEAN = 2;
  _typeBYTE = 3;
  _typeANSICHAR = 4;
  _typeANSISTRING = 5;
  _typeWORD = 6;
  _typeINTEGER = 7;
  _typeDOUBLE = 8;
  _typePOINTER = 9;
  _typeRECORD = 10;
  _typeARRAY = 11;
  _typeALIAS = 12;
  _typeENUM = 13;
  _typePROC = 14;
  _typeSET = 15;
  _typeSHORTSTRING = 16;
  _typeSINGLE = 17;
  _typeEXTENDED = 18;
  _typeCLASS = 19;
  _typeWIDECHAR = 21;
  _typeWIDESTRING = 22;
  _typeVARIANT = 23;
  _typeDYNARRAY = 24;
  _typeINT64 = 25;
  _typeCARDINAL = 27;
  _typeCURRENCY = 29;
  _typeSMALLINT = 30;
  _typeSHORTINT = 31;
  _typeWORDBOOL = 32;
  _typeLONGBOOL = 33;
  _typeBYTEBOOL = 34;
  _typeOLEVARIANT = 35;
  _typeUNICSTRING = 36;

{$IFDEF UNIC}
  _typeSTRING = _typeUNICSTRING;
  _typeCHAR = _typeWIDECHAR;
{$ELSE}
  _typeSTRING = _typeANSISTRING;
  _typeCHAR = _typeANSICHAR;
{$ENDIF}

  _typePCHAR = 49;
  _typePVOID = 50;
  _typePWIDECHAR = 51;
var
  _Unassigned: Variant;

function RegisterNamespace(LevelId: Integer; const Name: String): Integer;

procedure RegisterUsingNameSpace(const aNameSpaceName: String); overload;
procedure RegisterUsingNameSpace(aNameSpaceID: Integer); overload;

procedure UnregisterUsingNameSpace(aNameSpaceID: Integer); overload;
procedure UnregisterUsingNameSpace(const aNameSpaceName: String); overload;
procedure UnregisterUsingNameSpaces;

function RegisterConstant(LevelId: Integer; const Name: String; TypeId: Integer;
                          const Value: Variant): Integer; overload;
function RegisterConstant(LevelId: Integer; const Name: String;
                          const Value: Variant): Integer; overload;
function RegisterConstant(LevelId: Integer; const Declaration: String): Integer; overload;
function RegisterVariable(LevelId: Integer;
                          const Name: String; TypeId: Integer;
                          Address: Pointer): Integer; overload;
function RegisterVariable(LevelId: Integer;
                          const Declaration: String; Address: Pointer): Integer; overload;
function RegisterObject(LevelId: Integer;
                        const ObjectName: String;
                        TypeId: Integer;
                        Address: Pointer = nil): Integer;
function RegisterRoutine(LevelId: Integer; const Name: String; ResultId: Integer;
                         Address: Pointer; CallConvention: Integer = _ccREGISTER): Integer;
procedure RegisterMember(LevelId: Integer; const Name: String;
                         Address: Pointer);
function RegisterConstructor(ClassId: Integer; const Name: String;
                             Address: Pointer): Integer;
function RegisterDestructor(ClassId: Integer; const Name: String;
                             Address: Pointer): Integer;
function RegisterMethod(ClassId: Integer;
                        const Name: String;
                        ResultId: Integer;
                        Address: Pointer;
                        CallConvention: Integer = _ccREGISTER;
                        IsShared: Boolean = false;
                        CallMode: Integer = _cmNONE;
                        MethodIndex: Integer = 0): Integer;
function RegisterHeader(LevelId: Integer;
                        const Header: String; Address: Pointer;
                        MethodIndex: Integer = 0): Integer;
function RegisterFakeHeader(LevelId: Integer;
                        const Header: String; Address: Pointer;
                        MethodIndex: Integer = 0): Integer;
function RegisterParameter(LevelId: Integer; TypeId: Integer;
                           ByRef: Boolean = false): Integer; overload;
function RegisterParameter(LevelId: Integer; TypeId: Integer;
                           const DefaultValue: Variant;
                           ByRef: Boolean = false): Integer; overload;
function RegisterParameter(LevelId: Integer;
                           ParameterName: String;
                           TypeID: Integer;
                           const DefaultValue: Variant;
                           ByRef: Boolean = false): Integer; overload;
function RegisterParameterEx(LevelId: Integer;
                             ParameterName: String;
                             TypeID: Integer;
                             const DefaultValue: Variant;
                             ByRef: Boolean;
                             IsConst: Boolean): Integer;
function RegisterInterfaceType(LevelId: Integer;
                               const TypeName: String;
                               const GUID: TGUID): Integer; overload;
function RegisterInterfaceType(LevelId: Integer;
                               const TypeName: String;
                               const GUID: TGUID;
                               const ParentName: String;
                               const ParentGUID: TGUID): Integer; overload;

procedure RegisterSupportedInterface(TypeId: Integer;
                                     const SupportedInterfaceName: String;
                                     const GUID: TGUID);
function RegisterClassType(LevelId: Integer; C: TClass; DoRegisterClass: Boolean = false): Integer; overload;
function RegisterClassType(LevelId: Integer;
                           const TypeName: String; AncestorId: Integer): Integer; overload;
function RegisterClassType(LevelId: Integer;
                           const TypeName: String): Integer; overload;
function RegisterClassTypeForImporter(LevelId: Integer;
                                      C: TClass): Integer;
procedure RegisterClassTypeInfos(ClassId: Integer;
                                     C: TClass);
function RegisterClassReferenceType(LevelId: Integer;
                           const TypeName: String; OriginClassId: Integer): Integer; overload;
function RegisterClassReferenceType(LevelId: Integer;
                           const TypeName: String): Integer; overload;
function RegisterClassReferenceType(LevelID: Integer; const TypeName, OriginalTypeName: String): Integer; overload;
function RegisterClassTypeField(ClassTypeId: Integer; const Name: String;
                                TypeID: Integer; Shift: Integer = -1): Integer;
function RegisterProperty(LevelId: Integer; const PropName: String;
                          PropTypeID, ReadId, WriteId: Integer;
                          IsDefault: Boolean): Integer; overload;
function RegisterProperty(LevelId: Integer; const Header: String): Integer; overload;
function RegisterInterfaceProperty(LevelId: Integer;
                                   const PropName: String;
                                   PropTypeID,
                                   ReadIndex,
                                   WriteIndex: Integer): Integer;
function RegisterRecordType(LevelId: Integer;
                            const TypeName: String;
                            IsPacked: Boolean = false): Integer;
function RegisterRecordTypeField(TypeId: Integer; const FieldName: String;
                                FieldTypeID: Integer;
                                FieldOffset: Integer = -1): Integer; overload;
function RegisterRecordTypeField(TypeId: Integer; const Declaration: String
                                 ): Integer; overload;

function RegisterVariantRecordTypeField(LevelId: Integer; const FieldName: String;
                                FieldTypeID: Integer;
                                VarCount: Int64): Integer; overload;
function RegisterVariantRecordTypeField(LevelId: Integer; const Declaration: String;
                                VarCount: Int64): Integer; overload;
function RegisterSubrangeType(LevelId: Integer;
                              const TypeName: String;
                              TypeBaseId: Integer;
                              B1, B2: Integer): Integer;

function RegisterEnumType(LevelId: Integer;
                          const TypeName: String;
                          TypeBaseId: Integer = _typeINTEGER): Integer;
function RegisterEnumValue(EnumTypeId: Integer;
                           const FieldName: String;
                           const Value: Integer): Integer;

function RegisterArrayType(LevelId: Integer;
                           const TypeName: String;
                           RangeTypeId, ElemTypeId: Integer;
                           IsPacked: Boolean = false): Integer;
function RegisterDynamicArrayType(LevelId: Integer;
                           const TypeName: String;
                           ElemTypeId: Integer): Integer;
function RegisterPointerType(LevelId: Integer;
                             const TypeName: String;
                             OriginTypeId: Integer): Integer;
function RegisterSetType(LevelId: Integer;
                         const TypeName: String;
                         OriginTypeId: Integer): Integer;

function RegisterProceduralType(LevelId: Integer;
                                const TypeName: String;
                                SubId: Integer): Integer;
function RegisterShortStringType(LevelId: Integer;
                                 const TypeName: String;
                                 L: Integer): Integer;

function RegisterEventType(LevelId: Integer;
                           const TypeName: String;
                           SubId: Integer): Integer;
function RegisterRTTIType(LevelId: Integer;
                          pti: PTypeInfo): Integer;
function RegisterTypeAlias(LevelId:Integer;
                           const TypeName: String;
                           OriginTypeId: Integer): Integer; overload;
function RegisterTypeAlias(LevelId:Integer;
                           const Declaration: String): Integer; overload;

function RegisterTypeDeclaration(LevelId: Integer;
                        const Declaration: String): Integer;

function RegisterDummyType(LevelId: Integer;
                           const TypeName: String): Integer;
function RegisterSomeType(LevelId: Integer;
                          const TypeName: String): Integer;
procedure RegisterSpace(K: Integer);

procedure ForbidClass(C: TClass);
procedure ForbidPublishedProperty(C: TClass; const PropName: String);
procedure ForbidAllPublishedProperties(C: TClass);

function LookupTypeId(const TypeName: String): Integer;
function LookupTypeNamespaceId(const TypeName: String): Integer;
function LookupNamespace(LevelId: Integer; const NamespaceName: String;
                         CaseSensitive: Boolean): Integer; overload;
function LookupNamespace(const NamespaceName: String): Integer; overload;

procedure SaveNamespaceToStream(const NamespaceName: String;
                                S: TStream);
procedure SaveNamespaceToFile(const NamespaceName: String;
                              const FileName: String);

procedure LoadNamespaceFromStream(S: TStream);
procedure LoadNamespaceFromFile(const FileName: String);

procedure RegisterAlignment(value: Integer);
procedure SetVisibility(C: TClass; const MemberName: String; value: Integer);

procedure EndOfRegistration(CheckProc: TCheckProc; Data: Pointer); overload;
procedure EndOfRegistration; overload;

var MustRegisterClass: Boolean = false;

implementation

procedure ForbidPublishedProperty(C: TClass; const PropName: String);
begin
  if ForbiddenPropList = nil then
    ForbiddenPropList := TForbiddenPropList.Create;

  ForbiddenPropList.Add(C, PropName);
end;

procedure ForbidAllPublishedProperties(C: TClass);
begin
  if ForbiddenPropList = nil then
    ForbiddenPropList := TForbiddenPropList.Create;

  ForbiddenPropList.AddAll(C);
end;

procedure RaiseError(const Message: string; params: array of Const);
begin
  if RaiseE then
    raise Exception.Create(Format(Message, params))
  else
  begin
    REG_ERROR := Format(Message, params);
    REG_OK := false;

    if Message = errUndeclaredIdentifier then
      REG_ERROR := '';
  end;
end;

function RegisterNamespace(LevelId: Integer; const Name: String): Integer; overload;
begin
  result := GlobalSymbolTable.RegisterNamespace(LevelId, Name);
end;

procedure RegisterUsingNameSpace(const aNameSpaceName: String); overload;
Var
  H: integer;
begin
  H := GlobalSymbolTable.LookupNamespace(aNameSpaceName, 0, True);
  if H > 0 then
    RegisterUsingNameSpace (H);
end;

procedure RegisterUsingNameSpace(aNameSpaceID: Integer);
begin
  GlobalSymbolTable.HeaderParser.UsedNamespaceList.Add(aNameSpaceID);
end;

procedure UnregisterUsingNameSpace(aNameSpaceID: Integer); overload;
begin
  GlobalSymbolTable.HeaderParser.UsedNamespaceList.DeleteValue(aNameSpaceID);
end;

procedure UnregisterUsingNameSpaces;
begin
  GlobalSymbolTable.HeaderParser.UsedNamespaceList.Clear;
end;

procedure UnregisterUsingNameSpace(const aNameSpaceName: String); overload;
Var
  H: integer;
begin
  H := GlobalSymbolTable.LookupNamespace(aNameSpaceName, 0, True);
  if H > 0 then
    UnRegisterUsingNameSpace (H);
end;

function RegisterConstant(LevelId: Integer; const Name: String; TypeId: Integer;
                          const Value: Variant): Integer;
begin
  result := GlobalSymbolTable.RegisterConstant(LevelId, Name, TypeId, Value);
end;

function RegisterConstant(LevelId: Integer; const Name: String;
                          const Value: Variant): Integer;
begin
  result := GlobalSymbolTable.RegisterConstant(LevelId, Name, Value);
end;

function RegisterConstant(LevelId: Integer; const Declaration: String): Integer;
begin
  result := GlobalSymbolTable.RegisterConstant(LevelId, Declaration);
end;

function RegisterObject(LevelId: Integer;
                        const ObjectName: String;
                        TypeId: Integer;
                        Address: Pointer = nil): Integer;
begin
  result := GlobalSymbolTable.RegisterObject(LevelId, ObjectName, TypeId, Address);
end;

function RegisterVariable(LevelId: Integer;
                          const Name: String; TypeId: Integer;
                          Address: Pointer): Integer;
begin
  result := GlobalSymbolTable.RegisterVariable(LevelId, Name, TypeId, Address);
end;

function RegisterVariable(LevelId: Integer;
                          const Declaration: String; Address: Pointer): Integer;
begin
  result := GlobalSymbolTable.RegisterVariable(LevelId, Declaration, Address);
end;

function RegisterRoutine(LevelId: Integer; const Name: String;
                         ResultId: Integer;
                         Address: Pointer; CallConvention: Integer = _ccREGISTER): Integer;
begin
  result := GlobalSymbolTable.RegisterRoutine(LevelId, Name, ResultId, CallConvention, Address);
end;

procedure RegisterMember(LevelId: Integer; const Name: String;
                        Address: Pointer);
begin
  GlobalSymbolTable.RegisterMember(LevelId, Name, Address);
end;

function RegisterConstructor(ClassId: Integer; const Name: String;
                             Address: Pointer): Integer;
begin
  result := GlobalSymbolTable.RegisterConstructor(ClassId, Name, Address);
end;

function RegisterDestructor(ClassId: Integer; const Name: String;
                             Address: Pointer): Integer;
begin
  result := GlobalSymbolTable.RegisterDestructor(ClassId, Name, Address);
end;

function RegisterMethod(ClassId: Integer;
                        const Name: String;
                        ResultId: Integer;
                        Address: Pointer;
                        CallConvention: Integer = _ccREGISTER;
                        IsShared: Boolean = false;
                        CallMode: Integer = _cmNONE;
                        MethodIndex: Integer = 0): Integer;
begin
  result := GlobalSymbolTable.RegisterMethod(ClassId,
                                             Name,
                                             ResultId,
                                             CallConvention,
                                             Address,
                                             IsShared,
                                             CallMode,
                                             MethodIndex);
end;

function RegisterHeader(LevelId: Integer;
                        const Header: String; Address: Pointer;
                        MethodIndex: Integer = 0): Integer;
begin
  result := GlobalSymbolTable.RegisterHeader(LevelId, Header, Address, MethodIndex);
end;

function RegisterFakeHeader(LevelId: Integer;
                            const Header: String; Address: Pointer;
                            MethodIndex: Integer = 0): Integer;
begin
  result := GlobalSymbolTable.RegisterHeader(LevelId, Header, Address, MethodIndex);
  GlobalSymbolTable[GlobalSymbolTable.LastSubId].Vis := cvPrivate;
end;

function RegisterParameter(LevelId: Integer; TypeId: Integer; ByRef: Boolean = false): Integer;
begin
  result := GlobalSymbolTable.RegisterParameter(LevelId, TypeId, _Unassigned, ByRef);
end;

function RegisterParameter(LevelId: Integer; TypeId: Integer;
                           const DefaultValue: Variant; ByRef: Boolean = false): Integer;
begin
  result := GlobalSymbolTable.RegisterParameter(LevelId, TypeId, DefaultValue, ByRef);
end;

function RegisterParameter(LevelId: Integer;
                           ParameterName: String;
                           TypeID: Integer;
                           const DefaultValue: Variant;
                           ByRef: Boolean = false): Integer;
begin
  result := GlobalSymbolTable.RegisterParameter(LevelId, TypeId, DefaultValue, ByRef, ParameterName);
end;

function RegisterParameterEx(LevelId: Integer;
                             ParameterName: String;
                             TypeID: Integer;
                             const DefaultValue: Variant;
                             ByRef: Boolean;
                             IsConst: Boolean): Integer;
begin
  result := GlobalSymbolTable.RegisterParameter(LevelId, TypeId, DefaultValue, ByRef, ParameterName);
  if IsConst then
    GlobalSymbolTable[GlobalSymbolTable.Card].IsConst := true;
end;

function RegisterClassType(LevelId: Integer; C: TClass; DoRegisterClass: Boolean = false): Integer;
begin
  if DoRegisterClass or MustRegisterClass then
    if C.InheritsFrom(TPersistent) then
      if Classes.GetClass(C.ClassName) = nil then
        Classes.RegisterClass(TPersistentClass(C));

  result := GlobalSymbolTable.RegisterClassType(LevelId, C);
end;

function RegisterClassTypeForImporter(LevelId: Integer;
                                      C: TClass): Integer;
begin
  result := GlobalSymbolTable.RegisterClassTypeForImporter(LevelId, C);
end;

function RegisterInterfaceType(LevelId: Integer;
                               const TypeName: String;
                               const GUID: TGUID;
                               const ParentName: String;
                               const ParentGUID: TGUID): Integer;
begin
  result := GlobalSymbolTable.RegisterInterfaceType(LevelId, TypeName, GUID);
  GlobalSymbolTable.RegisterSupportedInterface(result, ParentName, ParentGUID);
end;

function RegisterInterfaceType(LevelId: Integer;
                               const TypeName: String;
                               const GUID: TGUID): Integer;
begin
  result := GlobalSymbolTable.RegisterInterfaceType(LevelId, TypeName, GUID);
end;

procedure RegisterSupportedInterface(TypeId: Integer;
                                     const SupportedInterfaceName: String;
                                     const GUID: TGUID);
begin
  GlobalSymbolTable.RegisterSupportedInterface(TypeId, SupportedInterfaceName, GUID);
end;

function RegisterClassType(LevelId: Integer;
                           const TypeName: String; AncestorId: Integer): Integer;
begin
  result := GlobalSymbolTable.RegisterClassType(LevelId, TypeName, AncestorId);
end;

function RegisterClassType(LevelId: Integer;
                           const TypeName: String): Integer;
begin
  result := GlobalSymbolTable.RegisterClassType(LevelId, TypeName, H_TObject);
end;

procedure RegisterClassTypeInfos(ClassId: Integer;
                                     C: TClass);
begin
  GlobalSymbolTable.RegisterClassTypeInfos(ClassId, C);
end;

function RegisterClassReferenceType(LevelId: Integer;
                           const TypeName: String; OriginClassId: Integer): Integer;
begin
  result := GlobalSymbolTable.RegisterClassReferenceType(LevelId, TypeName, OriginClassId);
end;

function RegisterClassReferenceType(LevelId: Integer;
                           const TypeName: String): Integer;
var
  OriginClassId: Integer;
  OriginTypeName: String;
begin
  OriginTypeName := Copy(TypeName, 1, Length(TypeName) - 5);
  OriginClassId := GlobalSymbolTable.LookUpType(OriginTypeName, 0, true);
  if OriginClassId = 0 then
  begin
    result := 0;
    RaiseError(errUndeclaredIdentifier, [OriginTypeName]);
    Exit;
  end;
  result := GlobalSymbolTable.RegisterClassReferenceType(LevelId, TypeName, OriginClassId);
end;

function RegisterClassReferenceType(LevelID: Integer; const TypeName, OriginalTypeName: String): Integer; overload;
var
  OriginClassId: Integer;
begin
  OriginClassId := GlobalSymbolTable.LookUpType(OriginalTypeName, 0, true);
  if OriginClassId = 0 then
  begin
    result := 0;
    RaiseError(errUndeclaredIdentifier, [OriginalTypeName]);
    Exit;
  end;
  result := GlobalSymbolTable.RegisterClassReferenceType(LevelId, TypeName, OriginClassId);
end;

function RegisterClassTypeField(ClassTypeId: Integer; const Name: String;
                                TypeID: Integer; Shift: Integer = -1): Integer;
begin
  result := GlobalSymbolTable.RegisterTypeField(ClassTypeId, Name, TypeId, Shift);
end;

function RegisterProperty(LevelId: Integer; const PropName: String;
                          PropTypeID, ReadId, WriteId: Integer;
                          IsDefault: Boolean): Integer;
begin
  result := GlobalSymbolTable.RegisterProperty(LevelId, PropName,
                                        PropTypeId, ReadId, WriteId, IsDefault);
end;

function RegisterInterfaceProperty(LevelId: Integer;
                                   const PropName: String;
                                   PropTypeID,
                                   ReadIndex,
                                   WriteIndex: Integer): Integer;
begin
  result := GlobalSymbolTable.RegisterInterfaceProperty(LevelId, PropName, PropTypeId,
                                    ReadIndex, WriteIndex);
end;

function RegisterProperty(LevelId: Integer; const Header: String): Integer;
begin
  result := GlobalSymbolTable.RegisterHeader(LevelId, Header, nil);
end;

function RegisterRecordType(LevelId: Integer;
                            const TypeName: String;
                            IsPacked: Boolean = false): Integer;
begin
  if IsPacked then
    result := GlobalSymbolTable.RegisterRecordType(LevelId, TypeName, 1)
  else
    result := GlobalSymbolTable.RegisterRecordType(LevelId, TypeName, GlobalAlignment);
end;

function RegisterDummyType(LevelId: Integer;
                           const TypeName: String): Integer;
begin
  result := GlobalSymbolTable.RegisterDummyType(LevelId, TypeName);
end;

function RegisterSomeType(LevelId: Integer;
                           const TypeName: String): Integer;
begin
  result := GlobalSymbolTable.RegisterSomeType(LevelId, TypeName);
end;

function LookupNamespace(LevelId: Integer; const NamespaceName: String;
                         CaseSensitive: Boolean): Integer;
begin
  result := GlobalSymbolTable.LookupNamespace(NamespaceName, LevelId, not CaseSensitive);
end;

function LookupNamespace(const NamespaceName: String): Integer; overload;
begin
  result := LookupNamespace(0, NamespaceName, true);
end;

function RegisterRecordTypeField(TypeId: Integer; const FieldName: String;
                                 FieldTypeID: Integer; FieldOffset: Integer = -1): Integer;
begin
  result := GlobalSymbolTable.RegisterTypeField(TypeId, FieldName,
                                                FieldTypeId, FieldOffset);
end;

function RegisterRecordTypeField(TypeId: Integer; const Declaration: String
                                 ): Integer;
begin
  result := GlobalSymbolTable.RegisterTypeFieldEx(TypeId, Declaration);
end;

function RegisterVariantRecordTypeField(LevelId: Integer; const FieldName: String;
                                FieldTypeID: Integer;
                                VarCount: Int64): Integer;
begin
  result := GlobalSymbolTable.RegisterVariantRecordTypeField(LevelId,
                                                           FieldName,
                                                           FieldTypeId,
                                                           VarCount);
end;

function RegisterVariantRecordTypeField(LevelId: Integer; const Declaration: String;
                                VarCount: Int64): Integer;
begin
  result := GlobalSymbolTable.RegisterVariantRecordTypeField(LevelId,
      Declaration, VarCount);
end;

function RegisterSubrangeType(LevelId: Integer;
                              const TypeName: String;
                              TypeBaseId: Integer;
                              B1, B2: Integer): Integer;
begin
  result := GlobalSymbolTable.RegisterSubrangeType(LevelId, TypeName, TypeBaseId, B1, B2);
end;

function RegisterTypeDeclaration(LevelId: Integer;
                                 const Declaration: String): Integer;
begin
  result := GlobalSymbolTable.RegisterTypeDeclaration(LevelId, Declaration);
end;

function LookupTypeId(const TypeName: String): Integer;
begin
//  result := GlobalSymbolTable.HeaderParser.LookupId(TypeName);
  result := GlobalSymbolTable.LookupType(TypeName, true);
end;

function LookupTypeNamespaceId(const TypeName: String): Integer;
var
  R: TSymbolRec;
  L, Id: Integer;
begin
  result := 0;
  Id := LookupTypeId(TypeName);
  if Id = 0 then
    Exit;

  L := GlobalSymbolTable[Id].Level;

  repeat
    if L = 0 then
    begin
      result := 0;
      Exit;
    end;

    R := GlobalSymbolTable[L];

    if R.Kind = kindNAMESPACE then
    begin
      result := R.Id;
      Exit;
    end;

    L := R.Level;

  until false;
end;


function RegisterEnumType(LevelId: Integer;
                          const TypeName: String;
                          TypeBaseId: Integer = _typeINTEGER): Integer;
begin
  result := GlobalSymbolTable.RegisterEnumType(LevelId, TypeName, TypeBaseId);
end;

function RegisterEnumValue(EnumTypeId: Integer;
                           const FieldName: String;
                           const Value: Integer): Integer;
begin
  result := GlobalSymbolTable.RegisterEnumValue(EnumTypeId, FieldName, Value);
end;

function RegisterArrayType(LevelId: Integer;
                           const TypeName: String;
                           RangeTypeId, ElemTypeId: Integer;
                           IsPacked: Boolean = false): Integer;
begin
  if IsPacked then
    result := GlobalSymbolTable.RegisterArrayType(LevelId, TypeName, RangeTypeId, ElemTypeId, 1)
  else
    result := GlobalSymbolTable.RegisterArrayType(LevelId, TypeName, RangeTypeId, ElemTypeId, GlobalAlignment);
end;

function RegisterDynamicArrayType(LevelId: Integer;
                           const TypeName: String;
                           ElemTypeId: Integer): Integer;
begin
  result := GlobalSymbolTable.RegisterDynamicArrayType(LevelId, TypeName, ElemTypeId);
end;

function RegisterPointerType(LevelId: Integer;
                             const TypeName: String;
                             OriginTypeId: Integer): Integer;
begin
  result := GlobalSymbolTable.RegisterPointerType(LevelId, TypeName, OriginTypeId);
end;

function RegisterSetType(LevelId: Integer;
                         const TypeName: String;
                         OriginTypeId: Integer): Integer;
begin
  result := GlobalSymbolTable.RegisterSetType(LevelId, TypeName, OriginTypeId);
end;

function RegisterProceduralType(LevelId: Integer;
                                const TypeName: String;
                                SubId: Integer): Integer;
begin
  result := GlobalSymbolTable.RegisterProceduralType(LevelId, TypeName, SubId);
end;

function RegisterShortStringType(LevelId: Integer;
                                 const TypeName: String;
                                 L: Integer): Integer;
begin
  result := GlobalSymbolTable.RegisterShortStringType(LevelId, TypeName, L);
end;

function RegisterEventType(LevelId: Integer;
                           const TypeName: String;
                           SubId: Integer): Integer;
begin
  result := GlobalSymbolTable.RegisterEventType(LevelId, TypeName, SubId);
end;

function RegisterRTTIType(LevelId: Integer; pti: PTypeInfo): Integer;
begin
  result := GlobalSymbolTable.RegisterRTTIType(LevelId, pti);
end;

function RegisterTypeAlias(LevelId:Integer; const TypeName: String;
                           OriginTypeId: Integer): Integer;
begin
  result := GlobalSymbolTable.RegisterTypeAlias(LevelId, TypeName, OriginTypeId);
end;

function RegisterTypeAlias(LevelId:Integer;
                           const Declaration: String): Integer;
begin
  result := GlobalSymbolTable.RegisterTypeAlias(LevelId, Declaration);
end;

procedure RegisterSpace(K: Integer);
begin
  GlobalSymbolTable.RegisterSpace(K);
end;

procedure RegisterAlignment(value: Integer);
begin
  GlobalAlignment := value;
end;

procedure SetVisibility(C: TClass; const MemberName: String; value: Integer);
begin
  GlobalSymbolTable.SetVisibility(C, MemberName, value);
end;

procedure SaveNamespaceToStream(const NamespaceName: String;
                                S: TStream);
begin
  GlobalSymbolTable.SaveNamespaceToStream(NamespaceName, S);
end;

procedure SaveNamespaceToFile(const NamespaceName: String;
                              const FileName: String);
begin
  GlobalSymbolTable.SaveNamespaceToFile(NamespaceName, FileName);
end;

procedure LoadNamespaceFromStream(S: TStream);
begin
  GlobalSymbolTable.LoadNamespaceFromStream(S);
end;

procedure LoadNamespaceFromFile(const FileName: String);
begin
  GlobalSymbolTable.LoadNamespaceFromFile(FileName);
end;

{$O-}
procedure EndOfRegistration(CheckProc: TCheckProc; Data: Pointer);
var
  I, J, L: Integer;
  RI: TSymbolRec;
  pti: PTypeInfo;
  ptd: PTypeData;
  C: TClass;
  S, err: String;
  LS: TStringList;
  found: Boolean;
begin
  GlobalSymbolTable.ResolveExternList(CheckProc, Data);
  err := '';
  LS := TStringList.Create;
  try
    for I:=1 to GlobalSymbolTable.Card do
    begin
      RI := GlobalSymbolTable[I];
      if RI.Kind = kindTYPE then
        RI.Completed := true
      else
        RI.Size;
      if RI.FinalTypeId = typeCLASS then
      begin
        if I <= StdCard then
          continue;

        C := RI.PClass;
        if C = nil then
          continue;

        pti := C.ClassInfo;
        if pti = nil then
          continue;

        ptd := GetTypeData(pti);
        if ptd = nil then
          continue;
        L := RI.Level;
        if L > 0 then
          S := GlobalSymbolTable[L].Name
        else
          S := '';
        if not StrEql(S, String(ptd^.UnitName)) then
        begin
          err := RI.Name + '(' + String(ptd^.UnitName) + ')' +
                 errWrongRegistration + '-' + S;
          found := false;
          for J := 0 to LS.Count - 1 do
            if StrEql(LS[J], err) then
            begin
              found := true;
              break;
            end;
          if not found then
            LS.Add(err);
        end;
      end;
    end;

    err := '';
    for J := 0 to LS.Count - 1 do
      err := err + LS[J] + #13#10;

  finally
    LS.Free;
  end;

  if err <> '' then
    RaiseError(errWrongRegistration + ':' + err, []);
end;

procedure EndOfRegistration;
begin
  EndOfRegistration(nil, nil);
end;

procedure ForbidClass(C: TClass);
begin
  GlobalSymbolTable.HideClass(C);
end;

end.
