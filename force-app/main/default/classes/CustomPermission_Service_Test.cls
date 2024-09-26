/**
 *Test Class For CustomPermission_Service
 */
@IsTest
public without sharing class CustomPermission_Service_Test {

    private static User one;
    private static User two;
    
    @TestSetup
    static void makeData() {
        one = TestFactoryUser.makeUser(null,'CPTESTING',  'BBSI Standard', '910', '1.cptesting@bbsi.zzz', '1.cptesting@bbsi.zzz');
        two = TestFactoryUser.makeUser(null,'CPTESTING',  'BBSI Standard', '910', '2.cptesting@bbsi.zzz', '2.cptesting@bbsi.zzz');
        insert new List<User>{ one, two };

        PermissionSet ps = [SELECT Id FROM PermissionSet WHERE Name = 'Referral_Partner_Admin'];        
        TestFactoryPermissionSetAssignment.createPermissionSetAssignment(ps.Id, one.Id);
    }

    static void getData() {
        for (User u : [SELECT Id, Email FROM User WHERE LastName = 'CPTESTING']) {
            if (u.Email == '1.cptesting@bbsi.zzz') { one = u; }
            else if (u.Email == '2.cptesting@bbsi.zzz') { two = u; }
        }
    }

    @IsTest
    static void test_checkUserCustomPermission() {
        getData();

        Set<Id> idUsers = new Set<Id>{ one.Id, two.Id };

        Test.startTest();
        Map<Id, Boolean> hasPermmissions = CustomPermission_Service.checkUserCustomPermission(CustomPermission_Service.REFERRAL_PARTNER_GROUP_EDIT, idUsers);
        Test.stopTest();

        Assert.areEqual(true, hasPermmissions.get(one.Id));
        Assert.areEqual(false, hasPermmissions.get(two.Id));
    }

    @IsTest
    static void test_getUserIdsWithCustomPermission() {
        getData();

        Test.startTest();
        Set<Id> idUsers = CustomPermission_Service.getUserIdsWithCustomPermission(CustomPermission_Service.REFERRAL_PARTNER_GROUP_EDIT);
        Test.stopTest();

        Assert.areEqual(true, idUsers.contains(one.Id));
        Assert.areEqual(false, idUsers.contains(two.Id));
    }

}