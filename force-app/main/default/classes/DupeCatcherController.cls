/**
 * @description DupeCatcherController controls the component MiniDupeScreen.
 *
 * LATER:
 *     ToolTips:
 * 		https://jsfiddle.net/tvshajeer/be1outpm/
 * 		https://www.w3schools.com/howto/howto_css_tooltip.asp
 */
public without sharing class DupeCatcherController {
	public List<Id> allMatchesSorted = new List<Id>();
	public List<Match__c> dupeMatches = new List<Match__c>();
	LeadDuplicateLog duplicateLog = new LeadDuplicateLog();

	public Lead dupeLead { get; set; }
	public Map<Id, possibleMatches> allMatches { get; set; }
	public List<possibleMatches> displayMatches { get; set; }

	public Boolean showArchive { get; set; }
	public Id recordId { get; set; }

	/**
	 * @description getDuplicates call to get duplicates for the LeadDuplicate component.
	 * @param  idLead  Lead identifier
	 * @return List<possibleMatches>
	 */
	@AuraEnabled
	public static List<possibleMatches> getDuplicates(Id idLead) {
		List<possibleMatches> result = new List<possibleMatches>();

		try {
			DupeCatcherController controller = new DupeCatcherController(idLead);

			result = controller.getSortedMatches();

			if (500 < result.size()) {
				List<possibleMatches> newResult = new List<possibleMatches>();

				for (Integer index = 0; index < 500; ++index) {
					newResult.add(result.get(index));
				}

				result = newResult;
			}
		} catch (Exception e) {
			System.debug(LoggingLevel.ERROR, 'exception: ' + e.getMessage());
		}

		return result;
	}

	public DupeCatcherController(Id idLead) {
		recordId = idLead;
		DupeCatcherController_Init(recordId, false);
	}

	public DupeCatcherController() {
		try {
			recordId = ApexPages.currentPage().getParameters().get('Id');
			String archiveVal = ApexPages.currentPage().getParameters().get('Type');
			Boolean archive = (archiveVal == 'Archive');

			DupeCatcherController_Init(recordId, archive);
		} catch (Exception e) {
			System.debug(LoggingLevel.ERROR, 'exception: ' + e.getMessage());
		}
	}

	public DupeCatcherController(String sType) {
		ApexPages.currentPage().getParameters().put('Type', sType);
		recordId = ApexPages.currentPage().getParameters().get('Id');

		DupeCatcherController_Init(recordId, false);
	}

	public void DupeCatcherController_Init(Id recordId, Boolean archive) {
		try {
			if (!archive) {
				this.dupeLead = [
					SELECT
						Id,
						Name,
						Street,
						DBA_Name__c,
						lastName,
						Company,
						Phone,
						OwnerID,
						Status,
						Latitude,
						Longitude,
						CreatedDate,
						FEIN__c,
						RecordType.Name,
						Duplicate_Check_Status__c
					FROM Lead
					WHERE Id = :recordId
				];

				getDupes();
				this.showArchive = false;
			} else {
				Id dupeLogId;

				if (recordId.getSobjectType().getDescribe().getName() == 'Lead') {
					dupeLogId = [SELECT Id FROM Lead_Duplicate_Log__c WHERE Lead__c = :recordId][0].Id;
				} else {
					dupeLogId = [SELECT Id FROM Lead_Duplicate_Log__c WHERE Id = :recordId][0].Id;
				}

				dupeMatches = [
					SELECT
						Name,
						DBA_Name__c,
						Branch__r.Name,
						Company__c,
						Created_Date__c,
						FEIN__c,
						Match_Type__c,
						Owner__r.FirstName,
						Owner__r.LastName,
						Phone__c,
						Street__c,
						Record_Type__c,
						Record_ID__c,
						FEINMatch__c,
						CompanyMatch__c,
						NameMatch__c,
						DBAMatch__c
					FROM Match__c
					WHERE Lead_Duplicate_Log__c = :dupeLogId
				];

				this.dupeLead = [
					SELECT
						Id,
						Name,
						DBA_Name__c,
						lastName,
						Street,
						Company,
						Phone,
						OwnerId,
						Status,
						Latitude,
						Longitude,
						CreatedDate,
						FEIN__c,
						RecordType.Name,
						Duplicate_Check_Status__c
					FROM Lead
					WHERE Id = :[SELECT Lead__c FROM Lead_Duplicate_Log__c WHERE Id = :dupeLogId].Lead__c
				];

				DupeCatcher.buildArchive(this.allMatches, this.dupeMatches);
			}
		} catch (exception e) {
			System.debug(LoggingLevel.ERROR, 'exception: ' + e.getMessage());
		}
	}

	// Called from convertLead_Extension
	public void saveMatches(Lead dupeLead, map<Id, possibleMatches> allMatches) {
		LeadDuplicateLog log = new LeadDuplicateLog();
		log.createLeadLog(dupeLead, getSortedMatches());
	}

	private List<possibleMatches> getSortedMatches() {
		List<possibleMatches> result = allMatches.values();

		result.sort();

		return result;
	}

	private dupecatcherlightningWrapper getLightningReturn(boolean archive) {
		DupeCatcherLightningWrapper wrap = new DupeCatcherLightningWrapper();
		wrap.allMatches = getSortedMatches();
		if (wrap.allMatches.size() > 0) {
			wrap.foundmatches = true;
		}
		return wrap;
	}

	public void DupeCatcherController_InitLightning(Id recordId, boolean archive) {
		this.recordId = recordId;

		this.DupeCatcherController_Init(recordId, archive);
	}

	@AuraEnabled
	public static List<dupecatcherlightningWrapper> getDupesLightning(Id leadId, boolean archive) {
		List<DupeCatcherLightningWrapper> returnVal = new List<DupeCatcherLightningWrapper>();

		DupeCatcherController controller = new DupeCatcherController();

		controller.DupeCatcherController_InitLightning(leadId, archive);

		returnVal.add(controller.getLightningReturn(archive));

		return returnVal;
	}

	private void getDupes() {
		this.allMatches = (new DupeCatcher()).populateMatches(this.dupeLead);
	}
}