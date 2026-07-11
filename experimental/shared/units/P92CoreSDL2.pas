unit P92CoreSDL2;

interface

uses SDL2;

var
  done: boolean;

  window: PSDL_Window;
  renderer: PSDL_Renderer;
  vgaTexture: PSDL_Texture;

procedure SetTitle(const value: string);

procedure SignalDone;
procedure HideCursor;
procedure ShowCursor;


implementation

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

end.
