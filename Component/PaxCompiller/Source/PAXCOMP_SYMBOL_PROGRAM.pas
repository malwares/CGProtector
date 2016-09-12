////////////////////////////////////////////////////////////////////////////
// PaxCompiler
// Site: http://www.paxcompiler.com
// Author: Alexander Baranovsky (paxscript@gmail.com)
// ========================================================================
// Copyright (c) Alexander Baranovsky, 2006-2008. All rights reserved.
// Code Version: 2.4
// ========================================================================
// Unit: PAXCOMP_SYMBOL_PROGRAM.pas
// ========================================================================
////////////////////////////////////////////////////////////////////////////

{$I PaxCompiler.def}
{$R-}

unit PAXCOMP_SYMBOL_PROGRAM;
interface

uses
{$IFDEF VARIANTS}
  Variants,
{$ENDIF}
  SysUtils,
  Classes,
  PAXCOMP_CONSTANTS,
  PAXCOMP_SYS,
  PAXCOMP_PROG,
  PAXCOMP_SYMBOL_REC,
  PAXCOMP_BASESYMBOL_TABLE,
  PAXCOMP_SYMBOL_TABLE,
  PAXCOMP_BYTECODE,
  PAXCOMP_MODULE,
  PAXCOMP_CLASSLST,
  PAXCOMP_TRYLST,
  PAXCOMP_RTI,
  PAXCOMP_DISASM,
  PAXCOMP_STDLIB;
type
  TSymbolProgRec = class
  private
    fLabelId: Integer;
    procedure SetLabelId(value: Integer);
  public
    Op: Integer;
    Arg1, Arg2: TArg;
    Size: Integer;
    code: array[0..10] of byte;
    Comment: String;
    SaveSubId: Integer;
    ShiftValue: Integer;
    Z: Boolean;

    ProgOffset: Integer;
    MustBeFixed: Boolean;
    OpOffset: Integer;
    SubId: Integer;

    constructor Create;
    function ToStr: String;
    procedure Decompile;
    property LabelId: Integer read fLabelId write SetLabelId;
  end;

  TSymbolProg = class(TTypedList)
  private
    function GetRecord(I: Integer): TSymbolProgRec;
    function GetCard: Integer;
    function GetProgSize: Integer;
  public
    kernel: Pointer;
    constructor Create(i_kernel: Pointer);
    function AddRecord: TSymbolProgRec;
    function Top: TSymbolProgRec;
    procedure Optimization;
    procedure Delete(I: Integer);
    function GetOffset(S: TSymbolRec): Integer;

    function AsmComment(const S: String): TSymbolProgRec;

    // requires EmitGetAddressRegister
    // MOV <SIZE> PTR [REG], Imm
    procedure AsmMovREGPtr_Imm(Reg: Integer; S: TSymbolRec; value: Integer);
    // requires EmitGetAddressRegister
    // ADD <SIZE> PTR [REG], Imm
    procedure AsmAddREGPtr_Imm(Reg: Integer; S: TSymbolRec; value: Integer);
    // requires EmitGetAddressRegister
    // CMP <SIZE> PTR [REG], Imm
    procedure AsmCmpREGPtr_Imm(Reg: Integer; S: TSymbolRec; value: Integer);
    // requires EmitGetAddressRegister
    // NEG DWORD PTR [REG + Shift]
    procedure AsmNEG_REGPtr(Reg: Integer; S: TSymbolRec);
    // requires EmitGetAddressRegister
    // Fld QWORD PTR [REG + Shift]
    procedure AsmFldDouble_REGPtr(Reg: Integer; S: TSymbolRec); overload;
    // requires EmitGetAddressRegister
    // FStp QWORD PTR [REG + Shift]
    procedure AsmFstpDouble_REGPtr(Reg: Integer; S: TSymbolRec); overload;
    // requires EmitGetAddressRegister
    // Fld DWORD PTR [REG + Shift]
    procedure AsmFldSingle_REGPtr(Reg: Integer; S: TSymbolRec); overload;
    // requires EmitGetAddressRegister
    // Fld TBYTE PTR [REG + Shift]
    procedure AsmFldExtended_REGPtr(Reg: Integer; S: TSymbolRec); overload;
    // requires EmitGetAddressRegister
    // FStp DWORD PTR [REG + Shift]
    procedure AsmFstpSingle_REGPtr(Reg: Integer; S: TSymbolRec); overload;
    // requires EmitGetAddressRegister
    // FStp TBYTE PTR [REG + Shift]
    procedure AsmFstpExtended_REGPtr(Reg: Integer; S: TSymbolRec); overload;

    function AsmAddREG_Imm(Reg: Integer; value: Integer): TSymbolProgRec;
    procedure AsmSubREG_Imm(Reg: Integer; value: Integer);
    procedure AsmAddREG_REG(Reg1, Reg2: Integer);
    procedure AsmAdcREG_REG(Reg1, Reg2: Integer);
    procedure AsmSbbREG_REG(Reg1, Reg2: Integer);

    procedure AsmMulREG(Reg: Integer);
    procedure AsmIMulREG(Reg: Integer);
    procedure AsmDivREG(Reg: Integer);
    procedure AsmIDivREG(Reg: Integer);
    procedure AsmShlREG(Reg: Integer);
    procedure AsmShrREG(Reg: Integer);

    procedure AsmNegREG(Reg: Integer);

    procedure AsmSubREG_REG(Reg1, Reg2: Integer);
    procedure AsmXorREG_REG(Reg1, Reg2: Integer);
    procedure AsmAndREG_REG(Reg1, Reg2: Integer);
    procedure AsmOrREG_REG(Reg1, Reg2: Integer);

    procedure AsmMovREG_REG(Reg1, Reg2: Integer);
    function AsmMovREG_Imm(Reg: Integer; value: Cardinal): TSymbolProgRec;
    procedure AsmMovREGPtr32_Imm(Reg: Integer; value: Cardinal); overload;
    procedure AsmMovREGPtr32_Imm(Reg, shift, value: Cardinal); overload;

    procedure AsmMovREGPtr_REG32(Reg1, Reg2: Integer);
    procedure AsmMovREGPtr_REG16(Reg1, Reg2: Integer);
    procedure AsmMovREGPtr_REG8(Reg1, Reg2: Integer);

    procedure AsmMovREG32_REGPtr(Reg1, Reg2: Integer);
    procedure AsmMovREG16_REGPtr(Reg1, Reg2: Integer);
    procedure AsmMovREG8_REGPtr(Reg1, Reg2: Integer);

    procedure AsmFldDouble_REGPtr(Reg: Integer); overload;
    procedure AsmFldSingle_REGPtr(Reg: Integer); overload;
    procedure AsmFldExtended_REGPtr(Reg: Integer); overload;

    procedure AsmFild_REG16Ptr(Reg: Integer);
    procedure AsmFild_REG32Ptr(Reg: Integer);
    procedure AsmFild_REG64Ptr(Reg: Integer);

    procedure AsmFistp_REG64Ptr(Reg: Integer);

    procedure AsmFAdd_REGPtr(Reg: Integer);

    procedure AsmWait;

    procedure AsmFAdd;
    procedure AsmFSub;
    procedure AsmFMul;
    procedure AsmFDiv;
    procedure AsmFChs;
    procedure AsmFAbs;
    procedure AsmFSub_REGPtr(Reg: Integer);
    procedure AsmFMul_REGPtr(Reg: Integer);
    procedure AsmFDiv_REGPtr(Reg: Integer);

    procedure AsmFMul_ESIPtr32(Shift: Integer);
    procedure AsmFDiv_ESIPtr32(Shift: Integer);

    procedure AsmFstpDouble_REGPtr(Reg: Integer); overload;
    procedure AsmFstpSingle_REGPtr(Reg: Integer); overload;
    procedure AsmFstpExtended_REGPtr(Reg: Integer); overload;

    procedure AsmFComp_REGPtr(Reg: Integer);
    procedure AsmFCompP;
    procedure AsmFstsw_AX;
    procedure AsmSahv;

    procedure AsmCDQ;

    procedure AsmSet_REGPtr(ASM_OP, Reg: Integer; S: TSymbolRec);

    procedure AsmSetL_REGPtr(Reg: Integer); // <
    procedure AsmSetLE_REGPtr(Reg: Integer); // <=
    procedure AsmSetNLE_REGPtr(Reg: Integer); // >
    procedure AsmSetNL_REGPtr(Reg: Integer); // >=

    procedure AsmSetB_REGPtr(Reg: Integer);
    procedure AsmSetBE_REGPtr(Reg: Integer);
    procedure AsmSetNBE_REGPtr(Reg: Integer);
    procedure AsmSetNB_REGPtr(Reg: Integer);
    procedure AsmSetZ_REGPtr(Reg: Integer);
    procedure AsmSetNZ_REGPtr(Reg: Integer);

    procedure AsmCmpByteREGPtr_Imm(Reg: Integer; value: Byte);
    procedure AsmCmpREG_REG(Reg1, Reg2: Integer);
    procedure AsmCmpREG_Imm(Reg: Integer; Value: Integer);

    procedure AsmTestREG8_REG8(Reg1, Reg2: Integer);

    procedure AsmCmpReg32Ptr_Imm(Reg: Integer; shift: Integer; value: Integer);

    procedure AsmJmp_REG(Reg: Integer);
    procedure AsmCall_REG(Reg: Integer);
    procedure AsmPush_Imm(value: Integer);
    procedure AsmPush_REG(Reg: Integer);
    procedure AsmPush_Reg16(Reg: Integer);

    procedure AsmPop_REG(Reg: Integer);
    procedure AsmPush_REGPtr(Reg: Integer);

    procedure AsmGetREG32_ESIPtr(Reg: Integer; shift: Integer);
    procedure AsmGetREG16_ESIPtr(Reg: Integer; shift: Integer);
    procedure AsmGetREG8_ESIPtr(Reg: Integer; shift: Integer);

    procedure AsmPutREG32_ESIPtr(Reg: Integer; shift: Integer);
    procedure AsmPutREG16_ESIPtr(Reg: Integer; shift: Integer);
    procedure AsmPutREG8_ESIPtr(Reg: Integer; shift: Integer);

    procedure AsmGetREG32_EBPPtr(Reg: Integer; shift: Integer);
    procedure AsmGetREG16_EBPPtr(Reg: Integer; shift: Integer);
    procedure AsmGetREG8_EBPPtr(Reg: Integer; shift: Integer);

    procedure AsmPutREG32_EBPPtr(Reg: Integer; shift: Integer);
    procedure AsmPutREG16_EBPPtr(Reg: Integer; shift: Integer);
    procedure AsmPutREG8_EBPPtr(Reg: Integer; shift: Integer);

    procedure AsmNop;
    procedure AsmClc;
    procedure AsmPushfd;
    procedure AsmPopfd;
    procedure AsmXCHG(Reg1, Reg2: Integer);
    procedure AsmRet(value: Word = 0);
    procedure AsmJMP_Imm(value: Integer);

    procedure AsmJNO_Imm(value: Byte);
    procedure AsmJNC_Imm(value: Byte);
    procedure AsmJBE_Imm(value: Byte);
    procedure AsmJNLE_Imm(value: Byte);

    procedure AsmJZ_Imm(value: Byte);
    procedure AsmJNZ_Imm(value: Byte);

    procedure AsmLeaReg32_RegPtr(Reg1, Reg2: Integer; shift: Integer);

    procedure AsmRep_MOVSB;
    procedure AsmRep_MOVSD;

    procedure AsmLoadESI_ESPPtr(shift: Integer);
    procedure AsmLoadEDI_ESPPtr(shift: Integer);

    procedure CreateProgram(result: TProgram);
    procedure CreateProgramSimple(result: TProgram);

    function GetShiftOfRecord(R: TSymbolProgRec): Integer;
    function GetShiftOfLabel(LabelId: Integer): Integer;
    procedure CreateRTI(aprogram: TProgram);
    procedure CreateZList(P: TProgram);

    procedure RaiseError(const Message: string; params: array of Const);
    procedure CreateError(const Message: string; params: array of Const);
    property Card: Integer read GetCard;
    property ProgSize: Integer read GetProgSize;
    property Records[I: Integer]: TSymbolProgRec read GetRecord; default;
  end;

implementation

uses
  PAXCOMP_KERNEL;


constructor TSymbolProgRec.Create;
begin
  FillChar(code, SizeOf(code), 0);
  Op := 0;
  ClearArg(Arg1);
  ClearArg(Arg2);
  Size := 0;
  LabelId := 0;
  Comment := '';
  SaveSubId := 0;
  ShiftValue := 0;
  Z := false;
end;

procedure TSymbolProgRec.SetLabelId(value: Integer);
begin
  fLabelId := Value;
end;

function TSymbolProgRec.ToStr: String;
var
  I: Integer;
begin
  result := '';
  for I := 0 to Size - 1 do
    result := result + ByteToHex(code[I]);

  if Size = -1 then
    result := AlignLeft('', 25) + Comment
  else
  begin
    if Arg2.valid then
      result := AlignLeft(result, 25) + AsmOperators[Op] + ' ' + ArgToString(Arg1) + ', ' + ArgToString(Arg2)
    else
      result := AlignLeft(result, 25) + AsmOperators[Op] + ' ' + ArgToString(Arg1);
   end;
end;

procedure TSymbolProgRec.Decompile;
var
  S: Integer;
begin
  Decomp(@code, S, Op, Arg1, Arg2);
  if S <> Size then
    raise Exception.Create(errInternalError);
end;

constructor TSymbolProg.Create(i_kernel: Pointer);
begin
  inherited Create;
  Self.kernel := i_kernel;
end;

function TSymbolProg.GetCard: Integer;
begin
  result := L.Count;
end;

function TSymbolProg.GetProgSize: Integer;
var
  I, SZ: Integer;
begin
  result := 0;
  for I:=1 to Card do
  begin
    SZ := Records[I].Size;
    if SZ > 0 then
      result := result + SZ;
  end;
end;

function TSymbolProg.GetShiftOfLabel(LabelId: Integer): Integer;
var
  I, SZ: Integer;
begin
  result := 0;
  for I:=1 to Card do
  begin
    if Records[I].LabelId = LabelId then
      Exit;

    SZ := Records[I].Size;
    if SZ > 0 then
      result := result + SZ;
  end;
  result := -1;
