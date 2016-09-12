{********************************************************************}
{ TCOLUMNCOMBOBOX component                                          }
{ for Delphi  & C+Builder                                            }
{ version 1.3                                                        }
{                                                                    }
{ written by TMS Software                                            }
{            copyright © 2000-2004                                   }
{            Email : info@tmssoftware.com                            }
{            Web : http://www.tmssoftware.com                        }
{********************************************************************}

unit colcoreg;
{$I TMSDEFS.INC}

interface

uses
 colcombo,classes;

{$IFDEF TMSDOTNET}
{$R TColumnComboBox.bmp}
{$ENDIF}

procedure Register;

implementation

procedure Register;
begin
  RegisterComponents('TMS', [TColumnComboBox]);
end;



end.

