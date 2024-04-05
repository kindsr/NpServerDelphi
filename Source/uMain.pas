unit uMain;

interface

uses
  Winapi.Windows, Winapi.Messages, System.SysUtils, System.Variants,
  System.Classes, Vcl.Graphics, Vcl.Controls, Vcl.Forms, Vcl.Dialogs,
  Vcl.ExtCtrls, Vcl.StdCtrls, System.SyncObjs, uGlobal, ScktComp, Math,
  System.Generics.Collections, StrUtils, scControls, IOUtils, DateUtils,
  scGPControls, scModernControls, Vcl.Mask, scGPExtControls, Registry, AdvEdit,
  Vcl.ComCtrls;

const
  SPLITCHAR = '#';
  BASE_IMAGE_PATH = 'C:\MSImage';
  TEST_IONDATA = 'TEST_IONDATA.txt';
  TEST_IOSDATA = 'TEST_IOSDATA.txt';

type
  TMain = class(TForm)
    Panel1: TPanel;
    Panel2: TPanel;
    btnSetting: TButton;
    btnTCPServer: TButton;
    mLogTCPServer: TMemo;
    pnlStatus: TPanel;
    Label1: TLabel;
    lblConnected: TLabel;
    btnClear: TButton;
    Panel3: TPanel;
    gbCH1: TGroupBox;
    lbLaneID: TLabel;
    Label2: TLabel;
    swBar: TscGPSwitch;
    cbBar: TscGPCheckBox;
    Label3: TLabel;
    edtLaneID: TscGPEdit;
    edtCarNo: TscGPEdit;
    btnSendCarNo: TscGPButton;
    gbCH2: TGroupBox;
    Label4: TLabel;
    Label5: TLabel;
    Label6: TLabel;
    swBar2: TscGPSwitch;
    cbBar2: TscGPCheckBox;
    edtLaneID2: TscGPEdit;
    edtCarNo2: TscGPEdit;
    btnSendCarNo2: TscGPButton;
    tmrHeartBeat: TTimer;
    btnOpenImageFile: TButton;
    btnRfVal: TscGPButton;
    btnRfVal2: TscGPButton;
    Label8: TLabel;
    edtRFCardNo: TscGPEdit;
    Label9: TLabel;
    edtRFCardNo2: TscGPEdit;
    cbRecg: TscGPComboBox;
    cbRecg2: TscGPComboBox;
    edtImageFilePath: TAdvEdit;
    StatusBar1: TStatusBar;
    edtRepeatPeriod: TscGPSpinEdit;
    procedure btnSettingClick(Sender: TObject);
    procedure FormCreate(Sender: TObject);
    procedure btnTCPServerClick(Sender: TObject);
    procedure btnClearClick(Sender: TObject);
    procedure FormShow(Sender: TObject);
    procedure tmrHeartBeatTimer(Sender: TObject);
    procedure btnSendCarNoClick(Sender: TObject);
    procedure btnOpenImageFileClick(Sender: TObject);
    procedure btnRfValClick(Sender: TObject);
    procedure FormCloseQuery(Sender: TObject; var CanClose: Boolean);
    procedure swBarChangeState(Sender: TObject);
  private
    procedure ssTcpServer_ClientConnect(Sender: TObject; Socket: TCustomWinSocket);
    procedure ssTcpServer_ClientDisconnect(Sender: TObject; Socket: TCustomWinSocket);
    procedure ssTcpServer_ClientError(Sender: TObject; Socket: TCustomWinSocket; ErrorEvent: TErrorEvent; var ErrorCode: Integer);
    procedure ssTcpServer_ClientRead(Sender: TObject; Socket: TCustomWinSocket);
    function SendMsgToAllClients(pServer: TServerSocket; pMsg: string): Boolean;
    function SaveImageFileToShareFolder(pSourceFilePath, pChannel, pCarNo: string): string;
    procedure LoadState;
    procedure SaveState;
    { Private declarations }
  public
    MainFormState: Integer; // 0 : 기본 , 1 : 최대화
    { Public declarations }
  end;

var
  Main: TMain;
  LPRServerQueue: TQueue<string>;
  ssTcpServer: TServerSocket;
  iConnectedClients: Integer;
  sNowCarNo: aString;
  _IsTerminated: Boolean;

implementation

uses
  uConfig, uDM, uIONData;

{$R *.dfm}

