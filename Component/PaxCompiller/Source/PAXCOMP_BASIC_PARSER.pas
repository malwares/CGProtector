////////////////////////////////////////////////////////////////////////////
// PaxCompiler
// Site: http://www.paxcompiler.com
// Author: Alexander Baranovsky (paxscript@gmail.com)
// ========================================================================
// Copyright (c) Alexander Baranovsky, 2006-2007. All rights reserved.
// Code Version: 2.4
// ========================================================================
// Unit: PAXCOMP_BASIC_PARSER.pas
// ========================================================================
////////////////////////////////////////////////////////////////////////////

{$I PaxCompiler.def}
unit PAXCOMP_BASIC_PARSER;
interface
uses
  SysUtils,
  Classes,
  PAXCOMP_CONSTANTS,
  PAXCOMP_SYS,
  PAXCOMP_MODULE,
  PAXCOMP_SCANNER,
  PAXCOMP_STDLIB,
  PAXCOMP_PARSER;
type
	TExitKind = (ekNone,
               ekDo,
               ekFor,
               ekWhile,
               ekSelect,
               ekSub,
               ekTry,
               ekFunction);

	TBasicModifier = (modPublic,
                    modProtected,
                    modPublished,
                    modInternal,
                    modPrivate,
                    modShared,
                    modOverridable,
                    modNotOverridable,
                    modMustOverride,
                    modOverrides,
                    modOverloads,
                    modReadOnly,
                    modFriend,
                    modDefault,
                    modMustInherit,
                    modShadows,
                    modNotInheritable,
                    modWithEvents);

  TBasicModifierList = set of TBasicModifier;

	TForLoopRec = class
  public
		id, step_id, lg, lf: Integer;
    Name: String;
  end;

	TForLoopStack = class
  private
		s: TList;
    function GetRecord(I: Integer): TForLoopRec;
    function GetTop: TForLoopRec;
  public
    constructor Create;
    destructor Destroy; override;
    procedure Push(id, step_id, lg, lf: Integer; const AName: String);
    procedure Pop;
    procedure	Clear;
    function Count: Integer;
    property Records[I: Integer]: TForLoopRec read GetRecord;
    property Top: TForLoopRec read GetTop;
  end;

  TBasicParser = class(TBaseParser)
  private
    exit_kind_stack: TIntegerStack;
    for_loop_stack: TForLoopStack;
    with_stack: TIntegerStack;
    WasInherited: Boolean;

    ParsesModuleBody: Boolean;
    ForEachCounter: Integer;

    function GetCurrExitKind: TExitKind;
  protected
    function CreateScanner: TBaseScanner; override;
    function GetLanguageName: String; override;
    function GetFileExt: String; override;
    procedure GenDefaultClassConstructor(ClassId: Integer; InitIds: TIntegerList);
    procedure GenDefaultClassDestructor(ClassId: Integer);
    procedure GenDefaultStructureConstructor(StructId: Integer; InitIds: TIntegerList);
    procedure GenDefaultStructureDestructor(StructId: Integer);
    function GetLanguageId: Integer; override;
    function GetUpcase: Boolean; override;
  public
    constructor Create; override;
    destructor Destroy; override;

    procedure ParseProgram; override;
    function GetIncludedFileExt: String; override;

    procedure Init(i_kernel: Pointer; M: TModule); override;

    procedure PushExitKind(k: TExitKind);
    procedure PopExitKind;

    procedure Parse_ImportsClause;
    procedure Parse_NamespaceDeclaration;
    procedure Parse_ModuleDeclaration;
    procedure Parse_NamespaceMemberDeclaration;
    procedure Parse_StructureTypeDeclaration(StructureMl: TBasicModifierList);
    procedure Parse_ClassTypeDeclaration(ClassMl: TBasicModifierList);
    procedure Parse_InterfaceTypeDeclaration(InterfaceMl: TBasicModifierList);
    procedure Parse_EnumTypeDeclaration(EnumMl: TBasicModifierList);
    function Parse_FormalParameterList(SubId: Integer): Integer;
    procedure Parse_ExternalSubDeclaration(SubMl: TBasicModifierList);
    procedure Parse_ExternalFunctionDeclaration(FunctionMl: TBasicModifierList);
    procedure Parse_SubDeclaration(SubMl: TBasicModifierList);
    procedure Parse_FunctionDeclaration(FunctionMl: TBasicModifierList);
    procedure Parse_DimStmt(DimMl: TBasicModifierList);
    procedure Parse_ConstStmt(ConstMl: TBasicModifierList);
    procedure Parse_CallConvention(SubId: Integer; IsDeclaredProc: Boolean);

    procedure Parse_Statement;
    procedure Parse_Statements;
    procedure Parse_Block;
    procedure Parse_ReturnStmt;
    procedure Parse_GotoStmt;
    procedure Parse_IfStmt;
    procedure Parse_ContinueStmt;
    procedure Parse_ExitStmt;
    procedure Parse_SelectStmt;
    procedure Parse_WhileStmt;
    procedure Parse_DoLoopStmt;
    procedure Parse_ForNextStmt;
    procedure Parse_ForEachStmt;
    procedure Parse_TryStmt;
    procedure Parse_ThrowStmt;
    procedure Parse_WithStmt;
    procedure Parse_AssignmentStmt;
    procedure Parse_PrintStmt;
    procedure Parse_PrintlnStmt;

    function Parse_ModifierList: TBasicModifierList;
    function Parse_VisibilityModifierList: TBasicModifierList;

    function Parse_ArgumentList(SubId: Integer): Integer;
    function Parse_Expression: Integer; override;
    function Parse_ConstantExpression: Integer;
    function Parse_LogicalXORExpression: Integer;
    function Parse_LogicalORExpression: Integer;
    function Parse_LogicalANDExpression: Integer;
    function Parse_LogicalNOTExpression: Integer;
    function Parse_RelationalExpression: Integer;
    function Parse_ShiftExpression: Integer;
    function Parse_ConcatenationExpression: Integer;
    function Parse_AdditiveExpression: Integer;
    function Parse_ModulusExpression: Integer;
    function Parse_IntegerDivisionExpression: Integer;
    function Parse_MultiplicativeExpression: Integer;
    function Parse_Factor: Integer;
    function Parse_NewExpression: Integer;
    function Parse_Designator(init_id: Integer = 0): Integer;
    function Parse_QualId: Integer;
    function Parse_Type: Integer;
    function Parse_Label: Integer;

    procedure Call_SCANNER; override;
    function Parse_Ident: Integer; override;
    function IsLineTerminator: Boolean;
    function IsStatementTerminator: Boolean;
    procedure MatchLineTerminator;
    procedure MatchStatementTerminator;

    property CurrExitKind: TExitKind read GetCurrExitKind;
  end;

implementation

uses
  PAXCOMP_BASIC_SCANNER, PAXCOMP_KERNEL;

constructor TForLoopStack.Create;
begin
  inherited;
  s := TList.Create;
end;

destructor TForLoopStack.Destroy;
begin
  Clear;
  s.Free;
  inherited;
end;

procedure TForLoopStack.Push(id, step_id, lg, lf: Integer; const AName: String);
var
  r: TForLoopRec;
begin
	r := TForLoopRec.Create;
	r.id := id;
	r.step_id := step_id;
	r.lg := lg;
	r.lf := lf;
  r.Name := UpperCase(AName);
	s.Add(r);
end;

procedure TForLoopStack.Pop;
begin
  Records[Count - 1].Free;
  s.Delete(Count - 1);
end;

procedure	TForLoopStack.Clear;
var
  I: Integer;
begin
  for I:=0 to Count - 1 do
    Records[I].Free;
  s.Clear;
end;

function TForLoopStack.Count: Integer;
begin
  result := s.Count;
end;

function TForLoopStack.GetRecord(I: Integer): TForLoopRec;
begin
  result := TForLoopRec(s[I]);
end;

function TForLoopStack.GetTop: TForLoopRec;
begin
  result := Records[Count - 1];
end;

constructor TBasicParser.Create;
begin
  inherited;
  exit_kind_stack := TIntegerStack.Create;
  for_loop_stack := TForLoopStack.Create;
  with_stack := TIntegerStack.Create;

  AddKeyword('AddHandler');
  AddKeyword('AddressOf');
  AddKeyword('Alias');
  AddKeyword('And');
  AddKeyword('AndAlso');
  AddKeyword('Ansi');
  AddKeyword('As');
  AddKeyword('Assembly');
  AddKeyword('Auto');
  AddKeyword('Boolean');
  AddKeyword('ByRef');
  AddKeyword('Byte');
  AddKeyword('ByVal');
  AddKeyword('Call');
  AddKeyword('Case');
  AddKeyword('Catch');
  AddKeyword('CBool');
  AddKeyword('CByte');
  AddKeyword('CChar');
  AddKeyword('CDate');
  AddKeyword('CDbl');
  AddKeyword('CDec');
  AddKeyword('Char');
  AddKeyword('CInt');
  AddKeyword('Class');
  AddKeyword('CLng');
  AddKeyword('CObj');
  AddKeyword('Const');
  AddKeyword('Continue');
  AddKeyword('CShort');
  AddKeyword('CSng');
  AddKeyword('CStr');
  AddKeyword('CType');
  AddKeyword('Date');
  AddKeyword('Decimal');
  AddKeyword('Declare');
  AddKeyword('Default');
  AddKeyword('Delegate');
  AddKeyword('Dim');
  AddKeyword('DirectCast');
  AddKeyword('Do');
  AddKeyword('Double');
  AddKeyword('Each');
  AddKeyword('Else');
  AddKeyword('ElseIf');
  AddKeyword('End');
  AddKeyword('EndIf');
  AddKeyword('Enum');
  AddKeyword('Erase');
  AddKeyword('Error');
  AddKeyword('Event');
  AddKeyword('Exit');
  AddKeyword('False');
  AddKeyword('Finally');
  AddKeyword('For');
  AddKeyword('From');
  AddKeyword('Friend');
  AddKeyword('Function');
  AddKeyword('Get');
//			AddKeyword('GetType');
  AddKeyword('GoSub');
  AddKeyword('GoTo');
  AddKeyword('Handles');
  AddKeyword('If');
  AddKeyword('Implements');
  AddKeyword('Imports');
  AddKeyword('In');
  AddKeyword('Inherits');
  AddKeyword('Integer');
  AddKeyword('Interface');
  AddKeyword('Is');
  AddKeyword('IsNot');
  AddKeyword('Let');
  AddKeyword('Lib');
  AddKeyword('Like');
  AddKeyword('Long');
  AddKeyword('Loop');
  AddKeyword('Me');
  AddKeyword('Mod');
  AddKeyword('Module');
  AddKeyword('MustInherit');
  AddKeyword('MustOverride');
  AddKeyword('MyBase');
  AddKeyword('MyClass');
  AddKeyword('Namespace');
  AddKeyword('New');
  AddKeyword('Next');
  AddKeyword('Not');
  AddKeyword('Nothing');
  AddKeyword('NotInheritable');
  AddKeyword('NotOverridable');
  AddKeyword('Null');
  AddKeyword('Object');
  AddKeyword('On');
  AddKeyword('Option');
  AddKeyword('Optional');
  AddKeyword('Or');
  AddKeyword('Overloads');
  AddKeyword('Overridable');
  AddKeyword('Overrides');
  AddKeyword('ParamArray');
  AddKeyword('Preserve');
  AddKeyword('Private');
  AddKeyword('Property');
  AddKeyword('Protected');
  AddKeyword('Public');
  AddKeyword('Published');
  AddKeyword('RaiseEvent');
  AddKeyword('ReadOnly');
  AddKeyword('ReDim');
  AddKeyword('REM');
  AddKeyword('RemoveHandler');
  AddKeyword('Resume');
  AddKeyword('Return');
  AddKeyword('Select');
  AddKeyword('Set');
  AddKeyword('Shadows');
  AddKeyword('Shared');
  AddKeyword('Short');
  AddKeyword('Single');
  AddKeyword('Static');
  AddKeyword('Step');
  AddKeyword('Stop');
  AddKeyword('String');
  AddKeyword('Structure');
  AddKeyword('Sub');
  AddKeyword('SyncLock');
  AddKeyword('Then');
  AddKeyword('Throw');
  AddKeyword('To');
  AddKeyword('True');
  AddKeyword('Try');
  AddKeyword('TypeOf');
  AddKeyword('Unicode');
  AddKeyword('Until');
  AddKeyword('Variant');
  AddKeyword('Wend');
  AddKeyword('When');
  AddKeyword('While');
  AddKeyword('With');
  AddKeyword('WithEvents');
  AddKeyword('WriteOnly');
  AddKeyword('Xor');

  AddKeyword('print');
  AddKeyword('println');

  AddKeyword('Register');
  AddKeyword('StdCall');
  AddKeyword('CDecl');
  AddKeyword('Pascal');
  AddKeyword('SafeCall');
  AddKeyword('MSFastCall');
end;

destructor TBasicParser.Destroy;
begin
  exit_kind_stack.Free;
  for_loop_stack.Free;
  with_stack.Free;
  inherited;
end;

procedure TBasicParser.GenDefaultClassConstructor(ClassId: Integer; InitIds: TIntegerList);
var
  SubId, ResId, L, I: Integer;
begin
  LevelStack.Push(ClassId);
  SubId := NewTempVar;

  BeginClassConstructor(SubId, ClassId);
  SetVisibility(SubId, cvPublic);
  inherited InitSub(SubId);
  Gen(OP_SAVE_EDX, 0, 0, 0);

  L := NewLabel;
  Gen(OP_GO_DL, L, 0, 0);
  Gen(OP_CREATE_OBJECT, ClassId, 0, CurrSelfId);
  SetLabelHere(L);

  Gen(OP_BEGIN_WITH, CurrSelfId, 0, 0);
  WithStack.Push(CurrSelfId);

  NewTempVar;
  ResId := NewTempVar;

  Gen(OP_PUSH_CLASSREF, CurrSelfId, 0, ResId);
  Gen(OP_EVAL_INHERITED, SubId, 0, ResId);

  SetDefault(SubId, true);
  Gen(OP_UPDATE_DEFAULT_CONSTRUCTOR, SubId, 0, ResId);
// will insertion here

  Gen(OP_CALL, ResId, 0, 0);

  for I := 0 to InitIds.Count - 1 do
  begin
    Gen(OP_PUSH_INSTANCE, CurrSelfId, 0, InitIds[I]);
    Gen(OP_CALL, InitIds[I], 0, 0);
  end;

  Gen(OP_END_WITH, WithStack.Top, 0, 0);
  WithStack.Pop;

  Gen(OP_RESTORE_EDX, 0, 0, 0);
  L := NewLabel;
  Gen(OP_GO_DL, L, 0, 0);
  Gen(OP_ONCREATE_OBJECT, CurrSelfId, 0, 0);
  Gen(OP_ON_AFTER_OBJECT_CREATION, CurrSelfId, 0, 0);
  SetLabelHere(L);

  EndSub(SubId);
  LevelStack.Pop;
end;

procedure TBasicParser.GenDefaultClassDestructor(ClassId: Integer);
var
  SubId, Id, ResId: Integer;
begin
  LevelStack.Push(ClassId);
  SubId := NewTempVar;
  SetName(SubId, 'Destroy');
  BeginClassDestructor(SubId, ClassId);
  SetVisibility(SubId, cvPublic);
  inherited InitSub(SubId);

  Gen(OP_BEGIN_WITH, CurrSelfId, 0, 0);
  WithStack.Push(CurrSelfId);

  Id := NewTempVar;
  ResId := NewTempVar;
  SetName(Id, 'Destroy');
  Gen(OP_EVAL, 0, 0, Id);
  Gen(OP_EVAL_INHERITED, Id, 0, ResId);
  Gen(OP_CALL, ResId, 0, 0);

  Gen(OP_END_WITH, WithStack.Top, 0, 0);
  WithStack.Pop;

  EndSub(SubId);
  LevelStack.Pop;
end;

procedure TBasicParser.GenDefaultStructureConstructor(StructId: Integer; InitIds: TIntegerList);
var
  SubId, I: Integer;
