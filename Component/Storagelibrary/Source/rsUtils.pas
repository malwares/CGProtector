{*******************************************************}
{                                                       }
{                Delphi VCL Extensions                  }
{                   Storage library                     }
{                                                       }
{         Copyright (c) 2000-2007 Deepsoftware          }
{                                                       }
{           www - http://www.deepsoftware.com           }
{              email - ray@deepsoftware.com             }
{                                                       }
{*******************************************************}
unit rsUtils;

interface

{$I rsStorage.inc}


uses Classes, SysUtils,
     {$IFDEF RSL_WIN}Windows,{$ENDIF}
     {$IFDEF RSL_KYLIX}QDialogs,{$ENDIF}
     {$IFDEF RSL_REALKYLIX}Libc, QControls,{$ENDIF}
     {$IFDEF RSL_AUTOLINKREFERENCES}
       {$IFDEF RSL_WIN}Forms,{$ENDIF}
       {$IFDEF RSL_KYLIX}QForms,{$ENDIF}
     {$ENDIF}
     rsConst;

{$IFDEF RSL_AUTOLINKREFERENCES}
type
  TrsFindComponentProc = procedure (Instance: TComponent) of object;

function rsGlobalFindComponent(const Value: TClass; StartOwner: TComponent; Proc: TrsFindComponentProc): TComponent;
{$ENDIF}

type
  TrsErrorGroup = (egGetKeyValue, egXMLParser, egSetKeyValue, egSearchPrepare, egSearch, egRegData);
  TrsException = class(Exception);

procedure rsError(const Group: TrsErrorGroup; const Msg: string);

function IsDigitValue(Value: PChar; const Count: integer): integer;

function HexStrToBinBuf(P: PAnsiChar; const Count: integer): AnsiString;
function BinBufToHexStr(P: PAnsiChar; const Count: integer): AnsiString;

function StrToBase64(P: PAnsiChar; const Count: integer): AnsiString;
function Base64ToStr(P: PAnsiChar; const Count: integer): AnsiString;

{$IFDEF RSL_WIN}
function RegReadString(Key: HKey; const Path,AName: string): string;
{$ENDIF}

function StringToHashInteger(const Value: string): integer;

function IsSectionSeparator(ch: RSLChar): boolean;
function GetNameBetweenSeparators(Value: RSLString; var Index: integer): RSLString;
function RSLCompareText(const Value1, Value2: RSLString): integer;
function RSLCompareStrLI(Value1, Value2: PRSLChar; MaxLen: Cardinal): integer;
function StrPosW(Str1, Str2: PWideChar): PWideChar;
function IsUnicodeString(const Value: RSLString): boolean;
function UpCaseW(Ch: WideChar): WideChar;
function IsHexStrW(P: PWideChar; const Count: integer): boolean;
function HexStrWToBinBuf(P: PWideChar; const Count: integer): AnsiString;
function IsDigitValueW(Value: PWideChar; const Count: integer): integer;
procedure SwapBytes(P: PWideChar);
function RSLQuoteStr(Value: RSLString): RSLString;

function RSLSameDateTime(const Value1,Value2: TDateTime): boolean;

function RSLDateTimeToXMLStr(Value: TDateTime): string;
function RSLXMLStrToDateTime(Value: string; var ADateTime: TDateTime): boolean;

procedure RslAbout;
{$IFDEF RSL_REALKYLIX}
function MessageBox(hWnd: cardinal; lpText, lpCaption: WideString; uType: integer): Integer;
procedure ShellExecute(h:integer; cmd,f:PChar; p1,p2:pointer; st:integer);
procedure ExitProcess(const ResCode: integer);

const
  { MessageBox() Flags }
  MB_OK                 = $00000000;
  MB_OKCANCEL           = $00000001;
  MB_ABORTRETRYIGNORE   = $00000002;
  MB_YESNOCANCEL        = $00000003;
  MB_YESNO              = $00000004;
  MB_RETRYCANCEL        = $00000005;
  MB_ICONHAND           = $00000010;
  MB_ICONQUESTION       = $00000020;
  MB_ICONEXCLAMATION    = $00000030;
  MB_ICONASTERISK       = $00000040;
  MB_USERICON           = $00000080;
  MB_ICONWARNING        = MB_ICONEXCLAMATION;
  MB_ICONERROR          = MB_ICONHAND;

{$IFDEF RSL_K2LE}
  mrYes			= 7;
{$ENDIF}
  IDYES                 = 1;
  SW_SHOWDEFAULT        = 0;
{$ENDIF}


var
  RSHexStrLineSeparator: AnsiString = CEOL; //#13#10;
  RSHexStrStartOffset: integer = 0;
  RSHexStrCompact: boolean = False;

implementation

{$IFDEF RSL_AUTOLINKREFERENCES}
function rsGlobalFindComponent(const Value: TClass; StartOwner: TComponent; Proc: TrsFindComponentProc): TComponent;

  function Find(Owner: TComponent): TComponent;
  var z: integer;
  begin
    Result := nil;
    with Owner do
      for z:=ComponentCount-1 downto 0 do
       if Components[z].InheritsFrom(Value) then begin
         Result := Components[z];
         if Assigned(Proc) then Proc(Result);
         Break;
       end;
  end;

var
  i: integer;
begin
  Result := nil;
  if StartOwner<>nil then begin
    Result := Find(StartOwner);
    if Result<>nil then Exit;
  end;

  for i:=Screen.FormCount-1 downto 0 do
    if Screen.Forms[i]<>StartOwner then begin
      Result := Find(Screen.Forms[i]);
      if Result<>nil then Exit;
    end;

  for i:=Screen.DataModuleCount-1 downto 0 do
    if Screen.DataModules[i]<>StartOwner then begin
      Result := Find(Screen.DataModules[i]);
      if Result<>nil then Exit;
    end;
end;
{$ENDIF}

function RSLSameDateTime(const Value1,Value2: TDateTime): boolean;
begin
  Result := Abs(Value1 - Value2) < (1/(24*3600*1000));
end;

function RSLDateTimeToXMLStr(Value: TDateTime): string;
var
  d,m,y, h,min,s,ms: word;
begin
  DecodeDate(Value, y,m,d);
  DecodeTime(Value, h,min,s,ms);
  Result := Format('%.4d-%.2d-%.2dT%.2d:%.2d:%.2d.%d',[y,m,d, h,min,s,ms]);
end;

function RSLXMLStrToDateTime(Value: string; var ADateTime: TDateTime): boolean;
var
  d,m,y, h,min,s,ms: smallint;
begin
  Result := False;
  y := StrToIntDef(Copy(Value, 1, 4), -1);
  if (y<0) or (Value[5]<>'-') then Exit;
  m := StrToIntDef(Copy(Value, 6, 2), -1);
  if (m<0) or (Value[8]<>'-') then Exit;
  d := StrToIntDef(Copy(Value, 9, 2), -1);
  if (d<0) or (Value[11]<>'T') then Exit;

  h   := StrToIntDef(Copy(Value, 12, 2), -1);
  if (h<0) or (Value[14]<>':') then Exit;
  min := StrToIntDef(Copy(Value, 15, 2), -1);
  if (min<0) or (Value[17]<>':') then Exit;
  s   := StrToIntDef(Copy(Value, 18, 2), -1);
  if (s<0) or (Value[20]<>'.') then Exit;
  ms  := StrToIntDef(Copy(Value, 21, Length(Value)-21+1), -1);
  if ms<0 then Exit;

  ADateTime := EncodeDate(y,m,d)+EncodeTime(h,min,s,ms);
  Result := True;
end;

procedure rsError(const Group: TrsErrorGroup; const Msg: string);
var
  s: string;
begin
  case Group of
    egXMLParser:   s := 'TrsXMLData parser error:';
    egGetKeyValue: s := 'TrsStorage get key value error:';
    egSetKeyValue: s := 'TrsStorage set key value error:';
    egSearchPrepare: s := 'TrsSearch prepare search error:';
    egSearch : s := 'TrsSearch error:';
    egRegData: s := 'TrsRegData error:';
    else s := 'Storage library error:';
  end;

  raise TrsException.Create(s+' '+Msg);
end;


//Result Value 0-not digit; 1-integer; 2-float; 3-int64;
function IsDigitValue(Value: PChar; const Count: integer): integer;
const
  HighInteger: PChar = '2147483647';
  LowInteger: PChar = '2147483648';
  HighInt64: PChar = '9223372036854775807';
  LowInt64: PChar = '9223372036854775808';
var
  P,PEnd: PChar;
  flSign,flDecSeparator: boolean;
begin
  Result := 0;
  flDecSeparator := False;
  flSign := False;
  P := Value;
  PEnd := P + Count;
  While P<PEnd do begin
    if P^ in [Char('0')..Char('9')] then Inc(Result)
     else
    if (P=Value) and (P^ in ['+','-']) then flSign := True
     else
    if (P^=DecimalSeparator) and (not flDecSeparator) then flDecSeparator := True
     else begin
       Result := 0;
       Exit;
     end;
    Inc(P);
  end;

 if Result>0 then begin
   if flDecSeparator then Result := 2
    else
   if Result<10 then Result := 1
    else
   if Result>19 then Result := 0
    else
   if Result>10 then begin
      if flSign then P := Value+1 else P := Value;
      if flSign and (Value^='-') then pEnd := LowInt64 else pEnd := HighInt64;
      if StrIComp(P,pEnd)<=0 then Result := 3 else Result := 0;
   end else begin
      if flSign then P := Value+1 else P := Value;
      if flSign and (Value^='-') then pEnd := LowInteger else pEnd := HighInteger;
      if StrIComp(P,pEnd)<=0 then Result := 1 else Result := 3;
    end;
 end;
end;

function IsDigitValueW(Value: PWideChar; const Count: integer): integer;
const
  HighInteger: PWideChar = '2147483647';
  LowInteger: PWideChar = '2147483648';
  HighInt64: PWideChar = '9223372036854775807';
  LowInt64: PWideChar = '9223372036854775808';
var
  P,PEnd: PWideChar;
  flSign,flDecSeparator: boolean;
begin
  Result := 0;
  flDecSeparator := False;
  flSign := False;
  P := Value;
  PEnd := P + Count;
  While P<PEnd do begin
    if P^ in [WideChar('0')..WideChar('9')] then Inc(Result)
     else
    if (P=Value) and (P^ in [WideChar('+'),WideChar('-')]) then flSign := True
     else
    if (P^=WideChar(DecimalSeparator)) and (not flDecSeparator) then flDecSeparator := True
     else begin
       Result := 0;
       Exit;
     end;
    Inc(P);
  end;

 if Result>0 then begin
   if flDecSeparator then Result := 2
    else
   if Result<10 then Result := 1
    else
   if Result>19 then Result := 0
    else
   if Result>10 then begin
      if flSign then P := Value+1 else P := Value;
      if flSign and (Value^='-') then pEnd := LowInt64 else pEnd := HighInt64;
      if RSLCompareText(WideString(P),WideString(pEnd))<=0 then Result := 3 else Result := 0;
   end else begin
      if flSign then P := Value+1 else P := Value;
      if flSign and (Value^='-') then pEnd := LowInteger else pEnd := HighInteger;
      if RSLCompareText(WideString(P),WideString(pEnd))<=0 then Result := 1 else Result := 3;
    end;
 end;
end;

function HexStrToBinBuf(P: PAnsiChar; const Count: integer): AnsiString;
var
  i: integer;
  PEnd: PAnsiChar;
  b: byte;
begin
  if (Count>3) and ((P+2)^<>',') then i := 2
   else i := 3;
  SetLength(Result, (Count+1) div i);
  i := 1;
  PEnd := P + Count;
  b := 0; // off warning only
  While P<PEnd do begin
    if P^ in ['0'..'9'] then b := Ord(P^)-Ord('0')
     else
    if P^ in ['A'..'F'] then b := Ord(P^)-Ord('A')+10
     else
    if P^ in ['a'..'f'] then b := Ord(P^)-Ord('a')+10
     else
    if P^ in [',',' ',#13,#10,'\'] then begin
      Inc(P);
      Continue;
    end else begin
      Result := '';
      Exit;
    end;
    b := b shl 4;
    Inc(P);
    if P^ in ['0'..'9'] then b := b + Ord(P^)-Ord('0')
     else
    if P^ in ['A'..'F'] then b := b + Ord(P^)-Ord('A')+10
     else
    if P^ in ['a'..'f'] then b := b + Ord(P^)-Ord('a')+10
     else begin
       Result := '';
       Exit;
     end;
    Result[i] := AnsiChar(b);
    Inc(i);
    Inc(P);
  end;

  SetLength(Result, i-1);
end;


// Additional parmeters:
// CRSHexStrLength - length of one line
// RSHexStrStartOffset - start offset for first line. default=0 - no offset
// RSHexStrLineSeparator - separator between lines #13#10 or "\#13#10  " or ...
function BinBufToHexStr(P: PAnsiChar; const Count: integer): AnsiString;
var
  PEnd: PAnsiChar;
  CP: PAnsiChar;
  iEol, StartIEol, EndLineDelta: integer;
begin
  if RSHexStrCompact then begin
    SetString(Result, nil, Count*2);
    CP := PAnsiChar(Result);
    PEnd := P + Count;
    While P<PEnd do begin
      CP^ := AnsiChar(RSHexDigits[(Byte(P^) and $F0) shr 4]); Inc(CP);
      CP^ := AnsiChar(RSHexDigits[Byte(P^) and $0F]);         Inc(CP);
      Inc(P);
    end;
    RSHexStrCompact := False;
    Exit;
  end;

{$IFDEF RSL_WIN}
  EndLineDelta := Pos(CEOL[1],String(RSHexStrLineSeparator))-1;
{$ENDIF}
{$IFDEF RSL_KYLIX}
  EndLineDelta := Pos(#10,RSHexStrLineSeparator)-1;
{$ENDIF}
  StartIEol := Length(RSHexStrLineSeparator)-Pos(#10,String(RSHexStrLineSeparator))+1;
  iEol := Count*3-1;
  iEol := iEol+StartIEol-1+((iEol+RSHexStrStartOffset) div (CRSHexStrLength-2-Length(RSHexStrLineSeparator){EndLineDelta})) * Length(RSHexStrLineSeparator);
  SetString(Result, nil, iEol);

  CP := PAnsiChar(Result);
  PEnd := P + Count;
  iEol := RSHexStrStartOffset+1;
  While P<PEnd do begin
    CP^ := AnsiChar(RSHexDigits[(Byte(P^) and $F0) shr 4]); Inc(CP);
    CP^ := AnsiChar(RSHexDigits[Byte(P^) and $0F]);         Inc(CP);
    Inc(P);
    if P>=PEnd then Break;
    CP^ := ','; Inc(CP);
    Inc(iEol,3);
    if (iEol>(CRSHexStrLength-3-EndLineDelta)) and (P<(PEnd-1)) then begin
      Move(PAnsiChar(RSHexStrLineSeparator)^, CP^, Length(RSHexStrLineSeparator));
      Inc(CP,Length(RSHexStrLineSeparator));
      iEol := StartIEol;
    end;
  end;
  SetLength(Result, CP-PAnsiChar(Result));
  RSHexStrStartOffset := 0;
end;

function StrToBase64(P: PAnsiChar; const Count: integer): AnsiString;
var
  i,len,k: integer;
  b1,b2,b3: byte;
begin
  i := (Count div 3)*4;
  if (Count mod 3)<>0 then Inc(i, (Count mod 3)+1);
  SetLength(Result, i);
  len := i;
  k := 0;
  i := 1;
  While k<Count do begin
    b1 := PByte(P+k)^;
    if (k+1)<Count then b2 := PByte(P+k+1)^ else b2 := 0;
    if (k+2)<Count then b3 := PByte(P+k+2)^ else b3 := 0;
    Inc(k, 3);
    Result[i] := RSBase64digits[b1 shr 2];
    if (i+1)<=len then Result[i+1] := RSBase64digits[((b1 and $3) shl 4) or (b2 shr 4)];
    if (i+2)<=len then Result[i+2] := RSBase64digits[((b2 and $F) shl 2) or (b3 shr 6)];
    if (i+3)<=len then Result[i+3] := RSBase64digits[b3 and $3F];
    Inc(i,4);
  end;
end;

function Base64ToStr(P: PAnsiChar; const Count: integer): AnsiString;
var
  i,res,bidx,k: integer;
  b: byte;
begin
  i := (Count div 4)*3;
  if (Count mod 4)<>0 then Inc(i, (Count mod 4)-1);
  SetLength(Result, i);
  k := 0;
  i := 1;
  bidx := 0;
  res := 0;
  b := 0;
  While k<Count do begin
    case PByte(P+k)^ of
      Ord('A')..Ord('Z'):  b := Ord(PByte(P+k)^) - Ord('A');
      Ord('a')..Ord('z'):  b := Ord(PByte(P+k)^) - Ord('a') + 26;
      Ord('0')..Ord('9'):  b := Ord(PByte(P+k)^) - Ord('0') + 52;
      Ord('+'):       b := 62;
      Ord('/'):       b := 63;
      else begin Result := ''; Exit; end;
    end;
    Inc(k);
    case bidx of
      0: begin res := b; Inc(bidx); end;
      1,
      2: begin res := (res shl 6) or b; Inc(bidx); end;
      3: begin res := (res shl 6) or b; bidx := 0; end;
    end;
    if (k=Count) or (bIdx=0) then begin
      case bIdx of
       0: begin
            Result[i] := AnsiChar((res shr 16) and $FF);
            Result[i+1] := AnsiChar((res shr 8) and $FF);
            Result[i+2] := AnsiChar(res and $FF);
            Inc(i,3);
          end;
       1: begin Result := ''; Exit; end;
       2: begin Result[i] := AnsiChar((res shr 4) and $FF); Exit; end;
       3: begin
            Result[i] := AnsiChar((res shr 10) and $FF);
            Result[i+1] := AnsiChar((res shr 2) and $FF);
            Exit;
          end;
      end;
      if k=Count then Break;
    end;
  end;
end;

{$IFDEF RSL_WIN}
function RegReadString(Key: HKey; const Path,AName: string): string;
var
  TmpKey: HKey;
  ValType, ValSize: integer;
begin
  Result := '';
  if RegOpenKeyEx(Key, PChar(Path), 0, KEY_READ, TmpKey)=ERROR_SUCCESS then begin
    if (RegQueryValueEx(TmpKey, PChar(AName), nil, @ValType, nil, @ValSize)=ERROR_SUCCESS) and
       (ValType=REG_SZ)
     then begin
       SetLength(Result, ValSize);
       if RegQueryValueEx(TmpKey, PChar(AName), nil, @ValType, Pointer(Result), @ValSize)<>ERROR_SUCCESS
        then Result := ''
        else SetLength(Result, ValSize-1);
     end;
    RegCloseKey(TmpKey);
  end;
end;
{$ENDIF}


type
  ExecuteProc = procedure(Wnd: cardinal);

{$IFDEF RSL_WIN}
procedure RslAbout;
var
  s: string;
  Instance: integer;
  proc: ExecuteProc;
begin
  s := RegReadString(HKEY_LOCAL_MACHINE, SRSProductKey, 'RootDir');

  if s='' then begin
    s := ExtractFilePath(ParamStr(0))+'rslabout.dll';
    if not FileExists(s) then begin
      MessageBeep(dword(-1));
      Exit;
    end;
  end else s := s+'\Source\rslabout.dll';

  Instance := LoadLibrary(PChar(s));
  if Instance<>0 then begin
    @proc := GetProcAddress(Instance, 'Execute');
    if Pointer(@proc)<>nil then proc(FindWindow('TAppBuilder',''))
     else MessageBeep(dword(-1));
    FreeLibrary(Instance);
  end else MessageBox(0, PChar('Can''t find '+s), 'Error', MB_OK or MB_ICONERROR);
end;
{$ENDIF}
{$IFDEF RSL_KYLIX}
procedure RslAbout;
begin
   MessageDlg('About Storage Library',
              'Storage library version '+SRSLibVersion+CEOL+CEOL+
              'Links:'+CEOL+
              '  Web: http://www.deepsoftware.com/rsllib/'+CEOL+
              '  e-mail: ray@deepsoftware.com',
              mtCustom, [mbOk], 0);
end;
{$ENDIF}

function StringToHashInteger(const Value: string): integer;
var
  i: integer;
  s: string;
  c: char;
begin
  Result := 0;
  s := Value;
  c := 'A';
  While Length(s)<16 do begin
    s := s + c;
    Inc(c);
  end;
  for i := 1 to Length(s) do
    Result := ((Result shl 2) or (Result shr (SizeOf(Result) * 8 - 2))) xor Ord(s[i]);
end;

function IsSectionSeparator(ch: RSLChar): boolean;
begin
  Result := (ch='/') or (ch='\');
end;

function GetNameBetweenSeparators(Value: RSLString; var Index: integer): RSLString;
var
  i,e: integer;
begin
  e := Length(Value)+1;
  for i := Index to Length(Value) do
    if IsSectionSeparator(Value[i]) then begin
      e := i;
      Break;
    end;
  Result := Copy(Value, Index, e-Index);
  Index := e;
end;

{$IFDEF RSL_UNICODE}
{$IFNDEF RSL_D6GE}
function WideCompareText(const S1, S2: WideString): Integer;
begin
  SetLastError(0);
  Result := CompareStringW(LOCALE_USER_DEFAULT, NORM_IGNORECASE,
                           PWideChar(S1), Length(S1),
                           PWideChar(S2), Length(S2)) - 2;

  if GetLastError = ERROR_CALL_NOT_IMPLEMENTED
    then Result := CompareStringA(LOCALE_USER_DEFAULT, NORM_IGNORECASE,
                                  PChar(AnsiString(S1)), Length(S1),
                                  PChar(AnsiString(S2)), Length(S2)) - 2;
end;
{$ENDIF}
{$ENDIF}

function RSLCompareText(const Value1, Value2: RSLString): integer;
begin
{$IFDEF RSL_UNICODE}
  Result := WideCompareText(Value1, Value2);
{$ELSE}
  Result := CompareText(Value1, Value2);
{$ENDIF}
end;

function RSLCompareStrLI(Value1, Value2: PRSLChar; MaxLen: Cardinal): integer;
var
  cnt: integer;
begin
{$IFDEF RSL_UNICODE}
  if SizeOf(Char)>1
    then cnt := MaxLen
    else cnt := MaxLen*2;
  Result := StrLIComp(PChar(Value1), PChar(Value2), cnt);
{$ELSE}
  cnt := MaxLen;
  Result := StrLIComp(Value1, Value2, cnt);
{$ENDIF}
end;

function StrPosW(Str1, Str2: PWideChar): PWideChar;
var
  P1,P2: PWideChar;
begin
  Result := nil;
  while True do begin
    While not (Str1^ in [Str2^, WideChar(#0)]) do Inc(Str1);
    if Str1^=#0 then Break;
    P1 := Str1;
    P2 := Str2;
    While P1^=P2^ do begin
      if P1^=#0 then Break;
      if P2^=#0 then begin
        Result := Str1;
        Exit;
      end;
      Inc(P1);
      Inc(P2);
      if P2^=#0 then begin
        Result := Str1;
        Exit;
      end;
    end;
    Inc(Str1);
  end;
end;


function IsUnicodeString(const Value: RSLString): boolean;
{$IFDEF RSL_UNICODE}
var
  i: integer;
{$ENDIF}
begin
  Result := false;
{$IFDEF RSL_UNICODE}
  for i:=1 to Length(Value) do
    if Word(Value[i])>$00FF then begin
      Result := true;
      Break;
    end;
{$ENDIF}
end;

function UpCaseW(Ch: WideChar): WideChar;
begin
  if ((Word(Ch) shr 8) and $FF)=0
    then Result := WideChar(UpCase(Chr(Word(Ch) and $FF)))
    else Result := Ch;
end;


function IsHexStrW(P: PWideChar; const Count: integer): boolean;
var
  PEnd: PWideChar;
  cntDigit,cntComma: integer;
begin
  Result := False;
  PEnd := P + Count;
  cntDigit := 0;
  cntComma := 0;
  While P<PEnd do begin
    if P^ in [WideChar('0')..WideChar('9'),
              WideChar('A')..WideChar('F'),
              WideChar('a')..WideChar('f')]
      then Inc(cntDigit)
      else
    if P^ = WideChar(',')
      then Inc(cntComma)
      else
    if P^ in [WideChar(#13),WideChar(#10)]
      then
      else Exit;
    Inc(P);
  end;
  Result := ((cntDigit=2) and (cntComma=0)) or
            ((cntComma>0) and (cntDigit>cntComma) and ((cntDigit div cntComma)<=4));
end;

function HexStrWToBinBuf(P: PWideChar; const Count: integer): AnsiString;
var
  i: integer;
  PEnd: PWideChar;
  b: byte;
begin
  if (Count>3) and ((P+2)^<>',') then i := 2
   else i := 3;
  SetLength(Result, (Count+1) div i);
  i := 1;
  PEnd := P + Count;
  b := 0; // off warning only
  While P<PEnd do begin
    if P^ in [WideChar('0')..WideChar('9')] then b := Ord(P^)-Ord('0')
     else
    if P^ in [WideChar('A')..WideChar('F')] then b := Ord(P^)-Ord('A')+10
     else
    if P^ in [WideChar('a')..WideChar('f')] then b := Ord(P^)-Ord('a')+10
     else
    if P^ in [WideChar(','),WideChar(' '),WideChar(#13),WideChar(#10),WideChar('\')] then begin
      Inc(P);
      Continue;
    end else begin
      Result := '';
      Exit;
    end;
    b := b shl 4;
    Inc(P);
    if P^ in [WideChar('0')..WideChar('9')] then b := b + Ord(P^)-Ord('0')
     else
    if P^ in [WideChar('A')..WideChar('F')] then b := b + Ord(P^)-Ord('A')+10
     else
    if P^ in [WideChar('a')..WideChar('f')] then b := b + Ord(P^)-Ord('a')+10
     else begin
       Result := '';
       Exit;
     end;
    Result[i] := AnsiChar(b);
    Inc(i);
    Inc(P);
  end;

  SetLength(Result, i-1);
end;

procedure SwapBytes(P: PWideChar);
begin
  While P^<>#0 do begin
    P^ := WideChar(Swap(Ord(P^)));
    Inc(P);
  end;
end;

function RSLQuoteStr(Value: RSLString): RSLString;
begin
  Result := Value;
  if Length(Value)>0 then begin
    if (Value[1]<>'"') or (Value[Length(Value)]<>'"')
      then Result := '"'+Value+'"'
  end;
end;


{$IFDEF RSL_REALKYLIX}
function MessageBox(hWnd: cardinal; lpText, lpCaption: WideString; uType: integer): Integer;
begin
  Result := MessageDlg(lpText, mtConfirmation, [mbYes, mbNo], 0, mbYes);
  if Result=mrYes then Result := IDYES;
end;

procedure ShellExecute(h:integer;cmd,f:PChar;p1,p2:pointer;st:integer);
begin
  if libc.fork=0 then begin
    libc.system(Pchar('netscape '+String(f)));
    libc._Exit(0);
  end;
end;

procedure ExitProcess(const ResCode: integer);
begin
  libc._Exit(ResCode);
end;
{$ENDIF}

end.

