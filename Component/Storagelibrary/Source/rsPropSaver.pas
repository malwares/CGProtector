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
unit rsPropSaver;

interface

{$I rsStorage.inc}

uses Classes, SysUtils, TypInfo,
     {$IFDEF RSL_WIN}Windows, Messages, Controls, Forms,{$ENDIF}
     {$IFDEF RSL_KYLIX}QControls, QForms,{$ENDIF}
     {$IFDEF RSL_D6GE}Variants,{$ENDIF}
     rsStorage, rsProperty;

type
  TrsPropSaverOption = (poStoreFormPlacement, poStoreDefValues, poEncryptFormPlacement, poNotRestoreCollectionItemsCount);
  TrsPropSaverOptions = set of TrsPropSaverOption;

  TrsPropSaverFormPlacement = (pfpPlacement, pfpSize, pfpState);
  TrsPropSaverFormPlacements = set of TrsPropSaverFormPlacement;

  TrsPropSaverState = (psLoadValues, psSaveValues);
  TrsPropSaverStates = set of TrsPropSaverState;

  TrsPropSaverLoad = (wlManual, wlOnActivate, wlOnCreate, wlOnShow);
  TrsPropSaverSave = (wsManual, wsOnClose, wsOnDeactivate, wsOnDestroy, wsOnHide);

  TrsUserPropertyEvent = procedure (Sender: TObject; const PropName: string; var Value: Variant) of object;
  TrsPropertyEvent = procedure (Sender,Instance: TObject; const PropName: string; var Value: Variant; var Allow: boolean) of object;

  TrsAddInProperties = class(TComponent)
  public
    function GetPropertyValue(Sender,Instance: TObject; const PropName: string): Variant; virtual;
    procedure SetPropertyValue(Sender,Instance: TObject; const PropName: string; const Value: Variant); virtual;
  end;


  TrsPropSaver = class(TrsStorageClient)
  private
    FProperty: TrsProperty;
    FActive: Boolean;
    FCustomProperties: TrsAddInProperties;
    FOptions: TrsPropSaverOptions;
    FProps: TStrings;
    FSection: String;
    FPreparedSection: string;
    FStates: TrsPropSaverStates;
    FSafeFormLoad: TNotifyEvent;
    FSafeFormSave: TNotifyEvent;
    FSafeFormCloseQuery: TCloseQueryEvent;
    FOnAfterLoad: TNotifyEvent;
    FOnAfterSave: TNotifyEvent;
    FOnBeforeSave: TNotifyEvent;
    FOnBeforeLoad: TNotifyEvent;
    FOnGetProperty: TrsPropertyEvent;
    FOnGetUserProperty: TrsUserPropertyEvent;
    FOnSetProperty: TrsPropertyEvent;
    FOnSetUserProperty: TrsUserPropertyEvent;
    FOwnerForm: TComponent;
    FOwnerIsForm: Boolean;
    FWhenLoad: TrsPropSaverLoad;
    FWhenSave: TrsPropSaverSave;
    FFormPlacementOptions: TrsPropSaverFormPlacements;
    procedure NewFormCloseQuery(Sender: TObject; var CanClose: Boolean);
    procedure NewFormSave(Sender: TObject);
    procedure NewFormLoad(Sender: TObject);
    function  GetFormPlacement: string;
    function  GetOwnerForm: TComponent;
    procedure SetCustomProperties(const Value: TrsAddInProperties);
    procedure SetFormPlacement(const Value: string);
    procedure SetProps(const Value: TStrings);
    procedure SetWhenLoad(const Value: TrsPropSaverLoad);
    procedure SetWhenSave(const Value: TrsPropSaverSave);
    function GetValue(const Key: string): Variant;
    procedure SetValue(const Key: string; const Value: Variant);
    procedure SetRootSection(const Value: String);
    procedure CheckPreparedSection;
    procedure SetOptions(const Value: TrsPropSaverOptions);
    procedure SetFormPlacementOptions(const Value: TrsPropSaverFormPlacements);
  protected
    KeyItem: TrsKeyItem;
    KeyWrapper: TrsKeyWrapper;

    procedure Notification(AComponent: TComponent; Operation: TOperation); override;
    property  OwnerForm: TComponent read FOwnerForm;
    property  OwnerIsForm: boolean read FOwnerIsForm;
    procedure SetName(const Value: TComponentName); override;

    function IntSetPublishProperty: boolean;
    function IntGetPublishProperty: boolean;
    procedure SetPropertyValueEx(Instance: TObject; const PropName: string);
    procedure GetPropertyValueEx(Instance: TObject; const PropName: string);
    function DoOnSetProperty(Instance: TObject; const PropName: string): boolean;
    function DoOnGetProperty(Instance: TObject; const PropName: string): boolean;
    procedure SetCollectionProperty(Instance: TCollection; const PropName: string);
    procedure GetCollectionProperty(Instance: TCollection; const PropName: string);
    procedure CheckInEncryptKeys(const APropertyName: string);

    procedure Loaded; override;
  public
    constructor Create(AOwner: TComponent); override;
    destructor Destroy; override;

    property FormPlacement:string read GetFormPlacement write SetFormPlacement;
    function FindInstance(var Instance: TObject; var PropName: string): boolean;
    property States: TrsPropSaverStates read FStates;
    function rsFindGlobalComponent(const Value:string):TComponent;
    procedure LoadValues;
    procedure SaveValues;

    function GetPublishProperty(const PropName: string; var Value: Variant): boolean;
    function GetUserProperty(const PropName: string; var Value: Variant): boolean;
    function GetCustomProperty(const PropName: string; var Value: Variant): boolean;
    function SetPublishProperty(const PropName: string; Value: Variant): boolean;
    function SetUserProperty(const PropName: string; Value: Variant): boolean;
    function SetCustomProperty(const PropName: string; Value: Variant): boolean;

    property Values[const Key:string]: Variant read GetValue write SetValue; default;
    property PreparedRootSection: string read FPreparedSection;
  published
    property Active: Boolean read FActive write FActive default True;
    property CustomProperties: TrsAddInProperties read FCustomProperties write SetCustomProperties;
    property FormPlacementOptions: TrsPropSaverFormPlacements read FFormPlacementOptions write SetFormPlacementOptions default [pfpPlacement, pfpSize, pfpState];
    property Storage;
    property Options: TrsPropSaverOptions read FOptions write SetOptions default [poStoreFormPlacement, poStoreDefValues];
    property RootSection: String read FSection write SetRootSection;
    property Properties: TStrings read FProps write SetProps;

    property WhenLoad: TrsPropSaverLoad read FWhenLoad write SetWhenLoad;
    property WhenSave: TrsPropSaverSave read FWhenSave write SetWhenSave;

    property OnAfterLoad: TNotifyEvent read FOnAfterLoad write FOnAfterLoad;
    property OnAfterSave: TNotifyEvent read FOnAfterSave write FOnAfterSave;
    property OnBeforeLoad: TNotifyEvent read FOnBeforeLoad write FOnBeforeLoad;
    property OnBeforeSave: TNotifyEvent read FOnBeforeSave write FOnBeforeSave;
    property OnGetUserProperty: TrsUserPropertyEvent read FOnGetUserProperty write FOnGetUserProperty;
    property OnSetUserProperty: TrsUserPropertyEvent read FOnSetUserProperty write FOnSetUserProperty;
    property OnGetProperty: TrsPropertyEvent read FOnGetProperty write FOnGetProperty;
    property OnSetProperty: TrsPropertyEvent read FOnSetProperty write FOnSetProperty;
  end;


