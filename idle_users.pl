#!/usr/bin/perl
# 09/13/2000 Ian  Show pty's with no activity in the last 30 minutes - good to make available for shaming

use File::stat;
use Getopt::Std;

getopt("c:");
if ($opt_c) {
   $cutoff = $opt_c;
} else {
   $cutoff = 60;
}

open (LISTUSER, "listuser|") || die "Cannot open listuser command: $!\n";

while (<LISTUSER>) {
   ($x, $pid, $x, $user, $x, $pty, $x) = split(" ");
   if ($pty =~ /pts/) {
      $inode = stat("/dev/$pty");
      $mtime = $inode->mtime;
      $idle = int((time() - $mtime) / 60);
      if ($idle > $cutoff) {write;}
   }
}

format =
@<<<<<<<<< @######### logged on to /dev/@<<<<<< has been idle for @#### minutes
$user, $pid, $pty, $idle
.