begin
  LevelStack.Push(StructId);
  SubId := NewTempVar;
  SetName(SubId, 'Create');
  BeginStructureConstructor(SubId, StructId);
  SetVisibility(SubId, cvPublic);
  inherited InitSub(SubId);
  Gen(OP_BEGIN_WITH, CurrSelfId, 0, 0);
  WithStack.Push(CurrSelfId);
  SetName(CurrSelfId, 'Me');
  for I := 0 to InitIds.Count - 1 do
  begin
    Gen(OP_PUSH_INSTANCE, CurrSelfId, 0, InitIds[I]);
    Gen(OP_CALL, InitIds[I], 0, 0);
  end;
  Gen(OP_END_WITH, WithStack.Top, 0, 0);
  WithStack.Pop;

  EndSub(SubId);
  LevelStack.Pop;
end;

procedure TBasicParser.GenDefaultStructureDestructor(StructId: Integer);
var
  SubId: Integer;
begin
  LevelStack.Push(StructId);
  SubId := NewTempVar;
  SetName(SubId, 'Destroy');
  BeginStructureDestructor(SubId, StructId);
  SetVisibility(SubId, cvPublic);
  inherited InitSub(SubId);

  Gen(OP_BEGIN_WITH, CurrSelfId, 0, 0);
  WithStack.Push(CurrSelfId);

  Gen(OP_END_WITH, WithStack.Top, 0, 0);
  WithStack.Pop;

  EndSub(SubId);
  LevelStack.Pop;
end;


procedure TBasicParser.Init(i_kernel: Pointer; M: TModule);
begin
  exit_kind_stack.Clear;
  for_loop_stack.Clear;
  with_stack.Clear;
  ParsesModuleBody := false;
  ForEachCounter := 0;
  inherited;
end;

function TBasicParser.CreateScanner: TBaseScanner;
begin
  result := TBasicScanner.Create;
end;

function TBasicParser.GetLanguageName: String;
begin
  result := 'Basic';
end;

function TBasicParser.GetFileExt: String;
begin
  result := 'bas';
end;

function TBasicParser.GetIncludedFileExt: String;
begin
  result := 'bas';
end;

function TBasicParser.GetLanguageId: Integer;
begin
  result := BASIC_LANGUAGE;
end;

function TBasicParser.GetUpcase: Boolean;
begin
  result := true;
end;

procedure TBasicParser.ParseProgram;
var
  B1, B2: Integer;
begin
  Call_SCANNER;

  while IsLineTerminator do
    MatchLineTerminator;

  if IsCurrText('Module') then
  begin
    Parse_ModuleDeclaration;
    Exit;
  end;

  while IsCurrText('Imports') do
    Parse_ImportsClause;

  Gen(OP_END_IMPORT, 0, 0, 0);

  B1 := CodeCard;

  while IsCurrText('Namespace') do
    Parse_NamespaceDeclaration;

  Gen(OP_END_INTERFACE_SECTION, CurrModule.ModuleNumber, 0, 0);
  Parse_Statements;

  B2 := CodeCard;

  BeginFinalization;

  Gen(OP_BEGIN_GLOBAL_BLOCK, 0, 0, 0);
  Gen(OP_NOP, 0, 0, 0);

  Gen(OP_EPILOGUE_GLOBAL_BLOCK, 0, 0, 0);
  Gen(OP_NOP, 0, 0, 0);
  Gen(OP_NOP, 0, 0, 0);
  Gen(OP_EPILOGUE_GLOBAL_BLOCK2, 0, 0, 0);

  GenDestroyGlobalDynamicVariables(B1, B2);

  Gen(OP_NOP, 0, 0, 0);
  Gen(OP_NOP, 0, 0, 0);
  Gen(OP_NOP, 0, 0, 0);
  Gen(OP_NOP, 0, 0, 0);
  Gen(OP_END_GLOBAL_BLOCK, 0, 0, 0);

  EndFinalization;
end;

procedure TBasicParser.Parse_Statement;
var
  ml: TBasicModifierList;
begin
  if CurrToken.TokenClass = tcIdentifier then
    if GetKind(CurrToken.Id) = KindLABEL then
    begin
      SetLabelHere(CurrToken.Id);
      Call_SCANNER;
      Match(':');
    end;

  ml := Parse_VisibilityModifierList;

  Gen(OP_STMT, 0, 0, 0);
  if IsCurrText('Structure') then
    Parse_StructureTypeDeclaration(ml)
  else if IsCurrText('Class') then
    Parse_ClassTypeDeclaration(ml)
  else if IsCurrText('Interface') then
    Parse_InterfaceTypeDeclaration(ml)
  else if IsCurrText('Enum') then
    Parse_EnumTypeDeclaration(ml)
  else if IsCurrText('Sub') then
    Parse_SubDeclaration(ml)
  else if IsCurrText('Function') then
    Parse_FunctionDeclaration(ml)
  else if IsCurrText('Declare') then
  begin
    Call_SCANNER;
    if IsCurrText('Sub') then
      Parse_ExternalSubDeclaration(ml)
    else if IsCurrText('Function') then
      Parse_ExternalFunctionDeclaration(ml)
    else
      Match('Sub');
  end
  else if IsCurrText('Dim') then
  begin
    Inc(EXECUTABLE_SWITCH);
    Parse_DimStmt(ml);
    Dec(EXECUTABLE_SWITCH);
  end
  else if IsCurrText('Const') then
    Parse_ConstStmt(ml)
  else if IsCurrText('Goto') then
  begin
    Inc(EXECUTABLE_SWITCH);
    Parse_GotoStmt;
    Dec(EXECUTABLE_SWITCH);
  end
  else if IsCurrText('If') then
  begin
    Inc(EXECUTABLE_SWITCH);
    Parse_IfStmt;
    Dec(EXECUTABLE_SWITCH);
  end
  else if IsCurrText('Continue') then
  begin
    Inc(EXECUTABLE_SWITCH);
    Parse_ContinueStmt;
    Dec(EXECUTABLE_SWITCH);
  end
  else if IsCurrText('Exit') then
  begin
    Inc(EXECUTABLE_SWITCH);
    Parse_ExitStmt;
    Dec(EXECUTABLE_SWITCH);
  end
  else if IsCurrText('Select') then
  begin
    Inc(EXECUTABLE_SWITCH);
    Parse_SelectStmt;
    Dec(EXECUTABLE_SWITCH);
  end
  else if IsCurrText('While') then
  begin
    Inc(EXECUTABLE_SWITCH);
    Parse_WhileStmt;
    Dec(EXECUTABLE_SWITCH);
  end
  else if IsCurrText('Do') then
  begin
    Inc(EXECUTABLE_SWITCH);
    Parse_DoLoopStmt;
    Dec(EXECUTABLE_SWITCH);
  end
  else if IsCurrText('For') then
  begin
    Inc(EXECUTABLE_SWITCH);
    if IsNextText('Each') then
      Parse_ForEachStmt
    else
      Parse_ForNextStmt;
    Dec(EXECUTABLE_SWITCH);
  end
  else if IsCurrText('Try') then
  begin
    Inc(EXECUTABLE_SWITCH);
    Parse_TryStmt;
    Dec(EXECUTABLE_SWITCH);
  end
  else if IsCurrText('Throw') then
  begin
    Inc(EXECUTABLE_SWITCH);
    Parse_ThrowStmt;
    Dec(EXECUTABLE_SWITCH);
  end
  else if IsCurrText('With') then
  begin
    Inc(EXECUTABLE_SWITCH);
    Parse_WithStmt;
    Dec(EXECUTABLE_SWITCH);
  end
  else if IsCurrText('Print') then
  begin
    Inc(EXECUTABLE_SWITCH);
    Match('Print');
    Parse_PrintStmt;
    MatchStatementTerminator;
    Dec(EXECUTABLE_SWITCH);
  end
  else if IsCurrText('Println') then
  begin
    Inc(EXECUTABLE_SWITCH);
    Match('Println');
    Parse_PrintlnStmt;
    MatchStatementTerminator;
    Dec(EXECUTABLE_SWITCH);
  end
  else if IsCurrText('Return') then
  begin
    Inc(EXECUTABLE_SWITCH);
    Parse_ReturnStmt;
    Dec(EXECUTABLE_SWITCH);
  end
  else
  begin
    Inc(EXECUTABLE_SWITCH);
    Parse_AssignmentStmt;
    Dec(EXECUTABLE_SWITCH);
  end;
end;

procedure TBasicParser.Parse_Statements;
begin
  repeat
    if IsEOF then
      break;
    if IsCurrText('End') then
      break;
		if IsCurrText('Else') then
			break;
		if IsCurrText('ElseIf') then
			break;
		if IsCurrText('Case') then
			break;
		if IsCurrText('Loop') then
			break;
		if IsCurrText('Next') then
			break;
		if IsCurrText('Finally') then
			break;
		if IsCurrText('Catch') then
			break;
    while IsLineTerminator do
      MatchLineTerminator;

     Parse_Statement;
  until false;
end;

procedure TBasicParser.Parse_NamespaceDeclaration;
var
  l: TIntegerList;
  i, namespace_id: Integer;
begin
  DECLARE_SWITCH := true;
	Match('Namespace');

  MatchLineTerminator;

  l := TIntegerList.Create;

  repeat // ParseQualifiedIdentifier
    namespace_id := Parse_Ident;
    l.Add(namespace_id);
    BeginNamespace(namespace_id);
    if NotMatch('.') then
      break;
  until false;

  // Parse namespace body

  repeat
    if IsEOF then
      Match('End');
    if IsCurrText('End') then
      break;
    if IsLineTerminator then
      MatchLineTerminator
    else
      Parse_NamespaceMemberDeclaration;
  until false;

  for i := l.Count - 1 downto 0 do
    EndNamespace(l[i]);

  Match('End');
  Match('Namespace');
  MatchLineTerminator();
end;

procedure TBasicParser.Parse_ModuleDeclaration;
var
  l: TIntegerList;
  i, namespace_id, B1, B2: Integer;
begin
  l := TIntegerList.Create;

  try

    DECLARE_SWITCH := true;
    Match('Module');

    repeat // ParseQualifiedIdentifier
      namespace_id := Parse_Ident;
      l.Add(namespace_id);
      BeginNamespace(namespace_id);
      if NotMatch('.') then
        break;
    until false;

    MatchLineTerminator;

    while IsCurrText('Imports') do
      Parse_ImportsClause;

    Gen(OP_END_IMPORT, 0, 0, 0);

    B1 := CodeCard;

    // Parse module body
    ParsesModuleBody := true;

    repeat
      if IsEOF then
        Match('End');
      if IsCurrText('End') then
        break;
      if IsLineTerminator then
        MatchLineTerminator
      else
        Parse_NamespaceMemberDeclaration;
    until false;

    ParsesModuleBody := false;

    for i := l.Count - 1 downto 0 do
      EndNamespace(l[i]);

    Gen(OP_END_INTERFACE_SECTION, CurrModule.ModuleNumber, 0, 0);

    B2 := CodeCard;

    BeginFinalization;

    Gen(OP_BEGIN_GLOBAL_BLOCK, 0, 0, 0);
    Gen(OP_NOP, 0, 0, 0);

    Gen(OP_EPILOGUE_GLOBAL_BLOCK, 0, 0, 0);
    Gen(OP_NOP, 0, 0, 0);
    Gen(OP_NOP, 0, 0, 0);
    Gen(OP_EPILOGUE_GLOBAL_BLOCK2, 0, 0, 0);

    GenDestroyGlobalDynamicVariables(B1, B2);

    Gen(OP_NOP, 0, 0, 0);
    Gen(OP_NOP, 0, 0, 0);
    Gen(OP_NOP, 0, 0, 0);
    Gen(OP_NOP, 0, 0, 0);
    Gen(OP_END_GLOBAL_BLOCK, 0, 0, 0);

    EndFinalization;

    Match('End');
    Match('Module');
    MatchLineTerminator();

  finally
    l.Free;
  end;
end;

procedure TBasicParser.Parse_ImportsClause;
var
  unit_id, id: Integer;
  S: String;
  AlreadyExists: Boolean;
  L: TStringList;
begin
  DECLARE_SWITCH := false;
	Match('Imports');

  L := TStringList.Create;

  try
    repeat
      if L.IndexOf(Uppercase(CurrToken.Text)) >= 0 then
        CreateError(errRedeclaredIdentifier, [CurrToken.Text]);
      L.Add(Uppercase(CurrToken.Text));

      unit_id := Parse_QualId;

      AlreadyExists := GetKind(unit_id) = kindNAMESPACE;

      Gen(OP_BEGIN_USING, unit_id, 0, 0);

      if IsCurrText('From') then
      begin
        Call_SCANNER;
        id := Parse_PCharLiteral;
        S := GetValue(id);

        AlreadyExists := false;
      end
      else
        S := GetName(unit_id) + '.' + GetFileExt;

      if not AlreadyExists then
        AddModuleFromFile(S, unit_id, false);

      if NotMatch(',') then
        Break;
    until false;

  finally
    L.Free;
  end;

  MatchLineTerminator;
end;

procedure TBasicParser.Parse_NamespaceMemberDeclaration;
var
  ml: TBasicModifierList;
begin
  ml := Parse_VisibilityModifierList;

  if IsCurrText('Structure') then
    Parse_StructureTypeDeclaration(ml)
  else if IsCurrText('Class') then
    Parse_ClassTypeDeclaration(ml)
  else if IsCurrText('Enum') then
    Parse_EnumTypeDeclaration(ml)
  else if IsCurrText('Sub') then
    Parse_SubDeclaration(ml)
  else if IsCurrText('Function') then
    Parse_FunctionDeclaration(ml)
  else if IsCurrText('Declare') then
  begin
    Call_SCANNER;
    if IsCurrText('Sub') then
      Parse_ExternalSubDeclaration(ml)
    else if IsCurrText('Function') then
      Parse_ExternalFunctionDeclaration(ml)
    else
      Match('Sub');
  end
  else if IsCurrText('Dim') then
    Parse_DimStmt(ml)
  else if IsCurrText('Const') then
    Parse_ConstStmt(ml)
  else
    Parse_DimStmt(ml)
end;

procedure TBasicParser.Parse_StructureTypeDeclaration;

