unit U_PEUtils;

interface
uses
windows,sysutils,classes;

const
  UE_ACCESS_READ = 0;
  UE_ACCESS_WRITE = 1;
  UE_ACCESS_ALL = 2;

type
  TAImageSectionHeaders = packed array [0..maxInt shr 6] of TImageSectionHeader;
  TPAImageSectionHeaders = ^TAImageSectionHeaders;
  TAImageDataDirectories = packed array[0..IMAGE_NUMBEROF_DIRECTORY_ENTRIES-1] of TImageDataDirectory;
  TPImageDataDirectories = ^TAImageDataDirectories;

  THeader = record
    NtHeader : PImageNtHeaders;
    SOffset : DWord;
    DataDirectoryEntries :TPImageDataDirectories;
    SectionHeaders : TPAImageSectionHeaders;
  end;

function EngineCloseHandle(myHandle :thandle): boolean;
function MapFileEx(fName:string; dwReadOrWrite: LongInt; dwFileHWND,dwFileSize,dwFileMap,dwFileMapVA:Pointer;SizeModifier :dword):boolean;
procedure UnmapFileEx(dwFileHWND,dwFileSize,dwFileMap:Cardinal;pVal : Pointer);
function IsValidBlockAddr(Address, Size: DWord): Boolean;
function Align(dwValue:DWORD; dwAlign:DWORD):DWORD;
Function GetHeaderEx(Buffer:Pointer):PImageNtHeaders;
Function GetHeader(Buffer:Pointer;var Header:THeader):Boolean;
function AddSection(szFileName:string;szSectionName:ansistring; SectionSize,SectionAttributes:LongInt; SectionContent:Pointer; ContentSize:LongInt):LongInt;
function StripRelocationTable(Const szFilename: String): Boolean;
function RealignFile(Const szFilename: String): Boolean;
function ReChecksum(const szFilename:string):boolean;
Function AddEof(Source,Target: String): Boolean;
implementation

const
{PE CONST}
  IMAGE_NT_SIGNATURE_LENGHT = 4;
  P64_AND_PE32_SIZE_DIFFERENCE = 16;
  IMAGE_NT_HEADER_OFFSET_OFFSET = $3c;

function EngineCloseHandle(myHandle :thandle): boolean;
var
HandleFlags : dword;
begin
  if GetHandleInformation(myHandle,HandleFlags) then
    if closehandle(myHandle) then result := true
    else
      result := false
  else
    result := false;
end;

function MapFileEx(fName:string; dwReadOrWrite: LongInt; dwFileHWND,dwFileSize,dwFileMap,dwFileMapVA:Pointer;SizeModifier :dword):boolean;
var
hFile : Thandle;
mfFileMap : Thandle;
FileAccess : Dword;
FileMapType : Dword;
FileMapViewType : Dword;
mfFileSize : Dword;
mfFileMapVA :Pointer;
begin
  result := false;
  hFile := 0;
  mfFileMap := 0;
  mfFileMapVA := nil;
  mfFileSize := 0;
  if (dwReadOrWrite = UE_ACCESS_READ) then
  begin
    FileAccess := GENERIC_READ;
    FileMapType := PAGE_READONLY;
    FileMapViewType := FILE_MAP_READ;
  end else
  if (dwReadOrWrite = UE_ACCESS_WRITE) then
  begin
    FileAccess := GENERIC_WRITE;
    FileMapType := PAGE_READWRITE;
    FileMapViewType := FILE_MAP_WRITE;
  end else
  if (dwReadOrWrite = UE_ACCESS_ALL) then
  begin
    FileAccess := GENERIC_READ+GENERIC_WRITE+GENERIC_EXECUTE;
    FileMapType := PAGE_EXECUTE_READWRITE;
    FileMapViewType := FILE_MAP_WRITE;
  end else
  begin
    FileAccess := GENERIC_READ+GENERIC_WRITE+GENERIC_EXECUTE;
    FileMapType := PAGE_EXECUTE_READWRITE;
    FileMapViewType := FILE_MAP_ALL_ACCESS;
  end;
  hFile := CreateFile(pchar(fName), FileAccess, FILE_SHARE_READ, nil, OPEN_EXISTING, FILE_ATTRIBUTE_NORMAL, 0);
  if hFile <> INVALID_HANDLE_VALUE then
  begin
    asm
      PUSHAD
      MOV EAX,hFile
      MOV EBX,dwFileHWND
      MOV DWORD PTR[EBX],EAX
      POPAD
    end;
    mfFileSize := GetFileSize(hFile,nil);
    mfFileSize := mfFileSize + SizeModifier;
    asm
      PUSHAD
      MOV EAX,mfFileSize
      MOV EBX,dwFileSize
      MOV DWORD PTR[EBX],EAX
      POPAD
    end;
    mfFileMap := CreateFileMapping(hFile, nil, FileMapType, 0, mfFileSize, nil);
    if mfFileMap <> 0  then
    begin
      asm
        PUSHAD
        MOV EAX,mfFileMap
        MOV EBX,dwFileMap
        MOV DWORD PTR[EBX],EAX
        POPAD
      end;
      mfFileMapVA := MapViewOfFile(mfFileMap, FileMapViewType, 0, 0, 0);
      if mfFileMapVA <> nil then
      begin
        asm
          PUSHAD
          MOV EAX,mfFileMapVA
          MOV EBX,dwFileMapVA
          MOV DWORD PTR[EBX],EAX
          POPAD
        end;
        result := true;
      end;
    end;
    EngineCloseHandle(hFile);
  end else
  result := false;
