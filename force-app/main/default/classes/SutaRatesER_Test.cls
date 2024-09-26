@isTest
private class SutaRatesER_Test {
	
	@isTest static void parseJSON() {
		string json = '{"CLIENTID":"900028","DATALIST":[{"State":"CA","SUTA":6.2,"ETT":0},{"State":"NV","SUTA":3}]}';
		SutaRatesER obj = SutaRatesER.parse(json);

		System.assert(obj.CLIENTID == '900028');
		System.assert(obj.DATALIST != null);
		System.assert(obj.DATALIST.size() == 2);

		System.assert(obj.DATALIST[0].State == 'CA');
		System.assert(obj.DATALIST[0].SUTA == 6.2);
		System.assert(obj.DATALIST[0].ETT == 0);
		System.assert(obj.DATALIST[0].EAF == null);
		System.assert(obj.DATALIST[0].Local == null);

		System.assert(obj.DATALIST[1].State == 'NV');
		System.assert(obj.DATALIST[1].SUTA == 3);
		System.assert(obj.DATALIST[1].ETT == null);
		System.assert(obj.DATALIST[1].EAF == null);
		System.assert(obj.DATALIST[1].Local == null);
	}
	
}