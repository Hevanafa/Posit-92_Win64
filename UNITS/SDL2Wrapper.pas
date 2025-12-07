unit SDL2Wrapper;

{$Mode TP}

interface

const 
  SDL_INIT_VIDEO = $00000020;
  SDL_WINDOWPOS_CENTERED = $2FFF0000;
  SDL_WINDOW_SHOWN = $00000004;

  SDL_PIXELFORMAT_RGBA32 = $16462004;
  SDL_TEXTUREACCESS_STREAMING = 1;

type
  PSDL_Window = pointer;
  PSDL_Renderer = pointer;
  PSDL_Texture = pointer;

function SDL_Init(flags: longword): longint; cdecl; external 'SDL2.dll';
function SDL_CreateWindow(title: PChar; x, y, w, h: longint; flags: longword): PSDL_Window; cdecl; external 'SDL2.dll';
function SDL_CreateRenderer(window: PSDL_Window; index: longint; flags: longword): PSDL_Renderer; cdecl; external 'SDL2.dll';
procedure SDL_DestroyRenderer(renderer: PSDL_Renderer); cdecl; external 'SDL2.dll';
procedure SDL_DestroyWindow(window: PSDL_Window); cdecl; external 'SDL2.dll';
procedure SDL_Quit; cdecl; external 'SDL2.dll';
procedure SDL_Delay(ms: longword); cdecl; external 'SDL2.dll';

procedure SDL_SetRenderDrawColor(renderer: PSDL_Renderer; r, g, b, a: byte); cdecl; external 'SDL2.dll';
procedure SDL_RenderClear(renderer: PSDL_Renderer); cdecl; external 'SDL2.dll';
procedure SDL_RenderPresent(renderer: PSDL_Renderer); cdecl; external 'SDL2.dll';

function SDL_CreateTexture(renderer: PSDL_Renderer; format: longword; access, w, h: longint): PSDL_Texture; cdecl; external 'SDL2.dll';
function SDL_UpdateTexture(texture: PSDL_Texture; rect, pixels: pointer; pitch: longint): longint; cdecl; external 'SDL2.dll';
function SDL_RenderCopy(renderer: PSDL_Renderer; texture: PSDL_Texture; srcrect, dstrect: pointer): longint; cdecl; external 'SDL2.dll';
function SDL_DestroyTexture(texture: PSDL_Texture); cdecl; external 'SDL2.dll';


implementation

end.