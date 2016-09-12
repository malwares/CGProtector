{*****************************************************************}
{ TWEBDATA component                                              }
{ for Delphi & C++Builder                                         }
{                                                                 }
{ written by                                                      }
{   TMS Software                                                  }
{   copyright © 1999 - 2007                                       }
{   Email: info@tmssoftware.com                                   }
{   Web: http://www.tmssoftware.com                               }
{*****************************************************************}
unit wdatreg;

interface

uses
  WebData, Classes;

{$IFDEF TMSDOTNET}
{$R TWebData.bmp}
{$ENDIF}


procedure Register;

implementation

procedure Register;
begin
  RegisterComponents('TMS Web',[TWebData]);
end;

end.

