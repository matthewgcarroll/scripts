#!/usr/bin/perl -w
# Payment Application Report

while (<>) {
    #Detail
    #                             BATCH NUM     PV RECOVERY   FIN RECOVERY   RES RECOVERY   IDC RECOVERY  RESERVE RECOV       INTEREST
    #CONTRACT NUMBER              DATE RCVD      TOTAL RCVD      FUTURE 31      FUTURE 61      FUTURE 91     CUR RENTAL      TOT RENTS
    #CUSTOMER NAME                TRANS                          PAST 1-30     PAST 31-60     PAST 61-90        PAST 91      LATE CHRG
    #PAYMENT MEMO                 PYMT TYPE       STATE TAX     COUNTY TAX       CITY TAX    TRANSIT TAX                  PRIN OVERPAY
    #                                                                           MISC NAME                      MISC AMT       MISC TAX

print;
    if (/^[0-9][0-9][0-9]-[0-9][0-9][0-9][0-9][0-9][0-9][0-9]-[0-9][0-9][0-9]/) {
        ($contract,$date_rcvd,$total_rcvd,$fut_31,$fut_61,$fut_91,$cur_rental,$tot_rents) = split(" ");
        print $contract,$date_rcvd,$total_rcvd,$fut_31,$fut_61,$fut_91,$cur_rental,$tot_rents,"\n";
        #print "$lease_type~$cust_name~$contract~$gross_contract~$curr_rent_rcvb~";
        #print "$unearn_fin~$pymts_rcvd~$rem_rent_rcvb~$unearn_resid~";
        #print "$bal_remain~$residual~$unpaid_int~$net_invest\n";
    }
}
