{********************************************************************}
{ THTMLPopup component                                               }
{ for Delphi & C++Builder                                            }
{ version 1.0                                                        }
{                                                                    }
{ written by TMS Software                                            }
{            copyright © 2001 - 2004                                 }
{            Email : info@tmssoftware.com                            }
{            Web : http://www.tmssoftware.com                        }
{********************************************************************}

unit HTMLPopupReg;

{$I TMSDEFS.INC}
interface

uses
  Classes, HTMLPopup;

{$IFDEF TMSDOTNET}
{$R THTMLPopup.bmp}
{$ENDIF}

procedure Register;

implementation

procedure Register;
begin
  RegisterComponents('TMS HTML', [THTMLPopup]);
end;



end.

