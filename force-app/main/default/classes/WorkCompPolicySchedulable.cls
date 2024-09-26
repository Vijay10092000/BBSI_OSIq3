global class WorkCompPolicySchedulable implements Schedulable {

	global void execute(SchedulableContext sc) {
		WorkCompPolicyBatch b = new WorkCompPolicyBatch();
        database.executeBatch(b);
	}
}