procedure TMain.btnOpenImageFileClick(Sender: TObject);
var
  openDialog: TOpenDialog;
begin
  openDialog := TOpenDialog.Create(Self);

  try
    with openDialog do
    begin
      InitialDir := GetCurrentDir;
      Options := [ofFileMustExist];
      Filter := 'JPG|*.jpg';
      FilterIndex := 0;

      if Execute then
        if FileExists(FileName) then
          edtImageFilePath.Text := FileName
        else
          raise Exception.Create('File does not exist.');
    end;
  finally
    openDialog.Free;
  end;
end;

procedure TMain.btnRfValClick(Sender: TObject);
var
  Buf: string;
begin
  // RF_VAL_1_00822511#
  // RF_VAL_(LaneID)_(RFCardNo)#(CurrentDate)
  Buf := MSG_RF_VAL;
  if TscGPButton(Sender).Name = 'btnRfVal' then
  begin
    Buf := Buf + edtLaneID.Text + '_';
    Buf := Buf + edtRFCardNo.Text + SPLITCHAR;
  end
  else if TscGPButton(Sender).Name = 'btnRfVal2' then
  begin
    Buf := Buf + edtLaneID2.Text + '_';
    Buf := Buf + edtRFCardNo2.Text + SPLITCHAR;
  end;

  SendMsgToAllClients(ssTcpServer, Buf);
end;

procedure TMain.btnSendCarNoClick(Sender: TObject);
var
  Buf, Msg: string;
  tmp: string;
  doIONData: TIONDataClass;
  TestCarList: TStringList;
  i: Integer;
begin
  if swBar.State = TscSwitchState.scswOn then
  begin
    // 출차는 DB에서
    if ConfigInfo.DBSetting.ServerIP <> '' then
    begin
      if not DM.ADODB.Connected then DM.ConnectDB;
      while (not _IsTerminated) and (swBar.State = TscSwitchState.scswOn) do
      begin
        if swBar.State = TscSwitchState.scswOff then Break;

        // Get IONData
        if not DM.GetIONData(DM.qryIOData, Msg) then
        begin
          StatusBar1.Panels[0].Text := Msg;
          Exit;
        end
        else
        begin
          StatusBar1.Panels[0].Text := IntToStr(DM.qryIOData.RecordCount) + ' data is queried.';
        end;

        // loop to change CarNo from the dataset
        try
          with DM.qryIOData do
          begin
            if RecordCount > 0 then
            begin
//              doIONData := TIONDataClass.Create;

              try
//                while (not Eof) and (not _IsTerminated) do
                begin
//                  doIONData.InCarNo1 := FieldByName('CarNo').AsString;

                  // SendMessage to clients
//                  edtCarNo.Text := doIONData.InCarNo1;
                  edtCarNo.Text := FieldByName('CarNo').AsString;

                  tmp := SaveImageFileToShareFolder(edtImageFilePath.Text, 'CH1', edtCarNo.Text);
                  Buf := 'CH1';
                  Buf := Buf + SPLITCHAR + edtCarNo.Text;
                  Buf := Buf + SPLITCHAR + cbRecg.Items[cbRecg.ItemIndex].Caption;
                  Buf := Buf + SPLITCHAR + tmp;

                  SendMsgToAllClients(ssTcpServer, Buf);
                  StatusBar1.Panels[0].Text := 'Sent ' + edtCarNo.Text;

                  // delay
//                  DelaySleep(edtRepeatPeriod.Value * 1000, True);
//                  Next;
                end;
              finally
