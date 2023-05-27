unit uShortcutsUtils;

interface

uses
  Winapi.Windows, Winapi.ShellAPI, IdURI, Vcl.Graphics, System.RegularExpressions, System.Net.HttpClient,
  uAtalho, uShortcutsTypes;

  function GetIconFromFileOrURL(ItemLink: string; IconHeight, IconWidth: Integer): TIcon;
  procedure ExecutarAtalho(const FileName: string);
  procedure ExibeMenuItemContexto(Sender: TObject);
  procedure CriaNovoAtalho(Lista: TListaGruposAtalho);

  function IsBatch(ExeName: string): Boolean;
  procedure ExecuteApplication(ExeName: string); overload;
  procedure ExecuteApplication(ExeName: string; Params: TArrayString); overload;

  function GetImageIndexItemMenu(ItemLink: string): TTipoItemMenu;
  function StrToComponentName(s: string): string;
  function RecuperaParteString(s, Separador: string; Index: Integer): string;
  function EhURL(CaminhoAtalho: string): Boolean;
  procedure CarregarArquivoINIListaAtalhos(sFileName: string; Lista: TListaGruposAtalho);

{$IFDEF UNICODE}
    function PrivateExtractIcons(lpszFile: PChar; nIconIndex, cxIcon, cyIcon: integer; phicon: PHANDLE; piconid: PDWORD; nicon, flags: DWORD): DWORD; stdcall ; external 'user32.dll' name 'PrivateExtractIconsW';
{$ELSE}
    function PrivateExtractIcons(lpszFile: PChar; nIconIndex, cxIcon, cyIcon: integer; phicon: PHANDLE; piconid: PDWORD; nicon, flags: DWORD): DWORD; stdcall ; external 'user32.dll' name 'PrivateExtractIconsA';
{$ENDIF}

const
  EXTENSION_BAT = '.bat';
  EXTENSION_PNG = '.png';

implementation

uses System.Classes, System.IniFiles, System.SysUtils, Vcl.Forms, Vcl.Dialogs, uShortcutsConsts, System.StrUtils,
     System.Math, uMenuItemPlus;

var
  MutexHandle: THandle;

function GetParameters(const FileName: string): TArrayString;
var
  AParams: TArrayString;
  auxFileName, auxParams: string;
  lst: TStringList;
  I: Integer;
begin
  SetLength(AParams, 0);

  if (Pos('"', FileName) > 0) then
  begin
    auxFileName := Copy(FileName, Pos('"', FileName)+1, Length(FileName)-Pos('"', FileName));
    auxParams   := Copy(auxFileName, Pos('"', auxFileName)+1, Length(auxFileName)-Pos('"', auxFileName));
    auxFileName := Copy(auxFileName, 1, Pos('"', auxFileName)-1);
  end
  else //sem aspas = sem parâmetros
  begin
    auxFileName := FileName;
    auxParams := EmptyStr;
  end;

  lst := TStringList.Create;
  try
    lst.Text := auxFileName +
                StringReplace(auxParams, ' ', sLineBreak, [rfReplaceAll]);

    for I := 0 to Pred(lst.Count) do
    begin
      SetLength(AParams, Length(AParams)+1);
      AParams[Length(AParams)-1] := lst[I];
    end;

  finally
    FreeAndNil(lst);
  end;

  Result := AParams;
end;

function IsBatch(ExeName: string): Boolean;
begin
  Result := Copy(ExeName, Length(ExeName) -3, 4) = EXTENSION_BAT;
end;

procedure ExecuteApplication(ExeName: string);
begin
  ShellExecute(Application.Handle, 'open', PWideChar(ExeName), nil, nil, SW_SHOWNORMAL {SW_SHOWMAXIMIZED});
end;

procedure ExecuteApplication(ExeName: string; Params: TArrayString);
var
  bCreateProcess: Boolean;
  StartupInfo: TStartupInfoW;
  ProcessInfo: TProcessInformation;
