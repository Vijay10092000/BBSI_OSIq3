public with sharing class MarginAnalysisModel {
    
    public BillingAdjustmentsSummary BillingAdjSummary {get; private set;}
    public DirectExpensesSummary DirectExpSummary {get; private set;}
    public MarginAnalysisSummary MarginAnalysSummary {get; private set;}
    public TurnoverSummary TurnovrSummary {get; private set;}
    public SecondaryServicesSummary SecondaryServSummary {get; private set;}
    public ClientBdmData BdmInfo {get; private set;}
    public TaxBurden TaxBurdenSum {get; private set;}
    
    private RenewalsRequestBody renewalsRequest;
    
    public String StatusMsg {get; Private set;}
    public Integer StatusCode {get; Private set;}
    
    public MarginAnalysisModel(Integer client, Date contractDate) {
        renewalsRequest = new RenewalsRequestBody();
        renewalsRequest.QuickInit(client, contractDate);
    }
    public void GetData() {
        
        if(renewalsRequest == null){ return; }
        
        string marginModelUrl = '/getMarginAnalysisModel';
        
        // initialize status msg and code
        StatusMsg = '';
        StatusCode = 0;
        
        HttpResponse httpRes;

        try{
            // Margin Analysis Summary
            httpRes = HttpCallout.callBoomi('/getMarginAnalysisModel', renewalsRequest.GetJsonString());
            if(httpRes != null && httpRes.getStatusCode() == 200 && httpRes.getBody() != ''){

                MarginModel_Deserialize tempObject = MarginModel_Deserialize.parse(httpRes.getBody());

                MarginAnalysSummary = tempObject.MARGINDATA;
                BillingAdjSummary = tempObject.BILLINGADJUSTMENTS;
                DirectExpSummary = tempObject.DIRECTEXPENSES;
                TurnovrSummary = tempObject.TURNOVER;
                SecondaryServSummary = tempObject.SECONDARYSERVICES;
                BdmInfo = tempObject.BDM;
                TaxBurdenSum = tempObject.TAXBURDEN;
            } else {
                CalloutException e = (CalloutException)CalloutException.class.newInstance();
                e.setMessage(httpRes.getStatus());
                throw e;
            }
            
        } catch (CalloutException e) {
			System.debug('MarginAnalysisModel GetData CalloutException: (line num ' + e.getLineNumber() + '), ' + e.getMessage());
            StatusMsg = e.getMessage();
            if (httpRes != null){
                StatusCode = httpRes.getStatusCode();
            }
        } catch (Exception e) {
			System.debug('MarginAnalysisModel GetData Exception: (line num ' + e.getLineNumber() + '), ' + e.getMessage());
            StatusMsg = e.getMessage();
        } finally {
            if (StatusMsg.length() == 0 && httpRes != null){
                StatusMsg = httpRes.getStatus();
                StatusCode = httpRes.getStatusCode();
            }
        }
    }
}