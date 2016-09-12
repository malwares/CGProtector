{**************************************************************************}
{ TPictureContainer component                                              }
{ for Delphi & C++Builder                                                  }
{ version 1.0                                                              }
{                                                                          }
{ Copyright © 2001 - 2010                                                  }
{   TMS Software                                                           }
{   Email : info@tmssoftware.com                                           }
{   Web : http://www.tmssoftware.com                                       }
{                                                                          }
{ The source code is given as is. The author is not responsible            }
{ for any possible damage done due to the use of this code.                }
{ The component can be freely used in any application. The complete        }
{ source code remains property of the author and may not be distributed,   }
{ published, given or sold in any form as such. No parts of the source     }
{ code can be included in any other component or application without       }
{ written authorization of the author.                                     }
{**************************************************************************}

unit PictureContainer;

{$I TMSDEFS.INC}

interface

uses
  Windows, SysUtils, Classes, Graphics, Controls, ActiveX
  {$IFDEF USEWININET}
  , WinInet
  {$ENDIF}
  {$IFDEF TMSDOTNET}
  , System.Runtime.InteropServices
  {$ENDIF}
  ;

const
  MAJ_VER = 1; // Major version nr.
  MIN_VER = 0; // Minor version nr.
  REL_VER = 0; // Release nr.
  BLD_VER = 0; // Build nr.


type
  {$I WIIF.PAS}

  TPictureItem = class(TCollectionItem)
  private
    FPicture: THTMLPicture;
    FTag: Integer;
    FName: string;
    procedure SetPicture(const Value: THTMLPicture);
  public
    constructor Create(Collection: TCollection); override;
    destructor Destroy; override;
    procedure Assign(Source: TPersistent); override;
  published
    property Picture: THTMLPicture read FPicture write SetPicture;
    property Name: string read FName write FName;
    property Tag: Integer read FTag write FTag;
  end;

  TPictureCollection = class(TCollection)
  private
    FOwner: TComponent;
    function GetItem(Index: Integer): TPictureItem;
    procedure SetItem(Index: Integer; Value: TPictureItem);
  protected
    function GetOwner: TPersistent; override;
  public
    constructor Create(AOwner:TComponent);
    function Add: TPictureItem;
    function Insert(index:integer): TPictureItem;
    property Items[Index: Integer]: TPictureItem read GetItem write SetItem; default;
    function Animate:Boolean;
  end;

  TPictureContainer = class(TComponent)
  private
    FItems: TPictureCollection;
    procedure SetItems(const Value: TPictureCollection);
    function GetVersion: string;
    procedure SetVersion(const Value: string);
    function GetVersionNr: Integer;
    { Private declarations }
  protected
    { Protected declarations }
  public
    { Public declarations }
    constructor Create(AOwner: TComponent); override;
    destructor Destroy; override;
    function FindPicture(s:string): THTMLPicture; virtual;
  published
    { Published declarations }
    property Items: TPictureCollection read FItems write SetItems;
    property Version: string read GetVersion write SetVersion;
  end;


implementation

{$IFDEF TMSDOTNET}
uses
  Types, WinUtils;
{$ENDIF}  

{$I WIIMPL.PAS}

{ TPictureItem }

procedure TPictureItem.Assign(Source: TPersistent);
begin
  Name := (Source as TPictureItem).Name;
  Tag := (Source as TPictureItem).Tag;
  Picture.Assign((Source as TPictureItem).Picture)
end;

constructor TPictureItem.Create(Collection: TCollection);
begin
  inherited;
  FPicture := THTMLPicture.Create;
end;

destructor TPictureItem.Destroy;
begin
  FPicture.Free;
  inherited;
end;

procedure TPictureItem.SetPicture(const Value: THTMLPicture);
begin
  FPicture.Assign(Value);
end;

{ TPictureCollection }

function TPictureCollection.Add: TPictureItem;
begin
  Result := TPictureItem(inherited Add);
end;

function TPictureCollection.Animate: Boolean;
var
  i: Integer;
begin
  Result := False;
  for i := 1 to Count do
  begin
    if Items[i - 1].Picture.Step then
      Result := True;
  end;

end;

constructor TPictureCollection.Create(AOwner: TComponent);
begin
  inherited Create(TPictureItem);
  FOwner := AOwner;
end;

function TPictureCollection.GetItem(Index: Integer): TPictureItem;
begin
  Result := TPictureItem(inherited Items[Index]);
end;

function TPictureCollection.GetOwner: TPersistent;
begin
  Result := FOwner;
end;

function TPictureCollection.Insert(index: Integer): TPictureItem;
begin
{$IFDEF DELPHI4_LVL}
  Result := TPictureItem(inherited Insert(Index));
{$ELSE}
  Result := TPictureItem(inherited Add);
{$ENDIF}  
end;

procedure TPictureCollection.SetItem(Index: Integer;
  Value: TPictureItem);
begin
  inherited SetItem(Index, Value);
end;

{ TPictureContainer }

constructor TPictureContainer.Create(AOwner: TComponent);
begin
  inherited;
  FItems := TPictureCollection.Create(Self);
end;

destructor TPictureContainer.Destroy;
begin
  FItems.Free;
  inherited;
end;

function TPictureContainer.FindPicture(s: string): THTMLPicture;
var
  i: Integer;
begin
  Result := nil;
  s := Uppercase(s);
  i := 1;
  while i <= Items.Count do
  begin
    if Uppercase(Items.Items[i - 1].Name) = s then
    begin
      Result := Items.Items[i - 1].Picture;
      Break;
    end;
    Inc(i);
  end;
end;

procedure TPictureContainer.SetItems(const Value: TPictureCollection);
begin
  FItems := Value;
end;

function TPictureContainer.GetVersion: string;
var
  vn: Integer;
begin
  vn := GetVersionNr;
  Result := IntToStr(Hi(Hiword(vn)))+'.'+IntToStr(Lo(Hiword(vn)))+'.'+IntToStr(Hi(Loword(vn)))+'.'+IntToStr(Lo(Loword(vn)));
end;

function TPictureContainer.GetVersionNr: Integer;
begin
  Result := MakeLong(MakeWord(BLD_VER,REL_VER),MakeWord(MIN_VER,MAJ_VER));
end;

procedure TPictureContainer.SetVersion(const Value: string);
begin

end;

end.
