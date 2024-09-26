/**
 * @description Event_Services handles Event objects.
 */
public without sharing class Event_Services {
	public static final String EVENT = 'Event';

	public static final String RECORDTYPE_CLIENT_GENERAL = 'Client General';
	public static final String RECORDTYPE_LEAD_EVENT = 'Lead Event';
	public static final String RECORDTYPE_RP_GENERAL = 'Referral Partner General';
	public static final String RECORDTYPE_RP_EVENT = 'Referral Partner Event';

	@TestVisible
	private static final String FIRST_MEETING = 'First Meeting';

	private static final String ERROR_NOT_PROSPECT = 'First Meeting events must be created on prospect or terminated accounts.';
	private static final String ERROR_MISSING_BAD_FIT_REASON ='Reason for Bad Fit is required.';

	/**
	 * @description blockInvalidCreation adds an error to Events which
	 * should NOT be created.
	 * @param  listEvents  List of Events
	 */
	public static void blockInvalidCreation(List<Event> listEvents) {
		List<Event> clientEvents = RecordTypeService.getByRecordType(listEvents, EVENT, RECORDTYPE_CLIENT_GENERAL);

		Set<Event> events = new Set<Event>();
		Set<Id> idCheckAccounts = new Set<Id>();

		for (Event event : clientEvents) {
			if (event.Type == FIRST_MEETING) {
				if (Id_Service.isType(event.WhoId, 'Account')) {
					events.add(event);
					idCheckAccounts.add(event.WhoId);
				}
			}
		}

		if (!idCheckAccounts.isEmpty()) {
			Map<Id, Account> accounts = new Map<Id, Account>([
				SELECT Id, Name, RecordType.Name
				FROM Account
				WHERE Id IN :idCheckAccounts
			]);

			for (Event e : events) {
				if (accounts.containsKey(e.WhoId)) {

					if (accounts.get(e.WhoId).RecordType.Name != 'Prospect' &&
						accounts.get(e.WhoId).RecordType.Name != 'Terminated') {
						e.addError(ERROR_NOT_PROSPECT);
					}
				}
			}
		}
	}

	/**
	* @description validateFields confirms fields which require data have it.
	* @param  oldEvents  Events before changes
	* @param  newEvents  List of Events being saved
	*/
	public static void validateFields(Map<Id, Event> oldEvents, List<Event> newEvents) {
		for (Event event : newEvents) {
			if (event.Meeting_Result__c == 'Completed - Bad Fit') {
				if (String.isBlank(event.Reason_for_Bad_Fit__c)) {
					event.addError('Reason_for_Bad_Fit__c', ERROR_MISSING_BAD_FIT_REASON);
				}
			}
		}
	}

	/**
	* @description updateFields updates fields.
	* @param  oldEvents  Events before changes
	* @param  newEvents  List of Events being saved
	*/
	public static void updateFields(Map<Id, Event> oldEvents, List<Event> newEvents) {
		for (Event event : newEvents) {
			if (event.Campaign_List_Name__c != oldEvents.get(event.Id).Campaign_List_Name__c) {				
				event.Event_Source__c = determineEventSource(event.Campaign_List_Name__c);
			}
		}
	}

	/**
	 * @description setRecordType sets Events with Leads as the "connection"
	 * to Record Type "Lead Event".
	 * @param  listEvents  List of Events being saved
	 */
	public static void setRecordType(List<Event> listEvents) {
		Id idrtLeadEvent = RecordTypeService.getId(EVENT, RECORDTYPE_LEAD_EVENT);

		for (Event event : listEvents) {
			if (Id_Service.isType(event.WhoId, 'Lead')) {
				event.RecordTypeId = idrtLeadEvent;
			}
		}
	}

	/**
	 * @description setInitialFields sets initial values on events.
	 * @param  listEvents  List of Events being saved
	 */
	public static void setInitialFields(List<Event> listEvents) {
		List<Event> leadEvents = RecordTypeService.getByRecordType(listEvents, EVENT, RECORDTYPE_LEAD_EVENT);
		List<Event> clientEvents = RecordTypeService.getByRecordType(listEvents, EVENT, RECORDTYPE_CLIENT_GENERAL);

		initializeLeadEventFields(leadEvents);
		initializeClientGeneralFields(clientEvents);
	}

	/**
	 * @description initializeLeadEventFields sets fields on "Lead Event" events
	 * on creation.
	 * @param  events  "Lead Event" Events
	 */
	private static void initializeLeadEventFields(List<Event> events) {
		if (events.isEmpty()) {
			return;
		}

		Set<Id> idLeads = new Set<Id>();

		for (Event event : events) {
			if (Id_Service.isType(event.WhoId, 'Lead')) {
				idLeads.add(event.WhoId);
			}
		}

		Map<Id, Lead> leads = new Map<Id, Lead>([
			SELECT Id, Name, Company, LeadSource, Other_Lead_Source_Type__c, Campaign_List_Name__c
			FROM Lead
			WHERE Id IN :idLeads
		]);

		Lead lead;

		for (Event event : events) {
			if (leads.containsKey(event.WhoId)) {
				lead = leads.get(event.WhoId);

				event.Company_Name__c = lead.Company;
				event.Lead_Source__c = lead.LeadSource;
				event.Other_Lead_Source__c = lead.Other_Lead_Source_Type__c;

				event.Campaign_List_Name__c = lead.Campaign_List_Name__c;
				event.Event_Source__c = determineEventSource(lead.Campaign_List_Name__c);
			}
		}
	}

	/**
	 * @description initializeLeadEventFields sets fields on "Client General" events
	 * on creation.
	 * @param  events  "Client General" Events
	 */
	private static void initializeClientGeneralFields(List<Event> events) {
		if (events.isEmpty()) {
			return;
		}

		Set<Id> idAccounts = new Set<Id>();

		for (Event event : events) {
			if (Id_Service.isType(event.WhatId, 'Account')) {
				idAccounts.add(event.WhatId);
			}
		}

		Map<Id, Account> accounts = new Map<Id, Account>([
			SELECT Id, Name, Lead_Source__c, Account_Source_Other__c, Campaign_List_Name__c
			FROM Account
			WHERE Id IN :idAccounts
		]);

		Account account;
		// FUTURE: Replace Call to Profile_Service.isProfile with Custom Setting: User Call Center
		String idUser = (Profile_Service.isProfile('BBSI Call Center', UserInfo.getProfileId())) ? UserInfo.getUserId() : null;

		for (Event event : events) {
			if (accounts.containsKey(event.WhatId)) {
				account = Accounts.get(event.WhatId);

				event.Sales_Development_Representative__c = idUser;
				event.Company_Name__c = account.Name;
				event.Lead_Source__c = account.Lead_Source__c;
				event.Other_Lead_Source__c = account.Account_Source_Other__c;

				event.Campaign_List_Name__c = account.Campaign_List_Name__c;
				
				event.Event_Source__c = determineEventSource(account.Campaign_List_Name__c);
			}
		}
	}

	@TestVisible
	private static String determineEventSource(String campaignList) {		
		if (String.isBlank(campaignList)) {
			return 'Outbound';
		}

		if (campaignList.toUpperCase().contains('HSFORM')) {
			return 'Inbound';
		} 
		
		return 'Campaign';
	}

	/**
	 * @description updateFirstMeeting update fields based on the First Meeting.
	 * @param  mapOld   Events before changes
	 * @param  listNew  Events with changes
	 */
	public static void updateFirstMeeting(Map<Id, Event> mapOld, List<Event> listNew) {
		List<Event> leadEvents = RecordTypeService.getByRecordType(listNew, EVENT, RECORDTYPE_LEAD_EVENT);
		List<Event> clientEvents = RecordTypeService.getByRecordType(listNew, EVENT, RECORDTYPE_CLIENT_GENERAL);

		updateFirstMeetingLeads(mapOld, leadEvents);        
		updateFirstMeetingAccounts(mapOld, clientEvents);
	}

	/**
	 * @description updateFirstMeetingLeads update "Lead Event" fields based on the First Meeting.
	 * @param  mapOld   Events before changes
	 * @param  events   Events to possibly update
	 */
	public static void updateFirstMeetingLeads(Map<Id, Event> mapOld, List<Event> events) {
		if (events.isEmpty()) {
			return;
		}

		Set<Id> idConvertLeads = new Set<Id>();
		Map<Id, String> unqualifiedLeads = new Map<Id, String>();

		for (Event event : events) {
			if (event.Type == FIRST_MEETING) {
				if (event.Meeting_Result__c != null) {
					if (mapOld == null || mapOld.get(event.Id).Meeting_Result__c != event.Meeting_Result__c) {
						switch on event.Meeting_Result__c {
							when 'Completed - Good Fit' {
								idConvertLeads.add(event.WhoId);
							}
							when 'Completed - Bad Fit' {
								unqualifiedLeads.put(event.WhoId, 'Bad Fit');
							}
							when 'Cancelled by BBSI' {
								unqualifiedLeads.put(event.WhoId, event.Reason_for_Event_Cancellation__c);
							}
						}
					}
				}
			}
		}

		disqualifyLeads(unqualifiedLeads);

		LeadConvert_Queueable.convert(new List<Id>(idConvertLeads));
	}

	/**
	 * @description updateFirstMeetingAccounts update "Client General" Event fields based on the First Meeting.
	 * Create an Client Event Opportunity if the meeting result was a good fit.
	 * @param  mapOld   Events before changes
	 * @param  events   Events to possibly update
	 */
	public static void updateFirstMeetingAccounts(Map<Id, Event> mapOld, List<Event> events) {
		if (events.isEmpty()) {
			return;
		}

		Set<Id> idAccounts = new Set<Id>();

		for (Event event : events) {
			if (event.Type == FIRST_MEETING) {
				if (event.Meeting_Result__c != null) {
					if (mapOld == null || mapOld.get(event.Id).Meeting_Result__c != event.Meeting_Result__c) {
						switch on event.Meeting_Result__c {
							when 'Completed - Good Fit' {                               
								idAccounts.add(event.WhatId);
							}
						}
					}
				}
			}
		}

		createClientEventOpportunities(idAccounts);
	}

	/**
	 * @description disqualifyLeads disqualifies the Leads
	 * @param  unqualifiedLeads  List of Lead identifiers to unqualify
	 */
	private static void disqualifyLeads(Map<Id, String> unqualifiedLeads) {
		if (!unqualifiedLeads.isEmpty()) {
			Map<Id, Lead> leads = new Map<Id, Lead>([
				SELECT Id, Name, Status, Unqualified_Reason__c
				FROM Lead
				WHERE Id IN :unqualifiedLeads.keySet()
			]);

			List<Lead> updateLeads = new List<Lead>();

			Lead lead;

			for (Id idLead : leads.keySet()) {
				lead = leads.get(idLead);

				lead.Status = 'Unqualified';
				lead.Unqualified_Reason__c = unqualifiedLeads.get(idLead);

				updateLeads.add(lead);
			}

			update updateLeads;
		}
	}

	/**
	 * @description createTasks creates tasks for the Event for the day after the event ends.
	 * @param  mapOld   Events before changes
	 * @param  listNew  Events with changes
	 *
	 * @see 35570 Auto created task to update RP Plan when event is added to account:
	 *     https://bbsi.visualstudio.com/Business%20IT%20Sales%20and%20Marketing%20Solutions/_workitems/edit/35570
	 */
	public static void createTasks(Map<Id, Event> mapOld, List<Event> listNew) {
		List<Event> listEvents = getEventsNeedingTasks(mapOld, listNew);
		if (!listEvents.isEmpty()) {
			List<Task> newTasks = new List<Task>();

			Map<Id, Account> mapAccounts = getRelatedReferralPartners(listEvents);

			for (Event event : listEvents) {
				Task task = createEventTask(event, mapAccounts);

				if (task != null) {
					newTasks.add(task);
				}
			}

			insert newTasks;
		}
	}

	/**
	 * @description getEventsNeedingTasks determine which of the Events need Tasks created.
	 * @param  mapOld   Map with Events before changes
	 * @param  listNew  List of Events with changes
	 * @return List of Event
	 */
	@TestVisible
	private static List<Event> getEventsNeedingTasks(Map<Id, Event> mapOld, List<Event> listNew) {
		List<Event> result = new List<Event>();

		for (Event event : listNew) {
			Event eventOld = (mapOld == null) ? null : mapOld.get(event.Id);

			if (Id_Service.isType(event.WhatId, 'Account')) {
				if (event.ActivityDateTime != null) {
					if (eventOld == null || eventOld.ActivityDate == null) {
						result.add(event);
					}
				} else if (eventOld == null && event.IsAllDayEvent) {
					result.add(event);
				}
			}
		}

		return result;
	}

	/**
	 * @description getRelatedReferralPartners retrieves the Referral Partners related
	 * to the Events.
	 * @param  events Events working with
	 * @return Map of Referral Partners
	 */
	@TestVisible
	private static Map<Id, Account> getRelatedReferralPartners(List<Event> events) {
		Set<Id> idAccounts = new Set<Id>();

		for (Event event : events) {
			if (event.AccountId != null) {
				idAccounts.add(event.AccountId);
			}
			if (Id_Service.isType(event.WhatId, 'Account')) {
				idAccounts.add(event.WhatId);
			}
		}

		return new Map<Id, Account>([SELECT Id, Name FROM Account WHERE RecordType.Name = 'Referral Partner']);
	}

	/**
	 * @description createEventTask creates a Task for the given Event.
	 * @param  event        Event creating Task for
	 * @param  mapAccounts  Map of available Referral Partners
	 * @return Task
	 */
	@TestVisible
	private static Task createEventTask(Event event, Map<Id, Account> mapAccounts) {
		Id idAccount;
		String nameAccount;

		if (mapAccounts.containsKey(event.WhatId)) {
			idAccount = mapAccounts.get(event.WhatId).Id;
			nameAccount = mapAccounts.get(event.WhatId).Name;
		} else if (mapAccounts.containsKey(event.AccountId)) {
			idAccount = mapAccounts.get(event.AccountId).Id;
			nameAccount = mapAccounts.get(event.AccountId).Name;
		} else {
			return null;
		}

		Id idRecordType = RecordTypeService.getId('Task', 'Event Task');

		Date dateDue;
		if (event.IsAllDayEvent) {
			dateDue = event.ActivityDate;
		} else {
			dateDue = Date.newinstance(
				event.ActivityDateTime.year(),
				event.ActivityDateTime.month(),
				event.ActivityDateTime.day()
			);
		}

		dateDue = dateDue.addDays(7);

		Task task = Task_Service.createTask(
			'Follow Up',
			null,
			idAccount,
			event.OwnerId,
			'Update Referral Partner Development Plan: ' + nameAccount,
			null,
			dateDue
		);

		task.IsReminderSet = true;
		task.ReminderDateTime = ((DateTime) dateDue).addHours(3);
		task.RecordTypeId = idRecordType;

		return task;
	}

	/**
	 * @description createClientEventOpportunities creates Client Event Opportunities
	 * on Prospect or Terminated accounts when there are no open or Closed Won on the
	 * account already.
	 * @param  idAccounts  Accounts related to the Opportunities
	 */
	private static void createClientEventOpportunities(Set<Id> idAccounts) {
		Map<Id, Account> accounts = new Map<Id, Account>([
			SELECT Id, Name, OwnerId
			FROM Account
			WHERE Id IN :idAccounts
			AND (RecordType.Name = 'Prospect' OR RecordType.Name = 'Terminated')
		]);

		Id idrtOppClient = RecordTypeService.getId('Opportunity', 'Client');

		Boolean createOpp;
		Map<Id, List<Opportunity>> typeOpporunities;
		List<Opportunity> opps;
		List<Opportunity> newOpps = new List<Opportunity>();

		Map<Id, Map<Id, List<Opportunity>>> accountOpps = Account_Services.getAccountOpportunities(idAccounts);
		for (Account account : accounts.values()) {
			createOpp = true;
			typeOpporunities = accountOpps.get(account.Id);

			if (typeOpporunities.containsKey(idRtOppClient)) {
				opps = typeOpporunities.get(idrtOppClient);

				for (Opportunity opp : opps) {
					if (opp.StageName != 'Closed Lost') {
						createOpp = false;
						break;
					}
				}
			}

			if (createOpp) {
				newOpps.add( OpportunityClient.makeClient(account.Name, account.Id, account.OwnerId) );
			}
		}

		if (!newOpps.isEmpty()) {
			insert newOpps;
		}
	}

	/**
	 * @description updateRelatedRecords updates account and Opportunities related to the events.
	 * @param newEvents  Map of changed events
	 */
	public static void updateRelatedRecords(Map<Id, Event> newEvents) {
		updateFirstMeetingsAccounts(newEvents.values());
		updateFirstMeetingsOpportunities(newEvents.values());
	}

	/**
	 * @description updateFirstMeetings updates accounts related to the First Meeting events.
	 * @param newEvents  List of changed events
	 */
	private static void updateFirstMeetingsAccounts(List<Event> newEvents) {
		List<Event> firstMeetings = new List<Event>();
		Set<Id> idAccounts = new Set<Id>();

		for (Event event : newEvents) {
			if (event.Type == FIRST_MEETING) {
				firstMeetings.add(event);
				idAccounts.add(event.WhatId);
			}
		}

		if (firstMeetings.isEmpty()) {
			return;
		}
		// FUTURE: Replace Call to Profile_Service.isProfile with Custom Setting: User Call Center
		if (!Profile_Service.isProfile('BBSI Call Center', UserInfo.getProfileId())) {
			return;
		}

		Map<Id, Account> accounts = new Map<Id, Account>([
			SELECT Id, Name, First_Meeting_Event_Id__c, First_Meeting_Event_Source__c, First_Meeting_Event_Date__c, First_Meeting_Event_Creator__c
			FROM Account
			WHERE Id IN :idAccounts
			AND RecordType.Name = :Account_Services.RECORDTYPE_PROSPECT 
		]);

		List<Account> updatedAccounts = new List<Account>();

		for (Event event : firstMeetings) {
			if (accounts.containsKey(event.WhatId)) {
				Account account = accounts.get(event.WhatId);

				Account_Services.updateAccountFromFirstMeeting(account, event);
				updatedAccounts.add(account);
			}
		}

		if (!updatedAccounts.isEmpty()) {
			update updatedAccounts;
		}
	}

	/**
	 * @description updateFirstMeetingsOpportunities opportunites related to the First Meeting events.
	 * @param newEvents  List of changed events
	 */
	private static void updateFirstMeetingsOpportunities(List<Event> newEvents) {
		Set<Id> idAccounts = new Set<Id>();

		for (Event event : newEvents) {
			if (event.Type == FIRST_MEETING) {
				idAccounts.add(event.WhatId);
			}
		}

		if (idAccounts.isEmpty()) {
			return;
		}

		List<Opportunity> changedOpps = new List<Opportunity>();

		for (Opportunity opp : [
			SELECT Id, Sales_Development_Representative__c, Account.Sales_Development_Representative__c, Bypass_Estimated_Annual_Billing__c
			FROM Opportunity
			WHERE AccountId IN :idAccounts
			AND (RecordType.Name = :Opportunity_Service.RECORDTYPE_CLIENT OR RecordType.Name = :Opportunity_Service.RECORDTYPE_SHELL)
			AND IsClosed = FALSE
		]) {
			if (opp.Sales_Development_Representative__c != opp.Account.Sales_Development_Representative__c) {
				opp.Sales_Development_Representative__c = opp.Account.Sales_Development_Representative__c;
				opp.Bypass_Estimated_Annual_Billing__c = !opp.Bypass_Estimated_Annual_Billing__c;
				changedOpps.add(opp);
			}
		}

		if (!changedOpps.isEmpty()) {
			update changedOpps;
		}
	}
}