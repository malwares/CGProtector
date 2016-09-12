////////////////////////////////////////////////////////////////////////////
// PaxCompiler
// Site: http://www.paxcompiler.com
// Author: Alexander Baranovsky (paxscript@gmail.com)
// ========================================================================
// Copyright (c) Alexander Baranovsky, 2006-2008. All rights reserved.
// Code Version: 2.4
// ========================================================================
// Unit: PAXCOMP_KERNEL.pas
// ========================================================================
////////////////////////////////////////////////////////////////////////////

{$I PaxCompiler.def}
unit PAXCOMP_KERNEL;
interface
uses
  Classes,
  SysUtils,
  PAXCOMP_CONSTANTS,
  PAXCOMP_SYS,
  PAXCOMP_MODULE,
  PAXCOMP_PARSER,
  PAXCOMP_SYMBOL_REC,
  PAXCOMP_BASESYMBOL_TABLE,
  PAXCOMP_SYMBOL_TABLE,
  PAXCOMP_BYTECODE,
  PAXCOMP_ERROR,
  PAXCOMP_OFFSET,
  PAXCOMP_VAROBJECT,
  PAXCOMP_EVAL,
  PAXCOMP_STDLIB,
  PAXCOMP_TYPEINFO,
  PAXCOMP_MAP,
  PAXCOMP_PROG;
type
  TWhatParse = (wpProgram, wpExpression, wpEvalExpression);

  TUsedUnitEvent = function (Sender: TObject; const UnitName: String;
                             var SourceCode: String): Boolean of object;

  TIncludeEvent = procedure (Sender: TObject; const FileName: String;
                              var Text: String) of object;

  TCompilerDirectiveEvent = procedure (Sender: TObject;
                                       const Directive: String;
                                       var ok: Boolean)
                                       of object;

  TKernel = class
  private
    function GetRootKernel: TKernel;
  public
    ParserList: TParserList;
    SymbolTable: TSymbolTable;
    Code: TCode;
    Errors: TErrorList;
    UndeclaredTypes: TUndeclaredTypeList;
    Modules: TModuleList;
    OffsetList: TOffsetList;
    CondDirectiveList, DefList, ExternalSymList: TStringList;
    ClassFactory: TPaxClassFactory;
    TypeInfoList: TPaxTypeInfoList;

    Owner: TObject;

    TryCount: Integer;

    OnCompilerProgress: TNotifyEvent;
    OnUsedUnit: TUsedUnitEvent;
    OnSavePCU: TSavePCUEvent;
    OnLoadPCU: TLoadPCUEvent;
    OnInclude: TIncludeEvent;

    OnDefineDirective: TCompilerDirectiveEvent;
    OnUndefineDirective: TCompilerDirectiveEvent;
    OnUnknownDirective: TCompilerDirectiveEvent;

    DEBUG_MODE: Boolean;

    CurrParser: TBaseParser;

    IsConsoleApp: Boolean;
    Alignment: Integer;

    SignCompression: Boolean;
    Canceled: Boolean;
    SignCodeCompletion: Boolean;
    CompletionTarget: String;
    InterfaceOnly: Boolean;

    UndeclaredIdentifiers: TStringList;
    TypeMap: TTypeMap;

    BuildAll: Boolean;
    BuildWithRuntimePackages: Boolean;
    BuildedUnits: TStringList;
    PCUStreamList: TStreamList;
    PCUOwner: Pointer;

    DefaultParser: TBaseParser;
    CurrLanguage: String;

    constructor Create(i_Owner: TObject);
    destructor Destroy; override;
    function AddModule(const Name, LanguageName: String): TModule;
    procedure AddCode(const ModuleName, Text: String);
    procedure AddCodeFromFile(const ModuleName, FileName: String);
    procedure RegisterParser(P: TBaseParser);
    function GetHandle(LevelId: Integer; const Name: String; Upcase: Boolean): Integer;
    procedure ParseModule(M: TModule; ModuleNumber: Integer;
                          What: TWhatParse = wpProgram);
    procedure Parse(CodeCompletion: Boolean = false;
                    const CancelModuleName: String = '';
                    X: Integer = -1;
                    Y: Integer = -1);
    procedure ParseExpression(const Expression: String;
                              const LangName: String = '');
    procedure Link;
    function HasError: Boolean;
    procedure RaiseError(const Message: string; params: array of Const);
    procedure CreateError(const Message: string; params: array of Const);
    function SourceLineToByteCodeLine(const ModuleName: String;
                                      SourceLine: Integer): Integer;
    function IsExecutableLine(const ModuleName: String;
                              SourceLine: Integer): Boolean;
    function FindFullName(const FileName: String): String;
    function GetOffset(S: TSymbolRec): Integer;
    procedure Reset;
    procedure ResetCompilation;
    function GetTypeMapRec(Id: Integer): TTypeMapRec;
    procedure CopyRootEvents;
    property RootKernel: TKernel read GetRootKernel;
  end;

