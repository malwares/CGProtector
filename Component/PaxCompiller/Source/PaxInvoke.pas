////////////////////////////////////////////////////////////////////////////
// PaxInvoke
// Site: http://www.paxcompiler.com
// Author: Alexander Baranovsky (paxscript@gmail.com)
// ========================================================================
// Copyright (c) Alexander Baranovsky,2006-2008. All rights reserved.
// Code Version: 2.4
// ========================================================================
// Unit: PaxInvoke.pas
// Implements dynamically invoke of a global function or a method of object
// ========================================================================
////////////////////////////////////////////////////////////////////////////

{$I PaxCompiler.def}
{$O-}
unit PaxInvoke;
interface
uses
  Classes,
  PAXCOMP_INVOKE;
const
  __ccSTDCALL = 1;
  __ccREGISTER = 2;
  __ccCDECL = 3;
  __ccPASCAL = 4;
  __ccSAFECALL = 5;
  __ccMSFASTCALL = 6;
type
  TPaxInvoke = class(TComponent)
  private
    base_invoke: TInvoke;
    function GetAddr: Pointer;
    procedure SetAddr(value: Pointer);
    procedure SetCallConv(value: Integer);
    function GetCallConv: Integer;
    function GetThis: Pointer;
    procedure SetThis(value: Pointer);
  public
    constructor Create(AOwner: TComponent); override;
    destructor Destroy; override;

    procedure LoadAddress(const DllName, ProcName: String);

    procedure ClearArguments;

    procedure AddArgAsByte(value: Byte);
    procedure AddArgAsWord(value: Word);
    procedure AddArgAsCardinal(value: Cardinal);
    procedure AddArgAsShortInt(value: ShortInt);
    procedure AddArgAsSmallInt(value: SmallInt);
    procedure AddArgAsInteger(value: Integer);
    procedure AddArgAsInt64(value: Int64);
    procedure AddArgAsBoolean(value: Boolean);
    procedure AddArgAsWordBool(value: WordBool);
    procedure AddArgAsLongBool(value: LongBool);
    procedure AddArgAsChar(value: Char);
    procedure AddArgAsWideChar(value: WideChar);
    procedure AddArgAsDouble(value: Double);
    procedure AddArgAsSingle(value: Single);
    procedure AddArgAsExtended(value: Extended);
    procedure AddArgAsCurrency(value: Currency);
    procedure AddArgAsAnsiString(const value: AnsiString);
    procedure AddArgAsWideString(const value: WideString);
    procedure AddArgAsShortString(const value: ShortString);
    procedure AddArgAsPChar(value: PChar);
    procedure AddArgAsPWideChar(value: PWideChar);
    procedure AddArgAsPointer(value: Pointer);
    procedure AddArgAsRecord(var value; Size: Integer);
    procedure AddArgAsRecordByVal(var value; Size: Integer);
    procedure AddArgAsArray(var value; Size: Integer);
    procedure AddArgAsArrayByVal(var value; Size: Integer);
    procedure AddArgAsDynArray(var value);
    procedure AddArgAsObject(value: TObject);
    procedure AddArgAsClassRef(value: TClass);
    procedure AddArgAsVariant(const value: Variant);
    procedure AddArgAsSet(var value; Size: Integer);
    procedure AddArgAsInterface(const value: IUnknown);

    procedure SetResultAsVoid;
    procedure SetResultAsByte;
    procedure SetResultAsWord;
    procedure SetResultAsCardinal;
    procedure SetResultAsShortInt;
    procedure SetResultAsSmallInt;
    procedure SetResultAsInteger;
    procedure SetResultAsBoolean;
    procedure SetResultAsWordBool;
    procedure SetResultAsLongBool;
    procedure SetResultAsChar;
    procedure SetResultAsWideChar;
    procedure SetResultAsDouble;
    procedure SetResultAsSingle;
    procedure SetResultAsExtended;
    procedure SetResultAsCurrency;
    procedure SetResultAsAnsiString;
    procedure SetResultAsWideString;
    procedure SetResultAsShortString;
    procedure SetResultAsPChar;
    procedure SetResultAsPWideChar;
    procedure SetResultAsPointer;
    procedure SetResultAsArray(Size: Integer);
    procedure SetResultAsDynArray;
    procedure SetResultAsRecord(Size: Integer);
    procedure SetResultAsObject;
    procedure SetResultAsClassRef;
    procedure SetResultAsInterface;
    procedure SetResultAsInt64;
    procedure CallHost;
    function GetResultPtr: Pointer;
    procedure ClearResult;
    function GetImplementation: Pointer;
    property Address: Pointer read GetAddr write SetAddr;
    property CallConv: Integer read GetCallConv write SetCallConv;
    property This: Pointer read GetThis write SetThis;
  end;

