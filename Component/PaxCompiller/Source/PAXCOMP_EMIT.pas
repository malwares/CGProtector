// PaxCompiler
// Site: http://www.paxcompiler.com
// Author: Alexander Baranovsky (paxscript@gmail.com)
// ========================================================================
// Copyright (c) Alexander Baranovsky, 2006-2008. All rights reserved.
// Code Version: 2.4
// ========================================================================
// Unit: PAXCOMP_EMIT.pas
// ========================================================================
////////////////////////////////////////////////////////////////////////////

{$I PaxCompiler.def}
{$R-}
unit PAXCOMP_EMIT;
interface
uses
  SysUtils,
  Classes,
  PAXCOMP_CONSTANTS,
  PAXCOMP_SYS,
  PAXCOMP_BYTECODE,
  PAXCOMP_MODULE,
  PAXCOMP_SYMBOL_REC,
  PAXCOMP_BASESYMBOL_TABLE,
  PAXCOMP_SYMBOL_TABLE,
  PAXCOMP_SYMBOL_PROGRAM;
type
  TRegisters = class
  private
    A: array[_NOREG.._EDI] of Boolean;
  public
    constructor Create;
    function GetReg: Integer; overload;
    procedure GetReg(Reg: Integer); overload;
    procedure FreeReg(Reg: Integer);
  end;

  TEmitter = class
  private
    kernel: Pointer;
    R: TCodeRec;
    Prg: TSymbolProg;

    Registers: TRegisters;

    ContextStack: TIntegerStack;

    List1: TList;
    List2: TList;
    List3: TList;

    EmitOff: Boolean;
    HandlesEvents: Boolean;
    OverflowCheck: Boolean;

    function GetSymbolRec(Id: Integer): TSymbolRec;
    function SymbolTable: TSymbolTable;
    function GetOperName: String;
    procedure EmitPCodeOperator;
    function Lookup(const S: String): Integer;
    procedure UpdateReg(var Reg: Integer);
    function GetLanguage: Integer;

    function IsLocalPos: Boolean;

    procedure EmitCheckOperResult(Reg: Integer);

    procedure Emit_PUSH_REGS(SubId: Integer = 0);
    procedure Emit_POP_REGS(SubId: Integer = 0);

    procedure Emit_PUSH_REGS_EX;
    procedure Emit_POP_REGS_EX;

    procedure EmitOP_SEPARATOR(I: Integer);

    procedure EmitOP_EMIT_ON;
    procedure EmitOP_EMIT_OFF;

    procedure EmitOP_PUSH_ADDRESS;
    procedure EmitOP_PUSH_STRUCTURE;
    procedure EmitOP_PUSH_SET;

    procedure EmitOP_PUSH_INT_IMM;
    procedure EmitOP_PUSH_INT;
    procedure EmitOP_PUSH_INT64;
    procedure EmitOP_PUSH_DOUBLE;
    procedure EmitOP_PUSH_CURRENCY;
    procedure EmitOP_PUSH_SINGLE;
    procedure EmitOP_PUSH_EXTENDED;
    procedure EmitOP_PUSH_ANSISTRING;
    procedure EmitOP_PUSH_WIDESTRING;
    procedure EmitOP_PUSH_UNICSTRING;
    procedure EmitOP_PUSH_SHORTSTRING;
    procedure EmitOP_PUSH_PANSICHAR_IMM;
    procedure EmitOP_PUSH_PWIDECHAR_IMM;
    procedure EmitOP_PUSH_INST;
    procedure EmitOP_PUSH_CLSREF;
    procedure EmitOP_UPDATE_INSTANCE;
    procedure EmitOP_CLEAR_EDX;
    procedure EmitOP_PUSH_DYNARRAY;
    procedure EmitOP_PUSH_DATA;
    procedure EmitOP_PUSH_EVENT;

    procedure EmitOP_CALL;
    procedure EmitOP_BEGIN_CALL;

    procedure EmitOP_CURRENCY_FROM_INT;
    procedure EmitOP_CURRENCY_FROM_INT64;
    procedure EmitOP_CURRENCY_FROM_REAL;

    procedure EmitOP_ASSIGN_INT_I;
    procedure EmitOP_ASSIGN_INT_M;
    procedure EmitOP_ASSIGN_PANSICHAR;
    procedure EmitOP_ASSIGN_PWIDECHAR;
    procedure EmitOP_ASSIGN_DOUBLE;
    procedure EmitOP_ASSIGN_CURRENCY;
    procedure EmitOP_ASSIGN_EVENT;
    procedure EmitOP_ASSIGN_SINGLE;
    procedure EmitOP_ASSIGN_EXTENDED;
    procedure EmitOP_ASSIGN_INT64;
    procedure EmitOP_ASSIGN_RECORD;
    procedure EmitOP_ASSIGN_RECORD_EX;
    procedure EmitOP_ASSIGN_INTERFACE;

    procedure EmitOP_CREATE_EVENT;

    procedure EmitOP_INT_FROM_INT64;
    procedure EmitOP_BYTE_FROM_INT64;
    procedure EmitOP_WORD_FROM_INT64;
    procedure EmitOP_CARDINAL_FROM_INT64;
    procedure EmitOP_SMALLINT_FROM_INT64;
    procedure EmitOP_SHORTINT_FROM_INT64;

    procedure EmitOP_ADD_INT64;
    procedure EmitOP_SUB_INT64;
    procedure EmitOP_AND_INT64;
    procedure EmitOP_OR_INT64;
    procedure EmitOP_XOR_INT64;
    procedure EmitOP_ABS_INT64;

    procedure EmitOP_LT_INT64;
    procedure EmitOP_LE_INT64;
    procedure EmitOP_GT_INT64;
    procedure EmitOP_GE_INT64;
    procedure EmitOP_EQ_INT64;
    procedure EmitOP_NE_INT64;

    procedure EmitOP_EQ_STRUCT;
    procedure EmitOP_NE_STRUCT;

    procedure EmitOP_ADD_CURRENCY;
    procedure EmitOP_SUB_CURRENCY;
    procedure EmitOP_MUL_CURRENCY;
    procedure EmitOP_DIV_CURRENCY;

    procedure EmitOP_ADD_INT_MI;
    procedure EmitOP_ADD_INT_MM;
    procedure EmitOP_ADD_DOUBLE;
    procedure EmitOP_ADD_SINGLE;
    procedure EmitOP_ADD_EXTENDED;

    procedure EmitOP_SUB_INT_MI;
    procedure EmitOP_SUB_INT_MM;
    procedure EmitOP_SUB_DOUBLE;
    procedure EmitOP_SUB_SINGLE;
    procedure EmitOP_SUB_EXTENDED;

    procedure EmitOP_NEG_INT;
    procedure EmitOP_NEG_INT64;
    procedure EmitOP_NOT;
    procedure EmitOP_NEG_DOUBLE;
    procedure EmitOP_NEG_CURRENCY;
    procedure EmitOP_NEG_SINGLE;
    procedure EmitOP_NEG_EXTENDED;

    procedure EmitOP_ABS_INT;
    procedure EmitOP_ABS_DOUBLE;
    procedure EmitOP_ABS_SINGLE;
    procedure EmitOP_ABS_EXTENDED;

    procedure EmitOP_IMUL_INT_MI;
    procedure EmitOP_IMUL_INT_MM;
    procedure EmitOP_MUL_DOUBLE;
    procedure EmitOP_MUL_SINGLE;
    procedure EmitOP_MUL_EXTENDED;

    procedure EmitOP_IDIV_INT_MI;
    procedure EmitOP_IDIV_INT_MM;
    procedure EmitOP_IDIV_INT_IM;
    procedure EmitOP_DIV_DOUBLE;
    procedure EmitOP_DIV_SINGLE;
    procedure EmitOP_DIV_EXTENDED;

    procedure EmitOP_MOD_INT_MI;
    procedure EmitOP_MOD_INT_MM;
    procedure EmitOP_MOD_INT_IM;

    procedure EmitOP_SHL_INT_MI;
    procedure EmitOP_SHL_INT_MM;
    procedure EmitOP_SHL_INT_IM;

    procedure EmitOP_SHR_INT_MI;
    procedure EmitOP_SHR_INT_MM;
    procedure EmitOP_SHR_INT_IM;

    procedure EmitOP_AND_INT_MI;
    procedure EmitOP_AND_INT_MM;
    procedure EmitOP_OR_INT_MI;
    procedure EmitOP_OR_INT_MM;
    procedure EmitOP_XOR_INT_MI;
    procedure EmitOP_XOR_INT_MM;

    procedure EmitOP_LT_INT_MI;
    procedure EmitOP_LT_INT_MM;

    procedure EmitOP_LE_INT_MI;
    procedure EmitOP_LE_INT_MM;

    procedure EmitOP_GT_INT_MI;
    procedure EmitOP_GT_INT_MM;

    procedure EmitOP_GE_INT_MI;
    procedure EmitOP_GE_INT_MM;

    procedure EmitOP_EQ_INT_MI;
    procedure EmitOP_EQ_INT_MM;

    procedure EmitOP_NE_INT_MI;
    procedure EmitOP_NE_INT_MM;

    procedure EmitOP_LT_DOUBLE;
    procedure EmitOP_LE_DOUBLE;
    procedure EmitOP_GT_DOUBLE;
    procedure EmitOP_GE_DOUBLE;
    procedure EmitOP_EQ_DOUBLE;
    procedure EmitOP_NE_DOUBLE;

    procedure EmitOP_LT_CURRENCY;
    procedure EmitOP_LE_CURRENCY;
    procedure EmitOP_GT_CURRENCY;
    procedure EmitOP_GE_CURRENCY;
    procedure EmitOP_EQ_CURRENCY;
    procedure EmitOP_NE_CURRENCY;

    procedure EmitOP_LT_SINGLE;
    procedure EmitOP_LE_SINGLE;
    procedure EmitOP_GT_SINGLE;
    procedure EmitOP_GE_SINGLE;
    procedure EmitOP_EQ_SINGLE;
    procedure EmitOP_NE_SINGLE;

    procedure EmitOP_LT_EXTENDED;
    procedure EmitOP_LE_EXTENDED;
    procedure EmitOP_GT_EXTENDED;
    procedure EmitOP_GE_EXTENDED;
    procedure EmitOP_EQ_EXTENDED;
    procedure EmitOP_NE_EXTENDED;

    procedure EmitOP_INIT_SUB;
    procedure EmitOP_END_SUB;
    procedure EmitOP_FIN_SUB;
    procedure EmitOP_RET;
    procedure EmitOP_PUSH_EBP;
    procedure EmitOP_POP;
    procedure EmitOP_SAVE_REGS;
    procedure EmitOP_RESTORE_REGS;

    procedure EmitOP_FIELD;
    procedure EmitOP_ELEM;

    procedure EmitOP_PRINT_EX;

    procedure EmitOP_INT_TO_INT64;
    procedure EmitOP_BYTE_TO_INT64;
    procedure EmitOP_WORD_TO_INT64;
    procedure EmitOP_CARDINAL_TO_INT64;
    procedure EmitOP_SMALLINT_TO_INT64;
    procedure EmitOP_SHORTINT_TO_INT64;

    procedure EmitOP_INT_TO_DOUBLE;
    procedure EmitOP_INT64_TO_DOUBLE;

    procedure EmitOP_INT_TO_SINGLE;
    procedure EmitOP_INT64_TO_SINGLE;

    procedure EmitOP_INT_TO_EXTENDED;
    procedure EmitOP_INT64_TO_EXTENDED;

    procedure EmitOP_MULT_INT64;
    procedure EmitOP_IDIV_INT64;
    procedure EmitOP_MOD_INT64;

    procedure EmitOP_CURRENCY_TO_EXTENDED;
    procedure EmitOP_CURRENCY_TO_SINGLE;
    procedure EmitOP_DOUBLE_TO_SINGLE;
    procedure EmitOP_DOUBLE_TO_EXTENDED;
    procedure EmitOP_SINGLE_TO_DOUBLE;
    procedure EmitOP_CURRENCY_TO_DOUBLE;
    procedure EmitOP_SINGLE_TO_EXTENDED;
    procedure EmitOP_EXTENDED_TO_DOUBLE;
    procedure EmitOP_EXTENDED_TO_SINGLE;

    procedure EmitOP_GO;
    procedure EmitOP_GO_TRUE;
    procedure EmitOP_GO_FALSE;
    procedure EmitOP_GO_DL;

    procedure EmitOP_SAVE_EDX;
    procedure EmitOP_RESTORE_EDX;

    procedure EmitOP_ADDRESS;
    procedure EmitOP_TERMINAL;
    procedure EmitOP_ADDRESS_PROG;
    procedure EmitOP_ASSIGN_PROG;

    procedure EmitOP_SET_INCLUDE;
    procedure EmitOP_SET_INCLUDE_INTERVAL;
    procedure EmitOP_SET_EXCLUDE;
    procedure EmitOP_SET_UNION;
    procedure EmitOP_SET_DIFFERENCE;
    procedure EmitOP_SET_INTERSECTION;
    procedure EmitOP_SET_SUBSET;
    procedure EmitOP_SET_SUPERSET;
    procedure EmitOP_SET_EQUALITY;
    procedure EmitOP_SET_INEQUALITY;
    procedure EmitOP_SET_MEMBERSHIP;
    procedure EmitOP_SET_ASSIGN;

    procedure EmitOP_ERR_ABSTRACT;

    procedure EmitOP_LOAD_PROC;

    procedure EmitOP_BEGIN_CRT_JS_FUNC_OBJECT;
    procedure EmitOP_END_CRT_JS_FUNC_OBJECT;

    procedure EmitOP_TO_JS_OBJECT;
    procedure EmitOP_JS_TYPEOF;
    procedure EmitOP_JS_VOID;
    procedure EmitOP_GET_NEXTJSPROP;
    procedure EmitOP_CLEAR_REFERENCES;

    procedure EmitOP_CREATE_METHOD;

    procedure EmitOP_INIT_PCHAR_LITERAL;
    procedure EmitOP_INIT_PWIDECHAR_LITERAL;
    procedure EmitOP_ANSISTRING_FROM_PANSICHAR;
    procedure EmitOP_ANSISTRING_FROM_PWIDECHAR;
    procedure EmitOP_ANSISTRING_FROM_ANSICHAR;
    procedure EmitOP_ASSIGN_ANSISTRING;
    procedure EmitOP_ASSIGN_SHORTSTRING;
    procedure EmitOP_ASSIGN_WIDESTRING;
    procedure EmitOP_ASSIGN_UNICSTRING;
    procedure EmitOP_ADD_ANSISTRING;
    procedure EmitOP_ADD_SHORTSTRING;
    procedure EmitOP_ADD_WIDESTRING;
    procedure EmitOP_ADD_UNICSTRING;
    procedure EmitOP_SET_LENGTH;
    procedure EmitOP_ANSISTRING_CLR;
    procedure EmitOP_WIDESTRING_CLR;
    procedure EmitOP_UNICSTRING_CLR;
    procedure EmitOP_INTERFACE_CLR;
    procedure EmitOP_STRUCTURE_CLR;
    procedure EmitOP_CLASS_CLR;
    procedure EmitOP_STRUCTURE_ADDREF;
    procedure EmitOP_DYNARRAY_CLR;
    procedure EmitOP_DYNARRAY_HIGH;
    procedure EmitOP_DYNARRAY_ASSIGN;
    procedure EmitOP_CREATE_EMPTY_DYNARRAY;

    procedure EmitOP_ASSIGN_TVarRec;

    procedure EmitOP_SHORTSTRING_FROM_PANSICHAR_LITERAL;
    procedure EmitOP_SHORTSTRING_FROM_PWIDECHAR_LITERAL;
    procedure EmitOP_SHORTSTRING_FROM_ANSICHAR;
    procedure EmitOP_SHORTSTRING_FROM_WIDECHAR;
    procedure EmitOP_SHORTSTRING_FROM_ANSISTRING;
    procedure EmitOP_SHORTSTRING_FROM_WIDESTRING;
    procedure EmitOP_UNICSTRING_FROM_WIDESTRING;
    procedure EmitOP_SHORTSTRING_FROM_UNICSTRING;
    procedure EmitOP_ANSISTRING_FROM_SHORTSTRING;

    procedure EmitOP_WIDESTRING_FROM_PANSICHAR_LITERAL;
    procedure EmitOP_WIDESTRING_FROM_PWIDECHAR_LITERAL;
    procedure EmitOP_WIDESTRING_FROM_ANSICHAR;
    procedure EmitOP_WIDESTRING_FROM_WIDECHAR;
    procedure EmitOP_ANSISTRING_FROM_WIDECHAR;
    procedure EmitOP_WIDESTRING_FROM_WIDECHAR_LITERAL;
    procedure EmitOP_WIDESTRING_FROM_ANSISTRING;
    procedure EmitOP_UNICSTRING_FROM_ANSISTRING;
    procedure EmitOP_WIDESTRING_FROM_SHORTSTRING;
    procedure EmitOP_WIDESTRING_FROM_UNICSTRING;
    procedure EmitOP_UNICSTRING_FROM_SHORTSTRING;
    procedure EmitOP_ANSISTRING_FROM_WIDESTRING;
    procedure EmitOP_ANSISTRING_FROM_UNICSTRING;

    procedure EmitOP_UNICSTRING_FROM_PANSICHAR_LITERAL;
    procedure EmitOP_UNICSTRING_FROM_PWIDECHAR_LITERAL;
    procedure EmitOP_UNICSTRING_FROM_ANSICHAR;
    procedure EmitOP_UNICSTRING_FROM_WIDECHAR;
    procedure EmitOP_UNICSTRING_FROM_WIDECHAR_LITERAL;

    procedure EmitOP_SHORTSTRING_HIGH;

    procedure EmitOP_EQ_ANSISTRING;
    procedure EmitOP_NE_ANSISTRING;
    procedure EmitOP_EQ_SHORTSTRING;
    procedure EmitOP_NE_SHORTSTRING;
    procedure EmitOP_EQ_WIDESTRING;
    procedure EmitOP_EQ_UNICSTRING;
    procedure EmitOP_NE_WIDESTRING;
    procedure EmitOP_NE_UNICSTRING;

    procedure EmitOP_GT_ANSISTRING;
    procedure EmitOP_GE_ANSISTRING;
    procedure EmitOP_LT_ANSISTRING;
    procedure EmitOP_LE_ANSISTRING;

    procedure EmitOP_GT_SHORTSTRING;
    procedure EmitOP_GE_SHORTSTRING;
    procedure EmitOP_LT_SHORTSTRING;
    procedure EmitOP_LE_SHORTSTRING;

    procedure EmitOP_GT_WIDESTRING;
    procedure EmitOP_GE_WIDESTRING;
    procedure EmitOP_LT_WIDESTRING;
    procedure EmitOP_LE_WIDESTRING;

    procedure EmitOP_GT_UNICSTRING;
    procedure EmitOP_GE_UNICSTRING;
    procedure EmitOP_LT_UNICSTRING;
    procedure EmitOP_LE_UNICSTRING;

    procedure EmitOP_VARIANT_FROM_CLASS; // JS only
    procedure EmitOP_VARIANT_FROM_POINTER; //JS only
    procedure EmitOP_CLASS_FROM_VARIANT; // JS only

    procedure EmitOP_INTERFACE_FROM_CLASS;
    procedure EmitOP_INTERFACE_CAST;

    procedure EmitOP_VARIANT_CLR;
    procedure EmitOP_ASSIGN_VARIANT;
    procedure EmitOP_ASSIGN_OLEVARIANT;

    procedure EmitOP_ASSIGN_CLASS;

    procedure EmitOP_VARIANT_FROM_PANSICHAR_LITERAL;
    procedure EmitOP_VARIANT_FROM_PWIDECHAR_LITERAL;
    procedure EmitOP_VARIANT_FROM_ANSISTRING;
    procedure EmitOP_VARIANT_FROM_WIDESTRING;
    procedure EmitOP_VARIANT_FROM_UNICSTRING;
    procedure EmitOP_VARIANT_FROM_SHORTSTRING;
    procedure EmitOP_VARIANT_FROM_ANSICHAR;
    procedure EmitOP_VARIANT_FROM_WIDECHAR;
    procedure EmitOP_VARIANT_FROM_WIDECHAR_LITERAL;
    procedure EmitOP_VARIANT_FROM_INT;
    procedure EmitOP_VARIANT_FROM_INT64;
    procedure EmitOP_VARIANT_FROM_BYTE;
    procedure EmitOP_VARIANT_FROM_BOOL;
    procedure EmitOP_VARIANT_FROM_WORD;
    procedure EmitOP_VARIANT_FROM_CARDINAL;
    procedure EmitOP_VARIANT_FROM_SMALLINT;
    procedure EmitOP_VARIANT_FROM_SHORTINT;
    procedure EmitOP_VARIANT_FROM_DOUBLE;
    procedure EmitOP_VARIANT_FROM_CURRENCY;
    procedure EmitOP_VARIANT_FROM_SINGLE;
    procedure EmitOP_VARIANT_FROM_EXTENDED;
    procedure EmitOP_VARIANT_FROM_INTERFACE;

    procedure EmitOP_OLEVARIANT_FROM_VARIANT;
    procedure EmitOP_OLEVARIANT_FROM_PANSICHAR_LITERAL;
    procedure EmitOP_OLEVARIANT_FROM_PWIDECHAR_LITERAL;
    procedure EmitOP_OLEVARIANT_FROM_ANSISTRING;
    procedure EmitOP_OLEVARIANT_FROM_WIDESTRING;
    procedure EmitOP_OLEVARIANT_FROM_UNICSTRING;
    procedure EmitOP_OLEVARIANT_FROM_SHORTSTRING;
    procedure EmitOP_OLEVARIANT_FROM_ANSICHAR;
    procedure EmitOP_OLEVARIANT_FROM_WIDECHAR;
    procedure EmitOP_OLEVARIANT_FROM_WIDECHAR_LITERAL;
    procedure EmitOP_OLEVARIANT_FROM_INT;
    procedure EmitOP_OLEVARIANT_FROM_INT64;
    procedure EmitOP_OLEVARIANT_FROM_BYTE;
    procedure EmitOP_OLEVARIANT_FROM_BOOL;
    procedure EmitOP_OLEVARIANT_FROM_WORD;
    procedure EmitOP_OLEVARIANT_FROM_CARDINAL;
    procedure EmitOP_OLEVARIANT_FROM_SMALLINT;
    procedure EmitOP_OLEVARIANT_FROM_SHORTINT;
    procedure EmitOP_OLEVARIANT_FROM_DOUBLE;
    procedure EmitOP_OLEVARIANT_FROM_CURRENCY;
    procedure EmitOP_OLEVARIANT_FROM_SINGLE;
    procedure EmitOP_OLEVARIANT_FROM_EXTENDED;
    procedure EmitOP_OLEVARIANT_FROM_INTERFACE;

    procedure EmitOP_ANSISTRING_FROM_INT; // JS only
    procedure EmitOP_ANSISTRING_FROM_DOUBLE; // JS only
    procedure EmitOP_ANSISTRING_FROM_SINGLE; // JS only
    procedure EmitOP_ANSISTRING_FROM_EXTENDED; // JS only
    procedure EmitOP_ANSISTRING_FROM_BOOLEAN; // JS only

    procedure EmitOP_UNICSTRING_FROM_INT; // JS only
    procedure EmitOP_UNICSTRING_FROM_DOUBLE; // JS only
    procedure EmitOP_UNICSTRING_FROM_SINGLE; // JS only
    procedure EmitOP_UNICSTRING_FROM_EXTENDED; // JS only
    procedure EmitOP_UNICSTRING_FROM_BOOLEAN; // JS only

    procedure EmitOP_JS_FUNC_OBJ_FROM_VARIANT; // JS only

    procedure EmitOP_ANSISTRING_FROM_VARIANT;
    procedure EmitOP_WIDESTRING_FROM_VARIANT;
    procedure EmitOP_UNICSTRING_FROM_VARIANT;
    procedure EmitOP_SHORTSTRING_FROM_VARIANT;
    procedure EmitOP_DOUBLE_FROM_VARIANT;
    procedure EmitOP_CURRENCY_FROM_VARIANT;
    procedure EmitOP_SINGLE_FROM_VARIANT;
    procedure EmitOP_EXTENDED_FROM_VARIANT;
    procedure EmitOP_INT_FROM_VARIANT;
    procedure EmitOP_INT64_FROM_VARIANT;
    procedure EmitOP_BYTE_FROM_VARIANT;
    procedure EmitOP_WORD_FROM_VARIANT;
    procedure EmitOP_CARDINAL_FROM_VARIANT;
    procedure EmitOP_BOOL_FROM_VARIANT;
    procedure EmitOP_BYTEBOOL_FROM_VARIANT;
    procedure EmitOP_WORDBOOL_FROM_VARIANT;
    procedure EmitOP_LONGBOOL_FROM_VARIANT;
    procedure EmitOP_SMALLINT_FROM_VARIANT;
    procedure EmitOP_SHORTINT_FROM_VARIANT;

    procedure EmitOP_NEG_VARIANT;
    procedure EmitOP_ABS_VARIANT;
    procedure EmitOP_NOT_VARIANT;
    procedure EmitOP_ADD_VARIANT;
    procedure EmitOP_SUB_VARIANT;
    procedure EmitOP_MULT_VARIANT;
    procedure EmitOP_DIV_VARIANT;
    procedure EmitOP_IDIV_VARIANT;
    procedure EmitOP_MOD_VARIANT;
    procedure EmitOP_SHL_VARIANT;
    procedure EmitOP_SHR_VARIANT;
    procedure EmitOP_AND_VARIANT;
    procedure EmitOP_OR_VARIANT;
    procedure EmitOP_XOR_VARIANT;
    procedure EmitOP_LT_VARIANT;
    procedure EmitOP_LE_VARIANT;
    procedure EmitOP_GT_VARIANT;
    procedure EmitOP_GE_VARIANT;
    procedure EmitOP_EQ_VARIANT;
    procedure EmitOP_NE_VARIANT;

    procedure EmitOP_VARARRAY_GET;
    procedure EmitOP_VARARRAY_PUT;

    procedure EmitOP_OLE_GET;
    procedure EmitOP_OLE_SET;
    procedure EmitOP_OLE_PARAM;

    procedure EmitOP_GENERAL_GET;
    procedure EmitOP_GENERAL_PUT;

    procedure EmitOP_ONCREATE_OBJECT;
    procedure EmitOP_ON_AFTER_OBJECT_CREATION;

    procedure EmitOP_IS;
    procedure EmitOP_CLASSNAME;
    procedure EmitOP_TYPEINFO;

    procedure EmitOP_PUSH_CONTEXT;
    procedure EmitOP_POP_CONTEXT;
    procedure EmitOP_FIND_CONTEXT;
    procedure EmitOP_FIND_JS_FUNC;

    procedure EmitOP_GET_PROG;

    procedure EmitOP_GET_ANSISTR_PROP;
    procedure EmitOP_SET_ANSISTR_PROP;

    procedure EmitOP_GET_WIDESTR_PROP;
    procedure EmitOP_SET_WIDESTR_PROP;

    procedure EmitOP_GET_UNICSTR_PROP;
    procedure EmitOP_SET_UNICSTR_PROP;

    procedure EmitOP_GET_ORD_PROP;
    procedure EmitOP_SET_ORD_PROP;

    procedure EmitOP_GET_INTERFACE_PROP;
    procedure EmitOP_SET_INTERFACE_PROP;

    procedure EmitOP_GET_SET_PROP;
    procedure EmitOP_SET_SET_PROP;

    procedure EmitOP_GET_FLOAT_PROP;
    procedure EmitOP_SET_FLOAT_PROP;

    procedure EmitOP_GET_VARIANT_PROP;
    procedure EmitOP_SET_VARIANT_PROP;

    procedure EmitOP_GET_INT64_PROP;
    procedure EmitOP_SET_INT64_PROP;

    procedure EmitOP_GET_EVENT_PROP;
    procedure EmitOP_SET_EVENT_PROP;
    procedure EmitOP_SET_EVENT_PROP2;

    procedure EmitOP_TRY_ON;
    procedure EmitOP_TRY_OFF;
    procedure EmitOP_FINALLY;
    procedure EmitOP_EXCEPT;
    procedure EmitOP_EXCEPT_ON;
    procedure EmitOP_RAISE;
    procedure EmitOP_EXIT;
    procedure EmitOP_COND_RAISE;
    procedure EmitOP_BEGIN_EXCEPT_BLOCK;
    procedure EmitOP_END_EXCEPT_BLOCK;

    procedure EmitOP_OVERFLOW_CHECK;

    procedure EmitOP_PAUSE;
    procedure EmitOP_CHECK_PAUSE;
    procedure EmitOP_CHECK_PAUSE_LIGHT;
    procedure EmitOP_HALT;

    procedure EmitOP_CHECK_INIT_ONLY;
    procedure EmitOP_CHECK_BODY_ONLY;

    procedure EmitOP_CREATE_OBJECT;
    procedure EmitOP_DESTROY_OBJECT;
    procedure EmitOP_GET_VMT_ADDRESS;

    procedure EmitJmp;

    procedure EmitFLD(S: TSymbolRec);
    procedure EmitFSTP(S: TSymbolRec);

    procedure EmitFild(S: TSymbolRec);
    procedure EmitFistp(S: TSymbolRec);

    procedure EmitFDiv_10000;
    procedure EmitFMul_10000;

    procedure EmitLoadAddress(Reg: Integer; S: TSymbolRec);

    function HasTheSameAddressRegister(S1, S2: TSymbolRec): Boolean; // see next method
    function EmitGetAddressRegister(S: TSymbolRec): Integer; // this method
                   // returns a register.
                   // If it returns ESI or EBP, true address = result + S.Shift !!
                   // otherwise, address = result
                   //   Caller must free the register !!

    procedure EmitLoadIntVal(Reg: Integer; S: TSymbolRec);
    procedure EmitSaveIntVal(Reg: Integer; S: TSymbolRec);
    procedure EmitRestoreEBP(Reg: Integer; S: TSymbolRec);

    procedure EmitPut_REG(Reg: Integer; S: TSymbolRec; ExtraShift: Integer = 0);
                          // Reg contains a 32-bit value
                          // S - destination

    procedure EmitGet_REG(Reg: Integer; S: TSymbolRec; ExtraShift: Integer = 0);
                          // S - source
                          // Reg - destination

    procedure EmitLabel(LabelId: Integer; const LabelName: String);

    procedure RaiseError(const Message: string; params: array of Const);

    function Host1: Boolean;
    function Host2: Boolean;

    function ByRef1: Boolean;

    function GetReg: Integer; overload;
    procedure GetReg(Reg: Integer); overload;
    procedure FreeReg(Reg: Integer);
    function ImmValue1: Cardinal;
    function ImmValue2: Cardinal;

    function GetOffset(S: TSymbolRec): Integer;

    function SymbolRec1: TSymbolRec;
    function SymbolRec2: TSymbolRec;
    function SymbolRecR: TSymbolRec;

    procedure Emit(I: Integer);

    property OperName: String read GetOperName;
    property Language: Integer read GetLanguage;
  public
    constructor Create;
    destructor Destroy; override;
    function CreateSymbolProgram(i_kernel: Pointer): TSymbolProg;
  end;

implementation

uses
  PAXCOMP_KERNEL, PAXCOMP_STDLIB;

{$IFDEF TRIAL}
var
  _Counter: Integer = 3;
{$ENDIF}

constructor TRegisters.Create;
var
  I: Integer;
begin
  for I:=_NOREG to _EDI do
    FreeReg(I);
  A[_ESI] := true;
  A[_EDI] := true;
end;

function TRegisters.GetReg: Integer;
var
  I: Integer;
begin
  for I:=_EAX to _EDI do
    if A[I] then
    begin
      A[I] := false;
      result := I;
      Exit;
    end;
  raise Exception.Create(errInternalError);
end;

procedure TRegisters.GetReg(Reg: Integer);
begin
  if A[Reg] then
    A[Reg] := false
  else
  begin
    raise Exception.Create(errInternalError);
  end;
end;

procedure TRegisters.FreeReg(Reg: Integer);
begin
  A[Reg] := true;
end;

constructor TEmitter.Create;
begin
  inherited;
  Registers := TRegisters.Create;
  ContextStack := TIntegerStack.Create;
  List1 := TList.Create;
  List2 := TList.Create;
  List3 := TList.Create;
  OverflowCheck := true;
end;

destructor TEmitter.Destroy;
begin
  Registers.Free;
  ContextStack.Free;
  List1.Free;
  List2.Free;
  List3.Free;
  inherited;
end;

function TEmitter.IsLocalPos: Boolean;
begin
  with TKernel(kernel) do
    result := Code.IsLocalPos(Code.N);
end;

function TEmitter.GetLanguage: Integer;
begin
  with TKernel(kernel) do
  result := Code[Code.N].Language;
end;

function TEmitter.GetOperName: String;
begin
  result := Operators[- R.Op];
end;

function TEmitter.Host1: Boolean;
begin
  result := GetSymbolRec(R.Arg1).Host;
end;

function TEmitter.Host2: Boolean;
begin
  result := GetSymbolRec(R.Arg2).Host;
end;

function TEmitter.ByRef1: Boolean;
begin
  result := GetSymbolRec(R.Arg1).ByRef;
end;

function TEmitter.GetReg: Integer;
begin
  result := registers.GetReg;
end;

procedure TEmitter.GetReg(Reg: Integer);
begin
  registers.GetReg(Reg);
end;

procedure TEmitter.FreeReg(Reg: Integer);
begin
  Registers.FreeReg(Reg);
end;

function TEmitter.ImmValue1: Cardinal;
begin
  result := SymbolRec1.Value;
end;

function TEmitter.ImmValue2: Cardinal;
begin
  result := SymbolRec2.Value;
end;

function TEmitter.GetOffset(S: TSymbolRec): Integer;
begin
  result := TKernel(kernel).GetOffset(S);
end;

function TEmitter.SymbolRec1: TSymbolRec;
begin
  result := GetSymbolRec(R.Arg1);
end;

function TEmitter.SymbolRec2: TSymbolRec;
begin
  result := GetSymbolRec(R.Arg2);
end;

function TEmitter.SymbolRecR: TSymbolRec;
begin
  result := GetSymbolRec(R.Res);
end;

function TEmitter.Lookup(const S: String): Integer;
begin
  result := SymbolTable.LookUp(S, 0, false);
end;

function TEmitter.CreateSymbolProgram(i_kernel: Pointer): TSymbolProg;
var
  Code: TCode;
  I, J, ShiftValue: Integer;

  SymbolProgRec: TSymbolProgRec;
  SymbolRec: TSymbolRec;
  Modules: TModuleList;
  b: Boolean;
  K, KK: Integer;
  SZ: Integer;
begin
  Self.kernel := i_kernel;

  EmitOff := false;
  HandlesEvents := false;

  Prg := TSymbolProg.Create(kernel);
  Prg.Clear;

  result := Prg;

  Code := TKernel(kernel).Code;

  Prg.AsmJMP_Imm(0);

  for I:= 1 to Code.Card do
  begin
    R := Code.Records[I];
    if R.Op = OP_INIT_PANSICHAR_LITERAL then
    begin
      EmitOP_INIT_PCHAR_LITERAL;
      R.Op := OP_NOP;
    end
    else if R.Op = OP_INIT_PWIDECHAR_LITERAL then
    begin
      EmitOP_INIT_PWIDECHAR_LITERAL;
      R.Op := OP_NOP;
    end;
  end;

  for I:= 1 to Code.Card do
  begin
    R := Code.Records[I];
    if R.Op = OP_LOAD_PROC then
      EmitOP_LOAD_PROC;
  end;

  I := 1;
  while I < Code.Card do
  begin
    R := Code.Records[I];
    Code.N := I;
    if R.Op = OP_BEGIN_CRT_JS_FUNC_OBJECT then
    begin
      EmitOP_BEGIN_CRT_JS_FUNC_OBJECT;
      R.Op := OP_NOP;
      repeat
        Inc(I);
        R := Code.Records[I];
        Code.N := I;
        Emit(I);
        if R.Op = OP_END_CRT_JS_FUNC_OBJECT then
        begin
          R.Op := OP_NOP;
          break;
        end
        else
          R.Op := OP_NOP;
      until false;
    end;

    Inc(I);
  end;

  K := 0;
  b := false;
  for I:= 1 to Code.Card do
  begin
    R := Code.Records[I];
    if R.Op = OP_BEGIN_INIT_CONST then
    begin
      b := true;
      R.Op := OP_NOP;
      Inc(K);
    end
    else if R.Op = OP_END_INIT_CONST then
    begin
      Dec(K);
      if K = 0 then
        b := false;
      R.Op := OP_NOP;
    end
    else if b then
    begin
      Code.N := I;
      Emit(I);
      R.Op := OP_NOP;
    end;
  end;

  Modules := TKernel(kernel).Modules;
  Modules.Recalc;

  // emit initialization sections

  for J:=0 to Modules.LoadOrder.Count - 1 do
    if Modules[J].PInitBegin > 0 then
      for I:= Modules[J].PInitBegin + 1 to Modules[J].PInitEnd - 1 do
        Emit(I);

  EmitOP_CHECK_INIT_ONLY;
  for KK:=1 to MAGIC_INITIALIZATION_JMP_COUNT do
    Prg.AsmJMP_Imm(0);

  I := 1;
  while I <= Code.Card do
  begin
    R := Code.Records[I];
    Code.N := I;

    if R.Op = OP_SEPARATOR then
    begin
      EmitOP_SEPARATOR(I);
      Inc(I);
      continue;
    end
    else if R.Op = OP_EMIT_ON then
    begin
      EmitOP_EMIT_ON;
      Inc(I);
      continue;
    end
    else if R.Op = OP_EMIT_OFF then
    begin
      EmitOP_EMIT_OFF;
      Inc(I);
      continue;
    end
    else if R.Op = OP_END_INITIALIZATION then
    begin
      EmitOP_EMIT_ON;
      Inc(I);
      continue;
    end
    else if R.Op = OP_BEGIN_INITIALIZATION then
    begin
      EmitOP_EMIT_OFF;
      Inc(I);
      continue;
    end
    else if R.Op = OP_END_FINALIZATION then
    begin
      EmitOP_EMIT_ON;
      Inc(I);
      continue;
    end
    else if R.Op = OP_BEGIN_FINALIZATION then
    begin
      EmitOP_EMIT_OFF;
      Inc(I);
      continue;
    end;

    if not EmitOff then
      Emit(I);

    Inc(I);
  end;

  Prg.Optimization;

  ShiftValue := 0;
  for I:=1 to Prg.Card do
  begin
    Prg[I].ShiftValue := ShiftValue;

    J := Prg[I].LabelId;
    if J > 0 then
      SymbolTable[J].Value := ShiftValue;

    SZ := Prg[I].Size;
    if SZ > 0 then
      ShiftValue := ShiftValue + SZ;
  end;

  for I:=0 to List1.Count - 1 do
  begin
    SymbolProgRec := TSymbolProgRec(List1[I]); // record of symbol code
    ShiftValue := SymbolProgRec.ShiftValue;
    SymbolRec := TSymbolRec(List3[I]); // label
    if SymbolProgRec.Op = ASM_JMP then
    begin
      ShiftValue := SymbolRec.Value - ShiftValue - SymbolProgRec.Size;
      Move(ShiftValue, SymbolProgRec.code[1], 4);
      SymbolProgRec.Decompile;
    end
    else if SymbolProgRec.Op = ASM_PUSH then // pause
    begin
      ShiftValue := SymbolRec.Value;
      Move(ShiftValue, SymbolProgRec.code[1], 4);
      SymbolProgRec.Decompile;
    end
    else
      RaiseError(errInternalError, []);
  end;

  for I:=0 to List2.Count - 1 do
  begin
    SymbolProgRec := TSymbolProgRec(List2[I]); // record of symbol code
    ShiftValue := SymbolTable[SymbolProgRec.SaveSubId].Value;

//    if ShiftValue < 0 then
//      RaiseError(errInternalError, []);

    if SymbolProgRec.code[0] = $05 then // ADD EAX, Imm
      Move(ShiftValue, SymbolProgRec.code[1], 4)
    else
      Move(ShiftValue, SymbolProgRec.code[2], 4);

    SymbolProgRec.Decompile;
  end;
end;

procedure TEmitter.Emit(I: Integer);
var
  Code: TCode;
  J, KK: Integer;
  Modules: TModuleList;
begin
  Code := TKernel(kernel).Code;

  R := Code.Records[I];
  Code.N := I;

  if R.Op = OP_SEPARATOR then
  begin
    EmitOP_SEPARATOR(I);
  end
  else if R.Op = OP_SET_CODE_LINE then
  begin
    Prg.AsmComment('***** N ****** ' + IntToStr(Code.N));
    Prg.AsmMovREGPtr32_Imm(_ESI, H_ByteCodePtr, I);
  end
  else if R.Op = OP_EMIT_ON then
  begin
    EmitOP_EMIT_ON;
  end
  else if R.Op = OP_EMIT_OFF then
  begin
    EmitOP_EMIT_OFF;
  end
  else if R.Op = OP_NOP then
  begin
    // nothing
  end
  else if R.Op = OP_BEGIN_MODULE then
  begin
    Prg.AsmComment('Module ' + Code.GetModule(I).Name);
  end
  else if R.Op = OP_END_INTERFACE_SECTION then
  begin
    Prg.AsmComment('End of interface section of ' + Code.GetModule(I).Name);
  end
  else if R.Op = OP_END_MODULE then
  begin
    Prg.AsmComment('End of module ' + Code.GetModule(I).Name);

    EmitOP_CHECK_BODY_ONLY;
    for KK:=1 to MAGIC_FINALIZATION_JMP_COUNT do
      Prg.AsmJMP_Imm(0);

    // emit finalization sections
    Modules := TKernel(kernel).Modules;

    for J:=Modules.LoadOrder.Count - 1 downto 0 do
    if Modules[J].PFinBegin > 0 then
      for I:= Modules[J].PFinBegin + 1 to Modules[J].PFinEnd - 1 do
        Emit(I);

    Prg.AsmRet;
  end
  else if R.Op = OP_LABEL then
    EmitLabel(R.Arg1, GetSymbolRec(R.Arg1).Name)
  else if R.Op = OP_GO then
    EmitOP_GO
  else if R.Op = OP_GO_TRUE then
    EmitOP_GO_TRUE
  else if R.Op = OP_GO_FALSE then
    EmitOP_GO_FALSE
  else if R.Op = OP_GO_DL then
    EmitOP_GO_DL
  else if R.Op = OP_SAVE_EDX then
    EmitOP_SAVE_EDX
  else if R.Op = OP_RESTORE_EDX then
    EmitOP_RESTORE_EDX
  else if R.Op = OP_ASSIGN_BYTE_I then
    EmitOP_ASSIGN_INT_I
  else if R.Op = OP_ASSIGN_BYTE_M then
    EmitOP_ASSIGN_INT_M

  else if R.Op = OP_ASSIGN_WORD_I then
    EmitOP_ASSIGN_INT_I
  else if R.Op = OP_ASSIGN_WORD_M then
    EmitOP_ASSIGN_INT_M
  else if R.Op = OP_ASSIGN_CARDINAL_I then
    EmitOP_ASSIGN_INT_I
  else if R.Op = OP_ASSIGN_CARDINAL_M then
    EmitOP_ASSIGN_INT_M
  else if R.Op = OP_ASSIGN_SMALLINT_I then
    EmitOP_ASSIGN_INT_I
  else if R.Op = OP_ASSIGN_SMALLINT_M then
    EmitOP_ASSIGN_INT_M
  else if R.Op = OP_ASSIGN_SHORTINT_I then
    EmitOP_ASSIGN_INT_I
  else if R.Op = OP_ASSIGN_SHORTINT_M then
    EmitOP_ASSIGN_INT_M
  else if R.Op = OP_ASSIGN_INT_I then
    EmitOP_ASSIGN_INT_I
  else if R.Op = OP_ASSIGN_INT_M then
    EmitOP_ASSIGN_INT_M
  else if R.Op = OP_ASSIGN_PANSICHAR then
    EmitOP_ASSIGN_PANSICHAR
  else if R.Op = OP_ASSIGN_PWIDECHAR then
    EmitOP_ASSIGN_PWIDECHAR

  else if R.Op = OP_ASSIGN_EVENT then
    EmitOP_ASSIGN_EVENT
  else if R.Op = OP_CREATE_EVENT then
    EmitOP_CREATE_EVENT

  else if R.Op = OP_ASSIGN_DOUBLE then
    EmitOP_ASSIGN_DOUBLE
  else if R.Op = OP_ASSIGN_CURRENCY then
    EmitOP_ASSIGN_CURRENCY
  else if R.Op = OP_ASSIGN_SINGLE then
    EmitOP_ASSIGN_SINGLE
  else if R.Op = OP_ASSIGN_EXTENDED then
    EmitOP_ASSIGN_EXTENDED
  else if R.Op = OP_ASSIGN_INT64 then
    EmitOP_ASSIGN_INT64

  else if R.Op = OP_ASSIGN_RECORD then
    EmitOP_ASSIGN_RECORD
  else if R.Op = OP_ASSIGN_ARRAY then
    EmitOP_ASSIGN_RECORD
  else if R.Op = OP_ASSIGN_INTERFACE then
    EmitOP_ASSIGN_INTERFACE

  else if R.Op = OP_ADD_INT64 then
    EmitOP_ADD_INT64
  else if R.Op = OP_SUB_INT64 then
    EmitOP_SUB_INT64
  else if R.Op = OP_AND_INT64 then
    EmitOP_AND_INT64
  else if R.Op = OP_OR_INT64 then
    EmitOP_OR_INT64
  else if R.Op = OP_XOR_INT64 then
    EmitOP_XOR_INT64

  else if R.Op = OP_LT_INT64 then
    EmitOP_LT_INT64
  else if R.Op = OP_LE_INT64 then
    EmitOP_LE_INT64
  else if R.Op = OP_GT_INT64 then
    EmitOP_GT_INT64
  else if R.Op = OP_GE_INT64 then
    EmitOP_GE_INT64
  else if R.Op = OP_EQ_INT64 then
    EmitOP_EQ_INT64
  else if R.Op = OP_NE_INT64 then
    EmitOP_NE_INT64

  else if R.Op = OP_EQ_STRUCT then
    EmitOP_EQ_STRUCT
  else if R.Op = OP_NE_STRUCT then
    EmitOP_NE_STRUCT

  else if R.Op = OP_EQ_EVENT then
    EmitOP_EQ_INT64
  else if R.Op = OP_NE_EVENT then
    EmitOP_NE_INT64

  else if R.Op = OP_ADD_CURRENCY then
    EmitOP_ADD_CURRENCY
  else if R.Op = OP_SUB_CURRENCY then
    EmitOP_SUB_CURRENCY
  else if R.Op = OP_MUL_CURRENCY then
    EmitOP_MUL_CURRENCY
  else if R.Op = OP_DIV_CURRENCY then
    EmitOP_DIV_CURRENCY

  else if R.Op = OP_ADD_INT_MI then
    EmitOP_ADD_INT_MI
  else if R.Op = OP_ADD_INT_MM then
    EmitOP_ADD_INT_MM
  else if R.Op = OP_ADD_DOUBLE then
    EmitOP_ADD_DOUBLE
  else if R.Op = OP_ADD_SINGLE then
    EmitOP_ADD_SINGLE
  else if R.Op = OP_ADD_EXTENDED then
    EmitOP_ADD_EXTENDED

  else if R.Op = OP_NEG_INT then
    EmitOP_NEG_INT
  else if R.Op = OP_NEG_INT64 then
    EmitOP_NEG_INT64
  else if R.Op = OP_NOT then
    EmitOP_NOT
  else if R.Op = OP_NEG_DOUBLE then
    EmitOP_NEG_DOUBLE
  else if R.Op = OP_NEG_CURRENCY then
    EmitOP_NEG_CURRENCY
  else if R.Op = OP_NEG_SINGLE then
    EmitOP_NEG_SINGLE
  else if R.Op = OP_NEG_EXTENDED then
    EmitOP_NEG_EXTENDED

  else if R.Op = OP_ABS_INT then
    EmitOP_ABS_INT
  else if R.Op = OP_ABS_DOUBLE then
    EmitOP_ABS_DOUBLE
  else if R.Op = OP_ABS_SINGLE then
    EmitOP_ABS_SINGLE
  else if R.Op = OP_ABS_EXTENDED then
    EmitOP_ABS_EXTENDED

  else if R.Op = OP_SUB_INT_MI then
    EmitOP_SUB_INT_MI
  else if R.Op = OP_SUB_INT_MM then
    EmitOP_SUB_INT_MM
  else if R.Op = OP_SUB_DOUBLE then
    EmitOP_SUB_DOUBLE
  else if R.Op = OP_SUB_SINGLE then
    EmitOP_SUB_SINGLE
  else if R.Op = OP_SUB_EXTENDED then
    EmitOP_SUB_EXTENDED

  else if R.Op = OP_IMUL_INT_MI then
    EmitOP_IMUL_INT_MI
  else if R.Op = OP_IMUL_INT_MM then
    EmitOP_IMUL_INT_MM
  else if R.Op = OP_MUL_DOUBLE then
    EmitOP_MUL_DOUBLE
  else if R.Op = OP_MUL_SINGLE then
    EmitOP_MUL_SINGLE
  else if R.Op = OP_MUL_EXTENDED then
    EmitOP_MUL_EXTENDED

  else if R.Op = OP_IDIV_INT_MI then
    EmitOP_IDIV_INT_MI
  else if R.Op = OP_IDIV_INT_MM then
    EmitOP_IDIV_INT_MM
  else if R.Op = OP_IDIV_INT_IM then
    EmitOP_IDIV_INT_IM
  else if R.Op = OP_DIV_DOUBLE then
    EmitOP_DIV_DOUBLE
  else if R.Op = OP_DIV_SINGLE then
    EmitOP_DIV_SINGLE
  else if R.Op = OP_DIV_EXTENDED then
    EmitOP_DIV_EXTENDED

  else if R.Op = OP_MOD_INT_MI then
    EmitOP_MOD_INT_MI
  else if R.Op = OP_MOD_INT_MM then
    EmitOP_MOD_INT_MM
  else if R.Op = OP_MOD_INT_IM then
    EmitOP_MOD_INT_IM

  else if R.Op = OP_SHL_INT_MI then
    EmitOP_SHL_INT_MI
  else if R.Op = OP_SHL_INT_MM then
    EmitOP_SHL_INT_MM
  else if R.Op = OP_SHL_INT_IM then
    EmitOP_SHL_INT_IM

  else if R.Op = OP_SHR_INT_MI then
    EmitOP_SHR_INT_MI
  else if R.Op = OP_SHR_INT_MM then
    EmitOP_SHR_INT_MM
  else if R.Op = OP_SHR_INT_IM then
    EmitOP_SHR_INT_IM

  else if R.Op = OP_AND_INT_MI then
    EmitOP_AND_INT_MI
  else if R.Op = OP_AND_INT_MM then
    EmitOP_AND_INT_MM

  else if R.Op = OP_OR_INT_MI then
    EmitOP_OR_INT_MI
  else if R.Op = OP_OR_INT_MM then
    EmitOP_OR_INT_MM

  else if R.Op = OP_XOR_INT_MI then
    EmitOP_XOR_INT_MI
  else if R.Op = OP_XOR_INT_MM then
    EmitOP_XOR_INT_MM

  else if R.Op = OP_LT_INT_MI then
    EmitOP_LT_INT_MI
  else if R.Op = OP_LT_INT_MM then
    EmitOP_LT_INT_MM
  else if R.Op = OP_LE_INT_MI then
    EmitOP_LE_INT_MI
  else if R.Op = OP_LE_INT_MM then
    EmitOP_LE_INT_MM
  else if R.Op = OP_GT_INT_MI then
    EmitOP_GT_INT_MI
  else if R.Op = OP_GT_INT_MM then
    EmitOP_GT_INT_MM
  else if R.Op = OP_GE_INT_MI then
    EmitOP_GE_INT_MI
  else if R.Op = OP_GE_INT_MM then
    EmitOP_GE_INT_MM
  else if R.Op = OP_EQ_INT_MI then
    EmitOP_EQ_INT_MI
  else if R.Op = OP_EQ_INT_MM then
    EmitOP_EQ_INT_MM
  else if R.Op = OP_NE_INT_MI then
    EmitOP_NE_INT_MI
  else if R.Op = OP_NE_INT_MM then
    EmitOP_NE_INT_MM

  else if R.Op = OP_LT_DOUBLE then
    EmitOP_LT_DOUBLE
  else if R.Op = OP_LE_DOUBLE then
    EmitOP_LE_DOUBLE
  else if R.Op = OP_GT_DOUBLE then
    EmitOP_GT_DOUBLE
  else if R.Op = OP_GE_DOUBLE then
    EmitOP_GE_DOUBLE
  else if R.Op = OP_EQ_DOUBLE then
    EmitOP_EQ_DOUBLE
  else if R.Op = OP_NE_DOUBLE then
    EmitOP_NE_DOUBLE

  else if R.Op = OP_LT_CURRENCY then
    EmitOP_LT_CURRENCY
  else if R.Op = OP_LE_CURRENCY then
    EmitOP_LE_CURRENCY
  else if R.Op = OP_GT_CURRENCY then
    EmitOP_GT_CURRENCY
  else if R.Op = OP_GE_CURRENCY then
    EmitOP_GE_CURRENCY
  else if R.Op = OP_EQ_CURRENCY then
    EmitOP_EQ_CURRENCY
  else if R.Op = OP_NE_CURRENCY then
    EmitOP_NE_CURRENCY

  else if R.Op = OP_LT_SINGLE then
    EmitOP_LT_SINGLE
  else if R.Op = OP_LE_SINGLE then
    EmitOP_LE_SINGLE
  else if R.Op = OP_GT_SINGLE then
    EmitOP_GT_SINGLE
  else if R.Op = OP_GE_SINGLE then
    EmitOP_GE_SINGLE
  else if R.Op = OP_EQ_SINGLE then
    EmitOP_EQ_SINGLE
  else if R.Op = OP_NE_SINGLE then
    EmitOP_NE_SINGLE

  else if R.Op = OP_LT_EXTENDED then
    EmitOP_LT_EXTENDED
  else if R.Op = OP_LE_EXTENDED then
    EmitOP_LE_EXTENDED
  else if R.Op = OP_GT_EXTENDED then
    EmitOP_GT_EXTENDED
  else if R.Op = OP_GE_EXTENDED then
    EmitOP_GE_EXTENDED
  else if R.Op = OP_EQ_EXTENDED then
    EmitOP_EQ_EXTENDED
  else if R.Op = OP_NE_EXTENDED then
    EmitOP_NE_EXTENDED

  else if R.Op = OP_PUSH_ADDRESS then
    EmitOP_PUSH_ADDRESS
  else if R.Op = OP_PUSH_STRUCTURE then
    EmitOP_PUSH_STRUCTURE
  else if R.Op = OP_PUSH_SET then
    EmitOP_PUSH_SET

  else if R.Op = OP_PUSH_BYTE_IMM then
    EmitOP_PUSH_INT_IMM
  else if R.Op = OP_PUSH_BYTE then
    EmitOP_PUSH_INT

  else if R.Op = OP_PUSH_WORD_IMM then
    EmitOP_PUSH_INT_IMM
  else if R.Op = OP_PUSH_WORD then
    EmitOP_PUSH_INT
  else if R.Op = OP_PUSH_CARDINAL_IMM then
    EmitOP_PUSH_INT_IMM
  else if R.Op = OP_PUSH_CARDINAL then
    EmitOP_PUSH_INT
  else if R.Op = OP_PUSH_SMALLINT_IMM then
    EmitOP_PUSH_INT_IMM
  else if R.Op = OP_PUSH_SMALLINT then
    EmitOP_PUSH_INT
  else if R.Op = OP_PUSH_SHORTINT_IMM then
    EmitOP_PUSH_INT_IMM
  else if R.Op = OP_PUSH_SHORTINT then
    EmitOP_PUSH_INT
  else if R.Op = OP_PUSH_INT_IMM then
    EmitOP_PUSH_INT_IMM
  else if R.Op = OP_PUSH_INT then
    EmitOP_PUSH_INT
  else if R.Op = OP_PUSH_INST then
    EmitOP_PUSH_INST
  else if R.Op = OP_PUSH_CLSREF then
    EmitOP_PUSH_CLSREF
  else if R.Op = OP_UPDATE_INSTANCE then
    EmitOP_UPDATE_INSTANCE
  else if R.Op = OP_CLEAR_EDX then
    EmitOP_CLEAR_EDX
  else if R.Op = OP_PUSH_DYNARRAY then
    EmitOP_PUSH_DYNARRAY
  else if R.Op = OP_PUSH_DATA then
    EmitOP_PUSH_DATA
  else if R.Op = OP_PUSH_EVENT then
    EmitOP_PUSH_EVENT

  else if R.Op = OP_PUSH_INT64 then
    EmitOP_PUSH_INT64
  else if R.Op = OP_PUSH_DOUBLE then
    EmitOP_PUSH_DOUBLE
  else if R.Op = OP_PUSH_CURRENCY then
    EmitOP_PUSH_CURRENCY
  else if R.Op = OP_PUSH_SINGLE then
    EmitOP_PUSH_SINGLE
  else if R.Op = OP_PUSH_EXTENDED then
    EmitOP_PUSH_EXTENDED
  else if R.Op = OP_PUSH_ANSISTRING then
    EmitOP_PUSH_ANSISTRING
  else if R.Op = OP_PUSH_WIDESTRING then
    EmitOP_PUSH_WIDESTRING
  else if R.Op = OP_PUSH_UNICSTRING then
    EmitOP_PUSH_UNICSTRING
  else if R.Op = OP_PUSH_SHORTSTRING then
    EmitOP_PUSH_SHORTSTRING
  else if R.Op = OP_PUSH_PANSICHAR_IMM then
    EmitOP_PUSH_PANSICHAR_IMM
  else if R.Op = OP_PUSH_PWIDECHAR_IMM then
    EmitOP_PUSH_PWIDECHAR_IMM

  else if R.Op = OP_BEGIN_CALL then
    EmitOP_BEGIN_CALL
  else if R.Op = OP_CALL then
    EmitOP_CALL

  else if R.Op = OP_INIT_SUB then
    EmitOP_INIT_SUB
  else if R.Op = OP_END_SUB then
    EmitOP_END_SUB
  else if R.Op = OP_FIN_SUB then
    EmitOP_FIN_SUB
  else if R.Op = OP_EPILOGUE_SUB then
    EmitPCodeOperator

  else if R.Op = OP_BEGIN_GLOBAL_BLOCK then
    EmitPCodeOperator
  else if R.Op = OP_EPILOGUE_GLOBAL_BLOCK then
    EmitPCodeOperator
  else if R.Op = OP_END_GLOBAL_BLOCK then
    EmitPCodeOperator

  else if R.Op = OP_EXTRA_BYTECODE then
    EmitPCodeOperator

  else if R.Op = OP_RET then
    EmitOP_RET

  else if R.Op = OP_FIELD then
    EmitOP_FIELD
  else if R.Op = OP_ELEM then
    EmitOP_ELEM

  else if R.Op = OP_PRINT_EX then
    EmitOP_PRINT_EX

  else if R.Op = OP_PUSH_EBP then
    EmitOP_PUSH_EBP
  else if R.Op = OP_POP then
    EmitOP_POP
  else if R.Op = OP_SAVE_REGS then
    EmitOP_SAVE_REGS
  else if R.Op = OP_RESTORE_REGS then
    EmitOP_RESTORE_REGS

  else if R.Op = OP_INT_TO_INT64 then
    EmitOP_INT_TO_INT64
  else if R.Op = OP_BYTE_TO_INT64 then
    EmitOP_BYTE_TO_INT64
  else if R.Op = OP_WORD_TO_INT64 then
    EmitOP_WORD_TO_INT64
  else if R.Op = OP_CARDINAL_TO_INT64 then
    EmitOP_CARDINAL_TO_INT64
  else if R.Op = OP_SMALLINT_TO_INT64 then
    EmitOP_SMALLINT_TO_INT64
  else if R.Op = OP_SHORTINT_TO_INT64 then
    EmitOP_SHORTINT_TO_INT64

  else if R.Op = OP_INT_FROM_INT64 then
    EmitOP_INT_FROM_INT64
  else if R.Op = OP_BYTE_FROM_INT64 then
    EmitOP_BYTE_FROM_INT64
  else if R.Op = OP_WORD_FROM_INT64 then
    EmitOP_WORD_FROM_INT64
  else if R.Op = OP_CARDINAL_FROM_INT64 then
    EmitOP_CARDINAL_FROM_INT64
  else if R.Op = OP_SMALLINT_FROM_INT64 then
    EmitOP_SMALLINT_FROM_INT64
  else if R.Op = OP_SHORTINT_FROM_INT64 then
    EmitOP_SHORTINT_FROM_INT64

  else if R.Op = OP_INT_TO_DOUBLE then
    EmitOP_INT_TO_DOUBLE
  else if R.Op = OP_INT64_TO_DOUBLE then
    EmitOP_INT64_TO_DOUBLE

  else if R.Op = OP_INT_TO_SINGLE then
    EmitOP_INT_TO_SINGLE
  else if R.Op = OP_INT64_TO_SINGLE then
    EmitOP_INT64_TO_SINGLE

  else if R.Op = OP_INT_TO_EXTENDED then
    EmitOP_INT_TO_EXTENDED
  else if R.Op = OP_INT64_TO_EXTENDED then
    EmitOP_INT64_TO_EXTENDED

  else if R.Op = OP_MULT_INT64 then
    EmitOP_MULT_INT64
  else if R.Op = OP_IDIV_INT64 then
    EmitOP_IDIV_INT64
  else if R.Op = OP_MOD_INT64 then
    EmitOP_MOD_INT64
  else if R.Op = OP_ABS_INT64 then
    EmitOP_ABS_INT64

  else if R.Op = OP_CURRENCY_TO_EXTENDED then
    EmitOP_CURRENCY_TO_EXTENDED
  else if R.Op = OP_CURRENCY_TO_SINGLE then
    EmitOP_CURRENCY_TO_SINGLE
  else if R.Op = OP_DOUBLE_TO_SINGLE then
    EmitOP_DOUBLE_TO_SINGLE
  else if R.Op = OP_DOUBLE_TO_EXTENDED then
    EmitOP_DOUBLE_TO_EXTENDED
  else if R.Op = OP_SINGLE_TO_DOUBLE then
    EmitOP_SINGLE_TO_DOUBLE
  else if R.Op = OP_CURRENCY_TO_DOUBLE then
    EmitOP_CURRENCY_TO_DOUBLE
  else if R.Op = OP_SINGLE_TO_EXTENDED then
    EmitOP_SINGLE_TO_EXTENDED
  else if R.Op = OP_EXTENDED_TO_DOUBLE then
    EmitOP_EXTENDED_TO_DOUBLE
  else if R.Op = OP_EXTENDED_TO_SINGLE then
    EmitOP_EXTENDED_TO_SINGLE

  else if R.Op = OP_ADDRESS then
    EmitOP_ADDRESS
  else if R.Op = OP_TERMINAL then
    EmitOP_TERMINAL
  else if R.Op = OP_ADDRESS_PROG then
    EmitOP_ADDRESS_PROG
  else if R.Op = OP_ASSIGN_PROG then
    EmitOP_ASSIGN_PROG

  else if R.Op = OP_SET_INCLUDE then
    EmitOP_SET_INCLUDE
  else if R.Op = OP_SET_INCLUDE_INTERVAL then
    EmitOP_SET_INCLUDE_INTERVAL
  else if R.Op = OP_SET_EXCLUDE then
    EmitOP_SET_EXCLUDE
  else if R.Op = OP_SET_UNION then
    EmitOP_SET_UNION
  else if R.Op = OP_SET_DIFFERENCE then
    EmitOP_SET_DIFFERENCE
  else if R.Op = OP_SET_INTERSECTION then
    EmitOP_SET_INTERSECTION
  else if R.Op = OP_SET_SUBSET then
    EmitOP_SET_SUBSET
  else if R.Op = OP_SET_SUPERSET then
    EmitOP_SET_SUPERSET
  else if R.Op = OP_SET_EQUALITY then
    EmitOP_SET_EQUALITY
  else if R.Op = OP_SET_INEQUALITY then
    EmitOP_SET_INEQUALITY
  else if R.Op = OP_SET_MEMBERSHIP then
    EmitOP_SET_MEMBERSHIP
  else if R.Op = OP_SET_ASSIGN then
    EmitOP_SET_ASSIGN

  else if R.Op = OP_ERR_ABSTRACT then
    EmitOP_ERR_ABSTRACT

  else if R.Op = OP_ANSISTRING_FROM_PANSICHAR then
    EmitOP_ANSISTRING_FROM_PANSICHAR
  else if R.Op = OP_ANSISTRING_FROM_PWIDECHAR then
    EmitOP_ANSISTRING_FROM_PWIDECHAR
  else if R.Op = OP_ANSISTRING_FROM_ANSICHAR then
    EmitOP_ANSISTRING_FROM_ANSICHAR
  else if R.Op = OP_ASSIGN_ANSISTRING then
    EmitOP_ASSIGN_ANSISTRING
  else if R.Op = OP_ASSIGN_SHORTSTRING then
    EmitOP_ASSIGN_SHORTSTRING
  else if R.Op = OP_ASSIGN_WIDESTRING then
    EmitOP_ASSIGN_WIDESTRING
  else if R.Op = OP_ASSIGN_UNICSTRING then
    EmitOP_ASSIGN_UNICSTRING
  else if R.Op = OP_ADD_ANSISTRING then
    EmitOP_ADD_ANSISTRING
  else if R.Op = OP_ADD_SHORTSTRING then
    EmitOP_ADD_SHORTSTRING
  else if R.Op = OP_ADD_WIDESTRING then
    EmitOP_ADD_WIDESTRING
  else if R.Op = OP_ADD_UNICSTRING then
    EmitOP_ADD_UNICSTRING
  else if R.Op = OP_ANSISTRING_CLR then
    EmitOP_ANSISTRING_CLR
  else if R.Op = OP_WIDESTRING_CLR then
    EmitOP_WIDESTRING_CLR
  else if R.Op = OP_UNICSTRING_CLR then
    EmitOP_UNICSTRING_CLR
  else if R.Op = OP_INTERFACE_CLR then
    EmitOP_INTERFACE_CLR
  else if R.Op = OP_STRUCTURE_CLR then
    EmitOP_STRUCTURE_CLR
  else if R.Op = OP_CLASS_CLR then
    EmitOP_CLASS_CLR
  else if R.Op = OP_STRUCTURE_ADDREF then
    EmitOP_STRUCTURE_ADDREF
  else if R.Op = OP_DYNARRAY_CLR then
    EmitOP_DYNARRAY_CLR
  else if R.Op = OP_DYNARRAY_HIGH then
    EmitOP_DYNARRAY_HIGH
  else if R.Op = OP_DYNARRAY_ASSIGN then
    EmitOP_DYNARRAY_ASSIGN
  else if R.Op = OP_CREATE_EMPTY_DYNARRAY then
    EmitOP_CREATE_EMPTY_DYNARRAY

  else if R.Op = OP_ASSIGN_TVarRec then
    EmitOP_ASSIGN_TVarRec

  else if R.Op = OP_SHORTSTRING_FROM_PANSICHAR_LITERAL then
    EmitOP_SHORTSTRING_FROM_PANSICHAR_LITERAL
  else if R.Op = OP_SHORTSTRING_FROM_PWIDECHAR_LITERAL then
    EmitOP_SHORTSTRING_FROM_PWIDECHAR_LITERAL
  else if R.Op = OP_SHORTSTRING_FROM_ANSICHAR then
    EmitOP_SHORTSTRING_FROM_ANSICHAR
  else if R.Op = OP_SHORTSTRING_FROM_WIDECHAR then
    EmitOP_SHORTSTRING_FROM_WIDECHAR
  else if R.Op = OP_SHORTSTRING_FROM_ANSISTRING then
    EmitOP_SHORTSTRING_FROM_ANSISTRING
  else if R.Op = OP_SHORTSTRING_FROM_WIDESTRING then
    EmitOP_SHORTSTRING_FROM_WIDESTRING
  else if R.Op = OP_UNICSTRING_FROM_WIDESTRING then
    EmitOP_UNICSTRING_FROM_WIDESTRING
  else if R.Op = OP_SHORTSTRING_FROM_UNICSTRING then
    EmitOP_SHORTSTRING_FROM_UNICSTRING
  else if R.Op = OP_ANSISTRING_FROM_SHORTSTRING then
    EmitOP_ANSISTRING_FROM_SHORTSTRING

  else if R.Op = OP_EQ_ANSISTRING then
    EmitOP_EQ_ANSISTRING
  else if R.Op = OP_NE_ANSISTRING then
    EmitOP_NE_ANSISTRING
  else if R.Op = OP_EQ_SHORTSTRING then
    EmitOP_EQ_SHORTSTRING
  else if R.Op = OP_NE_SHORTSTRING then
    EmitOP_NE_SHORTSTRING
  else if R.Op = OP_EQ_WIDESTRING then
    EmitOP_EQ_WIDESTRING
  else if R.Op = OP_EQ_UNICSTRING then
    EmitOP_EQ_UNICSTRING
  else if R.Op = OP_NE_WIDESTRING then
    EmitOP_NE_WIDESTRING
  else if R.Op = OP_NE_UNICSTRING then
    EmitOP_NE_UNICSTRING

  else if R.Op = OP_GT_ANSISTRING then
    EmitOP_GT_ANSISTRING
  else if R.Op = OP_GE_ANSISTRING then
    EmitOP_GE_ANSISTRING
  else if R.Op = OP_LT_ANSISTRING then
    EmitOP_LT_ANSISTRING
  else if R.Op = OP_LE_ANSISTRING then
    EmitOP_LE_ANSISTRING

  else if R.Op = OP_GT_SHORTSTRING then
    EmitOP_GT_SHORTSTRING
  else if R.Op = OP_GE_SHORTSTRING then
    EmitOP_GE_SHORTSTRING
  else if R.Op = OP_LT_SHORTSTRING then
    EmitOP_LT_SHORTSTRING
  else if R.Op = OP_LE_SHORTSTRING then
    EmitOP_LE_SHORTSTRING

  else if R.Op = OP_GT_WIDESTRING then
    EmitOP_GT_WIDESTRING
  else if R.Op = OP_GE_WIDESTRING then
    EmitOP_GE_WIDESTRING
  else if R.Op = OP_LT_WIDESTRING then
    EmitOP_LT_WIDESTRING
  else if R.Op = OP_LE_WIDESTRING then
    EmitOP_LE_WIDESTRING

  else if R.Op = OP_GT_UNICSTRING then
    EmitOP_GT_UNICSTRING
  else if R.Op = OP_GE_UNICSTRING then
    EmitOP_GE_UNICSTRING
  else if R.Op = OP_LT_UNICSTRING then
    EmitOP_LT_UNICSTRING
  else if R.Op = OP_LE_UNICSTRING then
    EmitOP_LE_UNICSTRING


  else if R.Op = OP_SHORTSTRING_HIGH then
    EmitOP_SHORTSTRING_HIGH

  else if R.Op = OP_VARIANT_CLR then
    EmitOP_VARIANT_CLR

  else if R.Op = OP_WIDESTRING_FROM_PANSICHAR_LITERAL then
    EmitOP_WIDESTRING_FROM_PANSICHAR_LITERAL
  else if R.Op = OP_WIDESTRING_FROM_PWIDECHAR_LITERAL then
    EmitOP_WIDESTRING_FROM_PWIDECHAR_LITERAL
  else if R.Op = OP_WIDESTRING_FROM_ANSICHAR then
    EmitOP_WIDESTRING_FROM_ANSICHAR
  else if R.Op = OP_WIDESTRING_FROM_WIDECHAR then
    EmitOP_WIDESTRING_FROM_WIDECHAR
  else if R.Op = OP_ANSISTRING_FROM_WIDECHAR then
    EmitOP_ANSISTRING_FROM_WIDECHAR
  else if R.Op = OP_WIDESTRING_FROM_WIDECHAR_LITERAL then
    EmitOP_WIDESTRING_FROM_WIDECHAR_LITERAL
  else if R.Op = OP_WIDESTRING_FROM_ANSISTRING then
    EmitOP_WIDESTRING_FROM_ANSISTRING
  else if R.Op = OP_UNICSTRING_FROM_ANSISTRING then
    EmitOP_UNICSTRING_FROM_ANSISTRING
  else if R.Op = OP_WIDESTRING_FROM_SHORTSTRING then
    EmitOP_WIDESTRING_FROM_SHORTSTRING
  else if R.Op = OP_WIDESTRING_FROM_UNICSTRING then
    EmitOP_WIDESTRING_FROM_UNICSTRING
  else if R.Op = OP_UNICSTRING_FROM_SHORTSTRING then
    EmitOP_UNICSTRING_FROM_SHORTSTRING
  else if R.Op = OP_ANSISTRING_FROM_WIDESTRING then
    EmitOP_ANSISTRING_FROM_WIDESTRING
  else if R.Op = OP_ANSISTRING_FROM_UNICSTRING then
    EmitOP_ANSISTRING_FROM_UNICSTRING

  else if R.Op = OP_UNICSTRING_FROM_PANSICHAR_LITERAL then
    EmitOP_UNICSTRING_FROM_PANSICHAR_LITERAL
  else if R.Op = OP_UNICSTRING_FROM_PWIDECHAR_LITERAL then
    EmitOP_UNICSTRING_FROM_PWIDECHAR_LITERAL
  else if R.Op = OP_UNICSTRING_FROM_ANSICHAR then
    EmitOP_UNICSTRING_FROM_ANSICHAR
  else if R.Op = OP_UNICSTRING_FROM_WIDECHAR then
    EmitOP_UNICSTRING_FROM_WIDECHAR
  else if R.Op = OP_UNICSTRING_FROM_WIDECHAR_LITERAL then
    EmitOP_UNICSTRING_FROM_WIDECHAR_LITERAL

  else if R.Op = OP_VARIANT_FROM_ANSICHAR then
    EmitOP_VARIANT_FROM_ANSICHAR
  else if R.Op = OP_VARIANT_FROM_INT then
    EmitOP_VARIANT_FROM_INT
  else if R.Op = OP_VARIANT_FROM_INT64 then
    EmitOP_VARIANT_FROM_INT64
  else if R.Op = OP_VARIANT_FROM_BYTE then
    EmitOP_VARIANT_FROM_BYTE
  else if R.Op = OP_VARIANT_FROM_BOOL then
    EmitOP_VARIANT_FROM_BOOL
  else if R.Op = OP_VARIANT_FROM_WORD then
    EmitOP_VARIANT_FROM_WORD
  else if R.Op = OP_VARIANT_FROM_CARDINAL then
    EmitOP_VARIANT_FROM_CARDINAL
  else if R.Op = OP_VARIANT_FROM_SMALLINT then
    EmitOP_VARIANT_FROM_SMALLINT
  else if R.Op = OP_VARIANT_FROM_SHORTINT then
    EmitOP_VARIANT_FROM_SHORTINT
  else if R.Op = OP_VARIANT_FROM_DOUBLE then
    EmitOP_VARIANT_FROM_DOUBLE
  else if R.Op = OP_VARIANT_FROM_CURRENCY then
    EmitOP_VARIANT_FROM_CURRENCY
  else if R.Op = OP_VARIANT_FROM_SINGLE then
    EmitOP_VARIANT_FROM_SINGLE
  else if R.Op = OP_VARIANT_FROM_EXTENDED then
    EmitOP_VARIANT_FROM_EXTENDED
  else if R.Op = OP_VARIANT_FROM_INTERFACE then
    EmitOP_VARIANT_FROM_INTERFACE
  else if R.Op = OP_VARIANT_FROM_PANSICHAR_LITERAL then
    EmitOP_VARIANT_FROM_PANSICHAR_LITERAL
  else if R.Op = OP_VARIANT_FROM_PWIDECHAR_LITERAL then
    EmitOP_VARIANT_FROM_PWIDECHAR_LITERAL
  else if R.Op = OP_VARIANT_FROM_ANSISTRING then
    EmitOP_VARIANT_FROM_ANSISTRING
  else if R.Op = OP_VARIANT_FROM_WIDESTRING then
    EmitOP_VARIANT_FROM_WIDESTRING
  else if R.Op = OP_VARIANT_FROM_UNICSTRING then
    EmitOP_VARIANT_FROM_UNICSTRING
  else if R.Op = OP_VARIANT_FROM_SHORTSTRING then
    EmitOP_VARIANT_FROM_SHORTSTRING
  else if R.Op = OP_VARIANT_FROM_WIDECHAR then
    EmitOP_VARIANT_FROM_WIDECHAR
  else if R.Op = OP_VARIANT_FROM_WIDECHAR_LITERAL then
    EmitOP_VARIANT_FROM_WIDECHAR_LITERAL

  else if R.Op = OP_OLEVARIANT_FROM_VARIANT then
    EmitOP_OLEVARIANT_FROM_VARIANT
  else if R.Op = OP_OLEVARIANT_FROM_ANSICHAR then
    EmitOP_OLEVARIANT_FROM_ANSICHAR
  else if R.Op = OP_OLEVARIANT_FROM_INT then
    EmitOP_OLEVARIANT_FROM_INT
  else if R.Op = OP_OLEVARIANT_FROM_INT64 then
    EmitOP_OLEVARIANT_FROM_INT64
  else if R.Op = OP_OLEVARIANT_FROM_BYTE then
    EmitOP_OLEVARIANT_FROM_BYTE
  else if R.Op = OP_OLEVARIANT_FROM_BOOL then
    EmitOP_OLEVARIANT_FROM_BOOL
  else if R.Op = OP_OLEVARIANT_FROM_WORD then
    EmitOP_OLEVARIANT_FROM_WORD
  else if R.Op = OP_OLEVARIANT_FROM_CARDINAL then
    EmitOP_OLEVARIANT_FROM_CARDINAL
  else if R.Op = OP_OLEVARIANT_FROM_SMALLINT then
    EmitOP_OLEVARIANT_FROM_SMALLINT
  else if R.Op = OP_OLEVARIANT_FROM_SHORTINT then
    EmitOP_OLEVARIANT_FROM_SHORTINT
  else if R.Op = OP_OLEVARIANT_FROM_DOUBLE then
    EmitOP_OLEVARIANT_FROM_DOUBLE
  else if R.Op = OP_OLEVARIANT_FROM_CURRENCY then
    EmitOP_OLEVARIANT_FROM_CURRENCY
  else if R.Op = OP_OLEVARIANT_FROM_SINGLE then
    EmitOP_OLEVARIANT_FROM_SINGLE
  else if R.Op = OP_OLEVARIANT_FROM_EXTENDED then
    EmitOP_OLEVARIANT_FROM_EXTENDED
  else if R.Op = OP_OLEVARIANT_FROM_INTERFACE then
    EmitOP_OLEVARIANT_FROM_INTERFACE
  else if R.Op = OP_OLEVARIANT_FROM_PANSICHAR_LITERAL then
    EmitOP_OLEVARIANT_FROM_PANSICHAR_LITERAL
  else if R.Op = OP_OLEVARIANT_FROM_PWIDECHAR_LITERAL then
    EmitOP_OLEVARIANT_FROM_PWIDECHAR_LITERAL
  else if R.Op = OP_OLEVARIANT_FROM_ANSISTRING then
    EmitOP_OLEVARIANT_FROM_ANSISTRING
  else if R.Op = OP_OLEVARIANT_FROM_WIDESTRING then
    EmitOP_OLEVARIANT_FROM_WIDESTRING
  else if R.Op = OP_OLEVARIANT_FROM_UNICSTRING then
    EmitOP_OLEVARIANT_FROM_UNICSTRING
  else if R.Op = OP_OLEVARIANT_FROM_SHORTSTRING then
    EmitOP_OLEVARIANT_FROM_SHORTSTRING
  else if R.Op = OP_OLEVARIANT_FROM_WIDECHAR then
    EmitOP_OLEVARIANT_FROM_WIDECHAR
  else if R.Op = OP_OLEVARIANT_FROM_WIDECHAR_LITERAL then
    EmitOP_OLEVARIANT_FROM_WIDECHAR_LITERAL

  else if R.Op = OP_ANSISTRING_FROM_INT then // JS only
    EmitOP_ANSISTRING_FROM_INT
  else if R.Op = OP_ANSISTRING_FROM_DOUBLE then // JS only
    EmitOP_ANSISTRING_FROM_DOUBLE
  else if R.Op = OP_ANSISTRING_FROM_SINGLE then // JS only
    EmitOP_ANSISTRING_FROM_SINGLE
  else if R.Op = OP_ANSISTRING_FROM_EXTENDED then // JS only
    EmitOP_ANSISTRING_FROM_EXTENDED
  else if R.Op = OP_ANSISTRING_FROM_BOOLEAN then // JS only
    EmitOP_ANSISTRING_FROM_BOOLEAN

  else if R.Op = OP_UNICSTRING_FROM_INT then // JS only
    EmitOP_UNICSTRING_FROM_INT
  else if R.Op = OP_UNICSTRING_FROM_DOUBLE then // JS only
    EmitOP_UNICSTRING_FROM_DOUBLE
  else if R.Op = OP_UNICSTRING_FROM_SINGLE then // JS only
    EmitOP_UNICSTRING_FROM_SINGLE
  else if R.Op = OP_UNICSTRING_FROM_EXTENDED then // JS only
    EmitOP_UNICSTRING_FROM_EXTENDED
  else if R.Op = OP_UNICSTRING_FROM_BOOLEAN then // JS only
    EmitOP_UNICSTRING_FROM_BOOLEAN

  else if R.Op = OP_JS_FUNC_OBJ_FROM_VARIANT then // JS only
    EmitOP_JS_FUNC_OBJ_FROM_VARIANT

  else if R.Op = OP_ANSISTRING_FROM_VARIANT then
    EmitOP_ANSISTRING_FROM_VARIANT
  else if R.Op = OP_WIDESTRING_FROM_VARIANT then
    EmitOP_WIDESTRING_FROM_VARIANT
  else if R.Op = OP_UNICSTRING_FROM_VARIANT then
    EmitOP_UNICSTRING_FROM_VARIANT
  else if R.Op = OP_SHORTSTRING_FROM_VARIANT then
    EmitOP_SHORTSTRING_FROM_VARIANT
  else if R.Op = OP_DOUBLE_FROM_VARIANT then
    EmitOP_DOUBLE_FROM_VARIANT
  else if R.Op = OP_CURRENCY_FROM_VARIANT then
    EmitOP_CURRENCY_FROM_VARIANT
  else if R.Op = OP_SINGLE_FROM_VARIANT then
    EmitOP_SINGLE_FROM_VARIANT
  else if R.Op = OP_EXTENDED_FROM_VARIANT then
    EmitOP_EXTENDED_FROM_VARIANT
  else if R.Op = OP_INT_FROM_VARIANT then
    EmitOP_INT_FROM_VARIANT
  else if R.Op = OP_INT64_FROM_VARIANT then
    EmitOP_INT64_FROM_VARIANT
  else if R.Op = OP_BYTE_FROM_VARIANT then
    EmitOP_BYTE_FROM_VARIANT
  else if R.Op = OP_WORD_FROM_VARIANT then
    EmitOP_WORD_FROM_VARIANT
  else if R.Op = OP_CARDINAL_FROM_VARIANT then
    EmitOP_CARDINAL_FROM_VARIANT
  else if R.Op = OP_BOOL_FROM_VARIANT then
    EmitOP_BOOL_FROM_VARIANT
  else if R.Op = OP_BYTEBOOL_FROM_VARIANT then
    EmitOP_BYTEBOOL_FROM_VARIANT
  else if R.Op = OP_WORDBOOL_FROM_VARIANT then
    EmitOP_WORDBOOL_FROM_VARIANT
  else if R.Op = OP_LONGBOOL_FROM_VARIANT then
    EmitOP_LONGBOOL_FROM_VARIANT
  else if R.Op = OP_SMALLINT_FROM_VARIANT then
    EmitOP_SMALLINT_FROM_VARIANT
  else if R.Op = OP_SHORTINT_FROM_VARIANT then
    EmitOP_SHORTINT_FROM_VARIANT

  else if R.Op = OP_NEG_VARIANT then
    EmitOP_NEG_VARIANT
  else if R.Op = OP_ABS_VARIANT then
    EmitOP_ABS_VARIANT
  else if R.Op = OP_NOT_VARIANT then
    EmitOP_NOT_VARIANT
  else if R.Op = OP_ADD_VARIANT then
    EmitOP_ADD_VARIANT
  else if R.Op = OP_SUB_VARIANT then
    EmitOP_SUB_VARIANT
  else if R.Op = OP_MULT_VARIANT then
    EmitOP_MULT_VARIANT
  else if R.Op = OP_DIV_VARIANT then
    EmitOP_DIV_VARIANT
  else if R.Op = OP_IDIV_VARIANT then
    EmitOP_IDIV_VARIANT
  else if R.Op = OP_MOD_VARIANT then
    EmitOP_MOD_VARIANT
  else if R.Op = OP_SHL_VARIANT then
    EmitOP_SHL_VARIANT
  else if R.Op = OP_SHR_VARIANT then
    EmitOP_SHR_VARIANT
  else if R.Op = OP_AND_VARIANT then
    EmitOP_AND_VARIANT
  else if R.Op = OP_OR_VARIANT then
    EmitOP_OR_VARIANT
  else if R.Op = OP_XOR_VARIANT then
    EmitOP_XOR_VARIANT
  else if R.Op = OP_LT_VARIANT then
    EmitOP_LT_VARIANT
  else if R.Op = OP_LE_VARIANT then
    EmitOP_LE_VARIANT
  else if R.Op = OP_GT_VARIANT then
    EmitOP_GT_VARIANT
  else if R.Op = OP_GE_VARIANT then
    EmitOP_GE_VARIANT
  else if R.Op = OP_EQ_VARIANT then
    EmitOP_EQ_VARIANT
  else if R.Op = OP_NE_VARIANT then
    EmitOP_NE_VARIANT

  else if R.Op = OP_CURRENCY_FROM_INT then
    EmitOP_CURRENCY_FROM_INT
  else if R.Op = OP_CURRENCY_FROM_INT64 then
    EmitOP_CURRENCY_FROM_INT64
  else if R.Op = OP_CURRENCY_FROM_REAL then
    EmitOP_CURRENCY_FROM_REAL

  else if R.Op = OP_VARIANT_FROM_CLASS then
    EmitOP_VARIANT_FROM_CLASS
  else if R.Op = OP_VARIANT_FROM_POINTER then
    EmitOP_VARIANT_FROM_POINTER
  else if R.Op = OP_CLASS_FROM_VARIANT then
    EmitOP_CLASS_FROM_VARIANT

  else if R.Op = OP_INTERFACE_FROM_CLASS then
    EmitOP_INTERFACE_FROM_CLASS
  else if R.Op = OP_INTERFACE_CAST then
    EmitOP_INTERFACE_CAST

  else if R.Op = OP_ASSIGN_VARIANT then
    EmitOP_ASSIGN_VARIANT
  else if R.Op = OP_ASSIGN_OLEVARIANT then
    EmitOP_ASSIGN_OLEVARIANT

  else if R.Op = OP_ASSIGN_CLASS then
    EmitOP_ASSIGN_CLASS

  else if R.Op = OP_VARARRAY_GET then
    EmitOP_VARARRAY_GET
  else if R.Op = OP_VARARRAY_PUT then
    EmitOP_VARARRAY_PUT

  else if R.Op = OP_OLE_GET then
    EmitOP_OLE_GET
  else if R.Op = OP_OLE_SET then
    EmitOP_OLE_SET
  else if R.Op = OP_OLE_PARAM then
    EmitOP_OLE_PARAM

  else if R.Op = OP_IS then
    EmitOP_IS
  else if R.Op = OP_TYPEINFO then
    EmitOP_TYPEINFO
  else if R.Op = OP_ADD_TYPEINFO then
    EmitPCodeOperator

  else if R.Op = OP_PUSH_CONTEXT then
    EmitOP_PUSH_CONTEXT
  else if R.Op = OP_POP_CONTEXT then
    EmitOP_POP_CONTEXT
  else if R.Op = OP_FIND_CONTEXT then
    EmitOP_FIND_CONTEXT
  else if R.Op = OP_FIND_JS_FUNC then
    EmitOP_FIND_JS_FUNC

  else if R.Op = OP_GET_PROG then
    EmitOP_GET_PROG

  else if R.Op = OP_ONCREATE_OBJECT then
    EmitOP_ONCREATE_OBJECT
  else if R.Op = OP_ON_AFTER_OBJECT_CREATION then
    EmitOP_ON_AFTER_OBJECT_CREATION

  else if R.Op = OP_CLASSNAME then
    EmitOP_CLASSNAME

  else if R.Op = OP_GET_ANSISTR_PROP then
    EmitOP_GET_ANSISTR_PROP
  else if R.Op = OP_SET_ANSISTR_PROP then
    EmitOP_SET_ANSISTR_PROP

  else if R.Op = OP_GET_WIDESTR_PROP then
    EmitOP_GET_WIDESTR_PROP
  else if R.Op = OP_SET_WIDESTR_PROP then
    EmitOP_SET_WIDESTR_PROP

  else if R.Op = OP_GET_UNICSTR_PROP then
    EmitOP_GET_UNICSTR_PROP
  else if R.Op = OP_SET_UNICSTR_PROP then
    EmitOP_SET_UNICSTR_PROP

  else if R.Op = OP_GET_ORD_PROP then
    EmitOP_GET_ORD_PROP
  else if R.Op = OP_SET_ORD_PROP then
    EmitOP_SET_ORD_PROP

  else if R.Op = OP_GET_INTERFACE_PROP then
    EmitOP_GET_INTERFACE_PROP
  else if R.Op = OP_SET_INTERFACE_PROP then
    EmitOP_SET_INTERFACE_PROP

  else if R.Op = OP_GET_SET_PROP then
    EmitOP_GET_SET_PROP
  else if R.Op = OP_SET_SET_PROP then
    EmitOP_SET_SET_PROP

  else if R.Op = OP_GET_FLOAT_PROP then
    EmitOP_GET_FLOAT_PROP
  else if R.Op = OP_SET_FLOAT_PROP then
    EmitOP_SET_FLOAT_PROP

  else if R.Op = OP_GET_VARIANT_PROP then
    EmitOP_GET_VARIANT_PROP
  else if R.Op = OP_SET_VARIANT_PROP then
    EmitOP_SET_VARIANT_PROP

  else if R.Op = OP_GET_INT64_PROP then
    EmitOP_GET_INT64_PROP
  else if R.Op = OP_SET_INT64_PROP then
    EmitOP_SET_INT64_PROP

  else if R.Op = OP_GET_EVENT_PROP then
    EmitOP_GET_EVENT_PROP
  else if R.Op = OP_SET_EVENT_PROP then
    EmitOP_SET_EVENT_PROP
  else if R.Op = OP_SET_EVENT_PROP2 then
    EmitOP_SET_EVENT_PROP2

  else if R.Op = OP_TRY_ON then
    EmitOP_TRY_ON
  else if R.Op = OP_TRY_OFF then
    EmitOP_TRY_OFF
  else if R.Op = OP_FINALLY then
    EmitOP_FINALLY
  else if R.Op = OP_EXCEPT then
    EmitOP_EXCEPT
  else if R.Op = OP_EXCEPT_ON then
    EmitOP_EXCEPT_ON
  else if R.Op = OP_RAISE then
    EmitOP_RAISE
  else if R.Op = OP_EXIT then
    EmitOP_EXIT
  else if R.Op = OP_COND_RAISE then
    EmitOP_COND_RAISE
  else if R.Op = OP_BEGIN_EXCEPT_BLOCK then
    EmitOP_BEGIN_EXCEPT_BLOCK
  else if R.Op = OP_END_EXCEPT_BLOCK then
    EmitOP_END_EXCEPT_BLOCK

  else if R.Op = OP_OVERFLOW_CHECK then
    EmitOP_OVERFLOW_CHECK

  else if R.Op = OP_PAUSE then
    EmitOP_PAUSE
  else if R.Op = OP_CHECK_PAUSE then
    EmitOP_CHECK_PAUSE
  else if R.Op = OP_CHECK_PAUSE_LIGHT then
    EmitOP_CHECK_PAUSE_LIGHT
  else if R.Op = OP_HALT then
    EmitOP_HALT

  else if R.Op = OP_CREATE_OBJECT then
    EmitOP_CREATE_OBJECT
  else if R.Op = OP_DESTROY_OBJECT then
    EmitOP_DESTROY_OBJECT
  else if R.Op = OP_GET_VMT_ADDRESS then
    EmitOP_GET_VMT_ADDRESS

  else if R.Op = OP_SET_LENGTH then
    EmitOP_SET_LENGTH

  else if R.Op = OP_CREATE_METHOD then
    EmitOP_CREATE_METHOD

  else if R.Op = OP_DECLARE_TEMP_VAR then
  begin
    EmitPCodeOperator;
  end
  else if R.Op = OP_BEGIN_USING then
  begin
    EmitPCodeOperator;
  end
  else if R.Op = OP_END_USING then
  begin
    EmitPCodeOperator;
  end
  else if R.Op = OP_BEGIN_BLOCK then
  begin
    EmitPCodeOperator;
  end
  else if R.Op = OP_END_BLOCK then
  begin
    EmitPCodeOperator;
  end
  else if R.Op = OP_BEGIN_WITH then
  begin
    EmitPCodeOperator;
  end
  else if R.Op = OP_END_WITH then
  begin
    EmitPCodeOperator;
  end
  else if R.Op = OP_BEGIN_SUB then
  begin
    EmitPCodeOperator;
  end
  else if R.Op = OP_BEGIN_CLASS_TYPE then
  begin
    EmitPCodeOperator;
  end
  else if R.Op = OP_END_CLASS_TYPE then
  begin
    EmitPCodeOperator;
  end
  else if R.Op = OP_BEGIN_RECORD_TYPE then
  begin
    EmitPCodeOperator;
  end
  else if R.Op = OP_END_RECORD_TYPE then
  begin
    EmitPCodeOperator;
  end

  else if R.Op = OP_ADD_ANCESTOR then
  begin
  // ok
  end

  else if R.Op = OP_INIT_PANSICHAR_LITERAL then
  begin
  // ok
  end
  else if R.Op = OP_INIT_PWIDECHAR_LITERAL then
  begin
  // ok
  end
  else if R.Op = OP_BEGIN_CRT_JS_FUNC_OBJECT then
  begin
    EmitOP_BEGIN_CRT_JS_FUNC_OBJECT;
  end
  else if R.Op = OP_END_CRT_JS_FUNC_OBJECT then
  begin
    EmitOP_END_CRT_JS_FUNC_OBJECT;
  end
  else if R.Op = OP_TO_JS_OBJECT then
  begin
    EmitOP_TO_JS_OBJECT;
  end
  else if R.Op = OP_JS_TYPEOF then
  begin
    EmitOP_JS_TYPEOF;
  end
  else if R.Op = OP_JS_VOID then
  begin
    EmitOP_JS_VOID;
  end
  else if R.Op = OP_GET_NEXTJSPROP then
  begin
    EmitOP_GET_NEXTJSPROP;
  end
  else if R.Op = OP_CLEAR_REFERENCES then
  begin
    EmitOP_CLEAR_REFERENCES;
  end
  else if R.Op = OP_DECLARE_LOCAL_VAR then
  begin
    EmitPCodeOperator;
  end
  else if R.Op = OP_LOAD_PROC then
  begin
    EmitPCodeOperator;
  end
  else if R.Op = OP_BEGIN_ARRAY_TYPE then
  begin
    EmitPCodeOperator;
  end
  else if R.Op = OP_END_ARRAY_TYPE then
  begin
    EmitPCodeOperator;
  end
  else if R.Op = OP_BEGIN_SET_TYPE then
  begin
    EmitPCodeOperator;
  end
  else if R.Op = OP_END_SET_TYPE then
  begin
    EmitPCodeOperator;
  end
  else if R.Op = OP_BEGIN_ENUM_TYPE then
  begin
    EmitPCodeOperator;
  end
  else if R.Op = OP_END_ENUM_TYPE then
  begin
    EmitPCodeOperator;
  end
  else if R.Op = OP_BEGIN_SUBRANGE_TYPE then
  begin
    EmitPCodeOperator;
  end
  else if R.Op = OP_END_SUBRANGE_TYPE then
  begin
    EmitPCodeOperator;
  end
  else if R.Op = OP_BEGIN_POINTER_TYPE then
  begin
    EmitPCodeOperator;
  end
  else if R.Op = OP_END_POINTER_TYPE then
  begin
    EmitPCodeOperator;
  end
  else if R.Op = OP_BEGIN_CLASSREF_TYPE then
  begin
    EmitPCodeOperator;
  end
  else if R.Op = OP_END_CLASSREF_TYPE then
  begin
    EmitPCodeOperator;
  end
  else if R.Op = OP_BEGIN_DYNARRAY_TYPE then
  begin
    EmitPCodeOperator;
  end
  else if R.Op = OP_END_DYNARRAY_TYPE then
  begin
    EmitPCodeOperator;
  end
  else if R.Op = OP_BEGIN_SHORTSTRING_TYPE then
  begin
    EmitPCodeOperator;
  end
  else if R.Op = OP_END_SHORTSTRING_TYPE then
  begin
    EmitPCodeOperator;
  end
  else if R.Op = OP_BEGIN_INTERFACE_TYPE then
  begin
    EmitPCodeOperator;
  end
  else if R.Op = OP_END_INTERFACE_TYPE then
  begin
    EmitPCodeOperator;
  end
  else
    RaiseError(errInternalError, []);
end;

procedure TEmitter.RaiseError(const Message: string; params: array of Const);
begin
  TKernel(kernel).RaiseError(Message, params);
end;

function TEmitter.GetSymbolRec(Id: Integer): TSymbolRec;
begin
  result := TKernel(kernel).SymbolTable[Id];
end;

function TEmitter.SymbolTable: TSymbolTable;
begin
  result := TKernel(kernel).SymbolTable;
end;

procedure TEmitter.EmitPCodeOperator;
var
  S: String;
  N: Integer;
begin
  N := TKernel(kernel).Code.N;
  if (R.Op = OP_CALL) or (R.Op = OP_LOAD_PROC) then
  begin
    if SymbolRec1.MethodIndex > 0 then
      S := '(' + IntToStr(SymbolRec1.MethodIndex) + ')' + ' *** N *** ' + IntToStr(N)
    else
      S := ' *** N *** ' + IntToStr(N);

    Prg.AsmComment('             ' + OperName + '  ' +
      GetSymbolRec(R.Arg1).FullName + '[' + IntToStr(R.Arg1) + ']' + S);
  end
  else
    Prg.AsmComment('             ' + OperName + ' *** N *** ' + IntToStr(N));
end;

procedure TEmitter.EmitOP_SEPARATOR(I: Integer);
{$IFDEF TRIAL}
var SubId: Integer;
{$ENDIF}
begin
{$IFDEF DUMP}
  Prg.AsmComment('------------------------------------------------------');
  Prg.AsmComment(TKernel(kernel).Code.GetSourceLine(I));
  Prg.AsmComment('------------------------------------------------------');
{$ENDIF}

  {$IFDEF TRIAL}
   Inc(_Counter);
   if _Counter mod 101 = 0 then
   begin
     SubId := TKernel(kernel).SymbolTable.LookUp(strShowTrial, 0, false);
     GetReg(_EBX);
     EmitGet_REG(_EBX, TKernel(kernel).SymbolTable[SubId]);
     Prg.AsmCall_REG(_EBX);
     FreeReg(_EBX);
   end;
  {$ENDIF}
end;

procedure TEmitter.EmitOP_GO;
begin
  EmitPCodeOperator;

  EmitJmp;
end;

procedure TEmitter.EmitOP_PAUSE;
var
  Reg, SubId: Integer;
begin
  EmitPCodeOperator;

  SubId := LookUp(_strPause);

  Reg := GetReg;

  Prg.AsmMovREG_REG(Reg, _ESP);
  Prg.AsmPush_REG(Reg);    // pusg _ESP

  Prg.AsmMovREG_REG(Reg, _EBP);
  Prg.AsmPush_REG(Reg);    // pusg _EBP

  Prg.AsmPush_Imm(0);

  List3.Add(SymbolRec1);
  List1.Add(Prg.Top);

  Prg.AsmMovREG_REG(Reg, _ESI);
  Prg.AsmAddREG_Imm(Reg, H_SelfPtr);
  Prg.AsmMovREG32_REGPtr(Reg, Reg); // load TProgram.Self
  Prg.AsmPush_REG(Reg);             // push TProgram.Self

  EmitGet_REG(Reg, SymbolTable[SubId]);
  Prg.AsmCall_REG(Reg);

  FreeReg(Reg);
end;

procedure TEmitter.EmitOP_CHECK_PAUSE;
begin
  EmitPCodeOperator;

  Prg.AsmNOP;
  Prg.AsmNOP;
  Prg.AsmNOP;
  Prg.AsmNOP;
  Prg.AsmNOP;

  GetReg(_EAX);
  Prg.AsmMovREG_REG(_EAX, _ESI);
  Prg.AsmAddREG_Imm(_EAX, H_SelfPtr);
  Prg.AsmMovREG32_REGPtr(_EAX, _EAX); // load TProgram.Self
  FreeReg(_EAX);

  GetReg(_EBX);
  EmitGet_REG(_EBX, SymbolTable[Id_CheckPause]);
  Prg.AsmCall_REG(_EBX);
  FreeReg(_EBX);

  Prg.AsmCmpReg32Ptr_Imm(_ESI, H_Flag, 1);
  Prg.AsmJNZ_Imm(29);

  R.Op := OP_PAUSE;
  EmitOP_PAUSE;
  R.Op := OP_CHECK_PAUSE;
end;

procedure TEmitter.EmitOP_CHECK_PAUSE_LIGHT;
begin
  EmitPCodeOperator;

  Prg.AsmCmpReg32Ptr_Imm(_ESI, H_Flag, 1);
  Prg.AsmJNZ_Imm(29);

  R.Op := OP_PAUSE;
  EmitOP_PAUSE;
  R.Op := OP_CHECK_PAUSE;
end;

procedure TEmitter.EmitOP_HALT;
var
  Reg, SubId: Integer;
begin
  EmitPCodeOperator;

  SubId := LookUp(_strHalt);

  Reg := GetReg;

  Prg.AsmPush_Imm(SymbolRec1.Value);

  Prg.AsmMovREG_REG(Reg, _ESI);
  Prg.AsmAddREG_Imm(Reg, H_SelfPtr);
  Prg.AsmMovREG32_REGPtr(Reg, Reg); // load TProgram.Self
  Prg.AsmPush_REG(Reg);             // push TProgram.Self

  EmitGet_REG(Reg, SymbolTable[SubId]);
  Prg.AsmCall_REG(Reg);

  FreeReg(Reg);
end;

procedure TEmitter.EmitOP_CHECK_INIT_ONLY;
begin
  EmitPCodeOperator;

  Prg.AsmCmpReg32Ptr_Imm(_ESI, H_InitOnly, 2);
  Prg.AsmJNZ_Imm(1);
  Prg.AsmRet();
end;

procedure TEmitter.EmitOP_CHECK_BODY_ONLY;
begin
  EmitPCodeOperator;

  Prg.AsmCmpReg32Ptr_Imm(_ESI, H_BodyOnly, 3);
  Prg.AsmJNZ_Imm(1);
  Prg.AsmRet();
end;

procedure TEmitter.EmitOP_TRY_ON;
var
  Reg, SubId: Integer;
begin
  EmitPCodeOperator;

  SubId := Id_TryOn;

  Prg.AsmPutREG32_ESIPtr(_EDX, 0);

  Reg := GetReg;

  Prg.AsmMovREG_REG(Reg, _ESP);
  Prg.AsmPush_REG(Reg);    // push _ESP

  Prg.AsmMovREG_REG(Reg, _EBP);
  Prg.AsmPush_REG(Reg);    // push _EBP

  Prg.AsmPush_Imm(R.Arg1); // block index

  Prg.AsmMovREG_REG(Reg, _ESI);
  Prg.AsmAddREG_Imm(Reg, H_SelfPtr);
  Prg.AsmMovREG32_REGPtr(Reg, Reg); // load TProgram.Self
  Prg.AsmPush_REG(Reg);             // push TProgram.Self

  EmitGet_REG(Reg, SymbolTable[SubId]);
  Prg.AsmCall_REG(Reg);

  FreeReg(Reg);

  Prg.AsmGetREG32_ESIPtr(_EDX, 0);
end;

procedure TEmitter.EmitOP_TRY_OFF;
var
  Reg, SubId: Integer;
begin
  EmitPCodeOperator;

  SubId := Id_TryOff;

  Reg := GetReg;

  Prg.AsmPush_Imm(R.Arg1); // block index

  Prg.AsmMovREG_REG(Reg, _ESI);
  Prg.AsmAddREG_Imm(Reg, H_SelfPtr);
  Prg.AsmMovREG32_REGPtr(Reg, Reg); // load TProgram.Self
  Prg.AsmPush_REG(Reg);             // push TProgram.Self

  EmitGet_REG(Reg, SymbolTable[SubId]);
  Prg.AsmCall_REG(Reg);

  FreeReg(Reg);
end;

procedure TEmitter.EmitOP_FINALLY;
begin
  EmitPCodeOperator;
end;

procedure TEmitter.EmitOP_EXCEPT;
begin
  EmitPCodeOperator;
end;

procedure TEmitter.EmitOP_EXCEPT_ON;
begin
  EmitPCodeOperator;
end;

procedure TEmitter.EmitOP_EXIT;
var
  Reg, SubId: Integer;
begin
  EmitPCodeOperator;

  SubId := Id_Exit;

  Prg.AsmPush_Imm(R.Res); // level

  Reg := GetReg;

  Prg.AsmMovREG_REG(Reg, _ESI);
  Prg.AsmAddREG_Imm(Reg, H_SelfPtr);
  Prg.AsmMovREG32_REGPtr(Reg, Reg); // load TProgram.Self
  Prg.AsmPush_REG(Reg);             // push TProgram.Self

  EmitGet_REG(Reg, SymbolTable[SubId]);
  Prg.AsmCall_REG(Reg);

  FreeReg(Reg);
end;

procedure TEmitter.EmitOP_RAISE;
var
  Reg, SubId: Integer;
begin
  EmitPCodeOperator;

  SubId := Id_Raise;

  Prg.AsmPush_Imm(R.Arg2); // raise mode

  Reg := GetReg;

  if R.Arg1 = 0 then
    Prg.AsmPush_Imm(R.Arg1) // block index
  else
  begin
    EmitLoadIntVal(Reg, SymbolRec1);
    Prg.AsmPush_REG(Reg);
  end;

  Prg.AsmMovREG_REG(Reg, _ESI);
  Prg.AsmAddREG_Imm(Reg, H_SelfPtr);
  Prg.AsmMovREG32_REGPtr(Reg, Reg); // load TProgram.Self
  Prg.AsmPush_REG(Reg);             // push TProgram.Self

  EmitGet_REG(Reg, SymbolTable[SubId]);
  Prg.AsmCall_REG(Reg);

  FreeReg(Reg);
end;

procedure TEmitter.EmitOP_OVERFLOW_CHECK;
begin
  EmitPCodeOperator;
  if R.Arg1 > 0 then
    OverflowCheck := true
  else
    OverflowCheck := false;
end;

procedure TEmitter.EmitOP_BEGIN_EXCEPT_BLOCK;
var
  Reg, SubId: Integer;
begin
  EmitPCodeOperator;

  SubId := Id_BeginExceptBlock;

  Reg := GetReg;

  Prg.AsmMovREG_REG(Reg, _ESI);
  Prg.AsmAddREG_Imm(Reg, H_SelfPtr);
  Prg.AsmMovREG32_REGPtr(Reg, Reg); // load TProgram.Self
  Prg.AsmPush_REG(Reg);             // push TProgram.Self

  EmitGet_REG(Reg, SymbolTable[SubId]);
  Prg.AsmCall_REG(Reg);

  FreeReg(Reg);
end;

procedure TEmitter.EmitOP_END_EXCEPT_BLOCK;
var
  Reg, SubId: Integer;
begin
  EmitPCodeOperator;

  SubId := Id_EndExceptBlock;

  Reg := GetReg;

  Prg.AsmMovREG_REG(Reg, _ESI);
  Prg.AsmAddREG_Imm(Reg, H_SelfPtr);
  Prg.AsmMovREG32_REGPtr(Reg, Reg); // load TProgram.Self
  Prg.AsmPush_REG(Reg);             // push TProgram.Self

  EmitGet_REG(Reg, SymbolTable[SubId]);
  Prg.AsmCall_REG(Reg);

  FreeReg(Reg);
end;

procedure TEmitter.EmitOP_COND_RAISE;
var
  Reg, SubId: Integer;
begin
  EmitPCodeOperator;

  SubId := Id_CondRaise;

  Reg := GetReg;

  Prg.AsmPush_Imm(SymbolRecR.Level);

  EmitLoadAddress(Reg, SymbolRecR);  // IsExit
  Prg.AsmPush_REG(Reg);

  Prg.AsmMovREG_REG(Reg, _ESI);
  Prg.AsmAddREG_Imm(Reg, H_SelfPtr);
  Prg.AsmMovREG32_REGPtr(Reg, Reg); // load TProgram.Self
  Prg.AsmPush_REG(Reg);             // push TProgram.Self

  EmitGet_REG(Reg, SymbolTable[SubId]);
  Prg.AsmCall_REG(Reg);

  if R.Arg1 > 0 then
  begin
    FreeReg(Reg);

    Reg := EmitGetAddressRegister(SymbolRecR);
    Prg.AsmCmpREGPtr_Imm(Reg, SymbolRecR, 0);
    Prg.AsmJZ_Imm(5);
    EmitJmp;
    FreeReg(Reg);
  end
  else
    FreeReg(Reg);
end;

procedure TEmitter.EmitOP_GO_TRUE;
var
  Reg: Integer;
begin
  EmitPCodeOperator;

  if SymbolRec2.Kind = kindCONST then
  begin
    if SymbolRec2.Value <> 0 then
      EmitJmp;
    Exit;
  end;

{
  Reg := GetReg;
  EmitLoadAddress(Reg, SymbolRec2);
  Prg.AsmCmpByteREGPtr_Imm(Reg, 0);
}

  Reg := EmitGetAddressRegister(SymbolRec2);
  Prg.AsmCmpREGPtr_Imm(Reg, SymbolRec2, 0);

  Prg.AsmJZ_Imm(5);
  EmitJmp;
  FreeReg(Reg);
end;

procedure TEmitter.EmitOP_GO_DL;
begin
  EmitPCodeOperator;
  Prg.AsmTestREG8_REG8(_EDX, _EDX);
  Prg.AsmJNZ_Imm(5);
  EmitJmp;
end;

procedure TEmitter.EmitOP_SAVE_EDX;
begin
  EmitPCodeOperator;
  Prg.AsmPush_REG(_EDX);
end;

procedure TEmitter.EmitOP_RESTORE_EDX;
begin
  EmitPCodeOperator;
  Prg.AsmPop_REG(_EDX);
end;

procedure TEmitter.EmitOP_GO_FALSE;
var
  Reg: Integer;
begin
  EmitPCodeOperator;

  if SymbolRec2.Kind = kindCONST then
  begin
    if SymbolRec2.Value = 0 then
      EmitJmp;
    Exit;
  end;

{
  Reg := GetReg;
  EmitLoadAddress(Reg, SymbolRec2);
  Prg.AsmCmpByteREGPtr_Imm(Reg, 0);
}

  Reg := EmitGetAddressRegister(SymbolRec2);
  Prg.AsmCmpREGPtr_Imm(Reg, SymbolRec2, 0);

  Prg.AsmJNZ_Imm(5);
  EmitJmp;
  FreeReg(Reg);
end;

procedure TEmitter.EmitLabel(LabelId: Integer; const LabelName: String);
begin
  Prg.AsmComment('LABEL: ' + LabelName);
  Prg.Top.LabelId := LabelId;
end;

procedure TEmitter.EmitOP_ASSIGN_INT_I;
var
  Reg: Integer;
begin
  EmitPCodeOperator;

  Reg := EmitGetAddressRegister(SymbolRec1);
  Prg.AsmMovREGPtr_Imm(Reg, SymbolRec1, ImmValue2);
  FreeReg(Reg);
end;

procedure TEmitter.EmitOP_ASSIGN_INT_M;
var
  Reg: Integer;
begin
  EmitPCodeOperator;

  Reg := GetReg;

  EmitLoadIntVal(Reg, SymbolRec2);
  EmitSaveIntVal(Reg, SymbolRec1);
  FreeReg(Reg);
end;

procedure TEmitter.EmitOP_ASSIGN_PANSICHAR;
var
  Reg: Integer;
begin
  EmitPCodeOperator;

  Reg := GetReg;

  EmitGet_REG(Reg, SymbolRec2);
  if SymbolRec2.Host or SymbolRec2.ByRef then
    Prg.AsmMovREG32_REGPtr(Reg, Reg);

  EmitSaveIntVal(Reg, SymbolRec1);
  FreeReg(Reg);
end;

procedure TEmitter.EmitOP_ASSIGN_PWIDECHAR;
var
  Reg: Integer;
begin
  EmitPCodeOperator;

  Reg := GetReg;

  EmitGet_REG(Reg, SymbolRec2);
  if SymbolRec2.Host or SymbolRec2.ByRef then
    Prg.AsmMovREG32_REGPtr(Reg, Reg);

  EmitSaveIntVal(Reg, SymbolRec1);
  FreeReg(Reg);
end;

procedure TEmitter.EmitOP_ASSIGN_EVENT;
var
  Reg, Reg1, Reg2: Integer;
begin
  EmitPCodeOperator;

  HandlesEvents := true;

  Reg := GetReg;
  Reg1 := GetReg;
  Reg2 := GetReg;

  EmitLoadAddress(Reg1, SymbolRec1);
  EmitLoadAddress(Reg2, SymbolRec2);

  Prg.AsmMovREG32_REGPtr(Reg, Reg2);
  Prg.AsmMovREGPtr_REG32(Reg1, Reg);

  Prg.AsmAddREG_Imm(Reg1, 4);
  Prg.AsmAddREG_Imm(Reg2, 4);

  Prg.AsmMovREG32_REGPtr(Reg, Reg2);
  Prg.AsmMovREGPtr_REG32(Reg1, Reg);

  FreeReg(Reg);
  FreeReg(Reg1);
  FreeReg(Reg2);
end;

procedure TEmitter.EmitOP_CREATE_EVENT;
var
  Reg, Reg1, Reg2: Integer;
begin
  EmitPCodeOperator;

  HandlesEvents := true;

  Reg := GetReg;
  Reg1 := GetReg;
  Reg2 := GetReg;

  EmitLoadIntVal(Reg1, SymbolRec1); // instance

  if Host2 then
    EmitLoadAddress(Reg2, SymbolRec2) // address of method
  else
  begin
    Prg.AsmMovREG_REG(Reg2, _EDI);
    Prg.AsmAddREG_Imm(Reg2, 0);
    Prg.Top.SaveSubId := R.Arg2;
    List2.Add(Prg.Top);
  end;

  EmitLoadAddress(Reg, SymbolRecR); // address of event

  Prg.AsmMovREGPtr_REG32(Reg, Reg2); // code
  Prg.AsmAddREG_Imm(Reg, 4);
  Prg.AsmMovREGPtr_REG32(Reg, Reg1); // data

  FreeReg(Reg);
  FreeReg(Reg1);
  FreeReg(Reg2);
end;

procedure TEmitter.EmitOP_ASSIGN_RECORD;
var
  Reg, S, TypeId: Integer;
  L: TIntegerList;
begin
  TypeId := SymbolRec1.TerminalTypeId;
  L := SymbolTable.GetShiftsOfDynamicFields(TypeId);

  try
    if L.Count = 0 then
    begin
      EmitPCodeOperator;

      Reg := GetReg;

      S := SymbolRec1.PtrSize;
      Prg.AsmPush_Imm(S);

      EmitLoadAddress(Reg, SymbolRec2); // dest
      Prg.AsmPush_REG(Reg);

      EmitLoadAddress(Reg, SymbolRec1); // source
      Prg.AsmPush_REG(Reg);

      GetReg(_EBX);
      EmitGet_REG(_EBX, SymbolTable[Id_RecordAssign]);
      Prg.AsmCall_REG(_EBX);
      FreeReg(_EBX);

      FreeReg(Reg);
    end
    else
      EmitOP_ASSIGN_RECORD_EX;
  finally
    L.Free;
  end;
end;

procedure TEmitter.EmitOP_ASSIGN_RECORD_EX;

  var SymbolTable: TSymbolTable;

  procedure AssignArr(Reg1, Reg2, TypeId: Integer); forward;

  procedure AssignRec(Reg1, Reg2, TypeId: Integer);
  var
    I, FT, Reg, SubId, S, K: Integer;
    RI: TSymbolRec;
    ArrayTypeId, ElTypeId, ElFinalTypeId, ElSize: Integer;
  begin
    K := 0;
    SubId := 0;
    for I := TypeId + 1 to SymbolTable.Card do
    begin
      RI := SymbolTable[I];
      if RI = SR0 then
        break;
      if RI.Level <> TypeId then
        continue;
      if RI.Kind <> kindTYPE_FIELD then
        continue;
      FT := RI.FinalTypeId;
      S := RI.PtrSize;

      Inc(K);

      Emit_PUSH_REGS;

      if K > 1 then
      begin
        Prg.AsmAddREG_Imm(Reg1, RI.Shift);
        Prg.AsmAddREG_Imm(Reg2, RI.Shift);
      end;

      case FT of
        typeINTEGER, typeCARDINAL, typePOINTER, typePROC,
        typeCLASS, typeCLASSREF, typeLONGBOOL:
        begin
          Reg := GetReg;
          Prg.AsmMovREG32_REGPtr(Reg, Reg2);
          Prg.AsmMovREGPtr_REG32(Reg1, Reg);
          FreeReg(Reg);
        end;
        typeWORD, typeSMALLINT, typeWORDBOOL, typeWIDECHAR:
        begin
          Reg := GetReg;
          Prg.AsmXorREG_REG(Reg, Reg);
          Prg.AsmMovREG16_REGPtr(Reg, Reg2);
          Prg.AsmMovREGPtr_REG16(Reg1, Reg);
          FreeReg(Reg);
        end;
        typeBYTE, typeBOOLEAN, typeSHORTINT, typeBYTEBOOL, typeANSICHAR:
        begin
          Reg := GetReg;
          Prg.AsmXorREG_REG(Reg, Reg);
          Prg.AsmMovREG8_REGPtr(Reg, Reg2);
          Prg.AsmMovREGPtr_REG8(Reg1, Reg);
          FreeReg(Reg);
        end;
        typeANSISTRING, typeUNICSTRING,
        typeWIDESTRING, typeSHORTSTRING,
        typeVARIANT, typeOLEVARIANT,
        typeINTERFACE:
        begin
          case FT of
            typeANSISTRING: SubId := Id_AnsiStringAssign;
            typeUNICSTRING: SubId := Id_UnicStringAssign;
            typeWIDESTRING: SubId := Id_WideStringAssign;
            typeSHORTSTRING: SubId := Id_ShortStringAssign;
            typeVARIANT, typeOLEVARIANT: SubId := Id_VariantAssign;
            typeINTERFACE: SubId := Id_InterfaceAssign;
          end;
          Reg := GetReg;
          Prg.AsmPush_REG(Reg1);
          Prg.AsmPush_REG(Reg2);
          EmitGet_REG(Reg, SymbolTable[SubId]);
          Prg.AsmCall_REG(Reg);
          FreeReg(Reg);
        end;
        typeDYNARRAY:
        begin
          SubId := Id_DynarrayAssign;

          Reg := GetReg;
          ArrayTypeId := RI.TerminalTypeId;
          ElTypeId := GetSymbolRec(ArrayTypeId).PatternId;
          ElFinalTypeId := GetSymbolRec(ElTypeId).FinalTypeId;
          ElSize := SymbolTable[ElTypeId].Size;

          Prg.AsmPush_Imm(ElSize);
          Prg.AsmPush_Imm(ElTypeId);
          Prg.AsmPush_Imm(ElFinalTypeId);

          Prg.AsmPush_REG(Reg1); // dest
          Prg.AsmPush_REG(Reg2); // source

          EmitGet_REG(Reg, SymbolTable[SubId]);
          Prg.AsmCall_REG(Reg);

          FreeReg(Reg);
        end;
        typeRECORD:
          AssignRec(Reg1, Reg2, RI.TerminalTypeId);
        typeARRAY:
          AssignArr(Reg1, Reg2, RI.TerminalTypeId);
        else
        begin
          Prg.AsmPush_Imm(S);
          Prg.AsmPush_REG(Reg2);
          Prg.AsmPush_REG(Reg1);
          GetReg(_EBX);
          EmitGet_REG(_EBX, SymbolTable[Id_RecordAssign]);
          Prg.AsmCall_REG(_EBX);
          FreeReg(_EBX);
        end;
      end; // case
      Emit_POP_REGS;
    end;
  end;

  procedure AssignArr(Reg1, Reg2, TypeId: Integer);
  var
    RangeTypeId, ElemTypeId, H1, H2, FT, I, ElemSize, S, SubId, Reg: Integer;
  begin
    SymbolTable.GetArrayTypeInfo(TypeId, RangeTypeId, ElemTypeId);
    H1 := SymbolTable.GetLowBoundRec(RangeTypeId).Value;
    H2 := SymbolTable.GetHighBoundRec(RangeTypeId).Value;

    ElemSize := SymbolTable[ElemTypeId].Size;

    FT := SymbolTable[ElemTypeId].FinalTypeId;

    SubId := 0;

    case FT of
      typeANSISTRING, typeWIDESTRING, typeUNICSTRING, typeDYNARRAY,
      typeVARIANT, typeOLEVARIANT, typeINTERFACE:
      begin
        case FT of
          typeANSISTRING: SubId := Id_AnsiStringAssign;
          typeUNICSTRING: SubId := Id_UnicStringAssign;
          typeWIDESTRING: SubId := Id_WideStringAssign;
          typeSHORTSTRING: SubId := Id_ShortStringAssign;
          typeVARIANT, typeOLEVARIANT: SubId := Id_VariantAssign;
          typeINTERFACE: SubId := Id_InterfaceAssign;
        end;
        for I:=0 to H2 - H1 do
        begin
          Emit_PUSH_REGS;
          Prg.AsmAddREG_Imm(Reg1, I * ElemSize);
          Prg.AsmAddREG_Imm(Reg2, I * ElemSize);
          Reg := GetReg;
          Prg.AsmPush_REG(Reg1);
          Prg.AsmPush_REG(Reg2);
          EmitGet_REG(Reg, SymbolTable[SubId]);
          Prg.AsmCall_REG(Reg);
          FreeReg(Reg);
          Emit_POP_REGS;
        end;
      end;
      typeRECORD:
      begin
        TypeID := SymbolTable.TerminalTypeOf(ElemTypeId);
        for I:=0 to H2 - H1 do
        begin
          Emit_PUSH_REGS;
          Prg.AsmAddREG_Imm(Reg1, I * ElemSize);
          Prg.AsmAddREG_Imm(Reg2, I * ElemSize);
          AssignRec(Reg1, Reg2, TypeId);
          Emit_POP_REGS;
        end;
      end;
      typeARRAY:
      begin
        TypeID := SymbolTable.TerminalTypeOf(ElemTypeId);
        for I:=0 to H2 - H1 do
        begin
          Emit_PUSH_REGS;
          Prg.AsmAddREG_Imm(Reg1, I * ElemSize);
          Prg.AsmAddREG_Imm(Reg2, I * ElemSize);
          AssignArr(Reg1, Reg2, TypeId);
          Emit_POP_REGS;
        end;
      end;
      else
      begin
        S := SymbolTable[TypeId].PtrSize;
        Prg.AsmPush_Imm(S);
        Prg.AsmPush_REG(Reg2);
        Prg.AsmPush_REG(Reg1);
        GetReg(_EBX);
        EmitGet_REG(_EBX, SymbolTable[Id_RecordAssign]);
        Prg.AsmCall_REG(_EBX);
        FreeReg(_EBX);
      end;
    end; // case
  end;

var
  Reg1, Reg2, S, FT: Integer;
begin
  EmitPCodeOperator;
  SymbolTable := TKernel(kernel).SymbolTable;
  Reg1 := GetReg;
  Reg2 := GetReg;
  EmitLoadAddress(Reg1, SymbolRec1); // source
  EmitLoadAddress(Reg2, SymbolRec2); // dest
  FT := SymbolRec1.FinalTypeId;
  case FT of
    typeRECORD:
    begin
      AssignRec(Reg1, Reg2, SymbolRec1.TerminalTypeId);
    end;
    typeARRAY:
    begin
      AssignArr(Reg1, Reg2, SymbolRec1.TerminalTypeId);
    end;
    else
    begin
      S := SymbolRec1.PtrSize;
      Prg.AsmPush_Imm(S);
      Prg.AsmPush_REG(Reg2);
      Prg.AsmPush_REG(Reg1);
      GetReg(_EBX);
      EmitGet_REG(_EBX, SymbolTable[Id_RecordAssign]);
      Prg.AsmCall_REG(_EBX);
      FreeReg(_EBX);
    end;
  end;
  FreeReg(Reg1);
  FreeReg(Reg2);
end;

procedure TEmitter.EmitOP_ASSIGN_DOUBLE;
begin
  EmitPCodeOperator;

  EmitFld(SymbolRec2);
  EmitFstp(SymbolRec1);
end;

procedure TEmitter.EmitOP_ASSIGN_CURRENCY;
var
  Reg, Reg1, Reg2: Integer;
begin
  EmitPCodeOperator;

  Reg := GetReg;
  Reg1 := GetReg;
  Reg2 := GetReg;

  EmitLoadAddress(Reg1, SymbolRec1);
  EmitLoadAddress(Reg2, SymbolRec2);

  Prg.AsmMovREG32_REGPtr(Reg, Reg2);
  Prg.AsmMovREGPtr_REG32(Reg1, Reg);

  Prg.AsmAddREG_Imm(Reg1, 4);
  Prg.AsmAddREG_Imm(Reg2, 4);

  Prg.AsmMovREG32_REGPtr(Reg, Reg2);
  Prg.AsmMovREGPtr_REG32(Reg1, Reg);

  FreeReg(Reg);
  FreeReg(Reg1);
  FreeReg(Reg2);
end;

procedure TEmitter.EmitOP_ASSIGN_SINGLE;
begin
  EmitPCodeOperator;

  EmitFld(SymbolRec2);
  EmitFstp(SymbolRec1);
end;

procedure TEmitter.EmitOP_ASSIGN_EXTENDED;
begin
  EmitPCodeOperator;

  EmitFld(SymbolRec2);
  EmitFstp(SymbolRec1);
end;

procedure TEmitter.EmitOP_ASSIGN_INT64;
var
  Reg, Reg1, Reg2: Integer;
begin
  EmitPCodeOperator;

  Reg := GetReg;
  Reg1 := GetReg;
  Reg2 := GetReg;

  EmitLoadAddress(Reg1, SymbolRec1);
  EmitLoadAddress(Reg2, SymbolRec2);

  Prg.AsmMovREG32_REGPtr(Reg, Reg2);
  Prg.AsmMovREGPtr_REG32(Reg1, Reg);

  Prg.AsmAddREG_Imm(Reg1, 4);
  Prg.AsmAddREG_Imm(Reg2, 4);

  Prg.AsmMovREG32_REGPtr(Reg, Reg2);
  Prg.AsmMovREGPtr_REG32(Reg1, Reg);

  FreeReg(Reg);
  FreeReg(Reg1);
  FreeReg(Reg2);
end;

procedure TEmitter.EmitFistp(S: TSymbolRec);
var
  Reg: Integer;
begin
  Reg := GetReg;
  EmitLoadAddress(Reg, S);
  Prg.AsmFistp_REG64Ptr(Reg);
  FreeReg(Reg);
  Prg.AsmWait;
end;

procedure TEmitter.EmitOP_CURRENCY_FROM_INT;
begin
  EmitPCodeOperator;

  EmitFild(SymbolRec2);
  EmitFMul_10000;
  EmitFistp(SymbolRecR);
end;

procedure TEmitter.EmitOP_CURRENCY_FROM_INT64;
begin
  EmitPCodeOperator;

  EmitFild(SymbolRec2);
  EmitFMul_10000;
  EmitFistp(SymbolRecR);
end;

procedure TEmitter.EmitOP_CURRENCY_FROM_REAL;
begin
  EmitPCodeOperator;

  EmitFLD(SymbolRec2);
  EmitFMul_10000;
  EmitFistp(SymbolRecR);
end;

procedure TEmitter.EmitCheckOperResult(Reg: Integer);
var
  SubId, T: Integer;
begin
  if OverflowCheck = false then
    Exit;

  T := SymbolRecR.FinalTypeId;

  case T of
    typeINTEGER:
    begin
      GetReg(_EBX);
      SubId := Id_IntOver;
      Prg.AsmJNO_Imm(8);
      EmitGet_REG(_EBX, SymbolTable[SubId]); // 6 bytes
      Prg.AsmCall_REG(_EBX);                 // 2 bytes
      FreeReg(_EBX);
    end;
    typeCARDINAL:
    begin
      GetReg(_EBX);
      SubId := Id_IntOver;
      Prg.AsmJNC_Imm(8);
      EmitGet_REG(_EBX, SymbolTable[SubId]); // 6 bytes
      Prg.AsmCall_REG(_EBX);                 // 2 bytes
      FreeReg(_EBX);
    end;
    typeBYTE:
    begin
      GetReg(_EBX);
      SubId := Id_BoundError;
      Prg.AsmCmpReg_Imm(Reg, $ff);
      Prg.AsmJBE_Imm(8);
      EmitGet_REG(_EBX, SymbolTable[SubId]); // 6 bytes
      Prg.AsmCall_REG(_EBX);                 // 2 bytes
      FreeReg(_EBX);
    end;
    typeWORD:
    begin
      GetReg(_EBX);
      SubId := Id_BoundError;
      Prg.AsmCmpReg_Imm(Reg, $ffff);
      Prg.AsmJBE_Imm(8);
      EmitGet_REG(_EBX, SymbolTable[SubId]); // 6 bytes
      Prg.AsmCall_REG(_EBX);                 // 2 bytes
      FreeReg(_EBX);
    end;
  end;
end;

procedure TEmitter.EmitOP_ADD_INT_MI;
var
  Reg: Integer;
begin
  EmitPCodeOperator;

  if (SymbolRec1 = SymbolRecR) and (SymbolRecR.Size = 4) then
  begin
    Reg := EmitGetAddressRegister(SymbolRec1);
    Prg.AsmAddREGPtr_Imm(Reg, SymbolRec1, ImmValue2);
    EmitCheckOperResult(Reg);
    FreeReg(Reg);
  end
  else
  begin
    Reg := GetReg;
    EmitLoadIntVal(Reg, SymbolRec1);
    Prg.AsmAddREG_Imm(Reg, ImmValue2);
    EmitCheckOperResult(Reg);
    EmitSaveIntVal(Reg, SymbolRecR);
    FreeReg(Reg);
  end;
end;

procedure TEmitter.EmitOP_ADD_INT_MM;
var
  Reg1, Reg2: Integer;
begin
  EmitPCodeOperator;

  Reg1 := GetReg;
  Reg2 := GetReg;

  EmitLoadIntVal(Reg1, SymbolRec1);
  EmitLoadIntVal(Reg2, SymbolRec2);

  Prg.AsmAddREG_REG(Reg1, Reg2);
  EmitCheckOperResult(Reg1);

  FreeReg(Reg2);
  EmitSaveIntVal(Reg1, SymbolRecR);

  FreeReg(Reg1);
end;

procedure TEmitter.EmitOP_NEG_INT;
var
  Reg: Integer;
begin
  EmitPCodeOperator;

  if (SymbolRec1 = SymbolRecR) and (SymbolRec1.PtrSize = 4) then
  begin
    Reg := EmitGetAddressRegister(SymbolRec1);
    Prg.AsmNEG_REGPtr(Reg, SymbolRec1);
    EmitCheckOperResult(Reg);
    FreeReg(Reg);
  end
  else
  begin
    Reg := GetReg;
    EmitLoadIntVal(Reg, SymbolRec1);
    Prg.AsmNEGREG(Reg);
    EmitCheckOperResult(Reg);
    EmitSaveIntVal(Reg, SymbolRecR);
    FreeReg(Reg);
  end;
end;

procedure TEmitter.EmitOP_NOT;
var
  Reg1, Reg2: Integer;
begin
  EmitPCodeOperator;

  Reg1 := GetReg;
  EmitLoadIntVal(Reg1, SymbolRec1);
  
  Reg2 := GetReg;
  Prg.AsmMovREG_Imm(Reg2, 1);
  Prg.AsmXorREG_REG(Reg1, Reg2);
  FreeReg(Reg2);

  EmitSaveIntVal(Reg1, SymbolRecR);
  FreeReg(Reg1);
end;

procedure TEmitter.EmitOP_SUB_INT_MI;
var
  Reg: Integer;
begin
  EmitPCodeOperator;

  Reg := GetReg;
  EmitLoadIntVal(Reg, SymbolRec1);
  Prg.AsmSubREG_Imm(Reg, ImmValue2);
  EmitCheckOperResult(Reg);
  EmitSaveIntVal(Reg, SymbolRecR);
  FreeReg(Reg);
end;

procedure TEmitter.EmitOP_SUB_INT_MM;
var
  Reg1, Reg2: Integer;
begin
  EmitPCodeOperator;

  Reg1 := GetReg;
  Reg2 := GetReg;

  EmitLoadIntVal(Reg1, SymbolRec1);
  EmitLoadIntVal(Reg2, SymbolRec2);

  Prg.AsmSubREG_REG(Reg1, Reg2);
  EmitCheckOperResult(Reg1);

  FreeReg(Reg2);
  EmitSaveIntVal(Reg1, SymbolRecR);

  FreeReg(Reg1);
end;

procedure TEmitter.EmitOP_IMUL_INT_MI;
var
  Reg2: Integer;
begin
  EmitPCodeOperator;

  GetReg(_EAX);
  Reg2 := GetReg;

  EmitLoadIntVal(_EAX, SymbolRec1);
  Prg.AsmMovREG_Imm(Reg2, SymbolRec2.Value);

  Prg.AsmIMulREG(Reg2);
  EmitCheckOperResult(_EAX);

  FreeReg(Reg2);
  EmitSaveIntVal(_EAX, SymbolRecR);

  FreeReg(_EAX);
end;

procedure TEmitter.EmitOP_IMUL_INT_MM;
var
  Reg2: Integer;
begin
  EmitPCodeOperator;

  GetReg(_EAX);
  Reg2 := GetReg;

  EmitLoadIntVal(_EAX, SymbolRec1);
  EmitLoadIntVal(Reg2, SymbolRec2);

  Prg.AsmIMulREG(Reg2);
  EmitCheckOperResult(_EAX);

  FreeReg(Reg2);
  EmitSaveIntVal(_EAX, SymbolRecR);

  FreeReg(_EAX);
end;

procedure TEmitter.EmitOP_IDIV_INT_MI;
var
  Reg2: Integer;
begin
  EmitPCodeOperator;

  GetReg(_EAX);
  Reg2 := GetReg;

  EmitLoadIntVal(_EAX, SymbolRec1);
  Prg.AsmMovREG_Imm(Reg2, SymbolRec2.Value);

  Prg.AsmCDQ;
  Prg.AsmIDivREG(Reg2);

  FreeReg(Reg2);
  EmitSaveIntVal(_EAX, SymbolRecR);

  FreeReg(_EAX);
end;

procedure TEmitter.EmitOP_IDIV_INT_MM;
var
  Reg2: Integer;
begin
  EmitPCodeOperator;

  GetReg(_EAX);
  Reg2 := GetReg;

  EmitLoadIntVal(_EAX, SymbolRec1);
  EmitLoadIntVal(Reg2, SymbolRec2);

  Prg.AsmCDQ;
  Prg.AsmIDivREG(Reg2);

  FreeReg(Reg2);
  EmitSaveIntVal(_EAX, SymbolRecR);

  FreeReg(_EAX);
end;

procedure TEmitter.EmitOP_IDIV_INT_IM;
var
  Reg2: Integer;
begin
  EmitPCodeOperator;

  GetReg(_EAX);
  Reg2 := GetReg;

  Prg.AsmMovREG_Imm(_EAX, SymbolRec1.Value);
  EmitLoadIntVal(Reg2, SymbolRec2);

  Prg.AsmCDQ;
  Prg.AsmIDivREG(Reg2);

  FreeReg(Reg2);
  EmitSaveIntVal(_EAX, SymbolRecR);

  FreeReg(_EAX);
end;

procedure TEmitter.EmitOP_MOD_INT_MI;
var
  Reg2: Integer;
begin
  EmitPCodeOperator;

  GetReg(_EAX);
  GetReg(_EDX);
  Reg2 := GetReg;

  EmitLoadIntVal(_EAX, SymbolRec1);
  Prg.AsmMovREG_Imm(Reg2, SymbolRec2.Value);

  Prg.AsmCDQ;
  Prg.AsmIDivREG(Reg2);

  FreeReg(Reg2);
  EmitSaveIntVal(_EDX, SymbolRecR);

  FreeReg(_EDX);
  FreeReg(_EAX);
end;

procedure TEmitter.EmitOP_MOD_INT_MM;
var
  Reg2: Integer;
begin
  EmitPCodeOperator;

  GetReg(_EAX);
  GetReg(_EDX);
  Reg2 := GetReg;

  EmitLoadIntVal(_EAX, SymbolRec1);
  EmitLoadIntVal(Reg2, SymbolRec2);

  Prg.AsmCDQ;
  Prg.AsmIDivREG(Reg2);

  FreeReg(Reg2);
  EmitSaveIntVal(_EDX, SymbolRecR);

  FreeReg(_EDX);
  FreeReg(_EAX);
end;

procedure TEmitter.EmitOP_MOD_INT_IM;
var
  Reg2: Integer;
begin
  EmitPCodeOperator;

  GetReg(_EAX);
  GetReg(_EDX);
  Reg2 := GetReg;

  Prg.AsmMovREG_Imm(_EAX, SymbolRec1.Value);
  EmitLoadIntVal(Reg2, SymbolRec2);

  Prg.AsmCDQ;
  Prg.AsmIDivREG(Reg2);

  FreeReg(Reg2);
  EmitSaveIntVal(_EDX, SymbolRecR);

  FreeReg(_EDX);
  FreeReg(_EAX);
end;

procedure TEmitter.EmitOP_SHL_INT_MI;
var
  Reg: Integer;
begin
  EmitPCodeOperator;

  GetReg(_ECX);
  Reg := GetReg;

  Prg.AsmXorREG_REG(Reg, Reg);
  EmitLoadIntVal(Reg, SymbolRec1);
  Prg.AsmMovREG_Imm(_ECX, SymbolRec2.Value);
  Prg.AsmShlREG(Reg);
  EmitSaveIntVal(Reg, SymbolRecR);

  FreeReg(Reg);
  FreeReg(_ECX);
end;

procedure TEmitter.EmitOP_SHL_INT_MM;
var
  Reg: Integer;
begin
  EmitPCodeOperator;

  GetReg(_ECX);
  Reg := GetReg;

  Prg.AsmXorREG_REG(Reg, Reg);
  EmitLoadIntVal(Reg, SymbolRec1);
  EmitLoadIntVal(_ECX, SymbolRec2);
  Prg.AsmShlREG(Reg);
  EmitSaveIntVal(Reg, SymbolRecR);

  FreeReg(Reg);
  FreeReg(_ECX);
end;

procedure TEmitter.EmitOP_SHL_INT_IM;
var
  Reg: Integer;
begin
  EmitPCodeOperator;

  GetReg(_ECX);
  Reg := GetReg;

  Prg.AsmMovREG_Imm(Reg, SymbolRec1.Value);
  EmitLoadIntVal(_ECX, SymbolRec2);
  Prg.AsmShlREG(Reg);
  EmitSaveIntVal(Reg, SymbolRecR);

  FreeReg(Reg);
  FreeReg(_ECX);
end;

procedure TEmitter.EmitOP_SHR_INT_MI;
var
  Reg: Integer;
begin
  EmitPCodeOperator;

  GetReg(_ECX);
  Reg := GetReg;

  Prg.AsmXorREG_REG(Reg, Reg);
  EmitLoadIntVal(Reg, SymbolRec1);
  Prg.AsmMovREG_Imm(_ECX, SymbolRec2.Value);
  Prg.AsmShrREG(Reg);
  EmitSaveIntVal(Reg, SymbolRecR);

  FreeReg(Reg);
  FreeReg(_ECX);
end;

procedure TEmitter.EmitOP_SHR_INT_MM;
var
  Reg: Integer;
begin
  EmitPCodeOperator;

  GetReg(_ECX);
  Reg := GetReg;

  Prg.AsmXorREG_REG(Reg, Reg);
  EmitLoadIntVal(Reg, SymbolRec1);
  EmitLoadIntVal(_ECX, SymbolRec2);
  Prg.AsmShrREG(Reg);
  EmitSaveIntVal(Reg, SymbolRecR);

  FreeReg(Reg);
  FreeReg(_ECX);
end;

procedure TEmitter.EmitOP_SHR_INT_IM;
var
  Reg: Integer;
begin
  EmitPCodeOperator;

  GetReg(_ECX);
  Reg := GetReg;

  Prg.AsmMovREG_Imm(Reg, SymbolRec1.Value);
  EmitLoadIntVal(_ECX, SymbolRec2);
  Prg.AsmShrREG(Reg);
  EmitSaveIntVal(Reg, SymbolRecR);

  FreeReg(Reg);
  FreeReg(_ECX);
end;

procedure TEmitter.EmitOP_AND_INT_MI;
var
  Reg1, Reg2: Integer;
begin
  EmitPCodeOperator;

  Reg1 := GetReg;
  Reg2 := GetReg;

  EmitLoadIntVal(Reg1, SymbolRec1);
  Prg.AsmMovREG_Imm(Reg2, SymbolRec2.Value);
  Prg.AsmAndREG_REG(Reg1, Reg2);
  EmitSaveIntVal(Reg1, SymbolRecR);

  FreeReg(Reg2);
  FreeReg(Reg1);
end;

procedure TEmitter.EmitOP_AND_INT_MM;
var
  Reg1, Reg2: Integer;
begin
  EmitPCodeOperator;

  Reg1 := GetReg;
  Reg2 := GetReg;

  EmitLoadIntVal(Reg1, SymbolRec1);
  EmitLoadIntVal(Reg2, SymbolRec2);
  Prg.AsmAndREG_REG(Reg1, Reg2);
  EmitSaveIntVal(Reg1, SymbolRecR);

  FreeReg(Reg2);
  FreeReg(Reg1);
end;

procedure TEmitter.EmitOP_OR_INT_MI;
var
  Reg1, Reg2: Integer;
begin
  EmitPCodeOperator;

  Reg1 := GetReg;
  Reg2 := GetReg;

  EmitLoadIntVal(Reg1, SymbolRec1);
  Prg.AsmMovREG_Imm(Reg2, SymbolRec2.Value);
  Prg.AsmOrREG_REG(Reg1, Reg2);
  EmitSaveIntVal(Reg1, SymbolRecR);

  FreeReg(Reg2);
  FreeReg(Reg1);
end;

procedure TEmitter.EmitOP_OR_INT_MM;
var
  Reg1, Reg2: Integer;
begin
  EmitPCodeOperator;

  Reg1 := GetReg;
  Reg2 := GetReg;

  EmitLoadIntVal(Reg1, SymbolRec1);
  EmitLoadIntVal(Reg2, SymbolRec2);
  Prg.AsmOrREG_REG(Reg1, Reg2);
  EmitSaveIntVal(Reg1, SymbolRecR);

  FreeReg(Reg2);
  FreeReg(Reg1);
end;

procedure TEmitter.EmitOP_XOR_INT_MI;
var
  Reg1, Reg2: Integer;
begin
  EmitPCodeOperator;

  Reg1 := GetReg;
  Reg2 := GetReg;

  EmitLoadIntVal(Reg1, SymbolRec1);
  Prg.AsmMovREG_Imm(Reg2, SymbolRec2.Value);
  Prg.AsmXorREG_REG(Reg1, Reg2);
  EmitSaveIntVal(Reg1, SymbolRecR);

  FreeReg(Reg2);
  FreeReg(Reg1);
end;

procedure TEmitter.EmitOP_XOR_INT_MM;
var
  Reg1, Reg2: Integer;
begin
  EmitPCodeOperator;

  Reg1 := GetReg;
  Reg2 := GetReg;

  EmitLoadIntVal(Reg1, SymbolRec1);
  EmitLoadIntVal(Reg2, SymbolRec2);
  Prg.AsmXorREG_REG(Reg1, Reg2);
  EmitSaveIntVal(Reg1, SymbolRecR);

  FreeReg(Reg2);
  FreeReg(Reg1);
end;

procedure TEmitter.EmitOP_ADD_INT64;
begin
  EmitPCodeOperator;

  GetReg(_ECX);
  GetReg(_EAX);
  GetReg(_EDX);

  Prg.AsmClc;

//  EAX:EDX <-- [N1]

  EmitLoadAddress(_ECX, SymbolRec1);
  Prg.AsmMovREG32_REGPtr(_EAX, _ECX);
  Prg.AsmAddREG_Imm(_ECX, 4);
  Prg.AsmMovREG32_REGPtr(_EDX, _ECX);

// ADD EAX, [N2]

  EmitLoadAddress(_ECX, SymbolRec2);
  Prg.AsmMovREG32_REGPtr(_ECX, _ECX);
  Prg.AsmAddREG_REG(_EAX, _ECX);

  Prg.AsmPushfd;

// ADC EDX, [N2 + 4]

  EmitLoadAddress(_ECX, SymbolRec2);
  Prg.AsmAddREG_Imm(_ECX, 4);
  Prg.AsmMovREG32_REGPtr(_ECX, _ECX);
  Prg.AsmPopfd;
  Prg.AsmAdcREG_REG(_EDX, _ECX);

// EAX:EDX --> [N2]

  EmitLoadAddress(_ECX, SymbolRecR);
  Prg.AsmMovREGPtr_REG32(_ECX, _EAX);
  Prg.AsmAddREG_Imm(_ECX, 4);
  Prg.AsmMovREGPtr_REG32(_ECX, _EDX);

  FreeReg(_EAX);
  FreeReg(_EDX);
  FreeReg(_ECX);
end;

procedure TEmitter.EmitOP_NEG_INT64;
begin
  EmitPCodeOperator;

  GetReg(_EAX);
  GetReg(_EDX);
  GetReg(_ECX);

  Prg.AsmClc;

//  EAX:EDX <-- [N1]

  EmitLoadAddress(_ECX, SymbolRec1);
  Prg.AsmMovREG32_REGPtr(_EAX, _ECX);
  Prg.AsmAddREG_Imm(_ECX, 4);
  Prg.AsmMovREG32_REGPtr(_EDX, _ECX);

  Prg.AsmXorREG_REG(_ECX, _ECX);
  Prg.AsmNegREG(_EAX);
  Prg.AsmXCHG(_EDX, _ECX);
  Prg.AsmSbbREG_REG(_EDX, _ECX);

// EAX:EDX --> [N2]

  EmitLoadAddress(_ECX, SymbolRecR);
  Prg.AsmMovREGPtr_REG32(_ECX, _EAX);
  Prg.AsmAddREG_Imm(_ECX, 4);
  Prg.AsmMovREGPtr_REG32(_ECX, _EDX);

  FreeReg(_EAX);
  FreeReg(_EDX);
  FreeReg(_ECX);
end;

procedure TEmitter.EmitOP_SUB_INT64;
begin
  EmitPCodeOperator;

  GetReg(_ECX);
  GetReg(_EAX);
  GetReg(_EDX);

//  EAX:EDX <-- [N1]

  EmitLoadAddress(_ECX, SymbolRec1);
  Prg.AsmMovREG32_REGPtr(_EAX, _ECX);
  Prg.AsmAddREG_Imm(_ECX, 4);
  Prg.AsmMovREG32_REGPtr(_EDX, _ECX);

// SUB EAX, [N2]

  EmitLoadAddress(_ECX, SymbolRec2);
  Prg.AsmMovREG32_REGPtr(_ECX, _ECX);
  Prg.AsmSubREG_REG(_EAX, _ECX);

  Prg.AsmPushfd;

// SBB EDX, [N2 + 4]

  EmitLoadAddress(_ECX, SymbolRec2);
  Prg.AsmAddREG_Imm(_ECX, 4);
  Prg.AsmMovREG32_REGPtr(_ECX, _ECX);
  Prg.AsmPopfd;
  Prg.AsmSbbREG_REG(_EDX, _ECX);

// EAX:EDX --> [N2]

  EmitLoadAddress(_ECX, SymbolRecR);
  Prg.AsmMovREGPtr_REG32(_ECX, _EAX);
  Prg.AsmAddREG_Imm(_ECX, 4);
  Prg.AsmMovREGPtr_REG32(_ECX, _EDX);

  FreeReg(_EAX);
  FreeReg(_EDX);
  FreeReg(_ECX);
end;

procedure TEmitter.EmitOP_AND_INT64;
begin
  EmitPCodeOperator;

  GetReg(_ECX);
  GetReg(_EAX);
  GetReg(_EDX);

//  EAX:EDX <-- [N1]

  EmitLoadAddress(_ECX, SymbolRec1);
  Prg.AsmMovREG32_REGPtr(_EAX, _ECX);
  Prg.AsmAddREG_Imm(_ECX, 4);
  Prg.AsmMovREG32_REGPtr(_EDX, _ECX);

// AND EAX, [N2]

  EmitLoadAddress(_ECX, SymbolRec2);
  Prg.AsmMovREG32_REGPtr(_ECX, _ECX);
  Prg.AsmAndREG_REG(_EAX, _ECX);

// AND EDX, [N2 + 4]

  EmitLoadAddress(_ECX, SymbolRec2);
  Prg.AsmAddREG_Imm(_ECX, 4);
  Prg.AsmMovREG32_REGPtr(_ECX, _ECX);
  Prg.AsmAndREG_REG(_EDX, _ECX);

// EAX:EDX --> [N2]

  EmitLoadAddress(_ECX, SymbolRecR);
  Prg.AsmMovREGPtr_REG32(_ECX, _EAX);
  Prg.AsmAddREG_Imm(_ECX, 4);
  Prg.AsmMovREGPtr_REG32(_ECX, _EDX);

  FreeReg(_EAX);
  FreeReg(_EDX);
  FreeReg(_ECX);
end;

procedure TEmitter.EmitOP_OR_INT64;
begin
  EmitPCodeOperator;

  GetReg(_ECX);
  GetReg(_EAX);
  GetReg(_EDX);

//  EAX:EDX <-- [N1]

  EmitLoadAddress(_ECX, SymbolRec1);
  Prg.AsmMovREG32_REGPtr(_EAX, _ECX);
  Prg.AsmAddREG_Imm(_ECX, 4);
  Prg.AsmMovREG32_REGPtr(_EDX, _ECX);

// OR EAX, [N2]

  EmitLoadAddress(_ECX, SymbolRec2);
  Prg.AsmMovREG32_REGPtr(_ECX, _ECX);
  Prg.AsmOrREG_REG(_EAX, _ECX);

// OR EDX, [N2 + 4]

  EmitLoadAddress(_ECX, SymbolRec2);
  Prg.AsmAddREG_Imm(_ECX, 4);
  Prg.AsmMovREG32_REGPtr(_ECX, _ECX);
  Prg.AsmOrREG_REG(_EDX, _ECX);

// EAX:EDX --> [N2]

  EmitLoadAddress(_ECX, SymbolRecR);
  Prg.AsmMovREGPtr_REG32(_ECX, _EAX);
  Prg.AsmAddREG_Imm(_ECX, 4);
  Prg.AsmMovREGPtr_REG32(_ECX, _EDX);

  FreeReg(_EAX);
  FreeReg(_EDX);
  FreeReg(_ECX);
end;

procedure TEmitter.EmitOP_XOR_INT64;
begin
  EmitPCodeOperator;

  GetReg(_ECX);
  GetReg(_EAX);
  GetReg(_EDX);

//  EAX:EDX <-- [N1]

  EmitLoadAddress(_ECX, SymbolRec1);
  Prg.AsmMovREG32_REGPtr(_EAX, _ECX);
  Prg.AsmAddREG_Imm(_ECX, 4);
  Prg.AsmMovREG32_REGPtr(_EDX, _ECX);

// XOR EAX, [N2]

  EmitLoadAddress(_ECX, SymbolRec2);
  Prg.AsmMovREG32_REGPtr(_ECX, _ECX);
  Prg.AsmXorREG_REG(_EAX, _ECX);

// XOR EDX, [N2 + 4]

  EmitLoadAddress(_ECX, SymbolRec2);
  Prg.AsmAddREG_Imm(_ECX, 4);
  Prg.AsmMovREG32_REGPtr(_ECX, _ECX);
  Prg.AsmXorREG_REG(_EDX, _ECX);

// EAX:EDX --> [N2]

  EmitLoadAddress(_ECX, SymbolRecR);
  Prg.AsmMovREGPtr_REG32(_ECX, _EAX);
  Prg.AsmAddREG_Imm(_ECX, 4);
  Prg.AsmMovREGPtr_REG32(_ECX, _EDX);

  FreeReg(_EAX);
  FreeReg(_EDX);
  FreeReg(_ECX);
end;

procedure TEmitter.EmitOP_GT_INT64;
var
  SubId, Reg: Integer;
begin
  EmitPCodeOperator;

  SubId := Id_Int64GreaterThan;

  Reg := GetReg;

  EmitLoadAddress(Reg, SymbolRecR); // dest
  Prg.AsmPush_REG(Reg);

  EmitLoadAddress(Reg, SymbolRec2); // source
  Prg.AsmPush_REG(Reg);

  EmitLoadAddress(Reg, SymbolRec1); // source
  Prg.AsmPush_REG(Reg);

  EmitGet_REG(Reg, SymbolTable[SubId]);
  Prg.AsmCall_REG(Reg);

  FreeReg(Reg);
end;

procedure TEmitter.EmitOP_GE_INT64;
var
  SubId, Reg: Integer;
begin
  EmitPCodeOperator;

  SubId := Id_Int64GreaterThanOrEqual;

  Reg := GetReg;

  EmitLoadAddress(Reg, SymbolRecR); // dest
  Prg.AsmPush_REG(Reg);

  EmitLoadAddress(Reg, SymbolRec2); // source
  Prg.AsmPush_REG(Reg);

  EmitLoadAddress(Reg, SymbolRec1); // source
  Prg.AsmPush_REG(Reg);

  EmitGet_REG(Reg, SymbolTable[SubId]);
  Prg.AsmCall_REG(Reg);

  FreeReg(Reg);
end;

procedure TEmitter.EmitOP_LT_INT64;
var
  SubId, Reg: Integer;
begin
  EmitPCodeOperator;

  SubId := Id_Int64LessThan;

  Reg := GetReg;

  EmitLoadAddress(Reg, SymbolRecR); // dest
  Prg.AsmPush_REG(Reg);

  EmitLoadAddress(Reg, SymbolRec2); // source
  Prg.AsmPush_REG(Reg);

  EmitLoadAddress(Reg, SymbolRec1); // source
  Prg.AsmPush_REG(Reg);

  EmitGet_REG(Reg, SymbolTable[SubId]);
  Prg.AsmCall_REG(Reg);

  FreeReg(Reg);
end;

procedure TEmitter.EmitOP_LE_INT64;
var
  SubId, Reg: Integer;
begin
  EmitPCodeOperator;

  SubId := Id_Int64LessThanOrEqual;

  Reg := GetReg;

  EmitLoadAddress(Reg, SymbolRecR); // dest
  Prg.AsmPush_REG(Reg);

  EmitLoadAddress(Reg, SymbolRec2); // source
  Prg.AsmPush_REG(Reg);

  EmitLoadAddress(Reg, SymbolRec1); // source
  Prg.AsmPush_REG(Reg);

  EmitGet_REG(Reg, SymbolTable[SubId]);
  Prg.AsmCall_REG(Reg);

  FreeReg(Reg);
end;

procedure TEmitter.EmitOP_EQ_INT64;
var
  SubId, Reg: Integer;
begin
  EmitPCodeOperator;

  SubId := Id_Int64Equality;

  Reg := GetReg;

  EmitLoadAddress(Reg, SymbolRecR); // dest
  Prg.AsmPush_REG(Reg);

  EmitLoadAddress(Reg, SymbolRec2); // source
  Prg.AsmPush_REG(Reg);

  EmitLoadAddress(Reg, SymbolRec1); // source
  Prg.AsmPush_REG(Reg);

  EmitGet_REG(Reg, SymbolTable[SubId]);
  Prg.AsmCall_REG(Reg);

  FreeReg(Reg);
end;

procedure TEmitter.EmitOP_NE_INT64;
var
  SubId, Reg: Integer;
begin
  EmitPCodeOperator;

  SubId := Id_Int64NotEquality;

  Reg := GetReg;

  EmitLoadAddress(Reg, SymbolRecR); // dest
  Prg.AsmPush_REG(Reg);

  EmitLoadAddress(Reg, SymbolRec2); // source
  Prg.AsmPush_REG(Reg);

  EmitLoadAddress(Reg, SymbolRec1); // source
  Prg.AsmPush_REG(Reg);

  EmitGet_REG(Reg, SymbolTable[SubId]);
  Prg.AsmCall_REG(Reg);

  FreeReg(Reg);
end;

procedure TEmitter.EmitOP_ADD_CURRENCY;
begin
  EmitPCodeOperator;

  if R.Arg1 <> 0 then
  begin
    if SymbolRec1.FinalTypeId <> typeCURRENCY then
    begin
      if SymbolRec1.FinalTypeId in IntegerTypes then
        EmitFild(SymbolRec1)
      else if SymbolRec1.FinalTypeId in RealTypes then
        EmitFld(SymbolRec1)
      else
        RaiseError(errInternalError, []);
      EmitFMul_10000;
    end
    else
      EmitFild(SymbolRec1);
  end;

  EmitFild(SymbolRec2);

  Prg.AsmFAdd;

  if R.Res <> 0 then
    EmitFistp(SymbolRecR);
end;

procedure TEmitter.EmitOP_SUB_CURRENCY;
begin
  EmitPCodeOperator;

  if R.Arg1 <> 0 then
  begin
    if SymbolRec1.FinalTypeId <> typeCURRENCY then
    begin
      if SymbolRec1.FinalTypeId in IntegerTypes then
        EmitFild(SymbolRec1)
      else if SymbolRec1.FinalTypeId in RealTypes then
        EmitFld(SymbolRec1)
      else
        RaiseError(errInternalError, []);

      EmitFMul_10000;

      if TKernel(kernel).Code[TKernel(kernel).Code.N].SwappedArgs then
      begin
        Prg.AsmFChs;
        EmitFild(SymbolRec2);
        Prg.AsmFAdd;
        EmitFistp(SymbolRecR);
        Exit;
      end;
    end
    else
      EmitFild(SymbolRec1);
  end;

  EmitFild(SymbolRec2);

  Prg.AsmFSub;

  if R.Res <> 0 then
    EmitFistp(SymbolRecR);
end;

procedure TEmitter.EmitOP_MUL_CURRENCY;
begin
  EmitPCodeOperator;

  if R.Arg1 <> 0 then
  begin
    if SymbolRec1.FinalTypeId <> typeCURRENCY then
    begin
      if SymbolRec1.FinalTypeId in IntegerTypes then
        EmitFild(SymbolRec1)
      else if SymbolRec1.FinalTypeId in RealTypes then
        EmitFld(SymbolRec1)
      else
        RaiseError(errInternalError, []);
      EmitFild(SymbolRec2);
      Prg.AsmFMul;
      EmitFistp(SymbolRecR);
      Exit;
    end
    else
      EmitFild(SymbolRec1);
  end;

  EmitFild(SymbolRec2);
  Prg.AsmFMul;
  EmitFDiv_10000;

  if R.Res <> 0 then
    EmitFistp(SymbolRecR);
end;

procedure TEmitter.EmitOP_DIV_CURRENCY;
begin
  EmitPCodeOperator;

  if R.Arg1 <> 0 then
  begin
    if SymbolRec1.FinalTypeId <> typeCURRENCY then
    begin
      if SymbolRec1.FinalTypeId in IntegerTypes then
        EmitFild(SymbolRec1)
      else if SymbolRec1.FinalTypeId in RealTypes then
        EmitFld(SymbolRec1)
      else
        RaiseError(errInternalError, []);

      EmitFild(SymbolRec2);
      Prg.AsmFDiv;

      EmitFMul_10000;
      EmitFMul_10000;

      EmitFistp(SymbolRecR);

      Exit;
    end
    else
    begin
      EmitFild(SymbolRec1);

      if SymbolRec2.FinalTypeId <> typeCURRENCY then
      begin
        if SymbolRec2.FinalTypeId in IntegerTypes then
          EmitFild(SymbolRec2)
        else if SymbolRec2.FinalTypeId in RealTypes then
          EmitFld(SymbolRec2)
        else
          RaiseError(errInternalError, []);

        Prg.AsmFDiv;
        EmitFistp(SymbolRecR);

        Exit;
      end;
    end;
  end;

  // both operands are currency

  EmitFild(SymbolRec2);

  Prg.AsmFDiv;

  EmitFMul_10000;

  if R.Res <> 0 then
    EmitFistp(SymbolRecR);
end;

procedure TEmitter.EmitOP_ADD_DOUBLE;
begin
  EmitPCodeOperator;

  EmitFld(SymbolRec1);
  EmitFld(SymbolRec2);
  Prg.AsmFAdd;
  EmitFStp(SymbolRecR);
end;

procedure TEmitter.EmitOP_ADD_SINGLE;
begin
  EmitPCodeOperator;

  EmitFld(SymbolRec1);
  EmitFld(SymbolRec2);
  Prg.AsmFAdd;
  EmitFStp(SymbolRecR);
end;

procedure TEmitter.EmitOP_ADD_EXTENDED;
begin
  EmitPCodeOperator;

  EmitFld(SymbolRec1);
  EmitFld(SymbolRec2);
  Prg.AsmFAdd;
  EmitFStp(SymbolRecR);
end;

procedure TEmitter.EmitOP_ABS_INT;
begin
  EmitPCodeOperator;

  GetReg(_EAX);
  GetReg(_EDX);

  EmitLoadIntVal(_EAX, SymbolRec1);
  Prg.AsmCDQ;
  Prg.AsmXorREG_REG(_EAX, _EDX);
  Prg.AsmSubREG_REG(_EAX, _EDX);
  EmitSaveIntVal(_EAX, SymbolRecR);

  FreeReg(_EAX);
  FreeReg(_EDX);
end;

procedure TEmitter.EmitOP_ABS_DOUBLE;
begin
  EmitPCodeOperator;

  EmitFld(SymbolRec1);
  Prg.AsmFAbs;
  EmitFStp(SymbolRecR);
end;

procedure TEmitter.EmitOP_ABS_SINGLE;
begin
  EmitPCodeOperator;

  EmitFld(SymbolRec1);
  Prg.AsmFAbs;
  EmitFStp(SymbolRecR);
end;

procedure TEmitter.EmitOP_ABS_EXTENDED;
begin
  EmitPCodeOperator;

  EmitFld(SymbolRec1);
  Prg.AsmFAbs;
  EmitFStp(SymbolRecR);
end;

procedure TEmitter.EmitOP_NEG_DOUBLE;
begin
  EmitPCodeOperator;

  EmitFld(SymbolRec1);
  Prg.AsmFChs;
  EmitFStp(SymbolRecR);
end;

procedure TEmitter.EmitOP_NEG_CURRENCY;
var
  Reg: Integer;
begin
  EmitPCodeOperator;

  Reg := GetReg;
  EmitLoadAddress(Reg, SymbolRec1);
  Prg.AsmFild_REG64Ptr(Reg);
  Prg.AsmFChs;

  FreeReg(Reg);

  EmitFistp(SymbolRecR);
end;

procedure TEmitter.EmitOP_NEG_SINGLE;
begin
  EmitPCodeOperator;

  EmitFld(SymbolRec1);
  Prg.AsmFChs;
  EmitFStp(SymbolRecR);
end;

procedure TEmitter.EmitOP_NEG_EXTENDED;
begin
  EmitPCodeOperator;

  EmitFld(SymbolRec1);
  Prg.AsmFChs;
  EmitFStp(SymbolRecR);
end;

procedure TEmitter.EmitOP_SUB_DOUBLE;
begin
  EmitPCodeOperator;

  EmitFld(SymbolRec1);
  EmitFld(SymbolRec2);
  Prg.AsmFSub;
  EmitFStp(SymbolRecR);
end;

procedure TEmitter.EmitOP_SUB_SINGLE;
begin
  EmitPCodeOperator;

  EmitFld(SymbolRec1);
  EmitFld(SymbolRec2);
  Prg.AsmFSub;
  EmitFStp(SymbolRecR);
end;

procedure TEmitter.EmitOP_SUB_EXTENDED;
begin
  EmitPCodeOperator;

  EmitFld(SymbolRec1);
  EmitFld(SymbolRec2);
  Prg.AsmFSub;
  EmitFStp(SymbolRecR);
end;

procedure TEmitter.EmitOP_MUL_DOUBLE;
begin
  EmitPCodeOperator;

  EmitFld(SymbolRec1);
  EmitFld(SymbolRec2);
  Prg.AsmFMul;
  EmitFStp(SymbolRecR);
end;

procedure TEmitter.EmitOP_MUL_SINGLE;
begin
  EmitPCodeOperator;

  EmitFld(SymbolRec1);
  EmitFld(SymbolRec2);
  Prg.AsmFMul;
  EmitFStp(SymbolRecR);
end;

procedure TEmitter.EmitOP_MUL_EXTENDED;
begin
  EmitPCodeOperator;

  EmitFld(SymbolRec1);
  EmitFld(SymbolRec2);
  Prg.AsmFMul;
  EmitFStp(SymbolRecR);
end;

procedure TEmitter.EmitOP_DIV_DOUBLE;
begin
  EmitPCodeOperator;

  EmitFld(SymbolRec1);
  EmitFld(SymbolRec2);
  Prg.AsmFDiv;
  EmitFStp(SymbolRecR);
end;

procedure TEmitter.EmitOP_DIV_SINGLE;
begin
  EmitPCodeOperator;

  EmitFld(SymbolRec1);
  EmitFld(SymbolRec2);
  Prg.AsmFDiv;
  EmitFStp(SymbolRecR);
end;

procedure TEmitter.EmitOP_DIV_EXTENDED;
begin
  EmitPCodeOperator;

  EmitFld(SymbolRec1);
  EmitFld(SymbolRec2);
  Prg.AsmFDiv;
  EmitFStp(SymbolRecR);
end;

procedure TEmitter.EmitOP_LT_INT_MI;
var
  Reg, RegR: Integer;
begin
  EmitPCodeOperator;

  if HasTheSameAddressRegister(SymbolRec1, SymbolRecR) then
  begin
    Reg := EmitGetAddressRegister(SymbolRec1);
    Prg.AsmCmpREGPtr_Imm(Reg, SymbolRec1, ImmValue2);
    Prg.AsmSet_REGPtr(ASM_SETL, Reg, SymbolRecR);
    FreeReg(Reg);
  end
  else
  begin
    RegR := GetReg;
    EmitLoadAddress(RegR, SymbolRecR);
    Reg := EmitGetAddressRegister(SymbolRec1);
    Prg.AsmCmpREGPtr_Imm(Reg, SymbolRec1, ImmValue2);
    Prg.AsmSetL_REGPtr(RegR);
    FreeReg(Reg);
    FreeReg(RegR);
  end;
end;

procedure TEmitter.EmitOP_LT_INT_MM;
var
  Reg1, Reg2, RegR: Integer;
begin
  EmitPCodeOperator;

  Reg1 := GetReg;
  Reg2 := GetReg;
  RegR := GetReg;
  EmitLoadAddress(RegR, SymbolRecR);
  EmitLoadIntVal(Reg1, SymbolRec1);
  EmitLoadIntVal(Reg2, SymbolRec2);
  Prg.AsmCmpREG_REG(Reg1, Reg2);
  Prg.AsmSetL_REGPtr(RegR);
  FreeReg(RegR);
  FreeReg(Reg2);
  FreeReg(Reg1);
end;

procedure TEmitter.EmitOP_LE_INT_MI;
var
  Reg, RegR: Integer;
begin
  EmitPCodeOperator;

  if HasTheSameAddressRegister(SymbolRec1, SymbolRecR) then
  begin
    Reg := EmitGetAddressRegister(SymbolRec1);
    Prg.AsmCmpREGPtr_Imm(Reg, SymbolRec1, ImmValue2);
    Prg.AsmSet_REGPtr(ASM_SETLE, Reg, SymbolRecR);
    FreeReg(Reg);
  end
  else
  begin
    RegR := GetReg;
    EmitLoadAddress(RegR, SymbolRecR);
    Reg := EmitGetAddressRegister(SymbolRec1);
    Prg.AsmCmpREGPtr_Imm(Reg, SymbolRec1, ImmValue2);
    Prg.AsmSetLE_REGPtr(RegR);
    FreeReg(Reg);
    FreeReg(RegR);
  end;
end;

procedure TEmitter.EmitOP_LE_INT_MM;
var
  Reg1, Reg2, RegR: Integer;
begin
  EmitPCodeOperator;

  Reg1 := GetReg;
  Reg2 := GetReg;
  RegR := GetReg;
  EmitLoadAddress(RegR, SymbolRecR);
  EmitLoadIntVal(Reg1, SymbolRec1);
  EmitLoadIntVal(Reg2, SymbolRec2);
  Prg.AsmCmpREG_REG(Reg1, Reg2);
  Prg.AsmSetLE_REGPtr(RegR);
  FreeReg(RegR);
  FreeReg(Reg2);
  FreeReg(Reg1);
end;

procedure TEmitter.EmitOP_GT_INT_MI;
var
  Reg, RegR: Integer;
begin
  EmitPCodeOperator;

  if HasTheSameAddressRegister(SymbolRec1, SymbolRecR) then
  begin
    Reg := EmitGetAddressRegister(SymbolRec1);
    Prg.AsmCmpREGPtr_Imm(Reg, SymbolRec1, ImmValue2);
    Prg.AsmSet_REGPtr(ASM_SETNLE, Reg, SymbolRecR);
    FreeReg(Reg);
  end
  else
  begin
    RegR := GetReg;
    EmitLoadAddress(RegR, SymbolRecR);
    Reg := EmitGetAddressRegister(SymbolRec1);
    Prg.AsmCmpREGPtr_Imm(Reg, SymbolRec1, ImmValue2);
    Prg.AsmSetNLE_REGPtr(RegR);
    FreeReg(Reg);
    FreeReg(RegR);
  end;
end;

procedure TEmitter.EmitOP_GT_INT_MM;
var
  Reg1, Reg2, RegR: Integer;
begin
  EmitPCodeOperator;

  Reg1 := GetReg;
  Reg2 := GetReg;
  RegR := GetReg;
  EmitLoadAddress(RegR, SymbolRecR);
  EmitLoadIntVal(Reg1, SymbolRec1);
  EmitLoadIntVal(Reg2, SymbolRec2);
  Prg.AsmCmpREG_REG(Reg1, Reg2);
  Prg.AsmSetNLE_REGPtr(RegR);
  FreeReg(RegR);
  FreeReg(Reg2);
  FreeReg(Reg1);
end;

procedure TEmitter.EmitOP_GE_INT_MI;
var
  Reg, RegR: Integer;
begin
  EmitPCodeOperator;

  if HasTheSameAddressRegister(SymbolRec1, SymbolRecR) then
  begin
    Reg := EmitGetAddressRegister(SymbolRec1);
    Prg.AsmCmpREGPtr_Imm(Reg, SymbolRec1, ImmValue2);
    Prg.AsmSet_REGPtr(ASM_SETNL, Reg, SymbolRecR);
    FreeReg(Reg);
  end
  else
  begin
    RegR := GetReg;
    EmitLoadAddress(RegR, SymbolRecR);
    Reg := EmitGetAddressRegister(SymbolRec1);
    Prg.AsmCmpREGPtr_Imm(Reg, SymbolRec1, ImmValue2);
    Prg.AsmSetNL_REGPtr(RegR);
    FreeReg(Reg);
    FreeReg(RegR);
  end;
end;

procedure TEmitter.EmitOP_GE_INT_MM;
var
  Reg1, Reg2, RegR: Integer;
begin
  EmitPCodeOperator;

  Reg1 := GetReg;
  Reg2 := GetReg;
  RegR := GetReg;
  EmitLoadAddress(RegR, SymbolRecR);
  EmitLoadIntVal(Reg1, SymbolRec1);
  EmitLoadIntVal(Reg2, SymbolRec2);
  Prg.AsmCmpREG_REG(Reg1, Reg2);
  Prg.AsmSetNL_REGPtr(RegR);
  FreeReg(RegR);
  FreeReg(Reg2);
  FreeReg(Reg1);
end;

procedure TEmitter.EmitOP_EQ_INT_MI;
var
  Reg, RegR: Integer;
begin
  EmitPCodeOperator;

  if HasTheSameAddressRegister(SymbolRec1, SymbolRecR) then
  begin
    Reg := EmitGetAddressRegister(SymbolRec1);
    Prg.AsmCmpREGPtr_Imm(Reg, SymbolRec1, ImmValue2);
    Prg.AsmSet_REGPtr(ASM_SETZ, Reg, SymbolRecR);
    FreeReg(Reg);
  end
  else
  begin
    RegR := GetReg;
    EmitLoadAddress(RegR, SymbolRecR);
    Reg := EmitGetAddressRegister(SymbolRec1);
    Prg.AsmCmpREGPtr_Imm(Reg, SymbolRec1, ImmValue2);
    Prg.AsmSetZ_REGPtr(RegR);
    FreeReg(Reg);
    FreeReg(RegR);
  end;
end;

procedure TEmitter.EmitOP_EQ_INT_MM;
var
  Reg1, Reg2, RegR: Integer;
begin
  EmitPCodeOperator;

  Reg1 := GetReg;
  Reg2 := GetReg;
  RegR := GetReg;
  EmitLoadAddress(RegR, SymbolRecR);
  EmitLoadIntVal(Reg1, SymbolRec1);
  EmitLoadIntVal(Reg2, SymbolRec2);
  Prg.AsmCmpREG_REG(Reg1, Reg2);
  Prg.AsmSetZ_REGPtr(RegR);
  FreeReg(RegR);
  FreeReg(Reg2);
  FreeReg(Reg1);
end;

procedure TEmitter.EmitOP_NE_INT_MI;
var
  Reg, RegR: Integer;
begin
  EmitPCodeOperator;

  if HasTheSameAddressRegister(SymbolRec1, SymbolRecR) then
  begin
    Reg := EmitGetAddressRegister(SymbolRec1);
    Prg.AsmCmpREGPtr_Imm(Reg, SymbolRec1, ImmValue2);
    Prg.AsmSet_REGPtr(ASM_SETNZ, Reg, SymbolRecR);
    FreeReg(Reg);
  end
  else
  begin
    RegR := GetReg;
    EmitLoadAddress(RegR, SymbolRecR);
    Reg := EmitGetAddressRegister(SymbolRec1);
    Prg.AsmCmpREGPtr_Imm(Reg, SymbolRec1, ImmValue2);
    Prg.AsmSetNZ_REGPtr(RegR);
    FreeReg(Reg);
    FreeReg(RegR);
  end;
end;

procedure TEmitter.EmitOP_NE_INT_MM;
var
  Reg1, Reg2, RegR: Integer;
begin
  EmitPCodeOperator;

  Reg1 := GetReg;
  Reg2 := GetReg;
  RegR := GetReg;
  EmitLoadAddress(RegR, SymbolRecR);
  EmitLoadIntVal(Reg1, SymbolRec1);
  EmitLoadIntVal(Reg2, SymbolRec2);
  Prg.AsmCmpREG_REG(Reg1, Reg2);
  Prg.AsmSetNZ_REGPtr(RegR);
  FreeReg(RegR);
  FreeReg(Reg2);
  FreeReg(Reg1);
end;

procedure TEmitter.EmitOP_LT_CURRENCY;
var
  Reg: Integer;
  S: TSymbolRec;
begin
  EmitPCodeOperator;

  S := SymbolRec2;
  if S.FinalTypeId <> typeCURRENCY then
  begin
    if S.FinalTypeId in IntegerTypes then
      EmitFild(S)
    else if S.FinalTypeId in RealTypes then
      EmitFld(S)
    else
      RaiseError(errInternalError, []);
    EmitFMul_10000;
  end
  else
    EmitFild(S);

  S := SymbolRec1;
  if S.FinalTypeId <> typeCURRENCY then
  begin
    if S.FinalTypeId in IntegerTypes then
      EmitFild(S)
    else if S.FinalTypeId in RealTypes then
      EmitFld(S)
    else
      RaiseError(errInternalError, []);
    EmitFMul_10000;
  end
  else
    EmitFild(S);

  GetReg(_EAX);
  Reg := GetReg;
  EmitLoadAddress(Reg, SymbolRecR);
  Prg.AsmFCompP;
  Prg.AsmFstsw_AX;
  Prg.AsmSahv;
  Prg.AsmSetB_REGPtr(Reg);
  FreeReg(Reg);
  FreeReg(_EAX);
end;

procedure TEmitter.EmitOP_LE_CURRENCY;
var
  Reg: Integer;
  S: TSymbolRec;
begin
  EmitPCodeOperator;

  S := SymbolRec2;
  if S.FinalTypeId <> typeCURRENCY then
  begin
    if S.FinalTypeId in IntegerTypes then
      EmitFild(S)
    else if S.FinalTypeId in RealTypes then
      EmitFld(S)
    else
      RaiseError(errInternalError, []);
    EmitFMul_10000;
  end
  else
    EmitFild(S);

  S := SymbolRec1;
  if S.FinalTypeId <> typeCURRENCY then
  begin
    if S.FinalTypeId in IntegerTypes then
      EmitFild(S)
    else if S.FinalTypeId in RealTypes then
      EmitFld(S)
    else
      RaiseError(errInternalError, []);
    EmitFMul_10000;
  end
  else
    EmitFild(S);

  GetReg(_EAX);
  Reg := GetReg;
  EmitLoadAddress(Reg, SymbolRecR);
  Prg.AsmFCompP;
  Prg.AsmFstsw_AX;
  Prg.AsmSahv;
  Prg.AsmSetBE_REGPtr(Reg);
  FreeReg(Reg);
  FreeReg(_EAX);
end;

procedure TEmitter.EmitOP_GT_CURRENCY;
var
  Reg: Integer;
  S: TSymbolRec;
begin
  EmitPCodeOperator;

  S := SymbolRec2;
  if S.FinalTypeId <> typeCURRENCY then
  begin
    if S.FinalTypeId in IntegerTypes then
      EmitFild(S)
    else if S.FinalTypeId in RealTypes then
      EmitFld(S)
    else
      RaiseError(errInternalError, []);
    EmitFMul_10000;
  end
  else
    EmitFild(S);

  S := SymbolRec1;
  if S.FinalTypeId <> typeCURRENCY then
  begin
    if S.FinalTypeId in IntegerTypes then
      EmitFild(S)
    else if S.FinalTypeId in RealTypes then
      EmitFld(S)
    else
      RaiseError(errInternalError, []);
    EmitFMul_10000;
  end
  else
    EmitFild(S);

  GetReg(_EAX);
  Reg := GetReg;
  EmitLoadAddress(Reg, SymbolRecR);
  Prg.AsmFCompP;
  Prg.AsmFstsw_AX;
  Prg.AsmSahv;
  Prg.AsmSetNBE_REGPtr(Reg);
  FreeReg(Reg);
  FreeReg(_EAX);
end;

procedure TEmitter.EmitOP_GE_CURRENCY;
var
  Reg: Integer;
  S: TSymbolRec;
begin
  EmitPCodeOperator;

  S := SymbolRec2;
  if S.FinalTypeId <> typeCURRENCY then
  begin
    if S.FinalTypeId in IntegerTypes then
      EmitFild(S)
    else if S.FinalTypeId in RealTypes then
      EmitFld(S)
    else
      RaiseError(errInternalError, []);
    EmitFMul_10000;
  end
  else
    EmitFild(S);

  S := SymbolRec1;
  if S.FinalTypeId <> typeCURRENCY then
  begin
    if S.FinalTypeId in IntegerTypes then
      EmitFild(S)
    else if S.FinalTypeId in RealTypes then
      EmitFld(S)
    else
      RaiseError(errInternalError, []);
    EmitFMul_10000;
  end
  else
    EmitFild(S);

  GetReg(_EAX);
  Reg := GetReg;
  EmitLoadAddress(Reg, SymbolRecR);
  Prg.AsmFCompP;
  Prg.AsmFstsw_AX;
  Prg.AsmSahv;
  Prg.AsmSetNB_REGPtr(Reg);
  FreeReg(Reg);
  FreeReg(_EAX);
end;

procedure TEmitter.EmitOP_EQ_CURRENCY;
var
  Reg: Integer;
  S: TSymbolRec;
begin
  EmitPCodeOperator;

  S := SymbolRec2;
  if S.FinalTypeId <> typeCURRENCY then
  begin
    if S.FinalTypeId in IntegerTypes then
      EmitFild(S)
    else if S.FinalTypeId in RealTypes then
      EmitFld(S)
    else
      RaiseError(errInternalError, []);
    EmitFMul_10000;
  end
  else
    EmitFild(S);

  S := SymbolRec1;
  if S.FinalTypeId <> typeCURRENCY then
  begin
    if S.FinalTypeId in IntegerTypes then
      EmitFild(S)
    else if S.FinalTypeId in RealTypes then
      EmitFld(S)
    else
      RaiseError(errInternalError, []);
    EmitFMul_10000;
  end
  else
    EmitFild(S);

  GetReg(_EAX);
  Reg := GetReg;
  EmitLoadAddress(Reg, SymbolRecR);
  Prg.AsmFCompP;
  Prg.AsmFstsw_AX;
  Prg.AsmSahv;
  Prg.AsmSetZ_REGPtr(Reg);
  FreeReg(Reg);
  FreeReg(_EAX);
end;

procedure TEmitter.EmitOP_NE_CURRENCY;
var
  Reg: Integer;
  S: TSymbolRec;
begin
  EmitPCodeOperator;

  S := SymbolRec2;
  if S.FinalTypeId <> typeCURRENCY then
  begin
    if S.FinalTypeId in IntegerTypes then
      EmitFild(S)
    else if S.FinalTypeId in RealTypes then
      EmitFld(S)
    else
      RaiseError(errInternalError, []);
    EmitFMul_10000;
  end
  else
    EmitFild(S);

  S := SymbolRec1;
  if S.FinalTypeId <> typeCURRENCY then
  begin
    if S.FinalTypeId in IntegerTypes then
      EmitFild(S)
    else if S.FinalTypeId in RealTypes then
      EmitFld(S)
    else
      RaiseError(errInternalError, []);
    EmitFMul_10000;
  end
  else
    EmitFild(S);

  GetReg(_EAX);
  Reg := GetReg;
  EmitLoadAddress(Reg, SymbolRecR);
  Prg.AsmFCompP;
  Prg.AsmFstsw_AX;
  Prg.AsmSahv;
  Prg.AsmSetNZ_REGPtr(Reg);
  FreeReg(Reg);
  FreeReg(_EAX);
end;

procedure TEmitter.EmitOP_LT_DOUBLE;
var
  Reg: Integer;
begin
  EmitPCodeOperator;

  EmitFld(SymbolRec2);
  EmitFld(SymbolRec1);

  GetReg(_EAX);
  Reg := GetReg;

  EmitLoadAddress(Reg, SymbolRecR);
  Prg.AsmFCompP;
  Prg.AsmFstsw_AX;
  Prg.AsmSahv;
  Prg.AsmSetB_REGPtr(Reg);

  FreeReg(Reg);
  FreeReg(_EAX);
end;

procedure TEmitter.EmitOP_LT_SINGLE;
var
  Reg: Integer;
begin
  EmitPCodeOperator;

  EmitFld(SymbolRec2);
  EmitFld(SymbolRec1);

  GetReg(_EAX);
  Reg := GetReg;

  EmitLoadAddress(Reg, SymbolRecR);
  Prg.AsmFCompP;
  Prg.AsmFstsw_AX;
  Prg.AsmSahv;
  Prg.AsmSetB_REGPtr(Reg);

  FreeReg(Reg);
  FreeReg(_EAX);
end;

procedure TEmitter.EmitOP_LT_EXTENDED;
var
  Reg: Integer;
begin
  EmitPCodeOperator;

  EmitFld(SymbolRec2);
  EmitFld(SymbolRec1);

  GetReg(_EAX);
  Reg := GetReg;

  EmitLoadAddress(Reg, SymbolRecR);
  Prg.AsmFCompP;
  Prg.AsmFstsw_AX;
  Prg.AsmSahv;
  Prg.AsmSetB_REGPtr(Reg);

  FreeReg(Reg);
  FreeReg(_EAX);
end;

procedure TEmitter.EmitOP_LE_DOUBLE;
var
  Reg: Integer;
begin
  EmitPCodeOperator;

  EmitFld(SymbolRec2);
  EmitFld(SymbolRec1);

  GetReg(_EAX);
  Reg := GetReg;

  EmitLoadAddress(Reg, SymbolRecR);
  Prg.AsmFCompP;
  Prg.AsmFstsw_AX;
  Prg.AsmSahv;
  Prg.AsmSetBE_REGPtr(Reg);

  FreeReg(Reg);
  FreeReg(_EAX);
end;

procedure TEmitter.EmitOP_LE_SINGLE;
var
  Reg: Integer;
begin
  EmitPCodeOperator;

  EmitFld(SymbolRec2);
  EmitFld(SymbolRec1);

  GetReg(_EAX);
  Reg := GetReg;

  EmitLoadAddress(Reg, SymbolRecR);
  Prg.AsmFCompP;
  Prg.AsmFstsw_AX;
  Prg.AsmSahv;
  Prg.AsmSetBE_REGPtr(Reg);

  FreeReg(Reg);
  FreeReg(_EAX);
end;

procedure TEmitter.EmitOP_LE_EXTENDED;
var
  Reg: Integer;
begin
  EmitPCodeOperator;

  EmitFld(SymbolRec2);
  EmitFld(SymbolRec1);

  GetReg(_EAX);
  Reg := GetReg;

  EmitLoadAddress(Reg, SymbolRecR);
  Prg.AsmFCompP;
  Prg.AsmFstsw_AX;
  Prg.AsmSahv;
  Prg.AsmSetBE_REGPtr(Reg);

  FreeReg(Reg);
  FreeReg(_EAX);
end;

procedure TEmitter.EmitOP_GT_DOUBLE;
var
  Reg: Integer;
begin
  EmitPCodeOperator;

  EmitFld(SymbolRec2);
  EmitFld(SymbolRec1);

  GetReg(_EAX);
  Reg := GetReg;

  EmitLoadAddress(Reg, SymbolRecR);
  Prg.AsmFCompP;
  Prg.AsmFstsw_AX;
  Prg.AsmSahv;
  Prg.AsmSetNBE_REGPtr(Reg);

  FreeReg(Reg);
  FreeReg(_EAX);
end;

procedure TEmitter.EmitOP_GT_SINGLE;
var
  Reg: Integer;
begin
  EmitPCodeOperator;

  EmitFld(SymbolRec2);
  EmitFld(SymbolRec1);

  GetReg(_EAX);
  Reg := GetReg;

  EmitLoadAddress(Reg, SymbolRecR);
  Prg.AsmFCompP;
  Prg.AsmFstsw_AX;
  Prg.AsmSahv;
  Prg.AsmSetNBE_REGPtr(Reg);

  FreeReg(Reg);
  FreeReg(_EAX);
end;

procedure TEmitter.EmitOP_GT_EXTENDED;
var
  Reg: Integer;
begin
  EmitPCodeOperator;

  EmitFld(SymbolRec2);
  EmitFld(SymbolRec1);

  GetReg(_EAX);
  Reg := GetReg;

  EmitLoadAddress(Reg, SymbolRecR);
  Prg.AsmFCompP;
  Prg.AsmFstsw_AX;
  Prg.AsmSahv;
  Prg.AsmSetNBE_REGPtr(Reg);

  FreeReg(Reg);
  FreeReg(_EAX);
end;

procedure TEmitter.EmitOP_GE_DOUBLE;
var
  Reg: Integer;
begin
  EmitPCodeOperator;

  EmitFld(SymbolRec2);
  EmitFld(SymbolRec1);

  GetReg(_EAX);
  Reg := GetReg;

  EmitLoadAddress(Reg, SymbolRecR);
  Prg.AsmFCompP;
  Prg.AsmFstsw_AX;
  Prg.AsmSahv;
  Prg.AsmSetNB_REGPtr(Reg);

  FreeReg(Reg);
  FreeReg(_EAX);
end;

procedure TEmitter.EmitOP_GE_SINGLE;
var
  Reg: Integer;
begin
  EmitPCodeOperator;

  EmitFld(SymbolRec2);
  EmitFld(SymbolRec1);

  GetReg(_EAX);
  Reg := GetReg;

  EmitLoadAddress(Reg, SymbolRecR);
  Prg.AsmFCompP;
  Prg.AsmFstsw_AX;
  Prg.AsmSahv;
  Prg.AsmSetNB_REGPtr(Reg);

  FreeReg(Reg);
  FreeReg(_EAX);
end;

procedure TEmitter.EmitOP_GE_EXTENDED;
var
  Reg: Integer;
begin
  EmitPCodeOperator;

  EmitFld(SymbolRec2);
  EmitFld(SymbolRec1);

  GetReg(_EAX);
  Reg := GetReg;

  EmitLoadAddress(Reg, SymbolRecR);
  Prg.AsmFCompP;
  Prg.AsmFstsw_AX;
  Prg.AsmSahv;
  Prg.AsmSetNB_REGPtr(Reg);

  FreeReg(Reg);
  FreeReg(_EAX);
end;

procedure TEmitter.EmitOP_EQ_DOUBLE;
var
  Reg: Integer;
begin
  EmitPCodeOperator;

  EmitFld(SymbolRec2);
  EmitFld(SymbolRec1);

  GetReg(_EAX);
  Reg := GetReg;

  EmitLoadAddress(Reg, SymbolRecR);
  Prg.AsmFCompP;
  Prg.AsmFstsw_AX;
  Prg.AsmSahv;
  Prg.AsmSetZ_REGPtr(Reg);

  FreeReg(Reg);
  FreeReg(_EAX);
end;

procedure TEmitter.EmitOP_EQ_SINGLE;
var
  Reg: Integer;
begin
  EmitPCodeOperator;

  EmitFld(SymbolRec2);
  EmitFld(SymbolRec1);

  GetReg(_EAX);
  Reg := GetReg;

  EmitLoadAddress(Reg, SymbolRecR);
  Prg.AsmFCompP;
  Prg.AsmFstsw_AX;
  Prg.AsmSahv;
  Prg.AsmSetZ_REGPtr(Reg);

  FreeReg(Reg);
  FreeReg(_EAX);
end;

procedure TEmitter.EmitOP_EQ_EXTENDED;
var
  Reg: Integer;
begin
  EmitPCodeOperator;

  EmitFld(SymbolRec2);
  EmitFld(SymbolRec1);

  GetReg(_EAX);
  Reg := GetReg;

  EmitLoadAddress(Reg, SymbolRecR);
  Prg.AsmFCompP;
  Prg.AsmFstsw_AX;
  Prg.AsmSahv;
  Prg.AsmSetZ_REGPtr(Reg);

  FreeReg(Reg);
  FreeReg(_EAX);
end;

procedure TEmitter.EmitOP_NE_DOUBLE;
var
  Reg: Integer;
begin
  EmitPCodeOperator;

  EmitFld(SymbolRec2);
  EmitFld(SymbolRec1);

  GetReg(_EAX);
  Reg := GetReg;

  EmitLoadAddress(Reg, SymbolRecR);
  Prg.AsmFCompP;
  Prg.AsmFstsw_AX;
  Prg.AsmSahv;
  Prg.AsmSetNZ_REGPtr(Reg);

  FreeReg(Reg);
  FreeReg(_EAX);
end;

procedure TEmitter.EmitOP_NE_SINGLE;
var
  Reg: Integer;
begin
  EmitPCodeOperator;

  EmitFld(SymbolRec2);
  EmitFld(SymbolRec1);

  GetReg(_EAX);
  Reg := GetReg;

  EmitLoadAddress(Reg, SymbolRecR);
  Prg.AsmFCompP;
  Prg.AsmFstsw_AX;
  Prg.AsmSahv;
  Prg.AsmSetNZ_REGPtr(Reg);

  FreeReg(Reg);
  FreeReg(_EAX);
end;

procedure TEmitter.EmitOP_NE_EXTENDED;
var
  Reg: Integer;
begin
  EmitPCodeOperator;

  EmitFld(SymbolRec2);
  EmitFld(SymbolRec1);

  GetReg(_EAX);
  Reg := GetReg;

  EmitLoadAddress(Reg, SymbolRecR);
  Prg.AsmFCompP;
  Prg.AsmFstsw_AX;
  Prg.AsmSahv;
  Prg.AsmSetNZ_REGPtr(Reg);

  FreeReg(Reg);
  FreeReg(_EAX);
end;

procedure TEmitter.EmitOP_PUSH_STRUCTURE;
var
  Reg, RegTemp: Integer;
  SubId, ParamId, ParamNumber, SZ: Integer;
  ByRefer: Boolean;
  S: TSymbolRec;
begin
  EmitPCodeOperator;

  SubId := R.Res;
  ParamNumber := R.Arg2;
  ParamId := SymbolTable.GetParamId(SubId, ParamNumber);

  S := GetSymbolRec(ParamId);
  SZ := S.Size;

  if (GetSymbolRec(SubId).CallConv = ccREGISTER) and (SZ > 4) then
    ByRefer := true
  else
    ByRefer := S.ByRef or (S.IsConst and (SZ > 4));

  if (not ByRefer) and (SZ > 4) then
  begin
    while SZ mod 4 <> 0 do
      Inc(SZ);

    Reg := GetReg;
    EmitLoadAddress(Reg, SymbolRec1);

    Dec(SZ, 4);
    if SZ > 0 then
      Prg.AsmAddREG_Imm(Reg, SZ);

    RegTemp := GetReg;

    repeat
      if SZ = 0 then
        Prg.AsmXorREG_REG(RegTemp, RegTemp);

      Prg.AsmMovREG32_REGPtr(RegTemp, Reg);
      Prg.AsmPush_REG(RegTemp);

      Dec(SZ, 4);
      if SZ < 0 then
        break;

      Prg.AsmSubREG_Imm(Reg, 4);
    until false;

    FreeReg(RegTemp);
    FreeReg(Reg);

    Exit;
  end;

  // push address or 4-byte value

  if GetSymbolRec(SubId).CallConv in [ccREGISTER, ccMSFASTCALL] then
  begin
    Reg := GetSymbolRec(ParamId).Register;
    UpdateReg(Reg);

    if Reg > 0 then
    begin
      GetReg(Reg);
      EmitLoadAddress(Reg, SymbolRec1);

      if not ByRefer then
        Prg.AsmMovREG32_REGPtr(Reg, Reg);

      FreeReg(Reg);
      Exit;
    end;
  end;

  Reg := GetReg;
  EmitLoadAddress(Reg, SymbolRec1);

  if not ByRefer then
    Prg.AsmMovREG32_REGPtr(Reg, Reg);

  Prg.AsmPush_REG(Reg);
  FreeReg(Reg);
end;

procedure TEmitter.EmitOP_PUSH_ADDRESS;
var
  Reg: Integer;
  SubId, ParamId, ParamNumber: Integer;
begin
  EmitPCodeOperator;

  SubId := R.Res;
  ParamNumber := R.Arg2;
  if GetSymbolRec(SubId).CallConv in [ccREGISTER, ccMSFASTCALL] then
  begin
    ParamId := SymbolTable.GetParamId(SubId, ParamNumber);
    Reg := GetSymbolRec(ParamId).Register;
    UpdateReg(Reg);

    if Reg > 0 then
    begin
      GetReg(Reg);

      if SymbolRec1.Kind = KindSUB then
      begin
        if Host1 then
          EmitGet_REG(Reg, SymbolRec1)
        else
        begin
          Prg.AsmMovREG_REG(Reg, _EDI);
          Prg.AsmAddREG_Imm(Reg, 0);
          Prg.Top.SaveSubId := R.Arg1;
          List2.Add(Prg.Top);
        end;
      end
      else
        EmitLoadAddress(Reg, SymbolRec1);
      FreeReg(Reg);
      Exit;
    end;
  end;

  Reg := GetReg;

  if SymbolRec1.Kind = KindSUB then
  begin
    if Host1 then
      EmitGet_REG(Reg, SymbolRec1)
    else
    begin
      Prg.AsmMovREG_REG(Reg, _EDI);
      Prg.AsmAddREG_Imm(Reg, 0);
      Prg.Top.SaveSubId := R.Arg1;
      List2.Add(Prg.Top);
    end;
  end
  else
    EmitLoadAddress(Reg, SymbolRec1);

  Prg.AsmPush_REG(Reg);
  FreeReg(Reg);
end;

procedure TEmitter.UpdateReg(var Reg: Integer);
begin
  if Reg > 0 then
     if GetSymbolRec(R.SavedSubId).Kind = kindVAR then
       if (GetSymbolRec(R.SavedSubId).FinalTypeId = typeEVENT) then
    begin
      if Reg = _EAX then
        Reg := _EDX
      else if Reg = _EDX then
        Reg := _ECX
      else
        Reg := 0;
    end;
end;

procedure TEmitter.EmitOP_PUSH_INT_IMM;
var
  Reg: Integer;
  SubId, ParamId, ParamNumber: Integer;
begin
  EmitPCodeOperator;

  if R.Res = 0 then
  begin
    Prg.AsmPush_IMM(ImmValue1);
    Exit;
  end;

  SubId := R.Res;
  ParamNumber := R.Arg2;

  if GetSymbolRec(SubId).CallConv in [ccREGISTER, ccMSFASTCALL] then
  begin
    ParamId := SymbolTable.GetParamId(SubId, ParamNumber);

    Reg := GetSymbolRec(ParamId).Register;
    UpdateReg(Reg);

    if Reg > 0 then
    begin
      GetReg(Reg);
      Prg.AsmMovREG_IMM(Reg, ImmValue1);
      FreeReg(Reg);
      Exit;
    end;
  end;

  Prg.AsmPush_IMM(ImmValue1);
end;

procedure TEmitter.EmitOP_PUSH_DATA;
begin
  EmitPCodeOperator;

  GetReg(_EBX);

  Emit_PUSH_REGS;
  EmitLoadAddress(_EBX, SymbolRec1);
  Prg.AsmAddREG_Imm(_EBX, 4);
  Prg.AsmMovREG32_REGPtr(_EBX, _EBX); // save data to ebx
  Emit_POP_REGS;

  if SymbolRecR.CallConv in [ccREGISTER, ccMSFASTCALL] then
    Prg.AsmMovREG_REG(_EAX, _EBX)
  else
    Prg.AsmPush_REG(_EBX);

  FreeReg(_EBX);
end;

procedure TEmitter.EmitOP_PUSH_INT;
var
  Reg: Integer;
  SubId, ParamId, ParamNumber: Integer;
begin
  EmitPCodeOperator;

  if R.Res = 0 then
  begin
    Reg := GetReg;
    EmitLoadIntVal(Reg, SymbolRec1);
    Prg.AsmPush_REG(Reg);
    FreeReg(Reg);
    Exit;
  end;

  SubId := R.Res;
  ParamNumber := R.Arg2;
  ParamId := SymbolTable.GetParamId(SubId, ParamNumber);

  Reg := GetSymbolRec(ParamId).Register;
  UpdateReg(Reg);

  if Reg > 0 then
  begin
    GetReg(Reg);
    EmitLoadIntVal(Reg, SymbolRec1);
    FreeReg(Reg);
    Exit;
  end;

  Reg := GetReg;
  EmitLoadIntVal(Reg, SymbolRec1);
  Prg.AsmPush_REG(Reg);
  FreeReg(Reg);
end;

procedure TEmitter.EmitOP_PUSH_SET;
var
  Reg: Integer;
  SubId, ParamId, ParamNumber, K: Integer;
begin
  EmitPCodeOperator;

  K := SymbolRec1.Kind;
  try
    SymbolRec1.Kind := KindVAR;

    if R.Res = 0 then
    begin
      Reg := GetReg;
      EmitLoadIntVal(Reg, SymbolRec1);
      Prg.AsmPush_REG(Reg);
      FreeReg(Reg);
      Exit;
    end;

    SubId := R.Res;
    ParamNumber := R.Arg2;
    ParamId := SymbolTable.GetParamId(SubId, ParamNumber);

    Reg := GetSymbolRec(ParamId).Register;
    UpdateReg(Reg);

    if Reg > 0 then
    begin
      GetReg(Reg);
      EmitLoadIntVal(Reg, SymbolRec1);
      FreeReg(Reg);
      Exit;
    end;

    Reg := GetReg;
    EmitLoadIntVal(Reg, SymbolRec1);
    Prg.AsmPush_REG(Reg);
    FreeReg(Reg);

  finally
    SymbolRec1.Kind := K;
  end;
end;

procedure TEmitter.EmitOP_PUSH_DYNARRAY;
var
  Reg, RegEx: Integer;
  SubId, ParamId, ParamNumber: Integer;
  S: String;
begin
  EmitPCodeOperator;

  if R.Res = 0 then
  begin
    Reg := GetReg;
    EmitLoadIntVal(Reg, SymbolRec1);
    Prg.AsmPush_REG(Reg);
    FreeReg(Reg);
    Exit;
  end;

  SubId := R.Res;
  ParamNumber := R.Arg2;
  ParamId := SymbolTable.GetParamId(SubId, ParamNumber);

  S := SymbolTable[SubId].Name;

  Reg := GetSymbolRec(ParamId).Register;
  UpdateReg(Reg);

  if Reg > 0 then
  begin
    GetReg(Reg);
    EmitLoadIntVal(Reg, SymbolRec1);
    FreeReg(Reg);

    if SymbolTable[ParamId].IsOpenArray then
    begin
      if Reg = _EAX then
        RegEx := _EDX
      else if Reg = _EDX then
        RegEx := _ECX
      else
        RegEx := _EBX;

      GetReg(RegEx);

      if SymbolRec1.FinalTypeId = typeDYNARRAY then
      begin
        // load high(A) into RegEx

        Prg.AsmMovREG_REG(RegEx, Reg);
        Prg.AsmAddREG_Imm(RegEx, -4);
        Prg.AsmMovREG32_REGPtr(RegEx, RegEx);
        Prg.AsmAddREG_Imm(RegEx, -1);
      end
      else
      begin
        Prg.AsmMovREG_Imm(RegEx, 0);
      end;

      if RegEx = _EBX then
        Prg.AsmPush_REG(RegEx);
      FreeReg(RegEx);
    end;

    Exit;
  end;

  if GetSymbolRec(SubId).CallConv in [ccREGISTER, ccMSFASTCALL] then
  begin
    Reg := GetReg;

    EmitLoadIntVal(Reg, SymbolRec1);
    Prg.AsmPush_REG(Reg);

    if SymbolTable[ParamId].IsOpenArray then
    begin
      if SymbolRec1.FinalTypeId = typeDYNARRAY then
      begin
        // load high(A) into RegEx
        EmitLoadIntVal(Reg, SymbolRec1);

        Prg.AsmAddREG_Imm(Reg, -4);
        Prg.AsmMovREG32_REGPtr(Reg, Reg);
        Prg.AsmAddREG_Imm(Reg, -1);
        Prg.AsmPush_REG(Reg);
      end
      else
        Prg.AsmPush_Imm(0);
    end;

    FreeReg(Reg);
    Exit;
  end;

  Reg := GetReg;
  if SymbolTable[ParamId].IsOpenArray then
  begin
    if SymbolRec1.FinalTypeId = typeDYNARRAY then
    begin
      // load high(A) into RegEx

      EmitLoadIntVal(Reg, SymbolRec1);

      Prg.AsmAddREG_Imm(Reg, -4);
      Prg.AsmMovREG32_REGPtr(Reg, Reg);
      Prg.AsmAddREG_Imm(Reg, -1);
      Prg.AsmPush_REG(Reg);
    end
    else
      Prg.AsmPush_Imm(0);
  end;

  EmitLoadIntVal(Reg, SymbolRec1);
  Prg.AsmPush_REG(Reg);
  FreeReg(Reg);
end;

procedure TEmitter.EmitOP_CLEAR_EDX;
begin
  EmitPCodeOperator;
  Prg.AsmMovREG_Imm(_EDX, 0);
end;

procedure TEmitter.EmitOP_UPDATE_INSTANCE;
var
  Reg: Integer;
  SubId: Integer;
begin
  EmitPCodeOperator;

  SubId := Id_UpdateInstance;

  Reg := _EBX;
  GetReg(Reg);

  Emit_PUSH_REGS;

  EmitLoadIntVal(Reg, SymbolRec1); // instance
  Prg.AsmPush_REG(Reg);

  Prg.AsmMovREG_REG(Reg, _ESI);
  Prg.AsmAddREG_Imm(Reg, H_SelfPtr);
  Prg.AsmMovREG32_REGPtr(Reg, Reg); // load TProgram.Self
  Prg.AsmPush_REG(Reg);

  EmitGet_REG(Reg, SymbolTable[SubId]);
  Prg.AsmCall_REG(Reg);

  Emit_POP_REGS;

  FreeReg(Reg);
end;

procedure TEmitter.EmitOP_PUSH_INST;
var
  Reg: Integer;
  SubId: Integer;
  L: Integer;
begin
  EmitPCodeOperator;

  L := GetSymbolRec(R.Res).Level;

  if SymbolTable[R.Res].CallConv in [ccREGISTER, ccMSFASTCALL] then
  begin
    if (SymbolTable[R.Res].Kind = kindCONSTRUCTOR) and SymbolTable[R.Res].Host
        and (not SymbolTable[R.Res].IsExternal) then
    begin
      SubId := Id_ToParentClass;

      Reg := _EBX;
      GetReg(Reg);

      Emit_PUSH_REGS;

      EmitLoadIntVal(Reg, SymbolRec1); // instance
      Prg.AsmPush_REG(Reg);

      Prg.AsmMovREG_REG(Reg, _ESI);
      Prg.AsmAddREG_Imm(Reg, H_SelfPtr);
      Prg.AsmMovREG32_REGPtr(Reg, Reg); // load TProgram.Self
      Prg.AsmPush_REG(Reg);

      EmitGet_REG(Reg, SymbolTable[SubId]);
      Prg.AsmCall_REG(Reg);

      Emit_POP_REGS;

      FreeReg(Reg);
    end;

    GetReg(_EAX);

    if GetSymbolRec(L).FinalTypeId = typeRECORD then
      EmitLoadAddress(_EAX, SymbolRec1)
    else
      EmitLoadIntVal(_EAX, SymbolRec1);

    if SymbolRecR.IsSharedMethod then
      if not StrEql(SymbolRecR.Name, 'ClassType') then
      Prg.AsmMovREG32_REGPtr(_EAX, _EAX);

    FreeReg(_EAX);

    if SymbolTable[R.Res].Kind in [kindCONSTRUCTOR, kindDESTRUCTOR] then
      Prg.AsmMovREG_Imm(_EDX, 0);
  end
  else
  begin
    GetReg(_EAX);
    Reg := _EAX;

    if GetSymbolRec(L).FinalTypeId = typeRECORD then
      EmitLoadAddress(Reg, SymbolRec1)
    else
      EmitLoadIntVal(Reg, SymbolRec1);

    if SymbolRecR.IsSharedMethod then
      if not StrEql(SymbolRecR.Name, 'ClassType') then
      Prg.AsmMovREG32_REGPtr(_EAX, _EAX);

    Prg.AsmPush_REG(Reg);
    FreeReg(Reg);
  end;
end;

procedure TEmitter.EmitOP_PUSH_CLSREF;
begin
  EmitPCodeOperator;

  if SymbolRecR.Kind = kindCONSTRUCTOR then
  begin
    GetReg(_EAX);
    GetReg(_EDX);
    EmitLoadIntVal(_EAX, SymbolRec1);
    Prg.AsmMovREG_Imm(_EDX, 1);
    FreeReg(_EDX);
    FreeReg(_EAX);

    if SymbolRecR.IsExternal then
    begin
      Emit_PUSH_REGS;

      Prg.AsmPush_REG(_EAX);

      Prg.AsmMovREG_REG(_EBX, _ESI);
      Prg.AsmAddREG_Imm(_EBX, H_SelfPtr);
      Prg.AsmMovREG32_REGPtr(_EBX, _EBX); // load TProgram.Self
      Prg.AsmPush_REG(_EBX);

      Prg.AsmGetREG32_ESIPtr(_EBX, GetOffset(SymbolTable[Id_LoadClassRef]));
      Prg.AsmCall_REG(_EBX);

      Emit_POP_REGS;
    end;
  end
  else
  begin
    GetReg(_EAX);
    EmitLoadIntVal(_EAX, SymbolRec1);
    if SymbolTable[R.Res].CallConv <> ccREGISTER then
       Prg.AsmPush_REG(_EAX);
    FreeReg(_EAX);
  end;
end;

procedure TEmitter.EmitOP_PUSH_INT64;
var
  Reg: Integer;
begin
  EmitPCodeOperator;

  Reg := GetReg;
  if Host1 or ByRef1 then
  begin
    EmitLoadAddress(Reg, SymbolRec1);

    Prg.AsmAddREG_Imm(Reg, 4);
    Prg.AsmPush_REGPtr(Reg);
    Prg.AsmAddREG_Imm(Reg, -4);
    Prg.AsmPush_REGPtr(Reg);
  end
  else
  begin
    EmitGet_REG(Reg, SymbolRec1, + 4);
    Prg.AsmPush_REG(Reg);
    EmitGet_REG(Reg, SymbolRec1);
    Prg.AsmPush_REG(Reg);
  end;
  FreeReg(Reg);
end;

procedure TEmitter.EmitOP_PUSH_EVENT;
var
  Reg: Integer;
begin
  EmitPCodeOperator;

  HandlesEvents := true;

  Reg := GetReg;
  if Host1 or ByRef1 then
  begin
    EmitLoadAddress(Reg, SymbolRec1);

    Prg.AsmAddREG_Imm(Reg, 4);
    Prg.AsmPush_REGPtr(Reg);
    Prg.AsmAddREG_Imm(Reg, -4);
    Prg.AsmPush_REGPtr(Reg);
  end
  else
  begin
    EmitGet_REG(Reg, SymbolRec1, + 4);
    Prg.AsmPush_REG(Reg);
    EmitGet_REG(Reg, SymbolRec1);
    Prg.AsmPush_REG(Reg);
  end;
  FreeReg(Reg);
end;

procedure TEmitter.EmitOP_PUSH_DOUBLE;
var
  Reg: Integer;
begin
  EmitPCodeOperator;

  Reg := GetReg;
  if Host1 or ByRef1 then
  begin
    EmitLoadAddress(Reg, SymbolRec1);

    Prg.AsmAddREG_Imm(Reg, 4);
    Prg.AsmPush_REGPtr(Reg);
    Prg.AsmAddREG_Imm(Reg, -4);
    Prg.AsmPush_REGPtr(Reg);
  end
  else
  begin
    EmitGet_REG(Reg, SymbolRec1, + 4);
    Prg.AsmPush_REG(Reg);
    EmitGet_REG(Reg, SymbolRec1);
    Prg.AsmPush_REG(Reg);
  end;
  FreeReg(Reg);
end;

procedure TEmitter.EmitOP_PUSH_CURRENCY;
var
  Reg: Integer;
begin
  EmitPCodeOperator;

  Reg := GetReg;
  if Host1 or ByRef1 then
  begin
    EmitLoadAddress(Reg, SymbolRec1);

    Prg.AsmAddREG_Imm(Reg, 4);
    Prg.AsmPush_REGPtr(Reg);
    Prg.AsmAddREG_Imm(Reg, -4);
    Prg.AsmPush_REGPtr(Reg);
  end
  else
  begin
    EmitGet_REG(Reg, SymbolRec1, + 4);
    Prg.AsmPush_REG(Reg);
    EmitGet_REG(Reg, SymbolRec1);
    Prg.AsmPush_REG(Reg);
  end;
  FreeReg(Reg);
end;

procedure TEmitter.EmitOP_PUSH_EXTENDED;
var
  RegAddr, RegE: Integer;
begin
  EmitPCodeOperator;

  RegAddr := GetReg;
  RegE    := GetReg;

  EmitLoadAddress(RegAddr, SymbolRec1);

  Prg.AsmAddREG_Imm(RegAddr, 8);
  Prg.AsmMovREG16_REGPtr(RegE, RegAddr);
  Prg.AsmPush_REG(RegE);

  Prg.AsmAddREG_Imm(RegAddr, -4);
  Prg.AsmPush_REGPtr(RegAddr);
  Prg.AsmAddREG_Imm(RegAddr, -4);
  Prg.AsmPush_REGPtr(RegAddr);

  FreeReg(RegE);
  FreeReg(RegAddr);
end;

procedure TEmitter.EmitOP_PUSH_SINGLE;
var
  Reg: Integer;
  I: Integer;
  S: Single;
begin
  EmitPCodeOperator;


  if SymbolRec1.Kind = KindCONST then
  begin
    S := SymbolRec1.Value;
    Move(S, I, SizeOf(Single));
    Prg.AsmPush_IMM(I);
  end
  else
  begin
    Reg := GetReg;
    EmitLoadIntVal(Reg, SymbolRec1);
    Prg.AsmPush_REG(Reg);
    FreeReg(Reg);
  end;
end;

procedure TEmitter.EmitOP_PUSH_ANSISTRING;
var
  Reg: Integer;
  SubId, ParamId, ParamNumber: Integer;
begin
  EmitPCodeOperator;

  SubId := R.Res;
  ParamNumber := R.Arg2;
  ParamId := SymbolTable.GetParamId(SubId, ParamNumber);

  Reg := GetSymbolRec(ParamId).Register;
  UpdateReg(Reg);

  if Reg > 0 then
  begin
    GetReg(Reg);
    EmitLoadIntVal(Reg, SymbolRec1);
    FreeReg(Reg);
    Exit;
  end;

  Reg := GetReg;
  EmitLoadIntVal(Reg, SymbolRec1);
  Prg.AsmPush_REG(Reg);
  FreeReg(Reg);
end;

procedure TEmitter.EmitOP_PUSH_WIDESTRING;
var
  Reg: Integer;
  SubId, ParamId, ParamNumber: Integer;
begin
  EmitPCodeOperator;

  SubId := R.Res;
  ParamNumber := R.Arg2;
  ParamId := SymbolTable.GetParamId(SubId, ParamNumber);

  Reg := GetSymbolRec(ParamId).Register;
  UpdateReg(Reg);

  if Reg > 0 then
  begin
    GetReg(Reg);
    EmitLoadIntVal(Reg, SymbolRec1);
    FreeReg(Reg);
    Exit;
  end;

  Reg := GetReg;
  EmitLoadIntVal(Reg, SymbolRec1);
  Prg.AsmPush_REG(Reg);
  FreeReg(Reg);
end;

procedure TEmitter.EmitOP_PUSH_UNICSTRING;
var
  Reg: Integer;
  SubId, ParamId, ParamNumber: Integer;
begin
  EmitPCodeOperator;

  SubId := R.Res;
  ParamNumber := R.Arg2;
  ParamId := SymbolTable.GetParamId(SubId, ParamNumber);

  Reg := GetSymbolRec(ParamId).Register;
  UpdateReg(Reg);

  if Reg > 0 then
  begin
    GetReg(Reg);
    EmitLoadIntVal(Reg, SymbolRec1);
    FreeReg(Reg);
    Exit;
  end;

  Reg := GetReg;
  EmitLoadIntVal(Reg, SymbolRec1);
  Prg.AsmPush_REG(Reg);
  FreeReg(Reg);
end;

procedure TEmitter.EmitOP_PUSH_SHORTSTRING;
var
  Reg: Integer;
  SubId, ParamId, ParamNumber: Integer;
begin
  EmitPCodeOperator;

  // push address

  SubId := R.Res;
  ParamNumber := R.Arg2;
  ParamId := SymbolTable.GetParamId(SubId, ParamNumber);
  Reg := GetSymbolRec(ParamId).Register;
  UpdateReg(Reg);

  if Reg > 0 then
  begin
    GetReg(Reg);
    EmitLoadAddress(Reg, SymbolRec1);
    FreeReg(Reg);
    Exit;
  end;

  Reg := GetReg;
  EmitLoadAddress(Reg, SymbolRec1);
  Prg.AsmPush_REG(Reg);
  FreeReg(Reg);
end;

procedure TEmitter.EmitOP_PUSH_PANSICHAR_IMM;
var
  Reg: Integer;
  SubId, ParamId, ParamNumber, Id: Integer;
begin
  EmitPCodeOperator;

  // to provide unique constant address
  Id := SymbolTable.FindPAnsiCharConst(SymbolRec1.Value, R.Arg1 - 1);
  if Id > 0 then
  if SymbolTable.InCode[Id] then
    R.Arg1 := Id;

  SubId := R.Res;
  ParamNumber := R.Arg2;
  ParamId := SymbolTable.GetParamId(SubId, ParamNumber);

  Reg := GetSymbolRec(ParamId).Register;
  UpdateReg(Reg);

  if Reg > 0 then
  begin
    GetReg(Reg);
    EmitGet_REG(Reg, SymbolRec1); // pchar source
    FreeReg(Reg);
    Exit;
  end;

  Reg := GetReg;
  EmitGet_REG(Reg, SymbolRec1); // pchar source
  Prg.AsmPush_REG(Reg);
  FreeReg(Reg);
end;

procedure TEmitter.EmitOP_PUSH_PWIDECHAR_IMM;
var
  Reg: Integer;
  SubId, ParamId, ParamNumber, Id: Integer;
begin
  EmitPCodeOperator;

  // to provide unique constant address
  Id := SymbolTable.FindPWideCharConst(SymbolRec1.Value, R.Arg1 - 1);
  if Id > 0 then
  if SymbolTable.InCode[Id] then
    R.Arg1 := Id;

  SubId := R.Res;
  ParamNumber := R.Arg2;
  ParamId := SymbolTable.GetParamId(SubId, ParamNumber);

  Reg := GetSymbolRec(ParamId).Register;
  UpdateReg(Reg);

  if Reg > 0 then
  begin
    GetReg(Reg);
    EmitGet_REG(Reg, SymbolRec1); // pchar source
    FreeReg(Reg);
    Exit;
  end;

  Reg := GetReg;
  EmitGet_REG(Reg, SymbolRec1); // pchar source
  Prg.AsmPush_REG(Reg);
  FreeReg(Reg);
end;

procedure TEmitter.EmitOP_BEGIN_CALL;
var
  Reg: Integer;
begin
  EmitPCodeOperator;

  if not SymbolRec1.IsNestedSub then
  begin
    Prg.AsmPush_REG(_ESI);
    Prg.AsmPush_REG(_EDI);
  end;

  if R.Res = 0 then
    exit;

  if SymbolRec1.CallConv = ccSAFECALL then
  begin
    Reg := GetReg;
    EmitLoadAddress(Reg, SymbolRecR);
    Prg.AsmPush_REG(Reg);
    FreeReg(Reg);
  end;
end;

procedure TEmitter.EmitOP_CALL;

procedure EmitInterfaceAddress(MethodIndex: Integer);
var
  Code: TCode;
  I: Integer;
begin
  Code := TKernel(kernel).Code;
  I := Code.N - 1;
  while Code[I].Op <> OP_PUSH_INST do
    Dec(I);

  if I = Code.N - 1 then
  begin
    prg.AsmMovREG32_REGPtr(_EBX, _EAX);
    prg.AsmAddREG_Imm(_EBX, (MethodIndex - 1) * 4);
    prg.AsmMovREG32_REGPtr(_EBX, _EBX);
  end
  else
  begin
    Emit_PUSH_REGS;
    EmitLoadIntVal(_EAX, GetSymbolRec(Code[I].Arg1));
    prg.AsmMovREG32_REGPtr(_EBX, _EAX);
    prg.AsmAddREG_Imm(_EBX, (MethodIndex - 1) * 4);
    prg.AsmMovREG32_REGPtr(_EBX, _EBX);
    Emit_POP_REGS;
  end;
end;

function FindBeginCall: TCodeRec;
var
  RR: TCodeRec;
  I, K, SubId: Integer;
  Code: TCode;
begin
  result := nil;
  Code := TKernel(kernel).Code;
  I := Code.N - 1;
  RR := Code[Code.N];
  SubId := RR.Arg1;
  K := 0;
  repeat
    if (Code[I].Op = OP_CALL) and (Code[I].Arg1 = SubId) then
      Dec(K)
    else if (Code[I].Op = OP_BEGIN_CALL) and (Code[I].Arg1 = SubId) then
    begin
      if K = 0 then
      begin
        result := Code[I];
        Exit;
      end;

      Inc(K);
    end;

    Dec(I);
  until I = 0;
end;

var
  Reg, ParamId, I, K, T: Integer;
  SR: TSymbolRec;

 {$IFDEF FPC}
  SubId: Integer;
 {$ENDIF}

  Code: TCode;
  TrueSubId: Integer;

  RR: TCodeRec;
begin
  EmitPCodeOperator;
  Code := TKernel(kernel).Code;

  if SymbolRec1.Kind = KindVAR then
  begin
    T := SymbolRec1.TerminalTypeId;
    TrueSubId := GetSymbolRec(T).PatternId;

    if not (GetSymbolRec(TrueSubId).Kind in kindSUBS) then
    begin
      K := Code.N - 1;
      repeat
        if Code[K] .Op = OP_GET_VMT_ADDRESS then
          if Code[K] .Res = SymbolRec1.Id then
          begin
            TrueSubId := Code[K] .Arg2;
            break;
          end;

        if Code[K] .Op = OP_SEPARATOR then
          break;

        Dec(K);
      until false;
    end
    else
    begin

    end;

  end
  else
    TrueSubId := SymbolRec1.Id;

  if (GetSymbolRec(TrueSubId).Level = H_TObject) and
     (GetSymbolRec(TrueSubId).Name = 'ClassName') then
  begin
    if Code[Code.N - 1].Op = OP_PUSH_CLSREF then
      Prg.AsmPush_Imm(1)
    else
      Prg.AsmPush_Imm(0);
  end;

  {$IFDEF TRIAL}
   Inc(_Counter);
  {$ENDIF}

  GetReg(_EBX);
  Reg := _EBX;

  if GetSymbolRec(TrueSubId).ExtraParamNeeded then
  begin
    if GetSymbolRec(TrueSubId).CallConv = ccREGISTER then
    begin
      K := 0;
      if GetSymbolRec(TrueSubId).IsMethod then
        Inc(K);

      for I:= 0 to R.Arg2 - 1 do
      begin
        ParamId := SymbolTable.GetParamId(TrueSubId, I);
        if GetSymbolRec(ParamId).Register > 0 then
        begin
          Inc(K);
          if GetSymbolRec(ParamId).FinalTypeId = typeDYNARRAY then
            if GetSymbolRec(ParamId).IsOpenArray then
              Inc(K);
        end;
      end;

      case K of
        0:
        begin
          GetReg(_EAX);
          EmitLoadAddress(_EAX, SymbolRecR);
          FreeReg(_EAX);
        end;
        1:
        begin
          GetReg(_EDX);
          EmitLoadAddress(_EDX, SymbolRecR);
          FreeReg(_EDX);
        end;
        2:
        begin
          GetReg(_ECX);
          EmitLoadAddress(_ECX, SymbolRecR);
          FreeReg(_ECX);
        end;
        else
        begin
          EmitLoadAddress(Reg, SymbolRecR);
          Prg.AsmPush_REG(Reg);
        end;
      end;
    end
    else
    begin

      if (GetSymbolRec(TrueSubId).CallConv = ccPASCAL) and
         (GetSymbolRec(TrueSubId).IsMethod) then
      begin
        GetReg(_EDX);
        Prg.AsmPop_REG(_EDX);
        FreeReg(_EDX);
      end;

      EmitLoadAddress(Reg, SymbolRecR);
      Prg.AsmPush_REG(Reg);

      if (GetSymbolRec(TrueSubId).CallConv = ccPASCAL) and
         (GetSymbolRec(TrueSubId).IsMethod) then
      begin
        GetReg(_EDX);
        Prg.AsmPush_REG(_EDX);
        FreeReg(_EDX);
      end;

    end;
  end; // extra param needed

  if Host1 then
  begin
    if (SymbolRec1.MethodIndex > 0) and (GetSymbolRec(SymbolRec1.Level).FinalTypeId = typeINTERFACE) then
      EmitInterfaceAddress(SymbolRec1.MethodIndex)
    else
      EmitGet_REG(Reg, SymbolRec1);
  end
  else
  begin
    if SymbolRec1.MethodIndex > 0 then
      EmitInterfaceAddress(SymbolRec1.MethodIndex)
    else if SymbolRec1.Kind = kindVAR then
      EmitLoadIntVal(Reg, SymbolRec1)
    else
    begin
      Prg.AsmMovREG_REG(Reg, _EDI);
      Prg.AsmAddREG_Imm(Reg, 0);
      Prg.Top.SaveSubId := R.Arg1;
      List2.Add(Prg.Top);
    end;
  end;

  if SymbolRec1.Kind = KindVAR then
    if SymbolRec1.Host then
    if SymbolRec1.FinalTypeId = typeEVENT then
    begin
      Prg.AsmMovREG32_REGPtr(Reg, Reg);
    end;

  Prg.AsmCall_REG(Reg);

  if SymbolRec1.Kind = KindVAR then
  begin
    T := SymbolRec1.TerminalTypeId;
    K := GetSymbolRec(T).PatternId;
    if GetSymbolRec(K).CallConv = ccCDECL then
      Prg.AsmAddREG_Imm(_ESP, SymbolTable.GetSizeOfParams(K));
  end
  else
  begin
    if SymbolRec1.CallConv = ccCDECL then
      Prg.AsmAddREG_Imm(_ESP, SymbolTable.GetSizeOfParams(R.Arg1));
  end;

  if not SymbolRec1.IsNestedSub then
  begin
    Prg.AsmPop_REG(_EDI);
    Prg.AsmPop_REG(_ESI);
  end;

  if R.Res <> 0 then
  begin
    SR := GetSymbolRec(R.Res);

    case SR.FinalTypeID of
      typeVOID:
      begin
        // ok
      end;
      typeBOOLEAN, typeBYTEBOOL, typeWORDBOOL, typeLONGBOOL,
      typeANSICHAR, typeWIDECHAR, typeENUM, typePOINTER,
      typeINTEGER, typeBYTE, typeWORD, typeSMALLINT, typeSHORTINT,
      typeCARDINAL, typeCLASS, typeCLASSREF:
      begin
        if SymbolRec1.CallConv = ccSAFECALL then
        begin
          RR := FindBeginCall;
          if RR = nil then
            RaiseError(errInternalError, []);
          EmitLoadIntVal(_EAX, GetSymbolRec(RR.Res));
        end;

        EmitPut_REG(_EAX, SymbolRecR);
      end;
      typeINT64:
      begin
        GetReg(_ECX);
        GetReg(_EDX);
        EmitLoadAddress(_ECX, SymbolRecR);
        Prg.AsmMovREGPtr_REG32(_ECX, _EAX);
        Prg.AsmAddREG_Imm(_ECX, 4);
        Prg.AsmMovREGPtr_REG32(_ECX, _EDX);
        FreeReg(_ECX);
        FreeReg(_EDX);
      end;
      typeANSISTRING:
      begin
        {$IFDEF FPC}
          GetReg(_EAX);

          Prg.AsmPush_REG(_EAX); // save result of function

          EmitLoadAddress(_EAX, SymbolRecR); // load address into EAX
          SubId := Id_DecStringCounter;
          EmitGet_REG(_EBX, TKernel(kernel).SymbolTable[SubId]);
          Prg.AsmCall_REG(_EBX);

          EmitLoadAddress(_EAX, SymbolRecR); // load address into EAX

          Prg.AsmPop_REG(_EBX);
          Prg.AsmMovREGPtr_REG32(_EAX, _EBX);

          FreeReg(_EAX);
        {$ELSE}
        // ok
        {$ENDIF}
      end;
      typeSHORTSTRING:
      begin
        // ok
      end;
      typeWIDESTRING:
      begin
        // ok
      end;
      typeUNICSTRING:
      begin
        // ok
      end;
      typeINTERFACE:
      begin
        // ok
      end;
      typeVARIANT, typeOLEVARIANT:
      begin
        // ok
      end;
      typeRECORD:
      begin
        if GetSymbolRec(TrueSubId).CallConv = ccMSFASTCALL then
        begin
          T := GetSymbolRec(TrueSubId).TerminalTypeId;
          if GetSymbolRec(T).Size <= 4 then
          begin
            EmitPut_REG(_EAX, SymbolRecR);
          end
          else if GetSymbolRec(T).Size <= 8 then
          begin
            GetReg(_ECX);
            GetReg(_EDX);
            EmitLoadAddress(_ECX, SymbolRecR);
            Prg.AsmMovREGPtr_REG32(_ECX, _EAX);
            Prg.AsmAddREG_Imm(_ECX, 4);
            Prg.AsmMovREGPtr_REG32(_ECX, _EDX);
            FreeReg(_ECX);
            FreeReg(_EDX);
          end;
        end;
      end;
      typeARRAY:
      begin
        // ok
      end;
      typeDYNARRAY:
      begin
        // ok
      end;
      typeSET:
      begin
        // ok
      end;
      typeDOUBLE:
      begin
        EmitLoadAddress(Reg, SymbolRecR);
        Prg.AsmFStpDouble_REGPtr(Reg);
      end;
      typeSINGLE:
      begin
        EmitLoadAddress(Reg, SymbolRecR);
        Prg.AsmFStpSingle_REGPtr(Reg);
      end;
      typeEXTENDED:
      begin
        EmitLoadAddress(Reg, SymbolRecR);
        Prg.AsmFStpExtended_REGPtr(Reg);
      end;
      typeCURRENCY:
      begin
        EmitLoadAddress(Reg, SymbolRecR);
        EmitFistp(SymbolRecR);
      end;
      typeEVENT:
      begin
        // ok
      end;
      else
        RaiseError(errInternalError, []);
    end;
  end;

  FreeReg(Reg);

  if TrueSubId = Id_TObject_Free then
  begin
    I := Code[Code.N - 1].Arg1;
    Reg := EmitGetAddressRegister(SymbolTable[I]);
    Prg.AsmMovREGPtr_Imm(Reg, SymbolTable[I], 0);
    FreeReg(Reg);
  end;

  if HandlesEvents then
  begin
    GetReg(_EBX);
    Reg := _EBX;

    Prg.AsmMovREG_REG(Reg, _ESI);
    Prg.AsmAddREG_Imm(Reg, H_SelfPtr);
    Prg.AsmMovREG32_REGPtr(Reg, Reg); // load TProgram.Self
    Prg.AsmPush_REG(Reg);             // push TProgram.Self

    EmitGet_REG(Reg, SymbolTable[Id_CondHalt]);
    Prg.AsmCall_REG(Reg);

    FreeReg(Reg);
  end;
end;

procedure TEmitter.EmitOP_INIT_SUB;

procedure Z;
var
  R: TSymbolProgRec;
begin
  R := Prg.AsmMovREG_Imm(_EBX, 400000);
  R.Z := true;

  Prg.AsmCall_REG(_EBX);
  Prg.AsmJMP_Imm(10);

  Prg.AsmAddREG_Imm(_EAX, 400000);
  Prg.AsmAddREG_Imm(_EAX, 400000);

  Prg.AsmGetREG32_ESIPtr(_EBX, 6);
  Prg.AsmMovREG_REG(_EDI, _EBX);

  Prg.AsmGetREG32_ESIPtr(_EBX, 11);
  Prg.AsmMovREG_REG(_ESI, _EBX);
end;

var
  SubId, I, J, T, TypeID, Reg, S, ParamId, ParamCount, SZ, FT, SubId2: Integer;
  L, TypeList, ProtectedShits: TIntegerList;
begin
  EmitPCodeOperator;

  ProtectedShits := TIntegerList.Create;

  try

  SubId := R.Arg1;
  ParamCount := GetSymbolRec(SubId).Count;

  for I:=0 to ParamCount - 1 do
  begin
    ParamId := SymbolTable.GetParamId(SubId, I);
    if GetSymbolRec(ParamId).Register > 0 then
      ProtectedShits.Add(GetSymbolRec(ParamId).Shift);
  end;

//  if not SymbolRec1.IsNestedSub then
//  begin
//    Prg.AsmLoadESI_ESPPtr(4 + 4 + SymbolTable.GetSizeOfParams(SubId));
//   Prg.AsmLoadEDI_ESPPtr(4 + SymbolTable.GetSizeOfParams(SubId));
//  end;

  Prg.AsmPush_REG(_EBP);
  Prg.AsmMovREG_REG(_EBP, _ESP);
  Prg.AsmAddREG_Imm(_ESP, - SymbolTable.GetSizeOfLocalsEx(SubId));

  if not SymbolRec1.IsNestedSub then
  begin
    Prg.AsmPush_REG(_ESI);
    Prg.AsmPush_REG(_EDI);
    Prg.AsmPush_REG(_EBX);

    Z;
  end;

  ContextStack.Push(SubId);

  if GetSymbolRec(SubId).CallConv in [ccREGISTER, ccMSFASTCALL] then
  begin
    ParamId := SymbolTable.GetSelfId(SubId);
    if GetSymbolRec(ParamId).Register > 0 then
      Prg.AsmPutREG32_EBPPtr(GetSymbolRec(ParamId).Register, GetOffset(GetSymbolRec(ParamId)));

    for I:=0 to GetSymbolRec(SubId).Count - 1 do
    begin
      ParamId := SymbolTable.GetParamId(SubId, I);
      if GetSymbolRec(ParamId).Register > 0 then
        Prg.AsmPutREG32_EBPPtr(GetSymbolRec(ParamId).Register, GetOffset(GetSymbolRec(ParamId)));
    end;

    if GetSymbolRec(SubId).ExtraParamNeeded then
    begin
      ParamId := SymbolTable.GetResultId(SubId);
      if GetSymbolRec(ParamId).Register > 0 then
        Prg.AsmPutREG32_EBPPtr(GetSymbolRec(ParamId).Register, GetOffset(GetSymbolRec(ParamId)));
    end;
  end;

  // init dynamic vars

  for I:=0 to ParamCount - 1 do
  begin
    ParamId := SymbolTable.GetParamId(SubId, I);
    FT := SymbolTable[ParamId].FinalTypeId;
    if FT in [typeRECORD, typeARRAY] then
      if not SymbolTable[ParamId].ByRef then
      begin
        TypeId := SymbolTable[ParamId].TerminalTypeId;
        L := SymbolTable.GetShiftsOfDynamicFields(TypeId);
        TypeList := SymbolTable.GetTypesOfDynamicFields(TypeId);

        if TypeList.Count <> L.Count then
          RaiseError(errInternalError, []);

        try

          Reg := GetReg;

          for J:=0 to L.Count - 1 do
          begin
            S := L[J];

            SubId2 := 0;
            case GetSymbolRec(TypeList[J]).FinalTypeId of
              typeANSISTRING: SubId2 := Id_StringAddRef;
              typeWIDESTRING: SubId2 := Id_WideStringAddRef;
              typeUNICSTRING: SubId2 := Id_UnicStringAddRef;
              typeVARIANT, typeOLEVARIANT: SubId2 := Id_VariantAddRef;
              typeDYNARRAY: SubId2 := Id_DynarrayAddRef;
              typeINTERFACE: SubId2 := Id_InterfaceAddRef;
             else
              RaiseError(errInternalError, []);
            end;

            EmitLoadAddress(Reg, SymbolTable[ParamId]);
            Prg.AsmAddREG_Imm(Reg, S);
            Prg.AsmPush_REG(Reg);

            EmitGet_REG(Reg, SymbolTable[SubId2]);
            Prg.AsmCall_REG(Reg);
          end;

          FreeReg(Reg);

        finally

          L.Free;
          TypeList.Free;

        end;
      end;
  end;

  for I:=SubId + 1 to SymbolTable.Card do
  begin
    if SymbolTable[I].Level = SubId then
       if SymbolTable[I].Kind = KindVAR then
       begin
          if not SymbolTable[I].ByRef then
            begin
              if SymbolTable[I].Local and (not SymbolTable[I].Param) then
              if ProtectedShits.IndexOf(SymbolTable[I].Shift) = -1 then
              begin
                T := SymbolTable[I].FinalTypeId;
                case T of
                  typeANSISTRING, typeWIDESTRING, typeUNICSTRING, typeDYNARRAY,
                  typeINTERFACE, typeCLASS, typeCLASSREF:
                  begin
                    Reg := EmitGetAddressRegister(SymbolTable[I]);
                    Prg.AsmMovREGPtr_Imm(Reg, SymbolTable[I], 0);
                    FreeReg(Reg);
                  end;
                  typeSET:
                  begin
                    T := SymbolTable[I].TerminalTypeId;
                    SZ := SymbolTable.GetSizeOfSetType(T) div 4;
                    if SZ = 0 then
                      SZ := 1;
                    Reg := GetReg;
                    EmitLoadAddress(Reg, SymbolTable[I]);
                    for J := 1 to SZ do
                    begin
                      Prg.AsmMovREGPtr32_Imm(Reg, 0);
                      if J < SZ then
                        Prg.AsmAddREG_Imm(Reg, 4);
                    end;
                    FreeReg(Reg);
                  end;
                  typeVARIANT, typeOLEVARIANT:
                  begin
                    Reg := GetReg;
                    EmitLoadAddress(Reg, SymbolTable[I]);
                    Prg.AsmMovREGPtr32_Imm(Reg, 0);
                    Prg.AsmAddREG_Imm(Reg, 4);
                    Prg.AsmMovREGPtr32_Imm(Reg, 0);
                    Prg.AsmAddREG_Imm(Reg, 4);
                    Prg.AsmMovREGPtr32_Imm(Reg, 0);
                    Prg.AsmAddREG_Imm(Reg, 4);
                    Prg.AsmMovREGPtr32_Imm(Reg, 0);
                    FreeReg(Reg);
                  end;
                  typeRECORD, typeARRAY:
                  begin
                    TypeId := SymbolTable[I].TerminalTypeId;
                    L := SymbolTable.GetShiftsOfDynamicFields(TypeId);

                    Reg := GetReg;

                    for J:=0 to L.Count - 1 do
                    begin
                      S := L[J];
                      EmitLoadAddress(Reg, SymbolTable[I]);
                      Prg.AsmAddREG_Imm(Reg, S);
                      Prg.AsmMovREGPtr32_Imm(Reg, 0);
                    end;

                    FreeReg(Reg);

                    L.Free;
                  end;
                end;
              end; // local
            end;
       end;
  end;

  if TKernel(Kernel).DEBUG_MODE then
  begin
    Prg.AsmComment('***** N ****** ' + IntToStr(TKernel(kernel).Code.N));
    Prg.AsmMovREGPtr32_Imm(_ESI, H_ByteCodePtr, TKernel(kernel).Code.N);

    Emit_PUSH_REGS_EX;

    GetReg(_EAX);
    GetReg(_EDX);

    Prg.AsmMovREG_REG(_EAX, _ESI);
    Prg.AsmAddREG_Imm(_EAX, H_SelfPtr);
    Prg.AsmMovREG32_REGPtr(_EAX, _EAX); // load TProgram.Self

    Prg.AsmMovREG_Imm(_EDX, SubId);
    Prg.AsmMovREG_REG(_ECX, _EBP);

    GetReg(_EBX);
    EmitGet_REG(_EBX, SymbolTable[Id_InitSub]);
    Prg.AsmCall_REG(_EBX);
    FreeReg(_EBX);

    FreeReg(_EAX);
    FreeReg(_EDX);

    Emit_POP_REGS_EX;
  end;

  finally

    ProtectedShits.Free;

  end;
end;

procedure TEmitter.EmitOP_END_SUB;
begin
  EmitPCodeOperator;
end;

procedure TEmitter.EmitOP_FIN_SUB;
var
  TypeID, ResultId, SubId, Reg,
  T, I, J, ParamId, ParamCount, FT, SubId2, S,
  ArrayTypeId, ElTypeId, ElFinalTypeId, ElSize: Integer;

  L, TypeList: TIntegerList;
begin
  EmitPCodeOperator;

  SubId := R.Arg1;

  I := SymbolTable[SubId].Level;
  if I > 0 then
    if SymbolTable[I].FinalTypeId = typeINTERFACE then
      Exit;

  ParamCount := GetSymbolRec(SubId).Count;

  // clear dynamic fields in parameters

  for I:=0 to ParamCount - 1 do
  begin
    ParamId := SymbolTable.GetParamId(SubId, I);
    FT := SymbolTable[ParamId].FinalTypeId;
    if FT in [typeRECORD, typeARRAY] then
      if not SymbolTable[ParamId].ByRef then
      begin
        TypeId := SymbolTable[ParamId].TerminalTypeId;
        L := SymbolTable.GetShiftsOfDynamicFields(TypeId);
        TypeList := SymbolTable.GetTypesOfDynamicFields(TypeId);

        if TypeList.Count <> L.Count then
          RaiseError(errInternalError, []);

        try

          Reg := GetReg;

          for J:=0 to L.Count - 1 do
          begin
            S := L[J];

            SubId2 := 0;
            case GetSymbolRec(TypeList[J]).FinalTypeId of
              typeANSISTRING: SubId2 := Id_AnsiStringClr;
              typeWIDESTRING: SubId2 := Id_WideStringClr;
              typeUNICSTRING: SubId2 := Id_UnicStringClr;
              typeVARIANT, typeOLEVARIANT: SubId2 := Id_VariantClr;
              typeDYNARRAY:
              begin
                SubId2 := Id_DynarrayClr;

                ArrayTypeId := TypeList[J];
                ElTypeId := GetSymbolRec(ArrayTypeId).PatternId;
                ElFinalTypeId := GetSymbolRec(ElTypeId).FinalTypeId;
                ElSize := SymbolTable[ElTypeId].Size;

                Prg.AsmPush_Imm(ElSize);
                Prg.AsmPush_Imm(ElTypeId);
                Prg.AsmPush_Imm(ElFinalTypeId);

              end;
              typeINTERFACE: SubId2 := Id_InterfaceClr;
             else
              RaiseError(errInternalError, []);
            end;

            EmitLoadAddress(Reg, SymbolTable[ParamId]);
            Prg.AsmAddREG_Imm(Reg, S);
            Prg.AsmPush_REG(Reg);

            EmitGet_REG(Reg, SymbolTable[SubId2]);
            Prg.AsmCall_REG(Reg);
          end;

          FreeReg(Reg);

        finally

          L.Free;
          TypeList.Free;

        end;
      end;
  end;


  if TKernel(Kernel).DEBUG_MODE then
  begin
    GetReg(_EAX);

    Prg.AsmMovREG_REG(_EAX, _ESI);
    Prg.AsmAddREG_Imm(_EAX, H_SelfPtr);
    Prg.AsmMovREG32_REGPtr(_EAX, _EAX); // load TProgram.Self

    GetReg(_EBX);
    EmitGet_REG(_EBX, SymbolTable[Id_EndSub]);
    Prg.AsmCall_REG(_EBX);
    FreeReg(_EBX);

    FreeReg(_EAX);
  end;

  TypeID := SymbolRec1.FinalTypeID;
  ResultId := SymbolTable.GetResultId(SubId);

  if SymbolRec1.Kind = KindCONSTRUCTOR then
  begin
    ResultId := SymbolTable.GetSelfId(SubId);
    EmitGet_REG(_EAX, SymbolTable[ResultId]);
  end
  else if SymbolRec1.Kind = KindDESTRUCTOR then
  begin
    // ok
  end
  else if TypeID = typeINT64 then
  begin
    GetReg(_EAX);
    GetReg(_EDX);
    GetReg(_ECX);

    EmitLoadAddress(_ECX, SymbolTable[ResultId]);
    Prg.AsmMovREG32_REGPtr(_EAX, _ECX);
    Prg.AsmAddREG_Imm(_ECX, 4);
    Prg.AsmMovREG32_REGPtr(_EDX, _ECX);

    FreeReg(_EAX);
    FreeReg(_EDX);
    FreeReg(_ECX);
  end
  else if (TypeID = typeRECORD) and
          (SymbolRec1.CallConv = ccMSFASTCALL) then
  begin
    T := SymbolRec1.TerminalTypeId;
    if GetSymbolRec(T).Size <= 4 then
    begin
      EmitGet_REG(_EAX, SymbolTable[ResultId]);
    end
    else if GetSymbolRec(T).Size <= 8 then
    begin
      GetReg(_EAX);
      GetReg(_EDX);
      GetReg(_ECX);

      EmitLoadAddress(_ECX, SymbolTable[ResultId]);
      Prg.AsmMovREG32_REGPtr(_EAX, _ECX);
      Prg.AsmAddREG_Imm(_ECX, 4);
      Prg.AsmMovREG32_REGPtr(_EDX, _ECX);

      FreeReg(_EAX);
      FreeReg(_EDX);
      FreeReg(_ECX);
    end;
  end
  else if TypeID in (OrdinalTypes + [typeANSISTRING, typeWIDESTRING, typeUNICSTRING, typeVARIANT,
                typeOLEVARIANT,
                typePOINTER, typeCLASS, typeCLASSREF, typeDYNARRAY,
                typeINTERFACE]) then
  begin
    EmitGet_REG(_EAX, SymbolTable[ResultId]);
  end
  else if TypeID = typeDOUBLE then
  begin
    Reg := GetReg;
    Prg.AsmMovREG_REG(Reg, _EBP);
    Prg.AsmAddREG_Imm(Reg, GetOffset(SymbolTable[ResultId]));
    Prg.AsmFldDouble_REGPtr(Reg);
    FreeReg(Reg);
  end
  else if TypeID = typeSINGLE then
  begin
    Reg := GetReg;
    Prg.AsmMovREG_REG(Reg, _EBP);
    Prg.AsmAddREG_Imm(Reg, GetOffset(SymbolTable[ResultId]));
    Prg.AsmFldSingle_REGPtr(Reg);
    FreeReg(Reg);
  end
  else if TypeID = typeEXTENDED then
  begin
    Reg := GetReg;
    Prg.AsmMovREG_REG(Reg, _EBP);
    Prg.AsmAddREG_Imm(Reg, GetOffset(SymbolTable[ResultId]));
    Prg.AsmFldExtended_REGPtr(Reg);
    FreeReg(Reg);
  end
  else if TypeID = typeCURRENCY then
  begin
    Reg := GetReg;
    Prg.AsmMovREG_REG(Reg, _EBP);
    Prg.AsmAddREG_Imm(Reg, GetOffset(SymbolTable[ResultId]));
    Prg.AsmFild_REG64Ptr(Reg);
    FreeReg(Reg);
  end;

  if not SymbolRec1.IsNestedSub then
  begin
    Prg.AsmPop_REG(_EBX);
    Prg.AsmPop_REG(_EDI);
    Prg.AsmPop_REG(_ESI);
  end;

  Prg.AsmMovREG_REG(_ESP, _EBP);
  Prg.AsmPop_REG(_EBP);

  if SymbolTable[SubId].CallConv = ccCDECL then
    Prg.AsmRet(0)
  else
    Prg.AsmRet(SymbolTable.GetSizeOfParams(R.Arg1));

  ContextStack.Pop;
end;

procedure TEmitter.EmitOP_PUSH_EBP;
var
  SubId, CurrSubId, Height, CurrHeight, Reg, I, D: Integer;
begin
  EmitPCodeOperator;

  if ContextStack.Count >= 2 then
  begin

    SubId := SymbolRecR.Id;
    CurrSubId := ContextStack.Top;

    Height := GetSymbolRec(SubId).Height;
    CurrHeight := GetSymbolRec(CurrSubId).Height;

    if Height > CurrHeight then
    begin
      Prg.AsmPush_REG(_EBP);
      Exit;
    end;

    D := CurrHeight - Height;

    Reg := _EBX;
    Prg.AsmMovREG_REG(Reg, _EBP);

    for I:=ContextStack.Count - 1 downto 0 do
    begin
      SubId := ContextStack[I];
      Prg.AsmAddREG_Imm(Reg, 8 + SymbolTable.GetSizeOfParams(SubId));
      Prg.AsmMovREG32_REGPtr(Reg, Reg);

      Dec(D);
      if D < 0 then
        break;
    end;

    Prg.AsmPush_REG(Reg);
  end
  else
    Prg.AsmPush_REG(_EBP);
end;

procedure TEmitter.EmitOP_POP;
var
  Reg: Integer;
begin
  EmitPCodeOperator;

  Reg := GetReg;
  Prg.AsmPop_REG(Reg);
  FreeReg(Reg);
end;

procedure TEmitter.EmitOP_SAVE_REGS;
begin
  EmitPCodeOperator;
  Emit_PUSH_REGS;
end;

procedure TEmitter.EmitOP_RESTORE_REGS;
begin
  EmitPCodeOperator;
  Emit_POP_REGS;
end;

procedure TEmitter.EmitOP_RET;
begin
  EmitPCodeOperator;

  Prg.AsmRet;
end;

procedure TEmitter.EmitOP_FIELD;
var
  Reg: Integer;
  PatternId: Integer;
begin
  EmitPCodeOperator;
  Reg := GetReg;
  EmitLoadAddress(Reg, SymbolRec1); // load address of record

  PatternId := SymbolRec2.PatternId; // find id of pattern field

  if SymbolRec1.FinalTypeId = typeCLASS then
    Prg.AsmMovREG32_REGPtr(Reg, Reg);

  Prg.AsmAddREG_Imm(Reg, GetOffset(SymbolTable[PatternId]));

  EmitPut_REG(Reg, SymbolRec2);
  FreeReg(Reg);
end;

procedure TEmitter.EmitOP_ELEM;
var
  Reg, RegIndex: Integer;
  ArrayTypeId, RangeTypeId, ElemTypeId, H1, ElSize: Integer;
begin
  EmitPCodeOperator;

  if SymbolRec1.HasPAnsiCharType then // pchar
  begin
    RegIndex := GetReg;
    Reg := GetReg;

    if SymbolRec2.Kind = KindCONST then
      Prg.AsmMovReg_Imm(RegIndex, SymbolRec2.Value)
    else
      EmitLoadIntVal(RegIndex, SymbolRec2); // RegIndex := <index value>

    EmitLoadAddress(Reg, SymbolRec1);     // Reg := <address of string>
    Prg.AsmMovREG32_REGPtr(Reg, Reg);
    Prg.AsmAddREG_REG(Reg, RegIndex);     // Reg := Reg + RegIndex
    EmitPut_REG(Reg, SymbolTable[R.Res]); // save address

    FreeReg(Reg);
    FreeReg(RegIndex);
  end
  else if SymbolRec1.HasPWideCharType then // pchar
  begin
    RegIndex := GetReg;
    Reg := GetReg;

    if SymbolRec2.Kind = KindCONST then
      Prg.AsmMovReg_Imm(RegIndex, SymbolRec2.Value)
    else
      EmitLoadIntVal(RegIndex, SymbolRec2); // RegIndex := <index value>

    EmitLoadAddress(Reg, SymbolRec1);     // Reg := <address of string>
    Prg.AsmMovREG32_REGPtr(Reg, Reg);
    Prg.AsmAddREG_REG(Reg, RegIndex);     // Reg := Reg + RegIndex
    Prg.AsmAddREG_REG(Reg, RegIndex);     // Reg := Reg + RegIndex
    EmitPut_REG(Reg, SymbolTable[R.Res]); // save address

    FreeReg(Reg);
    FreeReg(RegIndex);
  end
  else if SymbolRec1.FinalTypeId = typeANSISTRING then
  begin
    RegIndex := GetReg;
    Reg := GetReg;

    if SymbolRec2.Kind = KindCONST then
    begin
      Prg.AsmMovReg_Imm(RegIndex, SymbolRec2.Value - 1);
    end
    else
    begin
      EmitLoadIntVal(RegIndex, SymbolRec2); // RegIndex := <index value>
      Prg.AsmAddReg_Imm(RegIndex, -1);
    end;

    EmitLoadAddress(Reg, SymbolRec1);     // Reg := <address of string>
    Prg.AsmMovREG32_REGPtr(Reg, Reg);
    Prg.AsmAddREG_REG(Reg, RegIndex);     // Reg := Reg + RegIndex
    EmitPut_REG(Reg, SymbolTable[R.Res]); // save address

    FreeReg(Reg);
    FreeReg(RegIndex);
  end
  else if SymbolRec1.FinalTypeId in [typeWIDESTRING, typeUNICSTRING] then
  begin
    RegIndex := GetReg;
    Reg := GetReg;

    if SymbolRec2.Kind = KindCONST then
    begin
      Prg.AsmMovReg_Imm(RegIndex, (SymbolRec2.Value - 1) * SizeOf(WideChar));
    end
    else
    begin
      EmitLoadIntVal(RegIndex, SymbolRec2); // RegIndex := <index value>
      Prg.AsmAddReg_Imm(RegIndex, -1);
      Prg.AsmAddREG_REG(RegIndex, RegIndex);
    end;

    EmitLoadAddress(Reg, SymbolRec1);     // Reg := <address of string>
    Prg.AsmMovREG32_REGPtr(Reg, Reg);
    Prg.AsmAddREG_REG(Reg, RegIndex);     // Reg := Reg + RegIndex
    EmitPut_REG(Reg, SymbolTable[R.Res]); // save address

    FreeReg(Reg);
    FreeReg(RegIndex);
  end
  else if SymbolRec1.FinalTypeId = typeSHORTSTRING then
  begin
    RegIndex := GetReg;
    Reg := GetReg;

    EmitLoadIntVal(RegIndex, SymbolRec2); // RegIndex := <index value>
    EmitLoadAddress(Reg, SymbolRec1);     // Reg := <address of string>
    Prg.AsmAddREG_REG(Reg, RegIndex);     // Reg := Reg + RegIndex
    EmitPut_REG(Reg, SymbolTable[R.Res]); // save address

    FreeReg(Reg);
    FreeReg(RegIndex);
  end
  else if SymbolRec1.FinalTypeId = typeDYNARRAY then // dynamic array
  begin
    ArrayTypeId := SymbolRec1.TerminalTypeId;
    ElemTypeId := GetSymbolRec(ArrayTypeId).PatternId;
    ElSize := SymbolTable[ElemTypeId].Size;

  // emit

    RegIndex := _EAX;
    GetReg(RegIndex);
    Reg := GetReg;

    EmitLoadIntVal(RegIndex, SymbolRec2); // RegIndex := <index value>
    Prg.AsmMovREG_Imm(Reg, ElSize);       // Reg := <size of element>
    Prg.AsmMulREG(Reg);                   // RegIndex := RegIndex * Reg

    EmitLoadAddress(Reg, SymbolRec1);     // Reg := <address of array>
    Prg.AsmMovREG32_REGPtr(Reg, Reg);
    Prg.AsmAddREG_REG(Reg, RegIndex);     // Reg := Reg + RegIndex
    EmitPut_REG(Reg, SymbolTable[R.Res]); // save address

    FreeReg(Reg);
    FreeReg(RegIndex);
  end
  else // static array
  begin
    ArrayTypeId := SymbolRec1.TerminalTypeId;
    SymbolTable.GetArrayTypeInfo(ArrayTypeId, RangeTypeId, ElemTypeId);
    H1 := SymbolTable.GetLowBoundRec(RangeTypeId).Value;
    ElSize := SymbolTable[ElemTypeId].Size;

  // emit

    RegIndex := _EAX;
    GetReg(RegIndex);
    Reg := GetReg;

    EmitLoadIntVal(RegIndex, SymbolRec2); // RegIndex := <index value>
    Prg.AsmAddREG_Imm(RegIndex, - H1);    // RegIndex := RegIndex - H1
    Prg.AsmMovREG_Imm(Reg, ElSize);       // Reg := <size of element>
    Prg.AsmMulREG(Reg);                   // RegIndex := RegIndex * Reg

    EmitLoadAddress(Reg, SymbolRec1);     // Reg := <address of array>
    Prg.AsmAddREG_REG(Reg, RegIndex);     // Reg := Reg + RegIndex
    EmitPut_REG(Reg, SymbolTable[R.Res]); // save address

    FreeReg(Reg);
    FreeReg(RegIndex);
  end;
end;

procedure TEmitter.EmitOP_INT_TO_INT64;
begin
  EmitPCodeOperator;

  GetReg(_ECX);
  EmitLoadAddress(_ECX, SymbolRecR);

  GetReg(_EAX);
  GetReg(_EDX);

  EmitLoadIntVal(_EAX, SymbolRec1);
  Prg.AsmCDQ;
  Prg.AsmMovREGPtr_REG32(_ECX, _EAX);
  Prg.AsmAddREG_Imm(_ECX, 4);
  Prg.AsmMovREGPtr_REG32(_ECX, _EDX);

  FreeReg(_EAX);
  FreeReg(_EDX);
  FreeReg(_ECX);
end;

procedure TEmitter.EmitOP_BYTE_TO_INT64;
begin
  EmitPCodeOperator;

  GetReg(_ECX);
  EmitLoadAddress(_ECX, SymbolRecR);

  GetReg(_EAX);
  GetReg(_EDX);

  EmitLoadIntVal(_EAX, SymbolRec1);
  Prg.AsmXorREG_REG(_EDX, _EDX);
  Prg.AsmMovREGPtr_REG32(_ECX, _EAX);
  Prg.AsmAddREG_Imm(_ECX, 4);
  Prg.AsmMovREGPtr_REG32(_ECX, _EDX);

  FreeReg(_EAX);
  FreeReg(_EDX);
  FreeReg(_ECX);
end;

procedure TEmitter.EmitOP_WORD_TO_INT64;
begin
  EmitPCodeOperator;

  GetReg(_ECX);
  EmitLoadAddress(_ECX, SymbolRecR);

  GetReg(_EAX);
  GetReg(_EDX);

  EmitLoadIntVal(_EAX, SymbolRec1);
  Prg.AsmXorREG_REG(_EDX, _EDX);
  Prg.AsmMovREGPtr_REG32(_ECX, _EAX);
  Prg.AsmAddREG_Imm(_ECX, 4);
  Prg.AsmMovREGPtr_REG32(_ECX, _EDX);

  FreeReg(_EAX);
  FreeReg(_EDX);
  FreeReg(_ECX);
end;

procedure TEmitter.EmitOP_CARDINAL_TO_INT64;
begin
  EmitPCodeOperator;

  GetReg(_ECX);
  EmitLoadAddress(_ECX, SymbolRecR);

  GetReg(_EAX);
  GetReg(_EDX);

  EmitLoadIntVal(_EAX, SymbolRec1);
  Prg.AsmXorREG_REG(_EDX, _EDX);
  Prg.AsmMovREGPtr_REG32(_ECX, _EAX);
  Prg.AsmAddREG_Imm(_ECX, 4);
  Prg.AsmMovREGPtr_REG32(_ECX, _EDX);

  FreeReg(_EAX);
  FreeReg(_EDX);
  FreeReg(_ECX);
end;

procedure TEmitter.EmitOP_SMALLINT_TO_INT64;
begin
  EmitPCodeOperator;

  GetReg(_ECX);
  EmitLoadAddress(_ECX, SymbolRecR);

  GetReg(_EAX);
  GetReg(_EDX);

  EmitLoadIntVal(_EAX, SymbolRec1);
  Prg.AsmXorREG_REG(_EDX, _EDX);
  Prg.AsmMovREGPtr_REG32(_ECX, _EAX);
  Prg.AsmAddREG_Imm(_ECX, 4);
  Prg.AsmMovREGPtr_REG32(_ECX, _EDX);

  FreeReg(_EAX);
  FreeReg(_EDX);
  FreeReg(_ECX);
end;

procedure TEmitter.EmitOP_SHORTINT_TO_INT64;
begin
  EmitPCodeOperator;

  GetReg(_ECX);
  EmitLoadAddress(_ECX, SymbolRecR);

  GetReg(_EAX);
  GetReg(_EDX);

  EmitLoadIntVal(_EAX, SymbolRec1);
  Prg.AsmXorREG_REG(_EDX, _EDX);
  Prg.AsmMovREGPtr_REG32(_ECX, _EAX);
  Prg.AsmAddREG_Imm(_ECX, 4);
  Prg.AsmMovREGPtr_REG32(_ECX, _EDX);

  FreeReg(_EAX);
  FreeReg(_EDX);
  FreeReg(_ECX);
end;

procedure TEmitter.EmitOP_INT_TO_DOUBLE;
var
  Reg: Integer;
begin
  EmitPCodeOperator;

  EmitFild(SymbolRec1);

  Reg := GetReg;
  EmitLoadAddress(Reg, SymbolRecR);
  Prg.AsmFstpDouble_REGPtr(Reg);
  FreeReg(Reg);
end;

procedure TEmitter.EmitOP_INT64_TO_DOUBLE;
var
  Reg: Integer;
begin
  EmitPCodeOperator;

  Reg := GetReg;

  EmitLoadAddress(Reg, SymbolRec1);
  Prg.AsmFild_REG64Ptr(Reg);

  EmitLoadAddress(Reg, SymbolRecR);
  Prg.AsmFstpDouble_REGPtr(Reg);

  FreeReg(Reg);
end;

procedure TEmitter.EmitOP_INT_TO_SINGLE;
var
  Reg: Integer;
begin
  EmitPCodeOperator;

  EmitFild(SymbolRec1);

  Reg := GetReg;
  EmitLoadAddress(Reg, SymbolRecR);
  Prg.AsmFstpSingle_REGPtr(Reg);
  FreeReg(Reg);
end;

procedure TEmitter.EmitOP_INT64_TO_SINGLE;
var
  Reg: Integer;
begin
  EmitPCodeOperator;
  Reg := GetReg;
  EmitLoadAddress(Reg, SymbolRec1);
  Prg.AsmFild_REG64Ptr(Reg);
  EmitLoadAddress(Reg, SymbolRecR);
  Prg.AsmFstpSingle_REGPtr(Reg);
  FreeReg(Reg);
end;

procedure TEmitter.EmitOP_INT_TO_EXTENDED;
var
  Reg: Integer;
begin
  EmitPCodeOperator;

  EmitFild(SymbolRec1);

  Reg := GetReg;
  EmitLoadAddress(Reg, SymbolRecR);
  Prg.AsmFstpExtended_REGPtr(Reg);
  FreeReg(Reg);
end;

procedure TEmitter.EmitOP_INT64_TO_EXTENDED;
var
  Reg: Integer;
begin
  EmitPCodeOperator;
  Reg := GetReg;
  EmitLoadAddress(Reg, SymbolRec1);
  Prg.AsmFild_REG64Ptr(Reg);
  EmitLoadAddress(Reg, SymbolRecR);
  Prg.AsmFstpExtended_REGPtr(Reg);
  FreeReg(Reg);
end;

procedure TEmitter.EmitOP_DOUBLE_TO_SINGLE;
var
  Reg: Integer;
begin
  EmitPCodeOperator;
  Reg := GetReg;
  EmitLoadAddress(Reg, SymbolRec1);
  Prg.AsmFldDouble_REGPtr(Reg);
  EmitLoadAddress(Reg, SymbolRecR);
  Prg.AsmFstpSingle_REGPtr(Reg);
  FreeReg(Reg);
end;

procedure TEmitter.EmitOP_DOUBLE_TO_EXTENDED;
var
  Reg: Integer;
begin
  EmitPCodeOperator;
  Reg := GetReg;
  EmitLoadAddress(Reg, SymbolRec1);
  Prg.AsmFldDouble_REGPtr(Reg);
  EmitLoadAddress(Reg, SymbolRecR);
  Prg.AsmFstpExtended_REGPtr(Reg);
  FreeReg(Reg);
end;

procedure TEmitter.EmitOP_EXTENDED_TO_DOUBLE;
var
  Reg: Integer;
begin
  EmitPCodeOperator;
  Reg := GetReg;
  EmitLoadAddress(Reg, SymbolRec1);
  Prg.AsmFldExtended_REGPtr(Reg);
  EmitLoadAddress(Reg, SymbolRecR);
  Prg.AsmFstpDouble_REGPtr(Reg);
  FreeReg(Reg);
end;

procedure TEmitter.EmitOP_EXTENDED_TO_SINGLE;
var
  Reg: Integer;
begin
  EmitPCodeOperator;
  Reg := GetReg;
  EmitLoadAddress(Reg, SymbolRec1);
  Prg.AsmFldExtended_REGPtr(Reg);
  EmitLoadAddress(Reg, SymbolRecR);
  Prg.AsmFstpSingle_REGPtr(Reg);
  FreeReg(Reg);
end;

procedure TEmitter.EmitOP_SINGLE_TO_DOUBLE;
var
  Reg: Integer;
begin
  EmitPCodeOperator;
  Reg := GetReg;
  EmitLoadAddress(Reg, SymbolRec1);
  Prg.AsmFldSingle_REGPtr(Reg);
  EmitLoadAddress(Reg, SymbolRecR);
  Prg.AsmFstpDouble_REGPtr(Reg);
  FreeReg(Reg);
end;

procedure TEmitter.EmitFDiv_10000;
begin
  Prg.AsmFDiv_ESIPtr32(GetOffset(GetSymbolRec(CURR_FMUL_Id)));
end;

procedure TEmitter.EmitFMul_10000;
begin
  Prg.AsmFMul_ESIPtr32(GetOffset(GetSymbolRec(CURR_FMUL_Id)));
end;

procedure TEmitter.EmitOP_CURRENCY_TO_DOUBLE;
begin
  EmitPCodeOperator;

  EmitFild(SymbolRec1);
  EmitFDiv_10000;
  EmitFstp(SymbolRecR);
end;

procedure TEmitter.EmitOP_CURRENCY_TO_SINGLE;
begin
  EmitPCodeOperator;

  EmitFild(SymbolRec1);
  EmitFDiv_10000;
  EmitFstp(SymbolRecR);
end;

procedure TEmitter.EmitOP_CURRENCY_TO_EXTENDED;
begin
  EmitPCodeOperator;

  EmitFild(SymbolRec1);
  EmitFDiv_10000;
  EmitFstp(SymbolRecR);
end;

procedure TEmitter.EmitOP_SINGLE_TO_EXTENDED;
var
  Reg: Integer;
begin
  EmitPCodeOperator;
  Reg := GetReg;
  EmitLoadAddress(Reg, SymbolRec1);
  Prg.AsmFldSingle_REGPtr(Reg);
  EmitLoadAddress(Reg, SymbolRecR);
  Prg.AsmFstpExtended_REGPtr(Reg);
  FreeReg(Reg);
end;

procedure TEmitter.EmitOP_ADDRESS_PROG;
var
  Reg: Integer;
begin
  EmitPCodeOperator;
  Reg := GetReg;
  Prg.AsmMovREG_REG(Reg, _ESI);
  Prg.AsmAddREG_Imm(Reg, H_SelfPtr);
  EmitSaveIntVal(Reg, SymbolRecR);
  FreeReg(Reg);
end;

procedure TEmitter.EmitOP_ASSIGN_PROG;
var
  Reg: Integer;
begin
  EmitPCodeOperator;
  Reg := GetReg;

  Prg.AsmMovREG_REG(Reg, _ESI);
  Prg.AsmAddREG_Imm(Reg, H_SelfPtr);
  Prg.AsmMovREG32_REGPtr(Reg, Reg);
  Prg.AsmPush_REG(Reg);

  EmitLoadIntVal(Reg, SymbolRecR);
  Prg.AsmPush_REG(Reg);

  EmitGet_REG(Reg, SymbolTable[JS_AssignProgId]);
  Prg.AsmCall_REG(Reg);

  FreeReg(Reg);
end;

procedure TEmitter.EmitOP_ADDRESS;
var
  Reg: Integer;
begin
  EmitPCodeOperator;

  Reg := GetReg;

  if SymbolRec1.Kind = KindSUB then
  begin

    if Host1 then
      EmitGet_REG(Reg, SymbolRec1)
    else
    begin
      Prg.AsmMovREG_REG(Reg, _EDI);
      Prg.AsmAddREG_Imm(Reg, 0);
      Prg.Top.SaveSubId := R.Arg1;
      List2.Add(Prg.Top);
    end;
    EmitSaveIntVal(Reg, SymbolRecR);

  end
  else
  begin
    EmitLoadAddress(Reg, SymbolRec1);
    EmitSaveIntVal(Reg, SymbolRecR);
  end;

  FreeReg(Reg);
end;

procedure TEmitter.EmitOP_INIT_PCHAR_LITERAL;
var
  Reg: Integer;
begin
  EmitPCodeOperator;

  Reg := GetReg;

  EmitLoadAddress(Reg, SymbolRec1);
  Prg.AsmAddREG_Imm(Reg, 12);
  EmitSaveIntVal(Reg, SymbolRec1);

  FreeReg(Reg);
end;

procedure TEmitter.EmitOP_INIT_PWIDECHAR_LITERAL;
var
  Reg: Integer;
begin
  EmitPCodeOperator;

  Reg := GetReg;

  EmitLoadAddress(Reg, SymbolRec1);
  Prg.AsmAddREG_Imm(Reg, 8);
  EmitSaveIntVal(Reg, SymbolRec1);

  FreeReg(Reg);
end;

procedure TEmitter.EmitOP_TERMINAL;
var
  Reg, temp: Integer;
begin
  EmitPCodeOperator;

  Reg := GetReg;

  EmitLoadIntVal(Reg, SymbolRec1);
  SymbolRecR.ByRef := false;
  temp := SymbolRecR.TypeID;
  SymbolRecR.TypeID := TypePOINTER;
  EmitSaveIntVal(Reg, SymbolRecR);
  SymbolRecR.ByRef := true;
  SymbolRecR.TypeID := temp;

  FreeReg(Reg);
end;

procedure TEmitter.EmitOP_SET_INCLUDE;
var
  SubId, Reg: Integer;
begin
  EmitPCodeOperator;

  SubId := Id_SetInclude;

  Reg := GetReg;

  EmitLoadIntVal(Reg, SymbolRec2); // the second parameter
  Prg.AsmPush_REG(Reg);

  EmitLoadAddress(Reg, SymbolRec1); // the first parameter
  Prg.AsmPush_REG(Reg);

  EmitGet_REG(Reg, SymbolTable[SubId]);
  Prg.AsmCall_REG(Reg);

  FreeReg(Reg);
end;

procedure TEmitter.EmitOP_SET_INCLUDE_INTERVAL;
var
  SubId, Reg: Integer;
begin
  EmitPCodeOperator;

  SubId := Id_SetIncludeInterval;

  Reg := GetReg;

  EmitLoadIntVal(Reg, SymbolRecR); // the third parameter
  Prg.AsmPush_REG(Reg);

  EmitLoadIntVal(Reg, SymbolRec2); // the second parameter
  Prg.AsmPush_REG(Reg);

  EmitLoadAddress(Reg, SymbolRec1); // the first parameter
  Prg.AsmPush_REG(Reg);

  EmitGet_REG(Reg, SymbolTable[SubId]);
  Prg.AsmCall_REG(Reg);

  FreeReg(Reg);
end;

procedure TEmitter.EmitOP_SET_EXCLUDE;
var
  SubId, Reg: Integer;
begin
  EmitPCodeOperator;

  SubId := Id_SetExclude;

  Reg := GetReg;

  EmitLoadIntVal(Reg, SymbolRec2); // the second parameter
  Prg.AsmPush_REG(Reg);

  EmitLoadAddress(Reg, SymbolRec1); // the first parameter
  Prg.AsmPush_REG(Reg);

  EmitGet_REG(Reg, SymbolTable[SubId]);
  Prg.AsmCall_REG(Reg);

  FreeReg(Reg);
end;

procedure TEmitter.EmitOP_SET_UNION;
var
  SubId, Reg, T, SZ: Integer;
begin
  EmitPCodeOperator;

  SubId := Id_SetUnion;

  Reg := GetReg;

  T := SymbolRec2.TerminalTypeId;
  SZ := SymbolTable.GetSizeOfSetType(T);
  Prg.AsmPush_Imm(SZ);

  T := SymbolRec1.TerminalTypeId;
  SZ := SymbolTable.GetSizeOfSetType(T);
  Prg.AsmPush_Imm(SZ);

  EmitLoadAddress(Reg, SymbolRecR); // the third parameter
  Prg.AsmPush_REG(Reg);

  EmitLoadAddress(Reg, SymbolRec2); // the second parameter
  Prg.AsmPush_REG(Reg);

  EmitLoadAddress(Reg, SymbolRec1); // the first parameter
  Prg.AsmPush_REG(Reg);

  EmitGet_REG(Reg, SymbolTable[SubId]);
  Prg.AsmCall_REG(Reg);

  FreeReg(Reg);
end;

procedure TEmitter.EmitOP_SET_DIFFERENCE;
var
  SubId, Reg, T, SZ: Integer;
begin
  EmitPCodeOperator;

  SubId := Id_SetDifference;

  Reg := GetReg;

  T := SymbolRec2.TerminalTypeId;
  SZ := SymbolTable.GetSizeOfSetType(T);
  Prg.AsmPush_Imm(SZ);

  T := SymbolRec1.TerminalTypeId;
  SZ := SymbolTable.GetSizeOfSetType(T);
  Prg.AsmPush_Imm(SZ);

  EmitLoadAddress(Reg, SymbolRecR); // the third parameter
  Prg.AsmPush_REG(Reg);

  EmitLoadAddress(Reg, SymbolRec2); // the second parameter
  Prg.AsmPush_REG(Reg);

  EmitLoadAddress(Reg, SymbolRec1); // the first parameter
  Prg.AsmPush_REG(Reg);

  EmitGet_REG(Reg, SymbolTable[SubId]);
  Prg.AsmCall_REG(Reg);

  FreeReg(Reg);
end;

procedure TEmitter.EmitOP_SET_INTERSECTION;
var
  SubId, Reg, T, SZ: Integer;
begin
  EmitPCodeOperator;

  SubId := Id_SetIntersection;

  Reg := GetReg;

  T := SymbolRec2.TerminalTypeId;
  SZ := SymbolTable.GetSizeOfSetType(T);
  Prg.AsmPush_Imm(SZ);

  T := SymbolRec1.TerminalTypeId;
  SZ := SymbolTable.GetSizeOfSetType(T);
  Prg.AsmPush_Imm(SZ);

  EmitLoadAddress(Reg, SymbolRecR); // the third parameter
  Prg.AsmPush_REG(Reg);

  EmitLoadAddress(Reg, SymbolRec2); // the second parameter
  Prg.AsmPush_REG(Reg);

  EmitLoadAddress(Reg, SymbolRec1); // the first parameter
  Prg.AsmPush_REG(Reg);

  EmitGet_REG(Reg, SymbolTable[SubId]);
  Prg.AsmCall_REG(Reg);

  FreeReg(Reg);
end;

procedure TEmitter.EmitOP_SET_SUBSET;
var
  SubId, Reg, T, SZ: Integer;
begin
  EmitPCodeOperator;

  SubId := Id_SetSubset;

  GetReg(_EAX);
  Reg := _EAX;

  T := SymbolRec2.TerminalTypeId;
  SZ := SymbolTable.GetSizeOfSetType(T);
  Prg.AsmPush_Imm(SZ);

  T := SymbolRec1.TerminalTypeId;
  SZ := SymbolTable.GetSizeOfSetType(T);
  Prg.AsmPush_Imm(SZ);

  EmitLoadAddress(Reg, SymbolRec2); // the second parameter
  Prg.AsmPush_REG(Reg);

  EmitLoadAddress(Reg, SymbolRec1); // the first parameter
  Prg.AsmPush_REG(Reg);

  EmitGet_REG(Reg, SymbolTable[SubId]);
  Prg.AsmCall_REG(Reg);

  EmitPut_REG(_EAX, SymbolRecR);

  FreeReg(Reg);
end;

procedure TEmitter.EmitOP_SET_SUPERSET;
var
  SubId, Reg, T, SZ: Integer;
begin
  EmitPCodeOperator;

  SubId := Id_SetSuperset;

  GetReg(_EAX);
  Reg := _EAX;

  T := SymbolRec2.TerminalTypeId;
  SZ := SymbolTable.GetSizeOfSetType(T);
  Prg.AsmPush_Imm(SZ);

  T := SymbolRec1.TerminalTypeId;
  SZ := SymbolTable.GetSizeOfSetType(T);
  Prg.AsmPush_Imm(SZ);

  EmitLoadAddress(Reg, SymbolRec2); // the second parameter
  Prg.AsmPush_REG(Reg);

  EmitLoadAddress(Reg, SymbolRec1); // the first parameter
  Prg.AsmPush_REG(Reg);

  EmitGet_REG(Reg, SymbolTable[SubId]);
  Prg.AsmCall_REG(Reg);

  EmitPut_REG(_EAX, SymbolRecR);

  FreeReg(Reg);
end;

procedure TEmitter.EmitOP_SET_EQUALITY;
var
  SubId, Reg, T, SZ: Integer;
begin
  EmitPCodeOperator;

  SubId := Id_SetEquality;

  GetReg(_EAX);
  Reg := _EAX;

  T := SymbolRec2.TerminalTypeId;
  SZ := SymbolTable.GetSizeOfSetType(T);
  Prg.AsmPush_Imm(SZ);

  T := SymbolRec1.TerminalTypeId;
  SZ := SymbolTable.GetSizeOfSetType(T);
  Prg.AsmPush_Imm(SZ);

  EmitLoadAddress(Reg, SymbolRec2); // the second parameter
  Prg.AsmPush_REG(Reg);

  EmitLoadAddress(Reg, SymbolRec1); // the first parameter
  Prg.AsmPush_REG(Reg);

  EmitGet_REG(Reg, SymbolTable[SubId]);
  Prg.AsmCall_REG(Reg);

  EmitPut_REG(_EAX, SymbolRecR);

  FreeReg(Reg);
end;

procedure TEmitter.EmitOP_SET_INEQUALITY;
var
  SubId, Reg, T, SZ: Integer;
begin
  EmitPCodeOperator;

  SubId := Id_SetInequality;

  GetReg(_EAX);
  Reg := _EAX;

  T := SymbolRec2.TerminalTypeId;
  SZ := SymbolTable.GetSizeOfSetType(T);
  Prg.AsmPush_Imm(SZ);

  T := SymbolRec1.TerminalTypeId;
  SZ := SymbolTable.GetSizeOfSetType(T);
  Prg.AsmPush_Imm(SZ);

  EmitLoadAddress(Reg, SymbolRec2); // the second parameter
  Prg.AsmPush_REG(Reg);

  EmitLoadAddress(Reg, SymbolRec1); // the first parameter
  Prg.AsmPush_REG(Reg);

  EmitGet_REG(Reg, SymbolTable[SubId]);
  Prg.AsmCall_REG(Reg);

  EmitPut_REG(_EAX, SymbolRecR);

  FreeReg(Reg);
end;

procedure TEmitter.EmitOP_SET_MEMBERSHIP;
var
  SubId, Reg: Integer;
begin
  EmitPCodeOperator;

  SubId := Id_SetMembership;

  GetReg(_EAX);
  Reg := _EAX;

  EmitLoadAddress(Reg, SymbolRec2); // the second parameter
  Prg.AsmPush_REG(Reg);

  EmitLoadIntVal(Reg, SymbolRec1); // the first parameter
  Prg.AsmPush_REG(Reg);

  EmitGet_REG(Reg, SymbolTable[SubId]);
  Prg.AsmCall_REG(Reg);

  EmitPut_REG(_EAX, SymbolRecR);

  FreeReg(Reg);
end;

procedure TEmitter.EmitOP_SET_ASSIGN;
var
  Reg1, Reg2, TypeId, SetSize: Integer;
begin
  EmitPCodeOperator;

  GetReg(_ECX);
  Reg1 := GetReg;
  Reg2 := GetReg;

  TypeId := SymbolRec1.TerminalTypeId;
  SetSize := TKernel(kernel).SymbolTable.GetSizeOfSetType(TypeId);

  EmitLoadAddress(Reg1, SymbolRec1);
  EmitLoadAddress(Reg2, SymbolRec2);

  Prg.AsmPush_Reg(_ESI);
  Prg.AsmPush_Reg(_EDI);

  Prg.AsmMovREG_REG(_ESI, Reg2);
  Prg.AsmMovREG_REG(_EDI, Reg1);

  Prg.AsmMovREG_Imm(_ECX, SetSize);
  Prg.AsmRep_MOVSB;

  Prg.AsmPop_Reg(_EDI);
  Prg.AsmPop_Reg(_ESI);

  FreeReg(Reg2);
  FreeReg(Reg1);
  FreeReg(_ECX);
end;

procedure TEmitter.EmitOP_CREATE_METHOD;
var
  SubId, Reg: Integer;
begin
  EmitPCodeOperator;

  SubId := Id_CreateMethod;

  Reg := GetReg;

  EmitLoadAddress(Reg, SymbolRecR); // result
  Prg.AsmPush_REG(Reg);

  EmitLoadIntVal(Reg, SymbolRec2); // code
  Prg.AsmPush_REG(Reg);

  EmitLoadIntVal(Reg, SymbolRec1); // data
  Prg.AsmPush_REG(Reg);

  EmitGet_REG(Reg, SymbolTable[SubId]);
  Prg.AsmCall_REG(Reg);

  FreeReg(Reg);
end;

procedure TEmitter.EmitOP_TO_JS_OBJECT;
var
  SubId, Reg, FinTypeId: Integer;
begin
  EmitPCodeOperator;
  Emit_PUSH_REGS;

  SubId := JS_ToObjectId;

  GetReg(_EBX);
  Reg := _EBX;

  EmitLoadAddress(Reg, SymbolRecR); // result
  Prg.AsmPush_REG(Reg);

  if (SymbolRec1.Kind = kindCONST) and
     (SymbolRec1.FinalTypeId in IntegerTypes) then
  begin
{
    Id := SymbolRec1.Value;
    Id := TKernel(kernel).SymbolTable.AddInt64Const(Id).Id;

    Prg.AsmPush_Imm(typeINT64);
    EmitLoadAddress(Reg, GetSymbolRec(Id)); // source
}
    RaiseError(errInternalError, []);
  end
  else
  begin
    FinTypeId := GetSymbolRec(R.Arg1).FinalTypeId;
    Prg.AsmPush_Imm(FinTypeId);

    EmitLoadAddress(Reg, SymbolRec1); // source
  end;

  Prg.AsmPush_REG(Reg);

  Prg.AsmMovREG_REG(Reg, _ESI);
  Prg.AsmAddREG_Imm(Reg, H_SelfPtr);
  Prg.AsmMovREG32_REGPtr(Reg, Reg); // load TProgram.Self
  Prg.AsmPush_REG(Reg);

  EmitGet_REG(Reg, SymbolTable[SubId]);
  Prg.AsmCall_REG(Reg);

  FreeReg(Reg);

  Emit_POP_REGS;
end;

procedure TEmitter.EmitOP_GET_NEXTJSPROP;
var
  SubId, Reg: Integer;
begin
  EmitPCodeOperator;

  SubId := JS_GetNextPropId;

  Reg := GetReg;

  EmitLoadAddress(Reg, SymbolRecR); // result
  Prg.AsmPush_REG(Reg);

  EmitLoadAddress(Reg, SymbolRec2); // 2nd arg
  Prg.AsmPush_REG(Reg);

  EmitLoadAddress(Reg, SymbolRec1); // 1st arg - object
  Prg.AsmPush_REG(Reg);

  EmitGet_REG(Reg, SymbolTable[SubId]);
  Prg.AsmCall_REG(Reg);

  FreeReg(Reg);
end;

procedure TEmitter.EmitOP_CLEAR_REFERENCES;
var
  SubId, Reg: Integer;
begin
  EmitPCodeOperator;

  SubId := JS_ClearReferencesId;

  Reg := GetReg;

  Prg.AsmMovREG_REG(Reg, _ESI);
  Prg.AsmAddREG_Imm(Reg, H_SelfPtr);
  Prg.AsmMovREG32_REGPtr(Reg, Reg); // load TProgram.Self
  Prg.AsmPush_REG(Reg);             // push TProgram.Self

  EmitGet_REG(Reg, SymbolTable[SubId]);
  Prg.AsmCall_REG(Reg);

  FreeReg(Reg);
end;

procedure TEmitter.EmitOP_JS_TYPEOF;
var
  SubId, Reg: Integer;
begin
  EmitPCodeOperator;

  SubId := JS_TypeOfId;

  Reg := GetReg;

  EmitLoadAddress(Reg, SymbolRecR); // result
  Prg.AsmPush_REG(Reg);

  EmitLoadAddress(Reg, SymbolRec1); // 1st arg - object
  Prg.AsmPush_REG(Reg);

  EmitGet_REG(Reg, SymbolTable[SubId]);
  Prg.AsmCall_REG(Reg);

  FreeReg(Reg);
end;

procedure TEmitter.EmitOP_JS_VOID;
var
  SubId, Reg: Integer;
begin
  EmitPCodeOperator;

  SubId := JS_VoidId;

  Reg := GetReg;

  EmitLoadAddress(Reg, SymbolRecR); // result
  Prg.AsmPush_REG(Reg);

  EmitLoadAddress(Reg, SymbolRec1); // 1st arg - object
  Prg.AsmPush_REG(Reg);

  EmitGet_REG(Reg, SymbolTable[SubId]);
  Prg.AsmCall_REG(Reg);

  FreeReg(Reg);
end;

procedure TEmitter.EmitOP_SHORTSTRING_FROM_PANSICHAR_LITERAL;
var
  T1, L, L1, L2: Integer;
begin
  EmitPCodeOperator;
  Emit_PUSH_REGS;

  T1 := SymbolRec1.TypeID;
  L1 := GetSymbolRec(T1).Count;
  if T1 = typeSHORTSTRING then
    L1 := 255;
  L2 := Length(SymbolRec2.Value);

  if L2 < L1 then
    L := L2
  else
    L := L1;

  GetReg(_EAX);
  GetReg(_EDX);
  GetReg(_ECX);

  Prg.AsmMovREG_Imm(_ECX, L);
  EmitLoadAddress(_EAX, SymbolRec1); // string dest
  Prg.AsmMovREGPtr_REG8(_EAX, _ECX); // s[0] := length
  EmitGet_REG(_EDX, SymbolRec2); // pchar source

  Prg.AsmPush_REG(_ESI);
  Prg.AsmPush_REG(_EDI);

  Prg.AsmMovREG_REG(_ESI, _EDX);
  Prg.AsmAddREG_Imm(_EAX, 1);
  Prg.AsmMovREG_REG(_EDI, _EAX);
  Prg.AsmRep_MOVSB;

  Prg.AsmPop_REG(_EDI);
  Prg.AsmPop_REG(_ESI);

  FreeReg(_EAX);
  FreeReg(_EDX);
  FreeReg(_ECX);

  Emit_POP_REGS;
end;

procedure TEmitter.EmitOP_SHORTSTRING_FROM_PWIDECHAR_LITERAL;
var
  T1, L1, SubId, Reg: Integer;
begin
  SubId := Id_ShortStringFromPWideChar;

  EmitPCodeOperator;
  Emit_PUSH_REGS;

  T1 := SymbolRec1.TypeID;
  L1 := GetSymbolRec(T1).Count;
  if T1 = typeSHORTSTRING then
    L1 := 255;

  Reg := GetReg;
  EmitGet_REG(Reg, SymbolRec2); // pwidechar source
  Prg.AsmPush_REG(Reg);
  Prg.AsmPush_Imm(L1);
  EmitLoadAddress(Reg, SymbolRec1); // string dest
  Prg.AsmPush_REG(Reg);

  EmitGet_REG(Reg, SymbolTable[SubId]);
  Prg.AsmCall_REG(Reg);

  FreeReg(Reg);
  Emit_POP_REGS;
end;

procedure TEmitter.EmitOP_WIDESTRING_FROM_PANSICHAR_LITERAL;
var
  SubId, Reg: Integer;
begin
  EmitPCodeOperator;
  Emit_PUSH_REGS;

  SubId := Id_WideStringFromPAnsiChar;

  GetReg(_EBX);
  Reg := _EBX;

  EmitLoadAddress(Reg, SymbolRec1); // string dest
  Prg.AsmPush_REG(Reg);

  EmitGet_REG(Reg, SymbolRec2); // pchar source
  Prg.AsmPush_REG(Reg);

  EmitGet_REG(Reg, SymbolTable[SubId]);

  Prg.AsmCall_REG(Reg);
  FreeReg(Reg);

  Emit_POP_REGS;
end;

procedure TEmitter.EmitOP_UNICSTRING_FROM_PANSICHAR_LITERAL;
var
  SubId, Reg: Integer;
begin
  EmitPCodeOperator;
  Emit_PUSH_REGS;

  SubId := Id_UnicStringFromPAnsiChar;

  GetReg(_EBX);
  Reg := _EBX;

  EmitLoadAddress(Reg, SymbolRec1); // string dest
  Prg.AsmPush_REG(Reg);

  EmitGet_REG(Reg, SymbolRec2); // pchar source
  Prg.AsmPush_REG(Reg);

  EmitGet_REG(Reg, SymbolTable[SubId]);

  Prg.AsmCall_REG(Reg);
  FreeReg(Reg);

  Emit_POP_REGS;
end;

procedure TEmitter.EmitOP_WIDESTRING_FROM_PWIDECHAR_LITERAL;
var
  SubId, Reg: Integer;
begin
  EmitPCodeOperator;
  Emit_PUSH_REGS;

  SubId := Id_WideStringFromPWideChar;

  GetReg(_EBX);
  Reg := _EBX;

  EmitLoadAddress(Reg, SymbolRec1); // string dest
  Prg.AsmPush_REG(Reg);

  EmitGet_REG(Reg, SymbolRec2); // pchar source
  Prg.AsmPush_REG(Reg);

  EmitGet_REG(Reg, SymbolTable[SubId]);

  Prg.AsmCall_REG(Reg);
  FreeReg(Reg);

  Emit_POP_REGS;
end;

procedure TEmitter.EmitOP_UNICSTRING_FROM_PWIDECHAR_LITERAL;
var
  SubId, Reg: Integer;
begin
  EmitPCodeOperator;
  Emit_PUSH_REGS;

  SubId := Id_UnicStringFromPWideChar;

  GetReg(_EBX);
  Reg := _EBX;

  EmitLoadAddress(Reg, SymbolRec1); // string dest
  Prg.AsmPush_REG(Reg);

  EmitGet_REG(Reg, SymbolRec2); // pchar source
  Prg.AsmPush_REG(Reg);

  EmitGet_REG(Reg, SymbolTable[SubId]);

  Prg.AsmCall_REG(Reg);
  FreeReg(Reg);

  Emit_POP_REGS;
end;

procedure TEmitter.EmitOP_VARIANT_FROM_PANSICHAR_LITERAL;
var
  SubId, Reg: Integer;
begin
  EmitPCodeOperator;
  Emit_PUSH_REGS;

  SubId := Id_VariantFromPAnsiChar;

  GetReg(_EBX);
  Reg := _EBX;

  EmitLoadAddress(Reg, SymbolRec1); // variant dest
  Prg.AsmPush_REG(Reg);

  EmitGet_REG(Reg, SymbolRec2); // pchar source
  Prg.AsmPush_REG(Reg);

  EmitGet_REG(Reg, SymbolTable[SubId]);

  Prg.AsmCall_REG(Reg);
  FreeReg(Reg);

  Emit_POP_REGS;
end;

procedure TEmitter.EmitOP_VARIANT_FROM_PWIDECHAR_LITERAL;
var
  SubId, Reg: Integer;
begin
  EmitPCodeOperator;
  Emit_PUSH_REGS;

  SubId := Id_VariantFromPWideChar;

  GetReg(_EBX);
  Reg := _EBX;

  EmitLoadAddress(Reg, SymbolRec1); // variant dest
  Prg.AsmPush_REG(Reg);

  EmitGet_REG(Reg, SymbolRec2); // pchar source
  Prg.AsmPush_REG(Reg);

  EmitGet_REG(Reg, SymbolTable[SubId]);

  Prg.AsmCall_REG(Reg);
  FreeReg(Reg);

  Emit_POP_REGS;
end;

procedure TEmitter.EmitOP_OLEVARIANT_FROM_PANSICHAR_LITERAL;
var
  SubId, Reg: Integer;
begin
  EmitPCodeOperator;
  Emit_PUSH_REGS;

  SubId := Id_OleVariantFromPAnsiChar;

  GetReg(_EBX);
  Reg := _EBX;

  EmitLoadAddress(Reg, SymbolRec1); // variant dest
  Prg.AsmPush_REG(Reg);

  EmitGet_REG(Reg, SymbolRec2); // pchar source
  Prg.AsmPush_REG(Reg);

  EmitGet_REG(Reg, SymbolTable[SubId]);

  Prg.AsmCall_REG(Reg);
  FreeReg(Reg);

  Emit_POP_REGS;
end;

procedure TEmitter.EmitOP_OLEVARIANT_FROM_PWIDECHAR_LITERAL;
var
  SubId, Reg: Integer;
begin
  EmitPCodeOperator;
  Emit_PUSH_REGS;

  SubId := Id_OleVariantFromPWideChar;

  GetReg(_EBX);
  Reg := _EBX;

  EmitLoadAddress(Reg, SymbolRec1); // variant dest
  Prg.AsmPush_REG(Reg);

  EmitGet_REG(Reg, SymbolRec2); // pchar source
  Prg.AsmPush_REG(Reg);

  EmitGet_REG(Reg, SymbolTable[SubId]);

  Prg.AsmCall_REG(Reg);
  FreeReg(Reg);

  Emit_POP_REGS;
end;

procedure TEmitter.EmitOP_SHORTSTRING_FROM_ANSISTRING;
var
  T1, L1, SubId, Reg: Integer;
begin
  SubId := Id_ShortStringFromAnsiString;

  EmitPCodeOperator;
  Emit_PUSH_REGS;

  T1 := SymbolRec1.TypeID;
  L1 := GetSymbolRec(T1).Count;
  if T1 = typeSHORTSTRING then
    L1 := 255;

  Reg := GetReg;
  EmitLoadAddress(Reg, SymbolRec2); // string source
  Prg.AsmPush_REG(Reg);
  Prg.AsmPush_Imm(L1);
  EmitLoadAddress(Reg, SymbolRec1); // string dest
  Prg.AsmPush_REG(Reg);

  EmitGet_REG(Reg, SymbolTable[SubId]);
  Prg.AsmCall_REG(Reg);

  FreeReg(Reg);
  Emit_POP_REGS;
end;

procedure TEmitter.EmitOP_SHORTSTRING_FROM_WIDESTRING;
var
  T1, L1, SubId, Reg: Integer;
begin
  SubId := Id_ShortStringFromWideString;

  EmitPCodeOperator;
  Emit_PUSH_REGS;

  T1 := SymbolRec1.TypeID;
  L1 := GetSymbolRec(T1).Count;
  if T1 = typeSHORTSTRING then
    L1 := 255;

  Reg := GetReg;
  EmitLoadAddress(Reg, SymbolRec2); // string source
  Prg.AsmPush_REG(Reg);
  Prg.AsmPush_Imm(L1);
  EmitLoadAddress(Reg, SymbolRec1); // string dest
  Prg.AsmPush_REG(Reg);

  EmitGet_REG(Reg, SymbolTable[SubId]);
  Prg.AsmCall_REG(Reg);

  FreeReg(Reg);
  Emit_POP_REGS;
end;

procedure TEmitter.EmitOP_SHORTSTRING_FROM_UNICSTRING;
var
  T1, L1, SubId, Reg: Integer;
begin
  SubId := Id_ShortStringFromUnicString;

  EmitPCodeOperator;
  Emit_PUSH_REGS;

  T1 := SymbolRec1.TypeID;
  L1 := GetSymbolRec(T1).Count;
  if T1 = typeSHORTSTRING then
    L1 := 255;

  Reg := GetReg;
  EmitLoadAddress(Reg, SymbolRec2); // string source
  Prg.AsmPush_REG(Reg);
  Prg.AsmPush_Imm(L1);
  EmitLoadAddress(Reg, SymbolRec1); // string dest
  Prg.AsmPush_REG(Reg);

  EmitGet_REG(Reg, SymbolTable[SubId]);
  Prg.AsmCall_REG(Reg);

  FreeReg(Reg);
  Emit_POP_REGS;
end;

procedure TEmitter.EmitOP_ANSISTRING_FROM_SHORTSTRING;
var
  SubId, Reg: Integer;
begin
  SubId := Id_AnsiStringFromShortString;

  EmitPCodeOperator;
  Emit_PUSH_REGS;

  Reg := GetReg;
  EmitLoadAddress(Reg, SymbolRec2); // string source
  Prg.AsmPush_REG(Reg);
  EmitLoadAddress(Reg, SymbolRec1); // string dest
  Prg.AsmPush_REG(Reg);

  EmitGet_REG(Reg, SymbolTable[SubId]);
  Prg.AsmCall_REG(Reg);

  FreeReg(Reg);
  Emit_POP_REGS;
end;

procedure TEmitter.EmitOP_UNICSTRING_FROM_WIDESTRING;
var
  SubId, Reg: Integer;
begin
  SubId := Id_UnicStringFromWideString;

  EmitPCodeOperator;
  Emit_PUSH_REGS;

  Reg := GetReg;
  EmitLoadAddress(Reg, SymbolRec2); // string source
  Prg.AsmPush_REG(Reg);
  EmitLoadAddress(Reg, SymbolRec1); // string dest
  Prg.AsmPush_REG(Reg);

  EmitGet_REG(Reg, SymbolTable[SubId]);
  Prg.AsmCall_REG(Reg);

  FreeReg(Reg);
  Emit_POP_REGS;
end;

procedure TEmitter.EmitOP_WIDESTRING_FROM_SHORTSTRING;
var
  SubId, Reg: Integer;
begin
  SubId := Id_WideStringFromShortString;

  EmitPCodeOperator;
  Emit_PUSH_REGS;

  Reg := GetReg;
  EmitLoadAddress(Reg, SymbolRec2); // string source
  Prg.AsmPush_REG(Reg);
  EmitLoadAddress(Reg, SymbolRec1); // string dest
  Prg.AsmPush_REG(Reg);

  EmitGet_REG(Reg, SymbolTable[SubId]);
  Prg.AsmCall_REG(Reg);

  FreeReg(Reg);
  Emit_POP_REGS;
end;

procedure TEmitter.EmitOP_WIDESTRING_FROM_UNICSTRING;
var
  SubId, Reg: Integer;
begin
  SubId := Id_WideStringFromUnicString;

  EmitPCodeOperator;
  Emit_PUSH_REGS;

  Reg := GetReg;
  EmitLoadAddress(Reg, SymbolRec2); // string source
  Prg.AsmPush_REG(Reg);
  EmitLoadAddress(Reg, SymbolRec1); // string dest
  Prg.AsmPush_REG(Reg);

  EmitGet_REG(Reg, SymbolTable[SubId]);
  Prg.AsmCall_REG(Reg);

  FreeReg(Reg);
  Emit_POP_REGS;
end;

procedure TEmitter.EmitOP_UNICSTRING_FROM_SHORTSTRING;
var
  SubId, Reg: Integer;
begin
  SubId := Id_UnicStringFromShortString;

  EmitPCodeOperator;
  Emit_PUSH_REGS;

  Reg := GetReg;
  EmitLoadAddress(Reg, SymbolRec2); // string source
  Prg.AsmPush_REG(Reg);
  EmitLoadAddress(Reg, SymbolRec1); // string dest
  Prg.AsmPush_REG(Reg);

  EmitGet_REG(Reg, SymbolTable[SubId]);
  Prg.AsmCall_REG(Reg);

  FreeReg(Reg);
  Emit_POP_REGS;
end;

procedure TEmitter.EmitOP_ANSISTRING_FROM_WIDESTRING;
var
  SubId, Reg: Integer;
begin
  SubId := Id_AnsiStringFromWideString;

  EmitPCodeOperator;
  Emit_PUSH_REGS;

  Reg := GetReg;
  EmitLoadAddress(Reg, SymbolRec2); // string source
  Prg.AsmPush_REG(Reg);
  EmitLoadAddress(Reg, SymbolRec1); // string dest
  Prg.AsmPush_REG(Reg);

  EmitGet_REG(Reg, SymbolTable[SubId]);
  Prg.AsmCall_REG(Reg);

  FreeReg(Reg);
  Emit_POP_REGS;
end;

procedure TEmitter.EmitOP_ANSISTRING_FROM_UNICSTRING;
var
  SubId, Reg: Integer;
begin
  SubId := Id_AnsiStringFromUnicString;

  EmitPCodeOperator;
  Emit_PUSH_REGS;

  Reg := GetReg;
  EmitLoadAddress(Reg, SymbolRec2); // string source
  Prg.AsmPush_REG(Reg);
  EmitLoadAddress(Reg, SymbolRec1); // string dest
  Prg.AsmPush_REG(Reg);

  EmitGet_REG(Reg, SymbolTable[SubId]);
  Prg.AsmCall_REG(Reg);

  FreeReg(Reg);
  Emit_POP_REGS;
end;

procedure TEmitter.EmitOP_WIDESTRING_FROM_ANSISTRING;
var
  SubId, Reg: Integer;
begin
  SubId := Id_WideStringFromAnsiString;

  EmitPCodeOperator;
  Emit_PUSH_REGS;

  Reg := GetReg;
  EmitLoadAddress(Reg, SymbolRec2); // string source
  Prg.AsmPush_REG(Reg);
  EmitLoadAddress(Reg, SymbolRec1); // string dest
  Prg.AsmPush_REG(Reg);

  EmitGet_REG(Reg, SymbolTable[SubId]);
  Prg.AsmCall_REG(Reg);

  FreeReg(Reg);
  Emit_POP_REGS;
end;

procedure TEmitter.EmitOP_UNICSTRING_FROM_ANSISTRING;
var
  SubId, Reg: Integer;
begin
  SubId := Id_UnicStringFromAnsiString;

  EmitPCodeOperator;
  Emit_PUSH_REGS;

  Reg := GetReg;
  EmitLoadAddress(Reg, SymbolRec2); // string source
  Prg.AsmPush_REG(Reg);
  EmitLoadAddress(Reg, SymbolRec1); // string dest
  Prg.AsmPush_REG(Reg);

  EmitGet_REG(Reg, SymbolTable[SubId]);
  Prg.AsmCall_REG(Reg);

  FreeReg(Reg);
  Emit_POP_REGS;
end;

procedure TEmitter.EmitOP_INTERFACE_CAST;
var
  SubId, Reg: Integer;
  GuidId: Integer;
begin
  SubId := Id_InterfaceCast;

  GuidId := SymbolRec2.TerminalTypeId + 1;

  EmitPCodeOperator;

  Reg := GetReg;

  EmitLoadAddress(Reg, SymbolRec1); // interface source
  Prg.AsmPush_REG(Reg);

  EmitLoadAddress(Reg, GetSymbolRec(GuidId));
  Prg.AsmPush_REG(Reg);

  EmitLoadAddress(Reg, SymbolRecR); // interface dest
  Prg.AsmPush_REG(Reg);

  EmitGet_REG(Reg, SymbolTable[SubId]);
  Prg.AsmCall_REG(Reg);

  FreeReg(Reg);
end;

procedure TEmitter.EmitOP_INTERFACE_FROM_CLASS;
var
  SubId, Reg: Integer;
  GuidId: Integer;
begin
  SubId := Id_InterfaceFromClass;

  GuidId := SymbolRec1.TerminalTypeId + 1;

  EmitPCodeOperator;

  Reg := GetReg;

  EmitLoadAddress(Reg, SymbolRec2); // object
  Prg.AsmPush_REG(Reg);

  EmitLoadAddress(Reg, GetSymbolRec(GuidId));
  Prg.AsmPush_REG(Reg);

  EmitLoadAddress(Reg, SymbolRec1); // interface dest
  Prg.AsmPush_REG(Reg);

  EmitGet_REG(Reg, SymbolTable[SubId]);
  Prg.AsmCall_REG(Reg);

  FreeReg(Reg);
end;

procedure TEmitter.EmitOP_ASSIGN_INTERFACE;
var
  SubId, Reg: Integer;
begin
  SubId := Id_InterfaceAssign;

  EmitPCodeOperator;

  Reg := GetReg;

  EmitLoadAddress(Reg, SymbolRec2); // source
  Prg.AsmPush_REG(Reg);

  EmitLoadAddress(Reg, SymbolRec1); // dest
  Prg.AsmPush_REG(Reg);

  EmitGet_REG(Reg, SymbolTable[SubId]);
  Prg.AsmCall_REG(Reg);

  FreeReg(Reg);
end;

procedure TEmitter.EmitOP_VARIANT_FROM_CLASS;
var
  SubId, Reg: Integer;
begin
  SubId := Id_VariantFromClass;

  EmitPCodeOperator;
  Emit_PUSH_REGS;

  Reg := GetReg;
  EmitLoadAddress(Reg, SymbolRec2); // object
  Prg.AsmPush_REG(Reg);
  EmitLoadAddress(Reg, SymbolRec1); // string dest
  Prg.AsmPush_REG(Reg);

  EmitGet_REG(Reg, SymbolTable[SubId]);
  Prg.AsmCall_REG(Reg);

  FreeReg(Reg);
  Emit_POP_REGS;
end;

procedure TEmitter.EmitOP_CLASS_FROM_VARIANT;
var
  SubId, Reg: Integer;
begin
  SubId := Id_ClassFromVariant;

  EmitPCodeOperator;
  Emit_PUSH_REGS;

  Reg := GetReg;
  EmitLoadAddress(Reg, SymbolRec2);
  Prg.AsmPush_REG(Reg);
  EmitLoadAddress(Reg, SymbolRec1);
  Prg.AsmPush_REG(Reg);

  EmitGet_REG(Reg, SymbolTable[SubId]);
  Prg.AsmCall_REG(Reg);

  FreeReg(Reg);
  Emit_POP_REGS;
end;

procedure TEmitter.EmitOP_VARIANT_FROM_POINTER;
var
  SubId, Reg: Integer;
begin
  SubId := Id_VariantFromPointer;

  EmitPCodeOperator;
  Emit_PUSH_REGS;

  Reg := GetReg;
  EmitLoadAddress(Reg, SymbolRec2); // object
  Prg.AsmPush_REG(Reg);
  EmitLoadAddress(Reg, SymbolRec1); // string dest
  Prg.AsmPush_REG(Reg);

  EmitGet_REG(Reg, SymbolTable[SubId]);
  Prg.AsmCall_REG(Reg);

  FreeReg(Reg);
  Emit_POP_REGS;
end;

procedure TEmitter.EmitOP_VARIANT_FROM_ANSISTRING;
var
  SubId, Reg: Integer;
begin
  SubId := Id_VariantFromAnsiString;

  EmitPCodeOperator;
  Emit_PUSH_REGS;

  Reg := GetReg;
  EmitLoadAddress(Reg, SymbolRec2); // string source
  Prg.AsmPush_REG(Reg);
  EmitLoadAddress(Reg, SymbolRec1); // string dest
  Prg.AsmPush_REG(Reg);

  EmitGet_REG(Reg, SymbolTable[SubId]);
  Prg.AsmCall_REG(Reg);

  FreeReg(Reg);
  Emit_POP_REGS;
end;

procedure TEmitter.EmitOP_OLEVARIANT_FROM_ANSISTRING;
var
  SubId, Reg: Integer;
begin
  SubId := Id_OleVariantFromAnsiString;

  EmitPCodeOperator;
  Emit_PUSH_REGS;

  Reg := GetReg;
  EmitLoadAddress(Reg, SymbolRec2); // string source
  Prg.AsmPush_REG(Reg);
  EmitLoadAddress(Reg, SymbolRec1); // string dest
  Prg.AsmPush_REG(Reg);

  EmitGet_REG(Reg, SymbolTable[SubId]);
  Prg.AsmCall_REG(Reg);

  FreeReg(Reg);
  Emit_POP_REGS;
end;

procedure TEmitter.EmitOP_OLEVARIANT_FROM_VARIANT;
var
  SubId, Reg: Integer;
begin
  SubId := Id_OleVariantFromVariant;

  EmitPCodeOperator;
  Emit_PUSH_REGS;

  Reg := GetReg;
  EmitLoadAddress(Reg, SymbolRec2); // string source
  Prg.AsmPush_REG(Reg);
  EmitLoadAddress(Reg, SymbolRec1); // string dest
  Prg.AsmPush_REG(Reg);

  EmitGet_REG(Reg, SymbolTable[SubId]);
  Prg.AsmCall_REG(Reg);

  FreeReg(Reg);
  Emit_POP_REGS;
end;

procedure TEmitter.EmitOP_VARIANT_FROM_WIDESTRING;
var
  SubId, Reg: Integer;
begin
  SubId := Id_VariantFromWideString;

  EmitPCodeOperator;
  Emit_PUSH_REGS;

  Reg := GetReg;
  EmitLoadAddress(Reg, SymbolRec2); // string source
  Prg.AsmPush_REG(Reg);
  EmitLoadAddress(Reg, SymbolRec1); // string dest
  Prg.AsmPush_REG(Reg);

  EmitGet_REG(Reg, SymbolTable[SubId]);
  Prg.AsmCall_REG(Reg);

  FreeReg(Reg);
  Emit_POP_REGS;
end;

procedure TEmitter.EmitOP_VARIANT_FROM_UNICSTRING;
var
  SubId, Reg: Integer;
begin
  SubId := Id_VariantFromUnicString;

  EmitPCodeOperator;
  Emit_PUSH_REGS;

  Reg := GetReg;
  EmitLoadAddress(Reg, SymbolRec2); // string source
  Prg.AsmPush_REG(Reg);
  EmitLoadAddress(Reg, SymbolRec1); // string dest
  Prg.AsmPush_REG(Reg);

  EmitGet_REG(Reg, SymbolTable[SubId]);
  Prg.AsmCall_REG(Reg);

  FreeReg(Reg);
  Emit_POP_REGS;
end;

procedure TEmitter.EmitOP_OLEVARIANT_FROM_WIDESTRING;
var
  SubId, Reg: Integer;
begin
  SubId := Id_OleVariantFromWideString;

  EmitPCodeOperator;
  Emit_PUSH_REGS;

  Reg := GetReg;
  EmitLoadAddress(Reg, SymbolRec2); // string source
  Prg.AsmPush_REG(Reg);
  EmitLoadAddress(Reg, SymbolRec1); // string dest
  Prg.AsmPush_REG(Reg);

  EmitGet_REG(Reg, SymbolTable[SubId]);
  Prg.AsmCall_REG(Reg);

  FreeReg(Reg);
  Emit_POP_REGS;
end;

procedure TEmitter.EmitOP_OLEVARIANT_FROM_UNICSTRING;
var
  SubId, Reg: Integer;
begin
  SubId := Id_OleVariantFromUnicString;

  EmitPCodeOperator;
  Emit_PUSH_REGS;

  Reg := GetReg;
  EmitLoadAddress(Reg, SymbolRec2); // string source
  Prg.AsmPush_REG(Reg);
  EmitLoadAddress(Reg, SymbolRec1); // string dest
  Prg.AsmPush_REG(Reg);

  EmitGet_REG(Reg, SymbolTable[SubId]);
  Prg.AsmCall_REG(Reg);

  FreeReg(Reg);
  Emit_POP_REGS;
end;

procedure TEmitter.EmitOP_VARIANT_FROM_SHORTSTRING;
var
  SubId, Reg: Integer;
begin
  SubId := Id_VariantFromShortString;

  EmitPCodeOperator;
  Emit_PUSH_REGS;

  Reg := GetReg;
  EmitLoadAddress(Reg, SymbolRec2); // string source
  Prg.AsmPush_REG(Reg);
  EmitLoadAddress(Reg, SymbolRec1); // string dest
  Prg.AsmPush_REG(Reg);

  EmitGet_REG(Reg, SymbolTable[SubId]);
  Prg.AsmCall_REG(Reg);

  FreeReg(Reg);
  Emit_POP_REGS;
end;

procedure TEmitter.EmitOP_OLEVARIANT_FROM_SHORTSTRING;
var
  SubId, Reg: Integer;
begin
  SubId := Id_OleVariantFromShortString;

  EmitPCodeOperator;
  Emit_PUSH_REGS;

  Reg := GetReg;
  EmitLoadAddress(Reg, SymbolRec2); // string source
  Prg.AsmPush_REG(Reg);
  EmitLoadAddress(Reg, SymbolRec1); // string dest
  Prg.AsmPush_REG(Reg);

  EmitGet_REG(Reg, SymbolTable[SubId]);
  Prg.AsmCall_REG(Reg);

  FreeReg(Reg);
  Emit_POP_REGS;
end;

procedure TEmitter.EmitOP_SHORTSTRING_FROM_ANSICHAR;
var
  Reg1, Reg2: Integer;
begin
  EmitPCodeOperator;

  Reg1 := GetReg;
  Reg2 := GetReg;

  Prg.AsmMovREG_Imm(Reg2, 1);
  EmitLoadAddress(Reg1, SymbolRec1); // string dest
  Prg.AsmMovREGPtr_REG8(Reg1, Reg2); // s[0] := length
  EmitGet_REG(Reg2, SymbolRec2); // char

  Prg.AsmAddREG_Imm(Reg1, 1);
  Prg.AsmMovREGPtr_REG8(Reg1, Reg2);

  FreeReg(Reg1);
  FreeReg(Reg2);
end;

procedure TEmitter.EmitOP_SHORTSTRING_FROM_WIDECHAR;
var
  Reg1, Reg2: Integer;
begin
  EmitPCodeOperator;

  Reg1 := GetReg;
  Reg2 := GetReg;

  Prg.AsmMovREG_Imm(Reg2, 1);
  EmitLoadAddress(Reg1, SymbolRec1); // string dest
  Prg.AsmMovREGPtr_REG8(Reg1, Reg2); // s[0] := length
  EmitGet_REG(Reg2, SymbolRec2); // char

  Prg.AsmAddREG_Imm(Reg1, 1);
  Prg.AsmMovREGPtr_REG8(Reg1, Reg2);

  FreeReg(Reg1);
  FreeReg(Reg2);
end;

procedure TEmitter.EmitOP_BEGIN_CRT_JS_FUNC_OBJECT;
begin
  EmitPCodeOperator;
end;

procedure TEmitter.EmitOP_END_CRT_JS_FUNC_OBJECT;
begin
  EmitPCodeOperator;
end;

procedure TEmitter.EmitOP_LOAD_PROC;
var
  SubId, Reg, SubShift, OverCount: Integer;
begin
  EmitPCodeOperator;

  Emit_PUSH_REGS;

  SubId := Id_LoadProc;

  SymbolRec1.Host := true;

  SubShift := GetOffset(SymbolRec1);
  OverCount := SymbolRec1.OverCount;

  GetReg(_EBX);
  Reg := _EBX;

  Prg.AsmPush_Imm(OverCount);

  EmitGet_REG(Reg, SymbolRecR); // dll name (pchar const)
  Prg.AsmPush_REG(Reg);

  EmitGet_REG(Reg, SymbolRec2); // proc name (pchar const)
  Prg.AsmPush_REG(Reg);

  Prg.AsmPush_Imm(SubShift);

  Prg.AsmMovREG_REG(Reg, _ESI);
  Prg.AsmAddREG_Imm(Reg, H_SelfPtr);
  Prg.AsmMovREG32_REGPtr(Reg, Reg); // load TProgram.Self
  Prg.AsmPush_REG(Reg);

  EmitGet_REG(Reg, SymbolTable[SubId]);
  Prg.AsmCall_REG(Reg);
  FreeReg(Reg);

  Emit_POP_REGS;
end;

procedure TEmitter.EmitOP_ANSISTRING_FROM_PANSICHAR;
var
  SubId, Reg: Integer;
begin
  EmitPCodeOperator;
  Emit_PUSH_REGS;

  SubId := Id_AnsiStringFromPAnsiChar;

  GetReg(_EBX);
  Reg := _EBX;

  EmitLoadAddress(Reg, SymbolRec1); // string dest
  Prg.AsmPush_REG(Reg);

  EmitGet_REG(Reg, SymbolRec2); // pchar source
  Prg.AsmPush_REG(Reg);

  EmitGet_REG(Reg, SymbolTable[SubId]);

  Prg.AsmCall_REG(Reg);
  FreeReg(Reg);

  Emit_POP_REGS;
end;

procedure TEmitter.EmitOP_ANSISTRING_FROM_PWIDECHAR;
var
  SubId, Reg: Integer;
begin
  EmitPCodeOperator;
  Emit_PUSH_REGS;

  SubId := Id_AnsiStringFromPWideChar;

  GetReg(_EBX);
  Reg := _EBX;

  EmitLoadAddress(Reg, SymbolRec1); // string dest
  Prg.AsmPush_REG(Reg);

  EmitGet_REG(Reg, SymbolRec2); // pchar source
  Prg.AsmPush_REG(Reg);

  EmitGet_REG(Reg, SymbolTable[SubId]);

  Prg.AsmCall_REG(Reg);
  FreeReg(Reg);

  Emit_POP_REGS;
end;

procedure TEmitter.EmitOP_ERR_ABSTRACT;
var
  SubId, Reg: Integer;
begin
  EmitPCodeOperator;

  SubId := Id_ErrAbstract;

  GetReg(_EBX);
  Reg := _EBX;

  EmitGet_REG(Reg, SymbolRec1); // pchar source
  Prg.AsmPush_REG(Reg);

  EmitGet_REG(Reg, SymbolTable[SubId]);

  Prg.AsmCall_REG(Reg);
  FreeReg(Reg);
end;

procedure TEmitter.EmitOP_ANSISTRING_FROM_ANSICHAR;
var
  SubId, Reg: Integer;
begin
  EmitPCodeOperator;
  Emit_PUSH_REGS;

  SubId := Id_AnsiStringFromAnsiChar;

  GetReg(_EBX);
  Reg := _EBX;

  EmitLoadAddress(Reg, SymbolRec1); // string dest
  Prg.AsmPush_REG(Reg);

  EmitLoadIntVal(Reg, SymbolRec2); // char source
  Prg.AsmPush_REG(Reg);

  EmitGet_REG(Reg, SymbolTable[SubId]);
  Prg.AsmCall_REG(Reg);

  FreeReg(Reg);
  Emit_POP_REGS;
end;

procedure TEmitter.EmitOP_WIDESTRING_FROM_ANSICHAR;
var
  SubId, Reg: Integer;
begin
  EmitPCodeOperator;
  Emit_PUSH_REGS;

  SubId := Id_WideStringFromAnsiChar;

  GetReg(_EBX);
  Reg := _EBX;

  EmitLoadAddress(Reg, SymbolRec1); // dest
  Prg.AsmPush_REG(Reg);

  EmitLoadIntVal(Reg, SymbolRec2); // char source
  Prg.AsmPush_REG(Reg);

  EmitGet_REG(Reg, SymbolTable[SubId]);
  Prg.AsmCall_REG(Reg);

  FreeReg(Reg);
  Emit_POP_REGS;
end;

procedure TEmitter.EmitOP_UNICSTRING_FROM_ANSICHAR;
var
  SubId, Reg: Integer;
begin
  EmitPCodeOperator;
  Emit_PUSH_REGS;

  SubId := Id_UnicStringFromAnsiChar;

  GetReg(_EBX);
  Reg := _EBX;

  EmitLoadAddress(Reg, SymbolRec1); // dest
  Prg.AsmPush_REG(Reg);

  EmitLoadIntVal(Reg, SymbolRec2); // char source
  Prg.AsmPush_REG(Reg);

  EmitGet_REG(Reg, SymbolTable[SubId]);
  Prg.AsmCall_REG(Reg);

  FreeReg(Reg);
  Emit_POP_REGS;
end;

procedure TEmitter.EmitOP_VARIANT_FROM_ANSICHAR;
var
  SubId, Reg: Integer;
begin
  EmitPCodeOperator;
  Emit_PUSH_REGS;

  SubId := Id_VariantFromAnsiChar;

  GetReg(_EBX);
  Reg := _EBX;

  EmitLoadAddress(Reg, SymbolRec1); // dest
  Prg.AsmPush_REG(Reg);

  EmitLoadIntVal(Reg, SymbolRec2); // char source
  Prg.AsmPush_REG(Reg);

  EmitGet_REG(Reg, SymbolTable[SubId]);
  Prg.AsmCall_REG(Reg);

  Emit_POP_REGS;
  FreeReg(Reg);
end;

procedure TEmitter.EmitOP_OLEVARIANT_FROM_ANSICHAR;
var
  SubId, Reg: Integer;
begin
  EmitPCodeOperator;
  Emit_PUSH_REGS;

  SubId := Id_OleVariantFromAnsiChar;

  GetReg(_EBX);
  Reg := _EBX;

  EmitLoadAddress(Reg, SymbolRec1); // dest
  Prg.AsmPush_REG(Reg);

  EmitLoadIntVal(Reg, SymbolRec2); // char source
  Prg.AsmPush_REG(Reg);

  EmitGet_REG(Reg, SymbolTable[SubId]);
  Prg.AsmCall_REG(Reg);

  Emit_POP_REGS;
  FreeReg(Reg);
end;

procedure TEmitter.EmitOP_VARIANT_FROM_INT;
var
  SubId, Reg: Integer;
begin
  EmitPCodeOperator;
  Emit_PUSH_REGS;

  SubId := Id_VariantFromInt;

  GetReg(_EBX);
  Reg := _EBX;

  EmitLoadAddress(Reg, SymbolRec1); // dest
  Prg.AsmPush_REG(Reg);

  EmitLoadIntVal(Reg, SymbolRec2); // source
  Prg.AsmPush_REG(Reg);

  EmitGet_REG(Reg, SymbolTable[SubId]);
  Prg.AsmCall_REG(Reg);

  Emit_POP_REGS;
  FreeReg(Reg);
end;

procedure TEmitter.EmitOP_OLEVARIANT_FROM_INT;
var
  SubId, Reg: Integer;
begin
  EmitPCodeOperator;
  Emit_PUSH_REGS;

  SubId := Id_OleVariantFromInt;

  GetReg(_EBX);
  Reg := _EBX;

  EmitLoadAddress(Reg, SymbolRec1); // dest
  Prg.AsmPush_REG(Reg);

  EmitLoadIntVal(Reg, SymbolRec2); // source
  Prg.AsmPush_REG(Reg);

  EmitGet_REG(Reg, SymbolTable[SubId]);
  Prg.AsmCall_REG(Reg);

  Emit_POP_REGS;
  FreeReg(Reg);
end;

procedure TEmitter.EmitOP_VARIANT_FROM_INTERFACE;
var
  SubId, Reg: Integer;
begin
  EmitPCodeOperator;
  Emit_PUSH_REGS;

  SubId := Id_VariantFromInterface;

  GetReg(_EBX);
  Reg := _EBX;

  EmitLoadAddress(Reg, SymbolRec1); // dest
  Prg.AsmPush_REG(Reg);

  EmitLoadIntVal(Reg, SymbolRec2); // source
  Prg.AsmPush_REG(Reg);

  EmitGet_REG(Reg, SymbolTable[SubId]);
  Prg.AsmCall_REG(Reg);

  FreeReg(Reg);
  Emit_POP_REGS;
end;

procedure TEmitter.EmitOP_OLEVARIANT_FROM_INTERFACE;
var
  SubId, Reg: Integer;
begin
  EmitPCodeOperator;
  Emit_PUSH_REGS;

  SubId := Id_OleVariantFromInterface;

  GetReg(_EBX);
  Reg := _EBX;

  EmitLoadAddress(Reg, SymbolRec1); // dest
  Prg.AsmPush_REG(Reg);

  EmitLoadIntVal(Reg, SymbolRec2); // source
  Prg.AsmPush_REG(Reg);

  EmitGet_REG(Reg, SymbolTable[SubId]);
  Prg.AsmCall_REG(Reg);

  FreeReg(Reg);
  Emit_POP_REGS;
end;

procedure TEmitter.EmitOP_VARIANT_FROM_INT64;
var
  SubId, Reg: Integer;
begin
  EmitPCodeOperator;
  Emit_PUSH_REGS;

  SubId := Id_VariantFromInt64;

  GetReg(_EBX);
  Reg := _EBX;

  EmitLoadAddress(Reg, SymbolRec1); // dest
  Prg.AsmPush_REG(Reg);

  EmitLoadAddress(Reg, SymbolRec2); // source
  Prg.AsmPush_REG(Reg);

  EmitGet_REG(Reg, SymbolTable[SubId]);
  Prg.AsmCall_REG(Reg);

  FreeReg(Reg);
  Emit_POP_REGS;
end;

procedure TEmitter.EmitOP_OLEVARIANT_FROM_INT64;
var
  SubId, Reg: Integer;
begin
  EmitPCodeOperator;
  Emit_PUSH_REGS;

  SubId := Id_OleVariantFromInt64;

  GetReg(_EBX);
  Reg := _EBX;

  EmitLoadAddress(Reg, SymbolRec1); // dest
  Prg.AsmPush_REG(Reg);

  EmitLoadAddress(Reg, SymbolRec2); // source
  Prg.AsmPush_REG(Reg);

  EmitGet_REG(Reg, SymbolTable[SubId]);
  Prg.AsmCall_REG(Reg);

  FreeReg(Reg);
  Emit_POP_REGS;
end;

procedure TEmitter.EmitOP_VARIANT_FROM_BYTE;
var
  SubId, Reg: Integer;
begin
  EmitPCodeOperator;
  Emit_PUSH_REGS;

  SubId := Id_VariantFromByte;

  GetReg(_EBX);
  Reg := _EBX;

  EmitLoadAddress(Reg, SymbolRec1); // dest
  Prg.AsmPush_REG(Reg);

  EmitLoadIntVal(Reg, SymbolRec2); // source
  Prg.AsmPush_REG(Reg);

  EmitGet_REG(Reg, SymbolTable[SubId]);
  Prg.AsmCall_REG(Reg);

  FreeReg(Reg);
  Emit_POP_REGS;
end;

procedure TEmitter.EmitOP_OLEVARIANT_FROM_BYTE;
var
  SubId, Reg: Integer;
begin
  EmitPCodeOperator;
  Emit_PUSH_REGS;

  SubId := Id_OleVariantFromByte;

  GetReg(_EBX);
  Reg := _EBX;

  EmitLoadAddress(Reg, SymbolRec1); // dest
  Prg.AsmPush_REG(Reg);

  EmitLoadIntVal(Reg, SymbolRec2); // source
  Prg.AsmPush_REG(Reg);

  EmitGet_REG(Reg, SymbolTable[SubId]);
  Prg.AsmCall_REG(Reg);

  FreeReg(Reg);
  Emit_POP_REGS;
end;

procedure TEmitter.EmitOP_VARIANT_FROM_BOOL;
var
  SubId, Reg: Integer;
begin
  EmitPCodeOperator;
  Emit_PUSH_REGS;

  SubId := Id_VariantFromBool;

  GetReg(_EBX);
  Reg := _EBX;

  EmitLoadAddress(Reg, SymbolRec1); // dest
  Prg.AsmPush_REG(Reg);

  EmitLoadIntVal(Reg, SymbolRec2); // source
  Prg.AsmPush_REG(Reg);

  EmitGet_REG(Reg, SymbolTable[SubId]);
  Prg.AsmCall_REG(Reg);

  FreeReg(Reg);
  Emit_POP_REGS;
end;

procedure TEmitter.EmitOP_OLEVARIANT_FROM_BOOL;
var
  SubId, Reg: Integer;
begin
  EmitPCodeOperator;
  Emit_PUSH_REGS;

  SubId := Id_OleVariantFromBool;

  GetReg(_EBX);
  Reg := _EBX;

  EmitLoadAddress(Reg, SymbolRec1); // dest
  Prg.AsmPush_REG(Reg);

  EmitLoadIntVal(Reg, SymbolRec2); // source
  Prg.AsmPush_REG(Reg);

  EmitGet_REG(Reg, SymbolTable[SubId]);
  Prg.AsmCall_REG(Reg);

  FreeReg(Reg);
  Emit_POP_REGS;
end;

procedure TEmitter.EmitOP_VARIANT_FROM_WORD;
var
  SubId, Reg: Integer;
begin
  EmitPCodeOperator;
  Emit_PUSH_REGS;

  SubId := Id_VariantFromWord;

  GetReg(_EBX);
  Reg := _EBX;

  EmitLoadAddress(Reg, SymbolRec1); // dest
  Prg.AsmPush_REG(Reg);

  EmitLoadIntVal(Reg, SymbolRec2); // source
  Prg.AsmPush_REG(Reg);

  EmitGet_REG(Reg, SymbolTable[SubId]);
  Prg.AsmCall_REG(Reg);

  FreeReg(Reg);
  Emit_POP_REGS;
end;

procedure TEmitter.EmitOP_OLEVARIANT_FROM_WORD;
var
  SubId, Reg: Integer;
begin
  EmitPCodeOperator;
  Emit_PUSH_REGS;

  SubId := Id_OleVariantFromWord;

  GetReg(_EBX);
  Reg := _EBX;

  EmitLoadAddress(Reg, SymbolRec1); // dest
  Prg.AsmPush_REG(Reg);

  EmitLoadIntVal(Reg, SymbolRec2); // source
  Prg.AsmPush_REG(Reg);

  EmitGet_REG(Reg, SymbolTable[SubId]);
  Prg.AsmCall_REG(Reg);

  FreeReg(Reg);
  Emit_POP_REGS;
end;

procedure TEmitter.EmitOP_VARIANT_FROM_CARDINAL;
var
  SubId, Reg: Integer;
begin
  EmitPCodeOperator;
  Emit_PUSH_REGS;

  SubId := Id_VariantFromCardinal;

  GetReg(_EBX);
  Reg := _EBX;

  EmitLoadAddress(Reg, SymbolRec1); // dest
  Prg.AsmPush_REG(Reg);

  EmitLoadIntVal(Reg, SymbolRec2); // source
  Prg.AsmPush_REG(Reg);

  EmitGet_REG(Reg, SymbolTable[SubId]);
  Prg.AsmCall_REG(Reg);

  FreeReg(Reg);
  Emit_POP_REGS;
end;

procedure TEmitter.EmitOP_OLEVARIANT_FROM_CARDINAL;
var
  SubId, Reg: Integer;
begin
  EmitPCodeOperator;
  Emit_PUSH_REGS;

  SubId := Id_OleVariantFromCardinal;

  GetReg(_EBX);
  Reg := _EBX;

  EmitLoadAddress(Reg, SymbolRec1); // dest
  Prg.AsmPush_REG(Reg);

  EmitLoadIntVal(Reg, SymbolRec2); // source
  Prg.AsmPush_REG(Reg);

  EmitGet_REG(Reg, SymbolTable[SubId]);
  Prg.AsmCall_REG(Reg);

  FreeReg(Reg);
  Emit_POP_REGS;
end;

procedure TEmitter.EmitOP_VARIANT_FROM_SMALLINT;
var
  SubId, Reg: Integer;
begin
  EmitPCodeOperator;
  Emit_PUSH_REGS;

  SubId := Id_VariantFromSmallInt;

  GetReg(_EBX);
  Reg := _EBX;

  EmitLoadAddress(Reg, SymbolRec1); // dest
  Prg.AsmPush_REG(Reg);

  EmitLoadIntVal(Reg, SymbolRec2); // source
  Prg.AsmPush_REG(Reg);

  EmitGet_REG(Reg, SymbolTable[SubId]);
  Prg.AsmCall_REG(Reg);

  FreeReg(Reg);
  Emit_POP_REGS;
end;

procedure TEmitter.EmitOP_OLEVARIANT_FROM_SMALLINT;
var
  SubId, Reg: Integer;
begin
  EmitPCodeOperator;
  Emit_PUSH_REGS;

  SubId := Id_OleVariantFromSmallInt;

  GetReg(_EBX);
  Reg := _EBX;

  EmitLoadAddress(Reg, SymbolRec1); // dest
  Prg.AsmPush_REG(Reg);

  EmitLoadIntVal(Reg, SymbolRec2); // source
  Prg.AsmPush_REG(Reg);

  EmitGet_REG(Reg, SymbolTable[SubId]);
  Prg.AsmCall_REG(Reg);

  FreeReg(Reg);
  Emit_POP_REGS;
end;

procedure TEmitter.EmitOP_VARIANT_FROM_SHORTINT;
var
  SubId, Reg: Integer;
begin
  EmitPCodeOperator;
  Emit_PUSH_REGS;

  SubId := Id_VariantFromShortInt;

  GetReg(_EBX);
  Reg := _EBX;

  EmitLoadAddress(Reg, SymbolRec1); // dest
  Prg.AsmPush_REG(Reg);

  EmitLoadIntVal(Reg, SymbolRec2); // source
  Prg.AsmPush_REG(Reg);

  EmitGet_REG(Reg, SymbolTable[SubId]);
  Prg.AsmCall_REG(Reg);

  FreeReg(Reg);
  Emit_POP_REGS;
end;

procedure TEmitter.EmitOP_OLEVARIANT_FROM_SHORTINT;
var
  SubId, Reg: Integer;
begin
  EmitPCodeOperator;
  Emit_PUSH_REGS;

  SubId := Id_OleVariantFromShortInt;

  GetReg(_EBX);
  Reg := _EBX;

  EmitLoadAddress(Reg, SymbolRec1); // dest
  Prg.AsmPush_REG(Reg);

  EmitLoadIntVal(Reg, SymbolRec2); // source
  Prg.AsmPush_REG(Reg);

  EmitGet_REG(Reg, SymbolTable[SubId]);
  Prg.AsmCall_REG(Reg);

  FreeReg(Reg);
  Emit_POP_REGS;
end;

procedure TEmitter.EmitOP_VARIANT_FROM_DOUBLE;
var
  SubId, Reg: Integer;
begin
  EmitPCodeOperator;
  Emit_PUSH_REGS;

  SubId := Id_VariantFromDouble;

  GetReg(_EBX);
  Reg := _EBX;

  EmitLoadAddress(Reg, SymbolRec1); // dest
  Prg.AsmPush_REG(Reg);

  EmitLoadAddress(Reg, SymbolRec2); // source
  Prg.AsmPush_REG(Reg);

  EmitGet_REG(Reg, SymbolTable[SubId]);
  Prg.AsmCall_REG(Reg);

  FreeReg(Reg);
  Emit_POP_REGS;
end;

procedure TEmitter.EmitOP_OLEVARIANT_FROM_DOUBLE;
var
  SubId, Reg: Integer;
begin
  EmitPCodeOperator;
  Emit_PUSH_REGS;

  SubId := Id_OleVariantFromDouble;

  GetReg(_EBX);
  Reg := _EBX;

  EmitLoadAddress(Reg, SymbolRec1); // dest
  Prg.AsmPush_REG(Reg);

  EmitLoadAddress(Reg, SymbolRec2); // source
  Prg.AsmPush_REG(Reg);

  EmitGet_REG(Reg, SymbolTable[SubId]);
  Prg.AsmCall_REG(Reg);

  FreeReg(Reg);
  Emit_POP_REGS;
end;

procedure TEmitter.EmitOP_VARIANT_FROM_CURRENCY;
var
  SubId, Reg: Integer;
begin
  EmitPCodeOperator;
  Emit_PUSH_REGS;

  SubId := Id_VariantFromCurrency;

  GetReg(_EBX);
  Reg := _EBX;

  EmitLoadAddress(Reg, SymbolRec1); // dest
  Prg.AsmPush_REG(Reg);

  EmitLoadAddress(Reg, SymbolRec2); // source
  Prg.AsmPush_REG(Reg);

  EmitGet_REG(Reg, SymbolTable[SubId]);
  Prg.AsmCall_REG(Reg);

  FreeReg(Reg);
  Emit_POP_REGS;
end;

procedure TEmitter.EmitOP_OLEVARIANT_FROM_CURRENCY;
var
  SubId, Reg: Integer;
begin
  EmitPCodeOperator;
  Emit_PUSH_REGS;

  SubId := Id_OleVariantFromCurrency;

  GetReg(_EBX);
  Reg := _EBX;

  EmitLoadAddress(Reg, SymbolRec1); // dest
  Prg.AsmPush_REG(Reg);

  EmitLoadAddress(Reg, SymbolRec2); // source
  Prg.AsmPush_REG(Reg);

  EmitGet_REG(Reg, SymbolTable[SubId]);
  Prg.AsmCall_REG(Reg);

  FreeReg(Reg);
  Emit_POP_REGS;
end;

procedure TEmitter.EmitOP_VARIANT_FROM_SINGLE;
var
  SubId, Reg: Integer;
begin
  EmitPCodeOperator;
  Emit_PUSH_REGS;

  SubId := Id_VariantFromSingle;

  GetReg(_EBX);
  Reg := _EBX;

  EmitLoadAddress(Reg, SymbolRec1); // dest
  Prg.AsmPush_REG(Reg);

  EmitLoadAddress(Reg, SymbolRec2); // source
  Prg.AsmPush_REG(Reg);

  EmitGet_REG(Reg, SymbolTable[SubId]);
  Prg.AsmCall_REG(Reg);

  FreeReg(Reg);
  Emit_POP_REGS;
end;

procedure TEmitter.EmitOP_OLEVARIANT_FROM_SINGLE;
var
  SubId, Reg: Integer;
begin
  EmitPCodeOperator;
  Emit_PUSH_REGS;

  SubId := Id_OleVariantFromSingle;

  GetReg(_EBX);
  Reg := _EBX;

  EmitLoadAddress(Reg, SymbolRec1); // dest
  Prg.AsmPush_REG(Reg);

  EmitLoadAddress(Reg, SymbolRec2); // source
  Prg.AsmPush_REG(Reg);

  EmitGet_REG(Reg, SymbolTable[SubId]);
  Prg.AsmCall_REG(Reg);

  FreeReg(Reg);
  Emit_POP_REGS;
end;

procedure TEmitter.EmitOP_VARIANT_FROM_EXTENDED;
var
  SubId, Reg: Integer;
begin
  EmitPCodeOperator;
  Emit_PUSH_REGS;

  SubId := Id_VariantFromExtended;

  GetReg(_EBX);
  Reg := _EBX;

  EmitLoadAddress(Reg, SymbolRec1); // dest
  Prg.AsmPush_REG(Reg);

  EmitLoadAddress(Reg, SymbolRec2); // source
  Prg.AsmPush_REG(Reg);

  EmitGet_REG(Reg, SymbolTable[SubId]);
  Prg.AsmCall_REG(Reg);

  FreeReg(Reg);
  Emit_POP_REGS;
end;

procedure TEmitter.EmitOP_OLEVARIANT_FROM_EXTENDED;
var
  SubId, Reg: Integer;
begin
  EmitPCodeOperator;
  Emit_PUSH_REGS;

  SubId := Id_OleVariantFromExtended;

  GetReg(_EBX);
  Reg := _EBX;

  EmitLoadAddress(Reg, SymbolRec1); // dest
  Prg.AsmPush_REG(Reg);

  EmitLoadAddress(Reg, SymbolRec2); // source
  Prg.AsmPush_REG(Reg);

  EmitGet_REG(Reg, SymbolTable[SubId]);
  Prg.AsmCall_REG(Reg);

  FreeReg(Reg);
  Emit_POP_REGS;
end;

procedure TEmitter.EmitOP_ANSISTRING_FROM_INT; // JS only
var
  SubId, Reg: Integer;
begin
  EmitPCodeOperator;
  Emit_PUSH_REGS;

  SubId := Id_AnsiStringFromInt;

  GetReg(_EBX);
  Reg := _EBX;

  EmitLoadAddress(Reg, SymbolRecR); // dest
  Prg.AsmPush_REG(Reg);

  EmitLoadAddress(Reg, SymbolRec2); // source
  Prg.AsmPush_REG(Reg);

  EmitGet_REG(Reg, SymbolTable[SubId]);
  Prg.AsmCall_REG(Reg);

  FreeReg(Reg);
  Emit_POP_REGS;
end;

procedure TEmitter.EmitOP_ANSISTRING_FROM_DOUBLE; // JS only
var
  SubId, Reg: Integer;
begin
  EmitPCodeOperator;
  Emit_PUSH_REGS;

  SubId := Id_AnsiStringFromDouble;

  GetReg(_EBX);
  Reg := _EBX;

  EmitLoadAddress(Reg, SymbolRecR); // dest
  Prg.AsmPush_REG(Reg);

  EmitLoadAddress(Reg, SymbolRec2); // source
  Prg.AsmPush_REG(Reg);

  EmitGet_REG(Reg, SymbolTable[SubId]);
  Prg.AsmCall_REG(Reg);

  FreeReg(Reg);
  Emit_POP_REGS;
end;

procedure TEmitter.EmitOP_ANSISTRING_FROM_SINGLE; // JS only
var
  SubId, Reg: Integer;
begin
  EmitPCodeOperator;
  Emit_PUSH_REGS;

  SubId := Id_AnsiStringFromSingle;

  GetReg(_EBX);
  Reg := _EBX;

  EmitLoadAddress(Reg, SymbolRecR); // dest
  Prg.AsmPush_REG(Reg);

  EmitLoadAddress(Reg, SymbolRec2); // source
  Prg.AsmPush_REG(Reg);

  EmitGet_REG(Reg, SymbolTable[SubId]);
  Prg.AsmCall_REG(Reg);

  FreeReg(Reg);
  Emit_POP_REGS;
end;

procedure TEmitter.EmitOP_ANSISTRING_FROM_EXTENDED; // JS only
var
  SubId, Reg: Integer;
begin
  EmitPCodeOperator;
  Emit_PUSH_REGS;

  SubId := Id_AnsiStringFromExtended;

  GetReg(_EBX);
  Reg := _EBX;

  EmitLoadAddress(Reg, SymbolRecR); // dest
  Prg.AsmPush_REG(Reg);

  EmitLoadAddress(Reg, SymbolRec2); // source
  Prg.AsmPush_REG(Reg);

  EmitGet_REG(Reg, SymbolTable[SubId]);
  Prg.AsmCall_REG(Reg);

  FreeReg(Reg);
  Emit_POP_REGS;
end;

procedure TEmitter.EmitOP_ANSISTRING_FROM_BOOLEAN; // JS only
var
  SubId, Reg: Integer;
begin
  EmitPCodeOperator;
  Emit_PUSH_REGS;

  SubId := Id_AnsiStringFromBoolean;

  GetReg(_EBX);
  Reg := _EBX;

  EmitLoadAddress(Reg, SymbolRecR); // dest
  Prg.AsmPush_REG(Reg);

  EmitLoadAddress(Reg, SymbolRec2); // source
  Prg.AsmPush_REG(Reg);

  EmitGet_REG(Reg, SymbolTable[SubId]);
  Prg.AsmCall_REG(Reg);

  FreeReg(Reg);
  Emit_POP_REGS;
end;

procedure TEmitter.EmitOP_UNICSTRING_FROM_INT; // JS only
var
  SubId, Reg: Integer;
begin
  EmitPCodeOperator;
  Emit_PUSH_REGS;

  SubId := Id_UnicStringFromInt;

  GetReg(_EBX);
  Reg := _EBX;

  EmitLoadAddress(Reg, SymbolRecR); // dest
  Prg.AsmPush_REG(Reg);

  EmitLoadAddress(Reg, SymbolRec2); // source
  Prg.AsmPush_REG(Reg);

  EmitGet_REG(Reg, SymbolTable[SubId]);
  Prg.AsmCall_REG(Reg);

  FreeReg(Reg);
  Emit_POP_REGS;
end;

procedure TEmitter.EmitOP_UNICSTRING_FROM_DOUBLE; // JS only
var
  SubId, Reg: Integer;
begin
  EmitPCodeOperator;
  Emit_PUSH_REGS;

  SubId := Id_UnicStringFromDouble;

  GetReg(_EBX);
  Reg := _EBX;

  EmitLoadAddress(Reg, SymbolRecR); // dest
  Prg.AsmPush_REG(Reg);

  EmitLoadAddress(Reg, SymbolRec2); // source
  Prg.AsmPush_REG(Reg);

  EmitGet_REG(Reg, SymbolTable[SubId]);
  Prg.AsmCall_REG(Reg);

  FreeReg(Reg);
  Emit_POP_REGS;
end;

procedure TEmitter.EmitOP_UNICSTRING_FROM_SINGLE; // JS only
var
  SubId, Reg: Integer;
begin
  EmitPCodeOperator;
  Emit_PUSH_REGS;

  SubId := Id_UnicStringFromSingle;

  GetReg(_EBX);
  Reg := _EBX;

  EmitLoadAddress(Reg, SymbolRecR); // dest
  Prg.AsmPush_REG(Reg);

  EmitLoadAddress(Reg, SymbolRec2); // source
  Prg.AsmPush_REG(Reg);

  EmitGet_REG(Reg, SymbolTable[SubId]);
  Prg.AsmCall_REG(Reg);

  FreeReg(Reg);
  Emit_POP_REGS;
end;

procedure TEmitter.EmitOP_UNICSTRING_FROM_EXTENDED; // JS only
var
  SubId, Reg: Integer;
begin
  EmitPCodeOperator;
  Emit_PUSH_REGS;

  SubId := Id_UnicStringFromExtended;

  GetReg(_EBX);
  Reg := _EBX;

  EmitLoadAddress(Reg, SymbolRecR); // dest
  Prg.AsmPush_REG(Reg);

  EmitLoadAddress(Reg, SymbolRec2); // source
  Prg.AsmPush_REG(Reg);

  EmitGet_REG(Reg, SymbolTable[SubId]);
  Prg.AsmCall_REG(Reg);

  FreeReg(Reg);
  Emit_POP_REGS;
end;

procedure TEmitter.EmitOP_UNICSTRING_FROM_BOOLEAN; // JS only
var
  SubId, Reg: Integer;
begin
  EmitPCodeOperator;
  Emit_PUSH_REGS;

  SubId := Id_UnicStringFromBoolean;

  GetReg(_EBX);
  Reg := _EBX;

  EmitLoadAddress(Reg, SymbolRecR); // dest
  Prg.AsmPush_REG(Reg);

  EmitLoadAddress(Reg, SymbolRec2); // source
  Prg.AsmPush_REG(Reg);

  EmitGet_REG(Reg, SymbolTable[SubId]);
  Prg.AsmCall_REG(Reg);

  FreeReg(Reg);
  Emit_POP_REGS;
end;

procedure TEmitter.EmitOP_JS_FUNC_OBJ_FROM_VARIANT; // JS only
var
  SubId, Reg: Integer;
begin
  EmitPCodeOperator;
  Emit_PUSH_REGS;

  SubId := Id_FuncObjFromVariant;

  GetReg(_EBX);
  Reg := _EBX;

  EmitLoadAddress(Reg, SymbolRecR); // dest
  Prg.AsmPush_REG(Reg);

  EmitLoadAddress(Reg, SymbolRec1); // source
  Prg.AsmPush_REG(Reg);

  EmitGet_REG(Reg, SymbolTable[SubId]);
  Prg.AsmCall_REG(Reg);

  FreeReg(Reg);
  Emit_POP_REGS;
end;


procedure TEmitter.EmitOP_ANSISTRING_FROM_VARIANT;
var
  SubId, Reg: Integer;
begin
  EmitPCodeOperator;
  Emit_PUSH_REGS;

  SubId := Id_AnsiStringFromVariant;

  GetReg(_EBX);
  Reg := _EBX;

  EmitLoadAddress(Reg, SymbolRecR); // dest
  Prg.AsmPush_REG(Reg);

  EmitLoadAddress(Reg, SymbolRec2); // source
  Prg.AsmPush_REG(Reg);

  EmitGet_REG(Reg, SymbolTable[SubId]);
  Prg.AsmCall_REG(Reg);

  FreeReg(Reg);
  Emit_POP_REGS;
end;

procedure TEmitter.EmitOP_WIDESTRING_FROM_VARIANT;
var
  SubId, Reg: Integer;
begin
  EmitPCodeOperator;
  Emit_PUSH_REGS;

  SubId := Id_WideStringFromVariant;

  GetReg(_EBX);
  Reg := _EBX;

  EmitLoadAddress(Reg, SymbolRecR); // dest
  Prg.AsmPush_REG(Reg);

  EmitLoadAddress(Reg, SymbolRec2); // source
  Prg.AsmPush_REG(Reg);

  EmitGet_REG(Reg, SymbolTable[SubId]);
  Prg.AsmCall_REG(Reg);

  FreeReg(Reg);
  Emit_POP_REGS;
end;

procedure TEmitter.EmitOP_UNICSTRING_FROM_VARIANT;
var
  SubId, Reg: Integer;
begin
  EmitPCodeOperator;
  Emit_PUSH_REGS;

  SubId := Id_UnicStringFromVariant;

  GetReg(_EBX);
  Reg := _EBX;

  EmitLoadAddress(Reg, SymbolRecR); // dest
  Prg.AsmPush_REG(Reg);

  EmitLoadAddress(Reg, SymbolRec2); // source
  Prg.AsmPush_REG(Reg);

  EmitGet_REG(Reg, SymbolTable[SubId]);
  Prg.AsmCall_REG(Reg);

  FreeReg(Reg);
  Emit_POP_REGS;
end;

procedure TEmitter.EmitOP_SHORTSTRING_FROM_VARIANT;
var
  SubId, Reg: Integer;
begin
  EmitPCodeOperator;
  Emit_PUSH_REGS;

  SubId := Id_ShortStringFromVariant;

  GetReg(_EBX);
  Reg := _EBX;

  EmitLoadAddress(Reg, SymbolRec1); // dest
  Prg.AsmPush_REG(Reg);

  EmitLoadAddress(Reg, SymbolRec2); // source
  Prg.AsmPush_REG(Reg);

  EmitGet_REG(Reg, SymbolTable[SubId]);
  Prg.AsmCall_REG(Reg);

  FreeReg(Reg);
  Emit_POP_REGS;
end;

procedure TEmitter.EmitOP_DOUBLE_FROM_VARIANT;
var
  SubId, Reg: Integer;
begin
  EmitPCodeOperator;

  SubId := Id_DoubleFromVariant;

  GetReg(_EBX);
  Reg := _EBX;

  EmitLoadAddress(Reg, SymbolRecR); // dest
  Prg.AsmPush_REG(Reg);

  EmitLoadAddress(Reg, SymbolRec2); // source
  Prg.AsmPush_REG(Reg);

  EmitGet_REG(Reg, SymbolTable[SubId]);
  Prg.AsmCall_REG(Reg);

  FreeReg(Reg);
end;

procedure TEmitter.EmitOP_CURRENCY_FROM_VARIANT;
var
  SubId, Reg: Integer;
begin
  EmitPCodeOperator;

  SubId := Id_CurrencyFromVariant;

  GetReg(_EBX);
  Reg := _EBX;

  EmitLoadAddress(Reg, SymbolRecR); // dest
  Prg.AsmPush_REG(Reg);

  EmitLoadAddress(Reg, SymbolRec2); // source
  Prg.AsmPush_REG(Reg);

  EmitGet_REG(Reg, SymbolTable[SubId]);
  Prg.AsmCall_REG(Reg);

  FreeReg(Reg);
end;

procedure TEmitter.EmitOP_SINGLE_FROM_VARIANT;
var
  SubId, Reg: Integer;
begin
  EmitPCodeOperator;

  SubId := Id_SingleFromVariant;

  GetReg(_EBX);
  Reg := _EBX;

  EmitLoadAddress(Reg, SymbolRecR); // dest
  Prg.AsmPush_REG(Reg);

  EmitLoadAddress(Reg, SymbolRec2); // source
  Prg.AsmPush_REG(Reg);

  EmitGet_REG(Reg, SymbolTable[SubId]);
  Prg.AsmCall_REG(Reg);

  FreeReg(Reg);
end;

procedure TEmitter.EmitOP_EXTENDED_FROM_VARIANT;
var
  SubId, Reg: Integer;
begin
  EmitPCodeOperator;

  SubId := Id_ExtendedFromVariant;

  GetReg(_EBX);
  Reg := _EBX;

  EmitLoadAddress(Reg, SymbolRecR); // dest
  Prg.AsmPush_REG(Reg);

  EmitLoadAddress(Reg, SymbolRec2); // source
  Prg.AsmPush_REG(Reg);

  EmitGet_REG(Reg, SymbolTable[SubId]);
  Prg.AsmCall_REG(Reg);

  FreeReg(Reg);
end;

procedure TEmitter.EmitOP_INT_FROM_VARIANT;
var
  SubId, Reg: Integer;
begin
  EmitPCodeOperator;

  SubId := Id_IntFromVariant;

  GetReg(_EBX);
  Reg := _EBX;

  EmitLoadAddress(Reg, SymbolRecR); // dest
  Prg.AsmPush_REG(Reg);

  EmitLoadAddress(Reg, SymbolRec2); // source
  Prg.AsmPush_REG(Reg);

  EmitGet_REG(Reg, SymbolTable[SubId]);
  Prg.AsmCall_REG(Reg);

  FreeReg(Reg);
end;

procedure TEmitter.EmitOP_INT64_FROM_VARIANT;
var
  SubId, Reg: Integer;
begin
  EmitPCodeOperator;

  SubId := Id_Int64FromVariant;

  GetReg(_EBX);
  Reg := _EBX;

  EmitLoadAddress(Reg, SymbolRecR); // dest
  Prg.AsmPush_REG(Reg);

  EmitLoadAddress(Reg, SymbolRec2); // source
  Prg.AsmPush_REG(Reg);

  EmitGet_REG(Reg, SymbolTable[SubId]);
  Prg.AsmCall_REG(Reg);

  FreeReg(Reg);
end;

procedure TEmitter.EmitOP_INT_FROM_INT64;
var
  Reg: Integer;
begin
  EmitPCodeOperator;

  Reg := GetReg;
  EmitLoadIntVal(Reg, SymbolRec2);
  EmitSaveIntVal(Reg, SymbolRecR);
  FreeReg(Reg);
end;

procedure TEmitter.EmitOP_BYTE_FROM_INT64;
var
  Reg: Integer;
begin
  EmitPCodeOperator;

  Reg := GetReg;
  EmitLoadIntVal(Reg, SymbolRec2);
  EmitSaveIntVal(Reg, SymbolRecR);
  FreeReg(Reg);
end;

procedure TEmitter.EmitOP_WORD_FROM_INT64;
var
  Reg: Integer;
begin
  EmitPCodeOperator;

  Reg := GetReg;
  EmitLoadIntVal(Reg, SymbolRec2);
  EmitSaveIntVal(Reg, SymbolRecR);
  FreeReg(Reg);
end;

procedure TEmitter.EmitOP_CARDINAL_FROM_INT64;
var
  Reg: Integer;
begin
  EmitPCodeOperator;

  Reg := GetReg;
  EmitLoadIntVal(Reg, SymbolRec2);
  EmitSaveIntVal(Reg, SymbolRecR);
  FreeReg(Reg);
end;

procedure TEmitter.EmitOP_SMALLINT_FROM_INT64;
var
  Reg: Integer;
begin
  EmitPCodeOperator;

  Reg := GetReg;
  EmitLoadIntVal(Reg, SymbolRec2);
  EmitSaveIntVal(Reg, SymbolRecR);
  FreeReg(Reg);
end;

procedure TEmitter.EmitOP_SHORTINT_FROM_INT64;
var
  Reg: Integer;
begin
  EmitPCodeOperator;

  Reg := GetReg;
  EmitLoadIntVal(Reg, SymbolRec2);
  EmitSaveIntVal(Reg, SymbolRecR);
  FreeReg(Reg);
end;

procedure TEmitter.EmitOP_BYTE_FROM_VARIANT;
var
  SubId, Reg: Integer;
begin
  EmitPCodeOperator;

  SubId := Id_ByteFromVariant;

  GetReg(_EBX);
  Reg := _EBX;

  EmitLoadAddress(Reg, SymbolRecR); // dest
  Prg.AsmPush_REG(Reg);

  EmitLoadAddress(Reg, SymbolRec2); // source
  Prg.AsmPush_REG(Reg);

  EmitGet_REG(Reg, SymbolTable[SubId]);
  Prg.AsmCall_REG(Reg);

  FreeReg(Reg);
end;

procedure TEmitter.EmitOP_WORD_FROM_VARIANT;
var
  SubId, Reg: Integer;
begin
  EmitPCodeOperator;

  SubId := Id_WordFromVariant;

  GetReg(_EBX);
  Reg := _EBX;

  EmitLoadAddress(Reg, SymbolRecR); // dest
  Prg.AsmPush_REG(Reg);

  EmitLoadAddress(Reg, SymbolRec2); // source
  Prg.AsmPush_REG(Reg);

  EmitGet_REG(Reg, SymbolTable[SubId]);
  Prg.AsmCall_REG(Reg);

  FreeReg(Reg);
end;

procedure TEmitter.EmitOP_CARDINAL_FROM_VARIANT;
var
  SubId, Reg: Integer;
begin
  EmitPCodeOperator;

  SubId := Id_CardinalFromVariant;

  GetReg(_EBX);
  Reg := _EBX;

  EmitLoadAddress(Reg, SymbolRecR); // dest
  Prg.AsmPush_REG(Reg);

  EmitLoadAddress(Reg, SymbolRec2); // source
  Prg.AsmPush_REG(Reg);

  EmitGet_REG(Reg, SymbolTable[SubId]);
  Prg.AsmCall_REG(Reg);

  FreeReg(Reg);
end;

procedure TEmitter.EmitOP_SMALLINT_FROM_VARIANT;
var
  SubId, Reg: Integer;
begin
  EmitPCodeOperator;

  SubId := Id_SmallIntFromVariant;

  GetReg(_EBX);
  Reg := _EBX;

  EmitLoadAddress(Reg, SymbolRecR); // dest
  Prg.AsmPush_REG(Reg);

  EmitLoadAddress(Reg, SymbolRec2); // source
  Prg.AsmPush_REG(Reg);

  EmitGet_REG(Reg, SymbolTable[SubId]);
  Prg.AsmCall_REG(Reg);

  FreeReg(Reg);
end;

procedure TEmitter.EmitOP_SHORTINT_FROM_VARIANT;
var
  SubId, Reg: Integer;
begin
  EmitPCodeOperator;

  SubId := Id_ShortIntFromVariant;

  GetReg(_EBX);
  Reg := _EBX;

  EmitLoadAddress(Reg, SymbolRecR); // dest
  Prg.AsmPush_REG(Reg);

  EmitLoadAddress(Reg, SymbolRec2); // source
  Prg.AsmPush_REG(Reg);

  EmitGet_REG(Reg, SymbolTable[SubId]);
  Prg.AsmCall_REG(Reg);

  FreeReg(Reg);
end;

procedure TEmitter.EmitOP_BOOL_FROM_VARIANT;
var
  SubId, Reg: Integer;
begin
  EmitPCodeOperator;

  SubId := Id_BoolFromVariant;

  GetReg(_EBX);
  Reg := _EBX;

  EmitLoadAddress(Reg, SymbolRecR); // dest
  Prg.AsmPush_REG(Reg);

  EmitLoadAddress(Reg, SymbolRec2); // source
  Prg.AsmPush_REG(Reg);

  EmitGet_REG(Reg, SymbolTable[SubId]);
  Prg.AsmCall_REG(Reg);

  FreeReg(Reg);
end;

procedure TEmitter.EmitOP_BYTEBOOL_FROM_VARIANT;
var
  SubId, Reg: Integer;
begin
  EmitPCodeOperator;

  SubId := Id_ByteBoolFromVariant;

  GetReg(_EBX);
  Reg := _EBX;

  EmitLoadAddress(Reg, SymbolRecR); // dest
  Prg.AsmPush_REG(Reg);

  EmitLoadAddress(Reg, SymbolRec2); // source
  Prg.AsmPush_REG(Reg);

  EmitGet_REG(Reg, SymbolTable[SubId]);
  Prg.AsmCall_REG(Reg);

  FreeReg(Reg);
end;

procedure TEmitter.EmitOP_WORDBOOL_FROM_VARIANT;
var
  SubId, Reg: Integer;
begin
  EmitPCodeOperator;

  SubId := Id_WordBoolFromVariant;

  GetReg(_EBX);
  Reg := _EBX;

  EmitLoadAddress(Reg, SymbolRecR); // dest
  Prg.AsmPush_REG(Reg);

  EmitLoadAddress(Reg, SymbolRec2); // source
  Prg.AsmPush_REG(Reg);

  EmitGet_REG(Reg, SymbolTable[SubId]);
  Prg.AsmCall_REG(Reg);

  FreeReg(Reg);
end;

procedure TEmitter.EmitOP_LONGBOOL_FROM_VARIANT;
var
  SubId, Reg: Integer;
begin
  EmitPCodeOperator;

  SubId := Id_LongBoolFromVariant;

  GetReg(_EBX);
  Reg := _EBX;

  EmitLoadAddress(Reg, SymbolRecR); // dest
  Prg.AsmPush_REG(Reg);

  EmitLoadAddress(Reg, SymbolRec2); // source
  Prg.AsmPush_REG(Reg);

  EmitGet_REG(Reg, SymbolTable[SubId]);
  Prg.AsmCall_REG(Reg);

  FreeReg(Reg);
end;

procedure TEmitter.EmitOP_WIDESTRING_FROM_WIDECHAR;
var
  SubId, Reg: Integer;
begin
  EmitPCodeOperator;
  Emit_PUSH_REGS;

  SubId := Id_WideStringFromWideChar;

  GetReg(_EBX);
  Reg := _EBX;

  EmitLoadAddress(Reg, SymbolRec1); // string dest
  Prg.AsmPush_REG(Reg);

  EmitLoadIntVal(Reg, SymbolRec2); // char source
  Prg.AsmPush_REG(Reg);

  EmitGet_REG(Reg, SymbolTable[SubId]);
  Prg.AsmCall_REG(Reg);

  FreeReg(Reg);
  Emit_POP_REGS;
end;

procedure TEmitter.EmitOP_UNICSTRING_FROM_WIDECHAR;
var
  SubId, Reg: Integer;
begin
  EmitPCodeOperator;
  Emit_PUSH_REGS;

  SubId := Id_UnicStringFromWideChar;

  GetReg(_EBX);
  Reg := _EBX;

  EmitLoadAddress(Reg, SymbolRec1); // string dest
  Prg.AsmPush_REG(Reg);

  EmitLoadIntVal(Reg, SymbolRec2); // char source
  Prg.AsmPush_REG(Reg);

  EmitGet_REG(Reg, SymbolTable[SubId]);
  Prg.AsmCall_REG(Reg);

  FreeReg(Reg);
  Emit_POP_REGS;
end;

procedure TEmitter.EmitOP_ANSISTRING_FROM_WIDECHAR;
var
  SubId, Reg: Integer;
begin
  EmitPCodeOperator;
  Emit_PUSH_REGS;

  SubId := Id_AnsiStringFromWideChar;

  GetReg(_EBX);
  Reg := _EBX;

  EmitLoadAddress(Reg, SymbolRec1); // string dest
  Prg.AsmPush_REG(Reg);

  EmitLoadIntVal(Reg, SymbolRec2); // char source
  Prg.AsmPush_REG(Reg);

  EmitGet_REG(Reg, SymbolTable[SubId]);
  Prg.AsmCall_REG(Reg);

  FreeReg(Reg);
  Emit_POP_REGS;
end;

procedure TEmitter.EmitOP_VARIANT_FROM_WIDECHAR;
var
  SubId, Reg: Integer;
begin
  EmitPCodeOperator;
  Emit_PUSH_REGS;

  SubId := Id_VariantFromWideChar;

  GetReg(_EBX);
  Reg := _EBX;

  EmitLoadAddress(Reg, SymbolRec1); // string dest
  Prg.AsmPush_REG(Reg);

  EmitLoadIntVal(Reg, SymbolRec2); // char source
  Prg.AsmPush_REG(Reg);

  EmitGet_REG(Reg, SymbolTable[SubId]);
  Prg.AsmCall_REG(Reg);

  FreeReg(Reg);
  Emit_POP_REGS;
end;

procedure TEmitter.EmitOP_OLEVARIANT_FROM_WIDECHAR;
var
  SubId, Reg: Integer;
begin
  EmitPCodeOperator;
  Emit_PUSH_REGS;

  SubId := Id_OleVariantFromWideChar;

  GetReg(_EBX);
  Reg := _EBX;

  EmitLoadAddress(Reg, SymbolRec1); // string dest
  Prg.AsmPush_REG(Reg);

  EmitLoadIntVal(Reg, SymbolRec2); // char source
  Prg.AsmPush_REG(Reg);

  EmitGet_REG(Reg, SymbolTable[SubId]);
  Prg.AsmCall_REG(Reg);

  FreeReg(Reg);
  Emit_POP_REGS;
end;

procedure TEmitter.EmitOP_WIDESTRING_FROM_WIDECHAR_LITERAL;
var
  SubId, Reg: Integer;
begin
  EmitPCodeOperator;
  Emit_PUSH_REGS;

  SubId := Id_WideStringFromWideChar;

  GetReg(_EBX);
  Reg := _EBX;

  EmitLoadAddress(Reg, SymbolRec1); // string dest
  Prg.AsmPush_REG(Reg);

  Prg.AsmPush_Imm(SymbolRec2.Value); // widechar walue

  EmitGet_REG(Reg, SymbolTable[SubId]);
  Prg.AsmCall_REG(Reg);

  FreeReg(Reg);
  Emit_POP_REGS;
end;

procedure TEmitter.EmitOP_UNICSTRING_FROM_WIDECHAR_LITERAL;
var
  SubId, Reg: Integer;
begin
  EmitPCodeOperator;
  Emit_PUSH_REGS;

  SubId := Id_UnicStringFromWideChar;

  GetReg(_EBX);
  Reg := _EBX;

  EmitLoadAddress(Reg, SymbolRec1); // string dest
  Prg.AsmPush_REG(Reg);

  Prg.AsmPush_Imm(SymbolRec2.Value); // widechar walue

  EmitGet_REG(Reg, SymbolTable[SubId]);
  Prg.AsmCall_REG(Reg);

  FreeReg(Reg);
  Emit_POP_REGS;
end;

procedure TEmitter.EmitOP_VARIANT_FROM_WIDECHAR_LITERAL;
var
  SubId, Reg: Integer;
begin
  EmitPCodeOperator;
  Emit_PUSH_REGS;

  SubId := Id_VariantFromWideChar;

  GetReg(_EBX);
  Reg := _EBX;

  EmitLoadAddress(Reg, SymbolRec1); // string dest
  Prg.AsmPush_REG(Reg);

  Prg.AsmPush_Imm(SymbolRec2.Value); // widechar walue

  EmitGet_REG(Reg, SymbolTable[SubId]);
  Prg.AsmCall_REG(Reg);

  FreeReg(Reg);
  Emit_POP_REGS;
end;

procedure TEmitter.EmitOP_OLEVARIANT_FROM_WIDECHAR_LITERAL;
var
  SubId, Reg: Integer;
begin
  EmitPCodeOperator;
  Emit_PUSH_REGS;

  SubId := Id_OleVariantFromWideChar;

  GetReg(_EBX);
  Reg := _EBX;

  EmitLoadAddress(Reg, SymbolRec1); // string dest
  Prg.AsmPush_REG(Reg);

  Prg.AsmPush_Imm(SymbolRec2.Value); // widechar walue

  EmitGet_REG(Reg, SymbolTable[SubId]);
  Prg.AsmCall_REG(Reg);

  FreeReg(Reg);
  Emit_POP_REGS;
end;

procedure TEmitter.EmitOP_ASSIGN_ANSISTRING;
var
  SubId, Reg: Integer;
begin
  EmitPCodeOperator;

  SubId := Id_AnsiStringAssign;

  Reg := GetReg;

  EmitLoadAddress(Reg, SymbolRecR); // string dest
  Prg.AsmPush_REG(Reg);

  EmitLoadAddress(Reg, SymbolRec2); // string source
  Prg.AsmPush_REG(Reg);

  EmitGet_REG(Reg, SymbolTable[SubId]);
  Prg.AsmCall_REG(Reg);

  FreeReg(Reg);
end;

procedure TEmitter.EmitOP_ASSIGN_VARIANT;
var
  SubId, Reg: Integer;
begin
  EmitPCodeOperator;

  SubId := Id_VariantAssign;

  Reg := GetReg;

  EmitLoadAddress(Reg, SymbolRecR); // dest
  Prg.AsmPush_REG(Reg);

  EmitLoadAddress(Reg, SymbolRec2); // source
  Prg.AsmPush_REG(Reg);

  EmitGet_REG(Reg, SymbolTable[SubId]);
  Prg.AsmCall_REG(Reg);

  FreeReg(Reg);
end;

procedure TEmitter.EmitOP_ASSIGN_OLEVARIANT;
var
  SubId, Reg: Integer;
begin
  EmitPCodeOperator;

  SubId := Id_OleVariantAssign;

  Reg := GetReg;

  EmitLoadAddress(Reg, SymbolRecR); // dest
  Prg.AsmPush_REG(Reg);

  EmitLoadAddress(Reg, SymbolRec2); // source
  Prg.AsmPush_REG(Reg);

  EmitGet_REG(Reg, SymbolTable[SubId]);
  Prg.AsmCall_REG(Reg);

  FreeReg(Reg);
end;

procedure TEmitter.EmitOP_ASSIGN_CLASS;
var
  SubId, Reg: Integer;
begin
  EmitPCodeOperator;

  SubId := Id_ClassAssign;

  Reg := GetReg;

  EmitLoadAddress(Reg, SymbolRecR); // dest
  Prg.AsmPush_REG(Reg);

  EmitLoadIntVal(Reg, SymbolRec2); // source
  Prg.AsmPush_REG(Reg);

  EmitGet_REG(Reg, SymbolTable[SubId]);
  Prg.AsmCall_REG(Reg);

  FreeReg(Reg);
end;

procedure TEmitter.EmitOP_ASSIGN_WIDESTRING;
var
  SubId, Reg: Integer;
begin
  EmitPCodeOperator;

  SubId := Id_WideStringAssign;

  Reg := GetReg;

  EmitLoadAddress(Reg, SymbolRecR); // string dest
  Prg.AsmPush_REG(Reg);

  EmitLoadAddress(Reg, SymbolRec2); // string source
  Prg.AsmPush_REG(Reg);

  EmitGet_REG(Reg, SymbolTable[SubId]);
  Prg.AsmCall_REG(Reg);

  FreeReg(Reg);
end;

procedure TEmitter.EmitOP_ASSIGN_UNICSTRING;
var
  SubId, Reg: Integer;
begin
  EmitPCodeOperator;

  SubId := Id_UnicStringAssign;

  Reg := GetReg;

  EmitLoadAddress(Reg, SymbolRecR); // string dest
  Prg.AsmPush_REG(Reg);

  EmitLoadAddress(Reg, SymbolRec2); // string source
  Prg.AsmPush_REG(Reg);

  EmitGet_REG(Reg, SymbolTable[SubId]);
  Prg.AsmCall_REG(Reg);

  FreeReg(Reg);
end;

procedure TEmitter.EmitOP_ASSIGN_SHORTSTRING;
var
  L, T, SubId, Reg: Integer;
begin
  EmitPCodeOperator;

  SubId := Id_ShortStringAssign;

  T := SymbolRecR.TypeID;
  if T = typeSHORTSTRING then
    L := 255
  else
    L := GetSymbolRec(T).Count;

  Prg.AsmPush_Imm(L);

  Reg := GetReg;

  EmitLoadAddress(Reg, SymbolRecR); // string dest
  Prg.AsmPush_REG(Reg);

  EmitLoadAddress(Reg, SymbolRec2); // string source
  Prg.AsmPush_REG(Reg);

  EmitGet_REG(Reg, SymbolTable[SubId]);
  Prg.AsmCall_REG(Reg);

  FreeReg(Reg);
end;

procedure TEmitter.EmitOP_ADD_ANSISTRING;
var
  SubId, Reg: Integer;
begin
  EmitPCodeOperator;

  SubId := Id_AnsiStringAddition;

  Reg := GetReg;

  EmitLoadAddress(Reg, SymbolRecR); // string dest

  Prg.AsmPush_REG(Reg);

  EmitLoadAddress(Reg, SymbolRec2); // string source
  Prg.AsmPush_REG(Reg);

  EmitLoadAddress(Reg, SymbolRec1); // string source
  Prg.AsmPush_REG(Reg);

  EmitGet_REG(Reg, SymbolTable[SubId]);
  Prg.AsmCall_REG(Reg);

  FreeReg(Reg);
end;

procedure TEmitter.EmitOP_ADD_WIDESTRING;
var
  SubId, Reg: Integer;
begin
  EmitPCodeOperator;

  SubId := Id_WideStringAddition;

  Reg := GetReg;

  EmitLoadAddress(Reg, SymbolRecR); // string dest

  Prg.AsmPush_REG(Reg);

  EmitLoadAddress(Reg, SymbolRec2); // string source
  Prg.AsmPush_REG(Reg);

  EmitLoadAddress(Reg, SymbolRec1); // string source
  Prg.AsmPush_REG(Reg);

  EmitGet_REG(Reg, SymbolTable[SubId]);
  Prg.AsmCall_REG(Reg);

  FreeReg(Reg);
end;

procedure TEmitter.EmitOP_ADD_UNICSTRING;
var
  SubId, Reg: Integer;
begin
  EmitPCodeOperator;

  SubId := Id_UnicStringAddition;

  Reg := GetReg;

  EmitLoadAddress(Reg, SymbolRecR); // string dest

  Prg.AsmPush_REG(Reg);

  EmitLoadAddress(Reg, SymbolRec2); // string source
  Prg.AsmPush_REG(Reg);

  EmitLoadAddress(Reg, SymbolRec1); // string source
  Prg.AsmPush_REG(Reg);

  EmitGet_REG(Reg, SymbolTable[SubId]);
  Prg.AsmCall_REG(Reg);

  FreeReg(Reg);
end;

procedure TEmitter.EmitOP_ADD_SHORTSTRING;
var
  L, T, SubId, Reg: Integer;
begin
  EmitPCodeOperator;

  SubId := Id_ShortStringAddition;

  T := SymbolRecR.TypeID;
  if T = typeSHORTSTRING then
    L := 255
  else
    L := GetSymbolRec(T).Count;

  Prg.AsmPush_Imm(L);

  Reg := GetReg;

  EmitLoadAddress(Reg, SymbolRecR); // string dest
  Prg.AsmPush_REG(Reg);

  EmitLoadAddress(Reg, SymbolRec2); // string source
  Prg.AsmPush_REG(Reg);

  EmitLoadAddress(Reg, SymbolRec1); // string source
  Prg.AsmPush_REG(Reg);

  EmitGet_REG(Reg, SymbolTable[SubId]);
  Prg.AsmCall_REG(Reg);

  FreeReg(Reg);
end;

procedure TEmitter.EmitOP_MULT_INT64;
var
  SubId, Reg: Integer;
begin
  EmitPCodeOperator;

  SubId := Id_Int64Multiplication;

  Reg := GetReg;

  EmitLoadAddress(Reg, SymbolRecR); // dest
  Prg.AsmPush_REG(Reg);

  EmitLoadAddress(Reg, SymbolRec2); // source
  Prg.AsmPush_REG(Reg);

  EmitLoadAddress(Reg, SymbolRec1); // source
  Prg.AsmPush_REG(Reg);

  EmitGet_REG(Reg, SymbolTable[SubId]);
  Prg.AsmCall_REG(Reg);

  FreeReg(Reg);
end;

procedure TEmitter.EmitOP_IDIV_INT64;
var
  SubId, Reg: Integer;
begin
  EmitPCodeOperator;

  SubId := Id_Int64Division;

  Reg := GetReg;

  EmitLoadAddress(Reg, SymbolRecR); // dest
  Prg.AsmPush_REG(Reg);

  EmitLoadAddress(Reg, SymbolRec2); // source
  Prg.AsmPush_REG(Reg);

  EmitLoadAddress(Reg, SymbolRec1); // source
  Prg.AsmPush_REG(Reg);

  EmitGet_REG(Reg, SymbolTable[SubId]);
  Prg.AsmCall_REG(Reg);

  FreeReg(Reg);
end;

procedure TEmitter.EmitOP_MOD_INT64;
var
  SubId, Reg: Integer;
begin
  EmitPCodeOperator;

  SubId := Id_Int64Modulo;

  Reg := GetReg;

  EmitLoadAddress(Reg, SymbolRecR); // dest
  Prg.AsmPush_REG(Reg);

  EmitLoadAddress(Reg, SymbolRec2); // source
  Prg.AsmPush_REG(Reg);

  EmitLoadAddress(Reg, SymbolRec1); // source
  Prg.AsmPush_REG(Reg);

  EmitGet_REG(Reg, SymbolTable[SubId]);
  Prg.AsmCall_REG(Reg);

  FreeReg(Reg);
end;

procedure TEmitter.EmitOP_NEG_VARIANT;
var
  SubId, Reg: Integer;
begin
  EmitPCodeOperator;

  SubId := Id_VariantNegation;

  Reg := GetReg;

  EmitLoadAddress(Reg, SymbolRecR); // dest
  Prg.AsmPush_REG(Reg);

  EmitLoadAddress(Reg, SymbolRec1); // source
  Prg.AsmPush_REG(Reg);

  EmitGet_REG(Reg, SymbolTable[SubId]);
  Prg.AsmCall_REG(Reg);

  FreeReg(Reg);
end;

procedure TEmitter.EmitOP_ABS_VARIANT;
var
  SubId, Reg: Integer;
begin
  EmitPCodeOperator;

  SubId := Id_VariantAbs;

  Reg := GetReg;

  EmitLoadAddress(Reg, SymbolRecR); // dest
  Prg.AsmPush_REG(Reg);

  EmitLoadAddress(Reg, SymbolRec1); // source
  Prg.AsmPush_REG(Reg);

  EmitGet_REG(Reg, SymbolTable[SubId]);
  Prg.AsmCall_REG(Reg);

  FreeReg(Reg);
end;

procedure TEmitter.EmitOP_ABS_INT64;
var
  SubId, Reg: Integer;
begin
  EmitPCodeOperator;

  SubId := Id_Int64Abs;

  Reg := GetReg;

  EmitLoadAddress(Reg, SymbolRecR); // dest
  Prg.AsmPush_REG(Reg);

  EmitLoadAddress(Reg, SymbolRec1); // source
  Prg.AsmPush_REG(Reg);

  EmitGet_REG(Reg, SymbolTable[SubId]);
  Prg.AsmCall_REG(Reg);

  FreeReg(Reg);
end;

procedure TEmitter.EmitOP_NOT_VARIANT;
var
  SubId, Reg: Integer;
begin
  EmitPCodeOperator;

  SubId := Id_VariantNot;

  Reg := GetReg;

  EmitLoadAddress(Reg, SymbolRecR); // dest
  Prg.AsmPush_REG(Reg);

  EmitLoadAddress(Reg, SymbolRec1); // source
  Prg.AsmPush_REG(Reg);

  EmitGet_REG(Reg, SymbolTable[SubId]);
  Prg.AsmCall_REG(Reg);

  FreeReg(Reg);
end;

procedure TEmitter.EmitOP_ADD_VARIANT;
var
  SubId, Reg: Integer;
begin
  EmitPCodeOperator;

  SubId := Id_VariantAddition;

  Reg := GetReg;

  EmitLoadAddress(Reg, SymbolRecR); // dest
  Prg.AsmPush_REG(Reg);

  EmitLoadAddress(Reg, SymbolRec2); // source
  Prg.AsmPush_REG(Reg);

  EmitLoadAddress(Reg, SymbolRec1); // source
  Prg.AsmPush_REG(Reg);

  Prg.AsmPush_Imm(Language);

  EmitGet_REG(Reg, SymbolTable[SubId]);
  Prg.AsmCall_REG(Reg);

  FreeReg(Reg);
end;

procedure TEmitter.EmitOP_SUB_VARIANT;
var
  SubId, Reg: Integer;
begin
  EmitPCodeOperator;

  SubId := Id_VariantSubtraction;

  Reg := GetReg;

  EmitLoadAddress(Reg, SymbolRecR); // dest
  Prg.AsmPush_REG(Reg);

  EmitLoadAddress(Reg, SymbolRec2); // source
  Prg.AsmPush_REG(Reg);

  EmitLoadAddress(Reg, SymbolRec1); // source
  Prg.AsmPush_REG(Reg);

  Prg.AsmPush_Imm(Language);

  EmitGet_REG(Reg, SymbolTable[SubId]);
  Prg.AsmCall_REG(Reg);

  FreeReg(Reg);
end;

procedure TEmitter.EmitOP_MULT_VARIANT;
var
  SubId, Reg: Integer;
begin
  EmitPCodeOperator;

  SubId := Id_VariantMultiplication;

  Reg := GetReg;

  EmitLoadAddress(Reg, SymbolRecR); // dest
  Prg.AsmPush_REG(Reg);

  EmitLoadAddress(Reg, SymbolRec2); // source
  Prg.AsmPush_REG(Reg);

  EmitLoadAddress(Reg, SymbolRec1); // source
  Prg.AsmPush_REG(Reg);

  Prg.AsmPush_Imm(Language);

  EmitGet_REG(Reg, SymbolTable[SubId]);
  Prg.AsmCall_REG(Reg);

  FreeReg(Reg);
end;

procedure TEmitter.EmitOP_DIV_VARIANT;
var
  SubId, Reg: Integer;
begin
  EmitPCodeOperator;

  SubId := Id_VariantDivision;

  Reg := GetReg;

  EmitLoadAddress(Reg, SymbolRecR); // dest
  Prg.AsmPush_REG(Reg);

  EmitLoadAddress(Reg, SymbolRec2); // source
  Prg.AsmPush_REG(Reg);

  EmitLoadAddress(Reg, SymbolRec1); // source
  Prg.AsmPush_REG(Reg);

  Prg.AsmPush_Imm(Language);

  EmitGet_REG(Reg, SymbolTable[SubId]);
  Prg.AsmCall_REG(Reg);

  FreeReg(Reg);
end;

procedure TEmitter.EmitOP_IDIV_VARIANT;
var
  SubId, Reg: Integer;
begin
  EmitPCodeOperator;

  SubId := Id_VariantIDivision;

  Reg := GetReg;

  EmitLoadAddress(Reg, SymbolRecR); // dest
  Prg.AsmPush_REG(Reg);

  EmitLoadAddress(Reg, SymbolRec2); // source
  Prg.AsmPush_REG(Reg);

  EmitLoadAddress(Reg, SymbolRec1); // source
  Prg.AsmPush_REG(Reg);

  Prg.AsmPush_Imm(Language);

  EmitGet_REG(Reg, SymbolTable[SubId]);
  Prg.AsmCall_REG(Reg);

  FreeReg(Reg);
end;

procedure TEmitter.EmitOP_MOD_VARIANT;
var
  SubId, Reg: Integer;
begin
  EmitPCodeOperator;

  SubId := Id_VariantModulo;

  Reg := GetReg;

  EmitLoadAddress(Reg, SymbolRecR); // dest
  Prg.AsmPush_REG(Reg);

  EmitLoadAddress(Reg, SymbolRec2); // source
  Prg.AsmPush_REG(Reg);

  EmitLoadAddress(Reg, SymbolRec1); // source
  Prg.AsmPush_REG(Reg);

  Prg.AsmPush_Imm(Language);

  EmitGet_REG(Reg, SymbolTable[SubId]);
  Prg.AsmCall_REG(Reg);

  FreeReg(Reg);
end;

procedure TEmitter.EmitOP_SHL_VARIANT;
var
  SubId, Reg: Integer;
begin
  EmitPCodeOperator;

  SubId := Id_VariantLeftShift;

  Reg := GetReg;

  EmitLoadAddress(Reg, SymbolRecR); // dest
  Prg.AsmPush_REG(Reg);

  EmitLoadAddress(Reg, SymbolRec2); // source
  Prg.AsmPush_REG(Reg);

  EmitLoadAddress(Reg, SymbolRec1); // source
  Prg.AsmPush_REG(Reg);

  Prg.AsmPush_Imm(Language);

  EmitGet_REG(Reg, SymbolTable[SubId]);
  Prg.AsmCall_REG(Reg);

  FreeReg(Reg);
end;

procedure TEmitter.EmitOP_SHR_VARIANT;
var
  SubId, Reg: Integer;
begin
  EmitPCodeOperator;

  SubId := Id_VariantRightShift;

  Reg := GetReg;

  EmitLoadAddress(Reg, SymbolRecR); // dest
  Prg.AsmPush_REG(Reg);

  EmitLoadAddress(Reg, SymbolRec2); // source
  Prg.AsmPush_REG(Reg);

  EmitLoadAddress(Reg, SymbolRec1); // source
  Prg.AsmPush_REG(Reg);

  Prg.AsmPush_Imm(Language);
  
  EmitGet_REG(Reg, SymbolTable[SubId]);
  Prg.AsmCall_REG(Reg);

  FreeReg(Reg);
end;

procedure TEmitter.EmitOP_AND_VARIANT;
var
  SubId, Reg: Integer;
begin
  EmitPCodeOperator;

  SubId := Id_VariantAnd;

  Reg := GetReg;

  EmitLoadAddress(Reg, SymbolRecR); // dest
  Prg.AsmPush_REG(Reg);

  EmitLoadAddress(Reg, SymbolRec2); // source
  Prg.AsmPush_REG(Reg);

  EmitLoadAddress(Reg, SymbolRec1); // source
  Prg.AsmPush_REG(Reg);

  Prg.AsmPush_Imm(Language);

  EmitGet_REG(Reg, SymbolTable[SubId]);
  Prg.AsmCall_REG(Reg);

  FreeReg(Reg);
end;

procedure TEmitter.EmitOP_OR_VARIANT;
var
  SubId, Reg: Integer;
begin
  EmitPCodeOperator;

  SubId := Id_VariantOr;

  Reg := GetReg;

  EmitLoadAddress(Reg, SymbolRecR); // dest
  Prg.AsmPush_REG(Reg);

  EmitLoadAddress(Reg, SymbolRec2); // source
  Prg.AsmPush_REG(Reg);

  EmitLoadAddress(Reg, SymbolRec1); // source
  Prg.AsmPush_REG(Reg);

  Prg.AsmPush_Imm(Language);

  EmitGet_REG(Reg, SymbolTable[SubId]);
  Prg.AsmCall_REG(Reg);

  FreeReg(Reg);
end;

procedure TEmitter.EmitOP_XOR_VARIANT;
var
  SubId, Reg: Integer;
begin
  EmitPCodeOperator;

  SubId := Id_VariantXor;

  Reg := GetReg;

  EmitLoadAddress(Reg, SymbolRecR); // dest
  Prg.AsmPush_REG(Reg);

  EmitLoadAddress(Reg, SymbolRec2); // source
  Prg.AsmPush_REG(Reg);

  EmitLoadAddress(Reg, SymbolRec1); // source
  Prg.AsmPush_REG(Reg);
  
  Prg.AsmPush_Imm(Language);

  EmitGet_REG(Reg, SymbolTable[SubId]);
  Prg.AsmCall_REG(Reg);

  FreeReg(Reg);
end;

procedure TEmitter.EmitOP_LT_VARIANT;
var
  SubId, Reg: Integer;
begin
  EmitPCodeOperator;

  SubId := Id_VariantLessThan;

  Reg := GetReg;

  EmitLoadAddress(Reg, SymbolRecR); // dest
  Prg.AsmPush_REG(Reg);

  EmitLoadAddress(Reg, SymbolRec2); // source
  Prg.AsmPush_REG(Reg);

  EmitLoadAddress(Reg, SymbolRec1); // source
  Prg.AsmPush_REG(Reg);

  Prg.AsmPush_Imm(Language);

  EmitGet_REG(Reg, SymbolTable[SubId]);
  Prg.AsmCall_REG(Reg);

  FreeReg(Reg);
end;

procedure TEmitter.EmitOP_LE_VARIANT;
var
  SubId, Reg: Integer;
begin
  EmitPCodeOperator;

  SubId := Id_VariantLessThanOrEqual;

  Reg := GetReg;

  EmitLoadAddress(Reg, SymbolRecR); // dest
  Prg.AsmPush_REG(Reg);

  EmitLoadAddress(Reg, SymbolRec2); // source
  Prg.AsmPush_REG(Reg);

  EmitLoadAddress(Reg, SymbolRec1); // source
  Prg.AsmPush_REG(Reg);

  Prg.AsmPush_Imm(Language);

  EmitGet_REG(Reg, SymbolTable[SubId]);
  Prg.AsmCall_REG(Reg);

  FreeReg(Reg);
end;

procedure TEmitter.EmitOP_GT_VARIANT;
var
  SubId, Reg: Integer;
begin
  EmitPCodeOperator;

  SubId := Id_VariantGreaterThan;

  Reg := GetReg;

  EmitLoadAddress(Reg, SymbolRecR); // dest
  Prg.AsmPush_REG(Reg);

  EmitLoadAddress(Reg, SymbolRec2); // source
  Prg.AsmPush_REG(Reg);

  EmitLoadAddress(Reg, SymbolRec1); // source
  Prg.AsmPush_REG(Reg);

  Prg.AsmPush_Imm(Language);

  EmitGet_REG(Reg, SymbolTable[SubId]);
  Prg.AsmCall_REG(Reg);

  FreeReg(Reg);
end;

procedure TEmitter.EmitOP_GE_VARIANT;
var
  SubId, Reg: Integer;
begin
  EmitPCodeOperator;

  SubId := Id_VariantGreaterThanOrEqual;

  Reg := GetReg;

  EmitLoadAddress(Reg, SymbolRecR); // dest
  Prg.AsmPush_REG(Reg);

  EmitLoadAddress(Reg, SymbolRec2); // source
  Prg.AsmPush_REG(Reg);

  EmitLoadAddress(Reg, SymbolRec1); // source
  Prg.AsmPush_REG(Reg);

  Prg.AsmPush_Imm(Language);

  EmitGet_REG(Reg, SymbolTable[SubId]);
  Prg.AsmCall_REG(Reg);

  FreeReg(Reg);
end;

procedure TEmitter.EmitOP_EQ_VARIANT;
var
  SubId, Reg: Integer;
begin
  EmitPCodeOperator;

  SubId := Id_VariantEquality;

  Reg := GetReg;

  EmitLoadAddress(Reg, SymbolRecR); // dest
  Prg.AsmPush_REG(Reg);

  EmitLoadAddress(Reg, SymbolRec2); // source
  Prg.AsmPush_REG(Reg);

  EmitLoadAddress(Reg, SymbolRec1); // source
  Prg.AsmPush_REG(Reg);

  Prg.AsmPush_Imm(Language);

  EmitGet_REG(Reg, SymbolTable[SubId]);
  Prg.AsmCall_REG(Reg);

  FreeReg(Reg);
end;

procedure TEmitter.EmitOP_NE_VARIANT;
var
  SubId, Reg: Integer;
begin
  EmitPCodeOperator;

  SubId := Id_VariantNotEquality;

  Reg := GetReg;

  EmitLoadAddress(Reg, SymbolRecR); // dest
  Prg.AsmPush_REG(Reg);

  EmitLoadAddress(Reg, SymbolRec2); // source
  Prg.AsmPush_REG(Reg);

  EmitLoadAddress(Reg, SymbolRec1); // source
  Prg.AsmPush_REG(Reg);

  Prg.AsmPush_Imm(Language);

  EmitGet_REG(Reg, SymbolTable[SubId]);
  Prg.AsmCall_REG(Reg);

  FreeReg(Reg);
end;

procedure TEmitter.EmitOP_EQ_STRUCT;
var
  SubId, Reg: Integer;
begin
  EmitPCodeOperator;

  SubId := Id_StructEquality;

  Reg := GetReg;

  EmitLoadAddress(Reg, SymbolRecR); // dest
  Prg.AsmPush_REG(Reg);

  EmitLoadAddress(Reg, SymbolRec2); // source
  Prg.AsmPush_REG(Reg);

  EmitLoadAddress(Reg, SymbolRec1); // source
  Prg.AsmPush_REG(Reg);

  EmitGet_REG(Reg, SymbolTable[SubId]);
  Prg.AsmCall_REG(Reg);

  FreeReg(Reg);
end;

procedure TEmitter.EmitOP_NE_STRUCT;
var
  SubId, Reg: Integer;
begin
  EmitPCodeOperator;

  SubId := Id_StructNotEquality;

  Reg := GetReg;

  EmitLoadAddress(Reg, SymbolRecR); // dest
  Prg.AsmPush_REG(Reg);

  EmitLoadAddress(Reg, SymbolRec2); // source
  Prg.AsmPush_REG(Reg);

  EmitLoadAddress(Reg, SymbolRec1); // source
  Prg.AsmPush_REG(Reg);

  EmitGet_REG(Reg, SymbolTable[SubId]);
  Prg.AsmCall_REG(Reg);

  FreeReg(Reg);
end;

procedure TEmitter.EmitOP_EQ_ANSISTRING;
var
  SubId, Reg: Integer;
begin
  EmitPCodeOperator;

  SubId := Id_AnsiStringEquality;

  Reg := GetReg;

  EmitLoadAddress(Reg, SymbolRecR); // dest
  Prg.AsmPush_REG(Reg);

  EmitLoadAddress(Reg, SymbolRec2); // source
  Prg.AsmPush_REG(Reg);

  EmitLoadAddress(Reg, SymbolRec1); // source
  Prg.AsmPush_REG(Reg);

  EmitGet_REG(Reg, SymbolTable[SubId]);
  Prg.AsmCall_REG(Reg);

  FreeReg(Reg);
end;

procedure TEmitter.EmitOP_GT_ANSISTRING;
var
  SubId, Reg: Integer;
begin
  EmitPCodeOperator;

  SubId := Id_AnsiStringGreaterThan;

  Reg := GetReg;

  EmitLoadAddress(Reg, SymbolRecR); // dest
  Prg.AsmPush_REG(Reg);

  EmitLoadAddress(Reg, SymbolRec2); // source
  Prg.AsmPush_REG(Reg);

  EmitLoadAddress(Reg, SymbolRec1); // source
  Prg.AsmPush_REG(Reg);

  EmitGet_REG(Reg, SymbolTable[SubId]);
  Prg.AsmCall_REG(Reg);

  FreeReg(Reg);
end;

procedure TEmitter.EmitOP_GE_ANSISTRING;
var
  SubId, Reg: Integer;
begin
  EmitPCodeOperator;

  SubId := Id_AnsiStringGreaterThanOrEqual;

  Reg := GetReg;

  EmitLoadAddress(Reg, SymbolRecR); // dest
  Prg.AsmPush_REG(Reg);

  EmitLoadAddress(Reg, SymbolRec2); // source
  Prg.AsmPush_REG(Reg);

  EmitLoadAddress(Reg, SymbolRec1); // source
  Prg.AsmPush_REG(Reg);

  EmitGet_REG(Reg, SymbolTable[SubId]);
  Prg.AsmCall_REG(Reg);

  FreeReg(Reg);
end;

procedure TEmitter.EmitOP_LT_ANSISTRING;
var
  SubId, Reg: Integer;
begin
  EmitPCodeOperator;

  SubId := Id_AnsiStringLessThan;

  Reg := GetReg;

  EmitLoadAddress(Reg, SymbolRecR); // dest
  Prg.AsmPush_REG(Reg);

  EmitLoadAddress(Reg, SymbolRec2); // source
  Prg.AsmPush_REG(Reg);

  EmitLoadAddress(Reg, SymbolRec1); // source
  Prg.AsmPush_REG(Reg);

  EmitGet_REG(Reg, SymbolTable[SubId]);
  Prg.AsmCall_REG(Reg);

  FreeReg(Reg);
end;

procedure TEmitter.EmitOP_LE_ANSISTRING;
var
  SubId, Reg: Integer;
begin
  EmitPCodeOperator;

  SubId := Id_AnsiStringLessThanOrEqual;

  Reg := GetReg;

  EmitLoadAddress(Reg, SymbolRecR); // dest
  Prg.AsmPush_REG(Reg);

  EmitLoadAddress(Reg, SymbolRec2); // source
  Prg.AsmPush_REG(Reg);

  EmitLoadAddress(Reg, SymbolRec1); // source
  Prg.AsmPush_REG(Reg);

  EmitGet_REG(Reg, SymbolTable[SubId]);
  Prg.AsmCall_REG(Reg);

  FreeReg(Reg);
end;

procedure TEmitter.EmitOP_GT_SHORTSTRING;
var
  SubId, Reg: Integer;
begin
  EmitPCodeOperator;

  SubId := Id_ShortStringGreaterThan;

  Reg := GetReg;

  EmitLoadAddress(Reg, SymbolRecR); // dest
  Prg.AsmPush_REG(Reg);

  EmitLoadAddress(Reg, SymbolRec2); // source
  Prg.AsmPush_REG(Reg);

  EmitLoadAddress(Reg, SymbolRec1); // source
  Prg.AsmPush_REG(Reg);

  EmitGet_REG(Reg, SymbolTable[SubId]);
  Prg.AsmCall_REG(Reg);

  FreeReg(Reg);
end;

procedure TEmitter.EmitOP_GE_SHORTSTRING;
var
  SubId, Reg: Integer;
begin
  EmitPCodeOperator;

  SubId := Id_ShortStringGreaterThanOrEqual;

  Reg := GetReg;

  EmitLoadAddress(Reg, SymbolRecR); // dest
  Prg.AsmPush_REG(Reg);

  EmitLoadAddress(Reg, SymbolRec2); // source
  Prg.AsmPush_REG(Reg);

  EmitLoadAddress(Reg, SymbolRec1); // source
  Prg.AsmPush_REG(Reg);

  EmitGet_REG(Reg, SymbolTable[SubId]);
  Prg.AsmCall_REG(Reg);

  FreeReg(Reg);
end;

procedure TEmitter.EmitOP_LT_SHORTSTRING;
var
  SubId, Reg: Integer;
begin
  EmitPCodeOperator;

  SubId := Id_ShortStringLessThan;

  Reg := GetReg;

  EmitLoadAddress(Reg, SymbolRecR); // dest
  Prg.AsmPush_REG(Reg);

  EmitLoadAddress(Reg, SymbolRec2); // source
  Prg.AsmPush_REG(Reg);

  EmitLoadAddress(Reg, SymbolRec1); // source
  Prg.AsmPush_REG(Reg);

  EmitGet_REG(Reg, SymbolTable[SubId]);
  Prg.AsmCall_REG(Reg);

  FreeReg(Reg);
end;

procedure TEmitter.EmitOP_LE_SHORTSTRING;
var
  SubId, Reg: Integer;
begin
  EmitPCodeOperator;

  SubId := Id_ShortStringLessThanOrEqual;

  Reg := GetReg;

  EmitLoadAddress(Reg, SymbolRecR); // dest
  Prg.AsmPush_REG(Reg);

  EmitLoadAddress(Reg, SymbolRec2); // source
  Prg.AsmPush_REG(Reg);

  EmitLoadAddress(Reg, SymbolRec1); // source
  Prg.AsmPush_REG(Reg);

  EmitGet_REG(Reg, SymbolTable[SubId]);
  Prg.AsmCall_REG(Reg);

  FreeReg(Reg);
end;

procedure TEmitter.EmitOP_GT_WIDESTRING;
var
  SubId, Reg: Integer;
begin
  EmitPCodeOperator;

  SubId := Id_WideStringGreaterThan;

  Reg := GetReg;

  EmitLoadAddress(Reg, SymbolRecR); // dest
  Prg.AsmPush_REG(Reg);

  EmitLoadAddress(Reg, SymbolRec2); // source
  Prg.AsmPush_REG(Reg);

  EmitLoadAddress(Reg, SymbolRec1); // source
  Prg.AsmPush_REG(Reg);

  EmitGet_REG(Reg, SymbolTable[SubId]);
  Prg.AsmCall_REG(Reg);

  FreeReg(Reg);
end;

procedure TEmitter.EmitOP_GT_UNICSTRING;
var
  SubId, Reg: Integer;
begin
  EmitPCodeOperator;

  SubId := Id_UnicStringGreaterThan;

  Reg := GetReg;

  EmitLoadAddress(Reg, SymbolRecR); // dest
  Prg.AsmPush_REG(Reg);

  EmitLoadAddress(Reg, SymbolRec2); // source
  Prg.AsmPush_REG(Reg);

  EmitLoadAddress(Reg, SymbolRec1); // source
  Prg.AsmPush_REG(Reg);

  EmitGet_REG(Reg, SymbolTable[SubId]);
  Prg.AsmCall_REG(Reg);

  FreeReg(Reg);
end;

procedure TEmitter.EmitOP_GE_WIDESTRING;
var
  SubId, Reg: Integer;
begin
  EmitPCodeOperator;

  SubId := Id_WideStringGreaterThanOrEqual;

  Reg := GetReg;

  EmitLoadAddress(Reg, SymbolRecR); // dest
  Prg.AsmPush_REG(Reg);

  EmitLoadAddress(Reg, SymbolRec2); // source
  Prg.AsmPush_REG(Reg);

  EmitLoadAddress(Reg, SymbolRec1); // source
  Prg.AsmPush_REG(Reg);

  EmitGet_REG(Reg, SymbolTable[SubId]);
  Prg.AsmCall_REG(Reg);

  FreeReg(Reg);
end;

procedure TEmitter.EmitOP_GE_UNICSTRING;
var
  SubId, Reg: Integer;
begin
  EmitPCodeOperator;

  SubId := Id_UnicStringGreaterThanOrEqual;

  Reg := GetReg;

  EmitLoadAddress(Reg, SymbolRecR); // dest
  Prg.AsmPush_REG(Reg);

  EmitLoadAddress(Reg, SymbolRec2); // source
  Prg.AsmPush_REG(Reg);

  EmitLoadAddress(Reg, SymbolRec1); // source
  Prg.AsmPush_REG(Reg);

  EmitGet_REG(Reg, SymbolTable[SubId]);
  Prg.AsmCall_REG(Reg);

  FreeReg(Reg);
end;

procedure TEmitter.EmitOP_LT_WIDESTRING;
var
  SubId, Reg: Integer;
begin
  EmitPCodeOperator;

  SubId := Id_WideStringLessThan;

  Reg := GetReg;

  EmitLoadAddress(Reg, SymbolRecR); // dest
  Prg.AsmPush_REG(Reg);

  EmitLoadAddress(Reg, SymbolRec2); // source
  Prg.AsmPush_REG(Reg);

  EmitLoadAddress(Reg, SymbolRec1); // source
  Prg.AsmPush_REG(Reg);

  EmitGet_REG(Reg, SymbolTable[SubId]);
  Prg.AsmCall_REG(Reg);

  FreeReg(Reg);
end;

procedure TEmitter.EmitOP_LT_UNICSTRING;
var
  SubId, Reg: Integer;
begin
  EmitPCodeOperator;

  SubId := Id_UnicStringLessThan;

  Reg := GetReg;

  EmitLoadAddress(Reg, SymbolRecR); // dest
  Prg.AsmPush_REG(Reg);

  EmitLoadAddress(Reg, SymbolRec2); // source
  Prg.AsmPush_REG(Reg);

  EmitLoadAddress(Reg, SymbolRec1); // source
  Prg.AsmPush_REG(Reg);

  EmitGet_REG(Reg, SymbolTable[SubId]);
  Prg.AsmCall_REG(Reg);

  FreeReg(Reg);
end;

procedure TEmitter.EmitOP_LE_WIDESTRING;
var
  SubId, Reg: Integer;
begin
  EmitPCodeOperator;

  SubId := Id_WideStringLessThanOrEqual;

  Reg := GetReg;

  EmitLoadAddress(Reg, SymbolRecR); // dest
  Prg.AsmPush_REG(Reg);

  EmitLoadAddress(Reg, SymbolRec2); // source
  Prg.AsmPush_REG(Reg);

  EmitLoadAddress(Reg, SymbolRec1); // source
  Prg.AsmPush_REG(Reg);

  EmitGet_REG(Reg, SymbolTable[SubId]);
  Prg.AsmCall_REG(Reg);

  FreeReg(Reg);
end;

procedure TEmitter.EmitOP_LE_UNICSTRING;
var
  SubId, Reg: Integer;
begin
  EmitPCodeOperator;

  SubId := Id_UnicStringLessThanOrEqual;

  Reg := GetReg;

  EmitLoadAddress(Reg, SymbolRecR); // dest
  Prg.AsmPush_REG(Reg);

  EmitLoadAddress(Reg, SymbolRec2); // source
  Prg.AsmPush_REG(Reg);

  EmitLoadAddress(Reg, SymbolRec1); // source
  Prg.AsmPush_REG(Reg);

  EmitGet_REG(Reg, SymbolTable[SubId]);
  Prg.AsmCall_REG(Reg);

  FreeReg(Reg);
end;

procedure TEmitter.EmitOP_NE_ANSISTRING;
var
  SubId, Reg: Integer;
begin
  EmitPCodeOperator;

  SubId := Id_AnsiStringNotEquality;

  Reg := GetReg;

  EmitLoadAddress(Reg, SymbolRecR); // dest
  Prg.AsmPush_REG(Reg);

  EmitLoadAddress(Reg, SymbolRec2); // source
  Prg.AsmPush_REG(Reg);

  EmitLoadAddress(Reg, SymbolRec1); // source
  Prg.AsmPush_REG(Reg);

  EmitGet_REG(Reg, SymbolTable[SubId]);
  Prg.AsmCall_REG(Reg);

  FreeReg(Reg);
end;

procedure TEmitter.EmitOP_EQ_SHORTSTRING;
var
  SubId, Reg: Integer;
begin
  EmitPCodeOperator;

  SubId := Id_ShortStringEquality;

  Reg := GetReg;

  EmitLoadAddress(Reg, SymbolRecR); // dest
  Prg.AsmPush_REG(Reg);

  EmitLoadAddress(Reg, SymbolRec2); // source
  Prg.AsmPush_REG(Reg);

  EmitLoadAddress(Reg, SymbolRec1); // source
  Prg.AsmPush_REG(Reg);

  EmitGet_REG(Reg, SymbolTable[SubId]);
  Prg.AsmCall_REG(Reg);

  FreeReg(Reg);
end;

procedure TEmitter.EmitOP_NE_SHORTSTRING;
var
  SubId, Reg: Integer;
begin
  EmitPCodeOperator;

  SubId := Id_ShortStringNotEquality;

  Reg := GetReg;

  EmitLoadAddress(Reg, SymbolRecR); // dest
  Prg.AsmPush_REG(Reg);

  EmitLoadAddress(Reg, SymbolRec2); // source
  Prg.AsmPush_REG(Reg);

  EmitLoadAddress(Reg, SymbolRec1); // source
  Prg.AsmPush_REG(Reg);

  EmitGet_REG(Reg, SymbolTable[SubId]);
  Prg.AsmCall_REG(Reg);

  FreeReg(Reg);
end;

procedure TEmitter.EmitOP_EQ_WIDESTRING;
var
  SubId, Reg: Integer;
begin
  EmitPCodeOperator;

  SubId := Id_WideStringEquality;

  Reg := GetReg;

  EmitLoadAddress(Reg, SymbolRecR); // dest
  Prg.AsmPush_REG(Reg);

  EmitLoadAddress(Reg, SymbolRec2); // source
  Prg.AsmPush_REG(Reg);

  EmitLoadAddress(Reg, SymbolRec1); // source
  Prg.AsmPush_REG(Reg);

  EmitGet_REG(Reg, SymbolTable[SubId]);
  Prg.AsmCall_REG(Reg);

  FreeReg(Reg);
end;

procedure TEmitter.EmitOP_EQ_UNICSTRING;
var
  SubId, Reg: Integer;
begin
  EmitPCodeOperator;

  SubId := Id_UnicStringEquality;

  Reg := GetReg;

  EmitLoadAddress(Reg, SymbolRecR); // dest
  Prg.AsmPush_REG(Reg);

  EmitLoadAddress(Reg, SymbolRec2); // source
  Prg.AsmPush_REG(Reg);

  EmitLoadAddress(Reg, SymbolRec1); // source
  Prg.AsmPush_REG(Reg);

  EmitGet_REG(Reg, SymbolTable[SubId]);
  Prg.AsmCall_REG(Reg);

  FreeReg(Reg);
end;

procedure TEmitter.EmitOP_NE_WIDESTRING;
var
  SubId, Reg: Integer;
begin
  EmitPCodeOperator;

  SubId := Id_WideStringNotEquality;

  Reg := GetReg;

  EmitLoadAddress(Reg, SymbolRecR); // dest
  Prg.AsmPush_REG(Reg);

  EmitLoadAddress(Reg, SymbolRec2); // source
  Prg.AsmPush_REG(Reg);

  EmitLoadAddress(Reg, SymbolRec1); // source
  Prg.AsmPush_REG(Reg);

  EmitGet_REG(Reg, SymbolTable[SubId]);
  Prg.AsmCall_REG(Reg);

  FreeReg(Reg);
end;

procedure TEmitter.EmitOP_NE_UNICSTRING;
var
  SubId, Reg: Integer;
begin
  EmitPCodeOperator;

  SubId := Id_UnicStringNotEquality;

  Reg := GetReg;

  EmitLoadAddress(Reg, SymbolRecR); // dest
  Prg.AsmPush_REG(Reg);

  EmitLoadAddress(Reg, SymbolRec2); // source
  Prg.AsmPush_REG(Reg);

  EmitLoadAddress(Reg, SymbolRec1); // source
  Prg.AsmPush_REG(Reg);

  EmitGet_REG(Reg, SymbolTable[SubId]);
  Prg.AsmCall_REG(Reg);

  FreeReg(Reg);
end;

procedure TEmitter.EmitOP_VARARRAY_GET;
var
  SubId, Reg: Integer;
begin
  EmitPCodeOperator;

  SubId := 0;
  case R.Arg2 of
    1: SubId := Id_VarArrayGet1;
    2: SubId := Id_VarArrayGet2;
    3: SubId := Id_VarArrayGet3;
  else
    RaiseError(errInternalError, []);
  end;

  Reg := GetReg;

  EmitLoadAddress(Reg, SymbolRecR); // dest
  Prg.AsmPush_REG(Reg);

  EmitLoadAddress(Reg, SymbolRec1); // source
  Prg.AsmPush_REG(Reg);

  EmitGet_REG(Reg, SymbolTable[SubId]);
  Prg.AsmCall_REG(Reg);

  FreeReg(Reg);
end;

procedure TEmitter.EmitOP_VARARRAY_PUT;
var
  SubId, Reg: Integer;
begin
  EmitPCodeOperator;

  SubId := 0;
  case R.Arg2 of
    1: SubId := Id_VarArrayPut1;
    2: SubId := Id_VarArrayPut2;
    3: SubId := Id_VarArrayPut3;
  else
    RaiseError(errInternalError, []);
  end;

  Reg := GetReg;

  EmitLoadAddress(Reg, SymbolRecR); // value
  Prg.AsmPush_REG(Reg);

  EmitLoadAddress(Reg, SymbolRec1); // source
  Prg.AsmPush_REG(Reg);

  EmitGet_REG(Reg, SymbolTable[SubId]);
  Prg.AsmCall_REG(Reg);

  FreeReg(Reg);
end;

procedure TEmitter.EmitOP_GENERAL_GET;
var
  Reg, SubId, PropNameId: Integer;
  Code: TCode;
  I, NP: Integer;
  L: TIntegerList;
begin
  EmitPCodeOperator;

  SubId := JS_GetGenericPropertyId;

  PropNameId := SymbolRec2.Id;
  Code := TKernel(kernel).Code;
  L := TIntegerList.Create;
  for I:=Code.N downto 1 do
    if Code.Records[I].Op = OP_OLE_PARAM then
      if Code.Records[I].Res = PropNameId then
        L.Insert(0, Code.Records[I].Arg1);

  Reg := GetReg;

  NP := L.Count;

  for I:=NP - 1 downto 0 do
  begin
    EmitLoadAddress(Reg, GetSymbolRec(L[I]));
    Prg.AsmPush_REG(Reg);
  end;

  EmitLoadAddress(Reg, SymbolRecR); // result
  Prg.AsmPush_REG(Reg);

  Prg.AsmPush_Imm(NP);

  EmitGet_REG(Reg, SymbolRec2); // prop name - pchar
  Prg.AsmPush_REG(Reg);

  EmitLoadAddress(Reg, SymbolRec1); // object
  Prg.AsmPush_REG(Reg);

  EmitGet_REG(Reg, SymbolTable[SubId]);
  Prg.AsmCall_REG(Reg);

  FreeReg(Reg);
end;

procedure TEmitter.EmitOP_GENERAL_PUT;
var
  Reg, SubId, PropNameId: Integer;
  Code: TCode;
  I, NP: Integer;
  L: TIntegerList;
begin
  EmitPCodeOperator;

  SubId := JS_PutGenericPropertyId;

  PropNameId := SymbolRec2.Id;
  Code := TKernel(kernel).Code;
  L := TIntegerList.Create;
  for I:=Code.N downto 1 do
    if Code.Records[I].Op = OP_OLE_PARAM then
      if Code.Records[I].Res = PropNameId then
        L.Insert(0, Code.Records[I].Arg1);

  Reg := GetReg;

  NP := L.Count;

  for I:=NP - 1 downto 0 do
  begin
    EmitLoadAddress(Reg, GetSymbolRec(L[I]));
    Prg.AsmPush_REG(Reg);
  end;

  EmitLoadAddress(Reg, SymbolRecR); // value
  Prg.AsmPush_REG(Reg);

  Prg.AsmPush_Imm(NP);

  EmitGet_REG(Reg, SymbolRec2); // prop name - pchar
  Prg.AsmPush_REG(Reg);

  EmitLoadAddress(Reg, SymbolRec1); // object
  Prg.AsmPush_REG(Reg);

  EmitGet_REG(Reg, SymbolTable[SubId]);
  Prg.AsmCall_REG(Reg);

  FreeReg(Reg);
end;

procedure TEmitter.EmitOP_OLE_GET;
var
  Reg, SubId, PropNameId: Integer;
  Code: TCode;
  I: Integer;
  L: TIntegerList;
begin
  if R.Language = JS_LANGUAGE then
  begin
    EmitOP_GENERAL_GET;
    Exit;
  end;

  EmitPCodeOperator;

  SubId := LookUp(_strGetOLEProperty);
  if SubId = 0 then
    RaiseError(errIMPORT_ActiveX, []);

  PropNameId := SymbolRec2.Id;
  Code := TKernel(kernel).Code;
  L := TIntegerList.Create;

  try
    for I:=Code.N downto 1 do
      if Code.Records[I].Op = OP_OLE_PARAM then
        if Code.Records[I].Res = PropNameId then
          L.Insert(0, Code.Records[I].Arg1);

    Reg := GetReg;

    for I:=L.Count - 1 downto 0 do
    begin
      EmitLoadAddress(Reg, GetSymbolRec(L[I]));
      Prg.AsmPush_REG(Reg);
    end;

    Prg.AsmPush_Imm(L.Count);

    EmitLoadAddress(Reg, SymbolRecR); // result
    Prg.AsmPush_REG(Reg);

    EmitGet_REG(Reg, SymbolRec2); // prop name - pchar
    Prg.AsmPush_REG(Reg);

    EmitLoadAddress(Reg, SymbolRec1); // object
    Prg.AsmPush_REG(Reg);

    EmitGet_REG(Reg, SymbolTable[SubId]);
    Prg.AsmCall_REG(Reg);

    FreeReg(Reg);
  finally
    L.Free;
  end;
end;

procedure TEmitter.EmitOP_OLE_SET;
var
  Reg, SubId, PropNameId: Integer;
  Code: TCode;
  I: Integer;
  L: TIntegerList;
begin
  if R.Language = JS_LANGUAGE then
  begin
    EmitOP_GENERAL_PUT;
    Exit;
  end;

  EmitPCodeOperator;

  SubId := LookUp(_strSetOLEProperty);
  if SubId = 0 then
    RaiseError(errIMPORT_ActiveX, []);

  PropNameId := SymbolRec2.Id;
  Code := TKernel(kernel).Code;
  L := TIntegerList.Create;

  try
    for I:=Code.N downto 1 do
      if Code.Records[I].Op = OP_OLE_PARAM then
        if Code.Records[I].Res = PropNameId then
          L.Insert(0, Code.Records[I].Arg1);

    Reg := GetReg;

    for I:=L.Count - 1 downto 0 do
    begin
      EmitLoadAddress(Reg, GetSymbolRec(L[I]));
      Prg.AsmPush_REG(Reg);
    end;

    Prg.AsmPush_Imm(L.Count);

    EmitLoadAddress(Reg, SymbolRecR); // value
    Prg.AsmPush_REG(Reg);

    EmitGet_REG(Reg, SymbolRec2); // prop name - pchar
    Prg.AsmPush_REG(Reg);

    EmitLoadAddress(Reg, SymbolRec1); // object
    Prg.AsmPush_REG(Reg);

    EmitGet_REG(Reg, SymbolTable[SubId]);
    Prg.AsmCall_REG(Reg);

    FreeReg(Reg);

  finally
    L.Free;
  end;
end;

procedure TEmitter.EmitOP_OLE_PARAM;
begin
  EmitPCodeOperator;
end;

procedure TEmitter.EmitOP_ANSISTRING_CLR;
var
  SubId, Reg: Integer;
begin
  EmitPCodeOperator;

  SubId := Id_AnsiStringClr;

  Reg := GetReg;

  EmitLoadAddress(Reg, SymbolRec1); // string source
  Prg.AsmPush_REG(Reg);

  EmitGet_REG(Reg, SymbolTable[SubId]);
  Prg.AsmCall_REG(Reg);

  FreeReg(Reg);
end;

procedure TEmitter.EmitOP_SET_LENGTH;
var
  SubId, Reg, FinTypeId, T1, L1: Integer;
begin
  EmitPCodeOperator;
  Emit_PUSH_REGS;

  L1 := 0;
  FinTypeId := SymbolRec1.FinalTypeId;
  case FinTypeId of
    typeANSISTRING: SubId := Id_SetStringLength;
    typeWIDESTRING: SubId := Id_SetWideStringLength;
    typeUNICSTRING: SubId := Id_SetUnicStringLength;
    typeSHORTSTRING:
    begin
      SubId := Id_SetShortStringLength;
      T1 := SymbolRec1.TypeID;
      L1 := GetSymbolRec(T1).Count;
      if T1 = typeSHORTSTRING then
        L1 := 255;
    end;
    else
    begin
      SubId := 0;
      RaiseError(errInternalError, []);
    end;
  end;

  Reg := GetReg;

  EmitLoadIntVal(Reg, SymbolRec2); // L
  Prg.AsmPush_REG(Reg);

  if FinTypeId = typeSHORTSTRING then
    Prg.AsmPush_Imm(L1);

  EmitLoadAddress(Reg, SymbolRec1); // string source
  Prg.AsmPush_REG(Reg);

  EmitGet_REG(Reg, SymbolTable[SubId]);
  Prg.AsmCall_REG(Reg);

  FreeReg(Reg);
  Emit_POP_REGS;
end;

procedure TEmitter.EmitOP_WIDESTRING_CLR;
var
  SubId, Reg: Integer;
begin
  EmitPCodeOperator;

  SubId := Id_WideStringClr;

  Reg := GetReg;

  EmitLoadAddress(Reg, SymbolRec1); // string source
  Prg.AsmPush_REG(Reg);

  EmitGet_REG(Reg, SymbolTable[SubId]);
  Prg.AsmCall_REG(Reg);

  FreeReg(Reg);
end;

procedure TEmitter.EmitOP_UNICSTRING_CLR;
var
  SubId, Reg: Integer;
begin
  EmitPCodeOperator;

  SubId := Id_UnicStringClr;

  Reg := GetReg;

  EmitLoadAddress(Reg, SymbolRec1); // string source
  Prg.AsmPush_REG(Reg);

  EmitGet_REG(Reg, SymbolTable[SubId]);
  Prg.AsmCall_REG(Reg);

  FreeReg(Reg);
end;

procedure TEmitter.EmitOP_INTERFACE_CLR;
var
  SubId, Reg: Integer;
begin
  EmitPCodeOperator;

  SubId := Id_InterfaceClr;

  Reg := GetReg;

  EmitLoadAddress(Reg, SymbolRec1); // interface source
  Prg.AsmPush_REG(Reg);

  EmitGet_REG(Reg, SymbolTable[SubId]);
  Prg.AsmCall_REG(Reg);

  FreeReg(Reg);
end;

procedure TEmitter.EmitOP_CLASS_CLR;
var
  SubId, Reg: Integer;
begin
  EmitPCodeOperator;

  SubId := Id_ClassClr;

  Reg := GetReg;

  EmitLoadAddress(Reg, SymbolRec1); // object source
  Prg.AsmPush_REG(Reg);

  EmitGet_REG(Reg, SymbolTable[SubId]);
  Prg.AsmCall_REG(Reg);

  FreeReg(Reg);
end;

procedure TEmitter.EmitOP_SHORTSTRING_HIGH;
var
  SubId, Reg: Integer;
begin
  EmitPCodeOperator;

  SubId := Id_ShortstringHigh;

  Reg := GetReg;

  EmitLoadAddress(Reg, SymbolRecR); // dest
  Prg.AsmPush_REG(Reg);

  EmitLoadAddress(Reg, SymbolRec1); // source
  Prg.AsmPush_REG(Reg);

  EmitGet_REG(Reg, SymbolTable[SubId]);
  Prg.AsmCall_REG(Reg);

  FreeReg(Reg);
end;

procedure TEmitter.EmitOP_VARIANT_CLR;
var
  SubId, Reg: Integer;
begin
  EmitPCodeOperator;

  SubId := Id_VariantClr;

  Reg := GetReg;

  EmitLoadAddress(Reg, SymbolRec1);
  Prg.AsmPush_REG(Reg);

  EmitGet_REG(Reg, SymbolTable[SubId]);
  Prg.AsmCall_REG(Reg);

  FreeReg(Reg);
end;

procedure TEmitter.EmitOP_DYNARRAY_CLR;
var
  SubId, Reg,
  ArrayTypeId, ElSize, ElTypeId, ElFinalTypeId: Integer;
begin
  EmitPCodeOperator;

  SubId := Id_DynarrayClr;

  Reg := GetReg;

  ArrayTypeId := SymbolRec1.TerminalTypeId;
  ElTypeId := GetSymbolRec(ArrayTypeId).PatternId;
  ElFinalTypeId := GetSymbolRec(ElTypeId).FinalTypeId;
  ElSize := SymbolTable[ElTypeId].Size;

  Prg.AsmPush_Imm(ElSize);
  Prg.AsmPush_Imm(ElTypeId);
  Prg.AsmPush_Imm(ElFinalTypeId);

  EmitLoadAddress(Reg, SymbolRec1); // source
  Prg.AsmPush_REG(Reg);

  EmitGet_REG(Reg, SymbolTable[SubId]);
  Prg.AsmCall_REG(Reg);

  FreeReg(Reg);
end;

procedure TEmitter.EmitOP_CREATE_EMPTY_DYNARRAY;
var
  SubId, Reg: Integer;
begin
  EmitPCodeOperator;

  SubId := Id_CreateEmptyDynarray;

  Reg := GetReg;

  EmitLoadAddress(Reg, SymbolRec1); // source
  Prg.AsmPush_REG(Reg);

  EmitGet_REG(Reg, SymbolTable[SubId]);
  Prg.AsmCall_REG(Reg);

  FreeReg(Reg);
end;

procedure TEmitter.EmitOP_DYNARRAY_HIGH;
var
  SubId, Reg: Integer;
begin
  EmitPCodeOperator;

  SubId := LookUp(_strDynarrayHigh);

  Reg := GetReg;

  EmitLoadAddress(Reg, SymbolRecR); // dest
  Prg.AsmPush_REG(Reg);

  EmitLoadAddress(Reg, SymbolRec1); // source
  Prg.AsmPush_REG(Reg);

  EmitGet_REG(Reg, SymbolTable[SubId]);
  Prg.AsmCall_REG(Reg);

  FreeReg(Reg);
end;

procedure TEmitter.EmitOP_DYNARRAY_ASSIGN;
var
  SubId, Reg,
  ArrayTypeId, ElSize, ElTypeId, ElFinalTypeId: Integer;
begin
  EmitPCodeOperator;

  SubId := Id_DynarrayAssign;

  Reg := GetReg;

  ArrayTypeId := SymbolRec1.TerminalTypeId;
  ElTypeId := GetSymbolRec(ArrayTypeId).PatternId;
  ElFinalTypeId := GetSymbolRec(ElTypeId).FinalTypeId;
  ElSize := SymbolTable[ElTypeId].Size;

  Prg.AsmPush_Imm(ElSize);
  Prg.AsmPush_Imm(ElTypeId);
  Prg.AsmPush_Imm(ElFinalTypeId);

  EmitLoadAddress(Reg, SymbolRec1); // dest
  Prg.AsmPush_REG(Reg);

  EmitLoadAddress(Reg, SymbolRec2); // source
  Prg.AsmPush_REG(Reg);

  EmitGet_REG(Reg, SymbolTable[SubId]);
  Prg.AsmCall_REG(Reg);

  FreeReg(Reg);
end;

procedure TEmitter.EmitOP_ASSIGN_TVarRec;
var
  SubId, Reg,
  FinalTypeId: Integer;
begin
  EmitPCodeOperator;

  SubId := Id_AssignTVarRec;

  Reg := GetReg;

  FinalTypeId := SymbolRec2.FinalTypeId;
  if SymbolRec2.HasPAnsiCharType then
  begin
    if SymbolRec2.Kind <> KindCONST then
      FinalTypeId := typeANSISTRING
    else
      FinalTypeId := typePANSICHAR;
  end
  else if SymbolRec2.HasPWideCharType then
  begin
    if SymbolRec2.Kind <> KindCONST then
      FinalTypeId := typeUNICSTRING
    else
      FinalTypeId := typePWIDECHAR;
  end;

  Prg.AsmPush_Imm(FinalTypeId);

  EmitLoadAddress(Reg, SymbolRec1); // dest
  Prg.AsmPush_REG(Reg);

  EmitLoadAddress(Reg, SymbolRec2); // source
  Prg.AsmPush_REG(Reg);

  EmitGet_REG(Reg, SymbolTable[SubId]);
  Prg.AsmCall_REG(Reg);

  FreeReg(Reg);
end;

procedure TEmitter.EmitOP_STRUCTURE_CLR;
var
  SubId, Reg, TypeId, I, S, FT,
  ArrayTypeId, ElTypeId, ElFinalTypeId, ElSize, DestructorId: Integer;
  L, T: TIntegerList;
begin
  EmitPCodeOperator;

  TypeId := SymbolRec1.TerminalTypeId;

  if TKernel(kernel).SymbolTable[TypeId].FinalTypeId = typeRECORD then
  begin
    DestructorId := TKernel(kernel).SymbolTable.FindDestructorId(TypeId);
    if DestructorId <> 0 then
    begin
      if GetSymbolRec(DestructorId).Host then
      begin
        Reg := _EBX;
        EmitGet_REG(Reg, GetSymbolRec(DestructorId));
        Prg.AsmCall_REG(Reg);
      end
      else
      begin
        EmitLoadAddress(_EAX, SymbolRec1);

        Reg := _EBX;
        Prg.AsmMovREG_REG(Reg, _EDI);
        Prg.AsmAddREG_Imm(Reg, 0);
        Prg.Top.SaveSubId := DestructorId;
        List2.Add(Prg.Top);
        Prg.AsmCall_REG(Reg);
      end;
    end;
  end;

  L := TKernel(kernel).SymbolTable.GetShiftsOfDynamicFields(TypeId);
  T := TKernel(kernel).SymbolTable.GetTypesOfDynamicFields(TypeId);

  if T.Count <> L.Count then
    RaiseError(errInternalError, []);

  try
    Reg := GetReg;

    for I:=0 to L.Count - 1 do
    begin
      S := L[I];

      FT := GetSymbolRec(T[I]).FinalTypeId;

      SubId := 0;
      case FT of
        typeANSISTRING: SubId := Id_AnsiStringClr;
        typeWIDESTRING: SubId := Id_WideStringClr;
        typeUNICSTRING: SubId := Id_UnicStringClr;
        typeVARIANT, typeOLEVARIANT: SubId := Id_VariantClr;
        typeDYNARRAY: SubId := Id_DynarrayClr;
        typeINTERFACE: SubId := Id_InterfaceClr;
      else
        RaiseError(errInternalError, []);
      end;

      if FT = typeDYNARRAY then
      begin
        ArrayTypeId := T[I];
        ElTypeId := GetSymbolRec(ArrayTypeId).PatternId;
        ElFinalTypeId := GetSymbolRec(ElTypeId).FinalTypeId;
        ElSize := SymbolTable[ElTypeId].Size;

        Prg.AsmPush_Imm(ElSize);
        Prg.AsmPush_Imm(ElTypeId);
        Prg.AsmPush_Imm(ElFinalTypeId);
      end;

      EmitLoadAddress(Reg, SymbolRec1);
      Prg.AsmAddREG_Imm(Reg, S);
      Prg.AsmPush_REG(Reg);

      EmitGet_REG(Reg, SymbolTable[SubId]);
      Prg.AsmCall_REG(Reg);
    end;

    FreeReg(Reg);
  finally
    L.Free;
    T.Free;
  end;
end;

procedure TEmitter.EmitOP_STRUCTURE_ADDREF;
var
  SubId, Reg, TypeId, I, S, FT: Integer;
  L, T: TIntegerList;
begin
  EmitPCodeOperator;

  TypeId := SymbolRec1.TerminalTypeId;
  L := TKernel(kernel).SymbolTable.GetShiftsOfDynamicFields(TypeId);
  T := TKernel(kernel).SymbolTable.GetTypesOfDynamicFields(TypeId);

  if T.Count <> L.Count then
    RaiseError(errInternalError, []);

  try
    Reg := GetReg;

    for I:=0 to L.Count - 1 do
    begin
      S := L[I];

      FT := GetSymbolRec(T[I]).FinalTypeId;

      SubId := 0;
      case FT of
        typeANSISTRING: SubId := Id_StringAddRef;
        typeVARIANT, typeOLEVARIANT: SubId := Id_VariantAddRef;
        typeDYNARRAY: SubId := Id_DynarrayAddRef;
        typeINTERFACE: SubId := Id_InterfaceAddRef;
      else
        RaiseError(errInternalError, []);
      end;

      EmitLoadAddress(Reg, SymbolRec1);
      Prg.AsmAddREG_Imm(Reg, S);
      Prg.AsmPush_REG(Reg);

      EmitGet_REG(Reg, SymbolTable[SubId]);
      Prg.AsmCall_REG(Reg);
    end;

    FreeReg(Reg);
  finally
    L.Free;
    T.Free;
  end;
end;

procedure TEmitter.EmitOP_PRINT_EX;
var
  Reg, SubId, L, FT, K: Integer;
begin
  EmitPCodeOperator;

  SubId := Id_PrintEx;
  Reg := GetReg;

  L := R.Res;
  if L > 0 then
  begin
    if GetSymbolRec(L).Kind = KindCONST then
      Prg.AsmPush_Imm(Cardinal(GetSymbolRec(L).Value))
    else
    begin
      EmitLoadIntVal(Reg, GetSymbolRec(L));
      Prg.AsmPush_REG(Reg);
    end;
  end
  else
    Prg.AsmPush_Imm(0);

  L := R.Arg2;
  if L > 0 then
  begin
    if GetSymbolRec(L).Kind = KindCONST then
      Prg.AsmPush_Imm(Cardinal(GetSymbolRec(L).Value))
    else
    begin
      EmitLoadIntVal(Reg, GetSymbolRec(L));
      Prg.AsmPush_REG(Reg);
    end;
  end
  else
    Prg.AsmPush_Imm(0);

  if SymbolRec1.HasPAnsiCharType then
    FT := typePANSICHAR
  else if SymbolRec1.HasPWideCharType then
    FT := typePWIDECHAR
  else
    FT := SymbolRec1.FinalTypeId;

  K := SymbolRec1.Kind;

  Prg.AsmPush_Imm(FT);
  Prg.AsmPush_Imm(K);

  if K = KindCONST then
  begin
    if FT = typeINT64 then
    begin
      Prg.AsmPush_Imm(ImmValue1);
    end
    else if FT in OrdinalTypes then
      Prg.AsmPush_Imm(ImmValue1)
    else if FT = typePANSICHAR then
    begin
      EmitGet_REG(Reg, SymbolRec1); // pchar source
      Prg.AsmPush_REG(Reg);
    end
    else if FT = typePWIDECHAR then
    begin
      EmitGet_REG(Reg, SymbolRec1); // pchar source
      Prg.AsmPush_REG(Reg);
    end
    else
    begin
      EmitLoadAddress(Reg, SymbolRec1); // value
      Prg.AsmPush_REG(Reg);
    end;
  end
  else
  begin
    EmitLoadAddress(Reg, SymbolRec1); // value
    Prg.AsmPush_REG(Reg);
  end;

  Prg.AsmMovREG_REG(Reg, _ESI);
  Prg.AsmAddREG_Imm(Reg, H_SelfPtr);
  Prg.AsmMovREG32_REGPtr(Reg, Reg); // load TProgram.Self
  Prg.AsmPush_REG(Reg);

  EmitGet_REG(Reg, SymbolTable[SubId]);
  Prg.AsmCall_REG(Reg);

  FreeReg(Reg);
end;

procedure TEmitter.EmitOP_PUSH_CONTEXT;
var
  SubId, Reg: Integer;
begin
  SubId := Id_PushContext;

  EmitPCodeOperator;

  Reg := GetReg;

  EmitLoadAddress(Reg, SymbolRec1); // instance
  Prg.AsmPush_REG(Reg);

  Prg.AsmMovREG_REG(Reg, _ESI);
  Prg.AsmAddREG_Imm(Reg, H_SelfPtr);
  Prg.AsmMovREG32_REGPtr(Reg, Reg); // load TProgram.Self
  Prg.AsmPush_REG(Reg);

  EmitGet_REG(Reg, SymbolTable[SubId]);
  Prg.AsmCall_REG(Reg);

  FreeReg(Reg);
end;

procedure TEmitter.EmitOP_FIND_CONTEXT;
var
  SubId, Reg: Integer;
begin
  SubId := Id_FindContext;

  EmitPCodeOperator;

  Reg := GetReg;

  EmitLoadAddress(Reg, SymbolRecR); // (var) result
  Prg.AsmPush_REG(Reg);

  Prg.AsmPush_Imm(SymbolRec2.FinalTypeId);

  EmitLoadAddress(Reg, SymbolRec2); // alt
  Prg.AsmPush_REG(Reg);

  EmitGet_REG(Reg, SymbolRec1); // prop name - pchar
  Prg.AsmPush_REG(Reg);

  Prg.AsmMovREG_REG(Reg, _ESI);
  Prg.AsmAddREG_Imm(Reg, H_SelfPtr);
  Prg.AsmMovREG32_REGPtr(Reg, Reg); // load TProgram.Self
  Prg.AsmPush_REG(Reg);

  EmitGet_REG(Reg, SymbolTable[SubId]);
  Prg.AsmCall_REG(Reg);

  FreeReg(Reg);
end;

procedure TEmitter.EmitOP_FIND_JS_FUNC;
var
  SubId, Reg: Integer;
begin
  SubId := JS_FindFuncId;

  EmitPCodeOperator;

  Reg := GetReg;

  EmitLoadAddress(Reg, SymbolRecR); // (var) result
  Prg.AsmPush_REG(Reg);

  EmitLoadAddress(Reg, SymbolRec2); // alt
  Prg.AsmPush_REG(Reg);

  EmitGet_REG(Reg, SymbolRec1); // prop name - pchar
  Prg.AsmPush_REG(Reg);

  Prg.AsmMovREG_REG(Reg, _ESI);
  Prg.AsmAddREG_Imm(Reg, H_SelfPtr);
  Prg.AsmMovREG32_REGPtr(Reg, Reg); // load TProgram.Self
  Prg.AsmPush_REG(Reg);

  EmitGet_REG(Reg, SymbolTable[SubId]);
  Prg.AsmCall_REG(Reg);

  FreeReg(Reg);
end;

procedure TEmitter.EmitOP_POP_CONTEXT;
var
  SubId, Reg: Integer;
begin
  SubId := Id_PopContext;

  EmitPCodeOperator;

  Reg := GetReg;

  Prg.AsmMovREG_REG(Reg, _ESI);
  Prg.AsmAddREG_Imm(Reg, H_SelfPtr);
  Prg.AsmMovREG32_REGPtr(Reg, Reg); // load TProgram.Self
  Prg.AsmPush_REG(Reg);

  EmitGet_REG(Reg, SymbolTable[SubId]);
  Prg.AsmCall_REG(Reg);

  FreeReg(Reg);
end;

procedure TEmitter.EmitOP_IS;
var
  SubId, Reg, TypeId: Integer;
begin
  SubId := LookUp(_strIs);

  EmitPCodeOperator;

  Reg := GetReg;

  EmitLoadAddress(Reg, SymbolRecR); // result
  Prg.AsmPush_REG(Reg);

  EmitLoadIntVal(Reg, SymbolRec1); // instance
  Prg.AsmPush_REG(Reg);

  TypeId := SymbolRec2.TerminalTypeId;
  EmitLoadIntVal(Reg, GetSymbolRec(TypeId + 1)); // instance
  Prg.AsmPush_REG(Reg);

  EmitGet_REG(Reg, SymbolTable[SubId]);
  Prg.AsmCall_REG(Reg);

  FreeReg(Reg);
end;

procedure TEmitter.EmitOP_GET_PROG;
var
  Reg: Integer;
begin
  EmitPCodeOperator;

  Reg := GetReg;

  Prg.AsmMovREG_REG(Reg, _ESI);
  Prg.AsmAddREG_Imm(Reg, H_SelfPtr);
  Prg.AsmMovREG32_REGPtr(Reg, Reg); // load TProgram.Self

  EmitSaveIntVal(Reg, SymbolRecR);

  FreeReg(Reg);
end;

procedure TEmitter.EmitOP_TYPEINFO;
var
  SubId, Reg: Integer;
begin
  SubId := Id_TypeInfo;

  EmitPCodeOperator;

  Reg := GetReg;

  EmitLoadAddress(Reg, SymbolRecR); // result
  Prg.AsmPush_REG(Reg);

  EmitGet_REG(Reg, SymbolRec2); // prop name - pchar
  Prg.AsmPush_REG(Reg);

  Prg.AsmMovREG_REG(Reg, _ESI);
  Prg.AsmAddREG_Imm(Reg, H_SelfPtr);
  Prg.AsmMovREG32_REGPtr(Reg, Reg); // load TProgram.Self
  Prg.AsmPush_REG(Reg);

  EmitGet_REG(Reg, SymbolTable[SubId]);
  Prg.AsmCall_REG(Reg);

  FreeReg(Reg);
end;

procedure TEmitter.EmitOP_ONCREATE_OBJECT;
var
  SubId, Reg: Integer;
begin
  SubId := Id_OnCreateObject;

  EmitPCodeOperator;

  Reg := GetReg;

  EmitLoadIntVal(Reg, SymbolRec1); // instance
  Prg.AsmPush_REG(Reg);

  Prg.AsmMovREG_REG(Reg, _ESI);
  Prg.AsmAddREG_Imm(Reg, H_SelfPtr);
  Prg.AsmMovREG32_REGPtr(Reg, Reg); // load TProgram.Self
  Prg.AsmPush_REG(Reg);

  EmitGet_REG(Reg, SymbolTable[SubId]);
  Prg.AsmCall_REG(Reg);

  FreeReg(Reg);
end;

procedure TEmitter.EmitOP_ON_AFTER_OBJECT_CREATION;
var
  SubId, Reg: Integer;
begin
  SubId := Id_OnAfterObjectCreation;

  EmitPCodeOperator;

  Reg := GetReg;

  EmitLoadIntVal(Reg, SymbolRec1); // instance
  Prg.AsmPush_REG(Reg);

  Prg.AsmMovREG_REG(Reg, _ESI);
  Prg.AsmAddREG_Imm(Reg, H_SelfPtr);
  Prg.AsmMovREG32_REGPtr(Reg, Reg); // load TProgram.Self
  Prg.AsmPush_REG(Reg);

  EmitGet_REG(Reg, SymbolTable[SubId]);
  Prg.AsmCall_REG(Reg);

  FreeReg(Reg);
end;

procedure TEmitter.EmitOP_CLASSNAME;
var
  SubId, Reg, TypeId: Integer;
begin
  SubId := Id_ClassName;

  EmitPCodeOperator;

  Reg := GetReg;

  EmitLoadAddress(Reg, SymbolRecR); // result
  Prg.AsmPush_REG(Reg);

  TypeId := SymbolRec1.TerminalTypeId;
  if GetSymbolRec(TypeId).FinalTypeId = typeCLASSREF then
  begin
    TypeId := GetSymbolRec(TypeId).PatternId;
    TypeId := GetSymbolRec(TypeId).TerminalTypeId;
  end;

  EmitLoadIntVal(Reg, GetSymbolRec(TypeId + 1));
  Prg.AsmPush_REG(Reg);

  EmitGet_REG(Reg, SymbolTable[SubId]);
  Prg.AsmCall_REG(Reg);

  FreeReg(Reg);
end;

procedure TEmitter.EmitOP_GET_ANSISTR_PROP;
var
  SubId, Reg, ClassId, PropIndex, Shift: Integer;
begin
  SubId := Id_GetAnsiStrProp;

  EmitPCodeOperator;

  Reg := GetReg;

  EmitLoadAddress(Reg, SymbolRecR); // result
  Prg.AsmPush_REG(Reg);

  EmitLoadIntVal(Reg, SymbolRec1); // instance
  Prg.AsmPush_REG(Reg);

  // push ppi
  PropIndex := SymbolRec2.PropIndex;
  ClassId := GetSymbolRec(SymbolRec1.TerminalHostClassId).Id;
  Shift := GetOffset(GetSymbolRec(ClassId + 1));
  Inc(Shift, (PropIndex + 1) * SizeOf(Pointer));
  Prg.AsmGetREG32_ESIPtr(Reg, Shift);
  Prg.AsmPush_REG(Reg);

  EmitGet_REG(Reg, SymbolTable[SubId]);
  Prg.AsmCall_REG(Reg);

  FreeReg(Reg);
end;

procedure TEmitter.EmitOP_SET_ANSISTR_PROP;
var
  SubId, Reg, PropIndex, ClassId, Shift: Integer;
begin
  SubId := Id_SetAnsiStrProp;

  EmitPCodeOperator;

  Reg := GetReg;

  if SymbolRecR.HasPAnsiCharType then
    EmitGet_REG(Reg, SymbolRecR)
  else
    EmitLoadIntVal(Reg, SymbolRecR); // value
  Prg.AsmPush_REG(Reg);

  EmitLoadIntVal(Reg, SymbolRec1); // instance
  Prg.AsmPush_REG(Reg);

  // push ppi
  PropIndex := SymbolRec2.PropIndex;
  ClassId := GetSymbolRec(SymbolRec1.TerminalHostClassId).Id;
  Shift := GetOffset(GetSymbolRec(ClassId + 1));
  Inc(Shift, (PropIndex + 1) * SizeOf(Pointer));
  Prg.AsmGetREG32_ESIPtr(Reg, Shift);
  Prg.AsmPush_REG(Reg);

  EmitGet_REG(Reg, SymbolTable[SubId]);
  Prg.AsmCall_REG(Reg);

  FreeReg(Reg);
end;

procedure TEmitter.EmitOP_GET_WIDESTR_PROP;
var
  SubId, Reg, ClassId, PropIndex, Shift: Integer;
begin
  SubId := Id_GetWideStrProp;

  EmitPCodeOperator;

  Reg := GetReg;

  EmitLoadAddress(Reg, SymbolRecR); // result
  Prg.AsmPush_REG(Reg);

  EmitLoadIntVal(Reg, SymbolRec1); // instance
  Prg.AsmPush_REG(Reg);

  // push ppi
  PropIndex := SymbolRec2.PropIndex;
  ClassId := GetSymbolRec(SymbolRec1.TerminalHostClassId).Id;
  Shift := GetOffset(GetSymbolRec(ClassId + 1));
  Inc(Shift, (PropIndex + 1) * SizeOf(Pointer));
  Prg.AsmGetREG32_ESIPtr(Reg, Shift);
  Prg.AsmPush_REG(Reg);

  EmitGet_REG(Reg, SymbolTable[SubId]);
  Prg.AsmCall_REG(Reg);

  FreeReg(Reg);
end;

procedure TEmitter.EmitOP_SET_WIDESTR_PROP;
var
  SubId, Reg, PropIndex, ClassId, Shift: Integer;
begin
  SubId := Id_SetWideStrProp;

  EmitPCodeOperator;

  Reg := GetReg;

  if SymbolRecR.HasPAnsiCharType then
    EmitGet_REG(Reg, SymbolRecR)
  else
    EmitLoadIntVal(Reg, SymbolRecR); // value
  Prg.AsmPush_REG(Reg);

  EmitLoadIntVal(Reg, SymbolRec1); // instance
  Prg.AsmPush_REG(Reg);

  // push ppi
  PropIndex := SymbolRec2.PropIndex;
  ClassId := GetSymbolRec(SymbolRec1.TerminalHostClassId).Id;
  Shift := GetOffset(GetSymbolRec(ClassId + 1));
  Inc(Shift, (PropIndex + 1) * SizeOf(Pointer));
  Prg.AsmGetREG32_ESIPtr(Reg, Shift);
  Prg.AsmPush_REG(Reg);

  EmitGet_REG(Reg, SymbolTable[SubId]);
  Prg.AsmCall_REG(Reg);

  FreeReg(Reg);
end;

procedure TEmitter.EmitOP_GET_UNICSTR_PROP;
var
  SubId, Reg, ClassId, PropIndex, Shift: Integer;
begin
  SubId := Id_GetUnicStrProp;

  EmitPCodeOperator;

  Reg := GetReg;

  EmitLoadAddress(Reg, SymbolRecR); // result
  Prg.AsmPush_REG(Reg);

  EmitLoadIntVal(Reg, SymbolRec1); // instance
  Prg.AsmPush_REG(Reg);

  // push ppi
  PropIndex := SymbolRec2.PropIndex;
  ClassId := GetSymbolRec(SymbolRec1.TerminalHostClassId).Id;
  Shift := GetOffset(GetSymbolRec(ClassId + 1));
  Inc(Shift, (PropIndex + 1) * SizeOf(Pointer));
  Prg.AsmGetREG32_ESIPtr(Reg, Shift);
  Prg.AsmPush_REG(Reg);

  EmitGet_REG(Reg, SymbolTable[SubId]);
  Prg.AsmCall_REG(Reg);

  FreeReg(Reg);
end;

procedure TEmitter.EmitOP_SET_UNICSTR_PROP;
var
  SubId, Reg, PropIndex, ClassId, Shift: Integer;
begin
  SubId := Id_SetUnicStrProp;

  EmitPCodeOperator;

  Reg := GetReg;

  if SymbolRecR.HasPAnsiCharType then
    EmitGet_REG(Reg, SymbolRecR)
  else
    EmitLoadIntVal(Reg, SymbolRecR); // value
  Prg.AsmPush_REG(Reg);

  EmitLoadIntVal(Reg, SymbolRec1); // instance
  Prg.AsmPush_REG(Reg);

  // push ppi
  PropIndex := SymbolRec2.PropIndex;
  ClassId := GetSymbolRec(SymbolRec1.TerminalHostClassId).Id;
  Shift := GetOffset(GetSymbolRec(ClassId + 1));
  Inc(Shift, (PropIndex + 1) * SizeOf(Pointer));
  Prg.AsmGetREG32_ESIPtr(Reg, Shift);
  Prg.AsmPush_REG(Reg);

  EmitGet_REG(Reg, SymbolTable[SubId]);
  Prg.AsmCall_REG(Reg);

  FreeReg(Reg);
end;

procedure TEmitter.EmitOP_GET_ORD_PROP;
var
  SubId, Reg, ClassId, PropIndex, Shift: Integer;
begin
  SubId := Id_GetOrdProp;

  EmitPCodeOperator;

  Reg := GetReg;

  EmitLoadAddress(Reg, SymbolRecR); // result
  Prg.AsmPush_REG(Reg);

  EmitLoadIntVal(Reg, SymbolRec1); // instance
  Prg.AsmPush_REG(Reg);

  // push ppi
  PropIndex := SymbolRec2.PropIndex;
  ClassId := GetSymbolRec(SymbolRec1.TerminalHostClassId).Id;
  Shift := GetOffset(GetSymbolRec(ClassId + 1));
  Inc(Shift, (PropIndex + 1) * SizeOf(Pointer));
  Prg.AsmGetREG32_ESIPtr(Reg, Shift);
  Prg.AsmPush_REG(Reg);

  EmitGet_REG(Reg, SymbolTable[SubId]);
  Prg.AsmCall_REG(Reg);

  FreeReg(Reg);
end;

procedure TEmitter.EmitOP_SET_ORD_PROP;
var
  SubId, Reg, PropIndex, ClassId, Shift: Integer;
begin
  SubId := Id_SetOrdProp;

  EmitPCodeOperator;

  Reg := GetReg;

  EmitLoadIntVal(Reg, SymbolRecR); // value
  Prg.AsmPush_REG(Reg);

  EmitLoadIntVal(Reg, SymbolRec1); // instance
  Prg.AsmPush_REG(Reg);

  // push ppi
  PropIndex := SymbolRec2.PropIndex;
  ClassId := GetSymbolRec(SymbolRec1.TerminalHostClassId).Id;
  Shift := GetOffset(GetSymbolRec(ClassId + 1));
  Inc(Shift, (PropIndex + 1) * SizeOf(Pointer));
  Prg.AsmGetREG32_ESIPtr(Reg, Shift);
  Prg.AsmPush_REG(Reg);

  EmitGet_REG(Reg, SymbolTable[SubId]);
  Prg.AsmCall_REG(Reg);

  FreeReg(Reg);
end;

procedure TEmitter.EmitOP_GET_INTERFACE_PROP;
var
  SubId, Reg, ClassId, PropIndex, Shift: Integer;
begin
  SubId := Id_GetInterfaceProp;

  EmitPCodeOperator;

  Reg := GetReg;

  EmitLoadAddress(Reg, SymbolRecR); // result
  Prg.AsmPush_REG(Reg);

  EmitLoadIntVal(Reg, SymbolRec1); // instance
  Prg.AsmPush_REG(Reg);

  // push ppi
  PropIndex := SymbolRec2.PropIndex;
  ClassId := GetSymbolRec(SymbolRec1.TerminalHostClassId).Id;
  Shift := GetOffset(GetSymbolRec(ClassId + 1));
  Inc(Shift, (PropIndex + 1) * SizeOf(Pointer));
  Prg.AsmGetREG32_ESIPtr(Reg, Shift);
  Prg.AsmPush_REG(Reg);

  EmitGet_REG(Reg, SymbolTable[SubId]);
  Prg.AsmCall_REG(Reg);

  FreeReg(Reg);
end;

procedure TEmitter.EmitOP_SET_INTERFACE_PROP;
var
  SubId, Reg, PropIndex, ClassId, Shift: Integer;
begin
  SubId := Id_SetOrdProp;

  EmitPCodeOperator;

  Reg := GetReg;

  EmitLoadIntVal(Reg, SymbolRecR); // value
  Prg.AsmPush_REG(Reg);

  EmitLoadIntVal(Reg, SymbolRec1); // instance
  Prg.AsmPush_REG(Reg);

  // push ppi
  PropIndex := SymbolRec2.PropIndex;
  ClassId := GetSymbolRec(SymbolRec1.TerminalHostClassId).Id;
  Shift := GetOffset(GetSymbolRec(ClassId + 1));
  Inc(Shift, (PropIndex + 1) * SizeOf(Pointer));
  Prg.AsmGetREG32_ESIPtr(Reg, Shift);
  Prg.AsmPush_REG(Reg);

  EmitGet_REG(Reg, SymbolTable[SubId]);
  Prg.AsmCall_REG(Reg);

  FreeReg(Reg);
end;

procedure TEmitter.EmitOP_GET_SET_PROP;
var
  SubId, Reg, ClassId, PropIndex, Shift: Integer;
begin
  SubId := Id_GetSetProp;

  EmitPCodeOperator;

  Reg := GetReg;

  EmitLoadAddress(Reg, SymbolRecR); // result
  Prg.AsmPush_REG(Reg);

  EmitLoadIntVal(Reg, SymbolRec1); // instance
  Prg.AsmPush_REG(Reg);

  // push ppi
  PropIndex := SymbolRec2.PropIndex;
  ClassId := GetSymbolRec(SymbolRec1.TerminalHostClassId).Id;
  Shift := GetOffset(GetSymbolRec(ClassId + 1));
  Inc(Shift, (PropIndex + 1) * SizeOf(Pointer));
  Prg.AsmGetREG32_ESIPtr(Reg, Shift);
  Prg.AsmPush_REG(Reg);

  EmitGet_REG(Reg, SymbolTable[SubId]);
  Prg.AsmCall_REG(Reg);

  FreeReg(Reg);
end;

procedure TEmitter.EmitOP_SET_SET_PROP;
var
  SubId, Reg, ClassId, PropIndex, Shift: Integer;
begin
  SubId := Id_SetSetProp;

  EmitPCodeOperator;

  Reg := GetReg;

  EmitLoadAddress(Reg, SymbolRecR); // value
  Prg.AsmPush_REG(Reg);

  EmitLoadIntVal(Reg, SymbolRec1); // instance
  Prg.AsmPush_REG(Reg);

  // push ppi
  PropIndex := SymbolRec2.PropIndex;
  ClassId := GetSymbolRec(SymbolRec1.TerminalHostClassId).Id;
  Shift := GetOffset(GetSymbolRec(ClassId + 1));
  Inc(Shift, (PropIndex + 1) * SizeOf(Pointer));
  Prg.AsmGetREG32_ESIPtr(Reg, Shift);
  Prg.AsmPush_REG(Reg);

  EmitGet_REG(Reg, SymbolTable[SubId]);
  Prg.AsmCall_REG(Reg);

  FreeReg(Reg);
end;

procedure TEmitter.EmitOP_GET_FLOAT_PROP;
var
  SubId, Reg, ClassId, PropIndex, Shift: Integer;
begin
  SubId := Id_GetFloatProp;

  EmitPCodeOperator;

  Reg := GetReg;

  EmitLoadAddress(Reg, SymbolRecR); // result
  Prg.AsmPush_REG(Reg);

  EmitLoadIntVal(Reg, SymbolRec1); // instance
  Prg.AsmPush_REG(Reg);

  // push ppi
  PropIndex := SymbolRec2.PropIndex;
  ClassId := GetSymbolRec(SymbolRec1.TerminalHostClassId).Id;
  Shift := GetOffset(GetSymbolRec(ClassId + 1));
  Inc(Shift, (PropIndex + 1) * SizeOf(Pointer));
  Prg.AsmGetREG32_ESIPtr(Reg, Shift);
  Prg.AsmPush_REG(Reg);

  EmitGet_REG(Reg, SymbolTable[SubId]);
  Prg.AsmCall_REG(Reg);

  FreeReg(Reg);
end;

procedure TEmitter.EmitOP_SET_FLOAT_PROP;
var
  SubId, Reg, ClassId, PropIndex, Shift: Integer;
begin
  SubId := Id_SetFloatProp;

  EmitPCodeOperator;

  Reg := GetReg;

  EmitLoadAddress(Reg, SymbolRecR); // value
  Prg.AsmPush_REG(Reg);

  EmitLoadIntVal(Reg, SymbolRec1); // instance
  Prg.AsmPush_REG(Reg);

  // push ppi
  PropIndex := SymbolRec2.PropIndex;
  ClassId := GetSymbolRec(SymbolRec1.TerminalHostClassId).Id;
  Shift := GetOffset(GetSymbolRec(ClassId + 1));
  Inc(Shift, (PropIndex + 1) * SizeOf(Pointer));
  Prg.AsmGetREG32_ESIPtr(Reg, Shift);
  Prg.AsmPush_REG(Reg);

  EmitGet_REG(Reg, SymbolTable[SubId]);
  Prg.AsmCall_REG(Reg);

  FreeReg(Reg);
end;

procedure TEmitter.EmitOP_GET_VARIANT_PROP;
var
  SubId, Reg, ClassId, PropIndex, Shift: Integer;
begin
  SubId := Id_GetVariantProp;

  EmitPCodeOperator;

  Reg := GetReg;

  EmitLoadAddress(Reg, SymbolRecR); // result
  Prg.AsmPush_REG(Reg);

  EmitLoadIntVal(Reg, SymbolRec1); // instance
  Prg.AsmPush_REG(Reg);

  // push ppi
  PropIndex := SymbolRec2.PropIndex;
  ClassId := GetSymbolRec(SymbolRec1.TerminalHostClassId).Id;
  Shift := GetOffset(GetSymbolRec(ClassId + 1));
  Inc(Shift, (PropIndex + 1) * SizeOf(Pointer));
  Prg.AsmGetREG32_ESIPtr(Reg, Shift);
  Prg.AsmPush_REG(Reg);

  EmitGet_REG(Reg, SymbolTable[SubId]);
  Prg.AsmCall_REG(Reg);

  FreeReg(Reg);
end;

procedure TEmitter.EmitOP_SET_VARIANT_PROP;
var
  SubId, Reg, ClassId, PropIndex, Shift: Integer;
begin
  SubId := Id_SetVariantProp;

  EmitPCodeOperator;

  Reg := GetReg;

  EmitLoadAddress(Reg, SymbolRecR); // value
  Prg.AsmPush_REG(Reg);

  EmitLoadIntVal(Reg, SymbolRec1); // instance
  Prg.AsmPush_REG(Reg);

  // push ppi
  PropIndex := SymbolRec2.PropIndex;
  ClassId := GetSymbolRec(SymbolRec1.TerminalHostClassId).Id;
  Shift := GetOffset(GetSymbolRec(ClassId + 1));
  Inc(Shift, (PropIndex + 1) * SizeOf(Pointer));
  Prg.AsmGetREG32_ESIPtr(Reg, Shift);
  Prg.AsmPush_REG(Reg);

  EmitGet_REG(Reg, SymbolTable[SubId]);
  Prg.AsmCall_REG(Reg);

  FreeReg(Reg);
end;

procedure TEmitter.EmitOP_GET_INT64_PROP;
var
  SubId, Reg, ClassId, PropIndex, Shift: Integer;
begin
  SubId := Id_GetInt64Prop;

  EmitPCodeOperator;

  Reg := GetReg;

  EmitLoadAddress(Reg, SymbolRecR); // result
  Prg.AsmPush_REG(Reg);

  EmitLoadIntVal(Reg, SymbolRec1); // instance
  Prg.AsmPush_REG(Reg);

  // push ppi
  PropIndex := SymbolRec2.PropIndex;
  ClassId := GetSymbolRec(SymbolRec1.TerminalHostClassId).Id;
  Shift := GetOffset(GetSymbolRec(ClassId + 1));
  Inc(Shift, (PropIndex + 1) * SizeOf(Pointer));
  Prg.AsmGetREG32_ESIPtr(Reg, Shift);
  Prg.AsmPush_REG(Reg);

  EmitGet_REG(Reg, SymbolTable[SubId]);
  Prg.AsmCall_REG(Reg);

  FreeReg(Reg);
end;

procedure TEmitter.EmitOP_SET_INT64_PROP;
var
  SubId, Reg, ClassId, PropIndex, Shift: Integer;
begin
  SubId := Id_SetInt64Prop;

  EmitPCodeOperator;

  Reg := GetReg;

  EmitLoadAddress(Reg, SymbolRecR); // value
  Prg.AsmPush_REG(Reg);

  EmitLoadIntVal(Reg, SymbolRec1); // instance
  Prg.AsmPush_REG(Reg);

  // push ppi
  PropIndex := SymbolRec2.PropIndex;
  ClassId := GetSymbolRec(SymbolRec1.TerminalHostClassId).Id;
  Shift := GetOffset(GetSymbolRec(ClassId + 1));
  Inc(Shift, (PropIndex + 1) * SizeOf(Pointer));
  Prg.AsmGetREG32_ESIPtr(Reg, Shift);
  Prg.AsmPush_REG(Reg);

  EmitGet_REG(Reg, SymbolTable[SubId]);
  Prg.AsmCall_REG(Reg);

  FreeReg(Reg);
end;

procedure TEmitter.EmitOP_GET_EVENT_PROP;
var
  SubId, Reg, ClassId, PropIndex, Shift: Integer;
begin
  SubId := Id_GetEventProp;

  EmitPCodeOperator;

  HandlesEvents := true;

  Reg := GetReg;

  EmitLoadAddress(Reg, SymbolRecR); // result
  Prg.AsmPush_REG(Reg);

  EmitLoadIntVal(Reg, SymbolRec1); // instance
  Prg.AsmPush_REG(Reg);

  // push ppi
  PropIndex := SymbolRec2.PropIndex;
  ClassId := GetSymbolRec(SymbolRec1.TerminalHostClassId).Id;
  Shift := GetOffset(GetSymbolRec(ClassId + 1));
  Inc(Shift, (PropIndex + 1) * SizeOf(Pointer));
  Prg.AsmGetREG32_ESIPtr(Reg, Shift);
  Prg.AsmPush_REG(Reg);

  EmitGet_REG(Reg, SymbolTable[SubId]);
  Prg.AsmCall_REG(Reg);

  FreeReg(Reg);
end;

procedure TEmitter.EmitOP_SET_EVENT_PROP2;
var
  SubId, Reg, ClassId, PropIndex, Shift: Integer;
begin
  SubId := Id_SetEventProp2;

  EmitPCodeOperator;

  HandlesEvents := true;

  Reg := GetReg;

  EmitLoadAddress(Reg, SymbolRecR); // result
  Prg.AsmPush_REG(Reg);

  EmitLoadIntVal(Reg, SymbolRec1); // instance
  Prg.AsmPush_REG(Reg);

  // push ppi
  PropIndex := SymbolRec2.PropIndex;
  ClassId := GetSymbolRec(SymbolRec1.TerminalHostClassId).Id;
  Shift := GetOffset(GetSymbolRec(ClassId + 1));
  Inc(Shift, (PropIndex + 1) * SizeOf(Pointer));
  Prg.AsmGetREG32_ESIPtr(Reg, Shift);
  Prg.AsmPush_REG(Reg);

  Prg.AsmMovREG_REG(Reg, _ESI);
  Prg.AsmAddREG_Imm(Reg, H_SelfPtr);
  Prg.AsmMovREG32_REGPtr(Reg, Reg); // load TProgram.Self
  Prg.AsmPush_REG(Reg);             // push TProgram.Self

  EmitGet_REG(Reg, SymbolTable[SubId]);
  Prg.AsmCall_REG(Reg);

  FreeReg(Reg);
end;

procedure TEmitter.EmitOP_SET_EVENT_PROP;
var
  SubId, Reg, ClassId,
  PropIndex, Shift, CodeId, DataId, CallConv, RetSize: Integer;
  R: TSymbolRec;
begin
  SubId := Id_SetEventProp;

  EmitPCodeOperator;

  Reg := GetReg;

  HandlesEvents := true;

  if SymbolRecR.Id = TKernel(kernel).SymbolTable.NilId then
  begin
    R := TKernel(kernel).SymbolTable.AddIntegerConst(0);
    R.MustBeAllocated := true;
    DataId := R.Id;
    R := TKernel(kernel).SymbolTable.AddIntegerConst(0);
    R.MustBeAllocated := true;
    CodeId := R.Id;

    CallConv := ccREGISTER;
    RetSize := 0;
  end
  else
  begin
    DataId := SymbolRecR.OwnerId;
    CodeId := SymbolRecR.PatternId;

    CallConv := GetSymbolRec(CodeId).CallConv;
    RetSize := SymbolTable.GetSizeOfParams(CodeId);
  end;

  Prg.AsmPush_Imm(RetSize);
  Prg.AsmPush_Imm(CallConv);

  EmitLoadIntVal(Reg, GetSymbolRec(DataId)); // data
  Prg.AsmPush_REG(Reg);

  if GetSymbolRec(CodeId).Host then
  begin
    EmitGet_REG(Reg, GetSymbolRec(CodeId));
    Prg.AsmPush_REG(Reg);
  end
  else
  begin
    Prg.AsmMovREG_REG(Reg, _EDI);
    Prg.AsmAddREG_Imm(Reg, 0);
    Prg.Top.SaveSubId := CodeId;
    List2.Add(Prg.Top);
    Prg.AsmPush_REG(Reg);
  end;

  EmitLoadIntVal(Reg, SymbolRec1); // instance
  Prg.AsmPush_REG(Reg);

  // push ppi
  PropIndex := SymbolRec2.PropIndex;
  ClassId := GetSymbolRec(SymbolRec1.TerminalHostClassId).Id;
  Shift := GetOffset(GetSymbolRec(ClassId + 1));
  Inc(Shift, (PropIndex + 1) * SizeOf(Pointer));
  Prg.AsmGetREG32_ESIPtr(Reg, Shift);
  Prg.AsmPush_REG(Reg);

  Prg.AsmMovREG_REG(Reg, _ESI);
  Prg.AsmAddREG_Imm(Reg, H_SelfPtr);
  Prg.AsmMovREG32_REGPtr(Reg, Reg); // load TProgram.Self
  Prg.AsmPush_REG(Reg);             // push TProgram.Self

  EmitGet_REG(Reg, SymbolTable[SubId]);
  Prg.AsmCall_REG(Reg);

  FreeReg(Reg);
end;

procedure TEmitter.EmitOP_EMIT_ON;
begin
  EmitPCodeOperator;
  EmitOff := false;
end;

procedure TEmitter.EmitOP_EMIT_OFF;
begin
  EmitPCodeOperator;
  EmitOff := true;
end;

procedure TEmitter.EmitOP_CREATE_OBJECT;
var
  Reg, SubId, TypeId: Integer;
begin
  EmitPCodeOperator;

  SubId := Id_CreateObject;

  Reg := GetReg;

  EmitLoadAddress(Reg, SymbolRecR);
  Prg.AsmPush_REG(Reg);

  TypeId := SymbolRec1.TerminalTypeId;
  EmitLoadIntVal(Reg, GetSymbolRec(TypeId + 1));
  Prg.AsmPush_REG(Reg);

  EmitGet_REG(Reg, SymbolTable[SubId]);
  Prg.AsmCall_REG(Reg);

  FreeReg(Reg);
end;

procedure TEmitter.EmitOP_DESTROY_OBJECT;
var
  Reg, SubId: Integer;
begin
  EmitPCodeOperator;

  SubId := Id_DestroyObject;

  Reg := GetReg;

  EmitLoadAddress(Reg, SymbolRec1);
  Prg.AsmPush_REG(Reg);

  EmitGet_REG(Reg, SymbolTable[SubId]);
  Prg.AsmCall_REG(Reg);

  FreeReg(Reg);
end;

procedure TEmitter.EmitOP_GET_VMT_ADDRESS;
var
  Reg, MethodIndex: Integer;
  SymbolProgRec: TSymbolProgRec;
begin
  EmitPCodeOperator;

  if IsLocalPos then
    Emit_PUSH_REGS;

  GetReg(_EBX);
  Reg := _EBX;

  MethodIndex := SymbolRec2.MethodIndex;

  EmitLoadIntVal(Reg, SymbolRec1); // instance

  if SymbolRec1.FinalTypeId <> typeCLASSREF then
    prg.AsmMovREG32_REGPtr(Reg, Reg);

  if MethodIndex = 0 then
  begin
    SymbolProgRec := prg.AsmAddREG_Imm(Reg, 0);
    SymbolProgRec.MustBeFixed := true;
    SymbolProgRec.OpOffset := 2;
    SymbolProgRec.SubId := SymbolRec2.Id;
  end
  else
    prg.AsmAddREG_Imm(Reg, (MethodIndex - 1) * 4);

  prg.AsmMovREG32_REGPtr(Reg, Reg);

  EmitSaveIntVal(Reg, SymbolRecR); // result

  FreeReg(Reg);

  if IsLocalPos then
    Emit_POP_REGS;
end;

function TEmitter.HasTheSameAddressRegister(S1, S2: TSymbolRec): Boolean;

var
  t: Integer;

function RR(S: TSymbolRec): Integer;
begin
  Inc(t);

  if (S.Local or S.Param) and (not S.OverScript) then // local
  begin
    if S.ByRef then
      result := t
    else
    begin
      if S.Level = ContextStack.Top then
        result := _EBP
      else
        result := t;
    end;
  end
  else // global
  begin
    if S.Host or S.ByRef then
      result := t
    else
      result := _ESI;
  end;
end;

begin
  t := 100;
  result := RR(S1) = RR(S2);
end;

function TEmitter.EmitGetAddressRegister(S: TSymbolRec): Integer;
                   // returns a register.
                   // If it returns ESI or EBP, address = result + S.Shift !!
                   // otherwise, address = result
                   // Caller must free the register !!
var
  temp: Integer;
begin
  if (S.Local or S.LocalInternalField or S.Param) and (not S.OverScript) then
  begin
    if S.ByRef then
    begin
      result := GetReg;
      EmitGet_REG(result, S);
    end
    else
    begin
      if S.Level = ContextStack.Top then
        result := _EBP
      else
      begin
        result := GetReg;
        EmitRestoreEBP(result, S);
        Prg.AsmAddREG_Imm(result, GetOffset(S));
      end;
    end;
  end
  else // global
  begin
    if S.Host or S.ByRef then
    begin
      result := GetReg;

      temp := S.FinSize;
      S.FinSize := 4;
      EmitGet_REG(result, S);
      S.FinSize := temp;
    end
    else
      result := _ESI;
  end;
end;

procedure TEmitter.EmitFLD(S: TSymbolRec);
var
  Reg: Integer;
begin
  Reg := EmitGetAddressRegister(S);
  case S.FinalTypeId of
    typeDOUBLE: Prg.AsmFldDouble_REGPtr(Reg, S);
    typeSINGLE: Prg.AsmFldSingle_REGPtr(Reg, S);
    typeEXTENDED: Prg.AsmFldExtended_REGPtr(Reg, S);
  else
    RaiseError(errInternalError, []);
  end;
  FreeReg(Reg);
end;

procedure TEmitter.EmitFild(S: TSymbolRec);
var
  Reg, TempReg: Integer;
begin
  Reg := GetReg;
  EmitLoadAddress(Reg, S);
  if S.PtrSize = 8 then
    Prg.AsmFild_REG64Ptr(Reg)
  else if S.FinalTypeId in IntegerTypes then
  begin
    EmitLoadAddress(Reg, S);
    case S.PtrSize of
      1:
      begin
        TempReg := GetReg;
        Prg.AsmXorREG_REG(TempReg, TempReg);
        Prg.AsmMovREG8_REGPtr(TempReg, Reg);
        Prg.AsmPush_REG(TempReg);
        Prg.AsmMovREG_REG(TempReg, _ESP);
        Prg.AsmFild_REG32Ptr(TempReg);
        Prg.AsmPop_REG(TempReg);
        FreeReg(TempReg);
      end;
      2: Prg.AsmFild_REG16Ptr(Reg);
      4: Prg.AsmFild_REG32Ptr(Reg);
    end;
  end
  else
    RaiseError(errInternalError, []);
  FreeReg(Reg);
end;

procedure TEmitter.EmitFSTP(S: TSymbolRec);
var
  Reg: Integer;
begin
  Reg := EmitGetAddressRegister(S);
  case S.FinalTypeId of
    typeDOUBLE: Prg.AsmFStpDouble_REGPtr(Reg, S);
    typeSINGLE: Prg.AsmFStpSingle_REGPtr(Reg, S);
    typeEXTENDED: Prg.AsmFStpExtended_REGPtr(Reg, S);
  else
    RaiseError(errInternalError, []);
  end;
  FreeReg(Reg);
end;

procedure TEmitter.EmitJmp;
begin
  List3.Add(SymbolRec1);
  Prg.AsmJMP_Imm(0);
  List1.Add(Prg.Top);
end;

procedure TEmitter.EmitLoadAddress(Reg: Integer; S: TSymbolRec);
var
  temp: Integer;
begin
  if (S.Local or S.LocalInternalField or S.Param) and (not S.OverScript) then
  begin
    if S.ByRef then
    begin
      EmitGet_REG(Reg, S);
    end
    else
    begin
      if S.Level = ContextStack.Top then
      begin
        Prg.AsmMovREG_REG(Reg, _EBP);
        Prg.AsmAddREG_Imm(Reg, GetOffset(S));
      end
      else
      begin
        EmitRestoreEBP(Reg, S);
        Prg.AsmAddREG_Imm(Reg, GetOffset(S));
      end;
    end;
  end
  else // global
  begin
    if S.Host or S.ByRef then
    begin
      temp := S.FinSize;
      S.FinSize := 4;
      EmitGet_REG(Reg, S);
      S.FinSize := temp;
    end
    else
    begin
      Prg.AsmMovREG_REG(Reg, _ESI);
      Prg.AsmAddREG_Imm(Reg, GetOffset(S));
    end;
  end;
end;

procedure TEmitter.EmitLoadIntVal(Reg: Integer; S: TSymbolRec);
var
  TempReg, Temp: Integer;
begin
  if S.Kind = KindCONST then
  begin
    Prg.AsmMovREG_Imm(Reg, S.Value);
  end
  else
  begin
    if S.Host or S.ByRef then
    begin
      temp := S.FinSize;
      S.FinSize := 4;
      EmitGet_REG(Reg, S);
      S.FinSize := temp;
      case S.PtrSize of
        1:
        begin
          TempReg := GetReg;
          Prg.AsmPush_REG(TempReg);
          Prg.AsmXorREG_REG(TempReg, TempReg);
          Prg.AsmMovREG8_REGPtr(TempReg, Reg);
          Prg.AsmMovREG_REG(Reg, TempReg);
          Prg.AsmPop_REG(TempReg);
          FreeReg(TempReg);
        end;
        2:
        begin
          TempReg := GetReg;
          Prg.AsmPush_REG(TempReg);
          Prg.AsmXorREG_REG(TempReg, TempReg);
          Prg.AsmMovREG16_REGPtr(TempReg, Reg);
          Prg.AsmMovREG_REG(Reg, TempReg);
          Prg.AsmPop_REG(TempReg);
          FreeReg(TempReg);
        end;
      else
        Prg.AsmMovREG32_REGPtr(Reg, Reg);
      end;
    end
    else
    begin
      if S.PtrSize < 4 then
         Prg.AsmXorREG_REG(Reg, Reg);
      EmitGet_REG(Reg, S);
    end;
  end;
end;

procedure TEmitter.EmitSaveIntVal(Reg: Integer; S: TSymbolRec);
var
  RegR: Integer;
begin
  if S.Host or S.ByRef then
  begin
    RegR := GetReg;
    EmitLoadAddress(RegR, S);
    case S.PtrSize of
      1:
      begin
        Prg.AsmMovREGPtr_REG8(RegR, Reg);
      end;
      2:
      begin
        Prg.AsmMovREGPtr_REG16(RegR, Reg);
      end;
    else
      Prg.AsmMovREGPtr_REG32(RegR, Reg);
    end;
    FreeReg(RegR);
  end
  else
    EmitPut_REG(Reg, S);
end;

procedure TEmitter.EmitPut_REG(Reg: Integer; S: TSymbolRec; ExtraShift: Integer = 0);
                               // Reg contains a 32-bit value
                               // S - destination
var
  SZ, TempReg: Integer;
begin
  SZ := S.Size;

  case SZ of
    1:
    begin
      if (S.Param or S.Local or S.LocalInternalField) and (not S.OverScript) then // local
      begin
        if S.Level = ContextStack.Top then
          Prg.AsmPutREG8_EBPPtr(Reg, GetOffset(S) + ExtraShift)
        else
        begin
          TempReg := GetReg;
          Prg.AsmPush_REG(TempReg);
          EmitRestoreEBP(TempReg, S);
          Prg.AsmAddREG_Imm(TempReg, GetOffset(S) + ExtraShift);
          Prg.AsmMovREGPtr_REG8(TempReg, Reg);
          Prg.AsmPop_REG(TempReg);
          FreeReg(TempReg);
        end;
      end
      else // global
        Prg.AsmPutREG8_ESIPtr(Reg, GetOffset(S) + ExtraShift);
    end;
    2:
    begin
      if (S.Param or S.Local or S.LocalInternalField) and (not S.OverScript) then // local
      begin
        if S.Level = ContextStack.Top then
          Prg.AsmPutREG16_EBPPtr(Reg, GetOffset(S) + ExtraShift)
        else
        begin
          TempReg := GetReg;
          Prg.AsmPush_REG(TempReg);
          EmitRestoreEBP(TempReg, S);
          Prg.AsmAddREG_Imm(TempReg, GetOffset(S) + ExtraShift);
          Prg.AsmMovREGPtr_REG16(TempReg, Reg);
          Prg.AsmPop_REG(TempReg);
          FreeReg(TempReg);
        end;
      end
      else // global
        Prg.AsmPutREG16_ESIPtr(Reg, GetOffset(S) + ExtraShift);
    end;
    else
    begin
      if (S.Param or S.Local or S.LocalInternalField) and (not S.OverScript) then // local
      begin
        if S.Level = ContextStack.Top then
          Prg.AsmPutREG32_EBPPtr(Reg, GetOffset(S) + ExtraShift)
        else
        begin
          TempReg := GetReg;
          Prg.AsmPush_REG(TempReg);
          EmitRestoreEBP(TempReg, S);
          Prg.AsmAddREG_Imm(TempReg, GetOffset(S) + ExtraShift);
          Prg.AsmMovREGPtr_REG32(TempReg, Reg);
          Prg.AsmPop_REG(TempReg);
          FreeReg(TempReg);
        end;
      end
      else // global
        Prg.AsmPutREG32_ESIPtr(Reg, GetOffset(S) + ExtraShift);
    end;
  end;
end;

procedure TEmitter.EmitGet_REG(Reg: Integer; S: TSymbolRec; ExtraShift: Integer = 0);
                              // S - source
                              // Reg - destination
var
  SZ, TempReg: Integer;
begin
  SZ := S.Size;

  case SZ of
    1:
    begin
      if (S.Param or S.Local or S.LocalInternalField) and (not S.OverScript) then // local
      begin
        if S.Level = ContextStack.Top then
          Prg.AsmGetREG8_EBPPtr(Reg, GetOffset(S) + ExtraShift)
        else
        begin
          TempReg := GetReg;
          Prg.AsmPush_REG(TempReg);
          EmitRestoreEBP(TempReg, S);
          Prg.AsmAddREG_Imm(TempReg, GetOffset(S) + ExtraShift);
          Prg.AsmXorREG_REG(Reg, Reg);
          Prg.AsmMovREG8_REGPtr(Reg, TempReg);
          Prg.AsmPop_REG(TempReg);
          FreeReg(TempReg);
        end;
      end
      else // global
      begin
        Prg.AsmXorREG_REG(Reg, Reg);
        Prg.AsmGetREG8_ESIPtr(Reg, GetOffset(S) + ExtraShift);
      end;
    end;
    2:
    begin
      if (S.Param or S.Local or S.LocalInternalField) and (not S.OverScript) then // local
      begin
        if S.Level = ContextStack.Top then
          Prg.AsmGetREG16_EBPPtr(Reg, GetOffset(S) + ExtraShift)
        else
        begin
          TempReg := GetReg;
          Prg.AsmPush_REG(TempReg);
          EmitRestoreEBP(TempReg, S);
          Prg.AsmAddREG_Imm(TempReg, GetOffset(S) + ExtraShift);
          Prg.AsmXorREG_REG(Reg, Reg);
          Prg.AsmMovREG16_REGPtr(Reg, TempReg);
          Prg.AsmPop_REG(TempReg);
          FreeReg(TempReg);
        end;
      end
      else // global
      begin
        Prg.AsmXorREG_REG(Reg, Reg);
        Prg.AsmGetREG16_ESIPtr(Reg, GetOffset(S) + ExtraShift);
      end;
    end;
    else
    begin
      if (S.Param or S.Local or S.LocalInternalField) and (not S.OverScript) then // local
      begin
        if S.Level = ContextStack.Top then
          Prg.AsmGetREG32_EBPPtr(Reg, GetOffset(S) + ExtraShift)
        else
        begin
          TempReg := GetReg;
          Prg.AsmPush_REG(TempReg);
          EmitRestoreEBP(TempReg, S);
          Prg.AsmAddREG_Imm(TempReg, GetOffset(S) + ExtraShift);
          Prg.AsmMovREG32_REGPtr(Reg, TempReg);
          Prg.AsmPop_REG(TempReg);
          FreeReg(TempReg);
        end;
      end
      else // global
        Prg.AsmGetREG32_ESIPtr(Reg, GetOffset(S) + ExtraShift);
    end;
  end;
end;

procedure TEmitter.EmitRestoreEBP(Reg: Integer; S: TSymbolRec);
var
  I, Index, SubId: Integer;
begin
  SubId := S.Level;
  Index := ContextStack.IndexOf(SubId);

  Prg.AsmMovREG_REG(Reg, _EBP);

  for I:=ContextStack.Count - 1 downto Index + 1 do
  begin
    SubId := ContextStack[I];
    Prg.AsmAddREG_Imm(Reg, 8 + SymbolTable.GetSizeOfParams(SubId));
    Prg.AsmMovREG32_REGPtr(Reg, Reg);
  end;
end;

procedure TEmitter.Emit_PUSH_REGS(SubId: Integer = 0);
begin
  if SubId > 0 then
    if not (GetSymbolRec(SubId).CallConv in [ccREGISTER, ccMSFASTCALL]) then
      Exit;

  Prg.AsmPush_REG(_EAX);
  Prg.AsmPush_REG(_ECX);
  Prg.AsmPush_REG(_EDX);
end;

procedure TEmitter.Emit_POP_REGS(SubId: Integer = 0);
begin
  if SubId > 0 then
    if not (GetSymbolRec(SubId).CallConv in [ccREGISTER, ccMSFASTCALL]) then
      Exit;

  Prg.AsmPop_REG(_EDX);
  Prg.AsmPop_REG(_ECX);
  Prg.AsmPop_REG(_EAX);
end;

procedure TEmitter.Emit_PUSH_REGS_EX;
begin
  Prg.AsmPush_REG(_EAX);
  Prg.AsmPush_REG(_ECX);
  Prg.AsmPush_REG(_EDX);
  Prg.AsmPush_REG(_ESI);
  Prg.AsmPush_REG(_EDI);
end;

procedure TEmitter.Emit_POP_REGS_EX;
begin
  Prg.AsmPop_REG(_EDI);
  Prg.AsmPop_REG(_ESI);
  Prg.AsmPop_REG(_EDX);
  Prg.AsmPop_REG(_ECX);
  Prg.AsmPop_REG(_EAX);
end;


end.
