@isTest
private class RiskClaimsSiData_Test {
    @isTest static void RequestBody(){

        String reqBody = RiskClaimsSiData.GetRequestBody(900000, Date.Today().format());

        system.assert(reqBody != null);
        system.assert(reqBody.length() > 10);
    }
	@isTest static void parseJson() {
		String json = '{"CLIENT":905158,"STARTDATE":"2017-09-01","DATALIST":[{"Year":"2018","StateCode":"CA","WCBilled":185038,"PremBasedPayroll":3610615.56,"PeriodStartDate":"2017-09-01","TotalIncurred":46427.46,"UltimateExpected":0,"OpenClaims":3,"TotalClaims":10,"Frequency":2.7696,"MaxSI":45009.64},{"Year":"2017","StateCode":"CA","WCBilled":348683.62,"PremBasedPayroll":6780081.1,"PeriodStartDate":"2016-09-01","TotalIncurred":26758.55,"UltimateExpected":0,"OpenClaims":0,"TotalClaims":23,"Frequency":3.3923,"MaxSI":84912.8},{"Year":"2016","StateCode":"CA","WCBilled":256455.01,"PremBasedPayroll":5400383.87,"PeriodStartDate":"2015-09-01","TotalIncurred":85885.69,"UltimateExpected":0,"OpenClaims":1,"TotalClaims":18,"Frequency":3.3331,"MaxSI":63232.39},{"Year":"2014","StateCode":"CA","WCBilled":0,"PremBasedPayroll":0,"PeriodStartDate":"2013-09-01","TotalIncurred":183.92,"UltimateExpected":0,"OpenClaims":0,"TotalClaims":1,"Frequency":0,"MaxSI":0}]}';

		RiskClaimsSiData obj = RiskClaimsSiData.parse(json);
		System.assert(obj != null);
		System.assert(obj.Client == 905158);
		System.assert(obj.StartDate == '2017-09-01');
		System.assert(obj.DataList != null);
		System.assert(obj.DataList.size() > 1);
	}

}