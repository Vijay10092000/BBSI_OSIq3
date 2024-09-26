public without sharing class PricingDataModel {
    
    public String StatusMsg {get; Private set;}
    public Integer StatusCode {get; Private set;}
    
    // Data Classes
    public PayWcEstimate PayWcEst {get; private set;}
    public List<ER_Payroll_Tax_Master__c> PayrollTaxTable {get; set;}
    public List<WcPayItem> WcRatesAndPay {
        get{ return GetWcRatesAndPay(); }
    }
    public XmodHistory XmodHist { get; Private set; }
    public List<String> PricingGroups { get { return getPricingGroups(); } } 
    // private List<String> WorkCompCodes {
    //     get { return getWorkCompCodes(); }
    // }

    private List<ER_Payroll_Tax_Master__c> m_PayrollTaxTableTemp;
    private WorkCompRatesER m_WCRatesER;
    private SutaRatesER m_SutaRatesER;
    
    // Request Bodies
    private RenewalsRequestBody renewalsRequest;
    private RenewalsRequestBody renewalsRequest1period;
    private RenewalsRequestBody renewalsRequestXmod;
    
    // we don't support the default contstructor 
    public PricingDataModel(Integer client, Date contractDate) {
        renewalsRequest = new RenewalsRequestBody();
        renewalsRequest.QuickInit(client, contractDate);
        renewalsRequest1period = new RenewalsRequestBody();
        renewalsRequest1period.SimpleInit(client, contractDate, 1, False, False);
    }
    
    public void GetData() {
        if(renewalsRequest == null){ return; }
        
        string pricingDataModelUrl = '/getPricingDataModel';
        
        // initialize status msg and code
        StatusMsg = '';
        StatusCode = 0;
        
        HttpResponse httpRes;
        
        try {
            // Get data
            httpRes = HttpCallout.callBoomi(pricingDataModelUrl, renewalsRequest1period.GetJsonString());
            if(httpRes != null && httpRes.getStatusCode() == 200 && httpRes.getBody() != ''){
                PricingDataModelAggregateData tempObject = PricingDataModelAggregateData.parse(httpRes.getBody());

                PayWcEst = tempObject.PAYWCESTIMATES;
                XmodHist = tempObject.XMOD;
                m_SutaRatesER = tempObject.SUTARATES;
                m_WCRatesER = tempObject.WCRATES;

            } else {
                CalloutException e = (CalloutException)CalloutException.class.newInstance();
                e.setMessage(httpRes.getStatus());
                throw e;
            }

        }
        catch (CalloutException e) {
			System.debug('PricingDataModel GetData CalloutException: (line num ' + e.getLineNumber() + '), ' + e.getMessage());
            StatusMsg = e.getMessage();
            if (httpRes != null){
                StatusCode = httpRes.getStatusCode();
            }
        }
        catch (Exception e) {
			System.debug('PricingDataModel GetData Exception: (line num ' + e.getLineNumber() + '), ' + e.getMessage());
            StatusMsg = e.getMessage();
        }
        finally {
            if (StatusMsg.length() == 0 && httpRes != null){
                StatusMsg = httpRes.getStatus();
                StatusCode = httpRes.getStatusCode();
            }
        }
        
        InitializeTaxTable();                
    }
    
    public void InitializeTaxTable() {      
        //String PayWcEst_States = PayWcEst.States;
        if(PayWcEst == null) {return;}
        if(PayWcEst.States == null) {return;} 
        
        m_PayrollTaxTableTemp = [SELECT Limit__c, Rate__c, State_Code__c, Tax_Type__c 
                                 from ER_Payroll_Tax_Master__c 
                                 WHERE State_Code__c = 'FED' 
                                 OR State_Code__c in : PayWcEst.States];

        // Update the Tax Table with Client-specific Rates
        //first add all form payrolltaxtabletemp to payrolltaxtable
        PayrollTaxTable = new List<ER_Payroll_Tax_Master__c>();
        for(ER_Payroll_Tax_Master__c taxItem : m_PayrollTaxTableTemp){       
            PayrollTaxTable.add(taxItem);         
        }

        if (m_SutaRatesER != null)
        {
            Set<String> statesSet = new Set<String>(PayWcEst.States);
            
            for(SutaRatesER.DATA erItem : m_SutaRatesER.DATALIST){
                if(!statesSet.contains(erItem.State)) { continue; }

                If (erItem.SUTA != null && erItem.SUTA > 0){
                    UpdatePayrollTaxTable(erItem.State, 'SUTA', erItem.SUTA);
                }
                If (erItem.ETT != null && erItem.ETT >= 0){
                    UpdatePayrollTaxTable(erItem.State, 'ETT', erItem.ETT);
                }
                If (erItem.EAF != null && erItem.EAF > 0){
                    UpdatePayrollTaxTable(erItem.State, 'EAF', erItem.EAF);
                }
                If (erItem.Local != null && erItem.Local > 0){
                    UpdatePayrollTaxTable(erItem.State, 'Local', erItem.Local);
                }
            }
        }
    }
    
    private void UpdatePayrollTaxTable(string stateCode, string taxType, decimal taxRate) {
        
        Boolean rateFound = False;
        
        ER_Payroll_Tax_Master__c newTaxItem;
        
        for(ER_Payroll_Tax_Master__c taxItem : m_PayrollTaxTableTemp){
            if (taxItem.State_Code__c == stateCode &&
                taxItem.Tax_Type__c == taxType){
                    taxItem.Rate__c = taxRate;
                    rateFound = True;
                }
        }   
        If (!rateFound){
            newTaxItem = new ER_Payroll_Tax_Master__c();
            newTaxItem.State_Code__c = stateCode;
            newTaxItem.Tax_Type__c = taxType;
            newTaxItem.Rate__c = taxRate;
            newTaxItem.Limit__c = 0;
            PayrollTaxTable.add(newTaxItem);
        }
        
    }
    
    public class WcPayItem {
        public String State {get; private set;}
        public String WCcode {get; private set;}
        public Decimal PayAmt {get; private set;}
        public Decimal WcRate {get; private set;}
        public Integer IsEligibleSI {get; private set;}
        public Decimal EligibleRateSI {get; private set;}
    }
    
    private Map<String, WcPayItem> m_WcCodeMap;
    private WcPayItem payItem;
    
    
    private List<WcPayItem> GetWcRatesAndPay() {
        
        if(m_WcCodeMap == null){m_WcCodeMap = new Map<String, WcPayItem>();}
        
        m_WcCodeMap.clear();
        if (PayWcEst == null)
            return null;
        else
        {
            for (PayWcEstimate.DATA employee : PayWcEst.DATALIST){
                for (PayWcEstimate.WcPay wcItem : employee.WCcodes){
                    string key = employee.State +'.' + wcItem.WCcode;
                    if(m_WcCodeMap.containsKey(key)){
                        m_WcCodeMap.get(key).PayAmt += wcItem.PayAmt;
                    }
                    else{
                        payItem = new WcPayItem();
                        payItem.State = employee.State;
                        payItem.WCcode = wcItem.WCcode;
                        payItem.PayAmt = wcItem.PayAmt;
                        payItem.WcRate = getWcRate(employee.State, wcItem.WCcode);
                        payItem.IsEligibleSI = wcItem.IsEligibleSI;
                        payItem.EligibleRateSI = wcItem.EligibleRateSI;
                        m_WcCodeMap.put(key, payItem);
                    }
                }
            }
            return m_WcCodeMap.values();
        }
    }
    
    private Decimal getWcRate(string stateCode, string wcCode) {
        
        Decimal wcRate = 0.0;
        
        For(WorkCompRatesER.DATA item : m_WCRatesER.DATALIST){
            if (item.STATE == stateCode && item.WCCODE == wcCode) {
                wcRate = item.WCRATE;
                break;
            }
        }
        return wcRate;
    }
    
    private List<String> getPricingGroups() {
        Set<String> grpSet = new Set<String>();
        String tempStr;

        For(WorkCompRatesER.DATA item : m_WCRatesER.DATALIST){
            if (item.WCCODE.length() > 4) {
                // get the suffix and add it to the set

                tempStr = item.WCCODE.right(item.WCCODE.length() - 4);
                grpSet.add(tempStr.toUpperCase());
            }
        }
        return new List<String>(grpSet);
    }

    // private List<String> getWorkCompCodes() {

    //     List<String> wcCodes = new List<String>();

    //     For(WorkCompRatesER.DATA item : m_WCRatesER.DATALIST) {
    //         if(item.WCCODE.trim().length() > 0 && item.STATE.trim().length() > 0){
    //             wcCodes.add(item.WCCODE + ' ' + item.STATE);
    //         }
    //     }

    //     return wcCodes;
    // }
}