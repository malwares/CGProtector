{*******************************************************}
{                                                       }
{                Delphi VCL Extensions                  }
{                   Storage library                     }
{                                                       }
{         Copyright (c) 2000-2007 Deepsoftware          }
{                                                       }
{           www - http://www.deepsoftware.com           }
{              email - ray@deepsoftware.com             }
{                                                       }
{   This unit is based on LZRW1KH unit by Kurt HAENEN   }
{*******************************************************}
unit rsLZRWCompression;

interface

{$R-} { NO range checking !! }


uses SysUtils, Classes;

const
  BufferMaxSize = 32768;
  BufferMax = BufferMaxSize-1;
  BufferMaxIndex = BufferMax+15;
  FLAG_Copied = $80;
  FLAG_Compress = $40;

type
  Int16 = SmallInt;
  BufferIndex = 0..BufferMax + 15;
  BufferSize = 0..BufferMaxSize;
  { extra bytes needed here if compression fails      *dh *}
  BufferArray = array [BufferIndex] of byte;
  BufferPtr = ^BufferArray;


  ELzrw1KHCompressor = Class(Exception);

procedure rsLZRWStreamCompression(Source, Dest: TStream);
procedure rsLZRWStreamDecompression(Source, Dest: TStream);

function rsLZRWBufCompression(Source,Dest: BufferPtr; SourceSize: BufferSize): BufferSize;
function rsLZRWBufDecompression(Source,Dest: BufferPtr; SourceSize: BufferSize): BufferSize;


implementation

type
  HashTable = array [0..4095] of Int16;
  HashTabPtr = ^Hashtable;

var
  Hash: HashTabPtr;

                             { check if this string has already been seen }
                             { in the current 4 KB window }
function GetMatch(Source: BufferPtr; X: BufferIndex; SourceSize: BufferSize;
                  Hash: HashTabPtr; var Size: word; var Pos: BufferIndex): boolean;
var
  HashValue: word;
  TmpHash: Int16;
begin
  HashValue := (40543*((((Source^[X] shl 4) xor Source^[X+1]) shl 4) xor
                                     Source^[X+2]) shr 4) and $0FFF;
  Result := FALSE;
  TmpHash := Hash^[HashValue];
  if (TmpHash <> -1) and (X - TmpHash < 4096) then begin
    Pos := TmpHash;
    Size := 0;
    while ((Size<18) and (Source^[X+Size]=Source^[Pos+Size]) and (X+Size<SourceSize))
      do Inc(Size);
    Result := Size>=3;
  end;
  Hash^[HashValue] := X;
end;


{ compress a buffer of max. 32 KB }
function rsLZRWBufCompression(Source, Dest: BufferPtr; SourceSize: BufferSize): BufferSize;
var
  Bit,Command,Size: word;
  Key: word;
  X,Y,Z,Pos: BufferIndex;
BEGIN
  FillChar(Hash^,SizeOf(Hashtable), $FF);
  Dest^[0] := FLAG_Compress;
  X := 0;
  Y := 3;
  Z := 1;
  Bit := 0;
  Command := 0;
  while (X<SourceSize) and (Y<=SourceSize) do begin
    if Bit>15 then begin
      Dest^[Z] := HI(Command);
      Dest^[Z+1] := LO(Command);
      Z := Y;
      Bit := 0;
      Inc(Y,2)
    end;
    Size := 1;
    while ((Source^[X]=Source^[X+Size]) and (Size<$FFF) and (X+Size<SourceSize)) do Inc(Size);
    if Size>=16 then begin
      Dest^[Y] := 0;
      Dest^[Y+1] := HI(Size-16);
      Dest^[Y+2] := LO(Size-16);
      Dest^[Y+3] := Source^[X];
      Inc(Y,4);
      Inc(X,Size);
      Command := (Command shl 1) + 1;
    end
    else begin { not size >= 16 }
      if GetMatch(Source,X,SourceSize,Hash,Size,Pos) then begin
        Key := ((X-Pos) shl 4) + (Size-3);
        Dest^[Y] := HI(Key);
        Dest^[Y+1] := LO(Key);
        Inc(Y,2);
        Inc(X,Size);
        Command := (Command shl 1) + 1
      end
      else begin
        Dest^[Y] := Source^[X];
        Inc(Y);
        Inc(X);
        Command := Command shl 1
      end;
    end; { size <= 16 }
    Inc(Bit);
  end; { while x < sourcesize ... }
  Command := Command shl (16-Bit);
  Dest^[Z] := HI(Command);
  Dest^[Z+1] := LO(Command);
  if Y>SourceSize then begin
    Move(Source^[0], Dest^[1], SourceSize);
    Dest^[0] := FLAG_Copied;
    Y := SUCC(SourceSize);
  end;
  Result := Y;
end;


function rsLZRWBufDecompression(Source,Dest: BufferPtr; SourceSize: BufferSize): BufferSize;
var
  X,Y,Pos: BufferIndex;
  Command,Size,K: WORD;
  Bit: BYTE;
  SaveY: BufferIndex; { * dh * unsafe for-loop variable Y }
begin
  if (Source^[0] = FLAG_Copied) then  begin
     SaveY := 1;
    for Y := 1 to PRED(SourceSize) do begin
      Dest^[PRED(Y)] := Source^[Y];
      SaveY := Y;
    end;
    Y := SaveY;
  end
  else begin
    Y := 0;
    X := 3;
    Command := (Source^[1] shl 8) + Source^[2];
    Bit := 16;
    while X<SourceSize do begin
      if Bit=0 then begin
        Command := (Source^[X] shl 8) + Source^[X+1];
        Bit := 16;
        Inc(X,2);
      end;
      if (Command and $8000)=0 then begin
        Dest^[Y] := Source^[X];
        Inc(X);
        Inc(Y);
      end
      else begin  { command and $8000 }
        Pos := ((Source^[X] shl 4) + (Source^[X+1] shr 4));
        if Pos=0 then begin
          Size := (Source^[X+1] shl 8) + Source^[X+2] + 15;
          for K := 0 to Size do Dest^[Y+K] := Source^[X+3];
          Inc(X,4);
          Inc(Y,Size+1)
        end
        else begin  { pos = 0 }
          Size := (Source^[X+1] and $0F)+2;
          for K := 0 to Size do
            Dest^[Y+K] := Dest^[Y-Pos+K];
          Inc(X,2);
          Inc(Y,Size+1)
        end; { pos = 0 }
      end;  { command and $8000 }
      Command := Command shl 1;
      Dec(Bit);
    end { while x < sourcesize }
  end;
  Result := Y;
end;  { decompression }


procedure rsLZRWStreamCompression(Source, Dest: TStream);
var
  bIn, bOut: BufferPtr;
  r,s: Longint;
begin
  GetMem(bIn, BufferMaxIndex);
  GetMem(bOut, BufferMaxIndex);
  try
    r := BufferMaxIndex;
    while r=BufferMaxIndex do begin
      r:=Source.Read(bIn^, BufferMaxIndex);
      if r>0 then begin
        s:=rsLZRWBufCompression(bIn, bOut, r);
        Dest.Write(s, SizeOf(s));
        Dest.WriteBuffer(bOut^, s);
      end;
    end;
  finally
    FreeMem(bIn, BufferMaxIndex);
    FreeMem(bOut, BufferMaxIndex);
  end;
end;

procedure rsLZRWStreamDecompression(Source, Dest: TStream);
var
  c, s: longint;
  bIn, bOut: BufferPtr;
begin
  GetMem(bIn, BufferMaxIndex);
  GetMem(bOut, BufferMaxIndex);
  try
    while True do begin
      c := Source.Read(s, SizeOf(s));
      if (c<>SizeOf(s)) or (s=0) then Break;
      c := Source.Read(bIn^, s);
      if c<s then Break;
      s:=rsLZRWBufDecompression(bIn, bOut, c);
      Dest.WriteBuffer(bOut^, s);
    end;
  finally
    FreeMem(bIn, BufferMaxIndex);
    FreeMem(bOut, BufferMaxIndex);
  end;
end;



initialization
  GetMem(Hash,Sizeof(Hashtable));

finalization
  if Hash<>nil then FreeMem(Hash, Sizeof(HashTable));

end.
