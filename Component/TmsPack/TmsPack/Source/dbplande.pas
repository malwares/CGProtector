{$I TMSDEFS.INC}
{**************************************************************************}
{ TDBPLANNER DESIGN TIME EDITOR                                            }
{ for Delphi & C++Builder                                                  }
{ version 1.3                                                              }
{                                                                          }
{ written by TMS Software                                                  }
{            copyright © 2001 - 2004                                       }
{            Email : info@tmssoftware.com                                  }
{            Web : http://www.tmssoftware.com                              }
{                                                                          }
{ The source code is given as is. The author is not responsible            }
{ for any possible damage done due to the use of this code.                }
{ The component can be freely used in any application. The complete        }
{ source code remains property of the author and may not be distributed,   }
{ published, given or sold in any form as such. No parts of the source     }
{ code can be included in any other component or application without       }
{ written authorization of the author.                                     }
{**************************************************************************}

unit dbplande;

interface

uses
  Classes, DBPlanner, DB,
{$IFDEF TMSDOTNET}
  Borland.VCL.Design.DesignIntf, Borland.VCL.Design.DesignEditors
{$ENDIF}
{$IFNDEF TMSDOTNET}
{$IFDEF DELPHI6_LVL}
  DesignIntf, DesignEditors
{$ELSE}
  DsgnIntf
{$ENDIF}
{$ENDIF}
  ;

type
  TPlannerFieldNameProperty = class(TStringProperty)
  public
    function GetAttributes:TPropertyAttributes; override;
    procedure GetValues(Proc:TGetStrProc); override;
  end;

implementation

function TPlannerFieldNameProperty.GetAttributes: TPropertyAttributes;
begin
  Result := [paValueList,paSortList];
end;

procedure TPlannerFieldNameProperty.GetValues(Proc:TGetStrProc);
var
  FDBItemSource: TDBItemSource;
  FDataSource: TDataSource;
  FDataSet: TDataSet;
  st: TStringList;
  i: Integer;
begin
  FDBItemSource := (GetComponent(0) as TDBItemSource);
  FDataSource := FDBItemSource.DataSource;
  if not Assigned(fDataSource) then Exit;
  FDataSet := FDataSource.DataSet;

  if not Assigned(FDataSet) then Exit;

  st := TStringList.Create;
  FDataSet.GetFieldNames(st);
  for i := 1 to st.Count do Proc(st.Strings[i - 1]);
  st.Free;
end;

end.

