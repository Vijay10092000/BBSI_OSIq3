/**
 * @description DatabaseUpdateBatch updates a batch of SObjects records.
 *  Use this when there are many SObjects to update at a single time and
 * the update can wait.
 *
 * BUNDLE: BASE
 *
 * @see Database.Batchable https://developer.salesforce.com/docs/atlas.en-us.apexref.meta/apexref/apex_interface_database_batchable.htm#apex_interface_database_batchable
 */
public without sharing class DatabaseUpdateBatch implements Database.Batchable<sObject>, Database.Stateful {
	private List<SObject> records;
	private String errorBundle;
	private String errorSubject;
	private Boolean allOrNothing;

	private List<Database.SaveResult> results = new List<Database.SaveResult>();

	/**
	 * @description dispatch creates the batch processor and executes it.  Bundle size: 200
	 * @param  records       Records to insert into the database
	 * @param  allOrNothing  If fails on one back out all?
	 * @param  errorBundle   Bundle of calling method
	 * @param  errorSubject  Subject for an error.
	 */
	public static void dispatch(List<SObject> records, Boolean allOrNothing, String errorBundle, String errorSubject) {
		System.debug(LoggingLevel.FINE, 'DatabaseUpdateBatch.dispatch(): \n' + records);

		Database.executeBatch(new DatabaseUpdateBatch(records, allOrNothing, errorBundle, errorSubject), 200);
	}

	/**
	 * @description dispatch creates the batch processor and executes it.
	 * @param  records       Records to insert into the database
	 * @param  allOrNothing  If fails on one back out all?
	 * @param  errorBundle   Bundle of calling method
	 * @param  errorSubject  Subject for an error.
	 * @param  bundleCount   Number of records to handle in each bundle.
	 */
	public static void dispatch(
		List<SObject> records,
		Boolean allOrNothing,
		String errorBundle,
		String errorSubject,
		Integer bundleCount
	) {
//		Debug_Service.debug(LoggingLevel.DEBUG, 'DatabaseUpdateBatch.dispatch ' + bundleCount + '   record size: ' + records.size(), records);

		Database.executeBatch(new DatabaseUpdateBatch(records, allOrNothing, errorBundle, errorSubject), bundleCount);
	}

	/**
	 * @description DatabaseUpdateBatch constructor.
	 * @param  records       Records to insert into the database
	 * @param  allOrNothing  If fails on one back out all?
	 * @param  errorBundle   Bundle of calling method
	 * @param  errorSubject  Subject for an error.
	 */
	public DatabaseUpdateBatch(List<SObject> records, Boolean allOrNothing, String errorBundle, String errorSubject) {
		this.records = records;
		this.allOrNothing = allOrNothing;
		this.errorBundle = errorBundle;
		this.errorSubject = errorSubject;

		Debug_Service.debug(
			LoggingLevel.DEBUG,
			'====================================================================' +
			'DatabaseUpdateBatch: Updating Records' +
			'====================================================================',
			records
		);
	}

	/**
	 * @description start retrieves the list of records to process
	 * @param  context  Information about the Batch job, including Id
	 * @return List<SObject>
	 */
	public List<SObject> start(Database.BatchableContext context) {
		return records;
	}

	/**
	 * @description execute performs the operation on a batch of objects.
	 * @param  context Information about the Batch job, including Id
	 * @param  objects Contains the Client SObjects to process
	 */
	public void execute(Database.BatchableContext context, List<sObject> objects) {
		List<Database.SaveResult> srList = Database.update(objects, allOrNothing);

		results.addAll(srList);
	}

	/**
	 * @description finish performs actions after processing has completed.
	 * @param  context Information about the Batch job, including Id
	 */
	public void finish(Database.BatchableContext context) {
		Log.writeIfError(errorBundle, errorSubject, 'DatabaseUpdateBatch.execute() failed', results);
	}
}