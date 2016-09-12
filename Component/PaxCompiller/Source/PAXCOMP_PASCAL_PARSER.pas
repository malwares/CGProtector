///////////////////////////////////////////////////////////////////////////
// PaxCompiler
// Site: http://www.paxcompiler.com
// Author: Alexander Baranovsky (paxscript@gmail.com)
// ========================================================================
// Copyright (c) Alexander Baranovsky, 2006-2008. All rights reserved.
// Code Version: 2.4
// ========================================================================
// Unit: PAXCOMP_PASCAL_PARSER.pas
// ========================================================================
////////////////////////////////////////////////////////////////////////////

{$I PaxCompiler.def}
unit PAXCOMP_PASCAL_PARSER;
interface
uses
  SysUtils,
  Classes,
  PAXCOMP_CONSTANTS,
  PAXCOMP_SYS,
  PAXCOMP_BASESYMBOL_TABLE,
  PAXCOMP_SCANNER,
  PAXCOMP_BYTECODE,
  PAXCOMP_MODULE,
  PAXCOMP_STDLIB,
  PAXCOMP_PARSER,
  PAXCOMP_KERNEL;

const
  dirNONE = 0;
  dirFORWARD = 1;
  dirOVERLOAD = 2;
  dirABSTRACT = 3;
  dirVIRTUAL = 4;
  dirOVERRIDE = 5;
  dirREINTRODUCE = 6;

type
  TPascalParser = class(TBaseParser)
  private
    WasInherited: Boolean;
    ForInCounter: Integer;
    procedure GenExternalSub(SubId: Integer);
  protected
    function CreateScanner: TBaseScanner; override;
    function GetLanguageName: String; override;
    function GetFileExt: String; override;
    function GetLanguageId: Integer; override;
    function GetUpcase: Boolean; override;
  public
    constructor Create; override;
    procedure ParseProgram; override;
    procedure Call_SCANNER; override;
    procedure ReadToken; override;
    procedure InitSub(var SubId: Integer); override;
    function GetIncludedFileExt: String; override;
    procedure Init(i_kernel: Pointer; M: TModule); override;
    function Parse_DirectiveList(SubId: Integer): TIntegerList;
    function Parse_PortabilityDirective: Boolean;

    procedure GenDefaultConstructor(ClassId: Integer);
    procedure GenDefaultDestructor(ClassId: Integer);

    procedure Parse_ProgramBlock(namespace_id: Integer);
    procedure Parse_Unit(IsExternalUnit: Boolean = false); override;
    procedure Parse_Block;

    procedure Parse_NamespaceDeclaration;
    procedure Parse_UsesClause(IsImplementationSection: Boolean);
    procedure Parse_NamespaceMemberDeclaration;

    procedure Parse_DeclarationPart;
    procedure Parse_VariableDeclaration;
    procedure Parse_ConstantDeclaration(IsBuildingPCU: Boolean = false);
    procedure Parse_ResourcestringDeclaration(IsBuildingPCU: Boolean = false);
    procedure Parse_LabelDeclaration;
    function Parse_FormalParameterList(SubId: Integer;
                                          bracket: Char = '('): Integer;
    procedure Parse_ProcedureDeclaration(IsSharedMethod: Boolean = false);
    procedure Parse_FunctionDeclaration(IsSharedMethod: Boolean = false);
    procedure Parse_ConstructorDeclaration;
    procedure Parse_DestructorDeclaration;
    procedure Parse_SubBlock;
    procedure Parse_ConstantInitialization(ID: Integer);

    // types
    procedure Parse_TypeDeclaration(IsExternalUnit: Boolean = false);
    procedure Parse_ProceduralTypeDeclaration(TypeID: Integer;
                                              var SubId: Integer);
    procedure Parse_ArrayTypeDeclaration(ArrayTypeID: Integer; IsPacked: Boolean);
    procedure Parse_RecordTypeDeclaration(RecordTypeID: Integer; IsPacked: Boolean;
                                IsExternalUnit: Boolean = false);
    procedure Parse_ClassTypeDeclaration(ClassTypeID: Integer; IsPacked: Boolean;
                                         IsExternalUnit: Boolean = false);
    procedure Parse_InterfaceTypeDeclaration(IntfTypeID: Integer);
    procedure Parse_EnumTypeDeclaration(TypeID: Integer);
    procedure Parse_PointerTypeDeclaration(TypeID: Integer);
    procedure Parse_ShortStringTypeDeclaration(TypeID: Integer);
    procedure Parse_SetTypeDeclaration(TypeID: Integer);
    procedure Parse_SubrangeTypeDeclaration(TypeID, TypeBaseId: Integer; Expr1ID: Integer = 0);
    function Parse_OrdinalType: Integer;
    function Parse_Type: Integer;

    procedure ParseExternalSub(SubId: Integer);

    //statements
    procedure Parse_Statement;
    procedure Parse_CompoundStmt;
    procedure Parse_StmtList;
    procedure Parse_Write;
    procedure Parse_Writeln;
    procedure Parse_Print;
    procedure Parse_Println;
    procedure Parse_AssignmentStmt;
    procedure Parse_CaseStmt;
    procedure Parse_IfStmt;
    procedure Parse_GotoStmt;
    procedure Parse_BreakStmt;
    procedure Parse_ContinueStmt;
    procedure Parse_ExitStmt;
    procedure Parse_WhileStmt;
    procedure Parse_RepeatStmt;
    procedure Parse_ForStmt;
    procedure Parse_WithStmt;
    procedure Parse_TryStmt;
    procedure Parse_RaiseStmt;

    //expressions
    function Parse_ArgumentList(SubId: Integer): Integer;
    function Parse_ConstantExpression: Integer;
    function Parse_Expression: Integer; override;
    function Parse_SimpleExpression: Integer;
    function Parse_Term: Integer;
    function Parse_Factor: Integer; virtual;
    function Parse_SetConstructor: Integer;
    function Parse_Designator(init_id: Integer = 0): Integer;
    function Parse_QualId: Integer;
    function Parse_Label: Integer;
    function Parse_Ident: Integer; override;
  end;

implementation

uses
  PAXCOMP_PASCAL_SCANNER;

constructor TPascalParser.Create;
begin
  inherited;

  AddKeyword('abstract');
  AddKeyword('assembler');
  AddKeyword('and');
  AddKeyword('array');
  AddKeyword('as');
  AddKeyword('begin');
  AddKeyword('break');
  AddKeyword('case');
  AddKeyword('class');
  AddKeyword('const');
  AddKeyword('constructor');
  AddKeyword('continue');
  AddKeyword('deprecated');
  AddKeyword('destructor');
  AddKeyword('div');
  AddKeyword('do');
  AddKeyword('downto');
  AddKeyword('dynamic');
  AddKeyword('else');
  AddKeyword('end');
  AddKeyword('except');
  AddKeyword('exit');
  AddKeyword('external');
  AddKeyword('finally');
  AddKeyword('for');
  AddKeyword('forward');
  AddKeyword('function');
  AddKeyword('goto');
  AddKeyword('if');
  AddKeyword('implementation');
  AddKeyword('implements');
  AddKeyword('in');
  AddKeyword('inherited');
  AddKeyword('initialization');
  AddKeyword('interface');
  AddKeyword('is');
  AddKeyword('finalization');
  AddKeyword('label');
  AddKeyword('library');
  AddKeyword('namespace');
  AddKeyword('nil');
  AddKeyword('not');
  AddKeyword('object');
  AddKeyword('of');
  AddKeyword('on');
  AddKeyword('or');
  AddKeyword('overload');
  AddKeyword('override');
  AddKeyword('out');
  AddKeyword('packed');
  AddKeyword('pascal');
  AddKeyword('platform');
  AddKeyword('private');
  AddKeyword('procedure');
  AddKeyword('program');
  AddKeyword('property');
  AddKeyword('protected');
  AddKeyword('public');
  AddKeyword('published');
  AddKeyword('raise');
  AddKeyword('record');
  AddKeyword('repeat');
  AddKeyword('resourcestring');
  AddKeyword('set');
  AddKeyword('shl');
  AddKeyword('shr');
  AddKeyword('then');
  AddKeyword('to');
  AddKeyword('try');
  AddKeyword('type');
  AddKeyword('unit');
  AddKeyword('until');
  AddKeyword('uses');
  AddKeyword('var');
  AddKeyword('virtual');
  AddKeyword('while');
  AddKeyword('with');
  AddKeyword('xor');
end;

function TPascalParser.CreateScanner: TBaseScanner;
begin
  result := TPascalScanner.Create;
end;

function TPascalParser.GetLanguageName: String;
begin
  result := 'Pascal';
end;

function TPascalParser.GetFileExt: String;
begin
  result := 'pas';
end;

function TPascalParser.GetIncludedFileExt: String;
begin
  result := 'pas';
end;

function TPascalParser.GetLanguageId: Integer;
begin
  result := PASCAL_LANGUAGE;
end;

function TPascalParser.GetUpcase: Boolean;
begin
  result := true;
end;

procedure TPascalParser.Init(i_kernel: Pointer; M: TModule);
begin
  Inherited Init(i_kernel, M);
  WasInherited := true;
  ForInCounter := 0;
end;

procedure TPascalParser.GenDefaultConstructor(ClassId: Integer);
var
  SubId, Id, ResId, L: Integer;
begin
  LevelStack.Push(ClassId);
  SubId := NewTempVar;
  SetName(SubId, 'Create');
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

  Id := NewTempVar;
  ResId := NewTempVar;

  SetName(Id, 'Create');
  Gen(OP_EVAL, 0, 0, Id);
  Gen(OP_EVAL_INHERITED, Id, 0, ResId);

  SetDefault(SubId, true);
  Gen(OP_UPDATE_DEFAULT_CONSTRUCTOR, SubId, 0, ResId);
// will insertion here

  Gen(OP_CALL, ResId, 0, 0);

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

procedure TPascalParser.GenDefaultDestructor(ClassId: Integer);
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

procedure TPascalParser.Parse_DeclarationPart;
var
  ok: Boolean;
  I: Integer;
begin
  repeat
    ok := false;
    if IsCurrText('label') then
    begin
      Parse_LabelDeclaration;
      ok := true;
    end
    else if IsCurrText('var') then
    begin
      Parse_VariableDeclaration;
      ok := true;
    end
    else if IsCurrText('const') then
    begin
      Parse_ConstantDeclaration;
      ok := true;
    end
    else if IsCurrText('resourcestring') then
    begin
      Parse_ResourcestringDeclaration;
      ok := true;
    end
    else if IsCurrText('procedure') then
    begin
      Parse_ProcedureDeclaration;
      ok := true;
    end
    else if IsCurrText('function') then
    begin
      Parse_FunctionDeclaration;
      ok := true;
    end
    else if IsCurrText('class') then
    begin
      Call_SCANNER;
      if IsCurrText('procedure') then
        Parse_ProcedureDeclaration(true)
      else if IsCurrText('function') then
        Parse_FunctionDeclaration(true)
      else
        Match('procedure');
      ok := true;
    end
    else if IsCurrText('constructor') then
    begin
      Parse_ConstructorDeclaration;
      ok := true;
    end
    else if IsCurrText('destructor') then
    begin
      Parse_DestructorDeclaration;
      ok := true;
    end
    else if IsCurrText('type') then
    begin
      Parse_TypeDeclaration;
      ok := true;
    end
  until not ok;

  if GetKind(LevelStack.Top) in [KindSUB, KindCONSTRUCTOR, kindDESTRUCTOR] then
    Exit;

  for I:=0 to ScriptClasses.Count - 1 do
  begin
    if FindConstructorId(ScriptClasses[I]) = 0 then
      GenDefaultConstructor(ScriptClasses[I]);
    if FindDestructorId(ScriptClasses[I]) = 0 then
      GenDefaultDestructor(ScriptClasses[I]);
  end;
end;

procedure TPascalParser.ParseProgram;
var
  namespace_id: Integer;
begin
  EXECUTABLE_SWITCH := 0;
  Call_SCANNER;

  namespace_id := 0;

  if IsCurrText('program') then
  begin
    DECLARE_SWITCH := true;
    Call_SCANNER;
//    SetKind(CurrToken.Id, KindNONE);
//    Call_SCANNER;
    namespace_id := Parse_Ident;
    DECLARE_SWITCH := false;
    Match(';');
  end;

  if IsCurrText('unit') then
    Parse_Unit
  else
    Parse_ProgramBlock(namespace_id);
end;

procedure TPascalParser.Parse_NamespaceDeclaration;
var
  l: TIntegerList;
  i, namespace_id: Integer;
begin
  DECLARE_SWITCH := true;
	Match('namespace');

  l := TIntegerList.Create;

  try
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
        Match('end');
      if IsCurrText('end') then
        break;
      Parse_NamespaceMemberDeclaration;
    until false;

    for i := l.Count - 1 downto 0 do
      EndNamespace(l[i]);

  finally
    l.Free;
  end;

  Match('end');
  Match(';');
end;

procedure TPascalParser.Parse_UsesClause(IsImplementationSection: Boolean);
var
  unit_id, id: Integer;
  S: String;
  AlreadyExists: Boolean;
  L: TStringList;
begin
  DECLARE_SWITCH := false;
	Match('uses');

  L := TStringList.Create;

  try
    repeat
      if L.IndexOf(Uppercase(CurrToken.Text)) >= 0 then
        CreateError(errRedeclaredIdentifier, [CurrToken.Text]);
      L.Add(Uppercase(CurrToken.Text));

      unit_id := Parse_QualId;

      AlreadyExists := GetKind(unit_id) = kindNAMESPACE;

      Gen(OP_BEGIN_USING, unit_id, 0, 0);

      if IsCurrText('in') then
      begin
        Call_SCANNER;
        id := Parse_PCharLiteral;
        S := GetValue(id);

        AlreadyExists := false;
      end
      else
        S := GetName(unit_id) + '.' + GetFileExt;

      if not AlreadyExists then
        AddModuleFromFile(S, unit_id, IsImplementationSection);

      if NotMatch(',') then
        Break;
    until false;

  finally
    L.Free;
  end;

  Match(';');
end;

procedure TPascalParser.Parse_NamespaceMemberDeclaration;
begin
  if IsCurrText('type') then
    Parse_TypeDeclaration
  else if IsCurrText('procedure') then
    Parse_ProcedureDeclaration
  else if IsCurrText('function') then
    Parse_FunctionDeclaration
  else if IsCurrText('class') then
  begin
    Call_SCANNER;
    if IsCurrText('procedure') then
      Parse_ProcedureDeclaration(true)
    else if IsCurrText('function') then
      Parse_FunctionDeclaration(true)
    else
      Match('procedure');
  end
  else if IsCurrText('var') then
    Parse_VariableDeclaration
  else if IsCurrText('const') then
    Parse_ConstantDeclaration
  else if IsCurrText('resourcestring') then
    Parse_ResourcestringDeclaration
  else
    Match('end');
end;

procedure TPascalParser.Parse_Statement;
begin
  if CurrToken.TokenClass = tcIdentifier then
    if GetKind(CurrToken.Id) = KindLABEL then
    if GetName(CurrToken.Id) <> '' then
    begin
      SetLabelHere(CurrToken.Id);
      Call_SCANNER;
      Match(':');
    end;

  Gen(OP_STMT, 0, 0, 0);
  
  if IsCurrText('begin') then
    Parse_CompoundStmt
  else if IsCurrText('case') then
    Parse_CaseStmt
  else if IsCurrText('if') then
    Parse_IfStmt
  else if IsCurrText('goto') then
    Parse_GotoStmt
  else if IsCurrText('while') then
    Parse_WhileStmt
  else if IsCurrText('repeat') then
    Parse_RepeatStmt
  else if IsCurrText('for') then
    Parse_ForStmt
  else if IsCurrText('break') then
    Parse_BreakStmt
  else if IsCurrText('continue') then
    Parse_ContinueStmt
  else if IsCurrText('exit') then
    Parse_ExitStmt
  else if IsCurrText('with') then
    Parse_WithStmt
  else if IsCurrText('try') then
    Parse_TryStmt
  else if IsCurrText('raise') then
    Parse_RaiseStmt
  else
  begin
    if IsCurrText('write') then
    begin
      Call_SCANNER;
      Parse_Write;
    end
    else if IsCurrText('writeln') then
    begin
      Call_SCANNER;
      Parse_Writeln;
    end
    else if IsCurrText(PrintKeyword) then
    begin
      if (CurrToken.Id > StdCard) and (GetKind(CurrToken.Id) = kindSUB) then
        Parse_AssignmentStmt
      else
      begin
        Call_SCANNER;
        Parse_Print;
      end;
    end
    else if IsCurrText(PrintlnKeyword) then
    begin
      if (CurrToken.Id > StdCard) and (GetKind(CurrToken.Id) = kindSUB) then
        Parse_AssignmentStmt
      else
      begin
        Call_SCANNER;
        Parse_Println;
      end;
    end
    else
      Parse_AssignmentStmt;
  end;
