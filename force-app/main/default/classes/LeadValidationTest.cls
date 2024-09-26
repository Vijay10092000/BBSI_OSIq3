/**
 * @description LeadValidationTest contains tests for the LeadValidation class.
 */
@IsTest
@SuppressWarnings('PMD.ApexAssertionsShouldIncludeMessage')
public class LeadValidationTest {
	@TestSetup
	static void setup() {
		UserRole role = new UserRole();
		role.Name = 'Parent Role';
		insert role;

		UserRole parentRole = new UserRole();
		parentRole.Name = 'BU Role';
		parentRole.ParentRoleId = role.Id;
		insert parentRole;

		User areaManager = TestFactory.createUser(
			'Manager',
			'AreaManager@bbsihq.com',
			'AreaManager@bbsihq.com',
			'Area Manager',
			'910',
			false
		);
		areaManager.FirstName = 'Area';
		areaManager.Title = 'Area Manager';
		areaManager.UserRoleId = role.Id;

		User u = TestFactory.createUser(
			'BDMUser',
			'TestBBSI@bbsihq.com',
			'TestBBSI@bbsihq.com',
			'BBSI Standard',
			'910',
			false
		);
		u.title = 'Business Development Manager';
		u.UserRoleId = parentRole.Id;

		insert new List<User>{ areaManager, u };

		User sysAdmin = [SELECT Id FROM User WHERE IsActive = TRUE AND Profile.Name = 'System Administrator' LIMIT 1];
		System.runAs(sysAdmin) {
			Account rp = TestFactory.createAccountReferralPartner('RP Test', 'Active', '% of Margin', 12.0, null, true);
			TestFactory.CreateContact(rp, 'ProducerA', 'Producer', true);
		}
	}

	@IsTest
	static void requestPositiveUpdate() {
		User u = [SELECT Id FROM User WHERE Name = 'BDMUser'];

		Account branch = TestFactory.createAccount('Test Branch', '98662', 'BBSI Branch', false);
		branch.Branch_Manager__c = 'Area Manager';
		branch.Branch_Manager_Email__c = 'Test@Test.com';
		branch.External_Id__c = '910';

		User areaManager = TestFactory.createUser(
			'Area Manager',
			'TestAreaManager@bbsihq.com',
			'TestAreaManager@bbsihq.com',
			'Area Manager',
			'910',
			false
		);
		areaManager.Title = 'Area Manager';
		areaManager.Branch_Id__c = '910';
		insert areaManager;

		Lead l;
		System.runAs(areaManager) {
			insert branch;

			Account rp = TestFactory.createAccountReferralPartner(
				'Referral Partner Test',
				'Active',
				'% of Margin',
				12.0,
				null,
				true
			);

			l = new Lead(
				LastName = 'TestBDM',
				Company = 'BDM Company',
				Status = 'Assigned',
				Branch__c = branch.Id,
				Phone = TestFactory.nextPhoneNumber(),
				RecordTypeId = RecordTypeService.getId('Lead', 'Client_Lead'),
				Business_Development_Manager__c = u.Id
			);
			l.Referral_Partner__c = rp.Id;
			l.Producer__c = TestFactory.CreateContact(rp, 'Producer', 'Producer', true).Id;
			insert l;

			l.Request_Area_Manager_Approval__c = true;

			update l;
		}

		Lead resultLead = [
			SELECT Id, IsConverted, AM_Approval_Status__c, Request_Area_Manager_Approval__c, OwnerId
			FROM Lead
			WHERE Id = :l.Id
		];
		Assert.isTrue(resultLead.Request_Area_Manager_Approval__c);
		Assert.areNotEqual('Approved', resultLead.AM_Approval_Status__c);
		Assert.isFalse(resultLead.IsConverted);
	}

