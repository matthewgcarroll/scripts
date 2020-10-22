#!/usr/bin/perl
while (<>) {
	chomp $_ ; 
	$ll = $_ ; 
	next unless ($ll !~ /Cash/) ; # skip the rows containing Cash
	$ll =~ s/"//g;               # get rid of quotes
	@a = split (",",$ll) ; 
	$id = $a[4] ; 
	$id = ($id =~/(\w+)/g)[0] ; # extract the first word
	if ($ll =~ /-[12],/) {   # find the legs ending in -1 or -2
		$value = $a[-2]; 
		$h{$id} += $value ; 
		if ($ll =~ /-1,/)  { $curr = $a[-1]  }  ;   # get the currency from leg1 
		$g{$id} = $curr ; 
	} else {
		$value = $a[-2] ; 
		$curr = $a[-1] ;
		$g{$id} = $curr ; 
		$h{$id} = $value ;   # synthetics etc
	} 
}

foreach (sort keys %h) {
	print "$_,$h{$_}\n" ;
}
#0         1      23                   4                       5            6 / -1
#2014/03/31,2014Q1,,"100158TA EXOTIC-1",Swap Pre-determined Leg,100066964.77,ILS
#2014/03/31,2014Q1,,"100158TA EXOTIC-2",Swap Fixed Leg,-116389963.95,CPE
#2014/03/31,2014Q1,,"100202TA SWAP IRSWAP-1",Swap Pre-determined Leg,6958955.77,ILS
#2014/03/31,2014Q1,,"100202TA SWAP IRSWAP-2",Swap Fixed Leg,-9055073.46,ILS
#

