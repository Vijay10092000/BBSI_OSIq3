/**
 * @description LedHubSpotRP_Test contains tests for the LedHubSpotRP_Test class.
 */
@IsTest
public with sharing class LeadHubSpotRP_Test {
	@IsTest
	public static void test_updateReferralPartners() {
		Account rp = TestFactoryAccount.createReferralPartner('TEST REFERRAL PARTNER');
		Contact producer = TestFactoryContact.createProducer('TEST', 'PRODUCER', rp.Id);

		Test.startTest();

		HubSpot_Referral_Partner__mdt hrp = makeMetadata('TEST-Indirect', rp.Id, producer.Id);

		LeadHubSpotRP.hubSpotRPs = new Map<String, HubSpot_Referral_Partner__mdt>();
		LeadHubSpotRP.hubSpotRPs.put(hrp.MasterLabel, hrp);

		Lead lead1 = TestFactoryLead.makeClientLead(
			'TEST',
			'LEAD',
			'Easy 123 TEST',
			null,
			null
		);
		lead1.HubSpot_Referral_Partner__c = 'TEST-Indirect';

		Lead lead2 = TestFactoryLead.makeClientLead(
			'TEST',
			'LEAD',
			'Easy 123 TEST',
			null,
			null
		);
		lead2.HubSpot_Referral_Partner__c = null;

		LeadHubSpotRP.updateReferralPartners(null, new List<Lead>{ lead1, lead2 });

		Test.stopTest();

		Assert.areEqual(rp.Id, lead1.Referral_Partner__c);
		Assert.areEqual(producer.Id, lead1.Producer__c);
		Assert.isNull(lead2.Referral_Partner__c);
		Assert.isNull(lead2.Producer__c);
	}

	@IsTest
	public static void test_readHubSpotReferralPartners() {
		LeadHubSpotRP.readHubSpotReferralPartners();

		Assert.isNotNull(LeadHubSpotRP.hubSpotRPs, 'hubSpotRPs should be set.');
	}

	/**
	 * @description makeMetadata makes a HubSpot_Referral_Partner__mdt for use in tests.
	 * @param  label              Name
	 * @param  idReferralPartner  Referral Partner Id
	 * @param  idProducer         Producer Id
	 * @return HubSpot_Referral_Partner__mdt
	 */
	static private HubSpot_Referral_Partner__mdt makeMetadata(String label, Id idReferralPartner, Id idProducer) {
		HubSpot_Referral_Partner__mdt metadata = new HubSpot_Referral_Partner__mdt();
		metadata.MasterLabel = label;
		metadata.Referral_Partner_Id__c = idReferralPartner;
		metadata.Producer_Id__c = idProducer;

		return metadata;
	}
}