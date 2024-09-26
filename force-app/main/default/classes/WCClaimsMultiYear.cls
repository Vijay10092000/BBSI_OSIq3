public with sharing class WCClaimsMultiYear {
    
    public Integer CLIENT;
	public String STARTDATE;
	public List<DATA> DATALIST;

	public class DATA {
		public String Year;
		public String StateCode;
        //To calculate LDF (LDF uses annual contract start date, not injury date)
		public String PeriodStartDate;  
		public Decimal TotalIncurred;
		public Integer OpenClaims;
		public Integer TotalClaims;
		// LDF values are populated later as they require additional business logic
		public Double TotalIncurredLdf{get; set;}
	}

    // TODO: We should add GetRequestBody to the other 'deserialize' classes
	//       this puts all the API call "knowledge" in one place for each class
	public static String GetRequestBody(Integer clientId, String contractStartDate){
        String template = '\"CLIENT\":{0},\"STARTDATE\":\"{1}\"';
        List<String> args = new String[]{String.valueOf(clientId), contractStartDate};
        return '{' + String.format(template, args) + '}';
    }
    
	public static WCClaimsMultiYear parse(String json) {
		return (WCClaimsMultiYear) System.JSON.deserialize(json, WCClaimsMultiYear.class);
	}
}