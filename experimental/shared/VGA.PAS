{
  VGA unit - Part of Posit-92 game engine
  Hevanafa
}

unit VGA;

{$Mode ObjFPC}
{$H+}{$J-}
{$R-}
{$Q-}

{$Notes OFF}

interface

type
  PByteArray = ^TByteArray;
  TByteArray = array[0..0] of byte;

{$ifdef WASM}
procedure vgaFlush; external 'env' name 'vgaFlush';
{$endif}

function vgaWidth: smallint;
function vgaHeight: smallint;

{ Ref: https://www.freepascal.org/docs-html/ref/refse22.html }
procedure initVideoMem(const width, height: smallint; const startAddr: PByteArray); public name 'initVideoMem';
function getSurfacePtr: PByteArray; public name 'getSurfacePtr';

{ colour format: $AARRGGBB, ARGB like in QB64 PE }
procedure cls(const colour: longword);
{ colour format: $AARRGGBB }
procedure clsBlend(const colour: longword);

function unsafePget(const x, y: smallint): longword;
function pget(const x, y: smallint): longword;

procedure legacyUnsafePset(const x, y: smallint; const colour: longword);
procedure unsafePset(const x, y: smallint; const colour: longword);
procedure pset(const x, y: smallint; const colour: longword);

procedure unsafePsetBlend(const x, y: smallint; const colour: longword);
procedure psetBlend(const x, y: smallint; const colour: longword);


implementation

{$ifdef WASM}
uses
  Logger,
  WasmHeap;
{$endif}
{$ifdef Windows}
uses
  Conv, Logger;
{$endif}

var
  _vgaWidth, _vgaHeight: smallint;
  bufferSize: longword;
  activeSurface: PByteArray;

function vgaWidth: smallint;
begin
  vgaWidth := _vgaWidth
end;

function vgaHeight: smallint;
begin
  vgaHeight := _vgaHeight
end;

procedure initVideoMem(const width, height: smallint; const startAddr: PByteArray);
begin
  { writeLog('Attempting to call initVideoMem'); }
  _vgaWidth := width;
  _vgaHeight := height;
  bufferSize := _vgaWidth * _vgaHeight * 4;

  activeSurface := startAddr;
  fillchar(activeSurface^, bufferSize, 0);
end;

function getSurfacePtr: PByteArray;
begin
  getSurfacePtr := activeSurface
end;

function unsafePget(const x, y: smallint): longword;
var
  offset: longword;
begin
  offset := (x + y * _vgaWidth) * 4;

  { RGBA to ARGB }
  unsafePget := activeSurface^[offset + 3] shl 24
    or activeSurface^[offset] shl 16
    or activeSurface^[offset + 1] shl 8
    or activeSurface^[offset + 2]
end;

{ Gets the colour of a pixel }
function pget(const x, y: smallint): longword;
begin
  if (x >= vgaWidth) or (x < 0) or (y >= vgaHeight) or (y < 0) then begin
    pget := 0;
    exit
  end;

  pget := unsafePget(x, y)
end;

procedure legacyUnsafePset(const x, y: smallint; const colour: longword);
var
  offset: longword;
begin
  offset := (y * vgaWidth + x) * 4;

  { ARGB to RGBA }
  activeSurface^[offset] := (colour shr 16) and $FF;
  activeSurface^[offset + 1] := (colour shr 8) and $FF;
  activeSurface^[offset + 2] := colour and $FF;
  activeSurface^[offset + 3] := (colour shr 24) and $FF;
end;

procedure unsafePset(const x, y: smallint; const colour: longword);
begin
  { ARGB to RGBA }
  PLongWord(@activeSurface^[(y * vgaWidth + x) * 4])^ :=
    ((colour and $00FF0000) shr 16)
    or ((colour and $0000FF00))
    or ((colour and $000000FF) shl 16)
    or ((colour and $FF000000))
end;

{ colour: AARRGGBB }
procedure pset(const x, y: smallint; const colour: longword);
begin
  if (x >= vgaWidth) or (x < 0) or (y >= vgaHeight) or (y < 0) then exit;
  unsafePset(x, y, colour)
end;


procedure legacyUnsafePsetBlend(const x, y: smallint; const colour: longword);
var
  srcA, srcR, srcG, srcB: byte;
  destA, destR, destG, destB: byte;
  outA, outR, outG, outB: byte;
  offset: longword;
  { inverted alpha }
  alpha, invAlpha: single;
begin
  srcA := colour shr 24 and $FF;

  if srcA = 0 then exit;

  srcR := colour shr 16 and $FF;
  srcG := colour shr 8 and $FF;
  srcB := colour and $FF;
  
  offset := (x + y * vgaWidth) * 4;

  { Handle opaque pixel }
  if srcA = 255 then begin
    activeSurface^[offset] := srcR;
    activeSurface^[offset + 1] := srcG;
    activeSurface^[offset + 2] := srcB;
    activeSurface^[offset + 3] := srcA;
    exit
  end;

  destR := activeSurface^[offset];
  destG := activeSurface^[offset + 1];
  destB := activeSurface^[offset + 2];
  destA := activeSurface^[offset + 3];
  
  { Handle alpha blending }
  alpha := srcA / 255.0;
  invAlpha := 1.0 - alpha;

  outR := round(srcR * alpha + destR * invAlpha);
  outG := round(srcG * alpha + destG * invAlpha);
  outB := round(srcB * alpha + destB * invAlpha);
  outA := srcA + round(destA * invAlpha);

  activeSurface^[offset] := outR;
  activeSurface^[offset + 1] := outG;
  activeSurface^[offset + 2] := outB;
  activeSurface^[offset + 3] := outA;
end;

procedure unsafePsetBlend(const x, y: smallint; const colour: longword);
var
  srcA, srcR, srcG, srcB: byte;
  destA, destR, destG, destB: byte;
  offset: longword;
  { inverted alpha }
  alpha, invAlpha: single;
begin
  srcA := colour shr 24 and $FF;

  if srcA = 0 then exit;

  srcR := colour shr 16 and $FF;
  srcG := colour shr 8 and $FF;
  srcB := colour and $FF;
  
  offset := (x + y * vgaWidth) * 4;

  { Handle opaque pixel }
  if srcA = 255 then begin
    unsafePset(x, y, colour);
    exit
  end;

  destR := activeSurface^[offset];
  destG := activeSurface^[offset + 1];
  destB := activeSurface^[offset + 2];
  destA := activeSurface^[offset + 3];
  
  { Handle alpha blending }
  alpha := srcA / 255.0;
  invAlpha := 1.0 - alpha;

  PLongWord(@activeSurface^[offset])^ :=
    (round(srcR * alpha + destR * invAlpha))
    or (round(srcG * alpha + destG * invAlpha) shl 8)
    or (round(srcB * alpha + destB * invAlpha) shl 16)
    or ((srcA + round(destA * invAlpha)) shl 24)
end;

procedure psetBlend(const x, y: smallint; const colour: longword);
begin
  if (x >= vgaWidth) or (x < 0) or (y >= vgaHeight) or (y < 0) then exit;

  unsafePsetBlend(x, y, colour)
end;

procedure cls(const colour: longword);
var
  a, b: byte;
  rgba: longword;
begin
  a := (colour and $FF000000) shr 24;
  rgba := (colour and $FFFFFF) shl 8 or a;

  { hexstr: cnt is in nibbles (half byte), not bytes }
  writelog('rgba: ' + hexstr(rgba, 8));

  { TODO: Fix the orange-ish yellow background }
  FillDWord(getSurfacePtr^, vgaWidth * vgaHeight, rgba);

  writelog('Surface: ' + hexstr(activeSurface^[0] shl 8 or activeSurface^[1] shl 8 or activeSurface^[2] shl 8 or activeSurface^[3], 8));

  { for b:=0 to vgaHeight - 1 do
  for a:=0 to vgaWidth - 1 do
    unsafePset(a, b, colour); }
end;

procedure clsBlend(const colour: longword);
var
  a, b: word;
begin
  for b:=0 to vgaHeight - 1 do
  for a:=0 to vgaWidth - 1 do
    unsafePsetBlend(a, b, colour);
end;


end.
