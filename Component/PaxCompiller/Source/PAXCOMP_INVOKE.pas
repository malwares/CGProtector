////////////////////////////////////////////////////////////////////////////
// PaxInvoke
// Site: http://www.paxcompiler.com
// Author: Alexander Baranovsky (paxscript@gmail.com)
// ========================================================================
// Copyright (c) Alexander Baranovsky, 2006-2008. All rights reserved.
// Code Version: 2.4
// ========================================================================
// Unit: PAXCOMP_INVOKE.pas
// ========================================================================
////////////////////////////////////////////////////////////////////////////

{$I PaxCompiler.def}
{$O-}
unit PAXCOMP_INVOKE;
interface

uses
{$IFDEF LINUX}
{$IFDEF FPC}
  DynLibs,
{$ELSE}
{$ENDIF}
{$ENDIF}
{$IFNDEF LINUX}
  Windows,
{$ENDIF}

{$IFDEF VARIANTS}
  Variants,
{$ENDIF}
  SysUtils,
  Classes;

const
  MaxArgs = 20;
  __typeVOID = 1;
  __typeBOOLEAN = 2;
  __typeBYTE = 3;
  __typeANSICHAR = 4;
  __typeANSISTRING = 5;
  __typeWORD = 6;
  __typeINTEGER = 7;
  __typeDOUBLE = 8;
  __typePOINTER = 9;
  __typeRECORD = 10;
  __typeARRAY = 11;
  __typeALIAS = 12;
  __typeENUM = 13;
  __typePROC = 14;
  __typeSET = 15;
  __typeSHORTSTRING = 16;
  __typeSINGLE = 17;
  __typeEXTENDED = 18;
  __typeCLASS = 19;
  __typeCLASSREF = 20;
  __typeWIDECHAR = 21;
  __typeWIDESTRING = 22;
  __typeVARIANT = 23;
  __typeDYNARRAY = 24;
  __typeINT64 = 25;
  __typeINTERFACE = 26;
  __typeCARDINAL = 27;
  __typeEVENT = 28;
  __typeCURRENCY = 29;
  __typeSMALLINT = 30;
  __typeSHORTINT = 31;
  __typeWORDBOOL = 32;
  __typeLONGBOOL = 33;
  __typeBYTEBOOL = 34;
  __typeOLEVARIANT = 35;
  __typeUNICSTRING = 36;

  __typePANSICHAR = 49;
  __typePVOID = 50;
  __typePWIDECHAR = 51;

  __typeVALVALUE = 52;

{$IFDEF UNIC}
  __typeSTRING = __typeUNICSTRING;
  __typeCHAR = __typeWIDECHAR;
  __typePCHAR = __typePWIDECHAR;
{$ELSE}
  __typeSTRING = __typeANSISTRING;
  __typeCHAR = __typeANSICHAR;
  __typePCHAR = __typePANSICHAR;
{$ENDIF}

  varValValue = $0E;

type
  TIntegerArr = array[0..4096] of Integer;
  PIntegerArr = ^TIntegerArr;

  TValValue = class
  private
    fBuff: PIntegerArr;
    fSize: Integer;
  public
    constructor Create(var V; iSize: Integer);
    destructor Destroy; override;
    procedure Push(P: Pointer);
    property Size: Integer read fSize;
  end;

  TInvoke = class
  private
    fStackFrame: Pointer; //4
    fStackSize: Integer; //8

    fEAX: Integer; //12
    fEDX: Integer; //16
    fECX: Integer; //20
    fAddress: Pointer; // 24
    fCallConv: Integer; // 28
    fResultType: Integer; // 32
    fResult: array[0..15] of Byte; // 36
    fResultSize: Integer;

    fCount: Integer;
    NeedSetup: Boolean;
    A: array of Variant;
    Types: array of Integer;
    DllList: TStringList;
  public
    This: Pointer;
    IsInternal: Boolean;
    OldESP0: Integer;
    constructor Create;
    constructor CreateInternal;
    destructor Destroy; override;
    procedure ClearArguments;
    procedure PushArguments;
    procedure PushArgumentsBackward;

    procedure AddArg(const value: Variant; T: Integer);
    procedure AddArgByVal(var V; Size: Integer);

    property ArgumentCount: Integer read fCount;
    procedure Setup;
    procedure CallHost;
    function GetResultPtr: Pointer;
    procedure SetResType(value : Integer);
    procedure SetResSize(value : Integer);
    function ExtraParamNeeded: Boolean;
    function GetThis: Pointer;
    procedure SetThis(value: Pointer);
    procedure LoadAddress(const DllName, ProcName: String);
    procedure UloadDlls;
    procedure ClearResult;
    procedure RaiseError(const Message: string; params: array of Const);
    property CallConv: Integer read fCallConv write fCallConv;
    property Address: Pointer read fAddress write fAddress;
    property StackFrame: Pointer read fStackFrame write fStackFrame;
    property StackSize: Integer read fStackSize write fStackSize;
    property ResultType: Integer read fResultType;
    property _EAX: Integer read fEAX write fEAX;
    property _ECX: Integer read fECX write fECX;
    property _EDX: Integer read fEDX write fEDX;
  end;

