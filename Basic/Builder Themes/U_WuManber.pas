unit U_WuManber;

interface
uses
windows,
sysutils,
U_Utils,
classes;

const
 MAXHASH = $7FFF;
 MASK = $1F;

type
  PNode = ^Node;
  Node = record
    Pattern : TexByteArray;
    Length : integer;
    virusname : string;
  end;

  TWUMatch = class
  private
    FCount   : longint;
    Prefix: Array of Integer;
    Shift: Array[0..MAXHASH] of Integer;
    Hash: Array[0..MAXHASH] of TList;
    Pat : array of PNode;
    Lmin : integer;
    B : integer;
  Public
    Procedure InitHash;
    constructor Create;
    Destructor Destroy; override;
    Procedure Clear;
    Procedure AddPattern(Pattern,virusname: string);
    Function Search(const buffer: TexByteArray):String;
    Function SearchFile(const Filename:string):String;
    Property Count : integer read FCount;
  end;

var
WuMach:TWUMatch;

implementation

function HexToInt(HexNum: string): LongInt;
begin
   Result:=StrToInt('$' + HexNum) ;
end;

function GetByte(hexnum:string):TexByteArray;
var
i,d : integer;
begin
  setlength(result,length(hexnum) div 2);
  d := 0;
  i:=1;
  While i<Length(hexnum) Do
  begin
    Result[d] := HexToInt(Copy(hexnum,i,2));
    Inc(i,2);
    Inc(d);
  end;
end;

constructor TWUMatch.Create;
var
i : integer;
begin
  inherited create;
  FCount := 0;
  lmin := High(Integer);
  for i := 0 to MAXHASH do begin
    Shift[i] := 0;
    hash[i] := nil;
  end;
  setlength(Pat,FCount);
  setlength(Prefix,FCount);
end;
{---------------}
Destructor TWUMatch.Destroy;
begin
  Clear;
  FCount := 0;
  lmin := High(Integer);
  setlength(Pat,FCount);
  setlength(Prefix,FCount);
  inherited Destroy;
end;
{---------------}
Procedure TWUMatch.Clear;
var
i : integer;
begin
  for i := 0 to FCount-1 do begin
    dispose(Pat[i]);
  end;
  for i := 0 to MAXHASH do
    if assigned(Hash[i]) then hash[i].Free;
end;
{---------------}
procedure TWUMatch.InitHash;
var
r,def,i,mi,h: integer;
begin
  for r := 0 to FCount -1 do begin
    if lmin > pat[r].Length then lmin := pat[r].Length;
  end;
  if lmin = 1 then B := 1
  else if (lmin > 2) and (lmin*FCount > 400) then B := 3
  else B := 2;
  def := lmin - B +1 ;
  for i := 0 to MAXHASH do Shift[i] := def;
  Setlength(Prefix,FCount);
  for r := 0 to FCount - 1 do begin
    mi := pat[r].Length;
    if B=1 then Prefix[r] := Integer(pat[r].Pattern[mi-lmin])
    else Prefix[r] := (Integer(pat[r].Pattern[mi-lmin]) shl 8) + Integer(pat[r].Pattern[mi-lmin+1]);
  end;
  for r := 0 to FCount - 1 do begin
    mi := pat[r].Length;
    for i := (mi - lmin + B)-1 to mi - 1 do begin
      h := Integer(pat[r].Pattern[i]) AND MASK;
      if B >= 2 then h := (h shl 5) + (Integer(pat[r].Pattern[i-1]) and MASK);
      if B >= 3 then h := (h shl 5) + (Integer(pat[r].Pattern[i-2]) and MASK);
      if Shift[h] > mi-i then Shift[h] := mi-i;
    end;
    h := Integer(pat[r].Pattern[mi]) AND MASK;
    if B >= 2 then h := (h shl 5) + (Integer(pat[r].Pattern[mi-1]) and MASK);
    if B >= 3 then h := (h shl 5) + (Integer(pat[r].Pattern[mi-2]) and MASK);
    Shift[h] := 0;
    if not assigned(Hash[h]) then Hash[h] := TList.Create;
    Hash[h].Add(Pointer(r));
  end;
end;
{---------------}
Procedure TWUMatch.AddPattern(Pattern,virusname: string);
var
N : PNode;
mi : integer;
pattemp : TexByteArray;
begin
  pattemp := GetByte(Pattern);
  mi := Length(pattemp)-1;
  N := New(PNode);
  N^.Pattern := pattemp;
  N^.virusname := virusname;
  N^.Length := mi;
  inc(FCount);
  SetLength(Pat, FCount);
  pat[FCount-1] := N;
end;
{---------------}
Function TWUMatch.Search(const buffer: TexByteArray):String;
var
k,n,h,r,i,j : integer;
TextPref: Integer;
begin
  result := '';
  if lmin = High(Integer) then begin
  exit;
  end;
  k := lmin;
  n := length(buffer)-1;
  while k <= n do begin
    h := Integer(buffer[k]) AND MASK;
    if B >= 2 then h := (h shl 5) + (Integer(buffer[k-1]) and MASK);
    if B >= 3 then h := (h shl 5) + (Integer(buffer[k-2]) and MASK);
    if shift[h]=0 then begin
      if B=1 then TextPref := buffer[k - lmin]
      else TextPref := (buffer[k - lmin] shl 8) + buffer[k - lmin + 1];
      if assigned(Hash[h]) then begin
        for r := 0 to Hash[h].Count - 1 do begin
          i := Integer(Hash[h].Items[r]);
          if Prefix[i] = TextPref then begin
            if k >= pat[i].Length then begin
              j := 0;
              while (j <= pat[i].Length) and (buffer[k-j] = pat[i].Pattern[pat[i].Length-j]) do begin
                inc(j);
              end;
              if (j-1 = pat[i].Length) then begin
                  result := pat[i].virusname;
                  exit;
              end;
            end;
          end;
        end;
      end;
      k := k + 1;
    end else k := k + shift[h];
  end;
end;

Function TWUMatch.SearchFile(const Filename:string):String;
var
buffer : TexByteArray;
begin
  result := '';
  if FileToBytes(Filename,buffer) then
  begin
    result := Search(buffer);
  end;
end;

initialization
WuMach:=TWUMatch.Create;

finalization
WuMach.Free;

end.
