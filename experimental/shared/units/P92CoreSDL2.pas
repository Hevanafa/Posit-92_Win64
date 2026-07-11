unit P92CoreSDL2;

interface

uses SDL2;

var
  TargetFPS: smallint;
  { in ms }
  FrameTime: longword;

  done: boolean;

  window: PSDL_Window;
  renderer: PSDL_Renderer;
  { texture obtained by copying the software surface }
  vgaTexture: PSDL_Texture;

  { FPS stuff }
  lastFrameTime, frameTimeNow, elapsed: longword; { in ms }

procedure SetTitle(const value: string);

procedure SignalDone;
procedure HideCursor;
procedure ShowCursor;

procedure InitSDL;
procedure UpdateSDL;
procedure CleanupSDL;


implementation

uses
  P92Core,
  P92Keyboard, P92Mouse,
  P92TexRef, P92VGA;

procedure SetTitle(const value: string);
begin
  SDL_SetWindowTitle(window, @value[1])
end;

procedure SignalDone;
begin
  done := true
end;

procedure HideCursor;
begin
  SDL_ShowCursor(SDL_DISABLE)
end;

procedure ShowCursor;
begin
  SDL_ShowCursor(SDL_ENABLE)
end;

procedure InitSDL;
var
  windowTitle: AnsiString;
begin
  if SDL_Init(SDL_INIT_VIDEO) <> 0 then begin
    writeln('SDL_Init failed!');
    halt(1)
  end;

  { this converts the ShortString to AnsiString }
  windowTitle := bootConfig.windowTitle;

  window := SDL_CreateWindow(
    PAnsiChar(windowTitle),
    SDL_WINDOWPOS_CENTERED, SDL_WINDOWPOS_CENTERED,
    vgaWidth * bootConfig.sdlScale, vgaHeight * bootConfig.sdlScale,
    SDL_WINDOW_SHOWN);

  renderer := SDL_CreateRenderer(window, -1, SDL_RENDERER_ACCELERATED);
  SDL_RenderSetLogicalSize(renderer, vgaWidth, vgaHeight);

  vgaTexture := SDL_CreateTexture(
    renderer,
    SDL_PIXELFORMAT_RGBA32, SDL_TEXTUREACCESS_STREAMING,
    vgaWidth, vgaHeight);

  HwSetRenderer(renderer)
end;


procedure UpdateSDL;
var
  event: TSDL_Event;
  keyEvent: PSDL_KeyboardEvent;
  dosScancode: integer;
  mouseEvent: PSDL_MouseMotionEvent;
  buttonEvent: PSDL_MouseButtonEvent;
begin
  while SDL_PollEvent(@event) <> 0 do begin
    { case event.eventType of } { SDL2Wrapper }
    case event.type_ of
      { SDL_QUIT_: } { SDL2Wrapper }
      SDL_QUITEV:
        done := true;

      { Keyboard }
      SDL_KEYDOWN: begin
        keyEvent := PSDL_KeyboardEvent(@event);
        if keyEvent^.repeat_ = 0 then begin
          dosScancode := SDLToDOSScancode(keyEvent^.keysym.scancode);

          if dosScancode <> 0 then
            keyState[dosScancode] := true;
        end;
      end;

      SDL_KEYUP: begin
        keyEvent := PSDL_KeyboardEvent(@event);
        dosScancode := SDLToDOSScancode(keyEvent^.keysym.scancode);

        if dosScancode <> 0 then
          keyState[dosScancode] := false;
      end;

      { Mouse }
      SDL_MOUSEMOTION: begin
        mouseEvent := PSDL_MouseMotionEvent(@event);
        mouseX := mouseEvent^.x;
        mouseY := mouseEvent^.y;
      end;

      SDL_MOUSEBUTTONDOWN: begin
        buttonEvent := PSDL_MouseButtonEvent(@event);
        case buttonEvent^.button of
          SDL_BUTTON_LEFT:
            mouseButton := mouseButton or MouseButtonLeft;
          SDL_BUTTON_RIGHT:
            mouseButton := mouseButton or MouseButtonRight;
        end;
      end;

      SDL_MOUSEBUTTONUP: begin
        buttonEvent := PSDL_MouseButtonEvent(@event);
        case buttonEvent^.button of
          SDL_BUTTON_LEFT:
            mouseButton := mouseButton xor MouseButtonLeft;
          SDL_BUTTON_RIGHT:
            mouseButton := mouseButton xor MouseButtonRight;
        end;
      end;
    end;
  end;
end;

procedure CleanupSDL;
begin
  { Important: Destroy objects in reverse order }
  SDL_DestroyRenderer(renderer);
  SDL_DestroyWindow(window);
  SDL_Quit
end;

end.
