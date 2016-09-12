{********************************************************************}
{ TAdvTreeComboBox component                                         }
{ for Delphi & C++Builder                                            }
{ version 1.0                                                        }
{                                                                    }
{ written by TMS Software                                            }
{            copyright © 2003                                        }
{            Email : info@tmssoftware.com                            }
{            Web : http://www.tmssoftware.com                        }
{                -                                                   }
{ The source code is given as is. The author is not responsible      }
{ for any possible damage done due to the use of this code.          }
{ The component can be freely used in any application. The source    }
{ code remains property of the author and may not be distributed     }
{ freely as such.                                                    }
{********************************************************************}

unit AdvTreeComboBoxRegDE;

interface

{$I TMSDEFS.INC}

uses
  Classes, AdvTreeComboBox, AdvTreeComboboxDE
{$IFDEF DELPHI6_LVL}
  {$IFNDEF TMSDOTNET}
  , DesignIntf, DesignEditors
  {$ENDIF}
  {$IFDEF TMSDOTNET}
  , Borland.Vcl.Design.DesignIntf, Borland.Vcl.Design.DesignEditors
  {$ENDIF}

  {$ELSE}
  , DsgnIntf
{$ENDIF}
  ;
  
procedure Register;

implementation

procedure Register;
begin
  RegisterComponentEditor(TAdvTreeComboBox,TAdvTreeComboBoxEditor);
end;


end.
