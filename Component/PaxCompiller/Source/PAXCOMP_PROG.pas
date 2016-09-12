////////////////////////////////////////////////////////////////////////////
// PaxCompiler
// Site: http://www.paxcompiler.com
// Author: Alexander Baranovsky (paxscript@gmail.com)
// ========================================================================
// Copyright (c) Alexander Baranovsky, 2006-2008. All rights reserved.
// Code Version: 2.4
// ========================================================================
// Unit: PAXCOMP_PROG.pas
// ========================================================================
////////////////////////////////////////////////////////////////////////////

{$I PaxCompiler.def}
{$O-}

unit PAXCOMP_PROG;
interface
uses
{$IFDEF LINUX}
{$IFDEF FPC}
  DynLibs,
{$ELSE}
  QForms,
{$ENDIF}
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
  PAXCOMP_STDLIB,
  PAXCOMP_SYMBOL_REC,
  PAXCOMP_BASESYMBOL_TABLE,
  PAXCOMP_LOCALSYMBOL_TABLE,
  PAXCOMP_CLASSLST,
  PAXCOMP_DISASM,
  PAXCOMP_TRYLST,
  PAXCOMP_PAUSE,
  PAXCOMP_RTI,
  PAXCOMP_EVENT,
  PAXCOMP_MAP,
  PAXCOMP_OFFSET,
  PAXCOMP_TYPEINFO,
  PAXCOMP_PROGLIST,
  PAXCOMP_GC,
  PAXCOMP_INVOKE;
type
  TProgram = class;

  TPauseNotifyEvent = procedure (Sender: TObject;
       const ModuleName: String; SourceLineNumber: Integer) of object;

  THaltNotifyEvent = procedure (Sender: TObject; ExitCode: Integer;
       const ModuleName: String; SourceLineNumber: Integer) of object;

  TErrNotifyEvent = procedure (Sender: TObject; E: Exception;
       const ModuleName: String; SourceLineNumber: Integer) of object;

  TLoadProcEvent = procedure (Sender: TObject;
       const ProcName, DllName: String; var Address: Pointer) of object;

  TObjectNotifyEvent = procedure (Sender: TObject;
       Instance: TObject) of object;
  TClassNotifyEvent = procedure (Sender: TObject;
       C: TClass) of object;

  TMapTableNamespaceEvent = procedure (Sender: TObject;
                                       const FullName: String;
                                       Global: Boolean) of object;
  TMapTableVarAddressEvent = procedure (Sender: TObject;
       const FullName: String; Global: Boolean; var Address: Pointer) of object;
  TMapTableProcAddressEvent = procedure (Sender: TObject;
       const FullName: String; OverCount: Byte;
       Global: Boolean; var Address: Pointer) of object;
  TMapTableClassRefEvent = procedure (Sender: TObject;
       const FullName: String; Global: Boolean; var ClassRef: TClass) of object;

  TPrintEvent = procedure (Sender: TObject;
                           const Text: String) of object;

  TCustomExceptionHelperEvent = procedure (Sender: TObject;
                                      RaisedException, DestException: Exception)
                                      of object;
  TTryStackRec = class
  public
    TryBlockNumber: Integer;
    Prog: TProgram;
  end;

  TTryStack = class(TTypedList)
  private
    function GetRecord(I: Integer): TTryStackRec;
    function GetTop: TTryStackRec;
  public
    procedure Push(ATryBlockNumber: Integer; AProg: TProgram);
    procedure Pop;
    function IndexOf(ATryBlockNumber: Integer): Integer;
    procedure SaveToStream(S: TStream);
    procedure LoadFromStream(S: TStream);
    property Top: TTryStackRec read GetTop;
    property Records[I: Integer]: TTryStackRec read GetRecord; default;
  end;

  TProgram = class
  private
    Prog: Pointer;
    Data: Pointer;
    fCodeSize: Integer;
    fDataSize: Integer;
    fClassList: TClassList;
    fTryList: TTryList;
    fTryStack: TTryStack;
    fPauseRec: TPauseRec;

    fESP0: Integer;

    fCallStackID: TIntegerStack;
    fCallStackEBP: TIntegerStack;
    fCallStackNCall: TIntegerStack;
    fInitCallStackCount: Integer;
    fProcessingExceptBlock: Boolean;
    fExceptionIsAvailableForHostApplication: Boolean;
    fIsRunning: Boolean;
    fIsEvent: Boolean;

    fGC: TGC;

    function GetResultPtr: Pointer;
    function GetCodePtr: PBytes;
    function GetDataPtr: PBytes;
    function GetProgramSize: Integer;
    function GetInteger(Shift: Integer): Integer;
    function GetPChar(Shift: Integer): PChar;
    function GetShortString(Shift: Integer): ShortString;

    procedure Protect;
    procedure UnProtect;

    function GetRootProg: TProgram;
    function GetIsRootProg: Boolean;
    function GetTryStack: TTryStack;

    function GetCallStackID: TIntegerStack;
    function GetCallStackEBP: TIntegerStack;
    function GetCallStackNCall: TIntegerStack;
    function GetInitCallStackCount: Integer;
    procedure SetInitCallStackCount(value: Integer);
    function GetESP0: Integer;
    procedure SetESP0(value: Integer);
    function GetCurrException: Exception;
    procedure SetCurrException(value: Exception);
    function GetProcessingExceptBlock: Boolean;
    procedure SetProcessingExceptBlock(value: Boolean);
    function GetExceptionIsAvailableForHostApplication: Boolean;
    procedure SetExceptionIsAvailableForHostApplication(value: Boolean);

    function GetRootGC: TGC;

    function GetIsEvent: Boolean;
    procedure SetIsEvent(value: Boolean);
  public
    Owner: TObject;

    fCurrException: Exception;

    RunTimeModuleList: TRuntimeModuleList;
    OnException: TErrNotifyEvent;
    OnUnhandledException: TErrNotifyEvent;
    OnPause: TPauseNotifyEvent;
    OnPauseUpdated: TPauseNotifyEvent;
    OnHalt: THaltNotifyEvent;
    OnLoadProc: TLoadProcEvent;
    OnCreateObject: TObjectNotifyEvent;
    OnAfterObjectCreation: TObjectNotifyEvent;
    OnDestroyObject: TObjectNotifyEvent;
    OnAfterObjectDestruction: TClassNotifyEvent;

    OnMapTableNamespace: TMapTableNamespaceEvent;
    OnMapTableVarAddress: TMapTableVarAddressEvent;
    OnMapTableProcAddress: TMapTableProcAddressEvent;
    OnMapTableClassRef: TMapTableClassRefEvent;
    OnLoadPCU: TLoadPCUEvent;

    OnPrint: TPrintEvent;
    OnCustomExceptionHelper: TCustomExceptionHelperEvent;

    EventHandlerList: TEventHandlerList;
    VMT: TVMT;
    RunMode: Integer;

    JS_Object: TObject;
    JS_Boolean: TObject;
    JS_String: TObject;
    JS_Number: TObject;
    JS_Date: TObject;
    JS_Function: TObject;
    JS_Array: TObject;
    JS_Math: TObject;
    ContextList: TList;

    ScriptDefinedException: TObject;

    EPoint: TInvoke;

    DllList: TStringList;
    ProgList: TProgList;
    PCUOwner: TProgram;
    ZList: TIntegerList;

    ExitCode: Integer;
    IsHalted: Boolean;

    HostMapTable: TMapTable;
    ScriptMapTable: TMapTable;
    UseMapping: Boolean;
    LocalSymbolTable: TLocalSymbolTable;
    OffsetList: TOffsetList;

    OwnerEventHandlerMethod: TMethod;
    SavedClass: TClass;

{$IFNDEF LINUX}
    // Windows
    mbi: TMemoryBasicInformation;
    OldProtect: Cardinal;
    IsProtected: Boolean;
{$ELSE}
{$ENDIF}
    ProgClassFactory: TPaxClassFactory;

    IsPauseUpdated: Boolean;
    ProgTypeInfoList: TPaxTypeInfoList;
    ExitLevelId: Integer;
    FinalizationOffset: Integer;

    PassedClassRef: TClass;
    InitializationIsProcessed: Boolean;

    SuspendFinalization: Boolean;
    Tag: Integer;

    constructor Create;
    destructor Destroy; override;
    procedure Reset;
    function RegisterClass(C: TClass;
                           const FullName: String;
                           Offset: Integer = -1): TClassRec;
    function RegisterClassEx(C: TClass;
                             const FullName: String;
                             Offset: Integer; ClassIndex: Integer): TClassRec;
    procedure Allocate(InitCodeSize, InitDataSize: Integer);
    procedure Reallocate(NewCodeSize: Integer);
    procedure AllocateSimple(InitCodeSize, InitDataSize: Integer);
    procedure Deallocate;
    procedure RegisterDefinitions(SymbolTable: TBaseSymbolTable);
    procedure ForceMapping(SymbolTable: TBaseSymbolTable;
              Reassign: Boolean);
    procedure ForceMappingEvents;
    procedure SetAddress(Offset: Integer; P: Pointer);
    function SetHostAddress(const FullName: String; Address: Pointer): Boolean;
    function GetAddress(Handle: Integer): Pointer; overload;
    function GetAddress(const FullName: String; var MR: TMapRec): Pointer; overload;
    function GetAddressEx(const FullName: String; OverCount: Integer; var MR: TMapRec): Pointer;
    function GetCallConv(const FullName: String): Integer;
    function GetRetSize(const FullName: String): Integer;

    procedure Run;
    procedure RunInitialization;
    procedure RunExceptInitialization;
    procedure RunFinalization;

    procedure SaveToBuff(var Buff);
    procedure LoadFromBuff(var Buff);
    procedure SaveToStream(S: TStream);
    procedure LoadFromStream(S: TStream);
    procedure SaveToFile(const Path: String);
    procedure LoadFromFile(const Path: String);
    procedure PushPtrs;
    function GetPauseFlag: Integer;
    function GetByteCodeLine: Integer;
    procedure SetByteCodeLine(N: Integer);
    procedure InitByteCodeLine;
    function GetSourceLine: Integer;
    function GetModuleName: String;
    function GetModuleIndex: Integer;
    function IsPaused: Boolean;
    procedure Pause;
    procedure Terminate;
    procedure RemovePause;
    function Valid: Boolean;
    procedure UnloadDlls;
    procedure SetZList;
    function GetImageSize: Integer;
    function CreateScriptObject(const ScriptClassName: String): TObject;
    procedure DestroyScriptObject(var X: TObject);
    function GetOffset(Shift: Integer): Integer;
    procedure CreateMapOffsets;
    function GetFieldAddress(X: TObject; const FieldName: String): Pointer;
    procedure DiscardDebugMode;
    procedure RunEx;
    procedure SaveState(S: TStream);
    procedure LoadState(S: TStream);
    procedure SetupInterfaces;

    procedure CreateClassFactory;
    procedure LoadDFMStream(Instance: TObject; S: TStream);
    procedure LoadDFMFile(Instance: TObject; const FileName: String);
    procedure RebindEvents(AnInstance: TObject);
    function GetTypeInfo(const FullTypeName: String): PTypeInfo;

    function CallFunc(const FullName: String;
              This: Pointer;
              const ParamList: array of OleVariant): OleVariant;
    function CallFuncEx(const FullName: String;
                        This: Pointer;
                        const ParamList: array of const): Variant;
    procedure CopyRootEvents;
    function FileExists(const FileName: String; out FullPath: String): Boolean;
    procedure RaiseError(const Message: string; params: array of Const);

    property CodePtr: PBytes read GetCodePtr;
    property DataPtr: PBytes read GetDataPtr;
    property ResultPtr: Pointer read GetResultPtr;
    property CodeSize: Integer read fCodeSize;
    property DataSize: Integer read fDataSize;
    property ProgramSize: Integer read GetProgramSize;
    property ClassList: TClassList read fClassList;
    property Integers[Shift: Integer]: Integer read GetInteger;
    property PChars[Shift: Integer]: PChar read GetPChar;
    property ShortStrings[Shift: Integer]: ShortString read GetShortString;
    property TryList: TTryList read fTryList;
    property PauseRec: TPauseRec read fPauseRec;
    property CurrN: Integer read GetByteCodeLine;

    property IsRunning: Boolean read fIsRunning;

    property RootProg: TProgram read GetRootProg;

    property RootTryStack: TTryStack read GetTryStack;
    property RootCallStackID: TIntegerStack read GetCallStackID;
    property RootCallStackEBP: TIntegerStack read GetCallStackEBP;
    property RootCallStackNCall: TIntegerStack read GetCallStackNCall;
    property RootInitCallStackCount: Integer read GetInitCallStackCount write SetInitCallStackCount;
    property RootESP0: Integer read GetESP0 write SetESP0;
    property RootCurrException: Exception read GetCurrException write SetCurrException;
    property RootProcessingExceptBlock: Boolean read GetProcessingExceptBlock
      write SetProcessingExceptBlock;
    property RootExceptionIsAvailableForHostApplication: Boolean
      read GetExceptionIsAvailableForHostApplication
      write SetExceptionIsAvailableForHostApplication;
    property RootIsEvent: Boolean read GetIsEvent write SetIsEvent;

    property RootGC: TGC read GetRootGC;

    property IsRootProg: Boolean read GetIsRootProg;
  end;

