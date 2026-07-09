program Game;

{$Mode ObjFPC}
{$H+}  { Use AnsiStrings }
{$J-}  { Don't allow assignments to typed consts }

uses
  SysUtils, SDL2,
  Posit92,
  P92Colour, P92FPS,
  P92Keyboard, P92Mouse, P92Sounds,
  P92Tex, P92TexDraw, P92TexRef,
  P92Logger, P92Timing, P92Panic, P92VGA,
  Assets;

const
  TargetFPS = 60;
  FrameTime = 1000 div TargetFPS;

var
  { Game state variables }
  gameTime: double;

procedure DrawMouse;
begin
  { spr(imgCursor, mouseX, mouseY) }
  HwSpr(hwCursor, mouseX, mouseY)
end;

procedure OnPreload;
begin
  { imgCursor := LoadImage('assets\images\cursor.png'); }
  hwCursor := HwLoadImage('assets\images\cursor.png');
  imgDosuEXE[0] := LoadImage('assets\images\dosu_1.png');
  imgDosuEXE[1] := LoadImage('assets\images\dosu_2.png');

  LoadBMFont(
    'assets\fonts\nokia_cellphone_fc_8.txt',
    defaultFont, defaultFontGlyphs);

  { Load more assets here }
end;

procedure OnReady;
begin
  SetTitle('Posit-92 with SDL2');

  OnPreload;
  HideCursor;

  { Init your game state here }
  gameTime := 0.0
end;

procedure Cleanup;
begin
  ShowCursor;

  FreeTexture(imgCursor);
  FreeTexture(imgDosuEXE[0]);
  FreeTexture(imgDosuEXE[1]);
  FreeTexture(imgFullFont);

  FreeTexture(defaultFont.imgHandle);

  freemem(getSurfacePtr);

  { Your Cleanup code here (after setting `done` to true) }
  CloseLogger;
  CleanupSDL
end;

procedure Update;
begin
  UpdateSDL;
  UpdateDeltaTime;

  { Your Update logic here }
  if IsKeyDown(SC_ESCAPE) then done := true;

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

  VgaUpload;

  { Begin hardware layer }

  DrawMouse;

  VgaPresent
end;


var
  { done: boolean; }  { moved to Posit92 unit }
  lastFrameTime, frameTimeNow, elapsed: longword; { in ms }

{$R *.res}

begin
  P92Run(@Init, @OnPreload, @OnReady);
  Init;
  OnReady;

  done := false;

  lastFrameTime := SDL_GetTicks;

  while not done do begin
    frameTimeNow := SDL_GetTicks;
    elapsed := frameTimeNow - lastFrameTime;

    if elapsed >= FrameTime then begin
      lastFrameTime := frameTimeNow - (elapsed mod FrameTime); { Carry over extra time }
      Update;
      Draw
    end;

    SDL_Delay(1)
  end;

  Cleanup
end.


