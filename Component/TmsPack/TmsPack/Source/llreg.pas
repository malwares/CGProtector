{********************************************************************
TLISTLINK component
for Delphi 2.0,3.0,4.0,5.0 & C++Builder 1.0,3.0,4.0,5.0
version 1.2

written by TMS Software
           copyright © 1998-2000
           Email : info@tmssoftware.com
           Web : http://www.tmssoftware.com
{********************************************************************}

unit llreg;

{$I TMSDEFS.INC}
interface

uses
 listlink,classes;

{$IFDEF TMSDOTNET}
{$R TListLink.bmp}
{$ENDIF}

procedure Register;

implementation

procedure Register;
begin
 RegisterComponents('TMS', [TListLink]);
end;



end.

