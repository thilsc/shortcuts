object frmCadListaAtalhos: TfrmCadListaAtalhos
  Left = 44
  Top = 59
  Caption = 'Editar Lista de Atalhos'
  ClientHeight = 257
  ClientWidth = 732
  Color = clBtnFace
  Font.Charset = DEFAULT_CHARSET
  Font.Color = clWindowText
  Font.Height = -11
  Font.Name = 'Tahoma'
  Font.Style = []
  Position = poDesigned
  DesignSize = (
    732
    257)
  TextHeight = 13
  object grid: TDBGrid
    Left = 8
    Top = 32
    Width = 708
    Height = 217
    TabStop = False
    Anchors = [akLeft, akTop, akRight, akBottom]
    DataSource = dsGrid
    Options = [dgTitles, dgIndicator, dgColumnResize, dgColLines, dgRowLines, dgTabs, dgRowSelect, dgConfirmDelete, dgCancelOnExit, dgTitleClick, dgTitleHotTrack]
    TabOrder = 0
    TitleFont.Charset = DEFAULT_CHARSET
    TitleFont.Color = clWindowText
    TitleFont.Height = -11
    TitleFont.Name = 'Tahoma'
    TitleFont.Style = []
    OnDblClick = gridDblClick
    Columns = <
      item
        Expanded = False
        FieldName = 'secao'
        Title.Caption = 'Se'#231#227'o'
        Width = 101
        Visible = True
      end
      item
        Expanded = False
        FieldName = 'nome'
        Title.Caption = 'Nome'
        Width = 166
        Visible = True
      end
      item
        Expanded = False
        FieldName = 'valor'
        Title.Caption = 'Valor'
        Width = 423
        Visible = True
      end>
  end
  object cbLookupSecoes: TComboBox
    Left = 8
    Top = 8
    Width = 193
    Height = 21
    Style = csDropDownList
    TabOrder = 1
    TabStop = False
    OnChange = cbLookupSecoesChange
  end
  object Button1: TButton
    Left = 223
    Top = 8
    Width = 75
    Height = 21
    Caption = 'Novo'
    TabOrder = 2
    OnClick = Button1Click
  end
  object Button2: TButton
    Left = 304
    Top = 8
    Width = 75
    Height = 21
    Caption = 'Excluir'
    TabOrder = 3
    OnClick = Button2Click
  end
  object dsGrid: TDataSource
    Left = 56
    Top = 88
  end
end
