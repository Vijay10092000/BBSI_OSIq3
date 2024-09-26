/**
 * @description TestFactoryOpportunity contains methods to create test Opportunities.
 */
@IsTest
public without sharing class TestFactoryOpportunity {
	/**
	 * @description createClient creates an Opportunity record in the database.
	 * @param  name      Name of the Opportunity
	 * @param  idAccount Account identifier
	 * @param  closeDate Date closes
	 * @param  stage     Current stage
	 * @return Opportunity
	 */
	public static Opportunity createClient(String name, Id idAccount, Date closeDate, String stage) {
		Opportunity opp = makeClient(name, idAccount, closeDate, stage);
		insert opp;
		return opp;
	}

	/**
	 * @description makeClient makes a Client Opportunity record.
	 * @param  name      Name of the Opportunity
	 * @param  idAccount Account identifier
	 * @param  closeDate Date closes
	 * @param  stage     Current stage
	 * @return Opportunity
	 */
	public static Opportunity makeClient(String name, Id idAccount, Date closeDate, String stage) {
		Opportunity opp = new Opportunity(
			RecordTypeId = RecordTypeService.getId('Opportunity', 'Client'),
			Name = name,
			AccountId = idAccount,
			CloseDate = closeDate,
			StageName = stage,
			Security_Deposit_Required__c = 'No'
		);

		return opp;
	}

	/**
	 * @description createBenefits creates a Benefits Opportunity record in the database.
	 * @param  name      Name of the Opportunity
	 * @param  idAccount Account identifier
	 * @param  closeDate Date closes
	 * @param  stage     Current stage
	 * @return Opportunity
	 */
	public static Opportunity createBenefits(String name, Id idAccount, Date closeDate, String stage) {
		Opportunity opp = makeBenefits(name, idAccount, closeDate, stage);
		insert opp;
		return opp;
	}

	/**
	 * @description makeBenefits makes a Benefits Opportunity record.
	 * @param  name      Name of the Opportunity
	 * @param  idAccount Account identifier
	 * @param  closeDate Date closes
	 * @param  stage     Current stage
	 * @return Opportunity
	 */
	public static Opportunity makeBenefits(String name, Id idAccount, Date closeDate, String stage) {
		Opportunity opp = new Opportunity(
			RecordTypeId = RecordTypeService.getId('Opportunity', 'Benefits'),
			StageName = stage,
			Name = name,
			AccountId = idAccount,
			CloseDate = closeDate,
			Is_there_a_benefits_referral_partner__c = 'No',
			Security_Deposit_Required__c = 'No'
		);

		return opp;
	}

	/**
	 * @description createBenefits creates a Benefits Opportunity record in the database.
	 * @param  name          Name of the Opportunity
	 * @param  idAccount     Account identifier
	 * @param  idOwner       Who should own the Opportunity
	 * @param  idSpecialist  Specialist
	 * @param  closeDate     Date closes
	 * @param  stage         Current stage
	 * @return Opportunity
	 */
	public static Opportunity createBenefits(String name, Id idAccount, Id idSpecialist, Date closeDate, String stage) {
		Opportunity opp = makeBenefits(name, idAccount, idSpecialist, closeDate, stage);
		insert opp;
		return opp;
	}

	/**
	 * @description makeBenefits makes a Benefits Opportunity record.
	 * @param  name          Name of the Opportunity
	 * @param  idAccount     Account identifier
	 * @param  idOwner       Who should own the Opportunity
	 * @param  idSpecialist  Specialist
	 * @param  closeDate     Date closes
	 * @param  stage         Current stage
	 * @return Opportunity
	 */
	public static Opportunity makeBenefits(String name, Id idAccount, Id idSpecialist, Date closeDate, String stage) {
		Opportunity opp = new Opportunity(
			RecordTypeId = RecordTypeService.getId('Opportunity', 'Benefits'),
			StageName = stage,
			OwnerId = idSpecialist,
			Benefits_Specialist__c = idSpecialist,
			Name = name,
			AccountId = idAccount,
			CloseDate = closeDate,
			Security_Deposit_Required__c = 'No'
		);

		return opp;
	}

	/**
	 * @description createAdditionalProducts creates an Additional Products Opportunity record in the database.
	 * @param  name      Name of the Opportunity
	 * @param  idAccount Account identifier
	 * @param  closeDate Date closes
	 * @param  stage     Current stage
	 * @return Opportunity
	 */
	public static Opportunity createAdditionalProducts(String name, Id idAccount, Date closeDate, String stage) {
		Opportunity opp = makeAdditionalProducts(name, idAccount, closeDate, stage);
		insert opp;
		return opp;
	}

	/**
	 * @description makeAdditionalProducts makes a Additional Products Opportunity record.
	 * @param  name      Name of the Opportunity
	 * @param  idAccount Account identifier
	 * @param  closeDate Date closes
	 * @param  stage     Current stage
	 * @return Opportunity
	 */
	public static Opportunity makeAdditionalProducts(String name, Id idAccount, Date closeDate, String stage) {
		Opportunity opp = new Opportunity(
			RecordTypeId = RecordTypeService.getId('Opportunity', 'Additional Products'),
			StageName = stage,
			Name = name,
			AccountId = idAccount,
			CloseDate = closeDate,
			Security_Deposit_Required__c = 'No'
		);

		return opp;
	}

	/**
	 * @description createContactRole creates an OpportunityContactRole record in the database.
	 * @param  idContact     Related Contact
	 * @param  idOpportunity Related Opportunity
	 * @param  isPrimary     Is Contact the primay
	 * @param  role          What role does Contact have
	 * @return OpportunityContactRole
	 */
	public static OpportunityContactRole createContactRole(
		Id idContact,
		Id idOpportunity,
		Boolean isPrimary,
		String role
	) {
		OpportunityContactRole oppRole = makeContactRole(idContact, idOpportunity, isPrimary, role);
		insert oppRole;
		return oppRole;
	}

	/**
	 * @description makeContactRole makes an OpportunityContactRole object.
	 * @param  idContact     Related Contact
	 * @param  idOpportunity Related Opportunity
	 * @param  isPrimary     Is Contact the primay
	 * @param  role          What role does Contact have
	 * @return OpportunityContactRole
	 */
	public static OpportunityContactRole makeContactRole(
		Id idContact,
		Id idOpportunity,
		Boolean isPrimary,
		String role
	) {
		OpportunityContactRole template = new OpportunityContactRole(
			ContactId = idContact,
			OpportunityId = IdOpportunity,
			IsPrimary = isPrimary,
			Role = role
		);

		return template;
	}

	/**
	 * @description createShell creates a Creation of Shell Opportunity record in the database.
	 * @param  name      Name of the Opportunity
	 * @param  idAccount Account identifier
	 * @param  closeDate Date closes
	 * @param  stage     Current stage
	 * @return Opportunity
	 */
	public static Opportunity createShell(String name, Id idAccount, Date closeDate, String stage) {
		Opportunity opp = makeShell(name, idAccount, closeDate, stage);
		insert opp;
		return opp;
	}

	/**
	 * @description makeShell makes a Creation of Shell Opportunity record.
	 * @param  name      Name of the Opportunity
	 * @param  idAccount Account identifier
	 * @param  closeDate Date closes
	 * @param  stage     Current stage
	 * @return Opportunity
	 */
	public static Opportunity makeShell(String name, Id idAccount, Date closeDate, String stage) {
		Opportunity opp = new Opportunity(
			RecordTypeId = RecordTypeService.getId('Opportunity', 'Creation of Shell'),
			Name = name,
			AccountId = idAccount,
			CloseDate = closeDate,
			StageName = stage,
			Contract_Approval_Status__c = 'Approved',
			Credit_Approval_Status__c = 'Approved',
			OK_For_Risk_Approval_Status__c = 'Approved',
			AM_Approval_Status__c = 'Approved',
			Type = 'Co-Employment',
			Amount = 3.50,
			Admin_Factor__c = 1.0,
			Bucket__c = 3,
			Security_Deposit_Required__c = 'No'
		);

		return opp;
	}


	/**
	 * @description createBenefitsRenewal creates a Benefits Renewal Opportunity record in the database.
	 * @param  name          Name of the Opportunity
	 * @param  idAccount     Account identifier
	 * @param  closeDate     Date closes
	 * @param  idOwner       Who should own the Opportunity
	 * @param  stage         Current stage
	 * @param  fldMap        Additional fields to set on Opportunity
	 * @return Opportunity
	 */
	public static Opportunity createBenefitsRenewal(String name, Id idAccount, Date closeDate, String stage, Map<String,Object> fldMap) {
		Opportunity opp = makeBenefitsRenewal(name, idAccount, closeDate, stage, fldMap);
		insert opp;
		return opp;
	}

	/**
	 * @description makeBenefitsRenewal creates a Benefits Renewal Opportunity record in the database.
	 * @param  name          Name of the Opportunity
	 * @param  idAccount     Account identifier
	 * @param  closeDate     Date closes
	 * @param  idOwner       Who should own the Opportunity
	 * @param  stage         Current stage
	 * @param  fldMap        Additional fields to set on Opportunity
	 * @return Opportunity
	 */
	public static Opportunity makeBenefitsRenewal(String name, Id idAccount, Date closeDate, String stage, Map<String,Object> fldMap) {
		Opportunity opp = new Opportunity(
			RecordTypeId = OpportunityBenefits_Service.BenefitsRenewalRT,
			Name = name,
			AccountId = idAccount,
			CloseDate = closeDate,
			StageName = stage,
			Security_Deposit_Required__c = 'No'
		);

		if (fldMap != null) {
            opp = (Opportunity) TestFactory.assignFields(fldMap, opp);
        }

		return opp;
	}

	/**
	 * @description createBenefitsRenewal creates a Benefits Renewal Opportunity record in the database.
	 * @param  name          Name of the Opportunity
	 * @param  idAccount     Account identifier
	 * @param  closeDate     Date closes
	 * @param  idOwner       Who should own the Opportunity
	 * @param  stage         Current stage
	 * @return Opportunity
	 */
	public static Opportunity createBenefitsRenewal(String name, Id idAccount, Date closeDate, String stage) {
		return createBenefitsRenewal(name, idAccount, closeDate, stage, null);
	}

	/**
	 * @description makeBenefitsRenewal creates a Benefits Renewal Opportunity record in the database.
	 * @param  name          Name of the Opportunity
	 * @param  idAccount     Account identifier
	 * @param  closeDate     Date closes
	 * @param  idOwner       Who should own the Opportunity
	 * @param  stage         Current stage
	 * @return Opportunity
	 */
	public static Opportunity makeBenefitsRenewal(String name, Id idAccount, Date closeDate, String stage) {
		return makeBenefitsRenewal(name, idAccount, closeDate, stage, null);
	}
}