procedure ZZZ;

implementation

// TTryStack -------------------------------------------------------------------

function TTryStack.GetRecord(I: Integer): TTryStackRec;
begin
  result := TTryStackRec(L[I]);
end;

function TTryStack.GetTop: TTryStackRec;
begin
  if Count  = 0 then
    raise PaxCompilerException.Create(errInternalError);
  result := Records[Count - 1];
end;

function TTryStack.IndexOf(ATryBlockNumber: Integer): Integer;
var
  I: Integer;
begin
  result := -1;
  for I := 0 to Count - 1 do
    if Records[I].TryBlockNumber = ATryBlockNumber then
    begin
      result := I;
      Exit;
    end;
end;

procedure TTryStack.Push(ATryBlockNumber: Integer; AProg: TProgram);
var
  R: TTryStackRec;
begin
  R := TTryStackRec.Create;
  R.TryBlockNumber := ATryBlockNumber;
  R.Prog := AProg;
  L.Add(R);
end;

procedure TTryStack.Pop;
begin
  Records[Count - 1].Free;
  L.Delete(Count - 1);
end;

procedure TTryStack.SaveToStream(S: TStream);
var
  I, K: Integer;
begin
  K := Count;
  S.Write(K, SizeOf(K));
  for I := 0 to K - 1 do
  with Records[I] do
  begin
    S.Write(TryBlockNumber, SizeOf(TryBlockNumber));
    S.Write(Prog, SizeOf(Prog));
  end;
end;

procedure TTryStack.LoadFromStream(S: TStream);
var
  I, K: Integer;
  R: TTryStackRec;
begin
  Clear;
  S.Read(K, SizeOf(K));
  for I := 0 to K - 1 do
  begin
    R := TTryStackRec.Create;
    with R do
    begin
      S.Read(TryBlockNumber, SizeOf(TryBlockNumber));
      S.Read(Prog, SizeOf(Prog));
    end;
    L.Add(R);
  end;
end;

// TProgram --------------------------------------------------------------------

constructor TProgram.Create;
begin
  inherited Create;

  Owner := nil;

  fDataSize := 0;
  Data := nil;
  fCodeSize := 0;
  Prog := nil;

  fClassList := TClassList.Create;
  fTryList := TTryList.Create;
  fTryStack := TTryStack.Create;
  fPauseRec := TPauseRec.Create;

  fCurrException := nil;

  RuntimeModuleList := TRuntimeModuleList.Create;
  fExceptionIsAvailableForHostApplication := true;

  EventHandlerList := TEventHandlerList.Create;

  RunMode := 0;
  fCallStackId := TIntegerStack.Create;
  fCallStackEBP := TIntegerStack.Create;
  fCallStackNCall := TIntegerStack.Create;
  fInitCallStackCount := 0;

  ScriptDefinedException := nil;

  JS_Object := nil;
  JS_Boolean := nil;
  JS_String := nil;
  JS_Number := nil;
  JS_Date := nil;
  JS_Function := nil;
  JS_Array := nil;
  JS_Math := nil;
  ContextList := TList.Create;

  EPoint := nil;

  DllList := TStringList.Create;
  ProgList := TProgList.Create(Self);
  PCUOwner := nil;
  ZList := TIntegerList.Create;

  fIsRunning := false;

  HostMapTable := TMapTable.Create;
  ScriptMapTable := TMapTable.Create;
  LocalSymbolTable := TLocalSymbolTable.Create;
  OffsetList := TOffsetList.Create;

  UseMapping := false;
  fIsEvent := false;

  ProgClassFactory := TPaxClassFactory.Create;
  ProgTypeInfoList := TPaxTypeInfoList.Create;

  fGC := TGC.Create;
end;

destructor TProgram.Destroy;
begin
  if Assigned(ScriptDefinedException) then
    ScriptDefinedException.Free;

  UnloadDlls;
  DllList.Free;
  if ProgList <> nil then
    ProgList.Free;
  ZList.Free;

  fClassList.Free;
  fTryList.Free;
  fTryStack.Free;
  fPauseRec.Free;
  RuntimeModuleList.Free;
  fCallStackId.Free;
  fCallStackEBP.Free;
  fCallStackNCall.Free;

  Deallocate;

  EventHandlerList.Free;

  HostMapTable.Free;
  ScriptMapTable.Free;

  LocalSymbolTable.Free;
  OffsetList.Free;

  if Assigned(fCurrException) then
    fCurrException.Free;

  ContextList.Free;

  ProgClassFactory.Free;
  ProgTypeInfoList.Free;

  fGC.Free;

  inherited;
end;

procedure TProgram.CreateClassFactory;
var
  I: Integer;
  ClassRec: TClassRec;
  C: TClass;
  S: String;
  P: Pointer;
  PaxInfo: PPaxInfo;
  MR: TMapRec;
begin
  ProgClassFactory.Clear;

  for I:=0 to ClassList.Count - 1 do
  begin
    ClassRec := ClassList[I];
    if ClassRec.Host then
      continue;
    S := ExtractName(ClassRec.FullName);
    C := ProgClassFactory.CreatePaxClass(ClassRec.FullName, ClassRec.InstSize, TObject);
    ClassRec.PClass := C;

    P := GetAddress(ClassRec.FullName, MR);
    if P <> nil then
      Pointer(P^) := C;

    PaxInfo := GetPaxInfo(ClassRec.PClass);
    if PaxInfo = nil then
       RaiseError(errInternalError, []);
    PaxInfo^.Prog := Self;
    PaxInfo^.ClassIndex := I;
  end;

  ProgClassFactory.SetupParents(ClassList);
  ProgClassFactory.AddInheritedMethods;
  ProgClassFactory.AddOverridenMethods(Self, ScriptMapTable);
  ProgClassFactory.SetupStdVirtuals(ClassList, CodePtr);

  ProgTypeInfoList.AddToProgram(Self);
end;

procedure TProgram.UnloadDlls;
var
  H: Cardinal;
begin
  while DllList.Count > 0 do
  begin
    H := Cardinal(DllList.Objects[0]);
    FreeLibrary(H);
    DllList.Delete(0);
  end;
end;

procedure TProgram.Reset;
begin
  if Assigned(ScriptDefinedException) then
  begin
    ScriptDefinedException.Free;
    ScriptDefinedException := nil;
  end;

  ZList.Clear;
  fClassList.Clear;
  fTryList.Clear;
  fTryStack.Clear;
  fPauseRec.Clear;
  EventHandlerList.Clear;
  ContextList.Clear;
  fCallStackId.Clear;
  fCallStackEBP.Clear;
  fCallStackNCall.Clear;
  fInitCallStackCount := 0;
  Deallocate;
  EPoint := nil;

  fIsRunning := false;
  fIsEvent := false;

  ProgClassFactory.Clear;
  ProgTypeInfoList.Clear;
  if ProgList <> nil then
    ProgList.Clear;

  fGC.Clear;
end;

procedure TProgram.SetZList;
var
  I, S: Integer;
  P: Pointer;
begin
  for I:=0 to ZList.Count - 1 do
  begin
    S := ZList[I];
    P := ShiftPointer(CodePtr, S + 1);
    Pointer(P^) := @ ZZZ;

    P := ShiftPointer(P, 12);
    Pointer(P^) := CodePtr;

    P := ShiftPointer(P, 5);
    Pointer(P^) := DataPtr;
  end;
end;

function TProgram.RegisterClass(C: TClass;
                                const FullName: String;
                                Offset: Integer = -1): TClassRec;
var
  P: Pointer;
  I: Integer;
  S: String;
begin
  if (Offset = -1) or (Offset = 0) then
  begin
    S := C.ClassName;
    for I:=0 to fClassList.Count - 1 do
      if StrEql(fClassList.Names[I], S) then
      begin
        Offset := fClassList[I].Offset;
        break;
      end;
    if Offset = -1 then
      RaiseError(errCannotRegisterClass, [S]);
  end;

  P := ShiftPointer(DataPtr, Offset);
  Pointer(P^) := C;

  result := fClassList.AddClass(C, FullName, true, Offset);

  for I:=0 to result.PropInfos.Count - 1 do
  begin
    P := ShiftPointer(P, SizeOf(Pointer));
    Pointer(P^) := result.PropInfos[I];
  end;
end;

function TProgram.RegisterClassEx(C: TClass;
                                  const FullName: String;
                                  Offset: Integer; ClassIndex: Integer): TClassRec;
var
  P: Pointer;
  I: Integer;