end;

procedure UnmapFileEx(dwFileHWND,dwFileSize,dwFileMap:Cardinal;pVal : Pointer);
begin
 if UnmapViewOfFile(pVal) then
 begin
  EngineCloseHandle(dwFileMap);
  SetFilePointer(dwFileHWND, dwFileSize, nil, FILE_BEGIN);
  SetEndOfFile(dwFileHWND);
  EngineCloseHandle(dwFileHWND);
 end;
end;

function GetReadableSize(Address, Size: DWord): DWord;
const
  ReadAttributes = [PAGE_READONLY, PAGE_READWRITE, PAGE_WRITECOPY, PAGE_EXECUTE,
    PAGE_EXECUTE_READ, PAGE_EXECUTE_READWRITE, PAGE_EXECUTE_WRITECOPY];
var
  MemInfo: TMemoryBasicInformation;
  Tmp: DWord;
begin
  Result := 0;
  if (VirtualQuery(Pointer(Address), MemInfo, SizeOf(MemInfo)) = SizeOf(MemInfo)) and
    (MemInfo.State = MEM_COMMIT) and (MemInfo.Protect in ReadAttributes) then
  begin
    Result := (MemInfo.RegionSize - (Address - DWord(MemInfo.BaseAddress)));
    if (Result < Size) then
    begin
      repeat
        Tmp := GetReadableSize((DWord(MemInfo.BaseAddress) + MemInfo.RegionSize), (Size - Result));
        if (Tmp > 0) then Inc(Result, Tmp)
        else Result := 0;
      until (Result >= Size) or (Tmp = 0);
    end;
  end;
end;

function IsValidBlockAddr(Address, Size: DWord): Boolean;
begin
  Result := (GetReadableSize(Address, Size) >= Size);
end;

function Align(dwValue:DWORD; dwAlign:DWORD):DWORD;
begin
  if dwAlign <> 0 then
  begin
    if dwValue mod dwAlign <> 0 then
    begin
      Result := (dwValue + dwAlign) - (dwValue mod dwAlign);
      Exit;
    end;
  end;
  Result := dwValue;
end;

