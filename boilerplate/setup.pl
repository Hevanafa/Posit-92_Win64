use strict;
use warnings;
use 5.032001;

use Cwd qw(cwd abs_path);

use File::Copy qw(copy);
use File::Find qw(find);
use File::Path qw(make_path);

say cwd;

my $src = abs_path("../DEMOS/hello_simple");
my $dest = abs_path(".");

# Copy from the demo folder

# Quirk: `find` calls `chdir` into each directory as it "walks",
# since it's essentially a "walker", so using abs_path is necessary

find(sub {
  return unless -f;

  my $filename = $_;
  my $src_file = $File::Find::name;
  # my $dirname = $File::Find::dir;

  (my $relative = $src_file) =~ s/^\Q$src\E//;

  say "Relative path: ".$relative;

  my @chunks = (split /\//, "$dest$relative");
  @chunks = @chunks[0..$#chunks - 1];
  my $target_dir = (join "/", @chunks);

  say "Target dir  : ".$target_dir;

  make_path($target_dir);

  if (-e $src_file) {
    say "File exists!"
  } else {
    say "File doesn't exist!"
  }

  copy($src_file, $target_dir."/".$filename)
    or warn "Failed to copy $File::Find::name $!";

  say "";
}, $src);

print "Setup complete!"
