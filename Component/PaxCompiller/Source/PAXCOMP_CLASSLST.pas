////////////////////////////////////////////////////////////////////////////
// PaxCompiler
// Site: http://www.paxcompiler.com
// Author: Alexander Baranovsky (paxscript@gmail.com)
// ========================================================================
// Copyright (c) Alexander Baranovsky, 2006-2008. All rights reserved.
// Code Version: 2.4
// ========================================================================
// Unit: PAXCOMP_CLASSLST.pas
// ========================================================================
////////////////////////////////////////////////////////////////////////////

{$I PaxCompiler.def}
unit PAXCOMP_CLASSLST;
interface

uses
  TypInfo,
  SysUtils,
  Classes,
  PAXCOMP_CONSTANTS,
  PAXCOMP_SYS;

type
  TPropRec = class
  public
    PropInfo: PPropInfo;
    PropOffset: Integer;
    constructor Create;
    destructor Destroy; override;
  end;

  TPropList = class
  private
    L: TList;
    function GetInfo(I: Integer): PPropInfo;
    function GetCount: Integer;
  public
    constructor Create;
    destructor Destroy; override;
    procedure Clear;
    procedure Add(P: PPropInfo; S: Integer);
    property Count: Integer read GetCount;
    property Infos[I: Integer]: PPropInfo read GetInfo; default;
  end;

  TIntfMethodRec = class
  public
    MethodOffset: Integer;
    FullMethodName: String;
    procedure SaveToStream(S: TStream);
    procedure LoadFromStream(S: TStream);
  end;

  TIntfMethodList = class(TTypedList)
  private
    function GetRecord(I: Integer): TIntfMethodRec;
    function AddRecord: TIntfMethodRec;
  public
    function AddMethod(const FullMethodName: String;
                       MethodOffset: Integer): TIntfMethodRec;
    procedure SaveToStream(S: TStream);
    procedure LoadFromStream(S: TStream);
    property Records[I: Integer]: TIntfMethodRec read GetRecord; default;
  end;

  TIntfRec = class
  private
    fBuffSize: Integer;
  public
    GUID: TGUID;
    Buff: PPointers;
    IntfMethods: TIntfMethodList;
    constructor Create;
    destructor Destroy; override;
    procedure AllocBuff;
    procedure SetupBuff(P: Pointer);
    procedure DeallocBuff;
    procedure SaveToStream(P: TStream);
    procedure LoadFromStream(P: TStream);
    property BuffSize: Integer read fBuffSize;
  end;

  TIntfList = class
  private
    L: TList;
    function GetRecord(I: Integer): TIntfRec;
    function GetCount: Integer;
  public
    constructor Create;
    destructor Destroy; override;
    procedure Clear;
    function Add: TIntfRec;
    procedure Setup(P: Pointer);
    procedure SaveToStream(S: TStream);
    procedure LoadFromStream(S: TStream);
    function Lookup(const GUID: TGUID): TIntfRec;
    function IndexOf(const GUID: TGUID): Integer;
    property Count: Integer read GetCount;
    property Records[I: Integer]: TIntfRec read GetRecord; default;
  end;

  TClassRec = class
  private
    procedure AddPropInfos;
  public
    PClass: TClass;
    PClass_pti: PTypeInfo;
    PropInfos: TPropList;
    Offset: Integer;
    SizeOfScriptClassFields: Integer;
    Host: Boolean;

    DestructorProgOffset: Integer;
    AfterConstructionProgOffset: Integer;
    BeforeDestructionProgOffset: Integer;
    SafeCallExceptionProgOffset: Integer;
    DispatchProgOffset: Integer;
    DefaultHandlerProgOffset: Integer;
    NewInstanceProgOffset: Integer;
    FreeInstanceProgOffset: Integer;

    FullName: String;
    ParentFullName: String;
    InstSize: Integer;
    IntfList: TIntfList;
    constructor Create(i_PClass: TClass; i_Offset: Integer; i_Host: Boolean);
    destructor Destroy; override;
    procedure SetupInterfaces(P: Pointer);
  end;

  TClassList = class
  private
    L: TStringList;
    function GetClassRec(I: Integer): TClassRec;
    function GetName(I: Integer): String;
    function GetCount: Integer;
  public
    constructor Create;
    destructor Destroy; override;
    procedure Clear;
    function IndexOf(const S: String): Integer;
    function FindClass(C: TClass): Integer;
    function Add(const FullName: String; Host: Boolean): TClassRec;
    function AddEx(const FullName: String; ClassIndex: Integer): TClassRec;
    function AddClass(C: TClass; const FullName: String;
                      Host: Boolean; Offset: Integer): TClassRec;
    function AddClassEx(C: TClass;
                        const FullName: String;
                        Host: Boolean;
                        Offset: Integer;
                        ClassIndex: Integer): TClassRec;
    procedure SaveToStream(S: TStream);
    procedure LoadFromStream(S: TStream; Version: Integer);
    function GetSize: Integer;
    procedure SetupInterfaces(P: Pointer);
    function Lookup(const FullName: String): TClassRec;
    function LookupClassRec(C: TClass): TClassRec;
    property Count: Integer read GetCount;
    property Names[I: Integer]: String read GetName;
    property Records[I: Integer]: TClassRec read GetClassRec; default;
  end;

