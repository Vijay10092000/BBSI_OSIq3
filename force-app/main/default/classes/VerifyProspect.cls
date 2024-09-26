/**
 * @description VerifyProspect is a controller for the VerifiyProspect page.  It contains
 * methods to confirm the address of an account.
 */
public without sharing class VerifyProspect {
	/**
	 * @description pullAccountRecord verifies and corrects the Account address.
	 * @return PageReference to the Account
	 */
	public PageReference pullAccountRecord() {
		Id idAccount = String.valueOf(ApexPages.currentPage().getParameters().get('id'));

		VerifyProspect.updateAccount(idAccount);

		PageReference reference = new PageReference('/' + idAccount);
		reference.setRedirect(true);

		return reference;
	}

	/**
	 * @description udpateAccount calls out to StrikeIron to verify the address.  The
	 * Account address is updated if callout is successful.
	 * @param  idAccount idAccount description
	 */
	public static void updateAccount(Id idAccount) {
		Account a = [
			SELECT Id, RecordTypeId, Name, Verified__c, Verified_Status__c,
				BillingStreet, BillingCity, BillingState, BillingPostalCode,
				BillingLatitude, BillingLongitude, County__c
			FROM Account
			WHERE Id = :idAccount
		];

		Map<String, String> addressData = HttpCallout.retrieveAddressData(
			a.BillingStreet,
			a.BillingCity,
			a.BillingState,
			a.BillingPostalCode,
			'US'
		);

		if (addressData != null && addressData.get('AddressStatus') == 'Valid') {
			a.Verified_Status__c = 'Address Verified';
			a.Verified__c = true;

			a.BillingStreet = addressData.get('AddressLine1');
			a.StrikeIron_Address__c = addressData.get('AddressLine1');

			if (addressData.get('AddressLine2') != null) {
				a.BillingStreet += '\n' + addressData.get('AddressLine2');
				a.StrikeIron_Address__c += '\n' + addressData.get('AddressLine2');
			}

			a.BillingCity =  addressData.get('City');
			a.StrikeIron_City__c =  addressData.get('City');

			a.BillingState = addressData.get('State');
			a.StrikeIron_State__c = addressData.get('State');

			a.BillingPostalCode = addressData.get('ZIPPlus4');
			a.StrikeIron_Zip__c = addressData.get('ZIPPlus4');

			a.County__c = addressData.get('County');
			a.StrikeIron_County__c = addressData.get('County');

			a.BillingLatitude = Double.valueOf(addressData.get('Latitude'));
			a.BillingLongitude = Double.valueOf(addressData.get('Longitude'));
		} else {
			a.Verified_Status__c = addressData.get('StatusDescription');
			a.Verified__c = false;
		}

		try {
			update a;
		} catch (DMLException e) {
			System.debug(LoggingLevel.ERROR, 'EXCEPTION: Updating Address\n' + e);
		}
	}
}