implementation

const
  __ccSTDCALL = 1;
  __ccREGISTER = 2;
  __ccCDECL = 3;
  __ccPASCAL = 4;
  __ccSAFECALL = 5;
  __ccMSFASTCALL = 6;

function VariantToValValue(const V: Variant): TValValue;
begin
  result := TValValue(TVarData(V).VInteger);
end;

function ValValueToVariant(X: TValValue): Variant;
begin
  with TVarData(result) do
  begin
    VType := varValValue;
    VInteger := Integer(X);
  end;
end;

procedure ClearVariant(var V: Variant);
var
  X: TValValue;
begin
  if VarType(V) = varValValue then
  with TVarData(V) do
  begin
    X := TValValue(VInteger);
    X.Free;
    VType := varInteger;
  end;

  VarClear(V);
end;

constructor TValValue.Create(var V; iSize: Integer);
begin
  inherited Create;
  fSize := iSize;
  while fSize mod 4 <> 0 do
    Inc(fSize);
  fBuff := AllocMem(fSize);
  Move(V, fBuff^, fSize);
end;

destructor TValValue.Destroy;
begin
  FreeMem(fBuff, fSize);
  inherited;
end;

procedure TValValue.Push(P: Pointer);
var
  I, K: Integer;
begin
  K := fSize div 4;

  for I:=K - 1 downto 0 do
  begin
    Integer(P^) := fBuff^[I];
    Inc(Integer(P), SizeOf(Integer));
  end;
end;

constructor TInvoke.Create;
begin
  inherited;
  fCount := 0;
  SetLength(A, MaxArgs);
  SetLength(Types, MaxArgs);
  fCallConv := __ccSTDCALL;
  fStackFrame := AllocMem(MaxArgs * 16);
  fAddress := nil;
  This := nil;
  NeedSetup := true;
  DllList := TStringList.Create;
  IsInternal := false;
end;

constructor TInvoke.CreateInternal;
begin
  inherited;
  fCount := 0;
  fCallConv := __ccREGISTER;
  fStackFrame := nil;
  fAddress := nil;
  This := nil;
  NeedSetup := false;
  IsInternal := true;
end;

destructor TInvoke.Destroy;
begin
  if IsInternal then
    Exit;

  ClearArguments;

  UloadDlls;
  DllList.Free;
  FreeMem(fStackFrame, MaxArgs * 16);
  inherited;
end;

procedure TInvoke.ClearArguments;
var
  I: Integer;
begin
  for I:=0 to fCount - 1 do
    ClearVariant(A[I]);

  fCount := 0;
  NeedSetup := true;
end;

procedure TInvoke.AddArg(const value: Variant; T: Integer);
begin
  A[fCount] := value;
  Types[fCount] := T;
  Inc(fCount);
  NeedSetup := true;
end;

procedure TInvoke.AddArgByVal(var V; Size: Integer);
begin
  A[fCount] := ValValueToVariant(TValValue.Create(V, Size));
  Types[fCount] := __typeVALVALUE;
  Inc(fCount);
  NeedSetup := true;
end;

procedure TInvoke.Setup;
var
  I, T: Integer;

  P: Pointer;
  EAXbusy, EDXbusy, ECXbusy: Boolean;
  IDX, ICX: Integer;
  X: TValValue;
