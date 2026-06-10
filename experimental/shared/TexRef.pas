{
  Part of Posit-92 game engine
  Hardware images / textures

  This unit is only usable with SDL2 at this moment
}

unit TexRef;

interface

uses sdl2, sdl2_image;

type
  PTexRef = ^TTexRef;
  TTexRef = record
    width: smallint;
    height: smallint;
    texture: PSDL_Texture;
  end;

procedure hwRegisterTexRef(const imgHandle: longint; const tex: PSDL_Texture; const w, h: smallint);

implementation

const
  MaxTexRefs = 128;

var
  texRefs: array[1..MaxTexRefs] of TTexRef;

procedure hwRegisterTexRef(const imgHandle: longint; const tex: PSDL_Texture; const w, h: smallint);
begin
  texRefs[imgHandle].width := w;
  texRefs[imgHandle].height := h;
  texRefs[imgHandle].texture := tex
end;

function hwIsImageSet(const imgHandle: longint): boolean;
begin
  hwIsImageSet := (imgHandle > 0) and (texRefs[imgHandle].texture <> nil)
end;

initialization
  fillchar(texRefs, sizeof(texRefs, 0)

end.

