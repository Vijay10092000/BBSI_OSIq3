public without sharing class PricingSummaryData
{
    public PayrollHistoryData PayrollHistoryTable;
    public PayrollHistoryDataSum PayrollHistorySumTable;
    public RiskClaimsSiData RiskClaimsSi;
    public BdmAndCommissionData BdmAndCommissions;
    public XmodHistoryData XmodHistory;
    public WorkCompRatesER WorkCompRates;
    public WcAndSIdata WcAndSI;
    public WorkCompRatesER TemplateWorkCompRates;

    public static String ApiUrl {get {return '/getPricingSummaryData'; }}
    
	public static String GetRequestBody(Integer clientId, String contractStartDate){
        String template = '\"CLIENT\":{0},\"STARTDATE\":\"{1}\"';
        List<String> args = new String[]{String.valueOf(clientId), contractStartDate};
        return '{' + String.format(template, args) + '}';
    }
    
	public static PricingSummaryData parse(String json) {
		return (PricingSummaryData) System.JSON.deserialize(json, PricingSummaryData.class);
	}
}