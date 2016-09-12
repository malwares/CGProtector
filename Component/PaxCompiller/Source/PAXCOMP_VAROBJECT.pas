////////////////////////////////////////////////////////////////////////////
// PaxCompiler
// Site: http://www.paxcompiler.com
// Author: Alexander Baranovsky (paxscript@gmail.com)
// ========================================================================
// Copyright (c) Alexander Baranovsky, 2006-2008. All rights reserved.
// Code Version: 2.4
// ========================================================================
// Unit: PAXCOMP_VAROBJECT.pas
// ========================================================================
////////////////////////////////////////////////////////////////////////////

{$I PaxCompiler.def}
unit PAXCOMP_VAROBJECT;
interface

uses
{$IFDEF VARIANTS}
  Variants,
{$ENDIF}
  SysUtils,
  Classes,
  PAXCOMP_CONSTANTS,
  PAXCOMP_SYS;
const
  varObject = $15;
type
  TVarObjectKind = (voNone, voSet, voSimple, voArray);

  TVarObject = class
  private
    stable: Pointer;
    voKind: TVarObjectKind;
  public
    constructor Create(i_stable: Pointer);
    function ToStr: String; virtual; abstract;
    procedure SaveToStream(S: TWriter); virtual; abstract;
    procedure LoadFromStream(S: TReader); virtual; abstract;
  end;

  TSetObject = class(TVarObject)
  private
    fValue: TByteSet;
    TypeId: Integer;
    TypeBaseId: Integer;
  public
    constructor Create(i_stable: Pointer;
                       const Value: TByteSet;
                       i_TypeId: Integer;
                       i_TypeBaseId: Integer);
    constructor CreateSimple(i_stable: Pointer);
    function ToStr: String; override;
    function Clone: TVarObject;
    procedure SaveToStream(S: TWriter); override;
    procedure LoadFromStream(S: TReader); override;
    property Value: TByteSet read fValue write fValue;
  end;

  TSimpleObject = class(TVarObject)
  private
    fValue: Variant;
    fName: String;
  public
    constructor Create(i_stable: Pointer;
                       const Value: Variant; const i_Name: String);
    constructor CreateSimple(i_stable: Pointer);
    function ToStr: String; override;
    procedure SaveToStream(S: TWriter); override;
    procedure LoadFromStream(S: TReader); override;
    property Value: Variant read fValue write fValue;
    property Name: String read fName;
  end;

  TArrObject = class(TVarObject)
  private
    L: TList;
    function GetItem(I: Integer): TVarObject;
  public
    constructor Create(i_stable: Pointer);
    destructor Destroy; override;
    function ToStr: String; override;
    procedure Clear;
    function Count: Integer;
    procedure AddVarObject(X: TVarObject);
    procedure SaveToStream(S: TWriter); override;
    procedure LoadFromStream(S: TReader); override;
    property Items[I: Integer]: TVarObject read GetItem; default;
  end;

  TVarObjectList = class
  private
    stable: Pointer;
    L: TList;
    function GetItem(I: Integer): TVarObject;
    procedure AddVarObject(X: TVarObject);
  public
    constructor Create(i_stable: Pointer);
    destructor Destroy; override;
    procedure Clear;
    function Count: Integer;
    property Items[I: Integer]: TVarObject read GetItem;
  end;

function VariantToSetObject(const Value: Variant): TSetObject;
function IsVarObject(const V: Variant): boolean;
function VarObjectToVariant(const Value: TVarObject): Variant;
function VariantToVarObject(const Value: Variant): TVarObject;

procedure SaveVariantToStream(const Value: Variant; S: TWriter);
function LoadVariantFromStream(S: TReader; stable: Pointer): Variant;

implementation

uses
  PAXCOMP_BASESYMBOL_TABLE;

procedure SaveVariantToStream(const Value: Variant; S: TWriter);
var
  VType: Word;
  VObject: TVarObject;
begin
  VType := VarType(Value);
  S.Write(VType, SizeOf(VType));
  case VType of
    varString: S.WriteString(Value);
    varOleStr: S.WriteWideString(Value);
    varObject:
    begin
      VObject := VariantToVarObject(Value);
      S.Write(VObject.voKind, SizeOf(VObject.voKind));
      VObject.SaveToStream(S);
    end;
    else
      S.Write(Value, SizeOf(Variant));
  end;
