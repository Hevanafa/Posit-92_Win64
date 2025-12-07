unit Posit92;

{$Mode TP}

interface

uses SDL2Wrapper, Keyboard;

type
  TPosit92 = object
  public
    procedure init;
    procedure setTitle(const value: string);
    procedure cleanup;

    function isKeyDown(const scancode: integer): boolean;

    procedure update;
    procedure flush;
  protected
    done: boolean;
  private
    window: PSDL_Window;
    renderer: PSDL_Renderer;
    vgaTexture: PSDL_Texture;
    keyState: array[0..127] of boolean;  { use DOS scancode }
  end;


implementation

uses VGA;

procedure TPosit92.init;
begin
  if SDL_Init(SDL_INIT_VIDEO) <> 0 then begin
    writeln('SDL_Init failed!');
    halt(1)
  end;

  window := SDL_CreateWindow(
    'SDL2 Window',
    SDL_WINDOWPOS_CENTERED, SDL_WINDOWPOS_CENTERED,
    640, 400,
    SDL_WINDOW_SHOWN);

  renderer := SDL_CreateRenderer(window, -1, 0);

  vgaTexture := SDL_CreateTexture(
    renderer,
    SDL_PIXELFORMAT_BGRA32, SDL_TEXTUREACCESS_STREAMING,
    vgaWidth, vgaHeight);

  done := false
end;

procedure TPosit92.setTitle(const value: string);
begin
  SDL_SetWindowTitle(window, @value[1])
end;

procedure TPosit92.update;
var
  event: TSDL_Event;
  keyEvent: PSDL_KeyboardEvent;
  dosScancode: integer;
begin
  while SDL_PollEvent(@event) <> 0 do begin
    case event.eventType of 
      SDL_QUIT_: done := true;

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
    end;
  end;
end;

procedure TPosit92.cleanup;
begin
  { showCursor }

  { Important: Destroy objects in reverse order }
  SDL_DestroyRenderer(renderer);
  SDL_DestroyWindow(window);
  SDL_Quit
end;


function TPosit92.isKeyDown(const scancode: integer): boolean;
begin
  isKeyDown := keyState[scancode]
end;

procedure TPosit92.flush;
begin
{
  SDL_SetRenderDrawColor(renderer, $64, $95, $ED, $FF);
  SDL_RenderClear(renderer);
}

  SDL_UpdateTexture(vgaTexture, nil, getSurfacePtr, 320 * 4); { pitch = width * 4 bytes }
  SDL_RenderCopy(renderer, vgaTexture, nil, nil);

  SDL_RenderPresent(renderer)
end;


end.
