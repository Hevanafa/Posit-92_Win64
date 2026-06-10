{
  Part of Posit-92 game engine
  Hardware images / textures

  This unit is only usable with SDL2 at this moment
}

unit ImgRefHW;

interface

uses sdl2, sdl2_image;

type
  PImageRefHW = ^TImageRefHW;
  TImageRefHW = record
    width: smallint;
    height: smallint;
    dataPtr: PSDL_Texture;
  end;


implementation

const
  MaxTexRefs = 128;

var
  texRefs: array[1..MaxTexRefs] of TImageRefHW;

end.