begin
  if not NeedSetup then
    Exit;

  EAXbusy := false;
  EDXbusy := false;
  ECXbusy := false;

  P := fStackFrame;
  fStackSize := 0;

  case fCallConv of
    __ccSAFECALL:
    begin
      Pointer(P^) := @ fResult;
      I := 0;
      Move(I, fResult, SizeOf(Integer));
      Inc(Integer(P), SizeOf(Integer));
      Inc(fStackSize, SizeOf(Integer));

      for I:= fCount - 1 downto 0 do
      begin
        T := Types[I];
        case T of
          __typeINTEGER:
          begin
            Integer(P^) := Integer(A[I]);
            Inc(Integer(P), SizeOf(Integer));
            Inc(fStackSize, SizeOf(Integer));
          end;
          __typeVALVALUE:
          begin
            X := VariantToValValue(A[I]);
            X.Push(P);
            Inc(Integer(P), X.Size);
            Inc(fStackSize, X.Size);
          end;
          __typeVARIANT:
          begin
            Pointer(P^) := @ A[I];
            Inc(Integer(P), SizeOf(Integer));
            Inc(fStackSize, SizeOf(Integer));
          end;
          else
            RaiseError('Internal error', []);
        end;
      end;
    end; // __ccSAFECALL

    __ccSTDCALL, __ccCDECL:
    begin
      for I:= fCount - 1 downto 0 do
      begin
        T := Types[I];
        case T of
          __typeINTEGER:
          begin
            Integer(P^) := Integer(A[I]);
            Inc(Integer(P), SizeOf(Integer));
            Inc(fStackSize, SizeOf(Integer));
          end;
          __typeVALVALUE:
          begin
            X := VariantToValValue(A[I]);
            X.Push(P);
            Inc(Integer(P), X.Size);
            Inc(fStackSize, X.Size);
          end;
          __typeVARIANT:
          begin
            Pointer(P^) := @ A[I];
            Inc(Integer(P), SizeOf(Integer));
            Inc(fStackSize, SizeOf(Integer));
          end;
          else
            RaiseError('Internal error', []);
        end;
      end;
    end; // __ccSTDCALL, __ccCDECL

    __ccMSFASTCALL:
    begin
      EAXbusy := true;
      IDX := -1;
      ICX := -1;

      if fResultType in [__typeRECORD, __typeARRAY] then
      begin
        if fResultSize <= 4 then
        begin
          fResultType := __typeINTEGER;
        end
        else if fResultSize <= 8 then
        begin
          fResultType := __typeINT64;
        end;
      end;

      for I:= 0 to fCount - 1 do
      begin
        if Types[I] = __typeINTEGER then
        begin
          if not ECXbusy then
          begin
            fECX := Integer(A[I]);
            ECXbusy := true;
            ICX := I;
          end
          else if not EDXbusy then
          begin
            fEDX := Integer(A[I]);
            EDXbusy := true;
            IDX := I;
          end
        end;
      end;

      for I:= fCount - 1 downto 0 do
      begin
        if I = IDX then
          continue;
        if I = ICX then
          continue;

        T := Types[I];
        case T of
          __typeINTEGER:
          begin
            Integer(P^) := Integer(A[I]);
            Inc(Integer(P), SizeOf(Integer));
            Inc(fStackSize, SizeOf(Integer));
          end;
          __typeVALVALUE:
          begin
            X := VariantToValValue(A[I]);
            X.Push(P);
            Inc(Integer(P), X.Size);
            Inc(fStackSize, X.Size);
          end;
          __typeVARIANT:
          begin
            Pointer(P^) := @ A[I];
            Inc(Integer(P), SizeOf(Integer));
            Inc(fStackSize, SizeOf(Integer));
          end;
          else
            RaiseError('Internal error', []);
        end;
      end;
    end; // __ccMSFASTCALL

    __ccPASCAL:
    begin
      for I:= 0 to fCount - 1 do
      begin
        T := Types[I];
        case T of
          __typeINTEGER:
          begin
            Integer(P^) := Integer(A[I]);
            Inc(Integer(P), SizeOf(Integer));
            Inc(fStackSize, SizeOf(Integer));
          end;
          __typeVALVALUE:
          begin
            X := VariantToValValue(A[I]);
            X.Push(P);
            Inc(Integer(P), X.Size);
            Inc(fStackSize, X.Size);
          end;
          __typeVARIANT:
          begin
            Pointer(P^) := @ A[I];
            Inc(Integer(P), SizeOf(Integer));
            Inc(fStackSize, SizeOf(Integer));
          end;
          else
            RaiseError('Internal error', []);
        end;
      end;
    end; // __ccPASCAL

    __ccREGISTER:
    begin

      if This <> nil then
      begin
        fEAX := Integer(This);
        EAXbusy := true;
      end;

      for I:=0 to fCount - 1 do
      begin
        T := Types[I];
        case T of
          __typeINTEGER:
          begin
            if not EAXbusy then
            begin
              fEAX := Integer(A[I]);
              EAXbusy := true;
            end
            else if not EDXbusy then
            begin
              fEDX := Integer(A[I]);
              EDXbusy := true;
            end
            else if not ECXbusy then
            begin
              fECX := Integer(A[I]);
              ECXbusy := true;
            end
            else
            begin
              Integer(P^) := Integer(A[I]);
              Inc(Integer(P), SizeOf(Integer));
              Inc(fStackSize, SizeOf(Integer));
            end;
          end;
          __typeVALVALUE:
          begin
            X := VariantToValValue(A[I]);
            X.Push(P);
            Inc(Integer(P), X.Size);
            Inc(fStackSize, X.Size);
          end;
          __typeVARIANT:
          begin
            Pointer(P^) := @ A[I];
            Inc(Integer(P), SizeOf(Integer));
            Inc(fStackSize, SizeOf(Integer));
          end;
          else
            RaiseError('Internal error', []);
        end;
      end;
    end; // __ccREGISTER
  end;

  NeedSetup := false;

  if This <> nil then
  if fCallConv in [__ccSTDCALL, __ccCDECL, __ccPASCAL, __ccSAFECALL] then
  begin
    Pointer(P^) := This;
    Inc(fStackSize, SizeOf(Integer));
  end;

  if fCallConv = __ccSAFECALL then
    Exit;

  if ExtraParamNeeded then
  begin
    FillChar(fResult, SizeOf(fResult), 0);
    Pointer(P^) := @ fResult;

    if fCallConv = __ccREGISTER then
    begin
      if not EAXbusy then
        fEAX := Integer(@ fResult)
      else if not EDXbusy then
        fEDX := Integer(@ fResult)
      else if not ECXbusy then
        fECX := Integer(@ fResult)
      else
        Inc(fStackSize, SizeOf(Integer));
    end
    else
      Inc(fStackSize, SizeOf(Integer));
  end;
