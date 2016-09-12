{$I TMSDEFS.INC}
{***********************************************************************}
{ TPlannerMonthView component                                           }
{ for Delphi & C++Builder                                               }
{ version 2.5                                                           }
{                                                                       }
{ written by :                                                          }
{            TMS Software                                               }
{            copyright © 2005 - 2006                                    }
{            Email : info@tmssoftware.com                               }
{            Website : http://www.tmssoftware.com                       }
{                                                                       }
{ The source code is given as is. The author is not responsible         }
{ for any possible damage done due to the use of this code.             }
{ The component can be freely used in any application. The source       }
{ code remains property of the writer and may not be distributed        }
{ freely as such.                                                       }
{***********************************************************************}

unit PlannerMonthViewRegDE;



interface

uses
  Classes, SysUtils
  , PlannerMonthView, Planner, Dialogs, Forms, PlanStyles
  {$IFNDEF TMSDOTNET}
   , AdvImage, AdvImgDe
  {$ENDIF}

{$IFDEF DELPHI6_LVL}
  {$IFNDEF TMSDOTNET}
  , DesignIntf, DesignEditors
  {$ENDIF}
  {$IFDEF TMSDOTNET}
  , Borland.Vcl.Design.DesignIntf, Borland.Vcl.Design.DesignEditors
  {$ENDIF}

{$ELSE}
  , DsgnIntf
{$ENDIF}
  ;

type
  TPlannerMonthViewEditor = class(TDefaultEditor)
  protected
  {$IFNDEF DELPHI6_LVL}
    procedure EditProperty(PropertyEditor: TPropertyEditor;
                           var Continue, FreeEditor: Boolean); override;
  {$ELSE}
    procedure EditProperty(const PropertyEditor:IProperty; var Continue:Boolean); override;
  {$ENDIF}
  public
    function GetVerb(index:integer):string; override;
    function GetVerbCount:integer; override;
    procedure ExecuteVerb(Index:integer); override;
  end;

  TPMVSkinProperty = class(TClassProperty)
  public
    function GetAttributes:TPropertyAttributes; override;
    procedure Edit; override;
  end;


procedure Register;

implementation

uses
  Controls;
  
procedure Register;
begin
  {$IFNDEF TMSDOTNET}
  RegisterPropertyEditor(TypeInfo(TAdvImage), TPlannerMonthView, 'Background', TAdvImageProperty);
  {$ENDIF}
  RegisterPropertyEditor(TypeInfo(TPlannerSkin),TPlannerMonthView,'Skin',TPMVSkinProperty);
  RegisterComponentEditor(TPlannerMonthView, TPlannerMonthViewEditor);
end;


procedure TPlannerMonthViewEditor.ExecuteVerb(Index: integer);
var
  compiler:string;
  psf: TPlanStyleForm;
begin
  case Index of
  0:begin

      {$IFDEF VER90}
      compiler := 'Delphi 2';
      {$ENDIF}
      {$IFDEF VER93}
      compiler:='C++Builder 1';
      {$ENDIF}
      {$IFDEF VER100}
      compiler := 'Delphi 3';
      {$ENDIF}
      {$IFDEF VER110}
      compiler := 'C++Builder 3';
      {$ENDIF}
      {$IFDEF VER120}
      compiler := 'Delphi 4';
      {$ENDIF}
      {$IFDEF VER125}
      compiler := 'C++Builder 4';
      {$ENDIF}
      {$IFDEF VER130}
      {$IFDEF BCB}
      compiler := 'C++Builder 5';
      {$ELSE}
      compiler := 'Delphi 5';
      {$ENDIF}
      {$ENDIF}
      {$IFDEF VER140}
      {$IFDEF BCB}
      compiler := 'C++Builder 6';
      {$ELSE}
      compiler := 'Delphi 6';
      {$ENDIF}
      {$ENDIF}
      {$IFDEF VER150}
      {$IFDEF BCB}
      {$ELSE}
      compiler := 'Delphi 7';
      {$ENDIF}
      {$ENDIF}
      {$IFDEF VER160}
      {$IFDEF BCB}
      {$ELSE}
      compiler := 'Delphi 8';
      {$ENDIF}
      {$ENDIF}
      {$IFDEF VER170}
      {$IFDEF BCB}
      {$ELSE}
      compiler := 'Delphi 2005';
      {$ENDIF}
      {$ENDIF}
      {$IFDEF VER180}
      {$IFDEF BCB}
      {$ELSE}
      compiler := 'Delphi 2006';
      {$ENDIF}
      {$ENDIF}

      MessageDlg(Component.ClassName+' version '+ (Component as TPlannerMonthView).VersionString + ' for ' + compiler + #13#10#13#10'© 2004 - 2006 by TMS software'#13#10'http://www.tmssoftware.com',
                 mtInformation,[mbok],0);
    end;

  1: Edit;
  3: begin
       (Component as TPlannerMonthView).Skin.ClearSkin;
       Designer.Modified;
     end;
  2: begin
       psf := TPlanStyleForm.Create(Application);
       psf.Caption := 'PlannerMonthView Styles';
       if psf.ShowModal = mrOK then
       begin
         (Component as TPlannerMonthView).Style := TPlannerMonthViewStyle(psf.RadioGroup1.ItemIndex);
         Designer.Modified;
       end;
       psf.Free;
     end;
  end;
end;

{$IFNDEF DELPHI6_LVL}
procedure TPlannerMonthViewEditor.EditProperty(PropertyEditor: TPropertyEditor;
                                      var Continue, FreeEditor: Boolean);
{$ELSE}
procedure TPlannerMonthViewEditor.EditProperty(const PropertyEditor:IProperty;
                                      var Continue:Boolean);
{$ENDIF}
var
  PropName: string;
begin
  PropName := PropertyEditor.GetName;
  if (CompareText(PropName, 'ITEMS') = 0) then
  begin
    PropertyEditor.Edit;
    Continue := False;
  end;
end;


function TPlannerMonthViewEditor.GetVerb(Index: Integer): string;
begin
  Result := '';
  case Index of
  0:Result := 'About';
  1:Result := 'Items Editor';
  3:Result := 'Clear skin';
  2:Result := 'Styles';
  end;
end;

function TPlannerMonthViewEditor.GetVerbCount: Integer;
begin
  Result := 4;
end;

{ TSkinProperty }

procedure TPMVSkinProperty.Edit;
var
  od: TOpenDialog;
  Planner: TPlannerMonthView;
begin
  Planner := TPlannerMonthView(Getcomponent(0));

  od := TOpenDialog.Create(Application);
  od.Filter := 'Planner Skin (*.plskin)|*.plskin|All files (*.*)|*.*';

  if od.Execute then
  begin
    Planner.Skin.LoadFromFile(od.FileName);
    Modified;
  end;

  od.Free;
end;

function TPMVSkinProperty.GetAttributes: TPropertyAttributes;
begin
  Result := [paDialog];
end;



end.
