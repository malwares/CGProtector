////////////////////////////////////////////////////////////////////////////
// PaxCompiler
// Site: http://www.paxcompiler.com
// Author: Alexander Baranovsky (paxscript@gmail.com)
// ========================================================================
// Copyright (c) Alexander Baranovsky, 2006-2008. All rights reserved.
// Code Version: 2.4
// ========================================================================
// Unit: PAXCOMP_SCANNER.pas
// ========================================================================
////////////////////////////////////////////////////////////////////////////

{$I PaxCompiler.def}
unit PAXCOMP_SCANNER;
interface
uses
  SysUtils,
  Classes,
  PAXCOMP_CONSTANTS,
  PAXCOMP_SYS;

const
  _IFDEF = 1;
  _IFNDEF = 2;
  _ELSE = 3;
  _ENDIF = 4;

type
  TBaseScanner = class;

  TDefRec = class
  public
    Word: Integer;
    What: String;
    Vis: boolean;
  end;

  TDefStack = class
  private
    fItems: TList;
    function GetItem(I: Integer): TDefRec;
    function GetCount: Integer;
  public
    constructor Create;
    destructor Destroy; override;
    procedure Clear;
    procedure Push(Word: Integer; What: String; Vis: Boolean);
    procedure Pop;
    property Count: Integer read GetCount;
    property Items[I: Integer]: TDefRec read GetItem; default;
  end;

  TToken = class
  private
    scanner: TBaseScanner;
    function GetText: String;
  public
    TokenClass: TTokenClass;
    Position: Integer;
    Length: Integer;
    Id: Integer;
    Tag: Integer;
    constructor Create(i_scanner: TBaseScanner);
    procedure Push(StateStack: TIntegerStack);
    procedure Pop(StateStack: TIntegerStack);
    property Text: String read GetText;
  end;

  TScannerRec = class
  private
    LineCount: Integer;
    P: Integer;
    Buff: String;
  end;

  TScannerStack = class
  private
    fItems: TList;
    function GetItem(I: Integer): TScannerRec;
  public
    constructor Create;
    destructor Destroy; override;
    procedure Clear;
    function Count: Integer;
    procedure Push(Scanner: TBaseScanner);
    procedure Pop(Scanner: TBaseScanner);
    property Items[I: Integer]: TScannerRec read GetItem; default;
  end;

  TBaseScanner = class
  private
    kernel: Pointer;
    StateStack: TIntegerStack;
    DefStack: TDefStack;
    p: Integer;
    function GetLinePos: Integer;
  public
    Token: TToken;
    Buff: String;
    LineCount: Integer;
    LookForward: Boolean;
    ScannerStack: TScannerStack;
    CancelPos: Integer;
    CancelChar: Char;
    constructor Create;
    destructor Destroy; override;
    procedure Init(i_kernel: Pointer;
                   const SourceCode: string;
                   i_CancelPos: Integer);
    procedure GenSeparator;
    function LA(N: Integer): Char;
    procedure GetNextChar;
    function IsNewLine: Boolean;
    function IsEOF: Boolean; overload;
    class function IsEOF(c: Char): Boolean; overload;
    class function IsAlpha(c: Char): Boolean;
    class function IsAlphaEx(c: Char): Boolean;
    class function IsDigit(c: Char): Boolean;
    class function IsHexDigit(c: Char): Boolean;
    class function IsWhiteSpace(c: Char): Boolean;
    procedure ScanEOF;
    procedure ScanSpecial;
    procedure ScanSeparator;
    procedure ScanIdentifier;
    procedure ScanNumberLiteral;
    procedure ScanHexLiteral;
    procedure ScanStringLiteral(ch: Char);
    procedure ScanDigits;
    procedure ScanHexDigits;
    procedure ScanSingleLineComment;
    procedure ReadToken;
    procedure ReadCustomToken; virtual; abstract;
    procedure RaiseError(const Message: string; params: array of Const);
    procedure CreateError(const Message: string; params: array of Const);
    procedure Push;
    procedure Pop;
    procedure SetCompleteBooleanEval(value: Boolean);
    procedure SetOverflowCheck(value: Boolean);
    procedure SetAlignment(value: Integer);
    procedure ScanCondDir(Start1: Char;
                          Start2: TCharSet);
    property Position: Integer read p;
    property LinePos: Integer read GetLinePos;
    property LookAhead[N: Integer]: Char read LA; default;
  end;

