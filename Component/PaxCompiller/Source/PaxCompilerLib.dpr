////////////////////////////////////////////////////////////////////////////
// PaxCompiler
// Author: Alexander Baranovsky (ab@cable.netlux.org)
// ========================================================================
// Copyright (c) Alexander Baranovsky, 2006. All rights reserved.
// Code Version: 1.5
// ========================================================================
// Unit: PaxCompilerLib.dpr
// ========================================================================
////////////////////////////////////////////////////////////////////////////

{$I PaxCompiler.def}

library PaxCompilerDll;
uses
{$IFNDEF LINUX}
   ShareMem,
{$ENDIF}
  PAXCOMP_BASESYMBOL_TABLE,
  PaxRegister,
  PaxCompiler, PaxProgram;

/////////////////////// PaxCompiler ////////////////////////////////////////////

function PaxCompiler_Create: Integer; stdcall;
var
  C: TPaxCompiler;
begin
  C := TPaxCompiler.Create(nil);
  result := Integer(C);
  DllDefined := true;
end;

procedure PaxCompiler_Destroy(HCompiler: Integer); stdcall;
begin
  TPaxCompiler(HCompiler).Free;
end;

procedure PaxCompiler_Reset(HCompiler: Integer); stdcall;
begin
  TPaxCompiler(HCompiler).Reset;
end;

procedure PaxCompiler_AddModule(HCompiler: Integer; Name, LanguageName: PChar); stdcall;
begin
  TPaxCompiler(HCompiler).AddModule(Name, LanguageName);
end;

procedure PaxCompiler_AddCode(HCompiler: Integer; ModuleName, Text: PChar); stdcall;
begin
  TPaxCompiler(HCompiler).AddCode(ModuleName, Text);
end;

procedure PaxCompiler_AddCodeFromFile(HCompiler: Integer; ModuleName, FileName: PChar); stdcall;
begin
  TPaxCompiler(HCompiler).AddCodeFromFile(ModuleName, FileName);
end;

procedure PaxCompiler_RegisterLanguage(HCompiler, HLanguage: Integer); stdcall;
begin
  TPaxCompiler(HCompiler).RegisterLanguage(TPaxCompilerLanguage(HLanguage));
end;

function PaxCompiler_RegisterNamespace(HCompiler, LevelId: Integer; NamespaceName: PChar): Integer; stdcall;
begin
  if HCompiler = 0 then
    result := RegisterNamespace(LevelId, NamespaceName)
  else
    result := TPaxCompiler(HCompiler).RegisterNamespace(LevelId, NamespaceName);
end;

function PaxCompiler_RegisterRecordType(HCompiler, LevelId: Integer; TypeName: PChar): Integer; stdcall;
begin
  if HCompiler = 0 then
    result := RegisterRecordType(LevelId, TypeName)
  else
    result := TPaxCompiler(HCompiler).RegisterRecordType(LevelId, TypeName);
end;

function PaxCompiler_RegisterRecordTypeField(HCompiler, RecordTypeId: Integer; FieldName: PChar; FieldTypeID: Integer): Integer; stdcall;
begin
  if HCompiler = 0 then
    result := RegisterRecordTypeField(RecordTypeId, FieldName, FieldTypeId)
  else
    result := TPaxCompiler(HCompiler).RegisterRecordTypeField(RecordTypeId, FieldName, FieldTypeId);
end;

function PaxCompiler_RegisterSubrangeType(HCompiler, LevelId: Integer; TypeName: PChar; TypeBaseId: Integer;
                                          B1, B2: Integer): Integer; stdcall;
begin
  if HCompiler = 0 then
    result := RegisterSubrangeType(LevelId, TypeName, TypeBaseId, B1, B2)
  else
    result := TPaxCompiler(HCompiler).RegisterSubrangeType(LevelId, TypeName, TypeBaseId, B1, B2);
end;

function PaxCompiler_RegisterArrayType(HCompiler, LevelId: Integer; TypeName: PChar; RangeTypeId, ElemTypeId: Integer): Integer; stdcall;
begin
  if HCompiler = 0 then
    result := RegisterArrayType(LevelId, TypeName, RangeTypeId, ElemTypeId)
  else
    result := TPaxCompiler(HCompiler).RegisterArrayType(LevelId, TypeName, RangeTypeId, ElemTypeId);
end;

