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
unit rsBinData;

interface

{$I rsStorage.inc}

uses {$IFDEF RSL_WIN}Windows,{$ENDIF} Classes, rsStorage;

type
  TrsBinData = class(TrsStreamData)
  protected
    procedure LoadFromStream(Stream: TStream); override;
    procedure SaveToStream(Stream: TStream); override;
  public
    constructor Create(AOwner: TComponent); override;
  published
    property FileName;
    property FileDir;
    property InternalFileName;
    property InternalFileLoad;
    property Options;
{$IFDEF RSL_UNICODE}
    property Unicode;
{$ENDIF}
    property OnLoadFromStream;
    property OnSaveToStream;
  end;

implementation

uses rsConst;

type
  TIntStorage = class(TrsStorage);

  TSaveSectionRecord = packed record
    id: word;
    parentid: word;
    len: byte;
  end;

  TSaveKeyRecord = packed record
    id: word;
    len: byte;
    valuetype: word;
  end;


{ TrsBinData }

constructor TrsBinData.Create(AOwner: TComponent);
begin
  inherited Create(AOwner);
  FExtension := '.bin';
end;

procedure TrsBinData.LoadFromStream(Stream: TStream);
var
  sA: AnsiString;
  sW: WideString;
  w,SectionCnt,KeyCnt: word;
  pKI: PrsKeyItem;
  pSI: PrsSectionItem;
  SectionMaxId: integer;
  i,version: integer;
  saveSectRec: TSaveSectionRecord;
  saveKeyRec: TSaveKeyRecord;
begin
  inherited;
  SetString(sA, nil, 4);
  Stream.Read(PAnsiChar(sA)^, 4);
  version := Ord(sA[4]) - Ord('0');   //v1.46
  Stream.Read(SectionCnt, SizeOf(Word));
  Stream.Read(KeyCnt, SizeOf(Word));

  ProgressItemCount := SectionCnt + KeyCnt;
  DoProgress;

  TIntStorage(Storage).SectionListGrow(SectionCnt);
  TIntStorage(Storage).SectionCountAll := SectionCnt;

  SectionMaxId := 0;
  pSI := TIntStorage(Storage).GetSectionItem(0);
  While SectionCnt>0 do begin
    Stream.Read(saveSectRec, SizeOf(TSaveSectionRecord));
    pSI^.Id := saveSectRec.id;
    pSI^.ParentId := saveSectRec.parentid;
    if version=3 then begin //unicode
      SetString(sW, nil, saveSectRec.len div 2);
      Stream.Read(Pointer(sW)^, saveSectRec.len);
      pSI^.Name := sW;
    end else begin // ansi
      SetString(sA, nil, saveSectRec.len);
      Stream.Read(Pointer(sA)^, saveSectRec.len);
      pSI^.Name := String(sA);
    end;
    Dec(SectionCnt);
    Inc(pSI);

    Inc(ProgressItemCurrent);
    DoProgress;
  end;

  TIntStorage(Storage).SectionMaxId := SectionMaxId;

  TIntStorage(Storage).KeyListGrow(KeyCnt);
  TIntStorage(Storage).KeyCountAll := KeyCnt;

  pKI := TIntStorage(Storage).GetKeyItem(0);
  While KeyCnt>0 do begin
    Stream.Read(saveKeyRec, SizeOf(TSaveKeyRecord));
    pKI^.SectionId := saveKeyRec.id;
    pKI^.Value.kvType := saveKeyRec.valuetype;
    if version=3 then begin //unicode
      SetString(sW, nil, saveKeyRec.len div 2);
      Stream.Read(Pointer(sW)^, saveKeyRec.len);
      pKI^.Name := sW;
    end else begin // ansi
      SetString(sA, nil, saveKeyRec.len);
      Stream.Read(Pointer(sA)^, saveKeyRec.len);
      pKI^.Name := String(sA);
    end;

    case pKI^.Value.kvType of
      kvtPointer:  Stream.Read(pKI^.Value.VPointer, SizeOf(Pointer));
      kvtInteger:  Stream.Read(pKI^.Value.VInteger, SizeOf(Integer));
      kvtDouble:   Stream.Read(pKI^.Value.VDouble, SizeOf(Double));
      kvtCurrency: Stream.Read(pKI^.Value.VCurrency, SizeOf(Currency));
      kvtDateTime: Stream.Read(pKI^.Value.VDateTime, SizeOf(TDateTime));
      kvtBool:     Stream.Read(pKI^.Value.VBoolean, SizeOf(Integer));
      kvtPoint:    begin
                     Stream.Read(pKI^.Value.X, SizeOf(Longint));
                     Stream.Read(pKI^.Value.Y, SizeOf(Longint));
                   end;
      kvtBuffer:  begin
                    if version in [2,3]
                      then Stream.Read(i, SizeOf(Integer)) //v1.46
                      else begin
                        Stream.Read(w, SizeOf(Word));
                        i := w;
                      end;
                    SetString(AnsiString(pKI^.Value.VBuffer), nil, i);
                    Stream.Read(PAnsiChar(pKI^.Value.VBuffer)^, i);
                  end;
      kvtString:  begin
                    if version in [2,3]
                     then Stream.Read(i, SizeOf(Integer)) //v1.46
                     else begin
                       Stream.Read(w, SizeOf(Word));
                       i := w;
                     end;
                    if version=3 then begin
                      SetString(sW, nil, i div 2);
                      Stream.Read(Pointer(sW)^, i);
                      RSLString(pKI^.Value.VString) := sW;
                    end else begin
                      SetString(sA, nil, i);
                      Stream.Read(Pointer(sA)^, i);
                      RSLString(pKI^.Value.VString) := String(sA);
                    end;
                  end;
{$IFDEF RSL_INT64}
      kvtInt64:   Stream.Read(pKI^.Value.VInt64, SizeOf(Int64));
{$ENDIF}
    end;
    Dec(KeyCnt);
    Inc(pKI);

    Inc(ProgressItemCurrent);
    DoProgress;
  end;
