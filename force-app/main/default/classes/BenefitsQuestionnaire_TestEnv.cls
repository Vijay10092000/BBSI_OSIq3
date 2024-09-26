/**
 * @description BenefitsQuestionnaire_TestEnv creates a test environment for tesing
 * the Benefits_Discovery_Questionnaire__c object.
 */
@IsTest
@SuppressWarnings('PMD.ApexAssertionsShouldIncludeMessage, PMD.NcssConstructorCount')
public without sharing class BenefitsQuestionnaire_TestEnv {
	public Account branch;
	public Account prospect1;
	public Account prospect2;
	public Account prospect3;
	public Account prospect4;
	public Opportunity opp1;
	public Opportunity opp2;
	public Opportunity opp3;
	public Opportunity opp4;
	public User owner;
	public Contact contact1A;
	public Contact contact1B;
	public Contact contact1C;
	public Contact contact2A;
	public Contact contact3A;
	public Contact contact4A;

	/**
	 * @description BenefitsQuestionnaire_TestEnv constuctor.
	 */
	public BenefitsQuestionnaire_TestEnv() {
		branch = TestFactory.createAccountBranch('bbsiTESTBRANCH', '99999', '1000', true);
		owner = TestFactory.createUser(
			'bbsiTESTUSER',
			'testuser@bbsi.zzz',
			'testuser@bbsi.zzz',
			'BBSI Standard',
			'1000',
			true
		);

		System.runAs(owner) {
			prospect1 = TestFactory.createAccountProspect('TESTPROSPECT_1', false);
			prospect1.AnnualRevenue = 1234567;
			prospect2 = TestFactory.createAccountProspect('TESTPROSPECT_2', false);
			prospect2.AnnualRevenue = 1111111;
			prospect3 = TestFactory.createAccountProspect('TESTPROSPECTC', false);
			prospect3.AnnualRevenue = 2222222;
			prospect4 = TestFactory.createAccountProspect('TESTPROSPECTC', false);
			prospect4.AnnualRevenue = 2222222;
			insert new List<Account>{ prospect1, prospect2, prospect3, prospect4 };

			contact1A = TestFactory.createClientContact(prospect1, 'Contact1A', false);
			contact1B = TestFactory.createClientContact(prospect1, 'Contact1B', false);
			contact1C = TestFactory.createClientContact(prospect1, 'Contact1_3', false);
			contact2A = TestFactory.createClientContact(prospect2, 'Contact2A', false);
			contact3A = TestFactory.createClientContact(prospect3, 'Contact3A', false);
			contact4A = TestFactory.createClientContact(prospect3, 'Contact3A', false);
			insert new List<Contact>{ contact1A, contact1B, contact1C, contact2A, contact3A, contact4A };

			Date dateClose = Date.today().addDays(30);

			Id idOppType = RecordTypeService.getId('Opportunity', 'Benefits');
			opp1 = TestFactory.createOpportunity('TESTPROSPECT_1', prospect1, dateClose, 'Proposal', false);
			opp1.Amount = 10000;
			opp1.RecordTypeId = idOppType;
			opp2 = TestFactory.createOpportunity('TESTPROSPECT_2', prospect2, dateClose, 'Proposal', false);
			opp2.Amount = 10000;
			opp2.RecordTypeId = idOppType;
			opp3 = TestFactory.createOpportunity('TESTPROSPECT_3', prospect3, dateClose, 'Proposal', false);
			opp3.Amount = 10000;
			opp3.RecordTypeId = idOppType;
			opp4 = TestFactory.createOpportunity('TESTPROSPECT_3', prospect3, dateClose, 'Proposal', false);
			opp4.Amount = 10000;
			opp4.RecordTypeId = idOppType;
			insert new List<Opportunity>{ opp1, opp2, opp3, opp4 };

			Benefits_Discovery_Questionnaire__c bdq1 = new Benefits_Discovery_Questionnaire__c(
				OpportunityId__c = opp1.Id
			);
			Benefits_Discovery_Questionnaire__c bdq2 = new Benefits_Discovery_Questionnaire__c(
				OpportunityId__c = opp2.Id
			);
			Benefits_Discovery_Questionnaire__c bdq3 = new Benefits_Discovery_Questionnaire__c(
				OpportunityId__c = opp3.Id
			);
			insert (new List<Benefits_Discovery_Questionnaire__c>{ bdq1, bdq2, bdq3 });
		}

		OpportunityContactRole role1 = TestFactory.createOpportunityContactRole(
			contact1A.Id,
			opp1.Id,
			true,
			OpportunityContactRole_Service.BENEFITS_CONTACT,
			false
		);
		OpportunityContactRole role2 = TestFactory.createOpportunityContactRole(
			contact1A.Id,
			opp1.Id,
			true,
			OpportunityContactRole_Service.DECISION_MAKER,
			false
		);
		OpportunityContactRole role3 = TestFactory.createOpportunityContactRole(
			contact1B.Id,
			opp1.Id,
			false,
			OpportunityContactRole_Service.BENEFITS_CONTACT,
			false
		);
		OpportunityContactRole role4 = TestFactory.createOpportunityContactRole(
			contact1C.Id,
			opp1.Id,
			false,
			OpportunityContactRole_Service.DECISION_MAKER,
			false
		);
		OpportunityContactRole role5 = TestFactory.createOpportunityContactRole(
			contact2A.Id,
			opp2.Id,
			true,
			OpportunityContactRole_Service.EXECUTIVE_SPONSOR,
			false
		);
		insert new List<OpportunityContactRole>{ role1, role2, role3, role4, role5 };
	}
}