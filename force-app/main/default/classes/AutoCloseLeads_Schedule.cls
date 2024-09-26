global class AutoCloseLeads_Schedule implements Schedulable {
	global void execute(SchedulableContext sc) {
		database.executebatch(New AutoCloseLeads(),200);
	}
}