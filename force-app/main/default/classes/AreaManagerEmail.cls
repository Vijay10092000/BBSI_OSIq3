/**
 * Updated For US-33150
 * @description AreaManagerEmail class
 */
public without sharing class AreaManagerEmail {
	/**
	 * @description areaManagerApprovalEmail description
	 * @param  idRecords     Identifier of the record being approved
	 * @param  userName     Name of user requesting approval
	 * @param  branchNames  Set of Branch names to retrieve Branch Admin User
	 * @param  approvalType Type of approval: Lead, Prospect, Cancellation
	 */
	public static void areaManagerApprovalEmail(
		Set<Id> idRecords,
		String userName,
		Set<String> branchNames,
		String approvalType
	) {
		Map<Id, String> recordName = new Map<Id, String>();
		map<String, String> areaManagerEmail = new Map<String, String>();
		Set<String> branchManager = new Set<String>();

		List<String> toAddresses = new List<String>();

		Set<String> areaManagerApprovalSetting = new Set<String>();
		Set<String> users = new Set<String>();
		String templateName = '';

		for (Opportunity o : [SELECT Name FROM Opportunity WHERE Id IN :idRecords]) {
			recordName.put(o.Id, o.Name);
		}

		for (Lead l : [SELECT Name FROM Lead WHERE Id IN :idRecords]) {
			recordName.put(l.Id, l.Name);
		}

		for (Account a : [SELECT Name FROM Account WHERE Id IN :idRecords]) {
			recordName.put(a.Id, a.Name);
		}

		for (Client_Cancellation__c c : [
			SELECT Client__r.Name, Client__r.Prospect_Branch__r.Branch_Manager__c
			FROM Client_Cancellation__c
			WHERE Id IN :idRecords
			LIMIT 1
		]) {
			recordName.put(c.Id, c.Client__r.Name);
			branchManager.add(c.Client__r.Prospect_Branch__r.Branch_Manager__c);
		}

		for (Admin_Branch__c a : [SELECT Admin_User__c FROM Admin_Branch__c WHERE Name IN :branchNames]) {
			areaManagerApprovalSetting.add(a.Admin_User__c);
		}

		for (Account a : [
			SELECT Prospect_Branch__r.Branch_Manager_Email__c
			FROM Account
			WHERE Id IN :idRecords
			LIMIT 1
		]) {
			toAddresses.add(a.Prospect_Branch__r.Branch_Manager_Email__c);
		}

		for (Lead l : [SELECT Branch__r.Branch_Manager_Email__c FROM Lead WHERE Id IN :idRecords LIMIT 1]) {
			toAddresses.add(l.Branch__r.Branch_Manager_Email__c);
		}

		for (String s : areaManagerApprovalSetting) {
			if (s.contains('\'')) {
				s = s.substring(0, s.indexOf('\'')) + '\'' + s.substring(s.indexOf('\''), s.length());
			}
		}

		for (User u : [SELECT Email FROM User WHERE Name IN :areaManagerApprovalSetting]) {
			toAddresses.add(u.email);
		}

		if (approvalType == 'Prospect') {
			templateName = 'Prospect_Area_Manager_Approval';
		} else if (approvalType == 'Lead') {
			templateName = 'Lead_Area_Manager_Approval';
		} else if (approvalType == 'Cancellation') {
			templateName = 'Cancellation_Area_Manager_Approval';
		}

		List<Messaging.SingleEmailMessage> emails = new List<Messaging.SingleEmailMessage>();
		for (Id recordId : idRecords) {
			emails.add(
				Email_Service.buildTemplateEmail(
					toAddresses,
					null,
					templateName,
					null,
					recordId
				)
			);
		}
		Email_Service.send(emails);	
	}
}