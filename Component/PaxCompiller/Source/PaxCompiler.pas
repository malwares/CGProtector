////////////////////////////////////////////////////////////////////////////
// PaxCompiler
// Site: http://www.paxcompiler.com
// Author: Alexander Baranovsky (paxscript@gmail.com)
// ========================================================================
// Copyright (c) Alexander Baranovsky, 2006-2008. All rights reserved.
// Code Version: 2.4
// ========================================================================
// Unit: PaxCompiler.pas
// ========================================================================
////////////////////////////////////////////////////////////////////////////

{$I PaxCompiler.def}
unit PaxCompiler;

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
  PAXCOMP_KERNEL,
  PAXCOMP_BASESYMBOL_TABLE,
  PAXCOMP_PARSER,
  PAXCOMP_PASCAL_PARSER,
  PAXCOMP_OLE,
  PAXCOMP_PE,
  PAXCOMP_PROG,
  PAXCOMP_MODULE,
  PAXCOMP_TYPEINFO,
  PaxRegister,
  PaxProgram;
type
  TPaxCompiler = class;
  TPaxCompilerLanguage = class;

  TPaxCompilerNotifyEvent = procedure (Sender: TPaxCompiler) of object;
  TPaxCompilerUsedUnitEvent = function (Sender: TPaxCompiler; const UnitName: String;
                              var SourceCode: String): Boolean of object;
  TPaxCompilerSavePCUEvent = function (Sender: TPaxCompiler; const UnitName: String
                              ): TStream of object;
  TPaxCompilerLoadPCUEvent = function (Sender: TPaxCompiler; const UnitName: String
                              ): TStream of object;

  TPaxCompilerDirectiveEvent = procedure (Sender: TPaxCompiler;
                          const Directive: String; var ok: Boolean) of object;

  TPaxCompilerIncludeEvent = procedure (Sender: TObject; const FileName: String;
                                var Text: String) of object;

  TPaxCompiler = class(TComponent)
  private
    kernel: TKernel;
    function GetErrorCount: Integer;
    function GetErrorMessage(I: Integer): String;
    function GetErrorModuleName(I: Integer): String;
    function GetErrorLine(I: Integer): String;
    function GetErrorLineNumber(I: Integer): Integer;
    function GetErrorLinePos(I: Integer): Integer;

    function GetOnCompilerProgress: TPaxCompilerNotifyEvent;
    procedure SetOnCompilerProgress(value: TPaxCompilerNotifyEvent);

    function GetOnUsedUnit: TPaxCompilerUsedUnitEvent;
    procedure SetOnUsedUnit(value: TPaxCompilerUsedUnitEvent);

    function GetOnSavePCU: TPaxCompilerSavePCUEvent;
    procedure SetOnSavePCU(value: TPaxCompilerSavePCUEvent);

    function GetOnLoadPCU: TPaxCompilerLoadPCUEvent;
    procedure SetOnLoadPCU(value: TPaxCompilerLoadPCUEvent);

    function GetOnInclude: TPaxCompilerIncludeEvent;
    procedure SetOnInclude(value: TPaxCompilerIncludeEvent);

    function GetOnDefineDirective: TPaxCompilerDirectiveEvent;
    procedure SetOnDefineDirective(value: TPaxCompilerDirectiveEvent);

    function GetOnUndefineDirective: TPaxCompilerDirectiveEvent;
    procedure SetOnUndefineDirective(value: TPaxCompilerDirectiveEvent);

    function GetOnUnknownDirective: TPaxCompilerDirectiveEvent;
    procedure SetOnUnknownDirective(value: TPaxCompilerDirectiveEvent);

    function GetDebugMode: Boolean;
    procedure SetDebugMode(value: Boolean);

    function GetCondDirectiveList: TStringList;

    function GetSourceModule(const ModuleName: String): TStringList;
    function GetCurrLineNumber: Integer;
    function GetCurrModuleNumber: Integer;
    function GetCurrModuleName: String;

    function GetAlignment: Integer;
    procedure SetAlignment(value: Integer);

    function GetCurrLanguage: String;
    procedure SetCurrLanguage(const value: String);

  protected
  public
    constructor Create(AOwner: TComponent); override;
    destructor Destroy; override;
    procedure Reset;
    procedure ResetCompilation;
    procedure AddModule(const ModuleName, LanguageName: String);
    procedure AddCode(const ModuleName, Text: String);
    procedure AddCodeFromFile(const ModuleName, FileName: String);
    procedure RegisterLanguage(L: TPaxCompilerLanguage);
    function RegisterNamespace(LevelId: Integer;
                               const NamespaceName: String): Integer;
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
    function RegisterClassType(LevelId: Integer;
                               const TypeName: String; AncestorId: Integer): Integer; overload;
    function RegisterClassType(LevelId: Integer;
                               C: TClass): Integer; overload;
    function RegisterClassReferenceType(LevelId: Integer;
                                const TypeName: String; OriginClassId: Integer): Integer;
    function RegisterClassTypeField(TypeId: Integer; const FieldName: String;
                                    FieldTypeID: Integer; FieldShift: Integer = -1): Integer;
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
                                    FieldTypeID: Integer; FieldShift: Integer = -1): Integer;
    function RegisterVariantRecordTypeField(TypeId: Integer; const FieldName: String;
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
                               OriginTypeId: Integer): Integer;
    function RegisterVariable(LevelId: Integer;
                              const VarName: String; TypeId: Integer;
                              Address: Pointer = nil): Integer; overload;
    function RegisterVariable(LevelId: Integer;
                       const Declaration: String; Address: Pointer): Integer; overload;
    function RegisterObject(LevelId: Integer;
                            const ObjectName: String;
                            TypeId: Integer;
                            Address: Pointer = nil): Integer;
    function RegisterConstant(LevelId: Integer;
                              const ConstName: String;
                              typeID: Integer;
                              const Value: Variant): Integer; overload;
    function RegisterConstant(LevelId: Integer;
                              const ConstName: String;
                              const Value: Variant): Integer; overload;
    function RegisterConstant(LevelId: Integer;
                              const Declaration: String): Integer; overload;
    function RegisterRoutine(LevelId: Integer;
                             const RoutineName: String; ResultTypeID: Integer;
                             CallConvention: Integer;
                             Address: Pointer = nil): Integer;
    function RegisterMethod(LevelId: Integer;
                            const RoutineName: String; ResultTypeID: Integer;
                            CallConvention: Integer;
                            Address: Pointer = nil;
                            IsShared: Boolean = false): Integer;
    function RegisterConstructor(LevelId: Integer;
                                 const SubName: String;
                                 Address: Pointer = nil): Integer;
    function RegisterParameter(HSub: Integer; ParamTypeID: Integer;
                               const DefaultValue: Variant;
                               ByRef: Boolean = false): Integer;
    function RegisterHeader(LevelId: Integer; const Header: String;
                            Address: Pointer = nil;
                            MethodIndex: Integer = 0): Integer;
    function RegisterTypeDeclaration(LevelId: Integer;
                            const Declaration: String): Integer;
    function RegisterSomeType(LevelId: Integer;
                           const TypeName: String): Integer;
    function GetHandle(LevelId: Integer; const MemberName: String; Upcase: Boolean): Integer;
    function Compile(PaxProgram: TPaxProgram;
                     BuildAll: Boolean = false;
                     BuildWithRuntimePackages: Boolean = false): boolean; overload;
    function Compile: boolean; overload;
    function Parse: boolean;
    function CompileExpression(const Expression: String;
                               PaxProgram: TPaxProgram;
                               const LangName: String = ''): Boolean;
    function CodeCompletion(const ModuleName: String;
       X, Y: Integer; L: TStrings; PaxLang: TPaxCompilerLanguage = nil): Boolean;

