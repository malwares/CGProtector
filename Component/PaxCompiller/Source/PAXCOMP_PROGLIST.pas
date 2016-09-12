////////////////////////////////////////////////////////////////////////////
// PaxCompiler
// Site: http://www.paxcompiler.com
// Author: Alexander Baranovsky (paxscript@gmail.com)
// ========================================================================
// Copyright (c) Alexander Baranovsky, 2006-2008. All rights reserved.
// Code Version: 2.4
// ========================================================================
// Unit: PAXCOMP_PROGLIST.pas
// ========================================================================
////////////////////////////////////////////////////////////////////////////

{$I PaxCompiler.def}
{$O-}

unit PAXCOMP_PROGLIST;
interface
uses
{$IFDEF LINUX}
{$IFDEF FPC}
  DynLibs,
{$ELSE}
  QForms,
{$ENDIF}
{$ELSE}
  Windows,
{$ENDIF}
{$IFDEF VARIANTS}
  Variants,
{$ENDIF}
  SysUtils,
  Classes,
  PAXCOMP_CONSTANTS,
  PAXCOMP_SYS,
  PAXCOMP_MAP;
type
  TProgRec = class
  public
    FullPath: String;
    Prog: Pointer;
    destructor Destroy; override;
    procedure SaveToStream(S: TStream);
    procedure LoadFromStream(S: TStream; PCUOwner: Pointer);
  end;

  TProgList = class(TTypedList)
  private
    fOwner: Pointer;
    First: Boolean;
    function GetRecord(I: Integer): TProgRec;
    function AddRecord: TProgRec;
  public
    constructor Create(AOwner: Pointer);
    function LoadAddress(const FileName, ProcName: String;
                         RunInit: Boolean;
                         OverCount: Integer;
                         var MR: TMapRec): Pointer;
    procedure SaveToStream(S: TStream);
    procedure LoadFromStream(S: TStream; PCUOwner: Pointer);
    procedure LoadFromStreamList(S: TStreamList; PCUOwner: Pointer);
    procedure SetPCUOwner(PCUOwner: Pointer);
    procedure RunInitialization;
    procedure RunFinalization;
    procedure Clear; override;
    property Records[I: Integer]: TProgRec read GetRecord; default;
  end;

implementation

uses
  PAXCOMP_PROG;

destructor TProgRec.Destroy;
begin
  if Prog <> nil then
    TProgram(Prog).Destroy;
  inherited;
end;

procedure TProgRec.SaveToStream(S: TStream);
begin
  SaveStringToStream(FullPath, S);
  TProgram(Prog).SaveToStream(S);
end;

procedure TProgRec.LoadFromStream(S: TStream; PCUOwner: Pointer);
begin
  FullPath := LoadStringFromStream(S);
  TProgram(Prog) := TProgram.Create;
  TProgram(Prog).PCUOwner := PCUOwner;
  TProgram(Prog).CopyRootEvents;
  TProgram(Prog).LoadFromStream(S);
end;

// TProgList -------------------------------------------------------------------

constructor TProgList.Create(AOwner: Pointer);
begin
  inherited Create;
  fOwner := AOwner;
  First := true;
end;

function TProgList.GetRecord(I: Integer): TProgRec;
begin
  result := TProgRec(L[I]);
end;

function TProgList.AddRecord: TProgRec;
begin
  result := TProgRec.Create;
  L.Add(result);
end;

procedure TProgList.SaveToStream(S: TStream);
var
  I, K: Integer;
begin
  K := Count;
  S.Write(K, SizeOf(Integer));
  for I := 0 to K - 1 do
    Records[I].SaveToStream(S);
end;

procedure TProgList.LoadFromStream(S: TStream; PCUOwner: Pointer);
var
  I, K: Integer;
  R: TProgRec;
begin
  S.Read(K, SizeOf(Integer));
  for I := 0 to K - 1 do
  begin
    R := AddRecord;
    R.LoadFromStream(S, PCUOwner);
  end;
end;

procedure TProgList.LoadFromStreamList(S: TStreamList; PCUOwner: Pointer);
var
  I: Integer;
  R: TProgRec;
begin
  for I := 0 to S.Count - 1 do
  begin
    R := AddRecord;
    R.FullPath := S[I].UnitName + '.' + PCU_FILE_EXT;
    TProgram(R.Prog) := TProgram.Create;
    TProgram(R.Prog).PCUOwner := PCUOwner;
    TProgram(R.Prog).CopyRootEvents;
    TProgram(R.Prog).LoadFromStream(S[I].Stream);
  end;
end;

procedure TProgList.RunInitialization;
var
  I: Integer;
begin
  if First then
  try
    for I := 0 to Count - 1 do
      TProgram(Records[I].Prog).RunInitialization;
  finally
    First := false;
  end;
end;

procedure TProgList.RunFinalization;
var
  I: Integer;
begin
  for I := 0 to Count - 1 do
    TProgram(Records[I].Prog).RunFinalization;
end;

procedure TProgList.SetPCUOwner(PCUOwner: Pointer);
var
  I: Integer;
begin
  for I := 0 to Count - 1 do
    TProgram(Records[I].Prog).PCUOwner := PCUOwner;
end;

function TProgList.LoadAddress(const FileName, ProcName: String;
                               RunInit: Boolean;
                               OverCount: Integer;
                               var MR: TMapRec): Pointer;
var
  I: Integer;
  Owner, P: TProgram;
  UnitName, FullPath, S: String;
  ProgRec: TProgRec;
  InputStream: TStream;
begin
  Owner := TProgram(fOwner);

  ProgRec := nil;
  FullPath := '';
  UnitName := ExtractOwner(FileName);

  InputStream := nil;

//  if not Owner.FileExists(FileName, FullPath) then
//    Owner.RaiseError(errFileNotFound, [FileName]);

  for I := 0 to Count - 1 do
  begin
    S := ExtractFileName(TProgRec(L[I]).FullPath);
    if StrEql(S, FileName) then
    begin
      ProgRec := TProgRec(L[I]);
      FullPath := ProgRec.FullPath;
      break;
    end;
  end;

  if ProgRec = nil then
  begin
    if Assigned(Owner.OnLoadPCU) then
    begin
      InputStream := Owner.OnLoadPCU(Owner.Owner, UnitName);
    end;

    if not Owner.FileExists(FileName, FullPath) then
      if InputStream = nil then
      begin
        result := nil;
        Exit;
        Owner.RaiseError(errFileNotFound, [FileName]);
      end;

    P := TProgram.Create;
    P.PCUOwner := Owner;
    if InputStream <> nil then
      P.LoadFromStream(InputStream)
    else
      P.LoadFromFile(FullPath);
    ProgRec := TProgRec.Create;
    ProgRec.FullPath := FullPath;
    ProgRec.Prog := P;
    L.Add(ProgRec);

    if RunInit then
      P.RunInitialization;
  end
  else
    P := ProgRec.Prog;

  P.CopyRootEvents;

  result := P.GetAddressEx(UnitName + '.' + ProcName, OverCount, MR);
end;

procedure TProgList.Clear;
begin
  inherited;
  First := true;
end;

end.
