////////////////////////////////////////////////////////////////////////////
// PaxCompiler
// Site: http://www.paxcompiler.com
// Author: Alexander Baranovsky (paxscript@gmail.com)
// ========================================================================
// Copyright (c) Alexander Baranovsky, 2006-2008. All rights reserved.
// Code Version: 2.4
// ========================================================================
// Unit: PAXCOMP_EVAL.pas
// ========================================================================
////////////////////////////////////////////////////////////////////////////

{$I PaxCompiler.def}
{$R-}
{$O-}
unit PAXCOMP_EVAL;
interface
uses
  SysUtils,
  Classes,
  PAXCOMP_CONSTANTS,
  PAXCOMP_SYS,
  PAXCOMP_BYTECODE,
  PAXCOMP_SYMBOL_REC,
  PAXCOMP_SYMBOL_TABLE,
  PAXCOMP_EXTRASYMBOL_TABLE,
  PAXCOMP_EMIT,
  PAXCOMP_MODULE,
  PAXCOMP_SYMBOL_PROGRAM,
  PAXCOMP_PROG;

type
  TSaveRec = class
  public
    Id: Integer;
    Shift: Integer;
    Host: Boolean;
    Address: Pointer;
    OverScript: Boolean;
  end;

  TSaveList = class(TTypedList)
  private
    symbol_table: TSymbolTable;
    function GetRecord(I: Integer): TSaveRec;
  public
    function AddRec(id: Integer): TSaveRec;
    procedure Save;
    procedure Restore;
    constructor Create(st: TSymbolTable);
    property Records[I: Integer]: TSaveRec read GetRecord; default;
  end;

  TEval = class
  private
    SN: Integer;
    PascalParser: Pointer;
    ResultId: Integer;
    CurrSubId: Integer;
    ECode_InitCard: Integer;
    HostState: TMemoryStream;
    SaveList: TSaveList;
    procedure RemoveSubs;
    procedure CreateECode;
    procedure CreateESymbolTable;
    procedure SaveHostState;
    procedure RestoreHostState;
  public
    SKernel, SProg, EKernel, EProg: Pointer;
    constructor Create;
    destructor Destroy; override;
    procedure Reset;
    procedure Init(kernel, prog: Pointer; N: Integer);
    procedure CompileExpression(const Source: String);
    procedure CompileProgram(const Source: String);
    procedure Run;
    function Valid: Boolean;
    function GetResultAsString: String;
    function GetResultAddress: Pointer;
    function GetResultTypeName: String;
    function GetResultTypeId: Integer;
    function HasErrors: Boolean;
    function GetErrorCount: Integer;
    function GetErrorMessage(I: Integer): String;
  end;

implementation

uses
  PAXCOMP_PASCAL_PARSER,
  PAXCOMP_KERNEL;

constructor TSaveList.Create(st: TSymbolTable);
begin
  inherited Create;
  symbol_table := st;
end;

function TSaveList.AddRec(id: Integer): TSaveRec;
var
  R: TSymbolRec;
begin
  R := symbol_table[id];
  result := TSaveRec.Create;
  result.Id := R.id;
  result.Shift := R.Shift;
  result.Host := R.Host;
  result.Address := R.Address;
  result.OverScript := R.OverScript;
  L.Add(result);
end;

procedure TSaveList.Save;
var
  I: Integer;
begin
  for I := symbol_table.CompileCard + 1 to symbol_table.Card do
    AddRec(I);
end;

procedure TSaveList.Restore;
var
  I: Integer;
  R: TSymbolRec;
begin
  for I := 0 to Count - 1 do
  begin
    R := symbol_table[Records[I].Id];
    with Records[I] do
    begin
      R.Shift := Shift;
      R.Host := Host;
      R.OverScript := OverScript;
    end;
  end;
end;

function TSaveList.GetRecord(I: Integer): TSaveRec;
begin
  result := TSaveRec(L[I]);
end;

constructor TEval.Create;
begin
  inherited;

  SKernel := nil;
  SProg := nil;

  EKernel := TKernel.Create(nil);
  TKernel(EKernel).SignCompression := false;
  EProg := TProgram.Create;
  PascalParser := TPascalParser.Create;
  HostState := TMemoryStream.Create;

  SaveList := nil;
