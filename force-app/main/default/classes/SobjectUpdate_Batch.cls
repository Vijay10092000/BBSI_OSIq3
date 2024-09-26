/**
 * @description SobjectUpdate_Batch updates a batch of SObjects.  Use this when there are
 * many SObjects to update at a single time.
 */
public with sharing class SobjectUpdate_Batch implements Database.Batchable<SObject> {
	public List <SObject> objects = new List<SObject>();

	/**
	 * @description SObjectUpdate_Batch constructor.
	 * @param  objects  List of SObjects to update in a batch process
	 */
	public SObjectUpdate_Batch(List<SObject> objects) {
		this.objects = objects;
	}

	/**
	 * @description start retrieves the list of records to process
	 * @param  context  Information about the Batch job, including Id
	 * @return List<SObject>
	 */
	public List<SObject> start(Database.BatchableContext context) {
		return objects;
	}

	/**
	 * @description execute performs the operation on a batch of objects.
	 * @param  context Information about the Batch job, including Id
	 * @param  scope   Contains the Client SObjects to process
	 */
	public void execute(Database.BatchableContext context, List<sObject> scope) {
   		update scope;
	}

	/**
	 * @description finish performs actions after processing has completed.
	 * @param  context Information about the Batch job, including Id
	 */
	@SuppressWarnings('PMD.EmptyStatementBlock')
	public void finish(Database.BatchableContext context) {
	}
}