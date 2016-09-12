////////////////////////////////////////////////////////////////////////////
// PaxCompiler
// Site: http://www.paxcompiler.com
// Author: Alexander Baranovsky (paxscript@gmail.com)
// ========================================================================
// Copyright (c) Alexander Baranovsky, 2006-2008. All rights reserved.
// Code Version: 2.4
// ========================================================================
// Unit: PAXCOMP_EXTRASYMBOL_TABLE.pas
// ========================================================================
////////////////////////////////////////////////////////////////////////////

{$I PaxCompiler.def}
{$O-}
unit PAXCOMP_EXTRASYMBOL_TABLE;
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
  PAXCOMP_BASESYMBOL_TABLE,
  PAXCOMP_SYMBOL_TABLE,
  PAXCOMP_SYMBOL_REC,
  PAXCOMP_MAP,
  PAXCOMP_STDLIB;
type
  TExtraSymbolTable = class(TSymbolTable)
  private
    LocalSymbolTable: TSymbolTable;
  protected
    function GetRecord(I: Integer): TSymbolRec; override;
  public
    constructor Create(kernel: Pointer; ALocalSymbolTable: TSymbolTable);
    procedure Reset; override;
    property Records[I: Integer]: TSymbolRec read GetRecord; default;
  end;

implementation

constructor TExtraSymbolTable.Create(kernel: Pointer; ALocalSymbolTable: TSymbolTable);
begin
  inherited Create(kernel);
  LocalSymbolTable := ALocalSymbolTable;
  IsExtraTable := true;
end;

procedure TExtraSymbolTable.Reset;
var
  I: Integer;
begin
  for I:=A.Count - 1 downto 0 do
    TSymbolRec(A[I]).Free;

  A.Clear;

  Card := LocalSymbolTable.Card;

  ResultId := LocalSymbolTable.ResultId;

  TrueId := LocalSymbolTable.TrueId;
  FalseId := LocalSymbolTable.FalseId;
  NilId := LocalSymbolTable.NilId;
  EventNilId := LocalSymbolTable.EventNilId;
  CurrExceptionObjectId := LocalSymbolTable.CurrExceptionObjectId;
  EmptySetId := LocalSymbolTable.EmptySetId;
  EmptyStringId := LocalSymbolTable.EmptyStringId;
  LastShiftValue := LocalSymbolTable.LastShiftValue;
  LastClassIndex := LocalSymbolTable.LastClassIndex;

//  GlobalSymbolTable_LastShiftValue := GlobalSymbolTable.LastShiftValue;

  HashArray.Free;
  HashArray := LocalSymbolTable.HashArray.Clone;

  GuidList.Free;
  GuidList := LocalSymbolTable.GuidList.Clone;

  SomeTypeList.Free;
  SomeTypeList := LocalSymbolTable.SomeTypeList.Clone;

//  ExternList.Free;
//  ExternList := GlobalSymbolTable.ExternList.Clone;

 // CompileCard := Card;
end;

function TExtraSymbolTable.GetRecord(I: Integer): TSymbolRec;
begin
  if I <= LocalSymbolTable.Card then
    result := LocalSymbolTable[I]
  else
    result := TSymbolRec(A[I - LocalSymbolTable.Card - 1]);
end;

end.
