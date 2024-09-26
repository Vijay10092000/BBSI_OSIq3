@isTest
private class CommissionRateDetailData_Test {
	
	@isTest static void ParseAndRead() {
		String json = '{"CLIENTID":907115,"DATALIST":[{"Acronym":"9252","Company":"T/A Allen Insurance Group (DBA of Allen Ins Assoc)","TypeBegin":"2017-02-17 00:00:00.0","TypeEnd":"2017-11-30 00:00:00.0","CommissionType":"PERCHK","CommissionRate":2,"CommissionAmt":326,"Blended":1,"CommBasis":1.0,"ChksInPeriod":163,"WksInPeriod":41}]}';
		CommissionRateDetailData obj = CommissionRateDetailData.parse(json);
		
		System.assert(obj != null);
		System.assert(obj.CLIENTID == '907115');
		System.assert(obj.DataList[0].Acronym == '9252');
		System.assert(obj.DataList[0].Company == 'T/A Allen Insurance Group (DBA of Allen Ins Assoc)');
		System.assert(obj.DataList[0].CommissionType == 'PERCHK');
		System.assert(obj.DataList[0].CommissionRate == 2);
		System.assert(obj.DataList[0].CommissionAmt == 326);
		System.assert(obj.DataList[0].ChksInPeriod == 163);
		System.assert(obj.DataList[0].WksInPeriod == 41);
		System.assertEquals(true, obj.HasRefPartner);
		System.assertEquals(true, obj.HasValidRefPartner);
		System.assertEquals(true, obj.HasValidCommRate);
		json = '{"CLIENTID":907115,"DATALIST":[{"Acronym":"","Company":"T/A Allen Insurance Group (DBA of Allen Ins Assoc)","TypeBegin":"2017-02-17 00:00:00.0","TypeEnd":"2017-11-30 00:00:00.0","CommissionType":"PERCHK","CommissionRate":2,"CommissionAmt":326,"Blended":1,"CommBasis":1.0,"ChksInPeriod":163,"WksInPeriod":41}]},{"Acronym":"9252","Company":"T/A Allen Insurance Group (DBA of Allen Ins Assoc)","TypeBegin":"2017-02-17 00:00:00.0","TypeEnd":"2017-11-30 00:00:00.0","CommissionType":"PERCHK","CommissionRate":2,"CommissionAmt":326,"Blended":1,"CommBasis":1.0,"ChksInPeriod":163,"WksInPeriod":41},{"Acronym":"9251","Company":"T/A Allen Insurance Group (DBA of Allen Ins Assoc)","TypeBegin":"2017-02-17 00:00:00.0","TypeEnd":"2017-11-30 00:00:00.0","CommissionType":"PERCHK","CommissionRate":2,"CommissionAmt":326,"Blended":1,"CommBasis":1.0,"ChksInPeriod":163,"WksInPeriod":41}';
		obj = CommissionRateDetailData.parse(json);
		System.assertEquals(false, obj.HasValidRefPartner);
		json = '{"CLIENTID":907115,"DATALIST":[{"Acronym":"9252","Company":"T/A Allen Insurance Group (DBA of Allen Ins Assoc)","TypeBegin":"2017-02-17 00:00:00.0","TypeEnd":"2017-11-30 00:00:00.0","CommissionType":"PERCHK","CommissionRate":2,"CommissionAmt":326,"Blended":1,"CommBasis":1.0,"ChksInPeriod":163,"WksInPeriod":41},{"Acronym":"9251","Company":"T/A Allen Insurance Group (DBA of Allen Ins Assoc)","TypeBegin":"2017-02-17 00:00:00.0","TypeEnd":"2017-11-30 00:00:00.0","CommissionType":"PERCHK","CommissionRate":2,"CommissionAmt":326,"Blended":1,"CommBasis":1.0,"ChksInPeriod":163,"WksInPeriod":41},{"Acronym":"","Company":"T/A Allen Insurance Group (DBA of Allen Ins Assoc)","TypeBegin":"2017-02-17 00:00:00.0","TypeEnd":"2017-11-30 00:00:00.0","CommissionType":"PERCHK","CommissionRate":2,"CommissionAmt":326,"Blended":1,"CommBasis":1.0,"ChksInPeriod":163,"WksInPeriod":41}]}';
		obj = CommissionRateDetailData.parse(json);
		System.assertEquals(false, obj.HasValidRefPartner);
	}
}