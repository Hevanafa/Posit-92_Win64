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

  my $filename = $_;
  my $full_path = $File::Find::name;
  my $dirname = $File::Find::dir;

  (my $relative = $full_path) =~ s/^\Q$src\E//;

  say "Relative path: ".$relative;

  my @chunks = (split /\//, "$dest$relative");
  @chunks = @chunks[0..$#chunks - 1];
  my $target_dir = (join "/", @chunks);

  say "Target dir  : ".$target_dir;

  # make_path((split /\//, $target)[0..-2]);
  # copy($full_path, $target) or warn "Failed to copy $File::Find::name $!"

  say "";
}, $src);

print "Setup complete!"
