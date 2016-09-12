unit U_Encryption;

interface
uses
windows,U_Chiper;

type
PExByteArray = ^TExByteArray;
TExByteArray = array of byte;

var
KeyEnc : TKey128;

function BXor(const S, Key : Ansistring) : Ansistring;
Function Key128to64(const key :TKey128):TKey64;
function SimpleXor(Str : ansiString; Key: TKey128): ansiString;
function RC4(Str:Ansistring; EncKey:TKey128):Ansistring;
function BFEncrypt(const Key : TKey128;indata :pansichar; dataSize:integer) :ansistring;
function BFEncryptCBC(const Key : TKey128;indata :pansichar; dataSize:integer) :ansistring;
function DESEncrypt(const Key : TKey64;indata :pansichar; dataSize:integer) :ansistring;
function DESEncryptCBC(const Key : TKey64;indata :pansichar; dataSize:integer) :ansistring;
function TripleDESEncrypt(const Key : TKey128;indata :pansichar; dataSize:integer) :ansistring;
function TripleDESEncryptCBC(const Key : TKey128;indata :pansichar; dataSize:integer) :ansistring;
function RDLEncrypt(const Key; KeySize : Longint;indata :pansichar; dataSize:integer) :ansistring;
function RDLEncryptCBC(const Key; KeySize : Longint;indata :pansichar; dataSize:integer) :ansistring;
function CRC32(CRC: LongWord; Data: Pointer; DataSize: LongWord): LongWord; assembler;
Function CrcansiString(source:ansistring):longword;
implementation
uses
MMSystem;

type
  PByteArray = ^TByteArray;
  TByteArray = array[0..32767] of Byte;


Function CrcansiString(source:ansistring):longword;
begin
  result := crc32(0,pansichar(source),length(source));
end;

function BXor(const S, Key : Ansistring) : Ansistring;
var
  I, Z : integer;
  C : ansichar;
  Code : byte;
begin
  Result:= '';
  Z:= length(Key);
  if (Z > 0) and (length(S) > 0) then
  for I:= 1 to length(S) do
  begin
    Code:= ord(Key[(I - 1) mod Z + 1]);
    if S[I] >= #128 then C:= ansichar(ord(S[I]) xor (Code and $7F)) else
    if S[I] >= #64 then C:= ansichar(ord(S[I]) xor (Code and $3F)) else
    if S[I] >= #32 then C:= ansichar(ord(S[I]) xor (Code and $1F)) else
    C:= S[I];
    Result:= Result + C;
  end;
end;


Function Key128to64(const key :TKey128):TKey64;
begin
  Move(key, result, sizeof(TKey64));
end;

function SimpleXor(Str : ansiString; Key: TKey128): ansiString;
var
  X, Y : Integer;
  A : Byte;
begin
  Y := 0;
  for X := 1 to Length(Str) do
  begin
    A := (ord(Str[X]) and $0f) xor (Key[Y] and $0f);
    Str[X] := ansichar((ord(Str[X]) and $f0) + A);
    Inc(Y);
    If Y > length(Key)-1 then Y := 0;
  end;
  Result := Str;
end;

function RC4(Str:Ansistring; EncKey:TKey128):Ansistring;
var
RB    : array[0..255] of integer;
X,Y,Z : longint;
Temp  : Byte;
ByteArray:  TExByteArray;
begin
  if Length(Str) = 0 then Exit;
  if Length(EncKey) = 0 then Exit;
  for X := 0 to 255 do RB[X] := X;
  Y := 0;
  for X := 0 to 255 do
  begin
    Y := (Y + RB[X] + EncKey[X mod (Length(EncKey)-1)]) mod 256;
    Temp := RB[X];
    RB[X] := RB[Y];
    RB[Y] := Temp;
  end;
  Y := 0;
  Z := 0;
  SetLength(ByteArray, Length(str));
  CopyMemory(@ByteArray[0], @str[1], Length(str));
  for X := 0 to Length(str) - 1 do
  begin
    Y := (Y + 1) mod 256;
    Z := (Z + RB[Y]) mod 256;
    Temp := RB[Y];
    RB[Y] := RB[Z];
    RB[Z] := Temp;
    ByteArray[X] := ByteArray[X] xor (RB[(RB[Y] + RB[Z]) mod 256]);
  end;
  SetLength(Result, Length(str));
  CopyMemory(@Result[1], @ByteArray[0], Length(str));
  SetLength(ByteArray, 0);