end;

function TSymbolProg.GetShiftOfRecord(R: TSymbolProgRec): Integer;
var
  I, SZ: Integer;
begin
  result := 0;
  for I:=1 to Card do
  begin
    if Records[I] = R then
      Exit;

    SZ := Records[I].Size;
    if SZ > 0 then
      result := result + SZ;
  end;
  result := -1;
end;

function TSymbolProg.AddRecord: TSymbolProgRec;
begin
  result := TSymbolProgRec.Create;
  L.Add(result);
end;

function TSymbolProg.Top: TSymbolProgRec;
begin
  result := Records[Card];
end;

procedure TSymbolProg.Delete(I: Integer);
begin
  Records[I].Free;
  L.Delete(I - 1);
end;

function TSymbolProg.AsmComment(const S: String): TSymbolProgRec;
begin
  result := AddRecord;
  with result do
  begin
    Size := -1;
    Comment := ';' + S;
  end;
end;

function TSymbolProg.AsmMovREG_Imm(Reg: Integer; value: Cardinal): TSymbolProgRec;
begin
  result := AddRecord;
  with result do
  begin
    Size := 5;
    case Reg of
      _EAX: code[0] := $B8;
      _EBX: code[0] := $BB;
      _ECX: code[0] := $B9;
      _EDX: code[0] := $BA;
      else
        RaiseError(errInternalError, []);
    end;
    Move(value, code[1], 4);
    Decompile;
  end;
end;

procedure TSymbolProg.AsmMovREGPtr32_Imm(Reg: Integer; value: Cardinal);
begin
  with AddRecord do
  begin
    Size := 6;
    code[0] := $C7;
    case Reg of
      _EAX: code[1] := $00;
      _ECX: code[1] := $01;
      _EDX: code[1] := $02;
      _EBX: code[1] := $03;
      else
        RaiseError(errInternalError, []);
    end;
    Move(value, code[2], 4);
    Decompile;
  end;
end;

procedure TSymbolProg.AsmMovREG32_REGPtr(Reg1, Reg2: Integer);
begin
  with AddRecord do
  begin
    Size := 2;
    code[0] := $8B;
    case Reg1 of
      _EAX:
        case Reg2 of
          _EAX: code[1] := $00;
          _ECX: code[1] := $01;
          _EDX: code[1] := $02;
          _EBX: code[1] := $03;
        else
          RaiseError(errInternalError, []);
        end;
      _ECX:
        case Reg2 of
          _EAX: code[1] := $08;
          _ECX: code[1] := $09;
          _EDX: code[1] := $0A;
          _EBX: code[1] := $0B;
        else
          RaiseError(errInternalError, []);
        end;
      _EDX:
        case Reg2 of
          _EAX: code[1] := $10;
          _ECX: code[1] := $11;
          _EDX: code[1] := $12;
          _EBX: code[1] := $13;
        else
          RaiseError(errInternalError, []);
        end;
      _EBX:
        case Reg2 of
          _EAX: code[1] := $18;
          _ECX: code[1] := $19;
          _EDX: code[1] := $1A;
          _EBX: code[1] := $1B;
        else
          RaiseError(errInternalError, []);
        end;
      else
        RaiseError(errInternalError, []);
    end;
    Decompile;
  end;
end;

procedure TSymbolProg.AsmMovREG16_REGPtr(Reg1, Reg2: Integer);
begin
  with AddRecord do
  begin
    Size := 3;
    code[0] := $66;
    code[1] := $8B;
    case Reg1 of
      _EAX:
        case Reg2 of
          _EAX: code[2] := $00;
          _ECX: code[2] := $01;
          _EDX: code[2] := $02;
          _EBX: code[2] := $03;
          _ESP: code[2] := $04;
          _EBP: code[2] := $05;
          _ESI: code[2] := $06;
        else
          RaiseError(errInternalError, []);
        end;
      _ECX:
        case Reg2 of
          _EAX: code[2] := $08;
          _ECX: code[2] := $09;
          _EDX: code[2] := $0A;
          _EBX: code[2] := $0B;
          _ESP: code[2] := $0C;
          _EBP: code[2] := $0D;
          _ESI: code[2] := $0E;
        else
          RaiseError(errInternalError, []);
        end;
      _EDX:
        case Reg2 of
          _EAX: code[2] := $10;
          _ECX: code[2] := $11;
          _EDX: code[2] := $12;
          _EBX: code[2] := $13;
          _ESP: code[2] := $14;
          _EBP: code[2] := $15;
          _ESI: code[2] := $16;
        else
          RaiseError(errInternalError, []);
        end;
      _EBX:
        case Reg2 of
          _EAX: code[2] := $18;
          _ECX: code[2] := $19;
          _EDX: code[2] := $1A;
          _EBX: code[2] := $1B;
          _ESP: code[2] := $1C;
          _EBP: code[2] := $1D;
          _ESI: code[2] := $1E;
        else
          RaiseError(errInternalError, []);
        end;
      else
        RaiseError(errInternalError, []);
    end;
    Decompile;
  end;
end;

procedure TSymbolProg.AsmMovREG8_REGPtr(Reg1, Reg2: Integer);
begin
  with AddRecord do
  begin
    Size := 2;
    code[0] := $8A;
    case Reg1 of
      _EAX:
        case Reg2 of
          _EAX: code[1] := $00;
          _ECX: code[1] := $01;
          _EDX: code[1] := $02;
          _EBX: code[1] := $03;
        else
          RaiseError(errInternalError, []);
        end;
      _ECX:
        case Reg2 of
          _EAX: code[1] := $08;
          _ECX: code[1] := $09;
          _EDX: code[1] := $0A;
          _EBX: code[1] := $0B;
        else
          RaiseError(errInternalError, []);
        end;
      _EDX:
        case Reg2 of
          _EAX: code[1] := $10;
          _ECX: code[1] := $11;
          _EDX: code[1] := $12;
          _EBX: code[1] := $13;
        else
          RaiseError(errInternalError, []);
        end;
      _EBX:
        case Reg2 of
          _EAX: code[1] := $18;
          _ECX: code[1] := $19;
          _EDX: code[1] := $1A;
          _EBX: code[1] := $1B;
        else
          RaiseError(errInternalError, []);
        end;
      else
        RaiseError(errInternalError, []);
    end;
    Decompile;
  end;
end;

procedure TSymbolProg.AsmMovREG_REG(Reg1, Reg2: Integer);
begin
  with AddRecord do
  begin
    Size := 2;
    code[0] := $89;
    case Reg1 of
      _EAX:
        case Reg2 of
          _EAX: code[1] := $C0;
          _ECX: code[1] := $C8;
          _EDX: code[1] := $D0;
          _EBX: code[1] := $D8;
          _ESP: code[1] := $E0;
          _EBP: code[1] := $E8;
          _ESI: code[1] := $F0;
          _EDI: code[1] := $F8;
        else
          RaiseError(errInternalError, []);
        end;
      _ECX:
        case Reg2 of
          _EAX: code[1] := $C1;
          _ECX: code[1] := $C9;
          _EDX: code[1] := $D1;
          _EBX: code[1] := $D9;
          _ESP: code[1] := $E1;
          _EBP: code[1] := $E9;
          _ESI: code[1] := $F1;
          _EDI: code[1] := $F9;
        else
          RaiseError(errInternalError, []);
        end;
      _EDX:
        case Reg2 of
          _EAX: code[1] := $C2;
          _ECX: code[1] := $CA;
          _EDX: code[1] := $D2;
          _EBX: code[1] := $DA;
          _ESP: code[1] := $E2;
          _EBP: code[1] := $EA;
          _ESI: code[1] := $F2;
          _EDI: code[1] := $FA;
        else
          RaiseError(errInternalError, []);
        end;
      _EBX:
        case Reg2 of
          _EAX: code[1] := $C3;
          _ECX: code[1] := $CB;
          _EDX: code[1] := $D3;
          _EBX: code[1] := $DB;
          _ESP: code[1] := $E3;
          _EBP: code[1] := $EB;
          _ESI: code[1] := $F3;
          _EDI: code[1] := $FB;
        else
          RaiseError(errInternalError, []);
        end;
      _EBP:
        case Reg2 of
          _ESP: code[1] := $E5;
        else
          RaiseError(errInternalError, []);
        end;
      _ESP:
        case Reg2 of
          _EBP: code[1] := $EC;
        else
          RaiseError(errInternalError, []);
        end;
      _ESI:
        case Reg2 of
          _EAX: code[1] := $C6;
          _ECX: code[1] := $CE;
          _EDX: code[1] := $D6;
          _EBX: code[1] := $DE;
          _ESP: code[1] := $E6;
          _EBP: code[1] := $EE;
          _ESI: code[1] := $F6;
          _EDI: code[1] := $FE;
        else
          RaiseError(errInternalError, []);
        end;
      _EDI:
        case Reg2 of
          _EAX: code[1] := $C7;
          _ECX: code[1] := $CF;
          _EDX: code[1] := $D7;
          _EBX: code[1] := $DF;
          _ESP: code[1] := $E7;
          _EBP: code[1] := $EF;
          _ESI: code[1] := $F7;
          _EDI: code[1] := $FF;
        else
          RaiseError(errInternalError, []);
        end;
      else
        RaiseError(errInternalError, []);
    end;
    Decompile;
  end;
end;

procedure TSymbolProg.AsmCmpREG_Imm(Reg: Integer; Value: Integer);
begin
  with AddRecord do
  begin
    case Reg of
      _EAX:
      begin
        Size := 5;
        code[0] := $3D;
        Move(Value, code[1], 4);
      end;
      _ECX, _EDX, _EBX:
      begin
        Size := 6;
        code[0] := $81;
        case Reg of
          _ECX: code[1] := $F9;
          _EDX: code[1] := $FA;
          _EBX: code[1] := $FB;
          _ESP: code[1] := $FC;
          _EBP: code[1] := $FD;
          _ESI: code[1] := $FE;
          _EDI: code[1] := $FF;
        end;
        Move(Value, code[2], 4);
      end;
      else
        RaiseError(errInternalError, []);
    end;
    Decompile;
  end;
end;

procedure TSymbolProg.AsmCmpREG_REG(Reg1, Reg2: Integer);
begin
  with AddRecord do
  begin
    Size := 2;
    code[0] := $39;
    case Reg1 of
      _EAX:
        case Reg2 of
          _EAX: code[1] := $C0;
          _ECX: code[1] := $C8;
          _EDX: code[1] := $D0;
          _EBX: code[1] := $D8;
        else
          RaiseError(errInternalError, []);
        end;
      _ECX:
        case Reg2 of
          _EAX: code[1] := $C1;
          _ECX: code[1] := $C9;
          _EDX: code[1] := $D1;
          _EBX: code[1] := $D9;
        else
          RaiseError(errInternalError, []);
        end;
      _EDX:
        case Reg2 of
          _EAX: code[1] := $C2;
          _ECX: code[1] := $CA;
          _EDX: code[1] := $D2;
          _EBX: code[1] := $DA;
        else
          RaiseError(errInternalError, []);
        end;
      _EBX:
        case Reg2 of
          _EAX: code[1] := $C3;
          _ECX: code[1] := $CB;
          _EDX: code[1] := $D3;
          _EBX: code[1] := $DB;
        else
          RaiseError(errInternalError, []);
        end;
      else
        RaiseError(errInternalError, []);
    end;
    Decompile;
  end;
end;

procedure TSymbolProg.AsmTestREG8_REG8(Reg1, Reg2: Integer);
begin
  with AddRecord do
  begin
    Size := 2;
    if (Reg1 = _EDX) and (Reg2 = _EDX) then
    begin
      Code[0] := $84;
      Code[1] := $d2;
    end
    else
     RaiseError(errInternalError, []);
    Decompile;
  end;
end;

procedure TSymbolProg.AsmMovREGPtr_REG32(Reg1, Reg2: Integer);
begin
  with AddRecord do
  begin
    Size := 2;
    code[0] := $89;
    case Reg1 of
      _EAX:
        case Reg2 of
          _EAX: code[1] := $00;
          _ECX: code[1] := $08;
          _EDX: code[1] := $10;
          _EBX: code[1] := $18;
        else
          RaiseError(errInternalError, []);
        end;
      _ECX:
        case Reg2 of
          _EAX: code[1] := $01;
          _ECX: code[1] := $09;
          _EDX: code[1] := $11;
          _EBX: code[1] := $19;
        else
          RaiseError(errInternalError, []);
        end;
      _EDX:
        case Reg2 of
          _EAX: code[1] := $02;
          _ECX: code[1] := $0A;
          _EDX: code[1] := $12;
          _EBX: code[1] := $1A;
        else
          RaiseError(errInternalError, []);
        end;
      _EBX:
        case Reg2 of
          _EAX: code[1] := $03;
          _ECX: code[1] := $0B;
          _EDX: code[1] := $13;
          _EBX: code[1] := $1B;
        else
          RaiseError(errInternalError, []);
        end;
      else
        RaiseError(errInternalError, []);
    end;
    Decompile;
  end;
end;

procedure TSymbolProg.AsmMovREGPtr_REG16(Reg1, Reg2: Integer);
begin
  with AddRecord do
  begin
    Size := 3;
    code[0] := $66;
    code[1] := $89;
    case Reg1 of
      _EAX:
        case Reg2 of
          _EAX: code[2] := $00;
          _ECX: code[2] := $08;
          _EDX: code[2] := $10;
          _EBX: code[2] := $18;
        else
          RaiseError(errInternalError, []);
        end;
      _ECX:
        case Reg2 of
          _EAX: code[2] := $01;
          _ECX: code[2] := $09;
          _EDX: code[2] := $11;
          _EBX: code[2] := $19;
        else
          RaiseError(errInternalError, []);
        end;
      _EDX:
        case Reg2 of
          _EAX: code[2] := $02;
          _ECX: code[2] := $0A;
          _EDX: code[2] := $12;
          _EBX: code[2] := $1A;
        else
          RaiseError(errInternalError, []);
        end;
      _EBX:
        case Reg2 of
          _EAX: code[2] := $03;
          _ECX: code[2] := $0B;
          _EDX: code[2] := $13;
          _EBX: code[2] := $1B;
        else
          RaiseError(errInternalError, []);
        end;
      else
        RaiseError(errInternalError, []);
    end;
    Decompile;
  end;
