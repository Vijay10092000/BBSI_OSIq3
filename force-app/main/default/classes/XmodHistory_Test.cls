@isTest
private class XmodHistory_Test {
	
	@isTest static void testParse() {
		String json = '{"CLIENTID":"903961","DATALIST":[{"STARTDATE":"2016-08-11 00:00:00.0","ENDDATE":"2017-08-10 00:00:00.0","XMODLIST":[{"STATE":"OR","XMOD":1}]},{"STARTDATE":"2015-08-11 00:00:00.0","ENDDATE":"2016-08-10 00:00:00.0","XMODLIST":[{"STATE":"OR","XMOD":1}]},{"STARTDATE":"2014-08-11 00:00:00.0","ENDDATE":"2015-08-10 00:00:00.0","XMODLIST":[{"STATE":"CO","XMOD":1},{"STATE":"OR","XMOD":1}]}]}';
		XmodHistory obj = XmodHistory.parse(json);
		Assert.isTrue(obj.CLIENTID == '903961');
		Assert.isTrue(obj.DATALIST.size() == 3);
		Assert.isTrue(obj.DATALIST[0].XMODLIST[0].XMOD == 1);
	}
}