#!/usr/bin/perl
# Given a file with a list of names, present the list to the user on stderr
# optionally with filtering, and return the selected name on stdout
# Example: file=`filepicker /path/to/file regex` ; echo $file

# All output goes to the error channel, except for final return
select STDERR;
$clear=`clear`;

# If no fname provided, open will fail.  If no filter, all names shown
$fname = @ARGV[0];
$filter = @ARGV[1];

# Slurp the file into an array
open(F, $fname) or die "OPENING $fname: $!\n";
@names = <F>;
close(F);

# Filter first - only the ones we want
@names = grep(/$filter/i, @names);
$max = scalar(@names);
if ($max == 0) {
  die "No matches found\n";
}

# Loop until the user selects one or quits
while (1)
{
  print $clear;
  $ctr = 1;
  foreach $name (@names) {
    print $ctr++,") ",$name;
  }
  print "\nChoose a number, 1 to $max: ";
  my $num = <STDIN>;
  chomp $num;
  if ($num eq "/" || length($num) == 0) {
    exit 1;
  }
  if ($num !~ /[^0-9]/ && $num >= 1 && $num <= $max) {
    select STDOUT;
    print @names[$num-1];
    exit 0;
  } else {
    print "Please choose a number from 1..$max! [ENTER]:";
    $dummy=<STDIN>;
  }
}
