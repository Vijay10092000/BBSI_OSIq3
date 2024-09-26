public class EstimateWCPayWrapper {

/*******************************************************************
*
* Wrapper class for the esitmate your renewal Year WC Permium equivalent & saftty incentive table
* Encapsulates ui view table
*******************************************************************/
        public String State {get;  set;}
        public String WCcode {get;  set;}
        public Decimal PayAmt {get;  set;}
        public Decimal WcRate {get;  set;}
        public Decimal WCEquivalent {get;  set;}
        public String IsEligibleSI {get;  set;}
        public Decimal EligibleRateSI {get;  set;}
        public Decimal MaxSafetySI {get;  set;}
   
    // constructor
    public EstimateWCPayWrapper()
    {
        //get total here added to total margin*/
        //CurrentContractYTDXmode = 0;
        //PreContractY2Xmode =0;
       // PreContractY1Xmode =0;
    }   
    

}