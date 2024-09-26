/**
 * @description BusinessActivityGoal_Test contains tests for BusinessActivityGoal.
 */
@SuppressWarnings('PMD.ApexAssertionsShouldIncludeMessage, PMD.ApexDoc')
@IsTest
public with sharing class BusinessActivityGoal_Test {
	private static Account branchOne;
	private static Account branchTwo;
	private static Account branchThree;

	private static Id idrtGoalBDM;
	private static Id idrtGoalBranch;

	@TestSetup
	static void makeData() {
		Account branchOne = TestFactoryAccount.makeBranch('Branch-ONE');
		branchOne.BillingPostalCode = '99998';
		branchOne.ShippingPostalCode = '99998';
		branchOne.External_Id__c = 'ONE';

		Account branchTwo = TestFactoryAccount.makeBranch('Branch-TWO');
		branchTwo.BillingPostalCode = '99998';
		branchTwo.ShippingPostalCode = '99998';
		branchTwo.External_Id__c = 'TWO';

		Account branchThree = TestFactoryAccount.makeBranch('Branch-THREE');
		branchThree.BillingPostalCode = '99997';
		branchThree.ShippingPostalCode = '99997';
		branchThree.External_Id__c = 'THREE';

		insert new List<Account>{ branchOne, branchTwo, branchThree };

		insert new List<Business_Activity_Goal__c>{
			// For BDMs
			TestFactoryBusinessActivityGoal.makeBusinessActivityGoal(2018, 4, false, 1, (Id) null),
			TestFactoryBusinessActivityGoal.makeBusinessActivityGoal(2019, 3, false, 3, (Id) null),
			TestFactoryBusinessActivityGoal.makeBusinessActivityGoal(2020, 1, false, 5, (Id) null),
			TestFactoryBusinessActivityGoal.makeBusinessActivityGoal(2020, 2, false, 7, (Id) null),
			TestFactoryBusinessActivityGoal.makeBusinessActivityGoal(2020, 3, false, 9, (Id) null),
			TestFactoryBusinessActivityGoal.makeBusinessActivityGoal(2020, 4, false, 11, (Id) null),
			TestFactoryBusinessActivityGoal.makeBusinessActivityGoal(2021, 4, false, 13, (Id) null),
			// For Branches
			TestFactoryBusinessActivityGoal.makeBusinessActivityGoal(2020, 1, false, 1, branchOne.Id),
			TestFactoryBusinessActivityGoal.makeBusinessActivityGoal(2020, 2, false, 5, branchOne.Id),
			TestFactoryBusinessActivityGoal.makeBusinessActivityGoal(2020, 4, false, 9, branchOne.Id),
			TestFactoryBusinessActivityGoal.makeBusinessActivityGoal(2019, 2, false, 51, branchTwo.Id),
			TestFactoryBusinessActivityGoal.makeBusinessActivityGoal(2019, 4, false, 53, branchTwo.Id),
			TestFactoryBusinessActivityGoal.makeBusinessActivityGoal(2020, 1, false, 13, branchTwo.Id),
			TestFactoryBusinessActivityGoal.makeBusinessActivityGoal(2020, 3, false, 17, branchTwo.Id)
		};
	}

	static void readData() {
		idrtGoalBDM = RecordTypeService.getId('Business_Activity_Goal__c', 'BDM Goal');
		idrtGoalBranch = RecordTypeService.getId('Business_Activity_Goal__c', 'Branch Goal');

		List<Account> branches = [
			SELECT Id, Name
			FROM Account
			WHERE RecordType.Name = 'BBSI Branch' AND Name LIKE 'Branch-%'
			ORDER BY Name
		];

		branchOne = branches.get(0);
		branchThree = branches.get(1);
		branchTwo = branches.get(2);
	}

    /**
     * @description makeBusinessActivityGoal description
     * @param  year       Year of the goal
     * @param  quarter    Quarter (1-4 or 0 for full year)
     * @param  isOverride ???
     * @param  value      Value to put into all the goal fields
     * @param  idBranch   If set, the branch goals, else for BDMs
     * @return A new Business_Activity_Goal__c
     */
	public static Business_Activity_Goal__c makeBusinessActivityGoal(Integer year, Integer quarter, Boolean isOverride, Integer value, Id idBranch) {
		Id idGoalBDM = RecordTypeService.getId('Business_Activity_Goal__c', 'BDM Goal');
		Id idGoalBranch = RecordTypeService.getId('Business_Activity_Goal__c', 'Branch Goal');

		return new Business_Activity_Goal__c(
			RecordTypeId = (idBranch == null) ? idGoalBDM : idGoalBranch,
			Branch__c = idBranch,
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
	}

	@IsTest
	@SuppressWarnings('PMD.AvoidSystemDebugUsage')
	static void test_checkDuplicates_1() {
		readData();

		Business_Activity_Goal__c goalDup1 = TestFactoryBusinessActivityGoal.makeBusinessActivityGoal(2019, 3, false, 1, (Id) null);
		//Business_Activity_Goal__c goalDup2 = makeBusinessActivityGoal(2024, 3, false, 2, (Id) null);
		//Business_Activity_Goal__c goalDup3 = makeBusinessActivityGoal(2024, 3, false, 3, (Id) null);
		Business_Activity_Goal__c goalNew = TestFactoryBusinessActivityGoal.makeBusinessActivityGoal(2018, 3, false, 4, (Id) null);
		Business_Activity_Goal__c goalOverride = TestFactoryBusinessActivityGoal.makeBusinessActivityGoal(2019, 3, true, 5, (Id) null);

		Business_Activity_Goal__c goalBranchDup = TestFactoryBusinessActivityGoal.makeBusinessActivityGoal(2020, 4, false, 2, branchOne.Id);

		try {
			insert new List<Business_Activity_Goal__c>{ goalDup1 };
			Assert.isTrue(false, 'Should have thrown an Exception');
		} catch (Exception e) {
			System.debug(LoggingLevel.FINEST, e.getMessage());
			Assert.isTrue(e.getMessage().contains('Adding duplicate goal'));
		}

		/** TODO: FIX LATER
		try {
			insert new List<Business_Activity_Goal__c>{ goalDup2, goalDup3 };
			Assert.isTrue(false, 'Should have thrown an Exception');
		} catch (Exception e) {
			System.debug(LoggingLevel.FINEST, e.getMessage());
			Assert.isTrue(e.getMessage().contains('Adding duplicate goal'));
		}
		**/

		try {
			insert new List<Business_Activity_Goal__c>{ goalNew, goalOverride };
			Assert.isTrue(true, 'Should not have thrown an Exception');
		} catch (Exception e) {
			System.debug(LoggingLevel.FINEST, e.getMessage());
			Assert.isTrue(false, 'Should not have thrown an Exception');
		}

		try {
			goalNew.New_Leads__c = 5;
			update goalNew;
			Assert.isTrue(true, 'Should not have thrown an Exception');
		} catch (Exception e) {
			System.debug(LoggingLevel.FINEST, e.getMessage());
			Assert.isTrue(false, 'Should not have thrown an Exception');
		}

		try {
			goalNew.Start_Year__c = '2020';
			goalNew.Start_Quarter__c = 'Quarter 1';
			update goalNew;
			Assert.isTrue(false, 'Should have thrown an Exception');
		} catch (Exception e) {
			System.debug(LoggingLevel.FINEST, e.getMessage());
			Assert.isTrue(true, 'Should have thrown an Exception');
		}

		try {
			insert new List<Business_Activity_Goal__c>{ goalBranchDup };
			Assert.isTrue(false, 'Should have thrown an Exception');
		} catch (Exception e) {
			System.debug(LoggingLevel.FINEST, e.getMessage());
			Assert.isTrue(e.getMessage().contains('Adding duplicate goal'));
		}
	}

	@IsTest
	@SuppressWarnings('PMD.NcssMethodCount')
	static void test_getBDMGoalFor_YearQuarter() {
		Business_Activity_Goal__c goal;

		goal = BusinessActivityGoal.getBDMGoalFor(2018, 1);
		Assert.areEqual(0, goal.Discovery_Meetings__c);
		Assert.areEqual(0, goal.Events__c);
		Assert.areEqual(0, goal.Lost_Clients_Contacted__c);
		Assert.areEqual(0, goal.Lost_Leads_Contacted__c);
		Assert.areEqual(0, goal.New_Clients__c);
		Assert.areEqual(0, goal.New_Leads__c);
		Assert.areEqual(0, goal.New_Referral_Partners_Contacted__c);
		Assert.areEqual(0, goal.Producer_Tracks_Info_Sessions__c);
		Assert.areEqual(0, goal.Referral_Partner_Plans_In_Place__c);
		Assert.areEqual(0, goal.Referral_Partner_Touches__c);
		Assert.areEqual(0, goal.RP_Touches_In_Person__c);
		Assert.areEqual(0, goal.RP_Touches_Virtual__c);
		Assert.areEqual(0, goal.WSE_Added__c);

		goal = BusinessActivityGoal.getBDMGoalFor(2019, 2);
		Assert.areEqual('2018', goal.Start_Year__c);
		Assert.areEqual('Quarter 4', goal.Start_Quarter__c);

		goal = BusinessActivityGoal.getBDMGoalFor(2019, 4);
		Assert.areEqual('2019', goal.Start_Year__c);
		Assert.areEqual('Quarter 3', goal.Start_Quarter__c);

		goal = BusinessActivityGoal.getBDMGoalFor(2020, 3);
		Assert.areEqual('2020', goal.Start_Year__c);
		Assert.areEqual('Quarter 3', goal.Start_Quarter__c);

		goal = BusinessActivityGoal.getBDMGoalFor(2020, 4);
		Assert.areEqual('2020', goal.Start_Year__c);
		Assert.areEqual('Quarter 4', goal.Start_Quarter__c);

		goal = BusinessActivityGoal.getBDMGoalFor(2021, 3);
		Assert.areEqual('2020', goal.Start_Year__c);
		Assert.areEqual('Quarter 4', goal.Start_Quarter__c);

		goal = BusinessActivityGoal.getBDMGoalFor(2023, 4);
		Assert.areEqual('2021', goal.Start_Year__c);
		Assert.areEqual('Quarter 4', goal.Start_Quarter__c);

		goal = BusinessActivityGoal.getBDMGoalFor(2020, 0);
		Assert.areEqual('2020', goal.Start_Year__c);
		Assert.areEqual('Quarter 4', goal.Start_Quarter__c);
		Assert.areEqual(11, goal.Discovery_Meetings__c);
		Assert.areEqual(11, goal.Events__c);
		Assert.areEqual(11, goal.Lost_Clients_Contacted__c);
		Assert.areEqual(11, goal.Lost_Leads_Contacted__c);
		Assert.areEqual(11, goal.New_Clients__c);
		Assert.areEqual(11, goal.New_Leads__c);
		Assert.areEqual(11, goal.New_Referral_Partners_Contacted__c);
		Assert.areEqual(11, goal.Producer_Tracks_Info_Sessions__c);
		Assert.areEqual(11, goal.Referral_Partner_Plans_In_Place__c);
		Assert.areEqual(11, goal.Referral_Partner_Touches__c);
		Assert.areEqual(11, goal.RP_Touches_In_Person__c);
		Assert.areEqual(11, goal.RP_Touches_Virtual__c);
		Assert.areEqual(11, goal.WSE_Added__c);

		goal = BusinessActivityGoal.getBDMGoalFor(2023, 0);
		Assert.areEqual('2021', goal.Start_Year__c);
		Assert.areEqual('Quarter 4', goal.Start_Quarter__c);
		Assert.areEqual(13, goal.Discovery_Meetings__c);
		Assert.areEqual(13, goal.Events__c);
		Assert.areEqual(13, goal.Lost_Clients_Contacted__c);
		Assert.areEqual(13, goal.Lost_Leads_Contacted__c);
		Assert.areEqual(13, goal.New_Clients__c);
		Assert.areEqual(13, goal.New_Leads__c);
		Assert.areEqual(13, goal.New_Referral_Partners_Contacted__c);
		Assert.areEqual(13, goal.Producer_Tracks_Info_Sessions__c);
		Assert.areEqual(13, goal.Referral_Partner_Plans_In_Place__c);
		Assert.areEqual(13, goal.Referral_Partner_Touches__c);
		Assert.areEqual(13, goal.RP_Touches_In_Person__c);
		Assert.areEqual(13, goal.RP_Touches_Virtual__c);
		Assert.areEqual(13, goal.WSE_Added__c);
	}

	@IsTest
	static void test_addGoals() {
		Business_Activity_Goal__c goal1 = TestFactoryBusinessActivityGoal.makeBusinessActivityGoal(2019, 3, false, 1, (Id) null);
		Business_Activity_Goal__c goal2 = TestFactoryBusinessActivityGoal.makeBusinessActivityGoal(2024, 3, false, 3, (Id) null);
		Business_Activity_Goal__c goal3 = TestFactoryBusinessActivityGoal.makeBusinessActivityGoal(2024, 3, false, 5, (Id) null);

		Business_Activity_Goal__c goal;

		goal = BusinessActivityGoal.addGoals(goal1, goal2);
		Assert.areNotEqual(null, goal);
		Assert.areEqual(4, goal.Discovery_Meetings__c);
		Assert.areEqual(4, goal.Events__c);
		Assert.areEqual(4, goal.Lost_Clients_Contacted__c);
		Assert.areEqual(4, goal.Lost_Leads_Contacted__c);
		Assert.areEqual(4, goal.New_Clients__c);
		Assert.areEqual(4, goal.New_Leads__c);
		Assert.areEqual(4, goal.New_Referral_Partners_Contacted__c);
		Assert.areEqual(4, goal.Producer_Tracks_Info_Sessions__c);
		Assert.areEqual(4, goal.Referral_Partner_Plans_In_Place__c);
		Assert.areEqual(4, goal.Referral_Partner_Touches__c);
		Assert.areEqual(4, goal.RP_Touches_In_Person__c);
		Assert.areEqual(4, goal.RP_Touches_Virtual__c);
		Assert.areEqual(4, goal.WSE_Added__c);

		goal = BusinessActivityGoal.addGoals(goal, goal3);
		Assert.areNotEqual(null, goal);
		Assert.areEqual(9, goal.Discovery_Meetings__c);
		Assert.areEqual(9, goal.Events__c);
		Assert.areEqual(9, goal.Lost_Clients_Contacted__c);
		Assert.areEqual(9, goal.Lost_Leads_Contacted__c);
		Assert.areEqual(9, goal.New_Clients__c);
		Assert.areEqual(9, goal.New_Leads__c);
		Assert.areEqual(9, goal.New_Referral_Partners_Contacted__c);
		Assert.areEqual(9, goal.Producer_Tracks_Info_Sessions__c);
		Assert.areEqual(9, goal.Referral_Partner_Plans_In_Place__c);
		Assert.areEqual(9, goal.Referral_Partner_Touches__c);
		Assert.areEqual(9, goal.RP_Touches_In_Person__c);
		Assert.areEqual(9, goal.RP_Touches_Virtual__c);
		Assert.areEqual(9, goal.WSE_Added__c);
	}

	/**
	 * @description test_getAllBranchGoals
	 */
	@IsTest
	public static void test_getAllBranchGoals() {
		readData();

		Map<Id, List<Business_Activity_Goal__c>> mapGoals2020 = BusinessActivityGoal.getAllBranchGoals(2020);
		Map<Id, List<Business_Activity_Goal__c>> mapGoals2019 = BusinessActivityGoal.getAllBranchGoals(2019);

		Assert.areEqual(2, mapGoals2020.size());
		Assert.areEqual(3, mapGoals2020.get(branchOne.Id).size());
		Assert.areEqual(4, mapGoals2020.get(branchTwo.Id).size());

		Assert.areEqual(1, mapGoals2019.size());
		Assert.areEqual(2, mapGoals2019.get(branchTwo.Id).size());
	}

	/**
	 * @description test_getAllBranchGoals
	 */
	@IsTest
	public static void test_createEmptyGoal() {
		Business_Activity_Goal__c goal = BusinessActivityGoal.createEmptyGoal();

		Assert.areNotEqual(null, goal);
		Assert.areEqual(0, goal.Discovery_Meetings__c);
		Assert.areEqual(0, goal.Events__c);
		Assert.areEqual(0, goal.Lost_Clients_Contacted__c);
		Assert.areEqual(0, goal.Lost_Leads_Contacted__c);
		Assert.areEqual(0, goal.New_Clients__c);
		Assert.areEqual(0, goal.New_Leads__c);
		Assert.areEqual(0, goal.New_Referral_Partners_Contacted__c);
		Assert.areEqual(0, goal.Producer_Tracks_Info_Sessions__c);
		Assert.areEqual(0, goal.Referral_Partner_Plans_In_Place__c);
		Assert.areEqual(0, goal.Referral_Partner_Touches__c);
		Assert.areEqual(0, goal.RP_Touches_In_Person__c = 0);
		Assert.areEqual(0, goal.RP_Touches_Virtual__c = 0);
		Assert.areEqual(0, goal.WSE_Added__c);
	}

	/**
	 * @description test_multiplyGoal
	 */
	@IsTest
	public static void test_multiplyGoal() {
		Business_Activity_Goal__c goal = TestFactoryBusinessActivityGoal.makeBusinessActivityGoal(2016, 4, false, 2, (Id) null);

		Business_Activity_Goal__c after = BusinessActivityGoal.multiplyGoal(goal, 7);

		Assert.areNotEqual(null, after);
		Assert.areEqual(14, after.Discovery_Meetings__c);
		Assert.areEqual(14, after.Events__c);
		Assert.areEqual(14, after.Lost_Clients_Contacted__c);
		Assert.areEqual(14, after.Lost_Leads_Contacted__c);
		Assert.areEqual(14, after.New_Clients__c);
		Assert.areEqual(14, after.New_Leads__c);
		Assert.areEqual(14, after.New_Referral_Partners_Contacted__c);
		Assert.areEqual(14, after.Producer_Tracks_Info_Sessions__c);
		Assert.areEqual(14, after.Referral_Partner_Plans_In_Place__c);
		Assert.areEqual(14, after.Referral_Partner_Touches__c);
		Assert.areEqual(14, after.RP_Touches_In_Person__c);
		Assert.areEqual(14, after.RP_Touches_Virtual__c);
		Assert.areEqual(14, after.WSE_Added__c);
	}

	/**
	 * @description test_multiplyGoal
	 */
	@IsTest
	public static void test_sumGoal() {
		Business_Activity_Goal__c goal1 = TestFactoryBusinessActivityGoal.makeBusinessActivityGoal(2016, 4, false, 1, (Id) null);
		Business_Activity_Goal__c goal2 = TestFactoryBusinessActivityGoal.makeBusinessActivityGoal(2016, 4, false, 2, (Id) null);

		Business_Activity_Goal__c after = BusinessActivityGoal.sumGoals(
			new List<Business_Activity_Goal__c>{ goal1, goal2 }
		);

		Assert.areNotEqual(null, after);
		Assert.areEqual(3, after.Discovery_Meetings__c);
		Assert.areEqual(3, after.Events__c);
		Assert.areEqual(3, after.Lost_Clients_Contacted__c);
		Assert.areEqual(3, after.Lost_Leads_Contacted__c);
		Assert.areEqual(3, after.New_Clients__c);
		Assert.areEqual(3, after.New_Leads__c);
		Assert.areEqual(3, after.New_Referral_Partners_Contacted__c);
		Assert.areEqual(3, after.Producer_Tracks_Info_Sessions__c);
		Assert.areEqual(3, after.Referral_Partner_Plans_In_Place__c);
		Assert.areEqual(3, after.Referral_Partner_Touches__c);
		Assert.areEqual(3, after.RP_Touches_In_Person__c);
		Assert.areEqual(3, after.RP_Touches_Virtual__c);
		Assert.areEqual(3, after.WSE_Added__c);
	}

	@IsTest
	public static void test_getGoalFor() {
		readData();

		Set<Id> listIdBranches = new Set<Id>{ branchOne.Id, branchTwo.Id };

		User bdm1 = TestFactoryUser.makeBDM('BDM-ONE', 'BDM-ONE', 'BBSI Standard', 'ONE');
		bdm1.Acronym__c = 'ONE';
		User bdm2 = TestFactoryUser.makeBDM('BDM-TWO', 'BDM-TWO', 'BBSI Standard', 'TWO');
		bdm2.Acronym__c = 'TWO';
		insert new List<User>{ bdm1, bdm2 };

		Set<Id> listIdBDMs = new Set<Id>{ bdm1.Id, bdm2.Id };
		Set<Id> listIdBDM1 = new Set<Id>{ bdm1.Id };

		Test.startTest();

		Business_Activity_Goal__c allBdmsAllBranches2020Q1 = BusinessActivityGoal.getGoalFor(
			true,
			listIdBDMs,
			listIdBranches,
			2020,
			1
		);
		Business_Activity_Goal__c allBdmsAllBranches2020Q4 = BusinessActivityGoal.getGoalFor(
			true,
			listIdBDMs,
			listIdBranches,
			2020,
			4
		);
		Business_Activity_Goal__c allBdmsAllBranches2020FullYear = BusinessActivityGoal.getGoalFor(
			true,
			listIdBDMs,
			listIdBranches,
			2020,
			0
		);

		Business_Activity_Goal__c bdm1AllBranches2020Q2 = BusinessActivityGoal.getGoalFor(
			false,
			listIdBDM1,
			listIdBranches,
			2020,
			2
		);
		Business_Activity_Goal__c bdm1AllBranches2020FullYear = BusinessActivityGoal.getGoalFor(
			false,
			listIdBDM1,
			listIdBranches,
			2020,
			0
		);
		
		Test.stopTest();

		Assert.areEqual(14, allBdmsAllBranches2020Q1.Discovery_Meetings__c);
		Assert.areEqual(26, allBdmsAllBranches2020Q4.Discovery_Meetings__c);
		Assert.areEqual(104, allBdmsAllBranches2020FullYear.Discovery_Meetings__c);
		Assert.areEqual(7, bdm1AllBranches2020Q2.Discovery_Meetings__c);
		Assert.areEqual(44, bdm1AllBranches2020FullYear.Discovery_Meetings__c);
	}

	@IsTest
	public static void test_fixBranch() {
		readData();

        Business_Activity_Goal__c goal1 
            = TestFactoryBusinessActivityGoal.makeBusinessActivityGoal(
                2018, 1, false, 0, branchOne.Id, 
                new Map<String,Object> { 'RecordTypeId' => idrtGoalBDM }
            );
        Business_Activity_Goal__c goal2 
            = TestFactoryBusinessActivityGoal.makeBusinessActivityGoal(
                2019, 2, false, 0, branchOne.Id
            );
		insert new List<Business_Activity_Goal__c>{ goal1, goal2 };

		Test.startTest();

		goal2.RecordTypeId = idrtGoalBDM;
		update goal2;

		Test.stopTest();

		List<Id> idGoals = new List<Id>{ goal1.Id, goal2.Id };

		List<Business_Activity_Goal__c> listGoals = [
			SELECT Id, Branch__c
			FROM Business_Activity_Goal__c
			WHERE Id IN :idGoals
			ORDER BY Start_Year__c ASC
		];

		Assert.areEqual(null, listGoals.get(0).Branch__c);
		Assert.areEqual(null, listGoals.get(1).Branch__c);
	}
}