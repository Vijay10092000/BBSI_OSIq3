/**
 * @description AccountProspectOnboard_Test contains tests for the AccountProspectOnboard class.
 */
@IsTest
@SuppressWarnings('PMD.AvoidSystemDebugUsage, PMD.AvoidHardcodingId')
public without sharing class AccountProspectOnboard_Test {
	private static final Id ID_CONTRACTS_QUEUE = Id.valueOf('00G2J000003IPcq');

	private static Account branch;
	private static Account prospect;
	private static User owner;
	private static Contact userContact;

	@TestSetup
	static void makeData(){
        branch = TestFactoryAccount.createBranch('bbsiTESTBRANCH', '1000',null,null);
		owner = TestFactoryUser.createUser('bbsiTESTUSER', 'LASTNAME1', 'BBSI Standard', '1000');
        userContact = TestFactoryContact.createEmployee(owner.Id ,'bbsiTESTUSER','Testlast1' ,branch.Id);

		System.runAs(owner) {
			prospect = TestFactoryAccount.createProspect('bbsiTESTPROSPECT', null,null);
		}
	}

	static void readData() {

		branch = [SELECT Id, Name FROM Account WHERE RecordType.Name = 'BBSI Branch' AND Name = 'bbsiTESTBRANCH'];
		prospect = [SELECT Id, Name FROM Account WHERE RecordType.Name = 'Prospect' AND Name = 'bbsiTESTPROSPECT'];
		owner = [SELECT Id, Name FROM User WHERE LastName = 'LASTNAME1'];
		userContact = [SELECT Id, Name, User_Id__c FROM Contact WHERE RecordType.Name = 'BBSI Employee' AND  User_Id__c = :owner.Id];
    }

	@IsTest
	public static void test_createCase() {
		readData();
		
        Opportunity opp = TestFactoryOpportunity.makeClient(
			'OPP ' + prospect.Name,
			prospect.id,
			Date.today().addDays(10),
			'First Meeting');

		opp.States_of_Operation__c = 'WA,UT';

		insert opp;

		Case newCase = AccountProspectOnboard.createCase(
			opp,
			ID_CONTRACTS_QUEUE,
			prospect.Name,
			'ABCDEF',
			prospect.Id,
			userContact.Name,
			branch.Name,
			branch.Id
		);
		Assert.isNotNull(newCase, 'Case should have been created');
	}

	@IsTest
	public static void test_getUserContact() {
		readData();

		Contact contact;
		contact = AccountProspectOnboard.getUserContact(owner.Id);
		Assert.areEqual(userContact.Id, contact.Id, 'Contacts should be the same');

		Id idInvalid = Id.valueOf('00550000007SYYY');
		contact = AccountProspectOnboard.getUserContact(idInvalid);

		Assert.areEqual(null, contact, 'Contact should be null');
	}

	@IsTest
	public static void test_buildOnboardingCase() {
		readData();

		Opportunity opp = new Opportunity(
			AccountId = prospect.Id,
			States_of_Operation__c = 'WA,UT'
		);

		Case newCase = AccountProspectOnboard.buildOnboardingCase(opp);

		Assert.isNotNull(newCase, 'Case should be created');
		Assert.isTrue(newCase.Subject.contains(' - Onboard - '), 'Subject is wrong');
	}

	@IsTest
	public static void createOnboardingCase() {
		readData();
		
        Opportunity opp = TestFactoryopportunity.makeClient(
			'OPP ' + prospect.Name,
			prospect.id,
			Date.today().addDays(10),
			'First Meeting');

		opp.States_of_Operation__c = 'WA,UT';

		insert opp;

		Case newCase = AccountProspectOnboard.createOnboardingCase(opp);
		Assert.isNotNull(newCase, 'Case should have been created');
		Assert.isNotNull(newCase.Id, 'Case should have been inserted');
	}
}