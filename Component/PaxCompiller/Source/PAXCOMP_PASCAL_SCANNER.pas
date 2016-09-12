////////////////////////////////////////////////////////////////////////////
// PaxCompiler
// Site: http://www.paxcompiler.com
// Author: Alexander Baranovsky (paxscript@gmail.com)
// ========================================================================
// Copyright (c) Alexander Baranovsky, 2006-2008. All rights reserved.
// Code Version: 2.4
// ========================================================================
// Unit: PAXCOMP_PASCAL_SCANNER.pas
// ========================================================================
////////////////////////////////////////////////////////////////////////////

{$I PaxCompiler.def}
unit PAXCOMP_PASCAL_SCANNER;
interface
uses
  SysUtils,
  PAXCOMP_CONSTANTS,
  PAXCOMP_SYS,
  PAXCOMP_SCANNER;

type
  TPascalScanner = class(TBaseScanner)
    procedure ScanCharLiteral;
    procedure ReadCustomToken; override;
  end;

implementation

procedure TPascalScanner.ScanCharLiteral;
begin
  GetNextChar; // #
  ScanHexDigits;
  Token.TokenClass := tcCharConst;
  Token.Tag := 1;
end;

procedure TPascalScanner.ReadCustomToken;
var
  c: Char;
  S: String;