implementation

constructor TPaxInvoke.Create(AOwner: TComponent);
begin
  inherited;
  base_invoke := TInvoke.Create;
end;

destructor TPaxInvoke.Destroy;
begin
  base_invoke.Free;
  inherited;
end;

function TPaxInvoke.GetAddr: Pointer;
begin
  result := base_invoke.Address;
end;

procedure TPaxInvoke.SetAddr(value: Pointer);
begin
  base_invoke.Address := value;
end;

procedure TPaxInvoke.LoadAddress(const DllName, ProcName: String);
begin
  base_invoke.LoadAddress(DllName, ProcName);
end;

procedure TPaxInvoke.ClearArguments;
begin
  base_invoke.ClearArguments;
end;

procedure TPaxInvoke.AddArgAsByte(value: Byte);
begin
  base_invoke.AddArg(value, __typeINTEGER);
end;

procedure TPaxInvoke.AddArgAsWord(value: Word);
begin
  base_invoke.AddArg(value, __typeINTEGER);
end;

procedure TPaxInvoke.AddArgAsCardinal(value: Cardinal);
begin
{$IFDEF VARIANTS}
  base_invoke.AddArg(value, __typeINTEGER);
{$ELSE}
  base_invoke.AddArg(Integer(value), __typeINTEGER);
{$ENDIF}
end;

procedure TPaxInvoke.AddArgAsShortInt(value: ShortInt);
begin
  base_invoke.AddArg(value, __typeINTEGER);
end;

procedure TPaxInvoke.AddArgAsSmallInt(value: SmallInt);
begin
  base_invoke.AddArg(value, __typeINTEGER);
end;

procedure TPaxInvoke.AddArgAsInteger(value: Integer);
begin
  base_invoke.AddArg(value, __typeINTEGER);
end;

procedure TPaxInvoke.AddArgAsInt64(value: Int64);
begin
  base_invoke.AddArgByVal(value, SizeOf(Int64));
end;

procedure TPaxInvoke.AddArgAsBoolean(value: Boolean);
begin
  base_invoke.AddArg(Integer(value), __typeINTEGER);
end;

procedure TPaxInvoke.AddArgAsWordBool(value: WordBool);
begin
  base_invoke.AddArg(Integer(value), __typeINTEGER);
end;

procedure TPaxInvoke.AddArgAsLongBool(value: LongBool);
begin
  base_invoke.AddArg(Integer(value), __typeINTEGER);
end;

procedure TPaxInvoke.AddArgAsChar(value: Char);
begin
  base_invoke.AddArg(Integer(value), __typeINTEGER);
end;

procedure TPaxInvoke.AddArgAsWideChar(value: WideChar);
begin
  base_invoke.AddArg(Integer(value), __typeINTEGER);
end;

procedure TPaxInvoke.AddArgAsDouble(value: Double);
begin
  base_invoke.AddArgByVal(value, SizeOf(Double));
end;

procedure TPaxInvoke.AddArgAsSingle(value: Single);
begin
  base_invoke.AddArgByVal(value, SizeOf(Single));
end;

procedure TPaxInvoke.AddArgAsExtended(value: Extended);
begin
  base_invoke.AddArgByVal(value, SizeOf(Extended));
end;

procedure TPaxInvoke.AddArgAsCurrency(value: Currency);
begin
  base_invoke.AddArgByVal(value, SizeOf(Currency));
end;

procedure TPaxInvoke.AddArgAsAnsiString(const value: AnsiString);
begin
  base_invoke.AddArg(Integer(value), __typeINTEGER);
end;

procedure TPaxInvoke.AddArgAsWideString(const value: WideString);
begin
  base_invoke.AddArg(Integer(value), __typeINTEGER);
end;

procedure TPaxInvoke.AddArgAsShortString(const value: ShortString);
begin
  base_invoke.AddArg(Integer(@value), __typeINTEGER);
end;

procedure TPaxInvoke.AddArgAsPChar(value: PChar);
begin
  base_invoke.AddArg(Integer(value), __typeINTEGER);
end;

procedure TPaxInvoke.AddArgAsPWideChar(value: PWideChar);
begin
  base_invoke.AddArg(Integer(value), __typeINTEGER);
end;

procedure TPaxInvoke.AddArgAsPointer(value: Pointer);
begin
  base_invoke.AddArg(Integer(value), __typeINTEGER);
end;

