{===============================================================================

Author  : Ivan Dyachenko
E-mail  : ivan.dyachenko@gmail.com
Site    : http://atgrand.com
Project : http://clevertis.atgrand.com
Date    : 22.09.2007 16:06:43

===============================================================================}

unit iHashInt;

interface
uses Classes;

 Const Mask = Cardinal(not 1);
 Type
 PPHashItem = ^PHashItem;
  PHashItem = ^THashItem;
  THashItem = record
    Next: PHashItem;
    Key: Integer;
    Value: pointer;
  end;

  TArrayOfPHashItem = array Of  PHashItem;

//==============================================================================

 TInt32Hash = class
 Count,Size,MaxDublicate, Dublicate:Cardinal;
  private
    Buckets: TArrayOfPHashItem;
   // Count,Size,MaxDublicate, Dublicate:Cardinal;
  protected
    function Find(const Key: Integer): PPHashItem;

  public
    constructor Create(Size: Cardinal = 256);
    destructor Destroy; override;
    procedure Add(const Key: Integer; Value: pointer);
    procedure Clear;
    procedure ReHash;
    procedure Remove(const Key: Integer);
    function Modify(const Key: Integer; Value: pointer): Boolean;
    function ValueOf(const Key: Integer): pointer;
    function ProstoeChislo(v: Cardinal): Cardinal;
  end;

  THashedIntList = class
  private
    FItems       : TList;
    FItemsInd    : TInt32Hash;
    FCurrentItem : integer;
    function GetCurrentItem: Pointer;
    function GetCurrentItemName: integer;
    function GetVariables(Index: Integer): Pointer;
    procedure SetVariables(Index: Integer; const Value: Pointer);
  public

    constructor Create(Size : integer = 256);
    destructor  Destroy; override;

    procedure Clear;
    procedure Delete(I: integer);

    function  Next : Boolean;

    property Vars[Index: Integer]: Pointer read GetVariables write SetVariables; default;
    property CurrentValue : Pointer read GetCurrentItem;
    property CurrentID    : Integer read GetCurrentItemName;
  end;

//==============================================================================

implementation
    Const mdk=Cardinal(3);

{ TInt32Hash }
       Function TInt32Hash.ProstoeChislo(v: Cardinal): Cardinal;
          VAR i:Cardinal;
              Find:Boolean;
        Begin
         Result:=(v and mask)+1;
         Find:=false;

          While true do
          Begin
          i:=3;

               While i<(result div 3) do
                Begin
                  If (result mod i)= 0 Then
              Begin
               Find:=false;
               break
              end
               Else inc(i,2);
                end;

              If Find Then
                   exit
                else
               begin
               Find:=true;
               inc(result,2);
                end;
          end;

         End;


procedure TInt32Hash.Add(const Key: Integer; Value: pointer);
var
  Hash: Cardinal;
  Bucket: PHashItem;
begin
  Hash := Cardinal(Key) mod Size;
  New(Bucket);
  Bucket.Key := Key;
  Bucket.Value := Value;
  Bucket.Next := Buckets[Hash];
   If Assigned(Buckets[Hash]) Then
   Begin
   Inc(self.Dublicate); inc(count);
   Buckets[Hash] := Bucket;
   If  self.Dublicate>=self.MaxDublicate Then
   rehash;
   End
   else
   begin
  inc(count);
  Buckets[Hash] := Bucket;
   end;
end;

procedure TInt32Hash.Clear;
var
  I: Integer;
  P, N: PHashItem;
begin
  for I := 0 to Length(Buckets) - 1 do
  begin
    P := Buckets[I];
    while P <> nil do
    begin
      N := P^.Next;
      Dispose(P);
      P := N;
    end;
    Buckets[I] := nil;
  end;
  Count:=0;
  Dublicate:=0;

end;

constructor TInt32Hash.Create(Size: Cardinal);
begin
  inherited Create;
  Self.Size:=ProstoeChislo(Size);
  SetLength(Buckets, Self.Size);
  Count:=0;
  Dublicate:=0;
  MaxDublicate:=Size div mdk;
