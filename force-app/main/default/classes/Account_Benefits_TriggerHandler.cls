/**
 * @description Account_Benefits_TriggerHandler controls trigger events for Account objects for the Benefits project.
 */
public without sharing class Account_Benefits_TriggerHandler extends TriggerHandlerInvoker.TriggerHandler_Abstract {
	override public void afterInsert(Map<Id, SObject> mapNew) {
		Map<Id, Account> newAccounts = (Map<Id, Account>) mapNew;

		BenefitsAffiliatesAccount.handleAfter(null, newAccounts.values());
	}

	override public void beforeUpdate(Map<Id, SObject> mapOld, Map<Id, SObject> mapNew) {
		Map<Id, Account> oldAccounts = (Map<Id, Account>) mapOld;
		Map<Id, Account> newAccounts = (Map<Id, Account>) mapNew;

		BenefitsAffiliatesAccount.handleBefore(oldAccounts, newAccounts.values());
	}

	override public void afterUpdate(Map<Id, SObject> mapOld, Map<Id, SObject> mapNew) {
		Map<Id, Account> oldAccounts = (Map<Id, Account>) mapOld;
		Map<Id, Account> newAccounts = (Map<Id, Account>) mapNew;

		BenefitsAffiliatesAccount.handleAfter(oldAccounts, newAccounts.values());
	}
}