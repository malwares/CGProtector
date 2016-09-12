unit StreamHelper;

interface
//{$I Build.inc}
uses
{$IFDEF DebugMode}codesitelogging,{$ENDIF}
windows,sysutils,classes;

procedure WriteByte(Stream:TMemoryStream;Value:byte);
procedure WriteInteger(Stream:TMemoryStream;Value:integer);
procedure WriteBoolean(Stream:TMemoryStream;Value:Boolean);
procedure WriteAnsiString(Stream:TMemoryStream;Value:Ansistring);
procedure WriteUniString(Stream:TMemoryStream;Value:string);
implementation

procedure WriteByte(Stream:TMemoryStream;Value:byte);
begin
{$IFDEF DebugMode}
  codesite.Sendmemoryashex('Before WriteByte',Stream.Memory,Stream.SIZE);
{$ENDIF}
  Stream.Write(Value,sizeof(byte));
{$IFDEF DebugMode}
  codesite.Sendmemoryashex('After WriteByte',Stream.Memory,Stream.SIZE);
{$ENDIF}
end;

procedure WriteInteger(Stream:TMemoryStream;Value:integer);
begin
{$IFDEF DebugMode}
  codesite.Sendmemoryashex('Before WriteInteger',Stream.Memory,Stream.SIZE);
{$ENDIF}
  Stream.Write(Value,sizeof(integer));
{$IFDEF DebugMode}
  codesite.Sendmemoryashex('After WriteInteger',Stream.Memory,Stream.SIZE);
{$ENDIF}
end;

procedure WriteBoolean(Stream:TMemoryStream;Value:Boolean);
var
temp : Byte;
begin
  temp := Byte(value);
  WriteByte(Stream,temp);
end;

procedure WriteAnsiString(Stream:TMemoryStream;Value:Ansistring);
var
size : integer;
begin
{$IFDEF DebugMode}
  codesite.Sendmemoryashex('Before WriteAnsiString',Stream.Memory,Stream.SIZE);
{$ENDIF}
  size := length(value);
  Stream.Write(size,sizeof(integer));
  if (size <> 0) then
  begin
  stream.Write(Value[1],size);
  end;
{$IFDEF DebugMode}
  codesite.Sendmemoryashex('After WriteAnsiString',Stream.Memory,Stream.SIZE);
{$ENDIF}
end;

procedure WriteUniString(Stream:TMemoryStream;Value:string);
begin
  WriteAnsiString(Stream,ansistring(Value));
end;
end.
