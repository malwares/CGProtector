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
unit rsRegData;

interface

{$I rsStorage.inc}

uses Windows, Classes, SysUtils, rsStorage, rsConst, rsUtils;


type
  TrsRegRootKey = (rkClassesRoot, rkCurrentUser, rkLocalMachine, rkUsers,
                   rkPerformanceData, rkCurrentConfig, rkDynData);


  TrsRegData = class(TrsStorageData)
  private
    FRootPath: string;
    FRootKey: TrsRegRootKey;
    FRemoteComputerName: string;
{$IFDEF RSL_UNICODE}
    FUnicode: boolean;
{$ENDIF}
    function GetRootHKey: HKey;
    procedure RecursionLoadKey(Key: HKey);
    function  RecursionKeyCount(Key: HKey): integer;
    procedure RecursionDelKey(Key: HKey);
    procedure RecursionSaveKey(Key: HKey);
    procedure DelKeyContents(Key: HKey);
    procedure SetRootPath(const Value: string);
    function GetPrepareRemoteComputerName: string;

{$IFDEF RSL_UNICODE}
    procedure RecursionLoadKeyW(Key: HKey);
    procedure RecursionDelKeyW(Key: HKey);
    procedure DelKeyContentsW(Key: HKey);
{$ENDIF}
  protected
    isNT: boolean;
    procedure InternalLoad; override;
    procedure InternalSave; override;
  public
    constructor Create(AOwner: TComponent); override;
    procedure RootKeyAssign(const Key: HKey);
    property RemoteComputerName: string read FRemoteComputerName write FRemoteComputerName;
  published
    property RootKey: TrsRegRootKey read FRootKey write FRootKey default rkLocalMachine;
    property RootPath: string read FRootPath write SetRootPath;
{$IFDEF RSL_UNICODE}
    property Unicode: boolean read FUnicode write FUnicode default False;
{$ENDIF}
  end;


implementation


Type
  TintStorage = class(TrsStorage);

{ TrsRegData }

constructor TrsRegData.Create(AOwner: TComponent);
begin
  inherited Create(AOwner);
  RootKey := rkLocalMachine;
{$IFDEF RSL_UNICODE}
  FUnicode := False;
{$ENDIF}
  isNT := Win32Platform=VER_PLATFORM_WIN32_NT;
  FRemoteComputerName := '';
end;


procedure TrsRegData.DelKeyContents(Key: HKey);
var
  i, NumValues, MaxValuesNameLen, len: dword;
  ValueName: PAnsiChar;
begin
   RecursionDelKey(Key);

  if RegQueryInfoKeyW(Key, nil, nil, nil, nil, nil, nil, @NumValues, @MaxValuesNameLen, nil, nil, nil) = ERROR_SUCCESS
    then
  if NumValues>0 then begin
    Inc(MaxValuesNameLen);
    GetMem(ValueName, MaxValuesNameLen);
    for i:=NumValues-1 downto 0 do begin
      len := MaxValuesNameLen;
      if RegEnumValueA(Key, i, PAnsiChar(ValueName), len, nil, nil, nil, nil) = ERROR_SUCCESS
       then RegDeleteValueA(Key, PAnsiChar(ValueName));
    end;
    FreeMem(ValueName);
  end;
end;


{$IFDEF RSL_UNICODE}
procedure TrsRegData.DelKeyContentsW(Key: HKey);
var
  i, NumValues, MaxValuesNameLen, len: dword;
  ValueName: WideString;
begin
  RecursionDelKeyW(Key);

  if RegQueryInfoKey(Key, nil, nil, nil, nil, nil, nil, @NumValues, @MaxValuesNameLen, nil, nil, nil) = ERROR_SUCCESS
    then
  if NumValues>0 then begin
    Inc(MaxValuesNameLen);
    SetLength(ValueName, MaxValuesNameLen);
    for i:=NumValues-1 downto 0 do begin
      len := MaxValuesNameLen;
      if RegEnumValueW(Key, i, Pointer(@ValueName[1]), len, nil, nil, nil, nil) = ERROR_SUCCESS
        then RegDeleteValueW(Key, @ValueName[1]);
     end;
  end;
end;

procedure TrsRegData.RecursionDelKeyW(Key: HKey);
var
  TempKey: HKey;
  i,NumSubKeys,MaxSubKeyLen,len: dword;
  KeyName: WideString;
