/*******************************************************************
*
* Wrapper class for the Mrgin Analysis $ table
* Encapsulates a MarginAnalysis into a ViewModel of Margin Analysis view table
*******************************************************************/
public with sharing class MarginAnalysisWrapper {
    public String STATE {get;set;}
    public String WCCODE {get;set;}
    
    public Decimal PreContractY2MARGIN{get;set;}
    public Decimal PreContractY1MARGIN{get;set;}
    public Decimal CurrentContractYTDMARGIN{get;set;}
    public Decimal CurrentContractYPrjMARGIN{get;set;}
    public Decimal ContractLTDMARGIN{get;set;}
    
    
    
    // constructor
    public MarginAnalysisWrapper(MarginAnalysisSummary.MARGINSUMMARYDATA inPY2MarginAnalysis,  Map<String, Decimal> TotalGrossMargin )
    {
        //make a line for marginAnalysis table initial with YTD data first
        //string code = (string)inMarginAnalysis.get('State_Code__c');
        //System.debug('Renewal Link Statecode: ' + code);
        STATE = inPY2MarginAnalysis.STATE;
        WCCODE = inPY2MarginAnalysis.WCCODE;
        if (inPY2MarginAnalysis.MARGIN == null)
            CurrentContractYTDMARGIN = 0;
        else
        {
            CurrentContractYTDMARGIN = inPY2MarginAnalysis.MARGIN;
            Decimal Total = TotalGrossMargin.get('YTD');
            if (null==Total)
            {
                Total=0;
            }
            System.debug('PY2 CurrentContractYTDMARGIN' + CurrentContractYTDMARGIN);
            Total += CurrentContractYTDMARGIN;
            TotalGrossMargin.put('YTD', Total); 
            System.debug('YTD Total' + Total);
        }
        
        PreContractY1MARGIN = 0;
        PreContractY2MARGIN  = 0;
        CurrentContractYPrjMARGIN = 0;
        ContractLTDMARGIN =0;
        
        System.debug('**init one line of marginAnalysis ' + STATE +' '+WCCODE+' '+PreContractY2MARGIN +' '+ PreContractY1MARGIN +' '+ CurrentContractYTDMARGIN +' '+CurrentContractYPrjMARGIN);
        //get total here added to total margin
        
    }   
    
    public MarginAnalysisWrapper(String STATE, String WCCODE, String ColumnType, Decimal Margin) {    
        STATE = STATE;
        WCCODE = WCCODE;
        if( ColumnType == 'PY1')
            PreContractY1MARGIN = Margin;
        if( ColumnType == 'PY2')
            PreContractY2MARGIN  = Margin;
        if( ColumnType == 'LTD')
            ContractLTDMARGIN  = Margin;
        System.debug('**extra new line of marginAnalysis ' + STATE +' ' + WCCODE + ' ' + Margin + ColumnType );
        //get total here added to total margin
    }
    
}