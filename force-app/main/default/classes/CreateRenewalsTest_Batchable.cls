@IsTest
private class CreateRenewalsTest_Batchable {
	static final String ACCOUNT_CLIENT_RT = 'Client';

	@TestSetup 
	static void setup() {
		Account branch = TestFactoryAccount.createBranch('TEST BRANCH');

		List<Account> testAccts = new List<Account>();
		String fein = '00-1234567';
		
		Business_Unit__c bizUnit = TestFactoryBusinessUnit.makeBusinessUnit('foo unit', branch.Id);
		insert bizUnit;

		Integer extId = 900000;
		
		for (integer i = 0; i < 3; i++) {
			testAccts.add(TestFactoryAccount.makeAccount(ACCOUNT_CLIENT_RT, new Map<String, Object>{
				'Name'=> 'test acct ' + i,
				'External_ID__c'=> (extId + i).format(),
				'Business_Unit__c'=> bizUnit.Id,
				'Renewal_Date__c'=> System.today().addDays(20),
				'Start_Date__c'=> System.today().addDays(-365),
				'Fein__c' => '99-7654321'
			}));	
		}
		
		testAccts.add(TestFactoryAccount.makeAccount(ACCOUNT_CLIENT_RT, new Map<String, Object>{
			'Name'=> 'staffing acct',
			'External_ID__c'=> '990001',
			'Business_Unit__c'=> bizUnit.Id,
			'Renewal_Date__c'=> System.today().addDays(10),
			'Start_Date__c'=> System.today().addDays(-365),
			'Fein__c' => fein
		}));
		
		// Add one with a very long name, exceeding max length of 80 characters
		String longName = 'test acct test acct test acct test acct test acct test acct test acct test acct test acct test acct';
		
		testAccts.add(TestFactoryAccount.makeAccount(ACCOUNT_CLIENT_RT, new Map<String, Object>{
			'Name'=> longName,
			'External_ID__c'=> '900099',
			'Business_Unit__c'=> bizUnit.Id,
			'Renewal_Date__c'=> System.today().addDays(20),
			'Start_Date__c'=> System.today().addDays(-365),
			'Fein__c' => '99-1234567'
		}));         

		insert(testAccts);		
	}

	@IsTest
	static void createAndConfirmRenewals() {
		// Run schedulable to batchable
		Test.startTest();

		CreateRenewalsSchedulable renewalsSchedulable = new CreateRenewalsSchedulable();
		renewalsSchedulable.execute(null);

		test.StopTest();

		List<Account> accts = [SELECT Id, Name FROM Account];
		List<Renewal__c> newRenewals = [SELECT Id, (SELECT Id FROM Clients__r) FROM Renewal__c];
		List<RenewalClientAssoc__c> newRenewalAssocList = [SELECT Id FROM RenewalClientAssoc__c];
		Assert.areEqual(2, newRenewals.size());
		Assert.areEqual(3, newRenewals[1].Clients__r.size());
	}
}