begin
  if RegQueryInfoKey(Key, nil, nil, nil, @NumSubKeys, @MaxSubKeyLen, nil, nil, nil, nil, nil, nil) = ERROR_SUCCESS
    then
  if NumSubKeys>0 then begin
    Inc(MaxSubKeyLen);
    SetLength(KeyName, MaxSubKeyLen);
    for i:=NumSubKeys-1 downto 0 do begin
      len := MaxSubKeyLen;
      if RegEnumKeyExW(Key, i, @KeyName[1], len, nil, nil, nil, nil) = ERROR_SUCCESS
        then begin
          if RegOpenKeyExW(Key, @KeyName[1], 0, KEY_READ or KEY_WRITE, TempKey)=ERROR_SUCCESS
            then begin
              if isNT then RecursionDelKeyW(TempKey);
              RegDeleteKeyW(Key, @KeyName[1]);
              RegCloseKey(TempKey);
            end;
        end;
    end;
  end;
end;
{$ENDIF}

function TrsRegData.GetRootHKey: HKey;
begin
  if Length(GetPrepareRemoteComputerName)>0 then begin
    case FRootKey of
      rkLocalMachine:    Result := HKEY_LOCAL_MACHINE;
      rkUsers:           Result := HKEY_USERS;
      else Result := 0;
    end;
    if Result<>0
      then begin
        if RegConnectRegistry(Pchar(GetPrepareRemoteComputerName), Result, Result)<>ERROR_SUCCESS
          then Result := 0;
      end;
  end else
    case FRootKey of
      rkClassesRoot:     Result := HKEY_CLASSES_ROOT;
      rkCurrentUser:     Result := HKEY_CURRENT_USER;
      rkLocalMachine:    Result := HKEY_LOCAL_MACHINE;
      rkUsers:           Result := HKEY_USERS;
      rkPerformanceData: Result := HKEY_PERFORMANCE_DATA;
      rkCurrentConfig:   Result := HKEY_CURRENT_CONFIG;
      rkDynData:         Result := HKEY_DYN_DATA;
      else Result := 0;
    end;
end;


procedure TrsRegData.InternalLoad;
var
  TempKey: HKey;
begin
  if (Storage=nil) or (Length(FRootPath)=0) then Exit;
  if RegOpenKeyEx(GetRootHKey, PChar(FRootPath), 0, KEY_READ, TempKey)=ERROR_SUCCESS
   then begin
     if Assigned(OnProgress) then ProgressItemCount := RecursionKeyCount(TempKey);
     {$IFDEF RSL_UNICODE}
     if Unicode and isNT then RecursionLoadKeyW(TempKey)
      else {$ENDIF} RecursionLoadKey(TempKey);
     RegCloseKey(TempKey);
   end;
end;


procedure TrsRegData.InternalSave;
var
  TempKey: HKey;
  ResCode: integer;
begin
  if (Storage=nil) or (Length(FRootPath)=0) then Exit;
  ResCode := RegOpenKeyEx(GetRootHKey, PChar(FRootPath), 0, KEY_READ or KEY_WRITE, TempKey);
  if ResCode=ERROR_SUCCESS
    then begin
      {$IFDEF RSL_UNICODE}
      if Unicode and isNT then DelKeyContentsW(TempKey)
       else {$ENDIF} DelKeyContents(TempKey);
    end else ResCode := RegCreateKeyEx(GetRootHKey, PChar(FRootPath), 0, nil, REG_OPTION_NON_VOLATILE, KEY_WRITE, nil, TempKey, nil);

  if ResCode=ERROR_SUCCESS then begin
    ProgressItemCount := TIntStorage(Storage).KeyCountAll;
    DoProgress;
    RecursionSaveKey(TempKey);
    RegCloseKey(TempKey);
  end else rsError(egRegData, 'Open/Create key. Code '+IntToStr(ResCode));
end;


procedure TrsRegData.RecursionDelKey(Key: HKey);
var
  TempKey: HKey;
  i,NumSubKeys,MaxSubKeyLen,len: dword;
  KeyName: PAnsiChar;
begin
  if RegQueryInfoKeyA(Key, nil, nil, nil, @NumSubKeys, @MaxSubKeyLen, nil, nil, nil, nil, nil, nil) = ERROR_SUCCESS
    then
  if NumSubKeys>0 then begin
    Inc(MaxSubKeyLen);
    GetMem(KeyName, MaxSubKeyLen);
    for i:=NumSubKeys-1 downto 0 do begin
      len := MaxSubKeyLen;
      if RegEnumKeyExA(Key, i, KeyName, len, nil, nil, nil, nil) = ERROR_SUCCESS
        then begin
          if RegOpenKeyExA(Key, KeyName, 0, KEY_READ or KEY_WRITE, TempKey)=ERROR_SUCCESS
            then begin
              if isNT then RecursionDelKey(TempKey);
              RegDeleteKeyA(Key, KeyName);
              RegCloseKey(TempKey);
            end;
        end;
    end;
    FreeMem(KeyName);
  end;
