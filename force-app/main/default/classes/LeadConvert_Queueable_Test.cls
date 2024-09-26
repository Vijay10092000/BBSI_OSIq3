/**
 * @description LeadConvert_Queueable_Test contains tests for the LeadConvert_Queueable class.
 */
@IsTest
public without sharing class LeadConvert_Queueable_Test {
	/**
	 * @description method performs a test on .
	 */
	@IsTest
	public static void test_convert() {
		Account branch = TestFactoryAccount.createBranch('TEST BRANCH');
		Lead lead1 = TestFactoryLead.makeClientLead('TEST', 'LEAD1', 'One', branch.Id, null);
		Lead lead2 = TestFactoryLead.makeClientLead('TEST', 'LEAD2', 'Two', branch.Id, null);
		Lead lead3 = TestFactoryLead.makeLeadRP('TEST', 'LEAD3', 'Three');
		insert new List<Lead>{ lead1, lead2, lead3 };

		LeadConvert.convert(lead1.Id, true);

		List<Id> idLeads = new List<Id>{ lead1.Id, lead2.Id, lead3.Id };

		Test.startTest();

		LeadConvert_Queueable.convert(idLeads);

		Test.stopTest();

		List<Lead> leads = ([
			SELECT Id, Name, RecordTypeId, IsConverted, ConvertedAccountId, ConvertedContactId, ConvertedOpportunityId
			FROM Lead
			WHERE Id IN :idLeads
			ORDER BY Name ASC
		]);

		Assert.isTrue(leads.get(0).IsConverted);
		Assert.isNotNull(leads.get(0).ConvertedAccountId);
		Assert.isNotNull(leads.get(0).ConvertedContactId);
		Assert.isNotNull(leads.get(0).ConvertedOpportunityId);

		Assert.isTrue(leads.get(1).IsConverted);
		Assert.isNotNull(leads.get(1).ConvertedAccountId);
		Assert.isNotNull(leads.get(1).ConvertedContactId);
		Assert.isNotNull(leads.get(1).ConvertedOpportunityId);

		Assert.isTrue(leads.get(2).IsConverted);
		Assert.isNotNull(leads.get(2).ConvertedAccountId);
		Assert.isNotNull(leads.get(2).ConvertedContactId);
		Assert.isNull(leads.get(2).ConvertedOpportunityId);
	}
}