	@IsTest
	static void approvalPositiveUpdate() {
		User u = [SELECT ContactId FROM User WHERE Name = 'BDMUser'];

		User areaManager = TestFactory.createUser(
			'Area Manager',
			'TestAreaManager@bbsihq.com',
			'TestAreaManager@bbsihq.com',
			'Area Manager',
			'910',
			false
		);
		areaManager.Title = 'Area Manager';
		areaManager.Branch_Id__c = '910';
		insert areaManager;

		Account branch = TestFactory.createAccount('Test Branch', '98662', 'BBSI Branch', false);
		branch.Branch_Manager__c = 'Area Manager';
		branch.External_Id__c = '910';
		branch.Branch_Manager_Email__c = 'Test@Test.com';

		Lead l;

		Test.startTest();

		System.runAs(AreaManager) {
			insert branch;

			Account rp = TestFactory.createAccountReferralPartner(
				'Referral Partner Test',
				'Active',
				'% of Margin',
				12.0,
				null,
				true
			);

			l = new Lead(
				LastName = 'TestLead',
				Company = 'Test Lead Company',
				Status = 'Assigned',
				Branch__c = branch.Id,
				Phone = TestFactory.nextPhoneNumber(),
				RecordTypeId = RecordTypeService.getId('Lead', 'Client_Lead'),
				Business_Development_Manager__c = u.Id,
				Referral_Partner__c = rp.Id,
				Producer__c = TestFactory.CreateContact(rp, 'Producer', 'Producer', true).Id
			);
			insert l;

			l.Request_Area_Manager_Approval__c = true;
			update l;
		}

		Test.stopTest();

		Lead resultLead = [
			SELECT Id, IsConverted, AM_Approval_Status__c, Request_Area_Manager_Approval__c, OwnerId
			FROM Lead
			WHERE Id = :l.Id
		];
		Assert.isTrue(resultLead.Request_Area_Manager_Approval__c);
		Assert.areNotEqual('Approved', resultLead.AM_Approval_Status__c);
		Assert.isFalse(resultLead.IsConverted);

		l = [SELECT AM_Approval_Status__c, OwnerId FROM Lead WHERE LastName = 'TestLead'];
		l.OwnerId = AreaManager.Id;
		update l;

		System.runAs(areaManager) {
			l.AM_Approval_Status__c = 'Approved';

			update l;
		}
	}

	@IsTest
	static void requestPositiveInsert() {
		User u = [SELECT Id FROM User WHERE Name = 'BDMUser'];

		Account branch = TestFactory.createAccount('Test Branch', '98662', 'BBSI Branch', false);
		branch.Branch_Manager__c = 'Area Manager';
		branch.Branch_Manager_Email__c = 'Test@Test.com';

		Lead l;

		System.runAs(u) {
			insert branch;

			Account rp = TestFactory.createAccountReferralPartner(
				'Referral Partner Test',
				'Active',
				'% of Margin',
				12.0,
				null,
				true
			);

			l = new Lead(
				LastName = 'TestBDM',
				Company = 'BDM Company',
				Status = 'Assigned',
				Branch__c = branch.Id,
				Phone = TestFactory.nextPhoneNumber(),
				RecordTypeId = RecordTypeService.getId('Lead', 'Client_Lead'),
				Business_Development_Manager__c = u.Id
			);
			l.Referral_Partner__c = rp.Id;
			l.Producer__c = TestFactory.CreateContact(rp, 'Producer', 'Producer', true).Id;
			l.Request_Area_Manager_Approval__c = true;

			insert l;
		}

		Lead resultLead = [
			SELECT Id, IsConverted, AM_Approval_Status__c, Request_Area_Manager_Approval__c, OwnerId
			FROM Lead
			WHERE Id = :l.Id
		];
		Assert.isTrue(resultLead.Request_Area_Manager_Approval__c);
		Assert.areNotEqual('Approved', resultLead.AM_Approval_Status__c);
		Assert.areEqual(false, resultLead.IsConverted);
	}

	@IsTest
	static void approvalNegativeInsert() {
		User u = [SELECT Id FROM User WHERE name = 'BDMUser'];

		Account branch = TestFactory.createAccount('Test Branch', '98662', 'BBSI Branch', false);
		branch.Branch_Manager__c = 'Area Manager';

		System.runAs(u) {
			insert branch;

			Account rp = TestFactory.createAccountReferralPartner(
				'Referral Partner Test',
				'Active',
				'% of Margin',
				12.0,
				null,
				true
			);

			Lead l = new Lead(
				LastName = 'TestBDM',
				Company = 'BDM Company',
				Status = 'Assigned',
				Branch__c = branch.Id,
				Phone = TestFactory.nextPhoneNumber(),
				RecordTypeID = RecordTypeService.getId('Lead', 'Client_Lead')
			);
			l.Referral_Partner__c = rp.Id;
			l.Producer__c = TestFactory.CreateContact(rp, 'Producer', 'Producer', true).Id;
			l.AM_Approval_Status__c = 'Approved';

			try {
				insert l;
			} catch (DMLException e) {
				Assert.isTrue(
					e.getMessage().containsAny('You Must be a Area Manager or Delegated Admin to approve records.')
				);
			}

			Assert.isTrue([SELECT Id FROM Lead WHERE Id = :l.Id].size() == 0);
		}
	}

