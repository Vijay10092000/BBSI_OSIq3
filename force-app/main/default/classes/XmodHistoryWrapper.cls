/*******************************************************************
*
* Wrapper class for the XmodHistory  $ table
* Encapsulates a XmodHistory into a ViewModel of XmodHistory ui view table
*******************************************************************/
public with sharing class XmodHistoryWrapper {
    public String STATE {get;set;}
    public Decimal PreContractY2Xmode{get;set;}
    public Decimal PreContractY1Xmode{get;set;}
    public Decimal CurrentContractYTDXmode{get;set;}
    
    
    // constructor
    public XmodHistoryWrapper()
    {
        //get total here added to total margin*/
        //CurrentContractYTDXmode = 0;
        //PreContractY2Xmode =0;
       // PreContractY1Xmode =0;
    }   
    
       
}