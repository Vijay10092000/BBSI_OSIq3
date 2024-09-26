public with sharing class XmodHistory {
	
	public String CLIENTID;
	public List<XmodData> DATALIST;

	public Class XmodData{
		public String STARTDATE;
		public String ENDDATE;
		public List<XmodSummary> XMODLIST;
	}
	public Class XmodSummary{
		public String STATE;
		public Decimal XMOD;
	}

	public static XmodHistory parse(String json) {
		return (XmodHistory) System.JSON.deserialize(json, XmodHistory.class);
	}
}