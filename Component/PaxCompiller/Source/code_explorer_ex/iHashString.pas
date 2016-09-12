{===============================================================================

Author  : Ivan Dyachenko
E-mail  : ivan.dyachenko@gmail.com
Site    : http://atgrand.com
Project : http://clevertis.atgrand.com
Date    : 22.09.2007 16:06:43

===============================================================================}

unit iHashString;

interface
  uses Classes, SysUtils, Variants, iHash, IniFiles, Unicode;

Const

  Mask = Cardinal(not 1);
  mdk  = Cardinal(3);

Type

  PPHashItem = ^PHashItem;
  PHashItem  = ^THashItem;
  THashItem  = record
    Next  : PHashItem;
    Key   : WideString;
    Value : Integer;
  end;

  PVarItem   = ^TVarItem;
  TVarItem   = record
    Key   : WideString;
    Value : Variant;
  end;

//==============================================================================
// Всякие фитчи с масивами

  TArrayOfPHashItem = array of PHashItem;

  TStringHashTable = class(TObject)
    Count        : Cardinal;
    Size         : Cardinal;
    MaxDublicate : Cardinal;
    Dublicate    : Cardinal;
  private
    Buckets : TArrayOfPHashItem;
  protected
    function Find  (const Key : WideString): PPHashItem;
    function HashOf(const Key : WideString): Cardinal;
  public
    constructor Create(Size: Cardinal = 16);
    destructor  Destroy; override;
    procedure Add(const Key: WideString; Value: Integer);
    procedure Clear;
    procedure Remove(const Key : WideString);
    procedure ReHash;
    function Modify (const Key : WideString; Value: Integer): Boolean;
    function ValueOf(const Key : WideString): Integer;
    function PrimeNumber(Number : Cardinal): Cardinal;
  end;

//------------------------------------------------------------------------------

  THashedVarList = class(TVariantHash)
  private
    FFileName : String;
    FAutoSave : Boolean;
    function GetBool (const Index: String): Boolean;
    function GetFloat(const Index: String): Double;
    function GetInt  (const Index: String): Integer;
    function GetPtr  (const Index: String): Pointer;
    function GetStr  (const Index: String): WideString;

    procedure SetBool     (const Index: String; const Value: Boolean);
    procedure SetFloat    (const Index: String; const Value: Double);
    procedure SetInt      (const Index: String; const Value: Integer);
    procedure SetPtr      (const Index: String; const Value: Pointer);
    procedure SetStr      (const Index: String; const Value: WideString);

    function GetVarList   (const Index: String): THashedVarList;
    function GetCurrentList    : THashedVarList;
    function GetCurrentItemBool: Boolean;
    function GetCurrentItemDbl : Double;
    function GetCurrentItemInt : Integer;
    function GetCurrentItemStr : WideString;
    function GetCurrentItemPtr : Pointer;

    procedure SetCurrentItemBool(const Value: Boolean);
    procedure SetCurrentItemDbl (const Value: Double);
    procedure SetCurrentItemInt (const Value: Integer);
    procedure SetCurrentItemStr (const Value: WideString);
    procedure SetCurrentItemPtr (const Value: Pointer);

    function GetCurrentItemData: String;
    function GetData(const Index: String): String;

    procedure SetCurrentItemData(const Value: String);
    procedure SetData(const Index: String; const Value: String);
  public

    procedure qClear;
    procedure SaveToFile   (const F : String);
    procedure LoadFromFile (const F : String);

    function  isObj : Boolean;
    function  Clone : THashedVarList;
    function  CloneTo(Dest : THashedVarList) : Boolean;

    property VarList[const Index: String] : THashedVarList read GetVarList;
    property ValueStr   : WideString read GetCurrentItemStr  write SetCurrentItemStr;
    property ValueData  : String     read GetCurrentItemData write SetCurrentItemData;
    property ValueInt   : Integer    read GetCurrentItemInt  write SetCurrentItemInt;
    property ValuePtr   : Pointer    read GetCurrentItemPtr  write SetCurrentItemPtr;
    property ValueBool  : Boolean    read GetCurrentItemBool write SetCurrentItemBool;
    property ValueDouble: Double     read GetCurrentItemDbl  write SetCurrentItemDbl;
    property List       : THashedVarList read GetCurrentList;

    property Str  [const Index: String]: WideString  read GetStr   write SetStr;
    property Int  [const Index: String]: Integer     read GetInt   write SetInt;
    property Ptr  [const Index: String]: Pointer     read GetPtr   write SetPtr;
    property Bool [const Index: String]: Boolean     read GetBool  write SetBool;
    property Float[const Index: String]: Double      read GetFloat write SetFloat;
    property Data [const Index: String]: String      read GetData  write SetData;

    function QString (const Val: Variant; const Default : WideString)  : WideString;
    function QInteger(const Val: Variant; const Default : Integer)     : Integer;
    function QBoolean(const Val: Variant; const Default : Boolean)     : Boolean;
    function QDouble (const Val: Variant; const Default : Double)      : Double;
    function QPointer(const Val: Variant; const Default : Pointer)     : Pointer;
  end;