begin
  repeat
    GetNextChar;
    c := LA(0);
    Token.Position := Position;
    if IsWhiteSpace(c) then
    begin
      continue;
    end
    else if c = #13 then
      ScanSeparator
    else if IsEOF(c) then
      ScanEOF
    else if IsEOF then
      ScanEOF
    else if IsAlpha(c) then
    begin
      ScanIdentifier;

      token.Length := Position - token.Position + 1;

      S := Token.Text;

      if StrEql(S, 'in') then
      begin
        ScanSpecial;
        Token.Id := OP_SET_MEMBERSHIP;
      end
      else if StrEql(S, 'div') then
      begin
        ScanSpecial;
        Token.Id := OP_IDIV;
      end
      else if StrEql(S, 'mod') then
      begin
        ScanSpecial;
        Token.Id := OP_MOD;
      end
      else if StrEql(S, 'shl') then
      begin
        ScanSpecial;
        Token.Id := OP_SHL;
      end
      else if StrEql(S, 'shr') then
      begin
        ScanSpecial;
        Token.Id := OP_SHR;
      end
      else if StrEql(S, 'and') then
      begin
        ScanSpecial;
        Token.Id := OP_AND;
      end
      else if StrEql(S, 'or') then
      begin
        ScanSpecial;
        Token.Id := OP_OR;
      end
      else if StrEql(S, 'xor') then
      begin
        ScanSpecial;
        Token.Id := OP_XOR;
      end
      else if StrEql(S, 'not') then
      begin
        ScanSpecial;
        Token.Id := OP_NOT;
      end
      else if StrEql(S, 'is') then
      begin
        ScanSpecial;
        Token.Id := OP_IS;
      end
      else if StrEql(S, 'as') then
      begin
        ScanSpecial;
        Token.Id := OP_AS;
      end;

    end
    else if IsDigit(c) then
      ScanNumberLiteral
    else if c = '$' then
      ScanHexLiteral
    else if c = CHAR_AP then
      ScanStringLiteral(CHAR_AP)
    else if c = '+' then
    begin
      ScanSpecial;
      Token.Id := OP_PLUS;
    end
    else if c = '-' then
    begin
      ScanSpecial;
      Token.Id := OP_MINUS;
    end
    else if c = '*' then
    begin
      ScanSpecial;
      Token.Id := OP_MULT;
    end
    else if c = '/' then
    begin
      if LA(1) = '/' then
      begin
        ScanSingleLineComment();
				continue;
      end
      else
      begin
        ScanSpecial;
        Token.Id := OP_DIV;
      end;
    end
    else if c = '=' then
    begin
      ScanSpecial;
      Token.Id := OP_EQ;
    end
    else if c = '<' then
    begin
      ScanSpecial;
      if LA(1) = '=' then
      begin
        GetNextChar;
        ScanSpecial;
        Token.Id := OP_LE;
      end
      else if LA(1) = '>' then
      begin
        GetNextChar;
        ScanSpecial;
        Token.Id := OP_NE;
      end
      else
        Token.Id := OP_LT;
    end
    else if c = '>' then
    begin
      ScanSpecial;
      if LA(1) = '=' then
      begin
        GetNextChar;
        ScanSpecial;
        Token.Id := OP_GE;
      end
      else
        Token.Id := OP_GT;
    end
    else if c = ':' then
    begin
      ScanSpecial;
      if LA(1) = '=' then
      begin
        GetNextChar;
        ScanSpecial;
        Token.Id := OP_ASSIGN;
      end;
    end
    else if c = ',' then
      ScanSpecial
    else if c = '.' then
    begin
      if LA(1) = '.' then
        GetNextChar;
      ScanSpecial;
    end
    else if c = '#' then
      ScanCharLiteral
    else if c = '(' then
    begin
      if LA(1) = '*' then
      begin
        repeat
          GetNextChar;
          c := LA(0);
          if CharInSet(c, [#10,#13]) then
          begin
            Inc(LineCount);
            GenSeparator;
            if c = #13 then
              GetNextChar;
          end;
        until CharInSet(LA(1), ['*', CHAR_EOF]) and CharInSet(LA(2), [')', CHAR_EOF]);
        GetNextChar;
        GetNextChar;
      end
      else
        ScanSpecial;
    end
    else if c = ')' then
      ScanSpecial
    else if c = '[' then
      ScanSpecial
    else if c = ']' then
      ScanSpecial
    else if c = '^' then
      ScanSpecial
    else if c = '@' then
      ScanSpecial
    else if c = ':' then
      ScanSpecial
    else if c = ';' then
      ScanSpecial
    else if c = '{' then
    begin
      if LA(1) = '$' then
      begin

        if (not LookForward) then
        begin
          ScanCondDir('{', ['$']);
          Token.TokenClass := tcNone;
          continue;
        end;

        GetNextChar;
        if CharInSet(LA(1), ['b', 'B']) then
        begin
          GetNextChar;
          if LA(1) = '+' then
          begin
            GetNextChar;
            SetCompleteBooleanEval(true);
          end
          else if LA(1) = '-' then
          begin
            GetNextChar;
            SetCompleteBooleanEval(false);
          end;
        end
        else if CharInSet(LA(1), ['a', 'A']) then
        begin
          GetNextChar;
          if LA(1) = '1' then
          begin
            GetNextChar;
            SetAlignment(1);
          end
          else if LA(1) = '2' then
          begin
            GetNextChar;
            SetAlignment(2);
          end
          else if LA(1) = '4' then
          begin
            GetNextChar;
            SetAlignment(4);
          end
          else if LA(1) = '8' then
          begin
            GetNextChar;
            SetAlignment(8);
          end
          else if LA(1) = '-' then
          begin
            GetNextChar;
            SetAlignment(1);
          end
          else
            RaiseError(errInvalidCompilerDirective, []);
        end;

      end;

      if LA(1) = '}' then
      begin
        GetNextChar;
        continue;
      end;

      repeat
        GetNextChar;

        if IsEOF then
          break;

        c := LA(0);
        if CharInSet(c, [#10,#13]) then
        begin
          Inc(LineCount);
          GenSeparator;
          if c = #13 then
            GetNextChar;
        end;
      until LA(1) = '}';
      GetNextChar;
    end
    else if c = #254 then
    begin
      raise PaxCancelException.Create(CancelChar);
    end
    else
      RaiseError(errSyntaxError, []);
  until Token.TokenClass <> tcNone;
end;

end.
