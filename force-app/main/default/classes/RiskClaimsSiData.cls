public with sharing class RiskClaimsSiData {

	public Integer Client;
	public String StartDate;
	public List<DataItem> DataList;

	public class DataItem {
		public String Year;
		public String StateCode;
		public Double WCBilled;
		public Double PremBasedPayroll;
		public String PeriodStartDate;
		public Double TotalIncurred;
		public Double UltimateExpected;
		public Integer OpenClaims;
		public Integer TotalClaims;
		public Double Frequency;
		public Double MaxSI;
	}
	
	public static String GetRequestBody(Integer clientId, String contractStartDate){
        String template = '\"CLIENT\":{0},\"STARTDATE\":\"{1}\"';
        List<String> args = new String[]{String.valueOf(clientId), contractStartDate};
        return '{' + String.format(template, args) + '}';
    }
    
	public static RiskClaimsSiData parse(String json) {
		return (RiskClaimsSiData) System.JSON.deserialize(json, RiskClaimsSiData.class);
	}

}