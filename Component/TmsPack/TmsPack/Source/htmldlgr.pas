{********************************************************************}
{ THTMDialog component                                               }
{ for Delphi & C++Builder                                            }
{ version 1.0                                                        }
{                                                                    }
{  Written by                                                        }
{    TMS Software                                                    }
{    Copyright © 2001 - 2004                                         }
{    Email : info@tmssoftware.com                                    }
{    Web : http://www.tmssoftware.com                                }
{********************************************************************}

unit htmldlgr;

interface
{$I TMSDEFS.INC}
uses
  Classes, HTMLDialog;

{$IFDEF TMSDOTNET}
{$R THTMLDialog.bmp}
{$ENDIF}

procedure Register;

implementation

procedure Register;
begin
  RegisterComponents('TMS HTML',[ THTMLDialog ]);
end;

end.

