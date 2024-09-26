/**
 * @description AccountUpdate_Batch updates a Batch of Accounts.  Use this when there are
 * many Accounts to update at a single time.
 */
public with sharing class AccountUpdate_Batch implements Database.Batchable<sObject> {
	public List <Account> accounts = new List<Account>();

	/**
	 * @description AccountUpdate_Batch constructor.
	 * @param  accounts  List of Accounts to update in a batch process
	 */
	public AccountUpdate_Batch(List<Account> accounts) {
		this.accounts = accounts;
	}

	/**
	 * @description start retrieves the list of records to process
	 * @param  context  Information about the Batch job, including Id
	 * @return List<Account>
	 */
	public List<Account> start(Database.BatchableContext context) {
		return accounts;
	}

	/**
	 * @description execute performs the operation on a batch of objects.
	 * @param  context Information about the Batch job, including Id
	 * @param  scope   Contains the Client Accounts to process
	 */
	public void execute(Database.BatchableContext context, List<sObject> scope) {
   		update ((List<Account>) scope);
	}

	/**
	 * @description finish performs actions after processing has completed.
	 * @param  context Information about the Batch job, including Id
	 */
	@SuppressWarnings('PMD.EmptyStatementBlock')
	public void finish(Database.BatchableContext context) {
	}
}