// added in v 1.5
    function GetKernelPtr: Pointer;
//
    function GetUndeclaredTypes: TStringList;

    property ErrorCount: Integer read GetErrorCount;
    property ErrorMessage[I: Integer]: String read GetErrorMessage;
    property ErrorModuleName[I: Integer]: String read GetErrorModuleName;
    property ErrorLine[I: Integer]: String read GetErrorLine;
    property ErrorLineNumber[I: Integer]: Integer read GetErrorLineNumber;
    property ErrorLinePos[I: Integer]: Integer read GetErrorLinePos;
    property Modules[const ModuleName: String]: TStringList read GetSourceModule;
    property CurrLineNumber: Integer read GetCurrLineNumber;
    property CurrModuleNumber: Integer read GetCurrModuleNumber;
    property CurrModuleName: String read GetCurrModuleName;
    property CondDirectiveList: TStringList read GetCondDirectiveList;
    property CurrLanguage: String read GetCurrLanguage write SetCurrLanguage;
  published
    property Alignment: Integer read GetAlignment write SetAlignment;
    property OnCompilerProgress: TPaxCompilerNotifyEvent
                                 read GetOnCompilerProgress write SetOnCompilerProgress;
    property OnUsedUnit: TPaxCompilerUsedUnitEvent
                         read GetOnUsedUnit write SetOnUsedUnit;
    property OnSavePCU: TPaxCompilerSavePCUEvent
                         read GetOnSavePCU write SetOnSavePCU;
    property OnLoadPCU: TPaxCompilerLoadPCUEvent
                         read GetOnLoadPCU write SetOnLoadPCU;
    property OnInclude: TPaxCompilerIncludeEvent
                         read GetOnInclude write SetOnInclude;
    property OnDefineDirective: TPaxCompilerDirectiveEvent
                                read GetOnDefineDirective write SetOnDefineDirective;
    property OnUndefineDirective: TPaxCompilerDirectiveEvent
                                read GetOnUndefineDirective write SetOnUndefineDirective;
    property OnUnknownDirective: TPaxCompilerDirectiveEvent
                                read GetOnUnknownDirective write SetOnUnknownDirective;
    property DebugMode: Boolean read GetDebugMode write SetDebugMode;
  end;

  TPaxCompilerLanguage = class(TComponent)
  protected
    function GetLanguageName: String; virtual; abstract;
    function GetParser: TBaseParser; virtual; abstract;
  public
    procedure SetCallConv(CallConv: Integer); virtual; abstract;
    property LanguageName: String read GetLanguageName;
  end;

  TPaxPascalLanguage = class(TPaxCompilerLanguage)
  private
    P: TPascalParser;
    function GetCompleteBooleanEval: Boolean;
    procedure SetCompleteBooleanEval(value: Boolean);
    function GetUnitLookup: Boolean;
    procedure SetUnitLookup(value: Boolean);
    procedure SetInterfaceOnly(value: Boolean);
    function GetInterfaceOnly: Boolean;
    function GetPrintKeyword: String;
    function GetPrintlnKeyword: String;
    procedure SetPrintKeyword(const value: String);
    procedure SetPrintlnKeyword(const value: String);
  protected
    function GetParser: TBaseParser; override;
    function GetLanguageName: String; override;
  public
    constructor Create(AOwner: TComponent); override;
    destructor Destroy; override;
    procedure SetCallConv(CallConv: Integer); override;
    property InterfaceOnly: Boolean read GetInterfaceOnly write
                                         SetInterfaceOnly;
  published
    property CompleteBooleanEval: Boolean read GetCompleteBooleanEval write SetCompleteBooleanEval;
    property UnitLookup: Boolean read GetUnitLookup write SetUnitLookup;
    property PrintKeyword: String read GetPrintKeyword write SetPrintKeyword;
    property PrintlnKeyword: String read GetPrintlnKeyword write SetPrintlnKeyword;
  end;

