////////////////////////////////////////////////////////////////////////////
// PaxCompiler
// Site: http://www.paxcompiler.com
// Author: Alexander Baranovsky (paxscript@gmail.com)
// ========================================================================
// Copyright (c) Alexander Baranovsky, 2006-2008. All rights reserved.
// Code Version: 2.4
// ========================================================================
// Unit: PaxCompilerExplorer.pas
// ========================================================================
////////////////////////////////////////////////////////////////////////////

{$I PaxCompiler.def}
unit PaxCompilerExplorer;
interface
uses
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
  PAXCOMP_SYMBOL_TABLE,
  PAXCOMP_KERNEL,
  PAXCOMP_MAP,
  PAXCOMP_STDLIB,
  PaxCompiler;
type
  TPaxMemberKind = (pmkNamespace, pmkType, pmkField, pmkProperty, pmkProcedure, pmkFunction,
                 pmkConstructor, pmkDestructor,
                 pmkParam, pmkVar, pmkConst);

  TExplorerEnumProc = procedure (Id: Integer;
                                 Host: Boolean;
                                 Kind: TPaxMemberKind;
                                 Data: Pointer) of object;

  TPaxCompilerExplorer = class(TComponent)
  private
    compiler: TPaxCompiler;
    procedure TestId(Id: Integer);
    procedure TestSubId(SubId: Integer);
    procedure TestNamespaceId(NamespaceId: Integer);
    procedure TestArrayId(ArrayId: Integer);
//    procedure TestDynArrayId(DynArrayId: Integer);

    function GetName(Id: Integer): String;
    function GetTypeName(Id: Integer): String;
    function GetPosition(Id: Integer): Integer;
  protected
  public
    constructor Create(AOwner: TComponent); override;
    destructor Destroy; override;
    procedure RegisterCompiler(i_compiler: TPaxCompiler);
    function IsExecutableLine(const ModuleName: String;
                              LineNumber: Integer): Boolean;

    function GetParamCount(SubId: Integer): Integer;
    function GetParamId(SubId, I: Integer): Integer;

    function GetLocalCount(SubId: Integer): Integer;
    function GetLocalId(SubId, I: Integer): Integer;

    function GetGlobalCount(NamespaceId: Integer): Integer;
    function GetGlobalId(NamespaceId, I: Integer): Integer;

    function HasArrayType(Id: Integer): Boolean;
    function HasDynArrayType(Id: Integer): Boolean;
    function HasRecordType(Id: Integer): Boolean;
    function HasClassType(Id: Integer): Boolean;

    function IsArrayType(Id: Integer): Boolean;
    function IsDynArrayType(Id: Integer): Boolean;
    function IsRecordType(Id: Integer): Boolean;
    function IsClassType(Id: Integer): Boolean;

    function Host(Id: Integer): Boolean;

    function GetFieldCount(Id: Integer): Integer;
    function GetFieldName(Id, FieldNumber: Integer): String;
    function GetFieldId(Id, FieldNumber: Integer): Integer;

    function GetPublishedPropCount(Id: Integer): Integer;
    function GetPublishedPropName(Id, PropNumber: Integer): String;

    function GetArrayLowBound(Id: Integer): Integer;
    function GetArrayHighBound(Id: Integer): Integer;

    function GetNamespaceId(Id: Integer): Integer;
    function GetVisibility(Id: Integer): TClassVisibility;
    function GetReadId(PropId: Integer): Integer;
    function GetWriteId(PropId: Integer): Integer;
