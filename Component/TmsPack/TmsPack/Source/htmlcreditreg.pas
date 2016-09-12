{**************************************************************************}
{ THTMLCredit component                                                    }
{ for Delphi & C++Builder                                                  }
{ version 1.0                                                              }
{                                                                          }
{ written by TMS Software                                                  }
{            copyright © 2003 - 2004                                       }
{            Email : info@tmssoftware.com                                  }
{            Web : http://www.tmssoftware.com                              }
{**************************************************************************}

unit HTMLCreditReg;

interface
{$I TMSDEFS.INC}
uses
  Classes, HTMLCredit;

{$IFDEF TMSDOTNET}
{$R THTMLCredit.bmp}
{$ENDIF}

procedure Register;

implementation

procedure Register;
begin
  RegisterComponents('TMS HTML', [THTMLCredit]);
end;

end.
 
