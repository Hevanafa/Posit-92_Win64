program Game;

{$Mode ObjFPC}
{$H+}  { Use AnsiStrings }
{$J-}  { Don't allow assignments to typed consts }

uses
  SysUtils, SDL2,
  P92Core, P92CoreSDL2, P92Fonts, P92AssetRegistry,
  P92Conversions,
  P92Keyboard, P92Mouse,
  P92Tex, P92TexDraw, P92Sounds,
  P92Logger, P92Timing, P92VGA,
  Assets;

const
  Black = $FF000000;

var
  { Game state variables }
  gameTime: double;

procedure OnPreload;
begin
  imgSpecimenP92[0] := RequestImage('assets\images\specimen_p-92_1.png');
  imgSpecimenP92[1] := RequestImage('assets\images\specimen_p-92_2.png');

  imgEGAFont := RequestImage('assets\EGA8x14.png');
  imgCGAFont2y := RequestImage('assets\CGA8x16.png');;

  { Load more assets here }
end;

procedure OnReady;
begin
  HideCursor;

  { Init your game state here }
  gameTime := 0.0
end;

procedure OnCleanup;
begin
  ShowCursor;

  FreeTexture(imgSpecimenP92[0]);
  FreeTexture(imgSpecimenP92[1]);
end;


procedure PrintChar(const c: char; const x, y: smallint);
const
  GlyphWidth = 8;
  GlyphHeight = 16;
var
  row, col: smallint;
  texture: PSoftwareTex;
  a, b: smallint;
  colour: longword;
  sx, sy: smallint;
  destX, destY: smallint;
begin
  if not (ord(c) in [1..255]) then exit;

  row := ord(c) div 16;
  col := ord(c) mod 16;

  { SprRegion(
    imgCGAFont2y,
    col * 8, row * 16,
    8, 14,
    x, y) }

  sx := col * GlyphWidth;
  sy := row * GlyphHeight;

  texture := BorrowTexturePtr(imgCGAFont2y);

  { glyph size: 8x16 }

  for b:=0 to GlyphHeight - 1 do
  for a:=0 to GlyphWidth - 1 do begin
    if (x + a > ClipX2) or (x + a < ClipX1)
      or (y + b > ClipY2) or (y + b < ClipY1) then continue;

    sx := sx + a;
    sy := sy + b;
    srcPos := (sx + sy * texture^.width) * 4;

    alpha := texture^.pixelData[srcPos + 3];
    if alpha < 255 then continue;

    colour := UnsafeSprPget(texture, sx, sy);
    UnsafePset(destX + a, destY + b, colour);
  end;
end;

procedure PrintCharColour(const c: char; const x, y: smallint; const colour: longword);
begin

end;

procedure Print(const txt: string; const x, y: smallint);
var
  c: char;
  left: smallint;
begin
  left := x;

  for c in txt do begin
    PrintChar(c, left, y);
    inc(left, 8)
  end;
end;


procedure Update;
begin
  if IsKeyDown(SC_ESCAPE) then SignalDone;

  gameTime := gameTime + DeltaTime
end;

procedure Draw;
var
  a: smallint;
begin
  cls(black);

  if (trunc(gameTime * 4) and 1) > 0 then
    spr(imgSpecimenP92[1], 148, 88)
  else
    spr(imgSpecimenP92[0], 148, 88);

  {spr(imgEGAFont, 10, 10); }

  for a:=0 to 79 do
    print(i32str(a mod 10), 8 * a, 16);

  { PrintDefaultCentred('Hello world!', vgaWidth div 2, 120) }
end;


{$R *.res}

var
  appConfig: TP92AppConfig;
begin
  appConfig := DefaultP92AppConfig;

  with appConfig do begin
    windowTitle := 'Posit-92 with SDL2';

    width := 8 * 40;
    height := 16 * 13;
    { sdlScale := 1; }

    enableDefaultFont := false;
  end;

  appConfig.OnPreload := @OnPreload;
  appConfig.OnReady := @OnReady;
  appConfig.Update := @Update;
  appConfig.Draw := @Draw;
  appConfig.OnCleanup := @OnCleanup;

  P92Start(appConfig)
end.

