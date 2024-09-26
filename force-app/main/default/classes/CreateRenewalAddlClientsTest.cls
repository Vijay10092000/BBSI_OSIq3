@IsTest
private class CreateRenewalAddlClientsTest {
	private static final String ACCOUNT_CLIENT_RT = 'Client';
	@testSetup static void setup() {
		Account branch = TestFactoryAccount.createBranch('TEST BRANCH');
		// create accounts, record type "Client"
		List<Account> testAccts = new List<Account>();
		string fein = '00-1234567';
		Id clientTypeId = RecordTypeService.getId('Account','Client');
		integer extId = 900000;
		Business_Unit__c bizUnit = TestFactoryBusinessUnit.makeBusinessUnit('foo unit', branch.Id);
		Business_Unit__c bizUnit2 = TestFactoryBusinessUnit.makeBusinessUnit('bar unit', branch.Id);
		Insert new List<Business_Unit__c>{bizUnit, bizUnit2};
		for (integer i = 0; i<3; i++) {
			testAccts.add(TestFactoryAccount.makeAccount(ACCOUNT_CLIENT_RT, new Map<String, Object>{
				'Name'=> 'test acct ' + i,
				'External_ID__c'=> (extId + i).format(),
				'Fein__c'=> fein,
				'Business_Unit__c'=> bizUnit.Id,
				'Renewal_Date__c'=> System.today().addDays(20),
				'Start_Date__c'=> System.today().addDays(-365)
			}));	
		}

		// and an outlier...
		testAccts.add(TestFactoryAccount.makeAccount(ACCOUNT_CLIENT_RT, new Map<String, Object>{
			'Name'=> 'test acct outlier',
			'External_ID__c'=> (extId + 100).format(),
			'Fein__c'=> fein,
			'Business_Unit__c'=> bizUnit.Id,
			'Renewal_Date__c'=> System.today().addDays(4),
			'Start_Date__c'=> System.today().addDays(-365)
		}));
		// and an outlier... with same FEIN but a DIFFERENT BUSINESS UNIT!
		testAccts.add(TestFactoryAccount.makeAccount(ACCOUNT_CLIENT_RT, new Map<String, Object>{
			'Name'=> 'test acct outlier2',
			'External_ID__c'=> (extId + 200).format(),
			'Fein__c'=> fein,
			'Business_Unit__c'=> bizUnit2.Id,
			'Renewal_Date__c'=> System.today().AddMonths(4),
			'Start_Date__c'=> System.today().addDays(-365)
		}));
		Insert testAccts;
	}

	@IsTest static void TriggerCreateAddlClients() {
		List<Account> accounts = [SELECT Id FROM Account WHERE RecordType.Name = :ACCOUNT_CLIENT_RT];
		Assert.areEqual(5, accounts.size());
		
		Test.startTest();		
		// Note; AddClientsToRenewalsBatch is called at the 
		//       end of the following batch
		Database.executebatch(New CreateRenewalsBatchable(), 20);		
		Test.stopTest();

		// asserts here
		List<Renewal__c> afterRenewals = [Select Id, (select id from Clients__r) from Renewal__c];
		Assert.areEqual(1, afterRenewals.size());
		Assert.areEqual(4, afterRenewals[0].Clients__r.size());
	}
	
}