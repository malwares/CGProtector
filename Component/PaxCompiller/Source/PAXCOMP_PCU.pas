///////////////////////////////////////////////////////////////////////////
// PaxCompiler
// Site: http://www.paxcompiler.com
// Author: Alexander Baranovsky (paxscript@gmail.com)
// ========================================================================
// Copyright (c) Alexander Baranovsky, 2006-2008. All rights reserved.
// Code Version: 2.4
// ========================================================================
// Unit: PAXCOMP_PCU.pas
// ========================================================================
////////////////////////////////////////////////////////////////////////////

{$I PaxCompiler.def}
unit PAXCOMP_PCU;
interface
uses
  SysUtils,
  Classes,
  PAXCOMP_CONSTANTS,
  PAXCOMP_SYS,
  PAXCOMP_MODULE,
  PAXCOMP_PARSER,
  PAXCOMP_KERNEL;

function CompileUnit(Owner: Pointer;
                     const UnitName, FileName, PCUName: String;
                     Parser: TBaseParser;
                     BuildAll: Boolean;
                     OutputStream: TStream): Boolean;

implementation

uses
  PAXCOMP_BASESYMBOL_TABLE,
  PAXCOMP_SYMBOL_TABLE,
  PAXCOMP_SYMBOL_REC,
  PaxCompiler, PaxProgram;

procedure CopyLocalImport(RootST, ST: TSymbolTable);
var
  I: Integer;
  R1, R2: TSymbolRec;
  S: TMemoryStream;
  Writer: TWriter;
  Reader: TReader;
begin
  for I := FirstLocalId + 1 to RootST.CompileCard do
  begin
    S := TMemoryStream.Create;
    try
      Writer := TWriter.Create(S, 1024);
      try
        R1 := RootST[I];
        R1.SaveToStream(Writer);
      finally
        Writer.Free;
      end;

      S.Seek(0, soFromBeginning);
      Reader := TReader.Create(S, 1024);

      try
        R2 := ST.AddRecord;
        R2.LoadFromStream(Reader);
      finally
        Reader.Free;
      end;

      R2.Address := R1.Address;
      R2.PClass  := R1.PClass;

    finally
      S.Free;
    end;
  end;
end;

function CompileUnit(Owner: Pointer;
                     const UnitName, FileName, PCUName: String;
                     Parser: TBaseParser;
                     BuildAll: Boolean;
                     OutputStream: TStream): Boolean;

var
  PaxCompiler1: TPaxCompiler;
  PaxProgram1: TPaxProgram;
  UnitParser: TBaseParser;
  C: TBaseParserClass;
  RootKernel: TKernel;
  CodeLines: String;
  I: Integer;
begin
  RootKernel := TKernel(Owner).RootKernel;
  CodeLines := '';

  if Assigned(RootKernel.OnUsedUnit) then
    if RootKernel.Modules.IndexOf(UnitName) = -1 then
      if not RootKernel.OnUsedUnit(RootKernel.Owner, UnitName, CodeLines) then
        CodeLines := '';

  if CodeLines = '' then
    if not FileExists(FileName) then
    begin
      I := RootKernel.Modules.IndexOf(UnitName);
      if I >= 0 then
      begin
        CodeLines := RootKernel.Modules[I].Lines.Text;
      end
      else
      begin
        result := FileExists(PCUName);
        Exit;
      end;
    end;

  PaxCompiler1 := TPaxCompiler.Create(nil);
  CopyLocalImport(RootKernel.SymbolTable,
    TKernel(PaxCompiler1.GetKernelPtr).SymbolTable);

  PaxProgram1 := TPaxProgram.Create(nil);

  C := TBaseParserClass(Parser.ClassType);
  UnitParser := C.Create;

  TKernel(PaxCompiler1.GetKernelPtr).PCUOwner := Owner;

  TKernel(PaxCompiler1.GetKernelPtr).CopyRootEvents;

  try
    TKernel(PaxCompiler1.GetKernelPtr).RegisterParser(UnitParser);
    PaxCompiler1.AddModule(UnitName, UnitParser.LanguageName);

    if CodeLines = '' then
      PaxCompiler1.AddCodeFromFile(UnitName, FileName)
    else
      PaxCompiler1.AddCode(UnitName, CodeLines);

    if PaxCompiler1.Compile(PaxProgram1, BuildAll) then
    begin
      if Assigned(OutputStream) then
        PaxProgram1.SaveToStream(OutputStream)
      else
        PaxProgram1.SaveToFile(PCUName);
      result := true;

      RootKernel.BuildedUnits.Add(UpperCase(PCUName));
    end
    else
    begin
      result := false;
      RootKernel.CreateError(PaxCompiler1.ErrorMessage[0], []);
    end;
  finally
    UnitParser.Free;
    PaxCompiler1.Free;
    PaxProgram1.Free;
  end;
end;

end.

