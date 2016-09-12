////////////////////////////////////////////////////////////////////////////
// PaxInvoke
// Site: http://www.paxcompiler.com
// Author: Alexander Baranovsky (paxscript@gmail.com)
// ========================================================================
// Copyright (c) Alexander Baranovsky, 2006-2008. All rights reserved.
// Code Version: 2.4
// ========================================================================
// Unit: PaxInvoke.pas
// Implements dynamically invoke of a global function or a method of object
// ========================================================================
////////////////////////////////////////////////////////////////////////////

{$I PaxCompiler.def}
{$O-}
unit PaxEval;
interface
uses
  Classes,
  SysUtils,
  PAXCOMP_SYS,
  PAXCOMP_EVAL,
  PaxCompiler,
  PaxProgram;
type
  TPaxEval = class
  private
    fEval: TEval;
    function GetResultAsString: String;
    function GetResultAddress: Pointer;
    function GetResultTypeName: String;
    function GetResultTypeId: Integer;
    function GetHasErrors: Boolean;
    function GetValid: Boolean;
    function GetErrorCount: Integer;
    function GetErrorMessage(I: Integer): String;
  public
    constructor Create;
    destructor Destroy; override;
    procedure Reset;
    procedure RegisterCompiler(ACompiler: TPaxCompiler;
                               AProgram: TPaxProgram);
    procedure CompileExpression(const Source: String);
    procedure CompileProgram(const Source: String);
    procedure Run;

    function GetEvalKernelPtr: Pointer;
    property Valid: Boolean read GetValid;
    property ResultAsString: String read GetResultAsString;
    property ResultAddress: Pointer read GetResultAddress;
    property ResultTypeName: String read GetResultTypeName;
    property ResultTypeId: Integer read GetResultTypeId;
    property HasErrors: Boolean read GetHasErrors;
    property ErrorCount: Integer read GetErrorCount;
    property ErrorMessage[I: Integer]: String read GetErrorMessage;
  end;

function EvalExpression(const Source: String;
                        ACompiler: TPaxCompiler;
                        AProgram: TPaxProgram): String;

procedure EvalProgram(const Source: String;
                      ACompiler: TPaxCompiler;
                      AProgram: TPaxProgram);

implementation

constructor TPaxEval.Create;
begin
  inherited;
  fEval := TEval.Create;
end;

destructor TPaxEval.Destroy;
begin
  fEval.Free;
  inherited;
end;

procedure TPaxEval.Reset;
begin
  fEval.Reset;
end;

procedure TPaxEval.RegisterCompiler(ACompiler: TPaxCompiler;
                                    AProgram: TPaxProgram);
var
  N: Integer;
begin
  if AProgram.IsPaused then
    N := AProgram.GetProgPtr.CurrN
  else
    N := -1;
  fEval.Init(ACompiler.GetKernelPtr, AProgram.GetProgPtr, N);
end;

function TPaxEval.GetValid: Boolean;
begin
  result := fEval.Valid;
end;

procedure TPaxEval.CompileExpression(const Source: String);
begin
  fEval.CompileExpression(Source);
end;

procedure TPaxEval.CompileProgram(const Source: String);
begin
  fEval.CompileProgram(Source);
end;

procedure TPaxEval.Run;
begin
  fEval.Run;
end;

function TPaxEval.GetResultAsString: String;
begin
  result := fEval.GetResultAsString;
end;

function TPaxEval.GetResultAddress: Pointer;
begin
  result := fEval.GetResultAddress;
end;

function TPaxEval.GetResultTypeName: String;
begin
  result := fEval.GetResultTypeName;
end;

function TPaxEval.GetResultTypeId: Integer;
begin
  result := fEval.GetResultTypeId;
end;

function TPaxEval.GetHasErrors: Boolean;
begin
  result := fEval.HasErrors;
end;

function TPaxEval.GetErrorCount: Integer;
begin
  result := fEval.GetErrorCount;
end;

function TPaxEval.GetErrorMessage(I: Integer): String;
begin
  result := fEval.GetErrorMessage(I);
end;

function TPaxEval.GetEvalKernelPtr: Pointer;
begin
  result := fEval.EKernel;
end;


function EvalExpression(const Source: String;
                        ACompiler: TPaxCompiler;
                        AProgram: TPaxProgram): String;
var
  Eval: TPaxEval;
begin
  Eval := TPaxEval.Create;
  try
    Eval.RegisterCompiler(ACompiler, AProgram);
    Eval.CompileExpression(Source);

    if Eval.HasErrors then
      raise PaxCompilerException.Create(Eval.GetErrorMessage(0));

    Eval.Run;

    result := Eval.GetResultAsString;
  finally
    Eval.Free;
  end;
end;

procedure EvalProgram(const Source: String;
                      ACompiler: TPaxCompiler;
                      AProgram: TPaxProgram);
var
  Eval: TPaxEval;
begin
  Eval := TPaxEval.Create;
  try
    Eval.RegisterCompiler(ACompiler, AProgram);
    Eval.CompileProgram(Source);

    if Eval.HasErrors then
      raise PaxCompilerException.Create(Eval.GetErrorMessage(0));

    Eval.Run;
  finally
    Eval.Free;
  end;
end;



end.