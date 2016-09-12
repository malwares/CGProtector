////////////////////////////////////////////////////////////////////////////
// PaxCompiler
// Site: http://www.paxcompiler.com
// Author: Alexander Baranovsky (paxscript@gmail.com)
// ========================================================================
// Copyright (c) Alexander Baranovsky, 2006-2008. All rights reserved.
// Code Version: 2.4
// ========================================================================
// Unit: PAXCOMP_SYS.pas
// ========================================================================
////////////////////////////////////////////////////////////////////////////

{$I PaxCompiler.def}

{$O-}
{$Q-}
{$R-}

unit PAXCOMP_SYS;
interface
uses
{$IFDEF LINUX}
{$IFDEF FPC}
{$ELSE}
  QForms,
{$ENDIF}
{$ELSE}
  Windows,
{$ENDIF}

{$IFDEF VARIANTS}
  Variants,
{$ENDIF}
  TypInfo,
  SysUtils,
  Classes,
  PAXCOMP_CONSTANTS;

const
  FirstCompiledScriptVersion = 102;
var  
  FirstLocalId: Integer = 1000000;
  StreamVersion: Integer = 114;
  CompiledScriptVersion: Integer = 110;

const
  MaxPublishedProps = 50; // importer only
{$IFNDEF UNIC}
  varUString  = $0102; { Unicode string 258 } {not OLE compatible}
{$ENDIF}

  NaN         =  0.0 / 0.0;
  Infinity    =  1.0 / 0.0;
  NegInfinity = -1.0 / 0.0;

  SecsPerHour   = 60 * 60;
  SecsPerDay    = SecsPerHour * 24;
  MSecsPerDay   = SecsPerDay * 1000;
  MSecsPerHour  = SecsPerHour * 1000;

{$IFDEF LINUX}
  varClass = varError;
  varPointer = $15;
{$ELSE}
  varClass = $0E;
  varPointer = $15;
{$ENDIF}

  MaxHash = 199;

  H_SelfPtr = 16;
  H_ExceptionPtr = 20;
  H_ByteCodePtr = 24;
  H_Flag = 28;
  FirstShiftValue = 85;

  H_InitOnly = 4;
  H_BodyOnly = 8;

  kindNONE = 0;
  kindVAR = 1;
  kindCONST = 2;
  kindSUB = 3;
  kindPARAM = 4;
  kindTYPE = 5;
  kindTYPE_FIELD = 6;
  kindLABEL = 7;
  kindNAMESPACE = 8;
  kindCONSTRUCTOR = 9;
  kindDESTRUCTOR = 10;
  kindPROP = 11;
  kindEND_CLASS_HEADER = 12;

  KindSubs = [KindSUB, KindCONSTRUCTOR, KindDESTRUCTOR];

  UnsignedIntegerTypes = [typeBYTE, typeWORD, typeCARDINAL];

  IntegerTypes = [typeBYTE, typeWORD, typeINTEGER, typeINT64,
                  typeCARDINAL, typeSMALLINT, typeSHORTINT];
  CharTypes = [typeANSICHAR, typeWIDECHAR];
  BooleanTypes = [typeBOOLEAN, typeWORDBOOL, typeLONGBOOL, typeBYTEBOOL];
  OrdinalTypes = IntegerTypes + CharTypes + BooleanTypes + [typeENUM];
  RealTypes = [typeSINGLE, typeDOUBLE, typeEXTENDED];
  StringTypes = [typeANSISTRING, typeSHORTSTRING, typeWIDESTRING, typeUNICSTRING];
  NumberTypes = IntegerTypes + RealTypes + [typeCURRENCY];
  VariantTypes = [typeVARIANT, typeOLEVARIANT];
  DynamicTypes = [typeANSISTRING, typeWIDESTRING, typeUNICSTRING] + VariantTypes + [typeDYNARRAY, typeINTERFACE];
  StandardTypes = OrdinalTypes + RealTypes + StringTypes + VariantTypes;

var
  OP_NOP,
  OP_SEPARATOR,
  OP_STMT,
  OP_SET_CODE_LINE,

  OP_BEGIN_NAMESPACE,
  OP_END_NAMESPACE,

  OP_BEGIN_TYPE,
  OP_END_TYPE,

  OP_BEGIN_CLASS_TYPE,
  OP_END_CLASS_TYPE,

  OP_BEGIN_CLASSREF_TYPE,
  OP_END_CLASSREF_TYPE,

  OP_BEGIN_INTERFACE_TYPE,
  OP_END_INTERFACE_TYPE,

  OP_BEGIN_RECORD_TYPE,
  OP_END_RECORD_TYPE,

  OP_BEGIN_ARRAY_TYPE,
  OP_END_ARRAY_TYPE,

  OP_BEGIN_DYNARRAY_TYPE,
  OP_END_DYNARRAY_TYPE,

  OP_BEGIN_SUBRANGE_TYPE,
  OP_END_SUBRANGE_TYPE,

  OP_BEGIN_ENUM_TYPE,
  OP_END_ENUM_TYPE,

  OP_BEGIN_SET_TYPE,
  OP_END_SET_TYPE,

  OP_BEGIN_POINTER_TYPE,
  OP_END_POINTER_TYPE,

  OP_BEGIN_PROC_TYPE,
  OP_END_PROC_TYPE,

  OP_BEGIN_SHORTSTRING_TYPE,
  OP_END_SHORTSTRING_TYPE,

  OP_BEGIN_ALIAS_TYPE,
  OP_END_ALIAS_TYPE,

  OP_BEGIN_CONST,
  OP_END_CONST,

  OP_BEGIN_VAR,
  OP_END_VAR,

  OP_GET_NEXTJSPROP, // js only
  OP_CLEAR_REFERENCES, // js only

  OP_BEGIN_MODULE,
  OP_END_MODULE,
  OP_END_INTERFACE_SECTION,
  OP_END_IMPORT,
  OP_BEGIN_INITIALIZATION,
  OP_END_INITIALIZATION,
  OP_BEGIN_FINALIZATION,
  OP_END_FINALIZATION,

  OP_EXTRA_BYTECODE,

  OP_TRY_ON,
  OP_TRY_OFF,
  OP_FINALLY,
  OP_EXCEPT,
  OP_EXCEPT_ON,
  OP_RAISE,
  OP_COND_RAISE,
  OP_BEGIN_EXCEPT_BLOCK,
  OP_END_EXCEPT_BLOCK,

  OP_OVERFLOW_CHECK,

  OP_PAUSE,
  OP_CHECK_PAUSE,
  OP_CHECK_PAUSE_LIGHT,
  OP_HALT,

  OP_EMIT_OFF,
  OP_EMIT_ON,

  OP_BEGIN_USING,
  OP_END_USING,

  OP_BEGIN_BLOCK,
  OP_END_BLOCK,

  OP_EVAL,
  OP_EVAL_INHERITED,
  OP_EVAL_CONSTRUCTOR,
  OP_UPDATE_INSTANCE,
  OP_CLEAR_EDX,
  OP_IMPLEMENTS,
  OP_MYCLASS,
  OP_MYBASE,

  OP_LOAD_PROC,

  OP_CHECK_OVERRIDE,

  OP_EXIT,
  OP_GO,
  OP_GO_TRUE,
  OP_GO_FALSE,
  OP_GO_TRUE_BOOL,
  OP_GO_FALSE_BOOL,
  OP_GO_DL,
  OP_CALL,
  OP_BEGIN_CALL,
  OP_CALL_DEFAULT_CONSTRUCTOR,
  OP_PUSH,
  OP_PUSH_INSTANCE,
  OP_PUSH_CLASSREF,
  OP_PUSH_CONTEXT,
  OP_POP_CONTEXT,
  OP_FIND_CONTEXT,
  OP_FIND_JS_FUNC,
  OP_LABEL,

  OP_SAVE_EDX,
  OP_RESTORE_EDX,

  OP_TYPE_CAST,

  OP_BEGIN_SUB,
  OP_DECLARE_LOCAL_VAR,
  OP_DECLARE_TEMP_VAR,
  OP_DESTROY_LOCAL_VAR,
  OP_INIT_SUB,
  OP_END_SUB,
  OP_FIN_SUB,
  OP_EPILOGUE_SUB,

  OP_BEGIN_GLOBAL_BLOCK,
  OP_EPILOGUE_GLOBAL_BLOCK,
  OP_EPILOGUE_GLOBAL_BLOCK2,
  OP_END_GLOBAL_BLOCK,

  OP_ASSIGN_TYPE,
  OP_ASSIGN_THE_SAME_TYPE,
  OP_ASSIGN_TYPE_ALIAS,

  OP_BEGIN_WITH,
  OP_END_WITH,

  OP_BEGIN_INIT_CONST,
  OP_END_INIT_CONST,

  OP_CREATE_POINTER_TYPE,
  OP_CREATE_CLASSREF_TYPE,
  OP_ADDRESS,
  OP_TERMINAL,
  OP_ADDRESS_PROG,
  OP_ASSIGN_PROG,

  OP_CREATE_DYNAMIC_ARRAY_TYPE,

  OP_CREATE_SHORTSTRING_TYPE,

  OP_SET_INCLUDE,
  OP_SET_INCLUDE_INTERVAL,
  OP_SET_EXCLUDE,

  OP_LVALUE,

  OP_ASSIGN,
  OP_ASSIGN_CONST,
  OP_ASSIGN_ENUM,
  OP_CHECK_SUBRANGE_TYPE,

  OP_INC,
  OP_DEC,
  OP_PRED,
  OP_SUCC,
  OP_ORD,
  OP_CHR,
  OP_STR,
  OP_LOW,
  OP_HIGH,

  OP_SET_LENGTH,
  OP_DYNARRAY_ASSIGN,
  OP_DYNARRAY_CLR,
  OP_DYNARRAY_HIGH,
  OP_CREATE_EMPTY_DYNARRAY,

  OP_SHORTSTRING_HIGH,

  OP_PLUS,
  OP_MINUS,
  OP_MULT,
  OP_DIV,
  OP_IDIV,
  OP_MOD,
  OP_SHL,
  OP_SHR,

  OP_NEG,
  OP_ABS,

  OP_EQ,
  OP_NE,
  OP_LT,
  OP_LE,
  OP_GT,
  OP_GE,

  OP_CLASSNAME,

  OP_GET_PROG,

  OP_IS,
  OP_AS,
  OP_TYPEINFO,
  OP_ADD_TYPEINFO,

  OP_AND,
  OP_OR,
  OP_XOR,
  OP_NOT,
  OP_LEFT_SHIFT,
  OP_RIGHT_SHIFT,

  OP_RET,

  OP_FIELD,
  OP_ELEM,

  OP_ITEM,
  OP_RECORD_ITEM,

  OP_PRINT,
  OP_PRINT_EX,

  OP_INIT_PANSICHAR_LITERAL,
  OP_INIT_PWIDECHAR_LITERAL,
  OP_SIZEOF,

  OP_OLE_GET,
  OP_OLE_SET,
  OP_OLE_VALUE,
  OP_OLE_PARAM,

  OP_ONCREATE_OBJECT,
  OP_ON_AFTER_OBJECT_CREATION,
  OP_CREATE_OBJECT,
  OP_DESTROY_OBJECT,
  OP_GET_VMT_ADDRESS,
  OP_ADD_ANCESTOR,
  OP_ADD_INTERFACE,
  OP_ADD_METHOD_INDEX,
  OP_ASSIGNED,

  OP_SAVE_REGS,
  OP_RESTORE_REGS,

  OP_ERR_ABSTRACT,
  OP_UPDATE_DEFAULT_CONSTRUCTOR,
  OP_FIND_CONSTRUCTOR,

  OP_BEGIN_CRT_JS_FUNC_OBJECT,
  OP_END_CRT_JS_FUNC_OBJECT,

  OP_TO_JS_OBJECT,
  OP_JS_TYPEOF,
  OP_JS_VOID,

  // for-in statement
  OP_GET_ENUMERATOR,
  OP_MOVE_NEXT,
  OP_CURRENT,

  OP_DUMMY
  : Integer;

