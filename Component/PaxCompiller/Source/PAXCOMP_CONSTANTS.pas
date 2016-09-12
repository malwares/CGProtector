////////////////////////////////////////////////////////////////////////////
// PaxCompiler
// Site: http://www.paxcompiler.com
// Author: Alexander Baranovsky (paxscript@gmail.com)
// ========================================================================
// Copyright (c) Alexander Baranovsky, 2006-2008. All rights reserved.
// Code Version: 2.4
// ========================================================================
// Unit: PAXCOMP_CONSTANTS.pas
// ========================================================================
////////////////////////////////////////////////////////////////////////////

{$I PaxCompiler.def}
unit PAXCOMP_CONSTANTS;
interface

type
{$IFDEF UNIC}
  UnicString = UnicodeString;
{$ELSE}
  UnicString = WideString;
{$ENDIF}

  PUnicString = ^UnicString;

  TPaxLang = (lngPascal, lngC, lngBasic, lngJS);

var
  IsDump: Boolean = false;

const
{$IFDEF UNIC}
//  IsUnic = true;
{$ELSE}
//  IsUnic = false;
{$ENDIF}

  PM_BYVAL = 0;
  PM_BYREF = 1;
  PM_CONST = 2;

  PCU_FILE_EXT = 'PCU';
  MAGIC_INITIALIZATION_JMP_COUNT = 5;
  MAGIC_FINALIZATION_JMP_COUNT = 7;

  DummyName = '__DummyName';
  PARAMS_DELIMITER = '-';

  DUMMYPROC_PREFIX = 'DummyProc_';

  READ_PREFIX = '_Read_';
  WRITE_PREFIX = '_Write_';

  IntMaxArgs = 20;

  ccSTDCALL = 1;
  ccREGISTER = 2;
  ccCDECL = 3;
  ccPASCAL = 4;
  ccSAFECALL = 5;
  ccMSFASTCALL = 6;

  typeVOID = 1;
  typeBOOLEAN = 2;
  typeBYTE = 3;
  typeANSICHAR = 4;
  typeANSISTRING = 5;
  typeWORD = 6;
  typeINTEGER = 7;
  typeDOUBLE = 8;
  typePOINTER = 9;
  typeRECORD = 10;
  typeARRAY = 11;
  typeALIAS = 12;
  typeENUM = 13;
  typePROC = 14;
  typeSET = 15;
  typeSHORTSTRING = 16;
  typeSINGLE = 17;
  typeEXTENDED = 18;
  typeCLASS = 19;
  typeCLASSREF = 20;
  typeWIDECHAR = 21;
  typeWIDESTRING = 22;
  typeVARIANT = 23;
  typeDYNARRAY = 24;
  typeINT64 = 25;
  typeINTERFACE = 26;
  typeCARDINAL = 27;
  typeEVENT = 28;
  typeCURRENCY = 29;
  typeSMALLINT = 30;
  typeSHORTINT = 31;
  typeWORDBOOL = 32;
  typeLONGBOOL = 33;
  typeBYTEBOOL = 34;
  typeOLEVARIANT = 35;
  typeUNICSTRING = 36;

  typePANSICHAR = 49;
  typePVOID = 50;
  typePWIDECHAR = 51;