	@IsTest
	static void positiveConvertRequiredApproval() {
		Admin_Branch__c admin = new Admin_Branch__c();
		admin.Admin_User__c = 'BDMUser';
		admin.Name = 'Test Branch';
		insert admin;

		User user = [SELECT Id FROM User WHERE name = 'BDMUser'];

		Account branch = TestFactory.createAccount('Test Branch', '98662', 'BBSI Branch', false);
		branch.Branch_Manager__c = 'Area Manager';
		branch.Lead_AM_Approval__c = true;
		branch.OwnerId = user.Id;
		insert branch;

		System.runAs(user) {
			Account rp = TestFactory.createAccountReferralPartner(
				'Referral Partner Test',
				'Active',
				'% of Margin',
				12.0,
				null,
				true
			);

			Lead l = new Lead(
				LastName = 'TestBDM',
				Company = 'BDM Company',
				Status = 'Assigned',
				Branch__c = branch.Id,
				Phone = TestFactory.nextPhoneNumber(),
				Duplicate_Check_Status__c = true,
				RecordTypeId = RecordTypeService.getId('Lead', 'Client_Lead'),
				Business_Development_Manager__c = user.Id
			);
			l.Referral_Partner__c = rp.Id;
			l.Producer__c = TestFactory.CreateContact(rp, 'Producer', 'Producer', true).Id;
			l.AM_Approval_Status__c = 'Approved';
			l.Estimated_Annual_Billing__c = 700000;
			insert l;

			Test.startTest();
			
			Database.LeadConvertResult lcr = LeadConvert.convert(l.Id, true);
			Assert.isTrue(lcr.isSuccess(), 'Lead conversion failed');

			Test.stopTest();

			Assert.isTrue(
				[
					SELECT Id
					FROM Account
					WHERE Id = :[SELECT ConvertedAccountId FROM Lead WHERE Id = :l.Id].ConvertedAccountId
				]
				.size() == 1
			);
			Assert.isTrue(
				[
					SELECT Id
					FROM Opportunity
					WHERE Id = :[SELECT ConvertedOpportunityId FROM Lead WHERE Id = :l.Id].ConvertedOpportunityId
				]
				.size() == 1
			);
			Assert.isTrue(
				[
					SELECT Id
					FROM Contact
					WHERE Id = :[SELECT ConvertedContactId FROM Lead WHERE Id = :l.Id].ConvertedContactId
				]
				.size() == 1
			);
		}
	}

	@IsTest
	static void positiveConvertOptionalApproval() {
		Admin_Branch__c admin = new Admin_Branch__c();
		admin.Admin_User__c = 'BDMUser';
		admin.Name = 'Test Branch';
		insert admin;

		User u = [SELECT Id FROM User WHERE name = 'BDMUser'];

		Account branch = TestFactory.createAccount('Test Branch', '98662', 'BBSI Branch', false);
		branch.Branch_Manager__c = 'Area Manager';
		branch.Lead_AM_Approval__c = false;

		Lead l;

		System.runAs(u) {
			insert branch;

			Account rp = TestFactory.createAccountReferralPartner(
				'Referral Partner Test',
				'Active',
				'% of Margin',
				12.0,
				null,
				true
			);

			l = new Lead(
				LastName = 'TestBDM',
				company = 'BDM Company',
				status = 'Assigned',
				Branch__c = branch.Id,
				Phone = TestFactory.nextPhoneNumber(),
				Duplicate_Check_Status__c = true,
				RecordTypeId = recordTypeService.getId('Lead', 'Client_Lead'),
				Business_Development_Manager__c = u.Id
			);
			l.Referral_Partner__c = rp.Id;
			l.Producer__c = TestFactory.CreateContact(rp, 'Producer', 'Producer', true).Id;
			l.AM_Approval_Status__c = null;
			l.Estimated_Annual_Billing__c = 900000;
			insert l;

			Test.startTest();

			Database.LeadConvertResult lcr = LeadConvert.convert(l.Id, true);
			Assert.isTrue(lcr.isSuccess(), 'Lead conversion failed');

			Test.stopTest();
		}

		Assert.isTrue(
			[
				SELECT Id
				FROM Account
				WHERE Id = :[SELECT ConvertedAccountId FROM Lead WHERE Id = :l.Id].ConvertedAccountID
			]
			.size() == 1
		);
		Assert.isTrue(
			[
				SELECT Id
				FROM Opportunity
				WHERE Id = :[SELECT ConvertedOpportunityId FROM Lead WHERE Id = :l.Id].ConvertedOpportunityId
			]
			.size() == 1
		);
		Assert.isTrue(
			[
				SELECT Id
				FROM Contact
				WHERE Id = :[SELECT ConvertedContactId FROM Lead WHERE Id = :l.Id].ConvertedContactId
			]
			.size() == 1
		);
	}