end;

destructor TInt32Hash.Destroy;
begin
  Clear;
  inherited Destroy;
end;

function TInt32Hash.Find(const Key: Integer): PPHashItem;
var
  Hash: Cardinal;
begin
  Hash := Cardinal(Key) mod Size;
  Result := @Buckets[Hash];
  while Result^ <> nil do
  begin
    if Result^.Key = Key then
      Exit
    else
      Result := @Result^.Next;
  end;
end;



function TInt32Hash.Modify(const Key: Integer; Value: pointer): Boolean;
var
  P: PHashItem;
begin
  P := Find(Key)^;
  if P <> nil then
  begin
    Result := True;
    P^.Value := Value;
  end
  else
    Result := False;
end;

procedure TInt32Hash.Remove(const Key: Integer);
var
  P: PHashItem;
  Prev: PPHashItem;
begin
  Prev := Find(Key);
  P := Prev^;
  if P <> nil then
  begin
    Prev^ := P^.Next;
    Dispose(P);
  end;
end;

function TInt32Hash.ValueOf(const Key: Integer): pointer;
var
  P: PHashItem;
begin
  P := Find(Key)^;
  if P <> nil then
    Result := P^.Value
  else
    Result := nil;
end;

procedure TInt32Hash.ReHash;
 Var TempBuckets:TArrayOfPHashItem;
    Temp,Bucket:PHashItem;
  I,Hash:Cardinal;
begin
  Size:=ProstoeChislo(size*2);
  Self.MaxDublicate:=Size div mdk;
  SetLength(TempBuckets,Size);
  self.Dublicate:=0;
   For I:=0 To Length(self.Buckets)-1 Do
    If Assigned(self.Buckets[i]) Then
     Begin
    Temp:=self.Buckets[i];
    While Assigned(Temp) Do
     Begin
   Hash := Cardinal(Temp.Key) mod Size;
   Bucket:=Temp;
   Temp:=Temp.Next;

   Bucket^.Next := TempBuckets[Hash];
   If Assigned(TempBuckets[Hash]) Then
   Inc(self.Dublicate);

  TempBuckets[Hash] := Bucket;
  End;
   End;
   Self.Buckets:=TempBuckets;
end;

{ THashedIntList }

procedure THashedIntList.Clear;
begin
  FItems.Clear;
  FItemsInd.Clear;
end;

constructor THashedIntList.Create(Size : integer = 256);
begin
  FItems          := TList.Create;
  FItems.Capacity := Size;
  FItemsInd       := TInt32Hash.Create(Size);
  FCurrentItem    := -1;
end;

procedure THashedIntList.Delete(I: integer);
var p: Pointer;
begin
  p := FItemsInd.ValueOf(I);
  if p<>nil then FItems.Remove(p);
  FItemsInd.Remove(I);
end;

destructor THashedIntList.Destroy;
begin
  Clear;
  FItems.Free;
  FItemsInd.Free;
  inherited;
end;

function THashedIntList.GetCurrentItem: Pointer;
begin
  Result := FItems.Items[FCurrentItem];
end;

function THashedIntList.GetCurrentItemName: integer;
begin
  // Не обязательно
  Result := FCurrentItem;
end;

function THashedIntList.GetVariables(Index: Integer): Pointer;
begin
  Result := FItemsInd.ValueOf(Index);
end;

function THashedIntList.Next: Boolean;
begin
  inc(FCurrentItem);
  Result := FCurrentItem<FItems.Count;
  if not Result then FCurrentItem := -1;
end;

procedure THashedIntList.SetVariables(Index: Integer; const Value: Pointer);
var p:Pointer;
begin
  p := GetVariables(Index);
  if (p<>nil) then
  begin
    FItems.Remove(p);
  end;
  FItemsInd.Add(Index,Value);
  FItems.Add(Value);
end;

end.


