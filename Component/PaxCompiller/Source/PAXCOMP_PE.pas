////////////////////////////////////////////////////////////////////////////
// PaxCompiler
// Site: http://www.paxcompiler.com
// Author: Alexander Baranovsky (paxscript@gmail.com)
// ========================================================================
// Copyright (c) Alexander Baranovsky, 2006-2008. All rights reserved.
// Code Version: 2.4
// ========================================================================
// Unit: PAXCOMP_PE.pas
// ========================================================================
////////////////////////////////////////////////////////////////////////////
{$I PaxCompiler.def}
unit PAXCOMP_PE;
interface
uses
  PAXCOMP_SYS,
  SysUtils,
  Classes,
  PAXCOMP_CONSTANTS,
  PAXCOMP_SYMBOL_PROGRAM,
  PAXCOMP_PROG,
  PaxProgram;
type
  TDosHeader = array[1..128] of Byte;
  TSecName = packed array[0..7] of AnsiChar;
const
  NAME_CODE_SEC: TSecName = ('.', 'c', 'o', 'd', 'e', #0, #0, #0);
  NAME_RDATA_SEC: TSecName = ('.', 'r', 'd', 'a', 't', 'a', #0, #0);
  NAME_DATA_SEC: TSecName = ('.', 'd', 'a', 't', 'a', #0, #0, #0);

  msdos_header: TDosHeader = (
  $4D, $5A, $90, $00, $03, $00, $00, $00, //0
  $04, $00, $00, $00, $FF, $FF, $00, $00, //1
  $B8, $00, $00, $00, $00, $00, $00, $00, //2
  $40, $00, $00, $00, $00, $00, $00, $00, //3
  $00, $00, $00, $00, $00, $00, $00, $00, //4
  $00, $00, $00, $00, $00, $00, $00, $00, //5
  $00, $00, $00, $00, $00, $00, $00, $00, //6
  $00, $00, $00, $00, $80, $00, $00, $00, //7
  $0E, $1F, $BA, $0E, $00, $B4, $09, $CD, //8
  $21, $B8, $01, $4C, $CD, $21, $54, $68, //9
  $69, $73, $20, $70, $72, $6F, $67, $72, //10
  $61, $6D, $20, $63, $61, $6E, $6E, $6F, //11
  $74, $20, $62, $65, $20, $72, $75, $6E, //12
  $20, $69, $6E, $20, $44, $4F, $53, $20, //13
  $6D, $6F, $64, $65, $2E, $0D, $0D, $0A, //14
  $24, $00, $00, $00, $00, $00, $00, $00);//15

  IMAGE_FILE_RELOCS_STRIPPED               = $0001;  { Relocation info stripped from file. }
  IMAGE_FILE_EXECUTABLE_IMAGE              = $0002;  { File is executable  (i.e. no unresolved externel references). }
  IMAGE_FILE_LINE_NUMS_STRIPPED            = $0004;  { Line nunbers stripped from file. }
  IMAGE_FILE_LOCAL_SYMS_STRIPPED           = $0008;  { Local symbols stripped from file. }
  IMAGE_FILE_AGGRESIVE_WS_TRIM             = $0010;  { Agressively trim working set }
  IMAGE_FILE_LARGE_ADDRESS_AWARE           = $0020;  { App can handle >2gb addresses }
  IMAGE_FILE_BYTES_REVERSED_LO             = $0080;  { Bytes of machine word are reversed. }
  IMAGE_FILE_32BIT_MACHINE                 = $0100;  { 32 bit word machine. }
  IMAGE_FILE_DEBUG_STRIPPED                = $0200;  { Debugging info stripped from file in .DBG file }
  IMAGE_FILE_REMOVABLE_RUN_FROM_SWAP       = $0400;  { If Image is on removable media, copy and run from the swap file. }
  IMAGE_FILE_NET_RUN_FROM_SWAP             = $0800;  { If Image is on Net, copy and run from the swap file. }
  IMAGE_FILE_SYSTEM                        = $1000;  { System File. }
  IMAGE_FILE_DLL                           = $2000;  { File is a DLL. }
  IMAGE_FILE_UP_SYSTEM_ONLY                = $4000;  { File should only be run on a UP machine }
  IMAGE_FILE_BYTES_REVERSED_HI             = $8000;  { Bytes of machine word are reversed. }
  IMAGE_FILE_MACHINE_UNKNOWN               = 0;
  IMAGE_FILE_MACHINE_I386                  = $14c;   { Intel 386. }
  IMAGE_FILE_MACHINE_R3000                 = $162;   { MIPS little-endian, 0x160 big-endian }
  IMAGE_FILE_MACHINE_R4000                 = $166;   { MIPS little-endian }
  IMAGE_FILE_MACHINE_R10000                = $168;   { MIPS little-endian }
  IMAGE_FILE_MACHINE_ALPHA                 = $184;   { Alpha_AXP }
  IMAGE_FILE_MACHINE_POWERPC               = $1F0;   { IBM PowerPC Little-Endian }


  IMAGE_DOS_SIGNATURE                     = $5A4D;      { MZ }
  IMAGE_NT_SIGNATURE                      = $00004550;  { PE00 }
  IMAGE_NUMBEROF_DIRECTORY_ENTRIES        = 16;

{ Directory Entries }

  IMAGE_DIRECTORY_ENTRY_EXPORT             = 0;  { Export Directory }
  {$EXTERNALSYM IMAGE_DIRECTORY_ENTRY_EXPORT}
  IMAGE_DIRECTORY_ENTRY_IMPORT             = 1;  { Import Directory }
  {$EXTERNALSYM IMAGE_DIRECTORY_ENTRY_IMPORT}
  IMAGE_DIRECTORY_ENTRY_RESOURCE           = 2;  { Resource Directory }
  {$EXTERNALSYM IMAGE_DIRECTORY_ENTRY_RESOURCE}
  IMAGE_DIRECTORY_ENTRY_EXCEPTION          = 3;  { Exception Directory }
  {$EXTERNALSYM IMAGE_DIRECTORY_ENTRY_EXCEPTION}
  IMAGE_DIRECTORY_ENTRY_SECURITY           = 4;  { Security Directory }
  {$EXTERNALSYM IMAGE_DIRECTORY_ENTRY_SECURITY}
  IMAGE_DIRECTORY_ENTRY_BASERELOC          = 5;  { Base Relocation Table }
  {$EXTERNALSYM IMAGE_DIRECTORY_ENTRY_BASERELOC}
  IMAGE_DIRECTORY_ENTRY_DEBUG              = 6;  { Debug Directory }
  {$EXTERNALSYM IMAGE_DIRECTORY_ENTRY_DEBUG}
  IMAGE_DIRECTORY_ENTRY_COPYRIGHT          = 7;  { Description String }
  {$EXTERNALSYM IMAGE_DIRECTORY_ENTRY_COPYRIGHT}
  IMAGE_DIRECTORY_ENTRY_GLOBALPTR          = 8;  { Machine Value (MIPS GP) }
  {$EXTERNALSYM IMAGE_DIRECTORY_ENTRY_GLOBALPTR}
  IMAGE_DIRECTORY_ENTRY_TLS                = 9;  { TLS Directory }
  {$EXTERNALSYM IMAGE_DIRECTORY_ENTRY_TLS}
  IMAGE_DIRECTORY_ENTRY_LOAD_CONFIG       = 10;  { Load Configuration Directory }
  {$EXTERNALSYM IMAGE_DIRECTORY_ENTRY_LOAD_CONFIG}
  IMAGE_DIRECTORY_ENTRY_BOUND_IMPORT      = 11;  { Bound Import Directory in headers }
  {$EXTERNALSYM IMAGE_DIRECTORY_ENTRY_BOUND_IMPORT}
  IMAGE_DIRECTORY_ENTRY_IAT               = 12;  { Import Address Table }
  {$EXTERNALSYM IMAGE_DIRECTORY_ENTRY_IAT}
  IMAGE_DIRECTORY_ENTRY_DELAY_IMPORT      = 13;  { Delay Load Import Descriptors }
  {$EXTERNALSYM IMAGE_DIRECTORY_ENTRY_DELAY_IMPORT}
  IMAGE_DIRECTORY_ENTRY_COM_DESCRIPTOR    = 14;  { COM Runtime descriptor }
  {$EXTERNALSYM IMAGE_DIRECTORY_ENTRY_COM_DESCRIPTOR}

{ Section header format. }

  IMAGE_SIZEOF_SHORT_NAME                  = 8;

type
  TIMAGE_DATA_DIRECTORY = record
    VirtualAddress: Cardinal;
    Size: Cardinal;
  end;

  TIMAGE_DOS_HEADER = packed record      { DOS .EXE header                  }
      e_magic: Word;                     { Magic number                     }
      e_cblp: Word;                      { Bytes on last page of file       }
      e_cp: Word;                        { Pages in file                    }
      e_crlc: Word;                      { Relocations                      }
      e_cparhdr: Word;                   { Size of header in paragraphs     }
      e_minalloc: Word;                  { Minimum extra paragraphs needed  }
      e_maxalloc: Word;                  { Maximum extra paragraphs needed  }
      e_ss: Word;                        { Initial (relative) SS value      }
      e_sp: Word;                        { Initial SP value                 }
      e_csum: Word;                      { Checksum                         }
      e_ip: Word;                        { Initial IP value                 }
      e_cs: Word;                        { Initial (relative) CS value      }
      e_lfarlc: Word;                    { File address of relocation table }
      e_ovno: Word;                      { Overlay number                   }
      e_res: array [0..3] of Word;       { Reserved words                   }
      e_oemid: Word;                     { OEM identifier (for e_oeminfo)   }
      e_oeminfo: Word;                   { OEM information; e_oemid specific}
      e_res2: array [0..9] of Word;      { Reserved words                   }
      _lfanew: LongInt;                  { File address of new exe header   }
  end; // size of = 64 (dec)

  TIMAGE_FILE_HEADER = packed record
    Machine: Word;
    NumberOfSections: Word;
    TimeDateStamp: Cardinal;
    PointerToSymbolTable: Cardinal;
    NumberOfSymbols: Cardinal;
    SizeOfOptionalHeader: Word;
    Characteristics: Word;
  end; // size of = 20

  TIMAGE_OPTIONAL_HEADER = packed record
    { Standard fields. }
    Magic: Word;
    MajorLinkerVersion: Byte;
    MinorLinkerVersion: Byte;
    SizeOfCode: Cardinal;
    SizeOfInitializedData: Cardinal;
    SizeOfUninitializedData: Cardinal;
    AddressOfEntryPoint: Cardinal;
    BaseOfCode: Cardinal;
    BaseOfData: Cardinal;
    { NT additional fields. }
    ImageBase: Cardinal;
    SectionAlignment: Cardinal;
    FileAlignment: Cardinal;
    MajorOperatingSystemVersion: Word;
    MinorOperatingSystemVersion: Word;
    MajorImageVersion: Word;
    MinorImageVersion: Word;
    MajorSubsystemVersion: Word;
    MinorSubsystemVersion: Word;
    Win32VersionValue: Cardinal;
    SizeOfImage: Cardinal;
    SizeOfHeaders: Cardinal;
    CheckSum: Cardinal;
    Subsystem: Word;
    DllCharacteristics: Word;
    SizeOfStackReserve: Cardinal;
    SizeOfStackCommit: Cardinal;
    SizeOfHeapReserve: Cardinal;
    SizeOfHeapCommit: Cardinal;
    LoaderFlags: Cardinal;
    NumberOfRvaAndSizes: Cardinal;
    DataDirectory: packed array[0..IMAGE_NUMBEROF_DIRECTORY_ENTRIES-1] of TIMAGE_DATA_DIRECTORY;
  end; // size of = 224

  TIMAGE_NT_HEADER = packed record
    Signature: Cardinal;
    FileHeader: TIMAGE_FILE_HEADER;
    OptionalHeader: TIMAGE_OPTIONAL_HEADER;
  end; // size of 248

  TISHMisc = packed record
    case Integer of
      0: (PhysicalAddress: Cardinal);
      1: (VirtualSize: Cardinal);
  end; // size of = 4

  PIMAGE_SECTION_HEADER = ^TIMAGE_SECTION_HEADER;
  TIMAGE_SECTION_HEADER = packed record
    Name: TSecName;
    Misc: TISHMisc;
    VirtualAddress: Cardinal;
    SizeOfRawData: Cardinal;
    PointerToRawData: Cardinal;
    PointerToRelocations: Cardinal;
    PointerToLinenumbers: Cardinal;
    NumberOfRelocations: Word;
    NumberOfLinenumbers: Word;
    Characteristics: Cardinal;
  end; // size of = 40

  TIMAGE_SECTION_HEADER_ARR = array[0..50] of TIMAGE_SECTION_HEADER;

  PIMAGE_IMPORT_DESCRIPTOR = ^TIMAGE_IMPORT_DESCRIPTOR;
  TIMAGE_IMPORT_DESCRIPTOR = packed record
    OriginalFirstThunk: Cardinal;
    TimeDateStamp: Cardinal;
    ForwarderChain: Cardinal;
    Name: Cardinal;
    FirstThunk: Cardinal;
  end;

  TImportProc = class
  public
    ProcName: AnsiString;
    RVA: Cardinal;
  end;

  TImportDll = class
  private
    L: TList;
    function GetRecord(I: Integer): TImportProc;
    function GetCount: Integer;
  public
    DllName: AnsiString;
    RVA: Cardinal;
    constructor Create;
    destructor Destroy; override;
    procedure Clear;
    function Add: TImportProc;
    property Count: Integer read GetCount;
    property Records[I: Integer]: TImportProc read GetRecord; default;
  end;

  TImportDllList = class
  private
    L: TList;
    function GetRecord(I: Integer): TImportDll;
    function GetCount: Integer;
    function GetProcCount: Integer;
  public
    constructor Create;
    destructor Destroy; override;
    procedure Clear;
    function Add: TImportDll;
    function FindDll(const DllName: String): TImportDll;
    property Count: Integer read GetCount;
    property ProcCount: Integer read GetProcCount;
    property Records[I: Integer]: TImportDll read GetRecord; default;
  end;

  TImportTable = class
  public
    ImportDllList: TImportDllList;

    IAT_RVA1, IAT_RVA2: Cardinal;
    IAT_SIZE: Cardinal;
    IMAGE_IMPORT_DESCRIPTOR_RVA: Cardinal;
    IMAGE_IMPORT_DESCRIPTOR_SIZE: Cardinal;
    RVA_STRINGS: Cardinal;
    IAT: array of Cardinal;
    IMAGE_IMPORT_DESCRIPTOR_ARR: array of TIMAGE_IMPORT_DESCRIPTOR;

    constructor Create;
    destructor Destroy; override;
    function AddDll(const DllName: String): TImportDll;
    procedure AddProc(const DllName, ProcName: String);
    procedure Calc(IAT_RVA: Integer);
    procedure SaveToStream(F: TStream);
  end;

procedure CreateExe(const FileName: String;
                    T: TImportTable;
                    P: TProgram;
                    PaxProgram: TPaxProgram);

const
  MAX_STRING = $20;
function IsPEFile(const FileName: String): Boolean;
function GetRawOffset(vsm: Cardinal; // virtual address
                      P: PIMAGE_SECTION_HEADER; // P is pointer to first section
                      N: Cardinal // NumberOfSections
                      ): Cardinal;

implementation

function Align(L, Size: Integer): Integer;
begin
  if L < Size then
    result := Size
  else
  begin
    if L mod Size = 0 then
      result := (L div Size) * Size
    else
      result := (L div Size + 1) * Size;
  end;
end;

constructor TImportDll.Create;
begin
  inherited;
  L := TList.Create;
end;

destructor TImportDll.Destroy;
begin
  Clear;
  L.Free;
  inherited;
end;

function TImportDll.Add: TImportProc;
begin
  result := TImportProc.Create;
  L.Add(result);
end;

function TImportDll.GetRecord(I: Integer): TImportProc;
begin
  result := TImportProc(L[I]);
end;

function TImportDll.GetCount: Integer;
begin
  result := L.Count;
end;

procedure TImportDll.Clear;
var
  I: Integer;
begin
  for I:=0 to Count - 1 do
    Records[I].Free;
  L.Clear;
end;

constructor TImportDllList.Create;
begin
  L := TList.Create;
end;

destructor TImportDllList.Destroy;
begin
  Clear;
  L.Free;
end;

function TImportDllList.Add: TImportDll;
begin
  result := TImportDll.Create;
  L.Add(result);
end;

procedure TImportDllList.Clear;
var
  I: Integer;
begin
  for I:=0 to Count - 1 do
    Records[I].Free;
  L.Clear;
end;

function TImportDllList.GetRecord(I: Integer): TImportDll;
begin
  result := TImportDll(L[I]);
end;

function TImportDllList.FindDll(const DllName: String): TImportDll;
var
  I: Integer;
begin
  result := nil;
  for I:=0 to Count - 1 do
    if StrEql(String(Records[I].DllName), DllName) then
    begin
      result := Records[I];
      Exit;
    end;
end;

function TImportDllList.GetCount: Integer;
begin
  result := L.Count;
end;

function TImportDllList.GetProcCount: Integer;
var
  I: Integer;
begin
  result := 0;
  for I:=0 to Count - 1 do
    Inc(result, Records[I].Count);
end;

constructor TImportTable.Create;
begin
  inherited;
  ImportDllList := TImportDllList.Create;
end;

destructor TImportTable.Destroy;
begin
  ImportDllList.Free;
  inherited;
end;

function TImportTable.AddDll(const DllName: String): TImportDll;
begin
  result := ImportDllList.FindDll(DllName);
  if result = nil then
  begin
    result := ImportDllList.Add;
    result.DllName := AnsiString(DllName);
  end;
end;

procedure TImportTable.AddProc(const DllName, ProcName: String);
var
  Dll: TImportDll;
  Proc: TImportProc;
begin
  Dll := ImportDllList.FindDll(DllName);
  if Dll = nil then
    Dll := AddDll(DllName);
  Proc := Dll.Add;
  Proc.ProcName := AnsiString(ProcName);
end;

procedure TImportTable.Calc(IAT_RVA: Integer);
var
  I, J, ProcCount, RVA_STR: Cardinal;
  K: Integer;
begin
  // first IAT
  // second IAT
  // IMAGE_IMPORT_DESCRIPTOR_ARR
  // strings

  IAT_RVA1 := IAT_RVA;
  SetLength(IAT, ImportDllList.ProcCount + ImportDllList.Count);
  SetLength(IMAGE_IMPORT_DESCRIPTOR_ARR, ImportDllList.Count + 1);

  K := -1;

  IAT_SIZE := Length(IAT) * SizeOf(Cardinal);
  IAT_RVA2 := IAT_RVA1 + IAT_SIZE;
  IMAGE_IMPORT_DESCRIPTOR_RVA := IAT_RVA2 + IAT_SIZE;
  IMAGE_IMPORT_DESCRIPTOR_SIZE := SizeOf(TIMAGE_IMPORT_DESCRIPTOR) * (ImportDllList.Count + 1);
  RVA_STRINGS := IMAGE_IMPORT_DESCRIPTOR_RVA + IMAGE_IMPORT_DESCRIPTOR_SIZE;

  RVA_STR := RVA_STRINGS;

  for I := 0 to ImportDllList.Count - 1 do
  begin
    ProcCount := ImportDllList[I].Count;

    ImportDllList[I].RVA := RVA_STR; // rva of dll name

    IMAGE_IMPORT_DESCRIPTOR_ARR[I].Name := RVA_STR;
    IMAGE_IMPORT_DESCRIPTOR_ARR[I].TimeDateStamp := 0;
    IMAGE_IMPORT_DESCRIPTOR_ARR[I].ForwarderChain := 0;
    IMAGE_IMPORT_DESCRIPTOR_ARR[I].FirstThunk :=
      IAT_RVA1 + I * (ProcCount + 1) * SizeOf(Cardinal);

    IMAGE_IMPORT_DESCRIPTOR_ARR[I].OriginalFirstThunk :=
      IAT_RVA2 + I * (ProcCount + 1) * SizeOf(Cardinal);

    Inc(RVA_STR, MAX_STRING); // max AnsiString length is 32
    for J := 0 to ProcCount - 1 do
    begin
      ImportDllList[I][J].RVA := RVA_STR;
      Inc(K);
      IAT[K] := RVA_STR;
      
      Inc(RVA_STR, MAX_STRING);
    end;
    
    Inc(K);
    IAT[K] := 0;
  end;
end;

procedure TImportTable.SaveToStream(F: TStream);
var
  I, J: Cardinal;
  STR_BUFF: array[1..32] of AnsiChar;
begin
  for I:= 0 to Length(IAT) - 1 do
    F.Write(IAT[I], SizeOf(Cardinal));

  for I:= 0 to Length(IAT) - 1 do
    F.Write(IAT[I], SizeOf(Cardinal));

  for I := 0 to ImportDllList.Count do
    F.Write(IMAGE_IMPORT_DESCRIPTOR_ARR[I], SizeOf(TIMAGE_IMPORT_DESCRIPTOR));

  for I := 0 to ImportDllList.Count - 1 do
  begin
    FillChar(STR_BUFF, SizeOf(STR_BUFF), 0);
    Move(ImportDllList[I].DllName[1], STR_BUFF[1], Length(ImportDllList[I].DllName));
    F.Write(STR_BUFF, SizeOf(STR_BUFF));

    for J := 0 to ImportDllList[I].Count - 1 do
    begin
      FillChar(STR_BUFF, SizeOf(STR_BUFF), 0);
      Move(ImportDllList[I][J].ProcName[1], STR_BUFF[3], Length(ImportDllList[I][J].ProcName));
      F.Write(STR_BUFF, SizeOf(STR_BUFF));
    end;
  end;
end;

function _Floor(X: Extended): Int64;
begin
  result := Trunc(X);
  if Frac(X) < 0 then
    Dec(result);
end;

function DelphiDateTimeToEcmaTime(const AValue: TDateTime): Int64;
var
  T: TTimeStamp;
  D1970: TDateTime;
begin
  D1970 := EncodeDate(1970,1,1);

  T := DateTimeToTimeStamp(AValue);
  Result := (_Floor(AValue) - _Floor(D1970)) * MSecsPerDay + T.Time;
end;

function FileDate: Integer;
begin
  result := DelphiDateTimeToEcmaTime(Now);
end;


function GetRawOffset(vsm: Cardinal; // virtual address
                      P: PIMAGE_SECTION_HEADER; // P is pointer to first section
                      N: Cardinal // NumberOfSections
                      ): Cardinal;
var
  I: Integer;
  PrevP: PIMAGE_SECTION_HEADER;
begin
  if vsm < P^.VirtualAddress then
  begin
    result := 0;
    Exit;
  end;

  PrevP := P;
  Inc(P);

  for I:=1 to N - 1 do
  begin
    if vsm < P.VirtualAddress then
    begin
      result := vsm - PrevP.VirtualAddress + PrevP.PointerToRawData;

      Exit;
    end;

    PrevP := P;
    Inc(P);
  end;

  result := vsm - PrevP.VirtualAddress + PrevP.PointerToRawData;
end;

function IsPEFile(const FileName: String): Boolean;
var
  F: TFileStream;
  DOS: TIMAGE_DOS_HEADER;
  NT: TIMAGE_NT_HEADER;
begin
  if not FileExists(FileName) then
  begin
    result := false;
    Exit;
  end;

  F := TFileStream.Create(FileName, fmOpenRead);
  try
    F.Read(DOS, SizeOf(TIMAGE_DOS_HEADER));

    if DOS.e_magic <> IMAGE_DOS_SIGNATURE then
    begin
      result := false;
      Exit;
    end;

    if F.Size < DOS._lfanew + SizeOf(TIMAGE_NT_HEADER) then
    begin
      result := false;
      Exit;
    end;

    F.Position := DOS._lfanew;
    F.Read(NT, SizeOf(TIMAGE_NT_HEADER));
    if NT.Signature = IMAGE_NT_SIGNATURE then
      result := true
    else
      result := false;

  finally
    F.Free;
  end;
end;

procedure CreateExe(const FileName: String;
                    T: TImportTable;
                    P: TProgram;
                    PaxProgram: TPaxProgram);

const
  FileAlignment = $200;
  SectionAlignment = $1000;
  AddressOfEntryPoint = SectionAlignment;
  BaseOfCode = AddressOfEntryPoint;
  ImageBase = $400000;

var
  F: TFileStream;
  DOS: TDosHeader;
  NT: TIMAGE_NT_HEADER;
  SEC_CODE, SEC_RDATA, SEC_DATA: TIMAGE_SECTION_HEADER;

  B: Byte;

  section_code_size: Integer;
  psection_code: Pointer;
  section_code_count: Cardinal;

  section_rdata_size: Integer;
  section_rdata_count: Cardinal;

  section_data_size: Integer;
  psection_data: Pointer;
//  section_data_count: Integer;

  BaseOfData: Integer;
begin
  B := 0;

  // .code

  section_code_size := FileAlignment;
  psection_code := AllocMem(section_code_size);
  section_code_count := section_code_size div FileAlignment;

  BaseOfData := SectionAlignment +
                SectionAlignment * section_code_count;
                
  // .rdata

  section_rdata_size := FileAlignment;
  section_rdata_count := section_rdata_size div FileAlignment;

  T.Calc(BaseOfData);
//  T.Dump('import_table.txt');

  // .data

  if PaxProgram <> nil then
  begin
    section_data_size := Align(PaxProgram.GetImageSize, FileAlignment);
    psection_data := AllocMem(section_data_size);
    PaxProgram.SaveToBuff(psection_data^);
  end
  else
  begin
    section_data_size := FileAlignment;
    psection_data := AllocMem(section_data_size);
  end;
// section_data_count := section_data_size div FileAlignment;

  DOS := msdos_header;

  FillChar(NT, SizeOf(NT), 0);

  F := TFileStream.Create(FileName, fmCreate);
  try
    F.Write(DOS, SizeOf(DOS));

    NT.Signature := IMAGE_NT_SIGNATURE;

    NT.FileHeader.Machine := $014C;
    NT.FileHeader.NumberOfSections := 3;
    NT.FileHeader.TimeDateStamp := 0; ///// ?????????????????
    NT.FileHeader.PointerToSymbolTable := 0;
    NT.FileHeader.NumberOfSymbols := 0;
    NT.FileHeader.SizeOfOptionalHeader := SizeOf(TIMAGE_OPTIONAL_HEADER);
    NT.FileHeader.Characteristics := $010F;

    NT.OptionalHeader.Magic := $010B;
    NT.OptionalHeader.MajorLinkerVersion := 4;
    NT.OptionalHeader.MinorLinkerVersion := 0;
    NT.OptionalHeader.SizeOfCode := section_code_size;
    NT.OptionalHeader.SizeOfInitializedData := section_rdata_size +
                                               section_data_size;
    NT.OptionalHeader.SizeOfUninitializedData := 0;
    NT.OptionalHeader.AddressOfEntryPoint := AddressOfEntryPoint;
    NT.OptionalHeader.BaseOfCode := BaseOfCode; // $1000 (RVA)
    NT.OptionalHeader.BaseOfData := BaseOfData; // $2000 (RVA)
    NT.OptionalHeader.ImageBase := ImageBase;
    NT.OptionalHeader.SectionAlignment := SectionAlignment; //$1000
    NT.OptionalHeader.FileAlignment := FileAlignment; //$200
    NT.OptionalHeader.MajorOperatingSystemVersion := 4;
    NT.OptionalHeader.MinorOperatingSystemVersion := 0;
    NT.OptionalHeader.MajorImageVersion := 0;
    NT.OptionalHeader.MinorImageVersion := 0;
    NT.OptionalHeader.MajorSubsystemVersion := 4;
    NT.OptionalHeader.MinorSubsystemVersion := 0;
    NT.OptionalHeader.Win32VersionValue := 0;
    NT.OptionalHeader.SizeOfImage :=
         $3000 +
         section_data_size;
//      SectionAlignment * (NT.FileHeader.NumberOfSections + 1);
    NT.OptionalHeader.SizeOfHeaders := $400; // ??????
    NT.OptionalHeader.CheckSum := 0;

    if PaxProgram.Console then
      NT.OptionalHeader.Subsystem := 3 // console app
    else
      NT.OptionalHeader.Subsystem := 2; // gui app

    NT.OptionalHeader.DllCharacteristics := 0; // is not used
    NT.OptionalHeader.SizeOfStackReserve := $100000;
    NT.OptionalHeader.SizeOfStackCommit := $1000;
    NT.OptionalHeader.SizeOfHeapReserve := $100000;
    NT.OptionalHeader.SizeOfHeapCommit := $1000;
    NT.OptionalHeader.LoaderFlags := 0; // is not used
    NT.OptionalHeader.NumberOfRvaAndSizes := $10;

    NT.OptionalHeader.DataDirectory[IMAGE_DIRECTORY_ENTRY_IMPORT].VirtualAddress := T.IMAGE_IMPORT_DESCRIPTOR_RVA;
    NT.OptionalHeader.DataDirectory[IMAGE_DIRECTORY_ENTRY_IMPORT].Size := T.IMAGE_IMPORT_DESCRIPTOR_SIZE;
    NT.OptionalHeader.DataDirectory[IMAGE_DIRECTORY_ENTRY_IAT].VirtualAddress := T.IAT_RVA1;
    NT.OptionalHeader.DataDirectory[IMAGE_DIRECTORY_ENTRY_IAT].Size := T.IAT_SIZE;

    F.Write(NT, SizeOf(NT));

    FillChar(SEC_CODE, SizeOf(SEC_CODE), 0);
    SEC_CODE.Name := NAME_CODE_SEC;
    SEC_CODE.Misc.VirtualSize := section_code_size;
    SEC_CODE.VirtualAddress := SectionAlignment; //$1000
    SEC_CODE.SizeOfRawData := section_code_size;
    SEC_CODE.PointerToRawData := FileAlignment + FileAlignment; //$400
    SEC_CODE.PointerToRelocations := 0;
    SEC_CODE.PointerToLinenumbers := 0;
    SEC_CODE.NumberOfRelocations := 0;
    SEC_CODE.NumberOfLinenumbers := 0;
    SEC_CODE.Characteristics := $60000020;
    //Section contains executable code, Section can be executed as code, Section can be read
    F.Write(SEC_CODE, SizeOf(SEC_CODE));

    FillChar(SEC_RDATA, SizeOf(SEC_RDATA), 0);
    SEC_RDATA.Name := NAME_RDATA_SEC;
    SEC_RDATA.Misc.VirtualSize := section_rdata_size;
    SEC_RDATA.VirtualAddress := SEC_CODE.VirtualAddress +
                  SectionAlignment * section_code_count; //$2000
    SEC_RDATA.SizeOfRawData := section_rdata_size;
    SEC_RDATA.PointerToRawData := SEC_CODE.PointerToRawData +
                  FileAlignment * section_code_count;
    SEC_RDATA.PointerToRelocations := 0;
    SEC_RDATA.PointerToLinenumbers := 0;
    SEC_RDATA.NumberOfRelocations := 0;
    SEC_RDATA.NumberOfLinenumbers := 0;
    SEC_RDATA.Characteristics := $40000040;
    // Section contains initialized data, Section can be read, Section can be written to
    F.Write(SEC_RDATA, SizeOf(SEC_RDATA));

    FillChar(SEC_DATA, SizeOf(SEC_DATA), 0);
    SEC_DATA.Name := NAME_DATA_SEC;
    SEC_DATA.Misc.VirtualSize := section_data_size;
    SEC_DATA.VirtualAddress := SEC_RDATA.VirtualAddress +
                  SectionAlignment * section_rdata_count; //$3000
    SEC_DATA.SizeOfRawData := section_data_size;
    SEC_DATA.PointerToRawData := SEC_RDATA.PointerToRawData +
                  FileAlignment * section_rdata_count;
    SEC_DATA.PointerToRelocations := 0;
    SEC_DATA.PointerToLinenumbers := 0;
    SEC_DATA.NumberOfRelocations := 0;
    SEC_DATA.NumberOfLinenumbers := 0;
    SEC_DATA.Characteristics := $c0000040;
    // Section contains initialized data, Section can be read, Section can be written to
    F.Write(SEC_DATA, SizeOf(SEC_DATA));

    // end of section table

    // .code

    while F.Position < Integer(SEC_CODE.PointerToRawData) do
      F.Write(B, 1);

    Move(P.CodePtr^, psection_code^, P.CodeSize);
    F.Write(psection_code^, section_code_size);

    // .rdata

    while F.Position < Integer(SEC_RDATA.PointerToRawData) do
      F.Write(B, 1);
    T.SaveToStream(F);

    // .data

    while F.Position < Integer(SEC_DATA.PointerToRawData) do
      F.Write(B, 1);

    F.Write(psection_data^, section_data_size);
  finally
    FreeMem(psection_code, section_code_size);
    FreeMem(psection_data, section_data_size);
    F.Free;
  end;
end;

end.