procedure TPaxInvoke.AddArgAsRecord(var value; Size: Integer);
begin
  if Size > 4 then
    base_invoke.AddArg(Integer(@value), __typeINTEGER)
  else
    base_invoke.AddArg(Integer(value), __typeINTEGER);
end;

procedure TPaxInvoke.AddArgAsRecordByVal(var value; Size: Integer);
begin
  base_invoke.AddArgByVal(value, Size);
end;

procedure TPaxInvoke.AddArgAsArray(var value; Size: Integer);
begin
  if Size > 4 then
    base_invoke.AddArg(Integer(@value), __typeINTEGER)
  else
    base_invoke.AddArg(Integer(value), __typeINTEGER);
end;

procedure TPaxInvoke.AddArgAsArrayByVal(var value; Size: Integer);
begin
  base_invoke.AddArgByVal(value, Size);
end;

procedure TPaxInvoke.AddArgAsDynArray(var value);
var
  P: Pointer;
  H: Integer;
begin
  P := Pointer(value);
  base_invoke.AddArg(Integer(value), __typeINTEGER);

  if P = nil then
    H := 0
  else
  begin
    Dec(Integer(P), SizeOf(Integer));
    H := Integer(P^) - 1;
  end;

  base_invoke.AddArg(H, __typeINTEGER);
end;

procedure TPaxInvoke.AddArgAsSet(var value; Size: Integer);
begin
  if Size > 4 then
    base_invoke.AddArg(Integer(@value), __typeINTEGER)
  else
    base_invoke.AddArg(Integer(value), __typeINTEGER);
end;

procedure TPaxInvoke.AddArgAsObject(value: TObject);
begin
  base_invoke.AddArg(Integer(value), __typeINTEGER);
end;

procedure TPaxInvoke.AddArgAsClassRef(value: TClass);
begin
  base_invoke.AddArg(Integer(value), __typeINTEGER);
end;

procedure TPaxInvoke.AddArgAsInterface(const value: IUnknown);
begin
  base_invoke.AddArg(Integer(value), __typeINTEGER);
end;

procedure TPaxInvoke.AddArgAsVariant(const value: Variant);
begin
  base_invoke.AddArg(value, __typeVARIANT);
end;

procedure TPaxInvoke.CallHost;
begin
  asm
    push esi;
    push edi;
    push ebx;
  end;

  base_invoke.Setup;
  base_invoke.CallHost;

  asm
    pop ebx;
    pop edi;
    pop esi;
  end;
end;

function TPaxInvoke.GetImplementation: Pointer;
begin
  result := base_invoke;
end;

procedure TPaxInvoke.SetCallConv(value: Integer);
begin
  base_invoke.CallConv := value;
end;

function TPaxInvoke.GetCallConv: Integer;
begin
  result := base_invoke.CallConv;
end;

function TPaxInvoke.GetResultPtr: Pointer;
begin
  result := base_invoke.GetResultPtr;
end;

procedure TPaxInvoke.SetResultAsVoid;
begin
  base_invoke.SetResType(__typeVOID);
  base_invoke.SetResSize(4);
end;

procedure TPaxInvoke.SetResultAsByte;
begin
  base_invoke.SetResType(__typeINTEGER);
  base_invoke.SetResSize(SizeOf(Byte));
end;

procedure TPaxInvoke.SetResultAsWord;
begin
  base_invoke.SetResType(__typeINTEGER);
  base_invoke.SetResSize(SizeOf(Word));
end;

procedure TPaxInvoke.SetResultAsCardinal;
begin
  base_invoke.SetResType(__typeINTEGER);
  base_invoke.SetResSize(SizeOf(Cardinal));
end;

procedure TPaxInvoke.SetResultAsShortInt;
begin
  base_invoke.SetResType(__typeINTEGER);
  base_invoke.SetResSize(SizeOf(ShortInt));
end;

procedure TPaxInvoke.SetResultAsSmallInt;
begin
  base_invoke.SetResType(__typeINTEGER);
  base_invoke.SetResSize(SizeOf(SmallInt));
end;

procedure TPaxInvoke.SetResultAsInteger;
begin
  base_invoke.SetResType(__typeINTEGER);
  base_invoke.SetResSize(SizeOf(Integer));
end;

procedure TPaxInvoke.SetResultAsBoolean;
begin
  base_invoke.SetResType(__typeINTEGER);
  base_invoke.SetResSize(SizeOf(Boolean));
end;

procedure TPaxInvoke.SetResultAsWordBool;
begin
  base_invoke.SetResType(__typeINTEGER);
  base_invoke.SetResSize(SizeOf(WordBool));