end;

procedure TPascalParser.Parse_Write;
var
  ID, ID_L1, ID_L2: Integer;
begin
  IsConsoleApp := true;

  Match('(');
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

    Gen(OP_PRINT, ID, ID_L1, ID_L2);
    if NotMatch(',') then
      Break;
  until false;
  Match(')');
end;

procedure TPascalParser.Parse_Writeln;
begin
  IsConsoleApp := true;

  if IsCurrText('(') then
    Parse_Write;
  Gen(OP_PRINT, 0, 0, 0);
end;

procedure TPascalParser.Parse_Print;
var
  ID, ID_L1, ID_L2: Integer;
begin
  if IsCurrText(';') then
  begin
    Exit;
  end;

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

procedure TPascalParser.Parse_Println;
begin
  if not IsCurrText(';') then
    Parse_Print;
  Gen(OP_PRINT_EX, NewConst(typeANSISTRING, #13#10), 0, 0);
end;

procedure TPascalParser.Parse_Block;
begin
  DECLARE_SWITCH := true;
  Parse_DeclarationPart;
  Parse_CompoundStmt;
end;

procedure TPascalParser.Parse_ProgramBlock(namespace_id: Integer);
var
  B1, B2: Integer;
begin
  {$IFDEF ZERO_NS}
  namespace_id := 0;
  {$ENDIF}
  while IsCurrText('uses') do
    Parse_UsesClause(false);

  Gen(OP_END_IMPORT, 0, 0, 0);
  B1 := CodeCard;

  if namespace_id > 0 then
    BeginNamespace(namespace_id, false);

  while IsCurrText('namespace') do
    Parse_NamespaceDeclaration;

// parse block

  DECLARE_SWITCH := true;
  Parse_DeclarationPart;

  Gen(OP_END_INTERFACE_SECTION, CurrModule.ModuleNumber, 0, 0);

  Gen(OP_BEGIN_GLOBAL_BLOCK, 0, 0, 0);
  Gen(OP_NOP, 0, 0, 0);

  Parse_CompoundStmt;

  B2 := CodeCard;

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

  if IsCurrText('.') then
  begin
    // ok
  end
  else
    Match('.');

  if namespace_id > 0 then
    EndNamespace(namespace_id, false);
end;

procedure TPascalParser.GenExternalSub(SubId: Integer);
var
  SubNameId, LibId, namespace_id: Integer;
  S, TypeName: String;
begin
  namespace_id := GetLevel(SubId);
  if GetKind(namespace_id) = kindTYPE then
    TypeName := GetName(namespace_id)
  else
    TypeName := '';

  while GetKind(namespace_id) <> kindNAMESPACE do
    namespace_id := GetLevel(namespace_id);

  SetForward(SubId, false);

  SetExternal(SubId, true);

  ReplaceForwardDeclaration(SubId, true);
  S := GetName(SubId);
  if TypeName <> '' then
    S := TypeName + '.' + S;
  SubNameId := NewConst(typeSTRING, S);
  EndSub(SubId);
  RemoveSub;

  LibId := NewConst(typeSTRING,
    GetName(namespace_id) + '.' + PCU_FILE_EXT);

  Gen(OP_LOAD_PROC, SubId, SubNameId, LibId);
end;

procedure TPascalParser.Parse_Unit(IsExternalUnit: Boolean = false);
var
  namespace_id, B1, B2: Integer;

  procedure Parse_InterfaceSection;

    procedure Parse_ProcedureHeading;
    var
      SubId, NP: Integer;
      DirectiveList: TIntegerList;
    begin
      DECLARE_SWITCH := true;
      Match('procedure');
      SubId := Parse_Ident;
      BeginSub(SubId);
      if IsCurrText('(') then
        NP := Parse_FormalParameterList(SubId)
      else
        NP := 0;
      SetCount(SubId, NP);
      SetName(CurrResultId, '');
      SetKind(CurrResultId, KindNONE);
      SetType(SubId, TypeVOID);
      SetType(CurrResultId, TypeVOID);

      if InterfaceOnly then
      begin
        if IsCurrText(';') then
          Match(';');
      end
      else
        Match(';');

      DirectiveList := Parse_DirectiveList(SubId);
      DirectiveList.Free;

      if IsCurrText('external') then
      begin
        ParseExternalSub(SubId);
        Exit;
      end;

      if IsExternalUnit then
      begin
        GenExternalSub(SubId);
        Exit;
      end;

      SetForward(SubId, true);
      EndSub(SubId);
    end;

    procedure Parse_FunctionHeading;
    var
      SubId, TypeId, NP: Integer;
      DirectiveList: TIntegerList;
    begin
      DECLARE_SWITCH := true;
      Match('function');
      SubId := Parse_Ident;
      BeginSub(SubId);
      if IsCurrText('(') then
        NP := Parse_FormalParameterList(SubId)
      else
        NP := 0;
      SetCount(SubId, NP);
      DECLARE_SWITCH := false;
      Match(':');
      DECLARE_SWITCH := true;
      TypeID := Parse_Type;
      Gen(OP_ASSIGN_TYPE, SubId, TypeID, 0);
      Gen(OP_ASSIGN_TYPE, CurrResultId, TypeID, 0);

      DECLARE_SWITCH := true;

      if InterfaceOnly then
      begin
        if IsCurrText(';') then
          Match(';');
      end
      else
        Match(';');

      DirectiveList := Parse_DirectiveList(SubId);
      DirectiveList.Free;

      if IsCurrText('external') then
      begin
        ParseExternalSub(SubId);
        Exit;
      end;

      if IsExternalUnit then
      begin
        GenExternalSub(SubId);
        Exit;
      end;

      SetForward(SubId, true);
      EndSub(SubId);
    end;

  var
    ok: Boolean;
  begin
    Match('interface');
    while IsCurrText('uses') do
      Parse_UsesClause(false);

    Gen(OP_END_IMPORT, 0, 0, 0);

    BeginNamespace(namespace_id);

    B1 := CodeCard;

    repeat
      ok := false;
      if IsCurrText('var') then
      begin
        Parse_VariableDeclaration;
        ok := true;
      end
      else if IsCurrText('const') then
      begin
        Parse_ConstantDeclaration(BuildingAll);
        ok := true;
      end
      else if IsCurrText('resourcestring') then
      begin
        Parse_ResourcestringDeclaration(BuildingAll);
        ok := true;
      end
      else if IsCurrText('procedure') then
      begin
        Parse_ProcedureHeading;
        ok := true;
      end
      else if IsCurrText('function') then
      begin
        Parse_FunctionHeading;
        ok := true;
      end
      else if IsCurrText('type') then
      begin
        Parse_TypeDeclaration(IsExternalUnit);
        ok := true;
      end
    until not ok;
  end; // interface section

  procedure Parse_ImplementationSection;
  var
    HasUsesClause: Boolean;
  begin
    Match('implementation');
    HasUsesClause := IsCurrText('uses');
    while IsCurrText('uses') do
      Parse_UsesClause(true);
    if HasUsesClause then
      Gen(OP_BEGIN_USING, namespace_id, 0, 0);
    Parse_DeclarationPart;
    if HasUsesClause then
      Gen(OP_END_USING, namespace_id, 0, 0);
  end;

  procedure Parse_InitSection;
  begin
    DECLARE_SWITCH := false;
    if IsCurrText('initialization') then
    begin
      BeginInitialization;
                                          
      Gen(OP_BEGIN_GLOBAL_BLOCK, 0, 0, 0);
      Gen(OP_NOP, 0, 0, 0);

      Call_SCANNER;
      Parse_StmtList;

      Gen(OP_EPILOGUE_GLOBAL_BLOCK, 0, 0, 0);
      Gen(OP_NOP, 0, 0, 0);
      Gen(OP_NOP, 0, 0, 0);
      Gen(OP_EPILOGUE_GLOBAL_BLOCK2, 0, 0, 0);

      Gen(OP_NOP, 0, 0, 0);
      Gen(OP_NOP, 0, 0, 0);
      Gen(OP_NOP, 0, 0, 0);
      Gen(OP_NOP, 0, 0, 0);
      Gen(OP_END_GLOBAL_BLOCK, 0, 0, 0);

      EndInitialization;
      if IsCurrText('finalization') then
      begin
        BeginFinalization;

        Gen(OP_BEGIN_GLOBAL_BLOCK, 0, 0, 0);
        Gen(OP_NOP, 0, 0, 0);

        Call_SCANNER;
        Parse_StmtList;

        B2 := CodeCard;

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
      end
      else
      begin
        BeginFinalization;

        Gen(OP_BEGIN_GLOBAL_BLOCK, 0, 0, 0);
        Gen(OP_NOP, 0, 0, 0);

        B2 := CodeCard;

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

      Match('end');
    end
    else if IsCurrText('begin') then
    begin
      BeginInitialization;

      Gen(OP_BEGIN_GLOBAL_BLOCK, 0, 0, 0);
      Gen(OP_NOP, 0, 0, 0);

      Call_SCANNER;
      Parse_StmtList;

      Gen(OP_EPILOGUE_GLOBAL_BLOCK, 0, 0, 0);
      Gen(OP_NOP, 0, 0, 0);
      Gen(OP_NOP, 0, 0, 0);
      Gen(OP_EPILOGUE_GLOBAL_BLOCK2, 0, 0, 0);

      Gen(OP_NOP, 0, 0, 0);
      Gen(OP_NOP, 0, 0, 0);
      Gen(OP_NOP, 0, 0, 0);
      Gen(OP_NOP, 0, 0, 0);
      Gen(OP_END_GLOBAL_BLOCK, 0, 0, 0);

      EndInitialization;
      Match('end');

      BeginFinalization;

      Gen(OP_BEGIN_GLOBAL_BLOCK, 0, 0, 0);
      Gen(OP_NOP, 0, 0, 0);

      B2 := CodeCard;

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

    end
    else if IsCurrText('finalization') then
    begin
      BeginFinalization;

      Gen(OP_BEGIN_GLOBAL_BLOCK, 0, 0, 0);
      Gen(OP_NOP, 0, 0, 0);

      Call_SCANNER;
      Parse_StmtList;

      B2 := CodeCard;

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
      Match('end');
    end
    else if IsCurrText('end') then
    begin
      BeginFinalization;

      Gen(OP_BEGIN_GLOBAL_BLOCK, 0, 0, 0);
      Gen(OP_NOP, 0, 0, 0);

      Call_SCANNER;

      B2 := CodeCard;

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
    end
    else
      Match('end');
  end;

begin
  DECLARE_SWITCH := true;
  Match('unit');
  namespace_id := Parse_Ident;
  Parse_PortabilityDirective;
  Match(';');
  Parse_InterfaceSection;

  if IsExternalUnit then
  begin
    Match('implementation');
    Exit;
  end;

  Gen(OP_END_INTERFACE_SECTION, CurrModule.ModuleNumber, 0, 0);

  if InterfaceOnly then
  begin
    Match('implementation');
    EndNamespace(namespace_id);
  end
  else
  begin
    Parse_ImplementationSection;
    Inc(EXECUTABLE_SWITCH);
    Parse_InitSection;
    Dec(EXECUTABLE_SWITCH);
    EndNamespace(namespace_id);
    Match('.');
  end;
end;

procedure TPascalParser.Parse_VariableDeclaration;
var
  L: TIntegerList;
  I, ID, TypeID, ExprID: Integer;
  S: String;
  VarNameId, LibId: Integer;
begin
  L := TIntegerList.Create;
  try
    if InterfaceOnly then
      Gen(OP_BEGIN_VAR, 0, 0, 0);

    DECLARE_SWITCH := true;
    Match('var');

    repeat

      L.Clear;
      repeat
        ID := Parse_Ident;
        Gen(OP_DECLARE_LOCAL_VAR, CurrLevel, ID, 0);
        L.Add(ID);
        if NotMatch(',') then break;
      until false;
      DECLARE_SWITCH := false;
      Match(':');
      TypeID := Parse_Type;
      for I:=0 to L.Count - 1 do
        Gen(OP_ASSIGN_TYPE, L[I], TypeID, 0);

      if IsCurrText('=') then
      begin
        if GetKind(CurrLevel) = KindSUB then
          CreateError(errCannotInitializeLocalVariables, []);
        DECLARE_SWITCH := false;

        Match('=');
        if L.Count = 1 then
          Parse_ConstantInitialization(L[0])
        else
        begin
          ExprID := Parse_ConstantExpression;
          for I:=0 to L.Count - 1 do
            Gen(OP_ASSIGN_CONST, L[I], ExprID, L[I]);
        end;
      end;

      Parse_PortabilityDirective;

      DECLARE_SWITCH := true;
      Match(';');

      if IsCurrText('external') then
      begin
        S := GetName(Id);
        VarNameId := NewConst(typeSTRING, S);
        ReadToken; // skip external
        if CurrToken.TokenClass = tcPCharConst then
        begin
          S := RemoveCh('''', CurrToken.Text);
          LibId := NewConst(typeSTRING, S);
        end
        else
        begin
          LibId := Lookup(S, CurrLevel);

          if LibId = 0 then
            RaiseError(errUndeclaredIdentifier, [S]);

          if not IsStringConst(LibId) then
            RaiseError(errIncompatibleTypesNoArgs, []);
        end;

        ReadToken;
        Gen(OP_LOAD_PROC, Id, VarNameId, LibId);
        Match(';');
        Exit;
      end;


    until CurrToken.TokenClass <> tcIdentifier;

  finally
    if InterfaceOnly then
      Gen(OP_END_VAR, 0, 0, 0);

    L.Free;
  end;
end;

procedure TPascalParser.Parse_ConstantDeclaration(IsBuildingPCU: Boolean = false);
var
  ID: Integer;
  S: String;
  VarNameId, LibId: Integer;
begin
  Gen(OP_EMIT_OFF, 0, 0, 0);

  DECLARE_SWITCH := true;
  Match('const');

  repeat

    ID := Parse_Ident;

    if InterfaceOnly then
      Gen(OP_BEGIN_CONST, Id, 0, 0);

    Gen(OP_DECLARE_LOCAL_VAR, CurrLevel, ID, 0);

    SetKind(ID, kindCONST);
    DECLARE_SWITCH := false;
    if IsCurrText(':') then
    begin
      Match(':');
      Gen(OP_ASSIGN_TYPE, ID, Parse_Type, 0);
      levelStack.Push(CurrNamespaceId);
      Match('=');
      Parse_ConstantInitialization(ID);
      levelStack.Pop;
    end
    else
    begin
      levelStack.Push(CurrNamespaceId);
      Match('=');
      if IsBuildingPCU or IsCurrText('[') then
        Parse_ConstantInitialization(ID)
      else
        Gen(OP_ASSIGN_CONST, ID, Parse_ConstantExpression, ID);
      levelStack.Pop;
    end;
    DECLARE_SWITCH := true;

    if InterfaceOnly then
      Gen(OP_END_CONST, Id, 0, 0);

    Parse_PortabilityDirective;

    Match(';');

    if IsCurrText('external') then
    begin
      S := GetName(Id);
      VarNameId := NewConst(typeSTRING, S);
      ReadToken; // skip external
      if CurrToken.TokenClass = tcPCharConst then
      begin
        S := RemoveCh('''', CurrToken.Text);
        LibId := NewConst(typeSTRING, S);
      end
      else
      begin
        LibId := Lookup(S, CurrLevel);

        if LibId = 0 then
          RaiseError(errUndeclaredIdentifier, [S]);

        if not IsStringConst(LibId) then
          RaiseError(errIncompatibleTypesNoArgs, []);
      end;

      ReadToken;
      Gen(OP_LOAD_PROC, Id, VarNameId, LibId);
      Match(';');
      Exit;
    end;

  until CurrToken.TokenClass <> tcIdentifier;

  Gen(OP_EMIT_ON, 0, 0, 0);
end;

procedure TPascalParser.Parse_ResourcestringDeclaration(IsBuildingPCU: Boolean = false);
var
  ID: Integer;
begin
  Gen(OP_EMIT_OFF, 0, 0, 0);

  DECLARE_SWITCH := true;
  Match('resourcestring');

  repeat

    ID := Parse_Ident;
    Gen(OP_DECLARE_LOCAL_VAR, CurrLevel, ID, 0);

    SetKind(ID, kindCONST);
    DECLARE_SWITCH := false;
    Match('=');
    if IsBuildingPCU then
      Parse_ConstantInitialization(ID)
    else
      Gen(OP_ASSIGN_CONST, ID, Parse_ConstantExpression, ID);
    DECLARE_SWITCH := true;
    Match(';');

  until CurrToken.TokenClass <> tcIdentifier;

  Gen(OP_EMIT_ON, 0, 0, 0);
end;

procedure TPascalParser.Parse_ConstantInitialization(ID: Integer);
var
  ExprId, ItemId, NameId, K: Integer;
begin
  if GetKind(Id) = KindCONST then
    SetTypedConst(ID);
  Gen(OP_BEGIN_INIT_CONST, ID, 0, 0);
  if IsCurrText('(') then
  begin
    K := -1;
    Call_SCANNER;
    repeat
      Inc(K);
      if IsCurrText('(') then
      begin
        ExprId := NewTempVar();
        SetLevel(ExprId, 0);
        Parse_ConstantInitialization(ExprId);
        Gen(OP_ASSIGN_SHIFT, 0, K, ExprId);
        if NotMatch(',') then
          break;
      end
      else
      begin
        ItemId := NewTempVar();
        SetLevel(ItemId, 0);

        if IsNextText(':') then
        begin
          SetName(CurrToken.Id, '');
          SetKind(CurrToken.Id, KindNONE);
          NameId := NewConst(typeSTRING,  CurrToken.Text);
          SetKind(NameId, kindNONE);

          Call_SCANNER;
          Match(':');
          if IsCurrText('(') then
          begin
            ExprId := NewTempVar();
            SetLevel(ExprId, 0);

            Parse_ConstantInitialization(ExprId);
            Gen(OP_ASSIGN_SHIFT, 0, K, ExprId);
          end
          else
          begin
            ExprId := Parse_ConstantExpression;
            Gen(OP_RECORD_ITEM, ID, NameId, ItemId);
            Gen(OP_ASSIGN, ItemId, ExprId, ItemId);
          end;
          if NotMatch(';') then
            break;
        end
        else
        begin
          ExprId := Parse_ConstantExpression;
          Gen(OP_ITEM, ID, K, ItemId);
          Gen(OP_ASSIGN, ItemId, ExprId, ItemId);
          if NotMatch(',') then
            break;
        end;
      end;
    until false;
    Match(')');
  end
  else
  begin
    Gen(OP_ASSIGN, ID, Parse_ConstantExpression, ID);
  end;
  Gen(OP_END_INIT_CONST, ID, 0, 0);
end;

procedure TPascalParser.Parse_LabelDeclaration;
begin
  DECLARE_SWITCH := true;
  Match('label');
  repeat
    Parse_Label;
    if NotMatch(',') then break;
  until false;
  Match(';');
end;

procedure TPascalParser.Parse_TypeDeclaration(IsExternalUnit: Boolean = false);
var
  ok: Boolean;
  TypeID, T, SubId, TypeBaseId: Integer;
  IsPacked: Boolean;
  DirectiveList: TIntegerList;
begin
  DECLARE_SWITCH := true;
  Match('type');
  repeat
    TypeId := Parse_Ident;
    SetKind(TypeID, KindTYPE);
    DECLARE_SWITCH := false;

    if InterfaceOnly then
      Gen(OP_BEGIN_TYPE, TypeId, 0, 0);

    Match('=');

    if IsCurrText('packed') then
    begin
      Match('packed');
      IsPacked := true;
    end
    else
      IsPacked := false;

    if IsCurrText('array') then
    begin
      IsPacked := true;
      Parse_ArrayTypeDeclaration(TypeID, IsPacked);
      Parse_PortabilityDirective;

      DECLARE_SWITCH := true;
      Match(';');
      ok := true;
    end
    else if IsCurrText('record') then
    begin
      DECLARE_SWITCH := true;
      Parse_RecordTypeDeclaration(TypeID, IsPacked);
      Parse_PortabilityDirective;

      DECLARE_SWITCH := true;
      Match(';');
      ok := true;
    end
    else if IsCurrText('class') then
    begin
      IsPacked := true;
      DECLARE_SWITCH := true;
      Parse_ClassTypeDeclaration(TypeID, IsPacked, IsExternalUnit);
      Parse_PortabilityDirective;

      DECLARE_SWITCH := true;
      Match(';');
      ok := true;
    end
    else if IsCurrText('interface') then
    begin
      DECLARE_SWITCH := true;
      Parse_InterfaceTypeDeclaration(TypeID);
      Parse_PortabilityDirective;

      DECLARE_SWITCH := true;
      Match(';');
      ok := true;
    end
    else if IsCurrText('^') then
    begin
      if IsPacked then
        CreateError(errPACKEDNotAllowedHere, []);
      Parse_PointerTypeDeclaration(TypeID);
      Parse_PortabilityDirective;

      DECLARE_SWITCH := true;
      Match(';');
      ok := true;
    end
    else if IsCurrText('(') then
    begin
      if IsPacked then
        CreateError(errPACKEDNotAllowedHere, []);

      DECLARE_SWITCH := true;
      Parse_EnumTypeDeclaration(TypeID);
      Parse_PortabilityDirective;

      DECLARE_SWITCH := true;
      Match(';');
      ok := true;
    end
    else if IsCurrText('procedure') or IsCurrText('function') then
    begin
      if IsPacked then
        CreateError(errPACKEDNotAllowedHere, []);

      DECLARE_SWITCH := true;
      Parse_ProceduralTypeDeclaration(TypeID, SubId);

      DECLARE_SWITCH := true;
      if InterfaceOnly then
      begin
        if IsCurrText(';') then
          Match(';');
      end
      else
        Match(';');
      DirectiveList := Parse_DirectiveList(SubId);
      DirectiveList.Free;

      ok := true;
    end
    else if IsCurrText('set') then
    begin
      if IsPacked then
        CreateError(errPACKEDNotAllowedHere, []);

      DECLARE_SWITCH := true;
      Parse_SetTypeDeclaration(TypeID);
      Parse_PortabilityDirective;

      DECLARE_SWITCH := true;
      Match(';');
      ok := true;
    end
    else if CurrToken.TokenClass = tcIntegerConst then
    begin
      if IsPacked then
        CreateError(errPACKEDNotAllowedHere, []);

      Parse_SubrangeTypeDeclaration(TypeID, typeINTEGER);
      Parse_PortabilityDirective;

      DECLARE_SWITCH := true;
      Match(';');
      ok := true;
    end
    else if CurrToken.TokenClass = tcCharConst then
    begin
      if IsPacked then
        CreateError(errPACKEDNotAllowedHere, []);

      Parse_SubrangeTypeDeclaration(TypeID, typeCHAR);
      Parse_PortabilityDirective;

      DECLARE_SWITCH := true;
      Match(';');
      ok := true;
    end
    else if CurrToken.TokenClass = tcBooleanConst then
    begin
      if IsPacked then
        CreateError(errPACKEDNotAllowedHere, []);

      Parse_SubrangeTypeDeclaration(TypeID, typeBOOLEAN);
      Parse_PortabilityDirective;

      DECLARE_SWITCH := true;
      Match(';');
      ok := true;
    end
    else
    begin
      if IsPacked then
        CreateError(errPACKEDNotAllowedHere, []);

      if IsCurrText('type') then
        Call_SCANNER;

      if IsCurrText('string') then
      begin
        Call_SCANNER;
        if IsCurrText('[') then
        begin
          Parse_ShortStringTypeDeclaration(TypeID);
        end
        else
        begin
          if InterfaceOnly then
            Gen(OP_BEGIN_ALIAS_TYPE, TypeId, 0, 0);
          SetType(TypeId, typeALIAS);
          Gen(OP_ASSIGN_TYPE_ALIAS, TypeId, typeSTRING, 0);
          if InterfaceOnly then
            Gen(OP_END_ALIAS_TYPE, TypeId, 0, 0);
        end;
      end
      else
      begin
        case CurrToken.TokenClass of
          tcSpecial: typeBaseId := typeINTEGER;
          tcIntegerConst: typeBaseId := typeINTEGER;
          tcCharConst: typeBaseId := typeANSICHAR;
          tcBooleanConst: typeBaseId := typeBOOLEAN;
          tcIdentifier: typeBaseId := GetType(CurrToken.Id);
        else
          TypeBaseId := typeINTEGER;
        end;

        T := Parse_Expression;

        if IsCurrText('..') then
          Parse_SubrangeTypeDeclaration(TypeID, TypeBaseId, T)
        else
        begin
          if InterfaceOnly then
            Gen(OP_BEGIN_ALIAS_TYPE, TypeId, 0, 0);
          SetType(TypeId, typeALIAS);
          Gen(OP_ASSIGN_TYPE_ALIAS, TypeId, T, 0);
          if InterfaceOnly then
            Gen(OP_END_ALIAS_TYPE, TypeId, 0, 0);
        end;
      end;

      Parse_PortabilityDirective;

      DECLARE_SWITCH := true;
      Match(';');
      ok := true;
    end;

    Gen(OP_ADD_TYPEINFO, TypeId, 0, 0);

    if InterfaceOnly then
      Gen(OP_END_TYPE, TypeId, 0, 0);

    if CurrToken.TokenClass = tcKeyword then
      Break;
  until not ok;
end;

function TPascalParser.Parse_OrdinalType: Integer;
var
  T: Integer;
begin
  if IsCurrText('(') then
  begin
    result := NewTempVar;
    Parse_EnumTypeDeclaration(result);
  end
  else if (CurrToken.TokenClass = tcIntegerConst) or IsCurrText('-') then
  begin
    result := NewTempVar;
    Parse_SubrangeTypeDeclaration(result, typeINTEGER);
  end
  else if CurrToken.TokenClass = tcCharConst then
  begin
    result := NewTempVar;
    Parse_SubrangeTypeDeclaration(result, typeANSICHAR);
  end
  else if CurrToken.TokenClass = tcBooleanConst then
  begin
    result := NewTempVar;
    Parse_SubrangeTypeDeclaration(result, typeBOOLEAN);
  end
  else
  begin
    T := Parse_QualId;

    if IsCurrText('..') then
    begin
      result := NewTempVar;
      Parse_SubrangeTypeDeclaration(result, typeENUM, T);
    end
    else
      result := T;
  end;
end;

function TPascalParser.Parse_Type: Integer;
var
  IsPacked: Boolean;
  SubId: Integer;
  DirectiveList: TIntegerList;
begin
  if IsCurrText('packed') then
  begin
    Match('packed');
    IsPacked := true;
  end
  else
    IsPacked := false;

  if IsCurrText('array') then
  begin
    result := NewTempVar;
    DECLARE_SWITCH := true;
    Parse_ArrayTypeDeclaration(result, IsPacked);
    DECLARE_SWITCH := false;
  end
  else if IsCurrText('record') then
  begin
    result := NewTempVar;
    DECLARE_SWITCH := true;
    Parse_RecordTypeDeclaration(result, IsPacked);
    DECLARE_SWITCH := false;
  end
  else if IsCurrText('class') then
  begin
    result := NewTempVar;
    DECLARE_SWITCH := true;
    Parse_ClassTypeDeclaration(result, IsPacked);
    DECLARE_SWITCH := false;
  end
  else if IsCurrText('interface') then
  begin
    result := NewTempVar;
    DECLARE_SWITCH := true;
    Parse_InterfaceTypeDeclaration(result);
    DECLARE_SWITCH := false;
  end
  else if IsCurrText('^') then
  begin
    result := NewTempVar;
    Parse_PointerTypeDeclaration(result);
    DECLARE_SWITCH := false;
  end
  else if IsCurrText('set') then
  begin
    result := NewTempVar;
    Parse_SetTypeDeclaration(result);
    DECLARE_SWITCH := false;
  end
  else if IsCurrText('procedure') or IsCurrText('function') then
  begin
    result := NewTempVar;
    Parse_ProceduralTypeDeclaration(result, SubId);
    DirectiveList := Parse_DirectiveList(SubId);
    DirectiveList.Free;

    DECLARE_SWITCH := false;
  end
  else if IsCurrText('string') then
  begin
    result := Parse_Ident;
    if IsCurrText('[') then
    begin
      result := NewTempVar;
      Parse_ShortStringTypeDeclaration(result);
      DECLARE_SWITCH := false;
    end;
  end
  else if IsCurrText('double') then
  begin
    result := Parse_Ident;
  end
  else
    result := Parse_OrdinalType;

  Gen(OP_ADD_TYPEINFO, result, 0, 0);
end;

procedure TPascalParser.Parse_ArrayTypeDeclaration(ArrayTypeID: Integer; IsPacked: Boolean);
var
  I, T: Integer;
  L: TIntegerList;
begin
  L := TIntegerList.Create;

  try
    Match('array');
    DECLARE_SWITCH := false;

    if IsCurrText('of') then // dynamic array
    begin
      Match('of');
      BeginDynamicArrayType(ArrayTypeID);
      if IsCurrText('const') then
      begin
        Call_SCANNER;
        Gen(OP_CREATE_DYNAMIC_ARRAY_TYPE, ArrayTypeId, H_TVarRec, 0)
      end
      else
        Gen(OP_CREATE_DYNAMIC_ARRAY_TYPE, ArrayTypeId, Parse_Ident, 0);
      EndDynamicArrayType(ArrayTypeID);
    end
    else // static array
    begin

      BeginArrayType(ArrayTypeID);
      if IsPacked then
        SetPacked(ArrayTypeID);
      L.Add(ArrayTypeId);

      Match('[');
      repeat
        T := NewTypeAlias;
        Gen(OP_ASSIGN_TYPE_ALIAS, T, Parse_OrdinalType, 0);

        if IsCurrText(',') then
        begin
          Match(',');

          ArrayTypeId := NewTempVar;
          BeginArrayType(ArrayTypeID);
          if IsPacked then
            SetPacked(ArrayTypeID);
          L.Add(ArrayTypeId);
        end
        else
          break;
      until false;

      Match(']');
      Match('of');

      T := NewTypeAlias;
      Gen(OP_ASSIGN_TYPE_ALIAS, T, Parse_Type, 0);

      DECLARE_SWITCH := true;

      for I:=0 to L.Count - 1 do
      begin
        EndArrayType(L[I]);
      end;

    end;
  finally
    L.Free;
  end;
end;

procedure TPascalParser.Parse_RecordTypeDeclaration(RecordTypeID: Integer; IsPacked: Boolean;
                                    IsExternalUnit: Boolean = false);
var
  vis: TClassVisibility;

  function Parse_ConstructorHeading: Integer;
  var
    NP: Integer;
    DirectiveList: TIntegerList;
  begin
    DECLARE_SWITCH := true;
    Match('constructor');
    result := Parse_Ident;
    SetVisibility(result, vis);
    BeginStructureConstructor(result, RecordTypeId);
    if IsCurrText('(') then
      NP := Parse_FormalParameterList(result)
    else
      NP := 0;
    SetCount(result, NP);
    Match(';');

    DirectiveList := Parse_DirectiveList(result);
    if DirectiveList.IndexOf(dirOVERRIDE) >= 0 then
      Gen(OP_CHECK_OVERRIDE, result, 0, 0);

    DirectiveList.Free;
    SetForward(result, true);

    if IsCurrText('external') then
    begin
      ParseExternalSub(result);
      SetForward(result, false);
      Exit;
    end;

    if IsExternalUnit then
    begin
      GenExternalSub(result);
      Exit;
    end;

    EndSub(result);
  end;

  function Parse_DestructorHeading: Integer;
  var
    NP: Integer;
    DirectiveList: TIntegerList;
  begin
    DECLARE_SWITCH := true;
    Match('destructor');
    result := Parse_Ident;
    SetVisibility(result, vis);
    BeginStructureDestructor(result, RecordTypeId);
    NP := 0;
    if IsCurrText('(') then
    begin
      Call_SCANNER;
      Match(')');
    end;
    SetCount(result, NP);
    Match(';');

    DirectiveList := Parse_DirectiveList(result);
    if DirectiveList.IndexOf(dirOVERRIDE) = -1 then
      Match('override');
    DirectiveList.Free;
    SetForward(result, true);

    if IsCurrText('external') then
    begin
      ParseExternalSub(result);
      SetForward(result, false);
      Exit;
    end;

    if IsExternalUnit then
    begin
      GenExternalSub(result);
      Exit;
    end;

    EndSub(result);
  end;

  function Parse_ProcedureHeading(IsSharedMethod: Boolean): Integer;
  var
    NP: Integer;
    DirectiveList: TIntegerList;
  begin
    DECLARE_SWITCH := true;
    Match('procedure');
    result := Parse_Ident;

    if IsCurrText('.') then
    begin
      Match('.');
      Parse_Ident;
      DECLARE_SWITCH := false;
      Match('=');
      Parse_Ident;
      Match(';');
      Exit;
    end;

    SetVisibility(result, vis);
    BeginStructureMethod(result, RecordTypeId, false, IsSharedMethod);
    if IsCurrText('(') then
      NP := Parse_FormalParameterList(result)
    else
      NP := 0;
    SetCount(result, NP);
    Match(';');

    DirectiveList := Parse_DirectiveList(result);

    if DirectiveList.IndexOf(dirABSTRACT) >= 0 then
    begin
      inherited InitSub(result);
      Gen(OP_ERR_ABSTRACT, NewConst(typeSTRING,
                           GetName(RecordTypeId) + '.' + GetName(result)), 0, result);
    end
    else if DirectiveList.IndexOf(dirOVERRIDE) >= 0 then
    begin
      Gen(OP_CHECK_OVERRIDE, result, 0, 0);
      SetForward(result, true);
    end
    else
      SetForward(result, true);
    DirectiveList.Free;

    if IsCurrText('external') then
    begin
      ParseExternalSub(result);
      SetForward(result, false);
      Exit;
    end;

    if IsExternalUnit then
    begin
      GenExternalSub(result);
      Exit;
    end;

    EndSub(result);
  end;

  function Parse_FunctionHeading(IsSharedMethod: Boolean): Integer;
  var
    NP, TypeID: Integer;
    DirectiveList: TIntegerList;
  begin
    DECLARE_SWITCH := true;
    Match('function');
    result := Parse_Ident;

    if IsCurrText('.') then
    begin
      Match('.');
      Parse_Ident;
      DECLARE_SWITCH := false;
      Match('=');
      Parse_Ident;
      Match(';');
      Exit;
    end;

    SetVisibility(result, vis);
    BeginStructureMethod(result, RecordTypeId, true, IsSharedMethod);
    if IsCurrText('(') then
      NP := Parse_FormalParameterList(result)
    else
      NP := 0;
    SetCount(result, NP);

    DECLARE_SWITCH := false;
    Match(':');
    TypeID := Parse_Type;
    Gen(OP_ASSIGN_TYPE, result, TypeID, 0);
    Gen(OP_ASSIGN_TYPE, CurrResultId, TypeID, 0);

    DECLARE_SWITCH := true;
    Match(';');

    DirectiveList := Parse_DirectiveList(result);
    if DirectiveList.IndexOf(dirABSTRACT) >= 0 then
    begin
      inherited InitSub(result);
      Gen(OP_ERR_ABSTRACT, NewConst(typeSTRING,
                           GetName(RecordTypeId) + '.' + GetName(result)), 0, result);
    end
    else if DirectiveList.IndexOf(dirOVERRIDE) >= 0 then
    begin
      Gen(OP_CHECK_OVERRIDE, result, 0, 0);
      SetForward(result, true);
    end
    else
      SetForward(result, true);

    DirectiveList.Free;

    if IsCurrText('external') then
    begin
      ParseExternalSub(result);
      SetForward(result, false);
      Exit;
    end;

    if IsExternalUnit then
    begin
      GenExternalSub(result);
      Exit;
    end;

    EndSub(result);
  end;

  function Parse_Property: Integer;
  var
    NP, TypeID, ReadId, WriteId, ImplementsId: Integer;
  begin
    DECLARE_SWITCH := true;
    Match('property');
    result := Parse_Ident;
    SetVisibility(result, vis);
    BeginProperty(result, RecordTypeId);
    if IsCurrText('[') then
      NP := Parse_FormalParameterList(result, '[')
    else
      NP := 0;
    SetCount(result, NP);

    ReadId := 0;
    WriteId := 0;

    SetReadId(result, ReadId);
    SetWriteId(result, WriteId);

    if IsCurrText(';') then
    begin
      EndProperty(result);
      Exit;
    end;

    if IsCurrText(':') then
    begin
      DECLARE_SWITCH := false;
      Match(':');
      if CurrToken.TokenClass <> tcIdentifier then
        RaiseError(errIdentifierExpected, [CurrToken.Text]);
      TypeID := CurrToken.Id;
      Gen(OP_ASSIGN_TYPE, result, TypeID, 0);
      ReadToken;
    end;

    repeat
      DECLARE_SWITCH := true;
      if IsCurrText('read') and (ReadId = 0) then
      begin
        ReadToken;
        if CurrToken.TokenClass <> tcIdentifier then
          RaiseError(errIdentifierExpected, [CurrToken.Text]);
        ReadId := Lookup(CurrToken.Text, RecordTypeId);
        if ReadId = 0 then
          RaiseError(errUndeclaredIdentifier, [CurrToken.Text]);
        SetReadId(result, ReadId);
        ReadToken;
      end
      else if IsCurrText('write') and (WriteId = 0) then
      begin
        ReadToken;
        if CurrToken.TokenClass <> tcIdentifier then
          RaiseError(errIdentifierExpected, [CurrToken.Text]);
        WriteId := Lookup(CurrToken.Text, RecordTypeId);
        if WriteId = 0 then
          RaiseError(errUndeclaredIdentifier, [CurrToken.Text]);
        SetWriteId(result, WriteId);
        ReadToken;
      end
      else if IsCurrText('implements') then
      begin
        DECLARE_SWITCH := false;
        Call_SCANNER;
        DiscardLastStRecord;
        ImplementsId := Parse_Ident;
        Gen(OP_IMPLEMENTS, result, ImplementsId, 0);
      end
      else if IsCurrText('stored') then
      begin
        DECLARE_SWITCH := false;
        DiscardLastStRecord;
        Call_SCANNER;
        Parse_Expression;
      end
      else if IsCurrText('index') then
      begin
        DECLARE_SWITCH := false;
        DiscardLastStRecord;
        Call_SCANNER;
        Parse_Expression;
      end
      else if IsCurrText('default') then
      begin
        DiscardLastStRecord;
        Call_SCANNER;
        if IsCurrText(';') then
          SetDefault(result, true)
        else
          Parse_Expression;
      end
      else if IsCurrText('nodefault') then
      begin
        DiscardLastStRecord;
        Call_SCANNER;
      end
      else
        break;
    until false;

    if IsNextText('default') then
    begin
      Call_SCANNER;
      Match('default');
      SetDefault(result, true);
    end;

    EndProperty(result);
  end;

  procedure Parse_VariantPart(VarLevel: Integer; CurrVarCnt: Int64);
  var
    id, I, TypeId: Integer;
    V, VarCnt: Int64;
    L: TIntegerList;
  begin

    L := TIntegerList.Create;

    try
      VarCnt := 0;

      if IsNext2Text(':') then
      begin
        DECLARE_SWITCH := true;
        Match('case');
        DECLARE_SWITCH := false;
        id := Parse_Ident;
        Match(':');
        TypeId := Parse_Ident;
        SetKind(Id, KindTYPE_FIELD);
        Gen(OP_ASSIGN_TYPE, id, TypeId, 0);
      end
      else
      begin
        DECLARE_SWITCH := false;
        Match('case');
        TypeId := Parse_Ident;
        Gen(OP_EVAL, 0, 0, TypeId);
      end;

      DECLARE_SWITCH := false;
      Match('of');

      repeat
        Inc(VarCnt);

        if IsEOF then
          Break;
        if IsCurrText('end') then
          Break;
        if IsCurrText(')') then
        begin
          Break;
        end;

        // RecVariant

        // ConstList
        repeat
          if IsEOF then
            Break;
          if IsCurrText('end') then
            Break;

          Parse_Expression;

          if NotMatch(',') then
            break;
        until false;

        Match(':');

        // FieldList
        DECLARE_SWITCH := true;

        Match('(');
        if not IsCurrText(')') then
        begin
          if IsCurrText('case') then
          begin
             case VarLevel of
               1: V := VarCnt;
               2: V := VarCnt * 100 + CurrVarCnt;
               3: V := VarCnt * 10000 + CurrVarCnt;
               4: V := VarCnt * 1000000 + CurrVarCnt;
               5: V := VarCnt * 100000000 + CurrVarCnt;
               6: V := VarCnt * 10000000000 + CurrVarCnt;
               7: V := VarCnt * 1000000000000 + CurrVarCnt;
             else
               begin
                 V := 0;
                 RaiseError(errTooManyNestedCaseBlocks, []);
               end;
             end;

            Parse_VariantPart(VarLevel + 1, V);
          end
          else
          begin

            repeat

              L.Clear;
              repeat  // parse ident list
                L.Add(Parse_Ident);
                if NotMatch(',') then
                  break;
              until false;

             DECLARE_SWITCH := false;
             Match(':');

             TypeID := Parse_Type;

             case VarLevel of
               1: V := VarCnt;
               2: V := VarCnt * 100 + CurrVarCnt;
               3: V := VarCnt * 10000 + CurrVarCnt;
               4: V := VarCnt * 1000000 + CurrVarCnt;
               5: V := VarCnt * 100000000 + CurrVarCnt;
               6: V := VarCnt * 10000000000 + CurrVarCnt;
               7: V := VarCnt * 1000000000000 + CurrVarCnt;
             else
               begin
                 V := 0;
                 RaiseError(errTooManyNestedCaseBlocks, []);
               end;
             end;

             for I:=0 to L.Count - 1 do
             begin
               SetKind(L[I], KindTYPE_FIELD);
               SetVarCount(L[I], V);
               Gen(OP_ASSIGN_TYPE, L[I], TypeID, 0);
             end;

             if IsCurrText(';') then
             begin
               DECLARE_SWITCH := true;
               Match(';');

               if IsCurrText('case') then
               begin
                 Parse_VariantPart(VarLevel + 1, V);
                 break;
               end;

             end
             else
               break;

            until false;
          end;

          DECLARE_SWITCH := true;
        end;

        DECLARE_SWITCH := false;

        Match(')');
        if IsCurrText(';') then
          Match(';');

      until false;
    finally
      L.Free;
    end;
  end;

var
  L: TIntegerList;
  I, TypeID: Integer;
  b: Boolean;
begin
  BeginRecordType(RecordTypeID);
  if IsPacked then
    SetPacked(RecordTypeID);

  Match('record');
  b := false;

  L := TIntegerList.Create;
  try
    repeat
      if IsEOF then
        Break;
      if IsCurrText('end') then
        Break;

      if IsCurrText('case') then
      begin
        Parse_VariantPart(1, 0);
        break;
      end
      else
      begin

        repeat
          if IsCurrText('private') then
          begin
            Call_SCANNER;
            vis := cvPrivate;
            b := false;
          end
          else if IsCurrText('protected') then
          begin
            Call_SCANNER;
            vis := cvProtected;
            b := false;
          end
          else if IsCurrText('public') then
          begin
            Call_SCANNER;
            vis := cvPublic;
            b := false;
          end
          else if IsCurrText('published') then
          begin
            Call_SCANNER;
            vis := cvPublished;
            b := false;
          end
          else
            break;

        until false;

        if IsCurrText('end') then
          Break;

        if IsCurrText('constructor') then
        begin
          Parse_ConstructorHeading;
          b := true;
        end
        else if IsCurrText('destructor') then
        begin
          Parse_DestructorHeading;
          b := true;
        end
        else if IsCurrText('procedure') then
        begin
          Parse_ProcedureHeading(false);
          b := true;
        end
        else if IsCurrText('function') then
        begin
          Parse_FunctionHeading(false);
          b := true;
        end
        else if IsCurrText('class') then
        begin
          b := true;
          Call_SCANNER;
          if IsCurrText('procedure') then
            Parse_ProcedureHeading(true)
          else if IsCurrText('function') then
            Parse_FunctionHeading(true)
          else
            Match('procedure');
        end
        else if IsCurrText('property') then
        begin
          Parse_Property;
          b := true;
        end
        else
        begin
          if b then
            CreateError(errFieldDefinitionNotAllowedAfter, []);


          L.Clear;
          repeat  // parse ident list
            L.Add(Parse_Ident);
            if NotMatch(',') then
              break;
          until false;

          DECLARE_SWITCH := false;
          Match(':');

          TypeID := Parse_Type;

          for I:=0 to L.Count - 1 do
          begin
            SetKind(L[I], KindTYPE_FIELD);
            Gen(OP_ASSIGN_TYPE, L[I], TypeID, 0);
          end;

          DECLARE_SWITCH := true;

          Parse_PortabilityDirective;

          if IsCurrText(';') then
            Match(';');
        end;

        if IsCurrText('case') then
        begin
          Parse_VariantPart(1, 0);
          break;
        end;
      end;

    until false;
  finally
    L.Free;
  end;

  EndRecordType(RecordTypeId);

  Match('end');
end;

procedure TPascalParser.Parse_ClassTypeDeclaration(ClassTypeID: Integer; IsPacked: Boolean;
                                                   IsExternalUnit: Boolean = false);
var
  vis: TClassVisibility;

  function Parse_ConstructorHeading: Integer;
  var
    NP: Integer;
    DirectiveList: TIntegerList;
  begin
    DECLARE_SWITCH := true;
    Match('constructor');
    result := Parse_Ident;
    SetVisibility(result, vis);
    BeginClassConstructor(result, ClassTypeId);
    if IsCurrText('(') then
      NP := Parse_FormalParameterList(result)
    else
      NP := 0;
    SetCount(result, NP);
    Match(';');

    DirectiveList := Parse_DirectiveList(result);
    if DirectiveList.IndexOf(dirOVERRIDE) >= 0 then
      Gen(OP_CHECK_OVERRIDE, result, 0, 0);

    DirectiveList.Free;
    SetForward(result, true);

    if IsCurrText('external') then
    begin
      ParseExternalSub(result);
      SetForward(result, false);
      Exit;
    end;

    if IsExternalUnit then
    begin
      GenExternalSub(result);
      Exit;
    end;

    EndSub(result);
  end;

  function Parse_DestructorHeading: Integer;
  var
    NP: Integer;
    DirectiveList: TIntegerList;
  begin
    DECLARE_SWITCH := true;
    Match('destructor');
    result := Parse_Ident;
    SetVisibility(result, vis);
    BeginClassDestructor(result, ClassTypeId);
    NP := 0;
    if IsCurrText('(') then
    begin
      Call_SCANNER;
      Match(')');
    end;
    SetCount(result, NP);
    Match(';');

    DirectiveList := Parse_DirectiveList(result);
    if DirectiveList.IndexOf(dirOVERRIDE) = -1 then
      Match('override');
    DirectiveList.Free;
    SetForward(result, true);

    if IsCurrText('external') then
    begin
      ParseExternalSub(result);
      SetForward(result, false);
      Exit;
    end;

    if IsExternalUnit then
    begin
      GenExternalSub(result);
      Exit;
    end;

    EndSub(result);
  end;

  function Parse_ProcedureHeading(IsSharedMethod: Boolean): Integer;
  var
    NP: Integer;
    DirectiveList: TIntegerList;
  begin
    DECLARE_SWITCH := true;
    Match('procedure');
    result := Parse_Ident;

    if IsCurrText('.') then
    begin
      Match('.');
      Parse_Ident;
      DECLARE_SWITCH := false;
      Match('=');
      Parse_Ident;
      Match(';');
      Exit;
    end;

    SetVisibility(result, vis);
    BeginClassMethod(result, ClassTypeId, false, IsSharedMethod);
    if IsCurrText('(') then
      NP := Parse_FormalParameterList(result)
    else
      NP := 0;
    SetCount(result, NP);
    Match(';');

    DirectiveList := Parse_DirectiveList(result);

    if DirectiveList.IndexOf(dirABSTRACT) >= 0 then
    begin
      inherited InitSub(result);
      Gen(OP_ERR_ABSTRACT, NewConst(typeSTRING,
                           GetName(ClassTypeId) + '.' + GetName(result)), 0, result);
    end
    else if DirectiveList.IndexOf(dirOVERRIDE) >= 0 then
    begin
      Gen(OP_CHECK_OVERRIDE, result, 0, 0);
      SetForward(result, true);
    end
    else
      SetForward(result, true);
    DirectiveList.Free;

    if IsCurrText('external') then
    begin
      ParseExternalSub(result);
      SetForward(result, false);
      Exit;
    end;

    if IsExternalUnit then
    begin
      GenExternalSub(result);
      Exit;
    end;

    EndSub(result);
  end;

  function Parse_FunctionHeading(IsSharedMethod: Boolean): Integer;
  var
    NP, TypeID: Integer;
    DirectiveList: TIntegerList;
  begin
    DECLARE_SWITCH := true;
    Match('function');
    result := Parse_Ident;

    if IsCurrText('.') then
    begin
      Match('.');
      Parse_Ident;
      DECLARE_SWITCH := false;
      Match('=');
      Parse_Ident;
      Match(';');
      Exit;
    end;

    SetVisibility(result, vis);
    BeginClassMethod(result, ClassTypeId, true, IsSharedMethod);
    if IsCurrText('(') then
      NP := Parse_FormalParameterList(result)
    else
      NP := 0;
    SetCount(result, NP);

    DECLARE_SWITCH := false;
    Match(':');
    TypeID := Parse_Type;
    Gen(OP_ASSIGN_TYPE, result, TypeID, 0);
    Gen(OP_ASSIGN_TYPE, CurrResultId, TypeID, 0);

    DECLARE_SWITCH := true;
    Match(';');

    DirectiveList := Parse_DirectiveList(result);
    if DirectiveList.IndexOf(dirABSTRACT) >= 0 then
    begin
      inherited InitSub(result);
      Gen(OP_ERR_ABSTRACT, NewConst(typeSTRING,
                           GetName(ClassTypeId) + '.' + GetName(result)), 0, result);
    end
    else if DirectiveList.IndexOf(dirOVERRIDE) >= 0 then
    begin
      Gen(OP_CHECK_OVERRIDE, result, 0, 0);
      SetForward(result, true);
    end
    else
      SetForward(result, true);

    DirectiveList.Free;

    if IsCurrText('external') then
    begin
      ParseExternalSub(result);
      SetForward(result, false);
      Exit;
    end;

    if IsExternalUnit then
    begin
      GenExternalSub(result);
      Exit;
    end;

    EndSub(result);
  end;

  function Parse_Property: Integer;
  var
    NP, TypeID, ReadId, WriteId, ImplementsId: Integer;
  begin
    DECLARE_SWITCH := true;
    Match('property');
    result := Parse_Ident;
    SetVisibility(result, vis);
    BeginProperty(result, ClassTypeId);
    if IsCurrText('[') then
      NP := Parse_FormalParameterList(result, '[')
    else
      NP := 0;
    SetCount(result, NP);

    ReadId := 0;
    WriteId := 0;

    SetReadId(result, ReadId);
    SetWriteId(result, WriteId);

    if IsCurrText(';') then
    begin
      EndProperty(result);
      Exit;
    end;

    if IsCurrText(':') then
    begin
      DECLARE_SWITCH := false;
      Match(':');
      if CurrToken.TokenClass <> tcIdentifier then
        RaiseError(errIdentifierExpected, [CurrToken.Text]);
      TypeID := CurrToken.Id;
      Gen(OP_ASSIGN_TYPE, result, TypeID, 0);
      ReadToken;
    end;

    repeat
      DECLARE_SWITCH := true;
      if IsCurrText('read') and (ReadId = 0) then
      begin
        ReadToken;
        if CurrToken.TokenClass <> tcIdentifier then
          RaiseError(errIdentifierExpected, [CurrToken.Text]);
        ReadId := Lookup(CurrToken.Text, ClassTypeId);
        if ReadId = 0 then
          RaiseError(errUndeclaredIdentifier, [CurrToken.Text]);
        SetReadId(result, ReadId);
        ReadToken;
      end
      else if IsCurrText('write') and (WriteId = 0) then
      begin
        ReadToken;
        if CurrToken.TokenClass <> tcIdentifier then
          RaiseError(errIdentifierExpected, [CurrToken.Text]);
        WriteId := Lookup(CurrToken.Text, ClassTypeId);
        if WriteId = 0 then
          RaiseError(errUndeclaredIdentifier, [CurrToken.Text]);
        SetWriteId(result, WriteId);
        ReadToken;
      end
      else if IsCurrText('implements') then
      begin
        DECLARE_SWITCH := false;
        Call_SCANNER;
        DiscardLastStRecord;
        ImplementsId := Parse_Ident;
        Gen(OP_IMPLEMENTS, result, ImplementsId, 0);
      end
      else if IsCurrText('stored') then
      begin
        DECLARE_SWITCH := false;
        DiscardLastStRecord;
        Call_SCANNER;
        Parse_Expression;
      end
      else if IsCurrText('index') then
      begin
        DECLARE_SWITCH := false;
        DiscardLastStRecord;
        Call_SCANNER;
        Parse_Expression;
      end
      else if IsCurrText('default') then
      begin
        DiscardLastStRecord;
        Call_SCANNER;
        if IsCurrText(';') then
          SetDefault(result, true)
        else
          Parse_Expression;
      end
      else if IsCurrText('nodefault') then
      begin
        DiscardLastStRecord;
        Call_SCANNER;
      end
      else
        break;
    until false;

    if IsNextText('default') then
    begin
      Call_SCANNER;
      Match('default');
      SetDefault(result, true);
    end;

    EndProperty(result);
  end;

var
  L: TIntegerList;
  I, TypeID, AncestorId: Integer;
  b: Boolean;
begin
  if IsNextText('of') then
  begin
    DECLARE_SWITCH := false;
    BeginClassReferenceType(ClassTypeID);
    Match('class');
    Match('of');
    Gen(OP_CREATE_CLASSREF_TYPE, ClassTypeId, Parse_Ident, 0);
    EndClassReferenceType(ClassTypeID);
    Exit;
  end;

  BeginClassType(ClassTypeID);

  if IsPacked then
    SetPacked(ClassTypeID);

  Match('class');

  if IsCurrText(';') then // forward declaration
  begin
    SetForward(ClassTypeId, true);
    EndClassType(ClassTypeId, true);
    Exit;
  end;

  if IsCurrText('(') then
  begin
    DECLARE_SWITCH := false;
    Match('(');
    AncestorId := Parse_Ident;
    Gen(OP_ADD_ANCESTOR, ClassTypeId, AncestorId, 0);

    if StrEql(GetName(ClassTypeId), GetName(AncestorId)) then
      RaiseError(errRedeclaredIdentifier, [GetName(AncestorId)]);

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
    Match(')')
  end;

  if IsCurrText(';') then
  begin
    EndClassType(ClassTypeId);
    Exit;
  end;

  vis := cvPublished;

  b := false;

  L := TIntegerList.Create;
  try
    repeat
      if IsEOF then
        Break;
      if IsCurrText('end') then
        Break;

      repeat
        if IsCurrText('private') then
        begin
          Call_SCANNER;
          vis := cvPrivate;
          b := false;
        end
        else if IsCurrText('protected') then
        begin
          Call_SCANNER;
          vis := cvProtected;
          b := false;
        end
        else if IsCurrText('public') then
        begin
          Call_SCANNER;
          vis := cvPublic;
          b := false;
        end
        else if IsCurrText('published') then
        begin
          Call_SCANNER;
          vis := cvPublished;
          b := false;
        end
        else
          break;

      until false;

      if IsCurrText('end') then
        Break;

      if IsCurrText('constructor') then
      begin
        Parse_ConstructorHeading;
        b := true;
      end
      else if IsCurrText('destructor') then
      begin
        Parse_DestructorHeading;
        b := true;
      end
      else if IsCurrText('procedure') then
      begin
        Parse_ProcedureHeading(false);
        b := true;
      end
      else if IsCurrText('function') then
      begin
        Parse_FunctionHeading(false);
        b := true;
      end
      else if IsCurrText('class') then
      begin
        b := true;
        Call_SCANNER;
        if IsCurrText('procedure') then
          Parse_ProcedureHeading(true)
        else if IsCurrText('function') then
          Parse_FunctionHeading(true)
        else
          Match('procedure');
      end
      else if IsCurrText('property') then
      begin
        Parse_Property;
        b := true;
      end
      else
      begin
        if b then
          CreateError(errFieldDefinitionNotAllowedAfter, []);

        L.Clear;
        repeat  // parse ident list
          L.Add(Parse_Ident);
          if NotMatch(',') then
            break;
        until false;

        DECLARE_SWITCH := false;
        Match(':');

        TypeID := Parse_Type;

        for I:=0 to L.Count - 1 do
        begin
          SetKind(L[I], KindTYPE_FIELD);
          SetVisibility(L[I], vis);
          Gen(OP_ASSIGN_TYPE, L[I], TypeID, 0);
        end;
      end;

      DECLARE_SWITCH := true;

      Parse_PortabilityDirective;

      if IsCurrText(';') then
        Match(';');
    until false;
  finally
    L.Free;
  end;

  EndClassType(ClassTypeId);

  Match('end');
end;

procedure TPascalParser.Parse_InterfaceTypeDeclaration(IntfTypeID: Integer);

const
  IsPacked = true;

var
  NegativeMethodIndex: Integer;

  function Parse_ProcedureHeading: Integer;
  var
    NP: Integer;
    DirectiveList: TIntegerList;
  begin
    Dec(NegativeMethodIndex);

    DECLARE_SWITCH := true;
    Match('procedure');
    result := Parse_Ident;
    BeginInterfaceMethod(result, IntfTypeId, false);
    if IsCurrText('(') then
      NP := Parse_FormalParameterList(result)
    else
      NP := 0;
    SetCount(result, NP);
    Gen(OP_ADD_METHOD_INDEX, result, NegativeMethodIndex, 0);

    DECLARE_SWITCH := true;
    Match(';');

    DirectiveList := Parse_DirectiveList(result);
    if DirectiveList.IndexOf(dirABSTRACT) >= 0 then
      CreateError(errUnknownDirective, ['abstract']);
    EndSub(result);
    DirectiveList.Free;
  end;

  function Parse_FunctionHeading: Integer;
  var
    NP, TypeID: Integer;
    DirectiveList: TIntegerList;
  begin
    Dec(NegativeMethodIndex);

    DECLARE_SWITCH := true;
    Match('function');
    result := Parse_Ident;
    BeginInterfaceMethod(result, IntfTypeId, true);
    if IsCurrText('(') then
      NP := Parse_FormalParameterList(result)
    else
      NP := 0;
    SetCount(result, NP);

    DECLARE_SWITCH := false;
    Match(':');
    TypeID := Parse_Type;
    Gen(OP_ASSIGN_TYPE, result, TypeID, 0);
    Gen(OP_ASSIGN_TYPE, CurrResultId, TypeID, 0);
    Gen(OP_ADD_METHOD_INDEX, result, NegativeMethodIndex, 0);

    DECLARE_SWITCH := true;
    Match(';');

    DirectiveList := Parse_DirectiveList(result);
    if DirectiveList.IndexOf(dirABSTRACT) >= 0 then
      CreateError(errUnknownDirective, ['abstract']);
    EndSub(result);
    DirectiveList.Free;
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
      NP := Parse_FormalParameterList(result, '[')
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
  NegativeMethodIndex := 0;

  BeginInterfaceType(IntfTypeID);
  SetPacked(IntfTypeID);

  Match('interface');

  if IsCurrText(';') then // forward declaration
  begin
    SetForward(IntfTypeId, true);
    EndInterfaceType(IntfTypeId, true);
    Exit;
  end;

  if IsCurrText('(') then
  begin
    DECLARE_SWITCH := false;
    Match('(');

    repeat
       AncestorId := Parse_Ident;
       Gen(OP_ADD_INTERFACE, IntfTypeId, AncestorId, 0);
      if NotMatch(',') then
        break;
    until false;

    DECLARE_SWITCH := true;
    Match(')');
  end
  else
    Gen(OP_ADD_INTERFACE, IntfTypeId, H_IUnknown, 0);

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

      repeat
        if IsCurrText('private') then
        begin
          CreateError(errKeywordNotAllowedInInterfaceDeclaration, [CurrToken.Text]);
          Call_SCANNER;
        end
        else if IsCurrText('protected') then
        begin
          CreateError(errKeywordNotAllowedInInterfaceDeclaration, [CurrToken.Text]);
          Call_SCANNER;
        end
        else if IsCurrText('public') then
        begin
          CreateError(errKeywordNotAllowedInInterfaceDeclaration, [CurrToken.Text]);
          Call_SCANNER;
        end
        else if IsCurrText('published') then
        begin
          CreateError(errKeywordNotAllowedInInterfaceDeclaration, [CurrToken.Text]);
          Call_SCANNER;
        end
        else
          break;

      until false;

      if IsCurrText('end') then
        Break;

      if IsCurrText('procedure') then
      begin
        Parse_ProcedureHeading;
      end
      else if IsCurrText('function') then
      begin
        Parse_FunctionHeading;
      end
      else if IsCurrText('property') then
      begin
        Parse_Property;
      end;

      DECLARE_SWITCH := true;

      if IsCurrText(';') then
        Match(';');
    until false;
  finally
    L.Free;
  end;

  EndInterfaceType(IntfTypeId);

  Match('end');
end;

procedure TPascalParser.Parse_PointerTypeDeclaration(TypeID: Integer);
begin
  DECLARE_SWITCH := false;
  Match('^');
  BeginPointerType(TypeID);
  Gen(OP_CREATE_POINTER_TYPE, TypeId, Parse_Ident, 0);
  EndPointerType(TypeID);
end;

procedure TPascalParser.Parse_ShortStringTypeDeclaration(TypeID: Integer);
begin
  DECLARE_SWITCH := false;
  Match('[');
  BeginShortStringType(TypeID);
  Gen(OP_CREATE_SHORTSTRING_TYPE, TypeId, Parse_Expression, 0);
  EndShortStringType(TypeID);
  Match(']');
end;

procedure TPascalParser.Parse_ProceduralTypeDeclaration(TypeID: Integer;
                                                        var SubId: Integer);
var
  IsFunc: Boolean;
  SubTypeId, NP: Integer;
begin
  if IsCurrText('function') then
  begin
    Match('function');
    IsFunc := true;
  end
  else
  begin
    Match('procedure');
    IsFunc := false;
  end;
  SubTypeId := typeVOID;
  SubId := NewTempVar;
  BeginProceduralType(TypeID, SubId);
  if IsCurrText('(') then
    NP := Parse_FormalParameterList(SubId)
  else
    NP := 0;
  SetCount(SubId, NP);
  DECLARE_SWITCH := false;
  if IsFunc then
  begin
    Match(':');
    DECLARE_SWITCH := true;
    SubTypeID := Parse_Type;
  end;
  Gen(OP_ASSIGN_TYPE, SubId, SubTypeID, 0);
  Gen(OP_ASSIGN_TYPE, CurrResultId, SubTypeID, 0);
  EndProceduralType(TypeID);

  if IsCurrText('of') then
  begin
    Match('of');
    Match('object');
    SetType(TypeId, typeEVENT);
  end;
end;

procedure TPascalParser.Parse_SetTypeDeclaration(TypeID: Integer);
var
  TypeBaseId: Integer;
begin
  DECLARE_SWITCH := false;
  Match('set');
  Match('of');
  TypeBaseId := Parse_OrdinalType;
  BeginSetType(TypeID, TypeBaseId);
  EndSetType(TypeID);
end;

procedure TPascalParser.Parse_EnumTypeDeclaration(TypeID: Integer);
var
  ID, TempID, L, K: Integer;
begin
  L := CurrLevel;

  BeginEnumType(TypeID, TypeINTEGER);
  DECLARE_SWITCH := true;
  Match('(');

  TempID := NewConst(TypeID, 0);

  K := 0;

  repeat
    ID := Parse_EnumIdent;

    Inc(K);

    SetLevel(ID, L);

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
    if NotMatch(',') then
      Break;
  until false;
  Match(')');
  EndEnumType(TypeID, K);
end;

procedure TPascalParser.Parse_SubrangeTypeDeclaration(TypeID, TypeBaseId: Integer; Expr1ID: Integer = 0);
var
  ID1, ID2: Integer;
begin
  BeginSubrangeType(TypeID, TypeBaseID);

  ID1 := NewConst(TypeBaseId);
  ID2 := NewConst(TypeBaseId);

  if Expr1ID = 0 then
    Gen(OP_ASSIGN_CONST, ID1, Parse_ConstantExpression, ID1)
  else
    Gen(OP_ASSIGN_CONST, ID1, Expr1ID, ID1);

  Match('..');
  Gen(OP_ASSIGN_CONST, ID2, Parse_ConstantExpression, ID2);

  Gen(OP_CHECK_SUBRANGE_TYPE, ID1, ID2, 0);

  EndSubrangeType(TypeID);
end;

function TPascalParser.Parse_FormalParameterList(SubId: Integer;
                                                 bracket: Char = '('): Integer;
var
  L: TIntegerList;
  I, ID, TypeId: Integer;
  ByRef, IsConst, HasDefaultParameters, IsOpenArray: Boolean;
begin
  DECLARE_SWITCH := true;
  if bracket = '(' then
    Match('(')
  else if bracket = '[' then
    Match('[');

  HasDefaultParameters := false;

  result := 0;
  if not IsCurrText(')') then
  begin
    L := TIntegerList.Create;

    try

      repeat
        ByRef := false;
        IsConst := false;

        if IsCurrText('var') then
        begin
          Match('var');
          ByRef := true;
        end
        else if IsCurrText('out') then
        begin
          Match('out');
          ByRef := true;
        end
        else if IsCurrText('const') then
        begin
          Match('const');
          IsConst := true;
        end;

        L.Clear;
        repeat
          Inc(result);
          ID := Parse_FormalParameter;
          Gen(OP_DECLARE_LOCAL_VAR, SubId, ID, 0);
          L.Add(ID);
          if NotMatch(',') then
            break;
        until false;
        DECLARE_SWITCH := false;

        IsOpenArray := false;
        if ByRef or IsConst then
        begin
          if IsCurrText(':') then
          begin
            Match(':');
            IsOpenArray := IsCurrText('array');
            TypeId := Parse_Type;
          end
          else
            TypeId := typePVOID;
        end
        else
        begin
          Match(':');
          IsOpenArray := IsCurrText('array');
          TypeId := Parse_Type;
        end;

        DECLARE_SWITCH := true;

        for I:=0 to L.Count - 1 do
        begin

          if ByRef then
            SetByRef(L[I]);

          if IsConst then
            SetIsConst(L[I]);

          if IsOpenArray then
            SetOpenArray(L[I], true);

          Gen(OP_ASSIGN_TYPE, L[I], TypeID, 0);
        end;

        if IsCurrText('=') then
        begin
          if L.Count > 1 then
            CreateError(errParameterNotAllowedHere, [GetName(L[1])]);
          DECLARE_SWITCH := false;
          Match('=');
          Gen(OP_ASSIGN_CONST, L[0], Parse_ConstantExpression, L[0]);
          SetOptional(L[0]);

          DECLARE_SWITCH := true;
          HasDefaultParameters := true;
        end
        else
        begin
          if HasDefaultParameters then
            CreateError(errDefaultValueRequired, [GetName(L[0])]);
        end;

        if NotMatch(';') then
          Break;
      until false;

    finally
      L.Free;
    end;
  end;

  if bracket = '(' then
    Match(')')
  else if bracket = '[' then
    Match(']');
end;

procedure TPascalParser.Parse_SubBlock;
begin
  if GetName(CurrSelfId) = '' then
  begin
    Gen(OP_STMT, 0, 0, 0);
    Parse_Block;
  end
  else
  begin
    Gen(OP_BEGIN_WITH, CurrSelfId, 0, 0);
    WithStack.Push(CurrSelfId);
    Gen(OP_STMT, 0, 0, 0);
    Parse_Block;
    Gen(OP_END_WITH, WithStack.Top, 0, 0);
    WithStack.Pop;
  end;
end;

procedure TPascalParser.Parse_ProcedureDeclaration(IsSharedMethod: Boolean = false);
var
  SubId, ClassTypeId, NP: Integer;
  DirectiveList: TIntegerList;
  NotDeclared: Boolean;
begin
  NotDeclared := false;

  if IsSharedMethod then
  begin
    ReadToken;
    ClassTypeId := Lookup(CurrToken.Text, CurrLevel);
    if ClassTypeId = 0 then
      CreateError(errUndeclaredIdentifier, [CurrToken.Text]);

    Call_SCANNER;
    DECLARE_SWITCH := true;
    Match('.');
    SubId := Parse_Ident;
    BeginClassMethod(SubId, ClassTypeId, false, true);
  end
  else
  begin
    ReadToken;
    ClassTypeId := Lookup(CurrToken.Text, CurrLevel);
    if (ClassTypeId > 0) and (GetKind(ClassTypeId) = KindTYPE) then
    begin
      Call_SCANNER;
      DECLARE_SWITCH := true;
      Match('.');
      SubId := Parse_Ident;
      if Lookup(GetName(SubId), ClassTypeId) = 0 then
        NotDeclared := true;
      BeginClassMethod(SubId, ClassTypeId, false, false);
    end
    else
    begin
      SubId := NewVar(CurrToken.Text);
      SetPosition(SubId, CurrToken.Position - 1);
      Parse_Ident;
      BeginSub(SubId);
    end;
  end;

  if IsCurrText('(') then
    NP := Parse_FormalParameterList(SubId)
  else
    NP := 0;
  SetCount(SubId, NP);
  SetName(CurrResultId, '');
  SetKind(CurrResultId, KindNONE);
  SetType(SubId, TypeVOID);
  SetType(CurrResultId, TypeVOID);

  Match(';');

  if NotDeclared then
    CreateError(errUndeclaredIdentifier, [GetName(SubId)]);

  DirectiveList := Parse_DirectiveList(SubId);
  if DirectiveList.IndexOf(dirFORWARD) >= 0 then
  begin
    SetForward(SubId, true);
    EndSub(SubId);
    DirectiveList.Free;
    Exit;
  end;
  DirectiveList.Free;

  if IsCurrText('external') then
  begin
    ParseExternalSub(SubId);
    Exit;
  end;

  InitSub(SubId);
  Parse_SubBlock;
  EndSub(SubId);
  Match(';');
end;

procedure TPascalParser.Parse_FunctionDeclaration(IsSharedMethod: Boolean = false);
var
  SubId, TypeId, NP, ClassTypeId: Integer;
  DirectiveList: TIntegerList;
  L: TIntegerList;
  NotDeclared: Boolean;
begin
  NotDeclared := false;

  if IsSharedMethod then
  begin
    ReadToken;
    ClassTypeId := Lookup(CurrToken.Text, CurrLevel);
    if ClassTypeId = 0 then
      CreateError(errUndeclaredIdentifier, [CurrToken.Text]);

    Call_SCANNER;
    DECLARE_SWITCH := true;
    Match('.');
    SubId := Parse_Ident;
    BeginClassMethod(SubId, ClassTypeId, true, true);
  end
  else
  begin
    ReadToken;
    ClassTypeId := Lookup(CurrToken.Text, CurrLevel);
    if (ClassTypeId > 0) and (GetKind(ClassTypeId) = KindTYPE) then
    begin
      Call_SCANNER;
      DECLARE_SWITCH := true;
      Match('.');
      SubId := Parse_Ident;
      if Lookup(GetName(SubId), ClassTypeId) = 0 then
        NotDeclared := true;
      BeginClassMethod(SubId, ClassTypeId, true, false);
    end
    else
    begin
      SubId := NewVar(CurrToken.Text);
      SetPosition(SubId, CurrToken.Position - 1);
      Parse_Ident;
      BeginSub(SubId);
    end;
  end;

  if IsCurrText('(') then
    NP := Parse_FormalParameterList(SubId)
  else
    NP := 0;
  SetCount(SubId, NP);
  DECLARE_SWITCH := false;

  if IsCurrText(';') then
  begin
    L := LookupForwardDeclarations(SubId);
    if L = nil then
      RaiseError(errUnsatisfiedForwardOrExternalDeclaration, [GetName(SubId)])
    else
      L.Free;
  end
  else
  begin
    Match(':');
    TypeID := Parse_Type;
    Gen(OP_ASSIGN_TYPE, SubId, TypeID, 0);
    Gen(OP_ASSIGN_TYPE, CurrResultId, TypeID, 0);
  end;

  DECLARE_SWITCH := true;
  Match(';');

  if NotDeclared then
    CreateError(errUndeclaredIdentifier, [GetName(SubId)]);

  DirectiveList := Parse_DirectiveList(SubId);
  if DirectiveList.IndexOf(dirFORWARD) >= 0 then
  begin
    SetForward(SubId, true);
    EndSub(SubId);
    DirectiveList.Free;
    Exit;
  end;
  DirectiveList.Free;

  if IsCurrText('external') then
  begin
    ParseExternalSub(SubId);
    Exit;
  end;

  InitSub(SubId);
  Parse_SubBlock;
  EndSub(SubId);
  Match(';');
end;

procedure TPascalParser.ParseExternalSub(SubId: Integer);
var
  SubNameId, LibId, L: Integer;
  S: String;
begin
  ReplaceForwardDeclaration(SubId);

  SetExternal(SubId, true);

  S := GetName(SubId);
  L := GetLevel(SubId);
  if L > 0 then
    if GetKind(L) = KindTYPE then
      S := GetName(L) + '.' + S;

  SubNameId := NewConst(typeSTRING, S);

  ReadToken; // skip external

  EndSub(SubId);

  if CurrToken.TokenClass = tcPCharConst then
  begin
    S := RemoveCh('''', CurrToken.Text);
    LibId := NewConst(typeSTRING, S);
  end
  else
  begin
    LibId := Lookup(S, CurrLevel);

    if LibId = 0 then
      RaiseError(errUndeclaredIdentifier, [S]);

    if not IsStringConst(LibId) then
      RaiseError(errIncompatibleTypesNoArgs, []);
  end;

  ReadToken;
  RemoveSub;

  if IsCurrText(';') then
  begin
    Gen(OP_LOAD_PROC, SubId, SubNameId, LibId);
    Match(';');
  end
  else
  begin
    Match('name');
    SubNameId := CurrToken.Id;
    Gen(OP_LOAD_PROC, SubId, SubNameId, LibId);
    Call_SCANNER;
    Match(';');
  end;
end;

procedure TPascalParser.Parse_ConstructorDeclaration;
var
  ClassTypeId, SubId, NP, L: Integer;
  DirectiveList: TIntegerList;
  OldSubId: Integer;
begin
  DECLARE_SWITCH := false;
  Match('constructor');
  ClassTypeId := Parse_Ident;
  DECLARE_SWITCH := true;
  Match('.');
  SubId := Parse_Ident;
  BeginClassConstructor(SubId, ClassTypeId);

  if IsCurrText('(') then
    NP := Parse_FormalParameterList(SubId)
  else
    NP := 0;
  SetCount(SubId, NP);

  Inc(EXECUTABLE_SWITCH);
  Match(';');

  DirectiveList := Parse_DirectiveList(SubId);
  if DirectiveList.IndexOf(dirFORWARD) >= 0 then
  begin
    SetForward(SubId, true);
    EndSub(SubId);
    DirectiveList.Free;

    Dec(EXECUTABLE_SWITCH);
    Exit;
  end;
  DirectiveList.Free;

  OldSubId := SubId;
  InitSub(SubId);

  if OldSubId = SubId then
    RaiseError(errUndeclaredIdentifier, [GetName(OldSubId)]);

  WasInherited := false;

  Gen(OP_SAVE_EDX, 0, 0, 0);
  L := NewLabel;
  Gen(OP_GO_DL, L, 0, 0);
  Gen(OP_CREATE_OBJECT, ClassTypeId, 0, CurrSelfId);
  SetLabelHere(L);

  Parse_SubBlock;

  if not WasInherited then
    CreateError(errTheCallOfInheritedConstructorIsMandatory, []);

  Gen(OP_RESTORE_EDX, 0, 0, 0);
  L := NewLabel;
  Gen(OP_GO_DL, L, 0, 0);
  Gen(OP_ON_AFTER_OBJECT_CREATION, CurrSelfId, 0, 0);
  SetLabelHere(L);

  EndSub(SubId);

  Dec(EXECUTABLE_SWITCH);
  Match(';');
end;

procedure TPascalParser.Parse_DestructorDeclaration;
var
  ClassTypeId, SubId, NP: Integer;
  DirectiveList: TIntegerList;
  OldSubId: Integer;
begin
  DECLARE_SWITCH := false;
  Match('destructor');
  ClassTypeId := Parse_Ident;
  DECLARE_SWITCH := true;
  Match('.');
  SubId := Parse_Ident;
  BeginClassDestructor(SubId, ClassTypeId);

  NP := 0;
  if IsCurrText('(') then
  begin
    Call_SCANNER;
    Match(')');
  end;

  SetCount(SubId, NP);

  Inc(EXECUTABLE_SWITCH);
  Match(';');

  DirectiveList := Parse_DirectiveList(SubId);
  if DirectiveList.IndexOf(dirFORWARD) >= 0 then
  begin
    SetForward(SubId, true);
    EndSub(SubId);
    DirectiveList.Free;

    Dec(EXECUTABLE_SWITCH);
    Exit;
  end;
  DirectiveList.Free;

  OldSubId := SubId;
  InitSub(SubId);

  if OldSubId = SubId then
    RaiseError(errUndeclaredIdentifier, [GetName(OldSubId)]);

  Parse_SubBlock;
  EndSub(SubId);

  Dec(EXECUTABLE_SWITCH);
  Match(';');
end;

// STATEMENTS

procedure TPascalParser.Parse_CompoundStmt;
begin
  Inc(EXECUTABLE_SWITCH);
  DECLARE_SWITCH := false;
  Match('begin');
  Parse_StmtList;
  Match('end');
  Dec(EXECUTABLE_SWITCH);
end;

procedure TPascalParser.Parse_StmtList;
begin
  DECLARE_SWITCH := false;
  repeat
    if IsEOF then
      break;
    if IsCurrText('end') then
      break;
    if IsCurrText('finalization') then
      break;
    Parse_Statement;
    if NotMatch(';') then break;
  until false;
end;

procedure TPascalParser.Parse_AssignmentStmt;
var
  I, LeftID, SizeId, SubId, L, ID1, ID2: Integer;
  R: TCodeRec;
begin
  if IsCurrText('inherited') then
  begin
    Call_SCANNER;
    LeftId := NewTempVar;
    if IsCurrText(';') then
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
      L := Parse_Ident;
      Gen(OP_EVAL_INHERITED, L, 0, LeftId);
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
    Exit;
  end
  else if IsCurrText('inc') then
  begin
    Call_SCANNER;
    if not IsCurrText('(') then
      RaiseError(errTokenExpected, ['(', CurrToken.Text]);
    Push_SCANNER;
    Call_SCANNER;
    ID1 := Parse_Designator;
    Pop_SCANNER;
    Call_SCANNER;
    ID2 := Parse_Designator;
    if IsCurrText(',') then
    begin
      Call_SCANNER;
      Gen(OP_INC, ID2, Parse_Expression, ID1);
    end
    else
      Gen(OP_INC, ID2, NewConst(typeINTEGER, 1), ID1);
    Match(')');

    Exit;
  end
  else if IsCurrText('dec') then
  begin
    Call_SCANNER;
    if not IsCurrText('(') then
      RaiseError(errTokenExpected, ['(', CurrToken.Text]);
    Push_SCANNER;
    Call_SCANNER;
    ID1 := Parse_Designator;
    Pop_SCANNER;
    Call_SCANNER;
    ID2 := Parse_Designator;
    if IsCurrText(',') then
    begin
      Call_SCANNER;
      Gen(OP_DEC, ID2, Parse_Expression, ID1);
    end
    else
      Gen(OP_DEC, ID2, NewConst(typeINTEGER, 1), ID1);
    Match(')');

    Exit;
  end
  else if IsCurrText('SetLength') then
  begin
    Call_SCANNER;
    Match('(');
    LeftID := Parse_Designator;
    Call_SCANNER;
    Gen(OP_SET_LENGTH, LeftID, Parse_Expression, 0);
    Match(')');
    Exit;
  end
  else if IsCurrText('str') then
  begin
    LeftID := NewTempVar;

    Call_SCANNER;
    Match('(');

    try

    Gen(OP_PUSH, Parse_Expression, 3, LeftID);

    if IsCurrText(':') then
    begin
      Call_SCANNER;
      Gen(OP_PUSH, Parse_Expression, 2, LeftID);
    end
    else
      Gen(OP_PUSH, NewConst(typeINTEGER, 0), 2, LeftID);

    if IsCurrText(':') then
    begin
      Call_SCANNER;
      Gen(OP_PUSH, Parse_Expression, 1, LeftID);
    end
    else
      Gen(OP_PUSH, NewConst(typeINTEGER, 0), 1, LeftID);

    Match(',');
    Gen(OP_PUSH, Parse_Expression, 0, LeftID);

    finally
    Gen(OP_STR, LeftID, 0, 0);
    end;

    Match(')');
    Exit;
  end
  else if IsCurrText('new') then
  begin
    SetCompletionTarget('new');

    Call_SCANNER;

    Match('(');
    LeftId := Parse_Designator;
    SizeId := NewTempVar;
    SubId := NewTempVar;
    SetName(SubId, 'GetMem');
    SetKind(SubId, kindNONE);
    Gen(OP_EVAL, 0, 0, SubId);
    Gen(OP_SIZEOF, LeftId, 0, SizeId);
    Gen(OP_PUSH, LeftId, 0, SubId);
    Gen(OP_PUSH, SizeId, 1, SubId);
    Gen(OP_CALL, SubId, 0, 0);
    Match(')');
    Exit;
  end
  else if IsCurrText('dispose') then
  begin
    SetCompletionTarget('Dispose');

    Call_SCANNER;
    Match('(');
    LeftId := Parse_Designator;
    SizeId := NewTempVar;
    SubId := NewTempVar;
    SetName(SubId, 'FreeMem');
    SetKind(SubId, kindNONE);
    Gen(OP_EVAL, 0, 0, SubId);
    Gen(OP_SIZEOF, LeftId, 0, SizeId);
    Gen(OP_PUSH, LeftId, 0, SubId);
    Gen(OP_PUSH, SizeId, 1, SubId);
    Gen(OP_CALL, SubId, 0, 0);
    Match(')');
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
    Exit;
  end;

  if IsCurrText('(') then
    LeftID := Parse_Factor
  else
    LeftID := Parse_SimpleExpression;

  if IsEOF then
    Exit; 

  if IsCurrText(';') or (CurrToken.TokenClass = tcKeyword) then
  begin
    R := LastCodeRec;
    if R.Op = OP_CALL then
    begin
      SetKind(R.Res, KindNONE);
      R.Res := 0;
    end
    else if GetKind(LeftId) = kindCONST then
      RaiseError(errIdentifierExpectedNoArgs, [])
    else
      Gen(OP_CALL, LeftID, 0, 0);
    Exit;
  end;

  Gen(OP_LVALUE, LeftId, 0, 0);

  if IsCurrText(':=') then
  begin
    Call_SCANNER;
    Gen(OP_ASSIGN, LeftID, Parse_Expression, LeftID);
  end
  else if IsCurrText('(') then
  begin
    R := Gen(OP_CALL, LeftID, Parse_ArgumentList(LeftId), 0);

    if IsCurrText(':=') then
    begin
      R.Res := NewTempVar;
      Call_SCANNER;
      Gen(OP_ASSIGN, R.Res, Parse_Expression, R.Res);
    end
    else if IsCurrText('(') then
    begin
      R.Res := NewTempVar;
      Gen(OP_CALL, R.Res, Parse_ArgumentList(R.Res), 0);
    end;
  end
  else
  begin
    Gen(OP_CALL, LeftID, 0, 0);
  end;
end;

procedure TPascalParser.Parse_CaseStmt;
var
  lg, lf, lt, lc, id, expr1_id, cond_id: Integer;
begin
  Match('case');
  lg := NewLabel;
  cond_id := NewTempVar;
  id := Parse_Expression;
  Match('of');
  repeat
    // Parse case selector
    lt := NewLabel;
    lf := NewLabel;
    repeat
      lc := NewLabel;
      expr1_id := Parse_ConstantExpression;

      if IsCurrText('..') then
      begin
        Gen(OP_GE, id, expr1_id, cond_id);
        Gen(OP_GO_FALSE, lc, cond_id, 0);
        Match('..');
        Gen(OP_LE, id, Parse_ConstantExpression, cond_id);
        Gen(OP_GO_FALSE, lc, cond_id, 0);
      end
      else
        Gen(OP_EQ, id, expr1_id, cond_id);
      Gen(OP_GO_TRUE, lt, cond_id, 0);
      SetLabelHere(lc);

      if NotMatch(',') then
        break;
    until false;
    Gen(OP_GO, lf, 0, 0);
    SetLabelHere(lt);
    Match(':');
    Parse_Statement;
    Gen(OP_GO, lg, 0, 0);
    SetLabelHere(lf);
    // end of case selector
    if NotMatch(';') then
      Break;
    if IsCurrText('else') then
      break;
    if IsCurrText('end') then
      break;
  until false;
  if IsCurrText('else') then
  begin
    Match('else');
    Parse_StmtList;
  end;
  if IsCurrText(';') then
    Match(';');
  Match('end');
  SetLabelHere(lg);
end;

procedure TPascalParser.Parse_IfStmt;
var
  lf, lg: Integer;
begin
  Match('if');
  lf := NewLabel;
  Gen(OP_GO_FALSE, lf, Parse_Expression, 0);
  Match('then');
  if not IsCurrText('else') then
    Parse_Statement;
  if IsCurrText('else') then
  begin
		Gen(OP_NOP, 0, 0, 0);
		lg := NewLabel();
		Gen(OP_GO, lg, 0, 0);
  	SetLabelHere(lf);
    Match('else');
    Parse_Statement;
		SetLabelHere(lg);
  end
  else
    SetLabelHere(lf);
end;

procedure TPascalParser.Parse_GotoStmt;
begin
  Match('goto');
  Gen(OP_GO, Parse_Label, 0, 0);
end;

procedure TPascalParser.Parse_BreakStmt;
begin
	if BreakStack.Count = 0 then
    RaiseError(errBreakOrContinueOutsideOfLoop, []);
	Match('break');
  if IsCurrText('(') then
  begin
    Match('(');
    Match(')');
  end;
	Gen(OP_GO, BreakStack.TopLabel, 0, 0);
end;

procedure TPascalParser.Parse_ContinueStmt;
begin
	if ContinueStack.Count = 0 then
    RaiseError(errBreakOrContinueOutsideOfLoop, []);
	Match('continue');
  if IsCurrText('(') then
  begin
    Match('(');
    Match(')');
  end;
	Gen(OP_GO, ContinueStack.TopLabel, 0, 0);
end;

procedure TPascalParser.Parse_ExitStmt;
begin
	Match('exit');
  if IsCurrText('(') then
  begin
    Match('(');
    Match(')');
  end;
  Gen(OP_EXIT, SkipLabelStack.Top, 0, CurrLevel);
//  Gen(OP_GO, SkipLabelStack.Top, 0, CurrLevel);
end;

procedure TPascalParser.Parse_WhileStmt;
var
  lf, lg: Integer;
begin
	Match('while');
  lf := NewLabel;
	lg := NewLabel;
	SetLabelHere(lg);
	Gen(OP_GO_FALSE, lf, Parse_Expression, 0);
	Match('do');
	BreakStack.Push(lf);
	ContinueStack.Push(lg);
	Parse_Statement;
	BreakStack.Pop;
  ContinueStack.Pop;
	Gen(OP_GO, lg, 0, 0);
  SetLabelHere(lf);
end;

procedure TPascalParser.Parse_RepeatStmt;
var
  lf, lg: Integer;
begin
	Match('repeat');
  lf := NewLabel;
	lg := NewLabel;
  SetLabelHere(lf);
  repeat
    if IsCurrText('until') then
      Break;
    if IsEOF then
      Break;

  	BreakStack.Push(lg);
	  ContinueStack.Push(lf);
    Parse_Statement;
  	BreakStack.Pop;
    ContinueStack.Pop;
    if NotMatch(';') then
      Break;

  until false;
  Match('until');
	Gen(OP_GO_FALSE, lf, Parse_Expression, 0);
  SetLabelHere(lg);
end;

procedure TPascalParser.Parse_ForStmt;
var
  id, expr1_id, expr2_id, limit_cond_id1, limit_cond_id2: Integer;
  i: Boolean;
  lf, lg, lc: Integer;

  element_id, collection_id, enumerator_id, bool_id: Integer;
begin
  Match('for');
  if IsNextText('in') then
  begin
    Inc(ForInCounter);
    lf := NewLabel;
	  lg := NewLabel;
  	lc := NewLabel;
    enumerator_id := NewTempVar;
    bool_id := NewTempVar;
    element_id := Parse_Ident;
    Match('in');
    collection_id := Parse_Expression;
    Match('do');
    Gen(OP_GET_ENUMERATOR, collection_id, ForInCounter, enumerator_id);
    SetLabelHere(lg);
    Gen(OP_CURRENT, enumerator_id, ForInCounter, element_id);
    BreakStack.Push(lf);
    ContinueStack.Push(lc);
    Parse_Statement;
    BreakStack.Pop;
    ContinueStack.Pop;
    SetLabelHere(lc, ForInCounter);
    Gen(OP_MOVE_NEXT, element_id, ForInCounter, bool_id);
    Gen(OP_GO_FALSE, lf, bool_id, 0);
    Gen(OP_GO, lg, 0, 0);
    SetLabelHere(lf, 0, ForInCounter);
    Exit;
  end;

  lf := NewLabel;
	lg := NewLabel;
	lc := NewLabel;
  limit_cond_id1 := NewTempVar;
  limit_cond_id2 := NewTempVar;
  expr1_id := NewTempVar;
  expr2_id := NewTempVar;
  id := Parse_Ident;
  Match(':=');
  Gen(OP_ASSIGN, expr1_id, Parse_Expression, expr1_id);
  Gen(OP_ASSIGN, id, expr1_id, id);
  if IsCurrText('downto') then
  begin
    Match('downto');
    Gen(OP_ASSIGN, expr2_id, Parse_Expression, expr2_id);
    Gen(OP_LT, id, expr2_id, limit_cond_id1);
    i := false;
  end
  else
  begin
    Match('to');
    Gen(OP_ASSIGN, expr2_id, Parse_Expression, expr2_id);
    Gen(OP_GT, id, expr2_id, limit_cond_id1);
    i := true;
  end;
	Gen(OP_GO_TRUE, lg, limit_cond_id1, 0);
  Match('do');
  SetLabelHere(lf);
  BreakStack.Push(lg);
  ContinueStack.Push(lc);
  Parse_Statement;
  BreakStack.Pop;
  ContinueStack.Pop;
  SetLabelHere(lc);
  if i then
  begin
    Gen(OP_INC, id, NewConst(typeINTEGER, 1), id);
    Gen(OP_GT, id, expr2_id, limit_cond_id2);
  end
  else
  begin
    Gen(OP_DEC, id, NewConst(typeINTEGER, 1), id);
    Gen(OP_LT, id, expr2_id, limit_cond_id2);
  end;
	Gen(OP_GO_FALSE, lf, limit_cond_id2, 0);
  SetLabelHere(lg);
end;

procedure TPascalParser.Parse_WithStmt;
var
  id, K: Integer;
begin
  K := WithStack.Count;
  Match('with');
  repeat
    id := Parse_Expression;
    Gen(OP_BEGIN_WITH, id, 0, 0);
    WithStack.Push(id);
    if NotMatch(',') then
      Break;
  until false;
  Match('do');
  Parse_Statement;

  while WithStack.Count > K do
  begin
    id := WithStack.Top;
    Gen(OP_END_WITH, id, 0, 0);
    WithStack.Pop;
  end;
end;

procedure TPascalParser.Parse_TryStmt;
var
  id, type_id, l_try, BlockId: Integer;
begin
  l_try := GenBeginTry;

  Match('try');

  repeat
    if IsCurrText('except') then
      Break;
    if IsCurrText('finally') then
      Break;
    if IsEOF then
      Break;
    Parse_Statement;
    if NotMatch(';') then
      Break;
  until false;

  if IsCurrText('except') then
  begin
    Gen(OP_GO, l_try, 0, 0);
    GenExcept;

    Call_SCANNER;
    //ExceptionBlock

    if IsCurrText('on') then
    begin
      while IsCurrText('on') do
      begin
        BlockId := NewTempVar;
        LevelStack.push(BlockId);
        Gen(OP_BEGIN_BLOCK, BlockId, 0, 0);

        if IsNext2Text(':') then
        begin
          DECLARE_SWITCH := true;
          Match('on');
          id := Parse_Ident;
          DECLARE_SWITCH := false;
          Match(':');
          type_id := Parse_Ident;
        end
        else
        begin
          DECLARE_SWITCH := false;
          Match('on');
          type_id := Parse_Ident;
          id := NewTempVar;
        end;

        Gen(OP_ASSIGN_TYPE, id, type_id, 0);

        GenExceptOn(type_id);
        Gen(OP_ASSIGN, id, CurrExceptionObjectId, id);

//        Gen(OP_BEGIN_EXCEPT_BLOCK, 0, 0, 0);
        Match('do');
        Parse_Statement;
        Gen(OP_END_EXCEPT_BLOCK, 0, 0, 0);

        Gen(OP_GO, l_try, 0, 0);

        Gen(OP_END_BLOCK, BlockId, 0, 0);
        LevelStack.Pop;
        if IsCurrText(';') then
          Match(';');
      end;

      GenExceptOn(0);

      if IsCurrText('else') then
      begin
//        Gen(OP_BEGIN_EXCEPT_BLOCK, 0, 0, 0);
        Call_SCANNER;
        Parse_Statement;

        if IsCurrText(';') then
          Match(';');
        Gen(OP_END_EXCEPT_BLOCK, 0, 0, 0);
      end;
    end
    else
    begin
//      Gen(OP_BEGIN_EXCEPT_BLOCK, 0, 0, 0);
      repeat
        if IsCurrText('end') then
          Break;
        if IsEOF then
          Break;
        Parse_Statement;
        if NotMatch(';') then
          Break;
      until false;
      Gen(OP_END_EXCEPT_BLOCK, 0, 0, 0);
    end;
  end // except
  else if IsCurrText('finally') then
  begin
    GenFinally;
    Call_SCANNER;
    repeat
      if IsCurrText('end') then
        Break;
      if IsEOF then
        Break;
      Parse_Statement;
      if NotMatch(';') then
        Break;
    until false;
    Gen(OP_COND_RAISE, 0, 0, 0);
  end // finally
  else
    Match('finally');
  SetLabelHere(l_try);
  GenEndTry;
  Match('end');
end;

procedure TPascalParser.Parse_RaiseStmt;
begin
  Match('raise');
  if IsCurrText(';') then
    Gen(OP_RAISE, 0, RaiseMode, 0)
  else
  begin
    Gen(OP_RAISE, Parse_Expression, RaiseMode, 0);
  end;
end;

// EXPRESSIONS

function TPascalParser.Parse_ArgumentList(SubId: Integer): Integer;
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

function TPascalParser.Parse_ConstantExpression: Integer;
begin
  result := Parse_Expression;
end;

function TPascalParser.Parse_Expression: Integer;
var
  Op: Integer;
begin
  result := Parse_SimpleExpression;
  while (CurrToken.Id = OP_LT) or
        (CurrToken.Id = OP_LE) or
        (CurrToken.Id = OP_GT) or
        (CurrToken.Id = OP_GE) or
        (CurrToken.Id = OP_EQ) or
        (CurrToken.Id = OP_NE) or
        (CurrToken.Id = OP_IS) or
        (CurrToken.Id = OP_AS) or
        (CurrToken.Id = OP_SET_MEMBERSHIP) do
  begin
    Op := CurrToken.Id;
    Call_SCANNER;
		result := BinOp(Op, result, Parse_SimpleExpression);
  end;
end;

function TPascalParser.Parse_SimpleExpression: Integer;
var
  Op, L, I: Integer;
  Lst: TList;
  R: TCodeRec;
begin
  if CompleteBooleanEval then
  begin
    result := Parse_Term;
    while (CurrToken.Id = OP_PLUS) or
          (CurrToken.Id = OP_MINUS) or
          (CurrToken.Id = OP_OR) or
          (CurrToken.Id = OP_XOR) do
    begin
      Op := CurrToken.Id;
      Call_SCANNER;
      result := BinOp(Op, result, Parse_Term);
    end;
    Exit;
  end;

  L := 0;
  Lst := TList.Create;
  try
    result := Parse_Term;
    while (CurrToken.Id = OP_PLUS) or
          (CurrToken.Id = OP_MINUS) or
          (CurrToken.Id = OP_OR) or
          (CurrToken.Id = OP_XOR) do
    begin
      if (CurrToken.Id = OP_OR) and (Lst.Count = 0) then
        L := NewLabel;

      if CurrToken.Id = OP_OR then
      begin
        R := Gen(OP_ASSIGN, 0, result, 0);
        Lst.Add(R);
        Gen(OP_GO_TRUE_BOOL, L, result, 0);
      end;

      Op := CurrToken.Id;
      Call_SCANNER;
      result := BinOp(Op, result, Parse_Term);
    end;

    if Lst.Count > 0 then
    begin
      for I:=0 to Lst.Count - 1 do
      begin
        R := TCodeRec(Lst[I]);
        R.Arg1 := result;
        R.Res := result;
      end;
      SetLabelHere(L);
    end;
  finally
    Lst.Free;
  end;
end;

function TPascalParser.Parse_Term: Integer;
var
  Op, L, I: Integer;
  Lst: TList;
  R: TCodeRec;
begin
  if CompleteBooleanEval then
  begin
    result := Parse_Factor;
    while (CurrToken.Id = OP_MULT) or
          (CurrToken.Id = OP_DIV) or
          (CurrToken.Id = OP_IDIV) or
          (CurrToken.Id = OP_MOD) or
          (CurrToken.Id = OP_SHL) or
          (CurrToken.Id = OP_SHR) or
          (CurrToken.Id = OP_AND) do
    begin
      Op := CurrToken.Id;
      Call_SCANNER;
      result := BinOp(Op, result, Parse_Factor);
    end;
    Exit;
  end;

  L := 0;
  Lst := TList.Create;
  try
    result := Parse_Factor;
    while (CurrToken.Id = OP_MULT) or
          (CurrToken.Id = OP_DIV) or
          (CurrToken.Id = OP_IDIV) or
          (CurrToken.Id = OP_MOD) or
          (CurrToken.Id = OP_SHL) or
          (CurrToken.Id = OP_SHR) or
          (CurrToken.Id = OP_AND) do
    begin
      if (CurrToken.Id = OP_AND) and (Lst.Count = 0) then
        L := NewLabel;

      if CurrToken.Id = OP_AND then
      begin
        R := Gen(OP_ASSIGN, 0, result, 0);
        Lst.Add(R);
        Gen(OP_GO_FALSE_BOOL, L, result, 0);
      end;

      Op := CurrToken.Id;
      Call_SCANNER;
      result := BinOp(Op, result, Parse_Factor);
    end;

    if Lst.Count > 0 then
    begin
      for I:=0 to Lst.Count - 1 do
      begin
        R := TCodeRec(Lst[I]);
        R.Arg1 := result;
        R.Res := result;
      end;
      SetLabelHere(L);
    end;

  finally
    Lst.Free;
  end;
end;

function TPascalParser.Parse_Factor: Integer;
var
  SubId, K, Id: Integer;
  ValidConst: Boolean;
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
	else if IsCurrText('+') then
  begin
		Call_SCANNER;
		result := Parse_Factor;
  end
	else if IsCurrText('-') then
  begin
		Call_SCANNER;
    ValidConst := CurrToken.TokenClass in [tcIntegerConst, tcDoubleConst];
    Id := Parse_Factor;
    if ValidConst then
    begin
      result := Id;
      SetValue(Id, - GetValue(id));
    end
    else
  		result := UnaryOp(OP_NEG, Id);
  end
	else if IsCurrText('not') then
  begin
		Call_SCANNER;
		result := UnaryOp(OP_NOT, Parse_Factor);
  end
  else if IsCurrText('(') then
  begin
    Match('(');
    result := Parse_Expression;
    Match(')');
    if IsCurrText('.') or IsCurrText('[') then
      result := Parse_Designator(result);
  end
  else if IsCurrText('[') then
  begin
    result := Parse_SetConstructor;
  end
  else if IsCurrText('@') then
  begin
    Match('@');
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
  else if IsCurrText('sizeof') then
  begin
    Match('sizeof');
    Match('(');
    result := NewTempVar;
    Gen(OP_SIZEOF, Parse_Expression, 0, result);
    Match(')');
  end
  else if IsCurrText('typeinfo') then
  begin
    Match('typeinfo');
    Match('(');
    result := NewTempVar;
    SetType(result, typePOINTER);
    Gen(OP_TYPEINFO, Parse_Expression, 0, result);
    Match(')');
  end
  else if IsCurrText('pred') then
  begin
    Match('pred');
    Match('(');
    result := NewTempVar;
    Gen(OP_PRED, Parse_Expression, 0, result);
    Match(')');
  end
  else if IsCurrText('succ') then
  begin
    Match('succ');
    Match('(');
    result := NewTempVar;
    Gen(OP_SUCC, Parse_Expression, 0, result);
    Match(')');
  end
  else if IsCurrText('ord') then
  begin
    Match('ord');
    Match('(');
    result := NewTempVar;
    Gen(OP_ORD, Parse_Expression, 0, result);
    Match(')');
  end
  else if IsCurrText('chr') then
  begin
    Match('chr');
    Match('(');
    result := NewTempVar;
    Gen(OP_CHR, Parse_Expression, 0, result);
    Match(')');
  end
  else if IsCurrText('high') then
  begin
    Match('high');
    Match('(');
    result := NewTempVar;
    Gen(OP_HIGH, Parse_Expression, 0, result);
    Match(')');
  end
  else if IsCurrText('low') then
  begin
    Match('low');
    Match('(');
    result := NewTempVar;
    Gen(OP_LOW, Parse_Expression, 0, result);
    Match(')');
  end
  else if IsCurrText('abs') then
  begin
    Match('abs');
    Match('(');
    result := NewTempVar;
    Gen(OP_ABS, Parse_Expression, 0, result);
    Match(')');
  end
  else if IsCurrText('inherited') then
  begin
    Call_SCANNER;
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
  else
  begin
    result := Parse_Designator;

    if IsCurrText(':=') then
      if (GetName(result) <> '') and StrEql(GetName(result), GetName(CurrSubId)) then
   	  	result := CurrResultId;

    if IsCurrText('(') then
    begin
      SubId := result;
      result := NewTempVar;
      K := Parse_ArgumentList(SubId);
      Gen(OP_CALL, SubID, K, result);

      if IsCurrText('.') or IsCurrText('[') then
        result := Parse_Designator(result);
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

function TPascalParser.Parse_SetConstructor: Integer;
var
  id1, id2: Integer;
begin
  Match('[');
  if not IsCurrText(']') then
  begin
    result := NewTempVar;

    repeat
      if IsEOF then
        break;
      // parse member group

      id1 := Parse_Expression;
      if IsCurrText('..') then
      begin
        Match('..');
        id2 := Parse_Expression;
        Gen(OP_CHECK_SUBRANGE_TYPE, id1, id2, 0);
        Gen(OP_SET_INCLUDE_INTERVAL, result, id1, id2);
      end
      else
        Gen(OP_SET_INCLUDE, result, id1, 0);

      If NotMatch(',') then
        break;
    until false;

  end
  else
    result := EmptySetId;

  Match(']');
end;

function TPascalParser.Parse_Designator(init_id: Integer = 0): Integer;
var
  ok: Boolean;
  id: Integer;
begin
  if init_id = 0 then
    result := Parse_QualId
  else
    result := init_id;

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
    else if IsCurrText('(') then
    begin
      Id := result;
      result := NewTempVar;
      Gen(OP_CALL, Id, Parse_ArgumentList(Id), result);
      ok := true;
    end
    else if IsCurrText('^') then
    begin
      Match('^');
      id := result;
      result := NewTempVar;
      Gen(OP_TERMINAL, id, 0, result);
      ok := true;
    end
    else
      ok := false;
  until not ok;
end;

function TPascalParser.Parse_QualId: Integer;
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

function TPascalParser.Parse_Label: Integer;
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

function TPascalParser.Parse_Ident: Integer;
begin
  if CurrToken.TokenClass = tcKeyword then
  begin
    if IsCurrText('nil') then
    begin
      result := NilId;
      Call_SCANNER;
      Exit;
    end;
  end;
  result := inherited Parse_Ident;
end;

procedure TPascalParser.Call_SCANNER;
var
  S: String;
begin
  inherited;

  while CurrToken.TokenClass = tcSeparator do
  begin
    Gen(OP_SEPARATOR, CurrModule.ModuleNumber, CurrToken.Id, 0);
    inherited Call_SCANNER;
  end;

  if CurrToken.TokenClass = tcIdentifier then
  begin
    S := CurrToken.Text;
    if StrEql(S, 'String') then
    begin
      {$IFDEF UNIC}
        CurrToken.Id := typeUNICSTRING;
      {$ELSE}
        CurrToken.Id := typeANSISTRING;
      {$ENDIF}
    end
    else if StrEql(S, 'Char') then
    begin
      {$IFDEF UNIC}
        CurrToken.Id := typeWIDECHAR;
      {$ELSE}
        CurrToken.Id := typeANSICHAR;
      {$ENDIF}
    end
    else if StrEql(S, 'PChar') then
    begin
      {$IFDEF UNIC}
        CurrToken.Id := typePWIDECHAR;
      {$ELSE}
        CurrToken.Id := typePANSICHAR;
      {$ENDIF}
    end
    else if StrEql(S, 'Boolean') then
      CurrToken.Id := typeBOOLEAN
    else if StrEql(S, 'IInterface') then
      CurrToken.Id := H_IUnknown
  end;
end;

procedure TPascalParser.ReadToken;
begin
  inherited;

  while CurrToken.TokenClass = tcSeparator do
  begin
    Gen(OP_SEPARATOR, CurrModule.ModuleNumber, CurrToken.Id, 0);
    inherited ReadToken;
  end;
end;

function TPascalParser.Parse_DirectiveList(SubId: Integer): TIntegerList;
begin
  result := TIntegerList.Create;

  repeat
    if IsCurrText('overload') then
    begin
      Call_SCANNER;
      result.Add(dirOVERLOAD);
      SetOverloaded(SubId);
      Match(';');
    end
    else if IsCurrText('forward') then
    begin
      Call_SCANNER;
      result.Add(dirFORWARD);
      Match(';');
    end
    else if IsCurrText('message') then
    begin
      if DECLARE_SWITCH then
        if CurrToken.Id = StCard then
          DiscardLastSTRecord;

      Call_SCANNER;
      Parse_Expression;
      if IsCurrText(';') then
        Match(';');
    end
    else if IsCurrText('stdcall') then
    begin
      Call_SCANNER;
      SetCallConvention(SubId, ccSTDCALL);
      if IsCurrText(';') then
        Match(';');
    end
    else if IsCurrText('safecall') then
    begin
      Call_SCANNER;
      SetCallConvention(SubId, ccSAFECALL);
      if IsCurrText(';') then
        Match(';');
    end
    else if IsCurrText('register') then
    begin
      Call_SCANNER;
      SetCallConvention(SubId, ccREGISTER);
      if IsCurrText(';') then
        Match(';');
    end
    else if IsCurrText('cdecl') then
    begin
      Call_SCANNER;
      SetCallConvention(SubId, ccCDECL);
      if IsCurrText(';') then
        Match(';');
    end
    else if IsCurrText('msfastcall') then
    begin
      Call_SCANNER;
      SetCallConvention(SubId, ccMSFASTCALL);
      if IsCurrText(';') then
        Match(';');
    end
    else if IsCurrText('pascal') then
    begin
      Call_SCANNER;
      SetCallConvention(SubId, ccPASCAL);
      if IsCurrText(';') then
        Match(';');
    end
    else if IsCurrText('virtual') then
    begin
      Call_SCANNER;
      result.Add(dirVIRTUAL);
      SetCallMode(SubId, cmVIRTUAL);
      Match(';');
    end
    else if IsCurrText('dynamic') then
    begin
      Call_SCANNER;
      Match(';');
    end
    else if IsCurrText('deprecated') then
    begin
      Call_SCANNER;
      Match(';');
    end
    else if IsCurrText('platform') then
    begin
      Call_SCANNER;
      Match(';');
    end
    else if IsCurrText('library') then
    begin
      Call_SCANNER;
      Match(';');
    end
    else if IsCurrText('assembler') then
    begin
      Call_SCANNER;
      Match(';');
    end
    else if IsCurrText('override') then
    begin
      Call_SCANNER;
      result.Add(dirOVERRIDE);
      SetCallMode(SubId, cmOVERRIDE);
      Match(';');
    end
    else if IsCurrText('abstract') then
    begin
      Call_SCANNER;
      result.Add(dirABSTRACT);
      Match(';');
    end
    else if IsCurrText('reintroduce') then
    begin
      Call_SCANNER;
      result.Add(dirREINTRODUCE);
      Match(';');
    end
    else
      break;
  until false;

  if result.IndexOf(dirVIRTUAL) >= 0 then
    if result.IndexOf(dirVIRTUAL) = -1 then
      CreateError(errAbstractMethodsMustBeVirtual, []);

  if Parse_PortabilityDirective then
  begin
    if IsCurrText(';') then
      Call_SCANNER;
  end;
end;

function TPascalParser.Parse_PortabilityDirective: Boolean;
var
  ok: Boolean;
begin
  result := false;
  repeat
    ok := false;
    if IsCurrText('platform') then
    begin
      Call_SCANNER;
      result := true;
      ok := true;
    end;
    if IsCurrText('deprecated') then
    begin
      Call_SCANNER;
      result := true;
      ok := true;
    end;
    if IsCurrText('library') then
    begin
      Call_SCANNER;
      result := true;
      ok := true;
    end;
  until not ok;
end;

procedure TPascalParser.InitSub(var SubId: Integer);
begin
  CheckAbstract(SubId);
  ReplaceForwardDeclaration(SubId);
  inherited InitSub(SubId);
end;

end.
