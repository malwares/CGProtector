////////////////////////////////////////////////////////////////////////////
// PaxCompiler
// Site: http://www.paxcompiler.com
// Author: Alexander Baranovsky (paxscript@gmail.com)
// ========================================================================
// Copyright (c) Alexander Baranovsky, 2006-2008. All rights reserved.
// Code Version: 2.4
// ========================================================================
// Unit: PaxProgram.pas
// ========================================================================
////////////////////////////////////////////////////////////////////////////

{$I PaxCompiler.def}
unit PaxProgram;
interface
uses
{$IFDEF LINUX}
{$ELSE}
   Windows,
{$ENDIF}
{$IFDEF VARIANTS}
  Variants,
{$ENDIF}
  TypInfo,
  SysUtils,
  Classes,
  PAXCOMP_CONSTANTS,
  PAXCOMP_SYS,
  PAXCOMP_BASESYMBOL_TABLE,
  PAXCOMP_PROG,
  PAXCOMP_MAP,
  PAXCOMP_INVOKE,
  PAXCOMP_STDLIB,
  PaxInvoke;

const
 _rmRUN = 0;
 _rmTRACE_INTO = 1;
 _rmSTEP_OVER = 2;
 _rmRUN_TO_CURSOR = 3;

type
  TPaxProgram = class;

  TPaxPauseNotifyEvent = procedure (Sender: TPaxProgram;
       const ModuleName: String; SourceLineNumber: Integer) of object;

  TPaxHaltNotifyEvent = procedure (Sender: TPaxProgram; ExitCode: Integer;
       const ModuleName: String; SourceLineNumber: Integer) of object;

  TPaxErrNotifyEvent = procedure (Sender: TPaxProgram; E: Exception;
       const ModuleName: String; SourceLineNumber: Integer) of object;

  TPaxLoadProcEvent = procedure (Sender: TPaxProgram;
       const ProcName, DllName: String; var Address: Pointer) of object;

  TPaxObjectNotifyEvent = procedure (Sender: TPaxProgram;
       Instance: TObject) of object;
  TPaxClassNotifyEvent = procedure (Sender: TPaxProgram;
       C: TClass) of object;

  TPaxMapTableNamespaceEvent = procedure (Sender: TPaxProgram;
                                       const FullName: String;
                                       Global: Boolean) of object;

  TPaxMapTableVarAddressEvent = procedure (Sender: TPaxProgram;
       const FullName: String; Global: Boolean; var Address: Pointer) of object;
  TPaxMapTableProcAddressEvent = procedure (Sender: TPaxProgram;
       const FullName: String; OverCount: Byte;
       Global: Boolean; var Address: Pointer) of object;

  TPaxMapTableClassRefEvent = procedure (Sender: TPaxProgram;
       const FullName: String;
       Global: Boolean; var ClassRef: TClass) of object;

  TPaxPrintEvent = procedure (Sender: TPaxProgram;
                           const Text: String) of object;

  TPaxCustomExceptionHelperEvent = procedure (Sender: TPaxProgram;
                                      RaisedException, DestException: Exception)
                                      of object;

  TPaxProgramLoadPCUEvent = function (Sender: TPaxProgram; const UnitName: String
                              ): TStream of object;

  TPaxProgram = class(TComponent)
  private
    prog: TProgram;
    fConsole: Boolean;
    function GetSourceLine: Integer;
    function GetModuleName: String;
    function GetDataPtr: Pointer;
    function GetCodePtr: Pointer;
    function GetDataSize: Integer;
    function GetCodeSize: Integer;
    function GetProgramSize: Integer;
    function GetResultPtr: Pointer;

    function GetOnPause: TPaxPauseNotifyEvent;
    procedure SetOnPause(value: TPaxPauseNotifyEvent);

    function GetOnPauseUpdated: TPaxPauseNotifyEvent;
    procedure SetOnPauseUpdated(value: TPaxPauseNotifyEvent);

    function GetOnHalt: TPaxHaltNotifyEvent;
    procedure SetOnHalt(value: TPaxHaltNotifyEvent);

    function GetOnException: TPaxErrNotifyEvent;
    procedure SetOnException(value: TPaxErrNotifyEvent);

    function GetOnUnhandledException: TPaxErrNotifyEvent;
    procedure SetOnUnhandledException(value: TPaxErrNotifyEvent);

    function GetOnLoadProc: TPaxLoadProcEvent;
    procedure SetOnLoadProc(value: TPaxLoadProcEvent);

    function GetOnCreateObject: TPaxObjectNotifyEvent;
    procedure SetOnCreateObject(value: TPaxObjectNotifyEvent);

    function GetOnAfterObjectCreation: TPaxObjectNotifyEvent;
    procedure SetOnAfterObjectCreation(value: TPaxObjectNotifyEvent);

    function GetOnAfterObjectDestruction: TPaxClassNotifyEvent;
    procedure SetOnAfterObjectDestruction(value: TPaxClassNotifyEvent);

    function GetOnDestroyObject: TPaxObjectNotifyEvent;
    procedure SetOnDestroyObject(value: TPaxObjectNotifyEvent);

    function GetOnMapTableNamespace: TPaxMapTableNamespaceEvent;
    procedure SetOnMapTableNamespace(value: TPaxMapTableNamespaceEvent);

    function GetOnMapTableVarAddress: TPaxMapTableVarAddressEvent;
    procedure SetOnMapTableVarAddress(value: TPaxMapTableVarAddressEvent);

    function GetOnMapTableProcAddress: TPaxMapTableProcAddressEvent;
    procedure SetOnMapTableProcAddress(value: TPaxMapTableProcAddressEvent);

    function GetOnMapTableClassRef: TPaxMapTableClassRefEvent;
    procedure SetOnMapTableClassRef(value: TPaxMapTableClassRefEvent);

    function GetOnPrint: TPaxPrintEvent;
    procedure SetOnPrint(value: TPaxPrintEvent);

    function GetCustomExceptionHelper: TPaxCustomExceptionHelperEvent;
    procedure SetCustomExceptionHelper(value: TPaxCustomExceptionHelperEvent);

    function GetOnLoadPCU: TPaxProgramLoadPCUEvent;
    procedure SetOnLoadPCU(value: TPaxProgramLoadPCUEvent);

    function GetExitCode: Integer;
    function GetIsEvent: Boolean;
    procedure SetSuspendFinalization(value: Boolean);
    function GetSuspendFinalization: Boolean;

  protected
  public
    constructor Create(AOwner: TComponent); override;
    destructor Destroy; override;
    procedure Run;
    procedure RunInitialization;
    procedure RunFinalization;
    procedure Pause;
    function IsPaused: Boolean;
    function IsRunning: Boolean;
    procedure Resume;
    procedure RegisterClass(C: TClass; const FullName: String = '');
    procedure SaveToBuff(var Buff);
    procedure LoadFromBuff(var Buff);
    procedure SaveToStream(S: TStream);
    procedure LoadFromStream(S: TStream);
    procedure SaveToFile(const Path: String);
    procedure LoadFromFile(const Path: String);
    function GetAddress(Handle: Integer): Pointer; overload;
    function GetAddress(const FullName: String): Pointer; overload;
    function GetAddress(const FullName: String; OverCount: Integer): Pointer; overload;
    procedure SetAddress(Handle: Integer; P: Pointer);
    function GetFieldAddress(X: TObject; const FieldName: String): Pointer;
    function GetCallConv(const FullName: String): Integer;
    function GetRetSize(const FullName: String): Integer;

