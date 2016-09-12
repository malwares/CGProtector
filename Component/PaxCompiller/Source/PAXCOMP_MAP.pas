////////////////////////////////////////////////////////////////////////////
// PaxCompiler
// Site: http://www.paxcompiler.com
// Author: Alexander Baranovsky (paxscript@gmail.com)
// ========================================================================
// Copyright (c) Alexander Baranovsky, 2006-2008. All rights reserved.
// Code Version: 2.4
// ========================================================================
// Unit: PAXCOMP_MAP.pas
// ========================================================================
////////////////////////////////////////////////////////////////////////////

{$I PaxCompiler.def}
unit PAXCOMP_MAP;
interface
uses
  SysUtils,
  Classes,
  PAXCOMP_CONSTANTS,
  PAXCOMP_SYS,
  PAXCOMP_OFFSET;
type
  TMapFieldRec = class
  public
    FieldName: String;
    FieldOffset: Integer;
    procedure SaveToStream(S: TStream);
    procedure LoadFromStream(S: TStream);
  end;

  TMapFieldList = class
  private
    L: TList;
    function GetCount: Integer;
    function GetRecord(I: Integer): TMapFieldRec;
  public
    constructor Create;
    destructor Destroy; override;
    procedure Clear;
    function Add(const FieldName: String; FieldOffset: Integer): TMapFieldRec;
    procedure SaveToStream(S: TStream);
    procedure LoadFromStream(S: TStream);
    function Lookup(const FieldName: String): TMapFieldRec;
    property Count: Integer read GetCount;
    property Records[I: Integer]: TMapFieldRec read GetRecord; default;
  end;

  TSubParamRec = class
  public
    FinTypeId: Byte;
    ParamMod: Byte;
    ParamSize: Integer;
    // pcu only
    ParamName: String;
    ParamTypeName: String;
  end;

  TSubParamList = class(TTypedList)
  private
    function GetRecord(I: Integer): TSubParamRec;
  public
    function AddRecord: TSubParamRec;
    procedure SaveToStream(S: TStream);
    procedure LoadFromStream(S: TStream);
    property Records[I: Integer]: TSubParamRec read GetRecord; default;
  end;

  TSubDesc = class
  public
    OverCount: Byte;
    CallConv: Byte;
    CallMode: Byte;
    ResTypeId: Byte;
    MethodIndex: Integer;
    RetSize: Integer;
    ParamList: TSubParamList;
    // pcu only
    ResTypeName: String;
    IsMethod: Boolean;
    IsShared: Boolean;
    SubName: String;
    DllName: String;
    AliasName: String;

    constructor Create;
    destructor Destroy; override;
    procedure SaveToStream(S: TStream);
    procedure LoadFromStream(S: TStream);
  end;

  TSubDescList = class(TTypedList)
  private
    function GetRecord(I: Integer): TSubDesc;
  public
    function AddRecord: TSubDesc;
    procedure SaveToStream(S: TStream);
    procedure LoadFromStream(S: TStream);
    property Records[I: Integer]: TSubDesc read GetRecord; default;
  end;

  TMapRec = class
  public
    FullName: String;
    Shift: Integer;
    Offset: Integer;
    ClassIndex: Integer;
    Kind: Byte;
    Global: Boolean;
    Vis: TClassVisibility;
    TypedConst: Boolean;
    FullTypeName: String;
    IsExternal: Boolean;
    SubDesc: TSubDesc;
    FieldList: TMapFieldList;
    constructor Create;
    destructor Destroy; override;
    procedure SaveToStream(S: TStream);
    procedure LoadFromStream(S: TStream);
  end;

  TMapTable = class
  private
    L: TList;
    HashArray: THashArray;
    function GetCount: Integer;
    function GetRecord(I: Integer): TMapRec;
    function Add: TMapRec;
  public
    constructor Create;
    destructor Destroy; override;
    procedure Clear;
    function AddRec(const FullName: String;
                    Shift: Integer;
                    ClassIndex: Integer;
                    Kind: Byte;
                    Global: Boolean;
                    OverCount: Byte;
                    CallMode: Byte): TMapRec;
    function Lookup(const FullName: String): TMapRec;
    function LookupEx(const FullName: String; OverCount: Integer): TMapRec;
    function LookupType(const FullName: String): TMapRec;
    procedure SaveToStream(S: TStream);
    procedure LoadFromStream(S: TStream);
    procedure CreateOffsets(OffsetList: TOffsetList; Host: Boolean);
    property Count: Integer read GetCount;
    property Records[I: Integer]: TMapRec read GetRecord; default;
  end;

  TTypeMapRec = class
  public
    TypeId: Integer;
    Fields: TIntegerList;
    Completed: Boolean;
    constructor Create;
    destructor Destroy; override;
  end;

  TTypeMap = class(TTypedList)
  private
    function GetRecord(I: Integer): TTypeMapRec;
  public
    function Add(TypeId: Integer): TTypeMapRec;
    function Lookup(TypeId: Integer): TTypeMapRec;
    property Records[I: Integer]: TTypeMapRec read GetRecord; default;
  end;

