import { copyFileSync, cpSync, existsSync, mkdirSync } from "node:fs";
import path from "node:path";
import { styleText } from "node:util";

const scriptDir = import.meta.dir;
const distDir = path.join(scriptDir, "dist");

const MainExe = "game.exe";
const DLLs = ["SDL2.dll", "SDL2_image.dll", "SDL2_mixer.dll"];
const AssetsDir = "assets";

if (!existsSync(distDir))
  mkdirSync(distDir);

cpSync(MainExe, path.join(distDir, MainExe));
console.log(styleText("cyan", "Copied " + MainExe));

for (const dll of DLLs) {
  const src = path.join(scriptDir, dll);

  if (!existsSync(src)) {
    console.log(styleText("magenta", "Missing " + dll + ", skipping..."));
    continue
  }

  copyFileSync(src, path.join(distDir, dll));
  console.log(styleText("cyan", `Copied ${dll}`))
}

// Handle assets
const assetsSrc = path.join(scriptDir, AssetsDir);

if (!existsSync(assetsSrc)) {
  console.log(styleText("red", `Missing ${AssetsDir}!`));
  process.exit(1)
} else {
  cpSync(assetsSrc, path.join(distDir, AssetsDir), { recursive: true });
  console.log(styleText("cyan", `Copied ${AssetsDir}`))
}