implementation

uses
  PAXCOMP_TYPEINFO,
  PAXCOMP_PROG;

// TIntfMethodRec --------------------------------------------------------------

procedure TIntfMethodRec.SaveToStream(S: TStream);
begin
  S.Write(MethodOffset, SizeOf(MethodOffset));
  SaveStringToStream(FullMethodName, S);
end;

procedure TIntfMethodRec.LoadFromStream(S: TStream);
begin
  S.Read(MethodOffset, SizeOf(MethodOffset));
  FullMethodName := LoadStringFromStream(S);
end;

// TIntfMethodList -------------------------------------------------------------

function TIntfMethodList.GetRecord(I: Integer): TIntfMethodRec;
begin
  result := TIntfMethodRec(L[I]);
end;

function TIntfMethodList.AddRecord: TIntfMethodRec;
begin
  result := TIntfMethodRec.Create;
  L.Add(result);
end;

function TIntfMethodList.AddMethod(const FullMethodName: String;
                                   MethodOffset: Integer): TIntfMethodRec;
begin
  result := AddRecord;
  result.FullMethodName := FullMethodName;
  result.MethodOffset := MethodOffset;
end;

procedure TIntfMethodList.SaveToStream(S: TStream);
var
  I, K: Integer;
begin
  K := Count;
  S.Write(K, SizeOf(Integer));
  for I := 0 to K - 1 do
    Records[I].SaveToStream(S);
end;

procedure TIntfMethodList.LoadFromStream(S: TStream);
var
  I, K: Integer;
begin
  S.Read(K, SizeOf(Integer));
  for I := 0 to K - 1 do
    AddRecord.LoadFromStream(S);
end;

// -- TIntfRec -----------------------------------------------------------------

constructor TIntfRec.Create;
begin
  inherited;
  IntfMethods := TIntfMethodList.Create;
  fBuffSize := 0;
end;

destructor TIntfRec.Destroy;
begin
  IntfMethods.Free;
  if Buff <> nil then
    DeallocBuff;
  inherited;
end;

procedure TIntfRec.SaveToStream(P: TStream);
begin
  P.Write(GUID, SizeOf(GUID));
  IntfMethods.SaveToStream(P);
end;

procedure TIntfRec.LoadFromStream(P: TStream);
begin
  P.Read(GUID, SizeOf(GUID));
  IntfMethods.LoadFromStream(P);
end;

procedure TIntfRec.AllocBuff;
begin
  if Buff <> nil then
    DeallocBuff;
  fBuffSize := IntfMethods.Count * SizeOf(Pointer);
  Buff := AllocMem(fBuffSize);
end;

procedure TIntfRec.SetupBuff(P: Pointer);
var
  I, Offset: Integer;
  Adr: Pointer;
begin
  for I:=0 to IntfMethods.Count - 1 do
  begin
    Offset := IntfMethods[I].MethodOffset;
    Adr := ShiftPointer(TProgram(P).CodePtr, Offset);
    Buff^[I] := Adr;
  end;
