/**
 * EntitySubscription_Service_Test contains test for EntitySubscription_Service.
 */
@IsTest
 public without sharing class EntitySubscription_Service_Test {

    private static Case case1;
    private static Case case2;
    private static User user1;
    private static User user2;
    private static User user3;

    @TestSetup
    static void setupTest() {    
        User user1 = testFactoryUser.makeUser(null,'Test User1','BBSI Standard', '910', 'test.user1@bbsihq.zzz', 'test.user1@bbsihq.zzzz');
        User user2 = testFactoryUser.makeUser(null,'Test User2','BBSI Standard', '910', 'test.user2@bbsihq.zzz', 'test.user2@bbsihq.zzzz');
        User user3 = testFactoryUser.makeUser(null,'Test User3','BBSI Standard', '910', 'test.user3@bbsihq.zzz', 'test.user3@bbsihq.zzzz');
        insert new List<User>{ user1, user2, user3 };
        Account a = TestFactoryAccount.createBranch('--Test Account--', '910', null, null);
        Contact c = TestFactoryContact.createContact(null, 'One TestContact', 'BBSI Employee', a.id);        
        case1 = TestFactoryCase.makeCase(null, 
            new Map<String, Object>{  
        	'AccountId'    => a.id,
			'ContactId'    => c.Id,
			'Subject'      => '--First Test Case',
			'Type'         => 'Feature',
	        'Skip_Automation__c'   => True
        });
        case2 = TestFactoryCase.makeCase(null, 
            new Map<String, Object>{  
        	'AccountId'    => a.id,
			'ContactId'    => c.Id,
			'Subject'      => '--Second Test Case',
			'Type'         => 'Feature',
            'Skip_Automation__c'   => True
        });
        insert new List<Case>{ case1, case2 };
    }

    private static void setVariables() {
        case1 = [SELECT Id FROM Case WHERE Subject = '--First Test Case'];
        case2 = [SELECT Id FROM Case WHERE Subject = '--Second Test Case'];
        user1 = [SELECT Id FROM User WHERE LastName = 'Test User1'];
        user2 = [SELECT Id FROM User WHERE LastName = 'Test User2'];
        user3 = [SELECT Id FROM User WHERE LastName = 'Test User3'];
    }  

    /**
     * testMakeEntitySubscription 
     */
    @IsTest
    public static void testMakeEntitySubscription() {
        setVariables();
        EntitySubscription es = EntitySubscription_Service.makeEntitySubscription(case1.Id, user1.Id);
        Assert.areEqual(case1.Id, es.ParentId, 'ParentId was incorrectly set');
        Assert.areEqual(user1.Id, es.SubscriberId, 'SubscriberId was incorrectly set');
    }

    /**
     * testAddSubscribers 
     */
     @IsTest
    public static void testAddSubscribers() {
        setVariables();
        Map<Id, Set<Id>> mapParentToSubscriberIds = new Map<Id, Set<Id>>();
        mapParentToSubscriberIds.put(case1.Id, new Set<Id>());
        mapParentToSubscriberIds.get(case1.Id).add(user1.Id);
        mapParentToSubscriberIds.get(case1.Id).add(user2.Id);
        mapParentToSubscriberIds.put(case2.Id, new Set<Id>());
        mapParentToSubscriberIds.get(case2.Id).add(user3.Id);
        EntitySubscription_Service.addSubscribers(mapParentToSubscriberIds);

        Map<Id, Set<EntitySubscription>> mapParentToSubscribers = EntitySubscription_Service.getSubscribers(new Set<Id>{ case1.Id, case2.Id });
        Assert.areEqual(2, mapParentToSubscribers.keySet().size(), 'Incorrect number of ParentIds');
        Assert.areEqual(true, mapParentToSubscribers.containsKey(case1.Id), 'Missing case1');
        Assert.areEqual(true, mapParentToSubscribers.containsKey(case2.Id), 'Missing case2');
        Assert.areEqual(true, containsUserId(mapParentToSubscribers.get(case1.Id), user1.id), 'case1 missing SubscriberId user1.Id');
        Assert.areEqual(true, containsUserId(mapParentToSubscribers.get(case1.Id), user2.id), 'case1 missing SubscriberId user2.Id');
        Assert.areEqual(true, containsUserId(mapParentToSubscribers.get(case2.Id), user3.id), 'case2 missing SubscriberId user3.Id');

        try {
            mapParentToSubscriberIds.get(case2.Id).add(user1.Id);
            EntitySubscription_Service.addSubscribers(mapParentToSubscriberIds);
            mapParentToSubscribers = EntitySubscription_Service.getSubscribers(new Set<Id>{ case1.Id, case2.Id });
            Assert.areEqual(2, mapParentToSubscribers.keySet().size(), 'Incorrect number of ParentIds');
            Assert.areEqual(true, mapParentToSubscribers.containsKey(case1.Id), 'Missing case1');
            Assert.areEqual(true, mapParentToSubscribers.containsKey(case2.Id), 'Missing case2');
            Assert.areEqual(true, containsUserId(mapParentToSubscribers.get(case2.Id), user1.id), 'case2 missing SubscriberId user1.Id');
        } 
        catch (Exception e) {
            Assert.areEqual(true, false, 'Exception thrown: ' + e.getMessage());
        }
    }

    /**
     * testRemoveAllSubscribers 
     */
     @IsTest
    public static void testRemoveAllSubscribers() {
        setVariables();
        Map<Id, Set<Id>> mapParentToSubscriberIds = new Map<Id, Set<Id>>();
        mapParentToSubscriberIds.put(case1.Id, new Set<Id>());
        mapParentToSubscriberIds.get(case1.Id).add(user1.Id);
        mapParentToSubscriberIds.get(case1.Id).add(user2.Id);
        mapParentToSubscriberIds.put(case2.Id, new Set<Id>());
        mapParentToSubscriberIds.get(case2.Id).add(user3.Id);
        EntitySubscription_Service.addSubscribers(mapParentToSubscriberIds);

        Map<Id, Set<EntitySubscription>> mapParentToSubscribers = EntitySubscription_Service.getSubscribers(new Set<Id>{ case1.Id, case2.Id });
        Assert.areEqual(2, mapParentToSubscribers.keySet().size(), 'Incorrect number of ParentIds');
        Assert.areEqual(true, mapParentToSubscribers.containsKey(case1.Id), 'Missing case1');
        Assert.areEqual(true, mapParentToSubscribers.containsKey(case2.Id), 'Missing case2');
        Assert.areEqual(true, containsUserId(mapParentToSubscribers.get(case1.Id), user1.id), 'case1 missing SubscriberId user1.Id');
        Assert.areEqual(true, containsUserId(mapParentToSubscribers.get(case1.Id), user2.id), 'case1 missing SubscriberId user2.Id');
        Assert.areEqual(true, containsUserId(mapParentToSubscribers.get(case2.Id), user3.id), 'case2 missing SubscriberId user3.Id');

        try {
            EntitySubscription_Service.removeAllSubscribers(new Set<Id>{ case1.Id, case2.Id });
            mapParentToSubscribers = EntitySubscription_Service.getSubscribers(new Set<Id>{ case1.Id, case2.Id });
            Assert.areEqual(2, mapParentToSubscribers.keySet().size(), 'Incorrect number of ParentIds');
            Assert.areEqual(true, mapParentToSubscribers.containsKey(case1.Id), 'Missing case1');
            Assert.areEqual(true, mapParentToSubscribers.containsKey(case2.Id), 'Missing case2');
            Assert.areEqual(0, mapParentToSubscribers.get(case1.Id).size(), 'All followers of case1 should have been removed');
            Assert.areEqual(0, mapParentToSubscribers.get(case2.Id).size(), 'All followers of case2 should have been removed');
        } 
        catch (Exception e) {
           Assert.areEqual(true, false, 'Exception thrown: ' + e.getMessage());
        }
    }

    private static Boolean containsUserId(Set<EntitySubscription> ess, Id idUser) {
        for (EntitySubscription es : ess) {
            if (es.SubscriberId == idUser) {
                return true;
            }
        }
        return false;
    }
 }