end;


function TrsRegData.RecursionKeyCount(Key: HKey): integer;
var
  TempKey: HKey;
  SubKeyCnt, SubValueCnt: integer;
  s: array[0..RSMAX_PATH] of Char;
  len: DWord;
begin
  Result := 0;
  if RegQueryInfoKey(Key, nil, nil, nil, @SubKeyCnt, nil, nil, @SubValueCnt, nil, nil, nil, nil)<>ERROR_SUCCESS then Exit;
  Result := SubValueCnt;

  Dec(SubKeyCnt);
  While SubKeyCnt>=0 do begin
    len := RSMAX_PATH;
    if RegEnumKeyEx(Key, SubKeyCnt, s, len, nil, nil, nil, nil)<>ERROR_SUCCESS then Break;
    if RegOpenKeyEx(Key, s, 0, KEY_READ, TempKey)=ERROR_SUCCESS
     then begin
       Result := Result + RecursionKeyCount(TempKey);
       RegCloseKey(TempKey);
     end;
    Dec(SubKeyCnt);
  end;
end;

procedure TrsRegData.RecursionLoadKey(Key: HKey);
var
  TempKey: HKey;
  ValType, ValSize: integer;
  len,lenV: DWord;
  sData: AnsiString;
  lmaxValueDataSize: dword;
  SubKeyCnt, SubValueCnt: integer;
  s,sV: array[0..RSMAX_PATH] of AnsiChar;
begin
  if RegQueryInfoKeyA(Key, nil, nil, nil, @SubKeyCnt, nil, nil, @SubValueCnt, nil, @lmaxValueDataSize, nil, nil)<>ERROR_SUCCESS then Exit;
  SetString(sData, nil, lmaxValueDataSize);

  Dec(SubValueCnt);
  While SubValueCnt>=0 do begin
    lenV := RSMAX_PATH;
    if RegEnumValueA(Key, SubValueCnt, sV, lenV, nil, nil, nil, nil)<>ERROR_SUCCESS then Break;
    ValSize := lmaxValueDataSize;
    if RegQueryValueExA(Key, sV, nil, @ValType, Pointer(sData), @ValSize)<>ERROR_SUCCESS then Break;
    if ValSize=0 then FillChar(PAnsiChar(sData)^, lmaxValueDataSize, 0);    //07.03.2002 Read empty string bug
    case ValType of
      REG_EXPAND_SZ,
      REG_SZ: {$IFDEF RSL_UNICODE}
              if Unicode then
                 Storage.WriteString(PChar(@sV), PWideChar(Pointer(sData)))
              else {$ENDIF} Storage.WriteString(RSLString(sV), Copy(String(sData), 1, ValSize-1));
      REG_DWORD: Storage.WriteInteger(RSLString(sV), PInteger(sData)^);
      REG_BINARY: begin
                    if (ValSize=(SizeOf(Word)+SizeOf(Double))) and (PWord(sData)^=kvtDouble)
                     then Storage.WriteFloat(RSLString(sV), PDouble(Integer(sData)+SizeOf(Word))^)
                     else
                    if (ValSize=(SizeOf(Word)+SizeOf(Currency))) and (PWord(sData)^=kvtCurrency)
                     then Storage.WriteFloat(RSLString(sV), PCurrency(Integer(sData)+SizeOf(Word))^)
                     else
                    if (ValSize=(SizeOf(Word)+SizeOf(TDateTime))) and (PWord(sData)^=kvtDateTime)
                     then Storage.WriteDateTime(RSLString(sV), PDateTime(Integer(sData)+SizeOf(Word))^)
                     else
                    if (ValSize=(SizeOf(Word)+SizeOf(TPoint))) and (PWord(sData)^=kvtPoint)
                     then Storage.WritePoint(RSLString(sV), PPoint(Integer(sData)+SizeOf(Word))^)
                     else {$IFDEF RSL_INT64}
                    if (ValSize=(SizeOf(Word)+SizeOf(Int64))) and (PWord(sData)^=kvtInt64)
                     then Storage.WriteInt64(RSLString(sV), PInt64(Integer(sData)+SizeOf(Word))^)
                     else {$ENDIF} Storage.WriteBuffer(RSLString(sV), Pointer(sData)^, ValSize);
                  end;
      else;
    end;
    Dec(SubValueCnt);
    Inc(ProgressItemCurrent);
    DoProgress;
  end;

  Dec(SubKeyCnt);
  While SubKeyCnt>=0 do begin
    len := RSMAX_PATH;
    if RegEnumKeyExA(Key, SubKeyCnt, s, len, nil, nil, nil, nil)<>ERROR_SUCCESS then Break;
    Storage.SectionAdd(RSLString(s));

    if RegOpenKeyExA(Key, s, 0, KEY_READ, TempKey)=ERROR_SUCCESS
     then begin
       if Storage.ChangeDownRootSection(RSLString(s)) then begin
         RecursionLoadKey(TempKey);
         RegCloseKey(TempKey);
         Storage.ChangeUpRootSection;
       end;
     end;
    Dec(SubKeyCnt);
  end;
