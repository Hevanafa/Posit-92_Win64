program Game;

{$Mode ObjFPC}
{$H+}  { Use AnsiStrings }
{$J-}  { Don't allow assignments to typed consts }

uses
  SysUtils, SDL2,
  P92Core, P92Fonts,
  P92Colour, P92FPS,
  P92Keyboard, P92Mouse, P92Sounds,
  P92Tex, P92TexDraw, P92TexRef,
  P92Logger, P92Timing, P92Panic, P92VGA,
  Assets;

var
  { Game state variables }
  gameTime: double;

procedure OnPreload;
begin
  imgDosuEXE[0] := LoadImage('assets\images\dosu_1.png');
  imgDosuEXE[1] := LoadImage('assets\images\dosu_2.png');

  { Load more assets here }
end;

procedure OnReady;
begin
  HideCursor;
  SetTitle('Posit-92 with SDL2');

  { Init your game state here }
  gameTime := 0.0
end;

procedure OnCleanup;
begin
  ShowCursor;

  FreeTexture(imgCursor);
  FreeTexture(imgDosuEXE[0]);
  FreeTexture(imgDosuEXE[1]);
  FreeTexture(imgFullFont);

  FreeTexture(defaultFont.imgHandle);
end;

procedure Update;
begin
  { Your Update logic here }
  if IsKeyDown(SC_ESCAPE) then SignalDone;

  gameTime := gameTime + DeltaTime
end;

procedure Draw;
begin
  { Begin software layer }
  cls($FF6495ED);

  if (trunc(gameTime * 4) and 1) > 0 then
    spr(imgDosuEXE[1], 148, 88)
  else
    spr(imgDosuEXE[0], 148, 88);

  printDefaultCentred('Hello world!', vgaWidth div 2, 120);

  printDefault(format('Mouse: { %d, %d }', [mouseX, mouseY]), 10, 10);
end;


{$R *.res}

begin
  P92Start(@OnPreload, @OnReady, @Update, @Draw, @OnCleanup);

end.


