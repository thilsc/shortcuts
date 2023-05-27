unit uAtalho;

interface

uses System.Classes, System.SysUtils, Generics.Collections;

type
  TTipoAtalho = (taArquivo, taURL);

  TAtalho = class
  private
    FParametros: string;
    FNome: string;
    FTipo: TTipoAtalho;
    FCaminho: string;
  public
    property Nome: string read FNome write FNome;
    property Caminho: string read FCaminho write FCaminho;
    property Tipo: TTipoAtalho read FTipo write FTipo;
    property Parametros: string read FParametros write FParametros;
  end;

  TListaAtalhos = class(TObjectList<TAtalho>);

  TGrupoAtalho = class
  private
    FNome: string;
    FAtalhos: TListaAtalhos;
  public
    property Nome: string read FNome write FNome;
    property Atalhos: TListaAtalhos read FAtalhos write FAtalhos;

    constructor Create; reintroduce;
    destructor Destroy; override;
  end;

  TListaGruposAtalho = class(TObjectList<TGrupoAtalho>);

implementation

{ TGrupoAtalho }

constructor TGrupoAtalho.Create;
begin
  FAtalhos := TListaAtalhos.Create(True);
end;

destructor TGrupoAtalho.Destroy;
begin
  if Assigned(FAtalhos) then
    FreeAndNil(FAtalhos);

  inherited Destroy;
end;

end.