end;

destructor TEval.Destroy;
begin
  TKernel(EKernel).Free;
  TProgram(EProg).Free;
  TPascalParser(PascalParser).Free;
  HostState.Free;

  if SaveList <> nil then
  begin
    SaveList.Restore;
    SaveList.Free;
    SaveList := nil;
  end;

  inherited;
end;

procedure TEval.Reset;
begin
  if SaveList <> nil then
  begin
    SaveList.Restore;
    SaveList.Free;
    SaveList := nil;
  end;

  SKernel := nil;
  SProg := nil;
  TKernel(EKernel).Reset;
end;

procedure TEval.Init(kernel, prog: Pointer; N: Integer);
begin
  SN := N;
  if SN <= 0 then
    SN := TKernel(kernel).Code.Card;

  skernel := kernel;
  sprog := prog;

  CurrSubId := TKernel(kernel).Code.GetCurrSubId(SN);

  CreateECode;
  CreateESymbolTable;
  TKernel(ekernel).RegisterParser(PascalParser);

  ResultId := TKernel(ekernel).SymbolTable.Card + 3;
end;

function TEval.GetResultAddress: Pointer;
begin
  result := TKernel(EKernel).SymbolTable.GetFinalAddress(EProg, 0, ResultId);
end;

function TEval.GetResultTypeId: Integer;
begin
  result := TKernel(EKernel).SymbolTable[ResultId].TypeId;
end;

function TEval.GetResultTypeName: String;
var
  TypeId: Integer;
begin
  TypeId := TKernel(EKernel).SymbolTable[ResultId].TypeId;
  result := TKernel(EKernel).SymbolTable[TypeId].Name;
end;

function TEval.GetResultAsString: String;
var
  Address: Pointer;
  TypeId: Integer;
begin
  Address := TKernel(EKernel).SymbolTable.GetFinalAddress(EProg, 0, ResultId);
  TypeId := TKernel(EKernel).SymbolTable[ResultId].TypeId;
  result := TKernel(EKernel).SymbolTable.GetStrVal(Address, TypeId);
end;

function TEval.Valid: Boolean;
begin
  result := (SKernel <> nil) and (SProg <> nil);
end;

procedure TEval.CompileExpression(const Source: String);
var
  Emitter: TEmitter;
  SymbolProgram: TSymbolProg;
  EProgram: TProgram;
  M: TModule;
begin
  EProgram := TProgram(eprog);
  with TKernel(ekernel) do
  begin
    ClassFactory := TProgram(SProg).ProgClassFactory;

    M := AddModule('$', 'Pascal');
    AddCode('$', Source);
    ParseModule(M, 0, wpEvalExpression);

    if HasError then Exit;
    code.RemoveEvalOp;

    if HasError then Exit;
    modules.CreateLoadOrder;
    if HasError then Exit;

    code.CheckTypes;
    if HasError then Exit;

    SymbolTable.SetShifts;

    if HasError then Exit;
    code.ProcessSizeOf;
    if HasError then Exit;
    code.ChangeOrderOfActualParams;
    if HasError then Exit;
    code.AssignShifts;

    RemoveSubs;

    if HasError then Exit;
    code.Optimization;
  end;

  Emitter := TEmitter.Create;
  SymbolProgram := Emitter.CreateSymbolProgram(ekernel);
  try
    SymbolProgram.CreateProgram(EProgram);
  finally
    Emitter.Free;
    SymbolProgram.Free;
  end;
end;

procedure TEval.CompileProgram(const Source: String);
var
  Emitter: TEmitter;
  SymbolProgram: TSymbolProg;
  EProgram: TProgram;
  M: TModule;