//                doIONData.Free;
//                doIONData := nil;
              end;

              StatusBar1.Panels[0].Text := 'Finished sent CarNo out: ' + edtCarNo.Text;
            end;
          end;
        except
          on E: Exception do
          begin
            StatusBar1.Panels[0].Text := 'Exception at the loop to change CarNo from the dataset: ' + E.ClassName + ' ' + E.Message;
          end;
        end;

        // delay
        DelaySleep(edtRepeatPeriod.ValueAsInt * 1000, True);
      end;
    end
    else
    begin
      // load txt file for TEST DATA
      if FileExists(TEST_IONDATA) then
      begin
        TestCarList := TStringList.Create;
        TestCarList.DefaultEncoding := TEncoding.UTF8;
        try
          TestCarList.LoadFromFile(TEST_IONDATA);
          for i := TestCarList.Count - 1 downto 1 do
            TestCarList.Exchange(i, Random(i+1));

          for i := 0 to TestCarList.Count - 1 do
          begin
            if _IsTerminated then Break;
            if swBar.State = TscSwitchState.scswOff then Break;

            edtCarNo.Text := TestCarList[i];

            // SendMessage to clients
            tmp := SaveImageFileToShareFolder(edtImageFilePath.Text, 'CH1', edtCarNo.Text);
            Buf := 'CH1';
            Buf := Buf + SPLITCHAR + edtCarNo.Text;
            Buf := Buf + SPLITCHAR + cbRecg.Items[cbRecg.ItemIndex].Caption;
            Buf := Buf + SPLITCHAR + tmp;

            SendMsgToAllClients(ssTcpServer, Buf);
            StatusBar1.Panels[0].Text := 'Sent ' + edtCarNo.Text;

            // delay
            DelaySleep(edtRepeatPeriod.ValueAsInt * 1000, True);
            Next;
          end;

        finally
          TestCarList.Free;
          TestCarList := nil;
        end;
      end;
    end;
  end
  else
  begin
    if TscGPButton(Sender).Name = 'btnSendCarNo' then
    begin
      tmp := SaveImageFileToShareFolder(edtImageFilePath.Text, 'CH1', edtCarNo.Text);
      Buf := 'CH1';
      Buf := Buf + SPLITCHAR + edtCarNo.Text;
      Buf := Buf + SPLITCHAR + cbRecg.Items[cbRecg.ItemIndex].Caption;
    end
    else if TscGPButton(Sender).Name = 'btnSendCarNo2' then
    begin
      tmp := SaveImageFileToShareFolder(edtImageFilePath.Text, 'CH2', edtCarNo.Text);
      Buf := 'CH2';
      Buf := Buf + SPLITCHAR + edtCarNo2.Text;
      Buf := Buf + SPLITCHAR + cbRecg2.Items[cbRecg2.ItemIndex].Caption;
    end;

    Buf := Buf + SPLITCHAR + tmp;

    SendMsgToAllClients(ssTcpServer, Buf);
  end;
end;

procedure TMain.btnSettingClick(Sender: TObject);
var
  Res: Integer;
  Msg: string;
begin
  Res := NextModalDialog(TConfig.Create(Self));

  if Res > 0 then
  begin
    btnTCPServer.Click;
    DelaySleep(50);
    btnTCPServer.Click;

    if ConfigInfo.DBSetting.ServerIP <> '' then
    begin
      if not DM.ADODB.Connected then
      begin
        if not DM.ConnectDB(ConfigInfo.DBSetting, Msg) then
        begin
          StatusBar1.Panels[0].Text := Msg;
          Exit;
        end
        else
        begin
          StatusBar1.Panels[0].Text := 'Connedted to database.';
        end;
      end;
    end
    else
    begin
      if DM.ADODB.Connected then DM.ADODB.Connected := False;
      StatusBar1.Panels[0].Text := 'Disconnedted from database.';
    end;

  end;
end;

procedure TMain.btnTCPServerClick(Sender: TObject);
begin
  if TButton(Sender).Tag = 0 then
  begin
    try
      ssTcpServer.Port := ConfigInfo.ServerSetting.TCPServerPort;
      ssTcpServer.Open;
      TButton(Sender).Tag := 1;
      TButton(Sender).Caption := 'TCP Server Close';
    except
      on E: Exception do
      begin
        iConnectedClients := 0;
        lblConnected.Caption := '0';
        TButton(Sender).Tag := 0;
        TButton(Sender).Caption := 'TCP Server Open';
      end;
    end;
  end
  else
  begin
    if ssTcpServer.Active then
    begin
      ssTcpServer.Close;
      iConnectedClients := 0;
      lblConnected.Caption := '0';
      TButton(Sender).Tag := 0;
      TButton(Sender).Caption := 'TCP Server Open';
    end;
  end;
end;

procedure TMain.btnClearClick(Sender: TObject);
begin
  mLogTCPServer.Lines.Clear;
end;

procedure TMain.FormCloseQuery(Sender: TObject; var CanClose: Boolean);
begin
//  CanClose := False;
//  if MessageDlg('Quit this program?', TMsgDlgType.mtConfirmation, [mbOK, mbCancel], 0) = mrOk then
  begin
    SaveState;

    if ssTcpServer <> nil then
    begin
      ssTcpServer.Free;
      ssTcpServer := nil;
    end;

    if DM.ADODB.Connected then
      DM.ADODB.Connected := False;

    _IsTerminated := True;

    CanClose := True;
  end;