//------------------------------------------------------------------------------

  TStringHashInt = class(TVariantHash)
  private
    function GetItem(const Index: String): Integer;
    procedure SetItem(const Index: String; const Value: Integer);
  public
     property Item[const Index: String]:Integer read GetItem write SetItem; default;
  end;

//==============================================================================

  function HVL2VarArr(List : THashedVarList) : Variant;
  function GetSQLVar(Value: Variant): WideString;
  function Q(const S:WideString):WideString;
  function Qi(ins : array of WideString): WideString;
  function fprint(FSQL: WideString; Vars: Variant): WideString; overload;
  function fprint(FSQL: WideString; Vars: array of Variant): WideString; overload;
  function fprint(FSQL: WideString; Vars: THashedVarList): WideString; overload;

implementation

uses iLZH, RegExpr;

//==============================================================================>>>

function HVL2VarArr(List : THashedVarList) : Variant;
var I : Integer;
begin
  Result := VarArrayCreate([0,List.Count-1], varVariant);
  I      := 0;
  while List.Next do
  begin
    if List.isObj then Result[I] := HVL2VarArr(List.List)
                  else Result[I] := List.Value;
    inc(I);
  end;
end;

function GetSQLVar(Value: Variant): WideString;
begin
  Result := 'NULL';
  case TVarData(Value).VType of
    varSmallInt, varInteger, varShortInt, varByte, varWord, varLongWord, varInt64: Result := IntToStr(TVarData(Value).VInteger);
    varSingle, varDouble, varCurrency: Result := FloatToStr(TVarData(Value).VDouble);
    varDate: Result := DateToStr(TVarData(Value).VDate);
    varOleStr, varString: Result := VarToWideStr(Value);
    varBoolean: Result := BoolToStr(TVarData(Value).VBoolean);
    varNull: Result := 'NULL';
  end;
end;

function fprint(FSQL: WideString; Vars: THashedVarList): WideString;
var W : WideString;
begin
  while Vars.Next do
  begin
    W    := '%'+Vars.Key;
    FSQL := preg_replace(W, GetSQLVar(Vars.Value), FSQL);
  end;
  Result := FSQL;
end;

function fprint(FSQL: WideString; Vars: array of Variant): WideString;
var I, J, N : Integer;
    W : WideString;
begin
  J := 0;
  for I := Low(Vars) to High(Vars) do
  begin
    inc(J);
    W    := '%'+inttostr(J);
    FSQL := preg_replace(W, GetSQLVar(Vars[I]), FSQL);
  end;

  Result := FSQL;
end;

function fprint(FSQL: WideString; Vars: Variant): WideString;
var I, J, N : Integer;
    W : WideString;

begin
  J := 0;
  if VarIsArray(Vars) then
     for I := VarArrayLowBound(Vars,  1) to VarArrayHighBound(Vars,  1) do
     begin
        inc(J);
        W    := '%'+inttostr(J);
        FSQL := preg_replace(W, GetSQLVar(Vars[I]), FSQL);
     end
  else
  begin
    W    := '%1';
    FSQL := preg_replace(W, GetSQLVar(Vars), FSQL);
  end;

  Result := FSQL;
