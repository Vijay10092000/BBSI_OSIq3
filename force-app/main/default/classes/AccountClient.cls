/**
 * @description AccountClient contains methods for Client Accounts.
 */
public without sharing class AccountClient {
    /**
     * @description updateBusinessUnit sets the Business Unit change date and sends email on change.
     * @param  oldValues  Previous values of the Accounts
     * @param  newValues  New values for the Accounts
     */
	public static void updateBusinessUnit(Map<Id, Account> oldValues, List<Account> newValues) {
		for (Account account : newValues) {
			if (oldValues == null && account.Business_Unit__c == null) {
				// New account with no Business Unit
				continue;
			}

			if (oldValues == null || oldValues.get(account.Id).Business_Unit__c != account.Business_Unit__c) {
				if (account.Business_Unit__c == null) {
					account.BU_Assignment_Date__c = null;
				} else {
					account.BU_Assignment_Date__c = Date.today();
				}
			}
		}
	}

    /**
     * @description informAreaManager sends email to the AM on Business Unit change.
     * @param  oldValues  Previous values of the Accounts
     * @param  newValues  New values for the Accounts
     */
	public static void informAreaManager(Map<Id, Account> oldValues, List<Account> newValues) {
		Id idrtClient = RecordTypeService.getId('Account', 'Client');
		Id idrtTerminated = RecordTypeService.getId('Account', 'Terminated');

		List<Messaging.SingleEmailMessage> emails = new List<Messaging.SingleEmailMessage>();

		for (Account account : newValues) {
			if (oldValues?.get(account.Id).Business_Unit__c != account.Business_Unit__c) {
				// New account with Business Unit or existing account Business Unit has changed.
				if (account.Area_Manager_Email__c  != null) {
					if (account.RecordTypeId == idrtClient || account.RecordTypeId == idrtTerminated) {
						emails.add(
							Email_Service.buildTemplateEmail(
								new List<String>{ account.Area_Manager_Email__c },
								null,
								'Business_Unit_Changed_HTML',
								null,
								account.Id
							)
						);
					}
				}
			}
		}

		Email_Service.send(emails);
	}
}