begin
  P := ShiftPointer(DataPtr, Offset);
  Pointer(P^) := C;

  result := fClassList.AddClassEx(C, FullName, true, Offset, ClassIndex);

  for I:=0 to result.PropInfos.Count - 1 do
  begin
    P := ShiftPointer(P, SizeOf(Pointer));
    Pointer(P^) := result.PropInfos[I];
  end;
end;

function TProgram.GetInteger(Shift: Integer): Integer;
var
  P: Pointer;
begin
  P := ShiftPointer(DataPtr, Shift);
  result := Integer(P^);
end;

function TProgram.GetPChar(Shift: Integer): PChar;
var
  P: Pointer;
begin
  P := ShiftPointer(DataPtr, Shift);
  result := PChar(P^);
end;

function TProgram.GetShortString(Shift: Integer): ShortString;
var
  P: Pointer;
begin
  P := ShiftPointer(DataPtr, Shift);
  result := ShortString(P^);
end;

procedure TProgram.Reallocate(NewCodeSize: Integer);
begin
  if NewCodeSize = fCodeSize then
    Exit;
  if NewCodeSize < fCodeSize then
    RaiseError(errInternalError, []);
  fCodeSize := NewCodeSize;
  ReallocMem(Prog, fCodeSize);
end;

procedure TProgram.Allocate(InitCodeSize, InitDataSize: Integer);
begin
  Deallocate;

  fDataSize := InitDataSize;
  Data := AllocMem(fDataSize);

  fCodeSize := InitCodeSize;
  Prog := AllocMem(fCodeSize);

  Protect;

  SetAddress(H_SelfPtr, Self);
  SetAddress(H_ExceptionPtr, @ fCurrException);

  RegisterDefinitions(GlobalSymbolTable);
end;

procedure TProgram.AllocateSimple(InitCodeSize, InitDataSize: Integer);
begin
  Deallocate;

  fDataSize := InitDataSize;
  Data := AllocMem(fDataSize);

  fCodeSize := InitCodeSize;
  Prog := AllocMem(fCodeSize);
end;

function TProgram.Valid: Boolean;
begin
  result := (Data <> nil) and (Prog <> nil);
end;

procedure TProgram.Deallocate;
begin
  if Data <> nil then
  begin
    FreeMem(Data, fDataSize);
    Data := nil;
  end;

  if Prog <> nil then
  begin
    FreeMem(Prog, fCodeSize);
    Prog := nil;
  end;

  if Assigned(fCurrException) then
  begin
    fCurrException.Free;
    fCurrException := nil;
  end;

  UnProtect;
  InitializationIsProcessed := false;
end;

procedure TProgram.SetAddress(Offset: Integer; P: Pointer);
begin
  Move(P, DataPtr^[Offset], SizeOf(Pointer));
end;

function TProgram.GetAddress(Handle: Integer): Pointer;
begin
  if Handle < 0 then
    result := ShiftPointer(CodePtr, - Handle)
  else
  begin
    result := ShiftPointer(DataPtr, GetOffset(Handle));
  end;
end;

function TProgram.SetHostAddress(const FullName: String; Address: Pointer): Boolean;
var
  MR: TMapRec;
  P: Pointer;
begin
  result := false;
  MR := HostMapTable.Lookup(FullName);
  if MR <> nil then
  if MR.Kind in KindSUBS + [KindVAR] then
  begin
    P := ShiftPointer(DataPtr, MR.Offset);
    Pointer(P^) := Address;
    result := true;
  end;
end;

function TProgram.GetAddress(const FullName: String; var MR: TMapRec): Pointer;
begin
  result := nil;
  MR := ScriptMapTable.Lookup(FullName);
  if MR <> nil then
  begin
    case MR.Kind of
      KindVAR, kindTYPE: result := ShiftPointer(DataPtr, MR.Offset);
      KindSUB, KindCONSTRUCTOR, KindDESTRUCTOR:
      begin
        if MR.IsExternal then
          result := nil
        else
          result := ShiftPointer(CodePtr, MR.Offset);
      end;
    end;
    Exit;
  end;

  MR := HostMapTable.Lookup(FullName);
  if MR <> nil then
  if MR.Kind in KindSUBS + [KindVAR] then
  begin
    result := ShiftPointer(DataPtr, MR.Offset);
    result := Pointer(result^);
  end;
end;

function TProgram.GetAddressEx(const FullName: String; OverCount: Integer;
                               var MR: TMapRec): Pointer;
begin
  result := nil;

  if OverCount = 0 then
  begin
    result := GetAddress(FullName, MR);
    Exit;
  end;

  MR := ScriptMapTable.LookupEx(FullName, OverCount);
  if MR <> nil then
  begin
    case MR.Kind of
      KindVAR, kindTYPE: result := ShiftPointer(DataPtr, MR.Offset);
      KindSUB, KindCONSTRUCTOR, KindDESTRUCTOR:
      begin
        if MR.IsExternal then
          result := nil
        else
          result := ShiftPointer(CodePtr, MR.Offset);
      end;
    end;
    Exit;
  end;

  MR := HostMapTable.LookupEx(FullName, OverCount);
  if MR <> nil then
  if MR.Kind in KindSUBS + [KindVAR] then
  begin
    result := ShiftPointer(DataPtr, MR.Offset);
    result := Pointer(result^);
    Exit;
  end;
end;

function TProgram.GetCallConv(const FullName: String): Integer;
var
  MapRec: TMapRec;
begin
  result := ccREGISTER;
  MapRec := ScriptMapTable.Lookup(FullName);

  if MapRec <> nil then
    if MapRec.Kind in KindSUBS then
    begin
      result := MapRec.SubDesc.CallConv;
      Exit;
    end;

  MapRec := HostMapTable.Lookup(FullName);
  if MapRec <> nil then
    if MapRec.Kind in KindSUBS then
      result := MapRec.SubDesc.CallConv;
end;

function TProgram.GetRetSize(const FullName: String): Integer;
var
  MapRec: TMapRec;
begin
  result := 0;
  MapRec := ScriptMapTable.Lookup(FullName);

  if MapRec <> nil then
    if MapRec.Kind in KindSUBS then
    begin
      result := MapRec.SubDesc.RetSize;
      Exit;
    end;

  MapRec := HostMapTable.Lookup(FullName);
  if MapRec <> nil then
    if MapRec.Kind in KindSUBS then
      result := MapRec.SubDesc.RetSize;
end;

procedure TProgram.RaiseError(const Message: string; params: array of Const);
begin
  raise Exception.Create(Format(Message, params));
end;

function TProgram.GetResultPtr: Pointer;
begin
  result := Data;
end;

function TProgram.GetCodePtr: PBytes;
begin
  result := Prog;
end;

function TProgram.GetDataPtr: PBytes;
begin
  result := Data;
end;

function TProgram.GetByteCodeLine: Integer;
var
  P: Pointer;
begin
  P := ShiftPointer(Data, H_ByteCodePtr);
  result := Integer(P^);
end;

procedure TProgram.SetByteCodeLine(N: Integer);
var
  P: Pointer;
begin
  P := ShiftPointer(Data, H_ByteCodePtr);
  Integer(P^) := N;
end;

function TProgram.GetPauseFlag: Integer;
var
  P: Pointer;
begin
  P := ShiftPointer(Data, H_Flag);
  result := Integer(P^);
end;

procedure TProgram.InitByteCodeLine;
var
  P: Pointer;
begin
  P := ShiftPointer(Data, H_ByteCodePtr);
  Integer(P^) := -1;
end;

function TProgram.GetSourceLine: Integer;
begin
  result := GetByteCodeLine;

  if result = - 1 then
    Exit;

  result := RunTimeModuleList.GetSourceLine(result);
end;

function TProgram.GetModuleName: String;
var
  ByteCodeLine: Integer;
begin
  result := '';
  ByteCodeLine := GetByteCodeLine;

  if ByteCodeLine = - 1 then
    Exit;

  result := RunTimeModuleList.GetModuleName(ByteCodeLine);
end;

function TProgram.GetModuleIndex: Integer;
var
  ByteCodeLine: Integer;
begin
  result := -1;
  ByteCodeLine := GetByteCodeLine;

  if ByteCodeLine = - 1 then
    Exit;

  result := RunTimeModuleList.GetModuleIndex(ByteCodeLine);
end;

procedure TProgram.RegisterDefinitions(SymbolTable: TBaseSymbolTable);
var
  I, J, I1, Offset: Integer;
  R, R1: TSymbolRec;
  FullName: String;
  IsGlobal: Boolean;
  MapRec: TMapRec;
begin
  IsGlobal := SymbolTable = GlobalSymbolTable;

  if UseMapping then
  begin
    if HostMapTable.Count > 0 then
    begin
      for I:=0 to HostMapTable.Count - 1 do
      begin
        MapRec := HostMapTable[I];
        if MapRec.Kind <> kindNAMESPACE then
          continue;
        if MapRec.Global <> IsGlobal then
          continue;
        FullName := MapRec.FullName;
        J := SymbolTable.LookupFullName(FullName, true);
        if J = 0 then
          if Assigned(OnMapTableNamespace) then
             OnMapTableNamespace(Owner,
                                 FullName,
                                 MapRec.Global);
      end;
    end;
  end;

  if IsGlobal then
    I1 := 1
  else
    I1 := FirstLocalId + 1;

  for I:=I1 to SymbolTable.Card do
  begin
    R := SymbolTable[I];

    if R.Address <> nil then
    begin
      Offset := GetOffset(R.Shift);
      if Offset = -1 then
        continue;

      SetAddress(Offset, R.Address);
    end
    else if R.ClassIndex <> -1 then
    begin
      R1 := SymbolTable[I + 1]; // cls ref
      J := R1.Value;
      if J = 0 then
        ClassList.Add(R.FullName, R. Host)
      else
      begin
        Offset := GetOffset(R1.Shift);
        if Offset = -1 then
          continue;

        RegisterClass(TClass(J), R.FullName, Offset);
      end;
    end;
  end;
end;

procedure TProgram.ForceMapping(SymbolTable: TBaseSymbolTable;
                                Reassign: Boolean);
var
  IsGlobal: Boolean;
  I, J: Integer;
  MapRec: TMapRec;
  FullName: String;
  P: Pointer;
  ClsRef: TClass;
