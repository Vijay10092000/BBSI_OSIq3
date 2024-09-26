@isTest
private class XmodHistoryData_Test {
    @isTest static void RequestBody(){

        String reqBody = XmodHistoryData.GetRequestBody(900000, Date.Today().format());

        Assert.isTrue(reqBody != null);
        Assert.isTrue(reqBody.length() > 10);
    }
    @isTest static void ParseJson(){

        String json = '{"Client":904611,"XmodDetails":[{"Year":"2017","StateCode":"MD","ModifiedDate":"2016-05-01 00:00:00.0","Xmod":1},{"Year":"2016","StateCode":"MD","ModifiedDate":"2015-05-01 00:00:00.0","Xmod":1.1}]}';

        XmodHistoryData obj = XmodHistoryData.parse(json);

        Assert.isTrue(obj != null);
        Assert.isTrue(obj.Client != null);
        Assert.isTrue(obj.XmodDetails != null);
        Assert.isTrue(obj.XmodDetails.size() > 1);
        
        Assert.isTrue(obj.XmodDetails[0].Year == '2017');
        Assert.isTrue(obj.XmodDetails[0].StateCode.length() == 2);
        Assert.isTrue(obj.XmodDetails[0].ModifiedDate != null);
        Assert.isTrue(obj.XmodDetails[0].Xmod >= 0 || obj.XmodDetails[0].Xmod < 0);
    }
}