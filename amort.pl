#!/usr/bin/perl
# Amort Report

#               CONTRACT BALANCE                   PRINCIPAL      CONTRACT       DEFERRED      DEFERRED      MONTH END            NET
#PERIOD   DATE     PLUS RESIDUAL       PAYMENT        REPAID        INCOME         INCOME           IDC        BALANCE        BALANCE
#------   ----  ----------------       -------     ---------      --------       --------      --------      ---------        -------
#                      63,376.76                                                14,197.31          0.00      49,179.45
#   1    04/01         61,321.72      2,055.04      1,408.26        646.78      13,550.53          0.00      47,771.19      47,124.41
#...
#  32    11/03         13,542.04      1,541.28      1,364.91        176.37         515.54          0.00      13,026.50      12,850.13
#  33    12/03         12,000.76      1,541.28      1,383.65        157.63         357.91          0.00      11,642.85      11,485.22

print "contract_num\tcust_name\tperiod\tdate\tcbr\tpayment\t";
print "principal\tincome\tdeferred_income\tdeferred_idc\tme_bal\tnet_bal\n";

while ($l=<>) {
    # Header line
    #CONTRACT NUMBER: 060-0011620-001
    if ($l =~ /^CONTRACT NUMBER: (.*)\n/) {
        $contract_num = $1;
        # Cust name is the line under contact_num
        $cust_name=<>;
        $cust_name =~ s/\s+$//;
    }

    #Detail
    #               CONTRACT BALANCE                   PRINCIPAL      CONTRACT       DEFERRED      DEFERRED      MONTH END            NET
    #PERIOD   DATE     PLUS RESIDUAL       PAYMENT        REPAID        INCOME         INCOME           IDC        BALANCE        BALANCE

    if ($l =~ /\s+\d{1,2}\s+\d{6}/) {
        $l =~ s/,//go;
        ($period, $date, $cbr, $payment, $principal, $income, $deferred_income, $deferred_idc, $me_bal, $net_bal) = split(" ",$l);

        print "$contract_num\t$cust_name\t$period\t$date\t$cbr\t$payment\t";
        print "$principal\t$income\t$deferred_income\t$deferred_idc\t$me_bal\t$net_bal\n";
    }
}
