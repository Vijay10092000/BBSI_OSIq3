/**
 * @description AccountProspectOnboard methods to aid onboarding prospects.
 */
public inherited sharing class AccountProspectOnboard {
	@TestVisible
	private static final String FORMAT_SUBJECT = '{0} - {1} - Onboard - {2}';

	private static final String FORMAT_DESCRIPTION =
		'A new client is ready to onboard in the {0} branch.' +
		'\nClient Name:  {1}' +
		'\nAccount Owner:  {2}' +
		'\nBranch:  {0}' +
		'\nEstimated Annual Payroll:  {3}' +
		'\nState(s) of Operation:  {4}';

	/**
	 * @description createOnboardingCase creates a Contract case.  It should only be called when
	 * the Prospect's Client Id is returned from Boomi/Prism.
	 * @param  opportunity Related Opportunity record
	 * @return The inserted Case
	 */
	public static Case createOnboardingCase(Opportunity opportunity) {
		Case newCase = null;

		if (opportunity != null) {
			if (String.isNotBlank(opportunity.Id)) {
				newCase = buildOnboardingCase(opportunity);

				if (newCase != null) {
					insert newCase;
				}
			}
		}

		return newCase;
	}

	/**
	 * @description buildOnboardingCase creates Onboarding Cases for the given
	 * Opportunities.
	 * @param  opportunity  Opportunity which need a Case
	 * @return Created Case
	 */
	@TestVisible
	private static Case buildOnboardingCase(Opportunity opportunity) {
		Id idContractsQueue = [SELECT Id FROM Group WHERE Name = 'Contracts' AND Type = 'Queue' LIMIT 1].Id;

		Account prospect = [
			SELECT Id, Name, Client__c, OwnerId, Owner.Name, Owner.Branch_Id__c
			FROM Account
			WHERE Id = :opportunity.AccountId
		];

		String branchId = prospect.Owner.Branch_Id__c;
		Account branch = null;
		if (branchId != null) {
			branch = [
				SELECT Id, Name
				FROM Account
				WHERE RecordType.Name = 'BBSI Branch' AND External_ID__c = :branchId
			];
		}

		Contact contact = getUserContact(prospect.OwnerId);

		return createCase(
			opportunity,
			idContractsQueue,
			prospect.Name,
			prospect.Client__c,
			contact?.Id,
			contact?.Name,
			branch?.Name,
			branch?.Id
		);
	}

	/**
	 * @description getUserContact retrieves the Contact related to the User Owner.
	 * @param  idUser  User Owner Id
	 * @return Contact
	 */
	@TestVisible
	private static Contact getUserContact(Id idUser) {
		List<Contact> contacts = [
			SELECT Id, Name
			FROM Contact
			WHERE RecordType.Name = 'BBSI Employee' AND User_Id__c = :idUser
		];

		if (contacts.isEmpty()) {
			return null;
		}

		return contacts.get(0);
	}

	/**
	 * @description createCase creates and Onboarding Case.
	 * @param  opp               Opportunity
	 * @param  idContractsQueue  Contracts Queue identifier
	 * @param  nameProspect      Name of the Prospect account
	 * @param  clientId          Client Prism Identifier
	 * @param  idProspectOwner   Owner of the Opportunity's Prospect Account
	 * @param  nameOwner         Name of the Owner of the Opportunity's Prospect Account
	 * @param  nameOwnerBranch   Branch  of the Owner of the Opportunity's Prospect Account
	 * @param  idOwnerBranch     Identifier of the Owner's Branch
	 * @return Case with the given information
	 */
	@SuppressWarnings('PMD.ExcessiveParameterList')
	@TestVisible
	private static Case createCase(
		Opportunity opp,
		Id idContractsQueue,
		String nameProspect,
		String clientId,
		Id idProspectOwner,
		String nameOwner,
		String nameOwnerBranch,
		Id idOwnerBranch
	) {
		return new Case(
			RecordTypeId = RecordTypeService.getId('Case', 'Client/Referral Partner'),
			Type = 'Contracts',
			Type__c = 'New Client Onboard',
			OwnerId = idContractsQueue,
			ContactId = idProspectOwner,
			Origin = 'Salesforce',
			AccountId = opp.AccountId,
			Branch__c = idOwnerBranch,
			Priority = 'High',
			Subject = String.format(FORMAT_SUBJECT, new List<String>{ clientId, nameProspect, nameOwnerBranch }),
			Description = String.format(
				FORMAT_DESCRIPTION,
				new List<String>{
					nameOwnerBranch,
					nameProspect,
					nameOwner,
					String.valueOf(opp.Client_Annual_Payroll__c),
					opp.States_of_Operation__c
				}
			)
		);
	}
}