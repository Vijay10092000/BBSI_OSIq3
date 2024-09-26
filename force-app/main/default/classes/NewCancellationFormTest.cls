/**
 * @description NewCancellationFormTest contains tests for the NewCancellationForm class.
 */
@IsTest
private class NewCancellationFormTest {
	@IsTest
	static void positiveCreate() {
		Client_Cancellation__c c = new Client_Cancellation__c();
		//User BDM = TestFactory.createUser('Test', 'BDM@bbsihq.com', 'BDM@bbsihq.com', 'BBSI Standard', '910', true);
		User BDM = TestFactoryuser.createUser('','Test','BBSI Standard', '910','BDM@bbsihq.com', 'BDM@bbsihq.com');
		/*Account Branch = new Account();
		Branch.Name = 'Test Branch';
		Branch.Branch_Manager__c = 'Test';
		Branch.RecordTypeId = RecordTypeService.getId('Account', 'BBSI_Branch');
		Branch.Branch_Manager_Email__c = 'Test@Test.com';
		insert Branch;*/
		Account Branch = TestFactoryAccount.makeBranch('Test Branch','910',null,null);
		Account a = new Account();
		a.Name = 'Cancelled Client';
		a.Business_Development_Manager__c = BDM.Id;
		a.Prospect_Branch__c = Branch.Id;
		insert a;

		Event e = new Event();
		e.RecordTypeId = RecordTypeService.getId('Event', 'Client_Event');

		//Need to give Cancellation Form a Event for Last Core Visit
		//Need to give Cancellation Form a Parent Account

		c.Client__c = a.Id;
		c.Last_Check_Date__c = System.today();
		c.Where_did_the_business_go__c = 'Business Sold';

		try {
			insert c;
		} catch (DMLException eDML) {
			Assert.fail('An exception should NOT have been thrown\n' + eDML);
		}
	}

	@IsTest
	static void negativeCreate() {
		Client_Cancellation__c c = new Client_Cancellation__c();
		//User BDM = TestFactory.createUser('Test', 'BDM@bbsihq.com', 'BDM@bbsihq.com', 'BBSI Standard', '910', true);
		User BDM = TestFactoryUser.createBDM('firstuser','Test','BBSI Standard', '910');
		Account a = new Account();
		a.Name = 'Cancelled Client';
		a.Business_Development_Manager__c = BDM.Id;
		insert a;

		//Do not give the Cancellation Form a Client
		//c.Client__c = a.Id;
		c.Where_did_the_business_go__c = 'Business Sold';

		try {
			insert c;
			Assert.fail('An exception should have been thrown - missing Client__c.');
		} catch (DMLException e) {
			Assert.isTrue(e.getMessage().contains('Required fields are missing'));
		}
	}

	@IsTest
	static void amApprovalInsert() {
		//Client_Cancellation__c c = new Client_Cancellation__c();

		/*User areaManager = TestFactory.createUser(
			'Test',
			'AreaManager@bbsihq.com',
			'AreaManager@bbsihq.com',
			'Area Manager',
			'910',
			false
		);
		
		areaManager.Title = 'Area Manager';
		insert areaManager;*/
		User areaManager = TestFactoryUser.createAreaManager('testareamanager','Test','910');
		System.runAs(areaManager) {
			/*Account Branch = new Account();
			Branch.Name = 'Test Branch';
			Branch.Branch_Manager__c = 'Test';
			Branch.RecordTypeId = RecordTypeService.getId('Account', 'BBSI_Branch');
			Branch.Branch_Manager_Email__c = 'Test@Test.com';
			insert Branch;*/
			 Account Branch = TestFactoryAccount.makeBranch('Test Branch','910',null,null);
			Account a = new Account();
			a.Name = 'Cancelled Client';
			a.Prospect_Branch__c = Branch.Id;
			insert a;

			Event e = new Event();
			e.RecordTypeId = RecordTypeService.getId('Event', 'Client_Event');

			//Need to give Cancellation Form a Event for Last Core Visit
			//Need to give Cancellation Form a Parent Account
            Client_Cancellation__c c = TestFactoryClientCancellation.createClientCancellation(a.Id,System.today(),'BBSI',new Map<String, Object>{
            'Last_Check_Date__c' => System.today(),
			'Where_did_the_business_go__c' => 'Business Sold',
			'AM_Approval_Status__c'  => 'Approved',
			'AM_Comments__c' => 'approval comments'
        });
            /*
			c.Client__c = a.Id;
			c.Last_Check_Date__c = System.today();
			c.Where_did_the_business_go__c = 'Business Sold';
			c.AM_Approval_Status__c = 'Approved';
			c.AM_Comments__c = 'approval comments';

			insert c;
			*/
			c.Revoke__c = true;
			c.Revoked_Reason__c = 'Risk';
			update c;
		}
	}