end;

procedure TInvoke.PushArguments;
asm
  pop ebx // ret address

  mov edx, eax // Self
  mov ecx, [edx + 8] // fStackSize
  mov edx, [edx + 4] // fStackFrame

  cmp ecx, 0
  jz @@Next

  @@loop:
  mov esi, [edx]
  push esi
  add edx, 4 ////////////
  sub ecx, 4
  jnz @@loop

  @@Next:

  mov ecx, [eax + 20]
  mov edx, [eax + 16]
  mov eax, [eax + 12]

  jmp ebx
end;

procedure TInvoke.PushArgumentsBackward;
asm
  pop ebx // ret address

  mov edx, eax // Self
  mov ecx, [edx + 8] // fStackSize
  mov edx, [edx + 4] // fStackFrame

  cmp ecx, 0
  jz @@Next

  @@loop:
  mov esi, [edx]
  push esi
  sub edx, 4 ////////////
  sub ecx, 4
  jnz @@loop

  @@Next:

  mov ecx, [eax + 20]
  mov edx, [eax + 16]
  mov eax, [eax + 12]

  jmp ebx
end;

procedure TInvoke.CallHost;
asm
  push ebp
  mov ebp, esp
  sub esp, 4
  mov [ebp - 4], eax

  mov edx, eax // Self
  mov ecx, [edx + 8] // fStackSize
  mov edx, [edx + 4] // fStackFrame

  cmp ecx, 0
  jz @@Next

  @@loop:
  mov esi, [edx]
  push esi
  add edx, 4
  sub ecx, 4
  jnz @@loop

  @@Next:

  mov ebx, [eax + 24] // address of procedure

  mov ecx, [eax + 20]
  mov edx, [eax + 16]
  mov eax, [eax + 12]

  call ebx

  mov ebx, [ebp - 4]

  // if call convention is cdecl then pop arguments
  mov ecx, [ebx + 28] // fCallConv
  cmp ecx, __ccCDECL
  jnz @@Ret
  mov ecx, [ebx + 8] // fStackSize
  add esp, ecx

  @@Ret:

  mov ecx, [ebx + 32] // fResultType

  cmp ecx, __typeINTEGER
  jnz @@RetDOUBLE
  mov ecx, [ebx + 28] // fCallConv
  cmp ecx, __ccSAFECALL
  jz @@Return
  mov [ebx + 36], eax
  jmp @@Return
