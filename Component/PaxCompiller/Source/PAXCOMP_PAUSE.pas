////////////////////////////////////////////////////////////////////////////
// PaxCompiler
// Site: http://www.paxcompiler.com
// Author: Alexander Baranovsky (paxscript@gmail.com)
// ========================================================================
// Copyright (c) Alexander Baranovsky, 2006-2008. All rights reserved.
// Code Version: 2.4
// ========================================================================
// Unit: PAXCOMP_PAUSE.pas
// ========================================================================
////////////////////////////////////////////////////////////////////////////

{$I PaxCompiler.def}
unit PAXCOMP_PAUSE;
interface

uses
  SysUtils,
  PAXCOMP_CONSTANTS,
  PAXCOMP_SYS;

type
  TPauseRec = class
  public
    _EBP: Integer;
    _ESP: Integer;
    ESP0: Integer;
    ProgOffset: Integer;
    StackFrame: Pointer;
    StackFrameSize: Integer;
    constructor Create;
    destructor Destroy; override;
    procedure Clear;
    procedure SaveStackFrame;
    function GetPtr(EBP_Value, Shift: Integer): Pointer;
  end;

  TPauseException = class(EAbort)
  public
    constructor Create;
  end;

  THaltException = class(EAbort)
  public
    ExitCode: Integer;
    constructor Create(i_ExitCode: Integer);
  end;

implementation

//-- TPauseException -----------------------------------------------------------

constructor TPauseException.Create;
begin
  inherited Create('');
end;

//-- THaltException ------------------------------------------------------------

constructor THaltException.Create(i_ExitCode: Integer);
begin
  inherited Create('');
  ExitCode := i_ExitCode;
end;

//-- TPauseRec -----------------------------------------------------------------

constructor TPauseRec.Create;
begin
  inherited;
  StackFrame := nil;
  Clear;
end;

destructor TPauseRec.Destroy;
begin
  Clear;
  inherited;
end;

procedure TPauseRec.Clear;
begin
  if StackFrame <> nil then
    FreeMem(StackFrame, StackFrameSize);
  _ESP := 0;
  ESP0 := 0;
  ProgOffset := 0;
  StackFrame := nil;
  StackFrameSize := 0;
end;

procedure TPauseRec.SaveStackFrame;
var
  P: Pointer;
  I, K: Integer;
begin
  if ESP0 = _ESP then
    Exit;

  if StackFrame <> nil then
    FreeMem(StackFrame, StackFrameSize);

  StackFrameSize := ESP0 - _ESP;

  if StackFrameSize < 0 then
    Exit;

  StackFrame := AllocMem(StackFrameSize);

  I := ESP0 - 4;

//  P := StackFrame;
  P := ShiftPointer(StackFrame, StackFrameSize - 4);

  K := StackFrameSize div 4;

  asm
    mov eax, I
    mov ebx, P
    mov ecx, K

    @@loop:

    mov edx, [eax]
    mov [ebx], edx

    sub eax, 4

//  add ebx, 4
    sub ebx, 4

    sub ecx, 1
    cmp ecx, 0
    jnz @@loop
  end;
end;

function TPauseRec.GetPtr(EBP_Value, Shift: Integer): Pointer;
var
  K: Integer;
begin
//  K := ESP0 - EBP_Value - Shift - 4;
  K := EBP_Value + Shift - _ESP;
  result := ShiftPointer(StackFrame, K);
end;

end.