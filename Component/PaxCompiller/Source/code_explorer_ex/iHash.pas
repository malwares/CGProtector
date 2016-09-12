{===============================================================================

Author  : Ivan Dyachenko
E-mail  : ivan.dyachenko@gmail.com
Site    : http://atgrand.com
Project : http://clevertis.atgrand.com
Date    : 22.09.2007 16:06:43

===============================================================================}

unit iHash;

interface

uses
  Math, Classes, Controls, Variants, Unicode;

//------------------------------------------------------------------------------

type

  PPHashItemVariant = ^PHashItemVariant;
  PHashItemVariant  = ^THashItemVariant;
  THashItemVariant  = record
    Next  : PHashItemVariant;
    Link  : PHashItemVariant;
    Key   : String;
    Data  : String;
    iData : Integer;
    Value : Variant;
    Obj   : TObject;
  end;

  THashFunction     = function(const AKey : String) : Cardinal;
  THashFunctionName = (hfBHash, hfRSHash, hfJSHash, hfPJWHash, hfELFHash, hfBKDRHash, hfSDBMHash, hfDJBHash, hfDEKHash, hfBPHash, hfFNVHash, hfAPHash);

  TForEachProc = procedure(Item: PHashItemVariant);

  TVariantHash = class(TComponent)
  private
    FBuckets       : Array of PHashItemVariant;
    FHashFunction  : THashFunction;
    FBucketsLength : Cardinal;
    FBucketsScale  : Cardinal;
    FHashMask      : Cardinal;
    FCurrentIndex  : Integer;
    FCurrentItem   : PHashItemVariant;
    FTopPullItem   : PHashItemVariant;
    FCount         : Integer;
    FPullEmptySmartAction: Boolean;
    function GetLink: PHashItemVariant;
  protected

    function GetValue(const AKey: string): Variant;
    function GetCurValue: Variant;
    function GetVarName : String;
    function GetItem(const Key: String): PHashItemVariant;

    procedure SetCurValue(const Value: Variant);
    procedure SetValue(const AKey:String; const AValue:Variant);

    function Find(const AKey: string): PHashItemVariant;
    procedure SetScale(AScale: Cardinal; AHashFuncion: THashFunctionName);

    function  PullNewItem(): PHashItemVariant;

    procedure CreatePullItems(AItemsCount: Cardinal = 0);
    procedure PullDisposeItem(AItem:PHashItemVariant);
    procedure FreePullItems();
  public
    constructor Create(AOwner: TComponent); override;
    destructor Destroy(); override;
    //
    procedure Clear(ARemoveToPull: Boolean = true);
    procedure Remove(const AKey: string; ARemoveToPull: Boolean = true);
    //
    procedure ForEach(AProc: TForEachProc);
    procedure First();
    procedure LinkTo(const AKey: string); overload;
    procedure LinkTo(const This, AKey: string); overload;

    function  Add(const AKey: string):PHashItemVariant;
    function  Next() : Boolean;
    function  Count  : Integer;
    function  Exists(const AKey: string) : Boolean;
    function  toLink : Boolean;

  public
    property Values[const Key:String]:Variant read GetValue write SetValue; default;
    property Items [const Key:String]:PHashItemVariant read GetItem;
    property Value   : Variant read GetCurValue write SetCurValue;
    property Key     : String  read GetVarName;
    property Link    : PHashItemVariant read GetLink;

    property CurrentItem: PHashItemVariant    read FCurrentItem;
    property PullEmptySmartAction: Boolean    read FPullEmptySmartAction write FPullEmptySmartAction;
    //
  end;

  function RSHash (const Str : String)  : Cardinal;
  function JSHash (const Str : String)  : Cardinal;
  function PJWHash(const Str : String)  : Cardinal;
  function ELFHash(const Str : String)  : Cardinal;
  function BKDRHash(const Str : String) : Cardinal;
  function SDBMHash(const Str : String) : Cardinal;
  function DJBHash (const Str : String) : Cardinal;
  function DEKHash (const Str : String) : Cardinal;
  function BPHash  (const Str : String) : Cardinal;
  function FNVHash (const Str : String) : Cardinal;
  function APHash  (const Str : String) : Cardinal;
  function BHash   (const Str: String)  : Cardinal;