implementation

// TSubParamList ---------------------------------------------------------------

function TSubParamList.GetRecord(I: Integer): TSubParamRec;
begin
  result := TSubParamRec(L[I]);
end;

function TSubParamList.AddRecord: TSubParamRec;
begin
  result := TSubParamRec.Create;
  L.Add(result);
end;

procedure TSubParamList.SaveToStream(S: TStream);
var
  I, K: Integer;
begin
  K := Count;
  S.Write(K, SizeOf(Integer));

  for I := 0 to K - 1 do
    with Records[I] do
    begin
      S.Write(FinTypeId, SizeOf(FinTypeId));
      S.Write(ParamMod, SizeOf(ParamMod));
      S.Write(ParamSize, SizeOf(ParamSize));
      SaveStringToStream(ParamName, S);
      SaveStringToStream(ParamTypeName, S);
    end;
end;

procedure TSubParamList.LoadFromStream(S: TStream);
var
  I, K: Integer;
  R: TSubParamRec;
begin
  S.Read(K, SizeOf(Integer));

  for I := 0 to K - 1 do
  begin
    R := AddRecord;
    with R do
    begin
      S.Read(FinTypeId, SizeOf(FinTypeId));
      S.Read(ParamMod, SizeOf(ParamMod));
      S.Read(ParamSize, SizeOf(ParamSize));
      ParamName := LoadStringFromStream(S);
      ParamTypeName := LoadStringFromStream(S);
    end;
  end;
end;

// TSubDesc --------------------------------------------------------------------

constructor TSubDesc.Create;
begin
  inherited;
  ParamList := TSubParamList.Create;
end;

destructor TSubDesc.Destroy;
begin
  ParamList.Free;
  inherited;
end;

procedure TSubDesc.SaveToStream(S: TStream);
begin
  S.Write(OverCount, SizeOf(OverCount));
  S.Write(CallConv, SizeOf(CallConv));
  S.Write(CallMode, SizeOf(CallMode));
  S.Write(ResTypeId, SizeOf(ResTypeId));
  S.Write(MethodIndex, SizeOf(MethodIndex));
  S.Write(RetSize, SizeOf(RetSize));
  S.Write(IsMethod, SizeOf(IsMethod));
  S.Write(IsShared, SizeOf(IsShared));
  SaveStringToStream(ResTypeName, S);
  ParamList.SaveToStream(S);
  SaveStringToStream(SubName, S);
  SaveStringToStream(DllName, S);
  SaveStringToStream(AliasName, S);
end;