procedure CreateExeFile(const ExeName: String;
                        PaxProgram: TPaxProgram;
                        const DllName: String;
                        const ProcName: String);

procedure Register;
procedure SetDump;

implementation

uses
  PAXCOMP_EMIT,
  PAXCOMP_STDLIB,
  PAXCOMP_SYMBOL_PROGRAM;

//--------------------TPaxCompiler----------------------------------------------

constructor TPaxCompiler.Create(AOwner: TComponent);
begin
  inherited;
  kernel := TKernel.Create(Self);
end;

destructor TPaxCompiler.Destroy;
begin
  kernel.Free;
  inherited;
end;

procedure TPaxCompiler.Reset;
begin
  kernel.Reset;
end;

procedure TPaxCompiler.ResetCompilation;
begin
  kernel.ResetCompilation;
end;

procedure TPaxCompiler.AddModule(const ModuleName, LanguageName: String);
begin
  kernel.AddModule(ModuleName, LanguageName);
end;

procedure TPaxCompiler.AddCode(const ModuleName, Text: String);
begin
  kernel.AddCode(ModuleName, Text);
end;

procedure TPaxCompiler.AddCodeFromFile(const ModuleName, FileName: String);
begin
  kernel.AddCodeFromFile(ModuleName, FileName);
end;

function TPaxCompiler.CompileExpression(const Expression: String;
                                        PaxProgram: TPaxProgram;
                                        const LangName: String = ''): Boolean;
var
  Emitter: TEmitter;
  SymbolProgram: TSymbolProg;
begin
  result := false;
  PaxProgram.GetProgPtr.Reset;

  kernel.ClassFactory := PaxProgram.GetProgPtr.ProgClassFactory;
  kernel.TypeInfoList := PaxProgram.GetProgPtr.ProgTypeInfoList;

  kernel.ParseExpression(Expression, LangName);
  if kernel.HasError then Exit;
  kernel.Link;
  if kernel.HasError then Exit;

  PaxProgram.GetProgPtr.UseMapping := true;
  kernel.code.CreateMapping(PaxProgram.GetProgPtr.HostMapTable, true,
    PaxProgram.GetProgPtr.HostMapTable, nil);

  if kernel.SignCompression then
  begin
    kernel.SymbolTable.CompressHostClassList(PaxProgram.GetProgPtr.HostMapTable);
    kernel.SymbolTable.CreateOffsets(0, 0);
  end;

  Emitter := TEmitter.Create;
  SymbolProgram := Emitter.CreateSymbolProgram(kernel);
  try
    PaxProgram.GetProgPtr.OffsetList.Free;
    PaxProgram.GetProgPtr.OffsetList := kernel.OffsetList.Clone;

    kernel.code.CreateMapping(PaxProgram.GetProgPtr.ScriptMapTable, false,
        PaxProgram.GetProgPtr.HostMapTable, PaxProgram.GetProgPtr.ScriptMapTable);
    PaxProgram.GetProgPtr.CreateMapOffsets;

    SymbolProgram.CreateProgram(PaxProgram.GetProgPtr);
    if kernel.IsConsoleApp then
      PaxProgram.Console := kernel.IsConsoleApp;

    PaxProgram.GetProgPtr.SetupInterfaces;
    if kernel.HasError then Exit;
  finally
    Emitter.Free;
    SymbolProgram.Free;
  end;

  result := true;
end;

function TPaxCompiler.Compile(PaxProgram: TPaxProgram;
                              BuildAll: Boolean = false;
                              BuildWithRuntimePackages: Boolean = false): boolean;
var
  Emitter: TEmitter;
  SymbolProgram: TSymbolProg;
begin
  result := false;

  PaxProgram.GetProgPtr.Reset;

  if BuildWithRuntimePackages then
    BuildAll := true;

  kernel.ClassFactory := PaxProgram.GetProgPtr.ProgClassFactory;
  kernel.TypeInfoList := PaxProgram.GetProgPtr.ProgTypeInfoList;
  kernel.BuildAll := BuildAll;
  kernel.BuildWithRuntimePackages := BuildWithRuntimePackages;

  try

    kernel.Parse;
    if kernel.HasError then Exit;
    kernel.Link;
    if kernel.HasError then Exit;

    if kernel.Canceled then
    begin
      result := true;
      Exit;
    end;

    PaxProgram.GetProgPtr.UseMapping := true;
    kernel.code.CreateMapping(PaxProgram.GetProgPtr.HostMapTable, true,
      PaxProgram.GetProgPtr.HostMapTable, nil);

    if kernel.SignCompression then
    begin
      kernel.SymbolTable.CompressHostClassList(PaxProgram.GetProgPtr.HostMapTable);
      kernel.SymbolTable.CreateOffsets(0, 0);
    end;

    Emitter := TEmitter.Create;
    SymbolProgram := Emitter.CreateSymbolProgram(kernel);
    try
      PaxProgram.GetProgPtr.OffsetList.Free;
      PaxProgram.GetProgPtr.OffsetList := kernel.OffsetList.Clone;

      kernel.code.CreateMapping(PaxProgram.GetProgPtr.ScriptMapTable, false,
              PaxProgram.GetProgPtr.HostMapTable, PaxProgram.GetProgPtr.ScriptMapTable);

      PaxProgram.GetProgPtr.CreateMapOffsets;

      SymbolProgram.CreateProgram(PaxProgram.GetProgPtr);
      if kernel.IsConsoleApp then
        PaxProgram.Console := kernel.IsConsoleApp;

      PaxProgram.GetProgPtr.SetupInterfaces;
      if kernel.HasError then Exit;

      if not kernel.BuildWithRuntimePackages then
        PaxProgram.GetProgPtr.ProgList.LoadFromStreamList(kernel.PCUStreamList,
        PaxProgram.GetProgPtr);

    finally
      Emitter.Free;
      SymbolProgram.Free;
    end;

  finally
    kernel.BuildAll := false;
    kernel.BuildWithRuntimePackages := false;
  end;

  result := true;
