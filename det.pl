#!/usr/bin/perl   
# show a detail line of a csv file vertically - match up with header in that should be in the first row.
$filename	= $ARGV[0];
$linenumber  = $ARGV[1];
if ( $linenumber lt 1  ) { print "enter line number in arg2! ";exit }
open F,"<$filename" or die $!;
 
$hdr=<F>;            	# read the first line of file
chomp $hdr;          	# remove crlf
@h = split(",",$hdr);	# put header into an array
$i=0;
$j=0;
while (<F>) {
  chomp $_;
  $i+=1;   # line counter
  $j=1;	# field counter
  if ($i == $linenumber-1) {
 	@ll = split(",",$_);
 	foreach (@h) {
    	print "field $j $h[$j-1] -->" . $ll[$j-1] . "<--\n" ; # line count, fieldname , array value
    	$j+=1;
 	}
 	last;   # jump out of loop - no need to iterate through remainder of file
  }
}
print "\n";
print $#h+1 . " elements in header row\n";
print $#ll+1 . " elements in row $linenumber\n";
