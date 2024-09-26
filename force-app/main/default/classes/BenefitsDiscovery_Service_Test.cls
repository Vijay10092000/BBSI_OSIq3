/**
 * @description BenefitsDiscovery_Service_Test contains test for the BenefitsDiscovery_Service class.
 */
@IsTest
public with sharing class BenefitsDiscovery_Service_Test {
	@IsTest
	public static void test_confirmOnlyOne_Success() {
		BenefitsDiscovery_TestEnv testEnv = new BenefitsDiscovery_TestEnv();

		Test.startTest();
		TestFactoryBDQuestionnaire.createBDQuestionnaire(testEnv.opp4.Id);
		Test.stopTest();

		List<Benefits_Discovery_Questionnaire__c> bdqs = [
			SELECT Id, OpportunityId__c
			FROM Benefits_Discovery_Questionnaire__c
			WHERE OpportunityId__c = :testEnv.opp4.Id
		];

		System.assertEquals(1, bdqs.size(), 'A Benefits Contact Role should have been created');
	}

	@IsTest
	public static void test_confirmOnlyOne_Failure() {
		BenefitsDiscovery_TestEnv testEnv = new BenefitsDiscovery_TestEnv();

		Test.startTest();
		try {
			TestFactoryBDQuestionnaire.createBDQuestionnaire(testEnv.opp2.Id);
			System.assert(false, 'Should have failed to create 2 questionnare on opp2');
		} catch (Exception e) {
			System.assert(true, 'Should fail to create 2 questionnare on opp2');
		}
		Test.stopTest();
	}

	@IsTest
	public static void test_setBenefitsContactEmail() {
		BenefitsDiscovery_TestEnv testEnv = new BenefitsDiscovery_TestEnv();

		TestFactory.createOpportunityContactRole(
			testEnv.contact4A.Id,
			testEnv.opp4.Id,
			false,
			OpportunityContactRole_Service.BENEFITS_CONTACT,
			true
		);

		Test.startTest();
		TestFactoryBDQuestionnaire.createBDQuestionnaire(testEnv.opp4.Id);
		Test.stopTest();

		List<Benefits_Discovery_Questionnaire__c> bdqs = [
			SELECT Id, OpportunityId__c, BenefitsContactEmail__c
			FROM Benefits_Discovery_Questionnaire__c
			WHERE OpportunityId__c = :testEnv.opp4.Id
		];

		Assert.areEqual(1, bdqs.size(), 'A Benefits Contact Role should have been created');

		Assert.isTrue(
			testEnv.contact4A.Email.toLowerCase() == bdqs.get(0).BenefitsContactEmail__c.toLowerCase(),
			'Emails should be set'
		);
	}

	@IsTest
	public static void updateOpportunity() {
		BenefitsDiscovery_TestEnv testEnv = new BenefitsDiscovery_TestEnv();

		Benefits_Discovery_Questionnaire__c bdq = TestFactoryBDQuestionnaire.createBDQuestionnaire(testEnv.opp4.Id);

		Test.startTest();
		bdq.Budget_For_Renewal_Increase__c = 12;
		bdq.Have_Benefits__c = 'Yes';
		bdq.Plan_Types__c = 'Dental';
		update bdq;
		Test.stopTest();

		Opportunity opp = [
			SELECT Id, Budget_For_Renewal_Increase__c, Have_Benefits__c, Plan_Types__c
			FROM Opportunity
			WHERE Id = :testEnv.opp4.Id
		];

		Assert.areEqual(12, opp.Budget_For_Renewal_Increase__c, 'Budget For Renewal Increase should have changed');
		Assert.areEqual('Yes', opp.Have_Benefits__c, 'Have Benefitd should have changed');
		Assert.areEqual('Dental', opp.Plan_Types__c, 'Have Benefitd should have changed');
	}

	@IsTest
	public static void test_setBenefitsContact() {
		BenefitsDiscovery_TestEnv testEnv = new BenefitsDiscovery_TestEnv();

		Test.startTest();
		testEnv.bdq1.Benefits_Contact__c = testEnv.contact1A.Id;
		update new List<Benefits_Discovery_Questionnaire__c>{ testEnv.bdq1 };
		Test.stopTest();

		Contact c1 = [SELECT Id, Benefits_Contact__c FROM Contact WHERE Id = :testEnv.contact1A.Id];
		Assert.areEqual(true, c1.Benefits_Contact__c);

		Contact c2 = [SELECT Id, Benefits_Contact__c FROM Contact WHERE Id = :testEnv.contact2A.Id];
		Assert.areEqual(false, c2.Benefits_Contact__c);
	}
}