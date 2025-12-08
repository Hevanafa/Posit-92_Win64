# Compile Script for Win64
# Part of Posit-92 framework
# By Hevanafa, 07-12-2025

$compilerPath = "E:\fpc-wasm\fpc\bin\x86_64-win64\fpc.exe"
$primaryUnit = ".\game.pas"
$resfile = "game.res"
$outputFile = "game.exe"

if (!(test-path -path $resfile -pathType leaf)) {
  & ".\make_res.ps1"
}

# Compile targeting Windows x64
# E:\fpc-wasm\fpc\bin\x86_64-win64\fpc.exe -Twin64 -FuUNITS -O2 -ogame.exe .\game.pas

$pinfo = new-object System.Diagnostics.ProcessStartInfo
$pinfo.FileName = $compilerPath
$pinfo.Arguments = "-Twin64", "-FuUNITS", "-Fushared", "-O2", "-dWIN64", "-o$outputFile", $primaryUnit
$pinfo.WorkingDirectory = $PSScriptRoot
$pinfo.RedirectStandardError = $true
$pinfo.RedirectStandardOutput = $true
$pinfo.UseShellExecute = $false

$p = new-object System.Diagnostics.Process
$p.StartInfo = $pinfo
$p.Start() | Out-Null
$p.WaitForExit()

$stdout = $p.StandardOutput.ReadToEnd()
$stderr = $p.StandardError.ReadToEnd()

write-host "(STDOUT)" -foregroundColor cyan
if ($stdout.Trim() -eq "") {
  write-host "(No data)" -foregroundColor gray
} else {
  write-host $stdout
}
write-host "(STDERR)" -foregroundColor red
if ($stderr.Trim() -eq "") {
  write-host "(No data)" -foregroundColor gray
} else {
  write-host $stderr
}

if ($p.ExitCode -ne 0) {
  write-host "Compilation failed with exit code $($p.ExitCode)" -foregroundColor red
  exit $p.ExitCode
}

# if (test-path -path "$outputFile.wasm" -pathType leaf) {
#   remove-item "$outputFile.wasm"
# }

# if (test-path -path "$outputFile" -pathType leaf) {
#   rename-item "$outputFile" "$outputFile.wasm"
# }
