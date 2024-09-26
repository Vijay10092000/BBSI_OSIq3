@IsTest
private class WorkCompControllerTest 
{
    @IsTest static void WorkCompPolicyDisplayNameTest()
    {
        String workCompPoliciesData = '{"DATALIST":["A2","A3","A4","BBSI","BBSIMDMASTER","BBSISTAFFING","BOND-NC","CLIENT","D1","ECOLESTAFFING","I1","IDSTAFFING","N4","N5","N6","N8","STATE","STATESTAFFING","U4","W1","105655WA"]}';
        Test.startTest();
        Test.setMock(HttpCalloutMock.class, new GenericMockCallout(200, 'SUCCESS', workCompPoliciesData, null));
        WorkCompPolicyDisplayName__c newPolicy = new WorkCompPolicyDisplayName__c();
        Test.stopTest();

        newPolicy.Include__c = false;
        newPolicy.HRP_Work_Comp_Policy__c = 'BBSI';
        newPolicy.Display_Name__c = 'Corvell';

        WorkCompController.addWorkCompPolicyDisplayNameMappings(new List<WorkCompPolicyDisplayName__c>{newPolicy});

        WorkCompPolicyDisplayName__c[] policies = WorkCompController.getWorkCompPolicyDisplayNameMappings();
        Assert.isTrue(policies.size() > 0);
        WorkCompPolicyDisplayName__c policy = policies[0];
        Assert.areEqual(false, policy.Include__c);

        policy.Include__c  = true;
        WorkCompController.saveWorkCompPolicyDisplayNameMappings(policies);

        WorkCompPolicyDisplayName__c[] updatedPolicies = WorkCompController.getWorkCompPolicyDisplayNameMappings();
        Assert.isTrue(updatedPolicies.size() > 0);
        Assert.areEqual(true, updatedPolicies[0].Include__c);

        WorkCompPolicyDisplayName__c[] includedPolicies = WorkCompController.includedWorkCompPolicyDisplayNames();
        Assert.isTrue(includedPolicies.size() > 0);

        WorkCompPolicyDisplayName__c[] allPolicies = WorkCompController.getWorkCompPolicyDisplayNames();
        Assert.isTrue(allPolicies.size() > 0);
    }

    @IsTest static void WorkCompPolicyDataModelTest()
    {
        Test.startTest();
        String workCompPoliciesData = '{"DATALIST":["A2","A3","A4","BBSI","BBSIMDMASTER","BBSISTAFFING","BOND-NC","CLIENT","D1","ECOLESTAFFING","I1","IDSTAFFING","N4","N5","N6","N8","STATE","STATESTAFFING","U4","W1","105655WA"]}';

        Test.setMock(HttpCalloutMock.class, new GenericMockCallout(200, 'SUCCESS', workCompPoliciesData, null));

        WorkCompPolicyDataModel obj = new WorkCompPolicyDataModel();

		Test.stopTest();

        obj.GetData();
        Assert.areEqual(200, obj.StatusCode);
        Assert.isTrue(obj.WcPolicies.DATALIST.size() > 10);
    }

    @IsTest static void WorkCompPolicyDataModelTest_NoDataListResponse()
    {
        Test.startTest();
        String workCompPoliciesData = '{"DATALIST":[]}';

        Test.setMock(HttpCalloutMock.class, new GenericMockCallout(200, 'SUCCESS', workCompPoliciesData, null));

        WorkCompPolicyDataModel obj = new WorkCompPolicyDataModel();

        Test.stopTest();

        obj.GetData();
        Assert.areEqual(0, obj.StatusCode);
        Assert.isTrue(obj.WcPolicies.DATALIST.size() == 0);
    }

