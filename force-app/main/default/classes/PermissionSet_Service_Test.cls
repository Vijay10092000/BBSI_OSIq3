/**
 * PermissionSet_Service_Test contains tests for the methods
 * in PermissionSet_Service.
 */
@IsTest
public without sharing class PermissionSet_Service_Test {

    private static final String TEST_CUSTOM_PERMISSION = 'Referral_Partner_Group_Edit';

    private static User user1 = null;
    private static User user2 = null;
    private static User user3 = null;
    private static User user4 = null;
    private static PermissionSet ps1 = null;
    private static PermissionSet ps2 = null;
    
    /**
     * makeData creates 2 Permission Sets (PS One and PS Two), then
     * 4 Users.  The Users are assgined to the Permissions Sets:
     *     User 1 is in PS One and PS Two
     *     User 2 is in PS One
     *     User 3 is in PS Two
     *     User 4 is in none
     */
    @TestSetup
    static void makeData() {
        PermissionSet ps1 = new PermissionSet(Label = 'PS One', Name = 'PS_One');
        PermissionSet ps2 = new PermissionSet(Label = 'PS Two', Name = 'PS_Two');
        PermissionSet psRPAdmin = [SELECT Id FROM PermissionSet WHERE Name = :PermissionSet_Service.REFERRAL_PARTNER_ADMIN LIMIT 1];

        insert new List<PermissionSet>{ ps1, ps2 };

        User u1 = TestFactory.createUser('PSTestOne', 'test.one@bbsi.zzz', 'test.one@bbsi.zzz', 'BBSI Standard', '910', false);
        User u2 = TestFactory.createUser('PSTestTwo', 'test.two@bbsi.zzz', 'test.two@bbsi.zzz', 'BBSI Standard', '910', false);
        User u3 = TestFactory.createUser('PSTestThree', 'test.three@bbsi.zzz', 'test.three@bbsi.zzz', 'BBSI Standard', '910', false);
        User u4 = TestFactory.createUser('PSTestFour', 'test.four@bbsi.zzz', 'test.four@bbsi.zzz', 'BBSI Standard', '910', false);
        insert new List<User>{ u1, u2, u3, u4 };

        PermissionSetAssignment psa11 = new PermissionSetAssignment(
            AssigneeId = u1.Id,
            PermissionSetId = ps1.Id
        );

        PermissionSetAssignment psa12 = new PermissionSetAssignment(
            AssigneeId = u1.Id,
            PermissionSetId = psRPAdmin.Id
        );

        PermissionSetAssignment psa2 = new PermissionSetAssignment(
            AssigneeId = u1.Id,
            PermissionSetId = ps2.Id
        );

        PermissionSetAssignment psa3 = new PermissionSetAssignment(
            AssigneeId = u2.Id,
            PermissionSetId = ps1.Id
        );

        PermissionSetAssignment psa4 = new PermissionSetAssignment(
            AssigneeId = u3.Id,
            PermissionSetId = ps2.Id
        );

        insert new List<PermissionSetAssignment>{ psa11, psa12, psa2, psa3, psa4 };
    }

    static void loadData() {
        for (User u : [SELECT Id, LastName FROM User WHERE LastName LIKE 'PSTest%']) {
            if (u.LastName == 'PSTestOne')    { user1 = u; }
            if (u.LastName == 'PSTestTwo')    { user2 = u; }
            if (u.LastName == 'PSTestThree')  { user3 = u; }
            if (u.LastName == 'PSTestFour')   { user4 = u; }
        }

        for (PermissionSet ps : [SELECT Id, Name FROM PermissionSet WHERE Name LIKE 'PS_%']) {
            if (ps.Name == 'PS_One')    { ps1 = ps; }
            if (ps.Name == 'PS_Two')    { ps2 = ps; }
        }
    }

    @IsTest
    public static void testResetPermissionSetInfo() {
        System.assertEquals(null, PermissionSet_Service.permissionSets, 'Start with no Permissions Sets read');

        PermissionSet_Service.readPermissionSetInfo();
        System.assertNotEquals(null, PermissionSet_Service.permissionSets, 'There should be some Permission Sets read.');

        PermissionSet_Service.resetPermissionSetInfo();
        System.assertEquals(null, PermissionSet_Service.permissionSets, 'Should have removed the read Permission Sets.');
    }

    @IsTest
    public static void testGetPermissionSetInfo() {
        Map<String, PermissionSet> psets = PermissionSet_Service.getPermissionSetInfo(new Set<String>{ 'PS_One', 'PS_Two' });

        System.assertNotEquals(null, PermissionSet_Service.permissionSets, 'Start with no Permissions Sets read');

        PermissionSet_Service.readPermissionSetInfo();
        System.assertEquals(true, 2 <= PermissionSet_Service.permissionSets.keySet().size(), 'There are more than 2 Permssion Sets.');

        System.assertEquals(2, psets.keySet().size(), 'Should have entry for each requested Permission Set.');
        System.assertEquals(true, psets.containsKey('PS_One'), 'PS_One was requested, so should have an entry');
        System.assertEquals('PS One', psets.get('PS_One').Label, 'Confirm retrieved the correct PS_One entry.');
        System.assertEquals(true, psets.containsKey('PS_Two'), 'PS_Two was requested, so should have an entry');
        System.assertEquals('PS Two', psets.get('PS_Two').Label, 'Confirm retrieved the correct PS_Two entry.');
     }

    @IsTest
    public static void testGetPermissionSetUsers() {
        loadData();
        
        Map<String, List<Id>> psus = PermissionSet_Service.getPermissionSetUsers(new Set<String>{ 'PS_One', 'PS_Two' });
        List<Id> ids;

        System.assertEquals(2, psus.keySet().size(), 'Should have entry for each requested Permission Set.');

        System.assertEquals(true, psus.containsKey('PS_One'), 'PS_One should have an entry in the map');
        ids = psus.get('PS_One');
        System.assertEquals(true, ids.contains(user1.Id), 'User1 is has Permission Set PS_One');
        System.assertEquals(true, ids.contains(user2.Id), 'User2 is has Permission Set PS_One');
        System.assertEquals(false, ids.contains(user3.Id), 'User3 does not have Permission Set PS_One');
        System.assertEquals(false, ids.contains(user4.Id), 'User4 does not have Permission Set PS_One');

        System.assertEquals(true, psus.containsKey('PS_Two'), 'PS_Two should have an entry in the map');
        ids = psus.get('PS_Two');
        System.assertEquals(true, ids.contains(user1.Id), 'User1 is has Permission Set PS_Two');
        System.assertEquals(false, ids.contains(user2.Id), 'User2 does not have Permission Set PS_Two');
        System.assertEquals(true, ids.contains(user3.Id), 'User3 is has Permission Set PS_Two');
        System.assertEquals(false, ids.contains(user4.Id), 'User4 does not have Permission Set PS_Two');
    }

    @IsTest
    public static void testGetUserPermissionSets() {
        loadData();
        
        Map<Id, List<PermissionSet>> upss = PermissionSet_Service.getUserPermissionSets(new Set<Id>{ user1.Id, user2.Id, user3.Id, user4.Id });
        List<PermissionSet> pss;

        System.assertEquals(4, upss.keySet().size(), 'Should have entry for each requested User.');

        // NOTE: The number of Permission Sets on each of the Users
        // is one more then the Permission Sets assgned.  This is
        // because the Profile is included in the Permission Sets.
        
        System.assertEquals(true, upss.containsKey(user1.Id), 'User1 should have an entry in the map.');
        pss = upss.get(user1.Id);
        System.assertEquals(4, pss.size(), 'User1 was assigned a Profile and 3 Permission Sets');

        System.assertEquals(true, upss.containsKey(user2.Id), 'User2 should have an entry in the map.');
        pss = upss.get(user2.Id);
        System.assertEquals(2, pss.size(), 'User2 was assigned a Profile and 1 Permission Set');

        System.assertEquals(true, upss.containsKey(user3.Id), 'User3 should have an entry in the map.');
        System.assertEquals(2, pss.size(), 'User3 was assigned a Profile and 1 Permission Set');

        System.assertEquals(true, upss.containsKey(user4.Id), 'User4 should have an entry in the map.');
        pss = upss.get(user4.Id);
        System.assertEquals(1, pss.size(), 'User4 was assigned a Profile and no Permission Sets');
    }

    @IsTest
    public static void testGetUsersWithCustomPermission() {
        loadData();

        Test.startTest();

        Set<Id> idUsers = PermissionSet_Service.getUsersWithCustomPermission(TEST_CUSTOM_PERMISSION);

        Test.stopTest();

        // Will fail if the value of TEST_CUSTOM_PERMISSION is not assigned to someone
        System.assertEquals(true, idUsers.contains(user1.Id), 'TEST_CUSTOM_PERMISSION should have at least on user assgined to it.');
    }

}