end;

function Q(const S:WideString):WideString;
var S2 : WideString;
begin
  Result := (S);
  Result := ''''+Result+'''';
end;

function Qi(ins : array of WideString): WideString;
Var I : integer;
begin
  Result := '(';
  for I := 0 to High(Ins)-1 do
    Result := Result + Q(ins[I]) + ',';
  Result := Result + Q(ins[I]) + ')';
end;

//==============================================================================<<<

procedure TStringHashTable.Add(const Key: WideString; Value: Integer);
var
  Hash: Integer;
  Bucket: PHashItem;
begin
  Hash := HashOf(Key) mod Size;
  New(Bucket);
  Bucket.Key := Key;
  Bucket.Value := Value;
  Bucket.Next := Buckets[Hash];
  if Assigned(Buckets[Hash]) Then
  begin
    inc(self.Dublicate);
    inc(count);
    Buckets[Hash] := Bucket;
    If Self.Dublicate>=self.MaxDublicate Then ReHash;
  end
  else
  begin
    inc(count);
    Buckets[Hash] := Bucket;
  end;
end;

procedure TStringHashTable.Clear;
var
  I     : Integer;
  P, N  : PHashItem;
  Count : Integer;
begin
  Count := Length(Buckets) - 1;
  for I := Count downto 0 do
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
end;

constructor TStringHashTable.Create(Size: Cardinal);
begin
  inherited Create;
  Self.Size := PrimeNumber(Size);
  SetLength(Buckets, Self.Size);
  Count        := 0;
  Dublicate    := 0;
  MaxDublicate := Size div mdk;
end;

destructor TStringHashTable.Destroy;
begin
  Clear;
  inherited Destroy;
end;

function TStringHashTable.Find(const Key: WideString): PPHashItem;
var
  Hash: Integer;
begin
  Hash := HashOf(Key) mod Size;
  Result := @Buckets[Hash];
  while Result^ <> nil do
  begin
    if Result^.Key = Key then
      Exit
    else
      Result := @Result^.Next;
  end;
end;

function TStringHashTable.HashOf(const Key: WideString): Cardinal;
var
  I, N : Integer;
begin
  Result := 0;
  N      := Length(Key);
  for I := 1 to N do
    Result := ((Result shl 2) or (Result shr (SizeOf(Result) * 8 - 2))) xor Ord(Key[I]);
end;

function TStringHashTable.Modify(const Key: WideString; Value: Integer): Boolean;
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

function TStringHashTable.PrimeNumber(Number: Cardinal): Cardinal;
VAR i    : Cardinal;
    Find : Boolean;
Begin
  Result := (Number and mask)+1;
  Find   := false;
  While true do
  Begin
  I:=3;
  While I<(result div 3) do
    Begin
    If (result mod i)= 0 Then
      Begin
       Find:=false;
       break
      end
      Else inc(i,2);
    end;

    If Find Then Exit  else
    begin
      Find:=true;
      inc(result,2);
    end;
  end;
end;

procedure TStringHashTable.ReHash;
Var TempBuckets : TArrayOfPHashItem;
    Temp,Bucket : PHashItem;
    I,Hash      : Cardinal;
begin
  Size := PrimeNumber(size*2);
  Self.MaxDublicate:=Size div mdk;
  SetLength(TempBuckets, Size);
  Self.Dublicate:=0;
   for I:=0 To Length(self.Buckets)-1 Do
    If Assigned(self.Buckets[i]) Then
    begin
      Temp:=self.Buckets[i];
      while Assigned(Temp) Do
      Begin
        Hash   := Cardinal(Temp.Key) mod Size;
        Bucket := Temp;
        Temp   := Temp.Next;

        Bucket^.Next := TempBuckets[Hash];
        If Assigned(TempBuckets[Hash]) Then Inc(self.Dublicate);
        TempBuckets[Hash] := Bucket;
      end;
    end;
    Self.Buckets := TempBuckets;
