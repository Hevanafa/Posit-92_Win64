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

# copy_demo;

# for my $f (glob($dll_path."/*.dll")) {
#   # say "$f --> $dest/$f";
#   copy($f, $dest) or warn "Failed: $!"
# }

# Copy unit files

# mkdir "engine" if !(-d "engine");

# copy(
#   abs_path("../experimental/engine/posit92.pas"),
#   abs_path("engine"));


# Handle .lpi file

my $project_file = "project.lpi";
my $fh;

say "Processing $project_file";

open($fh, "<:", $project_file)
  or warn "Couldn't open $project_file!";

my @lines = <$fh>;
close $fh;

chomp(@lines);

for (0..$#lines) {
  my $line = $lines[$_];

  next if $line !~ /otherunitfiles/i;

  say "-- Before --";
  my ($dirs) = $line =~ /"(.*)"/;
  say $dirs;

  my @dirs = $dirs =~ /[^;]+/g;

  # Remove the "..\..\experimental\" prefix
  @dirs = map {
    $_ =~ s/^\.\.\\\.\.\\experimental\\//r;
  } @dirs;

  say "-- After replacement --";

  my $replacement = join ";", @dirs;
  say $replacement;

  $line =~ s/"(.*)"/"$replacement"/;
  say $line;

  $lines[$_] = $line;

  say ""
}

open($fh, ">", $project_file);
say $fh $_ for @lines;

print "Setup complete!"
