{********************************************************************}
{ TPICKDLG component                                                 }
{ for Delphi & C++Builder                                            }
{ version 1.1                                                        }
{                                                                    }
{ written by TMS Software                                            }
{            copyright © 1998 - 2004                                 }
{            Email : info@tmssoftware.com                            }
{            Web : http://www.tmssoftware.com                        }
{********************************************************************}
unit pdlgreg;

interface

{$I TMSDEFS.INC}
uses
  Pickdlg, Classes;


{$IFDEF TMSDOTNET}
{$R TPickDialog.bmp}
{$ENDIF}
procedure Register;

implementation

procedure Register;
begin
  RegisterComponents('TMS',[TPickDialog]);
end;

end.
 
