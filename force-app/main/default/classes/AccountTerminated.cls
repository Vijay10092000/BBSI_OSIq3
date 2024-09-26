/**
 * @description AccountTerminated methods for Terminated Accounts.
 */
public without sharing class AccountTerminated {
	private static final String TERMINATED = 'TERMINATED';
    
	/**
	* @description updateTerminated determines if an account has been terminated and
	* the status changed.  The Cancellation_Reason__c is set.
	* @param  oldValues Accounts before changes were made
	* @param  newValues New Accounts with changed values
	*/
	public static void updateTerminated(Map<Id, Account> oldValues, Map<Id, Account> newValues) {
		Id idrtTerminated = RecordTypeService.getId('Account', TERMINATED);

		Set<Id> idTerminated = new Set<Id>();

		for (Account a : newValues.values()) {
			if (a.RecordTypeId == idrtTerminated && a.Status__c == TERMINATED) {
				Account oldAccount = oldValues.get(a.Id);

				if (a.Status__c == TERMINATED) {
					idTerminated.add(a.Id);
				}
			} else {				
				if (a.Cancellation_Reason__c != null) {
					a.Cancellation_Reason__c = null;
				}
			}
		}

		if (!idTerminated.isEmpty()) {
			Map<Id, List<Client_Cancellation__c>> cancellations = getRecentCancellations(idTerminated);

			for (Id id : idTerminated) {
				if (cancellations.containsKey(id)) {
					List<Client_Cancellation__c> ccs = cancellations.get(id);

					Account newAccount = newValues.get(id);
					newAccount.Cancellation_Reason__c = null;

					for (Integer index = ccs.size() - 1; 0 <= index; --index) {
						Client_Cancellation__c cc = ccs.get(index);

						if (cc.AM_Approval_Status__c == 'Approved' && !cc.Revoke__c) {
							newAccount.Cancellation_Reason__c = cc.Reason_for_Cancellation__c;
							break;
						}
					}
				}
			}
		}
	}

	/**
	 * @description getRecentCancellations retrieves Client_Cancellation__c for the Account Ids given.  
	 * Client_Cancellation__c are ordered by by Cancellation Date from oldest to newest.
	 * @param  idAccounts  Account identifiers
	 * @return Map<Id, List<Client_Cancellation__c>>
	 */
	public static Map<Id, List<Client_Cancellation__c>> getRecentCancellations(Set<Id> idAccounts) {
		Map<Id, List<Client_Cancellation__c>> result = new Map<Id, List<Client_Cancellation__c>>();

		for (Id id : idAccounts) {
			result.put(id, new List<Client_Cancellation__c>());
		}		
		for (Client_Cancellation__c cc : [
			SELECT Id, Client__c, Revoke__c, Reason_for_Cancellation__c, Client_Cancellation_Date__c, AM_Approval_Status__c
			FROM Client_Cancellation__c 
			WHERE Client__c IN : idAccounts
			ORDER BY Client_Cancellation_Date__c ASC
		]) {
			result.get(cc.Client__c).add(cc);
		}

		return result;
	}
}