end;

function TPaxCompiler.Compile: boolean;
var
  ClassFactory: TPaxClassFactory;
  TypeInfoList: TPaxTypeInfoList;
begin
  ClassFactory := TPaxClassFactory.Create;
  TypeInfoList := TPaxTypeInfoList.Create;
  try
    kernel.ClassFactory := ClassFactory;
    kernel.TypeInfoList := TypeInfoList;

    result := false;
    kernel.Parse;
    if kernel.HasError then Exit;
    kernel.Link;
    if kernel.HasError then Exit;
    result := true;

  finally
    ClassFactory.Free;
    TypeInfoList.Free;
  end;
end;

function TPaxCompiler.Parse: boolean;
var
  ClassFactory: TPaxClassFactory;
  TypeInfoList: TPaxTypeInfoList;
begin
  ClassFactory := TPaxClassFactory.Create;
  TypeInfoList := TPaxTypeInfoList.Create;
  try
    kernel.ClassFactory := ClassFactory;
    kernel.TypeInfoList := TypeInfoList;

    result := false;
    kernel.Parse;
    if kernel.HasError then Exit;

    kernel.InterfaceOnly := true;

    kernel.Link;
    result := not kernel.HasError;


  finally
    ClassFactory.Free;
    TypeInfoList.Free;
  end;
end;

function TPaxCompiler.CodeCompletion(const ModuleName: String;
      X, Y: Integer; L: TStrings; PaxLang: TPaxCompilerLanguage = nil): Boolean;

procedure RestoreFieldType(N: Integer);
var
  OwnerId, Id, TypeId, PatternId: Integer;
  S: String;
begin
  with kernel do
  if Code[N - 1].Op = OP_FIELD then
    if Code[N - 1].Res = Code[N].Arg1 then
    begin
      OwnerId := Code[N - 1].Arg1;
      TypeId := SymbolTable[OwnerId].TypeId;

      if TypeId = 0 then
        RestoreFieldType(N - 1);

      TypeId := SymbolTable[OwnerId].TypeId;

      if TypeId = 0 then
        Exit;

      if SymbolTable[TypeId].Kind <> kindTYPE then
        Exit;

      Id := Code[N].Arg1;
      S := SymbolTable[Id].Name;
      PatternId := SymbolTable.LookUp(S, TypeId, Code.GetUpcase(N));
      if PatternId > 0 then
         SymbolTable[Id].TypeId := SymbolTable[PatternId].TypeId;
    end;
end;

var
  NN, Op, Id: Integer;
  ClassFactory: TPaxClassFactory;
  TypeInfoList: TPaxTypeInfoList;
begin
  result := false;
  ClassFactory := TPaxClassFactory.Create;
  TypeInfoList := TPaxTypeInfoList.Create;

  try
    kernel.ClassFactory := ClassFactory;
    kernel.TypeInfoList := TypeInfoList;

    kernel.Parse(true, ModuleName, X, Y);
    if kernel.HasError then Exit;
    if kernel.Code.Card = 0 then Exit;
    kernel.Link;

  finally
    ClassFactory.Free;
    TypeInfoList.Free;
  end;

  kernel.Code.LocateDummyName(NN);
  if NN > 0 then
  begin
    Op := kernel.Code[NN].Op;
    Id := kernel.Code[NN].Arg1;
    if Op = OP_FIELD then
    begin
      if kernel.SymbolTable[Id].TypeId = 0 then
        RestoreFieldType(NN);

      if PaxLang = nil then
        kernel.SymbolTable.ExtractMembers(Id, L)
      else if PaxLang is TPaxPascalLanguage then
        kernel.SymbolTable.ExtractMembers(Id, L)
      else
        kernel.SymbolTable.ExtractMembers(Id, L, lngBasic);
      kernel.Errors.Reset;
    end
    else if (Op = OP_CALL) or (Op = OP_BEGIN_CALL) then
    begin
      if not (kernel.SymbolTable[Id].Kind in KindSUBS) then
        Exit;

      if kernel.CompletionTarget <> '' then
      begin
        if StrEql(kernel.CompletionTarget, 'New') or
           StrEql(kernel.CompletionTarget, 'Dispose') then
           begin
             L.Add('X: Pointer');
             kernel.Errors.Reset;
           end;
      end
      else
      begin
        kernel.SymbolTable.ExtractParametersEx(Id, L, true);
        kernel.Errors.Reset;
      end;
    end
    else if (Op = OP_PRINT) or (Op = OP_PRINT_EX) then
    begin
      L.Add('P1;[...,PN]');
      kernel.Errors.Reset;
    end
    else if Op = OP_ABS then
    begin
      L.Add('X: Real');
      kernel.Errors.Reset;
    end
    else if (Op = OP_INC) or (Op = OP_DEC) then
    begin
      L.Add('var X: Ordinal; [N: Integer]');
      kernel.Errors.Reset;
    end
    else if (Op = OP_PRED) or
            (Op = OP_SUCC) or
            (Op = OP_ORD) then
    begin
      L.Add('X: Ordinal');
      kernel.Errors.Reset;
    end
    else if Op = OP_CHR then
    begin
      L.Add('X: Byte');
      kernel.Errors.Reset;
    end
    else if Op = OP_STR then
    begin
      L.Add('const X[: Width[:Decimals]]; var S: String');
      kernel.Errors.Reset;
    end
    else if (Op = OP_SIZEOF) or
            (Op = OP_ASSIGNED) or
            (Op = OP_LOW) or
            (Op = OP_HIGH) then
    begin
      L.Add('var X');
      kernel.Errors.Reset;
    end
    else // error
      Exit;
  end;

  result := not kernel.HasError;
