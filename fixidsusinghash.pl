#!/usr/bin/perl
# $1 hash file with ids
# $2 File that needs id's zapped into it. 

open (A,$ARGV[0]) or die "could not open $!"  ; 
open (B,$ARGV[1]) or die "could not open $!"  ; 

while (<A>) { 
	chomp $_ ;
        @F = split (",",$_) ;
        $key = $F[1] ;
        $value = $F[0] ;
        $h{$key} = $value ;
	#print  STDERR "$key,$value\n" ; 
} 
while (<B>) {
	chomp $_ ;
	@F = split (",",$_) ;
	$oldid = $F[4] ; 
	chomp $oldid ; 
	$newid = $h{$oldid}  ; 
	print STDERR "$oldid,$newid\n"; 
	$F[4]= $newid ;
	if ( $newid !~ /^$/ ) { 
		print join (",",@F),"\n"  ; 
	} 
} 

#foreach (sort keys %h) {
#        print "$_,$h{$_} \n" ;
#} 

