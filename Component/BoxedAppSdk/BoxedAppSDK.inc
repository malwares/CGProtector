{$IFNDEF BOXEDAPP_PAS_IS_INCLUDED}
unit BoxedAppSDK;
{$ENDIF}

{$IFNDEF BOXEDAPP_SDK_USE_DLL}
{$LINK 'BoxedAppSDK.obj'}
{$ENDIF}

interface

uses Windows, ActiveX;

// Available options, see BoxedAppSDK_EnableOption and BoxedAppSDK_IsOptionEnabled
const DEF_BOXEDAPPSDK_OPTION__ALL_CHANGES_ARE_VIRTUAL = 1; // default: false
const DEF_BOXEDAPPSDK_OPTION__EMBED_BOXEDAPP_IN_CHILD_PROCESSES = 2; // default: false
const DEF_BOXEDAPPSDK_OPTION__ENABLE_VIRTUAL_FILE_SYSTEM = 3; // default: true
const DEF_BOXEDAPPSDK_OPTION__RECREATE_VIRTUAL_FILE_AS_VIRTUAL = 4; // default: 1 (TRUE)
const DEF_BOXEDAPPSDK_OPTION__ENABLE_VIRTUAL_REGISTRY = 5; // default: 1 (TRUE)
const DEF_BOXEDAPPSDK_OPTION__HIDE_VIRTUAL_FILES_FROM_FILE_DIALOG = 6; // default: 0 (FALSE)

const EnumBoxedAppSDK_RequestId__RegQueryValue = 1;
const EnumBoxedAppSDK_RequestId__RedirectFilePath = 2;

type

TBoxedAppHandler = 
	function(Param: Pointer; RequestId: DWORD; pAdditionalInfo: Pointer): DWORD; stdcall;

SBoxedAppSDK__RedirectFilePath = packed record
	// in
	m_szPath: PWideChar;

	// out
	m_bHandled: DWORD;

	m_szRedirectToPath: PWideChar;
end;
PBoxedAppSDK__RedirectFilePath = ^SBoxedAppSDK__RedirectFilePath;

SBoxedAppSDK__RegQueryValue = packed record
	// in
	m_Root: HKEY;
	m_szPath: PWideChar;
	m_szValue: PWideChar;

	// out
	m_bHandled: DWORD;

	m_dwType: DWORD;
	m_pData: Pointer;
	m_dwSize: DWORD;
end;
PBoxedAppSDK__RegQueryValue = ^SBoxedAppSDK__RegQueryValue;

TBoxedAppSDK_EnumVirtualRegKeysCallbackA = 
	function(hRootKey: HKEY; szSubKey: PAnsiChar; lParam: Cardinal): Boolean; stdcall;
TBoxedAppSDK_EnumVirtualRegKeysCallbackW = 
	function(hRootKey: HKEY; szSubKey: PWideChar; lParam: Cardinal): Boolean; stdcall;
TBoxedAppSDK_EnumVirtualRegKeysCallback = TBoxedAppSDK_EnumVirtualRegKeysCallbackA;

function BoxedAppSDK_Init: BOOL; stdcall;{$IFNDEF BOXEDAPP_SDK_USE_DLL}external;{$ENDIF}
function BoxedAppSDK_Exit: BOOL; stdcall;{$IFNDEF BOXEDAPP_SDK_USE_DLL}external;{$ENDIF}

procedure BoxedAppSDK_EnableDebugLog(bEnable: BOOL); stdcall;{$IFNDEF BOXEDAPP_SDK_USE_DLL}external;{$ENDIF}

procedure BoxedAppSDK_SetLogFile(szLogFilePath: PAnsiChar); stdcall;{$IFNDEF BOXEDAPP_SDK_USE_DLL}external;{$ENDIF}
procedure BoxedAppSDK_SetLogFileA(szLogFilePath: PAnsiChar); stdcall;{$IFNDEF BOXEDAPP_SDK_USE_DLL}external;{$ENDIF}
procedure BoxedAppSDK_SetLogFileW(szLogFilePath: PWideChar); stdcall;{$IFNDEF BOXEDAPP_SDK_USE_DLL}external;{$ENDIF}

