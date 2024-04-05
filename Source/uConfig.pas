unit uConfig;

interface

uses
  Winapi.Windows, Winapi.Messages, System.SysUtils, System.Variants, System.Classes, Vcl.Graphics,
  Vcl.Controls, Vcl.Forms, Vcl.Dialogs, System.IniFiles, Vcl.StdCtrls,
  Vcl.ExtCtrls, uGlobal;

type
  TConfig = class(TForm)
    GroupBox1: TGroupBox;
    Panel1: TPanel;
    btnClose: TButton;
    btnSave: TButton;
    Label3: TLabel;
    Label4: TLabel;
    Label5: TLabel;
    edtTCPServerPort: TEdit;
    edtRetryPeriod: TEdit;
    edtHeartbeatPeriod: TEdit;
    GroupBox2: TGroupBox;
    Label6: TLabel;
    edtSalesCarNumber: TEdit;
    Label7: TLabel;
    edtEmergencyNumber: TEdit;
    GroupBox3: TGroupBox;
    Label1: TLabel;
    Label2: TLabel;
    Label8: TLabel;
    edtDBServerIP: TEdit;
    edtDBUsername: TEdit;
    edtDBPassword: TEdit;
    Label9: TLabel;
    edtDBName: TEdit;
    procedure FormShow(Sender: TObject);
    procedure btnSaveClick(Sender: TObject);
    procedure btnCloseClick(Sender: TObject);
  private
    { Private declarations }
  public
    function  LoadConfig(AFileName: string): TConfigRec;
    procedure SaveConfig(AFileName: string; AConfigInfo: TConfigRec);
    { Public declarations }
  end;

var
  Config: TConfig;

implementation

{$R *.dfm}

{ TMain }

procedure TConfig.btnCloseClick(Sender: TObject);
begin
  Close;
end;

procedure TConfig.btnSaveClick(Sender: TObject);
begin

  with ConfigInfo.ServerSetting do
  begin
    TCPServerPort    := StrToInt(edtTCPServerPort.Text);
    RetryPeriod      := StrToInt(edtRetryPeriod.Text);
    HeartbeatPeriod  := StrToInt(edtHeartbeatPeriod.Text);
  end;

  with ConfigInfo.PolicySetting do
  begin
    SalesCarNumber   := edtSalesCarNumber.Text;
    EmergencyNumber  := edtEmergencyNumber.Text;
  end;

  with ConfigInfo.DBSetting do
  begin
    ServerIP := edtDBServerIP.Text;
    Username := edtDBUsername.Text;
    Password := edtDBPassword.Text;
    DBName := edtDBName.Text;
  end;

  SaveConfig(ExtractFilePath(Application.ExeName) + ChangeFileExt(ExtractFileName(Application.ExeName), '.ini'), ConfigInfo);
end;

procedure TConfig.FormShow(Sender: TObject);
begin
  ConfigInfo := LoadConfig(ExtractFilePath(Application.ExeName) + ChangeFileExt(ExtractFileName(Application.ExeName), '.ini'));

  with ConfigInfo.ServerSetting do
  begin
    edtTCPServerPort.Text := IntToStr(TCPServerPort);
    edtRetryPeriod.Text := IntToStr(RetryPeriod);
    edtHeartbeatPeriod.Text := IntToStr(HeartbeatPeriod);
  end;

  with ConfigInfo.PolicySetting do
  begin
    edtSalesCarNumber.Text := SalesCarNumber;
    edtEmergencyNumber.Text := EmergencyNumber;
  end;

  with ConfigInfo.DBSetting do
  begin
    edtDBServerIP.Text := ServerIP;
    edtDBUsername.Text := Username;
    edtDBPassword.Text := Password;
    edtDBName.Text := DBName;
  end;
end;

function TConfig.LoadConfig(AFileName: string): TConfigRec;
var
  iniFile: TIniFile;
begin
  if not FileExists(AFileName) then Exit;

  iniFile := TIniFile.Create(AFileName);

  try
    with Result do
    begin
      ServerSetting.TCPServerPort    := iniFile.ReadInteger('GW', 'TCPSERVERPORT', 2200);
      ServerSetting.RetryPeriod      := iniFile.ReadInteger('GW', 'RETRY', 5000);
      ServerSetting.HeartbeatPeriod  := iniFile.ReadInteger('GW', 'HBEAT', 10000);

      PolicySetting.SalesCarNumber   := iniFile.ReadString('GW', 'SALESCARNUMBER', '아,바,사,자,배');
      PolicySetting.EmergencyNumber  := iniFile.ReadString('GW', 'EMERGENCYNUMBER', '998,999');

      DBSetting.ServerIP             := iniFile.ReadString('GW', 'DBServerIP', '127.0.0.1,42130');
      DBSetting.Username             := iniFile.ReadString('GW', 'DBUsername', 'sa');
      DBSetting.Password             := iniFile.ReadString('GW', 'DBPassword', 'nexpa1234');
      DBSetting.DBName               := iniFile.ReadString('GW', 'DBName', 'PARKING');
    end;
  finally
    iniFile.Free;
  end;
end;

procedure TConfig.SaveConfig(AFileName: string; AConfigInfo: TConfigRec);
var
  iniFile: TIniFile;
begin
//  if not FileExists(AFileName) then Exit;

  iniFile := TIniFile.Create(AFileName);

  try
    with AConfigInfo do
    begin
      iniFile.WriteInteger('GW', 'TCPSERVERPORT',   ServerSetting.TCPServerPort);
      iniFile.WriteInteger('GW', 'RETRY',           ServerSetting.RetryPeriod);
      iniFile.WriteInteger('GW', 'HBEAT',           ServerSetting.HeartbeatPeriod);

      iniFile.WriteString('GW', 'SALESCARNUMBER',   PolicySetting.SalesCarNumber);
      iniFile.WriteString('GW', 'EMERGENCYNUMBER',  PolicySetting.EmergencyNumber);

      iniFile.WriteString('GW', 'DBServerIP',       DBSetting.ServerIP);
      iniFile.WriteString('GW', 'DBUsername',       DBSetting.Username);
      iniFile.WriteString('GW', 'DBPassword',       DBSetting.Password);
      iniFile.WriteString('GW', 'DBName',           DBSetting.DBName);
    end;
  finally
    iniFile.Free;
  end;
end;

end.