//    function GetArrayDef(Id: Integer): String;

    procedure EnumMembers(OwnerId: Integer;
                          Host: Boolean;
                          pmk: TPaxMemberKind;
                          CallBack: TExplorerEnumProc;
                          Data: Pointer);

    function IsConst(LevelId, Id: Integer): Boolean;
    function IsVar(LevelId, Id: Integer): Boolean;
    function IsProcedure(LevelId, Id: Integer): Boolean;
    function IsFunction(LevelId, Id: Integer): Boolean;
    function IsNamespace(LevelId, Id: Integer): Boolean;
    function IsType(LevelId, Id: Integer): Boolean;
    function IsTypeField(TypeId, Id: Integer): Boolean;
    function IsProperty(TypeId, Id: Integer): Boolean;
    function IsConstructor(TypeId, Id: Integer): Boolean;
    function IsDestructor(TypeId, Id: Integer): Boolean;
    function IsByRefParam(Id: Integer): Boolean;
    function IsConstParam(Id: Integer): Boolean;
    function IsMethod(Id: Integer): Boolean;

    property Names[Id: Integer]: String read GetName;
    property TypeNames[Id: Integer]: String read GetTypeName;
    property Positions[Id: Integer]: Integer read GetPosition;
  end;

implementation

/////////////// TPaxCompilerExplorer ///////////////////////////////////////////

procedure RaiseError(const Message: string; params: array of Const);
begin
  raise Exception.Create(Format(Message, params))
end;

constructor TPaxCompilerExplorer.Create(AOwner: TComponent);
begin
  inherited;
  compiler := nil;
end;

destructor TPaxCompilerExplorer.Destroy;
begin
  inherited;
end;

procedure TPaxCompilerExplorer.RegisterCompiler(i_compiler: TPaxCompiler);
begin
  compiler := i_compiler;
end;

function TPaxCompilerExplorer.IsExecutableLine(const ModuleName: String;
                                      LineNumber: Integer): Boolean;
begin
  result := TKernel(compiler.GetKernelPtr).IsExecutableLine(ModuleName,
    LineNumber);
end;

procedure TPaxCompilerExplorer.TestId(Id: Integer);
begin
  if (Id <= 0) or (Id > TKernel(compiler.GetKernelPtr).SymbolTable.Card) then
    RaiseError(errInvalidId, [Id]);
end;

procedure TPaxCompilerExplorer.TestSubId(SubId: Integer);
begin
  TestId(SubId);
  if not (TKernel(compiler.GetKernelPtr).SymbolTable[SubId].Kind in [kindSUB,
    KindCONSTRUCTOR, KindDESTRUCTOR]) then
    RaiseError(errInvalidId, [SubId]);
end;

procedure TPaxCompilerExplorer.TestNamespaceId(NamespaceId: Integer);
begin
  if NamespaceId = 0 then
    Exit;
  TestId(NamespaceId);
  if TKernel(compiler.GetKernelPtr).SymbolTable[NamespaceId].Kind <>
    kindNAMESPACE then
    RaiseError(errInvalidId, [NamespaceId]);
end;

function TPaxCompilerExplorer.GetName(Id: Integer): String;
begin
  TestId(Id);
  result := TKernel(compiler.GetKernelPtr).SymbolTable[Id].Name;
end;

function TPaxCompilerExplorer.GetPosition(Id: Integer): Integer;
begin
  TestId(Id);
  result := TKernel(compiler.GetKernelPtr).SymbolTable[Id].Position;
end;

function TPaxCompilerExplorer.GetTypeName(Id: Integer): String;
var
  TypeId: Integer;
begin
  TestId(Id);
  TypeId := TKernel(compiler.GetKernelPtr).SymbolTable[Id].TypeId;
  if TypeId = 0 then
    result := ''
  else
    result := TKernel(compiler.GetKernelPtr).SymbolTable[TypeId].Name;
end;

function TPaxCompilerExplorer.GetParamCount(SubId: Integer): Integer;
begin
  TestSubId(SubId);
  result := TKernel(compiler.GetKernelPtr).SymbolTable[SubId].Count;
end;

function TPaxCompilerExplorer.GetParamId(SubId, I: Integer): Integer;
begin
  TestId(SubId);
  result := TKernel(compiler.GetKernelPtr).SymbolTable.GetParamId(SubId, I);
end;

