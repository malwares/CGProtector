unit U_RetCompress;

interface
uses
windows;

//ntdll compress
Function NtCompress(S:AnsiString):AnsiString;
Function NtDecompress(S:AnsiString):AnsiString;
implementation

type
  PVOID = pointer;
  ULONG = cardinal;
  NTSTATUS = cardinal;

const
  COMPRESSION_FORMAT_NONE	  = $00000000;
  COMPRESSION_FORMAT_DEFAULT	  = $00000001;
  COMPRESSION_FORMAT_LZNT1	  = $00000002;
  COMPRESSION_FORMAT_NS3	  = $00000003;
  COMPRESSION_FORMAT_NS15	  = $0000000F;
  COMPRESSION_FORMAT_SPARSE	  = $00004000;
  COMPRESSION_ENGINE_STANDARD	  = $00000000;
  COMPRESSION_ENGINE_MAXIMUM	  = $00000100;
  COMPRESSION_ENGINE_HIBER	  = $00000200;

const
  ntdll = 'ntdll.dll';

function RtlGetCompressionWorkSpaceSize(CompressionFormatAndEngine: ULONG; CompressBufferWorkSpaceSize, CompressFragmentWorkSpaceSize : PULONG): NTSTATUS; stdcall; external ntdll name 'RtlGetCompressionWorkSpaceSize';
function RtlCompressBuffer(CompressionFormatAndEngine:ULONG; SourceBuffer: PVOID; SourceBufferLength: ULONG; DestinationBuffer: PVOID; DestinationBufferLength: ULONG; SourceChunkSize: ULONG; pDestinationSize: PULONG; WorkspaceBuffer: PVOID):NTSTATUS; stdcall; external ntdll name 'RtlCompressBuffer';
function RtlDeCompressBuffer(CompressionFormatAndEngine:ULONG; DestinationBuffer: PVOID; DestinationBufferLength: ULONG; SourceBuffer: PVOID; SourceBufferLength: ULONG; pDestinationSize: PULONG):NTSTATUS; stdcall;  external ntdll name 'RtlDecompressBuffer';

function CompressString(sBuffer:Ansistring; dBufferSize:DWORD):ansistring;
var
  dWorkSpaceSize:   DWORD;
  dFragSpaceSize:   DWORD;
  pWorkSpace:       Pointer;
  pOutFile:         Pointer;
  dSize:            DWORD;
begin
  if RtlGetCompressionWorkSpaceSize(2, @dWorkSpaceSize, @dFragSpaceSize) = 0 then
  begin
    pOutFile := VirtualAlloc(nil, dBufferSize, MEM_COMMIT, PAGE_EXECUTE_READWRITE);
    if pOutFile <> nil then
    begin
      pWorkspace := VirtualAlloc(nil, dWorkSpaceSize, MEM_COMMIT, PAGE_EXECUTE_READWRITE);
      if pWorkSpace <> nil then
      begin
        if RtlCompressBuffer(2, @sBuffer[1], dBufferSize, pOutFile, dBufferSize, 0, @dSize, pWorkspace) = 0 then
        begin
          SetLength(Result, dSize);
          Move(pOutFile^, Result[1], dSize);
          VirtualFree(pOutFile, dSize, MEM_DECOMMIT);
          VirtualFree(pWorkSpace, dWorkSpaceSize, MEM_DECOMMIT);
        end;
      end;
    end;
  end;
end;

function DeCompressString(sBuffer:ansistring; dBufferSize:DWORD):ansistring;
var
  pOutFile:   Pointer;
  dSize:      DWORD;
begin
  dBufferSize := dBufferSize * 2;
  pOutFile := VirtualAlloc(nil, dBufferSize, MEM_COMMIT, PAGE_EXECUTE_READWRITE);
  if pOutFile <> nil then
  begin
    if RtlDeCompressBuffer(2, pOutFile, dBufferSize, @sBuffer[1], dBufferSize, @dSize) = 0 then
    begin
      SetLength(Result, dSize);
      Move(pOutFile^, Result[1], dSize);
      VirtualFree(pOutFile, dBufferSize, MEM_DECOMMIT);
    end;
  end;
end;

Function NtCompress(S:AnsiString):AnsiString;
begin
  result := CompressString(s,length(s));
end;

Function NtDecompress(S:AnsiString):AnsiString;
begin
  result := DeCompressString(s,length(s));
end;

end.