function CheckProc(const TypeName: String; Data: Pointer;
                   errKind: TExternRecKind): Boolean;
var
  VarCheckProc: TCheckProc = CheckProc;

var
  CurrKernel: TKernel;

implementation

uses
  PAXCOMP_PASCAL_PARSER;

constructor TKernel.Create(i_Owner: TObject);
begin
  CurrKernel := Self;

  Owner := i_Owner;
  OnCompilerProgress := nil;

  Errors := TErrorList.Create(Self);

  UndeclaredTypes := TUndeclaredTypeList.Create;

  SymbolTable := TSymbolTable.Create(Self);
  SymbolTable.Reset;

  Code := TCode.Create(Self);
  Code.Reset;

  Modules := TModuleList.Create(Self);
  Modules.Reset;

  ParserList := TParserList.Create(Self);
  DEBUG_MODE := false;

  CondDirectiveList := TStringList.Create;
  DefList := TStringList.Create;
  ExternalSymList := TStringList.Create;

  OffsetList := TOffsetList.Create;

  Alignment := 1;

  SignCompression := true;
  Canceled := false;
  SignCodeCompletion := false;
  InterfaceOnly := false;
  UndeclaredIdentifiers := TStringList.Create;
  BuildedUnits := TStringList.Create;
  PCUStreamList := TStreamList.Create;
  TypeMap := TTypeMap.Create;
  DefaultParser := TPascalParser.Create;
end;

destructor TKernel.Destroy;
begin
  SymbolTable.Free;
  Code.Free;
  Modules.Free;

  Errors.Free;

  UndeclaredTypes.Reset;
  UndeclaredTypes.Free;

  ParserList.Free;

  DefList.Free;
  CondDirectiveList.Free;
  ExternalSymList.Free;

  OffsetList.Free;

  UndeclaredIdentifiers.Free;
  BuildedUnits.Free;
  PCUStreamList.Free;

  TypeMap.Free;
  DefaultParser.Free;

  inherited;
end;

procedure TKernel.Reset;
begin
  CompletionTarget := '';

  SymbolTable.Reset;
  Code.Reset;
  Errors.Reset;
  UndeclaredTypes.Reset;
  Modules.Reset;
  ParserList.Clear;
  DefList.Clear;
  OffsetList.Clear;
  TryCount := 0;
  Canceled := false;
  SignCodeCompletion := false;
  InterfaceOnly := false;
  UndeclaredIdentifiers.Clear;
  BuildedUnits.Clear;
  PCUStreamList.Clear;
  ExternalSymList.Clear;
  TypeMap.Clear;
  PCUOwner := nil;
end;