var
  ml: TBasicModifierList;
  SubId, StructTypeId: Integer;
  HasConstructor, HasDestructor: Boolean;
  InitIds: TIntegerList;

  procedure Parse_MethodBody(L: TIntegerList = nil);
  var
    I: Integer;
  begin
    DECLARE_SWITCH := false;
    SetName(CurrSelfId, 'Me');
    SetVisibility(SubId, cvPUBLIC);
    if modPRIVATE in ml then
      SetVisibility(SubId, cvPRIVATE);
    if modPUBLIC in ml then
      SetVisibility(SubId, cvPUBLIC);
    if modPROTECTED in ml then
      SetVisibility(SubId, cvPROTECTED);
    if modPUBLISHED in ml then
      SetVisibility(SubId, cvPUBLISHED);
    if modOVERRIDABLE in ml then
      SetCallMode(SubId, cmVIRTUAL);
    if modOVERRIDES in ml then
      SetCallMode(SubId, cmOVERRIDE);
    if modOVERLOADS in ml then
      SetOverloaded(SubId);

    Gen(OP_BEGIN_WITH, CurrSelfId, 0, 0);
    WithStack.Push(CurrSelfId);
    Gen(OP_STMT, 0, 0, 0);

    if L <> nil then
      for I := 0 to L.Count - 1 do
      begin
        Gen(OP_PUSH_INSTANCE, CurrSelfId, 0, L[I]);
        Gen(OP_CALL, L[I], 0, 0);
      end;

    Inc(EXECUTABLE_SWITCH);
    MatchLineTerminator;
    Parse_Statements;
    Dec(EXECUTABLE_SWITCH);

    Gen(OP_END_WITH, WithStack.Top, 0, 0);
    WithStack.Pop;
    DECLARE_SWITCH := true;
  end;

  procedure Parse_SubMethodDeclaration;
  var
    NP: Integer;
  begin
    DECLARE_SWITCH := true;
    Match('Sub');

    if IsCurrText('New') then
    begin
      HasConstructor := true;
      Match('New');
      SubId := NewTempVar;
      BeginStructureConstructor(SubId, StructTypeId);

      NP := 0;
      SetCount(SubId, NP);
      InitSub(SubId);
      Parse_MethodBody(InitIDs);
      EndSub(SubId);
      Match('End');
      Match('Sub');
    end
    else if IsCurrText('Finalize') then
    begin
      HasDestructor := true;

      Match('Finalize');
      SubId := NewTempVar;
      BeginStructureDestructor(SubId, StructTypeId);

      NP := 0;
      SetCount(SubId, NP);
      InitSub(SubId);
      Parse_MethodBody;
      EndSub(SubId);
      Match('End');
      Match('Sub');
    end
    else
    begin
      SubId := Parse_Ident;
      BeginStructureMethod(SubId, StructTypeId, false, modSHARED in ml);

      if IsCurrText('(') then
        NP := Parse_FormalParameterList(SubId)
      else
        NP := 0;

      SetCount(SubId, NP);
      SetName(CurrResultId, '');
      SetKind(CurrResultId, KindNONE);
      Gen(OP_ASSIGN_TYPE, SubId, TypeVOID, 0);
      Gen(OP_ASSIGN_TYPE, CurrResultId, TypeVOID, 0);

      InitSub(SubId);
      Parse_MethodBody;

      EndSub(SubId);
      Match('End');
      Match('Sub');
    end;
  end;

  procedure Parse_FunctionMethodDeclaration;
  var
    TypeId, NP: Integer;
  begin
    DECLARE_SWITCH := true;
    Match('function');
    SubId := Parse_Ident;
    BeginStructureMethod(SubId, StructTypeId, true, modSHARED in ml);
    SetName(CurrResultId, '');
    if IsCurrText('(') then
      NP := Parse_FormalParameterList(SubId)
    else
      NP := 0;
    SetCount(SubId, NP);
    DECLARE_SWITCH := false;
    if IsCurrText('As') then
    begin
      Match('As');
      TypeID := Parse_Type;
    end
    else
      TypeId := typeVARIANT;
    Gen(OP_ASSIGN_TYPE, SubId, TypeID, 0);
    Gen(OP_ASSIGN_TYPE, CurrResultId, TypeID, 0);

    InitSub(SubId);
    Parse_MethodBody;
    EndSub(SubId);
    Match('End');
    Match('Function');
  end;

  procedure Parse_PropertyDeclaration;

    var
      ParamIds, TypeIds, ByRefIds: TIntegerList;

    function Parse_ParamList: Integer;
    begin
      DECLARE_SWITCH := true;
      Match('(');
      result := 0;

      repeat
        if IsCurrText('ByRef') then
        begin
          Match('ByRef');
          ByRefIds.Add(Integer(true));
        end
        else if IsCurrText('ByVal') then
        begin
          Match('ByVal');
          ByRefIds.Add(Integer(false));
        end
        else
          ByRefIds.Add(Integer(false));

        Inc(result);
        ParamIds.Add(Parse_Ident);

        if IsCurrText('As') then
        begin
          DECLARE_SWITCH := false;
          Match('As');
          TypeIds.Add(Parse_Type);
          DECLARE_SWITCH := true;
        end
        else
          TypeIds.Add(typeVARIANT);

        if NotMatch(',') then
          Break;
      until false;
      Match(')');
    end;

  var
    PropId, PropTypeId, NP, ReadId, WriteId, I, ParamId: Integer;
  begin
    DECLARE_SWITCH := true;
    Match('property');

    PropId := Parse_Ident;
    BeginProperty(PropId, StructTypeId);

    if modPRIVATE in ml then
      SetVisibility(PropId, cvPRIVATE);
    if modPUBLIC in ml then
      SetVisibility(PropId, cvPUBLIC);
    if modPROTECTED in ml then
      SetVisibility(PropId, cvPROTECTED);
    if modPUBLISHED in ml then
      SetVisibility(PropId, cvPUBLISHED);

    ParamIds := TIntegerList.Create;
    TypeIds := TIntegerList.Create;
    ByRefIds := TIntegerList.Create;

    try
      if IsCurrText('(') then
        NP := Parse_ParamList
      else
        NP := 0;
      SetCount(PropId, NP);

      if IsCurrText('As') then
      begin
        DECLARE_SWITCH := false;
        Match('As');
        DECLARE_SWITCH := true;
        PropTypeId := Parse_Ident;
      end
      else
        PropTypeId := typeVARIANT;
      Gen(OP_ASSIGN_TYPE, PropId, PropTypeID, 0);

      ReadId := 0;
      WriteId := 0;

      MatchLineTerminator;

      while IsCurrText('Get') or IsCurrText('Set') do
      begin
        if IsCurrText('Get') then
        begin
          if ReadId <> 0 then
            RaiseError(errSyntaxError, []);

          Match('Get');
          SubId := NewTempVar;
          ReadId := SubId;
          SetReadId(PropId, ReadId);

          BeginStructureMethod(SubId, StructTypeId, true, modSHARED in ml);

          for I := 0 to ParamIds.Count - 1 do
          begin
            ParamId := NewTempVar;
            SetParam(ParamId, true);
            SetName(ParamId, GetName(ParamIds[I]));
            Gen(OP_ASSIGN_TYPE, ParamId, TypeIds[I], 0);
            if ByRefIds[I] > 0 then
              SetByRef(PropId);
          end;

          SetCount(SubId, NP);
          DECLARE_SWITCH := false;
          Gen(OP_ASSIGN_TYPE, SubId, PropTypeID, 0);
          Gen(OP_ASSIGN_TYPE, CurrResultId, PropTypeID, 0);

          InitSub(SubId);
          Parse_MethodBody;
          EndSub(SubId);
          Match('End');
          Match('Get');
          MatchLineTerminator;
        end
        else
        begin
          if WriteId <> 0 then
            RaiseError(errSyntaxError, []);

          Match('Set');
          SubId := NewTempVar;
          WriteId := SubId;
          SetWriteId(PropId, WriteId);

          BeginStructureMethod(SubId, StructTypeId, true, modSHARED in ml);

          for I := 0 to ParamIds.Count - 1 do
          begin
            ParamId := NewTempVar;
            SetParam(ParamId, true);
            SetName(ParamId, GetName(ParamIds[I]));
            Gen(OP_ASSIGN_TYPE, ParamId, TypeIds[I], 0);
            if ByRefIds[I] > 0 then
              SetByRef(PropId);
          end;

          if IsCurrText('(') then
            Inc(NP, Parse_FormalParameterList(SubId))
          else
          begin
            ParamId := NewTempVar;
            SetParam(ParamId, true);
            SetName(ParamId, 'value');
            Gen(OP_ASSIGN_TYPE, ParamId, PropTypeId, 0);
            Inc(NP, 1);
          end;

          SetCount(SubId, NP);
          SetName(CurrResultId, '');
          SetKind(CurrResultId, KindNONE);
          SetType(SubId, TypeVOID);
          SetType(CurrResultId, TypeVOID);

          InitSub(SubId);
          Parse_MethodBody;
          EndSub(SubId);
          Match('End');
          Match('Set');
          MatchLineTerminator;
        end;
      end;

    finally
      ParamIds.Free;
      TypeIds.Free;
      ByRefIds.Free;
    end;

    EndProperty(PropId);
    Match('End');
    Match('Property');
  end;

var
  Id, TypeID, TempId, ConstId, ArrayTypeId, LengthId: Integer;
  IsArray: Boolean;
begin
  InitIds := TIntegerList.Create;
  try
    DECLARE_SWITCH := true;
    Match('Structure');
    StructTypeID := Parse_Ident;
    BeginRecordType(StructTypeID);
    MatchLineTerminator;

    SetPacked(StructTypeID);

    HasConstructor := false;
    HasDestructor := false;

    repeat
      if IsCurrText('End') then
        Break;

      if IsEOF then
        Break;

      if not IsLineTerminator then
      begin
        ml := Parse_ModifierList;

        Gen(OP_STMT, 0, 0, 0);
        if IsCurrText('Sub') then
        begin
          Parse_SubMethodDeclaration;
        end
        else if IsCurrText('Function') then
        begin
          Parse_FunctionMethodDeclaration;
        end
        else if IsCurrText('Property') then
        begin
          Parse_PropertyDeclaration;
        end
        else
        begin
          Id := Parse_Ident;
          DECLARE_SWITCH := false;

          if modPRIVATE in ml then
            SetVisibility(Id, cvPRIVATE);
          if modPUBLIC in ml then
            SetVisibility(Id, cvPUBLIC);
          if modPROTECTED in ml then
            SetVisibility(Id, cvPROTECTED);
          if modPUBLISHED in ml then
            SetVisibility(Id, cvPUBLISHED);

          if IsCurrText('(') then
          begin
            Match('(');
            ConstId := Parse_Expression;
            Match(')');
            IsArray := true;
          end
          else
          begin
            IsArray := false;
            ConstId := 0;
          end;

          Match('As');
          TypeID := Parse_Type;
          SetKind(Id, KindTYPE_FIELD);

          if IsArray then
          begin
            ArrayTypeId := NewTempVar;
            BeginDynamicArrayType(ArrayTypeID);
            Gen(OP_CREATE_DYNAMIC_ARRAY_TYPE, ArrayTypeId, TypeID, 0);
            EndDynamicArrayType(ArrayTypeID);
            Gen(OP_ADD_TYPEINFO, ArrayTypeId, 0, 0);

            Gen(OP_ASSIGN_TYPE, ID, ArrayTypeID, 0);

            LengthId := NewTempVar(typeINTEGER);
            Gen(OP_PLUS, ConstId, NewConst(typeINTEGER, 1), LengthId);

            SubId := NewTempVar;
            BeginStructureMethod(SubId, StructTypeId, false, modSHARED in ml);
            SetCount(SubId, 0);
            SetName(CurrResultId, '');
            SetKind(CurrResultId, KindNONE);
            SetType(SubId, TypeVOID);
            SetType(CurrResultId, TypeVOID);

            InitSub(SubId);

            DECLARE_SWITCH := false;
            SetName(CurrSelfId, 'Me');
            Gen(OP_BEGIN_WITH, CurrSelfId, 0, 0);
            WithStack.Push(CurrSelfId);
            Gen(OP_STMT, 0, 0, 0);
            TempId := NewTempVar;
            SetName(TempId, GetName(Id));

            // body
            Gen(OP_EVAL, 0, 0, TempId);
            Gen(OP_SET_LENGTH, TempId, LengthId, 0);

            Gen(OP_END_WITH, WithStack.Top, 0, 0);
            WithStack.Pop;
            DECLARE_SWITCH := true;

            EndSub(SubId);

            InitIds.Add(SubId);
          end
          else
            Gen(OP_ASSIGN_TYPE, ID, TypeID, 0);

          if IsCurrText('=') then
          begin
            Match('=');
            SubId := NewTempVar;
            BeginStructureMethod(SubId, StructTypeId, false, modSHARED in ml);
            SetCount(SubId, 0);
            SetName(CurrResultId, '');
            SetKind(CurrResultId, KindNONE);
            SetType(SubId, TypeVOID);
            SetType(CurrResultId, TypeVOID);

            InitSub(SubId);

            DECLARE_SWITCH := false;
            SetName(CurrSelfId, 'Me');
            Gen(OP_BEGIN_WITH, CurrSelfId, 0, 0);
            WithStack.Push(CurrSelfId);
            Gen(OP_STMT, 0, 0, 0);
            TempId := NewTempVar;
            SetName(TempId, GetName(Id));

            // body
            Gen(OP_EVAL, 0, 0, TempId);
            Gen(OP_ASSIGN, TempId, Parse_Expression, TempId);

            Gen(OP_END_WITH, WithStack.Top, 0, 0);
            WithStack.Pop;
            DECLARE_SWITCH := true;

            EndSub(SubId);

            InitIds.Add(SubId);
          end;
        end;
      end;

      DECLARE_SWITCH := true;
      MatchLineTerminator;

    until false;

    if not HasConstructor then
      GenDefaultStructureConstructor(StructTypeId, InitIds);
    if not HasDestructor then
      GenDefaultStructureDestructor(StructTypeId);

    EndRecordType(StructTypeId);

    Match('End');
    Match('Structure');

    DECLARE_SWITCH := false;
    MatchLineTerminator;

  finally
    InitIds.Free;
  end;
  Gen(OP_ADD_TYPEINFO, StructTypeId, 0, 0);
end;

function TBasicParser.Parse_ModifierList: TBasicModifierList;
begin
  result := [];

  repeat

    if IsCurrText('default') then
    begin
      result := result + [modDEFAULT];
      Call_SCANNER;
    end
    else if IsCurrText('public') then
    begin
      result := result + [modPUBLIC];
      Call_SCANNER;
    end
    else if IsCurrText('published') then
    begin
      result := result + [modPUBLISHED];
      Call_SCANNER;
    end
    else if IsCurrText('private') then
    begin
      result := result + [modPRIVATE];
{
      if NextToken.TokenClass <> tcKeyword then
      begin
        CurrToken.Text := NextToken.Text;
        CurrToken.Text := 'Dim';
        Exit;
      end;
}
      Call_SCANNER;
    end
    else if IsCurrText('protected') then
    begin
      result := result + [modPROTECTED];
      Call_SCANNER;
    end
    else if IsCurrText('shared') then
    begin
      result := result + [modSHARED];
      Call_SCANNER;
    end
    else if IsCurrText('overridable') then
    begin
      result := result + [modOVERRIDABLE];
      Call_SCANNER;
    end
    else if IsCurrText('notoverridable') then
    begin
      result := result + [modNOTOVERRIDABLE];
      Call_SCANNER;
    end
    else if IsCurrText('mustoverride') then
    begin
      result := result + [modMUSTOVERRIDE];
      Call_SCANNER;
    end
    else if IsCurrText('overrides') then
    begin
      result := result + [modOVERRIDES];
      Call_SCANNER;
    end
    else if IsCurrText('overloads') then
    begin
      result := result + [modOVERLOADS];
      Call_SCANNER;
    end
    else if IsCurrText('readonly') then
    begin
      result := result + [modREADONLY];
      Call_SCANNER;
    end
    else if IsCurrText('friend') then
    begin
      result := result + [modFRIEND];
      Call_SCANNER;
    end
    else if IsCurrText('mustinherit') then
    begin
      result := result + [modMUSTINHERIT];
      Call_SCANNER;
    end
    else if IsCurrText('shadows') then
    begin
      result := result + [modSHADOWS];
      Call_SCANNER;
    end
    else if IsCurrText('notinheritable') then
    begin
      result := result + [modNOTINHERITABLE];
      Call_SCANNER;
    end
    else if IsCurrText('withevents') then
    begin
      result := result + [modWITHEVENTS];
      Call_SCANNER;
    end
    else if IsCurrText('internal') then
    begin
      result := result + [modINTERNAL];
      Call_SCANNER;
    end
    else
      Exit;

  until false;
end;

procedure TBasicParser.Parse_CallConvention(SubId: Integer; IsDeclaredProc: Boolean);
begin
  if IsCurrText('Register') then
  begin
    SetCallConvention(SubId, ccREGISTER);
    Call_SCANNER;
  end
  else if IsCurrText('StdCall') then
  begin
    SetCallConvention(SubId, ccSTDCALL);
    Call_SCANNER;
  end
  else if IsCurrText('CDecl') then
  begin
    SetCallConvention(SubId, ccCDECL);
    Call_SCANNER;
  end
  else if IsCurrText('Pascal') then
  begin
    SetCallConvention(SubId, ccPASCAL);
    Call_SCANNER;
  end
  else if IsCurrText('SafeCall') then
  begin
    SetCallConvention(SubId, ccSAFECALL);
    Call_SCANNER;
  end
  else if IsCurrText('MSFastCall') then
  begin
    SetCallConvention(SubId, ccMSFASTCALL);
    Call_SCANNER;
  end
  else if IsDeclaredProc then
    SetCallConvention(SubId, DeclareCallConv);
end;

function TBasicParser.Parse_VisibilityModifierList: TBasicModifierList;
begin
  result := [modPUBLIC];

  repeat

    if IsCurrText('public') then
    begin
      DECLARE_SWITCH := true;
      result := result + [modPUBLIC];
      Call_SCANNER;
    end
    else if IsCurrText('published') then
    begin
      DECLARE_SWITCH := true;
      result := result + [modPUBLISHED];
      Call_SCANNER;
    end
    else if IsCurrText('private') then
    begin
      DECLARE_SWITCH := true;
      result := result + [modPRIVATE];
{
      if NextToken.TokenClass <> tcKeyword then
      begin
        CurrToken.Text := NextToken.Text;
        CurrToken.Text := 'Dim';
        Exit;
      end;
}
      Call_SCANNER;
    end
    else if IsCurrText('protected') then
    begin
      DECLARE_SWITCH := true;
      result := result + [modPROTECTED];
      Call_SCANNER;
    end
    else if IsCurrText('internal') then
    begin
      DECLARE_SWITCH := true;
      result := result + [modINTERNAL];
      Call_SCANNER;
    end
    else
      Exit;

  until false;
