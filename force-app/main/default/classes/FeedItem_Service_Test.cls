/**
 *  FeedItem_Service_Test
 */
@isTest
public class FeedItem_Service_Test {
    
    /**
     * postChatter sends a simple post to the given record welcoming each of the mentionIds.
     * 
     * @param recordId - The record the post is related to
     * @param mentionIds - Ids which should be mentioned in the post
     * @see https://developer.salesforce.com/docs/atlas.en-us.apexcode.meta/apexcode/apex_ConnectAPI_ChatterFeeds_static_methods.htm#apex_ConnectAPI_ChatterFeeds_postFeedElement_2
     */
    static private void postChatter(Id recordId, List<Id> mentionIds) {
        ConnectApi.FeedType feedType = ConnectApi.FeedType.UserProfile;
        ConnectApi.FeedItemInput feedItemInput = new ConnectApi.FeedItemInput();
        ConnectApi.MessageBodyInput messageInput = new ConnectApi.MessageBodyInput();
        ConnectApi.TextSegmentInput textSegment;
        ConnectApi.MentionSegmentInput mentionSegment;
        
        messageInput.messageSegments = new List<ConnectApi.MessageSegmentInput>();
        
        if (mentionIds.isEmpty() ) { 
            textSegment = new ConnectApi.TextSegmentInput();
            textSegment.text = 'No one to welcome.  :(';
            messageInput.messageSegments.add(textSegment);
        }
        else { 
            textSegment = new ConnectApi.TextSegmentInput();
            textSegment.text = 'Mentions: <br> ';
            messageInput.messageSegments.add(textSegment);
            
            for (Id id : mentionIds) {
                mentionSegment = new ConnectApi.MentionSegmentInput();      
                mentionSegment.id = id;
                messageInput.messageSegments.add(mentionSegment);
                
                textSegment = new ConnectApi.TextSegmentInput();
                textSegment.text = ' <br> ';
                messageInput.messageSegments.add(textSegment);
            }
        }
        
        feedItemInput.body = messageInput;
        feedItemInput.feedElementType = ConnectApi.FeedElementType.FeedItem;
        feedItemInput.subjectId = recordId;
        
        ConnectApi.FeedElement feedElement = ConnectApi.ChatterFeeds.postFeedElement(Network.getNetworkId(), feedItemInput);
    }

    @isTest(SeeAllData=true)
    static void test_caseFeedItemWithNoMention() {            
        Account a = TestFactoryAccount.createBranch('--Test Account--');
        Contact c = TestFactoryContact.createEmployee(null, null, 'One TestContact', a.Id);
        Case case1 = TestFactoryCase.createCase('--First Test Case', null, c.Id, a.Id, null, null, new  Map<String, Object> {'Type' => 'Feature'});

        Test.startTest();        
        postChatter(case1.Id, new List<Id>());        
        Test.stopTest();
         
        List<CaseTeamMember> members = [SELECT Id FROM CaseTeamMember WHERE ParentId = :case1.Id];
        Assert.areEqual(1, members.size());
        Map<Id, Set<EntitySubscription>> mapSubscriptions = EntitySubscription_Service.getSubscribers(new Set<Id>{ case1.Id });
      	Assert.areEqual(1, mapSubscriptions.get(case1.Id).size());
    }

