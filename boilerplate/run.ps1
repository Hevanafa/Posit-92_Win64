$outputFile = ".\game.exe"

if (test-path -path $outputFile -pathType leaf) {
  & (.\game.exe)
} else {
  write-host "Couldn't find $outputFile"
}