unit ImageEditor;

interface

uses
  Windows, Messages, SysUtils, Classes, Graphics, Controls, Forms, Dialogs,
  ExtCtrls, StdCtrls, Buttons, Spin, bsPropertyEditor, bsLoupe,
  bsSkinBoxCtrls, bsSkinCtrls, BusinessSkinForm;


type
  TIEFrm = class(TForm)
    Panel1: TbsSkinPanel;
    Panel4: TbsSkinPanel;
    Panel5: TbsSkinPanel;
    LBX: TbsSkinStdLabel;
    LbY: TbsSkinStdLabel;
    Label1: TbsSkinStdLabel;
    bsLoupe1: TbsLoupe;
    X1Edit: TbsSkinSpinEdit;
    Y1Edit: TbsSkinSpinEdit;
    X2Edit: TbsSkinSpinEdit;
    Y2Edit: TbsSkinSpinEdit;
    ZoomEdit: TbsSkinSpinEdit;
    Splitter1: TbsSkinSplitter;
    Splitter2: TbsSkinSplitter;
    bsSkinButton1: TbsSkinButton;
    bsSkinButton2: TbsSkinButton;
    bsBusinessSkinForm1: TbsBusinessSkinForm;
    bsSkinSpeedButton1: TbsSkinSpeedButton;
    bsSkinSpeedButton2: TbsSkinSpeedButton;
    bsSkinSpeedButton3: TbsSkinSpeedButton;
    bsSkinPanel1: TbsSkinPanel;
    PBox: TbsSkinViewer;
    procedure PBox1MouseDown(Sender: TObject; Button: TMouseButton;
      Shift: TShiftState; X, Y: Integer);
    procedure PBox1MouseMove(Sender: TObject; Shift: TShiftState; X,
      Y: Integer);
    procedure PBox1MouseUp(Sender: TObject; Button: TMouseButton;
      Shift: TShiftState; X, Y: Integer);
    procedure PBox1Paint(Sender: TObject);
    procedure FormShow(Sender: TObject);
    procedure FormClose(Sender: TObject; var Action: TCloseAction);
    procedure FormCreate(Sender: TObject);
    procedure ZoomEditChange(Sender: TObject);
    procedure FormResize(Sender: TObject);
    procedure X1EditChange(Sender: TObject);
    procedure Y1EditChange(Sender: TObject);
    procedure X2EditChange(Sender: TObject);
    procedure Y2EditChange(Sender: TObject);
    procedure PBoxMouseDown(Sender: TObject; Button: TMouseButton;
      Shift: TShiftState; X, Y: Integer);
    procedure PBoxMouseMove(Sender: TObject; Shift: TShiftState; X,
      Y: Integer);
    procedure PBoxMouseUp(Sender: TObject; Button: TMouseButton;
      Shift: TShiftState; X, Y: Integer);
    procedure PBoxPaint(Sender: TObject);
    procedure bsSkinButton1Click(Sender: TObject);
    procedure bsSkinButton2Click(Sender: TObject);
    procedure bsSkinSpeedButton1Click(Sender: TObject);
    procedure bsSkinSpeedButton3Click(Sender: TObject);
  private
    { Private declarations }
    IsGetRect: Boolean;
    B: TBitMap;
    ResultRect: TRect;
    ResultPoint: TPoint;
    FProperty: TbsProperty;
    FPoint: TPoint;
    FRect: TRect;
    FStopChange: Boolean;
    procedure PaintRect(X1, Y1, X2, Y2: Integer);
    procedure PaintCursor(X, Y: Integer);
    procedure ExecuteAsGetPoint(AB: TBitMap; P: TbsProperty);
    procedure ExecuteAsGetRect(AB: TBitMap; P: TbsProperty);
  public
    { Public declarations }
  end;


var
  IEFrm: TIEFrm;

  procedure ExecuteAsGetRect(AB: TBitMap; P: TbsProperty);
  procedure ExecuteAsGetPoint(AB: TBitMap; P: TbsProperty);

implementation

{$R *.DFM}
uses
  SkinBuild;
  
var
  Down: Boolean;
  X1, Y1, X2, Y2: Integer;

procedure ExecuteAsGetRect;
begin
  if AB = nil
  then
    begin
      P.Value := '0,0,0,0';
      Exit;
    end;
  IEFrm.Caption := 'Rect';
  IEFrm.ExecuteAsGetRect(AB, P);
  IEFrm.ShowModal;
end;

procedure ExecuteAsGetPoint;
begin
  if AB = nil
  then
    begin
      P.Value := '0,0';
      Exit;
    end;
  IEFrm.Caption := 'Point';
  IEFrm.ExecuteAsGetPoint(AB, P);
  IEFrm.ShowModal;
end;

procedure TIEFrm.PBox1MouseDown(Sender: TObject; Button: TMouseButton;
  Shift: TShiftState; X, Y: Integer);