end;

{$IFDEF RSL_UNICODE}
procedure TrsRegData.RecursionLoadKeyW(Key: HKey);
var
  TempKey: HKey;
  ValType, ValSize: integer;
  len,lenV: DWord;
  sData: WideString;
  lmaxValueDataSize: dword;
  SubKeyCnt, SubValueCnt: integer;
  s,sV: array[0..RSMAX_PATH] of WideChar;
  e: longint;
begin
  if RegQueryInfoKeyW(Key, nil, nil, nil, @SubKeyCnt, nil, nil, @SubValueCnt, nil, @lmaxValueDataSize, nil, nil)<>ERROR_SUCCESS then Exit;
  SetString(sData, nil, lmaxValueDataSize);

  Dec(SubValueCnt);
  While SubValueCnt>=0 do begin
    lenV := RSMAX_PATH*SizeOf(RSLChar);
    if RegEnumValueW(Key, SubValueCnt, Pointer(@sV[0]), lenV, nil, nil, nil, nil)<>ERROR_SUCCESS then Break;
    ValSize := lmaxValueDataSize;
    if RegQueryValueExW(Key, sV, nil, @ValType, Pointer(sData), @ValSize)<>ERROR_SUCCESS then Break;
    if ValSize=0 then FillChar(PWideChar(sData)^, lmaxValueDataSize*SizeOf(RSLChar), 0);    //07.03.2002 Read empty string bug
    case ValType of
      REG_EXPAND_SZ,
      REG_SZ: Storage.WriteString(PRSLChar(@sV), PRSLChar(sData));
      REG_DWORD: Storage.WriteInteger(PRSLChar(@sV), PInteger(sData)^);
      REG_BINARY: begin
                    if (ValSize=(SizeOf(Word)+SizeOf(Double))) and (PWord(sData)^=kvtDouble)
                     then Storage.WriteFloat(PRSLChar(@sV), PDouble(Integer(sData)+SizeOf(Word))^)
                     else
                    if (ValSize=(SizeOf(Word)+SizeOf(Currency))) and (PWord(sData)^=kvtCurrency)
                     then Storage.WriteFloat(PRSLChar(@sV), PCurrency(Integer(sData)+SizeOf(Word))^)
                     else
                    if (ValSize=(SizeOf(Word)+SizeOf(TDateTime))) and (PWord(sData)^=kvtDateTime)
                     then Storage.WriteDateTime(PRSLChar(@sV), PDateTime(Integer(sData)+SizeOf(Word))^)
                     else
                    if (ValSize=(SizeOf(Word)+SizeOf(TPoint))) and (PWord(sData)^=kvtPoint)
                     then Storage.WritePoint(PRSLChar(@sV), PPoint(Integer(sData)+SizeOf(Word))^)
                     else {$IFDEF RSL_INT64}
                    if (ValSize=(SizeOf(Word)+SizeOf(Int64))) and (PWord(sData)^=kvtInt64)
                     then Storage.WriteInt64(PRSLChar(@sV), PInt64(Integer(sData)+SizeOf(Word))^)
                     else {$ENDIF} Storage.WriteBuffer(PRSLChar(@sV), Pointer(sData)^, ValSize);
                  end;
      else;
    end;
    Dec(SubValueCnt);
    Inc(ProgressItemCurrent);
    DoProgress;
  end;

  Dec(SubKeyCnt);
  While SubKeyCnt>=0 do begin
    len := RSMAX_PATH;
    if RegEnumKeyExW(Key, SubKeyCnt, s, len, nil, nil, nil, nil)<>ERROR_SUCCESS then Break;
    Storage.SectionAdd(PWideChar(@s));

    e := RegOpenKeyExW(Key, s, 0, KEY_READ, TempKey);
    if e=ERROR_SUCCESS
     then begin
       if Storage.ChangeDownRootSection(PWideChar(@s)) then begin
         RecursionLoadKeyW(TempKey);
         RegCloseKey(TempKey);
         Storage.ChangeUpRootSection;
       end;
     end else rsError(egRegData, 'Open key. Code '+IntToStr(e));
    Dec(SubKeyCnt);
  end;
