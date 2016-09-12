////////////////////////////////////////////////////////////////////////////
// PaxCompiler
// Site: http://www.paxcompiler.com
// Author: Alexander Baranovsky (paxscript@gmail.com)
// ========================================================================
// Copyright (c) Alexander Baranovsky, 2006-2008. All rights reserved.
// Code Version: 2.4
// ========================================================================
// Unit: PAXCOMP_RTI.pas
// ========================================================================
////////////////////////////////////////////////////////////////////////////

{$I PaxCompiler.def}
unit PAXCOMP_RTI;
interface

uses
  SysUtils,
  Classes,
  PAXCOMP_CONSTANTS,
  PAXCOMP_SYS;

type
  TBreakpoint = class;
  TBreakpointList = class;

  TModuleRec = class
  public
    ModuleName: String;
    P1, P2, P3: Integer;
    UsedModules: TStringList;
    constructor Create;
    destructor Destroy; override;
    procedure SaveToStream(S: TStream);
    procedure LoadFromStream(S: TStream);
  end;

  TModuleLst = class(TTypedList)
  private
    function GetRecord(I: Integer): TModuleRec;
  public
    function AddRecord: TModuleRec;
    procedure SaveToStream(S: TStream);
    procedure LoadFromStream(S: TStream);
    function GetModuleRec(const ModuleName: String): TModuleRec;
    property Records[I: Integer]: TModuleRec read GetRecord; default;
  end;

  TRuntimeModuleList = class
  private
  public
    SourceLines: array of Integer;
    ModuleIndexes: array of Integer;
    Modules: TModuleLst;
    BreakpointList: TBreakpointList;
    TempBreakpoint: TBreakpoint;
    constructor Create;
    destructor Destroy; override;
    procedure Clear;
    function GetSourceLine(ByteCodeLine: Integer): Integer;
    function GetModuleName(ByteCodeLine: Integer): String;
    function GetModuleIndex(ByteCodeLine: Integer): Integer;
    function GetModuleIndexByName(const ModuleName: String): Integer;
    function AddBreakpoint(const ModuleName: String;
                           SourceLine: Integer): TBreakpoint;
    function AddTempBreakpoint(const ModuleName: String;
                           SourceLine: Integer): TBreakpoint;
    procedure RemoveBreakpoint(const ModuleName: String;
                               SourceLine: Integer);
    procedure RemoveAllBreakpoints;
    function HasBreakpoint(const ModuleName: String;
                           SourceLine: Integer): Boolean;
    procedure SaveToStream(S: TStream);
    procedure LoadFromStream(S: TStream);
  end;

  TBreakpoint = class
  public
    SourceLine: Integer;
    ModuleIndex: Integer;
  public
    destructor Destroy; override;
    procedure Clear;
  end;

  TBreakpointList = class
  private
    L: TList;
    function GetItem(I: Integer): TBreakpoint;
    function GetCount: Integer;
  public
    constructor Create;
    destructor Destroy; override;
    procedure Clear;
    function AddBreakpoint(ModuleIndex: Integer;
                           SourceLine: Integer): TBreakpoint;
    procedure RemoveBreakpoint(ModuleIndex: Integer;
                               SourceLine: Integer);
    function IndexOf(ModuleIndex: Integer;
                     SourceLine: Integer): Integer;
    property Count: Integer read GetCount;
    property Items[I: Integer]: TBreakpoint read GetItem; default;
  end;

implementation

// TModuleRec ------------------------------------------------------------------

constructor TModuleRec.Create;
begin
  inherited;
  UsedModules := TStringList.Create;
end;

destructor TModuleRec.Destroy;
begin
  UsedModules.Free;
  inherited;
end;

procedure TModuleRec.SaveToStream(S: TStream);
begin
  SaveStringToStream(ModuleName, S);
  S.Write(P1, SizeOf(Integer));
  S.Write(P2, SizeOf(Integer));
  S.Write(P3, SizeOf(Integer));
  SaveStringListToStream(UsedModules, S);
