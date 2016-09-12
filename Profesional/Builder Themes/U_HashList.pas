unit U_HashList;

interface
uses
windows,sysutils;

type
  PGpHashItem = ^TGpHashItem;
  TGpHashItem = record
    Next : cardinal;
    Key  : string;
    Value: string;
  end;

  ///<summary>External (string, integer) hash item representation.</summary>
  TGpStringHashKV = class
  private
    kvKey  : string;
    kvValue: string;
  public
    property Key: string read kvKey write kvKey;
    property Value: string read kvValue write kvValue;
  end; { TGpStringHashKV }

  TGpStringHash = class;

  TGpStringHashEnumerator = class
  private
    sheHash : TGpStringHash;
    sheIndex: cardinal;
    sheKV   : TGpStringHashKV;
  public
    constructor Create(stringHash: TGpStringHash);
    destructor Destroy; override;
    function  GetCurrent: TGpStringHashKV;
    function  MoveNext: boolean;
    property Current: TGpStringHashKV read GetCurrent;
  end; { TGpStringHashEnumerator }

  TGpStringHashEnumMethod = procedure(item: TGpStringHashKV) of object;

  TGpStringHash = class
  private
    shBuckets   : array of cardinal;
    shCanGrow   : boolean;
    shFirstEmpty: cardinal;
    shItems     : array of TGpHashItem;
    shNumBuckets: cardinal;
    shSize      : cardinal;
  protected
    function  FindBucket(const key: string): cardinal;
    procedure Grow;
    function  GetHashItem(idxHashItem: cardinal): PGpHashItem;
    function  GetItems(const key: string): string;
    procedure SetItems(const key: string; const value: string);
    property  HashItems[idxItem: cardinal]: PGpHashItem read GetHashItem;
  Public
    constructor Create(numItems: cardinal; canGrow: boolean = false); overload;
    constructor Create(numBuckets, numItems: cardinal; canGrow: boolean = false); overload;
    destructor  Destroy; override;
    procedure Add(const key: string; value: string);
    function  Count: integer;
    function  Find(const key: string; var value: string): boolean;
    procedure ForEach(enumerator: TGpStringHashEnumMethod);
    function  GetEnumerator: TGpStringHashEnumerator;
    function  ValueOf(const key: string): string;
    procedure Update(const key: string; value: string);
    function  HasKey(const key: string): boolean;
    property Items[const key: string]: string read GetItems write SetItems; default;
  end;

function GetGoodHashSize(dataSize: cardinal): cardinal;
function HashOf(const key: string): cardinal; overload;
function HashOf(data: pointer; dataLength: integer): cardinal; overload;
implementation

const
  CGpGoodHashSizes: array [5..30] of cardinal = (53, 97, 193, 389, 769, 1543, 3079, 6151,
    12289, 24593, 49157, 98317, 196613, 393241, 786433, 1572869, 3145739, 6291469,
    12582917, 25165843, 50331653, 100663319, 201326611, 402653189, 805306457, 1610612741);

{$R-,Q-}

function GetGoodHashSize(dataSize: cardinal): cardinal;
var
  iHashSize: integer;
  upper    : cardinal;
begin
  upper := 1 SHL Low(CGpGoodHashSizes);
  for iHashSize := Low(CGpGoodHashSizes) to High(CGpGoodHashSizes) do begin
    Result := CGpGoodHashSizes[iHashSize];
    if dataSize <= upper then
      Exit;
    upper := 2*upper;
  end;
  raise Exception.CreateFmt('GetGoodHashSize: Only data sizes up to %d are supported',
    [upper div 2]);
end;

function HashOf(data: pointer; dataLength: integer): cardinal;
var
  TempPart: longword;
  RemainingBytes: integer;
