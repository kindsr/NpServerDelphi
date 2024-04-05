program NPServerDelphi;

uses
  Vcl.Forms,
  uMain in 'uMain.pas' {Main},
  uConfig in 'uConfig.pas' {Config},
  uGlobal in 'uGlobal.pas',
  uDM in 'uDM.pas' {DM: TDataModule},
  uIONData in 'DataObject\uIONData.pas',
  Vcl.Themes,
  Vcl.Styles;

{$R *.res}

begin
  Application.Initialize;
  Application.MainFormOnTaskbar := True;
  TStyleManager.TrySetStyle('Glossy');
  Application.CreateForm(TDM, DM);
  Application.CreateForm(TMain, Main);
  {$IFDEF DEBUG} ReportMemoryLeaksOnShutdown := True; {$ENDIF}
  Application.Run;
end.
