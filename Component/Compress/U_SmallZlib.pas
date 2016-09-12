unit U_SmallZlib;

interface
uses
ZLibExApi;

function ZCompressStr(const s: AnsiString): RawByteString;
function ZDecompressStr(const s: RawByteString): AnsiString;
implementation

function ZCompressCheck(code: Integer): Integer;
begin
  result := code;
  if (code < 0) then exit;
end;

function ZDecompressCheck(code: Integer; raiseBufferError: Boolean = True): Integer;
begin
  Result := code;
  if code < 0 then
  begin
    if (code <> Z_BUF_ERROR) or raiseBufferError then
    begin
      exit;
    end;
  end;
end;

function ZInflateInit(var stream: TZStreamRec): Integer;
begin
  result := inflateInit_(stream, ZLIB_VERSION, SizeOf(TZStreamRec));
end;

function ZInflate(var stream: TZStreamRec; flush: integer): Integer;
begin
  result := inflate(stream, flush);
end;

function ZInflateEnd(var stream: TZStreamRec): Integer;
begin
  result := inflateEnd(stream);
end;

function ZDeflateInit(var stream: TZStreamRec): Integer;
begin
  result := deflateInit_(stream, 3, ZLIB_VERSION, SizeOf(TZStreamRec));
end;

function ZDeflate(var stream: TZStreamRec; flush: integer): Integer;
begin
  result := deflate(stream, flush);
end;

function ZDeflateEnd(var stream: TZStreamRec): Integer;
begin
  result := deflateEnd(stream);
end;

procedure ZInternalCompress(var zstream: TZStreamRec; const inBuffer: Pointer;
  inSize: Integer; out outBuffer: Pointer; out outSize: Integer);
const
  delta = 256;
var
  zresult: Integer;
begin
  outSize := ((inSize + (inSize div 10) + 12) + 255) and not 255;
  outBuffer := Nil;
  try
    try
      zstream.next_in := inBuffer;
      zstream.avail_in := inSize;
      repeat
        ReallocMem(outBuffer, outSize);
        zstream.next_out := Pointer(Integer(outBuffer) + zstream.total_out);
        zstream.avail_out := outSize - zstream.total_out;
        zresult := ZCompressCheck(ZDeflate(zstream,0));
        Inc(outSize, delta);
      until (zresult = Z_STREAM_END) or (zstream.avail_in = 0);

       while (zresult <> Z_STREAM_END) do
       begin
        ReallocMem(outBuffer, outSize);
        zstream.next_out := Pointer(Integer(outBuffer) + zstream.total_out);
        zstream.avail_out := outSize - zstream.total_out;
        zresult := ZCompressCheck(ZDeflate(zstream, 4));
        Inc(outSize, delta);
       end;
    finally
      ZCompressCheck(ZDeflateEnd(zstream));
    end;
    ReallocMem(outBuffer, zstream.total_out);
    outSize := zstream.total_out;
  Except
    FreeMem(outBuffer);
  end;
end;

procedure ZInternalDecompress(zstream: TZStreamRec; const inBuffer: Pointer;
  inSize: Integer; out outBuffer: Pointer; out outSize: Integer;
  outEstimate: Integer);
var
  zresult: Integer;
  delta  : Integer;
begin
  delta := (inSize + 255) and not 255;
  if outEstimate = 0 then outSize := delta
  else outSize := outEstimate;
  outBuffer := Nil;
  try
    try
      zresult := Z_OK;
      zstream.avail_in := inSize;
      zstream.next_in := inBuffer;
      while (zresult <> Z_STREAM_END) and (zstream.avail_in > 0) do
      begin
        repeat
          ReallocMem(outBuffer, outSize);
          zstream.next_out := Pointer(Integer(outBuffer) + zstream.total_out);
          zstream.avail_out := outSize - zstream.total_out;
          zresult := ZDecompressCheck(ZInflate(zstream, 0), False);
          Inc(outSize, delta);
        until (zresult = Z_STREAM_END) or (zstream.avail_out > 0);
      end;
    finally
      ZDecompressCheck(ZInflateEnd(zstream));
    end;
    ReallocMem(outBuffer, zstream.total_out);
    outSize := zstream.total_out;
  except
    if Assigned(outBuffer) then FreeMem(outBuffer);
  end;
end;

procedure ZCompress(const inBuffer: Pointer; inSize: Integer;
  out outBuffer: Pointer; out outSize: Integer);
var
  zstream: TZStreamRec;
begin
  FillChar(zstream, SizeOf(TZStreamRec), 0);
  ZCompressCheck(ZDeflateInit(zstream));
  ZInternalCompress(zstream, inBuffer, inSize, outBuffer, outSize);
end;

procedure ZDecompress(const inBuffer: Pointer; inSize: Integer;
  out outBuffer: Pointer; out outSize: Integer);
var
  zstream: TZStreamRec;
begin
  FillChar(zstream, SizeOf(TZStreamRec), 0);
  ZDecompressCheck(ZInflateInit(zstream));
  ZInternalDecompress(zstream, inBuffer, inSize, outBuffer, outSize, 0);
end;

procedure ZCompressString(var result: RawByteString; const s: AnsiString);
var
  buffer: Pointer;
  size  : Integer;
begin
  ZCompress(Pointer(s), Length(s), buffer, size);
  SetLength(result, size);
  Move(buffer^, result[1], size);
  FreeMem(buffer);
end;

procedure ZDecompressString(var result: AnsiString;  const s: RawByteString);
var
  buffer: Pointer;
  size  : Integer;
begin
  ZDecompress(Pointer(s), Length(s), buffer, size);
  SetLength(result, size);
  Move(buffer^, result[1], size);
  FreeMem(buffer);
end;

function ZCompressStr(const s: AnsiString): RawByteString;
begin
  ZCompressString(result, s);
end;

function ZDecompressStr(const s: RawByteString): AnsiString;
begin
  ZDecompressString(result, s);
end;

end.
