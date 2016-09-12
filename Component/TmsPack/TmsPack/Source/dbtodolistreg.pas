{*************************************************************************}
{ TDBTodoList component                                                   }
{ for Delphi & C++Builder                                                 }
{ version 1.2                                                             }
{                                                                         }
{ written by TMS Software                                                 }
{           copyright © 2001 - 2004                                       }
{           Email : info@tmssoftware.com                                  }
{           Web : http://www.tmssoftware.com                              }
{*************************************************************************}

unit DBTodoListReg;

interface
{$I TMSDEFS.INC}
uses
  DBTodoList, Classes;

{$IFDEF TMSDOTNET}
{$R TDBTodoList.bmp}
{$ENDIF}

procedure Register;

implementation

procedure Register;
begin
  RegisterComponents('TMS Planner',[TDBTodoList]);
end;

end.
 