////////////////////////////////////////////////////////////////////////////
// PaxCompiler
// Site: http://www.paxcompiler.com
// Author: Alexander Baranovsky (paxscript@gmail.com)
// ========================================================================
// Copyright (c) Alexander Baranovsky, 2006-2008. All rights reserved.
// Code Version: 2.4
// ========================================================================
// Unit: PAXCOMP_SYMBOL_OFFSET.pas
// ========================================================================
////////////////////////////////////////////////////////////////////////////

{$I PaxCompiler.def}
unit PAXCOMP_OFFSET;
interface
uses
{$IFDEF VARIANTS}
  Variants,
{$ENDIF}
  TypInfo,
  SysUtils,
  Classes,
  PAXCOMP_CONSTANTS,
  PAXCOMP_SYS;

type
  TOffsetRec = class
  public
    Id: Integer;
    Shift: Integer;
    Offset: Integer;
    Size: Integer;
    function Clone: TOffsetRec;
    procedure SaveToStream(S: TStream);
    procedure LoadFromStream(S: TStream);
  end;

  TOffsetList = class
  private
    L: TList;
    function GetRecord(I: Integer): TOffsetRec;
    function GetCount: Integer;
  public
    InitSize: Integer;
    constructor Create;
    destructor Destroy; override;
    function Add(Id, Shift, Offset, Size: Integer): TOffsetRec;
    procedure Clear;
    function Clone: TOffsetList;
    function GetSize: Integer;
    function GetOffset(Shift: Integer): Integer;
    function HasId(Id: Integer): Boolean;
    procedure SaveToStream(S: TStream);
    procedure LoadFromStream(S: TStream);
    function GetOffsetById(Id: Integer): Integer;
    property Count: Integer read GetCount;
    property Records[I: Integer]: TOffsetRec read GetRecord; default;
  end;

implementation

uses
  PAXCOMP_BASESYMBOL_TABLE,
  PAXCOMP_STDLIB;

// TOffsetRec ------------------------------------------------------------------

function TOffsetRec.Clone: TOffsetRec;
begin
  result := TOffsetRec.Create;
  result.Id := Id;
  result.Shift := Shift;
  result.Offset := Offset;
  result.Size := Size;
end;

procedure TOffsetRec.SaveToStream(S: TStream);
begin
  S.Write(Shift, SizeOf(Shift));
  S.Write(Offset, SizeOf(Offset));
end;

procedure TOffsetRec.LoadFromStream(S: TStream);
begin
  S.Read(Shift, SizeOf(Shift));
  S.Read(Offset, SizeOf(Offset));
end;


// TOffsetList -----------------------------------------------------------------

constructor TOffsetList.Create;
begin
  inherited;
  L := TList.Create;
  InitSize := 0;
end;

destructor TOffsetList.Destroy;
begin
  Clear;
  L.Free;
  inherited;
end;

function TOffsetList.Add(Id, Shift, Offset, Size: Integer): TOffsetRec;
begin
  result := TOffsetRec.Create;
  result.Id := Id;
  result.Shift := Shift;
  result.Offset := Offset;
  result.Size := Size;
  L.Add(result);
end;

function TOffsetList.GetSize: Integer;
var
  I, SZ: Integer;
begin
  result := InitSize;
  for I := 0 to Count - 1 do
  begin
    SZ := Records[I].Size;
    Inc(result, SZ);
  end;
end;

function TOffsetList.GetOffset(Shift: Integer): Integer;
var
  I: Integer;
  R: TOffsetRec;
begin
  if Shift < StdSize then
  begin
    result := Shift;
    Exit;
  end;

  for I := 0 to Count - 1 do
  begin
    R := Records[I];
    if R.Shift = Shift then
    begin
      result := R.Offset;
      Exit;
    end;
  end;
  result := -1;
end;

function TOffsetList.HasId(Id: Integer): Boolean;
var
  I: Integer;
  R: TOffsetRec;
begin
  for I := 0 to Count - 1 do
  begin
    R := Records[I];
    if R.Id = Id then
    begin
      result := true;
      Exit;
    end;
  end;
  result := false;
end;

function TOffsetList.GetRecord(I: Integer): TOffsetRec;
begin
  result := TOffsetRec(L[I]);
end;

function TOffsetList.GetCount: Integer;
begin
  result := L.Count;
end;

function TOffsetList.GetOffsetById(Id: Integer): Integer;
var
  I: Integer;
begin
  for I:=0 to Count - 1 do
    if Records[I].Id = Id then
    begin
      result := Records[I].Offset;
      Exit;
    end;
  raise Exception.Create(errInternalError);
end;

procedure TOffsetList.Clear;
var
  I: Integer;
begin
  InitSize := 0;
  for I := 0 to Count - 1 do
    Records[I].Free;
  L.Clear;
end;

function TOffsetList.Clone: TOffsetList;
var
  I: Integer;
  R: TOffsetRec;
begin
  result := TOffsetList.Create;
  for I := 0 to Count - 1 do
  begin
    R := Records[I].Clone;
    result.L.Add(R);
  end;
end;

procedure TOffsetList.SaveToStream(S: TStream);
var
  I, K: Integer;
begin
  K := Count;
  S.Write(K, SizeOf(Integer));
  for I := 0 to K - 1 do
    Records[I].SaveToStream(S);
end;

procedure TOffsetList.LoadFromStream(S: TStream);
var
  I, K: Integer;
  R: TOffsetRec;
begin
  S.Read(K, SizeOf(Integer));
  for I := 0 to K - 1 do
  begin
    R := TOffsetRec.Create;
    R.LoadFromStream(S);
    L.Add(R);
  end;
end;

end.
