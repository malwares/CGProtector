{********************************************************************
TSECTIONLISTBOX design time property editor
for Delphi 2.0,3.0,4.0,5.0 & C++Builder 1.0,3.0,4.0,5.0
version 1.8, May 2000

Copyright © 1998-2000
  TMS Software
  Email : info@tmssoftware.com
  Web : http://www.tmssoftware.com

The source code is given as is. The author is not responsible
for any possible damage done due to the use of this code.
The component can be freely used in any application. The complete
source code remains property of the author and may not be distributed,
published, given or sold in any form as such. No parts of the source
code can be included in any other component or application without
written authorization of the author.
********************************************************************}


unit slstde;

interface
{$I TMSDEFS.INC}
uses
  SlstBox,
{$IFDEF DELPHI6_LVL}
  {$IFNDEF TMSDOTNET}
  DesignIntf, DesignEditors
  {$ENDIF}
  {$IFDEF TMSDOTNET}
  Borland.Vcl.Design.DesignIntf, Borland.Vcl.Design.DesignEditors
  {$ENDIF}

{$ELSE}
  DsgnIntf
{$ENDIF}
  ;


type 
 {---------------------------------------------------}
 { Section property editor class : not used yet      }
 {---------------------------------------------------}
  TSectionListBoxEditor = class(TDefaultEditor)
                      protected
                        {$IFNDEF DELPHI6_LVL}
                        procedure EditProperty(PropertyEditor: TPropertyEditor;
                                               var Continue, FreeEditor: Boolean); override;
                        {$ELSE}
                        procedure EditProperty(const PropertyEditor: IProperty; var Continue: Boolean); override;
                        {$ENDIF}
                      public
                        function GetVerb(index:integer):string; override;
                        function GetVerbCount:integer; override;
                        procedure ExecuteVerb(Index:integer); override;
                      end;


implementation

uses
 sysutils,dialogs;

procedure TSectionListBoxEditor.ExecuteVerb(Index: integer);
var
 compiler:string;
begin
 case Index of
 0: Edit;
 1: (Component as TSectionListBox).ExpandAll;
 2: (Component as TSectionListBox).ContractAll;
 3: begin
   {$IFDEF VER90}
   compiler:='Delphi 2';
   {$ENDIF}
   {$IFDEF VER93}
   compiler:='C++Builder 1';
   {$ENDIF}
   {$IFDEF VER100}
   compiler:='Delphi 3';
   {$ENDIF}
   {$IFDEF VER110}
   compiler:='C++Builder 3';
   {$ENDIF}
   {$IFDEF VER120}
   compiler:='Delphi 4';
   {$ENDIF}
   {$IFDEF VER125}
   compiler:='C++Builder 4';
   {$ENDIF}
   {$IFDEF VER130}
   {$IFDEF BCB}
   compiler:='C++Builder 5';
   {$ELSE}
   compiler:='Delphi 5';
   {$ENDIF}
   {$ENDIF}
   {$IFDEF VER140}
   compiler:='Delphi 6';
   {$ENDIF}
   messagedlg(component.className+' version 1.8 for '+compiler+#13#10#13#10'© 1999-2000 by TMS software'#13#10'http://www.tmssoftware.com',
              mtinformation,[mbok],0);
   end;

 end;
end;

{$IFDEF DELPHI6_LVL}
procedure TSectionListBoxEditor.EditProperty(const PropertyEditor: IProperty; var Continue: Boolean);
{$ELSE}
procedure TSectionListBoxEditor.EditProperty(PropertyEditor: TPropertyEditor;
  var Continue, FreeEditor: Boolean);
{$ENDIF}
var
  PropName: string;
begin
  PropName := PropertyEditor.GetName;
  if (CompareText(PropName, 'SECTIONS') = 0) then
    begin
      PropertyEditor.Edit;
      Continue := False;
    end;
end;


function TSectionListBoxEditor.GetVerb(index: integer): string;
begin
 result:='';
 case index of
 0:result:='Section Editor';
 1:result:='Expand all';
 2:result:='Contract all';
 3:result:='About';
 end;
end;

function TSectionListBoxEditor.GetVerbCount: integer;
begin
 result:=4;
end;


end.