function PaxCompiler_RegisterPointerType(HCompiler, LevelId: Integer; TypeName: PChar; OriginTypeId: Integer): Integer; stdcall;
begin
  if HCompiler = 0 then
    result := RegisterPointerType(LevelId, TypeName, OriginTypeId)
  else
    result := TPaxCompiler(HCompiler).RegisterPointerType(LevelId, TypeName, OriginTypeId);
end;

function PaxCompiler_RegisterSetType(HCompiler, LevelId: Integer; TypeName: PChar; OriginTypeId: Integer): Integer; stdcall;
begin
  if HCompiler = 0 then
    result := RegisterSetType(LevelId, TypeName, OriginTypeId)
  else
    result := TPaxCompiler(HCompiler).RegisterSetType(LevelId, TypeName, OriginTypeId);
end;

function PaxCompiler_RegisterProceduralType(HCompiler, LevelId: Integer; TypeName: PChar; SubId: Integer): Integer; stdcall;
begin
  if HCompiler = 0 then
    result := RegisterProceduralType(LevelId, TYpeName, SubId)
  else
    result := TPaxCompiler(HCompiler).RegisterProceduralType(LevelId, TYpeName, SubId);
end;

function PaxCompiler_RegisterVariable(HCompiler, LevelId: Integer; Name: PChar; TypeId: Integer): Integer; stdcall;
begin
  if HCompiler = 0 then
    result := RegisterVariable(LevelId, Name, TypeId, nil)
  else
    result := TPaxCompiler(HCompiler).RegisterVariable(LevelId, Name, TypeId);
end;

function PaxCompiler_RegisterRoutine(HCompiler, LevelId: Integer; Name: PChar;
               ResultTypeID: Integer): Integer; stdcall;
begin
  if HCompiler = 0 then
    result := RegisterRoutine(LevelId, Name, ResultTypeId, nil, _ccSTDCALL)
  else
    result := TPaxCompiler(HCompiler).RegisterRoutine(LevelId, Name, ResultTypeId, _ccSTDCALL);
end;

function PaxCompiler_RegisterRoutineEx(HCompiler, LevelId: Integer; Name: PChar;
               ResultTypeID: Integer; CallConvention: Integer): Integer; stdcall;
begin
  if HCompiler = 0 then
    result := RegisterRoutine(LevelId, Name, ResultTypeId, nil, CallConvention)
  else
    result := TPaxCompiler(HCompiler).RegisterRoutine(LevelId, Name, ResultTypeId, CallConvention);
end;

function PaxCompiler_RegisterParameter(HCompiler, HSub: Integer; ParamTypeID: Integer;
                                       ByRef: Boolean): Integer; stdcall;
begin
  if HCompiler = 0 then
    result := RegisterParameter(HSub, ParamTypeId, _Unassigned, ByRef)
  else
    result := TPaxCompiler(HCompiler).RegisterParameter(HSub, ParamTypeId, _Unassigned, ByRef);
end;

function PaxCompiler_RegisterClassType(HCompiler, LevelId: Integer; C: TClass): Integer; stdcall;
begin
  if HCompiler = 0 then
    result := RegisterClassType(LevelId, C)
  else
    result := TPaxCompiler(HCompiler).RegisterClassType(LevelId, C);
end;

function PaxCompiler_RegisterHeader(HCompiler, LevelId: Integer; const Header: PChar; Address: Pointer): Integer; stdcall;
begin
  if HCompiler = 0 then
    result := RegisterHeader(LevelId, Header, Address)
  else
    result := TPaxCompiler(HCompiler).RegisterHeader(LevelId, Header, Address)
end;

function PaxCompiler_GetHandle(HCompiler, LevelId: Integer; Name: PChar; Upcase: Boolean): Integer; stdcall;
begin
  result := TPaxCompiler(HCompiler).GetHandle(LevelId, Name, Upcase);
end;

function PaxCompiler_Compile(HCompiler, HProgram: Integer): boolean; stdcall;
begin
  result := TPaxCompiler(HCompiler).Compile(TPaxProgram(HProgram));
end;

function PaxCompiler_GetErrorCount(HCompiler: Integer): Integer; stdcall;
begin
  result := TPaxCompiler(HCompiler).ErrorCount;
end;

function PaxCompiler_GetErrorMessage(HCompiler, I: Integer): PChar; stdcall;
begin
  result := PChar(TPaxCompiler(HCompiler).ErrorMessage[I]);
end;

function PaxCompiler_GetErrorModuleName(HCompiler, I: Integer): PChar; stdcall;
begin
  result := PChar(TPaxCompiler(HCompiler).ErrorModuleName[I]);
