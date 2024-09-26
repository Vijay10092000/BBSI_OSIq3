@isTest
private class BdmAndCommissionData_Test {
    @isTest static void RequestBody(){

        String reqBody = BdmAndCommissionData.GetRequestBody(900000, Date.Today().format());

        Assert.isTrue(reqBody != null);
        Assert.isTrue(reqBody.length() > 10);
    }

	@isTest static void parseJson() {
		String json = '{"CLIENT":905158,"STARTDATE":"2017-09-01","HasBdm":"TRUE","BdmName":"Roger Reedy","DATALIST":[{"Year":"2018","Acronym":"9950","Company":"BOZZUTO & ASSOCIATES INSURANCE SERVICES, INC.","MinDate":"2017-09-01 00:00:00.0","MaxDate":"2018-01-31 00:00:00.0","CommRate":0.117,"CommAmt":19746.96},{"Year":"2017","Acronym":"9950","Company":"BOZZUTO & ASSOCIATES INSURANCE SERVICES, INC.","MinDate":"2016-09-01 00:00:00.0","MaxDate":"2017-12-31 00:00:00.0","CommRate":0.115,"CommAmt":43871.45},{"Year":"2016","Acronym":"9950","Company":"BOZZUTO & ASSOCIATES INSURANCE SERVICES, INC.","MinDate":"2015-10-09 00:00:00.0","MaxDate":"2016-08-31 00:00:00.0","CommRate":0.1123,"CommAmt":28784.03},{"Year":"2015","Acronym":"9950","Company":"BOZZUTO & ASSOCIATES INSURANCE SERVICES, INC.","MinDate":"2015-01-01 00:00:00.0","MaxDate":"2015-12-31 00:00:00.0","CommRate":0,"CommAmt":708.31}]}';

		BdmAndCommissionData obj = BdmAndCommissionData.parse(json);
		Assert.isTrue(obj != null);
		Assert.isTrue(obj.Client == 905158);
		Assert.isTrue(obj.HasBdm == 'TRUE');
		Assert.isTrue(obj.BdmName == 'Roger Reedy');
		Assert.isTrue(obj.DataList != null);
		Assert.isTrue(obj.DataList.size() > 1);
	}

}