	@IsTest
	static void amApprovalPositiveUpdate() {
		UserRole parentRole = new UserRole();
		parentRole.Name = 'Parent Role';
		insert parentRole;

		UserRole Role = new UserRole();
		Role.Name = 'BU Role';
		Role.ParentRoleId = parentRole.Id;
		insert Role;

		Client_Cancellation__c c = new Client_Cancellation__c();
		/*
		User BDM = TestFactory.createUser('Test', 'BDM@bbsihq.com', 'BDM@bbsihq.com', 'BBSI Standard', '910', false);
		BDM.UserRoleID = role.Id;
		insert BDM;
		*/
		User BDM = TestFactoryUser.createBDM('firstuser','Test','BBSI Standard', '910');
		/*User areaManager = TestFactory.createUser(
			'Test',
			'AreaManager@bbsihq.com',
			'AreaManager@bbsihq.com',
			'Area Manager',
			'910',
			false
		);
		areaManager.UserRoleId = parentRole.Id;
		areaManager.Title = 'Area Manager';
		insert areaManager;*/
		User areaManager = TestFactoryUser.makeAreaManager('testareamanager','Test','910');
        areaManager.UserRoleId = parentRole.Id;
		areaManager.Title = 'Area Manager';
        insert areaManager;
		System.runAs(BDM) {
			/*Account Branch = new Account();
			Branch.Name = 'Test Branch';
			Branch.Branch_Manager__c = 'Test';
			Branch.RecordTypeId = RecordTypeService.getId('Account', 'BBSI_Branch');
			Branch.Branch_Manager_Email__c = 'Test@Test.com';
			insert Branch;*/
			 Account Branch = TestFactoryAccount.makeBranch('Test Branch','910',null,null);
			Account a = new Account();
			a.Name = 'Cancelled Client';
			a.Business_Development_Manager__c = BDM.Id;
			a.Prospect_Branch__c = Branch.Id;
			insert a;

			Event e = new Event();
			e.RecordTypeId = RecordTypeService.getId('Event', 'Client_Event');

			//Need to give Cancellation Form a Event for Last Core Visit
			//Need to give Cancellation Form a Parent Account

			c.Client__c = a.Id;
			c.Last_Check_Date__c = System.today();
			c.Where_did_the_business_go__c = 'Business Sold';
			insert c;
		}

		System.runAs(areaManager) {
			c.AM_Approval_Status__c = 'Approved';
			c.AM_Comments__c = 'approval comments';
			c.Communication_with_Client_Attached__c = true;
			//update c;

			c.Revoke__c = true;
			c.Revoked_Reason__c = 'Risk';
			//update c;
		}
	}

	@IsTest
	static void amApprovalNegativeUpdate() {
		//Client_Cancellation__c c = new Client_Cancellation__c();

		//User BDM = TestFactory.createUser('Test', 'BDM@bbsihq.com', 'BDM@bbsihq.com', 'BBSI Standard', '910', false);
        User BDM = TestFactoryUser.createBDM('firstuser','Test','BBSI Standard', '910');
		BDM.Title = 'Business Development Manager';
		//insert BDM;
		
		System.runAs(BDM) {
			/*Account Branch = new Account();
			Branch.Name = 'Test Branch';
			Branch.Branch_Manager__c = 'Not Test';
			Branch.RecordTypeId = RecordTypeService.getId('Account', 'BBSI_Branch');
			Branch.Branch_Manager_Email__c = 'Test@Test.com';
			insert Branch;*/
			 Account Branch = TestFactoryAccount.makeBranch('Test Branch','910',null,null);
			Account a = new Account();
			a.Name = 'Cancelled Client';
			a.Business_Development_Manager__c = BDM.Id;
			a.Prospect_Branch__c = Branch.Id;
			insert a;

			//Need to give Cancellation Form a Event for Last Core Visit
			//Need to give Cancellation Form a Parent Account
			/*
			c.Client__c = a.Id;
			c.Last_Check_Date__c = System.today();
			c.Where_did_the_business_go__c = 'Business Sold';
			insert c;
			*/
             Client_Cancellation__c c = TestFactoryClientCancellation.createClientCancellation(a.Id,System.today(),'BBSI',new Map<String, Object>{
            'Last_Check_Date__c' => System.today(),
			'Where_did_the_business_go__c' => 'Business Sold'
			
        });
			c.AM_Approval_Status__c = 'Approved';
			c.AM_Comments__c = 'approval comments';
			c.Communication_with_Client_Attached__c = true;

			try {
				update c;
			} catch (DMLException e) {
				System.debug(e);
			}
		}
	}

