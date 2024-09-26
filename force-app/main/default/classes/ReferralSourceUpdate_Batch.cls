/**
 * @description ReferralSourceUpdate_Batch works through the active Change Requests
 * and updates the related Referral Source (Referral_Partner__c) objects.
 */

 @SuppressWarnings('PMD.AvoidGlobalModifier')
 global without sharing class ReferralSourceUpdate_Batch implements Database.Batchable<sObject> {
	 /**
	  * @description start determines which change requests should be reviewed.  The
	  * reviewed are those which should be terminated.
	  * @param  bc Contains the Trigger Id
	  * @return A QueryLocator of the change requests to review
	  */
	 global Database.QueryLocator start(Database.BatchableContext bc) {
		 String today = System.now().format('yyyy-MM-dd');

		 String query =
			 'SELECT Id FROM Referral_Partner_Change_Request__c ' +
			 'WHERE Effective_Date__c <= ' + today + ' AND Status__c = \'Approved\' ' +
			 'ORDER BY Effective_Date__c ASC ';

		 return Database.getQueryLocator(query);
	 }

	 /**
	  * @description execute passes the list of requests on to Service.
	  * @param  bc Contains the Trigger Id
	  * @param  requests List of Referral_Partner_Change_Request__cs to work on
	  */
	 global void execute(Database.BatchableContext bc, List<Referral_Partner_Change_Request__c> requests) {
		 List<Id> idRequests = new List<Id>();

		 for (Referral_Partner_Change_Request__c rpcr : requests) {
			 idRequests.add(rpcr.Id);
		 }

		 try {
			 ReferralPartnerChange_Service.updateReferralSources(idRequests);
		 }
		 catch (Exception e) {
			 sendExceptionEmail(e);
		 }
	 }

	 /**
	  * @description finish performs any clean up work
	  * @param  bc Contains the Trigger Id
	  */
	 @SuppressWarnings('PMD.EmptyStatementBlock')
	 global void finish(Database.BatchableContext bc) {
	 }

	 /**
	  * @description sendExceptionEmail sends an email to the Referral Partner Admins
	  * when an exception has occurred.
	  * @param  e The exception
	  */
	 public void sendExceptionEmail(Exception e) {
		 String subject = 'Salesforce Error: Referral Source Update Schedule Job Failed';

		 String nameSandbox = Organization_Service.getSandboxName();
		 if (!String.isBlank(nameSandbox)) {
			 subject = nameSandbox + ': ' + subject;
		 }

		 Email_Service.sendPlainEmail(
			 Email_Service.getGroupEmailAddresses('Adminstrator', true),
			 Email_Service.getEmailAddressesWithPermissionSet(new List<String>{ 'Referral Partner Admin' }),
			 subject,
			 buildExceptionEmail(nameSandbox, e)
		 );
	 }

	 /**
	  * @description buildExceptionEmail builds the email body.
	  * @param  nameSandbox  Name of the Sandbox if not Production
	  * @param  e            The exception
	  * @return The body of an email with data about the issue.
	  */
	 @TestVisible
	 private String buildExceptionEmail(String nameSandbox, Exception e) {
		 String body = '';

		 if (String.isBlank(nameSandbox)) {
			 body = 'PRODUCTION ERROR';
		 }
		 else {
			 body = 'SANDBOX ERROR: ' + nameSandbox;
		 }

		 body += '\n\nReferral Source Update nightly process has failed.  A possible cause is multiple change';
		 body += ' requests on single client or referral partner.  The error may only be in some of the listed';
		 body += ' requests.  Processing is such that if any fail, they all fail.';
		 body += '\n\nReview the current list of "Approved" change requests in Salesforce for possible errors.';
		 body += '\n\nCreate a case if the issue is not found by reviewing the change requests.';
		 body += '\n\n' + e.getMessage();

		 return body;
	 }
 }