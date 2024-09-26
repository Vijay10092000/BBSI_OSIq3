global class BenefitsRenewalScheduler implements Schedulable {
    global void execute(SchedulableContext sc) {
        Database.executeBatch(new BenefitsRenewalBatch(),100);
    }
}