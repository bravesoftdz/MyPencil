{**********************************************************************}
{* ����������� � ����� "OpenGL � �������� Delphi"                     *}
{* ������� �.�. softgl@chat.ru                                        *}
{**********************************************************************}

unit Unit1;

interface

uses
  Windows, Messages, SysUtils, Classes, Graphics, Controls, Forms, Dialogs,
  Menus,
  OpenGL;

type
  TfrmGL = class(TForm)
    MainMenu1: TMainMenu;
    N1: TMenuItem;
    procedure FormCreate(Sender: TObject);
    procedure FormPaint(Sender: TObject);
    procedure FormDestroy(Sender: TObject);
    procedure FormKeyDown(Sender: TObject; var Key: Word;
      Shift: TShiftState);
    procedure FormResize(Sender: TObject);
    procedure N1Click(Sender: TObject);

  private
    DC : HDC;
    hrc: HGLRC;
  public
    mt : Array [0..3, 0..3] of GLfloat;
  end;

var
  frmGL: TfrmGL;

implementation

uses Unit2;

{$R *.DFM}

{=======================================================================
����������� ����}
procedure TfrmGL.FormPaint(Sender: TObject);
begin
 glClear (GL_COLOR_BUFFER_BIT);      // ������� ������ �����

 // ��������� ����� ������ ����
 glBegin(GL_QUADS);
   glVertex3f(1.0, 1.0, 1.0);
   glVertex3f(-1.0, 1.0, 1.0);
   glVertex3f(-1.0, -1.0, 1.0);
   glVertex3f(1.0, -1.0, 1.0);
 glEnd;

 glBegin(GL_QUADS);
   glVertex3f(1.0, 1.0, -1.0);
   glVertex3f(1.0, -1.0, -1.0);
   glVertex3f(-1.0, -1.0, -1.0);
   glVertex3f(-1.0, 1.0, -1.0);
 glEnd;

 glBegin(GL_QUADS);
   glVertex3f(-1.0, 1.0, 1.0);
   glVertex3f(-1.0, 1.0, -1.0);
   glVertex3f(-1.0, -1.0, -1.0);
   glVertex3f(-1.0, -1.0, 1.0);
 glEnd;

 glBegin(GL_QUADS);
   glVertex3f(1.0, 1.0, 1.0);
   glVertex3f(1.0, -1.0, 1.0);
   glVertex3f(1.0, -1.0, -1.0);
   glVertex3f(1.0, 1.0, -1.0);
 glEnd;

 glBegin(GL_QUADS);
   glVertex3f(-1.0, 1.0, -1.0);
   glVertex3f(-1.0, 1.0, 1.0);
   glVertex3f(1.0, 1.0, 1.0);
   glVertex3f(1.0, 1.0, -1.0);
 glEnd;

 glBegin(GL_QUADS);
   glVertex3f(-1.0, -1.0, -1.0);
   glVertex3f(1.0, -1.0, -1.0);
   glVertex3f(1.0, -1.0, 1.0);
   glVertex3f(-1.0, -1.0, 1.0);
 glEnd;

 SwapBuffers(DC);
end;

{=======================================================================
������ �������}
procedure SetDCPixelFormat (hdc : HDC);
var
 pfd : TPixelFormatDescriptor;
 nPixelFormat : Integer;
begin
 FillChar (pfd, SizeOf (pfd), 0);
 pfd.dwFlags  := PFD_DRAW_TO_WINDOW or PFD_SUPPORT_OPENGL or PFD_DOUBLEBUFFER;
 nPixelFormat := ChoosePixelFormat (hdc, @pfd);
 SetPixelFormat (hdc, nPixelFormat, @pfd);
end;

{=======================================================================
�������� �����}
procedure TfrmGL.FormCreate(Sender: TObject);
begin
 DC := GetDC (Handle);
 SetDCPixelFormat(DC);
 hrc := wglCreateContext(DC);
 wglMakeCurrent(DC, hrc);
 glClearColor (0.5, 0.5, 0.75, 1.0); // ���� ����
 glColor3f (1.0, 0.0, 0.5);          // ������� ���� ����������
 glPolygonMode (GL_FRONT_AND_BACK, GL_LINE);
 glGetFloatv (GL_MODELVIEW_MATRIX, @mt); 
end;

{=======================================================================
����� ������ ����������}
procedure TfrmGL.FormDestroy(Sender: TObject);
begin
 wglMakeCurrent(0, 0);
 wglDeleteContext(hrc);
 ReleaseDC (Handle, DC);
 DeleteDC (DC);
end;

procedure TfrmGL.FormKeyDown(Sender: TObject; var Key: Word;
  Shift: TShiftState);
begin
 If Key = VK_ESCAPE then Close;
end;

procedure TfrmGL.FormResize(Sender: TObject);
begin
 glViewport(0, 0, ClientWidth, ClientHeight);
 glLoadMatrixf (@mt);
 glFrustum (-1, 1, -1, 1, 3, 10); // ������ �����������
 // ���� �������� ����� ��� �������� �����������
 glTranslatef(0.0, 0.0, -8.0);   // ������� ������� - ��� Z
 glRotatef(30.0, 1.0, 0.0, 0.0); // ������� ������� - ��� X
 glRotatef(70.0, 0.0, 1.0, 0.0); // ������� ������� - ��� Y

 InvalidateRect(Handle, nil, False);
end;

procedure TfrmGL.N1Click(Sender: TObject);
begin
  With Form2 do begin
    edt00.Text := FloatToStr (mt [0, 0]);
    edt01.Text := FloatToStr (mt [0, 1]);
    edt02.Text := FloatToStr (mt [0, 2]);
    edt03.Text := FloatToStr (mt [0, 3]);
    edt10.Text := FloatToStr (mt [1, 0]);
    edt11.Text := FloatToStr (mt [1, 1]);
    edt12.Text := FloatToStr (mt [1, 2]);
    edt13.Text := FloatToStr (mt [1, 3]);
    edt20.Text := FloatToStr (mt [2, 0]);
    edt21.Text := FloatToStr (mt [2, 1]);
    edt22.Text := FloatToStr (mt [2, 2]);
    edt23.Text := FloatToStr (mt [2, 3]);
    edt30.Text := FloatToStr (mt [3, 0]);
    edt31.Text := FloatToStr (mt [3, 1]);
    edt32.Text := FloatToStr (mt [3, 2]);
    edt33.Text := FloatToStr (mt [3, 3]);
    Show;
  end;
end;

end.