function TPaxCompilerExplorer.GetLocalCount(SubId: Integer): Integer;
begin
  TestSubId(SubId);
  result := TKernel(compiler.GetKernelPtr).SymbolTable.GetLocalCount(SubId);
end;

function TPaxCompilerExplorer.GetLocalId(SubId, I: Integer): Integer;
begin
  TestSubId(SubId);
  result := TKernel(compiler.GetKernelPtr).SymbolTable.GetLocalId(SubId, I);
end;

function TPaxCompilerExplorer.GetGlobalCount(NamespaceId: Integer): Integer;
begin
  TestNamespaceId(NamespaceId);
  result := TKernel(compiler.GetKernelPtr).SymbolTable.GetGlobalCount(NamespaceId);
end;

function TPaxCompilerExplorer.GetGlobalId(NamespaceId, I: Integer): Integer;
begin
  TestNamespaceId(NamespaceId);
  result := TKernel(compiler.GetKernelPtr).SymbolTable.GetGlobalId(NamespaceId, I);
end;

function TPaxCompilerExplorer.GetFieldCount(Id: Integer): Integer;
var
  T: Integer;
  TypeMapRec: TTypeMapRec;
  TypeMap: TTypeMap;
begin
  TestId(Id);
  T := TKernel(compiler.GetKernelPtr).SymbolTable[Id].FinalTypeId;
  if T in [typeRECORD, typeCLASS] then
  begin
    TypeMap := TKernel(compiler.GetKernelPtr).TypeMap;
    T := TKernel(compiler.GetKernelPtr).SymbolTable[Id].TerminalTypeId;
    TypeMapRec := TypeMap.Lookup(T);
    if TypeMapRec = nil then
      TypeMapRec := TypeMap.Add(T)
    else
      if TypeMapRec.Completed then
      begin
        result := TypeMapRec.Fields.Count;
        Exit;
      end;
    TypeMapRec.Fields.Clear;
    result := TKernel(compiler.GetKernelPtr).SymbolTable.GetFieldCount(Id,
      TypeMapRec);
    TypeMapRec.Completed := true;
  end
  else
    result := 0;
end;

function TPaxCompilerExplorer.GetFieldName(Id, FieldNumber: Integer): String;
var
  FieldId: Integer;
  TypeMapRec: TTypeMapRec;
begin
  TestId(Id);

  TypeMapRec := TKernel(compiler.GetKernelPtr).GetTypeMapRec(Id);
  if TypeMapRec <> nil then
  begin
    FieldId := TypeMapRec.Fields[FieldNumber];
    result := TKernel(compiler.GetKernelPtr).SymbolTable[FieldId].Name;
  end
  else
    result := '';
end;

function TPaxCompilerExplorer.GetFieldId(Id, FieldNumber: Integer): Integer;
var
  TypeMapRec: TTypeMapRec;
begin
  TestId(Id);
  TypeMapRec := TKernel(compiler.GetKernelPtr).GetTypeMapRec(Id);
  if TypeMapRec <> nil then
    result := TypeMapRec.Fields[FieldNumber]
  else
    result := 0;
end;

function TPaxCompilerExplorer.GetPublishedPropCount(Id: Integer): Integer;
begin
  TestId(Id);
  result := TKernel(compiler.GetKernelPtr).SymbolTable.GetPublishedPropCount(Id);
end;

function TPaxCompilerExplorer.GetPublishedPropName(Id, PropNumber: Integer): String;
begin
  TestId(Id);
  result := TKernel(compiler.GetKernelPtr).SymbolTable.GetPublishedPropName(Id,
    PropNumber);
end;

procedure TPaxCompilerExplorer.TestArrayId(ArrayId: Integer);
begin
  if ArrayId = 0 then
    Exit;
  TestId(ArrayId);
  if TKernel(compiler.GetKernelPtr).SymbolTable[ArrayId].FinalTypeId <>
    typeARRAY then
    RaiseError(errInvalidId, [ArrayId]);
