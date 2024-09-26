/**
 * @descriptin possibleMatches_Test contains tests for the possibleMatches class.
 */
@IsTest
public with sharing class possibleMatches_Test {
	@IsTest
	public static void test_Constructor() {
		possibleMatches match = new possibleMatches();
		
		Assert.isFalse(match.CompanyMatch);
		Assert.isFalse(match.DBAMatch);
		Assert.isFalse(match.FEINMatch);
		Assert.isFalse(match.NameMatch);
	}

	@IsTest
	public static void test_Comparable() {
		Account branch = TestFactoryAccount.createBranch('TEST BRANCH');
		User user1 = TestFactoryUser.createUser('TEST', 'User', 'BBSI Standard', branch.External_Id__c);
		Account client1 = TestFactoryAccount.makeClient('CLIENT 1', null, null);
		Account client2 = TestFactoryAccount.makeClient('CLIENT 2', null, null);
		Account client3 = TestFactoryAccount.makeClient('CLIENT 3', null, null);
		Account client4 = TestFactoryAccount.makeClient('CLIENT 4', null, null);
		insert new List<Account>{ client1, client2, client3, client4 };

		List<Id> idClients = new List<Id>{ client1.Id, client2.Id, client3.Id, client4.Id };

		List<Account> accounts =
		[
			SELECT Id, Name, OwnerId, Owner.Name, Owner.FirstName, Owner.LastName, DBA_Name__c, Phone, RecordType.Name, FEIN__c, CreatedDate,
			Prospect_Branch__c, Prospect_Branch__r.Name, Prospect_Branch__r.Id, BillingStreet
			FROM Account
			WHERE Id IN :idClients
			AND RecordType.Name = 'Client'
			ORDER BY Name ASC
		];
		
		possibleMatches pm1 = createPossibleMatches(accounts.get(0), 3);
		pm1.FEINMatch = true;
		pm1.CompanyMatch = true;
		pm1.DBAMatch = true;
		pm1.NameMatch = true;
		possibleMatches pm2 = createPossibleMatches(accounts.get(1), 3);
		pm2.FEINMatch = true;
		pm2.CompanyMatch = false;
		pm2.DBAMatch = true;
		pm2.NameMatch = true;
		possibleMatches pm3 = createPossibleMatches(accounts.get(2), 4);
		pm3.FEINMatch = false;
		pm3.CompanyMatch = true;
		pm3.DBAMatch = true;
		pm3.NameMatch = false;
		possibleMatches pm4 = createPossibleMatches(accounts.get(3), 7);
		pm4.FEINMatch = false;
		pm4.CompanyMatch = true;
		pm4.DBAMatch = false;
		pm4.NameMatch = true;

		Assert.areEqual(4, pm1.matchcount);
		Assert.areEqual(3, pm2.matchcount);
		Assert.areEqual(2, pm3.matchcount);
		Assert.areEqual(2, pm4.matchcount);

		Assert.areEqual(0, pm1.compareTo(pm1), 'Same possibleMatch returns 0');

		Assert.areEqual(-1, pm1.compareTo(pm2), 'FEIN Matches on both');
		Assert.areEqual(-1, pm1.compareTo(pm3), 'FEIN Matches on both');
		Assert.areEqual(-1, pm1.compareTo(pm4), 'MatchCounts are different');

		Assert.areEqual(-1, pm2.compareTo(pm3), 'FEIN Matches on both');
		Assert.areEqual(-1, pm2.compareTo(pm4), 'FEIN Matches on both');

		Assert.areEqual(-1, pm3.compareTo(pm4), 'MatchCounts are different');		
	}
	
	private static possibleMatches createPossibleMatches(Account a, Decimal distance) {
		possibleMatches m = new possibleMatches();
		
		m.SmallestDistance = distance;
		m.recordId = (Id) a.get('Id');

		m.OwnerId = (String) a.get('OwnerId');
		m.OwnerName = a.getsObject('Owner') != null ? (String) a.getsObject('Owner').get('Name') : '';
		m.owner.Id = (Id) a.get('OwnerId');
		m.owner.FirstName = a.getsObject('Owner') != null ? (String) a.getsObject('Owner').get('FirstName') : '';
		m.owner.LastName = a.getsObject('Owner') != null ? (String) a.getsObject('Owner').get('LastName') : '';

		m.DBAName = (String) a.get('DBA_Name__c');
		m.phone = (String) a.get('Phone');
		m.RecordType = (String) a.getSObject('RecordType').get('Name');
		m.createdDate = (DateTime) a.get('CreatedDate');
		m.FEIN = (String) a.get('FEIN__c');

		m.Company = (String) a.get('Name');
		m.CompanyId = (String) a.get('Id');
		m.branch = a.getSObject('Prospect_Branch__r') != null ? (Account) a.getSObject('Prospect_Branch__r') : null;
		m.branchName = a.getSObject('Prospect_Branch__r') != null ? (String) a.getSObject('Prospect_Branch__r').get('Name') : null;
		m.branchId = a.getSObject('Prospect_Branch__r') != null ? (String) a.getSObject('Prospect_Branch__r').get('Id') : null;
		m.Street = (String) (a.get('BillingStreet'));

		return m;
	}
}