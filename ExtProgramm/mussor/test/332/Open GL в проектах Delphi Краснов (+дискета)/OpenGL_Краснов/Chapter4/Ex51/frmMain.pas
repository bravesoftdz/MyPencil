{**********************************************************************}
{* ����������� � ����� "OpenGL � �������� Delphi"                     *}
{* ������� �.�. softgl@chat.ru                                        *}
{**********************************************************************}

{/*
 *  multialphablend.c
 *  Celeste Fowler, 1997
 *
 *  An example of using alpha-blending to render multiple transparent
 *  objects (with sorting).
 *
 */}

unit frmMain;

interface

uses
  Windows, Messages, SysUtils, Classes, Graphics, Controls, Forms, Dialogs,
  ExtCtrls, OpenGL;

type
  TfrmGL = class(TForm)
    procedure FormCreate(Sender: TObject);
    procedure FormResize(Sender: TObject);
    procedure FormDestroy(Sender: TObject);
    procedure FormKeyDown(Sender: TObject; var Key: Word;
      Shift: TShiftState);

  private
    DC: HDC;
    hrc: HGLRC;

    cone, base, qsphere : GLUquadricObj;
    procedure draw_cone;
    procedure draw_sphere(angle : GLdouble);
    procedure SetDCPixelFormat;
    procedure Init;
  protected
    procedure WMPaint(var Msg: TWMPaint); message WM_PAINT;
  end;

var
  frmGL: TfrmGL;
  Angle : GLint = 0;

implementation

uses DGLUT;

{$R *.DFM}


procedure TfrmGL.Init;
const
    lightpos : Array [0..3] of GLfloat = (0.5, 0.75, 1.5, 1.0);
begin
    glEnable(GL_DEPTH_TEST);
    glEnable(GL_LIGHTING);
    glEnable(GL_LIGHT0);

    glLightfv(GL_LIGHT0, GL_POSITION, @lightpos);

    cone := gluNewQuadric;
    base := gluNewQuadric;
    qsphere := gluNewQuadric;

    glBlendFunc(GL_SRC_ALPHA, GL_ONE_MINUS_SRC_ALPHA);
end;

procedure draw_room;
const
    //* material for the walls, floor, ceiling */
    wall_mat : Array [0..3] of GLfloat = (1.0, 1.0, 1.0, 1.0);
begin
    glMaterialfv(GL_FRONT, GL_AMBIENT_AND_DIFFUSE, @wall_mat);

    glBegin(GL_QUADS);

    //* floor */
    glNormal3f(0, 1, 0);
    glVertex3f(-1, -1, 1);
    glVertex3f(1, -1, 1);
    glVertex3f(1, -1, -1);
    glVertex3f(-1, -1, -1);

    //* ceiling */
    glNormal3f(0, -1, 0);
    glVertex3f(-1, 1, -1);
    glVertex3f(1, 1, -1);
    glVertex3f(1, 1, 1);
    glVertex3f(-1, 1, 1);

    //* left wall */
    glNormal3f(1, 0, 0);
    glVertex3f(-1, -1, -1);
    glVertex3f(-1, -1, 1);
    glVertex3f(-1, 1, 1);
    glVertex3f(-1, 1, -1);

    //* right wall */
    glNormal3f(-1, 0, 0);
    glVertex3f(1, 1, -1);
    glVertex3f(1, 1, 1);
    glVertex3f(1, -1, 1);
    glVertex3f(1, -1, -1);

    //* far wall */
    glNormal3f(0, 0, 1);
    glVertex3f(-1, -1, -1);
    glVertex3f(1, -1, -1);
    glVertex3f(1, 1, -1);
    glVertex3f(-1, 1, -1);

    glEnd();
end;

procedure TfrmGL.draw_cone;
const
    cone_mat : Array [0..3] of GLfloat = (0.0, 0.5, 1.0, 0.5);