function  GetSetProp(Instance: TObject; PropInfo: PPropInfo): string;
procedure SetSetProp(Instance: TObject; PropInfo: PPropInfo; Value: string);

function rsStringParamsCount(const Value:string):integer;
function rsStringParams(const Value:string; Idx:integer):string;


implementation

uses rsUtils;

{$IFDEF RSL_TRIAL}
Const
 MaxPropsCount = 25;
 MaxPropSaverCount = 7;
{$ENDIF}

Const
  cFormPlacement = 'FormPlacement';
  cSeparator = ',';

type
  TIntStorage = class(TrsStorage);

{$IFDEF RSL_TRIAL}
var
  rsPropSaverCount: integer = 0;
{$ENDIF}


function rsStringParamsCount(const Value:string):integer;
var
  i: integer;
begin
  i := Length(Value);
  Result := 0;
  if i>0 then begin
    repeat
      if Value[i]=cSeparator then Inc(Result);
      Dec(i);
    until i=0;
    Inc(Result);
  end;
end;


function rsStringParams(const Value:string; Idx:integer):string;
var
  lnt,sIdx,eIdx:integer;
begin
  sIdx := 1;
  lnt:=length(Value);
  While Idx>0 do
   if sIdx>lnt then begin
    Result := '';
    Exit;
   end else begin
    if Value[sIdx]=cSeparator then Dec(Idx);
    Inc(sIdx);
   end;

  eIdx := sIdx;
  While (eIdx<=lnt) AND (Value[eIdx]<>cSeparator) do Inc(eIdx);

  Result := Copy(Value,sIdx,eIdx-sIdx);
end;


function GetSetProp(Instance: TObject; PropInfo: PPropInfo): string;
var
  k,b: cardinal;
  i : integer;
  aTypeInfo : PTypeInfo;
  aTypeData : PTypeData;
begin
  k := GetOrdProp(Instance, PropInfo);

  aTypeInfo := GetTypeData(PropInfo^.PropType^).CompType^;
  aTypeData := GetTypeData(aTypeInfo);

  Result := '';
  i := aTypeData^.MinValue;
  b := 1;
  While ((b and $80000000)=0) and (i<=aTypeData^.MaxValue) do begin
    if (k and b)>0 then begin
      Result := Result + GetEnumName(aTypeInfo, i)+',';
    end;
    Inc(i);
    b := b shl 1;
  end;
  if Length(Result)>0 then SetLength(Result, Length(Result)-1);
 Result := Format('[%s]',[Result]);
end;


procedure SetSetProp(Instance: TObject; PropInfo: PPropInfo; Value: string);
var
  i,b:integer;
  aTypeInfo : PTypeInfo;
  r : Longint;
begin
  if Value='' then Exit;
  if (Value[1]='[') AND ((Value[Length(Value)]=']'))
   then Value := Copy(Value, 2, Length(Value)-2);

  aTypeInfo := GetTypeData(PropInfo^.PropType^).CompType^;
  r:=0;

  for i:=0 to rsStringParamsCount(Value)-1 do begin
    b := GetEnumValue(aTypeInfo, rsStringParams(Value,i));
    r := r + (1 shl b);
  end;
  SetOrdProp(Instance, PropInfo, r);
end;


{ TrsPropSaver }

constructor TrsPropSaver.Create(AOwner: TComponent);
begin
{$IFDEF RSL_TRIAL}
  Inc(rsPropSaverCount);
  if rsPropSaverCount>MaxPropSaverCount then begin
    Application.MessageBox(PChar('Partially restricted version. Only '+
                                 IntToStr(MaxPropSaverCount)+
                                 ' PropSavers are available.'),
                           'Storage Library Error',
                           {$IFDEF RSL_WIN}MB_OK{$ENDIF}
                           {$IFDEF RSL_KYLIX}[smbOK]{$ENDIF});
    Abort;
  end;
{$ENDIF}
  inherited Create(AOwner);
  FProps := TStringList.Create;
  FOptions := [poStoreFormPlacement, poStoreDefValues];
  FFormPlacementOptions := [pfpPlacement, pfpSize, pfpState];
  FActive := True;
  FOwnerForm := GetOwnerForm;
  FProperty := TrsProperty.Create;

