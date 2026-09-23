unit P92Fonts;

{$Mode ObjFPC}
{$H-}  { Use ShortStrings }
{$J-}  { Don't allow assignments to typed consts }

interface

uses P92AssetHandles;

procedure LoadDefaultFont;
function GetDefaultFontHandle: TBMFontHandle;

procedure PrintDefault(const text: string; const x, y: integer);
procedure PrintDefaultCentred(const text: string; const cx, y: integer);
function MeasureDefault(const text: string): word;

function PrintCharColour(const ch: char; const x, y: integer; const colour: longword): word;


implementation

uses
  P92AssetRegistry, P92BMFont, P92Core, P92Logger;

var
  defaultFontHandle: TBMFontHandle;
  shownWarning: boolean;

function GetDefaultFontHandle: TBMFontHandle;
begin
  GetDefaultFontHandle := defaultFontHandle
end;

procedure LoadDefaultFont;
begin
{$ifdef P92_WASM}
  defaultFontHandle := RequestBMFont('assets/fonts/nokia_cellphone_fc_8.txt')
{$endif}

{$ifdef P92_SDL2}
  defaultFontHandle := RequestBMFont(bootConfig.defaultFontPath)
{$endif}
end;

function EnsureDefaultFont: boolean;
begin
  EnsureDefaultFont := defaultFontHandle > 0;

  if not EnsureDefaultFont and not shownWarning then begin
    WriteWarn('Default font is unavailable (either disabled or not loaded)');
    shownWarning := true
  end;
end;

procedure PrintDefault(const text: string; const x, y: integer);
begin
  if not EnsureDefaultFont then exit;

  PrintBMFont(defaultFontHandle, text, x, y)
end;

procedure PrintDefaultCentred(const text: string; const cx, y: integer);
var
  w: word;
begin
  if not EnsureDefaultFont then exit;

  w := MeasureDefault(text);
  PrintDefault(text, cx - w div 2, y)
end;

function MeasureDefault(const text: string): word;
begin
  if not EnsureDefaultFont then begin
    MeasureDefault := 0;
    exit
  end;

  MeasureDefault := MeasureBMFont(defaultFontHandle, text)
end;

{ Returns the width of the glyph }
function PrintCharColour(const ch: char; const x, y: integer; const colour: longword): word;
begin
  if not EnsureDefaultFont then begin
    PrintCharColour := 0;
    exit
  end;

  PrintCharColour := PrintBMFontCharColour(
    defaultFontHandle, ch, x, y, colour)
end;

initialization
  defaultFontHandle := 0;

end.

