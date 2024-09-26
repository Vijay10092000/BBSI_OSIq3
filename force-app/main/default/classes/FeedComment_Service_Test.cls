/**
 * @description FeedComment_Service_Test contains tests fro the FeedComment_Service
 *
 * @see https://salesforce.stackexchange.com/questions/143217/unit-testing-connectapi-chatterfeeds-getfeedelementbatch-with-auto-created-feed/143657
 * @see https://developer.salesforce.com/docs/atlas.en-us.apexcode.meta/apexcode/connectAPI_TestingApex.htm
 */
@IsTest
public with sharing class FeedComment_Service_Test {
	/**
	 * @description postChatter sends a simple post to the given record welcoming each of the mentionIds.
	 * @param recordId   The record the post is related to
     * @param text       Message to send
	 * @param mentionIds Ids which should be mentioned in the post
	 * @see https://developer.salesforce.com/docs/atlas.en-us.apexcode.meta/apexcode/apex_ConnectAPI_ChatterFeeds_static_methods.htm#apex_ConnectAPI_ChatterFeeds_postFeedElement_2
	 */
	static private void postChatter(Id recordId, String text, List<Id> mentionIds) {
		ConnectApi.FeedItemInput feedItemInput = new ConnectApi.FeedItemInput();
		ConnectApi.MessageBodyInput messageInput = new ConnectApi.MessageBodyInput();
		ConnectApi.TextSegmentInput textSegment;
		ConnectApi.MentionSegmentInput mentionSegment;

		messageInput.messageSegments = new List<ConnectApi.MessageSegmentInput>();

		if (mentionIds.isEmpty()) {
			textSegment = new ConnectApi.TextSegmentInput();
			textSegment.text = text;
			messageInput.messageSegments.add(textSegment);
		} else {
			textSegment = new ConnectApi.TextSegmentInput();
			textSegment.text = text;
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

		ConnectApi.ChatterFeeds.postFeedElement(Network.getNetworkId(), feedItemInput);
	}

	/**
	 * @description postChatterComment description
	 * @param  feedItemId FeedItemId description
	 * @param  text       text description
	 * @param  mentionIds Ids which should be mentioned in the post
	 */
	private static void postChatterComment(Id feedItemId, String text, List<Id> mentionIds) {
		ConnectApi.TextSegmentInput textSegment;
		ConnectApi.MentionSegmentInput mentionSegment;

		ConnectApi.MessageBodyInput messageBody = new ConnectApi.MessageBodyInput();
		messageBody.messageSegments = new List<ConnectApi.MessageSegmentInput>();

		if (mentionIds.isEmpty()) {
			textSegment = new ConnectApi.TextSegmentInput();
			textSegment.text = text;
			messageBody.messageSegments.add(textSegment);
		} else {
			textSegment = new ConnectApi.TextSegmentInput();
			textSegment.text = text;
			messageBody.messageSegments.add(textSegment);

			for (Id id : mentionIds) {
				mentionSegment = new ConnectApi.MentionSegmentInput();
				mentionSegment.id = id;
				messageBody.messageSegments.add(mentionSegment);

				textSegment = new ConnectApi.TextSegmentInput();
				textSegment.text = ' <br> ';
				messageBody.messageSegments.add(textSegment);
			}
		}

		ConnectApi.CommentInput commentInput = new ConnectApi.CommentInput();
		commentInput.body = messageBody;

		ConnectApi.ChatterFeeds.postCommentToFeedElement(Network.getNetworkId(), feedItemId, commentInput, null);
	}

    @IsTest(SeeAllData=true)
    @SuppressWarnings('PMD.ApexUnitTestShouldNotUseSeeAllDataTrue')
	static void test_caseFeedCommentWithNoMention() {
        Account a = TestFactoryAccount.createBranch('--Test Account--', null,null,null);
        Contact c = TestFactoryContact.createEmployee(null, null, 'One TestContact', a.Id);		
		Case case1 = TestFactoryCase.createCase('First Test Case', '', c.Id, a.Id, null, null, new Map<String, Object>{
			'Type' => 'Equipment/Hardware Request',
			'Type__c' => 'Printer'
		});

		Test.startTest();
		postChatter(case1.Id, 'Basic Post', new List<Id>());
		FeedItem feedItem = [SELECT Id, ParentId FROM FeedItem WHERE ParentId = :case1.Id LIMIT 1];
		postChatterComment(feedItem.Id, 'No Mentions', new List<Id>());
		Test.stopTest();

		List<CaseTeamMember> members = [SELECT Id FROM CaseTeamMember WHERE ParentId = :case1.Id];
		Assert.areEqual(1, members.size(), 'Case should have one member');
		Map<Id, Set<EntitySubscription>> mapSubscriptions = EntitySubscription_Service.getSubscribers(
			new Set<Id>{ case1.Id }
		);
		Assert.areEqual(1, mapSubscriptions.get(case1.Id).size(), 'Only one subscriber');
	}

	@IsTest(SeeAllData=true)
    @SuppressWarnings('PMD.ApexUnitTestShouldNotUseSeeAllDataTrue')
	static void test_caseFeedCommentWithUserMention() {
		User u1 = TestFactoryUser.makeUser('testuser1','One Test','System Administrator','910','one.test@bbsi.zzz','one.test@bbsi.zzz');
	    User u2 = TestFactoryUser.makeUser('testuser2','Two Test','BBSI Standard','910','two.test@bbsi.zzz','two.test@bbsi.zzz');
        User u3 = TestFactoryUser.makeUser('testuser3','three Test','BBSI Standard','910','three.test@bbsi.zzz','three.test@bbsi.zzz');
		insert new List<User>{ u1, u2, u3 };
        Account a = TestFactoryAccount.createBranch('--Test Account--', null, null,null);
		Contact c = TestFactoryContact.createEmployee(null, null, 'One TestContact', a.Id);
		Case case1 = TestFactoryCase.createCase('--First Test Case', '', c.Id, a.Id, null, null, new Map<String, Object>{
			'Type' => 'Feature'
		});

		List<CaseTeamMember> members = [SELECT Id FROM CaseTeamMember WHERE ParentId = :case1.Id];
		Assert.areEqual(1, members.size(), 'Case1 should have one member');

		Test.startTest();
		postChatter(case1.Id, 'Start Post', new List<Id>());
		FeedItem feedItem = [SELECT Id, ParentId FROM FeedItem WHERE ParentId = :case1.Id LIMIT 1];
		postChatterComment(feedItem.Id, '3 Mentions', new List<Id>{ u1.Id, u2.Id });
		Test.stopTest();

		members = [SELECT Id FROM CaseTeamMember WHERE ParentId = :case1.Id];
		Assert.areEqual(3, members.size(), 'Case1 now should have three members');
		Map<Id, Set<EntitySubscription>> mapSubscriptions = EntitySubscription_Service.getSubscribers(
			new Set<Id>{ case1.Id }
		);
		Assert.areEqual(3, mapSubscriptions.get(case1.Id).size(), 'Number of subscriptions should be three');
	}

	@IsTest(SeeAllData=true)
    @SuppressWarnings('PMD.ApexUnitTestShouldNotUseSeeAllDataTrue')
	static void test_caseFeedCommentNoText() {		
        User u1 = TestFactoryUser.makeUser('testuser1','One Test','System Administrator','910','one.test@bbsi.zzz','one.test@bbsi.zzz');
	    User u2 = TestFactoryUser.makeUser('testuser2','Two Test','BBSI Standard','910','two.test@bbsi.zzz','two.test@bbsi.zzz');
        User u3 = TestFactoryUser.makeUser('testuser3','three Test','BBSI Standard','910','three.test@bbsi.zzz','three.test@bbsi.zzz');
		insert new List<User>{ u1, u2, u3 };
        Account a = TestFactoryAccount.createBranch('--Test Account--', null, null,null);
		Contact c = TestFactoryContact.createEmployee(null, null, 'One TestContact', a.Id);
		Case case1 = TestFactoryCase.createCase('--First Test Case', '', c.Id, a.Id, null, null, new Map<String, Object>{
			'Type' => 'Feature'
		});

		List<CaseTeamMember> members = [SELECT Id FROM CaseTeamMember WHERE ParentId = :case1.Id];
		Assert.areEqual(1, members.size(), 'Case should have one member');

		Test.startTest();
		postChatter(case1.Id, 'Start Post', new List<Id>());
		FeedItem feedItem = [SELECT Id, ParentId FROM FeedItem WHERE ParentId = :case1.Id LIMIT 1];
		try {
			postChatterComment(feedItem.Id, '', new List<Id>());
			Assert.isTrue(false, 'Should have thrown an exception');
		} catch (Exception e) {
			Assert.isTrue(true, 'Exception should be thrown');
		}
		Test.stopTest();
	}

	@IsTest(SeeAllData=true)
    @SuppressWarnings('PMD.ApexUnitTestShouldNotUseSeeAllDataTrue')
	static void test_blockClosedCaseComments() {
		Account a = TestFactoryAccount.createBranch('--Test Account--', null, null,null);
		Contact c = TestFactoryContact.createEmployee(null, null, 'One TestContact', a.Id);
		Case case1 = TestFactoryCase.createCase('--First Test Case', '', c.Id, a.Id, null, null, new Map<String, Object>{
			'Type' => 'Feature'
		});

		postChatter(case1.Id, 'Basic Post', new List<Id>());
		FeedItem feedItem = [SELECT Id, ParentId FROM FeedItem WHERE ParentId = :case1.Id LIMIT 1];

		case1.Status = 'Closed';
		case1.Resolution__c = 'Fixed this TEST case.';
		update case1;

		Test.startTest();
		try {
			postChatterComment(feedItem.Id, 'Another Comment', new List<Id>());
			Assert.isTrue(false, 'Exception should have been thrown.  Case comment is not allowed on a closed Case.');
		} catch (Exception e) {
			Assert.areEqual(true, e.getMessage().contains(Label.FeedComment_Block_Closed_Case_Comment), 'Exception is closed case');
		}
		Test.stopTest();
	}

	@IsTest(SeeAllData=true)
    @SuppressWarnings('PMD.ApexUnitTestShouldNotUseSeeAllDataTrue')
	static void test_blockCaseCommentEdit() {
		Account a = TestFactoryAccount.createBranch('--Test Account--', null, null,null);
		Contact c = TestFactoryContact.createEmployee(null, null, 'One TestContact', a.Id);
		Case case1 = TestFactoryCase.createCase('--First Test Case', '', c.Id, a.Id, null, null, new Map<String, Object>{
			'Type' => 'Feature'
		});

		postChatter(case1.Id, 'Basic Post', new List<Id>());
		FeedItem feedItem = [SELECT Id, ParentId FROM FeedItem WHERE ParentId = :case1.Id LIMIT 1];

		postChatterComment(feedItem.Id, 'A Comment', new List<Id>());
		FeedComment feedcomment = [SELECT Id, ParentId FROM FeedComment WHERE ParentId = :case1.Id LIMIT 1];

		Test.startTest();
		try {
			feedcomment.IsRichText = false;
			feedcomment.CommentBody = 'Attempt to change the FeedComment';
			update feedcomment;

			Assert.isTrue(false, 'Exception should have been thrown.  Not allowed to change Case comments.');
		} catch (Exception e) {
			Assert.areEqual(true, e.getMessage().contains(Label.FeedComment_Block_Case_Comment_Edit), 'Exception is closed case');
		}
		Test.stopTest();
	}

	@IsTest(SeeAllData=true)
    @SuppressWarnings('PMD.ApexUnitTestShouldNotUseSeeAllDataTrue')
	static void test_blockCaseCommentDeletion() {
		Account a = TestFactoryAccount.createBranch('--Test Account--', null, null,null);
		Contact c = TestFactoryContact.createEmployee(null, null, 'One TestContact', a.Id);
		Case case1 = TestFactoryCase.createCase('--First Test Case', '', c.Id, a.Id, null, null, new Map<String, Object>{
			'Type' => 'Feature'
		});

		postChatter(case1.Id, 'Basic Post', new List<Id>());
		FeedItem feedItem = [SELECT Id, ParentId FROM FeedItem WHERE ParentId = :case1.Id LIMIT 1];

		postChatterComment(feedItem.Id, 'A Comment', new List<Id>());
		FeedComment feedcomment = [SELECT Id, ParentId FROM FeedComment WHERE ParentId = :case1.Id LIMIT 1];

		Test.startTest();
		try {
			delete feedcomment;
			Assert.isTrue(false, 'Exception should have been thrown.  Case comment is not allowed to be deleted.');
		} catch (Exception e) {
			Assert.areEqual(true, e.getMessage().contains(Label.FeedComment_Block_Case_Comment_Deletion), 'Exception is closed case');
		}
		Test.stopTest();
    }
    
	@IsTest(SeeAllData=true)
    @SuppressWarnings('PMD.ApexUnitTestShouldNotUseSeeAllDataTrue')
    static void test_onlyOpenCasesFeedComments() {
        Account a = TestFactoryAccount.createBranch('--Test Account--', null, null,null);
		Contact c = TestFactoryContact.createEmployee(null, null, 'One TestContact', a.Id);
		Case case1 = TestFactoryCase.makeCase('--First Test Case', '', c.Id, a.Id, null, null, new Map<String, Object>{
			'Type' => 'Feature'
		});
		Case case2 = TestFactoryCase.makeCase('--Second Test Case', '', c.Id, a.Id, null, null, new Map<String, Object>{
			'Type' => 'Feature'
		});      
        insert new List<Case>{ case1, case2 };

		postChatter(case1.Id, 'Basic Post', new List<Id>());
		FeedItem feedItem1 = [SELECT Id, ParentId FROM FeedItem WHERE ParentId = :case1.Id LIMIT 1];

		postChatterComment(feedItem1.Id, 'A Comment', new List<Id>());
        FeedComment feedcomment1 = [SELECT Id, ParentId FROM FeedComment WHERE ParentId = :case1.Id LIMIT 1];
        
		postChatter(case2.Id, 'Basic Post', new List<Id>());
		FeedItem feedItem2 = [SELECT Id, ParentId FROM FeedItem WHERE ParentId = :case2.Id LIMIT 1];

		postChatterComment(feedItem2.Id, 'A Comment', new List<Id>());
		FeedComment feedcomment2 = [SELECT Id, ParentId FROM FeedComment WHERE ParentId = :case2.Id LIMIT 1];
        
        case2.Status = 'Closed';
        update case2;

        List<FeedComment> workingFCs = new List<FeedComment>{ feedcomment1, feedcomment2 };
        
        test.startTest();
        List<FeedComment> resultFCs = FeedComment_Service.onlyOpenCasesFeedComments(workingFCs);
        test.stopTest();

        Assert.areEqual(1, resultFCs.size(), 'case1 is open case, so should be in list');
        Assert.areEqual(case1.Id, resultFCs.get(0).ParentId, 'case1 is open case, so should be in list');
    }
}