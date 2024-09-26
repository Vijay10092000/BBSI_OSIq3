/**
 * @description BenefitsAffiliatesOpportunity contains methods to handle the object
 * Benefits Affiliates on Opportunity Records.
 */
public without sharing class BenefitsAffiliatesOpportunity {
	/**
	 * @description checkCommonOwnership handles a change to Is Common Ownership flag on Opportunity.
	 * on the Benefits object.  A change to the flag will either create a related Benefits Affiliates
	 * record or delete it.
	 * Affiliates record or delete it.
	 * @param  mapOld   Opportunities before changes
	 * @param  listNew  Opportunities after changes
	 */
	public static void checkCommonOwnership(Map<Id, Opportunity> mapOld, List<Opportunity> listNew) {
		if (!listNew.isEmpty()) {
			Set<Id> deleteAffiliates = new Set<Id>();

			Map<Id, Opportunity> makeAffiliates = new Map<Id, Opportunity>();

			for (Opportunity opp : listNew) {
				if (opp.Have_Common_Ownership__c == 'Yes') {
					if (mapOld == null || mapOld.get(opp.Id).Have_Common_Ownership__c != 'Yes') {
						if (opp.Benefits_Affiliates__c == null) {
							makeAffiliates.put(opp.AccountId, opp);
						}
					}
				} else {
					if (mapOld != null && mapOld.get(opp.Id).Have_Common_Ownership__c == 'Yes') {
						if (opp.Benefits_Affiliates__c != null) {
							deleteAffiliates.add(opp.Benefits_Affiliates__c);
						}
					}
				}
			}

			insert BenefitsAffiliates.make(makeAffiliates);

			BenefitsAffiliates.deleteAffiliates(deleteAffiliates);
		}
	}

/**
	 * @description checkCommonOwnershipForBenRen handles a change to Is Common Ownership flag on Ben Ren Opportunity.
	 * on the Benefits object.  A change to the flag will either create a related Benefits Affiliates
	 * record or delete it.
	 * Affiliates record or delete it.
	 * The difference from checkCommonOwnership is that in that here, we need to link the BenefitsAffiliate with an 
	 * existing Benefits record at the time of creation of Benefits Affiliates. This is not a requirement for Ben Opp 
	 * since Benefits record is not even created yet for Ben Opp.
	 * @param  mapOld   Opportunities before changes
	 * @param  listNew  Opportunities after changes
	 */
	public static void checkCommonOwnershipForBenRen(Map<Id, Opportunity> mapOld, List<Opportunity> listNew) {
		List<Opportunity> benefitsRenOpps = RecordTypeService.getByRecordType(listNew, Opportunity_Service.OPPORTUNITY, Opportunity_Service.RECORDTYPE_BENEFITS_RENEWAL);

		if (!benefitsRenOpps.isEmpty()) {
			Set<Id> deleteAffiliates = new Set<Id>();

			Map<Id, Benefits__c> makeAffiliates = new Map<Id, Benefits__c>();

			Set<Id> oppAccId = new Set<Id>();
			Map<Id, Id> accIdToOppIdMap = new Map<Id, Id>();
			for (Opportunity opp : benefitsRenOpps) {
				oppAccId.add(opp.AccountId);
				accIdToOppIdMap.put(opp.AccountId, opp.Id);
			}
			Map<Id, Benefits__c> accIdBenMap = Benefits_Service.selectBenefitsByAccounts(oppAccId);

			for (Opportunity opp : benefitsRenOpps) {
				if (opp.Have_Common_Ownership__c == 'Yes') {
					if (mapOld == null || mapOld.get(opp.Id).Have_Common_Ownership__c != 'Yes') {
						if (opp.Benefits_Affiliates__c == null) {
							makeAffiliates.put(opp.AccountId, accIdBenMap.get(opp.AccountId));
						}
					}
				} else {
					if (mapOld != null && mapOld.get(opp.Id).Have_Common_Ownership__c == 'Yes') {
						if (opp.Benefits_Affiliates__c != null) {
							deleteAffiliates.add(opp.Benefits_Affiliates__c);
						}
					}
				}
			}

			List<Benefits_Affiliates__c> baList = BenefitsAffiliates.make(makeAffiliates);
			for (Benefits_Affiliates__c ba : baList) {
				Id benRenOppId = accIdToOppIdMap.get(ba.Primary_Account__c);
				ba.Benefits_Opportunity__c = benRenOppId; // By default the Benefits_Opportunity__c points to the original Ben Opp, hence updating it here.
			}
			insert baList;

			BenefitsAffiliates.deleteAffiliates(deleteAffiliates);
		}
	}
	/**
	 * @description updateRelatedRecords determines if any Benefits fields have changed which
	 * need to be pushed to the related Benefits Affiliates or Accounts.
	 * @param  mapOld   Opportunities before changes
	 * @param  listNew  Opportunities after changes
	 */
	public static void updateRelatedRecords(Map<Id, Opportunity> mapOld, List<Opportunity> listNew) {
		Map<Id, Opportunity> changeAffiliates = new Map<Id, Opportunity>();

		for (Opportunity opp : listNew) {
			if (mapOld == null || !BenefitsAffiliatesUpdates.sameAs(mapOld.get(opp.Id), opp)) {
				if (opp.Benefits_Affiliates__c != null) {
					changeAffiliates.put(opp.Benefits_Affiliates__c, opp);
				}
			}
		}

		if (!changeAffiliates.isEmpty()) {
			Map<Id, Benefits_Affiliates__c> affiliates = BenefitsAffiliates.selectAffiliates(changeAffiliates.keySet());

			for (Benefits_Affiliates__c ba : affiliates.values()) {
				Opportunity opp = changeAffiliates.get(ba.Id);

				if (BenefitsAffiliatesUpdates.updateRelated(ba, opp)) {
					affiliates.put(ba.Id, ba);
				}
			}

			update affiliates.values();
		}
	}

	/**Updated For: USER STORY 51029
	 * @description selectOpportunities reads the Benefits fields of the given Opportunity identifiers.
	 * @param idOpps  Opportunity identifiers
	 * @return Map<Id, Opportunity>
	 */
	public static Map<Id, Opportunity> selectOpportunities(Set<Id> idOpps) {
		Map<Id, Opportunity> result = new Map<Id, Opportunity>(
			[
				SELECT
					Id,
					OwnerId,
					Name,
					AccountId,
					RecordTypeId, 
					RecordType.Name,
					Benefits_Affiliates__c,
					Benefits_Specialist__c,
					Benefits_Consultant__c,
					Benefits_Coordinator__c,
					Benefits_Type__c,
					Benefits_Affiliated_Companies__c,
					Active_Employees_All_Affiliates__c,
					Full_Time_Employees_All_Affiliates__c,
					Part_Time_Employees_All_Affiliates__c,					
					Validation_Rule_Skip_Toggle__c,
					Have_Common_Ownership__c,
					Is_there_a_benefits_referral_partner__c,
					L_H_Referral_Partner__c,
					L_H_Producer__c,
					Benefits_Effective_Date__c,
					IsClosed,
					StageName
				FROM Opportunity
				WHERE (RecordType.Name =: Opportunity_Service.RECORDTYPE_BENEFITS OR RecordType.Name =: Opportunity_Service.RECORDTYPE_BENEFITS_RENEWAL)
				AND Id IN :idOpps
			]
		);

		String textDebug = 'BenefitsAffiliatesOpportunity.selectOpportunities';
		for (Opportunity o : result.values()) {
			textDebug += '\nOpportunity: ' + o.Id + '  ' + o.Name;
			textDebug += '\n  IsClosed: ' + o.IsClosed;
			textDebug += '\n  Benefits_Specialist__c: ' + o.Benefits_Specialist__c;
			textDebug += '\n  Benefits_Consultant__c: ' + o.Benefits_Consultant__c;
			textDebug += '\n  Benefits_Coordinator__c: ' + o.Benefits_Coordinator__c;
			textDebug += '\n  Benefits_Affiliates__c: '   + o.Benefits_Affiliates__c;
		}
		System.debug(LoggingLevel.DEBUG, textDebug);

		return result;
	}
	/**Updated For: USER STORY 51029
	 * @description selectOpportuntiesByAffiliates reads the Opportunites records for the given ids.
	 * @param idAffiliates Affiliates getting Opportunites for.
	 * @return Map<Id, Opportunity>
	 */
	public static Map<Id, Opportunity> selectOpportuntiesByAffiliates(Set<Id> idAffiliates) {
		Map<Id, Opportunity> result = new Map<Id, Opportunity>(
			[
				SELECT
					Id,
					OwnerId,
					Name,
					AccountId,
					RecordTypeId, 
					RecordType.Name,
					Benefits_Affiliates__c,
					Benefits_Specialist__c,
					Benefits_Consultant__c,
					Benefits_Coordinator__c,
					Benefits_Type__c,
					Benefits_Affiliated_Companies__c,
					Active_Employees_All_Affiliates__c,
					Full_Time_Employees_All_Affiliates__c,
					Part_Time_Employees_All_Affiliates__c,	
					Validation_Rule_Skip_Toggle__c,
					Have_Common_Ownership__c,
					IsClosed,			
					Is_there_a_benefits_referral_partner__c,
					L_H_Referral_Partner__c,
					L_H_Producer__c,
					Benefits_Effective_Date__c,
					StageName					
				FROM Opportunity
				WHERE (RecordTypeId =: OpportunityBenefits_Service.BenefitsRT OR RecordTypeId =: OpportunityBenefits_Service.BenefitsRenewalRT)
				AND Benefits_Affiliates__c IN :idAffiliates
				ORDER BY Benefits_Affiliates__c ASC
			]
		);

		String textDebug = 'BenefitsAffiliatesOpportunity.selectOpportuntiesByAffiliates';
		for (Opportunity o : result.values()) {
			textDebug += '\nOpportunity: ' + o.Id + '  ' + o.Name;
			textDebug += '\n  IsClosed: ' + o.IsClosed;
			textDebug += '\n  Benefits_Specialist__c: ' + o.Benefits_Specialist__c;
			textDebug += '\n  Benefits_Consultant__c: ' + o.Benefits_Consultant__c;
			textDebug += '\n  Benefits_Coordinator__c: ' + o.Benefits_Coordinator__c;
			textDebug += '\n  Benefits_Affiliates__c: '   + o.Benefits_Affiliates__c;
		}
		System.debug(LoggingLevel.DEBUG, textDebug);

		return result;
	}

	/**
	 * @description selectOpportuntiesByAccounts reads the Opportunites records for the given ids.
	 * @param idAccounts Accounts getting Opportunites for.
	 * @return Map<Id, Opportunity>
	 */
	public static Map<Id, Opportunity> selectOpportuntiesByAccounts(Set<Id> idAccounts) {
		Map<Id, Opportunity> result = new Map<Id, Opportunity>(
			[
				SELECT
					Id,
					OwnerId,
					Name,
					AccountId,
					Benefits_Affiliates__c,
					Benefits_Specialist__c,
					Benefits_Consultant__c,
					Benefits_Coordinator__c,
					Benefits_Type__c,
					Benefits_Affiliated_Companies__c,
					Active_Employees_All_Affiliates__c,
					Full_Time_Employees_All_Affiliates__c,
					Part_Time_Employees_All_Affiliates__c,	
					Validation_Rule_Skip_Toggle__c,
					Have_Common_Ownership__c,
					IsClosed
				FROM Opportunity
				WHERE  RecordType.Name = 'Benefits'
				AND AccountId IN :idAccounts
			]
		);

		String textDebug = 'BenefitsAffiliatesOpportunity.selectOpportuntiesByAccounts';
		for (Opportunity o : result.values()) {
			textDebug += '\nOpportunity: ' + o.Id + '  OPP NAME:' + o.Name;
			textDebug += '\n  IsClosed: ' + o.IsClosed;
			textDebug += '\n  Benefits_Specialist__c: ' + o.Benefits_Specialist__c;
			textDebug += '\n  Benefits_Consultant__c: ' + o.Benefits_Consultant__c;
			textDebug += '\n  Benefits_Coordinator__c: ' + o.Benefits_Coordinator__c;
			textDebug += '\n  Benefits_Affiliates__c: '   + o.Benefits_Affiliates__c;
		}
		System.debug(LoggingLevel.DEBUG, textDebug);

		return result;
	}
}