end;

procedure TPaxCompiler.RegisterLanguage(L: TPaxCompilerLanguage);
begin
  kernel.RegisterParser(L.GetParser);
end;

function TPaxCompiler.RegisterNamespace(LevelId: Integer;
                                        const NamespaceName: String): Integer;
begin
  result := kernel.SymbolTable.RegisterNamespace(LevelId, NamespaceName);
end;

function TPaxCompiler.RegisterInterfaceType(LevelId: Integer;
                                            const TypeName: String;
                                            const GUID: TGUID): Integer;
begin
  result := kernel.SymbolTable.RegisterInterfaceType(LevelId, TypeName, GUID);
end;

function TPaxCompiler.RegisterInterfaceType(LevelId: Integer;
                                            const TypeName: String;
                                            const GUID: TGUID;
                                            const ParentName: String;
                                            const ParentGUID: TGUID): Integer; 
begin
  result := kernel.SymbolTable.RegisterInterfaceType(LevelId, TypeName, GUID);
  kernel.SymbolTable.RegisterSupportedInterface(result, ParentName, ParentGUID);
end;

procedure TPaxCompiler.RegisterSupportedInterface(TypeId: Integer;
                                                  const SupportedInterfaceName: String;
                                                  const GUID: TGUID);
begin
  kernel.SymbolTable.RegisterSupportedInterface(TypeId, SupportedInterfaceName, GUID);
end;

function TPaxCompiler.RegisterClassType(LevelId: Integer;
                           const TypeName: String; AncestorId: Integer): Integer;
begin
  result := kernel.SymbolTable.RegisterClassType(LevelId, TypeName, AncestorId);
end;

function TPaxCompiler.RegisterClassType(LevelId: Integer;
                                        C: TClass): Integer;
begin
  result := kernel.SymbolTable.RegisterClassType(LevelId, C);
end;

function TPaxCompiler.RegisterClassReferenceType(LevelId: Integer;
                           const TypeName: String; OriginClassId: Integer): Integer;
begin
  result := kernel.SymbolTable.RegisterClassReferenceType(LevelId, TypeName, OriginClassId);
end;

function TPaxCompiler.RegisterClassTypeField(TypeId: Integer; const FieldName: String;
                                        FieldTypeID: Integer; FieldShift: Integer = -1): Integer;
begin
  result := kernel.SymbolTable.RegisterTypeField(TypeId, FieldName, FieldTypeID, FieldShift);
end;

function TPaxCompiler.RegisterProperty(LevelId: Integer; const PropName: String;
                                       PropTypeID, ReadId, WriteId: Integer;
                                       IsDefault: Boolean): Integer;
begin
  result := kernel.SymbolTable.RegisterProperty(LevelId, PropName, PropTypeId,
                                    ReadId, WriteId, IsDefault);
end;

function TPaxCompiler.RegisterInterfaceProperty(LevelId: Integer;
                                       const PropName: String;
                                       PropTypeID,
                                       ReadIndex,
                                       WriteIndex: Integer): Integer;
begin
  result := kernel.SymbolTable.RegisterInterfaceProperty(LevelId, PropName, PropTypeId,
                                    ReadIndex, WriteIndex);
end;

function TPaxCompiler.RegisterProperty(LevelId: Integer; const Header: String): Integer;
begin
  result := kernel.SymbolTable.RegisterHeader(LevelId, Header, nil);
end;

function TPaxCompiler.RegisterRecordType(LevelId: Integer;
                                         const TypeName: String;
                                         IsPacked: Boolean = false): Integer;
begin
  if IsPacked then
    result := kernel.SymbolTable.RegisterRecordType(LevelId, TypeName, 1)
  else
    result := kernel.SymbolTable.RegisterRecordType(LevelId, TypeName, kernel.Alignment);
end;

function TPaxCompiler.RegisterRecordTypeField(TypeId: Integer; const FieldName: String;
                                        FieldTypeID: Integer; FieldShift: Integer = -1): Integer;
begin
  result := kernel.SymbolTable.RegisterTypeField(TypeId, FieldName, FieldTypeID, FieldShift);
end;

function TPaxCompiler.RegisterVariantRecordTypeField(TypeId: Integer; const FieldName: String;
                                FieldTypeID: Integer;
                                VarCount: Int64): Integer;
begin
  result := kernel.SymbolTable.RegisterVariantRecordTypeField(TypeId,
                                                              FieldName,
                                                              FieldTypeId,
                                                              VarCount);
end;

function TPaxCompiler.RegisterVariantRecordTypeField(LevelId: Integer; const Declaration: String;
                                VarCount: Int64): Integer;
