/**
 * @description OpportunityValidationTest contains tests for the OpportunityValidation class.
 */
@IsTest
private class OpportunityValidationTest {
	private static Account branch;
	private static User areaManager;
	private static User bdm;

	@TestSetup
	static void setup() {
		branch = TestFactoryAccount.createBranch('TEST_BRANCH');

		User sysAdmin = [SELECT Id FROM User WHERE Profile.Name = 'System Administrator' AND IsActive = TRUE LIMIT 1];
		System.runAs(sysAdmin) {
			UserRole Role = new UserRole();
			Role.Name = 'Parent Role';
			insert Role;

			UserRole parentRole = new UserRole();
			parentRole.Name = 'BU Role';
			parentRole.ParentRoleId = Role.Id;
			insert parentRole;

			areaManager = TestFactoryUser.makeAreaManager('TEST', 'AREAMANAGER', branch.External_Id__c);
			areaManager.UserRoleId = Role.Id;

			bdm = TestFactoryUser.makeBDM('TEST', 'BDM', 'BBSI Standard', branch.External_Id__c);
			bdm.UserRoleId = parentRole.Id;

			insert new List<User>{ areaManager, bdm };
		}
	}

	static void loadData() {
		branch = [SELECT Id, Branch_Manager__c FROM account WHERE Name = 'TEST_BRANCH' LIMIT 1];

		areaManager = [
			SELECT Id, Name
			FROM User
			WHERE FirstName = 'TEST' AND LastName = 'AREAMANAGER'
			LIMIT 1
		];
		bdm = [
			SELECT Id, Name
			FROM User
			WHERE FirstName = 'TEST' AND LastName = 'BDM'
			LIMIT 1
		];
	}

	@IsTest
	static void SingleRequestApproval() {
		loadData();

		Ok_For_Risk_Access__c okRisk = new Ok_For_Risk_Access__c();
		okRisk.Name = areaManager.Name;
		insert okRisk;

		branch.Branch_Manager__c = areaManager.Name;
		branch.OwnerId = areaManager.Id;
		update branch;

		System.runAs(areaManager) {
			Account prospect = TestFactoryAccount.makeProspect('TEST_PROSPECT', null, null);
			prospect.Prospect_Branch__c = branch.Id;
			prospect.Branch_Manager__c = areaManager.Name;
			prospect.Annual_Payroll__c = 4.5;
			prospect.Main_Payroll_Frequency__c = 'Weekly';
			prospect.FEIN__c = '68-0326512';
			prospect.NAICS_Title__c = 'Crop Production';
			prospect.Customer_Class__c = '3';
			insert prospect;

			Opportunity opp = TestFactoryOpportunity.createClient(
				'TEST_OPPORUTNITY',
				prospect.Id,
				System.today(),
				'Identifiying'
			);

			opp.Type = 'Staffing';
			opp.Request_OK_For_Risk_Approval__c = true;
			//o.Request_Area_Manager_Approval__c = true;
			opp.Request_Credit_Approval__c = true;
			opp.Amount = 1000000;

			update opp;
		}
	}

	@IsTest
	static void UnqualifiedReason() {
		loadData();

		Account prospect = TestFactory.createAccount('Prospect Test One', '98662', 'Prospect', true);

		Account rpartner = TestFactoryAccount.createReferralPartner('TEST_REFERRAL_PARTNER', '% of Margin',  12.34, null);

		Opportunity opp = TestFactory.createOpportunity(
			'TestOpportunity',
			prospect,
			System.today(),
			'Identifying',
			false
		);

		opp.Amount = 1000000;
		opp.Security_Deposit_Required__c = 'No';
		insert opp;

		opp.StageName = 'Closed Lost';
		opp.Closed_Reason__c = 'Unable to Schedule a Meeting';

		try {
			update opp;
		} catch (DmlException ex) {
			Assert.areEqual(StatusCode.FIELD_CUSTOM_VALIDATION_EXCEPTION, ex.getDmlType(0));
			Assert.areEqual(
				'Must have a Referral Source when choosing to unqualify by unable to schedule a meeting',
				ex.getDmlMessage(0)
			);
		}

		Assert.areEqual('Identifying', [SELECT StageName FROM Opportunity WHERE ID = :opp.Id].StageName);

		Referral_Partner__c rf = new Referral_Partner__c();
		rf.Account__c = opp.AccountID;
		rf.Referral_Partner__c = rpartner.Id;
		rf.Commission_Rate__c = 12.34;
		rf.Referral_Partner_Commission_Type__c = '% of Margin';
		insert rf;

		opp.StageName = 'Closed Lost';
		opp.Closed_Reason__c = 'Unable to Schedule a Meeting';

		update opp;

		Assert.areEqual(
			'Unable to Schedule a Meeting',
			[SELECT Closed_Reason__c FROM Opportunity WHERE Id = :opp.Id].Closed_Reason__c
		);
	}