function BoxedAppSDK_CreateVirtualFile(
         lpFileName: PAnsiChar;
         dwDesiredAccess, dwShareMode: Integer;
         lpSecurityAttributes: PSecurityAttributes;
         dwCreationDisposition, dwFlagsAndAttributes: DWORD;
         hTemplateFile: THandle): THandle; stdcall;{$IFNDEF BOXEDAPP_SDK_USE_DLL}external;{$ENDIF}

function BoxedAppSDK_CreateVirtualFileA(
         lpFileName: PAnsiChar;
         dwDesiredAccess, dwShareMode: Integer;
         lpSecurityAttributes: PSecurityAttributes;
         dwCreationDisposition, dwFlagsAndAttributes: DWORD;
         hTemplateFile: THandle): THandle; stdcall;{$IFNDEF BOXEDAPP_SDK_USE_DLL}external;{$ENDIF}

function BoxedAppSDK_CreateVirtualFileW(
         lpFileName: PWideChar;
         dwDesiredAccess, dwShareMode: Integer;
         lpSecurityAttributes: PSecurityAttributes;
         dwCreationDisposition, dwFlagsAndAttributes: DWORD;
         hTemplateFile: THandle): THandle; stdcall;{$IFNDEF BOXEDAPP_SDK_USE_DLL}external;{$ENDIF}


function BoxedAppSDK_CreateVirtualDirectory(
         lpPathName: PAnsiChar;
         lpSecurityAttributes: PSecurityAttributes): BOOL; stdcall;{$IFNDEF BOXEDAPP_SDK_USE_DLL}external;{$ENDIF}

function BoxedAppSDK_CreateVirtualDirectoryA(
         lpPathName: PAnsiChar;
         lpSecurityAttributes: PSecurityAttributes): BOOL; stdcall;{$IFNDEF BOXEDAPP_SDK_USE_DLL}external;{$ENDIF}

function BoxedAppSDK_CreateVirtualDirectoryW(
         lpPathName: PWideChar;
         lpSecurityAttributes: PSecurityAttributes): BOOL; stdcall;{$IFNDEF BOXEDAPP_SDK_USE_DLL}external;{$ENDIF}


function BoxedAppSDK_CreateVirtualFileBasedOnIStream(
         lpFileName: PAnsiChar;
         dwDesiredAccess, dwShareMode: Integer;
         lpSecurityAttributes: PSecurityAttributes;
         dwCreationDisposition, dwFlagsAndAttributes: DWORD;
         hTemplateFile: THandle;
         pStream: IStream): THandle; stdcall;{$IFNDEF BOXEDAPP_SDK_USE_DLL}external;{$ENDIF}

function BoxedAppSDK_CreateVirtualFileBasedOnIStreamA(
         lpFileName: PAnsiChar;
         dwDesiredAccess, dwShareMode: Integer;
         lpSecurityAttributes: PSecurityAttributes;
         dwCreationDisposition, dwFlagsAndAttributes: DWORD;
         hTemplateFile: THandle;
         pStream: IStream): THandle; stdcall;{$IFNDEF BOXEDAPP_SDK_USE_DLL}external;{$ENDIF}

function BoxedAppSDK_CreateVirtualFileBasedOnIStreamW(
         lpFileName: PWideChar;
         dwDesiredAccess, dwShareMode: Integer;
         lpSecurityAttributes: PSecurityAttributes;
         dwCreationDisposition, dwFlagsAndAttributes: DWORD;
         hTemplateFile: THandle;
         pStream: IStream): THandle; stdcall;{$IFNDEF BOXEDAPP_SDK_USE_DLL}external;{$ENDIF}

function BoxedAppSDK_CreateVirtualRegKey(
         hKey: HKEY;
         lpSubKey: PAnsiChar;
         Reserved: DWORD;
         lpClass: PAnsiChar;
         dwOptions: DWORD;
         samDesired: REGSAM;
         lpSecurityAttributes: PSecurityAttributes;
         var phkResult: HKEY;
         lpdwDisposition: PDWORD): Longint; stdcall;{$IFNDEF BOXEDAPP_SDK_USE_DLL}external;{$ENDIF}

function BoxedAppSDK_CreateVirtualRegKeyA(
         hKey: HKEY;
         lpSubKey: PAnsiChar;
         Reserved: DWORD;
         lpClass: PAnsiChar;
         dwOptions: DWORD;
         samDesired: REGSAM;
         lpSecurityAttributes: PSecurityAttributes;
         var phkResult: HKEY;
         lpdwDisposition: PDWORD): Longint; stdcall;{$IFNDEF BOXEDAPP_SDK_USE_DLL}external;{$ENDIF}

