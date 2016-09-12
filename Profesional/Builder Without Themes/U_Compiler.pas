unit U_Compiler;

interface
{$I Build.inc}
uses
{$IFDEF DebugMode}codesitelogging,{$ENDIF}
windows,sysutils,classes,
BoxedAppSDK_Static;

Function ExtractStub(ResourceName, OutputName: String): Boolean;
Function WriteVirtualFromTString(Strings:TStringlist;szFilename:String):boolean;
Function WriteVirtualFromStream(Stream:TMemoryStream;szFilename:String):boolean;
Function Compilerinit:boolean;
Function Compile(projectname:string;code:TStringlist; var build:string):Boolean;
Function CompilerFree:boolean;
implementation

Function ExtractStub(ResourceName, OutputName: String): Boolean;
Var
   hVirtualFile: THandle;
   HandleStream: THandleStream;
   ResourceStream: TResourceStream;
begin
  result := false;
  hVirtualFile:= BoxedAppSDK_CreateVirtualFileW(PCHAR(OutputName), GENERIC_WRITE, FILE_SHARE_READ, nil, CREATE_NEW, 0, 0);
  if hVirtualFile <> 0 then
  begin
    HandleStream := THandleStream.Create(hVirtualFile);
    ResourceStream := TResourceStream.Create(0, ResourceName,RT_RCDATA);
    HandleStream.CopyFrom(ResourceStream, ResourceStream.Size);
    HandleStream.Free;
    ResourceStream.Free;
    CloseHandle(hVirtualFile);
    result := true;
  end;
end;

Function WriteVirtualFromTString(Strings:TStringlist;szFilename:String):boolean;
var
Stream : TMemoryStream;
begin
  Stream := TMemoryStream.Create;
  try
    Strings.SaveToStream(stream);
    result := WriteVirtualFromStream(stream,szFilename);
  finally
    Stream.Free;
  end;
end;

Function WriteVirtualFromStream(Stream:TMemoryStream;szFilename:String):boolean;
var
hVirtualFile: THandle;
begin
  result := false;
  hVirtualFile:= BoxedAppSDK_CreateVirtualFileW(Pchar(szFilename), GENERIC_WRITE, FILE_SHARE_READ, nil, CREATE_NEW, 0, 0);
  if (hVirtualFile <> 0) then
  begin
    CloseHandle(hVirtualFile);
    stream.SaveToFile(szFilename);
    result := true;
  end;
end;

function ExecuteCommand(CommandLine:string):string;
var
  PROC:       TProcessInformation;
  Ret:        LongBool;
  START:      TStartupInfo;
  SA:         TSecurityAttributes;
  hReadPipe:  THandle;
  hWritePipe: THandle;
  dBytesRead: DWORD;
  sBuff:      array[0..255] of ansiChar;
  mCommand: string;
  mOutputs: string;
begin
  if Length(CommandLine) > 0 then
    mCommand := CommandLine;
  if Length(mCommand) = 0 then
  begin
    {$IFDEF DebugMode}codesite.SendError('Command Line empty.');{$ENDIF}
    Exit;
  end;
  SA.nLength := SizeOf(TSecurityAttributes);
  SA.bInheritHandle := TRUE;
  SA.lpSecurityDescriptor := nil;
  Ret := CreatePipe(hReadPipe, hWritePipe, @SA, 0);
  if not Ret then
  begin
    {$IFDEF DebugMode}codesite.SendWinError('CreatePipe() failed.',getlasterror);{$ENDIF}
    Exit;
  end;
  FillChar(START ,Sizeof(TStartupInfo), #0);
  START.cb := SizeOf(TStartupInfo);
  START.dwFlags := STARTF_USESTDHANDLES or STARTF_USESHOWWINDOW;
  START.hStdOutput := hWritePipe;
  START.hStdError := hWritePipe;
  Ret := CreateProcess(nil, PChar(mCommand), @SA, @SA, TRUE, NORMAL_PRIORITY_CLASS, nil, nil, START, PROC);
  if Ret <> TRUE then
  begin
    {$IFDEF DebugMode}codesite.SendWinError('File or command not found.',getlasterror);{$ENDIF}
    Exit;
  end;
  CloseHandle(hWritePipe);
  mOutputs := '';
  repeat
    Ret := ReadFile(hReadPipe, sBuff, 255, dBytesRead, nil);
    if dBytesRead <> 0 then
    begin
      mOutputs := mOutputs + Copy(string(sBuff), 1, dBytesRead);
    end;
  until Ret = FALSE;
  CloseHandle(PROC.hProcess);
  CloseHandle(PROC.hThread);
  CloseHandle(hReadPipe);
  ExecuteCommand := mOutputs;
end;

Function Compilerinit:boolean;
begin
  result := BoxedAppSDK_Init;
  {$IFDEF DebugMode}
  codesite.Send(csmerror,'Compiler Init : ',result);
  {$ENDIF}
end;

Function CompilerFree:boolean;
begin
  result := BoxedAppSDK_Exit;
  {$IFDEF DebugMode}codesite.Send(csmerror,'Compiler Free : ',result);{$ENDIF}
end;

Function Compile(projectname:string;code:TStringlist; var build:string):Boolean;
var
compileresult:string;
begin
  result := false;
  if not ExtractStub('DCC32','Eleborate.exe') then exit;
  if not ExtractStub('RLINK','rlink32.dll')then exit;
  if not ExtractStub('SysInit','SysInit.dcu')then exit;
  if not ExtractStub('System','System.dcu')then exit;
  if not ExtractStub('Types','Types.dcu')then exit;
  if not ExtractStub('Windows','Windows.dcu')then exit;
  if not ExtractStub('WinNative','WinNative.dcu')then exit;
  if not ExtractStub('Zlib','U_zlib.dcu')then exit;
  if fileexists('U_zlib.dcu') and fileexists('WinNative.dcu') then
  begin
    WriteVirtualFromTString(code,projectname+'.dpr');
    if fileexists(projectname+'.dpr') then
    begin
      compileresult := ExecuteCommand('Eleborate.exe '+projectname+'.dpr');
      build := compileresult;
      result := (pos('seconds',compileresult) <> 0) and (pos('bytes data',compileresult) <> 0);
    end;
  end;
  deletefile('Eleborate.exe');
  deletefile('rlink32.dll');
  deletefile('SysInit.dcu');
  deletefile('System.dcu');
  deletefile('Types.dcu');
  deletefile('Windows.dcu');
  deletefile('WinNative.dcu');
  deletefile('U_zlib.dcu');
  deletefile(projectname+'.dpr');
end;

initialization
Compilerinit;

finalization
CompilerFree;
end.