end;

function BFEncrypt(const Key : TKey128;indata :pansichar; dataSize:integer) :ansistring;
var
Context    : TBFContext;
BlockCount : LongInt;
I          : LongInt;
Block      : TBFBlock;
outdata    : pansichar;
begin
  i := datasize + SizeOf(Block);
  getmem(outdata,i);
  try
    InitEncryptBF(Key, Context);
    BlockCount := (dataSize div SizeOf(Block));
    for I := 0 to BlockCount - 1 do begin
      copymemory(@block[0],indata+(i*SizeOf(Block)),SizeOf(Block));
      EncryptBF(Context, Block, true);
      copymemory(outdata+(i*SizeOf(Block)),@block[0],SizeOf(Block));
    end;
    FillChar(Block, SizeOf(Block), 0);
    I := (dataSize mod SizeOf(Block));
    copymemory(@block[0],indata+(BlockCount*SizeOf(Block)),I);
    PByteArray(@Block)^[SizeOf(Block)-1] := I;
    EncryptBF(Context, Block, true);
    copymemory(outdata+(BlockCount*SizeOf(Block)),@block[0],SizeOf(Block));
    dataSize := (BlockCount +1)*sizeof(block);
    setlength(result,dataSize);
    setstring(result,outdata,dataSize);
  finally
    freemem(outdata);
  end;
end;

