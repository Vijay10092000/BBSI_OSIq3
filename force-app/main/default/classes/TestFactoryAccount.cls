/**
 * @description TestFactoryAccount contains methods to create test Accounts.
 */
@IsTest
public without sharing class TestFactoryAccount {
	/**
	 * @description createAccount creates a new Account record in the database.
	 * @param  recordType 	Record Type name for the Account
	 * @param  fldMap 		additional field values for the Account
	 * @return Account
	 */
	public static Account createAccount(String recordType, Map<String, Object> fldMap) {
		Account account = makeAccount(recordType, fldMap);
		insert account;
		return account;
	}

	/**
	 * @description makeAccount makes an Account record.
	 * @param  recordType 	Record Type name for the Account
	 * @param  fldMap 		additional field values for the Account
	 * @return Account
	 */
	public static Account makeAccount(String recordType, Map<String, Object> fldMap) {
		Account a = new Account(
			External_Id__c = TestFactory.nextExternalId(),
			FEIN__c = TestFactory.nextFein(),
			Status__c = 'ACTIVE'
		);
		if(String.isNotBlank(recordType)){
			Id idrtCase = RecordTypeService.getId('Account', recordType);
			a.RecordTypeId = idrtCase;
		}         
        if (fldMap != null) {
			a = (Account) TestFactory.assignFields(fldMap, a);
		}
		return a;
	}
	/**
	 * @description createAccount creates a new Account record in the database.
	 * @param  name       Name of the Account
	 * @param  recordType Record Type name for the Account
	 * @return Account
	 */
	public static Account createAccount(String name, String recordType) {
		Account account = makeAccount(name, recordType);
		insert account;
		return account;
	}

	/**
	 * @description makeAccount makes an Account record.
	 * @param  name       Name of the Account
	 * @param  recordType Record Type name for the Account
	 * @return Account
	 */
	public static Account makeAccount(String name, String recordType) {
		Id idrtAccount = RecordTypeService.getId('Account', recordType);

		Account a = new Account(
			Name = name,
			RecordTypeId = idrtAccount,
			External_Id__c = TestFactory.nextExternalId(),
			// Set default Addresses
			BillingStreet = '8100 NE Parkway Drive',
			BillingCity = 'Vancouver',
			BillingState = 'WA',
			BillingCountry = 'US',
			BillingPostalCode = '98662',
			ShippingStreet = '8100 NE Parkway Drive',
			ShippingCity = 'Vancouver',
			ShippingState = 'WA',
			ShippingCountry = 'US',
			ShippingPostalCode = '98662',
			Branch_Manager__c = name,
			Client_Benefits_Renewal_Month__c = 'June',
			// Default the required fields for an Opportunity to close
			Customer_Class__c = '2',
			EEO_Reporting__c = 'Yes',
			FEIN__c = TestFactory.nextFein(),
			Safety_Incentive__c = 'Yes',
			X_Mod__c = '118',
			Credit_Limit__c = 250000.00,
			NumberOFEmployees = 51,
			Annual_Payroll__c = 500000.00,
			Main_Payroll_Frequency__c = 'Weekly',
			Verified__c = true,
			Price_Info__c = '1-CA.0042--20.47\n2-CA.1000--8.50\n3-CA.8742--12.02\n4-CA.8810--11.49\n5-CA.9008--29.77\n6-CA.9009--20.79\n7-CA.8810-MODDUTY-0.00\n7-CA.8810-MODDAYS-0.00\n8-CA.9009-MODDUTY-0.00\n8-CA.9009-MODDAYS-0.00\n9-CA.1000-ERHSA-0.85\n10-CA.1000-ERMED-0.00',
			Safety_Incentive_Info__c = '1000 - 0.0\n8742 - 0.0\n8810 - 0.0\n9008 - 4.0\n9009 - 2.51',
			// Other default data
			Status__c = 'Active'
		);

		return a;
	}

	/**
	 * @description createBranch creates a Branch Account record in the database.
	 * @param  name  Name of the Branch

	 * @return Branch Account
	 */
	public static Account createBranch(String name) {
		Account account = makeBranch(name, testFactory.nextBranchNumber(), null, null);
		insert account;
		return account;
	}

	/**
	 * @description makeBranch creates a Branch Account object.
	 * @param  name  Name of the Branch

	 * @return Branch Account
	 */
	public static Account makeBranch(String name) {
		return makeBranch(name, testFactory.nextBranchNumber(), null, null);
	}

	/**
	 * @description createBranch creates a Branch Account record in the database.
	 * @param  name              Name of the Branch
	 * @param  branchNumber      Unique branch number
	 * @param  areaManager       Name of the Area Manager - may be null
	 * @param  areaManagerEmail  Email of the Area Manager - may be null
	 * @return Branch Account
	 */
	public static Account createBranch(String name, String branchNumber, String areaManager, String areaManagerEmail) {
		Account account = makeBranch(name, branchNumber, areaManager, areaManagerEmail);
		insert account;
		return account;
	}

	/**
	 * @description makeBranch makes a Branch Account object.
	 * @param  name              Name of the Branch
	 * @param  branchNumber      Unique branch number
	 * @param  areaManager       Name of the Area Manager - may be null
	 * @param  areaManagerEmail  Email of the Area Manager - may be null
	 * @return Branch Account
	 */
	public static Account makeBranch(String name, String branchNumber, String areaManager, String areaManagerEmail) {
		Account account = makeAccount(name, 'BBSI Branch');
		if(String.isNotEmpty(branchNumber)){
			account.External_Id__c = branchNumber;
		}
		account.Branch_Manager__c = areaManager;
		account.Branch_Manager_Email__c = areaManagerEmail;

		return account;
	}

	/**
	 * @description createProspect creates a Prospect Account record in the database.
	 * @param  name               Name of the Prospect
	 * @param  idReferralPartner  ReferralPartner (Account) identifier - may be null
	 * @param  idProducer         Producer (Contact) identifier - may be null
	 * @return Prospect Account
	 */
	public static Account createProspect(String name, Id idReferralPartner, Id idProducer) {
		Account account = makeProspect(name, idReferralPartner, idProducer);
		insert account;
		return account;
	}

	/**
	 * @description makeProspect makes a Prospect Account object.
	 * @param  name               Name of the Prospect
	 * @param  idReferralPartner  ReferralPartner (Account) identifier - may be null
	 * @param  idProducer         Producer (Contact) identifier - may be null
	 * @return Prospect Account
	 */
	public static Account makeProspect(String name, Id idReferralPartner, Id idProducer) {
		Account account = makeAccount(name, 'Prospect');

		account.Assigned_Referral_Partner__c = idReferralPartner;
		account.Producer__c = idProducer;

		return account;
	}

	/**
	 * @description createProspect creates a Prospect Account record in the database.
	 * @param  name  Name of the Prospect
	 * @return Prospect Account
	 */
	public static Account createProspect(String name) {
		return makeProspect(name);
	}

	/**
	 * @description makeProspect makes a Prospect Account object.
	 * @param  name  Name of the Prospect
	 * @return Prospect Account
	 */
	public static Account makeProspect(String name) {
		return makeAccount(name, 'Prospect');
	}

	/**
	 * @description createClient creates a Client Account record in the database.
	 * @param  name  Name of the Client
	 * @return Client Account
	 */
	public static Account createClient(String name) {
		return makeClient(name);
	}

	/**
	 * @description makeClient makes a Client Account object.
	 * @param  name  Name of the Client
	 * @return Client Account
	 */
	public static Account makeClient(String name) {
		return makeAccount(name, 'Client');
	}

	/**
	 * @description createClient creates a Client Account record in the database.
	 * @param  name               Name of the Client
	 * @param  idReferralPartner  ReferralPartner (Account) identifier - may be null
	 * @param  idProducer         Producer (Contact) identifier - may be null
	 * @return Client Account
	 */
	public static Account createClient(String name, Id idReferralPartner, Id idProducer) {
		Account account = makeClient(name, idReferralPartner, idProducer);
		insert account;
		return account;
	}

	/**
	 * @description makeClient makes a Client Account object.
	 * @param  name               Name of the Client
	 * @param  idReferralPartner  ReferralPartner (Account) identifier - may be null
	 * @param  idProducer         Producer (Contact) identifier - may be null
	 * @return Client Account
	 */
	public static Account makeClient(String name, Id idReferralPartner, Id idProducer) {
		Account account = makeAccount(name, 'Client');

		account.Assigned_Referral_Partner__c = idReferralPartner;
		account.Producer__c = idProducer;

		return account;
	}

	/**
	 * @description createClient creates a Client Account record in the database.
	 * @param  name               Name of the Client
	 * @param  idReferralPartner  ReferralPartner (Account) identifier - may be null
	 * @param  idProducer         Producer (Contact) identifier - may be null
	 * @param  commType           Commission type
	 * @param  commRate           Commission rate
	 * @return Client Account
	 */
	public static Account createClient(
		String name,
		Id idReferralPartner,
		Id idProducer,
		String commType,
		Decimal commRate
	) {
		Account account = makeClient(name, idReferralPartner, idProducer, commType, commRate);
		insert account;
		return account;
	}

	/**
	 * @description createClient makes a Client Account object.
	 * @param  name               Name of the Client
	 * @param  idReferralPartner  ReferralPartner (Account) identifier - may be null
	 * @param  idProducer         Producer (Contact) identifier - may be null
	 * @param  commType           Commission type
	 * @param  commRate           Commission rate
	 * @return Client Account
	 */
	public static Account makeClient(
		String name,
		Id idReferralPartner,
		Id idProducer,
		String commType,
		Decimal commRate
	) {
		Account account = makeClient(name, idReferralPartner, idProducer);

		account.Commission_Type__c = commType;
		account.Commission_Rate__c = commRate;

		return account;
	}

	/**
	 * @description createReferralPartner creates a Referral Partner Account record in the database.
	 * @param  name       Name of the Referral Partner
	 * @param  commType   Commission type
	 * @param  commRate   Commission rate
	 * @param  idRpGroup  Referral Partner Group identifier - may be null
	 * @return Referral Partner Account
	 */
	public static Account createReferralPartner(String name, String commType, Decimal commRate, Id idRpGroup) {
		Account account = makeReferralPartner(name, commType, commRate, idRpGroup);
		insert account;
		return account;
	}

	/**
	 * @description makeReferralPartner makes a Referral Partner Account object.
	 * @param  name       Name of the Referral Partner
	 * @param  commType   Commission type
	 * @param  commRate   Commission rate
	 * @param  idRpGroup  Referral Partner Group identifier - may be null
	 * @return Referral Partner Account
	 */
	public static Account makeReferralPartner(String name, String commType, Decimal commRate, Id idRpGroup) {
		Account account = makeAccount(name, 'Referral Partner');

		account.Referral_Partner_Status__c = 'Active';
		account.Commission_Type__c = commType;
		account.Commission_Rate__c = commRate;
		account.Referral_Partner_Group__c = idRpGroup;

		return account;
	}

	/**
	 * @description createTerminated creates a terminated Client Account record in the database.
	 * @param  name               Name of the Terminated Client
	 * @param  idReferralPartner  ReferralPartner (Account) identifier - may be null
	 * @param  idProducer         Producer (Contact) identifier - may be null
	 * @return Terminated Account
	 */
	public static Account createTerminated(String name, Id idReferralPartner, Id idProducer) {
		Account account = makeTerminated(name, idReferralPartner, idProducer);
		insert account;
		return account;
	}

	/**
	 * @description makeTerminated makes a terminated Client Account object.
	 * @param  name               Name of the Terminated Client
	 * @param  idReferralPartner  ReferralPartner (Account) identifier - may be null
	 * @param  idProducer         Producer (Contact) identifier - may be null
	 * @return Terminated Account
	 */
	public static Account makeTerminated(String name, Id idReferralPartner, Id idProducer) {
		Account account = makeAccount(name, 'Terminated');

		account.Assigned_Referral_Partner__c = idReferralPartner;
		account.Producer__c = idProducer;

		return account;
	}

	/**
	 * @description createReferralPartner creates a Referral Partner Account record in the database.
	 * @param  name       Name of the Referral Partner
	 * @param  commType   Commission type
	 * @param  commRate   Commission rate
	 * @param  idRpGroup  Referral Partner Group identifier - may be null
	 * @return Referral Partner Account
	 */
	public static Account createReferralPartner(String name) {
		Account account = makeReferralPartner(name);
		insert account;
		return account;
	}

	/**
	 * @description makeReferralPartner makes a Referral Partner Account object.
	 * @param  name       Name of the Referral Partner
	 * @param  commType   Commission type
	 * @param  commRate   Commission rate
	 * @param  idRpGroup  Referral Partner Group identifier - may be null
	 * @return Referral Partner Account
	 */
	public static Account makeReferralPartner(String name) {
		Account account = makeAccount(name, 'Referral Partner');

		account.Referral_Partner_Status__c = 'Active';
		account.Commission_Type__c = '% of Margin';
		account.Commission_Rate__c = 5.0;

		return account;
	}    
}