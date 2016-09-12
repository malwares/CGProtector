#if !defined (PAXCOMPILERLIB)
#define PAXCOMPILERLIB

#include "windows.h"
#define PaxProcDef typedef 

#define ccSTDCALL 1
#define ccCDECL 3

#define PaxTypeVOID 1
#define PaxTypeBOOLEAN 2
#define PaxTypeBYTE 3
#define PaxTypeCHAR 4
#define PaxTypeWORD 6
#define PaxTypeLONG 7
#define PaxTypeDOUBLE 8
#define PaxTypePOINTER 9
#define PaxTypeSINGLE 17
#define PaxTypePCHAR 19
#define PaxTypePVOID 20

//------------- PaxCompiler ----------------------------------------------------

PaxProcDef DWORD (__stdcall *P_PaxCompiler_Create) (); 
P_PaxCompiler_Create PaxCompiler_Create;

PaxProcDef void (__stdcall *P_PaxCompiler_Destroy) (DWORD HCompiler);
P_PaxCompiler_Destroy PaxCompiler_Destroy;

PaxProcDef void (__stdcall *P_PaxCompiler_Reset) (DWORD HCompiler);
P_PaxCompiler_Reset PaxCompiler_Reset;

PaxProcDef void (__stdcall *P_PaxCompiler_AddModule) (DWORD HCompiler, char * Name, char * LanguageName);
P_PaxCompiler_AddModule PaxCompiler_AddModule;

PaxProcDef void (__stdcall *P_PaxCompiler_AddCode) (DWORD HCompiler, char * ModuleName, char * Text);
P_PaxCompiler_AddCode PaxCompiler_AddCode;

PaxProcDef void (__stdcall *P_PaxCompiler_AddCodeFromFile) (DWORD HCompiler, char * ModuleName, char * FileName);
P_PaxCompiler_AddCodeFromFile PaxCompiler_AddCodeFromFile;

PaxProcDef void (__stdcall *P_PaxCompiler_RegisterLanguage) (DWORD HCompiler, DWORD HLanguage);
P_PaxCompiler_RegisterLanguage PaxCompiler_RegisterLanguage;

// importing procs

PaxProcDef DWORD (__stdcall *P_PaxCompiler_RegisterNamespace) (DWORD HCompiler, DWORD LevelId, char * NamespaceName);
P_PaxCompiler_RegisterNamespace PaxCompiler_RegisterNamespace;

PaxProcDef DWORD (__stdcall *P_PaxCompiler_RegisterRecordType) (DWORD HCompiler, DWORD LevelId, char * TypeName);
P_PaxCompiler_RegisterRecordType PaxCompiler_RegisterRecordType;

PaxProcDef DWORD (__stdcall *P_PaxCompiler_RegisterRecordTypeField) (DWORD HCompiler,
                  DWORD RecordTypeId, char * FieldName, DWORD FieldTypeID);
P_PaxCompiler_RegisterRecordTypeField PaxCompiler_RegisterRecordTypeField;

PaxProcDef DWORD (__stdcall *P_PaxCompiler_RegisterSubrangeType) (DWORD HCompiler, DWORD LevelId,
                                            char * TypeName, DWORD TypeBaseId, DWORD B1, DWORD B2);
P_PaxCompiler_RegisterSubrangeType PaxCompiler_RegisterSubrangeType;

PaxProcDef DWORD (__stdcall *P_PaxCompiler_RegisterArrayType) (DWORD HCompiler, DWORD LevelId,
                 char * TypeName, DWORD RangeTypeId, DWORD ElemTypeId);
P_PaxCompiler_RegisterArrayType PaxCompiler_RegisterArrayType;

PaxProcDef DWORD (__stdcall *P_PaxCompiler_RegisterPointerType) (DWORD HCompiler,
                 DWORD LevelId, char * TypeName, DWORD OriginTypeId);
P_PaxCompiler_RegisterPointerType PaxCompiler_RegisterPointerType;