begin
  IsGlobal := SymbolTable = GlobalSymbolTable;

  if HostMapTable.Count > 0 then
  begin
    for I:=0 to HostMapTable.Count - 1 do
    begin
      MapRec := HostMapTable[I];

      if MapRec.Global <> IsGlobal then
        continue;

      if MapRec.TypedConst then
        continue;

      FullName := MapRec.FullName;

      J := SymbolTable.LookupFullNameEx(FullName, true, MapRec.SubDesc.OverCount);
      if J > 0 then
      begin
        if MapRec.Kind = KindVAR then
        begin
          P := SymbolTable[J].Address;
          if P <> nil then
          begin
            if Reassign then
            begin
              if Assigned(OnMapTableVarAddress) then
                          OnMapTableVarAddress(Owner,
                                               FullName,
                                               MapRec.Global,
                                               P);

              if P = nil then
                RaiseError(errUnresolvedAddress, [FullName]);

              SymbolTable[J].Address := P;
            end;

            SetAddress(MapRec.Offset, P);
          end
          else
          begin
            P := nil;
            if Assigned(OnMapTableVarAddress) then
                        OnMapTableVarAddress(Owner,
                                             FullName,
                                             MapRec.Global,
                                             P);
            if P = nil then
              RaiseError(errUnresolvedAddress, [FullName]);
            SetAddress(MapRec.Offset, P);
          end;
        end
        else if MapRec.Kind in KindSUBS then
        begin
          P := SymbolTable[J].Address;

          if P <> nil then
            SetAddress(MapRec.Offset, P)
          else
          begin
            P := nil;
            if Assigned(OnMapTableProcAddress) then
                        OnMapTableProcAddress(Owner,
                                              FullName,
                                              MapRec.SubDesc.OverCount,
                                              MapRec.Global,
                                              P);
            if P = nil then
              RaiseError(errUnresolvedAddress, [FullName]);
            SetAddress(MapRec.Offset, P);
          end;
        end
        else if MapRec.Kind = KindTYPE then
        begin
          ClsRef := TClass(Integer(SymbolTable[J + 1].Value));
          if ClsRef = nil then
            if Assigned(OnMapTableClassRef) then
              OnMapTableClassRef(Owner,
                                 FullName,
                                 MapRec.Global,
                                 ClsRef);
          if ClsRef = nil then
            RaiseError(errUnresolvedClassReference, [FullName])
  //            ClassList.AddEx(ExtractName(FullName), MapRec.ClassIndex)
          else
            RegisterClassEx(ClsRef, MapRec.FullName, MapRec.Offset, MapRec.ClassIndex);
        end;
      end
      else
      begin
        if MapRec.Kind = KindVAR then
        begin
          if Assigned(OnMapTableVarAddress) then
          begin
            P := nil;
            OnMapTableVarAddress(Owner,
                                 FullName,
                                 MapRec.Global,
                                 P);
            if P = nil then
              RaiseError(errUnresolvedAddress, [FullName]);
            SetAddress(MapRec.Offset, P);
          end
          else
            RaiseError(errHostMemberIsNotDefined, [FullName]);
        end
        else if MapRec.Kind in KindSUBS then
        begin
          if Assigned(OnMapTableProcAddress) then
          begin
            P := nil;
            OnMapTableProcAddress(Owner,
                                  FullName,
                                  MapRec.SubDesc.OverCount,
                                  MapRec.Global,
                                  P);
            if P = nil then
              RaiseError(errUnresolvedAddress, [FullName]);
            SetAddress(MapRec.Offset, P);
          end
          else
            RaiseError(errHostMemberIsNotDefined, [FullName]);
        end
        else if MapRec.Kind = KindTYPE then
        begin
          if Assigned(OnMapTableClassRef) then
          begin
            ClsRef := nil;
            OnMapTableClassRef(Owner,
                               FullName,
                               MapRec.Global,
                               ClsRef);
            if ClsRef = nil then
              RaiseError(errUnresolvedClassReference, [FullName])
  //                ClassList.AddEx(ExtractName(FullName), MapRec.ClassIndex)
            else
              RegisterClassEx(ClsRef, MapRec.FullName, MapRec.Offset, MapRec.ClassIndex);
          end
          else
            RaiseError(errHostMemberIsNotDefined, [FullName]);
        end;
      end;
    end;
  end;

  for I:=0 to ProgList.Count - 1 do
    TProgram(ProgList[I].Prog).ForceMapping(SymbolTable, Reassign);
end;

procedure TProgram.ForceMappingEvents;
var
  I, J, TypeId: Integer;
  MapRec: TMapRec;
  P: Pointer;
  ClsRef: TClass;
  L: TIntegerList;
  C: TClass;
  ClassRec: TClassRec;
begin
  if not Assigned(OnMapTableProcAddress) then
    Exit;
  if not Assigned(OnMapTableClassRef) then
    Exit;

  L := TIntegerList.Create;

  try

    for I:=0 to HostMapTable.Count - 1 do
    begin
      MapRec := HostMapTable[I];
      if MapRec.Kind in KindSUBS then
      begin
        P := nil;
        OnMapTableProcAddress(Owner,
                              MapRec.FullName,
                              MapRec.SubDesc.OverCount,
                              MapRec.Global,
                              P);
        if P <> nil then
        begin
          J := GlobalSymbolTable.LookupFullNameEx(MapRec.FullName, true, MapRec.SubDesc.OverCount);
          if J > 0 then
          begin
            GlobalSymbolTable[J].Address := P;
            if GlobalSymbolTable[J].IsVirtual then
              if GlobalSymbolTable[J].MethodIndex = 0 then
                L.Add(J);
          end;
          SetAddress(MapRec.Offset, P);
        end;
      end
      else if MapRec.Kind = KindTYPE then
      begin
        ClsRef := nil;
        if Assigned(OnMapTableClassRef) then
            OnMapTableClassRef(Owner,
                               MapRec.FullName,
                               MapRec.Global,
                               ClsRef);
        if ClsRef <> nil then
        begin
          J := GlobalSymbolTable.LookupFullName(MapRec.FullName, true);
          if J > 0 then
          begin
            GlobalSymbolTable[J].PClass := ClsRef;
            GlobalSymbolTable[J+1].Value := Integer(ClsRef);
          end;
          ClassRec := ClassList.Lookup(MapRec.FullName);
          if ClassRec <> nil then
            ClassRec.PClass := ClsRef;
        end;
      end;
    end;

    for I:=0 to L.Count - 1 do
    begin
      J := L[I];
      TypeId := GlobalSymbolTable[J].Level;
      C := GlobalSymbolTable[TypeId].PClass;
      if C = nil then
        RaiseError(errInternalErrorMethodIndex, []);
      GlobalSymbolTable[J].MethodIndex := VirtualMethodIndex(PPointerArray(C),
         GlobalSymbolTable[J].Address) + 1;
    end;
  finally
    L.Free;
  end;
end;

procedure TProgram.SaveToBuff(var Buff);
var
  P: Pointer;
  S: TMemoryStream;
begin
  P := @Buff;
  S := TMemoryStream.Create;
  try
    SaveToStream(S);
    S.Position := 0;
    S.Read(P^, S.Size);
  finally
    S.Free;
  end;
end;

procedure TProgram.LoadFromBuff(var Buff);
var
  P: Pointer;
  temp: TMemoryStream;
  SZ: Integer;
begin
  P := @Buff;
  temp := TMemoryStream.Create;
  try
    temp.Write(P^, SizeOf(Integer));
    SZ := Integer(P^);
    temp.Position := 0;
    temp.Write(P^, SZ);
    temp.Position := 0;
    LoadFromStream(temp);
  finally
    temp.Free;
  end;
end;

function TProgram.GetImageSize: Integer;
var
  S: TMemoryStream;
begin
  S := TMemoryStream.Create;
  try
    SaveToStream(S);
    result := S.Size;
  finally
    S.Free;
  end;
end;

procedure TProgram.SaveToStream(S: TStream);
var
  StartSize, EndSize, StartPos, EndPos, StreamSize: Integer;
begin
  StartSize := S.Size;
  StartPos  := S.Position;

  S.Write(StreamSize, SizeOf(Integer));
  S.Write(CompiledScriptVersion, SizeOf(CompiledScriptVersion));

  S.Write(fDataSize, SizeOf(Integer));
  S.Write(fCodeSize, SizeOf(Integer));

  S.Write(Data^, fDataSize);
  S.Write(Prog^, fCodeSize);

  fClassList.SaveToStream(S);
  RunTimeModuleList.SaveToStream(S);
  TryList.SaveToStream(S);
  ZList.SaveToStream(S);

  HostMapTable.SaveToStream(S);
  ScriptMapTable.SaveToStream(S);
  OffsetList.SaveToStream(S);
  ProgTypeInfoList.SaveToStream(S);

  ProgList.SaveToStream(S);

  EndSize := S.Size;
  EndPos  := S.Position;
  StreamSize := EndSize - StartSize;
  S.Position := StartPos;
  S.Write(StreamSize, SizeOf(Integer));
  S.Position := EndPos;
end;

procedure TProgram.LoadFromStream(S: TStream);
var
 Version: Integer;
 K: Integer;
begin
  Deallocate;
  S.Read(K, SizeOf(Integer));
  S.Read(Version, SizeOf(CompiledScriptVersion));
  if Version <> CompiledScriptVersion then
   RaiseError(errIncorrectCompiledScriptVersion, []);

  S.Read(fDataSize, SizeOf(Integer));
  S.Read(fCodeSize, SizeOf(Integer));

  Data := AllocMem(fDataSize);
  Prog := AllocMem(fCodeSize);

  S.Read(Data^, fDataSize);
  S.Read(Prog^, fCodeSize);

  fClassList.Clear;
  fClassList.LoadFromStream(S, Version);

  RunTimeModuleList.Clear;
  RunTimeModuleList.LoadFromStream(S);
  TryList.Clear;
  TryList.LoadFromStream(S);

  ZList.Clear;
  ZList.LoadFromStream(S);

  HostMapTable.Clear;
  HostMapTable.LoadFromStream(S);
  ScriptMapTable.Clear;
  ScriptMapTable.LoadFromStream(S);

  OffsetList.Clear;
  OffsetList.LoadFromStream(S);
  ProgTypeInfoList.Clear;
  ProgTypeInfoList.LoadFromStream(S);

  ProgList.Clear;
  ProgList.LoadFromStream(S, Self);
  ProgList.SetPCUOwner(Self);

  UseMapping := HostMapTable.Count > 0;

  SetAddress(H_SelfPtr, Self);
  SetAddress(H_ExceptionPtr, @ fCurrException);

  RegisterDefinitions(GlobalSymbolTable);
  if UseMapping then
  begin
   LocalSymbolTable.Free;
   LocalSymbolTable := TLocalSymbolTable.Create;

   LocalSymbolTable.Reset;
   RegisterDefinitions(LocalSymbolTable);
  end;

  SetZList;
  SetupInterfaces;

  ProgClassFactory.ForceCreate := true;
end;

procedure TProgram.SaveToFile(const Path: String);
var
  F: TFileStream;
begin
  F := TFileStream.Create(Path, fmCreate);
  try
    SaveToStream(F);
  finally
    F.Free;
  end;
end;

procedure TProgram.LoadFromFile(const Path: String);
var
  F: TFileStream;
begin
  F := TFileStream.Create(Path, fmOpenRead or fmShareDenyWrite);
  try
    LoadFromStream(F);
  finally
    F.Free;
  end;
end;