procedure TKernel.ResetCompilation;
begin
  CompletionTarget := '';

  if Code.Card = 0 then
    SymbolTable.CompileCard := SymbolTable.Card
  else
    SymbolTable.ResetCompilation;
  Code.Reset;
  Errors.Reset;
  UndeclaredTypes.Reset;
  Modules.Reset;
  DefList.Clear;
  OffsetList.Clear;
  TryCount := 0;
  Canceled := false;
  InterfaceOnly := false;
  UndeclaredIdentifiers.Clear;
  ExternalSymList.Clear;
  TypeMap.Clear;
  PCUOwner := nil;
end;

function TKernel.AddModule(const Name, LanguageName: String): TModule;
var
  I: Integer;
  Found: Boolean;
begin
  if Modules.Count = 0 then
  begin
    SymbolTable.CompileCard := SymbolTable.Card;
    CurrLanguage := LanguageName;
  end;

  Found := false;
  for I := 0 to ParserList.Count - 1 do
    if StrEql(LanguageName, ParserList[I].LanguageName) then
      Found := true;

  if not Found then
  begin
    if StrEql(LanguageName, 'Pascal') then
    begin
      RegisterParser(DefaultParser);
    end
    else
      RaiseError(errUnregisteredLanguage, [LanguageName]);
  end;

  result := Modules.AddModule(Name, LanguageName)
end;

procedure TKernel.AddCode(const ModuleName, Text: String);
var
  I: Integer;
begin
  I := Modules.IndexOf(ModuleName);
  if I = -1 then
    RaiseError(errModuleNotFound, [ModuleName]);
  Modules[I].Lines.Text := Modules[I].Lines.Text + Text;
end;

procedure TKernel.AddCodeFromFile(const ModuleName, FileName: String);
var
  L: TStringList;
begin
  if not FileExists(FileName) then
    RaiseError(errFileNotFound, [FileName]);
  L := TStringList.Create;
  try
    L.LoadFromFile(FileName);
    AddCode(ModuleName, L.Text);
  finally
    L.Free;
  end;
end;

procedure TKernel.RegisterParser(P: TBaseParser);
begin
  ParserList.AddParser(P);
end;

function TKernel.GetHandle(LevelId: Integer; const Name: String; Upcase: Boolean): Integer;
var
  id, I, P: Integer;
  Ok: Boolean;
  S: String;
begin
  P := 0;
  for I:= Length(Name) downto 1 do
    if Name[I] = '.' then
    begin
      P := I;
      break;
    end;

  if P > 0 then
  begin
    S := Copy(Name, 1, P - 1);
    LevelId := GetHandle(LevelId, S, Upcase);
    if LevelId = 0 then
    begin
      result := 0;
      Exit;
    end;
    S := Copy(Name, P + 1, Length(Name) - P);
  end
  else
    S := Name;

  id := 0;

  with SymbolTable do
  for I := Card downto 1 do
  if (Records[I].Level = LevelId) and
     (Records[I].OwnerId = 0) and
     (Records[I].Kind <> KindNONE) then
  begin
    if UpCase then
      ok := StrEql(Records[I].Name, S)
    else
      ok := Records[I].Name = S;
    if ok then
    begin
      id := I;
      break;
    end;
  end;

  if id > 0 then
  begin
    if SymbolTable[id].Kind in KindSUBs then
      result := - SymbolTable[id].Value
    else if SymbolTable[id].Kind in [KindNAMESPACE, KindTYPE] then
      result := id
    else
      result := SymbolTable[id].Shift;
  end
  else
    result := 0;
end;

procedure TKernel.ParseModule(M: TModule; ModuleNumber: Integer;
                              What: TWhatParse = wpProgram);
var
  LanguageNamespaceId: Integer;
  L, I, J, ExitLabelId: Integer;
  parser: TBaseParser;
  R: TSymbolRec;
