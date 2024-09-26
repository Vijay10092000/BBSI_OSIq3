/**
 * @description AccountProspect_Test contains tests for the AccountProspect class.
 */
@IsTest
public without sharing class AccountProspect_Test {
	private static Account branch1;
	private static Account branch2;
	private static Business_Unit__c bu1A;
	private static Business_Unit__c bu1B;
	private static Business_Unit__c bu2;

	private static void buildBusinessUnitEnvironment() {
		branch1 = TestFactory.createAccountBranch('Branch 1', '001', 'Jon Noone', 'jon.noone@bbsi.zzz', false);
		branch1.Email_BU_when_Prospect_Assigned__c = true;
		branch2 = TestFactory.createAccountBranch('Branch 2', '002', 'Jane Noone', 'jane.noone@bbsi.zzz', false);
		branch2.Email_BU_when_Prospect_Assigned__c = false;
		Account client1 = TestFactory.createAccountClient('Client 1', false);
		Account client2 = TestFactory.createAccountClient('Client 2', false);
		Account client3 = TestFactory.createAccountClient('Client 3', false);
		insert new List<Account>{ branch1, branch2, client1, client2, client3 };

		User user1 = TestFactory.createUser('User1', 'user1@bbsi.zzz', 'user1@bbsi.zzz', 'BBSI Standard', '001', false);
		User user2 = TestFactory.createUser('User2', 'user2@bbsi.zzz', 'user2@bbsi.zzz', 'BBSI Standard', '001', false);
		User user3 = TestFactory.createUser('User3', 'user3@bbsi.zzz', 'user3@bbsi.zzz', 'BBSI Standard', '002', false);
		insert new List<User>{ user1, user2, user3 };

		Contact contact1 = TestFactory.createContactEmployee(user1.Id, 'User1', branch1.Id, false);
		Contact contact2 = TestFactory.createContactEmployee(user2.Id, 'User2', branch1.Id, false);
		Contact contact3 = TestFactory.createContactEmployee(user3.Id, 'User3', branch2.Id, false);
		insert new List<Contact>{ contact1, contact2, contact3 };

		bu1A = TestFactory.createBusinessUnit('Test BU 1A', branch1, false);
		bu1B = TestFactory.createBusinessUnit('Test BU 1B', branch1, false);
		bu2 = TestFactory.createBusinessUnit('Test BU 2', branch2, false);
		insert new List<Business_Unit__c>{ bu1A, bu1B, bu2 };

		Business_Unit_Contact__c buc11A = TestFactory.createBusinessUnitContact(bu1A, true, 'Business Partner', contact1, false);
		Business_Unit_Contact__c buc11B = TestFactory.createBusinessUnitContact(bu1B, true, 'Payroll Specialist', contact1, false);
		Business_Unit_Contact__c buc21A = TestFactory.createBusinessUnitContact(bu1A, true, 'Business Partner', contact2, false);
		Business_Unit_Contact__c buc21B = TestFactory.createBusinessUnitContact(bu1B, true, 'Payroll Specialist', contact2, false);
		Business_Unit_Contact__c buc32 = TestFactory.createBusinessUnitContact(bu2, true, 'Business Partner', contact3, false);
		insert new List<Business_Unit_Contact__c>{ buc11A, buc11B, buc21A, buc21B, buc32 };

		Business_Unit_Member__c bum1 = TestFactory.createBusinessUnitMember(buc11A, client1, false);
		Business_Unit_Member__c bum2 = TestFactory.createBusinessUnitMember(buc21B, client2, false);
		Business_Unit_Member__c bum3 = TestFactory.createBusinessUnitMember(buc32, client3, false);
		insert new List<Business_Unit_Member__c>{ bum1, bum2, bum3 };
	}

	@IsTest
	public static void test_sendEmailAssignedBU() {
		buildBusinessUnitEnvironment();

		Account prospect1 = TestFactory.createAccountProspect('Prospect 1', false);
		prospect1.Business_Unit__c = bu1A.Id;
		Account prospect2 = TestFactory.createAccountProspect('Prospect 2', false);
		prospect2.Business_Unit__c = bu2.Id;

		Test.startTest();

		insert new List<Account>{ prospect1, prospect2 };

		Test.stopTest();

		System.assertEquals(1, Email_Service.testEmails.size(), 'Only prospect1 has BU which allows the email');
	}

	@IsTest
	public static void test_setPriceApprovalDate() {
		Date today = Date.today();

		Account client1 = TestFactoryAccount.makeClient('Client 1', null, null);
		Account prospect1 = TestFactoryAccount.makeProspect('Prospect 1', null, null);
		Account prospect2 = TestFactoryAccount.makeProspect('Prospect 2', null, null);

		client1.Price_Approval__c = 'Approved';
		prospect1.Price_Approval__c = 'Approved';
		prospect2.Price_Approval__c = 'Denied';

		insert new List<Account>{ client1, prospect1, prospect2 };

		List<Id> idAccounts = new List<Id>{ client1.Id, prospect1.Id, prospect2.Id };

		List<Account> accounts = [
			SELECT Id, Name, RecordTypeId, Price_Approval__c, Price_Approval_Date__c
			FROM Account
			WHERE Id IN :idAccounts
			ORDER BY Name ASC
		];

		client1 = accounts.get(0);
		prospect1 = accounts.get(1);
		prospect2 = accounts.get(2);

		Assert.areEqual(today, client1.Price_Approval_Date__c);
		Assert.areEqual(today, prospect1.Price_Approval_Date__c);
		Assert.isNull(prospect2.Price_Approval_Date__c);

		Test.startTest();

		Account client1Old = client1.clone(true, true, true, true);
		Account prospect1Old = prospect1.clone(true, true, true, true);
		Account prospect2Old = prospect2.clone(true, true, true, true);

		prospect1.Price_Approval__c = null;		
		prospect2.Price_Approval__c = 'Approved';

		List<Account> oldAccounts = new List<Account>{ client1Old, prospect1Old, prospect2Old };
		List<Account> newAccounts = new List<Account>{ client1, prospect1, prospect2 };

		AccountProspect.setPriceApprovalDate(new Map<Id, Account>(oldAccounts), newAccounts);

		Test.stopTest();

		Assert.areEqual(today, client1.Price_Approval_Date__c);
		Assert.areEqual(today, prospect1.Price_Approval_Date__c);
		Assert.areEqual(today, prospect2.Price_Approval_Date__c);
	}
}