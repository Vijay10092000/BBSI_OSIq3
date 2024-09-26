/**
 * @description LeadConvert_Queueable converts a bunch of Leads.   
 */
public without sharing class LeadConvert_Queueable implements Queueable {
	private List<Lead> leads;
    
    /**
     * @description convert converts Leads into Contacts and Accounts with Opportunities
     * when a Lead is a Client Lead.
     * @param  idLeads  Lead identifiers
     */
    public static void convert(List<Id> idLeads) {
		if (!idLeads.isEmpty()) {
            List<Lead> leads = ([SELECT Id, Name, RecordTypeId FROM Lead WHERE Id IN :idLeads AND IsConverted = FALSE]);
            
            if (!leads.isEmpty()) {
            	System.enqueueJob(new LeadConvert_Queueable(leads));
            }
		}
    }

	/**
	 * @description LeadConvert_Queueable constructor.
	 * @param  idRecords     Lead identifiers to convert
	 */
	public LeadConvert_Queueable(List<Lead> leads) {     
		this.leads = leads;
	}

	/**
	 * @description execute converts on a group of Leads.
	 * @param  context  Information about the Queueable job
	 */
	public void execute(QueueableContext context) {        
        Id idrtLeadClient = RecordTypeService.getId('Lead', 'Client Lead');
        
		LeadStatus convertedStatus = [SELECT MasterLabel FROM LeadStatus WHERE IsConverted = TRUE LIMIT 1];

		List<Database.LeadConvert> converts = new List<Database.LeadConvert>();

		for (Lead lead : leads) {
			Database.LeadConvert convert = new Database.LeadConvert();

			convert.setLeadId(lead.Id);
			convert.setConvertedStatus(convertedStatus.MasterLabel);
			convert.setDoNotCreateOpportunity(lead.RecordTypeId != idrtLeadClient);

			converts.add(convert);
		}

		 Database.convertLead(converts);
	}
}