	@IsTest
	static void nedgativeConvertRequiredApproval() {
		Admin_Branch__c admin = new Admin_Branch__c();
		admin.Admin_User__c = 'BDMUser';
		admin.Name = 'Test Branch';
		insert admin;

		User u = [SELECT Id FROM User WHERE name = 'BDMUser'];

		Account branch = TestFactory.createAccount('Test Branch', '98662', 'BBSI Branch', false);
		branch.Branch_Manager__c = 'Area Manager';
		branch.Lead_AM_Approval__c = true;

		System.runAs(u) {
			insert branch;
			Account rp = TestFactory.createAccountReferralPartner(
				'Referral Partner Test',
				'Active',
				'% of Margin',
				12.0,
				null,
				true
			);

			Lead l = new Lead(
				LastName = 'TestBDM',
				company = 'BDM Company',
				status = 'Assigned',
				Branch__c = Branch.Id,
				Phone = TestFactory.nextPhoneNumber(),
				RecordTypeId = recordTypeService.getId('Lead', 'Client_Lead')
			);
			l.Referral_Partner__c = rp.Id;
			l.Producer__c = TestFactory.CreateContact(rp, 'Producer', 'Producer', true).Id;
			insert l;

			try {
				LeadConvert.convert(l.Id, true);
				Assert.fail('Should have thrown an exception');
			} catch (DMLException e) {
				Assert.isTrue(true, 'Should have thrown an exception');
				Assert.isTrue(e.getMessage().contains('ConvertLead failed'));
			}

			Assert.isTrue(
				[
					SELECT Id
					FROM Account
					WHERE Id = :[SELECT ConvertedAccountId FROM Lead WHERE Id = :l.Id].ConvertedAccountId
				]
				.size() == 0
			);
			Assert.isTrue(
				[
					SELECT Id
					FROM Opportunity
					WHERE Id = :[SELECT ConvertedOpportunityId FROM Lead WHERE Id = :l.Id].ConvertedOpportunityId
				]
				.size() == 0
			);
			Assert.isTrue(
				[
					SELECT Id
					FROM Contact
					WHERE Id = :[SELECT ConvertedContactId FROM Lead WHERE Id = :l.Id].ConvertedContactId
				]
				.size() == 0
			);
		}
	}

	@IsTest
	static void positiveConvertOptionalApprovalNoCustomSetting() {
		User u = [SELECT Id FROM User WHERE Name = 'BDMUser'];
		User areaManager = [SELECT Id FROM User WHERE Name = 'Area Manager'];

		Account branch = TestFactory.createAccount('Test Branch', '98662', 'BBSI Branch', false);
		branch.Branch_Manager__c = 'Area Manager';
		branch.Lead_AM_Approval__c = false;

		Lead l = new lead();

		System.runAs(u) {
			insert branch;

			Account rp = TestFactory.createAccountReferralPartner(
				'Referral Partner Test',
				'Active',
				'% of Margin',
				12.0,
				null,
				true
			);

			l = new Lead(
				LastName = 'TestBDM',
				Company = 'BDM Company',
				Status = 'Assigned',
				Branch__c = branch.Id,
				Phone = TestFactory.nextPhoneNumber(),
				Duplicate_Check_Status__c = true,
				RecordTypeId = RecordTypeService.getId('Lead', 'Client_Lead')
			);
			l.Referral_Partner__c = rp.Id;
			l.Producer__c = TestFactory.CreateContact(rp, 'Producer', 'Producer', true).Id;
			l.Estimated_Annual_Billing__c = 500000;
			insert l;
		}

		System.runAs(AreaManager) {
			l.AM_Approval_Status__c = 'Approved';
			update l;
		}

		Test.startTest();

		System.runAs(u) {
			Database.LeadConvertResult lcr = LeadConvert.convert(l.Id, true);
			Assert.isTrue(lcr.isSuccess(), 'Lead conversion should be successful');
		}

		Test.stopTest();

		Assert.isTrue(
			[
				SELECT Id
				FROM Account
				WHERE Id = :[SELECT ConvertedAccountId FROM Lead WHERE Id = :l.Id].ConvertedAccountId
			]
			.size() == 1
		);
		Assert.isTrue(
			[
				SELECT Id
				FROM Opportunity
				WHERE Id = :[SELECT ConvertedOpportunityId FROM Lead WHERE Id = :l.Id].ConvertedOpportunityId
			]
			.size() == 1
		);
		Assert.isTrue(
			[
				SELECT Id
				FROM Contact
				WHERE Id = :[SELECT ConvertedContactId FROM Lead WHERE Id = :l.Id].ConvertedContactId
			]
			.size() == 1
		);
	}