end;

function LoadVariantFromStream(S: TReader; stable: Pointer): Variant;
var
  VType: Word;
  VObject: TVarObject;
  voKind: TVarObjectKind;
begin
  S.Read(VType, SizeOf(VType));
  case VType of
    varString: result := S.ReadString;
    varOleStr: result := S.ReadWideString;
    varObject:
    begin
      S.Read(voKind, SizeOf(voKind));
      case voKind of
        voSet: VObject := TSetObject.CreateSimple(stable);
        voSimple: VObject := TSimpleObject.CreateSimple(stable);
        voArray: VObject := TArrObject.Create(stable);
      else
        raise Exception.Create(errInternalError);
      end;
      VObject.LoadFromStream(S);
      result := VarObjectToVariant(VObject);
    end
    else
      S.Read(result, SizeOf(Variant));
  end;
end;

function IsVarObject(const V: Variant): boolean;
begin
  result := VarType(V) = varObject;
end;

function VarObjectToVariant(const Value: TVarObject): Variant;
begin
  result := Integer(Value);
  TVarData(result).VType := varObject;
end;

function VariantToVarObject(const Value: Variant): TVarObject;
begin
  if IsVarObject(Value) then
    result := TVarObject(TVarData(Value).VInteger)
  else
    raise Exception.Create(errInternalError);
end;

function VariantToSetObject(const Value: Variant): TSetObject;
begin
  result := VariantToVarObject(Value) as TSetObject;
end;

//---------- TVarObject --------------------------------------------------------

constructor TVarObject.Create(i_stable: Pointer);
begin
  stable := i_stable;
  voKind := voNone;

  if stable <> nil then
    TBaseSymbolTable(stable).VarObjects.AddVarObject(Self);
end;

//---------- TSetObject --------------------------------------------------------

constructor TSetObject.Create(i_stable: Pointer; const Value: TByteSet;
                              i_TypeId: Integer; i_TypeBaseId: Integer);
begin
  inherited Create(i_stable);
  fValue := Value;
  TypeId := i_TypeId;
  voKind := voSet;
  TypeBaseId := I_TypeBaseId;
end;

constructor TSetObject.CreateSimple(i_stable: Pointer);
begin
  inherited Create(i_stable);
  voKind := voSet;
end;

function TSetObject.Clone: TVarObject;
begin
  result := TSetObject.Create(stable, fValue, TypeId, TypeBaseId);
end;

procedure TSetObject.SaveToStream(S: TWriter);
begin
  S.Write(fValue, SizeOf(fValue));
  S.Write(TypeId, SizeOf(TypeId));
end;

procedure TSetObject.LoadFromStream(S: TReader);
begin
  S.Read(fValue, SizeOf(fValue));
  S.Read(TypeId, SizeOf(TypeId));
end;

function TSetObject.ToStr: String;
var
  S: TByteSet;
  B1, B2: Integer;
  I, J: Byte;
  First: boolean;
  FinType: Integer;
  T: Integer;
begin
  if stable <> nil then
  begin
    T := TBaseSymbolTable(stable).GetTypeBase(TypeId);
    FinType := TBaseSymbolTable(stable)[T].FinalTypeId;
  end
  else
    FinType := TypeBaseId;

  result := '[';
  B1 := 0;
  B2 := 0;

  S := fValue;
  First := true;

  I := 0;
  while I < 255 do
  begin
    if I in S then
    begin
      if First then
      begin
        B1 := I;
        B2 := B1;
        First := false;
      end
      else
        Inc(B2);
    end
    else if not First then
    begin
      if B2 - B1 >= 1 then
      begin
        if FinType = typeANSICHAR then
          result := result + '''' + Chr(B1) + '''' + '..' +
                             '''' + Chr(B2) + ''''
        else if FinType = typeENUM then
          for J:=B1 to B2 do
          begin
