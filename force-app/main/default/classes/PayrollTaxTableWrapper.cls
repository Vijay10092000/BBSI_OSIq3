public class PayrollTaxTableWrapper {

/*******************************************************************
*
* Wrapper class for the XmodHistory  $ table
* Encapsulates a XmodHistory into a ViewModel of XmodHistory ui view table
*******************************************************************/
    public String STATE {get;set;}
    public String TaxType {get;set;}
    public Decimal Rate{get;set;}
    public Decimal TaxLimit{get;set;}
   
    
    // constructor
    public PayrollTaxTableWrapper()
    {
        //get total here added to total margin*/
        //CurrentContractYTDXmode = 0;
        //PreContractY2Xmode =0;
       // PreContractY1Xmode =0;
    }   
    
    public PayrollTaxTableWrapper(String STATE, String ColumnType, Decimal Rate) {    

    }
    

}