const HashFunctions : Array [THashFunctionName] of THashFunction = (BHash, RSHash, JSHash, PJWHash, ELFHash, BKDRHash, SDBMHash, DJBHash, DEKHash, BPHash, FNVHash, APHash);

implementation

function RSHash(const Str : String) : Cardinal;
const b = 378551;
var
  a : Cardinal;
  i : Integer;
begin
  a      := 63689;
  Result := 0;
  for i := 1 to Length(Str) do
  begin
    Result := Result * a + Ord(Str[i]);
    a      := a * b;
  end;
end;

function JSHash(const Str : String) : Cardinal;
var
  i : Integer;
begin
  Result := 1315423911;
  for i := 1 to Length(Str) do
  begin
    Result := Result xor ((Result shl 5) + Ord(Str[i]) + (Result shr 2));
  end;
end;

function PJWHash(const Str : String) : Cardinal;
const BitsInCardinal = Sizeof(Cardinal) * 8;
const ThreeQuarters  = (BitsInCardinal  * 3) div 4;
const OneEighth      = BitsInCardinal div 8;
const HighBits       : Cardinal = (not Cardinal(0)) shl (BitsInCardinal - OneEighth);
var
  i    : Cardinal;
  Test : Cardinal;
begin
  Result := 0;
  for i := 1 to Length(Str) do
  begin
    Result := (Result shl OneEighth) + Ord(Str[i]);
    Test   := Result and HighBits;
    If (Test <> 0) then
    begin
      Result := (Result xor (Test shr ThreeQuarters)) and (not HighBits);
    end;
  end;
end;

function ELFHash(const Str : String) : Cardinal;
var
  i : Cardinal;
  x : Cardinal;
begin
  Result := 0;
  for i := 1 to Length(Str) do
  begin
    Result := (Result shl 4) + Ord(Str[i]);
    x      := Result and $F0000000;
    if (x <> 0) then
    begin
      Result := Result xor (x shr 24);
    end;
    Result := Result and (not x);
  end;
end;

function BKDRHash(const Str : String) : Cardinal;
const Seed = 131; (* 31 131 1313 13131 131313 etc... *)
var
  i : Cardinal;
begin
  Result := 0;
  for i := 1 to Length(Str) do
  begin
    Result := (Result * Seed) + Ord(Str[i]);
  end;
end;

function SDBMHash(const Str : String) : Cardinal;
var
  i : Cardinal;
begin
  Result := 0;
  for i := 1 to Length(Str) do
  begin
    Result := Ord(str[i]) + (Result shl 6) + (Result shl 16) - Result;
  end;
end;

function DJBHash(const Str : String) : Cardinal;
var
  i : Cardinal;
begin
  Result := 5381;
  for i := 1 to Length(Str) do
  begin
    Result := ((Result shl 5) + Result) + Ord(Str[i]);
  end;
end;

function DEKHash(const Str : String) : Cardinal;
var
  i : Cardinal;
begin
  Result := Length(Str);
  for i := 1 to Length(Str) do
  begin
    Result := ((Result shr 5) xor (Result shl 27)) xor Ord(Str[i]);
  end;
end;

function BPHash(const Str : String) : Cardinal;
var
  i : Cardinal;
begin
  Result := 0;
  for i := 1 to Length(Str) do
  begin
    Result := Result shl 7 xor Ord(Str[i]);
  end;
end;

function FNVHash(const Str : String) : Cardinal;
const FNVPrime = $811C9DC5;
var
  i : Cardinal;
begin
  Result := 0;
  for i := 1 to Length(Str) do
  begin
    Result := Result * FNVPrime;
    Result := Result xor Ord(Str[i]);
  end;
end;

function APHash(const Str : String) : Cardinal;
var
  i : Cardinal;