implementation

uses
  PAXCOMP_KERNEL,
  PAXCOMP_BYTECODE;

//--- TDefStack ----------------------------------------------------------------

constructor TDefStack.Create;
begin
  fItems := TList.Create;
end;

destructor TDefStack.Destroy;
begin
  Clear;
  fItems.Free;
  inherited;
end;

procedure TDefStack.Clear;
begin
  while Count > 0 do
    Pop;
end;

function TDefStack.GetCount: Integer;
begin
  result := fItems.Count;
end;

function TDefStack.GetItem(I: Integer): TDefRec;
begin
  result := TDefRec(fItems[I - 1]);
end;

procedure TDefStack.Push(Word: Integer; What: String; Vis: Boolean);
var
  R: TDefRec;
begin
  R := TDefRec.Create;
  R.Word := Word;
  R.What := What;
  R.Vis := Vis;
  fItems.Add(R);
end;

procedure TDefStack.Pop;
var
  R: TDefRec;
begin
  R := fItems[Count - 1];
  fItems.Delete(Count - 1);
  R.Free;
end;

//------- TToken ---------------------------------------------------------------

constructor TToken.Create(i_scanner: TBaseScanner);
begin
  Self.scanner := i_scanner;
  Length := 0;
  Id := 0;
  Tag := 0;
end;

function TToken.GetText: String;
begin
  result := Copy(scanner.Buff, Position, Length);
end;

procedure TToken.Push(StateStack: TIntegerStack);
begin
  StateStack.Push(Integer(TokenClass));
  StateStack.Push(Position);
  StateStack.Push(Length);
  StateStack.Push(Id);
  StateStack.Push(Tag);
end;

procedure TToken.Pop(StateStack: TIntegerStack);
begin
  Tag := StateStack.Pop;
  Id := StateStack.Pop;
  Length := StateStack.Pop;
  Position := StateStack.Pop;
  TokenClass := TTokenClass(StateStack.Pop);
end;

//------- TScannerStack ---------------------------------------------------------

constructor TScannerStack.Create;
begin
  inherited;

  fItems := TList.Create;
end;

destructor TScannerStack.Destroy;
begin
  Clear;
  fItems.Free;

  inherited;
end;

procedure TScannerStack.Clear;
begin
  while Count > 0 do
    Pop(nil);
end;

function TScannerStack.GetItem(I: Integer): TScannerRec;
begin
  result := TScannerRec(fItems[I - 1]);
end;

function TScannerStack.Count: Integer;
begin
  result := fItems.Count;
end;

procedure TScannerStack.Push(Scanner: TBaseScanner);
var
  R: TScannerRec;
begin
  R := TScannerRec.Create;

  R.LineCount := Scanner.LineCount;
  R.P := Scanner.P;
  R.Buff := Scanner.Buff;

  fItems.Add(R);
end;

procedure TScannerStack.Pop(Scanner: TBaseScanner);
var
  R: TScannerRec;
begin
  R := fItems[Count - 1];
  fItems.Delete(Count - 1);

  if Scanner <> nil then
  begin
    Scanner.LineCount := R.LineCount;
    Scanner.P := R.P;
    Scanner.Buff := R.Buff;
  end;

  R.Free;
end;

//------- TBaseScanner ---------------------------------------------------------

constructor TBaseScanner.Create;
begin
  inherited;

  p := 0;
  Buff := '';
  token := TToken.Create(Self);

  StateStack := TIntegerStack.Create;
  DefStack := TDefStack.Create;
  LookForward := false;

  ScannerStack := TScannerStack.Create;
  CancelPos := -1;
end;

destructor TBaseScanner.Destroy;
begin
  token.Free;
  StateStack.Free;
  DefStack.Free;
  ScannerStack.Free;

  inherited;
end;

procedure TBaseScanner.Init(i_kernel: Pointer;
                            const SourceCode: string;
                            i_CancelPos: Integer);
