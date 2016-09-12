{********************************************************************}
{ TEDITLISTBOX component                                             }
{ for Delphi 3.0,4.0,5.0,6.0 & C++Builder 3.0,4.0,5.0                }
{ version 1.9                                                        }
{                                                                    }
{ written by                                                         }
{   TMS Software                                                     }
{   Copyright © 1998-2001                                            }
{   Email : info@tmssoftware.com                                     }
{   Website : http://www.tmssoftware.com                             }
{********************************************************************}
unit edtlstreg;

interface

{$I TMSDEFS.INC}
uses
  EditList, Classes;

{$IFDEF TMSDOTNET}
{$R TEditListBox.bmp}
{$ENDIF}

procedure Register;

implementation

procedure Register;
begin
  RegisterComponents('TMS Edits', [TEditListBox]);
end;


end.
 
