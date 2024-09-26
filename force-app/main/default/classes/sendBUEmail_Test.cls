/**
 * @description sendBUEmail_Test contains tests for the sendBUEmailMessage class.
 */
@IsTest
private class sendBUEmail_Test {
	@IsTest
	static void test() {
		Test.startTest();

		Id jobId = Database.ExecuteBatch(new sendBUEmailMessage(), 200);

		Test.stopTest();

		// Test runs through all the success batch code, but does not confirm work.
		Assert.areNotEqual(null, jobId, 'A Job should have been created.');
		Assert.areEqual(1, sendBUEmailMessage.sentEmails.size(), 'Should have sent 1 email');
	}

	@IsTest
	static void test_All_Base() {
		insert new orgWide__c(SetupOwnerId = UserInfo.getOrganizationId(), BU_Email_Batch_Size__c = 2);

		Test.startTest();

		sendBUEmail_Schedulable schedule = new sendBUEmail_Schedulable();
		schedule.execute(null);

		Test.stopTest();

		// Test runs uns through all the success code, but does not confirm work.
		Assert.areEqual(1, sendBUEmailMessage.sentEmails.size(), 'Should have sent 1 email');
	}

	@IsTest
	public static void test_start() {
		Test.startTest();

		sendBUEmailMessage batch = new sendBUEmailMessage();

		Assert.areNotEqual(null, batch.start(null), 'Iterator should have been created');

		Test.stopTest();
	}

	@IsTest
	public static void test_execute_Send() {
		User areaManager = [SELECT Id FROM User WHERE Name = 'TEST AreaManager'];

		Test.startTest();

		sendBUEmailMessage batch = new sendBUEmailMessage();

		batch.execute(null, new List<User>{ areaManager });

		Test.stopTest();

		Assert.areNotEqual(0, sendBUEmailMessage.sentEmails.size(), 'Emails should be sent');
	}

	@IsTest
	public static void test_execute_NoSend() {
		Test.startTest();

		sendBUEmailMessage batch = new sendBUEmailMessage();

		batch.execute(null, new List<User>());

		Test.stopTest();

		Assert.areEqual(0, sendBUEmailMessage.sentEmails.size(), 'No emails sent');
	}

	@IsTest
	public static void test_finish_NoErrors() {
		DateTime timeStart = DateTime.now();

		Test.startTest();

		sendBUEmailMessage batch = new sendBUEmailMessage();

		batch.finish(null);

		Test.stopTest();

		Assert.areEqual(0, Log_Test.recentLogs(timeStart).size(), 'No error should be logged');
	}

	@IsTest
	public static void test_finish_Errors() {
		DateTime timeStart = DateTime.now();

		Test.startTest();

		sendBUEmailMessage batch = new sendBUEmailMessage();
		batch.errors = 'Testing errors Log';

		batch.finish(null);

		Test.stopTest();

		Assert.areEqual(1, Log_Test.recentLogs(timeStart).size(), 'Error should be logged');
	}

	@IsTest
	public static void test_finish() {
		DateTime startTest = DateTime.now();

		Test.startTest();

		sendBUEmailMessage batch = new sendBUEmailMessage();
		batch.errors = 'Test error message';

		batch.finish(null);

		Test.stopTest();

		Assert.areEqual(1, Log_Test.recentLogs(startTest).size(), 'Log should have been created.');
	}

	@TestSetup
	private static void makeData() {
		User am = TestFactoryUser.makeAreaManager('TEST', 'AreaManager', '9001');

		Account branch = TestFactory.createAccountBranch(
			'TEST BRANCH',
			'9001',
			am.FirstName + ' ' + am.LastName,
			am.Email,
			true
		);


		User employee = TestFactoryUser.makeUser('Person', 'Employee', 'BBSI Standard', '9001');
		insert new List<User>{ am, employee };

		Contact employeeContact = TestFactory.createContactEmployee(employee.Id, employee.LastName, branch.Id, true);

		Business_Unit__c bu1 = TestFactory.createBusinessUnit('TEST BU1', branch, true);

		TestFactory.createBusinessUnitContact(bu1, true, 'Business Partner', employeeContact, true);
	}
}