end;

{
procedure TPaxCompilerExplorer.TestDynArrayId(DynArrayId: Integer);
begin
  if DynArrayId = 0 then
    Exit;
  TestId(DynArrayId);
  if TKernel(compiler.GetKernelPtr).SymbolTable[DynArrayId].FinalTypeId <>
    typeDYNARRAY then
    RaiseError(errInvalidId, [DynArrayId]);
end;
}

function TPaxCompilerExplorer.GetArrayLowBound(Id: Integer): Integer;
var
  TypeId, RangeTypeId, ElemTypeId: Integer;
begin
  TestArrayId(Id);
  TypeId := TKernel(compiler.GetKernelPtr).SymbolTable[Id].TerminalTypeId;
  with TKernel(compiler.GetKernelPtr).SymbolTable do
  begin
    GetArrayTypeInfo(TypeId, RangeTypeId, ElemTypeId);
    result := GetLowBoundRec(RangeTypeId).Value;
  end;
end;

function TPaxCompilerExplorer.GetArrayHighBound(Id: Integer): Integer;
var
  TypeId, RangeTypeId, ElemTypeId: Integer;
begin
  TestArrayId(Id);
  TypeId := TKernel(compiler.GetKernelPtr).SymbolTable[Id].TerminalTypeId;
  with TKernel(compiler.GetKernelPtr).SymbolTable do
  begin
    GetArrayTypeInfo(TypeId, RangeTypeId, ElemTypeId);
    result := GetHighBoundRec(RangeTypeId).Value;
  end;
end;

function TPaxCompilerExplorer.HasArrayType(Id: Integer): Boolean;
begin
  TestId(Id);
  with TKernel(compiler.GetKernelPtr).SymbolTable[Id] do
    result := (Kind = KindVAR) and (FinalTypeId = typeARRAY);
end;

function TPaxCompilerExplorer.HasDynArrayType(Id: Integer): Boolean;
begin
  TestId(Id);
  with TKernel(compiler.GetKernelPtr).SymbolTable[Id] do
    result := (Kind = KindVAR) and (FinalTypeId = typeDYNARRAY);
end;

function TPaxCompilerExplorer.HasRecordType(Id: Integer): Boolean;
begin
  TestId(Id);
  with TKernel(compiler.GetKernelPtr).SymbolTable[Id] do
    result := (Kind = KindVAR) and (FinalTypeId = typeRECORD);
end;

function TPaxCompilerExplorer.HasClassType(Id: Integer): Boolean;
begin
  TestId(Id);
  with TKernel(compiler.GetKernelPtr).SymbolTable[Id] do
    result := (Kind = KindVAR) and (FinalTypeId = typeCLASS);
end;

function TPaxCompilerExplorer.IsArrayType(Id: Integer): Boolean;
begin
  TestId(Id);
  with TKernel(compiler.GetKernelPtr).SymbolTable[Id] do
    result := (Kind = KindTYPE) and (FinalTypeId = typeARRAY);
end;

function TPaxCompilerExplorer.IsDynArrayType(Id: Integer): Boolean;
begin
  TestId(Id);
  with TKernel(compiler.GetKernelPtr).SymbolTable[Id] do
    result := (Kind = KindTYPE) and (FinalTypeId = typeDYNARRAY);
end;

function TPaxCompilerExplorer.IsRecordType(Id: Integer): Boolean;
begin
  TestId(Id);
  with TKernel(compiler.GetKernelPtr).SymbolTable[Id] do
    result := (Kind = KindTYPE) and (FinalTypeId = typeRECORD);
end;

function TPaxCompilerExplorer.IsClassType(Id: Integer): Boolean;
begin
  TestId(Id);
  with TKernel(compiler.GetKernelPtr).SymbolTable[Id] do
    result := (Kind = KindTYPE) and (FinalTypeId = typeCLASS);
end;

