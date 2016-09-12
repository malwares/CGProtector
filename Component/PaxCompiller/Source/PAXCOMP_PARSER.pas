////////////////////////////////////////////////////////////////////////////
// PaxCompiler
// Site: http://www.paxcompiler.com
// Author: Alexander Baranovsky (paxscript@gmail.com)
// ========================================================================
// Copyright (c) Alexander Baranovsky, 2006-2008. All rights reserved.
// Code Version: 2.4
// ========================================================================
// Unit: PAXCOMP_PARSER.pas
// ========================================================================
////////////////////////////////////////////////////////////////////////////

{$I PaxCompiler.def}
unit PAXCOMP_PARSER;
interface
uses
{$IFDEF LINUX}
{$IFDEF FPC}
  uuid, // in hash folder
{$ENDIF}
{$ENDIF}
  SysUtils,
  Classes,
  TypInfo,
  PAXCOMP_CONSTANTS,
  PAXCOMP_SYS,
  PAXCOMP_MODULE,
  PAXCOMP_SCANNER,
  PAXCOMP_LABEL_STACK,
  PAXCOMP_SYMBOL_REC,
  PAXCOMP_BYTECODE,
  PAXCOMP_TYPEINFO,
  PAXCOMP_PROG,
  PAXCOMP_MAP,
  PAXCOMP_SYMBOL_TABLE;
type
   TBaseParser = class;
   TBaseParserClass = class of TBaseParser;
   TBaseParser = class
   private
     scanner: TBaseScanner;
     keywords: TFastStringList;
     LValueIndex: Integer;
     SkipWhenNotFound: Boolean;
     function GetFinSubLabel: Integer;
     function GetCurrLevel: Integer;
     function GetCurrSubId: Integer;
     function GetCurrResultId: Integer;
     function GetCurrSelfId: Integer;
     function GetNilId: Integer;
     function GetEmptySetId: Integer;
     function GetCurrExceptionObjectId: Integer;
     function GetTryCount: Integer;
     procedure SetTryCount(Value: Integer);
     function GetDebugMode: Boolean;
     function GetRaiseMode: Integer;
     function GetStCard: Integer;
     function GetTrueId: Integer;
     function GetFalseId: Integer;
     function GetCodeCard: Integer;
     function CreateParser(const FileName: String): TBaseParser;
   protected
     function CreateScanner: TBaseScanner; virtual; abstract;
     function GetLanguageName: String; virtual; abstract;
     function GetFileExt: String; virtual; abstract;
     function GetLanguageId: Integer; virtual; abstract;
     function GetUpcase: Boolean; virtual; abstract;
     function ReplaceForwardDeclaration(var ID: Integer; IsExternalUnit: Boolean = false): Boolean; virtual;
   public
     kernel: Pointer;
     PrintKeyword: String;
     PrintlnKeyword: String;
     UpCase: Boolean;
     LanguageId: Integer;
     CurrToken: TToken;
     DECLARE_SWITCH: Boolean;
     EXECUTABLE_SWITCH: Integer;
     FIELD_OWNER_ID: Integer;
     SKIP_STATEMENT_TERMINATOR: Boolean;
     CurrModule: TModule;
     BreakStack: TEntryStack;
     ContinueStack: TEntryStack;
     WithStack: TIntegerStack;
     SkipLabelStack: TIntegerStack;
     ExitLabelStack: TIntegerStack;
     try_stack: TIntegerStack;
     CallConv: Integer;
     DeclareCallConv: Integer;
     ScriptClasses: TIntegerList;
     LevelStack: TIntegerStack;
     CompleteBooleanEval: Boolean;
     UnitLookup: Boolean;
     IsConsoleApp: Boolean;
     Alignment: Integer;
     LinePos: Integer;
     InterfaceOnly: Boolean;
     BRP: Boolean;
     constructor Create; virtual;
     destructor Destroy; override;
     procedure ParseProgram; virtual; abstract;
     function Parse_Expression: Integer; virtual; abstract;
     procedure Parse_Unit(IsExternalUnit: Boolean = false); virtual;
     procedure Init(i_kernel: Pointer; M: TModule); virtual;
     procedure InitScanner(const S: String);
     function Lookup(const S: String; Level: Integer): Integer;
     function Lookups(const S: String; Levels: TIntegerStack): Integer;

     function FindConstructorId(ClassId: Integer): Integer;
     function FindDestructorId(ClassId: Integer): Integer;

     procedure AddKeyword(const S: String);
     function IsKeyword(const S: String): Boolean;
     function Parse_Ident: Integer; virtual;
     function Parse_EnumIdent: Integer;
     function Parse_FormalParameter: Integer; virtual;
     function Parse_BooleanLiteral: Integer; virtual;
     function Parse_CharLiteral: Integer; virtual;
     function Parse_PCharLiteral: Integer; virtual;
     function Parse_IntegerLiteral: Integer; virtual;
     function Parse_DoubleLiteral: Integer; virtual;
     function BinOp(Op, Arg1, Arg2: Integer): Integer;
     function UnaryOp(Op, Arg1: Integer): Integer;
     function NewConst(TypeID: Integer): Integer; overload;
     function NewConst(TypeID: Integer; const Value: Variant): Integer; overload;
     function NewVar(const VarName: String): Integer;
     function NewTempVar: Integer; overload;
     function NewTempVar(TypeId: Integer): Integer; overload;
     function NewTypeAlias: Integer;
     function NewLabel: Integer;
     function NewField(const FieldName: String; OwnerId: Integer): Integer;
     function Gen(Op, Arg1, Arg2, Res: Integer): TCodeRec;
     procedure ReadToken; virtual;
     procedure Call_SCANNER; virtual;
     function IsCurrText(const S: String): Boolean;
     function IsNextText(const S: String): Boolean;
     function IsNext2Text(const S: String): Boolean;
     function GetNextText: String;
     procedure Match(const S: String);
     function NotMatch(const S: String): Boolean;
     function IsEOF: Boolean;
     function IsNewLine: Boolean;
     function GetFullName(Id: Integer): String;
     function GetName(Id: Integer): String;
     procedure SetName(Id: Integer; const S: String);
     procedure SetValue(Id: Integer; const Value: Variant);
     function GetCount(Id: Integer): Integer;
     procedure SetParam(Id: Integer; value: boolean);
     procedure SetCount(Id: Integer; value: Integer);
     function GetParamId(SubId, J: Integer): Integer;
     procedure SetPatternId(Id: Integer; PatternId: Integer);
     procedure SetOwnerId(Id: Integer; OwnerId: Integer);
     procedure SetByRef(Id: Integer);
     procedure SetIsConst(Id: Integer);
     procedure SetOptional(Id: Integer);
     procedure SetPacked(Id: Integer);
     procedure SetCallConvention(Id: Integer; value: Integer);
     procedure SetOverloaded(SubId: Integer);
     procedure SetCallMode(Id: Integer; value: Integer);
     procedure SetKind(Id: Integer; Kind: Integer);
     function GetLevel(Id: Integer): Integer;
     procedure SetLevel(Id: Integer; Level: Integer);
     function GetType(Id: Integer): Integer;
     procedure SetType(Id: Integer; TypeID: Integer);
     function GetKind(Id: Integer): Integer;
     procedure SetPosition(Id, Position: Integer);
     procedure SetVarCount(Id, value: Integer);
     procedure SetLabelHere(Id: Integer;
                            Arg2: Integer = 0;
                            Res: Integer = 0);
     procedure SetVisibility(Id: Integer; vis: TClassVisibility);
     procedure SetReadId(PropId, ReadId: Integer);
     procedure SetWriteId(PropId, WriteId: Integer);
     procedure SetDefault(Id: Integer; value: Boolean);
     procedure SetTypedConst(Id: Integer);
     procedure SetOpenArray(ID: Integer; value: Boolean);
     procedure SetExternal(Id: Integer; value: Boolean);

     procedure SetHost(Id: Integer; value: Boolean);
     function GetHost(Id: Integer): Boolean;
     procedure SetAlignment(TypeId, Value: Integer);

     procedure BeginSub(SubId: Integer); virtual;
     procedure RemoveSub;
     procedure BeginClassConstructor(SubId, ClassTypeId: Integer); virtual;
     procedure BeginClassDestructor(SubId, ClassTypeId: Integer); virtual;
     procedure BeginClassMethod(SubId, ClassTypeId: Integer;
                                HasResult: Boolean;
                                IsSharedMethod: Boolean); virtual;
     procedure BeginStructureConstructor(SubId, StructTypeId: Integer);
     procedure BeginStructureDestructor(SubId, StructTypeId: Integer);
     procedure BeginStructureMethod(SubId, StructTypeId: Integer;
                                    HasResult: Boolean;
                                    IsSharedMethod: Boolean); virtual;
     procedure BeginInterfaceMethod(SubId, IntfTypeId: Integer;
                                    HasResult: Boolean); virtual;
     procedure CheckAbstract(SubId: Integer);
     procedure InitSub(var SubId: Integer); virtual;
     procedure EndSub(SubId: Integer); virtual;
     function GetIncludedFileExt: String; virtual; abstract;

     procedure BeginProperty(PropId, ClassTypeId: Integer);
     procedure EndProperty(PropId: Integer);

     procedure BeginNamespace(Id: Integer; Jump: Boolean = true);
     procedure EndNamespace(Id: Integer; Jump: Boolean = true);

     procedure BeginArrayType(TypeId: Integer);
     procedure EndArrayType(TypeId: Integer);

     procedure BeginRecordType(TypeId: Integer);
     procedure EndRecordType(TypeId: Integer);

     procedure BeginClassType(TypeId: Integer);
     procedure EndClassType(TypeId: Integer; IsForward: Boolean = false);

     procedure BeginInterfaceType(TypeId: Integer);
     procedure SetGuid(IntfTypeId: Integer; const S: String);
     procedure SetNewGuid(IntfTypeId: Integer);
     procedure EndInterfaceType(TypeId: Integer; IsForward: Boolean = false);

     procedure BeginEnumType(TypeId, TypeBaseId: Integer);
     procedure EndEnumType(TypeId, ACount: Integer);

     procedure BeginSubrangeType(TypeId, TypeBaseId: Integer);
     procedure EndSubrangeType(TypeId: Integer);

     procedure BeginPointerType(TypeId: Integer);
     procedure EndPointerType(TypeId: Integer);

     procedure BeginClassReferenceType(TypeId: Integer);
     procedure EndClassReferenceType(TypeId: Integer);

     procedure BeginDynamicArrayType(TypeId: Integer);
     procedure EndDynamicArrayType(TypeId: Integer);

     procedure BeginShortStringType(TypeId: Integer);
     procedure EndShortStringType(TypeId: Integer);

     procedure BeginProceduralType(TypeId, SubID: Integer);
     procedure EndProceduralType(TypeId: Integer);

     procedure BeginSetType(TypeId, TypeBaseId: Integer);
     procedure EndSetType(TypeId: Integer);

     procedure BeginInitialization;
     procedure EndInitialization;
     procedure BeginFinalization;
     procedure EndFinalization;

     function GenBeginTry: Integer; // returns label
     procedure GenEndTry;
     procedure GenFinally;
     procedure GenExcept;
     procedure GenExceptOn(type_id: Integer);

     procedure GenDestroyGlobalDynamicVariables(B1, B2: Integer);

     procedure SetForward(SubId: Integer; value: Boolean);
     function IsForward(SubId: Integer): Boolean;

     procedure AddModuleFromFile(FileName: String;
                                 UsedUnitId: Integer;
                                 IsImplementationSection: Boolean);

     function GetValue(id: Integer): Variant;

     procedure RemoveInstruction(Op, Arg1, Arg2, Res: Integer);
     function LastCodeRec: TCodeRec;
     function LastEvalRec(Id: Integer): TCodeRec;

     function LookupForwardDeclarations(Id: Integer): TIntegerList;
     procedure DiscardLastSTRecord;

     procedure RaiseError(const Message: string; params: array of Const);
     procedure CreateError(const Message: string; params: array of Const);

     procedure Push_SCANNER;
     procedure Pop_SCANNER;

     function IsStringConst(Id: Integer): Boolean;
     procedure SetCompletionTarget(const S: String);
     function GetCodeRec(I: Integer): TCodeRec;
     function GetSymbolRec(Id: Integer): TSymbolRec;
     function CurrNamespaceId: Integer;
     function BuildingAll: Boolean;
     procedure SetTempName(Id: Integer);

     property CurrLevel: Integer read GetCurrLevel;
     property CurrResultId: Integer read GetCurrResultId;
     property CurrSelfId: Integer read GetCurrSelfId;
     property CurrSubId: Integer read GetCurrSubId;
     property NilId: Integer read GetNilId;
     property EmptySetId: Integer read GetEmptySetId;
     property CurrExceptionObjectId: Integer read GetCurrExceptionObjectId;
     property LanguageName: String read GetLanguageName;
     property TryCount: Integer read GetTryCount write SetTryCount;
     property DEBUG_MODE: Boolean read GetDebugMode;
     property RaiseMode: Integer read GetRaiseMode;
     property STCard: Integer read GetStCard;
     property FinSubLabel: Integer read GetFinSubLabel;
     property TrueId: Integer read GetTrueId;
     property FalseId: Integer read GetFalseId;
     property CodeCard: Integer read GetCodeCard;
   end;

   TParserList = class
   private
     L: TList;
     kernel: Pointer;
     function GetParser(I: Integer): TBaseParser;
   public
     constructor Create(i_kernel: Pointer);
     destructor Destroy; override;
     procedure AddParser(P: TBaseParser);
     procedure Clear;
     function Count: Integer;
     function FindParser(const LanguageName: String): TBaseParser;
     function FindParserByFileExtension(const FileExtension: String): TBaseParser;
     property Items[I: Integer]: TBaseParser read GetParser; default;
   end;

implementation

uses
  PAXCOMP_KERNEL, PAXCOMP_STDLIB, PAXCOMP_PCU, PAXCOMP_RTI;

constructor TBaseParser.Create;
begin
  kernel := nil;
  scanner := CreateScanner;
  UpCase := true;
  DECLARE_SWITCH := false;
  EXECUTABLE_SWITCH := 0;
  FIELD_OWNER_ID := 0;
  keywords := TFastStringList.Create;
  levelStack := TIntegerStack.Create;
  levelStack.Push(0);
  try_stack := TIntegerStack.Create;
  SkipLabelStack := TIntegerStack.Create;
  ExitLabelStack := TIntegerStack.Create;
  BreakStack := TEntryStack.Create;
  ContinueStack := TEntryStack.Create;
  WithStack := TIntegerStack.Create;
  SKIP_STATEMENT_TERMINATOR := false;
  ScriptClasses := TIntegerList.Create;
  CompleteBooleanEval := false;
  UnitLookup := true;
  IsConsoleApp := false;
  Alignment := 1;
  PrintKeyword := 'print';
  PrintlnKeyword := 'println';
  BRP := false;
  CallConv := ccREGISTER;
  DeclareCallConv := ccSTDCALL;
end;

destructor TBaseParser.Destroy;
begin
  scanner.Free;
  keywords.Free;
  levelStack.Free;
  SkipLabelStack.Free;
  ExitLabelStack.Free;
  BreakStack.Free;
  ContinueStack.Free;
  WithStack.Free;
  try_stack.Free;
  ScriptClasses.Free;
  inherited;