// detailed operators
var
  OP_CURRENCY_FROM_INT64,
  OP_CURRENCY_FROM_INT,
  OP_CURRENCY_FROM_REAL,

  OP_INT_TO_DOUBLE,
  OP_INT64_TO_DOUBLE,

  OP_INT_TO_SINGLE,
  OP_INT64_TO_SINGLE,

  OP_INT_TO_EXTENDED,
  OP_INT64_TO_EXTENDED,

  OP_INT_TO_INT64,
  OP_BYTE_TO_INT64,
  OP_WORD_TO_INT64,
  OP_CARDINAL_TO_INT64,
  OP_SMALLINT_TO_INT64,
  OP_SHORTINT_TO_INT64,

  OP_INT_FROM_INT64,
  OP_BYTE_FROM_INT64,
  OP_WORD_FROM_INT64,
  OP_CARDINAL_FROM_INT64,
  OP_SMALLINT_FROM_INT64,
  OP_SHORTINT_FROM_INT64,

  OP_MULT_INT64,
  OP_IDIV_INT64,
  OP_MOD_INT64,
  OP_SHL_INT64,
  OP_SHR_INT64,

  OP_CURRENCY_TO_EXTENDED,
  OP_CURRENCY_TO_SINGLE,
  OP_DOUBLE_TO_SINGLE,
  OP_DOUBLE_TO_EXTENDED,
  OP_SINGLE_TO_DOUBLE,
  OP_CURRENCY_TO_DOUBLE,
  OP_SINGLE_TO_EXTENDED,
  OP_EXTENDED_TO_DOUBLE,
  OP_EXTENDED_TO_SINGLE,

  OP_ASSIGN_BYTE_I,
  OP_ASSIGN_BYTE_M,
  OP_ASSIGN_WORD_I,
  OP_ASSIGN_WORD_M,
  OP_ASSIGN_CARDINAL_I,
  OP_ASSIGN_CARDINAL_M,
  OP_ASSIGN_SMALLINT_I,
  OP_ASSIGN_SMALLINT_M,
  OP_ASSIGN_SHORTINT_I,
  OP_ASSIGN_SHORTINT_M,
  OP_ASSIGN_INT_I,
  OP_ASSIGN_INT_M,
  OP_ASSIGN_DOUBLE,
  OP_ASSIGN_CURRENCY,
  OP_ASSIGN_EVENT,
  OP_ASSIGN_SINGLE,
  OP_ASSIGN_EXTENDED,
  OP_ASSIGN_PANSICHAR,
  OP_ASSIGN_PWIDECHAR,
  OP_ASSIGN_INT64,
  OP_ASSIGN_INTERFACE,

  OP_CREATE_EVENT,

  OP_ASSIGN_ANSISTRING,
  OP_ASSIGN_SHORTSTRING,
  OP_ASSIGN_WIDESTRING,
  OP_ASSIGN_UNICSTRING,
  OP_ASSIGN_VARIANT,
  OP_ASSIGN_OLEVARIANT,

  OP_ASSIGN_CLASS,

  OP_ASSIGN_SHIFT,

  OP_ASSIGN_TVarRec,

  OP_ASSIGN_RECORD,
  OP_ASSIGN_ARRAY,

  OP_ANSISTRING_FROM_PANSICHAR,
  OP_ANSISTRING_FROM_PWIDECHAR,
  OP_ANSISTRING_FROM_ANSICHAR,
  OP_ADD_ANSISTRING,
  OP_ADD_SHORTSTRING,
  OP_ADD_WIDESTRING,
  OP_ADD_UNICSTRING,

  OP_ADD_STRING,

  OP_ANSISTRING_CLR,
  OP_WIDESTRING_CLR,
  OP_UNICSTRING_CLR,
  OP_INTERFACE_CLR,
  OP_CLASS_CLR, // js only

  OP_EQ_STRUCT,
  OP_NE_STRUCT,

  OP_EQ_ANSISTRING,
  OP_NE_ANSISTRING,

  OP_GT_ANSISTRING,
  OP_GE_ANSISTRING,
  OP_LT_ANSISTRING,
  OP_LE_ANSISTRING,

  OP_GT_SHORTSTRING,
  OP_GE_SHORTSTRING,
  OP_LT_SHORTSTRING,
  OP_LE_SHORTSTRING,

  OP_GT_WIDESTRING,
  OP_GE_WIDESTRING,
  OP_LT_WIDESTRING,
  OP_LE_WIDESTRING,

  OP_GT_UNICSTRING,
  OP_GE_UNICSTRING,
  OP_LT_UNICSTRING,
  OP_LE_UNICSTRING,

  OP_EQ_SHORTSTRING,
  OP_EQ_WIDESTRING,
  OP_EQ_UNICSTRING,
  OP_NE_SHORTSTRING,
  OP_NE_WIDESTRING,
  OP_NE_UNICSTRING,

  OP_STRUCTURE_CLR,
  OP_STRUCTURE_ADDREF,

  OP_SHORTSTRING_FROM_PANSICHAR_LITERAL,
  OP_SHORTSTRING_FROM_PWIDECHAR_LITERAL,
  OP_SHORTSTRING_FROM_ANSICHAR,
  OP_SHORTSTRING_FROM_WIDECHAR,
  OP_SHORTSTRING_FROM_ANSISTRING,
  OP_SHORTSTRING_FROM_WIDESTRING,
  OP_UNICSTRING_FROM_WIDESTRING,
  OP_SHORTSTRING_FROM_UNICSTRING,
  OP_ANSISTRING_FROM_SHORTSTRING,

  OP_WIDESTRING_FROM_PANSICHAR_LITERAL,
  OP_WIDESTRING_FROM_PWIDECHAR_LITERAL,
  OP_WIDESTRING_FROM_ANSICHAR,
  OP_WIDESTRING_FROM_WIDECHAR,
  OP_ANSISTRING_FROM_WIDECHAR,
  OP_WIDESTRING_FROM_WIDECHAR_LITERAL,
  OP_WIDESTRING_FROM_ANSISTRING,
  OP_UNICSTRING_FROM_ANSISTRING,
  OP_WIDESTRING_FROM_SHORTSTRING,
  OP_WIDESTRING_FROM_UNICSTRING,
  OP_UNICSTRING_FROM_SHORTSTRING,
  OP_ANSISTRING_FROM_WIDESTRING,
  OP_ANSISTRING_FROM_UNICSTRING,

  OP_UNICSTRING_FROM_PANSICHAR_LITERAL,
  OP_UNICSTRING_FROM_PWIDECHAR_LITERAL,
  OP_UNICSTRING_FROM_ANSICHAR,
  OP_UNICSTRING_FROM_WIDECHAR,
  OP_UNICSTRING_FROM_WIDECHAR_LITERAL,

  OP_VARIANT_FROM_CLASS, // JS only
  OP_VARIANT_FROM_POINTER, // JS only
  OP_CLASS_FROM_VARIANT, // JS only

  OP_INTERFACE_FROM_CLASS,
  OP_INTERFACE_CAST,

  OP_VARIANT_FROM_PANSICHAR_LITERAL,
  OP_VARIANT_FROM_PWIDECHAR_LITERAL,
  OP_VARIANT_FROM_ANSISTRING,
  OP_VARIANT_FROM_WIDESTRING,
  OP_VARIANT_FROM_UNICSTRING,
  OP_VARIANT_FROM_SHORTSTRING,
  OP_VARIANT_FROM_ANSICHAR,
  OP_VARIANT_FROM_WIDECHAR,
  OP_VARIANT_FROM_WIDECHAR_LITERAL,
  OP_VARIANT_FROM_INT,
  OP_VARIANT_FROM_INT64,
  OP_VARIANT_FROM_BYTE,
  OP_VARIANT_FROM_BOOL,
  OP_VARIANT_FROM_WORD,
  OP_VARIANT_FROM_CARDINAL,
  OP_VARIANT_FROM_SMALLINT,
  OP_VARIANT_FROM_SHORTINT,
  OP_VARIANT_FROM_DOUBLE,
  OP_VARIANT_FROM_CURRENCY,
  OP_VARIANT_FROM_SINGLE,
  OP_VARIANT_FROM_EXTENDED,
  OP_VARIANT_FROM_INTERFACE,

  OP_OLEVARIANT_FROM_VARIANT,
  OP_OLEVARIANT_FROM_PANSICHAR_LITERAL,
  OP_OLEVARIANT_FROM_PWIDECHAR_LITERAL,
  OP_OLEVARIANT_FROM_ANSISTRING,
  OP_OLEVARIANT_FROM_WIDESTRING,
  OP_OLEVARIANT_FROM_UNICSTRING,
  OP_OLEVARIANT_FROM_SHORTSTRING,
  OP_OLEVARIANT_FROM_ANSICHAR,
  OP_OLEVARIANT_FROM_WIDECHAR,
  OP_OLEVARIANT_FROM_WIDECHAR_LITERAL,
  OP_OLEVARIANT_FROM_INT,
  OP_OLEVARIANT_FROM_INT64,
  OP_OLEVARIANT_FROM_BYTE,
  OP_OLEVARIANT_FROM_BOOL,
  OP_OLEVARIANT_FROM_WORD,
  OP_OLEVARIANT_FROM_CARDINAL,
  OP_OLEVARIANT_FROM_SMALLINT,
  OP_OLEVARIANT_FROM_SHORTINT,
  OP_OLEVARIANT_FROM_DOUBLE,
  OP_OLEVARIANT_FROM_CURRENCY,
  OP_OLEVARIANT_FROM_SINGLE,
  OP_OLEVARIANT_FROM_EXTENDED,
  OP_OLEVARIANT_FROM_INTERFACE,

  OP_ANSISTRING_FROM_INT, // JS only
  OP_ANSISTRING_FROM_DOUBLE, // JS only
  OP_ANSISTRING_FROM_SINGLE, // JS only
  OP_ANSISTRING_FROM_EXTENDED, // JS only
  OP_ANSISTRING_FROM_BOOLEAN, // JS only

  OP_UNICSTRING_FROM_INT, // JS only
  OP_UNICSTRING_FROM_DOUBLE, // JS only
  OP_UNICSTRING_FROM_SINGLE, // JS only
  OP_UNICSTRING_FROM_EXTENDED, // JS only
  OP_UNICSTRING_FROM_BOOLEAN, // JS only

  OP_JS_FUNC_OBJ_FROM_VARIANT, // JS only

  OP_ANSISTRING_FROM_VARIANT,
  OP_WIDESTRING_FROM_VARIANT,
  OP_UNICSTRING_FROM_VARIANT,
  OP_SHORTSTRING_FROM_VARIANT,
  OP_DOUBLE_FROM_VARIANT,
  OP_CURRENCY_FROM_VARIANT,
  OP_SINGLE_FROM_VARIANT,
  OP_EXTENDED_FROM_VARIANT,
  OP_INT64_FROM_VARIANT,
  OP_INT_FROM_VARIANT,
  OP_BYTE_FROM_VARIANT,
  OP_WORD_FROM_VARIANT,
  OP_CARDINAL_FROM_VARIANT,
  OP_BOOL_FROM_VARIANT,
  OP_BYTEBOOL_FROM_VARIANT,
  OP_WORDBOOL_FROM_VARIANT,
  OP_LONGBOOL_FROM_VARIANT,
  OP_SMALLINT_FROM_VARIANT,
  OP_SHORTINT_FROM_VARIANT,

  OP_NOT_VARIANT,
  OP_NEG_VARIANT,
  OP_ADD_VARIANT,
  OP_SUB_VARIANT,
  OP_MULT_VARIANT,
  OP_DIV_VARIANT,
  OP_IDIV_VARIANT,
  OP_MOD_VARIANT,
  OP_SHL_VARIANT,
  OP_SHR_VARIANT,
  OP_AND_VARIANT,
  OP_OR_VARIANT,
  OP_XOR_VARIANT,
  OP_LT_VARIANT,
  OP_LE_VARIANT,
  OP_GT_VARIANT,
  OP_GE_VARIANT,
  OP_EQ_VARIANT,
  OP_NE_VARIANT,

  OP_EQ_EVENT,
  OP_NE_EVENT,

  OP_VARIANT_CLR,
  OP_VARARRAY_GET,
  OP_VARARRAY_PUT,
  OP_VARARRAY_IDX,

  OP_ADD_INT_MI,
  OP_ADD_INT_MM,

  OP_SUB_INT_MI,
  OP_SUB_INT_MM,

  OP_IMUL_INT_MI,
  OP_IMUL_INT_MM,

  OP_IDIV_INT_MI,
  OP_IDIV_INT_MM,
  OP_IDIV_INT_IM,

  OP_MOD_INT_MI,
  OP_MOD_INT_MM,
  OP_MOD_INT_IM,

  OP_SHL_INT_MI,
  OP_SHL_INT_MM,
  OP_SHL_INT_IM,

  OP_SHR_INT_MI,
  OP_SHR_INT_MM,
  OP_SHR_INT_IM,

  OP_AND_INT_MI,
  OP_AND_INT_MM,

  OP_OR_INT_MI,
  OP_OR_INT_MM,

  OP_XOR_INT_MI,
  OP_XOR_INT_MM,

  OP_NEG_INT,
  OP_NEG_INT64,

  OP_ABS_INT,
  OP_ABS_INT64,
  OP_ABS_DOUBLE,
  OP_ABS_SINGLE,
  OP_ABS_EXTENDED,
  OP_ABS_VARIANT,

  OP_LT_INT_MI,
  OP_LT_INT_MM,

  OP_LE_INT_MI,
  OP_LE_INT_MM,

  OP_GT_INT_MI,
  OP_GT_INT_MM,

  OP_GE_INT_MI,
  OP_GE_INT_MM,

  OP_EQ_INT_MI,
  OP_EQ_INT_MM,

  OP_NE_INT_MI,
  OP_NE_INT_MM,

  OP_ADD_INT64,
  OP_SUB_INT64,
  OP_AND_INT64,
  OP_OR_INT64,
  OP_XOR_INT64,

  OP_LT_INT64,
  OP_LE_INT64,
  OP_GT_INT64,
  OP_GE_INT64,
  OP_EQ_INT64,
  OP_NE_INT64,

  OP_ADD_CURRENCY,
  OP_SUB_CURRENCY,
  OP_MUL_CURRENCY,
  OP_DIV_CURRENCY,

  OP_LT_CURRENCY,
  OP_LE_CURRENCY,
  OP_GT_CURRENCY,
  OP_GE_CURRENCY,
  OP_EQ_CURRENCY,
  OP_NE_CURRENCY,


  OP_ADD_DOUBLE,
  OP_SUB_DOUBLE,
  OP_MUL_DOUBLE,
  OP_DIV_DOUBLE,

  OP_NEG_DOUBLE,
  OP_NEG_CURRENCY,

  OP_LT_DOUBLE,
  OP_LE_DOUBLE,
  OP_GT_DOUBLE,
  OP_GE_DOUBLE,
  OP_EQ_DOUBLE,
  OP_NE_DOUBLE,

  OP_ADD_SINGLE,
  OP_SUB_SINGLE,
  OP_MUL_SINGLE,
  OP_DIV_SINGLE,

  OP_NEG_SINGLE,

  OP_LT_SINGLE,
  OP_LE_SINGLE,
  OP_GT_SINGLE,
  OP_GE_SINGLE,
  OP_EQ_SINGLE,
  OP_NE_SINGLE,

  OP_ADD_EXTENDED,
  OP_SUB_EXTENDED,
  OP_MUL_EXTENDED,
  OP_DIV_EXTENDED,

  OP_NEG_EXTENDED,

  OP_LT_EXTENDED,
  OP_LE_EXTENDED,
  OP_GT_EXTENDED,
  OP_GE_EXTENDED,
  OP_EQ_EXTENDED,
  OP_NE_EXTENDED,

  OP_PUSH_EBP,
  OP_POP,

  OP_PUSH_ADDRESS,
  OP_PUSH_STRUCTURE,
  OP_PUSH_SET,

  OP_PUSH_BYTE_IMM,
  OP_PUSH_BYTE,
  OP_PUSH_WORD_IMM,
  OP_PUSH_WORD,
  OP_PUSH_CARDINAL_IMM,
  OP_PUSH_CARDINAL,
  OP_PUSH_SMALLINT_IMM,
  OP_PUSH_SMALLINT,
  OP_PUSH_SHORTINT_IMM,
  OP_PUSH_SHORTINT,
  OP_PUSH_INT_IMM,
  OP_PUSH_INT,
  OP_PUSH_DOUBLE,
  OP_PUSH_CURRENCY,
  OP_PUSH_SINGLE,
  OP_PUSH_EXTENDED,
  OP_PUSH_ANSISTRING,
  OP_PUSH_SHORTSTRING,
  OP_PUSH_WIDESTRING,
  OP_PUSH_UNICSTRING,
  OP_PUSH_PANSICHAR_IMM,
  OP_PUSH_PWIDECHAR_IMM,
  OP_PUSH_INST,
  OP_PUSH_CLSREF,
  OP_PUSH_DYNARRAY,
  OP_PUSH_INT64,
  OP_PUSH_DATA,
  OP_PUSH_EVENT,

  OP_SET_ASSIGN,
  OP_SET_UNION,
  OP_SET_DIFFERENCE,
  OP_SET_INTERSECTION,
  OP_SET_SUBSET,
  OP_SET_SUPERSET,
  OP_SET_EQUALITY,
  OP_SET_INEQUALITY,
  OP_SET_MEMBERSHIP,

  OP_GET_ANSISTR_PROP,
  OP_SET_ANSISTR_PROP,

  OP_GET_WIDESTR_PROP,
  OP_SET_WIDESTR_PROP,

  OP_GET_UNICSTR_PROP,
  OP_SET_UNICSTR_PROP,

  OP_GET_ORD_PROP,
  OP_SET_ORD_PROP,

  OP_GET_INTERFACE_PROP,
  OP_SET_INTERFACE_PROP,

  OP_GET_SET_PROP,
  OP_SET_SET_PROP,

  OP_GET_FLOAT_PROP,
  OP_SET_FLOAT_PROP,

  OP_GET_VARIANT_PROP,
  OP_SET_VARIANT_PROP,

  OP_GET_INT64_PROP,
  OP_SET_INT64_PROP,

  OP_GET_EVENT_PROP,
  OP_SET_EVENT_PROP,
  OP_SET_EVENT_PROP2,
  OP_CREATE_METHOD

  : Integer;

  ASM_NOP,
  ASM_WAIT,
  ASM_CLC,
  ASM_PUSHFD,
  ASM_POPFD,
  ASM_XCHG,

  ASM_MOV,
  ASM_LEA,
  ASM_TEST,

  ASM_ADD,
  ASM_ADC,
  ASM_SBB,
  ASM_NEG,
  ASM_SUB,

  ASM_MUL,
  ASM_IMUL,
  ASM_DIV,
  ASM_IDIV,
  ASM_XOR,
  ASM_AND,
  ASM_OR,
  ASM_SHL,
  ASM_SHR,

  ASM_CDQ,

  ASM_CALL,
  ASM_RET,
  ASM_PUSH,
  ASM_POP,
  ASM_JMP,

  ASM_JNO,
  ASM_JNC,
  ASM_JZ,
  ASM_JNZ,
  ASM_JBE,
  ASM_JNLE,

  ASM_FLD,
  ASM_FILD,
  ASM_FISTP,
  ASM_FSTP,
  ASM_FADD,
  ASM_FSUB,
  ASM_FMUL,
  ASM_FDIV,
  ASM_FCOMP,
  ASM_FCOMPP,
  ASM_FSTSV,
  ASM_SAHF,
  ASM_FCHS,
  ASM_FABS,

  ASM_SETL,
  ASM_SETLE,
  ASM_SETNLE,
  ASM_SETNL,

  ASM_SETB,
  ASM_SETBE,
  ASM_SETNBE,
  ASM_SETNB,
  ASM_SETZ,
  ASM_SETNZ,

  ASM_CMP,

  ASM_REP_MOVSB,
  ASM_REP_MOVSD

  : Integer;

type
  TIsJSType = function (T: Integer): Boolean;
function _IsJSType(T: Integer): Boolean;
var
  IsJSType: TIsJSType = _IsJSType;
type
  TSavePCUEvent = function (Sender: TObject; const UnitName: String): TStream
    of object;
  TLoadPCUEvent = function (Sender: TObject; const UnitName: String): TStream
    of object;

  TExceptionClass = class of Exception;
  TCharSet = set of AnsiChar;

  PPointer = ^Pointer;

  TClassVisibility = (cvNone, cvPrivate, cvProtected, cvPublic, cvPublished);
  
  TBytes = array[0..1000000000] of Byte;
  PBytes = ^TBytes;

  TIntegers = array[0..100000] of Integer;
  PIntegers = ^ TIntegers;
  TPointers = array[0..100000] of Pointer;
  PPointers = ^ TPointers;

  TByteSet = set of Byte;

  TTokenClass = (tcNone, tcSeparator, tcKeyword, tcIdentifier,
                 tcBooleanConst, tcCharConst, tcPCharConst, tcIntegerConst,
                 tcDoubleConst, tcNumCharConst, tcVariantConst,
                 tcSpecial);

  TTypedList = class
  private
    function GetCount: Integer;
  public
    L: TList;
    constructor Create;
    destructor Destroy; override;
    procedure Clear; virtual;
    property Count: Integer read GetCount;
  end;

  TIntegerList = class
  private
    fItems: TList;
    function GetItem(I: Integer): Integer;
    procedure SetItem(I: Integer; value: Integer);
    function GetCount: Integer;
  public
    constructor Create;
    destructor Destroy; override;
    procedure Clear;
    function Add(value: Integer): Integer;
    procedure Insert(I: Integer; value: Integer);
    function IndexOf(value: Integer): Integer;
    procedure RemoveAt(I: Integer);
    procedure DeleteValue(value: Integer);
    function Top: Integer;
    procedure SaveToStream(S: TStream);
    procedure LoadFromStream(S: TStream);
    function SaveToPtr(P: Pointer): Integer;
    function LoadFromPtr(P: Pointer): Integer;
    function Clone: TIntegerList;
    property Count: Integer read GetCount;
    property Items[I: Integer]: Integer read GetItem write SetItem; default;
    property Last: Integer read Top;
  end;

  TIntegerStack = class(TIntegerList)
  public
    procedure Push(value: Integer);
    function Pop: Integer;
    function Depth(value: Integer): Integer;
  end;

  TAssocIntegers = class
  private
    function GetCount: Integer;
  public
    Keys, Values: TIntegerList;
    constructor Create;
    destructor Destroy; override;
    procedure Add(Key, Value: Integer);
    procedure SaveToStream(S: TStream);
    procedure LoadFromStream(S: TStream);
    function SaveToPtr(P: Pointer): Integer;
    function LoadFromPtr(P: Pointer): Integer;
    property Count: Integer read GetCount;
  end;

  TStdTypeRec = class
  public
    Name: String;
    TypeID: Integer;
    Size: Integer;
    NativeName: String;
  end;

  TStdTypeList = class
  private
    L: TList;
    function GetRecord(I: Integer): TStdTypeRec;
  public
    constructor Create;
    destructor Destroy; override;
    function Add(const TypeName: String; Size: Integer): Integer;
    function IndexOf(const S: String): Integer;
    function Count: Integer;
    function GetSize(TypeID: Integer): Integer;
    property Records[I: Integer]: TStdTypeRec read GetRecord; default;
  end;

  THashArray = class
  private
    function GetMaxId: Integer;
  public
    A: array[0..MaxHash] of TIntegerList;
    constructor Create;
    destructor Destroy; override;
    procedure AddName(const S: String; Id: Integer);
    procedure DeleteName(const S: String; Id: Integer);
    procedure Clear;
    function Clone: THashArray;
    function GetList(const S: String): TIntegerList;
    property MaxId: Integer read GetMaxId;
  end;

  PaxCompilerException = class(Exception)
  end;

  PaxCancelException = class(EAbort)
  end;

  PaxExitException = class(EAbort);

  TParamData = record
    Flags: TParamFlags;
    ParamName, TypeName: ShortString;
  end;
  PParamData = ^TParamData;

  TGuidRec = class
  public
    GUID: TGUID;
    Id: Integer;
    Name: String;
    GuidIndex: Integer;
    procedure SaveToStream(S: TWriter);
    procedure LoadFromStream(S: TReader);
  end;

  TGuidList = class
  private
    L: TList;
    function GetRecord(I: Integer): TGuidRec;
  public
    constructor Create;
    destructor Destroy; override;
    function Count: Integer;
    procedure Clear;
    function Add(const GUID: TGUID; Id: Integer;
                 const Name: String): TGuidRec;
    function Clone: TGuidList;
    function IndexOf(const GUID: TGUID): Integer;
    function GetGuidByID(Id: Integer): TGUID;
    function HasId(Id: Integer): Boolean;
    procedure Delete(I: Integer);
    procedure SaveToStream(S: TWriter);
    procedure LoadFromStream(S: TReader);
    property Records[I: Integer]: TGuidRec read GetRecord; default;
  end;

