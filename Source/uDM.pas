unit uDM;

interface

uses
  System.SysUtils, System.Classes, Data.DB, Data.Win.ADODB, uGlobal;

type
  TDM = class(TDataModule)
    ADODB: TADOConnection;
    qryIOData: TADOQuery;
  private

    { Private declarations }
  public
    function GetIONData(var ASql: TADOQuery; var ErrorMsg: string; const PreCarNo: string=''): Boolean;
    procedure ConnectDB; overload;
    function ConnectDB(ADbSetting: TDBSet; var ErrorMsg: string): Boolean; overload;
    function SqlRunExec(var sqlTemp: TADOQuery; BufSql: String): Boolean; overload;
    function SqlRunExec(var sqlTemp: TADOQuery; BufSql: String; var ErrorMsg: string): Boolean; overload;
    function SqlRunOpen(var sqlTemp: TADOQuery; BufSql: String): Boolean; overload;
    function SqlRunOpen(var sqlTemp: TADOQuery; BufSql: String; var ErrorMsg: string): Boolean; overload;
    { Public declarations }
  end;

var
  DM: TDM;

implementation

uses
  uConfig;

{%CLASSGROUP 'Vcl.Controls.TControl'}

{$R *.dfm}


function TDM.GetIONData(var ASql: TADOQuery; var ErrorMsg: string; const PreCarNo: string=''): Boolean;
var
  BufSql: string;
begin
  Result := True;
  BufSql := '';
  BufSql := BufSql + ' SELECT TOP 1 * ';
  BufSql := BufSql + '   FROM ( ';
  BufSql := BufSql + '         SELECT UnitNo, CASE WHEN InCarNo2 <> '''' THEN InCarNo2 ELSE InCarNo1 END AS CarNo, ProcDate, ProcTime ';
  BufSql := BufSql + '           FROM IONData ';
  BufSql := BufSql + '          WHERE ProcDate >= CONVERT(VARCHAR(10),GETDATE()-3,120) ';
  BufSql := BufSql + '            AND OutChk = 0 ';
  BufSql := BufSql + '            AND OutDate is null ';
  BufSql := BufSql + '          UNION ALL ';
  BufSql := BufSql + '         SELECT UnitNo, CASE WHEN InCarNo2 <> '''' THEN InCarNo2 ELSE InCarNo1 END AS CarNo, ProcDate, ProcTime ';
  BufSql := BufSql + '           FROM IOSData ';
  BufSql := BufSql + '          WHERE ProcDate >= CONVERT(VARCHAR(10),GETDATE()-3,120) ';
  BufSql := BufSql + '            AND InIOStatusNo = 1 ';
  BufSql := BufSql + '            AND OutIOStatusNo = 0 ';
  BufSql := BufSql + '        ) IOData ';
  if PreCarNo <> '' then
    BufSql := BufSql + '  WHERE CarNo <> ' + QuotedStr(PreCarNo);
  BufSql := BufSql + '  ORDER BY ProcDate, ProcTime ';

  if not DM.SqlRunOpen(ASql, BufSql, ErrorMsg) then
  begin
    Result := False;
    Exit;
  end;
end;

procedure TDM.ConnectDB;
begin
  if not ADODB.Connected then ADODB.Connected := True;
end;

function TDM.ConnectDB(ADbSetting: TDBSet; var ErrorMsg: string): Boolean;
var
  sConnStr: string;
begin
  Result := False;

  if ADbSetting.ServerIP <> '' then
  begin
    try
      with ADODB do
      begin
        if Connected then Connected := False;
        sConnStr := 'Provider=SQLOLEDB.1;Persist Security Info=True;';
        sConnStr := sConnStr + 'User ID=' + ADbSetting.Username;
        sConnStr := sConnStr + ';Password=' + ADbSetting.Password;
        sConnStr := sConnStr + ';Initial Catalog=' + ADbSetting.DBName;
        sConnStr := sConnStr + ';Data Source=' + ADbSetting.ServerIP;

        ConnectionString := sConnStr;
        Connected := True;
      end;
      Result := True;
      Exit;
    except
      on E: Exception do
      begin
        ErrorMsg := 'Failed to connect to the database. ' + E.ClassName + ' ' + E.Message;
        Result := False;
      end;
    end;
  end;
end;

function TDM.SqlRunExec(var sqlTemp: TADOQuery; BufSql: String): Boolean;
begin
  Result := True;
  Bufsql := StringReplace(BufSql, #9, '', [rfReplaceAll]);
  With sqlTemp do
  try
     Close;
     SQL.Clear;
     SQL.Add(BufSql);
     ExecSQL;
  except
    on E: Exception do
    begin
      Result := False;
      ExceptLogging('Failed to call function SqlRunExec: ' + E.ClassName + ' ' + E.Message);
    end;
  end;
end;

function TDM.SqlRunOpen(var sqlTemp: TADOQuery; BufSql: String): Boolean;
begin
  Result := True;
  Bufsql := StringReplace(BufSql, #9, '', [rfReplaceAll]);
  with sqlTemp do
  try
     Close;
     SQL.Clear;
     SQL.Add(BufSql);
     Open;
  except
    on E: Exception do
    begin
      Result := False;
      ExceptLogging('Failed to call function SqlRunOpen: ' + E.ClassName + ' ' + E.Message);
    end;
  end;

end;

function TDM.SqlRunExec(var sqlTemp: TADOQuery; BufSql: String; var ErrorMsg: string): Boolean;
begin
  Result := True;
  ErrorMsg := '';
  Bufsql := StringReplace(BufSql, #9, '', [rfReplaceAll]);
  With sqlTemp do
  try
     Close;
     SQL.Clear;
     SQL.Add(BufSql);
     ExecSQL;
  except
    on E: Exception do
    begin
      Result := False;
      ErrorMsg := 'Failed to call function SqlRunExec: ' + E.ClassName + ' ' + E.Message;
    end;
  end;
end;

function TDM.SqlRunOpen(var sqlTemp: TADOQuery; BufSql: String; var ErrorMsg: string): Boolean;
begin
  Result := True;
  ErrorMsg := '';
  Bufsql := StringReplace(BufSql, #9, '', [rfReplaceAll]);
  with sqlTemp do
  try
     Close;
     SQL.Clear;
     SQL.Add(BufSql);
     Open;
  except
    on E: Exception do
    begin
      Result := False;
      ErrorMsg := 'Failed to call function SqlRunOpen: ' + E.ClassName + ' ' + E.Message;
    end;
  end;

end;

end.
