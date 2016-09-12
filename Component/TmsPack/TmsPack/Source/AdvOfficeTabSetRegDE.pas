unit AdvOfficeTabSetRegDE;

interface
{$I TMSDEFS.INC}

uses
  Classes, AdvOfficeTabSet, GDIPicture, GDIPicDE,
  {$IFDEF DELPHI6_LVL}
  {$IFDEF TMSDOTNET}
  Borland.Vcl.Design.DesignIntf, Borland.Vcl.Design.DesignEditors
  {$ENDIF}
  {$IFNDEF TMSDOTNET}
  DesignIntf, DesignEditors
  {$ENDIF}
  {$ELSE}
  DsgnIntf
  {$ENDIF}
  ;

procedure Register;

implementation

procedure Register;
begin
  // Setting property Editor to all properties of type TGDIPPicture
  RegisterPropertyEditor(TypeInfo(TGDIPPicture), TTabSetButtonSettings, '', TGDIPPictureProperty);
  RegisterPropertyEditor(TypeInfo(TGDIPPicture), TOfficeTabCollectionItem, 'Picture', TGDIPPictureProperty);
  RegisterPropertyEditor(TypeInfo(TGDIPPicture), TOfficeTabCollectionItem, 'DisabledPicture', TGDIPPictureProperty);
end;



end.

