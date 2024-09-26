/**
 * @description CheckRPFEIN contains methods to determine if a Referral Partner is changing FEIN to one
 * which already exists.
 */
public with sharing class CheckRPFEIN {
	/**
	 * @description idrtReferralPartner contains the Record Type identifier for a Referral Partner Account.
	 */
	private static Id idrtReferralPartner = RecordTypeService.getId('Account', 'Referral Partner');

	/**
	 * @description allowedDuplicateFeins contains the list of FEINs which may be duplicated.
	 */
	@TestVisible
	private static Set<String> allowedDuplicateFeins = new Set<String>();

	/**
	 * @description checkReferralPartnerFEIN make sure no Referral Partner Account is duplicating a FEIN.
	 * @param  mapAccounts    Accounts after change
	 * @param  mapOldAccounts Accounts before change
	 */
	public static void checkReferralPartnerFEIN(Map<Id, Account> mapAccounts, Map<Id, Account> mapOldAccounts) {
		Map<String, Account> mapFeins = new Map<String, Account>();

		for (Account a : mapAccounts.values()) {
			if (a.recordTypeId == idrtReferralPartner) {
				if (a.Fein__c != null) {
					String oldFein = mapOldAccounts.get(a.Id).Fein__c;
					if (a.Fein__c != oldFein) {
						mapFeins.put(a.Fein__c, a);
					}
				}
			}
		}

		if (mapFeins.size() > 0) {
			readAllowedDuplicateFeins();
			checkForDuplicates(mapFeins);
		}
	}

	/**
	 * @description checkForDuplicates search the given list of FEINS for duplicate Accounts.
	 * @param  mapFeins FEINs to search for
	 */
	private static void checkForDuplicates(Map<String, Account> mapFeins) {
		for (Account a : [
			SELECT Id, Fein__c
			FROM Account
			WHERE Fein__c IN :mapFeins.keySet() AND RecordTypeId = :idrtReferralPartner
		]) {
			if (!allowedDuplicateFeins.contains(a.Fein__c)) {
				mapFeins.get(a.Fein__c).addError('You cannot enter in a duplicate FEIN for Referral Partner');
				Log.warn(
					'Accounts - CheckRPFEIN.checkForDuplicates()',
					'Duplicate Feins',
					'Referral Partners cannot have duplicate FEINs.  FEIN: ' + a.Fein__c
				);
			}
		}
	}

	/**
	 * @description readAllowedDuplicateFeins reads the list of FEINs which are allowed to be duplicated
	 * @return A Set of FEINs
	 */
	private static void readAllowedDuplicateFeins() {
		for (Referral_Partner_Duplicate_FEIN__mdt fein : [
			SELECT Id, Fein__c
			FROM Referral_Partner_Duplicate_FEIN__mdt
		]) {
			allowedDuplicateFeins.add(fein.Fein__c);
		}
	}
}