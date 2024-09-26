public with sharing class MarginAnalysisSummary {

	public String CLIENTID;
	public List<DATA> DataList;

	public class DATA {
		public String StartDate;
		public String EndDate;
		public List<MARGINSUMMARYDATA> MarginSumDataList;
	}

	public class MARGINSUMMARYDATA {
		public String STATE;
		public String WCCODE;
		public Decimal MARGIN;
		public Decimal BILLAMT;
		public Decimal WCPREM;
	}

	public static MarginAnalysisSummary parse(String json) {
		return (MarginAnalysisSummary) System.JSON.deserialize(json, MarginAnalysisSummary.class);
	}
}