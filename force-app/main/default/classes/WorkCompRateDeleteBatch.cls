/**
 * @description WorkCompRateDeleteBatch deletes the current Work Comp Rates and calls
 * WorkCompRateCreateBatch to create new ones.
 */
public class WorkCompRateDeleteBatch implements Database.Batchable<sObject>, Database.Stateful {
	String logMessage = '';

	/**
	 * @description start retrieves the current WorkCompRates to delete.
	 * @param  context  The Batch context
	 * @return Database.QueryLocator containing the WorkCompRate__cs to delete
	 */
	public Database.QueryLocator start(Database.BatchableContext context) {
		return Database.getQueryLocator('SELECT Id FROM WorkCompRate__c');
	}

	/**
	 * @description execute deletes the WorkCompRates.  Errors are saved to write later.
	 * @param  context  The Batch context
	 * @param  scope    The SObjects
	 */
	public void execute(Database.BatchableContext context, List<SObject> scope) {
		logMessage += makeErrorString( Database.delete(scope, false) );
	}

	/**
	 * @description finish performs cleanup work for batch process.  Write errors to a Log record and
	 * call WorkCompRateCreateBatch to create the new rates.
	 * @param  context  The Batch context
	 */
	public void finish(Database.BatchableContext context) {
		if (0 < logMessage.length()) {
			Log.error('WorkCompRateDeleteBatch', 'Deletion Failures', logMessage);
		}

		Database.executeBatch(new WorkCompRateCreateBatch());
	}

	/**
	 * @description makeErrorString create a string containing the errors from the database.
	 * @param  listDeletes  List of delete results
	 * @return String of errors
	 */
	private String makeErrorString(List<Database.DeleteResult> listDeletes) {
		String result = '';

		if (listDeletes != null && listDeletes.size() > 0) {
			for (Database.DeleteResult dr : listDeletes) {
				if (!dr.isSuccess()) {
					result += Log.formatDatabaseErrors(Id_Service.makeIdString(dr.getId()), dr.getErrors());
				}
			}
		}

		return result;
	}
}