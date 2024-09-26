/**
 * @description Account_TriggerHandler controls trigger events for Account objects.
 */
public without sharing class Account_TriggerHandler extends TriggerHandlerInvoker.TriggerHandler_Abstract {
	override public void beforeInsert(List<SObject> listNew) {
		List<Account> newAccounts = (List<Account>) listNew;

		AccountConversion.updateConvertedAccounts(newAccounts);
		AccountProspect.setPriceApprovalDate(null, newAccounts);
		AccountReferralPartner.setExternalId(null, newAccounts);
		Account_Services.setDefaults(newAccounts);
		Account_Services.changeOfBranch(null, newAccounts);
		Account_Services.setBranchData(null, newAccounts);
		Account_Services.setHeadquarterState(null, newAccounts);
		AccountClient.updateBusinessUnit(null, newAccounts);
		Account_Services.formatPhoneNumber(null, RecordTypeService.getByRecordType(newAccounts, 'Account', 'Prospect'));
		Account_Services.populateReferralPartnerStatus(newAccounts);
		Account_Services.populateOwnerForStaffingAndLocationAccounts(newAccounts);
		Account_Services.populateNAICSInformation(newAccounts, null);
		Account_Services.assignAccountFEINs(newAccounts, null);
		AccountBranch.setClientBenefitsFields(newAccounts);

		AccountHub.setRegion(null, newAccounts);
	}

	override public void afterInsert(Map<Id, SObject> mapNew) {
		Map<Id, Account> newAccounts = (Map<Id, Account>) mapNew;

		Account_Services.updateBranchNames(null, newAccounts);
        Account_Services.updateProspectReferralSources(null, newAccounts.values());
        Account_Services.confirmReferralSource(null, newAccounts);
        Account_Services.populateBusinessUnitMembers(newAccounts.values(),null);
        Account_Services.processPriceApproval(newAccounts,null);
        (new BdmSharing()).processAccounts(null, newAccounts.values());
        Account_Services.updateAccountFEINs(newAccounts.values(), null);
        Account_Services.onAccountTermination(null, newAccounts);
        AccountProspect.sendEmailAssignedBU(null, newAccounts);
		AccountClient.informAreaManager(null, newAccounts.values());
	}

	override public void beforeUpdate(Map<Id, SObject> mapOld, Map<Id, SObject> mapNew) {
		Map<Id, Account> oldAccounts = (Map<Id, Account>) mapOld;
		Map<Id, Account> newAccounts = (Map<Id, Account>) mapNew;

		AccountProspect.setPriceApprovalDate(oldAccounts, newAccounts.values());
		AccountReferralPartner.setExternalId(oldAccounts, newAccounts.values());
		AccountTerminated.updateTerminated(oldAccounts, newAccounts);
		Account_Services.changeOfBranch(oldAccounts, newAccounts.values());
		Account_Services.setBranchData(oldAccounts, newAccounts.values());
        Account_Services.setHeadquarterState(null, newAccounts.values());
		AccountClient.updateBusinessUnit(oldAccounts, newAccounts.values());
        Account_Services.formatPhoneNumber(oldAccounts, RecordTypeService.getByRecordType(newAccounts.values(), 'Account', 'Prospect'));
        Account_Services.populateReferralPartnerStatus(newAccounts.values());
        Account_Services.processReferralPartnerIDChangesBefore(newAccounts, oldAccounts);
        Account_Services.populateNAICSInformation(newAccounts.values(),oldAccounts);
        Account_Services.populateBranch(newAccounts,oldAccounts);
        Account_Services.populateBusinessUnitMembers(newAccounts.values(), oldAccounts);
        Account_Services.checkReferralPartnerFEIN(newAccounts, oldAccounts);
        Account_Services.processPriceApproval(newAccounts, oldAccounts);
        Account_Services.assignAccountFEINs(newAccounts.values(), oldAccounts.values());
        AccountBranch.updateAreaManagerEmails(newAccounts.values(), oldAccounts);

		AccountHub.setRegion(oldAccounts, newAccounts.values());
	}

	override public void afterUpdate(Map<Id, SObject> mapOld, Map<Id, SObject> mapNew) {
		Map<Id, Account> oldAccounts = (Map<Id, Account>) mapOld;
		Map<Id, Account> newAccounts = (Map<Id, Account>) mapNew;

		AccountBranch.updateBenefitsPeople(oldAccounts, newAccounts.values());
		Account_Services.updateBranchNames(oldAccounts, newAccounts);
		AccountHub.updateHubBranches(oldAccounts, newAccounts);
        Account_Services.updateProspectReferralSources(oldAccounts, newAccounts.values());
        Account_Services.confirmReferralSource(oldAccounts, newAccounts);
        (new BdmSharing()).processAccounts(oldAccounts, newAccounts.values());
		Account_Services.updateOpportunityFields(oldAccounts, newAccounts);
        OpportunityStageName.updateOpportunityCloseWon(newAccounts);
        Account_Services.processRenewalTermination(newAccounts.values(), oldAccounts);
        RenewalChangeOwner.ProcessRenewalChangeOwner(oldAccounts, newAccounts.values());
        Account_Services.updateAccountFEINs(newAccounts.values(), oldAccounts.values());  // !!! FIX CALLING ACOUNT TRIGGER
        AccountBranch.updateAreaManager(newAccounts, oldAccounts);
        Account_Services.onReferralPartnerGroupChange(oldAccounts, newAccounts);
        Account_Services.onAccountTermination(oldAccounts, newAccounts);
        AccountProspect.sendEmailAssignedBU(oldAccounts, newAccounts);
		AccountClient.informAreaManager(oldAccounts, newAccounts.values());
		Account_Services.updateBenefits(oldAccounts, newAccounts.values());

		ContactClient.updateFields(oldAccounts, newAccounts);
	}
}