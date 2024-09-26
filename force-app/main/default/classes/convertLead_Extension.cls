/**
 * @description convertLead_Extension
 */
public with sharing class convertLead_Extension {
	private static final String CLIENT_LEAD = 'Client Lead';
	
	private static final String ERROR_LEAD_SOURCE = 'Lead Source must have a value to convert.';
	private static final String ERROR_LEAD_SOURCE_OTHER = 'Other Lead Source is required when Lead Source is "Other"';
	private static final String ERROR_EST_ANNUAL_BILLING = 'Estimated Annual Billing must be populated before lead conversion';

	private final Lead leadToConvert;

	public convertLead_Extension(ApexPages.StandardController stdController) {
		leadToConvert = [
			SELECT Id, Estimated_Annual_Billing__c, LeadSource, Other_Lead_Source_Type__c, RecordType.Name
			FROM Lead
			WHERE Id = :stdController.getRecord().Id
		];
	}

	public PageReference archiveDupesAndConvertLead() {
		if (mayConvert(leadToConvert)) {
			DupeCatcherController controller = new DupeCatcherController('New');

			try {
				controller.saveMatches(controller.dupeLead, controller.allMatches);
			} catch (Exception e) {
				ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.ERROR, e.getMessage()));
			}

			return ConvertLead();
		}
		
		return null;
	}

	private PageReference ConvertLead() {
		try {
			Database.LeadConvertResult result = LeadConvert.convert(leadToConvert.Id, leadToConvert.RecordType.Name == CLIENT_LEAD);

			Id acctId = result.getAccountId();
			pageReference pageRef = new PageReference('/' + (String) acctId);
			pageRef.setRedirect(true);

			return pageRef;
		} catch (Exception e) {
			if (e.getMessage().contains('Estimated Annual Billing')) {
				leadToConvert.Estimated_Annual_Billing__c.addError(ERROR_EST_ANNUAL_BILLING);
			} else {
				leadToConvert.addError(e.getMessage());
			}
		}

		return null;
	}

	/**
	 * @description mayConvert checks values which are required on the Lead to convert.
	 * @param  lead  Lead checking
	 * @Return true if valid.
	 */
	@TestVisible
	private static Boolean mayConvert(Lead lead) {	
		Boolean result = true;

		//if (lead.Estimated_Annual_Billing__c == null) {
		//	if (lead.RecordType.Name == CLIENT_LEAD) {
		//		lead.Estimated_Annual_Billing__c.addError(ERROR_EST_ANNUAL_BILLING);
		//		result = false;
		//	}
		//}
			
		if (String.isBlank(lead.LeadSource)) {
			lead.LeadSource.addError(ERROR_LEAD_SOURCE);
			result = false;
		} else if (lead.LeadSource == 'Other' && String.isBlank(lead.Other_Lead_Source_Type__c)) {
			lead.LeadSource.addError(ERROR_LEAD_SOURCE_OTHER);
			result = false;
		}

		return result;
	}
}