/**
 * @description OpportunityProductCases creates Cases for Additional Product Opportunities.
 */
public without sharing class OpportunityProductCases {
	@TestVisible
	private static final String FORMAT_CASE_SUBJECT_BBSIU_CONTRACT = 'New BBSIU Setup- {0}';
	@TestVisible
	private static final String FORMAT_CASE_SUBJECT_BBSIU_SETUP = 'BBSIU Billing Setup- {0}';
	@TestVisible
	private static final String FORMAT_CASE_SUBJECT_LMS_DEMO = 'Demo Access Requested for {0}';

	@TestVisible
	private static final String CASE_TYPE_BBSIU_CONTRACT = 'New BBSIU Contract';
	@TestVisible
	private static final String CASE_TYPE_BBSIU_SETUP = 'BBSIU Billing Setup';
	@TestVisible
	private static final String CASE_TYPE_LMS_DEMO = 'LMS Demo Requested';
	@TestVisible
	private static final String CASE_CATEGORY_LMS = 'LMS';
	@TestVisible
	private static final String CASE_CATEGORY_BILLING = 'Billing';
	@TestVisible
	private static final String CASE_ORIGIN_SF = 'Salesforce';
	@TestVisible
	private static final String CASE_STATUS_NEW = 'New';
	@TestVisible
	private static final String CASE_PRIORITY_LOW = 'Low';
	@TestVisible
	private static final String CASE_PRIORITY_MEDIUM = 'Medium';
	@TestVisible
	private static final String CASE_PRIORITY_SEVERITY_S2 = 'S2';
	@TestVisible
	private static final String CASE_PRIORITY_SEVERITY_S3 = 'S3';

	@TestVisible
	private static final String CASE_TYPE_TIMECO = 'TIMECO Billing Setup';
	private static final String CASE_TYPE_TIMECLOCKPLUS = 'TIMECLOCKPLUS Billing Setup';
	private static final String CASE_TYPE_TIMENET = 'TIMENET Billing Setup';

	@TestVisible
	private static final String FAMILY_TYPE_BBSIU = 'BBSIU for Clients';
	@TestVisible
	private static final String FAMILY_TYPE_LMS = 'LMS';
	@TestVisible
	private static final String FAMILY_TYPE_TIMECO = 'TIMECO';
	@TestVisible
	private static final String FAMILY_TYPE_TIMECLOCKPLUS = 'TIMECLOCKPLUS';
	@TestVisible
	private static final String FAMILY_TYPE_TIMENET = 'TIMENET';

	private static final String FORMAT_CASE_DESCRIPTION_BBSIU_CONTRACT =
		'Client Name: {0} \n' +
		'Client ID: {1} \n' +
		'Branch: {2} \n' +
		'Billing Frequency: {3} \n' +
		'Number of Subscribers: {4} \n' +
		'HR & Compliance Seat Count: {5} \n' +
		'Risk & Safety Seat Count: {6} \n' +
		'Leadership Seat Count: {7} \n' +
		'Professional Skills Seat Count: {8} \n' +
		'Total BBSIU Seats: {9} \n' +
		'Additional Products Notes: \n{10}';
	private static final String FORMAT_CASE_DESCRIPTION_BBSIU_SETUP =
		'Client Name: {0} \n' +
		'Client ID: {1} \n' +
		'Billing Frequency: {2} \n' +
		'Branch: {3} \n' +
		'Additional Products Notes: \n{4}';
	private static final String FORMAT_CASE_DESCRIPTION_LMS_DEMO =
		'Account:  {0}\n' +
		'Opportunity: {1}\n' +
		'Link: {2}\n' +
		'Additional Products Notes: \n{3}';
	private static final String FORMAT_CASE_DESCRIPTION_TIMECO =
		'Client Name: {0} \n' +
		'Client ID: {1} \n' +
		'Branch: {2} \n' +
		'Billing Frequency: {3} \n' +
		'TIMECO Setup Fee Waived: {4}\n' +
		'Additional Products Notes: \n{5}';
	private static final String FORMAT_CASE_DESCRIPTION_TIMECLOCKPLUS =
		'Client Name: {0} \n' +
		'Client ID: {1} \n' +
		'Branch: {2} \n' +
		'Billing Frequency: {3} \n' +
		'TIMECLOCKPLUS Setup Fee Waived: {4}\n' +
		'Additional Products Notes: \n{5}';
	private static final String FORMAT_CASE_DESCRIPTION_TIMENET =
		'Client Name: {0} \n' +
		'Client ID: {1} \n' +
		'Branch: {2} \n' +
		'Billing Frequency: {3} \n' +
		'TIMENET Setup Fee Waived: {4}\n' +
		'Additional Products Notes: \n{5}';
	private static final String FORMAT_PRODUCT_ITEM =
		'\n' +
		'Product Name: {0}  ' +
		'Quantity: {1}  ' +
		'Sales Price: {2}';

	// Maps Account Id to Account
	@TestVisible
	private Map<Id, Account> relatedAccounts;

	// Maps Account Id to Owner Contact
	@TestVisible
	private Map<Id, Contact> relatedContacts;

	// Maps Opportuntiy Id to List of OpportunityLineItems
	@TestVisible
	private Map<Id, List<OpportunityLineItem>> relatedLineItems;

	// Maps Opportuntiy Id to List of File Ids
	@TestVisible
	private Map<Id, List<Id>> relatedFileIds;

	private Case workCase;
	private Account workClient;
	private Opportunity workOpp;
	private Contact workContact;
	private List<OpportunityLineItem> workItems;

	@TestVisible
	private List<Case> cases = new List<Case>();

	private Map<Id, List<Case>> mapOppToCases = new Map<Id, List<Case>>();

	/**
	 * @description OpportunityProductCases constructor.
	 * @param  relatedAccounts  Related Accounts
	 * @param  relatedContacts  Related Contacts
	 * @param  relatedLineItems Related LineItems
	 * @param  relatedFileIds   Related FileIds
	 */
	public OpportunityProductCases(
		Map<Id, Account> relatedAccounts,
		Map<Id, Contact> relatedContacts,
		Map<Id, List<OpportunityLineItem>> relatedLineItems,
		Map<Id, List<Id>> relatedFileIds
	) {
		this.relatedAccounts = relatedAccounts;
		this.relatedContacts = relatedContacts;
		this.relatedLineItems = relatedLineItems;
		this.relatedFileIds = relatedFileIds;
	}

	/**
	 * @description insertCases pushes the created Cases to the database
	 */
	public void insertCases() {
		if (!cases.isEmpty()) {
			insert cases;

			cases = new List<Case>();
		}

		if (!mapOppToCases.isEmpty()) {
			attachDocuments();

			mapOppToCases = new Map<Id, List<Case>>();
		}
	}

	/**
	 * @description createBbsiuContract creates a Case for BBSIU Contract.
	 * @param  opp  Opportunity
	 */
	public void createBbsiuContract(Opportunity opp) {
		workOpp = opp;
		workClient = relatedAccounts.get(opp.AccountId);
		workContact = relatedContacts.get(opp.AccountId);

		workItems = getItemsOfType(opp, FAMILY_TYPE_BBSIU);

		if (!workItems.isEmpty()) {
			String subject = String.format(FORMAT_CASE_SUBJECT_BBSIU_CONTRACT, new List<String>{ workClient.Name });

			String description = String.format(
				FORMAT_CASE_DESCRIPTION_BBSIU_CONTRACT,
				new List<String>{
					workClient.Name,
					workClient.External_Id__c,
					workClient.Prospect_Branch__r.Name,
					opp.Billing_Frequency__c,
					String.valueOf(opp.Number_of_Subscribers__c),
					String.valueOf(opp.HR_Seats__c),
					String.valueOf(opp.Risk_Seats__c),
					String.valueOf(opp.Leadership_Seats__c),
					String.valueOf(opp.Pro_Skills_Seats__c),
					String.valueOf(opp.Total_BBSIU_Seats__c),
					opp.Notes_Additional_Products__c
				}
			);

			Case newCase = new Case(
				RecordTypeId = RecordTypeService.getId(Case_Services.CASE_NAME, Case_Services.RECORDTYPE_CLIENT_RP),
				Origin = CASE_ORIGIN_SF,
				Status = CASE_STATUS_NEW,
				Priority = CASE_PRIORITY_MEDIUM,
				Severity__c = CASE_PRIORITY_SEVERITY_S2,
				AccountId = workClient.Id,
				ContactId = (workContact == null) ? null : workContact.Id,
				Type = CASE_CATEGORY_LMS,
				Type__c = CASE_TYPE_BBSIU_CONTRACT,
				Sub_Type__c = 'Add New Users',
				Subject = subject,
				Description = description
			);

			cases.add(newCase);

			if (!mapOppToCases.containsKey(opp.Id)) {
				mapOppToCases.put(opp.Id, new List<Case>());
			}
			mapOppToCases.get(opp.Id).add(newCase);
		}
	}

	/**
	 * @description createBbsiuSetup creates a Case for BBSIU setup.
	 * @param  opp  Opportunity
	 */
	public void createBbsiuSetup(Opportunity opp) {
		workOpp = opp;
		workClient = relatedAccounts.get(opp.AccountId);
		workContact = relatedContacts.get(opp.AccountId);

		workItems = getItemsOfType(opp, FAMILY_TYPE_BBSIU);

		if (!workItems.isEmpty()) {
			String subject = String.format(FORMAT_CASE_SUBJECT_BBSIU_SETUP, new List<String>{ workClient.Name });

			String description = String.format(
				FORMAT_CASE_DESCRIPTION_BBSIU_SETUP,
				new List<String>{
					workClient.Name,
					workClient.External_Id__c,
					opp.Billing_Frequency__c,
					workClient.Prospect_Branch__r.Name,
					opp.Notes_Additional_Products__c
				}
			);

			description += '\n' + formatLineItems();

			Case newCase = new Case(
				RecordTypeId = RecordTypeService.getId(Case_Services.CASE_NAME, Case_Services.RECORDTYPE_CLIENT_RP),
				Origin = CASE_ORIGIN_SF,
				Status = CASE_STATUS_NEW,
				Priority = CASE_PRIORITY_MEDIUM,
				Severity__c = CASE_PRIORITY_SEVERITY_S2,
				AccountId = workClient.Id,
				ContactId = (workContact == null) ? null : workContact.Id,
				Type = CASE_CATEGORY_BILLING,
				Type__c = CASE_TYPE_BBSIU_SETUP,
				Sub_Type__c = null,
				Subject = subject,
				Description = description
			);

			cases.add(newCase);

			if (!mapOppToCases.containsKey(opp.Id)) {
				mapOppToCases.put(opp.Id, new List<Case>());
			}
			mapOppToCases.get(opp.Id).add(newCase);
		}
	}

	/**
	 * @description createLmsDemo creates a Case for LMS Demo request.
	 * @param  opp      Opportunity
	 * @param  role     ContactRoles of the Opportunity
	 * @param  contact  Contact related to the role
	 * @return true if Case created
	 */
	public Boolean createLmsDemo(Opportunity opp, OpportunityContactRole role, Contact contact) {
		if (role.Role != 'BBSIU Contact') {
			return false;
		}

		workOpp = opp;
		workClient = relatedAccounts.get(opp.AccountId);
		workContact = relatedContacts.get(opp.AccountId);

		String subject = String.format(FORMAT_CASE_SUBJECT_LMS_DEMO, new List<String>{ workOpp.Name });

		String description = String.format(
			FORMAT_CASE_DESCRIPTION_LMS_DEMO,
			new List<String>{
				workClient.Name,
				workOpp.Name,
				URL.getSalesforceBaseUrl().toExternalForm() +
				'/' +
				workOpp.Id,
				opp.Notes_Additional_Products__c
			}
		);

		description += '\n' + contact.Name;
		contact.BBSIU_Demo_Access__c = true;

		Case newCase = new Case(
			RecordTypeId = RecordTypeService.getId(Case_Services.CASE_NAME, Case_Services.RECORDTYPE_CLIENT_RP),
			Origin = CASE_ORIGIN_SF,
			Status = CASE_STATUS_NEW,
			Priority = CASE_PRIORITY_LOW,
			Severity__c = CASE_PRIORITY_SEVERITY_S3,
			AccountId = workClient.Id,
			ContactId = (workContact == null) ? null : workContact.Id,
			Type = CASE_CATEGORY_LMS,
			Type__c = CASE_TYPE_LMS_DEMO,
			Sub_Type__c = null,
			Subject = subject,
			Description = description
		);

		cases.add(newCase);

		if (!mapOppToCases.containsKey(opp.Id)) {
			mapOppToCases.put(opp.Id, new List<Case>());
		}
		mapOppToCases.get(opp.Id).add(newCase);

		return true;
	}

	/**
	 * @description formatLineItems formats the OpportunityLineItems into a String.
	 * @return String
	 */
	@TestVisible
	private String formatLineItems() {
		String result = '';

		for (OpportunityLineItem item : workItems) {
			result += String.format(
				FORMAT_PRODUCT_ITEM,
				new List<String>{ item.Name, String.valueOf(item.Quantity), String.valueOf(item.UnitPrice) }
			);
		}

		return result;
	}

	/**
	 * @description getItemsOfType retrieves specific Family OpportunityLineItems for an Opportunity.
	 * @param  opp   Opportunity
	 * @param  type  Family Type of Product looking for
	 * @return List<OpportunityLineItem>
	 */
	@TestVisible
	private List<OpportunityLineItem> getItemsOfType(Opportunity opp, String type) {
		List<OpportunityLineItem> result = new List<OpportunityLineItem>();

		for (OpportunityLineItem item : relatedLineItems.get(opp.Id)) {
			if (item.Product2.Family == type) {
				result.add(item);
			}
		}

		return result;
	}

	/**
	 * @description attachDocuments attaches Opportunity documents to the L&D Team Case.
	 */
	private void attachDocuments() {
		Map<Id, List<Id>> mapDocuments = File_Service.getRelatedFiles(mapOppToCases.keySet());

		List<ContentDocumentLink> links = new List<ContentDocumentLink>();

		for (Id idOpp : mapOppToCases.keySet()) {
			for (Case newCase : mapOppToCases.get(idOpp)) {
				if (mapDocuments.containsKey(idOpp)) {
					for (Id idDoc : mapDocuments.get(idOpp)) {
						links.add(
							new ContentDocumentLink(
								LinkedEntityId = newCase.Id,
								ContentDocumentId = idDoc,
								ShareType = 'V',
								Visibility = 'AllUsers'
							)
						);
					}
				}
			}
		}

		insert links;
	}
}