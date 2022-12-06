object Form1: TForm1
  Left = 0
  Top = 0
  BorderIcons = [biSystemMenu, biMinimize]
  Caption = 'Einstein WebDoc'
  ClientHeight = 235
  ClientWidth = 858
  Color = clBtnFace
  Font.Charset = DEFAULT_CHARSET
  Font.Color = clWindowText
  Font.Height = -11
  Font.Name = 'Tahoma'
  Font.Style = []
  OldCreateOrder = False
  WindowState = wsMinimized
  OnClose = FormClose
  OnCreate = FormCreate
  PixelsPerInch = 96
  TextHeight = 13
  object Memo1: TMemo
    Left = 8
    Top = 8
    Width = 842
    Height = 153
    Lines.Strings = (
      'Memo1')
    TabOrder = 0
  end
  object gtPDFPrinter1: TgtPDFPrinter
    Collate = True
    Options = [poPageNums]
    About = 'Gnostice PDFtoolkit (www.gnostice.com)'
    PDFDocument = gtPDFDocument1
    Version = '5.0.0.851'
    AutoRotate = False
    IgnoreHardMargin = False
    RenderingOptions = []
    Left = 343
    Top = 112
  end
  object gtPDFDocument1: TgtPDFDocument
    About = 'Gnostice PDFtoolkit (www.gnostice.com)'
    Version = '5.0.0.851'
    OpenAfterSave = False
    MergeOptions = []
    EMailAfterSave = False
    ShowSetupDialog = False
    Left = 447
    Top = 112
  end
  object JvTrayIcon1: TJvTrayIcon
    Active = True
    IconIndex = 0
    Visibility = [tvVisibleTaskBar, tvVisibleTaskList, tvAutoHide, tvRestoreDbClick]
    Left = 400
    Top = 176
  end
end
