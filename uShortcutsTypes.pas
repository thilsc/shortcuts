unit uShortcutsTypes;

interface

uses
  System.Classes, uAtalho;

type
  TTipoItemMenu = (timNone, timURL, timFile, timExe, timText);

  TTipoItemMenuDefault = (timdNone, timdEditar, timdAtualizar, timdNovoItem, timdFechar);

  TArrayDefaultEvents = array[TTipoItemMenuDefault] of TNotifyEvent;

  TArrayString = array of string;

  TArrayStringHelper = record helper for TArrayString
  public
    function ToString: string; inline;
  end;

  TGrupoAtalhoHelper = class helper for TGrupoAtalho
  public
    procedure CopyFrom(obj: TGrupoAtalho);
  end;

  TAtalhoHelper = class helper for TAtalho
  public
    procedure CopyFrom(obj: TAtalho);
  end;

implementation

uses System.SysUtils, uShortcutsConsts, uShortcutsUtils;

{ TArrayStringHelper }

function TArrayStringHelper.ToString: string;
var
  str: string;
begin
  Result := EmptyStr;
  for str in Self do
    Result := Result + str + ' ';

end;

{ TGrupoAtalhoHelper }

procedure TGrupoAtalhoHelper.CopyFrom(obj: TGrupoAtalho);
begin
  Self.Nome := obj.Nome;
end;

{ TAtalhoHelper }

procedure TAtalhoHelper.CopyFrom(obj: TAtalho);
begin
  Self.Nome        := obj.Nome;
  Self.Caminho     := obj.Caminho;
  Self.Tipo        := obj.Tipo;
  Self.Parametros  := obj.Parametros;
  //Self.Grupo.CopyFrom(obj.Grupo);
end;

end.
