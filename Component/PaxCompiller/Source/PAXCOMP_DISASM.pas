////////////////////////////////////////////////////////////////////////////
// PaxCompiler
// Site: http://www.paxcompiler.com
// Author: Alexander Baranovsky (paxscript@gmail.com)
// ========================================================================
// Copyright (c) Alexander Baranovsky, 2006-2008. All rights reserved.
// Code Version: 2.4
// ========================================================================
// Unit: PAXCOMP_DISASM.pas
// ========================================================================
////////////////////////////////////////////////////////////////////////////

{$I PaxCompiler.def}
unit PAXCOMP_DISASM;
interface

uses
  SysUtils,
  PAXCOMP_CONSTANTS,
  PAXCOMP_SYS;

type
  TArg = packed record
    valid: Boolean;
    Reg: Byte;
    Ptr: Boolean;
    sz: Byte;
    val: Integer;
  end;

procedure Decomp(P: Pointer; var Length: Integer; var op: Integer;
                                                  var Arg1: TArg;
                                                  var Arg2: TArg);
procedure ClearArg(var Arg: TArg);
function EqualArgs(const Arg1, Arg2: TArg): Boolean;

procedure SaveDecompiledCode(P: Pointer; CodeSize: Integer; const FileName: String);
function ArgToString(const Arg: TArg): String;

procedure DiscardDebugMode(P: Pointer; CodeSize: Integer);
function GetInitializationOffset(P: Pointer; CodeSize: Integer): Integer;
function GetFinalizationOffset(P: Pointer; CodeSize: Integer): Integer;

implementation

procedure RaiseError(const Message: string; params: array of Const);
begin
  raise Exception.Create(Format(Message, params));
end;

function ValToStr(val: Integer): String;
begin
//  result := IntToStr(val);

  if val = 0 then
    result := '0'
  else if val > 0 then
  begin
    result := Format('%x', [val]);
    while Length(result) < 4 do
      result := '0' + result;
    result := '$' + result;
  end
  else
  begin
    result := Format('%x', [-val]);
    while Length(result) < 4 do
      result := '0' + result;
    result := '-$' + result;
  end;
end;

function ArgToString(const Arg: TArg): String;
begin
  with Arg do
  begin
    if not valid then
    begin
      result := '';
      Exit;
    end;
    if Reg = 0 then // imm
    begin
      result := ValToStr(val);
      Exit;
    end;
    if not Ptr then
    begin
      case sz of
        1:
        case Reg of
         _EAX: result := 'AL';
         _ECX: result := 'CL';
         _EDX: result := 'DL';
         _EBX: result := 'BL';
        else
          RaiseError(errInternalError, []);
        end;
        2:
        case Reg of
         _EAX: result := 'AX';
         _ECX: result := 'CX';
         _EDX: result := 'DX';
         _EBX: result := 'BX';
        else
          RaiseError(errInternalError, []);
        end;
        else
        case Reg of
         _EAX: result := 'EAX';
         _ECX: result := 'ECX';
         _EDX: result := 'EDX';
         _EBX: result := 'EBX';
         _ESI: result := 'ESI';
         _EDI: result := 'EDI';
         _EBP: result := 'EBP';
         _ESP: result := 'ESP';
        end;
      end;
    end
    else // Ptr
    begin

      case Reg of
       _EAX: result := '[EAX]';
       _ECX: result := '[ECX]';
       _EDX: result := '[EDX]';
       _EBX: result := '[EBX]';
       _ESI: result := '[ESI]';
       _EDI: result := '[EDI]';
       _EBP: result := '[EBP]';
       _ESP: result := '[ESP]';
      end;

      if val <> 0 then
        result := ValToStr(val) + result;

      case sz of
        1: result := 'BYTE PTR ' + result;
        2: result := 'WORD PTR ' + result;
        4: result := 'DWORD PTR ' + result;
        8: result := 'QWORD PTR ' + result;
       10: result := 'TBYTE PTR ' + result;
      else
        RaiseError(errInternalError, []);
      end;
    end;
  end;
end;

procedure ClearArg(var Arg: TArg);
begin
  FillChar(Arg, SizeOf(Arg), 0);
end;

function EqualArgs(const Arg1, Arg2: TArg): Boolean;
begin
  result := (Arg1.Reg = Arg2.Reg) and
            (Arg1.Ptr = Arg2.Ptr) and
            (Arg1.sz = Arg2.sz) and
            (Arg1.val = Arg2.val);
end;

procedure SaveDecompiledCode(P: Pointer; CodeSize: Integer; const FileName: String);
var
  buff: array[1..10] of byte;
  L: Integer;

function HexCode: String;
var
  I: Integer;
begin
  result := '';
  for I:=1 to L do
     result := result + ByteToHex(buff[I]);
end;

var
  T: TextFile;
  K, Line: Integer;
  Op: Integer;
  Arg1, Arg2: TArg;
  S, S1, S2: String;
begin
  Line := 0;
  K := 0;

  AssignFile(T, FileName);
  Rewrite(T);
  try
    repeat
      Inc(Line);
      Decomp(P, L, Op, Arg1, Arg2);
      Move(P^, buff, L);

      S  := AsmOperators[Op];
      S1 := ArgToString(Arg1);
      S2 := ArgToString(Arg2);

      if not Arg2.valid then
        writeln(T, Line:6, HexCode:20, S:10, S1:20)
      else
        writeln(T, Line:6, HexCode:20, S:10, S1:20, ',', S2);

      P := ShiftPointer(P, L);
      Inc(K, L);
      if K >= CodeSize then
        Break;
    until false;
  finally
    Close(T);
  end;
end;

procedure DiscardDebugMode(P: Pointer; CodeSize: Integer);
var
  buff: array[1..10] of byte;
  L: Integer;
  Value: Cardinal;
var
  K: Integer;
  Op: Integer;
  Arg1, Arg2: TArg;
begin
  Value := 58;

  K := 0;

  repeat
    Decomp(P, L, Op, Arg1, Arg2);
    Move(P^, buff, L);

    if Op = ASM_NOP then
    begin
      Move(P^, Buff, 5);
      if Buff[2] = $90 then
      if Buff[3] = $90 then
      if Buff[4] = $90 then
      if Buff[5] = $90 then
      begin
        Buff[1] := $E9;
        Move(value, Buff[2], 4);
        Move(Buff, P^, 5);

        P := ShiftPointer(P, 5);
        Inc(K, 5);
      end;
    end
    else
    begin
      P := ShiftPointer(P, L);
      Inc(K, L);
    end;

    if K >= CodeSize then
      Break;

  until false;
end;

function GetMagicOffset(P: Pointer; CodeSize: Integer; MAGIC_COUNT: Integer): Integer;
var
  K, L, Op, Count: Integer;
  Arg1, Arg2: TArg;
begin
  K := 0;

  Count := 0;

  result := -1;

  repeat
    Decomp(P, L, Op, Arg1, Arg2);

    if Op = ASM_JMP then
    begin
      if Arg1.val = 0 then
      begin
        Inc(Count);
        if Count = MAGIC_COUNT then
        begin
          result := K;
          Exit;
        end;
      end
      else
        Count := 0;
    end
    else
      Count := 0;

    P := ShiftPointer(P, L);
    Inc(K, L);

    if K >= CodeSize then
      Break;

  until false;
end;

function GetFinalizationOffset(P: Pointer; CodeSize: Integer): Integer;
begin
  result := GetMagicOffset(P, CodeSize, MAGIC_FINALIZATION_JMP_COUNT);
end;

function GetInitializationOffset(P: Pointer; CodeSize: Integer): Integer;
begin
  result := GetMagicOffset(P, CodeSize, MAGIC_INITIALIZATION_JMP_COUNT);
end;

procedure Decomp(P: Pointer; var Length: Integer; var op: Integer;
                                                  var Arg1: TArg;
                                                  var Arg2: TArg);
var
  B: Byte;