//

  @@RetDOUBLE:

  cmp ecx, __typeDOUBLE
  jnz @@RetSINGLE
  fstp qword ptr [ebx + 36]
  jmp @@Return
//

  @@RetSINGLE:

  cmp ecx, __typeSINGLE
  jnz @@RetEXTENDED
  fstp dword ptr [ebx + 36]
  jmp @@Return
//

  @@RetEXTENDED:

  cmp ecx, __typeEXTENDED
  jnz @@RetCURRENCY
  fstp tbyte ptr [ebx + 36]
  jmp @@Return
//

  @@RetCURRENCY:

  cmp ecx, __typeCURRENCY
  jnz @@RetINT64
  fistp qword ptr [ebx + 36]
  jmp @@Return
//

  @@RetINT64:
  cmp ecx, __typeINT64
  jnz @@Return
  mov [ebx + 36], eax
  mov [ebx + 40], edx

  @@Return:

  mov esp, ebp
  pop ebp
  ret
end;

function TInvoke.GetResultPtr: Pointer;
begin
  result := @ fResult;
end;

procedure TInvoke.SetResType(value : Integer);
begin
  fResultType := value;
  NeedSetup := true;
end;

procedure TInvoke.SetResSize(value : Integer);
begin
  fResultSize := value;
  NeedSetup := true;
end;

function TInvoke.GetThis: Pointer;
begin
  result := This;
  NeedSetup := true;
end;

procedure TInvoke.SetThis(value: Pointer);
begin
  This := value;
  NeedSetup := true;
end;

function TInvoke.ExtraParamNeeded: Boolean;
begin
{$IFDEF FPC}
  result := fResultType in [__typeSHORTSTRING,
                            __typeWIDESTRING,
                            __typeRECORD,
                            __typeARRAY,
                            __typeDYNARRAY,
                            __typeSET,
                            __typeVARIANT,
                            __typeINTERFACE];
{$ELSE}
  result := fResultType in [__typeSTRING,
                            __typeWIDESTRING,
                            __typeSHORTSTRING,
                            __typeRECORD,
                            __typeARRAY,
                            __typeDYNARRAY,
                            __typeSET,
                            __typeVARIANT,
                            __typeINTERFACE];
{$ENDIF}
end;

procedure TInvoke.RaiseError(const Message: string; params: array of Const);
begin
  raise Exception.Create(Format(Message, params));
end;

procedure TInvoke.LoadAddress(const DllName, ProcName: String);
var
  H: Cardinal;
  I: Integer;
begin
  I := DllList.IndexOf(DllName);
  if I = - 1 then
  begin
   {$IFDEF LINUX}
    H := HMODULE(dynlibs.LoadLibrary(DLLName));
    Address := dynlibs.GetProcedureAddress(H, ProcName);
    {$ELSE}
    H := LoadLibrary(PChar(DllName));
    Address := GetProcAddress(H, PChar(ProcName));
    {$ENDIF}

    if Address <> nil then
      DllList.AddObject(DllName, TObject(H));
  end
  else
  begin
    H := Cardinal(DllList.Objects[I]);
   {$IFDEF LINUX}
    Address := dynlibs.GetProcedureAddress(H, ProcName);
    {$ELSE}
    Address := GetProcAddress(H, PChar(ProcName));
    {$ENDIF}
  end;

  if H = 0 then
    raise Exception.Create(Format('Dynamic link library %s was not found.',
     [DllName]));

  if Address = nil then
    raise Exception.Create(Format('The procedure entry point %s could not be located in the' +
   ' dynamic link library %s.',
     [ProcName, DllName]));
end;

procedure TInvoke.UloadDlls;
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

procedure TInvoke.ClearResult;
begin
  case fResultType of
    __typeSTRING: String(GetResultPtr^) := '';
    __typeINTERFACE: IUnknown(GetResultPtr^)._Release;
    __typeVARIANT: VarClear(Variant(GetResultPtr^));
  end;
end;

end.
