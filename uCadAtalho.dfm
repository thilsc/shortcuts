object frmCadAtalho: TfrmCadAtalho
  Left = 0
  Top = 0
  BorderStyle = bsDialog
  Caption = 'Adicionar/Editar Atalho'
  ClientHeight = 188
  ClientWidth = 447
  Color = clBtnFace
  Font.Charset = DEFAULT_CHARSET
  Font.Color = clWindowText
  Font.Height = -12
  Font.Name = 'Segoe UI'
  Font.Style = []
  TextHeight = 15
  object lblCaminho: TLabel
    Left = 17
    Top = 98
    Width = 49
    Height = 15
    Alignment = taRightJustify
    Caption = 'Caminho'
  end
  object lblParametros: TLabel
    Left = 6
    Top = 127
    Width = 60
    Height = 15
    Alignment = taRightJustify
    Caption = 'Par'#226'metros'
  end
  object lblGrupo: TLabel
    Left = 33
    Top = 9
    Width = 33
    Height = 15
    Alignment = taRightJustify
    Caption = 'Grupo'
  end
  object lblTipoAtalho: TLabel
    Left = 43
    Top = 68
    Width = 23
    Height = 15
    Alignment = taRightJustify
    Caption = 'Tipo'
  end
  object lblNome: TLabel
    Left = 34
    Top = 36
    Width = 33
    Height = 15
    Alignment = taRightJustify
    Caption = 'Nome'
  end
  object edtCaminho: TEdit
    Left = 72
    Top = 95
    Width = 374
    Height = 23
    TabOrder = 3
  end
  object edtParametros: TEdit
    Left = 72
    Top = 124
    Width = 374
    Height = 23
    TabOrder = 5
  end
  object cbGrupo: TComboBox
    Left = 72
    Top = 6
    Width = 374
    Height = 23
    Style = csDropDownList
    TabOrder = 0
  end
  object btnGravar: TButton
    Left = 152
    Top = 156
    Width = 75
    Height = 25
    Caption = 'Gravar'
    TabOrder = 6
    OnClick = btnGravarClick
  end
  object btnCancelar: TButton
    Left = 233
    Top = 156
    Width = 75
    Height = 25
    Caption = 'Cancelar'
    TabOrder = 7
    OnClick = btnCancelarClick
  end
  object rgTipoAtalho: TRadioGroup
    Left = 72
    Top = 60
    Width = 374
    Height = 31
    Columns = 2
    DefaultHeaderFont = False
    HeaderFont.Charset = DEFAULT_CHARSET
    HeaderFont.Color = clWindowText
    HeaderFont.Height = -1
    HeaderFont.Name = 'Segoe UI'
    HeaderFont.Style = []
    Items.Strings = (
      'Aplicativo/Arquivo BAT        '
      'URL')
    TabOrder = 2
  end
  object btnProcurar: TBitBtn
    Left = 423
    Top = 95
    Width = 23
    Height = 23
    Caption = '...'
    TabOrder = 4
    OnClick = btnProcurarClick
  end
  object edtNome: TEdit
    Left = 72
    Top = 33
    Width = 374
    Height = 23
    TabOrder = 1
  end
  object opd: TOpenDialog
    DefaultExt = '*.exe'
    Filter = 'Aplicativo|*.exe|Arquivo de lote|*.bat'
    Left = 398
    Top = 119
  end
end
