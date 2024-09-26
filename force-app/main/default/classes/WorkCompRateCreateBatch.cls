/**
 * @description WorkCompRateCreateBatch creates new Worker Comp Rates.
 */
public class WorkCompRateCreateBatch implements Database.Batchable<WorkCompRate__c>, Database.Stateful, Database.AllowsCallouts {
	// US States plus American Samoa, Northern Mariana Islands, District of Columbia, Guam, Puerto Rico,
	// Trust Territories and Virgin Islands
	private static final String ABBRIVATION_STATES =
		'AK;AL;AR;AZ;CA;CO;CT;DE;FL;GA;HI;IA;ID;IL;IN;KS;KY;LA;MA;MD;ME;MI;MN;MO;MS;' +
		'MT;NC;ND;NE;NH;NJ;NM;NV;NY;OH;OK;OR;PA;RI;SC;SD;TN;TX;UT;VA;VT;WA;WI;WV;WY;' +
		'AS;CM;DC;GU;PR;TT;VI;';

	List<Database.SaveResult> allSaveResults = new List<Database.SaveResult>();

	/**
	 * @description start retrieves WorkCompRates to create.  Only returns those with
	 * a valid US State abbreviation.
	 * @param  context  The Batch context
	 * @return List of WorkCompRate__c to process
	 */
	public List<WorkCompRate__c> start(Database.BatchableContext context) {
		Log logInvalidStates = new Log();

		List<WorkCompRate__c> result = new List<WorkCompRate__c>();

		List<WorkCompPolicyCodeRate.DATA> data = WorkCompController.getWorkCompPolicyCodeRate();

		//if (data != null) {
			for (WorkCompPolicyCodeRate.DATA wcp : data) {
				if (wcp.State.length() == 2  && ABBRIVATION_STATES.contains(wcp.State)) {
					WorkCompRate__c wcr = new WorkCompRate__c(
						Policy__c = wcp.WcPolicy,
						State__c = wcp.State,
						Code__c = wcp.Code,
						Rate__c = wcp.Rate
					);

					result.add(wcr);
				}
				else {
					logInvalidStates.addLine('Invalid WcPolicy: ' + wcp.WcPolicy + '  State: ' + wcp.State + '  Code: ' + wcp.Code + '  Rate: ' + wcp.Rate);
				}
			}

			if (logInvalidStates.hasDescription()) {
				logInvalidStates.description = 'WC POLICIES REMOVED FROM PROCESSING\n' + logInvalidStates.description;
				logInvalidStates.write(Log.Severity.WARN, 'WorkCompRate Nightly Batch', 'WorkCompRateCreateBatch: Invalid Work Comp Rates');
			}
		//}

		return result;
	}

	/**
	 * @description execute creates the WorkCompRates.  Errors are saved to write later.
	 * @param  context  The Batch context
	 * @param  scope    The SObjects
	 */
	public void execute(Database.BatchableContext context, List<WorkCompRate__c> scope) {
		allSaveResults.addAll( Database.insert(scope, false) );
	}

	/**
	 * @description finish performs cleanup work for batch process.  Write errors to a Log record.
	 * @param  context  The Batch context
	 */
	public void finish(Database.BatchableContext context) {
		Log.writeIfError('WorkCompRate Nightly Batch', 'WorkCompRateCreateBatch: Insertion Failures', null, allSaveResults);
	}
}