function TPaxCompilerExplorer.Host(Id: Integer): Boolean;
begin
  TestId(Id);
  result := TKernel(compiler.GetKernelPtr).SymbolTable[Id].Host;
end;

procedure TPaxCompilerExplorer.EnumMembers(OwnerId: Integer;
                                           Host: Boolean;
                                           pmk: TPaxMemberKind;
                                           CallBack: TExplorerEnumProc;
                                           Data: Pointer);
var
  SymbolTable: TSymbolTable;
  Count, K, I: Integer;
begin
  SymbolTable := TKernel(compiler.GetKernelPtr).SymbolTable;

  if OwnerId = 0 then
  begin
    case pmk of
      pmkProcedure:
      begin
        if Host then
          for I:=1 to SymbolTable.CompileCard do
          begin
            if SymbolTable[I] = SR0 then
              break;
            if SymbolTable[I].Kind = kindNAMESPACE then
              break;

            if SymbolTable.IsProcedure(OwnerId, I) then
              CallBack(I, Host, pmk, Data);
          end
        else
          for I:=SymbolTable.CompileCard + 1 to SymbolTable.Card do
          begin
            if SymbolTable[I].Kind = kindNAMESPACE then
              break;

            if SymbolTable.IsProcedure(OwnerId, I) then
              CallBack(I, Host, pmk, Data);
          end;
      end;
      pmkFunction:
      begin
        if Host then
          for I:=1 to SymbolTable.CompileCard do
          begin
            if SymbolTable[I] = SR0 then
              break;
            if SymbolTable[I].Kind = kindNAMESPACE then
              break;

            if SymbolTable.IsFunction(OwnerId, I) then
              CallBack(I, Host, pmk, Data);
          end
        else
          for I:=SymbolTable.CompileCard + 1 to SymbolTable.Card do
          begin
            if SymbolTable[I].Kind = kindNAMESPACE then
              break;

            if SymbolTable.IsFunction(OwnerId, I) then
              CallBack(I, Host, pmk, Data);
          end;
      end;
      pmkConst:
      begin
        if Host then
          for I:=1 to SymbolTable.CompileCard do
          begin
            if SymbolTable[I] = SR0 then
              break;
            if SymbolTable[I].Kind = kindNAMESPACE then
              break;

            if SymbolTable.IsConst(OwnerId, I) then
                  CallBack(I, Host, pmk, Data);
          end
        else
          for I:=SymbolTable.CompileCard + 1 to SymbolTable.Card do
          begin
            if SymbolTable[I].Kind = kindNAMESPACE then
              break;

            if SymbolTable.IsConst(OwnerId, I) then
                  CallBack(I, Host, pmk, Data);
          end;
      end;
      pmkVar:
      begin
        if Host then
          for I:=1 to SymbolTable.CompileCard do
          begin
            if SymbolTable[I] = SR0 then
              break;
            if SymbolTable[I].Kind = kindNAMESPACE then
              break;

            if SymbolTable.IsVar(OwnerId, I) then
              CallBack(I, Host, pmk, Data);
          end
        else
          for I:=SymbolTable.CompileCard + 1 to SymbolTable.Card do
          begin
            if SymbolTable[I].Kind = kindNAMESPACE then
              break;

            if SymbolTable.IsVar(OwnerId, I) then
              CallBack(I, Host, pmk, Data);
          end;
      end;
      pmkType:
      begin
        if Host then
          for I:=1 to SymbolTable.CompileCard do
          begin
            if SymbolTable[I] = SR0 then
              break;
          if SymbolTable[I].Kind = kindNAMESPACE then
            break;

            if SymbolTable.IsType(OwnerId, I) then
              CallBack(I, Host, pmk, Data);
          end
        else
          for I:=SymbolTable.CompileCard + 1 to SymbolTable.Card do
          begin
            if SymbolTable.IsType(OwnerId, I) then
              CallBack(I, Host, pmk, Data);
          end;
      end;
      pmkNamespace:
      begin
        if Host then
          for I:=1 to SymbolTable.CompileCard do
          begin
            if SymbolTable[I] = SR0 then
              break;

            if SymbolTable.IsNamespace(OwnerId, I) then
              CallBack(I, Host, pmk, Data);
          end
        else
          for I:=SymbolTable.CompileCard + 1 to SymbolTable.Card do
          begin
            if SymbolTable.IsNamespace(OwnerId, I) then
              CallBack(I, Host, pmk, Data);
          end;
      end;
    end;

    Exit;
  end;

  K := SymbolTable[OwnerId].Kind;
  if K = KindSUB then
  begin
    case pmk of
      pmkParam:
      begin
        Count := SymbolTable[OwnerId].Count;
        K := 0;
        for I:=OwnerId + 1 to SymbolTable.Card do
        begin
          if SymbolTable.IsParam(OwnerId, I) then
          begin
            CallBack(I, Host, pmk, Data);
            Inc(K);
            if K = Count then
              break;
          end;
        end;
      end;
      pmkVar:
        for I:=OwnerId + 1 to SymbolTable.Card do
        begin
          if SymbolTable[I] = SR0 then
            break;
          if SymbolTable[I].Kind = kindNAMESPACE then
            break;

          if SymbolTable.IsVar(OwnerId, I) then
            CallBack(I, Host, pmk, Data);
        end;
      pmkConst:
        for I:=OwnerId + 1 to SymbolTable.Card do
        begin
          if SymbolTable[I] = SR0 then
            break;
          if SymbolTable[I].Kind = kindNAMESPACE then
            break;

          if SymbolTable.IsConst(OwnerId, I) then
            CallBack(I, Host, pmk, Data);
        end;
      pmkType:
        for I:=OwnerId + 1 to SymbolTable.Card do
        begin
          if SymbolTable[I] = SR0 then
            break;
          if SymbolTable[I].Kind = kindNAMESPACE then
            break;

          if SymbolTable.IsType(OwnerId, I) then
            CallBack(I, Host, pmk, Data);
        end;
      pmkProcedure:
        for I:=OwnerId + 1 to SymbolTable.Card do
        begin
          if SymbolTable[I] = SR0 then
            break;
          if SymbolTable[I].Kind = kindNAMESPACE then
            break;

          if SymbolTable.IsProcedure(OwnerId, I) then
            CallBack(I, Host, pmk, Data);
        end;
      pmkFunction:
        for I:=OwnerId + 1 to SymbolTable.Card do
        begin
          if SymbolTable[I] = SR0 then
            break;
          if SymbolTable[I].Kind = kindNAMESPACE then
            break;

          if SymbolTable.IsFunction(OwnerId, I) then
            CallBack(I, Host, pmk, Data);
        end;
    end;
  end
  else if K = KindTYPE then
  begin
    case pmk of
      pmkField:
        for I:=OwnerId + 1 to SymbolTable.Card do
        begin
          if SymbolTable[I] = SR0 then
            break;
          if SymbolTable[I].Kind = kindNAMESPACE then
            break;

          if SymbolTable.IsTypeField(OwnerId, I) then
            CallBack(I, Host, pmk, Data);
        end;
      pmkProperty:
        for I:=OwnerId + 1 to SymbolTable.Card do
        begin
          if SymbolTable[I] = SR0 then
            break;
          if SymbolTable[I].Kind = kindNAMESPACE then
            break;

          if SymbolTable.IsProperty(OwnerId, I) then
            CallBack(I, Host, pmk, Data);
        end;
      pmkProcedure:
        for I:=OwnerId + 1 to SymbolTable.Card do
        begin
          if SymbolTable[I] = SR0 then
            break;
          if SymbolTable[I].Kind = kindNAMESPACE then
            break;

          if SymbolTable.IsProcedure(OwnerId, I) then
            CallBack(I, Host, pmk, Data);
        end;
      pmkFunction:
        for I:=OwnerId + 1 to SymbolTable.Card do
        begin
          if SymbolTable[I] = SR0 then
            break;
          if SymbolTable[I].Kind = kindNAMESPACE then
            break;

          if SymbolTable.IsFunction(OwnerId, I) then
            CallBack(I, Host, pmk, Data);
        end;
      pmkConstructor:
        for I:=OwnerId + 1 to SymbolTable.Card do
        begin
          if SymbolTable[I] = SR0 then
            break;
          if SymbolTable[I].Kind = kindNAMESPACE then
            break;

          if SymbolTable.IsConstructor(OwnerId, I) then
            CallBack(I, Host, pmk, Data);
        end;
      pmkDestructor:
        for I:=OwnerId + 1 to SymbolTable.Card do
        begin
          if SymbolTable[I] = SR0 then
            break;
          if SymbolTable[I].Kind = kindNAMESPACE then
            break;

          if SymbolTable.IsDestructor(OwnerId, I) then
            CallBack(I, Host, pmk, Data);
        end;
    end;
  end
  else if K = KindNAMESPACE then
  begin
    case pmk of
      pmkProcedure:
        for I:=OwnerId + 1 to SymbolTable.Card do
        begin
          if SymbolTable[I] = SR0 then
            break;
          if SymbolTable[I].Kind = kindNAMESPACE then
            break;

          if SymbolTable.IsProcedure(OwnerId, I) then
            CallBack(I, Host, pmk, Data);
        end;
      pmkFunction:
        for I:=OwnerId + 1 to SymbolTable.Card do
        begin
          if SymbolTable[I] = SR0 then
            break;
          if SymbolTable[I].Kind = kindNAMESPACE then
            break;

          if SymbolTable.IsFunction(OwnerId, I) then
            CallBack(I, Host, pmk, Data);
        end;
      pmkConst:
        for I:=OwnerId + 1 to SymbolTable.Card do
        begin
          if SymbolTable[I] = SR0 then
            break;
          if SymbolTable[I].Kind = kindNAMESPACE then
            break;

          if SymbolTable.IsConst(OwnerId, I) then
            CallBack(I, Host, pmk, Data);
        end;
      pmkVar:
        for I:=OwnerId + 1 to SymbolTable.Card do
        begin
          if SymbolTable[I] = SR0 then
            break;
          if SymbolTable[I].Kind = kindNAMESPACE then
            break;

          if SymbolTable.IsVar(OwnerId, I) then
            CallBack(I, Host, pmk, Data);
        end;
      pmkType:
        for I:=OwnerId + 1 to SymbolTable.Card do
        begin
          if SymbolTable[I] = SR0 then
            break;
          if SymbolTable[I].Kind = kindNAMESPACE then
            break;

          if SymbolTable.IsType(OwnerId, I) then
            CallBack(I, Host, pmk, Data);
        end;
    end;
  end;
