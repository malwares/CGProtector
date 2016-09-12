(*------------------------------------------------------------------------------

Unit          : SysUtils
Author        : Ivan Dyachenko
E-mail        : ivan.dyachenko@gmail.com
Site          : http://atgrand.com
Project       : http://clevertis.atgrand.com
Date          : 2009-10-31
Generation by : AT&PI PaxCompiler Importer

------------------------------------------------------------------------------*)

{$I PaxCompiler.def}
unit IMPORT_SysUtils;

interface
uses
   Windows,
   Types,
   SysConst,
   SysUtils,
   iCore2,
   PaxCompiler;

procedure Register_SysUtils;

implementation


procedure Register_SysUtils;
var
  H : Integer;
  G : Integer;
begin
  H := RegisterNamespace(0, 'SysUtils');
  _uses['SysUtils'] := true;

//--------------------------------------------------------------------------------
// CONST
  RegisterConstant(H, 'fmShareExclusive'  , fmShareExclusive);
  RegisterConstant(H, 'fmShareDenyWrite'  , fmShareDenyWrite);
  RegisterConstant(H, 'fmShareDenyRead'   , fmShareDenyRead);
  RegisterConstant(H, 'fmShareDenyNone'   , fmShareDenyNone);
  RegisterConstant(H, 'fmShareCompat'     , fmShareCompat);
  RegisterConstant(H, 'fmOpenWrite'       , fmOpenWrite);
  RegisterConstant(H, 'fmOpenReadWrite'   , fmOpenReadWrite);
  RegisterConstant(H, 'fmOpenRead'        , fmOpenRead);
  RegisterConstant(H, 'faSysFile'         , faSysFile);
  RegisterConstant(H, 'faSymLink'         , faSymLink);
  RegisterConstant(H, 'faReadOnly'        , faReadOnly);
  RegisterConstant(H, 'faHidden'          , faHidden);
  RegisterConstant(H, 'faDirectory'       , faDirectory);
  RegisterConstant(H, 'faArchive'         , faArchive);
  RegisterConstant(H, 'faAnyFile'         , faAnyFile);
  RegisterConstant(H, 'UnixDateDelta'     , UnixDateDelta);
  RegisterConstant(H, 'SecsPerMin'        , SecsPerMin);
  RegisterConstant(H, 'SecsPerDay'        , SecsPerDay);
  RegisterConstant(H, 'PathSep'           , PathSep);
  RegisterConstant(H, 'PathDelim'         , PathDelim);
  RegisterConstant(H, 'MinsPerHour'       , MinsPerHour);
  RegisterConstant(H, 'MinsPerDay'        , MinsPerDay);
  RegisterConstant(H, 'MaxEraCount'       , MaxEraCount);
  RegisterConstant(H, 'MSecsPerSec'       , MSecsPerSec);
  RegisterConstant(H, 'MSecsPerDay'       , MSecsPerDay);
  RegisterConstant(H, 'HoursPerDay'       , HoursPerDay);
  RegisterConstant(H, 'DriveDelim'        , DriveDelim);
  RegisterConstant(H, 'DefaultTrueBoolStr', DefaultTrueBoolStr);
  RegisterConstant(H, 'DefaultFalseBoolStr', DefaultFalseBoolStr);
  RegisterConstant(H, 'DateDelta'         , DateDelta);

//--------------------------------------------------------------------------------
// TYPE
  _type['TBytes']        := RegisterDynamicArrayType(H, 'TBytes'      , _typeBYTE);
  _type['TSysCharSet']   := RegisterRTTIType(H, TypeInfo(TSysCharSet));
  _type['TByteArray']    := RegisterArrayType(H, 'TByteArray'  , RegisterSubrangeType(H, '', _typeINTEGER, 0, 32767), _typeBYTE);
  _type['PByteArray']    := RegisterPointerType(H, 'PByteArray'  , _type['TByteArray']);
  _type['TWordArray']    := RegisterArrayType(H, 'TWordArray'  , RegisterSubrangeType(H, '', _typeINTEGER, 0, 16383), _typeWORD);
  _type['PWordArray']    := RegisterPointerType(H, 'PWordArray'  , _type['TWordArray']);
  _type['TFileName']     := RegisterTypeAlias(H, 'TFileName' , _typeSTRING);

  G := RegisterRecordType(H, 'TSearchRec');
  _type['TSearchRec']    := G;

  G := RegisterEnumType (H, 'TFloatValue');
       RegisterEnumValue(G, 'fvExtended'      , 0);
       RegisterEnumValue(G, 'fvCurrency'      , 1);
  _type['TFloatValue']   := G;

  G := RegisterEnumType (H, 'TFloatFormat');
       RegisterEnumValue(G, 'ffGeneral'       , 0);
       RegisterEnumValue(G, 'ffExponent'      , 1);
       RegisterEnumValue(G, 'ffFixed'         , 2);
       RegisterEnumValue(G, 'ffNumber'        , 3);
       RegisterEnumValue(G, 'ffCurrency'      , 4);
  _type['TFloatFormat']  := G;
  _type['TFloatRec']     := RegisterRecordType(H, 'TFloatRec');

//--------------------------------------------------------------------------------
// CLASS


