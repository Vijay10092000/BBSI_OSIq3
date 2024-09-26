/**
 * Renewal_Service_Test contains tests for the Renewal_Service class.
 */
@IsTest
public without sharing class Renewal_Service_Test {
    @IsTest
	static void test_setIncompleteRenewals() {
		String fein = '11-1111111';

		Renewal__c renewal_1 = new Renewal__c(
			Name = 'TEST 1',
			FEIN__c = fein,
			Status__c = 'New'
		);
		Renewal__c renewal_2 = new Renewal__c(
			Name = 'TEST 2',
			FEIN__c = fein,
			Status__c = 'Waiting for Approval'
		);
		Renewal__c renewal_3 = new Renewal__c(
			Name = 'TEST 3',
			FEIN__c = fein,
			Status__c = 'In Process'
		);
		Renewal__c renewal_4 = new Renewal__c(
			Name = 'TEST 4',
			FEIN__c = fein,
			Status__c = 'Completed'
		);

		insert(new List<Renewal__c>{ renewal_1, renewal_2, renewal_3, renewal_4  });

		Test.startTest();
		
		Renewal__c renewal_5 = new Renewal__c(
			Name = 'TEST 5',
			FEIN__c = fein,
			Status__c = 'New'
		);

		insert renewal_5;
		
		Test.stopTest();

		List<Renewal__c> renewals = [SELECT Id, Name, Status__c FROM Renewal__c WHERE Name LIKE 'TEST %' ORDER BY NAME ASC];

		Assert.areEqual(5, renewals.size());
		Assert.areEqual('Incomplete', renewals[0].Status__c);
		Assert.areEqual('Incomplete', renewals[1].Status__c);
		Assert.areEqual('Incomplete', renewals[2].Status__c);
		Assert.areEqual('Completed', renewals[3].Status__c);
		Assert.areEqual('New', renewals[4].Status__c);
    }
}