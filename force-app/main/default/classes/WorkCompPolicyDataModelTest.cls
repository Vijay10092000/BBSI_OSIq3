@isTest
public without sharing class WorkCompPolicyDataModelTest 
{
    @IsTest static void getMockData() 
    {
        Test.startTest();
        Test.setMock(HttpCalloutMock.class, new GenericMockCallout(200, 'OK', getWorkCompPoliciesData(), null));
        WorkCompPolicyDataModel workComp = new WorkCompPolicyDataModel();
        Test.stopTest();

        workComp.GetData();

        Assert.areEqual(200, workComp.StatusCode);
        Assert.areEqual('OK', workComp.StatusMsg);
        Assert.isTrue(workComp.WcPolicies != null);
        Assert.isTrue(workComp.WcPolicies.DATALIST != null);
        Assert.areEqual(21, workComp.WcPolicies.DATALIST.size());
    }

    @IsTest static void getMockData_Exception() 
    {
        Test.startTest();
        Test.setMock(HttpCalloutMock.class, new GenericMockCallout(new CalloutException()));
        WorkCompPolicyDataModel workComp = new WorkCompPolicyDataModel();
        Test.stopTest();

        workComp.GetData();

        Assert.areEqual(0, workComp.StatusCode);
    }

    @IsTest static void getMockDataWithBlankDataList() 
    {
        Test.startTest();
        Test.setMock(HttpCalloutMock.class, new GenericMockCallout(200, 'OK', getWorkCompPoliciesDataWithBlankDataList(), null));
        WorkCompPolicyDataModel workComp = new WorkCompPolicyDataModel();
        Test.stopTest();

        workComp.GetData();

        Assert.areEqual(0, workComp.StatusCode);
        Assert.areEqual('Error - Get Work Comp Policies - Data not found', workComp.StatusMsg);
        Assert.isTrue(workComp.WcPolicies != null);
        Assert.isTrue(workComp.WcPolicies.DATALIST != null);
        Assert.areEqual(0, workComp.WcPolicies.DATALIST.size());
    }

    @IsTest static void getMockDataWithBlankStatusMsg() 
    {
        Test.startTest();
        Test.setMock(HttpCalloutMock.class, new GenericMockCallout(200, '', getWorkCompPoliciesData(), null));
        WorkCompPolicyDataModel workComp = new WorkCompPolicyDataModel();
        Test.stopTest();

        workComp.GetData();

        Assert.areEqual(0, workComp.StatusCode);
        Assert.isTrue(workComp.StatusMsg.startsWith('Status: '));
        Assert.isTrue(workComp.WcPolicies != null);
        Assert.isTrue(workComp.WcPolicies.DATALIST != null);
        Assert.areEqual(21, workComp.WcPolicies.DATALIST.size());
    }

    private static String getWorkCompPoliciesData() {
        String workCompPoliciesData = '{"DATALIST":["A2","A3","A4","BBSI","BBSIMDMASTER","BBSISTAFFING","BOND-NC","CLIENT","D1","ECOLESTAFFING","I1","IDSTAFFING","N4","N5","N6","N8","STATE","STATESTAFFING","U4","W1","105655WA"]}';
        return workCompPoliciesData;
    }

    private static String getWorkCompPoliciesDataWithBlankDataList() {
        String workCompPoliciesData = '{"DATALIST":[]}';
        return workCompPoliciesData;
    }
}