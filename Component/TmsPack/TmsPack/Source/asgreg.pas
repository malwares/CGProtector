{*********************************************************************}
{ TADVSTRINGGRID component                                            }
{ for Delphi & C++Builder                                             }
{                                                                     }
{ written by TMS Software                                             }
{            copyright © 1996-2008                                    }
{            Email : info@tmssoftware.com                             }
{            Web : http://www.tmssoftware.com                         }
{*********************************************************************}

unit ASGReg;

interface
{$I TMSDEFS.INC}

uses
  Classes, Advgrid, BaseGrid, AsgCheck, AsgMemo, AdvSpin,
  AsgReplaceDialog, AsgFindDialog, AsgPrev, AsgPrint, AsgHTML, FrmCtrlLink,
  AdvGridCSVPager, AsgImport
  {$IFDEF DELPHI5_LVL}
  , AdvGridWorkbook
  {$ENDIF}
  ;

{$IFDEF TMSDOTNET}
{$R TAdvStringGrid.bmp}
{$R TAdvGridReplaceDialog.bmp}
{$R TAdvGridFindDialog.bmp}
{$R TAdvGridPrintSettingsDialog.bmp}
{$R TAdvGridHTMLSettingsDialog.bmp}
{$R TAdvPreviewDialog.bmp}
{$R TAdvGridUndoRedo.bmp}
{$R TAdvStringGridCheck.bmp}
{$R TEditLink.bmp}
{$R TMemoEditLink.bmp}
{$R TFormControlEditLink.bmp}
{$R TCapitalCheck.bmp}
{$R TDBAdvGrid.bmp}
{$R TAdvGridRTFIO.bmp}
{$R TAdvGridCSVPager.bmp}
{$ENDIF}


{$IFNDEF TMSDOTNET}
{$R ASGREG.RES}
{$ENDIF}

procedure Register;

implementation

procedure Register;
begin
  RegisterComponents('TMS Grids', [TAdvStringGrid]);
  //RegisterComponents('TMS Grids', [TAdvSpinEdit]);

  RegisterComponents('TMS Grids', [TCapitalCheck]);
  RegisterComponents('TMS Grids', [TMemoEditLink]);
  RegisterComponents('TMS Grids', [TAdvGridUndoRedo]);
  RegisterComponents('TMS Grids', [TAdvGridReplaceDialog]);
  RegisterComponents('TMS Grids', [TAdvGridFindDialog]);
  RegisterComponents('TMS Grids', [TAdvPreviewDialog]);
  RegisterComponents('TMS Grids', [TAdvGridPrintSettingsDialog]);
  RegisterComponents('TMS Grids', [TAdvGridHTMLSettingsDialog]);
  RegisterComponents('TMS Grids', [TFormControlEditLink]);
  RegisterComponents('TMS Grids', [TAdvGridCSVPager]);
  RegisterComponents('TMS Grids', [TAdvGridCSVPager]);
  RegisterComponents('TMS Grids', [TAdvGridImportDialog]);
  {$IFDEF DELPHI5_LVL}
  {$IFNDEF TMSDOTNET}
  RegisterComponents('TMS Grids',[TAdvGridWorkbook]);
  {$ENDIF}
  {$ENDIF}
end;

end.

