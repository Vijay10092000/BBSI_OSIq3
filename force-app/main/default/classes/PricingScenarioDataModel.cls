public without sharing class PricingScenarioDataModel {

    public MarginAnalysisSummary MarginAnalysSummary {get; private set;}
    public TaxBurden TaxBurdenSum {get; private set;}
    public SafetyIncentiveSummary SafetyIncentiveSum {get; private set;}
    public CommissionRateDetailData CommissionRateDetail {get; private set;}
    public ClientBdmData BdmInfo {get; private set;}
    
    public String ClientId {get; Private set;}
    private String m_clientId;

    private RenewalsRequestBody renewalsRequest;
    
    public String StatusMsg {get; Private set;}
    public Integer StatusCode {get; Private set;}

	private final Integer PERIODS = 1;
	private final Boolean LTD = false;
	private final Boolean PROJECTED = true;

    public PricingScenarioDataModel(Integer client, Date contractDate) {
        this.ClientId = String.ValueOf(client);
        renewalsRequest = new RenewalsRequestBody();
        renewalsRequest.SimpleInit(client, contractDate, PERIODS, LTD, PROJECTED);
    }

    public static MarginAnalysisSummary parse(String json) 
    {
        return (MarginAnalysisSummary) System.JSON.deserialize(json, MarginAnalysisSummary.class);
    }

    public Decimal BillAmtTotal {
        Get {
            Decimal temp = 0;
            if (this.MarginAnalysSummary.DataList == null) return temp;            
            For (MarginAnalysisSummary.DATA dataItem : this.MarginAnalysSummary.DataList){
                For (MarginAnalysisSummary.MARGINSUMMARYDATA item : dataItem.MarginSumDataList) {
                    temp += item.BILLAMT;
                }
            }
            return temp;
        }
    }
    public Decimal WcPremTotal {
        Get {
            Decimal temp = 0;
            if (this.MarginAnalysSummary.DataList == null) return temp;            
            For (MarginAnalysisSummary.DATA dataItem : this.MarginAnalysSummary.DataList){
                if(dataItem.MarginSumDataList == null) continue;
                For (MarginAnalysisSummary.MARGINSUMMARYDATA item : dataItem.MarginSumDataList) {
                    temp += item.WCPREM;
                }
            }
            return temp;
        }
    }
    public Decimal MarginTotal {
        Get {
            Decimal temp = 0;
            if (this.MarginAnalysSummary.DataList == null) return temp;            
            For (MarginAnalysisSummary.DATA dataItem : this.MarginAnalysSummary.DataList){
                if(dataItem.MarginSumDataList == null) continue;
                For (MarginAnalysisSummary.MARGINSUMMARYDATA item : dataItem.MarginSumDataList) {
                    temp += item.MARGIN;
                }
            }
            return temp;
        }
    }
    public Decimal PayrollTotal {
        Get {
            Decimal temp = 0;
            if(this.TaxBurdenSum.DATALIST == null) return temp;
            For (TaxBurden.DATA item : this.TaxBurdenSum.DATALIST){
                if(item.TotalPayroll == null) continue;
                temp += item.TotalPayroll;
            }
            return temp;
        }
    }
    public Decimal TaxesTotal {
        Get {
            Decimal temp = 0;
            if(this.TaxBurdenSum.DATALIST == null) return temp;
            For (TaxBurden.DATA item : this.TaxBurdenSum.DATALIST){
                if(item.TotalTaxes == null) continue;
                temp += item.TotalTaxes;
            }
            return temp;
        }
    }
    public Decimal MaxSITotal {
        Get {
            Decimal temp = 0;
            if(this.SafetyIncentiveSum.DataList == null) return temp;
            For (SafetyIncentiveSummary.DATA item : this.SafetyIncentiveSum.DataList){
                if(item.MaxSI == null) continue;
                temp += item.MaxSI;
            }
            return temp;
        }
    }
    public Decimal BdmCommissionTotal {
        Get { 

            Decimal temp = 0;
            Decimal rate = .05;
            if(BdmInfo == null || BdmInfo.HASBDM == null) return temp;

            if (BdmInfo.HASBDM == 'TRUE'){
                temp = rate * this.MarginTotal;
            }

            return temp;
        }
    }
    public Decimal RefPartCommissionTotal {
        Get {
            Decimal temp = 0;
            if(CommissionRateDetail == null || CommissionRateDetail.HasRefPartner == null) return temp;
            if(CommissionRateDetail.HasRefPartner){
                if(this.CommissionRateDetail.DataList == null) return temp;
                For (CommissionRateDetailData.DATA item : this.CommissionRateDetail.DataList){
                    if(item.CommissionAmt == null) continue;
                    temp += item.CommissionAmt;
                }
            }
            return temp;
        }
    }

    public void GetData() 
    {
        if(renewalsRequest == null){ return; }
        
        string pricingScenarioDataUrl = '/getPricingScenarioModel';
        
        // initialize status msg and code
        StatusMsg = '';
        StatusCode = 0;
        
        HttpResponse httpRes;
        try {
            // Margin Analysis Summary
            httpRes = HttpCallout.callBoomi(pricingScenarioDataUrl, renewalsRequest.GetJsonString());
            if(httpRes != null && httpRes.getStatusCode() == 200 && httpRes.getBody() != ''){

                PricingScenarioAggregateData tempObject = PricingScenarioAggregateData.parse(httpRes.getBody());
                
                MarginAnalysSummary = tempObject.MARGINDATA;
                TaxBurdenSum = tempObject.TAXBURDEN;
                BdmInfo = tempObject.BDM;
                CommissionRateDetail = tempObject.COMMRATEDETAIL;
                SafetyIncentiveSum = tempObject.SISUMMARY;

            } else {
                CalloutException e = (CalloutException)CalloutException.class.newInstance();
                e.setMessage(httpRes.getStatus());
                throw e;
            }
            
        } catch (CalloutException e) {
			System.debug('PricingScenarioDataModel GetData CalloutException: (line num ' + e.getLineNumber() + '), ' + e.getMessage());
            StatusMsg = e.getMessage();
            System.debug('PricingScenarioDataModel CalloutException: ' + e.getMessage());
            if (httpRes != null){
                StatusCode = httpRes.getStatusCode();
            }
        } catch (Exception e) {
			System.debug('PricingScenarioDataModel GetData Exception: (line num ' + e.getLineNumber() + '), ' + e.getMessage());
            StatusMsg = e.getMessage();
            System.debug('PricingScenarioDataModel Exception: ' + e.getMessage());
        } finally {
            if (StatusMsg.length() == 0 && httpRes != null){
                StatusMsg = httpRes.getStatus();
                StatusCode = httpRes.getStatusCode();
            }
        }
    }
}