end;

procedure TSymbolProg.AsmMovREGPtr_REG8(Reg1, Reg2: Integer);
begin
  with AddRecord do
  begin
    Size := 2;
    code[0] := $88;
    case Reg1 of
      _EAX:
        case Reg2 of
          _EAX: code[1] := $00;
          _ECX: code[1] := $08;
          _EDX: code[1] := $10;
          _EBX: code[1] := $18;
        else
          RaiseError(errInternalError, []);
        end;
      _ECX:
        case Reg2 of
          _EAX: code[1] := $01;
          _ECX: code[1] := $09;
          _EDX: code[1] := $11;
          _EBX: code[1] := $19;
        else
          RaiseError(errInternalError, []);
        end;
      _EDX:
        case Reg2 of
          _EAX: code[1] := $02;
          _ECX: code[1] := $0A;
          _EDX: code[1] := $12;
          _EBX: code[1] := $1A;
        else
          RaiseError(errInternalError, []);
        end;
      _EBX:
        case Reg2 of
          _EAX: code[1] := $03;
          _ECX: code[1] := $0B;
          _EDX: code[1] := $13;
          _EBX: code[1] := $1B;
        else
          RaiseError(errInternalError, []);
        end;
      else
        RaiseError(errInternalError, []);
    end;
    Decompile;
  end;
end;

function TSymbolProg.AsmAddREG_Imm(Reg: Integer; value: Integer): TSymbolProgRec;
begin
  result := AddRecord;
  with result do
  begin
    case Reg of
      _EAX:
      begin
        Size := 5;
        code[0] := $05;
        Move(value, code[1], 4);
      end;
      _ECX:
      begin
        Size := 6;
        code[0] := $81;
        code[1] := $C1;
        Move(value, code[2], 4);
      end;
      _EDX:
      begin
        Size := 6;
        code[0] := $81;
        code[1] := $C2;
        Move(value, code[2], 4);
      end;
      _EBX:
      begin
        Size := 6;
        code[0] := $81;
        code[1] := $C3;
        Move(value, code[2], 4);
      end;
      _ESP:
      begin
        Size := 6;
        code[0] := $81;
        code[1] := $C4;
        Move(value, code[2], 4);
      end;
      _EBP:
      begin
        Size := 6;
        code[0] := $81;
        code[1] := $C5;
        Move(value, code[2], 4);
      end;
      else
        RaiseError(errInternalError, []);
    end;
    Decompile;
  end;
end;

procedure TSymbolProg.AsmSubREG_Imm(Reg: Integer; value: Integer);
begin
  with AddRecord do
  begin
    case Reg of
      _EAX:
      begin
        Size := 5;
        code[0] := $2D;
        Move(value, code[1], 4);
      end;
      _ECX:
      begin
        Size := 6;
        code[0] := $81;
        code[1] := $E9;
        Move(value, code[2], 4);
      end;
      _EDX:
      begin
        Size := 6;
        code[0] := $81;
        code[1] := $EA;
        Move(value, code[2], 4);
      end;
      _EBX:
      begin
        Size := 6;
        code[0] := $81;
        code[1] := $EB;
        Move(value, code[2], 4);
      end;
      _ESP:
      begin
        Size := 6;
        code[0] := $81;
        code[1] := $EC;
        Move(value, code[2], 4);
      end;
      _EBP:
      begin
        Size := 6;
        code[0] := $81;
        code[1] := $ED;
        Move(value, code[2], 4);
      end;
      _ESI:
      begin
        Size := 6;
        code[0] := $81;
        code[1] := $EE;
        Move(value, code[2], 4);
      end;
      _EDI:
      begin
        Size := 6;
        code[0] := $81;
        code[1] := $EF;
        Move(value, code[2], 4);
      end;
      else
        RaiseError(errInternalError, []);
    end;
    Decompile;
  end;
end;

procedure TSymbolProg.AsmMovREGPtr32_Imm(Reg, shift, value: Cardinal);
begin
  with AddRecord do
  begin
    Size := 10;
    code[0] := $C7;
    case Reg of
      _EAX: code[1] := $80;
      _ECX: code[1] := $81;
      _EDX: code[1] := $82;
      _EBX: code[1] := $83;
      _EBP: code[1] := $85;
      _ESI: code[1] := $86;
      else
        RaiseError(errInternalError, []);
    end;
    Move(shift, code[2], 4);
    Move(value, code[6], 4);
    Decompile;
  end;
end;

// requires EmitGetAddressRegister
// MOV <SIZE> PTR [REG], Imm
procedure TSymbolProg.AsmMovREGPtr_Imm(Reg: Integer; S: TSymbolRec; value: Integer);
var
  shift: Integer;
begin
  shift := GetOffset(S);
  if Reg in CommonRegisters then
    Shift := 0;

  with AddRecord do
  begin
    case S.PtrSize of
      1:
      begin
        Size := 7;
        code[0] := $C6;
        case Reg of
          _EAX: code[1] := $80;
          _ECX: code[1] := $81;
          _EDX: code[1] := $82;
          _EBX: code[1] := $83;
          _ESP: code[1] := $84;
          _EBP: code[1] := $85;
          _ESI: code[1] := $86;
          else
            RaiseError(errInternalError, []);
        end;
        Move(shift, code[2], 4);
        code[6] := value;
      end;
      2:
      begin
        Size := 9;
        code[0] := $66;
        code[1] := $C7;
        case Reg of
          _EAX: code[2] := $80;
          _ECX: code[2] := $81;
          _EDX: code[2] := $82;
          _EBX: code[2] := $83;
          _ESP: code[2] := $84;
          _EBP: code[2] := $85;
          _ESI: code[2] := $86;
          else
            RaiseError(errInternalError, []);
        end;
        Move(shift, code[3], 4);
        Move(value, code[7], 2);
      end;
      4:
      begin
        Size := 10;
        code[0] := $C7;
        case Reg of
          _EAX: code[1] := $80;
          _ECX: code[1] := $81;
          _EDX: code[1] := $82;
          _EBX: code[1] := $83;
          _EBP: code[1] := $85;
          _ESI: code[1] := $86;
          else
            RaiseError(errInternalError, []);
        end;
        Move(shift, code[2], 4);
        Move(value, code[6], 4);
      end;
      else
        RaiseError(errInternalError, []);
    end;
    Decompile;
  end;
end;

// requires EmitGetAddressRegister
// ADD <SIZE> PTR [REG], Imm
procedure TSymbolProg.AsmAddREGPtr_Imm(Reg: Integer; S: TSymbolRec; value: Integer);
var
  shift: Integer;
begin
  shift := GetOffset(S);
  if Reg in CommonRegisters then
    Shift := 0;

  with AddRecord do
  begin

    case S.PtrSize of
      1:
      begin
        Size := 7;
        code[0] := $80;
        case Reg of
          _EAX: code[1] := $80;
          _ECX: code[1] := $81;
          _EDX: code[1] := $82;
          _EBX: code[1] := $83;
          _ESP: code[1] := $84;
          _EBP: code[1] := $85;
          _ESI: code[1] := $86;
          else
            RaiseError(errInternalError, []);
        end;
        Move(shift, code[2], 4);
        Move(value, code[6], 1);
      end;
      2:
      begin
        Size := 9;
        code[0] := $66;
        code[1] := $81;
        case Reg of
          _EAX: code[2] := $80;
          _ECX: code[2] := $81;
          _EDX: code[2] := $82;
          _EBX: code[2] := $83;
          _ESP: code[2] := $84;
          _EBP: code[2] := $85;
          _ESI: code[2] := $86;
          else
            RaiseError(errInternalError, []);
        end;
        Move(shift, code[3], 4);
        Move(value, code[7], 2);
      end;
      4:
      begin
        Size := 10;
        code[0] := $81;
        case Reg of
          _EAX: code[1] := $80;
          _ECX: code[1] := $81;
          _EDX: code[1] := $82;
          _EBX: code[1] := $83;
          _EBP: code[1] := $85;
          _ESI: code[1] := $86;
          else
            RaiseError(errInternalError, []);
        end;
        Move(shift, code[2], 4);
        Move(value, code[6], 4);
      end;
      else
        RaiseError(errInternalError, []);
    end;
    Decompile;
  end;
end;

// requires EmitGetAddressRegister
// CMP <SIZE> PTR [REG], Imm
procedure TSymbolProg.AsmCmpREGPtr_Imm(Reg: Integer; S: TSymbolRec; value: Integer);
var
  shift: Integer;
begin
  shift := GetOffset(S);
  if Reg in CommonRegisters then
    Shift := 0;

  with AddRecord do
  begin
    case S.PtrSize of
      1:
      begin
        Size := 7;
        code[0] := $80;
        case Reg of
          _EAX: code[1] := $B8;
          _ECX: code[1] := $B9;
          _EDX: code[1] := $BA;
          _EBX: code[1] := $BB;
          _ESP: code[1] := $BC;
          _EBP: code[1] := $BD;
          _ESI: code[1] := $BE;
          else
            RaiseError(errInternalError, []);
        end;
        Move(shift, code[2], 4);
        Move(value, code[6], 1);
      end;
      2:
      begin
        Size := 9;
        code[0] := $66;
        code[1] := $81;
        case Reg of
          _EAX: code[2] := $B8;
          _ECX: code[2] := $B9;
          _EDX: code[2] := $BA;
          _EBX: code[2] := $BB;
          _ESP: code[2] := $BC;
          _EBP: code[2] := $BD;
          _ESI: code[2] := $BE;
          else
            RaiseError(errInternalError, []);
        end;
        Move(shift, code[3], 4);
        Move(value, code[7], 2);
      end;
      4:
      begin
        Size := 10;
        code[0] := $81;
        case Reg of
          _EAX: code[1] := $B8;
          _ECX: code[1] := $B9;
          _EDX: code[1] := $BA;
          _EBX: code[1] := $BB;
          _ESP: code[1] := $BC;
          _EBP: code[1] := $BD;
          _ESI: code[1] := $BE;
          else
            RaiseError(errInternalError, []);
        end;
        Move(shift, code[2], 4);
        Move(value, code[6], 4);
      end;
      else
        RaiseError(errInternalError, []);
    end;
    Decompile;
  end;
end;

procedure TSymbolProg.AsmCmpReg32Ptr_Imm(Reg: Integer; shift: Integer; value: Integer);
begin
  with AddRecord do
  begin
    Size := 10;
    code[0] := $81;
    case Reg of
      _EAX: code[1] := $B8;
      _ECX: code[1] := $B9;
      _EDX: code[1] := $BA;
      _EBX: code[1] := $BB;
      _ESP: code[1] := $BC;
      _EBP: code[1] := $BD;
      _ESI: code[1] := $BE;
      else
        RaiseError(errInternalError, []);
    end;
    Move(shift, code[2], 4);
    Move(value, code[6], 4);
    Decompile;
  end;
end;

procedure TSymbolProg.AsmAddREG_REG(Reg1, Reg2: Integer);
begin
  with AddRecord do
  begin
    Size := 2;
    code[0] := $01;
    case Reg1 of
      _EAX:
        case Reg2 of
          _EAX: code[1] := $C0;
          _ECX: code[1] := $C8;
          _EDX: code[1] := $D0;
          _EBX: code[1] := $D8;
        else
          RaiseError(errInternalError, []);
        end;
      _ECX:
        case Reg2 of
          _EAX: code[1] := $C1;
          _ECX: code[1] := $C9;
          _EDX: code[1] := $D1;
          _EBX: code[1] := $D9;
        else
          RaiseError(errInternalError, []);
        end;
      _EDX:
        case Reg2 of
          _EAX: code[1] := $C2;
          _ECX: code[1] := $CA;
          _EDX: code[1] := $D2;
          _EBX: code[1] := $DA;
        else
          RaiseError(errInternalError, []);
        end;
      _EBX:
        case Reg2 of
          _EAX: code[1] := $C3;
          _ECX: code[1] := $CB;
          _EDX: code[1] := $D3;
          _EBX: code[1] := $DB;
        else
          RaiseError(errInternalError, []);
        end;
      else
        RaiseError(errInternalError, []);
    end;
    Decompile;
  end;
end;

procedure TSymbolProg.AsmAdcREG_REG(Reg1, Reg2: Integer);
begin
  with AddRecord do
  begin
    Size := 2;
    code[0] := $11;
    case Reg1 of
      _EAX:
        case Reg2 of
          _EAX: code[1] := $C0;
          _ECX: code[1] := $C8;
          _EDX: code[1] := $D0;
          _EBX: code[1] := $D8;
        else
          RaiseError(errInternalError, []);
        end;
      _ECX:
        case Reg2 of
          _EAX: code[1] := $C1;
          _ECX: code[1] := $C9;
          _EDX: code[1] := $D1;
          _EBX: code[1] := $D9;
        else
          RaiseError(errInternalError, []);
        end;
      _EDX:
        case Reg2 of
          _EAX: code[1] := $C2;
          _ECX: code[1] := $CA;
          _EDX: code[1] := $D2;
          _EBX: code[1] := $DA;
        else
          RaiseError(errInternalError, []);
        end;
      _EBX:
        case Reg2 of
          _EAX: code[1] := $C3;
          _ECX: code[1] := $CB;
          _EDX: code[1] := $D3;
          _EBX: code[1] := $DB;
        else
          RaiseError(errInternalError, []);
        end;
      else
        RaiseError(errInternalError, []);
    end;
    Decompile;
  end;
end;

procedure TSymbolProg.AsmSbbREG_REG(Reg1, Reg2: Integer);
begin
  with AddRecord do
  begin
    Size := 2;
    code[0] := $19;
    case Reg1 of
      _EAX:
        case Reg2 of
          _EAX: code[1] := $C0;
          _ECX: code[1] := $C8;
          _EDX: code[1] := $D0;
          _EBX: code[1] := $D8;
        else
          RaiseError(errInternalError, []);
        end;
      _ECX:
        case Reg2 of
          _EAX: code[1] := $C1;
          _ECX: code[1] := $C9;
          _EDX: code[1] := $D1;
          _EBX: code[1] := $D9;
        else
          RaiseError(errInternalError, []);
        end;
      _EDX:
        case Reg2 of
          _EAX: code[1] := $C2;
          _ECX: code[1] := $CA;
          _EDX: code[1] := $D2;
          _EBX: code[1] := $DA;
        else
          RaiseError(errInternalError, []);
        end;
      _EBX:
        case Reg2 of
          _EAX: code[1] := $C3;
          _ECX: code[1] := $CB;
          _EDX: code[1] := $D3;
          _EBX: code[1] := $DB;
        else
          RaiseError(errInternalError, []);
        end;
      else
        RaiseError(errInternalError, []);
    end;
    Decompile;
  end;
