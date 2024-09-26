public with sharing class XmodHistoryData {

    public Integer Client;
	public List<XmodDetailItem> XmodDetails;

    public Class XmodDetailItem{
        public String Year;
        public String StateCode;
        public String ModifiedDate;
        public double Xmod;
    }

	public static String GetRequestBody(Integer clientId, String contractStartDate){
        String template = '\"CLIENT\":{0},\"STARTDATE\":\"{1}\"';
        List<String> args = new String[]{String.valueOf(clientId), contractStartDate};
        return '{' + String.format(template, args) + '}';
    }
    

	public static XmodHistoryData parse(String json) {
		return (XmodHistoryData) System.JSON.deserialize(json, XmodHistoryData.class);
	}

}