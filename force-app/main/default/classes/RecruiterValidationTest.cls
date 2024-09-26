/**
 * @description RecruiterValidationTest contains tests for the RecruiterValidation class.
 */
@IsTest
@SuppressWarnings('PMD.ApexAssertionsShouldIncludeMessage')
public with sharing class RecruiterValidationTest {
	@TestSetup
	static void makeData() {
		User u = TestFactory.createUser('Approver', 'test123@bbsihq.zzz', 'test123@bbsihq.zzz', 'System Administrator', '910', true);

		Group g = new Group(
			Name = 'Executives'
		);
		insert g;

		GroupMember gm = new GroupMember(
			GroupId = g.Id,
			UserOrGroupId = u.Id
		);
		insert gm;
	}

	@IsTest
	static void test_positiveValidation() {
		User user = [SELECT Id FROM User WHERE Email = 'test123@bbsihq.zzz'];

		Schema.DescribeFieldResult fieldResult = Position__c.Recruiter__c.getDescribe();
   		List<Schema.PicklistEntry> ple = fieldResult.getPicklistValues();
   		List<String> recuiter = new List<String>();

		for (Schema.PicklistEntry f : ple) {
 			if (f.getLabel() != 'External') {
 				recuiter.add(f.getLabel());
 			}
   		}

        List<String> name = new List<String>();

        for(String s : recuiter.get(0).split(' ')) {
            name.add(s);
        }

        Contact c = new Contact(
        	FirstName = name.get(0),
        	LastName = name.get(1),
        	Email = 'test@test.com'
		);
        insert c;

		System.runAs(user) {
			Account branch = TestFactory.createAccount('!!TEST Branch', '98682', 'BBSI Branch', true);

			Position__c position = new Position__c(
				Branch__c = branch.Id,
				Type__c = 'New',
				Hours_Per_Week__c = 5,
				Est_Annual_Salary__c = 45,
				Reason_For_New_Hire__c = 'Test Reason',
				Position__c = 'Exempt',
				Recruiter__c = ''
			);
			insert position;

			position.Recruiter__c = recuiter.get(0);
            position.Recruiter_Change_Date__c = System.today();
			update position;

			System.assertEquals([SELECT Recruiter__c FROM Position__c WHERE Id = :position.Id].Recruiter__c, recuiter.get(0));
		}
	}

	@IsTest
	static void test_negativeValidation() {
		User user = TestFactory.createUser('Not Approver', 'test124@bbsihq.com', 'test124@bbsihq.com', 'Area Manager', '910', true);

		Schema.DescribeFieldResult fieldResult = Position__c.Recruiter__c.getDescribe();
   		List<Schema.PicklistEntry> ple = fieldResult.getPicklistValues();
   		String recuiter;

		for (Schema.PicklistEntry f : ple) {
 			if (f.getLabel() != 'External') {
 				recuiter = f.getLabel();
 			}
   		}

		System.runAs(user) {
			Account branch = TestFactory.createAccount('!!TEST Branch', '98682', 'BBSI Branch', true);
			Position__c position = new Position__c(
				Branch__c = Branch.Id,
				Type__c = 'New',
				Hours_Per_Week__c = 5,
				Est_Annual_Salary__c = 45,
				Reason_For_New_Hire__c = 'Test Reason',
				Position__c = 'Exempt',
				Recruiter__c = ''
			);
			insert position;

			try {
				position.Recruiter__c = recuiter;
				update position;
			} catch(DmlException e) {
				System.assert(e.getMessage().containsAny('Insert Error Message Here'));
			}

			System.assertNotEquals(recuiter, [SELECT Recruiter__c FROM Position__c WHERE Id =: position.Id].Recruiter__c);
		}
	}
}