//--------------------------------------------------------------------------------
// METHOD

  RegisterHeader(H, 'function UpperCase(const S: string): string; overload; ', @UpperCase);
  RegisterHeader(H, 'function LowerCase(const S: string): string; overload; ', @LowerCase);
  RegisterHeader(H, 'function CompareStr(const S1, S2: string): Integer; overload; ', @CompareStr);
  RegisterHeader(H, 'function WideUpperCase(const S: WideString): WideString; ', @WideUpperCase);
  RegisterHeader(H, 'function WideLowerCase(const S: WideString): WideString; ', @WideLowerCase);
  RegisterHeader(H, 'function WideCompareStr(const S1, S2: WideString): Integer; ', @WideCompareStr);
  RegisterHeader(H, 'function Trim(const S: WideString): WideString; overload; ', @Trim);
  RegisterHeader(H, 'function QuotedStr(const S: string): string; ', @QuotedStr);
  RegisterHeader(H, 'function IntToStr(Value: Integer): string; overload; ', @IntToStr);
  RegisterHeader(H, 'function IntToHex(Value: Integer; Digits: Integer): string; overload; ', @IntToHex);
  RegisterHeader(H, 'function StrToInt(const S: string): Integer; ', @StrToInt);
  RegisterHeader(H, 'function StrToBool(const S: string): Boolean; ', @StrToBool);
  RegisterHeader(H, 'function BoolToStr(B: Boolean; UseBoolStrs: Boolean = False): string; ', @BoolToStr);
  RegisterHeader(H, 'function FileOpen(const FileName: string; Mode: LongWord): Integer; ', @FileOpen);
  RegisterHeader(H, 'function FileCreate(const FileName: string): Integer; overload; inline; ', @FileCreate);
  RegisterHeader(H, 'function FileCreate(const FileName: string; Rights: Integer): Integer; overload; inline; ', @FileCreate);
  RegisterHeader(H, 'function FileRead(Handle: Integer; var Buffer; Count: LongWord): Integer; ', @FileRead);
  RegisterHeader(H, 'function FileWrite(Handle: Integer; const Buffer; Count: LongWord): Integer; ', @FileWrite);
  RegisterHeader(H, 'function FileSeek(Handle, Offset, Origin: Integer): Integer; overload; ', @FileSeek);
  RegisterHeader(H, 'function FileSeek(Handle: Integer; const Offset: Int64; Origin: Integer): Int64; overload; ', @FileSeek);
  RegisterHeader(H, 'procedure FileClose(Handle: Integer); inline; ', @FileClose);
  RegisterHeader(H, 'function DirectoryExists(const Directory: string): Boolean; ', @DirectoryExists);
  RegisterHeader(H, 'function ForceDirectories(Dir: string): Boolean; ', @ForceDirectories);
  RegisterHeader(H, 'function DeleteFile(const FileName: string): Boolean; inline; ', @DeleteFile);
  RegisterHeader(H, 'function RenameFile(const OldName, NewName: string): Boolean; inline; ', @RenameFile);
  RegisterHeader(H, 'function ExtractFilePath(const FileName: string): string; ', @ExtractFilePath);
  RegisterHeader(H, 'function ExtractFileDir(const FileName: string): string; ', @ExtractFileDir);
  RegisterHeader(H, 'function ExtractFileDrive(const FileName: string): string; ', @ExtractFileDrive);
  RegisterHeader(H, 'function ExtractFileName(const FileName: string): string; ', @ExtractFileName);
  RegisterHeader(H, 'function ExtractFileExt(const FileName: string): string; ', @ExtractFileExt);
  RegisterHeader(H, 'function ExpandFileName(const FileName: string): string; ', @ExpandFileName);
  RegisterHeader(H, 'function GetCurrentDir: string; ', @GetCurrentDir);
  RegisterHeader(H, 'function SetCurrentDir(const Dir: string): Boolean; ', @SetCurrentDir);
  RegisterHeader(H, 'function CreateDir(const Dir: string): Boolean; ', @CreateDir);
  RegisterHeader(H, 'function RemoveDir(const Dir: string): Boolean; ', @RemoveDir);
  RegisterHeader(H, 'function Format(const Format: string; const Args: array of const): string; overload; ', @Format);
  RegisterHeader(H, 'function WideFormat(const Format: WideString; const Args: array of const): WideString; overload; ', @WideFormat);
  RegisterHeader(H, 'function FloatToStr(Value: Extended): string; overload; ', @FloatToStr);
  RegisterHeader(H, 'function CurrToStr(Value: Currency): string; overload; ', @CurrToStr);
  RegisterHeader(H, 'function StrToFloat(const S: string): Extended; overload; ', @StrToFloat);
  RegisterHeader(H, 'function Date: TDateTime; ', @Date);
  RegisterHeader(H, 'function Time: TDateTime; ', @Time);
  RegisterHeader(H, 'function GetTime: TDateTime; ', @GetTime);
  RegisterHeader(H, 'function Now: TDateTime; ', @Now);
  RegisterHeader(H, 'function CurrentYear: Word; ', @CurrentYear);

//--------------------------------------------------------------------------------
// VAR


end;

initialization

Register_SysUtils;

end.
