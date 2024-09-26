global class RenewalDateOpportunity implements Schedulable {
	global void execute(SchedulableContext sc) {
        list<Opportunity> renewalOpp = new list<Opportunity>([select ID, Renewal_Date__c from Opportunity where Renewal_Date__c <= Today]);

        if(renewalOpp.size() > 0){
            updateLeadOpportunityDate(renewalOpp);
        }
	}

	private void updateLeadOpportunityDate(list<Opportunity> dateOpportunity){
        for(Opportunity o: dateOpportunity){
            if(o.Renewal_Date__c != NULL){
                Date d;
                d = date.newInstance(o.Renewal_Date__c.Year()+1, o.Renewal_Date__c.Month(), o.Renewal_Date__c.Day());
                o.Renewal_Date__c = d;                
            }
        }

        update dateOpportunity;
    }
}