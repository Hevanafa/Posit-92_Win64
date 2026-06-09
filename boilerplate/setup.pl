# Boilerplate setup script
# Part of Posit-92 game engine

use strict;
use warnings;
use 5.032001;

use Cwd qw(cwd abs_path);

use File::Copy qw(copy);
use File::Find qw(find);
use File::Path qw(make_path);

# Print current working directory
# say cwd;

my $src = abs_path("../DEMOS/hello_simple");
my $dll_path = abs_path("../DLL/x64");
my $dest = abs_path(".");

sub copy_demo {
  # Quirk: `find` calls `chdir` into each directory as it "walks",
  # since it's essentially a "walker", so using abs_path is necessary

  find(sub {
    return unless -f;

    my $filename = $_;
    my $src_file = $File::Find::name;
    # my $dirname = $File::Find::dir;

    (my $relative = $src_file) =~ s/^\Q$src\E//;

    # say "Relative path: ".$relative;

    my @chunks = (split /\//, "$dest$relative");
    @chunks = @chunks[0..$#chunks - 1];
    my $target_dir = (join "/", @chunks);

    # say "Target dir  : ".$target_dir;

    make_path($target_dir);

    copy($src_file, $target_dir."/".$filename)
      or warn "Failed to copy $File::Find::name $!";

    # say "";
  }, $src);
}

# Entry point

copy_demo;

for my $f (glob($dll_path."/*.dll")) {
  # say "$f --> $dest/$f";
  copy($f, $dest) or warn "Failed: $!"
}

print "Setup complete!"
