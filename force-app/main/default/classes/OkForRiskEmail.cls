/** Updated For US-33150
 * @description OkForRiskEmail - OK for Risk was changed to Underwriting
 */
public class OkForRiskEmail {

	/**
	 * @description riskEmail description
	 * @param  idRecord   Opporutnity Identifiers
	 */
	public static void riskEmail(Set<Id> idRecords) {
		List<Opportunity> listOpportunities = [SELECT Id, Name FROM Opportunity WHERE Id IN :idRecords];

		riskEmail(listOpportunities);
	}

	/**
	 * @description riskEmail description
	 * @param  opps       List of Opporutnities
	 */
	public static void riskEmail(List<Opportunity> opps) {
		Set<String> riskApproval = new Set<String>();
		for (Ok_For_Risk_Access__c approver : Ok_For_Risk_Access__c.getall().values()) {
			riskApproval.add(approver.Name);
		}

		List<String> toAddresses = new List<String>();
		for (User user : [SELECT Email FROM User WHERE Name IN :riskApproval]) {
			toAddresses.add(user.Email);
		}

		List<Messaging.SingleEmailMessage> emails = new List<Messaging.SingleEmailMessage>();		
		for (Opportunity opp : opps) {
			emails.add(
				Email_Service.buildTemplateEmail(
					toAddresses,
					null,
					'Underwriting_Approval_in_Salesforce',
					null,
					opp.Id
				)
			);
		}
		Email_Service.send(emails);
	}
}