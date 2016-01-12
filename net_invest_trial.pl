#!/usr/bin/perl
# Net Investment Trial Balance
print "contract~#bal_remain~#net_invest\n";
while (<>) {
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

        print "$contract~$bal_remain~$net_invest\n";
    }
}
