@isTest
private class MarginAnalysisSummary_Test {
	
	static testMethod void testParse() {
		String json = '{"CLIENTID":"900021","DataList":[{"StartDate":"2016-05-12","EndDate":"2017-05-11","MarginSumDataList":[{"STATE":"DE","WCCODE":"5415","MARGIN":135},{"STATE":"CA","WCCODE":"5415","MARGIN":9842.5}]},{"StartDate":"2015-05-12","EndDate":"2016-05-11","MarginSumDataList":[{"STATE":"DE","WCCODE":"5415","MARGIN":120},{"STATE":"CA","WCCODE":"5415","MARGIN":8342.5}]}]}';

		MarginAnalysisSummary obj = MarginAnalysisSummary.parse(json);
		Assert.isTrue(obj != null);
		Assert.isTrue(obj.CLIENTID == '900021');
		Assert.isTrue(obj.DataList.size() == 2);
		Assert.isTrue(obj.DataList[1].MarginSumDataList.size() == 2);
	}
}