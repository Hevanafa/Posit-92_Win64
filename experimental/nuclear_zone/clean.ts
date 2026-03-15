import Bun from "bun";

import { readdirSync, rmSync } from "node:fs";
import path from "node:path";
import { styleText } from "node:util";

const TargetExtensions = [".a", ".o", ".ppu"];

function collectFiles(dir: string): Array<string> {
  const result: Array<string> = [];

  for (const entry of readdirSync(dir, { withFileTypes: true })) {
    const fullpath = path.join(dir, entry.name);

    if (entry.isDirectory())
      result.push(...collectFiles(fullpath))
    else if (TargetExtensions.includes(path.extname(entry.name)))
      result.push(fullpath);
  }

  return result
}

const files = collectFiles(import.meta.dir);

if (files.length == 0)
  console.log(styleText("white", "No files needed to be cleaned"))
else {
  console.log(styleText("yellow", `Found ${ files.length } to delete`));

  for (const f of files) {
    console.log("  " + f);
    rmSync(f)
  }

  console.log(styleText("cyan", `Deleted ${files.length} file(s)`))
}
