program Game;

{$Mode ObjFPC}
{$H+}  { Use AnsiStrings }
{$J-}  { Don't allow assignments to typed consts }

uses
{$IFDEF P92_SDL2}
  SysUtils, SDL2, P92CoreSDL2,
{$ENDIF}
{$IFDEF P92_WASM}
  P92WasmHost,
{$ENDIF}
  P92Core, P92Fonts, P92AssetRegistry,
  P92Keyboard, P92Mouse,
  P92Tex, P92TexDraw, P92Sounds,
  P92Logger, P92Timing, P92VGA,
  Assets;

var
  { Game state variables }
  gameTime: double;

procedure OnPreload;
begin
  texSpecimenP92[0] := RequestImage('assets\images\specimen_p-92_1.png');
  texSpecimenP92[1] := RequestImage('assets\images\specimen_p-92_2.png');

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

  FreeTex(texSpecimenP92[0]);
  FreeTex(texSpecimenP92[1]);
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
    spr(texSpecimenP92[1], 148, 88)
  else
    spr(texSpecimenP92[0], 148, 88);

  PrintDefaultCentred('Hello world!', vgaWidth div 2, 120)
end;


procedure Init;
var
  config: TP92AppConfig;
begin
  config := DefaultP92AppConfig;

{$IFDEF P92_SDL2}
  config.WindowTitle := 'Posit-92 with SDL2';

  config.OnPreload := @OnPreload;
  config.OnReady := @OnReady;
  config.Update := @Update;
  config.Draw := @Draw;
  config.OnCleanup := @OnCleanup;
{$ENDIF}

  P92Start(config)
end;

{$IFDEF P92_SDL2}
{$R *.res}

begin
  Init
end.
{$ENDIF}

{$IFDEF P92_WASM}
begin
  { Entry point is intentionally left empty }
end.
{$ENDIF}
