unit Posit92;

{$Mode TP}

interface

uses SDL2Wrapper;

type
  TPosit92 = object
  public
    procedure init;
    { procedure afterInit; }
    procedure cleanup;
    { procedure update; }
    procedure draw;
  private
    window: PSDL_Window;
    renderer: PSDL_Renderer;
  end;


implementation

procedure TPosit92.init;
const
  title = 'Posit-92 with SDL2';
begin
  if SDL_Init(SDL_INIT_VIDEO) <> 0 then begin
    writeln('SDL_Init failed!');
    halt(1)
  end;

  window := SDL_CreateWindow(
    title,
    SDL_WINDOWPOS_CENTERED, SDL_WINDOWPOS_CENTERED,
    640, 400,
    SDL_WINDOW_SHOWN);

  renderer := SDL_CreateRenderer(window, -1, 0);

  writeln('Hello from TPosit92.init!')
end;

procedure TPosit92.cleanup;
begin
  { showCursor }

  { Important: Destroy objects in reverse order }
  SDL_DestroyRenderer(renderer);
  SDL_DestroyWindow(window);
  SDL_Quit
end;


procedure TPosit92.draw;
begin
  SDL_SetRenderDrawColor(renderer, $64, $95, $ED, $FF);
  SDL_RenderClear(renderer);
  SDL_RenderPresent(renderer)
end;


end.
