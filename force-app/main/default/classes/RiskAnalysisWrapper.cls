//wrapper for Risk Analysis table
public with sharing class RiskAnalysisWrapper {
    public String TimePeriod{get;set;}
    public String STATE{get;set;}
    public Decimal Frequency{get;set;}
    public Decimal TotalIncurred{get;set;}
    public Decimal PEBilled{get;set;}
    
    
    // constructor
    public RiskAnalysisWrapper()
    {
        //get total here added to total margin*/
        //add init
        
    }   
    

    
}