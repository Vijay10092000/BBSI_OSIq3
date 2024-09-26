/**
 * @description LeadCloneValidator validates the Lead fields for the Clone Lead button.
 * @see
 *   Azure User Story: 49526 Clone Lead Button (https://bbsi.visualstudio.com/Business%20IT%20Sales%20and%20Marketing%20Solutions/_workitems/edit/49526)
 */
public with sharing class LeadCloneValidator {
	@TestVisible
	private static final String ERROR_NO_LEADS = 'No leads given';

	@TestVisible
	private static final String ERROR_BAD_RECORDTYPE = 'Invalid Record Type on Lead.';
	
	@TestVisible
	private static final String ERROR_MISSING_FIELDS = 'Missing information in the following fields:';

	@TestVisible
	private static final String ERROR_PRODUCER = 'Producer does not belong to the given Referral Partner.';

	@TestVisible
	private Lead workLead;

	@TestVisible
	private List<String> fields;

	@TestVisible
	private String error;
	
	@TestVisible
	private String recordType;


	/**
	 * @description validate validates the values of the Lead.
	 * @param  leads  Lead checking
	 * @return Empty string if no error. Otherwise errors.
	 */
	@InvocableMethod(label='Clone Lead Validation' description='Validates the Lead has values in the required fields.  Returns a string of errors.' category='Lead')
	public static List<String> validate(List<Lead> leads) {
		List<String> result = new List<String>();

		if (leads == null || leads.isEmpty()) {
			result.add(ERROR_NO_LEADS);
		} else {
			LeadCloneValidator validator = new LeadCloneValidator();

			for (Lead lead : leads) {
				validator.validation(lead);

				result.add(validator.getResult());
			}
		}

		return result;
	}

	@TestVisible
	private void validation(Lead lead) {
		workLead = lead;
		fields = new List<String>();
		error = '';
		recordType = RecordTypeService.getLabel(lead.RecordTypeId, 'Lead');

		if (recordType == 'Client Lead') {
			checkStandardFields();
			checkClient();
		} else if (recordType == 'Referral Partner Lead') {
			checkStandardFields();
			checkReferralPartner();
		} else {
			error = ERROR_BAD_RECORDTYPE;
		}
	}

	/**
	 * @description getResult builds the resulting validation string.
	 * @return Empty string if no error. Otherwise the combined errors.
	 */
	@TestVisible
	private String getResult() {
		String result = error;

		if (!fields.isEmpty()) {
			result += '\n' + ERROR_MISSING_FIELDS;
			for (String field : fields) {
				result += '\n    ' + field;
			}
		}

		return result;
	}

	/**
	 * @description checkStandardFields checks fields are valid for Client or Referral Partner leads.
	 */
	@TestVisible
	private void checkStandardFields() {
		if (String.isBlank(workLead.Company)) {
			fields.add('Company');
		}

		if (String.isBlank(workLead.LastName)) {
			fields.add('Last Name');
		}

		if (String.isBlank(workLead.Direct__c) &&
			String.isBlank(workLead.MobilePhone) &&
			String.isBlank(workLead.Phone)) {
				fields.add('Phone Number');
		}

		if (String.isBlank(workLead.LeadSource)) {
			fields.add('Lead Source');
		} else if (workLead.LeadSource == 'Other') {
			if (String.isBlank(workLead.Other_Lead_Source_Type__c)) {
				fields.add('Other Lead Source');
			}
		}
	}

	/**
	 * @description checkClient checks fields are valid for Client leads.
	 */
	@TestVisible
	private void checkClient() {
		if (String.isBlank(workLead.Part_of_a_Franchise__c)) {
			fields.add('Part of a Franchise');
		} else {
			if (workLead.Part_of_a_Franchise__c == 'Yes') {
				if (String.isBlank(workLead.Franchise_Brand_Name__c)) {
					fields.add('Franchise Brand Name');
				} else {
					if (workLead.Franchise_Brand_Name__c == 'Other') {
						if (String.isBlank(workLead.Other_Franchise_Brand_Name__c)) {
							fields.add('Other Franchise Brand Name');
						}
					}					
				}
			}
		}

		if (String.isBlank(workLead.Referral_Partner__c)) {
			fields.add('Referral Partner');
		} else {
			if (String.isBlank(workLead.Producer__c)) {
				fields.add('Producer');
			} else {
				Contact contact = [SELECT Id, Name, AccountId FROM Contact WHERE Id = :workLead.Producer__c];

				if (workLead.Referral_Partner__c != contact.AccountId) {
					error = ERROR_PRODUCER;
				}
			}
		}
	}

	/**
	 * @description checkReferralPartner checks fields are valid for Referral Partner leads.
	 */
	@TestVisible
	private void checkReferralPartner() {
		if (String.isBlank(workLead.Email)) {
			fields.add('Email');
		}
	}
}