end;

procedure TSymbolProg.AsmSubREG_REG(Reg1, Reg2: Integer);
begin
  with AddRecord do
  begin
    Size := 2;
    code[0] := $29;
    case Reg1 of
      _EAX:
        case Reg2 of
          _EAX: code[1] := $C0;
          _ECX: code[1] := $C8;
          _EDX: code[1] := $D0;
          _EBX: code[1] := $D8;
        else
          RaiseError(errInternalError, []);
        end;
      _ECX:
        case Reg2 of
          _EAX: code[1] := $C1;
          _ECX: code[1] := $C9;
          _EDX: code[1] := $D1;
          _EBX: code[1] := $D9;
        else
          RaiseError(errInternalError, []);
        end;
      _EDX:
        case Reg2 of
          _EAX: code[1] := $C2;
          _ECX: code[1] := $CA;
          _EDX: code[1] := $D2;
          _EBX: code[1] := $DA;
        else
          RaiseError(errInternalError, []);
        end;
      _EBX:
        case Reg2 of
          _EAX: code[1] := $C3;
          _ECX: code[1] := $CB;
          _EDX: code[1] := $D3;
          _EBX: code[1] := $DB;
        else
          RaiseError(errInternalError, []);
        end;
      else
        RaiseError(errInternalError, []);
    end;
    Decompile;
  end;
end;

procedure TSymbolProg.AsmXorREG_REG(Reg1, Reg2: Integer);
begin
  with AddRecord do
  begin
    Size := 2;
    code[0] := $31;
    case Reg1 of
      _EAX:
        case Reg2 of
          _EAX: code[1] := $C0;
          _ECX: code[1] := $C8;
          _EDX: code[1] := $D0;
          _EBX: code[1] := $D8;
        else
          RaiseError(errInternalError, []);
        end;
      _ECX:
        case Reg2 of
          _EAX: code[1] := $C1;
          _ECX: code[1] := $C9;
          _EDX: code[1] := $D1;
          _EBX: code[1] := $D9;
        else
          RaiseError(errInternalError, []);
        end;
      _EDX:
        case Reg2 of
          _EAX: code[1] := $C2;
          _ECX: code[1] := $CA;
          _EDX: code[1] := $D2;
          _EBX: code[1] := $DA;
        else
          RaiseError(errInternalError, []);
        end;
      _EBX:
        case Reg2 of
          _EAX: code[1] := $C3;
          _ECX: code[1] := $CB;
          _EDX: code[1] := $D3;
          _EBX: code[1] := $DB;
        else
          RaiseError(errInternalError, []);
        end;
      else
        RaiseError(errInternalError, []);
    end;
    Decompile;
  end;
end;

procedure TSymbolProg.AsmAndREG_REG(Reg1, Reg2: Integer);
begin
  with AddRecord do
  begin
    Size := 2;
    code[0] := $21;
    case Reg1 of
      _EAX:
        case Reg2 of
          _EAX: code[1] := $C0;
          _ECX: code[1] := $C8;
          _EDX: code[1] := $D0;
          _EBX: code[1] := $D8;
        else
          RaiseError(errInternalError, []);
        end;
      _ECX:
        case Reg2 of
          _EAX: code[1] := $C1;
          _ECX: code[1] := $C9;
          _EDX: code[1] := $D1;
          _EBX: code[1] := $D9;
        else
          RaiseError(errInternalError, []);
        end;
      _EDX:
        case Reg2 of
          _EAX: code[1] := $C2;
          _ECX: code[1] := $CA;
          _EDX: code[1] := $D2;
          _EBX: code[1] := $DA;
        else
          RaiseError(errInternalError, []);
        end;
      _EBX:
        case Reg2 of
          _EAX: code[1] := $C3;
          _ECX: code[1] := $CB;
          _EDX: code[1] := $D3;
          _EBX: code[1] := $DB;
        else
          RaiseError(errInternalError, []);
        end;
      else
        RaiseError(errInternalError, []);
    end;
    Decompile;
  end;
end;

procedure TSymbolProg.AsmOrREG_REG(Reg1, Reg2: Integer);
begin
  with AddRecord do
  begin
    Size := 2;
    code[0] := $09;
    case Reg1 of
      _EAX:
        case Reg2 of
          _EAX: code[1] := $C0;
          _ECX: code[1] := $C8;
          _EDX: code[1] := $D0;
          _EBX: code[1] := $D8;
        else
          RaiseError(errInternalError, []);
        end;
      _ECX:
        case Reg2 of
          _EAX: code[1] := $C1;
          _ECX: code[1] := $C9;
          _EDX: code[1] := $D1;
          _EBX: code[1] := $D9;
        else
          RaiseError(errInternalError, []);
        end;
      _EDX:
        case Reg2 of
          _EAX: code[1] := $C2;
          _ECX: code[1] := $CA;
          _EDX: code[1] := $D2;
          _EBX: code[1] := $DA;
        else
          RaiseError(errInternalError, []);
        end;
      _EBX:
        case Reg2 of
          _EAX: code[1] := $C3;
          _ECX: code[1] := $CB;
          _EDX: code[1] := $D3;
          _EBX: code[1] := $DB;
        else
          RaiseError(errInternalError, []);
        end;
      else
        RaiseError(errInternalError, []);
    end;
    Decompile;
  end;
end;

procedure TSymbolProg.AsmMulREG(Reg: Integer);
begin
  with AddRecord do
  begin
    Size := 2;
    code[0] := $F7;
    case Reg of
      _EAX: code[1] := $E0;
      _ECX: code[1] := $E1;
      _EDX: code[1] := $E2;
      _EBX: code[1] := $E3;
    else
      RaiseError(errInternalError, []);
    end;
    Decompile;
  end;
end;

procedure TSymbolProg.AsmIMulREG(Reg: Integer);
begin
  with AddRecord do
  begin
    Size := 2;
    code[0] := $F7;
    case Reg of
      _EAX: code[1] := $E8;
      _ECX: code[1] := $E9;
      _EDX: code[1] := $EA;
      _EBX: code[1] := $EB;
    else
      RaiseError(errInternalError, []);
    end;
    Decompile;
  end;
end;

procedure TSymbolProg.AsmDivREG(Reg: Integer);
begin
  with AddRecord do
  begin
    Size := 2;
    code[0] := $F7;
    case Reg of
      _EAX: code[1] := $F0;
      _ECX: code[1] := $F1;
      _EDX: code[1] := $F2;
      _EBX: code[1] := $F3;
    else
      RaiseError(errInternalError, []);
    end;
    Decompile;
  end;
end;

procedure TSymbolProg.AsmIDivREG(Reg: Integer);
begin
  with AddRecord do
  begin
    Size := 2;
    code[0] := $F7;
    case Reg of
      _EAX: code[1] := $F8;
      _ECX: code[1] := $F9;
      _EDX: code[1] := $FA;
      _EBX: code[1] := $FB;
    else
      RaiseError(errInternalError, []);
    end;
    Decompile;
  end;
end;

procedure TSymbolProg.AsmShlREG(Reg: Integer);
begin
  with AddRecord do
  begin
    Size := 2;
    code[0] := $D3;
    case Reg of
      _EAX: code[1] := $E0;
      _ECX: code[1] := $E1;
      _EDX: code[1] := $E2;
      _EBX: code[1] := $E3;
    else
      RaiseError(errInternalError, []);
    end;
    Decompile;
  end;
end;

procedure TSymbolProg.AsmShrREG(Reg: Integer);
begin
  with AddRecord do
  begin
    Size := 2;
    code[0] := $D3;
    case Reg of
      _EAX: code[1] := $E8;
      _ECX: code[1] := $E9;
      _EDX: code[1] := $EA;
      _EBX: code[1] := $EB;
    else
      RaiseError(errInternalError, []);
    end;
    Decompile;
  end;
end;

procedure TSymbolProg.AsmNegREG(Reg: Integer);
begin
  with AddRecord do
  begin
    Size := 2;
    code[0] := $F7;
    case Reg of
      _EAX: code[1] := $D8;
      _ECX: code[1] := $D9;
      _EDX: code[1] := $DA;
      _EBX: code[1] := $DB;
    else
      RaiseError(errInternalError, []);
    end;
    Decompile;
  end;
end;

// requires EmitGetAddressRegister
// NEG <SIZE = 4> PTR [REG + Shift]
procedure TSymbolProg.AsmNEG_REGPtr(Reg: Integer; S: TSymbolRec);
var
  shift: Integer;
begin
  shift := GetOffset(S);
  if Reg in CommonRegisters then
    Shift := 0;

  if S.PtrSize <> 4 then
    RaiseError(errInternalError, []);

  with AddRecord do
  begin
    Size := 6;
    code[0] := $F7;

    case Reg of
      _EAX: code[1] := $98;
      _ECX: code[1] := $99;
      _EDX: code[1] := $9A;
      _EBX: code[1] := $9B;
      _ESP: code[1] := $9C;
      _EBP: code[1] := $9D;
      _ESI: code[1] := $9E;
    else
      RaiseError(errInternalError, []);
    end;

    Move(shift, code[2], 4);
    Decompile;
  end;
end;

procedure TSymbolProg.AsmLoadESI_ESPPtr(shift: Integer);
begin
  with AddRecord do
  begin
    Size := 7;
    code[0] := $8B;
    code[1] := $B4;
    code[2] := $24;
    Move(shift, code[3], 4);
    Decompile;
  end;
end;

procedure TSymbolProg.AsmLoadEDI_ESPPtr(shift: Integer);
begin
  with AddRecord do
  begin
    Size := 7;
    code[0] := $8B;
    code[1] := $BC;
    code[2] := $24;
    Move(shift, code[3], 4);
    Decompile;
  end;
end;

procedure TSymbolProg.AsmGetREG32_ESIPtr(Reg: Integer; shift: Integer);
begin
  with AddRecord do
  begin
    Size := 6;
    code[0] := $8B;
    case Reg of
      _EAX: code[1] := $86;
      _ECX: code[1] := $8E;
      _EDX: code[1] := $96;
      _EBX: code[1] := $9E;
      else
        RaiseError(errInternalError, []);
    end;
    Move(shift, code[2], 4);
    Decompile;
  end;
end;

procedure TSymbolProg.AsmGetREG16_ESIPtr(Reg: Integer; shift: Integer);
begin
  with AddRecord do
  begin
    Size := 7;
    code[0] := $66;
    code[1] := $8B;
    case Reg of
      _EAX: code[2] := $86;
      _ECX: code[2] := $8E;
      _EDX: code[2] := $96;
      _EBX: code[2] := $9E;
      else
        RaiseError(errInternalError, []);
    end;
    Move(shift, code[3], 4);
    Decompile;
  end;
end;

procedure TSymbolProg.AsmGetREG8_ESIPtr(Reg: Integer; shift: Integer);
begin
  with AddRecord do
  begin
    Size := 6;
    code[0] := $8A;
    case Reg of
      _EAX: code[1] := $86;
      _ECX: code[1] := $8E;
      _EDX: code[1] := $96;
      _EBX: code[1] := $9E;
      else
        RaiseError(errInternalError, []);
    end;
    Move(shift, code[2], 4);
    Decompile;
  end;
end;

procedure TSymbolProg.AsmPutREG32_ESIPtr(Reg: Integer; shift: Integer);
begin
  with AddRecord do
  begin
    Size := 6;
    code[0] := $89;
    case Reg of
      _EAX: code[1] := $86;
      _ECX: code[1] := $8E;
      _EDX: code[1] := $96;
      _EBX: code[1] := $9E;
      else
        RaiseError(errInternalError, []);
    end;
    Move(shift, code[2], 4);
    Decompile;
  end;
end;

procedure TSymbolProg.AsmPutREG16_ESIPtr(Reg: Integer; shift: Integer);
begin
  with AddRecord do
  begin
    Size := 7;
    code[0] := $66;
    code[1] := $89;
    case Reg of
      _EAX: code[2] := $86;
      _ECX: code[2] := $8E;
      _EDX: code[2] := $96;
      _EBX: code[2] := $9E;
      else
        RaiseError(errInternalError, []);
    end;
    Move(shift, code[3], 4);
    Decompile;
  end;
end;

procedure TSymbolProg.AsmLeaReg32_RegPtr(Reg1, Reg2: Integer; shift: Integer);
begin
  with AddRecord do
  begin
    Size := 6;
    code[0] := $8D;
    case Reg1 of
      _EAX:
      case Reg2 of
        _EAX: code[1] := $80;
        _ECX: code[1] := $81;
        _EDX: code[1] := $82;
        _EBX: code[1] := $83;

        _EBP: code[1] := $85;
        _ESI: code[1] := $86;
        _EDI: code[1] := $87;
        else
          RaiseError(errInternalError, []);
      end;
      _ECX:
      case Reg2 of
        _EAX: code[1] := $88;
        _ECX: code[1] := $89;
        _EDX: code[1] := $8A;
        _EBX: code[1] := $8B;

        _EBP: code[1] := $8D;
        _ESI: code[1] := $8E;
        _EDI: code[1] := $8F;
        else
          RaiseError(errInternalError, []);
      end;
      _EDX:
      case Reg2 of
        _EAX: code[1] := $90;
        _ECX: code[1] := $91;
        _EDX: code[1] := $92;
        _EBX: code[1] := $93;

        _EBP: code[1] := $95;
        _ESI: code[1] := $96;
        _EDI: code[1] := $97;
        else
          RaiseError(errInternalError, []);
      end;
      _EBX:
      case Reg2 of
        _EAX: code[1] := $98;
        _ECX: code[1] := $99;
        _EDX: code[1] := $9A;
        _EBX: code[1] := $9B;

        _EBP: code[1] := $9D;
        _ESI: code[1] := $9E;
        _EDI: code[1] := $9F;
        else
          RaiseError(errInternalError, []);
      end;
      else
        RaiseError(errInternalError, []);
    end;
    Move(shift, code[2], 4);
    Decompile;
  end;
