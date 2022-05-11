object Form1: TForm1
  Left = 0
  Top = 0
  Caption = 'Form1'
  ClientHeight = 278
  ClientWidth = 604
  Color = clBtnFace
  Font.Charset = DEFAULT_CHARSET
  Font.Color = clWindowText
  Font.Height = -11
  Font.Name = 'Tahoma'
  Font.Style = []
  OldCreateOrder = False
  PixelsPerInch = 96
  TextHeight = 13
  object memOutput: TMemo
    Left = 0
    Top = 0
    Width = 604
    Height = 257
    Align = alClient
    Color = clNavy
    Font.Charset = DEFAULT_CHARSET
    Font.Color = 8454143
    Font.Height = -11
    Font.Name = 'Courier'
    Font.Style = []
    ParentFont = False
    ReadOnly = True
    ScrollBars = ssBoth
    TabOrder = 1
  end
  object edtInput: TEdit
    Left = 0
    Top = 257
    Width = 604
    Height = 21
    Align = alBottom
    TabOrder = 0
    Text = 'chkdsk.exe c:\'
    OnKeyDown = edtInputKeyDown
  end
end