end;

procedure TBaseParser.Init(i_kernel: Pointer; M: TModule);
begin
  Self.kernel := i_kernel;
  if scanner <> nil then
    scanner.Init(kernel, M.Lines.Text, M.CancelPos);
  levelStack.Clear;
  levelStack.Push(0);
  SkipLabelStack.Clear;
  ExitLabelStack.Clear;
  BreakStack.Clear;
  ContinueStack.Clear;
  WithStack.Clear;
  try_stack.Clear;
  ScriptClasses.Clear;

  CurrModule := M;
  LValueIndex := 0;

  SKIP_STATEMENT_TERMINATOR := false;
  FIELD_OWNER_ID := 0;

  IsConsoleApp := false;
  Alignment := TKernel(kernel).Alignment;

  LinePos := 0;

  LanguageId := GetLanguageId;
  Upcase := GetUpcase;

  TKernel(kernel).Code.PrintKeyword := PrintKeyword;
  TKernel(kernel).Code.PrintlnKeyword := PrintlnKeyword;
end;

procedure TBaseParser.ReadToken;
begin
  scanner.ReadToken;
  CurrToken := scanner.Token;
end;

function TBaseParser.NewField(const FieldName: String; OwnerId: Integer): Integer;
begin
  result := NewTempVar;
  with TKernel(kernel) do
  begin
    SymbolTable[result].Name := FieldName;
    SymbolTable[result].OwnerId := OwnerId;
  end;
end;

procedure TBaseParser.Call_SCANNER;
var
  IntVal: Integer;
  Int64Val: Int64;
  DoubleVal: Double;
  StringVal: String;
  SymbolTable: TSymbolTable;
  I, id: Integer;
  R: TSymbolRec;
  S: String;
  WordVal: Word;
  CurrToken_Text: String;
  cc: Boolean;
begin
  SymbolTable := TKernel(kernel).SymbolTable;

  LinePos := scanner.LinePos;

  scanner.ReadToken;
  CurrToken := scanner.Token;

  CurrToken_Text := CurrToken.Text;

  if Assigned(TKernel(kernel).OnCompilerProgress) then
    TKernel(kernel).OnCompilerProgress(TKernel(kernel).Owner);

  if CurrToken.TokenClass = tcIntegerConst then
  begin
    if CurrToken_Text[1] = '&' then
    begin
      CurrToken_Text := '$' + Copy(CurrToken_Text, 3, Length(CurrToken_Text) - 2);
    end;

    Int64Val := StrToInt64(CurrToken_Text);
    if Abs(Int64Val) > MaxInt then
      CurrToken.Id := SymbolTable.AddInt64Const(Int64Val).Id
    else
      CurrToken.Id := SymbolTable.AddIntegerConst(Int64Val).Id;
  end
  else if CurrToken.TokenClass = tcCharConst then
  begin
    if CurrToken.Tag = 1 then
    begin
      StringVal := Copy(CurrToken_Text, 2, Length(CurrToken_Text) - 1);

      IntVal := StrToInt(StringVal);
      if IntVal <= 255 then
      begin
        StringVal := Chr(IntVal);

        repeat

          if scanner[1] = '#' then
          begin
            ReadToken;
            S := Copy(CurrToken.Text, 2, Length(CurrToken.Text) - 1);
            WordVal := StrToInt(S);
            if WordVal <= 255 then
              StringVal := StringVal + Chr(WordVal)
            else
              RaiseError(errSyntaxError, []);
          end;

          if scanner[1] = '''' then
          begin
            ReadToken;
            S := CurrToken.Text;
            S := Copy(S, 2, Length(S) - 2);

            I := PosCh(CHAR_REMOVE, S);
            while I > 0 do
            begin
              Delete(S, I, 1);
              I := PosCh(CHAR_REMOVE, S);
            end;
            StringVal := StringVal + S;
          end;

        until not CharInSet(scanner[1], ['#', '''']);

        {$IFDEF UNIC}
        if Length(StringVal) > 1 then
          CurrToken.Id := SymbolTable.AddPWideCharConst(StringVal).Id
        else
          CurrToken.Id := SymbolTable.AddWideCharConst(IntVal).Id;
        {$ELSE}
        if Length(StringVal) > 1 then
          CurrToken.Id := SymbolTable.AddPAnsiCharConst(StringVal).Id
        else
          CurrToken.Id := SymbolTable.AddAnsiCharConst(AnsiChar(Chr(IntVal))).Id;
        {$ENDIF}
      end
      else
        CurrToken.Id := SymbolTable.AddWideCharConst(IntVal).Id;
      CurrToken.Tag := 0;
    end
    else
    begin
      StringVal := CurrToken_Text; // length = 3
      {$IFDEF UNIC}
        CurrToken.Id := SymbolTable.AddWideCharConst(Ord(StringVal[2])).Id;
      {$ELSE}
        CurrToken.Id := SymbolTable.AddAnsiCharConst(AnsiChar(StringVal[2])).Id;
      {$ENDIF}
    end;
  end
  else if CurrToken.TokenClass = tcPCharConst then
  begin
    StringVal := CurrToken_Text;
    StringVal := Copy(StringVal, 2, Length(StringVal) - 2);

    I := PosCh(CHAR_REMOVE, StringVal);
    while I > 0 do
    begin
      Delete(StringVal, I, 1);
      I := PosCh(CHAR_REMOVE, StringVal);
    end;

    repeat

      if scanner[1] = '#' then
      begin
        ReadToken;
        S := Copy(CurrToken.Text, 2, Length(CurrToken.Text) - 1);
        WordVal := StrToInt(S);
        if WordVal <= 255 then
          StringVal := StringVal + Chr(WordVal)
        else
          RaiseError(errSyntaxError, []);
      end;

      if scanner[1] = '''' then
      begin
        ReadToken;
        S := CurrToken.Text;
        S := Copy(S, 2, Length(S) - 2);

        I := PosCh(CHAR_REMOVE, S);
        while I > 0 do
        begin
          Delete(S, I, 1);
          I := PosCh(CHAR_REMOVE, S);
        end;
        StringVal := StringVal + S;
      end;

    until not CharInSet(scanner[1], ['#', '''']);

    if StringVal = '' then
      CurrToken.Id := SymbolTable.EmptyStringId
    else
    begin
      {$IFDEF UNIC}
        CurrToken.Id := SymbolTable.AddPWideCharConst(StringVal).Id
      {$ELSE}
        CurrToken.Id := SymbolTable.AddPAnsiCharConst(StringVal).Id;
      {$ENDIF}
    end;

    CurrToken.Tag := 0;
  end
  else if CurrToken.TokenClass = tcDoubleConst then
  begin
    StringVal := CurrToken_Text;
    id := PosCh('.', StringVal);
    if id > 0 then
      StringVal[id] := DecimalSeparator;
    DoubleVal := StrToFloat(StringVal);
    CurrToken.Id := SymbolTable.AddDoubleConst(DoubleVal).Id;
  end
  else if CurrToken.TokenClass = tcIdentifier then
  begin
    if IsCurrText('true') then
    begin
      CurrToken.TokenClass := tcBooleanConst;
      CurrToken.Id := SymbolTable.TrueId;
      Exit;
    end
    else if IsCurrText('false') then
    begin
      CurrToken.TokenClass := tcBooleanConst;
      CurrToken.Id := SymbolTable.FalseId;
      Exit;
    end;

    if IsKeyword(CurrToken_Text) then
    begin
      CurrToken.Id := 0;
      CurrToken.TokenClass := tcKeyword;
      Exit;
    end;

    if FIELD_OWNER_ID > 0 then
    begin
      with SymbolTable.AddRecord do
      begin
        CurrToken.Id := Id;
        Name := CurrToken_Text;
        Kind := KindVAR;
        Level := CurrLevel;
        OwnerId := FIELD_OWNER_ID;
      end;
      FIELD_OWNER_ID := 0;
      Exit;
    end;

    if DECLARE_SWITCH then
    begin
      id := LookUp(CurrToken_Text, CurrLevel);
      if id <> 0 then
      begin
        if SymbolTable[id].Kind in [kindNAMESPACE] then
        begin
          CurrToken.Id := Id;
          Exit;
        end
        else
        begin
          if SymbolTable[Id].IsForward then
          begin

            if (SymbolTable[Id].Kind = KindTYPE) and
               (SymbolTable[Id].FinalTypeId = typeCLASS) then
            begin
              CurrToken.Id := id;
              SetForward(Id, false);
              SymbolTable[Id].Position := CurrToken.Position - 1;
              Exit;
            end;

            CurrToken.Id := NewTempVar;
            SetName(CurrToken.Id, GetName(Id));
            SymbolTable[Id].Position := CurrToken.Position - 1;
            Exit;
          end
          else if LanguageId = JS_LANGUAGE then
          begin
            // no problem
          end
          else
          begin
            if not (GetKind(id) in [kindSUB, KindCONSTRUCTOR, KindDESTRUCTOR]) then
              if not TKernel(kernel).SymbolTable[id].Host then
                if Id > GlobalSymbolTable.Card then
                begin
                  cc := StrEql(CurrToken_Text, 'register') or
                        StrEql(CurrToken_Text, 'pascal') or
                        StrEql(CurrToken_Text, 'stdcall') or
                        StrEql(CurrToken_Text, 'cdecl') or
                        StrEql(CurrToken_Text, 'msfastcall') or
                        StrEql(CurrToken_Text, 'safecall');
                  if cc then
                    SymbolTable[id].Kind := KindNONE;

                  if not (InterfaceOnly or cc) then
                    RaiseError(errRedeclaredIdentifier, [CurrToken_Text]);
                end;
          end;
        end;
      end;

      with SymbolTable.AddRecord do
      begin
        CurrToken.Id := Id;
        Name := CurrToken_Text;
        Kind := KindVAR;
        Level := CurrLevel;

        Position := CurrToken.Position - 1;
      end;
    end
    else
    begin
      CurrToken.Id := 0;

      if WithStack.Count = 0 then
        CurrToken.Id := LookUps(CurrToken_Text, levelStack);

      if CurrToken.Id = 0 then
      begin
        if LanguageId = BASIC_LANGUAGE then
          if IsNextText('.') then
          begin
            SkipWhenNotFound := true;
            try
              AddModuleFromFile(CurrToken_Text, CurrToken.Id, false);
            finally
              SkipWhenNotFound := false;
            end;
          end;

        StringVal := CurrToken_Text;

        R := SymbolTable.AddRecord;
        R.Name := StringVal;
        R.Kind := KindNONE;
        R.Level := CurrLevel;
        CurrToken.Id := R.Id;
        Gen(OP_EVAL, 0, 0, R.Id);
        R.Position := CurrToken.Position - 1;
      end;
    end;
  end;
end;

procedure TBaseParser.SetPosition(Id, Position: Integer);
begin
  TKernel(kernel).SymbolTable[Id].Position := Position;
end;

procedure TBaseParser.SetVarCount(Id, value: Integer);
begin
  TKernel(kernel).SymbolTable[Id].VarCount := value;
end;

function TBaseParser.Parse_Ident: Integer;
begin
  if CurrToken.TokenClass <> tcIdentifier then
    RaiseError(errIdentifierExpected, [CurrToken.Text]);
  result := CurrToken.Id;
  Call_SCANNER;
end;

function TBaseParser.Parse_EnumIdent: Integer;
var
  TypeID: Integer;
begin
  TypeID := LevelStack.Top;

  result := Parse_Ident;
  SetKind(result, KindCONST);
  SetType(result, TypeID);
  SetOwnerId(result, TypeID);
end;

function TBaseParser.Parse_FormalParameter: Integer;
begin
  if CurrToken.TokenClass <> tcIdentifier then
    RaiseError(errIdentifierExpected, [CurrToken.Text]);
  result := CurrToken.Id;

  TKernel(kernel).SymbolTable[result].Param := true;

  Call_SCANNER;
end;

function TBaseParser.Parse_CharLiteral: Integer;
begin
  result := CurrToken.Id;
  Call_SCANNER;
end;

function TBaseParser.Parse_PCharLiteral: Integer;
begin
  result := CurrToken.Id;
  if CurrToken.TokenClass <> tcPCharConst then
    RaiseError(errPCharLiteralExpected, []);
  Call_SCANNER;
end;

function TBaseParser.Parse_BooleanLiteral: Integer;
begin
  result := CurrToken.Id;
  Call_SCANNER;
end;

function TBaseParser.Parse_IntegerLiteral: Integer;
begin
  result := CurrToken.Id;
  Call_SCANNER;
end;

function TBaseParser.Parse_DoubleLiteral: Integer;
begin
  result := CurrToken.Id;
  Call_SCANNER;
end;

function TBaseParser.BinOp(Op, Arg1, Arg2: Integer): Integer;
begin
	result := NewTempVar;
  Gen(Op, Arg1, Arg2, result);
end;

function TBaseParser.UnaryOp(Op, Arg1: Integer): Integer;
begin
  result := NewTempVar();
  Gen(Op, Arg1, 0, result);
end;

function TBaseParser.NewVar(const VarName: String): Integer;
var
  R: TSymbolRec;
begin
  R := TKernel(kernel).SymbolTable.AddRecord;
  R.Kind := KindVAR;
  R.Level := CurrLevel;
  R.Name := VarName;
  result := R.Id;
end;

function TBaseParser.NewTempVar: Integer;
var
  R: TSymbolRec;
begin
  R := TKernel(kernel).SymbolTable.AddRecord;
  R.Kind := KindVAR;
  R.Level := CurrLevel;
  result := R.Id;
end;

function TBaseParser.NewTempVar(TypeId: Integer): Integer;
begin
  result := NewTempVar;
  SetType(result, typeID);
end;

function TBaseParser.NewConst(TypeID: Integer; const Value: Variant): Integer;
var
  R: TSymbolRec;
begin
  case TypeID of
    typeBOOLEAN: result := TKernel(kernel).SymbolTable.AddBooleanConst(Value).Id;
    typeINTEGER: result := TKernel(kernel).SymbolTable.AddIntegerConst(Value).Id;
    typeDOUBLE: result := TKernel(kernel).SymbolTable.AddDoubleConst(Value).Id;
    typeANSISTRING: result := TKernel(kernel).SymbolTable.AddPAnsiCharConst(AnsiString(Value)).Id;
    typeUNICSTRING: result := TKernel(kernel).SymbolTable.AddPWideCharConst(Value).Id;
  else
    begin
      R := TKernel(kernel).SymbolTable.AddRecord;
      R.Kind := KindCONST;
      R.TypeID := TypeID;
      R.Level := CurrLevel;
      R.Value := Value;
      result := R.Id;
    end;
  end;
end;

function TBaseParser.NewConst(TypeID: Integer): Integer;
begin
  with TKernel(kernel).SymbolTable do
  begin
    result := AddRecord.Id;
    with Records[result] do
    begin
      Kind := kindCONST;
      Level := CurrLevel;
      TypeID := TypeID;
    end;
  end;
end;

function TBaseParser.NewTypeAlias: Integer;
var
  R: TSymbolRec;
begin
  R := TKernel(kernel).SymbolTable.AddRecord;
  R.Kind := KindTYPE;
  R.Level := CurrLevel;
  R.TypeID := typeALIAS;
  result := R.Id;
end;

function TBaseParser.NewLabel: Integer;
begin
  result := TKernel(kernel).SymbolTable.AddLabel.Id;
