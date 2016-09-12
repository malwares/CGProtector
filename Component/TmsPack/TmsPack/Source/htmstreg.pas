{**************************************************************************}
{ THTMLStaticText component                                                }
{ for Delphi & C++Builder                                                  }
{ version 1.2                                                              }
{                                                                          }
{ written by TMS Software                                                  }
{            copyright © 2000 - 2004                                       }
{            Email : info@tmssoftware.com                                  }
{            Web : http://www.tmssoftware.com                              }
{**************************************************************************}

unit htmstreg;

{$I TMSDEFS.INC}
interface

uses
  Classes, HTMLText;

{$IFDEF TMSDOTNET}
{$R THTMLStaticText.bmp}
{$ENDIF}

procedure Register;

implementation

procedure Register;
begin
  RegisterComponents('TMS HTML', [THTMLStaticText ]);
end;

end.
 