end;

procedure TSymbolProg.AsmGetREG32_EBPPtr(Reg: Integer; shift: Integer);
begin
  with AddRecord do
  begin
    Size := 6;
    code[0] := $8B;
    case Reg of
      _EAX: code[1] := $85;
      _ECX: code[1] := $8D;
      _EDX: code[1] := $95;
      _EBX: code[1] := $9D;
      else
        RaiseError(errInternalError, []);
    end;
    Move(shift, code[2], 4);
    Decompile;
  end;
end;

procedure TSymbolProg.AsmGetREG16_EBPPtr(Reg: Integer; shift: Integer);
begin
  with AddRecord do
  begin
    Size := 7;
    code[0] := $66;
    code[1] := $8B;
    case Reg of
      _EAX: code[2] := $85;
      _ECX: code[2] := $8D;
      _EDX: code[2] := $95;
      _EBX: code[2] := $9D;
      else
        RaiseError(errInternalError, []);
    end;
    Move(shift, code[3], 4);
    Decompile;
  end;
end;

procedure TSymbolProg.AsmPutREG32_EBPPtr(Reg: Integer; shift: Integer);
begin
  with AddRecord do
  begin
    Size := 6;
    code[0] := $89;
    case Reg of
      _EAX: code[1] := $85;
      _ECX: code[1] := $8D;
      _EDX: code[1] := $95;
      _EBX: code[1] := $9D;
      else
        RaiseError(errInternalError, []);
    end;
    Move(shift, code[2], 4);
    Decompile;
  end;
end;

procedure TSymbolProg.AsmPutREG16_EBPPtr(Reg: Integer; shift: Integer);
begin
  with AddRecord do
  begin
    Size := 7;
    code[0] := $66;
    code[1] := $89;
    case Reg of
      _EAX: code[2] := $85;
      _ECX: code[2] := $8D;
      _EDX: code[2] := $95;
      _EBX: code[2] := $9D;
      else
        RaiseError(errInternalError, []);
    end;
    Move(shift, code[3], 4);
    Decompile;
  end;
end;

procedure TSymbolProg.AsmPutREG8_ESIPtr(Reg: Integer; shift: Integer);
begin
  with AddRecord do
  begin
    Size := 6;
    code[0] := $88;
    case Reg of
      _EAX: code[1] := $86;
      _ECX: code[1] := $8E;
      _EDX: code[1] := $96;
      _EBX: code[1] := $9E;
      else
        RaiseError(errInternalError, []);
    end;
    Move(shift, code[2], 4);
    Decompile;
  end;
end;

procedure TSymbolProg.AsmGetREG8_EBPPtr(Reg: Integer; shift: Integer);
begin
  with AddRecord do
  begin
    Size := 6;
    code[0] := $8A;
    case Reg of
      _EAX: code[1] := $85;
      _ECX: code[1] := $8D;
      _EDX: code[1] := $95;
      _EBX: code[1] := $9D;
      else
        RaiseError(errInternalError, []);
    end;
    Move(shift, code[2], 4);
    Decompile;
  end;
end;

procedure TSymbolProg.AsmPutREG8_EBPPtr(Reg: Integer; shift: Integer);
begin
  with AddRecord do
  begin
    Size := 6;
    code[0] := $88;
    case Reg of
      _EAX: code[1] := $85;
      _ECX: code[1] := $8D;
      _EDX: code[1] := $95;
      _EBX: code[1] := $9D;
      else
        RaiseError(errInternalError, []);
    end;
    Move(shift, code[2], 4);
    Decompile;
  end;
end;

procedure TSymbolProg.AsmFldDouble_REGPtr(Reg: Integer);
begin
  with AddRecord do
  begin
    Size := 2;
    code[0] := $DD;
    case Reg of
      _EAX: code[1] := $00;
      _ECX: code[1] := $01;
      _EDX: code[1] := $02;
      _EBX: code[1] := $03;
    else
      RaiseError(errInternalError, []);
    end;
    Decompile;
  end;
end;

procedure TSymbolProg.AsmFldSingle_REGPtr(Reg: Integer);
begin
  with AddRecord do
  begin
    Size := 2;
    code[0] := $D9;
    case Reg of
      _EAX: code[1] := $00;
      _ECX: code[1] := $01;
      _EDX: code[1] := $02;
      _EBX: code[1] := $03;
    else
      RaiseError(errInternalError, []);
    end;
    Decompile;
  end;
end;

procedure TSymbolProg.AsmFldExtended_REGPtr(Reg: Integer);
begin
  with AddRecord do
  begin
    Size := 2;
    code[0] := $DB;
    case Reg of
      _EAX: code[1] := $28;
      _ECX: code[1] := $29;
      _EDX: code[1] := $2A;
      _EBX: code[1] := $2B;
    else
      RaiseError(errInternalError, []);
    end;
    Decompile;
  end;
end;

// requires EmitGetAddressRegister
// Fld QWORD PTR [REG + Shift]
procedure TSymbolProg.AsmFldDouble_REGPtr(Reg: Integer; S: TSymbolRec);
var
  shift: Integer;
begin
  shift := GetOffset(S);
  if Reg in CommonRegisters then
    Shift := 0;

  with AddRecord do
  begin
    Size := 6;
    code[0] := $DD;
    case Reg of
      _EAX: code[1] := $80;
      _ECX: code[1] := $81;
      _EDX: code[1] := $82;
      _EBX: code[1] := $83;
      _EBP: code[1] := $85;
      _ESI: code[1] := $86;
    else
      RaiseError(errInternalError, []);
    end;
    Move(shift, code[2], 4);
    Decompile;
  end;
end;

// requires EmitGetAddressRegister
// Fld DWORD PTR [REG + Shift]
procedure TSymbolProg.AsmFldSingle_REGPtr(Reg: Integer; S: TSymbolRec);
var
  shift: Integer;
begin
  shift := GetOffset(S);
  if Reg in CommonRegisters then
    Shift := 0;

  with AddRecord do
  begin
    Size := 6;
    code[0] := $D9;
    case Reg of
      _EAX: code[1] := $80;
      _ECX: code[1] := $81;
      _EDX: code[1] := $82;
      _EBX: code[1] := $83;
      _EBP: code[1] := $85;
      _ESI: code[1] := $86;
    else
      RaiseError(errInternalError, []);
    end;
    Move(shift, code[2], 4);
    Decompile;
  end;
end;

// requires EmitGetAddressRegister
// Fld TBYTE PTR [REG + Shift]
procedure TSymbolProg.AsmFldExtended_REGPtr(Reg: Integer; S: TSymbolRec);
var
  shift: Integer;
begin
  shift := GetOffset(S);
  if Reg in CommonRegisters then
    Shift := 0;

  with AddRecord do
  begin
    Size := 6;
    code[0] := $DB;
    case Reg of
      _EAX: code[1] := $A8;
      _ECX: code[1] := $A9;
      _EDX: code[1] := $AA;
      _EBX: code[1] := $AB;
      _EBP: code[1] := $AD;
      _ESI: code[1] := $AE;
    else
      RaiseError(errInternalError, []);
    end;
    Move(shift, code[2], 4);
    Decompile;
  end;
end;

procedure TSymbolProg.AsmFild_REG32Ptr(Reg: Integer);
begin
  with AddRecord do
  begin
    Size := 2;
    code[0] := $DB;
    case Reg of
      _EAX: code[1] := $00;
      _ECX: code[1] := $01;
      _EDX: code[1] := $02;
      _EBX: code[1] := $03;
      _ESI: code[1] := $06;
      _EDI: code[1] := $07;
    else
      RaiseError(errInternalError, []);
    end;
    Decompile;
  end;
end;

procedure TSymbolProg.AsmFild_REG16Ptr(Reg: Integer);
begin
  with AddRecord do
  begin
    Size := 2;
    code[0] := $DF;
    case Reg of
      _EAX: code[1] := $00;
      _ECX: code[1] := $01;
      _EDX: code[1] := $02;
      _EBX: code[1] := $03;
      _ESI: code[1] := $06;
      _EDI: code[1] := $07;
    else
      RaiseError(errInternalError, []);
    end;
    Decompile;
  end;
end;

procedure TSymbolProg.AsmFild_REG64Ptr(Reg: Integer);
begin
  with AddRecord do
  begin
    Size := 2;
    code[0] := $DF;
    case Reg of
      _EAX: code[1] := $28;
      _ECX: code[1] := $29;
      _EDX: code[1] := $2A;
      _EBX: code[1] := $2B;
    else
      RaiseError(errInternalError, []);
    end;
    Decompile;
  end;
end;

procedure TSymbolProg.AsmFistp_REG64Ptr(Reg: Integer);
begin
  with AddRecord do
  begin
    Size := 2;
    code[0] := $DF;
    case Reg of
      _EAX: code[1] := $38;
      _ECX: code[1] := $39;
      _EDX: code[1] := $3A;
      _EBX: code[1] := $3B;
    else
      RaiseError(errInternalError, []);
    end;
    Decompile;
  end;
end;

procedure TSymbolProg.AsmFAdd_REGPtr(Reg: Integer);
begin
  with AddRecord do
  begin
    Size := 2;
    code[0] := $DC;
    case Reg of
      _EAX: code[1] := $00;
      _ECX: code[1] := $01;
      _EDX: code[1] := $02;
      _EBX: code[1] := $03;
    else
      RaiseError(errInternalError, []);
    end;
    Decompile;
  end;
end;

procedure TSymbolProg.AsmFSub_REGPtr(Reg: Integer);
begin
  with AddRecord do
  begin
    Size := 2;
    code[0] := $DC;
    case Reg of
      _EAX: code[1] := $20;
      _ECX: code[1] := $21;
      _EDX: code[1] := $22;
      _EBX: code[1] := $23;
    else
      RaiseError(errInternalError, []);
    end;
    Decompile;
  end;
end;

procedure TSymbolProg.AsmFMul_REGPtr(Reg: Integer);
begin
  with AddRecord do
  begin
    Size := 2;
    code[0] := $DC;
    case Reg of
      _EAX: code[1] := $08;
      _ECX: code[1] := $09;
      _EDX: code[1] := $0A;
      _EBX: code[1] := $0B;
    else
      RaiseError(errInternalError, []);
    end;
    Decompile;
  end;
end;

procedure TSymbolProg.AsmFMul_ESIPtr32(Shift: Integer);
begin
  with AddRecord do
  begin
    Size := 6;
    code[0] := $D8;
    code[1] := $8E;
    Move(Shift, code[2], 4);
    Decompile;
  end;
end;

procedure TSymbolProg.AsmFDiv_ESIPtr32(Shift: Integer);
begin
  with AddRecord do
  begin
    Size := 6;
    code[0] := $D8;
    code[1] := $B6;
    Move(Shift, code[2], 4);
    Decompile;
  end;
end;

procedure TSymbolProg.AsmFDiv_REGPtr(Reg: Integer);
begin
  with AddRecord do
  begin
    Size := 2;
    code[0] := $DC;
    case Reg of
      _EAX: code[1] := $30;
      _ECX: code[1] := $31;
      _EDX: code[1] := $32;
      _EBX: code[1] := $33;
    else
      RaiseError(errInternalError, []);
    end;
    Decompile;
  end;
end;

procedure TSymbolProg.AsmFComp_REGPtr(Reg: Integer);
begin
  with AddRecord do
  begin
    Size := 2;
    code[0] := $D8;
    case Reg of
      _EAX: code[1] := $18;
      _ECX: code[1] := $19;
      _EDX: code[1] := $1A;
      _EBX: code[1] := $1B;
    else
      RaiseError(errInternalError, []);
    end;
    Decompile;
  end;
end;

procedure TSymbolProg.AsmFAdd;
begin
  with AddRecord do
  begin
    Size := 2;
    code[0] := $DE;
    code[1] := $C1;
    Decompile;
  end;
end;

procedure TSymbolProg.AsmFSub;
begin
  with AddRecord do
  begin
    Size := 2;
    code[0] := $DE;
    code[1] := $E9;
    Decompile;
  end;
end;

procedure TSymbolProg.AsmFMul;
begin
  with AddRecord do
  begin
    Size := 2;
    code[0] := $DE;
    code[1] := $C9;
    Decompile;
  end;
end;

procedure TSymbolProg.AsmFDiv;
begin
  with AddRecord do
  begin
    Size := 2;
    code[0] := $DE;
    code[1] := $F9;
    Decompile;
  end;
end;

procedure TSymbolProg.AsmFChs;
begin
  with AddRecord do
  begin
    Size := 2;
    code[0] := $D9;
    code[1] := $E0;
    Decompile;
  end;
end;

procedure TSymbolProg.AsmFAbs;
begin
  with AddRecord do
  begin
    Size := 2;
    code[0] := $D9;
    code[1] := $E1;
    Decompile;
  end;
end;

procedure TSymbolProg.AsmFCompP;
begin
  with AddRecord do
  begin
    Size := 2;
    code[0] := $DE;
    code[1] := $D9;
    Decompile;
  end;
end;

procedure TSymbolProg.AsmFstsw_AX;
begin
  with AddRecord do
  begin
    Size := 2;
    code[0] := $DF;
    code[1] := $E0;
    Decompile;
  end;
end;

procedure TSymbolProg.AsmSahv;
begin
  with AddRecord do
  begin
    Size := 1;
    code[0] := $9E;
    Decompile;
  end;
end;

procedure TSymbolProg.AsmCDQ;
begin
  with AddRecord do
  begin
    Size := 1;
    code[0] := $99;
    Decompile;
  end;
end;

procedure TSymbolProg.AsmSetL_REGPtr(Reg: Integer);
begin
  with AddRecord do
  begin
    Size := 3;
    code[0] := $0F;
    code[1] := $9C;
    case Reg of
      _EAX: code[2] := $00;
      _ECX: code[2] := $01;
      _EDX: code[2] := $02;
      _EBX: code[2] := $03;
    else
      RaiseError(errInternalError, []);
    end;
    Decompile;
  end;
end;

procedure TSymbolProg.AsmSetLE_REGPtr(Reg: Integer);
begin
  with AddRecord do
  begin
    Size := 3;
    code[0] := $0F;
    code[1] := $9E;
    case Reg of
      _EAX: code[2] := $00;
      _ECX: code[2] := $01;
      _EDX: code[2] := $02;
      _EBX: code[2] := $03;
    else
      RaiseError(errInternalError, []);
    end;
    Decompile;
  end;
