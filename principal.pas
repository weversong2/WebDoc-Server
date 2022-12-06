unit principal;

interface

uses
  Winapi.Windows, Winapi.Messages, System.SysUtils, System.Variants,
  System.Classes, Vcl.Graphics,
  Vcl.Controls, Vcl.Forms, Vcl.Dialogs, Horse, System.JSON, gtPDFPrinter,
  Horse.Jhonson,
  Vcl.StdCtrls, gtPDFClasses, gtCstPDFDoc, gtExPDFDoc, gtExProPDFDoc, gtPDFDoc,
  System.NetEncoding,
  Horse.CORS, ShellApi, Vcl.ExtCtrls, JvComponentBase, JvTrayIcon, IniFiles;

type
  TForm1 = class(TForm)
    gtPDFPrinter1: TgtPDFPrinter;
    Memo1: TMemo;
    gtPDFDocument1: TgtPDFDocument;
    JvTrayIcon1: TJvTrayIcon;
    procedure FormCreate(Sender: TObject);
    procedure FormClose(Sender: TObject; var Action: TCloseAction);
  private
    { Private declarations }
  public
    { Public declarations }
  end;

var
  Form1: TForm1;
  data: TInifile;
  porta: String;

implementation

{$R *.dfm}

function quebra(BaseString, BreakString: string; StringList: TStringList)
  : TStringList;
var
  EndOfCurrentString: byte;
  TempStr: string;
begin
  repeat
    EndOfCurrentString := Pos(BreakString, BaseString);
    if EndOfCurrentString = 0 then
      StringList.add(BaseString)
    else
      StringList.add(Copy(BaseString, 1, EndOfCurrentString - 1));
    BaseString := Copy(BaseString, EndOfCurrentString + length(BreakString),
      length(BaseString) - EndOfCurrentString);

  until EndOfCurrentString = 0;
  result := StringList;
end;

procedure ExecuteAndWait(const aCommando: string);
var
  tmpStartupInfo: TStartupInfo;
  tmpProcessInformation: TProcessInformation;
  tmpProgram: String;
begin
  tmpProgram := trim(aCommando);
  FillChar(tmpStartupInfo, SizeOf(tmpStartupInfo), 0);
  with tmpStartupInfo do
  begin
    cb := SizeOf(TStartupInfo);
    wShowWindow := SW_HIDE;
  end;

  if CreateProcess(nil, pchar(tmpProgram), nil, nil, true, CREATE_NO_WINDOW,
    nil, nil, tmpStartupInfo, tmpProcessInformation) then
  begin
    // loop every 10 ms
    while WaitForSingleObject(tmpProcessInformation.hProcess, 10) > 0 do
    begin
      Application.ProcessMessages;
    end;
    CloseHandle(tmpProcessInformation.hProcess);
    CloseHandle(tmpProcessInformation.hThread);
  end
  else
  begin
    RaiseLastOSError;
  end;
end;

procedure TForm1.FormClose(Sender: TObject; var Action: TCloseAction);
begin
  Action := caNone;
end;

procedure TForm1.FormCreate(Sender: TObject);
begin
  // Para criar o arquivo INI:
  // data := TInifile.Create(ExtractFilePath(ParamStr(0)) + 'Config.ini');
  // Nome do meu arquivo INI que será criado
  // data.WriteString('CONFIGURACAO', 'PORTA', '8000');
  // O conteúdo do Edit1.Text será gravado dentro da chave CONFIGURACAO e na subchave PORTA
  // data.Free; // Libera a memória

  // Para ler o arquivo INI:
  data := TInifile.Create(ExtractFilePath(ParamStr(0)) + 'Config.ini');
  // Nome do meu arquivo INI que quero ler
  porta := data.ReadString('CONFIGURACAO', 'PORTA', '');
  // O Edit1.Text vai receber o que está gravado dentro da chave NOME1 e da subchave NOME2
  data.Free; // Libera a memória

  THorse.Use(Jhonson);
  THorse.Use(CORS);

  THorse.Get('/doc',
    procedure(Req: THorseRequest; Res: THorseResponse; Next: TProc)
    var
      Impressoras: TJSONArray;
      i: integer;
    begin
      Impressoras := TJSONArray.Create;

      for i := 0 to gtPDFPrinter1.GetInstalledPrinters.count - 1 do
      begin

        Impressoras.add(TJSONObject.Create.AddPair('impressora',
          gtPDFPrinter1.GetInstalledPrinters[i]));

      end;

      Res.Send(Impressoras);

    end);

  THorse.Post('/doc',
    procedure(Req: THorseRequest; Res: THorseResponse; Next: TProc)
    var
      lBody, lRetorno: TJSONObject;
      base64: String;
      documento: String;
      diretorio: String;
      id_externo: String;
      stream: TBytesStream;
      arquivo: TStringList;
      f: textfile;
      OutPutList: TStringList;
      i: integer;
    begin

      lBody := Req.Body<TJSONObject>;

      base64 := lBody.Values['base64'].Value;
      documento := lBody.Values['documento'].Value;
      diretorio := lBody.Values['diretorio'].Value;
      id_externo := lBody.Values['id_externo'].Value;
      Memo1.Lines.add('' + diretorio + '\' + documento + '');

      CreateDir(diretorio);
      stream := TBytesStream.Create
        (TNetEncoding.base64.DecodeStringToBytes(base64));

      // stream.SaveToFile(ExtractFilePath(ParamStr(0))+'\Documentos_Clientes\'+documento);
      stream.SaveToFile(diretorio + '\' + documento);

      lRetorno := TJSONObject.Create;
      lRetorno.AddPair('status', 'true');
      lRetorno.AddPair('id_externo', id_externo);

      Res.Send(lRetorno);

    end);

  THorse.Listen(Strtoint(porta));
end;

end.