end;

procedure TMain.FormCreate(Sender: TObject);
begin
  try
    // Load Config
    with TConfig.Create(Self) do
      ConfigInfo := LoadConfig(ExtractFilePath(Application.ExeName) + ChangeFileExt(ExtractFileName(Application.ExeName), '.ini'));

    sCurrRunDir := aString(ExtractFileDir(Application.ExeName));

    if not DirectoryExists('Log') then
      MkDir('Log');

    // Server
    ssTcpServer := TServerSocket.Create(Self);
    with ssTcpServer do
    begin
      ServerType := stNonBlocking;
      Port := ConfigInfo.ServerSetting.TCPServerPort;

      OnClientConnect := ssTcpServer_ClientConnect;
      OnClientDisconnect := ssTcpServer_ClientDisconnect;
      OnClientError := ssTcpServer_ClientError;
      OnClientRead := ssTcpServer_ClientRead;
    end;

    mLogTCPServer.Lines.Clear;

    iConnectedClients := 0;
  except
    on E: Exception do
    begin
      Assert(false, E.ClassName + ' ' + E.Message);
      ExceptLogging('TfrmMain.FormCreate: ' + aString(E.Message));
    end;
  end;
end;

procedure TMain.FormShow(Sender: TObject);
var
  Msg: string;
  BufSql: string;
begin
  LoadState;
  Caption := TPath.GetFileNameWithoutExtension(Application.ExeName);

  btnTCPServer.Click;

  _IsTerminated := False;
end;

procedure TMain.ssTcpServer_ClientConnect(Sender: TObject; Socket: TCustomWinSocket);
begin
  ExceptLogging('ssTcpServer_ClientConnect : Connect');
  ExceptLogging('ssTcpServer_ClientConnect : ' + Socket.RemoteAddress + ' , ' + IntToStr(Socket.RemotePort) + '접속');
  iConnectedClients := iConnectedClients + 1;
  lblConnected.Caption := IntToStr(iConnectedClients);
  tmrHeartBeat.Enabled := True;
  if ssTcpServer.Socket.ActiveConnections > 0 then
    ssTcpServer.Socket.Connections[ssTcpServer.Socket.ActiveConnections - 1].SendText(Socket.RemoteAddress);
end;

procedure TMain.ssTcpServer_ClientDisconnect(Sender: TObject; Socket: TCustomWinSocket);
begin
  ExceptLogging('ssTcpServer_ClientDisconnect : DisConnect');
  ExceptLogging('ssTcpServer_ClientDisconnect : ' + Socket.RemoteAddress + ' , ' + IntToStr(Socket.RemotePort) + '종료');
  if iConnectedClients > 0 then
  begin
    iConnectedClients := iConnectedClients - 1;
    lblConnected.Caption := IntToStr(iConnectedClients);
  end
  else
  begin
    iConnectedClients := 0;
    lblConnected.Caption := IntToStr(iConnectedClients);
    tmrHeartBeat.Enabled := False;
  end;
end;

procedure TMain.ssTcpServer_ClientError(Sender: TObject; Socket: TCustomWinSocket; ErrorEvent: TErrorEvent; var ErrorCode: Integer);
begin
  ExceptLogging('ssHomeinfo_iconClientError : 에러코드 : [' + IntToStr(ErrorCode) + ']');
  ErrorCode := 0;
end;

procedure TMain.ssTcpServer_ClientRead(Sender: TObject; Socket: TCustomWinSocket);
var
  sRecvText, sSend: AnsiString;
begin
  sRecvText := Socket.ReceiveText;
  sRecvText := StringReplace(sRecvText, MSG_OK, '', [rfReplaceAll, rfIgnoreCase]);
  if string.IsNullOrEmpty(sRecvText) then
    Exit;

  ExceptLogging('tssServerMainClientRead : ' + Socket.RemoteAddress + ' , ' + IntToStr(Socket.RemotePort) + '로 부터 요청전문 수신');
  ExceptLogging('요청전문 : [' + sRecvText + ']');

  if mLogTCPServer.Lines.Count > 300 then
    mLogTCPServer.Lines.Clear;
  mLogTCPServer.Lines.Add('[RECEIVED] ' + sRecvText);