begin
  Canceled := false;
  DefList.Clear;
  for I := 0 to CondDirectiveList.Count - 1 do
    DefList.Add(CondDirectiveList[I]);

  parser := ParserList.FindParser(M.LanguageName);

  CurrParser := parser;

  if parser = nil then
    RaiseError(errLanguageNotRegistered, [M.LanguageName]);

  M.ModuleNumber := ModuleNumber;

  CurrLanguage := M.LanguageName;

  parser.Init(Self, M);
  try
    parser.Gen(OP_BEGIN_MODULE, ModuleNumber, parser.LanguageId, Integer(parser.UpCase));
    parser.Gen(OP_SEPARATOR, ModuleNumber, 0, 0);

    LanguageNamespaceId := SymbolTable.LookUp(M.LanguageName + 'Namespace', 0, true);
    if LanguageNamespaceId = 0 then
      LanguageNamespaceId := H_PascalNamespace;
//      LanguageNamespaceId := SymbolTable.RegisterNamespace(0, M.LanguageName + 'Namespace');

    parser.Gen(OP_BEGIN_USING, 0, 0, 0);
    parser.Gen(OP_BEGIN_USING, LanguageNamespaceId, 0, 0);

    L := parser.NewLabel;
    parser.SkipLabelStack.Push(L);

    ExitLabelId := parser.NewLabel;
    parser.ExitLabelStack.Push(L);

    case What of
      wpProgram: parser.ParseProgram;
      wpExpression:
      begin
        parser.Gen(OP_END_INTERFACE_SECTION, 0, 0, 0);
        parser.DECLARE_SWITCH := false;
        parser.Call_SCANNER;
        parser.Gen(OP_ASSIGN, SymbolTable.ResultId, parser.Parse_Expression, SymbolTable.ResultId);
      end;
      wpEvalExpression:
      begin
        R := SymbolTable.AddRecord;
        R.Kind := KindVAR;
        R.Name := '__result';
        R.Level := 0;

        parser.Gen(OP_END_INTERFACE_SECTION, 0, 0, 0);
        parser.DECLARE_SWITCH := false;
        parser.Call_SCANNER;
        parser.Gen(OP_ASSIGN, R.Id, parser.Parse_Expression, R.Id);
      end;
    else
      parser.ParseProgram;
    end;
    parser.SkipLabelStack.Pop;
    parser.SetLabelHere(L);

    parser.ExitLabelStack.Pop;
    parser.SetLabelHere(ExitLabelId);

    parser.Gen(OP_END_USING, LanguageNamespaceId, 0, 0);
    parser.Gen(OP_END_USING, 0, 0, 0);
//    parser.Gen(OP_RET, 0, 0, 0);
    parser.Gen(OP_END_MODULE, ModuleNumber, 0, 0);

    if parser.IsConsoleApp then
      IsConsoleApp := parser.IsConsoleApp;
  except
    on E: PaxCompilerException do
    begin
      // already has been processed
    end;
    on E: PaxCancelException do
    begin
      Errors.Reset;
      Canceled := true;
    end;
    on E: Exception do
    begin
      CreateError(E.Message, []);
    end;
  end;

  if parser.InterfaceOnly then
    Exit;

  if Canceled then
    Exit;

  if What = wpExpression then
    Exit;
  if What = wpEvalExpression then
    Exit;
  for I:=FirstLocalId + 1 to SymbolTable.Card do
  begin
    if SymbolTable[I].IsForward then
    begin
      for J := 1 to Code.Card do
        if Code[J].Op = OP_BEGIN_SUB then
          if Code[J].Arg1 = I then
          begin
            Code.N := J;
            break;
          end;

      CreateError(errUnsatisfiedForwardOrExternalDeclaration, [SymbolTable[I].Name]);
    end;
  end;
end;

procedure TKernel.Parse(CodeCompletion: Boolean = false;
                        const CancelModuleName: String = '';
                        X: Integer = -1;
                        Y: Integer = -1);
var
  I, CancelPos: Integer;
  Temp: Boolean;