begin
  Result := 0;
  for i := 1 to Length(Str) do
  begin
    if ((i - 1) and 1) = 0 then
      Result := Result xor ((Result shl 7) xor Ord(Str[i]) xor (Result shr 3))
    else
      Result := Result xor (not((Result shl 11) xor Ord(Str[i]) xor (Result shr 5)));
  end;
end;

//----------------------------------------------------------------------- by ASH

function BHash(const Str: String): Cardinal;
var
  Off, Len, Skip, I: Integer;
begin
  Result := 0;
  Off := 1;
  Len := Length(Str);
  if Len < 16 then
    for I := (Len - 1) downto 0 do
    begin
      Result := (Result * 37) + Ord(Str[Off]);
      Inc(Off);
    end
  else
  begin
    { Only sample some characters }
    Skip := Len div 8;
    I := Len - 1;
    while I >= 0 do
    begin
      Result := (Result * 39) + Ord(Str[Off]);
      Dec(I, Skip);
      Inc(Off, Skip);
    end;
  end;
end;


//------------------------------------------------------------------------------

function TVariantHash.Count: Integer;
begin
  Result := FCount;
end;

constructor TVariantHash.Create(AOwner: TComponent);
begin
  inherited Create(AOwner);
  SetScale(12, hfAPHash);
  CreatePullItems();
  FCount := 0;
  FPullEmptySmartAction := true;
end;

procedure TVariantHash.SetCurValue(const Value: Variant);
begin
  CurrentItem^.Value := Value;
end;

procedure TVariantHash.SetScale(AScale: Cardinal; AHashFuncion: THashFunctionName);
begin
  FBucketsScale  := AScale;
  FBucketsLength := 1 shl AScale;
  FHashMask      := FBucketsLength - 1;
  SetLength(FBuckets, FBucketsLength);
  FHashFunction  := HashFunctions[AHashFuncion];
  First();
end;

function TVariantHash.Find(const AKey: string): PHashItemVariant;
var
  Hash: Cardinal;
begin
  Hash := FHashFunction(AKey) and FHashMask;
  Result := FBuckets[Hash];
  while (Result <> nil) do begin
    if Result^.Key = AKey then
      Exit
    else
      Result := Result^.Next;
  end;
end;

destructor TVariantHash.Destroy();
begin
  Clear(false);
  FreePullItems();
  inherited Destroy();
end;

function TVariantHash.Exists(const AKey: string): Boolean;
begin
  Result := Find(AKey)<>nil;
end;

//------------------------------------------------------------------------------

function TVariantHash.Add(const AKey: string):PHashItemVariant;
var
  Hash: Cardinal;
  P: PHashItemVariant;
begin
  Hash := FHashFunction(AKey) and FHashMask;
  P    := FBuckets[Hash];
  while (P <> nil) do begin
    if P^.Key = AKey then begin
      Result   := P;
      Exit;
    end else
      P := P^.Next;
  end;
  Inc(FCount);

  P := PullNewItem();
  P^.Key   := AKey;
  P^.Next  := FBuckets[Hash];
  FBuckets[Hash] := P;
  Result := P;
end;

procedure TVariantHash.Clear(ARemoveToPull: Boolean);
var
  I: Cardinal;
  P, N: PHashItemVariant;
begin
  for I := 0 to FHashMask do
  begin
    P := FBuckets[I];
    while P <> nil do begin
      N := P^.Next;
      if ARemoveToPull then PullDisposeItem(P) else Dispose(P);
      P := N;
    end;
    FBuckets[I] := nil;
  end;
end;

function TVariantHash.GetCurValue: Variant;
begin
  Result := CurrentItem^.Value;
end;

function TVariantHash.GetItem(const Key: String): PHashItemVariant;
begin
  Result := Add(Key);
end;

function TVariantHash.GetLink: PHashItemVariant;
begin
  Result := nil;
  if (CurrentItem<>nil) then Result := CurrentItem^.Link;
end;

function TVariantHash.GetValue(const AKey: string): Variant;
var
  P: PHashItemVariant;
