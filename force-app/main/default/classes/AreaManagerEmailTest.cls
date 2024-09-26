/** Updated For US-33150
 * @description AreaManagerEmailTest contains test methods for the AreaManagerEmail class.
 */
@SuppressWarnings('PMD.AvoidHardcodingId')
@IsTest
private class AreaManagerEmailTest {
    private static final Id FAKE_ID = Id.valueOf('00Q500000148cYGEAY');

    @IsTest
    public static void testAreaManagerEmailLeadSingle() {
        Admin_Branch__c admin = TestFactoryAdminBranch.createAdminBranch('TEST SYSTEM\'ADMIN','TEST SYSTEM\'ADMIN');
        User userBDM = TestFactoryUser.createBDM('UserBDM','BDMUser','Area Manager', '910');
        Account testBranch = TestFactoryAccount.makeBranch('TEST SYSTEM\'ADMIN','BBSI Branch',null,null);
        testBranch.Branch_Manager__c = userBDM.LastName;
        testBranch.Branch_Manager_Email__c = userBDM.Email;
        Account rp = TestFactoryAccount.makeReferralPartner('RP Test', '% of Margin', 12.0, null);
        rp.Status__c = 'Active';
        List<Account> accounts = new List<Account>{testBranch, rp};
        insert accounts;
        User systemAdmin = TestFactoryUser.makeUser('TEST', 'SYSTEMADMIN', 'System Administrator', testBranch.External_Id__c);
        systemAdmin.LastName = 'SYSTEM\'ADMIN';
        insert systemAdmin;
        Contact c = TestFactoryContact.createProducer('test','testcontact', rp.Id);

        Lead l = TestFactoryLead.makeClientLead('testlead1','EmailTest','Assigned', testBranch.id, userBDM.id);
        l.Request_Area_Manager_Approval__c = false;
        l.Referral_Partner__c = rp.Id;
        l.Producer__c = c.Id;
        system.runAs(systemAdmin){
            insert l;
        }

        Test.startTest();
        l.Request_Area_Manager_Approval__c = true;
        update l;
        Test.stopTest();

        Assert.areEqual(1, Email_Service.testEmails.size(), 'Missing Email');
    }

    @IsTest
    public static void testAreaManagerEmailLeadBulk() {
        User areaManager = TestFactoryUser.makeUser('BDMUser_1','BDMUser', 'Area Manager', '910', 'TestBBSI1@bbsihq.com', 'TestBBSI1@bbsihq.com');  
        User areaManager2 = TestFactoryUser.makeUser('BDMUser_2', 'BDMUser2','Area Manager', '910', 'TestBBSI2@bbsihq.com', 'TestBBSI2@bbsihq.com');
        User userBDM1 = TestFactoryUser.makeBDM('UserBDM','BDM_1','Area Manager', '910');
        User userBDM2 = TestFactoryUser.makeBDM('UserBDM2','BDM_1','Area Manager', '910');

        List<User> users = new List<User>{ areaManager, areaManager2, userBDM1, userBDM2 };
		insert users;
        Account testBranch = TestFactoryAccount.makeBranch('TestBranch', null, null,null);
		testBranch.Branch_Manager__c = 'BDMUser';
        testBranch.Branch_Manager_Email__c = 'Test@Test.com';
        Account testBranch2 = TestFactoryAccount.makeBranch('TestBranch2', null, null,null);
        testBranch2.Branch_Manager__c = 'BDMUser2';
        testBranch2.Branch_Manager_Email__c = 'Test@Test.com';
        Account rp = TestFactoryAccount.makeReferralPartner('RP Test', '% of Margin', 12.0, null);
        rp.Status__c = 'Active';
        List<Account> accounts = new List<Account>{testBranch, testBranch2, rp};
        insert accounts;
        Contact c = TestFactoryContact.createProducer('test','testcontact', rp.Id);

        List<Lead> testLead = new List<Lead>();

        for (integer x = 0; x <= 2; x++) {
            Lead l = TestFactoryLead.makeClientLead('testlead1','EmailTest','EmailCompany', testBranch.id, userBDM1.id);
            l.Request_Area_Manager_Approval__c = false;
		    l.Referral_Partner__c = rp.id;
            l.Producer__c = c.Id;
			testLead.add(l);
        }

        for (integer x = 0; x <= 3; x++) {
            Lead l = TestFactoryLead.makeClientLead('testlead2','EmailTest1','EmailCompany', testBranch2.id, userBDM2.id);
            l.Request_Area_Manager_Approval__c = false;
		    l.Referral_Partner__c = rp.id;
            l.Producer__c = c.Id;
			testLead.add(l);
        }

		insert testLead;
        Test.startTest();
        for (lead l : testLead) {
            l.Request_Area_Manager_Approval__c = true;
        }
        update testLead;
        Test.stopTest();

        Assert.areEqual(7, Email_Service.testEmails.size(), 'Missing Emails');
    }

	@IsTest
    public static void testAreaManagerEmailOpportunitySingle(){
        Admin_Branch__c admin = TestFactoryAdminBranch.createAdminBranch('TEST SYSTEM\'ADMIN','TEST SYSTEM\'ADMIN');
        User userBDM1 = TestFactoryUser.createBDM(null,'UserBDM','Area Manager', '910');
        Account testBranch = TestFactoryAccount.createBranch('TEST SYSTEM\'ADMIN');
		testBranch.Branch_Manager__c = 'UserBDM';
        testBranch.Branch_Manager_Email__c = 'Test@Test.com';
        update testBranch;

        Account testClient = TestFactoryAccount.makeClient('TestClient', null, null);
        testClient.Prospect_Branch__c = testBranch.ID;
        testClient.Credit_Limit__c = 350;
        insert testClient;
        User systemAdmin = TestFactoryUser.makeUser('TEST', 'SYSTEMADMIN', 'System Administrator', testBranch.External_Id__c);
        systemAdmin.LastName = 'SYSTEM\'ADMIN';
        insert systemAdmin;

        Opportunity opp = TestFactoryOpportunity.makeClient('TestOpp', testClient.Id, System.today(), 'Identifiying');
        opp.AccountId = testClient.ID;
        opp.Request_Area_Manager_Approval__c = false;
        opp.Credit_Approval_Status__c = 'Approved';
        opp.OK_For_Risk_Approval_Status__c = 'Approved';
        opp.Amount = 1000000;   // Set field: Estimated Annual Billing
        
        system.runAs(systemAdmin){
            insert opp;
            Test.startTest();
            opp.Request_Area_Manager_Approval__c = true;
            update opp;
            Test.stopTest();
        }
        
        Assert.areEqual(2, Email_Service.testEmails.size(), 'Missing Emails');

		Messaging.Email email;
		email = Email_Service.testEmails.get(0);
        Assert.isTrue(email.getSubject().contains('Opportunity Closed'), 'First email should be the Opportunity Closed won or lost');
		email = Email_Service.testEmails.get(1);
        Assert.isTrue(email.getSubject().contains('Prospect Approval in Salesforce'), 'Second email should be the approval');
    }
}