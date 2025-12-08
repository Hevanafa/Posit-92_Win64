unit Keyboard;

{$Mode TP}

interface

{ SDL Scancodes }
const
  SDL_SCANCODE_ESCAPE = 41;
  SDL_SCANCODE_SPACE = 44;
  { Add more SDL scancodes here }

{ DOS Scancodes }
const
  SC_ESC = $01;
  SC_SPACE = $39;
  { Add more DOS scancodes here }

function SDLToDOSScancode(const scancode: integer): integer;


implementation

function SDLToDOSScancode(const scancode: integer): integer;
var
  result: integer;
begin
  case scancode of
    SDL_SCANCODE_ESCAPE: result := SC_ESC;
    SDL_SCANCODE_SPACE: result := SC_SPACE;
    else result := 0;
  end;

  SDLToDOSScancode := result;
end;

end.
