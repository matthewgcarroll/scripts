#!/usr/bin/perl
# $1 hash file with ids
# $2 File that needs id's zapped into it. 

open (A,$ARGV[0]) or die "could not open $!"  ; 
open (B,$ARGV[1]) or die "could not open $!"  ; 

while (<A>) { 
	chomp $_ ;
        @F = split (",",$_) ;
        $key = $F[4] ;
        $h{$key} = 1  ;
} 
while (<B>) {
	chomp $_ ;
	@F = split (",",$_) ;
	$id_b = $F[4] ; 
	if ( defined ($h{$id_b} ) )   { 
		print join (",",@F),"\n"  ; 
	} 
} 

#foreach (sort keys %h) {
#        print "$_,$h{$_} \n" ;
#} 

