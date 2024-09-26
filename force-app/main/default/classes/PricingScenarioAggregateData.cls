public without sharing class PricingScenarioAggregateData {

    public MarginAnalysisSummary MARGINDATA;
    public TaxBurden TAXBURDEN;
    //public DirectExpensesSummary DIRECTEXPENSES;
    public SafetyIncentiveSummary SISUMMARY;
	public CommissionRateDetailData COMMRATEDETAIL;
    public ClientBdmData BDM;

	public static PricingScenarioAggregateData parse(String json) {
		return (PricingScenarioAggregateData) System.JSON.deserialize(json, PricingScenarioAggregateData.class);
	}
}