end;

function TBaseParser.Gen(Op, Arg1, Arg2, Res: Integer): TCodeRec;
var
  L, I: Integer;
  B: Boolean;
  Code: TCode;
  SymbolTable: TSymbolTable;
begin
  Code := TKernel(kernel).Code;
  SymbolTable := TKernel(kernel).SymbolTable;

  Code.N := Code.Card;

  if Op = OP_STMT then
  begin
    if Code[Code.Card].Op = OP_EVAL then
    begin
      result := Code[Code.Card];
      Exit;
    end;
  end;

  if OP = OP_COND_RAISE then
  begin
    Arg1 := FinSubLabel;
    if Res = 0 then
      Res := NewTempVar(typeBOOLEAN);
  end;

  result := Code.Add(Op, Arg1, Arg2, Res, Upcase,
                     LanguageId, CurrModule.ModuleNumber,
                     LinePos);

  if Op = OP_ELEM then
  begin
    SymbolTable[Res].Kind := KindVAR;
    SymbolTable[Res].OwnerId := Arg1;
  end
  else if Op = OP_BEGIN_MODULE then
  begin
    CurrModule.S1 := SymbolTable.Card + 1;
    CurrModule.P1 := Code.Card;
  end
  else if Op = OP_END_INTERFACE_SECTION then
  begin
    CurrModule.S2 := SymbolTable.Card;
    CurrModule.P2 := Code.Card;
  end
  else if Op = OP_END_MODULE then
  begin
    CurrModule.S3 := SymbolTable.Card;
    CurrModule.P3 := Code.Card;
  end
  else if OP = OP_EVAL_INHERITED then
    Gen(OP_NOP, SkipLabelStack.Top, 0, 0)
  else if OP = OP_GET_ENUMERATOR then
  begin
    Gen(OP_NOP, 0, 0, 0);
    Gen(OP_NOP, 0, 0, 0);
    Gen(OP_NOP, 0, 0, 0);
  end
  else if OP = OP_CURRENT then
  begin
    Gen(OP_NOP, 0, 0, 0);
    Gen(OP_NOP, 0, 0, 0);
    Gen(OP_NOP, 0, 0, 0);
  end
  else if OP = OP_MOVE_NEXT then
  begin
    Gen(OP_NOP, 0, 0, 0);
    Gen(OP_NOP, 0, 0, 0);
    Gen(OP_NOP, 0, 0, 0);
  end
  else if Op = OP_SEPARATOR then
  begin
    if (not DECLARE_SWITCH) and (EXECUTABLE_SWITCH > 0) then
    begin
      b := false;
      for I:=Code.Card downto 1 do
        if Code[I].Op = OP_SET_CODE_LINE then
          break
        else if Code[I].Op = OP_CALL then
          break
        else if Code[I].Op = OP_PUSH then
        begin
          b := true;
          break;
        end;

      Gen(OP_SET_CODE_LINE, 0, 0, 0);
      if DEBUG_MODE then if not b then
      begin
        L := NewLabel;
        Gen(OP_CHECK_PAUSE, L, 0, 0);
        SetLabelHere(L);
      end;
    end;
  end;
end;

procedure TBaseParser.RaiseError(const Message: string; params: array of Const);
begin
  TKernel(kernel).Code.N := TKernel(kernel).Code.Card;
  TKernel(kernel).RaiseError(Message, params);
end;

procedure TBaseParser.CreateError(const Message: string; params: array of Const);
begin
  TKernel(kernel).CreateError(Message, params);
end;

procedure TBaseParser.AddKeyword(const S: String);
begin
  keywords.Add(S);
end;

function TBaseParser.IsKeyword(const S: String): Boolean;
begin
  result := keywords.IndexOfEx(S, Upcase) >= 0;
end;

function TBaseParser.IsCurrText(const S: String): Boolean;
begin
  if UpCase then
    result := StrEql(CurrToken.Text, S)
  else
    result := CurrToken.Text = S;
end;

function TBaseParser.IsNextText(const S: String): Boolean;
begin
  if scanner.ScannerStack.Count > 0 then
  begin
    result := false;
    Exit;
  end;

  scanner.LookForward := true;

  Push_SCANNER;
  ReadToken;
  result := IsCurrText(S);
  Pop_SCANNER;

  scanner.LookForward := false;
end;

function TBaseParser.IsNext2Text(const S: String): Boolean;
begin
  if scanner.ScannerStack.Count > 0 then
  begin
    result := false;
    Exit;
  end;

  scanner.LookForward := true;

  Push_SCANNER;
  ReadToken;
  ReadToken;
  result := IsCurrText(S);
  Pop_SCANNER;

  scanner.LookForward := false;
end;

function TBaseParser.GetNextText: String;
begin
  if scanner.ScannerStack.Count > 0 then
  begin
    result := '';
    Exit;
  end;

  scanner.LookForward := true;

  Push_SCANNER;
  ReadToken;
  result := CurrToken.Text;
  Pop_SCANNER;

  scanner.LookForward := false;
end;

procedure TBaseParser.Match(const S: String);
begin
  if IsCurrText(S) then
    Call_SCANNER
  else
  begin
    LinePos := scanner.LinePos;
    Gen(OP_NOP, 0, 0, 0);
    RaiseError(errTokenExpected, [S, CurrToken.Text]);
  end;
end;

function TBaseParser.NotMatch(const S: String): Boolean;
begin
  if not IsCurrText(S) then
    result := true
  else
  begin
    result := false;
    Call_SCANNER;
  end;
end;

function TBaseParser.IsEOF: Boolean;
begin
  result := scanner.IsEOF;
end;

function TBaseParser.IsNewLine: Boolean;
begin
  result := scanner.IsNewLine;
end;

function TBaseParser.GetType(Id: Integer): Integer;
begin
  result := TKernel(kernel).SymbolTable[Id].TypeID;
end;

procedure TBaseParser.SetType(Id: Integer; TypeID: Integer);
begin
  TKernel(kernel).SymbolTable[Id].TypeID := TypeID;
end;

procedure TBaseParser.SetValue(Id: Integer; const Value: Variant);
begin
  TKernel(kernel).SymbolTable[Id].Value := Value;
end;

function TBaseParser.GetLevel(Id: Integer): Integer;
begin
  result := TKernel(kernel).SymbolTable[Id].Level;
end;

procedure TBaseParser.SetLevel(Id: Integer; Level: Integer);
begin
  TKernel(kernel).SymbolTable[Id].Level := Level;
end;

procedure TBaseParser.SetTypedConst(Id: Integer);
begin
  TKernel(kernel).SymbolTable[Id].TypedConst := true;
  SetKind(Id, KindVAR);
end;

procedure TBaseParser.SetKind(Id: Integer; Kind: Integer);
var
  S: TSymbolRec;
begin
  S := TKernel(kernel).SymbolTable[Id];
  S.Kind := Kind;
  if Kind = KindNONE then
  begin
    S.Param := false;
    S.Register := 0;
    S.TypeId := 0;
  end;

end;

function TBaseParser.GetKind(Id: Integer): Integer;
begin
  result := TKernel(kernel).SymbolTable[Id].Kind;
end;

function TBaseParser.GetFullName(Id: Integer): String;
begin
  result := TKernel(kernel).SymbolTable[Id].FullName;
end;

function TBaseParser.GetName(Id: Integer): String;
begin
  result := TKernel(kernel).SymbolTable[Id].Name;
end;

procedure TBaseParser.SetName(Id: Integer; const S: String);
begin
  TKernel(kernel).SymbolTable[Id].Name := S;
end;

function TBaseParser.GetCount(Id: Integer): Integer;
begin
  result := TKernel(kernel).SymbolTable[Id].Count;
end;

procedure TBaseParser.SetCount(Id: Integer; value: Integer);
begin
  TKernel(kernel).SymbolTable[Id].Count := value;
end;

function TBaseParser.GetParamId(SubId, J: Integer): Integer;
begin
  result := TKernel(kernel).SymbolTable.GetParamId(SubId, J);
end;

procedure TBaseParser.SetPatternId(Id: Integer; PatternId: Integer);
begin
  TKernel(kernel).SymbolTable[Id].PatternId := PatternId;
end;

procedure TBaseParser.SetParam(Id: Integer; value: boolean);
begin
  TKernel(kernel).SymbolTable[Id].Param := value;
end;

procedure TBaseParser.SetOwnerId(Id: Integer; OwnerId: Integer);
begin
  TKernel(kernel).SymbolTable[Id].OwnerId := OwnerId;
end;

procedure TBaseParser.SetByRef(Id: Integer);
begin
  TKernel(kernel).SymbolTable[Id].ByRef := true;
end;

procedure TBaseParser.SetIsConst(Id: Integer);
begin
  TKernel(kernel).SymbolTable[Id].IsConst := true;
end;

procedure TBaseParser.SetOptional(Id: Integer);
begin
  TKernel(kernel).SymbolTable[Id].Optional := true;
end;

procedure TBaseParser.SetPacked(Id: Integer);
begin
  SetAlignment(Id, 1);
end;

procedure TBaseParser.SetCallConvention(Id: Integer; value: Integer);
begin
  TKernel(kernel).SymbolTable[Id].CallConv := value;
end;

procedure TBaseParser.SetOverloaded(SubId: Integer);
var
  Lst: TIntegerList;
  SymbolTable: TSymbolTable;
begin
  SymbolTable := TKernel(kernel).SymbolTable;
  lst := SymbolTable.LookupAll(SymbolTable[SubId].Name, SymbolTable[SubId].Level, Upcase);
  try
    TKernel(kernel).SymbolTable[SubId].OverCount := Lst.Count;
  finally
    Lst.Free;
  end;
end;

procedure TBaseParser.SetCallMode(Id: Integer; value: Integer);
var
  S: String;
begin
  S := TKernel(kernel).SymbolTable[Id].Name;
  if StrEql(S, 'AfterConstruction') or
     StrEql(S, 'BeforeDestruction') or
     StrEql(S, 'SafeCallexception') or
     StrEql(S, 'Dispatch') or
     StrEql(S, 'DefaultHandler') or
     StrEql(S, 'NewInstance') or
     StrEql(S, 'FreeInstance') then
     value := cmNONE;
  TKernel(kernel).SymbolTable[Id].CallMode := value;
end;

procedure TBaseParser.SetLabelHere(Id: Integer;
                                   Arg2: Integer = 0;
                                   Res: Integer = 0);
begin
  Gen(OP_LABEL, Id, Arg2, Res);
end;

function TBaseParser.GetFinSubLabel: Integer;
begin
  if ExitLabelStack.Count = 0 then
    result := 0
  else
    result := ExitLabelStack.Top;
end;

function TBaseParser.GetCurrLevel: Integer;
begin
  if levelStack.Count = 0 then
    result := 0
  else
    result := levelStack.Top;
end;

function TBaseParser.GetCurrSubId: Integer;
begin
  if levelStack.Count = 0 then
    result := 0
  else
    result := levelStack.Top;
end;

function TBaseParser.GetCurrResultId: Integer;
begin
  result := levelStack.Top;
  while not (GetKind(result) in KindSUBS) do
  begin
    levelStack.Pop;
    result := levelStack.Top;
  end;
  result := TKernel(kernel).SymbolTable.GetResultId(result);
end;

function TBaseParser.GetCurrSelfId: Integer;
begin
  result := levelStack.Top;
  result := TKernel(kernel).SymbolTable.GetSelfId(result);
end;

function TBaseParser.GetNilId: Integer;
begin
  result := TKernel(kernel).SymbolTable.NilId;
end;

function TBaseParser.GetCurrExceptionObjectId: Integer;
begin
  result := TKernel(kernel).SymbolTable.CurrExceptionObjectId;
end;

function TBaseParser.GetEmptySetId: Integer;
begin
  result := TKernel(kernel).SymbolTable.EmptySetId;
end;

procedure TBaseParser.BeginSub(SubId: Integer);
var
  SelfId, L: Integer;
begin
  SetKind(SubID, KindSUB);
  SetCallConvention(SubID, CallConv);

  levelStack.Push(SubId);

  NewVar('result');
  SelfId := NewVar('');
  SetKind(SelfId, KindNONE);

  L := NewLabel;
  Gen(OP_GO, L, 0, 0);
  SkipLabelStack.Push(L);

	Gen(OP_BEGIN_SUB, SubId, 0, 0);
  L := NewLabel;
  SkipLabelStack.Push(L);

  if TKernel(kernel).SymbolTable[SubId].IsNestedSub then
    SetCallConvention(SubID, ccSTDCALL);

  L := NewLabel;
  ExitLabelStack.Push(L);
end;

procedure TBaseParser.RemoveSub;
var
  Code: TCode;
  I: Integer;
begin
  Code := TKernel(kernel).Code;

  I := Code.Card;
  repeat
    if Code[I].Op = OP_EVAL then
    begin
      Dec(I);
      continue;
    end;

    if Code[I].Op = OP_ASSIGN_TYPE then
      Dec(I)
    else if Code[I].Op = OP_ASSIGN_CONST then
      Dec(I)
    else if Code[I].Op = OP_GO then
    begin
      Code[I].Op := OP_NOP;
      Exit;
    end
    else
    begin
      Code[I].Op := OP_NOP;
      Dec(I);
    end;

  until false;
end;

procedure TBaseParser.BeginClassConstructor(SubId, ClassTypeId: Integer);
var
  L: Integer;
  ResId, SelfId: Integer;
begin
  SetKind(SubID, KindCONSTRUCTOR);
  SetCallConvention(SubID, ccREGISTER);

  levelStack.Push(SubId);

  ResId  := NewVar(''); // result
  SelfId := NewVar('Self');

  SetKind(ResId, KindNONE);
  SetLevel(SubId, ClassTypeId);
  TKernel(kernel).SymbolTable[SelfId].Param := true;

  Gen(OP_ASSIGN_TYPE, SubId,  ClassTypeId, 0);
  Gen(OP_ASSIGN_TYPE, SelfId, ClassTypeId, 0);

  L := NewLabel;
  Gen(OP_GO, L, 0, 0);
  SkipLabelStack.Push(L);

	Gen(OP_BEGIN_SUB, SubId, 0, 0);
  L := NewLabel;
  SkipLabelStack.Push(L);

  L := NewLabel;
  ExitLabelStack.Push(L);
end;

procedure TBaseParser.BeginClassDestructor(SubId, ClassTypeId: Integer);
var
  L: Integer;
  ResId, SelfId: Integer;
begin
  SetKind(SubID, KindDESTRUCTOR);
  SetCallConvention(SubID, CallConv);

  levelStack.Push(SubId);

  ResId  := NewVar(''); // result
  SelfId := NewVar('Self');

  SetKind(ResId, KindNONE);
  SetLevel(SubId, ClassTypeId);
  TKernel(kernel).SymbolTable[SelfId].Param := true;

  Gen(OP_ASSIGN_TYPE, SubId,  ClassTypeId, 0);
  Gen(OP_ASSIGN_TYPE, SelfId, ClassTypeId, 0);

  L := NewLabel;
  Gen(OP_GO, L, 0, 0);
  SkipLabelStack.Push(L);

	Gen(OP_BEGIN_SUB, SubId, 0, 0);
  L := NewLabel;
  SkipLabelStack.Push(L);

  L := NewLabel;
  ExitLabelStack.Push(L);
