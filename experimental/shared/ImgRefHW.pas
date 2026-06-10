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

