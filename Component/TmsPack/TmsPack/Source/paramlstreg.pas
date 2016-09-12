{********************************************************************}
{ TPARAMLISTBOX component                                            }
{ for Delphi & C++Builder                                            }
{ version 1.2                                                        }
{                                                                    }
{ written by TMS Software                                            }
{            copyright © 2000 - 2004                                 }
{            Email : info@tmssoftware.com                            }
{            Web : http://www.tmssoftware.com                        }
{********************************************************************}

unit paramlstreg;
{$I TMSDEFS.INC}
interface

uses
  Paramlistbox, Classes;

{$IFDEF TMSDOTNET}
{$R TParamListBox.bmp}
{$ENDIF}

procedure Register;

implementation

procedure Register;
begin
  RegisterComponents('TMS Param', [TParamListBox]);
end;



end.