end;

procedure TBasicParser.Parse_ClassTypeDeclaration;

var
  ml: TBasicModifierList;
  SubId, ClassTypeId: Integer;
  HasConstructor, HasDestructor: Boolean;
  InitIds: TIntegerList;

  procedure Parse_MethodBody(L: TIntegerList = nil);
  var
    I: Integer;
  begin
    Inc(EXECUTABLE_SWITCH);
    DECLARE_SWITCH := false;
    SetName(CurrSelfId, 'Me');
    SetVisibility(SubId, cvPUBLIC);
    if modPRIVATE in ml then
      SetVisibility(SubId, cvPRIVATE);
    if modPUBLIC in ml then
      SetVisibility(SubId, cvPUBLIC);
    if modPROTECTED in ml then
      SetVisibility(SubId, cvPROTECTED);
    if modPUBLISHED in ml then
      SetVisibility(SubId, cvPUBLISHED);
    if modOVERRIDABLE in ml then
      SetCallMode(SubId, cmVIRTUAL);
    if modOVERRIDES in ml then
      SetCallMode(SubId, cmOVERRIDE);
    if modOVERLOADS in ml then
      SetOverloaded(SubId);

    Gen(OP_BEGIN_WITH, CurrSelfId, 0, 0);
    WithStack.Push(CurrSelfId);
    Gen(OP_STMT, 0, 0, 0);

    if L <> nil then
      for I := 0 to L.Count - 1 do
      begin
        Gen(OP_PUSH_INSTANCE, CurrSelfId, 0, L[I]);
        Gen(OP_CALL, L[I], 0, 0);
      end;

    MatchLineTerminator;
    Parse_Statements;

    Gen(OP_END_WITH, WithStack.Top, 0, 0);
    WithStack.Pop;
    DECLARE_SWITCH := true;
    Dec(EXECUTABLE_SWITCH);
  end;

  procedure Parse_SubMethodDeclaration;
  var
    NP, L: Integer;
  begin
    DECLARE_SWITCH := true;
    Match('Sub');

    if IsCurrText('New') then
    begin
      HasConstructor := true;
      Match('New');
      SubId := NewTempVar;
      BeginClassConstructor(SubId, ClassTypeId);
      SetVisibility(SubId, cvPublic);

      if IsCurrText('(') then
        NP := Parse_FormalParameterList(SubId)
      else
        NP := 0;

      SetCount(SubId, NP);

      InitSub(SubId);

      WasInherited := false;

      Gen(OP_SAVE_EDX, 0, 0, 0);
      L := NewLabel;
      Gen(OP_GO_DL, L, 0, 0);
      Gen(OP_CREATE_OBJECT, ClassTypeId, 0, CurrSelfId);
      SetLabelHere(L);

      Parse_MethodBody(InitIDs);

      if not WasInherited then
        CreateError(errTheCallOfInheritedConstructorIsMandatory, []);

      Gen(OP_RESTORE_EDX, 0, 0, 0);
      L := NewLabel;
      Gen(OP_GO_DL, L, 0, 0);
      Gen(OP_ON_AFTER_OBJECT_CREATION, CurrSelfId, 0, 0);
      SetLabelHere(L);

      EndSub(SubId);
      Match('End');
      Match('Sub');
    end
    else if IsCurrText('Finalize') then
    begin
      HasDestructor := true;

      Match('Finalize');
      SubId := NewTempVar;
      BeginClassDestructor(SubId, ClassTypeId);
      SetVisibility(SubId, cvPublic);

      NP := 0;
      SetCount(SubId, NP);

      InitSub(SubId);
      Parse_MethodBody;
      EndSub(SubId);
      Match('End');
      Match('Sub');
    end
    else
    begin
      SubId := Parse_Ident;
      BeginClassMethod(SubId, ClassTypeId, false, modSHARED in ml);

      if IsCurrText('(') then
        NP := Parse_FormalParameterList(SubId)
      else
        NP := 0;

      SetCount(SubId, NP);
      SetName(CurrResultId, '');
      SetKind(CurrResultId, KindNONE);
      Gen(OP_ASSIGN_TYPE, SubId, TypeVOID, 0);
      Gen(OP_ASSIGN_TYPE, CurrResultId, TypeVOID, 0);

      InitSub(SubId);
      Parse_MethodBody;

      EndSub(SubId);
      Match('End');
      Match('Sub');
    end;
  end;

  procedure Parse_FunctionMethodDeclaration;
  var
    TypeId, NP: Integer;
  begin
    DECLARE_SWITCH := true;
    Match('function');
    SubId := Parse_Ident;
    BeginClassMethod(SubId, ClassTypeId, true, modSHARED in ml);
    SetName(CurrResultId, '');
    if IsCurrText('(') then
      NP := Parse_FormalParameterList(SubId)
    else
      NP := 0;
    SetCount(SubId, NP);
    DECLARE_SWITCH := false;
    if IsCurrText('As') then
    begin
      Match('As');
      TypeID := Parse_Type;
    end
    else
      TypeId := typeVARIANT;
    Gen(OP_ASSIGN_TYPE, SubId, TypeID, 0);
    Gen(OP_ASSIGN_TYPE, CurrResultId, TypeID, 0);

    InitSub(SubId);
    Parse_MethodBody;
    EndSub(SubId);
    Match('End');
    Match('Function');
  end;

  procedure Parse_PropertyDeclaration;

    var
      ParamIds, TypeIds, ByRefIds: TIntegerList;

    function Parse_ParamList: Integer;
    begin
      DECLARE_SWITCH := true;
      Match('(');
      result := 0;

      repeat
        if IsCurrText('ByRef') then
        begin
          Match('ByRef');
          ByRefIds.Add(Integer(true));
        end
        else if IsCurrText('ByVal') then
        begin
          Match('ByVal');
          ByRefIds.Add(Integer(false));
        end
        else
          ByRefIds.Add(Integer(false));

        Inc(result);
        ParamIds.Add(Parse_Ident);

        if IsCurrText('As') then
        begin
          DECLARE_SWITCH := false;
          Match('As');
          TypeIds.Add(Parse_Type);
          DECLARE_SWITCH := true;
        end
        else
          TypeIds.Add(typeVARIANT);

        if NotMatch(',') then
          Break;
      until false;
      Match(')');
    end;

  var
    PropId, PropTypeId, NP, ReadId, WriteId, I, ParamId: Integer;
  begin
    DECLARE_SWITCH := true;
    Match('property');

    PropId := Parse_Ident;
    BeginProperty(PropId, ClassTypeId);

    if modPRIVATE in ml then
      SetVisibility(PropId, cvPRIVATE);
    if modPUBLIC in ml then
      SetVisibility(PropId, cvPUBLIC);
    if modPROTECTED in ml then
      SetVisibility(PropId, cvPROTECTED);
    if modPUBLISHED in ml then
      SetVisibility(PropId, cvPUBLISHED);

    ParamIds := TIntegerList.Create;
    TypeIds := TIntegerList.Create;
    ByRefIds := TIntegerList.Create;

    try
      if IsCurrText('(') then
        NP := Parse_ParamList
      else
        NP := 0;
      SetCount(PropId, NP);

      if IsCurrText('As') then
      begin
        DECLARE_SWITCH := false;
        Match('As');
        DECLARE_SWITCH := true;
        PropTypeId := Parse_Ident;
      end
      else
        PropTypeId := typeVARIANT;
      Gen(OP_ASSIGN_TYPE, PropId, PropTypeID, 0);

      ReadId := 0;
      WriteId := 0;

      ml := [ModPRIVATE];

      MatchLineTerminator;

      while IsCurrText('Get') or IsCurrText('Set') do
      begin
        if IsCurrText('Get') then
        begin
          if ReadId <> 0 then
            RaiseError(errSyntaxError, []);

          Match('Get');
          SubId := NewTempVar;
          ReadId := SubId;
          SetReadId(PropId, ReadId);

          SetName(SubId, '__get' + GetName(PropId));

          BeginClassMethod(SubId, ClassTypeId, true, modSHARED in ml);

          for I := 0 to ParamIds.Count - 1 do
          begin
            ParamId := NewTempVar;
            SetParam(ParamId, true);
            SetName(ParamId, GetName(ParamIds[I]));
            Gen(OP_ASSIGN_TYPE, ParamId, TypeIds[I], 0);
            if ByRefIds[I] > 0 then
              SetByRef(PropId);
          end;

          SetCount(SubId, NP);
          DECLARE_SWITCH := false;
          Gen(OP_ASSIGN_TYPE, SubId, PropTypeID, 0);
          Gen(OP_ASSIGN_TYPE, CurrResultId, PropTypeID, 0);

          InitSub(SubId);
          Parse_MethodBody;
          EndSub(SubId);
          Match('End');
          Match('Get');
          MatchLineTerminator;
        end
        else
        begin
          if WriteId <> 0 then
            RaiseError(errSyntaxError, []);

          Match('Set');
          SubId := NewTempVar;
          WriteId := SubId;
          SetWriteId(PropId, WriteId);

          SetName(SubId, '__set' + GetName(PropId));

          BeginClassMethod(SubId, ClassTypeId, true, modSHARED in ml);

          for I := 0 to ParamIds.Count - 1 do
          begin
            ParamId := NewTempVar;
            SetParam(ParamId, true);
            SetName(ParamId, GetName(ParamIds[I]));
            Gen(OP_ASSIGN_TYPE, ParamId, TypeIds[I], 0);
            if ByRefIds[I] > 0 then
              SetByRef(PropId);
          end;

          if IsCurrText('(') then
            Inc(NP, Parse_FormalParameterList(SubId))
          else
          begin
            ParamId := NewTempVar;
            SetParam(ParamId, true);
            SetName(ParamId, 'value');
            Gen(OP_ASSIGN_TYPE, ParamId, PropTypeId, 0);
            Inc(NP, 1);
          end;

          SetCount(SubId, NP);
          SetName(CurrResultId, '');
          SetKind(CurrResultId, KindNONE);
          SetType(SubId, TypeVOID);
          SetType(CurrResultId, TypeVOID);

          InitSub(SubId);
          Parse_MethodBody;
          EndSub(SubId);
          Match('End');
          Match('Set');
          MatchLineTerminator;
        end;
      end;

    finally
      ParamIds.Free;
      TypeIds.Free;
      ByRefIds.Free;
    end;

    EndProperty(PropId);
    Match('End');
    Match('Property');
  end;

var
  Id, TypeID, TempId, ConstId, ArrayTypeId, LengthId, AncestorId: Integer;
  IsArray: Boolean;
begin
  InitIds := TIntegerList.Create;
  try
    DECLARE_SWITCH := true;
    Match('Class');
    ClassTypeID := Parse_Ident;
    BeginClassType(ClassTypeID);
    MatchLineTerminator;

    SetPacked(ClassTypeID);

    HasConstructor := false;
    HasDestructor := false;

    if IsCurrText('Inherits') then
    begin
      DECLARE_SWITCH := false;
      Match('Inherits');
      Gen(OP_ADD_ANCESTOR, ClassTypeId, Parse_Ident, 0);

      if IsCurrText(',') then
      begin
        Call_SCANNER;
        repeat
           AncestorId := Parse_Ident;
           Gen(OP_ADD_INTERFACE, ClassTypeId, AncestorId, 0);
          if NotMatch(',') then
            break;
        until false;
      end;

      DECLARE_SWITCH := true;
      MatchLineTerminator;
    end
    else
      Gen(OP_ADD_ANCESTOR, ClassTypeId, H_TObject, 0);

    repeat

      if IsCurrText('End') then
        Break;

      if IsEOF then
        Break;

      if not IsLineTerminator then
      begin
        ml := Parse_ModifierList;

        Gen(OP_STMT, 0, 0, 0);
        if IsCurrText('Sub') then
        begin
          Parse_SubMethodDeclaration;
        end
        else if IsCurrText('Function') then
        begin
          Parse_FunctionMethodDeclaration;
        end
        else if IsCurrText('Property') then
        begin
          Parse_PropertyDeclaration;
        end
        else
        begin
          if IsCurrText('Dim') then
            Call_SCANNER
          else if IsCurrText('Const') then
            Call_SCANNER;

          Id := Parse_Ident;
          DECLARE_SWITCH := false;

          if modPRIVATE in ml then
            SetVisibility(Id, cvPRIVATE);
          if modPUBLIC in ml then
            SetVisibility(Id, cvPUBLIC);
          if modPROTECTED in ml then
            SetVisibility(Id, cvPROTECTED);
          if modPUBLISHED in ml then
            SetVisibility(Id, cvPUBLISHED);

          if IsCurrText('(') then
          begin
            Match('(');
            ConstId := Parse_Expression;
            Match(')');
            IsArray := true;
          end
          else
          begin
            IsArray := false;
            ConstId := 0;
          end;

          Match('As');
          TypeID := Parse_Type;
          SetKind(Id, KindTYPE_FIELD);

          if IsArray then
          begin
            ArrayTypeId := NewTempVar;
            BeginDynamicArrayType(ArrayTypeID);
            Gen(OP_CREATE_DYNAMIC_ARRAY_TYPE, ArrayTypeId, TypeID, 0);
            EndDynamicArrayType(ArrayTypeID);
            Gen(OP_ADD_TYPEINFO, ArrayTypeId, 0, 0);

            Gen(OP_ASSIGN_TYPE, ID, ArrayTypeID, 0);

            LengthId := NewTempVar(typeINTEGER);
            Gen(OP_PLUS, ConstId, NewConst(typeINTEGER, 1), LengthId);

            SubId := NewTempVar;
            BeginClassMethod(SubId, ClassTypeId, false, modSHARED in ml);
            SetCount(SubId, 0);
            SetName(CurrResultId, '');
            SetKind(CurrResultId, KindNONE);
            SetType(SubId, TypeVOID);
            SetType(CurrResultId, TypeVOID);

            InitSub(SubId);

            DECLARE_SWITCH := false;
            SetName(CurrSelfId, 'Me');
            Gen(OP_BEGIN_WITH, CurrSelfId, 0, 0);
            WithStack.Push(CurrSelfId);
            Gen(OP_STMT, 0, 0, 0);
            TempId := NewTempVar;
            SetName(TempId, GetName(Id));

            // body
            Gen(OP_EVAL, 0, 0, TempId);
            Gen(OP_SET_LENGTH, TempId, LengthId, 0);

            Gen(OP_END_WITH, WithStack.Top, 0, 0);
            WithStack.Pop;
            DECLARE_SWITCH := true;

            EndSub(SubId);

            InitIds.Add(SubId);
          end
          else
            Gen(OP_ASSIGN_TYPE, ID, TypeID, 0);

          if IsCurrText('=') then
          begin
            Match('=');
            SubId := NewTempVar;
            BeginClassMethod(SubId, ClassTypeId, false, modSHARED in ml);
            SetCount(SubId, 0);
            SetName(CurrResultId, '');
            SetKind(CurrResultId, KindNONE);
            SetType(SubId, TypeVOID);
            SetType(CurrResultId, TypeVOID);

            InitSub(SubId);

            DECLARE_SWITCH := false;
            SetName(CurrSelfId, 'Me');
            Gen(OP_BEGIN_WITH, CurrSelfId, 0, 0);
            WithStack.Push(CurrSelfId);
            Gen(OP_STMT, 0, 0, 0);
            TempId := NewTempVar;
            SetName(TempId, GetName(Id));

            // body
            Gen(OP_EVAL, 0, 0, TempId);
            Gen(OP_ASSIGN, TempId, Parse_Expression, TempId);

            Gen(OP_END_WITH, WithStack.Top, 0, 0);
            WithStack.Pop;
            DECLARE_SWITCH := true;

            EndSub(SubId);

            InitIds.Add(SubId);
          end
          else
          begin
            SubId := NewTempVar;
            BeginClassMethod(SubId, ClassTypeId, false, modSHARED in ml);
            SetCount(SubId, 0);
            SetName(CurrResultId, '');
            SetKind(CurrResultId, KindNONE);
            SetType(SubId, TypeVOID);
            SetType(CurrResultId, TypeVOID);

            InitSub(SubId);

            DECLARE_SWITCH := false;
            SetName(CurrSelfId, 'Me');
            Gen(OP_BEGIN_WITH, CurrSelfId, 0, 0);
            WithStack.Push(CurrSelfId);
            Gen(OP_STMT, 0, 0, 0);
            TempId := NewTempVar;
            SetName(TempId, GetName(Id));

            // body
            Gen(OP_EVAL, 0, 0, TempId);
            Gen(OP_CALL_DEFAULT_CONSTRUCTOR, TempID, 0, 0);

            Gen(OP_END_WITH, WithStack.Top, 0, 0);
            WithStack.Pop;
            DECLARE_SWITCH := true;

            EndSub(SubId);

            InitIds.Add(SubId);
          end;


        end;
      end;

      DECLARE_SWITCH := true;
      MatchLineTerminator;

    until false;

    if not HasConstructor then
      GenDefaultClassConstructor(ClassTypeId, InitIds);
    if not HasDestructor then
      GenDefaultClassDestructor(ClassTypeId);

    EndClassType(ClassTypeId);

    Match('End');
    Match('Class');

    DECLARE_SWITCH := false;
    MatchLineTerminator;

  finally
    InitIds.Free;
  end;
  Gen(OP_ADD_TYPEINFO, ClassTypeId, 0, 0);
