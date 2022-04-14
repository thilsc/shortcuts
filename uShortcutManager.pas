unit uShortcutManager;

interface

uses System.Classes, System.Types, System.SysUtils, Vcl.Forms, Vcl.Menus,
  Vcl.Controls, Vcl.Graphics, Vcl.ExtCtrls;

type
  TTipoItemMenu = (timNone, timURL, timFile, timExe, timText);
  TTipoItemMenuDefault = (timdNone, timdEditar, timdAtualizar, timdFechar);
  TArrayDefaultEvents = array[TTipoItemMenuDefault] of TNotifyEvent;

  TShortcutManager = class
  private
    FListaItens: TStringList;
    FDefaultItems: TStringList;
    FDefaultEvents: TArrayDefaultEvents;
    FConfigFile: string;
    FPopup: TPopupMenu;
    function GetImageIndexItemMenu(ItemLink: string): TTipoItemMenu;
    function GetImageIndexItemMenuDefault(TextValue: string): TTipoItemMenuDefault;
    procedure CriaItensMenuPopup;
    procedure ItemMenuPopupClick(Sender: TObject);
    procedure ItemMenuEditarClick(Sender: TObject);
    procedure ItemMenuAtualizarClick(Sender: TObject);
    procedure ItemMenuFecharClick(Sender: TObject);
    function GetNewInstanceItemMenu: TMenuItem;
    procedure SetDefaultEvents;
  public
    property PopupMenu: TPopupMenu read FPopup;
    procedure Load(AConfigFile: string);
    constructor Create(AListaImagens: TImageList); overload;
    destructor Destroy; override;
  end;

  TTitlePopupMenu = class(TMenuItem)
  private
    FImage: TImage;
  public
    procedure DrawPopupTitle(Sender: TObject; ACanvas: TCanvas; ARect: TRect; Selected: Boolean);
    procedure MeasureItemPopupTitle(Sender: TObject; ACanvas: TCanvas; var Width, Height: Integer);

    constructor Create(AOwner: TComponent; AImageFile: string); reintroduce;
  end;

const
  PREFIXO_ITEM_NAME = 'Item_';
  PREFIXO_ITEM_DEFAULT = 'mnu_';
  IMAGE_INDEX_NONE = -1;
  IMAGE_INDEX_APP = 0;
  IMAGE_INDEX_FECHAR = 1;
  IMAGE_INDEX_URL = 2;
  IMAGE_INDEX_FILE = 3;
  IMAGE_INDEX_EXE = 4;
  IMAGE_INDEX_REFRESH = 5;
  IMAGE_INDEX_TEXT = 6;
  ITEM_MENU_SEP = '-';
  NAME_DEFAULT  = 'DEFAULT';

  ITEM_MENU_EDITAR = 'Editar Lista...';
  ITEM_MENU_ATUALIZAR = 'Atualizar';
  ITEM_MENU_FECHAR = 'Fechar';

  ArrayTipoItemMenuImageIndex: array[TTipoItemMenu] of Integer = (IMAGE_INDEX_NONE, IMAGE_INDEX_URL, IMAGE_INDEX_FILE, IMAGE_INDEX_EXE, IMAGE_INDEX_TEXT);
  ArrayItemMenuDefault: array[TTipoItemMenuDefault] of string = ('', ITEM_MENU_EDITAR, ITEM_MENU_ATUALIZAR, ITEM_MENU_FECHAR);
  ArrayItemMenuDefaultImageIndex: array[TTipoItemMenuDefault] of Integer = (IMAGE_INDEX_NONE, IMAGE_INDEX_TEXT, IMAGE_INDEX_REFRESH, IMAGE_INDEX_FECHAR);

implementation

uses Winapi.Windows, Winapi.ShellAPI;

{ TShortcutManager }

constructor TShortcutManager.Create(AListaImagens: TImageList);
begin
  inherited Create;
  FListaItens   := TStringList.Create;
  FDefaultItems := TStringList.Create;

  FPopup := TPopupMenu.Create(AListaImagens.Owner);
  FPopup.Images := AListaImagens;
  FPopup.OwnerDraw := True;

  SetDefaultEvents;
end;

procedure TShortcutManager.SetDefaultEvents;
begin
  FDefaultEvents[timdEditar]    := ItemMenuEditarClick;
  FDefaultEvents[timdAtualizar] := ItemMenuAtualizarClick;
  FDefaultEvents[timdFechar]    := ItemMenuFecharClick;

  FDefaultItems.Add(NAME_DEFAULT+'='+ITEM_MENU_SEP);
  FDefaultItems.Add(NAME_DEFAULT+'='+ITEM_MENU_EDITAR);
  FDefaultItems.Add(NAME_DEFAULT+'='+ITEM_MENU_ATUALIZAR);
  FDefaultItems.Add(NAME_DEFAULT+'='+ITEM_MENU_SEP);
  FDefaultItems.Add(NAME_DEFAULT+'='+ITEM_MENU_FECHAR);
end;

function TShortcutManager.GetImageIndexItemMenu(ItemLink: string): TTipoItemMenu;
begin
  if (Pos('http', ItemLink) = 1) then
    Result := timURL
  else
    if (Pos('.exe', ItemLink) > 0) then
      Result := timExe
    else
      if (Pos('.txt', ItemLink) > 0) or
         (Pos('.ini', ItemLink) > 0) or
         (Pos('.cfg', ItemLink) > 0) then
        Result := timText
      else
        Result := timFile;
