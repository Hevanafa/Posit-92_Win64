unit Assets;

{$Mode TP}

interface

uses BMFont;

var
  defaultFont: TBMFont;
  defaultFontGlyphs: array [32..126] of TBMFontGlyph;

  imgCursor: longint;
  imgDosuEXE: array[0..1] of longint;
  imgFullFont: longint;

{ BMFont boilerplate }
procedure printDefault(const text: string; const x, y: integer);
function measureDefault(const text: string): word;


implementation

procedure printDefault(const text: string; const x, y: integer);
begin
  printBMFont(text, x, y, defaultFont, defaultFontGlyphs)
end;

function measureDefault(const text: string): word;
begin
  measureDefault := measureBMFont(text, defaultFontGlyphs)
end;


end.