begin
  Down := True;
  FStopChange := True;
  X1 := X;
  Y1 := Y;
  X1Edit.Value := X;
  Y1Edit.Value := Y;
  if IsGetRect
  then
    begin
      X2Edit.Value := X;
      Y2Edit.Value := Y;
      PaintCursor(X1, Y1);
      X2 := X;
      Y2 := Y;
      PaintRect(ResultRect.Left, ResultRect.Top,
                ResultRect.Right, ResultRect.Bottom);
      ResultRect := Rect(X1, Y1, X2, Y2);
    end
  else
    begin
      PaintCursor(ResultPoint.X, ResultPoint.Y);
      ResultPoint.X := X1;
      ResultPoint.Y := Y1;
    end;
end;

procedure TIEFrm.PBox1MouseMove(Sender: TObject; Shift: TShiftState; X,
  Y: Integer);
begin
  LBX.Caption := 'X: ' + IntToStr(X);
  LBY.Caption := 'Y: ' + IntToStr(Y);
  if IsGetRect and Down
  then
    begin
      X2Edit.Value := X;
      Y2Edit.Value := Y;
      PaintRect(X1, Y1, X2, Y2);
      PaintRect(X1, Y1, X, Y);
      X2 := X;
      Y2 := Y;
      ResultRect := Rect(X1, Y1, X2, Y2);
    end
  else
    begin
      PaintCursor(X1, Y1);
      PaintCursor(X, Y);
      X1 := X;
      Y1 := Y;
    end;
end;

procedure TIEFrm.PBox1MouseUp(Sender: TObject; Button: TMouseButton;
  Shift: TShiftState; X, Y: Integer);
begin
  Down := False;
  FStopChange := False;
  if IsGetRect
  then
    PaintCursor(X1, Y1)
  else
    PaintCursor(ResultPoint.X, ResultPoint.Y);
end;

procedure TIEFrm.PaintCursor(X, Y: Integer);
begin
  with PBox.Canvas do
  begin
    Brush.Style := bsClear;
    Pen.Color := clBlack;
    Pen.Style := psDot;
    Pen.Mode := pmNot;
    MoveTo(0, Y); LineTo(X, Y);
    MoveTo(X, 0); LineTo(X, Y);
    MoveTo(PBox.Width, Y); LineTo(X, Y);
    MoveTo(X, PBox.Height); LineTo(X, Y);
    Pen.Style := psSolid;
  end;
end;

procedure TIEFrm.PaintRect;
begin
  with PBox.Canvas do
  begin
    Brush.Style := bsClear;
    Pen.Color := clBlack;
    Pen.Style := psDot;
    Pen.Mode := pmNot;
    Rectangle(X1, Y1, X2, Y2);
    Pen.Style := psSolid;
  end;
end;

procedure TIEFrm.PBox1Paint(Sender: TObject);
begin
  PBox.Width := B.Width;
  PBox.Height := B.Height;
  PBox.Canvas.Draw(0, 0, B);
  if IsGetRect
  then
    PaintRect(ResultRect.Left, ResultRect.Top,
              ResultRect.Right, ResultRect.Bottom)
  else
    PaintCursor(ResultPoint.X, ResultPoint.Y);
  X1 := -1; Y1 := -1;  
end;

procedure TIEFrm.FormShow(Sender: TObject);
begin
  X1 := -1; Y1 := -1;
  X2 := -1; Y2 := -1;
  bsLoupe1.Active := True;
end;

procedure TIEFrm.ExecuteAsGetPoint;
begin
  B := AB;
  PBox.Width := B.Width;
  PBox.Height := B.Height;
  IsGetRect := False;
  X2Edit.Visible := False;
  Y2Edit.Visible := False;
  FProperty := P;
  FPoint := GetPoint(FProperty.Value);
  X1Edit.Value := FPoint.X;
  Y1Edit.Value := FPoint.Y;
  ResultPoint := FPoint;
end;

procedure TIEFrm.ExecuteAsGetRect;
begin
  IsGetRect := True;
  B := AB;
  PBox.Width := B.Width;
  PBox.Height := B.Height;
  X2Edit.Visible := True;
  Y2Edit.Visible := True;
  FProperty := P;
  FRect := GetRect(FProperty.Value);
  X1Edit.Value := FRect.Left;
  Y1Edit.Value := FRect.Top;
  X2Edit.Value := FRect.Right;
  Y2Edit.Value := FRect.Bottom;
  ResultRect := FRect;
end;

procedure TIEFrm.FormClose(Sender: TObject; var Action: TCloseAction);
begin
  if SBForm.TempImage <> nil
  then
    begin
      SBForm.TempImage.Free;
      SBForm.TempImage := nil;
    end;
  bsLoupe1.Active := False;
end;