PaxProcDef DWORD (__stdcall *P_PaxCompiler_RegisterSetType) (DWORD HCompiler,
                 DWORD LevelId, char * TypeName, DWORD OriginTypeId);
P_PaxCompiler_RegisterSetType PaxCompiler_RegisterSetType;

PaxProcDef DWORD (__stdcall *P_PaxCompiler_RegisterProceduralType) (DWORD HCompiler,
                DWORD LevelId, char * TypeName, DWORD SubId);
P_PaxCompiler_RegisterProceduralType PaxCompiler_RegisterProceduralType;

PaxProcDef DWORD (__stdcall *P_PaxCompiler_RegisterVariable) (DWORD HCompiler,
                DWORD LevelId, char * Name, DWORD TypeId);
P_PaxCompiler_RegisterVariable PaxCompiler_RegisterVariable;

PaxProcDef DWORD (__stdcall *P_PaxCompiler_RegisterRoutine) (DWORD HCompiler,
                DWORD LevelId, char * Name, DWORD ResultTypeID);
P_PaxCompiler_RegisterRoutine PaxCompiler_RegisterRoutine;

PaxProcDef DWORD (__stdcall *P_PaxCompiler_RegisterRoutineEx) (DWORD HCompiler,
                DWORD LevelId, char * Name, DWORD ResultTypeID, DWORD CallConvention);
P_PaxCompiler_RegisterRoutineEx PaxCompiler_RegisterRoutineEx;

PaxProcDef DWORD (__stdcall *P_PaxCompiler_RegisterParameter) (DWORD HCompiler,
                 DWORD HSub, DWORD ParamTypeID, bool ByRef);
P_PaxCompiler_RegisterParameter PaxCompiler_RegisterParameter;                

// compile

PaxProcDef DWORD (__stdcall *P_PaxCompiler_Compile) (DWORD HCompiler, DWORD HProgram);
P_PaxCompiler_Compile PaxCompiler_Compile;

// error processing

PaxProcDef DWORD (__stdcall *P_PaxCompiler_GetErrorCount) (DWORD HCompiler);
P_PaxCompiler_GetErrorCount PaxCompiler_GetErrorCount;

PaxProcDef char * (__stdcall *P_PaxCompiler_GetErrorMessage) (DWORD HCompiler, DWORD i);
P_PaxCompiler_GetErrorMessage PaxCompiler_GetErrorMessage;

PaxProcDef char * (__stdcall *P_PaxCompiler_GetErrorModuleName) (DWORD HCompiler, DWORD i);
P_PaxCompiler_GetErrorModuleName PaxCompiler_GetErrorModuleName;

PaxProcDef char * (__stdcall *P_PaxCompiler_GetErrorLine) (DWORD HCompiler, DWORD i);
P_PaxCompiler_GetErrorLine PaxCompiler_GetErrorLine;

PaxProcDef DWORD (__stdcall *P_PaxCompiler_GetErrorLineNumber) (DWORD HCompiler, DWORD i);
P_PaxCompiler_GetErrorLineNumber PaxCompiler_GetErrorLineNumber;

PaxProcDef DWORD (__stdcall *P_PaxCompiler_GetHandle) (DWORD HCompiler, DWORD LevelId,
                char * Name, DWORD Upcase);
P_PaxCompiler_GetHandle PaxCompiler_GetHandle;

//------------- PaxProgram -----------------------------------------------------

PaxProcDef DWORD (__stdcall *P_PaxProgram_Create) ();
P_PaxProgram_Create PaxProgram_Create;

PaxProcDef void (__stdcall *P_PaxProgram_Destroy) (DWORD HCompiler);
P_PaxProgram_Destroy PaxProgram_Destroy;

PaxProcDef void (__stdcall *P_PaxProgram_Run) (DWORD HProgram);
P_PaxProgram_Run PaxProgram_Run;

PaxProcDef void (__stdcall *P_PaxProgram_SaveToFile) (DWORD HProgram, char * Path);
P_PaxProgram_SaveToFile PaxProgram_SaveToFile;

