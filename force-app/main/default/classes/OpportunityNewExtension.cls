/**
 * @description OpportunityNewExtension redirects where the "New" Opportunity goes.
 * Show the blocker page, NewOpportunityWarning, for Creation of Shell and Client
 * Opportunity RecordTypes.  For other RecordType this creates an Opportunity of
 * the given type and go to edit.
 *
 * TODO: FUTURE: Determine if can call standard New Opportunity and not create
 *     a new Opportunity for edit.  All attempts so far have not worked.
 *
 * URL ATTEMPTS TO GET AT THE STANDARD NEW OPPORTUNITY
 * 0060r000009iDasAAE is a created opportunity
 * 0120r000000AOS6AAO is the Benefits RecordType
 *
 *     /006/e?Id=0060r000009iDasAAE                                  Goes to STOP Screen
 *     /006/e?RecordTypeId=0120r000000AOS6AAO                        Goes to STOP Screen
 *     /o/Opportunity/new?count=1&RecordTypeId=0120r000000AOS6AAO    Goes to STOP Screen
 *     /006/e?Id=0060r000009iDasAAE                                  Goes to STOP Screen
 *     /r/Opportunity/0060r000009iDasAAE/edit                        Goes to STOP Screen
 *     /o/Opportunity/0060r000009iDasAAE/edit                        Breaks
 */
public without sharing class OpportunityNewExtension {
	private static final String ERROR_CREATE_SHELL = 'Creation of Shell opportunity may not be created';
	private static final String ERROR_CLIENT_PROSPECT_ONLY = 'A Client opportunity may only be created on a Prospect account;';
	private static final String ERROR_EXISTING_CLIENT_OPPORTUNITY = 'Active Client opportunity already exists on the Prospect account';

	@TestVisible
	private Boolean showBlocker { get; set; }
	@TestVisible
	private String message { get; set; }
	@TestVisible
	private String idAccount { get; set; }
	@TestVisible
	private String idrtNewOpp { get; set; }
	@TestVisible

	/**
	 * @description OpportunityNewExtension constructor.
	 * @param  controller  Standard Controller
	 */
	public OpportunityNewExtension(ApexPages.StandardController controller) {
		Opportunity opp = (Opportunity) controller.getRecord();

		idAccount = opp.AccountId;
		idrtNewOpp = opp.RecordTypeId;

		Account account = [SELECT Id, Name, RecordType.Name FROM Account WHERE Id = :idAccount];

		showBlocker = false;

		if (opp.RecordTypeId == RecordTypeService.getId('Opportunity', 'Creation of Shell')) {
			message = ERROR_CREATE_SHELL;
			showBlocker = true;
		}
		else if (opp.RecordTypeId == RecordTypeService.getId('Opportunity', 'Client')) {
			if (account.RecordType.Name == 'Prospect') {
				Map<Id, Boolean> createable = OpportunityClient.mayCreate(new Set<Id>{ idAccount });

				if (!createable.get(idAccount)) {
					message = ERROR_EXISTING_CLIENT_OPPORTUNITY;
					showBlocker = true;
				}
			} else {
				message = ERROR_CLIENT_PROSPECT_ONLY;
				showBlocker = true;
			}
		}
	}

	/**
	 * @description redirect determine where to redirect.
	 * @return Pagereference
	 */
	public PageReference redirect() {
		PageReference page = null;

		if (showBlocker) {
			page = new PageReference('/apex/NewOpportunityWarning');			
			page.setRedirect(true);
		} else {
			try {
				Account client = [SELECT Id, Name FROM Account WHERE Id = :idAccount];

				RecordType rt = [SELECT Id, Name FROM RecordType WHERE Id = :idrtNewOpp];

				Date closeDate = (rt.Name == 'Client') ? OpportunityClient.getCloseDate() : Date.today().addDays(30);

				Opportunity opp = new Opportunity(
					Name = rt.Name + ': ' + client.Name,
					AccountId = idAccount,
					RecordTypeId = rt.Id,
					StageName = Opportunity_Service.firstStage(rt.Name),
					CloseDate = closeDate
				);

				insert opp;

				page = new PageReference('/' + opp.Id);
			} catch (Exception e) {
				System.debug(LoggingLevel.ERROR, 'Failed to create Opportunity.  Exception\n' + e);
				page = new PageReference(ApexPages.currentPage().getParameters().get('retURL'));
			}
		}

		return page;
	}
}