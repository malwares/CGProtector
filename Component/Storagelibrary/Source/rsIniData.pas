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
unit rsIniData;

interface

{$I rsStorage.inc}


uses {$IFDEF RSL_WIN}Windows,{$ENDIF}
     {$IFDEF RSL_KYLIX}Types,{$ENDIF}
     Classes, SysUtils, rsStorage;

const
  cValueHex = 'hex:';
  cValueCurr = 'curr:';
  cValueDate = 'date:';
  cValueFixedDate = 'fxdate:';
  cValueText = 'text:';
  cValuePoint = 'point:';
{$IFDEF RSL_INT64}
  cValueInt64 = 'int64:';
{$ENDIF}

type
  TrsIniCompactOption = (coHexStr);
  TrsIniCompactOptions = set of TrsIniCompactOption;

  TrsIniData = class(TrsStreamData)
  private
    PBuf: PAnsiChar;
    FCompactOptions: TrsIniCompactOptions;
    IsUnicode: boolean;
    FTemplate: TStrings;
    CharSize: integer;
    FFixedDTFormat: boolean;

    function  CalcBufSize(Var P: PAnsiChar): integer;
    procedure CalcItemsCnt(var SectionCnt,KeyCnt: integer);
    function  DecodeText(var P: PChar): string;
    procedure EncodeText(var Value: String; const Source: string);
    function  GetFileString(var P: PAnsiChar): AnsiString;
    procedure StorageFill;

    {$IFDEF RSL_UNICODE}
    procedure EncodeTextW(var Value: WideString; const Source: WideString);
    function  DecodeTextW(var P: PWideChar): WideString;
    function  GetFileStringW(var P: PWideChar): WideString;
    function  CalcBufSizeW(Var P: PWideChar): integer;
    procedure StorageFillW;
    {$ENDIF}

    function IsTemplateStored: Boolean;
    procedure SetTemplate(const Value: TStrings);
    procedure TemplateSkipPrefix;
  protected
    procedure LoadFromStream(Stream: TStream); override;
    procedure SaveToStream(Stream: TStream); override;
  public
    constructor Create(AOwner: TComponent); override;
    destructor Destroy; override;
  published
    property CompactOptions: TrsIniCompactOptions read FCompactOptions write FCompactOptions default [];
    property FileName;
    property FileDir;
    property InternalFileName;
    property InternalFileLoad;
    property Options;
    property Template: TStrings read FTemplate write SetTemplate stored IsTemplateStored;
{$IFDEF RSL_UNICODE}
    property Unicode;
{$ENDIF}
    property OnLoadFromStream;
    property OnSaveToStream;
    property FixedDateTimeFormat: boolean read FFixedDTFormat write FFixedDTFormat default FAlse;
  end;


implementation

uses rsConst, rsUtils;

const
  SBody = '%BODY%'+CEOL;
  SDefaultTemplate = SBody;

type
  TIntStorage = class(TrsStorage);

// check: has a string, char with code<' '
function IsTextString(const Value: PRSLChar):boolean;
var
  p: PRSLChar;
begin
  if Value=nil then Result := False
   else begin
     p := Value;
     While p^>=' ' do Inc(p);
     Result := p^<>#0;
   end;
end;


{$IFDEF RSL_UNICODE}
function IsTextStringW(const Value: PWideChar):boolean;
var
  p: PWideChar;
begin
  if Value=nil then Result := False
   else begin
     p := Value;
     While p^>=' ' do Inc(p);
     Result := p^<>#0;
   end;
end;
{$ENDIF}

{ TrsIniData }

constructor TrsIniData.Create(AOwner: TComponent);
begin
  inherited Create(AOwner);
  FExtension := '.ini';
  FTemplate := TStringList.Create;
  FTemplate.Text := SDefaultTemplate;
  FFixedDTFormat := False;
end;


function TrsIniData.CalcBufSize(Var P: PAnsiChar): integer;
var
  PStart: PAnsiChar;