end;

procedure TBaseParser.BeginClassMethod(SubId, ClassTypeId: Integer;
                                       HasResult: Boolean;
                                       IsSharedMethod: Boolean);
var
  L: Integer;
  ResId, SelfId: Integer;
begin
  SetKind(SubID, KindSUB);
  SetCallConvention(SubID, CallConv);

  levelStack.Push(SubId);

  if HasResult then
    NewVar('result')
  else
  begin
    ResId := NewVar('');
    SetKind(ResId, KindNONE);
  end;

  SelfId := NewVar('Self');

  SetLevel(SubId, ClassTypeId);

  TKernel(kernel).SymbolTable[SelfId].Param := true;
  TKernel(kernel).SymbolTable[SubId].IsSharedMethod := IsSharedMethod;

  SetType(SubId, typeVOID);
  Gen(OP_ASSIGN_TYPE, SelfId, ClassTypeId, 0);

  L := NewLabel;
  Gen(OP_GO, L, 0, 0);
  SkipLabelStack.Push(L);

	Gen(OP_BEGIN_SUB, SubId, 0, 0);
  L := NewLabel;
  SkipLabelStack.Push(L);

  L := NewLabel;
  ExitLabelStack.Push(L);
end;

procedure TBaseParser.BeginStructureConstructor(SubId, StructTypeId: Integer);
begin
  BeginStructureMethod(SubId, StructTypeId, false, false);
  SetKind(SubId, kindCONSTRUCTOR);
  SetCallConvention(SubID, ccREGISTER);
end;

procedure TBaseParser.BeginStructureDestructor(SubId, StructTypeId: Integer);
begin
  BeginStructureMethod(SubId, StructTypeId, false, false);
  SetKind(SubId, kindDESTRUCTOR);
  SetCallConvention(SubID, ccREGISTER);
end;

procedure TBaseParser.BeginStructureMethod(SubId, StructTypeId: Integer;
                                           HasResult: Boolean;
                                           IsSharedMethod: Boolean);
var
  L: Integer;
  ResId, SelfId: Integer;
begin
  SetKind(SubID, KindSUB);
  SetCallConvention(SubID, CallConv);

  levelStack.Push(SubId);

  if HasResult then
    NewVar('result')
  else
  begin
    ResId := NewVar('');
    SetKind(ResId, KindNONE);
  end;

  SelfId := NewVar('Self');

  SetLevel(SubId, StructTypeId);

  TKernel(kernel).SymbolTable[SelfId].Param := true;
  TKernel(kernel).SymbolTable[SubId].IsSharedMethod := IsSharedMethod;

  TKernel(kernel).SymbolTable[SelfId].ByRef := true;

  SetType(SubId, typeVOID);
  Gen(OP_ASSIGN_TYPE, SelfId, StructTypeId, 0);

  L := NewLabel;
  Gen(OP_GO, L, 0, 0);
  SkipLabelStack.Push(L);

	Gen(OP_BEGIN_SUB, SubId, 0, 0);
  L := NewLabel;
  SkipLabelStack.Push(L);

  L := NewLabel;
  ExitLabelStack.Push(L);
end;

procedure TBaseParser.BeginInterfaceMethod(SubId, IntfTypeId: Integer;
                                           HasResult: Boolean);
begin
  BeginClassMethod(SubId, IntfTypeId, HasResult, false);
  SetVisibility(SubId, cvPublic);
end;

procedure TBaseParser.CheckAbstract(SubId: Integer);
var
  I: Integer;
  Code: TCode;
  S: String;
begin
  Code := TKernel(kernel).Code;
  S := GetFullName(SubId);
  for I:=1 to Code.Card do
    if Code[I].Op = OP_ERR_ABSTRACT then
      if StrEql(GetFullName(Code[I].Res), S) then
      begin
        CreateError(errNoDefinitionForAbstractMethodAllowed, [S]);
        break;
      end;
end;

procedure TBaseParser.InitSub(var SubId: Integer);
begin
  SetLabelHere(SubId);
	Gen(OP_INIT_SUB, SubId, 0, 0);
  // reserved for prologue
  Gen(OP_NOP, 0, 0, 0);
end;

procedure TBaseParser.EndSub(SubId: Integer);
var
  L: Integer;
  I: Integer;
  Code: TCode;
  R: TCodeRec;
begin
  Code := TKernel(kernel).Code;

  L := SkipLabelStack.Top;
  SetLabelHere(L);
  SkipLabelStack.Pop;

  Gen(OP_EPILOGUE_SUB,  SubId, 0, 0);

  // reserved for epilogue
  Gen(OP_NOP, 0, 0, 0);
  Gen(OP_NOP, 0, 0, 0);

  for I:=Code.Card downto 1 do
  begin
    R := Code[I];
    if (R.Op = OP_BEGIN_SUB) and (R.Arg1 = SubId) then
      break;
    if (R.Op = OP_DECLARE_LOCAL_VAR) and (R.Arg1 = SubId) then
    begin
      if GetKind(R.Arg2) = KindVAR then
        if not TKernel(kernel).SymbolTable[R.Arg2].Param then
          Gen(OP_DESTROY_LOCAL_VAR, R.Arg2, 0, 0);
    end;
  end;

  // reserved for epilogue
	Gen(OP_NOP, 0, 0, 0);
	Gen(OP_NOP, 0, 0, 0);
	Gen(OP_NOP, 0, 0, 0);
	Gen(OP_NOP, 0, 0, 0);

  levelStack.Pop;
  Gen(OP_END_SUB, SubId, 0, 0);

  L := ExitLabelStack.Top;
  SetLabelHere(L);
  ExitLabelStack.Pop;
  Gen(OP_FIN_SUB, SubId, 0, 0);

  L := SkipLabelStack.Top;
  SetLabelHere(L);
  SkipLabelStack.Pop;
end;

procedure TBaseParser.BeginProperty(PropId, ClassTypeId: Integer);
begin
  SetKind(PropID, KindPROP);
  levelStack.Push(PropId);
  SetLevel(PropId, ClassTypeId);
end;

procedure TBaseParser.EndProperty(PropId: Integer);
begin
  levelStack.Pop;
end;

procedure TBaseParser.BeginNamespace(Id: Integer; Jump: Boolean = true);
var
  L: Integer;
  DeclaredInSub: Boolean;
begin
  DeclaredInSub := GetKind(levelStack.Top) = KindSUB;

  SetKind(Id, KindNAMESPACE);
  levelStack.Push(Id);

  if Jump then if not DeclaredInSub then
  begin
    L := NewLabel;
    Gen(OP_GO, L, 0, 0);
    SkipLabelStack.Push(L);
  end;

  if InterfaceOnly then
    Gen(OP_BEGIN_NAMESPACE, Id, 0, 0);
  Gen(OP_BEGIN_USING, Id, 0, 0);
end;

procedure TBaseParser.EndNamespace(Id: Integer; Jump: Boolean = true);
var
  L: Integer;
  DeclaredInSub: Boolean;
begin
  if InterfaceOnly then
    Gen(OP_END_NAMESPACE, Id, 0, 0);

  levelStack.Pop;

  DeclaredInSub := GetKind(levelStack.Top) = KindSUB;

  if Jump then if not DeclaredInSub then
  begin
    L := SkipLabelStack.Top;
    SetLabelHere(L);
    SkipLabelStack.Pop;
  end;

  Gen(OP_END_USING, Id, 0, 0);
end;

procedure TBaseParser.BeginRecordType(TypeId: Integer);
var
  L: Integer;
  DeclaredInSub: Boolean;
begin
  DeclaredInSub := GetKind(levelStack.Top) = KindSUB;

  SetKind(TypeId, KindTYPE);
  SetType(TypeId, typeRECORD);
  levelStack.Push(TypeId);

  SetAlignment(TypeId, Alignment);

  if not DeclaredInSub then
  begin
    L := NewLabel;
    Gen(OP_GO, L, 0, 0);
    SkipLabelStack.Push(L);
  end;

  Gen(OP_BEGIN_RECORD_TYPE, TypeId, 0, 0);
  if GetName(TypeId) = '' then
  begin
    SetName(TypeId, 'RecordType_' + IntToStr(TypeId));
    Gen(OP_ADD_TYPEINFO, TypeId, 0, 0);
  end;
end;

procedure TBaseParser.EndRecordType(TypeId: Integer);
var
  L: Integer;
  DeclaredInSub: Boolean;
begin
  Gen(OP_END_RECORD_TYPE, TypeId, 0, 0);

  levelStack.Pop;

  DeclaredInSub := GetKind(levelStack.Top) = KindSUB;

  if not DeclaredInSub then
  begin
    L := SkipLabelStack.Top;
    SetLabelHere(L);
    SkipLabelStack.Pop;
  end;
end;

procedure TBaseParser.BeginClassType(TypeId: Integer);
var
  L: Integer;
  DeclaredInSub: Boolean;
  R: TSymbolRec;
  ClassRefTypeId: Integer;
  S, FullName: String;
  C: TClass;
begin
  if ScriptClasses.IndexOf(TypeId) = -1 then
    ScriptClasses.Add(TypeId);

  S := GetName(TypeId);
  FullName := GetSymbolRec(TypeId).FullName;

  DeclaredInSub := GetKind(levelStack.Top) = KindSUB;

  SetAlignment(TypeId, Alignment);

  SetKind(TypeId, KindTYPE);
  SetType(TypeId, typeCLASS);

  TKernel(kernel).SymbolTable[TypeId].AncestorId := H_TObject;

  R := TKernel(kernel).SymbolTable.AddClassRefVar(0);

  if TKernel(kernel).ClassFactory.LookupFullName(FullName) = nil then
  begin
    C := TKernel(kernel).ClassFactory.CreatePaxClass(FullName, TObject.InstanceSize, TObject);
    R.Value := Integer(C);
    TKernel(kernel).SymbolTable[TypeId].PClass := C;
  end;

  ClassRefTypeId := TKernel(kernel).SymbolTable.RegisterClassReferenceType(0, '', TypeId);
  TKernel(kernel).SymbolTable[ClassRefTypeId].Host := false;
  R.TypeID := ClassRefTypeId;

  levelStack.Push(TypeId);

  if not DeclaredInSub then
  begin
    L := NewLabel;
    Gen(OP_GO, L, 0, 0);
    SkipLabelStack.Push(L);
  end;

  Gen(OP_BEGIN_CLASS_TYPE, TypeId, 0, 0);
end;

procedure TBaseParser.EndClassType(TypeId: Integer; IsForward: Boolean = false);
var
  L: Integer;
  DeclaredInSub: Boolean;
  Code: TCode;
begin
  if IsForward then
  begin
    Code := TKernel(kernel).Code;
    L := Code.Card;
    while Code[L].Op <> OP_BEGIN_CLASS_TYPE do Dec(L);
    Code[L].Op := OP_NOP;
  end
  else
    Gen(OP_END_CLASS_TYPE, TypeId, 0, 0);

  levelStack.Pop;

  DeclaredInSub := GetKind(levelStack.Top) = KindSUB;

  if not DeclaredInSub then
  begin
    L := SkipLabelStack.Top;
    SetLabelHere(L);
    SkipLabelStack.Pop;
  end;
end;

procedure TBaseParser.BeginInterfaceType(TypeId: Integer);
var
  L: Integer;
  DeclaredInSub: Boolean;
begin
  DeclaredInSub := GetKind(levelStack.Top) = KindSUB;

  SetAlignment(TypeId, Alignment);

  SetKind(TypeId, KindTYPE);
  SetType(TypeId, typeINTERFACE);

  TKernel(kernel).SymbolTable.AddDoubleConst(0);
  TKernel(kernel).SymbolTable.AddDoubleConst(0);

  levelStack.Push(TypeId);

  if not DeclaredInSub then
  begin
    L := NewLabel;
    Gen(OP_GO, L, 0, 0);
    SkipLabelStack.Push(L);
  end;

  Gen(OP_BEGIN_INTERFACE_TYPE, TypeId, 0, 0);
  if GetName(TypeId) = '' then
  begin
    SetName(TypeId, 'InterfaceType_' + IntToStr(TypeId));
    Gen(OP_ADD_TYPEINFO, TypeId, 0, 0);
  end;
end;

procedure TBaseParser.SetGuid(IntfTypeId: Integer; const S: String);
var
  D: packed record
       D1, D2: Double;
     end;
  G: TGUID;
begin
{$IFDEF VARIANTS}
  if S[1] = '(' then
    G := SysUtils.StringToGUID(Copy(S, 2, Length(S) - 2))
  else
    G := SysUtils.StringToGUID(S);
{$ELSE}
  if S[1] = '(' then
    G := StringToGUID(Copy(S, 2, Length(S) - 2))
  else
    G := StringToGUID(S);
{$ENDIF}
  Move(G, D, SizeOf(G));
  TKernel(kernel).SymbolTable[IntfTypeId + 1].Value := D.D1;
  TKernel(kernel).SymbolTable[IntfTypeId + 2].Value := D.D2;
end;

{$IFDEF LINUX}
 // will use uuid.pas in hash folder:
function CoCreateGuid(out guid: TGUID): HResult;
begin
   if uuid.uuid_create(GUID) then result:=1
   else result:=0;
end;
{$ELSE}
function CoCreateGuid(out guid: TGUID): HResult; stdcall;
  external 'ole32.dll' name 'CoCreateGuid';
{$ENDIF}

function CreateGUID(out Guid: TGUID): HResult;
begin
  Result := CoCreateGuid(Guid);
end;

procedure TBaseParser.SetNewGuid(IntfTypeId: Integer);
var
  D: packed record
       D1, D2: Double;
     end;
  G: TGUID;
begin
{$IFDEF VARIANTS}
  SysUtils.CreateGUID(G);
{$ELSE}
  CreateGUID(G);
{$ENDIF}
  Move(G, D, SizeOf(G));
  TKernel(kernel).SymbolTable[IntfTypeId + 1].Value := D.D1;
  TKernel(kernel).SymbolTable[IntfTypeId + 2].Value := D.D2;
end;

procedure TBaseParser.EndInterfaceType(TypeId: Integer; IsForward: Boolean);
var
  L: Integer;
  DeclaredInSub: Boolean;
  Code: TCode;
begin
  if IsForward then
  begin
    Code := TKernel(kernel).Code;
    L := Code.Card;
    while Code[L].Op <> OP_BEGIN_INTERFACE_TYPE do Dec(L);
    Code[L].Op := OP_NOP;
  end
  else
    Gen(OP_END_INTERFACE_TYPE, TypeId, 0, 0);

  levelStack.Pop;

  DeclaredInSub := GetKind(levelStack.Top) = KindSUB;

  if not DeclaredInSub then
  begin
    L := SkipLabelStack.Top;
    SetLabelHere(L);
    SkipLabelStack.Pop;
  end;
end;

procedure TBaseParser.BeginArrayType(TypeId: Integer);
var
  L: Integer;
  DeclaredInSub: Boolean;
begin
  DeclaredInSub := GetKind(levelStack.Top) = KindSUB;

  SetKind(TypeId, KindTYPE);
  SetType(TypeId, typeARRAY);

  SetAlignment(TypeId, Alignment);

  levelStack.Push(TypeId);

  if not DeclaredInSub then
  begin
    L := NewLabel;
    Gen(OP_GO, L, 0, 0);
    SkipLabelStack.Push(L);
  end;

  Gen(OP_BEGIN_ARRAY_TYPE, TypeId, 0, 0);
  if GetName(TypeId) = '' then
  begin
    SetName(TypeId, 'ArrayType_' + IntToStr(TypeId));
    Gen(OP_ADD_TYPEINFO, TypeId, 0, 0);
  end;