begin
  EProgram := TProgram(eprog);
  with TKernel(ekernel) do
  begin
    ClassFactory := TProgram(SProg).ProgClassFactory;

    M := AddModule('$', 'Pascal');
    AddCode('$', Source);
    ParseModule(M, 0, wpProgram);

    if HasError then Exit;
    code.RemoveEvalOp;

    if HasError then Exit;
    modules.CreateLoadOrder;
    if HasError then Exit;

    code.CheckTypes;
    if HasError then Exit;

    SymbolTable.SetShifts;

    if HasError then Exit;
    code.ProcessSizeOf;
    if HasError then Exit;
    code.ChangeOrderOfActualParams;
    if HasError then Exit;
    code.AssignShifts;

    RemoveSubs;

    if HasError then Exit;
    code.Optimization;
  end;

  Emitter := TEmitter.Create;
  SymbolProgram := Emitter.CreateSymbolProgram(ekernel);
  try
    SymbolProgram.CreateProgram(EProgram);
  finally
    Emitter.Free;
    SymbolProgram.Free;
  end;
end;

procedure TEval.SaveHostState;
begin
  TProgram(SProg).SaveState(HostState);
end;

procedure TEval.RestoreHostState;
begin
  HostState.Position := 0;
  TProgram(SProg).LoadState(HostState);
end;

procedure TEval.Run;
begin
  SaveHostState;
  try
    TProgram(EProg).Run;
  finally
    RestoreHostState;
  end;
end;

procedure TEval.CreateESymbolTable;

var
  SSymbolTable: TSymbolTable;
  SCode: TCode;

  L1, L2: TIntegerList;

procedure SearchSubstitute(ParamId: Integer);
var
  R: TSymbolRec;
  I: Integer;
  CR: TCodeRec;
begin
  R := SSymbolTable[ParamId];
  if R.ByRef then
    Exit;
  if R.IsConst then
    Exit;
  if not (R.FinalTypeId in StringTypes) then
    Exit;
  for I := 1 to SCode.Card do
  begin
    CR := SCode[I];
    if CR.Op = OP_DECLARE_TEMP_VAR then
      if CR.Res = ParamId then
      begin
        L1.Add(ParamId);
        L2.Add(CR.Arg2);
      end;
  end;
end;

var
  I, J, StackFrameNumber: Integer;
  R: TSymbolRec;
  S: Integer;
begin
  TKernel(ekernel).SymbolTable.Free;
  TKernel(ekernel).SymbolTable := TExtraSymbolTable.Create(ekernel,
    TKernel(skernel).SymbolTable);
  TKernel(ekernel).SymbolTable.Reset;

  StackFrameNumber := 0;
  if TProgram(sprog).RootCallStackID.Count > 0 then
    StackFrameNumber := TProgram(sprog).RootCallStackID.Count - 1;

  SSymbolTable := TKernel(skernel).SymbolTable;
  SCode := TKernel(skernel).Code;

  S := SSymbolTable.GetDataSize(SSymbolTable.CompileCard);

  if SaveList = nil then
  begin
    SaveList := TSaveList.Create(SSymbolTable);
    SaveList.Save;
  end;

  L1 := TIntegerList.Create;
  L2 := TIntegerList.Create;

  try

    for I := SSymbolTable.CompileCard + 1 to SSymbolTable.Card do
    begin
      R := SSymbolTable[I];

       if R.Kind in kindSUBs then
       begin
         if R.Host then
           continue;

         J := R.Value;
         R.Host := true;
         R.OverScript := true;
         R.Address := ShiftPointer(TProgram(sprog).CodePtr, J);
         R.Shift := S;
         Inc(S, 4);

         continue;
       end;

      if R.IsGlobalVarEx then
      begin
        if R.Host then
          continue;

         R.Address := SSymbolTable.GetFinalAddress(SProg, StackFrameNumber, I);
         R.Host := true;
         R.OverScript := true;
         R.Shift := S;
         Inc(S, 4);

         continue;
      end;

      if R.OverScript then
      begin
        R.OverScript := false;
        R.Host := false;
        R.Shift := R.SavedShift;
      end
      else
      begin
        R.SavedShift := R.Shift;
      end;

      if R.Param then
      begin
        if R.Level <> CurrSubId then
          continue;

         R.Address := SSymbolTable.GetFinalAddress(SProg, StackFrameNumber, I);
         R.Host := true;
         R.OverScript := true;
         R.Shift := S;
         Inc(S, 4);

         SearchSubstitute(I);

         continue;
       end;

       if R.IsLocalVarEx or (R.Name = '@') then
       begin
         if R.Level <> CurrSubId then
           continue;

         R.Address := SSymbolTable.GetFinalAddress(SProg, StackFrameNumber, I);
         R.Host := true;
         R.OverScript := true;
         R.Shift := S;
         Inc(S, 4);

         continue;
       end;

       if R.Kind = kindVAR then
       begin
         R.Kind := kindNONE;
         R.Shift := 0;
       end
       else if R.Kind = kindCONST then
       begin
         R.Kind := kindNONE;
         R.Shift := 0;
       end;
    end;

  finally

    for I := 0 to L1.Count - 1 do
    begin
      SSymbolTable[L1[I]].Address := SSymbolTable[L2[I]].Address;
    end;

    L1.Free;
    L2.Free;
  end;
