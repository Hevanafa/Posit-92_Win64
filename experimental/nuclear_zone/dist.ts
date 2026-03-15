import { copyFileSync, existsSync, mkdirSync } from "node:fs";
import path from "node:path";
import { styleText } from "node:util";

const scriptDir = import.meta.dir;
const distDir = path.join(scriptDir, "dist");

const DLLs = ["SDL2.dll", "SDL_image.dll", "SDL_mixer.dll"];

if (!existsSync(distDir))
  mkdirSync(distDir);

for (const dll of DLLs) {
  const src = path.join(scriptDir, dll);

  if (!existsSync(src)) {
    console.log(styleText("magenta", "Missing " + dll + ", skipping..."));
    continue
  }

  copyFileSync(src, path.join(distDir, dll));
  console.log(styleText("cyan", `Copied ${dll}`))
}

// TODO: Handle assets copying
