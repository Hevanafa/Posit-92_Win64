# Removes all .o, .ppu, and .res files

$files = Get-ChildItem -include *.o, *.ppu, *.res -file

if ($files.count -eq 0) {
  write-host "No .o, .ppu or *.res files found" -foregroundColor white
} else {
  write-host "Found $($files.count) file(s) to delete" -foregroundColor yellow

  $files | foreach-object { write-host "  $($_.FullName)" }

  # Assuming that no files are locked after compilation
  $files | remove-item
  write-host "Deleted $($files.count) file(s)" -foregroundColor cyan
}

push-location ..\..\experimental
& .\cleanup.ps1
pop-location
