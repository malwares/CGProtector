{*******************************************************}
{                                                       }
{                Delphi VCL Extensions                  }
{                   Storage library                     }
{                                                       }
{         Copyright (c) 2000-2007 Deepsoftware          }
{                                                       }
{           www - http://www.deepsoftware.com           }
{              email - ray@deepsoftware.com             }
{                                                       }
{*******************************************************}
unit rsRegister;

{$I rsStorage.inc}

interface

uses {$IFDEF RSL_WIN}
       Windows, ShellApi, Dialogs, Forms, Controls,
       {$IFDEF RSL_D6GE}DesignIntf,DesignEditors,{$ELSE}DsgnIntf,{$ENDIF}
     {$ENDIF}
     {$IFDEF RSL_KYLIX}
       DesignIntf, DesignEditors, QControls, QDialogs, QForms,
     {$ENDIF}
     {$IFDEF RSL_NEWDLG}
       {$IFDEF RSL_WIN}rsPropSaverForm,{$ELSE}QrsPropSaverForm,{$ENDIF}
     {$ELSE}
       rsCfgForm,
     {$ENDIF}
     {$IFDEF RSL_WIN}rsRegData,{$ENDIF}
     Classes, SysUtils, ColnEdit,
     rsStorage, rsIniData, rsPropSaver, rsProperties, rsConst, rsBinData, rsXmlData,
     rsUtils, rsTreeViewConnector, rsListViewConnector, rsXorEncryptor, rsAesEncryptor,
     rsSearch, rsEventData;

type
  TrsAboutEditor = class(TComponentEditor)
    function GetVerbCount : integer; override;
    function GetVerb(Index : integer) : string; override;
    procedure ExecuteVerb(Index : integer) ; override;
  end;

  TrsCustomPropertiesEditor = class(TrsAboutEditor)
    function GetVerbCount : integer; override;
    function GetVerb(Index : integer) : string; override;
    procedure ExecuteVerb(Index : integer) ; override;
  end;

  TrsPropSaverEditor = class(TrsAboutEditor)
    function GetVerbCount : integer; override;
    function GetVerb(Index : integer) : string; override;
    procedure ExecuteVerb(Index : integer) ; override;
  private
    procedure Config(AComponent:TComponent);
  end;

  TrsPropSaverProperties = class(TClassProperty)
  public
    function GetAttributes: TPropertyAttributes; override;
    function GetValue: string; override;
    procedure Edit; override;
  end;

  TrsSearchEditor = class(TrsAboutEditor)
    function GetVerbCount : integer; override;
    function GetVerb(Index : integer) : string; override;
    procedure ExecuteVerb(Index : integer) ; override;
  end;

  TrsInternalFileProperty = class(TStringProperty)
  public
    procedure Edit; override;
    function GetAttributes: TPropertyAttributes; override;
  end;

procedure Register;

{$IFDEF RSL_NEWDLG}
procedure FreeDesignTimeDialog;
{$ENDIF}

{$R Storage.dcr}

implementation

{$IFDEF RSL_NEWDLG}
var
  PropSaverForm: TrsPropSaverForm;
{$ENDIF}

procedure Register;
begin
  RegisterComponents('Storage', [TrsStorage, TrsIniData, TrsBinData,
                                 {$IFDEF RSL_WIN}TrsRegData,{$ENDIF}
                                 TrsXMLData, TrsEventData,
                                 TrsCustomProperties, TrsPropSaver,
                                 TrsTreeViewConnector, TrsListViewConnector, TrsSearch,
                                 TrsXorEncryptor, TrsAesEncryptor]);

  RegisterComponentEditor(TrsPropSaver, TrsPropSaverEditor);
  RegisterPropertyEditor(TypeInfo(TStrings), TrsPropSaver, 'Properties', TrsPropSaverProperties);
  RegisterComponentEditor(TrsCustomProperties, TrsCustomPropertiesEditor);
  RegisterComponentEditor(TrsStorage, TrsAboutEditor);
  RegisterComponentEditor(TrsIniData, TrsAboutEditor);
  RegisterComponentEditor(TrsSearch, TrsSearchEditor);
{$IFDEF RSL_WIN}
  RegisterComponentEditor(TrsRegData, TrsAboutEditor);
{$ENDIF}
  RegisterComponentEditor(TrsBinData, TrsAboutEditor);
  RegisterComponentEditor(TrsXMLData, TrsAboutEditor);
  RegisterComponentEditor(TrsTreeViewConnector, TrsAboutEditor);
  RegisterComponentEditor(TrsListViewConnector, TrsAboutEditor);
  RegisterComponentEditor(TrsXorEncryptor, TrsAboutEditor);
  RegisterComponentEditor(TrsAesEncryptor, TrsAboutEditor);
  RegisterComponentEditor(TrsEventData, TrsAboutEditor);

  RegisterPropertyEditor(TypeInfo(String), TrsIniData, 'InternalFileName', TrsInternalFileProperty);
  RegisterPropertyEditor(TypeInfo(String), TrsBinData, 'InternalFileName', TrsInternalFileProperty);
  RegisterPropertyEditor(TypeInfo(String), TrsXmlData, 'InternalFileName', TrsInternalFileProperty);
end;


procedure ShowDesignTimeDialog(AComponent: TComponent);
{$IFDEF RSL_NEWDLG}
begin
  PropSaverform := TrsPropSaverForm.Create(Application);
  try
  PropSaverForm.PropSaver := AComponent as TrsPropSaver;
  PropSaverForm.ShowModal;
  finally
    FreeAndNil(PropSaverForm);
  end;
{$ELSE}
var
  f: TrsFormCfg;
begin
  f := TrsFormCfg.Create(nil);
  try
    f.PropSaver := AComponent as TrsPropSaver;
    f.ShowModal;
  finally
    f.free;
  end;
{$ENDIF}
end;

{$IFDEF RSL_NEWDLG}
procedure FreeDesignTimeDialog;
begin
  PropSaverForm := nil;
end;
{$ENDIF}

{ TrsPropSaverEditor }

procedure TrsPropSaverEditor.Config(AComponent: TComponent);
begin
  ShowDesignTimeDialog(AComponent);
  Designer.Modified;
end;

procedure TrsPropSaverEditor.ExecuteVerb(Index: integer);
begin
  if Index = GetVerbCount - 2 then Config(Component)
   else inherited ExecuteVerb(Index);
end;

function TrsPropSaverEditor.GetVerb(Index: integer): string;
begin
  if Index = GetVerbCount - 2
   then Result := 'Editor...'
   else Result := inherited GetVerb(Index);
end;

function TrsPropSaverEditor.GetVerbCount: integer;
begin
  Result := inherited GetVerbCount + 1;
end;

{ TrsPropSaverProperties }

procedure TrsPropSaverProperties.Edit;
begin
  ShowDesignTimeDialog(GetComponent(0) as TrsPropSaver);
  Designer.Modified;
end;

function TrsPropSaverProperties.GetAttributes: TPropertyAttributes;
begin
  Result := inherited GetAttributes + [paDialog] - [paSubProperties];
end;

function TrsPropSaverProperties.GetValue: string;
begin
  if TStrings(GetOrdValue).Count > 0
   then Result := Format('(Count=%d)',[TStrings(GetOrdValue).Count])
   else Result := '(None)';
end;

{ TrsCustomPropertiesEditor }

procedure TrsCustomPropertiesEditor.ExecuteVerb(Index: integer);
begin
  if Index = GetVerbCount - 2
   then ShowCollectionEditor(Designer, Component, (Component as TrsCustomProperties).Properties, 'Properties')
   else inherited ExecuteVerb(Index);
end;

function TrsCustomPropertiesEditor.GetVerb(Index: integer): string;
begin
  if Index = GetVerbCount - 2
   then Result := '&Items...'
   else Result := inherited GetVerb(Index);
end;

function TrsCustomPropertiesEditor.GetVerbCount: integer;
begin
  Result := inherited GetVerbCount + 1;
end;

{ TrsAboutEditor }

procedure TrsAboutEditor.ExecuteVerb(Index: integer);
begin
  if Index = GetVerbCount - 1 then RslAbout
   else inherited ExecuteVerb(Index);
end;

function TrsAboutEditor.GetVerb(Index: integer): string;
begin
  if Index = GetVerbCount - 1
   then Result := 'About...'
   else Result := inherited GetVerb(Index);
end;

function TrsAboutEditor.GetVerbCount: integer;
begin
  Result := inherited GetVerbCount + 1;
end;

{ TrsSearchEditor }

procedure TrsSearchEditor.ExecuteVerb(Index: integer);
begin
  if Index = GetVerbCount - 2
   then ShowCollectionEditor(Designer, Component, (Component as TrsSearch).Params, 'Params')
   else inherited ExecuteVerb(Index);
end;

function TrsSearchEditor.GetVerb(Index: integer): string;
begin
  if Index = GetVerbCount - 2
   then Result := '&Params...'
   else Result := inherited GetVerb(Index);
end;

function TrsSearchEditor.GetVerbCount: integer;
begin
  Result := inherited GetVerbCount + 1;
end;

{ TrsInternalFileProperty }

procedure TrsInternalFileProperty.Edit;
var
  Dlg: TOpenDialog;
begin
  Dlg := TOpenDialog.Create(Application);
  Dlg.Filename := GetValue;
  Dlg.Filter := '*.*';
  Dlg.Options := Dlg.Options + [ofPathMustExist, ofFileMustExist];
  try
    if Dlg.Execute then SetValue(Dlg.Filename);
  finally
    Dlg.Free;
  end;
  Designer.Modified;
end;

function TrsInternalFileProperty.GetAttributes: TPropertyAttributes;
begin
 Result := inherited GetAttributes + [paDialog] + [paRevertable] - [paSubProperties];
end;

{$IFDEF RSL_D6GE}
initialization
  StartClassGroup(TControl);
  ActivateClassGroup(TControl);
  GroupDescendentsWith(TrsStorage, TControl);
  GroupDescendentsWith(TrsIniData, TControl);
  GroupDescendentsWith(TrsBinData, TControl);
  GroupDescendentsWith(TrsXMLData, TControl);
  GroupDescendentsWith(TrsCustomProperties, TControl);
  GroupDescendentsWith(TrsPropSaver, TControl);

  GroupDescendentsWith(TrsStreamData, TControl);
  GroupDescendentsWith(TrsStorageData, TControl);
  GroupDescendentsWith(TrsAddInProperties, TControl);
  GroupDescendentsWith(TrsStorageClient, TControl);

  GroupDescendentsWith(TrsTreeViewConnector, TControl);
  GroupDescendentsWith(TrsListViewConnector, TControl);

  GroupDescendentsWith(TrsEncryptor, TControl);
  GroupDescendentsWith(TrsXorEncryptor, TControl);
  GroupDescendentsWith(TrsAesEncryptor, TControl);

  GroupDescendentsWith(TrsSearch, TControl);
  GroupDescendentsWith(TrsEventData, TControl);
{$ENDIF}


end.