end;

procedure TIntfRec.DeallocBuff;
begin
  if Buff <> nil then
  begin
    FreeMem(Buff, fBuffSize);
  end;
end;

// -- TIntfList ----------------------------------------------------------------

constructor TIntfList.Create;
begin
  inherited;
  L := TList.Create;
end;

destructor TIntfList.Destroy;
begin
  Clear;
  L.Free;
  inherited;
end;

function TIntfList.Lookup(const GUID: TGUID): TIntfRec;
var
  I: Integer;
begin
  result := nil;
  for I:=0 to Count - 1 do
    if GuidsAreEqual(Records[I].GUID, GUID) then
    begin
      result := Records[I];
      Exit;
    end;
end;

function TIntfList.IndexOf(const GUID: TGUID): Integer;
var
  I: Integer;
begin
  result := -1;
  for I:=0 to Count - 1 do
    if GuidsAreEqual(Records[I].GUID, GUID) then
    begin
      result := I;
      Exit;
    end;
end;

procedure TIntfList.SaveToStream(S: TStream);
var
  I, K: Integer;
begin
  K := Count;
  S.Write(K, 4);
  for I:=0 to K - 1 do
    Records[I].SaveToStream(S);
end;

procedure TIntfList.LoadFromStream(S: TStream);
var
  I, K: Integer;
  IntfRec: TIntfRec;
begin
  S.Read(K, 4);
  for I:=0 to K - 1 do
  begin
    IntfRec := TIntfRec.Create;
    IntfRec.LoadFromStream(S);
    L.Add(IntfRec);
  end;
end;

procedure TIntfList.Setup(P: Pointer);
var
  I: Integer;
  R: TIntfRec;
begin
  for I:=0 to Count - 1 do
  begin
    R := Records[I];

    R.AllocBuff;
    R.SetupBuff(P);
  end;
end;

function TIntfList.GetRecord(I: Integer): TIntfRec;
begin
  result := TIntfRec(L[I]);
end;

function TIntfList.GetCount: Integer;
begin
  result := L.Count;
end;

procedure TIntfList.Clear;
var
  I: integer;
begin
  for I := 0 to Count - 1 do
    TObject(L[I]).Free;
  L.Clear;
end;

function TIntfList.Add: TIntfRec;
begin
  result := TIntfRec.Create;
  L.Add(result);
end;

// -- TPropRec -----------------------------------------------------------------

constructor TPropRec.Create;
begin
  inherited;
end;

destructor TPropRec.Destroy;
begin
  inherited;
end;

// -- TPropList ----------------------------------------------------------------

constructor TPropList.Create;
begin
  inherited;
  L := TList.Create;
end;

destructor TPropList.Destroy;
begin
  Clear;
  L.Free;
  inherited;
end;

procedure TPropList.Clear;
var
  I: Integer;
begin
  for I:=0 to Count - 1 do
    TPropRec(L[I]).Free;
  L.Clear;
end;

procedure TPropList.Add(P: PPropInfo; S: Integer);
var
  R: TPropRec;
begin
  R := TPropRec.Create;
  R.PropInfo := P;
  R.PropOffset := S;
  L.Add(R);
end;

function TPropList.GetCount: Integer;
begin
  result := L.Count;
end;

function TPropList.GetInfo(I: Integer): PPropInfo;
begin
  result := TPropRec(L[I]).PropInfo;
end;

// -- TClassRec ----------------------------------------------------------------

constructor TClassRec.Create(i_PClass: TClass; i_Offset: Integer; i_Host: Boolean);
begin
  inherited Create;
  PClass := i_PClass;
  Offset := i_Offset;
  PropInfos := TPropList.Create;
  Host := i_Host;
  if PClass <> nil then
  begin
    PClass_pti := PClass.ClassInfo;
    AddPropInfos;
  end;
  IntfList := TIntfList.Create;
end;

destructor TClassRec.Destroy;
begin
  PropInfos.Free;
  IntfList.Free;
  inherited;
end;

procedure TClassRec.SetupInterfaces(P: Pointer);
begin
  IntfList.Setup(P);
