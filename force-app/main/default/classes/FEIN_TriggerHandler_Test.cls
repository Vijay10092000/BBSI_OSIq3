/**
 * @description FEIN_TriggerHandler_Test contains tests for the FEIN_TriggerHandler class.
 */
@IsTest
@SuppressWarnings('PMD.ApexAssertionsShouldIncludeMessage')
public without sharing class FEIN_TriggerHandler_Test {
    @TestSetup
	static void setupTests(){
        UserRole role = TestFactoryUserRole.createUserRole('Parent Role', null);
        UserRole parentRole = TestFactoryUserRole.createUserRole('BU Role', role.Id, null);

        list<User> uList = new list<User>();
        User areaManager = TestFactoryUser.makeUser('Area','Manager', 'Area Manager', '910', 'AreaManager@bbsihq.com', 'AreaManager@bbsihq.com');
        areaManager.title = 'Area Manager';
        areaManager.UserRoleId = role.ID;
        uList.add(areaManager);
        User u = TestFactoryUser.makeUser(null, 'BDMUser', 'BBSI Standard', '910', 'TestBBSI@bbsihq.com', 'TestBBSI@bbsihq.com');//
        u.title = 'Business Development Manager';
        u.UserRoleId = parentRole.Id;
        uList.add(u);         
        insert uList;

        System.runAs(areaManager) {
            Account branch = TestFactoryAccount.createBranch('Test Branch', '910', 'Area Manager', 'Test@Test.com');            
		    Account rp = TestFactoryAccount.createReferralPartner('Test Referral Partner','% of Work Comp',10,null);
            TestFactoryContact.createContact(null, 'TestProducer', 'Producer',rp.id);     
        }
    }

    private static List<Account> createAccounts(Integer count, Integer start, String recordType, String fein) {
        List<Account> accounts = new List<Account>();
        Account a;
        for (Integer i = 0; i < count; i++) {
            a = TestFactoryAccount.makeAccount('Test Account ' + (start + i), recordType);
            a.FEIN__c = fein;
            accounts.add(a);
        }
        return accounts;
    }

    private static List<Lead> createLeads(Integer count, Integer start, String recordType, String name) {
        Account branch = [SELECT Id FROM Account WHERE Name = 'Test Branch'];
        User u = [SELECT ID FROM user WHERE name = 'BDMUser'];
        Account rp = [SELECT Id FROM Account WHERE Name = 'Test Referral Partner'];
        Contact c = [SELECT Id FROM Contact WHERE LastName = 'TestProducer'];

        List<Lead> leads = new List<Lead>();
        Lead l;
        for (Integer i = 0; i < count; i++) {
            l = TestFactoryLead.makeClientLead(null, 'TestBDM' + start, 'BDM Company ' + start, branch.Id, u.Id);
            l.Referral_Partner__c = rp.Id;
            l.Producer__c = c.Id;
            l.FEIN__c = name;

            leads.add(l);
            start++;
        }
		
        return leads;
    }

    @isTest
    static void newAccountNoFEIN(){
        Test.startTest();
        Account a = TestFactoryAccount.makeClient('Test Account',null,null);
        a.FEIN__c = null;
        insert a;
        Test.stopTest();

        a = [SELECT Id, FEIN__c, FEIN_Id__c FROM Account WHERE Id = :a.Id];
        Assert.isNull(a.FEIN__c);
    }

    @isTest
    static void newLeadNoFEIN(){
        Test.startTest();
        FEIN__c f = TestFactoryFEIN.createFEIN(new Map<String, Object> {'Name' => '00-0000000'});
        Lead l = createLeads(1, 1, 'Client Lead', null).get(0);
        insert l;
        Test.stopTest();

        l = [SELECT Id, FEIN__c, FEIN_Id__c FROM Lead WHERE Id = :l.Id];
        Assert.isNull(l.FEIN__c);
    }

	@isTest
    static void newAccountCreatesFEIN(){
        Test.startTest();
        Account a = TestFactoryAccount.makeClient('Test Account', null, null);
        a.BillingPostalCode = '11111';
        a.FEIN__c = '00-0000001';
        insert a;

        Test.stopTest();

        a = [SELECT Id, FEIN__c, FEIN_Id__c FROM Account WHERE Id = :a.Id];
        FEIN__c f = [SELECT Id, Name FROM FEIN__c WHERE Name = '00-0000001'];

        Assert.isNotNull(f.Id);
        Assert.areEqual('00-0000001', a.FEIN__c);
        Assert.areEqual(f.Id, a.FEIN_Id__c);
    }

    @isTest
    static void newLeadCreatesFEIN(){
        Test.startTest();
        Lead l = createLeads(1, 1, 'Client Lead', '00-0000000').get(0);
        insert l;
        Test.stopTest();

        l = [SELECT Id, FEIN__c, FEIN_Id__c FROM Lead WHERE Id = :l.Id];
        FEIN__c f = [SELECT Id, Name FROM FEIN__c WHERE Name = '00-0000000'];

        Assert.isNotNull(f.Id);
        Assert.areEqual('00-0000000', l.FEIN__c);
        Assert.areEqual(f.Id, l.FEIN_Id__c);
    }

    @isTest
    static void newAccountWithExistingFEIN(){
        Test.startTest();
        FEIN__c f = TestFactoryFEIN.createFEIN(new  Map<String, Object> {'Name' => '00-0000000'});

        Account a = TestFactoryAccount.makeClient('Test Account',null,null);
        a.FEIN__c = '00-0000000';
        insert a;
        Test.stopTest();

        a = [SELECT Id, FEIN__c, FEIN_Id__c FROM Account WHERE Id = :a.Id];
        Assert.areEqual('00-0000000', a.FEIN__c);
        Assert.areEqual(f.Id, a.FEIN_Id__c);
    }

    @isTest
    static void newLeadWithExistingFEIN(){
        Test.startTest();
        FEIN__c f = TestFactoryFEIN.createFEIN(new  Map<String, Object> {'Name' => '00-0000000'});
        Lead l = createLeads(1, 1, 'Client Lead', '00-0000000').get(0);
        insert l;

        Test.stopTest();

        l = [SELECT Id, FEIN__c, FEIN_Id__c FROM Lead WHERE Id = :l.Id];
        Assert.areEqual('00-0000000', l.FEIN__c);
        Assert.areEqual(f.Id, l.FEIN_Id__c);
    }

    @isTest
    static void oldAccountCreatesFEIN(){
        Test.startTest();
        FEIN__c f = TestFactoryFEIN.createFEIN(new  Map<String, Object> {'Name' => '00-0000000'});

        Account a = TestFactoryAccount.makeClient('Test Account',null,null);
        a.FEIN__c = '00-0000000';
        insert a;

        delete f;

        a = [SELECT Id, FEIN__c, FEIN_Id__c FROM Account WHERE Id = :a.Id];
        // Confirm Account has a FEIN__C, but no FEIN_Id__c
        Assert.areEqual('00-0000000', a.FEIN__c);
        Assert.isNull(a.FEIN_Id__c);

        a.Annual_Billing__c = 9000;
        update a;

        Test.stopTest();

        a = [SELECT Id, FEIN__c, FEIN_Id__c FROM Account WHERE Id = :a.Id];
        f = [SELECT Id, Name FROM FEIN__c WHERE Name = '00-0000000'];
        Assert.areEqual('00-0000000', a.FEIN__c);
        Assert.areEqual(f.Id, a.FEIN_Id__c);
    }

    @isTest
    static void oldLeadCreatesFEIN(){
        Test.startTest();
        FEIN__c f = TestFactoryFEIN.createFEIN(new  Map<String, Object> {'Name' => '00-0000000'});
        Account branch = [SELECT Id FROM Account WHERE Name = 'Test Branch'];
        Account rp = [SELECT Id FROM Account WHERE Name = 'Test Referral Partner'];
        User u = [SELECT ID FROM user WHERE name = 'BDMUser'];		

        Lead l = TestFactoryLead.makeClientLead(null,'TestLead','Test Company',branch.ID,u.ID);
        l.FEIN__c = '00-0000000';
        insert l;
        
        delete f;

        l = [SELECT Id, FEIN__c, FEIN_Id__c FROM Lead WHERE Id = :l.Id];
        // Confirm Lead has a FEIN__C, but no FEIN_Id__c
        Assert.areEqual('00-0000000', l.FEIN__c);
        Assert.areEqual(null, l.FEIN_Id__c);

        l.FirstName = 'Change';
        update l;

        Test.stopTest();

        l = [SELECT Id, FEIN__c, FEIN_Id__c FROM Lead WHERE Id = :l.Id];
        f = [SELECT Id, Name FROM FEIN__c WHERE Name = '00-0000000'];
        Assert.areEqual('00-0000000', l.FEIN__c);
        Assert.areEqual(f.Id, l.FEIN_Id__c);
    }

    @isTest
    static void newFEIN(){
        Test.startTest();
		FEIN__c newFein = TestFactoryFEIN.createFEIN(new  Map<String, Object> {'Name' => '00-0000000'});
        Test.stopTest();

        List<Account> accounts = [SELECT Id, FEIN__c, FEIN_Id__c FROM Account WHERE FEIN_Id__c = :newFein.Id];
        Assert.areEqual(0, accounts.size());
        List<Lead> leads = [SELECT Id, FEIN__c, FEIN_Id__c FROM Lead WHERE FEIN_Id__c = :newFein.Id];
        Assert.areEqual(0, leads.size());
    }

    @isTest
    static void newFEINConnectsAccounts(){
        Test.startTest();

        Account a = TestFactoryAccount.makeClient('Test Account',null,null);
        a.FEIN__c = '00-0000000';
        insert a;

        FEIN__c fein = [SELECT Id, Name FROM FEIN__c WHERE Name = '00-0000000'];
        delete fein;

        a = [SELECT Id, FEIN__c, FEIN_Id__c FROM Account WHERE Id = :a.Id];
        Assert.areEqual('00-0000000', a.FEIN__c);
        Assert.isNull(a.FEIN_Id__c);

	    FEIN__c newFein = TestFactoryFEIN.createFEIN(new  Map<String, Object> {'Name' => '00-0000000'});
        Test.stopTest();

        a = [SELECT Id, FEIN__c, FEIN_Id__c FROM Account WHERE Id = :a.Id];
        Assert.areEqual('00-0000000', a.FEIN__c);
        Assert.areEqual(newFein.Id, a.FEIN_Id__c);
    }

    @isTest
    static void newFEINConnectsLeads(){
        Test.startTest();
        Account branch = [SELECT Id FROM Account WHERE Name = 'Test Branch'];
        Account rp = [SELECT Id FROM Account WHERE Name = 'Test Referral Partner'];
        User u = [SELECT ID FROM user WHERE name = 'BDMUser'];
        Lead l = TestFactoryLead.makeClientLead(null,'TestLead','Test Company',branch.ID,u.ID);
        l.Phone = TestFactory.nextPhoneNumber();
        l.RecordTypeId =  RecordTypeService.getId('Lead','Client_Lead');
        l.Referral_Partner__c = rp.id;
        l.Producer__c = TestFactoryContact.createContact(null, 'Producer', 'Producer',rp.id).id;
        l.FEIN__c = '00-0000000';
        insert l;

        FEIN__c fein = [SELECT Id, Name FROM FEIN__c WHERE Name = '00-0000000'];
        delete fein;

        l = [SELECT Id, FEIN__c, FEIN_Id__c FROM Lead WHERE Id = :l.Id];
        Assert.areEqual('00-0000000', l.FEIN__c);
        Assert.isNull(l.FEIN_Id__c);
        FEIN__c newFein = TestFactoryFEIN.createFEIN(new  Map<String, Object> {'Name' => '00-0000000'});
        Test.stopTest();

        l = [SELECT Id, FEIN__c, FEIN_Id__c FROM Lead WHERE Id = :l.Id];
        Assert.areEqual('00-0000000', l.FEIN__c);
        Assert.areEqual(newFein.Id, l.FEIN_Id__c);
    }

    @isTest
    static void whenAccountChangesFEIN(){
        Test.startTest();
        FEIN__c f1 = TestFactoryFEIN.makeFEIN(new  Map<String, Object> {'Name' => '00-0000001'});
		FEIN__c f2 = TestFactoryFEIN.makeFEIN(new  Map<String, Object> {'Name' => '00-0000002'});
        insert new List<FEIN__c> {f1, f2};
        Account a = TestFactoryAccount.makeClient('Test Account',null,null);
        a.FEIN__c = '00-0000001';
        insert a;

        a = [SELECT Id, FEIN__c, FEIN_Id__c FROM Account WHERE Id = :a.Id];
        a.FEIN__c = '00-0000002';
        update a;

        Test.stopTest();

        a = [SELECT Id, FEIN__c, FEIN_Id__c FROM Account WHERE Id = :a.Id];
        f1 = [SELECT Id, Name, Status__c, Client_Count__c FROM FEIN__c WHERE Id = :f1.Id];
        f2 = [SELECT Id, Name, Status__c, Client_Count__c FROM FEIN__c WHERE Id = :f2.Id];

        Assert.areEqual('00-0000002', a.FEIN__c);
        Assert.areEqual(f2.Id, a.FEIN_Id__c);
        Assert.areEqual(0, f1.Client_Count__c);
        Assert.areEqual(1, f2.Client_Count__c);
    }

    @isTest
    static void whenLeadChangesFEIN(){
        Test.startTest();
        FEIN__c f1 = TestFactoryFEIN.makeFEIN(new  Map<String, Object> {'Name' => '00-0000000'});
		FEIN__c f2 = TestFactoryFEIN.makeFEIN(new  Map<String, Object> {'Name' => '00-0000001'});
        insert new List<FEIN__c> {f1, f2};
        Lead l = createLeads(1, 1, 'Client Lead', '00-0000000').get(0);
        insert l;

        l = [SELECT Id, FEIN__c, FEIN_Id__c FROM Lead WHERE Id = :l.Id];

        Assert.areEqual('00-0000000', l.FEIN__c);
        Assert.areEqual(f1.Id, l.FEIN_Id__c);

        l.FEIN__c = '00-0000001';
        update l;

        Test.stopTest();

        l = [SELECT Id, FEIN__c, FEIN_Id__c FROM Lead WHERE Id = :l.Id];

        Assert.areEqual('00-0000001', l.FEIN__c);
        Assert.areEqual(f2.Id, l.FEIN_Id__c);
    }

    @isTest
    static void whenAccountChangesFEINToNull(){
        Test.startTest();
		FEIN__c f1 = TestFactoryFEIN.makeFEIN(new  Map<String, Object> {'Name' => '00-0000000'});
		FEIN__c f2 = TestFactoryFEIN.makeFEIN(new  Map<String, Object> {'Name' => '00-0000001'});
        insert new List<FEIN__c> {f1, f2};
        Account a = TestFactoryAccount.makeClient('Test Account',null,null);
        a.FEIN__c = '00-0000000';
        insert a;

        a = [SELECT Id, FEIN__c, FEIN_Id__c FROM Account WHERE Id = :a.Id];

        Assert.areEqual('00-0000000', a.FEIN__c);
        Assert.areEqual(f1.Id, a.FEIN_Id__c);

        a.FEIN__c = null;
        update a;

        Test.stopTest();

        a = [SELECT Id, FEIN__c, FEIN_Id__c FROM Account WHERE Id = :a.Id];

        Assert.isNull(a.FEIN__c);
        Assert.isNull(a.FEIN_Id__c);
    }

    @isTest
    static void whenLeadChangesFEINToNull(){
        Test.startTest();
		FEIN__c f1 = TestFactoryFEIN.makeFEIN(new  Map<String, Object> {'Name' => '00-0000000'});
		FEIN__c f2 = TestFactoryFEIN.makeFEIN(new  Map<String, Object> {'Name' => '00-0000001'});
        insert new List<FEIN__c> {f1, f2};
        Lead l = createLeads(1, 1, 'Client Lead', '00-0000000').get(0);
        insert l;

        l = [SELECT Id, FEIN__c, FEIN_Id__c FROM Lead WHERE Id = :l.Id];

        Assert.areEqual('00-0000000', l.FEIN__c);
        Assert.areEqual(f1.Id, l.FEIN_Id__c);

        l.FEIN__c = null;
        update l;

        Test.stopTest();

        l = [SELECT Id, FEIN__c, FEIN_Id__c FROM Lead WHERE Id = :l.Id];

        Assert.isNull(l.FEIN__c);
        Assert.isNull(l.FEIN_Id__c);
    }

    @isTest
    static void newAccountsCreateOnlyOneFEIN(){
        Test.startTest();
        List<Account> accounts = new List<Account>();
        Account a1 = TestFactoryAccount.makeClient('Test Account 1',null,null);
        a1.FEIN__c = '00-0000000';
        accounts.add(a1);
        Account a2 = TestFactoryAccount.makeClient('Test Account 2',null,null);
        a2.FEIN__c = '00-0000000';
        accounts.add(a2);
        Account a3 = TestFactoryAccount.makeClient('Test Account 3',null,null);
        a3.FEIN__c = '00-0000000';
        accounts.add(a3);
        insert accounts;
        Test.stopTest();

        List<FEIN__c> feins = [SELECT Id, Name FROM FEIN__c WHERE Name = '00-0000000'];
        Assert.areEqual(1, feins.size());
    }
}