function StrEql(const S1, S2: String): Boolean;
function ShiftPointer(P: Pointer; L: Integer): Pointer;
function AlignLeft(const S: String; L: Integer): String;
function ByteToHex(B: Byte): String;
function IsShortInt(I: Integer): Boolean;

function IsEmpty(const V: Variant): Boolean;

function StrRefCountPtr(S: Pointer): Pointer;
function StrRefCount(S: Pointer): Integer;
function StrSizePtr(S: Pointer): Pointer;
function StrSize(S: Pointer): Integer;

function SaveStringListToStream(L: TStringList; P: TStream): Integer;
function LoadStringListFromStream(L: TStringList; P: TStream): Integer;

procedure SaveStringToStream(const S: String; P: TStream);
function LoadStringFromStream(P: TStream): String;

procedure SaveWideStringToStream(const S: WideString; P: TStream);
function LoadWideStringFromStream(P: TStream): WideString;

procedure SaveShortStringToStream(const S: ShortString; P: TStream);
function LoadShortStringFromStream(P: TStream): ShortString;

procedure SaveVariantToStream(const Value: Variant; S: TStream);
function LoadVariantFromStream(S: TStream): Variant;

procedure SaveIntegerToStream(Value: Integer; S: TStream);
function LoadIntegerFromStream(S: TStream): Integer;

function Int32ToByteSet(value: Integer): TByteSet;
function ByteSetToInt32(value: TByteSet): Integer;
function ByteSetToString(value: TByteSet; FinTypeId: Integer): String;

function Norm(const S: String; L: Integer): String;

function HashNumber(const S: String): Integer;

function RemoveWhiteSpaces(const S: String): String;
function PosCh(ch: Char; const S: String): Integer;
function CountCh(ch: Char; const S: String): Integer;
procedure ReplaceCh(var result: String; Source, Dest: Char);
function RemoveCh(Ch: Char; const S: String): String;
function RemoveChars(C: TCharSet; const S: String): String;
function IsPositiveInt(S: PChar): Boolean;

function GuidsAreEqual(const G1, G2: TGUID): Boolean;
function ExtractName(const S: String): String;
function ExtractFullName(const S: String): String;
function ExtractClassName(const S: String): String;
function ExtractOwner(const S: String): String;
function ExtractFullOwner(const S: String): String;

function ChCount(const S: String; Ch: Char): Integer;

function CLSIDFromString(psz: PWideString; out clsid: TGUID): HResult; stdcall;

var
  Types: TStdTypeList;
  Kinds: TStringList;
  Operators: TStringList;

  AsmOperators: TStringList;
  DynDestrList: TIntegerList;

function IsDynDestr(OP: Integer): Boolean;
procedure ErrMessageBox(const S:  String);

type
  TVarPathRec = class
  public
    Id: Integer;
    VarCount: Int64;
  end;

  TVarPath = class
  private
    L: TList;
    function GetCount: Integer;
    function GetItem(I: Integer): TVarPathRec;
  public
    constructor Create;
    destructor Destroy; override;
    procedure Clear;
    function Add(Id: Integer; VarCount: Int64): TVarPathRec;
    function IndexOf(VarCount: Int64): Integer;
    function LastIndexOf(VarCount: Int64): Integer;
    property Count: Integer read GetCount;
    property Items[I: Integer]: TVarPathRec read GetItem; default;
  end;

  TVarPathList = class
  private
    L: TList;
    function GetCount: Integer;
    function GetPath(I: Integer): TVarPath;
  public
    constructor Create;
    destructor Destroy; override;
    procedure Clear;
    function AddPath: TVarPath;
    procedure Add(Id: Integer; VarCount: Int64);
    function GetLevel(VarCount: Int64): Integer;
    property Count: Integer read GetCount;
    property Pathes[I: Integer]: TVarPath read GetPath; default;
  end;

  TSomeTypeRec = class
  public
    Name: String;
    Id: Integer;
  end;

  TSomeTypeList = class
  private
    L: TList;
    function GetCount: Integer;
    function GetRecord(I: Integer): TSomeTypeRec;
  public
    constructor Create;
    destructor Destroy; override;
    procedure Clear;
    function Add(const Name: String; Id: Integer): TSomeTypeRec;
    procedure Delete(I: Integer);
    function Clone: TSomeTypeList;
    function IndexOf(const Name: String): Integer;
    property Count: Integer read GetCount;
    property Records[I: Integer]: TSomeTypeRec read GetRecord; default;
  end;

  TExternRecKind = (erNone, erLevel, erTypeId,
                    erOwnerId, erPatternId,
                    erAncestorId, erReadId, erWriteId,
                    ePropertyInBaseClassId,
                    erGUID);

  TCheckProc = function (const TypeName: String; Data: Pointer;
                         errKind: TExternRecKind): Boolean;

  TExternRec = class
  public
    Id: Integer;
    FullName: String;
    RecKind: TExternRecKind;
    procedure SaveToStream(S: TWriter);
    procedure LoadFromStream(S: TReader);
  end;

  TExternList = class
  private
    L: TList;
    function GetRecord(I: Integer): TExternRec;
    function GetCount: Integer;
  public
    constructor Create;
    destructor Destroy; override;
    procedure Clear;
    function Add(Id: Integer; const FullName: String;
                 RecKind: TExternRecKind): TExternRec;
    function Clone: TExternList;
    procedure SaveToStream(S: TWriter);
    procedure LoadFromStream(S: TReader);
    property Count: Integer read GetCount;
    property Records[I: Integer]: TExternRec read GetRecord; default;
  end;

  TFastStringList = class
  private
    L: TStringList;
    X: THashArray;
  public
    constructor Create;
    destructor Destroy; override;
    function Add(const S: String): Integer;
    function IndexOfEx(const S: String; Upcase: Boolean): Integer;
  end;

  TUndeclaredTypeRec = class
  public
    Id, ErrorIndex: Integer;
  end;

  TUndeclaredTypeList = class(TStringList)
    procedure Reset;
  end;

function GetImplementorOfInterface(const I: IUnknown): TObject;
function IsValidName(const S: String): Boolean;

type
  PClass = ^TClass;
  PSafeCallException = function  (Self: TObject; ExceptObject:
    TObject; ExceptAddr: Pointer): HResult;
  PAfterConstruction = procedure (Self: TObject);
  PBeforeDestruction = procedure (Self: TObject);
  PDispatch          = procedure (Self: TObject; var Message);
  PDefaultHandler    = procedure (Self: TObject; var Message);
  PNewInstance       = function  (Self: TClass) : TObject;
  PFreeInstance      = procedure (Self: TObject);
  PDestroy           = procedure (Self: TObject; OuterMost: ShortInt);
  PVmt = ^TVmt;

{$IFDEF UNIC}

{ Virtual method table entries }
{
  vmtSelfPtr           = -88;
  vmtIntfTable         = -84;
  vmtAutoTable         = -80;
  vmtInitTable         = -76;
  vmtTypeInfo          = -72;
  vmtFieldTable        = -68;
  vmtMethodTable       = -64;
  vmtDynamicTable      = -60;
  vmtClassName         = -56;
  vmtInstanceSize      = -52;
  vmtParent            = -48;
  vmtEquals            = -44 deprecated 'Use VMTOFFSET in asm code';
  vmtGetHashCode       = -40 deprecated 'Use VMTOFFSET in asm code';
  vmtToString          = -36 deprecated 'Use VMTOFFSET in asm code';
  vmtSafeCallException = -32 deprecated 'Use VMTOFFSET in asm code';
  vmtAfterConstruction = -28 deprecated 'Use VMTOFFSET in asm code';
  vmtBeforeDestruction = -24 deprecated 'Use VMTOFFSET in asm code';
  vmtDispatch          = -20 deprecated 'Use VMTOFFSET in asm code';
  vmtDefaultHandler    = -16 deprecated 'Use VMTOFFSET in asm code';
  vmtNewInstance       = -12 deprecated 'Use VMTOFFSET in asm code';
  vmtFreeInstance      = -8 deprecated 'Use VMTOFFSET in asm code';
  vmtDestroy           = -4 deprecated 'Use VMTOFFSET in asm code';
}

  TVmt = packed record
    SelfPtr           : TClass;              // -88	pointer to virtual method table (or nil)
    IntfTable         : Pointer;             // -84	pointer to interface table (or nil)
    AutoTable         : Pointer;             // -80	pointer to Automation information table (or nil)
    InitTable         : Pointer;             // -76	pointer to instance initialization table (or nil)
    TypeInfo          : Pointer;             // -72	pointer to type information table (or nil)
    FieldTable        : Pointer;             // -58	pointer to field definition table (or nil)
    MethodTable       : Pointer;             // -64	pointer to method definition table (or nil)
    DynamicTable      : Pointer;             // -60	pointer to dynamic method table (or nil)
    ClassName         : PShortString;        // -56	pointer to short string containing class name
    InstanceSize      : Cardinal;            // -52	instance size in bytes
    Parent            : PClass;              // -48	pointer to a pointer to ancestor class (or nil)
    Equals            : Pointer;             // -44 deprecated 'Use VMTOFFSET in asm code';
    GetHashCode       : Pointer;             // -40
    ToString          : Pointer;             // -36
    SafeCallException : PSafeCallException;  // -32	pointer to entry point of SafecallException method (or nil)
    AfterConstruction : PAfterConstruction;  // -28	entry point of AfterConstruction method
    BeforeDestruction : PBeforeDestruction;  // -24	entry point of BeforeDestruction method
    Dispatch          : PDispatch;           // -20	entry point of Dispatch method
    DefaultHandler    : PDefaultHandler;     // -16	entry point of DefaultHandler method
    NewInstance       : PNewInstance;        // -12	entry point of NewInstance method
    FreeInstance      : PFreeInstance;       // -8	entry point of FreeInstance method
    Destroy           : PDestroy;            // -4	entry point of Destroy destructor
   {UserDefinedVirtuals: array[0..999] of procedure;}
  end;

{$ELSE}
  TVmt = packed record
    SelfPtr           : TClass;              // -76	pointer to virtual method table (or nil)
    IntfTable         : Pointer;             // -72	pointer to interface table (or nil)
    AutoTable         : Pointer;             // -68	pointer to Automation information table (or nil)
    InitTable         : Pointer;             // -64	pointer to instance initialization table (or nil)
    TypeInfo          : Pointer;             // -60	pointer to type information table (or nil)
    FieldTable        : Pointer;             // -56	pointer to field definition table (or nil)
    MethodTable       : Pointer;             // -52	pointer to method definition table (or nil)
    DynamicTable      : Pointer;             // -48	pointer to dynamic method table (or nil)
    ClassName         : PShortString;        // -44	pointer to short string containing class name
    InstanceSize      : Cardinal;            // -40	instance size in bytes
    Parent            : PClass;              // -36	pointer to a pointer to ancestor class (or nil)
    SafeCallException : PSafeCallException;  // -32	pointer to entry point of SafecallException method (or nil)
    AfterConstruction : PAfterConstruction;  // -28	entry point of AfterConstruction method
    BeforeDestruction : PBeforeDestruction;  // -24	entry point of BeforeDestruction method
    Dispatch          : PDispatch;           // -20	entry point of Dispatch method
    DefaultHandler    : PDefaultHandler;     // -16	entry point of DefaultHandler method
    NewInstance       : PNewInstance;        // -12	entry point of NewInstance method
    FreeInstance      : PFreeInstance;       // -8	entry point of FreeInstance method
    Destroy           : PDestroy;            // -4	entry point of Destroy destructor
   {UserDefinedVirtuals: array[0..999] of procedure;}
  end;
{$ENDIF}

function GetVmtFromClass(AClass: TClass): PVmt;
function GetVmtFromObject(Instance: TObject): PVmt;
function GetClassFromVMT(Vmt: PVmt): TClass;
function GetDestructorAddress(AClass: TClass): Pointer;

const
  MaxVirtuals = 999;
  strPaxSignature = 'This is a pax class';
  PaxSignatureLength = 19;
type
  PPointerArray = ^TPointerArray;
  TPointerArray = array[0..MaxVirtuals] of pointer;

  PPaxInfo = ^TPaxInfo;
  TPaxInfo = packed record
    PaxSignature: String[PaxSignatureLength];
    Prog: Pointer;
    ClassIndex: Integer;
  end;

  PPaxClassRec = ^TPaxClassRec;
  TPaxClassRec = packed record
    PaxInfo: TPaxInfo;
    VMT: TVMT;
    UserDefinedVirtuals: TPointerArray;
  end;

function GetPaxInfo(C: TClass): PPaxInfo;
function IsPaxObject(X: TObject): Boolean;
function IsPaxClass(C: TClass): Boolean;

function GetIntResultType(T1, T2: Integer): Integer;

{$IFDEF UNIC}
{$ELSE}
function CharInSet(C: AnsiChar; const CharSet: TCharSet): Boolean;
{$ENDIF}

type
  PVmtMethod = ^TVmtMethod;
  TVmtMethod = packed record
  {$ifdef WIN32}
    Size: Word;
  {$endif}
    Address: Pointer;
    Name: ShortString;
  end;

  PVmtMethodTable = ^TVmtMethodTable;
  TVmtMethodTable = packed record
    Count: Word;
    Methods: array[0..MaxListSize] of Byte;
    { Methods: array[1..Count] of TVmtMethod; }
  end;

  PFieldClassTable = ^TFieldClassTable;
  TFieldClassTable = packed record
    Count: Smallint;
    Classes: array [0..8191] of ^TPersistentClass;
  end;

  PVmtField = ^TVmtField;
  TVmtField = packed record
    Offset: Cardinal;    { Offset of field in the class data. }
    ClassIndex: Word;    { Index in the FieldClassTable. }
    Name: ShortString;
  end;

  PVmtFieldTable = ^TVmtFieldTable;
  TVmtFieldTable = packed record
    Count: Word;
    FieldClassTable: {$ifdef WIN32} PFieldClassTable {$else} Word {$endif};
    Fields: packed array[0..MaxListSize] of Byte;
    { Fields: packed array [1..Count] of TVmtField; }
  end;

function GetMethodSize(PMethod: PVmtMethod): Cardinal;
function GetFieldSize(PField: PVmtField): Cardinal;
function GetFieldTable(AClass: TClass): PVmtFieldTable;
function GetFieldClassTableSize(FieldClassTable: PFieldClassTable): Integer;
function CreateFieldClassTable(InitCount: SmallInt): PFieldClassTable;
procedure DestroyFieldClassTable(FieldClassTable: PFieldClassTable);

function StringToGUID(const S: string): TGUID;
function GUIDToString(const GUID: TGUID): string;
function LoadText(const FileName: String): String;

type
  TStreamRec = class
  public
    UnitName: String;
    Stream: TMemoryStream;
    constructor Create;
    destructor Destroy;override;
  end;

  TStreamList = class(TTypedList)
  private
    function GetRecord(I: Integer): TStreamRec;
  public
    function IndexOf(const UnitName: String): Integer;
    procedure AddFromFile(const FileName: String);
    property Records[I: Integer]: TStreamRec read GetRecord; default;
  end;

implementation

constructor TStreamRec.Create;
begin
  inherited;
  Stream := TMemoryStream.Create;
end;

destructor TStreamRec.Destroy;
begin
  inherited;
  Stream.Free;
end;

function TStreamList.GetRecord(I: Integer): TStreamRec;
begin
  result := TStreamRec(L[I]);
end;

function TStreamList.IndexOf(const UnitName: String): Integer;
var
  I: Integer;
begin
  result := -1;
  for I := 0 to Count - 1 do
    if StrEql(UnitName, Records[I].UnitName) then
    begin
      result := I;
      Exit;
    end;
end;

procedure TStreamList.AddFromFile(const FileName: String);
var
  UnitName: String;
  R: TStreamRec;
begin
  UnitName := ExtractOwner(FileName);
  if IndexOf(UnitName) <> -1 then
    Exit;
  R := TStreamRec.Create;
  R.UnitName := UnitName;
  R.Stream.LoadFromFile(FileName);
  L.Add(R);
end;

function StringToGUID(const S: string): TGUID;

  procedure InvalidGUID;
  begin
    raise Exception.Create(errSyntaxError);
  end;

  function HexChar(c: Char): Byte;
  begin
    case c of
      '0'..'9':  Result := Byte(c) - Byte('0');
      'a'..'f':  Result := (Byte(c) - Byte('a')) + 10;
      'A'..'F':  Result := (Byte(c) - Byte('A')) + 10;
    else
      InvalidGUID;
      Result := 0;
    end;
  end;

  function HexByte(p: PChar): Char;
  begin
    Result := Char((HexChar(p[0]) shl 4) + HexChar(p[1]));
  end;

var
  i: Integer;
  src, dest: PChar;
begin
  if ((Length(S) <> 38) or (s[1] <> '{')) then InvalidGUID;
  dest := @Result;
  src := PChar(s);
  Inc(src);
  for i := 0 to 3 do
    dest[i] := HexByte(src+(3-i)*2);
  Inc(src, 8);
  Inc(dest, 4);
  if src[0] <> '-' then InvalidGUID;
  Inc(src);
  for i := 0 to 1 do
  begin
    dest^ := HexByte(src+2);
    Inc(dest);
    dest^ := HexByte(src);
    Inc(dest);
    Inc(src, 4);
    if src[0] <> '-' then InvalidGUID;
    inc(src);
  end;
  dest^ := HexByte(src);
  Inc(dest);
  Inc(src, 2);
  dest^ := HexByte(src);
  Inc(dest);
  Inc(src, 2);
  if src[0] <> '-' then InvalidGUID;
  Inc(src);
  for i := 0 to 5 do
  begin
    dest^ := HexByte(src);
    Inc(dest);
    Inc(src, 2);
  end;
end;

function GUIDToString(const GUID: TGUID): string;
begin
  SetLength(Result, 38);
  StrLFmt(PChar(Result), 38,'{%.8x-%.4x-%.4x-%.2x%.2x-%.2x%.2x%.2x%.2x%.2x%.2x}',   // do not localize
    [GUID.D1, GUID.D2, GUID.D3, GUID.D4[0], GUID.D4[1], GUID.D4[2], GUID.D4[3],
    GUID.D4[4], GUID.D4[5], GUID.D4[6], GUID.D4[7]]);
end;

function CreateFieldClassTable(InitCount: SmallInt): PFieldClassTable;
var
  SZ: Integer;
begin
  SZ := SizeOf(SmallInt) + InitCount * SizeOf(Pointer);
  result := AllocMem(SZ);
  result^.Count := InitCount;
end;

