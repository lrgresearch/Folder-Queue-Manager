unit Unit1;

{$mode objfpc}{$H+}

interface

uses
  Classes, SysUtils, FileUtil, Forms, Controls, Graphics, Dialogs, StdCtrls,
  ComCtrls, IniFiles, Interfaces, Process, LCLIntf, ExtCtrls, Zipper, LazFileUtils;

type

  { TForm1 }

  TForm1 = class(TForm)
    Button1: TButton;
    Button2: TButton;
    Button3: TButton;
    Button4: TButton;
    Button5: TButton;
    Button6: TButton;
    CheckBox1: TCheckBox;
    Image1: TImage;
    Label1: TLabel;
    Label2: TLabel;
    Label4: TLabel;
    Label5: TLabel;
    Label6: TLabel;
    Label7: TLabel;
    Label8: TLabel;
    ListBox1: TListBox;
    ListBox2: TListBox;
    Memo1: TMemo;
    PageControl1: TPageControl;
    SelectDirectoryDialog1: TSelectDirectoryDialog;
    SelectDirectoryDialog2: TSelectDirectoryDialog;
    SelectDirectoryDialog3: TSelectDirectoryDialog;
    Settings: TGroupBox;
    TabSheet1: TTabSheet;
    TabSheet2: TTabSheet;
    TabSheet3: TTabSheet;
    Timer1: TTimer;
    procedure Button4Click(Sender: TObject);
    procedure Button5Click(Sender: TObject);
    procedure Button6Click(Sender: TObject);
    procedure CheckBox1Click(Sender: TObject);
    procedure FormClose(Sender: TObject; var CloseAction: TCloseAction);
    procedure FormCreate(Sender: TObject);
    procedure Timer1Timer(Sender: TObject);
  private

  public

  end;

var
  Form1: TForm1;
  InputFolder,OutputFolder, TempFolder, CommandOutput, LogFileName: String;
  TempFolderName,Instance1: String;
  NumberofRunnings,i: Integer;
  NotSaved,InstanceRunning: Boolean;
  INI: TINIFile;

implementation

{$R *.lfm}

{ TForm1 }
{
 LRG Cloud Queue Manager Version 0.1
 Copyleft (C) 2020 Sefer Bora Lisesivdin
}