end;

procedure TBasicParser.Parse_InterfaceTypeDeclaration;
var
  NegativeMethodIndex: Integer;
  IntfTypeId: Integer;

  function Parse_SubHeading: Integer;
  var
    NP: Integer;
  begin
    Dec(NegativeMethodIndex);
    DECLARE_SWITCH := true;
    Match('Sub');
    result := Parse_Ident;
    BeginInterfaceMethod(result, IntfTypeId, false);
    if IsCurrText('(') then
      NP := Parse_FormalParameterList(result)
    else
      NP := 0;
    SetCount(result, NP);
    Gen(OP_ADD_METHOD_INDEX, result, NegativeMethodIndex, 0);
    DECLARE_SWITCH := true;
    MatchLineTerminator;
    EndSub(result);
  end;

  function Parse_FunctionHeading: Integer;
  var
    NP, TypeID: Integer;
  begin
    Dec(NegativeMethodIndex);

    DECLARE_SWITCH := true;
    Match('Function');
    result := Parse_Ident;
    BeginInterfaceMethod(result, IntfTypeId, true);
    SetName(CurrResultId, '');
    if IsCurrText('(') then
      NP := Parse_FormalParameterList(result)
    else
      NP := 0;
    SetCount(result, NP);

    DECLARE_SWITCH := false;
    Match('As');
    TypeID := Parse_Type;
    Gen(OP_ASSIGN_TYPE, result, TypeID, 0);
    Gen(OP_ASSIGN_TYPE, CurrResultId, TypeID, 0);
    Gen(OP_ADD_METHOD_INDEX, result, NegativeMethodIndex, 0);

    DECLARE_SWITCH := true;
    MatchLineTerminator;

    EndSub(result);
  end;

  function Parse_Property: Integer;
  var
    NP, TypeID, ReadId, WriteId: Integer;
  begin
    DECLARE_SWITCH := true;
    Match('property');
    result := Parse_Ident;
    BeginProperty(result, IntfTypeId);
    SetVisibility(result, cvPublic);
    if IsCurrText('[') then
      NP := Parse_FormalParameterList(result)
    else
      NP := 0;
    SetCount(result, NP);

    DECLARE_SWITCH := false;
    Match(':');
    if CurrToken.TokenClass <> tcIdentifier then
      RaiseError(errIdentifierExpected, [CurrToken.Text]);
    TypeID := CurrToken.Id;
    Gen(OP_ASSIGN_TYPE, result, TypeID, 0);

    ReadId := 0;
    WriteId := 0;

    repeat
      ReadToken;

      if IsCurrText('read') and (ReadId = 0) then
      begin
        ReadToken;
        if CurrToken.TokenClass <> tcIdentifier then
          RaiseError(errIdentifierExpected, [CurrToken.Text]);
        ReadId := Lookup(CurrToken.Text, IntfTypeId);
        if ReadId = 0 then
          RaiseError(errUndeclaredIdentifier, [CurrToken.Text]);
        SetReadId(result, ReadId);
      end
      else if IsCurrText('write') and (WriteId = 0) then
      begin
        ReadToken;
        if CurrToken.TokenClass <> tcIdentifier then
          RaiseError(errIdentifierExpected, [CurrToken.Text]);
        WriteId := Lookup(CurrToken.Text, IntfTypeId);
        if WriteId = 0 then
          RaiseError(errUndeclaredIdentifier, [CurrToken.Text]);
        SetWriteId(result, WriteId);
      end
      else
        break;
    until false;

    if IsCurrText(';') then
      ReadToken
    else
      RaiseError(errTokenExpected, [';', CurrToken.Text]);

    if IsCurrText('default') then
    begin
      Call_SCANNER;
      SetDefault(result, true);
    end;

    EndProperty(result);
  end;

var
  L: TIntegerList;
  I, AncestorId: Integer;
  S: String;
begin
  Match('Interface');
  IntfTypeID := Parse_Ident;

  NegativeMethodIndex := 0;

  BeginInterfaceType(IntfTypeID);
  SetPacked(IntfTypeID);

  if IsCurrText('Inherits') then
  begin
    DECLARE_SWITCH := false;
    Match('Inherits');
    repeat
       AncestorId := Parse_Ident;
       Gen(OP_ADD_INTERFACE, IntfTypeId, AncestorId, 0);
      if NotMatch(',') then
        break;
    until false;
    DECLARE_SWITCH := true;
  end
  else
    Gen(OP_ADD_INTERFACE, IntfTypeId, H_IUnknown, 0);

  MatchLineTerminator;

  if IsCurrText('[') then
  begin
    Match('[');
    I := Parse_PCharLiteral;
    S := GetValue(I);
    SetGuid(IntfTypeId, S);
    Match(']');
  end
  else
    SetNewGuid(IntfTypeId);

  L := TIntegerList.Create;
  try
    repeat
      if IsEOF then
        Break;
      if IsCurrText('end') then
        Break;

      if IsCurrText('Sub') then
      begin
        Parse_SubHeading;
      end
      else if IsCurrText('Function') then
      begin
        Parse_FunctionHeading;
      end;
{
      else if IsCurrText('property') then
      begin
        Parse_Property;
      end;
}

      DECLARE_SWITCH := true;

    until false;
  finally
    L.Free;
  end;

  EndInterfaceType(IntfTypeId);

  Match('End');
  Match('Interface');
  DECLARE_SWITCH := false;
  MatchLineTerminator;
  Gen(OP_ADD_TYPEINFO, IntfTypeId, 0, 0);
end;

procedure TBasicParser.Parse_EnumTypeDeclaration;
var
  TypeId, ID, TempID, L, K: Integer;
begin
  L := CurrLevel;

  DECLARE_SWITCH := true;
  Match('Enum');
  TypeId := Parse_Ident;
  BeginEnumType(TypeID, TypeINTEGER);

  MatchLineTerminator;

  TempID := NewConst(TypeID, 0);

  K := 0;

  repeat

    If IsEOF then
      Match('End');

    if IsCurrText('End') then
      Break;

    if not IsLineTerminator then
    begin
      ID := Parse_EnumIdent;
      SetLevel(ID, L);

      Inc(K);

      if IsCurrText('=') then
      begin
        DECLARE_SWITCH := false;
        Match('=');
        Gen(OP_ASSIGN_ENUM, ID, Parse_ConstantExpression, ID);
        Gen(OP_ASSIGN_ENUM, TempID, ID, TempID);
        Gen(OP_INC, TempID, NewConst(typeINTEGER, 1), tempID);
        DECLARE_SWITCH := true;
      end
      else
      begin
        Gen(OP_ASSIGN_ENUM, ID, TempID, ID);
        Gen(OP_INC, TempID, NewConst(typeINTEGER, 1), tempID);
      end;
    end;

    MatchLineTerminator;
  until false;

  EndEnumType(TypeID, K);

  Match('End');
  Match('Enum');

  DECLARE_SWITCH := false;
  MatchLineTerminator;

  Gen(OP_ADD_TYPEINFO, TypeId, 0, 0);
end;

function TBasicParser.Parse_FormalParameterList(SubId: Integer): Integer;
var
  ID, TypeId, ArrayTypeId: Integer;
  ByRef: Boolean;
begin
  DECLARE_SWITCH := true;
  Match('(');
  result := 0;
  if not IsCurrText(')') then
  begin
    repeat
      if IsCurrText('ByRef') then
      begin
        Match('ByRef');
        ByRef := true;
      end
      else if IsCurrText('ByVal') then
      begin
        Match('ByVal');
        ByRef := false;
      end
      else
        ByRef := false;

      Inc(result);
      ID := Parse_FormalParameter;
      Gen(OP_DECLARE_LOCAL_VAR, CurrLevel, ID, 0);
      DECLARE_SWITCH := false;

      ArrayTypeId := 0;

      if IsCurrText('As') then
      begin
        Match('As');
        TypeId := Parse_Type;

        if IsCurrText('(') then
        begin
          Match('(');
          Match(')');
          ArrayTypeId := NewTempVar;
          BeginDynamicArrayType(ArrayTypeID);
          Gen(OP_CREATE_DYNAMIC_ARRAY_TYPE, ArrayTypeId, TypeID, 0);
          EndDynamicArrayType(ArrayTypeID);
          Gen(OP_ADD_TYPEINFO, ArrayTypeId, 0, 0);
          TypeId := ArrayTypeId;
        end;
      end
      else
        TypeId := typeVARIANT;
      DECLARE_SWITCH := true;

      if ByRef then
        SetByRef(ID);
      Gen(OP_ASSIGN_TYPE, ID, TypeID, 0);

      if IsCurrText('=') then
      begin
        if ArrayTypeId = 0 then
          Match('=')
        else
          Match(',');
        Gen(OP_ASSIGN_CONST, ID, Parse_ConstantExpression, ID);
        SetOptional(ID);
      end;

      if NotMatch(',') then
        Break;
    until false;
  end;
  Match(')');
end;

procedure TBasicParser.Parse_ExternalSubDeclaration(SubMl: TBasicModifierList);
var
  SubId, NP, LibId, AliasId, SubNameId: Integer;
  S: String;
begin
  DECLARE_SWITCH := true;
  Match('Sub');

  SubId := Parse_Ident;
  BeginSub(SubId);
  Parse_CallConvention(SubId, true);
  SetExternal(SubId, true);

  S := GetName(SubId);
  SubNameId := NewConst(typeSTRING, S);

  DECLARE_SWITCH := false;
  if not IsCurrText('Lib') then
    Match('Lib')
  else
    ReadToken;

  if CurrToken.TokenClass = tcPCharConst then
  begin
    S := RemoveCh('"', CurrToken.Text);
    LibId := NewConst(typeSTRING, S);
  end
  else
  begin
    LibId := Lookups(CurrToken.Text, LevelStack);

    if LibId = 0 then
      RaiseError(errUndeclaredIdentifier, [CurrToken.Text]);

    if not IsStringConst(LibId) then
      RaiseError(errIncompatibleTypesNoArgs, []);
  end;
  ReadToken;

  if IsCurrText('Alias') then
  begin
    ReadToken;
    if CurrToken.TokenClass = tcPCharConst then
    begin
      S := RemoveCh('"', CurrToken.Text);
      AliasId := NewConst(typeSTRING, S);
    end
    else
    begin
      AliasId := Lookups(CurrToken.Text, LevelStack);

      if AliasId = 0 then
        RaiseError(errUndeclaredIdentifier, [CurrToken.Text]);

      if not IsStringConst(AliasId) then
        RaiseError(errIncompatibleTypesNoArgs, []);
    end;
    SubNameId := AliasId;
  end;

  DECLARE_SWITCH := true;
  if IsCurrText('(') then
    NP := Parse_FormalParameterList(SubId)
  else
    NP := 0;
  SetCount(SubId, NP);
  SetName(CurrResultId, '');
  SetKind(CurrResultId, KindNONE);
  Gen(OP_ASSIGN_TYPE, SubId, TypeVOID, 0);
  Gen(OP_ASSIGN_TYPE, CurrResultId, TypeVOID, 0);

  EndSub(SubId);
  RemoveSub;

  Gen(OP_LOAD_PROC, SubId, SubNameId, LibId);

  DECLARE_SWITCH := false;
  MatchLineTerminator;
end;

procedure TBasicParser.Parse_ExternalFunctionDeclaration(FunctionMl: TBasicModifierList);
var
  SubId, NP, LibId, AliasId, SubNameId, TypeId: Integer;
  S: String;
begin
  DECLARE_SWITCH := true;
  Match('Function');

  SubId := Parse_Ident;
  BeginSub(SubId);
  Parse_CallConvention(SubId, true);
  SetExternal(SubId, true);

  S := GetName(SubId);
  SubNameId := NewConst(typeSTRING, S);

  DECLARE_SWITCH := false;
  if not IsCurrText('Lib') then
    Match('Lib')
  else
    ReadToken;

  if CurrToken.TokenClass = tcPCharConst then
  begin
    S := RemoveCh('"', CurrToken.Text);
    LibId := NewConst(typeSTRING, S);
  end
  else
  begin
    LibId := Lookups(CurrToken.Text, LevelStack);

    if LibId = 0 then
      RaiseError(errUndeclaredIdentifier, [CurrToken.Text]);

    if not IsStringConst(LibId) then
      RaiseError(errIncompatibleTypesNoArgs, []);
  end;
  ReadToken;

  if IsCurrText('Alias') then
  begin
    ReadToken;
    if CurrToken.TokenClass = tcPCharConst then
    begin
      S := RemoveCh('"', CurrToken.Text);
      AliasId := NewConst(typeSTRING, S);
    end
    else
    begin
      AliasId := Lookups(CurrToken.Text, LevelStack);

      if AliasId = 0 then
        RaiseError(errUndeclaredIdentifier, [CurrToken.Text]);

      if not IsStringConst(AliasId) then
        RaiseError(errIncompatibleTypesNoArgs, []);
    end;
    SubNameId := AliasId;
    ReadToken;
  end;

  DECLARE_SWITCH := true;
  if IsCurrText('(') then
    NP := Parse_FormalParameterList(SubId)
  else
    NP := 0;
  SetCount(SubId, NP);
  DECLARE_SWITCH := false;
  if IsCurrText('As') then
  begin
    Match('As');
    TypeID := Parse_Type;
  end
  else
    TypeId := typeVARIANT;
  Gen(OP_ASSIGN_TYPE, SubId, TypeID, 0);
  Gen(OP_ASSIGN_TYPE, CurrResultId, TypeID, 0);

  EndSub(SubId);
  RemoveSub;

  Gen(OP_LOAD_PROC, SubId, SubNameId, LibId);

  DECLARE_SWITCH := false;
  MatchLineTerminator;
end;

procedure TBasicParser.Parse_SubDeclaration(SubMl: TBasicModifierList);
var
  SubId, NP: Integer;
begin
  DECLARE_SWITCH := true;
  Match('Sub');
  SubId := Parse_Ident;
  BeginSub(SubId);
  Parse_CallConvention(SubId, false);

  if IsCurrText('(') then
    NP := Parse_FormalParameterList(SubId)
  else
    NP := 0;
  SetCount(SubId, NP);
  SetName(CurrResultId, '');
  SetKind(CurrResultId, KindNONE);
  Gen(OP_ASSIGN_TYPE, SubId, TypeVOID, 0);
  Gen(OP_ASSIGN_TYPE, CurrResultId, TypeVOID, 0);

  InitSub(SubId);
  Inc(EXECUTABLE_SWITCH);
  DECLARE_SWITCH := false;
  MatchLineTerminator;
  Parse_Statements;
  EndSub(SubId);
  Match('End');
  Match('Sub');

  DECLARE_SWITCH := false;
  Dec(EXECUTABLE_SWITCH);
  MatchLineTerminator;
end;

procedure TBasicParser.Parse_FunctionDeclaration(FunctionMl: TBasicModifierList);
var
  SubId, TypeId, NP: Integer;
