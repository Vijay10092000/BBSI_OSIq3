@isTest
private class DirectExpensesSummary_Test {
	
	static testMethod void testParse() {
		String json = '{'+
		'  \"CLIENTID\": \"900099\",'+
		'  \"DIRECTEXPENSES\": ['+
		'    {'+
		'      \"STARTDATE\": \"2015-05-12\",'+
		'      \"ENDDATE\": \"2016-05-11\",'+
		'      \"COMMISSIONAMT\": 165137.74'+
		'    },'+
		'    {'+
		'      \"STARTDATE\": \"2016-05-12\",'+
		'      \"ENDDATE\": \"2017-05-11\",'+
		'      \"COMMISSIONAMT\": 36208.23'+
		'    }'+
		'  ]'+
		'}';
		DirectExpensesSummary obj = DirectExpensesSummary.parse(json);
		Assert.isTrue(obj != null);
	}
}