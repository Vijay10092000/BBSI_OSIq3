@isTest
private class RiskAndClaims_Test {
    @isTest static void RequestBody(){

        String reqBody = RiskAndClaims.GetRequestBody(900000, Date.Today().format());

        system.assert(reqBody != null);
        system.assert(reqBody.length() > 10);
    }
    @IsTest static void ParseJson(){
        String json = '{"CLIENT":900199,"STARTDATE":"2017-01-01","DATALIST":[{"Year":"2018","StateCode":"CA","WCBilled":9943.17,"PremBasedPayroll":147223.75,"PeriodStartDate":"2017-01-01","TotalIncurred":0,"UltimateExpected":0,"OpenClaims":0,"TotalClaims":0,"Frequency":0},{"Year":"2017","StateCode":"CA","WCBilled":19461.16,"PremBasedPayroll":369708.79,"PeriodStartDate":"2016-01-01","TotalIncurred":2463.22,"UltimateExpected":0,"OpenClaims":0,"TotalClaims":4,"Frequency":10.82},{"Year":"2016","StateCode":"CA","WCBilled":10610.61,"PremBasedPayroll":248021.75,"PeriodStartDate":"2015-01-01","TotalIncurred":568.38,"UltimateExpected":0,"OpenClaims":0,"TotalClaims":1,"Frequency":4.03},{"Year":"2015","StateCode":"CA","WCBilled":9741.6,"PremBasedPayroll":236328,"PeriodStartDate":"2014-01-01","TotalIncurred":2748.26,"UltimateExpected":0,"OpenClaims":0,"TotalClaims":1,"Frequency":4.23},{"Year":"2014","StateCode":"CA","WCBilled":4306.29,"PremBasedPayroll":168174,"PeriodStartDate":"2013-01-01","TotalIncurred":0,"UltimateExpected":0,"OpenClaims":0,"TotalClaims":0,"Frequency":0},{"Year":"2013","StateCode":"CA","WCBilled":4289.72,"PremBasedPayroll":233142,"PeriodStartDate":"2012-01-01","TotalIncurred":0,"UltimateExpected":0,"OpenClaims":0,"TotalClaims":0,"Frequency":0},{"Year":"2012","StateCode":"CA","WCBilled":3661.74,"PremBasedPayroll":207391.5,"PeriodStartDate":"2011-01-01","TotalIncurred":0,"UltimateExpected":0,"OpenClaims":0,"TotalClaims":0,"Frequency":0},{"Year":"2011","StateCode":"CA","WCBilled":2946.55,"PremBasedPayroll":164313.5,"PeriodStartDate":"2010-01-01","TotalIncurred":0,"UltimateExpected":0,"OpenClaims":0,"TotalClaims":0,"Frequency":0}]}';

        RiskAndClaims obj = RiskAndClaims.parse(json);
    }

}