function TProgram.IsPaused: Boolean;
begin
  result := PauseRec.ProgOffset > 0;
end;

{
procedure TProgram.Resume;
begin
  if not IsPaused then
    RaiseError(errProgramIsNotPaused, []);
  Run;
end;
}

procedure TProgram.Pause;
var
  P: Pointer;
begin
  P := ShiftPointer(Data, H_Flag);
  Integer(P^) := 1;
end;

procedure TProgram.Terminate;
var
  P: Pointer;
begin
  P := ShiftPointer(Data, H_Flag);
  Integer(P^) := 2;
end;

procedure TProgram.RemovePause;
var
  P: Pointer;
begin
  P := ShiftPointer(Data, H_Flag);
  Integer(P^) := 0;
end;

procedure TProgram.Protect;
begin
  {$IFNDEF LINUX}
  // Windows
  if IsProtected then
    Exit;

  VirtualQuery(Prog, mbi, sizeof(mbi));
//  VirtualProtect(mbi.BaseAddress, mbi.RegionSize, PAGE_EXECUTE_READWRITE, OldProtect);
  VirtualProtect(Prog, CodeSize, PAGE_EXECUTE_READWRITE, OldProtect);
  FlushInstructionCache(GetCurrentProcess, Prog, CodeSize);
// Applications should call FlushInstructionCache if they generate or modify
// code in memory. The CPU cannot detect the change, and may execute the old
// code it cached.

  IsProtected := true;

  {$ELSE}
  {$ENDIF}
end;

procedure TProgram.UnProtect;
begin
  {$IFNDEF LINUX}
  // Windows

  if not IsProtected then
    Exit;

//  VirtualProtect(mbi.BaseAddress, mbi.RegionSize, OldProtect, OldProtect);
  VirtualProtect(Prog, CodeSize, OldProtect, OldProtect);

  IsProtected := false;

  {$ELSE}
  {$ENDIF}
end;

procedure TProgram.Run;
var
  D, P, P0: Pointer;
  ProgOffset: Integer;
  Handled: Boolean;
  _EBP, _ESP: Integer;
  TryRec: TTryRec;
  I, Delta: Integer;
  ClsIndex: Integer;
  ClassRec: TClassRec;
  StackFrame: Pointer;
  K: Integer;
  SourceLine, SourceLineFinally: Integer;
  HasError: Boolean;
  ModuleName, ModuleNameFinally: String;
  CE: TExceptionClass;
  PEpoint: Pointer;
  StackFrameSize: Integer;
  IsHaltException: Boolean;
  IsPauseException: Boolean;
  IsExitException: Boolean;
  TryBlockNumber: Integer;

  SelfPtr: TProgram;
  HandledByExcept: Boolean;
label
  Again;
begin
//  PChars[0];
//  ShortStrings[0];
//  Integers[0];
  SourceLineFinally := -1;
  ModuleNameFinally := '';

  IsRootProg;

  if ProgClassFactory.ForceCreate then
  begin
    CreateClassFactory;
    ProgClassFactory.ForceCreate := false;
  end;

  fIsRunning := true;
  IsHalted := false;
  IsPauseUpdated := false;

  PEpoint := nil;

  ProgOffset := 0;
  Handled := false;

  SelfPtr := Self;

  with SelfPtr do
  begin
    D  := Data;
    P0 := Prog;
  end;

  SourceLine := -1;
  ExitCode := 0;

  IsHaltException := false;
  IsPauseException := false;

  fInitCallStackCount := fCallStackId.Count;

  if IsPaused then
  begin
    Handled := true;
    StackFrameSize := PauseRec.StackFrameSize;
    K := PauseRec.StackFrameSize div 4;
    StackFrame := PauseRec.StackFrame;
    ProgOffset := PauseRec.ProgOffset;
    _ESP := PauseRec._ESP;
    _EBP := PauseRec._EBP;

    PauseRec.ProgOffset := 0;
  end;

  RemovePause;

Again:

  HasError := false;
  HandledByExcept := false;

  try
    if Handled then
    begin
      Handled := false;

      asm
        mov I, esp
      end;

      Delta := fESP0 - I;
      fESP0 := I;
      _ESP := _ESP - Delta;
      _EBP := _EBP - Delta;

      for I := 0 to fCallStackEBP.Count - 1 do
        fCallStackEBP[I] := fCallStackEBP[I] - Delta;

        // restore stack frame
      I := fESP0 - 4;

      asm
        mov eax, I
        mov ebx, StackFrame

        add ebx, StackFrameSize //!!
        sub ebx, 4              //!!

        mov ecx, K

        @@loop:

        mov edx, [ebx]
        mov [eax], edx

        sub eax, 4

//        add ebx, 4
        sub ebx, 4

        sub ecx, 1
        cmp ecx, 0
        jnz @@loop
      end;

      P := Pointer(Integer(P0) + ProgOffset);

      asm
        // assign code and data registers
        mov esi, D
        mov edi, P0

        mov eax, P

        mov esp, _ESP
        mov ebp, _EBP

        jmp eax

      end;
    end
    else
    begin
      InitByteCodeLine;

      asm
        mov _ESP, esp
      end;

      fESP0 := _ESP;

      if EPoint = nil then
      begin
        P := P0;

        asm
          mov esi, D
          mov edi, P

          call P
       end;

      end
      else
      begin
        if not EPoint.IsInternal then
          EPoint.Setup;

        PEpoint := EPoint;

//        P  := ShiftPointer(EPoint.Address, 14);
        P  := EPoint.Address;

        asm
          mov esi, D
          mov edi, P0
        end;

        if EPoint.IsInternal then
          EPoint.PushArgumentsBackward
        else
          EPoint.PushArguments;

        asm
          call P
        end;

        asm
          mov ebx, PEpoint

          cmp ebx, 0
          jz @@Return

          // if call convention is cdecl then pop arguments
          mov ecx, [ebx + 28] // fCallConv
          cmp ecx, ccCDECL
          jnz @@Ret
          mov ecx, [ebx + 8] // fStackSize
          add esp, ecx

          @@Ret:

          mov ecx, [ebx + 32] // fResultType

          cmp ecx, __typeINTEGER
          jnz @@RetDOUBLE
          mov ecx, [ebx + 28] // fCallConv
          cmp ecx, ccSAFECALL
          jz @@Return
          mov [ebx + 36], eax
          jmp @@Return
        //

          @@RetDOUBLE:

          cmp ecx, typeDOUBLE
          jnz @@RetSINGLE
          fstp qword ptr [ebx + 36]
          jmp @@Return
        //

          @@RetSINGLE:

          cmp ecx, typeSINGLE
          jnz @@RetEXTENDED
          fstp dword ptr [ebx + 36]
          jmp @@Return
        //

          @@RetEXTENDED:

          cmp ecx, typeEXTENDED
          jnz @@RetCURRENCY
          fstp tbyte ptr [ebx + 36]
          jmp @@Return
        //

          @@RetCURRENCY:

          cmp ecx, typeCURRENCY
          jnz @@RetINT64
          fistp qword ptr [ebx + 36]
          jmp @@Return
        //

          @@RetINT64:
          cmp ecx, typeINT64
          jnz @@Return
          mov [ebx + 36], eax
          mov [ebx + 40], edx

          @@Return:

        end;

      end;
    end;
  except
    on E: Exception do
    begin
      if fTryStack.Count > 0 then
      begin
        TryBlockNumber := fTryStack.Top.TryBlockNumber;
        SelfPtr := fTryStack.Top.Prog;
      end
      else
      begin
        SelfPtr := Self;
        TryBlockNumber := 0;
      end;
      with SelfPtr do
      begin
        D  := Data;
        P0 := Prog;
        SourceLine := GetSourceLine;
        ModuleName := GetModuleName;
      end;

      IsExitException := E is PaxExitException;
      IsPauseException := E is TPauseException;
      IsHaltException := (E is THaltException) or
                         ((E is EAbort) and (not IsPauseException) and (not IsExitException));

      IsHalted := IsHaltException;

      HasError := true;

      if E is THaltException then
        ExitCode := (E as THaltException).ExitCode;

      with SelfPtr do
      if (not IsPauseException) and (not IsHaltException) and
         (TryBlockNumber > 0) and (TryBlockNumber < TryList.Count) then
      begin
        TryRec := TryList[TryBlockNumber];
        _EBP := TryRec._EBP;
        _ESP := TryRec._ESP;

        K := TryRec.StackFrameSize div 4;
        StackFrame := TryRec.StackFrame;
        StackFrameSize := TryRec.StackFrameSize;

        if TryRec.TryKind = tryFinally then
        begin
          RootProcessingExceptBlock := false;
          if SourceLineFinally = -1 then
          begin
            SourceLineFinally := GetSourceLine;
            ModuleNameFinally := GetModuleName;
          end;
        end
        else
        begin
          RootProcessingExceptBlock := true;
          HandledByExcept := true;
        end;

        if TryRec.ExceptOnInfo.Count = 0 then
          ProgOffset := TryRec.ProgOffset
        else
        begin
          for I:=0 to TryRec.ExceptOnInfo.Count - 1 do
          begin
            ClsIndex := TryRec.ExceptOnInfo.Keys[I];
            ProgOffset := TryRec.ExceptOnInfo.Values[I];
            if ClsIndex >= 0 then
            begin
              if ScriptDefinedException <> nil then
              begin
                if ClsIndex = GetPaxInfo(ScriptDefinedException.ClassType)^.ClassIndex then
                begin
                  SetAddress(H_ExceptionPtr, @ ScriptDefinedException);
                  break;
                end;
              end;

              ClassRec := ClassList[ClsIndex];
              if ClassRec.PClass <> nil then
              begin
                if E is ClassRec.PClass then
                  break;

                if StrEql(ClassRec.PClass.ClassName, 'TJS_Object') then
                  break;
              end;
            end;
          end;
        end;

        Handled := true;
      end;

      if Assigned(fCurrException) then
      begin
        fCurrException.Free;
        fCurrException := nil;
      end;

      if (not IsPauseException) and (not IsHaltException) then
      begin
        Integer(CE) := Integer(E.ClassType);
        fCurrException := CE.Create(E.Message);

        if Assigned(OnCustomExceptionHelper) then
          OnCustomExceptionHelper(Owner, E, fCurrException);
      end;

    end; // on: E Exception
    else
    begin
      // custom exception
    end;
  end; // try

  RuntimeModuleList.TempBreakpoint.Clear;

  if Handled then
  begin
    if Assigned(OnException) and fExceptionIsAvailableForHostApplication then
    if HandledByExcept then
      OnException(Owner, fCurrException, ModuleName, SourceLine);

    fExceptionIsAvailableForHostApplication := true;
    goto Again;
  end
  else
  begin
    fIsRunning := false;

    fGC.ClearObjects;

    if HasError then
    begin
      if Assigned(OnHalt) and IsHaltException then
      begin
        OnHalt(Owner, ExitCode, ModuleName, SourceLine);
        fExceptionIsAvailableForHostApplication := true;
        fPauseRec.Clear;
        Exit;
      end
      else if Assigned(OnPause) and IsPauseException then
      begin
        OnPause(Owner, ModuleName, SourceLine);
        fExceptionIsAvailableForHostApplication := true;
        Exit;
      end;

      if Assigned(OnUnhandledException) and fExceptionIsAvailableForHostApplication then
      begin
        if SourceLineFinally = -1 then
          OnUnhandledException(Owner, fCurrException, ModuleName, SourceLine)
        else
          OnUnhandledException(Owner, fCurrException, ModuleNameFinally, SourceLineFinally);
      end;
      fExceptionIsAvailableForHostApplication := true;
    end;
  end;
