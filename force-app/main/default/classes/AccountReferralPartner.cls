/**
 * @description AccountReferralPartner methods for Referral Partner Accounts.
 */
public without sharing class AccountReferralPartner {
	/**
	 * @description setExternalId sets the Referral Partner's External Id to the Acronym if
	 * the External Id is not set.
	 * @param  oldAccounts  Accounts before changes
	 * @param  newAccounts  Accounts with changes
	 */
	public static void setExternalId(Map<Id, Account> oldAccounts, List<Account> newAccounts) {
		for (Account account : newAccounts) {
			if (RecordTypeService.isType(account.RecordTypeId, 'Account', 'Referral Partner')) {
				if (account.External_Id__c == null) {	
					account.External_Id__c = account.Acronym__c;
				}
			}
		}
	}
}