procedure DestroyFieldClassTable(FieldClassTable: PFieldClassTable);
var
  SZ: Integer;
begin
  SZ := GetFieldClassTableSize(FieldClassTable);
  FreeMem(FieldClassTable, SZ);
end;

function GetFieldClassTableSize(FieldClassTable: PFieldClassTable): Integer;
begin
  result := SizeOf(FieldClassTable^.Count) +
            FieldClassTable^.Count * SizeOf(Pointer);
end;

function GetFieldTable(AClass: TClass): PVmtFieldTable; assembler;
asm
  MOV EAX, [EAX].vmtFieldTable
end;

function GetMethodSize(PMethod: PVmtMethod): Cardinal;
begin
{$ifdef WIN32}
  Result := PMethod^.Size;
{$else}
  Result := SizeOf(Pointer) + Length(PMethod^.Name) + 1; 
{$endif}
end;

function GetFieldSize(PField: PVmtField): Cardinal;
begin
  Result := SizeOf(PField^.Offset) + SizeOf(PField^.ClassIndex) +
            Length(PField^.Name) + 1;
end;

function IsDynDestr(OP: Integer): Boolean;
begin
  result := DynDestrList.IndexOf(OP) <> -1;
end;

function GetPaxInfo(C: TClass): PPaxInfo;
var
  P: Pointer;
begin
  result := nil;
  if C = nil then
    Exit;
  P := GetVMTFromClass(C);
  P := ShiftPointer(P, - SizeOf(TPaxInfo));
  if Byte(P^) = PaxSignatureLength then
    if PShortString(P)^ = strPaxSignature then
      result := P;
end;

function IsPaxObject(X: TObject): Boolean;
begin
  if X = nil then
  begin
    result := false;
    Exit;
  end;

  result := IsPaxClass(X.ClassType);
end;

function IsPaxClass(C: TClass): Boolean;
begin
  if C = nil then
  begin
    result := false;
    Exit;
  end;

  result := GetPaxInfo(C) <> nil;
end;

function GetVmtFromClass(AClass: TClass): PVmt;
begin
  if AClass = nil then
  begin
    result := nil;
    Exit;
  end;

  Result := PVmt(AClass);
  Dec(Result);
end;

function GetDestructorAddress(AClass: TClass): Pointer;
begin
  result := ShiftPointer(AClass, -4);
  result := Pointer(result^);
end;

function GetVmtFromObject(Instance: TObject): PVmt;
begin
  Result := GetVmtFromClass(Instance.ClassType);
end;

function GetClassFromVMT(Vmt: PVmt): TClass;
begin
  if Vmt = nil then
  begin
    result := nil;
    Exit;
  end;

  Inc(Vmt);
  result := TClass(Vmt);
end;

function ChCount(const S: String; Ch: Char): Integer;
var
  I: Integer;
begin
  result := 0;
  for I:=1 to Length(S) do
    if S[I] = Ch then
      Inc(result);
end;

function GetIntResultType(T1, T2: Integer): Integer;
begin
  result := typeINTEGER;
  if not ((T1 in IntegerTypes) and (T2 in IntegerTypes)) then
    raise Exception.Create(errInternalError);
  if (T1 in UnsignedIntegerTypes) or (T2 in UnsignedIntegerTypes) then
    result := typeCARDINAL;
  if (T1 = typeINT64) or (T2 = typeINT64) then
    result := typeINT64;
end;

function GetImplementorOfInterface(const I: IUnknown): TObject;
{ TODO -cDOC : Original code by Hallvard Vassbotn }
{ TODO -cTesting : Check the implemetation for any further version of compiler }
const
  AddByte = $04244483; // opcode for ADD DWORD PTR [ESP+4], Shortint
  AddLong = $04244481; // opcode for ADD DWORD PTR [ESP+4], Longint
type
  PAdjustSelfThunk = ^TAdjustSelfThunk;
  TAdjustSelfThunk = packed record
    case AddInstruction: Longint of
      AddByte: (AdjustmentByte: ShortInt);
      AddLong: (AdjustmentLong: Longint);
  end;
  PInterfaceMT = ^TInterfaceMT;
  TInterfaceMT = packed record
    QueryInterfaceThunk: PAdjustSelfThunk;
  end;
  TInterfaceRef = ^PInterfaceMT;
var
  QueryInterfaceThunk: PAdjustSelfThunk;
begin
  try
    Result := Pointer(I);
    if Assigned(Result) then
    begin
      QueryInterfaceThunk := TInterfaceRef(I)^.QueryInterfaceThunk;
      case QueryInterfaceThunk.AddInstruction of
        AddByte:
          Inc(PChar(Result), QueryInterfaceThunk.AdjustmentByte);
        AddLong:
          Inc(PChar(Result), QueryInterfaceThunk.AdjustmentLong);
      else
        Result := nil;
      end;
    end;
  except
    Result := nil;
  end;
end;

function IsValidName(const S: String): Boolean;
var
  I: Integer;
begin
  if S = '' then
  begin
    result := false;
    Exit;
  end;
  result := true;
  for I := 1 to Length(S) do
    if not (AnsiChar(S[I]) in ['a'..'z','A'..'Z','_','0'..'9']) then
    begin
      result := false;
      Exit;
    end;
end;

// TTypedList ------------------------------------------------------------------

constructor TTypedList.Create;
begin
  inherited;
  L := TList.Create;
end;

destructor TTypedList.Destroy;
begin
  Clear;
  L.Free;
  inherited;
end;

function TTypedList.GetCount: Integer;
begin
  result := L.Count;
end;

procedure TTypedList.Clear;
var
  I: Integer;
begin
  for I:=0 to L.Count - 1 do
    TObject(L[I]).Free;
  L.Clear;
end;

// TUndeclaredTypeList ---------------------------------------------------------

procedure TUndeclaredTypeList.Reset;
var
  I: Integer;
begin
  for I:= 0 to Count - 1 do
    Objects[I].Free;
  Clear;
end;

// TFastStringList -------------------------------------------------------------

constructor TFastStringList.Create;
begin
  inherited;
  L := TStringList.Create;
  X := THashArray.Create;
end;

destructor TFastStringList.Destroy;
begin
  L.Free;
  X.Free;
  inherited;
end;

function TFastStringList.Add(const S: String): Integer;
var
  H: Integer;
begin
  H := HashNumber(S);
  result := L.Add(S);
  X.A[H].Add(result);
end;

function TFastStringList.IndexOfEx(const S: String; Upcase: Boolean): Integer;
var
  I, J: Integer;
  List: TIntegerList;
begin
  result := -1;

  List := X.GetList(S);

  for I := 0 to List.Count - 1 do
  begin
    J := List[I];
    if Upcase then
    begin
      if StrEql(L[J], S) then
      begin
        result := J;
        Exit;
      end;
    end
    else
    begin
      if L[J] = S then
      begin
        result := J;
        Exit;
      end;
    end;
  end;
end;

// TExternRec ------------------------------------------------------------------

procedure TExternRec.SaveToStream(S: TWriter);
begin
  S.WriteInteger(id);
  S.WriteString(FullName);
  S.Write(RecKind, SizeOf(RecKind));
end;

procedure TExternRec.LoadFromStream(S: TReader);
begin
  Id := S.ReadInteger;
  FullName := S.ReadString;
  S.Read(RecKind, SizeOf(RecKind));
end;

// TExternList -----------------------------------------------------------------

constructor TExternList.Create;
begin
  inherited;
  L := TList.Create;
end;

destructor TExternList.Destroy;
begin
  Clear;
  L.Free;
  inherited;
end;

procedure TExternList.Clear;
var
  I: Integer;
begin
  for I:=0 to Count - 1 do
    Records[I].Free;
  L.Clear;
end;

function TExternList.Clone: TExternList;
var
  I: Integer;
begin
  result := TExternList.Create;
  for I:=0 to Count - 1 do
    with Records[I] do
    begin
      result.Add(Id, FullName, RecKind);
    end;
end;

function TExternList.GetRecord(I: Integer): TExternRec;
begin
  result := TExternRec(L[I]);
end;

function TExternList.GetCount: Integer;
begin
  result := L.Count;
end;

function TExternList.Add(Id: Integer; const FullName: String;
                         RecKind: TExternRecKind): TExternRec;
begin
  result := TExternRec.Create;
  result.Id := Id;
  result.FullName := FullName;
  result.RecKind := RecKind;
  L.Add(result);
end;

procedure TExternList.SaveToStream(S: TWriter);
var
  I: Integer;
begin
  S.WriteInteger(Count);
  for I := 0 to Count - 1 do
    Records[I].SaveToStream(S);
end;

procedure TExternList.LoadFromStream(S: TReader);
var
  I, K: Integer;
  R: TExternRec;
begin
  K := S.ReadInteger;
  for I := 0 to K - 1 do
  begin
    R := TExternRec.Create;
    R.LoadFromStream(S);
    L.Add(R);
  end;
end;

// TSomeTypeList ---------------------------------------------------------------

constructor TSomeTypeList.Create;
begin
  inherited;
  L := TList.Create;
end;

destructor TSomeTypeList.Destroy;
begin
  Clear;
  L.Free;
  inherited;
end;

function TSomeTypeList.GetCount: Integer;
begin
  result := L.Count;
end;

function TSomeTypeList.GetRecord(I: Integer): TSomeTypeRec;
begin
  result := TSomeTypeRec(L[I]);
end;

procedure TSomeTypeList.Clear;
var
  I: Integer;
begin
  for I:=0 to Count - 1 do
    Records[I].Free;
  L.Clear;
end;

function TSomeTypeList.Add(const Name: String; Id: Integer): TSomeTypeRec;
begin
  result := TSomeTypeRec.Create;
  result.Name := Name;
  result.Id := Id;
  L.Add(result);
end;

procedure TSomeTypeList.Delete(I: Integer);
begin
  Records[I].Free;
  L.Delete(I);
end;

function TSomeTypeList.Clone: TSomeTypeList;
var
  I: Integer;
begin
  result := TSomeTypeList.Create;
  for I := 0 to Count - 1 do
    result.Add(Records[I].Name, Records[I].Id);
end;

function TSomeTypeList.IndexOf(const Name: String): Integer;
var
  I: Integer;
begin
  result := -1;
  for I := 0 to Count - 1 do
    if StrEql(Records[I].Name, Name) then
    begin
      result := I;
      Exit;
    end;
end;

// TVarPath --------------------------------------------------------------------

constructor TVarPath.Create;
begin
  inherited;
  L := TList.Create;
end;

destructor TVarPath.Destroy;
begin
  Clear;
  L.Free;
  inherited;
end;

function TVarPath.GetCount: Integer;
begin
  result := L.Count;
end;

function TVarPath.GetItem(I: Integer): TVarPathRec;
begin
  result := TVarPathRec(L[I]);
end;

procedure TVarPath.Clear;
var
  I: Integer;
begin
  for I := 0 to Count - 1 do
    Items[I].Free;
  L.Clear;
end;

function TVarPath.Add(Id: Integer; VarCount: Int64): TVarPathRec;
begin
  result := TVarPathRec.Create;
  result.Id := Id;
  result.VarCount := VarCount;
  L.Add(result);
end;

function TVarPath.IndexOf(VarCount: Int64): Integer;
var
  I: Integer;
begin
  result := -1;
  for I := 0 to Count - 1 do
    if Items[I].VarCount = VarCount then
    begin
      result := I;
      Exit;
    end;
end;

function TVarPath.LastIndexOf(VarCount: Int64): Integer;
var
  I: Integer;
begin
  result := -1;
  for I := Count - 1 downto 0 do
    if Items[I].VarCount = VarCount then
    begin
      result := I;
      Exit;
    end;
end;

// TVarPathList ----------------------------------------------------------------

constructor TVarPathList.Create;
begin
  inherited;
  L := TList.Create;
end;

destructor TVarPathList.Destroy;
begin
  Clear;
  L.Free;
  inherited;
end;

procedure TVarPathList.Clear;
var
  I: Integer;
begin
  for I := 0 to Count - 1 do
    Pathes[I].Free;
  L.Clear;
end;

function TVarPathList.GetCount: Integer;
begin
  result := L.Count;
end;

function TVarPathList.GetPath(I: Integer): TVarPath;
begin
  result := TVarPath(L[I]);
end;

function TVarPathList.AddPath: TVarPath;
begin
  result := TVarPath.Create;
  L.Add(result);
end;

function TVarPathList.GetLevel(VarCount: Int64): Integer;
begin
  if VarCount < 100 then
    result := 1
  else if VarCount < 10000 then
    result := 2
  else if VarCount < 1000000 then
    result := 3
  else if VarCount < 100000000 then
    result := 4
  else if VarCount < 10000000000 then
    result := 5
  else if VarCount < 1000000000000 then
    result := 6
  else if VarCount < 100000000000000 then
    result := 7
  else
    raise PaxCompilerException.Create(errTooManyNestedCaseBlocks);
end;

procedure TVarPathList.Add(Id: Integer; VarCount: Int64);
var
  I, J, Idx: Integer;
  Path: TVarPath;
  Level: Integer;
  ParentVarCount: Integer;
  R: TVarPathRec;
  new_path: Boolean;
begin
  if Count = 0 then
  begin
    Path := AddPath;
    Path.Add(Id, VarCount);
    Exit;
  end;

  for I := 0 to Count - 1 do
  begin
    Path := Pathes[I];
    Idx := Path.IndexOf(VarCount);
    if Idx >= 0 then
    begin
      Path.Add(Id, VarCount);
      Exit;
    end;
  end;

  Level := GetLevel(VarCount);

  if Level = 1 then
  begin
    Path := AddPath;
    Path.Add(Id, VarCount);
    Exit;
  end;

 case Level of
   2:
   begin
     ParentVarCount := VarCount mod 100;
     new_path := VarCount div 100 > 1;
   end;
   3:
   begin
     ParentVarCount := VarCount mod 10000;
     new_path := VarCount div 10000 > 1;
   end;
   4:
   begin
     ParentVarCount := VarCount mod 1000000;
     new_path := VarCount div 1000000 > 1;
   end;
   5:
   begin
     ParentVarCount := VarCount mod 100000000;
     new_path := VarCount div 100000000 > 1;
   end;
   6:
   begin
     ParentVarCount := VarCount mod 10000000000;
     new_path := VarCount div 10000000000 > 1;
   end;
   7:
   begin
     ParentVarCount := VarCount mod 1000000000000;
     new_path := VarCount div 1000000000000 > 1;
   end
 else
   raise PaxCompilerException.Create(errTooManyNestedCaseBlocks);
 end;

  for I := Count - 1 downto 0 do
  begin
    Idx := Pathes[I].LastIndexOf(ParentVarCount);
    if Idx >= 0 then
    begin
      if new_path then
      begin
        Path := AddPath;
        for J := 0 to Idx do
        begin
          R := Pathes[I][J];
          Path.Add(R.Id, R.VarCount);
        end;
        Path.Add(Id, VarCount);
      end
      else
      begin
        Path := Pathes[I];
        Path.Add(Id, VarCount);
      end;

      Exit;
    end;
  end;

  Path := AddPath;
  Path.Add(Id, VarCount);
end;

//------------------------------------------------------------------------------

procedure ErrMessageBox(const S:  String);
begin
{$IFDEF CONSOLE}
  writeln(S);
  Exit;
{$ENDIF}

{$IFDEF LINUX}
  Application.MessageBox(PChar(S), 'paxCompiler', [smbOK]);
{$ELSE}
  MessageBox(GetActiveWindow(), PChar(S), PChar('paxCompiler'), MB_ICONEXCLAMATION or MB_OK);
{$ENDIF}
end;

procedure TGuidRec.SaveToStream(S: TWriter);
begin
  S.Write(Id, SizeOf(Id));
  S.Write(Guid, SizeOf(Guid));
  S.WriteString(Name);
end;

procedure TGuidRec.LoadFromStream(S: TReader);
begin
  S.Read(Id, SizeOf(Id));
  S.Read(Guid, SizeOf(Guid));
  Name := S.ReadString;
end;

constructor TGuidList.Create;
begin
  inherited;
  L := TList.Create;
end;

destructor TGuidList.Destroy;
begin
  Clear;
  L.Free;
  inherited;
end;

function TGuidList.Count: Integer;
begin
  result := L.Count;
end;

procedure TGuidList.Clear;
var
  I: Integer;
begin
  for I:=0 to Count - 1 do
    Records[I].Free;
end;

procedure TGuidList.Delete(I: Integer);
begin
  Records[I].Free;
  L.Delete(I);
end;

function TGuidList.Add(const GUID: TGUID; Id: Integer;
                       const Name: String): TGuidRec;
var
  I: Integer;
begin
  I := IndexOf(GUID);
  if I >= 0 then
  begin
    result := Records[I];
    Exit;
  end;

  result := TGuidRec.Create;
  L.Add(result);
  result.GUID := GUID;
  result.Name := Name;
  result.GuidIndex := L.Count - 1;
  result.Id := Id;
end;

function TGuidList.Clone: TGuidList;
var
  I: Integer;
begin
  result := TGuidList.Create;
  for I := 0 to Count - 1 do
    result.Add(Records[I].GUID, Records[I].Id, Records[I].Name);
end;

function TGuidList.IndexOf(const GUID: TGUID): Integer;
var
  I: Integer;
begin
  result := -1;
  for I := 0 to Count - 1 do
    if GuidsAreEqual(Records[I].GUID, GUID) then
    begin
      result := I;
      Exit;
    end;
end;

function TGuidList.GetGuidByID(Id: Integer): TGUID;
var
  I: Integer;
begin
  for I := 0 to Count - 1 do
    if Records[I].Id = Id then
    begin
      result := Records[I].GUID;
      Exit;
    end;
  result := IUnknown;
end;

function TGuidList.HasId(Id: Integer): Boolean;
var
  I: Integer;
begin
  for I := 0 to Count - 1 do
    if Records[I].Id = Id then
    begin
      result := true;
      Exit;
    end;
  result := false;
end;

procedure TGuidList.SaveToStream(S: TWriter);
var
  I, K: Integer;
begin
  K := Count;
  S.Write(K, SizeOf(K));
  for I := 0 to K - 1 do
    Records[I].SaveToStream(S);
end;

procedure TGuidList.LoadFromStream(S: TReader);
var
  I, K: Integer;
  R: TGuidRec;
begin
  Clear;
  S.Read(K, SizeOf(K));
  for I := 0 to K - 1 do
  begin
    R := TGuidRec.Create;
    R.LoadFromStream(S);
    Add(R.GUID, R.Id, R.Name);
    R.Free;
  end;