PaxProcDef void (__stdcall *P_PaxProgram_LoadFromFile) (DWORD HProgram, char * Path);
P_PaxProgram_LoadFromFile PaxProgram_LoadFromFile;

PaxProcDef void * (__stdcall *P_PaxProgram_GetAddress) (DWORD HProgram, DWORD Handle);
P_PaxProgram_GetAddress PaxProgram_GetAddress;

PaxProcDef void (__stdcall *P_PaxProgram_SetAddress) (DWORD HProgram, DWORD Handle, void * p);
P_PaxProgram_SetAddress PaxProgram_SetAddress;

PaxProcDef void * (__stdcall *P_PaxProgram_GetDataPtr) (DWORD HProgram);
P_PaxProgram_GetDataPtr PaxProgram_GetDataPtr;

PaxProcDef void * (__stdcall *P_PaxProgram_GetCodePtr) (DWORD HProgram);
P_PaxProgram_GetCodePtr PaxProgram_GetCodePtr;

//------------- PaxLanguage ----------------------------------------------------

PaxProcDef DWORD (__stdcall *P_PaxPascalLanguage_Create) ();
P_PaxPascalLanguage_Create PaxPascalLanguage_Create;

PaxProcDef void (__stdcall *P_PaxPascalLanguage_Destroy) (DWORD HPaxPascalLanguage);
P_PaxPascalLanguage_Destroy PaxPascalLanguage_Destroy;

//------------------------------------------------------------------------------


