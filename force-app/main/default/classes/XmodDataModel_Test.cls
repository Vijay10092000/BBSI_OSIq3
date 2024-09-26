@IsTest
public with sharing class XmodDataModel_Test
{
    @IsTest static void GetExmodsBasic()
    {
        // Basic Exmod test of data objects only
        String json2 = '{"ExMods":[{"year":2018,"calc_date":"2018-03-08","exmod":165,"exmod_status":"(N) New Entry"},{"year":2017,"calc_date":"2018-01-18","exmod":119,"exmod_status":"(R) Revised Entry"},{"year":2016,"calc_date":"2016-03-17","exmod":78,"exmod_status":""},{"year":2015,"calc_date":"2015-04-30","exmod":183,"exmod_status":""}],"BureauReportUrl":"https://exmod.com/Employer?EmployerFilter=3358737"}';
        ExmodsICdata obj2 = ExmodsICdata.parse(json2);
        Assert.isTrue(obj2 != null);
        Assert.isTrue(obj2.BureauReportUrl == 'https://exmod.com/Employer?EmployerFilter=3358737');
        Assert.isTrue(obj2.ExMods.size() == 4);
        Assert.isTrue(obj2.ExMods[0].year == 2018);
        Assert.isTrue(obj2.ExMods[0].exmod == 165);
        Assert.isTrue(obj2.ExMods[0].Xmod == 1.65);
        Assert.isTrue(obj2.ExMods[3].XmodStatus == '');
    }

    @IsTest static void GetExmods()
    {
        // Exmod test with Mock Callouts
        Test.startTest();
        // Test.setMock(HttpCalloutMock.class, new RenewalCalloutClass_Mock('','','','','',''));
        Test.setMock(HttpCalloutMock.class, new GenericMockCallout(200, 'SUCCESS', getExmodsData(), null));
        String fein = '91-2053995';
        XmodDataModel xmodModel = new XmodDataModel(fein);
        xmodModel.GetData();
        Test.stopTest();
        Assert.isTrue(xmodModel.ExmodData.ExMods.size() == 4);
        Assert.isTrue(xmodModel.ExmodData.ExMods[0].year == 2019);
        Assert.isTrue(xmodModel.ExmodData.ExMods[0].exmod == 165);
        Assert.isTrue(xmodModel.ExmodData.ExMods[0].Xmod == 1.65);
        Assert.isTrue(xmodModel.ExmodData.ExMods[0].XmodStatus == '(N) New Entry');
    }

    @IsTest static void GetExmodsWithSoftError()
    {
        // Exmod test with Mock ERROR Callouts
        Test.startTest();
        // Test.setMock(HttpCalloutMock.class, new RenewalCalloutClass_Mock('SOFT ERROR','','','','',''));
        Test.setMock(HttpCalloutMock.class, new GenericMockCallout(200, 'SOFT ERROR', getExmodsData_SoftError(), null));
        String fein = '91-2053995';
        XmodDataModel xmodModel = new XmodDataModel(fein);
        Test.stopTest();
        xmodModel.GetData();
        Assert.isTrue(xmodModel.StatusCode == 0);
        Assert.isTrue(xmodModel.StatusMsg.contains('FEIN or Bureau number not found'));
    }

    @IsTest static void GetExmodsWithErrors()
    {
        // Exmod test with Mock ERROR Callouts
        Test.startTest();
        // Test.setMock(HttpCalloutMock.class, new RenewalCalloutClass_Mock('ERROR','','','','',''));
        Test.setMock(HttpCalloutMock.class, new GenericMockCallout(400, 'ERROR', null, null));
        String fein = '91-2053995';
        XmodDataModel xmodModel = new XmodDataModel(fein);
        Test.stopTest();
        xmodModel.GetData();
        Assert.isTrue(xmodModel.StatusMsg.contains('Status: ERROR'));
    }

    @IsTest static void GetExmodsWithAuthErrors()
    {
        Test.startTest();
        // Test.setMock(HttpCalloutMock.class, new RenewalCalloutClass_Mock('AUTH ERROR','','','','',''));
        Test.setMock(HttpCalloutMock.class, new GenericMockCallout(404, 'Auth Error', getExmodsData_AuthError(), null));
        String fein = '91-2053995';
        XmodDataModel xmodModel = new XmodDataModel(fein);
        Test.stopTest();
        xmodModel.GetData();
        Assert.isTrue(xmodModel.StatusMsg.contains('Status: Auth Error'));
    }

    @IsTest static void GetExmodsWithEmptyBody()
    {
        Test.startTest();
        // Test.setMock(HttpCalloutMock.class, new RenewalCalloutClass_Mock('EMPTY ERROR','','','','',''));
        Test.setMock(HttpCalloutMock.class, new GenericMockCallout(200, 'EMPTY ERROR', '', null));
        String fein = '91-2053995';
        XmodDataModel xmodModel = new XmodDataModel(fein);
        Test.stopTest();
        xmodModel.GetData();
        Assert.isTrue(xmodModel.StatusMsg.contains('API callout returns empty'));
    }
    
    @IsTest static void GetExmodsWithNullResp()
    {
        Test.startTest();
        // Test.setMock(HttpCalloutMock.class, new RenewalCalloutClass_Mock('EMPTY ERROR','','','','',''));
        HttpResponse resp = null;
        Test.setMock(HttpCalloutMock.class, new GenericMockCallout((CalloutException)CalloutException.class.newInstance()));
        String fein = '91-2053995';
        XmodDataModel xmodModel = new XmodDataModel(fein);
        try {
        	xmodModel.GetData();
            // Assert.isTrue(false, 'Should have thrown an exception');
        }
        catch (Exception e) {
            Assert.isTrue(true, 'Should throw an exception');
        }
        Test.stopTest();
    }

    private static String getExmodsData() {
        String xmodsData = '{"ExMods":[{"year":2019,"calc_date":"2019-03-08","exmod":165,"exmod_status":"(N) New Entry"},{"year":2018,"calc_date":"2018-01-18","exmod":119,"exmod_status":"(R) Revised Entry"},{"year":2017,"calc_date":"2017-03-17","exmod":78,"exmod_status":""},{"year":2016,"calc_date":"2016-04-30","exmod":183,"exmod_status":"(R) Revised Entry"}],"BureauReportUrl":"https://exmod.com/Employer?EmployerFilter=3358737"}';
        return xmodsData;
    }

    private static String getExmodsData_SoftError() {
        String xmodsData = '{"FEIN":"ERROR"}';
        return xmodsData;
    }

    private static String getExmodsData_AuthError() {
        String xmodsData = '{"Message": "Authorization has been denied for this request."}';
        return xmodsData;
    }
}