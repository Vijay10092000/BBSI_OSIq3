/**
 * @description AccountReferralPartner_Test contains tests for the AccountReferralPartner class.
 */
@IsTest
public without sharing class AccountReferralPartner_Test {

    @IsTest
    public static void test_setExternalId() {
		Account rp1 = TestFactoryAccount.makeReferralPartner('RP1');
		Account rp2 = TestFactoryAccount.makeReferralPartner('RP2');
		Account client1 = TestFactoryAccount.makeClient('Client1', null, null);

		rp1.External_Id__c = null;
		rp2.External_Id__c = '2222222';
		client1.External_Id__c = null;

		AccountReferralPartner.setExternalId(null, new List<Account>{ rp1, rp2, client1 });

		Assert.areEqual(rp1.Acronym__c, rp1.External_Id__c);
		Assert.areEqual('2222222', rp2.External_Id__c);
		Assert.isNull(rp1.External_Id__c);
	}
}