{$IFDEF RSL_AUTOLINKREFERENCES}
  if csDesigning in ComponentState then begin
    FStorage := TrsStorage(rsGlobalFindComponent(TrsStorage, AOwner, nil));
    FCustomProperties := TrsAddInProperties(rsGlobalFindComponent(TrsAddInProperties, AOwner, nil));
  end;
{$ENDIF}
  if csDesigning in ComponentState then begin
    if OwnerIsForm then begin
      FWhenLoad := wlOnCreate;// wlOnShow;
      FWhenSave := wsOnClose;
    end else begin
      FWhenLoad := wlOnCreate;
      FWhenSave := wsOnDestroy;
    end;
  end;
  KeyWrapper := TrsKeyWrapper.Create(nil);
end;


destructor TrsPropSaver.Destroy;
begin
  if not (csDesigning in ComponentState) then begin
    WhenLoad := wlManual;
    WhenSave := wsManual;
  end;
  KeyWrapper.PKeyItem := @KeyItem;  //2007-03-12 memory leak fix
  KeyWrapper.Clear;                 //2007-03-12 memory leak fix
  KeyWrapper.Free;
  FProperty.Free;
  FProps.Free;
  inherited Destroy;
{$IFDEF RSL_TRIAL}
  Dec(rsPropSaverCount);
{$ENDIF}
end;


function TrsPropSaver.FindInstance(var Instance: TObject; var PropName: string): boolean;
var
  i,k: integer;
  s: string;
  TypeInfo: PTypeInfo;
  PropInfo: PPropInfo;
  o: TObject;
begin
  TypeInfo := Instance.ClassInfo;
  k := 1;
  for i:=1 to Length(PropName) do
    if PropName[i]='.' then begin
      s := Copy(PropName, k, i-k);
      k := i+1;
      PropInfo := GetPropInfo(TypeInfo, s);
      if (PropInfo<>nil) and (PropInfo^.PropType^.Kind = tkClass)
       then Instance := TObject(GetOrdProp(Instance, PropInfo))
       else
      if Instance is TComponent
       then Instance := TComponent(Instance).FindComponent(s)
       else
      if (PropInfo=nil) and (Instance is TCollection)
       then begin
         k := k-Length(s)-1;
         Break;
       end
       else Break;

      if Instance<>nil then TypeInfo := Instance.ClassInfo
       else Break;
    end;

  if (k=1) and (GetPropInfo(TypeInfo, PropName)=nil) and (Instance is TComponent) then begin
    o := TComponent(Instance).FindComponent(PropName);
    if o<>nil then begin
      PropName := '';
      Instance := o;
      Result := True;
      Exit;
    end;
  end;
  PropName := Copy(PropName, k, Length(PropName)-k+1);
  Result := Instance<>nil;
end;


function TrsPropSaver.GetCustomProperty(const PropName: string; var Value: Variant): boolean;
var
  Instance: TObject;
  s: string;
begin
  Value := Unassigned;
  Result := CustomProperties<>nil;
  if Result then begin
    Instance := Owner;
    s := PropName;
    Result := FindInstance(Instance, s);
    if not Result then Exit;

    Value := CustomProperties.GetPropertyValue(Self, Instance, s);
    Result := not VarIsEmpty(Value);
  end;
end;

{$IFDEF RSL_WIN}
function TrsPropSaver.GetFormPlacement: string;
var
  Placement: TWindowPlacement;
  Form: TForm;
begin
  Result := '';
  if not OwnerIsForm then Exit;
  Form := TForm(OwnerForm);
  if Form<>nil then begin
    Placement.Length := SizeOf(TWindowPlacement);
    GetWindowPlacement(Form.Handle, @Placement);
    with Placement do begin
     if (Form = Application.MainForm) and IsIconic(Application.Handle)
      then ShowCmd := SW_SHOWMINIMIZED;
     if (Form.FormStyle = fsMDIChild) and (Form.WindowState = wsMinimized)
      then Flags := Flags or WPF_SETMINPOSITION;

     Result:=Format('%d,%d,%d,%d,%d,%d,%d,%d,%d,%d',
                    [Flags, ShowCmd,
                     ptMinPosition.X, ptMinPosition.Y,
                     ptMaxPosition.X, ptMaxPosition.Y,
                     rcNormalPosition.Left, rcNormalPosition.Top,
                     rcNormalPosition.Right, rcNormalPosition.Bottom]);
    end;
  end;
end;
{$ELSE}
function TrsPropSaver.GetFormPlacement: string;
var
  Form: TForm;
begin
  Result := '';
  if not OwnerIsForm then Exit;
  Form := TForm(OwnerForm);
  if Form<>nil then begin
    Result := Format('%d,%d,%d,%d,%d',
                     [Ord(Form.WindowState),
                     Form.Left, Form.Top, Form.Width, Form.Height]);
  end;
end;
{$ENDIF}


function TrsPropSaver.GetOwnerForm: TComponent;
var
  own: TComponent;
begin
  own := Owner;

  While own<>nil do
    if (own is TCustomForm) or (own is TDataModule) then Break
     else own := own.Owner;

  FOwnerIsForm := own is TCustomForm;
  Result := TForm(own);
end;


function TrsPropSaver.GetPublishProperty(const PropName: string; var Value: Variant): boolean;
begin
  FProperty.Name := PropName;
  FProperty.SubstName := '';
  KeyWrapper.PKeyItem := @KeyItem;
  Result := IntGetPublishProperty;
  if Result then Value := KeyWrapper.AsVariant;
end;