end;

procedure TSymbolProg.AsmSetNLE_REGPtr(Reg: Integer);
begin
  with AddRecord do
  begin
    Size := 3;
    code[0] := $0F;
    code[1] := $9F;
    case Reg of
      _EAX: code[2] := $00;
      _ECX: code[2] := $01;
      _EDX: code[2] := $02;
      _EBX: code[2] := $03;
    else
      RaiseError(errInternalError, []);
    end;
    Decompile;
  end;
end;

procedure TSymbolProg.AsmSetNL_REGPtr(Reg: Integer);
begin
  with AddRecord do
  begin
    Size := 3;
    code[0] := $0F;
    code[1] := $9D;
    case Reg of
      _EAX: code[2] := $00;
      _ECX: code[2] := $01;
      _EDX: code[2] := $02;
      _EBX: code[2] := $03;
    else
      RaiseError(errInternalError, []);
    end;
    Decompile;
  end;
end;

procedure TSymbolProg.AsmSetB_REGPtr(Reg: Integer);
begin
  with AddRecord do
  begin
    Size := 3;
    code[0] := $0F;
    code[1] := $92;
    case Reg of
      _EAX: code[2] := $00;
      _ECX: code[2] := $01;
      _EDX: code[2] := $02;
      _EBX: code[2] := $03;
    else
      RaiseError(errInternalError, []);
    end;
    Decompile;
  end;
end;

procedure TSymbolProg.AsmSet_REGPtr(ASM_OP, Reg: Integer; S: TSymbolRec);
var
  shift: Integer;
begin
  with AddRecord do
  begin
    shift := GetOffset(S);

    Size := 7;
    code[0] := $0F;

    if ASM_OP = ASM_SETB then code[1] := $92
    else if ASM_OP = ASM_SETNB then code[1] := $93
    else if ASM_OP = ASM_SETZ then code[1] := $94
    else if ASM_OP = ASM_SETNZ then code[1] := $95
    else if ASM_OP = ASM_SETBE then code[1] := $96
    else if ASM_OP = ASM_SETNBE then code[1] := $97
    else if ASM_OP = ASM_SETL then code[1] := $9C
    else if ASM_OP = ASM_SETNL then code[1] := $9D
    else if ASM_OP = ASM_SETLE then code[1] := $9E
    else if ASM_OP = ASM_SETNLE then code[1] := $9F
    else
      RaiseError(errInternalError, []);

    case Reg of
      _EAX: code[2] := $80;
      _ECX: code[2] := $81;
      _EDX: code[2] := $82;
      _EBX: code[2] := $83;
      _EBP: code[2] := $85;
      _ESI: code[2] := $86;
      else
        RaiseError(errInternalError, []);
    end;
    Move(shift, code[3], 4);
    Decompile;
  end;
end;

procedure TSymbolProg.AsmSetBE_REGPtr(Reg: Integer);
begin
  with AddRecord do
  begin
    Size := 3;
    code[0] := $0F;
    code[1] := $96;
    case Reg of
      _EAX: code[2] := $00;
      _ECX: code[2] := $01;
      _EDX: code[2] := $02;
      _EBX: code[2] := $03;
    else
      RaiseError(errInternalError, []);
    end;
    Decompile;
  end;
end;

procedure TSymbolProg.AsmSetNBE_REGPtr(Reg: Integer);
begin
  with AddRecord do
  begin
    Size := 3;
    code[0] := $0F;
    code[1] := $97;
    case Reg of
      _EAX: code[2] := $00;
      _ECX: code[2] := $01;
      _EDX: code[2] := $02;
      _EBX: code[2] := $03;
    else
      RaiseError(errInternalError, []);
    end;
    Decompile;
  end;
end;

procedure TSymbolProg.AsmSetNB_REGPtr(Reg: Integer);
begin
  with AddRecord do
  begin
    Size := 3;
    code[0] := $0F;
    code[1] := $93;
    case Reg of
      _EAX: code[2] := $00;
      _ECX: code[2] := $01;
      _EDX: code[2] := $02;
      _EBX: code[2] := $03;
    else
      RaiseError(errInternalError, []);
    end;
    Decompile;
  end;
end;

procedure TSymbolProg.AsmSetZ_REGPtr(Reg: Integer);
begin
  with AddRecord do
  begin
    Size := 3;
    code[0] := $0F;
    code[1] := $94;
    case Reg of
      _EAX: code[2] := $00;
      _ECX: code[2] := $01;
      _EDX: code[2] := $02;
      _EBX: code[2] := $03;
    else
      RaiseError(errInternalError, []);
    end;
    Decompile;
  end;
end;

procedure TSymbolProg.AsmSetNZ_REGPtr(Reg: Integer);
begin
  with AddRecord do
  begin
    Size := 3;
    code[0] := $0F;
    code[1] := $95;
    case Reg of
      _EAX: code[2] := $00;
      _ECX: code[2] := $01;
      _EDX: code[2] := $02;
      _EBX: code[2] := $03;
    else
      RaiseError(errInternalError, []);
    end;
    Decompile;
  end;
end;

procedure TSymbolProg.AsmFstpDouble_REGPtr(Reg: Integer);
begin
  with AddRecord do
  begin
    Size := 2;
    code[0] := $DD;
    case Reg of
      _EAX: code[1] := $18;
      _ECX: code[1] := $19;
      _EDX: code[1] := $1A;
      _EBX: code[1] := $1B;
    else
      RaiseError(errInternalError, []);
    end;
    Decompile;
  end;
end;

procedure TSymbolProg.AsmFstpSingle_REGPtr(Reg: Integer);
begin
  with AddRecord do
  begin
    Size := 2;
    code[0] := $D9;
    case Reg of
      _EAX: code[1] := $18;
      _ECX: code[1] := $19;
      _EDX: code[1] := $1A;
      _EBX: code[1] := $1B;
    else
      RaiseError(errInternalError, []);
    end;
    Decompile;
  end;
end;

// FStp TBYTE PTR [REG]
procedure TSymbolProg.AsmFstpExtended_REGPtr(Reg: Integer);
begin
  with AddRecord do
  begin
    Size := 2;
    code[0] := $DB;
    case Reg of
      _EAX: code[1] := $38;
      _ECX: code[1] := $39;
      _EDX: code[1] := $3A;
      _EBX: code[1] := $3B;
    else
      RaiseError(errInternalError, []);
    end;
    Decompile;
  end;
end;

// requires EmitGetAddressRegister
// FStp QWORD PTR [REG + Shift]
procedure TSymbolProg.AsmFstpDouble_REGPtr(Reg: Integer; S: TSymbolRec);
var
  shift: Integer;
begin
  shift := GetOffset(S);
  if Reg in CommonRegisters then
    Shift := 0;

  with AddRecord do
  begin
    Size := 6;
    code[0] := $DD;
    case Reg of
      _EAX: code[1] := $98;
      _ECX: code[1] := $99;
      _EDX: code[1] := $9A;
      _EBX: code[1] := $9B;
      _EBP: code[1] := $9D;
      _ESI: code[1] := $9E;
    else
      RaiseError(errInternalError, []);
    end;
    Move(shift, code[2], 4);
    Decompile;
  end;
end;

// requires EmitGetAddressRegister
// FStp DWORD PTR [REG + Shift]
procedure TSymbolProg.AsmFstpSingle_REGPtr(Reg: Integer; S: TSymbolRec);
var
  shift: Integer;
begin
  shift := GetOffset(S);
  if Reg in CommonRegisters then
    Shift := 0;

  with AddRecord do
  begin
    Size := 6;
    code[0] := $D9;
    case Reg of
      _EAX: code[1] := $98;
      _ECX: code[1] := $99;
      _EDX: code[1] := $9A;
      _EBX: code[1] := $9B;
      _EBP: code[1] := $9D;
      _ESI: code[1] := $9E;
    else
      RaiseError(errInternalError, []);
    end;
    Move(shift, code[2], 4);
    Decompile;
  end;
end;

// requires EmitGetAddressRegister
// FStp TBYTE PTR [REG + Shift]
procedure TSymbolProg.AsmFstpExtended_REGPtr(Reg: Integer; S: TSymbolRec);
var
  shift: Integer;
begin
  shift := GetOffset(S);
  if Reg in CommonRegisters then
    Shift := 0;

  with AddRecord do
  begin
    Size := 6;
    code[0] := $DB;
    case Reg of
      _EAX: code[1] := $B8;
      _ECX: code[1] := $B9;
      _EDX: code[1] := $BA;
      _EBX: code[1] := $BB;
      _EBP: code[1] := $BD;
      _ESI: code[1] := $BE;
    else
      RaiseError(errInternalError, []);
    end;
    Move(shift, code[2], 4);
    Decompile;
  end;
end;

procedure TSymbolProg.AsmCmpByteREGPtr_Imm(Reg: Integer; value: Byte);
begin
  with AddRecord do
  begin
    Size := 3;
    code[0] := $80;
    case Reg of
      _EAX: code[1] := $38;
      _ECX: code[1] := $39;
      _EDX: code[1] := $3A;
      _EBX: code[1] := $3B;
    else
      RaiseError(errInternalError, []);
    end;
    code[2] := value;
    Decompile;
  end;
end;

procedure TSymbolProg.AsmJmp_REG(Reg: Integer);
begin
  with AddRecord do
  begin
    Size := 2;
    code[0] := $FF;
    case Reg of
      _EAX: code[1] := $E0;
      _ECX: code[1] := $E1;
      _EDX: code[1] := $E2;
      _EBX: code[1] := $E3;
    else
      RaiseError(errInternalError, []);
    end;
    Decompile;
  end;
end;

procedure TSymbolProg.AsmCall_REG(Reg: Integer);
begin
  with AddRecord do
  begin
    Size := 2;
    code[0] := $FF;
    case Reg of
      _EAX: code[1] := $D0;
      _ECX: code[1] := $D1;
      _EDX: code[1] := $D2;
      _EBX: code[1] := $D3;
    else
      RaiseError(errInternalError, []);
    end;
    Decompile;
  end;
end;

procedure TSymbolProg.AsmPush_Imm(value: Integer);
begin
  with AddRecord do
  begin
    Size := 5;
    code[0] := $68;
    Move(value, code[1], 4);
    Decompile;
  end;
end;

procedure TSymbolProg.AsmPush_REG(Reg: Integer);
begin
  with AddRecord do
  begin
    Size := 1;
    case Reg of
      _EAX: code[0] := $50;
      _ECX: code[0] := $51;
      _EDX: code[0] := $52;
      _EBX: code[0] := $53;
      _ESP: code[0] := $54;
      _EBP: code[0] := $55;
      _ESI: code[0] := $56;
      _EDI: code[0] := $57;
    else
      RaiseError(errInternalError, []);
    end;
    Decompile;
  end;
end;

procedure TSymbolProg.AsmPop_REG(Reg: Integer);
begin
  with AddRecord do
  begin
    Size := 1;
    case Reg of
      _EAX: code[0] := $58;
      _ECX: code[0] := $59;
      _EDX: code[0] := $5A;
      _EBX: code[0] := $5B;
      _ESP: code[0] := $5C;
      _EBP: code[0] := $5D;
      _ESI: code[0] := $5E;
      _EDI: code[0] := $5F;
    else
      RaiseError(errInternalError, []);
    end;
    Decompile;
  end;
end;

procedure TSymbolProg.AsmPush_REGPtr(Reg: Integer);
begin
  with AddRecord do
  begin
    Size := 2;
    code[0] := $FF;
    case Reg of
      _EAX: code[1] := $30;
      _ECX: code[1] := $31;
      _EDX: code[1] := $32;
      _EBX: code[1] := $33;
    else
      RaiseError(errInternalError, []);
    end;
    Decompile;
  end;
end;

procedure TSymbolProg.AsmPush_Reg16(Reg: Integer);
begin
  with AddRecord do
  begin
    Size := 2;
    code[0] := $66;
    case Reg of
      _EAX: code[1] := $50;
      _ECX: code[1] := $51;
      _EDX: code[1] := $52;
      _EBX: code[1] := $53;
    else
      RaiseError(errInternalError, []);
    end;
    Decompile;
  end;
end;

procedure TSymbolProg.AsmRet(value: Word = 0);
begin
  with AddRecord do
  begin
    if value = 0 then
    begin
      Size := 1;
      code[0] := $c3;
    end
    else
    begin
      Size := 3;
      code[0] := $c2;
      Move(value, code[1], 2);
    end;
    Decompile;
  end;
end;

procedure TSymbolProg.AsmNop;
begin
  with AddRecord do
  begin
    Size := 1;
    code[0] := $90;
    Decompile;
  end;
end;

procedure TSymbolProg.AsmWait;
begin
  with AddRecord do
  begin
    Size := 1;
    code[0] := $9B;
    Decompile;
  end;
end;

procedure TSymbolProg.AsmClc;
begin
  with AddRecord do
  begin
    Size := 1;
    code[0] := $F8;
    Decompile;
  end;
end;

procedure TSymbolProg.AsmPushfd;
begin
  with AddRecord do
  begin
    Size := 1;
    code[0] := $9C;
    Decompile;
  end;
end;

procedure TSymbolProg.AsmPopfd;
begin
  with AddRecord do
  begin
    Size := 1;
    code[0] := $9D;
    Decompile;
  end;
end;