Function GetHeader(Buffer:Pointer;var Header:THeader):Boolean;
var
SectionHeadersOffset: DWord;
begin
  Result := False;
  // Set NT Header, validate file against DOS and NT signatures
  try
    if (IsValidBlockAddr(DWord(Buffer), 2)) and
      (PWord(Buffer)^ = IMAGE_DOS_SIGNATURE) then
    begin
      Header.NtHeader := (Pointer(DWord(Buffer) +
        DWord(Pointer(DWord(Buffer) + IMAGE_NT_HEADER_OFFSET_OFFSET)^)));
      if (not IsValidBlockAddr(DWord(Header.NtHeader), 4) or
        (Header.NtHeader^.signature <> IMAGE_NT_SIGNATURE)) then Header.NtHeader := nil;
    end;
  Except
    Header.NtHeader := nil;
  end;

  if (Header.NtHeader <> nil) then
  begin
    // Set section headers and data directories
    SectionHeadersOffset := (DWord(Header.NtHeader) + IMAGE_NT_SIGNATURE_LENGHT +
      IMAGE_SIZEOF_FILE_HEADER + IMAGE_SIZEOF_NT_OPTIONAL_HEADER);
    if (Header.NtHeader^.OptionalHeader.Magic <> IMAGE_NT_OPTIONAL_HDR_MAGIC) then
      Inc(SectionHeadersOffset, P64_AND_PE32_SIZE_DIFFERENCE);
    Header.DataDirectoryEntries := (TPImageDataDirectories(SectionHeadersOffset -
      SizeOf(TImageDataDirectory) * IMAGE_NUMBEROF_DIRECTORY_ENTRIES));
    Header.SectionHeaders := TPAImageSectionHeaders(SectionHeadersOffset);
    Header.SOffset := SectionHeadersOffset;
    Result := True;
  end;
end;

Function GetHeaderEx(Buffer:Pointer):PImageNtHeaders;
begin
  Result := nil;
  // Set NT Header, validate file against DOS and NT signatures
  try
    if (IsValidBlockAddr(DWord(Buffer), 2)) and
      (PWord(Buffer)^ = IMAGE_DOS_SIGNATURE) then
    begin
      result := (Pointer(DWord(Buffer) +
        DWord(Pointer(DWord(Buffer) + IMAGE_NT_HEADER_OFFSET_OFFSET)^)));
      if (not IsValidBlockAddr(DWord(result), 4) or
        (result^.signature <> IMAGE_NT_SIGNATURE)) then
        result := nil;
    end;
  Except
    result := nil;
  end;
end;

function LastSectionRaw(Sections: array of TImageSectionHeader):DWORD;
var
  i:    integer;
  Ret:  DWORD;
begin
  Ret := 0;
  for i := Low(Sections) to High(Sections) do
  begin
    if Sections[i].SizeOfRawData + Sections[i].PointerToRawData > Ret then
      Ret := Sections[i].SizeOfRawData + Sections[i].PointerToRawData;
  end;
  Result := Ret;
end;

function LastSectionVirtual(Sections: array of TImageSectionHeader):DWORD;
var
  i:   integer;
  Ret: DWORD;
begin
  Ret := 0;
  for i := Low(Sections) to High(Sections) do
  begin
    if Sections[i].Misc.VirtualSize + Sections[i].VirtualAddress > Ret then
      Ret := Sections[i].Misc.VirtualSize + Sections[i].VirtualAddress;
  end;
  Result := Ret;
end;