	@IsTest
	static void areaManagerNegativeCommentsNoCustomSetting() {
		User u = [SELECT Id FROM User WHERE Name = 'BDMUser'];

		Account branch = TestFactory.createAccount('Test Branch', '98662', 'BBSI Branch', false);
		branch.Branch_Manager__c = 'Area Manager';

		Lead l = new lead();

		System.runAs(u) {
			Test.startTest();

			insert branch;

			Account rp = TestFactory.createAccountReferralPartner(
				'Referral Partner Test',
				'Active',
				'% of Margin',
				12.0,
				null,
				true
			);

			l = new Lead(
				LastName = 'TestBDM',
				Company = 'BDM Company',
				Status = 'Assigned',
				Branch__c = branch.Id,
				Phone = TestFactory.nextPhoneNumber(),
				RecordTypeId = RecordTypeService.getId('Lead', 'Client_Lead')
			);
			l.Referral_Partner__c = rp.Id;
			l.Producer__c = TestFactory.CreateContact(rp, 'Producer', 'Producer', true).Id;
			insert l;

			l.Area_Manager_Comments__c = 'Test Comments';

			try {
				update l;
			} catch (DMLException e) {
				Assert.isTrue(
					e.getMessage()
						.contains('You Must be the Approver or Delegated Aprover to edit Area Manager Comments.')
				);
			}

			Test.stopTest();

			Assert.isNull([SELECT Area_Manager_Comments__c FROM Lead WHERE Id = :l.Id].Area_Manager_Comments__c);
		}
	}

	@IsTest
	static void areaManagerPositiveCommentsWithCustomSetting() {
		Admin_Branch__c admin = new Admin_Branch__c();
		admin.Admin_User__c = 'BDMUser';
		admin.Name = 'Test Branch';
		insert admin;

		User u = [SELECT Id FROM User WHERE name = 'BDMUser'];

		Account branch = TestFactory.createAccount('Test Branch', '98662', 'BBSI Branch', false);
		branch.Branch_Manager__c = 'Area Manager';
		branch.Lead_AM_Approval__c = true;

		Lead l = new lead();

		System.runAs(u) {
			Test.startTest();

			insert branch;

			Account rp = TestFactory.createAccountReferralPartner(
				'Referral Partner Test',
				'Active',
				'% of Margin',
				12.0,
				null,
				true
			);

			l = new Lead(
				LastName = 'TestBDM',
				Company = 'BDM Company',
				Status = 'Assigned',
				Branch__c = branch.Id,
				Phone = TestFactory.nextPhoneNumber(),
				RecordTypeId = RecordTypeService.getId('Lead', 'Client_Lead')
			);
			l.Referral_Partner__c = rp.Id;
			l.Producer__c = TestFactory.CreateContact(rp, 'Producer', 'Producer', true).Id;
			insert l;

			l.Area_Manager_Comments__c = 'Test Comments';

			try {
				update l;
			} catch (DMLException e) {
				Assert.isTrue(false);
			}

			Test.stopTest();

			Assert.areEqual(
				'Test Comments',
				[SELECT Area_Manager_Comments__c FROM Lead WHERE Id = :l.Id]
				.Area_Manager_Comments__c
			);
		}
	}
}