function BFEncryptCBC(const Key : TKey128;indata :pansichar; dataSize:integer) :ansistring;
var
Context    : TBFContext;
BlockCount : LongInt;
I          : LongInt;
Block      : TBFBlock;
IV         : TBFBlock;
outdata    : pansichar;
begin
  i := datasize + (SizeOf(Block)*2);
  getmem(outdata,i);
  try
    InitEncryptBF(Key, Context);
    BlockCount := (dataSize div SizeOf(Block));
    Block[0] := timeGetTime;
    Block[1] := timeGetTime;
    EncryptBF(Context, Block, true);
    copymemory(outdata,@Block[0], SizeOf(Block));
    IV := Block;
    for I := 0 to BlockCount - 1 do begin
      copymemory(@block[0],indata+(i*SizeOf(Block)),SizeOf(Block));
      EncryptBFCBC(Context, IV, Block, true);
      IV := Block;
      copymemory(outdata+((i+1)*SizeOf(Block)),@block[0],SizeOf(Block));
    end;
    FillChar(Block, SizeOf(Block), #0);
    I := (dataSize mod SizeOf(Block));
    copymemory(@block[0],indata+(BlockCount*SizeOf(Block)),I);
    PByteArray(@Block)^[SizeOf(Block)-1] := I;
    EncryptBFCBC(Context, IV, Block, true);
    copymemory(outdata+((BlockCount+1)*SizeOf(Block)),@block[0],SizeOf(Block));
    dataSize := (BlockCount +2)*sizeof(block);
    setlength(result,dataSize);
    setstring(result,outdata,dataSize);
  finally
    freemem(outdata);
  end;
end;

function DESEncrypt(const Key : TKey64;indata :pansichar; dataSize:integer) :ansistring;
var
I          : LongInt;
Block      : TDESBlock;
outdata    : pansichar;
Context    : TDESContext;
BlockCount : LongInt;
begin
  i := datasize + SizeOf(Block);
  getmem(outdata,i);
  try
    InitEncryptDES(Key, Context, true);
    BlockCount := (dataSize div SizeOf(Block));
    for I := 0 to BlockCount - 1 do begin
      copymemory(@block[0],indata+(i*SizeOf(Block)),SizeOf(Block));
      EncryptDES(Context, Block);
      copymemory(outdata+(i*SizeOf(Block)),@block[0],SizeOf(Block));
    end;
    FillChar(Block, SizeOf(Block), #0);
    I := (dataSize mod SizeOf(Block));
    copymemory(@block[0],indata+(BlockCount*SizeOf(Block)),I);
    PByteArray(@Block)^[SizeOf(Block)-1] := I;
    EncryptDES(Context, Block);
    copymemory(outdata+(BlockCount*SizeOf(Block)),@block[0],SizeOf(Block));
    dataSize := (BlockCount +1)*sizeof(block);
    setlength(result,dataSize);
    setstring(result,outdata,dataSize);
  finally
    freemem(outdata);
  end;
end;

function DESEncryptCBC(const Key : TKey64;indata :pansichar; dataSize:integer) :ansistring;
var
I          : LongInt;
Block      : TDESBlock;
IV         : TDESBlock;
outdata    : pansichar;
Context    : TDESContext;
BlockCount : LongInt;
begin
  i := datasize + (SizeOf(Block)*2);
  getmem(outdata,i);
  try
    InitEncryptDES(Key, Context, true);
    BlockCount := (dataSize div SizeOf(Block));
    Block[0] := timeGetTime;
    Block[1] := timeGetTime;
    EncryptDES(Context, Block);
    copymemory(outdata,@Block[0], SizeOf(Block));
    IV := Block;
    for I := 0 to BlockCount - 1 do begin
      copymemory(@block[0],indata+(i*SizeOf(Block)),SizeOf(Block));
      EncryptDESCBC(Context, IV, Block);
      IV := Block;
      copymemory(outdata+((i+1)*SizeOf(Block)),@block[0],SizeOf(Block));
    end;
    FillChar(Block, SizeOf(Block), #0);
    I := (dataSize mod SizeOf(Block));
    copymemory(@block[0],indata+(BlockCount*SizeOf(Block)),I);
    PByteArray(@Block)^[SizeOf(Block)-1] := I;
    EncryptDESCBC(Context, IV, Block);
    copymemory(outdata+((BlockCount+1)*SizeOf(Block)),@block[0],SizeOf(Block));
    dataSize := (BlockCount +2)*sizeof(block);
    setlength(result,dataSize);
    setstring(result,outdata,dataSize);
  finally
    freemem(outdata);
  end;
end;

function TripleDESEncrypt(const Key : TKey128;indata :pansichar; dataSize:integer) :ansistring;
var
Context    : TTripleDESContext;
BlockCount : LongInt;
I          : LongInt;
Block      : TDESBlock;
outdata    : pansichar;
begin
  i := datasize + SizeOf(Block);
  getmem(outdata,i);
  try
    InitEncryptTripleDES(Key, Context, true);
    BlockCount := (dataSize div SizeOf(Block));
    for I := 0 to BlockCount - 1 do begin
      copymemory(@block[0],indata+(i*SizeOf(Block)),SizeOf(Block));
      EncryptTripleDES(Context, Block);
      copymemory(outdata+(i*SizeOf(Block)),@block[0],SizeOf(Block));
    end;
    FillChar(Block, SizeOf(Block), #0);
    I := (dataSize mod SizeOf(Block));
    copymemory(@block[0],indata+(BlockCount*SizeOf(Block)),I);
    PByteArray(@Block)^[SizeOf(Block)-1] := I;
    EncryptTripleDES(Context, Block);
    copymemory(outdata+(BlockCount*SizeOf(Block)),@block[0],SizeOf(Block));
    dataSize := (BlockCount +1)*sizeof(block);
    setlength(result,dataSize);
    setstring(result,outdata,dataSize);
  finally
    freemem(outdata);
  end;
end;

function TripleDESEncryptCBC(const Key : TKey128;indata :pansichar; dataSize:integer) :ansistring;
var
Context    : TTripleDESContext;
BlockCount : LongInt;
I          : LongInt;
Block      : TDESBlock;
IV         : TDESBlock;
outdata    : pansichar;
begin
  i := datasize + (SizeOf(Block)*2);
  getmem(outdata,i);
  try
    InitEncryptTripleDES(Key, Context, true);
    BlockCount := (dataSize div SizeOf(Block));
    Block[0] := timeGetTime;
    Block[1] := timeGetTime;
    EncryptTripleDES(Context, Block);
    copymemory(outdata,@Block[0], SizeOf(Block));
    IV := Block;
    for I := 0 to BlockCount - 1 do begin
      copymemory(@block[0],indata+(i*SizeOf(Block)),SizeOf(Block));
      EncryptTripleDESCBC(Context, IV, Block);
      IV := Block;
      copymemory(outdata+((i+1)*SizeOf(Block)),@block[0],SizeOf(Block));
    end;
    FillChar(Block, SizeOf(Block), #0);
    I := (dataSize mod SizeOf(Block));
    copymemory(@block[0],indata+(BlockCount*SizeOf(Block)),I);
    PByteArray(@Block)^[SizeOf(Block)-1] := I;
    EncryptTripleDESCBC(Context, IV, Block);
    copymemory(outdata+((BlockCount+1)*SizeOf(Block)),@block[0],SizeOf(Block));
    dataSize := (BlockCount +2)*sizeof(block);
    setlength(result,dataSize);
    setstring(result,outdata,dataSize);
  finally
    freemem(outdata);
  end;
end;

function RDLEncrypt(const Key; KeySize : Longint;indata :pansichar; dataSize:integer) :ansistring;
var
Context    : TRDLContext;
BlockCount : LongInt;
I          : LongInt;
Block      : TRDLBlock;
outdata    : pansichar;
begin
  i := datasize + SizeOf(Block);
  getmem(outdata,i);
  try
    InitEncryptRDL(Key, KeySize, Context, true);
    BlockCount := (dataSize div SizeOf(Block));
    for I := 0 to BlockCount - 1 do begin
      copymemory(@block[0],indata+(i*SizeOf(Block)),SizeOf(Block));
      EncryptRDL(Context, Block);
      copymemory(outdata+(i*SizeOf(Block)),@block[0],SizeOf(Block));
    end;
    FillChar(Block, SizeOf(Block), #0);
    I := (dataSize mod SizeOf(Block));
    copymemory(@block[0],indata+(BlockCount*SizeOf(Block)),I);
    PByteArray(@Block)^[SizeOf(Block)-1] := I;
    EncryptRDL(Context, Block);
    copymemory(outdata+(BlockCount*SizeOf(Block)),@block[0],SizeOf(Block));
    dataSize := (BlockCount +1)*sizeof(block);
    setlength(result,dataSize);
    setstring(result,outdata,dataSize);
  finally
    freemem(outdata);
  end;
end;

function RDLEncryptCBC(const Key; KeySize : Longint;indata :pansichar; dataSize:integer) :ansistring;
var
Context    : TRDLContext;
BlockCount : LongInt;
I          : LongInt;
Block      : TRDLBlock;
IV         : TRDLBlock;
outdata    : pansichar;
begin
  i := datasize + (SizeOf(Block)*2);
  getmem(outdata,i);
  try
    InitEncryptRDL(Key, KeySize, Context, true);
    BlockCount := (dataSize div SizeOf(Block));
    Block[0] := timeGetTime;
    Block[1] := timeGetTime;
    EncryptRDL(Context, Block);
    copymemory(outdata,@Block[0], SizeOf(Block));
    IV := Block;
    for I := 0 to BlockCount - 1 do begin
      copymemory(@block[0],indata+(i*SizeOf(Block)),SizeOf(Block));
      EncryptRDLCBC(Context, IV, Block);
      IV := Block;
      copymemory(outdata+((i+1)*SizeOf(Block)),@block[0],SizeOf(Block));
    end;
    FillChar(Block, SizeOf(Block), #0);
    I := (dataSize mod SizeOf(Block));
    copymemory(@block[0],indata+(BlockCount*SizeOf(Block)),I);
    PByteArray(@Block)^[SizeOf(Block)-1] := I;
    EncryptRDLCBC(Context, IV, Block);
    copymemory(outdata+((BlockCount+1)*SizeOf(Block)),@block[0],SizeOf(Block));
    dataSize := (BlockCount +2)*sizeof(block);
    setlength(result,dataSize);
    setstring(result,outdata,dataSize);
  finally
    freemem(outdata);
  end;
end;

function CRC32(CRC: LongWord; Data: Pointer; DataSize: LongWord): LongWord; assembler;
asm
         AND    EDX,EDX
         JZ     @Exit
         AND    ECX,ECX
         JLE    @Exit
         PUSH   EBX
         PUSH   EDI
         XOR    EBX,EBX
         LEA    EDI,CS:[OFFSET @CRC32]
@Start:  MOV    BL,AL
         SHR    EAX,8
         XOR    BL,[EDX]
         XOR    EAX,[EDI + EBX * 4]
         INC    EDX
         DEC    ECX
         JNZ    @Start
         POP    EDI
         POP    EBX
@Exit:   RET
         DB 0, 0, 0, 0, 0 // Align Table
@CRC32:  DD 000000000h, 077073096h, 0EE0E612Ch, 0990951BAh
         DD 0076DC419h, 0706AF48Fh, 0E963A535h, 09E6495A3h
         DD 00EDB8832h, 079DCB8A4h, 0E0D5E91Eh, 097D2D988h
         DD 009B64C2Bh, 07EB17CBDh, 0E7B82D07h, 090BF1D91h
         DD 01DB71064h, 06AB020F2h, 0F3B97148h, 084BE41DEh
         DD 01ADAD47Dh, 06DDDE4EBh, 0F4D4B551h, 083D385C7h
         DD 0136C9856h, 0646BA8C0h, 0FD62F97Ah, 08A65C9ECh
         DD 014015C4Fh, 063066CD9h, 0FA0F3D63h, 08D080DF5h
         DD 03B6E20C8h, 04C69105Eh, 0D56041E4h, 0A2677172h
         DD 03C03E4D1h, 04B04D447h, 0D20D85FDh, 0A50AB56Bh
         DD 035B5A8FAh, 042B2986Ch, 0DBBBC9D6h, 0ACBCF940h
         DD 032D86CE3h, 045DF5C75h, 0DCD60DCFh, 0ABD13D59h
         DD 026D930ACh, 051DE003Ah, 0C8D75180h, 0BFD06116h
         DD 021B4F4B5h, 056B3C423h, 0CFBA9599h, 0B8BDA50Fh
         DD 02802B89Eh, 05F058808h, 0C60CD9B2h, 0B10BE924h
         DD 02F6F7C87h, 058684C11h, 0C1611DABh, 0B6662D3Dh
         DD 076DC4190h, 001DB7106h, 098D220BCh, 0EFD5102Ah
         DD 071B18589h, 006B6B51Fh, 09FBFE4A5h, 0E8B8D433h
         DD 07807C9A2h, 00F00F934h, 09609A88Eh, 0E10E9818h
         DD 07F6A0DBBh, 0086D3D2Dh, 091646C97h, 0E6635C01h
         DD 06B6B51F4h, 01C6C6162h, 0856530D8h, 0F262004Eh
         DD 06C0695EDh, 01B01A57Bh, 08208F4C1h, 0F50FC457h
         DD 065B0D9C6h, 012B7E950h, 08BBEB8EAh, 0FCB9887Ch
         DD 062DD1DDFh, 015DA2D49h, 08CD37CF3h, 0FBD44C65h
         DD 04DB26158h, 03AB551CEh, 0A3BC0074h, 0D4BB30E2h
         DD 04ADFA541h, 03DD895D7h, 0A4D1C46Dh, 0D3D6F4FBh
         DD 04369E96Ah, 0346ED9FCh, 0AD678846h, 0DA60B8D0h
         DD 044042D73h, 033031DE5h, 0AA0A4C5Fh, 0DD0D7CC9h
         DD 05005713Ch, 0270241AAh, 0BE0B1010h, 0C90C2086h
         DD 05768B525h, 0206F85B3h, 0B966D409h, 0CE61E49Fh
         DD 05EDEF90Eh, 029D9C998h, 0B0D09822h, 0C7D7A8B4h
         DD 059B33D17h, 02EB40D81h, 0B7BD5C3Bh, 0C0BA6CADh
         DD 0EDB88320h, 09ABFB3B6h, 003B6E20Ch, 074B1D29Ah
         DD 0EAD54739h, 09DD277AFh, 004DB2615h, 073DC1683h
         DD 0E3630B12h, 094643B84h, 00D6D6A3Eh, 07A6A5AA8h
         DD 0E40ECF0Bh, 09309FF9Dh, 00A00AE27h, 07D079EB1h
         DD 0F00F9344h, 08708A3D2h, 01E01F268h, 06906C2FEh
         DD 0F762575Dh, 0806567CBh, 0196C3671h, 06E6B06E7h
         DD 0FED41B76h, 089D32BE0h, 010DA7A5Ah, 067DD4ACCh
         DD 0F9B9DF6Fh, 08EBEEFF9h, 017B7BE43h, 060B08ED5h
         DD 0D6D6A3E8h, 0A1D1937Eh, 038D8C2C4h, 04FDFF252h
         DD 0D1BB67F1h, 0A6BC5767h, 03FB506DDh, 048B2364Bh
         DD 0D80D2BDAh, 0AF0A1B4Ch, 036034AF6h, 041047A60h
         DD 0DF60EFC3h, 0A867DF55h, 0316E8EEFh, 04669BE79h
         DD 0CB61B38Ch, 0BC66831Ah, 0256FD2A0h, 05268E236h
         DD 0CC0C7795h, 0BB0B4703h, 0220216B9h, 05505262Fh
         DD 0C5BA3BBEh, 0B2BD0B28h, 02BB45A92h, 05CB36A04h
         DD 0C2D7FFA7h, 0B5D0CF31h, 02CD99E8Bh, 05BDEAE1Dh
         DD 09B64C2B0h, 0EC63F226h, 0756AA39Ch, 0026D930Ah
         DD 09C0906A9h, 0EB0E363Fh, 072076785h, 005005713h
         DD 095BF4A82h, 0E2B87A14h, 07BB12BAEh, 00CB61B38h
         DD 092D28E9Bh, 0E5D5BE0Dh, 07CDCEFB7h, 00BDBDF21h
         DD 086D3D2D4h, 0F1D4E242h, 068DDB3F8h, 01FDA836Eh
         DD 081BE16CDh, 0F6B9265Bh, 06FB077E1h, 018B74777h
         DD 088085AE6h, 0FF0F6A70h, 066063BCAh, 011010B5Ch
         DD 08F659EFFh, 0F862AE69h, 0616BFFD3h, 0166CCF45h
         DD 0A00AE278h, 0D70DD2EEh, 04E048354h, 03903B3C2h
         DD 0A7672661h, 0D06016F7h, 04969474Dh, 03E6E77DBh
         DD 0AED16A4Ah, 0D9D65ADCh, 040DF0B66h, 037D83BF0h
         DD 0A9BCAE53h, 0DEBB9EC5h, 047B2CF7Fh, 030B5FFE9h
         DD 0BDBDF21Ch, 0CABAC28Ah, 053B39330h, 024B4A3A6h
         DD 0BAD03605h, 0CDD70693h, 054DE5729h, 023D967BFh
         DD 0B3667A2Eh, 0C4614AB8h, 05D681B02h, 02A6F2B94h
         DD 0B40BBE37h, 0C30C8EA1h, 05A05DF1Bh, 02D02EF8Dh
         DD 074726F50h, 0736E6F69h, 0706F4320h, 067697279h
         DD 028207468h, 031202963h, 020393939h, 048207962h
         DD 06E656761h, 064655220h, 06E616D64h, 06FBBA36Eh
end;

end.
