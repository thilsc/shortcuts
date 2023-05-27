unit uCadAtalho;

interface

uses
  Winapi.Windows, Winapi.Messages, System.SysUtils, System.Variants, System.Classes, Vcl.Graphics,
  Vcl.Controls, Vcl.Forms, Vcl.Dialogs, Vcl.Buttons, Vcl.StdCtrls, Vcl.ExtCtrls, uAtalho;

type
  TfrmCadAtalho = class(TForm)
    edtCaminho: TEdit;
    lblCaminho: TLabel;
    opd: TOpenDialog;
    edtParametros: TEdit;
    lblParametros: TLabel;
    cbGrupo: TComboBox;
    lblGrupo: TLabel;
    btnGravar: TButton;
    btnCancelar: TButton;
    rgTipoAtalho: TRadioGroup;
    lblTipoAtalho: TLabel;
    btnProcurar: TBitBtn;
    lblNome: TLabel;
    edtNome: TEdit;
    procedure btnProcurarClick(Sender: TObject);
    procedure btnGravarClick(Sender: TObject);
    procedure btnCancelarClick(Sender: TObject);
  private
    { Private declarations }
    FAtalho: TAtalho;
    procedure Init(ListaAtalhos: TListaAtalhos; Index: Integer = -1);
    function StrToIndexGrupo(NomeGrupo: string): Integer;
    function GetNomeGrupos(ListaAtalhos: TListaAtalhos): TStrings;
    function ValidarCampos: Boolean;
    procedure PosicionaFoco(Control: TWinControl; Justificativa: string);
  public
    { Public declarations }
    function GetAtalho: TAtalho;
    class procedure Run(AListaAtalhos: TListaAtalhos; AIndex: Integer = -1);
  end;

implementation

uses System.Math, uShortcutsTypes;

{$R *.dfm}

{ TfrmCadAtalho }

class procedure TfrmCadAtalho.Run(AListaAtalhos: TListaAtalhos; AIndex: Integer);
var
  frm: TfrmCadAtalho;
begin
  frm := TfrmCadAtalho.Create(Application);
  try
    frm.Init(AListaAtalhos);

    if (frm.ShowModal = mrOk) then
    begin
      if (AIndex >= 0) then
        AListaAtalhos.Items[AIndex].CopyFrom(frm.GetAtalho)
      else
        AListaAtalhos.Add(frm.GetAtalho);
    end;

  finally
    FreeAndNil(frm);
  end;
end;

procedure TfrmCadAtalho.Init(ListaAtalhos: TListaAtalhos; Index: Integer);
begin
  cbGrupo.Items.Clear;
  cbGrupo.Items.AddStrings(GetNomeGrupos(ListaAtalhos));
(*
  if (Index >= 0) and (ListaAtalhos.Count > 0) then
  begin
    FAtalho := ListaAtalhos.Items[Index];

    cbGrupo.ItemIndex := StrToIndexGrupo(FAtalho.Grupo.Nome);
    rgTipoAtalho.ItemIndex := IfThen(FAtalho.Tipo = taArquivo, 0, 1);
    edtNome.Text := FAtalho.Nome;
    edtCaminho.Text := FAtalho.Caminho;
    edtParametros.Text := FAtalho.Parametros;

    cbGrupo.Enabled := False;
    edtNome.Enabled := False;
  end
  else
  begin
    FAtalho := TAtalho.Create;
    FAtalho.Grupo := TGrupoAtalho.Create;

    cbGrupo.ItemIndex := 0;
    rgTipoAtalho.ItemIndex := 0;
    cbGrupo.SetFocus;
  end;*)
end;

procedure TfrmCadAtalho.PosicionaFoco(Control: TWinControl; Justificativa: string);
begin
  if Control.CanFocus then
    Control.SetFocus;

  if (not Justificativa.Trim.IsEmpty) then
    MessageDlg(Justificativa.Trim, mtInformation, [mbOK], 0);
end;

function TfrmCadAtalho.ValidarCampos: Boolean;
begin
  Result := False;

  if edtNome.ToString.Trim.IsEmpty then
    PosicionaFoco(edtNome, 'Campo "Nome" precisa ser informado.')
  else
    if edtCaminho.ToString.Trim.IsEmpty then
      PosicionaFoco(edtNome, 'Campo "Caminho" precisa ser informado.')
    else
      Result := True;
end;

procedure TfrmCadAtalho.btnCancelarClick(Sender: TObject);
begin
  ModalResult := mrCancel;
end;

procedure TfrmCadAtalho.btnGravarClick(Sender: TObject);
begin
  if ValidarCampos then
    ModalResult := mrOk;
end;

procedure TfrmCadAtalho.btnProcurarClick(Sender: TObject);
begin
  if opd.Execute then
    edtCaminho.Text := opd.FileName;
end;

function TfrmCadAtalho.GetAtalho: TAtalho;
begin
  Result := FAtalho;
end;

function TfrmCadAtalho.GetNomeGrupos(ListaAtalhos: TListaAtalhos): TStrings;
var
  obj: TAtalho;
begin
  Result := TStringList.Create;

(*  for obj in ListaAtalhos do
    Result.Add(obj.Grupo.Nome);

  if (Result.Count = 0) then
    Result.Add('GERAL');*)
end;

function TfrmCadAtalho.StrToIndexGrupo(NomeGrupo: string): Integer;
var
  I: Integer;
begin
  Result := -1;

  for I := 0 to Pred(cbGrupo.Items.Count) do
    if (cbGrupo.Items[I] = NomeGrupo) then
    begin
      Result := I;
      Break;
    end;
end;

end.
