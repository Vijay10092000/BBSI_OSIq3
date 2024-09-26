/**
 * @description WorkCompRenewalsDataModel_Test contains tests for the WorkCompRenewalsDataModel class.
 */
@IsTest
@SuppressWarnings('PMD.ApexAssertionsShouldIncludeMessage')
private class WorkCompRenewalsDataModel_Test {
	@isTest
	static void getMockData() {
		Test.startTest();

		// Not using GenericMockCallout since GetData method calls 2 REST calls back to back.
		Test.setMock(HttpCalloutMock.class, new WorkCompCalloutClass_Mock('', '', ''));

		Integer client = 905384;
		WorkCompRenewalsDataModel obj = new WorkCompRenewalsDataModel(client, Date.today().addDays(45));

		Test.stopTest();

		obj.GetData();

		Assert.isNotNull(obj);
		Assert.isNotNull(obj.RiskClaims);
		Assert.areEqual(6, obj.RiskClaims.Client.length());
		Assert.isNotNull(obj.XmodHist);
		Assert.areEqual('900001', obj.XmodHist.ClientId);

		Assert.isNotNull(obj.RiskClaimsMap);

		Assert.isNotNull(obj.SafetyIncentiveSum);
		Assert.areEqual(6, obj.SafetyIncentiveSum.Client.length());
		Assert.isNotNull(obj.SafetyIncentiveSum.DataList);
		Assert.isTrue(obj.SafetyIncentiveSum.DataList.size() > 0);
	}

	@IsTest
	static void getMockDataError() {
		// Not using GenericMockCallout since GetData method calls 2 REST calls back to back.
		Test.setMock(HttpCalloutMock.class, new WorkCompCalloutClass_Mock('ERROR', '', ''));

		integer client = 905384;
		WorkCompRenewalsDataModel obj = new WorkCompRenewalsDataModel(client, Date.today().addDays(45));
		obj.GetData();

		Assert.isNotNull(obj);
		Assert.areEqual(400, obj.StatusCode);
	}
}