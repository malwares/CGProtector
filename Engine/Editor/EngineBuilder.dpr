program EngineBuilder;

uses
  Forms,
  U_FrmMain in 'U_FrmMain.pas' {Frm_Main},
  U_Utils in 'U_Utils.pas';

{$R *.res}

begin
  Application.Initialize;
  Application.MainFormOnTaskbar := True;
  Application.CreateForm(TFrm_Main, Frm_Main);
  Application.Run;
end.