end;

procedure TMain.swBarChangeState(Sender: TObject);
var
  Msg: string;
begin
  if ConfigInfo.DBSetting.ServerIP = '' then Exit;

  if TscGPSwitch(Sender).State = TscSwitchState.scswOn then
  begin
    if not DM.ADODB.Connected then
    begin
      if not DM.ConnectDB(ConfigInfo.DBSetting, Msg) then
      begin
        StatusBar1.Panels[0].Text := Msg;
        Exit;
      end
      else
      begin
        StatusBar1.Panels[0].Text := 'Connedted to database.';
      end;
    end;
  end
  else
  begin
    StatusBar1.Panels[0].Text := 'Disconnedted from database.';
    DM.ADODB.Connected := False;
  end;
end;

procedure TMain.tmrHeartBeatTimer(Sender: TObject);
begin
  tmrHeartBeat.Enabled := False;

  if (ssTcpServer.Active) and (ssTcpServer.Socket.ActiveConnections > 0) then
  begin
    SendMsgToAllClients(ssTcpServer, MSG_HEARTBEAT);
  end;

  tmrHeartBeat.Enabled := True;
end;

function TMain.SendMsgToAllClients(pServer: TServerSocket; pMsg: string): Boolean;
var
  i: Integer;
  tmpMsg: string;
begin
  // 여기서 연결된 클라이언트로 send
  if (pServer.Active) and (pServer.Socket.ActiveConnections > 0) then
  begin
    for i := 0 to ssTcpServer.Socket.ActiveConnections - 1 do
    begin
      ssTcpServer.Socket.Connections[i].SendText(pMsg);
    end;

    tmpMsg := StringReplace(pMsg, MSG_HEARTBEAT, '', [rfReplaceAll, rfIgnoreCase]);
    if string.IsNullOrEmpty(tmpMsg) then
      Exit;
    mLogTCPServer.Lines.Add('[SENDTOALL] ' + pMsg);
  end;
end;

function TMain.SaveImageFileToShareFolder(pSourceFilePath, pChannel, pCarNo: string): string;
var
  TargetFilePath: string;
  currentDateTime: string;
begin
  currentDateTime := FormatDateTime('YYYY-MM-DD hh:mm:ss', now);
  currentDateTime := StringReplace(currentDateTime, '-', '', [rfReplaceAll, rfIgnoreCase]);
  currentDateTime := StringReplace(currentDateTime, ':', '', [rfReplaceAll, rfIgnoreCase]);
  currentDateTime := StringReplace(currentDateTime, ' ', '', [rfReplaceAll, rfIgnoreCase]);

  TargetFilePath := PathDelim + Copy(currentDateTime, 1, 4);
  TargetFilePath := TargetFilePath + PathDelim + Copy(currentDateTime, 5, 2);
  TargetFilePath := TargetFilePath + PathDelim + Copy(currentDateTime, 7, 2);

  ForceDirectories(BASE_IMAGE_PATH + TargetFilePath);

  TargetFilePath := TargetFilePath + PathDelim + pChannel + '_' + currentDateTime + '_' + pCarNo + '.jpg';

  CopyFile(PChar(pSourceFilePath), PChar(BASE_IMAGE_PATH + TargetFilePath), False);

  Result := TargetFilePath;
end;

procedure TMain.LoadState;
var
  R: TRegistry;
  sColWidth: string;
  arrColWidth: TArray<string>;
  iMonitorSearch, iMonitorCount: Integer;
  iScreenWidth, iScreenHeight: Integer;