    @isTest(SeeAllData=true)
    static void test_caseFeedItemWithUserMention() {
        User u1 = TestFactoryUser.makeUser(null, 'One Test', 'System Administrator', '910', 'one.test@bbsi.zzz', 'one.test@bbsi.zzz');	
        User u2 = TestFactoryUser.makeUser(null, 'Two Test', 'BBSI Standard', '910', 'two.test@bbsi.zzz', 'two.test@bbsi.zzz');	
        User u3 = TestFactoryUser.makeUser(null, 'Three Test', 'BBSI Standard', '910', 'three.test@bbsi.zzz', 'three.test@bbsi.zzz');	
        insert new List<User>{ u1, u2, u3 };
            
        Account a = TestFactoryAccount.createBranch('--Test Account--');
        Contact c = TestFactoryContact.createEmployee(null, null, 'One TestContact', a.Id);
        Case case1 = TestFactoryCase.createCase('--First Test Case', null, c.Id, a.Id, null, null, new  Map<String, Object> {'Type' => 'Feature'});

        Test.startTest();
        postChatter(case1.Id, new List<Id>{ u1.Id, u2.Id });
        Test.stopTest();
         
        List<CaseTeamMember> members = [SELECT Id FROM CaseTeamMember WHERE ParentId = :case1.Id];
        Assert.areEqual(3, members.size());
        Map<Id, Set<EntitySubscription>> mapSubscriptions = EntitySubscription_Service.getSubscribers(new Set<Id>{ case1.Id });
        Assert.areEqual(3, mapSubscriptions.get(case1.Id).size());
    }
   
    @isTest(SeeAllData=true)
    static void test_caseFeedItemAddingUserMention() {
        User u1 = TestFactoryUser.makeUser(null, 'One Test', 'System Administrator', '910', 'one.test@bbsi.zzz', 'one.test@bbsi.zzz');	
        User u2 = TestFactoryUser.makeUser(null, 'Two Test', 'BBSI Standard', '910', 'two.test@bbsi.zzz', 'two.test@bbsi.zzz');	
        User u3 = TestFactoryUser.makeUser(null, 'Three Test', 'BBSI Standard', '910', 'three.test@bbsi.zzz', 'three.test@bbsi.zzz');	
        insert new List<User>{ u1, u2, u3 };

        Account a = TestFactoryAccount.createBranch('--Test Account--');
        Contact c = TestFactoryContact.createEmployee(null, null, 'One TestContact', a.Id);
        Case case1 = TestFactoryCase.createCase('--First Test Case', null, c.Id, a.Id, null, null, new  Map<String, Object> {'Type' => 'Feature'});

        Test.startTest();
        postChatter(case1.Id, new List<Id>{ u1.Id, u2.Id });
        postChatter(case1.Id, new List<Id>{ u2.Id, u3.Id });
        Test.stopTest();
        
        List<CaseTeamMember> members = [SELECT Id FROM CaseTeamMember WHERE ParentId = :case1.Id];
        Assert.areEqual(4, members.size());  
        Map<Id, Set<EntitySubscription>> mapSubscriptions = EntitySubscription_Service.getSubscribers(new Set<Id>{ case1.Id });
        Assert.areEqual(4, mapSubscriptions.get(case1.Id).size());   
    }

    @isTest(SeeAllData=true)
    static void test_caseFeedItemWithGroupMention() {           
        Account a = TestFactoryAccount.createBranch('--Test Account--');
        Contact c = TestFactoryContact.createEmployee(null, null, 'One TestContact', a.Id);
        Case case1 = TestFactoryCase.createCase('--First Test Case', null, c.Id, a.Id, null, null, new  Map<String, Object> {'Type' => 'Feature'});
        
        User u1 = TestFactoryUser.makeUser(null, 'One Test', 'System Administrator', '910', 'one.test@bbsi.zzz', 'one.test@bbsi.zzz');	
        User u2 = TestFactoryUser.makeUser(null, 'Two Test', 'BBSI Standard', '910', 'two.test@bbsi.zzz', 'two.test@bbsi.zzz');	
        User u3 = TestFactoryUser.makeUser(null, 'Three Test', 'BBSI Standard', '910', 'three.test@bbsi.zzz', 'three.test@bbsi.zzz');	
        insert new List<User>{ u1, u2, u3 };
            
        CollaborationGroup group1;
        System.runAs(u1) {
            group1 = new CollaborationGroup (Name = 'Test-Group-1', CollaborationType = 'Public');
            insert group1;

            List<CollaborationGroupMember> gmembers = new List<CollaborationGroupMember>();
            // u1 is in group because is creator
            gmembers.add( new CollaborationGroupMember (CollaborationGroupId = group1.Id, Memberid  = u2.Id) );
            gmembers.add( new CollaborationGroupMember (CollaborationGroupId = group1.Id, Memberid  = u3.Id) );
            insert gmembers;
        }

        Test.startTest();        
        postChatter(case1.Id, new List<Id>{ group1.Id });        
        Test.stopTest();
         
        List<CaseTeamMember> members = [SELECT Id FROM CaseTeamMember WHERE ParentId = :case1.Id];
        Assert.areEqual(4, members.size());
        Map<Id, Set<EntitySubscription>> mapSubscriptions = EntitySubscription_Service.getSubscribers(new Set<Id>{ case1.Id });
        Assert.areEqual(4, mapSubscriptions.get(case1.Id).size());
    }
    
