////////////////////////////////////////////////////////////////////////////
// PaxCompiler
// Site: http://www.paxcompiler.com
// Author: Alexander Baranovsky (paxscript@gmail.com)
// ========================================================================
// Copyright (c) Alexander Baranovsky, 2006-2008. All rights reserved.
// Code Version: 2.4
// ========================================================================
// Unit: PAXCOMP_HOSTCLS.pas
// ========================================================================
////////////////////////////////////////////////////////////////////////////
{$I PaxCompiler.def}
unit PAXCOMP_HOSTCLS;
interface
uses
{$IFNDEF LINUX}
  Windows,
{$ENDIF}
  SysUtils,
  Classes,
  PAXCOMP_SYS;

procedure RegisterUsedClasses;

implementation

{$IFNDEF LINUX}

{$IFDEF FPC}
procedure SearchClasses(AnInstance: Cardinal; UsedClasses: TList);
begin
end;
{$ELSE}

procedure SearchClasses(AnInstance: Cardinal; UsedClasses: TList);
type
   PPointer = ^Pointer;

   PIMAGE_DOS_HEADER = ^IMAGE_DOS_HEADER;
   IMAGE_DOS_HEADER = packed record { DOS .EXE header }
      e_magic : WORD; { Magic number }
      e_cblp : WORD; { Bytes on last page of file }
      e_cp : WORD; { Pages in file }
      e_crlc : WORD; { Relocations }
      e_cparhdr : WORD; { Size of header in paragraphs }
      e_minalloc : WORD; { Minimum extra paragraphs needed }
      e_maxalloc : WORD; { Maximum extra paragraphs needed }
      e_ss : WORD; { Initial (relative) SS value }
      e_sp : WORD; { Initial SP value }
      e_csum : WORD; { Checksum }
      e_ip : WORD; { Initial IP value }
      e_cs : WORD; { Initial (relative) CS value }
      e_lfarlc : WORD; { File address of relocation table }
      e_ovno : WORD; { Overlay number }
      e_res : packed array [0..3] of WORD; { Reserved words }
      e_oemid : WORD; { OEM identifier (for e_oeminfo) }
      e_oeminfo : WORD; { OEM information; e_oemid specific }
      e_res2 : packed array [0..9] of WORD; { Reserved words }
      e_lfanew : LongWord; { File address of new exe header }
   end;

   PIMAGE_NT_HEADERS = ^IMAGE_NT_HEADERS;
   IMAGE_NT_HEADERS = packed record
      Signature : DWORD;
      FileHeader : IMAGE_FILE_HEADER;
      OptionalHeader : IMAGE_OPTIONAL_HEADER;
   end;

   PIMAGE_SECTION_HEADER = ^IMAGE_SECTION_HEADER;
   IMAGE_SECTION_HEADER = packed record
      Name : packed array [0..IMAGE_SIZEOF_SHORT_NAME-1] of Char;
      VirtualSize : DWORD; // or VirtualSize (union);
      VirtualAddress : DWORD;
      SizeOfRawData : DWORD;
      PointerToRawData : DWORD;
      PointerToRelocations : DWORD;
      PointerToLinenumbers : DWORD;
      NumberOfRelocations : WORD;
      NumberOfLinenumbers : WORD;
      Characteristics : DWORD;
   end;