end;

function TGuidList.GetRecord(I: Integer): TGuidRec;
begin
  result := TGuidRec(L[I]);
end;

constructor THashArray.Create;
var
  I: Integer;
begin
  for I:=0 to MaxHash do
    A[I] := TIntegerList.Create;
end;

procedure THashArray.Clear;
var
  I: Integer;
begin
  for I:=0 to MaxHash do
    A[I].Clear;
end;

destructor THashArray.Destroy;
var
  I: Integer;
begin
  for I:=0 to MaxHash do
    A[I].Free;
end;

function THashArray.GetList(const S: String): TIntegerList;
var
  H: Integer;
begin
  H := HashNumber(S);
  result := A[H];
end;

function THashArray.GetMaxId: Integer;
var
  I, J: Integer;
begin
  result := 0;
  for I:=0 to MaxHash do
    for J := 0 to A[I].Count - 1 do
      if A[I][J] > result then
        result := A[I][J];
end;

function IsPositiveInt(S: PChar): Boolean;
var
  N: Byte;
  c: Char;
begin
  if S^ = #0 then
  begin
    result := false;
    Exit;
  end;

  result := true;

  repeat
    c := S^;

    if c = #0 then
      Exit;

    N := Ord(c);

    if N < Ord('0') then
    begin
      result := false;
      Exit;
    end;

    if N > Ord('9') then
    begin
      result := false;
      Exit;
    end;

    Inc(S);

  until false;
end;

function HashNumber(const S: String): Integer;
var
  I, J: Integer;
begin
  if S = '' then
  begin
    raise Exception.Create(errInternalError);
  end;

  I := 0;
  for J:=1 to Length(S) do
  begin
    I := I shl 1;
    I := I xor ord(UpCase(S[J]));
  end;
  if I < 0 then I := - I;
  result := I mod MaxHash;
end;

procedure THashArray.AddName(const S: String; Id: Integer);
var
  H: Integer;
begin
  if S = '' then
    Exit;
  H := HashNumber(S);
  with A[H] do
    Add(Id);
end;

procedure THashArray.DeleteName(const S: String; Id: Integer);
var
  H: Integer;
begin
  if S = '' then
    Exit;
  H := HashNumber(S);
  with A[H] do
    DeleteValue(Id);
end;

function THashArray.Clone: THashArray;
var
  I, J: Integer;
begin
  result := THashArray.Create;
  for I:=0 to MaxHash do
  begin
    for J:=0 to A[I].Count - 1 do
      result.A[I].Add(A[I][J]);
  end;
end;

{$IFDEF LINUX}
function CLSIDFromString;
begin
end;
{$ELSE}
function CLSIDFromString; external 'ole32.dll' name 'CLSIDFromString';
{$ENDIF}

function GuidsAreEqual(const G1, G2: TGUID): Boolean;
begin
{$IFDEF VARIANTS}
  result := SysUtils.IsEqualGUID(G1, G2);
{$ELSE}
  result := CompareMem(@G1, @G2, SizeOf(TGUID));
{$ENDIF}
end;

function Norm(const S: String; L: Integer): String;
begin
  result := Copy(S, 1, L);
  while Length(result) < L do
    result := ' ' + result;
end;

function Int32ToByteSet(value: Integer): TByteSet;
begin
  result := [];
  Move(value, result, 4);
end;

function ByteSetToInt32(value: TByteSet): Integer;
begin
  Move(value, result, 4);
end;

function ByteSetToString(value: TByteSet; FinTypeId: Integer): String;
var
  I, B1, B2: Integer;
  X: Boolean;
label
  L;
begin
  result := '[';
  X := true;
  B1 := -1;
  B2 := -1;
  for I:= 0 to 255 do
    if I in value then
    begin
      if X then
      begin
        B1 := I;
        B2 := I;
        X := false;
      end
      else
      begin
        B2 := I;
      end;

      if I = 255 then
        goto L;
    end
    else if B1 >= 0 then
    begin
L:
      if B2 - B1 = 0 then
        case FinTypeId of
          typeANSICHAR:
            result := result + '''' + Chr(B1) + '''';
          typeBOOLEAN:
            if B1 = 0 then
              result := result + 'false'
            else
              result := result + 'true'
          else
            result := result + IntToStr(B1);
        end
      else
        case FinTypeId of
          typeANSICHAR:
            result := result + '''' + Chr(B1) + '''' + '..' +
                               '''' + Chr(B2) + '''';
          typeBOOLEAN:
            result := result + 'false..true';
          else
            result := result + IntToStr(B1) + '..' + IntToStr(B2);
        end;

      B1 := -1;
      X := true;
      result := result + ',';

    end;

  if result[Length(result)] = ',' then
    result[Length(result)] := ']'
  else
    result := result + ']';
end;

{$IFDEF UNIC}
function SaveStringListToStream(L: TStringList; P: TStream): Integer;
var
  I, K: Integer;
begin
  K := L.Count;
  P.Write(K, 4);
  result := 4;
  for I:=0 to L.Count - 1 do
  begin
    SaveStringToStream(L[I], P);
    Inc(result, 4 + Length(L[I]) * SizeOf(Char));
  end;
end;

function LoadStringListFromStream(L: TStringList; P: TStream): Integer;
var
  I, K: Integer;
  S: String;
begin
  P.Read(K, 4);
  result := 4;
  for I:=0 to K - 1 do
  begin
    S := LoadStringFromStream(P);
    L.Add(S);
    Inc(result, 4 + Length(S) * SizeOf(Char));
  end;
end;
{$ELSE}
function SaveStringListToStream(L: TStringList; P: TStream): Integer;
var
  I, K: Integer;
  S: ShortString;
begin
  result := 0;
  K := L.Count;
  P.Write(K, 4);
  Inc(result, 4);
  for I:=0 to L.Count - 1 do
  begin
    S := L[I];
    K := Length(S);
    P.Write(K, 4);
    P.Write(S[1], Length(S));
    Inc(result, Length(S) + 4);
  end;
end;

function LoadStringListFromStream(L: TStringList; P: TStream): Integer;
var
  I, K, Count: Integer;
  S: ShortString;
begin
  result := 0;
  P.Read(Count, 4);
  Inc(result, 4);
  for I:=0 to Count - 1 do
  begin
    P.Read(K, 4);
    P.Read(S[1], K);
    S[0] := AnsiChar(Chr(K));
    L.Add(S);
    Inc(result, Length(S) + 4);
  end;
end;
{$ENDIF}

procedure SaveShortStringToStream(const S: ShortString; P: TStream);
begin
  P.Write(S[0], Length(S) + 1);
end;

function LoadShortStringFromStream(P: TStream): ShortString;
var
  L: Byte;
begin
  P.Read(L, SizeOf(Byte));
  P.Read(result[1], L);
  result[0] := AnsiChar(Chr(L));
end;

procedure SaveStringToStream(const S: String; P: TStream);
var
  K: Integer;
begin
  K := Length(S);
  P.Write(K, 4);
  if K > 0 then
    P.Write(Pointer(S)^, K * SizeOf(Char));
end;

function LoadStringFromStream(P: TStream): String;
var
  K: Integer;
begin
  P.Read(K, 4);
  SetLength(result, K);
  if K > 0 then
    P.Read(Pointer(result)^, K * SizeOf(Char));
end;

procedure SaveWideStringToStream(const S: WideString; P: TStream);
var
  K: Integer;
begin
  K := Length(S);
  P.Write(K, 4);
  if K > 0 then
    P.Write(Pointer(S)^, K * 2);
end;

function LoadWideStringFromStream(P: TStream): WideString;
var
  K: Integer;
begin
  P.Read(K, 4);
  SetLength(result, K);
  if K > 0 then
    P.Read(Pointer(result)^, K * 2);
end;

procedure SaveVariantToStream(const Value: Variant; S: TStream);
var
  VType: Integer;
begin
  VType := VarType(Value);
  SaveIntegerToStream(VType, S);
  case VType of
    varString:
      SaveStringToStream(Value, S);
{$IFDEF UNIC}
    varUString:
      SaveStringToStream(Value, S);
{$ENDIF}
    varOleStr:
      SaveWideStringToStream(Value, S);
    else
      S.Write(Value, SizeOf(Variant));
  end;
end;

function LoadVariantFromStream(S: TStream): Variant;
var
  VType: Integer;
begin
  VType := LoadIntegerFromStream(S);
  case VType of
    varString:
      result := LoadStringFromStream(S);
{$IFDEF UNIC}
    varUString:
      result := LoadStringFromStream(S);
{$ENDIF}
    varOleStr:
      result := LoadWideStringFromStream(S);
    else
      S.ReadBuffer(result, SizeOf(Variant));
  end;
end;

procedure SaveIntegerToStream(Value: Integer; S: TStream);
begin
  S.Write(Value, SizeOf(Integer));
end;

function LoadIntegerFromStream(S: TStream): Integer;
begin
  S.Read(result, SizeOf(Integer));
end;

function IsEmpty(const V: Variant): Boolean;
begin
  result := VarType(V) = varEmpty;
end;

//-- TIntegerList --------------------------------------------------------------

constructor TIntegerList.Create;
begin
  inherited;
  fItems := TList.Create;
end;

destructor TIntegerList.Destroy;
begin
  fItems.Free;
  inherited;
end;

function TIntegerList.Clone: TIntegerList;
var
  I: Integer;
begin
  result := TIntegerList.Create;
  for I:=0 to Count - 1 do
    result.Add(Items[I]);
end;

procedure TIntegerList.Clear;
begin
  fItems.Clear;
end;

function TIntegerList.GetCount: Integer;
begin
  result := fItems.Count;
end;

function TIntegerList.GetItem(I: Integer): Integer;
begin
  result := Integer(fItems[I]);
end;

procedure TIntegerList.SetItem(I: Integer; value: Integer);
begin
  fItems[I] := Pointer(value);
end;

function TIntegerList.Add(value: Integer): Integer;
begin
  result := fItems.Add(Pointer(value));
end;

procedure TIntegerList.Insert(I: Integer; value: Integer);
begin
  fItems.Insert(I, Pointer(value));
end;

procedure TIntegerList.RemoveAt(I: Integer);
begin
  fItems.Delete(I);
end;

procedure TIntegerList.DeleteValue(value: Integer);
var
  I: Integer;
begin
  I := IndexOf(value);
  if I >= 0 then
    fItems.Delete(I);
end;

function TIntegerList.IndexOf(value: Integer): Integer;
begin
  result := fItems.IndexOf(Pointer(value));
end;

function TIntegerList.Top: Integer;
begin
  if Count  = 0 then
    raise PaxCompilerException.Create(errInternalError);
  result := Items[Count - 1];
end;

procedure TIntegerList.SaveToStream(S: TStream);
var
  I: Integer;
begin
  SaveIntegerToStream(Count, S);
  for I:=0 to Count - 1 do
    SaveIntegerToStream(Integer(fItems[I]), S);
end;

procedure TIntegerList.LoadFromStream(S: TStream);
var
  I, K: Integer;
begin
  Clear;
  K := LoadIntegerFromStream(S);
  for I:=0 to K - 1 do
    Add(LoadIntegerFromStream(S));
end;

function TIntegerList.SaveToPtr(P: Pointer): Integer;
var
  I, K: Integer;
begin
  K := Count;
  Move(K, P^, 4);
  P := ShiftPointer(P, 4);
  for I:=0 to Count - 1 do
  begin
    K := Integer(fItems[I]);
    Move(K, P^, 4);
    P := ShiftPointer(P, 4);
  end;

  result := (Count * 4) + 4;
end;

function TIntegerList.LoadFromPtr(P: Pointer): Integer;
var
  I, K, Z: Integer;
begin
  Move(P^, K, 4);
  P := ShiftPointer(P, 4);
  for I:=0 to K - 1 do
  begin
    Move(P^, Z, 4);
    P := ShiftPointer(P, 4);
    Add(Z);
  end;

  result := (Count * 4) + 4;
end;

//-- TIntegerStack -------------------------------------------------------------

procedure TIntegerStack.Push(value: Integer);
begin
  Add(value);
end;

function TIntegerStack.Pop: Integer;
begin
  result := Items[Count - 1];
  fItems.Delete(Count - 1);
end;

function TIntegerStack.Depth(value: Integer): Integer;
var
  I: Integer;
begin
  result := -1;
  for I:=Count - 1 downto 0 do
  begin
    Inc(result);
    if Items[I] = value then
      Exit;
  end;
  raise Exception.Create(errInternalError);
end;

constructor TAssocIntegers.Create;
begin
  inherited;
  Keys := TIntegerList.Create;
  Values := TIntegerList.Create;
end;

destructor TAssocIntegers.Destroy;
begin
  Keys.Free;
  Values.Free;
  inherited;
end;

procedure TAssocIntegers.SaveToStream(S: TStream);
begin
  Keys.SaveToStream(S);
  Values.SaveToStream(S);
end;

procedure TAssocIntegers.LoadFromStream(S: TStream);
begin
  Keys.LoadFromStream(S);
  Values.LoadFromStream(S);
end;

function TAssocIntegers.SaveToPtr(P: Pointer): Integer;
begin
  result := Keys.SaveToPtr(P);
  P := ShiftPointer(P, result);
  Inc(result, Values.SaveToPtr(P));
end;

function TAssocIntegers.LoadFromPtr(P: Pointer): Integer;
begin
  result := Keys.LoadFromPtr(P);
  P := ShiftPointer(P, result);
  Inc(result, Values.LoadFromPtr(P));
end;

function TAssocIntegers.GetCount: Integer;
begin
  result := Keys.Count;
end;

procedure TAssocIntegers.Add(Key, Value: Integer);
begin
  Keys.Add(Key);
  Values.Add(Value);
end;

function StrEql(const S1, S2: String): Boolean;
begin
  result := CompareText(S1, S2) = 0;
end;

function ExtractName(const S: String): String;
var
  I, L: Integer;
