/*
 * Copyright (c) 2018. Barrett Business Services, Inc. All Rights Reserved
 * Created by agoganian on 10/9/2018
 */
public without sharing class PrcScenarioController 
{
    @AuraEnabled
    public static PricingScenario__c getPricingScenario(String recordId)
    {
        PricingScenario__c result = 
        [
            SELECT
                    CreatedById,
                    CreatedDate,
                    CreatedDate__c,
                    FEIN__c,
                    Id,
                    LastActivityDate,
                    LastModifiedById,
                    LastModifiedDate,
                    LastModifiedDate__c,
                    Name,
                    Notes__c,
                    OwnerId,
                    Renewal__c,
                    Renewal__r.Renewal_Date__c,
                    Renewal__r.Renewal_Date_Add_1__c,
                    ScenarioName__c,
                    Status__c, (
                    SELECT Id, ClientName__c, ClientId__c
                    FROM ClientPricingScenarios__r
                    ORDER BY ClientId__c)
            FROM PricingScenario__c Id
            WHERE Id = :recordId
        ];

        return result;
    }

    @AuraEnabled
    public static Renewal__c getRenewal(String recordId)
    {
        Renewal__c result = 
        [
            SELECT
                    Branch__c,
                    Business_Unit__c,
                    Clients__c,
                    CreatedById,
                    CreatedDate,
                    FEIN__c,
                    Id,
                    LastActivityDate,
                    LastModifiedById,
                    LastModifiedDate,
                    LastReferencedDate,
                    Name,
                    OwnerId,
                    Renewal_Date__c,
                    Renewal_Date_Add_1__c,
                    Renewal_Link__c,
                    Status__c
            FROM Renewal__c
            WHERE Id = :recordId
        ];

        return result;
    }

    @AuraEnabled
    public static void SavePricingScenario(PricingScenario__c pricingScenario)
    {
        Database.SaveResult sr = Database.update(pricingScenario, false);

        if (!sr.isSuccess()){
            system.debug('Save Pricing Scenario Errors: ' + sr.getErrors());
        }
    }

    @AuraEnabled
    public static void SaveRenewal(Renewal__c renewal)
    {
        Database.SaveResult sr = Database.update(renewal, false);

        if (!sr.isSuccess()){
            system.debug('Save Renewal Errors: ' + sr.getErrors());
        }
    }

    @AuraEnabled
    public static ClientPricingScenario__c getClientPricingScenario(String recordId)
    {
        ClientPricingScenario__c result = [
            SELECT Id, IsProspect__c, Name, Opportunity__c, Opportunity__r.Name
            FROM ClientPricingScenario__c
            WHERE Id = :recordId
        ];

        return result;
    }
}