begin
  Delete(Params, 0, 1);  //remove o EXE dos parâmetros

  { fill with known state }
  FillChar(StartupInfo, SizeOf(TStartupInfoW), #0);
  FillChar(ProcessInfo, SizeOf(TProcessInformation), #0);
  StartupInfo.cb := SizeOf(TStartupInfoW);

  if IsBatch(ExeName) then
    bCreateProcess := CreateProcessW(nil,
                                     PWideChar(ExeName + ' ' + Params.ToString),
                                     nil, nil, False,
                                     0,
                                     nil,
                                     nil,
                                     StartupInfo,
                                     ProcessInfo)
  else
    bCreateProcess := CreateProcessW(PWideChar(ExeName),
                                     PWideChar(Params),
                                     nil, nil, False,
                                     CREATE_DEFAULT_ERROR_MODE + CREATE_NEW_CONSOLE +
                                     CREATE_NEW_PROCESS_GROUP + NORMAL_PRIORITY_CLASS,
                                     nil,
                                     PWideChar(ExtractFilePath(ExeName)),
                                     StartupInfo,
                                     ProcessInfo);

  if bCreateProcess then
    try
      WaitForSingleObject(ProcessInfo.hProcess, INFINITE);
    finally
      CloseHandle(ProcessInfo.hProcess);
      CloseHandle(ProcessInfo.hThread);
    end;
end;

procedure ExecutarAtalho(const FileName: string);
var
  ExeName: string;
  Params: TArrayString;
begin
  Params := GetParameters(FileName);
  ExeName:= Params[0]; //usando mesmo padrão do ParamStr

  if (Length(Params) <= 1) then //sem parâmetros
    ExecuteApplication(ExeName)
  else
    ExecuteApplication(ExeName, Params);
end;

procedure ExibeMenuItemContexto(Sender: TObject);
var
  MenuItem: TMenuItemPlus;
begin
  if (Sender is TMenuItemPlus) then
  begin
    MenuItem := (Sender as TMenuItemPlus);
    ShowMessage('Chama tela de Edição do Atalho');

    //Chama tela de Edição do Item de Menu
    //Se a alteração for OK, muda na classe e no arquivo

    //Preparar essa tela para ser chamada também na criação de um novo item
  end;
end;

procedure CriaNovoAtalho(Lista: TListaGruposAtalho);
begin
  ShowMessage('Chama tela de Criação de um novo Atalho');
end;


function GetDomainName(myURL: string): string;
var
  URI: TIdURI;
  founditems: TMatchCollection;
  founditem: TMatch;
  myregex: string;
  myhostname: string;
begin
  Result := '';
  URI := TIdURI.Create(myurl); // https://www.mail.example.co.uk/test
  try
    myhostname := URI.Host; // www.mail.example.co.uk
  finally
    URI.Free;
  end;

  myregex := '([a-z0-9][a-z0-9\-]{1,63}\.[a-z\.]{2,6})$';
  founditems := TRegEx.Matches(myhostname, myregex, [roIgnoreCase]);

  for founditem in founditems do
    Result := founditem.Value; // example.co.uk
end;

function DownloadImage(URL, FileName: string): Boolean;
var
  MemoryStream : TMemoryStream;
  HttpClient: THttpClient;
  Picture: TPicture;
begin
  HttpClient := THttpClient.Create;
  MemoryStream := TMemoryStream.Create;
  Picture := TPicture.Create;
  try
    HttpClient.Get(URL, MemoryStream);
    MemoryStream.Seek(0, soFromBeginning);
    Picture.LoadFromStream(MemoryStream);
    Picture.SaveToFile(FileName);

    Result := FileExists(FileName);
  finally
    FreeAndNil(Picture);
    FreeAndNil(MemoryStream);
    FreeAndNil(HttpClient);
  end;
end;

function GetIconFromEXE(ItemLink: string; IconHeight, IconWidth: Integer): TIcon;
var
  nIconId : DWORD;
  hIcon: THandle;
begin
  if (PrivateExtractIcons(PWideChar(ItemLink), 0, IconHeight, IconWidth, @hIcon, @nIconId, 1, LR_LOADFROMFILE) <> 0) then
  begin
    Result := TIcon.Create;
    Result.Handle := hIcon;
  end
  else
    Result := nil;
end;

function GetIconFromPNG(ItemLink: string; IconHeight, IconWidth: Integer): TIcon;
var
  Picture: TPicture;
  BmImg, Bmp, BmpMask: TBitmap;
  IconInfo: TIconInfo;
begin
  Picture := TPicture.Create;
  try
    Picture.LoadFromFile(ItemLink);

    BmImg := TBitmap.Create;
    BmImg.Assign(Picture.Graphic);
  finally
    FreeAndNil(Picture);
  end;

  Bmp := TBitmap.Create;
  BmpMask := TBitmap.Create;
  try
    Bmp.SetSize(IconWidth, IconHeight);
    SetStretchBltMode(Bmp.Canvas.Handle, HALFTONE);
    StretchBlt(Bmp.Canvas.Handle, 0, 0, Bmp.Width, Bmp.Height,
                BmImg.Canvas.Handle, 0, 0, BmImg.Width, BmImg.Height, SRCCOPY);
    BmImg.Free;

    BmpMask.Canvas.Brush.Color := clNone;//clBlack
    BmpMask.SetSize(Bmp.Width, Bmp.Height);

    FillChar(IconInfo, SizeOf(IconInfo), 0);
    IconInfo.fIcon    := True;
    IconInfo.hbmMask  := BmpMask.Handle;
    IconInfo.hbmColor := Bmp.Handle;

    Result := TIcon.Create;
    Result.Handle := CreateIconIndirect(IconInfo);
  finally
    Bmp.Free;
    BmpMask.Free;
  end;

end;

function GetIconFromFileOrURL(ItemLink: string; IconHeight, IconWidth: Integer): TIcon;
var
  sDomainName, sImageFileName: string;
begin
  if (Pos('http', ItemLink) = 1) then
  begin
    if (not DirectoryExists(ExtractFilePath(Application.ExeName)+ICONS_PATH)) then
      CreateDir(ExtractFilePath(Application.ExeName)+ICONS_PATH);

    sDomainName    := GetDomainName(ItemLink);
    sImageFileName := ICONS_PATH + sDomainName + EXTENSION_PNG;

    if DownloadImage(GOOGLE_FAVICON_URL + sDomainName, sImageFileName) then
      Result := GetIconFromPNG(sImageFileName, IconHeight, IconWidth)
    else
      Result := nil;
  end
  else
    Result := GetIconFromEXE(ItemLink, IconHeight, IconWidth);
end;

function GetImageIndexItemMenu(ItemLink: string): TTipoItemMenu;
begin
  if (Pos('http', ItemLink) = 1) then
    Result := timURL
  else
    if (Pos('.exe', ItemLink) > 0) then
      Result := timExe
    else
      if (Pos('.txt', ItemLink) > 0) or
         (Pos('.ini', ItemLink) > 0) or
         (Pos('.cfg', ItemLink) > 0) then
        Result := timText
      else
        Result := timFile;
end;

function StrToComponentName(s: string): string;
begin
  Result := TRegEx.Replace(s, '[^\w]+', EmptyStr);
end;

function RecuperaParteString(s, Separador: string; Index: Integer): string;
begin

end;

function EhURL(CaminhoAtalho: string): Boolean;
begin
  Result := (Pos('http://', CaminhoAtalho) = 1) or
            (Pos('https://', CaminhoAtalho) = 1) or
            (Pos('ftp://', CaminhoAtalho) = 1);
end;

procedure CarregarArquivoINIListaAtalhos(sFileName: string; Lista: TListaGruposAtalho);
var
  sGrupo, sAtalho: string;
  IniFile: TIniFile;
  lstGrupos, lstAtalhosGrupo: TStringList;
  GrupoAtalho: TGrupoAtalho;
  Atalho: TAtalho;
begin
  lstGrupos := TStringList.Create;
  lstAtalhosGrupo := TStringList.Create;
  IniFile := TIniFile.Create(sFileName);
  try
    Lista.Clear;
    IniFile.ReadSections(lstGrupos);

    for sGrupo in lstGrupos do
    begin
      IniFile.ReadSection(sGrupo, lstAtalhosGrupo);
      GrupoAtalho := TGrupoAtalho.Create;
      GrupoAtalho.Nome := sGrupo;

      for sAtalho in lstAtalhosGrupo do
      begin
        Atalho := TAtalho.Create;
        Atalho.Nome       := sAtalho;
        Atalho.Caminho    := IniFile.ReadString(sGrupo, sAtalho, EmptyStr);
        Atalho.Parametros := EmptyStr;///
        Atalho.Tipo       := TTipoAtalho(IfThen(EhURL(Atalho.Caminho), Integer(taArquivo), Integer(taURL)));
        GrupoAtalho.Atalhos.Add(Atalho);
        Atalho := nil;
      end;

      Lista.Add(GrupoAtalho);
      GrupoAtalho := nil;
    end;

  finally
    FreeAndNil(lstGrupos);
  end;
end;


initialization
  MutexHandle := CreateMutex(nil, True, 'ShortcutsMutex');

  // Já existe uma instância da aplicação em execução
  if (MutexHandle <> 0) and (GetLastError = ERROR_ALREADY_EXISTS) then
    Halt(ERROR_ALREADY_EXISTS);

finalization
  CloseHandle(MutexHandle);
end.
