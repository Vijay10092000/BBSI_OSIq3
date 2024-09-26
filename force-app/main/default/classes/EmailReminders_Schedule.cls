/**
 * @description EmailReminders_Schedule start a chain of Batch methods to send Reminder emails.
 */
public with sharing class EmailReminders_Schedule  implements Schedulable {
    /**
     * @description execute runs the scheduled job to send reminder emails.
     * @param  sc  Contains the Trigger Id
     */
    public void execute(SchedulableContext sc) {
        database.executebatch(new EmailReminderTaskEvent_Batch(), 100);
    }
}