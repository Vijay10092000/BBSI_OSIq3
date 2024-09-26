public without sharing class PricingSummaryDataModel
{
    public PayrollHistoryData PayrollHistory;
    public PayrollHistoryDataSum PayrollHistorySum;
    public BdmAndCommissionData BdmAndComms;
    public RiskClaimsSiData RiskAndClaims;
    public XmodHistoryData XmodHistory;
    public XmodDataModel XmodPublishedData;
    public WorkCompRatesER WorkCompRates;
    public WcAndSIdata WcAndSI;
    public WorkCompRatesER TemplateWorkCompRates;

    public String StatusMsg { get; private set; }
    public Integer StatusCode { get; private set; }

    private Integer clientId;
    public String FEIN { get; private set; }
    public Date StartDate { get; private set; }
    public Date EndDate { get; set; }

    /**
     * Client has an Xmod for California and is subject to California Work Comp insurance
     */
    public Boolean HasCA_Xmod
    {
        get {
            for (XmodHistoryData.XmodDetailItem item : XmodHistory.XmodDetails) {
                if (item.StateCode == 'CA') {
                    return true;
                }
            }
            return false;
        }
    }

    public List<String> WorkCompCodes
    { get { return getWorkCompCodes(); } }

    public List<WorkCompRatesER.DATA> TemplateWorkComps
    { get { return TemplateWorkCompRates.DATALIST; } }

    public List<WcPayItem> WcRatesAndPay
    { get{ return GetWcRatesAndPay(); } }

    public PricingSummaryDataModel(Integer client, Date contractDate, String fein)
    {
        this.clientId = client;
        this.FEIN = fein;
        this.EndDate = contractDate;
        this.StartDate = contractDate.addYears(-1).addDays(1);

        // Move to March if lands on the Leap Day
        if (this.StartDate.month() == 2 && this.StartDate.day() == 29) {
            this.StartDate = Date.newInstance(this.StartDate.year(), 3, 1);
        }
    }

    public void GetData()
    {
        String requestBody;
        String apiUrl = '';
        StatusMsg = '';
        StatusCode = 0;

        HttpResponse httpRes;
        try
        {
            apiUrl = PricingSummaryData.ApiUrl;
            requestBody = PricingSummaryData.GetRequestBody(clientId, StartDate.format());
            httpRes = HttpCallout.callBoomi(apiUrl, requestBody);
            if (httpRes != null && httpRes.getStatusCode() == 200 && httpRes.getBody() != '')
            {
                PricingSummaryData summaryData = PricingSummaryData.parse(httpRes.getBody());
                PayrollHistory = summaryData.PayrollHistoryTable;
                PayrollHistorySum = summaryData.PayrollHistorySumTable;
                RiskAndClaims = summaryData.RiskClaimsSi;
                BdmAndComms = summaryData.BdmAndCommissions;
                XmodHistory = summaryData.XmodHistory;
                WorkCompRates = summaryData.WorkCompRates;
                TemplateWorkCompRates = summaryData.TemplateWorkCompRates;
                WcAndSI = summaryData.WcAndSI;

                if (this.HasCA_Xmod) {
                    XmodPublishedData = new XmodDataModel(FEIN);
                    XmodPublishedData.GetData();
                }
            } else {
                CalloutException e = (CalloutException)CalloutException.class.newInstance();
                e.setMessage(httpRes.getStatus());
                throw e;
            }
        } catch (CalloutException e) {
            System.debug('PricingSummaryDataModel GetData CalloutException: (line num ' + e.getLineNumber() + '), ' + e.getMessage());
            StatusMsg = e.getMessage();
            System.debug('PricingSummaryDataModel CalloutException: ' + e.getMessage());
            if (httpRes != null)
            { StatusCode = httpRes.getStatusCode(); }
            throw new RenewalException('An unexpected error occurred importing data');
        } catch (Exception e) {
            System.debug('PricingSummaryDataModel GetData Exception: (line num ' + e.getLineNumber() + '), ' + e.getMessage());
            StatusMsg = e.getMessage();
            System.debug('PricingSummaryDataModel Exception: ' + e.getMessage());
            throw new RenewalException('An unexpected error occurred');
        } finally {
            if (StatusMsg.length() == 0 && httpRes != null){
                StatusMsg = httpRes.getStatus();
                StatusCode = httpRes.getStatusCode();
            }
        }
    }

    public class WcPayItem
    {
        public String State {get; private set;}
        public String WcCode {get; private set;}
        public Decimal PayAmt {get; private set;}
        public Decimal WcRate {get; private set;}
        public Boolean IsEligibleSI {get; private set;}
        public Decimal EligibleRateSI {get; private set;}
    }

    private Map<String, WcPayItem> m_WcCodeMap;
    private WcPayItem payItem;

    private List<WcPayItem> GetWcRatesAndPay()
    {
        if (m_WcCodeMap == null) { m_WcCodeMap = new Map<String, WcPayItem>(); }

        m_WcCodeMap.clear();
        if (PayrollHistory == null) {
            return null;
        }
        else {
            for (PayrollHistoryData.PayrollItem employee : PayrollHistory.Payroll){
                for (PayrollHistoryData.WcDetail wcItem : employee.WcDetails){
                    String key = wcItem.State +'.' + wcItem.WcCode;
                    if(m_WcCodeMap.containsKey(key)){
                        m_WcCodeMap.get(key).PayAmt += wcItem.PayAmt;
                    }
                    else{
                        payItem = new WcPayItem();
                        payItem.State = wcItem.State;
                        payItem.WcCode = wcItem.WcCode;
                        payItem.PayAmt = wcItem.PayAmt;
                        payItem.WcRate = getWcRate(wcItem.State, wcItem.WcCode);
                        payItem.IsEligibleSI = IsEligibleforSI(wcItem.State, wcItem.WcCode);
                        payItem.EligibleRateSI = getSIrate(wcItem.State, wcItem.WcCode);
                        m_WcCodeMap.put(key, payItem);
                    }
                }
            }
            return m_WcCodeMap.values();
        }
    }

    private List<String> getWorkCompCodes()
    {
        List<String> wcCodes = new List<String>();
        for(WorkCompRatesER.DATA item : WorkCompRates.DATALIST) {
            if(item.WCCODE.trim().length() > 0 && item.STATE.trim().length() > 0){
                wcCodes.add(item.WCCODE + ' ' + item.STATE);
            }
        }
        return wcCodes;
    }

    private List<String> getTemplateWorkCompCodes()
    {
        List<String> wcCodes = new List<String>();

        for(WorkCompRatesER.DATA item : TemplateWorkCompRates.DATALIST) {
            if(item.WCCODE.trim().length() > 0 && item.STATE.trim().length() > 0){
                wcCodes.add(item.WCCODE + ' ' + item.STATE);
            }
        }
        return wcCodes;
    }

    public Decimal getWcRate(String stateCode, String wcCode)
    {
        Decimal wcRate = 0.0;
        for(WorkCompRatesER.DATA item : WorkCompRates.DATALIST){
            if (item.STATE == stateCode && item.WCCODE == wcCode) {
                wcRate = item.WCRATE;
                break;
            }
        }
        return wcRate;
    }

    private Boolean IsEligibleforSI(String stateCode, String wcCode)
    {
        for(WcAndSIdata.WcSiItem item : WcAndSI.WcSiList){
            if(item.StateCode == stateCode && item.WcCode == wcCode){
                return item.IsEligible == 1;
            }
        }
        // if we got through the list and haven't found a match, return false
        return false;
    }

    private Double GetSIrate(String stateCode, String wcCode)
    {
        for(WcAndSIdata.WcSiItem item : WcAndSI.WcSiList){
            if(item.StateCode == stateCode && item.WcCode == wcCode){
                return item.EligibleRateSI;
            }
        }
        // if we got through the list and haven't found a match, return 0
        return 0;
    }

}