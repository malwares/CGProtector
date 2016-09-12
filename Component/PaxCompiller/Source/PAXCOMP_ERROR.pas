////////////////////////////////////////////////////////////////////////////
// PaxCompiler
// Site: http://www.paxcompiler.com
// Author: Alexander Baranovsky (paxscript@gmail.com)
// ========================================================================
// Copyright (c) Alexander Baranovsky, 2006-2008. All rights reserved.
// Code Version: 2.4
// ========================================================================
// Unit: PAXCOMP_ERROR.pas
// ========================================================================
////////////////////////////////////////////////////////////////////////////

{$I PaxCompiler.def}
{$O-}
unit PAXCOMP_ERROR;
interface
uses
  Classes;

type
  TError = class
  private
    kernel: Pointer;
    fMessage: String;
    fPCodeLineNumber: Integer;
    fModuleName: String;
    fSourceLineNumber: Integer;
    fSourceLine: String;
    fLinePos: Integer;
  public
    constructor Create(i_kernel: Pointer; const i_Message: String);
    property Message: String read fMessage;
    property PCodeLineNumber: Integer read fPCodeLineNumber;
    property ModuleName: String read fModuleName;
    property SourceLine: String read fSourceLine;
    property SourceLineNumber: Integer read fSourceLineNumber;
    property LinePos: Integer read fLinePos;
  end;

  TErrorList = class
  private
    kernel: Pointer;
    L: TList;
    function GetRecord(I: Integer): TError;
  public
    constructor Create(i_kernel: Pointer);
    destructor Destroy; override;
    procedure Reset;
    function Count: Integer;
    procedure Add(E: TError);
    function IndexOf(E: TError): Integer;
    property Records[I: Integer]: TError read GetRecord; default;
  end;

implementation

uses
  PAXCOMP_KERNEL, PAXCOMP_MODULE;

constructor TError.Create(i_kernel: Pointer; const i_Message: String);
var
  M: TModule;
begin
  inherited Create;
  fMessage := i_Message;
  kernel := i_kernel;
  fPCodeLineNumber := TKernel(kernel).Code.N;
  if (fPCodeLineNumber < 1) or (fPCodeLineNumber > TKernel(kernel).Code.Card) then
    fPCodeLineNumber := TKernel(kernel).Code.Card;
  M := TKernel(kernel).Code.GetModule(fPCodeLineNumber);
  if M <> nil then
  begin
    fModuleName := M.Name;
    fSourceLine := TKernel(kernel).Code.GetSourceLine(fPCodeLineNumber);
    fSourceLineNumber := TKernel(kernel).Code.GetSourceLineNumber(fPCodeLineNumber);
    fLinePos := TKernel(kernel).Code.GetLinePos(fPCodeLineNumber);
  end
  else
  begin
    fModuleName := '';
    fSourceLine := '';
    fSourceLineNumber := 0;
    fLinePos := 0;
  end;
end;

constructor TErrorList.Create(i_kernel: Pointer);
begin
  inherited Create;
  Self.kernel := i_kernel;
  L := TList.Create;
end;

destructor TErrorList.Destroy;
begin
  Reset;
  L.Free;
  inherited;
end;

procedure TErrorList.Reset;
var
  I: Integer;
begin
  for I:=0 to L.Count - 1 do
    Records[I].Free;
  L.Clear;
end;

function TErrorList.Count: Integer;
begin
  result := L.Count;
end;

function TErrorList.GetRecord(I: Integer): TError;
begin
  result := TError(L[I]);
end;

function TErrorList.IndexOf(E: TError): Integer;
var
  I: Integer;
begin
  result := -1;
  for I := 0 to Count - 1 do
    if Records[I].fSourceLineNumber = E.fSourceLineNumber then
      if Records[I].fMessage = E.fMessage then
      begin
        result := I;
        Exit;
      end;
end;

procedure TErrorList.Add(E: TError);
begin
  if IndexOf(E) = -1 then
    L.Add(E)
  else
    E.Free;
end;

end.