begin
  PStart := P;
  While True do begin
    While not (P^ in [#13,#10,#0]) do Inc(P);
    if P^=#0 then Break;
    if not ((P-1)^ in [',','\']) then Break;
    if P^=#13 then Inc(P);
    if P^=#10 then Inc(P);
  end;
  Result := P-PStart;
end;


procedure TrsIniData.CalcItemsCnt(var SectionCnt, KeyCnt: integer);
var
  State: integer;
  p: PAnsiChar;
  w: word;
begin
  SectionCnt := 0;
  KeyCnt := 0;
  State := 1;
  p := PBuf;

  while True do begin

    if IsUnicode
      then w := PWord(p)^
      else w := PByte(p)^;
    Inc(p, CharSize);

    case w of
      ord('['):
          begin
            if State>0 then Inc(SectionCnt);
            State := 0;
          end;
      13,
      10: Inc(State);
       0: Exit;
      else begin
        if (State>0) and (w<>Ord(' ')) then begin
          Inc(KeyCnt);
          State := 0;
        end;
      end;
    end;

  end; //of while
end;

function TrsIniData.DecodeText(var P: PChar): string;
var
  i: integer;
  b: Byte;
begin
  SetLength(Result, Length(P));
  i := 1;
  if P^='"' then Inc(P);
  While True do begin
    if P^='$' then begin
      if (P+1)^='$' then begin
        Result[i] := '$';
        Inc(i);
        Inc(P,2);
      end else begin
        b := 0;
        Inc(P);
        case P^ of
         '0'..'9': b := (ORD(P^)-ORD('0')) shl 4;
         'A'..'F': b := (ORD(P^)-ORD('A')+10) shl 4;
         'a'..'f': b := (ORD(P^)-ORD('a')+10) shl 4;
        end;
        Inc(P);
        case P^ of
         '0'..'9': b := b + (ORD(P^)-ORD('0'));
         'A'..'F': b := b + (ORD(P^)-ORD('A')+10);
         'a'..'f': b := b + (ORD(P^)-ORD('a')+10);
        end;
        Result[i] := Chr(b);
        Inc(i);
        Inc(P);
      end;
    end else
    if (P^ in [#0,#10,#13]) or ((P^='"') and ((P+1)^ in [#0,#10,#13]))
     then break
     else begin
       Result[i] := Char(P^);
       Inc(i);
       Inc(P);
     end;
  end;
  SetLength(Result, i-1);
end;


procedure TrsIniData.EncodeText(var Value: String; const Source: string);
var
  i,k: integer;
begin
  k := 0;
  for i:=1 to Length(Source) do
   if Source[i]='$' then Inc(k,1)
    else if Source[i]<' ' then Inc(k,2);

  if k=0 then Value := Value + '"' + Source + '"'
   else begin
     i := Length(Value);
     SetLength(Value, i+Length(Source)+k+2);
     Value[i+1] := '"'; k:=i+2;
     i:=1;
     While i<=Length(Source) do begin
       if Source[i]='$' then begin
         Value[k] := '$'; Inc(k);
         Value[k] := '$'; Inc(k);
       end else
       if Source[i]<' ' then begin
         Value[k] := '$';                                          Inc(k);
         Value[k] := RSHexDigits[(ORD(Source[i]) and $F0) shr 4];  Inc(k);
         Value[k] := RSHexDigits[ORD(Source[i]) and $0F];          Inc(k);
       end else begin
         Value[k] := Source[i];
         Inc(k);
       end;
       Inc(i);
     end;
     Value[k] := '"';
     SetLength(Value, k);
   end;
end;


function TrsIniData.GetFileString(var P: PAnsiChar): AnsiString;
var
  Start: PAnsiChar;
begin
  Start := P;
  while not (P^ in [#0, #10, #13]) do Inc(P);
  SetString(Result, Start, P - Start);
  if P^ = #13 then Inc(P);
  if P^ = #10 then Inc(P);
end;


procedure TrsIniData.LoadFromStream(Stream: TStream);
var
  SectionCnt,KeyCnt: integer;
  i,cnt: integer;
  sA: AnsiString;
begin
  inherited;
  i := 0;
  if (Stream is TMemoryStream) then begin
    Stream.Seek(0,soFromEnd);
    Stream.Write(i,2);
    Stream.Position := 0;
    PBuf := (Stream as TMemoryStream).Memory;
    cnt := Stream.Size-2;
  end else begin
    cnt := Stream.Size;
    SetString(sA, nil, i+2);
    Stream.Read(Pointer(sA)^, cnt);
    PBuf := Pointer(sA);
    sA[Length(sA)] := #0;
    sA[Length(sA)-1] := #0;
  end;

  if cnt>0 then begin  //data size > 0
    case PWord(PBuf)^ of
     $FEFF: IsUnicode := True;
     $FFFE: begin // if UTF16LE
              SwapBytes(PWideChar(PBuf));
              IsUnicode := True;
            end;
     else IsUnicode := False;
    end;

    CharSize := 1;
    if IsUnicode then begin
      Inc(PBuf, 2); // skip $FEFF
      Inc(CharSize);
    end;

    TemplateSkipPrefix;

    CalcItemsCnt(SectionCnt,KeyCnt);
    ProgressItemCount := KeyCnt;

    if (SectionCnt or KeyCnt)<>0 then begin
      TIntStorage(Storage).SectionListGrow(SectionCnt);
      TIntStorage(Storage).KeyListGrow(KeyCnt);
      {$IFDEF RSL_UNICODE}
      if IsUnicode
        then StorageFillW
        else {$ENDIF}StorageFill;
    end;
  end;

  if Stream is TMemoryStream then begin
    Stream.Size := Stream.Size-2; // delete #0 bytes
  end;
end;


procedure TrsIniData.SaveToStream(Stream: TStream);
var
  s: RSLString;
  sA: String;
  i,j,KeyRangeBegin,KeyRangeEnd: integer;
  pKI: PrsKeyItem;
  HasKeys: boolean;
  TemplateIdx: integer;
begin
  inherited;
  BufferClear;

  CharSize := 1;
{$IFDEF RSL_UNICODE}
  IsUnicode := Unicode;
  if IsUnicode then begin
    BufferWriteCharW(#$FEFF);
    Inc(CharSize);
  end;
{$ELSE}
  IsUnicode := False;
{$ENDIF}

  // process template
  sA := FTemplate.Text;
  TemplateIdx := pos(SBody, sA);
  if TemplateIdx>0 then sA := Copy(sA, 1, TemplateIdx-1);
  {$IFDEF RSL_UNICODE}
  if IsUnicode
    then BufferWriteStrW(sA)
    else {$ENDIF}BufferWriteStrA(AnsiString(sA));

  ProgressItemCount := TintStorage(Storage).KeyCountAll;
  DoProgress;

  for i:=-1 to TintStorage(Storage).SectionCountAll-1 do begin
    if i<0
      then HasKeys := TintStorage(Storage).KeyFindRange(0, KeyRangeBegin, KeyRangeEnd)
      else HasKeys := TintStorage(Storage).KeyFindRange(TintStorage(Storage).GetSectionItem(i)^.Id, KeyRangeBegin, KeyRangeEnd);

    if HasKeys or (soSaveEmptySection in Storage.Options) then begin
      s := TintStorage(Storage).SectionFullName(i);
      {$IFDEF RSL_UNICODE}
      if IsUnicode then begin
        BufferWriteCharW('[');
        BufferWriteStrW(s);
        BufferWriteCharW(']');
        BufferWriteEOL;
      end else {$ENDIF}
        BufferWriteFmtA(Length(s)+2+Length(CEOL), '[%s]'+CEOL, [AnsiString(s)]);
    end else Continue;

    if HasKeys then begin
     for j := KeyRangeBegin to KeyRangeEnd-1 do begin
       pKI := TintStorage(Storage).GetKeyItem(j);

       Inc(ProgressItemCurrent);  // increment progress
       DoProgress;

       {$IFDEF RSL_UNICODE}
       if IsUnicode then begin
         BufferWriteStrW(pKI^.Name);
         BufferWriteCharW('=');
       end else {$ENDIF}
         BufferWriteFmtA(Length(pKI^.Name)+1, '%s=', [AnsiString(pKI^.Name)]);

       case pKI^.Value.kvType of
         kvtPointer,
         kvtInteger: begin
                       {$IFDEF RSL_UNICODE}
                       if IsUnicode
                         then BufferWriteStrW(IntToStr(pKI^.Value.VInteger))
                         else {$ENDIF}
                              BufferWriteFmtA(11, '%d', [pKI^.Value.VInteger]);
                     end;
         kvtDouble:  begin
                       sA := Format('%g', [pKI^.Value.VDouble]);
                       if pos(DecimalSeparator, sA)=0 then sA := sA + DecimalSeparator + '0';
                       {$IFDEF RSL_UNICODE}
                       if IsUnicode
                         then BufferWriteStrW(sA)
                         else {$ENDIF} BufferWriteStrA(AnsiString(sA));
                     end;
         kvtCurrency:begin
                       sA := cValueCurr+CurrToStr(pKI^.Value.VCurrency);
                       {$IFDEF RSL_UNICODE}
                       if IsUnicode
                         then BufferWriteStrW(sA)
                         else {$ENDIF}BufferWriteStrA(AnsiString(sA));
                     end;
         kvtDateTime:begin
                       if FixedDateTimeFormat
                         then sA := cValueFixedDate+RSLDateTimeToXMLStr(pKI^.Value.VDateTime)
                         else sA := cValueDate+DateTimeToStr(pKI^.Value.VDateTime);
                       {$IFDEF RSL_UNICODE}
                       if IsUnicode
                         then BufferWriteStrW(sA)
                         else {$ENDIF}BufferWriteStrA(AnsiString(sA));
                     end;
         kvtBool:    begin
                       {$IFDEF RSL_UNICODE}
                       if IsUnicode
                         then begin
                           if pKI^.Value.VBoolean
                             then BufferWriteStrW(RSBooleanIdentsTrue)
                             else BufferWriteStrW(RSBooleanIdentsFalse);
                         end else {$ENDIF}begin
                           if pKI^.Value.VBoolean
                             then BufferWriteStrA(RSBooleanIdentsTrue)
                             else BufferWriteStrA(RSBooleanIdentsFalse);
                         end;
                     end;
         kvtPoint:   begin
                       {$IFDEF RSL_UNICODE}
                       if IsUnicode
                         then BufferWriteStrW(cValuePoint+IntToStr(pKI^.Value.x)+','+IntToStr(pKI^.Value.y))
                         else {$ENDIF}BufferWriteFmtA(31, '%s%d,%d', [cValuePoint, pKI^.Value.x, pKI^.Value.y]);
                     end;
         kvtString:  begin
                       {$IFDEF RSL_UNICODE}
                       if IsUnicode then begin
                         if IsTextStringW(PRSLChar(pKI^.Value.VString)) then begin
                           BufferWriteStrW(cValueText);
                           s := '';
                           EncodeTextW(s, RSLString(pKI^.Value.VString));
                           BufferWriteStrW(s);
                         end else begin
                           s := RSLQuoteStr(RSLString(pKI^.Value.VString));
                           BufferWriteStrW(s);
                         end;
		       end else begin {$ENDIF}
                         if IsTextString(PRSLChar(pKI^.Value.VString)) then begin
                           sA := cValueText;
                           EncodeText(sA, String(RSLString(pKI^.Value.VString)));
                           BufferWriteStrA(AnsiString(sA));
                         end else begin
                           sA := RSLQuoteStr(String(RSLString(pKI^.Value.VString)));
                           BufferWriteStrA(AnsiString(sA));
                         end;
                       {$IFDEF RSL_UNICODE}
		       end;
                       {$ENDIF}
                     end;
         kvtBuffer:  begin
                       RSHexStrLineSeparator := '\'+CEOL+'  ';
                       RSHexStrStartOffset := Length(pKI^.Name)+6;
                       RSHexStrCompact := coHexStr in CompactOptions;
                       sA := cValueHex + String(BinBufToHexStr(pKI^.Value.VBuffer, Length(AnsiString(pKI^.Value.VBuffer))));
                       {$IFDEF RSL_UNICODE}
                       if IsUnicode
                         then BufferWriteStrW(sA)
                         else {$ENDIF}BufferWriteStrA(AnsiString(sA));
                     end;
{$IFDEF RSL_INT64}
         kvtInt64:   begin
                       if (pKI^.Value.VInt64>High(Integer)) or (pKI^.Value.VInt64<Low(Integer))
                         then sA := IntToStr(pKI^.Value.VInt64)
                         else sA := cValueInt64 + IntToStr(pKI^.Value.VInt64);
                       {$IFDEF RSL_UNICODE}
                       if IsUnicode
                         then BufferWriteStrW(sA)
                         else {$ENDIF}BufferWriteStrA(AnsiString(sA));
                     end;
{$ENDIF}
       end; // of case
       BufferWriteEOL;
     end; // of for j=...
     BufferWriteEOL;
    end; // of if findRange
  end; // of for i:=0 ...

  if TemplateIdx>0 then begin //has a postfix on template
    sA := FTemplate.Text;
    Inc(TemplateIdx, Length(SBody));
    if TemplateIdx<=Length(sA) then begin
      sA := Copy(sA, TemplateIdx, Length(sA)-TemplateIdx+1);
      if sA<>CEOL then begin
        {$IFDEF RSL_UNICODE}
        if IsUnicode
          then BufferWriteStrW(sA)
          else {$ENDIF} BufferWriteStrA(AnsiString(sA));
      end;
    end;
  end;

  BufferFlush;
end;


procedure TrsIniData.StorageFill;
var
  sKeyName: string;
  s: String;
  iKeySize: integer;
  Pi: PChar;
  P,p2: PAnsiChar;
  i,j: integer;
  HexBuf: AnsiString;
  flOk: boolean;
  Point: TPoint;
  dt: TDateTime;
begin
  P := PBuf;
  DoProgress;
  while P^ <> #0 do begin
    s := Trim(String(GetFileString(P)));
    if Length(s)=0 then Continue;

      if (s[1]='[') and (s[Length(s)]=']') then begin
        Storage.RootSection := Copy(String(s), 2, Length(s)-2);
      end else begin
        i := Pos('=',s);
        if (i>0) and (not (s[1] in [';','#','/','\'])) then begin
          sKeyName := Copy(s,1,i-1);
          iKeySize := Length(s)-i;
          Inc(i);

          Inc(ProgressItemCurrent);  // increment progress
          DoProgress;

// do empty
          if iKeySize=0 then begin
            Storage.Values[sKeyName] := '';
            Continue;
          end else
// do string
          if (iKeySize>1) and (s[i]='"') and (s[Length(s)]='"') then begin
            Storage.Values[sKeyName] := Copy(s, i+1,iKeySize-2);
            Continue;
          end;

          if s[i] in ['0'..'9','+','-'] then begin
            j :=  IsDigitValue(@s[i], iKeySize);
            if j>0 then begin
              case j of
                1: Storage.WriteInteger(sKeyName, StrToInt(Copy(s,i,iKeySize)));
                2: Storage.WriteFloat(sKeyName, StrToFloat(Copy(s,i,iKeySize)));
{$IFDEF RSL_INT64}3: Storage.WriteInt64(sKeyName, StrToInt64(Copy(s,i,iKeySize)));{$ENDIF}
              end;
              Continue;
            end;
          end;

          Pi := @s[i];
          case UpCase(s[i]) of
           'T': begin
                  flOk := StrIComp('True', Pi)=0;
                  if flOk then Storage.Values[sKeyName] := True
                   else begin
                     flOk := StrLIComp(cValueText, Pi, Length(cValueText))=0;
                     if flOk then begin
                       Inc(Pi, Length(cValueText));
                       Storage.WriteText(sKeyName, DecodeText(Pi));
                     end;
                   end;
                end;
           'F': begin
                  flOk := StrIComp('False', Pi)=0;
                  if flOk
                    then Storage.Values[sKeyName] := False
                    else begin
                      flOk := StrLIComp(cValueFixedDate, Pi, Length(cValueFixedDate))=0;
                      if flOk then begin
                         if RSLXMLStrToDateTime(
                           Copy(s,
                                i+Length(cValueFixedDate),
                                iKeySize-Length(cValueFixedDate)), dt)
                          then begin
                             Storage.Values[sKeyName] := dt;
                          end else begin
                          end;
                      end;
                    end;
                end;
           'C': begin
                  flOk := StrLIComp(cValueCurr, Pi, Length(cValueCurr))=0;
                  if flOk then Storage.Values[sKeyName] := StrToCurr(Copy(s,i+Length(cValueCurr),iKeySize-Length(cValueCurr)));
                end;
           'H': begin
                  flOk := StrLIComp(cValueHex, Pi, Length(cValueHex))=0;
                  if flOk then begin
                    While P^<>':' do Dec(P);
                    Inc(P);

                    P2 := P;
                    HexBuf := HexStrToBinBuf(P, CalcBufSize(P2));
                    P := P2;
                    if P^ = #13 then Inc(P);
                    if P^ = #10 then Inc(P);

                    Storage.WriteBuffer(sKeyName,Pointer(HexBuf)^, Length(HexBuf));
                  end;
                end;
           'D': begin
                  flOk := StrLIComp(cValueDate, Pi, Length(cValueDate))=0;
                  if flOk then Storage.Values[sKeyName] := StrToDateTime(Copy(s,i+Length(cValueDate),iKeySize-Length(cValueDate)));
                end;
           'P': begin
                  flOk := StrLIComp(cValuePoint, Pi, Length(cValuePoint))=0;
                  if flOk then begin
                    Inc(i, Length(cValueText));
                    Point.Y := i+1;
                    j := Length(s);
                    While (s[i]<>',') and (i<=j) do Inc(i);
                    Point.x := StrToInt(Copy(s, Point.y, i-Point.y));
                    Point.y := StrToInt(Copy(s, i+1, 255));
                    Storage.WritePoint(sKeyName, Point);
                  end;
                end;
{$IFDEF RSL_INT64}
           'I': begin
                  flOk := StrLIComp(cValueInt64, Pi, Length(cValueInt64))=0;
                  if flOk then Storage.WriteInt64(sKeyName, StrToInt64(Copy(s,i+Length(cValueInt64),iKeySize-Length(cValueInt64))));
                end;
{$ENDIF}
           else begin
             Storage.Values[sKeyName] := Copy(s, i, iKeySize);
             flOk := True;
           end;
          end;

          if not flOk then Storage.Values[sKeyName] := Copy(s, i, iKeySize);

        end; // pos '=' > 0
      end; // if else []
  end; // of while
end;

{$IFDEF RSL_UNICODE}
procedure TrsIniData.StorageFillW;
var
  s,sKeyName: WideString;
  iKeySize: integer;
  P,Pi: PRSLChar;
  i,j: integer;
  HexBuf: AnsiString;
  flOk: boolean;
  Point: TPoint;
  dt: TDateTime;
begin
  P := PRSLChar(PBuf);
  DoProgress;
  while P^ <> #0 do begin
    s := Trim(GetFileStringW(P));
    if Length(s)=0 then Continue;

      if (s[1]='[') and (s[Length(s)]=']') then begin
        Storage.RootSection := Copy(s,2,Length(s)-2);
      end else begin
        i := Pos('=',s);
        if (i>0) and (not (Char(s[1]) in [';','#','/','\'])) then begin
          sKeyName := Copy(s,1,i-1);
          iKeySize := Length(s)-i;
          Inc(i);

          Inc(ProgressItemCurrent);  // increment progress
          DoProgress;

// do empty
          if iKeySize=0 then begin
            Storage.Values[sKeyName] := '';
            Continue;
          end else
// do string
          if (iKeySize>1) and (s[i]='"') and (s[Length(s)]='"') then begin
            Storage.Values[sKeyName] := Copy(s,i+1,iKeySize-2);
            Continue;
          end;

          if s[i] in [WideChar('0')..WideChar('9'),WideChar('+'),WideChar('-')] then begin
            j :=  IsDigitValueW(@s[i], iKeySize);
            if j>0 then begin
              case j of
                1: Storage.WriteInteger(sKeyName, StrToInt(Copy(s,i,iKeySize)));
                2: Storage.WriteFloat(sKeyName, StrToFloat(Copy(s,i,iKeySize)));
{$IFDEF RSL_INT64}3: Storage.WriteInt64(sKeyName, StrToInt64(Copy(s,i,iKeySize)));{$ENDIF}
              end;
              Continue;
            end;
          end;

          Pi := PRSLChar(@s[i]);
          case UpCaseW(s[i]) of //UpCase(s[i])
           'T': begin
                  flOk := RSLCompareText('True', Pi)=0;
                  if flOk then Storage.Values[sKeyName] := True
                   else begin
                     flOk := RSLCompareStrLI(cValueText, Pi, Length(cValueText))=0;
                     if flOk then begin
                       Inc(Pi, Length(cValueText));
                       Storage.WriteText(sKeyName, DecodeTextW(Pi));
                     end;
                   end;
                end;
           'F': begin
                  flOk := RSLCompareText('False', Pi)=0;
                  if flOk
                    then Storage.Values[sKeyName] := False
                    else begin
                      flOk := RSLCompareStrLI(cValueFixedDate, Pi, Length(cValueFixedDate))=0;
                      if flOk then begin
                         if RSLXMLStrToDateTime(
                           Copy(s,
                                i+Length(cValueFixedDate),
                                iKeySize-Length(cValueFixedDate)), dt)
                          then begin
                             Storage.Values[sKeyName] := dt;
                          end else begin
                          end;
                      end;
                    end;
                end;
           'C': begin
                  flOk := RSLCompareStrLI(cValueCurr, Pi, Length(cValueCurr))=0;
                  if flOk then Storage.Values[sKeyName] := StrToCurr(Copy(s,i+Length(cValueCurr),iKeySize-Length(cValueCurr)));
                end;
           'H': begin
                  flOk := RSLCompareStrLI(cValueHex, Pi, Length(cValueHex))=0;
                  if flOk then begin
                    While P^<>':' do Dec(P);
                    Inc(P);

                    Pi := P;
                    HexBuf := HexStrWToBinBuf(P, CalcBufSizeW(Pi));
                    P := Pi;
                    if P^ = #13 then Inc(P);
                    if P^ = #10 then Inc(P);

                    Storage.WriteBuffer(sKeyName,Pointer(HexBuf)^,Length(HexBuf));
                  end;
                end;
           'D': begin
                  flOk := RSLCompareStrLI(cValueDate, Pi, Length(cValueDate))=0;
                  if flOk then Storage.Values[sKeyName] := StrToDateTime(Copy(s,i+Length(cValueDate),iKeySize-Length(cValueDate)));
                end;
           'P': begin
                  flOk := RSLCompareStrLI(cValuePoint, Pi, Length(cValuePoint))=0;
                  if flOk then begin
                    Inc(i, Length(cValueText));
                    Point.Y := i+1;
                    j := Length(s);
                    While (s[i]<>',') and (i<=j) do Inc(i);
                    Point.x := StrToInt(Copy(s, Point.y, i-Point.y));
                    Point.y := StrToInt(Copy(s, i+1, 255));
                    Storage.WritePoint(sKeyName, Point);
                  end;
                end;
{$IFDEF RSL_INT64}
           'I': begin
                  flOk := RSLCompareStrLI(cValueInt64, Pi, Length(cValueInt64))=0;
                  if flOk then Storage.WriteInt64(sKeyName, StrToInt64(Copy(s,i+Length(cValueInt64),iKeySize-Length(cValueInt64))));
                end;
{$ENDIF}
           else begin
             Storage.Values[sKeyName] := Copy(s,i,iKeySize);
             flOk := True;
           end;
          end;

          if not flOk then Storage.Values[sKeyName] := Copy(s,i,iKeySize);

        end; // pos '=' > 0
      end; // if else []
  end; // of while
end;

procedure TrsIniData.EncodeTextW(var Value: WideString; const Source: WideString);
var
  i,k: integer;
begin
  k := 0;
  for i:=1 to Length(Source) do
   if Source[i]='$' then Inc(k,1)
    else if Source[i]<' ' then Inc(k,2);

  if k=0 then Value := Value + '"' + Source + '"'
   else begin
     i := Length(Value);
     SetLength(Value, i+Length(Source)+k+2);
     Value[i+1] := '"'; k:=i+2;
     i:=1;
     While i<=Length(Source) do begin
       if Source[i]='$' then begin
         Value[k] := '$'; Inc(k);
         Value[k] := '$'; Inc(k);
       end else
       if Source[i]<' ' then begin
         Value[k] := '$';                                                    Inc(k);
         Value[k] := WideChar(RSHexDigits[(ORD(Source[i]) and $F0) shr 4]);  Inc(k);
         Value[k] := WideChar(RSHexDigits[ORD(Source[i]) and $0F]);          Inc(k);
       end else begin
         Value[k] := Source[i];
         Inc(k);
       end;
       Inc(i);
     end;
     Value[k] := '"';
     SetLength(Value, k);
   end;
end;

function TrsIniData.GetFileStringW(var P: PWideChar): WideString;
var
  Start: PWideChar;
begin
  Start := P;
  while not (P^ in [WideChar(#0), WideChar(#10), WideChar(#13)]) do Inc(P);
  SetString(Result, Start, P - Start);
  if P^ = #13 then Inc(P);
  if P^ = #10 then Inc(P);
end;

function TrsIniData.CalcBufSizeW(var P: PWideChar): integer;
var
  PStart: PWideChar;
begin
  PStart := P;
  While True do begin
    While not (P^ in [WideChar(#0013),WideChar(#0010),WideChar(#0000)]) do Inc(P);
    if P^=#0 then Break;
    if not ((P-1)^ in [WideChar(','),WideChar('\')]) then Break;
    if P^=#13 then Inc(P);
    if P^=#10 then Inc(P);
  end;
  Result := P-PStart;
end;


function TrsIniData.DecodeTextW(var P: PWideChar): WideString;
var
  i: integer;
  b: Word;
begin
  SetLength(Result, Length(P));
  i := 1;
  if P^='"' then Inc(P);
  While True do begin
    if P^='$' then begin
      if (P+1)^='$' then begin
        Result[i] := '$';
        Inc(i);
        Inc(P,2);
      end else begin
        b := 0;
        Inc(P);
        case P^ of
         '0'..'9': b := (ORD(P^)-ORD('0')) shl 4;
         'A'..'F': b := (ORD(P^)-ORD('A')+10) shl 4;
         'a'..'f': b := (ORD(P^)-ORD('a')+10) shl 4;
        end;
        Inc(P);
        case P^ of
         '0'..'9': b := b + (ORD(P^)-ORD('0'));
         'A'..'F': b := b + (ORD(P^)-ORD('A')+10);
         'a'..'f': b := b + (ORD(P^)-ORD('a')+10);
        end;
        Result[i] := WideChar(b);
        Inc(i);
        Inc(P);
      end;
    end else
    if (P^ in [WideChar(#0),WideChar(#10),WideChar(#13)]) or ((P^='"') and ((P+1)^ in [WideChar(#0),WideChar(#10),WideChar(#13)]))
     then break
     else begin
       Result[i] := P^;
       Inc(i);
       Inc(P);
     end;
  end;
  SetLength(Result, i-1);
end;
{$ENDIF}

function TrsIniData.IsTemplateStored: Boolean;
begin
  Result := FTemplate.Text<>SDefaultTemplate;
end;

procedure TrsIniData.SetTemplate(const Value: TStrings);
begin
  FTemplate.Assign(Value);
end;

destructor TrsIniData.Destroy;
begin
  inherited;
  FTemplate.Free;
end;

// find first section name: '[' in start of line
procedure TrsIniData.TemplateSkipPrefix;
var
  State: integer;
  w: word;
begin
  State := 1;

  while True do begin

    if IsUnicode
      then w := PWord(PBuf)^
      else w := PByte(PBuf)^;

    case w of
      ord('['): if State>0 then Exit;
      13,
      10: Inc(State);
       0: Exit;
      else State := 0;
    end;

    Inc(PBuf, CharSize);
  end; //of while
end;

end.