function AddSection(szFileName:string;szSectionName:ansistring; SectionSize,SectionAttributes:LongInt; SectionContent:Pointer; ContentSize:LongInt):LongInt;
var
Filehandle,FileMap :THandle;
FileSize,OldFileSize,FResize :Dword;
FileMapVA :pointer;
PEHeader :PImageNTHeaders;
PESections: PImageSectionHeader;
SN : word;
SOffset: DWord;
SpaceLeft,FAlign,SAlign,LastSecSize : dword;
AlignSecSize,NVirOffset : dword;
begin
  result := 0;

  // Prepare Size...
  if (ContentSize < SectionSize) and (ContentSize<>0) then
    ContentSize := SectionSize
  else if (ContentSize > SectionSize) then
    SectionSize := ContentSize;

  // Mapping File To Memory...
  if MapFileEx(szFileName,UE_ACCESS_READ,@FileHandle,@FileSize,@FileMap,@FileMapVA,0) then
  begin

    // Save Old Size...
    OldFileSize := FileSize;

    // Get PE Header...
    PEHeader := GetHeaderEx(FileMapVA);
    if (PEHeader<> nil) then
    begin

      // Calculate First Section Offset..
      SOffset := (DWord(PEHeader) + IMAGE_NT_SIGNATURE_LENGHT +
        IMAGE_SIZEOF_FILE_HEADER + IMAGE_SIZEOF_NT_OPTIONAL_HEADER);
      if (PEHeader.OptionalHeader.Magic <> IMAGE_NT_OPTIONAL_HDR_MAGIC) then
        Inc(SOffset, P64_AND_PE32_SIZE_DIFFERENCE);

      // Get Sections Number..
      SN := PEHeader.FileHeader.NumberOfSections;
      // Get File Alignment..
      FAlign := PEHeader.OptionalHeader.FileAlignment;

      // Get First Sections..
      PESections := PImageSectionHeader(SOffset);

      // Calculate Space in Section Table and New FileSize..
      try
        SpaceLeft := integer(PESections.PointerToRawData) - (SN*40) - integer(SOffset);
        PESections := PImageSectionHeader(integer(PESections)+(SN-1)*40);
        LastSecSize := (PESections.SizeOfRawData div FAlign) *FAlign;
        if (LastSecSize < PESections.SizeOfRawData) then
          LastSecSize := LastSecSize + FAlign;
        LastSecSize := LastSecSize - PESections.SizeOfRawData;
        UnMapFileEx(FileHandle, FileSize, FileMap, FileMapVA);
        FResize := LastSecSize + dword(SectionSize);
      Except
        UnmapFileEx(FileHandle,FileSize,FileMap,FileMapVA);
        result := 0;
        exit;
      end;

      // Check if still have space in section table..
      if (SpaceLeft > 40) then
      begin

        // ReMapping File To Memory With Resize File...
        if MapFileEx(szFileName,UE_ACCESS_ALL,@FileHandle,@FileSize,@FileMap,@FileMapVA,FResize) then
        begin

          // ReGet PE Header...
          PEHeader := GetHeaderEx(FileMapVA);
          if (PEHeader<> nil) then
          begin
            try
              // Calculate First Section Offset..
              SOffset := (DWord(PEHeader) + IMAGE_NT_SIGNATURE_LENGHT +
                IMAGE_SIZEOF_FILE_HEADER + IMAGE_SIZEOF_NT_OPTIONAL_HEADER);
              if (PEHeader.OptionalHeader.Magic <> IMAGE_NT_OPTIONAL_HDR_MAGIC) then
                Inc(SOffset, P64_AND_PE32_SIZE_DIFFERENCE);

              // Get Sections Number..
              SN := PEHeader.FileHeader.NumberOfSections;
              // Get File Alignment..
              FAlign := PEHeader.OptionalHeader.FileAlignment;
              // Get Section Alignment..
              SAlign := PEHeader.OptionalHeader.SectionAlignment;

              // Check New Section Size..
              if (SectionSize = 0) then SectionSize := FAlign;

              // Get Alignment New Section Size..
              AlignSecSize := (dword(SectionSize) div SAlign) * SAlign;
              if (AlignSecSize < dword(SectionSize)) then
                AlignSecSize := AlignSecSize + SAlign;

              // Get First Sections..
              PESections := PImageSectionHeader(SOffset);

              // Increment Sections Number..
              PEHeader.FileHeader.NumberOfSections := SN +1;

              // Jumpto Last Section..
              PESections := PImageSectionHeader(integer(PESections)+(SN-1)*40);

              // Calculate Virtual Address for New Sections..
              with PESections^ do
              begin
                NVirOffset := VirtualAddress + (Misc.VirtualSize div SAlign) * SAlign;
                if(NVirOffset < (VirtualAddress + Misc.VirtualSize)) then
                  NVirOffset := NVirOffset + SAlign;
              end;

              // Calculate SizeOfRawData for Last Sections..
              PESections.SizeOfRawData := PESections.SizeOfRawData + LastSecSize;

              // Add New Section to Sections Table..
              PESections := Pointer(integer(PESections)+40);

              // Calculate New SizeOfImage..
              PEHeader.OptionalHeader.SizeOfImage := NVirOffset + AlignSecSize;

              // Input Name to New Sections..
              movememory(@PESections.Name[0],@szSectionName[1],8);

              // Input Characteristics to New Sections..
              if (SectionAttributes = 0) then
                PESections.Characteristics := $E0000020
              else
                PESections.Characteristics := dword(SectionAttributes);

              // Input VirtualSize to New Sections..
              PESections.Misc.VirtualSize := AlignSecSize;

              // Input SizeOfRawData to New Sections..
              PESections.SizeOfRawData := dword(SectionSize);

              // Input SizeOfRawData to New Sections..
              PESections.VirtualAddress := NVirOffset;

              // Input PointerToRawData to New Sections..
              PESections.PointerToRawData := OldFileSize + LastSecSize;

              // Input Data to New Sections..
              if (sectioncontent <> nil) then
              begin
                movememory(pointer(cardinal(FileMapVA)+OldFileSize),SectionContent,ContentSize);
              end;

              // Finish..
              UnMapFileEx(FileHandle, FileSize, FileMap, FileMapVA);
              result := OldFileSize + LastSecSize;
            except
              UnMapFileEx(FileHandle, FileSize, FileMap, FileMapVA);
              result := 0;
              exit;
            end;
          end else
          begin
            UnMapFileEx(FileHandle, FileSize, FileMap, FileMapVA);
            result := 0;
            exit;
          end;
        end;
      end;
    end else
    begin
      UnMapFileEx(FileHandle, FileSize, FileMap, FileMapVA);
      result := 0;
    end;
  end;
