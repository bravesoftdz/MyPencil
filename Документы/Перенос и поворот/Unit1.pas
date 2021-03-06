unit Unit1;

interface

uses
  Windows, Messages, SysUtils, Variants, Classes, Graphics, Controls, Forms,
  Dialogs, StdCtrls, ExtCtrls;

type
  TselectState = (ssSelect, ssUnselect, ssMove);
  TForm1 = class(TForm)
    Image1: TImage;
    Button1: TButton;
    procedure FormCreate(Sender: TObject);
    procedure FormDestroy(Sender: TObject);
    procedure Button1Click(Sender: TObject);
    procedure Image1MouseMove(Sender: TObject; Shift: TShiftState; X,
      Y: Integer);
    procedure Image1MouseUp(Sender: TObject; Button: TMouseButton;
      Shift: TShiftState; X, Y: Integer);
  private
    { Private declarations }
  public
    { Public declarations }
  end;

var
  Form1: TForm1;
  Bitmap1: TBitmap;
  SelectImage: TBitmap;
  aSelectState: TselectState;
  fOldX, FOldY: Integer;
  FOldX1, FOldY1: Integer;
  First: Boolean;

implementation

{$R *.dfm}

procedure TForm1.Button1Click(Sender: TObject);
begin
  if (aSelectState =ssSelect )then
    aSelectState :=ssUnselect
  else
    aSelectState :=ssSelect;
end;

procedure TForm1.FormCreate(Sender: TObject);
begin
  Bitmap1 := TBitmap.Create;
  SelectImage := TBitmap.Create;
  Bitmap1.SetSize(500,600);
  SelectImage.SetSize(500,600);
  aSelectState := ssSelect;
  First := True;
end;

procedure TForm1.FormDestroy(Sender: TObject);
begin
  Bitmap1.Free;
  SelectImage.Free;
end;

procedure TForm1.Image1MouseMove(Sender: TObject; Shift: TShiftState; X,
  Y: Integer);
begin
  if ssLeft in Shift then begin
    if  First then begin
       fOldX := X;
       fOldY := Y;
       First := False;
    end;

    SelectImage.Canvas.Rectangle(-1,-1, 501,601);
    SelectImage.Canvas.Pen.Style := psDash;
    SelectImage.Canvas.Rectangle(fOldX, FOldY, X,Y);
    SelectImage.Canvas.Pen.Style := psDot;
    SelectImage.Canvas.Ellipse(X-5,Y-5,X+5,Y+5);

    Image1.Canvas.Draw(0, 0, SelectImage);
  end;

  if ((fOldX > X)and (FOldY > Y) and (FOldX1 < X) and (FOldY1 < Y)
    and (ssLeft in Shift) and(aSelectState = ssMove)) then begin
     Image1.Canvas.CopyRect(Rect(fOldX, FOldY, fOldX1, FOldY1),);

  end;


end;

procedure TForm1.Image1MouseUp(Sender: TObject; Button: TMouseButton;
  Shift: TShiftState; X, Y: Integer);
begin
  First := True;
  if ssLeft in Shift then begin
    FOldX1 := X;
    FOldY1 := Y;
     aSelectState :=ssMove;
  end;

end;

end.
