////////////////////////////////////////////////////////////////////////////
// PaxCompiler
// Site: http://www.paxcompiler.com
// Author: Alexander Baranovsky (paxscript@gmail.com)
// ========================================================================
// Copyright (c) Alexander Baranovsky, 2006-2008. All rights reserved.
// Code Version: 2.4
// ========================================================================
// Unit: PaxCompilerDebugger.pas
// ========================================================================
////////////////////////////////////////////////////////////////////////////

{$I PaxCompiler.def}
unit PaxCompilerDebugger;
interface
uses
{$IFDEF VARIANTS}
  Variants,
{$ENDIF}
  TypInfo,
  SysUtils,
  Classes,
  PAXCOMP_CONSTANTS,
  PAXCOMP_SYS,
  PAXCOMP_KERNEL,
  PAXCOMP_MAP,
  PaxProgram,
  PaxCompiler;
type
  TPaxCompilerDebugger = class(TComponent)
  private
    compiler: TPaxCompiler;
    prog: TPaxProgram;

    function GetRunMode: Integer;
    procedure SetRunMode(Value: Integer);

    function GetValid: Boolean;
    function GetCallStackCount: Integer;
    function GetCallStackItem(I: Integer): Integer;
    function GetCallStackLineNumber(I: Integer): Integer;
    function GetCallStackModuleName(I: Integer): String;
    function GetCallStackModuleIndex(I: Integer): Integer;

    function GetSourceLineNumber: Integer;
    function GetModuleName: String;

  protected
  public

    constructor Create(AOwner: TComponent); override;
    destructor Destroy; override;
    procedure RegisterCompiler(i_compiler: TPaxCompiler;
                               i_prog: TPaxProgram);
    procedure Run;
    function IsPaused: Boolean;

    function GetAddress(StackFrameNumber, Id: Integer): Pointer; overload;
    function GetAddress(Id: Integer): Pointer; overload;

    function GetValueAsString(StackFrameNumber, Id: Integer): String; overload;
    function GetValueAsString(Id: Integer): String; overload;

    function GetValue(StackFrameNumber, Id: Integer): Variant; overload;
    function GetValue(Id: Integer): Variant; overload;

    procedure PutValue(StackFrameNumber, Id: Integer; const Value: Variant); overload;
    procedure PutValue(Id: Integer; const Value: Variant); overload;

    function GetFieldValueAsString(StackFrameNumber: Integer;
                              Id, FieldNumber: Integer): String;
    function GetPublishedPropValueAsString(StackFrameNumber: Integer;
                                           Id, PropNumber: Integer): String;

    function GetArrayItemValueAsString(StackFrameNumber: Integer;
                                 Id, Index: Integer): String;
    function GetDynArrayLength(StackFrameNumber, Id: Integer): Integer;
    function GetDynArrayItemValueAsString(StackFrameNumber: Integer;
                                 Id, Index: Integer): String;
    procedure AddBreakpoint(const ModuleName: String;
                            SourceLine: Integer);
    procedure AddTempBreakpoint(const ModuleName: String;
                                SourceLine: Integer);
    procedure RemoveBreakpoint(const ModuleName: String;
                               SourceLine: Integer);
    procedure RemoveAllBreakpoints;
    function HasBreakpoint(const ModuleName: String;
                          SourceLine: Integer): Boolean;
    procedure Reset;

    property CallStackCount: Integer read GetCallStackCount;
    property CallStack[I: Integer]: Integer read GetCallStackItem;
    property CallStackLineNumber[I: Integer]: Integer read
                  GetCallStackLineNumber;
    property CallStackModuleName[I: Integer]: String read
                  GetCallStackModuleName;
    property CallStackModuleIndex[I: Integer]: Integer read
                  GetCallStackModuleIndex;
    property ModuleName: String read GetModuleName;
    property RunMode: Integer read GetRunMode write SetRunMode;
    property SourceLineNumber: Integer read GetSourceLineNumber;
    property Valid: Boolean read GetValid;
  end;

implementation

/////////////// TPaxCompilerDebugger ///////////////////////////////////////////

procedure RaiseError(const Message: string; params: array of Const);
begin
  raise Exception.Create(Format(Message, params))
end;

constructor TPaxCompilerDebugger.Create(AOwner: TComponent);
begin
  inherited;
  compiler := nil;
  prog := nil;
end;

destructor TPaxCompilerDebugger.Destroy;
begin
  inherited;
