program CGProtect;

uses
  Forms,
  U_FrmMain in 'U_FrmMain.pas' {Frm_Main},
  U_Type in 'U_Type.pas',
  U_FrmExecute in 'U_FrmExecute.pas' {Frm_Execute},
  U_FrmDrop in 'U_FrmDrop.pas' {Frm_Drop},
  U_FrmBinder in 'U_FrmBinder.pas' {Frm_Binder},
  U_Utils in 'U_Utils.pas',
  U_IconDll in 'U_IconDll.pas',
  U_PEUtils in 'U_PEUtils.pas',
  U_IconChangerUnit in 'U_IconChangerUnit.pas',
  U_FrmDownloader in 'U_FrmDownloader.pas' {Frm_Downloader},
  U_FrmResource in 'U_FrmResource.pas' {Frm_Resource},
  U_FrmSection in 'U_FrmSection.pas' {Frm_Section},
  U_RetCompress in 'U_RetCompress.pas',
  U_HashList in 'U_HashList.pas',
  StreamHelper in 'StreamHelper.pas',
  U_Chiper in 'U_Chiper.pas',
  U_Cloner in 'U_Cloner.pas',
  U_Compiler in 'U_Compiler.pas',
  U_Encryption in 'U_Encryption.pas',
  U_Engine in 'U_Engine.pas',
  U_Hardwareid in 'U_Hardwareid.pas',
  U_ThreadHandle in 'U_ThreadHandle.pas',
  U_FrmProxy in 'U_FrmProxy.pas' {Frm_Proxy};

{$R *.res}

begin
  Application.Initialize;
  Application.MainFormOnTaskbar := True;
  Application.Title := 'CG-Protector';
  Application.CreateForm(TFrm_Main, Frm_Main);
  Application.CreateForm(TFrm_Execute, Frm_Execute);
  Application.CreateForm(TFrm_Drop, Frm_Drop);
  Application.CreateForm(TFrm_Binder, Frm_Binder);
  Application.CreateForm(TFrm_Downloader, Frm_Downloader);
  Application.CreateForm(TFrm_Resource, Frm_Resource);
  Application.CreateForm(TFrm_Section, Frm_Section);
  Application.CreateForm(TFrm_Proxy, Frm_Proxy);
  Application.Run;
end.