// added in v1.5
//
    function GetProgPtr: TProgram;
//

// added in v1.6

    procedure SetEntryPoint(EntryPoint: TPaxInvoke);
    procedure ResetEntryPoint(EntryPoint: TPaxInvoke);
//
// added in v1.7
    procedure DiscardPause;
    function GetImageSize: Integer;

    procedure DiscardDebugMode;
    procedure AssignEventHandlerRunner(MethodAddress: Pointer;
                                       Instance: TObject);
//
// added in v1.9
    function RegisterNamespace(LevelId: Integer; const Name: String): Integer;
    function RegisterClassType(LevelId: Integer; C: TClass): Integer;
    procedure RegisterMember(LevelId: Integer; const Name: String;
                         Address: Pointer);
    procedure MapGlobal;
    procedure MapLocal;

    function CreateScriptObject(const ScriptClassName: String): TObject;
    procedure DestroyScriptObject(X: TObject);

    procedure LoadDFMFile(Instance: TObject; const FileName: String);
    procedure LoadDFMStream(Instance: TObject; S: TStream);

    function GetTypeInfo(const FullTypeName: String): PTypeInfo;

    function CallRoutine(const FullName: String;
                         const ParamList: array of OleVariant): OleVariant;
    function CallMethod(const FullName: String;
                        Instance: TObject;
                        const ParamList: array of OleVariant): OleVariant;
    function CallClassMethod(const FullName: String;
                             Instance: TClass;
                             const ParamList: array of OleVariant): OleVariant;

    function SetHostAddress(const FullName: String; Address: Pointer): Boolean;

    property DataPtr: Pointer read GetDataPtr;
    property CodePtr: Pointer read GetCodePtr;
    property DataSize: Integer read GetDataSize;
    property CodeSize: Integer read GetCodeSize;
    property ProgramSize: Integer read GetProgramSize;
    property ResultPtr: Pointer read GetResultPtr;
    property ExitCode: Integer read GetExitCode;
    property IsEvent: Boolean read GetIsEvent;
    property SourceLine: Integer read GetSourceLine;
    property ModuleName: String read GetModuleName;
    property SuspendFinalization: Boolean
      read GetSuspendFinalization write SetSuspendFinalization;

  published