end;

procedure TBaseParser.EndArrayType(TypeId: Integer);
var
  L: Integer;
  DeclaredInSub: Boolean;
begin
  Gen(OP_END_ARRAY_TYPE, TypeId, 0, 0);

  levelStack.Pop;

  DeclaredInSub := GetKind(levelStack.Top) = KindSUB;

  if not DeclaredInSub then
  begin
    L := SkipLabelStack.Top;
    SetLabelHere(L);
    SkipLabelStack.Pop;
  end;
end;

procedure TBaseParser.BeginSetType(TypeId, TypeBaseId: Integer);
begin
  SetKind(TypeId, KindTYPE);
  SetType(TypeId, typeSET);
  SetPatternId(TypeId, TypeBaseId);

  Gen(OP_BEGIN_SET_TYPE, TypeId, 0, 0);
  if GetName(TypeId) = '' then
  begin
    SetName(TypeId, 'SetType_' + IntToStr(TypeId));
    Gen(OP_ADD_TYPEINFO, TypeId, 0, 0);
  end;
  if GetName(TypeBaseId) = '' then
  begin
    SetName(TypeBaseId, 'OriginSetType_' + IntToStr(TypeBaseId));
    Gen(OP_ADD_TYPEINFO, TypeBaseId, 0, 0);
  end;
end;

procedure TBaseParser.EndSetType(TypeId: Integer);
begin
  Gen(OP_END_SET_TYPE, TypeId, 0, 0);
end;

procedure TBaseParser.BeginEnumType(TypeId, TypeBaseId: Integer);
begin
  SetKind(TypeId, KindTYPE);
  SetType(TypeId, typeENUM);
  SetPatternId(TypeId, TypeBaseId);

  levelStack.Push(TypeId);

  Gen(OP_BEGIN_ENUM_TYPE, TypeId, 0, 0);
  if GetName(TypeId) = '' then
  begin
    SetName(TypeId, 'EnumType_' + IntToStr(TypeId));
    Gen(OP_ADD_TYPEINFO, TypeId, 0, 0);
  end;
end;

procedure TBaseParser.EndEnumType(TypeId, ACount: Integer);
begin
  Gen(OP_END_ENUM_TYPE, TypeId, 0, 0);

  SetCount(TypeId, ACount);

  levelStack.Pop;
end;

procedure TBaseParser.BeginSubrangeType(TypeId, TypeBaseId: Integer);
begin
  SetKind(TypeId, KindTYPE);
  SetType(TypeId, TypeBaseId);
  levelStack.Push(TypeId);

  Gen(OP_BEGIN_SUBRANGE_TYPE, TypeId, 0, 0);
  if GetName(TypeId) = '' then
  begin
    SetName(TypeId, 'SubType_' + IntToStr(TypeId));
    Gen(OP_ADD_TYPEINFO, TypeId, 0, 0);
  end;
end;

procedure TBaseParser.EndSubrangeType(TypeId: Integer);
begin
  Gen(OP_END_SUBRANGE_TYPE, TypeId, 0, 0);

  levelStack.Pop;
end;

procedure TBaseParser.BeginPointerType(TypeId: Integer);
begin
  SetKind(TypeId, KindTYPE);
  SetType(TypeId, typePOINTER);

  Gen(OP_BEGIN_POINTER_TYPE, TypeId, 0, 0);
  if GetName(TypeId) = '' then
  begin
    SetName(TypeId, 'PointerType_' + IntToStr(TypeId));
    Gen(OP_ADD_TYPEINFO, TypeId, 0, 0);
  end;
end;

procedure TBaseParser.EndPointerType(TypeId: Integer);
begin
  Gen(OP_END_POINTER_TYPE, TypeId, 0, 0);
end;

procedure TBaseParser.BeginClassReferenceType(TypeId: Integer);
begin
  SetKind(TypeId, KindTYPE);
  SetType(TypeId, typeCLASSREF);
  Gen(OP_BEGIN_CLASSREF_TYPE, TypeId, 0, 0);
  if GetName(TypeId) = '' then
  begin
    SetName(TypeId, 'ClassRefType_' + IntToStr(TypeId));
    Gen(OP_ADD_TYPEINFO, TypeId, 0, 0);
  end;
end;

procedure TBaseParser.EndClassReferenceType(TypeId: Integer);
begin
  Gen(OP_END_CLASSREF_TYPE, TypeId, 0, 0);
end;

procedure TBaseParser.BeginDynamicArrayType(TypeId: Integer);
var
  L: Integer;
begin
  SetKind(TypeId, KindTYPE);
  SetType(TypeId, typeDYNARRAY);

  Gen(OP_BEGIN_DYNARRAY_TYPE, TypeId, 0, 0);
  if GetName(TypeId) = '' then
  begin
    SetName(TypeId, 'DynarrayType_' + IntToStr(TypeId));
    Gen(OP_ADD_TYPEINFO, TypeId, 0, 0);
  end;
  L := GetLevel(TypeId);
  if L = 0 then
    Exit;
  while GetKind(L) in kindSUBS do
    L := GetLevel(L);
  SetLevel(TypeId, L);
end;

procedure TBaseParser.EndDynamicArrayType(TypeId: Integer);
begin
  Gen(OP_END_DYNARRAY_TYPE, TypeId, 0, 0);
end;

procedure TBaseParser.BeginShortStringType(TypeId: Integer);
begin
  SetKind(TypeId, KindTYPE);
  SetType(TypeId, typeSHORTSTRING);
  Gen(OP_BEGIN_SHORTSTRING_TYPE, TypeId, 0, 0);
  if GetName(TypeId) = '' then
  begin
    SetName(TypeId, 'ShortStringType_' + IntToStr(TypeId));
    Gen(OP_ADD_TYPEINFO, TypeId, 0, 0);
  end;
end;

procedure TBaseParser.EndShortStringType(TypeId: Integer);
begin
  Gen(OP_END_SHORTSTRING_TYPE, TypeId, 0, 0);
end;

procedure TBaseParser.BeginProceduralType(TypeId, SubId: Integer);
var
  DummySubId: Integer;
begin
  SetKind(TypeId, KindTYPE);
  SetType(TypeId, typePROC);

  SetKind(SubID, KindSUB);
  SetCallConvention(SubID, CallConv);

  SetPatternId(TypeId, SubId);

  levelStack.Push(SubId);
  NewVar('result');
  NewVar('');

  if InterfaceOnly then
  begin
    DummySubId := TypeId + 1;
    SetName(DummySubId, DUMMYPROC_PREFIX + IntToStr(DummySubId));

    Gen(OP_BEGIN_PROC_TYPE, TypeId, 0, 0);
    Gen(OP_BEGIN_SUB, DummySubId, 0, 0);
  end;
end;

procedure TBaseParser.EndProceduralType(TypeId: Integer);
begin
  if InterfaceOnly then
  begin
    Gen(OP_END_SUB, TypeId + 1, 0, 0);
    Gen(OP_END_PROC_TYPE, TypeId, 0, 0);
  end;

  levelStack.Pop;
end;


function TBaseParser.GetTryCount: Integer;
begin
  result := TKernel(kernel).TryCount;
end;

procedure TBaseParser.SetTryCount(Value: Integer);
begin
  TKernel(kernel).TryCount := Value;
end;

function TBaseParser.GetDebugMode: Boolean;
begin
  result := TKernel(kernel).DEBUG_MODE;
end;

function TBaseParser.GenBeginTry: Integer; // returns label
begin
  SetTryCount(TryCount + 1);
  try_stack.Push(TryCount);

  result := NewLabel;
  Gen(OP_TRY_ON, try_stack.Top, 0, CurrLevel);
end;

procedure TBaseParser.GenFinally;
var
  L: Integer;
  Code: TCode;
  R: TCodeRec;
  I, K: Integer;
begin
  L := NewLabel;
  SetLabelHere(L);
  Gen(OP_FINALLY, try_stack.Top, L, CurrLevel);

  K := 1;

  Code := TKernel(kernel).Code;
  for I := Code.Card downto 1 do
  begin
    R := Code[I];
    if R.Op = OP_TRY_ON then
    begin
      Dec(K);
      if K = 0 then
        break;
    end
    else if R.Op = OP_TRY_OFF then
    begin
      Inc(K);
    end
    else if R.Op = OP_INIT_SUB then
      break;
  end;
end;

procedure TBaseParser.GenExcept;
var
  L: Integer;
begin
  L := NewLabel;
  SetLabelHere(L);
  Gen(OP_EXCEPT, try_stack.Top, L, CurrLevel);
end;

procedure TBaseParser.GenExceptOn(type_id: Integer);
var
  L: Integer;
begin
  L := NewLabel;
  SetLabelHere(L);
  Gen(OP_EXCEPT_ON, try_stack.Top, L, type_id);
end;

procedure TBaseParser.GenEndTry;
begin
  Gen(OP_TRY_OFF, try_stack.Top, 0, CurrLevel);
  try_stack.Pop;
end;

procedure TBaseParser.GenDestroyGlobalDynamicVariables(B1, B2: Integer);
var
  I: Integer;
  R: TCodeRec;
  Code: TCode;
begin
  Code := TKernel(kernel).Code;

  for I:=B2 downto B1 do
  begin
    R := Code[I];
    if R.Op = OP_DECLARE_LOCAL_VAR then
    if GetKind(R.Arg2) = KindVAR then
    begin
      if (R.Arg1 = 0) or (TKernel(kernel).SymbolTable[R.Arg1].Kind = kindNAMESPACE) then
      begin
        if not TKernel(kernel).SymbolTable[R.Arg2].Param then
          Gen(OP_DESTROY_LOCAL_VAR, R.Arg2, 0, 0);
      end
      else if GetSymbolRec(R.Arg2).TypedConst then
      begin
        Gen(OP_DESTROY_LOCAL_VAR, R.Arg2, 0, 0);
      end;
    end;
  end;
end;

function TBaseParser.IsForward(SubId: Integer): Boolean;
begin
  result := TKernel(kernel).SymbolTable[SubId].IsForward;
end;

procedure TBaseParser.SetForward(SubId: Integer; value: Boolean);
begin
  TKernel(kernel).SymbolTable[SubId].IsForward := value;
end;

function TBaseParser.ReplaceForwardDeclaration(var ID: Integer; IsExternalUnit: Boolean = false): Boolean;
var
  I, J, ParamId: Integer;
  Code: TCode;
  SymbolTable: TSymbolTable;
  ForwardID: Integer;
  L: TIntegerList;
  BestId: Integer;
label
  ok;
begin
  BestId := 0;
  Code := TKernel(kernel).Code;
  SymbolTable := TKernel(kernel).SymbolTable;

  ForwardId := SymbolTable.LookupForwardDeclaration(Id, Upcase, BestId);

  if ForwardId = Id then
  begin
    result := true;
    Exit;
  end;

  if ForwardId = 0 then
  begin
    if IsExternalUnit then
    begin
      result := true;
      Exit;
    end;

    if BestId > 0 then
    begin
      ForwardId := BestId;

      if SymbolTable[id].Count > 0 then
      begin
        CreateError(errDeclarationDiffersFromPreviousDeclaration,
        [SymbolTable[Id].FullName]);
      end;

      goto ok;
    end;

    if SymbolTable[Id].Count > 0 then
    begin
      result := false;
      Exit;
    end;

    L := LookupForwardDeclarations(Id);

    if L = nil then
    begin
      I := SymbolTable[Id].Level;
      if (I > 0) then if SymbolTable[I].Kind = kindTYPE then
      begin
        if SymbolTable.LookupAnotherDeclaration(Id, Upcase, BestId) = 0 then
        begin
          CreateError(errUndeclaredIdentifier, [SymbolTable[Id].FullName]);
        end
        else
        begin
          CreateError(errRedeclaredIdentifier, [SymbolTable[Id].FullName]);
        end;
      end;

      result := false;
      Exit;
    end
    else if L.Count = 1 then
    begin
      // ok
      ForwardId := L[0];
      L.Free;
    end
    else
    begin
      L.Free;
      result := false;
      Exit;
    end;

  end;

  ok:

  result := true;

  // remove forward definition from Code
  I := 1;
  repeat
    if (Code[I].Op = OP_BEGIN_SUB) and (Code[I].Arg1 = ForwardId) then
    begin
      Code[I].Op := OP_NOP;
      break;
    end;
    Inc(I);
    if I = Code.Card then
      RaiseError(errInternalError, []);
  until false;

  Code[I-1].Op := OP_NOP; //OP_GO

  Inc(I); // 15 july 2007
  repeat
// new
    if Code[I].Op = OP_HIGH then
    begin
      // ok. 30 match 2009
    end
    else if Code[I].Op = OP_LOW then
    begin
      // ok. 30 match 2009
    end
    else if Code[I].Op = OP_SIZEOF then
    begin
      // ok. 30 match 2009
    end
    else if Code[I].Op = OP_PRED then
    begin
      // ok. 30 match 2009
    end
    else if Code[I].Op = OP_SUCC then
    begin
      // ok. 30 match 2009
    end
    else if Code[I].Op = OP_ABS then
    begin
      // ok. 30 match 2009
    end
    else if Code[I].Op = OP_ORD then
    begin
      // ok. 30 match 2009
    end
    else if Code[I].Op = OP_CHR then
    begin
      // ok. 30 match 2009
    end
    else if Code[I].Op = OP_EVAL then
    begin
      // ok. 2 october 2007
    end
    else if Code[I].Op = OP_ASSIGN_CONST then
    begin
      // ok. 18 november 2007
    end
    else if (Code[I].Op = OP_PUSH) or (Code[I].Op = OP_CALL) then
    begin
      // ok. 3 december 2007
    end
    else if (Code[I].Op = OP_CHECK_OVERRIDE) then
    begin
      // ok. 23 July 2008
    end
    else if (Code[I].Op = OP_CREATE_DYNAMIC_ARRAY_TYPE) then
    begin
      // ok. 6 October 2008
    end
    else if Code[I].Op = OP_SEPARATOR then
    begin
      // ok. 3 August 2009
    end
    else
    if Code[I].Op = OP_ASSIGN_TYPE then
    begin
      if (Code[I].Arg1 = ForwardId) or
         (SymbolTable[Code[I].Arg1].Level = ForwardId) then
        begin
          // ok
        end
        else
          Code[I].Op := OP_NOP;
    end
    else