procedure TIEFrm.FormCreate(Sender: TObject);
begin
  PBox.Cursor := crNone;
  FStopChange := False;
end;

procedure TIEFrm.ZoomEditChange(Sender: TObject);
begin
  bsLoupe1.ZoomLevel := ZoomEdit.Value;
end;

procedure TIEFrm.FormResize(Sender: TObject);
begin
  PBox.RePaint;
end;

procedure TIEFrm.X1EditChange(Sender: TObject);
begin
  if not FStopChange then bsSkinSpeedButton1Click(Self);
end;

procedure TIEFrm.Y1EditChange(Sender: TObject);
begin
  if not FStopChange then bsSkinSpeedButton1Click(Self);
end;

procedure TIEFrm.X2EditChange(Sender: TObject);
begin
  if not FStopChange then bsSkinSpeedButton1Click(Self);
end;

procedure TIEFrm.Y2EditChange(Sender: TObject);
begin
  if not FStopChange then bsSkinSpeedButton1Click(Self);
end;

procedure TIEFrm.PBoxMouseDown(Sender: TObject; Button: TMouseButton;
  Shift: TShiftState; X, Y: Integer);
begin
  Down := True;
  FStopChange := True;
  X1 := X;
  Y1 := Y;
  X1Edit.Value := X;
  Y1Edit.Value := Y;
  if IsGetRect
  then
    begin
      X2Edit.Value := X;
      Y2Edit.Value := Y;
      PaintCursor(X1, Y1);
      X2 := X;
      Y2 := Y;
      PaintRect(ResultRect.Left, ResultRect.Top,
                ResultRect.Right, ResultRect.Bottom);
      ResultRect := Rect(X1, Y1, X2, Y2);
    end
  else
    begin
      PaintCursor(ResultPoint.X, ResultPoint.Y);
      ResultPoint.X := X1;
      ResultPoint.Y := Y1;
    end;
end;

procedure TIEFrm.PBoxMouseMove(Sender: TObject; Shift: TShiftState; X,
  Y: Integer);
begin
  LBX.Caption := 'X: ' + IntToStr(X);
  LBY.Caption := 'Y: ' + IntToStr(Y);
  if IsGetRect and Down
  then
    begin
      X2Edit.Value := X;
      Y2Edit.Value := Y;
      PaintRect(X1, Y1, X2, Y2);
      PaintRect(X1, Y1, X, Y);
      X2 := X;
      Y2 := Y;
      ResultRect := Rect(X1, Y1, X2, Y2);
    end
  else
    begin
      PaintCursor(X1, Y1);
      PaintCursor(X, Y);
      X1 := X;
      Y1 := Y;
    end;
end;

procedure TIEFrm.PBoxMouseUp(Sender: TObject; Button: TMouseButton;
  Shift: TShiftState; X, Y: Integer);
begin
  Down := False;
  FStopChange := False;
  if IsGetRect
  then
    PaintCursor(X1, Y1)
  else
    PaintCursor(ResultPoint.X, ResultPoint.Y);
end;

procedure TIEFrm.PBoxPaint(Sender: TObject);
begin
  PBox.Width := B.Width;
  PBox.Height := B.Height;
  PBox.Canvas.Draw(0, 0, B);
  if IsGetRect
  then
    PaintRect(ResultRect.Left, ResultRect.Top,
              ResultRect.Right, ResultRect.Bottom)
  else
    PaintCursor(ResultPoint.X, ResultPoint.Y);
  X1 := -1; Y1 := -1;
end;

procedure TIEFrm.bsSkinButton1Click(Sender: TObject);
begin
  if IsGetRect
  then
    begin
      FRect := Rect(Round(X1Edit.Value), Round(Y1Edit.Value),
       Round(X2Edit.Value), Round(Y2Edit.Value));
      FProperty.Value := SetRect(FRect);
    end
  else
    begin
      FPoint := Point(Round(X1Edit.Value), Round(Y1Edit.Value));
      FProperty.Value := SetPoint(FPoint);
    end;
  Close;
end;

procedure TIEFrm.bsSkinButton2Click(Sender: TObject);
begin
  Close;
end;

procedure TIEFrm.bsSkinSpeedButton1Click(Sender: TObject);
begin
  X1 := Round(X1Edit.Value);
  Y1 := Round(Y1Edit.Value);
  if IsGetRect
  then
    begin
      X2 := Round(X2Edit.Value);
      Y2 := Round(Y2Edit.Value);
      ResultRect := Rect(X1, Y1, X2, Y2);
    end
  else
    ResultPoint := Point(X1, Y1);
  PBox.Repaint;
end;

procedure TIEFrm.bsSkinSpeedButton3Click(Sender: TObject);
begin
  X1Edit.Value := 0;
  Y1Edit.Value := 0;
  X2Edit.Value := 0;
  Y2Edit.Value := 0;
end;

end.
