{********************************************************************}
{ THTMLButtons components                                            }
{ for Delphi & C++Builder                                            }
{ version 1.2                                                        }
{                                                                    }
{ written by TMS Software                                            }
{            copyright © 1999 - 2004                                 }
{            Email : info@tmssoftware.com                            }
{            Web : http://www.tmssoftware.com                        }
{********************************************************************}

unit htmbureg;
{$I TMSDEFS.INC}
interface

uses
  Classes, htmlbtns;

{$IFDEF TMSDOTNET}
{$R THTMLRadioButton.bmp}
{$R THTMLCheckBox.bmp}
{$R THTMLButton.bmp}
{$R THTMLRadioGroup.bmp}
{$R THTMLCheckGroup.bmp}
{$ENDIF}

procedure Register;

implementation

procedure Register;
begin
  RegisterComponents('TMS HTML', [THTMLRadioButton,THTMLCheckbox,THTMLButton,THTMLRadioGroup,THTMLCheckGroup]);
end;

end.