begin
  SignCodeCompletion := CodeCompletion;
  Temp := false;

  code.Reset;
  SymbolTable.CompileCard := SymbolTable.Card;
  I := 0;
  while (I < Modules.Count) do
  begin

    if CodeCompletion and StrEql(CancelModuleName, Modules[I].Name) then
    begin
      CancelPos := Modules.GetPos(CancelModuleName, X, Y);
      if CancelPos = -1 then
         Exit;
      Modules[I].CancelPos := CancelPos;
    end;

    Modules[I].State := msCompiling;
    if not Modules[I].SkipParsing then
      ParseModule(Modules[I], I);
    Modules[I].State := msCompiled;

    Inc(I);

    if Canceled then
    begin
      Temp := True;
      if I >= Modules.Count then
        break;
    end;
  end;

  Canceled := Temp;

  for I := Modules.Count - 1 downto 0 do
    if Modules[I].SkipParsing then
      Modules.Delete(Modules[I]);
end;

procedure TKernel.ParseExpression(const Expression: String;
                                  const LangName: String = '');
var
  M: TModule;
begin
  if LangName = '' then
    M := AddModule('$', 'Pascal')
  else
    M := AddModule('$', LangName);
  AddCode('$', Expression);
  ParseModule(M, 0, wpExpression);
end;

procedure TKernel.RaiseError(const Message: string; params: array of Const);
begin
  CreateError(Message, params);
  if SignCodeCompletion then
    raise PaxCancelException.Create(Format(Message, params))
  else
    raise PaxCompilerException.Create(Format(Message, params));
end;

procedure TKernel.CreateError(const Message: string; params: array of Const);
var
  E: TError;
begin
  E := TError.Create(Self, Format(Message, params));
  Errors.Add(E);
end;

function TKernel.HasError: Boolean;
begin
  result := Errors.Count > 0;
end;

function CheckProc(const TypeName: String; Data: Pointer; errKind: TExternRecKind): Boolean;
var
  Code: TCode;
  CodeRec: TCodeRec;
  SymbolTable: TSymbolTable;
  I, Id, K: Integer;
  S: String;
begin
  S := ExtractName(TypeName);
  result := false;
  Code := TKernel(Data).Code;
  SymbolTable := TKernel(Data).SymbolTable;
  K := SymbolTable.Card;
  for I := 1 to Code.Card do
  begin
    CodeRec := Code[I];
    Id := CodeRec.Arg1;
    if (Id > StdCard) and (Id <= K) then
      if StrEql(S, SymbolTable[Id].Name) then
      begin
        Code.N := I;
        result := true;
        Exit;
      end;
    Id := CodeRec.Arg2;
    if (Id > StdCard) and (Id <= K) then
      if StrEql(S, SymbolTable[Id].Name) then
      begin
        Code.N := I;
        result := true;
        Exit;
      end;
    Id := CodeRec.Res;
    if (Id > StdCard) and (Id <= K) then
      if StrEql(S, SymbolTable[Id].Name) then
      begin
        Code.N := I;
        result := true;
        Exit;
      end;
  end;
end;

procedure TKernel.Link;
begin
  try
    SymbolTable.Update;
    try
      SymbolTable.ResolveExternList(VarCheckProc, Self);
    except
      on E: Exception do
      begin
        CreateError(E.Message, []);
      end;
    end;

    if HasError then Exit;
    code.RemoveEvalOpForTypes;

    if HasError then Exit;
    code.ProcessImplements;

    if HasError then Exit;
    code.RemoveEvalOp;

    if HasError then Exit;
    if not Canceled then
    code.GenHostStructConst;

    if HasError then Exit;
    if not Canceled then
    code.UpdateDefaultConstructors;

    if HasError then Exit;
    modules.CreateLoadOrder;

    if HasError then Exit;
    code.CheckTypes;

    if Canceled then
    begin
      Exit;
    end;

    if InterfaceOnly then
    begin
      Exit;
    end;

    if HasError then Exit;
    code.InsertDynamicTypeDestructors;

    if HasError then Exit;
    code.InsertFinalizators;

    if HasError then Exit;
    code.InsertTryFinally;

    if HasError then Exit;
    SymbolTable.SetShifts;

    if HasError then Exit;
    TypeInfoList.SetFieldOffsets(SymbolTable);

    if HasError then Exit;
    code.ProcessSizeOf;

    if HasError then Exit;
    code.ChangeOrderOfActualParams;

    if HasError then Exit;
    code.AssignShifts;

    if HasError then Exit;
    code.Optimization;

    code.AdjustTryList;

  except
  end;