function TrsPropSaver.GetUserProperty(const PropName: string; var Value: Variant): boolean;
begin
  Value := Unassigned;
  Result := Assigned(FOnGetUserProperty);
  if Result then begin
    FOnGetUserProperty(Self, PropName, Value);
  end;
end;


function TrsPropSaver.GetValue(const Key: string): Variant;
var
  sKeyName: string;
  i: integer;
begin
  sKeyName := FPreparedSection+Key;
  if (Storage<>nil) and Storage.KeyExist(sKeyName) then begin
    Result := Storage.Values[sKeyName];
  end else begin // check for default value
    Result := Unassigned;
    for i:=0 to FProps.Count-1 do begin
      FProperty.AsString := FProps[i];
      if RSLCompareText(FProperty.NameInData, Key)=0 then begin
        if Length(FProperty.DefValue)>0
          then Result := FProperty.DefValue;
//          else Result := Unassigned;
        Break;
      end;
    end;
  end;
end;


procedure TrsPropSaver.LoadValues;
var
  i,k: integer;
begin
  Include(FStates, psLoadValues);
  if Assigned(FOnBeforeLoad) then FOnBeforeLoad(self);
  try
    if Storage=nil then Exit;
    CheckPreparedSection;
    Storage.RootSection := RootSection;

    for i:=0 to FProps.Count-1 do begin
{$IFDEF RSL_TRIAL}
      if i>=MaxPropsCount then Break;
{$ENDIF}
      FProperty.AsString := FProps[i];
      if FProperty.Enabled and (FProperty.State in [psNormal, psRead])
       then begin
        k := TIntStorage(Storage).KeyFindAddItem(FProperty.NameInData, False);
        if k>=0
         then KeyWrapper.PKeyItem := TIntStorage(Storage).GetKeyItem(k)
         else
        if Length(FProperty.DefValue)>0 then begin
           KeyWrapper.PKeyItem := @KeyItem;
           KeyWrapper.AsString := FProperty.DefValue;
        end else continue;

         case FProperty.PropType of
           ptPublished: IntSetPublishProperty;
           ptCustom:    SetCustomProperty(FProperty.Name{InData}, KeyWrapper.AsVariant);
           ptUser:      SetUserProperty(FProperty.NameInData, KeyWrapper.AsVariant);
         end;
       end;
    end;

    if (poStoreFormPlacement in Options) and Storage.KeyExist(cFormPlacement)
     then begin
       if (poEncryptFormPlacement in Options) and Assigned(Storage.Encryptor)
         then Storage.Encryptor.DoDecryptKey(cFormPlacement);
       FormPlacement := Storage.ReadString(cFormPlacement,'');
     end;
  finally
    if Assigned(FOnAfterLoad) then FOnAfterLoad(self);
    Exclude(FStates, psLoadValues);
  end;
end;



procedure TrsPropSaver.NewFormCloseQuery(Sender: TObject; var CanClose: Boolean);
begin
  if Assigned(FSafeFormCloseQuery) then FSafeFormCloseQuery(Sender, CanClose);
  if CanClose and Active and OwnerIsForm and (OwnerForm<>nil) and (Integer(TForm(OwnerForm).Handle) <> 0) then
   try
     SaveValues;
   except
     Application.HandleException(Self);
   end;
end;


procedure TrsPropSaver.NewFormLoad(Sender: TObject);
begin
  if Active then
    try
      LoadValues;
    except
      Application.HandleException(Self);
    end;
  if Assigned(FSafeFormLoad) then FSafeFormLoad(Sender);
end;


procedure TrsPropSaver.NewFormSave(Sender: TObject);
begin
  if Assigned(FSafeFormSave) then FSafeFormSave(Sender);
  if Active and (OwnerForm<>nil) then begin
    if (OwnerIsForm and (Integer(TForm(OwnerForm).Handle) <> 0)) or
       (not OwnerIsForm) then
    try
      SaveValues;
    except
      Application.HandleException(Self);
    end;
  end;
end;


procedure TrsPropSaver.Notification(AComponent: TComponent; Operation: TOperation);
begin
  inherited Notification(AComponent, Operation);
  if (AComponent=FCustomProperties) AND (Operation=opRemove) then FCustomProperties := nil;

//  ShowMessage('Notification:' + AComponent.Name + ' '+ IntToStr(Ord(Operation)));
end;


function TrsPropSaver.rsFindGlobalComponent(const Value: string): TComponent;
var
  i: integer;
  sLeft,sRight: string;
begin
  i := Pos('.',Value);
  if i=0 then Result := Owner.FindComponent(Value)
   else begin
     sLeft  := Copy(Value,1,i-1);
     sRight := Copy(Value,i+1, Length(Value)-i);
     for i:=0 to Screen.FormCount-1 do
      if sLeft = Screen.Forms[i].Name then begin
        Result := Screen.Forms[i].FindComponent(sRight);
        Exit;
      end;
     for i:=0 to Screen.DataModuleCount-1 do
      if sLeft = Screen.DataModules[i].Name then begin
       Result := Screen.DataModules[i].FindComponent(sRight);
       Exit;
      end;
     Result := nil;
   end;
end;


procedure TrsPropSaver.SaveValues;
var
  i,k: integer;
  Value: Variant;
  flOk: boolean;
