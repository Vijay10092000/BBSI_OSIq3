@isTest
private class TurnoverSummary_Test {
	
	static testMethod void parseJson() {
		String json = '{'+
		'    \"CLIENTID\": \"900021\",'+
		'    \"DataList\": ['+
		'      {'+
		'        \"STARTDATE\": \"2016-05-12\",'+
		'        \"ENDDATE\": \"2017-05-11\",'+
		'        \"EEANNUAL\": 12,'+
		'        \"EECURRENT\": 8'+
		'      },'+
		'      {'+
		'        \"STARTDATE\": \"2015-05-12\",'+
		'        \"ENDDATE\": \"2016-05-11\",'+
		'        \"EEANNUAL\": 14,'+
		'        \"EECURRENT\": 7'+
		'      }'+
		'    ]'+
		'  }';
		TurnoverSummary obj = TurnoverSummary.parse(json);
		System.assert(obj != null);
		System.assert(obj.CLIENTID == '900021');
		System.assert(obj.DataList.size() == 2);

	}
}