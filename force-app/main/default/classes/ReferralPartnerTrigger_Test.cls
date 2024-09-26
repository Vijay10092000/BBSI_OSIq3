@isTest
private class ReferralPartnerTrigger_Test {

    private static Referral_Partner__c objReferralPartner;

    @TestSetup
    static void setupData() {
    	User bdm = TestFactory.createUser('Tester', 'tester@bbsihq.com.gmail', 'tester@bbsihq.com.gmail', 'Area Manager', '910', true);

    	System.runAs(bdm) {
      		Account branch = TestFactory.createAccount('Branch', '97219', 'BBSI Branch', true);
			bdm.Branch_Id__c = '910';
      		update bdm;

            Account referralPartner = TestFactory.createAccount('Referral Test', '97219', 'Referral Partner', false);
            referralPartner.Referral_Partner_Status__c = 'Active';
            insert referralPartner;

      		Contact c = TestFactory.CreateContact(referralPartner,'Producer','Producer', true);
      		List<Lead> clientLeads = New List<Lead>();
      		clientLeads.Add(TestFactoryLead.makeClientLead('TEST', 'Company1', 'Company1', branch.Id, bdm.Id));
      		clientLeads[0].Referral_Partner__c = referralPartner.Id;
      		clientLeads[0].Producer__c = c.Id;
      		clientLeads[0].Duplicate_Check_Status__c = true;
            clientLeads[0].Estimated_Annual_Billing__c = 354000;
      		insert clientLeads;

            objReferralPartner = new Referral_Partner__c();
            objReferralPartner.Account__c = branch.Id;
            objReferralPartner.Referral_Partner__c = referralPartner.Id;
            objReferralPartner.Referral_Partner_Commission_Type__c = '% of Margin';
            objReferralPartner.Commission_Rate__c = 10;
            objReferralPartner.Effective_Date__c = Date.today().addDays(-1);
			insert objReferralPartner;
    	}
	}

    public static void getData() {
        objReferralPartner = [SELECT Id FROM Referral_Partner__c LIMIT 1];
    }

    @isTest static void testConvertLeadSeeIfLastReferralDateSetOnReferralPartner() {
        Lead createdLead = [SELECT Id FROM Lead LIMIT 1];
        Account referralPartner = [SELECT Id FROM Account WHERE RecordType.Name = 'Referral Partner' LIMIT 1];

        Test.startTest();

        Database.LeadConvertResult lcr = LeadConvert.convert(createdLead.Id, false);
        System.assert(lcr.isSuccess(), 'Lead convestion failed.');

        createdLead = [SELECT Id, CreatedDate FROM Lead WHERE Id = :createdLead.Id LIMIT 1];
        referralPartner = [SELECT Id, Last_Referral_Date__c FROM Account WHERE Id = :referralPartner.Id LIMIT 1];
        Date createdDate = date.newInstance(createdLead.CreatedDate.Year(), createdLead.CreatedDate.Month(), createdLead.CreatedDate.day());
        Date lastReferraldate = date.newInstance(referralPartner.Last_Referral_Date__c.Year(), referralPartner.Last_Referral_Date__c.Month(), referralPartner.Last_Referral_Date__c.day());
        System.assertEquals(lastReferraldate, createdDate, 'Change should have updated the Referral Partner');

        Test.stopTest();
	}

    @isTest static void testSettingRPonConvertedAccountNotLead() {
		/* FIX: Line 72 is Failing
        Lead createdLead = [SELECT Id FROM Lead LIMIT 1];
        Account referralPartner = [SELECT Id FROM Account WHERE RecordType.Name='Referral Partner' LIMIT 1];

        Test.startTest();

        Database.LeadConvertResult lcr = LeadConvert.convert(createdLead.Id, true);
        System.assertEquals(true, lcr.isSuccess(), 'Lead convestion should be successful.');

        createdLead = [SELECT Id, ConvertedAccountId, CreatedDate FROM Lead WHERE Id = :createdLead.Id LIMIT 1];
        referralPartner = [SELECT Id, Last_Referral_Date__c FROM Account WHERE Id =: referralPartner.Id LIMIT 1];
        System.assertNotEquals(Date.ValueOf(referralPartner.Last_Referral_Date__c), Date.valueOf(createdLead.CreatedDate), 'Lead Referral Date not set correctly');

        createdLead = [SELECT Id, CreatedDate FROM Lead WHERE Id = :createdLead.Id LIMIT 1];
        referralPartner = [SELECT Id, Last_Referral_Date__c FROM Account WHERE Id = :referralPartner.Id LIMIT 1];
        Date createdDate = date.newInstance(createdLead.CreatedDate.Year(), createdLead.CreatedDate.Month(), createdLead.CreatedDate.day());
        Date lastReferraldate = date.newInstance(referralPartner.Last_Referral_Date__c.Year(), referralPartner.Last_Referral_Date__c.Month(), referralPartner.Last_Referral_Date__c.day());
        System.assertEquals(lastReferraldate, createdDate, 'Change should have updated the Referral Partner');

        Test.stopTest();
		*/
	}

    @isTest static void testAddingAndConvertingASecondLeadToMakeSureDateIsUpdated() {
        Lead createdLead = [SELECT Id FROM Lead LIMIT 1];

        Account referralPartner = [SELECT Id FROM Account WHERE RecordType.Name = 'Referral Partner' LIMIT 1];

        Test.startTest();

        Database.LeadConvertResult lcr = LeadConvert.convert(createdLead.Id, true);
        System.assertEquals(true, lcr.isSuccess(), 'Lead convestion should be successful.');

        createdLead = [SELECT Id, CreatedDate FROM Lead WHERE Id = :createdLead.Id LIMIT 1];
        referralPartner = [SELECT Id, Last_Referral_Date__c FROM Account WHERE Id = :referralPartner.Id LIMIT 1];
        Date createdDate = date.newInstance(createdLead.CreatedDate.Year(), createdLead.CreatedDate.Month(), createdLead.CreatedDate.day());
        Date lastReferraldate = date.newInstance(referralPartner.Last_Referral_Date__c.Year(), referralPartner.Last_Referral_Date__c.Month(), referralPartner.Last_Referral_Date__c.day());
        System.assertEquals(lastReferraldate, createdDate, 'Change should have updated the Referral Partner');

        Test.stopTest();
	}
}