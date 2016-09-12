unit PaxCompilerDLL;

interface

const
  DLL = 'PaxCompilerLib.dll';

/////////////////////// PaxCompiler ////////////////////////////////////////////
function PaxCompiler_Create: Integer; stdcall; external DLL;
procedure PaxCompiler_Destroy(HCompiler: Integer); stdcall; external DLL;
procedure PaxCompiler_Reset(HCompiler: Integer); stdcall; external DLL;
procedure PaxCompiler_AddModule(HCompiler: Integer; Name, LanguageName: PChar); stdcall; external DLL;
procedure PaxCompiler_AddCode(HCompiler: Integer; ModuleName, Text: PChar); stdcall; external DLL;
procedure PaxCompiler_AddCodeFromFile(HCompiler: Integer; ModuleName, FileName: PChar); stdcall; external DLL;
procedure PaxCompiler_RegisterLanguage(HCompiler, HLanguage: Integer); stdcall; external DLL;
function  PaxCompiler_RegisterNamespace(HCompiler, LevelId: Integer; NamespaceName: PChar): Integer; stdcall; external DLL;
function  PaxCompiler_RegisterRecordType(HCompiler, LevelId: Integer; TypeName: PChar): Integer; stdcall; external DLL;
function  PaxCompiler_RegisterRecordTypeField(HCompiler, RecordTypeId: Integer; FieldName: PChar; FieldTypeID: Integer): Integer; stdcall; external DLL;
function  PaxCompiler_RegisterSubrangeType(HCompiler, LevelId: Integer; TypeName: PChar; TypeBaseId: Integer; B1, B2: Integer): Integer; stdcall; external DLL;
function  PaxCompiler_RegisterArrayType(HCompiler, LevelId: Integer; TypeName: PChar; RangeTypeId, ElemTypeId: Integer): Integer; stdcall; external DLL;
function  PaxCompiler_RegisterPointerType(HCompiler, LevelId: Integer; TypeName: PChar; OriginTypeId: Integer): Integer; stdcall; external DLL;
function  PaxCompiler_RegisterSetType(HCompiler, LevelId: Integer; TypeName: PChar; OriginTypeId: Integer): Integer; stdcall; external DLL;
function  PaxCompiler_RegisterProceduralType(HCompiler, LevelId: Integer; TypeName: PChar; SubId: Integer): Integer; stdcall; external DLL;
function  PaxCompiler_RegisterVariable(HCompiler, LevelId: Integer; Name: PChar; TypeId: Integer): Integer; stdcall; external DLL;
function  PaxCompiler_RegisterRoutine(HCompiler, LevelId: Integer; Name: PChar; ResultTypeID: Integer): Integer; stdcall; external DLL;
function  PaxCompiler_RegisterRoutineEx(HCompiler, LevelId: Integer; Name: PChar; ResultTypeID: Integer; CallConvention: Integer): Integer; stdcall; external DLL;
function  PaxCompiler_RegisterParameter(HCompiler, HSub: Integer; ParamTypeID: Integer; ByRef: Boolean): Integer; stdcall; external DLL;
function  PaxCompiler_RegisterClassType(HCompiler, LevelId: Integer; C: TClass): Integer; stdcall; external DLL;
function  PaxCompiler_RegisterHeader(HCompiler, LevelId: Integer; const Header: PChar; Address: Pointer = nil): Integer; stdcall; external DLL;
function  PaxCompiler_GetHandle(HCompiler, LevelId: Integer; Name: PChar; Upcase: Boolean): Integer; stdcall; external DLL;
function  PaxCompiler_Compile(HCompiler, HProgram: Integer): boolean; stdcall; external DLL;
function  PaxCompiler_GetErrorCount(HCompiler: Integer): Integer; stdcall; external DLL;
function  PaxCompiler_GetErrorMessage(HCompiler, I: Integer): PChar; stdcall; external DLL;
function  PaxCompiler_GetErrorModuleName(HCompiler, I: Integer): PChar; stdcall; external DLL;
function  PaxCompiler_GetErrorLine(HCompiler, I: Integer): PChar; stdcall; external DLL;
function  PaxCompiler_GetErrorLineNumber(HCompiler, I: Integer): Integer; stdcall; external DLL;

/////////////////////// PaxProgram /////////////////////////////////////////////
function  PaxProgram_Create: Integer; stdcall; external DLL;
procedure PaxProgram_Destroy(HProgram: Integer); stdcall; external DLL;
procedure PaxProgram_Run(HProgram: Integer); stdcall; external DLL;
procedure PaxProgram_SaveToFile(HProgram: Integer; Path: PChar); stdcall; external DLL;
procedure PaxProgram_LoadFromFile(HProgram: Integer; Path: PChar); stdcall; external DLL;
function  PaxProgram_GetAddress(HProgram: Integer; Handle: Integer): Pointer; stdcall; external DLL;
procedure PaxProgram_SetAddress(HProgram, Handle: Integer; P: Pointer); stdcall; external DLL;
procedure PaxProgram_BeginCall(HProgram: Integer); stdcall; external DLL;
procedure PaxProgram_EndCall(HProgram: Integer); stdcall; external DLL;
function  PaxProgram_GetDataPtr(HProgram: Integer): Pointer; stdcall; external DLL;
function  PaxProgram_GetCodePtr(HProgram: Integer): Pointer; stdcall; external DLL;

/////////////////////// PaxPascalLanguage //////////////////////////////////////
function  PaxPascalLanguage_Create: Integer; stdcall; external DLL;
procedure PaxPascalLanguage_Destroy(HPaxPascalLanguage: Integer); stdcall; external DLL;
procedure PaxPascalLanguage_SetCallConv(HPaxPascalLanguage: Integer; cc: Integer); stdcall; external DLL;

implementation

end.
