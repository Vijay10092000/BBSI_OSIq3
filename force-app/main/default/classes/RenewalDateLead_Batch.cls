/**
 * @description RenewalDateLead_Batch finds Lead Renewal Dates which have past
 * and resets them into the future.
 */
public without sharing class RenewalDateLead_Batch implements Database.Batchable<Sobject> {
    @TestVisible
    private static Boolean constructed = false;
    private static final String FORMAT_LEAD_COUNT = 'LEAD COUNT: {0}\n';
    private static final String FORMAT_LEAD_RECORD = '\n  Lead Id: {0} - New Renewal Date: {1}';
    private static final String FORMAT_LEAD_ID = '\n  Lead Id: {0}';

    /**
     * @description RenewalDateLead_Batch constructor
     */
    public RenewalDateLead_Batch() {
        constructed = true;
    }

    /**
     * @description start queries the Leads which need to be updated
     * @param  context Batch Context
     * @return Database.QueryLocator
     */
    public Database.QueryLocator start(Database.BatchableContext context) {
        return Database.getQueryLocator(
            'SELECT Id, Name, Renewal_Date__c ' +
            ' FROM Lead ' +
            ' WHERE isConverted = FALSE ' +
            ' AND Renewal_Date__c != NULL ' +
            ' AND Renewal_Date__c < TODAY ' +
            ' ORDER BY Renewal_Date__c ASC'
        );
    }

    /**
     * @description execute finds Lead Renewal Dates which are in the past and pushes them one
     * year into the future.
     * @param  context Batch Context
     */
    public void execute(Database.BatchableContext context, List<Lead> leads) {
        Date today = Date.today();
        for (Lead l : leads) {
            while (l.Renewal_Date__c < today) 
            {
                DateTime beforeRequired = DateTime.newInstance(2023, 1, 13, 0, 0, 1);
                if(l.Lead_Creation_Date__c < beforeRequired)
                {
                    l.Validation_Rule_Skip_Toggle__c=true;
                }
                l.Renewal_Date__c = l.Renewal_Date__c.addYears(1);
            }
        }

        try {
            List<Database.SaveResult> errors = Database.update(leads, false);
			String description = 'Database write failed.  Job ' + context.getJobId() + ' : '+ context.getChildJobId();

            if (Log.writeIfError('Renewals', 'RenewalDateLead_Batch Failed', description, errors)) {
				String failedLeads = description + '\n\nFAILED LEADS';

				for (Lead l : leads) {
					failedLeads += String.format(FORMAT_LEAD_ID, new List<String>{ String.valueOf(l.Id) });
				}

				Log.info('Renewals', 'RenewalDateLead_Batch Ids', failedLeads);
			}
        } catch (Exception e) {
			writeErrorLog(e, leads);
        }
    }

    /**
     * @description finish performs any clean up work
     * @param  context Batch Context
     */
    @SuppressWarnings('PMD.EmptyStatementBlock')
    public void finish(Database.BatchableContext context) {
    }

	@TestVisible
	private void writeErrorLog(Exception e, List<Lead> leads) {
		String additional = String.format(FORMAT_LEAD_COUNT, new List<String>{ String.valueOf(leads.size()) });

		for (Lead l : leads) {
			additional += String.format(FORMAT_LEAD_RECORD, new List<String>{ String.valueOf(l.Id), String.valueof(l.Renewal_Date__c) });
		}

		Log.error('Renewals', 'RenewalDateLead_Batch.execute', additional, e);
	}
}