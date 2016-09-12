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
unit rsProperties;

interface

{$I rsStorage.inc}

uses Classes, SysUtils,
     {$IFDEF RSL_D6GE}Variants,{$ENDIF}
     rsUtils, rsPropSaver;

type
  TrsCustomProperties = class;

  TrsCustomPropertyEvent = procedure (Sender,Instance: TObject; var Value: Variant) of object;


  TrsCustomProperty = class(TCollectionItem)
  private
    FInDescendants: boolean;
    FPropClass: string;
    FPropName: string;
    FOnGetProperty: TrsCustomPropertyEvent;
    FOnSetProperty: TrsCustomPropertyEvent;
  protected
    function GetDisplayName: string; override;
  public
    function IsSuitable(Instance: TObject): boolean;
    constructor Create(Collection: TCollection); override;
    destructor Destroy; override;
    procedure Assign(Source: TPersistent); override;
  published
    property InDescendants: boolean read FInDescendants write FInDescendants default True;
    property PropClass: string read FPropClass write FPropClass;
    property PropName: string read FPropName write FPropName;
    property OnGetProperty: TrsCustomPropertyEvent read FOnGetProperty write FOnGetProperty;
    property OnSetProperty: TrsCustomPropertyEvent read FOnSetProperty write FOnSetProperty;
  end;

  TrsPropertyItems = class(TCollection)
  private
    FOwner: TrsCustomProperties;
    function GetItem(Index: Integer): TrsCustomProperty;
    procedure SetItem(Index: Integer; const Value: TrsCustomProperty);
  protected
    function GetOwner: TPersistent; override;
  public
    constructor Create(AOwner: TrsCustomProperties);
    function Add: TrsCustomProperty;
{$WARNINGS OFF}
    property Owner: TrsCustomProperties read FOwner;
{$WARNINGS ON}
    property Items[Index: Integer]: TrsCustomProperty read GetItem write SetItem; default;
  end;


  TrsCustomProperties = class(TrsAddInProperties)
  private
    FProperties: TrsPropertyItems;
    procedure SetProperties(const Value: TrsPropertyItems);
{$IFDEF RSL_AUTOLINKREFERENCES}
    procedure rsGlobalComponentProc(Instance: TComponent);
{$ENDIF}
  public
    constructor Create(AOwner: TComponent); override;
    destructor Destroy; override;
    function GetPropertyValue(Sender,Instance: TObject; const PropName: string): Variant; override;
    procedure SetPropertyValue(Sender,Instance: TObject; const PropName: string; const Value: Variant); override;
  published
    property Properties: TrsPropertyItems read FProperties write SetProperties;
  end;


implementation



{ TrsPropertyItems }

function TrsPropertyItems.Add: TrsCustomProperty;
begin
  Result := TrsCustomProperty(inherited Add);
end;

constructor TrsPropertyItems.Create(AOwner: TrsCustomProperties);
begin
  inherited Create(TrsCustomProperty);
  FOwner := AOwner;
end;

function TrsPropertyItems.GetItem(Index: Integer): TrsCustomProperty;
begin
  Result := TrsCustomProperty(inherited GetItem(Index));
end;

function TrsPropertyItems.GetOwner: TPersistent;
begin
  Result := FOwner;
end;

procedure TrsPropertyItems.SetItem(Index: Integer;  const Value: TrsCustomProperty);
begin
  inherited SetItem(Index, Value);
end;

{ TrsCustomProperty }

procedure TrsCustomProperty.Assign(Source: TPersistent);
begin
  if Source is TrsCustomProperty then begin
    FInDescendants := TrsCustomProperty(Source).FInDescendants;
    FPropClass := TrsCustomProperty(Source).FPropClass;
    FPropName := TrsCustomProperty(Source).FPropName;
    FOnGetProperty := TrsCustomProperty(Source).FOnGetProperty;
    FOnSetProperty := TrsCustomProperty(Source).FOnSetProperty;
  end else inherited Assign(Source);
end;

constructor TrsCustomProperty.Create(Collection: TCollection);
begin
  inherited Create(Collection);
  FInDescendants := True;
end;

destructor TrsCustomProperty.Destroy;
begin
  inherited Destroy;
end;

function TrsCustomProperty.GetDisplayName: string;
begin
  Result := Format('%s.%s',[FPropClass,FPropName]);
  if (Result[1]='.') or (Result[Length(Result)]='.')
   then Result := inherited GetDisplayName;
end;

function TrsCustomProperty.IsSuitable(Instance: TObject): boolean;
var
  ClassRef: TClass;
begin
  if Instance=nil then begin
    Result := False;
    Exit;
  end;
  Result := CompareText(Instance.ClassName, FPropClass)=0;
  if not Result then
    if FInDescendants then begin
      ClassRef := Instance.ClassType;
      While ClassRef<>nil do
        if CompareText(ClassRef.ClassName, FPropClass)=0 then begin
          Result := True;
          Break;
        end else ClassRef := ClassRef.ClassParent;
    end;
end;

{ TrsCustomProperties }

constructor TrsCustomProperties.Create(AOwner: TComponent);
begin
  inherited Create(AOwner);
  FProperties := TrsPropertyItems.Create(Self);
{$IFDEF RSL_AUTOLINKREFERENCES}
  if csDesigning in ComponentState then begin
    rsGlobalFindComponent(TrsPropSaver, AOwner, rsGlobalComponentProc);
  end;
{$ENDIF}
end;

destructor TrsCustomProperties.Destroy;
begin
  FProperties.Free;
  inherited Destroy;
end;

function TrsCustomProperties.GetPropertyValue(Sender,Instance: TObject; const PropName: string): Variant;
var
  i: integer;
begin
  Result := Unassigned;
  for i:=0 to Properties.Count-1 do
   if (CompareText(PropName, Properties[i].PropName)=0) and
      (Properties[i].IsSuitable(Instance))
     then begin
       if Assigned(Properties[i].OnGetProperty) then
         Properties[i].OnGetProperty(Sender, Instance, Result);
       Break;
     end;
end;

{$IFDEF RSL_AUTOLINKREFERENCES}
procedure TrsCustomProperties.rsGlobalComponentProc(Instance: TComponent);
begin
  if TrsPropSaver(Instance).CustomProperties=nil then
    TrsPropSaver(Instance).CustomProperties := Self;
end;
{$ENDIF}

procedure TrsCustomProperties.SetProperties(const Value: TrsPropertyItems);
begin
  FProperties.Assign(Value);
end;

procedure TrsCustomProperties.SetPropertyValue(Sender,Instance: TObject; const PropName: string;
                                               const Value: Variant);
var
  i: integer;
  v: variant;
begin
  for i:=0 to Properties.Count-1 do
   if (CompareText(PropName, Properties[i].PropName)=0) and
      (Properties[i].IsSuitable(Instance))
     then begin
       if Assigned(Properties[i].OnSetProperty) then begin
         v := Value;
         Properties[i].OnSetProperty(Sender, Instance, v);
       end;
       Break;
     end;
end;

end.
