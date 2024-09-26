/**
 * @description FEIN_Services_Test contains tests for the FEIN_Services class.
 */
@IsTest
@SuppressWarnings('PMD.ApexAssertionsShouldIncludeMessage')
public class FEIN_Services_Test {
    @TestSetup static void setupTests(){        
        UserRole role = TestFactoryUserRole.createUserRole('Parent Role', null);
        UserRole parentRole = TestFactoryUserRole.createUserRole('BU Role', role.Id, null);

        User areaManager = TestFactoryUser.makeUser('Area','Manager', 'Area Manager', '910', 'AreaManager@bbsihq.com', 'AreaManager@bbsihq.com');
        areaManager.title = 'Area Manager';
        areaManager.UserRoleId = role.ID;
        User u = TestFactoryUser.makeUser(null, 'BDMUser', 'BBSI Standard', '910', 'TestBBSI@bbsihq.com', 'TestBBSI@bbsihq.com');//
        u.title = 'Business Development Manager';
        u.UserRoleId = parentRole.ID;
        insert new list<User>{ areaManager, u };

        Account r = TestFactoryAccount.makeReferralPartner('Test Referral', '',null,null);
        Account branch = TestFactoryAccount.makeBranch('Test Branch','910','Area Manager','Test@Test.com');

        System.runAs(areaManager){
            insert new List<Account>{ branch, r };
            TestFactoryContact.createContact(null, 'TestProducer', 'Producer',r.id);
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
        Account r = [SELECT Id FROM Account WHERE Name = 'Test Referral'];
        Contact c = [SELECT Id FROM Contact WHERE LastName = 'TestProducer'];

        List<Lead> leads = new List<Lead>();
        Lead l;
        for (Integer i = 0; i < count; i++) {
            l = TestFactoryLead.makeClientLead(null, 'TestBDM' + start, 'BDM Company ' + start, branch.Id, u.Id);
            l.Referral_Partner__c = r.Id;
            l.Producer__c = c.Id;
            l.FEIN__c = name;
            leads.add(l);
            start++;
        }
        return leads;
    }

    @IsTest
    static void getAccountsByFEIN(){
        List<Account> accounts = new List<Account>();
        accounts.addAll(createAccounts(2, 1, 'Client', '00-0000001'));
        accounts.addAll(createAccounts(1, 3, 'Client', '00-0000002'));
        accounts.addAll(createAccounts(1, 4, 'Client', '00-0000003'));
        insert accounts;

        Assert.areEqual(2, FEIN_Services.getAccountsByFein(new Set<String> {'00-0000001'}).size());
        Assert.areEqual(3, FEIN_Services.getAccountsByFein(new Set<String> {'00-0000001', '00-0000002'}).size());
        Assert.areEqual(2, FEIN_Services.getAccountsByFein(new Set<String> {'00-0000002', '00-0000003'}).size());
    }

    @IsTest
    static void checkProspectCount(){
        Test.startTest();

        List<Account> accounts = createAccounts(3, 1, 'Prospect', '00-0000001');
        insert accounts;

        Test.stopTest();

        accounts = [SELECT Id, FEIN__c FROM Account WHERE FEIN__c = '00-0000001'];
        Assert.areEqual(3, accounts.size());

        FEIN__c f = [SELECT Id, Name, Status__c, Prospect_Count__c FROM FEIN__c WHERE Name = '00-0000001'];
        Assert.areEqual(3, f.Prospect_Count__c);
        Assert.areEqual('Prospect', f.Status__c);
    }

    @IsTest
    static void checkClientCount(){
        Test.startTest();

        List<Account> accounts = createAccounts(1, 1, 'Client', '00-0000001');
        insert accounts;

        Test.stopTest();

        accounts = [SELECT Id, FEIN__c FROM Account WHERE FEIN__c = '00-0000001'];
        Assert.areEqual(1, accounts.size());

        FEIN__c f = [SELECT Id, Name, Status__c, Client_Count__c FROM FEIN__c WHERE Name = '00-0000001'];
        Assert.areEqual(1, f.Client_Count__c);
        Assert.areEqual('Client', f.Status__c);
    }

    @IsTest
    static void checkTerminatedCount(){
        Test.startTest();

        List<Account> accounts = createAccounts(3, 1, 'Terminated', '00-0000001');
        insert accounts;

        Test.stopTest();

        accounts = [SELECT Id, FEIN__c FROM Account WHERE FEIN__c = '00-0000001'];
        Assert.areEqual(3, accounts.size());

        FEIN__c f = [SELECT Id, Name, Status__c, Terminated_Count__c FROM FEIN__c WHERE Name = '00-0000001'];

        Assert.areEqual(3, f.Terminated_Count__c);
        Assert.areEqual('Terminated', f.Status__c);
    }

    @IsTest
    static void checkMixedAccounts(){

        Test.startTest();

        List<Account> accounts = new List<Account>();
        Account prospect = createAccounts(1, 1, 'Prospect', '00-0000001').get(0);
        accounts.add(prospect);
        accounts.addAll(createAccounts(3, 1, 'Client', '00-0000001'));
        accounts.addAll(createAccounts(4, 1, 'Terminated', '00-0000001'));
        accounts.addAll(createAccounts(1, 1, 'Parent', '00-0000001'));
        insert accounts;

        Test.stopTest();

        accounts = [SELECT Id, FEIN__c FROM Account WHERE FEIN__c = '00-0000001'];
        Assert.areEqual(9, accounts.size());

        ID recordTypeId = RecordTypeService.getId('Account','Prospect');
        FEIN__c f = [SELECT Id, Name, Status__c, Prospect_Count__c, Client_Count__c, Terminated_Count__c FROM FEIN__c WHERE Name = '00-0000001'];
        prospect = [SELECT ID, FEIN_Id__c, FEIN__c, RecordTypeId FROM Account WHERE Id = :prospect.Id];
        Assert.areEqual(f.Id, prospect.FEIN_Id__c);
        Assert.areEqual(recordTypeId, prospect.RecordTypeId);

        Assert.areEqual(9, FEIN_Services.getAccountsByFein(new Set<String>{'00-0000001'}).size());
        Assert.areEqual(1, f.Prospect_Count__c);
        Assert.areEqual(3, f.Client_Count__c);
        Assert.areEqual(4, f.Terminated_Count__c);
        Assert.areEqual('Client', f.Status__c);
    }

    @IsTest
    static void toClient(){
        Test.startTest();

        Account prospect = createAccounts(1, 1, 'Prospect', '00-0000001').get(0);
        Account client = createAccounts(1, 1, 'Client', '00-0000001').get(0);
        insert new List<Account>{ prospect, client };

        prospect.RecordTypeId = RecordTypeService.getId('Account', 'Client');
        update prospect;

        Test.stopTest();

        FEIN__c f = [SELECT Id, Name, Status__c, Prospect_Count__c, Client_Count__c, Terminated_Count__c, Client_Runoff_Date__c FROM FEIN__c WHERE Name = '00-0000001'];
        prospect = [SELECT Id, FEIN__c, FEIN_Id__c, RecordType.Name FROM Account WHERE Id = :prospect.Id];

        Assert.areEqual('Client', prospect.RecordType.Name);
        Assert.areEqual('00-0000001', prospect.FEIN__c);
        Assert.areEqual(f.Id, prospect.FEIN_Id__c);

        Assert.areEqual('Client', f.Status__c);
        Assert.areEqual(0, f.Prospect_Count__c);
        Assert.areEqual(2, f.Client_Count__c);
    }

    @IsTest
    static void toTerminated(){
        Id idTerminated = RecordTypeService.getId('Account', 'Terminated');
        Date terminated1 = Date.today().addDays(-20);

        Account terminated = createAccounts(1, 1, 'Client', '00-0000001').get(0);
        terminated.RecordTypeId = idTerminated;
        insert terminated;
        TestFactoryClientCancellation.createClientCancellation(terminated.Id, terminated1, 'BBSI', 'Approved', null);

        terminated = [SELECT Id, FEIN__c, FEIN_Id__c, RecordType.Name, Cancellation_Date__c FROM Account WHERE Name = 'Test Account 1'];
        FEIN__c f = [SELECT Id, Name, Status__c, Prospect_Count__c, Client_Count__c, Terminated_Count__c, Client_Runoff_Date__c FROM FEIN__c WHERE Name = '00-0000001'];

        Assert.areEqual('Terminated', terminated.RecordType.Name);
        Assert.areEqual('00-0000001', terminated.FEIN__c);
        Assert.areEqual(terminated1, terminated.Cancellation_Date__c);
        Assert.areEqual(f.Id, terminated.FEIN_Id__c);

        Assert.areEqual('Terminated', f.Status__c);
        Assert.areEqual(0, f.Client_Count__c);
        Assert.areEqual(1, f.Terminated_Count__c);
        Assert.areEqual(terminated.Cancellation_Date__c, f.Client_Runoff_Date__c);
    }

    @IsTest
    static void checkLeadCount(){
        Test.startTest();
        List<Lead> leads = createLeads(4, 1, 'Client Lead', '00-0000001');
        insert leads;

        Test.stopTest();

        leads = [SELECT Id, FEIN__c FROM Lead WHERE FEIN__c = '00-0000001'];
        Assert.areEqual(4, leads.size());

        FEIN__c f = [SELECT Id, Name, Lead_Count__c FROM FEIN__c WHERE Name = '00-0000001'];
        Assert.areEqual(4, f.Lead_Count__c);
    }

    @IsTest
    static void checkChangeNameFailure(){        
        FEIN__c f = TestFactoryFEIN.createFEIN(new Map<String, Object> {'Name' => '00-0000001'});
        try {
            f.Name = '00-0000003';
            update f;

            Assert.fail('Validation exception should have been thrown');
        }
        catch (Exception e) {
			Assert.isTrue(true, 'Exception is expected');
        }
    }

    @IsTest
    static void checkRemoveExistingFeinNames(){
        List<FEIN__c> feins = new List<FEIN__c>();
        feins.add( TestFactoryFEIN.makeFEIN(new Map<String, Object> {'Name' => '00-0000001'}));
        feins.add( TestFactoryFEIN.makeFEIN(new Map<String, Object> {'Name' => '00-0000002'}) );
        feins.add( TestFactoryFEIN.makeFEIN(new Map<String, Object> {'Name' => '00-0000003'}) );
        feins.add( TestFactoryFEIN.makeFEIN(new Map<String, Object> {'Name' => '00-0000004'}) );
        feins.add( TestFactoryFEIN.makeFEIN(new Map<String, Object> {'Name' => '00-0000005'}) );
        insert feins;

        Set<String> names = new Set<String>();
        names.add('00-0000001');
        names.add('00-0000007');
        names.add('00-0000003');
        names.add('');
        names.add('00-0000011');
        names.add('00-0000006');
        names.add('00-0000005');
        names.add('00-0000991');
        names.add(null);

        Set<String> removedNames = FEIN_Services.removeExistingFeinNames(names);

        Assert.areEqual(4, removedNames.size());
        Assert.isTrue(removedNames.contains('00-0000006'));
        Assert.isTrue(removedNames.contains('00-0000007'));
        Assert.isTrue(removedNames.contains('00-0000011'));
        Assert.isTrue(removedNames.contains('00-0000991'));
    }

}