begin
  Include(FStates, psSaveValues);
  if Assigned(FOnBeforeSave) then FOnBeforeSave(self);
  try
    if Storage=nil then Exit;
    CheckPreparedSection;
    Storage.RootSection := RootSection;
    KeyWrapper.PKeyItem := @KeyItem;

    for i:=0 to FProps.Count-1 do begin
      FProperty.AsString := FProps[i];
      if FProperty.State = psRead then Continue;
      flOk := False;
      if FProperty.Enabled then begin
        case FProperty.PropType of
          ptPublished: flOk := IntGetPublishProperty;
          ptCustom:    begin
                         flOk := GetCustomProperty(FProperty.Name{InData}, Value);
                         if flOk then KeyWrapper.AsVariant := Value;
                       end;
          ptUser:      begin
                         flOk := GetUserProperty(FProperty.NameInData, Value);
                         if flOk then KeyWrapper.AsVariant := Value;
                       end;
        end;
        if flOk and (not (poStoreDefValues in Options)) and
         (RSLCompareText(KeyWrapper.AsString, FProperty.DefValue)=0)  // No case sensitive  08.03.2002
         then flOk := False;
      end;

      if flOk then begin
        k := TIntStorage(Storage).KeyFindAddItem(FProperty.NameInData, True);
        KeyWrapper.AssignValueTo(@TIntStorage(Storage).GetKeyItem(k)^.Value);
        if FProperty.StoreEncrypted then CheckInEncryptKeys(FProperty.NameInData);
      end else Storage.KeyDelete(FProperty.NameInData);
    end;

    if (poStoreFormPlacement in Options) then begin
      Storage.WriteString(cFormPlacement, FormPlacement);
      if (poEncryptFormPlacement in Options) then CheckInEncryptKeys(cFormPlacement);
    end;
  finally
    if Assigned(FOnAfterSave) then FOnAfterSave(self);
    Exclude(FStates, psSaveValues);
  end;
end;


procedure TrsPropSaver.SetCustomProperties(const Value: TrsAddInProperties);
begin
  FCustomProperties := Value;
  if FCustomProperties <> nil then FCustomProperties.FreeNotification(Self);
end;


function TrsPropSaver.SetCustomProperty(const PropName: string; Value: Variant): boolean;
var
  Instance: TObject;
  s: string;
begin
  Result := CustomProperties<>nil;
  if Result then begin
    Instance := Owner;
    s := PropName;
    Result := FindInstance(Instance, s);
    if Result then CustomProperties.SetPropertyValue(Self, Instance, s, Value);
  end;
end;

type
  THackComponent = class(TComponent);

{$IFNDEF RSL_D3}
  {$IFNDEF RSL_CB3}
     {$DEFINE RSL_NOT_D3_CB3}
  {$ENDIF}
{$ENDIF}


{$IFDEF RSL_WIN}
procedure TrsPropSaver.SetFormPlacement(const Value: string);
var
  Form : TForm;
  Placement: TWindowPlacement;
  WinState: TWindowState;
begin
  if not OwnerIsForm then Exit;
  Form := TForm(OwnerForm);
  if (Form=nil) OR (rsStringParamsCount(Value)<>10) then Exit;

  Placement.Length := SizeOf(TWindowPlacement);
  GetWindowPlacement(Form.Handle, @Placement);

  with Placement, Form do begin
    if not IsWindowVisible(Form.Handle) then ShowCmd := SW_HIDE;
    Flags := StrToInt(rsStringParams(Value,0));
    ptMinPosition.x := StrToInt(rsStringParams(Value,2));
    ptMinPosition.y := StrToInt(rsStringParams(Value,3));
    ptMaxPosition.x := StrToInt(rsStringParams(Value,4));
    ptMaxPosition.y := StrToInt(rsStringParams(Value,5));
    if pfpPlacement in FFormPlacementOptions then begin
      rcNormalPosition.Left := StrToInt(rsStringParams(Value,6));
      rcNormalPosition.Top := StrToInt(rsStringParams(Value,7));
    end else begin
      rcNormalPosition.Left := Left;
      rcNormalPosition.Top := Top;
    end;
    if pfpSize in FFormPlacementOptions then begin
      rcNormalPosition.Right := StrToInt(rsStringParams(Value,8))-StrToInt(rsStringParams(Value,6))+rcNormalPosition.Left;
      rcNormalPosition.Bottom := StrToInt(rsStringParams(Value,9))-StrToInt(rsStringParams(Value,7))+rcNormalPosition.Top;
    end else begin
      rcNormalPosition.Right := rcNormalPosition.Left + Width;
      rcNormalPosition.Bottom := rcNormalPosition.Top + Height;
    end;

    if rcNormalPosition.Right > rcNormalPosition.Left then
      if (Position in [poScreenCenter{$IFDEF RSL_NOT_D3_CB3}, poDesktopCenter{$ENDIF}]) and
        not (csDesigning in ComponentState) then
          with THackComponent(Form) do
            try
              SetDesigning(True);
              Position := poDesigned;
            finally
              SetDesigning(False);
            end;

    SetWindowPlacement(Handle, @Placement);

    if pfpState in FFormPlacementOptions then begin
      WinState := wsNormal;
      ShowCmd := StrToInt(rsStringParams(Value,1));
      case ShowCmd of
        SW_SHOWNORMAL, SW_RESTORE, SW_SHOW:                WinState := wsNormal;
        SW_MINIMIZE, SW_SHOWMINIMIZED, SW_SHOWMINNOACTIVE: WinState := wsMinimized;
        SW_MAXIMIZE:                                       WinState := wsMaximized;
      end;
      WindowState := WinState;
    end;

    UpdateControlState;
    Update;
  end;
end;
{$ELSE}
procedure TrsPropSaver.SetFormPlacement(const Value: string);
var
  Form : TForm;
  l,t,w,h: integer;
begin
  if not OwnerIsForm then Exit;
  Form := TForm(OwnerForm);
  if (Form=nil) OR (rsStringParamsCount(Value)<>5) then Exit;

  with Form do begin
    if pfpPlacement in FFormPlacementOptions then begin
      l := StrToInt(rsStringParams(Value,1));
      t := StrToInt(rsStringParams(Value,2));
    end else begin
      l := Left;
      t := Top;
    end;
    if pfpSize in FFormPlacementOptions then begin
      w := StrToInt(rsStringParams(Value,3));
      h := StrToInt(rsStringParams(Value,4));
    end else begin
      w := Width;
      h := Height;
    end;

    SetBounds( l, t, w, h);
    if pfpState in FFormPlacementOptions then
      WindowState := TWindowState(StrToInt(rsStringParams(Value,0)));
  end;
