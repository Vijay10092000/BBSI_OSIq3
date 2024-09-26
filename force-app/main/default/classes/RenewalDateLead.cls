/**
 * @description RenewalDateLead is a Schedulable class to update Renewal Dates for unconverted
 * Leads.
 */
@SuppressWarnings('PMD.AvoidGlobalModifier')
public without sharing class RenewalDateLead implements Schedulable {
	private static final Integer BATCH_SIZE = 200;

    /**
     * @description execute runs the scheduled job to update the Renewal Date on Leads.
     * @param  sc Contains the Trigger Id
     */
    public void execute(SchedulableContext sc) {
        Database.executebatch(new RenewalDateLead_Batch(), BATCH_SIZE);
    }
}