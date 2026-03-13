{$Mode ObjFPC}
{$H+}
{$J-}

uses SysUtils;

type
  TDosHeader = record
    e_magic: WORD;  { Should be $5A4D, which is 'MZ' }
    e_cblp: WORD;
    e_cp: WORD;
    e_crlc: WORD;
    e_cparhdr: WORD;
    e_minalloc: WORD;
    e_maxalloc: WORD;
    e_ss: WORD;
    e_sp: WORD;
    e_csum: WORD;
    e_ip: WORD;
    e_cs: WORD;
    e_lfarlc: WORD;
    e_ovno: WORD;
    e_res: array[0..3] of WORD;
    e_oemid: WORD;
    e_oeminfo: WORD;
    e_res2: array[0..9] of WORD;
    e_lfanew: DWORD;  { Offset to PE header }
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

function getDllMachine(const filename: string): word;
var
  f: file of byte;
  dosHeader: TDosHeader;
  peSignature: word;
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
	
	writeln('e_magic:', dosHeader.e_magic);
	
    if dosHeader.e_magic <> $5A4D then exit;

    seek(f, dosHeader.e_lfanew);

    BlockRead(f, peSignature, SizeOf(peSignature));
	
	writeln('peSignature:', peSignature);
	
    if peSignature <> $4550 then exit;
	
	writeln('after peSignature');

    { Read COFF header }
    BlockRead(f, coffHeader, sizeof(coffHeader));
	
	writeln(coffHeader.NumberOfSections);
	
    result := coffHeader.machine
  finally
    CloseFile(f)
  end;
end;

begin
  writeln('dll machine', getDllMachine('SDL2_x86.dll'))
end.
