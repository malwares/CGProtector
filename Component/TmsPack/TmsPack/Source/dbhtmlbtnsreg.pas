{********************************************************************}
{ TDBHTMLCheckBox & TDBHTMLRadioGroup component                      }
{ for Delphi & C++Builder                                            }
{ version 1.0                                                        }
{                                                                    }
{ written by TMS Software                                            }
{            copyright © 1999 - 2004                                 }
{            Email : info@tmssoftware.com                            }
{            Web : http://www.tmssoftware.com                        }
{********************************************************************}

unit DBHTMLBtnsReg;

{$I TMSDEFS.INC}

interface

uses
  Classes, htmlbtns, DBHTMLBtns;

{$IFDEF TMSDOTNET}
{$R TDBHTMLCheckBox.bmp}
{$R TDBHTMLRadioGroup.bmp}
{$ENDIF}

procedure Register;

implementation

procedure Register;
begin
  RegisterComponents('TMS HTML', [TDBHTMLCheckbox, TDBHTMLRadioGroup]);
end;



end.