end;
{$ENDIF}


procedure TrsRegData.RecursionSaveKey(Key: HKey);
var
  i, k, KeyRangeBegin, KeyRangeEnd, RngBegin, RngEnd: integer;
  pKI: PrsKeyItem;
  pSI: PrsSectionItem;
  buf: array[0..9] of AnsiChar;
  TempKey: HKey;
  p: Pointer;
  sA: AnsiString;
{$IFDEF RSL_UNICODE}
  sW: WideString;
{$ENDIF}
  e: longint;
begin
if TintStorage(Storage).GetKeyRange(KeyRangeBegin, KeyRangeEnd) then
  for i:=KeyRangeBegin to KeyRangeEnd-1 do begin
    pKI := TintStorage(Storage).GetKeyItem(i);
    {$IFDEF RSL_UNICODE}
    if Unicode and isNT
      then p := Pointer(RSLString(pKI^.Name))
      else {$ENDIF} p := Pointer(AnsiString(RSLString(pKI^.Name)));
    case pKI^.Value.kvType of
      kvtPointer: {$IFDEF RSL_UNICODE}
                  if Unicode and isNT then
                    RegSetValueExW(Key, p, 0, REG_DWORD, @pKI^.Value.VPointer, SizeOf(Pointer))
                  else {$ENDIF} RegSetValueExA(Key, p, 0, REG_DWORD, @pKI^.Value.VPointer, SizeOf(Pointer));
      kvtInteger: {$IFDEF RSL_UNICODE}
                  if Unicode and isNT then
                    RegSetValueExW(Key, p, 0, REG_DWORD, @pKI^.Value.VInteger, SizeOf(Integer))
                  else {$ENDIF} RegSetValueExA(Key, p, 0, REG_DWORD, @pKI^.Value.VInteger, SizeOf(Integer));
      kvtDateTime,
      kvtCurrency,
      kvtDouble:
               begin
                 PWord(@buf)^ := pKI^.Value.kvType;
                 PDouble(@buf[2])^ := pKI^.Value.VDouble;
                 {$IFDEF RSL_UNICODE}
                  if Unicode and isNT then
                    RegSetValueExW(Key, p, 0, REG_BINARY, @buf, SizeOf(Word)+SizeOf(double))
                  else {$ENDIF} RegSetValueExA(Key, p, 0, REG_BINARY, @buf, SizeOf(Word)+SizeOf(double));
               end;
      kvtPoint:begin
                 PWord(@buf)^ := pKI^.Value.kvType;
                 PPoint(@buf[2])^.x := pKI^.Value.X;
                 PPoint(@buf[2])^.y := pKI^.Value.Y;
                 {$IFDEF RSL_UNICODE}
                 if Unicode and isNT then
                   RegSetValueExW(Key, p, 0, REG_BINARY, @buf, SizeOf(Word)+SizeOf(TPoint))
                 else {$ENDIF} RegSetValueExA(Key, p, 0, REG_BINARY, @buf, SizeOf(Word)+SizeOf(TPoint));
               end;
      kvtBool:   {$IFDEF RSL_UNICODE}
                 if Unicode and isNT then
                   RegSetValueExW(Key, p, 0, REG_DWORD, @pKI^.Value.VBoolean, SizeOf(Integer))
                 else {$ENDIF} RegSetValueExA(Key, p, 0, REG_DWORD, @pKI^.Value.VBoolean, SizeOf(Integer));
      kvtString : begin
                    {$IFDEF RSL_UNICODE}
                    if Unicode then begin
                      sW := RSLString(pKI^.Value.VString);
                      k := (Length(sW)+1)*SizeOf(RSLChar);
                      if k=SizeOf(RSLChar) then sW := #0#0;

                      if isNT then begin
                        RegSetValueExW(Key, p, 0, REG_SZ, Pointer(sW), k);
                      end else begin
                        RegSetValueExA(Key, p, 0, REG_SZ, Pointer(sW), k);
                      end;
                    end else begin {$ENDIF}
                      sA := AnsiString(RSLString(pKI^.Value.VString));
                      k := Length(sA)+1;
                      if k=1 then sA := #0;
                      RegSetValueExA(Key, p, 0, REG_SZ, Pointer(sA), k);
                    {$IFDEF RSL_UNICODE}
                    end;
                    {$ENDIF}
                  end;
      kvtBuffer : {$IFDEF RSL_UNICODE}
                  if Unicode and isNT then
                    RegSetValueExW(Key, p, 0, REG_BINARY, pKI^.Value.VBuffer, Length(AnsiString(pKI^.Value.VBuffer)))
                  else {$ENDIF} RegSetValueExA(Key, p, 0, REG_BINARY, pKI^.Value.VBuffer, Length(AnsiString(pKI^.Value.VBuffer)));
{$IFDEF RSL_INT64}
      kvtInt64:begin
                 PWord(@buf)^ := pKI^.Value.kvType;
                 PInt64(@buf[2])^ := pKI^.Value.VInt64;
                 {$IFDEF RSL_UNICODE}
                  if Unicode and isNT then
                    RegSetValueExW(Key, p, 0, REG_BINARY, @buf, SizeOf(Word)+SizeOf(double))
                  else {$ENDIF} RegSetValueExA(Key, p, 0, REG_BINARY, @buf, SizeOf(Word)+SizeOf(double));
               end;
{$ENDIF}
    end;
    Inc(ProgressItemCurrent);
    DoProgress;
  end;