function BoxedAppSDK_CreateVirtualRegKeyW(
         hKey: HKEY;
         lpSubKey: PWideChar;
         Reserved: DWORD;
         lpClass: PWideChar;
         dwOptions: DWORD;
         samDesired: REGSAM;
         lpSecurityAttributes: PSecurityAttributes;
         var phkResult: HKEY;
         lpdwDisposition: PDWORD): Longint; stdcall;{$IFNDEF BOXEDAPP_SDK_USE_DLL}external;{$ENDIF}

function BoxedAppSDK_RegisterCOMLibraryInVirtualRegistry(szVirtualFilePath: PAnsiChar): Longint; stdcall;{$IFNDEF BOXEDAPP_SDK_USE_DLL}external;{$ENDIF}
function BoxedAppSDK_RegisterCOMLibraryInVirtualRegistryA(szVirtualFilePath: PAnsiChar): Longint; stdcall;{$IFNDEF BOXEDAPP_SDK_USE_DLL}external;{$ENDIF}
function BoxedAppSDK_RegisterCOMLibraryInVirtualRegistryW(szVirtualFilePath: PWideChar): Longint; stdcall;{$IFNDEF BOXEDAPP_SDK_USE_DLL}external;{$ENDIF}

function BoxedAppSDK_SetContext(szContext: PAnsiChar): Longint; stdcall;{$IFNDEF BOXEDAPP_SDK_USE_DLL}external;{$ENDIF}

function BoxedAppSDK_AddHandler(pHandler: TBoxedAppHandler; Param: Pointer): DWORD; stdcall;{$IFNDEF BOXEDAPP_SDK_USE_DLL}external;{$ENDIF}
function BoxedAppSDK_RemoveHandler(dwHandlerId: DWORD): DWORD; stdcall;{$IFNDEF BOXEDAPP_SDK_USE_DLL}external;{$ENDIF}

function BoxedAppSDK_Alloc(dwSize: DWORD): Pointer; stdcall;{$IFNDEF BOXEDAPP_SDK_USE_DLL}external;{$ENDIF}
function BoxedAppSDK_Free(pData: Pointer): DWORD; stdcall;{$IFNDEF BOXEDAPP_SDK_USE_DLL}external;{$ENDIF}

procedure BoxedAppSDK_EnableOption(dwOptionIndex: DWORD; bEnable: BOOL); stdcall;{$IFNDEF BOXEDAPP_SDK_USE_DLL}external;{$ENDIF}
function BoxedAppSDK_IsOptionEnabled(dwOptionIndex: DWORD): BOOL; stdcall;{$IFNDEF BOXEDAPP_SDK_USE_DLL}external;{$ENDIF}

function BoxedAppSDK_DeleteFileFromVirtualFileSystem(szPath: PAnsiChar): Longint; stdcall;{$IFNDEF BOXEDAPP_SDK_USE_DLL}external;{$ENDIF}
function BoxedAppSDK_DeleteFileFromVirtualFileSystemA(szPath: PAnsiChar): Longint; stdcall;{$IFNDEF BOXEDAPP_SDK_USE_DLL}external;{$ENDIF}
function BoxedAppSDK_DeleteFileFromVirtualFileSystemW(szPath: PWideChar): Longint; stdcall;{$IFNDEF BOXEDAPP_SDK_USE_DLL}external;{$ENDIF}

function BoxedAppSDK_CreateProcessFromMemoryA(
	pBuffer: Pointer;
	dwSize: DWORD;

	lpApplicationName: PAnsiChar; 
	lpCommandLine: PAnsiChar;
	lpProcessAttributes, lpThreadAttributes: PSecurityAttributes;
	bInheritHandles: BOOL; 
	dwCreationFlags: DWORD; 
	lpEnvironment: Pointer;
	lpCurrentDirectory: PAnsiChar; 
	const lpStartupInfo: TStartupInfo;
	var lpProcessInformation: TProcessInformation): BOOL; stdcall;{$IFNDEF BOXEDAPP_SDK_USE_DLL}external;{$ENDIF}
