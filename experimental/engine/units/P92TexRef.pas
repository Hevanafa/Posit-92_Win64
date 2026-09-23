{
  Part of Posit-92 game engine
  Hardware images / textures

  This unit is only usable with SDL2 at this moment
}

unit P92TexRef;

interface

uses
  SDL2, SDL2_image,
  P92AssetHandles;

type
  PTexRef = ^TTexRef;
  TTexRef = record
    width: smallint;
    height: smallint;
    texture: PSDL_Texture;
  end;

procedure HwSetRenderer(const r: PSDL_Renderer);
function HwRegisterTexRef(const tex: PSDL_Texture; const w, h: smallint): THWTextureHandle;
procedure HwFreeTex(const texHandle: THWTextureHandle);

{ Blitting procedures }

procedure HwSpr(const texHandle: THWTextureHandle; const x, y: smallint);

procedure HwSprRegion(
  const texHandle: THWTextureHandle;
  const srcX, srcY, srcW, srcH: smallint;
  const destX, destY: smallint);


implementation

uses
  P92Panic;

const
  MaxTexRefs = 128;

var
  texRefs: array[1..MaxTexRefs] of TTexRef;
  renderer: PSDL_Renderer;

procedure HwSetRenderer(const r: PSDL_Renderer);
begin
  renderer := r
end;

function HwIsTextureSet(const texHandle: longint): boolean;
begin
  HwIsTextureSet := (texHandle > 0) and (texRefs[texHandle].texture <> nil)
end;

function HwFindEmptyImageSlot: longint;
var
  a: longint;
begin
  for a:=1 to high(texRefs) do
    if not HwIsTextureSet(a) then begin
      HwFindEmptyImageSlot := a;
      exit
    end;

  HwFindEmptyImageSlot := -1
end;

function HwRegisterTexRef(const tex: PSDL_Texture; const w, h: smallint): THWTextureHandle;
var
  imgHandle: longint;
begin
  imgHandle := HwFindEmptyImageSlot;

  if imgHandle < 1 then panicHalt('Texture ref pool is full!');

  HwRegisterTexRef := imgHandle;
  texRefs[imgHandle].width := w;
  texRefs[imgHandle].height := h;
  texRefs[imgHandle].texture := tex
end;

procedure HwFreeTex(const texHandle: THWTextureHandle);
begin
  if not HwIsTextureSet(texHandle) then exit;

  texRefs[texHandle].width := 0;
  texRefs[texHandle].height := 0;
  SDL_DestroyTexture(texRefs[texHandle].texture)
end;


procedure HwSpr(const texHandle: THWTextureHandle; const x, y: smallint);
var
  dest: TSDL_Rect;
begin
  if not HwIsTextureSet(texHandle) then exit;

  dest.x := x;
  dest.y := y;
  dest.w := texRefs[texHandle].width;
  dest.h := texRefs[texHandle].height;

  SDL_RenderCopy(renderer, texRefs[texHandle].texture, nil, @dest)
end;

procedure HwSprRegion(
  const texHandle: THWTextureHandle;
  const srcX, srcY, srcW, srcH: smallint;
  const destX, destY: smallint
);
var
  src, dest: TSDL_Rect;
begin
  if not HwIsTextureSet(texHandle) then exit;

  src.x := srcX;
  src.y := srcY;
  src.w := srcW;
  src.h := srcH;

  dest.x := destX;
  dest.y := destY;
  dest.w := srcW;
  dest.h := srcH;

  SDL_RenderCopy(renderer, texRefs[texHandle].texture, @src, @dest)
end;

initialization
  fillchar(texRefs, sizeof(texRefs), 0)

end.

