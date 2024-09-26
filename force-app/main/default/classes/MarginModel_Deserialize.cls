public with sharing class MarginModel_Deserialize {

    public BillingAdjustmentsSummary BILLINGADJUSTMENTS;
    public DirectExpensesSummary DIRECTEXPENSES;
    public MarginAnalysisSummary MARGINDATA;
    public TurnoverSummary TURNOVER;
    public SecondaryServicesSummary SECONDARYSERVICES;
    public TaxBurden TAXBURDEN;
    public ClientBdmData BDM;

	public static MarginModel_Deserialize parse(String json) {
		return (MarginModel_Deserialize) System.JSON.deserialize(json, MarginModel_Deserialize.class);
	}

}