end;

function PaxCompiler_GetErrorLine(HCompiler, I: Integer): PChar; stdcall;
begin
  result := PChar(TPaxCompiler(HCompiler).ErrorLine[I]);
end;

function PaxCompiler_GetErrorLineNumber(HCompiler, I: Integer): Integer; stdcall;
begin
  result := TPaxCompiler(HCompiler).ErrorLineNumber[I];
end;

/////////////////////// PaxProgram /////////////////////////////////////////////

function PaxProgram_Create: Integer; stdcall;
begin
  result := Integer(TPaxProgram.Create(nil));
end;

procedure PaxProgram_Destroy(HProgram: Integer); stdcall;
begin
  TPaxProgram(HProgram).Free;
end;

procedure PaxProgram_Run(HProgram: Integer); stdcall;
begin
  TPaxProgram(HProgram).Run;
end;

procedure PaxProgram_SaveToFile(HProgram: Integer; Path: PChar); stdcall;
begin
  TPaxProgram(HProgram).SaveToFile(Path);
end;

procedure PaxProgram_LoadFromFile(HProgram: Integer; Path: PChar); stdcall;
begin
  TPaxProgram(HProgram).LoadFromFile(Path);
end;

function PaxProgram_GetAddress(HProgram: Integer; Handle: Integer): Pointer; stdcall;
begin
  result := TPaxProgram(HProgram).GetAddress(Handle);
end;

procedure PaxProgram_SetAddress(HProgram, Handle: Integer; P: Pointer); stdcall;
begin
  TPaxProgram(HProgram).SetAddress(Handle, P);
end;

function PaxProgram_GetDataPtr(HProgram: Integer): Pointer; stdcall;
begin
  result := TPaxProgram(HProgram).DataPtr;
end;

function PaxProgram_GetCodePtr(HProgram: Integer): Pointer; stdcall;
begin
  result := TPaxProgram(HProgram).CodePtr;
end;

/////////////////////// PaxPascalLanguage //////////////////////////////////////

function PaxPascalLanguage_Create: Integer; stdcall;
var
  L: TPaxPascalLanguage;
begin
  L := TPaxPascalLanguage.Create(nil);
  result := Integer(L);
end;

procedure PaxPascalLanguage_Destroy(HPaxPascalLanguage: Integer); stdcall;
begin
  TPaxPascalLanguage(HPaxPascalLanguage).Free;
end;

procedure PaxPascalLanguage_SetCallConv(HPaxPascalLanguage: Integer; cc: Integer); stdcall;
begin
  TPaxPascalLanguage(HPaxPascalLanguage).SetCallConv(cc);
end;

exports ////////////////////////////////////////////////////////////////////////

  PaxCompiler_Create,
  PaxCompiler_Destroy,
  PaxCompiler_Reset,
  PaxCompiler_AddModule,
  PaxCompiler_AddCode,
  PaxCompiler_AddCodeFromFile,
  PaxCompiler_RegisterLanguage,
  PaxCompiler_RegisterNamespace,
  PaxCompiler_RegisterRecordType,
  PaxCompiler_RegisterRecordTypeField,
  PaxCompiler_RegisterSubrangeType,
  PaxCompiler_RegisterArrayType,
  PaxCompiler_RegisterPointerType,
  PaxCompiler_RegisterSetType,
  PaxCompiler_RegisterProceduralType,
  PaxCompiler_RegisterVariable,
  PaxCompiler_RegisterRoutine,
  PaxCompiler_RegisterRoutineEx,
  PaxCompiler_RegisterParameter,
  PaxCompiler_RegisterClassType,
  PaxCompiler_RegisterHeader,
  PaxCompiler_GetHandle,
  PaxCompiler_Compile,
  PaxCompiler_GetErrorCount,
  PaxCompiler_GetErrorMessage,
  PaxCompiler_GetErrorModuleName,
  PaxCompiler_GetErrorLine,
  PaxCompiler_GetErrorLineNumber,

  PaxProgram_Create,
  PaxProgram_Destroy,
  PaxProgram_Run,
  PaxProgram_SaveToFile,
  PaxProgram_LoadFromFile,
  PaxProgram_GetAddress,
  PaxProgram_SetAddress,
  PaxProgram_GetDataPtr,
  PaxProgram_GetCodePtr,

  PaxPascalLanguage_Create,
  PaxPascalLanguage_Destroy,
  PaxPascalLanguage_SetCallConv;
begin
end.
