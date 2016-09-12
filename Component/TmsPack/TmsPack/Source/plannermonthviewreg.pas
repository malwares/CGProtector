{$I TMSDEFS.INC}
{***********************************************************************}
{ TPLANNERMONTHVIEW component                                           }
{ for Delphi & C++Builder                                               }
{ version 1.0                                                           }
{                                                                       }
{ written by :                                                          }
{            TMS Software                                               }
{            copyright © 2004                                           }
{            Email : info@tmssoftware.com                               }
{            Website : http://www.tmssoftware.com                       }
{***********************************************************************}


unit PlannerMonthViewReg;

interface

{$IFDEF TMSDOTNET}
{$R TPlannerMonthView.bmp}
{$ENDIF}

uses
  PlannerMonthView, Classes;

procedure Register;

implementation

procedure Register;
begin
  RegisterComponents('TMS Planner', [TPlannerMonthView]);
end;



end.


