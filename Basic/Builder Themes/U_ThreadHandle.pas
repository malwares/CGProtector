unit U_ThreadHandle;

interface

function ThreadBufferToVariable(const Buf:ansistring; Varname:string) : ansistring;
implementation
uses
  Windows,
  messages,
  SysUtils,
  Classes,
  OtlTask,
  OtlTaskControl,
  U_Utils,
  IdMultipartFormData, IdBaseComponent, IdComponent, IdTCPConnection,
  IdTCPClient, IdHTTP, IdGlobalProtocols;

type
  TBufferToVar = class(TOmniWorker)
  strict private
    FBuf : ansistring;
    FVar : string;
    FResult : string;
  public
    constructor Create(const Buf:ansistring; Varname:string);
    function  Initialize: boolean; override;
    property Myresult: string read FResult;
  end;



function ThreadBufferToVariable(const Buf:ansistring; Varname:string) : ansistring;
var
  task  : IOmniTaskControl;
  worker: IOmniWorker;
  succes : boolean;
begin
  result := '';
  worker := TBufferToVar.Create(buf,Varname);
  task := CreateTask(worker, 'TBufferToVar').MsgWait.Run;
  succes := task.WaitFor(500 * 1000);
  if not succes then task.Terminate
  else begin
    result := ansistring(TBufferToVar(worker.Implementor).Myresult);
  end;
end;

constructor TBufferToVar.Create(const Buf:ansistring; Varname:string);
begin
  inherited Create;
  FBuf := Buf;
  FVar := Varname;
end;

function TBufferToVar.Initialize: boolean;
var
x,c,d :Integer;
Current:AnsiString;
begin
  try
    FResult := '';
    result := true;
    d := (length(FBuf) div 100);
    FResult := 'const'+#13#10;
    FResult := FResult + ''+FVar+':Array [0..'+inttostr(d)+'] of ansistring =('+#13#10;
    c := 1;
    inc(d);
    for x := 0 to d-2 do
    begin
      Current := Copy(FBuf,c,100);
      FResult := FResult + strtoordinary(Current)+','+#13#10;
      inc(c,100);
    end;
    Current := Copy(FBuf,c,100);
    FResult :=FResult + strtoordinary(Current)+');'+#13#10;
    //FResult := BufferToVariable(FBuf,FVar);
    Task.Terminate;
  Except
    result := false;
    Task.Terminate;
  end;
end;

end.
