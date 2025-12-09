# Setup Boilerplate
# By Hevanafa, 08-12-2025
# Part of Posit-92 framework
# Modified from the Wasm version

# This script should be executed before copying as a new demo

$source = ".."

if (!(test-path -path "shared" -pathType container)) {
  mkdir "shared"
}

if (!(test-path -path "UNITS" -pathType container)) {
  mkdir "UNITS"
}

copy-item "$source\shared\*.pas" ".\shared\"
copy-item "$source\UNITS\*.pas" ".\UNITS\"

$scripts = @("build_run", "cleanup", "compile", "make_res", "run")
foreach ($script in $scripts) {
  copy-item "$source\scripts\$script.ps1" ".\"
}

copy-item "$source\posit92.pas" ".\"
copy-item "$source\posit-92.ico" ".\"
