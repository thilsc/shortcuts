unit uShortcutsUtils;

interface

uses
  Winapi.Windows, Winapi.ShellAPI, IdURI, Vcl.Graphics,
  System.RegularExpressions, System.Net.HttpClient, uShortcutsTypes;

  function GetIconFromFileOrURL(ItemLink: string; IconHeight, IconWidth: Integer): TIcon;
  procedure ExecutarAtalho(const FileName: string);

{$IFDEF UNICODE}
    function PrivateExtractIcons(lpszFile: PChar; nIconIndex, cxIcon, cyIcon: integer; phicon: PHANDLE; piconid: PDWORD; nicon, flags: DWORD): DWORD; stdcall ; external 'user32.dll' name 'PrivateExtractIconsW';
{$ELSE}
    function PrivateExtractIcons(lpszFile: PChar; nIconIndex, cxIcon, cyIcon: integer; phicon: PHANDLE; piconid: PDWORD; nicon, flags: DWORD): DWORD; stdcall ; external 'user32.dll' name 'PrivateExtractIconsA';
{$ENDIF}

implementation

uses System.Classes, Vcl.Forms, System.SysUtils, uShortcutsConsts, System.StrUtils;

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

procedure ExecutarAtalho(const FileName: string);
var
  ExeName: string;
  IsBatch: Boolean;
  Params: TArrayString;
  StartInfo: TStartupInfoW;
  ProcInfo: TProcessInformation;
begin
  Params := GetParameters(FileName);
  ExeName:= Params[0]; //usando mesmo padrão do ParamStr

  if (Length(Params) <= 1) then //sem parâmetros
    ShellExecute(Application.Handle, 'open', PWideChar(ExeName), nil, nil, SW_SHOWNORMAL {SW_SHOWMAXIMIZED})
  else //chamada com parâmetros
  begin
    IsBatch := (Copy(ExeName, Length(ExeName)-3, 4) = '.bat');

    if IsBatch then //se for .BAT
    begin
      ExeName := 'C:\windows\System32\cmd.exe';
      Params[0] := '/c '+Params[0]; //comando para executar BATCH
    end
    else //remove o EXE dos parâmetros
      Delete(Params, 0, 1);

    { fill with known state }
    FillChar(StartInfo, SizeOf(TStartupInfoW), #0);
    FillChar(ProcInfo, SizeOf(TProcessInformation), #0);
    StartInfo.cb := SizeOf(TStartupInfoW);

    if CreateProcessW(
                      PWideChar(ExeName),
                      PWideChar(Params),
                      nil, nil, False,
                      CREATE_DEFAULT_ERROR_MODE + CREATE_NEW_CONSOLE +
                      CREATE_NEW_PROCESS_GROUP + NORMAL_PRIORITY_CLASS,
                      nil,
                      PWideChar(ExtractFilePath(ExeName)),
                      StartInfo,
                      ProcInfo) then
    try
      WaitForSingleObject(ProcInfo.hProcess, INFINITE);
    finally
      //close process & thread handles
      CloseHandle(ProcInfo.hProcess);
      CloseHandle(ProcInfo.hThread);
    end;
  end;
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
    sImageFileName := ICONS_PATH + sDomainName+'.png';

    if DownloadImage(GOOGLE_FAVICON_URL + sDomainName, sImageFileName) then
      Result := GetIconFromPNG(sImageFileName, IconHeight, IconWidth)
    else
      Result := nil;
  end
  else
    Result := GetIconFromEXE(ItemLink, IconHeight, IconWidth);
end;

end.