end;

procedure TPaxCompilerDebugger.RegisterCompiler(i_compiler: TPaxCompiler;
                                                i_prog: TPaxProgram);
begin
  if not i_compiler.DebugMode then
    RaiseError(errDebugModeIsRequred, []);

  compiler := i_compiler;
  prog := i_prog;
end;

procedure TPaxCompilerDebugger.Run;
begin
  prog.Run;
end;

function TPaxCompilerDebugger.IsPaused: Boolean;
begin
  result := prog.IsPaused;
end;

function TPaxCompilerDebugger.GetAddress(StackFrameNumber, Id: Integer): Pointer;
begin
  result := TKernel(compiler.GetKernelPtr).SymbolTable.GetFinalAddress(
    prog.GetProgPtr, StackFrameNumber, Id);
end;

function TPaxCompilerDebugger.GetAddress(Id: Integer): Pointer;
begin
  result := TKernel(compiler.GetKernelPtr).SymbolTable.GetFinalAddress(
    prog.GetProgPtr, 0, Id);
end;

function TPaxCompilerDebugger.GetValue(StackFrameNumber, Id: Integer): Variant;
begin
  result := TKernel(compiler.GetKernelPtr).SymbolTable.GetValue(
    prog.GetProgPtr, StackFrameNumber, Id);
end;

function TPaxCompilerDebugger.GetValue(Id: Integer): Variant;
begin
  result := TKernel(compiler.GetKernelPtr).SymbolTable.GetValue(
    prog.GetProgPtr, 0, Id);
end;

function TPaxCompilerDebugger.GetValueAsString(StackFrameNumber, Id: Integer): String;
var
  TypeMapRec: TTypeMapRec;
begin
  TypeMapRec := TKernel(compiler.GetKernelPtr).GetTypeMapRec(Id);

  result := TKernel(compiler.GetKernelPtr).SymbolTable.GetValueAsString(
    prog.GetProgPtr, StackFrameNumber, Id, TypeMapRec);
end;

function TPaxCompilerDebugger.GetValueAsString(Id: Integer): String;
var
  TypeMapRec: TTypeMapRec;
begin
  TypeMapRec := TKernel(compiler.GetKernelPtr).GetTypeMapRec(Id);
  result := TKernel(compiler.GetKernelPtr).SymbolTable.GetValueAsString(
    prog.GetProgPtr, 0, Id, TypeMapRec);
end;

procedure TPaxCompilerDebugger.PutValue(StackFrameNumber, Id: Integer; const Value: Variant);
begin
  TKernel(compiler.GetKernelPtr).SymbolTable.PutValue(
    prog.GetProgPtr, StackFrameNumber, Id, Value);
end;

procedure TPaxCompilerDebugger.PutValue(Id: Integer; const Value: Variant);
begin
  TKernel(compiler.GetKernelPtr).SymbolTable.PutValue(
    prog.GetProgPtr, 0, Id, Value);
end;

function TPaxCompilerDebugger.GetFieldValueAsString(StackFrameNumber: Integer;
                                               Id, FieldNumber: Integer): String;
var
  TypeMapRec: TTypeMapRec;
begin
  TypeMapRec := TKernel(compiler.GetKernelPtr).GetTypeMapRec(Id);

  result := TKernel(compiler.GetKernelPtr).SymbolTable.GetFieldValueAsString(
     prog.GetProgPtr, StackFrameNumber, Id, FieldNumber, TypeMapRec);
end;

function TPaxCompilerDebugger.GetPublishedPropValueAsString(StackFrameNumber: Integer;
                                               Id, PropNumber: Integer): String;
begin
  result := TKernel(compiler.GetKernelPtr).SymbolTable.GetPublishedPropValueAsString(
     prog.GetProgPtr, StackFrameNumber, Id, PropNumber);
end;

function TPaxCompilerDebugger.GetDynArrayLength(StackFrameNumber,
                                                Id: Integer): Integer;
var
  Address, P: Pointer;
begin
  Address := TKernel(compiler.GetKernelPtr).SymbolTable.GetFinalAddress(
   prog.GetProgPtr, StackFrameNumber, Id);
        Address := Pointer(Address^);

  if Address = nil then
  begin
    result := -1;
    Exit;
  end;

  P := ShiftPointer(Address, - SizeOf(Integer));
  result := Integer(P^);
end;

