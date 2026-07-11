{
  Sounds unit
  Part of Posit-92 game engine
  By Hevanafa

  Requires SoundsMixin class
}

unit P92Sounds;

{$Mode ObjFPC}
{$H-}{$J-}

interface

{$ifdef P92_SDL2}
uses SDL2_Mixer, P92AssetRegistry;
{$endif}

procedure InitSounds;

procedure PlaySound(const sndHandle: longint);

{$ifdef P92_WASM}
function GetSoundVolume(sndHandle: longint): double; public name 'GetSoundVolume';
procedure SetSoundVolume(sndHandle: longint; volume: double); public name 'SetSoundVolume';

{ Music playback }

procedure PlayMusic(const sndHandle: longint);
procedure SeekMusic(t: double);
procedure PauseMusic;
procedure StopMusic;

function GetMusicTime: double;
function GetMusicDuration: double;

function GetMusicVolume: double; public name 'GetMusicVolume';
procedure SetMusicVolume(value: double); public name 'SetMusicVolume';

function GetMusicPlaying: boolean; public name 'GetMusicPlaying';
procedure SetMusicPlaying(value: boolean); public name 'SetMusicPlaying';

function GetMusicPauseTime: double; public name 'GetMusicPauseTime';
procedure SetMusicPauseTime(value: double); public name 'SetMusicPauseTime';

function GetMusicRepeat: boolean; public name 'GetMusicRepeat';
procedure SetMusicRepeat(const value: boolean); public name 'SetMusicRepeat';
procedure HandleMusicRepeat(const sndHandle: smallint);
{$endif}
{$ifdef P92_SDL2}
procedure CleanupSounds;
procedure SetSoundVolume(const sndHandle: longint; const volume: single);
{$endif}


implementation

uses
  P92AssetRegistry, P92Conversions, P92Maths, P92PanicDisplay;

var
  soundVolumes: array[1..255] of double;

{
  As for music playback, Pascal mainly only needs to know about:
  - music position
  - music duration
  - is the music playing?
}

  currentMusicHandle: longint;
  isMusicPlaying: boolean;
  musicRepeat: boolean;
  musicVolume: double;

  { in seconds }
  musicPauseTime: double;

{ initialises the audioContext }
procedure JsInitAudio; external 'env' name 'JsInitAudio';

procedure JsPlaySound(sndHandle: longint); external 'env' name 'JsPlaySound';

procedure JsStartMusicPlayer; external 'env' name 'JsStartMusicPlayer';
procedure JsPauseMusic; external 'env' name 'JsPauseMusic';

procedure JsSetMusicBuffer(sndHandle: longint); external 'env' name 'JsSetMusicBuffer';
procedure JsUnsetMusicBuffer; external 'env' name 'JsUnsetMusicBuffer';

procedure JsCreateMusicPlayer; external 'env' name 'JsCreateMusicPlayer';
procedure JsConnectMusicPlayerGraph; external 'env' name 'JsConnectMusicPlayerGraph';
procedure JsDestroyMusicPlayer; external 'env' name 'JsDestroyMusicPlayer';

procedure JsSetMusicVolume(volume: double); external 'env' name 'JsSetMusicVolume';

function JsGetMusicTime: double; external 'env' name 'JsGetMusicTime';
function JsGetMusicDuration: double; external 'env' name 'JsGetMusicDuration';

procedure InitSounds;
var
  a: word;
begin
  for a:=1 to high(soundVolumes) do
    soundVolumes[a] := 0.0;

  currentMusicHandle := 0;
  isMusicPlaying := false;
  musicRepeat := true;
  musicVolume := 1.0;
  musicPauseTime := 0.0;

  JsInitAudio
end;

procedure PlaySound(const sndHandle: longint);
begin
  JsPlaySound(sndHandle)
end;

function GetSoundVolume(sndHandle: longint): double;
begin
  if (sndHandle < low(soundVolumes)) or (sndHandle > high(soundVolumes)) then
    PanicHaltDisplay('Invalid sndHandle: ' + I32Str(sndHandle));

  GetSoundVolume := soundVolumes[sndHandle];
end;

procedure SetSoundVolume(sndHandle: longint; volume: double);
begin
  volume := clamp(volume, 0.0, 1.0);
  soundVolumes[sndHandle] := volume
end;

{ Music playback }

function IsMusicLoaded: boolean;
begin
  IsMusicLoaded := currentMusicHandle > 0
end;

procedure StartMusicPlayer;
begin
  isMusicPlaying := true;
  JsStartMusicPlayer
end;