// new
      Code[I].Op := OP_NOP;
    Inc(I);
    if I = Code.Card then
      RaiseError(errInternalError, []);
  until (Code[I].Op = OP_FIN_SUB) and (Code[I].Arg1 = ForwardId);
  Code[I].Op := OP_NOP;
  Code[I+1].Op := OP_NOP; //OP_LABEL

  // update OP_ASSIGN_TYPE instructions for parameters and result
  I := 1;
  repeat
    if (Code[I].Op = OP_BEGIN_SUB) and (Code[I].Arg1 = Id) then
      break;
    Inc(I);
    if I > Code.Card then // 15 july 2007
      RaiseError(errInternalError, []);
  until false;

  if I < Code.Card then // 15 july 2007
  repeat
    Inc(I);
    if Code[I].Op = OP_ASSIGN_TYPE then
    begin
      if SymbolTable[Code[I].Arg1].Level = Id then
      begin
        for J:=0 to SymbolTable[Id].Count - 1 do
        begin
          ParamId := SymbolTable.GetParamId(Id, J);
          if ParamId = Code[I].Arg1 then
          begin
            ParamId := SymbolTable.GetParamId(ForwardId, J);
            Code[I].Arg1 := ParamId;
            break;
          end;
        end;
        if Code[I].Arg1 = SymbolTable.GetResultId(Id) then
           Code[I].Arg1 := SymbolTable.GetResultId(ForwardId);
      end;
    end;
    if I >= Code.Card then
      break;
  until false;

  Code.ReplaceId(Id, ForwardId);

  SetKind(Id, KindNONE);
  SetName(Id, '');

  SetKind(SymbolTable.GetResultId(Id), KindNONE);
  SetKind(SymbolTable.GetSelfId(Id),   KindNONE);

  SetKind(ForwardId + 3, KindNONE);               // label
  SetKind(ForwardId + 4, KindNONE);               // label

  for I:=ID to SymbolTable.Card do
    if (SymbolTable[I].Level = Id) and (SymbolTable[I].Kind <> KindTYPE) then
      SetKind(I, KindNONE);

  SetForward(ForwardId, false);

  Id := ForwardId;
  LevelStack.Pop;
  LevelStack.Push(id);
end;

constructor TParserList.Create(i_kernel: Pointer);
begin
  inherited Create;
  L := TList.Create;
  kernel := i_kernel;
end;

destructor TParserList.Destroy;
begin
  Clear;
  L.Free;
  inherited;
end;

function TParserList.GetParser(I: Integer): TBaseParser;
begin
  result := TBaseParser(L[I]);
end;

function TParserList.Count: Integer;
begin
  result := L.Count;
end;

procedure TParserList.Clear;
begin
  L.Clear;
end;

procedure TParserList.AddParser(P: TBaseParser);
begin
  if FindParser(P.LanguageName) = nil then
    L.Add(P);
end;

function TParserList.FindParser(const LanguageName: String): TBaseParser;
var
  I: Integer;
begin
  for I:=0 to Count - 1 do
    if StrEql(Items[I].LanguageName, LanguageName) then
    begin
      result := Items[I];
      Exit;
    end;
  result := nil;
end;

function TParserList.FindParserByFileExtension(const FileExtension: String): TBaseParser;
var
  I: Integer;
begin
  for I:=0 to Count - 1 do
    if StrEql(Items[I].GetFileExt, FileExtension) then
    begin
      result := Items[I];
      Exit;
    end;
  result := nil;
end;

{$WARN SYMBOL_DEPRECATED OFF}
procedure TBaseParser.AddModuleFromFile(FileName: String;
                                        UsedUnitId: Integer;
                                        IsImplementationSection: Boolean);
var
  CodeLines: String;
  UnitName, ALanguageName, Ext: String;
  P, I, J, K: Integer;
  Parser, UnitParser: TBaseParser;
  Prog: TProgram;
  MapTable: TMapTable;
  MapRec: TMapRec;
  SubDesc: TSubDesc;
  S: String;
  SourceAge, PCUAge: TDateTime;
  PCUFileName: String;
  M: TModule;
  RootKernel: TKernel;
  TypeInfoList: TPaxTypeInfoList;
  EnumTypeDataContainer: TEnumTypeDataContainer;
  ArrayTypeDataContainer: TArrayTypeDataContainer;
  RecordTypeDataContainer: TRecordTypeDataContainer;
  SetTypeDataContainer: TSetTypeDataContainer;
  AliasTypeDataContainer: TAliasTypeDataContainer;
  PointerTypeDataContainer: TPointerTypeDataContainer;
  ClassRefTypeDataContainer: TClassRefTypeDataContainer;
  DynArrayTypeDataContainer: TDynArrayTypeDataContainer;
  ProceduralTypeDataContainer: TProceduralTypeDataContainer;
  ClassTypeDataContainer: TClassTypeDataContainer;
  MethodTypeDataContainer: TMethodTypeDataContainer;
  InterfaceTypeDataContainer: TInterfaceTypeDataContainer;

  S1, S2, AFullTypeName: String;
  InputStream, OutputStream: TStream;
  OutputStream_Position, Temp_Position: Integer;
  ModuleRec: TModuleRec;
  CompilePCU: Boolean;
