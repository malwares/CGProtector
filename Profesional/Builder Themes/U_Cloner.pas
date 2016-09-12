unit U_Cloner;

interface
uses
windows,sysutils,classes,U_IconChangerUnit,U_Utils,U_PEUtils;

Function ChangeIcon(Iconfile,Filename:string):boolean;
procedure cloneVersion(fromfile,filepath:string);
Function CloneSign(szSource,szDestination:String):boolean;
implementation

procedure cloneVersion(fromfile,filepath:string);
var
  dwHandle, cbTranslate: cardinal;
  sizeVers: DWord;
  lpData, langData: Pointer;
  lpTranslate: WORD;
  hRes : THandle;
begin
  sizeVers := GetFileVersionInfoSize(PChar(fromfile), dwHandle);
  If sizeVers <> 0 then
  begin
    GetMem(lpData, sizeVers);
    ZeroMemory(lpData, sizeVers);
    GetFileVersionInfo (PChar(fromfile), 0, sizeVers, lpData);
    If VerQueryValue (lpData, '\VarFileInfo\Translation', langData, cbTranslate) then
    begin
      hRes := BeginUpdateResourceW(pchar(filepath), FALSE);
      if hRes <> 0 then
      begin
        CopyMemory(@lpTranslate, langData, 2);
        UpdateResourceW(hRes, RT_VERSION, MAKEINTRESOURCE(VS_VERSION_INFO), lpTranslate, lpData, sizeVers);
        EndUpdateResourceW(hRes, FALSE);
      end;
    end;
    FreeMem(lpData);
  end;
end;

Function ChangeIcon(Iconfile,Filename:string):boolean;
var TempIcon : string;
begin
  if pos('.ico',Iconfile) <> 0 then
  begin
    result := ChangeExeIcon(Filename,'ICON',Iconfile);
  end else
  begin
    TempIcon := TempDir + inttostr(GetTickCount) + '.ico';
    ExtractIcon(Iconfile,TempIcon);
    result := ChangeExeIcon(Filename,'ICON',TempIcon);
    DeleteFile(TempIcon);
  end;
end;

Function AddSign(szFilename:string;Sign:Pointer;DwSize:Dword):boolean;
var
Header :THeader;
Source :TMemoryStream;
Offset :Dword;
begin
  Source := TMemoryStream.Create;
  try
    Source.LoadFromFile(szFilename);
    if GetHeader(Source.Memory,Header) then
    begin
      if (Header.DataDirectoryEntries[4].VirtualAddress<> 0) or
        (Header.DataDirectoryEntries[4].Size<> 0) then
      begin
        Source.Free;
        result := true;
        exit;
      end;
    end;

    Source.Free;
    Source := nil;
    Offset := AddSection(szFilename,'.Sign',DwSize,0,Sign,DwSize);
    Source := TMemoryStream.Create;
    Source.LoadFromFile(szFileName);

    if (offset = 0) then
    begin
      Source.Free;
      result := false;
      exit;
    end;

    if GetHeader(Source.Memory,Header) then
    begin
      Header.DataDirectoryEntries[4].VirtualAddress := offset;
      Header.DataDirectoryEntries[4].Size := DwSize;
      Source.SaveToFile(szFilename);
      result := true;
    end else
      result := false;
    Source.Free;
  Except
    Source.Free;
    result := false;
  end;
end;

Function CloneSign(szSource,szDestination:string):boolean;
var
Header :THeader;
Source :TMemoryStream;
begin
  result := false;
  Source := TMemoryStream.Create;
  try
    Source.LoadFromFile(szSource);
    if GetHeader(Source.Memory,Header) then
    begin
      if (Header.DataDirectoryEntries[4].VirtualAddress<> 0) or
        (Header.DataDirectoryEntries[4].Size<> 0) then
      begin
        AddSign(szDestination,
        Pointer(Dword(Source.Memory)+Header.DataDirectoryEntries[4].VirtualAddress),
        Header.DataDirectoryEntries[4].Size);
      end;
    end;
  finally
    Source.Free;
  end;
end;


end.
