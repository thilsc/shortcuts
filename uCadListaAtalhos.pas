unit uCadListaAtalhos;

interface

uses
  Windows, Messages, SysUtils, Variants, Classes, Graphics, Controls, Forms,
  Dialogs, StdCtrls, Grids, DBGrids, DBCtrls, DB, IniFiles, Datasnap.DBClient, uAtalho;

type
  TfrmCadListaAtalhos = class(TForm)
    grid: TDBGrid;
    cbLookupSecoes: TComboBox;
    dsGrid: TDataSource;
    Button1: TButton;
    Button2: TButton;
    procedure Button1Click(Sender: TObject);
    procedure Button2Click(Sender: TObject);
    procedure cbLookupSecoesChange(Sender: TObject);
    procedure gridDblClick(Sender: TObject);
  private
    { Private declarations }
    FGruposAtalho: TListaGruposAtalho;
    FcdsChaves: TClientDataSet;
    FListaAlteracoes: TListaGruposAtalho;

    procedure CarregarListaGruposAtalho(ListaGruposAtalho: TListaGruposAtalho);
    procedure CarregarChaves;
    procedure AtualizarChave(nome, valor, secao: string);
    procedure InserirChave;
    procedure ExcluirChave;
    procedure EditarChave;
  public
    { Public declarations }
    property ListaAlteracoes: TListaGruposAtalho read FListaAlteracoes;

    constructor Create(AOwner: TComponent); reintroduce;
    destructor Destroy; override;

    class procedure Run(Lista, ListaAlteracoes: TListaGruposAtalho);
  end;

implementation

uses uCadAtalho;

{$R *.dfm}

{ TfrmCadListaAtalhos }

class procedure TfrmCadListaAtalhos.Run(Lista, ListaAlteracoes: TListaGruposAtalho);
var
  frm: TfrmCadListaAtalhos;
begin
  frm := TfrmCadListaAtalhos.Create(Application);
  try
    frm.CarregarListaGruposAtalho(Lista);

    ListaAlteracoes := TListaGruposAtalho.Create(True);
    if (frm.ShowModal = mrOk) then
      ListaAlteracoes := frm.ListaAlteracoes;

  finally
    FreeAndNil(frm);
  end;
end;

constructor TfrmCadListaAtalhos.Create(AOwner: TComponent);
begin
  inherited Create(AOwner);

  FcdsChaves := TClientDataSet.Create(Self);
  FcdsChaves.FieldDefs.Add('nome', ftString, 1024, True);
  FcdsChaves.FieldDefs.Add('valor', ftString, 1024, True);
  FcdsChaves.FieldDefs.Add('secao', ftString, 32, True);
  FcdsChaves.CreateDataSet;
  dsGrid.DataSet := FcdsChaves;
end;

procedure TfrmCadListaAtalhos.CarregarListaGruposAtalho(ListaGruposAtalho: TListaGruposAtalho);
begin
  FGruposAtalho := ListaGruposAtalho;

  CarregarChaves;
end;

procedure TfrmCadListaAtalhos.CarregarChaves;
var
  Atalho: TAtalho;
  GrupoAtalho: TGrupoAtalho;
  lstChaves: TStringList;
  i, j: Integer;
begin
  cbLookupSecoes.Items.Clear;
  lstChaves := TStringList.Create;
  try
    FcdsChaves.DisableControls;


//    FIniFile.ReadSections(cbLookupSecoes.Items);
//    cbLookupSecoes.Items.Insert(0, 'Todos');
//
//    for i := 1 to Pred(cbLookupSecoes.Items.Count) do
//    begin
//      FIniFile.ReadSection(cbLookupSecoes.Items[i], lstChaves);
//      GrupoAtalho := TGrupoAtalho.Create;
//
//      for j := 0 to Pred(lstChaves.Count) do
//      begin
//        Atalho := TAtalho.Create;
//        Atalho.Nome := lstChaves[j];
//        Atalho.Caminho := FIniFile.ReadString(cbLookupSecoes.Items[i], lstChaves[j], EmptyStr);
//        //Atalho.Tipo := ;
//        //Atalho.Parametros := ;
//        GrupoAtalho.Atalhos.Add(Atalho);
//
//        FcdsChaves.Append;
//        FcdsChaves.FieldByName('nome').AsString := lstChaves[j];
//        FcdsChaves.FieldByName('valor').AsString := FIniFile.ReadString(cbLookupSecoes.Items[i], lstChaves[j], EmptyStr);
//        FcdsChaves.FieldByName('secao').AsString := cbLookupSecoes.Items[i];
//        FcdsChaves.Post;
//      end;
//
//      FGruposAtalho.Add(GrupoAtalho);
//    end;

    cbLookupSecoes.ItemIndex := 0;
  finally
    FcdsChaves.EnableControls;
    lstChaves.Free;
  end;
end;

procedure TfrmCadListaAtalhos.cbLookupSecoesChange(Sender: TObject);
begin
  if cbLookupSecoes.ItemIndex = 0 then
    FcdsChaves.Filtered := False
  else
  begin
    FcdsChaves.Filter := 'secao = ''' + cbLookupSecoes.Items[cbLookupSecoes.ItemIndex] + '''';
    FcdsChaves.Filtered := True;
  end;

  grid.Columns[0].Visible := not FcdsChaves.Filtered; //Exibe a coluna 'Seção' quando estiver na opção 'Todos'
end;

procedure TfrmCadListaAtalhos.gridDblClick(Sender: TObject);
begin
  if not FcdsChaves.IsEmpty then
    EditarChave;
end;

procedure TfrmCadListaAtalhos.EditarChave;
begin

end;

procedure TfrmCadListaAtalhos.AtualizarChave;
begin
//  if not FcdsChaves.IsEmpty then
//  begin
//    FcdsChaves.Edit;
    //cdsChaves.FieldByName('nome').AsString := edtNome.Text;
    //cdsChaves.FieldByName('valor').AsString := edtValor.Text;
    //cdsChaves.FieldByName('secao').AsString := cdsSecoes.FieldByName('secao').AsString;
//    FcdsChaves.Post;
//  end;
end;

procedure TfrmCadListaAtalhos.InserirChave;
begin
//  FcdsChaves.Append;
//  FcdsChaves.FieldByName('nome').AsString := '';
//  FcdsChaves.FieldByName('valor').AsString := '';
//  FcdsChaves.FieldByName('secao').AsString := cbLookupSecoes.Items[cbLookupSecoes.ItemIndex];
//  FcdsChaves.Post;
end;

procedure TfrmCadListaAtalhos.ExcluirChave;
begin
//  if not cdsChaves.IsEmpty then
//    cdsChaves.Delete;
end;

procedure TfrmCadListaAtalhos.Button1Click(Sender: TObject);
begin
//  InserirChave;
//  DBGrid1.SetFocus;
end;

procedure TfrmCadListaAtalhos.Button2Click(Sender: TObject);
begin
//  ExcluirChave;
//  DBGrid1.SetFocus;
end;

destructor TfrmCadListaAtalhos.Destroy;
begin
  if Assigned(FGruposAtalho) then
    FreeAndNil(FGruposAtalho);

  inherited Destroy;
end;

end.
