/*******************************************************************
*
* Wrapper class for the XmodHistory  $ table in pricing use
*
*******************************************************************/
public with sharing class XModPricingWrapper {
/*
    public Integer Key {get; set;}
    public PricingScenXmod__c CurrentPricingXmod {get; set;}
    public String STATE {get;set;}
    public Decimal PreContractY2Xmode{get;set;}
    public Decimal PreContractY1Xmode{get;set;}
    public Decimal CurrentContractYTDXmode{get;set;}
    //public Decimal RenewalPublishedXmode{get;set;}
    //public Decimal RenewalActualXmode{get;set;}
    // constructor
    public XModPricingWrapper(Integer inKey, PricingScenXmod__c inCurrentPricing, List<XmodHistory__c> xhistory)
    {
         this.Key = inKey;
         this.CurrentPricingXmod = inCurrentPricing;
         this.state = inCurrentPricing.State_Code__c;
        
         //use state code to find the history on this company xmod
           if (xhistory.size() > = 1 )  
           {
                this.CurrentContractYTDXmode = xhistory[0].Xmod__c;
           }
           if (xhistory.size() > = 2 )  
           {
                this.PreContractY1Xmode = xhistory[1].Xmod__c;
           }
           if (xhistory.size() == 3 )  
           {
                this.PreContractY2Xmode = xhistory[2].Xmod__c;
           }
        
		 //this.RenewalPublishedXmode = inCurrentPricing.Published_Xmod__c;
         //this.RenewalActualXmode = inCurrentPricing.Xmod__c;      
    }   
*/       
}