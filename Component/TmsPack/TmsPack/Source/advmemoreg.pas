{***************************************************************************}
{ TAdvMemo component                                                        }
{ for Delphi & C++Builder                                                   }
{ version 2.0                                                               }
{                                                                           }
{ written by TMS Software                                                   }
{            copyright © 2001 - 2006                                        }
{            Email : info@tmssoftware.com                                   }
{            Web : http://www.tmssoftware.com                               }
{                                                                           }
{ The source code is given as is. The author is not responsible             }
{ for any possible damage done due to the use of this code.                 }
{ The component can be freely used in any application. The complete         }
{ source code remains property of the author and may not be distributed,    }
{ published, given or sold in any form as such. No parts of the source      }
{ code can be included in any other component or application without        }
{ written authorization of TMS software.                                    }
{***************************************************************************}

unit AdvMemoReg;

interface

{$I TMSDEFS.INC}

{$IFDEF TMSDOTNET}
{$R TAdvMemo.bmp}
{$R TAdvMemoSource.bmp}
{$R TDBAdvMemo.bmp}
{$R TAdvHTMLMemoStyler.bmp}
{$R TAdvJSMemoStyler.bmp}
{$R TAdvWebMemoStyler.bmp}
{$R TAdvPascalMemoStyler.bmp}
{$R TAdvBasicMemoStyler.bmp}
{$R TAdvCSSMemoStyler.bmp}
{$R TAdvINIMemoStyler.bmp}
{$R TAdvXMLMemoStyler.bmp}
{$R TAdvCSharpMemoStyler.bmp}
{$R TAdvSQLMemoStyler.bmp}
{$R TAdvPhytonMemoStyler.bmp}
{$R TAdvPerlMemoStyler.bmp}
{$R TAdvEmoticonMemoStyler.bmp}
{$R TAdvMemoFindDialog.bmp}
{$R TAdvMemoFindReplaceDialog.bmp}
{$R TAdvMemoStylerManager.bmp}
{$R TAdvMemoCapitalChecker.bmp}
{$R TAdvCodeList.bmp}
{$ENDIF}


uses
  Classes,
  AdvMemo,
  AdvmCSS,
  AdvmPS,
  AdvmBS,
  AdvmWS,
  AdvmSQLS,
  AdvmCSHS,
  AdvmPYS,
  AdvmPLS,
  AdvmES,
  AdvmINIS,
  AdvmXML,
  AdvmPHP,
  AdvCodeList,
  AdvMemoStylerManager
  {$IFNDEF TMSPERSONAL}
  , DBAdvMemo
  {$ENDIF}
  ;




procedure Register;

implementation

uses
  ActnList;                                            

procedure Register;
begin
  //property editors

  RegisterComponents('TMS Memo', [TAdvMemo,TAdvMemoSource,
{$IFNDEF TMSPERSONAL}
                                  TDBAdvMemo,
{$ENDIF}
                                  TAdvHTMLMemoStyler,
                                  TAdvJSMemoStyler,
                                  TAdvWebMemoStyler,
                                  TAdvPascalMemoStyler,
                                  TAdvBasicMemoStyler,
                                  TAdvCSSMemoStyler,
                                  TAdvCSharpMemoStyler,
                                  TAdvSQLMemoStyler,
                                  TAdvPythonMemoStyler,
                                  TAdvPerlMemoStyler,
                                  TAdvEmoticonMemoStyler,
                                  TAdvMemoFindDialog,
                                  TAdvMemoFindReplaceDialog,
                                  TAdvCodeList,
                                  TAdvMemoStylerManager,
                                  TAdvINIMemoStyler,
                                  TAdvXMLMemoStyler,                                  
                                  TAdvMemoCapitalChecker,
                                  TAdvPHPMemoStyler]);


  RegisterActions('AdvMemo', [TAdvMemoCut, TAdvMemoCopy, TAdvMemoPaste,
    TAdvMemoDelete, TAdvMemoUndo, TAdvMemoRedo, TAdvMemoSelectAll], nil);
end;

end.
