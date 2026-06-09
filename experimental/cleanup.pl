# Experimental cleanup script
# This script cleans automatically generated files by Lazarus

# Targeted extensions: .o, .ppu, .bak

use strict;
use warnings;
use 5.032001;

use Cwd qw(abs_path);
use File::Find;
use File::Path qw(remove_tree);

find(sub {
  my $full_path = $File::Find::name;

  if (-d && $_ eq "backup") {
    remove_tree($full_path, { verbose => 1 });
    $File::Find::prune = 1;  # don't chdir into it
    return
  }

  return unless -f;

  unlink or warn "Can't delete $full_path: $!"
    if /\.(o|ppu|bak)$/
}, abs_path("."))
