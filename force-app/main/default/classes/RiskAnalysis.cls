public with sharing class RiskAnalysis  {

	public String CLIENTID;
	public List<DATA> DATALIST;

	public class DATA {
		public String STARTDATE;
		public String ENDDATE;
		public List<RiskAnalysisSummary>RISKANALYSISLIST{get; Private set;}
	}
	public Class RiskAnalysisSummary{
		public String STATE {get; Private set;}
		public Double WCBILLED {get; Private set;}
		public Double PREMBASEDPAYROLL {get; Private set;}
	}
	public static RiskAnalysis  parse(String json) {
        system.debug('RiskAnalysis json:' +json);
		return (RiskAnalysis) System.JSON.deserialize(json, RiskAnalysis.class);
	}
}