begin
  result := kernel.SymbolTable.RegisterVariantRecordTypeField(LevelId,
      Declaration, VarCount);
end;

function TPaxCompiler.RegisterSubrangeType(LevelId: Integer;
                                           const TypeName: String;
                                           TypeBaseId: Integer;
                                           B1, B2: Integer): Integer;
begin
  result := kernel.SymbolTable.RegisterSubrangeType(LevelId, TypeName, TypeBaseId, B1, B2);
end;

function TPaxCompiler.RegisterEnumType(LevelId: Integer;
                                       const TypeName: String;
                                       TypeBaseId: Integer = _typeINTEGER): Integer;
begin
  result := kernel.SymbolTable.RegisterEnumType(LevelId, TypeName, TypeBaseId);
end;

function TPaxCompiler.RegisterEnumValue(EnumTypeId: Integer;
                                            const FieldName: String;
                                            const Value: Integer): Integer;
begin
  result := kernel.SymbolTable.RegisterEnumValue(EnumTypeId, FieldName, Value);
end;


function TPaxCompiler.RegisterArrayType(LevelId: Integer;
                                        const TypeName: String;
                                        RangeTypeId, ElemTypeId: Integer;
                                        IsPacked: Boolean = false): Integer;
begin
  if IsPacked then
    result := kernel.SymbolTable.RegisterArrayType(LevelId, TypeName, RangeTypeId, ElemTypeId, 1)
  else
    result := kernel.SymbolTable.RegisterArrayType(LevelId, TypeName, RangeTypeId, ElemTypeId, kernel.Alignment);
end;

function TPaxCompiler.RegisterDynamicArrayType(LevelId: Integer;
                                        const TypeName: String;
                                        ElemTypeId: Integer): Integer;
begin
  result := kernel.SymbolTable.RegisterDynamicArrayType(LevelId, TypeName, ElemTypeId);
end;

function TPaxCompiler.RegisterPointerType(LevelId: Integer;
                                          const TypeName: String;
                                          OriginTypeId: Integer): Integer;
begin
  result := kernel.SymbolTable.RegisterPointerType(LevelId, TypeName, OriginTypeId);
end;

function TPaxCompiler.RegisterTypeDeclaration(LevelId: Integer;
                                      const Declaration: String): Integer;
begin
  result := kernel.SymbolTable.RegisterTypeDeclaration(LevelId, Declaration);
end;

function TPaxCompiler.RegisterSomeType(LevelId: Integer;
                           const TypeName: String): Integer;
begin
  result := kernel.SymbolTable.RegisterSomeType(LevelId, TypeName);
end;

function TPaxCompiler.RegisterSetType(LevelId: Integer;
                                      const TypeName: String;
                                      OriginTypeId: Integer): Integer;
begin
  result := kernel.SymbolTable.RegisterSetType(LevelId, TypeName, OriginTypeId);
end;

function TPaxCompiler.RegisterProceduralType(LevelId: Integer;
                                             const TypeName: String;
                                             SubId: Integer): Integer;
begin
  result := kernel.SymbolTable.RegisterProceduralType(LevelId, TypeName, SubId);
end;

function TPaxCompiler.RegisterShortStringType(LevelId: Integer;
                                              const TypeName: String;
                                              L: Integer): Integer;
begin
  result := kernel.SymbolTable.RegisterShortStringType(LevelId, TypeName, L);
end;

function TPaxCompiler.RegisterEventType(LevelId: Integer;
                                        const TypeName: String;
                                        SubId: Integer): Integer;
begin
  result := kernel.SymbolTable.RegisterEventType(LevelId, TypeName, SubId);
end;

function TPaxCompiler.RegisterRTTIType(LevelId: Integer; pti: PTypeInfo): Integer;
begin
  result := kernel.SymbolTable.RegisterRTTIType(LevelId, pti);
end;

function TPaxCompiler.RegisterTypeAlias(LevelId:Integer; const TypeName: String;
                               OriginTypeId: Integer): Integer;
begin
  result := kernel.SymbolTable.RegisterTypeAlias(LevelId, TypeName, OriginTypeId);
end;

function TPaxCompiler.RegisterObject(LevelId: Integer;
                                     const ObjectName: String;
                                     TypeId: Integer;
                                     Address: Pointer = nil): Integer;
begin
  result := kernel.SymbolTable.RegisterObject(LevelId, ObjectName, TypeId, Address);
end;

function TPaxCompiler.RegisterVariable(LevelId: Integer;
                                       const VarName: String;
                                       TypeId: Integer;
                                       Address: Pointer = nil): Integer;
begin
  result := kernel.SymbolTable.RegisterVariable(LevelId, VarName, TypeId, Address);
end;

function TPaxCompiler.RegisterVariable(LevelId: Integer;
                       const Declaration: String; Address: Pointer): Integer;
begin
  result := kernel.SymbolTable.RegisterVariable(LevelId, Declaration, Address);
end;

function TPaxCompiler.RegisterConstant(LevelId: Integer;
                                       const ConstName: String;
                                       typeID: Integer;
                                       const Value: Variant): Integer;
begin
  result := kernel.SymbolTable.RegisterConstant(LevelId, ConstName, TypeId, Value);
end;

function TPaxCompiler.RegisterConstant(LevelId: Integer;
                                       const ConstName: String;
                                       const Value: Variant): Integer;
begin
  result := kernel.SymbolTable.RegisterConstant(LevelId, ConstName, Value);
end;

function TPaxCompiler.RegisterConstant(LevelId: Integer;
                              const Declaration: String): Integer;
begin
  result := kernel.SymbolTable.RegisterConstant(LevelId, Declaration);
