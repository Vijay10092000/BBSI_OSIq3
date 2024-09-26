@isTest
private class SecondaryServicesSummary_Test {
	
	@isTest static void testParse() {
		String json = '{"CLIENTID":"905384","DATALIST":[{"STARTDATE":"2016-06-08 00:00:00.0","ENDDATE":"2017-06-07 00:00:00.0","SECONDARYSERVICES":-31},{"STARTDATE":"2017-06-15 00:00:00.0","ENDDATE":"2017-06-15 00:00:00.0","SECONDARYSERVICES":0},{"STARTDATE":"1999-12-31 00:00:00.0","ENDDATE":"2017-06-14 00:00:00.0","SECONDARYSERVICES":-31},{"STARTDATE":"2015-06-08 00:00:00.0","ENDDATE":"2016-06-07 00:00:00.0","SECONDARYSERVICES":0},{"STARTDATE":"2014-06-08 00:00:00.0","ENDDATE":"2015-06-07 00:00:00.0","SECONDARYSERVICES":0}]}';
		SecondaryServicesSummary obj = SecondaryServicesSummary.parse(json);
		System.assert(obj.CLIENTID == '905384');
		System.assert(obj.DATALIST.size() == 5);
		System.assert(obj.DATALIST[0].SECONDARYSERVICES == -31);
	}
	
}