procedure TSubDesc.LoadFromStream(S: TStream);
begin
  S.Read(OverCount, SizeOf(OverCount));
  S.Read(CallConv, SizeOf(CallConv));
  S.Read(CallMode, SizeOf(CallMode));
  S.Read(ResTypeId, SizeOf(ResTypeId));
  S.Read(MethodIndex, SizeOf(MethodIndex));
  S.Read(RetSize, SizeOf(RetSize));
  S.Read(IsMethod, SizeOf(IsMethod));
  S.Read(IsShared, SizeOf(IsShared));
  ResTypeName := LoadStringFromStream(S);
  ParamList.Clear;
  ParamList.LoadFromStream(S);
  SubName := LoadStringFromStream(S);
  DllName := LoadStringFromStream(S);
  AliasName := LoadStringFromStream(S);
end;

// TSubDescList ----------------------------------------------------------------

function TSubDescList.GetRecord(I: Integer): TSubDesc;
begin
  result := TSubDesc(L[I]);
end;

function TSubDescList.AddRecord: TSubDesc;
begin
  result := TSubDesc.Create;
  L.Add(result);
end;

procedure TSubDescList.SaveToStream(S: TStream);
var
  I, K: Integer;
begin
  K := Count;
  S.Write(K, SizeOf(Integer));
  for I := 0 to K - 1 do
    Records[I].SaveToStream(S);
end;

procedure TSubDescList.LoadFromStream(S: TStream);
var
  I, K: Integer;
begin
  S.Read(K, SizeOf(Integer));
  for I := 0 to K - 1 do
    AddRecord.LoadFromStream(S);
end;

// TTypeMapRec -----------------------------------------------------------------

constructor TTypeMapRec.Create;
begin
  inherited;
  Fields := TIntegerList.Create;
end;

destructor TTypeMapRec.Destroy;
begin
  Fields.Free;
  inherited;
end;

// TTypeMap --------------------------------------------------------------------

function TTypeMap.Lookup(TypeId: Integer): TTypeMapRec;
var
  I: Integer;
begin
  result := nil;
  for I := 0 to Count - 1 do
    if Records[I].TypeId = TypeId then
    begin
      result := Records[I];
      Exit;
    end;
end;

function TTypeMap.GetRecord(I: Integer): TTypeMapRec;
begin
  result := TTypeMapRec(L[I]);
end;

function TTypeMap.Add(TypeId: Integer): TTypeMapRec;
begin
  result := Lookup(TypeId);
  if result <> nil then
    Exit;
  result := TTypeMapRec.Create;
  result.TypeId := TypeId;
  L.Add(result);
end;

// TMapFieldRec ----------------------------------------------------------------

procedure TMapFieldRec.SaveToStream(S: TStream);
begin
  SaveStringToStream(FieldName, S);
  S.Write(FieldOffset, SizeOf(FieldOffset));
end;

procedure TMapFieldRec.LoadFromStream(S: TStream);
begin
  FieldName := LoadStringFromStream(S);
  S.Read(FieldOffset, SizeOf(FieldOffset));
end;

// TMapFieldList ---------------------------------------------------------------

constructor TMapFieldList.Create;
begin
  inherited;
  L := TList.Create;
end;

destructor TMapFieldList.Destroy;
begin
  Clear;
  L.Free;
  inherited;
end;

function TMapFieldList.GetCount: Integer;
begin
  result := L.Count;
end;

function TMapFieldList.GetRecord(I: Integer): TMapFieldRec;
begin
  result := TMapFieldRec(L[I]);
end;

function TMapFieldList.Lookup(const FieldName: String): TMapFieldRec;
var
  I: Integer;
begin
  result := nil;
  for I := 0 to Count - 1 do
    if StrEql(Records[I].FieldName, FieldName) then
    begin
      result := Records[I];
      Exit;
    end;
end;

procedure TMapFieldList.Clear;
var
  I: Integer;
begin
  for I := 0 to Count - 1 do
    Records[I].Free;
  L.Clear;
end;

procedure TMapFieldList.SaveToStream(S: TStream);
var
  I, K: Integer;
begin
  K := Count;
  S.Write(K, SizeOf(K));
  for I := 0 to Count - 1 do
    Records[I].SaveToStream(S);
