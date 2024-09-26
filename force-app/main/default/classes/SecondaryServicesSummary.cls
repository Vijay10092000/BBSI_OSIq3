public with sharing class SecondaryServicesSummary {

	public String CLIENTID;
	public List<SecondaryServicesData> DATALIST;

	public Class SecondaryServicesData{
		public String STARTDATE;
		public String ENDDATE;
		public Decimal SECONDARYSERVICES;
	}

	public static SecondaryServicesSummary parse(String json) {
		return (SecondaryServicesSummary) System.JSON.deserialize(json, SecondaryServicesSummary.class);
	}
}