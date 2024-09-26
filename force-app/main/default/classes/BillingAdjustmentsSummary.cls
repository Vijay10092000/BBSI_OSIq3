public with sharing class BillingAdjustmentsSummary {

	public String CLIENTID;
	public List<DATA> DataList;

	public class DATA {
		public String STARTDATE;
		public String ENDDATE;
		public Double BILLINGADJUSTMENTS;
	}
	
	public static BillingAdjustmentsSummary parse(String json) {
		return (BillingAdjustmentsSummary) System.JSON.deserialize(json, BillingAdjustmentsSummary.class);
	}
}