end;

function TPaxCompiler.RegisterRoutine(LevelId: Integer;
                                      const RoutineName: String; ResultTypeID: Integer;
                                      CallConvention: Integer;
                                      Address: Pointer = nil): Integer;
begin
  result := kernel.SymbolTable.RegisterRoutine(LevelId, RoutineName, ResultTypeId,
                                      CallConvention, Address);
end;

function TPaxCompiler.RegisterMethod(LevelId: Integer;
                                     const RoutineName: String; ResultTypeID: Integer;
                                     CallConvention: Integer;
                                     Address: Pointer = nil;
                                     IsShared: Boolean = false): Integer;
begin
  result := kernel.SymbolTable.RegisterMethod(LevelId, RoutineName, ResultTypeId,
                  CallConvention, Address, IsShared);
end;

function TPaxCompiler.RegisterConstructor(LevelId: Integer;
                                          const SubName: String;
                                          Address: Pointer = nil): Integer;
begin
  result := kernel.SymbolTable.RegisterConstructor(LevelId, SubName, Address);
end;

function TPaxCompiler.RegisterParameter(HSub: Integer; ParamTypeID: Integer;
                                        const DefaultValue: Variant;
                                        ByRef: Boolean = false): Integer;
begin
  result := kernel.SymbolTable.RegisterParameter(HSub, ParamTypeId, DefaultValue, ByRef);
end;

function TPaxCompiler.RegisterHeader(LevelId: Integer; const Header: String;
                                     Address: Pointer = nil;
                                     MethodIndex: Integer = 0): Integer;
begin
  result := kernel.SymbolTable.RegisterHeader(LevelId, Header, Address, MethodIndex);
end;

function TPaxCompiler.GetHandle(LevelId: Integer; const MemberName: String; Upcase: Boolean): Integer;
begin
  result := kernel.GetHandle(LevelId, MemberName, Upcase);
end;

function TPaxCompiler.GetErrorCount: Integer;
begin
  result := kernel.Errors.Count;
end;

function TPaxCompiler.GetErrorMessage(I: Integer): String;
begin
  if (I >= 0) and (I < GetErrorCount) then
    result := kernel.Errors[I].Message
  else
    result := '';
end;

function TPaxCompiler.GetErrorModuleName(I: Integer): String;
begin
  if (I >= 0) and (I < GetErrorCount) then
    result := kernel.Errors[I].ModuleName
  else
    result := '';
end;

function TPaxCompiler.GetErrorLine(I: Integer): String;
begin
  if (I >= 0) and (I < GetErrorCount) then
    result := kernel.Errors[I].SourceLine
  else
    result := '';
end;

function TPaxCompiler.GetErrorLineNumber(I: Integer): Integer;
begin
  if (I >= 0) and (I < GetErrorCount) then
    result := kernel.Errors[I].SourceLineNumber
  else
    result := 0;
end;

function TPaxCompiler.GetErrorLinePos(I: Integer): Integer;
begin
  if (I >= 0) and (I < GetErrorCount) then
    result := kernel.Errors[I].LinePos
  else
    result := 0;
end;

function TPaxCompiler.GetOnCompilerProgress: TPaxCompilerNotifyEvent;
begin
  result := TPaxCompilerNotifyEvent(kernel.OnCompilerProgress);
end;

procedure TPaxCompiler.SetOnCompilerProgress(value: TPaxCompilerNotifyEvent);
begin
  kernel.OnCompilerProgress := TNotifyEvent(value);
end;

function TPaxCompiler.GetOnUsedUnit: TPaxCompilerUsedUnitEvent;
begin
  result := TPaxCompilerUsedUnitEvent(kernel.OnUsedUnit);
end;

procedure TPaxCompiler.SetOnUsedUnit(value: TPaxCompilerUsedUnitEvent);
begin
  kernel.OnUsedUnit := TUsedUnitEvent(value);
end;

function TPaxCompiler.GetOnSavePCU: TPaxCompilerSavePCUEvent;
begin
  result := TPaxCompilerSavePCUEvent(kernel.OnSavePCU);
end;

procedure TPaxCompiler.SetOnSavePCU(value: TPaxCompilerSavePCUEvent);
begin
  kernel.OnSavePCU := TSavePCUEvent(value);
end;

function TPaxCompiler.GetOnLoadPCU: TPaxCompilerLoadPCUEvent;
begin
  result := TPaxCompilerLoadPCUEvent(kernel.OnLoadPCU);
end;

procedure TPaxCompiler.SetOnLoadPCU(value: TPaxCompilerLoadPCUEvent);
begin
  kernel.OnLoadPCU := TLoadPCUEvent(value);
end;

function TPaxCompiler.GetOnInclude: TPaxCompilerIncludeEvent;
begin
  result := TPaxCompilerIncludeEvent(kernel.OnInclude);
end;

procedure TPaxCompiler.SetOnInclude(value: TPaxCompilerIncludeEvent);
begin
  kernel.OnInclude := TIncludeEvent(value);
end;

function TPaxCompiler.GetOnDefineDirective: TPaxCompilerDirectiveEvent;
begin
  result := TPaxCompilerDirectiveEvent(kernel.OnDefineDirective);
end;

procedure TPaxCompiler.SetOnDefineDirective(value: TPaxCompilerDirectiveEvent);
begin
  kernel.OnDefineDirective := TCompilerDirectiveEvent(value);
end;

function TPaxCompiler.GetOnUndefineDirective: TPaxCompilerDirectiveEvent;
begin
  result := TPaxCompilerDirectiveEvent(kernel.OnUndefineDirective);
end;

