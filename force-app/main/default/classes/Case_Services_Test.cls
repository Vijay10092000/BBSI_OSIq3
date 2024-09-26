/**
 * @description Case_Services_Test contains test for the Case_Services class.
 */
@SuppressWarnings('PMD.TooManyFields')
@IsTest
public without sharing class Case_Services_Test {
    private static String userLastName1 = 'Case_ServiceTestuser1';
    private static String userLastName2 = 'Case_ServiceTestuser2';
    private static String userEmail1 = 'Test.User1@company.zzz';
    private static String userEmail2 = 'Test.User2@company.zzz';
    private static String baseBranch = '910';
    private static String accountName1 = 'Case_Service TEST BRANCH';
    private static String accountName2 = 'Case_Service TEST CLIENT';
    private static String rtBBSIBranch = 'BBSI Branch';
    private static String rtClient = 'Client';
    private static String rtBBSIEmployee = 'BBSI Employee';
    private static String rtClientContact = 'Client Contact';
    private static String profileBBSIStandard = 'BBSI Standard';
    private static String profileSupportUser = 'Support Users';
    private static String profileSystemAdmin = 'System Administrator';

    private static Account account1;
    private static Account account2;
    private static User userStandard;
    private static User userSystemAdmin;
    private static Contact contact1;
    private static Contact contact2;
    private static Group group1;
    private static GroupMember member1;
    private static QueuesObject q1;
    
    private static Id roleViewerId = CaseTeamMember_Services.getCaseTeamRoleByName('Viewer');
    private static Id roleViewerPlusId = CaseTeamMember_Services.getCaseTeamRoleByName('Viewer & Notifications');

    @TestSetup
    private static void setupTest() {
        account1 = TestFactoryAccount.makeBranch(accountName1, '99999',null,null);
        account2 = TestFactoryAccount.makeClient(accountName2,null,null);
        List<Account> accs = new List<Account>{account1, account2};
        insert accs;
        userStandard = TestFactoryUser.makeUser('',userLastName1, profileBBSIStandard, baseBranch, userEmail1, userEmail1);
        userSystemAdmin = TestFactoryUser.makeUser('',userLastName2, profileSystemAdmin, baseBranch, userEmail2, userEmail2);
        List<User> users = new List<User>{userStandard, userSystemAdmin};
        insert users;
        Test.startTest();
        System.runAs(userSystemAdmin) {
            group1 = TestFactoryGroup.createGroup('QUEUE One', 'Queue', true, 'queueOne@bbsihq.zzz');
            member1 = TestFactoryGroupMember.createGroupMember(userSystemAdmin.Id, group1.Id);
            q1 = TestFactoryQueuesObject.createQueuesObject('Case', group1.id);
        }
        Test.stopTest();
        contact1 = TestFactoryContact.makeContact('firstname', userLastName1, rtBBSIEmployee, account1.id);
        contact1.User_Id__c = userStandard.Id;
        contact2 = TestFactoryContact.makeContact('firstname', userLastName2, rtClientContact, account1.id);
        List<Contact> contacts = new List<Contact>{contact1, contact2};
        insert contacts;        
    }

    private static void setVariables() {
        account1 = [SELECT Id FROM Account WHERE Name = :accountName1];
        account2 = [SELECT Id FROM Account WHERE Name = :accountName2];
        userStandard = [SELECT Id FROM User WHERE Email = :userEmail1];
        userSystemAdmin = [SELECT Id, ProfileId FROM User WHERE Email = :userEmail2];
        group1 = [SELECT Id FROM Group WHERE Name = 'QUEUE One'];
        member1 = [SELECT Id FROM GroupMember WHERE GroupId =: group1.Id];
        q1 = [SELECT Id FROM QueuesObject WHERE QueueId =: group1.Id and SObjectType = 'Case'];
        contact1 = [SELECT Id, User_Id__c FROM Contact WHERE LastName = :userLastName1];
        contact2 = [SELECT Id, User_Id__c FROM Contact WHERE LastName = :userLastName2];

        Assert.areEqual(userStandard.Id, contact1.User_Id__c, 'Contact1 should be related to User1');
    }

    @IsTest static void testCreateCaseTeamMember_NewMember() {
        setVariables();

        Map<Id, Id> mapContactIdToUserId = new Map<Id, Id>();
        mapContactIdToUserId.put(contact1.Id, contact1.User_Id__c);

		Case case1 = TestFactoryCase.createCase('Test Case', 'Test Description', contact1.Id, account1.id,account2.id,'Client/Referral Partner',null);
        CaseTeamMember member = CaseTeamMember_Services.createMember(case1.Id, userSystemAdmin.Id, 'Viewer');

        Map<String, CaseTeamMember> mapExistingCaseTeamMembers = new Map<String, CaseTeamMember>();       

        CaseTeamMember teamMember = Case_Services.createCaseTeamMember(case1, mapExistingCaseTeamMembers, mapContactIdToUserId);   

        Assert.areEqual(case1.Id, teamMember.ParentId, 'Team member should be on the created case');
        Assert.areEqual(userStandard.Id, teamMember.MemberId, 'Team member should be of the given user');
        Assert.areEqual(roleViewerPlusId, teamMember.TeamRoleId, 'Role should be Viewer & Notifications');
    }

    @IsTest static void testCreateCaseTeamMember_BadParam() {
        CaseTeamMember ctm = Case_Services.createCaseTeamMember(null, null, null);
        Assert.areEqual(null, ctm.MemberId, 'Member Id should not have been set');
    }

    @IsTest static void testCreateCaseTeamMember_UpdateMember() {
        setVariables();

        Map<Id, Id> mapContactIdToUserId = new Map<Id, Id>();
        mapContactIdToUserId.put(contact1.Id, contact1.User_Id__c);

		Case case1 = TestFactoryCase.createCase('Test', 'Test Description', contact1.Id,account1.Id,account2.Id, 'Client/Referral Partner', null);  
        CaseTeamMember member = CaseTeamMember_Services.createMember(case1.Id, userSystemAdmin.Id, 'Viewer');

        Map<String, CaseTeamMember> mapExistingCaseTeamMembers = new Map<String, CaseTeamMember>();
        mapExistingCaseTeamMembers.put( String.valueOf(case1.Id) + String.valueOf(member.Id), member);   

        CaseTeamMember teamMember = Case_Services.createCaseTeamMember(case1, mapExistingCaseTeamMembers, mapContactIdToUserId);   

        Assert.areEqual(case1.Id, teamMember.ParentId, 'Team member should be on the created case');
        Assert.areEqual(userStandard.Id, teamMember.MemberId, 'Team member should be of the given user');
        Assert.areEqual(roleViewerPlusId, teamMember.TeamRoleId, 'Role should be Viewer & Notifications');
    }

    @IsTest static void testAddUserCreatorToCaseTeam() {
        setVariables();

        Test.startTest();       
		Case case1 = TestFactoryCase.makeCase('Test', 'Test Description', contact1.Id,account1.Id,account2.Id, 'Client/Referral Partner', null);
        System.runAs(userSystemAdmin) {
            insert case1;
        }
        Test.stopTest();

        Id roleViewerPlusId = CaseTeamMember_Services.getCaseTeamRoleByName('Viewer & Notifications');
        Map<Id, Set<CaseTeamMember>> mapCaseIdToMembers = CaseTeamMember_Services.getCaseTeamMembersByCase(new Set<Id>{ case1.Id });

        CaseTeamMember foundCTM = null;
        for (CaseTeamMember ctm : mapCaseIdToMembers.get(case1.Id)) {
            if (ctm.MemberId == userSystemAdmin.Id) {
                foundCTM = ctm;
                break;
            }
        }

        Assert.areEqual(true, foundCTM != null, 'A CaseTeamMember should have been created');
        Assert.areEqual(userSystemAdmin.Id, foundCTM.MemberId, 'The CaseTeamMember should be of the created user');
        Assert.areEqual(roleViewerPlusId, foundCTM.TeamRoleId, 'Role should be Viewer & Notifications');
    }

    @IsTest static void testAddCaseTeamAsSubscribers() {
        setVariables();

        Map<Id, Id> mapContactIdToUserId = new Map<Id, Id>();
        mapContactIdToUserId.put(contact1.Id, contact1.User_Id__c);

        Test.startTest();
		Case case1 = TestFactoryCase.createCase('Test Case', 'Test Description', contact1.Id,account1.Id,account2.Id, 'Client/Referral Partner', null);
        Test.stopTest();

        case1 = [SELECT Id, OwnerId FROM Case WHERE Id = :case1.Id LIMIT 1];
        Assert.areEqual(true, String.valueOf(case1.OwnerId).startsWith('00G'), 'Case should be owned by a Queue (Group).');

        Map<Id, Set<EntitySubscription>> subscribers = EntitySubscription_Service.getSubscribers(new Set<Id>{ case1.Id });
        Assert.areEqual(false, subscribers.isEmpty(), 'Case subscribers should have been added.');
        Assert.areEqual(true, subscribers.containsKey(case1.Id), 'Case subscribers for the case should have been added.');

        List<Id> caseIds = new List<Id>{ case1.Id };
        List<CaseTeamMember> ctms = [SELECT Id, ParentId, MemberId
                                     FROM CaseTeamMember
                                     WHERE ParentId IN :caseIds];
        Boolean found;
        for (EntitySubscription es : subscribers.get(case1.Id)) {
            found = false;
            for (CaseTeamMember ctm : ctms) {
                if (es.SubscriberId == ctm.MemberId) {
                    found = true;
                    break;
                }
            }
            Assert.areEqual(true, found, 'Not all Case Team Members were added as subscribors');
        }
    }

    @IsTest static void testInsertSystemGeneratedCase() {
        setVariables();

        System.runAs(userStandard) {
            Id idCase = Case_Services.insertSystemGeneratedCase('Subject', 'Body', account1.Id);
            Case c = [
                SELECT Id, AccountId, Subject, Description, Status, Priority, Type, Origin, ContactId, Skip_Automation__c
                FROM Case
                WHERE Id = :idCase
            ];
            
            Assert.areEqual(account1.Id, c.AccountId);
            Assert.areEqual('Subject', c.Subject);
            Assert.areEqual('Body', c.Description);
            Assert.areEqual('New', c.Status);
            Assert.areEqual('High', c.Priority);
            Assert.areEqual('Issue', c.Type);
            Assert.areEqual('System Generated', c.Origin);
            Assert.areNotEqual(null, c.ContactId);
        }
    }

    @IsTest static void testCreateSystemGeneratedCase() {
        setVariables();

        System.runAs(userStandard) {
            Case c = Case_Services.createSystemGeneratedCase('Subject', 'Body', account1.Id);
            
            Assert.areEqual(account1.Id, c.AccountId);
            Assert.areEqual('Subject', c.Subject);
            Assert.areEqual('Body', c.Description);
            Assert.areEqual('New', c.Status);
            Assert.areEqual('High', c.Priority);
            Assert.areEqual('Issue', c.Type);
            Assert.areEqual('System Generated', c.Origin);
            Assert.areEqual(RecordTypeService.getId('Case', 'System Generated'), c.RecordTypeId);
            Assert.areNotEqual(null, c.ContactId);
            Assert.areEqual(true, c.Skip_Automation__c);
        }
    }

    @IsTest static void testAddOwnerToCaseTeam() {
        setVariables();

        Test.startTest();
        Case case1 = TestFactoryCase.makeCase('Test Case', 'Test Description', contact1.Id,account1.Id,account2.Id, 'Client/Referral Partner', null);
        System.runAs(userSystemAdmin) {
            insert case1;
        }

        case1.OwnerId = contact1.Id;

        Test.stopTest();

        Id roleViewerPlusId = CaseTeamMember_Services.getCaseTeamRoleByName('Viewer & Notifications');

        Map<Id, Set<CaseTeamMember>> mapCaseIdToMembers = CaseTeamMember_Services.getCaseTeamMembersByCase(new Set<Id>{ case1.Id });

        CaseTeamMember foundCTM = null;
        for (CaseTeamMember ctm : mapCaseIdToMembers.get(case1.Id)) {
            if (ctm.MemberId == userStandard.Id) {
                foundCTM = ctm;
                break;
            }
        }

        Assert.areEqual(true, foundCTM != null, 'A CaseTeamMember should have been created');
        Assert.areEqual(userStandard.Id, foundCTM.MemberId, 'The CaseTeamMember should be of the created user');
        Assert.areEqual(roleViewerPlusId, foundCTM.TeamRoleId, 'Role should be Viewer & Notifications');
    }

    /**
     * @description test_blockOwnerAssignment_NonSysAdmin has a non-System Admin try to assign a case
     * to as System Admin.  This should be blocked.
     */
    @IsTest static void test_blockOwnerAssignment_NonSysAdmin() {
        setVariables();
		Case case1 = TestFactoryCase.createCase('Test Case', 'Test Description', contact1.Id,account1.Id,account2.Id, 'Client/Referral Partner', null);
        Test.startTest();

        System.runAs(userStandard) {
            case1.OwnerId = userSystemAdmin.Id;

            try {
                update case1;
               Assert.isTrue(false, 'An Exception should have been thrown');
            }
            catch (Exception e) {
                System.debug(LoggingLevel.INFO, 'Exception: ' + e);
                Assert.isTrue(true, 'An Exception has been thrown');
            }
        }
    }

    /**
     * @description test_blockOwnerAssignment_SysAdmin has a System Admin try to assign a case
     * to as System Admin.  This should be allowed.
     */
    @IsTest static void test_blockOwnerAssignment_SysAdmin() {
        setVariables();
		Case case1 = TestFactoryCase.createCase('Test Case', 'Test Description', contact1.Id,account1.Id,account2.Id, 'Client/Referral Partner', null);
        Test.startTest();

        System.runAs(userSystemAdmin) {
            case1.OwnerId = userSystemAdmin.Id;
            try {
                update case1;
                Assert.isTrue(true, 'An Exception should NOT be thrown.');
            }
            catch (Exception e) {
                System.debug(LoggingLevel.INFO, 'Exception: ' + e);
                Assert.isTrue(false, 'An Exception was thrown.');
            }
        }
    }

    /**
     * @description test_ChangeCaseOwnerForVendor_SysAdmin has a System Admin try to assign a case
     * to as System Admin.  This should be allowed.
     */
    @IsTest static void test_ChangeCaseOwnerForVendor_SysAdmin() {        
        setVariables();   
        COntact bbsiContact = TestFactoryContact.makeContact('firstname1', userLastName1, rtBBSIEmployee, account1.id);
        bbsiContact.User_Id__c = userStandard.Id;     
        insert bbsiContact;
        Test.startTest();
		Case case1 = TestFactoryCase.createCase('Test Case', 'Test Description', contact1.Id,account1.Id,account2.Id, 'Client_Referral_Partner', null);
        System.runAs(userSystemAdmin) {
            case1.ContactId = bbsiContact.Id;
            update case1;
            case1.OwnerId = group1.Id;
            case1.Origin = 'Onsite';
            case1.Skip_Automation__c = false;
            case1.ContactId = contact1.Id;
            case1.RecordTypeId = RecordTypeService.getId('Case', 'Client_Referral_Partner');
            try {
                Case_Services.assignEntitlementInsert(new List<Case>{case1});
                Case_Services.addCreatedByAsContact(new List<Case>{case1});
                update case1;
                case1.ContactId = contact2.Id;
                update case1;
                Assert.isTrue(false, 'An Exception should NOT be thrown.');
            }
            catch (Exception e) {
                System.debug(LoggingLevel.INFO, 'Exception: ' + e);
                Assert.isTrue(true, 'An Exception was thrown.');
            }
        }
    }
}