unit selectcolorpic;

interface

uses
  Windows, Messages, SysUtils, Classes, Graphics, Controls, Forms, Dialogs,
  ExtCtrls, StdCtrls, Buttons, bsPropertyEditor, bsSkinCtrls,
  BusinessSkinForm;

type
  TSelColorPicForm = class(TForm)
    Panel1: TbsSkinPanel;
    ShowPicShape: TShape;
    Shape: TShape;
    PBox: TbsSkinViewer;
    bsSkinButton1: TbsSkinButton;
    bsSkinButton2: TbsSkinButton;
    bsBusinessSkinForm1: TbsBusinessSkinForm;
    procedure PBoxPaint(Sender: TObject);
    procedure PBoxMouseDown(Sender: TObject; Button: TMouseButton;
      Shift: TShiftState; X, Y: Integer);
    procedure PBoxMouseMove(Sender: TObject; Shift: TShiftState; X,
      Y: Integer);
    procedure bsSkinButton2Click(Sender: TObject);
    procedure bsSkinButton1Click(Sender: TObject);
  private
    { Private declarations }
  public
    { Public declarations }
    Pic: TBitMap;
  end;

var
  SelColorPicForm: TSelColorPicForm;

  procedure ExecuteColorPicDialog(Apic: TBitMap);

implementation

uses selectcolor, SkinBuild;

{$R *.DFM}

procedure ExecuteColorPicDialog(Apic: TBitMap);
begin
  SelColorPicForm.Pic := Apic;
  SelColorPicForm.ShowModal;
end;


procedure TSelColorPicForm.PBoxPaint(Sender: TObject);
begin
  PBox.Width := Pic.Width;
  PBox.Height := Pic.Height;
  PBox.Canvas.Draw(0, 0, Pic);
end;

procedure TSelColorPicForm.PBoxMouseDown(Sender: TObject;
  Button: TMouseButton; Shift: TShiftState; X, Y: Integer);
begin
  ShowPicShape.Brush.Color := PBox.Canvas.Pixels[X, Y];
end;

procedure TSelColorPicForm.PBoxMouseMove(Sender: TObject;
  Shift: TShiftState; X, Y: Integer);
begin
  Shape.Brush.Color := PBox.Canvas.Pixels[X, Y];
end;

procedure TSelColorPicForm.bsSkinButton2Click(Sender: TObject);
begin
  Close;
end;

procedure TSelColorPicForm.bsSkinButton1Click(Sender: TObject);
begin
  SelectColorForm.ShowShape.Brush.Color := ShowPicShape.Brush.Color;
  Close;
end;

end.
