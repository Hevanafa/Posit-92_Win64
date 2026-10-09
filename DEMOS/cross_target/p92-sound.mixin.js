"use strict";
globalThis.SoundMixin = (Base) => class SoundMixin extends Base {
    #audioContext = null;
    #sounds = new Map();
    #startTime = 0.0;
    #musicPlayer = null;
    #musicGainNode = null;
    #musicBuffer = null;
    SetupImportObject() {
        super.SetupImportObject();
        const { env } = this.WasmImportObject;
        Object.assign(env, {
            JsRequestSound: this.#RequestSound.bind(this),
            JsInitAudio: this.#InitAudio.bind(this),
            JsPlaySound: this.#PlaySound.bind(this),
            JsStartMusicPlayer: this.#StartMusicPlayer.bind(this),
            JsSetMusicBuffer: this.#SetMusicBuffer.bind(this),
            JsUnsetMusicBuffer: this.#UnsetMusicBuffer.bind(this),
            JsCreateMusicPlayer: this.#CreateMusicPlayer.bind(this),
            JsConnectMusicPlayerGraph: this.#ConnectMusicPlayerGraph.bind(this),
            JsDestroyMusicPlayer: this.#DestroyMusicPlayer.bind(this),
            JsSetMusicVolume: this.#SetMusicVolume.bind(this),
            JsGetMusicTime: this.#GetMusicTime.bind(this),
            JsGetMusicDuration: this.#GetMusicDuration.bind(this)
        });
    }
    get WasmInstanceExports() {
        return this.WasmInstance.exports;
    }
    #InitAudio() {
        this.#audioContext = new AudioContext();
    }
    async #RequestSound(sndHandle) {
        const url = this.ReadInteropBuffer();
        if (debugRequests)
            console.log("RequestSound", sndHandle, url);
        try {
            if (this.#audioContext == null)
                throw new Error("LoadSound: audioContext is not initialised!");
            const response = await fetch(url);
            const arrayBuffer = await response.arrayBuffer();
            const audioBuffer = await this.#audioContext.decodeAudioData(arrayBuffer);
            this.#sounds.set(sndHandle, audioBuffer);
            this.WasmInstanceExports.PascalSoundLoaded(sndHandle);
        }
        catch (error) {
            console.error("RequestSound failed", error);
            const lines = [
                "Failed to load sound",
                "",
                "Path: " + url
            ];
            if (error instanceof Error)
                lines.push("Reason: " + error.message);
            else
                lines.push("Reason: " + error);
            this.PanicHaltDisplay(lines.join("\n"));
            this.WasmInstanceExports.PascalSoundFailed(sndHandle);
        }
    }
    #PlaySound(sndHandle) {
        if (this.#audioContext == null)
            throw new Error("PlaySound: audioContext is not initialised!");
        const buffer = this.#sounds.get(sndHandle);
        if (buffer == null) {
            console.warn("PlaySound: Sound " + sndHandle + " is not loaded!");
            return;
        }
        const volume = this.WasmInstanceExports.GetSoundVolume(sndHandle);
        const source = this.#audioContext.createBufferSource();
        const gainNode = this.#audioContext.createGain();
        source.buffer = buffer;
        gainNode.gain.value = volume;
        source.connect(gainNode);
        gainNode.connect(this.#audioContext.destination);
        source.start(0);
    }
    #SetMusicBuffer(sndHandle) {
        if (!this.#sounds.has(sndHandle))
            throw new Error("Missing sndHandle " + sndHandle);
        this.#musicBuffer = this.#sounds.get(sndHandle);
    }
    #UnsetMusicBuffer() {
        this.#musicBuffer = null;
    }
    #CreateMusicPlayer() {
        if (this.#audioContext == null)
            throw new Error("ResetMusicPlayerNode: audioContext is not initialised!");
        this.#musicPlayer = this.#audioContext.createBufferSource();
        this.#musicGainNode = this.#audioContext.createGain();
    }
    #ConnectMusicPlayerGraph() {
        if (this.#audioContext == null)
            throw new Error("ConnectMusicPlayerGraph: audioContext is unset");
        if (this.#musicPlayer == null)
            throw new Error("ConnectMusicPlayerGraph: musicPlayer is unset");
        if (this.#musicGainNode == null)
            throw new Error("ConnectMusicPlayerGraph: musicGainNode is unset");
        this.#musicPlayer.buffer = this.#musicBuffer;
        this.#musicGainNode.gain.value = this.WasmInstanceExports.GetSoundVolume(this.WasmInstanceExports.GetCurrentMusicHandle());
        this.#musicPlayer.connect(this.#musicGainNode);
        this.#musicGainNode.connect(this.#audioContext.destination);
    }
    #DestroyMusicPlayer() {
        if (this.#musicPlayer != null) {
            try {
                this.#musicPlayer.stop();
            }
            catch { }
            this.#musicPlayer.disconnect();
            this.#musicPlayer = null;
        }
        if (this.#musicGainNode != null) {
            this.#musicGainNode.disconnect();
            this.#musicGainNode = null;
        }
    }
    #StartMusicPlayer() {
        if (this.#audioContext == null)
            throw new Error("ResumeMusic: audioContext is not initialised!");
        if (this.#musicPlayer == null)
            throw new Error("ResumeMusic: musicPlayer is not initialised!");
        const musicPauseTime = this.WasmInstanceExports.GetMusicPauseTime();
        this.#musicPlayer.start(0, musicPauseTime);
        this.#startTime = this.#audioContext.currentTime - musicPauseTime;
    }
    #SetMusicVolume(volume) {
        if (this.#musicGainNode != null)
            this.#musicGainNode.gain.value = volume;
    }
    #GetMusicTime() {
        if (this.#audioContext == null)
            throw new Error("GetMusicTime: audioContext is not initialised!");
        if (this.#musicBuffer == null)
            return 0.0;
        if (!this.WasmInstanceExports.GetMusicPlaying())
            return this.WasmInstanceExports.GetMusicPauseTime();
        const elapsed = this.#audioContext.currentTime - this.#startTime;
        const duration = this.#GetMusicDuration();
        return elapsed % duration;
    }
    #GetMusicDuration() {
        if (this.#musicBuffer == null)
            return 0.0;
        return this.#musicBuffer.duration;
    }
};