end;

procedure CalculateCheckSum(Header:THeader;BaseAddress: Pointer; Size: DWord);
var
I, x: DWord;
CheckSum: DWORD;
begin
  x := 0;
  for I := 0 to (Size div 2 - 1) do
  begin
    x := (x + word(BaseAddress^));
    if (x and $ffff0000 <> 0) then x := (x and $ffff + x shr 16);
    Inc(DWord(BaseAddress), 2);
  end;
  if Odd(Size) then
  begin
    x := (x + byte(BaseAddress^));
    x := (x and $ffff + x shr 16);
  end;
  x := Word(x and $ffff + x shr 16);
  CheckSum := (x + Size);
  Header.NtHeader^.OptionalHeader.CheckSum := CheckSum;
end;

function StripRelocationTableFromStream(Source: TMemoryStream): Boolean;
var
Header: THeader;
I,RelocationTableSectionNumber,DebugDirectoriesCount :integer;
Size,FileAlignedSize : Dword;
Pidb: PImageDebugDirectory;

begin
  result := false;

  // Read headers...
  if GetHeader(Source.Memory,Header) then
  begin

    // Don't process dll...
    if (Header.NtHeader^.FileHeader.Characteristics and IMAGE_FILE_DLL <> 0) then Exit;

    // Check PE32 version...
    if (Header.NtHeader^.OptionalHeader.Magic <> IMAGE_NT_OPTIONAL_HDR_MAGIC) then Exit;

    // Check relocation table existence...
    if (Header.NtHeader^.FileHeader.Characteristics and IMAGE_FILE_RELOCS_STRIPPED <> 0) then Exit;

    with Header.DataDirectoryEntries^[IMAGE_DIRECTORY_ENTRY_BASERELOC] do
      if (VirtualAddress = 0) or (Size = 0) then Exit;

    // Find sections used relocation table; Find relocation table section...
    RelocationTableSectionNumber := -1;
    for I :=0 to (Header.NtHeader^.FileHeader.NumberOfSections - 1) do
    begin
      if (Header.SectionHeaders[I].VirtualAddress =
        Header.DataDirectoryEntries^[IMAGE_DIRECTORY_ENTRY_BASERELOC].VirtualAddress) then
        RelocationTableSectionNumber := I
      else
        if (Header.SectionHeaders[I].PointerToRelocations <> 0) then Exit;
    end;

    // Relocation table is not found...
    if (RelocationTableSectionNumber = -1) then Exit;

    // Remove relocation section...
    with Header.SectionHeaders[RelocationTableSectionNumber] do
    begin
      Move(Pointer(DWord(Source.Memory) + PointerToRawData + SizeOfRawData)^,
      Pointer(DWord(Source.Memory) + PointerToRawData)^,
      DWord(Source.size) - PointerToRawData - SizeOfRawData);
      Source.size := (DWord(Source.size) - SizeOfRawData);
    end;

    // Reread headers...
    if GetHeader(Source.Memory,Header) then
    begin
      Size := Header.SectionHeaders[RelocationTableSectionNumber].Misc.VirtualSize;
      FileAlignedSize := Align(Size, Header.NtHeader^.OptionalHeader.FileAlignment);

      // Fix section headers...
      for I := 0 to (Header.NtHeader^.FileHeader.NumberOfSections - 1) do
      begin
        // Move pointer to raw data if it is required...
        if (Header.SectionHeaders[I].PointerToRawData >
          Header.SectionHeaders[RelocationTableSectionNumber].PointerToRawData) then
          Dec(Header.SectionHeaders[I].PointerToRawData, FileAlignedSize);

        // Move pointer to line numebers if it is required...
        if (Header.SectionHeaders[I].PointerToLinenumbers >
          Header.SectionHeaders[RelocationTableSectionNumber].PointerToRawData) then
          Dec(Header.SectionHeaders[I].PointerToLinenumbers, FileAlignedSize);
      end;

      // Clear section header...
      with Header.SectionHeaders[RelocationTableSectionNumber] do
      begin
        SizeOfRawData := 0;
        Characteristics := (IMAGE_SCN_MEM_READ or IMAGE_SCN_MEM_WRITE);
      end;

      // Clear Data Directory entry...
      with Header.DataDirectoryEntries^[IMAGE_DIRECTORY_ENTRY_BASERELOC] do
      begin
        VirtualAddress := 0;
        Size := 0;
      end;

      // Fuzzy search debug section for case debug section VirtualAddress
      // is in the middle of real section...
      Pidb := nil;
      if (Header.DataDirectoryEntries^[IMAGE_DIRECTORY_ENTRY_DEBUG].Size > 0) then
      begin
        for I := 0 to Header.NtHeader^.FileHeader.NumberOfSections - 1 do
        begin
          if ((Header.DataDirectoryEntries^[IMAGE_DIRECTORY_ENTRY_DEBUG].VirtualAddress >=
            Header.SectionHeaders[I].VirtualAddress) and
            ((I = Header.NtHeader^.FileHeader.NumberOfSections - 1) or
            (Header.DataDirectoryEntries^[IMAGE_DIRECTORY_ENTRY_DEBUG].VirtualAddress <
            Header.SectionHeaders[I + 1].VirtualAddress))) then
          begin
            Pidb := (Pointer(DWord(Source.Memory) + Header.SectionHeaders[I].PointerToRawData +
              Header.DataDirectoryEntries^[IMAGE_DIRECTORY_ENTRY_DEBUG].VirtualAddress -
              Header.SectionHeaders[I].VirtualAddress));
            Break;
          end;
        end;
      end;

      // Update all ImageDebugDirectories...
      if (Pidb <> nil) then
      begin
        DebugDirectoriesCount := Header.DataDirectoryEntries^[IMAGE_DIRECTORY_ENTRY_DEBUG].Size;

        // If debug section Size is in bytes...
        if (DebugDirectoriesCount mod sizeOf(TImageDebugDirectory) = 0) then
          DebugDirectoriesCount := (DebugDirectoriesCount div sizeOf(TImageDebugDirectory));
        for I := 1 to DebugDirectoriesCount do
        begin
          if (Pidb^.PointerToRawData >
            Header.SectionHeaders[RelocationTableSectionNumber].PointerToRawData) then
            Dec(Pidb^.PointerToRawData, FileAlignedSize);
          Inc(Pidb);
        end;
      end;

      // Set IMAGE_FILE_RELOCS_STRIPPED flag...
      Header.NtHeader^.FileHeader.Characteristics := (Header.NtHeader^.FileHeader.Characteristics or IMAGE_FILE_RELOCS_STRIPPED);

      // Decrease total Size of initialized data...
      Dec(Header.NtHeader^.OptionalHeader.SizeOfInitializedData, FileAlignedSize);

      // Recalculate check sum...
      CalculateCheckSum(Header,Source.Memory, Source.size);

      Result := True;
    end;
  end;
