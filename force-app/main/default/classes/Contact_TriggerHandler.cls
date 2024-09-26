/**
 * @description Contact_TriggerHandler controls trigger events for Contact objects.
 */
public without sharing class Contact_TriggerHandler extends TriggerHandlerInvoker.TriggerHandler_Abstract {
	override public void beforeInsert(List<SObject> listNew) {
		List<Contact> newContacts = (List<Contact>) listNew;

		Contact_Services.setFields(null, newContacts);
		Contact_Services.updateUserAcronym(null, newContacts);
        Contact_Services.setContactOwner(newContacts);
        Contact_Services.setPrimaryOnInsert(newContacts);
		ContactPrimary.checkForDuplicatePrimaryContacts(null, newContacts);
	}

	override public void afterInsert(Map<Id, SObject> mapNew) {
		Map<Id, Contact> newContacts = (Map<Id, Contact>) mapNew;

		ContactPrimary.updatePrimaryContacts(null, newContacts.values());
	}

	override public void beforeUpdate(Map<Id, SObject> mapOld, Map<Id, SObject> mapNew) {
		Map<Id, Contact> oldContacts = (Map<Id, Contact>) mapOld;
		Map<Id, Contact> newContacts = (Map<Id, Contact>) mapNew;

		Contact_Services.setFields(oldContacts, newContacts.values());
		Contact_Services.updateUserAcronym(oldContacts, newContacts.values());
		ContactPrimary.checkForDuplicatePrimaryContacts(oldContacts, newContacts.values());
	}

	override public void afterUpdate(Map<Id, SObject> mapOld, Map<Id, SObject> mapNew) {
		Map<Id, Contact> oldContacts = (Map<Id, Contact>) mapOld;
		Map<Id, Contact> newContacts = (Map<Id, Contact>) mapNew;

		ContactPrimary.updatePrimaryContacts(oldContacts, newContacts.values());
		ContactBenefits.updateBenefitsContact(oldContacts, newContacts);
	}
}