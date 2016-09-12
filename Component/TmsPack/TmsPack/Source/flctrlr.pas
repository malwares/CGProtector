{********************************************************************}
{ Extended filecontrol components                                    }
{ for Delphi & C++ Builder                                           }
{ version 1.2                                                        }
{                                                                    }
{ written by :                                                       }
{           TMS Software                                             }
{           copyright © 1999-2002                                    }
{           Email : info@tmssoftware.com                             }
{           Website : http://www.tmssoftware.com                     }
{                                                                    }
{ The source code is given as is. The author is not responsible      }
{ for any possible damage done due to the use of this code.          }
{ The component can be freely used in any application. The source    }
{ code remains property of the writer and may not be distributed     }
{freely as such.                                                     }
{********************************************************************}

unit flctrlr;

interface

{$I TMSDEFS.INC}
uses
  Classes, FlCtrlEx;

{$IFDEF TMSDOTNET}
{$R TFileListBoxEx.bmp}
{$R TCheckFileListBoxEx.bmp}
{$R TDirectoryListBoxEx.bmp}
{$R TCheckDirectoryListBoxEx.bmp}
{$R TDriveComboBoxEx.bmp}

{$ENDIF}
procedure Register;

implementation

procedure Register;
begin
  RegisterComponents ( 'TMS', [TFileListBoxEx,
                               TCheckFileListBoxEx,
                               TDirectoryListBoxEx,
                               TCheckDirectoryListBoxEx,
                               TDriveComboBoxEx] );
end;


end.
 
