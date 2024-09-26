/**
 * @description NewHireApproval handles hire approvals for the Position__c object.
 */
public without sharing class NewHireApproval {
	private static final String TEMPLATE_NAME_NOTIFICATION = 'Notification_Recruiter_HTML';

	private static final String CORPORATE_BRANCH_ID = '910';
	private static final String BRANCH = 'Branch';
	private static final String CORPORATE = 'Corporate';

	/**
	 * @description populateApprover assigns the proper user for authorization to hire.
	 * @param  newPositions  Positions__c to fix
	 */
	public static void populateApprover(List<Position__c> newPositions) {
		Map<String, Id> approvers = getApprovers();
		Map<Id, Account> branches = AccountBranch.getBranches();

		for (Position__c p : newPositions) {
			String approver = BRANCH;

			if (branches.containsKey(p.Branch__c)) {
				if (branches.get(p.Branch__c).External_Id__c == CORPORATE_BRANCH_ID) {
					approver = CORPORATE;
				}
			}

			p.Authorization_to_Hire_User__c = approvers.get(approver);
		}
	}

	/**
	 * getApprovers reads the custom setting of Approvers.
	 * @returns Map<String, Id> relating Branch or Corporate to approver's User Id.
	 */
	private static Map<String, Id> getApprovers() {
		Map<String, Id> result = new Map<String, Id>();
		Map<String, String> userLookup = new Map<String, String>();

		for (New_Hire__c n : New_Hire__c.getall().values()) {
			userLookup.put(n.User__c, n.Name);
		}

		for (User u : [SELECT Id, Name FROM User WHERE Name IN :userLookup.keySet()]) {
			result.put(userLookup.get(u.Name), u.Id);
		}

		return result;
	}

	/**
	 * @description emailRecruiter sends the recuiter an email notificaiton if has been set.
	 */
	public static void emailRecruiter(Map<Id, Position__c> oldMap, Map<Id, Position__c> newMap) {
		List<Position__c> toEmail = new List<Position__c>();
		Set<String> recruiters = new Set<String>();

		for (Position__c p : newMap.values()) {
			if (
				!String.isEmpty(p.Recruiter__c) &&
				p.Recruiter__c != 'External' &&
				p.Recruiter__c != 'Internal Recruiter' &&
				p.Recruiter__c != 'External Recruiter'
			) {
				toEmail.add(p);
				recruiters.add(p.Recruiter__c);
			}
		}

		if (!toEmail.isEmpty() && !recruiters.isEmpty()) {
			sendRecruiterEmail(toEmail, recruiters);
		}
	}

	/**
	 * @description sendRecruiterEmail sends emails to the recruiters.
	 */
	private static void sendRecruiterEmail(List<Position__c> positions, Set<String> nameRecruiters) {
		Log log = new Log(Log.Severity.ERROR, 'New Hire', 'NewHireApproval.sendRecruiterEmail() Failed');

		Map<String, Contact> recruiters = getRecruiterEmail(nameRecruiters);

		List<Messaging.SingleEmailMessage> emails = new List<Messaging.SingleEmailMessage>();

		for (Position__c position : positions) {
			if (recruiters.containsKey(position.Recruiter__c)) {
				Contact recruiter = recruiters.get(position.Recruiter__c);

				if (!String.isBlank(recruiter.Email)) {
					emails.add(
						Email_Service.buildTemplateEmail(
							new List<String>{ recruiters.get(position.Recruiter__c).Email },
							null,
							TEMPLATE_NAME_NOTIFICATION,
							recruiters.get(position.Recruiter__c).Id,
							position.Id
						)
					);
				} else {
					log.addLine(
						'Position: ' + position.Id + ': Recruiter (' + position.Recruiter__c + ') is missing its email.'
					);
				}
			} else {
				log.addLine('Position: ' + position.Id + ': Has invalid Recruiter (' + position.Recruiter__c + '.');
			}
		}

		if (!String.isBlank(log.description)) {
			log.write();
		}

		Email_Service.send(emails);
	}

	/**
	 * getRecruiterEmail finds the Contact related to the given recruiter names.
	 * @param  names  Set of names for the recruiters
	 * @return Map<String, Contact> relates to recruiter Name to their Contact
	 */
	private static Map<String, Contact> getRecruiterEmail(Set<String> names) {
		Map<String, Contact> result = new Map<String, Contact>();

		for (Contact contact : [
			SELECT Id, Name, Email 
			FROM Contact 
			WHERE Name IN :names
			AND RecordType.Name = 'BBSI Employee'
		]) {
			result.put(contact.Name, contact);
		}

		return result;
	}
}