begin
  if TKernel(kernel).Modules.IndexOf(FileName) >= 0 then
    Exit;

  RootKernel := Kernel;
  while RootKernel.PCUOwner <> nil do
    RootKernel := RootKernel.PCUOwner;

  CodeLines := '';

  P := PosCh('.', FileName);
  if P > 0 then
  begin
    UnitName := Copy(FileName, 1, P - 1);
    Ext := Copy(FileName, P + 1, 10);
    Parser := TKernel(kernel).ParserList.FindParserByFileExtension(Ext);
    if Parser = nil then
      RaiseError(errUnregisteredLanguage, [FileName]);

    ALanguageName := Parser.LanguageName;
  end
  else
  begin
    ALanguageName := LanguageName;
    UnitName := FileName;
    Parser := Self;
  end;

  PCUFileName := UnitName + '.' + PCU_FILE_EXT;
  OutputStream := nil;
  OutputStream_Position := 0;
  InputStream := nil;

  I := RootKernel.Modules.IndexOf(UnitName);
  if I >= 0 then
  begin
    if IsImplementationSection then
    begin
      if RootKernel.Modules[I].State <> msCompiling then
        IsImplementationSection := false;
    end
    else
    begin
      if RootKernel.Modules[I].State = msCompiling then
        IsImplementationSection := true
      else if RootKernel.BuildedUnits.IndexOf(UpperCase(PCUFileName)) = -1 then
        RaiseError(errCircularUnitReference, [UnitName]);
    end;
  end;

  if Assigned(RootKernel.OnLoadPCU) then
  begin
    InputStream := RootKernel.OnLoadPCU(RootKernel.Owner, UnitName);
  end;

  if RootKernel.BuildAll then
  begin
    if Assigned(RootKernel.OnSavePCU) then
      if RootKernel.BuildedUnits.IndexOf(UpperCase(PCUFileName)) = - 1 then
      if not IsImplementationSection then
      begin
        OutputStream := RootKernel.OnSavePCU(RootKernel.Owner, UnitName);
        if OutputStream <> nil then
          OutputStream_Position := OutputStream.Position;
      end;

    if IsImplementationSection then
    begin
      RemoveInstruction(OP_EVAL, -1, -1, UsedUnitId);

      I := TKernel(Kernel).Modules.IndexOf(UnitName);
      if I = -1 then
      begin
        if Assigned(RootKernel.OnUsedUnit) then
        begin
          RootKernel.CurrLanguage := ALanguageName;
          if (RootKernel.OnUsedUnit(RootKernel, UnitName, CodeLines)) and
            (CodeLines <> '') then
            begin
              ALanguageName := RootKernel.CurrLanguage;
              M := TKernel(kernel).AddModule(UnitName, ALanguageName);
              M.SkipParsing := true;
              TKernel(kernel).AddCode(UnitName, CodeLines);
            end
            else
            begin
              M := TKernel(kernel).AddModule(UnitName, ALanguageName);
              M.SkipParsing := true;
            end;
        end
        else
        begin
          I := RootKernel.Modules.IndexOf(UnitName);
          M := TKernel(kernel).AddModule(UnitName, ALanguageName);
          M.SkipParsing := true;
          if I = - 1 then
            TKernel(kernel).AddCodeFromFile(UnitName, FileName)
          else
            TKernel(kernel).AddCode(UnitName,
              RootKernel.Modules[I].Lines.Text);
        end;

        UnitParser := CreateParser(FileName);
        try
          UnitParser.Init(kernel, M);
          UnitParser.BRP := true;
          UnitParser.Call_SCANNER;
          UnitParser.Parse_Unit(true);
        finally
          UnitParser.Free;
        end;
      end;
      Exit;
    end
    else
    begin
      if RootKernel.BuildedUnits.IndexOf(UpperCase(PCUFileName)) = - 1 then
        if not CompileUnit(kernel, UnitName, FileName, PCUFileName, Parser, true, OutputStream) then
           Exit;
    end;
  end;

  if not RootKernel.BuildAll then
    if Assigned(RootKernel.OnUsedUnit) then
      if TKernel(Kernel).Modules.IndexOf(UnitName) = -1 then
      begin
        RootKernel.CurrLanguage := LanguageName;
        if RootKernel.OnUsedUnit(RootKernel.Owner, UnitName, CodeLines) then
          if CodeLines <> '' then
          begin
            TKernel(kernel).AddModule(UnitName, TKernel(kernel).CurrLanguage);
            TKernel(kernel).AddCode(UnitName, CodeLines);
            Exit;
          end;
      end;

  if (InputStream = nil) or (OutputStream = nil) then
  begin
    if not FileExists(FileName) then
      SourceAge := 0
    else
      SourceAge := FileDateToDateTime(FileAge(FileName));

    if not FileExists(PCUFileName) then
      PCUAge := 0
    else
      PCUAge := FileDateToDateTime(FileAge(PCUFileName));

    CompilePCU := ((PCUAge > SourceAge) and FileExists(PCUFileName));
  end
  else
    CompilePCU := true;

  if CompilePCU then
  begin
    FileName := PCUFileName;

    if TKernel(kernel).Modules.IndexOf(UnitName) = -1 then
    begin
      Prog := TProgram.Create;
      try
        CodeLines := 'unit ' + UnitName + ';' + #13#10 +
        'interface' + #13#10;

        if InputStream <> nil then
        begin
          Prog.LoadFromStream(InputStream);
        end
        else if OutputStream <> nil then
        begin
          Temp_Position := OutputStream.Position;
          OutputStream.Position := OutputStream_Position;
          Prog.LoadFromStream(OutputStream);
          OutputStream.Position := Temp_Position;
        end
        else
          Prog.LoadFromFile(FileName);

        ModuleRec := Prog.RunTimeModuleList.Modules.GetModuleRec(UnitName);
        if ModuleRec <> nil then
          if ModuleRec.UsedModules.Count > 0 then
          begin
            CodeLines := CodeLines + 'uses ';
            for I := 0 to ModuleRec.UsedModules.Count - 1 do
            begin
              CodeLines := CodeLines + ModuleRec.UsedModules[I];
              if I < ModuleRec.UsedModules.Count - 1 then
                CodeLines := CodeLines + ','
              else
                CodeLines := CodeLines + ';' + #13#10;
            end;
          end;

        if not RootKernel.BuildWithRuntimePackages then
          RootKernel.PCUStreamList.AddFromFile(FileName);

        MapTable := Prog.ScriptMapTable;

        TypeInfoList := Prog.ProgTypeInfoList;
        for I := 0 to TypeInfoList.Count - 1 do
        begin
          S := String(TypeInfoList[I].FullName);
          S := ExtractOwner(S);
          if not StrEql(UnitName, S) then
            continue;
          case TypeInfoList[I].TypeInfo.Kind of
            tkUnknown:
            begin
              case TypeInfoList[I].FinTypeId of
                typeALIAS:
                begin
                  AliasTypeDataContainer :=
                     TypeInfoList[I].TypeDataContainer as TAliasTypeDataContainer;
                     CodeLines := CodeLines + 'type ' + String(TypeInfoList[I].TypeInfo.Name) +
                     ' = ';
                  CodeLines := CodeLines +
                  ExtractName(String(AliasTypeDataContainer.FullSourceTypeName)) + ';' +
                  #13#10;
                end;
                typePOINTER:
                begin
                  PointerTypeDataContainer :=
                     TypeInfoList[I].TypeDataContainer as TPointerTypeDataContainer;
                     CodeLines := CodeLines + 'type ' + String(TypeInfoList[I].TypeInfo.Name) +
                     ' = ';
                  CodeLines := CodeLines + '^' +
                  ExtractName(String(PointerTypeDataContainer.FullOriginTypeName)) + ';' +
                  #13#10;
                end;
                typeCLASSREF:
                begin
                  ClassRefTypeDataContainer :=
                    TypeInfoList[I].TypeDataContainer as TClassRefTypeDataContainer;
                    CodeLines := CodeLines + 'type ' + String(TypeInfoList[I].TypeInfo.Name) +
                     ' = ';
                  CodeLines := CodeLines + ' class of ' +
                  ExtractName(String(ClassRefTypeDataContainer.FullOriginTypeName)) + ';' +
                  #13#10;
                end;
                typePROC:
                begin
                  ProceduralTypeDataContainer :=
                     TypeInfoList[I].TypeDataContainer as TProceduralTypeDataContainer;
                     CodeLines := CodeLines + 'type ' + String(TypeInfoList[I].TypeInfo.Name) +
                     ' = ';
                  with ProceduralTypeDataContainer.SubDesc do
                  begin
                    if ResTypeId = typeVOID then
                      CodeLines := CodeLines + 'procedure ('
                    else
                      CodeLines := CodeLines + 'function (';
                    if ParamList.Count = 0 then
                      CodeLines := CodeLines + ')'
                    else
                      for J := 0 to ParamList.Count - 1 do
                      begin
                        if ParamList[J].ParamMod = PM_BYREF then
                          CodeLines := CodeLines + 'var '
                        else if ParamList[J].ParamMod = PM_CONST then
                          CodeLines := CodeLines + 'const ';

                        CodeLines := CodeLines + ParamList[J].ParamName + ':' +
                          ParamList[J].ParamTypeName;
                        if J < ParamList.Count - 1 then
                          CodeLines := CodeLines + ';'
                        else
                          CodeLines := CodeLines + ')';
                      end;

                    if ResTypeId = typeVOID then
                      CodeLines := CodeLines + ';'
                    else
                      CodeLines := CodeLines + ':' + ResTypeName + ';';

                    case CallMode of
                      ccREGISTER: CodeLines := CodeLines + 'register;';
                      ccSTDCALL: CodeLines := CodeLines + 'stdcall;';
                      ccCDECL: CodeLines := CodeLines + 'cdecl;';
                      ccPASCAL: CodeLines := CodeLines + 'pascal;';
                      ccSAFECALL: CodeLines := CodeLines + 'safecall;';
                      ccMSFASTCALL: CodeLines := CodeLines + 'msfastcall;';
                    end;

                  end;
                  CodeLines := CodeLines + #13#10;
                end;
              end;
            end;
            tkRecord:
            begin
              RecordTypeDataContainer :=
                TypeInfoList[I].TypeDataContainer as TRecordTypeDataContainer;
              CodeLines := CodeLines + 'type ' + String(TypeInfoList[I].TypeInfo.Name) +
                ' = record' + #13#10;
              with RecordTypeDataContainer do
              for J := 0 to FieldListContainer.Count - 1 do
              begin
                CodeLines := CodeLines +
                  String(FieldListContainer[J].Name) + ':' +
                  ExtractName(String(FieldListContainer[J].FullFieldTypeName)) +
                  ';'#13#10;
              end;

              AFullTypeName := String(TypeInfoList[I].FullName);

              // methods
              for J := 0 to MapTable.Count - 1 do
              begin
                MapRec := MapTable[J];
                S := ExtractOwner(MapRec.FullName);
                if StrEql(S, UnitName) then
                begin
                  if MapRec.Kind in KindSUBS then
                  begin
                    SubDesc := MapRec.SubDesc;
                    if not SubDesc.IsMethod then
                      continue;

                    S := ExtractFullOwner(MapRec.FullName);
                    if not StrEql(AFullTypeName, S) then
                      continue;

                    S := ExtractName(MapRec.FullName);

                    case MapRec.Kind of
                      KindCONSTRUCTOR:
                        S := 'constructor ' + S + '(';
                      KindDESTRUCTOR:
                        S := 'destructor ' + S + '(';
                      KindSUB:
                      begin
                        if SubDesc.ResTypeId = typeVOID then
                          S := 'procedure ' + S + '('
                        else
                          S := 'function ' + S + '(';
                      end;
                    end;

                    if SubDesc.IsShared then
                      S := 'class ' + S;

                    case MapRec.Vis of
                      cvNone: continue;
                      cvPrivate: S := 'private ' + S;
                      cvPublic: S := 'public ' + S;
                      cvProtected: S := 'protected ' + S;
                      cvPublished:
                      begin
                        if MapRec.Kind = KindSUB then
                          S := 'published ' + S;
                      end;
                    end;

                    for K:=0 to SubDesc.ParamList.Count - 1 do
                    begin
                      case SubDesc.ParamList[K].ParamMod of
                        PM_BYVAL: begin end;
                        PM_BYREF: S := S + 'var ';
                        PM_CONST: S := S + 'const ';
                      end;
                      S := S + SubDesc.ParamList[K].ParamName;
                      S := S + ':';
                      S := S + SubDesc.ParamList[K].ParamTypeName;
                      if K < SubDesc.ParamList.Count - 1 then
                        S := S + ';';
                    end;

                    S := S + ')';

                    if MapRec.Kind = KindSUB then
                      if SubDesc.ResTypeId <> typeVOID then
                        S := S + ':' + SubDesc.ResTypeName;
                    S := S + ';';

                   case SubDesc.CallMode of
                      cmNONE:
                        if MapRec.Kind = KindDESTRUCTOR then
                          S := S + 'override;';
                      cmVIRTUAL:
                      begin
                        S := S + 'virtual;';
                      end;
                      cmOVERRIDE:
                        S := S + 'override;';
                    end;

                    case SubDesc.CallConv of
                      ccREGISTER: S := S + 'register';
                      ccSTDCALL: S := S + 'stdcall';
                      ccCDECL: S := S + 'cdecl';
                      ccPASCAL: S := S + 'pascal';
                      ccSAFECALL: S := S + 'safecall';
                      ccMSFASTCALL: S := S + 'msfastcall';
                    end;
                    S := S + ';';

                    S := S + 'external ' + '''' + FileName + '''' + ';';
                    CodeLines := CodeLines + S + #13#10;
                  end; // kindSUB
                end;
              end; // methods

              CodeLines := CodeLines + 'end;'#13#10;
            end;
            tkArray:
            begin
              ArrayTypeDataContainer :=
                TypeInfoList[I].TypeDataContainer as TArrayTypeDataContainer;
              CodeLines := CodeLines + 'type ' + String(TypeInfoList[I].TypeInfo.Name) +
                ' = array[';
              case ArrayTypeDataContainer.FinRangeTypeId of
                typeANSICHAR, typeWIDECHAR:
                  CodeLines := CodeLines +
                    '''' + Chr(ArrayTypeDataContainer.B1) + '''' + '..' +
                    '''' + Chr(ArrayTypeDataContainer.B2) + '''' + ']';
                typeENUM, typeBOOLEAN, typeBYTEBOOL, typeWORDBOOL, typeLONGBOOL:
                  CodeLines := CodeLines +
                    ExtractName(String(ArrayTypeDataContainer.FullRangeTypeName)) + ']';
                else
                begin
                  CodeLines := CodeLines +
                    IntToStr(ArrayTypeDataContainer.B1) + '..' +
                    IntToStr(ArrayTypeDataContainer.B2) + ']';
                end;
              end; // case
              CodeLines := CodeLines + ' of ' +
                ExtractName(String(ArrayTypeDataContainer.FullElemTypeName)) + ';' +
                #13#10;
            end; //tkArray
            tkDynArray:
            begin
              DynArrayTypeDataContainer :=
                TypeInfoList[I].TypeDataContainer as TDynArrayTypeDataContainer;
                CodeLines := CodeLines + 'type ' + String(TypeInfoList[I].TypeInfo.Name) +
                 ' = ';
              CodeLines := CodeLines + ' array of ' +
              ExtractName(String(DynArrayTypeDataContainer.FullElementTypeName)) + ';' +
              #13#10;
            end;
            tkSet:
            begin
              SetTypeDataContainer :=
                TypeInfoList[I].TypeDataContainer as TSetTypeDataContainer;
              CodeLines := CodeLines + 'type ' + String(TypeInfoList[I].TypeInfo.Name) +
                ' = set of ';
              CodeLines := CodeLines +
                ExtractName(String(SetTypeDataContainer.FullCompName)) + ';' +
                #13#10;
            end; // tkSet
            tkMethod:
            begin
              MethodTypeDataContainer :=
                TypeInfoList[I].TypeDataContainer as TMethodTypeDataContainer;
              if MethodTypeDataContainer.ResultTypeId = 0 then
                continue;

             CodeLines := CodeLines + 'type ' + String(TypeInfoList[I].TypeInfo.Name) +
               ' = ';
              with MethodTypeDataContainer do
              begin
                if ResultTypeId = typeVOID then
                  CodeLines := CodeLines + 'procedure ('
                else
                  CodeLines := CodeLines + 'function (';
                if ParamCount = 0 then
                  CodeLines := CodeLines + ')'
                else
                  for J := 0 to ParamCount - 1 do
                  with ParamListContainer do
                  begin
                    if ParamList[J].Flags = [pfVar] then
                      CodeLines := CodeLines + 'var '
                    else if ParamList[J].Flags = [pfConst] then
                      CodeLines := CodeLines + 'const ';

                    CodeLines := CodeLines + String(ParamList[J].ParamName) + ':' +
                      String(ParamList[J].TypeName);
                    if J < ParamCount - 1 then
                      CodeLines := CodeLines + ';'
                    else
                      CodeLines := CodeLines + ')';
                  end;

                if ResultTypeId = typeVOID then
                  CodeLines := CodeLines + ' of object;'
                else
                  CodeLines := CodeLines + ':' + String(ResultType) + ' of object;';

                case CallConv of
                  ccREGISTER: CodeLines := CodeLines + 'register;';
                  ccSTDCALL: CodeLines := CodeLines + 'stdcall;';
                  ccCDECL: CodeLines := CodeLines + 'cdecl;';
                  ccPASCAL: CodeLines := CodeLines + 'pascal;';
                  ccSAFECALL: CodeLines := CodeLines + 'safecall;';
                  ccMSFASTCALL: CodeLines := CodeLines + 'msfastcall;';
                end;

                CodeLines := CodeLines + #13#10;
              end;
            end; // tkMethod
            tkClass:
            begin
              ClassTypeDataContainer :=
                TypeInfoList[I].TypeDataContainer as TClassTypeDataContainer;
              CodeLines := CodeLines + 'type ' + String(TypeInfoList[I].TypeInfo.Name) +
                ' = class (' +
                ExtractName(String(ClassTypeDataContainer.FullParentName));

              for J := 0 to ClassTypeDataContainer.SupportedInterfaces.Count - 1 do
              begin
                CodeLines := CodeLines + ',' +
                  ClassTypeDataContainer.SupportedInterfaces[J];
              end;

              CodeLines := CodeLines + ')' + #13#10;
              AFullTypeName := String(TypeInfoList[I].FullName);

              // public fields
              for J := 0 to ClassTypeDataContainer.AnotherFieldListContainer.Count - 1 do
              begin
                case ClassTypeDataContainer.AnotherFieldListContainer[J].Vis of
                  cvPrivate: CodeLines := CodeLines + 'private ';
                  cvProtected: CodeLines := CodeLines + 'protected ';
                  cvPublic: CodeLines := CodeLines + 'public ';
                end;

                CodeLines := CodeLines +
                  String(ClassTypeDataContainer.AnotherFieldListContainer[J].Name)
                  + ':' +
                  String(ClassTypeDataContainer.AnotherFieldListContainer[J].FullFieldTypeName) +
                  ';'#13#10;
              end;

              // published fields
              for J := 0 to ClassTypeDataContainer.FieldListContainer.Count - 1 do
              begin
                CodeLines := CodeLines + 'published ' +
                  String(ClassTypeDataContainer.FieldListContainer[J].Name) + ':' +
                  String(ExtractName(ClassTypeDataContainer.FieldListContainer[J].FullFieldTypeName)) +
                  ';'#13#10;
              end;

              // methods
              for J := 0 to MapTable.Count - 1 do
              begin
                MapRec := MapTable[J];
                S := ExtractOwner(MapRec.FullName);
                if StrEql(S, UnitName) then
                begin
                  if MapRec.Kind in KindSUBS then
                  begin
                    SubDesc := MapRec.SubDesc;
                    if not SubDesc.IsMethod then
                      continue;

                    S := ExtractFullOwner(MapRec.FullName);
                    if not StrEql(AFullTypeName, S) then
                      continue;

                    S := ExtractName(MapRec.FullName);

                    case MapRec.Kind of
                      KindCONSTRUCTOR:
                        S := 'constructor ' + S + '(';
                      KindDESTRUCTOR:
                        S := 'destructor ' + S + '(';
                      KindSUB:
                      begin
                        if SubDesc.ResTypeId = typeVOID then
                          S := 'procedure ' + S + '('
                        else
                          S := 'function ' + S + '(';
                      end;
                    end;

                    if SubDesc.IsShared then
                      S := 'class ' + S;

                    case MapRec.Vis of
                      cvNone: continue;
                      cvPrivate: S := 'private ' + S;
                      cvPublic: S := 'public ' + S;
                      cvProtected: S := 'protected ' + S;
                      cvPublished:
                      begin
                        if MapRec.Kind = KindSUB then
                          S := 'published ' + S;
                      end;
                    end;

                    for K:=0 to SubDesc.ParamList.Count - 1 do
                    begin
                      case SubDesc.ParamList[K].ParamMod of
                        PM_BYVAL: begin end;
                        PM_BYREF: S := S + 'var ';
                        PM_CONST: S := S + 'const ';
                      end;
                      S := S + SubDesc.ParamList[K].ParamName;
                      S := S + ':';
                      S := S + SubDesc.ParamList[K].ParamTypeName;
                      if K < SubDesc.ParamList.Count - 1 then
                        S := S + ';';
                    end;

                    S := S + ')';

                    if MapRec.Kind = KindSUB then
                      if SubDesc.ResTypeId <> typeVOID then
                        S := S + ':' + SubDesc.ResTypeName;
                    S := S + ';';

                   case SubDesc.CallMode of
                      cmNONE:
                        if MapRec.Kind = KindDESTRUCTOR then
                          S := S + 'override;';
                      cmVIRTUAL:
                      begin
                        S := S + 'virtual;';
                      end;
                      cmOVERRIDE:
                        S := S + 'override;';
                    end;

                    case SubDesc.CallConv of
                      ccREGISTER: S := S + 'register';
                      ccSTDCALL: S := S + 'stdcall';
                      ccCDECL: S := S + 'cdecl';
                      ccPASCAL: S := S + 'pascal';
                      ccSAFECALL: S := S + 'safecall';
                      ccMSFASTCALL: S := S + 'msfastcall';
                    end;
                    S := S + ';';

                    if (MapRec.SubDesc.DllName = '') and (MapRec.SubDesc.AliasName = '') then
                      S := S + 'external ' + '''' + FileName + '''' + ';'
                    else
                      S := S + ' external ' + '''' + MapRec.SubDesc.DllName + '''' +
                               ' name ' + '''' + MapRec.SubDesc.AliasName + '''' +
                      ';';

                    CodeLines := CodeLines + S + #13#10;
                  end; // kindSUB
                end;
              end; // methods

              // public properties
              with ClassTypeDataContainer do
              for J := 0 to AnotherPropList.Count - 1 do
              with AnotherPropList[J] do
              begin
                case Vis of
                  cvPrivate: CodeLines := CodeLines + 'private ';
                  cvProtected: CodeLines := CodeLines + 'protected ';
                  cvPublic: CodeLines := CodeLines + 'public ';
                end;
                CodeLines := CodeLines + 'property ' +
                  String(PropName);
                if ParamNames.Count > 0 then
                begin
                  CodeLines := CodeLines + '[';
                  for K := 0 to ParamNames.Count - 1 do
                  begin
                    CodeLines := CodeLines + ParamNames[K] + ':' +
                                             ParamTypes[K];
                    if K < ParamNames.Count - 1 then
                      CodeLines := CodeLines + ','
                    else
                      CodeLines := CodeLines + ']';
                  end;
                end;
                CodeLines := CodeLines + ':' + String(PropType);
                if Length(ReadName) > 0 then
                  CodeLines := CodeLines + ' read ' + String(ReadName);
                if Length(WriteName) > 0 then
                  CodeLines := CodeLines + ' write ' + String(WriteName);
                CodeLines := CodeLines + ';';
                if IsDefault then
                  CodeLines := CodeLines + 'default;';
                CodeLines := CodeLines + #13#10;
              end;

              // published properties
              for J := 0 to ClassTypeDataContainer.PropDataContainer.PropTypeNames.Count - 1 do
              begin
                S1 := ExtractName(ClassTypeDataContainer.PropDataContainer.ReadNames[J]);
                if Pos(READ_PREFIX, S1) = 1 then
                  S1 := Copy(S1, Length(READ_PREFIX) + 1, Length(S1) - Length(READ_PREFIX));
                S2 := ExtractName(ClassTypeDataContainer.PropDataContainer.WriteNames[J]);
                if Pos(WRITE_PREFIX, S2) = 1 then
                  S2 := Copy(S2, Length(WRITE_PREFIX) + 1, Length(S2) - Length(WRITE_PREFIX));

                CodeLines := CodeLines + 'published property ' +
                  String(ClassTypeDataContainer.PropDataContainer.PropList[J].Name) + ':' +
                  ClassTypeDataContainer.PropDataContainer.PropTypeNames[J] +
                  ' read ' + S1 +
                  ' write ' + S2 +
                  ';'#13#10;
              end;

              CodeLines := CodeLines + 'end;' + #13#10;
            end;
            tkString:
            begin
              CodeLines := CodeLines + 'type ' + String(TypeInfoList[I].TypeInfo.Name) +
                ' = String[' +
                IntToStr(TypeInfoList[I].TypeDataContainer.TypeData.MaxLength) +
                '];'#13#10;
            end;
            tkInterface:
            begin
              InterfaceTypeDataContainer :=
                TypeInfoList[I].TypeDataContainer as TInterfaceTypeDataContainer;
              CodeLines := CodeLines + 'type ' + String(TypeInfoList[I].TypeInfo.Name) +
                ' = interface(' +
                ExtractName(String(InterfaceTypeDataContainer.FullParentName))
                + ')' + #13#10;
              CodeLines := CodeLines +
                '[''' +
                GuidToString(InterfaceTypeDataContainer.Guid) +
                ''']' +
                #13#10;

              for K := 0 to InterfaceTypeDataContainer.SubDescList.Count - 1 do
              with InterfaceTypeDataContainer.SubDescList[K] do
              begin
                if ResTypeId = typeVOID then
                  CodeLines := CodeLines + 'procedure '
                else
                  CodeLines := CodeLines + 'function ';

                CodeLines := CodeLines + SubName + '(';

                if ParamList.Count = 0 then
                  CodeLines := CodeLines + ')'
                else
                  for J := 0 to ParamList.Count - 1 do
                  begin
                    if ParamList[J].ParamMod = PM_BYREF then
                      CodeLines := CodeLines + 'var '
                    else if ParamList[J].ParamMod = PM_CONST then
                      CodeLines := CodeLines + 'const ';

                    CodeLines := CodeLines + ParamList[J].ParamName + ':' +
                      ParamList[J].ParamTypeName;
                    if J < ParamList.Count - 1 then
                      CodeLines := CodeLines + ';'
                    else
                      CodeLines := CodeLines + ')';
                  end; // for-loop

                if ResTypeId = typeVOID then
                  CodeLines := CodeLines + ';'
                else
                  CodeLines := CodeLines + ':' + ResTypeName + ';';

                if OverCount > 0 then
                  CodeLines := CodeLines + 'overload;';

                case CallConv of
                  ccREGISTER: CodeLines := CodeLines + 'register;';
                  ccSTDCALL: CodeLines := CodeLines + 'stdcall;';
                  ccCDECL: CodeLines := CodeLines + 'cdecl;';
                  ccPASCAL: CodeLines := CodeLines + 'pascal;';
                  ccSAFECALL: CodeLines := CodeLines + 'safecall;';
                  ccMSFASTCALL: CodeLines := CodeLines + 'msfastcall;';
                end;

                CodeLines := CodeLines + #13#10;
              end; // for-looop SubDescList

              for J := 0 to InterfaceTypeDataContainer.PropDataContainer.Count - 1 do
              with InterfaceTypeDataContainer do
              begin
                S1 := ExtractName(PropDataContainer.ReadNames[J]);
                S2 := ExtractName(PropDataContainer.WriteNames[J]);

                CodeLines := CodeLines + 'property ' +
                  String(PropDataContainer.PropList[J].Name) + ':' +
                  PropDataContainer.PropTypeNames[J];
                if S1 <> '' then
                  CodeLines := CodeLines + ' read ' + S1;
                if S2 <> '' then
                  CodeLines := CodeLines + ' write ' + S2;
                CodeLines := CodeLines + ';'#13#10;
              end;

              CodeLines := CodeLines + 'end;' + #13#10;
            end; // tkInterface
            tkEnumeration:
            begin
              EnumTypeDataContainer :=
                TypeInfoList[I].TypeDataContainer as TEnumTypeDataContainer;

              CodeLines := CodeLines + 'type ' + String(TypeInfoList[I].TypeInfo.Name) +
                ' = (';
              K := Length(EnumTypeDataContainer.NameList);
              for J := 0 to K - 1 do
              begin
                CodeLines := CodeLines +
                  String(EnumTypeDataContainer.NameList[J]) + '=' +
                  IntToStr(EnumTypeDataContainer.ValueList[J]);

                if J < K - 1 then
                  CodeLines := CodeLines + ','
                else
                  CodeLines := CodeLines + ');' + #13#10;
              end;
            end; //tkEnumeration
          end; // case
        end; // for-loop

        for I := 0 to MapTable.Count - 1 do
        begin
          MapRec := MapTable[I];
          S := ExtractOwner(MapRec.FullName);
          if StrEql(S, UnitName) then
          begin
            S := ExtractName(MapRec.FullName);
            if MapRec.Kind = KindSUB then
            begin
              SubDesc := MapRec.SubDesc;
              if SubDesc.IsMethod then
                continue;

              if S = '' then
                continue;

              if SubDesc.ResTypeId = typeVOID then
                S := 'procedure ' + S + '('
              else
                S := 'function ' + S + '(';

              for J:=0 to SubDesc.ParamList.Count - 1 do
              begin
                case SubDesc.ParamList[J].ParamMod of
                  PM_BYVAL: begin end;
                  PM_BYREF: S := S + 'var ';
                  PM_CONST: S := S + 'const ';
                end;
                S := S + SubDesc.ParamList[J].ParamName;
                S := S + ':';
                S := S + SubDesc.ParamList[J].ParamTypeName;
                if J < SubDesc.ParamList.Count - 1 then
                  S := S + ';';
              end;

              S := S + ')';
              if SubDesc.ResTypeId <> typeVOID then
                S := S + ':' + SubDesc.ResTypeName;
              S := S + ';';

              case SubDesc.CallConv of
                ccREGISTER: S := S + 'register';
                ccSTDCALL: S := S + 'stdcall';
                ccCDECL: S := S + 'cdecl';
                ccPASCAL: S := S + 'pascal';
                ccSAFECALL: S := S + 'safecall';
                ccMSFASTCALL: S := S + 'msfastcall';
              end;
              S := S + ';';

              if SubDesc.OverCount > 0 then
                S := S + 'overload;';

              if (MapRec.SubDesc.DllName = '') and (MapRec.SubDesc.AliasName = '') then
                S := S + 'external ' + '''' + FileName + '''' + ';'
              else
                S := S + ' external ' + '''' + MapRec.SubDesc.DllName + '''' +
                         ' name ' + '''' + MapRec.SubDesc.AliasName + '''' +
                ';';

              CodeLines := CodeLines + S + #13#10;
            end // kindSUB
            else if MapRec.Kind = KindVAR then
            begin
              S := 'var ' + S + ':' +
                ExtractName(MapRec.FullTypeName) +
                ';';
              S := S + 'external ' + '''' + FileName + '''' + ';';
              CodeLines := CodeLines + S + #13#10;
            end // kindVAR
            else if MapRec.Kind = KindCONST then
            begin
              S := 'const ' + S + ':' +
                ExtractName(MapRec.FullTypeName) +
                ';';
              S := S + 'external ' + '''' + FileName + '''' + ';';
              CodeLines := CodeLines + S + #13#10;
            end; // kindCONST
            CodeLines := CodeLines + #13#10;
          end;
        end;

        CodeLines := CodeLines +
          'implementation' + #13#10 +
          'end.' + #13#10;

        TKernel(kernel).AddModule(UnitName, 'Pascal');
        TKernel(kernel).AddCode(UnitName, CodeLines);
      finally
        Prog.Free;
      end;
    end;

    Exit;
  end;

  if not UnitLookup then
    Exit;

  if SkipWhenNotFound then
  begin
    SkipWhenNotFound := false;
    Exit;
  end;

  if TKernel(kernel).Modules.IndexOf(UnitName) = -1 then
  begin
    TKernel(kernel).AddModule(UnitName, ALanguageName);
    TKernel(kernel).AddCodeFromFile(UnitName, FileName);
  end;
end;

function TBaseParser.GetValue(id: Integer): Variant;
begin
  result := TKernel(kernel).SymbolTable[id].Value;
end;

procedure TBaseParser.BeginInitialization;
begin
  Gen(OP_STMT, 0, 0, 0);
  Gen(OP_BEGIN_INITIALIZATION, CurrModule.ModuleNumber, 0, 0);
end;

procedure TBaseParser.EndInitialization;
begin
  Gen(OP_STMT, 0, 0, 0);
  Gen(OP_END_INITIALIZATION, CurrModule.ModuleNumber, 0, 0);
end;

procedure TBaseParser.BeginFinalization;
begin
  Gen(OP_STMT, 0, 0, 0);
  Gen(OP_BEGIN_FINALIZATION, CurrModule.ModuleNumber, 0, 0);
end;

procedure TBaseParser.EndFinalization;
begin
  Gen(OP_STMT, 0, 0, 0);
  Gen(OP_END_FINALIZATION, CurrModule.ModuleNumber, 0, 0);
end;

function TBaseParser.GetRaiseMode: Integer;
var
  Code: TCode;
  I: Integer;
begin
  Code := TKernel(kernel).Code;
  result := 0;
  for I:=Code.Card downto 1 do
    if Code[I].Op = OP_EXCEPT then
    begin
      result := 1;
      Exit;
    end
    else if Code[I].Op = OP_FINALLY then
    begin
      result := 1;
      Exit;
    end
    else if Code[I].Op = OP_TRY_ON then
      break
    else if Code[I].Op = OP_TRY_OFF then
      break;
end;

function TBaseParser.Lookup(const S: String; Level: Integer): Integer;
begin
  result := TKernel(kernel).SymbolTable.LookUp(S, Level, UpCase);
end;

function TBaseParser.Lookups(const S: String; Levels: TIntegerStack): Integer;
begin
  result := TKernel(kernel).SymbolTable.LookUps(S, Levels, UpCase);
end;

procedure TBaseParser.SetVisibility(Id: Integer; vis: TClassVisibility);
begin
  TKernel(kernel).SymbolTable[id].Vis := vis;
end;

procedure TBaseParser.SetReadId(PropId, ReadId: Integer);
begin
  TKernel(kernel).SymbolTable[PropId].ReadId := ReadId;
end;

procedure TBaseParser.SetWriteId(PropId, WriteId: Integer);
begin
  TKernel(kernel).SymbolTable[PropId].WriteId := WriteId;
end;

procedure TBaseParser.SetDefault(Id: Integer; value: Boolean);
begin
  TKernel(kernel).SymbolTable[Id].IsDefault := value;
end;

procedure TBaseParser.RemoveInstruction(Op, Arg1, Arg2, Res: Integer);
begin
  TKernel(kernel).Code.RemoveInstruction(Op, Arg1, Arg2, Res);
end;

function TBaseParser.LastCodeRec: TCodeRec;
var
  Code: TCode;
  I: Integer;
begin
  Code := TKernel(kernel).Code;
  I := Code.Card;
  while Code[I].Op = OP_SEPARATOR do
    Dec(I);
  result := Code[I];
end;

function TBaseParser.LastEvalRec(Id: Integer): TCodeRec;
var
  Code: TCode;
  I: Integer;
begin
  result := LastCodeRec;
  if result.Op = OP_EVAL then
    if result.Res = Id then
      Exit;
  Code := TKernel(kernel).Code;
  I := Code.Card;
  result := nil;
  repeat
    Dec(I);
    if I <= 1 then
      Exit;
    if Code[I].Op = OP_SEPARATOR then
      Exit;
    if Code[I].Op = OP_EVAL then
      if Code[I].Res = Id then
      begin
        result := Code[I];
        Exit;
      end;
  until false;
end;

function TBaseParser.LookupForwardDeclarations(Id: Integer): TIntegerList;
begin
  result := TKernel(kernel).SymbolTable.LookupForwardDeclarations(Id, Upcase);
end;

procedure TBaseParser.Push_SCANNER;
begin
  scanner.Push;
end;

procedure TBaseParser.Pop_SCANNER;
begin
  scanner.Pop;
end;

function TBaseParser.FindConstructorId(ClassId: Integer): Integer;
begin
  result := TKernel(kernel).SymbolTable.FindConstructorId(ClassId);
end;

function TBaseParser.FindDestructorId(ClassId: Integer): Integer;
begin
  result := TKernel(kernel).SymbolTable.FindDestructorId(ClassId);
end;

function TBaseParser.IsStringConst(Id: Integer): Boolean;
var
  Code: TCode;
  I: Integer;
begin
  result := (GetKind(Id) = KindCONST) and
    TKernel(kernel).SymbolTable[Id].HasPAnsiCharType or
    TKernel(kernel).SymbolTable[Id].HasPWideCharType;

  if not result then
  begin
    Code := TKernel(kernel).Code;
    for I:=1 to Code.Card do
      if Code[I].Op = OP_ASSIGN_CONST then
      if Code[I].Arg1 = Id then
      begin
        result := IsStringConst(Code[I].Arg2);
        break;
      end;
  end;
end;

procedure TBaseParser.SetHost(Id: Integer; value: Boolean);
begin
  TKernel(kernel).SymbolTable[Id].Host := value;
end;

function TBaseParser.GetHost(Id: Integer): Boolean;
begin
  result := TKernel(kernel).SymbolTable[Id].Host;
end;

procedure TBaseParser.SetAlignment(TypeId, Value: Integer);
begin
  TKernel(kernel).SymbolTable[TypeId].DefaultAlignment := Value;
end;

procedure TBaseParser.SetCompletionTarget(const S: String);
begin
  TKernel(kernel).CompletionTarget := S;
end;

function TBaseParser.GetStCard: Integer;
begin
  result := TKernel(kernel).SymbolTable.Card;
end;

procedure TBaseParser.SetOpenArray(ID: Integer; value: Boolean);
begin
  TKernel(kernel).SymbolTable[ID].IsOpenArray := value;
end;

procedure TBaseParser.DiscardLastSTRecord;
begin
  if CurrToken.Id = StCard then
  with TKernel(kernel).SymbolTable[TKernel(kernel).SymbolTable.Card] do
  begin
    Kind := kindNONE;
    Name := '';
  end;
end;

function TBaseParser.GetSymbolRec(Id: Integer): TSymbolRec;
begin
  result := TKernel(kernel).SymbolTable[Id];
end;

procedure TBaseParser.InitScanner(const S: String);
begin
  scanner.Init(kernel, S, -1);
end;

function TBaseParser.GetTrueId: Integer;
begin
  result := TKernel(kernel).SymbolTable.TrueId;
end;

function TBaseParser.GetFalseId: Integer;
begin
  result := TKernel(kernel).SymbolTable.FalseId;
end;

function TBaseParser.GetCodeCard: Integer;
begin
  result := TKernel(kernel).Code.Card;
end;

function TBaseParser.GetCodeRec(I: Integer): TCodeRec;
begin
  result := TKernel(kernel).Code[I];
end;

function TBaseParser.CurrNamespaceId: Integer;
begin
  result := CurrLevel;
  if result = 0 then
    Exit;
  while GetSymbolRec(result).Kind <> kindNAMESPACE do
  begin
    result := GetSymbolRec(result).Level;
    if result = 0 then
      break;
  end;
end;

function TBaseParser.CreateParser(const FileName: String): TBaseParser;
var
  Parser: TBaseParser;
  Ext: String;
  P: Integer;
  C: TBaseParserClass;
begin
  Parser := nil;
  P := PosCh('.', FileName);
  if P > 0 then
  begin
    Ext := Copy(FileName, P + 1, 10);
    Parser := TKernel(kernel).ParserList.FindParserByFileExtension(Ext);
  end;
  if Parser = nil then
    RaiseError(errUnregisteredLanguage, [FileName]);
  C := TBaseParserClass(Parser.ClassType);
  result := C.Create;
end;

procedure TBaseParser.Parse_Unit(IsExternalUnit: Boolean = false);
begin
end;

function TBaseParser.BuildingAll: Boolean;
var
  RootKernel: TKernel;
begin
  RootKernel := Kernel;
  while RootKernel.PCUOwner <> nil do
    RootKernel := RootKernel.PCUOwner;
  result := RootKernel.BuildAll;
end;

procedure TBaseParser.SetExternal(Id: Integer; value: Boolean);
begin
  GetSymbolRec(Id).IsExternal := value;
end;

procedure TBaseParser.SetTempName(Id: Integer);
begin
  SetName(Id, '_temp_' + IntToStr(id));
end;

end.
