public with sharing class RiskAndClaims  {

    public String CLIENT;
    public List<DATA> DATALIST;

    public class DATA {
        public String Year;
        public String StateCode;
        public Double WCBilled;
        public Double PremBasedPayroll;
        //To calculate LDF, which uses annual contract start date, not injury date
        public String PeriodStartDate;
        public Double TotalIncurred;
		// UltimateExpected is populated later. It requires LDF + business logic
        public Double UltimateExpected;
        public Integer OpenClaims;
        public Integer TotalClaims;
        public Double Frequency;
    }

	public static String GetRequestBody(Integer clientId, String contractStartDate){
        String template = '\"CLIENT\":{0},\"STARTDATE\":\"{1}\"';
        List<String> args = new String[]{String.valueOf(clientId), contractStartDate};
        return '{' + String.format(template, args) + '}';
    }

    public static RiskAndClaims parse(String json) {
        return (RiskAndClaims) System.JSON.deserialize(json, RiskAndClaims.class);
    }
}