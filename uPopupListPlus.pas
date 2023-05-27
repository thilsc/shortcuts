unit uPopupListPlus;

interface

uses System.Classes, uMenuItemPlus, Vcl.Menus, Winapi.Messages, WinApi.Windows;

type
  TCustomPopupList = class(TPopupList)
  private
    FCallContextMenu: Boolean;
    procedure RightButtonClick(var Message: TMessage);
  protected
    procedure WndProc(var Message: TMessage); override;
  public
    constructor Create; reintroduce;
  end;

implementation


{ TCustomPopupList }

procedure TCustomPopupList.WndProc(var Message: TMessage);
begin
  case Message.Msg of

    WM_ENTERIDLE: //WM_COMMAND:
    begin
      // Botão direito do mouse foi clicado
      if ((GetKeyState(VK_RBUTTON) and $8000) <> 0) then
        FCallContextMenu := True;

      inherited WndProc(Message);
    end;

    WM_COMMAND:
      if FCallContextMenu then
      begin
        RightButtonClick(Message);
        FCallContextMenu := False;
      end
      else
        inherited WndProc(Message);
  else
    inherited WndProc(Message);
  end;
end;

constructor TCustomPopupList.Create;
begin
  inherited Create;
  FCallContextMenu := False;
end;

procedure TCustomPopupList.RightButtonClick(var Message: TMessage);
var
  Item: TMenuItem;
  I: Integer;
begin
  for I := 0 to Pred(Count) do
  begin
    Item := TPopupMenu(Items[I]).FindItem(Message.wParam, fkCommand);

    if (Item <> nil) then
    begin
      if (Item is TMenuItemPlus) then
        (Item as TMenuItemPlus).ContextMenuClick
      else
        Item.Click;
      Break;
    end;
  end;
end;

initialization

  if Assigned(Vcl.Menus.PopupList) then
    Vcl.Menus.PopupList.Free;

  Vcl.Menus.PopupList := TCustomPopupList.Create;
end.
