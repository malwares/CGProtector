{***************************************************************************}
{ THTMListbox component                                                     }
{ for Delphi & C++Builder                                                   }
{ version 1.8                                                               }
{                                                                           }
{ Copyright © 2001 - 2004                                                   }
{   TMS Software                                                            }
{   Email : info@tmssoftware.com                                            }
{   Web : http://www.tmssoftware.com                                        }
{                                                                           }
{ The source code is given as is. The author is not responsible             }
{ for any possible damage done due to the use of this code.                 }
{ The component can be freely used in any application. The complete         }
{ source code remains property of the author and may not be distributed,    }
{ published, given or sold in any form as such. No parts of the source      }
{ code can be included in any other component or application without        }
{ written authorization of the author.                                      }
{***************************************************************************}

unit htmlireg;

{$I TMSDEFS.INC}
interface

uses
  Classes, HtmListb;

{$IFDEF TMSDOTNET}
{$R THTMListBox.bmp}
{$ENDIF}

procedure Register;

implementation

procedure Register;
begin
  RegisterComponents('TMS HTML',[THTMListbox]);
end;

end.

