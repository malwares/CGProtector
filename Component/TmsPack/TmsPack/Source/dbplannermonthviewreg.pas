{$I TMSDEFS.INC}
{***********************************************************************}
{ TDBPlannerMonthView component                                         }
{ for Delphi & C++Builder                                               }
{ version 1.0                                                           }
{                                                                       }
{ written by :                                                          }
{            TMS Software                                               }
{            copyright © 2004                                           }
{            Email : info@tmssoftware.com                               }
{            Website : http://www.tmssoftware.com                       }
{                                                                       }
{ The source code is given as is. The author is not responsible         }
{ for any possible damage done due to the use of this code.             }
{ The component can be freely used in any application. The source       }
{ code remains property of the writer and may not be distributed        }
{ freely as such.                                                       }
{***********************************************************************}
unit DBPlannerMonthViewReg;

interface
{$I TMSDEFS.INC}

{$IFDEF TMSDOTNET}
{$R TDBPlannerMonthView.bmp}
{$ENDIF}


uses
  Classes
  , DBPlannerMonthView
  ;
procedure Register;

implementation

procedure Register;
begin
  RegisterComponents('TMS Planner', [TDBPlannerMonthView]);
end;



end.


