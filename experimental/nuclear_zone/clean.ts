import Bun from "bun";
import { readdirSync } from "node:fs";
import path from "node:path";

const TargetExtensions = [".a", ".o", ".ppu"];

function collectFiles(dir): Array<string> {
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
  console.log("No files needed to be cleaned");
// TODO: Handle deletion
