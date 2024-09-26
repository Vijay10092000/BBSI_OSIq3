@isTest
public with sharing class ExmodsICdata_Test {

    @isTest
    static void createErPayrollTaxes() {
        String json = '{"ExMods":[{"year":2018,"calc_date":"2017-12-21","exmod":82,"exmod_status":"(N) New Entry"},{"year":2017,"calc_date":"2016-12-08","exmod":89,"exmod_status":"(R) Revised Entry"},{"year":2016,"calc_date":"2016-04-21","exmod":127,"exmod_status":""},{"year":2015,"calc_date":"2015-05-07","exmod":130,"exmod_status":"(N)                   New Entry"},{"year":2014,"calc_date":"2014-05-08","exmod":null,"exmod_status":"(I) Insufficient Premium"}],"BureauReportUrl":"https://exmod.com/Employer?EmployerFilter=6344038"}';
        ExmodsICdata obj = ExmodsICdata.parse(json);
        Assert.isTrue(obj != null);

        Assert.isTrue(obj.ExMods.size() == 5);

        Assert.isTrue(obj.ExMods[0].year == 2018);
        Assert.isTrue(obj.ExMods[0].calc_date == '2017-12-21');
        Assert.isTrue(obj.ExMods[0].year == 2018);

        Assert.isTrue(obj.ExMods[3].year == 2015);
        Assert.isTrue(obj.ExMods[3].exmod == 130);
        Assert.isTrue(obj.ExMods[3].Xmod == 1.3);
        Assert.isTrue(obj.ExMods[3].XmodStatus == '(N) New Entry');

        Assert.isTrue(obj.ExMods[4].exmod == null);
        Assert.isTrue(obj.ExMods[4].Xmod == null);

    }

    @isTest
    static void testApiUrl() {
        Assert.areEqual('/getExmodReport?fein=', ExmodsICdata.ApiUrl);
    }
    
    @isTest
    static void testExModItem_StateCode() {
        ExmodsICdata.ExModItem item = new ExmodsICdata.ExModItem();
        Assert.areEqual('CA', item.StateCode);
    }
    
    @isTest
    static void testExModItem_Xmod() {
        ExmodsICdata.ExModItem item = new ExmodsICdata.ExModItem();
        
        Assert.areEqual(null, item.Xmod);
        
        item.exmod = 0;        
        Assert.areEqual(0.0, item.XMod);
        
        item.exmod = 78;        
        Assert.areEqual(0.78, item.XMod);
    }
    
    @isTest
    static void testExModItem_XmodStatus() {
        ExmodsICdata.ExModItem item = new ExmodsICdata.ExModItem();
        
        item.exmod_status = null;
        Assert.areEqual('', item.XmodStatus);
        
        item.exmod_status = '';
        Assert.areEqual('', item.XmodStatus);
        
        item.exmod_status = 'STATUS     ';
        Assert.areEqual('STATUS ', item.XmodStatus);
    }
    
    @isTest
    static void testBureauNumber() {
        ExmodsICdata icData = new ExmodsICdata();
        
        icData.BureauReportUrl = null;
        Assert.areEqual(0, icData.BureauNumber);
        
        icData.BureauReportUrl = 'A String with No Numbers';
        Assert.areEqual(0, icData.BureauNumber);
        
        icData.BureauReportUrl = 'A Str1ng w1th Numb3rs';
       Assert.areEqual(113, icData.BureauNumber);
        
        icData.BureauReportUrl = 'Anoth3r \\Str1ng [w1th Numb3rs} and -, Symb01s';
       Assert.areEqual(311301, icData.BureauNumber);
    }

}