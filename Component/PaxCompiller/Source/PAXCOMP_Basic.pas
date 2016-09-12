////////////////////////////////////////////////////////////////////////////
// PaxCompiler
// Site: http://www.paxcompiler.com
// Author: Alexander Baranovsky (paxscript@gmail.com)
// ========================================================================
// Copyright (c) Alexander Baranovsky, 2006-2007. All rights reserved.
// Code Version: 2.4
// ========================================================================
// Unit: PAXCOMP_Basic.pas
// ========================================================================
////////////////////////////////////////////////////////////////////////////

{$I PaxCompiler.def}
{$O-}
{$Q-}
{$B-}
{$R-}
unit PAXCOMP_Basic;
interface

uses
{$IFDEF VARIANTS}
  Variants,
{$ENDIF}
{$IFNDEF LINUX}
  Windows,
{$ENDIF}
  SysUtils,
  Classes,
  Math,
  PAXCOMP_CONSTANTS,
  PAXCOMP_SYS,
  PAXCOMP_STDLIB,
  PAXCOMP_PROG,
  PAXCOMP_BASESYMBOL_TABLE;

procedure Register_StdBasic;

implementation

procedure Register_StdBasic;
begin
  with GlobalSymbolTable do
  begin
  end;
end;

end.
