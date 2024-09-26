public class PayrollPricingComponentController {
    Public String accountExternalID {get;set;}   
    Public String ErrorStatus{get;set;} 
    Public Date contractDate  {get;set;} 
    Public Date contractStartDate  {get;set;} 
    Public integer wcran {get; set;}
    Public integer currentContractYear  {get;set;} 
    Public String SIRunDate {get;set;} 

    
    public List<PayrollTaxTableWrapper> PayrollTaxTable {get; set;}  
    public List<EstimateWCPayWrapper> EstimateWCPayTable{get; set;}  
    public List<EstimatePayTaxWrapper> EstimatePayTaxTable {get; set;}
    
    public Map<String, Decimal> Totals {get; set;} //PAY TAX WC INC
    public List<XmodHistoryWrapper> XmodRateTable {get; set;}
    private Map<String, XmodHistory.XmodData> XmodData {get; set;}   
    
    // constructor
    public PayrollPricingComponentController() {
        wcran = 0;
        system.debug('wcran: in construct:' + wcran);
    }
    
    
    public Pagereference getCompValues(){
        //accountExternalID = '903629'; //'901550'
        System.Debug('*** getting marginanalysis Detail getValues with ***>>' + accountExternalID + 'and contractDate -' + contractDate );
        if (contractDate.year() >= system.today().year())
            currentContractYear = contractDate.year();
        else
            currentContractYear = system.Today().year(); 
        
        integer client = integer.valueOf(accountExternalID);
        System.Debug('*** currentContractYear' + currentContractYear + ' Client:' + accountExternalID  );
        PricingDataModel obj = new PricingDataModel(client, contractDate);
        wcran = wcran+1;
        System.Debug('wcran: ' + wcran +' currentContractYear' + currentContractYear + ' Client:' + accountExternalID  );
        if (wcran == 1)
        {
            //MarginAnalysisTable = new List<MarginAnalysisWrapper>() ;
            //will put in lazy loading while i am ready
            obj.GetData();      
            //oppsNeeded = false; //for lazy loading
            system.debug ('obj.StatusMsg returned:' + obj.StatusMsg);          
            if (obj.StatusMsg != 'OK')   
            {    
                ErrorStatus =  obj.StatusMsg;  
                system.debug ('obj.StatusMsg:' + obj.StatusMsg + ' *** currentContractYear' + currentContractYear + ' Client:' + accountExternalID);
                ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.ERROR, obj.StatusMsg + ' in PricingDataModel with Client:' + accountExternalID));
                //system.debug ('MarginAnalysisTable returned:' + MarginAnalysisTable);
            } 
            else
            {   
                
				XmodHistory XmodHistoryObj = obj.XmodHist; 
                XmodData = new Map<String, XmodHistory.XmodData>();
                XmodRateTable = new List<XmodHistoryWrapper>() ;
                processXmodData(XmodHistoryObj);
                //system.debug ('obj.StatusMsg returned -- OK message:' + obj.StatusMsg);      
                PayWcEstimate PayWcEstObj  = obj.PayWcEst;
                List<ER_Payroll_Tax_Master__c> PayrollTaxTableObj = obj.PayrollTaxTable;
                
                //system.debug ('$$$$obj.PayrollTaxTable:' + obj.PayrollTaxTable);  
                
                List<PricingDataModel.WcPayItem> WcRatesAndPayObj = obj.WcRatesAndPay;
                
                PayrollTaxTable = new List<PayrollTaxTableWrapper>() ;
                processPayrollTaxTable(PayrollTaxTableObj);
                //System.debug('obj.PayrollTaxTable -' + obj.PayrollTaxTable);
                //System.debug('***PayrollTaxTableObj -' + PayrollTaxTableObj);
                Totals = new Map<String, Decimal>();
                Totals.clear();
                EstimatePayTaxTable = new List<EstimatePayTaxWrapper>() ;
                processPaytaxEstimate(PayWcEstObj);
                                
                EstimateWCPayTable = new List<EstimateWCPayWrapper>() ;
                // EstimatePayTaxTable = new List<EstimateWCPayWrapper>() ;
                processPayWCEstimate(WcRatesAndPayObj);
                
            }
        }
        return null;
    }
    
    //filling  processPaytaxEstimate
    Public void processPaytaxEstimate(PayWcEstimate PayWcEstObj)
    {   
        Decimal PayTotal =0;
        Decimal TaxTotal =0;
        Decimal PayTotalOwner =0;
        Decimal TaxTotalOwner =0;
        Decimal TaxBurden =0;
        Decimal TaxBurdenNoOwner =0;
        
        if (PayWcEstObj != null)
        {
            system.debug(' PayWcEstObj.DATALIST:' + PayWcEstObj.DATALIST);
            
            for (PayWcEstimate.DATA ThePayWcEstimate : PayWcEstObj.DATALIST)
            {
                
                //system.debug('in Process thePayWcEstimate --' + thePayWcEstimate);         
                EstimatePayTaxWrapper TheEstimatePayTax= new EstimatePayTaxWrapper(); 
                //system.debug('in Process thePayWcEstimate.State --' + thePayWcEstimate.State);     
                TheEstimatePayTax.State = ThePayWcEstimate.State;
                if (ThePayWcEstimate.IsOwner == 1)
                {
                	TheEstimatePayTax.LastName = ThePayWcEstimate.LastName + '(Owner)';
                    PayTotalOwner = PayTotalOwner + ThePayWcEstimate.TotalPay;
                }
                else
                {
                    TheEstimatePayTax.LastName = ThePayWcEstimate.LastName ;
                }

                TheEstimatePayTax.FirstName = ThePayWcEstimate.FirstName;
                if(ThePayWcEstimate.Active.replaceAll( '\\s+', '') == '')
                    TheEstimatePayTax.Active = 'T';
                else
                    TheEstimatePayTax.Active = ThePayWcEstimate.Active;
                TheEstimatePayTax.IsOwner = ThePayWcEstimate.IsOwner;
                TheEstimatePayTax.PrjAnnualPay = ThePayWcEstimate.TotalPay;
                PayTotal = PayTotal + ThePayWcEstimate.TotalPay;
                //this has to add all the related tax and limit from PayrollTaxTable
                //fixed limit is for wage limit not tax limit 9.13.2017
                TheEstimatePayTax.EstERTax = 0;
                for (PayrollTaxTableWrapper item : PayrollTaxTable)
                    {
                        if ((item.STATE =='FED') || (item.STATE == TheEstimatePayTax.State))
                        {
                            Decimal theTotal = 0;
                            if (item.TaxLimit==0)
                            {
                                theTotal = TheEstimatePayTax.PrjAnnualPay * (item.Rate/100);
                                TheEstimatePayTax.EstERTax =  TheEstimatePayTax.EstERTax + theTotal; 
                            }
                            else
                            {
                                if (TheEstimatePayTax.PrjAnnualPay >= item.TaxLimit)
                                {
                                    theTotal = item.TaxLimit * (item.Rate/100);
                                    TheEstimatePayTax.EstERTax =  TheEstimatePayTax.EstERTax + theTotal; 
                                    
                                }
                                else
                                {
                                    theTotal = TheEstimatePayTax.PrjAnnualPay * (item.Rate/100);
                                    TheEstimatePayTax.EstERTax =  TheEstimatePayTax.EstERTax + theTotal; 
                                }
                                
                            }
                        }
                        
                    }
                if (ThePayWcEstimate.IsOwner == 1)
                 TaxTotalOwner = TaxTotalOwner + TheEstimatePayTax.EstERTax;  
                
                TaxTotal = TaxTotal + TheEstimatePayTax.EstERTax;        
                EstimatePayTaxTable.add(TheEstimatePayTax);
            }
        }
        system.debug('PayTotal --' + PayTotal); 
        if (PayTotal == 0 )
            TaxBurden = 0;
        else
            TaxBurden = TaxTotal/PayTotal;
        
       if ((PayTotal - PayTotalOwner) == 0 )
            TaxBurdenNoOwner = 0;
        else
            TaxBurdenNoOwner = (TaxTotal-TaxTotalOwner)/(PayTotal - PayTotalOwner);

        
        Totals.put ('PAY', PayTotal);
        Totals.put ('TAX', TaxTotal);
        Totals.put ('TaxBurden', TaxBurden*100);
        Totals.put ('TaxBurdenNoOwner', TaxBurdenNoOwner*100);
        system.debug('TaxTotalOwner --' + TaxTotalOwner); 
        system.debug('PayTotalOwner --' + PayTotalOwner); 
        
    }
    
    
    //filling  processPayWcEstimate
    Public void processPayWCEstimate(List<PricingDataModel.WcPayItem> WcRatesAndPayObj)
    {
        
        Decimal WCTotal =0;
        Decimal EQTotal =0;
        Decimal MSITotal =0;
        if (WcRatesAndPayObj != null)
        {
            system.debug('WcRatesAndPayObj:' + WcRatesAndPayObj);
            
            for (PricingDataModel.WcPayItem TheWcRatesAndPay : WcRatesAndPayObj)
            {
                
                //system.debug('in Process thePayWcEstimate --' + thePayWcEstimate);   
                
                EstimateWCPayWrapper EstimateWCPayTableItem= new EstimateWCPayWrapper(); 
                EstimateWCPayTableItem.State = TheWcRatesAndPay.State;
                EstimateWCPayTableItem.PayAmt = TheWcRatesAndPay.PayAmt;
                EstimateWCPayTableItem.WCcode = TheWcRatesAndPay.WCcode;
                EstimateWCPayTableItem.WcRate = TheWcRatesAndPay.WcRate;
                Boolean xmodFound = False;
                if (XmodRateTable != null)
                {
                    for (XmodHistoryWrapper XmodHistory : XmodRateTable )
                    {
                         if (XmodHistory.State == EstimateWCPayTableItem.State)
                         {
                            EstimateWCPayTableItem.WCEquivalent = EstimateWCPayTableItem.PayAmt * (EstimateWCPayTableItem.WcRate/100)*XmodHistory.CurrentContractYTDXmode;
                            xmodFound = True;
                            break;
                         }                        
                    }
                }
                if (!xmodFound) //no xmodFound
                {
                    EstimateWCPayTableItem.WCEquivalent = EstimateWCPayTableItem.PayAmt * EstimateWCPayTableItem.WcRate * 0;
                }
                               
                if (TheWcRatesAndPay.IsEligibleSI == 1)
                    EstimateWCPayTableItem.IsEligibleSI = 'Yes';
                else
                    EstimateWCPayTableItem.IsEligibleSI = 'No';
                EstimateWCPayTableItem.EligibleRateSI = TheWcRatesAndPay.EligibleRateSI;
                EstimateWCPayTableItem.MaxSafetySI = (EstimateWCPayTableItem.EligibleRateSI/100) *  EstimateWCPayTableItem.PayAmt ;
                WCTotal = WCTotal + TheWcRatesAndPay.PayAmt;
                EQTotal = EQTotal + EstimateWCPayTableItem.WCEquivalent;
                MSITotal = MSITotal + EstimateWCPayTableItem.MaxSafetySI;
                EstimateWCPayTable.add(EstimateWCPayTableItem);
            }
        }
        system.debug('WCTotal --' + WCTotal); 
        
        Totals.put ('WC', WCTotal);
        Totals.put ('EQ', EQTotal);
        Totals.put ('MSI', MSITotal);
        system.debug('EstimateWCPayTable --' + EstimateWCPayTable); 
        
        
    }
    
    //filling  processPayTaxEstimate
    Public void processPayrollTaxTable(List<ER_Payroll_Tax_Master__c> PayrollTaxTableObj)
    {
        if (PayrollTaxTableObj != null)
        {
            for (ER_Payroll_Tax_Master__c ThePayrollTax : PayrollTaxTableObj)
            {
                
                //system.debug('in Process thePayWcEstimate --' + thePayWcEstimate);         
                PayrollTaxTableWrapper PayrollTaxItem = new PayrollTaxTableWrapper(); 
                //system.debug('in Process thePayWcEstimate.State --' + thePayWcEstimate.State);     
                PayrollTaxItem.STATE = ThePayrollTax.State_Code__c;
                PayrollTaxItem.TaxType = ThePayrollTax.Tax_Type__c;
                PayrollTaxItem.Rate = ThePayrollTax.Rate__c;
                PayrollTaxItem.TaxLimit = ThePayrollTax.Limit__c;
                
                PayrollTaxTable.add(PayrollTaxItem);
            }
            //system.debug('PayrollTaxTable --' + PayrollTaxTable); 
        }
        
    }
    
     //filling process XmodData
    Public void processXmodData(XmodHistory XmodHistoryObj)
    {
        XmodData.clear();
        
        //we should have 5 period of Data back at this point
        //system.debug(' ClaimsObj.DataList[0]:' + XmodHistoryObj.DATALIST[0]);
        //system.debug(' ClaimsObj.DataList[1]:' + XmodHistoryObj.DATALIST[1]);
        //system.debug('ClaimsObj.DataList[2]' + XmodHistoryObj.DATALIST[2]);
        
        //use xmodhistory wrapper
        //build the first fill in xmodhistoryTable with YTD data
        if (XmodHistoryObj != null)
        {
            //YTD adjustment
            XmodData.put ('YTD', XmodHistoryObj.DATALIST[0]);
            system.debug('XmodHistoryObj --' + XmodHistoryObj);  
            
            for (XmodHistory.XmodSummary YTDdata : XmodHistoryObj.DataList[0].XMODLIST)
            {
                
                system.debug('in Process data YTD xmode --' + YTDdata);         
                XmodHistoryWrapper TheXmodHistory= new XmodHistoryWrapper();        
                TheXmodHistory.STATE = YTDdata.STATE;
                TheXmodHistory.PreContractY2Xmode = 0; //no use
                TheXmodHistory.PreContractY1Xmode = 0; //no use
                TheXmodHistory.CurrentContractYTDXmode = YTDdata.XMOD;
                
                XmodRateTable.add(TheXmodHistory);
            }
        }
    }
}