end;

function TPaxCompilerExplorer.IsConst(LevelId, Id: Integer): Boolean;
begin
  result := TKernel(compiler.GetKernelPtr).SymbolTable.IsConst(LevelId, Id);
end;

function TPaxCompilerExplorer.IsVar(LevelId, Id: Integer): Boolean;
begin
  result := TKernel(compiler.GetKernelPtr).SymbolTable.IsVar(LevelId, Id);
end;

function TPaxCompilerExplorer.IsProcedure(LevelId, Id: Integer): Boolean;
begin
  result := TKernel(compiler.GetKernelPtr).SymbolTable.IsProcedure(LevelId, Id);
end;

function TPaxCompilerExplorer.IsFunction(LevelId, Id: Integer): Boolean;
begin
  result := TKernel(compiler.GetKernelPtr).SymbolTable.IsFunction(LevelId, Id);
end;

function TPaxCompilerExplorer.IsNamespace(LevelId, Id: Integer): Boolean;
begin
  result := TKernel(compiler.GetKernelPtr).SymbolTable.IsNamespace(LevelId, Id);
end;

function TPaxCompilerExplorer.IsType(LevelId, Id: Integer): Boolean;
begin
  result := TKernel(compiler.GetKernelPtr).SymbolTable.IsType(LevelId, Id);
