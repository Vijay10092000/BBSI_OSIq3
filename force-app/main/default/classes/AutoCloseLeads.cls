public class AutoCloseLeads implements Database.Batchable<sObject> {
	private static final String QUERY_TESTING =
		'SELECT Id, Status, LastModifiedDate ' +
		' FROM Lead ' +
		' WHERE Status != \'Unqualified\'';

	private static final String FORMAT_QUERY =
		'SELECT Id, Status, LastModifiedDate ' +
		' FROM Lead ' +
		' WHERE Status != \'Unqualified\' ' +
		' AND LastModifiedDate < LAST_N_DAYS:{0}';

	private static final Integer DEFAULT_DAYS_FOR_AUTO_CLOSE = 30;

	public Database.QueryLocator start(Database.BatchableContext context) {
		Integer daysForAutoClose = getDaysForAutoClose();

		String query = String.format(FORMAT_QUERY, new List<String>{ String.valueOf(daysForAutoClose) });

		if (Test.isRunningTest()) {
			query = QUERY_TESTING;
		}

		return Database.getQueryLocator(query);
	}

	public void execute(Database.BatchableContext context, List<SObject> scope) {
		if (!scope.isEmpty()) {
			List<Lead> leads = (List<Lead>) scope;

			for (Lead lead : leads) {
				lead.Status = 'Unqualified';
				lead.Unqualified_Reason__c = 'Neglect';
			}

			update leads;
		}
	}

	@SuppressWarnings('PMD.EmptyStatementBlock')
	public void finish(Database.BatchableContext context) {
	}

	private Integer getDaysForAutoClose() {
		OrgWide__c orgWide = OrgWide__c.getOrgDefaults();

		if (!String.isBlank(orgWide.Days_For_Auto_Close_Leads__c)) {
			if (orgWide.Days_For_Auto_Close_Leads__c.isNumeric()) {
				return Integer.valueOf(orgWide.Days_For_Auto_Close_Leads__c);
			}
		}

		return DEFAULT_DAYS_FOR_AUTO_CLOSE;
	}
}