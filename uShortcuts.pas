unit uShortcuts;

interface

uses
  Winapi.Windows, Winapi.Messages, System.SysUtils, System.Variants, System.Classes, Vcl.Graphics,
  Vcl.Controls, Vcl.Forms, Vcl.Dialogs, Vcl.ExtCtrls, Vcl.Menus,
  System.ImageList, Vcl.ImgList, uShortcutManager, Vcl.Imaging.pngimage;

type
  TfrmShortcuts = class(TForm)
    tray: TTrayIcon;
    lstImagens: TImageList;
    procedure FormCreate(Sender: TObject);
    procedure FormClose(Sender: TObject; var Action: TCloseAction);
  private
    { Private declarations }
    FManager: TShortcutManager;
  public
    { Public declarations }
  end;

const
  CONFIG_FILE = 'shortcuts.ini';

var
  frmShortcuts: TfrmShortcuts;

implementation

{$R *.dfm}

{ Form Methods }

procedure TfrmShortcuts.FormCreate(Sender: TObject);
begin
  FManager := TShortcutManager.Create(lstImagens);
  FManager.Load(CONFIG_FILE);
  tray.PopupMenu := FManager.PopupMenu;
end;

procedure TfrmShortcuts.FormClose(Sender: TObject; var Action: TCloseAction);
begin
  FreeAndNil(FManager);
end;

end.