begin
  ClearArg(Arg1);
  Arg1.valid := true;
  Arg1.sz := 4;
  ClearArg(Arg2);
  Arg2.valid := true;
  Arg2.sz := 4;

  B := Byte(P^);
  case B of

    $C2:
    begin
      op := ASM_RET;
      Length := 3;

      P := ShiftPointer(P, 1);
      Arg1.val := 0;
      Move(P^, Arg1.val, 2);

      Arg2.valid := false;
    end;

    $C3:
    begin
      op := ASM_RET;
      Length := 1;

      Arg1.valid := false;
      Arg2.valid := false;
    end;

    $90:
    begin
      op := ASM_NOP;
      Length := 1;

      Arg1.valid := false;
      Arg2.valid := false;
    end;

    $9B:
    begin
      op := ASM_WAIT;
      Length := 1;

      Arg1.valid := false;
      Arg2.valid := false;
    end;

    $91..$97:
    begin
      op := ASM_XCHG;
      Length := 1;

      Arg1.Reg := _EAX;
      case B of
        $91: Arg2.Reg := _ECX;
        $92: Arg2.Reg := _EDX;
        $93: Arg2.Reg := _EBX;
        $94: Arg2.Reg := _ESP;
        $95: Arg2.Reg := _EBP;
        $96: Arg2.Reg := _ESI;
        $97: Arg2.Reg := _EDI;
      else
        RaiseError(errInternalError, []);
      end;
    end;

    $F8:
    begin
      op := ASM_CLC;
      Length := 1;

      Arg1.valid := false;
      Arg2.valid := false;
    end;

    $9C:
    begin
      op := ASM_PUSHFD;
      Length := 1;

      Arg1.valid := false;
      Arg2.valid := false;
    end;

    $9D:
    begin
      op := ASM_POPFD;
      Length := 1;

      Arg1.valid := false;
      Arg2.valid := false;
    end;

    $F3:
    begin
      Length := 2;
      Arg1.valid := false;
      Arg2.valid := false;

      P := ShiftPointer(P, 1);
      B := Byte(P^);

      case B of
        $A4: op := ASM_REP_MOVSB;
        $A5: op := ASM_REP_MOVSD;
      else
        RaiseError(errInternalError, []);
      end;
    end;

    $71:
    begin
      op := ASM_JNO;
      Length := 2;
      P := ShiftPointer(P, 1);
      B := Byte(P^);
      Arg1.val := B;
      Arg2.valid := false;
    end;

    $73:
    begin
      op := ASM_JNC;
      Length := 2;
      P := ShiftPointer(P, 1);
      B := Byte(P^);
      Arg1.val := B;
      Arg2.valid := false;
    end;

    $74:
    begin
      op := ASM_JZ;
      Length := 2;
      P := ShiftPointer(P, 1);
      B := Byte(P^);
      Arg1.val := B;
      Arg2.valid := false;
    end;

    $75:
    begin
      op := ASM_JNZ;
      Length := 2;
      P := ShiftPointer(P, 1);
      B := Byte(P^);
      Arg1.val := B;
      Arg2.valid := false;
    end;

    $76:
    begin
      op := ASM_JBE;
      Length := 2;
      P := ShiftPointer(P, 1);
      B := Byte(P^);
      Arg1.val := B;
      Arg2.valid := false;
    end;

    $7F:
    begin
      op := ASM_JNLE;
      Length := 2;
      P := ShiftPointer(P, 1);
      B := Byte(P^);
      Arg1.val := B;
      Arg2.valid := false;
    end;

    // Mov EAX, Imm
    $B8:
    begin
      Op := ASM_MOV;
      Length := 5;

      Arg1.Reg := _EAX;

      P := ShiftPointer(P, 1);
      Move(P^, Arg2.Val, 4);
    end;

    // Mov ECX, Imm
    $B9:
    begin
      Op := ASM_MOV;
      Length := 5;

      Arg1.Reg := _ECX;
      P := ShiftPointer(P, 1);
      Move(P^, Arg2.Val, 4);
    end;

    // Mov EDX, Imm
    $BA:
    begin
      Op := ASM_MOV;
      Length := 5;

      Arg1.Reg := _EDX;
      P := ShiftPointer(P, 1);
      Move(P^, Arg2.Val, 4);
    end;

    // Mov EBX, Imm
    $BB:
    begin
      Op := ASM_MOV;
      Length := 5;

      Arg1.Reg := _EBX;
      P := ShiftPointer(P, 1);
      Move(P^, Arg2.Val, 4);
    end;

    // Add REG, REG
    $01:
    begin
      Op := ASM_ADD;
      Length := 2;

      P := ShiftPointer(P, 1);
      B := Byte(P^);

      case B of
        $C0: begin Arg1.Reg := _EAX; Arg2.Reg := _EAX; end;
        $C8: begin Arg1.Reg := _EAX; Arg2.Reg := _ECX; end;
        $D0: begin Arg1.Reg := _EAX; Arg2.Reg := _EDX; end;
        $D8: begin Arg1.Reg := _EAX; Arg2.Reg := _EBX; end;
        $F0: begin Arg1.Reg := _EAX; Arg2.Reg := _ESI; end;
        $F8: begin Arg1.Reg := _EAX; Arg2.Reg := _EDI; end;

        $C1: begin Arg1.Reg := _ECX; Arg2.Reg := _EAX; end;
        $C9: begin Arg1.Reg := _ECX; Arg2.Reg := _ECX; end;
        $D1: begin Arg1.Reg := _ECX; Arg2.Reg := _EDX; end;
        $D9: begin Arg1.Reg := _ECX; Arg2.Reg := _EBX; end;
        $F1: begin Arg1.Reg := _ECX; Arg2.Reg := _ESI; end;
        $F9: begin Arg1.Reg := _ECX; Arg2.Reg := _EDI; end;

        $C2: begin Arg1.Reg := _EDX; Arg2.Reg := _EAX; end;
        $CA: begin Arg1.Reg := _EDX; Arg2.Reg := _ECX; end;
        $D2: begin Arg1.Reg := _EDX; Arg2.Reg := _EDX; end;
        $DA: begin Arg1.Reg := _EDX; Arg2.Reg := _EBX; end;
        $F2: begin Arg1.Reg := _EDX; Arg2.Reg := _ESI; end;
        $FA: begin Arg1.Reg := _EDX; Arg2.Reg := _EDI; end;

        $C3: begin Arg1.Reg := _EBX; Arg2.Reg := _EAX; end;
        $CB: begin Arg1.Reg := _EBX; Arg2.Reg := _ECX; end;
        $D3: begin Arg1.Reg := _EBX; Arg2.Reg := _EDX; end;
        $DB: begin Arg1.Reg := _EBX; Arg2.Reg := _EBX; end;
        $F3: begin Arg1.Reg := _EBX; Arg2.Reg := _ESI; end;
        $FB: begin Arg1.Reg := _EBX; Arg2.Reg := _EDI; end;
      else
        RaiseError(errInternalError, []);
      end;
    end;

    // Adc REG, REG
    $11:
    begin
      Op := ASM_ADC;
      Length := 2;

      P := ShiftPointer(P, 1);
      B := Byte(P^);

      case B of
        $C0: begin Arg1.Reg := _EAX; Arg2.Reg := _EAX; end;
        $C8: begin Arg1.Reg := _EAX; Arg2.Reg := _ECX; end;
        $D0: begin Arg1.Reg := _EAX; Arg2.Reg := _EDX; end;
        $D8: begin Arg1.Reg := _EAX; Arg2.Reg := _EBX; end;
        $F0: begin Arg1.Reg := _EAX; Arg2.Reg := _ESI; end;
        $F8: begin Arg1.Reg := _EAX; Arg2.Reg := _EDI; end;

        $C1: begin Arg1.Reg := _ECX; Arg2.Reg := _EAX; end;
        $C9: begin Arg1.Reg := _ECX; Arg2.Reg := _ECX; end;
        $D1: begin Arg1.Reg := _ECX; Arg2.Reg := _EDX; end;
        $D9: begin Arg1.Reg := _ECX; Arg2.Reg := _EBX; end;
        $F1: begin Arg1.Reg := _ECX; Arg2.Reg := _ESI; end;
        $F9: begin Arg1.Reg := _ECX; Arg2.Reg := _EDI; end;

        $C2: begin Arg1.Reg := _EDX; Arg2.Reg := _EAX; end;
        $CA: begin Arg1.Reg := _EDX; Arg2.Reg := _ECX; end;
        $D2: begin Arg1.Reg := _EDX; Arg2.Reg := _EDX; end;
        $DA: begin Arg1.Reg := _EDX; Arg2.Reg := _EBX; end;
        $F2: begin Arg1.Reg := _EDX; Arg2.Reg := _ESI; end;
        $FA: begin Arg1.Reg := _EDX; Arg2.Reg := _EDI; end;

        $C3: begin Arg1.Reg := _EBX; Arg2.Reg := _EAX; end;
        $CB: begin Arg1.Reg := _EBX; Arg2.Reg := _ECX; end;
        $D3: begin Arg1.Reg := _EBX; Arg2.Reg := _EDX; end;
        $DB: begin Arg1.Reg := _EBX; Arg2.Reg := _EBX; end;
        $F3: begin Arg1.Reg := _EBX; Arg2.Reg := _ESI; end;
        $FB: begin Arg1.Reg := _EBX; Arg2.Reg := _EDI; end;
      else
        RaiseError(errInternalError, []);
      end;
    end;

    // Sbb REG, REG
    $19:
    begin
      Op := ASM_ADC;
      Length := 2;

      P := ShiftPointer(P, 1);
      B := Byte(P^);

      case B of
        $C0: begin Arg1.Reg := _EAX; Arg2.Reg := _EAX; end;
        $C8: begin Arg1.Reg := _EAX; Arg2.Reg := _ECX; end;
        $D0: begin Arg1.Reg := _EAX; Arg2.Reg := _EDX; end;
        $D8: begin Arg1.Reg := _EAX; Arg2.Reg := _EBX; end;
        $F0: begin Arg1.Reg := _EAX; Arg2.Reg := _ESI; end;
        $F8: begin Arg1.Reg := _EAX; Arg2.Reg := _EDI; end;

        $C1: begin Arg1.Reg := _ECX; Arg2.Reg := _EAX; end;
        $C9: begin Arg1.Reg := _ECX; Arg2.Reg := _ECX; end;
        $D1: begin Arg1.Reg := _ECX; Arg2.Reg := _EDX; end;
        $D9: begin Arg1.Reg := _ECX; Arg2.Reg := _EBX; end;
        $F1: begin Arg1.Reg := _ECX; Arg2.Reg := _ESI; end;
        $F9: begin Arg1.Reg := _ECX; Arg2.Reg := _EDI; end;

        $C2: begin Arg1.Reg := _EDX; Arg2.Reg := _EAX; end;
        $CA: begin Arg1.Reg := _EDX; Arg2.Reg := _ECX; end;
        $D2: begin Arg1.Reg := _EDX; Arg2.Reg := _EDX; end;
        $DA: begin Arg1.Reg := _EDX; Arg2.Reg := _EBX; end;
        $F2: begin Arg1.Reg := _EDX; Arg2.Reg := _ESI; end;
        $FA: begin Arg1.Reg := _EDX; Arg2.Reg := _EDI; end;

        $C3: begin Arg1.Reg := _EBX; Arg2.Reg := _EAX; end;
        $CB: begin Arg1.Reg := _EBX; Arg2.Reg := _ECX; end;
        $D3: begin Arg1.Reg := _EBX; Arg2.Reg := _EDX; end;
        $DB: begin Arg1.Reg := _EBX; Arg2.Reg := _EBX; end;
        $F3: begin Arg1.Reg := _EBX; Arg2.Reg := _ESI; end;
        $FB: begin Arg1.Reg := _EBX; Arg2.Reg := _EDI; end;
      else
        RaiseError(errInternalError, []);
      end;
    end;

    // Add EAX, Imm
    $05:
    begin
      Op := ASM_ADD;
      Length := 5;

      Arg1.Reg := _EAX;
      P := ShiftPointer(P, 1);
      Move(P^, Arg2.val, 4);
    end;

    $81:
    begin
      P := ShiftPointer(P, 1);
      B := Byte(P^);

      case B of
        $C1..$C6: // ADD Reg, Imm
        begin
          Op := ASM_ADD;
          Length := 6;
          case B of
            $C1: Arg1.Reg := _ECX;
            $C2: Arg1.Reg := _EDX;
            $C3: Arg1.Reg := _EBX;
            $C4: Arg1.Reg := _ESP;
            $C5: Arg1.Reg := _EBP;
            $C6: Arg1.Reg := _ESI;
          end;
          P := ShiftPointer(P, 1);
          Move(P^, Arg2.val, 4);
        end;

        $80..$86:  // ADD DWORD PTR Shift[Reg], Imm
        begin
          Op := ASM_ADD;
          Length := 10;
          case B of
            $80: Arg1.Reg := _EAX;
            $81: Arg1.Reg := _ECX;
            $82: Arg1.Reg := _EDX;
            $83: Arg1.Reg := _EBX;
            $84: Arg1.Reg := _ESP;
            $85: Arg1.Reg := _EBP;
            $86: Arg1.Reg := _ESI;
          end;
          Arg1.Ptr := true;
          P := ShiftPointer(P, 1);
          Move(P^, Arg1.val, 4);
          P := ShiftPointer(P, 4);
          Move(P^, Arg2.val, 4);
        end;

        $F9..$FF: // CMP Reg, Imm
        begin
          Op := ASM_CMP;
          Length := 6;
          case B of
            $F9: Arg1.Reg := _ECX;
            $FA: Arg1.Reg := _EDX;
            $FB: Arg1.Reg := _EBX;
            $FC: Arg1.Reg := _ESP;
            $FD: Arg1.Reg := _EBP;
            $FE: Arg1.Reg := _ESI;
            $FF: Arg1.Reg := _EDI;
          end;
          P := ShiftPointer(P, 1);
          Move(P^, Arg2.val, 4);
        end;

        $E9..$EF: // SUB Reg, Imm
        begin
          Op := ASM_SUB;
          Length := 6;
          case B of
            $E9: Arg1.Reg := _ECX;
            $EA: Arg1.Reg := _EDX;
            $EB: Arg1.Reg := _EBX;
            $EC: Arg1.Reg := _ESP;
            $ED: Arg1.Reg := _EBP;
            $EE: Arg1.Reg := _ESI;
            $EF: Arg1.Reg := _EDI;
          end;
          P := ShiftPointer(P, 1);
          Move(P^, Arg2.val, 4);
        end;

        $B8..$BE:  // CMP DWORD PTR Shift[Reg], Imm
        begin
          Op := ASM_CMP;
          Length := 10;
          case B of
            $B8: Arg1.Reg := _EAX;
            $B9: Arg1.Reg := _ECX;
            $BA: Arg1.Reg := _EDX;
            $BB: Arg1.Reg := _EBX;
            $BC: Arg1.Reg := _ESP;
            $BD: Arg1.Reg := _EBP;
            $BE: Arg1.Reg := _ESI;
          end;
          Arg1.Ptr := true;
          P := ShiftPointer(P, 1);
          Move(P^, Arg1.val, 4);
          P := ShiftPointer(P, 4);
          Move(P^, Arg2.val, 4);
        end;
      else
        RaiseError(errInternalError, []);
      end;
    end;

    $F7:
    begin
      P := ShiftPointer(P, 1);
      B := Byte(P^);

      case B of
        $E0..$E3: // mul reg
        begin
          Op := ASM_MUL;
          Length := 2;
          case B of
            $E0: Arg1.Reg := _EAX;
            $E1: Arg1.Reg := _ECX;
            $E2: Arg1.Reg := _EDX;
            $E3: Arg1.Reg := _EBX;
          end;
          Arg2.valid := false;
        end;
        $E8..$EB: // imul reg
        begin
          Op := ASM_IMUL;
          Length := 2;
          case B of
            $E8: Arg1.Reg := _EAX;
            $E9: Arg1.Reg := _ECX;
            $EA: Arg1.Reg := _EDX;
            $EB: Arg1.Reg := _EBX;
          end;
          Arg2.valid := false;
        end;
        $F0..$F3: // div reg
        begin
          Op := ASM_DIV;
          Length := 2;
          case B of
            $F0: Arg1.Reg := _EAX;
            $F1: Arg1.Reg := _ECX;
            $F2: Arg1.Reg := _EDX;
            $F3: Arg1.Reg := _EBX;
          end;
          Arg2.valid := false;
        end;
        $F8..$FB: // idiv reg
        begin
          Op := ASM_IDIV;
          Length := 2;
          case B of
            $F8: Arg1.Reg := _EAX;
            $F9: Arg1.Reg := _ECX;
            $FA: Arg1.Reg := _EDX;
            $FB: Arg1.Reg := _EBX;
          end;
          Arg2.valid := false;
        end;
        $D8..$DB: // neg reg
        begin
          Op := ASM_NEG;
          Length := 2;
          case B of
            $D8: Arg1.Reg := _EAX;
            $D9: Arg1.Reg := _ECX;
            $DA: Arg1.Reg := _EDX;
            $DB: Arg1.Reg := _EBX;
          end;
          Arg2.valid := false;
        end;
        $98..$9E:  // neg dword ptr [reg]
        begin
          Op := ASM_NEG;
          Length := 6;
          case B of
            $98: Arg1.Reg := _EAX;
            $99: Arg1.Reg := _ECX;
            $9A: Arg1.Reg := _EDX;
            $9B: Arg1.Reg := _EBX;
            $9C: Arg1.Reg := _ESP;
            $9D: Arg1.Reg := _EBP;
            $9E: Arg1.Reg := _ESI;
          end;
          P := ShiftPointer(P, 1);
          Move(P^, Arg1.val, 4);
          Arg1.Ptr := true;
          Arg2.valid := false;
        end;
      else
        RaiseError(errInternalError, []);
      end;
    end;

    $D3:
    begin
      P := ShiftPointer(P, 1);
      B := Byte(P^);

      Arg2.Reg := _ECX;
      Arg2.sz := 1;
      Length := 2;

      case B of
        $E0..$E3: // shl reg, cl
        begin
          Op := ASM_SHL;
          case B of
            $E0: Arg1.Reg := _EAX;
            $E1: Arg1.Reg := _ECX;
            $E2: Arg1.Reg := _EDX;
            $E3: Arg1.Reg := _EBX;
          end;
        end;
        $E8..$EB: // shr reg, cl
        begin
          Op := ASM_SHR;
          case B of
            $E8: Arg1.Reg := _EAX;
            $E9: Arg1.Reg := _ECX;
            $EA: Arg1.Reg := _EDX;
            $EB: Arg1.Reg := _EBX;
          end;
        end;
      else
        RaiseError(errInternalError, []);
      end;
    end;

    //GET REG, BYTE PTR ESI or EBP
    $8A:
    begin
      Op := ASM_MOV;

      P := ShiftPointer(P, 1);
      B := Byte(P^);

      if B in [$86, $8E, $96, $9E] then
      begin
        Length := 6;

        Arg1.sz := 1;
        case B of
          $86: Arg1.Reg := _EAX;
          $8E: Arg1.Reg := _ECX;
          $96: Arg1.Reg := _EDX;
          $9E: Arg1.Reg := _EBX;
        end;

        Arg2.sz := 1;
        Arg2.Reg := _ESI;
        Arg2.Ptr := true;

        P := ShiftPointer(P, 1);
        Move(P^, Arg2.val, 4);
      end
      else if B in [$85, $8D, $95, $9D] then
      begin
        Length := 6;

        Arg1.sz := 1;
        case B of
          $85: Arg1.Reg := _EAX;
          $8D: Arg1.Reg := _ECX;
          $95: Arg1.Reg := _EDX;
          $9D: Arg1.Reg := _EBX;
        end;

        Arg2.sz := 1;
        Arg2.Reg := _EBP;
        Arg2.Ptr := true;

        P := ShiftPointer(P, 1);
        Move(P^, Arg2.val, 4);
      end
      else
      begin
        Length := 2;

        Arg1.sz := 1;
        Arg2.sz := 1;

        Arg2.Ptr := true;

        case B of
          $00: begin Arg1.Reg := _EAX; Arg2.Reg := _EAX; end;
          $01: begin Arg1.Reg := _EAX; Arg2.Reg := _ECX; end;
          $02: begin Arg1.Reg := _EAX; Arg2.Reg := _EDX; end;
          $03: begin Arg1.Reg := _EAX; Arg2.Reg := _EBX; end;

          $08: begin Arg1.Reg := _ECX; Arg2.Reg := _EAX; end;
          $09: begin Arg1.Reg := _ECX; Arg2.Reg := _ECX; end;
          $0A: begin Arg1.Reg := _ECX; Arg2.Reg := _EDX; end;
          $0B: begin Arg1.Reg := _ECX; Arg2.Reg := _EBX; end;

          $10: begin Arg1.Reg := _EDX; Arg2.Reg := _EAX; end;
          $11: begin Arg1.Reg := _EDX; Arg2.Reg := _ECX; end;
          $12: begin Arg1.Reg := _EDX; Arg2.Reg := _EDX; end;
          $13: begin Arg1.Reg := _EDX; Arg2.Reg := _EBX; end;

          $18: begin Arg1.Reg := _EBX; Arg2.Reg := _EAX; end;
          $19: begin Arg1.Reg := _EBX; Arg2.Reg := _ECX; end;
          $1A: begin Arg1.Reg := _EBX; Arg2.Reg := _EDX; end;
          $1B: begin Arg1.Reg := _EBX; Arg2.Reg := _EBX; end;
        else
          RaiseError(errInternalError, []);
        end;
      end;
    end;

    //GET REG, ESI or DI or EBP
    $8B:
    begin
      Op := ASM_MOV;

      P := ShiftPointer(P, 1);
      B := Byte(P^);

      if B in [$86, $9E, $8E, $96] then
      begin
        Length := 6;

        case B of
          $86: Arg1.Reg := _EAX;
          $8E: Arg1.Reg := _ECX;
          $96: Arg1.Reg := _EDX;
          $9E: Arg1.Reg := _EBX;
        end;

        Arg2.Reg := _ESI;
        Arg2.Ptr := true;
        P := ShiftPointer(P, 1);
        Move(P^, Arg2.Val, 4);
      end
      else if B in [$85, $8D, $95, $9D] then
      begin
        Length := 6;

        case B of
          $85: Arg1.Reg := _EAX;
          $8D: Arg1.Reg := _ECX;
          $95: Arg1.Reg := _EDX;
          $9D: Arg1.Reg := _EBX;
        end;

        Arg2.Reg := _EBP;
        Arg2.Ptr := true;
        P := ShiftPointer(P, 1);
        Move(P^, Arg2.Val, 4);
      end
      else if B = $B4 then
      begin
        Length := 7;
        P := ShiftPointer(P, 1);
        B := Byte(P^);
        if B <> $24 then
          RaiseError(errInternalError, []);
        Arg1.Reg := _ESI;
        Arg2.Reg := _ESP;
        Arg2.Ptr := true;
        P := ShiftPointer(P, 1);
        Move(P^, Arg2.Val, 4);
      end
      else if B = $BC then
      begin
        Length := 7;
        P := ShiftPointer(P, 1);
        B := Byte(P^);
        if B <> $24 then
          RaiseError(errInternalError, []);
        Arg1.Reg := _EDI;
        Arg2.Reg := _ESP;
        Arg2.Ptr := true;
        P := ShiftPointer(P, 1);
        Move(P^, Arg2.Val, 4);
      end
      else
      begin
        Length := 2;

        Arg2.Ptr := true;

        case B of
          $00: begin Arg1.Reg := _EAX; Arg2.Reg := _EAX; end;
          $01: begin Arg1.Reg := _EAX; Arg2.Reg := _ECX; end;
          $02: begin Arg1.Reg := _EAX; Arg2.Reg := _EDX; end;
          $03: begin Arg1.Reg := _EAX; Arg2.Reg := _EBX; end;

          $08: begin Arg1.Reg := _ECX; Arg2.Reg := _EAX; end;
          $09: begin Arg1.Reg := _ECX; Arg2.Reg := _ECX; end;
          $0A: begin Arg1.Reg := _ECX; Arg2.Reg := _EDX; end;
          $0B: begin Arg1.Reg := _ECX; Arg2.Reg := _EBX; end;

          $10: begin Arg1.Reg := _EDX; Arg2.Reg := _EAX; end;
          $11: begin Arg1.Reg := _EDX; Arg2.Reg := _ECX; end;
          $12: begin Arg1.Reg := _EDX; Arg2.Reg := _EDX; end;
          $13: begin Arg1.Reg := _EDX; Arg2.Reg := _EBX; end;

          $18: begin Arg1.Reg := _EBX; Arg2.Reg := _EAX; end;
          $19: begin Arg1.Reg := _EBX; Arg2.Reg := _ECX; end;
          $1A: begin Arg1.Reg := _EBX; Arg2.Reg := _EDX; end;
          $1B: begin Arg1.Reg := _EBX; Arg2.Reg := _EBX; end;
        else
          RaiseError(errInternalError, []);
        end;
      end;
    end;

    // Put BYTE PTR [ESI]| BYTE PTR [EBP],  REG
    $88:
    begin
      Op := ASM_MOV;

      P := ShiftPointer(P, 1);
      B := Byte(P^);

      Arg1.sz := 1;
      Arg2.sz := 1;

      if B in [$86, $9E, $8E, $96] then
      begin
        Length := 6;

        case B of
          $86: Arg2.Reg := _EAX;
          $8E: Arg2.Reg := _ECX;
          $96: Arg2.Reg := _EDX;
          $9E: Arg2.Reg := _EBX;
        end;

        Arg1.Ptr := true;
        Arg1.Reg := _ESI;

        P := ShiftPointer(P, 1);
        Move(P^, Arg1.val, 4);
      end
      else if B in [$85, $8D, $95, $9D] then
      begin
        Length := 6;

        case B of
          $85: Arg2.Reg := _EAX;
          $8D: Arg2.Reg := _ECX;
          $95: Arg2.Reg := _EDX;
          $9D: Arg2.Reg := _EBX;
        end;

        Arg1.Ptr := true;
        Arg1.Reg := _EBP;

        P := ShiftPointer(P, 1);
        Move(P^, Arg1.val, 4);
      end
      else
      begin
        Length := 2;

        Arg1.Ptr := true;

        case B of
          $00: begin Arg1.Reg := _EAX; Arg2.Reg := _EAX; end;
          $08: begin Arg1.Reg := _EAX; Arg2.Reg := _ECX; end;
          $10: begin Arg1.Reg := _EAX; Arg2.Reg := _EDX; end;
          $18: begin Arg1.Reg := _EAX; Arg2.Reg := _EBX; end;

          $01: begin Arg1.Reg := _ECX; Arg2.Reg := _EAX; end;
          $09: begin Arg1.Reg := _ECX; Arg2.Reg := _ECX; end;
          $11: begin Arg1.Reg := _ECX; Arg2.Reg := _EDX; end;
          $19: begin Arg1.Reg := _ECX; Arg2.Reg := _EBX; end;

          $02: begin Arg1.Reg := _EDX; Arg2.Reg := _EAX; end;
          $0A: begin Arg1.Reg := _EDX; Arg2.Reg := _ECX; end;
          $12: begin Arg1.Reg := _EDX; Arg2.Reg := _EDX; end;
          $1A: begin Arg1.Reg := _EDX; Arg2.Reg := _EBX; end;

          $03: begin Arg1.Reg := _EBX; Arg2.Reg := _EAX; end;
          $0B: begin Arg1.Reg := _EBX; Arg2.Reg := _ECX; end;
          $13: begin Arg1.Reg := _EBX; Arg2.Reg := _EDX; end;
          $1B: begin Arg1.Reg := _EBX; Arg2.Reg := _EBX; end;
        else
          RaiseError(errInternalError, []);
        end;
      end;
    end;

    // Put [ESI] REG or MOV REGPtr, REG
    $89:
    begin
      Op := ASM_MOV;

      P := ShiftPointer(P, 1);
      B := Byte(P^);

      if B in [$86, $9E, $8E, $96] then
      begin
        Length := 6;

        case B of
          $86: Arg2.Reg := _EAX;
          $9E: Arg2.Reg := _EBX;
          $8E: Arg2.Reg := _ECX;
          $96: Arg2.Reg := _EDX;
        end;

        Arg1.Ptr := true;
        Arg1.Reg := _ESI;
        P := ShiftPointer(P, 1);
        Move(P^, Arg1.val, 4);
      end
      else if B in [$85, $8D, $95, $9D] then
      begin
        Length := 6;

        case B of
          $85: Arg2.Reg := _EAX;
          $8D: Arg2.Reg := _ECX;
          $95: Arg2.Reg := _EDX;
          $9D: Arg2.Reg := _EBX;
        end;

        Arg1.Ptr := true;
        Arg1.Reg := _EBP;
        P := ShiftPointer(P, 1);
        Move(P^, Arg1.val, 4);
      end
      else
      begin
        Length := 2;

        case B of
          $C0: begin Arg1.Reg := _EAX; Arg2.Reg := _EAX; end;
          $C8: begin Arg1.Reg := _EAX; Arg2.Reg := _ECX; end;
          $D0: begin Arg1.Reg := _EAX; Arg2.Reg := _EDX; end;
          $D8: begin Arg1.Reg := _EAX; Arg2.Reg := _EBX; end;
          $E0: begin Arg1.Reg := _EAX; Arg2.Reg := _ESP; end;
          $E8: begin Arg1.Reg := _EAX; Arg2.Reg := _EBP; end;
          $F0: begin Arg1.Reg := _EAX; Arg2.Reg := _ESI; end;
          $F8: begin Arg1.Reg := _EAX; Arg2.Reg := _EDI; end;

          $C1: begin Arg1.Reg := _ECX; Arg2.Reg := _EAX; end;
          $C9: begin Arg1.Reg := _ECX; Arg2.Reg := _ECX; end;
          $D1: begin Arg1.Reg := _ECX; Arg2.Reg := _EDX; end;
          $D9: begin Arg1.Reg := _ECX; Arg2.Reg := _EBX; end;
          $E1: begin Arg1.Reg := _ECX; Arg2.Reg := _ESP; end;
          $E9: begin Arg1.Reg := _ECX; Arg2.Reg := _EBP; end;
          $F1: begin Arg1.Reg := _ECX; Arg2.Reg := _ESI; end;
          $F9: begin Arg1.Reg := _ECX; Arg2.Reg := _EDI; end;

          $C2: begin Arg1.Reg := _EDX; Arg2.Reg := _EAX; end;
          $CA: begin Arg1.Reg := _EDX; Arg2.Reg := _ECX; end;
          $D2: begin Arg1.Reg := _EDX; Arg2.Reg := _EDX; end;
          $DA: begin Arg1.Reg := _EDX; Arg2.Reg := _EBX; end;
          $E2: begin Arg1.Reg := _EDX; Arg2.Reg := _ESP; end;
          $EA: begin Arg1.Reg := _EDX; Arg2.Reg := _EBP; end;
          $F2: begin Arg1.Reg := _EDX; Arg2.Reg := _ESI; end;
          $FA: begin Arg1.Reg := _EDX; Arg2.Reg := _EDI; end;

          $C3: begin Arg1.Reg := _EBX; Arg2.Reg := _EAX; end;
          $CB: begin Arg1.Reg := _EBX; Arg2.Reg := _ECX; end;
          $D3: begin Arg1.Reg := _EBX; Arg2.Reg := _EDX; end;
          $DB: begin Arg1.Reg := _EBX; Arg2.Reg := _EBX; end;
          $E3: begin Arg1.Reg := _EBX; Arg2.Reg := _ESP; end;
          $EB: begin Arg1.Reg := _EBX; Arg2.Reg := _EBP; end;
          $F3: begin Arg1.Reg := _EBX; Arg2.Reg := _ESI; end;
          $FB: begin Arg1.Reg := _EBX; Arg2.Reg := _EDI; end;

          $E5: begin Arg1.Reg := _EBP; Arg2.Reg := _ESP; end;
          $EC: begin Arg1.Reg := _ESP; Arg2.Reg := _EBP; end;

          $C6: begin Arg1.Reg := _ESI; Arg2.Reg := _EAX; end;
          $CE: begin Arg1.Reg := _ESI; Arg2.Reg := _ECX; end;
          $D6: begin Arg1.Reg := _ESI; Arg2.Reg := _EDX; end;
          $DE: begin Arg1.Reg := _ESI; Arg2.Reg := _EBX; end;
          $E6: begin Arg1.Reg := _ESI; Arg2.Reg := _ESP; end;
          $EE: begin Arg1.Reg := _ESI; Arg2.Reg := _EBP; end;
          $F6: begin Arg1.Reg := _ESI; Arg2.Reg := _ESI; end;
          $FE: begin Arg1.Reg := _ESI; Arg2.Reg := _EDI; end;

          $C7: begin Arg1.Reg := _EDI; Arg2.Reg := _EAX; end;
          $CF: begin Arg1.Reg := _EDI; Arg2.Reg := _ECX; end;
          $D7: begin Arg1.Reg := _EDI; Arg2.Reg := _EDX; end;
          $DF: begin Arg1.Reg := _EDI; Arg2.Reg := _EBX; end;
          $E7: begin Arg1.Reg := _EDI; Arg2.Reg := _ESP; end;
          $EF: begin Arg1.Reg := _EDI; Arg2.Reg := _EBP; end;
          $F7: begin Arg1.Reg := _EDI; Arg2.Reg := _ESI; end;
          $FF: begin Arg1.Reg := _EDI; Arg2.Reg := _EDI; end;

          $00: begin Arg1.Ptr := true; Arg1.Reg := _EAX; Arg2.Reg := _EAX; end;
          $08: begin Arg1.Ptr := true; Arg1.Reg := _EAX; Arg2.Reg := _ECX; end;
          $10: begin Arg1.Ptr := true; Arg1.Reg := _EAX; Arg2.Reg := _EDX; end;
          $18: begin Arg1.Ptr := true; Arg1.Reg := _EAX; Arg2.Reg := _EBX; end;

          $01: begin Arg1.Ptr := true; Arg1.Reg := _ECX; Arg2.Reg := _EAX; end;
          $09: begin Arg1.Ptr := true; Arg1.Reg := _ECX; Arg2.Reg := _ECX; end;
          $11: begin Arg1.Ptr := true; Arg1.Reg := _ECX; Arg2.Reg := _EDX; end;
          $19: begin Arg1.Ptr := true; Arg1.Reg := _ECX; Arg2.Reg := _EBX; end;

          $02: begin Arg1.Ptr := true; Arg1.Reg := _EDX; Arg2.Reg := _EAX; end;
          $0A: begin Arg1.Ptr := true; Arg1.Reg := _EDX; Arg2.Reg := _ECX; end;
          $12: begin Arg1.Ptr := true; Arg1.Reg := _EDX; Arg2.Reg := _EDX; end;
          $1A: begin Arg1.Ptr := true; Arg1.Reg := _EDX; Arg2.Reg := _EBX; end;

          $03: begin Arg1.Ptr := true; Arg1.Reg := _EBX; Arg2.Reg := _EAX; end;
          $0B: begin Arg1.Ptr := true; Arg1.Reg := _EBX; Arg2.Reg := _ECX; end;
          $13: begin Arg1.Ptr := true; Arg1.Reg := _EBX; Arg2.Reg := _EDX; end;
          $1B: begin Arg1.Ptr := true; Arg1.Reg := _EBX; Arg2.Reg := _EBX; end;
        else
          RaiseError(errInternalError, []);
        end;
      end;
    end;


    //LEA REG32, [REG32 + Shift]
    $8D:
    begin
      Op := ASM_LEA;
      Length := 6;

      P := ShiftPointer(P, 1);
      B := Byte(P^);

      case B of
        $80: begin Arg1.Reg := _EAX; Arg2.Reg := _EAX; end;
        $81: begin Arg1.Reg := _EAX; Arg2.Reg := _ECX; end;
        $82: begin Arg1.Reg := _EAX; Arg2.Reg := _EDX; end;
        $83: begin Arg1.Reg := _EAX; Arg2.Reg := _EBX; end;
        $85: begin Arg1.Reg := _EAX; Arg2.Reg := _EBP; end;
        $86: begin Arg1.Reg := _EAX; Arg2.Reg := _ESI; end;
        $87: begin Arg1.Reg := _EAX; Arg2.Reg := _EDI; end;

        $88: begin Arg1.Reg := _ECX; Arg2.Reg := _EAX; end;
        $89: begin Arg1.Reg := _ECX; Arg2.Reg := _ECX; end;
        $8A: begin Arg1.Reg := _ECX; Arg2.Reg := _EDX; end;
        $8B: begin Arg1.Reg := _ECX; Arg2.Reg := _EBX; end;
        $8D: begin Arg1.Reg := _ECX; Arg2.Reg := _EBP; end;
        $8E: begin Arg1.Reg := _ECX; Arg2.Reg := _ESI; end;
        $8F: begin Arg1.Reg := _ECX; Arg2.Reg := _EDI; end;

        $90: begin Arg1.Reg := _EDX; Arg2.Reg := _EAX; end;
        $91: begin Arg1.Reg := _EDX; Arg2.Reg := _ECX; end;
        $92: begin Arg1.Reg := _EDX; Arg2.Reg := _EDX; end;
        $93: begin Arg1.Reg := _EDX; Arg2.Reg := _EBX; end;
        $95: begin Arg1.Reg := _EDX; Arg2.Reg := _EBP; end;
        $96: begin Arg1.Reg := _EDX; Arg2.Reg := _ESI; end;
        $97: begin Arg1.Reg := _EDX; Arg2.Reg := _EDI; end;

        $98: begin Arg1.Reg := _EBX; Arg2.Reg := _EAX; end;
        $99: begin Arg1.Reg := _EBX; Arg2.Reg := _ECX; end;
        $9A: begin Arg1.Reg := _EBX; Arg2.Reg := _EDX; end;
        $9B: begin Arg1.Reg := _EBX; Arg2.Reg := _EBX; end;
        $9D: begin Arg1.Reg := _EBX; Arg2.Reg := _EBP; end;
        $9E: begin Arg1.Reg := _EBX; Arg2.Reg := _ESI; end;
        $9F: begin Arg1.Reg := _EBX; Arg2.Reg := _EDI; end;
      else
        RaiseError(errInternalError, []);
      end;

      Arg2.Ptr := true;
      P := ShiftPointer(P, 1);
      Move(P^, Arg2.Val, 4);
    end;

    // (SUB|XOR|CMP|OR|AND) REG, REG
    $29, $31, $39, $09, $21:
    begin

      case B of
        $29: Op := ASM_SUB;
        $31: Op := ASM_XOR;
        $39: Op := ASM_CMP;
        $09: Op := ASM_OR;
        $21: Op := ASM_AND;
      end;

      P := ShiftPointer(P, 1);
      B := Byte(P^);

      Length := 2;

      case B of
        $C0: begin Arg1.Reg := _EAX; Arg2.Reg := _EAX; end;
        $C8: begin Arg1.Reg := _EAX; Arg2.Reg := _ECX; end;
        $D0: begin Arg1.Reg := _EAX; Arg2.Reg := _EDX; end;
        $D8: begin Arg1.Reg := _EAX; Arg2.Reg := _EBX; end;

        $C1: begin Arg1.Reg := _ECX; Arg2.Reg := _EAX; end;
        $C9: begin Arg1.Reg := _ECX; Arg2.Reg := _ECX; end;
        $D1: begin Arg1.Reg := _ECX; Arg2.Reg := _EDX; end;
        $D9: begin Arg1.Reg := _ECX; Arg2.Reg := _EBX; end;

        $C2: begin Arg1.Reg := _EDX; Arg2.Reg := _EAX; end;
        $CA: begin Arg1.Reg := _EDX; Arg2.Reg := _ECX; end;
        $D2: begin Arg1.Reg := _EDX; Arg2.Reg := _EDX; end;
        $DA: begin Arg1.Reg := _EDX; Arg2.Reg := _EBX; end;

        $C3: begin Arg1.Reg := _EBX; Arg2.Reg := _EAX; end;
        $CB: begin Arg1.Reg := _EBX; Arg2.Reg := _ECX; end;
        $D3: begin Arg1.Reg := _EBX; Arg2.Reg := _EDX; end;
        $DB: begin Arg1.Reg := _EBX; Arg2.Reg := _EBX; end;
      else
        RaiseError(errInternalError, []);
      end;
    end;

    $87:
    begin
      Op := ASM_XCHG;

      P := ShiftPointer(P, 1);
      B := Byte(P^);

      Length := 2;

      case B of
        $C9: begin Arg1.Reg := _ECX; Arg2.Reg := _ECX; end;
        $CA: begin Arg1.Reg := _ECX; Arg2.Reg := _EDX; end;
        $CB: begin Arg1.Reg := _ECX; Arg2.Reg := _EBX; end;
        $CC: begin Arg1.Reg := _ECX; Arg2.Reg := _ESP; end;
        $CD: begin Arg1.Reg := _ECX; Arg2.Reg := _EBP; end;
        $CE: begin Arg1.Reg := _ECX; Arg2.Reg := _ESI; end;
        $CF: begin Arg1.Reg := _ECX; Arg2.Reg := _EDI; end;

        $D1: begin Arg1.Reg := _EDX; Arg2.Reg := _ECX; end;
        $D2: begin Arg1.Reg := _EDX; Arg2.Reg := _EDX; end;
        $D3: begin Arg1.Reg := _EDX; Arg2.Reg := _EBX; end;
        $D4: begin Arg1.Reg := _EDX; Arg2.Reg := _ESP; end;
        $D5: begin Arg1.Reg := _EDX; Arg2.Reg := _EBP; end;
        $D6: begin Arg1.Reg := _EDX; Arg2.Reg := _ESI; end;
        $D7: begin Arg1.Reg := _EDX; Arg2.Reg := _EDI; end;

        $D9: begin Arg1.Reg := _EBX; Arg2.Reg := _ECX; end;
        $DA: begin Arg1.Reg := _EBX; Arg2.Reg := _EDX; end;
        $DB: begin Arg1.Reg := _EBX; Arg2.Reg := _EBX; end;
        $DC: begin Arg1.Reg := _EBX; Arg2.Reg := _ESP; end;
        $DD: begin Arg1.Reg := _EBX; Arg2.Reg := _EBP; end;
        $DE: begin Arg1.Reg := _EBX; Arg2.Reg := _ESI; end;
        $DF: begin Arg1.Reg := _EBX; Arg2.Reg := _EDI; end;
      else
        RaiseError(errInternalError, []);
      end;
    end;

    // FLD|FSTP REG
    $DD:
    begin
      Length := 2;
      P := ShiftPointer(P, 1);
      B := Byte(P^);

      Arg1.Ptr := true;
      Arg1.sz := 8;

      Arg2.valid := false;
      case B of
        $00: begin Op := ASM_FLD; Arg1.Reg := _EAX; end;
        $01: begin Op := ASM_FLD; Arg1.Reg := _ECX; end;
        $02: begin Op := ASM_FLD; Arg1.Reg := _EDX; end;
        $03: begin Op := ASM_FLD; Arg1.Reg := _EBX; end;

        $18: begin Op := ASM_FSTP; Arg1.Reg := _EAX; end;
        $19: begin Op := ASM_FSTP; Arg1.Reg := _ECX; end;
        $1A: begin Op := ASM_FSTP; Arg1.Reg := _EDX; end;
        $1B: begin Op := ASM_FSTP; Arg1.Reg := _EBX; end;

        $80:
        begin
          Length := 6;
          Op := ASM_FLD;
          Arg1.Reg := _EAX;
          P := ShiftPointer(P, 1);
          Move(P^, Arg1.val, 4);
        end;

        $81:
        begin
          Length := 6;
          Op := ASM_FLD;
          Arg1.Reg := _ECX;
          P := ShiftPointer(P, 1);
          Move(P^, Arg1.val, 4);
        end;

        $82:
        begin
          Length := 6;
          Op := ASM_FLD;
          Arg1.Reg := _EDX;
          P := ShiftPointer(P, 1);
          Move(P^, Arg1.val, 4);
        end;

        $83:
        begin
          Length := 6;
          Op := ASM_FLD;
          Arg1.Reg := _EBX;
          P := ShiftPointer(P, 1);
          Move(P^, Arg1.val, 4);
        end;

        $85:
        begin
          Length := 6;
          Op := ASM_FLD;
          Arg1.Reg := _EBP;
          P := ShiftPointer(P, 1);
          Move(P^, Arg1.val, 4);
        end;

        $86:
        begin
          Length := 6;
          Op := ASM_FLD;
          Arg1.Reg := _ESI;
          P := ShiftPointer(P, 1);
          Move(P^, Arg1.val, 4);
        end;

        $98:
        begin
          Length := 6;
          Op := ASM_FSTP;
          Arg1.Reg := _EAX;
          P := ShiftPointer(P, 1);
          Move(P^, Arg1.val, 4);
        end;

        $99:
        begin
          Length := 6;
          Op := ASM_FSTP;
          Arg1.Reg := _ECX;
          P := ShiftPointer(P, 1);
          Move(P^, Arg1.val, 4);
        end;

        $9A:
        begin
          Length := 6;
          Op := ASM_FSTP;
          Arg1.Reg := _EDX;
          P := ShiftPointer(P, 1);
          Move(P^, Arg1.val, 4);
        end;

        $9B:
        begin
          Length := 6;
          Op := ASM_FSTP;
          Arg1.Reg := _EBX;
          P := ShiftPointer(P, 1);
          Move(P^, Arg1.val, 4);
        end;

        $9D:
        begin
          Length := 6;
          Op := ASM_FSTP;
          Arg1.Reg := _EBP;
          P := ShiftPointer(P, 1);
          Move(P^, Arg1.val, 4);
        end;

        $9E:
        begin
          Length := 6;
          Op := ASM_FSTP;
          Arg1.Reg := _ESI;
          P := ShiftPointer(P, 1);
          Move(P^, Arg1.val, 4);
        end;

      else
        RaiseError(errInternalError, []);
      end;
    end;

    // FILD REG PTR32
    $DB:
    begin
      P := ShiftPointer(P, 1);
      B := Byte(P^);

      if B in [$00..$03] then
      begin
        Op := ASM_FILD;
        Length := 2;
        Arg1.Ptr := true;
        Arg1.sz := 4;

        Arg2.valid := false;
        case B of
          $00: Arg1.Reg := _EAX;
          $01: Arg1.Reg := _ECX;
          $02: Arg1.Reg := _EDX;
          $03: Arg1.Reg := _EBX;
        end;
      end
      else if B in [$28..$2B] then // Fld TBYTE PTR [REG]
      begin
        Op := ASM_FLD;
        Length := 2;
        Arg1.Ptr := true;
        Arg1.sz := 10;
        case B of
          $28: Arg1.Reg := _EAX;
          $29: Arg1.Reg := _ECX;
          $2A: Arg1.Reg := _EDX;
          $2B: Arg1.Reg := _EBX;
        end;
        Arg2.valid := false;
      end
      else if B in [$38..$3B] then // FStp TBYTE PTR [REG]
      begin
        Op := ASM_FSTP;
        Length := 2;
        Arg1.Ptr := true;
        Arg1.sz := 10;
        case B of
          $38: Arg1.Reg := _EAX;
          $39: Arg1.Reg := _ECX;
          $3A: Arg1.Reg := _EDX;
          $3B: Arg1.Reg := _EBX;
        end;
        Arg2.valid := false;
      end
      else if B in [$A8..$AE] then
      begin
        Op := ASM_FLD; // Fld TBYTE PTR [REG + Shift]
        Length := 6;
        Arg1.Ptr := true;
        Arg1.sz := 10;
        case B of
          $A8: Arg1.Reg := _EAX;
          $A9: Arg1.Reg := _ECX;
          $AA: Arg1.Reg := _EDX;
          $AB: Arg1.Reg := _EBX;
          $AD: Arg1.Reg := _EBP;
          $AE: Arg1.Reg := _ESP;
        end;
        P := ShiftPointer(P, 1);
        Move(P^, Arg1.val, 4);

        Arg2.valid := false;
      end
      else if B in [$B8..$BE] then
      begin
        Op := ASM_FSTP; // FSTP TBYTE PTR [REG + Shift]
        Length := 6;
        Arg1.Ptr := true;
        Arg1.sz := 10;
        case B of
          $B8: Arg1.Reg := _EAX;
          $B9: Arg1.Reg := _ECX;
          $BA: Arg1.Reg := _EDX;
          $BB: Arg1.Reg := _EBX;
          $BD: Arg1.Reg := _EBP;
          $BE: Arg1.Reg := _ESP;
        end;
        P := ShiftPointer(P, 1);
        Move(P^, Arg1.val, 4);

        Arg2.valid := false;
      end
      else
        RaiseError(errInternalError, []);
    end;

    // FADD, DSUB, FMUL, FDIV REG
    $DC:
    begin
      Length := 2;
      P := ShiftPointer(P, 1);
      B := Byte(P^);

      Arg1.Ptr := true;
      Arg1.sz := 8;

      Arg2.valid := false;
      case B of
        $00: begin Op := ASM_FADD; Arg1.Reg := _EAX; end;
        $01: begin Op := ASM_FADD; Arg1.Reg := _ECX; end;
        $02: begin Op := ASM_FADD; Arg1.Reg := _EDX; end;
        $03: begin Op := ASM_FADD; Arg1.Reg := _EBX; end;

        $20: begin Op := ASM_FSUB; Arg1.Reg := _EAX; end;
        $21: begin Op := ASM_FSUB; Arg1.Reg := _ECX; end;
        $22: begin Op := ASM_FSUB; Arg1.Reg := _EDX; end;
        $23: begin Op := ASM_FSUB; Arg1.Reg := _EBX; end;

        $08: begin Op := ASM_FMUL; Arg1.Reg := _EAX; end;
        $09: begin Op := ASM_FMUL; Arg1.Reg := _ECX; end;
        $0A: begin Op := ASM_FMUL; Arg1.Reg := _EDX; end;
        $0B: begin Op := ASM_FMUL; Arg1.Reg := _EBX; end;

        $30: begin Op := ASM_FDIV; Arg1.Reg := _EAX; end;
        $31: begin Op := ASM_FDIV; Arg1.Reg := _ECX; end;
        $32: begin Op := ASM_FDIV; Arg1.Reg := _EDX; end;
        $33: begin Op := ASM_FDIV; Arg1.Reg := _EBX; end;
      else
        RaiseError(errInternalError, []);
      end;
    end;

    // FCOMP
    $D8:
    begin
      Op := ASM_FCOMP;
      Length := 2;
      P := ShiftPointer(P, 1);
      B := Byte(P^);

      Arg1.Ptr := true;
      Arg1.sz := 8;

      Arg2.valid := false;

      if B = $8E then
      begin
        Length := 6;
        P := ShiftPointer(P, 1);
        Op := ASM_FMUL;
        Arg1.sz := 4;
        Arg1.Reg := _ESI;
        Move(P^, Arg1.val, 4);
        Exit;
      end
      else if B = $B6 then
      begin
        Length := 6;
        P := ShiftPointer(P, 1);
        Op := ASM_FDIV;
        Arg1.sz := 4;
        Arg1.Reg := _ESI;
        Move(P^, Arg1.val, 4);
        Exit;
      end;

      case B of
        $18: Arg1.Reg := _EAX;
        $19: Arg1.Reg := _ECX;
        $1A: Arg1.Reg := _EDX;
        $1B: Arg1.Reg := _EBX;
      else
        RaiseError(errInternalError, []);
      end;
    end;

    // FSTSV
    $DF:
    begin
      Length := 2;
      P := ShiftPointer(P, 1);
      B := Byte(P^);

      if B in [$00..$03] then
      begin
        Op := ASM_FILD;
        Length := 2;
        Arg1.Ptr := true;
        Arg1.sz := 2;

        Arg2.valid := false;
        case B of
          $00: Arg1.Reg := _EAX;
          $01: Arg1.Reg := _ECX;
          $02: Arg1.Reg := _EDX;
          $03: Arg1.Reg := _EBX;
        end;
        Exit;
      end
      else if B in [$28..$2B] then
      begin
        Op := ASM_FILD;
        Arg1.Ptr := true;
        Arg1.sz := 8;
        Arg2.valid := false;
        case B of
          $28: Arg1.Reg := _EAX;
          $29: Arg1.Reg := _ECX;
          $2A: Arg1.Reg := _EDX;
          $2B: Arg1.Reg := _EBX;
        else
          RaiseError(errInternalError, []);
        end;
        Exit;
      end
      else if B in [$38..$3B] then
      begin
        Op := ASM_FISTP;
        Arg1.Ptr := true;
        Arg1.sz := 8;
        Arg2.valid := false;
        case B of
          $38: Arg1.Reg := _EAX;
          $39: Arg1.Reg := _ECX;
          $3A: Arg1.Reg := _EDX;
          $3B: Arg1.Reg := _EBX;
        else
          RaiseError(errInternalError, []);
        end;
        Exit;
      end;

      Op := ASM_FSTSV;
      Arg1.sz := 2;
      Arg2.valid := false;
      case B of
        $E0: Arg1.Reg := _EAX;
      else
        RaiseError(errInternalError, []);
      end;
    end; // $DF

    $9E: //SAHF
    begin
      op := ASM_SAHF;
      Length := 1;
      Arg1.valid := false;
      Arg2.valid := false;
    end;

    $99: //CDQ
    begin
      op := ASM_CDQ;
      Length := 1;
      Arg1.valid := false;
      Arg2.valid := false;
    end;

    // FADD, FSUB, FMUL, FDIV, FCOMPP
    $DE:
    begin
      Length := 2;
      P := ShiftPointer(P, 1);
      B := Byte(P^);
      case B of
        $C1: op := ASM_FADD;
        $C9: op := ASM_FMUL;
        $D9: op := ASM_FCOMPP;
        $E9: op := ASM_FSUB;
        $F9: op := ASM_FDIV;
      else
        RaiseError(errInternalError, []);
      end;

      Arg1.valid := false;
      Arg2.valid := false;
    end;

    // FCHS
    $D9:
    begin
      Length := 2;
      P := ShiftPointer(P, 1);
      B := Byte(P^);
      case B of
        $E0: op := ASM_FCHS;
        $E1: op := ASM_FABS;
      else
        begin
          // FLD|FSTP (Single) REG
          Arg1.Ptr := true;
          Arg1.sz := 4;
          Arg2.valid := false;
          case B of
            $00: begin Op := ASM_FLD; Arg1.Reg := _EAX; end;
            $01: begin Op := ASM_FLD; Arg1.Reg := _ECX; end;
            $02: begin Op := ASM_FLD; Arg1.Reg := _EDX; end;
            $03: begin Op := ASM_FLD; Arg1.Reg := _EBX; end;

            $18: begin Op := ASM_FSTP; Arg1.Reg := _EAX; end;
            $19: begin Op := ASM_FSTP; Arg1.Reg := _ECX; end;
            $1A: begin Op := ASM_FSTP; Arg1.Reg := _EDX; end;
            $1B: begin Op := ASM_FSTP; Arg1.Reg := _EBX; end;

            $80:
            begin
              Length := 6;
              Op := ASM_FLD;
              Arg1.Reg := _EAX;
              P := ShiftPointer(P, 1);
              Move(P^, Arg1.val, 4);
            end;

            $81:
            begin
              Length := 6;
              Op := ASM_FLD;
              Arg1.Reg := _ECX;
              P := ShiftPointer(P, 1);
              Move(P^, Arg1.val, 4);
            end;

            $82:
            begin
              Length := 6;
              Op := ASM_FLD;
              Arg1.Reg := _EDX;
              P := ShiftPointer(P, 1);
              Move(P^, Arg1.val, 4);
            end;

            $83:
            begin
              Length := 6;
              Op := ASM_FLD;
              Arg1.Reg := _EBX;
              P := ShiftPointer(P, 1);
              Move(P^, Arg1.val, 4);
            end;

            $85:
            begin
              Length := 6;
              Op := ASM_FLD;
              Arg1.Reg := _EBP;
              P := ShiftPointer(P, 1);
              Move(P^, Arg1.val, 4);
            end;

            $86:
            begin
              Length := 6;
              Op := ASM_FLD;
              Arg1.Reg := _ESI;
              P := ShiftPointer(P, 1);
              Move(P^, Arg1.val, 4);
            end;

            $98:
            begin
              Length := 6;
              Op := ASM_FSTP;
              Arg1.Reg := _EAX;
              P := ShiftPointer(P, 1);
              Move(P^, Arg1.val, 4);
            end;

            $99:
            begin
              Length := 6;
              Op := ASM_FSTP;
              Arg1.Reg := _ECX;
              P := ShiftPointer(P, 1);
              Move(P^, Arg1.val, 4);
            end;

            $9A:
            begin
              Length := 6;
              Op := ASM_FSTP;
              Arg1.Reg := _EDX;
              P := ShiftPointer(P, 1);
              Move(P^, Arg1.val, 4);
            end;

            $9B:
            begin
              Length := 6;
              Op := ASM_FSTP;
              Arg1.Reg := _EBX;
              P := ShiftPointer(P, 1);
              Move(P^, Arg1.val, 4);
            end;

            $9D:
            begin
              Length := 6;
              Op := ASM_FSTP;
              Arg1.Reg := _EBP;
              P := ShiftPointer(P, 1);
              Move(P^, Arg1.val, 4);
            end;

            $9E:
            begin
              Length := 6;
              Op := ASM_FSTP;
              Arg1.Reg := _ESI;
              P := ShiftPointer(P, 1);
              Move(P^, Arg1.val, 4);
            end;
          else
            RaiseError(errInternalError, []);
          end;
          Exit;
        end;
      end;

      Arg1.valid := false;
      Arg2.valid := false;
    end;

    // SETL, SETLE, SETNLE, SETNL,
    // SETB, SETBE, SETNBE, SETNB, SETZ, SETNZ
    $0F:
    begin
      Length := 3;
      P := ShiftPointer(P, 1);
      B := Byte(P^);

      case B of
        $92: Op := ASM_SETB;
        $93: Op := ASM_SETNB;
        $94: Op := ASM_SETZ;
        $95: Op := ASM_SETNZ;
        $96: Op := ASM_SETBE;
        $97: Op := ASM_SETNBE;
        $9C: Op := ASM_SETL;
        $9D: Op := ASM_SETNL;
        $9E: Op := ASM_SETLE;
        $9F: Op := ASM_SETNLE;
      else
        RaiseError(errInternalError, []);
      end;

      P := ShiftPointer(P, 1);
      B := Byte(P^);

      Arg1.Ptr := true;
      Arg1.sz := 1;

      Arg2.valid := false;
      case B of
        $00: Arg1.Reg := _EAX;
        $01: Arg1.Reg := _ECX;
        $02: Arg1.Reg := _EDX;
        $03: Arg1.Reg := _EBX;

        $80..$86:
        begin
          case B of
            $80: Arg1.Reg := _EAX;
            $81: Arg1.Reg := _ECX;
            $82: Arg1.Reg := _EDX;
            $83: Arg1.Reg := _EBX;
            $84: Arg1.Reg := _ESP;
            $85: Arg1.Reg := _EBP;
            $86: Arg1.Reg := _ESI;
          end;

          Length := 7;
          P := ShiftPointer(P, 1);
          Move(P^, Arg1.val, 4);
        end;
      else
        RaiseError(errInternalError, []);
      end;
    end;

    $80:
    begin
      Arg1.sz := 1;
      Arg1.Ptr := true;

      P := ShiftPointer(P, 1);
      B := Byte(P^);

      case B of
        $80..$86: // ADD BYTE PTR [REG + Shift], imm
        begin
          Op := ASM_ADD;
          Length := 7;

          case B of
            $80: Arg1.Reg := _EAX;
            $81: Arg1.Reg := _ECX;
            $82: Arg1.Reg := _EDX;
            $83: Arg1.Reg := _EBX;
            $84: Arg1.Reg := _ESP;
            $85: Arg1.Reg := _EBP;
            $86: Arg1.Reg := _ESI;
          end;

          P := ShiftPointer(P, 1);
          Move(P^, Arg1.val, 4);

          P := ShiftPointer(P, 4);
          B := Byte(P^);
          Arg2.val := B;
        end;

        $B8..$BE: // CMP BYTE PTR [REG + Shift], imm
        begin
          Op := ASM_CMP;
          Length := 7;

          case B of
            $B8: Arg1.Reg := _EAX;
            $B9: Arg1.Reg := _ECX;
            $BA: Arg1.Reg := _EDX;
            $BB: Arg1.Reg := _EBX;
            $BC: Arg1.Reg := _ESP;
            $BD: Arg1.Reg := _EBP;
            $BE: Arg1.Reg := _ESI;
          end;

          P := ShiftPointer(P, 1);
          Move(P^, Arg1.val, 4);

          P := ShiftPointer(P, 4);
          B := Byte(P^);
          Arg2.val := B;
        end;

        $38..$3B: // CMP BYTE PTR [REG], imm
        begin
          op := ASM_CMP;
          Length := 3;
          case B of
            $38: Arg1.Reg := _EAX;
            $39: Arg1.Reg := _ECX;
            $3A: Arg1.Reg := _EDX;
            $3B: Arg1.Reg := _EBX;
          end;

          P := ShiftPointer(P, 1);
          B := Byte(P^);
          Arg2.val := B;
        end;
        else
          RaiseError(errInternalError, []);
      end;
    end;

    $E9:
    begin
      op := ASM_JMP;
      Length := 5;
      Arg2.valid := false;
      P := ShiftPointer(P, 1);
      Move(P^, Arg1.val, 4);
    end;

    $2D:
    begin
      op := ASM_SUB;
      Length := 5;
      Arg1.Reg := _EAX;
      P := ShiftPointer(P, 1);
      Move(P^, Arg2.val, 4);
    end;

    $3D:
    begin
      op := ASM_CMP;
      Length := 5;
      Arg1.Reg := _EAX;
      P := ShiftPointer(P, 1);
      Move(P^, Arg2.val, 4);
    end;

    // CALL REG| JMP REG| PUSH REGPtr
    $FF:
    begin
      Length := 2;
      Arg2.valid := false;
      P := ShiftPointer(P, 1);
      B := Byte(P^);

      case B of
        $E0: begin Op := ASM_JMP; Arg1.Reg := _EAX; end;
        $E1: begin Op := ASM_JMP; Arg1.Reg := _ECX; end;
        $E2: begin Op := ASM_JMP; Arg1.Reg := _EDX; end;
        $E3: begin Op := ASM_JMP; Arg1.Reg := _EBX; end;

        $D0: begin Op := ASM_CALL; Arg1.Reg := _EAX; end;
        $D1: begin Op := ASM_CALL; Arg1.Reg := _ECX; end;
        $D2: begin Op := ASM_CALL; Arg1.Reg := _EDX; end;
        $D3: begin Op := ASM_CALL; Arg1.Reg := _EBX; end;

        $30: begin Op := ASM_PUSH; Arg1.Ptr := true; Arg1.sz := 4; Arg1.Reg := _EAX; end;
        $31: begin Op := ASM_PUSH; Arg1.Ptr := true; Arg1.sz := 4; Arg1.Reg := _ECX; end;
        $32: begin Op := ASM_PUSH; Arg1.Ptr := true; Arg1.sz := 4; Arg1.Reg := _EDX; end;
        $33: begin Op := ASM_PUSH; Arg1.Ptr := true; Arg1.sz := 4; Arg1.Reg := _EBX; end;
      else
        RaiseError(errInternalError, []);
      end;
    end;

    // PUSH Imm
    $68:
    begin
      Op := ASM_PUSH;
      Length := 5;

      P := ShiftPointer(P, 1);
      Move(P^, Arg1.val, 4);

      Arg2.valid := false;
    end;

    $84:
    begin
      Op := ASM_TEST;
      Length := 2;
      Arg1.sz := 1;
      Arg1.sz := 1;
      P := ShiftPointer(P, 1);
      B := Byte(P^);
      case B of
        $D2: begin Arg1.Reg := _EDX; Arg2.Reg := _EDX; end;
      else
        RaiseError(errInternalError, []);
      end;
    end;

    // PUSH REG | POP REG
    $50..$57, $58..$5F:
    begin
      Length := 1;
      Arg2.valid := false;

      case B of
        $50: begin Op := ASM_PUSH; Arg1.Reg := _EAX; end;
        $51: begin Op := ASM_PUSH; Arg1.Reg := _ECX; end;
        $52: begin Op := ASM_PUSH; Arg1.Reg := _EDX; end;
        $53: begin Op := ASM_PUSH; Arg1.Reg := _EBX; end;
        $54: begin Op := ASM_PUSH; Arg1.Reg := _ESP; end;
        $55: begin Op := ASM_PUSH; Arg1.Reg := _EBP; end;
        $56: begin Op := ASM_PUSH; Arg1.Reg := _ESI; end;
        $57: begin Op := ASM_PUSH; Arg1.Reg := _EDI; end;

        $58: begin Op := ASM_POP; Arg1.Reg := _EAX; end;
        $59: begin Op := ASM_POP; Arg1.Reg := _ECX; end;
        $5A: begin Op := ASM_POP; Arg1.Reg := _EDX; end;
        $5B: begin Op := ASM_POP; Arg1.Reg := _EBX; end;
        $5C: begin Op := ASM_POP; Arg1.Reg := _ESP; end;
        $5D: begin Op := ASM_POP; Arg1.Reg := _EBP; end;
        $5E: begin Op := ASM_POP; Arg1.Reg := _ESI; end;
        $5F: begin Op := ASM_POP; Arg1.Reg := _EDI; end;
      else
        RaiseError(errInternalError, []);
      end;
    end;

    $C6:
    begin
      Arg1.sz := 1;
      Arg1.Ptr := true;

      P := ShiftPointer(P, 1);
      B := Byte(P^);

      case B of
        $00..$06: // MOV BYTE PTR [REG], imm
        begin
          Op := ASM_MOV;
          Length := 3;
          case B of
            $00: Arg1.Reg := _EAX;
            $01: Arg1.Reg := _ECX;
            $02: Arg1.Reg := _EDX;
            $03: Arg1.Reg := _EBX;
            $04: Arg1.Reg := _ESP;
            $05: Arg1.Reg := _EBP;
            $06: Arg1.Reg := _ESI;
          end;
          P := ShiftPointer(P, 1);
          B := Byte(P^);

          Arg2.val := B;
        end;

        $80..$86: // MOV BYTE PTR [REG + Shift], imm
        begin
          Op := ASM_MOV;
          Length := 7;

          case B of
            $80: Arg1.Reg := _EAX;
            $81: Arg1.Reg := _ECX;
            $82: Arg1.Reg := _EDX;
            $83: Arg1.Reg := _EBX;
            $84: Arg1.Reg := _ESP;
            $85: Arg1.Reg := _EBP;
            $86: Arg1.Reg := _ESI;
          end;

          P := ShiftPointer(P, 1);
          Move(P^, Arg1.val, 4);

          P := ShiftPointer(P, 4);
          B := Byte(P^);
          Arg2.val := B;
        end;
        else
          RaiseError(errInternalError, []);
      end;
    end;

    $C7:
    begin
      Arg1.sz := 4;
      Arg1.Ptr := true;

      P := ShiftPointer(P, 1);
      B := Byte(P^);

      case B of
        $00..$06: // MOV DWORD PTR [REG], imm
        begin
          Op := ASM_MOV;

          case B of
            $00: Arg1.Reg := _EAX;
            $01: Arg1.Reg := _ECX;
            $02: Arg1.Reg := _EDX;
            $03: Arg1.Reg := _EBX;
            $04: Arg1.Reg := _ESP;
            $05: Arg1.Reg := _EBP;
            $06: Arg1.Reg := _ESI;
          else
            RaiseError(errInternalError, []);
          end;

          Length := 6;

          P := ShiftPointer(P, 1);
          Move(P^, Arg2.val, 4);
        end;

        $80..$86: // MOV DWORD PTR [REG + Shift], imm
        begin
          Op := ASM_MOV;
          Length := 10;

          case B of
            $80: Arg1.Reg := _EAX;
            $81: Arg1.Reg := _ECX;
            $82: Arg1.Reg := _EDX;
            $83: Arg1.Reg := _EBX;
            $84: Arg1.Reg := _ESP;
            $85: Arg1.Reg := _EBP;
            $86: Arg1.Reg := _ESI;
          end;

          P := ShiftPointer(P, 1);
          Move(P^, Arg1.val, 4);

          P := ShiftPointer(P, 4);
          Move(P^, Arg2.val, 4);
        end;
        else
          RaiseError(errInternalError, []);
      end;
    end;

    $66:
    begin
      P := ShiftPointer(P, 1);
      B := Byte(P^);
      case B of
      
        $50..$53: // PUSH REG16
        begin
          Op := ASM_PUSH;
          Length := 2;
          Arg1.sz := 2;
          case B of
            $50: Arg1.Reg := _EAX;
            $51: Arg1.Reg := _ECX;
            $52: Arg1.Reg := _EDX;
            $53: Arg1.Reg := _EBX;
          end;
          Arg2.valid := false;
        end;

        $C7: // MOV WORD PTR [REG], Imm
        begin
          Op := ASM_MOV;
          Length := 9;
          Arg1.Ptr := true;
          Arg1.sz := 2;

          P := ShiftPointer(P, 1);
          B := Byte(P^);
          case B of
            $80: Arg1.Reg := _EAX;
            $81: Arg1.Reg := _ECX;
            $82: Arg1.Reg := _EDX;
            $83: Arg1.Reg := _EBX;
            $84: Arg1.Reg := _ESP;
            $85: Arg1.Reg := _EBP;
            $86: Arg1.Reg := _ESI;
          else
            RaiseError(errInternalError, []);
          end;
          P := ShiftPointer(P, 1);
          Move(P^, Arg1.val, 4);
          P := ShiftPointer(P, 4);
          Move(P^, Arg2.val, 2);
        end;
        $81:
        begin
          Length := 9;
          Arg1.Ptr := true;
          Arg1.sz := 2;

          P := ShiftPointer(P, 1);
          B := Byte(P^);

          case B of
            $80..$86: // ADD WORD PTR [REG], Imm
            begin
              Op := ASM_ADD;
              case B of
                $80: Arg1.Reg := _EAX;
                $81: Arg1.Reg := _ECX;
                $82: Arg1.Reg := _EDX;
                $83: Arg1.Reg := _EBX;
                $84: Arg1.Reg := _ESP;
                $85: Arg1.Reg := _EBP;
                $86: Arg1.Reg := _ESI;
              end;
            end;
            $B8..$BE: // WORD PTR [REG], Imm
            begin
              Op := ASM_CMP;
              case B of
                $B8: Arg1.Reg := _EAX;
                $B9: Arg1.Reg := _ECX;
                $BA: Arg1.Reg := _EDX;
                $BB: Arg1.Reg := _EBX;
                $BC: Arg1.Reg := _ESP;
                $BD: Arg1.Reg := _EBP;
                $BE: Arg1.Reg := _ESI;
              end;
            end;
            else
              RaiseError(errInternalError, []);
          end;
          P := ShiftPointer(P, 1);
          Move(P^, Arg1.val, 4);
          P := ShiftPointer(P, 4);
          Move(P^, Arg2.val, 2);
        end;
        $8B: // MOV Reg16, WORD PTR [REG]
        begin
          Op := ASM_MOV;
          Length := 3;
          Arg1.sz := 2;
          Arg2.sz := 2;

          P := ShiftPointer(P, 1);
          B := Byte(P^);
          case B of
            $86, $8E, $96, $9E: // MOV Reg16, WORD PTR [ESI + Shift]
            begin
              Length := 7;
              case B of
                $86: Arg1.Reg := _EAX;
                $8E: Arg1.Reg := _ECX;
                $96: Arg1.Reg := _EDX;
                $9E: Arg1.Reg := _EBX;
              end;
              Arg2.Reg := _ESI;
              Arg2.Ptr := true;
              P := ShiftPointer(P, 1);
              Move(P^, Arg2.Val, 4);
            end;
            $85, $8D, $95, $9D: // MOV Reg16, WORD PTR [EBP + Shift]
            begin
              Length := 7;
              case B of
                $85: Arg1.Reg := _EAX;
                $8D: Arg1.Reg := _ECX;
                $95: Arg1.Reg := _EDX;
                $9D: Arg1.Reg := _EBX;
              end;
              Arg2.Reg := _EBP;
              Arg2.Ptr := true;
              P := ShiftPointer(P, 1);
              Move(P^, Arg2.Val, 4);
            end;
            // MOV Reg16, WORD PTR [REG]
            $00: begin Arg1.Reg := _EAX; Arg2.Reg := _EAX; end;
            $01: begin Arg1.Reg := _EAX; Arg2.Reg := _ECX; end;
            $02: begin Arg1.Reg := _EAX; Arg2.Reg := _EDX; end;
            $03: begin Arg1.Reg := _EAX; Arg2.Reg := _EBX; end;

            $08: begin Arg1.Reg := _ECX; Arg2.Reg := _EAX; end;
            $09: begin Arg1.Reg := _ECX; Arg2.Reg := _ECX; end;
            $0A: begin Arg1.Reg := _ECX; Arg2.Reg := _EDX; end;
            $0B: begin Arg1.Reg := _ECX; Arg2.Reg := _EBX; end;

            $10: begin Arg1.Reg := _EDX; Arg2.Reg := _EAX; end;
            $11: begin Arg1.Reg := _EDX; Arg2.Reg := _ECX; end;
            $12: begin Arg1.Reg := _EDX; Arg2.Reg := _EDX; end;
            $13: begin Arg1.Reg := _EDX; Arg2.Reg := _EBX; end;

            $18: begin Arg1.Reg := _EBX; Arg2.Reg := _EAX; end;
            $19: begin Arg1.Reg := _EBX; Arg2.Reg := _ECX; end;
            $1A: begin Arg1.Reg := _EBX; Arg2.Reg := _EDX; end;
            $1B: begin Arg1.Reg := _EBX; Arg2.Reg := _EBX; end;
          else
            RaiseError(errInternalError, []);
          end;

          Arg2.Ptr := true;
        end;
        $89: // MOVE WORD PTR [Reg], Reg16
        begin
          Op := ASM_MOV;
          Arg1.Ptr := true;
          Arg1.sz := 2;
          Arg2.sz := 2;
          Length := 3;

          P := ShiftPointer(P, 1);
          B := Byte(P^);

          case B of
            $86, $8E, $96, $9E: // MOV WORD PTR [ESI + Shift], Reg16
            begin
              Length := 7;
              case B of
                $86: Arg2.Reg := _EAX;
                $8E: Arg2.Reg := _ECX;
                $96: Arg2.Reg := _EDX;
                $9E: Arg2.Reg := _EBX;
              end;
              Arg1.Reg := _ESI;
              P := ShiftPointer(P, 1);
              Move(P^, Arg1.Val, 4);
            end;
            $85, $8D, $95, $9D: // MOV WORD PTR [EBP + Shift], Reg16
            begin
              Length := 7;
              case B of
                $85: Arg2.Reg := _EAX;
                $8D: Arg2.Reg := _ECX;
                $95: Arg2.Reg := _EDX;
                $9D: Arg2.Reg := _EBX;
              end;
              Arg1.Reg := _EBP;
              P := ShiftPointer(P, 1);
              Move(P^, Arg1.Val, 4);
            end;
            $00: begin Arg1.Reg := _EAX; Arg2.Reg := _EAX; end;
            $08: begin Arg1.Reg := _EAX; Arg2.Reg := _ECX; end;
            $10: begin Arg1.Reg := _EAX; Arg2.Reg := _EDX; end;
            $18: begin Arg1.Reg := _EAX; Arg2.Reg := _EBX; end;

            $01: begin Arg1.Reg := _ECX; Arg2.Reg := _EAX; end;
            $09: begin Arg1.Reg := _ECX; Arg2.Reg := _ECX; end;
            $11: begin Arg1.Reg := _ECX; Arg2.Reg := _EDX; end;
            $19: begin Arg1.Reg := _ECX; Arg2.Reg := _EBX; end;

            $02: begin Arg1.Reg := _EDX; Arg2.Reg := _EAX; end;
            $0A: begin Arg1.Reg := _EDX; Arg2.Reg := _ECX; end;
            $12: begin Arg1.Reg := _EDX; Arg2.Reg := _EDX; end;
            $1A: begin Arg1.Reg := _EDX; Arg2.Reg := _EBX; end;

            $03: begin Arg1.Reg := _EBX; Arg2.Reg := _EAX; end;
            $0B: begin Arg1.Reg := _EBX; Arg2.Reg := _ECX; end;
            $13: begin Arg1.Reg := _EBX; Arg2.Reg := _EDX; end;
            $1B: begin Arg1.Reg := _EBX; Arg2.Reg := _EBX; end;
          else
            RaiseError(errInternalError, []);
          end;
        end;
      end;
    end;

  else
    RaiseError(errInternalError, []);
  end; // case
end;

end.


