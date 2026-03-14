import Bun from "bun";
import { existsSync } from "node:fs";
import path from "node:path";
import { stderr, stdout } from "node:process";
import { styleText } from "node:util";

const compilerPath = "E:\\fpc-wasm\\fpc\\bin\\x86_64-win64\\fpc.exe";
const primaryUnit = ".\\game.pas";
const resfile = "game.res";
const outputFile = "game.exe";

const scriptDir = import.meta.dir;

if (!existsSync(path.join(scriptDir, resfile))) {
  // TODO: Write make_res.ts
  // Bun.spawnSync(
  //   ["bun", "run", "make_res.ts"],
  //   { cwd: scriptDir, stdio: ["inherit", "inherit", "inherit"] }
  // )
}

const unitPaths = [
  path.join("shared", "units"),
  path.join("shared", "sdl2"),
  "shared"
];

const result = Bun.spawnSync(
  [compilerPath, "-Twin64", ...unitPaths.map(path => "-Fu" + path), `-o${outputFile}`, primaryUnit],
  { cwd: scriptDir, stdout: "pipe", stderr: "pipe" }
);

// TODO: Handle stdout and stderr

console.log(styleText("cyan", "(STDOUT)"));
console.log(stdout == "" ? styleText("gray", "(No data)") : stdout);

console.log(styleText("red", "(STDERR)"));
console.log(stderr == "" ? styleText("gray", "(No data)") : stdout);

const exitCode = result.exitCode ?? 1;

if (exitCode != 0) {
  console.log(styleText("red", `Compilation failed with exit code ${exitCode}`));
  process.exit(exitCode)
}
