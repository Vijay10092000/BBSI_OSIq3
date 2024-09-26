/**
 * @description sendBUEmail_Schedulable
 */
@SuppressWarnings('PMD.AvoidGlobalModifier')
global without sharing class sendBUEmail_Schedulable implements Schedulable {
	/**
	 * @description execute performs the scheduled event.
	 * @param  context SchedulableContext with information about the Schedulable.
	 */
	global void execute(SchedulableContext context) {
		orgWide__c orgWide = OrgWide__c.getOrgDefaults();

    	Integer batchSize = Integer.valueOf(orgWide.BU_Email_Batch_Size__c);

    	SendBUEmailMessage email = new SendBUEmailMessage();
		database.executebatch(email, batchSize);
	}
}