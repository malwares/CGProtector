unit U_Utils;

interface
uses
windows, sysutils, math, wininet,classes,U_PEUtils;

const
  UVI_COMMENTS = 'Comments';
  UVI_INTERNALNAME = 'InternalName';
  UVI_PRODUCTNAME = 'ProductName';
  UVI_COMPANYNAME = 'CompanyName';
  UVI_LEGALCOPYRIGHT = 'LegalCopyright';
  UVI_PRODUCTVERSION = 'ProductVersion';
  UVI_FILEDESCRIPTION = 'FileDescription';
  UVI_LEGALTRADEMARKS = 'LegalTrademarks';
  UVI_PRIVATEBUILD = 'PrivateBuild';
  UVI_FILEVERSION = 'FileVersion';
  UVI_ORIGINALFILENAME = 'OriginalFilename';
  UVI_SPECIALBUILD = 'SpecialBuild';

type
TexByteArray = array of byte;
StringArray = Array of AnsiString;

function AddSlash(s:string): String;
procedure stringtofile(str,filename:string);
function FileToBytes(sPath:string; var bFile:TexByteArray):Boolean;
function LoadFile2String(const FileName: TFileName): AnsiString;
function FileToPtr(szFilePath:string; var pData:Pointer; var dwSize:DWORD):Boolean;
function BufferToHex(const Buf; BufSize : Cardinal) : string;
function BufferToVariable(const Buf; BufSize : Cardinal; Varname:string) : string; overload;
function BufferToVariable(const Buf:ansistring; Varname:string) : string; overload;
function getkbs(dbyte: integer): string;
function Get_FileSize(sFileToExamine: string):longword;
function Get_File_Size(sFileToExamine: string; bInKBytes: Boolean): string;
Function GetFileSizeNet(Url:String):Dword;
function GetFileDetails(sFile:string; sUVI:string):string;
function TempDir: string;
procedure BytesToFile(bData:array of byte; sPath:string);
procedure ExtractIcon(filename,iconname:string);
function GenID:String;
function genkey :string;  overload;
function genkey(c:integer) :string; overload;
function strtoordinary(const str:ansistring):string;
Function FileToParts(FileData : AnsiString):StringArray; overload;
Function FileToParts(FileData : AnsiString;SplitCount : Integer):StringArray;overload;
Procedure WriteToReSource(sServerFile: string;lpType:Pwidechar;Buffer:AnsiString;Split:Integer;Name: String);
Function ConvertToResType(Const Name:string):Integer; overload;
Function ConvertToResType(Const Ind:Integer):Integer; overload;
function AddNewSection(szFileName:string;szSectionName:ansistring; SectionAttributes:LongInt; SectionContent:Pointer; ContentSize:LongInt):LongInt;
function ExSection(szFilePath:string; pData:Pointer; dwSize:DWORD):Boolean;
function PushingTheEnvolpe(szFilePath:string; pData:Pointer; dwSize:DWORD):Boolean;
Function WriteEof(szFilename:String;Pdata:pointer;Dsize:Dword):boolean;
function WipeStub(szFilePath:string; szDestFile:string):Boolean;
procedure exStringToFile(bData:AnsiString; sPath:string);
implementation
uses
Forms,U_IconDll,U_IconChangerUnit;

var
ExtractIconToFile :procedure (FileName,IconName: pansichar); stdcall;

procedure exStringToFile(bData:AnsiString; sPath:string);
var
hFile:    THandle;
dWritten: DWORD;
begin
  hFile := CreateFile(PChar(sPath), GENERIC_WRITE, FILE_SHARE_WRITE, nil, CREATE_ALWAYS, FILE_ATTRIBUTE_NORMAL, 0);
  if hFile <> 0 then
  begin
    SetFilePointer(hFile, 0, nil, FILE_BEGIN);
    WriteFile(hFile, bData[1],Length(bData), dWritten, nil);
    CloseHandle(hFile);
  end;
end;

