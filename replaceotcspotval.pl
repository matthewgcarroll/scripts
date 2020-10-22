#!/usr/bin/perl
# goal is to replace field 78 
# OTC_CVA_20130930.csv has 
# field 5 IDENTIFIER -->LN20130930030006813102900000001<--
# field 21 CurrencyUNIT -->ILS<--
# field 64 SpotPriceVAL -->197213.85<--
# field 78 UserDefined6NAME -->"100158TA<--
# usage: ./replaceotcspotval.pl fx2_20140630.csv f2.2014q2.comb.csv > otc_file.csv
# use the file from above as input into the basel run on prod.
# $1 FX FILE
# $2 MARKET FILE

#$fx    ="/arm_sharefs/home/meirm/matt/fx1_20140331.csv" ; 
#$market="/arm_sharefs/home/meirm/matt/f1.comb.out.txt" ; 
#$market="/arm_sharefs/home/meirm/matt/f0.2014Q1" ; 
#$xref  ="/arm_sharefs/home/meirm/matt/Basel2_IDs_MR_IDs.csv" ; 
#$bsl   ="/arm_sharefs/home/meirm/OTC_20130930.csv"  ; 

$xref  ="/arm_sharefs/home/meirm/matt/DecBOIScen/B2ID_MRID_20131231.csv" ; 
$bsl   ="/arm_sharefs/home/meirm/matt/DecBOIScen/OTC_20131231NEW.csv" ; 

open (X,$xref) or die "could not open $!"  ; 
open (M,$ARGV[1]) or die "could not open $!"  ; 
open (FX,$ARGV[0]) or die "could not open $!"  ; 
open (BSL,$bsl) or die "could not open $!"  ; 

while (<M>) { 
	chomp $_ ;
        @F = split (",",$_) ;
        $key = $F[0] ;
        $value = $F[1] ;
        $m{$key} = $value ;
} 
	
while (<X>) {
# MZ20130930010006742902900000000000000000001,SM5459587 
	chomp $_ ;
	@F = split (",",$_) ;
	$key = $F[0] ; 
	$value = $F[1] ; 
	$h{$key} = $value ; 
} 
while (<FX>) {  # build a hash of fx rates
# 0       1   2          3
# EXCHANGE,ARS,2014-03-31,0.624567468389506
	chomp $_ ;
        @F = split (",",$_) ;
        $key = $F[1] ;   # CURRENCY
        $value = $F[3] ; # RATE 	
        $fx{$key} = $value 
}

#foreach (sort keys %h) {
#        print "$_,$h{$_} \n" ;
#} 

$hdr="##BAS,DM OTC DerivativesSPEC,OBJECT,TYPE,IDENTIFIER,AccountingTransitNB,AlphaVAL,ApprovedCalculationMethodNAME,BIS1AssetTYPE,BIS2AdvCRMLGDVAL,BIS2AdvCRMPDVAL,BIS2AdvLGDGradENUM,BIS2AdvLGDVAL,BIS2AdvLgdCrmGENUM,BIS2AssetTYPE,BIS2FndLGDGradENUM,BIS2MatAdjFLAG,BISCredRskCptlFLAG,CollAdjModelFLAG,ContractSizeVAL,CurrencyUNIT,DDEligCheckENUM,DMAssetTypeNAME,DefaultExpFLAG,DelAgnstPaymntFLAG,DerivativeTYPE,DfltProtectionENUM,EffectiveEPEVAL,ExposureTYPE,FailedTradeFLAG,GLAccountNAME,GrsNegReplCostVAL,GrsPosReplCostVAL,IntEADMethodENUM,InterimFLAG,IssueDATE,IssuerXREF,LGDLkpUsrDefNAME,LoadSetNB,LongSettlemtFLAG,MastrAgrXREF,MaturityDATE,NetPosReplCostVAL,NotionalVAL,ParentFacilityIdNAME,ParentFacilitySrcNAME,PortfolioXREF,PremiumTypeENUM,ProdTypeCodeNAME,ProductSubTypeNAME,ProductTypeENUM,ProfitCentreXREF,QualifyingFLAG,RefAssetProdTYPE,RegulatoryProdTYPE,ReportingTransitXREF,ResultWholeSaleFLAG,RiskOnXREF,SettleAmountVAL,SettlementDATE,SimplRECollTrmtFLAG,SourceSystemCodeNAME,SpecificProvVAL,SpotPriceVAL,TradeDATE,TradingBookFLAG,TransactionTYPE,UndrBIS2AdvLGDGradENUM,UndrBIS2AdvLGDVAL,UndrBIS2FndLGDGradENUM,UnpaidPremiumVAL,UserDefined10NAME,UserDefined1NAME,UserDefined2NAME,UserDefined3NAME,UserDefined4NAME,UserDefined5NAME,UserDefined6NAME,UserDefined7NAME,UserDefined8NAME,UserDefined9NAME,UserDefinedAmount10VAL,UserDefinedAmount1VAL,UserDefinedAmount2VAL,UserDefinedAmount3VAL,UserDefinedAmount4VAL,UserDefinedAmount5VAL,UserDefinedAmount6VAL,UserDefinedAmount7VAL,UserDefinedAmount8VAL,UserDefinedAmount9VAL,WholesaleFLAG,DomesticVAL,FundingUNIT" ; 

print $hdr , "\n" ; 

while (<BSL>) {   # loop thru basel2 file
        chomp $_ ;
        @F = split ("," , $_ ) ;
        $baselid = @F[4] ;
        $curr    = @F[20] ;
        $spot    = @F[63] ;
	if ($curr =~ "RUB") { $curr="RUR" } 
	if ($curr =~ "RON") { $curr="ROL" } 
	
	if (defined ($h{$baselid} )) { 
		##print "MATCH $baselid \n" ; 
		$newid = $h{$baselid};  # not $F[77] ;
		$newvalue = $m{$newid} ; 
		$fxrate = $fx{$curr} ; 
		if ($curr =~ /ILS/) { $fxrate = 1 } 
		$newvalue = $newvalue / $fxrate ; 
		$F[63] = $newvalue ;  # SPOT PRICE
		if ( abs ( $spot - $newvalue) > .5 )  {	
			print STDERR "$baselid,$newid,$spot,$newvalue,$F[20],$curr,$fxrate\n";
		}
        	print join (",",@F) , "\n"  ; 
	} 
}
