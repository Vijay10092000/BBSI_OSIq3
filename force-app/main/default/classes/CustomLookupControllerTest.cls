@IsTest
public with sharing class CustomLookupControllerTest {
    @IsTest
    public static void testFetchLookUpValues() {
		Account a = TestFactoryAccount.makeClient('!--TestAccount',null,null);
        insert a;
        List<SObject> accounts = CustomLookupController.fetchLookUpValues('!--TestAcco', 'Account');
        Assert.areEqual(1, accounts.size());
    }
}