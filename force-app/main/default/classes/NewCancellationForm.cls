/**
 * @description NewCancellationForm
 */
public without sharing class NewCancellationForm {
	List<Client_Cancellation__c> newCollection;

	@TestVisible
	Map<Id, Id> parentLookup = new Map<Id, Id>();
	@TestVisible
	Map<Id, Date> coreVisit = new Map<Id, Date>();
	@TestVisible
	Map<Id, Id> lookupBDMs = new Map<Id, Id>();

	List<Client_Cancellation__c> updatedCancellation = new List<Client_Cancellation__c>();

	/**
	 * @description handle performs the new cancellation for the given Client Cancellations.
	 * @param  listNew List of Client_Cancellation__c
	 */
	public void handle(List<SObject> listNew) {
		newCollection = (List<Client_Cancellation__c>) listNew;

		checkUpdate();

		if (parentLookup.size() > 0) {
			findParent();
		}

		if (coreVisit.size() > 0) {
			findCoreVisit();
		}

		if (lookupBDMs.size() > 0) {
			findBDM();
		}
	}

	@TestVisible
	private void checkUpdate() {
		for (Client_Cancellation__c c : newCollection) {
			parentLookup.put(c.Client__c, null);
			coreVisit.put(c.Client__c, null);
			lookupBDMs.put(c.Client__c, null);
		}
	}

	@TestVisible
	private void findParent() {
		for (Account a : [SELECT ParentId FROM Account WHERE Id IN :parentLookup.keySet()]) {
			if (a.ParentId != null) {
				parentLookup.put(a.Id, a.ParentId);
			}
		}

		for (Client_Cancellation__c c : newCollection) {
			c.Parent_Account__c = parentLookup.get(c.Client__c);
		}
	}

	@TestVisible
	private void findCoreVisit() {
		for (Event e : [
			SELECT ActivityDate, WhatID
			FROM Event
			WHERE WhatID IN :coreVisit.keySet() AND RecordType.Name = 'Client Visit'
		]) {
			if (corevisit.get(e.WhatID) != null) {
				if (corevisit.get(e.WhatID) < e.ActivityDate) {
					corevisit.put(e.WhatID, e.ActivityDate);
				}
			} else {
				corevisit.put(e.WhatID, e.ActivityDate);
			}
		}

		for (Client_Cancellation__c c : newCollection) {
			c.Last_Core_Visit__c = corevisit.get(c.Client__c);
		}
	}

	@TestVisible
	private void findBDM() {
		for (Account a : [SELECT Business_Development_Manager__c FROM Account WHERE Id IN :coreVisit.keySet()]) {
			lookupBDMs.put(a.Id, a.Business_Development_Manager__c);
		}

		for (Client_Cancellation__c c : newCollection) {
			if (lookupBDMs.containsKey(c.Client__c)) {
				if (lookupBDMs.get(c.Client__c) != null) {
					c.Business_Development_Manager__c = lookupBDMs.get(c.Client__c);
				}
			}
		}
	}
}