// added in v1.8
    property Console: boolean read fConsole write fConsole;

    property OnPause: TPaxPauseNotifyEvent read GetOnPause write SetOnPause;
    property OnPauseUpdated: TPaxPauseNotifyEvent read GetOnPauseUpdated write SetOnPauseUpdated;
    property OnHalt: TPaxHaltNotifyEvent read GetOnHalt write SetOnHalt;
    property OnException: TPaxErrNotifyEvent read GetOnException write SetOnException;
    property OnUnhandledException: TPaxErrNotifyEvent read GetOnUnhandledException
                                                      write SetOnUnhandledException;
    property OnLoadProc: TPaxLoadProcEvent read GetOnLoadProc
                                           write SetOnLoadProc;

    property OnCreateObject: TPaxObjectNotifyEvent read GetOnCreateObject
                                                   write SetOnCreateObject;

    property OnAfterObjectCreation: TPaxObjectNotifyEvent read GetOnAfterObjectCreation
                                                   write SetOnAfterObjectCreation;

    property OnDestroyObject: TPaxObjectNotifyEvent read GetOnDestroyObject
                                                   write SetOnDestroyObject;

    property OnAfterObjectDestruction: TPaxClassNotifyEvent read GetOnAfterObjectDestruction
                                                   write SetOnAfterObjectDestruction;

    property OnMapTableNamespace: TPaxMapTableNamespaceEvent read GetOnMapTableNamespace
                                           write SetOnMapTableNamespace;
    property OnMapTableVarAddress: TPaxMapTableVarAddressEvent read GetOnMapTableVarAddress
                                           write SetOnMapTableVarAddress;
    property OnMapTableProcAddress: TPaxMapTableProcAddressEvent read GetOnMapTableProcAddress
                                           write SetOnMapTableProcAddress;
    property OnMapTableClassRef: TPaxMapTableClassRefEvent read GetOnMapTableClassRef
                                           write SetOnMapTableClassRef;

    property OnPrintEvent: TPaxPrintEvent read GetOnPrint
                                           write SetOnPrint;

    property OnCustomExceptionHelperEvent: TPaxCustomExceptionHelperEvent
                             read GetCustomExceptionHelper
                             write SetCustomExceptionHelper;

    property OnLoadPCU: TPaxProgramLoadPCUEvent
                         read GetOnLoadPCU write SetOnLoadPCU;

  end;

