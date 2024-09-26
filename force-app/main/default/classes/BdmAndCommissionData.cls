public with sharing class BdmAndCommissionData {

	public Integer Client;
	public String StartDate;
	public String HasBdm;
	public String BdmName;
	public List<DataItem> DataList;

	public class DataItem {
		public String Year;
		public String Acronym;
		public String Company;
		public String MinDate;
		public String MaxDate;
		public Double CommRate;
		public Double CommAmt;
	}

	public static String GetRequestBody(Integer clientId, String contractStartDate){
        String template = '\"CLIENT\":{0},\"STARTDATE\":\"{1}\"';
        List<String> args = new String[]{String.valueOf(clientId), contractStartDate};
        return '{' + String.format(template, args) + '}';
    }
    
	public static BdmAndCommissionData parse(String json) {
		return (BdmAndCommissionData) System.JSON.deserialize(json, BdmAndCommissionData.class);
	}
    
}