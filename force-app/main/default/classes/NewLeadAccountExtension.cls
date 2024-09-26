/**
 * @description NewLeadAccountExtension creates a new Lead from the given Account.
 */
public without sharing class NewLeadAccountExtension {
	/**
	 * @description account is the account being processed in the controller.
	 */
	public Account account { get; set; }

	/**
	 * @description NewLeadAccountExtension constructor
	 * @param  controller Base controller
	 */
	public NewLeadAccountExtension(ApexPages.StandardController controller) {
		if (controller != null) {
			account = [
				SELECT 
					Id, 
					Name, 
					Assigned_Referral_Partner__c,
					Producer__c,
					BillingStreet,
					BillingCity,
					BillingState,
					BillingCountry,
					BillingPostalCode,
					Prospect_Branch__c,
					Business_Development_Manager__c,
					X_Mod__c,
					NAICS__c,
					FEIN__c,
					External_Id__c,
					Phone,
					Lead_Source__c,
					Account_Source_Other__c
				FROM Account
				WHERE Id = :controller.getRecord().Id
			];
		}
	}

	/**
	 * @description newLead creates a new Lead based on the Account and primary
	 * Contact.
	 * @return The new Lead PageReference, null on error
	 */
	public PageReference newLead() {
		try {
			if (confirmAccount()) {
				Lead newLead = makeLead();

				insert newLead;

				PageReference pageRef = new PageReference('/' + newLead.Id);
				pageRef.setRedirect(true);
				
				return pageRef;
			}
		} catch (Exception e) {
			addPageError(
				'An unexpected error occurred while creating the lead.  Please contact support.\n' + e.getMessage()
			);
			System.debug(LoggingLevel.ERROR, 'NewLeadAccountExtension.newLead() Exception: ' + e.getMessage() + '\n' + e.getStackTraceString());
		}

		return null;
	}

	/**
	 * @description getPrimaryContact retrieves information about the Primary contact of the
	 * given Account
	 * @return Primary Contact of given Account
	 */
	private Contact getPrimaryContact() {
		List<Contact> contacts = [
			SELECT Id, Name, Active__c, LastName, Direct__c, Phone, MobilePhone
			FROM Contact
			WHERE AccountId = :account.Id AND Primary__c = TRUE AND Active__c = TRUE
			ORDER BY CreatedDate DESC
		];

		if (contacts.isEmpty()) {
			return null;
		}

		return contacts[0];
	}

	/**
	 * @description addPageError adds an error to the displayed page
	 * @param  text Text to put in error
	 */
	private void addPageError(String text) {
		ApexPages.Message myMsg = new ApexPages.Message(ApexPages.Severity.ERROR, text);
		ApexPages.addMessage(myMsg);
	}

	/**
	 * @description confirmAccount checks the Account is OK to be cloned.
	 * @return true if OK, false if not
	 */
	private Boolean confirmAccount() {
		if (account.Assigned_Referral_Partner__c == null || account.Producer__c == null) {
			addPageError(
				'The account ' +
				account.Name +
				' is missing an assigned referral partner or producer.' +
				' Please fix the account before trying again.'
			);

			System.debug(LoggingLevel.ERROR, 'NewLeadAccountExtension.confirmAccount: NULL Referral Partner and/or Producer');
			return false;
		}

		Contact producer = [SELECT Id, AccountId FROM Contact WHERE Id = :account.Producer__c LIMIT 1];

		if (account.Assigned_Referral_Partner__c != producer.AccountId) {
			addPageError(
				'The Producer must be a contact of the assigned Referral Partner. Please fix the account ' +
				account.Name +
				' before trying again.'
			);

			System.debug(LoggingLevel.ERROR, 'NewLeadAccountExtension.confirmAccount: NULL Producer not a Contact for the Referral Partner');
			return false;
		}

		return true;
	}

	/**
	 * @description makeLead creates the cloned Lead from the Account
	 * @return The cloned Lead or null on error
	 */
	private Lead makeLead() {
		Contact primary = getPrimaryContact();

		String lastName = (String.isBlank(primary?.LastName) ? 'Unknown' : primary.LastName);
		
		Lead result = new Lead(
			LastName = lastName,
			Phone = PhoneNumber.forcePhoneNumber(primary?.Phone, false),
			MobilePhone = PhoneNumber.forcePhoneNumber(primary?.MobilePhone, false),
			Direct__c = PhoneNumber.forcePhoneNumber(primary?.Direct__c, false),
			Company = account.Name,
			Street = account.BillingStreet,
			City = account.BillingCity,
			State = account.BillingState,
			Country = account.BillingCountry,
			PostalCode = account.BillingPostalCode,
			Branch__c = account.Prospect_Branch__c,
			Business_Development_Manager__c = account.Business_Development_Manager__c,
			X_Mod__c = account.X_Mod__c,
			NAICS__c = account.NAICS__c,
			FEIN__c = account.FEIN__c,
			Referral_Partner__c = account.Assigned_Referral_Partner__c,
			Producer__c = account.Producer__c,
			Cloned_from_Client__c = account.External_Id__c,
			LeadSource = account.Lead_Source__c,
			Other_Lead_Source_Type__c = Account.account_Source_Other__c
		);

		if (result.Phone == null && result.MobilePhone == null && result.Direct__c == null) {
			result.Phone = PhoneNumber.forcePhoneNumber(account.Phone, false);
		}

		if (!PhoneNumber.isValid(result.Phone, true) &&
			!PhoneNumber.isValid(result.MobilePhone, true) &&
			!PhoneNumber.isValid(result.Direct__c, true)) {
			addPageError(
				'No phone number available for Lead.  Account ' +
				account.Name +
				' or its Primary Contact should have a valid phone number: ###-###-####'
			);

			return null;
		}

		return result;
	}
}