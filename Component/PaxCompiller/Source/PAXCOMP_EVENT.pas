////////////////////////////////////////////////////////////////////////////
// PaxCompiler
// Site: http://www.paxcompiler.com
// Author: Alexander Baranovsky (paxscript@gmail.com)
// ========================================================================
// Copyright (c) Alexander Baranovsky, 2006-2008. All rights reserved.
// Code Version: 2.4
// ========================================================================
// Unit: PAXCOMP_EVENT.pas
// ========================================================================
////////////////////////////////////////////////////////////////////////////

{$I PaxCompiler.def}
{$O-}
unit PAXCOMP_EVENT;
interface

uses
  SysUtils,
  Classes;

type
  TEventHandlerRec = class
  public
    _ESI: Integer; // 4
    _EDI: Integer; // 8
    Code: Pointer; // 12
    Data: TObject; // 16
    Prog: Pointer; // 20
    CallConv: Integer; // 24
    RetSize: Integer; // 28
    procedure Invoke;
  end;

  TEventHandlerList = class
  private
    L: TList;
    function GetRecord(I: Integer): TEventHandlerRec;
    function GetCount: Integer;
  public
    constructor Create;
    destructor Destroy; override;
    procedure Clear;
    function Lookup(Code: Pointer; Data: TObject): TEventHandlerRec;
    function Add(Prog, Code, Data: Pointer; CallConv, RetSize: Integer): TEventHandlerRec;
    property Count: Integer read GetCount;
    property Records[I: Integer]: TEventHandlerRec read GetRecord; default;
  end;

implementation

uses
  PAXCOMP_CONSTANTS,
  PAXCOMP_SYS,
  PAXCOMP_PROG,
  PAXCOMP_STDLIB,
  PAXCOMP_PAUSE,
  PAXCOMP_INVOKE;

// -- TEventHandlerRec ---------------------------------------------------------

{
procedure TEventHandlerRec.Invoke; assembler;
asm
  sub esp, 4 // reserve place for Code

  push ecx
  mov ecx, [eax + 12]
//  add ecx, 14
  mov [esp + 4], ecx // Code
  pop ecx

  mov esi, [eax + 4] // esi
  mov edi, [eax + 8] // edi

  mov eax, [eax + 16] // Data

  add esp, 4
  mov ebx, [esp - 4]
  jmp ebx
end;
}

procedure TEventHandlerRec.Invoke;
var
  P: TProgram;
  EPoint, OldEPoint: TInvoke;
  _EAX, _ECX, _EDX, _EBP: Integer;
  OldESP0: Integer;
  OldIsEvent: Boolean;
begin
  asm
    mov _EBP, ebp
    mov _EAX, eax
    mov _ECX, ecx
    mov _EDX, edx
  end;

  P := Prog;
  P := P.RootProg;

  if not P.IsPauseUpdated then
  begin

    EPoint := TInvoke.CreateInternal;
    EPoint._EAX := _EAX;
    EPoint._ECX := _ECX;
    EPoint._EDX := _EDX;
    EPoint.CallConv := CallConv;
    EPoint.StackSize := RetSize;
    EPoint.StackFrame := Pointer(_EBP + 4 + RetSize);

    OldEPoint := P.EPoint;
    OldESP0 := P.RootESP0;
    OldIsEvent := P.RootIsEvent;

    try
      P.RootIsEvent := true;

      EPoint.Address := Code;
      EPoint.SetThis(Data);

      if CallConv = ccREGISTER then
        EPoint._EAX := Integer(Data);

      P.EPoint := EPoint;
      P.RunEx;

    finally

      P.RootESP0 := OldESP0;
      P.RootIsEvent := OldIsEvent;

      P.EPoint := OldEPoint;
      EPoint.Free;
    end;

    // emulate ret RetSize

    if P.IsHalted then
      raise THaltException.Create(P.ExitCode);

  end;

  if RetSize = 0 then
    Exit;

  _ecx := RetSize;
{
  asm
    mov ecx, _ecx

    mov esp, ebp
    pop ebp
    mov ebx, [esp]

    @@loop:
    pop edx
    sub ecx, 4
    jnz @@loop
    pop edx
    jmp ebx
  end;
}
  asm
    mov ecx, _ecx

    mov esp, ebp
    pop ebp

    fild dword ptr [esp]

    @@loop:
    pop edx
    sub ecx, 4
    jnz @@loop

    fistp dword ptr [esp]

    pop edx
    jmp edx
  end;
end;

// -- TEventHandlerList --------------------------------------------------------

constructor TEventHandlerList.Create;
begin
  L := TList.Create;
end;

destructor TEventHandlerList.Destroy;
begin
  Clear;
  L.Free;
end;

procedure TEventHandlerList.Clear;
var
  I: Integer;
begin
  for I:=0 to Count - 1 do
    Records[I].Free;
  L.Clear;
end;

function TEventHandlerList.Add(Prog, Code, Data: Pointer; CallConv, RetSize: Integer): TEventHandlerRec;
begin
  result := Lookup(Code, Data);
  if result = nil then
  begin
    result := TEventHandlerRec.Create;
    result.Code := Code;
    result.Data := Data;
    result._ESI := Integer(TProgram(Prog).DataPtr);
    result._EDI := Integer(TProgram(Prog).CodePtr);
    result.Prog := Prog;
    result.CallConv := CallConv;
    result.RetSize := RetSize;
    L.Add(result);
  end;
end;

function TEventHandlerList.Lookup(Code: Pointer; Data: TObject): TEventHandlerRec;
var
  R: TEventHandlerRec;
  I: Integer;
begin
  for I:=0 to Count - 1 do
  begin
    R := Records[I];
    if (R.Code = Code) and (R.Data = Data) then
    begin
      result := R;
      Exit;
    end;
  end;
  result := nil;
end;

function TEventHandlerList.GetRecord(I: Integer): TEventHandlerRec;
begin
  result := TEventHandlerRec(L[I]);
end;

function TEventHandlerList.GetCount: Integer;
begin
  result := L.Count;
end;

end.