end;

procedure TStringHashTable.Remove(const Key: WideString);
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

function TStringHashTable.ValueOf(const Key: WideString): Integer;
var
  P: PHashItem;
begin
  P := Find(Key)^;
  if P <> nil then
    Result := P^.Value
  else
    Result := -1;
end;

//==============================================================================
{ THashedVarList }

procedure THashedVarList.qClear;
begin
  First;
  while Next do
    if isObj then
    begin
      List.qClear;
      List.Free;
    end;
  Clear(true);
end;

function THashedVarList.QDouble(const Val: Variant; const Default: Double): Double;
begin
  case TVarData(Val).VType of
    varSmallint..varDate,
    varShortInt..varInt64 : Result := TvarData(Val).VDouble;
    else Result := Default;
  end;
end;

function THashedVarList.QInteger(const Val: Variant; const Default: Integer): Integer;
begin
  case TVarData(Val).VType of
    varSmallint..varSingle,
    varBoolean,
    varShortInt..varInt64 : Result := TvarData(Val).VInteger;
    else Result := Default;
  end;
end;

function THashedVarList.QPointer(const Val: Variant; const Default: Pointer): Pointer;
begin
  case TVarData(Val).VType of
    varSmallint..varSingle,
    varShortInt..varInt64 : Result := TvarData(Val).VPointer;
    varByRef              : Result := TvarData(Val).VPointer;
    else Result := Default;
  end;
end;

function THashedVarList.QString(const Val: Variant; const Default: WideString): WideString;
begin
  case TVarData(Val).VType of
    varNull, varEmpty : Result := Default;
    else Result := VarToWideStr(Val);
  end;
end;

function THashedVarList.Clone: THashedVarList;
begin
  CloneTo(Result);
end;

function THashedVarList.CloneTo(Dest: THashedVarList): Boolean;
  function Clone(S, D : THashedVarList):Boolean;
  begin
    while S.Next do
    begin
      D.Values[S.Key] := S.Value;
      if S.isObj then Clone(S.List, D.VarList[S.Key]);
    end;
    Result := true;
  end;
begin
  Result := Clone(Self, Dest);
end;

function THashedVarList.GetBool(const Index: String): boolean;
begin
  Result := QBoolean(Values[Index], false);
end;

function THashedVarList.GetCurrentItemBool: Boolean;
begin
  Result := QBoolean(Value, false);
end;

function THashedVarList.GetCurrentItemData: String;
begin
  Result := CurrentItem^.Data;
end;

function THashedVarList.GetCurrentItemDbl: Double;
begin
  Result := QDouble(Value, 0);
end;

function THashedVarList.GetCurrentItemInt: integer;
begin
  Result := QInteger(Value, 0);
end;

function THashedVarList.GetCurrentItemPtr: pointer;
begin
  Result := QPointer(Value, Nil);
end;

function THashedVarList.GetCurrentItemStr: WideString;
begin
  Result := QString(Value, '');
end;

function THashedVarList.GetCurrentList: THashedVarList;
begin
  Result := THashedVarList(CurrentItem^.Obj);
end;

function THashedVarList.GetData(const Index: String): String;
var
  P : PHashItemVariant;
begin
  P      := Find(Index);
  Result := '';
  if P <> nil then Exit;
  Result := P^.Data;
end;

function THashedVarList.GetFloat(const Index: String): Double;
begin
  Result := QDouble(Values[Index], 0);
end;

function THashedVarList.GetInt(const Index: String): integer;
begin
  Result := QInteger(Values[Index], 0);
end;

function THashedVarList.GetPtr(const Index: String): pointer;
begin
  Result := QPointer(Values[Index], nil);
end;

function THashedVarList.GetStr(const Index: String): WideString;
begin
  Result := QString(Values[Index], '');
end;

function THashedVarList.GetVarList(const Index: String): THashedVarList;
var Item : PHashItemVariant;
    I    : Integer;
    Cur  : THashedVarList;
    S    : String;
    Ind  : String;