function BoxedAppSDK_CreateProcessFromMemoryW(
	pBuffer: Pointer;
	dwSize: DWORD;

	lpApplicationName: PWideChar; 
	lpCommandLine: PWideChar;
	lpProcessAttributes, lpThreadAttributes: PSecurityAttributes;
	bInheritHandles: BOOL; 
	dwCreationFlags: DWORD; 
	lpEnvironment: Pointer;
	lpCurrentDirectory: PWideChar; 
	const lpStartupInfo: TStartupInfo;
	var lpProcessInformation: TProcessInformation): BOOL; stdcall;{$IFNDEF BOXEDAPP_SDK_USE_DLL}external;{$ENDIF}
function BoxedAppSDK_CreateProcessFromMemory(
	pBuffer: Pointer;
	dwSize: DWORD;

	lpApplicationName: PAnsiChar; 
	lpCommandLine: PAnsiChar;
	lpProcessAttributes, lpThreadAttributes: PSecurityAttributes;
	bInheritHandles: BOOL; 
	dwCreationFlags: DWORD; 
	lpEnvironment: Pointer;
	lpCurrentDirectory: PAnsiChar; 
	const lpStartupInfo: TStartupInfo;
	var lpProcessInformation: TProcessInformation): BOOL; stdcall;{$IFNDEF BOXEDAPP_SDK_USE_DLL}external;{$ENDIF}

function BoxedAppSDK_AttachToProcess(hProcess: THandle): BOOL; stdcall;{$IFNDEF BOXEDAPP_SDK_USE_DLL}external;{$ENDIF}
function BoxedAppSDK_DetachFromProcess(hProcess: THandle): BOOL; stdcall;{$IFNDEF BOXEDAPP_SDK_USE_DLL}external;{$ENDIF}

// Internal; don't use
function BoxedAppSDK_GetInternalValue(nValueId: DWORD; buf: Pointer; dwSize: DWORD): DWORD; stdcall;{$IFNDEF BOXEDAPP_SDK_USE_DLL}external;{$ENDIF}

function BoxedAppSDK_ExecuteDotNetApplication(szPath: PAnsiChar; szArgs: PAnsiChar): DWORD; stdcall;{$IFNDEF BOXEDAPP_SDK_USE_DLL}external;{$ENDIF}
function BoxedAppSDK_ExecuteDotNetApplicationA(szPath: PAnsiChar; szArgs: PAnsiChar): DWORD; stdcall;{$IFNDEF BOXEDAPP_SDK_USE_DLL}external;{$ENDIF}
function BoxedAppSDK_ExecuteDotNetApplicationW(szPath: PWideChar; szArgs: PWideChar): DWORD; stdcall;{$IFNDEF BOXEDAPP_SDK_USE_DLL}external;{$ENDIF}

function BoxedAppSDK_HookFunction(pFunction: Pointer; pHook: Pointer; bEnable: BOOL): THandle; stdcall;{$IFNDEF BOXEDAPP_SDK_USE_DLL}external;{$ENDIF}
function BoxedAppSDK_GetOriginalFunction(hHook: THandle): Pointer; stdcall;{$IFNDEF BOXEDAPP_SDK_USE_DLL}external;{$ENDIF}
function BoxedAppSDK_EnableHook(hHook: THandle; bEnable: BOOL): BOOL; stdcall;{$IFNDEF BOXEDAPP_SDK_USE_DLL}external;{$ENDIF}
function BoxedAppSDK_UnhookFunction(hHook: THandle): BOOL; stdcall;{$IFNDEF BOXEDAPP_SDK_USE_DLL}external;{$ENDIF}

function BoxedAppSDK_RemoteProcess_LoadLibrary(dwProcessId: DWORD; szPath: PAnsiChar): HMODULE; stdcall;{$IFNDEF BOXEDAPP_SDK_USE_DLL}external;{$ENDIF}
function BoxedAppSDK_RemoteProcess_LoadLibraryA(dwProcessId: DWORD; szPath: PAnsiChar): HMODULE; stdcall;{$IFNDEF BOXEDAPP_SDK_USE_DLL}external;{$ENDIF}
function BoxedAppSDK_RemoteProcess_LoadLibraryW(dwProcessId: DWORD; szPath: PWideChar): HMODULE; stdcall;{$IFNDEF BOXEDAPP_SDK_USE_DLL}external;{$ENDIF}