procedure PlayMusic(const sndHandle: longint);
begin
  if IsMusicLoaded and isMusicPlaying then exit;

  { Resuming }
  if IsMusicLoaded then begin
    JsCreateMusicPlayer;
    JsConnectMusicPlayerGraph;
    StartMusicPlayer;
    exit
  end;

  StopMusic;

  currentMusicHandle := sndHandle;
  JsSetMusicBuffer(sndHandle);

  musicPauseTime := 0.0;
  JsCreateMusicPlayer;
  JsConnectMusicPlayerGraph;
  StartMusicPlayer
end;

procedure PauseMusic;
begin
  { JsGetMusicTime only knows if the music is playing or not }
  musicPauseTime := JsGetMusicTime;
  isMusicPlaying := false;
  JsDestroyMusicPlayer
end;

procedure StopMusic;
begin
  isMusicPlaying := false;
  currentMusicHandle := 0;
  musicPauseTime := 0.0;

  JsDestroyMusicPlayer;
  JsUnsetMusicBuffer;
end;

procedure SeekMusic(t: double);
var
  duration: double;
  wasPlaying: boolean;
begin
  if not IsMusicLoaded then exit;

  duration := JsGetMusicDuration;
  musicPauseTime := clamp(t, 0.0, duration);
  wasPlaying := isMusicPlaying;

  JsDestroyMusicPlayer;
  isMusicPlaying := false;

  if wasPlaying then begin
    JsCreateMusicPlayer;
    JsConnectMusicPlayerGraph;
    StartMusicPlayer
  end;
end;

function GetMusicDuration: double;
begin
  GetMusicDuration := JsGetMusicDuration
end;

function GetMusicTime: double;
begin
  GetMusicTime := JsGetMusicTime
end;

function GetMusicPlaying: boolean;
begin
  GetMusicPlaying := isMusicPlaying
end;

procedure SetMusicPlaying(value: boolean);
begin
  isMusicPlaying := value
end;

function GetMusicPauseTime: double;
begin
  GetMusicPauseTime := musicPauseTime
end;

procedure SetMusicPauseTime(value: double);
begin
  musicPauseTime := value
end;

function GetMusicVolume: double;
begin
  GetMusicVolume := musicVolume
end;

procedure SetMusicVolume(value: double);
begin
  musicVolume := value;
  JsSetMusicVolume(value)
end;

function GetMusicRepeat: boolean;
begin
  GetMusicRepeat := musicRepeat
end;

procedure SetMusicRepeat(const value: boolean);
begin
  musicRepeat := value
end;

{ Handle music repeat (only when it is playing)
  Important: #musicPlayer.loop must be turned off! }
procedure HandleMusicRepeat(const sndHandle: smallint);
begin
  if GetMusicPlaying and (JsGetMusicTime >= JsGetMusicDuration - 0.05) then
    if GetMusicRepeat then begin
      StopMusic;
      PlayMusic(sndHandle)
    end else
      StopMusic;
end;

{$ifdef P92_SDL2}
uses
  SysUtils, SDL2_Mixer,
  P92Conversions, P92Maths, P92Logger;

var
  soundsInitialised: boolean;

procedure InitSounds;
var
  a: longint;
begin
  soundsInitialised := false;
  writeLog('initSounds begin');

  if Mix_OpenAudio(MIX_DEFAULT_FREQUENCY,
    MIX_DEFAULT_FORMAT,
    MIX_DEFAULT_CHANNELS, 2048) < 0 then
  begin
    writeLog('initSounds: Couldn''t initialise SDL_Mixer!');
    exit
  end;

  for a:=1 to high(sounds) do begin
    sounds[a] := default(TSoundEntry);
    sounds[a].volume := 1.0
  end;

  writeLog('initSounds end');
  soundsInitialised := true
end;

procedure CleanupSounds;
var
  a: longint;
begin
  if not soundsInitialised then exit;

  for a := 1 to high(sounds) do
    if sounds[a].chunk <> nil then
      Mix_FreeChunk(sounds[a].chunk);

  Mix_CloseAudio;
  soundsInitialised := false
end;


procedure PlaySound(const sndHandle: longint);
var
  sdlVolume: integer;
begin
  if not soundsInitialised then exit;
  if (sndHandle < 1) or (sndHandle > high(sounds)) then exit;

  if sounds[sndHandle].chunk = nil then begin
    writeWarn('Warning: Attempting to play a nil sound');
    exit
  end;

  sdlVolume := round(sounds[sndHandle].volume * 128);
  Mix_VolumeChunk(sounds[sndHandle].chunk, sdlVolume);

  { -1: any available channel
    0: no looping }
  Mix_PlayChannel(-1, sounds[sndHandle].chunk, 0)
end;

procedure SetSoundVolume(const sndHandle: longint; const volume: single);
begin
  if not soundsInitialised then exit;
  if (sndHandle < 1) or (sndHandle > high(sounds)) then exit;

  sounds[sndHandle].volume := Clamp(volume, 0.0, 1.0)
end;
{$endif}


end.