end;

procedure TPaxInvoke.SetResultAsLongBool;
begin
  base_invoke.SetResType(__typeINTEGER);
  base_invoke.SetResSize(SizeOf(LongBool));
end;

procedure TPaxInvoke.SetResultAsChar;
begin
  base_invoke.SetResType(__typeINTEGER);
  base_invoke.SetResSize(SizeOf(Char));
end;

procedure TPaxInvoke.SetResultAsWideChar;
begin
  base_invoke.SetResType(__typeINTEGER);
  base_invoke.SetResSize(SizeOf(WideChar));
end;

procedure TPaxInvoke.SetResultAsDouble;
begin
  base_invoke.SetResType(__typeDOUBLE);
  base_invoke.SetResSize(SizeOf(Double));
end;

procedure TPaxInvoke.SetResultAsSingle;
begin
  base_invoke.SetResType(__typeSINGLE);
  base_invoke.SetResSize(SizeOf(Single));
end;

procedure TPaxInvoke.SetResultAsExtended;
begin
  base_invoke.SetResType(__typeEXTENDED);
  base_invoke.SetResSize(SizeOf(Extended));
end;

procedure TPaxInvoke.SetResultAsCurrency;
begin
  base_invoke.SetResType(__typeCURRENCY);
  base_invoke.SetResSize(SizeOf(Currency));
end;

procedure TPaxInvoke.SetResultAsAnsiString;
begin
  base_invoke.SetResType(__typeSTRING);
  base_invoke.SetResSize(SizeOf(String));
end;

procedure TPaxInvoke.SetResultAsWideString;
begin
  base_invoke.SetResType(__typeWIDESTRING);
  base_invoke.SetResSize(SizeOf(WideString));
end;

procedure TPaxInvoke.SetResultAsShortString;
begin
  base_invoke.SetResType(__typeSHORTSTRING);
  base_invoke.SetResSize(SizeOf(Pointer));
end;

procedure TPaxInvoke.SetResultAsPChar;
begin
  base_invoke.SetResType(__typeINTEGER);
  base_invoke.SetResSize(SizeOf(Pointer));
end;

procedure TPaxInvoke.SetResultAsPWideChar;
begin
  base_invoke.SetResType(__typeINTEGER);
  base_invoke.SetResSize(SizeOf(Pointer));
end;

procedure TPaxInvoke.SetResultAsPointer;
begin
  base_invoke.SetResType(__typeINTEGER);
  base_invoke.SetResSize(SizeOf(Pointer));
end;

procedure TPaxInvoke.SetResultAsArray(Size: Integer);
begin
  if Size > 4 then
  begin
    base_invoke.SetResType(__typeARRAY);
    base_invoke.SetResSize(Size);
  end
  else
  begin
    base_invoke.SetResType(__typeINTEGER);
    base_invoke.SetResSize(SizeOf(Pointer));
  end;
end;

procedure TPaxInvoke.SetResultAsDynArray;
begin
  base_invoke.SetResType(__typeDYNARRAY);
  base_invoke.SetResSize(SizeOf(Pointer));
end;

procedure TPaxInvoke.SetResultAsRecord(Size: Integer);
begin
  if Size > 4 then
  begin
    base_invoke.SetResType(__typeRECORD);
    base_invoke.SetResSize(Size);
  end
  else
  begin
    base_invoke.SetResType(__typeINTEGER);
    base_invoke.SetResSize(SizeOf(Pointer));
  end;
end;

procedure TPaxInvoke.SetResultAsObject;
begin
  base_invoke.SetResType(__typeINTEGER);
  base_invoke.SetResSize(SizeOf(Pointer));
end;

procedure TPaxInvoke.SetResultAsClassRef;
begin
  base_invoke.SetResType(__typeINTEGER);
  base_invoke.SetResSize(SizeOf(Pointer));
end;

procedure TPaxInvoke.SetResultAsInterface;
begin
  base_invoke.SetResType(__typeINTERFACE);
  base_invoke.SetResSize(SizeOf(Pointer));
end;

procedure TPaxInvoke.SetResultAsInt64;
begin
  base_invoke.SetResType(__typeINT64);
  base_invoke.SetResSize(SizeOf(Int64));
end;

function TPaxInvoke.GetThis: Pointer;
begin
  result := base_invoke.GetThis;
end;

procedure TPaxInvoke.SetThis(value: Pointer);
begin
  base_invoke.SetThis(value);
end;

procedure TPaxInvoke.ClearResult;
begin
  base_invoke.ClearResult;
end;

end.
