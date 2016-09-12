unit U_Hardwareid;

interface
uses
windows,sysutils,U_Encryption;

Function GetHardwareid:longword;
implementation

function GetIdeSerialNumber ():Ansistring;
const IDENTIFY_BUFFER_SIZE = 512;
type
  TIDERegs = packed record
    bFeaturesReg     : BYTE;
    bSectorCountReg  : BYTE;
    bSectorNumberReg : BYTE;
    bCylLowReg       : BYTE;
    bCylHighReg      : BYTE;
    bDriveHeadReg    : BYTE;
    bCommandReg      : BYTE;
    bReserved        : BYTE;
  end;
  TSendCmdInParams = packed record
    cBufferSize  : DWORD;
    irDriveRegs  : TIDERegs;
    bDriveNumber : BYTE;
    bReserved    : Array[0..2] of Byte;
    dwReserved   : Array[0..3] of DWORD;
    bBuffer      : Array[0..0] of Byte;
  end;
  TIdSector = packed record
    wGenConfig                 : Word;
    wNumCyls                   : Word;
    wReserved                  : Word;
    wNumHeads                  : Word;
    wBytesPerTrack             : Word;
    wBytesPerSector            : Word;
    wSectorsPerTrack           : Word;
    wVendorUnique              : Array[0..2] of Word;
    sSerialNumber              : Array[0..19] of ansiCHAR;
    wBufferType                : Word;
    wBufferSize                : Word;
    wECCSize                   : Word;
    sFirmwareRev               : Array[0..7] of ansiCHAR;
    sModelNumber               : Array[0..39] of ansiCHAR;
    wMoreVendorUnique          : Word;
    wDoubleWordIO              : Word;
    wCapabilities              : Word;
    wReserved1                 : Word;
    wPIOTiming                 : Word;
    wDMATiming                 : Word;
    wBS                        : Word;
    wNumCurrentCyls            : Word;
    wNumCurrentHeads           : Word;
    wNumCurrentSectorsPerTrack : Word;
    ulCurrentSectorCapacity    : DWORD;
    wMultSectorStuff           : Word;
    ulTotalAddressableSectors  : DWORD;
    wSingleWordDMA             : Word;
    wMultiWordDMA              : Word;
    bReserved                  : Array[0..127] of BYTE;
  end;
  PIdSector = ^TIdSector;
  TDriverStatus = packed record
    bDriverError : Byte;
    bIDEStatus   : Byte;
    bReserved    : Array[0..1] of Byte;
    dwReserved   : Array[0..1] of DWORD;
  end;
  TSendCmdOutParams = packed record
    cBufferSize  : DWORD;
    DriverStatus : TDriverStatus;
    bBuffer      : Array[0..0] of BYTE;
  end;

  var
    hDevice : THandle;
    cbBytesReturned : DWORD;
    SCIP : TSendCmdInParams;
    aIdOutCmd : Array [0..(SizeOf(TSendCmdOutParams)+IDENTIFY_BUFFER_SIZE-1)-1] of Byte;
    IdOutCmd  : TSendCmdOutParams absolute aIdOutCmd;

  procedure ChangeByteOrder( var Data; Size : Integer );
  var ptr : PChar;
      i : Integer;
      c : Char;
  begin
    ptr := @Data;
    for i := 0 to (Size shr 1)-1 do
    begin
      c := ptr^;
      ptr^ := (ptr+1)^;
      (ptr+1)^ := c;
      Inc(ptr,2);
    end;
  end;

