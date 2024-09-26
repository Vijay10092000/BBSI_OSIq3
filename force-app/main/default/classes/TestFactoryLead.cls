/**
 * @description TestFactoryLead contains methods to create test Leads.
 */
@IsTest
@SuppressWarnings('PMD.ExcessiveParameterList')
public without sharing class TestFactoryLead {
	private static final String LEAD_CLIENT = 'Client_Lead';
	private static final String LEAD_REFERRAL_PARTNER = 'Referral_Partner_Lead';

	/**
	 * @description makeLead makes a Lead object.
	 * @param  firstName  First Name of Lead
	 * @param  lastName   Last Name of Lead
	 * @param  company    Company of Lead
	 * @param  recordType Record Type name
	 * @param  idBranch   Branch identifier
	 * @param  idBdm      Bdm identifier
	 * @return Lead
	 */
	private static Lead makeLead(
		String firstName,
		String lastName,
		String company,
		String recordType,
		Id idBranch,
		Id idBdm
	) {
		Lead l = new Lead(
			Status = 'Assigned',
			Lead_Stage__c = 'Pending',
			FirstName = firstName,
			LastName = lastName,
			Company = company,
			Branch__c = idBranch,
			Business_Development_Manager__c = idBdm,
			Phone = TestFactory.nextPhoneNumber()
		);
		if(String.isNotBlank(recordType)){
			l.RecordTypeId = RecordTypeService.getId('Lead', recordType);
		}
		return l;
	}

	/**
	 * @description createClientLead creates a Lead record in the database.
	 * @param  firstName  First Name of Lead
	 * @param  lastName   Last Name of Lead
	 * @param  company    Company of Lead
	 * @param  idBranch   Branch identifier
	 * @param  idBdm      Bdm identifier
	 * @return Lead
	 */
	public static Lead createClientLead(
		String firstName,
		String lastName,
		String company,
		Id idBranch,
		Id idBdm
	) {
		Lead lead = makeClientLead(firstName, lastName, company, idBranch, idBdm);

		insert lead;

		return lead;
	}

	/**
	 * @description makeClientLead makes a Lead object.
	 * @param  firstName  First Name of Lead
	 * @param  lastName   Last Name of Lead
	 * @param  company    Company of Lead
	 * @param  idBranch   Branch identifier
	 * @param  idBdm      Bdm identifier
	 * @return Lead
	 */
	public static Lead makeClientLead(
		String firstName,
		String lastName,
		String company,
		Id idBranch,
		Id idBdm
	) {
		return makeLead(firstName, lastName, company, LEAD_CLIENT, idBranch, idBdm);
	}

	/**
	 * @description createRP creates a Lead record in the database.
	 * @param  firstName  First Name of Lead
	 * @param  lastName   Last Name of Lead
	 * @param  company    Company of Lead
	 * @return Lead
	 */
	public static Lead createLeadRP(
		String firstName,
		String lastName,
		String company
	) {
		return makeLeadRP(firstName, lastName, company);
	}

	/**
	 * @description makeLeadRP makes a Lead object.
	 * @param  firstName  First Name of Lead
	 * @param  lastName   Last Name of Lead
	 * @param  company    Company of Lead
	 * @return Lead
	 */
	public static Lead makeLeadRP(
		String firstName,
		String lastName,
		String company
	) {
		Lead l = makeLead(firstName, lastName, company, LEAD_REFERRAL_PARTNER, null, null);
		l.Referral_Partner_Type__c = 'Other';
		
		return l;
	}
}