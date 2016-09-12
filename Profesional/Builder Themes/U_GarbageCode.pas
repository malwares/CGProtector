unit U_GarbageCode;

interface
uses
windows,sysutils;

Function SimpleGarbage:string;
Function Garbage:string;
Function RandomFunc(const temp:array of string):string;
implementation

const
garbageapi:Array [0..27] of string =
(
'loadlibrary('''');','loadlibraryW('''');','GetModuleHandleA('''');','GetModuleHandleW('''');',
'freelibrary(0);','messagebox(thandle(-1),nil,nil,0);','lstrcmpW(nil,nil);',
'lstrcmpA(nil,nil);','lstrcmpiA(nil,nil);','lstrcmpiW(nil,nil);','lstrcpynA(nil,nil,0);',
'lstrcpynW(nil,nil,0);','lstrcpyW(nil,nil);','lstrcpyA(nil,nil);','lstrcatA(nil,nil);',
'lstrcatW(nil,nil);','lstrlenA(nil);','lstrlenW(nil);','SleepEx(0,false);',
'Sleep(0);','GetModuleFileNameA(thandle(-1),nil,0);','GetModuleFileNameW(thandle(-1),nil,0);',
'GetProcessVersion(0);','GetEnvironmentVariableA(nil,nil,0);','GetEnvironmentVariableW(nil,nil,0);',
'FindResourceA(thandle(-1),nil,nil);','FindResourceW(thandle(-1),nil,nil);','GetTickCount;'
);

const
garbageasm:Array [0..44] of string =
(
'MOV EBX, ESP SUB EBX, 4 MOV ESP, EBX MOV [ESP], EAX  INC [ESP]',
'PUSH EAX PUSH ECX MOV EAX, [EAX].offset Default8087CW FLDCW [EAX] POP ECX POP EAX',
'TEST EAX,EAX JE @@1 SUB EAX, $1000 @@1:',
'LEA ESI,[ESI + 8] PUSH EDI PUSH ESI SUB EBX,[ESI + 0]',
'SUB ESP,8 FISTP QWORD PTR [ESP] LEA ESI,[ESI + 8] PUSH EDI PUSH ESI SUB EBX,[ESI + 0]',
'PUSH EDI PUSH ESI PUSH EBX MOV ESI,EAX MOV EDI,EDX',
'INC ESI IMUL EDX,10 ADD EDX,EAX CMP EDX,500',
'MOV AL,0DFH MOV AL,0DFH MOV AL,0DFH MOV AL,0DFH MOV AL,0DFH MOV AL,0DFH MOV AL,0DFH',
'DD 10 DD 100 DD 1000 DD 10000',
'BSWAP EBX BSWAP EBP BSWAP EBX BSWAP EBP BSWAP EBX BSWAP EBP BSWAP EBX BSWAP EBP',
'MOVZX  ECX,BH MOV ECX,[ESI + ECX * 4 + 1024 * 0] MOV EBX,[ESI + EBX * 4 + 1024 * 1]',
'MOVZX ECX,AL ADD EBX,ECX INC EDI TEST EDI,010h MOV EBP,EAX',
'LEA EBX,[EBX + EDX] DEC EDI MOV EBP,EAX BSWAP EBX MOV [EAX + 4],EBX',
'MOV EAX,[EDX + 0] MOV EBX,[EDX + 4] MOV EDI,[EDX + 8] IMUL ECX,EDX',
'ADD EDI,[ESI + 4] DEC EBP MOV EDX,ECX LEA ESI,[ESI + 8]',
'LEA ESI,[ESI - 8] SUB EBX,[ESI + 0] SUB EBX,[ESI + 4] MOV [ECX + 12],EDX',
'MOV [EAX +  0],ESI  ADD EAX,[EDI +  8] MOV EAX,ECX SUB EDI,16',
'PUSHAD DW 0310Fh ADC EDX,0 ADD EAX,5000',
'PUSH EAX PUSH EAX PUSH EAX PUSH EAX PUSH EAX PUSH EAX PUSH EAX ',
'LEA EBX,[EBX + EDX] LEA EBX,[EBX + EDX] LEA EBX,[EBX + EDX]',
'FISTP QWORD PTR [ESP] FISTP QWORD PTR [ESP] FISTP QWORD PTR [ESP]',
'TEST EAX,EAX JE @@1 SUB EAX, $1000 @@2: TEST EAX,EAX JE @@2 SUB EAX, $1000 @@1:',
'DD 10 DD 100 DD 1000 DD 10 DD 100 DD 1000 DD 10 DD 100 DD 1000 DD 10 DD 100 DD 1000',
'BSWAP EBX BSWAP EBP BSWAP EBX BSWAP EBP BSWAP EBX BSWAP EBP BSWAP EBX BSWAP EBP',
'DEC EDI MOV EBP,EAX DEC EDI MOV EBP,EAX',
'MOV EDI,[EDX + 8] IMUL ECX,EDX MOV EDI,[EDX + 8] IMUL ECX,EDX',
'MOVZX  ECX,BH MOV ECX,[ESI + ECX * 4 + 1024 * 0]',
'INC ESI IMUL EDX,10 BSWAP EBX BSWAP EBP',
'FISTP QWORD PTR [ESP] IMUL EDX,10 FISTP QWORD PTR [ESP]',
'TEST EAX,EAX JE @@1 SUB EAX, $1000 @@1: IMUL ECX,EDX',
'PUSH EAX ADC EDX,0 TEST EAX,EAX SUB EAX, $1000',
'fistp qword ptr [edx + 32] fild qword ptr [eax + 16]',
'neg ecx db $0f, $6f, $04, $01 movq mm0, [eax + ecx]',
'movq mm0, [eax + ecx] movq [edx + ecx], mm0 add ecx, 16',
'fild qword ptr [eax + ecx] fistp qword ptr [edx + ecx]',
'lea eax, [edx * 4 + edx] cmp ecx, 1 sbb edi, -1',
'lea eax, [edx * 4 + edx] movzx eax, ch sbb edi, -1',
'mov ecx, dword ptr [4 + eax * 4] bsf ecx, ecx',
'bsf ecx, ecx cmp edi, edx test eax, eax',
'pop edx call Sleep pop ecx',
'pop esi pop ebx ret',
'xor eax, eax sub ecx, edx adc eax, -1',
'BSWAP EBX',
'PUSH EAX ADC EDX,0',
'mov eax, ecx sub eax, edx adc edi, -1 sub eax, edx'
);

