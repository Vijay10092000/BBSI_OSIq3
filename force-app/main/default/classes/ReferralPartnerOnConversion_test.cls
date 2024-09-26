/**
 * @description ReferralPartnerOnConversion_test
 */
@IsTest
@SuppressWarnings('PMD.ApexAssertionsShouldIncludeMessage')
public class ReferralPartnerOnConversion_test {
	@IsTest
	static void test() {
        User userBDM = TestFactoryUser.makeBDM(null, 'UserBDM', 'BBSI Standard', '910');
        userBDM.Acronym__c = '0000';

        Account branch = TestFactoryAccount.makeBranch('TestBranch', '98662', null, null);

        Account rpartner = TestFactoryAccount.makeReferralPartner('Referral PartnerTest', '% of Margin', 12.34, null);
        rpartner.Referral_Partner_Status__c = 'Active';

		insert new List<Account>{ branch, rpartner };

		Contact producer = TestFactoryContact.createProducer(null, 'Producer', rpartner.Id);

		Lead testLead = new Lead(
			Branch__c = branch.Id,
			FirstName = 'LeadFirst',
			LastName = 'LeadLast',
			Company = 'LeadCo',
			PostalCode = '98662',
			Phone = '333-333-3333',
			Business_Development_Manager__c = userBDM.Id,
			Duplicate_Check_Status__c = true,
			Referral_Partner__c = rpartner.Id,
			Producer__c = producer.Id,
			Estimated_Annual_Billing__c = 440000
		);

		insert testLead;

		Referral_Partner__c rp1 = new Referral_Partner__c(
			Lead__c = testLead.Id,
			Referral_Partner__c = rpartner.Id,
			Commission_Rate__c = 12.34,
			Referral_Partner_Commission_Type__c = '% of Margin'
		);

		Referral_Partner__c rp2 = new Referral_Partner__c(
			Lead__c = testLead.Id,
			Referral_Partner__c = rpartner.Id,
			Commission_Rate__c = 12.34,
			Referral_Partner_Commission_Type__c = '% of Margin'
		);

		insert new List<Referral_Partner__c>{ rp1, rp2 };

		Test.startTest();

		Database.LeadConvertResult lcr = LeadConvert.convert(testLead.Id, true);
		Assert.isTrue(lcr.isSuccess(), 'Lead conversion failed');

		Test.stopTest();

		Id acRId = RecordTypeService.getId('Referral_Partner__c', 'Client_Referral_Partner');

		Referral_Partner__c rp3 = [SELECT Id, Account__c, RecordTypeId FROM Referral_Partner__c WHERE Id = :rp1.Id];
		Referral_Partner__c rp4 = [SELECT Id, Account__c, RecordTypeId FROM Referral_Partner__c WHERE Id = :rp2.Id];

		Assert.areEqual(testLead.ConvertedAccountId, rp1.Account__c);
		Assert.areEqual(testLead.ConvertedAccountId, rp2.Account__c);
		Assert.areEqual(acRId, rp3.RecordTypeId);
		Assert.areEqual(acRId, rp4.RecordTypeId);
	}
}