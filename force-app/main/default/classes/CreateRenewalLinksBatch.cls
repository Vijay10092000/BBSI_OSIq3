/**
 * @description CreateRenewalLinksBatch is part of the nightly process which creates
 * renewal links.
 */
public class CreateRenewalLinksBatch implements Database.Batchable<String> {
	private static final String FORMAT_QUERY_FEINS =
		'SELECT Fein__c, COUNT(Id) FROM Renewal__c ' +
		' WHERE Fein__c LIKE \'\'{0}%\'\' ' +
		' AND Renewal__c.Status__c NOT IN (\'Terminated\', \'Complete\', \'Incomplete\') ' +
		' GROUP BY Fein__c ' +
		' HAVING COUNT(Id) > 1';

	/**
	 * @description start retrieves the list of records to process
	 * @param  context Information about the Batch job, including Id
	 * @return An iterator over the Renewals to process
	 */
	public Iterable<String> start(Database.BatchableContext context) {
		return getDuplicateFeins();
	}

	/**
	 * @description execute performs the operation on a batch of objects.
	 * @param  context Information about the Batch job, including Id
	 * @param  scope   Contains the FEINs to process
	 */
	public void execute(Database.BatchableContext context, List<String> scope) {
		List<String> feins = new List<String>();
		String text = 'FEIN Count: ' + scope.size() + '\nFEINS WITH MULTIPLE RENEWALS\n';

		for (String fein : scope) {
			feins.add(fein);
			text += '\n' + fein;
		}

		Log.info('Renewals - CreateRenealLinkBatch.execute()', 'Run batch of duplicate FEINs', text);

		CreateRenewalLinks.CreateRenewalLinks(feins);
	}

	/**
	 * @description finish performs actions after processing has completed.
	 * In this case processing ends.
	 * @param  context Information about the Batch job, including Id
	 */
	@SuppressWarnings('PMD.EmptyStatementBlock')
	public void finish(Database.BatchableContext context) {
	}

	@SuppressWarnings('PMD.OperationWithLimitsInLoop')
	private List<String> getDuplicateFeins() {
		List<String> result = new List<String>();

		for (Integer i = 0; i < 10; i++) {
			List<AggregateResult> listAR = (List<AggregateResult>) Database.query(
				String.format(FORMAT_QUERY_FEINS, new List<String>{ String.valueOf(i) })
			);

			for (AggregateResult ar : listAR) {
				result.add((String) ar.get('FEIN__c'));
			}
		}

		return result;
	}
}