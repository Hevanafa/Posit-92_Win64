unit Assets;

{$Mode TP}

interface

uses BMFont;

var
  imgGasolineMaid: longint;
  imgXPCursor: longint;

  defaultFont: TBMFont;
  defaultFontGlyphs: array [32..126] of TBMFontGlyph;

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