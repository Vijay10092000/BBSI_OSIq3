/**
 * @description AutoCloseLeads_Batch_Test
 */
@IsTest
@SuppressWarnings('PMD.ApexAssertionsShouldIncludeMessage')
public with sharing class AutoCloseLeads_Batch_Test {
	@TestSetup
	static void setup() {
		Account branch = TestFactoryAccount.createBranch('TEST BRANCH');
		User bdm = TestFactoryUser.createBDM('TEST', 'BDM', 'BBSI Standard', branch.External_Id__c);
		Account rp = TestFactoryAccount.createReferralPartner('RP Test', '% of Margin', 12.0, null);
		Contact producer = TestFactoryContact.createProducer('Test', 'Producer', rp.Id);

		Lead lead = TestFactoryLead.makeClientLead('TEST', 'Lead', 'LeadCo', branch.Id, bdm.Id);
		lead.Producer__c = producer.Id;
		lead.Referral_Partner__c = rp.Id;
		lead.Additional_Contact__c = 'AdnlFirst AdnlLast';
		lead.Additional_Contact_Title__c = 'AdnlTitle';
		lead.Additional_Contact_Phone__c = '444-444-4444';
		lead.Additional_Contact_Mobile__c = '222-222-2222';
		lead.Additional_Contact_Email__c = 'a@a.com';
		lead.Duplicate_Check_Status__c = true;

		insert lead;
	}

	@IsTest
	static void test_AutoCloseLeads_Batch() {        
		Test.StartTest();

		AutoCloseLeads_Schedule sh1 = new AutoCloseLeads_Schedule();
		sh1.execute(null);

		Test.stopTest();

		List<Lead> leads = [SELECT Id, Status FROM Lead];

		Assert.areEqual('Unqualified', leads[0].status);
	}
    @IsTest
	static void test_AutoCloseLeadsOrgDefaults_Batch() {
        OrgWide__c orgWide = OrgWide__c.getOrgDefaults();
        orgWide.Days_For_Auto_Close_Leads__c = '5';
        Upsert orgWide;
		Test.StartTest();

		AutoCloseLeads_Schedule sh1 = new AutoCloseLeads_Schedule();
		sh1.execute(null);

		Test.stopTest();

		List<Lead> leads = [SELECT Id, Status FROM Lead];

		Assert.areEqual('Unqualified', leads[0].status);
	}
}