begin
  Ind := Index;
  I   := pos('/', Ind);
  Cur := Self;

  If I<>0 Then
  begin
    Ind := Ind + '/';
    While (I<>0) AND (Cur<>nil) do
    begin
      S   := Copy(Ind, 1, I-1);
      Cur := Cur.VarList[S];
      Delete(Ind, 1, I);
      I   := pos('/', Ind);
    end;
    Result := Cur;
    Exit;
  end;

  Item   := Find(Ind);
  Result := nil;
  if (Item=nil) OR (Item^.Obj=nil) then
  begin
    Result     := THashedVarList.Create(Self);
    Ptr[Ind]   := Result;
    Item       := Find(Ind);
    Item^.Obj  := Result;
  end
  else
    Result    := THashedVarList(Item^.Obj);
end;

function THashedVarList.isObj: Boolean;
begin
  Result := CurrentItem^.Obj<>nil;
end;

procedure THashedVarList.LoadFromFile(const F: String);
var List : THashedStringList;
    I, N : Integer;
begin
  FFileName := F;
  if not FileExists(FFileName) then Exit;

  List := THashedStringList.Create;
  List.LoadFromFile(FFileName);
  First;
  N := List.Count-1;
  For N := I downto 0 do
  begin
    Values[List.Names[I]] := List.ValueFromIndex[I];
  end;

  List.Free;
end;

function THashedVarList.QBoolean(const Val: Variant; const Default: Boolean): Boolean;
begin
  case TVarData(Val).VType of
    varSmallint..varSingle,
    varBoolean,
    varShortInt..varInt64 : Result := TvarData(Val).VBoolean;
    else Result := Default;
  end;
end;

procedure THashedVarList.SaveToFile(const F: String);
var List : THashedStringList;
begin
  FFileName := F;
  List := THashedStringList.Create;
  First;
  while Next do List.Values[Key] := ValueStr;
  List.SaveToFile(FFileName);
  List.Free;
end;

procedure THashedVarList.SetBool(const Index: String; const Value: boolean);
begin
   Values[Index] := Value;
end;

procedure THashedVarList.SetCurrentItemBool(const Value: Boolean);
begin
   SetCurValue(Value);
end;

procedure THashedVarList.SetCurrentItemData(const Value: String);
begin
  CurrentItem^.Data := Value;
end;

procedure THashedVarList.SetCurrentItemDbl(const Value: Double);
begin
   SetCurValue(Value);
end;

procedure THashedVarList.SetCurrentItemInt(const Value: integer);
begin
   SetCurValue(Value);
end;

procedure THashedVarList.SetCurrentItemPtr(const Value: Pointer);
begin
   SetCurValue(Integer(Value));
end;

procedure THashedVarList.SetCurrentItemStr(const Value: WideString);
begin
   SetCurValue(Value);
end;

procedure THashedVarList.SetData(const Index: String; const Value: String);
var
  P: PHashItemVariant;
begin
  P := Find(Index);
  if P = nil then
  begin
    Values[Index] := Value;
    P := Find(Index);
  end;
  P^.Data := Value;
end;

procedure THashedVarList.SetFloat(const Index: String; const Value: Double);
begin
   Values[Index] := Value;
end;

procedure THashedVarList.SetInt(const Index: String; const Value: integer);
begin
   Values[Index] := Value;
end;

procedure THashedVarList.SetPtr(const Index: String; const Value: pointer);
begin
   Values[Index] := Integer(Value);
end;

procedure THashedVarList.SetStr(const Index: String;const Value: WideString);
begin
   Values[Index] := Value;
end;

//==============================================================================
{ TStringHashInt }

function TStringHashInt.GetItem(const Index: String): Integer;
var V : Variant;
begin
  V      := GetValue(Index);
  Result := 0;
  if V<>NULL then
  Result := TVarData(V).VInteger;
end;

procedure TStringHashInt.SetItem(const Index: String; const Value: Integer);
begin
  Values[Index] := Value;
end;

end.