end;

procedure TProgram.RunInitialization;
var
  P: Pointer;
begin
  if InitializationIsProcessed then
    Exit;

  ProgList.RunInitialization;

  P := ShiftPointer(Data, H_InitOnly);
  Integer(P^) := 2;
  try
    Run;
  finally
    Integer(P^) := 0;
    InitializationIsProcessed := true;
  end;
end;

procedure TProgram.RunExceptInitialization;
var
  P: Pointer;
  Offset: Integer;
begin
  Offset := GetInitializationOffset(CodePtr, CodeSize);
  if Offset = -1 then
    Exit;

  P := ShiftPointer(Data, H_BodyOnly);
  if SuspendFinalization then
    Integer(P^) := 3
  else
    Integer(P^) := 0;

  EPoint := nil;

  P := ShiftPointer(CodePtr, 1);
  Move(Offset, P^, 4);
  try
    Run;
  finally
    Integer(P^) := 0;
  end;
end;

procedure TProgram.RunFinalization;
var
  P: Pointer;
  Offset: Integer;
begin
  ProgList.RunFinalization;

  Offset := GetFinalizationOffset(CodePtr, CodeSize);
  if Offset = -1 then
    Exit;

  EPoint := nil;

  P := ShiftPointer(CodePtr, 1);
  Move(Offset, P^, 4);
  try
    Run;
  finally
    Integer(P^) := 0;
  end;
end;

procedure TProgram.SaveState(S: TStream);
begin
  S.Write(DataPtr^, DataSize);
  fCallStackID.SaveToStream(S);
  fCallStackEBP.SaveToStream(S);
  fCallStackNCall.SaveToStream(S);
  fTryStack.SaveToStream(S);
end;

procedure TProgram.LoadState(S: TStream);
begin
  S.Read(DataPtr^, DataSize);
  fCallStackID.LoadFromStream(S);
  fCallStackEBP.LoadFromStream(S);
  fCallStackNCall.LoadFromStream(S);
  fTryStack.LoadFromStream(S);
end;

procedure TProgram.PushPtrs; assembler;
asm
  mov ecx, [esp]
  push ecx
  push ecx

  mov edx, [eax + 4]
  mov [esp + 4], edx

  mov edx, [eax + 8]
  mov [esp + 8], edx
end;

function TProgram.GetProgramSize: Integer;
begin
  result := DataSize + CodeSize + 2;
end;

function TProgram.CreateScriptObject(const ScriptClassName: String): TObject;
var
  ClassIndex: Integer;
begin
  ClassIndex := ClassList.IndexOf(ScriptClassName);
  if ClassIndex = -1 then
    RaiseError(errClassNotFound, [ScriptClassName]);
  _CreateObject(ClassList[ClassIndex].PClass, result);
end;

procedure TProgram.DestroyScriptObject(var X: TObject);
begin
  X.Free;
end;

function TProgram.GetOffset(Shift: Integer): Integer;
begin
  if OffsetList.Count > 0 then
  begin

    if Shift <= 0 then
    begin
      result := Shift;
      Exit;
    end;

    result := OffsetList.GetOffset(Shift);
  end
  else
    result := Shift;
end;

procedure TProgram.CreateMapOffsets;
begin
  HostMapTable.CreateOffsets(OffsetList, true);
  ScriptMapTable.CreateOffsets(OffsetList, false);
end;

function TProgram.GetFieldAddress(X: TObject; const FieldName: String): Pointer;
var
  MapRec: TMapRec;
  MapFieldRec: TMapFieldRec;
begin
  if IsPaxObject(X) then
  begin
    MapRec := ScriptMapTable.LookupType(X.ClassName);
    if MapRec <> nil then
    begin
      if MapRec.FieldList = nil then
        RaiseError(errInternalError, []);
      MapFieldRec := MapRec.FieldList.Lookup(FieldName);
      if MapFieldRec = nil then
        result := nil
      else
        result := ShiftPointer(X, MapFieldRec.FieldOffset);
    end
    else
      result := X.FieldAddress(FieldName);
  end
  else
    result := X.FieldAddress(FieldName);
end;

procedure TProgram.DiscardDebugMode;
begin
  PAXCOMP_DISASM.DiscardDebugMode(CodePtr, CodeSize);
end;

procedure TProgram.RunEx;
var
  M: TMethod;
begin
  M := OwnerEventHandlerMethod;
  if Assigned(M.Code) then
  begin
    asm
      MOV  EAX,DWORD PTR M.Data;
      CALL M.Code;
    end;
  end
  else
    Run;
end;

procedure TProgram.SetupInterfaces;
begin
  ClassList.SetupInterfaces(Self);
end;

function TProgram.GetTypeInfo(const FullTypeName: String): PTypeInfo;
var
  R: TTypeInfoContainer;
begin
  R := ProgTypeInfoList.LookupFullName(FullTypeName);
  if R = nil then
    result := nil
  else
    result := R.TypeInfoPtr;
end;

procedure TProgram.LoadDFMFile(Instance: TObject; const FileName: String);
var
  fs: TFileStream;
  ms: TMemoryStream;
  Reader: TReader;
begin
  fs := TFileStream.Create(FileName, fmOpenRead);
  ms := TMemoryStream.Create;
  try
    Reader := nil;
    case TestStreamFormat(fs) of
      sofText:
      begin
        ObjectTextToBinary(fs, ms);
        ms.Position := 0;
        Reader := TReader.Create(ms, 4096 * 10);
      end;
      sofBinary:
      begin
        fs.ReadResHeader;
        Reader := TReader.Create(fs, 4096 * 10);
      end;
    else
      RaiseError(errUnknownStreamFormat, []);
    end;

    try
      Reader.ReadRootComponent(Instance as TComponent);
    finally
      Reader.Free;
    end;
  finally
    ms.Free;
    fs.Free;
  end;
  RebindEvents(Instance);
end;

procedure TProgram.LoadDFMStream(Instance: TObject; S: TStream);
var
  ms: TMemoryStream;
  Reader: TReader;
begin
  ms := TMemoryStream.Create;
  try
    Reader := nil;
    case TestStreamFormat(s) of
      sofText:
      begin
        ObjectTextToBinary(s, ms);
        ms.Position := 0;
        Reader := TReader.Create(ms, 4096 * 10);
      end;
      sofBinary:
      begin
        s.ReadResHeader;
        Reader := TReader.Create(s, 4096 * 10);
      end;
    else
      RaiseError(errUnknownStreamFormat, []);
    end;

    try
      Reader.ReadRootComponent(Instance as TComponent);
    finally
      Reader.Free;
    end;
  finally
    ms.Free;
  end;
  RebindEvents(Instance);
end;

procedure TProgram.RebindEvents(AnInstance: TObject);

  procedure _RebindEvents(Instance: TObject);
  var
    pti, PropType: PTypeInfo;
    ptd: PTypeData;
    Loop, nProps: Integer;
    pProps: PPropList;
    ppi: PPropInfo;
    M: TMethod;
    C: TComponent;
    I: Integer;
    aFullName: String;
    ER: TEventHandlerRec;
  begin
    pti := Instance.ClassInfo;
    if pti = nil then Exit;
    ptd := GetTypeData(pti);
    nProps := ptd^.PropCount;
    if nProps > 0 then
    begin
      GetMem(pProps, SizeOf(PPropInfo) * nProps);
      GetPropInfos(pti, pProps);

      for Loop:=0 to nProps - 1 do
      begin
    {$ifdef fpc}
        ppi := pProps^[Loop];
        PropType := PPropInfo(ppi)^.PropType;
    {$else}
        ppi := pProps[Loop];
        PropType := PPropInfo(ppi)^.PropType^;
    {$endif}
        if PropType^.Kind = tkMethod then
        begin
          M := GetMethodProp(Instance, ppi);
          if Assigned(M.Code) and Assigned(M.Data) then
          begin
            aFullName := ProgTypeInfoList.FindMethodFullName(M.Code);

            if AFullName = '' then
              continue;

            ER := EventHandlerList.Add(Self,
                  M.Code,
                  M.Data,
                  GetCallConv(aFullName),
                  GetRetSize(aFullName));

            M.Code := @ TEventHandlerRec.Invoke;
            M.Data := ER;

            SetMethodProp(Instance, ppi, M);
          end;
        end;
      end;
      FreeMem(pProps, SizeOf(PPropInfo) * nProps);
    end;

    if Instance is TComponent then
    begin
      C := TComponent(Instance);
      for I := 0 to C.ComponentCount - 1 do
        _RebindEvents(C.Components[I]);
    end;
  end;
begin
  _RebindEvents(AnInstance);
end;

procedure ZZZ;
asm
  pop esi;
  jmp esi;
end;

function TProgram.CallFunc(const FullName: String;
                     This: Pointer;
                     const ParamList: array of OleVariant): OleVariant;
const
  MaxParam = 30;
var
  Invoke, OldEPoint: TInvoke;
  Address: Pointer;
  MR: TMapRec;
  OldESP0, I, NP, T: Integer;
  Value: OleVariant;
  AnsiStrings: array [1..MaxParam] of AnsiString;
  UnicStrings: array [1..MaxParam] of UnicString;
  ShortStrings: array [1..MaxParam] of ShortString;
  WideStrings: array [1..MaxParam] of WideString;
  valueDouble: Double;
  valueSingle: Single;
  valueExtended: Extended;
  valueCurrency: Currency;