	@IsTest
	static void AreaManagerApprovalPositive() {
		loadData();

		branch.Branch_Manager__c = areaManager.Name;
		branch.OwnerId = AreaManager.Id;
		update branch;
		
		Test.startTest();

		Opportunity opp = new Opportunity();

		System.runAs(areaManager) {
			Account prospect = TestFactoryAccount.makeProspect('TEST_PROSPECT', null, null);
			prospect.Prospect_Branch__c = branch.Id;
			prospect.Branch_Manager__c = areaManager.Name;
			prospect.Annual_Payroll__c = 4.5;
			prospect.Main_Payroll_Frequency__c = 'Weekly';
			prospect.FEIN__c = '68-0326512';
			prospect.NAICS_Title__c = 'Crop Production';
			prospect.Credit_Limit__c = 4444;
			insert prospect;

			opp = TestFactoryopportunity.createClient('TEST_OPPORTUNITY', prospect.Id, System.today(), 'Identifying');
		}

		Assert.areEqual('Identifying', opp.StageName);
		Assert.areEqual(false, opp.IsClosed);

		opp.Credit_Approval_Status__c = 'Approved';
		opp.OK_For_Risk_Approval_Status__c = 'Approved';
		opp.Amount = 1000000; // Set field: Estimated Annual Billing
		update opp;

		opp = [SELECT IsClosed, StageName FROM Opportunity WHERE Id = :opp.Id];
		Assert.areEqual('Identifying', opp.StageName);
		Assert.areEqual(false, opp.IsClosed);

		System.runAs(AreaManager) {
			opp.AM_Approval_Status__c = 'Approved';
			update opp;
		}

		Test.stopTest();

		Assert.areEqual(
			'Approved',
			[SELECT AM_Approval_Status__c FROM Opportunity WHERE Id = :opp.Id].AM_Approval_Status__c
		);
	}

	@IsTest
	static void AreaManagerApprovalNegative() {
		loadData();

		Opportunity opp;

		System.runAs(bdm) {
			Account client = TestFactoryAccount.createClient('TEST_CLIENT', null, null);

			opp = TestFactoryOpportunity.createClient(
				'TEST_OPPORTUNITY',
				client.Id,
				System.today(),
				'Identifying'
			);

			opp.AM_Approval_Status__c = 'Approved';

			try {
				update opp;

				Assert.fail('Exception should have been thrown.');
			} catch (DMLException ex) {
				Assert.areEqual(StatusCode.FIELD_CUSTOM_VALIDATION_EXCEPTION, ex.getDmlType(0));
				Assert.areEqual(
					'You must be an Area Manager or Delegated Admin to approve records.',
					ex.getDmlMessage(0)
				);
			}
		}

		Assert.areEqual(
			null,
			[SELECT AM_Approval_Status__c FROM Opportunity WHERE Id = :opp.Id].AM_Approval_Status__c
		);
	}