{$IFDEF UNIC}
  typeSTRING = typeUNICSTRING;
  typeCHAR = typeWIDECHAR;
  typePCHAR = typePWIDECHAR;
{$ELSE}
  typeSTRING = typeANSISTRING;
  typeCHAR = typeANSICHAR;
  typePCHAR = typePANSICHAR;
{$ENDIF}

  CURR_MUL = 10000;

  rmRUN = 0;
  rmTRACE_INTO = 1;
  rmSTEP_OVER = 2;
  rmRUN_TO_CURSOR = 3;

  PASCAL_LANGUAGE = 0;
  C_LANGUAGE = 1;
  BASIC_LANGUAGE = 2;
  JS_LANGUAGE = 3;

  CHAR_EOF = #255;
  CHAR_REMOVE = #254;
  CHAR_AP  = '''';
  CHAR_DOUBLE_AP  = '"';

  cmNONE = 0;
  cmVIRTUAL = 1;
  cmOVERRIDE = 2;

  _NOREG = 0;
  _EAX = _NOREG + 1;
  _ECX = _NOREG + 2;
  _EDX = _NOREG + 3;
  _EBX = _NOREG + 4;
  _ESP = _NOREG + 5;
  _EBP = _NOREG + 6;
  _ESI = _NOREG + 7;
  _EDI = _NOREG + 8;

  BaseRegisters = [_EBP, _ESI];
  CommonRegisters = [_EAX.._EBX];

  strPascalLanguage = 'Pascal';
  strPascalNamespace = 'PascalNamespace';

  strBasicLanguage = 'Basic';
  strBasicNamespace = 'BasicNamespace';

  strJavaScriptLanguage = 'JavaScript';
  strJavaScriptNamespace = 'JavaScriptNamespace';
  strJavaScriptTempNamespace = 'JavaScriptTempNamespace';

  strWrite = 'write';
  strWriteln = 'writeln';
  strGetTickCount = 'GetTickCount';
  strUnassigned = 'Unassigned';

  _strIs = '_Is';

// processing pause and halt

  _strPause = '_Pause';
  _strHalt = '_Halt';

//------------------ Dynamic array support routines ----------------------------

  _strDynarraySetLength = '_DynarraySetLength';
  _strDynarrayHigh = '_DynarrayHigh';

  _strGetOLEProperty = '_GetOleProperty';
  _strSetOLEProperty = '_SetOleProperty';

//------ JS --------

  strInternalFuncAddr = 'InternalFuncAddr';
  strInternalCreate = 'InternalCreate';
  strInternalLength = 'InternalLength';
  strInternalCall = 'InternalCall';
  strInternalConstructor = 'InternalConstructor';
  str__this = '__this';
  strProgram = 'aprogram';

{$IFDEF FPC}
const
{$ELSE}
resourcestring
{$ENDIF}

  errInternalError = 'Internal error';
  errInternalErrorMethodIndex = 'Internal error - method index is not set correctly';

  errUnregisteredLanguage = 'Unregistered language %s';
  errSyntaxError = 'Syntax error';
  errUnterminatedString = 'Unterminated string';
  errTokenExpected = '"%s" expected but "%s" found';
  errIdentifierExpected = 'Identifier expected but "%s" found';
  errIdentifierExpectedNoArgs = 'Identifier expected';
  errLabelExpected = 'Label expected';
  errPCharLiteralExpected = 'PChar literal expected';
  errIncompatibleTypesNoArgs = 'Incompatible types';
  errIncompatibleTypes = 'Incompatible types "%s" and "%s"';
  errOperatorNotApplicableToThisOperandType = 'Operator not applicable to "%s" type';
  errOperatorNotApplicableToThisOperandTypeNoArgs = 'Operator not applicable to this type';
  errLeftSideCannotBeAssignedTo = 'Left side cannot be assigned to';
  errUndeclaredIdentifier = 'Undeclared identifier "%s"';
  errUndeclaredType = 'Undeclared type "%s"';
  errRedeclaredIdentifier = 'Redeclared identifier "%s"';
  errModuleNotFound = 'Module "%s" not found';
  errLanguageNotRegistered = 'Language "%s" not registered';
  errFileNotFound = 'File "%s" not found';
  errTooManyActualParameters = 'Too many actual parameters';
  errNotEnoughActualParameters = 'Not enough actual parameters';
  errLabelIsDeclaredButNeverUsed = 'Label "%s" is declared but never used';
  errThereIsNoOverloaded = 'There is no overloaded version of "%s" that can be called with these arguments';
  errAmbiguousOverloadedCall = 'Ambiguous overloaded call to "%s"';
  errDefaultParameterMustBeByValueOrConst = 'Default parameter "%s" must be by-value or const';
  errParameterNotAllowedHere = 'Parameter "%s" not allowed here due to default value';
  errConstantExpressionExpected = 'Constant expression expected';
  errCannotInitializeLocalVariables = 'Cannot initialize local variables';
  errRecordRequired = 'Record required';
  errClassTypeRequired = 'Class type required';
  errArrayTypeRequired = 'Array type required';
  errSetTypeRequired = 'Set type required';
  errOrdinalTypeRequired = 'Ordinal type required';
  errIllegalTypeInWriteStatememt = 'Illegal type in Write/Writeln statement';
  errConstantExpressionViolatesSubrangeBounds = 'Constant expression violates subrange bounds';
  errLowBoundExceedsHighBound = 'Low bound exceeds high bound';
  errPACKEDNotAllowedHere = 'PACKED not allowed here';
  errVariableRequired = 'Variable required';
  errLineTerminatorExpected = 'Line terminator expected';
  errStatementTerminatorExpected = 'Statement terminator expected';
  errTypeOfExpressionMustBe = 'Type of expression must be %s';
  errBreakOrContinueOutsideOfLoop = 'BREAK or CONTINUE outside of loop';
  errNextControlVariableDoesNotMatchForLoopControlVariable = 'Next control variable does not match For loop control variable %s';
  errDivisionByZero = 'Division by zero';
  errCannotApplyCall = 'Cannot apply () to "%s"';
  errUnsatisfiedForwardOrExternalDeclaration = 'Unsatisfied forward or external declaration: "%s"';
  errCircularUnitReference = 'Circular unit reference to "%s"';
  errTypesOfActualAndFormalVarParametersMustBeIdentical = 'Types of actual and formal var parameters must be identical';
  errClassNotFound = 'Class "%s" not found';
  errTypeNotFound = 'Type "%s" not found';
  errThisFormOfMethodCanOnlyAllowedForClassMethod = 'This form of method can only allowed for class methods';
  errCannotAssignToReadOnlyProperty = 'Cannot assign to read-only property';
  errCannotReadWriteOnlyProperty = 'Cannot read a write-only property';
  errClassDoesNotHaveDefaultProperty = 'Class "%s" does not have a default property';
  errCannotRegisterClass = 'Cannot register class "%s"';
  errIMPORT_ActiveX = 'Error. You have to add "IMPORT_ActiveX.pas" to your project';
  errIntegerOverflow = 'Integer overflow';
  errRangeCheckError = 'Range check error';
  errThisFormOfMethodCallOnlyAllowedInMethodsOfDerivedTypes = 'This form of method call only allowed in methods of derived types';
  errYouCannotUseIncOnProperties = 'You can''t use Inc on properties because it modifies the parameter.';
  errYouCannotUseDecOnProperties = 'You can''t use Dec on properties because it modifies the parameter.';
  errDefaultValueRequired = 'Default value required for "%s".';
  errClassIsNotRegistered = 'Class "%s" is not registered.';
  errAbstractMethodsMustBeVirtual = 'Abstract methods must be virtual.';
  errAbstractMethodCall = 'Abstract method call.';
  errDebugModeIsRequred = 'Debug mode is required.';
  errProgramIsNotPaused = 'Program is not paused.';
  errInvalidId = 'Invalid id "%d"';
  errInvalidIndex = 'Invalid index "%d"';
  errInvalidValue = 'Invalid value';
  errMemoryNotInitialized = 'Memory not initialized';
  errNotValidObject = 'Not a valid object';
  errDllNotFound = 'This script has failed to start because %s was not found.';
  errProcNotFound = 'The procedure entry point %s could not be located in the' +
   ' dynamic link library %s.';
  errProcNotFoundInPCU = 'The procedure entry point %s could not be located in the' +
   ' pcu %s.';
  errConstructorNotFoundInClass = 'Constructor not found in class "%s"';
  errPropertyIsForbidden = 'Property "%s" of class "%s" is forbidden.';
  errHostMemberIsNotDefined = 'Host member "%s" is not defined.';
  errCannotRegisterHostMember = 'Cannot register host member "%s".';
  errInvalidAlignmentValue = '"%d" is invalid alignment value. Must be 1, 2, 4 or 8.';
  errInvalidCompilerDirective = 'Invalid compiler directive "%s".';
  errTooManyNestedCaseBlocks = 'Too many nested case blocks.';
  errProtectionLevel = ' "%s" is inaccessible due to its protection level.';
  errMissingENDIFdirective = 'Missing ENDIF directive.';
  errPropertyDoesNotExistsInTheBaseClass = 'Property "%s" does not exist in the base class.';
  errMethodDoesNotExistsInTheBaseClass = 'Method "%s" does not exist in the base class.';
  errIncorrectValue = 'Incorrect value.';
  errUnresolvedClassReference = 'Unresolved class reference "%s".';
  errUnresolvedAddress = 'Unresolved address "%s".';
  errIncorrectStreamVersion = 'Incorrect stream version.';
  errIncorrectCompiledScriptVersion = 'Incorrect compiled script version';
  errInvalidVariantType = 'Variant type not safe on debugger or invalid variant type';
  errClassTypeExpected = 'Class type expected';
  errUndeclaredInterface = 'Undeclared interface "%s"';
  errDeclarationDiffersFromPreviousDeclaration = 'Declaration of "%s" differs from previous declaration';
  errTheCallOfInheritedConstructorIsMandatory = 'The Call of inherited constructor is mandatory';
  errFieldDefinitionNotAllowedAfter = 'Field definition not allowed after methods or properties.';
  errKeywordNotAllowedInInterfaceDeclaration = '"%s" not allowed in interface declaration.';
  errUnknownDirective = 'Unknown directive "%s"';
  errCannotOverrideStaticMethod = 'Cannot override a static method';
  errNoDefinitionForAbstractMethodAllowed = 'No definition for abstract method "%s" allowed.';
  errWrongRegistration = 'Wrong registration';
  errConstantObjectCannotBePassedAsVarParameter = 'Constant object cannot be passed as var parameter';
  errError = 'error';
  errCanceled = 'Canceled';

  STooManyParams = 'Dispatch methods do not support more than 64 parameters';
  errLabelNotFound = 'Label not found';
  errRoutineNotFound = 'Routine "%s" not found';
  errPropertyNotFound = 'Property "%s" not found';
  errUnknownStreamFormat = 'Unknown stream format';
  errTypeHasNotEnumerator = 'Type "%s" has not enumerator';

//JS
  errCannotConvertToFunctionObject = 'Cannot convert to Function Object';
  errJSUnitHasBeenNotIncluded = 'JavaScript unit has been not included in current project';
  errCannotConvertToJS_Object = 'Cannot convert to JavaScript object';
  errReferenceError = 'Reference error';

implementation
end.
