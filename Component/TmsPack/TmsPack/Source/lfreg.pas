{********************************************************************
TLAYEREDFORM component
for Delphi 3.0, 4.0, 5.0 & C++Builder 3.0, 4.0, 5.0
version 1.0

written by TMS Software
           copyright © 2000
           Email : info@tmssoftware.com
           Web : http://www.tmssoftware.com
{********************************************************************}

unit lfreg;

{$I TMSDEFS.INC}
interface

uses
 layeredform,classes;

{$IFDEF TMSDOTNET}
{$R TLayeredForm.bmp}
{$ENDIF}

procedure Register;

implementation

procedure Register;
begin
 RegisterComponents('TMS', [TLayeredForm]);
end;



end.

