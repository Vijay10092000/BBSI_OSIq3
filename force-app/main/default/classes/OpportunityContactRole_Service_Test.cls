/**
 * @description OpportunityContactRole_Service_Test contains tests for the OpportunityContactRole_Service class.
 */
@IsTest
@SuppressWarnings('PMD.ApexAssertionsShouldIncludeMessage ')
public without sharing class OpportunityContactRole_Service_Test {
	@IsTest
	public static void test_getOpportunityContactsByRole() {
		BenefitsDiscovery_TestEnv textEnv = new BenefitsDiscovery_TestEnv();

		Test.startTest();

		Map<Id, List<OpportunityContactRole>> mapResults = OpportunityContactRole_Service.getOpportunityContactsByRole(
			new List<Id>{ textEnv.opp1.Id, textEnv.opp2.Id },
			new List<String>{
				OpportunityContactRole_Service.BENEFITS_CONTACT,
				OpportunityContactRole_Service.DECISION_MAKER,
				OpportunityContactRole_Service.EXECUTIVE_SPONSOR
			}
		);

		Test.stopTest();

		Assert.areEqual(2, mapResults.size(), 'Should have one per Opportunity');
		Assert.areEqual(4, mapResults.get(textEnv.opp1.Id).size(), '4 created for the first Opportunity');
		Assert.areEqual(1, mapResults.get(textEnv.opp2.Id).size(), '1 created for the second Opportunity');

		List<Id> idOpps = new List<Id>{ textEnv.opp1.Id, textEnv.opp2.Id, textEnv.opp3.Id };

		for (Benefits_Discovery_Questionnaire__c bdq : [
			SELECT Id, OpportunityId__c, BenefitsContactEmail__c
			FROM Benefits_Discovery_Questionnaire__c
			WHERE Id IN :idOpps
		]) {
			if (bdq.OpportunityId__c == textEnv.opp1.Id || bdq.OpportunityId__c == textEnv.opp2.Id) {
				Assert.isTrue(!String.isBlank(bdq.BenefitsContactEmail__c), 'Benefits Contact Email should be set');
			} else if (bdq.OpportunityId__c == textEnv.opp3.Id) {
				Assert.isTrue(String.isBlank(bdq.BenefitsContactEmail__c), 'Benefits Contact Email should not be set');
			}
		}
	}

	@IsTest
	public static void test_getRoles() {
		BenefitsDiscovery_TestEnv textEnv = new BenefitsDiscovery_TestEnv();

		List<Id> idContacts = new List<Id>{
			textEnv.contact1A.Id,
			textEnv.contact1B.Id,
			textEnv.contact1C.Id,
			textEnv.contact2A.Id,
			textEnv.contact3A.Id,
			textEnv.contact4A.Id
		};

		List<OpportunityContactRole> ocrs = [
			SELECT Id, ContactId, OpportunityId, IsPrimary, Role
			FROM OpportunityContactRole
			WHERE ContactId IN :idContacts
		];

		Test.startTest();

		Map<Id, OpportunityContactRole> mapBenefitsContact = OpportunityContactRole_Service.getRoles(
			ocrs,
			OpportunityContactRole_Service.BENEFITS_CONTACT
		);
		Map<Id, OpportunityContactRole> mapDecisionMaker = OpportunityContactRole_Service.getRoles(
			ocrs,
			OpportunityContactRole_Service.DECISION_MAKER
		);
		Map<Id, OpportunityContactRole> mapExecutiveSponsor = OpportunityContactRole_Service.getRoles(
			ocrs,
			OpportunityContactRole_Service.EXECUTIVE_SPONSOR
		);
		Map<Id, OpportunityContactRole> mapUnknown = OpportunityContactRole_Service.getRoles(ocrs, 'Unknown');

		Test.stopTest();

		Assert.areEqual(2, mapBenefitsContact.size());
		Assert.areEqual(2, mapDecisionMaker.size());
		Assert.areEqual(1, mapExecutiveSponsor.size());
		Assert.areEqual(0, mapUnknown.size());
	}

	@IsTest
	public static void test_updateQuestionnaires() {
		BenefitsDiscovery_TestEnv textEnv = new BenefitsDiscovery_TestEnv();

		Benefits_Discovery_Questionnaire__c bdq3;

		bdq3 = [
			SELECT Id, Name, BenefitsContactEmail__c
			FROM Benefits_Discovery_Questionnaire__c
			WHERE OpportunityId__c = :textEnv.opp3.Id
		];

		Assert.areEqual(null, bdq3.BenefitsContactEmail__c, 'No Benefits Contact Role, yet');

		Test.startTest();

		TestFactoryOpportunity.createContactRole(textEnv.contact3A.Id, textEnv.opp3.Id, true, 'Benefits Contact');

		Test.stopTest();

		bdq3 = [
			SELECT Id, Name, BenefitsContactEmail__c
			FROM Benefits_Discovery_Questionnaire__c
			WHERE OpportunityId__c = :textEnv.opp3.Id
		];

		Assert.areEqual(
			textEnv.contact3A.Email.toLowerCase(),
			bdq3.BenefitsContactEmail__c.toLowerCase(),
			'Benefits Contact Role should have been created'
		);
	}

	@IsTest
	public static void test_updateContacts() {
		BenefitsDiscovery_TestEnv testEnv = new BenefitsDiscovery_TestEnv();

		List<Id> idContacts = new List<Id>{
			testEnv.contact1A.Id,
			testEnv.contact1B.Id,
			testEnv.contact1C.Id,
			testEnv.contact2A.Id,
			testEnv.contact3A.Id,
			testEnv.contact4A.Id
		};

		Map<Id, Contact> mapContacts = new Map<Id, Contact>([SELECT Id, Benefits_Contact__c FROM Contact WHERE Id IN :idContacts]);

		Assert.isTrue(mapContacts.get(testEnv.contact1A.Id).Benefits_Contact__c, 'Is Benefits Contact');
		Assert.isTrue(mapContacts.get(testEnv.contact1B.Id).Benefits_Contact__c, 'Is Benefits Contact');
		Assert.isFalse(mapContacts.get(testEnv.contact1C.Id).Benefits_Contact__c, 'Is not Benefits Contact');
		Assert.isFalse(mapContacts.get(testEnv.contact2A.Id).Benefits_Contact__c, 'Is not Benefits Contact');
		Assert.isFalse(mapContacts.get(testEnv.contact3A.Id).Benefits_Contact__c, 'Is not Benefits Contact');
		Assert.isFalse(mapContacts.get(testEnv.contact4A.Id).Benefits_Contact__c, 'Is not Benefits Contact');

		Test.startTest();

		OpportunityContactRole role3A = TestFactoryOpportunity.makeContactRole(
			testEnv.contact3A.Id,
			testEnv.opp1.Id,
			false,
			OpportunityContactRole_Service.BENEFITS_CONTACT
		);

		OpportunityContactRole role4A = TestFactoryOpportunity.makeContactRole(
			testEnv.contact4A.Id,
			testEnv.opp1.Id,
			false,
			OpportunityContactRole_Service.EXECUTIVE_SPONSOR
		);

		insert new List<OpportunityContactRole>{ role3A, role4A };

		Test.stopTest();

		mapContacts = new Map<Id, Contact>([SELECT Id, Benefits_Contact__c FROM Contact WHERE Id IN :idContacts]);

		Assert.isTrue(mapContacts.get(testEnv.Contact1A.Id).Benefits_contact__c, 'Is Benefits Contact');
		Assert.isTrue(mapContacts.get(testEnv.Contact1B.Id).Benefits_contact__c, 'Is Benefits Contact');
		Assert.isFalse(mapContacts.get(testEnv.Contact1C.Id).Benefits_contact__c, 'Is not Benefits Contact');
		Assert.isFalse(mapContacts.get(testEnv.Contact2A.Id).Benefits_contact__c, 'Is not Benefits Contact');
		Assert.isTrue(mapContacts.get(testEnv.Contact3A.Id).Benefits_contact__c, 'Is Benefits Contact');
		Assert.isFalse(mapContacts.get(testEnv.Contact4A.Id).Benefits_contact__c, 'Is not Benefits Contact');
	}

	@IsTest
	public static void test_readContactRoles() {
		BenefitsDiscovery_TestEnv testEnv = new BenefitsDiscovery_TestEnv();

		List<Id> idContacts = new List<Id>{
			testEnv.contact1A.Id,
			testEnv.contact1B.Id,
			testEnv.contact1C.Id,
			testEnv.contact2A.Id,
			testEnv.contact3A.Id,
			testEnv.contact4A.Id
		};

		Test.startTest();

		Map<Id, Contact> mapContacts = new Map<Id, Contact>([SELECT Id, Benefits_Contact__c FROM Contact WHERE Id IN :idContacts]);

		Assert.isTrue(mapContacts.get(testEnv.contact1A.Id).Benefits_Contact__c, 'Is Benefits Contact');
		Assert.isTrue(mapContacts.get(testEnv.contact1B.Id).Benefits_Contact__c, 'Is Benefits Contact');
		Assert.isFalse(mapContacts.get(testEnv.contact1C.Id).Benefits_Contact__c, 'Is not Benefits Contact');
		Assert.isFalse(mapContacts.get(testEnv.contact2A.Id).Benefits_Contact__c, 'Is not Benefits Contact');
		Assert.isFalse(mapContacts.get(testEnv.contact3A.Id).Benefits_Contact__c, 'Is not Benefits Contact');
		Assert.isFalse(mapContacts.get(testEnv.contact4A.Id).Benefits_Contact__c, 'Is not Benefits Contact');

		OpportunityContactRole role3A = TestFactoryOpportunity.makeContactRole(
			testEnv.contact3A.Id,
			testEnv.opp1.Id,
			false,
			OpportunityContactRole_Service.BENEFITS_CONTACT
		);

		OpportunityContactRole role4A = TestFactoryOpportunity.makeContactRole(
			testEnv.contact4A.Id,
			testEnv.opp2.Id,
			false,
			OpportunityContactRole_Service.EXECUTIVE_SPONSOR
		);

		insert new List<OpportunityContactRole>{ role3A, role4A };

		Set<Id> idOpps = new Set<Id>{ testEnv.opp1.Id, testEnv.opp2.Id, testEnv.opp3.Id, testEnv.opp4.Id };
		Map<Id, List<OpportunityContactRole>> oppToRoles = OpportunityContactRole_Service.readContactRoles(idOpps);

		Test.stopTest();

		Assert.isTrue(oppToRoles.containsKey(testEnv.opp1.Id));
		Assert.isTrue(oppToRoles.containsKey(testEnv.opp2.Id));
		Assert.isTrue(oppToRoles.containsKey(testEnv.opp3.Id));
		Assert.isTrue(oppToRoles.containsKey(testEnv.opp4.Id));

		Assert.areEqual(5, oppToRoles.get(testEnv.opp1.Id).size());
		Assert.areEqual(2, oppToRoles.get(testEnv.opp2.Id).size());
		Assert.areEqual(0, oppToRoles.get(testEnv.opp3.Id).size());
		Assert.areEqual(0, oppToRoles.get(testEnv.opp4.Id).size());
	}

	@IsTest
	public static void test_ChangePrimary() {
		BenefitsDiscovery_TestEnv testEnv = new BenefitsDiscovery_TestEnv();

		Test.startTest();

		List<Id> idContacts = new List<Id>{
			testEnv.contact1A.Id,
			testEnv.contact1B.Id,
			testEnv.contact1C.Id,
			testEnv.contact2A.Id,
			testEnv.contact3A.Id,
			testEnv.contact4A.Id
		};

		Map<Id, Contact> mapContacts = new Map<Id, Contact>([SELECT Id, Benefits_Contact__c FROM Contact WHERE Id IN :idContacts]);

		Assert.isTrue(mapContacts.get(testEnv.contact1A.Id).Benefits_Contact__c, 'Is Benefits Contact');
		Assert.isTrue(mapContacts.get(testEnv.contact1B.Id).Benefits_Contact__c, 'Is Benefits Contact');
		Assert.isFalse(mapContacts.get(testEnv.contact1C.Id).Benefits_Contact__c, 'Is not Benefits Contact');
		Assert.isFalse(mapContacts.get(testEnv.contact2A.Id).Benefits_Contact__c, 'Is not Benefits Contact');
		Assert.isFalse(mapContacts.get(testEnv.contact3A.Id).Benefits_Contact__c, 'Is not Benefits Contact');
		Assert.isFalse(mapContacts.get(testEnv.contact4A.Id).Benefits_Contact__c, 'Is not Benefits Contact');

		OpportunityContactRole role3A = TestFactoryOpportunity.makeContactRole(
			testEnv.contact3A.Id,
			testEnv.opp1.Id,
			false,
			OpportunityContactRole_Service.BENEFITS_CONTACT
		);

		OpportunityContactRole role4A = TestFactoryOpportunity.makeContactRole(
			testEnv.contact4A.Id,
			testEnv.opp2.Id,
			false,
			OpportunityContactRole_Service.EXECUTIVE_SPONSOR
		);

		insert new List<OpportunityContactRole>{ role3A, role4A };

		role3A.IsPrimary = true;
		update role3A;
		role3A.IsPrimary = false;

		Test.stopTest();

		role3A = [SELECT Id, ContactId, IsPrimary FROM OpportunityContactRole WHERE Id = :role3A.Id];

		Assert.isTrue(role3A.IsPrimary);
	}
}