end;

procedure TMapFieldList.LoadFromStream(S: TStream);
var
  I, K: Integer;
  R: TMapFieldRec;
begin
  S.Read(K, SizeOf(K));
  for I := 0 to K - 1 do
  begin
    R := TMapFieldRec.Create;
    R.LoadFromStream(S);
    L.Add(R);
  end;
end;

function TMapFieldList.Add(const FieldName: String; FieldOffset: Integer): TMapFieldRec;
begin
  result := TMapFieldRec.Create;
  result.FieldName := FieldName;
  result.FieldOffset := FieldOffset;
  L.Add(result);
end;

// TMapRec ---------------------------------------------------------------------

constructor TMapRec.Create;
begin
  inherited;
  FieldList := nil;
  SubDesc := TSubDesc.Create;
end;

destructor TMapRec.Destroy;
begin
  if Assigned(FieldList) then
    FieldList.Free;

  SubDesc.Free;

  inherited;
end;

procedure TMapRec.SaveToStream(S: TStream);
begin
  SaveStringToStream(FullName, S);
  S.Write(Offset, SizeOf(Offset));
  S.Write(ClassIndex, SizeOf(ClassIndex));
  S.Write(Kind, SizeOf(Kind));
  S.Write(Global, SizeOf(Global));
  S.Write(Vis, SizeOf(Vis));
  S.Write(TypedConst, SizeOf(TypedConst));
  S.Write(IsExternal, SizeOf(IsExternal));
  SaveStringToStream(FullTypeName, S);

  SubDesc.SaveToStream(S);

  if ClassIndex > 0 then
    FieldList.SaveToStream(S);
end;

procedure TMapRec.LoadFromStream(S: TStream);
begin
  FullName := LoadStringFromStream(S);
  S.Read(Offset, SizeOf(Offset));
  S.Read(ClassIndex, SizeOf(ClassIndex));
  S.Read(Kind, SizeOf(Kind));
  S.Read(Global, SizeOf(Global));
  S.Read(Vis, SizeOf(Vis));
  S.Read(TypedConst, SizeOf(TypedConst));
  S.Read(IsExternal, SizeOf(IsExternal));
  FullTypeName := LoadStringFromStream(S);

  SubDesc.LoadFromStream(S);

  if ClassIndex > 0 then
  begin
    if Assigned(FieldList) then
      FieldList.Free;

    FieldList := TMapFieldList.Create;
    FieldList.LoadFromStream(S);
  end;
end;

// TMapTable ------------------------------------------------------------------------

constructor TMapTable.Create;
begin
  inherited;
  L := TList.Create;
  HashArray := THashArray.Create;
end;

destructor TMapTable.Destroy;
begin
  Clear;
  L.Free;
  HashArray.Free;
  inherited;
end;

function TMapTable.GetCount: Integer;
begin
  result := L.Count;
end;

function TMapTable.GetRecord(I: Integer): TMapRec;
begin
  result := TMapRec(L[I]);
end;

procedure TMapTable.Clear;
var
  I: Integer;
begin
  for I:=0 to Count - 1 do
    Records[I].Free;
  L.Clear;
  HashArray.Clear;
end;

function TMapTable.Add: TMapRec;
begin
  result := TMapRec.Create;
  L.Add(result);
end;

function TMapTable.AddRec(const FullName: String;
                          Shift: Integer; ClassIndex: Integer;
                          Kind: Byte;
                          Global: Boolean;
                          OverCount: Byte;
                          CallMode: Byte): TMapRec;
begin
  result := Add;
  result.FullName := FullName;
  result.Shift := Shift;
  result.ClassIndex := ClassIndex;
  result.Kind := Kind;
  result.Global := Global;

  result.SubDesc.OverCount := OverCount;
  result.SubDesc.CallMode := CallMode;

  if ClassIndex > 0 then
    result.FieldList := TMapFieldList.Create;

  HashArray.AddName(ExtractName(FullName), Count - 1);
