/**
 * ReferralSourceUpdate_Schedulable used to update the Referral Source
 * records from the change requests on a timely basis.
 */
@SuppressWarnings('PMD.AvoidGlobalModifier')
global without sharing class ReferralSourceUpdate_Schedulable implements Schedulable {

    /**
     * execute runs the scheduled job to update Referral Source objects
     * based on Referral Partner Change Requests in batches of 50.
     * @param  sc Contains the Trigger Id
     */ 
    global void execute(SchedulableContext sc) {
        database.executebatch(new ReferralSourceUpdate_Batch(), 50);
    }

}