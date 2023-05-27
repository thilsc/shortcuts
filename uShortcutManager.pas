unit uShortcutManager;

interface

uses System.Classes, System.Types, System.SysUtils, Vcl.Forms, Vcl.Menus,
  Vcl.Controls, Vcl.Graphics, Vcl.ExtCtrls, uShortcutsTypes, uAtalho;

type
  TShortcutManager = class
  private
    FConfigFile: string;
    FPopup: TPopupMenu;
    FListaGruposAtalho: TListaGruposAtalho;
    procedure CriaItensMenuPopup;
    procedure AtualizaItensMenuPopup(ListaAtualizacoes: TListaGruposAtalho);
    procedure ItemMenuEditarClick(Sender: TObject);
    procedure ItemMenuFecharClick(Sender: TObject);
    function GetActualImageIndex(ItemLink: string): Integer;
    procedure NovoItemMenuClick(Sender: TObject);
  public
    property PopupMenu: TPopupMenu read FPopup;
    procedure Load(AConfigFile: string);
    constructor Create(AListaImagens: TImageList); overload;
    destructor Destroy; override;
  end;

implementation

uses uShortcutsConsts, uShortcutsUtils, uTitlePopupMenu, uCadListaAtalhos, uMenuItemPlus, Vcl.Dialogs;

{ TShortcutManager }

constructor TShortcutManager.Create(AListaImagens: TImageList);
begin
  inherited Create;
  FPopup := TPopupMenu.Create(AListaImagens.Owner);
  FPopup.Images := AListaImagens;
  FPopup.OwnerDraw := True;

  FListaGruposAtalho := TListaGruposAtalho.Create(True);
end;

function TShortcutManager.GetActualImageIndex(ItemLink: string): Integer;
var
  Icon: TIcon;
begin
  Icon := GetIconFromFileOrURL(ItemLink, FPopup.Images.Height, FPopup.Images.Width);

  if Assigned(Icon) then
    Result := FPopup.Images.AddIcon(Icon)
  else
    Result := ArrayTipoItemMenuImageIndex[GetImageIndexItemMenu(ItemLink)];
end;

procedure TShortcutManager.Load(AConfigFile: string);
begin
  if FileExists(AConfigFile) then
  begin
    FConfigFile := AConfigFile;

    FListaGruposAtalho.Clear;
    CarregarArquivoINIListaAtalhos(FConfigFile, FListaGruposAtalho);
  end;

  CriaItensMenuPopup;
end;

procedure TShortcutManager.CriaItensMenuPopup;
var
  I, J: Integer;
  MenuGrupo, MenuItem: TMenuItem;
begin
  FPopup.Items.Clear;
  FPopup.Items.Add(TTitlePopupMenu.Create(FPopup, 'title.png'));

  for I := 0 to Pred(FListaGruposAtalho.Count) do
  begin
    MenuGrupo := nil;

    if (AnsiUpperCase(FListaGruposAtalho[I].Nome) <> 'GERAL') then
    begin
      FPopup.Items.Add(TMenuItemPlus.Create(FPopup.Items, FListaGruposAtalho[I]));
      MenuGrupo := FPopup.Items[Pred(FPopup.Items.Count)];
    end;

    for J := 0 to Pred(FListaGruposAtalho[I].Atalhos.Count) do
    begin
      if Assigned(MenuGrupo) then
      begin
        MenuGrupo.Add(TMenuItemPlus.Create(MenuGrupo, FListaGruposAtalho[I].Atalhos[J], GetActualImageIndex(FListaGruposAtalho[I].Atalhos[J].Caminho)));
        MenuItem := MenuGrupo.Items[Pred(MenuGrupo.Count)];
      end
      else
      begin
        FPopup.Items.Add(TMenuItemPlus.Create(FPopup.Items, FListaGruposAtalho[I].Atalhos[J], GetActualImageIndex(FListaGruposAtalho[I].Atalhos[J].Caminho)));
        MenuItem := FPopup.Items[Pred(FPopup.Items.Count)];
      end;

     // MenuItem.
    end;
  end;

  FPopup.Items.Add(TSeparadorMenuItem.Create(FPopup, 'sep1'));
  FPopup.Items.Add(TMenuItemNovoItem.Create(FPopup, NovoItemMenuClick));
  //FPopup.Items.Add(TMenuItemEditar.Create(FPopup, ItemMenuEditarClick));
  FPopup.Items.Add(TSeparadorMenuItem.Create(FPopup, 'sep2'));
  FPopup.Items.Add(TMenuItemFechar.Create(FPopup, ItemMenuFecharClick));
end;

procedure TShortcutManager.AtualizaItensMenuPopup(ListaAtualizacoes: TListaGruposAtalho);
var
  MenuItem: TMenuItem;
begin
  for MenuItem in FPopup.Items do
  begin
    //se for grupo
    //if (MenuItem.Count > 0) then

  end;
end;


{$REGION 'Default Events'}
procedure TShortcutManager.NovoItemMenuClick(Sender: TObject);
begin
  CriaNovoAtalho(FListaGruposAtalho);
end;

procedure TShortcutManager.ItemMenuEditarClick(Sender: TObject);
var
  ListaAtualizacoes: TListaGruposAtalho;
begin
  TfrmCadListaAtalhos.Run(FListaGruposAtalho, ListaAtualizacoes);
  AtualizaItensMenuPopup(ListaAtualizacoes);
end;

procedure TShortcutManager.ItemMenuFecharClick(Sender: TObject);
begin
  Application.Terminate;
end;
{$ENDREGION}

destructor TShortcutManager.Destroy;
begin
  FreeAndNil(FPopup);
  FreeAndNil(FListaGruposAtalho);

  inherited Destroy;
end;

end.