procedure TSymbolProg.AsmXCHG(Reg1, Reg2: Integer);
begin
  with AddRecord do
  begin
    if Reg2 = _EAX then
    begin
      Reg2 := Reg1;
      Reg1 := _EAX;
    end;

    if Reg1 = _EAX then
    begin
      Size := 1;
      case Reg2 of
        _EAX: code[0] := $90; // nop
        _ECX: code[0] := $91;
        _EDX: code[0] := $92;
        _EBX: code[0] := $93;
        _ESP: code[0] := $94;
        _EBP: code[0] := $95;
        _ESI: code[0] := $96;
        _EDI: code[0] := $97;
      else
        RaiseError(errInternalError, []);
      end;
    end
    else if Reg1 = _ECX then
    begin
      Size := 2;
      code[0] := $87;
      case Reg2 of
        _ECX: code[1] := $C9;
        _EDX: code[1] := $CA;
        _EBX: code[1] := $CB;
        _ESP: code[1] := $CC;
        _EBP: code[1] := $CD;
        _ESI: code[1] := $CE;
        _EDI: code[1] := $CF;
      else
        RaiseError(errInternalError, []);
      end;
    end
    else if Reg1 = _EDX then
    begin
      Size := 2;
      code[0] := $87;
      case Reg2 of
        _ECX: code[1] := $D1;
        _EDX: code[1] := $D2;
        _EBX: code[1] := $D3;
        _ESP: code[1] := $D4;
        _EBP: code[1] := $D5;
        _ESI: code[1] := $D6;
        _EDI: code[1] := $D7;
      else
        RaiseError(errInternalError, []);
      end;
    end
    else if Reg1 = _EBX then
    begin
      Size := 2;
      code[0] := $87;
      case Reg2 of
        _ECX: code[1] := $D9;
        _EDX: code[1] := $DA;
        _EBX: code[1] := $DB;
        _ESP: code[1] := $DC;
        _EBP: code[1] := $DD;
        _ESI: code[1] := $DE;
        _EDI: code[1] := $DF;
      else
        RaiseError(errInternalError, []);
      end;
    end
    else
      RaiseError(errInternalError, []);

    Decompile;
  end;
end;

procedure TSymbolProg.AsmJMP_Imm(value: Integer);
begin
  with AddRecord do
  begin
    Size := 5;
    code[0] := $E9;
    Move(value, code[1], 4);
    Decompile;
  end;
end;

procedure TSymbolProg.AsmJNO_Imm(value: Byte);
begin
  with AddRecord do
  begin
    Size := 2;
    code[0] := $71;
    code[1] := value;
    Decompile;
  end;
end;

procedure TSymbolProg.AsmJNC_Imm(value: Byte);
begin
  with AddRecord do
  begin
    Size := 2;
    code[0] := $73;
    code[1] := value;
    Decompile;
  end;
end;

procedure TSymbolProg.AsmJZ_Imm(value: Byte);
begin
  with AddRecord do
  begin
    Size := 2;
    code[0] := $74;
    code[1] := value;
    Decompile;
  end;
end;

procedure TSymbolProg.AsmJNZ_Imm(value: Byte);
begin
  with AddRecord do
  begin
    Size := 2;
    code[0] := $75;
    code[1] := value;
    Decompile;
  end;
end;

procedure TSymbolProg.AsmJBE_Imm(value: Byte);
begin
  with AddRecord do
  begin
    Size := 2;
    code[0] := $76;
    code[1] := value;
    Decompile;
  end;
end;

procedure TSymbolProg.AsmJNLE_Imm(value: Byte);
begin
  with AddRecord do
  begin
    Size := 2;
    code[0] := $7F;
    code[1] := value;
    Decompile;
  end;
end;


procedure TSymbolProg.AsmRep_MOVSB;
begin
  with AddRecord do
  begin
    Size := 2;
    code[0] := $F3;
    code[1] := $A4;
    Decompile;
  end;
end;

procedure TSymbolProg.AsmRep_MOVSD;
begin
  with AddRecord do
  begin
    Size := 2;
    code[0] := $F3;
    code[1] := $A5;
    Decompile;
  end;
end;

function TSymbolProg.GetRecord(I: Integer): TSymbolProgRec;
begin
  result := TSymbolProgRec(L[I - 1]);
end;

procedure TSymbolProg.Optimization;
var
  I: Integer;
begin
  for I:= 1 to Card - 1 do
    if Records[I].Op = ASM_MOV then
    begin

      if Records[I + 1].Op = ASM_MOV then
      begin
        if EqualArgs(Records[I].Arg1, Records[I+1].Arg2) and
           EqualArgs(Records[I].Arg2, Records[I+1].Arg1) then
        begin
          Records[I+1].Size := 0;
        end;
      end
      else if (Records[I + 2].Op = ASM_MOV) and (Records[I + 1].Size < 0) then
      begin
        if EqualArgs(Records[I].Arg1, Records[I+2].Arg2) and
           EqualArgs(Records[I].Arg2, Records[I+2].Arg1) then
        begin
          Records[I+2].Size := -1;
        end;
      end
    end;

  for I:=Card downto 1 do
    if Records[I].Size = 0 then
      Delete(I);
end;

procedure TSymbolProg.CreateProgramSimple(result: TProgram);
var
  I, N, SZ: Integer;
begin
  result.AllocateSimple(ProgSize, 0);
  N := 0;
  for I:=1 to Card do
  begin
    SZ := Records[I].Size;
    if SZ >= 0 then
    begin
      Move(Records[I].code, result.CodePtr^[N], SZ);
      Inc(N, SZ);
    end;
  end;
end;

procedure TSymbolProg.CreateProgram(result: TProgram);
var
  I, J, K, N, SZ: Integer;
  SymbolTable: TSymbolTable;
  Shift: Integer;
  ProgOffset: Integer;
  PData: Pointer;
  P: Pointer;
  S: AnsiString;
  TypeId: Integer;

  Code: TCode;
  OP: Integer;
  ID: Integer;
  TryRec: TTryRec;
  ClsIndex: Integer;
  I64: Int64;
  ClassRec: TClassRec;
  DestructorId,
  AfterConstructionId,
  BeforeDestructionId,
  SafeCallExceptionId,
  DispatchId,
  DefaultHandlerId,
  NewInstanceId,
  FreeInstanceId : Integer;
  ByteSet: TByteSet;
  SetSize: Integer;
  RR: TSymbolRec;
  VCardinal: Cardinal;
  GUID: TGUID;
  WS: WideString;
  RI: TSymbolRec;
  temp: Boolean;
  IntfId: Integer;
  InterfaceMethodIds: TIntegerList;
  ClassMethodIds: TIntegerList;
  IntfRec: TIntfRec;

  UpdatedProgSize, LastCard, NN: Integer;
  PaxInfo: PPaxInfo;
  PaxFactoryRec: TPaxClassFactoryRec;
  VT: Integer;
  SS: String;
  ConstId: Integer;
begin
  SymbolTable := TKernel(kernel).SymbolTable;
  Code := TKernel(kernel).Code;

  if TKernel(kernel).SignCompression then
    SZ := TKernel(kernel).OffsetList.GetSize
  else
    SZ := SymbolTable.GetDataSize;

  temp := result.UseMapping;
  result.UseMapping := false;
  result.Allocate(ProgSize, SZ);
  result.UseMapping := temp;

  N := 0;
  for I:=1 to Card do
  begin
    SZ := Records[I].Size;
    if SZ >= 0 then
    begin
      Records[I].ProgOffset := N;

      Move(Records[I].code, result.CodePtr^[N], SZ);
      Inc(N, SZ);
    end;
  end;

  LastCard := Card;
  NN := N;
  UpdatedProgSize := ProgSize;

  PData := result.ResultPtr;

  I := 0;
  while I < SymbolTable.Card do
  begin
    Inc(I);

    if not SymbolTable.InCode[I] then
      continue;

    RI := SymbolTable[I];

    if RI = SR0 then
      continue;

    if RI.Shift = 0 then
      continue;

    case RI.Kind of
      KindCONST:
        case RI.FinalTypeID of
          typeDOUBLE:
          begin
            Shift := GetOffset(RI);
            P := ShiftPointer(PData, Shift);
            Double(P^) := Double(RI.Value);
          end;
          typeSINGLE:
          begin
            Shift := GetOffset(RI);
            P := ShiftPointer(PData, Shift);
            Single(P^) := Single(RI.Value);
          end;
          typeEXTENDED:
          begin
            Shift := GetOffset(RI);
            P := ShiftPointer(PData, Shift);
            Extended(P^) := Extended(RI.Value);
          end;
          typeCURRENCY:
          begin
            Shift := GetOffset(RI);
            P := ShiftPointer(PData, Shift);
            Currency(P^) := Currency(RI.Value);
          end;

