/**
 * @description WorkCompRateScheduler schedulable class to update Work Comp Rates.
 * The first deletes the current rates and calls the batch to pull the rates in
 * from (Boomi?).
 */
global class WorkCompRateScheduler implements Schedulable {
	global void execute(SchedulableContext sc) {
		Database.executeBatch(new WorkCompRateDeleteBatch());
	}
}