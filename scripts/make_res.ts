import { existsSync, rmSync } from "node:fs";
import path from "node:path";
import { styleText } from "node:util";

const resname = "game.res";
const rcname = "game.rc";
const windresPath = "E:\\fpc-wasm\\fpc\\bin\\x86_64-win64\\windres.exe";

const scriptDir = import.meta.dir;

if (existsSync(path.join(scriptDir, resname)))
  rmSync(path.join(scriptDir, resname));

if (!existsSync(path.join(scriptDir, rcname))) {
  console.log(styleText("magenta", `Missing ${rcname}!`));
  process.exit(1)
}

Bun.spawnSync(
  [windresPath, "--preprocessor=type", "-O", "coff", `--input=${rcname}`, `--output=${resname}`],
  { cwd: scriptDir, stdio: ["inherit", "inherit", "inherit"]}
);