function BoxedAppSDK_EnumVirtualRegKeys(pEnumFunc: TBoxedAppSDK_EnumVirtualRegKeysCallback; lParam: Cardinal): Boolean; stdcall;{$IFNDEF BOXEDAPP_SDK_USE_DLL}external;{$ENDIF}
function BoxedAppSDK_EnumVirtualRegKeysA(pEnumFunc: TBoxedAppSDK_EnumVirtualRegKeysCallbackA; lParam: Cardinal): Boolean; stdcall;{$IFNDEF BOXEDAPP_SDK_USE_DLL}external;{$ENDIF}
function BoxedAppSDK_EnumVirtualRegKeysW(pEnumFunc: TBoxedAppSDK_EnumVirtualRegKeysCallbackW; lParam: Cardinal): Boolean; stdcall;{$IFNDEF BOXEDAPP_SDK_USE_DLL}external;{$ENDIF}

implementation

{$IFDEF BOXEDAPP_SDK_USE_DLL}

function BoxedAppSDK_Init; external 'BoxedAppSDK.dll';
function BoxedAppSDK_Exit; external 'BoxedAppSDK.dll';

procedure BoxedAppSDK_EnableDebugLog; external 'BoxedAppSDK.dll';

procedure BoxedAppSDK_SetLogFile; external 'BoxedAppSDK.dll' name 'BoxedAppSDK_SetLogFileA';
procedure BoxedAppSDK_SetLogFileA; external 'BoxedAppSDK.dll' name 'BoxedAppSDK_SetLogFileA';
procedure BoxedAppSDK_SetLogFileW; external 'BoxedAppSDK.dll' name 'BoxedAppSDK_SetLogFileW';

function BoxedAppSDK_CreateVirtualFile; external 'BoxedAppSDK.dll' name 'BoxedAppSDK_CreateVirtualFileA';
function BoxedAppSDK_CreateVirtualFileA; external 'BoxedAppSDK.dll' name 'BoxedAppSDK_CreateVirtualFileA';
function BoxedAppSDK_CreateVirtualFileW; external 'BoxedAppSDK.dll' name 'BoxedAppSDK_CreateVirtualFileW';

function BoxedAppSDK_CreateVirtualDirectory; external 'BoxedAppSDK.dll' name 'BoxedAppSDK_CreateVirtualDirectoryA';
function BoxedAppSDK_CreateVirtualDirectoryA; external 'BoxedAppSDK.dll' name 'BoxedAppSDK_CreateVirtualDirectoryA';
function BoxedAppSDK_CreateVirtualDirectoryW; external 'BoxedAppSDK.dll' name 'BoxedAppSDK_CreateVirtualDirectoryW';

function BoxedAppSDK_CreateVirtualFileBasedOnIStream; external 'BoxedAppSDK.dll' name 'BoxedAppSDK_CreateVirtualFileBasedOnIStreamA';
function BoxedAppSDK_CreateVirtualFileBasedOnIStreamA; external 'BoxedAppSDK.dll' name 'BoxedAppSDK_CreateVirtualFileBasedOnIStreamA';
function BoxedAppSDK_CreateVirtualFileBasedOnIStreamW; external 'BoxedAppSDK.dll' name 'BoxedAppSDK_CreateVirtualFileBasedOnIStreamW';

function BoxedAppSDK_CreateVirtualRegKey; external 'BoxedAppSDK.dll' name 'BoxedAppSDK_CreateVirtualRegKeyA';
function BoxedAppSDK_CreateVirtualRegKeyA; external 'BoxedAppSDK.dll' name 'BoxedAppSDK_CreateVirtualRegKeyA';
function BoxedAppSDK_CreateVirtualRegKeyW; external 'BoxedAppSDK.dll' name 'BoxedAppSDK_CreateVirtualRegKeyW';

function BoxedAppSDK_RegisterCOMLibraryInVirtualRegistry; external 'BoxedAppSDK.dll' name 'BoxedAppSDK_RegisterCOMLibraryInVirtualRegistryA';
function BoxedAppSDK_RegisterCOMLibraryInVirtualRegistryA; external 'BoxedAppSDK.dll' name 'BoxedAppSDK_RegisterCOMLibraryInVirtualRegistryA';
function BoxedAppSDK_RegisterCOMLibraryInVirtualRegistryW; external 'BoxedAppSDK.dll' name 'BoxedAppSDK_RegisterCOMLibraryInVirtualRegistryW';