begin
    glPushMatrix();
    glTranslatef(0, -1, 0);
    glRotatef(-90, 1, 0, 0);

    glMaterialfv(GL_FRONT, GL_AMBIENT_AND_DIFFUSE, @cone_mat);

    //* base is coplanar with floor, so turn off depth testing */
    glDisable(GL_DEPTH_TEST);
    gluDisk(base, 0.0, 0.3, 20, 1);
    glEnable(GL_DEPTH_TEST);

    gluCylinder(cone, 0.3, 0, 1.25, 20, 1);

    glPopMatrix();
end;

procedure TfrmGL.draw_sphere(angle : GLdouble);
const
    sphere_mat : Array [0..3] of GLfloat = (1.0, 0.5, 0.0, 0.5);
begin
    glPushMatrix();
    glTranslatef(0, -0.3, 0);
    glRotatef(angle, 0, 1, 0);
    glTranslatef(0, 0, 0.6);

    glMaterialfv(GL_FRONT, GL_AMBIENT_AND_DIFFUSE, @sphere_mat);
    gluSphere(qsphere, 0.3, 20, 20);

    glPopMatrix();
end;


procedure TfrmGL.SetDCPixelFormat;
var
  nPixelFormat: Integer;
  pfd: TPixelFormatDescriptor;
begin
  FillChar(pfd, SizeOf(pfd), 0);

  pfd.dwFlags := PFD_DRAW_TO_WINDOW or PFD_SUPPORT_OPENGL or
                 PFD_DOUBLEBUFFER;

  nPixelFormat := ChoosePixelFormat(DC, @pfd);
  SetPixelFormat(DC, nPixelFormat, @pfd);
end;

procedure TfrmGL.FormCreate(Sender: TObject);
begin
  DC := GetDC(Handle);
  SetDCPixelFormat;
  hrc := wglCreateContext(DC);
  wglMakeCurrent(DC, hrc);
  Init;
end;

procedure TfrmGL.FormResize(Sender: TObject);
begin
  glViewport(0, 0, ClientWidth, ClientHeight);
  glMatrixMode(GL_PROJECTION);
  glLoadIdentity;
  gluPerspective(60, 1, 0.01, 10);
  gluLookAt(0, 0, 2.577, 0, 0, -5, 0, 1, 0);

  glMatrixMode(GL_MODELVIEW);
  glLoadIdentity;

  InvalidateRect(Handle, nil, False);
end;

procedure TfrmGL.WMPaint(var Msg: TWMPaint);
var
  ps : TPaintStruct;
begin
  BeginPaint(Handle, ps);
    glClear(GL_COLOR_BUFFER_BIT or GL_DEPTH_BUFFER_BIT);

    draw_room;

    glEnable(GL_BLEND);
    glEnable(GL_CULL_FACE);
    If Angle < 180 then begin
      //* sphere behind cone */
      glCullFace(GL_FRONT);
      draw_sphere(Angle + 45.0);
      draw_cone();
      glCullFace(GL_BACK);
      draw_sphere(Angle + 45.0);
      draw_cone();
      end
      else begin
      //* cone behind sphere */
      glCullFace(GL_FRONT);
      draw_cone();
      draw_sphere(Angle + 45.0);
      glCullFace(GL_BACK);
      draw_cone();
      draw_sphere(Angle + 45.0);
    end;
    glDisable(GL_CULL_FACE);
    glDisable(GL_BLEND);

  SwapBuffers(DC);

  EndPaint(Handle, ps);

  Angle := (Angle + 2) mod 360;
  InvalidateRect(Handle, nil, False);
end;

procedure TfrmGL.FormDestroy(Sender: TObject);
begin
  gluDeleteQuadric (cone);
  gluDeleteQuadric (base);
  gluDeleteQuadric (qsphere);
  wglMakeCurrent(0, 0);
  wglDeleteContext(hrc);
  ReleaseDC(Handle, DC);
  DeleteDC (DC);
end;

procedure TfrmGL.FormKeyDown(Sender: TObject; var Key: Word;
  Shift: TShiftState);
begin
 If Key = VK_ESCAPE then Close;
end;

end.

