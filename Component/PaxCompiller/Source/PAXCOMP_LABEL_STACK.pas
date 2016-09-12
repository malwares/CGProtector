////////////////////////////////////////////////////////////////////////////
// PaxCompiler
// Site: http://www.paxcompiler.com
// Author: Alexander Baranovsky (paxscript@gmail.com)
// ========================================================================
// Copyright (c) Alexander Baranovsky, 2006-2008. All rights reserved.
// Code Version: 2.4
// ========================================================================
// Unit: PAXCOMP_LABEL_STACK.pas
// ========================================================================
////////////////////////////////////////////////////////////////////////////

{$I PaxCompiler.def}
unit PAXCOMP_LABEL_STACK;
interface
uses
  SysUtils,
  Classes,
  PAXCOMP_CONSTANTS,
  PAXCOMP_SYS;
type

  TEntryRec = class
  public
    IntLabel: Integer;
    StringLabel: String;
  end;

  TEntryStack = class(TTypedList)
  private
    function GetRecord(I: Integer): TEntryRec;
  public
    procedure Push(AIntLabel: Integer); overload;
    procedure Push(AIntLabel: Integer;
                   var AStringLabel: String); overload;
    procedure Pop;
    function TopLabel(const AStringLabel: String = ''): Integer;
    property Records[I: Integer]: TEntryRec read GetRecord; default;
  end;

implementation

function TEntryStack.GetRecord(I: Integer): TEntryRec;
begin
  result := TEntryRec(L[I]);
end;

procedure TEntryStack.Push(AIntLabel: Integer);
var
  R: TEntryRec;
begin
  R := TEntryRec.Create;
  R.IntLabel := AIntLabel;
  R.StringLabel := '';
  L.Add(R);
end;

procedure TEntryStack.Push(AIntLabel: Integer; var AStringLabel: String);
var
  R: TEntryRec;
begin
  R := TEntryRec.Create;
  R.IntLabel := AIntLabel;
  R.StringLabel := AStringLabel;
  L.Add(R);
  AStringLabel := '';
end;

procedure TEntryStack.Pop;
begin
  Records[Count - 1].Free;
  L.Delete(Count - 1);
end;

function TEntryStack.TopLabel(const AStringLabel: String = ''): Integer;
var
  I: Integer;
  R: TEntryRec;
begin
  if AStringLabel <> '' then
  begin
    for I:=Count - 1 downto 0 do
    begin
      R := Records[I];
      with R do
        if StringLabel = AStringLabel then
        begin
          result := IntLabel;
          Exit;
        end;
    end;
    raise Exception.Create(errLabelNotFound);
  end
  else
    result := Records[Count - 1].IntLabel;
end;

end.
