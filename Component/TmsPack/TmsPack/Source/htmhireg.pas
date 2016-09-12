{*************************************************************************}
{ THTMLHint component                                                     }
{ for Delphi 5.0,6.0,7.0,2005 + C++Builder 5.0,6.0                        }
{ version 1.3                                                             }
{                                                                         }
{ written by TMS Software                                                 }
{            copyright © 1999 - 2005                                      }
{            Email : info@tmssoftware.com                                 }
{            Web : http://www.tmssoftware.com                             }
{                                                                         }
{*************************************************************************}

unit htmhireg;

{$I TMSDEFS.INC}
interface

uses
  Classes,htmlhint;

{$IFDEF TMSDOTNET}
{$R THTMLHint.bmp}
{$ENDIF}

procedure Register;

implementation

procedure Register;
begin
  RegisterComponents('TMS HTML',[ THTMLHint ]);
end;

end.