end;
{$ENDIF}


procedure TrsPropSaver.SetName(const Value: TComponentName);
var
  generatedRootSection, ChangeText: Boolean;
begin
  generatedRootSection :=
    (Length(RootSection)>=0) and
    ((Name=RootSection) or
     ((Owner<>nil) and (RootSection=(Owner.Name+'.'+Name))));

  ChangeText := (csDesigning in ComponentState) and generatedRootSection and
    ((Owner = nil) or not (Owner is TControl) or
    not (csLoading in TControl(Owner).ComponentState));

  inherited SetName(Value);
  if ChangeText then begin
    if (Owner<>nil) and (Owner.Name<>'')
      then RootSection := Owner.Name+'.'+Value
      else RootSection := Value;
  end;
end;


procedure TrsPropSaver.SetProps(const Value: TStrings);
begin
  FProps.Assign(Value);
end;


function TrsPropSaver.SetPublishProperty(const PropName: string; Value: Variant): boolean;
begin
  FProperty.Name := PropName;
  FProperty.SubstName := '';
  KeyWrapper.PKeyItem := @KeyItem;
  KeyWrapper.AsVariant := Value;
  Result := IntSetPublishProperty;
end;


procedure TrsPropSaver.SetRootSection(const Value: String);
begin
  FSection := Value;
  CheckPreparedSection;
end;

function TrsPropSaver.SetUserProperty(const PropName: string; Value: Variant): boolean;
begin
  Result := Assigned(FOnSetUserProperty);
  if Result then begin
    FOnSetUserProperty(Self, PropName, Value);
  end;
end;


procedure TrsPropSaver.SetValue(const Key: string; const Value: Variant);
begin
  if Storage<>nil then Storage.Values[FPreparedSection+Key] := Value;
end;


procedure TrsPropSaver.SetWhenLoad(const Value: TrsPropSaverLoad);
begin
  if Value <> FWhenLoad then begin
    if (not OwnerIsForm) and (not (Value in [wlManual,wlOnCreate])) then Exit;

    if csDesigning in ComponentState then FWhenLoad := Value
     else begin
       if FWhenLoad<>wlManual then
         case FWhenLoad of // Unset old event
           wlOnActivate: TForm(OwnerForm).OnActivate := FSafeFormLoad;
           wlOnShow:     TForm(OwnerForm).OnShow := FSafeFormLoad;
           wlOnCreate:
             begin
               if OwnerIsForm then TForm(OwnerForm).OnCreate := FSafeFormLoad
                else TDataModule(OwnerForm).OnCreate := FSafeFormLoad;
             end;
         end;

       FWhenLoad := Value;

       if FWhenLoad<>wlManual then
         case FWhenLoad of // set new event
           wlOnActivate:
             begin
               FSafeFormLoad := TForm(OwnerForm).OnActivate;
               TForm(OwnerForm).OnActivate := NewFormLoad;
             end;
           wlOnShow:
             begin
               FSafeFormLoad := TForm(OwnerForm).OnShow;
               TForm(OwnerForm).OnShow := NewFormLoad;
             end;
           wlOnCreate:
             begin
               if OwnerIsForm then begin
                 FSafeFormLoad := TForm(OwnerForm).OnCreate;
                 TForm(OwnerForm).OnCreate := NewFormLoad;
               end else begin
                 FSafeFormLoad := TDataModule(OwnerForm).OnCreate;
                 TDataModule(OwnerForm).OnCreate := NewFormLoad;
               end;
             end;
         end;
     end;
  end;
end;


procedure TrsPropSaver.SetWhenSave(const Value: TrsPropSaverSave);
begin
  if Value <> FWhenSave then begin
    if (not OwnerIsForm) and (not (Value in [wsManual,wsOnDestroy])) then Exit;
    if csDesigning in ComponentState then FWhenSave := Value
     else begin
       if FWhenSave<>wsManual then
         case FWhenSave of // Unset old event
           wsOnClose:      TForm(OwnerForm).OnCloseQuery := FSafeFormCloseQuery;
           wsOnDeactivate: TForm(OwnerForm).OnDeactivate := FSafeFormSave;
           wsOnHide:       TForm(OwnerForm).OnHide := FSafeFormSave;
           wsOnDestroy:
             begin
               if OwnerIsForm then TForm(OwnerForm).OnDestroy := FSafeFormSave
                 else TDataModule(OwnerForm).OnDestroy := FSafeFormSave;
             end;
         end;

       FWhenSave := Value;

       if FWhenSave<>wsManual then
         case FWhenSave of // set new event
           wsOnClose:
             begin
               FSafeFormCloseQuery := TForm(OwnerForm).OnCloseQuery;
               TForm(OwnerForm).OnCloseQuery := NewFormCloseQuery;
             end;
           wsOnDeactivate:
             begin
               FSafeFormSave := TForm(OwnerForm).OnDeactivate;
               TForm(OwnerForm).OnDeactivate := NewFormSave;
             end;
           wsOnHide:
             begin
               FSafeFormSave := TForm(OwnerForm).OnHide;
               TForm(OwnerForm).OnHide := NewFormSave;
             end;
           wsOnDestroy:
             begin
               if OwnerIsForm then begin
                 FSafeFormSave := TForm(OwnerForm).OnDestroy;
                 TForm(OwnerForm).OnDestroy := NewFormSave;
               end else begin
                 FSafeFormSave := TDataModule(OwnerForm).OnDestroy;
                 TDataModule(OwnerForm).OnDestroy := NewFormSave;
               end;
             end;
         end;
     end;
  end;
