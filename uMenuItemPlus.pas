unit uMenuItemPlus;

interface

uses System.Classes, Vcl.Menus, Winapi.Windows, Winapi.Messages, System.UITypes, uAtalho, uShortcutsTypes;

type
  TMenuItemPlus = class(TMenuItem)
  private
    FAtalho: TAtalho;
    FTipoItemMenu: TTipoItemMenu;
    procedure ItemMenuPopupClick(Sender: TObject);
  public
    property TipoItemMenu: TTipoItemMenu read FTipoItemMenu write FTipoItemMenu;
    property Atalho: TAtalho read FAtalho write FAtalho;

    procedure ContextMenuClick;

    constructor Create(AOwner: TComponent; AAtalho: TAtalho; AImageIndex: TImageIndex); reintroduce; overload;
    constructor Create(AOwner: TComponent; AGrupoAtalho: TGrupoAtalho); overload;
  end;

  TDefaultMenuItem = class(TMenuItemPlus)
  public
    //
  end;

  TSeparadorMenuItem = class(TDefaultMenuItem)
  public
    constructor Create(AOwner: TComponent; AName: string); reintroduce;
  end;

  TMenuItemEditar = class(TDefaultMenuItem)
  public
    constructor Create(AOwner: TComponent; AEventOnClick: TNotifyEvent); reintroduce;
  end;

  TMenuItemAtualizar = class(TDefaultMenuItem)
  public
    constructor Create(AOwner: TComponent; AEventOnClick: TNotifyEvent); reintroduce;
  end;

  TMenuItemNovoItem = class(TDefaultMenuItem)
  public
    constructor Create(AOwner: TComponent; AEventOnClick: TNotifyEvent); reintroduce;
  end;

  TMenuItemFechar = class(TDefaultMenuItem)
  public
    constructor Create(AOwner: TComponent; AEventOnClick: TNotifyEvent); reintroduce;
  end;

implementation

uses uShortcutsConsts, uShortcutsUtils;

{ TMenuItemPlus }

constructor TMenuItemPlus.Create(AOwner: TComponent; AAtalho: TAtalho; AImageIndex: TImageIndex);
begin
  inherited Create(AOwner);

  ImageIndex := AImageIndex;
  OnClick := ItemMenuPopupClick;

  if Assigned(AAtalho) then
  begin
    FAtalho    := AAtalho;
    Name       := PREFIXO_ITEM_DEFAULT+StrToComponentName(FAtalho.Nome);
    Caption    := FAtalho.Nome;
    FTipoItemMenu := GetImageIndexItemMenu(FAtalho.Caminho);
  end;
end;

constructor TMenuItemPlus.Create(AOwner: TComponent; AGrupoAtalho: TGrupoAtalho);
begin
  inherited Create(AOwner);
  Name    := PREFIXO_GRUPO_DEFAULT + StrToComponentName(AGrupoAtalho.Nome);
  Caption := AGrupoAtalho.Nome;
end;

procedure TMenuItemPlus.ItemMenuPopupClick(Sender: TObject);
var
  MenuItem: TMenuItemPlus;
begin
  MenuItem := (Sender as TMenuItemPlus);

  if Assigned(MenuItem.Atalho) then
    ExecutarAtalho(MenuItem.Atalho.Caminho);
end;

procedure TMenuItemPlus.ContextMenuClick;
begin
  ExibeMenuItemContexto(Self);
end;

{ TSeparadorMenuItem }

constructor TSeparadorMenuItem.Create(AOwner: TComponent; AName: string);
begin
  inherited Create(AOwner, nil, -1);
  Name    := PREFIXO_ITEM_DEFAULT+AName;
  Caption := ITEM_MENU_SEP;
end;

{ TMenuItemEditar }

constructor TMenuItemEditar.Create(AOwner: TComponent; AEventOnClick: TNotifyEvent);
begin
  inherited Create(AOwner, nil, -1);
  Name       := PREFIXO_ITEM_DEFAULT+StrToComponentName(ITEM_MENU_EDITAR);
  Caption    := ITEM_MENU_EDITAR;
  ImageIndex := ArrayItemMenuDefaultImageIndex[timdEditar];
  OnClick    := AEventOnClick;

  {$IFNDEF DEBUG}
  Enabled := False;
  {$ENDIF}
end;

{ TMenuItemAtualizar }

constructor TMenuItemAtualizar.Create(AOwner: TComponent; AEventOnClick: TNotifyEvent);
begin
  inherited Create(AOwner, nil, -1);
  Name       := PREFIXO_ITEM_DEFAULT+StrToComponentName(ITEM_MENU_ATUALIZAR);
  Caption    := ITEM_MENU_ATUALIZAR;
  ImageIndex := ArrayItemMenuDefaultImageIndex[timdAtualizar];
  OnClick    := AEventOnClick;
end;

{ TMenuItemNovoItem }

constructor TMenuItemNovoItem.Create(AOwner: TComponent; AEventOnClick: TNotifyEvent);
begin
  inherited Create(AOwner, nil, -1);
  Name       := PREFIXO_ITEM_DEFAULT+StrToComponentName(ITEM_MENU_NOVO_ITEM);
  Caption    := ITEM_MENU_NOVO_ITEM;
  ImageIndex := ArrayItemMenuDefaultImageIndex[timdNovoItem];
  OnClick    := AEventOnClick;

  {$IFNDEF DEBUG}
  Enabled := False;
  {$ENDIF}
end;

{ TMenuItemFechar }

constructor TMenuItemFechar.Create(AOwner: TComponent; AEventOnClick: TNotifyEvent);
begin
  inherited Create(AOwner, nil, -1);
  Name       := PREFIXO_ITEM_DEFAULT+StrToComponentName(ITEM_MENU_FECHAR);
  Caption    := ITEM_MENU_FECHAR;
  ImageIndex := ArrayItemMenuDefaultImageIndex[timdFechar];
  OnClick    := AEventOnClick;
end;

end.