function BoxedAppSDK_SetContext; external 'BoxedAppSDK.dll' name 'BoxedAppSDK_SetContext';

function BoxedAppSDK_AddHandler; external 'BoxedAppSDK.dll';
function BoxedAppSDK_RemoveHandler; external 'BoxedAppSDK.dll';

function BoxedAppSDK_Alloc; external 'BoxedAppSDK.dll';
function BoxedAppSDK_Free; external 'BoxedAppSDK.dll';

procedure BoxedAppSDK_EnableOption; external 'BoxedAppSDK.dll';
function BoxedAppSDK_IsOptionEnabled; external 'BoxedAppSDK.dll';

function BoxedAppSDK_DeleteFileFromVirtualFileSystem; external 'BoxedAppSDK.dll' name 'BoxedAppSDK_DeleteFileFromVirtualFileSystemA';
function BoxedAppSDK_DeleteFileFromVirtualFileSystemA; external 'BoxedAppSDK.dll' name 'BoxedAppSDK_DeleteFileFromVirtualFileSystemA';
function BoxedAppSDK_DeleteFileFromVirtualFileSystemW; external 'BoxedAppSDK.dll' name 'BoxedAppSDK_DeleteFileFromVirtualFileSystemW';

function BoxedAppSDK_CreateProcessFromMemoryA; external 'BoxedAppSDK.dll' name 'BoxedAppSDK_CreateProcessFromMemoryA';
function BoxedAppSDK_CreateProcessFromMemoryW; external 'BoxedAppSDK.dll' name 'BoxedAppSDK_CreateProcessFromMemoryW';
function BoxedAppSDK_CreateProcessFromMemory; external 'BoxedAppSDK.dll' name 'BoxedAppSDK_CreateProcessFromMemory';

function BoxedAppSDK_AttachToProcess; external 'BoxedAppSDK.dll' name 'BoxedAppSDK_AttachToProcess';
function BoxedAppSDK_DetachFromProcess; external 'BoxedAppSDK.dll' name 'BoxedAppSDK_DetachFromProcess';

function BoxedAppSDK_GetInternalValue; external 'BoxedAppSDK.dll' name 'BoxedAppSDK_GetInternalValue';

function BoxedAppSDK_ExecuteDotNetApplication; external 'BoxedAppSDK.dll' name 'BoxedAppSDK_ExecuteDotNetApplicationA';
function BoxedAppSDK_ExecuteDotNetApplicationA; external 'BoxedAppSDK.dll' name 'BoxedAppSDK_ExecuteDotNetApplicationA';
function BoxedAppSDK_ExecuteDotNetApplicationW; external 'BoxedAppSDK.dll' name 'BoxedAppSDK_ExecuteDotNetApplicationW';

function BoxedAppSDK_HookFunction; external 'BoxedAppSDK.dll' name 'BoxedAppSDK_HookFunction';
function BoxedAppSDK_GetOriginalFunction; external 'BoxedAppSDK.dll' name 'BoxedAppSDK_GetOriginalFunction';
function BoxedAppSDK_EnableHook; external 'BoxedAppSDK.dll' name 'BoxedAppSDK_EnableHook';
function BoxedAppSDK_UnhookFunction; external 'BoxedAppSDK.dll' name 'BoxedAppSDK_UnhookFunction';

function BoxedAppSDK_RemoteProcess_LoadLibrary; external 'BoxedAppSDK.dll' name 'BoxedAppSDK_RemoteProcess_LoadLibraryA';
function BoxedAppSDK_RemoteProcess_LoadLibraryA; external 'BoxedAppSDK.dll' name 'BoxedAppSDK_RemoteProcess_LoadLibraryA';
function BoxedAppSDK_RemoteProcess_LoadLibraryW; external 'BoxedAppSDK.dll' name 'BoxedAppSDK_RemoteProcess_LoadLibraryW';

function BoxedAppSDK_EnumVirtualRegKeys; external 'BoxedAppSDK.dll' name 'BoxedAppSDK_EnumVirtualRegKeysA';
function BoxedAppSDK_EnumVirtualRegKeysA; external 'BoxedAppSDK.dll' name 'BoxedAppSDK_EnumVirtualRegKeysA';
function BoxedAppSDK_EnumVirtualRegKeysW; external 'BoxedAppSDK.dll' name 'BoxedAppSDK_EnumVirtualRegKeysW';

{$ENDIF}

end.