begin
  P := Find(AKey);
  if P <> nil then
    Result := P^.Value
  else
    Result := Null;
end;

function TVariantHash.GetVarName: String;
begin
  Result := CurrentItem^.Key;
end;

procedure TVariantHash.LinkTo(const AKey: string);
begin
  If Exists(AKey) AND (CurrentItem<>NIL) then CurrentItem^.Link := Items[AKey];
end;

procedure TVariantHash.LinkTo(const This, AKey: string);
begin
  If Exists(This) AND Exists(AKey) then Items[This]^.Link := Items[AKey];
end;

procedure TVariantHash.SetValue(const AKey:String; const AValue: Variant);
begin
  Add(AKey)^.Value := AValue;
end;

function TVariantHash.toLink: Boolean;
begin
  Result := False;
  if (CurrentItem<>nil) AND (CurrentItem^.Link<>NIL) then
  begin
    FCurrentItem := CurrentItem^.Link;
    Result := True;
  end;
end;

procedure TVariantHash.Remove(const AKey: string; ARemoveToPull: Boolean);
var
  Hash: Cardinal;
  P: PHashItemVariant;
  C: PPHashItemVariant;
begin
  Hash := FHashFunction(AKey) and FHashMask;
  C := @FBuckets[Hash];
  P := C^;
  while (P <> nil) do begin
    if P^.Key = AKey then begin
      C^ := P^.Next;
      if ARemoveToPull then PullDisposeItem(P) else Dispose(P);
      Dec(FCount);
      Exit;
    end else
      C := @P^.Next;
      P := C^;
  end;
end;

//------------------------------------------------------------------------------

procedure TVariantHash.ForEach(AProc: TForEachProc);
var
  I: Cardinal;
  P: PHashItemVariant;
begin
  for I := 0 to FHashMask do begin
    P := FBuckets[I];
    while P <> nil do begin
      AProc(P);
      P := P^.Next;
    end;
  end;
end;

procedure TVariantHash.First();
begin
  FCurrentIndex := -1;
  FCurrentItem := nil;
end;

function TVariantHash.Next(): Boolean;
var
  I: Cardinal;
  P: PHashItemVariant;
begin
  if FCurrentItem <> nil then begin
    P := FCurrentItem^.Next;
    if P <> nil then begin
      FCurrentItem := P;
      Result := true;
      Exit;
    end;
  end;

  for I := FCurrentIndex+1 to FHashMask do begin
    if FBuckets[I] <> nil then begin
      FCurrentIndex := I;
      FCurrentItem := FBuckets[I];
      Result := true;
      Exit;
    end;
  end;

  First();
  Result := false;
end;

//------------------------------------------------------------------------------

procedure TVariantHash.CreatePullItems(AItemsCount: Cardinal);
var
  i, PullItemsCount: Cardinal;
  Bucket: PHashItemVariant;
begin
  if AItemsCount = 0 then
    PullItemsCount := FBucketsLength shr 2
  else
    PullItemsCount := AItemsCount;

  for i:=1 to PullItemsCount do begin
    New(Bucket);
    Bucket^.Next := FTopPullItem;
    FTopPullItem := Bucket;
  end;
end;

procedure TVariantHash.FreePullItems();
var
  P: PHashItemVariant;
begin
  while FTopPullItem<>nil do begin
     P := FTopPullItem;
     FTopPullItem := FTopPullItem^.Next;
     Dispose(P);
  end;
end;

function TVariantHash.PullNewItem(): PHashItemVariant;
begin
  if FTopPullItem = nil then begin
    New(Result);
    if FPullEmptySmartAction then CreatePullItems();
  end else begin
    Result := FTopPullItem;
    FTopPullItem := FTopPullItem^.Next;
  end;
  Result^.Obj  := nil;
  Result^.Link := nil;
end;

procedure TVariantHash.PullDisposeItem(AItem: PHashItemVariant);
begin
  AItem^.Next := FTopPullItem;
  FTopPullItem := AItem;
end;

end.