procedure RunScript(Address: Pointer); stdcall;

implementation

type
  THandler = class
    procedure OnPrintHandler(Sender: TPaxProgram; const Text: string);
  end;

procedure THandler.OnPrintHandler(Sender: TPaxProgram; const Text: string);
begin
  write(Text);
end;

procedure RunScript(Address: Pointer); stdcall;
var
  PaxProgram1: TPaxProgram;
  H: THandler;
begin
  PaxProgram1 := TPaxProgram.Create(nil);
  H := THandler.Create;
  try
    PaxProgram1.OnPrintEvent := H.OnPrintHandler;
    PaxProgram1.LoadFromBuff(Address^);
    PaxProgram1.Run;
  finally
    PaxProgram1.Free;
    H.Free;
  end;
  ExitProcess(0);
end;

/////////////// TPaxProgram ///////////////////////////////////////////////////

constructor TPaxProgram.Create(AOwner: TComponent);
begin
  inherited;
  prog := TProgram.Create;
  prog.Owner := Self;
  fConsole := false;
end;

destructor TPaxProgram.Destroy;
begin
  prog.Free;
  inherited;
end;

procedure TPaxProgram.Run;
begin
  if prog.IsPaused or (prog.EPoint <> nil) then
  begin
    prog.Run;
    Exit;
  end
  else
    prog.RunInitialization;
  if prog.IsPaused then
    Exit;
  prog.RunExceptInitialization;
  if not prog.IsPaused then
    prog.ProgList.RunFinalization;
end;

procedure TPaxProgram.RunInitialization;
begin
  prog.RunInitialization;
end;

procedure TPaxProgram.RunFinalization;
begin
  prog.RunFinalization;
end;

procedure TPaxProgram.Pause;
begin
  prog.Pause;
end;

function TPaxProgram.IsPaused: Boolean;
begin
  result := prog.IsPaused;
end;

function TPaxProgram.IsRunning: Boolean;
begin
  result := prog.IsRunning;
end;

procedure TPaxProgram.Resume;
begin
  prog.Run;
end;

procedure TPaxProgram.DiscardPause;
begin
  prog.PauseRec.ProgOffset := 0;
end;

procedure TPaxProgram.SaveToBuff(var Buff);
begin
  prog.SaveToBuff(Buff);
end;

procedure TPaxProgram.LoadFromBuff(var Buff);
begin
  prog.LoadFromBuff(Buff);
end;

procedure TPaxProgram.SaveToStream(S: TStream);
begin
  prog.SaveToStream(S);
end;

procedure TPaxProgram.LoadFromStream(S: TStream);
begin
  prog.LoadFromStream(S);
end;

procedure TPaxProgram.SaveToFile(const Path: String);
begin
  prog.SaveToFile(path);
end;

procedure TPaxProgram.LoadFromFile(const Path: String);
begin
  prog.LoadFromFile(path);
end;

function TPaxProgram.GetAddress(Handle: Integer): Pointer;
begin
  result := prog.GetAddress(Handle);
end;

function TPaxProgram.GetAddress(const FullName: String): Pointer;
var
  MR: TMapRec;
begin
  result := prog.GetAddress(FullName, MR);
end;

function TPaxProgram.GetAddress(const FullName: String; OverCount: Integer): Pointer;
var
  MR: TMapRec;
begin
  result := prog.GetAddressEx(FullName, OverCount, MR);
end;

function TPaxProgram.GetCallConv(const FullName: String): Integer;
begin
  result := prog.GetCallConv(FullName);
end;

function TPaxProgram.GetRetSize(const FullName: String): Integer;
begin
  result := prog.GetRetSize(FullName);
end;

procedure TPaxProgram.SetAddress(Handle: Integer; P: Pointer);
var
  Offset: Integer;
