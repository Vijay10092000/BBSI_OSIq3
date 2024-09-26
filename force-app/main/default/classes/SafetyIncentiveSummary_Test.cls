@isTest
private class SafetyIncentiveSummary_Test {
	
	@isTest static void test_method_one() {
		String json = '{"CLIENT":"900001","RUNDATE": "2017-05-31 00:00:00.0","DATALIST":[{"StartDate":"2017-01-01 00:00:00.0","EndDate":"2017-12-31 00:00:00.0","EligiblePR":58819.84,"MaxSI":611.73,"Losses":19390.9,"ProfServices":925,"ModWork":0,"SIEarned":-19704.17,"AmountPaid":0,"Status":"InYear"},{"StartDate":"2016-01-01 00:00:00.0","EndDate":"2016-12-31 00:00:00.0","EligiblePR":151239.61,"MaxSI":1572.89,"Losses":0,"ProfServices":0,"ModWork":0,"SIEarned":1572.89,"PaidDate":"2017-02-27 00:00:00.0","AmountPaid":1572.89,"Status":" "},{"StartDate":"2015-01-01 00:00:00.0","EndDate":"2015-12-31 00:00:00.0","EligiblePR":160434.34,"MaxSI":1668.52,"Losses":52260.79,"ProfServices":1205,"ModWork":0,"SIEarned":-51797.27,"AmountPaid":0,"Status":" "}]}';
	
		SafetyIncentiveSummary obj = SafetyIncentiveSummary.parse(json);
		
		System.assert(obj != null);
		System.assert(obj.Client == '900001');
		System.assert(obj.RunDate.length() > 0);
		System.assert(obj.DataList.size() == 3);
		System.assert(obj.DataList[0].StartDate.length() > 0);
		System.assert(obj.DataList[0].EndDate.length() > 0);
		System.assert(obj.DataList[0].EligiblePR == 58819.84);
		System.assert(obj.DataList[0].MaxSI == 611.73);
		System.assert(obj.DataList[0].Losses == 19390.9);
		System.assert(obj.DataList[0].ProfServices == 925);
		System.assert(obj.DataList[0].ModWork == 0);
		System.assert(obj.DataList[0].SIEarned == -19704.17);
		System.assert(obj.DataList[0].AmountPaid == 0);
		System.assert(obj.DataList[0].PaidDate == null);
		System.assert(obj.DataList[0].Status == 'InYear');
	}
	
}