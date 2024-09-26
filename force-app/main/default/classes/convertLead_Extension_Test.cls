/**
 * @description convertLead_Extension_Test contains test for the class convertLead_Extension.
 */
@IsTest
private class convertLead_Extension_Test {
	@IsTest
	static void test_Controller() {
		Account rp = TestFactoryAccount.createReferralPartner('Account Test', null, null, null);
		Contact producer = TestFactoryContact.createProducer('TEST', 'PRODUCER', rp.Id);

		Lead lead = TestFactoryLead.makeClientLead('TEST', 'LEAD', 'TEST_COMPANY', null, null);
		lead.Referral_Partner__c = rp.Id;
		lead.Producer__c = producer.Id;
		lead.Estimated_Annual_Billing__c = 50000;
		lead.LeadSource = 'Other';
		lead.Other_Lead_Source_Type__c = 'Company ABC';
		insert lead;

		ApexPages.StandardController sc = new ApexPages.StandardController(lead);
		convertLead_Extension ext = new convertLead_Extension(sc);
		PageReference pageRef = Page.classic_leadConvert;

		Test.StartTest();
		
		pageRef.getParameters().put('id', String.valueOf(lead.Id));
		Test.setCurrentPage(pageRef);
		ext.archiveDupesAndConvertLead();

		Test.StopTest();

		lead = [SELECT Id, Name, IsConverted FROM Lead WHERE Id = :lead.Id];
		Assert.isTrue(lead.IsConverted, 'Lead should be converted');
	}

	@IsTest
	private static void test_mayConvert() {
		Lead lead = TestFactoryLead.createClientLead('TEST', 'LEAD', 'ABC', null, null);

		lead = [
			SELECT Id, Name, Estimated_Annual_Billing__c, LeadSource, Other_Lead_Source_Type__c, RecordType.Name
			FROM Lead
			WHERE Id = :lead.Id
			LIMIT 1
		];

		lead.Estimated_Annual_Billing__c = null;
		lead.LeadSource = null;
		lead.Other_Lead_Source_Type__c = null;
		Assert.isFalse(convertLead_Extension.mayConvert(lead));

		lead.Estimated_Annual_Billing__c = null;
		lead.LeadSource = 'Convention';
		lead.Other_Lead_Source_Type__c = null;
		//Assert.isFalse(convertLead_Extension.mayConvert(lead));

		lead.Estimated_Annual_Billing__c = 50000;
		lead.LeadSource = null;
		lead.Other_Lead_Source_Type__c = null;
		Assert.isFalse(convertLead_Extension.mayConvert(lead));

		lead.Estimated_Annual_Billing__c = 50000;
		lead.LeadSource = 'Other';
		lead.Other_Lead_Source_Type__c = null;
		Assert.isFalse(convertLead_Extension.mayConvert(lead));

		lead.Estimated_Annual_Billing__c = 50000;
		lead.LeadSource = 'Other';
		lead.Other_Lead_Source_Type__c = 'Company ABC';
		Assert.isTrue(convertLead_Extension.mayConvert(lead));

		lead.Estimated_Annual_Billing__c = 50000;
		lead.LeadSource = 'Convention';
		lead.Other_Lead_Source_Type__c = null;
		Assert.isTrue(convertLead_Extension.mayConvert(lead));
	}
}