end;

function TKernel.SourceLineToByteCodeLine(const ModuleName: String;
                                          SourceLine: Integer): Integer;
var
  I: Integer;
  M: TModule;
begin
  result := 0;
  I := Modules.IndexOf(ModuleName);
  if I = -1 then
    Exit;
  M := Modules[I];
  for I:=M.P1 to M.P3 do
    if Code[I].OP = OP_SEPARATOR then
      if Code[I].Arg2 = SourceLine then
      begin
        result := I;
        Exit;
      end;
end;

function TKernel.IsExecutableLine(const ModuleName: String;
                                  SourceLine: Integer): Boolean;
var
  I, J: Integer;
  M: TModule;
begin
  result := false;
  I := Modules.IndexOf(ModuleName);
  if I = -1 then
    Exit;
  M := Modules[I];
  for I:=M.P1 to M.P3 do
    if Code[I].OP = OP_SEPARATOR then
      if Code[I].Arg2 = SourceLine then
      begin
        J := I;
        repeat
          Inc(J);
          
          if J > Code.Card then
            Exit;
          if Code[J].Op = OP_SEPARATOR then
            Exit;

          if Code[J].Op = OP_SET_CODE_LINE then
          begin
            result := true;
            Exit;
          end;
        until false;

        Exit;
      end;
end;

function TKernel.FindFullName(const FileName: String): String;
begin
  result := FileName; // not implemented yet
end;

function TKernel.GetOffset(S: TSymbolRec): Integer;
var
  Shift: Integer;
begin
  if SignCompression then
  begin
    Shift := S.Shift;

    if (Shift <= 0) or (S.Kind = kindTYPE_FIELD) then
    begin
      result := Shift;
      Exit;
    end;

    result := OffsetList.GetOffset(Shift);

    if result = -1 then
      RaiseError(errInternalError, []);
  end
  else
    result := S.Shift;
end;

function TKernel.GetTypeMapRec(Id: Integer): TTypeMapRec;
var
  T: Integer;
begin
  result := nil;

  T := SymbolTable[Id].FinalTypeId;
  if not (T in [typeRECORD, typeCLASS]) then
    Exit;

  T := SymbolTable[Id].TerminalTypeId;
  result := TypeMap.Lookup(T);
  if result = nil then
    result := TypeMap.Add(T);
  if not result.Completed then
  begin
    result.Fields.Clear;
    SymbolTable.GetFieldCount(Id, result);
    result.Completed := true;
  end;
end;

function TKernel.GetRootKernel: TKernel;
begin
  result := Self;
  while result.PCUOwner <> nil do
    result := result.PCUOwner;
end;

procedure TKernel.CopyRootEvents;
var
  RK: TKernel;
begin
  RK := RootKernel;
  if Self <> RK then
  begin
    Owner := RK.Owner;

    OnCompilerProgress := RK.OnCompilerProgress;
    OnUsedUnit := RK.OnUsedUnit;
    OnSavePCU := RK.OnSavePCU;
    OnLoadPCU := RK.OnLoadPCU;
    OnInclude := RK.OnInclude;
    OnDefineDirective := RK.OnDefineDirective;
    OnUndefineDirective := RK.OnUndefineDirective;
    OnUnknownDirective := RK.OnUnknownDirective;
  end;
end;

end.
