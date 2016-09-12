////////////////////////////////////////////////////////////////////////////
// PaxCompiler
// Site: http://www.paxcompiler.com
// Author: Alexander Baranovsky (paxscript@gmail.com)
// ========================================================================
// Copyright (c) Alexander Baranovsky, 2006-2008. All rights reserved.
// Code Version: 2.4
// ========================================================================
// Unit: PAXCOMP_TRYLST.pas
// ========================================================================
////////////////////////////////////////////////////////////////////////////

{$I PaxCompiler.def}
unit PAXCOMP_TRYLST;
interface

uses
  SysUtils,
  Classes,
  PAXCOMP_CONSTANTS,
  PAXCOMP_SYS,
  PAXCOMP_PAUSE;

type
  TTryKind = (tryExcept, tryFinally);

  TTryRec = class(TPauseRec)
  private
  public
    TryKind: TTryKind;
    ExceptOnInfo: TAssocIntegers;
    Level: Integer;
    N: Integer; // not saved into stream
    constructor Create;
    destructor Destroy; override;
    procedure SaveToStream(S: TStream);
    procedure LoadFromStream(S: TStream);
  end;

  TTryList = class
  private
    L: TList;
    function GetRecord(I: Integer): TTryRec;
    function GetCount: Integer;
    procedure ClearBase;
  public
    constructor Create;
    destructor Destroy; override;
    procedure Clear;
    procedure SaveToStream(S: TStream);
    procedure LoadFromStream(S: TStream);
    function Add: TTryRec;
    property Count: Integer read GetCount;
    property Records[I: Integer]: TTryRec read GetRecord; default;
  end;

implementation

//----------- TTryRec ----------------------------------------------------------

constructor TTryRec.Create;
begin
  inherited;
  ExceptOnInfo := TAssocIntegers.Create;
end;

destructor TTryRec.Destroy;
begin
  ExceptOnInfo.Free;
  inherited;
end;

procedure TTryRec.SaveToStream(S: TStream);
begin
  S.Write(TryKind, SizeOf(TryKind));
  S.Write(ProgOffset, SizeOf(ProgOffset));
  S.Write(Level, SizeOf(Level));
  ExceptOnInfo.SaveToStream(S);
end;

procedure TTryRec.LoadFromStream(S: TStream);
begin
  S.Read(TryKind, SizeOf(TryKind));
  S.Read(ProgOffset, SizeOf(ProgOffset));
  S.Read(Level, SizeOf(Level));
  ExceptOnInfo.LoadFromStream(S);
end;

//----------- TTryList ---------------------------------------------------------

constructor TTryList.Create;
begin
  inherited;
  L := TList.Create;
  Add;
end;

destructor TTryList.Destroy;
var
  I: Integer;
begin
  for I:=0 to Count - 1 do
    Records[I].Free;
  L.Free;
  inherited;
end;

procedure TTryList.ClearBase;
var
  I: Integer;
begin
  for I:=0 to Count - 1 do
    Records[I].Free;
  L.Clear;
end;

procedure TTryList.Clear;
var
  I: Integer;
begin
  for I:=0 to Count - 1 do
    Records[I].Free;
  L.Clear;

  Add;
end;

function TTryList.Add: TTryRec;
begin
  result := TTryRec.Create;
  L.Add(result);
end;

function TTryList.GetCount: Integer;
begin
  result := L.Count;
end;

function TTryList.GetRecord(I: Integer): TTryRec;
begin
  result := TTryRec(L[I]);
end;

procedure TTryList.SaveToStream(S: TStream);
var
  I, K: Integer;
begin
  K := Count;
  S.Write(K, SizeOf(Integer));
  for I:=0 to K - 1 do
    Records[I].SaveToStream(S);
end;

procedure TTryList.LoadFromStream(S: TStream);
var
  I, K: Integer;
  R: TTryRec;
begin
  ClearBase;

  S.Read(K, SizeOf(Integer));
  for I:=0 to K - 1 do
  begin
    R := Add;
    R.LoadFromStream(S);
  end;
end;

end.