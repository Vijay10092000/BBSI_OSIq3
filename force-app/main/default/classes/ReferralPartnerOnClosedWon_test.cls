/**
 * @description ReferralPartnerOnClosedWon_test
 */
@IsTest
public class ReferralPartnerOnClosedWon_test {
	@TestSetup
	public static void setup() {
		insert new NAICS_Code__c(Name = '111120', NAICS_Title__c = 'Test code');

		User sysAdmin = [SELECT Id FROM User WHERE IsActive = TRUE AND Profile.Name = 'System Administrator' LIMIT 1];

		Account branch;

		System.runAs(sysAdmin) {
			branch = TestFactoryAccount.makeBranch('TEST_BRANCH');
			branch.Branch_Manager__c = 'Area Manager';
			branch.Branch_Manager_Email__c = 'AreaManager@bbsihq.com';
			branch.Region__c = 'SoCal';
			branch.Zone__c = '1';
			insert branch;
		}

		User areaManager = TestFactoryUser.makeAreaManager('Area', 'Manager', branch.External_Id__c);
		User userBDM = TestFactoryUser.makeBDM(null, 'UserBDM', 'BBSI Standard', '910');
		insert new List<User>{ areaManager, userBDM };

		Business_Unit__c bu1 = TestFactoryBusinessUnit.createBusinessUnit('Test BU', branch);
		Contact c = TestFactoryContact.makeEmployee(null, 'BU', 'Contact', branch.Id);
		c.User_Id__c = userBDM.Id;
		Contact c1 = TestFactoryContact.makeClient('Dave', 'Smith', branch.Id);
		insert new List<Contact>{ c, c1 };

		Business_Unit_Contact__c buc = TestFactoryBusinessUnitContact.makeBusinessUnitContact(
			bu1,
			true,
			'Payroll Specialist',
			null
		);
		buc.Active__c = true;
		buc.BU_Member__c = c.Id;
		buc.Active_Date__c = System.Today();
		insert buc;

		Account client = TestFactoryAccount.makeClient('Test Account', null, null);
		client.OwnerId = areaManager.Id;
		client.NAICS__c = '111120';
		client.Business_Unit__c = bu1.Id;

		Account rpartner = TestFactoryAccount.makeReferralPartner('Test Referral Partner', '% of Margin', 12.34, null);
		insert new List<Account>{ client, rpartner };

		Ok_For_Risk_Access__c okRisk = new Ok_For_Risk_Access__c();
		okRisk.Name = 'Area Manager';
		insert okRisk;

		Admin_Branch__c adbranch = new Admin_Branch__c();
		adbranch.Name = 'TEST_BRANCH';
		adbranch.Admin_User__c = 'Area Manager';
		insert adbranch;

		System.runAs(areaManager) {
			Opportunity opp = TestFactoryOpportunity.makeClient('Test', client.Id, System.Today().AddDays(30), 'Identifying');
			opp.Est_Preferred_Payroll_Annual_Billing__c = 3.50;
			opp.Est_Fee_Only_Annual_Billing__c = 3.50;
			opp.Est_Staffing_Annual_Billing__c = 3.50;
			insert opp;
		}
	}

	@IsTest
	public static void test() {
		test.StartTest();

		Opportunity opp = [
			SELECT Id, Request_OK_For_Risk_Approval__c, AccountId
			FROM Opportunity
			WHERE Name = 'Test'
			LIMIT 1
		];

		Account client = [
			SELECT Id, Prospect_Branch__c, Prospect_Branch__r.Branch_Manager_Email__c
			FROM Account
			WHERE Id = :opp.AccountId
			LIMIT 1
		];
		Account rpartner = [SELECT Id FROM Account WHERE Name = 'Test Referral Partner' LIMIT 1];

		opp.Request_OK_For_Risk_Approval__c = true;
		opp.OK_For_Risk_Approval_Status__c = 'Approved';
		opp.Request_Credit_Approval__c = true;
		opp.Credit_Approval_Status__c = 'Approved';
		opp.AM_Approval_Status__c = 'Approved';
		opp.Request_Area_Manager_Approval__c = true;
		opp.Amount = 200000.00;
		update opp;

		Referral_Partner__c rp1 = new Referral_Partner__c();
		rp1.Opportunity__c = opp.Id;
		rp1.Account__c = client.Id;
		rp1.Referral_Partner__c = rpartner.Id;

		Referral_Partner__c rp2 = new Referral_Partner__c();
		rp2.Opportunity__c = opp.Id;
		rp2.Account__c = client.Id;
		rp2.Referral_Partner__c = rpartner.Id;

		insert new List<Referral_Partner__c>{ rp1, rp2 };

		opp.StageName = 'Creation of Shell';
		update opp;

		test.StopTest();
	}
}