/**
 * @description BenefitsDiscovery_TestEnv creates a test environment for tesing
 * the Benefits_Discovery_Questionnaire__c object.
 */
@IsTest
@SuppressWarnings('PMD.ApexAssertionsShouldIncludeMessage, PMD.NcssConstructorCount')
public without sharing class BenefitsDiscovery_TestEnv {
    private static final String BRANCH_HANE = 'TESTBRANCH';

    public Account branch;
    public Account prospect1;
    public Account prospect2;
    public Account prospect3;
    public Account prospect4;
    public Opportunity opp1;
    public Opportunity opp2;
    public Opportunity opp3;
    public Opportunity opp4;
    public User owner;
    public User user1;
    public Contact contact1A;
    public Contact contact1B;
    public Contact contact1C;
    public Contact contact2A;
    public Contact contact3A;
    public Contact contact4A;
    public Benefits_Discovery_Questionnaire__c bdq1;
    public Benefits_Discovery_Questionnaire__c bdq2;
    public Benefits_Discovery_Questionnaire__c bdq3;

    /**
     * @description BenefitsDiscovery_TestEnv constructor.
     */
    public BenefitsDiscovery_TestEnv() {
        createData();
    }

    /**
     * @description createData creates the test data
     */
    public void createData() {

        branch = TestFactoryAccount.createBranch(BRANCH_HANE, 'TEST', null, null);
        owner = TestFactoryUser.makeUser(
            'Test',
            'Owner',
            'Client Benefits',
            'TEST'
        );
        user1 = TestFactoryUser.makeUser(
            'Test',
            'UserOne',
            'BBSI Standard',
            'TEST'
        );
        User sysAdmin = TestFactoryUser.makeUser('SYS', 'ADMIN', 'System Administrator', '910');

        insert new List<User>{ owner, user1, sysAdmin };

        System.runAs(sysAdmin) {
            Id idPermission = TestFactoryPermissionSetAssignment.createPermissionSet(
                'TESTOPPORTUNITYBENEFITS', 
                new List<String>{ 'Opportunity_Edit_Benefit_Opportunities' }
            );
            TestFactoryPermissionSetAssignment.assignPermissionSet(idPermission, new List<Id>{ owner.Id });
        }

        System.runAs(owner) {
            prospect1 = TestFactoryAccount.makeProspect('TESTPROSPECT_1', null, null);
            prospect1.AnnualRevenue = 111111;
            prospect1.NumberOfEmployees = 100;
            prospect1.Active_Employees_Full_Time__c = 10;
            prospect1.Active_Employees_Part_Time__c = 1;
            prospect1.Benefits_Representative__c = user1.Id;
            prospect2 = TestFactoryAccount.makeProspect('TESTPROSPECT_2', null, null);
            prospect2.AnnualRevenue = 222222;
            prospect1.NumberOfEmployees = 200;
            prospect1.Active_Employees_Full_Time__c = 20;
            prospect1.Active_Employees_Part_Time__c = 2;
            prospect3 = TestFactoryAccount.makeProspect('TESTPROSPECT_3', null, null);
            prospect3.AnnualRevenue = 333333;
            prospect1.NumberOfEmployees = 300;
            prospect1.Active_Employees_Full_Time__c = 30;
            prospect1.Active_Employees_Part_Time__c = 3;
            prospect4 = TestFactoryAccount.makeProspect('TESTPROSPECT_4', null, null);
            prospect4.AnnualRevenue = 444444;
            prospect4.NumberOfEmployees = 400;
            prospect4.Active_Employees_Full_Time__c = 40;
            prospect4.Active_Employees_Part_Time__c = 4;
            insert new List<Account>{ prospect1, prospect2, prospect3, prospect4 };

            contact1A = TestFactory.createClientContact(prospect1, 'Contact1A', false);
            contact1B = TestFactory.createClientContact(prospect1, 'Contact1B', false);
            contact1C = TestFactory.createClientContact(prospect1, 'Contact1C', false);
            contact2A = TestFactory.createClientContact(prospect2, 'Contact2A', false);
            contact3A = TestFactory.createClientContact(prospect3, 'Contact3A', false);
            contact4A = TestFactory.createClientContact(prospect3, 'Contact3A', false);
            insert new List<Contact>{ contact1A, contact1B, contact1C, contact2A, contact3A, contact4A };

            Date dateClose = Date.today().addDays(30);

            Id idOppType = RecordTypeService.getId('Opportunity', 'Benefits');
            opp1 = TestFactoryOpportunity.makeClient('TESTPROSPECT_1', prospect1.id, dateClose, 'Proposal');
            opp1.Amount = 10000;
            opp1.RecordTypeId = idOppType;
            opp1.Admin_Factor__c = 1.0;
            opp1.Bucket__c = 3;
            opp2 = TestFactoryOpportunity.makeClient('TESTPROSPECT_2', prospect2.id, dateClose, 'Proposal');
            opp2.Amount = 10000;
            opp2.RecordTypeId = idOppType;
            opp2.Admin_Factor__c = 1.0;
            opp2.Bucket__c = 3;
            opp3 = TestFactoryOpportunity.makeClient('TESTPROSPECT_3', prospect3.id, dateClose, 'Proposal');
            opp3.Amount = 10000;
            opp3.RecordTypeId = idOppType;
            opp3.Admin_Factor__c = 1.0;
            opp3.Bucket__c = 3;
            opp4 = TestFactoryOpportunity.makeClient('TESTPROSPECT_4', prospect3.id, dateClose, 'Proposal');
            opp4.Amount = 10000;
            opp4.RecordTypeId = idOppType;
            opp4.Admin_Factor__c = 1.0;
            opp4.Bucket__c = 3;
            insert new List<Opportunity>{ opp1, opp2, opp3, opp4 };

            bdq1 = TestFactoryBDQuestionnaire.makeBDQuestionnaire(opp1.Id,'Yes','Yes','Dental');
            bdq2 = TestFactoryBDQuestionnaire.makeBDQuestionnaire(opp2.Id,'Yes','Yes','Dental');
            bdq3 = TestFactoryBDQuestionnaire.makeBDQuestionnaire(opp3.Id,'Yes','Yes','Dental');
            insert new List<Benefits_Discovery_Questionnaire__c>{ bdq1, bdq2, bdq3 };
        }

        List<Id> idContacts = new List<Id>{
            contact1A.Id,
            contact1B.Id,
            contact1C.Id,
            contact2A.Id,
            contact3A.Id,
            contact4A.Id
        };

        Map<Id, Contact> mapContacts = new Map<Id, Contact>([SELECT Id, Benefits_Contact__c FROM Contact WHERE Id IN :idContacts]);

        Assert.areEqual(false, mapContacts.get(contact1A.Id).Benefits_Contact__c, 'Is not Benefits Contact');
        Assert.areEqual(false, mapContacts.get(contact1B.Id).Benefits_Contact__c, 'Is not Benefits Contact');
        Assert.areEqual(false, mapContacts.get(contact1C.Id).Benefits_Contact__c, 'Is not Benefits Contact');
        Assert.areEqual(false, mapContacts.get(contact2A.Id).Benefits_Contact__c, 'Is not Benefits Contact');
        Assert.areEqual(false, mapContacts.get(contact3A.Id).Benefits_Contact__c, 'Is not Benefits Contact');
        Assert.areEqual(false, mapContacts.get(contact4A.Id).Benefits_Contact__c, 'Is not Benefits Contact');
        
        OpportunityContactRole role1 = TestFactoryOpportunity.makeContactRole(contact1A.Id,opp1.Id,true,OpportunityContactRole_Service.BENEFITS_CONTACT);
        OpportunityContactRole role2 = TestFactoryOpportunity.makeContactRole(contact1A.Id,opp1.Id,true,OpportunityContactRole_Service.DECISION_MAKER);
        OpportunityContactRole role3 = TestFactoryOpportunity.makeContactRole(contact1B.Id,opp1.Id,false,OpportunityContactRole_Service.BENEFITS_CONTACT);
        OpportunityContactRole role4 = TestFactoryOpportunity.makeContactRole(contact1C.Id,opp1.Id,false,OpportunityContactRole_Service.DECISION_MAKER);
        OpportunityContactRole role5 = TestFactoryOpportunity.makeContactRole(contact2A.Id,opp2.Id,true,OpportunityContactRole_Service.EXECUTIVE_SPONSOR);

        insert new List<OpportunityContactRole>{ role1, role2, role3, role4, role5 };

        mapContacts = new Map<Id, Contact>([SELECT Id, Benefits_Contact__c FROM Contact WHERE Id IN :idContacts]);

        Assert.areEqual(true,  mapContacts.get(contact1A.Id).Benefits_Contact__c, 'Is Benefits Contact');
        Assert.areEqual(true,  mapContacts.get(contact1B.Id).Benefits_Contact__c, 'Is Benefits Contact');
        Assert.areEqual(false, mapContacts.get(contact1C.Id).Benefits_Contact__c, 'Is Benefits Contact');
        Assert.areEqual(false, mapContacts.get(contact2A.Id).Benefits_Contact__c, 'Is not Benefits Contact');
        Assert.areEqual(false, mapContacts.get(contact3A.Id).Benefits_Contact__c, 'Is not Benefits Contact');
        Assert.areEqual(false, mapContacts.get(contact4A.Id).Benefits_Contact__c, 'Is not Benefits Contact');
    }

    /**
     * @description loadData reads the data.
     */
    public void loadData() {
        owner = [SELECT Id, Name FROM User WHERE Name = 'Test Owner' LIMIT 1];
        user1 = [SELECT Id, Name FROM User WHERE Name = 'Test UserOne' LIMIT 1];

        branch = [SELECT Id, Name, OwnerId FROM Account WHERE Name = :BRANCH_HANE LIMIT 1];

        List<Account> prospects = [
            SELECT Id, Name, OwnerId, Benefits_Representative__c
            FROM Account
            WHERE Name LIKE 'TESTPROSPECT_%'
            ORDER BY Name ASC
        ];

        prospect1 = prospects.get(0);
        prospect2 = prospects.get(1);
        prospect3 = prospects.get(2);
        prospect4 = prospects.get(3);

        List<Opportunity> opps = [
            SELECT Id, Name, OwnerId, AccountId
            FROM Opportunity
            WHERE Name LIKE 'TESTPROSPECT_%'
            ORDER BY Name ASC
        ];

        opp1 = opps.get(0);
        opp2 = opps.get(1);
        opp3 = opps.get(2);
        opp4 = opps.get(3);

        List<Contact> contacts = [
            SELECT Id, Name, OwnerId
            FROM Contact
            WHERE LastName LIKE 'Contact_%'
            ORDER BY LastName ASC
        ];

        contact1A = contacts.get(0);
        contact1B = contacts.get(1);
        contact1C = contacts.get(2);
        contact2A = contacts.get(3);
        contact3A = contacts.get(4);
        contact4A = contacts.get(5);

        Set<Id> idOpps = new Set<Id>{ opp1.Id, opp2.Id, opp3.Id };
        List<Benefits_Discovery_Questionnaire__c> bdqs = [
            SELECT Id, Name, OpportunityId__c
            FROM Benefits_Discovery_Questionnaire__c
            WHERE OpportunityId__c IN :idOpps
        ];

        for (Benefits_Discovery_Questionnaire__c bdq : bdqs) {
            if (bdq.OpportunityId__c == opp1.Id) {
                bdq1 = bdq;
            } else if (bdq.OpportunityId__c == opp2.Id) {
                bdq2 = bdq;
            } else if (bdq.OpportunityId__c == opp3.Id) {
                bdq3 = bdq;
            }
        }
    }
}