{*************************************************************************}
{ THotSpotImage component                                                 }
{ for Delphi & C++Builder                                                 }
{                                                                         }
{ written by TMS Software                                                 }
{           copyright © 2002 - 2010                                       }
{           Email : info@tmssoftware.com                                  }
{           Web : http://www.tmssoftware.com                              }
{                                                                         }
{ The source code is given as is. The author is not responsible           }
{ for any possible damage done due to the use of this code.               }
{ The component can be freely used in any application. The complete       }
{ source code remains property of the author and may not be distributed,  }
{ published, given or sold in any form as such. No parts of the source    }
{ code can be included in any other component or application without      }
{ written authorization of the author.                                    }
{*************************************************************************}

unit HotSpotEditorDE;

interface
{$I TMSDEFS.INC}
uses
  Classes, HotSpotEditor, HotSpotImage, Controls,
{$IFDEF DELPHI6_LVL}
  DesignIntf  , DesignEditors
{$ELSE}
  DsgnIntf
{$ENDIF}
  ;


type
  THotSpotImageEditor = class(TDefaultEditor)
    function GetVerbCount: Integer; override;
    function GetVerb(Index: Integer): String; override;
    procedure ExecuteVerb(Index: Integer); override;
   {$IFNDEF DELPHI6_LVL}
    procedure EditProperty(PropertyEditor: TPropertyEditor;
      var Continue, FreeEditor: Boolean); override;
   {$ELSE}
    procedure EditProperty(const PropertyEditor: IProperty; var Continue: Boolean); override;
   {$ENDIF}
  end;

  THotSpotEditor = class(TPropertyEditor)
    procedure Edit; override;
    function GetAttributes: TPropertyAttributes; override;
    function GetValue: String; override;

    procedure TransferToHotSpotImage;
    procedure TransferFromHotSpotImage;
  end;


implementation

{$WARNINGS OFF}
uses
  SysUtils,Dialogs, ToolIntf
  {, ShellAPI, Windows, ShlObj, ActiveX}
  ;
{$WARNINGS ON}

(*
function GetSystemPath(Folder: Integer): string;
var
  PIDL: PItemIDList;
  Path: LPSTR;
  AMalloc: IMalloc;
begin
  Path := StrAlloc(MAX_PATH);
  SHGetSpecialFolderLocation(0, Folder, PIDL);
  if SHGetPathFromIDList(PIDL, Path) then
    Result := Path;
  SHGetMalloc(AMalloc);
  AMalloc.Free(PIDL);
  StrDispose(Path);
end;

function GetMyDocuments: string;
begin
  Result := GetSystemPath(CSIDL_PERSONAL);
end;
*)

{ THotSpotEditor }

//------------------------------------------------------------------------------
procedure THotSpotEditor.Edit;
var
  frmEditor: TfrmHSIEditor;
  s:string;
begin
  TransferFromHotSpotImage;
  frmEditor := TfrmHSIEditor.Create(nil);
  //s := GetMyDocuments;
  s := PrivateDirectory;
  {$WARNINGS OFF}
  {$IFDEF DELPHI5_LVL}
  s := IncludeTrailingBackslash(s);
  {$ENDIF}
  {$WARNINGS ON}
  frmEditor.LoadSettings(s + 'hotspotedit.ini');
  try
    if frmEditor.ShowModal = mrOK then
    begin
      TransferToHotSpotImage;
      Modified;
    end;
    frmEditor.SaveSettings(s + 'hotspotedit.ini');
  finally
    frmEditor.Free;
  end;
end;

//------------------------------------------------------------------------------
function THotSpotEditor.GetAttributes: TPropertyAttributes;
begin
  Result := [paDialog];
end;

//------------------------------------------------------------------------------
function THotSpotEditor.GetValue: String;
begin
  Result := '(THotSpots)';
end;

{ THotSpotImageEditor }

//------------------------------------------------------------------------------

{$IFDEF DELPHI6_LVL}
procedure THotSpotImageEditor.EditProperty(const PropertyEditor: IProperty; var Continue: Boolean);
{$ELSE}
procedure THotSpotImageEditor.EditProperty(PropertyEditor: TPropertyEditor;
  var Continue, FreeEditor: Boolean);
{$ENDIF}
begin
  if PropertyEditor.GetName = 'HotSpots' then
  begin
    PropertyEditor.Edit;
    Continue := False;
  end
  else inherited;
end;

//------------------------------------------------------------------------------
procedure THotSpotImageEditor.ExecuteVerb(Index: Integer);
begin
  Edit;
end;

//------------------------------------------------------------------------------
function THotSpotImageEditor.GetVerb(Index: Integer): String;
begin
  Result := 'Edit hotspots...';
end;

//------------------------------------------------------------------------------
function THotSpotImageEditor.GetVerbCount: Integer;
begin
  Result := 1;
end;

//------------------------------------------------------------------------------
procedure THotSpotEditor.TransferFromHotSpotImage;
var
  Comp: THotSpotImage;
begin
  if propCount = 0 then
    Exit;
  Comp := THotSpotImage(GetComponent(0));
  if Comp = nil then
    Exit;
  if FHotSpots_org = nil then
    Exit;
  if FPicture=nil then
    Exit;
  if FHotSpots=nil then
    Exit;

  ImageList := Comp.Images;  
  FHotSpots_org.Assign(Comp.HotSpots);
  FPicture.Assign(Comp.Picture);
  if Comp.Stretch then
    FHotSpots_org.ReScale(FPicture.Width,FPicture.Height);
  FHotSpots.Assign(FHotSpots_org);
  HotSpotsChanged:=false;
end;

//------------------------------------------------------------------------------
procedure THotSpotEditor.TransferToHotSpotImage;
var
  Comp: THotSpotImage;
begin
  Comp := THotSpotImage(GetComponent(0));
  Comp.HotSpots.Assign(FHotSpots);
  if Comp.Stretch then
    Comp.HotSpots.ReScale(Comp.Width,Comp.Height)
  else
    Comp.HotSpots.ReScale(Comp.Picture.Width,Comp.Picture.Height);
  Comp.Picture := FPicture;
  Comp.RePaint;
end;

end.