    @isTest(SeeAllData=true)
    static void test_caseFeedItemWithGroupMentionInactiveMembers() {
        Account a = TestFactoryAccount.createBranch('--Test Account--');
        Contact c = TestFactoryContact.createEmployee(null, null, 'One TestContact', a.Id);
        Case case1 = TestFactoryCase.createCase('--First Test Case', null, c.Id, a.Id, null, null, new  Map<String, Object> {'Type' => 'Feature'});
        
        User u1 = TestFactoryUser.makeUser(null, 'One Test', 'System Administrator', '910', 'one.test@bbsi.zzz', 'one.test@bbsi.zzz');	
        User u2 = TestFactoryUser.makeUser(null, 'Two Test', 'BBSI Standard', '910', 'two.test@bbsi.zzz', 'two.test@bbsi.zzz');	
        User u3 = TestFactoryUser.makeUser(null, 'Three Test', 'BBSI Standard', '910', 'three.test@bbsi.zzz', 'three.test@bbsi.zzz');	
        insert new List<User>{ u1, u2, u3 };
            
        CollaborationGroup group1;
        System.runAs(u1) {
            group1 = new CollaborationGroup (Name = 'Test-Group-1', CollaborationType = 'Public');
            insert group1;

            List<CollaborationGroupMember> gmembers = new List<CollaborationGroupMember>();
            // u1 is in group because is creator
            gmembers.add( new CollaborationGroupMember (CollaborationGroupId = group1.Id, Memberid  = u2.Id) );
            gmembers.add( new CollaborationGroupMember (CollaborationGroupId = group1.Id, Memberid  = u3.Id) );
            insert gmembers;

            u2.IsActive = false;
            u3.IsActive = false;
            update new List<User>{ u2, u3 };
        }

        Test.startTest();
        postChatter(case1.Id, new List<Id>{ group1.Id });
        Test.stopTest();

        List<CaseTeamMember> members = [SELECT Id FROM CaseTeamMember WHERE ParentId = :case1.Id];
        Assert.areEqual(2, members.size());
        Map<Id, Set<EntitySubscription>> mapSubscriptions = EntitySubscription_Service.getSubscribers(new Set<Id>{ case1.Id });
       Assert.areEqual(2, mapSubscriptions.get(case1.Id).size());
    }
    
