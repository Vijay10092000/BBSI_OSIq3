@IsTest
public without sharing class Debug_Service_Test {

    @SuppressWarnings('PMD.ApexUnitTestClassShouldHaveAsserts')
    @IsTest
    static void testDumpLimits() {
        Debug_Service.dumpLimits(LoggingLevel.DEBUG);
        // No asserts.  Cannot tell if object written to debug.
    }

    @SuppressWarnings('PMD.ApexUnitTestClassShouldHaveAsserts')
    @IsTest
    static void testDebugSObjects() {
        Account a = TestFactoryAccount.makeReferralPartner('Account Test', '% of Margin', 2.22, null);
        Debug_Service.debug(LoggingLevel.DEBUG, new List<SObject>{ a });
        // No asserts.  Cannot tell if object written to debug.
    }

    @SuppressWarnings('PMD.ApexUnitTestClassShouldHaveAsserts')
    @IsTest
    static void testDebugSObjectsFields() {
        Account a = TestFactoryAccount.makeReferralPartner('Account Test', '% of Margin', 2.22, null);
        List<String> fields = new List<String>{ 'Id', 'Name' };
        Debug_Service.debug(LoggingLevel.DEBUG, new List<SObject>{ a }, fields);
        // No asserts.  Cannot tell if object written to debug.
    }

    @IsTest
    public static void testDebugSaveResult() {
        Account a = TestFactoryAccount.makeReferralPartner('Account Test', '% of Margin', 2.22, null);
        Database.SaveResult sr = Database.update(a, false);
        Boolean success = Debug_Service.debug(LoggingLevel.DEBUG, new List<Database.SaveResult>{ sr }, false);
        Assert.areEqual(false, success);

        sr = Database.insert(a, false);
        success = Debug_Service.debug(LoggingLevel.DEBUG, new List<Database.SaveResult>{ sr }, false);
        Assert.areEqual(true, success);
    }
    @IsTest
    public static void testDebugDifferences() {
        Account a1 = TestFactoryAccount.makeReferralPartner('Account Test1', '% of Margin', 2.22, null);
        Account a2 = TestFactoryAccount.makeReferralPartner('Account Test2', '% of Margin', 2.22, null);
        Account b1 = TestFactoryAccount.makeBranch('Branch1');
        
        Debug_Service.debug(LoggingLevel.DEBUG,'', new List<String>{'a','b','c','d'});
        Debug_Service.differences(LoggingLevel.DEBUG,'',a1,a2);
        Debug_Service.differences(LoggingLevel.DEBUG,'',a1,a2);
        Debug_Service.differences(LoggingLevel.DEBUG,'',new Map<Id, account> {a1.Id=>a1,b1.Id=>b1},new Map<Id, account> {a2.Id=>a2, a1.Id=>a1});
        // No asserts.  Cannot tell if object written to debug.
    }
}