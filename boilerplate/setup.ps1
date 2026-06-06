# Setup Boilerplate
# By Hevanafa
# Part of Posit-92 game engine
# Modified from the Wasm version

# This script should be executed before copying as a new demo

$source = ".."

if (!(test-path -path "shared" -pathType container)) {
  mkdir "shared"
}

if (!(test-path -path "UNITS" -pathType container)) {
  mkdir "UNITS"
}

copy-item "$source\DLL\*.dll" ".\"
copy-item "$source\shared\*.pas" ".\shared\"
copy-item "$source\UNITS\*.pas" ".\UNITS\"

$scripts = @("build_run", "clean", "make", "make_res", "run")
foreach ($script in $scripts) {
  copy-item "$source\scripts\$script.ps1" ".\"
}

copy-item "$source\posit92.pas" ".\"

copy-item "$source\game.rc" ".\"
copy-item "$source\posit-92.ico" ".\"
copy-item "$source\game.manifest" ".\"

write-host "Setup complete! Run .\build_run.ps1 to compile and test" -ForegroundColor green
