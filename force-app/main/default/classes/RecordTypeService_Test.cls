/**
 * @description RecordTypeService_Test contains tests for the RecordTypeService class.
 */
@IsTest
@SuppressWarnings('PMD.ApexAssertionsShouldIncludeMessage')
public without sharing class RecordTypeService_Test {
	@IsTest
	static void test_getRecordTypeIdsByName() {
		// Queries are not getting the Master Record Type
		Map<Id, RecordType> mapRTAccounts = new Map<Id, RecordType>(
			[SELECT Id, Name, DeveloperName FROM RecordType WHERE SObjectType = 'Account']
		);
		Map<Id, RecordType> mapRTContacts = new Map<Id, RecordType>(
			[SELECT Id, Name, DeveloperName FROM RecordType WHERE SObjectType = 'Contact']
		);
		Map<Id, RecordType> mapRTLeads = new Map<Id, RecordType>(
			[SELECT Id, Name, DeveloperName FROM RecordType WHERE SObjectType = 'Lead']
		);

		Map<String, Id> mapNameToId;

		mapNameToId = RecordTypeService.getRecordTypeIdsByName('Account');
		Assert.areEqual(mapRTAccounts.size() + 1, mapNameToId.size());

		mapNameToId = RecordTypeService.getRecordTypeIdsByName('Contact');
		Assert.areEqual(mapRTContacts.size() + 1, mapNameToId.size());

		mapNameToId = RecordTypeService.getRecordTypeIdsByName('Lead');
		Assert.areEqual(mapRTLeads.size() + 1, mapNameToId.size());
	}

	@IsTest
	static void test_getRecordTypeIdsByDeveloperName() {
		// Queries are not getting the Master Record Type
		Map<Id, RecordType> mapRTAccounts = new Map<Id, RecordType>(
			[SELECT Id, Name, DeveloperName FROM RecordType WHERE SObjectType = 'Account']
		);
		Map<Id, RecordType> mapRTContacts = new Map<Id, RecordType>(
			[SELECT Id, Name, DeveloperName FROM RecordType WHERE SObjectType = 'Contact']
		);
		Map<Id, RecordType> mapRTLeads = new Map<Id, RecordType>(
			[SELECT Id, Name, DeveloperName FROM RecordType WHERE SObjectType = 'Lead']
		);

		Map<String, Id> mapNameToId;

		mapNameToId = RecordTypeService.getRecordTypeIdsByDeveloperName('Account');
		Assert.areEqual(mapRTAccounts.size() + 1, mapNameToId.size());

		mapNameToId = RecordTypeService.getRecordTypeIdsByDeveloperName('Contact');
		Assert.areEqual(mapRTContacts.size() + 1, mapNameToId.size());

		mapNameToId = RecordTypeService.getRecordTypeIdsByDeveloperName('Lead');
		Assert.areEqual(mapRTLeads.size() + 1, mapNameToId.size());
	}

	@IsTest
	static void test_getByRecordType() {
		Account client1 = TestFactoryAccount.makeClient('Client 1', null, null);
		Account client2 = TestFactoryAccount.makeClient('Client 2', null, null);
		Account client3 = TestFactoryAccount.makeClient('Client 3', null, null);
		Account prospect1 = TestFactoryAccount.makeProspect('Prospect 1', null, null);
		Account prospect2 = TestFactoryAccount.makeProspect('Prospect 2', null, null);
		Account location1 = TestFactoryAccount.makeAccount('Location 1', 'Location');

		List<Account> accounts = new List<Account>{ client1, location1, prospect1, prospect2, client2, client3 };

		Assert.areEqual(
			3,
			RecordTypeService.getByRecordType(accounts, 'Account', 'Client').size(),
			'There should be 3 Client accounts'
		);
		Assert.areEqual(
			2,
			RecordTypeService.getByRecordType(accounts, 'Account', 'Prospect').size(),
			'There should be 2 Prospect accounts'
		);
		Assert.areEqual(
			1,
			RecordTypeService.getByRecordType(accounts, 'Account', 'Location').size(),
			'There should be 1 Location accounts'
		);
		Assert.areEqual(
			0,
			RecordTypeService.getByRecordType(accounts, 'Account', 'Vendor').size(),
			'There should be 0 Vendor accounts'
		);

		try {
			RecordTypeService.getByRecordType(accounts, 'Account', 'Unknown').size();
			Assert.fail('Exception should have been thrown.');
		} catch (Exception e) {
		}
	}

	@IsTest
	static void test_getByRecordTypes() {
		Account client1 = TestFactoryAccount.makeClient('Client 1', null, null);
		Account client2 = TestFactoryAccount.makeClient('Client 2', null, null);
		Account client3 = TestFactoryAccount.makeClient('Client 3', null, null);
		Account prospect1 = TestFactoryAccount.makeProspect('Prospect 1', null, null);
		Account prospect2 = TestFactoryAccount.makeProspect('Prospect 2', null, null);
		Account location1 = TestFactoryAccount.makeAccount('Location 1', 'Location');

		List<Account> accounts = new List<Account>{ client1, location1, prospect1, prospect2, client2, client3 };

		List<String> types = new List<String>{ 'Client', 'Prospect', 'Location', 'Vendor' };
		Assert.areEqual(6, RecordTypeService.getByRecordTypes(accounts, 'Account', types).size(), '6 total accounts');
	}

	@IsTest
	static void test_getId() {
		Assert.isNotNull(RecordTypeService.getId('Account', 'Client'));
		Assert.isNotNull(RecordTypeService.getId('Account', 'Prospect'));
		Assert.areEqual(null, RecordTypeService.getId('UNKNOWN', 'NONE'));

		Assert.isNotNull(RecordTypeService.getId('Account.Client'));
		Assert.isNotNull(RecordTypeService.getId('Account.Prospect'));
		Assert.areEqual(null, RecordTypeService.getId('UNKNOWN.NONE'));
	}

	@IsTest
	static void test_getLabel() {
		Id idrtClient = RecordTypeService.getId('Account', 'Client');
		Id idrtProspect = RecordTypeService.getId('Account', 'Prospect');

		Assert.areEqual('Client', RecordTypeService.getLabel(idrtClient, 'Account'));
		Assert.areEqual('Prospect', RecordTypeService.getLabel(idrtProspect, 'Account'));
		Assert.isNull(RecordTypeService.getLabel(idrtProspect, 'Bad Object Name'));
	}

	@IsTest
	static void test_isType() {
		Account client = TestFactoryAccount.makeClient('CLIENT ONE', null, null);

		Assert.isTrue(RecordTypeService.isType(client.RecordTypeId, 'Account', 'Client'));
		Assert.isFalse(RecordTypeService.isType(client.RecordTypeId, 'Account', 'Prospect'));
		Assert.isFalse(RecordTypeService.isType(client.RecordTypeId, 'UNKNOWN', 'NONE'));

		Assert.isTrue(RecordTypeService.isType(client.RecordTypeId, 'Account.Client'));
		Assert.isFalse(RecordTypeService.isType(client.RecordTypeId, 'Account.Prospect'));
		Assert.isFalse(RecordTypeService.isType(client.RecordTypeId, 'UNKNOWN.NONE'));
	}

	@IsTest
	static void test_sortByRecordType() {
		Account branch1 = TestFactoryAccount.makeBranch('BRANCH ONE');
		Account branch2 = TestFactoryAccount.makeBranch('BRANCH TWO');
		Account client1 = TestFactoryAccount.makeClient('CLIENT ONE', null, null);
		Account client2 = TestFactoryAccount.makeClient('CLIENT TWO', null, null);
		Account prospect = TestFactoryAccount.makeProspect('PROSPECT ONE', null, null);

		List<Account> accounts = new List<Account>{ branch1, client1, prospect, client2, branch2 };

		Map<String, List<SObject>> sorted = RecordTypeService.sortByRecordType('Account', accounts);

		Assert.isFalse(sorted.isEmpty());

		Assert.areEqual(2, sorted.get('BBSI Branch').size());
		Assert.areEqual(2, sorted.get('Client').size());
		Assert.areEqual(1, sorted.get('Prospect').size());
	}

	//=============================================================================
	// DEPRECATED: Methods below here are testing methods which should be removed
	//=============================================================================
	@IsTest
	static void testGetRecordTypeByDeveloperName() {
		Map<Id, RecordType> mapRTAccounts = new Map<Id, RecordType>(
			[SELECT Id, Name, DeveloperName FROM RecordType WHERE SObjectType = 'Account']
		);

		for (RecordType rt : mapRTAccounts.values()) {
			Id idRT = RecordTypeService.getId('Account', rt.DeveloperName);
			Assert.areEqual(rt.Id, idRt);
		}
	}

	@IsTest
	static void testGetAllRecordTypesByDevName() {
		Map<Id, RecordType> mapRTAccounts = new Map<Id, RecordType>(
			[SELECT Id, Name, DeveloperName FROM RecordType WHERE SObjectType = 'Account']
		);

		Map<String, Id> mapRTs = RecordTypeService.getRecordTypeIdsByDeveloperName('Account');

		// Plus one because the query does not read "Master"
		Assert.areEqual(mapRTAccounts.size() + 1, mapRTs.size());
	}

	@IsTest
	static void testGetRecordTypeID() {
		Map<Id, RecordType> mapRTAccounts = new Map<Id, RecordType>(
			[SELECT Id, Name, DeveloperName FROM RecordType WHERE SObjectType = 'Account']
		);

		for (RecordType rt : mapRTAccounts.values()) {
			Id idRT = RecordTypeService.getId('Account', rt.Name);
			Assert.areEqual(rt.Id, idRt);
		}
	}

	@IsTest
	static void testAllRecordTypesByName() {
		String objectType = 'Account';

		Map<Id, RecordType> mapRTAll = new Map<Id, RecordType>(
			[SELECT Id, Name, DeveloperName FROM RecordType WHERE SObjectType = :objectType AND IsActive = TRUE]
		);

		Map<String, Id> mapRTs = RecordTypeService.getRecordTypeIdsByName(objectType);

		if (mapRTS.containsKey('Master')) {
			Assert.areEqual(mapRTAll.size() + 1, mapRTs.size());
		} else {
			Assert.areEqual(mapRTAll.size(), mapRTs.size());
		}
	}

	@IsTest
	static void testRecordTypeByRecordTypeName() {
		Map<Id, RecordType> mapRTAccounts = new Map<Id, RecordType>(
			[SELECT Id, Name, DeveloperName FROM RecordType WHERE SObjectType = 'Account']
		);

		for (RecordType rt : mapRTAccounts.values()) {
			Id idRT = RecordTypeService.getId('Account', rt.Name);
			Assert.areEqual(rt.Id, idRT);
		}
	}
}