    @IsTest static void WorkCompPolicyDataModelTest_NullResponse()
    {
        Test.startTest();

        /**
         * The following block in WorkCompPolicyDataModel is problematic. It first checks 
         * if WorkCompPolicyDataModel is null and if yes, then tries to call httpRes.getStatus() 
         * which again throws a NullPointer exception rather than throwing CalloutException. 
         * Due to this the final block is not getting covered for coverage. Once the code is fixed, 
         * hopefully finally block too should get covered.
            if(httpRes == null) {
                CalloutException e = (CalloutException) CalloutException.class.newInstance();
                e.setMessage(httpRes.getStatus());
                throw e;
            }
         */
        Test.setMock(HttpCalloutMock.class, new GenericMockCallout(200, 'SUCCESS', null, null));

        WorkCompPolicyDataModel obj = new WorkCompPolicyDataModel();

        Test.stopTest();

        obj.GetData();
        Assert.areEqual(0, obj.StatusCode);
    }

    @IsTest static void HrpWorkCompPoliciesTest()
    {
        Test.startTest();

        String workCompPoliciesData = '{"DATALIST":["A2","A3","A4","BBSI","BBSIMDMASTER","BBSISTAFFING","BOND-NC","CLIENT","D1","ECOLESTAFFING","I1","IDSTAFFING","N4","N5","N6","N8","STATE","STATESTAFFING","U4","W1","105655WA"]}';

        Test.setMock(HttpCalloutMock.class, new GenericMockCallout(200, 'SUCCESS', workCompPoliciesData, null));
        // Test.setMock(HttpCalloutMock.class, new WorkCompCalloutClass_Mock('','',''));
        List<String> policies = WorkCompController.getHrpWorkCompPolicies();
		Test.stopTest();

        Assert.isTrue(policies.size() > 10);

        WorkCompPolicyDisplayName__c[] workCompPolicies = WorkCompController.getWorkCompPolicyDisplayNameMappings();
        Assert.isTrue(workCompPolicies.size() > 0);
    }

    @IsTest static void WorkCompPolicyCodeRateTest()
    {
        Test.startTest();

        Test.setMock(HttpCalloutMock.class, new WorkCompCalloutClass_Mock('','',''));
        WorkCompPolicyCodeRateDataModel obj = new WorkCompPolicyCodeRateDataModel();
        Assert.isTrue(obj.GetData());

		Test.stopTest();

        Assert.areEqual(3, obj.WcPolicy.values().size());
        
        Map<String, List<String>> wcState = obj.WcPolicy.get('BBSI');
        Assert.areEqual(1, wcState.values().size());

        List<String> wcCodes = wcState.get('CA');
        Assert.isTrue(wcCodes.size() > 10);

        String wcCode = wcCodes[0];
        String [] codeRate = wcCode.split('-');
        Assert.isTrue(codeRate.size() == 2);
        Assert.areEqual(4, codeRate[0].length());
    }

    @IsTest static void WorkCompRateTest()
    {
        Test.startTest();
        
        WorkCompRate__c rate1 = new WorkCompRate__c();
        rate1.Policy__c = 'BBSI';
        rate1.State__c = 'CA';
        rate1.Code__c = '8810';
        rate1.Rate__c = 15.2500;

        WorkCompRate__c rate2 = new WorkCompRate__c();
        rate2.Policy__c = 'BBSI';
        rate2.State__c = 'CA';
        rate2.Code__c = '4423';
        rate2.Rate__c = 10.2500;

        WorkCompRate__c rate3 = new WorkCompRate__c();
        rate2.Policy__c = 'BBSI';
        rate2.State__c = 'WA';
        rate2.Code__c = '8810';
        rate2.Rate__c = 6.2500;

        insert new List<WorkCompRate__c> { rate1, rate2, rate3 };

        Test.stopTest();

        List<WorkCompRate__c> rates = WorkCompController.getWorkCompRates();
        Assert.areEqual(3, rates.size());
        
        Map<String, Map<String, List<WorkCompRate__c>>> rateMap = WorkCompController.getWorkCompRateMap();
        Assert.isTrue(rateMap != null);
        Assert.isTrue(rateMap.containsKey('BBSI'));
        Assert.isTrue(rateMap.get('BBSI').containsKey('CA'));

        List<WorkCompRate__c> waRates = WorkCOmpController.getWorkCompRatesByState('WA');
        Assert.isTrue(waRates.size() > 0);
    }
}