end;

procedure TClassRec.AddPropInfos;
var
  pti: PTypeInfo;
  ptd: PTypeData;
  Loop, nProps: Integer;
  pProps: PPropList;
  ppi: PPropInfo;
  PropOffset: Integer;
begin
  PropInfos.Clear;

  pti := PClass.ClassInfo;
  if pti = nil then Exit;
  ptd := GetTypeData(pti);
  nProps := ptd^.PropCount;
  if nProps = 0 then
    Exit;
  GetMem(pProps, SizeOf(PPropInfo) * nProps);
  GetPropInfos(pti, pProps);
  for Loop:=0 to nProps - 1 do
  begin
{$ifdef fpc}
    ppi := pProps^[Loop];
{$else}
    ppi := pProps[Loop];
{$endif}
    PropOffset := Offset + (Loop + 1) * SizeOf(Pointer);
    PropInfos.Add(ppi, PropOffset);
  end;
  FreeMem(pProps, SizeOf(PPropInfo) * nProps);
end;

// -- TClassList ---------------------------------------------------------------

constructor TClassList.Create;
begin
  inherited;
  L := TStringList.Create;
end;

function TClassList.GetCount: Integer;
begin
  result := L.Count;
end;

function TClassList.GetClassRec(I: Integer): TClassRec;
begin
  result := TClassRec(L.Objects[I]);
end;

function TClassList.GetName(I: Integer): String;
begin
  result := L[I];
end;

function TClassList.IndexOf(const S: String): Integer;
begin
  result := L.IndexOf(S);
end;

function TClassList.Add(const FullName: String; Host: Boolean): TClassRec;
begin
  result := TClassRec.Create(nil, 0, false);
  result.FullName := FullName;
  result .Host := Host;
  L.AddObject(ExtractName(FullName), result);
end;

function TClassList.AddEx(const FullName: String; ClassIndex: Integer): TClassRec;
begin
  while L.Count < ClassIndex + 1 do
    L.Add('');

  if Assigned(L.Objects[ClassIndex]) then
    L.Objects[ClassIndex].Free;

  result := TClassRec.Create(nil, 0, false);
  result.FullName := FullName;
  L.Objects[ClassIndex] := result;
end;

function TClassList.AddClass(C: TClass; const FullName: String;
                             Host: Boolean; Offset: Integer): TClassRec;
var
  I: Integer;
  S: String;
begin
  S := C.ClassName;

  I := L.IndexOf(S);
  if I = -1 then
  begin
    result := TClassRec.Create(C, Offset, Host);
    L.AddObject(S, result);
  end
  else
  begin
    result := TClassRec(L.Objects[I]);

    if Assigned(result) then
    begin
      if result.PClass = nil then
      begin
        result.Free;
        result := TClassRec.Create(C, Offset, Host);
      end
      else
        result.AddPropInfos;
    end
    else
      result := TClassRec.Create(C, Offset, Host);

    L.Objects[I] := result;
  end;
  result.FullName := FullName;
end;

function TClassList.AddClassEx(C: TClass;
                               const FullName: String;
                               Host: Boolean;
                               Offset: Integer;
                               ClassIndex: Integer): TClassRec;
begin
  while L.Count < ClassIndex + 1 do
    L.AddObject('', nil);

  result := TClassRec(L.Objects[ClassIndex]);

  if Assigned(result) then
  begin
    if result.PClass = nil then
    begin
      result.Free;
      result := TClassRec.Create(C, Offset, Host);
    end
    else
      result.AddPropInfos;
  end
  else
    result := TClassRec.Create(C, Offset, Host);

  L.Objects[ClassIndex] := result;
  result.FullName := FullName;
end;

procedure TClassList.SetupInterfaces(P: Pointer);
var
  I: Integer;
begin
  for I:=0 to Count - 1 do
    Records[I].SetupInterfaces(P);
end;

procedure TClassList.Clear;
var
  I: Integer;
begin
  for I:=0 to L.Count - 1 do
  begin
    if L.Objects[I] <> nil then
       L.Objects[I].Free;
  end;
  L.Clear;