begin
  DECLARE_SWITCH := true;
  Match('function');
  SubId := Parse_Ident;
  BeginSub(SubId);
  Parse_CallConvention(SubId, false);
  SetName(CurrResultId, '');
  if IsCurrText('(') then
    NP := Parse_FormalParameterList(SubId)
  else
    NP := 0;
  SetCount(SubId, NP);
  DECLARE_SWITCH := false;
  if IsCurrText('As') then
  begin
    Match('As');
    TypeID := Parse_Type;
  end
  else
    TypeId := typeVARIANT;
  Gen(OP_ASSIGN_TYPE, SubId, TypeID, 0);
  Gen(OP_ASSIGN_TYPE, CurrResultId, TypeID, 0);

  InitSub(SubId);
  Inc(EXECUTABLE_SWITCH);
  DECLARE_SWITCH := false;
  MatchLineTerminator;

  Parse_Statements;
  EndSub(SubId);
  Match('End');
  Match('Function');
  MatchLineTerminator;

  DECLARE_SWITCH := false;
  Dec(EXECUTABLE_SWITCH);
end;

procedure TBasicParser.Parse_PrintStmt;
var
  ID, ID_L1, ID_L2: Integer;
begin
  repeat
    ID := Parse_Expression;
    ID_L1 := 0;
    ID_L2 := 0;
    if IsCurrText(':') then
    begin
      Call_SCANNER;
      ID_L1 := Parse_Expression;
    end;
    if IsCurrText(':') then
    begin
      Call_SCANNER;
      ID_L2 := Parse_Expression;
    end;

    Gen(OP_PRINT_EX, ID, ID_L1, ID_L2);
    if NotMatch(',') then
      Break;
  until false;
end;