// Log entry/save procedure
procedure LogEntry(entry : string);
begin
  Form1.Memo1.Append('['+DateTimeToStr(Now)+'] '+entry);
  Form1.Memo1.Lines.SaveToFile(GetCurrentDir+'\log\'+LogFileName+'.txt');
end;

procedure TForm1.FormCreate(Sender: TObject);
begin
  // Nothing is running at the first place
  InstanceRunning:=False;
  // Create setting.ini file if there is not
  if FileExists('settings.ini') = False then begin
    INI := TINIFile.Create('settings.ini');
    INI.WriteString('General','InputFolder', 'na');
    INI.WriteString('General','OutputFolder', 'na');
    INI.WriteString('General','TempFolder', 'na');
    INI.WriteString('General','NumberofRunnings', '1');
    INI.Free;
    CreateDir('log');
  end;

// Create a log filename with date information
LogFileName := FormatDateTime('YYMMDD_hhmm',Now);

// Loading options from INI file to variables
INI := TINIFile.Create('settings.ini');
InputFolder := INI.ReadString('General','InputFolder','');
OutputFolder := INI.ReadString('General','OutputFolder','');
TempFolder := INI.ReadString('General','TempFolder','');
NumberofRunnings := StrtoInt(INI.ReadString('General','NumberofRunnings',''));
INI.Free;

// Change ListBox Index value using the value written in settings.ini

case NumberofRunnings of
  1: ListBox1.ItemIndex:= 0;
  2: ListBox1.ItemIndex:= 1;
  3: ListBox1.ItemIndex:= 2;
  4: ListBox1.ItemIndex:= 3;
  5: ListBox1.ItemIndex:= 4;
  6: ListBox1.ItemIndex:= 5;
  7: ListBox1.ItemIndex:= 6;
  8: ListBox1.ItemIndex:= 7;
  else ListBox1.ItemIndex:= 8;
  end;

//If any of the folder information is na then enter folder information
if ((InputFolder = 'na') or (OutputFolder = 'na') or (TempFolder = 'na')) then begin
  ShowMessage('You are running the software for the first time, or folder settings are wrong. You will be forwarded to folder choose dialogs.');
  if SelectDirectoryDialog1.Execute then begin
    InputFolder := SelectDirectoryDialog1.FileName;
    NotSaved := true;
  end;
  if SelectDirectoryDialog2.Execute then begin
    OutputFolder := SelectDirectoryDialog2.FileName;
    NotSaved := true;
  end;
  if SelectDirectoryDialog3.Execute then begin
    TempFolder := SelectDirectoryDialog3.FileName;
    NotSaved := true;
  end;
   INI := TINIFile.Create('settings.ini');
   INI.WriteString('General','InputFolder', InputFolder);
   INI.WriteString('General','OutputFolder', OutputFolder);
   INI.WriteString('General','TempFolder', TempFolder);
   INI.WriteString('General','NumberofRunnings', '1');
   INI.Free;
   NotSaved := false;
   // Save to log
   LogEntry('New settings are written to settings.ini.');
end;

   // 10 mins = 1000msec*60*10 =600000msecs
   Timer1.Interval := 60000;
   i:=60000;
end;

procedure TForm1.Timer1Timer(Sender: TObject);
const
  BUF_SIZE = 2048; // Buffer size for reading the output in chunks
var
  Mask,relativefn : String;
  sr: TSearchRec;
  Process: Tprocess;
  OutputStream : TMemoryStream;
  BytesRead    : longint;
  Buffer       : array[1..BUF_SIZE] of byte;
  AZipper: TZipper;
  ZipFileList:TStringList;
begin
  //Taking the names of py files into Listbox2.Items
  Mask := '*.py';
  //Erasing Listbox before starting again
  repeat
    ListBox2.Items.Delete(0);
  until ListBox2.Items.Count = 0;

  if FindFirst(InputFolder+'\'+Mask,faAnyFile,sr)=0 then
    repeat
      ListBox2.Items.Add(sr.Name);
    until FindNext(sr)<>0;
  FindClose(sr);
  LogEntry('Find '+IntToStr(ListBox2.Items.Count)+' files in input folder.');

  // Making a folder in TEMP directory
  // As of Mar 25th 2020, the code will work with single instance
  // After the code matures, this will change and these lines below
  // must be changed mostly.

  // HERE THERE MUST BE INSTANCE CONTROL. false/true
  // IF There is a file in INPUT folder:
  if ListBox2.Items.Count > 0 then begin
    InstanceRunning := true;
    // Take a item from list and then delete it from list
    // Creating a folder under temp
    Instance1 := ListBox2.Items[0];
    TempFolderName := FormatDateTime('YYMMDD_hhmmss',Now);
    TempFolderName := TempFolderName+'_'+Instance1;
    CreateDir(TempFolder+'\'+TempFolderName);
    RenameFile(InputFolder+'\'+ListBox2.Items[0],TempFolder+'\'+TempFolderName+'\'+ListBox2.Items[0]);
    LogEntry('First instance is running at: '+TempFolder+'\'+TempFolderName+'\'+ListBox2.Items[0]);
    //Instance1 := TempFolder+'\'+TempFolderName+'\'+ListBox2.Items[0];
    Instance1 := ListBox2.Items[0];
    ListBox2.Items.Delete(0);
  end;

  // Running command
  Process := TProcess.Create(nil);
  try
    Process.Executable := 'python.exe';
    Process.CurrentDirectory:= TempFolder+'\'+TempFolderName;
    Process.Parameters.Add(Instance1);
    Process.Options := Process.Options + [poUsePipes];
    Process.ShowWindow:= swoHIDE;;
    Process.Execute;
  finally
    OutputStream := TMemoryStream.Create;
    repeat
      // Get the new data from the process to a maximum of the buffer size that was allocated.
      // Note that all read(...) calls will block except for the last one, which returns 0 (zero).
      BytesRead := Process.Output.Read(Buffer, BUF_SIZE);

      // Add the bytes that were read to the stream for later usage
      OutputStream.Write(Buffer, BytesRead)
    until BytesRead = 0;  // Stop if no more data is available

    Process.Free;
  end;
  // Save to log
  LogEntry('Instance executed: '+Instance1);

  // Now that all data has been read it can be used; for example to save it to a file on disk
  with TFileStream.Create(TempFolder+'\'+TempFolderName+'\'+Instance1+'.log', fmCreate) do
  begin
    OutputStream.Position := 0; // Required to make sure all data is copied from the start
    CopyFrom(OutputStream, OutputStream.Size);
    Free
  end;
  // Clean up
  OutputStream.Free;
  // Save to log
  LogEntry('Log file of '+Instance1+' is created.');

  //Zipping the folder before moving to output folder.
  CreateDir(OutputFolder+'\'+TempFolderName);
  AZipper := TZipper.Create;
  AZipper.Filename := OutputFolder+'\'+TempFolderName+'\'+Instance1+'.zip';
  ZipFileList:=TStringList.Create;
  try
    FindAllFiles(ZipFileList, TempFolder+'\'+TempFolderName);
    // Creating files with relative paths, not full paths.
    for i:=0 to ZipFileList.Count-1 do begin
        relativefn := CreateRelativePath(ZipFileList[i], TempFolder+'\'+TempFolderName);
        AZipper.Entries.AddFileEntry(ZipFileList[i], relativefn);
    end;
    //AZipper.Entries.AddFileEntries(ZipFileList);
    //AZipper.ZipAllFiles;
    Azipper.SaveToFile(OutputFolder+'\'+TempFolderName+'\'+Instance1+'.zip');
  finally
    ZipFileList.Free;
    AZipper.Free;
  end;
  // At the end remove the folders in TEMP
  if DeleteDirectory(TempFolder+'\'+TempFolderName,True) then begin
    RemoveDir(TempFolder+'\'+TempFolderName);
  end;
end;

procedure TForm1.Button4Click(Sender: TObject);
begin

case ListBox1.ItemIndex of
  0: NumberofRunnings:= 1;
  1: NumberofRunnings:= 2;
  2: NumberofRunnings:= 3;
  3: NumberofRunnings:= 4;
  4: NumberofRunnings:= 5;
  5: NumberofRunnings:= 6;
  6: NumberofRunnings:= 7;
  7: NumberofRunnings:= 8;
  else NumberofRunnings:= 9;
  end;

// Writing settings to settings.ini file
   INI := TINIFile.Create('settings.ini');
   INI.WriteString('General','InputFolder', InputFolder);
   INI.WriteString('General','OutputFolder', OutputFolder);
   INI.WriteString('General','TempFolder', TempFolder);
   INI.WriteString('General','NumberofRunnings', InttoStr(NumberofRunnings));
   INI.Free;
  end;

procedure TForm1.Button5Click(Sender: TObject);
begin
  OpenDocument('settings.ini')
end;

procedure TForm1.Button6Click(Sender: TObject);
var
  Process: TProcess;
begin
  Process := TProcess.Create(nil);
  try
    Process.Executable := 'explorer.exe';
    Process.Parameters.Add(GetCurrentDir+'\log');
    Process.Options := Process.Options + [poWaitOnExit];
    Process.Execute;
  finally
    Process.Free;
  end;
  // Save to log
  LogEntry('Log file is opened.');
end;

procedure TForm1.CheckBox1Click(Sender: TObject);
begin
    If CheckBox1.Checked = True then begin
  // Code is running!
      // Start timer1
      Timer1.Enabled:=true;
      // Save to log
      LogEntry('FQM is running.');
  end
  Else begin
    //Code is stopped!
    // Stop timer1
      Timer1.Enabled:=false;
    // Save to log
    LogEntry('FQM is stopped.');
  end;
end;

procedure TForm1.FormClose(Sender: TObject; var CloseAction: TCloseAction);
begin
  LogEntry('FQM is closed.');
end;


end.

