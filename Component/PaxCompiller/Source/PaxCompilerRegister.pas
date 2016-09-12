////////////////////////////////////////////////////////////////////////////
// PaxCompiler
// Site: http://www.paxcompiler.com
// Author: Alexander Baranovsky (paxscript@gmail.com)
// ========================================================================
// Copyright (c) Alexander Baranovsky, 2006-2008. All rights reserved.
// Code Version: 2.3
// ========================================================================
// Unit: PaxCompilerRegister.pas
// ========================================================================
////////////////////////////////////////////////////////////////////////////

unit PaxCompilerRegister;

interface

uses
  Classes,
  PaxCompiler,
  PaxBasicLanguage,
  PaxProgram,
  PaxCompilerDebugger,
  PaxCompilerExplorer,
  PaxInvoke;

procedure Register;

Implementation

procedure Register;
begin
  RegisterComponents('PaxCompiler',
    [TPaxCompiler,
     TPaxPascalLanguage,
     TPaxBasicLanguage,
     TPaxProgram,
     TPaxCompilerDebugger,
     TPaxCompilerExplorer,
     TPaxInvoke]);
end;

end.