end;


function TrsPropSaver.IntSetPublishProperty: boolean;
var
  Instance: TObject;
  s: string;
begin
  Instance := Owner;
  s := FProperty.Name;//InData;
  Result := FindInstance(Instance, s);
  if not Result then Exit;

//  try
  if Assigned(FOnSetProperty) then Result := DoOnSetProperty(Instance, s);

  if Result then begin
    if Instance is TCollection
     then SetCollectionProperty(TCollection(Instance), s)
     else
    if (Instance is TComponent) and (Length(s)=0)
     then KeyWrapper.SetComponentProps(TComponent(Instance))
     else SetPropertyValueEx(Instance, s);
  end;
//  except
//    on E: Exception do
//      outputdebugstring(PChar(s));
//  end;
end;



procedure TrsPropSaver.SetPropertyValueEx(Instance: TObject; const PropName: string);
var
  ClassObject: TObject;
  PropInfo: PPropInfo;
begin
  PropInfo := GetPropInfo(Instance.ClassInfo, PropName);
  if PropInfo<>nil then
    case  PropInfo^.PropType^.Kind of
      tkInteger, tkChar, tkWChar:
        SetOrdProp(Instance, PropInfo, KeyWrapper.AsInteger);
      tkFloat:
        SetFloatProp(Instance, PropInfo, KeyWrapper.AsFloat);
      tkString, tkLString:
        SetStrProp(Instance, PropInfo, KeyWrapper.AsString);
{$IFDEF RSL_D6GE}
      tkWString:
        SetWideStrProp(Instance, PropInfo, KeyWrapper.AsString);
{$ENDIF}
      tkEnumeration:
        {$IFDEF RSL_ENUMASINTEGER}
           SetOrdProp(Instance, PropInfo, KeyWrapper.AsInteger);
        {$ELSE}
           SetOrdProp(Instance, PropInfo, GetEnumValue(PropInfo^.PropType^, KeyWrapper.AsString));
        {$ENDIF}
      tkSet:
        if KeyWrapper.PKeyItem^.Value.kvType = kvtInteger then SetOrdProp(Instance, PropInfo, KeyWrapper.AsInteger)
         else SetSetProp(Instance, PropInfo, KeyWrapper.AsString);
      tkClass:
        begin
          ClassObject := TObject(GetOrdProp(Instance, PropInfo));

          if (ClassObject<>nil) and (ClassObject is TStrings)
            then TStrings(ClassObject).Text := KeyWrapper.AsString
            else
          if (ClassObject<>nil) and ClassObject.InheritsFrom(TPersistent) and
             not ClassObject.InheritsFrom(TComponent)
            then begin
              KeyWrapper.SetPersistentProps(TPersistent(ClassObject));
            end else begin
              ClassObject := rsFindGlobalComponent(KeyWrapper.AsString);
              if ClassObject<>nil then SetOrdProp(Instance, PropInfo, Integer(ClassObject));
            end;
        end;
      tkVariant:
        SetVariantProp(Instance, PropInfo, KeyWrapper.AsVariant);
{$IFDEF RSL_INT64}
      tkInt64:
        SetInt64Prop(Instance, PropInfo, KeyWrapper.AsInt64);
{$ENDIF}
{$ifdef RSL_BDS6}
      tkUString: SetWideStrProp(Instance, PropInfo, KeyWrapper.AsString);
{$endif}
    end;
end;

function TrsPropSaver.DoOnSetProperty(Instance: TObject; const PropName: string): boolean;
var
  Value: Variant;
begin
  Result := True;
  if Assigned(FOnSetProperty) then begin
    Value := KeyWrapper.AsVariant;
    FOnSetProperty(Self, Instance, PropName, Value, Result);
  end;
end;


procedure TrsPropSaver.SetCollectionProperty(Instance: TCollection;  const PropName: string);
var
  i,cnt: integer;
  s,sP: string;
  o: TObject;
begin
  Instance.BeginUpdate;
  try
    s := KeyWrapper.AsString;
    if (Length(s)>1) and (s[1]='"') and (s[Length(s)]='"') then s := Copy(s,2,Length(s)-2);
    cnt := rsStringParamsCount(s);

    if not (poNotRestoreCollectionItemsCount in Options)
      then begin
        if Instance.Count=1 then Instance.Add;
      end;

    for i:=0 to cnt-1 do begin
      KeyWrapper.AsString := rsStringParams(s,i);

      if i<Instance.Count
       then o := Instance.Items[i]
       else begin
         if poNotRestoreCollectionItemsCount in Options
           then Break
           else o := Instance.Add;
       end;
      sP := PropName;
      if FindInstance(o, sP)
       then SetPropertyValueEx(o, sP);
    end;

    KeyWrapper.AsString := s;
    if not (poNotRestoreCollectionItemsCount in Options)
      then begin
        with Instance do
          while Count>cnt do Items[Count-1].Free;
      end;
  finally
    Instance.EndUpdate;
  end;
end;


procedure TrsPropSaver.GetPropertyValueEx(Instance: TObject; const PropName: string);
var
  PropInfo: PPropInfo;
