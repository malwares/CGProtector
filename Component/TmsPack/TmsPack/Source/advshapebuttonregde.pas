{********************************************************************}
{ TAdvShapeButton component                                          }
{ for Delphi & C++Builder                                            }
{                                                                    }
{ written                                                            }
{   TMS Software                                                     }
{   copyright © 2006 - 2010                                          }
{   Email : info@tmssoftware.com                                     }
{   Web : http://www.tmssoftware.com                                 }
{                                                                    }
{ The source code is given as is. The author is not responsible      }
{ for any possible damage done due to the use of this code.          }
{ The component can be freely used in any application. The source    }
{ code remains property of the writer and may not be distributed     }
{ freely as such.                                                    }
{********************************************************************}

unit AdvShapeButtonRegDE;

interface
{$I TMSDEFS.INC}
uses
  AdvShapeButton, AdvShapeButtonDE, GDIPicDE, Classes, GDIPicture, AdvHintInfo,
{$IFDEF DELPHI6_LVL}
  DesignIntf, DesignEditors
{$ELSE}
  DsgnIntf
{$ENDIF}
  ;
            
procedure Register;

implementation

procedure Register;
begin
  RegisterPropertyEditor(TypeInfo(TGDIPPicture), TAdvShapeButton, 'Picture', TGDIPPictureProperty);
  RegisterPropertyEditor(TypeInfo(TGDIPPicture), TAdvShapeButton, 'PictureHot', TGDIPPictureProperty);
  RegisterPropertyEditor(TypeInfo(TGDIPPicture), TAdvShapeButton, 'PictureDown', TGDIPPictureProperty);
  RegisterPropertyEditor(TypeInfo(TGDIPPicture), TAdvShapeButton, 'PictureDisabled', TGDIPPictureProperty);
  RegisterComponentEditor(TAdvShapeButton, TAdvShapeButtonEditor);
end;

end.

