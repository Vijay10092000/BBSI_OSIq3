@isTest
private class WcAndSIdata_Test {
    @isTest static void RequestBody(){

        String reqBody = WcAndSIdata.GetRequestBody(900000, Date.Today().format());

        Assert.isTrue(reqBody != null);
        Assert.isTrue(reqBody.length() > 10);
    }
    @isTest static void parseWcSiData(){
        String json = '{"Client":905158,"WcSiList":[{"StateCode":"CA","WcCode":"0042","IsEligible":1,"EligibleRateSI":1.46},{"StateCode":"CA","WcCode":"0106","IsEligible":1,"EligibleRateSI":4},{"StateCode":"CA","WcCode":"1000","IsEligible":0,"EligibleRateSI":0},{"StateCode":"CA","WcCode":"8810","IsEligible":0,"EligibleRateSI":0}]}';

		WcAndSIdata obj = WcAndSIdata.parse(json);
		Assert.isTrue(obj != null);
        
    }

}