begin
  PropInfo := GetPropInfo(Instance.ClassInfo, PropName);

  if PropInfo <> nil then
    case PropInfo^.PropType^.Kind of
      tkInteger,
      tkChar,
      tkWChar: KeyWrapper.AsInteger := GetOrdProp(Instance, PropInfo);
      tkFloat: KeyWrapper.AsFloat := GetFloatProp(Instance, PropInfo);
      tkString,
      tkLString: KeyWrapper.AsString := GetStrProp(Instance, PropInfo);
{$IFDEF RSL_D6GE}
      tkWString: KeyWrapper.AsString := GetWideStrProp(Instance, PropInfo);
{$ENDIF}
      tkEnumeration:
               begin
                {$IFDEF RSL_ENUMASINTEGER}
                 KeyWrapper.AsInteger := GetOrdProp(Instance, PropInfo);
                {$ELSE}
                 KeyWrapper.AsString := GetEnumName(PropInfo^.PropType^ , GetOrdProp(Instance, PropInfo));
                {$ENDIF}
               end;
      tkSet:   KeyWrapper.AsString := GetSetProp(Instance, PropInfo);
      tkClass:
        begin
          Instance := TObject(GetOrdProp(Instance, PropInfo));
          if Instance<>nil then begin
            if Instance.InheritsFrom(TComponent)
             then begin
               if Owner = TComponent(Instance).Owner
                then KeyWrapper.AsString := TComponent(Instance).Name
                else KeyWrapper.AsString := TComponent(Instance).Owner.Name + '.' + TComponent(Instance).Name;
             end else
            if Instance is TStrings
             then KeyWrapper.AsString := TStrings(Instance).Text
             else
            if Instance.InheritsFrom(TPersistent)
             then KeyWrapper.GetPersistentProps(TPersistent(Instance));
          end;
        end;
      tkVariant: KeyWrapper.AsVariant := GetVariantProp(Instance, PropInfo);
{$IFDEF RSL_INT64}
      tkInt64: KeyWrapper.AsInt64 := GetInt64Prop(Instance, PropInfo);
{$ENDIF}
{$ifdef RSL_BDS6}
      tkUString: KeyWrapper.AsString := GetWideStrProp(Instance, PropInfo);
{$endif}
    end;
end;


function TrsPropSaver.IntGetPublishProperty: boolean;
var
  Instance: TObject;
  s: string;
begin
  Instance := Owner;
  s := FProperty.Name;
  Result := FindInstance(Instance, s);
  if not Result then Exit;

  if Assigned(FOnGetProperty) then begin
    Result := DoOnGetProperty(Instance, s);
    if not Result then begin
      Result := True;
      Exit;
    end;
  end;

  if Result then begin
    if Instance is TCollection
     then GetCollectionProperty(TCollection(Instance), s)
     else
    if (Instance is TComponent) and (Length(s)=0)
     then KeyWrapper.GetComponentProps(TComponent(Instance))
     else GetPropertyValueEx(Instance, s);
  end;
end;


function TrsPropSaver.DoOnGetProperty(Instance: TObject; const PropName: string): boolean;
var
  Value: Variant;
begin
  Result := True;
  if Assigned(FOnGetProperty) then begin
    Value := KeyWrapper.AsVariant;
    FOnGetProperty(Self, Instance, PropName, Value, Result);
    KeyWrapper.AsVariant := Value;
  end;
end;


procedure TrsPropSaver.GetCollectionProperty(Instance: TCollection; const PropName: string);
var
  s,sP: string;
  i: integer;
  o: TObject;
begin
  s := '';
  for i:=0 to Instance.Count-1 do begin
    o := Instance.Items[i];
    sP := PropName;
    if FindInstance(o, sP)
      then GetPropertyValueEx(o, sP);
    s := s + KeyWrapper.AsString + ',';
  end;
  if Length(s)>0 then begin
    s[Length(s)] := '"';
    s := '"'+s;
  end;
  KeyWrapper.AsString := s;
end;


procedure TrsPropSaver.CheckInEncryptKeys(const APropertyName: string);
var
  s: string;
  i: integer;
begin
  if Assigned(Storage.Encryptor) then begin
    s := PreparedRootSection + APropertyName;
    i := Storage.Encryptor.EncryptKeys.IndexOf(s);
    if (i<0) and (Length(s)>0) and (s[1] in cSectionSeparators)
      then i := Storage.Encryptor.EncryptKeys.IndexOf(Copy(s, 2, Length(s)-1));
    if i<0 then Storage.Encryptor.EncryptKeys.Add(s);
  end;
end;

procedure TrsPropSaver.Loaded;
begin
  inherited;
  CheckPreparedSection;
end;

procedure TrsPropSaver.CheckPreparedSection;
begin
  if Length(FSection)=0 then FPreparedSection := '\'
   else begin
     if not (FSection[1] in cSectionSeparators) then FPreparedSection := '\'+FSection
       else FPreparedSection := FSection;
     if not (FPreparedSection[Length(FPreparedSection)] in cSectionSeparators)
      then FPreparedSection := FPreparedSection + '\';
   end;
end;

procedure TrsPropSaver.SetOptions(const Value: TrsPropSaverOptions);
begin
  if FOptions<>Value then begin
    if (Value*[poStoreFormPlacement]) <> (FOptions*[poStoreFormPlacement])
      then begin //need to correct FormPlacementOptions
        if Value*[poStoreFormPlacement]<>[]
          then FFormPlacementOptions := [pfpPlacement, pfpSize, pfpState]
          else FFormPlacementOptions := [];
      end;
    FOptions := Value;
  end;
end;

procedure TrsPropSaver.SetFormPlacementOptions(const Value: TrsPropSaverFormPlacements);
begin
  if FFormPlacementOptions <> Value then begin
    if Value<>[]
      then Include(FOptions, poStoreFormPlacement)
      else Exclude(FOptions, poStoreFormPlacement);
    FFormPlacementOptions := Value;
  end;  
end;

{ TrsAddInProperties }

function TrsAddInProperties.GetPropertyValue(Sender, Instance: TObject;
                                             const PropName: string): Variant;
begin
 Result := Unassigned;
end;

procedure TrsAddInProperties.SetPropertyValue(Sender, Instance: TObject;
                                   const PropName: string; const Value: Variant);
begin
end;

end.