begin
  Self.kernel := i_kernel;
  Buff := SourceCode + CHAR_EOF;
  p := 0;
  LineCount := 0;
  StateStack.Clear;
  LookForward := false;
  ScannerStack.Clear;
  CancelPos := i_CancelPos;
end;

procedure TBaseScanner.GenSeparator;
begin
  with TKernel(kernel) do
    CurrParser.Gen(OP_SEPARATOR, CurrParser.CurrModule.ModuleNumber, LineCount, 0);
end;

function TBaseScanner.LA(N: Integer): Char;
begin
  result := Buff[p + N];
end;

procedure TBaseScanner.GetNextChar;
begin
  Inc(p);
  if P = CancelPos then
  begin
    CancelChar := Buff[P];
    case CancelChar of
      '.': Buff := Copy(Buff, 1, P) + DummyName +
                   CancelChar + #254;
      '(': Buff := Copy(Buff, 1, P) + DummyName + ')' +
                   CancelChar + #254;
    else
      RaiseError(errInternalError, []);
    end;
  end;
end;

class function TBaseScanner.IsEOF(c: Char): Boolean;
begin
  result := (c = CHAR_EOF);
end;

function TBaseScanner.IsEOF: Boolean;
begin
//  result := LA(0) = CHAR_EOF;
  result := P >= Length(Buff);
end;

