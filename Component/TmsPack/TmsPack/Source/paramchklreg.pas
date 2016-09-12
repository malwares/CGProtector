{********************************************************************}
{ TPARAMCHECKLIST component                                          }
{ for Delphi & C++Builder                                            }
{ version 1.2                                                        }
{                                                                    }
{ written by TMS Software                                            }
{            copyright © 2000 - 2004                                 }
{            Email : info@tmssoftware.com                            }
{            Web : http://www.tmssoftware.com                        }
{********************************************************************}

unit paramchklreg;
{$I TMSDEFS.INC}
interface

uses
  Paramchklist, Classes;

{$IFDEF TMSDOTNET}
{$R TParamCheckList.bmp}
{$ENDIF}

procedure Register;

implementation

procedure Register;
begin
  RegisterComponents('TMS Param', [TParamCheckList]);
end;

end.

