unit uGlobal;

interface

uses
  Forms, Vcl.Controls, System.Classes, System.SysUtils, Windows;

const
  MSG_BAR_OPEN = 'BAR_OPEN_1';
  MSG_HEARTBEAT = 'LPR_N';
  MSG_OK = 'OK';
  MSG_RF_VAL = 'RF_VAL_';

const
  REG_KEY = 'Software\Nexpa\NPServerDelphi\';

type
  aString = AnsiString;
  wString = WideString;

{$region 'Record'}
type
  TLPRRec = record
    myConLprNo: string;
    imgFile: string;
    carNo: string;
    cTime: string;
    nRecogFlag: string;
    lprName: string;
    myCompName: string;
  end;

type
  TServerSet = packed record
    LPR_HostIP: string;
    LPR_HostPort: Integer;
    TCPServerPort: Integer;
    RetryPeriod: Integer;
    HeartbeatPeriod: Integer;
  end;

  TPolicySet = packed record
    SalesCarNumber: string;
    EmergencyNumber: string;
  end;

  TDBSet = packed record
    ServerIP: string;
    Username: string;
    Password: string;
    DBName: string;
  end;

  TConfigRec = packed record
    ServerSetting: TServerSet;
    PolicySetting: TPolicySet;
    DBSetting: TDBSet;
  end;
{$endregion}

var
  sCurrRunDir: aString;
  ConfigInfo: TConfigRec;
  GetTickXP: Int64Rec;

function GetNow() : String;
procedure NormalLogging(sMsg: aString);
procedure ExceptLogging(sMsg: aString; isStartEnd: boolean=False);
function NextModalDialog(Sender: TForm): Integer;
procedure ClearComponent(AComponent: TComponent);
procedure DelaySleep(pSleepSecs: Cardinal; Flg: Boolean = False);
function GetTickCount64ForXP: Int64; stdcall;

implementation

uses
  DateUtils;


function GetNow() : String;
begin
  Result := FormatDateTime('yyyy-mm-dd hh:nn:ss', Now) + ': ';
end;

procedure NormalLogging(sMsg: aString);
var
  nFile: Integer;
  sFile: aString;
begin
   sFile := sCurrRunDir + '\Non_Reg\' + aString(FormatDateTime('YYMMDD', Now)) + '_Non_Reg.log';

   if FileExists(wString(sFile)) then
   begin
      nFile := FileOpen(wString(sFile), fmOpenWrite);
      FileSeek(nFile, 0, 2);
   end
   else
   begin
      nFile := FileCreate(wString(sFile));
   end;

   if nFile <> -1 then
   begin
      sFile := '[' + aString(FormatDateTime('hh:nn:ss', Now)) + '] ' + sMsg + #13 + #10;
      FileWrite(nFile, PAnsichar(sFile)^, Length(sFile));
      FileClose(nFile);
   end;
end;

procedure ExceptLogging(sMsg: aString; isStartEnd: boolean=False);
var
  nFile: Integer;
  sFile: aString;
begin
    sFile := sCurrRunDir + '\Log\' + aString(FormatDateTime('YYMMDD', Now)) + '.log';

   if FileExists(wString(sFile)) then
   begin
      nFile := FileOpen(wString(sFile), fmOpenWrite);
      FileSeek(nFile, 0, 2);
   end
   else
   begin
      nFile := FileCreate(wString(sFile));
   end;

   if nFile <> -1 then
   begin
      if isStartEnd = True then
        sFile := '**************************************************************' + #13#10 + '[' + aString(FormatDateTime('hh:nn:ss', Now)) + '] ' + sMsg + #13 + #10
      else
        sFile := '[' + aString(FormatDateTime('hh:nn:ss', Now)) + '] ' + sMsg + #13 + #10;
      FileWrite(nFile, PAnsichar(sFile)^, Length(sFile));
      FileClose(nFile);
   end;
end;

function NextModalDialog(Sender: TForm): Integer;
begin
  try
    with Sender do
    begin
      ShowModal;
      Result:= ModalResult;
      Free;
    end;
  except
    on E: Exception do
    begin
      ExceptLogging('NextModalDialog: ' + aString(E.Message));
      Result:= 0;
    end;
  end;
end;

procedure ClearComponent(AComponent: TComponent);
begin

end;

procedure DelaySleep(pSleepSecs: Cardinal; Flg: Boolean = False);
var
  StartTickCount : LongInt;
begin
  StartTickCount := GetTickCount;
  while (GetTickCount  < pSleepSecs + StartTickCount) and (not Application.Terminated) do
  begin
    if Flg then Sleep(63);
    Application.ProcessMessages;
  end;
end;

function GetTickCount64ForXP: Int64; stdcall;
var t32: cardinal;
    t64: Int64Rec absolute result;
begin // warning: GetSystemTimeAsFileTime() is fast, but not monotonic!
  t32 := Windows.GetTickCount;
  t64 := GetTickXP; // (almost) atomic read
  if t32<t64.Lo then
    inc(t64.Hi); // wrap-up overflow after 49 days
  t64.Lo := t32;
  GetTickXP := t64; // (almost) atomic write
end; // warning: FPC's GetTickCount64 doesn't handle 49 days wrap :(

end.
