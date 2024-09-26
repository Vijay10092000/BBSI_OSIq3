public without sharing class PricingScenarioService 
{
    @AuraEnabled
    public static void DeletePricingScenario(String pricingScenarioId)
    {
        ClientPricingScenario__c[] clients = [
            SELECT Id
            FROM ClientPricingScenario__c
            WHERE PricingScenario__c =: pricingScenarioId
        ];

        for(ClientPricingScenario__c cps: clients) {
            PricingWcCode__c[] codes = [
                SELECT Id
                FROM PricingWcCode__c
                WHERE ClientPricingScenario__c =: cps.Id
            ];

            PricingEEtoWcCodeAssoc__c[] associations = [
                SELECT Id
                FROM PricingEEtoWcCodeAssoc__c
                WHERE PricingWcCode__c =: codes
                LIMIT 200
            ];

            while(associations.size() > 0)
            {
                delete associations;
                associations = [
                    SELECT Id
                    FROM PricingEEtoWcCodeAssoc__c
                    WHERE PricingWcCode__c =: codes
                    LIMIT 200
                ];
            }

            PricingEmployee__c[] employees = [
                SELECT Id
                FROM PricingEmployee__c
                WHERE ClientPricingScenario__c =: cps.Id
                LIMIT 200
            ];

            while(employees.size() > 0) {
                delete employees;
                employees = [
                    SELECT Id
                    FROM PricingEmployee__c
                    WHERE ClientPricingScenario__c =: cps.Id
                    LIMIT 200
                ];
            }
        }

        delete new PricingScenario__c(Id = pricingScenarioId);
    }

}