unit uDOSinMemo;

interface

uses
  Winapi.Windows, Winapi.Messages, System.SysUtils, System.Variants, System.Classes, Vcl.Graphics,
  Vcl.Controls, Vcl.Forms, Vcl.Dialogs, Vcl.StdCtrls;

type
  TForm1 = class(TForm)
    memOutput: TMemo;
    edtInput: TEdit;
    procedure edtInputKeyDown(Sender: TObject; var Key: Word;
      Shift: TShiftState);
  private
    { Private declarations }
  public
    { Public declarations }
  end;

var
  Form1: TForm1;

implementation

{$R *.dfm}

procedure RunDosInMemo(DosApp: string; AMemo: TMemo);
const
    READ_BUFFER_SIZE = 2400;
var
    Security: TSecurityAttributes;
    readableEndOfPipe, writeableEndOfPipe: THandle;
    start: TStartUpInfo;
    ProcessInfo: TProcessInformation;
    Buffer: PAnsiChar;
    BytesRead: DWORD;
    AppRunning: DWORD;
begin
  Security.nLength := SizeOf(TSecurityAttributes);
  Security.bInheritHandle := True;
  Security.lpSecurityDescriptor := nil;

  if CreatePipe({var}readableEndOfPipe, {var}writeableEndOfPipe, @Security, 0) then
    try
      Buffer := AllocMem(READ_BUFFER_SIZE+1);
      FillChar(Start, Sizeof(Start), #0);
      start.cb := SizeOf(start);

      // Set up members of the STARTUPINFO structure.
      // This structure specifies the STDIN and STDOUT handles for redirection.
      // - Redirect the output and error to the writeable end of our pipe.
      // - We must still supply a valid StdInput handle (because we used STARTF_USESTDHANDLES to swear that all three handles will be valid)
      start.dwFlags := start.dwFlags or STARTF_USESTDHANDLES;
      start.hStdInput := GetStdHandle(STD_INPUT_HANDLE); //we're not redirecting stdInput; but we still have to give it a valid handle
      start.hStdOutput := writeableEndOfPipe; //we give the writeable end of the pipe to the child process; we read from the readable end
      start.hStdError := writeableEndOfPipe;

      //We can also choose to say that the wShowWindow member contains a value.
      //In our case we want to force the console window to be hidden.
      start.dwFlags := start.dwFlags + STARTF_USESHOWWINDOW;
      start.wShowWindow := SW_HIDE;

      // Don't forget to set up members of the PROCESS_INFORMATION structure.
      ProcessInfo := Default(TProcessInformation);

      //WARNING: The unicode version of CreateProcess (CreateProcessW) can modify the command-line "DosApp" string.
      //Therefore "DosApp" cannot be a pointer to read-only memory, or an ACCESS_VIOLATION will occur.
      //We can ensure it's not read-only with the RTL function: UniqueString
      UniqueString({var}DosApp);

      if CreateProcess(nil, PChar(DosApp), nil, nil, True, NORMAL_PRIORITY_CLASS, nil, nil, start, {var}ProcessInfo) then
      begin
          //Wait for the application to terminate, as it writes it's output to the pipe.
          //WARNING: If the console app outputs more than 2400 bytes (ReadBuffer),
          //it will block on writing to the pipe and *never* close.
          repeat
              Apprunning := WaitForSingleObject(ProcessInfo.hProcess, 100);
              Application.ProcessMessages;
          until (Apprunning <> WAIT_TIMEOUT);

          //Read the contents of the pipe out of the readable end
          //WARNING: if the console app never writes anything to the StdOutput, then ReadFile will block and never return
          repeat
              BytesRead := 0;
              ReadFile(readableEndOfPipe, Buffer[0], READ_BUFFER_SIZE, {var}BytesRead, nil);
              Buffer[BytesRead]:= #0;
              OemToAnsi(Buffer,Buffer);
              AMemo.Text := AMemo.text + String(Buffer);
          until (BytesRead < READ_BUFFER_SIZE);
      end;
    finally
      FreeMem(Buffer);
      CloseHandle(ProcessInfo.hProcess);
      CloseHandle(ProcessInfo.hThread);
      CloseHandle(readableEndOfPipe);
      CloseHandle(writeableEndOfPipe);
    end;
end;

procedure CaptureConsoleOutput(const ACommand, AParameters: String; AMemo: TMemo);
 const
   CReadBuffer = 2400;
 var
   saSecurity: TSecurityAttributes;
   hRead: THandle;
   hWrite: THandle;
   suiStartup: TStartupInfo;
   piProcess: TProcessInformation;
   pBuffer: array[0..CReadBuffer] of AnsiChar;      //<----- update
   dRead: DWord;
   dRunning: DWord;
 begin
   saSecurity.nLength := SizeOf(TSecurityAttributes);
   saSecurity.bInheritHandle := True;
   saSecurity.lpSecurityDescriptor := nil;

   if CreatePipe(hRead, hWrite, @saSecurity, 0) then
   begin
     FillChar(suiStartup, SizeOf(TStartupInfo), #0);
     suiStartup.cb := SizeOf(TStartupInfo);
     suiStartup.hStdInput := hRead;
     suiStartup.hStdOutput := hWrite;
     suiStartup.hStdError := hWrite;
     suiStartup.dwFlags := STARTF_USESTDHANDLES or STARTF_USESHOWWINDOW;
     suiStartup.wShowWindow := SW_HIDE;

     if CreateProcess(nil, PChar(ACommand + ' ' + AParameters), @saSecurity,
       @saSecurity, True, NORMAL_PRIORITY_CLASS, nil, nil, suiStartup, piProcess)
       then
     begin
       repeat
         dRunning  := WaitForSingleObject(piProcess.hProcess, 100);
         Application.ProcessMessages();
         repeat
           dRead := 0;
           ReadFile(hRead, pBuffer[0], CReadBuffer, dRead, nil);
           pBuffer[dRead] := #0;

           OemToAnsi(pBuffer, pBuffer);
           AMemo.Lines.Add(String(pBuffer));
         until (dRead < CReadBuffer);
       until (dRunning <> WAIT_TIMEOUT);
       CloseHandle(piProcess.hProcess);
       CloseHandle(piProcess.hThread);
     end;

     CloseHandle(hRead);
     CloseHandle(hWrite);
   end;
end;

procedure TForm1.edtInputKeyDown(Sender: TObject; var Key: Word;
  Shift: TShiftState);
begin
  if (Key = VK_RETURN) then
    try
      //RunDosInMemo(edtInput.Text, memOutput);
      CaptureConsoleOutput(edtInput.Text, EmptyStr, memOutput);
    finally
      edtInput.Clear;
    end;
end;

end.
