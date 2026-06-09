use strict;
use warnings;
use 5.032001;

use File::Copy qw(copy);
use File::Find qw(find);
use File::Path qw(make_path);

my $src = "../DEMOS/hello_simple";
my $dest = ".";

find(sub {
  return unless -f;

  (my $relative = $File::Find::name) =~ s/^\Q$src\E//;
  say "Relative path: ".$relative;

  my $target = "$dest/$relative";

  make_path((split /\//, $target)[0..-2]);
  copy($File::Find::name, $target) or warn "Failed to copy $File::Find::name $!"
}, $src);

print "Setup complete!"
