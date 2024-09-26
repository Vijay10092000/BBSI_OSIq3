/*******************************************************************
*
* Wrapper class for the EstimatePayTaxWrapper  $ table
* Encapsulates pryroll tax detail for pricing use
*******************************************************************/
public with sharing class EstimatePayTaxWrapper {
    public String State {get; set;}
    public String LastName {get; set;}
    public String FirstName {get; set;}
    public Decimal PrjAnnualPay{get;set;}
    public Decimal EstERTax{get;set;}
    public String Active{get;set;}
	public Integer IsOwner{get;set;}
    
    // constructor
    public EstimatePayTaxWrapper()
    {
        //get total here added to total margin*/
        //CurrentContractYTDXmode = 0;
        //PreContractY2Xmode =0;
       // PreContractY1Xmode =0;
    }   
    
    /*public EstimatePayTaxWrapper(Decimal PrjAnnualPay, Decimal Rate) {    
       //calculate EstERTax = Rate*PrjAnnualPay
       //System.debug('**extra new line of XmodHistoryWrapper ' + STATE + ' ' + Rate + ColumnType );
       //get total here added to total margin
    }
    */
}