/**
 * @description OpportunityBenefits_Service handles Benefits Opportunities.
 */
public without sharing class OpportunityBenefits_Service {
    // Fetching Benefits RecordType Id
	public static final String BenefitsRT  = recordTypeService.getId(Opportunity_Service.OPPORTUNITY, Opportunity_Service.RECORDTYPE_BENEFITS);  
    // Fetching Benefits Renewal RecordType Id
	public static final String BenefitsRenewalRT  = recordTypeService.getId(Opportunity_Service.OPPORTUNITY, Opportunity_Service.RECORDTYPE_BENEFITS_RENEWAL);
	
	private static final String ERROR_CHANGE_PENDED_UNDERWRITING = 'Only Benefits Underwriting users may change the stage from Pending Underwriting.';
	private static final String ERROR_MISSING_BENEFITS_CONSULTANT = 'Missing Benefits Consultant.';
	private static final String ERROR_INVALID_BENEFITS_RENEWAL = 'Benefits Renewal Creats only on Clients with Benefits Affiliation Type as Primary.';
	private static final String PERMISSION_APPROVE_UNDERWRITING = 'Approve_Benefits_Underwriting';

	private static final String EMAIL_STAGE_CHANGE = 'Benefits_Opp_StageChange';
	private static final String EMAIL_PREENROLLMENT_OWNER  = 'Benefits_Opp_PreEnrollment_Owner';
	private static final String GROUP_BENEFITS_NOTIFICTAION = 'Benefits Insurance Notification';

	/**
	 * @description getBenefitsOpportunities gets the Benefits Opportunities from the given
	 * list of Opporutnities.
	 * @param  newOpps  List of Opportunities
	 * @return List<Opportunity>
	 */
	public static List<Opportunity> getBenefitsOpportunities(List<Opportunity> newOpps) {
		return RecordTypeService.getByRecordType(
			newOpps,
			Opportunity_Service.OPPORTUNITY,
			Opportunity_Service.RECORDTYPE_BENEFITS
		);
	}

	/**
	 * @description getBenefitsRenewalOpportunities gets the Benefits Opportunities from the given
	 * list of Opporutnities.
	 * @param  newOpps  List of Opportunities
	 * @return List<Opportunity>
	 */
	public static List<Opportunity> getBenefitsRenewalOpportunities(List<Opportunity> newOpps) {
		return RecordTypeService.getByRecordType(
			newOpps,
			Opportunity_Service.OPPORTUNITY,
			Opportunity_Service.RECORDTYPE_BENEFITS_RENEWAL
		);
	}
    
	/**
	 * @description beforeInsert handles before insert trigger event for Benefits Opportunities.
	 * @param  newOpps  Opportunities before insert
	 */
	public static void beforeInsert(List<Opportunity> newOpps) {
		List<Opportunity> oppBenefits = getBenefitsOpportunities(newOpps);
		List<Opportunity> oppBenefitsRenewal = getBenefitsRenewalOpportunities(newOpps);
		List<Opportunity> oppList = new List<Opportunity> ();    
		oppList.AddAll(oppBenefits);
		oppList.AddAll(oppBenefitsRenewal);        
		setInitialValues(oppList);
		if (!oppBenefits.isEmpty()) {
			checkStageUpdate(null, oppBenefits);
			TaskBenefits.createOtherTasks(null, oppBenefits);
			checkFieldUpdate(null, oppBenefits, Opportunity_Service.RECORDTYPE_BENEFITS); // US-65534
		}
	}

	/**
	 * @description afterInsert handles before insert trigger event for Benefits Opportunities.
	 * @param  newOpps  Opportunities after insert
	 */
	public static void afterInsert(List<Opportunity> newOpps) {
		List<Opportunity> oppBenefits = getBenefitsOpportunities(newOpps);
		List<Opportunity> oppBenefitsRenewal = getBenefitsRenewalOpportunities(newOpps);
        List<Opportunity> oppList = new List<Opportunity> (); 
				
		oppList.AddAll(oppBenefits);
		oppList.AddAll(oppBenefitsRenewal);   
		if (!oppList.isEmpty()) {
			updateAccounts(oppList);
			BenefitsAffiliatesOpportunity.checkCommonOwnership(null, oppList);	
			Benefits_Service.handleBenefitsOpportunityChanges(null, oppList);
			TaskBenefits.taskCreationOnFieldChange(null, oppList);	
			emailStageChanges(null, oppList);	
		}
	}

	/**
	 * @description beforeUpdate handles before update trigger event for Benefits Opportunities.
	 * @param  mapOldOpps  Opportunities before changes
	 * @param  newOpps     Opportunities with changes
	 */
	public static void beforeUpdate(Map<Id, Opportunity> mapOldOpps, List<Opportunity> newOpps) {
		List<Opportunity> oppBenefits = getBenefitsOpportunities(newOpps);

		if (!oppBenefits.isEmpty()) {
			blockOnClosed(mapOldOpps, newOpps);
			checkStageUpdate(mapOldOpps, newOpps);
			checkFieldUpdate(mapOldOpps, oppBenefits, Opportunity_Service.RECORDTYPE_BENEFITS); // US-65534
		}
	}

	/**
	 * @description afterUpdate handles after update trigger event for Benefits Opportunities.
	 * @param  mapOldOpps  Opportunities before changes
	 * @param  newOpps     Opportunities with changes
	 */
	public static void afterUpdate(Map<Id, Opportunity> mapOldOpps, List<Opportunity> newOpps) {
		List<Opportunity> oppBenefits = getBenefitsOpportunities(newOpps);
		List<Opportunity> oppBenefitsRenewal = getBenefitsRenewalOpportunities(newOpps);
        List<Opportunity> oppList = new List<Opportunity> ();    
		oppList.AddAll(oppBenefits);
		oppList.AddAll(oppBenefitsRenewal);

		if (!oppBenefits.isEmpty()){
            BenefitsAffiliatesOpportunity.checkCommonOwnership(null, oppBenefits);
        }
		if (!oppBenefitsRenewal.isEmpty()) {
			BenefitsAffiliatesOpportunity.checkCommonOwnershipForBenRen(mapOldOpps, oppBenefitsRenewal);
		}
		if (!oppList.isEmpty()) {
            // BenefitsAffiliatesOpportunity.checkCommonOwnership(null, oppList);
			Benefits_Service.handleBenefitsOpportunityChanges(mapOldOpps, oppList);
			TaskBenefits.taskCreationOnFieldChange(mapOldOpps, oppList);	
		}
		if (!oppBenefits.isEmpty()) {
			TaskBenefits.createOtherTasks(mapOldOpps, oppBenefits);
			// BenefitsAffiliatesOpportunity.updateRelatedRecords(mapOldOpps, newOpps);
		}
		if (!oppList.isEmpty()) {
			updateAccounts(oppList);
			BenefitsAffiliatesOpportunity.updateRelatedRecords(mapOldOpps, newOpps);
			emailStageChanges(null, oppList);
		}
	}

	/**
	 * @description setInitialValues sets initial values for Benefits Opportunities being created.
	 * Trigger stage: Before Insert
	 * @param  listOpps  List of Opportunities checking
	 */
	@TestVisible
	private static void setInitialValues(List<Opportunity> listOpps) {
		Set<Id> idAccounts = new Set<Id>();

		for (Opportunity opp : listOpps) {
			idAccounts.add(opp.AccountId);
		}
		Map<Id, Benefits__c> benefitsByAffiliates = Benefits_Service.selectBenefitsByAffiliates(idAccounts);
		//Updated SOQL For US-65531
		Map<Id, Account> mapClients = new Map<Id, Account>(
			[
				SELECT
					Id,
					Name,
					OwnerId,
					Benefits_Affiliates__c,
					Benefits_Affiliates__r.Benefits_Affiliated_Companies_Count__c, 
					Benefits_Affiliated_Companies__c,
					Client_Benefits_Renewal_Month__c,
					Name_Branch__c,
					Benefits_Representative__c,
					Benefits_Consultant__c,
					NumberOfEmployees,
					Active_Employees_Full_Time__c,
					Active_Employees_Part_Time__c,
					Producer__c, 
					Assigned_Referral_Partner__c, 
					BBSI_Benefits__c,
					RecordType.DeveloperName,
					Benefits_Affiliates_Type__c,
					BBSI_Benefits_Renewal_Date__c,
					Benefits_Type2__c,
					(SELECT Id, Active_Employees_All_Affiliates__c, 
							Full_Time_Employees_All_Affiliates__c, 
							Part_Time_Employees_All_Affiliates__c,
							Bucket__c,
							Admin_Factor__c,
							Is_there_common_ownership__c,
							Benefits_Coordinator__c,
							Benefits_Specialist__c,
							L_H_Referral_Partner__c,
							L_H_Producer__c,
							Is_there_a_benefits_referral_partner__c,
							Admin_Factor_KP__c,
							Bucket_KP__c 
						FROM BenefitsClient__r),
					(SELECT Id, Benefits_Consultant__c 
						FROM Opportunities 
						WHERE RecordType.Id = :BenefitsRT 
							AND StageName = :Opportunity_Service.STAGE_BENEFITS_CLOSED_WON)
				FROM Account
				WHERE Id IN :idAccounts
			]
		);

		for (Opportunity opp : listOpps) {
			Account client = mapClients.get(opp.AccountId);
			if (opp.RecordTypeId == BenefitsRenewalRT) {
                if(String.isEmpty(client.Benefits_Affiliates_Type__c) || client.Benefits_Affiliates_Type__c == 'Primary'){
                    String  renewalYear = (client.BBSI_Benefits_Renewal_Date__c != null) ? String.Valueof(client.BBSI_Benefits_Renewal_Date__c.year()) : '';

                    opp.OwnerId = client.Benefits_Representative__c != null ? client.Benefits_Representative__c : client.OwnerId;
                    opp.Name = 'Benefits Renewal ' + renewalYear + ': ' + client.Name;
                    opp.AccountId = client.Id;
                    opp.CloseDate = client.BBSI_Benefits_Renewal_Date__c;
                    opp.StageName = Opportunity_Service.firstStage(Opportunity_Service.RECORDTYPE_BENEFITS_RENEWAL); //Opportunity_Service.STAGE_BENEFITS_UW_RELEASED;
                    if (client.BBSI_Benefits_Renewal_Date__c != null) {
                        opp.Insurance_Medical_Renewal__c = client.BBSI_Benefits_Renewal_Date__c.addYears(1);
                    }
                    opp.PEO_Referral_Partner__c = client.Assigned_Referral_Partner__c; 
                    opp.PEO_Producer__c = client.Producer__c;
                    opp.Benefits_Affiliates__c = client.Benefits_Affiliates__c;
                    opp.Benefits_Affiliated_Companies__c = client.Benefits_Affiliated_Companies__c;
                    opp.Number_of_Affiliated_Companies__c = (client.Benefits_Affiliates__c != null 
                                                                && client.Benefits_Affiliates__r.Benefits_Affiliated_Companies_Count__c>0)
                                                                ? client.Benefits_Affiliates__r.Benefits_Affiliated_Companies_Count__c : 0;

					opp.Benefits_Type__c = client.Benefits_Type2__c; // User Story 51377

					if (client.BenefitsClient__r.size() > 0  &&  client.BenefitsClient__r[0] != null) {
						Benefits__c ben = client.BenefitsClient__r[0];

						opp.Validation_Rule_Skip_Toggle__c = !opp.Validation_Rule_Skip_Toggle__c;

						// Following 5 fields updated for User Story 51378
						opp.Active_Employees_Full_Time__c = Sobject_Services.getValue(ben.Full_Time_Employees_All_Affiliates__c, 0);
						opp.Active_Employees_Part_Time__c = Sobject_Services.getValue(ben.Part_Time_Employees_All_Affiliates__c, 0);
						opp.Active_Employees_All_Affiliates__c = Sobject_Services.getValue(ben.Active_Employees_All_Affiliates__c, 0);
						opp.Full_Time_Employees_All_Affiliates__c = Sobject_Services.getValue(ben.Full_Time_Employees_All_Affiliates__c, 0);
						opp.Part_Time_Employees_All_Affiliates__c = Sobject_Services.getValue(ben.Part_Time_Employees_All_Affiliates__c, 0);

						// Following 2 fields updated for User Story 50392 / Bug 51412
						opp.Current_Bucket__c = Sobject_Services.getValue(ben.Bucket__c, 0);
						opp.Current_Admin_Factor__c = Sobject_Services.getValue(ben.Admin_Factor__c, 0);

						opp.Have_Common_Ownership__c = ben.Is_there_common_ownership__c; // Bug 51440

						opp.Benefits_Coordinator__c = ben.Benefits_Coordinator__c; // 51409
						opp.Benefits_Specialist__c = ben.Benefits_Specialist__c; // 51409

						opp.L_H_Referral_Partner__c = ben.L_H_Referral_Partner__c; // Bug - 51410
						opp.L_H_Producer__c = ben.L_H_Producer__c; // Bug - 51410
						opp.Is_there_a_benefits_referral_partner__c = ben.Is_there_a_benefits_referral_partner__c; // Bug - 51410
						opp.Current_Admin_Factor_KP__c = ben.Admin_Factor_KP__c; // US-65531
				        opp.Current_Bucket_KP__c = ben.Bucket_KP__c; // US-65531
					}

					if (client.Opportunities.size() > 0  &&  client.Opportunities[0] != null) {
						Opportunity benOpp = client.Opportunities[0];

						opp.Benefits_Consultant__c = benOpp.Benefits_Consultant__c; // 51409
					}
                }
                else{
                    opp.addError(ERROR_INVALID_BENEFITS_RENEWAL);
                }				
            }
			else if(opp.RecordTypeId == BenefitsRT){
				opp.OwnerId = client.Benefits_Consultant__c != null ? client.Benefits_Consultant__c : UserInfo.getUserId();
				opp.Benefits_Consultant__c = client.Benefits_Representative__c;
				opp.Current_Medical_Renewal_Month__c = client.Client_Benefits_Renewal_Month__c;
				opp.Active_Employees_Full_Time__c = Sobject_Services.getValue(client.Active_Employees_Full_Time__c, 0);
				opp.Active_Employees_Part_Time__c = Sobject_Services.getValue(client.Active_Employees_Part_Time__c, 0);
				opp.Active_Employees_All_Affiliates__c = Sobject_Services.getValue(client.NumberOfEmployees, 0);
				opp.Full_Time_Employees_All_Affiliates__c = Sobject_Services.getValue(client.Active_Employees_Full_Time__c, 0);
				opp.Part_Time_Employees_All_Affiliates__c = Sobject_Services.getValue(client.Active_Employees_Part_Time__c, 0);
				opp.Validation_Rule_Skip_Toggle__c = !opp.Validation_Rule_Skip_Toggle__c;
				opp.CloseDate = Date.today().addDays(120); // US-66151

				if (opp.Amount == null) {
					opp.Amount = 0;
				}
			}
		}
	}

	/**
	 * @description blockOnClosed blocks some variables from being changed once
	 * the Opportunity is closed.
	 * Trigger stage: Before Update
	 * @param  mapOldOpps  Opportunities before changes
	 * @param  newOpps     Opportunities with changes
	 */
	@TestVisible
	private static void blockOnClosed(Map<Id, Opportunity> mapOldOpps, List<Opportunity> newOpps) {
		for (Opportunity newOpp : newOpps) {
			if (newOpp.IsClosed) {
				Opportunity oldOpp = mapOldOpps.get(newOpp.Id);

				if (oldOpp.Benefits_Affiliated_Companies__c != newOpp.Benefits_Affiliated_Companies__c) {
					newOpp.Benefits_Affiliated_Companies__c = oldOpp.Benefits_Affiliated_Companies__c;
				}
			}
		}
	}

	/**
	 * @description checkStageUpdate handles changes to Benefits Opportunity Stages.
	 * Trigger stage: Before Insert and Before Update
	 * @param  mapOldOpps  Opportunities before changes
	 * @param  newOpps     Opportunities with changes
	 */
	@TestVisible
	private static void checkStageUpdate(Map<Id, Opportunity> mapOldOpps, List<Opportunity> newOpps) {
		Boolean hasApproveUnderwriting = FeatureManagement.checkPermission(PERMISSION_APPROVE_UNDERWRITING);

		List<Opportunity> oppUpdateOwner = new List<Opportunity>();

		for (Opportunity opp : newOpps) {
			Opportunity oppOld = (mapOldOpps == null) ? null : mapOldOpps.get(opp.Id);

			/* DELETE: User Story 66133 - No automatic change of stage Pending Submission
			if (opp.StageName == Opportunity_Service.STAGE_PENDING_SUBMISSION) {
				if (opp.Have_Documents_Been_Submitted__c) {
					opp.StageName = Opportunity_Service.STAGE_UNDERWRITING;
				}
			}
			*/

			if (oppOld == null || oppOld.StageName != opp.StageName) {
				if (opp.StageName == Opportunity_Service.STAGE_UNDERWRITING) {
					oppUpdateOwner.add(opp);
				}

				if (oppOld != null) {
					if (oppOld.StageName == Opportunity_Service.STAGE_PENDED_UNDERWRITING) {
						if (!hasApproveUnderwriting) {
							opp.addError(ERROR_CHANGE_PENDED_UNDERWRITING);
						}
					}
				}
			}
		}

		if (!oppUpdateOwner.isEmpty()) {
			updateOwnerToConsultant(oppUpdateOwner);
		}
	}

	/**
	 * @description emailStageChanges determines if Stage change needs an email.
	 * @param  mapOldOpps  Opportunities before changes
	 * @param  newOpps     Opportunities with changes
	 */
	@TestVisible
	private static void emailStageChanges(Map<Id, Opportunity> mapOldOpps, List<Opportunity> newOpps) {
		List<Messaging.SingleEmailMessage> emails = new List<Messaging.SingleEmailMessage>();

		Map<Id, User> oppAccountOwners = Opportunity_Service.getAccountOwners(newOpps);

		for (Opportunity opp : newOpps) {
			if (mapOldOpps != null && mapOldOpps.get(opp.Id).StageName == opp.StageName) {
				continue;
			}

			if (opp.StageName == Opportunity_Service.STAGE_PRE_ENROLLMENT) {
				if (oppAccountOwners.containsKey(opp.Id)) {
					String email = oppAccountOwners.get(opp.Id).Email;

					if (email != null) {
						emails.add(					
							Email_Service.buildTemplateEmail(
								new List<String>{ email },
								null, 
								EMAIL_PREENROLLMENT_OWNER, 
								null,
								opp.Id
							)
						);
					}
				}
			}

			if (opp.StageName == Opportunity_Service.STAGE_PRE_ENROLLMENT || opp.StageName == Opportunity_Service.STAGE_VERVAL_SOLD) {
				emails.add(					
					Email_Service.buildTemplateEmail(
						Email_Service.getGroupEmailAddresses(GROUP_BENEFITS_NOTIFICTAION, true),
						null, 
						EMAIL_STAGE_CHANGE, 
						null,
						opp.Id
					)
				);
			}
		}

		Email_Service.send(emails);
	}

	/**
	 * @description updateOwnerToConsultant updates the opportunity owner to the Benefits Consultant.
	 * Trigger stage: Before Insert and Before Update
	 * @param  opps  Opportunities changing.
	 */
	@TestVisible
	private static void updateOwnerToConsultant(List<Opportunity> opps) {
		Set<Id> idAccounts = new Set<Id>();

		for (Opportunity opp : opps) {
			idAccounts.add(opp.AccountId);
		}

		Map<Id, Account> mapAccounts = new Map<Id, Account>(
			[SELECT Id, Name, Benefits_Representative__c FROM Account WHERE Id IN :idAccounts]
		);

		for (Opportunity opp : opps) {
			if (mapAccounts.containsKey(opp.AccountId)) {
				Id idCon = opp.Benefits_Consultant__c;

				if (idCon != null) {
					opp.OwnerId = idCon;
				} else {
					opp.addError(ERROR_MISSING_BENEFITS_CONSULTANT);
				}
			}
		}
	}

	/**
	 * @description updateAccounts updates the Accounts related to Opportunities.
	 */
	@TestVisible
	private static void updateAccounts(List<Opportunity> opps) {
		Map<Id, Id> accountBenefitsSpecialist = new Map<Id, Id>();

		// 63192: Update Benefits Specialist when Benefits Opportunity is Closed Won
		for (Opportunity opp : opps) {
			if (opp.StageName == 'Benefits Closed Won') {
				accountBenefitsSpecialist.put(opp.AccountId, opp.Benefits_Specialist__c);
			}
		}

		if (!accountBenefitsSpecialist.isEmpty()) {
			List<Account> accounts = [
				SELECT Id, Name, Benefits_Specialist__c 
				FROM Account
				WHERE Id IN :accountBenefitsSpecialist.keySet()
			];

			for (Account account : accounts) {
				if (accountBenefitsSpecialist.containsKey(account.Id)) {
					account.Benefits_Specialist__c  = accountBenefitsSpecialist.get(account.Id);
				}
			}

			update accounts;
		}
	}

	/** US-65534
	 * @description checkFieldUpdate handles Stage Automation on Benefits Opportunity Fields changed.
	 * Trigger stage: Before Insert and Before Update
	 * @param  mapOldOpps  Opportunities before changes
	 * @param  newOpps     Opportunities with changes
	 * @param  recordType  Opportunity Record Type Name
	 */
	@TestVisible
    private static void checkFieldUpdate(Map<Id, Opportunity> mapOldOpps, List<Opportunity> newOpps, String recordType) {
        for (Opportunity newOpp : newOpps) {
            List<Benefits_Task_Definition__mdt> taskDefinitions = new List<Benefits_Task_Definition__mdt>();
			for(Benefits_Task_Definition__mdt taskDef: TaskBenefits.getOnFieldChangeTaskDefs(newOpp.StageName)){
				if(String.isNotBlank(taskDef.Set_Opportunity_Stage__c) && TaskBenefits.shouldProcessTaskDef(taskDef, recordType)){
					taskDefinitions.add(taskDef);
				}
			}
			
            if (!taskDefinitions.isEmpty()) {
                Opportunity oldOpp = mapOldOpps != null ? mapOldOpps.get(newOpp.Id) : null;
                TaskBenefits.opportunityStageAutomation(taskDefinitions, oldOpp, newOpp, Opportunity_Service.getOpportunityFieldTypes('Opportunity'), recordType);
            }
        }
    }	
}