    @isTest(SeeAllData=true)
    static void test_caseFeedItemWithGroupMentionLimit() {
        Account a = TestFactoryAccount.createBranch('--Test Account--');
        Contact c = TestFactoryContact.createEmployee(null, null, 'One TestContact', a.Id);
        Case case1 = TestFactoryCase.createCase('--First Test Case', null, c.Id, a.Id, null, null, new  Map<String, Object> {'Type' => 'Feature'});
        
        User u1 = TestFactoryUser.makeUser(null, 'One Test', 'System Administrator', '910', 'One.test@bbsi.zzz', 'One.test@bbsi.zzz');	
        User u2 = TestFactoryUser.makeUser(null, 'Two Test', 'BBSI Standard', '910', 'Two.test@bbsi.zzz', 'Two.test@bbsi.zzz');	
        User u3 = TestFactoryUser.makeUser(null, 'Three Test', 'BBSI Standard', '910', 'Three.test@bbsi.zzz', 'Three.test@bbsi.zzz');	
        User u4 = TestFactoryUser.makeUser(null, 'Four Test', 'BBSI Standard', '910', 'Four.test@bbsi.zzz', 'Four.test@bbsi.zzz');	
        User u5 = TestFactoryUser.makeUser(null, 'Five Test', 'BBSI Standard', '910', 'Five.test@bbsi.zzz', 'Five.test@bbsi.zzz');	
        User u6 = TestFactoryUser.makeUser(null, 'Six Test', 'BBSI Standard', '910', 'Six.test@bbsi.zzz', 'Six.test@bbsi.zzz');	
        User u7 = TestFactoryUser.makeUser(null, 'Seven Test', 'BBSI Standard', '910', 'Seven.test@bbsi.zzz', 'Seven.test@bbsi.zzz');	
        User u8 = TestFactoryUser.makeUser(null, 'Eight Test', 'BBSI Standard', '910', 'Eight.test@bbsi.zzz', 'Eight.test@bbsi.zzz');	
        User u9 = TestFactoryUser.makeUser(null, 'Nine Test', 'BBSI Standard', '910', 'Nine.test@bbsi.zzz', 'Nine.test@bbsi.zzz');	
        User u10 = TestFactoryUser.makeUser(null, 'Ten Test', 'BBSI Standard', '910', 'Ten.test@bbsi.zzz', 'Ten.test@bbsi.zzz');	
        User u11 = TestFactoryUser.makeUser(null, 'Eleven Test', 'BBSI Standard', '910', 'Eleven.test@bbsi.zzz', 'Eleven.test@bbsi.zzz');	
        User u12 = TestFactoryUser.makeUser(null, 'Twelve Test', 'BBSI Standard', '910', 'Twelve.test@bbsi.zzz', 'Twelve.test@bbsi.zzz');	
        insert new List<User>{ u1, u2, u3, u4, u5, u6, u7, u8, u9, u10, u11, u12 };
            
        CollaborationGroup group1;
        System.runAs(u1) {
            group1 = new CollaborationGroup (Name = 'Test-Group-1', CollaborationType = 'Public');
            insert group1;

            List<CollaborationGroupMember> gmembers = new List<CollaborationGroupMember>();
            // u1 is in group because is creator
            gmembers.add( new CollaborationGroupMember (CollaborationGroupId = group1.Id, Memberid  = u2.Id) );
            gmembers.add( new CollaborationGroupMember (CollaborationGroupId = group1.Id, Memberid  = u3.Id) );
            gmembers.add( new CollaborationGroupMember (CollaborationGroupId = group1.Id, Memberid  = u4.Id) );
            gmembers.add( new CollaborationGroupMember (CollaborationGroupId = group1.Id, Memberid  = u5.Id) );
            gmembers.add( new CollaborationGroupMember (CollaborationGroupId = group1.Id, Memberid  = u6.Id) );
            gmembers.add( new CollaborationGroupMember (CollaborationGroupId = group1.Id, Memberid  = u7.Id) );
            gmembers.add( new CollaborationGroupMember (CollaborationGroupId = group1.Id, Memberid  = u8.Id) );
            gmembers.add( new CollaborationGroupMember (CollaborationGroupId = group1.Id, Memberid  = u9.Id) );
            gmembers.add( new CollaborationGroupMember (CollaborationGroupId = group1.Id, Memberid  = u10.Id) );
            gmembers.add( new CollaborationGroupMember (CollaborationGroupId = group1.Id, Memberid  = u11.Id) );
            gmembers.add( new CollaborationGroupMember (CollaborationGroupId = group1.Id, Memberid  = u12.Id) );
            insert gmembers;
        }

        Test.startTest();
        postChatter(case1.Id, new List<Id>{ group1.Id });
        Test.stopTest();

        List<CaseTeamMember> members = [SELECT Id FROM CaseTeamMember WHERE ParentId = :case1.Id];
        Assert.areEqual(1, members.size());
        Map<Id, Set<EntitySubscription>> mapSubscriptions = EntitySubscription_Service.getSubscribers(new Set<Id>{ case1.Id });
        Assert.areEqual(1, mapSubscriptions.get(case1.Id).size());
    }

