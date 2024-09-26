/**
 * @description Lead_Services_Test contains test methods for the Lead_Services class.
 */
@IsTest
@SuppressWarnings('PMD.ApexAssertionsShouldIncludeMessage')
public with sharing class Lead_Services_Test {
	@IsTest
	public static void test_TriggerHandler() {
		try {
			Account branch1 = TestFactoryAccount.createBranch('TEST_BRANCH');

			User userBdm = TestFactoryUser.createBdm('TEST', 'BDM', 'BBSI Standard', branch1.External_Id__c);

			Lead client = TestFactoryLead.createClientLead(
				'NAME',
				'TESTCLIENTLEAD',
				'Test Company',
				branch1.Id,
				userBdm.Id
			);

			client.LastName = 'TESTCLIENT-UPDATED';
			update client;

			delete client;

			undelete client;
		} catch (Exception e) {
			System.debug(LoggingLevel.ERROR, 'EXCEPTION: ' + e);
			Assert.fail('Exception was thrown.');
		}
	}

	@IsTest
	public static void test_setBranches_Valid() {
		Account branch1 = TestFactoryAccount.makeBranch('TEST_BRANCH_1');
		Account branch2 = TestFactoryAccount.makeBranch('TEST_BRANCH_2');
		insert new List<Account>{ branch1, branch2 };

		User userBdm = TestFactoryUser.makeBDM('TEST', 'BDM', 'BBSI Standard', branch1.External_Id__c);
		User user1 = TestFactoryUser.makeUser('TEST', 'User1', 'BBSI Standard', branch1.External_Id__c);
		User user2 = TestFactoryUser.makeUser('TEST', 'User2', 'BBSI Standard', branch2.External_Id__c);
		insert new List<User>{ userBdm, user1, user2 };

		Lead lead1 = TestFactoryLead.createClientLead('NAME', 'Lead1', 'Lead1 Company', branch1.Id, userBdm.Id);
		lead1.OwnerId = user1.Id;
		Lead lead2 = TestFactoryLead.createClientLead('NAME', 'Lead2', 'Lead2 Company', branch2.Id, userBdm.Id);
		lead2.OwnerId = user2.Id;
		List<Lead> leads = new List<Lead>{ lead1, lead2 };

		Test.startTest();

		Lead_Services.setBranches(leads);

		Test.stopTest();

		Assert.areEqual(branch1.Id, lead1.Branch__c, 'Owner belongs to branch 1');
		Assert.areEqual(branch2.Id, lead2.Branch__c, 'Owner belongs to branch 2');
	}

	@IsTest
	public static void test_addAdditionalContacts() {
		/*
		String numberBranch1 = '999';
		Account branch1 = TestFactoryAccount.createBranch('TEST_BRANCH');
		User userBdm = TestFactoryUser.createBdm('TEST', 'BDM', 'BBSI Standard', branch.External_Id__c);

		Lead lead1 = TestFactoryLead.makeClientLead('LEAD1', 'Lead1 Company', 'Qualified', branch1, userBdm, false);
		lead1.Additional_Contact__c = 'LEAD1_ADD';
		lead1.Additional_Contact_Title__c = 'Additional Title';
		lead1.Additional_Contact_Phone__c = '360 123 4567';
		lead1.Additional_Contact_Mobile__c = '360 234 5678';
		lead1.Additional_Contact_Email__c = 'additional.lead@lead1.zzz';
		lead1.Estimated_Annual_Billing__c = 500000;
		Lead lead2 = TestFactoryLead.makeClientLead('Lead2', 'Lead2 Company', 'Qualified', branch1, userBdm, false);
		lead2.Additional_Contact__c = 'LEAD2_ADD';
		lead2.Additional_Contact_Title__c = 'Additional Title';
		lead2.Additional_Contact_Phone__c = '360 123 4567';
		lead2.Additional_Contact_Mobile__c = '360 234 5678';
		lead2.Additional_Contact_Email__c = 'additional.lead@lead1.zzz';
		lead2.Estimated_Annual_Billing__c = 500000;
		insert new List<Lead>{ lead1, lead2 };

		Test.startTest();

		Database.LeadConvertResult lcr;

		lcr = LeadConvert.convert(lead1.Id, false);
		Assert.isTrue(lcr.isSuccess(), 'Lead1 conversion should not fail');

		lcr = LeadConvert.convert(lead2.Id, false);
		Assert.isTrue(lcr.isSuccess(), 'Lead2 conversion should not fail');

		Test.stopTest();

		Account newAccount1 = [SELECT Id, Name FROM Account WHERE Name = 'Lead1 Company'];
		List<Contact> contacts1 = [SELECT Id, Name, Converted_From_Lead_ID__c, MobilePhone FROM Contact WHERE AccountId = :newAccount1.Id ORDER BY Name];
		Account newAccount2 = [SELECT Id, Name FROM Account WHERE Name = 'Lead2 Company'];
		List<Contact> contacts2 = [SELECT Id, Name, Converted_From_Lead_ID__c, MobilePhone FROM Contact WHERE AccountId = :newAccount2.Id ORDER BY Name];

		Assert.areEqual(2, contacts1.size(), '2 Contacts should exits for Lead1 Company');
		Assert.areEqual(2, contacts2.size(), '2 Contacts should exits for Lead2 Company');

		Contact contact = contacts1.get(0);
		Assert.areEqual('LEAD1', contact.Name);

		contact = contacts1.get(1);
		Assert.areEqual(lead1.Id, contact.Converted_From_Lead_Id__c);
		Assert.areEqual('LEAD1_ADD', contact.Name);
		Assert.areEqual('360-234-5678', contact.MobilePhone);
		*/
	}

	@SuppressWarnings('PMD.AvoidHardcodingId')
	@IsTest
	public static void test_validateNewBranch() {
		Account branch1 = TestFactoryAccount.makeBranch('TEST_BRANCH_1');
		branch1.Id = '001000000000111';
		Account branch2 = TestFactoryAccount.makeBranch('TEST_BRANCH_2');
		branch2.Id = '001000000000222';
		
		Map<String, Account> branches = new Map<String, Account>();
		branches.put(branch1.External_Id__c, branch1);
		branches.put(branch2.External_Id__c, branch2);

		User userBDM = TestFactoryUser.makeBDM('TEST', 'BDM', 'BBSI Standard', branch1.External_Id__c);
		userBDM.Id = '005000000000BDM';
		User user1 = TestFactoryUser.makeUser('TEST', 'UserONE', 'BBSI Standard', branch1.External_Id__c);
		user1.Id = '005000000000111';
		User user2 = TestFactoryUser.makeUser('TEST', 'UserTWO', 'BBSI Standard', branch2.External_Id__c);
		user2.Id = '005000000000222';
		Map<Id, User> users = new Map<Id, User>();
		users.put(user1.Id, user1);
		users.put(user2.Id, user2);

		Lead leadValid = TestFactoryLead.makeClientLead('NAME', 'LeadONE', 'ONE', branch1.Id, userBDM.Id);
		leadValid.OwnerId = user1.Id;
		Lead leadInvalid = TestFactoryLead.makeClientLead('NAME', 'LeadTWO', 'TWO', branch2.Id, userBDM.Id);
		leadInvalid.OwnerId = user1.Id;

		Lead_Services.validateNewBranch(leadValid, users, branches);
		Assert.isFalse(leadValid.hasErrors(), 'Valid lead should not have errors.');

		Lead_Services.validateNewBranch(leadInvalid, users, branches);
		Assert.isTrue(leadInvalid.hasErrors(), 'Invalid lead should have errors.');
	}

	@IsTest
	public static void test_taskOnQualified() {
		Account branch = TestFactoryAccount.createBranch('BRANCH');
		User userBDM = TestFactoryUser.createBDM('TEST', 'BDM', 'BBSI Standard', branch.External_Id__c);

		Lead lead = TestFactoryLead.makeClientLead('NAME', 'Lead', 'ONE', branch.Id, userBDM.Id);
		lead.OwnerId = userBDM.Id;
		insert lead;
		lead = [SELECT Id, OwnerId, Name_Branch__c, Televerde_Status__c, Call_Notes__c, Appointment_Date__c FROM Lead WHERE Id = :lead.Id];
		Assert.areNotEqual(null, lead.OwnerId, 'Lead has owner');
		Assert.areEqual(branch.Name, lead.Name_Branch__c, 'Name Branch should be set');

		List<Task> tasks;

		tasks = [SELECT Id FROM Task WHERE WhoId = :lead.Id];
		Assert.areEqual(0, tasks.size(), 'Lead should start with no tasks');

		Test.startTest();

		Map<Id, Lead> mapLeads = new Map<Id, Lead>();
		mapLeads.put(lead.Id, lead);

		lead.Televerde_Status__c = 'Qualified';

		Lead_Services.taskOnQualified(null, mapLeads);

		Test.stopTest();

		tasks = [SELECT Id, Subject FROM Task WHERE WhoId = :lead.Id];
		Assert.areEqual(1, tasks.size(), 'Lead should have a task.');
		Assert.areEqual('Appointment Scheduled by Televerde', tasks.get(0).Subject, 'Task should be about Televerde');
	}

	@IsTest
	static void test_updateLeadFields() {
		Account branch = TestFactoryAccount.createBranch('!!TEST BRANCH');

		User user = TestFactoryUser.createUser('TEST', '!!USER', 'BBSI Standard', branch.External_Id__c);

		Lead lead1 = TestFactoryLead.makeClientLead('NAME', 'TESTLEAD1', '!!TEST COMPANY1', branch.Id, user.Id);
		Lead lead2 = TestFactoryLead.makeClientLead('NAME', 'TESTLEAD2', '!!TEST COMPANY2', branch.Id, user.Id);
		Lead lead3 = TestFactoryLead.makeClientLead('NAME', 'TESTLEAD3', '!!TEST COMPANY2', branch.Id, user.Id);
		Lead lead4 = TestFactoryLead.makeClientLead('NAME', 'TESTLEAD2', '!!TEST COMPANY2', branch.Id, user.Id);
		Lead lead5 = TestFactoryLead.makeClientLead('NAME', 'TESTLEAD3', '!!TEST COMPANY2', branch.Id, user.Id);
		insert new List<Lead>{lead1, lead2, lead3, lead4, lead5};

		Task task1 = Task_Service.createTaskCompleted('Task', lead1.Id, null, user.Id, 'TEST TASK', 'TEST TASK');
		Task task2 = Task_Service.createTaskCompleted('Task', lead2.Id, null, user.Id, 'TEST TASK', 'TEST TASK');
		Task task3 = Task_Service.createTaskCompleted('Task', lead3.Id, null, user.Id, 'TEST TASK', 'TEST TASK');
		Task task4 = Task_Service.createTaskCompleted('Task', lead4.Id, null, user.Id, 'TEST TASK', 'TEST TASK');
		Task task5 = Task_Service.createTaskCompleted('Task', lead5.Id, null, user.Id, 'TEST TASK', 'TEST TASK');
		insert new List<Task>{task1, task2, task3, task4, task5};

		lead1 = [SELECT Id, Status FROM Lead WHERE Id = :lead1.Id];
		Assert.areNotEqual('Qualified', lead1.Status);
		Assert.areNotEqual('Unqualified', lead1.Status);

		Test.startTest();

		task1.put('CallDisposition', 'Appointment Set');
		task2.put('CallDisposition', 'Not Interested');
		task3.put('CallDisposition', 'Do not call');
		task4.put('CallDisposition', 'Not Qualified');
		task5.put('CallDisposition', 'Left Message');

		update new List<Task>{task1, task2, task3, task4, task5};
		Test.stopTest();

		lead1 = [SELECT Id, Status FROM Lead WHERE Id = :lead1.Id];
		Assert.areEqual('Qualified', lead1.Status);

		/** POSTPONED until the 2023 Q1 RELEASE - Azure User Story 41538
		List<Task> newTasks = [
			SELECT Id, Type
			FROM Task
			WHERE RecordType.Name = 'Task'
			AND Type = 'Call Center Appointment'
		];
		Assert.areEqual(1, newTasks.size());
		*/

		lead2 = [SELECT Id, Status FROM Lead WHERE Id = :lead2.Id];
		Assert.areEqual('Unqualified', lead2.Status);

		lead3 = [SELECT Id, Status FROM Lead WHERE Id = :lead3.Id];
		Assert.areEqual('Unqualified', lead3.Status);

		lead4 = [SELECT Id, Status FROM Lead WHERE Id = :lead4.Id];
		Assert.areEqual('Unqualified', lead4.Status);

		lead5 = [SELECT Id, Status FROM Lead WHERE Id = :lead5.Id];
		Assert.areEqual('Assigned', lead5.Status);
	}

	/** POSTPONED until the 2023 Q1 RELEASE - Azure User Story 41538
	@IsTest
	static void test_insertAppointmentTasks() {
		DateTime now = DateTime.now();

		Account branch = TestFactoryAccount.createBranch('TEST BRANCH');

		User user1 = TestFactoryUser.makeUser('ONE', 'TEST', 'BBSI Standard', branch.External_Id__c);
		User user2 = TestFactoryUser.makeUser('TWO', 'TEST', 'BBSI Standard', branch.External_Id__c);
		insert new List<User>{ user1, user2 };

		Lead lead1 = TestFactoryLead.makeClientLead('ONE', 'TEST', 'TEST COMPANY ONE', branch.Id, null);
		Lead lead2 = TestFactoryLead.makeClientLead('TWO', 'TEST', 'TEST COMPANY TWO', branch.Id, null);
		Lead lead3 = TestFactoryLead.makeClientLead('THREE', 'TEST', 'TEST COMPANY THREE', branch.Id, null);
		insert new List<Lead>{ lead1, lead2, lead3 };

		Test.startTest();

		Map<Id, Id> mapLeadIdToOwnerId = new Map<Id, Id>();
		mapLeadIdToOwnerId.put(lead1.Id, user1.Id);
		mapLeadIdToOwnerId.put(lead2.Id, user1.Id);
		mapLeadIdToOwnerId.put(lead3.Id, user2.Id);

		Lead_Services.insertAppointmentTasks(mapLeadIdToOwnerId);

		Test.stopTest();

		List<Task> newTasks = [
			SELECT Id, Type
			FROM Task
			WHERE RecordType.Name = 'Task'
			AND Type = 'Call Center Appointment'
			AND CreatedDate > :now
		];

		Assert.areEqual(3, newTasks.size());
	}

	@IsTest
	static void test_makeAppointmentTask() {
		Account branch = TestFactoryAccount.createBranch('TEST BRANCH');

		User user1 = TestFactoryUser.createUser('ONE', 'TEST', 'BBSI Standard', branch.External_Id__c);

		Lead lead1 = TestFactoryLead.createClientLead('ONE', 'TEST', 'TEST COMPANY ONE', branch.Id, null);

		Test.startTest();

		lead1 = [SELECT Id, Name, Company FROM Lead WHERE Id = :lead1.Id];

		Task task = Lead_Services.makeAppointmentTask(lead1, user1.Id);

		Test.stopTest();

		Assert.areEqual('Call Center Appointment', task.Type);
		Assert.areEqual(user1.Id, task.OwnerId);
		Assert.areEqual(lead1.Id, task.WhoId);
		Assert.areEqual('Appointment Scheduled with ONE TEST, TEST COMPANY ONE', task.Subject);
		Assert.isNotNull(task.ActivityDate);
		Assert.areEqual('Normal', task.Priority);
		Assert.areEqual('Not Started', task.Status);
	}
	*/

	@IsTest
	static void test_nameBranch() {
		Account branch1 = TestFactoryAccount.makeBranch('!!TEST BRANCH 1');
		Account branch2 = TestFactoryAccount.makeBranch('!!TEST BRANCH 2');
		Account branch3 = TestFactoryAccount.makeBranch('!!TEST BRANCH 3');
		insert new List<Account>{branch1, branch2, branch3};

		Test.startTest();

		Lead lead1 = TestFactoryLead.makeClientLead('TEST', 'BBSILEAD1', 'Company 1', branch1.Id, null);
		Lead lead2 = TestFactoryLead.makeClientLead('TEST', 'BBSILEAD2', 'Company 2', branch2.Id, null);
		Lead lead3 = TestFactoryLead.makeClientLead('TEST', 'BBSILEAD3', 'Company 3', branch3.Id, null);
		Lead lead4 = TestFactoryLead.makeClientLead('TEST', 'BBSILEAD4', 'Company 4', branch1.Id, null);
		Lead lead5 = TestFactoryLead.makeClientLead('TEST', 'BBSILEAD5', 'Company 5', branch2.Id, null);
		insert new List<Lead>{lead1, lead2, lead3, lead4, lead5};

		Test.stopTest();

		List<Lead> leads = [
			SELECT Id, Name, Name_Branch__c
			FROM Lead
			WHERE Name LIKE 'TEST BBSILEAD%'
			ORDER BY Name
		];

		Assert.areEqual(5, leads.size());
		Assert.areEqual('!!TEST BRANCH 1', leads[0].Name_Branch__c);
		Assert.areEqual('!!TEST BRANCH 2', leads[1].Name_Branch__c);
		Assert.areEqual('!!TEST BRANCH 3', leads[2].Name_Branch__c);
		Assert.areEqual('!!TEST BRANCH 1', leads[3].Name_Branch__c);
		Assert.areEqual('!!TEST BRANCH 2', leads[4].Name_Branch__c);
	}

	@IsTest
	static void test_SetStage() {
		Account branch = TestFactoryAccount.createBranch('TEST_BRANCH');

		User userIntegration = TestFactoryUser.makeUser('INTEGRATION', 'TEST', 'BBSI Integration', branch.External_Id__c);
		User userRegular = TestFactoryUser.makeUser('TEST', 'User', 'BBSI Standard', branch.External_Id__c);
		insert new List<User>{ userIntegration, userRegular };

		Lead lead1 = TestFactoryLead.makeClientLead('TEST', 'LEAD_1', 'COMPANY_1', null, null);
		lead1.OwnerId = userIntegration.Id;
		lead1.Status = 'Assigned';

		Lead lead2 = TestFactoryLead.makeClientLead('TEST', 'LEAD_2', 'COMPANY_2', null, null);
		lead2.OwnerId = userRegular.Id;

		Lead lead3 = TestFactoryLead.makeClientLead('TEST', 'LEAD_3', 'COMPANY_3', null, null);
		lead3.OwnerId = userRegular.Id;
		lead3.Status = 'Unqualified';		

		Lead lead4 = TestFactoryLead.makeClientLead('TEST', 'LEAD_4', 'COMPANY_4', null, null);
		lead4.OwnerId = userRegular.Id;
		lead4.Status = 'Converted';	
		lead4.IsConverted = true;	
		
		Test.startTest();

		Lead_Services.SetStatus(null, new List<Lead>{ lead1, lead2, lead3, lead4 });
		
		Test.stopTest();
		
		// FUTURE: 2020 Quarter 2: Restore next lines
		//Assert.areEqual('Raw', lead1.Status);
		//Assert.areEqual('Pending', lead1.Lead_Stage__c);

		Assert.areEqual('Assigned', lead2.Status);
		Assert.areEqual('Pending', lead2.Lead_Stage__c);

		Assert.areEqual('Unqualified', lead3.Status);
		Assert.areEqual('Dead', lead3.Lead_Stage__c);

		Assert.areEqual('Converted', lead4.Status);
		Assert.areEqual('Converted', lead4.Lead_Stage__c);
	}
}