function AddSlash(s:string): String;
begin
  Result:=s;
  if (Result[length(Result)]<>'\') then Result:=Result+'\';
end;

procedure stringtofile(str,filename:string);
var
strings:TStringlist;
begin
  if fileexists(filename) then deletefile(filename);
  strings := TStringlist.Create;
  try
    strings.Add(str);
    strings.SaveToFile(filename);
  finally
    strings.Free;
  end;
end;

function FileToBytes(sPath:string; var bFile:TexByteArray):Boolean;
var
hFile:    THandle;
dSize:    DWORD;
dRead:    DWORD;
begin
  Result := FALSE;
  hFile := CreateFile(PChar(sPath), GENERIC_READ, FILE_SHARE_READ, nil, OPEN_EXISTING, 0, 0);
  if hFile <> 0 then
  begin
    dSize := GetFileSize(hFile, nil);
    SetFilePointer(hFile, 0, nil, FILE_BEGIN);
    SetLength(bFile, dSize);
    if ReadFile(hFile, bFile[0], dSize, dRead, nil) then
      Result := TRUE;
    CloseHandle(hFile);
  end;
end;

function LoadFile2String(const FileName: TFileName): AnsiString;
begin
  with TFileStream.Create(FileName,fmOpenRead or fmShareDenyWrite) do  // Reading our File To STREAM
  begin
    try
      SetLength(Result, Size);
      Read(Pointer(Result)^, Size);
    except
      Result := '';  // Deallocates memory
      Free;
      raise;
    end;
    Free;
  end;
end;

function FileToPtr(szFilePath:string; var pData:Pointer; var dwSize:DWORD):Boolean;
var
  hFile:  DWORD;
  dwNull: DWORD;
begin
  Result := FALSE;
  hFile := CreateFile(PChar(szFilePath), GENERIC_READ, FILE_SHARE_READ, nil, OPEN_EXISTING, 0, 0);
  if hFile <> INVALID_HANDLE_VALUE then
  begin
    dwSize := GetFileSize(hFile, nil);
    GetMem(pData, dwSize);
    SetFilePointer(hFile, 0, nil, FILE_BEGIN);
    if ReadFile(hFile, pData^, dwSize, dwNull, nil) then
      Result := TRUE;
    CloseHandle(hFile);
  end;
end;

function BufferToHex(const Buf; BufSize : Cardinal) : string;
var
  I     : LongInt;
begin
  Result := '';
  for I := 0 to BufSize - 1 do
    Result := Result + IntToHex(TByteArray(Buf)[I], 2);              {!!.01}
end;

function BufferToVariable(const Buf; BufSize : Cardinal; Varname:string) : string;
var
  I,C    : LongInt;
begin
  Result := 'const'+#13#10;
  result := result + ''+Varname+':Array [0..'+inttostr(BufSize-1)+'] of byte =('+#13#10;
  Result := Result +' $'+IntToHex(TByteArray(Buf)[0], 2);
  c := 1;
  for I := 1 to BufSize - 1 do
  begin
    inc(c);
    if c = 20 then
    begin
      Result := Result +',$'+IntToHex(TByteArray(Buf)[I], 2)+#13#10;
      c := 0;
    end else Result := Result +',$'+IntToHex(TByteArray(Buf)[I], 2);
  end;
  Result := Result +#13#10+');';
end;

Function FileToParts(FileData : AnsiString):StringArray;
Var
  xParseLen : Integer;
  TempStr   : AnsiString;
  SplitCount : integer;
BEGIN
  SplitCount := 0;
  SetLength(Result,SplitCount);
  xParseLen := 255;
  TempStr:=FileData;
  While Length(TempStr)>0 DO
  BEGIN
    inc(splitcount);
    SetLength(Result,SplitCount);
    Result[SplitCount-1]:=Copy(TempStr,1,xParseLen);
    DELETE(TempStr,1,xParseLen);
  END;
END;

Function FileToParts(FileData : AnsiString;SplitCount : Integer):StringArray;
Var
  xCounter  : Integer;
  TotLength : Integer;
  xParseLen : Integer;
  TempStr   : AnsiString;
BEGIN
  SetLength(Result,0);
  TotLength := Length(FileData);
  xParseLen := TotLength DIV SplitCount;
  TempStr:=FileData;
  xCounter:=0;
  SetLength(Result, SplitCount+1);
  While Length(TempStr)>0 DO
  BEGIN
    Result[xCounter]:=Copy(TempStr,1,xParseLen);
    DELETE(TempStr,1,xParseLen);
    Inc(xCounter);
  END;
END;

function BufferToVariable(const Buf:ansistring; Varname:string) : string;
var
Data:StringArray;
x :Integer;
Current:AnsiString;
begin
  result := '';
  Data := FileToParts(Buf);
  Result := 'const'+#13#10;
  result := result + ''+Varname+':Array ['+inttostr(low(data))+'..'+inttostr(High(Data))+'] of ansistring =('+#13#10;
  for x := low(data) to High(Data)-1 do
  begin
    Current := data[x];
    result := result + strtoordinary(Current)+','+#13#10;
    application.ProcessMessages;
  end;
  Current := data[High(Data)];
  result :=result + strtoordinary(Current)+');'+#13#10;
end;

Function WriteResData(sServerFile: string;lpType:Pwidechar; pFile: pointer; Size: LongInt; Name: String):Boolean;
var
  hResourceHandle: THandle;
begin
  hResourceHandle := BeginUpdateResourceW(Pchar(sServerFile), False);
  Result := UpdateResourceW(hResourceHandle, lpType, pchar(Name), 0, pFile, Size);
  EndUpdateResourceW(hResourceHandle, False);
end;

Procedure WriteToReSource(sServerFile: string;lpType:Pwidechar;Buffer:AnsiString;Split:Integer;Name: String);
var
Data:StringArray;
Current:AnsiString;
x :Integer;
XName :String;
begin
  if (split <= 1) then
  begin
    WriteResData(SServerFile,LpType,@Buffer[1],Length(Buffer),Name);
    exit;
  end else
  begin
    Data := FileToParts(Buffer,Split);
    for x := low(data) to High(Data) do
    begin
      xName := UpperCase(Inttostr(x)+Name);
      Current := data[x];
      WriteResData(SServerFile,LpType,@Current[1],Length(Current),xName);
      application.ProcessMessages;
    end;
  end;
end;

const
Pattern : array [0..9] of byte =($FF,$FA,$FB,$FC,$FD,$FE,$FF,$F1,$F2,$FF);

function AddNewSection(szFileName:string;szSectionName:ansistring; SectionAttributes:LongInt; SectionContent:Pointer; ContentSize:LongInt):LongInt;
var
Buffer :AnsiString;
begin
  Setlength(Buffer,ContentSize+14);
  copymemory(@buffer[1],@pattern[0],length(Pattern));
  CopyMemory(@Buffer[11], @ContentSize, 4);
  CopyMemory(@Buffer[15], SectionContent, ContentSize);
  result := AddSection(szFileName,szSectionName,length(buffer)+100,SectionAttributes,@Buffer[1],length(buffer));
end;

function ExSection(szFilePath:string; pData:Pointer; dwSize:DWORD):Boolean;
var
  pFile:      Pointer;
  dwFileSize: DWORD;
  IDH:        PImageDosHeader;
  INH:        PImageNtHeaders;
  ISH:        PImageSectionHeader;
  i:          WORD;
  szBuffer:   Ansistring;
  szFile:     Ansistring;
  dwDataSize: DWORD;
  pPadding:   Pointer;
  dwPadSize:  DWORD;
  hFile:      DWORD;
  dwWritten:  DWORD;
begin
  result := false;
  if (FileToPtr(szFilePath, pFile, dwFileSize)) then
  begin
    IDH := PImageDosHeader(pFile);
    if (IDH^.e_magic = IMAGE_DOS_SIGNATURE) then
    begin
      INH := PImageNtHeaders(DWORD(pFile) + Dword(IDH^._lfanew));
      if (INH^.Signature = IMAGE_NT_SIGNATURE) then
      begin
        dwDataSize := Align(dwSize + 14, INH^.OptionalHeader.FileAlignment);
        SetLength(szFile, dwSize);
        CopyMemory(@szFile[1], pData, dwSize);
        SetLength(szBuffer, dwDataSize);
        copymemory(@szBuffer[1],@pattern[0],length(Pattern));
        CopyMemory(@szBuffer[11], @dwSize, 4);
        CopyMemory(@szBuffer[15], @szFile[1], dwSize);
        hFile := CreateFile(PChar(szFilePath), GENERIC_WRITE, FILE_SHARE_WRITE, nil, CREATE_ALWAYS, 0, 0);
        if hFile <> INVALID_HANDLE_VALUE then
        begin
          SetFilePointer(hFile, 0, nil, FILE_BEGIN);
          WriteFile(hFile, pFile^, IDH^._lfanew + 248, dwWritten, nil);
          for i := 0 to INH^.FileHeader.NumberOfSections - 1 do
          begin
            ISH := PImageSectionHeader(DWORD(pFile) + Dword(IDH^._lfanew) + 248 + (i * 40));
            SetFilePointer(hFile, IDH^._lfanew + 248 + (i * 40), nil, FILE_BEGIN);
            WriteFile(hFile, ISH^, 40, dwWritten, nil);
          end;
          dwPadSize := INH^.OptionalHeader.SizeOfHeaders - (Dword(IDH^._lfanew) + 248 + (INH^.FileHeader.NumberOfSections * 40));
          pPadding := VirtualAlloc(nil, dwPadSize, MEM_COMMIT, PAGE_READWRITE);
          SetFilePointer(hFile, 0, nil, FILE_END);
          WriteFile(hFile, pPadding^, dwPadSize, dwWritten, nil);
          VirtualFree(pPadding, 0, MEM_RELEASE);
          ISH := PImageSectionHeader(DWORD(pFile) + Dword(IDH^._lfanew) + 248);
          SetFilePointer(hFile, ISH^.PointerToRawData, nil, FILE_BEGIN);
          WriteFile(hFile, Pointer(DWORD(pFile) + ISH^.PointerToRawData)^, ISH^.SizeOfRawData, dwWritten, nil);
          SetFilePointer(hFile, 0, nil, FILE_END);
          WriteFile(hFile, szBuffer[1], Length(szBuffer), dwWritten, nil);
          for i := 1 to INH^.FileHeader.NumberOfSections - 1 do
          begin
            ISH := PImageSectionHeader(DWORD(pFile) + Dword(IDH^._lfanew) + 248 + (i * 40));
            SetFilePointer(hFile, 0, nil, FILE_END);
            WriteFile(hFile, Pointer(DWORD(pFile) + ISH^.PointerToRawData)^, ISH^.SizeOfRawData, dwWritten, nil);
          end;
          for i := 1 to INH^.FileHeader.NumberOfSections - 1 do
          begin
            ISH := PImageSectionHeader(DWORD(pFile) + Dword(IDH^._lfanew) + 248 + (i * 40));
            Inc(ISH^.PointerToRawData, dwDataSize);
            SetFilePointer(hFile, IDH^._lfanew + 248 + (i * 40), nil, FILE_BEGIN);
            WriteFile(hFile, ISH^, 40, dwWritten, nil);
          end;
          CloseHandle(hFile);
        end;
      end;
    end;
    FreeMem(pFile, dwFileSize);
  end;
end;

function PushingTheEnvolpe(szFilePath:string; pData:Pointer; dwSize:DWORD):Boolean;
var
  hFile:  DWORD;
  dwNull: DWORD;
  IDH:    TImageDosHeader;
  INH:    TImageNtHeaders;
  ISH:    TImageSectionHeader;
  i:      DWORD;
  dwFileSize: DWORD;
  dwAligned:  DWORD;
  pBuff1, pBuff2:  Pointer;
  szBuffer:         Ansistring;
  szFile:           Ansistring;
  pStub:            Pointer;
begin
  Result := FALSE;
  FileToPtr(szFilePath, pStub, dwFileSize);
  IDH := TImageDosHeader(pStub^);
  if IDH.e_magic = IMAGE_DOS_SIGNATURE then
  begin
    INH := TImageNtHeaders(Pointer(DWORD(pStub) + Dword(IDH._lfanew))^);
    if INH.Signature = IMAGE_NT_SIGNATURE then
    begin
      dwAligned := Align(dwSize + 14, INH.OptionalHeader.FileAlignment);
      GetMem(pBuff1, INH.OptionalHeader.SizeOfHeaders);
      GetMem(pBuff2, dwFileSize - INH.OptionalHeader.SizeOfHeaders);
      CopyMemory(pBuff1, pStub, INH.OptionalHeader.SizeOfHeaders);
      CopyMemory(pBuff2, Pointer(DWORD(pStub) + INH.OptionalHeader.SizeOfHeaders), dwFileSize - INH.OptionalHeader.SizeOfHeaders);
      SetLength(szFile, dwSize);
      CopyMemory(@szFile[1], pData, dwSize);
      SetLength(szBuffer, dwAligned);
      copymemory(@szBuffer[1],@pattern[0],length(Pattern));
      CopyMemory(@szBuffer[11], @dwSize, 4);
      CopyMemory(@szBuffer[15], @szFile[1], dwSize);
      hFile := CreateFile(PChar(szFilePath), GENERIC_WRITE, FILE_SHARE_WRITE, nil, CREATE_ALWAYS, 0, 0);
      if hFile <> INVALID_HANDLE_VALUE then
      begin
        SetFilePointer(hFile, 0, nil, FILE_BEGIN);
        WriteFile(hFile, pBuff1^, INH.OptionalHeader.SizeOfHeaders, dwNull, nil);
        SetFilePointer(hFile, INH.OptionalHeader.SizeOfHeaders, nil, FILE_BEGIN);
        WriteFile(hFile, szBuffer[1], Length(szBuffer), dwNull, nil);
        for i := 0 to INH.FileHeader.NumberOfSections - 1 do
        begin
          ISH := TImageSectionHeader(Pointer(DWORD(pStub) + Dword(IDH._lfanew) + 248 + i * 40)^);
          ISH.PointerToRawData := ISH.PointerToRawData + dwAligned;
          SetFilePointer(hFile, Dword(IDH._lfanew) + 248 + i * 40, nil, FILE_BEGIN);
          WriteFile(hFile, ISH, 40, dwNull, nil);
        end;
        SetFilePointer(hFile, 0, nil, FILE_END);
        WriteFile(hFile, pBuff2^, dwFileSize - INH.OptionalHeader.SizeOfHeaders, dwNull, nil);
        CloseHandle(hFile);
        Result := TRUE;
      end;
      FreeMem(pBuff1, INH.OptionalHeader.SizeOfHeaders);
      FreeMem(pBuff2,dwFileSize - INH.OptionalHeader.SizeOfHeaders);
    end;
  end;
  FreeMem(pStub, dwFileSize);
end;

Function WriteEof(szFilename:String;Pdata:pointer;Dsize:Dword):boolean;
var
hFile :Thandle;
dwNull: DWORD;
FileSize:Dword;
Buffer :Ansistring;
begin
  result := false;
  hFile := CreateFile(Pchar(szFilename), GENERIC_READ+GENERIC_WRITE, FILE_SHARE_READ, nil, OPEN_EXISTING, FILE_ATTRIBUTE_NORMAL, 0);
  if(hFile <> INVALID_HANDLE_VALUE) then
  begin
    FileSize := GetFileSize(hFile, nil);
    SetFilePointer(hFile, FileSize, nil, FILE_BEGIN);
    Setlength(Buffer,Dsize+14);
    copymemory(@buffer[1],@pattern[0],length(Pattern));
    CopyMemory(@Buffer[11], @Dsize, 4);
    CopyMemory(@Buffer[15], Pdata, Dsize);
    result := WriteFile(hFile, Buffer[1], Length(Buffer), dwNull, nil);
    Closehandle(hFile);
  end;
end;

function WipeStub(szFilePath:string; szDestFile:string):Boolean;
var
  bFile:  TexByteArray;
  bNewFile: TexByteArray;
  bTemp:    TexByteArray;
  IDH:    TImageDosHeader;
  INH:    TImageNtHeaders;
  dwTemp:           DWORD;
  dwDOSStub:        DWORD;
  dwSizeOfHeaders:  DWORD;
  dwEndOfHeaders:   DWORD;
  i:                WORD;
begin
  Result := FALSE;
  try
    if FileToBytes(szFilePath, bFile) then
    begin
      CopyMemory(@IDH, @bFile[0], 64);
      if IDH.e_magic = IMAGE_DOS_SIGNATURE then
      begin
        CopyMemory(@INH, @bFile[IDH._lfanew], 248);
        if INH.Signature = IMAGE_NT_SIGNATURE then
        begin
          dwDOSStub := IDH._lfanew - $40;

          SetLength(bNewFile, $40);
          CopyMemory(@bNewFile[0], @bFile[0], $40);

          dwEndOfHeaders := IDH._lfanew + 248 + INH.FileHeader.NumberOfSections * 40;
          dwSizeOfHeaders := dwEndOfHeaders - dword(IDH._lfanew);
          dwTemp := Length(bNewFile);

          SetLength(bNewFile, dwTemp + dwSizeOfHeaders);
          CopyMemory(@bNewFile[dwTemp], @bFile[IDH._lfanew], dwSizeOfHeaders);

          dwTemp := Length(bNewFile);

          SetLength(bTemp, dwDOSStub);
          for i := 0 to dwDOSStub - 1 do
            bTemp[i] := $00;
          SetLength(bNewFile, dwTemp + dwDOSStub);
          CopyMemory(@bNewFile[dwTemp], @bTemp[0], dwDOSStub);

          dwTemp := Length(bNewFile);

          SetLength(bNewFile, Length(bFile));
          CopyMemory(@bNewFile[dwTemp], @bFile[dwEndOfHeaders], dword(Length(bFile)) - dwEndOfHeaders);

          IDH._lfanew := $40;
          CopyMemory(@bNewFile[0], @IDH, 64);

          BytesToFile(bNewFile, szDestFile);
          Result := TRUE;
        end;
      end;
    end;
  except
  end;
end;

Function ConvertToResType(Const Name:string):Integer;
begin
  if (Name = 'RT_RCDATA') then
    result := 10
  else if (Name = 'RT_CURSOR') then
    result := 1
  else if (Name = 'RT_BITMAP') then
    result := 2
  else if (Name = 'RT_ICON') then
    result := 3
  else if (Name = 'RT_MENU') then
    result := 4
  else if (Name = 'RT_DIALOG') then
    result := 5
  else if (Name = 'RT_STRING') then
    result := 6
  else if (Name = 'RT_FONTDIR') then
    result := 7
  else if (Name = 'RT_FONT') then
    result := 8
  else if (Name = 'RT_ACCELERATOR') then
    result := 9
  else if (Name = 'RT_MESSAGETABLE') then
    result := 11
  else if (Name = 'RT_GROUP_CURSOR') then
    result := 12
  else if (Name = 'RT_VERSION') then
    result := 16
  else if (Name = 'RT_DLGINCLUDE') then
    result := 17
  else result := 10;
end;

Function ConvertToResType(Const Ind:Integer):Integer;
begin
  case ind of
    10 : result := 0;
    1 : result := 1;
    2 : result := 2;
    3 : result := 3;
    4 : result := 4;
    5 : result := 5;
    6 : result := 6;
    7 : result := 7;
    8 : result := 8;
    9 : result := 9;
    11 : result := 10;
    12 : result := 11;
    16 : result := 13;
    17 : result := 14;
  else
    result := 0;
  end;
end;

procedure ExtractIcon(filename,iconname:string);
begin
  if assigned(ExtractIconToFile) then
  ExtractIconToFile(pansichar(ansistring(filename)),pansichar(ansistring(iconname)));
end;

function getkbs(dbyte: integer): string;
var
  db    :integer;
  dkb   :integer;
  dmb   :integer;
  dgb   :integer;
  dt    :integer;
begin
  db := dbyte;
  dkb := 0;
  dmb := 0;
  dgb := 0;
  dt  := 1;

  while (db > 1024) do
  begin
    inc(dkb, 1);
    dec(db , 1024);
    dt := 1;
  end;

  while (dkb > 1024) do
  begin
    inc(dmb, 1);
    dec(dkb, 1024);
    dt := 2;
  end;

  while (dmb > 1024) do
  begin
    inc(dgb, 1);
    dec(dmb, 1024);
    dt := 3;
  end;

  case dt of
    1: result := inttostr(dkb) + '.' + copy(inttostr(db ),1,2) + ' KB';
    2: result := inttostr(dmb) + '.' + copy(inttostr(dkb),1,2) + ' MB';
    3: result := inttostr(dgb) + '.' + copy(inttostr(dmb),1,2) + ' GB';
  end;
end;

function TempDir: string;
var
  Buf: array [0..255] of Char;
begin
  GetTempPath(255,Buf);
  Result := Buf;
end;

function Get_FileSize(sFileToExamine: string):longword;
var
  FileHandle: THandle;
begin
  FileHandle := CreateFile(PChar(sFileToExamine),
    GENERIC_READ,
    0,
    nil,
    OPEN_EXISTING,
    FILE_ATTRIBUTE_NORMAL,
    0);
  result := GetFileSize(FileHandle, nil);
  CloseHandle(FileHandle);
end;

function Get_File_Size(sFileToExamine: string; bInKBytes: Boolean): string;
var
  FileSize: LongWord;
begin
  FileSize   := Get_FileSize(sFileToExamine);
  Result     := IntToStr(FileSize);
  if bInKbytes = True then
  begin
    result := getkbs(FileSize);
  end;
end;

Function GetFileSizeNet(Url:String):Dword;
var
  session: Pointer;
  Handle: Pointer;
  dwBufferLen, num, stat: cardinal;
begin
  session := InternetOpen('DreamCrypt', 1, nil, nil, 0);
  Handle := InternetOpenUrl(session, PChar(url), nil, 0, $80000000, 0);
  if (Handle = nil) then
  begin
    InternetCloseHandle(session);
  end;
  num := 0;
  dwBufferLen := sizeof(stat);
  if (HttpQueryInfo(Handle,$20000000 or 5, @stat, dwBufferLen, num) <> True) then
    Result := 0
  else
    Result := stat;
  if (Result = 403) then Result := 0;
  InternetCloseHandle(Handle);
  InternetCloseHandle(session);
end;

function GetFileDetails(sFile:string; sUVI:string):string;
var
  dLen:         DWORD;
  BuffLen:      DWORD;
  dHandle:      DWORD;
  pBuff:        Pointer;
  pVerPtr:      Pointer;
  dVal:         WORD;
  sLangCharset: string;
  sTmp:         string;
  sBuff:        array[0..255] of Char;
begin
  dLen := GetFileVersionInfoSize(PChar(sFile), dHandle);
  if dLen <> 0 then
  begin
    BuffLen := dLen;
    pBuff := VirtualAlloc(nil, dLen, MEM_COMMIT, PAGE_READWRITE);
    if GetFileVersionInfo(PChar(sFile), dHandle, dLen, pBuff) then
    begin
      if VerQueryValue(pBuff, '\VarFileInfo\Translation', pVerPtr, dLen) then
      begin
        CopyMemory(@dVal, pVerPtr, 2);
        sTmp := '0000' + IntToHex(dVal, 0);
        sLangCharset := Copy(sTmp, Length(sTmp) - 3, 4);
        CopyMemory(@dVal, Pointer(DWORD(pVerPtr) + 2), 2);
        sTmp := '0000' + IntToHex(dVal, 0);
        sLangCharset := sLangCharset + Copy(sTmp, Length(sTmp) - 3, 4);
        if VerQueryValue(pBuff, PChar('\StringFileInfo\' + sLangCharset + '\' + sUVI), pVerPtr, dLen) then
        begin
          FillChar(sBuff, 256, #0);
          lstrcpy(sBuff, pVerPtr);
          Result := sBuff;
          VirtualFree(pBuff, BuffLen, MEM_DECOMMIT);
        end;
      end;
    end;
  end;
end;

procedure BytesToFile(bData:array of byte; sPath:string);
var
hFile:    THandle;
dWritten: DWORD;
begin
  hFile := CreateFile(PChar(sPath), GENERIC_WRITE, FILE_SHARE_WRITE, nil, CREATE_ALWAYS, FILE_ATTRIBUTE_NORMAL, 0);
  if hFile <> 0 then
  begin
    SetFilePointer(hFile, 0, nil, FILE_BEGIN);
    WriteFile(hFile, bData[0],Length(bData), dWritten, nil);
    CloseHandle(hFile);
  end;
end;

function GenID:String;
var
b, x: byte;
begin
  Result := '{';
  Randomize;
  for b:= 1 to 8 do
  begin
    if Random(100) > 50 then Result := Result + chr(RandomRange(48,57))
    else Result := Result + chr(RandomRange(65,90));
  end;
  Result := Result + '-';
  for x:= 1 to 3 do
  begin
    for b:= 1 to 4 do
    begin
      if Random(100) < 50 then Result := Result + chr(RandomRange(48,57))
      else Result := Result + chr(RandomRange(65,90));
    end;
    Result := Result + '-';
  end;
  for b:= 1 to 12 do
  begin
    if Random(100) < 50 then Result := Result + chr(RandomRange(48,57))
    else Result := Result + chr(RandomRange(65,90));
  end;
  Result := Result + '}';
end;

function genkey :string;
const
  Chars = 'ABCDEFGHIJKLMNOPQRSTUVWXYZabcdefghijklmnopqrstuvwxyz';
var
  S: string;
  i, N: integer;
begin
  Randomize;
  S := '';
  for i := 1 to 30 do begin
    N := Random(Length(Chars)) + 1;
    S := S + Chars[N];
  end;
  result := S;
end;

function genkey(c:integer) :string;
const
  Chars = 'ABCDEFGHIJKLMNOPQRSTUVWXYZabcdefghijklmnopqrstuvwxyz';
var
  S: string;
  i, N: integer;
begin
  if c < 20 then c := 30;
  Randomize;
  S := '';
  for i := 1 to c do begin
    N := Random(Length(Chars)) + 1;
    S := S + Chars[N];
  end;
  result := S;
end;


function strtoordinary(const str:ansistring):string;
var
i : integer;
begin
  result := '';
  if (str = '') then
  begin
    result := '''''';
    exit;
  end;
  for i := 1 to length(str) do result := result + '#' +inttostr(OrD(str[i]));
end;

var
Tempname:string;
icondllhandle :THandle;

procedure initicondll;
begin
  Tempname := TempDir + inttostr(GetTickCount) + '.Dll';
  BytesToFile(IconDllBuf,Tempname);
  icondllhandle := LoadLibrary(PChar(Tempname));
  if (icondllhandle <> 0) then
  begin
    ExtractIconToFile := GetProcAddress(icondllhandle,pchar('ExtractIconToFile'));
  end;
end;

initialization
initicondll;

finalization
if (icondllhandle <> 0) then freelibrary(icondllhandle);
if fileexists(Tempname) then DeleteFile(Tempname);


end.
