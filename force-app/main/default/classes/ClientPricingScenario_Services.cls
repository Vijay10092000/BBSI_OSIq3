public without sharing class ClientPricingScenario_Services {

    public static void RollupModifiedDates(map<ID,ClientPricingScenario__c> newValues, Map<Id,ClientPricingScenario__c> oldValues){
        
        Map<Id, Datetime> PricScenDateMap = new Map<Id, Datetime>();
        Id pricScenId;
        DateTime lastModDate;

        for(Id key : newValues.keySet()){
            if(newValues.get(key).LastModifiedDate > oldValues.get(key).LastModifiedDate){
                lastModDate = newValues.get(key).LastModifiedDate;
                pricScenId = newValues.get(key).PricingScenario__c;
                if(PricScenDateMap.containsKey(pricScenId)){
                    if(lastModDate > PricScenDateMap.get(pricScenId)){
                        PricScenDateMap.put(pricScenId, lastModDate);
                    }
                }else {
                   PricScenDateMap.put(pricScenId, lastModDate);
                }
            }
        }
        if(PricScenDateMap.keySet().size() > 0){
            PricingScenario__c[] psList = [SELECT Id, LastModifiedDate__c from PricingScenario__c WHERE Id in : PricScenDateMap.keySet()];
            for(PricingScenario__c item : psList){
                item.LastModifiedDate__c = PricScenDateMap.get(item.Id);
            }
            if(psList.size() < 1) {return;}
            Database.Upsert(psList, false);
        }
    }
}