end;

procedure TModuleRec.LoadFromStream(S: TStream);
begin
  ModuleName := LoadStringFromStream(S);
  S.Read(P1, SizeOf(Integer));
  S.Read(P2, SizeOf(Integer));
  S.Read(P3, SizeOf(Integer));
  LoadStringListFromStream(UsedModules, S);
end;

// TModuleLst ------------------------------------------------------------------

function TModuleLst.GetRecord(I: Integer): TModuleRec;
begin
  result := TModuleRec(L[I]);
end;

function TModuleLst.AddRecord: TModuleRec;
begin
  result := TModuleRec.Create;
  L.Add(result);
end;

procedure TModuleLst.SaveToStream(S: TStream);
var
  I, K: Integer;
begin
  K := Count;
  S.Write(K, SizeOf(Integer));
  for I:=0 to K - 1 do
    Records[I].SaveToStream(S);
end;

procedure TModuleLst.LoadFromStream(S: TStream);
var
  I, K: Integer;
begin
  S.Read(K, SizeOf(Integer));
  for I:=0 to K - 1 do
    AddRecord.LoadFromStream(S);
end;

function TModuleLst.GetModuleRec(const ModuleName: String): TModuleRec;
var
  I: Integer;
begin
  result := nil;
  for I := 0 to Count - 1 do
    if StrEql(Records[I].ModuleName, ModuleName) then
    begin
      result := Records[I];
      Exit;
    end;
end;

//-- TRuntimeModuleList --------------------------------------------------------

constructor TRuntimeModuleList.Create;
begin
  inherited Create;
  BreakpointList := TBreakpointList.Create;
  TempBreakpoint := TBreakpoint.Create;
  Modules := TModuleLst.Create;
  Clear;
end;

destructor TRuntimeModuleList.Destroy;
begin
  Clear;
  BreakpointList.Free;
  TempBreakpoint.Free;
  Modules.Free;
  inherited;
end;

procedure TRuntimeModuleList.Clear;
begin
  SourceLines := nil;
  ModuleIndexes := nil;
  Modules.Clear;
  BreakpointList.Clear;
  TempBreakpoint.Clear;
end;

function TRuntimeModuleList.GetSourceLine(ByteCodeLine: Integer): Integer;
begin
  result := SourceLines[ByteCodeLine];
end;

function TRuntimeModuleList.GetModuleIndex(ByteCodeLine: Integer): Integer;
begin
  result := ModuleIndexes[ByteCodeLine];
end;

function TRuntimeModuleList.GetModuleName(ByteCodeLine: Integer): String;
var
  I: Integer;
begin
  result := '';
  for I:=0 to Modules.Count - 1 do
    if (ByteCodeLine >= Modules[I].P1) and (ByteCodeLine <= Modules[I].P3) then
    begin
      result := Modules[I].ModuleName;
      Exit;
    end;

  raise Exception.Create(errInternalError);
end;

function TRuntimeModuleList.GetModuleIndexByName(const ModuleName: String): Integer;
var
  I: Integer;
begin
  for I:=0 to Modules.Count - 1 do
    if Modules[I].ModuleName = ModuleName then
    begin
      result := I;
      Exit;
    end;
  raise Exception.Create(errInternalError);
end;

function TRuntimeModuleList.AddBreakpoint(const ModuleName: String;
                                          SourceLine: Integer): TBreakpoint;
var
  ModuleIndex: Integer;
begin
  ModuleIndex := GetModuleIndexByName(ModuleName);
  result := BreakpointList.AddBreakpoint(ModuleIndex, SourceLine);
end;

function TRuntimeModuleList.AddTempBreakpoint(const ModuleName: String;
                                              SourceLine: Integer): TBreakpoint;
var
  ModuleIndex: Integer;
