public with sharing class PayrollHistoryDataSum {

	public Integer Client;
	public String StartDate;
	public List<DataItem> Data;
	
    public class DataItem {
		public String Year;
		public String MinDate;
		public String MaxDate;
		public Double BillAmt;
		public Double PayAmt;
		public Double PremPayAmt;
		public Double TaxablePayAmt;
		public Double ErTaxes;
		public Double WcPremiums;
		public Double BillAdj;
		public Double HoursWorked;
	}
	
	public static String GetRequestBody(Integer clientId, String contractStartDate){
        String template = '\"CLIENT\":{0},\"STARTDATE\":\"{1}\"';
        List<String> args = new String[]{String.valueOf(clientId), contractStartDate};
        return '{' + String.format(template, args) + '}';
    }
    
	public static PayrollHistoryDataSum parse(String json) {
		return (PayrollHistoryDataSum) System.JSON.deserialize(json, PayrollHistoryDataSum.class);
	}
}