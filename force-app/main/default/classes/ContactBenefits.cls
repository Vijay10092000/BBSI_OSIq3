/**
 * @description ContactBenefits handles the trigger event when a Contact is set or cleared
 * as a Benefits Contact.
 */
public without sharing class ContactBenefits {
	/**
	 * @description updateBenefitsContact performs the actions when a Contact changes its Benefits Contact status.
	 * @param  mapOld  How the Contacts looked before the changes
	 * @param  mapNew  How the Contacts look with the changes
	 */
    public static void updateBenefitsContact(Map<Id, Contact> mapOld, Map<Id, Contact> mapNew) {
		List<Contact> checked = new List<Contact>();
		List<Contact> unchecked = new List<Contact>();

        for (Contact c : mapNew.values()) {
            if (c.Benefits_Contact__c != mapOld.get(c.Id).Benefits_Contact__c) {
                if (c.Benefits_Contact__c) {
                    checked.add(c);
                } else {
                    unchecked.add(c);
                }
            }
        }

		BenefitsContactHandler handler = new BenefitsContactHandler(checked, unchecked);
		handler.perform();
    }

	@TestVisible
	private without sharing class BenefitsContactHandler {
		private Map<Id, Benefits__c> mapBenefits = new Map<Id, Benefits__c>();
		private List<Contact> checked;
		private List<Contact> unchecked;
		private List<Benefits__c> updateBenefits = new List<Benefits__c>();
		private Set<Id> idAccounts = new Set<Id>();

		/**
		 * @description BenefitsContactHandler constructor
		 * @param  checked   checked description
		 * @param  unchecked unchecked description
		 */
		public BenefitsContactHandler(List<Contact> checked, List<Contact> unchecked) {
			this.checked = checked;
			this.unchecked = unchecked;

			for (Contact c : checked) {
				if (c.AccountId != null) {
					idAccounts.add(c.AccountId);
				}
			}

			for (Contact c : unchecked) {
				if (c.AccountId != null) {
					idAccounts.add(c.AccountId);
				}
			}
		}

		/**
		 * @description perform clears and sets the Benefits object based on Contact.
		 */
		public void perform() {
			if (checked.isEmpty() && unchecked.isEmpty()) {
				return;
			}

			handleUnchecked();
			fixBenefits();
		}

		/**
		 * @description handleUnchecked adds Benefits record to update list and clears the current Contact.
		 */
		private void handleUnchecked() {
			Set<Id> idUnchecked = new Set<Id>();
			for (Contact c : unchecked) {
				idUnchecked.add(c.Id);
			}

			List<Benefits__c> updateBenefits = new List<Benefits__c>();

			for (Benefits__c benefits : [
				SELECT
					Id,
					LH_Contact_Name__c,
					Opportunity__c
				FROM Benefits__c
				WHERE LH_Contact_Name__c IN :idUnchecked
			]) {
				benefits.LH_Contact_Name__c = null;
				updateBenefits.add(benefits);
			}

			update updateBenefits;
		}

		private void fixBenefits() {
			Map<Id, Id> mapAccountToContact = new Map<Id, Id>();

			for (Contact c : [
				SELECT Id, AccountId
				FROM Contact
				WHERE AccountId IN :idAccounts
				AND Benefits_Contact__c = TRUE
			]) {
				if (!mapAccountToContact.containsKey(c.AccountId)) {
					mapAccountToContact.put(c.AccountId, c.Id);
				}
			}

			List<Benefits__c> benefits = [
				SELECT Id, AccountId__c, LH_Contact_Name__c, Opportunity__c
				FROM Benefits__c
				WHERE AccountID__c IN :idAccounts
				AND LH_Contact_Name__c = NULL
			];

			for (Benefits__c b : benefits) {
				if (mapAccountToContact.containsKey(b.AccountId__c)) {
					b.LH_Contact_Name__c = mapAccountToContact.get(b.AccountId__c);
				}
			}

			update benefits;
		}
	}
}