begin
  R := TRegistry.Create(KEY_READ);
  try
    try
      R.RootKey := HKEY_CURRENT_USER;
      if R.KeyExists(REG_KEY+TPath.GetFileNameWithoutExtension(Application.ExeName)+'\') then
      begin
        if R.OpenKey(REG_KEY+TPath.GetFileNameWithoutExtension(Application.ExeName)+'\', False) then
        begin
          try
            if R.ValueExists('MainFormState') then
              MainFormState := R.ReadInteger('MainFormState')
            else
              MainFormState := 0;

            if R.ValueExists('Left') then
              Left := R.ReadInteger('Left')
            else
              Left := (Screen.monitors[0].Width div 2) - (ClientWidth div 2);

            if R.ValueExists('Top') then
            begin
              Top := R.ReadInteger('Top');
              if Top < 0 then
                Top := 0;
            end
            else
              Top := (Screen.monitors[0].Height div 2) - (ClientHeight div 2);

            if R.ValueExists('ClientHeight') then
              ClientHeight := R.ReadInteger('ClientHeight')
            else
              ClientHeight := 460;

            if R.ValueExists('ClientWidth') then
              ClientWidth := R.ReadInteger('ClientWidth')
            else
              ClientWidth := 580;

            if R.ValueExists('edtImageFilePath') then
              edtImageFilePath.Text := R.ReadString('edtImageFilePath');

            if R.ValueExists('edtLaneID') then
              edtLaneID.Text := R.ReadString('edtLaneID');

            if R.ValueExists('edtCarNo') then
              edtCarNo.Text := R.ReadString('edtCarNo');

            if R.ValueExists('swBar') then
            begin
              if R.ReadInteger('swBar') = 0 then
                swBar.State := scswOff
              else
                swBar.State := scswOn;
            end;

            if R.ValueExists('cbBar') then
              cbBar.Checked := R.ReadBool('cbBar');

            if R.ValueExists('edtRepeatPeriod') then
              edtRepeatPeriod.Value := R.ReadInteger('edtRepeatPeriod');

            if R.ValueExists('edtRFCardNo') then
              edtRFCardNo.Text := R.ReadString('edtRFCardNo');

            if R.ValueExists('edtLaneID2') then
              edtLaneID2.Text := R.ReadString('edtLaneID2');

            if R.ValueExists('edtCarNo2') then
              edtCarNo2.Text := R.ReadString('edtCarNo2');

            if R.ValueExists('swBar2') then
            begin
              if R.ReadInteger('swBar2') = 0 then
                swBar2.State := scswOff
              else
                swBar2.State := scswOn;
            end;

            if R.ValueExists('cbBar2') then
              cbBar2.Checked := R.ReadBool('cbBar2');

            if R.ValueExists('edtRFCardNo2') then
              edtRFCardNo2.Text := R.ReadString('edtRFCardNo2');

          finally
            R.CloseKey;
          end;
        end
        else
        begin
          //Failed to open registry key
        end;
      end
      else
      begin
        //Registry key does not exist
        Left := (Screen.Width div 2) - (ClientWidth div 2);
        Top := (Screen.Height div 2) - (ClientHeight div 2);
      end;
    except

    end;
  finally
    R.Free;
  end;
end;

procedure TMain.SaveState;
var
  R: TRegistry;
  sColWidth: string;
begin
  R := TRegistry.Create(KEY_READ or KEY_WRITE);
  try
    try
      R.RootKey := HKEY_CURRENT_USER;
      if R.OpenKey(REG_KEY+TPath.GetFileNameWithoutExtension(Application.ExeName)+'\', True) then
      begin
        try
          if MainFormState = 0 then
          begin
            R.WriteInteger('Left', Left);
            if Top < 0 then
              R.WriteInteger('Top', 0)
            else
              R.WriteInteger('Top', Top);
            R.WriteInteger('ClientHeight', ClientHeight);
            R.WriteInteger('ClientWidth', ClientWidth);
          end;

          // 화면최대화 여부확인(0 : 기본, 1: 최소화(바모드), 2 : 최대화)
          R.WriteInteger('MainFormState', MainFormState);
  
          R.WriteString('edtImageFilePath', edtImageFilePath.Text);
          R.WriteString('edtLaneID', edtLaneID.Text);
          R.WriteString('edtCarNo', edtCarNo.Text);
          R.WriteInteger('swBar', IfThen(swBar.State = scswOff, 0, 1));
          R.WriteBool('cbBar', cbBar.Checked);
          R.WriteInteger('edtRepeatPeriod', edtRepeatPeriod.ValueAsInt);
          R.WriteString('edtRFCardNo', edtRFCardNo.Text);

          R.WriteString('edtLaneID2', edtLaneID2.Text);
          R.WriteString('edtCarNo2', edtCarNo2.Text);
          R.WriteInteger('swBar2', IfThen(swBar2.State = scswOff, 0, 1));
          R.WriteBool('cbBar2', cbBar2.Checked);
          R.WriteString('edtRFCardNo2', edtRFCardNo2.Text);

        finally
          R.CloseKey;
        end;
      end
      else
      begin
        //Failed to open registry key
      end;
    except

    end;
  finally
    R.Free;
  end;
end;

end.