//            result := result + GetName(T + J + 1);
            if J < B2 then
              result := result + ',';
          end
        else
          result := result + IntToStr(B1) + '..' + IntToStr(B2);
      end
      else
      begin
        if FinType = typeANSICHAR then
          result := result + '''' + Chr(B1) + ''''
        else if FinType = typeENUM then
        begin
//          result := result + GetName(T + B1 + 1)
        end
        else
          result := result + IntToStr(B1);
      end;
      result := result + ',';
      First := true;
    end;
    Inc(I);
  end;

  if result[Length(result)] = ',' then
    Delete(result, Length(result), 1);

  result := result + ']';
end;

//---------- TSimpleObject -----------------------------------------------------

constructor TSimpleObject.Create(i_stable: Pointer;
            const Value: Variant; const i_Name: String);
begin
  inherited Create(i_stable);
  fValue := Value;
  fName := i_Name;
  voKind := voSimple;
end;

constructor TSimpleObject.CreateSimple(i_stable: Pointer);
begin
  inherited Create(i_stable);
  voKind := voSimple;
end;

function TSimpleObject.ToStr: String;
begin
  result := VarToStr(Value);
end;

procedure TSimpleObject.SaveToStream(S: TWriter);
begin
  S.WriteString(fName);
  SaveVariantToStream(fValue, S);
end;

procedure TSimpleObject.LoadFromStream(S: TReader);
begin
  fName := S.ReadString;
  fValue := LoadVariantFromStream(S, stable);
end;

//---------- TArrObject --------------------------------------------------------

constructor TArrObject.Create(i_stable: Pointer);
begin
  inherited;
  L := TList.Create;
  voKind := voArray;
end;

destructor TArrObject.Destroy;
begin
  Clear;
  L.Free;
  inherited;
end;

procedure TArrObject.Clear;
var
  I: Integer;
begin
  for I:=0 to Count - 1 do
    Items[I].Free;
  L.Clear;
end;

function TArrObject.GetItem(I: Integer): TVarObject;
begin
  result := TVarObject(L[I]);
end;

function TArrObject.Count: Integer;
begin
  result := L.Count;
end;

procedure TArrObject.AddVarObject(X: TVarObject);
begin
  L.Add(X);
end;

procedure TArrObject.SaveToStream(S: TWriter);
var
  I, K: Integer;
begin
  K := Count;
  S.Write(K, SizeOf(K));
  for I := 0 to K - 1 do
  begin
    S.Write(Items[I].voKind, SizeOf(Items[I].voKind));
    Items[I].SaveToStream(S);
  end;
end;

procedure TArrObject.LoadFromStream(S: TReader);
var
  I, K: Integer;
  voKind: TVarObjectKind;
  VObject: TVarObject;
begin
  S.Read(K, SizeOf(K));
  for I := 0 to K - 1 do
  begin
    S.Read(voKind, SizeOf(voKind));
    case voKind of
      voSet: VObject := TSetObject.CreateSimple(nil);
      voSimple: VObject := TSimpleObject.CreateSimple(nil);
      voArray: VObject := TArrObject.Create(nil);
    else
      raise Exception.Create(errInternalError);
    end;
    VObject.LoadFromStream(S);
    AddVarObject(VObject);
  end;
end;

function TArrObject.ToStr: String;
var
  I: Integer;
begin
  result := '(';
  for I:=0 to Count - 1 do
  begin
    result := result + Items[I].ToStr;
    if I < Count - 1 then
      result := result + ',';
  end;
  result := result + ')';
end;

//---------- TVarObjectList ----------------------------------------------------

constructor TVarObjectList.Create(i_stable: Pointer);
begin
  inherited Create;
  stable := i_stable;
  L := TList.Create;
end;

destructor TVarObjectList.Destroy;
begin
  Clear;
  L.Free;
  inherited;
end;

function TVarObjectList.GetItem(I: Integer): TVarObject;
begin
  result := TVarObject(L[I]);
end;

procedure TVarObjectList.Clear;
var
  I: Integer;
begin
  for I:=0 to Count - 1 do
  begin
    Items[I].Free;
  end;
  L.Clear;
end;

function TVarObjectList.Count: Integer;
begin
  result := L.Count;
end;

procedure TVarObjectList.AddVarObject(X: TVarObject);
begin
  L.Add(X);
end;

end.