begin
  Offset := prog.GetOffset(Handle);
  if Offset = -1 then
    Exit;

  prog.SetAddress(Offset, P);
end;

function TPaxProgram.GetResultPtr: Pointer;
begin
  result := prog.ResultPtr;
end;

function TPaxProgram.GetDataPtr: Pointer;
begin
  result := prog.DataPtr;
end;

function TPaxProgram.GetCodePtr: Pointer;
begin
  result := prog.CodePtr;
end;

function TPaxProgram.GetDataSize: Integer;
begin
  result := prog.DataSize;
end;

function TPaxProgram.GetCodeSize: Integer;
begin
  result := prog.CodeSize;
end;

function TPaxProgram.GetProgramSize: Integer;
begin
  result := prog.ProgramSize;
end;

procedure TPaxProgram.RegisterClass(C: TClass; const FullName: String = '');
begin
  if FullName = '' then
    prog.RegisterClass(C, C.ClassName)
  else
    prog.RegisterClass(C, FullName);
end;

function TPaxProgram.GetProgPtr: TProgram;
begin
  result := prog;
end;

function TPaxProgram.GetOnPause: TPaxPauseNotifyEvent;
begin
  result := TPaxPauseNotifyEvent(prog.OnPause);
end;

procedure TPaxProgram.SetOnPause(value: TPaxPauseNotifyEvent);
begin
  prog.OnPause := TPauseNotifyEvent(value);
end;

function TPaxProgram.GetOnPauseUpdated: TPaxPauseNotifyEvent;
begin
  result := TPaxPauseNotifyEvent(prog.OnPauseUpdated);
end;

procedure TPaxProgram.SetOnPauseUpdated(value: TPaxPauseNotifyEvent);
begin
  prog.OnPauseUpdated := TPauseNotifyEvent(value);
end;

function TPaxProgram.GetOnCreateObject: TPaxObjectNotifyEvent;
begin
  result := TPaxObjectNotifyEvent(prog.OnCreateObject);
end;

procedure TPaxProgram.SetOnCreateObject(value: TPaxObjectNotifyEvent);
begin
  prog.OnCreateObject := TObjectNotifyEvent(value);
end;

function TPaxProgram.GetOnAfterObjectCreation: TPaxObjectNotifyEvent;
begin
  result := TPaxObjectNotifyEvent(prog.OnAfterObjectCreation);
end;

procedure TPaxProgram.SetOnAfterObjectCreation(value: TPaxObjectNotifyEvent);
begin
  prog.OnAfterObjectCreation := TObjectNotifyEvent(value);
end;

function TPaxProgram.GetOnAfterObjectDestruction: TPaxClassNotifyEvent;
begin
  result := TPaxClassNotifyEvent(prog.OnAfterObjectDestruction);
end;

procedure TPaxProgram.SetOnAfterObjectDestruction(value: TPaxClassNotifyEvent);
begin
  prog.OnAfterObjectDestruction := TClassNotifyEvent(value);
end;

function TPaxProgram.GetOnDestroyObject: TPaxObjectNotifyEvent;
begin
  result := TPaxObjectNotifyEvent(prog.OnDestroyObject);
end;

procedure TPaxProgram.SetOnDestroyObject(value: TPaxObjectNotifyEvent);
begin
  prog.OnDestroyObject := TObjectNotifyEvent(value);
end;

function TPaxProgram.GetOnHalt: TPaxHaltNotifyEvent;
begin
  result := TPaxHaltNotifyEvent(prog.OnHalt);
end;

procedure TPaxProgram.SetOnHalt(value: TPaxHaltNotifyEvent);
begin
  prog.OnHalt := THaltNotifyEvent(value);
end;

function TPaxProgram.GetOnLoadProc: TPaxLoadProcEvent;
begin
  result := TPaxLoadProcEvent(prog.OnLoadProc);
end;

procedure TPaxProgram.SetOnLoadProc(value: TPaxLoadProcEvent);
begin
  prog.OnLoadProc := TLoadProcEvent(value);