end;

procedure TrsBinData.SaveToStream(Stream: TStream);
var
  sA: AnsiString;
  i,j: integer;
  pKI: PrsKeyItem;
  pSI: PrsSectionItem;
  WriteUnicode: boolean;
  saveSectRec: TSaveSectionRecord;
  saveKeyRec: TSaveKeyRecord;
begin
  inherited;
{$IFDEF RSL_UNICODE}
  WriteUnicode := Unicode;
{$ELSE}
  WriteUnicode := False;
{$ENDIF}
  if WriteUnicode
    then sA := 'RS03' //real unicode
    else sA := 'RS02'; //v1.46
  Stream.Write(PAnsiChar(sA)^,Length(sA));
  Stream.Write(TIntStorage(Storage).SectionCountAll, SizeOf(Word));
  Stream.Write(TIntStorage(Storage).KeyCountAll,  SizeOf(Word));

  ProgressItemCount := TIntStorage(Storage).SectionCountAll + TIntStorage(Storage).KeyCountAll;
  DoProgress;

  //save sections
  if TIntStorage(Storage).SectionCountAll>0 then begin
    pSI := TIntStorage(Storage).GetSectionItem(0);
    i := 0;
    While i < TIntStorage(Storage).SectionCountAll do begin
      saveSectRec.id := Word(pSI^.Id);
      saveSectRec.parentid := Word(pSI^.ParentId);
      if WriteUnicode
        then saveSectRec.len := Length(pSI^.Name)*SizeOf(RSLChar)
        else saveSectRec.len := Length(pSI^.Name);
      Stream.Write(saveSectRec, SizeOf(TSaveSectionRecord));
      if WriteUnicode
        then Stream.Write(Pointer(pSI^.Name)^, Length(pSI^.Name)*SizeOf(RSLChar))
        else Stream.Write(PAnsiChar(AnsiString(pSI^.Name))^, Length(pSI^.Name));
      Inc(pSI);
      Inc(i);

      Inc(ProgressItemCurrent);
      DoProgress;
    end;
  end;

 if TIntStorage(Storage).KeyCountAll > 0 then begin
  pKI := TIntStorage(Storage).GetKeyItem(0);
  i := 0;
  While i < TIntStorage(Storage).KeyCountAll do begin
    saveKeyRec.id := Word(pKI^.SectionId);
    saveKeyRec.valuetype := Word(pKI^.Value.kvType);
    if WriteUnicode
      then saveKeyRec.len := Length(pKI^.Name)*SizeOf(RSLChar)
      else saveKeyRec.len := Length(pKI^.Name);
    Stream.Write(saveKeyRec, SizeOf(TSaveKeyRecord));
    if WriteUnicode
      then Stream.Write(Pointer(pKI^.Name)^, Length(pKI^.Name)*SizeOf(RSLChar))
      else Stream.Write(PAnsiChar(AnsiString(pKI^.Name))^, Length(pKI^.Name));

    Case pKI^.Value.kvType of
      kvtPointer:  Stream.Write(pKI^.Value.VPointer, SizeOf(Pointer));
      kvtInteger:  Stream.Write(pKI^.Value.VInteger, SizeOf(Integer));
      kvtDouble:   Stream.Write(pKI^.Value.VDouble, SizeOf(Double));
      kvtCurrency: Stream.Write(pKI^.Value.VCurrency, SizeOf(Currency));
      kvtDateTime: Stream.Write(pKI^.Value.VDateTime, SizeOf(TDateTime));
      kvtBool:     Stream.Write(pKI^.Value.VBoolean, SizeOf(Integer));
      kvtPoint:    begin
                     Stream.Write(pKI^.Value.X, SizeOf(Longint));
                     Stream.Write(pKI^.Value.Y, SizeOf(Longint));
                   end;
      kvtBuffer:   begin
                     j := Length(AnsiString(pKI^.Value.VBuffer));
                     Stream.Write(j, SizeOf(Integer));
                     Stream.Write(PAnsiChar(pKI^.Value.VBuffer)^, j);
                   end;
      kvtString:   begin
                     j := Length(RSLString(pKI^.Value.VString));
                     if WriteUnicode then begin
                       j := j*SizeOf(RSLChar);
                       Stream.Write(j, SizeOf(Integer));
                       Stream.Write(PWideChar(pKI^.Value.VString)^, j);
                     end else begin
                       Stream.Write(j, SizeOf(Integer));  //v1.46
                       Stream.Write(PAnsiChar(AnsiString(RSLString(pKI^.Value.VString)))^, j);
                     end;
                   end;
{$IFDEF RSL_INT64}
      kvtInt64:    Stream.Write(pKI^.Value.VInt64, SizeOf(Int64));
{$ENDIF}
    end;
    Inc(pKI);
    Inc(i);

    Inc(ProgressItemCurrent);
    DoProgress;
  end;
 end;
end;

end.
