global class CreateRenewalsSchedulable implements Schedulable {
	global void execute(SchedulableContext sc) {
		CreateRenewalsBatchable renewalsBatchable = new CreateRenewalsBatchable(); 
		database.executebatch(renewalsBatchable, 20);
	}
}