begin
  Address := GetAddress(FullName, MR);
  if Address = nil then
    RaiseError(errRoutineNotFound, [FullName]);

  NP := MR.SubDesc.ParamList.Count;
  if NP > Length(ParamList) then
    RaiseError(errNotEnoughActualParameters, [])
  else if NP < Length(ParamList) then
    RaiseError(errTooManyActualParameters, []);

  Invoke := TInvoke.Create;
  Invoke.CallConv := MR.SubDesc.CallConv;
  Invoke.SetResType(MR.SubDesc.ResTypeId);
  Invoke.SetResSize(MR.SubDesc.RetSize);

  Invoke.Address := Address;
  Invoke.SetThis(This);

  for I := 0 to NP - 1 do
  begin
    T := MR.SubDesc.ParamList[I].FinTypeId;
    value := ParamList[I];
    case T of
      typeVOID: Invoke.AddArg(value, typeINTEGER);
      typeBOOLEAN: Invoke.AddArg(value, typeINTEGER);
      typeBYTE: Invoke.AddArg(value, typeINTEGER);
      typeANSICHAR: Invoke.AddArg(value, typeINTEGER);
      typeANSISTRING:
      begin
        AnsiStrings[I] := AnsiString(value);
        Invoke.AddArg(Integer(AnsiStrings[I]), typeINTEGER);
      end;
      typeWORD: Invoke.AddArg(value, typeINTEGER);
      typeINTEGER: Invoke.AddArg(value, typeINTEGER);
      typeDOUBLE:
      begin
        valueDouble := value;
        Invoke.AddArgByVal(valueDouble, SizeOf(Double));
      end;
      typePOINTER: Invoke.AddArg(Integer(value), typeINTEGER);
      typeRECORD: Invoke.AddArg(Integer(value), typeINTEGER);
      typeARRAY: Invoke.AddArg(Integer(value), typeINTEGER);
      typeALIAS: Invoke.AddArg(Integer(value), typeINTEGER);
      typeENUM: Invoke.AddArg(Integer(value), typeINTEGER);
      typePROC: Invoke.AddArg(Integer(value), typeINTEGER);
      typeSET: Invoke.AddArg(Integer(value), typeINTEGER);
      typeSHORTSTRING:
      begin
        ShortStrings[I] := ShortString(value);
        Invoke.AddArg(Integer(@ShortStrings[I]), typeINTEGER);
      end;
      typeSINGLE:
      begin
        valueSingle := value;
        Invoke.AddArgByVal(valueSingle, SizeOf(Single));
      end;
      typeEXTENDED:
      begin
        valueExtended := value;
        Invoke.AddArgByVal(valueExtended, SizeOf(Extended));
      end;
      typeCLASS: Invoke.AddArg(Integer(value), typeINTEGER);
      typeCLASSREF: Invoke.AddArg(Integer(value), typeINTEGER);
      typeWIDECHAR: Invoke.AddArg(Integer(value), typeINTEGER);
      typeWIDESTRING:
      begin
        WideStrings[I] := value;
        Invoke.AddArg(Integer(WideStrings[I]), typeINTEGER);
      end;
      typeVARIANT:
      begin
        if MR.SubDesc.ParamList[I].ParamMod = PM_BYVAL then
          Invoke.AddArg(value, typeVARIANT)
        else
          Invoke.AddArg(Integer(@ParamList[I]), typeINTEGER);
      end;
      typeDYNARRAY: Invoke.AddArg(Integer(value), typeINTEGER);
      typeINT64: Invoke.AddArgByVal(value, SizeOf(Int64));
      typeINTERFACE: Invoke.AddArg(Integer(value), typeINTEGER);
      typeCARDINAL: Invoke.AddArg(Integer(value), typeINTEGER);
      typeEVENT: Invoke.AddArg(Integer(value), typeINTEGER);
      typeCURRENCY:
      begin
        valueCurrency := value;
        Invoke.AddArgByVal(valueCurrency, SizeOf(Single));
      end;
      typeSMALLINT: Invoke.AddArg(Integer(value), typeINTEGER);
      typeSHORTINT: Invoke.AddArg(Integer(value), typeINTEGER);
      typeWORDBOOL: Invoke.AddArg(Integer(value), typeINTEGER);
      typeLONGBOOL: Invoke.AddArg(Integer(value), typeINTEGER);
      typeBYTEBOOL: Invoke.AddArg(Integer(value), typeINTEGER);
      typeOLEVARIANT: Invoke.AddArg(value, typeVARIANT);
      typeUNICSTRING:
      begin
        UnicStrings[I] := value;
        Invoke.AddArg(Integer(UnicStrings[I]), typeINTEGER);
      end;
    end;
  end;

  OldEPoint := EPoint;
  OldESP0 := fESP0;

  try
    Invoke.SetUp;
    EPoint := Invoke;
    Run;

  finally

    Address := EPoint.GetResultPtr;

    fESP0 := OldESP0;
    EPoint := OldEPoint;
    Invoke.Free;
  end;

  case MR.SubDesc.ResTypeId of
    typeVOID: result := Unassigned;
    typeBOOLEAN: result := Boolean(Address^);
    typeBYTE: result := Byte(Address^);
    typeANSICHAR: result := AnsiChar(Address^);
    typeANSISTRING: result := AnsiString(Address^);
    typeWORD: result := Word(Address^);
    typeINTEGER: result := Integer(Address^);
    typeDOUBLE: result := Double(Address^);
    typePOINTER: result := Integer(Address^);
    typeRECORD: result := Integer(Address);
    typeARRAY: result := Integer(Address);
    typeALIAS: result := Unassigned;
    typeENUM: result := Byte(Address^);
    typePROC: result := Integer(Address^);
    typeSET: result := Integer(Address^);
    typeSHORTSTRING: result := ShortString(Address^);
    typeSINGLE: result := Single(Address^);
    typeEXTENDED: result := Extended(Address^);
    typeCLASS: result := Integer(Address^);
    typeCLASSREF: result := Integer(Address^);
    typeWIDECHAR: result := WideChar(Address^);
    typeWIDESTRING: result := WideString(Address^);
    typeVARIANT: result := Variant(Address^);
    typeDYNARRAY: result := Integer(Address^);
    typeINT64: result := Integer(Address^);
    typeINTERFACE: result := Integer(Address^);
{$IFDEF VARIANTS}
    typeCARDINAL: result := Cardinal(Address^);
{$ELSE}
    typeCARDINAL: result := Integer(Address^);
{$ENDIF}
    typeEVENT: result := Unassigned;
    typeCURRENCY: result := Currency(Address^);
    typeSMALLINT: result := SmallInt(Address^);
    typeSHORTINT: result := ShortInt(Address^);
    typeWORDBOOL: result := WordBool(Address^);
    typeLONGBOOL: result := LongBool(Address^);
    typeBYTEBOOL: result := ByteBool(Address^);
    typeOLEVARIANT: result := OleVariant(Address^);
    typeUNICSTRING: result := UnicString(Address^);
  else
    result := Integer(Address^);
  end;

  if IsHalted then
    raise THaltException.Create(ExitCode);
end;

function TProgram.CallFuncEx(const FullName: String;
                             This: Pointer;
                             const ParamList: array of const): Variant;
const
  MaxParam = 30;
var
  Invoke, OldEPoint: TInvoke;
  Address: Pointer;
  MR: TMapRec;
  OldESP0, I, NP, T: Integer;
  AnsiStrings: array [1..MaxParam] of AnsiString;
  UnicStrings: array [1..MaxParam] of UnicString;
  ShortStrings: array [1..MaxParam] of ShortString;
  WideStrings: array [1..MaxParam] of WideString;
  valueDouble: Double;
  valueSingle: Single;
  valueExtended: Extended;
  valueCurrency: Currency;