	@IsTest
	static void AreaManagerCommentsPositive() {
		loadData();

		Opportunity opp;

		System.runAs(areaManager) {
			Account prospect = TestFactoryAccount.createProspect('Prospect Test Five', null, null);

			opp = TestFactoryOpportunity.createClient(
				'TEST_OPPORTUNITY',
				prospect.Id,
				System.today(),
				'Identifying'
			);

			opp.AM_Approval_Comments__c = 'TEST COMMENTS';
			opp.Amount = 1000000;
			update opp;
		}

		Assert.areEqual(
			'TEST COMMENTS',
			[SELECT AM_Approval_Comments__c FROM Opportunity WHERE Id = :opp.Id].AM_Approval_Comments__c
		);
	}

	@IsTest
	static void AreaManagerCommentsNegative() {
		loadData();

		Opportunity opp;

		System.runAs(bdm) {
			Account client = TestFactoryAccount.createClient('TEST_CLIENT', null, null);

			opp = TestFactoryOpportunity.createClient(
				'TEST_OPPORTUNITY',
				client.Id,
				System.today(),
				'Identifying'
			);
			opp.AM_Approval_Comments__c = 'Test';

			try {
				update opp;
			} catch (DMLException ex) {
				Assert.areEqual(StatusCode.FIELD_CUSTOM_VALIDATION_EXCEPTION, ex.getDmlType(0));
				Assert.areEqual(
					'You must be the Approver or Delegated Approver to edit Area Manager Comments',
					ex.getDmlMessage(0)
				);
			}
		}

		Assert.areEqual(
			null,
			[SELECT AM_Approval_Comments__c FROM Opportunity WHERE Id = :opp.Id].AM_Approval_Comments__c
		);
	}

	@IsTest
	static void OkForRiskApprovalPositive() {
		User userOkRisk = TestFactoryUser.createUser('TEST', 'RISK', 'BBSI Standard', '910');
		//userOkRisk.title = 'Ok for Risk';
		//insert userOkRisk;

		Ok_For_Risk_Access__c riskAccess = new Ok_For_Risk_Access__c();
		riskAccess.name = 'TEST RISK';
		insert riskAccess;

		Opportunity opp = new Opportunity();

		System.runAs(userOkRisk) {
			Account prospect = TestFactoryAccount.createProspect('TEST_PROSPECT', null, null);

			opp = TestFactory.createOpportunity('TEST_OPPORTUNITY', prospect, System.today(), 'Identifying', true);
			opp.Request_OK_For_Risk_Approval__c = true;
			opp.OK_For_Risk_Approval_Status__c = 'Approved';
			opp.Amount = 1000000;
			update opp;
		}

		Assert.areEqual(
			'Approved',
			[SELECT OK_For_Risk_Approval_Status__c FROM Opportunity WHERE Id = :Opp.Id]
			.OK_For_Risk_Approval_Status__c
		);
	}

	@IsTest
	static void OkForRiskApprovalNegative() {
		loadData();

		User userOkRisk = TestFactoryUser.createUser('TEST', 'RISK', 'BBSI Standard', '910');
		//userOkRisk.FirstName = 'Ok';
		//userOkRisk.title = 'Ok for Risk';
		//insert userOkRisk;

		Ok_For_Risk_Access__c okRisk = new Ok_For_Risk_Access__c();
		okRisk.name = 'Not Ok Risk';
		insert okRisk;

		Opportunity opp = new Opportunity();

		System.runAs(userOkRisk) {
			Account prospect = TestFactoryAccount.createProspect('TEST_PROSPECT', null, null);

			opp = TestFactory.createOpportunity('TEST_OPPORTUNITY', prospect, System.today(), 'Identifying', true);

			opp.OK_For_Risk_Approval_Status__c = 'Approved';
			try {
				update opp;
			} catch (DMLException ex) {
				Assert.areEqual(StatusCode.FIELD_CUSTOM_VALIDATION_EXCEPTION, ex.getDmlType(0));
				Assert.areEqual(
					'You must be the Approver or Delegated Approver for Underwriting Approval',
					ex.getDmlMessage(0)
				);
			}
		}

		Assert.areEqual(
			null,
			[SELECT OK_For_Risk_Approval_Status__c FROM Opportunity WHERE Id = :opp.Id]
			.OK_For_Risk_Approval_Status__c
		);
	}
}