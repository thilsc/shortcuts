program Shortcuts;

uses
  Vcl.Forms,
  uShortcuts in 'uShortcuts.pas' {frmShortcuts},
  uShortcutManager in 'uShortcutManager.pas',
  uShortcutsUtils in 'uShortcutsUtils.pas',
  uShortcutsConsts in 'uShortcutsConsts.pas',
  uShortcutsTypes in 'uShortcutsTypes.pas';

{$R *.res}

begin
  Application.Initialize;
  Application.MainFormOnTaskbar := True;
  Application.CreateForm(TfrmShortcuts, frmShortcuts);
  Application.ShowMainForm := False;
  Application.Run;
end.
