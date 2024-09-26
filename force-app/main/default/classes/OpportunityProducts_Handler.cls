/**
 * @description OpportunityProducts_Handler handles Trigger Events for Additional Product Opportunities.
 */
public without sharing class OpportunityProducts_Handler {
	private static final String ERROR_DEMO_REQUEST = 'Missing active BBSIU Contact on Opportunity.';

	// All Opportunites before changes
	@TestVisible
	private Map<Id, Opportunity> oldOpps;

	// Only Additional Product Opportunity changes
	@TestVisible
	private List<Opportunity> newOpps;

	// Close Won Additional Product Opportunities
	@TestVisible
	private List<Opportunity> closedWon;

	// Additional Product Opportunities with demo requests
	@TestVisible
	private List<Opportunity> demoRequests;

	// Maps Account Id to Account
	@TestVisible
	private Map<Id, Account> relatedAccounts;

	// Maps Account Id to Owner Contact
	@TestVisible
	private Map<Id, Contact> relatedContacts;

	// Maps Opportunity Id to list of Contact Roles
	@TestVisible
	private Map<Id, List<OpportunityContactRole>> relatedContactRoles;

	// Maps Opportuntiy Id to List of OpportunityLineItems
	@TestVisible
	private Map<Id, List<OpportunityLineItem>> relatedLineItems;

	// Maps Opportuntiy Id to List of File Ids
	@TestVisible
	private Map<Id, List<Id>> relatedFileIds;

	// List of Assets
	@TestVisible
	private List<Asset> assets;

	// List of Cases to create
	@TestVisible
	private OpportunityProductCases caseMaker;

	/**
	 * @description OpportunityProducts_Handler constructor.
	 * @param  mapOldOpps   Opportunities before changes
	 * @param  listNewOpps  Opportunities with changes
	 */
	public OpportunityProducts_Handler(Map<Id, Opportunity> mapOldOpps, List<Opportunity> listNewOpps) {
		oldOpps = mapOldOpps;
		newOpps = RecordTypeService.getByRecordType(
			listNewOpps,
			Opportunity_Service.OPPORTUNITY,
			Opportunity_Service.RECORDTYPE_PRODUCTS
		);

		assets = new List<Asset>();
	}

	/**
	 * @description beforeInsert handles after insert trigger event for Additional Product Opportunities.
	 */
	public void beforeInsert() {
		readAccounts();

		setOwnerId();
	}

	/**
	 * @description afterInsert handles after insert trigger event for Additional Product Opportunities.
	 */
	public void afterInsert() {
		if (!newOpps.isEmpty()) {
			readAccounts();
			readDocuments();
			readLineItems();
			readContacts();

			findDemoRequest();
			findClosedWon();

			if (!demoRequests.isEmpty()) {
				readContactRoles();
			}

			caseMaker = new OpportunityProductCases(relatedAccounts, relatedContacts, relatedLineItems, relatedFileIds);

			createLmsDemoCases();
			createClosedWonCases();
			createClosedWonAssets();

			finish();
		}
	}

	/**
	 * @description afterUpdate handles after update trigger event for Benefits Opportunities.
	 */
	public void afterUpdate() {
		if (!newOpps.isEmpty()) {
			readAccounts();
			readDocuments();
			readContacts();
			readLineItems();
			findDemoRequest();
			findClosedWon();

			if (!demoRequests.isEmpty()) {
				readContactRoles();
			}

			caseMaker = new OpportunityProductCases(relatedAccounts, relatedContacts, relatedLineItems, relatedFileIds);

			createLmsDemoCases();
			createClosedWonCases();
			createClosedWonAssets();

			finish();
		}
	}

	/**
	 * @description finish performs remaining work.
	 */
	private void finish() {
		caseMaker.insertCases();

		insert assets;
	}

	/**
	 * @description setOwnerId sets the Additional Products Opportunity owner
	 * to the same as the Account Owner.
	 */
	private void setOwnerId() {
		for (Opportunity opp : newOpps) {
			if (relatedAccounts.containsKey(opp.AccountId)) {
				opp.OwnerId = relatedAccounts.get(opp.AccountId).OwnerId;
			}
		}
	}

	/**
	 * @description createLmsDemoCases
	 */
	@TestVisible
	private void createLmsDemoCases() {
		if (demoRequests.isEmpty()) {
			return;
		}

		Map<Id, Contact> contacts = getContactsFromRoles();

		for (Opportunity opp : demoRequests) {
			Boolean found = false;

			if (!relatedContactRoles.get(opp.Id).isEmpty()) {
				for (OpportunityContactRole role : relatedContactRoles.get(opp.Id)) {
					if (contacts.containsKey(role.ContactId)) {
						Contact contact = contacts.get(role.ContactId);

						if (caseMaker.createLmsDemo(opp, role, contact)) {
							found = true;
							break;
						}
					}
				}
			}

			if (!found) {
				opp.addError(ERROR_DEMO_REQUEST);
			}
		}

		update contacts.values();
	}

	/**
	 * @description createClosedWonCase creates Case for when Opportunity is Closed Won.
	 */
	@TestVisible
	private void createClosedWonCases() {
		for (Opportunity opp : closedWon) {
			caseMaker.createBbsiuSetup(opp);
			caseMaker.createBbsiuContract(opp);
		}
	}

	/**
	 * @description createClosedWonAssets
	 */
	@TestVisible
	private void createClosedWonAssets() {
		for (Opportunity opp : closedWon) {
			for (OpportunityLineItem item : relatedLineItems.get(opp.Id)) {
				assets.add(Asset_Service.createAsset(item, opp.AccountId, opp.CloseDate, item.Product2.Name));
			}
		}
	}

	/**
	 * @description readRelatedAccounts retrieves the Accounts related to the Opportunites.
	 */
	@TestVisible
	private void readAccounts() {
		if (relatedAccounts == null) {
			Set<Id> idAccounts = new Set<Id>();

			for (Opportunity opp : newOpps) {
				idAccounts.add(opp.AccountId);
			}

			relatedAccounts = new Map<Id, Account>(
				[SELECT Id, Name, OwnerId, External_Id__c, Prospect_Branch__r.Name FROM Account WHERE Id IN :idAccounts]
			);
		}
	}

	/**
	 * @description readLineItems gets the OpportunityLineItems related to all the changed Opportunities.
	 */
	@TestVisible
	private void readLineItems() {
		if (relatedLineItems == null) {
			relatedLineItems = new Map<Id, List<OpportunityLineItem>>();

			Set<Id> idOpps = new Set<Id>();

			for (Opportunity opp : newOpps) {
				idOpps.add(opp.Id);

				relatedLineItems.put(opp.Id, new List<OpportunityLineItem>());
			}

			List<OpportunityLineItem> items = [
				SELECT Id, Name, Quantity, UnitPrice, OpportunityId, Product2Id, Product2.Family, Product2.Name
				FROM OpportunityLineItem
				WHERE OpportunityId IN :idOpps
				ORDER BY Name ASC
			];

			for (OpportunityLineItem item : items) {
				relatedLineItems.get(item.OpportunityId).add(item);
			}
		}
	}

	/**
	 * @description readDocuments gets the Documents(Files) related to the Opportunities.
	 */
	private void readDocuments() {
		Set<Id> idOpps = new Set<Id>();

		for (Opportunity opp : newOpps) {
			idOpps.add(opp.Id);
		}

		relatedFileIds = File_Service.getRelatedFiles(idOpps);
	}

	/**
	 * @description readContacts gets the Contacts related to the Account's Owners.
	 */
	@TestVisible
	private void readContacts() {
		if (relatedContacts == null) {
			readAccounts();

			relatedContacts = new Map<Id, Contact>();

			Set<Id> idUsers = new Set<Id>();

			for (Account account : relatedAccounts.values()) {
				idUsers.add(account.OwnerId);
			}

			List<Contact> contacts = [
				SELECT Id, Name, Active__c, User_Id__c
				FROM Contact
				WHERE User_Id__c IN :idUsers
				ORDER BY Name ASC
			];

			for (Account account : relatedAccounts.values()) {
				for (Contact contact : contacts) {
					if (account.OwnerId == contact.User_Id__c) {
						relatedContacts.put(account.Id, contact);
						break;
					}
				}
			}
		}
	}

	/**
	 * @description findClosedWon finds the Opportunies which are newly Closed Won.
	 */
	@TestVisible
	private void findClosedWon() {
		if (closedWon == null) {
			closedWon = new List<Opportunity>();

			for (Opportunity opp : newOpps) {
				if (opp.StageName == 'Product Closed Won') {
					if (oldOpps == null || oldOpps.get(opp.Id).StageName != 'Product Closed Won') {
						closedWon.add(opp);
					}
				}
			}
		}
	}

	/**
	 * @description findDemoRequest finds the Opportunies newly request a demo.
	 */
	@TestVisible
	private void findDemoRequest() {
		if (demoRequests == null) {
			demoRequests = new List<Opportunity>();

			for (Opportunity opp : newOpps) {
				if (opp.BBSIU_for_Clients_Request_Demo_Access__c) {
					if (oldOpps == null || oldOpps.get(opp.Id).BBSIU_for_Clients_Request_Demo_Access__c == false) {
						demoRequests.add(opp);
					}
				}
			}
		}
	}

	/**
	 * @description readContactRoles gets the Opportunities Contact Roles related to the Opporunties.
	 */
	@TestVisible
	private void readContactRoles() {
		if (relatedContactRoles == null) {
			Set<Id> idOpps = new Set<Id>();

			for (Opportunity opp : newOpps) {
				idOpps.add(opp.Id);
			}

			relatedContactRoles = OpportunityContactRole_Service.readContactRoles(idOpps);
		}
	}

	/**
	 * @description getContactsFromRoles retrieves Contacts related to the Opportunity Contact Roles
	 * @return   return description
	 */
	@TestVisible
	private Map<Id, Contact> getContactsFromRoles() {
		Set<Id> idContacts = new Set<Id>();

		for (Opportunity opp : demoRequests) {
			List<OpportunityContactRole> roles = relatedContactRoles.get(opp.Id);

			for (OpportunityContactRole role : roles) {
				idContacts.add(role.ContactId);
			}
		}

		return new Map<Id, Contact>([SELECT Id, Name, AccountId FROM Contact WHERE Id IN :idContacts]);
	}
}