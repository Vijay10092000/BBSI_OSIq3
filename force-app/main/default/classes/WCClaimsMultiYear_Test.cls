@isTest
private class WCClaimsMultiYear_Test {
    @isTest static void RequestBody(){

        String reqBody = WCClaimsMultiYear.GetRequestBody(900000, Date.Today().format());

        Assert.isTrue(reqBody != null);
        Assert.isTrue(reqBody.length() > 10);
    }

    @isTest static void test_method_one() {
        String json = '{"CLIENT":905158,"STARTDATE":"2017-09-01","DATALIST":[{"Year":"2018","StateCode":"CA","PeriodStartDate":"2017-09-01","TotalIncurred":46427.46,"OpenClaims":3,"TotalClaims":10},{"Year":"2017","StateCode":"CA","PeriodStartDate":"2016-09-01","TotalIncurred":26758.55,"OpenClaims":0,"TotalClaims":23},{"Year":"2016","StateCode":"CA","PeriodStartDate":"2015-09-01","TotalIncurred":85885.69,"OpenClaims":1,"TotalClaims":18},{"Year":"2014","StateCode":"CA","PeriodStartDate":"2013-09-01","TotalIncurred":183.92,"OpenClaims":0,"TotalClaims":1}]}';

        WCClaimsMultiYear obj = WCClaimsMultiYear.parse(json);

		Assert.isTrue(obj != null);
		Assert.isTrue(obj.CLIENT == 905158);
		Assert.isTrue(obj.DataList.size() == 4);
		Assert.isTrue(obj.DataList[0] != null);
		Assert.isTrue(obj.DataList[0].Year == '2018');
		Assert.isTrue(obj.DataList[0].PeriodStartDate == '2017-09-01');
		Assert.isTrue(obj.DataList[0].TotalIncurred == 46427.46);
		Assert.isTrue(obj.DataList[0].TotalClaims == 10);
        Assert.isTrue(obj.DataList[0].TotalIncurredLdf == null);
    }
}