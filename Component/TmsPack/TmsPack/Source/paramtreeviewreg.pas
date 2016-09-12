{********************************************************************}
{ TPARAMTREEVIEW component                                           }
{ for Delphi & C++Builder                                            }
{ version 1.0                                                        }
{                                                                    }
{ Written by                                                         }
{   TMS Software                                                     }
{   Copyright © 2000-2004                                            }
{   Email : info@tmssoftware.com                                     }
{   Web : http://www.tmssoftware.com                                 }
{********************************************************************}

unit paramtreeviewreg;

{$I TMSDEFS.INC}
interface

uses
  ParamTreeview, Classes;

{$IFDEF TMSDOTNET}
{$R TParamTreeview.bmp}
{$ENDIF}

procedure Register;

implementation

procedure Register;
begin
  RegisterComponents('TMS Param', [TParamTreeview]);
end;



end.

