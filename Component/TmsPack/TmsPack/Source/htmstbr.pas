{********************************************************************}
{ THTMLSTATUSBAR Component                                           }
{ for Delphi & C++Builder                                            }
{ version 1.1                                                        }
{                                                                    }
{ Written by                                                         }
{   TMS Software                                                     }
{   Copyright © 2002 - 2004                                          }
{   Email : info@tmssoftware.com                                     }
{   Web : http://www.tmssoftware.com                                 }
{********************************************************************}

unit htmstbr;

{$I TMSDEFS.INC}
interface

uses
  HTMLStatusBar,Classes;

{$IFDEF TMSDOTNET}
{$R THTMLStatusBar.bmp}
{$ENDIF}

procedure Register;

implementation

procedure Register;
begin
  RegisterComponents('TMS HTML', [THTMLStatusBar]);
end;



end.

