{********************************************************************}
{ TPARAMLABEL component                                              }
{ for Delphi & C++Builder                                            }
{ version 1.1                                                        }
{                                                                    }
{ written by TMS Software                                            }
{           copyright © 2000 - 2004                                  }
{           Email : info@tmssoftware.com                             }
{           Web : http://www.tmssoftware.com                         }
{********************************************************************}

unit paramlabreg;

{$I TMSDEFS.INC}
interface

uses
  ParamLabel, Classes;

{$IFDEF TMSDOTNET}
{$R TParamLabel.bmp}
{$ENDIF}

procedure Register;

implementation

procedure Register;
begin
  RegisterComponents('TMS Param', [TParamLabel]);
end;



end.

