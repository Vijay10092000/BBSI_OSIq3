@isTest
private class TaxBurden_Test {
	
	@isTest static void testParse() {
		String json = '{"CLIENTID":"900022","DATALIST":[{"STARTDATE":"2016-05-12 00:00:00.0","ENDDATE":"2017-05-12 00:00:00.0","TotalPayroll":295102.67,"TotalTaxes":27373.86,"TotalPayrollNo1000":295102.67,"TotalTaxesNo1000":27373.86},{"STARTDATE":"2015-05-12 00:00:00.0","ENDDATE":"2016-05-12 00:00:00.0","TotalPayroll":301292.4,"TotalTaxes":26912.87,"TotalPayrollNo1000":296132.24,"TotalTaxesNo1000":26912.87}]}';
		TaxBurden obj = TaxBurden.parse(json);
		System.assert(obj.CLIENTID == '900022');
		System.assert(obj.DATALIST.size() == 2);
		System.assert(obj.DATALIST[0].TotalPayroll == 295102.67);
	}
}