end;

function TPaxProgram.GetOnPrint: TPaxPrintEvent;
begin
  result := TPaxPrintEvent(prog.OnPrint);
end;

procedure TPaxProgram.SetOnPrint(value: TPaxPrintEvent);
begin
  prog.OnPrint := TPrintEvent(value);
end;

function TPaxProgram.GetCustomExceptionHelper: TPaxCustomExceptionHelperEvent;
begin
  result := TPaxCustomExceptionHelperEvent(prog.OnCustomExceptionHelper);
end;

procedure TPaxProgram.SetCustomExceptionHelper(value: TPaxCustomExceptionHelperEvent);
begin
  prog.OnCustomExceptionHelper := TCustomExceptionHelperEvent(value);
end;

function TPaxProgram.GetOnMapTableNamespace: TPaxMapTableNamespaceEvent;
begin
  result := TPaxMapTableNamespaceEvent(prog.OnMapTableNamespace);
end;

procedure TPaxProgram.SetOnMapTableNamespace(value: TPaxMapTableNamespaceEvent);
begin
  prog.OnMapTableNamespace := TMapTableNamespaceEvent(value);
end;

function TPaxProgram.GetOnMapTableVarAddress: TPaxMapTableVarAddressEvent;
begin
  result := TPaxMapTableVarAddressEvent(prog.OnMapTableVarAddress);
end;

procedure TPaxProgram.SetOnMapTableVarAddress(value: TPaxMapTableVarAddressEvent);
begin
  prog.OnMapTableVarAddress := TMapTableVarAddressEvent(value);
end;

function TPaxProgram.GetOnMapTableProcAddress: TPaxMapTableProcAddressEvent;
begin
  result := TPaxMapTableProcAddressEvent(prog.OnMapTableProcAddress);
end;

procedure TPaxProgram.SetOnMapTableProcAddress(value: TPaxMapTableProcAddressEvent);
begin
  prog.OnMapTableProcAddress := TMapTableProcAddressEvent(value);
end;

function TPaxProgram.GetOnMapTableClassRef: TPaxMapTableClassRefEvent;
begin
  result := TPaxMapTableClassRefEvent(prog.OnMapTableClassRef);
end;

procedure TPaxProgram.SetOnMapTableClassRef(value: TPaxMapTableClassRefEvent);
begin
  prog.OnMapTableClassRef := TMapTableClassRefEvent(value);
end;

function TPaxProgram.GetOnException: TPaxErrNotifyEvent;
begin
  result := TPaxErrNotifyEvent(prog.OnException);
end;

procedure TPaxProgram.SetOnException(value: TPaxErrNotifyEvent);
begin
  prog.OnException := TErrNotifyEvent(value);
end;

function TPaxProgram.GetOnUnhandledException: TPaxErrNotifyEvent;
begin
  result := TPaxErrNotifyEvent(prog.OnUnhandledException);
end;

procedure TPaxProgram.SetOnUnhandledException(value: TPaxErrNotifyEvent);
begin
  prog.OnUnhandledException := TErrNotifyEvent(value);
end;

// added in v1.6

procedure TPaxProgram.SetEntryPoint(EntryPoint: TPaxInvoke);
begin
  if EntryPoint = nil then
    prog.EPoint := nil
  else
  begin
    prog.EPoint := TInvoke(EntryPoint.GetImplementation);
    TInvoke(EntryPoint.GetImplementation).OldESP0 := prog.RootESP0;
  end;
end;

procedure TPaxProgram.ResetEntryPoint(EntryPoint: TPaxInvoke);
begin
  if EntryPoint = nil then
    Exit
  else
    prog.RootESP0 := TInvoke(EntryPoint.GetImplementation).OldESP0;
end;

function TPaxProgram.GetImageSize: Integer;
begin
  result := prog.GetImageSize;
end;

function TPaxProgram.CreateScriptObject(const ScriptClassName: String): TObject;
begin
  result := prog.CreateScriptObject(ScriptClassName);
