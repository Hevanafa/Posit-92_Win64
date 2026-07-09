unit Assets;

{$Mode ObjFPC}
{$H+}  { Use AnsiStrings }
{$J-}  { Don't allow assignments to typed consts }

interface

uses BMFont;

var
  { for use in loadBMFont }
  defaultFont: TBMFontLegacy;
  defaultFontGlyphs: array[32..126] of TBMFontGlyph;

  imgCursor: longint;
  imgDosuEXE: array[0..1] of longint;
  imgFullFont: longint;

  hwCursor: longint;

{ BMFont boilerplate }
procedure printDefault(const text: string; const x, y: integer);
procedure printDefaultCentred(const text: string; const cx, y: integer);
function measureDefault(const text: string): word;


implementation

procedure printDefault(const text: string; const x, y: integer);
begin
  printBMFont(defaultFont, defaultFontGlyphs, text, x, y)
end;

procedure printDefaultCentred(const text: string; const cx, y: integer);
var
  w: word;
begin
  w := measureDefault(text);
  printDefault(text, cx - w div 2, y)
end;

function measureDefault(const text: string): word;
begin
  measureDefault := measureBMFont(defaultFont, defaultFontGlyphs, text)
end;


end.
