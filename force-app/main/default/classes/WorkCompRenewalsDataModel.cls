/**
 * @description WorkCompRenewalsDataModel
 */
public with sharing class WorkCompRenewalsDataModel {


    public String StatusMsg {get; private set;}
    public Integer StatusCode {get; private set;}

	public RiskAndClaims RiskClaims {get; private set;}
    public XmodHistory XmodHist {get; private set;}
    public SafetyIncentiveSummary SafetyIncentiveSum {get; private set;}

	private RenewalsRequestBody renewalsRequest;
    private RenewalsRequestBody renewalsRequestXmod;
    private Integer clientId;

    public Date StartDate {get; private set;}
    public Date EndDate {get; private set;}

    // Constructor
    public WorkCompRenewalsDataModel(Integer client, Date contractDate) {

        clientId = client;
        this.EndDate = contractDate;
        this.StartDate = contractDate.addYears(-1).addDays(1);

        renewalsRequest = new RenewalsRequestBody();
        renewalsRequest.QuickInit(client, contractDate);
        renewalsRequestXmod = new RenewalsRequestBody(client, contractDate, 5, false, false);
    }

    public void GetData() {
        if(renewalsRequest == null){ return; }

        String workCompModel2Url = '/getWorkCompModel2';
        String riskAndClaimsUrl = '/getRiskAndClaims';

        // initialize status msg and code
        StatusMsg = '';
        StatusCode = 0;

        HttpResponse httpRes;

        try {
                httpRes = HttpCallout.callBoomi(workCompModel2Url, renewalsRequestXmod.GetJsonString());
                if(httpRes != null && httpRes.getStatusCode() == 200 && httpRes.getBody() != ''){
                    WorkCompModel2_Deserialize tempObject = WorkCompModel2_Deserialize.parse(httpRes.getBody());

                    SafetyIncentiveSum = tempObject.SAFETYINCENTIVE;
                    XmodHist = tempObject.XMODHISTORY;

                } else {
                    CalloutException e = (CalloutException)CalloutException.class.newInstance();
                    e.setMessage(httpRes.getStatus());
                    throw e;
                }
                // New RiskClaims Object
                httpRes = HttpCallout.callBoomi(riskAndClaimsUrl, RiskAndClaims.GetRequestBody(clientId, StartDate.format()));
                if(httpRes != null && httpRes.getStatusCode() == 200 && httpRes.getBody() != ''){
                    RiskClaims = RiskAndClaims.parse(httpRes.getBody());
                } else {
                    CalloutException e = (CalloutException)CalloutException.class.newInstance();
                    e.setMessage(httpRes.getStatus());
                    throw e;
                }
                if(RiskClaims != null && RiskClaims.DATALIST.size() > 0){
                    applyUltimateExpected();
                }
	    }
	    catch (CalloutException e) {
			System.debug('WorkCompRenewalsDataModel GetData CalloutException: (line num ' + e.getLineNumber() + '), ' + e.getMessage());
	    	StatusMsg = e.getMessage();
	    	if (httpRes != null){
	    		StatusCode = httpRes.getStatusCode();
	    	}
        }
        catch (Exception e) {
			System.debug('WorkCompRenewalsDataModel GetData Exception: (line num ' + e.getLineNumber() + '), ' + e.getMessage());
            StatusMsg = e.getMessage();
        }
        finally {
            if (StatusMsg.length() == 0 && httpRes != null){
                StatusMsg = httpRes.getStatus();
                StatusCode = httpRes.getStatusCode();
            }
        }
    }


    // Claims list for the UI
    public Map<Integer,RiskClaimsListItem> RiskClaimsMap{
        get{
            Map<Integer,RiskClaimsListItem> claimsMap = new Map<Integer,RiskClaimsListItem>();
            RiskClaimsListItem listItem = new RiskClaimsListItem();
            if(RiskClaims != null && RiskClaims.DATALIST != null && RiskClaims.DATALIST.size() > 0){
                // Create the LTD row
                listItem.SortOrder = 0;
                listItem.ContractYear = 'Lifetime to Date';
                listItem.WorkCompBilled = 0;
                listItem.PremBasedPayroll = 0;
                listItem.TotalIncurred = 0;
                listItem.UltimateExpected = 0;
                listItem.OpenClaims = 0;
                listItem.TotalClaims = 0;
                listItem.Frequency = 0;
                listItem.LossRatio = 0;

                for(RiskAndClaims.DATA dataItem : RiskClaims.DATALIST){
                    listItem.WorkCompBilled += dataItem.WCBilled;
                    listItem.PremBasedPayroll += dataItem.PremBasedPayroll;
                    listItem.TotalIncurred += dataItem.TotalIncurred;
                    listItem.UltimateExpected += dataItem.UltimateExpected;
                    listItem.OpenClaims += dataItem.OpenClaims;
                    listItem.TotalClaims += dataItem.TotalClaims;
                }
                if(listItem.PremBasedPayroll > 0){
                    listItem.Frequency = (listItem.TotalClaims / listItem.PremBasedPayroll) * 1000000; //one million (six zeros)
                }
                if(listItem.WorkCompBilled > 0){
                    listItem.LossRatio = 100 * (listItem.UltimateExpected / listItem.WorkCompBilled);
                }

                claimsMap.put(listItem.SortOrder, listItem);

                //Add the history rows
                for(RiskAndClaims.DATA dataItem : RiskClaims.DATALIST){
                    // Skip if we have no WC billing or payroll
                    if(dataItem.WCBilled == 0 && dataItem.PremBasedPayroll == 0){
                        continue;
                    }

                    Integer sortOrder = Integer.valueOf(dataItem.Year);
                    if (claimsMap.containsKey(sortOrder)) {
                        listItem = claimsMap.get(sortOrder);
                    }
                    else {
                        listItem = new RiskClaimsListItem();
                        listItem.SortOrder = sortOrder;
                        listItem.ContractYear = 'Contract Year - ' + dataItem.Year;
                        listItem.WorkCompBilled = 0;
                        listItem.PremBasedPayroll = 0;
                        listItem.TotalIncurred = 0;
                        listItem.UltimateExpected = 0;
                        listItem.OpenClaims = 0;
                        listItem.TotalClaims = 0;
                        listItem.Frequency = 0;
                        listItem.LossRatio = 0;
                    }

                    listItem.WorkCompBilled += dataItem.WCBilled;
                    listItem.PremBasedPayroll += dataItem.PremBasedPayroll;
                    listItem.TotalIncurred += dataItem.TotalIncurred;
                    listItem.UltimateExpected += dataItem.UltimateExpected;
                    listItem.OpenClaims += dataItem.OpenClaims;
                    listItem.TotalClaims += dataItem.TotalClaims;

					if(listItem.PremBasedPayroll > 0){
						listItem.Frequency = (listItem.TotalClaims / listItem.PremBasedPayroll) * 1000000; //one million (six zeros)
					}

                    if(listItem.WorkCompBilled > 0){
                        listItem.LossRatio = 100 * (listItem.UltimateExpected / listItem.WorkCompBilled);
                    }

                    claimsMap.put(listItem.SortOrder, listItem);
                }
            }
            return claimsMap;
        }
    }

	public class RiskClaimsListItem {
		public Integer SortOrder {get; protected set;}
        public String ContractYear {get; protected set;}
		public Decimal WorkCompBilled{get; protected set;}
		public Decimal PremBasedPayroll{get; protected set;}
		public Decimal TotalIncurred{get; protected set;}
		public Decimal UltimateExpected{get; protected set;}
		public Integer OpenClaims {get; protected set;}
		public Integer TotalClaims {get; protected set;}
		public Decimal Frequency {get; protected set;}
		public Decimal LossRatio {get; protected set;}
	}

    private void applyUltimateExpected(){
		String exceptions = '';

        // Calculate Ultimate values with LDF
        Decimal ldfRate = 0;
        Integer months = 0;
        Date startDate;

        for (RiskAndClaims.DATA dataItem : RiskClaims.DATALIST) {
            if (!String.isBlank(dataItem.PeriodStartDate)) {
                try {
                    startDate = Date.valueOf(dataItem.PeriodStartDate);
                    months = Date.today().monthsBetween(startDate);

                    ldfRate = LdfModel.getLdfRate(dataItem.StateCode, months);
                    dataItem.UltimateExpected = ldfRate * dataItem.TotalIncurred;
                }
                catch (Exception e) {
					exceptions += 'DataItem Values';
					exceptions += '\nPeriodStartDate: ' + dataItem.PeriodStartDate;
					exceptions += '\nStateCode: ' + dataItem.StateCode;
					exceptions += '\nTotalIncurred: ' + dataItem.TotalIncurred;
					exceptions += '\n' + e.getMessage();
					exceptions += '\n\n';
                }
            }
        }

		if (!String.isBlank(exceptions)) {
			Log.error(
				'Renewals - WorkCompRenewalsDataModel.applyUltimateExpected()',
				'LDF Calculation Failure',
				exceptions
			);
		}
    }
}