end;

procedure TPaxProgram.DestroyScriptObject(X: TObject);
begin
  prog.DestroyScriptObject(X);
end;

function TPaxProgram.GetExitCode: Integer;
begin
  result := prog.ExitCode;
end;

procedure TPaxProgram.RegisterMember(LevelId: Integer; const Name: String;
                         Address: Pointer);
begin
  prog.LocalSymbolTable.RegisterMember(LevelId, Name, Address);
end;

function TPaxProgram.RegisterNamespace(LevelId: Integer; const Name: String): Integer;
begin
  result := prog.LocalSymbolTable.RegisterNamespace(LevelId, Name);
end;

function TPaxProgram.RegisterClassType(LevelId: Integer; C: TClass): Integer;
begin
  result := prog.LocalSymbolTable.RegisterClassType(LevelId, C);
end;

procedure TPaxProgram.MapGlobal;
begin
  prog.ForceMapping(GlobalSymbolTable, true);
end;

procedure TPaxProgram.MapLocal;
begin
  prog.ForceMapping(prog.LocalSymbolTable, true);
end;

function TPaxProgram.GetFieldAddress(X: TObject; const FieldName: String): Pointer;
begin
  result := prog.GetFieldAddress(X, FieldName);
end;

procedure TPaxProgram.DiscardDebugMode;
begin
  prog.DiscardDebugMode;
end;

procedure TPaxProgram.AssignEventHandlerRunner(MethodAddress: Pointer;
                                               Instance: TObject);
begin
  prog.OwnerEventHandlerMethod.Code := MethodAddress;
  prog.OwnerEventHandlerMethod.Data := Instance;
end;

function TPaxProgram.GetIsEvent: Boolean;
begin
  result := prog.RootIsEvent;
end;

procedure TPaxProgram.LoadDFMFile(Instance: TObject; const FileName: String);
begin
  prog.LoadDFMFile(Instance, FileName);
end;

procedure TPaxProgram.LoadDFMStream(Instance: TObject; S: TStream);
begin
  prog.LoadDFMStream(Instance, S);
end;

function TPaxProgram.GetTypeInfo(const FullTypeName: String): PTypeInfo;
begin
  result := prog.GetTypeInfo(FullTypeName);
end;

function TPaxProgram.CallRoutine(const FullName: String;
                     const ParamList: array of OleVariant): OleVariant;
begin
  result := prog.CallFunc(FullName, nil, ParamList);
end;

function TPaxProgram.CallMethod(const FullName: String;
                                Instance: TObject;
                                const ParamList: array of OleVariant): OleVariant;
begin
  result := prog.CallFunc(FullName, Instance, ParamList);
end;

function TPaxProgram.CallClassMethod(const FullName: String;
                                     Instance: TClass;
                                     const ParamList: array of OleVariant): OleVariant;
begin
  result := prog.CallFunc(FullName, Instance, ParamList);
end;

function TPaxProgram.GetSourceLine: Integer;
begin
  result := prog.GetSourceLine;
end;

function TPaxProgram.GetModuleName: String;
begin
  result := prog.GetModuleName;
end;

function TPaxProgram.SetHostAddress(const FullName: String; Address: Pointer): Boolean;
begin
  result := prog.SetHostAddress(FullName, Address);
end;

function TPaxProgram.GetOnLoadPCU: TPaxProgramLoadPCUEvent;
begin
  result := TPaxProgramLoadPCUEvent(prog.OnLoadPCU);
end;

procedure TPaxProgram.SetOnLoadPCU(value: TPaxProgramLoadPCUEvent);
begin
  prog.OnLoadPCU := TLoadPCUEvent(value);
end;

procedure TPaxProgram.SetSuspendFinalization(value: Boolean);
begin
  prog.SuspendFinalization := value;
end;

function TPaxProgram.GetSuspendFinalization: Boolean;
begin
  result := prog.SuspendFinalization;
end;

end.
