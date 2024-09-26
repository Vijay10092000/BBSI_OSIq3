@IsTest
public with sharing class WorkCompRateScheduler_Test {
	private static String JSON_WORKCOMPRATES =
		'{"DATALIST":[' + 
		'  { "WcPolicy":"A1",' +
		'    "State":"PA",' +
		'    "Rate":1.11,' +
		'    "Code":"1111" },' +
		'  { "WcPolicy":"A4",' +
		'    "State":"FL",' +
		'    "Rate":2.22,' +
		'    "Code":"2222" }' +
		']}';

    @IsTest
	public static void test_WorkCompRateScheduler() {
		
		WorkCompRate__c rate1 = TestFactoryWorkCompRate.makeWorkCompRate('A2', 'AZ', '1234', 1.23, null);
		WorkCompRate__c rate2 = TestFactoryWorkCompRate.makeWorkCompRate('A2', 'CA', '2345', 2.34, null);
		WorkCompRate__c rate3 = TestFactoryWorkCompRate.makeWorkCompRate('A3', 'WA', '3456', 3.45, null);

		insert new List<WorkCompRate__c>{ rate1, rate2, rate3 };

		List<WorkCompRate__c> rates;

		rates = [SELECT Id, Policy__c, State__c, Code__c, Rate__c FROM WorkCompRate__c ORDER BY State__c];
		Assert.areEqual(3, rates.size(), 'Starting with 3 rates');

		Test.startTest();

		Test.setMock(HttpCalloutMock.class, new GenericMockCallout(200, 'SUCCESS', JSON_WORKCOMPRATES, null));

		// NOTE: The scheducBatch job deletes the old records and adds new records
		WorkCompRateScheduler scheduler = new WorkCompRateScheduler();
		scheduler.execute(null);

		Test.stopTest();

		rates = [SELECT Id, Policy__c, State__c, Code__c, Rate__c FROM WorkCompRate__c ORDER BY State__c];

		Assert.areEqual(2, rates.size(), 'Two rates were returned from mock callout');

		Assert.areEqual('A4', rates[0].Policy__c);
		Assert.areEqual('FL', rates[0].State__c);
		Assert.areEqual('2222', rates[0].Code__c);
		Assert.areEqual(2.22, rates[0].Rate__c);

		Assert.areEqual('A1', rates[1].Policy__c);
		Assert.areEqual('PA', rates[1].State__c);
		Assert.areEqual('1111', rates[1].Code__c);
		Assert.areEqual(1.11, rates[1].Rate__c);
	}
}