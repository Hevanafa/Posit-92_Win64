{ A simple program to get the DLL machine code }

program TestGetDLLMachine;

{$Mode ObjFPC}
{$H+}
{$J-}

uses SysUtils;

type
  TDosHeader = record
    e_magic: word;  { Should be $5A4D, which is 'MZ' }
    e_cblp: word;
    e_cp: word;
    e_crlc: word;
    e_cparhdr: word;
    e_minalloc: word;
    e_maxalloc: word;
    e_ss: word;
    e_sp: word;
    e_csum: word;
    e_ip: word;
    e_cs: word;
    e_lfarlc: word;
    e_ovno: word;
    e_res: array[0..3] of word;
    e_oemid: word;
    e_oeminfo: word;
    e_res2: array[0..9] of word;
    e_lfanew: dword;  { Offset to PE header }
  end;

  TCoffHeader = record
    Machine: word;
    NumberOfSections: word;
    TimeDateStamp: dword;
    PointerToSymbolTable: dword;
    NumberOfSymbols: dword;
    SizeOfOptionalHeader: word;
    Characteristics: word;
  end;


{ Ref: https://learn.microsoft.com/en-us/windows/win32/sysinfo/image-file-machine-constants }
const
  IMAGE_FILE_MACHINE_I386 = $014C;
  IMAGE_FILE_MACHINE_AMD64 = $8664;
  IMAGE_FILE_MACHINE_ARM64 = $AA64;


function getDllMachine(const filename: string): word;
var
  f: file of byte;
  dosHeader: TDosHeader;
  peSignature: dword;
  coffHeader: TCoffHeader;
begin
  result := 0;

  if not FileExists(filename) then begin
    writeln(format('%s is missing!', [filename]));
    exit
  end;

  AssignFile(f, filename);
  Reset(f);

  try
    { Read DOS header }
    BlockRead(f, dosHeader, sizeof(dosHeader));
  
    { writeln('e_magic:', dosHeader.e_magic); }
  
    if dosHeader.e_magic <> $5A4D then exit;

    seek(f, longword(dosHeader.e_lfanew));

    BlockRead(f, peSignature, SizeOf(peSignature));
  
    { writeln('peSignature:', peSignature); }
  
    if peSignature <> $00004550 then exit;
  
    { Read COFF header }
    BlockRead(f, coffHeader, sizeof(coffHeader));
  
    { writeln(coffHeader.NumberOfSections); }
  
    result := coffHeader.machine
  finally
    CloseFile(f)
  end;
end;

begin
  writeln('x64');
  writeln(getDllMachine('SDL2_x64.dll'));
  { writeln(format('Machine: %x', [getDllMachine('SDL2_x64.dll')])); }

  writeln('x86');
  writeln(getDllMachine('SDL2_x86.dll'));

  write('The DLL is for ');
  case getDllMachine('SDL2.dll') of
  IMAGE_FILE_MACHINE_I386: writeln('i386');
  IMAGE_FILE_MACHINE_AMD64: writeln('AMD64');
  IMAGE_FILE_MACHINE_ARM64: writeln('ARM64');
  end;
end.
