/**
 * @description SObjectSelector_Controller_Test contains tests for the SObjectSelector_Controller class.
 */
@IsTest
public with sharing class SObjectSelector_Controller_Test {
	private static final String RESULT_BUILD_QUERY_1 = 
		'SELECT id, name' +
		' FROM Account' +
		' WHERE (Name LIKE \'%FIND%\' OR External_Id__c LIKE \'%FIND%\')' +
		' AND RecordType.Name IN (\'Client\',\'Prospect\')' +
		' ORDER BY Name ASC' +
		' LIMIT 7';

	private static final String RESULT_BUILD_QUERY_2 = 
		'SELECT external_id__c, id, name, recordtype.name' +
		' FROM Account' +
		' WHERE (Name LIKE \'%FIND%\')' +
		' ORDER BY Name ASC' +
		' LIMIT 1';

	private static final String SEARCH_QUERY = 
		'SELECT external_id__c, id, name, recordtype.name' +
		' FROM Account' +
		' WHERE (Name LIKE \'%FIND%\' OR External_Id__c LIKE \'%FIND%\')' +
		' AND RecordType.Name IN (\'Client\',\'Prospect\')' +
		' ORDER BY Name ASC' +
		' LIMIT 10';

		private static final String FORMAT_RESULT_QUERY_1 =
			'[' +
			'\'{\'"value":"{0}","text":"{1}"\'}\',' +
			'\'{\'"value":"{2}","text":"{3}"\'}\'' +
			']';


		private static final String FORMAT_RESULT_QUERY_2 =
		'[' +
		'\'{\'"value":"{0}","text":"{1}"\'}\',' +
		'\'{\'"value":"{2}","text":"RP_1 - {3}"\'}\'' +
		']';
		
	@IsTest
	static void test_buildQuery() {		
		Assert.areEqual(
			RESULT_BUILD_QUERY_1, 
			SObjectSelector_Controller.buildQuery(
				'Account',
				'Name',
				'Id',
				new List<String>{ 'Name', 'External_Id__c' },
				new List<String>{ 'Client', 'Prospect' },
				'FIND',
				7,
				null
			),
			'Query build wrong.'
		);		

		Assert.areEqual(
			RESULT_BUILD_QUERY_2, 
			SObjectSelector_Controller.buildQuery(
				'Account',
				'Name',
				'Id',
				new List<String>{ 'Name' },
				new List<String>(),
				'FIND',
				0,
				SObjectSelector_Controller.KIND_BAR_REFERRAL_PARTNER
			),
			'Query build wrong.'
		);	
	}

	@IsTest
	static void test_search() {
		Account branch = TestFactoryAccount.makeBranch('FIND Branch');
		Account client1 = TestFactoryAccount.makeClient('Second Find', null, null);
		Account client2 = TestFactoryAccount.makeClient('Find 1', null, null);
		Account client3 = TestFactoryAccount.makeClient('Other', null, null);
		Account prospect1 = TestFactoryAccount.makeProspect('Prospect Find', null, null);
		Account prospect2 = TestFactoryAccount.makeProspect('Prospect One', null, null);
		prospect2.External_Id__c = 'FINDME';

		insert new List<Account>{ branch, client1, client2, client3, prospect1, prospect2 };
		
		List<SObject> objects = SObjectSelector_Controller.search(SEARCH_QUERY);

		Assert.areEqual(4, objects.size(), 'Wrong number of items found');
		Assert.areEqual(objects[0].Id, client2.Id, 'Missing account or ORDER BY failed');
		Assert.areEqual(objects[1].Id, prospect1.Id, 'Missing account or ORDER BY failed');
		Assert.areEqual(objects[2].Id, prospect2.Id, 'Missing account or ORDER BY failed');
		Assert.areEqual(objects[3].Id, client1.Id, 'Missing account or ORDER BY failed');
	}

	@IsTest
	static void test_query1() {
		Account client = TestFactoryAccount.makeClient('Find Client', null, null);
		Account prospect = TestFactoryAccount.makeProspect('Prospect Find', null, null);

		insert new List<Account>{ client, prospect };

		String json = SObjectSelector_Controller.query(
			'Account',
			'Name',
			'Id',
			new List<String>{ 'Name', 'External_Id__c' },
			new List<String>{ 'Client', 'Prospect' },
			'FIND',
			10,
			null
		);

		String expected = String.format(
			FORMAT_RESULT_QUERY_1, 
			new List<String>{ 
				String.valueOf(client.Id), client.Name,
				String.valueOf(prospect.Id), prospect.Name
			}
		);

		Assert.areEqual(expected, json, 'Returned JSON incorrectly built.');
	}

	@IsTest
	static void test_query2() {
		Account branch = TestFactoryAccount.makeBranch('FIND BRANCH');
		Account rp = TestFactoryAccount.makeReferralPartner('Find RP');
		rp.External_Id__c = 'RP_1';

		insert new List<Account>{ branch, rp };

		String json = SObjectSelector_Controller.query(
			'Account',
			'Name',
			'Id',
			new List<String>{ 'Name', 'External_Id__c' },
			new List<String>{ 'BBSI Branch', 'Referral Partner' },
			'FIND',
			10,
			SObjectSelector_Controller.KIND_BAR_REFERRAL_PARTNER
		);

		String expected = String.format(
			FORMAT_RESULT_QUERY_2, 
			new List<String>{ 
				String.valueOf(branch.Id), branch.Name,
				String.valueOf(rp.Id), rp.Name
			}
		);

		Assert.areEqual(expected, json, 'Returned JSON incorrectly built.');
	}
}