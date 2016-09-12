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
unit rsAesEncryptor;

interface

{$I rsStorage.inc}

uses Classes, SysUtils, rsStorage, rsConst, dsrAES;

type
  TrsAesEncryptorMode = TAESChipherMode;
  TrsAesEncryptorKeyBits = TAESChipherKeyBits;

  TrsAesEncryptor = class(TrsEncryptor)
  private
    function GetKey: string;
    function GetKeyBits: TrsAesEncryptorKeyBits;
    function GetMode: TrsAesEncryptorMode;
    procedure SetKey(const Value: string);
    procedure SetKeyBits(const Value: TrsAesEncryptorKeyBits);
    procedure SetMode(const Value: TrsAesEncryptorMode);
  protected
    function DecryptBuffer(PData: Pointer; Count: integer): integer; override;
    function EncryptBuffer(PData: Pointer; Count: integer): integer; override;
    function CalcDecryptBufferSize(const SourceCount: integer): integer; override;
    function CalcEncryptBufferSize(const SourceCount: integer): integer; override;
  public
    Cipher: TAESChipher;
    constructor Create(AOwner: TComponent); override;
    destructor Destroy; override;
  published
    property Mode: TrsAesEncryptorMode read GetMode write SetMode;
    property KeyBits: TrsAesEncryptorKeyBits read GetKeyBits write SetKeyBits;
    property Key: string read GetKey write SetKey;
  end;

implementation

uses rsUtils;


{ TrsXorEncryptor }

function TrsAesEncryptor.CalcDecryptBufferSize(const SourceCount: integer): integer;
begin
  Result := SourceCount;
end;

function TrsAesEncryptor.CalcEncryptBufferSize(const SourceCount: integer): integer;
begin
  Result := 0;
  Cipher.BufferEncrypt(nil, SourceCount, nil, Result);
end;

constructor TrsAesEncryptor.Create(AOwner: TComponent);
begin
  inherited;
  Cipher := TAESChipher.Create;
end;


function TrsAesEncryptor.DecryptBuffer(PData: Pointer; Count: integer): integer;
var
  Dest: pointer;
  DestCount,i: integer;
begin
  DestCount := CalcDecryptBufferSize(Count);
  GetMem(Dest, DestCount);
  i := DestCount;
  Result := Cipher.BufferDecrypt(PData, Count, Dest, i);
  if Result>=0
    then begin
      Move(Dest^, PData^, i);
      Result := i;
    end;
  FreeMem(Dest, DestCount);
end;

destructor TrsAesEncryptor.Destroy;
begin
  inherited;
  Cipher.Free;
end;

function TrsAesEncryptor.EncryptBuffer(PData: Pointer; Count: integer): integer;
var
  Dest: pointer;
  DestCount,i: integer;
begin
  DestCount := CalcEncryptBufferSize(Count);
  GetMem(Dest, DestCount);
  i := DestCount;
  Result := Cipher.BufferEncrypt(PData, Count, Dest, i);
  if Result>=0
    then begin
      Move(Dest^, PData^, i);
      Result := i;
    end;
  FreeMem(Dest, DestCount);
end;


function TrsAesEncryptor.GetKey: string;
begin
  Result := Cipher.Key;
end;

function TrsAesEncryptor.GetKeyBits: TrsAesEncryptorKeyBits;
begin
  Result := Cipher.KeyBits;
end;

function TrsAesEncryptor.GetMode: TrsAesEncryptorMode;
begin
  Result := Cipher.Mode;
end;

procedure TrsAesEncryptor.SetKey(const Value: string);
begin
  Cipher.Key := Value;
end;

procedure TrsAesEncryptor.SetKeyBits(const Value: TrsAesEncryptorKeyBits);
begin
  Cipher.KeyBits := Value;
end;

procedure TrsAesEncryptor.SetMode(const Value: TrsAesEncryptorMode);
begin
  Cipher.Mode := Value;
end;

end.
