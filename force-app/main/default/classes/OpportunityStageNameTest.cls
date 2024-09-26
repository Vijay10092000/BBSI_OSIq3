/**
 * @description OpportunityStageNameTest contains tests for the class OpportunityStageName.
 */
@IsTest
public class OpportunityStageNameTest {
	@IsTest
	static void test_ClientOpp() {
		NAICS_Code__c code = new NAICS_Code__c();
		code.Name = '123456';
		code.NAICS_Title__c = 'Crop Production';
		insert code;

		Business_Unit__c bu = new Business_Unit__c(name = 'TEST');
		insert bu;

		Account account1 = TestFactory.createAccountClient('testAcct', false);
		account1.Status__c = 'Pending';
		account1.Business_Unit__c = bu.Id;
		account1.FEIN__c = '99-9999999';
		account1.NAICS__c = code.Name;
		account1.Verified__c = true;
		account1.Credit_Limit__c = 45;
		account1.EEO_Reporting__c = 'Yes';

		insert new List<Account>{ account1 };

		Opportunity opp1 = TestFactory.createOpportunity('TestOpp', account1, System.today(), 'Proposal', false);
		opp1.RecordTypeId = RecordTypeService.getId('Opportunity', 'Client');
		opp1.StageName = 'Contracting';
		opp1.Contract_Approval_Status__c = 'Approved';
		opp1.Credit_Approval_Status__c = 'Approved';
		opp1.OK_For_Risk_Approval_Status__c = 'Approved';
		opp1.AM_Approval_Status__c = 'Approved';
		opp1.Type = 'Co-Employment';
		opp1.Amount = 3.50;
		opp1.Admin_Factor__c = 1.0;
		opp1.Bucket__c = 3;
		opp1.Security_Deposit_Required__c = 'No';
		insert opp1;

		account1.Status__c = 'Active';
		account1.External_Id__c = '903873';

		update new List<Account>{ account1 };

		System.assertEquals(
			'Closed Won',
			[SELECT StageName FROM Opportunity WHERE Id = :opp1.Id]
			.StageName,
			'StageName should be Closed Won'
		);
	}
	@IsTest
	static void test_BenefitsOpp() {
		NAICS_Code__c code = new NAICS_Code__c();
		code.Name = '123456';
		code.NAICS_Title__c = 'Crop Production';
		insert code;

		Business_Unit__c bu = new Business_Unit__c(name = 'TEST');
		insert bu;

		Account account2 = TestFactory.createAccountClient('testAcct', false);
		account2.Status__c = 'Pending';
		account2.Business_Unit__c = bu.Id;
		account2.FEIN__c = '99-9999999';
		account2.NAICS__c = code.Name;
		account2.Verified__c = true;
		account2.Credit_Limit__c = 45;
		account2.EEO_Reporting__c = 'Yes';

		insert new List<Account>{ account2 };

		Opportunity opp2 = TestFactory.createOpportunity(
			'TestOpp',
			account2,
			System.today(),
			'Benefits Client Data Gathering',
			false
		);
		opp2.RecordTypeId = RecordTypeService.getId('Opportunity', 'Benefits');
		opp2.StageName = 'Contracting';
		opp2.Contract_Approval_Status__c = 'Approved';
		opp2.Credit_Approval_Status__c = 'Approved';
		opp2.OK_For_Risk_Approval_Status__c = 'Approved';
		opp2.AM_Approval_Status__c = 'Approved';
		opp2.Type = 'Co-Employment';
		opp2.Amount = 3.50;
		opp2.Admin_Factor__c = 1.0;
		opp2.Bucket__c = 3;
		opp2.Security_Deposit_Required__c = 'No';
		insert opp2;

		account2.Status__c = 'Active';
		account2.External_Id__c = '999999';

		update new List<Account>{ account2 };

		System.assertEquals(
			'Contracting',
			[SELECT StageName FROM Opportunity WHERE Id = :opp2.Id]
			.StageName,
			'Stage should not change'
		);
	}

	@IsTest
	static void test_ProspectOpp() {
		NAICS_Code__c code = new NAICS_Code__c();
		code.Name = '123456';
		code.NAICS_Title__c = 'Crop Production';
		insert code;

		Business_Unit__c bu = new Business_Unit__c(name = 'TEST');
		insert bu;

		Account account3 = TestFactory.createAccountProspect('testAcct', true);

		Opportunity opp3 = TestFactory.createOpportunity('TestOpp', account3, System.today(), 'Proposal', true);
		opp3.StageName = 'Contracting';
		opp3.Contract_Approval_Status__c = 'Approved';
		opp3.Credit_Approval_Status__c = 'Approved';
		opp3.OK_For_Risk_Approval_Status__c = 'Approved';
		opp3.AM_Approval_Status__c = 'Approved';
		opp3.Type = 'Co-Employment';
		opp3.Amount = 3.50;
		opp3.Admin_Factor__c = 1.0;
		opp3.Bucket__c = 3;
		opp3.Security_Deposit_Required__c = 'No';
		update opp3;

		account3.Status__c = 'Active';
		account3.External_Id__c = '903873';

		update new List<Account>{ account3 };

		System.assertNotEquals(
			'Closed Won',
			[SELECT StageName FROM Opportunity WHERE Id = :opp3.Id]
			.StageName,
			'StageName should not change'
		);
	}

	@IsTest
	static void test_ShellOpp() {
		NAICS_Code__c code = new NAICS_Code__c();
		code.Name = '123456';
		code.NAICS_Title__c = 'Crop Production';
		insert code;

		Business_Unit__c bu = new Business_Unit__c(name = 'TEST');
		insert bu;

		Account account4 = TestFactory.createAccountClient('testAcct', false);
		account4.Status__c = 'Pending';
		account4.Business_Unit__c = bu.Id;
		account4.FEIN__c = '99-9999999';
		account4.NAICS__c = code.Name;
		account4.Verified__c = true;
		account4.Credit_Limit__c = 45;
		account4.EEO_Reporting__c = 'Yes';

		insert new List<Account>{ account4 };

		Opportunity opp4 = TestFactory.createOpportunity('TestOpp', account4, System.today(), 'Proposal', false);
		opp4.RecordTypeId = RecordTypeService.getId('Opportunity', 'Creation of Shell');
		opp4.StageName = 'Contracting';
		opp4.Contract_Approval_Status__c = 'Approved';
		opp4.Credit_Approval_Status__c = 'Approved';
		opp4.OK_For_Risk_Approval_Status__c = 'Approved';
		opp4.AM_Approval_Status__c = 'Approved';
		opp4.Type = 'Co-Employment';
		opp4.Amount = 3.50;
		opp4.Admin_Factor__c = 1.0;
		opp4.Bucket__c = 3;
		opp4.Security_Deposit_Required__c = 'No';
		insert opp4;

		account4.Status__c = 'Active';
		account4.External_Id__c = '903873';

		update new List<Account>{ account4 };

		System.assertEquals(
			'Closed Won',
			[SELECT StageName FROM Opportunity WHERE Id = :opp4.Id]
			.StageName,
			'StageName should be Closed Won'
		);
	}
}