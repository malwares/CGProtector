{$I TMSDEFS.INC}
{***********************************************************************}
{ TPlanner component                                                    }
{ for Delphi & C++Builder & Kylix                                       }
{ for Delphi & C++Builder                                               }
{ version 2.0, Jan 2004                                                 }
{                                                                       }
{ written by TMS Software                                               }
{            copyright © 1999-2004                                      }
{            Email: info@tmssoftware.com                                }
{            Web: http://www.tmssoftware.com                            }
{                                                                       }
{ The source code is given as is. The author is not responsible         }
{ for any possible damage done due to the use of this code.             }
{ The component can be freely used in any application. The complete     }
{ source code remains property of the author and may not be distributed,}
{ published, given or sold in any form as such. No parts of the source  }
{ code can be included in any other component or application without    }
{ written authorization of the author.                                  }
{***********************************************************************}


unit PlanObj;

interface

uses
  Classes, Graphics;

const
  NumColors = 288;

type
  TNumColorsRange = 0..NumColors;
                                       
  TCellState = record
    Color: TColor;
    Selected: Integer;
  end;

  TPlannerColorArray = array[TNumColorsRange] of TCellState;
  PPlannerColorArray = ^TPlannerColorArray;


  {$IFDEF TMSDOTNET}
  TPlannerColorArrayObject = class(TObject)
  private
    FColorArray: TPlannerColorArray;
    FTag: Integer;
    function GetColor(Index: Integer): TColor;
    procedure SetColor(Index: Integer; const Value: TColor);
    function GetSelected(Index: Integer): Integer;
    procedure SetSelected(Index: Integer; const Value: Integer);
  public
    property ColorArray: TPlannerColorArray read FColorArray write FColorArray;
    property Tag: Integer read FTag write FTag;
    property Color[Index: Integer]: TColor read GetColor write SetColor;
    property Selected[Index: Integer]: Integer read GetSelected write SetSelected;
  end;
  {$ENDIF}

  TColorChangeEvent = procedure(Sender: TObject; Index: Integer) of object;

  TPlannerColorArrayList = class(TList)
  private
    FOnChange: TColorChangeEvent;
    {$IFNDEF TMSDOTNET}
    procedure SetArray(Index: Integer; Value: PPlannerColorArray);
    function GetArray(Index: Integer): PPlannerColorArray;
    {$ENDIF}
    {$IFDEF TMSDOTNET}
    procedure SetArray(Index: Integer; Value: TPlannerColorArrayObject);
    function GetArray(Index: Integer): TPlannerColorArrayObject;
    {$ENDIF}
  public
    constructor Create;
    destructor Destroy; override;
    {$IFNDEF TMSDOTNET}
    property Items[Index: Integer]: PPlannerColorArray read GetArray write SetArray;
    function Add: PPlannerColorArray;
    {$ENDIF}
    {$IFDEF TMSDOTNET}
    property Items[Index: Integer]: TPlannerColorArrayObject read GetArray write SetArray;
    function Add: TPlannerColorArrayObject;
    {$ENDIF}
    procedure Delete(Index: Integer);
    property OnChange: TColorChangeEvent read FOnChange write FOnChange;
  end;

 


implementation

{ TPlannerColorArrayList }

{$IFNDEF TMSDOTNET}
function TPlannerColorArrayList.Add: PPlannerColorArray;
begin
  New(Result);
  inherited Add(Result);
end;
{$ENDIF}

{$IFDEF TMSDOTNET}
function TPlannerColorArrayList.Add: TPlannerColorArrayObject;
begin
  Result := TPlannerColorArrayObject.Create;
  inherited Add(Result);
end;
{$ENDIF}

constructor TPlannerColorArrayList.Create;
begin
  inherited;
end;

procedure TPlannerColorArrayList.Delete(Index: Integer);
begin
  {$IFNDEF TMSDOTNET}
  if Assigned(Items[Index]) then
    Dispose(Items[Index]);
  {$ENDIF}

  {$IFDEF TMSDOTNET}
  if Assigned(Items[Index]) then
    Items[Index].Free;
  {$ENDIF}

  inherited Delete(Index);
end;

destructor TPlannerColorArrayList.Destroy;
var
  Index: Integer;
begin
  {$IFNDEF TMSDOTNET}
  for Index := 0 to Self.Count - 1 do
    if Assigned(Items[Index]) then
      Dispose(Items[Index]);
  {$ENDIF}

  {$IFDEF TMSDOTNET}
  for Index := 0 to Self.Count - 1 do
    if Assigned(Items[Index]) then
      Items[Index].Free;
  {$ENDIF}
  inherited;
end;

{$IFNDEF TMSDOTNET}
function TPlannerColorArrayList.GetArray(
  Index: Integer): PPlannerColorArray;
begin
  Result := PPlannerColorArray(inherited Items[Index]);
end;

procedure TPlannerColorArrayList.SetArray(Index: Integer;
  Value: PPlannerColorArray);
begin
  inherited Items[Index] := Value;
end;
{$ENDIF}

{$IFDEF TMSDOTNET}
function TPlannerColorArrayList.GetArray(
  Index: Integer): TPlannerColorArrayObject;
begin
  Result := TPlannerColorArrayObject(inherited Items[Index]);
end;

procedure TPlannerColorArrayList.SetArray(Index: Integer;
  Value: TPlannerColorArrayObject);
begin
  inherited Items[Index] := Value;
end;
{$ENDIF}

{$IFDEF TMSDOTNET}

{ TPlannerColorArrayObject }

function TPlannerColorArrayObject.GetColor(Index: Integer): TColor;
begin
  Result := FColorArray[Index].Color;
end;

function TPlannerColorArrayObject.GetSelected(Index: Integer): Integer;
begin
  Result := FColorArray[Index].Selected;
end;

procedure TPlannerColorArrayObject.SetColor(Index: Integer;
  const Value: TColor);
begin
  FColorArray[Index].Color := Value;
end;

procedure TPlannerColorArrayObject.SetSelected(Index: Integer;
  const Value: Integer);
begin
  FColorArray[Index].Selected := Value;
end;

{$ENDIF}




end.