function TBaseScanner.IsNewLine: Boolean;
begin
{$IFDEF UNIC}
  result := CharInSet(LA(0), [#13, #10]);
{$ELSE}
  result := LA(0) in [#13, #10];
{$ENDIF}
end;

class function TBaseScanner.IsAlpha(c: Char): Boolean;
begin
{$IFDEF UNIC}
  result := CharInSet(c, ['a'..'z', 'A'..'Z', '_']);
{$ELSE}
  result := c in ['a'..'z', 'A'..'Z', '_'];
{$ENDIF}
end;

class function TBaseScanner.IsAlphaEx(c: Char): Boolean;
begin
{$IFDEF UNIC}
  if CharInSet(c, ['e','E']) then
{$ELSE}
  if c in ['e','E'] then
{$ENDIF}
    result := false
  else
    result := IsAlpha(c);
end;

class function TBaseScanner.IsDigit(c: Char): Boolean;
begin
{$IFDEF UNIC}
  result := CharInSet(c, ['0'..'9']);
{$ELSE}
  result := c in ['0'..'9'];
{$ENDIF}
end;

class function TBaseScanner.IsHexDigit(c: Char): Boolean;
begin
{$IFDEF UNIC}
  result := CharInSet(c, ['0'..'9','A'..'F','a'..'f']);
{$ELSE}
  result := c in ['0'..'9','A'..'F','a'..'f'];
{$ENDIF}
end;

class function TBaseScanner.IsWhiteSpace(c: Char): Boolean;
begin
{$IFDEF UNIC}
  result := CharInSet(c, [' ', #8, #9, #11, #12]);
{$ELSE}
  result := c in [' ', #8, #9, #11, #12];
{$ENDIF}
end;

procedure TBaseScanner.ScanIdentifier;
begin
  while IsAlpha(LA(1)) or IsDigit(LA(1)) do
    GetNextChar;
  Token.TokenClass := tcIdentifier;
end;

procedure TBaseScanner.ScanDigits;
begin
  while IsDigit(LA(1)) do
    GetNextChar;
end;

procedure TBaseScanner.ScanHexDigits;
begin
  while IsHexDigit(LA(1)) do
    GetNextChar;
end;

procedure TBaseScanner.ScanNumberLiteral;
begin
  ScanDigits;
  Token.TokenClass := tcIntegerConst;

  if (LA(1) = '.') and (LA(2) <> '.') and (not IsAlphaEx(LA(2))) then
  begin
    GetNextChar();

{$IFDEF UNIC}
    if CharInSet(LA(1), ['0'..'9']) then
{$ELSE}
    if LA(1) in ['0'..'9'] then
{$ENDIF}
      ScanDigits;

{$IFDEF UNIC}
    if CharInSet(LA(1), ['e', 'E']) then
{$ELSE}
    if LA(1) in ['e', 'E'] then
{$ENDIF}
    begin
      GetNextChar();
{$IFDEF UNIC}
      if CharInSet(LA(1), ['+', '-']) then
{$ELSE}
      if LA(1) in ['+', '-'] then
{$ENDIF}
        GetNextChar();
      ScanDigits;
    end;

    Token.TokenClass := tcDoubleConst;
  end
  else if (LA(1) in ['e','E']) and (LA(2) in ['0'..'9','+','-']) then
  begin
    GetNextChar();
{$IFDEF UNIC}
    if CharInSet(LA(1), ['+', '-']) then
{$ELSE}
    if LA(1) in ['+', '-'] then
{$ENDIF}
      GetNextChar();
    ScanDigits;
    Token.TokenClass := tcDoubleConst;
  end;
end;

procedure TBaseScanner.ScanHexLiteral;
begin
  GetNextChar;
  ScanHexDigits;
  Token.TokenClass := tcIntegerConst;
end;

procedure TBaseScanner.ScanStringLiteral(ch: Char);
var
  K: Integer;
begin
  K := 0;
  GetNextChar;
  if (LA(0) = ch) and (LA(1) <> ch) then // empty string
  begin
    Token.TokenClass := tcPCharConst;
    Exit;
  end;

  repeat
     if IsEOF then
     begin
       RaiseError(errUnterminatedString, []);
       Exit;
     end;

     if (LA(0) = ch) and (LA(1) = ch) then
     begin
       GetNextChar;
       buff[p] := CHAR_REMOVE;
     end
     else if (LA(0) = ch) then
        break;

     GetNextChar;
     Inc(K);
  until false;

  if K = 1 then
    Token.TokenClass := tcCharConst
  else
    Token.TokenClass := tcPCharConst;
end;

procedure TBaseScanner.ScanSpecial;
begin
  Token.TokenClass := tcSpecial;
  Token.Id := 0;
end;

procedure TBaseScanner.ScanSeparator;
begin
  if LA(1) = #10 then
    GetNextChar;
  Token.TokenClass := tcSeparator;
  Inc(LineCount);
  Token.Id := LineCount;
end;

procedure TBaseScanner.ScanEOF;
begin
  if ScannerStack.Count > 0 then
  begin
    ScannerStack.Pop(Self);
    Exit;
  end;

  Token.TokenClass := tcSpecial;
  Token.Id := 0;
end;

procedure TBaseScanner.ReadToken;
begin
  token.TokenClass := tcNone;
  token.Position := p;
  ReadCustomToken;
  token.Length := p - token.Position + 1;
end;

procedure TBaseScanner.ScanSingleLineComment;
begin
  repeat
    if IsEOF then
      break;
    GetNextChar;

{$IFDEF UNIC}
  until CharInSet(LA(1), [#13, #10]);
{$ELSE}
  until LA(1) in [#13, #10];
{$ENDIF}
end;

procedure TBaseScanner.RaiseError(const Message: string; params: array of Const);
begin
  TKernel(kernel).Code.N := TKernel(kernel).Code.Card;
  TKernel(kernel).RaiseError(Message, params);
end;

procedure TBaseScanner.CreateError(const Message: string; params: array of Const);
begin
  TKernel(kernel).CreateError(Message, params);
end;

procedure TBaseScanner.Push;
begin
  StateStack.Push(p);
  StateStack.Push(LineCount);

  Token.Push(StateStack);
end;

procedure TBaseScanner.Pop;
begin
  Token.Pop(StateStack);

  LineCount := StateStack.Pop;
  p := StateStack.Pop;
end;

procedure TBaseScanner.SetCompleteBooleanEval(value: Boolean);
begin
  TKernel(kernel).CurrParser.CompleteBooleanEval := value;
end;

procedure TBaseScanner.SetOverflowCheck(value: Boolean);
begin
  if value then
    TKernel(kernel).CurrParser.Gen(OP_OVERFLOW_CHECK, 1, 0, 0)
  else
    TKernel(kernel).CurrParser.Gen(OP_OVERFLOW_CHECK, 0, 0, 0);
end;

procedure TBaseScanner.SetAlignment(value: Integer);
begin
  TKernel(kernel).CurrParser.Alignment := value;
end;

procedure TBaseScanner.ScanCondDir(Start1: Char;
                                   Start2: TCharSet);

  procedure ScanChars(CSet: TCharSet);
  begin
    Token.Position := P;
{$IFDEF UNIC}
    while CharInSet(LA(1), CSet) do
{$ELSE}
    while LA(1) in CSet do
{$ENDIF}
      GetNextChar;

    token.Length := p - token.Position + 1;
    Token.TokenClass := tcIdentifier;
  end;


label
  NextComment, Fin;
const
  IdsSet = ['a'..'z','A'..'Z','0'..'9','_'];
var
  S: String;
  I, J, J1, J2: Integer;
  Visible: Boolean;
  FileName, DirName: String;
  ok: Boolean;
begin
  GetNextChar; // skip $

  DirName := '';

{$IFDEF UNIC}
  if CharInSet(LA(1), ['b','B']) and CharInSet(LA(2), ['+','-']) then
{$ELSE}
  if (LA(1) in ['b','B']) and (LA(2) in ['+','-']) then
{$ENDIF}
  begin
    DirName := LA(1);

    GetNextChar;
    if LA(1) = '+' then
    begin
      DirName := DirName + LA(1);

      GetNextChar;
      SetCompleteBooleanEval(true);
    end
    else if LA(1) = '-' then
    begin
      DirName := DirName + LA(1);

      GetNextChar;
      SetCompleteBooleanEval(false);
    end;

    if LA(1) = '}' then
      GetNextChar
    else
      Self.RaiseError(errInvalidCompilerDirective, [DirName]);

    Exit;
  end;

  if CharInSet(LA(1),['q','Q']) and CharInSet(LA(2), ['+','-']) then
  begin
    DirName := LA(1);

    GetNextChar;
    if LA(1) = '+' then
    begin
      DirName := DirName + LA(1);

      GetNextChar;
      SetOverflowCheck(true);
    end
    else if LA(1) = '-' then
    begin
      DirName := DirName + LA(1);

      GetNextChar;
      SetOverflowCheck(false);
    end;

    if LA(1) = '}' then
      GetNextChar
    else
      Self.RaiseError(errInvalidCompilerDirective, [DirName]);

    Exit;
  end;

  if CharInSet(LA(1), ['a', 'A']) and CharInSet(LA(2), ['1', '2', '4', '8', '-']) then
  begin
    DirName := LA(1);

    GetNextChar;
    if LA(1) = '1' then
    begin
      DirName := DirName + LA(1);

      GetNextChar;
      SetAlignment(1);
    end
    else if LA(1) = '2' then
    begin
      DirName := DirName + LA(1);

      GetNextChar;
      SetAlignment(2);
    end
    else if LA(1) = '4' then
    begin
      DirName := DirName + LA(1);

      GetNextChar;
      SetAlignment(4);
    end
    else if LA(1) = '8' then
    begin
      DirName := DirName + LA(1);

      GetNextChar;
      SetAlignment(8);
    end
    else if LA(1) = '-' then
    begin
      DirName := DirName + LA(1);

      GetNextChar;
      SetAlignment(1);
    end;

    if LA(1) = '}' then
      GetNextChar
    else
      Self.RaiseError(errInvalidCompilerDirective, [DirName]);

    Exit;
  end;

  Visible := true;

NextComment:

  S := '';
  repeat
    GetNextChar;
    S := S + LA(0);
    if CharInSet(LA(0), [#10,#13]) then
    begin
      Inc(LineCount);

      if LA(0) = #13 then
        GetNextChar;
    end;
  until not CharInSet(LA(0), (IdsSet + Start2));

  I := Pos('INCLUDE ', UpperCase(S) + ' ');
  if I = 0 then
    I := Pos('I ', UpperCase(S));

  DirName := RemoveChars([' ', #8, #9, '}'], S);

  if I > 0 then
  begin
    while not CharInSet(LA(0), IdsSet) do GetNextChar;

    ScanChars(['A'..'Z', 'a'..'z', '0'..'9', '_']);

    FileName := Token.Text;
    if LA(1) = '.' then
    begin
      GetNextChar;

      ScanChars(['A'..'Z', 'a'..'z', '0'..'9', '_']);

      FileName := FileName + Token.Text;
    end;

    if Assigned(TKernel(kernel).OnInclude) then
    begin
      S := '';
      TKernel(kernel).OnInclude(TKernel(kernel).Owner, FileName, S);
    end
    else
    begin
      if Pos('.', FileName) = 0 then
        if TKernel(kernel).CurrParser.GetIncludedFileExt <> '' then
          FileName := FileName + '.' + TKernel(kernel).CurrParser.GetIncludedFileExt;

      S := TKernel(kernel).FindFullName(FileName);

      if S = '' then
        Self.RaiseError(errFileNotFound, [FileName])
      else
      begin
        FileName := S;
        S := LoadText(FileName);
      end;
    end;

    if LA(1) = '}' then
      GetNextChar;

    if S = '' then
      Exit;

    ScannerStack.Push(Self);

    P := 0;
    Buff := S + CHAR_EOF;
    LineCount := 0;

    Exit;
  end;

  I := Pos('DEFINE ', UpperCase(S) + ' ');
  if I > 0 then
  begin
    while not CharInSet(LA(0), IdsSet) do
      GetNextChar;

    ScanChars(['A'..'Z', 'a'..'z', '0'..'9', '_', '.', '-', '[', ']', '(', ')', ',', ' ']);

    DirName := Token.Text;

    TKernel(kernel).DefList.Add(DirName);

    with TKernel(kernel) do
      if Assigned(OnDefineDirective) then
      begin
        ok := true;
        OnDefineDirective(Owner, DirName, ok);
        if not ok then
          Self.RaiseError(errInvalidCompilerDirective, [DirName]);
      end;

    if LA(1) = '}' then
      GetNextChar;

    Exit;
  end;

{
  I := Pos('EXTERNALSYM ', UpperCase(S) + ' ');
  if I > 0 then
  begin
    while not (LA(0) in IdsSet) do
      GetNextChar;
    ScanChars(['A'..'Z', 'a'..'z', '0'..'9', '_', '.', '-', '[', ']', '(', ')', ',', ' ']);
    DirName := Token.Text;

    if DirName = 'version' then
      writeln;

    TKernel(kernel).ExternalSymList.Add(DirName);
}
//    if LA(1) = '}' then
//      GetNextChar;
//    Exit;
//  end;

  I := Pos('UNDEF ', UpperCase(S) + ' ');
  if I > 0 then
  begin
    while not CharInSet(LA(0), IdsSet) do GetNextChar;

    ScanChars(['A'..'Z', 'a'..'z', '0'..'9', '_', '.', '-', '[', ']', '(', ')', ',', ' ']);

    DirName := Token.Text;

    I := TKernel(kernel).DefList.IndexOf(DirName);
    if I <> -1 then
      TKernel(kernel).DefList.Delete(I);

    with TKernel(kernel) do
      if Assigned(OnUndefineDirective) then
      begin
        ok := true;
        OnUndefineDirective(Owner, DirName, ok);
        if not ok then
          Self.RaiseError(errInvalidCompilerDirective, [DirName]);
      end;

    if LA(1) = '}' then
      GetNextChar;

    Exit;
  end;

  I := Pos('IFDEF ', UpperCase(S) + ' ');

  if I > 0 then
  begin
    while not CharInSet(LA(0), IdsSet) do GetNextChar;

    ScanChars(['A'..'Z', 'a'..'z', '0'..'9', '_', '.', '-', '[', ']', '(', ')', ',', ' ']);

    Visible := TKernel(kernel).DefList.IndexOf(Token.Text) <> -1;
    DefStack.Push(_IFDEF, Token.Text, Visible);

    if Visible then
      for I := DefStack.Count - 1 downto 1 do
        if DefStack[I].Word in [_IFDEF, _IFNDEF] then
        begin
          Visible := DefStack[I].Vis;
          Break;
        end;

    if LA(1) = '}' then
      GetNextChar;

    goto Fin;
  end;

  I := Pos('IFNDEF ', UpperCase(S) + ' ');
  if I > 0 then
  begin
    while not CharInSet(LA(0), IdsSet) do GetNextChar;

    ScanChars(['A'..'Z', 'a'..'z', '0'..'9', '_', '.', '-', '[', ']', '(', ')', ',']);

    Visible := TKernel(kernel).DefList.IndexOf(Token.Text) = -1;
    DefStack.Push(_IFNDEF, Token.Text, Visible);

    if Visible then
      for I := DefStack.Count - 1 downto 1 do
        if DefStack[I].Word in [_IFDEF, _IFNDEF] then
        begin
          Visible := DefStack[I].Vis;
          Break;
        end;

    if LA(1) = '}' then
      GetNextChar;

    goto Fin;
  end;

  I := Pos('ELSE ', UpperCase(S) + ' ');
  if I = 0 then
    I := Pos('ELSE}', UpperCase(S) + '}');

  if I > 0 then
  begin
    if LA(1) = '}' then
      GetNextChar;

    DefStack.Push(_ELSE, '', Visible);

    I := DefStack.Count - 1;
    if I <= 0 then
      Self.RaiseError(errInvalidCompilerDirective, ['']);

    if DefStack[I].Word in [_IFDEF, _IFNDEF] then
    begin
      DefStack[DefStack.Count].What := DefStack[I].What;
      DefStack[DefStack.Count].Vis := not DefStack[I].Vis;

      Visible := DefStack[DefStack.Count].Vis;
      if Visible then
        for J:=I - 1 downto 1 do
          if DefStack[J].Word in [_IFDEF, _IFNDEF] then
          begin
            Visible := DefStack[J].Vis;
            Break;
          end;
    end
    else
      Self.RaiseError(errInvalidCompilerDirective, ['']);

    goto Fin;
  end;

  I := Pos('ENDIF ', UpperCase(S) + ' ');
  if I = 0 then
    I := Pos('ENDIF}', UpperCase(S) + '}');

  if I > 0 then
  begin
    if LA(1) = '}' then
      GetNextChar;

    J1 := 0;
    J2 := 0;
    for I := DefStack.Count downto 1 do
      if DefStack[I].Word in [_IFDEF, _IFNDEF] then
        Inc(J1)
      else if DefStack[I].Word = _ENDIF then
        Inc(J2);
    if J2 >= J1 then
      Self.RaiseError(errInvalidCompilerDirective, ['']);

    for I:=DefStack.Count downto 1 do
      if DefStack[I].Word in [_IFDEF, _IFNDEF] then
      begin
        while DefStack.Count > I - 1 do
          DefStack.Pop;
        Break;
      end;
    if DefStack.Count = 0 then
      Visible := true
    else
      Visible := DefStack[DefStack.Count].Vis;

    goto Fin;
  end;

  with TKernel(kernel) do
    if Assigned(OnUnknownDirective) then
    begin
      ok := true;

      if LA(1) <> '}' then
      begin
        ScanChars(['A'..'Z', 'a'..'z', '0'..'9', ',', '_', '.', '-', '+', '[', ']', '(', ')', '*', '''', '"', ' ', '\', '/', ':']);

        if Token.Text <> '}' then
          DirName := DirName + ' ' + Token.Text;
      end;

      OnUnknownDirective(Owner, DirName, ok);
      if not ok then
        Self.RaiseError(errInvalidCompilerDirective, [DirName]);

      while LA(0) <> '}' do
        GetNextChar;
    end
  else
    Self.RaiseError(errInvalidCompilerDirective, [DirName]);

Fin:

  if not Visible then
  begin

    repeat
      GetNextChar;
      if CharInSet(LA(0), [#10,#13]) then
      begin
        Inc(LineCount);
        if LA(0) = #13 then
          GetNextChar;
      end;
    until ((LA(0) = Start1) and CharInSet(LA(1), Start2)) or IsEOF;

    if IsEOF then
      Self.RaiseError(errMissingENDIFdirective, []);

    goto NextComment;
  end;
end;

function TBaseScanner.GetLinePos: Integer;
var
  I: Integer;
begin
  I := P;
  result := P;

  if I = 0 then
    Exit;

  repeat
    if CharInSet(Buff[I], [#13, #10]) then
      Break
    else
      Dec(I);
  until I <= 0;
  result := P - I;

end;


end.
