/**
 * @description LeadCloneValidator_Test contains tests for the LeadCloneValidator class.
 */
@IsTest
public with sharing class LeadCloneValidator_Test {
	@IsTest
	public static void test_NoLeads() {
		Lead lead = new Lead();

		List<String> result = LeadCloneValidator.validate(new List<Lead>());

		Assert.areEqual(1, result.size());
		Assert.areEqual(LeadCloneValidator.ERROR_NO_LEADS, result.get(0));
	}

	@IsTest
	public static void test_fullError() {
		Lead lead = new Lead();

		List<String> result = LeadCloneValidator.validate(new List<Lead>{ lead });

		Assert.areEqual(1, result.size());
		Assert.areEqual(LeadCloneValidator.ERROR_BAD_RECORDTYPE, result.get(0));
	}

	@IsTest
	public static void test_ErrorLeadSource() {
		Lead lead = new Lead(
			RecordTypeId = RecordTypeService.getId('Lead', 'Client Lead'),
			LeadSource = 'Other'
		);

		List<String> result = LeadCloneValidator.validate(new List<Lead>{ lead });

		Assert.areEqual(1, result.size());
		String error = result.get(0);

		Assert.isTrue(error.Contains('Other Lead Source'));
	}

	@IsTest
	public static void test_ErrorClient() {
		Lead lead = new Lead(
			RecordTypeId = RecordTypeService.getId('Lead', 'Client Lead')
		);

		List<String> result = LeadCloneValidator.validate(new List<Lead>{ lead });

		Assert.areEqual(1, result.size());
		String error = result.get(0);

		Assert.isTrue(error.Contains('Company'));
		Assert.isTrue(error.Contains('Last Name'));
		Assert.isTrue(error.Contains('Phone Number'));
		Assert.isTrue(error.Contains('Lead Source'));
		Assert.isTrue(error.Contains('Part of a Franchise'));
		Assert.isTrue(error.Contains('Referral Partner'));
	}

	@IsTest
	public static void test_ErrorPartOfFranchise() {
		Lead lead = new Lead(
			RecordTypeId = RecordTypeService.getId('Lead', 'Client Lead'),
			Part_of_a_Franchise__c = 'Yes'
		);

		List<String> result = LeadCloneValidator.validate(new List<Lead>{ lead });

		Assert.areEqual(1, result.size());
		String error = result.get(0);

		Assert.isTrue(error.Contains('Franchise Brand Name'));
	}

	@IsTest
	public static void test_ErrorOtherFranchise() {
		Lead lead = new Lead(
			RecordTypeId = RecordTypeService.getId('Lead', 'Client Lead'),
			Part_of_a_Franchise__c = 'Yes',
			Franchise_Brand_Name__c = 'Other'
		);

		List<String> result = LeadCloneValidator.validate(new List<Lead>{ lead });

		Assert.areEqual(1, result.size());
		String error = result.get(0);

		Assert.isTrue(error.Contains('Other Franchise Brand Name'));
	}

	@IsTest
	public static void test_fullReferralPartnerError() {
		Lead lead = new Lead(
			RecordTypeId = RecordTypeService.getId('Lead', 'Referral Partner Lead')
		);

		List<String> result = LeadCloneValidator.validate(new List<Lead>{ lead });

		Assert.areEqual(1, result.size());
		String error = result.get(0);

		Assert.isTrue(error.Contains('Company'));
		Assert.isTrue(error.Contains('Last Name'));
		Assert.isTrue(error.Contains('Phone Number'));
		Assert.isTrue(error.Contains('Lead Source'));
		Assert.isTrue(error.Contains('Email'));
	}

	@IsTest
	public static void test_ErrorProducer() {
		Account rp = TestFactoryAccount.createReferralPartner('Referral Partner Test', '% of Margin', 3, null);

		Lead lead = new Lead(
			RecordTypeId = RecordTypeService.getId('Lead', 'Client Lead'),
			LeadSource = 'Other',
			Referral_Partner__c = rp.Id
		);

		List<String> result = LeadCloneValidator.validate(new List<Lead>{ lead });

		Assert.areEqual(1, result.size());
		String error = result.get(0);

		Assert.isTrue(error.Contains('Producer'));
	}

	@IsTest
	public static void test_ErrorProducerAccount() {
		Account rp1 = TestFactoryAccount.createReferralPartner('Referral Partner ONE', '% of Margin', 1.1, null);
		Account rp2 = TestFactoryAccount.createReferralPartner('Referral Partner TWO', '% of Margin', 2.2, null);

		Contact producer = TestFactoryContact.createProducer('FIRST', 'TEST', rp2.id);

		Lead lead = new Lead(
			RecordTypeId = RecordTypeService.getId('Lead', 'Client Lead'),
			LeadSource = 'Other',
			Referral_Partner__c = rp1.Id,
			Producer__c = producer.Id
		);

		List<String> result = LeadCloneValidator.validate(new List<Lead>{ lead });

		Assert.areEqual(1, result.size());
		String error = result.get(0);

		Assert.isTrue(error.Contains(LeadCloneValidator.ERROR_PRODUCER));
	}
}