	@IsTest
	static void delegatePositiveApproval() {
		/*
        UserRole Role = new UserRole();
        Role.Name = 'BU Role';
        insert Role;
        */

		Admin_Branch__c admin = new Admin_Branch__c();
		admin.Admin_User__c = 'BDMUser';
		admin.Name = 'Test Branch';
		insert admin;

		/*User BDM = TestFactory.createUser(
			'BDMUser',
			'TestBBSI@bbsihq.com',
			'TestBBSI@bbsihq.com',
			'BBSI Standard',
			'910',
			false
		);*/
        User BDM = TestFactoryUser.createBDM('firstuser','Test','BBSI Standard', '910');
		BDM.Title = 'Business Devlopment Manager';
		//insert BDM;
		/*
		User riskUser = TestFactory.createUser(
			'Test',
			'risk@bbsihq.com',
			'risk@bbsihq.com',
			'BBSI Standard',
			'910',
			false
		);*/
        User riskUser = TestFactoryUser.makeUser('testuser','Test','BBSI Standard','910','risk@bbsihq.com','risk@bbsihq.com');
		riskUser.Title = 'Area Manager';
		insert riskUser;

		System.runAs(BDM) {
			/*Account Branch = new Account();
			Branch.Name = 'Test Branch';
			Branch.Branch_Manager__c = 'Test';
			Branch.RecordTypeId = RecordTypeService.getId('Account', 'BBSI_Branch');
			Branch.Branch_Manager_Email__c = 'Test@Test.com';
			Branch.Lead_AM_Approval__c = true;
			insert Branch;*/
			Account Branch = TestFactoryAccount.makeBranch('Test Branch','910',null,null);
			Account a = new Account();
			a.Name = 'Cancelled Client';
			a.Business_Development_Manager__c = BDM.Id;
			a.Prospect_Branch__c = Branch.Id;
			insert a;

			Event e = new Event();
			e.RecordTypeId = RecordTypeService.getId('Event', 'Client_Event');

			//Need to give Cancellation Form a Event for Last Core Visit
			//Need to give Cancellation Form a Parent Account

			/*Client_Cancellation__c c = new Client_Cancellation__c();

			c.Client__c = a.Id;
			c.Last_Check_Date__c = System.today();
			c.Where_did_the_business_go__c = 'Business Sold';
			insert c;*/
             Client_Cancellation__c c = TestFactoryClientCancellation.createClientCancellation(a.Id,System.today(),'BBSI',new Map<String, Object>{
            'Last_Check_Date__c' => System.today(),
			'Where_did_the_business_go__c' => 'Business Sold'
			
        });

			c.AM_Approval_Status__c = 'Approved';
			c.AM_Comments__c = 'approval comments';
			c.Communication_with_Client_Attached__c = true;
			//update c;
		}
	}

	@IsTest
	static void delegateNegativeApproval() {
		//Client_Cancellation__c c = new Client_Cancellation__c();

		/*User BDM = TestFactory.createUser(
			'BDMUser',
			'TestBBSI@bbsihq.com',
			'TestBBSI@bbsihq.com',
			'BBSI Standard',
			'910',
			false
		);*/
        User BDM = TestFactoryUser.createBDM('firstuser','BDMUser','BBSI Standard', '910');
		BDM.Title = 'Business Devlopment Manager';
		//insert BDM;

		/*User riskUser = TestFactory.createUser(
			'Test',
			'risk@bbsihq.com',
			'risk@bbsihq.com',
			'BBSI Standard',
			'910',
			false
		);*/
        User riskUser = TestFactoryUser.makeUser('testuser','Test','BBSI Standard','910','risk@bbsihq.com','risk@bbsihq.com');
		riskUser.Title = 'Area Manager';
		insert riskUser;

		System.runAs(BDM) {
			/*Account Branch = new Account();
			Branch.Name = 'Test Branch';
			Branch.Branch_Manager__c = 'Test';
			Branch.RecordTypeId = RecordTypeService.getId, 'BBSI_Branch');
			Branch.Branch_Manager_Email__c = 'Test@Test.com';
			insert Branch;*/
			Account Branch = TestFactoryAccount.makeBranch('Test Branch','910',null,null);
            insert Branch;
			Account a = new Account();
			a.Name = 'Cancelled Client';
			a.Business_Development_Manager__c = BDM.Id;
			a.Prospect_Branch__c = Branch.Id;
			insert a;

			//Need to give Cancellation Form a Event for Last Core Visit
			//Need to give Cancellation Form a Parent Account

			/*c.Client__c = a.Id;
			c.Last_Check_Date__c = System.today();
			c.Where_did_the_business_go__c = 'Business Sold';
			insert c;*/
			 Client_Cancellation__c c = TestFactoryClientCancellation.createClientCancellation(a.Id,System.today(),'BBSI',new Map<String, Object>{
            'Last_Check_Date__c' => System.today(),
			'Where_did_the_business_go__c' => 'Business Sold'
			
        });
			c.AM_Approval_Status__c = 'Approved';
			c.AM_Comments__c = 'approval comments';
			try {
				update c;
			} catch (DMLException e) {
				System.debug(e);
			}
		}
	}
}