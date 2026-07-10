program Game;

{$Mode ObjFPC}
{$H+}  { Use AnsiStrings }
{$J-}  { Don't allow assignments to typed consts }

uses
  SysUtils, SDL2,
  P92Core, P92Fonts,
  P92Keyboard, P92Mouse,
  P92Tex, P92TexDraw, P92Sounds,
  P92Logger, P92Timing, P92VGA,
  Assets;

var
  { Game state variables }
  gameTime: double;

procedure OnPreload;
begin
  imgSpecimenP92[0] := LoadImage('assets\images\specimen_p-92_1.png');
  imgSpecimenP92[1] := LoadImage('assets\images\specimen_p-92_2.png');

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

procedure Update;
begin
  if IsKeyDown(SC_ESCAPE) then SignalDone;

  gameTime := gameTime + DeltaTime
end;

procedure Draw;
begin
  cls($FF6495ED);

  if (trunc(gameTime * 4) and 1) > 0 then
    spr(imgSpecimenP92[1], 148, 88)
  else
    spr(imgSpecimenP92[0], 148, 88);

  PrintDefaultCentred('Hello world!', vgaWidth div 2, 120);

  PrintDefault(format('Mouse: { %d, %d }', [mouseX, mouseY]), 10, 10);
end;


{$R *.res}

var
  appConfig: TP92AppConfig;
begin
  appConfig := DefaultP92AppConfig;

  with appConfig do begin
    windowTitle := 'Posit-92 with SDL2';
  end;

  appConfig.OnPreload := @OnPreload;
  appConfig.OnReady := @OnReady;
  appConfig.Update := @Update;
  appConfig.Draw := @Draw;
  appConfig.OnCleanup := @OnCleanup;

  P92Start(appConfig)
end.

