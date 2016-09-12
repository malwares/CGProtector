{*********************************************************************}
{ TTreeList component                                                 }
{ for Delphi & C++Builder                                             }
{ version 1.0.x.x                                                     }
{                                                                     }
{ written by TMS Software                                             }
{            copyright © 1996-2006                                    }
{            Email : info@tmssoftware.com                             }
{            Web : http://www.tmssoftware.com                         }
{*********************************************************************}

unit tlreg;

{$I TMSDEFS.INC}
interface

uses
 treelist,classes;

{$IFDEF TMSDOTNET}
{$R TTreeList.bmp}
{$ENDIF}

procedure Register;

implementation

procedure Register;
begin
  RegisterComponents('TMS', [TTreeList]);
end;

end.

