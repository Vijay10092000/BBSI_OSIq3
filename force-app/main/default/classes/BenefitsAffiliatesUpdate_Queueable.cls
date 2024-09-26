/**
 * @description BenefitsAffiliatesUpdate_Queueable updates the related Accounts
 * Opportunities and Benfits of Benefits Affiliates.
 */
public without sharing class BenefitsAffiliatesUpdate_Queueable implements Queueable {
	private static Boolean alreadyRun = false;

	private Set<Id> idAffiliates;
	private Map<Id, Benefits_Affiliates__c> affiliates;
	private Map<Id, Benefits__c> benefits;

	/**
	 * @description updateRelatedRecords
	 * @param  idAffiliates
	 */
	public static void updateRelatedRecords(Set<Id> idAffiliates) {
		if (idAffiliates != null && !idAffiliates.isEmpty()) {

			if (alreadyRun) {
				Log log = new Log(
					Log.Severity.ERROR,
					'Benefits',
					'BenefitsAffiliatesUpdate_Queueable.updateRelatedRecords() already run',
					'Benefits Data for the following Benefits Affilaites and related records should be reviewd.'
				);
				log.addLine('Benefits Affiliate Ids: ');

				for (Id id : idAffiliates) {
					log.addLine('  ' + id);
				}

				Log.write();
			}

			System.enqueueJob(new BenefitsAffiliatesUpdate_Queueable(idAffiliates));
			alreadyRun = true;
		}
	}

	/**
	 * @description BenefitsAffiliatesUpdate_Queueable constructor.
	 * @param  idAffiliates  Benefits_Affiliates__c identifiers
	 */
	public BenefitsAffiliatesUpdate_Queueable(Set<Id> idAffiliates) {
		this.idAffiliates = idAffiliates;
	}

	/**
	 * @description execute runs through the related accounts, opportunitys and benefits
	 * to update those which need it.
	 * @param  context  Information about the Queueable job
	 */
	public void execute(QueueableContext context) {
		affiliates = BenefitsAffiliates.selectAffiliates(idAffiliates);

		String textDebug = '';
		for (Benefits_Affiliates__c ba : affiliates.values()) {
			textDebug += '\n  AFFILIATE: ' + ba.Id + '  NAME: ' + ba.Name;
			textDebug += '\n  Companies: ' + ba.Benefits_Affiliated_Companies__c;
			textDebug += '\n';
		}
		System.debug(LoggingLevel.FINER, 'BenefitsAffiliatesUpdate_Queueable.execute()' + textDebug);

		if (!affiliates.isEmpty()) {
			processAccounts(affiliates.keySet());
			processOpportunities(affiliates.keySet());
			processBenefits(affiliates.keySet());
		}
	}

	/**
	 * @description processAccounts updates the Accounts related to the Benefits Affilates.
	 * Updates are only made if a change to the Benefits fields have happened.
	 * @param  idAffiliates  Set of changed Affiliates
	 */
	@TestVisible
	private void processAccounts(Set<Id> idAffiliates) {
		Map<Id, Account> accounts = BenefitsAffiliatesAccount.selectAccountsByAffiliates(idAffiliates);

		List<Account> updatedAccounts = getUpdateAccounts(accounts.values());

		if (!updatedAccounts.isEmpty()) {
			//DatabaseUpdateBatch.dispatch(updatedAccounts, false, 'Benefits Affiliates', 'Update Accounts Failed');
			update updatedAccounts;
			List<Referral_Partner__c> rsList = new List<Referral_Partner__c>();
			for (Account acc : updatedAccounts) {
				rsList.addAll(acc.Referral_Partners__r);
			}
			if(!rsList.isEmpty()){
				update rsList;
			}
		}
	}

	/**
	 * @description processOpportunities updates the Opportunties related to the Benefits Affilates.
	 * Updates are only made if a change to the Benefits fields have happened.
	 * @param  idAffiliates  Set of changed Affiliates
	 */
	@TestVisible
	private void processOpportunities(Set<Id> idAffiliates) {
		Map<Id, Opportunity> opps = BenefitsAffiliatesOpportunity.selectOpportuntiesByAffiliates(affiliates.keySet());

		List<Opportunity> updatedOpps = getUpdateOpportunties(opps.values());

		if (!updatedOpps.isEmpty()) {
			//DatabaseUpdateBatch.dispatch(updatedOpps, false, 'Benefits Affiliates', 'Update Opportunities Failed');
			update updatedOpps;
		}
	}

	/**
	 * @description processBenefits updates the Benefits related to the Benefits Affilates.
	 * Updates are only made if a change to the Benefits fields have happened.
	 * @param  idAffiliates  Set of changed Affiliates
	 */
	@TestVisible
	private void processBenefits(Set<Id> idAffiliates) {
		Map<Id, Benefits__c> benefits = BenefitsAffiliatesBenefits.selectBenefitsByAffiliates(affiliates.keySet());

		List<Benefits__c> updatedBenefits = getUpdateBenefits(benefits.values());

		if (!updatedBenefits.isEmpty()) {
			//DatabaseUpdateBatch.dispatch(updatedBenefits, false, 'Benefits Affiliates', 'Update Benefits Failed');
			update updatedBenefits;
		}
	}

	/**
	 * @description getUpdateAccounts determines which Accounts need to be updated.
	 * @param  accounts  Accounts to review
	 * @return List of Accounts to update
	 */
	@TestVisible
	private List<Account> getUpdateAccounts(List<Account> accounts) {
		List<Account> result = new List<Account>();

		for (Account client : accounts) {
			Benefits_Affiliates__c ba = affiliates.get(client.Benefits_Affiliates__c);

			if (BenefitsAffiliatesUpdates.updateRelated(client, ba)) {
				result.add(client);
			}
		}

		return result;
	}

	/**
	 * @description getUpdateOpportunties determines which Opportunties need to be updated.
	 * @param  opps  Opportunties to review
	 * @return List of Opportunties to update
	 */
	@TestVisible
	private List<Opportunity> getUpdateOpportunties(List<Opportunity> opps) {
		List<Opportunity> result = new List<Opportunity>();

		for (Opportunity opp : opps) {
			if(opp.RecordTypeId == OpportunityBenefits_Service.BenefitsRT){
				Benefits_Affiliates__c ba = affiliates.get(opp.Benefits_Affiliates__c);

				if (BenefitsAffiliatesUpdates.updateRelated(opp, ba)) {
					result.add(opp);
				}
			}
		}

		return result;
	}

	/**
	 * @description getUpdateBenefits determines which Benefits need to be updated.
	 * @param  benefits  Benefits to review
	 * @return List of Benefits to update
	 */
	@TestVisible
	private List<Benefits__c> getUpdateBenefits(List<Benefits__c> benefits) {
		List<Benefits__c> result = new List<Benefits__c>();

		for (Benefits__c b : benefits) {
			Benefits_Affiliates__c ba = affiliates.get(b.Benefits_Affiliates__c);

			if (BenefitsAffiliatesUpdates.updateRelated(b, ba)) {
				result.add(b);
			}
		}

		return result;
	}
}