end;

function TPaxCompilerExplorer.IsTypeField(TypeId, Id: Integer): Boolean;
begin
  result := TKernel(compiler.GetKernelPtr).SymbolTable.IsTypeField(TypeId, Id);
end;

function TPaxCompilerExplorer.IsProperty(TypeId, Id: Integer): Boolean;
begin
  result := TKernel(compiler.GetKernelPtr).SymbolTable.IsProperty(TypeId, Id);
end;

function TPaxCompilerExplorer.IsConstructor(TypeId, Id: Integer): Boolean;
begin
  result := TKernel(compiler.GetKernelPtr).SymbolTable.IsConstructor(TypeId, Id);
end;

function TPaxCompilerExplorer.IsDestructor(TypeId, Id: Integer): Boolean;
begin
  result := TKernel(compiler.GetKernelPtr).SymbolTable.IsDestructor(TypeId, Id);
end;

function TPaxCompilerExplorer.GetNamespaceId(Id: Integer): Integer;
var
  R: TSymbolRec;
  L: Integer;
begin
  L := TKernel(compiler.GetKernelPtr).SymbolTable[Id].Level;
  repeat
    if L = 0 then
    begin
      result := 0;
      Exit;
    end;

    R := TKernel(compiler.GetKernelPtr).SymbolTable[L];

    if R.Kind = kindNAMESPACE then
    begin
      result := R.Id;
      Exit;
    end;

    L := R.Level;

  until false;
