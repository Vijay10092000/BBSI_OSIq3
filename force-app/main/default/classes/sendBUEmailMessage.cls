/**
 * @description sendBUEmailMessage
 */
public class sendBUEmailMessage implements Database.Batchable<User>, Database.Stateful {
	private static final String FORMAT_ERROR = '\n    Code: {0}    Target: {1}    Message: {2}';

	@TestVisible
	private static List<Messaging.SingleEmailMessage> sentEmails = new List<Messaging.SingleEmailMessage>();

	@TestVisible
	private String errors;

	@TestVisible
	private Integer count = 0;

	/**
	 * @description start determines which Area Manager have Business Units.
	 * @param  context  Contains the Trigger Id
	 * @return A List of Users - Area Managers
	 */
	public List<User> start(Database.BatchableContext context) {
		return getAreaManagersWithBusinessUnits();
	}

	/**
	 * @description execute passes the list of requests on to Service.
	 * @param  context  Contains the Trigger Id
	 * @param  scope    List of Users - Area Managers
	 */
	public void execute(Database.BatchableContext context, List<User> scope) {
		List<Messaging.SingleEmailMessage> sendEmails = new List<Messaging.SingleEmailMessage>();

		EmailTemplate templateId = [SELECT Id FROM EmailTemplate WHERE Name = 'BU Membership'];

		for (User u : scope) {
			Messaging.SingleEmailMessage mail = new Messaging.SingleEmailMessage();
			mail.setTemplateId(templateId.Id);
			mail.setTargetObjectId(u.Id);
			mail.setSaveAsActivity(false);
			mail.setWhatId(u.Id);
			sendEmails.add(mail);
		}

		sentEmails.addAll(sendEmails);

		List<Messaging.SendEmailResult> emailResults = Messaging.sendEmail(sendEmails, false);
		addErrors(emailResults);
	}

	/**
	 * @description finish performs any clean up work
	 * @param  context  Contains the Trigger Id
	 */
	public void finish(Database.BatchableContext context) {
		if (!String.isBlank(errors)) {
			Log.error('SendBuEmailMessage Batch', 'BU Membership Email Failures ', errors);
		}
	}

	/**
	 * @description getAreaManagersWithBusinessUnits gets List of Area Manager names for all the branches.
	 * @return List of Users
	 */
	private List<User> getAreaManagersWithBusinessUnits() {
		Set<String> areaManagerNames = new Set<String>();

		for (Account branch : [
			SELECT Branch_Manager__c
			FROM Account
			WHERE RecordType.Name = 'BBSI BRANCH' AND Branch_No__c != '910'
		]) {
			if (branch.Branch_Manager__c != null) {
				areaManagerNames.add(branch.Branch_Manager__c);
			}
		}

		return [SELECT Id FROM User WHERE Name IN :AreaManagerNames];
	}

	/**
	 * @description addErrors adds to the errors String.
	 * @param emailResults  List of Messaging.SendEmailResult
	 */
	@TestVisible
	private void addErrors(List<Messaging.SendEmailResult> emailResults) {
		for (Messaging.SendEmailResult emailResult : emailResults) {
			if (!emailResult.isSuccess()) {
				++count;

				errors += '\n\nERROR ' + count;

				for (Messaging.SendEmailError emailError : emailResult.getErrors()) {
					errors += String.format(
						FORMAT_ERROR,
						new List<String>{
							emailError.getStatusCode().name(),
							emailError.getTargetObjectId(),
							emailError.getMessage()
						}
					);
				}
			}
		}
	}
}