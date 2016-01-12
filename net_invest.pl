#!/usr/bin/perl
# Net Investment Report

print "lease_type~cust_name~contract~gross_contract~curr_rent_rcvb~unearn_fin~pymts_rcvd~rem_rent_rcvb~unearn_resid~bal_remain~residual~unpaid_int~net_invest\n";

while (<>) {
    # Header line
    #NET.INVEST.RPT     CONDITIONAL SALES         PAGE     1
    if (/^NET.INVEST.RPT/) {
        # Skip 57 chars, grab next 30, then trim them...
        (undef, $lease_type) = unpack("A57 A30",$_);
        $lease_type =~ s/^\s+//;
    }

    #Detail
    #CUSTOMER NAME     CURR INT RCVB
    #LEASE NUMBER      GROSS CONTRACT   CURR RENT RCVB    UNEARN FIN      END DEPOSIT    SEC DEPOSIT
    #                  PAYMENTS RCVD    REM RENT RCVB     UNEARN RESID    PROV LOSS      NET RESERVE      LEASE PYMTS
    #CONTRACT STAT     BAL REMAINING    RESIDUAL          UNPAID INT      NET INV        UNEARNED IDC     UNEARN INC    TOTAL

    if (/^([\@A-Z].................)\s+([0-9]+.[0-9][0-9])/) {
        next if /TOTALS/;
        $cust_name = $1;
        $cust_name =~ s/\s+$//;
        $l=<>;
        $l =~ s/,//go;
        ($contract, $gross_contract, $curr_rent_rcvb, $unearn_fin, undef) = split(" ",$l);
        $l=<>;
        $l =~ s/,//go;
        ($pymts_rcvd, $rem_rent_rcvb, $unearn_resid, undef) = split(" ",$l);
        $l=<>;
        $l =~ s/,//go;
        ($bal_remain, $residual, $unpaid_int, $net_invest, undef) = split(" ",$l);

        print "$lease_type~$cust_name~$contract~$gross_contract~$curr_rent_rcvb~";
        print "$unearn_fin~$pymts_rcvd~$rem_rent_rcvb~$unearn_resid~";
        print "$bal_remain~$residual~$unpaid_int~$net_invest\n";
    }
}
