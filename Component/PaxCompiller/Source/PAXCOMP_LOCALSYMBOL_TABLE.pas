////////////////////////////////////////////////////////////////////////////
// PaxCompiler
// Site: http://www.paxcompiler.com
// Author: Alexander Baranovsky (paxscript@gmail.com)
// ========================================================================
// Copyright (c) Alexander Baranovsky, 2006-2008. All rights reserved.
// Code Version: 2.4
// ========================================================================
// Unit: PAXCOMP_LOCALSYMBOL_TABLE.pas
// ========================================================================
////////////////////////////////////////////////////////////////////////////

{$I PaxCompiler.def}
{$O-}
unit PAXCOMP_LOCALSYMBOL_TABLE;
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
  PAXCOMP_SYMBOL_REC,
  PAXCOMP_MAP,
  PAXCOMP_STDLIB;
type
  TLocalSymbolTable = class(TBaseSymbolTable)
  protected
    function GetRecord(I: Integer): TSymbolRec; override;
  public
    GlobalSymbolTable_LastShiftValue: Integer;
    procedure Reset; override;
    procedure Update;
    procedure CompressHostClassList(MapTable: TMapTable);
    property Records[I: Integer]: TSymbolRec read GetRecord; default;
  end;

implementation

procedure TLocalSymbolTable.Reset;
var
  I: Integer;
begin
  for I:=A.Count - 1 downto 0 do
    TSymbolRec(A[I]).Free;
  A.Clear;

//  Card := GlobalSymbolTable.Card;
  Card := FirstLocalId;

  ResultId := GlobalSymbolTable.ResultId;
  TrueId := GlobalSymbolTable.TrueId;
  FalseId := GlobalSymbolTable.FalseId;
  NilId := GlobalSymbolTable.NilId;
  EventNilId := GlobalSymbolTable.EventNilId;
  CurrExceptionObjectId := GlobalSymbolTable.CurrExceptionObjectId;
  EmptySetId := GlobalSymbolTable.EmptySetId;
  EmptyStringId := GlobalSymbolTable.EmptyStringId;
  LastShiftValue := GlobalSymbolTable.LastShiftValue;
  LastClassIndex := GlobalSymbolTable.LastClassIndex;

  GlobalSymbolTable_LastShiftValue := GlobalSymbolTable.LastShiftValue;

  HashArray.Free;
  HashArray := GlobalSymbolTable.HashArray.Clone;

  GuidList.Free;
  GuidList := GlobalSymbolTable.GuidList.Clone;

  SomeTypeList.Free;
  SomeTypeList := GlobalSymbolTable.SomeTypeList.Clone;

//  ExternList.Free;
//  ExternList := GlobalSymbolTable.ExternList.Clone;

 // CompileCard := Card;
end;

function TLocalSymbolTable.GetRecord(I: Integer): TSymbolRec;
begin
  if I <= GlobalSymbolTable.Card then
    result := TSymbolRec(GlobalSymbolTable.A[I])
  else if I <= FirstLocalId then
    result := SR0
  else
    result := TSymbolRec(A[I - FirstLocalId - 1]);
end;

procedure TLocalSymbolTable.Update;
var
  I, D: Integer;
  R: TSymbolRec;
  S: String;
begin
  D := GlobalSymbolTable.LastShiftValue - GlobalSymbolTable_LastShiftValue;
  if D > 0 then
  begin
    for I := FirstLocalId + 1 to Card do
    begin
      R := Records[I];
      if R.Shift >= GlobalSymbolTable_LastShiftValue then
        if R.Kind in (KindSubs + [KindVAR]) then
          R.Shift := R.Shift + D;
    end;
    GlobalSymbolTable_LastShiftValue := GlobalSymbolTable.LastShiftValue;
  end;

  HashArray.Free;
  HashArray := GlobalSymbolTable.HashArray.Clone;
  for I := FirstLocalId + 1 to Card do
  begin
    R := Records[I];
    S := R.Name;
    R.Name := S;
  end;

  LastClassIndex := -1;
  for I := 1 to Card do
  begin
    R := Records[I];
    if R = SR0 then
      continue;

    if R.Kind = kindTYPE then
      if R.TypeId = typeCLASS then
      begin
        Inc(LastClassIndex);
        R.ClassIndex := LastClassIndex;
      end;
  end;
end;

procedure TLocalSymbolTable.CompressHostClassList(MapTable: TMapTable);
var
  I, KK, K1, K2: Integer;
  R: TSymbolRec;
  S: String;
  MapRec: TMapRec;
begin
  LastClassIndex := -1;

  for KK := 1 to 2 do
  begin
    if KK = 1 then
    begin
      K1 := 1;
      K2 := GlobalSymbolTable.Card;
    end
    else
    begin
      K1 := FirstLocalId + 1;
      K2 := Card;
    end;

    for I := K1 to K2 do
    begin
      R := Records[I];

      if R.Kind = kindTYPE then
        if R.TypeId = typeCLASS then
        if R.ClassIndex <> -1 then
        begin
          if R.Host then
          begin
            if I <= StdCard then
            begin
              Inc(LastClassIndex);
              R.ClassIndex := LastClassIndex;
              continue;
            end;

            S := R.FullName;

            MapRec := MapTable.Lookup(S);
            if MapRec <> nil then
            begin
              Inc(LastClassIndex);
              R.ClassIndex := LastClassIndex;
              MapRec.ClassIndex := LastClassIndex;
              continue;
            end;

            MapRec := MapTable.Lookup(ExtractName(S));
            if MapRec <> nil then
            begin
              Inc(LastClassIndex);
              R.ClassIndex := LastClassIndex;
              MapRec.ClassIndex := LastClassIndex;
            end
            else
              R.ClassIndex := -1;
          end
          else
          begin
            Inc(LastClassIndex);
            R.ClassIndex := LastClassIndex;
          end;
        end;
      end;
  end;
end;

end.