const
    Calculator: array[0..4] of string = (
        ' + ', ' - ', ' * ', ' div ', ' mod '
    );

function GenerateNumber(count:Integer) :string;
const
  Chars = '123456789';
var
  S: string;
  i, N: integer;
begin
  Randomize;
  S := '';
  for i := 1 to count do begin
    N := Random(Length(Chars)) + 1;
    S := S + Chars[N];
  end;
  result := S;
end;

function garbagecalculator:string;
var
x : byte;
temp : string;
begin
  temp := '('+GenerateNumber(2);
  for x := 0 to 3 do
  begin
    Randomize;
    temp := temp + Calculator[random(5)] + GenerateNumber(2);
  end;
  temp := temp + ')';
  result := 'if '+temp+' <> '+temp+' then sleep(0);';
end;

Function SimpleGarbage:string;
var
i : byte;
begin
  result := '';
  randomize;
  i := random(3);
  case i of
    0 :
    begin
      result := 'if 2 = 3 then begin '+garbagecalculator+' end;'+#13#10
    end;
    1 :
    begin
      randomize;
      result := 'if 2 = 3 then asm '+garbageasm[random(45)]+' end;'+#13#10
    end;
  end;
end;

Function Garbage:string;
var
i : byte;
begin
  result := '';
  randomize;
  i := random(4);
  case i of
    0 :
    begin
      result := 'if 2 = 3 then begin '+garbagecalculator+' end;'+#13#10
    end;
    1 :
    begin
      randomize;
      result := 'if 2 = 3 then asm '+garbageasm[random(45)]+' end;'+#13#10
    end;
    2 :
    begin
      randomize;
      result :=  garbageapi[random(28)]+#13#10;
    end;
  end;
end;

procedure Shuffle(var Elements: array of integer);
var i, j: integer; temp: integer;
begin
  randomize;
  for i := (length(Elements) - 1) downto 1 do
  begin
    j := Random(i+1);
    temp := Elements[i];
    Elements[i] := Elements[j];
    Elements[j] := temp
  end;
end;

Function RandomFunc(const temp:array of string):string;
var
item : array of integer;
i : integer;
begin
  setlength(item,length(temp));
  for i := 0 to length(item)-1 do item[i] := i;
  Shuffle(item);
  for i := 0 to length(item)-1 do result := result+ temp[item[i]];
end;

end.

