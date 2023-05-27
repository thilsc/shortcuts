unit uTitlePopupMenu;

interface

uses System.Classes, System.SysUtils, System.Types, Vcl.Controls, Vcl.ExtCtrls, Vcl.Graphics, Vcl.Menus;

type
  TTitlePopupMenu = class(TMenuItem)
  private
    FImage: TImage;
  public
    procedure DrawPopupTitle(Sender: TObject; ACanvas: TCanvas; ARect: TRect; Selected: Boolean);
    procedure MeasureItemPopupTitle(Sender: TObject; ACanvas: TCanvas; var Width, Height: Integer);

    constructor Create(AOwner: TComponent; AImageFile: string); reintroduce;
  end;

implementation

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
