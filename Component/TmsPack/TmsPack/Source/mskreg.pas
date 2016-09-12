{********************************************************************}
{ TMASKEDITEX component                                              }
{ for Delphi 3.0,4.0,5.0,6.0 & C++Builder 3,4,5                      }
{ version 1.1                                                        }
{                                                                    }
{ Written by                                                         }
{   TMS Software                                                     }
{   Copyright © 1998-2001                                            }
{   Email : info@tmssoftware.com                                     }
{   Web : http://www.tmssoftware.com                                 }
{********************************************************************}

unit mskreg;

interface

uses
  MaskEdEx,Classes;

{$I TMSDEFS.INC}
procedure Register;

{$IFDEF TMSDOTNET}
{$R TMaskEditEx.bmp}
{$ENDIF}

implementation

procedure Register;
begin
  RegisterComponents('TMS Edits', [TMaskEditEx]);
end;


end.
 