end;

function TShortcutManager.GetImageIndexItemMenuDefault(TextValue: string): TTipoItemMenuDefault;
var
  I: TTipoItemMenuDefault;
begin
  Result := timdNone;
  for I := Low(TTipoItemMenuDefault) to High(TTipoItemMenuDefault) do
    if (TextValue = ArrayItemMenuDefault[I]) then
    begin
      Result := I;
      Break;
    end;
end;

procedure TShortcutManager.Load(AConfigFile: string);
begin
  if FileExists(AConfigFile) then
  begin
    FConfigFile := AConfigFile;

    FListaItens.Clear;
    FListaItens.LoadFromFile(AConfigFile);

    //Adicionando Itens Default à lista
    FListaItens.AddStrings(FDefaultItems);
  end;

  CriaItensMenuPopup;
end;

procedure TShortcutManager.CriaItensMenuPopup;
var
  I: Integer;
begin
  FPopup.Items.Clear;
  FPopup.Items.Add(TTitlePopupMenu.Create(FPopup, 'title.png'));

  for I := 0 to Pred(FListaItens.Count) do
    if ((FListaItens.Names[I] <> EmptyStr) and
        (FListaItens.ValueFromIndex[I] <> EmptyStr)) then
      with GetNewInstanceItemMenu do
        if (FListaItens.Names[I] = NAME_DEFAULT) then
        begin
          Name       := PREFIXO_ITEM_DEFAULT+I.ToString;
          Caption    := FListaItens.ValueFromIndex[I];
          ImageIndex := ArrayItemMenuDefaultImageIndex[GetImageIndexItemMenuDefault(FListaItens.ValueFromIndex[I])];
          OnClick    := FDefaultEvents[GetImageIndexItemMenuDefault(FListaItens.ValueFromIndex[I])];
        end
        else
        begin
          Name       := PREFIXO_ITEM_NAME+I.ToString;
          Caption    := FListaItens.Names[I];
          ImageIndex := ArrayTipoItemMenuImageIndex[GetImageIndexItemMenu(FListaItens.ValueFromIndex[I])];
          OnClick    := ItemMenuPopupClick;
        end;
end;

function TShortcutManager.GetNewInstanceItemMenu: TMenuItem;
begin
  FPopup.Items.Add(TMenuItem.Create(FPopup));
  Result := FPopup.Items[Pred(FPopup.Items.Count)];
end;

procedure TShortcutManager.ItemMenuPopupClick(Sender: TObject);
var
  MenuItem: TMenuItem;
  I: Integer;
begin
  if (not (Sender is TMenuItem)) then
    Exit;

  MenuItem := (Sender as TMenuItem);
  I := StrToIntDef(Copy(MenuItem.Name, Length(PREFIXO_ITEM_NAME)+1, Length(MenuItem.Name)-Length(PREFIXO_ITEM_NAME)), -1);

  if (I >= 0) then
    ShellExecute(Application.Handle, 'open', PWideChar(FListaItens.ValueFromIndex[I]), nil, nil, SW_SHOWMAXIMIZED);
end;

{$REGION 'Default Events'}
procedure TShortcutManager.ItemMenuEditarClick(Sender: TObject);
begin
  if FileExists(FConfigFile) then
    ShellExecute(Application.Handle, 'open', PWideChar(FConfigFile), nil, nil, SW_SHOWMAXIMIZED);
end;

procedure TShortcutManager.ItemMenuAtualizarClick(Sender: TObject);
begin
  Load(FConfigFile);
end;

procedure TShortcutManager.ItemMenuFecharClick(Sender: TObject);
begin
  Application.Terminate;
end;
{$ENDREGION}

destructor TShortcutManager.Destroy;
begin
  FreeAndNil(FListaItens);
  FreeAndNil(FDefaultItems);
  FreeAndNil(FPopup);

  inherited Destroy;
end;

{ TTitlePopupMenu }

constructor TTitlePopupMenu.Create(AOwner: TComponent; AImageFile: string);
begin
  inherited Create(AOwner);
  OnDrawItem := DrawPopupTitle;
  OnMeasureItem := MeasureItemPopupTitle;

  FImage := TImage.Create(AOwner);
  if FileExists(AImageFile) then
    FImage.Picture.LoadFromFile(AImageFile)
  else
    Caption := 'Menu';
end;

procedure TTitlePopupMenu.MeasureItemPopupTitle(Sender: TObject; ACanvas: TCanvas;
  var Width, Height: Integer);
begin
  if Assigned(FImage.Picture.Graphic) then
  begin
    Width  := FImage.Picture.Width -14;
    Height := FImage.Picture.Height;
  end;
end;

procedure TTitlePopupMenu.DrawPopupTitle(Sender: TObject; ACanvas: TCanvas;
    ARect: TRect; Selected: Boolean);
begin
  if Assigned(FImage.Picture.Graphic) then
  begin
    ACanvas.FillRect(ARect);
    ACanvas.Draw(0, 0, FImage.Picture.Graphic);
  end;
end;

end.
