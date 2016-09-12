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
unit rsConst;

interface

{$I rsStorage.inc}

Const
  SRSProductKey  = 'Software\Deepsoftware\Storage library';
  SRSTemplatesFileName = 'rsTempls.ini';
  SRSLibName = 'RslLib';
  SRSLibVersion = '3.56';

  CRSHexStrLength = 80;
  CRSBufferSize = 4096;
  RSBooleanIdentsFalse = 'False';
  RSBooleanIdentsTrue = 'True';
  //-+-*--+*--+--+*+-+++-==---+=--*=--+=--+=-+=*--+-+-*---=+--*+-+*=
  RSHexDigits: PChar = '0123456789ABCDEF';
  RSBase64Digits: PAnsiChar = 'ABCDEFGHIJKLMNOPQRSTUVWXYZ'+
                              'abcdefghijklmnopqrstuvwxyz'+
                              '0123456789+/';


  RSMAX_PATH = 260;
{$IFDEF RSL_WIN}
{$IFDEF RSL_UNICODE}
 CEOL = Char(#13)+Char(#10);
{$ELSE}
  CEOL = #13#10;
{$ENDIF}
  CDirSeparator = '\';
{$ENDIF}
{$IFDEF RSL_KYLIX}
  CEOL = #10;
  CDirSeparator = '/';
{$ENDIF}



{$IFDEF RSL_CB3LE}
type
  PDateTime = ^TDateTime;
{$ENDIF}

{$IFDEF RSL_D5LE}
type
  PInteger = ^Integer;
  PByte = ^Byte;
{$ENDIF}

{$IFNDEF RSL_D6GE}
type
  TVarType = Integer;
{$ENDIF}

type
{$IFDEF RSL_UNICODE}
  RSLString = WideString;
  RSLChar = WideChar;
  PRSLChar = PWideChar;
{$ELSE}
  RSLString = String;
  RSLChar = Char;
  PRSLChar = PChar;
{$ENDIF}

implementation

end.

