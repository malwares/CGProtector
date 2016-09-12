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
{*******************************************************}
unit rsXorEncryptor;

interface

{$I rsStorage.inc}

uses Classes, SysUtils, rsStorage, rsConst;

type
  TrsXorEncryptor = class(TrsEncryptor)
  private
    FEncryptId: integer;
    function GenEncryptId: integer;
  protected
    function DecryptBuffer(PData: Pointer; Count: integer): integer; override;
    function EncryptBuffer(PData: Pointer; Count: integer): integer; override;
    function CalcDecryptBufferSize(const SourceCount: integer): integer; override;
    function CalcEncryptBufferSize(const SourceCount: integer): integer; override;
  public
    constructor Create(AOwner: TComponent); override;
  published
    property EncryptId: integer read FEncryptId write FEncryptId;
  end;

implementation

uses rsUtils;


{ TrsXorEncryptor }

function TrsXorEncryptor.CalcDecryptBufferSize(const SourceCount: integer): integer;
begin
  Result := SourceCount;
end;

function TrsXorEncryptor.CalcEncryptBufferSize(const SourceCount: integer): integer;
begin
  Result := SourceCount;
end;

constructor TrsXorEncryptor.Create(AOwner: TComponent);
begin
  inherited;
  FEncryptId := GenEncryptId;
end;


function TrsXorEncryptor.DecryptBuffer(PData: Pointer; Count: integer): integer;
begin
  Result := EncryptBuffer(PData, Count);
end;

function TrsXorEncryptor.EncryptBuffer(PData: Pointer; Count: integer): integer;
var
  pI: PInteger;
  i: integer;
begin
  pI := PData;

  i := Count div SizeOf(Integer);
  While i>0 do begin
    pI^ := pI^ xor FEncryptId;
    Inc(pI);
    Dec(i);
  end;

  i := Count mod SizeOf(Integer);
  if i>0 then begin
    PByte(pI)^ := PByte(pI)^ xor ((FEncryptId shr (0*8)) and $FF);
    Dec(i);
    if i>0 then begin
      PByte(Integer(pI)+1)^ := PByte(Integer(pI)+1)^ xor ((FEncryptId shr (1*8)) and $FF);
      Dec(i);
      if i>0 then begin
        PByte(Integer(pI)+2)^ := PByte(Integer(pI)+2)^ xor ((FEncryptId shr (2*8)) and $FF);
      end;
    end;
  end;
  Result := Count;
end;

function TrsXorEncryptor.GenEncryptId: integer;
begin
  Randomize;
  Result := Random(High(Integer));
end;

end.
