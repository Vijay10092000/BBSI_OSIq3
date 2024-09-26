/**
 * AccountConverstion handles updating a new Account from the Lead which created it.
 */
public with sharing class AccountConversion {
	/**
	 * @description updateConvertedAccounts retrieves additional data for a new (Converted) Account.
	 * @param idAccounts  Set of Account identifiers
	 */
	public static void updateConvertedAccounts(List<Account> accounts) {
		List<Account> converted = getConvertedAccounts(accounts);

		if (!converted.isEmpty()) {			
			checkRecordType(converted);
			updateFirstMeeting(converted);
		}
	}
	
	/**
	 * @description getConvertedAccounts finds the list of Accounts which are being
	 * created because of Lead Convertsion.
	 * @param  accounts   List of Accounts
	 * @return List<Account>
	 */
	@TestVisible
	private static List<Account> getConvertedAccounts(List<Account> accounts) {
		List<Account> result = new List<Account>();

		for (Account account : accounts) {
			if (account.Lead_Converted_Id__c != null) {
				result.add(account);
			}
		}

		return result;
	}

	/**
	 * @description checkRecordType changes the Account record type based on the record type
	 * of the Lead.  Uppercases the Client account name.
	 * @param  oldAccounts  Accounts before changes
	 * @param  newAccounts  Accounts with changes
	 */
	@TestVisible
	private static void checkRecordType(List<Account> accounts) {
		Id idProspect = RecordTypeService.getId('Account', 'Prospect');
		Id idRP = RecordTypeService.getId('Account', 'Referral Partner');
		
		for (Account account : accounts) {
			if (account.Lead_Record_Type__c == 'Client_Lead') {
				account.RecordTypeId = idProspect;
				account.Name = account.Name.toUpperCase();
			} else if (account.Lead_Record_Type__c == 'Referral_Partner_Lead') {
				account.RecordTypeId = idRP;
			} else {
				System.debug(LoggingLevel.WARN, 'AccountConverstion.checkRecordType(): Unknown Lead Record Type: ' + account.Lead_Record_Type__c);
			}
		}
	}

	/**
	 * @description updateFirstMeeting finds the converted Lead and updates the Account with
	 * the Lead's First Meeting Event.
	 */
	@TestVisible
	private static void updateFirstMeeting(List<Account> accounts) {		
		Map<Id, Lead> leads = getRelatedLeads(accounts);
		Map<Id, List<Event>> events = getRelatedEvents(leads.keySet(), 'First Meeting');

		for (Account account : accounts) {
			Lead lead = leads.get(account.Lead_Converted_Id__c);

			if (events.containsKey(lead.Id)) {
				List<Event> leadEvents = events.get(lead.Id);

				if (!leadEvents.isEmpty()) {
					Account_Services.updateAccountFromFirstMeeting(account, leadEvents.get(0));
				}
			}
		}
	}

	/**
	 * @description getRelatedLeads retrieves the Converted Lead for the given Account ids.
	 * @param  accounts  Converted Accounts
	 * @return Map<Id, Lead>
	 */
	@TestVisible
	public static Map<Id, Lead> getRelatedLeads(List<Account> accounts) {
		Set<Id> idLeads = new Set<Id>();

		for (Account account : accounts) {
			idLeads.add(account.Lead_Converted_Id__c);
		}

		return new Map<Id, Lead>([SELECT Id FROM Lead WHERE Id IN :idLeads]);
	}

	/**
	 * @description getRelatedEventsFirstMeeting retrieves a list of Events
	 * for the given Lead ids and type.
	 * @param  idLeads  Lead identifiers
	 * @param  type     Type of Event
	 * @return Map<Id, List<Event>> ordered most recent first
	 */
	@TestVisible
	private static Map<Id, List<Event>> getRelatedEvents(Set<Id> idLeads, String type) {
		Map<Id, Id> leadToAccount = new Map<Id, Id>();

		Map<Id, List<Event>> result = new Map<Id, List<Event>>();

		for (Id idLead : idLeads) {
			result.put(idLead, new List<Event>());
		}

		for (Event event : [
			SELECT Id, WhoId, WhatId, Event_Source__c, StartDateTime, CreatedBy.Name
			FROM Event
			WHERE Type = :type
			AND WhoId IN :idLeads
			ORDER BY StartDateTime DESC
		]) {
			result.get(event.WhoId).add(event);
		}

		return result;
	}			
}