program EngineBuilder;

uses
  Forms,
  U_Main in 'U_Main.pas' {Frm_Main};

{$R *.res}

begin
  Application.Initialize;
  Application.MainFormOnTaskbar := True;
  Application.CreateForm(TFrm_Main, Frm_Main);
  Application.Run;
end.
