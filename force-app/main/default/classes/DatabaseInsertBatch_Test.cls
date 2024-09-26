/**
 * @description: Test Class for DatabaseInsertBatch
 */
@IsTest
@SuppressWarnings('PMD.ApexAssertionsShouldIncludeMessage')
public with sharing class DatabaseInsertBatch_Test {
	@IsTest
	public static void test_Batch() {
		List<Work_Comp_Policy__c> policies = new List<Work_Comp_Policy__c>();

		for (Integer index = 1; index <= 30; ++index) {
			policies.add(TestFactoryWorkCompPolicy.makeWorkCompPolicy('TEST-WC-' + index, Date.today().addDays(30), Date.today().addDays(1), null));
		}

		Test.startTest();
		Id idJob = Database.executeBatch(new DatabaseInsertBatch(policies, false, 'BASE TESTS', 'test_Batch'), 30);
		Test.stopTest();

		AsyncApexJob job = [
			SELECT Id, Status, ExtendedStatus, JobItemsProcessed, JobType, MethodName, NumberOfErrors, TotalJobItems
			FROM AsyncApexJob
			WHERE Id = :idJob
		];
		Assert.areEqual('Completed', job.Status);
		Assert.areEqual('BatchApex', job.JobType);
		Assert.areEqual(0, job.NumberOfErrors);
		Assert.areEqual(1, job.JobItemsProcessed);
		Assert.areEqual(1, job.TotalJobItems);

		policies = [SELECT Id FROM Work_Comp_Policy__c WHERE Name LIKE 'TEST-WC-%'];
		Assert.areEqual(30, policies.size(), 'Should have the 30 added');
	}
}