procedure TPaxCompiler.SetOnUndefineDirective(value: TPaxCompilerDirectiveEvent);
begin
  kernel.OnUndefineDirective := TCompilerDirectiveEvent(value);
end;

function TPaxCompiler.GetOnUnknownDirective: TPaxCompilerDirectiveEvent;
begin
  result := TPaxCompilerDirectiveEvent(kernel.OnUnknownDirective);
end;

procedure TPaxCompiler.SetOnUnknownDirective(value: TPaxCompilerDirectiveEvent);
begin
  kernel.OnUnknownDirective := TCompilerDirectiveEvent(value);
end;

function TPaxCompiler.GetSourceModule(const ModuleName: String): TStringList;
var
  I: Integer;
begin
  I := kernel.Modules.IndexOf(ModuleName);
  if I >= 0 then
    result := kernel.Modules[I].Lines
  else
    result := nil;
end;

function TPaxCompiler.GetCurrLineNumber: Integer;
begin
  result := kernel.Code.GetSourceLineNumber(kernel.Code.N);
end;

function TPaxCompiler.GetCurrModuleNumber: Integer;
begin
  result := kernel.Code.GetModuleNumber(kernel.Code.N);
end;

function TPaxCompiler.GetCurrModuleName: String;
begin
  result := kernel.Modules[CurrModuleNumber].Name;
end;

function TPaxCompiler.GetDebugMode: Boolean;
begin
  result := kernel.DEBUG_MODE;
end;

procedure TPaxCompiler.SetDebugMode(value: Boolean);
begin
  kernel.DEBUG_MODE := value;
end;

// added in v 1.5

function TPaxCompiler.GetKernelPtr: Pointer;
begin
  result := kernel;
end;

// added in v 1.9

function TPaxCompiler.GetCondDirectiveList: TStringList;
begin
  result := kernel.CondDirectiveList;
end;

function TPaxCompiler.GetAlignment: Integer;
begin
  result := kernel.Alignment;
end;

procedure TPaxCompiler.SetAlignment(value: Integer);
begin
  if not
     (
     (value = 1) or (value = 2) or
     (value = 4) or (value = 8)
     )
      then
        raise Exception.Create(Format(errInvalidAlignmentValue, [value]));

  kernel.Alignment := value;
end;

function TPaxCompiler.GetUndeclaredTypes: TStringList;
begin
  result := kernel.UndeclaredTypes;
end;

function TPaxCompiler.GetCurrLanguage: String;
begin
  result := kernel.CurrLanguage;
end;

procedure TPaxCompiler.SetCurrLanguage(const value: String);
begin
  kernel.CurrLanguage := value;
end;

procedure Register;
begin
end;


/////////////// TPaxPascalLanguage /////////////////////////////////////////////

constructor TPaxPascalLanguage.Create(AOwner: TComponent);
begin
  inherited;
  P := TPascalParser.Create;
  SetCallConv(_ccREGISTER);
end;

destructor TPaxPascalLanguage.Destroy;
begin
  P.Free;
  inherited;
end;

procedure TPaxPascalLanguage.SetCallConv(CallConv: Integer);
begin
  P.CallConv := CallConv;
end;

procedure TPaxPascalLanguage.SetInterfaceOnly(value: Boolean);
begin
  P.InterfaceOnly := value;
end;

function TPaxPascalLanguage.GetInterfaceOnly: Boolean;
begin
  result := P.InterfaceOnly;
end;

function TPaxPascalLanguage.GetParser: TBaseParser;
begin
  result := P;
end;

function TPaxPascalLanguage.GetLanguageName: String;
begin
  result := P.LanguageName;
end;

function TPaxPascalLanguage.GetCompleteBooleanEval: Boolean;
begin
  result := P.CompleteBooleanEval;
end;

procedure TPaxPascalLanguage.SetCompleteBooleanEval(value: Boolean);
begin
  P.CompleteBooleanEval := value;
end;

function TPaxPascalLanguage.GetUnitLookup: Boolean;
begin
  result := P.UnitLookup;
end;

procedure TPaxPascalLanguage.SetUnitLookup(value: Boolean);
begin
  P.UnitLookup := value;
end;

function TPaxPascalLanguage.GetPrintKeyword: String;
begin
  result := P.PrintKeyword;
end;

function TPaxPascalLanguage.GetPrintlnKeyword: String;
begin
  result := P.PrintlnKeyword;
end;

procedure TPaxPascalLanguage.SetPrintKeyword(const value: String);
begin
  P.PrintKeyword := value;
end;

procedure TPaxPascalLanguage.SetPrintlnKeyword(const value: String);
begin
  P.PrintlnKeyword := value;
end;

procedure CreateExeFile(const ExeName: String;
                        PaxProgram: TPaxProgram;
                        const DllName: String;
                        const ProcName: String);
var
  T: TImportTable;
  prg: TSymbolProg;
  P: TProgram;
begin
  prg := TSymbolProg.Create(nil);
  P := TProgram.Create;
  T := TImportTable.Create;

  try
    T.AddDll(DllName);
    T.AddProc(DllName, ProcName);

    prg.AsmPush_Imm($403000); // push data segment
    prg.AsmMovREG_Imm(_EAX, $402000);
    prg.AsmMovREG32_REGPtr(_EAX, _EAX);
    prg.AsmCall_REG(_EAX);

    prg.AsmRet(0);
    prg.CreateProgramSimple(P);

    CreateExe(ExeName, T, P, PaxProgram);
  finally
    T.Free;
    prg.Free;
    P.Free;
  end;
end;

procedure SetDump;
begin
  IsDump := true;
end;

end.