end;

procedure TEval.CreateECode;
var
  I, Op, Id, L: Integer;
  R: TCodeRec;
  SCode, ECode: TCode;
  SR: TSymbolRec;
  SSymbolTable: TSymbolTable;
begin
  SCode := TKernel(skernel).Code;
  ECode := TKernel(ekernel).Code;
  SSymbolTable := TKernel(skernel).SymbolTable;

  ECode.Reset;
  for I := 1 to SN do
  begin
    R := SCode.Records[I];
    Op := R.Op;
    if (Op = OP_BEGIN_MODULE) or (Op = OP_END_MODULE) or
       (Op = OP_BEGIN_USING) or (Op = OP_END_USING) then
    begin
      ECode.Add(Op, R.Arg1, R.Arg2, R.Res,
                    R.Upcase, R.Language, R.ModuleNum,
                    R.LinePos);
    end
    else if (Op = OP_BEGIN_WITH) or (Op = OP_END_WITH) then
    begin
      Id := R.Arg1;
      SR := SCode.GetSymbolRec(Id);
      L := SR.Level;
      if SSymbolTable[L].Kind in kindSUBS then
        if SSymbolTable.GetSelfId(L) = Id then
          ECode.Add(Op, R.Arg1, R.Arg2, R.Res,
                    R.Upcase, R.Language, R.ModuleNum,
                    R.LinePos);
    end
    else if Op = OP_BEGIN_SUB then
    begin
      ECode.Add(Op, R.Arg1, R.Arg2, R.Res,
                    R.Upcase, R.Language, R.ModuleNum,
                    R.LinePos);
    end
    else if Op = OP_END_SUB then
    begin
      ECode.Add(Op, R.Arg1, R.Arg2, R.Res,
                    R.Upcase, R.Language, R.ModuleNum,
                    R.LinePos);
    end;
  end;

  ECode_InitCard := ECode.Card;
end;

procedure TEval.RemoveSubs;
var
  I: Integer;
  R: TCodeRec;
begin
  for I := 1 to ECode_InitCard do
  begin
    R := TKernel(ekernel).Code[I];
    if R.Op = OP_BEGIN_SUB then
      R.Op := OP_NOP
    else if R.Op = OP_END_SUB then
      R.Op := OP_NOP
    else if R.Op = OP_BEGIN_MODULE then
      R.Op := OP_NOP
    else if R.Op = OP_END_MODULE then
      R.Op := OP_NOP
    else if R.Op = OP_BEGIN_USING then
      R.Op := OP_NOP
    else if R.Op = OP_END_USING then
      R.Op := OP_NOP
    else if R.Op = OP_BEGIN_WITH then
      R.Op := OP_NOP
    else if R.Op = OP_END_WITH then
      R.Op := OP_NOP;
  end;
end;

function TEval.HasErrors: Boolean;
begin
  result := TKernel(ekernel).Errors.Count > 0;
end;

function TEval.GetErrorCount: Integer;
begin
  result := TKernel(ekernel).Errors.Count;
end;

function TEval.GetErrorMessage(I: Integer): String;
begin
  if (I >= 0) and (I < GetErrorCount) then
    result := TKernel(ekernel).Errors[I].Message
  else
    result := '';
end;

end.
