public with sharing class PricingDataModelAggregateData {

	public PayWcEstimate PAYWCESTIMATES;
	public XmodHistory XMOD;
	public SutaRatesER SUTARATES;
	public WorkCompRatesER WCRATES;

	public static PricingDataModelAggregateData parse(String json) {
		return (PricingDataModelAggregateData) System.JSON.deserialize(json, PricingDataModelAggregateData.class);
	}
}