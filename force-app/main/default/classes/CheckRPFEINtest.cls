/**
 * @description CheckRPFEINtest contains tests for the CheckRPFEIN class.
 */
@IsTest
public class CheckRPFEINtest {
	/**
	 * @description updateNoDupe test works when not duplicate.
	 */
	@IsTest
	static void updateNoDupe() {
        Account rp1 = TestFactoryAccount.makeReferralPartner('Referral Partner 1','% of Work Comp',10,null);
		rp1.FEIN__c = '99-9999999';
		insert rp1;

        Account rp2 = TestFactoryAccount.createReferralPartner('Referral Partner 2','% of Work Comp',10,null);
		rp2.FEIN__c = '88-8888888';
		try {
			update rp2;
			Assert.isTrue(true, 'No exception should have been thrown.');
		} catch (Exception e) {
			Assert.isTrue(false, 'No exception should have been thrown.');
		}

		Assert.areEqual([SELECT ID FROM Account WHERE name LIKE 'Referral Partner%'].size(), 2);
		Assert.areEqual([SELECT FEIN__c FROM Account WHERE name = 'Referral Partner 1'].FEIN__c, '99-9999999');
		Assert.areEqual([SELECT FEIN__c FROM Account WHERE name = 'Referral Partner 2'].FEIN__c, '88-8888888');
	}

	/**
	 * @description updateNoDupe tests throws excetion when duplicate.
	 */
	@IsTest
	static void updateWithDupe() {
		Account rp1 = TestFactoryAccount.makeReferralPartner('Referral Partner 1','% of Work Comp',10,null);
        rp1.FEIN__c = '99-9999998';
		insert rp1;

		Account rp2 = TestFactoryAccount.createReferralPartner('Referral Partner 2','% of Work Comp',10,null);
        rp2.FEIN__c = '99-9999998';

		try {
			update rp2;
			Assert.isTrue(false, 'Should have thrown an exception.');
		} catch (exception e) {
			Assert.isTrue(e.getMessage().contains('You cannot enter in a duplicate FEIN for Referral Partner'));
		}
	}

	/**
	 * @description updateNoDupe tests works with duplicates, but in duplicate list.
	 */
	@IsTest
	static void updateWithAllowedDupe() {
		CheckRPFEIN.allowedDuplicateFeins.add('99-9999998');

        Account rp1 = TestFactoryAccount.makeReferralPartner('Referral Partner 1','% of Work Comp',10,null);
		rp1.FEIN__c = '99-9999998';
		insert rp1;

		Account rp2 = TestFactoryAccount.createReferralPartner('Referral Partner 2','% of Work Comp',10,null);
        rp2.FEIN__c = '99-9999998';

		try {
			update rp2;
			Assert.isTrue(true, 'No exception should have been thrown.');
		} catch (Exception e) {
			Assert.isTrue(false, 'No exception should have been thrown.');
		}
	}
}