    @isTest(SeeAllData=true)
    static void test_blockClosedCasePosts() {      
        Account a = TestFactoryAccount.createBranch('--Test Account--');
        Contact c = TestFactoryContact.createEmployee(null, null, 'One TestContact', a.Id);
        Case case1 = TestFactoryCase.createCase('--First Test Case', null, c.Id, a.Id, null, null, new  Map<String, Object> {
                        'Type' => 'Feature',
                        'Status' => 'New'
                    });

        postChatter(case1.Id, new List<Id>());
        List<FeedItem> feedItems = [SELECT Id FROM FeedItem WHERE ParentId = :case1.Id];
        Assert.areEqual(1, feedItems.size());

        Test.startTest();
        case1.Status = 'Closed';
        case1.Resolution__c = 'Fixed this TEST case.';
        update case1;
        
        feedItems = [SELECT Id FROM FeedItem WHERE ParentId = :case1.Id];
        Integer numFeedItems = feedItems.size();
        
        try {
            postChatter(case1.Id, new List<Id>());
            Assert.isTrue(false, 'Exception should have been thrown.  Case post is not allowed on a closed Case.');
        }
        catch (Exception e) {
            Assert.areEqual(true, e.getMessage().contains(Label.FeedItem_Block_Closed_Case_Post));
            // This is the correct path
        }
        Test.stopTest();
    }

    @isTest(SeeAllData=true)
    static void test_blockCasePostEdit() {    
        Account a = TestFactoryAccount.createBranch('--Test Account--');
        Contact c = TestFactoryContact.createEmployee(null, null, 'One TestContact', a.Id);
        Case case1 = TestFactoryCase.createCase('--First Test Case', null, c.Id, a.Id, null, null, new  Map<String, Object> {
                        'Type' => 'Feature',
                        'Status' => 'New'
                    });

        postChatter(case1.Id, new List<Id>());
        List<FeedItem> feedItems = [SELECT Id FROM FeedItem WHERE ParentId = :case1.Id];

        Test.startTest();
        try {
            FeedItem fi = feedItems[0];
            fi.title = 'Attempt to change the FeedItem';
            update fi;

            Assert.isTrue(false, 'Exception should have been thrown.  Not allowed to change Case posts.');
        }
        catch (Exception e) {
            Assert.areEqual(true, e.getMessage().contains(Label.FeedItem_Block_Case_Post_Edit));
        }
        Test.stopTest();
    }

    @isTest(SeeAllData=true)
    static void test_blockCasePostDeletion() {     
        Account a = TestFactoryAccount.createBranch('--Test Account--');
        Contact c = TestFactoryContact.createEmployee(null, null, 'One TestContact', a.Id);
        Case case1 = TestFactoryCase.createCase('--First Test Case', null, c.Id, a.Id, null, null, new  Map<String, Object> {
                        'Type' => 'Feature',
                        'Status' => 'New'
                    });

        postChatter(case1.Id, new List<Id>());
        List<FeedItem> feedItems = [SELECT Id FROM FeedItem WHERE ParentId = :case1.Id];

        Test.startTest();
        try {
            delete feedItems[0];
            Assert.isTrue(false, 'Exception should have been thrown.  Case post is not allowed to be deleted.');
        }
        catch (Exception e) {
            Assert.areEqual(true, e.getMessage().contains(Label.FeedItem_Block_Case_Post_Deletion));
        }
        
        Test.stopTest();
    }
}