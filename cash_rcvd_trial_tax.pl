#!/usr/bin/perl
# Cash Received Trial Tax Report

print "contract~lease_type~date_recvd~total_recvd~interest~rental_recvd~state_tax~county_tax~curr_int_rcvb~contract_bal~";
print "cust_name~transit_tax~interest2~late_charges~misc~city_tax~pymts_from_begin~curr_rent_rcvb~";
print "misc_tax~pymts_disp~rem_rent_rcvb\n";

while (<>) {
    # Header line
    #CASH.RCVD.TRIAL.TAX.RPT           CONDITIONAL SALES        PAGE    1
    if (/^CASH.RCVD.TRIAL.TAX.RPT/) {
        # Skip 57 chars, grab next 30, then trim them...
        (undef, $lease_type) = unpack("A57 A30",$_);
        $lease_type =~ s/^\s+//;
    }

    #CONTRACT NUMBER      DATE                                                               COUNTY TAX  CURR INT RCVB   CONTRACT BALANCE
    #CUSTOMER NAME       RECVD    TOTAL RECVD     INTEREST   RENTAL RECVD      STATE TAX       CITY TAX PYMTS FROM BEG     CURR RENT RCVB
    #                     TYPE    TRANSIT TAX                LATE CHARGES  MISCELLANEOUS       MISC TAX     PYMTS DISP      REM RENT RCVB
    #---------------  --------    -----------     --------   ------------  -------------     ---------- -------------- ------------------
    #
    #502-0000055-110  02/04/03       8,732.13         0.00       8,520.95         211.18           0.00           0.00         144,856.15
    #ELECTRONIC PROCESSIN STAN           0.00         0.00           0.00           0.00           0.00     264,149.45               0.00
    #                                                                                              0.00           0.00         144,856.15

    if (m#^(\d\d\d-\d\d\d\d\d\d\d-\d\d\d)..(........)....(...........).....(........)...(............)..(.............).....(..........).(..............).(..................)#)  {
        $contract = $1;
                $date_recvd = $2;
                $total_recvd = $3;
                $interest = $4;
                $rental_recvd = $5;
                $state_tax = $6;
                $county_tax = $7;
                $curr_int_rcvb = $8;
                $contract_bal = $9;

        $l=<>;
                m/(.........................)....(...........).....(........)...(............)..(.............).....(..........).(..............).(..................)/;
                $cust_name = $1;
                $transit_tax = $2;
                $interest2 = $3;
                $late_charges = $4;
                $misc = $5;
                $city_tax = $6;
                $pymts_from_begin = $7;
                $curr_rent_rcvb = $8;

        $l=<>;
        m/........................................................................................(..........).(..............).(..................)/;
                $misc_tax = $1;
                $pymts_disp = $2;
                $rem_rent_rcvb = $3;

        print "$contract~$lease_type~$date_recvd~$total_recvd~$interest~$rental_recvd~$state_tax~$county_tax~$curr_int_rcvb~$contract_bal~";
                print "$cust_name~$transit_tax~$interest2~$late_charges~$misc~$city_tax~$pymts_from_begin~$curr_rent_rcvb~";
                print "$misc_tax~$pymts_disp~$rem_rent_rcvb\n";
    }
}