begin
  if not Assigned(data) or (dataLength <= 0) then
  begin
    Result := 0;
    Exit;
  end;
  Result := dataLength;
  RemainingBytes := dataLength and 3;
  dataLength := dataLength shr 2;
  while dataLength > 0 do
  begin
    inc(Result, PWord(data)^);
    TempPart := (PWord(Pointer(Cardinal(data)+2))^ shl 11) xor Result;
    Result := (Result shl 16) xor TempPart;
    data := Pointer(Cardinal(data) + 4);
    inc(Result, Result shr 11);
    dec(dataLength);
  end;
  // end case
  if RemainingBytes = 3 then
  begin
    inc(Result, PWord(data)^);
    Result := Result xor (Result shl 16);
    Result := Result xor (PByte(Pointer(Cardinal(data)+2))^ shl 18);
    inc(Result, Result shr 11);
  end
  else if RemainingBytes = 2 then
  begin
    inc(Result, PWord(data)^);
    Result := Result xor (Result shl 11);
    inc(Result, Result shr 17);
  end
  else if RemainingBytes = 1 then
  begin
    inc(Result, PByte(data)^);
    Result := Result xor (Result shl 10);
    inc(Result, Result shr 1);
  end;
  Result := Result xor (Result shl 3);
  inc(Result, Result shr 5);
  Result := Result xor (Result shl 4);
  inc(Result, Result shr 17);
  Result := Result xor (Result shl 25);
  inc(Result, Result shr 6);
end;

function HashOf(const key: string): cardinal;
begin
  if Length(key) = 0 then
    Result := 0
  else
    Result := HashOf(@key[1], Length(key) * SizeOf(Char));
end;

{ TGpStringHashEnumerator }

constructor TGpStringHashEnumerator.Create(stringHash: TGpStringHash);
begin
  inherited Create;
  sheIndex := 0;
  sheHash := stringHash;
  sheKV := TGpStringHashKV.Create;
end; { TGpStringHashEnumerator.Create }

destructor TGpStringHashEnumerator.Destroy;
begin
  FreeAndNil(sheKV);
  inherited;
end; { TGpStringHashEnumerator.Destroy }

function TGpStringHashEnumerator.GetCurrent: TGpStringHashKV;
begin
  sheKV.Key := sheHash.shItems[sheIndex].Key;
  sheKV.Value := sheHash.shItems[sheIndex].Value;
  Result := sheKV;
end; { TGpStringHashEnumerator.GetCurrent }

function TGpStringHashEnumerator.MoveNext: boolean;
begin
  Result := sheIndex < (sheHash.shFirstEmpty - 1);
  if Result then
    Inc(sheIndex);
end; { TGpStringHashEnumerator.MoveNext }

{ TGpStringHash }

constructor TGpStringHash.Create(numItems: cardinal; canGrow: boolean);
begin
  Create(GetGoodHashSize(numItems), numItems, canGrow);
end; { TGpStringHash.Create }

constructor TGpStringHash.Create(numBuckets, numItems: cardinal; canGrow: boolean);
begin
  inherited Create;
  SetLength(shBuckets, numBuckets);
  SetLength(shItems, numItems + 1);
  shItems[0].Value := ''; // sentinel for the ValueOf operation
  shSize := numItems;
  shNumBuckets := numBuckets;
  shFirstEmpty := 1;
  shCanGrow := canGrow;
end; { TGpStringHash.Create }

destructor TGpStringHash.Destroy;
begin
  SetLength(shItems, 0);
  SetLength(shBuckets, 0);
  inherited Destroy;
end; { TGpStringHash.Destroy }

procedure TGpStringHash.Add(const key: string; value: string);
var
  bucket: PGpHashItem;
  hash  : cardinal;
begin
  if shFirstEmpty > shSize then
    if shCanGrow then
      Grow
    else
      raise Exception.Create('TGpStringHash.Add: Maximum size reached');
  hash := HashOf(key) mod shNumBuckets;
  bucket := @(shItems[shFirstEmpty]); // point to an empty slot in the pre-allocated array
  bucket^.Key := key;
  bucket^.Value := value;
  bucket^.Next := shBuckets[hash];
  shBuckets[hash] := shFirstEmpty;
  Inc(shFirstEmpty);
end; { TGpStringHash.Add }

function TGpStringHash.Count: integer;
begin
  Result := shFirstEmpty - 1;
end; { TGpStringHash.Count }

function TGpStringHash.Find(const key: string; var value: string): boolean;
var
  bucket: integer;
begin
  bucket := FindBucket(key);
  if bucket > 0 then begin
    value := shItems[bucket].Value;
    Result := true;
  end
  else
    Result := false;