end;

procedure TMapTable.SaveToStream(S: TStream);
var
  I, K: Integer;
begin
  K := Count;
  S.Write(K, SizeOf(Integer));
  for I:=0 to K - 1 do
    Records[I].SaveToStream(S);
end;

procedure TMapTable.LoadFromStream(S: TStream);
var
  I, K: Integer;
  R: TMapRec;
begin
  Clear;

  S.Read(K, SizeOf(Integer));
  for I:=0 to K - 1 do
  begin
    R := Add;
    R.LoadFromStream(S);

    HashArray.AddName(ExtractName(R.FullName), I);
  end;
end;

function TMapTable.Lookup(const FullName: String): TMapRec;
var
  I: Integer;
  S: String;
begin
  result := nil;
  for I:=0 to Count - 1 do
    if StrEql(Records[I].FullName, FullName) then
    begin
      result := Records[I];
      Exit;
    end;

  if ChCount(FullName, '.') <> 1 then
    Exit;
  for I:=0 to Count - 1 do
  begin
    S := Records[I].FullName;
    if ChCount(S, '.') = 2 then
      if StrEql(FullName, ExtractFullName(S)) then
      begin
        result := Records[I];
        Exit;
      end;
  end;
end;

function TMapTable.LookupEx(const FullName: String; OverCount: Integer): TMapRec;
var
  H, I, J: Integer;
  S: String;
begin
  result := nil;
  H := HashNumber(ExtractName(FullName));
  for J:=HashArray.A[H].Count - 1 downto 0 do
  begin
    I := HashArray.A[H][J];

    if Records[I].Kind in KindSUBS then
    begin
      if Records[I].SubDesc.OverCount = OverCount then
      if StrEql(Records[I].FullName, FullName) then
      begin
        result := Records[I];
        Exit;
      end;
    end
    else
    begin
      if StrEql(Records[I].FullName, FullName) then
      begin
        result := Records[I];
        Exit;
      end;
    end;
  end;

  if ChCount(FullName, '.') <> 1 then
    Exit;
  for I:=0 to Count - 1 do
    if Records[I].Kind in KindSUBS then
    begin
      if Records[I].SubDesc.OverCount = OverCount then
      begin
        S := Records[I].FullName;
        if ChCount(S, '.') = 2 then
          if StrEql(FullName, ExtractFullName(S)) then
          begin
            result := Records[I];
            Exit;
          end;
      end;
    end
    else
    begin
      S := Records[I].FullName;
      if ChCount(S, '.') = 2 then
        if StrEql(FullName, ExtractFullName(S)) then
        begin
          result := Records[I];
          Exit;
        end;
    end;
end;

function TMapTable.LookupType(const FullName: String): TMapRec;
var
  I: Integer;
  S1, S2: String;
begin
  result := nil;
  
  S1 := ExtractName(FullName);
  for I:=0 to Count - 1 do
  if Records[I].Kind = kindTYPE then
  begin
    S2 := ExtractName(Records[I].FullName);
    if StrEql(S1, S2) then
    begin
      result := Records[I];
      Exit;
    end;
  end;
end;

procedure TMapTable.CreateOffsets(OffsetList: TOffsetList; Host: Boolean);
var
  I, S, Q: Integer;
  MapRec: TMapRec;
begin
  if OffsetList.Count > 0 then
    for I := 0 to Count - 1 do
    begin
      MapRec := Records[I];

      if (not Host) and (MapRec.Kind in KindSUBS) then
      begin
        MapRec.Offset := MapRec.Shift;
        continue;
      end;

      S := MapRec.Shift;
      if S > 0 then
      begin
        Q := OffsetList.GetOffset(S);
        if Q = -1 then
          raise Exception.Create(errInternalError);
        MapRec.Offset := Q;
      end;
    end
  else
    for I := 0 to Count - 1 do
    begin
      MapRec := Records[I];
      MapRec.Offset := MapRec.Shift;
    end;
end;

end.

