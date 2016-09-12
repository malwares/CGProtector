{*******************************************************************}
{ TDBADVSTRINGGRID component                                        }
{ for Delphi & C++Builder                                           }
{ version 1.7                                                       }
{                                                                   }
{ written by                                                        }
{    TMS Software                                                   }
{    copyright © 1999-2003                                          }
{    Email : info@tmssoftware.com                                   }
{    Web : http://www.tmssoftware.com                               }
{                                                                   }
{*******************************************************************}

unit dbgregde;

interface

{$I TMSDEFS.INC}

uses
  Classes, DBAdvGrd, DBAsgDE
{$IFNDEF TMSDOTNET}
  , HtmlDE
{$ENDIF}
{$IFDEF DELPHI6_LVL}
  {$IFDEF TMSDOTNET}
  , Borland.Vcl.Design.DesignIntf, Borland.Vcl.Design.DesignEditors
  {$ENDIF}
  {$IFNDEF TMSDOTNET}
  , DesignIntf, DesignEditors, ContNrs
  {$ENDIF}
{$ELSE}
  , DsgnIntf
{$ENDIF}
  ;

procedure Register;

implementation

procedure Register;
begin
  RegisterComponentEditor(TDBAdvStringGrid,TDBAdvStringGridEditor);

  RegisterPropertyEditor(TypeInfo(string),TStringGridField,'FieldName',TSgFieldNameProperty);

  {$IFNDEF TMSDOTNET}
  RegisterPropertyEditor(TypeInfo(TStringList), TDBAdvStringGrid, 'HTMLTemplate', THTMLTextProperty);
  {$ENDIF}
end;

end.
