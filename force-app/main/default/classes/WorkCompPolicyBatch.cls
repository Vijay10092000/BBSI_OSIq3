/**
 * @description WorkCompPolicyBatch updates renewal dates for Prospects.
 */
public class WorkCompPolicyBatch implements Database.Batchable<sObject>, Database.Stateful {
	// @description QUERY_PROSPECTS retrieves all the Prospect Accounts with expired Renewal Dates.
	private static final String QUERY_PROSPECTS =
		'SELECT Id, CreatedDate, Renewal_Date__c, Start_Date__c, Validation_Rule_Skip_Toggle__c ' +
		'FROM Account ' +
		'WHERE RecordType.Name = \'Prospect\' ' +
		'AND (Renewal_Date__c < TODAY OR Renewal_Date__c = NULL) ' +
		'ORDER BY CreatedDate DESC';

	// @description errors contains all the error messages for this batch run.
	@TestVisible
	private String errors = '';

	/**
	 * @description start determines which records need to be updated.
	 * @param  context  Batch Context
	 * @return Database.QueryLocator
	 */
	public Database.QueryLocator start(Database.BatchableContext context) {
		return Database.getQueryLocator(QUERY_PROSPECTS);
	}

	/**
	 * @description execute determines and sets the new Renewal Date for a batch of Prospect Accounts.
	 * @param  context    Batch Context
	 * @param  prospects  List of Prospect Accounts
	 */
	public void execute(Database.BatchableContext context, List<Account> prospects) {
		for (Account prospect : prospects) {
			prospect.Renewal_Date__c = calculateNewRenewalDate(prospect);
			prospect.Validation_Rule_Skip_Toggle__c = !prospect.Validation_Rule_Skip_Toggle__c;
		}

		addErrors(prospects, database.update(prospects, false));
	}

	/**
	 * @description finish write errors to a Log record.
	 * @param  context  Batch Context
	 */
	public void finish(Database.BatchableContext context) {
		if (errors != '') {
			Log.error('WorkCompPolicyBatch', 'Renewal Date Update Error', 'DATABASE ERRORS' + errors);
		}
	}

	/**
	 * @description calculateNewRenewalDate determines the new Renewal Date for the given Prospect.
	 * @param  prospect  Prospect Account
	 * @return New Renewal Date
	 */
	private Date calculateNewRenewalDate(Account prospect) {
		Date result = date.valueOf(prospect.createdDate);

		if (prospect.Renewal_Date__c != null) {
			result = prospect.Renewal_Date__c;
		} else if (prospect.Start_Date__c != null) {
			result = prospect.Start_Date__c;
		}

		while (result <= System.today()) {
			result = result.addYears(1);
		}

		return result;
	}

	/**
	 * @description addErrors adds database errors to the errors String.
	 * @param  prospects  List of Prospect Accounts
	 * @param  srList     List of SaveResults
	 */
	private void addErrors(List<Account> prospects, List<Database.SaveResult> srList) {
		for (Integer i = 0; i < srList.size(); i++) {
			if (!srList.get(i).isSuccess()) {
				errors += '\n' + prospects.get(i).Id + ' ' + srList.get(i).getErrors();
			}
		}
	}
}