function TPaxCompilerDebugger.GetArrayItemValueAsString(StackFrameNumber: Integer;
                                                   Id, Index: Integer): String;
begin
  result := TKernel(compiler.GetKernelPtr).SymbolTable.GetArrayItemValueAsString(
     prog.GetProgPtr, StackFrameNumber, Id, Index);
end;

function TPaxCompilerDebugger.GetDynArrayItemValueAsString(StackFrameNumber: Integer;
                                 Id, Index: Integer): String;
begin
  result := TKernel(compiler.GetKernelPtr).SymbolTable.GetDynArrayItemValueAsString(
     prog.GetProgPtr, StackFrameNumber, Id, Index);
end;

procedure TPaxCompilerDebugger.AddBreakpoint(const ModuleName: String;
                                    SourceLine: Integer);
begin
  prog.GetProgPtr.RunTimeModuleList.AddBreakpoint(ModuleName, SourceLine);
end;

procedure TPaxCompilerDebugger.AddTempBreakpoint(const ModuleName: String;
                                        SourceLine: Integer);
begin
  prog.GetProgPtr.RunTimeModuleList.AddTempBreakpoint(ModuleName, SourceLine);
end;

procedure TPaxCompilerDebugger.RemoveBreakpoint(const ModuleName: String;
                                       SourceLine: Integer);
begin
  prog.GetProgPtr.RunTimeModuleList.RemoveBreakpoint(ModuleName, SourceLine);
end;

procedure TPaxCompilerDebugger.RemoveAllBreakpoints;
begin
  prog.GetProgPtr.RunTimeModuleList.RemoveAllBreakpoints;
end;

function TPaxCompilerDebugger.HasBreakpoint(const ModuleName: String;
                                   SourceLine: Integer): Boolean;
begin
  result := prog.GetProgPtr.RunTimeModuleList.HasBreakpoint(ModuleName, SourceLine);
end;

function TPaxCompilerDebugger.GetSourceLineNumber: Integer;
begin
  result := prog.GetProgPtr.GetSourceLine;
end;

function TPaxCompilerDebugger.GetModuleName: String;
begin
  result := prog.GetProgPtr.GetModuleName;
end;

function TPaxCompilerDebugger.GetRunMode: Integer;
begin
  result := prog.GetProgPtr.RunMode;
end;

procedure TPaxCompilerDebugger.SetRunMode(Value: Integer);
begin
  prog.GetProgPtr.RunMode := Value;
end;

function TPaxCompilerDebugger.GetValid: Boolean;
begin
  if prog = nil then
    result := false
  else
    result := prog.GetProgPtr.Valid;
end;

function TPaxCompilerDebugger.GetCallStackCount: Integer;
begin
  result := prog.GetProgPtr.RootCallStackId.Count;
end;

function TPaxCompilerDebugger.GetCallStackItem(I: Integer): Integer;
begin
  if (I >= 0) and (I < GetCallStackCount) then
    result := prog.GetProgPtr.RootCallStackId[I]
  else
    result := 0;
end;

function TPaxCompilerDebugger.GetCallStackLineNumber(I: Integer): Integer;
var
  N: Integer;
begin
  if (I >= 0) and (I < GetCallStackCount) then
  begin
    N := prog.GetProgPtr.RootCallStackNCall[I];
    result := prog.GetProgPtr.RunTimeModuleList.GetSourceLine(N);
  end
  else
    result := 0;
end;

function TPaxCompilerDebugger.GetCallStackModuleName(I: Integer): String;
var
  N: Integer;
begin
  result := '';
  if (I >= 0) and (I < GetCallStackCount) then
  begin
    N := prog.GetProgPtr.RootCallStackNCall[I];
    if N = - 1 then
      Exit;
    result := prog.GetProgPtr.RunTimeModuleList.GetModuleName(N);
  end;
end;

function TPaxCompilerDebugger.GetCallStackModuleIndex(I: Integer): Integer;
var
  N: Integer;
begin
  result := -1;
  if (I >= 0) and (I < GetCallStackCount) then
  begin
    N := prog.GetProgPtr.RootCallStackNCall[I];
    if N = - 1 then
      Exit;
    result := prog.GetProgPtr.RunTimeModuleList.GetModuleIndex(N);
  end;
end;

procedure TPaxCompilerDebugger.Reset;
begin
  prog.DiscardPause;
  prog.GetProgPtr.EPoint := nil;
end;

end.
