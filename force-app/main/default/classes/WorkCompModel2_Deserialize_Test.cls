@IsTest
private class WorkCompModel2_Deserialize_Test {
	@IsTest 
	static void test_method_one() {

		String json = '{"SAFETYINCENTIVE":{"CLIENT":"900001","RUNDATE":"2017-07-31 00:00:00.0","DATALIST":[{"StartDate":"2017-01-01 00:00:00.0","EndDate":"2017-12-31 00:00:00.0","EligiblePR":86078.62,"MaxSI":895.22,"Losses":19390.9,"ProfServices":925,"ModWork":0,"SIEarned":-19420.68,"AmountPaid":0,"Status":"InYear"},{"StartDate":"2016-01-01 00:00:00.0","EndDate":"2016-12-31 00:00:00.0","EligiblePR":151239.61,"MaxSI":1572.89,"Losses":0,"ProfServices":0,"ModWork":0,"SIEarned":1572.89,"PaidDate":"2017-02-27 00:00:00.0","AmountPaid":1572.89,"Status":" "},{"StartDate":"2015-01-01 00:00:00.0","EndDate":"2015-12-31 00:00:00.0","EligiblePR":160434.34,"MaxSI":1668.52,"Losses":52260.79,"ProfServices":1205,"ModWork":0,"SIEarned":-51797.27,"AmountPaid":0,"Status":" "}]},"XMODHISTORY":{"CLIENTID":"900001","DATALIST":[{"STARTDATE":"2017-01-01 00:00:00.0","ENDDATE":"2017-12-31 00:00:00.0","XMODLIST":[{"STATE":"DE","XMOD":1}]},{"STARTDATE":"2016-01-01 00:00:00.0","ENDDATE":"2016-12-31 00:00:00.0","XMODLIST":[{"STATE":"DE","XMOD":1}]},{"STARTDATE":"2015-01-01 00:00:00.0","ENDDATE":"2015-12-31 00:00:00.0","XMODLIST":[{"STATE":"DE","XMOD":1}]}]}}';

		WorkCompModel2_Deserialize obj = WorkCompModel2_Deserialize.parse(json);

		Assert.isTrue(obj != null);
		Assert.isTrue(obj.SAFETYINCENTIVE != null);
		Assert.isTrue(obj.SAFETYINCENTIVE.Client == '900001');
		Assert.isTrue(obj.SAFETYINCENTIVE.RunDate == '2017-07-31 00:00:00.0');
	}
}