end;
{---------------}
function StripRelocationTable(Const szFilename: String): Boolean;
var
Stream :TMemoryStream;
begin
  Stream := TMemoryStream.Create;
  try
    Stream.LoadFromFile(szFilename);
    Result := StripRelocationTableFromStream(Stream);
    Stream.SaveToFile(szFilename);
    Stream.Free;
  except
    Stream.Free;
    result := false;
  end;
end;

Function RealignFromMemoy(FileMapVA:pointer):boolean;
var
PEHeader:             PImageNTHeaders;
PESections:           PImageSectionHeader;
SOffset,FAlign,SAlign: DWord;
SN,x : word;
SectionDataPtr :dword;
OldSectionDataPtr :dword;
OldSectionDataRawPtr : dword;
NewSectionRawPointer : dword;
NewVirtualSectionSize : dword;
begin
  result := false;
  if assigned(FileMapVA) then
  begin

    // Get PE Header...
    PEHeader := GetHeaderEx(FileMapVA);
    if (PEHeader<> nil) then
    begin

      // Calculate First Section Offset..
      SOffset := (DWord(PEHeader) + IMAGE_NT_SIGNATURE_LENGHT +
        IMAGE_SIZEOF_FILE_HEADER + IMAGE_SIZEOF_NT_OPTIONAL_HEADER);
      if (PEHeader.OptionalHeader.Magic <> IMAGE_NT_OPTIONAL_HDR_MAGIC) then
        Inc(SOffset, P64_AND_PE32_SIZE_DIFFERENCE);

      // Get Sections Number..
      SN := PEHeader.FileHeader.NumberOfSections;
      // Get Section Alignment..
      SAlign := PEHeader.OptionalHeader.SectionAlignment;
      // Get File Alignment..
      FAlign := PEHeader.OptionalHeader.FileAlignment;
      if (FAlign = $1000) then FAlign := $200;
      PEHeader.OptionalHeader.FileAlignment := FAlign;

      // Get First Sections..
      PESections := PImageSectionHeader(SOffset);

      // ReAlign All Sections..
      for x := 0 to SN -1 do
      begin

        // GetLast offset raw current Section..
        SectionDataPtr := PESections.PointerToRawData + PESections.SizeOfRawData;
        if (PESections.SizeOfRawData > 0) then
        begin
          dec(SectionDataPtr);
          while (Byte(PUCHAR(Pointer(Cardinal(FileMapVA)+SectionDataPtr))) = $00) and (SectionDataPtr > PESections.PointerToRawData) do
              dec(SectionDataPtr);
        end;

        // Calculate New Size Raw Data..
        SectionDataPtr := SectionDataPtr -PESections.PointerToRawData;
        OldSectionDataPtr := SectionDataPtr;
        SectionDataPtr := (SectionDataPtr div FAlign) * FAlign;
        if (SectionDataPtr < OldSectionDataPtr) then
          SectionDataPtr := SectionDataPtr + FAlign;

        if (x = 0) then
        begin
          PEHeader.OptionalHeader.SizeOfHeaders := PESections.PointerToRawData;
          PEHeader.OptionalHeader.SectionAlignment := PESections.VirtualAddress;
          PESections.SizeOfRawData := SectionDataPtr;
        end else
        begin
          OldSectionDataRawPtr := PESections.PointerToRawData;
          PESections.SizeOfRawData := SectionDataPtr;
          PESections := Pointer(Cardinal(PESections)-SizeOf(TImageSectionHeader));
          NewSectionRawPointer := PESections.PointerToRawData + PESections.SizeOfRawData;
          PESections := Pointer(Cardinal(PESections)+SizeOf(TImageSectionHeader));
          PESections.PointerToRawData := NewSectionRawPointer;
          MoveMemory(Pointer(Cardinal(FileMapVA)+NewSectionRawPointer),
            Pointer(Cardinal(FileMapVA)+OldSectionDataRawPtr),SectionDataPtr);
        end;

        // Calculate New Virtual Size Data..
        NewVirtualSectionSize := (PESections.Misc.VirtualSize div SAlign) * SAlign;
        if (NewVirtualSectionSize < PESections.Misc.VirtualSize) then
          NewVirtualSectionSize := NewVirtualSectionSize + SAlign;
        PESections.Misc.VirtualSize := NewVirtualSectionSize;
        PESections := Pointer(Cardinal(PESections)+SizeOf(TImageSectionHeader));
        result := true;
      end;
    end;
  end;
