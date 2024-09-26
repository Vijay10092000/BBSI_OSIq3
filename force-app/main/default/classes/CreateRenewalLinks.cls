/**
 * @description CreateRenewalLinks
 */
public without sharing class CreateRenewalLinks {
	/**
	 * @description createRenewalLinks
	 * @param feins  FEIN values
	 */
	public static void createRenewalLinks(List<String> feins) {
		List<Renewal_Link__c> renewalLinks = new List<Renewal_Link__c>();
		List<Renewal__c> renewals = new List<Renewal__c>();
		Renewal_Link__c myRenewalLink;

		Map<String, List<Renewal__c>> mapFeinToRenewals = getFeinToRenewals(feins);

		Set<String> processedFEIN = new Set<String>();

		List<String> tags;

		//first create the ones that do exist.
		for (Renewal_Link__c link : [
			SELECT Id, Description__c, Fein__c
			FROM Renewal_Link__c
			WHERE Fein__c IN :feins
			ORDER BY CreatedDate DESC
		]) {
			if (!processedFEIN.contains(link.Fein__c)) {
				processedFEIN.add(link.Fein__c);
				myRenewalLink = Link;

				tags = new List<String>();
				myRenewalLink.Description__c = '';
				for (Renewal__c renewal : mapFeinToRenewals.get(link.FEIN__c)) {
					String tag = makeTag(renewal);

					if (!tags.contains(tag)) {
						myRenewalLink.Description__c += tag;
						tags.add(tag);
					}

					renewals.add(renewal);
				}
				myRenewalLink.Description__c = String_Services.truncateWithDots(myRenewalLink.Description__c,  255);

				renewalLinks.add(myRenewalLInk);
			}
		}

		for (String fein : mapFeinToRenewals.Keyset()) {
			if (!processedFEIN.Contains(fein)) {
				myRenewalLink = new Renewal_Link__c();
				myRenewalLink.Fein__c = fein;

				tags = new List<String>();
				myRenewalLink.Description__c = '';
				for (Renewal__c renewal : mapFeinToRenewals.get(Fein)) {
					String tag = makeTag(renewal);

					if (!tags.contains(tag)) {
						myRenewalLink.Description__c += tag;
						tags.add(tag);
					}

					renewals.add(renewal);
				}
				myRenewalLink.Description__c = String_Services.truncateWithDots(myRenewalLink.Description__c,  255);

				renewalLinks.add(myRenewalLInk);
			}
		}

		Database.UpsertResult[] urList = Database.upsert(renewalLinks, false);
		Log.writeIfError('Renewals - CreateRenewalLinks.createRenewalLinks()', 'Database Upsert RenewalLinks Failed', null, urList);

		for (Renewal__c renewal : renewals) {
			for (Renewal_Link__c renewalLink : renewalLinks) {
				if (renewal.Fein__c == renewalLink.Fein__c) {
					renewal.Renewal_Link__c = renewalLink.Id;
				}
			}
		}

		Database.SaveResult[] srList = Database.update(renewals, false);
		Log.writeIfError('Renewals - CreateRenewalLinks.createRenewalLinks()', 'Database Update Renewals Failed', null, srList);
	}


	private static Map<String, List<Renewal__c>> getFeinToRenewals(List<String> feins) {
		Map<String, List<Renewal__c>> result = new Map<String, List<Renewal__c>>();

		for (Renewal__c renewal : [
			SELECT Name, Owner.Name, FEIN__c, Business_Unit__c, Renewal_Link__c
			FROM Renewal__c
			WHERE Fein__c IN :feins
			ORDER BY CreatedDate DESC
		]) {
			if (!result.containsKey(renewal.Fein__c)) {
				result.put(renewal.Fein__c, new List<Renewal__c>());
			}

			result.get(renewal.Fein__c).add(renewal);
		}

		return result;
	}

	private static String makeTag(Renewal__c renewal) {
		return renewal.Name + ', ' + renewal.Business_Unit__c + ', ' + Renewal.Owner.Name + '\n';
	}
}