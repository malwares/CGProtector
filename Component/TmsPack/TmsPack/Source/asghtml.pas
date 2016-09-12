{********************************************************************}
{ TAdvGridHTMLSettingsDialog component                               }
{ for Delphi & C++Builder                                            }
{ version 1.2                                                        }
{                                                                    }
{ written by    Christopher Sansone, ScholarSoft                     }
{               Web : http://www.meteortech.com/ScholarSoft/         }
{ enhanced by : TMS Software                                         }
{               copyright © 1998-2001                                }
{               Email : info@tmssoftware.com                         }
{               Web : http://www.tmssoftware.com                     }
{********************************************************************}

unit AsgHTML;

{$I TMSDEFS.INC}

interface

uses
  Windows, Messages, SysUtils, Classes, Graphics, Controls, Forms, Dialogs,
  StdCtrls, AdvSpin, AdvGrid, Buttons, shellapi, Mask
  {$IFDEF TMSDOTNET}
  , System.ComponentModel
  {$ENDIF}
  ;

type
  TAdvGridHTMLSettingsForm = class(TForm)
    CellsGroupBox: TGroupBox;
    BorderSizeLabel: TLabel;
    CellSpacingLabel: TLabel;
    TagsGroupBox: TGroupBox;
    PrefixLabel: TLabel;
    SuffixLabel: TLabel;
    TableStyleLabel: TLabel;
    FilesGroupBox: TGroupBox;
    HeaderLabel: TLabel;
    FooterLabel: TLabel;
    GeneralGroupBox: TGroupBox;
    TableColorsCheckBox: TCheckBox;
    TableFontsCheckBox: TCheckBox;
    TableWidthLabel: TLabel;
    BorderSizeSpinEdit: TAdvSpinEdit;
    CellSpacingSpinEdit: TAdvSpinEdit;
    PrefixEdit: TEdit;
    SuffixEdit: TEdit;
    TableStyleEdit: TEdit;
    HeaderEdit: TEdit;
    FooterEdit: TEdit;
    HeaderButton: TButton;
    FooterButton: TButton;
    TableWidthSpinEdit: TAdvSpinEdit;
    OKButton: TBitBtn;
    CancelButton: TBitBtn;
    OpenDialog: TOpenDialog;
    Preview: TButton;
    Label1: TLabel;
    CellPaddingSpinEdit: TAdvSpinEdit;
    ConvertChar: TCheckBox;
    ExportNonBreaking: TCheckBox;
    AutoShow: TCheckBox;
    procedure UpdateControls;
    procedure UpdateSettings;
    procedure HeaderButtonClick(Sender: TObject);
    procedure PreviewClick(Sender: TObject);
  private
    { Private declarations }
  public
    { Public declarations }
    Grid: TAdvStringGrid;
    procedure EnableGroupBox(AGroupBox: TGroupBox; Enable: Boolean);
  end;

  TAdvGridHTMLOption = (hoGeneral, hoCells, hoTags, hoFiles);
  TAdvGridHTMLOptions = set of TAdvGridHTMLOption;

  {$IFNDEF TMSDOTNET}
  TAdvGridHTMLSettingsDialog = class(TCommonDialog)
  {$ENDIF}
  {$IFDEF TMSDOTNET}
  TAdvGridHTMLSettingsDialog = class(TComponent)
  {$ENDIF}
  private
    FGrid: TAdvStringGrid;
    FForm: TAdvGridHTMLSettingsForm;
    FOptions: TAdvGridHTMLOptions;
  protected
    procedure EnableGroupBoxes;
    procedure Notification(AComponent: TComponent; AOperation: TOperation); override;
  public
    constructor Create(AOwner: TComponent); override;
    destructor Destroy; override;
    {$IFDEF TMSDOTNET}
    function Execute: Boolean;// override;
    {$ENDIF}
    {$IFNDEF TMSDOTNET}
    function Execute: Boolean; override;
    {$ENDIF}
    property Form: TAdvGridHTMLSettingsForm read FForm;
  published
    property Grid: TAdvStringGrid read FGrid write FGrid;
    property Options: TAdvGridHTMLOptions read FOptions write FOptions;
  end;


implementation

{$IFDEF TMSDOTNET}
uses
  WinUtils, System.Text;
{$ENDIF}

{$R *.DFM}

procedure TAdvGridHTMLSettingsForm.UpdateControls;
begin
  With Grid.HTMLSettings do begin
    PrefixEdit.Text := PrefixTag;
    SuffixEdit.Text := SuffixTag;
    TableStyleEdit.Text := TableStyle;

    HeaderEdit.Text := HeaderFile;
    FooterEdit.Text := FooterFile;

    BorderSizeSpinEdit.Value := BorderSize;
    CellSpacingSpinEdit.Value := CellSpacing;
    CellPaddingSpinEdit.Value := CellPadding;

    TableWidthSpinEdit.Value := Width;
    TableColorsCheckBox.Checked := SaveColor;
    TableFontsCheckBox.Checked := SaveFonts;

    ConvertChar.Checked := ConvertSpecialChars;
    ExportNonBreaking.Checked := NonBreakingText;
    AutoShow.Checked := AutoPreview;
  end;
end;

procedure TAdvGridHTMLSettingsForm.UpdateSettings;
begin
  with Grid.HTMLSettings do
  begin
    PrefixTag := PrefixEdit.Text;
    SuffixTag := SuffixEdit.Text;
    TableStyle := TableStyleEdit.Text;

    HeaderFile := HeaderEdit.Text;
    FooterFile := FooterEdit.Text;

    BorderSize := BorderSizeSpinEdit.Value;
    CellSpacing := CellSpacingSpinEdit.Value;
    CellPadding := CellPaddingSpinEdit.Value;

    Width := TableWidthSpinEdit.Value;
    SaveColor := TableColorsCheckBox.Checked;
    SaveFonts := TableFontsCheckBox.Checked;

    AutoPreview := AutoShow.Checked;
    ConvertSpecialChars := ConvertChar.Checked;
    NonBreakingText := ExportNonBreaking.Checked;
  end;
end;

procedure TAdvGridHTMLSettingsForm.EnableGroupBox(AGroupBox: TGroupBox;
                                                  Enable: Boolean);
var
  i: integer;
begin
  With AGroupBox do begin
    Enabled := Enable;
    For i := 0 to ControlCount - 1 do
      Controls[i].Enabled := Enable;
  end;
end;

procedure TAdvGridHTMLSettingsForm.HeaderButtonClick(Sender: TObject);
var
  FileEdit: TEdit;
begin
  With OpenDialog do begin
    If Sender = HeaderButton then
      FileEdit := HeaderEdit
    else
      FileEdit := FooterEdit;

    FileName := FileEdit.Text;
    If Execute then
      FileEdit.Text := FileName;
  end;
end;




constructor TAdvGridHTMLSettingsDialog.Create(AOwner: TComponent);
begin
  inherited Create(AOwner);

  FOptions := [hoGeneral, hoCells, hoTags, hoFiles];

  If (csDesigning in ComponentState) then
    FForm := TAdvGridHTMLSettingsForm.Create(Application)
  else
    FForm := TAdvGridHTMLSettingsForm.Create(Self);
end;

function TAdvGridHTMLSettingsDialog.Execute: Boolean;
begin
  If not Assigned(Grid) then begin
    Raise Exception.Create('The dialog does not have a grid component assigned.');
    Result := False;
    Exit;
  end;

  with FForm do
  begin
    Grid := Self.Grid;
    UpdateControls;
    EnableGroupBoxes;

    Result := ShowModal = mrOK;
    if Result then
      UpdateSettings;
  end;
end;

destructor TAdvGridHTMLSettingsDialog.Destroy;
begin
  FForm.Free;
  inherited;
end;

procedure TAdvGridHTMLSettingsDialog.EnableGroupBoxes;
begin
  With FForm do begin
    EnableGroupBox(GeneralGroupBox, hoGeneral in FOptions);
    EnableGroupBox(CellsGroupBox, hoCells in FOptions);
    EnableGroupBox(TagsGroupBox, hoTags in FOptions);
    EnableGroupBox(FilesGroupBox, hoFiles in FOptions);
  end;
end;

procedure TAdvGridHTMLSettingsDialog.Notification(AComponent: TComponent;
  AOperation: TOperation);
begin
 if (aOperation=opRemove) and (aComponent=fGrid) then fGrid:=nil;
 inherited;
end;


procedure TAdvGridHTMLSettingsForm.PreviewClick(Sender: TObject);
var
{$IFNDEF TMSDOTNET}
  buf:array[0..128] of char;
{$ENDIF}
{$IFDEF TMSDOTNET}
  buf: StringBuilder;
{$ENDIF}
begin
  UpdateSettings;

  {$IFNDEF TMSDOTNET}
  GetWindowsDirectory(buf,sizeof(buf));
  strcat(buf,'\TEMP\temp001.htm');
  grid.savetohtml(strpas(buf));
  ShellExecute(0,'open',buf,nil,nil, SW_NORMAL);
  {$ENDIF}

  {$IFDEF TMSDOTNET}
  buf := StringBuilder.Create(255);
  GetWindowsDirectory(buf,255);
  grid.savetohtml(buf.ToString);
  ShellExecute(0,'open',buf.ToString,'','', SW_NORMAL);
  {$ENDIF}


end;


end.
