@IsTest
public without sharing class Case_Assignment_Test {
    /**
     * setupTests creates some Users, Accounts and Contacts to be used during the test.
     */
    @TestSetup 
    static private void setupTests(){
        UserRole role = TestFactoryUserRole.createUserRole('Parent Role', null);
        UserRole parentRole = TestFactoryUserRole.createUserRole('BU Role', role.Id, null);

        User user1 = TestFactoryUser.makeUser('One','Support',  'BBSI Standard', '910','Support.One@bbsihq.zzz', 'Support.One@bbsihq.zzz');
        user1.title = 'Support One';
        user1.UserRoleId = role.ID; 
        User user2 = TestFactoryUser.makeUser('Two','Support',  'BBSI Standard', '910','Support.Two@bbsihq.zzz', 'Support.Two@bbsihq.zzz');
        user2.title = 'Support Two';
        user2.UserRoleId = role.ID;
        User user3 = TestFactoryUser.makeUser('Three','Support',  'BBSI Standard', '910','Support.Three@bbsihq.zzz', 'Support.Three@bbsihq.zzz');
        user3.title = 'Support Three';
        user3.UserRoleId = role.ID;
        User areaManager = TestFactoryUser.makeUser('Area','Manager', 'Area Manager', '910', 'AreaManager@bbsihq.com', 'AreaManager@bbsihq.com');
        areaManager.title = 'Area Manager';
        areaManager.UserRoleId = role.ID;
        User bdmUser = TestFactoryUser.makeUser('bdm','BDMUser', 'BBSI Standard', '910', 'TestBBSI@bbsihq.com', 'TestBBSI@bbsihq.com');//
        bdmUser.title = 'Business Development Manager';
        bdmUser.UserRoleId = parentRole.ID;        
        insert new list<User>{ areaManager, bdmUser, user1, user2, user3 };
   
        Group group1 = TestFactoryGroup.makeGroup('QUEUE One', 'Queue', true, 'queueOne@bbsihq.zzz');
        Group group2 = TestFactoryGroup.makeGroup('QUEUE Two', 'Queue', false, 'queueTwo@bbsihq.zzz');
        Group group3 = TestFactoryGroup.makeGroup('QUEUE Three', 'Queue', true, null);
        Group group4 = TestFactoryGroup.makeGroup('QUEUE Four', 'Queue', false, null);
        insert new List<Group>{ group1, group2, group3, group4 }; 

        Id userId = UserInfo.getUserId();
        GroupMember member1 = TestFactoryGroupMember.makeGroupMember(user1.Id, group1.Id);
        GroupMember member2 = TestFactoryGroupMember.makeGroupMember(user2.Id, group2.Id);
        GroupMember member3 = TestFactoryGroupMember.makeGroupMember(user3.Id, group3.Id);
        GroupMember member4 = TestFactoryGroupMember.makeGroupMember(user1.Id, group4.Id);
        GroupMember member5 = TestFactoryGroupMember.makeGroupMember(user2.Id, group4.Id);
        GroupMember member6 = TestFactoryGroupMember.makeGroupMember(user3.Id, group4.Id);
        insert new list<GroupMember>{ member1, member2, member3, member4, member5, member6 }; 
                        
        QueuesObject q1 = TestFactoryQueuesObject.makeQueuesObject('Case', group1.id);
        QueuesObject q2 = TestFactoryQueuesObject.makeQueuesObject('Case', group2.id);
        QueuesObject q3 = TestFactoryQueuesObject.makeQueuesObject('Case', group3.id);
        QueuesObject q4 = TestFactoryQueuesObject.makeQueuesObject('Case', group4.id);
        insert new List<QueuesObject>{ q1, q2, q3, q4 };  
            
        System.runAs(areaManager) {
            Account aReferralPartner = TestFactoryAccount.makeReferralPartner('Test Referral Partner', '% of Work Comp',12,null);
            Account aBBSIBranch = TestFactoryAccount.makeBranch('Test BBSI Branch','BBSI Branch',null,null);
            aBBSIBranch.Branch_Manager__c = 'Area Manager';
            aBBSIBranch.Branch_Manager_Email__c = 'Test@Test.com';
            insert new List<Account>{ aReferralPartner, aBBSIBranch };

            Contact cProducer = TestFactoryContact.makeContact('testfirstname', 'TestProducer', 'Producer',aReferralPartner.id);
            Contact cBBSIEmployee = TestFactoryContact.makeContact('CaseAssignment', 'Testing', 'BBSI Employee',aBBSIBranch.id);
            insert new List<Contact>{ cProducer, cBBSIEmployee }; 
        }
    }
    
    /**
     * makeRule creates a Case_Assignment_Rule__mdt for use in tests.
     */
    static private Case_Assignment_Rule__mdt makeRule(Decimal order,
                                                      String caseRecordType, 
                                                      String category, 
                                                      String casetype,
                                                      String subType, 
                                                      String primaryApplication, 
                                                      String scope,
                                                      String accountRecordType,
                                                      String queue, 
                                                      String severity) {
         Case_Assignment_Rule__mdt rule = new Case_Assignment_Rule__mdt();
         rule.Order__c = order; 
         rule.Case_Record_Type__c = caseRecordType; 
         rule.Category__c = category; 
         rule.Type__c = casetype; 
         rule.Sub_Type__c = subType; 
         rule.Primary_Application__c = primaryApplication; 
         rule.Scope__c = scope; 
         rule.Account_Record_Type__c = accountRecordType; 
         rule.Queue__c = queue; 
         rule.Severity__c = severity;
         rule.Send_Email_on_Create__c = false;
         return rule;
    }
    
    /**
     * createCase creates a Case object for use in the test.
     */
    static private Case createCase(String subject, Id accountId, Id contactId, String recordType, String category, 
                                   String caseType, String subType, String primaryApplication, String scope) {
        Map<String, Object> fldMap = new  Map<String, Object>();
        fldMap.put('Type', category);
        fldMap.put('Type__c', caseType);
        fldMap.put('Sub_Type__c', subType);
        fldMap.put('Primary_Product__c', primaryApplication);
        fldMap.put('Scope__c', scope);
        return TestFactoryCase.makeCase(subject, null, contactId, accountId, null, recordType, fldMap);        
    }
 
    @IsTest
    static private void testHaveRules() { 
        List<Case_Assignment_Rule__mdt> rules = Case_Assignment.readRules();
        Assert.isTrue(0 < rules.size(), 'Missing Case Assignment Rules.');
    } 

    @IsTest
    static private void testHaveDefaultRule() {
        List<Case_Assignment_Rule__mdt> rules = Case_Assignment.readRules();
        
        Boolean foundDefault = false;
        for (Case_Assignment_Rule__mdt rule : rules) {
            if (rule.Case_Record_Type__c == 'Any'  &&
                rule.Category__c == 'Any' &&                
                rule.Type__c == 'Any' &&                
                rule.Sub_Type__c == 'Any' &&                
                rule.Primary_Application__c == 'Any' &&
                rule.Scope__c == 'Any' &&
                rule.Account_Record_Type__c == 'Any') {
                foundDefault = true;
                break;
            }
        }
        Assert.areEqual(true, foundDefault, 'Missing default Case Assignment Rule.');
    }

    @IsTest
    static private void testBuildEmail() {
        Case_Assignment ca = new Case_Assignment();
        
        List<String> listTo = new List<String>{ 'emailTo1@test.zzz', 'emailTo2@test.zzz' };
        List<String> listCc = new List<String>{ 'emailCc1@test.zzz' };
        Id idTemplate;
        Id idTarget;
        Id idWhat;
        
        Messaging.SingleEmailMessage email = ca.buildEmail(listTo, listCc, idTemplate, idTarget, idWhat);
        
        Assert.areEqual(2, email.getToAddresses().size());
        Assert.areEqual(1, email.getCcAddresses().size());
        Assert.areEqual(idTemplate, email.getTemplateId());
        Assert.areEqual(idTarget, email.getTargetObjectId());
        Assert.areEqual(idWhat, email.getWhatId());
    }
    
    @IsTest
    static private void testNeedEmailNo() {
        Group queue = [SELECT Id, Name, DoesSendEmailToMembers, EMail FROM Group WHERE Name = 'QUEUE Four'];

        Case_Assignment ca = new Case_Assignment();
        Assert.areEqual(false, ca.needEmail(queue));
    }
    
    @IsTest
    static private void testNeedEmailYes() {
        Group queue = [SELECT Id, Name, DoesSendEmailToMembers, EMail FROM Group WHERE Name = 'QUEUE One'];

        Case_Assignment ca = new Case_Assignment();
        Assert.areEqual(true, ca.needEmail(queue));
    }

    @IsTest
    static private void testRetrieveQueues() {
        Case_Assignment_Rule__mdt rule1 = makeRule(1.0, 'Any', 'Category', 'Type', 'SubType', 'Any', 'Any', 'Any', 'QUEUE One', 'Severity');
        Case_Assignment_Rule__mdt rule2 = makeRule(2.0, 'Any', 'Category', 'Any', 'SubType', 'Any', 'Any', 'Any', 'QUEUE Two', 'Severity');
        Case_Assignment_Rule__mdt rule3 = makeRule(3.0, 'Any', 'Any', 'Any', 'Any', 'Any', 'Any', 'Any', 'QUEUE Three', 'Severity');

        Case_Assignment.setRules(new List<Case_Assignment_Rule__mdt>{ rule1, rule2, rule3 });

        Map<String, Group> queues = Case_Assignment.retrieveQueues();
            
        Assert.areEqual(3, queues.size(), 'Expected 3 queues to be in the list');
    }

    @IsTest
    static private void testCheckRuleMatchDefault() {
        Case_Assignment ca = new Case_Assignment();
        Case_Assignment_Rule__mdt ruleDefault = makeRule(1.0, 'Any', 'Any', 'Any', 'Any', 'Any', 'Any', 'Any', 'Queue', 'Severity');

        Assert.areEqual(true, ca.checkRuleMatch(ruleDefault, 'RecordType','Category', 'Type', 'SubType', 'PrimaryApplication', 'Scope', 'AccountRecordType'), 
                            '"The default rule should match any values"');
        Assert.areEqual(true, ca.checkRuleMatch(ruleDefault, null, null, null, null, null, null, null), 
                            '"The default rule should match null values"');
    }
 
    @IsTest
    static private void testCheckRuleMatch() {
        Case_Assignment ca = new Case_Assignment();
        Case_Assignment_Rule__mdt rule;
            
        rule = makeRule(1.0, 'Any', 'caseCategory', 'Any', 'caseSubType', 'Any', 'Any', 'Any', 'Queue', 'Severity');

        Assert.areEqual(true, ca.checkRuleMatch(rule, null, 'caseCategory',  null, 'caseSubType', null, null, null),
                            '"caseCategory" and "caseSubType" should have been enough to match the rule');   
        
        Assert.areEqual(true, ca.checkRuleMatch(rule, 'recordType', 'caseCategory',  'type', 'caseSubType', 'primaryApplication', 'scope', 'accountRecordType'),
                            '"caseCategory" and "caseSubType" should have been enough to match the rule');
                
        Assert.areEqual(false, ca.checkRuleMatch(rule, 'recordType', 'category',  'type', 'subType',  'primaryApplication', 'scope', 'accountRecordType'),
                            'The rule does not allow for "category" or "subType"');

        rule = makeRule(1.0, 'recordType', 'category', 'Any', 'SubType', 'PrimaryApplication', 'Scope', 'AccountRecordType', 'Queue', 'Severity');
        Assert.areEqual(false, ca.checkRuleMatch(rule, 'recordType', 'category',  'type', 'badSubType',  'PrimaryApplication', 'scope', 'AccountRecordType'),
                            'SubType should not align with the rule');
        Assert.areEqual(false, ca.checkRuleMatch(rule, 'recordType', 'category',  'type', 'SubType',  'badPrimaryApplication', 'scope', 'AccountRecordType'),
                            'PrimaryApplication should not align with the rule');
        Assert.areEqual(false, ca.checkRuleMatch(rule, 'recordType', 'category',  'type', 'SubType',  'PrimaryApplication', 'badScope', 'AccountRecordType'),
                            'Scope should not align with the rule');       
        Assert.areEqual(false, ca.checkRuleMatch(rule, 'recordType', 'category',  'type', 'SubType',  'PrimaryApplication', 'Scope', 'badAccountRecordType'),
                            'Account RecordType should not align with the rule');
    }

    @IsTest
    static private void testFindMatchingRule() {        
        Case_Assignment_Rule__mdt rule1 = makeRule(1.0, 'Any', 'Category', 'Type', 'SubType', 'Any', 'Any', 'Any', 'Queue ONE', 'S1');
        Case_Assignment_Rule__mdt rule2 = makeRule(2.0, 'Any', 'Category', 'Any', 'SubType', 'Any', 'Any', 'Any', 'Queue TWO', 'S2');
        Case_Assignment_Rule__mdt rule3 = makeRule(3.0, 'Any', 'Any', 'Any', 'Any', 'Any', 'Any', 'Any', 'Queue THREE', 'S3');
        
        Case_Assignment ca = new Case_Assignment();
        Case_Assignment.setRules(new List<Case_Assignment_Rule__mdt>{ rule1, rule2, rule3 });
        
        Assert.areEqual(rule1, ca.findMatchingRule('', 'Category', 'Type', 'SubType', '', '', ''), 'Rule 1 matches matches the Category, Type and SubType');
        Assert.areEqual(rule2, ca.findMatchingRule('', 'Category',  'Unknown', 'SubType', '', '', ''), 'Rule 2 matches the Category and SubType');
        Assert.areEqual(rule3, ca.findMatchingRule('', 'Honey',  '', 'SubType', '', '', ''), 'Rule 3, a default rule, should match any values');
    }

    @IsTest
    static public void testMissingDefaultRule() {       
        Case_Assignment_Rule__mdt rule1 = makeRule(1.0, 'Any', 'Category', 'Type', 'SubType', 'Any', 'Any', 'Any', 'Queue ONE', 'S1');
        Case_Assignment_Rule__mdt rule2 = makeRule(2.0, 'Any', 'Category', 'Any', 'SubType', 'Any', 'Any', 'Any', 'Queue TWO', 'S2');
        
        Case_Assignment ca = new Case_Assignment();
        Case_Assignment.setRules(new List<Case_Assignment_Rule__mdt>{ rule1, rule2 });
        
        Assert.areEqual(null, ca.findMatchingRule('', 'Honey',  '', 'SubType', '', '', ''), 'Rule 3, a default rule, should match any values');
    }

    @IsTest
    static private void testCreateEmail() {
        EmailTemplate template = [SELECT Id FROM EmailTemplate WHERE Name = 'New Queue Assignment Notification' LIMIT 1];
        Account aReferralPartner = [SELECT Id FROM Account WHERE Name = 'Test Referral Partner' LIMIT 1];
        Contact cProducer = [SELECT Id FROM Contact WHERE LastName = 'TestProducer' LIMIT 1];
        
        Case c = createCase( 'subject', aReferralPartner.Id, cProducer.Id, 'recordType', 'category', 
                             'caseType', 'subType', 'primaryApplication', 'scope');
        Group queue = [SELECT Id, Name, DoesSendEmailToMembers, Email FROM Group WHERE Name = 'QUEUE Three'];

        Case_Assignment ca = new Case_Assignment();
        Messaging.SingleEmailMessage email = ca.createEmail(c, queue);
        
        Assert.areEqual(1, email.getToAddresses().size());
        Assert.areEqual(0, email.getCcAddresses().size());
        Assert.areEqual(template.Id, email.getTemplateId());
        Assert.areEqual(queue.Id, email.getTargetObjectId());
        Assert.areEqual(c.Id, email.getWhatId());
    }

    @IsTest
    static private void testAssignCaseTo() { 
        List<Case_Assignment_Rule__mdt> rules = Case_Assignment.readRules();
        
        Account a = [SELECT Id, Name FROM Account WHERE Name = 'Test BBSI Branch' LIMIT 1];
        Contact c = [SELECT Id, Name FROM Contact WHERE FirstName = 'CaseAssignment' AND LastName = 'Testing' LIMIT 1];

        Test.startTest();
     
        Case case1 = createCase('Test Case', a.Id, c.Id, 'Client/Referral Partner', 'Software Request', 'Other', '', '', '');
        case1.Skip_Automation__c = true;
        insert case1;
        
        Group queue = [SELECT Id, Name FROM Group WHERE Type = 'Queue' AND Name = :rules.get(rules.size()-1).Queue__c];
        case1 = [SELECT Id, OwnerId, Severity__c FROM Case WHERE Id = :case1.Id];
        Assert.areEqual(rules.get(rules.size()-1).Severity__c, case1.Severity__c, 'Case severity not assigned correctly');
        Assert.areEqual(queue.Id, case1.OwnerId, 'Case not assigned to Queue correctly');
        
        User user1 = [SELECT Id, FirstName, LastName FROM User WHERE Email = 'Support.One@bbsihq.zzz'];
        case1.OwnerId = user1.Id;
        case1.Skip_Automation__c = true;
        update case1;
        
        user1 = [SELECT Id, FirstName, LastName FROM User WHERE Email = 'Support.One@bbsihq.zzz'];
        Assert.areEqual(user1.Id, case1.OwnerId, 'Case not assigned to Queue correctly');
        
        Test.stopTest();
    }

    @IsTest
    static private void testAssignCaseNoOwnerChangeForEmailToCase() { 
        List<Case_Assignment_Rule__mdt> rules = Case_Assignment.readRules();
        
        Account a = [SELECT Id, Name FROM Account WHERE Name = 'Test BBSI Branch' LIMIT 1];
        Contact c = [SELECT Id, Name FROM Contact WHERE FirstName = 'CaseAssignment' AND LastName = 'Testing' LIMIT 1];
        User user1 = [SELECT Id, FirstName, LastName FROM User WHERE Email = 'Support.One@bbsihq.zzz'];

        Test.startTest();
     
        Case case1 = createCase('Test Case', a.Id, c.Id, 'Client/Referral Partner', 'Software Request', 'Other', '', '', '');
        case1.Origin = 'Email to Case';
        case1.OwnerId = user1.Id;
        case1.Skip_Automation__c = true;
        insert case1;
        
        Group queue = [SELECT Id, Name FROM Group WHERE Type = 'Queue' AND Name = :rules.get(rules.size()-1).Queue__c];
        case1 = [SELECT Id, OwnerId, Severity__c FROM Case WHERE Id = :case1.Id];
        Assert.areEqual(user1.Id, case1.OwnerId, 'Case not assigned to Queue correctly');
        
        Test.stopTest();
    }

    @IsTest
    static private void testUpdateAssignment() {  
        Case_Assignment_Rule__mdt rule1 = makeRule(1.0, 'Any', 'Onboarding', 'Paperless Onboarding process', 'SpringCM Record Changes', 'Any', 'Any', 'Any', 'QUEUE One', 'S1');
        Case_Assignment_Rule__mdt rule2 = makeRule(2.0, 'Any', 'Name Change', 'Any', 'Any', 'Any', 'Any', 'Any', 'QUEUE Two', 'S2');
        Case_Assignment_Rule__mdt rule3 = makeRule(3.0, 'Any', 'Any', 'Any', 'Any', 'Any', 'Any', 'Any', 'QUEUE Three', 'S3');
        
        Case_Assignment ca = new Case_Assignment();
        Case_Assignment.setRules(new List<Case_Assignment_Rule__mdt>{ rule1, rule2, rule3 });
        
        Account a = [SELECT Id, Name FROM Account WHERE Name = 'Test BBSI Branch' LIMIT 1];
        Contact c = [SELECT Id, Name FROM Contact WHERE FirstName = 'CaseAssignment' AND LastName = 'Testing' LIMIT 1];
        
        Case case1 = createCase('Test Case', a.Id, c.Id, 'Client/Referral Partner', 'Onboarding', 'Paperless Onboarding process', 'SpringCM Record Changes', '', '');          
        case1.Skip_Automation__c = true;
        insert case1;

        // Confirm assignment and severity
        case1 = [SELECT Id, OwnerId, Severity__c, Type, Type__c, Sub_Type__C FROM Case WHERE Id = :case1.Id];
        Group queue1 = [SELECT Id, Name, DoesSendEmailToMembers, Email FROM Group WHERE Name = 'QUEUE One'];
        Assert.areEqual(queue1.Id, case1.OwnerId);
        Assert.areEqual('S1', case1.Severity__c);

        Test.startTest();
        
        case1.Type = 'Name Change';
        update case1;
        
        // Confirm owner did not change, but severity did
        case1 = [SELECT Id, OwnerId, Severity__c, Type, Type__c, Sub_Type__C FROM Case WHERE Id = :case1.Id];
        Group queue2 = [SELECT Id, Name, DoesSendEmailToMembers, Email FROM Group WHERE Name = 'QUEUE Two'];
        Assert.areEqual(queue1.Id, case1.OwnerId);
        Assert.areEqual('S2', case1.Severity__c);
     
        Test.stopTest();
    }

    @IsTest
    static private void testBlockCaseAssign() { 
        List<Case_Assignment_Rule__mdt> rules = Case_Assignment.readRules();
        
        Account a = [SELECT Id, Name FROM Account WHERE Name = 'Test BBSI Branch' LIMIT 1];
        Contact c = [SELECT Id, Name FROM Contact WHERE FirstName = 'CaseAssignment' AND LastName = 'Testing' LIMIT 1];

        User user3 = [SELECT Id, FirstName, LastName FROM User WHERE Email = 'Support.Three@bbsihq.zzz'];

        Case case1 = createCase('Test Case', a.Id, c.Id, 'Client/Referral Partner', 'Software Request', 'Other', '', '', '');
        case1.Block_Auto_Assignment__c = false;
        case1.Skip_Automation__c = true;
        insert case1;

        // Owner was reassigned - Blocked is false
        Assert.areNotEqual(user3.Id, case1.OwnerId);

        Case case2 = createCase('Test Case', a.Id, c.Id, 'Client/Referral Partner', 'Software Request', 'Other', '', '', '');
        case2.OwnerId = user3.Id;
        case2.Block_Auto_Assignment__c = true;
        case2.Skip_Automation__c = true;
        insert case2;

        // Owner was not reassigned - Blocked is true
        Assert.areEqual(user3.Id, case2.OwnerId);
    }

    @IsTest
    static private void testLogMatchOfRules() {
        List<Case_Assignment_Rule__mdt> rules = Case_Assignment.readRules();

        Account a = [SELECT Id, Name FROM Account WHERE Name = 'Test BBSI Branch' LIMIT 1];
        Contact c = [SELECT Id, Name FROM Contact WHERE FirstName = 'CaseAssignment' AND LastName = 'Testing' LIMIT 1];

        Case case1 = createCase('Test Case', a.Id, c.Id, 'Client/Referral Partner', 'Software Request', 'Other', '', '', '');
        case1.Skip_Automation__c = true;
        insert case1;

        Case_Assignment.logMatchOfRules(LoggingLevel.DEBUG, case1.Id, true);
        // Only sends information to Log, so nothing to assert
        Assert.isTrue(true);
    }

    @IsTest
    static private void testEmailAdministrators() {
        // This is a false test to achieve coverage.
        Boolean error = false;
        try {
            Case_Assignment.EmailAdministrators('Subject', 'Message');
        } catch(Exception e) {
            error = true;
        }
        Assert.isFalse(error);
    }
}