begin
  Address := GetAddress(FullName, MR);
  if Address = nil then
    RaiseError(errRoutineNotFound, [FullName]);

  NP := MR.SubDesc.ParamList.Count;
  if NP > Length(ParamList) then
    RaiseError(errNotEnoughActualParameters, [])
  else if NP < Length(ParamList) then
    RaiseError(errTooManyActualParameters, []);

  Invoke := TInvoke.Create;
  Invoke.CallConv := MR.SubDesc.CallConv;
  Invoke.SetResType(MR.SubDesc.ResTypeId);
  Invoke.SetResSize(MR.SubDesc.RetSize);

  Invoke.Address := Address;
  Invoke.SetThis(This);

  for I := 0 to NP - 1 do
  begin
    T := MR.SubDesc.ParamList[I].FinTypeId;
    case T of
      typeVOID: Invoke.AddArg(ParamList[I].VInteger, typeINTEGER);
      typeBOOLEAN: Invoke.AddArg(ParamList[I].VBoolean, typeINTEGER);
      typeBYTE: Invoke.AddArg(ParamList[I].VInteger, typeINTEGER);
      typeANSICHAR: Invoke.AddArg(ParamList[I].VChar, typeINTEGER);
      typeANSISTRING:
      begin
        case ParamList[I].VType of
          vtString: AnsiStrings[I] :=
            PShortString(ParamList[I].VString)^;
          vtAnsiString: AnsiStrings[I] :=
            PAnsiString(ParamList[I].VAnsiString)^;
          vtWideString: AnsiStrings[I] :=
            AnsiString(PWideString(ParamList[I].VWideString)^);
         {$IFDEF UNIC}
          vtUnicodeString: AnsiStrings[I] :=
            AnsiString(PUnicodeString(ParamList[I].VUnicodeString)^);
         {$ENDIF}
          vtVariant: AnsiStrings[I] :=
            AnsiString(PVariant(ParamList[I].VVariant)^);
          vtChar: AnsiStrings[I] :=
            ParamList[I].VChar;
          vtWideChar: AnsiStrings[I] :=
            AnsiChar(ParamList[I].VWideChar);
        end;
        Invoke.AddArg(Integer(AnsiStrings[I]), typeINTEGER);
      end;
      typeWORD: Invoke.AddArg(ParamList[I].VInteger, typeINTEGER);
      typeINTEGER: Invoke.AddArg(ParamList[I].VInteger, typeINTEGER);
      typeDOUBLE:
      begin
        valueDouble := ParamList[I].VExtended^;
        Invoke.AddArgByVal(valueDouble, SizeOf(Double));
      end;
      typePOINTER: Invoke.AddArg(Integer(ParamList[I].VPointer), typeINTEGER);
      typeRECORD: Invoke.AddArg(Integer(ParamList[I].VPointer), typeINTEGER);
      typeARRAY: Invoke.AddArg(Integer(ParamList[I].VPointer), typeINTEGER);
      typeALIAS: Invoke.AddArg(ParamList[I].VInteger, typeINTEGER);
      typeENUM: Invoke.AddArg(ParamList[I].VInteger, typeINTEGER);
      typePROC: Invoke.AddArg(Integer(ParamList[I].VPointer), typeINTEGER);
      typeSET: Invoke.AddArg(ParamList[I].VInteger, typeINTEGER);
      typeSHORTSTRING:
      begin
        case ParamList[I].VType of
          vtString: ShortStrings[I] :=
            PShortString(ParamList[I].VString)^;
          vtAnsiString: ShortStrings[I] :=
            PAnsiString(ParamList[I].VAnsiString)^;
          vtWideString: ShortStrings[I] :=
            ShortString(PWideString(ParamList[I].VWideString)^);
         {$IFDEF UNIC}
          vtUnicodeString: ShortStrings[I] :=
            AnsiString(PUnicodeString(ParamList[I].VUnicodeString)^);
         {$ENDIF}
          vtVariant: ShortStrings[I] :=
            ShortString(PVariant(ParamList[I].VVariant)^);
          vtChar: ShortStrings[I] :=
            ParamList[I].VChar;
          vtWideChar: ShortStrings[I] :=
            AnsiChar(ParamList[I].VWideChar);
        end;
        Invoke.AddArg(Integer(@ShortStrings[I]), typeINTEGER);
      end;
      typeSINGLE:
      begin
        valueSingle := ParamList[I].VExtended^;
        Invoke.AddArgByVal(valueSingle, SizeOf(Single));
      end;
      typeEXTENDED:
      begin
        valueExtended := ParamList[I].VExtended^;
        Invoke.AddArgByVal(valueExtended, SizeOf(Extended));
      end;
      typeCLASS: Invoke.AddArg(Integer(ParamList[I].VObject), typeINTEGER);
      typeCLASSREF: Invoke.AddArg(Integer(ParamList[I].VPointer), typeINTEGER);
      typeWIDECHAR: Invoke.AddArg(Integer(ParamList[I].VWideChar), typeINTEGER);
      typeWIDESTRING:
      begin
        case ParamList[I].VType of
          vtString: WideStrings[I] :=
            WideString(PShortString(ParamList[I].VString)^);
          vtAnsiString: WideStrings[I] :=
            WideString(PAnsiString(ParamList[I].VAnsiString)^);
          vtWideString: WideStrings[I] :=
            PWideString(ParamList[I].VWideString)^;
         {$IFDEF UNIC}
          vtUnicodeString: WideStrings[I] :=
            PUnicodeString(ParamList[I].VUnicodeString)^;
         {$ENDIF}
          vtVariant: WideStrings[I] :=
            PVariant(ParamList[I].VVariant)^;
          vtChar: WideStrings[I] :=
            WideChar(ParamList[I].VChar);
          vtWideChar: WideStrings[I] :=
            ParamList[I].VWideChar;
        end;
        Invoke.AddArg(Integer(WideStrings[I]), typeINTEGER);
      end;
      typeVARIANT:
      begin
        if MR.SubDesc.ParamList[I].ParamMod = PM_BYVAL then
          Invoke.AddArg(ParamList[I].VVariant^, typeVARIANT)
        else
          Invoke.AddArg(Integer(ParamList[I].VVariant), typeINTEGER);
      end;
      typeDYNARRAY: Invoke.AddArg(Integer(ParamList[I].VPointer), typeINTEGER);
      typeINT64: Invoke.AddArgByVal(ParamList[I].VInt64^, SizeOf(Int64));
      typeINTERFACE: Invoke.AddArg(Integer(ParamList[I].VInterface), typeINTEGER);
      typeCARDINAL: Invoke.AddArg(ParamList[I].VInteger, typeINTEGER);
      typeEVENT: Invoke.AddArg(ParamList[I].VInteger, typeINTEGER);
      typeCURRENCY:
      begin
        valueCurrency := ParamList[I].VExtended^;
        Invoke.AddArgByVal(valueCurrency, SizeOf(Single));
      end;
      typeSMALLINT: Invoke.AddArg(ParamList[I].VInteger, typeINTEGER);
      typeSHORTINT: Invoke.AddArg(ParamList[I].VInteger, typeINTEGER);
      typeWORDBOOL: Invoke.AddArg(ParamList[I].VInteger, typeINTEGER);
      typeLONGBOOL: Invoke.AddArg(ParamList[I].VInteger, typeINTEGER);
      typeBYTEBOOL: Invoke.AddArg(ParamList[I].VInteger, typeINTEGER);
      typeOLEVARIANT:
      begin
        if MR.SubDesc.ParamList[I].ParamMod = PM_BYVAL then
          Invoke.AddArg(ParamList[I].VVariant^, typeVARIANT)
        else
          Invoke.AddArg(Integer(ParamList[I].VVariant), typeINTEGER);
      end;
      typeUNICSTRING:
      begin
        case ParamList[I].VType of
          vtString: UnicStrings[I] :=
            UnicString(PShortString(ParamList[I].VString)^);
          vtAnsiString: UnicStrings[I] :=
            UnicString(PAnsiString(ParamList[I].VAnsiString)^);
          vtWideString: UnicStrings[I] :=
            PWideString(ParamList[I].VWideString)^;
         {$IFDEF UNIC}
          vtUnicodeString: UnicStrings[I] :=
            PUnicodeString(ParamList[I].VUnicodeString)^;
         {$ENDIF}
          vtVariant: UnicStrings[I] :=
            PVariant(ParamList[I].VVariant)^;
          vtChar: UnicStrings[I] :=
            WideChar(ParamList[I].VChar);
          vtWideChar: UnicStrings[I] :=
            ParamList[I].VWideChar;
        end;
        Invoke.AddArg(Integer(UnicStrings[I]), typeINTEGER);
      end;
    end;
  end;

  OldEPoint := EPoint;
  OldESP0 := fESP0;

  try
    Invoke.SetUp;
    EPoint := Invoke;
    Run;

  finally

    Address := EPoint.GetResultPtr;

    fESP0 := OldESP0;
    EPoint := OldEPoint;
    Invoke.Free;
  end;

  case MR.SubDesc.ResTypeId of
    typeVOID: result := Unassigned;
    typeBOOLEAN: result := Boolean(Address^);
    typeBYTE: result := Byte(Address^);
    typeANSICHAR: result := AnsiChar(Address^);
    typeANSISTRING: result := AnsiString(Address^);
    typeWORD: result := Word(Address^);
    typeINTEGER: result := Integer(Address^);
    typeDOUBLE: result := Double(Address^);
    typePOINTER: result := Integer(Address^);
    typeRECORD: result := Integer(Address);
    typeARRAY: result := Integer(Address);
    typeALIAS: result := Unassigned;
    typeENUM: result := Byte(Address^);
    typePROC: result := Integer(Address^);
    typeSET: result := Integer(Address^);
    typeSHORTSTRING: result := ShortString(Address^);
    typeSINGLE: result := Single(Address^);
    typeEXTENDED: result := Extended(Address^);
    typeCLASS: result := Integer(Address^);
    typeCLASSREF: result := Integer(Address^);
    typeWIDECHAR: result := WideChar(Address^);
    typeWIDESTRING: result := WideString(Address^);
    typeVARIANT: result := Variant(Address^);
    typeDYNARRAY: result := Integer(Address^);
    typeINT64: result := Integer(Address^);
    typeINTERFACE: result := Integer(Address^);
{$IFDEF VARIANTS}
    typeCARDINAL: result := Cardinal(Address^);
{$ELSE}
    typeCARDINAL: result := Integer(Address^);
{$ENDIF}
    typeEVENT: result := Unassigned;
    typeCURRENCY: result := Currency(Address^);
    typeSMALLINT: result := SmallInt(Address^);
    typeSHORTINT: result := ShortInt(Address^);
    typeWORDBOOL: result := WordBool(Address^);
    typeLONGBOOL: result := LongBool(Address^);
    typeBYTEBOOL: result := ByteBool(Address^);
    typeOLEVARIANT: result := OleVariant(Address^);
    typeUNICSTRING: result := UnicString(Address^);
  else
    result := Integer(Address^);
  end;

  if IsHalted then
    raise THaltException.Create(ExitCode);
end;

function TProgram.FileExists(const FileName: String; out FullPath: String): Boolean;
begin
  if SysUtils.FileExists(FileName) then
  begin
    result := true;
    FullPath := FileName;
  end
  else
  begin
    result := false;
    FullPath := FileName;
  end;
end;

function TProgram.GetRootProg: TProgram;
begin
  result := Self;
  while result.PCUOwner <> nil do
    result := result.PCUOwner;
end;

function TProgram.GetIsRootProg: Boolean;
begin
  result := PCUOwner = nil;
end;

function TProgram.GetTryStack: TTryStack;
begin
  result := RootProg.fTryStack;
end;

function TProgram.GetCallStackID: TIntegerStack;
begin
  result := RootProg.fCallStackID;
end;

function TProgram.GetCallStackEBP: TIntegerStack;
begin
  result := RootProg.fCallStackEBP;
end;

function TProgram.GetCallStackNCall: TIntegerStack;
begin
  result := RootProg.fCallStackNCall;
end;

function TProgram.GetInitCallStackCount: Integer;
begin
  result := RootProg.fInitCallStackCount;
end;

procedure TProgram.SetInitCallStackCount(value: Integer);
begin
  RootProg.fInitCallStackCount := value;
end;

function TProgram.GetESP0: Integer;
begin
  result := RootProg.fESP0;
end;

procedure TProgram.SetESP0(value: Integer);
begin
  RootProg.fESP0 := value;
end;

function TProgram.GetCurrException: Exception;
begin
  result := RootProg.fCurrException;
end;

procedure TProgram.SetCurrException(value: Exception);
begin
  RootProg.fCurrException := value;
end;

function TProgram.GetProcessingExceptBlock: Boolean;
begin
  result := RootProg.fProcessingExceptBlock;
end;

procedure TProgram.SetProcessingExceptBlock(value: Boolean);
begin
  RootProg.fProcessingExceptBlock := value;
end;

function TProgram.GetExceptionIsAvailableForHostApplication: Boolean;
begin
  result := RootProg.fExceptionIsAvailableForHostApplication;
end;

procedure TProgram.SetExceptionIsAvailableForHostApplication(value: Boolean);
begin
  RootProg.fExceptionIsAvailableForHostApplication := value;
end;

function TProgram.GetIsEvent: Boolean;
begin
  result := RootProg.fIsEvent;
end;

procedure TProgram.SetIsEvent(value: Boolean);
begin
  RootProg.fIsEvent := value;
end;

procedure TProgram.CopyRootEvents;
var
  RP: TProgram;
begin
  RP := RootProg;
  if Self <> RP then
  begin
    Owner := RP.Owner;

    OnException := RP.OnException;
    OnUnhandledException := RP.OnUnhandledException;
    OnPause := RP.OnPause;
    OnPauseUpdated := RP.OnPauseUpdated;
    OnHalt := RP.OnHalt;
    OnLoadProc := RP.OnLoadProc;
    OnCreateObject := RP.OnCreateObject;
    OnAfterObjectCreation := RP.OnAfterObjectCreation;
    OnDestroyObject := RP.OnDestroyObject;
    OnAfterObjectDestruction := RP.OnAfterObjectDestruction;

    OnMapTableNamespace := RP.OnMapTableNamespace;
    OnMapTableVarAddress := RP.OnMapTableVarAddress;
    OnMapTableProcAddress := RP.OnMapTableProcAddress;
    OnMapTableClassRef := RP.OnMapTableClassRef;
    OnLoadPCU := RP.OnLoadPCU;

    OnPrint := RP.OnPrint;
    OnCustomExceptionHelper := RP.OnCustomExceptionHelper;
  end;
end;

function TProgram.GetRootGC: TGC;
begin
  result := RootProg.fGC;
end;

end.