HMODULE LoadPaxCompilerLib()
{
        HMODULE h_lib = LoadLibrary("PaxCompilerLib.dll");
        if (h_lib != 0)
        {
//------------- PaxCompiler ----------------------------------------------------
                PaxCompiler_Create = (P_PaxCompiler_Create) GetProcAddress(h_lib, "PaxCompiler_Create");
                PaxCompiler_Destroy = (P_PaxCompiler_Destroy) GetProcAddress(h_lib, "PaxCompiler_Destroy");
                PaxCompiler_Reset = (P_PaxCompiler_Reset) GetProcAddress(h_lib, "PaxCompiler_Reset");

                PaxCompiler_AddModule = (P_PaxCompiler_AddModule) GetProcAddress(h_lib, "PaxCompiler_AddModule");
                PaxCompiler_AddCode = (P_PaxCompiler_AddCode) GetProcAddress(h_lib, "PaxCompiler_AddCode");
                PaxCompiler_AddCodeFromFile = (P_PaxCompiler_AddCodeFromFile) GetProcAddress(h_lib, "PaxCompiler_AddCodeFromFile");

                PaxCompiler_RegisterLanguage = (P_PaxCompiler_RegisterLanguage) GetProcAddress(h_lib, "PaxCompiler_RegisterLanguage");

                PaxCompiler_RegisterNamespace = (P_PaxCompiler_RegisterNamespace) GetProcAddress(h_lib, "PaxCompiler_RegisterNamespace");

                PaxCompiler_RegisterRecordType = (P_PaxCompiler_RegisterRecordType) GetProcAddress(h_lib, "PaxCompiler_RegisterRecordType");
                PaxCompiler_RegisterRecordTypeField = (P_PaxCompiler_RegisterRecordTypeField) GetProcAddress(h_lib, "PaxCompiler_RegisterRecordTypeField");
                PaxCompiler_RegisterSubrangeType = (P_PaxCompiler_RegisterSubrangeType) GetProcAddress(h_lib, "PaxCompiler_RegisterSubrangeType");
                PaxCompiler_RegisterArrayType = (P_PaxCompiler_RegisterArrayType) GetProcAddress(h_lib, "PaxCompiler_RegisterArrayType");
                PaxCompiler_RegisterPointerType = (P_PaxCompiler_RegisterPointerType) GetProcAddress(h_lib, "PaxCompiler_RegisterPointerType");
                PaxCompiler_RegisterSetType = (P_PaxCompiler_RegisterSetType) GetProcAddress(h_lib, "PaxCompiler_RegisterSetType");
                PaxCompiler_RegisterProceduralType = (P_PaxCompiler_RegisterProceduralType) GetProcAddress(h_lib, "PaxCompiler_RegisterProceduralType");

                PaxCompiler_RegisterVariable = (P_PaxCompiler_RegisterVariable) GetProcAddress(h_lib, "PaxCompiler_RegisterVariable");
                PaxCompiler_RegisterRoutine = (P_PaxCompiler_RegisterRoutine) GetProcAddress(h_lib, "PaxCompiler_RegisterRoutine");
                PaxCompiler_RegisterRoutineEx = (P_PaxCompiler_RegisterRoutineEx) GetProcAddress(h_lib, "PaxCompiler_RegisterRoutineEx");
                PaxCompiler_RegisterParameter = (P_PaxCompiler_RegisterParameter) GetProcAddress(h_lib, "PaxCompiler_RegisterParameter");

                PaxCompiler_GetHandle = (P_PaxCompiler_GetHandle) GetProcAddress(h_lib, "PaxCompiler_GetHandle");

                PaxCompiler_Compile = (P_PaxCompiler_Compile) GetProcAddress(h_lib, "PaxCompiler_Compile");

                PaxCompiler_GetErrorCount = (P_PaxCompiler_GetErrorCount) GetProcAddress(h_lib, "PaxCompiler_GetErrorCount");
                PaxCompiler_GetErrorMessage = (P_PaxCompiler_GetErrorMessage) GetProcAddress(h_lib, "PaxCompiler_GetErrorMessage");
                PaxCompiler_GetErrorModuleName = (P_PaxCompiler_GetErrorModuleName) GetProcAddress(h_lib, "PaxCompiler_GetErrorModuleName");
                PaxCompiler_GetErrorLine = (P_PaxCompiler_GetErrorLine) GetProcAddress(h_lib, "PaxCompiler_GetErrorLine");
                PaxCompiler_GetErrorLineNumber = (P_PaxCompiler_GetErrorLineNumber) GetProcAddress(h_lib, "PaxCompiler_GetErrorLineNumber");

//------------- PaxProgram -----------------------------------------------------
                PaxProgram_Create = (P_PaxProgram_Create) GetProcAddress(h_lib, "PaxProgram_Create");
                PaxProgram_Destroy = (P_PaxProgram_Destroy) GetProcAddress(h_lib, "PaxProgram_Destroy");
                PaxProgram_Run = (P_PaxProgram_Run) GetProcAddress(h_lib, "PaxProgram_Run");
                PaxProgram_SaveToFile = (P_PaxProgram_SaveToFile) GetProcAddress(h_lib, "PaxProgram_SaveToFile");
                PaxProgram_LoadFromFile = (P_PaxProgram_LoadFromFile) GetProcAddress(h_lib, "PaxProgram_LoadFromFile");
                PaxProgram_GetAddress = (P_PaxProgram_GetAddress) GetProcAddress(h_lib, "PaxProgram_GetAddress");
                PaxProgram_SetAddress = (P_PaxProgram_SetAddress) GetProcAddress(h_lib, "PaxProgram_SetAddress");
                PaxProgram_GetDataPtr = (P_PaxProgram_GetDataPtr) GetProcAddress(h_lib, "PaxProgram_GetDataPtr");
                PaxProgram_GetCodePtr = (P_PaxProgram_GetCodePtr) GetProcAddress(h_lib, "PaxProgram_GetCodePtr");

//------------- PaxLanguage ----------------------------------------------------
                PaxPascalLanguage_Create = (P_PaxPascalLanguage_Create) GetProcAddress(h_lib, "PaxPascalLanguage_Create");
                PaxPascalLanguage_Destroy = (P_PaxPascalLanguage_Destroy) GetProcAddress(h_lib, "PaxPascalLanguage_Destroy");
        }
        return h_lib;
}

long FreePaxCompilerLib(HMODULE h_lib)
{
        if (h_lib != 0)
        {
                return FreeLibrary(h_lib);
        }
}

#endif