end;

function TPaxCompilerExplorer.GetVisibility(Id: Integer): TClassVisibility;
begin
  result := TKernel(compiler.GetKernelPtr).SymbolTable[Id].Vis;
end;

function TPaxCompilerExplorer.GetReadId(PropId: Integer): Integer;
begin
  result := TKernel(compiler.GetKernelPtr).SymbolTable[PropId].ReadId;
end;

function TPaxCompilerExplorer.GetWriteId(PropId: Integer): Integer;
begin
  result := TKernel(compiler.GetKernelPtr).SymbolTable[PropId].WriteId;
end;

function TPaxCompilerExplorer.IsByRefParam(Id: Integer): Boolean;
var
  R: TSymbolRec;
begin
  R := TKernel(compiler.GetKernelPtr).SymbolTable[Id];
  result := R.Param and R.ByRef;
end;

function TPaxCompilerExplorer.IsConstParam(Id: Integer): Boolean;
var
  R: TSymbolRec;
begin
  R := TKernel(compiler.GetKernelPtr).SymbolTable[Id];
  result := R.Param and R.IsConst;
end;

function TPaxCompilerExplorer.IsMethod(Id: Integer): Boolean;
var
  L: Integer;
begin
  result := false;
  L := TKernel(compiler.GetKernelPtr).SymbolTable[Id].Level;
  if L = 0 then
    Exit;
  result := TKernel(compiler.GetKernelPtr).SymbolTable[L].Kind = KindTYPE;
end;

{
function TPaxCompilerExplorer.GetArrayDef(Id: Integer): String;
var
 TypeId, RangeTypeId, ElemTypeId: Integer;
begin
 TestArrayId(Id);
 TypeId := TKernel(compiler.GetKernelPtr).SymbolTable[Id].TerminalTypeId;
 with TKernel(compiler.GetKernelPtr).SymbolTable do
   begin
     GetArrayTypeInfo(TypeId, RangeTypeId, ElemTypeId);
     result := 'Array[ ' + inttostr( GetLowBoundRec(RangeTypeId).Value ) +
                    '..' + inttostr( GetHighBoundRec(RangeTypeId).Value ) +
               ' ]  of ' + Records[ElemTypeId].Name;
 end;
end;
}

end.
