program HardwareGrab;

uses
  Forms,
  U_FrmHardwareGrab in 'U_FrmHardwareGrab.pas' {Frm_HardwareGrab},
  U_Hardwareid in 'U_Hardwareid.pas';

{$R *.res}

begin
  Application.Initialize;
  Application.MainFormOnTaskbar := True;
  Application.CreateForm(TFrm_HardwareGrab, Frm_HardwareGrab);
  Application.Run;
end.
