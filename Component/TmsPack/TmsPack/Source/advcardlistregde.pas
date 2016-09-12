{***************************************************************************}
{ TAdvCardList component                                                    }
{ for Delphi & C++Builder                                                   }
{                                                                           }
{ written by TMS Software                                                   }
{            copyright © 2005 - 2010                                        }
{            Email : info@tmssoftware.com                                   }
{            Web : http://www.tmssoftware.com                               }
{                                                                           }
{ The source code is given as is. The author is not responsible             }
{ for any possible damage done due to the use of this code.                 }
{ The component can be freely used in any application. The complete         }
{ source code remains property of the author and may not be distributed,    }
{ published, given or sold in any form as such. No parts of the source      }
{ code can be included in any other component or application without        }
{ written authorization of the author.                                      }
{***************************************************************************}

unit AdvCardListRegDE;

{$I TMSDEFS.INC}

interface

uses
  Classes, Controls, AdvCardList, AdvCardListGradient, Forms, Graphics

  {$IFDEF TMSDOTNET}
  , Borland.Vcl.Design.DesignIntf
  , Borland.Vcl.Design.DesignEditors
  {$ELSE}
    {$IFDEF DELPHI6_LVL}
    , DesignIntf, DesignEditors
    {$ELSE}
    , DsgnIntf
    {$ENDIF}
  {$ENDIF}
  ;

type

  TAdvCardListEditor = class(TDefaultEditor)
  protected
  {$IFNDEF DELPHI6_LVL}
    procedure EditProperty(PropertyEditor: TPropertyEditor;
      var Continue, FreeEditor: Boolean); override;
  {$ELSE}
    procedure EditProperty(const PropertyEditor: IProperty; var Continue: Boolean); override;
  {$ENDIF}
  public
  end;

  TAdvCardTemplateEditor = class(TDefaultEditor)
  protected
  {$IFNDEF DELPHI6_LVL}
    procedure EditProperty(PropertyEditor: TPropertyEditor;
      var Continue, FreeEditor: Boolean); override;
  {$ELSE}
    procedure EditProperty(const PropertyEditor: IProperty; var Continue: Boolean); override;
  {$ENDIF}
  public
  end;


  TAdvGradientProperty =class(TClassProperty)
  public
    function GetAttributes:TPropertyAttributes; override;
    procedure Edit; override;
  end;



procedure Register;


implementation

uses
  SysUtils;

{$IFDEF DELPHI6_LVL}
procedure TAdvCardListEditor.EditProperty(const PropertyEditor: IProperty; var Continue: Boolean);
{$ELSE}
procedure TAdvCardListEditor.EditProperty(PropertyEditor: TPropertyEditor;
  var Continue, FreeEditor: Boolean);
{$ENDIF}
var
  PropName: string;
begin
  PropName := PropertyEditor.GetName;

  if (CompareText(PropName, 'CardTemplate') = 0) then
  begin
    PropertyEditor.Edit;
    Continue := False;
  end;
end;

{$IFDEF DELPHI6_LVL}
procedure TAdvCardTemplateEditor.EditProperty(const PropertyEditor: IProperty; var Continue: Boolean);
{$ELSE}
procedure TAdvCardTemplateEditor.EditProperty(PropertyEditor: TPropertyEditor;
  var Continue, FreeEditor: Boolean);
{$ENDIF}
var
  PropName: string;
begin
  PropName := PropertyEditor.GetName;

  if (CompareText(PropName, 'Items') = 0) then
  begin
    PropertyEditor.Edit;
    Continue := False;
  end;
end;


{ TAdvGradientProperty }

procedure TAdvGradientProperty.Edit;
var
  ge: TGradientEditor;
begin
  ge := TGradientEditor.Create(Application);
  ge.Color := TAdvGradient(GetOrdValue);

  if ge.ShowModal = mrOk then
    SetOrdValue(Longint(ge.Color));
  ge.Free;
end;

function TAdvGradientProperty.GetAttributes: TPropertyAttributes;
begin
  Result := [paDialog];
end;

procedure Register;
begin
  RegisterPropertyEditor(TypeInfo(TAdvGradient),TCustomAdvCardList,'',TAdvGradientProperty);
  RegisterPropertyEditor(TypeInfo(TAdvGradient),TAdvCardAppearance,'',TAdvGradientProperty);
end;

end.
