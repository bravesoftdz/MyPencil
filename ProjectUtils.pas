unit ProjectUtils;

interface

uses Windows, Sysutils;

function CreateProc(const FileName, Params: string; WindowState: Word): Boolean;

implementation

function CreateProc(const FileName, Params: string; WindowState: Word): Boolean;
var
  SUInfo: TStartupInfo;
  ProcInfo: TProcessInformation;
  CmdLine: string;
begin
  CmdLine := '"' + FileName + '"' + Params;
  FillChar(SUInfo, SizeOf(SUInfo), #0);
  with SUInfo do
  begin
    cb:= SizeOf(SUInfo);
    dwFlags:= CREATE_NO_WINDOW;
    wShowWindow:= WindowState;
  end;

  Result := CreateProcess(nil, PChar(CmdLine), nil, nil, False, CREATE_NEW_PROCESS_GROUP or NORMAL_PRIORITY_CLASS, nil, PChar(ExtractFilePath(FileName)), SUInfo, ProcInfo);
end;

end.
