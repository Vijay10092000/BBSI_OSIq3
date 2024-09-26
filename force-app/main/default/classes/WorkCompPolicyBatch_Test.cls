/**
 * @description WorkCompPolicyBatch_Test contains tests for the WorkCompPolicyBatch class.
 */
@IsTest
public without sharing class WorkCompPolicyBatch_Test {
	private static Account branch;
	private static Account prospectNEW1;
	private static Account prospectNEW2;
	private static Account prospectOLD1;
	private static Account prospectOLD2;

	@TestSetup
	static void makeData() {
		branch = TestFactoryAccount.createBranch('BRANCH', '999', null, null);
		User u = TestFactoryUser.createUser(
			null,
			'UserAdmin',
			'System Administrator',
			'999'
		);

		System.runAs(u) {
			Date today = System.today();

			prospectNEW1 = TestFactoryAccount.makeProspect('New Prospect 1', null, null);
			prospectNEW1.Renewal_Date__c = today.addDays(30);
			prospectNEW1.Start_Date__c = today;
			prospectNEW1.BillingPostalCode = '97209';

            prospectNEW2 = TestFactoryAccount.makeProspect('New Prospect 2', null, null);
			prospectNEW2.Renewal_Date__c = null;
			prospectNEW2.Start_Date__c = null;
			prospectNEW2.BillingPostalCode = '97209';
			
            prospectOLD1 = TestFactoryAccount.makeProspect('Old Prospect 1', null, null);
			prospectOLD1.Renewal_Date__c = null;
			prospectOLD1.Start_Date__c = today.addDays(-7);
			prospectOLD1.BillingPostalCode = '97209';
			
            prospectOLD2 = TestFactoryAccount.makeProspect('Old Prospect 2', null, null);
			prospectOLD2.Renewal_Date__c = today.addDays(-90);
			prospectOLD2.Start_Date__c = today.addDays(-120);
			prospectOLD2.BillingPostalCode = '97209';

			insert new List<Account>{ prospectNEW1, prospectNEW2, prospectOLD1, prospectOLD2 };
		}
	}

	static void getData() {
		for (Account a : [
			SELECT Id, Name, CreatedDate, Renewal_Date__c, Start_Date__c, RecordType.Name, BillingPostalCode
			FROM Account
			WHERE RecordType.Name = 'Prospect' OR RecordType.Name = 'BBSI Branch'
		]) {
			if (a.Name == 'BRANCH') {
				branch = a;
			} else if (a.Name == 'New Prospect 1') {
				prospectNEW1 = a;
			} else if (a.Name == 'New Prospect 2') {
				prospectNEW2 = a;
			} else if (a.Name == 'Old Prospect 1') {
				prospectOLD1 = a;
			} else if (a.Name == 'Old Prospect 2') {
				prospectOLD2 = a;
			}
		}

		Assert.areNotEqual(null, branch, 'Branch hould be created');
		Assert.areNotEqual(null, prospectNEW1, 'Prospect New 1 should be created');
		Assert.areNotEqual(null, prospectNEW2, 'Prospect New 2 should be created');
		Assert.areNotEqual(null, prospectOLD1, 'Prospect Old 1 should be created');
		Assert.areNotEqual(null, prospectOLD2, 'Prospect Old 2 should be created');
	}

	@IsTest
	public static void test_start() {
		getData();

		WorkCompPolicyBatch batch = new WorkCompPolicyBatch();

		Test.startTest();

		Database.QueryLocator locator = batch.start(null);
		Assert.areNotEqual(null, locator, 'Did not find Prospect requiring renewal');

		Database.QueryLocatorIterator it = locator.iterator();

		Integer count = 0;

		while (it.hasNext()) {
			count++;

			Account a = (Account) it.next();
			Assert.isTrue(
				a.Id == prospectNEW2.Id ||
				a.Id == prospectOLD1.Id ||
				a.Id == prospectOLD2.Id,
				'Check has correct Prospects failed'
			);
		}

		Test.stopTest();

		Assert.areEqual(3, count, 'Should only have 3 Prospects');
	}

	@IsTest
	public static void test_execute() {
		getData();

		List<Account> accounts = new List<Account>{ prospectNEW2, prospectOLD1, prospectOLD2 };

		WorkCompPolicyBatch batch = new WorkCompPolicyBatch();

		Test.startTest();

		batch.execute(null, accounts);

		Test.stopTest();

		getData();

		Date today = Date.today();
		Assert.areEqual(today.addDays(-90).addYears(1), prospectOLD2.Renewal_Date__c, 'Renewal date incorrectly set');
		Assert.areEqual(today.addDays(-7).addYears(1), prospectOLD1.Renewal_Date__c, 'Renewal date incorrectly set');
	}

	@IsTest
	public static void test_finish() {
		DateTime startTest = DateTime.now();

		getData();

		WorkCompPolicyBatch batch = new WorkCompPolicyBatch();

		batch.errors = 'Test Error';

		Test.startTest();

		batch.finish(null);

		Test.stopTest();

		List<Log__c> logs = Log_Test.recentLogs(startTest);

		Assert.areEqual(1, logs.size(), 'Log record was not created');
	}
}