begin
  L := Length(S);
  for I:= L downto 1 do
{$IFDEF UNIC}
    if CharInSet(S[I], ['.', '/', '\']) then
{$ELSE}
    if S[I] in ['.', '/', '\'] then
{$ENDIF}
    begin
      result := Copy(S, I + 1, L - I);
      Exit;
    end;
  result := S;
end;

function ExtractFullName(const S: String): String;
var
  I, L: Integer;
begin
  L := Length(S);
  for I:= 1 to L do
    if S[I] = '.' then
    begin
      result := Copy(S, I + 1, L - I);
      Exit;
    end;
  result := S;
end;

function ExtractFullOwner(const S: String): String;
var
  I, L: Integer;
begin
  L := Length(S);
  for I:= L downto 1 do
    if S[I] = '.' then
    begin
      result := Copy(S, 1, I - 1);
      Exit;
    end;
  result := '';
end;


function ExtractClassName(const S: String): String;
var
  I, L, K1, K2: Integer;
begin
  L := Length(S);

  result := '';

  K1 := 0;
  K2 := 0;

  for I:= L downto 1 do
    if S[I] = '.' then
      if K2 = 0 then
        K2 := I
      else
      begin
        K1 := I;
        result := Copy(S, K1 + 1, K2 - K1 - 1);
        Exit;
      end;
  result := Copy(S, K1 + 1, K2 - K1 - 1);
end;

function ExtractOwner(const S: String): String;
var
  P: Integer;
begin
  result := '';
  P := PosCh('.', S);
  if P > 0 then
    result := Copy(S, 1, P - 1);
end;

function ShiftPointer(P: Pointer; L: Integer): Pointer;
begin
  result := Pointer(Integer(P) + L);
end;

function AlignLeft(const S: String; L: Integer): String;
begin
  result := S;
  while Length(result) < L do
    result := result + ' ';
end;

function ByteToHex(B: Byte): String;
begin
  result := Format('%x', [B]);
  if Length(result) = 1 then
    result := '0' + result;
end;

constructor TStdTypeList.Create;
begin
  inherited;
  L := TList.Create;
end;

destructor TStdTypeList.Destroy;
var
  I: Integer;
begin
  for I:=0 to L.Count - 1 do
    Records[I].Free;

  L.Free;
  inherited;
end;

function TStdTypeList.IndexOf(const S: String): Integer;
var
  I: Integer;
  Q: String;
begin
  Q := UpperCase(S);
  for I:=0 to L.Count - 1 do
    if Records[I].Name = Q then
    begin
      result := I;
      Exit;
    end;
  result := -1;
end;

function TStdTypeList.GetRecord(I: Integer): TStdTypeRec;
begin
  if I = typePANSICHAR then
    I := typePOINTER
  else if I = typePVOID then
    I := typePOINTER;
  result := TStdTypeRec(L[I]);
end;

function TStdTypeList.Count: Integer;
begin
  result := L.Count;
end;

function TStdTypeList.Add(const TypeName: String; Size: Integer): Integer;
var
  R: TStdTypeRec;
begin
  R := TStdTypeRec.Create;
  R.TypeID := L.Count;
  L.Add(R);
  R.Size := Size;
  R.Name := UpperCase(TypeName);
  R.NativeName := TypeName;
  result := R.TypeID;
end;

function TStdTypeList.GetSize(TypeID: Integer): Integer;
begin
  result := Records[TypeID].Size;
end;

function IsShortInt(I: Integer): Boolean;
begin
  result := Abs(I) <= 127;
end;

function StrRefCountPtr(S: Pointer): Pointer;
begin
  if S <> nil then
    result := Pointer(Integer(Pointer(S)) - 8)
  else
    result := nil;
end;

function StrRefCount(S: Pointer): Integer;
begin
  result := Integer(StrRefCountPtr(S)^);
end;

function StrSizePtr(S: Pointer): Pointer;
begin
  if S <> nil then
    result := Pointer(Integer(Pointer(S)) - 4)
  else
    result := nil;
end;

function StrSize(S: Pointer): Integer;
begin
  result := Integer(StrSizePtr(S)^);
end;

function RemoveWhiteSpaces(const S: String): String;
var
  I: Integer;
  ch: Char;
begin
  result := '';
  for I:=1 to Length(S) do
  begin
    ch := S[I];
    if ch = ' ' then begin end
    else if ch = #9 then begin end
    else
      result := result + ch;
  end;
end;

function RemoveChars(C: TCharSet; const S: String): String;
var
  I: Integer;
  ch: Char;
  b: Boolean;
begin
  result := '';
  for I:=1 to Length(S) do
  begin
    ch := S[I];

{$IFDEF UNIC}
    b := CharInSet(ch, C);
{$ELSE}
    b := ch in C;
{$ENDIF}

    if b then
    begin
    end
    else
      result := result + ch;
  end;
end;

function PosCh(ch: Char; const S: String): Integer;
var
  I: Integer;
begin
  for I:=1 to Length(S) do
    if S[I] = ch then
    begin
      result := I;
      Exit;
    end;
  result := 0;
end;

function CountCh(ch: Char; const S: String): Integer;
var
  I: Integer;
begin
  result := 0;
  for I:=1 to Length(S) do
    if S[I] = ch then
      Inc(result);
end;

function RemoveCh(Ch: Char; const S: String): String;
var
  I: Integer;
begin
  result := '';
  for I:=1 to Length(S) do
    if S[I] <> Ch then
      result := result + S[I];
end;

procedure ReplaceCh(var result: String; Source, Dest: Char);
var
  I: Integer;
begin
  for I := 1 to Length(result) do
    if result[I] = Source then
      result[I] := Dest;
end;

{$IFDEF UNIC}
{$ELSE}
function CharInSet(C: AnsiChar; const CharSet: TCharSet): Boolean;
begin
  Result := C in CharSet;
end;
{$ENDIF}

function LoadText(const FileName: String): String;
var
  L: TStringList;
begin
  L := TStringList.Create;
  try
    L.LoadFromFile(FileName);
    result := L.Text;
  finally
    L.Free;
  end;
end;

function _IsJSType(T: Integer): Boolean;
begin
  result := false;
end;

initialization

  Types := TStdTypeList.Create;
  with Types do
  begin
    Add('', 0);
    Add('Void', SizeOf(Pointer));
    Add('Boolean', SizeOf(Boolean));
    Add('Byte', SizeOf(Byte));
    Add('Char', SizeOf(AnsiChar));
    Add('String', SizeOf(Pointer));
    Add('Word', SizeOf(Word));
    Add('Integer', SizeOf(Integer));
    Add('Double', SizeOf(Double));
    Add('Pointer', SizeOf(Pointer));
    Add('#RECORD', 0);
    Add('#ARRAY', 0);
    Add('#ALIAS', 0);
    Add('#ENUM', SizeOf(Byte));
    Add('#PROC', SizeOf(Pointer));
    Add('#SET', 32);
    Add('ShortString', 256);
    Add('Single', SizeOf(Single));
    Add('Extended', SizeOf(Extended));
    Add('#CLASS', SizeOf(Pointer));
    Add('#CLASSREF', SizeOf(Pointer));
    Add('WideChar', SizeOf(WideChar));
    Add('WideString', SizeOf(WideString));
    Add('Variant', SizeOf(Variant));
    Add('#DYNARRAY', SizeOf(Pointer));
    Add('Int64', SizeOf(Int64));
    Add('#INTERFACE', SizeOf(Pointer));
    Add('Cardinal', SizeOf(Cardinal));
    Add('#EVENT', SizeOf(TMethod));
    Add('Currency', SizeOf(Currency));
    Add('SmallInt', SizeOf(SmallInt));
    Add('ShortInt', SizeOf(ShortInt));
    Add('WordBool', SizeOf(WordBool));
    Add('LongBool', SizeOf(LongBool));
    Add('ByteBool', SizeOf(ByteBool));
    Add('OleVariant', SizeOf(OleVariant));

{$IFDEF UNIC}
    Add('UnicodeString', SizeOf(UnicString));
{$ENDIF}
  end;

  Kinds := TStringList.Create;
  with Kinds do
  begin
    Add('');
    Add('VAR');
    Add('CONST');
    Add('SUB');
    Add('PARAM');
    Add('TYPE');
    Add('T FIELD');
    Add('LABEL');
    Add('NAMESP');
    Add('CONSTR');
    Add('DESTR');
    Add('PROP');
    Add('END CH');
  end;

  Operators := TStringList.Create;
  with Operators do
  begin
    OP_NOP := - Add('NOP');
    OP_SEPARATOR := - Add('SEPARATOR');
    OP_STMT := - Add('STMT');
    OP_SET_CODE_LINE := - Add('SCL');

    OP_BEGIN_NAMESPACE := - Add('BEGIN NAMESPACE');
    OP_END_NAMESPACE := - Add('END NAMESPACE');

    OP_BEGIN_TYPE := - Add('BEGIN TYPE');
    OP_END_TYPE := - Add('END TYPE');

    OP_BEGIN_CLASS_TYPE := - Add('BEGIN CLASS TYPE');
    OP_END_CLASS_TYPE := - Add('END CLASS TYPE');

    OP_BEGIN_CLASSREF_TYPE := - Add('BEGIN CLASSREF TYPE');
    OP_END_CLASSREF_TYPE := - Add('END CLASSREF TYPE');

    OP_BEGIN_INTERFACE_TYPE := - Add('BEGIN INTERFACE TYPE');
    OP_END_INTERFACE_TYPE := - Add('END INTERFACE TYPE');

    OP_BEGIN_RECORD_TYPE := - Add('BEGIN RECORD TYPE');
    OP_END_RECORD_TYPE := - Add('END RECORD TYPE');

    OP_BEGIN_ARRAY_TYPE := - Add('BEGIN ARRAY TYPE');
    OP_END_ARRAY_TYPE := - Add('END ARRAY TYPE');

    OP_BEGIN_DYNARRAY_TYPE := - Add('BEGIN DYNARRAY TYPE');
    OP_END_DYNARRAY_TYPE := - Add('END DYNARRAY TYPE');

    OP_BEGIN_SUBRANGE_TYPE := - Add('BEGIN SUBRANGE TYPE');
    OP_END_SUBRANGE_TYPE := - Add('END SUBRANGE TYPE');

    OP_BEGIN_ENUM_TYPE := - Add('BEGIN ENUM TYPE');
    OP_END_ENUM_TYPE := - Add('END ENUM TYPE');

    OP_BEGIN_SET_TYPE := - Add('BEGIN SET TYPE');
    OP_END_SET_TYPE := - Add('END SET TYPE');

    OP_BEGIN_POINTER_TYPE := - Add('BEGIN POINTER TYPE');
    OP_END_POINTER_TYPE := - Add('END POINTER TYPE');

    OP_BEGIN_PROC_TYPE := - Add('BEGIN PROC TYPE');
    OP_END_PROC_TYPE := - Add('END PROC TYPE');

    OP_BEGIN_ALIAS_TYPE := - Add('BEGIN ALIAS TYPE');
    OP_END_ALIAS_TYPE := - Add('END ALIAS TYPE');

    OP_BEGIN_SHORTSTRING_TYPE := - Add('BEGIN SHORTSTRING TYPE');
    OP_END_SHORTSTRING_TYPE := - Add('END SHORTSTRING TYPE');

    OP_BEGIN_CONST := - Add('BEGIN CONST');
    OP_END_CONST := - Add('END CONST');

    OP_BEGIN_VAR := - Add('BEGIN VAR');
    OP_END_VAR := - Add('END VAR');

    OP_GET_NEXTJSPROP := - Add('GET NEXTJSPROP');
    OP_CLEAR_REFERENCES := - Add('CLEAR REFERENCES');

    OP_BEGIN_MODULE := - Add('BEGIN MODULE');
    OP_END_MODULE := - Add('END MODULE');
    OP_END_INTERFACE_SECTION := - Add('END INTERFACE SECTION');
    OP_END_IMPORT := - Add('END IMPORT');
    OP_BEGIN_INITIALIZATION := - Add('BEGIN INITIALIZATION');
    OP_END_INITIALIZATION := - Add('END INITIALIZATION');
    OP_BEGIN_FINALIZATION := - Add('BEGIN FINALIZATION');
    OP_END_FINALIZATION := - Add('END FINALIZATION');

    OP_EXTRA_BYTECODE := - Add('EXTRA BYTECODE');

    OP_TRY_ON := - Add('TRY ON');
    OP_TRY_OFF := - Add('TRY OFF');
    OP_FINALLY := - Add('FINALLY');
    OP_EXCEPT := - Add('EXCEPT');
    OP_EXCEPT_ON := - Add('EXCEPT ON');
    OP_RAISE := - Add('RAISE');
    OP_COND_RAISE := - Add('COND RAISE');
    OP_BEGIN_EXCEPT_BLOCK := - Add('BEGIN EXCEPT BLOCK');
    OP_END_EXCEPT_BLOCK := - Add('END EXCEPT BLOCK');

    OP_OVERFLOW_CHECK := - Add('OVERFLOW CHECK');

    OP_PAUSE := - Add('PAUSE');
    OP_CHECK_PAUSE := - Add('CHECK PAUSE');
    OP_CHECK_PAUSE_LIGHT := - Add('CHECK PAUSE LIGHT');
    OP_HALT := - Add('HALT');

    OP_EMIT_OFF := - Add('EMIT OFF');
    OP_EMIT_ON := - Add('EMIT ON');

    OP_BEGIN_USING := - Add('BEGIN USING');
    OP_END_USING := - Add('END USING');

    OP_BEGIN_BLOCK := - Add('BEGIN BLOCK');
    OP_END_BLOCK := - Add('END BLOCK');

    OP_EVAL := - Add('EVAL');
    OP_EVAL_INHERITED := - Add('EVAL INHERITED');
    OP_EVAL_CONSTRUCTOR := - Add('EVAL CONSTRUCTOR');
    OP_UPDATE_INSTANCE := - Add('UPDATE INSTANCE');
    OP_CLEAR_EDX := - Add('CLEAR EDX');
    OP_IMPLEMENTS := - Add('IMPLEMENTS');

    OP_MYCLASS := - Add('MYCLASS');
    OP_MYBASE := - Add('MYBASE');

    OP_LOAD_PROC := - Add('LOAD PROC');

    OP_CHECK_OVERRIDE := - Add('CHECK OVERRIDE');

    OP_EXIT := - Add('EXIT');
    OP_GO := - Add('GO');
    OP_GO_TRUE := - Add('GO TRUE');
    OP_GO_FALSE := - Add('GO FALSE');
    OP_GO_TRUE_BOOL := - Add('GO TRUE BOOL');
    OP_GO_FALSE_BOOL := - Add('GO FALSE BOOL');
    OP_GO_DL := - Add('GO DL');
    OP_BEGIN_CALL := - Add('BEGIN CALL');
    OP_CALL := - Add('CALL');
    OP_CALL_DEFAULT_CONSTRUCTOR := - Add('CALL DEFAULT CONSTRUCTOR');
    OP_PUSH := - Add('PUSH');
    OP_PUSH_INSTANCE := - Add('PUSH INSTANCE');
    OP_PUSH_CLASSREF := - Add('PUSH CLASSREF');
    OP_PUSH_CONTEXT := - Add('PUSH CONTEXT');
    OP_POP_CONTEXT := - Add('POP CONTEXT');
    OP_FIND_CONTEXT := - Add('FIND CONTEXT');
    OP_FIND_JS_FUNC := - Add('FIND JS FUNC');
    OP_LABEL := - Add('LABEL');
    OP_TYPE_CAST := - Add('TYPE CAST');
    OP_BEGIN_SUB := - Add('BEGIN SUB');
    OP_DECLARE_LOCAL_VAR := - Add('DECLARE LOCAL VAR');
    OP_DECLARE_TEMP_VAR := - Add('DECLARE TEMP VAR');
    OP_DESTROY_LOCAL_VAR := - Add('DESTROY LOCAL VAR');
    OP_INIT_SUB := - Add('INIT SUB');
    OP_END_SUB := - Add('END SUB');
    OP_FIN_SUB := - Add('FIN SUB');
    OP_EPILOGUE_SUB := - Add('EPILOGUE SUB');

    OP_BEGIN_GLOBAL_BLOCK := - Add('BEGIN GLOBAL BLOCK');
    OP_EPILOGUE_GLOBAL_BLOCK := - Add('EPILOGUE_GLOBAL_BLOCK');
    OP_EPILOGUE_GLOBAL_BLOCK2 := - Add('EPILOGUE_GLOBAL_BLOCK2');
    OP_END_GLOBAL_BLOCK := - Add('END GLOBAL BLOCK');

    OP_ASSIGN_TYPE := - Add('ASSIGN TYPE');
    OP_ASSIGN_THE_SAME_TYPE := - Add('ASSIGN THE SAME TYPE');
    OP_ASSIGN_TYPE_ALIAS := - Add('ASSIGN TYPE ALIAS');

    OP_SAVE_EDX := - Add('SAVE EDX');
    OP_RESTORE_EDX := - Add('RESTORE EDX');

    OP_BEGIN_WITH := - Add('BEGIN WITH');
    OP_END_WITH := - Add('END WITH');

    OP_BEGIN_INIT_CONST := - Add('BEGIN INIT CONST');
    OP_END_INIT_CONST := - Add('END INIT CONST');

    OP_CREATE_POINTER_TYPE := - Add('CREATE POINTER TYPE');
    OP_CREATE_CLASSREF_TYPE := - Add('CREATE CLASSREF TYPE');
    OP_ADDRESS := - Add('ADDRESS');
    OP_TERMINAL := - Add('TERMINAL');
    OP_ADDRESS_PROG := - Add('ADDRESS PROG');
    OP_ASSIGN_PROG := - Add('ASSIGN PROG');

    OP_LVALUE := - Add('LVALUE');

    OP_ASSIGN := - Add(':=');
    OP_ASSIGN_CONST := - Add(':= (const)');
    OP_ASSIGN_ENUM := - Add(':= (enum)');
    OP_CHECK_SUBRANGE_TYPE := - Add('CHECK SUBRANGE TYPE');

    OP_CREATE_DYNAMIC_ARRAY_TYPE := - Add('CREATE DYNARRAY TYPE');

    OP_CREATE_SHORTSTRING_TYPE := - Add('CREATE SHORTSTRING TYPE');

    OP_INC := - Add('INC');
    OP_DEC := - Add('DEC');
    OP_PRED := - Add('PRED');
    OP_SUCC := - Add('SUCC');
    OP_ORD := - Add('ORD');
    OP_CHR := - Add('CHR');
    OP_STR := - Add('STR');
    OP_LOW := - Add('LOW');
    OP_HIGH := - Add('HIGH');

    OP_SET_LENGTH := - Add('SET LENGTH');
    OP_DYNARRAY_ASSIGN := - Add(':= (dynarray)');
    OP_DYNARRAY_CLR := - Add('CLR (dynarray)');
    OP_DYNARRAY_HIGH := - Add('HIGH (dynarray)');
    OP_CREATE_EMPTY_DYNARRAY := - Add('CRT EMPTY dynarray');

    OP_SHORTSTRING_HIGH := - Add('HIGH (shortstring)');

    OP_PLUS := - Add('+');
    OP_MINUS := - Add('-');
    OP_MULT := - Add('*');
    OP_DIV := - Add('/');
    OP_IDIV := - Add('DIV');
    OP_MOD := - Add('MOD');
    OP_SHL := - Add('SHL');
    OP_SHR := - Add('SHR');

    OP_AND := - Add('AND');
    OP_OR := - Add('OR');
    OP_XOR := - Add('XOR');
    OP_NOT := - Add('NOT');

    OP_NEG := - Add('NEG');
    OP_ABS := - Add('ABS');

    OP_EQ := - Add('=');
    OP_NE := - Add('<>');
    OP_GT := - Add('>');
    OP_GE := - Add('>=');
    OP_LT := - Add('<');
    OP_LE := - Add('<=');

    OP_CLASSNAME := - Add('CLASSNAME');

    OP_GET_PROG := - Add('GET_PROG');

    OP_IS := - Add('IS');
    OP_AS := - Add('AS');
    OP_TYPEINFO := - Add('TYPEINFO');
    OP_ADD_TYPEINFO := - Add('ADD_TYPEINFO');

    OP_RET := - Add('RET');

    OP_CURRENCY_FROM_INT64 := - Add('CURRENCY FROM INT64');
    OP_CURRENCY_FROM_INT := - Add('CURRENCY FROM INT');
    OP_CURRENCY_FROM_REAL := - Add('CURRENCY FROM REAL');

    OP_INT_TO_DOUBLE := - Add('INT TO DOUBLE');
    OP_INT64_TO_DOUBLE := - Add('INT64 TO DOUBLE');

    OP_INT_TO_SINGLE := - Add('INT TO SINGLE');
    OP_INT64_TO_SINGLE := - Add('INT64 TO SINGLE');

    OP_INT_TO_EXTENDED := - Add('INT TO EXTENDED');
    OP_INT64_TO_EXTENDED := - Add('INT64 TO EXTENDED');

    OP_INT_TO_INT64 := - Add('INT TO INT64');
    OP_BYTE_TO_INT64 := - Add('BYTE TO INT64');
    OP_WORD_TO_INT64 := - Add('WORD TO INT64');
    OP_CARDINAL_TO_INT64 := - Add('CARDINAL TO INT64');
    OP_SMALLINT_TO_INT64 := - Add('SMALLINT TO INT64');
    OP_SHORTINT_TO_INT64 := - Add('SHORTINT TO INT64');

    OP_INT_FROM_INT64 := - Add('INT FROM INT64');
    OP_BYTE_FROM_INT64 := - Add('BYTE FROM INT64');
    OP_WORD_FROM_INT64 := - Add('WORD FROM INT64');
    OP_CARDINAL_FROM_INT64 := - Add('CARDINAL FROM INT64');
    OP_SMALLINT_FROM_INT64 := - Add('SMALLINT FROM INT64');
    OP_SHORTINT_FROM_INT64 := - Add('SHORTINT FROM INT64');

    OP_CURRENCY_TO_EXTENDED := - Add('CURRENCY TO EXTENDED');
    OP_CURRENCY_TO_SINGLE := - Add('CURRENCY TO SINGLE');
    OP_DOUBLE_TO_SINGLE := - Add('DOUBLE TO SINGLE');
    OP_DOUBLE_TO_EXTENDED := - Add('DOUBLE TO EXTENDED');
    OP_SINGLE_TO_DOUBLE := - Add('SINGLE TO DOUBLE');
    OP_CURRENCY_TO_DOUBLE := - Add('CURRENCY TO DOUBLE');
    OP_SINGLE_TO_EXTENDED := - Add('SINGLE TO EXTENDED');
    OP_EXTENDED_TO_DOUBLE := - Add('EXTENDED TO DOUBLE');
    OP_EXTENDED_TO_SINGLE := - Add('EXTENDED TO SINGLE');

    OP_PUSH_EBP := -Add('push ebp');
    OP_POP := -Add('pop');

    OP_FIELD := - Add('FIELD');
    OP_ELEM := - Add('ELEM');

    OP_ITEM := - Add('ITEM');
    OP_RECORD_ITEM := - Add('RECORD ITEM');

    OP_PRINT := - Add('PRINT');
    OP_PRINT_EX := - Add('PRINT_EX');

    OP_SET_INCLUDE := - Add('SET INCLUDE');
    OP_SET_INCLUDE_INTERVAL := - Add('SET INCLUDE INTERVAL');
    OP_SET_EXCLUDE := - Add('SET EXCLUDE');
    OP_SET_MEMBERSHIP := -Add('SET MEMBERSHIP');

    OP_INIT_PANSICHAR_LITERAL := - Add('INIT PANSICHAR LITERAL');
    OP_INIT_PWIDECHAR_LITERAL := - Add('INIT PWIDECHAR LITERAL');

    OP_SIZEOF := - Add('SIZEOF');

    OP_OLE_GET := - Add('OLE_GET');
    OP_OLE_SET := - Add('OLE_SET');
    OP_OLE_VALUE := - Add('OLE_VALUE');
    OP_OLE_PARAM := - Add('OLE_PARAM');

    OP_ONCREATE_OBJECT := - Add('ON CREATE OBJECT');
    OP_ON_AFTER_OBJECT_CREATION := - Add('ON AFTER OBJECT CREATION');
    OP_CREATE_OBJECT := - Add('CREATE OBJECT');
    OP_DESTROY_OBJECT := - Add('DESTROY OBJECT');
    OP_GET_VMT_ADDRESS := - Add('GET VMT ADDRESS');
    OP_ADD_ANCESTOR := - Add('ADD ANCESTOR');
    OP_ADD_INTERFACE := - Add('ADD INTERFACE');
    OP_ADD_METHOD_INDEX := - Add('ADD METHOD INDEX');
    OP_ASSIGNED := - Add('ASSIGNED');

    OP_SET_SET_PROP := -Add('SET SET PROP');
    OP_SET_ORD_PROP := -Add('SET ORD PROP');
    OP_SET_INTERFACE_PROP := -Add('SET INTERFACE PROP');
    OP_SET_ANSISTR_PROP := -Add('SET ANSISTR PROP');
    OP_SET_WIDESTR_PROP := -Add('SET WIDESTR PROP');
    OP_SET_UNICSTR_PROP := -Add('SET UNICSTR PROP');
    OP_SET_FLOAT_PROP := -Add('SET FLOAT PROP');
    OP_SET_VARIANT_PROP := -Add('SET VARIANT PROP');
    OP_SET_INT64_PROP := -Add('SET INT64 PROP');

    OP_SET_EVENT_PROP := -Add('SET EVENT PROP');
    OP_SET_EVENT_PROP2 := -Add('SET EVENT PROP2');

    OP_VARARRAY_GET := -Add('VARARRAY GET');
    OP_VARARRAY_PUT := -Add('VARARRAY PUT');
    OP_VARARRAY_IDX := -Add('VARARRAY IDX');

    OP_SAVE_REGS := - Add('SAVE REGS');
    OP_RESTORE_REGS := - Add('RESTORE REGS');

    OP_ERR_ABSTRACT := - Add('ERR ABSTRACT');
    OP_UPDATE_DEFAULT_CONSTRUCTOR := - Add('UPDATE DEFAULT CONSTRUCTOR');
    OP_FIND_CONSTRUCTOR := - Add('FIND CONSTRUCTOR');

    OP_BEGIN_CRT_JS_FUNC_OBJECT := - Add('BEGIN_CRT_JS_FUNC_OBJECT');
    OP_END_CRT_JS_FUNC_OBJECT := - Add('END_CRT_JS_FUNC_OBJECT');

    OP_TO_JS_OBJECT := - Add('TO_JS_OBJECT');
    OP_JS_TYPEOF := - Add('JS_TYPEOF');
    OP_JS_VOID := - Add('JS_VOID');

    OP_ASSIGN_SHIFT := -Add('ASSIGN SHIFT');

    OP_ASSIGN_INT_M := -Add(':= (integer, m)');

    OP_CREATE_METHOD := -Add('CREATE METHOD');

    OP_GET_ENUMERATOR := -Add('GET ENUMERATOR');
    OP_MOVE_NEXT := -Add('MOVE NEXT');
    OP_CURRENT := -Add('CURRENT');

/////////////////// DETAILED OPERATORS /////////////////////////////////

//    OP_DUMMY := - Add('DUMMY');

    OP_ASSIGN_BYTE_I := -Add(':= (byte, i)');
    OP_ASSIGN_BYTE_M := -Add(':= (byte, m)');
    OP_ASSIGN_WORD_I := -Add(':= (word, i)');
    OP_ASSIGN_WORD_M := -Add(':= (word, m)');
    OP_ASSIGN_CARDINAL_I := -Add(':= (cardinal, i)');
    OP_ASSIGN_CARDINAL_M := -Add(':= (cardinal, m)');
    OP_ASSIGN_SMALLINT_I := -Add(':= (smallint, i)');
    OP_ASSIGN_SMALLINT_M := -Add(':= (smallint, m)');
    OP_ASSIGN_SHORTINT_I := -Add(':= (shortint, i)');
    OP_ASSIGN_SHORTINT_M := -Add(':= (shortint, m)');
    OP_ASSIGN_INT_I := -Add(':= (integer, i)');
//    OP_ASSIGN_INT_M := -Add(':= (integer, m)');
    OP_ASSIGN_DOUBLE := -Add(':= (double)');
    OP_ASSIGN_CURRENCY := -Add(':= (currency)');
    OP_ASSIGN_EVENT := -Add(':= (event)');
    OP_ASSIGN_SINGLE := -Add(':= (single)');
    OP_ASSIGN_EXTENDED := -Add(':= (extended)');
    OP_ASSIGN_PANSICHAR := -Add(':= (pansichar)');
    OP_ASSIGN_PWIDECHAR := -Add(':= (pwidechar)');
    OP_ASSIGN_INT64 := -Add(':= (int64)');
    OP_ASSIGN_INTERFACE := -Add(':= (interface)');

    OP_CREATE_EVENT := -Add('create event');

    OP_MULT_INT64 := -Add('* (int64)');
    OP_IDIV_INT64 := -Add('div (int64)');
    OP_MOD_INT64 := -Add('mod (int64)');
    OP_SHL_INT64 := -Add('shl (int64)');
    OP_SHR_INT64 := -Add('shr (int64)');

    OP_ANSISTRING_FROM_PANSICHAR := -Add('ANSISTRING FROM PANSICHAR');
    OP_ANSISTRING_FROM_PWIDECHAR := -Add('ANSISTRING FROM PWIDECHAR');
    OP_ANSISTRING_FROM_ANSICHAR := -Add('ANSISTRING FROM ANSICHAR');
    OP_ASSIGN_ANSISTRING := -Add(':= (ansistring)');
    OP_ASSIGN_SHORTSTRING := -Add(':= (shortstring)');
    OP_ASSIGN_WIDESTRING := -Add(':= (widestring)');
    OP_ASSIGN_UNICSTRING := -Add(':= (unicstring)');
    OP_ASSIGN_VARIANT := -Add(':= (variant)');
    OP_ASSIGN_OLEVARIANT := -Add(':= (olevariant)');

    OP_ASSIGN_CLASS := -Add(':= (class)');

    OP_ASSIGN_TVarRec := -Add(':= (TVarRec)');

    OP_ASSIGN_RECORD := -Add(':= (record)');
    OP_ASSIGN_ARRAY := -Add(':= (array)');

    OP_SHORTSTRING_FROM_PANSICHAR_LITERAL := -Add('SHORTSTRING FROM PANSICHAR LITERAL');
    OP_SHORTSTRING_FROM_PWIDECHAR_LITERAL := -Add('SHORTSTRING FROM PWIDECHAR LITERAL');
    OP_SHORTSTRING_FROM_ANSICHAR := -Add('SHORTSTRING FROM ANSICHAR');
    OP_SHORTSTRING_FROM_WIDECHAR := -Add('SHORTSTRING FROM WIDECHAR');
    OP_SHORTSTRING_FROM_ANSISTRING := -Add('SHORTSTRING FROM ANSISTRING');
    OP_SHORTSTRING_FROM_WIDESTRING := -Add('SHORTSTRING FROM WIDESTRING');
    OP_UNICSTRING_FROM_WIDESTRING := -Add('UNICSTRING FROM WIDESTRING');
    OP_SHORTSTRING_FROM_UNICSTRING := -Add('SHORTSTRING FROM UNICSTRING');
    OP_ANSISTRING_FROM_SHORTSTRING := -Add('ANSISTRING FROM SHORTSTRING');

    OP_WIDESTRING_FROM_PANSICHAR_LITERAL := -Add('WIDESTRING FROM PANSICHAR LITERAL');
    OP_WIDESTRING_FROM_PWIDECHAR_LITERAL := -Add('WIDESTRING FROM PWIDECHAR LITERAL');
    OP_WIDESTRING_FROM_ANSICHAR := -Add('WIDESTRING FROM ANSICHAR');
    OP_WIDESTRING_FROM_WIDECHAR := -Add('WIDESTRING FROM WIDECHAR');
    OP_ANSISTRING_FROM_WIDECHAR := -Add('ANSISTRING FROM WIDECHAR');
    OP_WIDESTRING_FROM_WIDECHAR_LITERAL := -Add('WIDESTRING FROM WIDECHAR LITERAL');
    OP_WIDESTRING_FROM_ANSISTRING := -Add('WIDESTRING FROM ANSISTRING');
    OP_UNICSTRING_FROM_ANSISTRING := -Add('UNICSTRING FROM ANSISTRING');
    OP_WIDESTRING_FROM_SHORTSTRING := -Add('WIDESTRING FROM SHORTSTRING');
    OP_WIDESTRING_FROM_UNICSTRING := -Add('WIDESTRING FROM UNICSTRING');
    OP_UNICSTRING_FROM_SHORTSTRING := -Add('UNICSTRING FROM SHORTSTRING');
    OP_ANSISTRING_FROM_WIDESTRING := -Add('ANSISTRING FROM WIDESTRING');
    OP_ANSISTRING_FROM_UNICSTRING := -Add('ANSISTRING FROM UNICSTRING');

    OP_UNICSTRING_FROM_PANSICHAR_LITERAL := -Add('UNICSTRING FROM PANSICHAR LITERAL');
    OP_UNICSTRING_FROM_PWIDECHAR_LITERAL := -Add('UNICSTRING FROM PWIDECHAR LITERAL');
    OP_UNICSTRING_FROM_ANSICHAR := -Add('UNICSTRING FROM ANSICHAR');
    OP_UNICSTRING_FROM_WIDECHAR := -Add('UNICSTRING FROM WIDECHAR');
    OP_UNICSTRING_FROM_WIDECHAR_LITERAL := -Add('UNICSTRING FROM WIDECHAR LITERAL');

    OP_VARIANT_FROM_CLASS := -Add('VARIANT FROM CLASS'); // JS only
    OP_VARIANT_FROM_POINTER := -Add('VARIANT FROM POINTER'); // JS only
    OP_CLASS_FROM_VARIANT := -Add('CLASS FROM VARIANT'); // JS only

    OP_INTERFACE_FROM_CLASS := -Add('INTERFACE FROM CLASS');
    OP_INTERFACE_CAST := -Add('INTERFACE CAST');

    OP_VARIANT_FROM_PANSICHAR_LITERAL := -Add('VARIANT FROM PANSICHAR LITERAL');
    OP_VARIANT_FROM_PWIDECHAR_LITERAL := -Add('VARIANT FROM PWIDECHAR LITERAL');
    OP_VARIANT_FROM_ANSISTRING := -Add('VARIANT FROM ANSISTRING');
    OP_VARIANT_FROM_WIDESTRING := -Add('VARIANT FROM WIDESTRING');
    OP_VARIANT_FROM_UNICSTRING := -Add('VARIANT FROM UNICSTRING');
    OP_VARIANT_FROM_SHORTSTRING := -Add('VARIANT FROM SHORTSTRING');
    OP_VARIANT_FROM_ANSICHAR := -Add('VARIANT FROM ANSICHAR');
    OP_VARIANT_FROM_WIDECHAR := -Add('VARIANT FROM WIDECHAR');
    OP_VARIANT_FROM_WIDECHAR_LITERAL := -Add('VARIANT FROM WIDECHAR LITERAL');
    OP_VARIANT_FROM_INT := -Add('VARIANT FROM INT');
    OP_VARIANT_FROM_INT64 := -Add('VARIANT FROM INT64');
    OP_VARIANT_FROM_BYTE := -Add('VARIANT FROM BYTE');
    OP_VARIANT_FROM_BOOL := -Add('VARIANT FROM BOOL');
    OP_VARIANT_FROM_WORD := -Add('VARIANT FROM WORD');
    OP_VARIANT_FROM_CARDINAL := -Add('VARIANT FROM CARDINAL');
    OP_VARIANT_FROM_SMALLINT := -Add('VARIANT FROM SMALLINT');
    OP_VARIANT_FROM_SHORTINT := -Add('VARIANT FROM SHORTINT');
    OP_VARIANT_FROM_DOUBLE := -Add('VARIANT FROM DOUBLE');
    OP_VARIANT_FROM_CURRENCY := -Add('VARIANT FROM CURRENCY');
    OP_VARIANT_FROM_SINGLE := -Add('VARIANT FROM SINGLE');
    OP_VARIANT_FROM_EXTENDED := -Add('VARIANT FROM EXTENDED');
    OP_VARIANT_FROM_INTERFACE := -Add('VARIANT FROM INTERFACE');

    OP_OLEVARIANT_FROM_VARIANT := -Add('OLEVARIANT FROM VARIANT');
    OP_OLEVARIANT_FROM_PANSICHAR_LITERAL := -Add('OLEVARIANT FROM PANSICHAR LITERAL');
    OP_OLEVARIANT_FROM_PWIDECHAR_LITERAL := -Add('OLEVARIANT FROM PWIDECHAR LITERAL');
    OP_OLEVARIANT_FROM_ANSISTRING := -Add('OLEVARIANT FROM ANSISTRING');
    OP_OLEVARIANT_FROM_WIDESTRING := -Add('OLEVARIANT FROM WIDESTRING');
    OP_OLEVARIANT_FROM_UNICSTRING := -Add('OLEVARIANT FROM UNICSTRING');
    OP_OLEVARIANT_FROM_SHORTSTRING := -Add('OLEVARIANT FROM SHORTSTRING');
    OP_OLEVARIANT_FROM_ANSICHAR := -Add('OLEVARIANT FROM ANSICHAR');
    OP_OLEVARIANT_FROM_WIDECHAR := -Add('OLEVARIANT FROM WIDECHAR');
    OP_OLEVARIANT_FROM_WIDECHAR_LITERAL := -Add('OLEVARIANT FROM WIDECHAR LITERAL');
    OP_OLEVARIANT_FROM_INT := -Add('OLEVARIANT FROM INT');
    OP_OLEVARIANT_FROM_INT64 := -Add('OLEVARIANT FROM INT64');
    OP_OLEVARIANT_FROM_BYTE := -Add('OLEVARIANT FROM BYTE');
    OP_OLEVARIANT_FROM_BOOL := -Add('OLEVARIANT FROM BOOL');
    OP_OLEVARIANT_FROM_WORD := -Add('OLEVARIANT FROM WORD');
    OP_OLEVARIANT_FROM_CARDINAL := -Add('OLEVARIANT FROM CARDINAL');
    OP_OLEVARIANT_FROM_SMALLINT := -Add('OLEVARIANT FROM SMALLINT');
    OP_OLEVARIANT_FROM_SHORTINT := -Add('OLEVARIANT FROM SHORTINT');
    OP_OLEVARIANT_FROM_DOUBLE := -Add('OLEVARIANT FROM DOUBLE');
    OP_OLEVARIANT_FROM_CURRENCY := -Add('OLEVARIANT FROM CURRENCY');
    OP_OLEVARIANT_FROM_SINGLE := -Add('OLEVARIANT FROM SINGLE');
    OP_OLEVARIANT_FROM_EXTENDED := -Add('OLEVARIANT FROM EXTENDED');
    OP_OLEVARIANT_FROM_INTERFACE := -Add('OLEVARIANT FROM INTERFACE');

    OP_ANSISTRING_FROM_INT := -Add('ANSISTRING FROM INT'); // JS only
    OP_ANSISTRING_FROM_DOUBLE := -Add('ANSISTRING FROM DOUBLE'); // JS only
    OP_ANSISTRING_FROM_SINGLE := -Add('ANSISTRING FROM SINGLE'); // JS only
    OP_ANSISTRING_FROM_EXTENDED := -Add('ANSISTRING FROM EXTENDED'); // JS only
    OP_ANSISTRING_FROM_BOOLEAN := -Add('ANSISTRING FROM BOOLEAN'); // JS only

    OP_UNICSTRING_FROM_INT := -Add('UNICSTRING FROM INT'); // JS only
    OP_UNICSTRING_FROM_DOUBLE := -Add('UNICSTRING FROM DOUBLE'); // JS only
    OP_UNICSTRING_FROM_SINGLE := -Add('UNICSTRING FROM SINGLE'); // JS only
    OP_UNICSTRING_FROM_EXTENDED := -Add('UNICSTRING FROM EXTENDED'); // JS only
    OP_UNICSTRING_FROM_BOOLEAN := -Add('UNICSTRING FROM BOOLEAN'); // JS only


    OP_JS_FUNC_OBJ_FROM_VARIANT := -Add('JS FUNC OBJ FROM VARIANT'); // JS only

    OP_ANSISTRING_FROM_VARIANT := -Add('ANSISTRING FROM VARIANT');
    OP_WIDESTRING_FROM_VARIANT := -Add('WIDESTRING FROM VARIANT');
    OP_UNICSTRING_FROM_VARIANT := -Add('UNICSTRING FROM VARIANT');
    OP_SHORTSTRING_FROM_VARIANT := -Add('SHORTSTRING FROM VARIANT');
    OP_DOUBLE_FROM_VARIANT := -Add('DOUBLE FROM VARIANT');
    OP_CURRENCY_FROM_VARIANT := -Add('CURRENCY FROM VARIANT');
    OP_SINGLE_FROM_VARIANT := -Add('SINGLE FROM VARIANT');
    OP_EXTENDED_FROM_VARIANT := -Add('EXTENDED FROM VARIANT');
    OP_INT64_FROM_VARIANT := -Add('INT64 FROM VARIANT');
    OP_INT_FROM_VARIANT := -Add('INT FROM VARIANT');
    OP_BYTE_FROM_VARIANT := -Add('BYTE FROM VARIANT');
    OP_WORD_FROM_VARIANT := -Add('WORD FROM VARIANT');
    OP_CARDINAL_FROM_VARIANT := -Add('CARDINAL FROM VARIANT');
    OP_BOOL_FROM_VARIANT := -Add('BOOL FROM VARIANT');
    OP_BYTEBOOL_FROM_VARIANT := -Add('BYTEBOOL FROM VARIANT');
    OP_WORDBOOL_FROM_VARIANT := -Add('WORDBOOL FROM VARIANT');
    OP_LONGBOOL_FROM_VARIANT := -Add('LONGBOOL FROM VARIANT');
    OP_SMALLINT_FROM_VARIANT := -Add('SMALLINT FROM VARIANT');
    OP_SHORTINT_FROM_VARIANT := -Add('SHORTINT FROM VARIANT');

    OP_NOT_VARIANT := -Add('not (variant)');
    OP_NEG_VARIANT := -Add('neg (variant)');
    OP_ADD_VARIANT := -Add('+ (variant)');
    OP_SUB_VARIANT := -Add('- (variant)');
    OP_MULT_VARIANT := -Add('* (variant)');
    OP_DIV_VARIANT := -Add('/ (variant)');
    OP_IDIV_VARIANT := -Add('div (variant)');
    OP_MOD_VARIANT := -Add('mod (variant)');
    OP_SHL_VARIANT := -Add('shl (variant)');
    OP_SHR_VARIANT := -Add('shr (variant)');
    OP_AND_VARIANT := -Add('and (variant)');
    OP_OR_VARIANT := -Add('or (variant)');
    OP_XOR_VARIANT := -Add('xor (variant)');
    OP_LT_VARIANT := -Add('< (variant)');
    OP_LE_VARIANT := -Add('<= (variant)');
    OP_GT_VARIANT := -Add('> (variant)');
    OP_GE_VARIANT := -Add('>= (variant)');
    OP_EQ_VARIANT := -Add('= (variant)');
    OP_NE_VARIANT := -Add('<> (variant)');

    OP_EQ_EVENT := -Add('= (event)');
    OP_NE_EVENT := -Add('<> (event)');

    OP_VARIANT_CLR := -Add('VARIANT CLR');

    OP_ADD_ANSISTRING := -Add('+ (ansistring)');
    OP_ADD_SHORTSTRING := -Add('+ (shortstring)');
    OP_ADD_WIDESTRING := -Add('+ (widestring)');
    OP_ADD_UNICSTRING := -Add('+ (unicstring)');

    OP_EQ_STRUCT := -Add('= (struct)');
    OP_NE_STRUCT := -Add('<> (struct)');

    OP_EQ_ANSISTRING := -Add('= (ansistring)');
    OP_EQ_SHORTSTRING := -Add('= (shortstring)');
    OP_EQ_WIDESTRING := -Add('= (widestring)');
    OP_EQ_UNICSTRING := -Add('= (unicstring)');

    OP_NE_ANSISTRING := -Add('<> (ansistring)');
    OP_NE_SHORTSTRING := -Add('<> (shortstring)');
    OP_NE_WIDESTRING := -Add('<> (widestring)');
    OP_NE_UNICSTRING := -Add('<> (unicstring)');

    OP_GT_ANSISTRING := -Add('> (ansistring)');
    OP_GE_ANSISTRING := -Add('>= (ansistring)');
    OP_LT_ANSISTRING := -Add('< (ansistring)');
    OP_LE_ANSISTRING := -Add('<= (ansistring)');

    OP_GT_SHORTSTRING := -Add('> (shortstring)');
    OP_GE_SHORTSTRING := -Add('>= (shortstring)');
    OP_LT_SHORTSTRING := -Add('< (shortstring)');
    OP_LE_SHORTSTRING := -Add('<= (shortstring)');

    OP_GT_WIDESTRING := -Add('> (widestring)');
    OP_GE_WIDESTRING := -Add('>= (widestring)');
    OP_LT_WIDESTRING := -Add('< (widestring)');
    OP_LE_WIDESTRING := -Add('<= (widestring)');

    OP_GT_UNICSTRING := -Add('> (unicstring)');
    OP_GE_UNICSTRING := -Add('>= (unicstring)');
    OP_LT_UNICSTRING := -Add('< (unicstring)');
    OP_LE_UNICSTRING := -Add('<= (unicstring)');

    OP_ANSISTRING_CLR := -Add('ANSISTRING CLR');
    OP_WIDESTRING_CLR := -Add('WIDESTRING CLR');
    OP_UNICSTRING_CLR := -Add('UNICSTRING CLR');
    OP_STRUCTURE_CLR := -Add('STRUCTURE CLR');
    OP_INTERFACE_CLR := -Add('INTERFACE CLR');
    OP_CLASS_CLR := -Add('CLASS CLR');

    OP_STRUCTURE_ADDREF := -Add('STRUCTURE ADDREF');

    OP_ADD_INT_MI := -Add('+ (integer, mi)');
    OP_ADD_INT_MM := -Add('+ (integer, mm)');

    OP_SUB_INT_MI := -Add('- (integer, mi)');
    OP_SUB_INT_MM := -Add('- (integer, mm)');

    OP_IMUL_INT_MI := -Add('imul (integer, mi)');
    OP_IMUL_INT_MM := -Add('imul (integer, mm)');

    OP_IDIV_INT_MI := -Add('idiv (integer, mi)');
    OP_IDIV_INT_MM := -Add('idiv (integer, mm)');
    OP_IDIV_INT_IM := -Add('idiv (integer, im)');

    OP_MOD_INT_MI := -Add('mod (integer, mi)');
    OP_MOD_INT_MM := -Add('mod (integer, mm)');
    OP_MOD_INT_IM := -Add('mod (integer, im)');

    OP_SHL_INT_MI := -Add('shl (integer, mi)');
    OP_SHL_INT_MM := -Add('shl (integer, mm)');
    OP_SHL_INT_IM := -Add('shl (integer, im)');

    OP_SHR_INT_MI := -Add('shr (integer, mi)');
    OP_SHR_INT_MM := -Add('shr (integer, mm)');
    OP_SHR_INT_IM := -Add('shr (integer, im)');

    OP_AND_INT_MI := -Add('and (integer, mi)');
    OP_AND_INT_MM := -Add('and (integer, mm)');

    OP_OR_INT_MI := -Add('or (integer, mi)');
    OP_OR_INT_MM := -Add('or (integer, mm)');

    OP_XOR_INT_MI := -Add('xor (integer, mi)');
    OP_XOR_INT_MM := -Add('xor (integer, mm)');

    OP_NEG_INT := -Add('NEG (integer)');
    OP_NEG_INT64 := -Add('NEG64 (integer)');

    OP_ABS_INT := -Add('ABS (integer)');
    OP_ABS_INT64 := -Add('ABS (int64)');
    OP_ABS_DOUBLE := -Add('ABS (double)');
    OP_ABS_SINGLE := -Add('ABS (single)');
    OP_ABS_EXTENDED := -Add('ABS (extended)');
    OP_ABS_VARIANT := -Add('ABS (variant)');

    OP_LT_INT_MI := -Add('< (integer, mi)');
    OP_LT_INT_MM := -Add('< (integer, mm)');

    OP_LE_INT_MI := -Add('<= (integer, mi)');
    OP_LE_INT_MM := -Add('<= (integer, mm)');

    OP_GT_INT_MI := -Add('> (integer, mi)');
    OP_GT_INT_MM := -Add('> (integer, mm)');

    OP_GE_INT_MI := -Add('>= (integer, mi)');
    OP_GE_INT_MM := -Add('>= (integer, mm)');

    OP_EQ_INT_MI := -Add('= (integer, mi)');
    OP_EQ_INT_MM := -Add('= (integer, mm)');

    OP_NE_INT_MI := -Add('<> (integer, mi)');
    OP_NE_INT_MM := -Add('<> (integer, mm)');

    OP_ADD_INT64 := -Add('+ (int64)');
    OP_SUB_INT64 := -Add('- (int64)');
    OP_AND_INT64 := -Add('AND (int64)');
    OP_OR_INT64 := -Add('OR (int64)');
    OP_XOR_INT64 := -Add('XOR (int64)');

    OP_LT_INT64 := -Add('< (int64)');
    OP_LE_INT64 := -Add('<= (int64)');
    OP_GT_INT64 := -Add('> (int64)');
    OP_GE_INT64 := -Add('>= (int64)');
    OP_EQ_INT64 := -Add('= (int64)');
    OP_NE_INT64 := -Add('<> (int64)');

    OP_ADD_CURRENCY := -Add('+ (currency)');
    OP_SUB_CURRENCY := -Add('- (currency)');
    OP_MUL_CURRENCY := -Add('* (currency)');
    OP_DIV_CURRENCY := -Add('/ (currency)');

    OP_LT_CURRENCY := -Add('< (currency)');
    OP_LE_CURRENCY := -Add('<= (currency)');
    OP_GT_CURRENCY := -Add('> (currency)');
    OP_GE_CURRENCY := -Add('>= (currency)');
    OP_EQ_CURRENCY := -Add('= (currency)');
    OP_NE_CURRENCY := -Add('<> (currency)');

    OP_ADD_DOUBLE := -Add('+ (double)');
    OP_SUB_DOUBLE := -Add('- (double)');
    OP_MUL_DOUBLE := -Add('* (double)');
    OP_DIV_DOUBLE := -Add('/ (double)');

    OP_NEG_DOUBLE := -Add('NEG (double)');
    OP_NEG_CURRENCY := -Add('NEG (currency)');

    OP_LT_DOUBLE := -Add('< (double)');
    OP_LE_DOUBLE := -Add('<= (double)');
    OP_GT_DOUBLE := -Add('> (double)');
    OP_GE_DOUBLE := -Add('>= (double)');
    OP_EQ_DOUBLE := -Add('= (double)');
    OP_NE_DOUBLE := -Add('<> (double)');

    OP_ADD_SINGLE := -Add('+ (single)');
    OP_SUB_SINGLE := -Add('- (single)');
    OP_MUL_SINGLE := -Add('* (single)');
    OP_DIV_SINGLE := -Add('/ (single)');

    OP_NEG_SINGLE := -Add('NEG (single)');

    OP_LT_SINGLE := -Add('< (single)');
    OP_LE_SINGLE := -Add('<= (single)');
    OP_GT_SINGLE := -Add('> (single)');
    OP_GE_SINGLE := -Add('>= (single)');
    OP_EQ_SINGLE := -Add('= (single)');
    OP_NE_SINGLE := -Add('<> (single)');

    OP_ADD_EXTENDED := -Add('+ (extended)');
    OP_SUB_EXTENDED := -Add('- (EXTENDED)');
    OP_MUL_EXTENDED := -Add('* (EXTENDED)');
    OP_DIV_EXTENDED := -Add('/ (EXTENDED)');

    OP_NEG_EXTENDED := -Add('NEG (EXTENDED)');

    OP_LT_EXTENDED := -Add('< (EXTENDED)');
    OP_LE_EXTENDED := -Add('<= (EXTENDED)');
    OP_GT_EXTENDED := -Add('> (EXTENDED)');
    OP_GE_EXTENDED := -Add('>= (EXTENDED)');
    OP_EQ_EXTENDED := -Add('= (EXTENDED)');
    OP_NE_EXTENDED := -Add('<> (EXTENDED)');

    OP_PUSH_ADDRESS := -Add('push address');
    OP_PUSH_STRUCTURE := -Add('push struct');
    OP_PUSH_SET := -Add('push set');

    OP_PUSH_BYTE_IMM := -Add('push (byte i)');
    OP_PUSH_BYTE := -Add('push (byte)');
    OP_PUSH_WORD_IMM := -Add('push (word i)');
    OP_PUSH_WORD := -Add('push (word)');
    OP_PUSH_CARDINAL_IMM := -Add('push (cardinal i)');
    OP_PUSH_CARDINAL := -Add('push (cardinal)');
    OP_PUSH_SMALLINT_IMM := -Add('push (smallint i)');
    OP_PUSH_SMALLINT := -Add('push (smallint)');
    OP_PUSH_SHORTINT_IMM := -Add('push (shortint i)');
    OP_PUSH_SHORTINT := -Add('push (shortint)');
    OP_PUSH_INT_IMM := -Add('push (int i)');
    OP_PUSH_INT := -Add('push (int)');

    OP_PUSH_DOUBLE := -Add('push (double)');
    OP_PUSH_CURRENCY := -Add('push (currency)');
    OP_PUSH_SINGLE := -Add('push (single)');
    OP_PUSH_EXTENDED := -Add('push (extended)');

    OP_PUSH_INT64 := -Add('push (int64)');
    OP_PUSH_DATA := -Add('push (data)');
    OP_PUSH_EVENT := -Add('push (event)');

    OP_PUSH_ANSISTRING := -Add('push (ansistring)');
    OP_PUSH_SHORTSTRING := -Add('push (shortstring)');
    OP_PUSH_WIDESTRING := -Add('push (widestring)');
    OP_PUSH_UNICSTRING := -Add('push (unicstring)');
    OP_PUSH_PANSICHAR_IMM := -Add('push (pansichar i)');
    OP_PUSH_PWIDECHAR_IMM := -Add('push (pwidechar i)');
    OP_PUSH_INST := -Add('push inst');
    OP_PUSH_CLSREF := -Add('push clsref');
    OP_PUSH_DYNARRAY := -Add('push dynarray');

    OP_SET_ASSIGN := -Add('SET ASSIGN');
    OP_SET_UNION := -Add('SET UNION');
    OP_SET_DIFFERENCE :=  -Add('SET DIFFERENCE');
    OP_SET_INTERSECTION := -Add('SET INTERSECTION');
    OP_SET_SUBSET := -Add('SET SUBSET');
    OP_SET_SUPERSET := -Add('SET SUPERSET');
    OP_SET_EQUALITY := -Add('SET EQUALITY');
    OP_SET_INEQUALITY := -Add('SET INEQUALITY');

    OP_GET_ANSISTR_PROP := -Add('GET ANSISTR PROP');
    OP_GET_WIDESTR_PROP := -Add('GET WIDESTR PROP');
    OP_GET_UNICSTR_PROP := -Add('GET UNICSTR PROP');
    OP_GET_ORD_PROP := -Add('GET ORD PROP');
    OP_GET_SET_PROP := -Add('GET SET PROP');
    OP_GET_INTERFACE_PROP := -Add('GET INTERFACE PROP');
    OP_GET_FLOAT_PROP := -Add('GET FLOAT PROP');
    OP_GET_VARIANT_PROP := -Add('GET VARIANT PROP');
    OP_GET_INT64_PROP := -Add('GET INT64 PROP');
    OP_GET_EVENT_PROP := -Add('GET EVENT PROP');

{$IFDEF UNIC}
    OP_ADD_STRING := OP_ADD_UNICSTRING;
{$ELSE}
    OP_ADD_STRING := OP_ADD_ANSISTRING;
{$ENDIF}

    OP_DUMMY := - Add('DUMMY');

    if IsDump then
      SaveToFile('operators.txt');
  end;

  AsmOperators := TStringList.Create;
  with AsmOperators do
  begin
    ASM_NOP := Add('NOP');
    ASM_WAIT := Add('WAIT');
    ASM_CLC := Add('CLC');
    ASM_PUSHFD := Add('PUSHFD');
    ASM_POPFD := Add('POPFD');
    
    ASM_XCHG := Add('XCHG');

    ASM_MOV := Add('MOV');
    ASM_LEA := Add('LEA');
    ASM_TEST := Add('TEST');

    ASM_ADD := Add('ADD');
    ASM_ADC := Add('ADC');
    ASM_SBB := Add('SBB');
    ASM_NEG := Add('NEG');
    ASM_SUB := Add('SUB');
    ASM_MUL := Add('MUL');
    ASM_IMUL := Add('IMUL');
    ASM_DIV := Add('DIV');
    ASM_IDIV := Add('IDIV');
    ASM_XOR := Add('XOR');
    ASM_AND := Add('AND');
    ASM_OR := Add('OR');
    ASM_SHL := Add('SHL');
    ASM_SHR := Add('SHR');

    ASM_CDQ := Add('CDQ');

    ASM_CALL := Add('CALL');
    ASM_RET := Add('RET');
    ASM_PUSH := Add('PUSH');
    ASM_POP := Add('POP');
    ASM_JMP := Add('JMP');

    ASM_JNO := Add('JNO');
    ASM_JNC := Add('JNC');
    ASM_JZ  := Add('JZ');
    ASM_JNZ := Add('JNZ');
    ASM_JBE := Add('JBE');
    ASM_JNLE:= Add('JNLE');

    ASM_FLD := Add('FLD');
    ASM_FILD := Add('FILD');
    ASM_FISTP := Add('FISTP');
    ASM_FSTP := Add('FSTP');
    ASM_FADD := Add('FADD');
    ASM_FSUB := Add('FSUB');
    ASM_FMUL := Add('FMUL');
    ASM_FDIV := Add('FDIV');
    ASM_FCOMP := Add('FCOMP');
    ASM_FCOMPP := Add('FCOMPP');
    ASM_FSTSV := Add('FSTSV');
    ASM_SAHF := Add('SAHF');
    ASM_FCHS := Add('FCHS');
    ASM_FABS := Add('FABS');

    ASM_SETL := Add('SETL'); // <
    ASM_SETLE := Add('SETLE'); // <=
    ASM_SETNLE := Add('SETNLE'); // >
    ASM_SETNL := Add('SETNL'); // >=

    ASM_SETB := Add('SETB'); // <
    ASM_SETBE := Add('SETBE'); // <=
    ASM_SETNBE := Add('SETNBE'); // >
    ASM_SETNB := Add('SETNB'); // >=
    ASM_SETZ := Add('SETZ'); // =
    ASM_SETNZ := Add('SETNZ'); // =

    ASM_CMP := Add('CMP');

    ASM_REP_MOVSB := Add('REP MOVSB');
    ASM_REP_MOVSD := Add('REP MOVSD');

    DynDestrList := TIntegerList.Create;
    with DynDestrList do
    begin
      Add(OP_VARIANT_CLR);
      Add(OP_ANSISTRING_CLR);
      Add(OP_WIDESTRING_CLR);
      Add(OP_UNICSTRING_CLR);
      Add(OP_INTERFACE_CLR);
      Add(OP_DYNARRAY_CLR);
      Add(OP_STRUCTURE_CLR);
    end;

  end;

finalization

  Types.Free;
  Kinds.Free;
  Operators.Free;
  AsmOperators.Free;
  DynDestrList.Free;
end.
