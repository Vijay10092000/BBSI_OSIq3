/**
 * @description BusinessActivityReport_TestEnv creates a test environment
 * for aid in testing the BusinessActivityReport code.
 *
 * BRANCH HOME
 *   AREA MANAGER:  areaManagerHome (Not created)
 *   BDMS:          --none--
 * BRANCH ONE
 *   AREA MANAGER:  areaManagerOne
 *   BDMS:          bdmOne
 * BRANCH TWO
 *   AREA MANAGER:  areaManagerTwo
 *   BDMS:          bdmTwo
 * BRANCH THREE
 *   AREA MANAGER:  areaManagerThree
 *   BDMS:          bdmThree
 *
 */
@IsTest
@SuppressWarnings(
	'PMD.ApexAssertionsShouldIncludeMessage,PMD.ExcessivePublicCount,PMD.TooManyFields,PMD.FieldNamingConventions,PMD.LocalVariableNamingConventions'
)
public without sharing class BusinessActivityReport_TestEnv {
	public Account branchHome;
	public Account branchOne;
	public Account branchTwo;
	public Account branchThree;
	public Account accountProspect1_1;
	public Account accountProspect2_1;
	public Account accountClient1_1;
	public Account accountClient1_2;
	public Account accountClient2_1;
	public Account accountClient3_1;

	public User systemAdmin;
	public User userReportManager;
	public User userOther;

	public User areaManagerOne;
	public User areaManagerTwo;
	public User areaManagerThree;

	public User bdmOne;
	public User bdmTwo;
	public User bdmThree;
	public User bdmInactive;

	public Lead leadClient1_1;
	public Lead leadClient1_2;
	public Lead leadClient2_1;
	public Lead leadClient3_1;
	public Lead leadRp1_1;
	public Lead leadRp2_1;

	public Business_Activity_Goal__c goal2020Q1;
	public Business_Activity_Goal__c goal2020Q2;
	public Business_Activity_Goal__c goal2021Q1;
	public Business_Activity_Goal__c goal2021Q4;
	public Business_Activity_Goal__c goal2022Q3;

	/**
	 * @description loadData reads the created test data.
	 */
	@SuppressWarnings('PMD.NcssConstructorCount')
	public void loadData() {
		List<Account> branches = [
			SELECT Id, Name, External_Id__c
			FROM Account
			WHERE Name IN ('BRANCH Home', 'BRANCH One', 'BRANCH Two', 'BRANCH Three')
			ORDER BY External_Id__c
		];
		Assert.areEqual(4, branches.size());
		branchHome = branches.get(0);
		branchOne = branches.get(1);
		branchThree = branches.get(2);
		branchTwo = branches.get(3);


		List<User> ams = [SELECT Id, Name, Branch_Id__c, ProfileId FROM User WHERE Name LIKE 'AreaManager%' ORDER BY Branch_Id__c];
		Assert.areEqual(3, ams.size());
		areaManagerOne = ams.get(0);
		areaManagerThree = ams.get(1);
		areaManagerTwo = ams.get(2);
		Assert.areEqual('AreaManagerTwo', areaManagerTwo.Name);

		List<User> bdms = [
			SELECT Id, Name, Branch_Id__c, ProfileId
			FROM User
			WHERE Name IN ('Bdm1', 'Bdm2', 'Bdm3', 'BdmInactive')
			ORDER BY Name];
		Assert.areEqual(4, bdms.size());
		bdmOne = bdms.get(0);
		bdmTwo = bdms.get(1);
		bdmThree = bdms.get(2);
		BdmInactive = bdms.get(3);
		Assert.areEqual('Bdm3', bdmThree.Name);

		userReportManager = [SELECT Id, Name, Branch_Id__c, ProfileId FROM User WHERE Name = 'userReportManager' LIMIT 1];
		userOther = [SELECT Id, Name, Branch_Id__c, ProfileId FROM User WHERE Name = 'Other' LIMIT 1];

		List<Lead> leads = [
			SELECT Id, Name, Branch__c, Business_Development_Manager__c, Converted__c, OwnerId, Status
			FROM Lead
			ORDER BY Name ASC
		];
		Assert.areEqual(6, leads.size());
		leadClient1_1 = leads.get(0);
		leadClient1_2 = leads.get(1);
		leadClient2_1 = leads.get(2);
		leadClient3_1 = leads.get(3);
		leadRp1_1 = leads.get(4);
		leadRp2_1 = leads.get(5);
		Assert.areEqual('RP1-1', leadRp1_1.Name);

		List<Account> accounts = [
			SELECT Id, Name, Prospect_Branch__c, Business_Development_Manager__c, OwnerId, Status__c
			FROM Account
			WHERE RecordType.Name IN ('Prospect', 'Client')
			ORDER BY Name ASC
		];
		Assert.areEqual(6, accounts.size());
		accountClient1_1 = accounts.get(0);
		accountClient1_2 = accounts.get(1);
		accountClient2_1 = accounts.get(2);
		accountClient3_1 = accounts.get(3);
		accountProspect1_1 = accounts.get(4);
		accountProspect2_1 = accounts.get(5);

		List<Business_Activity_Goal__c> goals = [
			SELECT
				Id,
				Name,
				Start_Year__c,
				Start_Quarter__c,
				Start_Year_Quarter__c,
				Override__c,
				Discovery_Meetings__c,
				Events__c,
				Lost_Clients_Contacted__c,
				Lost_Leads_Contacted__c,
				New_Leads__c,
				New_Referral_Partners_Contacted__c,
				Producer_Tracks_Info_Sessions__c,
				New_Clients__c,
				Referral_Partner_Plans_In_Place__c,
				Referral_Partner_Touches__c,
				RP_Touches_In_Person__c,
				RP_Touches_Virtual__c,
				WSE_Added__c
			FROM Business_Activity_Goal__c
			ORDER BY Start_Year_Quarter__c ASC
		];
		Assert.areEqual(5, goals.size());
		goal2020Q1 = goals.get(0);
		goal2020Q2 = goals.get(1);
		goal2021Q1 = goals.get(2);
		goal2021Q4 = goals.get(3);
		goal2022Q3 = goals.get(4);
	}

	/**
	 * @description createData creates the Test Environment data.
	 */
	public void createData() {
		createBranches();
		createUsers();
		createLeads();
		createAccounts();
		createGoals();
	}

	private void createBranches() {
		/*branchHome = TestFactory.createAccountBranch(
			'BRANCH Home',
			'HOME',
			'AreaManagerHome',
			'areamanager.Home@bbsi.zzz',
			false
		);
		branchOne = TestFactory.createAccountBranch(
			'BRANCH One',
			'ONE',
			'AreaManagerOne',
			'areamanager.One@bbsi.zzz',
			false
		);
		branchTwo = TestFactory.createAccountBranch(
			'BRANCH Two',
			'TWO',
			'AreaManagerTwo',
			'areamanager.Two@bbsi.zzz',
			false
		);
		branchThree = TestFactory.createAccountBranch(
			'BRANCH Three',
			'THREE',
			'AreaManagerThree',
			'areamanager.Three@bbsi.zzz',
			false
		);*/

		branchHome = TestFactoryAccount.makeBranch(
			'BRANCH Home',
			'HOME',
			'AreaManagerHome',
			'areamanager.Home@bbsi.zzz'
		);
		branchOne = TestFactoryAccount.makeBranch(
			'BRANCH One',
			'ONE',
			'AreaManagerOne',
			'areamanager.One@bbsi.zzz'
		);
		branchTwo = TestFactoryAccount.makeBranch(
			'BRANCH Two',
			'TWO',
			'AreaManagerTwo',
			'areamanager.Two@bbsi.zzz'
		);
		branchThree = TestFactoryAccount.makeBranch(
			'BRANCH Three',
			'THREE',
			'AreaManagerThree',
			'areamanager.Three@bbsi.zzz'
		);

		insert new List<Account>{ branchHome, branchOne, branchTwo, branchThree };
	}

	private void createUsers() {
		/*User systemAdmin = TestFactory.createUser(
			'BarTestEnv',
			'BarTestEnv@bbsi.zzz',
			'BarTestEnv@bbsi.zzz',
			'System Administrator',
			'HOME',
			true
		);*/

		User systemAdmin = TestFactoryUser.makeUser(
			null, 
			'BarTestEnv', 
			'System Administrator', 
			'HOME', 
			'BarTestEnv@bbsi.zzz', 
			'BarTestEnv@bbsi.zzz'
		);
		insert systemAdmin;

		System.runAs(systemAdmin) {
			/*areaManagerOne = TestFactory.createUserAM('AreaManagerOne', 'ONE', false);
			areaManagerTwo = TestFactory.createUserAM('AreaManagerTwo', 'TWO', false);
			areaManagerThree = TestFactory.createUserAM('AreaManagerThree', 'THREE', false);
			bdmOne = TestFactory.createUserBDM('Bdm1', 'acronym', 'BBSI Standard', 'ONE', false);
			bdmTwo = TestFactory.createUserBDM('Bdm2', 'acronym', 'BBSI Standard', 'TWO', false);
			bdmThree = TestFactory.createUserBDM('Bdm3', 'acronym', 'BBSI Standard', 'THREE', false);
			userReportManager = TestFactory.createUser('userReportManager', 'BBSI Standard', 'ONE', false);
			userOther = TestFactory.createUser('Other', 'BBSI Standard', 'ONE', false);
			bdmInactive = TestFactory.createUserBDM('BdmInactive', 'acronym', 'BBSI Standard', 'ONE', false);*/
			areaManagerOne = TestFactoryUser.makeAreaManager(null, 'AreaManagerOne', 'ONE');
			areaManagerTwo = TestFactoryUser.makeAreaManager(null, 'AreaManagerTwo', 'TWO');
			areaManagerThree = TestFactoryUser.makeAreaManager(null, 'AreaManagerThree', 'THREE');
			bdmOne = TestFactoryUser.makeBDM(null, 'Bdm1', 'BBSI Standard', 'ONE');
			bdmOne.Acronym__c = 'acronym';
            bdmTwo = TestFactoryUser.makeBDM(null, 'Bdm2', 'BBSI Standard', 'TWO');
			bdmTwo.Acronym__c = 'acronym';
            bdmThree = TestFactoryUser.makeBDM(null, 'Bdm3', 'BBSI Standard', 'THREE');
			bdmThree.Acronym__c = 'acronym';
			userReportManager = TestFactoryUser.makeUser(null, 'userReportManager', 'BBSI Standard', 'ONE');
			userOther = TestFactoryUser.makeUser(null, 'Other', 'BBSI Standard', 'ONE');
			bdmInactive = TestFactoryUser.makeBDM(null, 'BdmInactive', 'BBSI Standard', 'ONE');
			bdmInactive.Acronym__c = 'acronym';
			bdmInactive.IsActive = false;

			insert new List<User>{
				areaManagerOne,
				areaManagerTwo,
				areaManagerThree,
				bdmOne,
				bdmTwo,
				bdmThree,
				userReportManager,
				userOther,
				bdmInactive
			};

			PermissionSet ps = [SELECT Id FROM PermissionSet WHERE Name = 'Business_Activity_Report'];
			insert new PermissionSetAssignment(PermissionSetId = ps.Id, AssigneeId = userReportManager.Id);
		}
	}

	private void createLeads() {
		Lead leadClient1_1 = TestFactoryLead.makeClientLead(
			null, 'Client1-1',
			'Client1-1',
			branchOne.Id,
			bdmOne.Id
		);
		Lead leadClient1_2 = TestFactoryLead.makeClientLead(
			null, 'Client1-2',
			'Client1-2',
			branchOne.Id,
			bdmOne.Id
		);
		Lead leadClient2_1 = TestFactoryLead.makeClientLead(
			null, 'Client2-1',
			'Client2-1',
			branchTwo.Id,
			bdmOne.Id
		);
		Lead leadClient3_1 = TestFactoryLead.makeClientLead(
			null, 'Client3-1',
			'Client3-1',
			branchThree.Id,
			bdmOne.Id
		);
		Lead leadRp1_1 = TestFactoryLead.makeLeadRP(
			null, 'RP1-1',
			'RP1-1'
		);
		Lead leadRp2_1 = TestFactoryLead.makeLeadRP(
			null, 'RP2-1',
			'RP2-1'
		);

		leadClient1_1.OwnerId = bdmOne.Id;
		leadClient1_2.OwnerId = bdmOne.Id;
		leadClient2_1.OwnerId = bdmTwo.Id;
		leadClient3_1.OwnerId = bdmThree.Id;
		leadRp1_1.OwnerId = bdmOne.Id;
		leadRp2_1.OwnerId = bdmTwo.Id;
		insert new List<Lead>{ leadClient1_1, leadClient1_2, leadClient2_1, leadClient3_1, leadRp1_1, leadRp2_1 };
	}

	private void createAccounts() {
		Date today = Date.today();

		/*accountClient1_1 = TestFactory.createAccountClient('CLIENT 1', false);
		accountClient1_2 = TestFactory.createAccountClient('CLIENT 4', false);
		accountClient2_1 = TestFactory.createAccountClient('CLIENT 2', false);
		accountClient3_1 = TestFactory.createAccountClient('CLIENT 3', false);
		accountProspect1_1 = TestFactory.createAccountProspect('PROSPECT 1', false);
		accountProspect2_1 = TestFactory.createAccountProspect('PROSPECT 2', false);*/

		accountClient1_1 = TestFactoryAccount.makeClient('CLIENT 1', null, null);
		accountClient1_2 = TestFactoryAccount.makeClient('CLIENT 4', null, null);
		accountClient2_1 = TestFactoryAccount.makeClient('CLIENT 2', null, null);
		accountClient3_1 = TestFactoryAccount.makeClient('CLIENT 3', null, null);
		accountProspect1_1 = TestFactoryAccount.makeClient('PROSPECT 1', null, null);
		accountProspect2_1 = TestFactoryAccount.makeClient('PROSPECT 2', null, null);

		accountClient1_1.Business_Development_Manager__c = bdmOne.Id;
		accountClient1_1.Prospect_Branch__c = branchOne.Id;
		accountClient1_1.OwnerId = bdmOne.Id;
		accountClient1_1.Status__c = 'Active';
		accountClient1_1.Start_Date__c = today;
		accountClient1_2.Business_Development_Manager__c = bdmOne.Id;
		accountClient1_2.Prospect_Branch__c = branchOne.Id;
		accountClient1_2.OwnerId = bdmOne.Id;
		accountClient1_2.Status__c = 'Active';
		accountClient1_2.Start_Date__c = today;
		accountClient2_1.Business_Development_Manager__c = bdmOne.Id;
		accountClient2_1.Prospect_Branch__c = branchTwo.Id;
		accountClient2_1.OwnerId = bdmOne.Id;
		accountClient2_1.Status__c = 'Active';
		accountClient2_1.Start_Date__c = today;
		accountClient3_1.Business_Development_Manager__c = bdmOne.Id;
		accountClient3_1.Prospect_Branch__c = branchThree.Id;
		accountClient3_1.OwnerId = bdmThree.Id;
		accountClient3_1.Status__c = 'Active';
		accountClient3_1.Start_Date__c = today;
		accountProspect1_1.Business_Development_Manager__c = bdmOne.Id;
		accountProspect1_1.Prospect_Branch__c = branchOne.Id;
		accountProspect1_1.OwnerId = bdmOne.Id;
		accountProspect1_1.Status__c = 'Active';
		accountProspect2_1.Business_Development_Manager__c = bdmOne.Id;
		accountProspect2_1.Prospect_Branch__c = branchTwo.Id;
		accountProspect2_1.OwnerId = bdmTwo.Id;
		accountProspect2_1.Status__c = 'Active';
		insert new List<Account>{
			accountClient1_1,
			accountClient1_2,
			accountClient2_1,
			accountClient3_1,
			accountProspect1_1,
			accountProspect2_1
		};
	}

	private void createGoals() {
		insert new List<Business_Activity_Goal__c>{
			TestFactoryBusinessActivityGoal.makeBusinessActivityGoal(2020, 1, false, 1, null),
			TestFactoryBusinessActivityGoal.makeBusinessActivityGoal(2020, 2, false, 2, null),
			TestFactoryBusinessActivityGoal.makeBusinessActivityGoal(2021, 1, false, 3, null),
			TestFactoryBusinessActivityGoal.makeBusinessActivityGoal(2021, 4, false, 4, null),
			TestFactoryBusinessActivityGoal.makeBusinessActivityGoal(2022, 3, false, 5, null)
		};
	}

	/*private static Business_Activity_Goal__c makeTestGoal(
		Integer year,
		Integer quarter,
		Boolean isOverride,
		Integer value
	) {
		return new Business_Activity_Goal__c(
			Start_Year__c = String.valueOf(year),
			Start_Quarter__c = 'Quarter ' + quarter,
			Override__c = isOverride,
			Discovery_Meetings__c = value,
			Events__c = value,
			Lost_Clients_Contacted__c = value,
			Lost_Leads_Contacted__c = value,
			New_Clients__c = value,
			New_Leads__c = value,
			New_Referral_Partners_Contacted__c = value,
			Producer_Tracks_Info_Sessions__c = value,
			Referral_Partner_Plans_In_Place__c = value,
			Referral_Partner_Touches__c = value,
			RP_Touches_In_Person__c = value,
			RP_Touches_Virtual__c = value,
			WSE_Added__c = value
		);
	}*/
}