if TintStorage(Storage).GetSectionChildRange(KeyRangeBegin, KeyRangeEnd) then
  for i:=KeyRangeBegin to KeyRangeEnd-1 do begin
    pSI := TintStorage(Storage).GetSectionItem(i);
    if Storage.ChangeDownRootSection(pSI^.Name) then begin
      if TintStorage(Storage).GetKeyRange(RngBegin, RngEnd) or
         TintStorage(Storage).GetSectionChildRange(RngBegin, RngEnd) or
         (soSaveEmptySection in Storage.Options)
        then begin
          {$IFDEF RSL_UNICODE}
          if Unicode and isNT then
            e := RegCreateKeyExW(Key, Pointer(RSLString(pSI^.Name)), 0, nil, REG_OPTION_NON_VOLATILE, KEY_WRITE, nil, TempKey, nil)
           else {$ENDIF} e := RegCreateKeyExA(Key, Pointer(AnsiString(RSLString(pSI^.Name))), 0, nil, REG_OPTION_NON_VOLATILE, KEY_WRITE, nil, TempKey, nil);
          if e=ERROR_SUCCESS
           then begin
             RecursionSaveKey(TempKey);
             RegCloseKey(TempKey);
           end else rsError(egRegData, 'Create key. Code '+IntToStr(e));
        end;
      Storage.ChangeUpRootSection;
    end;
  end;
end;

procedure TrsRegData.RootKeyAssign(const Key: HKey);
begin
  case Key of
    HKEY_CLASSES_ROOT:     RootKey := rkClassesRoot;
    HKEY_CURRENT_USER:     RootKey := rkCurrentUser;
    HKEY_LOCAL_MACHINE:    RootKey := rkLocalMachine;
    HKEY_USERS:            RootKey := rkUsers;
    HKEY_PERFORMANCE_DATA: RootKey := rkPerformanceData;
    HKEY_CURRENT_CONFIG:   RootKey := rkCurrentConfig;
    HKEY_DYN_DATA:         RootKey := rkDynData;
  end;
end;

procedure TrsRegData.SetRootPath(const Value: string);
var
  i: integer;
begin
  FRootPath := Value;
  while (Length(FRootPath)>0) and (FRootPath[1] in cSectionSeparators)
   do Delete(FRootPath, 1, 1);
  while True do begin
    i := Length(FRootPath);
    if (i>0) and (FRootPath[i] in cSectionSeparators) then Delete(FRootPath, i, 1)
     else Break;
  end;
end;

function TrsRegData.GetPrepareRemoteComputerName: string;
begin
  Result := FRemoteComputerName;
  if Length(Result)>0 then begin
    if Result[1]<>'\'
      then Result := '\\'+Result;
  end;
end;

end.
