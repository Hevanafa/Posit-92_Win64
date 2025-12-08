$resname = "game.res"
$rcname = "game.rc"
$iconame = "game.ico"
$windresPath = "E:\fpc-wasm\fpc\bin\x86_64-win64\windres.exe";

if (test-path $resname) {
  remove-item $resname
}

if (!(test-path $rcname)) {
  write-host "Missing $rcname!" -foregroundColor magenta
  exit
}

if (!(test-path $iconame)) {
  write-host "Missing $iconame!" -ForegroundColor magenta
  exit
}

& ($windresPath $rcname -O coff -o $resname)
