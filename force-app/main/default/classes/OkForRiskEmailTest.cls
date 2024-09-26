/**
 * @descirption OkForRiskEmailTest
 */
@IsTest
private class OkForRiskEmailTest {
	@IsTest static void test_riskEmail() {
		/*NAICS_Code__c n1 = new NAICS_Code__c(
			Name = '111',
			NAICS_Title__c = 'Crop Production'
		);

		NAICS_Code__c n2 = new NAICS_Code__c(
			Name = '111140',
			NAICS_Title__c = 'Wheat Farming'
		);*/
		NAICS_Code__c n1 = TestFactoryNAICSCode.makeCode('111','Crop Production');
		NAICS_Code__c n2 = TestFactoryNAICSCode.makeCode('111140','Wheat Farming');
		insert new List<NAICS_Code__c>{ n1, n2 };

		insert new Ok_For_Risk_Access__c( Name = 'BDMUser' );

		//User bdm = TestFactory.createUser('BDMUser', 'bdm@bbsihq.zzz', 'bdm@bbsihq.zzz', 'Area Manager', '910', false);
        User bdm = TestFactoryUser.makeUser('','BDMUser','Area Manager', '910','bdm@bbsihq.zzz', 'bdm@bbsihq.zzz');
		bdm.Title = 'Business Development Manager';
		insert bdm;

		//Account prospect = TestFactory.createAccount('Test Prospect', '98662', 'Prospect', false);
        Account prospect = TestFactoryAccount.makeProspect('Test Prospect',null,null);
		prospect.FEIN__c = '68-0326512';
		prospect.NAICS__c = '111140';
		insert prospect;

		//Opportunity opp = TestFactory.createOpportunity('TestOpportunity', prospect, System.today(), 'Identifying', true);
		Opportunity opp = TestFactoryOpportunity.createClient('TestOpportunity', prospect.id, System.today(), 'Identifying');
		Test.startTest();

		opp.Request_OK_For_Risk_Approval__c = true;
		opp.Amount = 1000000;

		update opp;

		Test.stopTest();

		opp = [SELECT Id, Name, Request_OK_For_Risk_Approval__c FROM Opportunity WHERE Id = :opp.Id];

		Assert.areEqual(true, opp.Request_OK_For_Risk_Approval__c);
		Assert.areEqual(1, Email_Service.testEmails.size());

		Messaging.Email email = Email_Service.testEmails.get(0);

		Assert.areEqual(true, email.getSubject().contains(opp.Name));
	}
}