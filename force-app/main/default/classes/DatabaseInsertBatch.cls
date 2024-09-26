/**
 * @description DatabaseInsertBatch uses a Batchable to insert a List of records
 * into the database.  Use when the number of rows to insert is large and/or will
 * hit the 10000 record govenor limit.
 *
 * BUNDLE: BASE
 *
 * @see Database.Batchable https://developer.salesforce.com/docs/atlas.en-us.apexref.meta/apexref/apex_interface_database_batchable.htm#apex_interface_database_batchable
 */
public without sharing class DatabaseInsertBatch implements Database.Batchable<sObject>, Database.Stateful {
	private List<SObject> records;
	private String errorBundle;
	private String errorSubject;
	private Boolean allOrNothing;

	private List<Database.SaveResult> results = new List<Database.SaveResult>();

	/**
	 * @description DatabaseInsertBatch constructor.
	 * @param  records       Records to insert into the database
	 * @param  allOrNothing  If fails on one back out all?
	 * @param  errorBundle   Bundle of calling method
	 * @param  errorSubject  Subject for an error.
	 */
	public DatabaseInsertBatch(List<SObject> records, Boolean allOrNothing, String errorBundle, String errorSubject) {
		this.records = records;
		this.allOrNothing = allOrNothing;
		this.errorBundle = errorBundle;
		this.errorSubject = errorSubject;
	}

	/**
	 * @description start retrieves the records to insert.
	 * @param  context Context of the Batchable
	 * @return List of SObjects to insert
	 */
	public List<SObject> start(Database.BatchableContext context) {
		return records;
	}

	/**
	 * @description execute performs the database insert on a batch of records.
	 * @param  context Context of the Batchable
	 * @param  objects Records to insert in current batch
	 */
	public void execute(Database.BatchableContext context, List<SObject> objects) {
		List<Database.SaveResult> srList = Database.insert(objects, allOrNothing);

		results.addAll(srList);
	}

	/**
	 * @description finish performs any clean up needed.
	 * @param  context Context of the Batchable
	 */
	public void finish(Database.BatchableContext context) {
		Log.writeIfError(
			errorBundle,
			errorSubject,
			'DatabaseInsertBatch.execute() failed',
			results
		);
	}
}