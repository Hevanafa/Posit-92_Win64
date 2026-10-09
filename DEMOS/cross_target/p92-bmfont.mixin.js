"use strict";
globalThis.BMFontMixin = (Base) => class BMFontMixin extends Base {
    SetupImportObject() {
        super.SetupImportObject();
        const { env } = super.WasmImportObject;
        Object.assign(env, {
            JsRequestBMFont: this.#RequestBMFont.bind(this)
        });
    }
    get WasmInstanceExports() {
        return this.WasmInstance.exports;
    }
    async #RequestBMFont(bmfontHandle) {
        const url = this.ReadInteropBuffer();
        if (debugRequests)
            console.log("ReadInteropBuffer", bmfontHandle, url);
        try {
            const res = await fetch(url);
            if (!res.ok) {
                const lines = [
                    "Failed to load BMFont",
                    "",
                    "Path: " + url,
                    "Reason: HTTP status " + res.status
                ];
                this.PanicHaltDisplay(lines.join("\n"));
                this.WasmInstanceExports.PascalBMFontFailed(bmfontHandle, 1);
                return;
            }
            this.WriteBMFontBuffer(await res.text());
            this.WasmInstanceExports.PascalBMFontLoaded(bmfontHandle);
        }
        catch (error) {
            if (error instanceof Error)
                console.error("RequestBMFont:", error);
            this.WasmInstanceExports.PascalBMFontFailed(bmfontHandle, 1);
        }
    }
    WriteBMFontBuffer(s) {
        const encoder = new TextEncoder();
        const bytes = encoder.encode(s);
        const ptr = this.WasmInstanceExports.GetBMFontBufferPtr();
        const len = bytes.length;
        const capacity = this.WasmInstanceExports.GetBMFontBufferCapacity();
        if (len > capacity)
            this.PanicHaltDisplay(`BMFont buffer overflow: ${len} > ${capacity}`);
        const memview = new Uint8Array(this.WasmInstanceExports.memory.buffer);
        memview.set(bytes, ptr);
        this.WasmInstanceExports.SetBMFontBufferLen(len);
    }
};
