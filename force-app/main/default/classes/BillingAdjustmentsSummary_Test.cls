@isTest
private class BillingAdjustmentsSummary_Test {
	
	static testMethod void parseJson() {
		String json = '{'+
		'  \"CLIENTID\": \"900099\",'+
		'  \"DataList\": ['+
		'    {'+
		'      \"STARTDATE\": \"2015-05-12\",'+
		'      \"ENDDATE\": \"2016-05-11\",'+
		'      \"BILLINGADJUSTMENTS\": 1517.00'+
		'    },'+
		'    {'+
		'      \"STARTDATE\": \"2016-05-12\",'+
		'      \"ENDDATE\": \"2017-05-11\",'+
		'      \"BILLINGADJUSTMENTS\": 308.23'+
		'    }'+
		'  ]'+
		'}';
		BillingAdjustmentsSummary obj = BillingAdjustmentsSummary.parse(json);
		Assert.isTrue(obj != null);
		Assert.isTrue(obj.CLIENTID == '900099');
		Assert.isTrue(obj.DataList.size() == 2);
	}
}