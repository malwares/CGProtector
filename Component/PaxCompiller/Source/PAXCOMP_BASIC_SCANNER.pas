////////////////////////////////////////////////////////////////////////////
// PaxCompiler
// Site: http://www.paxcompiler.com
// Author: Alexander Baranovsky (paxscript@gmail.com)
// ========================================================================
// Copyright (c) Alexander Baranovsky, 2006-2007. All rights reserved.
// Code Version: 2.4
// ========================================================================
// Unit: PAXCOMP_BASIC_SCANNER.pas
// ========================================================================
////////////////////////////////////////////////////////////////////////////

{$I PaxCompiler.def}
unit PAXCOMP_BASIC_SCANNER;
interface
uses
  SysUtils,
  PAXCOMP_CONSTANTS,
  PAXCOMP_SYS,
  PAXCOMP_SCANNER,
  PAXCOMP_BYTECODE;

type
  TBasicScanner = class(TBaseScanner)
    procedure ReadCustomToken; override;
  end;

implementation

procedure TBasicScanner.ReadCustomToken;
var
  c: Char;
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
    else if c = #10 then
      ScanSeparator
    else if IsEOF(c) then
      ScanSpecial
    else if IsEOF then
      ScanEOF
    else if IsAlpha(c) then
      ScanIdentifier
    else if IsDigit(c) then
      ScanNumberLiteral
    else if c = CHAR_DOUBLE_AP then
      ScanStringLiteral(CHAR_DOUBLE_AP)
    else if c = CHAR_AP then
    begin
      ScanSingleLineComment();
  		continue;
    end
    else if c = '+' then
    begin
      ScanSpecial;
      if LA(1) = '=' then
      begin
        GetNextChar;
        ScanSpecial;
      end;
      Token.Id := OP_PLUS;
    end
    else if c = '-' then
    begin
      ScanSpecial;
      if LA(1) = '=' then
      begin
        GetNextChar;
        ScanSpecial;
      end;
      Token.Id := OP_MINUS;
    end
    else if c = '*' then
    begin
      ScanSpecial;
      if LA(1) = '=' then
      begin
        GetNextChar;
        ScanSpecial;
      end;
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
        if LA(1) = '=' then
        begin
          GetNextChar;
          ScanSpecial;
        end;
        Token.Id := OP_DIV;
      end;
    end
    else if c = '\' then
    begin
      ScanSpecial;
      if LA(1) = '=' then
      begin
        GetNextChar;
        ScanSpecial;
      end;
      Token.Id := OP_IDIV;
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
      ScanSpecial
    else if c = '(' then
      ScanSpecial
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
    else if c = '&' then
    begin
      c := LA(1);
      if c in ['h','H'] then
      begin
        GetNextChar;
        ScanHexLiteral;
      end
      else
        RaiseError(errSyntaxError, []);
    end
    else
      RaiseError(errSyntaxError, []);
  until Token.TokenClass <> tcNone;
end;

end.