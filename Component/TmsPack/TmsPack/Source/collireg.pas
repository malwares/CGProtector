{********************************************************************}
{ TCOLUMNLISTBOX component                                           }
{ for Delphi & C++Builder                                            }
{ version 1.2                                                        }
{                                                                    }
{ written by TMS Software                                            }
{            copyright © 2000-2004                                   }
{            Email : info@tmssoftware.com                            }
{            Web : http://www.tmssoftware.com                        }
{********************************************************************}

unit collireg;

{$I TMSDEFS.INC}

interface

uses
 collistb,classes;

{$IFDEF TMSDOTNET}
{$R TColumnListBox.bmp}
{$ENDIF}

procedure Register;

implementation

procedure Register;
begin
  RegisterComponents('TMS', [TColumnListBox]);
end;



end.