end; { TGpStringHash.Find }

function TGpStringHash.GetEnumerator: TGpStringHashEnumerator;
begin
  Result := TGpStringHashEnumerator.Create(Self);
end; { TGpStringHash.GetEnumerator }

function TGpStringHash.FindBucket(const key: string): cardinal;
begin
  Result := shBuckets[HashOf(key) mod shNumBuckets];
  while (Result <> 0) and (shItems[Result].Key <> key) do
    Result := shItems[Result].Next;
end; { TGpStringHash.FindBucket }

procedure TGpStringHash.ForEach(enumerator: TGpStringHashEnumMethod);
var
  enum: TGpStringHashEnumerator;
begin
  enum := GetEnumerator;
  try
    while enum.MoveNext do
      enumerator(enum.Current);
  finally FreeAndNil(enum); end;
end; { TGpStringHash.ForEach }

function TGpStringHash.GetHashItem(idxHashItem: cardinal): PGpHashItem;
begin
  if idxHashItem > 0 then
    Result := @shItems[idxHashItem]
  else
    Result := nil;
end; { TGpStringHash.GetHashItem }

function TGpStringHash.GetItems(const key: string): string;
begin
  Result := ValueOf(key);
end; { TGpStringHash.GetItems }

procedure TGpStringHash.Grow;
var
  bucket      : PGpHashItem;
  hash        : cardinal;
  oldBucket   : PGpHashItem;
  oldIndex    : integer;
  shOldBuckets: array of cardinal;
  shOldItems  : array of TGpHashItem;
begin
  SetLength(shOldBuckets, Length(shBuckets));
  Move(shBuckets[0], shOldBuckets[0], Length(shBuckets) * SizeOf(shBuckets[0]));
  SetLength(shOldItems, Length(shItems));
  for oldIndex := 0 to Length(shItems) - 1 do  begin
    shOldItems[oldIndex] := shItems[oldIndex];
    shItems[oldIndex].Key := '';
    shItems[oldIndex].Next := 0;
  end;
  SetLength(shItems, 2*Length(shItems) + 1);
  SetLength(shBuckets, GetGoodHashSize(Length(shItems)));
  FillChar(shBuckets[0], Length(shBuckets) * SizeOf(shBuckets[0]), 0);
  shItems[0].Value := ''; // sentinel for the ValueOf operation
  shSize := Length(shItems) - 1;
  shNumBuckets := Length(shBuckets);
  shFirstEmpty := 1;
  for oldIndex := 1 to Length(shOldItems) - 1 do begin
    oldBucket := @(shOldItems[oldIndex]);
    hash := HashOf(oldBucket.Key) mod shNumBuckets;
    bucket := @(shItems[shFirstEmpty]); // point to an empty slot in the pre-allocated array
    Move(oldBucket^, bucket^, SizeOf(bucket^) - SizeOf(bucket^.Next));
    bucket^.Next := shBuckets[hash];
    shBuckets[hash] := shFirstEmpty;
    Inc(shFirstEmpty);
  end;
  FillChar(shOldItems[0], Length(shOldItems) * SizeOf(shOldItems[0]), 0); //prevent string refcount problems
end; { TGpStringHash.Grow }

function TGpStringHash.HasKey(const key: string): boolean;
begin
  Result := (FindBucket(key) <> 0);
end; { TGpStringHash.HasKey }

procedure TGpStringHash.SetItems(const key: string; const value: string);
begin
  Update(key, value);
end; { TGpStringHash.SetItems }

procedure TGpStringHash.Update(const key: string; value: string);
var
  bucket: integer;
begin
  bucket := FindBucket(key);
  if bucket > 0 then
    shItems[bucket].Value := value
  else
    Add(key, value);
end; { TGpStringHash.Update }

function TGpStringHash.ValueOf(const key: string): string;
var
  bucket: integer;
begin
  bucket := FindBucket(key);
  if bucket > 0 then
    Result := shItems[bucket].Value
  else
    raise Exception.CreateFmt('TGpStringHash.ValueOf: Key %s does not exist', [key]);
end; { TGpStringHash.ValueOf }

end.