end;

destructor TClassList.Destroy;
begin
  Clear;
  L.Free;
  inherited;
end;

function TClassList.FindClass(C: TClass): Integer;
var
  I: Integer;
begin
  result := -1;
  for I:=0 to L.Count - 1 do
    if Records[I].PClass = C then
    begin
      result := I;
      Exit;
    end;
end;

function TClassList.Lookup(const FullName: String): TClassRec;
var
  I: Integer;
  ClassRec: TClassRec;
begin
  result := nil;
  for I:=0 to Count - 1 do
  begin
    ClassRec := Records[I];
    if StrEql(ClassRec.FullName, FullName) then
    begin
      result := ClassRec;
      Exit;
    end;
  end;
end;

function TClassList.LookupClassRec(C: TClass): TClassRec;
var
  I: Integer;
  ClassRec: TClassRec;
begin
  result := nil;
  for I:=0 to Count - 1 do
  begin
    ClassRec := Records[I];
    if StrEql(ClassRec.PClass.ClassName, C.ClassName) then
    begin
      result := ClassRec;
      Exit;
    end;
  end;
end;


function TClassList.GetSize: Integer;
var
  S: TMemoryStream;
begin
  S := TMemoryStream.Create;
  try
    SaveToStream(S);
    result := S.Size;
  finally
    S.Free;
  end;
end;

procedure TClassList.SaveToStream(S: TStream);
var
  I: Integer;
begin
  SaveStringListToStream(L, S);
  for I:=0 to L.Count - 1 do
  begin
    SaveStringToStream(Records[I].FullName, S);
    SaveStringToStream(Records[I].ParentFullName, S);
    S.Write(Records[I].PClass, 4);
    S.Write(Records[I].Offset, 4);
    S.Write(Records[I].InstSize, 4);

    S.Write(Records[I].DestructorProgOffset, 4);
    S.Write(Records[I].DestructorProgOffset, 4);

    S.Write(Records[I].AfterConstructionProgOffset, 4);
    S.Write(Records[I].BeforeDestructionProgOffset, 4);
    S.Write(Records[I].SafeCallExceptionProgOffset, 4);
    S.Write(Records[I].DispatchProgOffset, 4);
    S.Write(Records[I].DefaultHandlerProgOffset, 4);
    S.Write(Records[I].NewInstanceProgOffset, 4);
    S.Write(Records[I].FreeInstanceProgOffset, 4);

    S.Write(Records[I].SizeOfScriptClassFields, 4);
    S.Write(Records[I].Host, 1);

    Records[I].IntfList.SaveToStream(S);
  end;
end;

procedure TClassList.LoadFromStream(S: TStream; Version: Integer);
var
  I: Integer;
begin
  Clear;

  LoadStringListFromStream(L, S);
  for I:=0 to L.Count - 1 do
  begin
    L.Objects[I] := TClassRec.Create(nil, 0, false);

    Records[I].FullName := LoadStringFromStream(S);
    Records[I].ParentFullName := LoadStringFromStream(S);
    S.Read(Records[I].PClass, 4);
    S.Read(Records[I].Offset, 4);
    S.Read(Records[I].InstSize, 4);

    S.Read(Records[I].DestructorProgOffset, 4);
    S.Read(Records[I].DestructorProgOffset, 4);

    Records[I].PClass := nil;

    if Version >= 105 then
    begin
      S.Read(Records[I].AfterConstructionProgOffset, 4);
      S.Read(Records[I].BeforeDestructionProgOffset, 4);
      S.Read(Records[I].SafeCallExceptionProgOffset, 4);
      S.Read(Records[I].DispatchProgOffset, 4);
      S.Read(Records[I].DefaultHandlerProgOffset, 4);
      S.Read(Records[I].NewInstanceProgOffset, 4);
      S.Read(Records[I].FreeInstanceProgOffset, 4);
    end;

    S.Read(Records[I].SizeOfScriptClassFields, 4);
    S.Read(Records[I].Host, 1);

    if CompiledScriptVersion > FirstCompiledScriptVersion then
      Records[I].IntfList.LoadFromStream(S);
  end;
end;

end.