{$IFDEF VARIANTS}
          typeINT64:
          begin
            Shift := GetOffset(RI);
            P := ShiftPointer(PData, Shift);
            I64 := RI.Value;
            Int64(P^) := I64;
          end;
{$ELSE}
          typeINT64:
          begin
            Shift := GetOffset(RI);
            P := ShiftPointer(PData, Shift);
            I64 := Integer(RI.Value);
            Int64(P^) := I64;
          end;
{$ENDIF}
          typeINTEGER, typeCLASS:
          if RI.MustBeAllocated then
          begin
            Shift := GetOffset(RI);
            P := ShiftPointer(PData, Shift);
            Integer(P^) := Integer(RI.Value);
          end;
          typeSHORTINT:
          if RI.MustBeAllocated then
          begin
            Shift := GetOffset(RI);
            P := ShiftPointer(PData, Shift);
            ShortInt(P^) := Integer(RI.Value);
          end;
          typeSMALLINT:
          if RI.MustBeAllocated then
          begin
            Shift := GetOffset(RI);
            P := ShiftPointer(PData, Shift);
            SmallInt(P^) := Integer(RI.Value);
          end;
          typeWORD:
          if RI.MustBeAllocated then
          begin
            Shift := GetOffset(RI);
            P := ShiftPointer(PData, Shift);
            VCardinal := RI.Value;
            Word(P^) := VCardinal;
          end;
          typeBOOLEAN:
          if RI.MustBeAllocated then
          begin
            Shift := GetOffset(RI);
            P := ShiftPointer(PData, Shift);
            Boolean(P^) := RI.Value;
          end;
          typeBYTEBOOL:
          if RI.MustBeAllocated then
          begin
            Shift := GetOffset(RI);
            P := ShiftPointer(PData, Shift);
            ByteBool(P^) := RI.Value;
          end;
          typeWORDBOOL:
          if RI.MustBeAllocated then
          begin
            Shift := GetOffset(RI);
            P := ShiftPointer(PData, Shift);
            WordBool(P^) := RI.Value;
          end;
          typeLONGBOOL:
          if RI.MustBeAllocated then
          begin
            Shift := GetOffset(RI);
            P := ShiftPointer(PData, Shift);
            LongBool(P^) := RI.Value;
          end;
          typeBYTE:
          if RI.MustBeAllocated then
          begin
            Shift := GetOffset(RI);
            P := ShiftPointer(PData, Shift);
            VCardinal := RI.Value;
            Byte(P^) := VCardinal;
          end;
          typeCARDINAL:
          if RI.MustBeAllocated then
          begin
            Shift := GetOffset(RI);
            P := ShiftPointer(PData, Shift);
            VCardinal := RI.Value;
            Cardinal(P^) := VCardinal;
          end;
          typeVARIANT:
          begin
            Shift := GetOffset(RI);
            P := ShiftPointer(PData, Shift);
            Variant(P^) := RI.Value;
          end;
          typeOLEVARIANT:
          begin
            Shift := GetOffset(RI);
            P := ShiftPointer(PData, Shift);
            OleVariant(P^) := RI.Value;
          end;
          typeSET:
          begin
            Shift := GetOffset(RI);
            P := ShiftPointer(PData, Shift);
            ByteSet := RI.ValueAsByteSet;
            SetSize := SymbolTable.GetSizeOfSetType(RI.TerminalTypeId);
            Move(ByteSet, P^, SetSize);
          end;
          typeCLASSREF:
          begin
            Shift := GetOffset(RI);
            P := ShiftPointer(PData, Shift);
            Integer(P^) := Integer(RI.Value);
          end;
          typeRECORD:
          if RI.TerminalTypeId = H_TGUID then
          begin
            VT := VarType(RI.Value);
            if (VT = varString) or (VT = varUString) then
            begin
              Shift := GetOffset(RI);
              P := ShiftPointer(PData, Shift);
              SS := RI.Value;
              GUID := StringToGuid(SS);
              Move(GUID, P^, SizeOf(TGUID));
            end;
          end;
          typePOINTER:
          begin
            TypeID := RI.TypeId;
            if SymbolTable[TypeId].PatternId = typeANSICHAR then
            begin
              S := AnsiString(RI.Value);

              Shift := GetOffset(RI);
              P := ShiftPointer(PData, Shift + 4);
              Integer(P^) := -1;

              P := ShiftPointer(P, 4);
              Integer(P^) := Length(S);

              P := ShiftPointer(P, 4);

              if S = '' then
                Byte(P^) := 0
              else
                Move(Pointer(S)^, P^, Length(S) + 1);
            end
            else if SymbolTable[TypeId].PatternId = typeWIDECHAR then
            begin
              WS := RI.Value;

              Shift := GetOffset(RI);
              P := ShiftPointer(PData, Shift);

              P := ShiftPointer(P, 4);
              Integer(P^) := Length(WS) * 2;

              P := ShiftPointer(P, 4);

              if WS = '' then
                Byte(P^) := 0
              else
              begin
                for J := 1 to Length(WS) do
                begin
                  Move(WS[J], P^, SizeOf(WideChar));
                  Inc(Integer(P), 2);
                end;
                Byte(P^) := 0;
              end;
            end
            else
              if RI.MustBeAllocated then
              begin
                Shift := GetOffset(RI);
                P := ShiftPointer(PData, Shift);
                VCardinal := RI.Value;
                Cardinal(P^) := VCardinal;
              end;
          end;
        end;
      KindVAR:
      if (RI.IsStatic) and (not IsEmpty(RI.Value)) then
        case RI.FinalTypeID of
          typeBOOLEAN, typeBYTE, typeANSICHAR:
          begin
            Shift := GetOffset(RI);
            P := ShiftPointer(PData, Shift);
            Byte(P^) := Integer(RI.Value);
          end;
          typeINTEGER:
          begin
            Shift := GetOffset(RI);
            P := ShiftPointer(PData, Shift);
            Integer(P^) := Integer(RI.Value);
          end;
          typeDOUBLE:
          begin
            Shift := GetOffset(RI);
            P := ShiftPointer(PData, Shift);
            Double(P^) := Double(RI.Value);
          end;
          typeSINGLE:
          begin
            Shift := GetOffset(RI);
            P := ShiftPointer(PData, Shift);
            Single(P^) := Single(RI.Value);
          end;
          typeEXTENDED:
          begin
            Shift := GetOffset(RI);
            P := ShiftPointer(PData, Shift);
            Extended(P^) := Extended(RI.Value);
          end;
          typeCURRENCY:
          begin
            Shift := GetOffset(RI);
            P := ShiftPointer(PData, Shift);
            Currency(P^) := Currency(RI.Value);
          end;
{$IFDEF VARIANTS}
          typeINT64:
          begin
            Shift := GetOffset(RI);
            P := ShiftPointer(PData, Shift);
            I64 := RI.Value;
            Int64(P^) := I64;
          end;
{$ELSE}
          typeINT64:
          begin
            Shift := GetOffset(RI);
            P := ShiftPointer(PData, Shift);
            I64 := Integer(RI.Value);
            Int64(P^) := I64;
          end;
{$ENDIF}
          typeSET:
          begin
            Shift := GetOffset(RI);
            P := ShiftPointer(PData, Shift);
            ByteSet := RI.ValueAsByteSet;
            SetSize := SymbolTable.GetSizeOfSetType(RI.TerminalTypeId);
            Move(ByteSet, P^, SetSize);
          end;

          typeCLASSREF:
          begin
            Shift := GetOffset(RI);
            P := ShiftPointer(PData, Shift);
            Integer(P^) := Integer(RI.Value);
          end;

          typeVARIANT:
          begin
            Shift := GetOffset(RI);
            P := ShiftPointer(PData, Shift);
            Variant(P^) := Variant(RI.Value);
          end;

          typeOLEVARIANT:
          begin
            Shift := GetOffset(RI);
            P := ShiftPointer(PData, Shift);
            OleVariant(P^) := Variant(RI.Value);
          end;
          
          typeRECORD:
          if RI.TerminalTypeId = H_TGUID then
          begin
            VT := VarType(RI.Value);
            if (VT = varString) or (VT = varUString) then
            begin
              Shift := GetOffset(RI);
              P := ShiftPointer(PData, Shift);
              SS := RI.Value;
              GUID := StringToGuid(SS);
              Move(GUID, P^, SizeOf(TGUID));
            end;
          end;
      end;
      KindSUB:
      if not RI.Host then
      begin
        Shift := GetOffset(RI);
        P := ShiftPointer(PData, Shift);
        Integer(P^) := RI.Value;
      end;
    end; // case
  end;

  with SymbolTable do
  for I:=GlobalSymbolTable.Card + 1 to Card do
    if Records[I].Host then
    begin
      RR := SymbolTable[I];

      if RR.Address <> nil then
      begin
        if not InCode[I] then
          continue;

        result.SetAddress(GetOffset(RR), RR.Address);
      end
      else if RR.ClassIndex <> -1 then
      begin
        RR := SymbolTable[I + 1]; // cls ref
        J := RR.Value;
        if J = 0 then
        begin
          ClassRec := result.ClassList.Add(SymbolTable[I].FullName, SymbolTable[I].Host);
          ClassRec.InstSize := 4;
        end
        else
        begin
          ClassRec := result.RegisterClass(TClass(J), SymbolTable[I].FullName, GetOffset(RR));
          ClassRec.InstSize := TClass(J).InstanceSize;
        end;
        ClassRec.ParentFullName := Records[Records[I].AncestorId].FullName;
      end;
    end
    else
      if Records[I].ClassIndex > 0 then
      begin
        ClassRec := result.ClassList.Add(Records[I].FullName, Records[I].Host);
        ClassRec.Host := false;
        ClassRec.Offset := GetOffset(Records[I + 1]);
        ClassRec.SizeOfScriptClassFields := Records[I].SizeOfScriptClassFields;

        ClassRec.PClass := TClass(Integer(Records[I + 1].Value));
        ClassRec.ParentFullName := Records[Records[I].AncestorId].FullName;

        DestructorId := FindDestructorId(I);
        if DestructorId > 0 then
          ClassRec.DestructorProgOffset := Records[DestructorId].Value;

        SafeCallExceptionId := Lookup('SafeCallException', I, true);
        if SafeCallExceptionId > 0 then
          ClassRec.SafeCallExceptionProgOffset := Records[SafeCallExceptionId].Value;

        AfterConstructionId := Lookup('AfterConstruction', I, true);
        if AfterConstructionId > 0 then
          ClassRec.AfterConstructionProgOffset := Records[AfterConstructionId].Value;

        BeforeDestructionId := Lookup('BeforeDestruction', I, true);
        if BeforeDestructionId > 0 then
          ClassRec.BeforeDestructionProgOffset := Records[BeforeDestructionId].Value;

        DispatchId := Lookup('Dispatch', I, true);
        if DispatchId > 0 then
          ClassRec.DispatchProgOffset := Records[DispatchId].Value;

        DefaultHandlerId := Lookup('DefaultHandler', I, true);
        if DefaultHandlerId > 0 then
          ClassRec.DefaultHandlerProgOffset := Records[DefaultHandlerId].Value;

        NewInstanceId := Lookup('NewInstance', I, true);
        if NewInstanceId > 0 then
          ClassRec.NewInstanceProgOffset := Records[NewInstanceId].Value;

        FreeInstanceId := Lookup('FreeInstance', I, true);
        if FreeInstanceId > 0 then
          ClassRec.FreeInstanceProgOffset := Records[FreeInstanceId].Value;

        PaxInfo := GetPaxInfo(ClassRec.PClass);
        if PaxInfo = nil then
          RaiseError(errInternalError, []);
        PaxInfo^.Prog := result;
        PaxInfo^.ClassIndex := Records[I].ClassIndex;

        PaxFactoryRec := TKernel(kernel).ClassFactory.FindRecord(ClassRec.PClass);
        if PaxFactoryRec = nil then
          RaiseError(errInternalError, []);

        if Records[I].SupportedInterfaces = nil then
        begin
          ClassRec.InstSize := Records[I].SizeOfAllClassFields;
          PaxFactoryRec.SetInstanceSize(ClassRec.InstSize);
          continue;
        end
        else
        begin
          ClassRec.InstSize := Records[I].SizeOfAllClassFields +
            Records[I].SupportedInterfaces.Count * 4;
          PaxFactoryRec.SetInstanceSize(ClassRec.InstSize);
        end;

        if Records[I].SupportedInterfaces.Count = 0 then
          continue;

        InterfaceMethodIds := TIntegerList.Create;
        ClassMethodIds := TIntegerList.Create;
        try
          for J:=0 to Records[I].SupportedInterfaces.Count - 1 do
          begin

            IntfId := Records[I].SupportedInterfaces[J].Id;
            CreateInterfaceMethodList(I, IntfId,
                                    InterfaceMethodIds,
                                    ClassMethodIds);
            if InterfaceMethodIds.Count > 0 then // some methods not found
            begin
              for K:=0 to InterfaceMethodIds.Count - 1 do
              begin
                Code.N := Code.FindRecord1(OP_END_CLASS_TYPE, I);
                CreateError(errUndeclaredIdentifier,
                   [Records[InterfaceMethodIds[K]].Name]);
              end;
              break;
            end
            else
            begin
              IntfRec := ClassRec.IntfList.Add;
              IntfRec.GUID := Records[I].SupportedInterfaces[J].GUID;
              for K:=0 to ClassMethodIds.Count - 1 do
              begin
                Id := ClassMethodIds[K];

                IntfRec.IntfMethods.AddMethod(Records[Id].FullName, UpdatedProgSize);

                if Records[Id].CallConv in [ccSTDCALL, ccCDECL, ccPASCAL, ccSAFECALL] then
                begin
                  AsmPop_REG(_EBX);
                  AsmPop_REG(_EAX);
                  Inc(UpdatedProgSize, 1 + 1);
                end;

                AsmAddREG_Imm(_EAX, -Records[I].SizeOfAllClassFields + J * 4); //5
                Inc(UpdatedProgSize, 5);

                // EAX contains instance of object

                if Records[Id].CallConv in [ccSTDCALL, ccCDECL, ccPASCAL, ccSAFECALL] then
                begin
                  AsmPush_REG(_EAX);
                  AsmPush_REG(_EBX);
                  Inc(UpdatedProgSize, 1 + 1);
                end;

                // jump to address

                if Records[Id].Host then
                begin
                  AsmGetREG32_ESIPtr(_EBX, GetOffset(Records[Id]));

                  Inc(UpdatedProgSize, 6);
                end
                else
                begin
                  AsmMovREG_REG(_EBX, _EDI);
                  AsmAddREG_Imm(_EBX, Records[Id].Value);

                  Inc(UpdatedProgSize, 2);
                  Inc(UpdatedProgSize, 6);

                end;
                AsmJMP_REG(_EBX);
                Inc(UpdatedProgSize, 2);
              end;
            end;
          end;
        finally
          InterfaceMethodIds.Free;
          ClassMethodIds.Free;
        end;
      end;

  result.Reallocate(UpdatedProgSize);

  for I:= LastCard + 1 to Card do
  begin
    SZ := Records[I].Size;
    if SZ >= 0 then
    begin
      Records[I].ProgOffset := NN;

      Move(Records[I].code, result.CodePtr^[NN], SZ);
      Inc(NN, SZ);
    end;
  end;

  result.TryList.Clear;
  result.RootTryStack.Clear;

  for I:=1 to Code.Card do
    if Code[I].Op = OP_TRY_ON then
    begin
      TryRec := result.TryList.Add;
      TryRec.Level := Code[I].Res;
    end;

  for I:=1 to Code.Card do
  begin
    OP := Code[I].Op;
    if OP = OP_FINALLY then
    begin
      ID := Code[I].Arg2;
      ProgOffset := SymbolTable[ID].Value;

      TryRec := result.TryList[Code[I].Arg1];

      TryRec.TryKind := tryFinally;
      TryRec._ESP := 0;                    // will be determined at run-time
      TryRec._EBP := 0;                    // will be determined at run-time
      TryRec.ProgOffset := ProgOffset;

      TryRec.N := I;
    end
    else if OP = OP_EXCEPT then
    begin
      ID := Code[I].Arg2;
      ProgOffset := SymbolTable[ID].Value;

      TryRec := result.TryList[Code[I].Arg1];

      TryRec.TryKind := tryExcept;
      TryRec._ESP := 0;                    // will be determined at run-time
      TryRec._EBP := 0;                    // will be determined at run-time
      TryRec.ProgOffset := ProgOffset;

      TryRec.N := I;
    end
    else if OP = OP_EXCEPT_ON then
    begin
      ID := Code[I].Arg2;
      ProgOffset := SymbolTable[ID].Value;

      TryRec := result.TryList[Code[I].Arg1];

      if Code[I].Res = 0 then
        ClsIndex := -1  // else part
      else
      begin
        ID := SymbolTable[Code[I].Res].TerminalTypeId;
        ClsIndex := SymbolTable[ID].ClassIndex;

        if ClsIndex <= 0 then
          RaiseError(errInternalError, []);
      end;

      TryRec.ExceptOnInfo.Add(ClsIndex, ProgOffset);

      TryRec.N := I;
    end;
  end;

  CreateRTI(result);      
  CreateZList(result);

  SymbolTable.ProcessClassFactory(Tkernel(kernel).ClassFactory, result);

  TKernel(kernel).ClassFactory.SetupStdVirtuals(result.ClassList, result.CodePtr);

  result.ProgTypeInfoList.AddToProgram(result);

  for I:= 1 to Card do
    if Records[I].MustBeFixed then
    begin
      if SymbolTable[Records[I].SubId].MethodIndex = 0 then
        TKernel(kernel).CreateError(errInternalErrorMethodIndex, []);

      Shift := (SymbolTable[Records[I].SubId].MethodIndex - 1) * 4;
      Move(Shift, Records[I].Code[Records[I].OpOffset], 4);
      Records[I].Decompile;
      Move(Shift, ShiftPointer(result.CodePtr, Records[I].ProgOffset + Records[I].OpOffset)^, 4);
    end;
end;

procedure TSymbolProg.CreateZList(P: TProgram);
var
  I, S: Integer;
  R: TSymbolProgRec;
begin
  P.ZList.Clear;
  for I:=1 to Card do
  begin
    R := Records[I];
    if R.Z then
    begin
      S := GetShiftOfRecord(R);
      P.ZList.Add(S);
    end;
  end;
  P.SetZList;
end;

procedure TSymbolProg.CreateRTI(aprogram: TProgram);
var
  RuntimeModuleList: TRuntimeModuleList;
  I, J, K, Index, Id: Integer;
  Code: TCode;
  Modules: TModuleList;
  UsedName: String;
begin
  Code := TKernel(kernel).Code;
  Modules := TKernel(kernel).Modules;

  RuntimeModuleList := aprogram.RunTimeModuleList;
  RuntimeModuleList.Clear;

  SetLength(RuntimeModuleList.SourceLines, Code.Card + 1);
  SetLength(RuntimeModuleList.ModuleIndexes, Code.Card + 1);

  for I:=1 to Code.Card do
  begin
    RuntimeModuleList.SourceLines[I] := Code.GetSourceLineNumber(I);
    RuntimeModuleList.ModuleIndexes[I] := Code.GetModuleNumber(I);
  end;

  for I:=0 to Modules.Count - 1 do
  with RuntimeModuleList.Modules.AddRecord do
  begin
    ModuleName := Modules[I].Name;
    P1 := Modules[I].P1;
    P2 := Modules[I].P2;
    P3 := Modules[I].P3;

    UsedModules.Clear;
    for J:=P1 to P2 do
    begin
      if Code[J].Op = OP_BEGIN_USING then
      begin
        Id := Code[J].Arg1;
        if Id > 0 then
        begin
          UsedName := Code.GetSymbolRec(Id).Name;
          if StrEql(UsedName, ModuleName) then
            continue;
          if StrEql(UsedName, strPascalNamespace) then
            continue;
          if StrEql(UsedName, strBasicNamespace) then
            continue;

          Index := -1;
          for K := 0 to UsedModules.Count - 1 do
            if StrEql(UsedModules[K], UsedName) then
            begin
              Index := K;
              break;
            end;
          if Index = -1 then
            UsedModules.Add(UsedName);
        end;
      end;
    end;
  end;
end;

procedure TSymbolProg.RaiseError(const Message: string; params: array of Const);
begin
  raise Exception.Create(Format(Message, params));
end;

procedure TSymbolProg.CreateError(const Message: string; params: array of Const);
begin
  TKernel(kernel).CreateError(Message, params);
end;

function TSymbolProg.GetOffset(S: TSymbolRec): Integer;
begin
  result := TKernel(kernel).GetOffset(S);
end;

end.
