/**
 * @description Lead_Services contains methods to handle Leads.
 */
public without sharing class Lead_Services {
	private static final String ERROR_MISSING_PHONE = 'At least one phone number must be given: Office, Mobile or Direct';
	private static final String ERROR_PHONE_FORMAT = 'Invalid number.  Format: ###-###-####';

	/**
	 * @description fixPhoneNumbers formats the Lead's phone numbers.
	 * @param  leads  List of Leads
	 */
	public static void fixPhoneNumbers(List<Lead> leads) {
		for (Lead lead : leads) {
			try {
				lead.Phone = PhoneNumber.fixPhoneNumber(lead.Phone, false, false);
			} catch (Exception e) {
				lead.Phone.addError(ERROR_PHONE_FORMAT);
			}
			try {
				lead.MobilePhone = PhoneNumber.fixPhoneNumber(lead.MobilePhone, false, false);
			} catch (Exception e) {
				lead.MobilePhone.addError(ERROR_PHONE_FORMAT);
			}
			try {
				lead.Direct__c = PhoneNumber.fixPhoneNumber(lead.Direct__c, false, false);
			} catch (Exception e) {
				lead.Direct__c.addError(ERROR_PHONE_FORMAT);
			}
			try {
				lead.Additional_Contact_Phone__c = PhoneNumber.fixPhoneNumber(lead.Additional_Contact_Phone__c, false, false);
			} catch (Exception e) {
				lead.Additional_Contact_Phone__c.addError(ERROR_PHONE_FORMAT);
			}
			try {
				lead.Additional_Contact_Mobile__c = PhoneNumber.fixPhoneNumber(lead.Additional_Contact_Mobile__c, false, false);
			} catch (Exception e) {
				lead.Additional_Contact_Mobile__c.addError(ERROR_PHONE_FORMAT);
			}
		}
	}

	/**
	 * @description hasOnePhoneNumber determines if each of the given Leads have
	 * at least one valid phone number.  Leads missing a phone number are marked
	 * with and error.
	 * Phone numbers became required on 2023-01-13, so Leads before that date may
	 * have no phone numbers.
	 * User Story 46365: skip Validating these fields when Validation_Rule_Skip_Toggle__c is checked.
	 * @param  oldLeads  Leads without changes
	 * @param  newLeads  Leads with changes
	 */
	public static void hasOnePhoneNumber(Map<Id, Lead> oldLeads, List<Lead> newLeads) {
		DateTime beforeRequired = DateTime.newInstance(2023, 1, 13, 0, 0, 1);

		for (Lead lead : newLeads) {
			if (!lead.Validation_Rule_Skip_Toggle__c && 
				lead.CreatedDate > beforeRequired &&
				!PhoneNumber.isValid(lead.Phone, false) &&
				!PhoneNumber.isValid(lead.MobilePhone, false) &&
				!PhoneNumber.isValid(lead.Direct__c, false)) {
					lead.addError(ERROR_MISSING_PHONE);
			}
		}
	}

	/**
	 * @description updateLeadFields updates the Status field on a Lead if CallDisposition
	 * on a Task is set to a value above.
	 * @param  mapOldTasks Tasks before changes
	 * @param  newTasks    Tasks with changes being made
	 */
	public static void updateLeadFields(Map<Id, Task> mapOldTasks, List<Task> newTasks) {
		List<Lead> updateLeads = new List<Lead>();
		Map<Id, Id> idLeadTasks = new Map<Id, Id>();

		for (Task task : newTasks) {
			if (task.Status != 'Completed' || String.isBlank(task.CallDisposition)) {
				continue;
			}

			if (mapOldTasks == null || mapOldTasks.get(task.Id).CallDisposition != task.CallDisposition) {
				if ('Lead' == Sobject_Services.getType(task.WhoId)) {
					String status = '';
					String reason = '';

					switch on task.CallDisposition.toLowerCase() {
						when 'appointment set' {
							status = 'Qualified';
							reason = '';

							// Need Appointment Tasks
							idLeadTasks.put(task.WhoId, Task.OwnerId);
						}
						when 'do not call' {
							status = 'Unqualified';
							reason = 'Do not call';
						}
						when 'not interested' {
							status = 'Unqualified';
							reason = 'Not Interested';
						}
						when 'not qualified' {
							status = 'Unqualified';
							reason = 'Not Qualified';
						}
					}

					if (String.isNotBlank(status)) {
						updateLeads.add(new Lead(Id = task.WhoId, Status = status, Unqualified_Reason__c = reason));
					}
				}
			}
		}

		update updateLeads;

		insertAppointmentTasks(idLeadTasks);
	}

	/**
	 * @description setBranches sets the Lead branch based on the Owner's branch.

	* @param  newList New Leads
	*/
	public static void setBranches(List<Lead> newList) {
		Lead_Services.setBranches(newList, null);
	}

	/**
	 * @description setBranches sets the Lead branch based on the Owner's branch.
	 * @param  newList Leads with proposed changes
	 * @param  oldMap  Leads before the changes
	 */
	public static void setBranches(List<Lead> newList, Map<Id, Lead> oldMap) {
		Set<Id> ownerIds = new Set<Id>();
		for (Lead leadRec : newList) {
			ownerIDs.add(leadRec.OwnerId);
		}

		Map<Id, User> users = User_Services.getUserRecordsMap(ownerIds);
		Map<String, Account> branches = AccountBranch.getBranchesByNumber();

		for (Lead leadRec : newList) {
			if (oldMap != null) {
				if (leadRec.OwnerId != oldMap.get(leadRec.Id).OwnerId) {
					getBranch(leadRec, users, branches);
				}
			} else {
				getBranch(leadRec, users, branches);
			}
		}
	}

	/**
	 * @description validateNewBranch confirms the Lead Owner's branch is the same as the Lead branch.
	 * @param  lRec     The Lead record
	 * @param  users    Map of Users
	 * @param  branches Map of Branches
	 */
	@TestVisible
	private static void validateNewBranch(Lead lRec, Map<Id, User> users, Map<String, Account> branches) {
		String userBranch = users.get(lRec.OwnerID).Branch_Id__c;

		if (lRec.Branch__c != branches.get(userBranch).Id) {
			lRec.addError(
				'The Branch must match the record owner\'s branch.  Record owner\'s branch is ' +
				branches.get(userBranch).Name
			);
		}
	}

	/**
	 * @description getBranch validates the Lead owner belongs to a valid branch.
	 * @param  lRec     The Lead record
	 * @param  users    Map of Users
	 * @param  branches Map of Branches
	 */
	private static void getBranch(Lead lRec, Map<Id, User> users, Map<String, Account> branches) {
		String userBranch = users.get(lRec.OwnerID).Branch_ID__c;

		if (userBranch != null && branches.containsKey(UserBranch)) {
			lRec.Branch__c = branches.get(userBranch).Id;
		} else {
			if (!Test.isRunningTest()) {
				lRec.addError(
					'Owner does not have Branch Assigned or Owner Branch is invalid. Owner must have a valid Branch.'
				);
			}
		}
	}

	/**
	 * @description updateReferralSourceForLead updates Referral Source on the given Leads.
	 * @param  mapOld  Leads before changes
	 * @param  listNew Leads with proposed chagnes
	 */
	public static void updateReferralSourceForLead(Map<Id, Lead> mapOld, List<Lead> listNew) {
		List<Referral_Partner__c> referralSources = ReferralSource_Service.updateLeadReferralSources(mapOld, listNew);

		if (!referralSources.isEmpty()) {
			upsert referralSources;
		}
	}

	/**
	 * @description setUnverify resets Duplicate_Check_Status__c if a field
	 * has changed on the Lead.
	 * @param  mapNew  Leads with proposed changes
	 * @param  mapOld  Leads before changes
	 */
	public static void setUnverify(Map<Id, Lead> mapNew, Map<Id, Lead> mapOld) {
		List<Schema.FieldSetMember> fields = sObjectType.Lead.FieldSets.unverifydupes.getFields();

		for (Lead l : mapNew.values()) {
			if (l.Duplicate_Check_Status__c) {
				for (Schema.FieldSetMember f : fields) {
					String fieldPath = f.getFieldPath();

					if (!String.isBlank(fieldPath)) {
						List<String> path = fieldPath.split('\\.');

						if (path.size() > 1) {
						}

						Lead oldLead = mapOld.get(l.Id);

						if (l.get(path[0]) != oldLead.get(path[0])) {
							l.Duplicate_Check_Status__c = false;
							break;
						}
					}
				}
			}
		}
	}

	/**
	 * @description assignLeadFEINs assigns FEINs to the Leads.
	 * @param  newValues  Leads with proposed changes
	 * @param  oldValues  Leads before changes
	 */
	public static void assignLeadFEINs(List<Lead> newValues, List<Lead> oldValues) {
		FEIN_Services.assignLeadFEINs(newValues, oldValues);
	}

	/**
	 * @description assignLeadFEINs updates FEINs for the Leads.
	 * @param  newValues  Leads with proposed changes
	 * @param  oldValues  Leads before changes
	 */
	public static void updateLeadFEINs(List<Lead> newValues, List<Lead> oldValues) {
		FEIN_Services.updateLeadFEINs(newValues, oldValues);
	}

	/**
	 * @description onLeadConversionUpdateAccountType when a Lead is converted keep the
	 * account record type consistent with the lead.
	 * @param  oldLeads Leads before the change
	 * @param  newLeads Leads with change
	 */
	public static void onLeadConversionUpdateAccountType(Map<Id, Lead> oldLeads, Map<Id, Lead> newLeads) {
		List<Lead> convertedLeads = getCovertedLeads(oldLeads, newLeads.values());

		if (!convertedLeads.isEmpty()) {
			Id rtLeadClient = RecordTypeService.getId('Lead', 'Client Lead');
			Id rtLeadRP = RecordTypeService.getId('Lead', 'Referral Partner Lead');
			Id rtAccountProspect = RecordTypeService.getId('Account', 'Prospect');
			Id rtaccountRP = RecordTypeService.getId('Account', 'Referral Partner');

			Map<Id, Id> mapAccountToType = new Map<Id, Id>();

			// Get Accounts of newly converted Leads and relate the Record Type they SHOULD be
			for (Lead l : convertedLeads) {
				if (l.RecordTypeId == rtLeadClient) {
					mapAccountToType.put(l.ConvertedAccountId, rtAccountProspect);
				} else if (l.RecordTypeId == rtLeadRP) {
					mapAccountToType.put(l.ConvertedAccountId, rtAccountRP);
				}
			}

			// Update Accounts with wrong Record Types
			if (!mapAccountToType.isEmpty()) {
				List<Account> accounts = [SELECT Id, RecordTypeId FROM Account WHERE Id IN :mapAccountToType.keySet()];
				List<Account> updateAccounts = new List<Account>();

				for (Account a : accounts) {
					Id idRecordTypeShouldBe = mapAccountToType.get(a.Id);

					if (a.RecordTypeId != idRecordTypeShouldBe) {
						a.RecordTypeId = idRecordTypeShouldBe;
					}
				}

				if (!updateAccounts.isEmpty()) {
					update updateAccounts;
				}
			}
		}
	}

	/**
	 * @description getCovertedLeads retrives a List of leads currently being converted.
	 * @param  oldLeads Leads before the change
	 * @param  newLeads Leads with change
	 * @return List of converted leads
	 */
	@TestVisible
	private static List<Lead> getCovertedLeads(Map<Id, Lead> oldLeads, List<Lead> newLeads) {
		List<Lead> converted = new List<Lead>();

		if (!oldLeads.isEmpty()) {
			for (Lead lead : newLeads) {
				if (lead.IsConverted) {
					if (!oldLeads.get(lead.Id).IsConverted) {
						converted.add(lead);
					}
				}
			}
		}

		return converted;
	}

	// On Lead conversion, AFTER UPDATE, if there is an Additional Contact information,
	// create the additional Contact record.
	/**
	 * @description addAdditionalContacts description
	 * @param  oldLeads  Leads before changes
	 * @param  newLeads  Leads with changes being made
	 */
	public static void addAdditionalContacts(Map<Id, Lead> oldLeads, List<Lead> newLeads) {
		List<Lead> convertedLeads = getCovertedLeads(oldLeads, newLeads);

		if (!convertedLeads.isEmpty()) {
			List<Contact> contacts = new List<Contact>();

			for (Lead lead : convertedLeads) {
				if (lead.Additional_Contact__c == null) {
					continue;
				}

				Integer space = lead.Additional_Contact__c.indexOf(' ');
				String firstName;
				String lastName;

				if (space != -1) {
					firstName = lead.Additional_Contact__c.substring(0, space);
					lastName = lead.Additional_Contact__c.substring(space + 1);
				} else {
					firstName = '';
					lastName = lead.Additional_Contact__c;
				}

				string title = 'n/a';

				if (lead.Additional_Contact_Title__c != null) {
					title = lead.Additional_Contact_Title__c;
				}

				contacts.add(
					new Contact(
						FirstName = firstName,
						LastName = lastName,
						Title = lead.Additional_Contact_Title__c,
						Other__c = true,
						Function__c = title,
						Direct__c = lead.Additional_Contact_Phone__c,
						MobilePhone = lead.Additional_Contact_Mobile__c,
						Email = lead.Additional_Contact_Email__c,
						Converted_From_Lead_ID__c = lead.Id,
						AccountId = lead.ConvertedAccountId
					)
				);
			}

			if (!contacts.isEmpty()) {
				insert contacts;
			}
		}
	}

	/**
	 * @description taskOnQualified creates a task on a lead when a Televerde Lead is qualified.
	 * @param  oldLeads Map of Leads previous values
	 * @param  newLeads Map of Leads new values
	 * @see https://developer.salesforce.com/docs/atlas.en-us.api.meta/api/sforce_api_objects_task.htm
	 */
	public static void taskOnQualified(Map<Id, Lead> oldLeads, Map<Id, Lead> newLeads) {
		List<Lead> leadsNeedingTasks = new List<Lead>();

		for (Lead lead : newLeads.values()) {
			if (lead.Televerde_Status__c == 'Qualified') {
				if (oldLeads == null || lead.Televerde_Status__c != oldLeads.get(lead.Id).Televerde_Status__c) {
					leadsNeedingTasks.add(lead);
				}
			}
		}

		if (!leadsNeedingTasks.isEmpty()) {
			List<Task> tasks = new List<Task>();

			for (Lead lead : leadsNeedingTasks) {
				tasks.add(
					new Task(
						OwnerId = lead.OwnerId,
						Description = String_Services.truncateWithDots(lead.Call_Notes__c, 32000),
						ActivityDate = lead.Appointment_Date__c,
						WhoId = lead.Id,
						Priority = 'Normal',
						Status = 'Not Started',
						Subject = 'Appointment Scheduled by Televerde'
					)
				);
			}

			if (!tasks.isEmpty()) {
				Database.DMLOptions notifyOption = new Database.DMLOptions();
				notifyOption.EmailHeader.triggerUserEmail = true;

				Database.insert(tasks, notifyOption);
			}
		}
	}

	/**
	 * @description setFields set Lead fields based on Branch.
	 * @param  oldLeads  Leads before the change
	 * @param  newLeads  Leads with change
	 */
	public static void setFields(Map<Id, Lead> oldLeads, List<Lead> newLeads) {
		List<Lead> changedLeads = new List<Lead>();

		for (Lead lead : newLeads) {
			if (oldLeads == null) {
				if  (lead.Branch__c != null) {
					changedLeads.add(lead);
				}
			} else if (oldLeads.get(lead.Id).Branch__c != lead.Branch__c) {
				if (lead.Branch__c == null) {
					lead.Name_Branch__c = null;
				} else {
					changedLeads.add(lead);
				}
			}
		}

		if (!changedLeads.isEmpty()) {
			Map<Id, Account> mapBranches = AccountBranch.getBranches();

			for (Lead lead : changedLeads) {
				if (mapBranches.containsKey(lead.Branch__c)) {
					lead.Name_Branch__c = mapBranches.get(lead.Branch__c).Name;
				}
			}
		}
	}

	/**
	 * @description insertAppointmentTasks creates an Appointment Task on the given Lead.
	 * @param  mapLeadIdToOwnerId  Lead Id to Owner Id
	 */
	@TestVisible
	private static void insertAppointmentTasks(Map<Id, Id> mapLeadIdToOwnerId) {
		/** POSTPONED until the 2023 Q1 RELEASE - Azure User Story 41538
		List<Id> leadIds = new List<Id>( mapLeadIdToOwnerId.keySet() );

		Map<Id, Lead> mapLeads = new Map<Id, Lead>([SELECT Id, Name, Company FROM Lead WHERE Id IN :leadIds]);

		List<Task> insertTasks = new List<Task>();

		for (id idLead : leadIds) {
			Lead lead = mapLeads.get(idLead);

			Task task = new Task(
				RecordTypeId = RecordTypeService.getId('Task', 'Task'),
				Type = 'Call Center Appointment',
				OwnerId = mapLeadIdToOwnerId.get(idLead),
				WhoId = lead.Id,
				Subject = 'Appointment Scheduled with ' + lead.Name + ', ' + lead.Company,
				ActivityDate = Date.today().addDays(7),
				Priority = 'Normal',
				Status = 'Not Started'
			);
		}

		insert insertTasks;
		*/
	}

	/**
	 * @description setStatus changes the Lead Status and Lead Stage of the Lead.  If the Lead has a Status of "Raw" and
	 * the owner is not an integration user, the change it to "Assigned".
	 */
	public static void setStatus(Map<Id, Lead> oldLeads, List<Lead> newLeads) {
		Set<Id> idIntegraionUsers = PermissionSet_Service.getUsersWithCustomPermission('Lead_Start_Lead_Status_Raw');   
		
		Id idUser = UserInfo.getUserId();

		for (Lead lead : newLeads) {
			String oldStatus = lead.Status;
		
			if (oldLeads == null) {
				System.debug(LoggingLevel.INFO, 'Lead_Service.setStatus(): NEW LEAD');
				if (lead.Status == 'Raw' || lead.Status == 'Assigned') {
					System.debug(LoggingLevel.INFO, 'Lead_Service.setStatus(): Status is "Raw" OR "Assigned"');
				
					if (idIntegraionUsers.contains(idUser)) {
						System.debug(LoggingLevel.INFO, 'Lead_Service.setStatus(): Set Raw');
						lead.Status = 'Raw';
					} else {
						System.debug(LoggingLevel.INFO, 'Lead_Service.setStatus(): Set Assigned');
						lead.Status = 'Assigned';
					}
				} 
			}

			switch on lead.Status {
				when 'Unqualified' {
					if (oldLeads == null || oldLeads.get(lead.Id).Status != 'Unqualified') {
						lead.Lead_Stage__c = 'Dead';
					}
				}
				when 'Converted' {
					if (lead.IsConverted) {
						lead.Lead_Stage__c = 'Converted';
					}
				}
			}
			
			System.debug(
				LoggingLevel.INFO, 
				'Lead_Service.setStatus()' +
				'\n  Lead CreatedBy: ' + lead.CreatedById +
				'\n  Lead Owner: ' + lead.OwnerId +
				'\n  Lead Status: ' + oldStatus + ' => ' + lead.Status +
				'\n~~~~~~~~~~~~~~~~~~~~~'
			);
		}
	}
}