end;

function RealignFile(Const szFilename: String): Boolean;
var
Stream :TMemoryStream;
begin
  Stream := TMemoryStream.Create;
  try
    Stream.LoadFromFile(szFilename);
    Result := RealignFromMemoy(Stream.Memory);
    Stream.SaveToFile(szFilename);
    Stream.Free;
  except
    Stream.Free;
    result := false;
  end;
end;

function ReChecksum(const szFilename:string):boolean;
var
Header: THeader;
Stream :TMemoryStream;
begin
  result := false;
  Stream := TMemoryStream.Create;
  try
    if GetHeader(Stream.Memory,Header) then
    begin
      CalculateCheckSum(Header,Stream.Memory, Stream.size);
      result := true;
    end;
    Stream.Free;
  except
    Stream.Free;
    result := false;
  end;
end;

Function AddEof(Source,Target: String): Boolean;
Var
  hFile                 :THandle;
  DosHeader             :TImageDosHeader;
  NTHeaders             :TImageNTHeaders;
  SectionHeader         :TImageSectionHeader;
  ReadBytes             :DWORD;
  OrginalFileSize       :DWORD;
  FileSize              :DWORD;
  SettingsLength        :DWORD;
  Buffer: Pointer;
begin
  Result := False;
  Buffer := nil;
  SettingsLength := 0;
  hFile := CreateFile(PChar(Source), GENERIC_READ, FILE_SHARE_READ, NIL,OPEN_EXISTING, 0, 0);
  If (hFile = INVALID_HANDLE_VALUE) Then exit;
  SetFilePointer(hFile, 0, NIL, FILE_BEGIN);
  ReadFile(hFile, Dosheader, SizeOf(DosHeader), ReadBytes, NIL);
  If (ReadBytes = SizeOf(Dosheader)) Then
  begin
    SetFilePointer(hFile, DosHeader._lfanew, NIL, FILE_BEGIN);
    ReadFile(hFile, NTHeaders, SizeOf(NTHeaders), ReadBytes, NIL);
    If (ReadBytes = SizeOf(NTHeaders)) Then
    begin
      SetFilePointer(hFile, SizeOf(SectionHeader) *
        (NTHeaders.FileHeader.NumberOfSections - 1), NIL,FILE_CURRENT);
      ReadFile(hFile, SectionHeader, SizeOf(SectionHeader), ReadBytes, NIL);
      OrginalFileSize := SectionHeader.PointerToRawData + SectionHeader.SizeOfRawData;
      FileSize        := Windows.GetFileSize(hFile, NIL);
      SettingsLength  := FileSize - OrginalFileSize;
      If (SettingsLength > 0) Then
      begin
        SetFilePointer(hFile, OrginalFileSize, NIL, FILE_BEGIN);
        GetMem(Buffer, SettingsLength);
        ReadFile(hFile, Buffer^, SettingsLength, ReadBytes, NIL);
        If (ReadBytes = SettingsLength) Then
        begin
          Result := True;
         end;
      end;
    end;
  end;
  CloseHandle(hFile);
  If (Assigned(Buffer)) And (SettingsLength > 0) and Result Then
  begin
    result := false;
    hFile := CreateFile(PChar(Target), GENERIC_WRITE,FILE_SHARE_WRITE, NIL, OPEN_ALWAYS,
      FILE_ATTRIBUTE_NORMAL, 0);
    If (hFile <> INVALID_HANDLE_VALUE) Then
    begin
      SetFilePointer(hFile, 0, NIL, FILE_END);
      WriteFile(hFile, Buffer^, SettingsLength, ReadBytes, NIL);
      CloseHandle(hFile);
      result := true;
    end;
    FreeMem(Buffer, SettingsLength);
  end;
end;

end.
