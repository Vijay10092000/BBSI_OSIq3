/**
 * ReferralPartnerOnConversion handles Referral Sources (Referral_Partner__c)
 * during a lead conversion.  Called during an After-Update in the Lead Trigger.
 */
public class ReferralPartnerOnConversion {

	List<lead> newCollection = (List<Lead>)trigger.new;
	Map<ID, lead> oldCollection = (Map<ID, Lead>)trigger.oldMap;
	list<lead> convertedLeads = new list<lead>();
	Map<Id, Set<Id>> lead2rp = new Map<Id, Set<Id>>();
    Map<Id, Referral_Partner__c> rps = new Map<Id, Referral_Partner__c>();

	public void handle() {
		getReferralPartners();
        List<Referral_Partner__c> rpsToUpdate = new List<Referral_Partner__c>();

        if(rps.size() > 0 && !rps.isEmpty()){
            rpsToUpdate = PopulateRP(rps);
        }

        if(rpsToUpdate.size() > 0 && !rpsToUpdate.isEmpty()){
             UpdateRP(rpsToUpdate);
        }
	}

	private void getReferralPartners(){
    	Set<Id> rpIds = new Set<Id>();

		for(lead l : newCollection){
			if(l.isConverted && !oldCollection.get(l.ID).isConverted){
				convertedLeads.add(l);
			}
		}

		if(convertedLeads.size() > 0){
			for (Referral_Partner__c rp : [Select Id, Lead__c From Referral_Partner__c Where Lead__c In :trigger.new]) {
		        if (!lead2rp.containsKey(rp.Lead__c)){
		            lead2rp.put(rp.Lead__c, new Set<Id>());
		        }

		        lead2rp.get(rp.Lead__c).add(rp.Id);
		        rpIds.add(rp.Id);
			}
		}
		if(rpIds.size() > 0){
            for(Referral_Partner__c rp : [Select Id, Account__c From Referral_Partner__c Where Id In :rpIds]){
                System.debug(rp);
                rps.put(rp.ID, rp);
            }
            System.debug(rps);
		}
	}

	private List<Referral_Partner__c> PopulateRP(Map<Id, Referral_Partner__c> rps){
		List<Referral_Partner__c> rpsToUpdate = new List<Referral_Partner__c>();
	    Id acpId = RecordTypeService.getId('Referral_Partner__c','Client_Referral_Partner');
		for(lead l : convertedLeads){
			if(lead2rp.get(l.Id) != null){
	            for (Id rpId : lead2rp.get(l.Id)) {
	                   Referral_Partner__c rp = rps.get(rpId);
	                   rp.Account__c = l.convertedAccountId;
	                   rp.RecordTypeId = acpId;
	                   rpsToUpdate.add(rp);
	            }
			}
		}

	    return rpsToUpdate;
	}


	private void UpdateRP(List<Referral_Partner__c> rpsToUpdate){
  	try{
			update rpsToUpdate;
		}catch(exception e){
			System.debug(e);
		}
	}

}