begin
  Result := '';
  if SysUtils.Win32Platform=VER_PLATFORM_WIN32_NT then
    begin
      hDevice := CreateFile( '\\.\PhysicalDrive0', GENERIC_READ or GENERIC_WRITE,
        FILE_SHARE_READ or FILE_SHARE_WRITE, nil, OPEN_EXISTING, 0, 0 );
    end
  else
      hDevice := CreateFile( '\\.\SMARTVSD', 0, 0, nil, CREATE_NEW, 0, 0 );
  if hDevice=INVALID_HANDLE_VALUE then Exit;
  try
    FillChar(SCIP,SizeOf(TSendCmdInParams)-1,#0);
    FillChar(aIdOutCmd,SizeOf(aIdOutCmd),#0);
    cbBytesReturned := 0;
    with SCIP do
    begin
      cBufferSize  := IDENTIFY_BUFFER_SIZE;
      with irDriveRegs do
      begin
        bSectorCountReg  := 1;
        bSectorNumberReg := 1;
        bDriveHeadReg    := $A0;
        bCommandReg      := $EC;
      end;
    end;
    if not DeviceIoControl( hDevice, $0007c088, @SCIP, SizeOf(TSendCmdInParams)-1,
      @aIdOutCmd, SizeOf(aIdOutCmd), cbBytesReturned, nil ) then Exit;
  finally
    CloseHandle(hDevice);
  end;
  with PIdSector(@IdOutCmd.bBuffer)^ do
  begin
    ChangeByteOrder( sSerialNumber, SizeOf(sSerialNumber) );
    (PChar(@sSerialNumber)+SizeOf(sSerialNumber))^ := #0;
    Result := PansiChar(@sSerialNumber);
  end;
end;

function GetCnCPUInfoString: string;
const
  cnIFContinuous = '%.8x%.8x%.8x%.8x';
var
  iEax,iEbx,iEcx,iEdx: Integer;
begin
  asm
    push ebx
    push ecx
    push edx
    mov  eax, $1
    dw $A20F
    mov iEax, eax
    mov iEbx, ebx
    mov iEcx, ecx
    mov iEdx, edx
    pop edx
    pop ecx
    pop ebx
  end;
  Result := Format(cnIFContinuous, [iEax, iEbx, iEcx, iEdx])
end;

function GetMacAddress: string;
var
  Lib: Cardinal;
  Func: function(GUID: PGUID): Longint; stdcall;
  GUID1, GUID2: TGUID;
begin
  Result := '';
  Lib := LoadLibrary('rpcrt4.dll');
  if Lib <> 0 then
  begin
    if Win32Platform <>VER_PLATFORM_WIN32_NT then
      @Func := GetProcAddress(Lib, 'UuidCreate')
      else @Func := GetProcAddress(Lib, 'UuidCreateSequential');
    if Assigned(Func) then
    begin
      if (Func(@GUID1) = 0) and
        (Func(@GUID2) = 0) and
        (GUID1.D4[2] = GUID2.D4[2]) and
        (GUID1.D4[3] = GUID2.D4[3]) and
        (GUID1.D4[4] = GUID2.D4[4]) and
        (GUID1.D4[5] = GUID2.D4[5]) and
        (GUID1.D4[6] = GUID2.D4[6]) and
        (GUID1.D4[7] = GUID2.D4[7]) then
      begin
        Result :=
         IntToHex(GUID1.D4[2], 2) +
         IntToHex(GUID1.D4[3], 2) +
         IntToHex(GUID1.D4[4], 2) +
         IntToHex(GUID1.D4[5], 2) +
         IntToHex(GUID1.D4[6], 2) +
         IntToHex(GUID1.D4[7], 2);
      end;
    end;
    FreeLibrary(Lib);
  end;
end;

type
  TCPUIDResult = packed record
    EAX: Cardinal;
    EBX: Cardinal;
    ECX: Cardinal;
    EDX: Cardinal;
  end;
  TCPUType = (ctPrimary, ctOverDrive, ctSecondary, ctUnknown);

const
   CPUID_CPUSIGNATURE	: DWORD = $1;

var
  CPUID_Level: DWORD;

function ExecuteCPUID: TCPUIDResult; assembler;
asm
    PUSH    EBX
    PUSH    EDI
    MOV     EDI, EAX
    MOV     EAX, CPUID_LEVEL
    DW	    $A20F
    STOSD
    MOV     EAX, EBX
    STOSD
    MOV     EAX, ECX
    STOSD
    MOV     EAX, EDX
    STOSD
    POP     EDI
    POP     EBX
end;

function GetCPUSerialNumber: String;
  function SplitToNibble(ANumber: String): String;
  var
    rs:string;
  begin
    rs:=Copy(ANumber,0,4)+Copy(ANumber,5,4);
    Result:=rs;
  end;
var
  SerialNumber: TCPUIDResult;
begin
  Result:='';
  CPUID_Level:=CPUID_CPUSIGNATURE;
  SerialNumber:=ExecuteCPUID;
  Result:=SplitToNibble(IntToHex(SerialNumber.EAX,8));
  CPUID_Level:=CPUID_CPUSIGNATURE;
  SerialNumber:=ExecuteCPUID;
  Result:=Result+SplitToNibble(IntToHex(SerialNumber.EDX,8));
  Result:=Result+SplitToNibble(IntToHex(SerialNumber.ECX,8));
end;

Function GetHardwareid:longword;
var
hardwareid : string;
begin
  {$I SE_PROTECT_START_ULTRA.inc}
  hardwareid := '';
  if GetCPUSerialNumber <> '' then
    hardwareid := hardwareid + GetCPUSerialNumber;
  if Trim(String(GetIdeSerialNumber)) <> '' then
    hardwareid := hardwareid + Trim(String(GetIdeSerialNumber));
  result := CrcansiString(ansistring(hardwareid));
  {$I SE_PROTECT_END.inc}
end;

end.


