@isTest
private class WCClaims_Test {
	
	@isTest static void test_method_one() {
		String json = '{"CLIENTID":"905158","DATALIST":[{"StartDate":"2016-06-08 00:00:00.0","EndDate":"2017-06-07 00:00:00.0","CLAIMSDATALIST":[{"STATE":"CA","LTCLAIMS":2,"LTINCURRED":53616.68,"MOCLAIMS":18,"MOINCURRED":49810.37,"FAIDCLAIMS":2,"FAIDINCURRED":737.25,"OPENCLAIMS":5,"TOTALCLAIMS":22,"TOTALINCURRED":104164.3}]},{"StartDate":"2017-06-15 00:00:00.0","EndDate":"2017-06-15 00:00:00.0","CLAIMSDATALIST":[{"STATE":"none","LTCLAIMS":0,"LTINCURRED":0,"MOCLAIMS":0,"MOINCURRED":0,"FAIDCLAIMS":0,"FAIDINCURRED":0,"OPENCLAIMS":0,"TOTALCLAIMS":0,"TOTALINCURRED":0}]},{"StartDate":"1999-12-31 00:00:00.0","EndDate":"2017-06-14 00:00:00.0","CLAIMSDATALIST":[{"STATE":"CA        ","LTCLAIMS":3,"LTINCURRED":54223.76,"MOCLAIMS":29,"MOINCURRED":65002.02,"FAIDCLAIMS":4,"FAIDINCURRED":1279.74,"OPENCLAIMS":5,"TOTALCLAIMS":36,"TOTALINCURRED":120505.52}]},{"StartDate":"2015-06-08 00:00:00.0","EndDate":"2016-06-07 00:00:00.0","CLAIMSDATALIST":[{"STATE":"CA        ","LTCLAIMS":1,"LTINCURRED":607.08,"MOCLAIMS":10,"MOINCURRED":15007.73,"FAIDCLAIMS":2,"FAIDINCURRED":542.49,"OPENCLAIMS":0,"TOTALCLAIMS":13,"TOTALINCURRED":16157.3}]},{"StartDate":"2014-06-08 00:00:00.0","EndDate":"2015-06-07 00:00:00.0","CLAIMSDATALIST":[{"STATE":"none","LTCLAIMS":0,"LTINCURRED":0,"MOCLAIMS":0,"MOINCURRED":0,"FAIDCLAIMS":0,"FAIDINCURRED":0,"OPENCLAIMS":0,"TOTALCLAIMS":0,"TOTALINCURRED":0}]}]}';

		WCClaims obj = WCClaims.parse(json);
		
		Assert.isTrue(obj != null);
		Assert.isTrue(obj.CLIENTID == '905158');
		Assert.isTrue(obj.DataList.size() == 5);
		Assert.isTrue(obj.DataList[0] != null);
		Assert.isTrue(obj.DataList[0].StartDate.length() > 0);
		Assert.isTrue(obj.DataList[0].ClaimsDataList.size() == 1);
		Assert.isTrue(obj.DataList[0].ClaimsDataList[0].State == 'CA');
		Assert.isTrue(obj.DataList[0].ClaimsDataList[0].LTClaims == 2);
		Assert.isTrue(obj.DataList[0].ClaimsDataList[0].LTIncurred == 53616.68);
		Assert.isTrue(obj.DataList[0].ClaimsDataList[0].MOClaims == 18);
		Assert.isTrue(obj.DataList[0].ClaimsDataList[0].MOIncurred == 49810.37);
		Assert.isTrue(obj.DataList[0].ClaimsDataList[0].FAIDClaims == 2);
		Assert.isTrue(obj.DataList[0].ClaimsDataList[0].FAIDIncurred == 737.25);
		Assert.isTrue(obj.DataList[0].ClaimsDataList[0].OpenClaims == 5);
		Assert.isTrue(obj.DataList[0].ClaimsDataList[0].TotalClaims == 22);
		Assert.isTrue(obj.DataList[0].ClaimsDataList[0].TOTALIncurred == 104164.30);
	}
}