begin
  ModuleIndex := GetModuleIndexByName(ModuleName);
  TempBreakpoint.SourceLine := SourceLine;
  TempBreakpoint.ModuleIndex := ModuleIndex;
  result := TempBreakpoint;
end;

procedure TRuntimeModuleList.RemoveBreakpoint(const ModuleName: String;
                                              SourceLine: Integer);
var
  ModuleIndex: Integer;
begin
  ModuleIndex := GetModuleIndexByName(ModuleName);
  BreakpointList.RemoveBreakpoint(ModuleIndex, SourceLine);
end;

procedure TRuntimeModuleList.RemoveAllBreakpoints;
begin
  BreakpointList.Clear;
end;

function TRuntimeModuleList.HasBreakpoint(const ModuleName: String;
                                          SourceLine: Integer): Boolean;
var
  ModuleIndex: Integer;
begin
  ModuleIndex := GetModuleIndexByName(ModuleName);
  result := BreakpointList.IndexOf(ModuleIndex, SourceLine) >= 0;
end;

procedure TRuntimeModuleList.SaveToStream(S: TStream);
var
  K: Integer;
  P: Pointer;
begin
  K := Length(SourceLines);
  S.Write(K, SizeOf(Integer));
  P := @SourceLines[0];
  S.Write(P^, K * SizeOf(Integer));

  K := Length(ModuleIndexes);
  S.Write(K, SizeOf(Integer));
  P := @ModuleIndexes[0];
  S.Write(P^, K * SizeOf(Integer));

  Modules.SaveToStream(S);
end;

procedure TRuntimeModuleList.LoadFromStream(S: TStream);
var
  K: Integer;
  P: Pointer;
begin
  S.Read(K, SizeOf(Integer));
  SetLength(SourceLines, K);
  P := @SourceLines[0];
  S.Read(P^, K * SizeOf(Integer));

  S.Read(K, SizeOf(Integer));
  SetLength(ModuleIndexes, K);
  P := @ModuleIndexes[0];
  S.Read(P^, K * SizeOf(Integer));

  Modules.LoadFromStream(S);
end;

//-- TBreakpointList -----------------------------------------------------------

constructor TBreakpointList.Create;
begin
  inherited;
  L := TList.Create;
end;

destructor TBreakpointList.Destroy;
begin
  Clear;
  L.Free;
  inherited;
end;

procedure TBreakpointList.Clear;
var
  I: Integer;
begin
  for I:=0 to Count - 1 do
    Items[I].Free;
  L.Clear;
end;

function TBreakpointList.AddBreakpoint(ModuleIndex: Integer;
                                       SourceLine: Integer): TBreakpoint;
begin
  result := TBreakpoint.Create;
  result.SourceLine := SourceLine;
  result.ModuleIndex := ModuleIndex;
  L.Add(result);
end;

procedure TBreakpointList.RemoveBreakpoint(ModuleIndex: Integer;
                                           SourceLine: Integer);
var
  I: Integer;
begin
  I := IndexOf(ModuleIndex, SourceLine);
  if I = -1 then
    Exit;
  Items[I].Free;
  L.Delete(I);
end;

function TBreakpointList.IndexOf(ModuleIndex: Integer;
                                 SourceLine: Integer): Integer;
var
  I: Integer;
begin
  result := -1;
  for I:=0 to Count - 1 do
    if Items[I].ModuleIndex = ModuleIndex then
      if Items[I].SourceLine = SourceLine then
      begin
        result := I;
        Exit;
      end;
end;

function TBreakpointList.GetItem(I: Integer): TBreakpoint;
begin
  result := TBreakpoint(L[I]);
end;

function TBreakpointList.GetCount: Integer;
begin
  result := L.Count;
end;

procedure TBreakpoint.Clear;
begin
  SourceLine := 0;
  ModuleIndex := 0;
end;

destructor TBreakpoint.Destroy;
begin
  inherited;
end;

end.