var
   DosHeader: PIMAGE_DOS_HEADER;
   NTHeader: PIMAGE_NT_HEADERS;
   SectionHeader: PIMAGE_SECTION_HEADER;
   pCodeBegin,
   pCodeEnd: PChar;
   pCode,
   p: PChar;

   function GetSectionHeader(const ASectionName: string): Boolean;
   var
      i: Integer;
   begin
      SectionHeader := PIMAGE_SECTION_HEADER(NTHeader);
      Inc(PIMAGE_NT_HEADERS(SectionHeader));
      Result := True;
      for i := 0 to NTHeader.FileHeader.NumberOfSections - 1 do
      begin
         if Strlicomp(SectionHeader.Name, PChar(ASectionName),
               IMAGE_SIZEOF_SHORT_NAME) = 0 then
            Exit;
         Inc(SectionHeader);
      end;
      Result := False;
   end;

   function InRangeOrNil(APointer, pMin, pMax: Pointer): Boolean;
   begin
     if (APointer = nil) or
        ((Integer(APointer) >= Integer(pMin))
          and (Integer(APointer) <= Integer(pMax))) then
          result := true
     else
       result := false;
   end;

   function IsIdent(p: PChar): Boolean;
   var
      lg,
      i: Integer;
   begin
      lg := ord(p^);
      Inc(p);
      Result := (lg > 0) and (p^ in ['A'..'Z', 'a'..'z', '_']);
      if not Result then
         Exit;
      for i := 2 to lg do
      begin
         inc(p);
         if not (p^ in ['0'..'9', 'A'..'Z', 'a'..'z', '_']) then
         begin
            Result := False;
            Exit;
         end;
      end;
   end;

   begin
   { Read the DOS header }
   DosHeader := PIMAGE_DOS_HEADER(AnInstance);
   if not DosHeader.e_magic = IMAGE_DOS_SIGNATURE then // POUnrecognizedFileFormat;
   begin
      ErrMessageBox('No IMAGE_DOS_SIGNATURE');
      Exit;
   end;
   { Read the NT header (PE format) }
   //NTHeader := PIMAGE_NT_HEADERS(Longint(DosHeader) + DosHeader.e_lfanew);
   NTHeader := PIMAGE_NT_HEADERS(LongWord(DosHeader) + DosHeader.e_lfanew);
   if IsBadReadPtr(NTHeader, SizeOf(IMAGE_NT_HEADERS)) or
      (NTHeader.Signature <> IMAGE_NT_SIGNATURE) then // PONotAPEFile
      Exit;
   { Find the code section }
//   if not GetSectionHeader('CODE') then // PONoInitializedData;
//      Exit;
   { Computes beginning & end of the code section }
   pCodeBegin := PChar(AnInstance + SectionHeader.VirtualAddress);
   pCodeEnd := pCodeBegin + (SectionHeader.SizeOfRawData - 3);
   pCode := pCodeBegin;
   while pCode < pCodeEnd do
   begin
      p := PPointer(pCode)^;
      { Search for a class }
      if (p = (pCode - vmtSelfPtr)) and // Is it SelfPtr pointer?
         InRangeOrNil(PPointer(p+vmtClassName)^, p, pCodeEnd) and
         InRangeOrNil(PPointer(p+vmtDynamicTable)^, p, pCodeEnd) and
         InRangeOrNil(PPointer(p+vmtMethodTable)^, p, pCodeEnd) and
         InRangeOrNil(PPointer(p+vmtFieldTable)^, p, pCodeEnd) and
         InRangeOrNil(PPointer(p+vmtTypeInfo)^, pCodeBegin, pCodeEnd) and
         InRangeOrNil(PPointer(p+vmtInitTable)^, pCodeBegin, pCodeEnd) and
         InRangeOrNil(PPointer(p+vmtAutoTable)^, pCodeBegin, pCodeEnd) and
         InRangeOrNil(PPointer(p+vmtIntfTable)^, pCodeBegin, pCodeEnd) and
         IsIdent(PPointer(p+vmtClassName)^) then
      begin
        if UsedClasses.IndexOf(p) = -1 then
          UsedClasses.Add(TClass(p));
        Inc(pCode, 4);
      end
      else
         Inc(pCode);
  end;
end;

{$ENDIF}

function EnumModulesFunc(HInstance: Integer; Data: Pointer): Boolean;
begin
  result := true;
  TList(Data).Add(Pointer(HInstance));
end;

procedure RegisterUsedClasses;
var
  I: Integer;
  AClass: TClass;
  UsedClasses, UsedModules: TList;
begin
  UsedModules := TList.Create;
{$IFNDEF FPC}
  EnumModules(EnumModulesFunc, UsedModules);
{$ENDIF}

  UsedClasses := TList.Create;
  for I:=0 to UsedModules.Count - 1 do
    SearchClasses(Cardinal(UsedModules[I]), UsedClasses);

  for I:=0 to UsedClasses.Count - 1 do
  begin
    AClass := TClass(UsedClasses[I]);
    if AClass.InheritsFrom(TPersistent) then
    begin
      if GetClass(AClass.ClassName) = nil then
      begin
        try
          Classes.RegisterClass(TPersistentClass(AClass));
        except
        end;
      end;
    end;
  end;

  UsedClasses.Free;
  UsedModules.Free;
end;

{$ELSE}

procedure RegisterUsedClasses;
begin
end;

{$ENDIF}

end.
