#!/usr/bin/perl
# Cash Received Trial Report

while (<>) {
  # Header line
  #CASH.RCVD.TRIAL.RPT                                       ACCOUNT: TRINITY                                              PAGE   259
  #
  #                                                                                                   GROSS CONTRACT  CONTRACT BALANCE
  #CONTRACT NUMBER                          TOTAL RECVD   RENTAL RECVD  SALES/USE TAX   LATE CHARGES  PYMTS FROM BEG  CURR RENT RCVB
  #CUSTOMER NAME         TYPE DATE RECVD    INTEREST     MISCELLANEOUS  MISC TAX        CUR INT RCVB  PYMTS DISPOSED  REM RENT RCVB
  #---------------       ---- ----------    -----------  -------------  -------------   ------------  --------------  ----------------
  #
  #250-0814527-001       STAN 01/26/04           749.62         713.92          35.70           0.00       34,268.16         20,703.68
  #BSN AND BSN-SANTA FE, BERGSTRA                  0.00           0.00           0.00           0.00       13,564.48              0.00
  #                                                                                             0.00            0.00         20,703.68

  if (m#^\d\d\d-\d\d\d\d\d\d\d-\d\d\d#) {
    $contract = substr($_,0,15);

    $l=<>;
    $cust_name = substr($l,0,21);

    $l=<>;
    $pymts_disp = substr($l,99,20);
    $pymts_disp =~ s/^\s+//;
    $pymts_disp =~ s/\s+$//;

    print "$contract\|$cust_name\|$pymts_disp\n";
  }
}
