/*******************************************************************
 *
 * Test class for the "Renewal client detail" vf page.
 *
 *******************************************************************/
@IsTest
private class RenewalClientDetailExtTest
{
    @TestSetup static void setup()
    {
        // create accounts, record type "Client"
        List<Account> testAccts = new List<Account>();
        String fein = '00-1234567';
        // Id clientTypeId = RecordTypeService.getId('Account','Client');
        Id clientTypeId = RecordTypeService.getId('Account','Client');
        Integer extId = 900000;
        Business_Unit__c bizUnit = new Business_Unit__c(Name = 'foo unit');
        Business_Unit__c bizUnit2 = new Business_Unit__c(Name = 'bar unit');
        insert(bizUnit);
        insert(bizUnit2);
        
        //three account with business unit and fein '00-1234567'
        for (Integer i = 0; i < 3; i++) {
            testAccts.add(new Account(
                    Name = 'test acct ' + i,
                    External_ID__c = String.valueOf(extId + i),
                    FEIN__c = fein,
                    Business_Unit__c = bizUnit.Id,
                    Renewal_Date__c = System.today().addDays(20),
                    Start_Date__c = System.today().addDays(-91),
                    Status__c = 'ACTIVE',
                    RecordTypeId = clientTypeId));
        }

        // and an outlier...
        testAccts.add(new Account(
                Name = 'test acct outlier',
                External_ID__c = String.valueOf(extId + 100),
                FEIN__c = fein,
                Business_Unit__c = bizUnit.Id,
                Renewal_Date__c = System.today().addMonths(4),
                Start_Date__c = System.today().addDays(-365),
                Status__c = 'ACTIVE',
                RecordTypeId = clientTypeId));

        // and an outlier... with same FEIN but a DIFFERENT BUSINESS UNIT!
        testAccts.add(new Account(
                Name = 'test acct outlier2',
                External_ID__c = String.valueOf(extId + 200),
                FEIN__c = fein,
                Business_Unit__c = bizUnit2.Id,
                Renewal_Date__c = System.today().addMonths(4),
                Start_Date__c = System.today().addDays(-365),
                Status__c = 'ACTIVE',
                RecordTypeId = clientTypeId));

        insert(testAccts);
        
        //create contacts
        List<Contact> contacts=new List<Contact>();
        contacts.add(new Contact(FirstName='Unit', LastName='Test', Email='Unit.Test@Unit.Test', AccountId=testAccts[0].Id));
        contacts.add(new Contact(FirstName='Unit', LastName='Test 2', Email='Unit.Test2@Unit.Test', AccountId=testAccts[1].Id));
        contacts.add(new Contact(FirstName='Unit', LastName='Test 3', Email='Unit.Test3@Unit.Test', AccountId=testAccts[2].Id));
        insert contacts;

        Integer thisYear = Date.today().year();

        Account a = testAccts[0];
        // Work_Comp_Policy__c wcp = TestFactory.createWorkCompPolicy('C64375416', Date.newInstance(thisYear, 1, 2), Date.newInstance(thisYear - 1, 1, 1), true);
        Work_Comp_Policy__c wcp = TestFactoryWorkCompPolicy.createWorkCompPolicy('C64375416', Date.newInstance(thisYear, 1, 2), Date.newInstance(thisYear - 1, 1, 1), null);
        // WorkCompPolicyAccount__c wcpa = TestFactory.createWorkCompPolicyAccount('C64375416', wcp, a, true);
        WorkCompPolicyAccount__c wcpa = TestFactoryWorkCompPolicyAccount.createWorkCompPolicyAccount('C64375416', wcp, a, null);

        XmodRecommended__c xmod = new XmodRecommended__c();
        xmod.Policy_Number__c = 'C64375416';
        xmod.State_Code__c = 'CA';
        xmod.Effective_Date__c = Date.newInstance(thisYear, 4, 1);
        xmod.Xmod__c = 1.25;

        XmodRecommendedController.saveXmodRecommended(new List<XmodRecommended__c>{xmod});

        Test.startTest();
        // Note; AddClientsToRenewalsBatch and CreateRenewalLinksBatch are called
        //       at the end of the following batch
        Database.executeBatch(new CreateRenewalsBatchable(), 20);
        Test.stopTest();

    }

   // test that the Renewal detail clients are correctly retrieved when the extension is constructed
   @IsTest static void test_RenewalClientDetailExt()
    {
        List<Renewal__c> renewals = new List<Renewal__c>();
        String name = 'test acct';
        String searchStr='%' + name + '%';
        renewals = [
                SELECT Id, Name, OwnerId, Status__c, Renewal_Date__c, Renewal_Date_Add_1__c
                FROM Renewal__c
                WHERE Name LIKE :searchStr
                LIMIT 20];
        PageReference pr = Page.renewalClientDetail; //pagename put here..
        pr.getParameters().put('id', renewals[0].Id);
        Test.setCurrentPage(pr);
        
        ApexPages.StandardController std = new ApexPages.StandardController(renewals[0]);
        RenewalClientDetailExt controller = new RenewalClientDetailExt(std);
        List<Account>  accounts = controller.getAccounts();
        Assert.areEqual(4, accounts.size());
        Assert.areEqual(1, accounts[0].Contacts.size());

        controller.enabledLogging();
        controller.closePopup();
        controller.setStatusEdit();

        controller.Sname = 'Ps' + Datetime.now().getTime();
        controller.NewPricingScenario();

        List<PricingScenario__c> psItems = controller.GetPricingScenarios();
        Assert.areEqual(1, psItems.size());

        controller.showFinancial();

        controller.Clonename = 'Clone-' + controller.Sname;
        controller.ClonePricingScenario();

        controller.SelectedScenarioId = psItems[0].Id;

        Test.startTest();
        Test.setMock(HttpCalloutMock.class, new PricingDataCalloutClass_Mock('','',''));
        controller.newClientScenario();
        Test.stopTest();

        PricingScenario__c ps = controller.m_psNewPricingScenario;
        ClientPricingScenario__c cps = [
                SELECT Id
                FROM ClientPricingScenario__c
                WHERE PricingScenario__c = :ps.Id
                LIMIT 1
        ];

        PricingXmod__c[] xmods = [
                SELECT Id
                FROM PricingXmod__c
                WHERE ClientPricingScenario__c = :cps.Id
        ];
        Assert.areEqual(6, xmods.size());

        ERPayrollTax__c[] taxes = [
                SELECT Id
                FROM ERPayrollTax__c
                WHERE ClientPricingScenario__c = :cps.Id
        ];
        Assert.areEqual(1, taxes.size());

        PricingExpense__c[] expenses = [
                SELECT Id
                FROM PricingExpense__c
                WHERE ClientPricingScenario__c = :cps.Id
        ];
        Assert.areEqual(3, expenses.size());

        PricingEmployee__c[] employees = [
                SELECT Id
                FROM PricingEmployee__c
                WHERE ClientPricingScenario__c = :cps.Id
        ];
        Assert.areEqual(1, employees.size());

        PricingEmployee__c emp = employees[0];

        PricingEEtoWcCodeAssoc__c[] associations = [
                SELECT Id
                FROM PricingEEtoWcCodeAssoc__c
                WHERE Pricing_Employee__c = :emp.Id
        ];
        Assert.areEqual(1, associations.size());

        PricingSummaryHistory__c[] summary = [
                SELECT Id
                FROM PricingSummaryHistory__c
                WHERE ClientPricingScenario__c = :cps.Id
        ];
        Assert.areEqual(5, summary.size());

        controller.DeleteAPricingScenario();

    }
}