procedure TBasicParser.Parse_PrintlnStmt;
begin
  Parse_PrintStmt;
  Gen(OP_PRINT_EX, NewConst(typeANSISTRING, #13#10), 0, 0);
end;

procedure TBasicParser.Parse_GotoStmt;
begin
  Match('Goto');
  Gen(OP_GO, Parse_Label, 0, 0);
  MatchStatementTerminator;
end;

procedure TBasicParser.Parse_Block;
begin
	DECLARE_SWITCH := false;
	Parse_Statements;
end;

procedure TBasicParser.Parse_IfStmt;
var
  lg, lf, l1: Integer;
begin
  Match('If');

	lg := NewLabel;
	lf := NewLabel;

	Gen(OP_GO_FALSE, lf, Parse_Expression, 0);

	if IsStatementTerminator then // block if statement
  begin
		MatchStatementTerminator;

		Parse_Block;
		Gen(OP_GO, lg, 0, 0);
		SetLabelHere(lf);

    while IsCurrText('ElseIf') do
    begin
      l1 := NewLabel();
      Match('ElseIf');
      Gen(OP_GO_FALSE, l1, Parse_Expression, 0);

      if IsCurrText('Then') then
        Match('Then');

      MatchStatementTerminator;
      Parse_Block;
      Gen(OP_GO, lg, 0, 0);
      SetLabelHere(l1);
    end;

    if IsCurrText('Else') then
    begin
      Match('Else');
      MatchStatementTerminator;
      Parse_Block;
    end;

    SetLabelHere(lg);

    Match('End');
    Match('If');
    MatchStatementTerminator;
  end
	else // line if statement
  begin
		Match('Then');
    while IsLineTerminator do
      MatchLineTerminator;

    SKIP_STATEMENT_TERMINATOR := true;

    Parse_Statements;
    Gen(OP_GO, lg, 0, 0);
    SetLabelHere(lf);

    while IsCurrText('ElseIf') do
    begin
      l1 := NewLabel();
      Match('ElseIf');
      Gen(OP_GO_FALSE, l1, Parse_Expression, 0);

      if IsCurrText('Then') then
        Match('Then');

      MatchStatementTerminator;
      Parse_Block;
      Gen(OP_GO, lg, 0, 0);
      SetLabelHere(l1);
    end;

    if IsCurrText('Else') then
    begin
      Match('Else');
      Parse_Statements;
    end;

    SetLabelHere(lg);
    if IsNextText('If') then
    begin
      Match('End');
      Match('If');
      MatchStatementTerminator;
    end;

    SKIP_STATEMENT_TERMINATOR := false;
  end;
end;

procedure TBasicParser.Parse_SelectStmt;
var
  lg, lf, id, expr1_id, cond_id, op: Integer;
  lt: Integer; //new
begin
  Match('Select');
  if IsCurrText('Case') then
    Match('Case');

  PushExitKind(ekSelect);
  lg := NewLabel;
  cond_id := NewTempVar;
  BreakStack.Push(lg);

  id := Parse_Expression;
  MatchStatementTerminator;

  while IsCurrText('Case') do
  begin
    Match('Case');
    if not IsCurrText('Else') then // parse case statement
    begin
      lf := NewLabel;
      lt := NewLabel; //new

      repeat // parse case clauses
        // parse case clause

        if IsCurrText('Is') then
        begin
          Match('Is');

          op := 0;
          if IsCurrText('=') or
             IsCurrText('<>') or
             IsCurrText('>') or
             IsCurrText('>=') or
             IsCurrText('<') or
             IsCurrText('<=') then
          begin
            op := CurrToken.Id;
            Call_SCANNER;
          end
          else
            Match('=');

          Gen(op, id, Parse_Expression, cond_id);
          Gen(OP_GO_FALSE, lf, cond_id, 0);
          Gen(OP_GO_TRUE, lt, cond_id, 0);  //new
        end
        else
        begin
          expr1_id := Parse_Expression;

          if IsCurrText('To') then
          begin
            Gen(OP_GE, id, expr1_id, cond_id);
            Gen(OP_GO_FALSE, lf, cond_id, 0);
            Match('To');
            Gen(OP_LE, id, Parse_Expression, cond_id);
            Gen(OP_GO_FALSE, lf, cond_id, 0);
            Gen(OP_GO_TRUE, lt, cond_id, 0);  //new
          end
          else
          begin
            Gen(OP_EQ, id, expr1_id, cond_id);
//          Gen(OP_GO_FALSE, lf, cond_id, 0); //new
            Gen(OP_GO_TRUE, lt, cond_id, 0);  //new
          end;
        end;

        if NotMatch(',') then
        begin
          Gen(OP_GO, lf, 0, 0); //new
          break;
        end;

      until false;

      SetLabelHere(lt);

      MatchStatementTerminator;
      Parse_Block;
      Gen(OP_GO, lg, 0, 0);
      SetLabelHere(lf);
    end
    else // parse case else statement
    begin
      Match('Else');
      MatchStatementTerminator;
      Parse_Block;
    end;
  end;

  SetLabelHere(lg);
  BreakStack.Pop;
  PopExitKind;

  Match('End');
  Match('Select');
  MatchStatementTerminator;
end;

procedure TBasicParser.Parse_WhileStmt;
var
  lf, lg: Integer;
begin
	Match('While');
  PushExitKind(ekWhile);

  lf := NewLabel;
  lg := NewLabel;
  SetLabelHere(lg);
  Gen(OP_GO_FALSE, lf, Parse_Expression, 0);
  MatchStatementTerminator;
  BreakStack.Push(lf);
  ContinueStack.Push(lg);
  Parse_Block;
  BreakStack.Pop;
  ContinueStack.Pop;
  Gen(OP_GO, lg, 0, 0);
  SetLabelHere(lf);
  Match('End');
  Match('While');
  PopExitKind;
  MatchStatementTerminator;
end;

procedure TBasicParser.Parse_DoLoopStmt;
var
  lf, lg: Integer;
begin
  Match('Do');
  PushExitKind(ekDo);

  lg := NewLabel;
  lf := NewLabel;
  SetLabelHere(lg);
  if IsCurrText('While') then
  begin
    Match('While');
    Gen(OP_GO_FALSE, lf, Parse_Expression, 0);
  end
  else if IsCurrText('Until') then
  begin
    Match('Until');
    Gen(OP_GO_TRUE, lf, Parse_Expression(), 0);
  end;
  MatchStatementTerminator;

  BreakStack.Push(lf);
  ContinueStack.Push(lg);
  Parse_Block;
  BreakStack.Pop;
  ContinueStack.Pop;

  Match('Loop');
  if IsCurrText('While') then
  begin
    Match('While');
    Gen(OP_GO_TRUE, lg, Parse_Expression, 0);
  end
  else if IsCurrText('Until') then
  begin
    Match('Until');
    Gen(OP_GO_FALSE, lg, Parse_Expression, 0);
  end
  else
    Gen(OP_GO, lg, 0, 0);
  SetLabelHere(lf);
  MatchStatementTerminator;

  PopExitKind;
end;

procedure TBasicParser.Parse_ExitStmt;

function GetExitLabel(ek: TExitKind; const AKeyword: String): Integer;
var
  I: Integer;
  S: String;
begin
  result := 0;
  if BreakStack.Count <>  exit_kind_stack.Count then
    RaiseError(errInternalError, []);
  for I := exit_kind_stack.Count - 1 downto 0 do
    if exit_kind_stack[I] = Integer(ek) then
    begin
      result := BreakStack[I].IntLabel;
      Exit;
    end;
  ek := TExitKind(exit_kind_stack.Top);
  case ek of
    ekNone: S := '';
    ekDo: S := 'Do';
    ekFor: S := 'For';
    ekWhile: S := 'While';
    ekSelect: S := 'Select';
    ekSub: S := 'Sub';
    ekTry: S := 'Try';
    ekFunction: S := 'Function';
  end;
  RaiseError(errTokenExpected, [S, AKeyword]);
end;

var
  L: Integer;
begin
	Match('Exit');
  if IsCurrText('Do') then
  begin
    Match('Do');
    L := GetExitLabel(ekDo, 'Do');
  	Gen(OP_GO, L, 0, 0);
  end
  else if IsCurrText('For') then
  begin
    Match('For');
    L := GetExitLabel(ekFor, 'For');
  	Gen(OP_GO, L, 0, 0);
  end
  else if IsCurrText('While') then
  begin
    Match('While');
    L := GetExitLabel(ekWhile, 'While');
  	Gen(OP_GO, L, 0, 0);
  end
  else if IsCurrText('Select') then
  begin
    Match('Select');
    L := GetExitLabel(ekSelect, 'Select');
  	Gen(OP_GO, L, 0, 0);
  end
  else if IsCurrText('Sub') then
  begin
    Match('Sub');
    Gen(OP_EXIT, SkipLabelStack.Top, 0, CurrLevel);
  end
  else if IsCurrText('Function') then
  begin
    Match('Function');
    Gen(OP_EXIT, SkipLabelStack.Top, 0, CurrLevel);
  end
  else if IsCurrText('Try') then
  begin
    Match('Try');
    L := GetExitLabel(ekTry, 'Try');
  	Gen(OP_GO, L, 0, 0);
  end
  else
  	Gen(OP_GO, BreakStack.TopLabel, 0, 0);
  MatchStatementTerminator;
end;

procedure TBasicParser.Parse_ContinueStmt;
begin
	if ContinueStack.Count = 0 then
    RaiseError(errBreakOrContinueOutsideOfLoop, []);
	Match('Continue');
  if IsCurrText('(') then
  begin
    Match('(');
    Match(')');
  end;
	Gen(OP_GO, ContinueStack.TopLabel, 0, 0);
  MatchStatementTerminator;
end;

procedure TBasicParser.Parse_ThrowStmt;
begin
  Match('Throw');
  if IsStatementTerminator then
    Gen(OP_RAISE, 0, RaiseMode, 0)
  else
    Gen(OP_RAISE, Parse_Expression, RaiseMode, 0);
  MatchStatementTerminator;
end;

procedure TBasicParser.Parse_TryStmt;
var
  l_try, l_finally, id, block_id, type_id: Integer;
  S: String;
begin
  Match('Try');
  PushExitKind(ekTry);

  MatchStatementTerminator();
  l_try := GenBeginTry;
  BreakStack.Push(l_try);
  Parse_Block();

  l_finally := NewLabel;
  Gen(OP_GO, l_finally, 0, 0);

  while IsCurrText('Catch') do
  begin
    Gen(OP_GO, l_try, 0, 0);
    GenExcept;
    //ExceptionBlock

    block_id := NewTempVar;
    LevelStack.push(block_id);
    Gen(OP_BEGIN_BLOCK, block_id, 0, 0);

    S := GetNextText;
    if not ((PosCh(#13, S) > 0) or (Pos(#10, S) > 0)) then
      DECLARE_SWITCH := true;
    Call_SCANNER;

    if not IsStatementTerminator then
    begin
      id := Parse_Ident;
      DECLARE_SWITCH := false;
      Match('As');
      type_id := Parse_Ident;
      Gen(OP_ASSIGN_TYPE, id, type_id, 0);

      GenExceptOn(type_id);
      Gen(OP_ASSIGN, id, CurrExceptionObjectId, id);
    end
    else
    begin
      GenExceptOn(0);
    end;

//  Gen(OP_BEGIN_EXCEPT_BLOCK, 0, 0, 0);
    MatchStatementTerminator();
    Parse_Block();// on catch
    Gen(OP_END_EXCEPT_BLOCK, 0, 0, 0);
    Gen(OP_GO, l_finally, 0, 0);
    Gen(OP_END_BLOCK, block_id, 0, 0);
    LevelStack.Pop;
  end;

  SetLabelHere(l_finally);

  if IsCurrText('Finally') then
  begin
    GenFinally;
    Call_SCANNER;
    MatchStatementTerminator();
    Parse_Block();
    Gen(OP_COND_RAISE, 0, 0, 0);
  end;

  SetLabelHere(l_try);
  GenEndTry;

  Match('End');
  Match('Try');

  BreakStack.Pop;
  PopExitKind();

  MatchStatementTerminator();
end;

procedure TBasicParser.Parse_ForEachStmt;
var
  lf, lg, lc: Integer;
  element_id, collection_id, enumerator_id, bool_id: Integer;
  next_id: Integer;
  r: TForLoopRec;
begin
  PushExitKind(ekFor);
  Match('For');
  Match('Each');
  Inc(ForEachCounter);
  lf := NewLabel;
  lg := NewLabel;
  lc := NewLabel;
  enumerator_id := NewTempVar;
  bool_id := NewTempVar;
  element_id := Parse_Ident;
  Match('in');
  collection_id := Parse_Expression;
  MatchLineTerminator;

  for_loop_stack.Push(element_id, 0, lg, lf, GetName(element_id));

  Gen(OP_GET_ENUMERATOR, collection_id, ForEachCounter, enumerator_id);
  SetLabelHere(lg);
  Gen(OP_CURRENT, enumerator_id, ForEachCounter, element_id);
  BreakStack.Push(lf);
  ContinueStack.Push(lc);

  repeat
    if IsCurrText('Next') then
      break;
    if IsEOF then
      break;
    if for_loop_stack.Count = 0 then
      break;
    Parse_Statement;
  until false;

  BreakStack.Pop;
  ContinueStack.Pop;

  SetLabelHere(lc, ForEachCounter);

  Match('Next');
  if not IsStatementTerminator() then
  begin
    repeat
      next_id := Parse_Expression;
      r := for_loop_stack.Top;
      if r.Name <> UpperCase(GetName(next_id)) then
        RaiseError(errNextControlVariableDoesNotMatchForLoopControlVariable, [GetName(r.id)]);

      Gen(OP_MOVE_NEXT, r.id, ForEachCounter, bool_id);
      Gen(OP_GO_FALSE, r.lf, bool_id, 0);
      Gen(OP_GO, r.lg, 0, 0);
      SetLabelHere(r.lf, 0, ForEachCounter);

      for_loop_stack.Pop;

      if NotMatch(',') then
        break;
    until false;
  end
  else
  begin

    Gen(OP_MOVE_NEXT, element_id, ForEachCounter, bool_id);
    Gen(OP_GO_FALSE, lf, bool_id, 0);
    Gen(OP_GO, lg, 0, 0);
    SetLabelHere(lf, 0, ForEachCounter);

    for_loop_stack.Pop;
  end;

  MatchStatementTerminator();
  PopExitKind();
end;

procedure TBasicParser.Parse_ForNextStmt;
var
  lf, lg, id, limit_cond_id, step_id, next_id: Integer;
  r: TForLoopRec;
begin
  Match('For');
  PushExitKind(ekFor);

  lg := NewLabel;
  lf := NewLabel;
  limit_cond_id := NewTempVar;

  id := Parse_Ident;
  Match('=');
  Gen(OP_ASSIGN, id, Parse_Expression, id);
  SetLabelHere(lg);

  Match('To');
  Gen(OP_LE, id, Parse_Expression, limit_cond_id);
  Gen(OP_GO_FALSE, lf, limit_cond_id, 0);

  if IsCurrText('Step') then
  begin
    Match('Step');
    step_id := Parse_Expression;
  end
  else
    step_id := NewConst(typeINTEGER, 1);

  MatchStatementTerminator;

  for_loop_stack.Push(id, step_id, lg, lf, GetName(id));
  BreakStack.Push(lf);
  ContinueStack.Push(lg);

  repeat
    if IsCurrText('Next') then
      break;
    if IsEOF then
      break;
    if for_loop_stack.Count = 0 then
      break;
    Parse_Statement;
  until false;

  BreakStack.Pop();
  ContinueStack.Pop();

  if for_loop_stack.Count = 0 then
  begin
    SetLabelHere(lf);
    Exit;
  end;

  Match('Next');
  if not IsStatementTerminator() then
  begin
    repeat
      next_id := Parse_Expression;
      r := for_loop_stack.Top;
      if r.Name <> UpperCase(GetName(next_id)) then
        RaiseError(errNextControlVariableDoesNotMatchForLoopControlVariable, [GetName(r.id)]);

      Gen(OP_PLUS, r.id, r.step_id, r.id);
      Gen(OP_GO, r.lg, 0, 0);
      SetLabelHere(r.lf);

      for_loop_stack.Pop;

      if NotMatch(',') then
        break;
    until false;
  end
  else
  begin
    Gen(OP_PLUS, id, step_id, id);
    Gen(OP_GO, lg, 0, 0);
    SetLabelHere(lf);
    for_loop_stack.Pop;
  end;

  PopExitKind();

  MatchStatementTerminator();
end;

procedure TBasicParser.Parse_WithStmt;
var
  Id: Integer;
begin
  Match('With');
  Id := Parse_Expression;
  with_stack.Push(Id);
  Gen(OP_BEGIN_WITH, id, 0, 0);
  MatchStatementTerminator;
  if not IsCurrText('End') then
    Parse_Block;
  Gen(OP_END_WITH, id, 0, 0);
  with_stack.Pop;
  Match('End');
  Match('With');
  MatchStatementTerminator;
end;

procedure TBasicParser.Parse_ReturnStmt;
begin
  Match('Return');
  if not IsStatementTerminator then
    Gen(OP_ASSIGN, CurrResultId, Parse_Expression, CurrResultId);
	Gen(OP_GO, SkipLabelStack.Top, 0, 0);
  MatchStatementTerminator;
end;

procedure TBasicParser.Parse_AssignmentStmt;
var
  LeftID, SubId, L, I, TempId, P: Integer;
  SubName: String;
begin

  if IsCurrText('SetLength') then
  begin
    Call_SCANNER;
    Match('(');
    LeftID := Parse_Designator;
    Call_SCANNER;
    Gen(OP_SET_LENGTH, LeftID, Parse_Expression, 0);
    Match(')');
    MatchStatementTerminator;
    Exit;
  end
  else if IsCurrText('pause') then
  begin
    Call_SCANNER;
    if IsCurrText('(') then
    begin
      Match('(');
      Match(')');
    end;
    L := NewLabel;
    Gen(OP_PAUSE, L, 0, 0);
    SetLabelHere(L);
    MatchStatementTerminator;
    Exit;
  end
  else if IsCurrText('halt') or IsCurrText('abort') then
  begin
    Call_SCANNER;
    if IsCurrText('(') then
    begin
      Match('(');
      if not IsCurrText(')') then
      begin
        Gen(OP_HALT, Parse_ConstantExpression, 0, 0);
      end
      else
        Gen(OP_HALT, NewConst(typeINTEGER, 0), 0, 0);
      Match(')');
    end
    else
      Gen(OP_HALT, NewConst(typeINTEGER, 0), 0, 0);
    MatchStatementTerminator;
    Exit;
  end;

  if IsCurrText('MyClass') then
  begin
    Call_SCANNER;
    Match('.');
    LeftID := Parse_Ident;
    Gen(OP_MYCLASS, LeftId, 0, 0);
  end
  else if IsCurrText('MyBase') then
  begin
    Call_SCANNER;
    Match('.');
    LeftId := NewTempVar;
    if IsLineTerminator then
    begin
      SubId := CurrLevel;
      L := NewTempVar;
      SetName(L, GetName(SubId));
      Gen(OP_EVAL, 0, 0, L);
      Gen(OP_EVAL_INHERITED, L, 0, LeftId);
      for I:=0 to GetCount(SubId) - 1 do
        Gen(OP_PUSH, GetParamId(SubId, I), I, LeftId);
      Gen(OP_CALL, LeftID, 0, 0);
    end
    else
    begin
      if GetName(CurrSubId) = '' then
      begin
        if IsCurrText('New') then
          Gen(OP_PUSH_INSTANCE, CurrSelfId, 0, LeftId);
        Gen(OP_EVAL_INHERITED, CurrSubId, 0, LeftId);
        Call_SCANNER;
      end
      else
      begin
        L := Parse_Ident;
        Gen(OP_EVAL_INHERITED, L, 0, LeftId);
      end;

      if IsCurrText('(') then
        Gen(OP_CALL, LeftID, Parse_ArgumentList(LeftId), 0)
      else
        Gen(OP_CALL, LeftID, 0, 0);
    end;
    if GetKind(CurrSubId) = kindCONSTRUCTOR then
    begin
      Gen(OP_RESTORE_EDX, 0, 0, 0);

      L := NewLabel;
      Gen(OP_GO_DL, L, 0, 0);
      Gen(OP_ONCREATE_OBJECT, CurrSelfId, 0, 0);
      SetLabelHere(L);

      Gen(OP_SAVE_EDX, 0, 0, 0);

      WasInherited := true;
    end;
    MatchStatementTerminator;
    Exit;
  end
  else
    LeftID := Parse_Designator;

  SubName := GetName(CurrSubId);
  P := Pos('__get', SubName);
  if P = 1 then
    SubName := Copy(SubName, 6, Length(SubName) - 5)
  else
  begin
    P := Pos('__set', SubName);
    if P = 1 then
      SubName := Copy(SubName, 6, Length(SubName) - 5)
  end;

  if (GetName(LeftId) <> '') and StrEql(GetName(LeftId), SubName) then
  begin
    if GetCodeRec(CodeCard).Op = OP_EVAL then
      if StrEql(GetName(LeftId), GetName(GetCodeRec(CodeCard).Res)) then
        GetCodeRec(CodeCard).Op := OP_NOP;

 		LeftId := CurrResultId;
  end;

  Gen(OP_LVALUE, LeftId, 0, 0);

  if IsCurrText('=') then
  begin
    Call_SCANNER;
    Gen(OP_ASSIGN, LeftID, Parse_Expression, LeftID);
  end
  else if IsCurrText('+=') then
  begin
    TempId := NewTempVar;
    Call_SCANNER;
    Gen(OP_PLUS, LeftID, Parse_Expression, TempId);
    Gen(OP_ASSIGN, LeftID, TempId, LeftId);
  end
  else if IsCurrText('-=') then
  begin
    TempId := NewTempVar;
    Call_SCANNER;
    Gen(OP_MINUS, LeftID, Parse_Expression, TempId);
    Gen(OP_ASSIGN, LeftID, TempId, LeftId);
  end
  else if IsCurrText('*=') then
  begin
    TempId := NewTempVar;
    Call_SCANNER;
    Gen(OP_MULT, LeftID, Parse_Expression, TempId);
    Gen(OP_ASSIGN, LeftID, TempId, LeftId);
  end
  else if IsCurrText('/=') then
  begin
    TempId := NewTempVar;
    Call_SCANNER;
    Gen(OP_DIV, LeftID, Parse_Expression, TempId);
    Gen(OP_ASSIGN, LeftID, TempId, LeftId);
  end
  else if IsCurrText('\=') then
  begin
    TempId := NewTempVar;
    Call_SCANNER;
    Gen(OP_IDIV, LeftID, Parse_Expression, TempId);
    Gen(OP_ASSIGN, LeftID, TempId, LeftId);
  end
  else if IsCurrText('(') then
  begin
    SubId := LeftId;
    LeftId := NewTempVar;
    Gen(OP_CALL, SubId, Parse_ArgumentList(SubId), LeftId);

    if IsCurrText('=') then
    begin
      Call_SCANNER;
      Gen(OP_ASSIGN, LeftID, Parse_Expression, LeftID);
    end;
  end
  else
  begin
    Gen(OP_CALL, LeftID, 0, 0);
  end;
  MatchStatementTerminator;
end;

procedure TBasicParser.Parse_DimStmt;
var
  ID, TypeID, ExprID, ArrayTypeId, LengthId, L: Integer;
  IsArray: Boolean;
begin
  DECLARE_SWITCH := true;
  if IsCurrText('Dim') then
    Match('Dim');

  L := CurrLevel;
  if L > 0 then
    if GetKind(L) in KindSUBS then
      L := -1;

  repeat
    ID := Parse_Ident;
    Gen(OP_DECLARE_LOCAL_VAR, CurrLevel, ID, 0);
    DECLARE_SWITCH := false;

    if IsCurrText('(') then
    begin
      Match('(');
      ExprID := Parse_Expression;
      Match(')');
      IsArray := true;
    end
    else
    begin
      IsArray := false;
      ExprId := 0;
    end;

    if IsCurrText('As') then
    begin
      Match('As');
      TypeID := Parse_Type;
    end
    else
      TypeId := typeVARIANT;

    if IsArray then
    begin
      ArrayTypeId := NewTempVar;
      BeginDynamicArrayType(ArrayTypeID);
      Gen(OP_CREATE_DYNAMIC_ARRAY_TYPE, ArrayTypeId, TypeID, 0);
      EndDynamicArrayType(ArrayTypeID);
      Gen(OP_ADD_TYPEINFO, ArrayTypeId, 0, 0);

      Gen(OP_ASSIGN_TYPE, ID, ArrayTypeID, 0);
      LengthId := NewTempVar(typeINTEGER);
      if L >= 0 then
        Gen(OP_BEGIN_INIT_CONST, ID, 0, 0);
      Gen(OP_PLUS, ExprId, NewConst(typeINTEGER, 1), LengthId);
      Gen(OP_SET_LENGTH, ID, LengthId, 0);
      if L >= 0 then
        Gen(OP_END_INIT_CONST, ID, 0, 0);
    end
    else
      Gen(OP_ASSIGN_TYPE, ID, TypeID, 0);

    if IsCurrText('=') then
    begin
      Inc(EXECUTABLE_SWITCH);
      DECLARE_SWITCH := false;
      Match('=');
      ExprID := Parse_Expression;

      if L >= 0 then
      if ParsesModuleBody then
        Gen(OP_BEGIN_INIT_CONST, ID, 0, 0);

      Gen(OP_ASSIGN, ID, ExprID, ID);

      if L >= 0 then
      if ParsesModuleBody then
        Gen(OP_END_INIT_CONST, ID, 0, 0);

      Dec(EXECUTABLE_SWITCH);
    end
    else
      Gen(OP_CALL_DEFAULT_CONSTRUCTOR, ID, 0, 0);

    DECLARE_SWITCH := true;

    if NotMatch(',') then
      break;
  until false;

  DECLARE_SWITCH := false;
  MatchStatementTerminator;
end;

procedure TBasicParser.Parse_ConstStmt;
var
  ID: Integer;
begin
  DECLARE_SWITCH := true;
  Match('const');

  repeat
    ID := Parse_Ident;
    Gen(OP_DECLARE_LOCAL_VAR, CurrLevel, ID, 0);
    SetKind(ID, kindCONST);
    DECLARE_SWITCH := false;
    if IsCurrText('As') then
    begin
      Match('As');
      Gen(OP_ASSIGN_TYPE, ID, Parse_Type, 0);
    end;
    Match('=');
    Gen(OP_ASSIGN_CONST, ID, Parse_ConstantExpression, ID);
    DECLARE_SWITCH := true;

    if NotMatch(',') then
      break;
  until false;

  DECLARE_SWITCH := false;
  MatchStatementTerminator;
end;

function TBasicParser.Parse_ArgumentList(SubId: Integer): Integer;
var
  I: Integer;
  L: TIntegerList;
begin
  L := TIntegerList.Create;
  try
    Match('(');
    result := 0;
    if (not IsCurrText(')')) then
    begin
      repeat
        Inc(result);
        L.Add(Parse_Expression);
        if NotMatch(',') then
          Break;
      until false;
    end;

    for I:=0 to L.Count - 1 do
      Gen(OP_PUSH, L[I], I, SubID);

    Match(')');
  finally
    L.Free;
  end;
end;

function TBasicParser.Parse_Expression: Integer;
begin
  result := Parse_LogicalXORExpression;
end;

function TBasicParser.Parse_ConstantExpression: Integer;
begin
  result := Parse_Expression;
end;

function TBasicParser.Parse_LogicalXORExpression: Integer;
begin
	result := Parse_LogicalORExpression;
	while IsCurrText('Xor') do
  begin
		Call_SCANNER();
		result := BinOp(OP_XOR, result, Parse_LogicalORExpression);
	end;
end;

function TBasicParser.Parse_LogicalORExpression: Integer;
var
  id, lt: Integer;
begin
  result := Parse_LogicalANDExpression;
  while IsCurrText('Or') or IsCurrText('OrElse') do
  begin
    if IsCurrText('Or') then
    begin
      Call_SCANNER();
      result := BinOp(OP_OR, result, Parse_LogicalANDExpression);
    end
    else
    begin
      id := result;
      lt := NewLabel;
      result := NewTempVar;
      Gen(OP_ASSIGN, result, id, result);
      Gen(OP_GO_TRUE, lt, result, 0);
      Call_SCANNER;
      Gen(OP_ASSIGN, result, Parse_LogicalANDExpression, result);
      SetLabelHere(lt);
    end;
  end;
end;

function TBasicParser.Parse_LogicalANDExpression: Integer;
var
  id, lf: Integer;
begin
  result := Parse_LogicalNOTExpression;
  while IsCurrText('And') or IsCurrText('AndAlso') do
  begin
    if IsCurrText('And') then
    begin
      Call_SCANNER;
      result := BinOp(OP_AND, result, Parse_LogicalNOTExpression);
    end
    else
    begin
      id := result;
      lf := NewLabel;
      result := NewTempVar;
      Gen(OP_ASSIGN, result, id, result);
      Gen(OP_GO_FALSE, lf, result, 0);
      Call_SCANNER;
      Gen(OP_ASSIGN, result, Parse_LogicalNOTExpression, result);
      SetLabelHere(lf);
    end;
  end;
end;

function TBasicParser.Parse_LogicalNOTExpression: Integer;
begin
  if IsCurrText('Not') then
  begin
    Match('Not');
    result := UnaryOp(OP_NOT, Parse_Expression);
  end
  else
    result := Parse_RelationalExpression();
end;

function TBasicParser.Parse_RelationalExpression: Integer;
begin
  result := Parse_ShiftExpression;
  while IsCurrText('=') or IsCurrText('<>') or
        IsCurrText('>') or IsCurrText('>=') or
        IsCurrText('<') or IsCurrText('<=') do
  begin
    if IsCurrText('=') then
    begin
      Call_SCANNER;
      result := BinOp(OP_EQ, result, Parse_ShiftExpression);
    end
    else if IsCurrText('<>') then
    begin
      Call_SCANNER;
      result := BinOp(OP_NE, result, Parse_ShiftExpression);
    end
    else if IsCurrText('>') then
    begin
      Call_SCANNER;
      result := BinOp(OP_GT, result, Parse_ShiftExpression);
    end
    else if IsCurrText('>=') then
    begin
      Call_SCANNER;
      result := BinOp(OP_GE, result, Parse_ShiftExpression);
    end
    else if IsCurrText('<') then
    begin
      Call_SCANNER;
      result := BinOp(OP_LT, result, Parse_ShiftExpression);
    end
    else if IsCurrText('<=') then
    begin
      Call_SCANNER;
      result := BinOp(OP_LE, result, Parse_ShiftExpression);
    end;
  end
end;

function TBasicParser.Parse_ShiftExpression: Integer;
begin
  result := Parse_ConcatenationExpression;
  while IsCurrText('<<') or IsCurrText('>>') do
  begin
    if IsCurrText('<<') then
    begin
      Call_SCANNER;
      result := BinOp(OP_LEFT_SHIFT, result, Parse_ConcatenationExpression);
    end
    else
    begin
      Call_SCANNER;
      result := BinOp(OP_RIGHT_SHIFT, result, Parse_ConcatenationExpression);
    end;
  end;
end;

function TBasicParser.Parse_ConcatenationExpression: Integer;
begin
  result := Parse_AdditiveExpression;
  while IsCurrText('&') do
  begin
    Call_SCANNER;
    result := BinOp(OP_PLUS, result, Parse_AdditiveExpression);
  end;
end;

function TBasicParser.Parse_AdditiveExpression: Integer;
begin
  result := Parse_ModulusExpression;
  while IsCurrText('+') or IsCurrText('-') do
  begin
    if IsCurrText('+') then
    begin
      Call_SCANNER();
      result := BinOp(OP_PLUS, result, Parse_ModulusExpression);
    end
    else
    begin
      Call_SCANNER;
      result := BinOp(OP_MINUS, result, Parse_ModulusExpression);
    end;
  end;
end;

function TBasicParser.Parse_ModulusExpression: Integer;
begin
  result := Parse_IntegerDivisionExpression;
  while IsCurrText('Mod') do
  begin
    Call_SCANNER;
    result := BinOp(OP_MOD, result, Parse_IntegerDivisionExpression);
  end;
end;

function TBasicParser.Parse_IntegerDivisionExpression: Integer;
begin
  result := Parse_MultiplicativeExpression;
  while IsCurrText('\') do
  begin
    Call_SCANNER;
    result := BinOp(OP_IDIV, result, Parse_MultiplicativeExpression);
  end;
end;

function TBasicParser.Parse_MultiplicativeExpression: Integer;
begin
  result := Parse_Factor;
  while IsCurrText('*') or IsCurrText('/') do
  begin
    if IsCurrText('*') then
    begin
      Call_SCANNER;
      result := BinOp(OP_MULT, result, Parse_Factor);
    end
    else
    begin
      Call_SCANNER;
      result := BinOp(OP_DIV, result, Parse_Factor);
    end;
  end;
end;

function TBasicParser.Parse_Factor: Integer;
var
  SubId, K: Integer;
begin
  if CurrToken.TokenClass = tcBooleanConst then
    result := Parse_BooleanLiteral
  else if CurrToken.TokenClass = tcCharConst then
    result := Parse_CharLiteral
  else if CurrToken.TokenClass = tcPCharConst then
    result := Parse_PCharLiteral
  else if CurrToken.TokenClass = tcIntegerConst then
    result := Parse_IntegerLiteral
  else if CurrToken.TokenClass = tcDoubleConst then
    result := Parse_DoubleLiteral
  else if IsCurrText('MyClass') then
  begin
    Call_SCANNER;
    Match('.');
    result := Parse_Ident;
    Gen(OP_MYCLASS, result, 0, 0);
  end
  else if IsCurrText('MyBase') then
  begin
    Call_SCANNER;
    Match('.');
    SubId := NewTempVar;
    result := NewTempVar;
    K := Parse_Ident;
    RemoveInstruction(OP_EVAL, -1, -1, K);
    Gen(OP_EVAL_INHERITED, K, 0, SubId);
    if IsCurrText('(') then
      Gen(OP_CALL, SubID, Parse_ArgumentList(SubId), result)
    else
      Gen(OP_CALL, SubID, 0, result);
  end
	else if IsCurrText('+') then
  begin
		Call_SCANNER;
		result := Parse_Factor;
  end
	else if IsCurrText('-') then
  begin
		Call_SCANNER;
		result := UnaryOp(OP_NEG, Parse_Factor);
  end
  else if IsCurrText('(') then
  begin
    Match('(');
    result := Parse_Expression;
    Match(')');
  end
  else if IsCurrText('AddressOf') then
  begin
    Match('AddressOf');
    result := NewTempVar;
    Gen(OP_ADDRESS, Parse_Designator, 0, result);
  end
  else if IsCurrText('assigned') then
  begin
    Call_SCANNER;
    Match('(');
    result := NewTempVar;
    Gen(OP_ASSIGNED, Parse_Expression, 0, result);
    Match(')');
    Exit;
  end
  else if IsCurrText('CBool') then
  begin
    Call_SCANNER;
    result := NewTempVar;
    Match('(');
    Gen(OP_PUSH, Parse_Expression, 0, typeBOOLEAN);
    Match(')');
    Gen(OP_CALL, typeBOOLEAN, 1, result);
  end
  else if IsCurrText('CByte') then
  begin
    Call_SCANNER;
    result := NewTempVar;
    Match('(');
    Gen(OP_PUSH, Parse_Expression, 0, typeBYTE);
    Match(')');
    Gen(OP_CALL, typeBYTE, 1, result);
  end
  else if IsCurrText('CChar') then
  begin
    Call_SCANNER;
    result := NewTempVar;
    Match('(');
    Gen(OP_PUSH, Parse_Expression, 0, typeCHAR);
    Match(')');
    Gen(OP_CALL, typeCHAR, 1, result);
  end
  else if IsCurrText('CDate') then
  begin
    Call_SCANNER;
    result := NewTempVar;
    Match('(');
    Gen(OP_PUSH, Parse_Expression, 0, typeDOUBLE);
    Match(')');
    Gen(OP_CALL, typeDOUBLE, 1, result);
  end
  else if IsCurrText('CDbl') then
  begin
    Call_SCANNER;
    result := NewTempVar;
    Match('(');
    Gen(OP_PUSH, Parse_Expression, 0, typeDOUBLE);
    Match(')');
    Gen(OP_CALL, typeDOUBLE, 1, result);
  end
  else if IsCurrText('CDec') then
  begin
    Call_SCANNER;
    result := NewTempVar;
    Match('(');
    Gen(OP_PUSH, Parse_Expression, 0, typeCURRENCY);
    Match(')');
    Gen(OP_CALL, typeCURRENCY, 1, result);
  end
  else if IsCurrText('CInt') then
  begin
    Call_SCANNER;
    result := NewTempVar;
    Match('(');
    Gen(OP_PUSH, Parse_Expression, 0, typeINTEGER);
    Match(')');
    Gen(OP_CALL, typeINTEGER, 1, result);
  end
  else if IsCurrText('CLong') then
  begin
    Call_SCANNER;
    result := NewTempVar;
    Match('(');
    Gen(OP_PUSH, Parse_Expression, 0, typeINTEGER);
    Match(')');
    Gen(OP_CALL, typeINTEGER, 1, result);
  end
  else if IsCurrText('CSByte') then
  begin
    Call_SCANNER;
    result := NewTempVar;
    Match('(');
    Gen(OP_PUSH, Parse_Expression, 0, typeSMALLINT);
    Match(')');
    Gen(OP_CALL, typeSMALLINT, 1, result);
  end
  else if IsCurrText('CShort') then
  begin
    Call_SCANNER;
    result := NewTempVar;
    Match('(');
    Gen(OP_PUSH, Parse_Expression, 0, typeSHORTINT);
    Match(')');
    Gen(OP_CALL, typeSHORTINT, 1, result);
  end
  else if IsCurrText('CStr') then
  begin
    Call_SCANNER;
    result := NewTempVar;
    Match('(');
    Gen(OP_PUSH, Parse_Expression, 0, typeSTRING);
    Match(')');
    Gen(OP_CALL, typeSTRING, 1, result);
  end
  else if IsCurrText('CUInt') then
  begin
    Call_SCANNER;
    result := NewTempVar;
    Match('(');
    Gen(OP_PUSH, Parse_Expression, 0, typeCARDINAL);
    Match(')');
    Gen(OP_CALL, typeCARDINAL, 1, result);
  end
  else if IsCurrText('CUlng') then
  begin
    Call_SCANNER;
    result := NewTempVar;
    Match('(');
    Gen(OP_PUSH, Parse_Expression, 0, typeCARDINAL);
    Match(')');
    Gen(OP_CALL, typeCARDINAL, 1, result);
  end
  else if IsCurrText('CUShort') then
  begin
    Call_SCANNER;
    result := NewTempVar;
    Match('(');
    Gen(OP_PUSH, Parse_Expression, 0, typeWORD);
    Match(')');
    Gen(OP_CALL, typeWORD, 1, result);
  end
  else if IsCurrText('new') then
  begin
    result := Parse_NewExpression;
  end
  else
  begin
    result := Parse_Designator;

    if IsCurrText('(') then
    begin
      SubId := result;
      result := NewTempVar;
      Gen(OP_CALL, SubID, Parse_ArgumentList(SubId), result);
    end
    else if GetKind(result) = KindSUB then
    begin
      SubId := result;
      result := NewTempVar;
      SetName(result, GetName(SubId));
      SetKind(result, KindNONE);
      Gen(OP_EVAL, 0, 0, result);

      if IsCurrText('.') or IsCurrText('[') then
        result := Parse_Designator(result);
    end;

  end;
end;

function TBasicParser.Parse_NewExpression: Integer;
var
  id, TypeId: Integer;
begin
  Match('new');
  TypeId := Parse_QualId;
  if IsCurrText('(') then
  begin
    Id := NewTempVar;
    result := NewTempVar;
    Gen(OP_EVAL_CONSTRUCTOR, TypeId, 0, Id);
    Gen(OP_CALL, Id, Parse_ArgumentList(Id), result);
  end
  else
  begin
    Id := NewTempVar;
    result := NewTempVar;
    Gen(OP_EVAL_CONSTRUCTOR, TypeId, 0, Id);
    Gen(OP_CALL, Id, 0, result);
  end;
end;

function TBasicParser.Parse_Designator(init_id: Integer = 0): Integer;
var
  ok: Boolean;
  id: Integer;
begin
  if init_id = 0 then
    result := Parse_QualId
  else
    result := init_id;

  ok := false;
  repeat
    if IsCurrText('.') then
    begin
      FIELD_OWNER_ID := result;
      id := FIELD_OWNER_ID;

      Match('.');
      result := Parse_Ident;
      Gen(OP_FIELD, id, result, result);
      ok := true;
    end
    else if IsCurrText('[') then // index
    begin
      Match('[');
      repeat
        id := result;
        result := NewTempVar;
        Gen(OP_ELEM, id, Parse_Expression, result);
        if NotMatch(',') then
           Break;
      until false;
      Match(']');
      ok := true;
    end
    else if IsCurrText('^') then
    begin
      Match('^');
      id := result;
      result := NewTempVar;
      Gen(OP_TERMINAL, id, 0, result);
    end
    else
      ok := false;
  until not ok;
end;

function TBasicParser.Parse_QualId: Integer;
var
  id: Integer;
begin
  result := Parse_Ident;

  while IsCurrText('.') do
  begin
    FIELD_OWNER_ID := result;
    id := FIELD_OWNER_ID;

    Match('.');
    result := Parse_Ident;
    Gen(OP_FIELD, id, result, result);
  end;
end;

function TBasicParser.Parse_Type: Integer;
begin
  if DECLARE_SWITCH then
    RaiseError(errInternalError, []);

  if IsCurrText('Byte') then
  begin
    result := typeBYTE;
    Call_SCANNER;
  end
  else if IsCurrText('Char') then
  begin
    result := typeCHAR;
    Call_SCANNER;
  end
  else if IsCurrText('Word') then
  begin
    result := typeWORD;
    Call_SCANNER;
  end
  else if IsCurrText('Integer') then
  begin
    result := typeINTEGER;
    Call_SCANNER;
  end
  else if IsCurrText('Boolean') then
  begin
    result := typeBOOLEAN;
    Call_SCANNER;
  end
  else if IsCurrText('Variant') then
  begin
    result := typeVARIANT;
    Call_SCANNER;
  end
  else if IsCurrText('Double') then
  begin
    result := typeDOUBLE;
    Call_SCANNER;
  end
  else if IsCurrText('Single') then
  begin
    result := typeSINGLE;
    Call_SCANNER;
  end
  else if IsCurrText('Decimal') then
  begin
    result := typeCURRENCY;
    Call_SCANNER;
  end
  else
    result := Parse_QualId;

  Gen(OP_ADD_TYPEINFO, result, 0, 0);
end;

function TBasicParser.Parse_Label: Integer;
begin
  if not (CurrToken.TokenClass in [tcIntegerConst, tcIdentifier]) then
    RaiseError(errIdentifierExpected, [CurrToken.Text]);
  result := CurrToken.Id;
  if DECLARE_SWITCH then
    SetKind(result, KindLABEL)
  else if GetKind(result) <> KindLABEL then
    RaiseError(errLabelExpected, []);
  Call_SCANNER;
end;

procedure TBasicParser.Call_SCANNER;
begin
	inherited;

	if IsCurrText('_') then
  begin
    RemoveInstruction(OP_EVAL, -1, -1, CurrToken.Id);

		Call_SCANNER();
		while IsLineTerminator do
			MatchLineTerminator();
  end
  else if IsCurrText('null') then
  begin
    CurrToken.Id := NilId;
    CurrToken.TokenClass := tcIdentifier;
  end
  else if IsCurrText('me') then
  begin
    CurrToken.Id := CurrSelfId;
    CurrToken.TokenClass := tcIdentifier;
  end
  else if IsCurrText('char') then
  begin
    CurrToken.Id := typeCHAR;
    CurrToken.TokenClass := tcIdentifier;
  end
  else if IsCurrText('integer') then
  begin
    CurrToken.Id := typeINTEGER;
    CurrToken.TokenClass := tcIdentifier;
  end
  else if IsCurrText('string') then
  begin
    CurrToken.Id := typeSTRING;
    CurrToken.TokenClass := tcIdentifier;
  end
  else if IsCurrText('short') then
  begin
    CurrToken.Id := typeSHORTINT;
    CurrToken.TokenClass := tcIdentifier;
  end
  else if IsCurrText('long') then
  begin
    CurrToken.Id := typeINTEGER;
    CurrToken.TokenClass := tcIdentifier;
  end
  else if IsCurrText('decimal') then
  begin
    CurrToken.Id := typeCURRENCY;
    CurrToken.TokenClass := tcIdentifier;
  end;
end;

function TBasicParser.Parse_Ident: Integer;
var
  id: Integer;
begin
  result := 0;
  if IsCurrText('.') then
  begin
    if with_stack.Count = 0 then
      RaiseError(errIdentifierExpected, [CurrToken.Text])
    else
    begin
      FIELD_OWNER_ID := with_stack.Top;
      id := FIELD_OWNER_ID;
      Match('.');
      result := Parse_Ident;
      Gen(OP_FIELD, id, result, result);
    end;
  end
  else
    result := inherited Parse_Ident;
end;

function TBasicParser.IsLineTerminator: Boolean;
begin
  result := IsNewLine or IsEOF;
end;

function TBasicParser.IsStatementTerminator: Boolean;
begin
 	result := IsLineTerminator or IsCurrText(':') or IsEOF;
end;

procedure TBasicParser.MatchLineTerminator;
begin
	if IsEOF then
    Exit;

	if not IsNewLine then
		RaiseError(errLineTerminatorExpected, []);

  while CurrToken.TokenClass = tcSeparator do
  begin
    Gen(OP_SEPARATOR, CurrModule.ModuleNumber, CurrToken.Id, 0);
    Call_SCANNER;
  end;
end;

procedure TBasicParser.MatchStatementTerminator;
begin
	if IsEOF then
    Exit;

	if not SKIP_STATEMENT_TERMINATOR then
		if not IsNewLine then
  		RaiseError(errStatementTerminatorExpected, []);

  while CurrToken.TokenClass = tcSeparator do
  begin
    Gen(OP_SEPARATOR, CurrModule.ModuleNumber, CurrToken.Id, 0);
    Call_SCANNER;
  end;
end;

procedure TBasicParser.PushExitKind(k: TExitKind);
begin
	exit_kind_stack.Push(Integer(k));
end;

procedure TBasicParser.PopExitKind;
begin
	exit_kind_stack.Pop;
end;

function TBasicParser.GetCurrExitKind: TExitKind;
begin
  result := TExitKind(exit_kind_stack.Top);
end;

end.
