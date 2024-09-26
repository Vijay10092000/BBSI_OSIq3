@IsTest
public with sharing class PlatformEvent_Test {
	private static final Id FAKE_LEAD_ID = Id.valueOf('00Q000000000t75');

	@IsTest
	static void test_fireLeadConversion() {
		Set<Id> idLeads = new Set<Id>{ FAKE_LEAD_ID };

		Test.startTest();

		DateTime now = DateTime.now();

		PlatformEvent.fireLeadConversion(idLeads);

		Test.stopTest();

		List<Log__c> logs = Log_Test.recentLogs(now);

		Assert.areEqual(0, logs.size());
	}
}