#!/usr/bin/perl
# goal is to replace field 78 
# OTC_CVA_20130930.csv has 
# field 5 IDENTIFIER -->LN20130930030006813102900000001<--
# field 21 CurrencyUNIT -->ILS<--
# field 64 SpotPriceVAL -->197213.85<--
# field 78 UserDefined6NAME -->"100158TA<--

# $1 EAD FILE
# $2 CVA FILE

open (EAD,$ARGV[0]) or die "could not open $!"  ; 
open (CVA,$ARGV[1]) or die "could not open $!"  ; 

while (<EAD>) { 
#20140331,MZ20130930030006842902900000000000000000001,0.0000 
	chomp $_ ;
        @F = split (",",$_) ;
        $key   = $F[1] ;
        $value = $F[2] ;
        $ead{$key} = $value ;
} 
	
#foreach (sort keys %h) {
#        print "$_,$h{$_} \n" ;
#} 

$hdr="##BAS,DM OTC DerivativesSPEC,OBJECT,TYPE,IDENTIFIER,AccountingTransitNB,AlphaVAL,ApprovedCalculationMethodNAME,BIS1AssetTYPE,BIS2AdvCRMLGDVAL,BIS2AdvCRMPDVAL,BIS2AdvLGDGradENUM,BIS2AdvLGDVAL,BIS2AdvLgdCrmGENUM,BIS2AssetTYPE,BIS2FndLGDGradENUM,BIS2MatAdjFLAG,BISCredRskCptlFLAG,CollAdjModelFLAG,ContractSizeVAL,CurrencyUNIT,DDEligCheckENUM,DMAssetTypeNAME,DefaultExpFLAG,DelAgnstPaymntFLAG,DerivativeTYPE,DfltProtectionENUM,EffectiveEPEVAL,ExposureTYPE,FailedTradeFLAG,GLAccountNAME,GrsNegReplCostVAL,GrsPosReplCostVAL,IntEADMethodENUM,InterimFLAG,IssueDATE,IssuerXREF,LGDLkpUsrDefNAME,LoadSetNB,LongSettlemtFLAG,MastrAgrXREF,MaturityDATE,NetPosReplCostVAL,NotionalVAL,ParentFacilityIdNAME,ParentFacilitySrcNAME,PortfolioXREF,PremiumTypeENUM,ProdTypeCodeNAME,ProductSubTypeNAME,ProductTypeENUM,ProfitCentreXREF,QualifyingFLAG,RefAssetProdTYPE,RegulatoryProdTYPE,ReportingTransitXREF,ResultWholeSaleFLAG,RiskOnXREF,SettleAmountVAL,SettlementDATE,SimplRECollTrmtFLAG,SourceSystemCodeNAME,SpecificProvVAL,SpotPriceVAL,TradeDATE,TradingBookFLAG,TransactionTYPE,UndrBIS2AdvLGDGradENUM,UndrBIS2AdvLGDVAL,UndrBIS2FndLGDGradENUM,UnpaidPremiumVAL,UserDefined10NAME,UserDefined1NAME,UserDefined2NAME,UserDefined3NAME,UserDefined4NAME,UserDefined5NAME,UserDefined6NAME,UserDefined7NAME,UserDefined8NAME,UserDefined9NAME,UserDefinedAmount10VAL,UserDefinedAmount1VAL,UserDefinedAmount2VAL,UserDefinedAmount3VAL,UserDefinedAmount4VAL,UserDefinedAmount5VAL,UserDefinedAmount6VAL,UserDefinedAmount7VAL,UserDefinedAmount8VAL,UserDefinedAmount9VAL,WholesaleFLAG,DomesticVAL,FundingUNIT" ; 

print $hdr , "\n" ; 

while (<CVA>) {   # loop thru basel2 file
        chomp $_ ;
        @F = split ("," , $_ ) ;
        $baselid = @F[4] ;
        $spot    = @F[63] ;
	    $newspot = $ead{$baselid} ; 
	
	if (defined ($ead{$baselid} )) { 
		$F[63] = $newspot ;
        	print join (",",@F) , "\n"  ; 
	} 
}
