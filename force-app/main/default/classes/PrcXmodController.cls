/*
 * Copyright (c) 2018. Barrett Business Services, Inc. All Rights Reserved
 */
public without sharing class PrcXmodController {
    @AuraEnabled
    public static PricingXmod__c[] getPublishedXmods(String recordId, String maxRows)
    {
        Integer maximumRows = Integer.valueOf(maxRows);
        PricingXmod__c[] results = [
                SELECT
                        ClientPricingScenario__c,
                        CreatedDate,
                        Id,
                        IsDeleted,
                        IsPricingXmod__c,
                        IsPublishedXmod__c,
                        Name,
                        Published_Xmod__c,
                        State_Code__c,
                        Xmod__c,
                        XmodDate__c,
                        XmodStatus__c,
                        Year__c,
                        ClientPricingScenario__r.BureauReportUrl__c
                FROM PricingXmod__c
                WHERE ClientPricingScenario__c = :recordId
                AND   IsPublishedXmod__c = TRUE
                AND   IsPricingXmod__c != TRUE
                ORDER BY State_Code__c, Year__c DESC, XmodDate__c DESC
                LIMIT : maximumRows];
        System.debug('getPublishedXmods OUT: ' + results.size() + ', ' + results);
        return results;
    }

    @AuraEnabled
    public static PricingXmod__c[] getXmodHistory(String recordId, String maxRows){
        Integer maximumRows = Integer.valueOf(maxRows);
        PricingXmod__c[] results = [
                SELECT
                        ClientPricingScenario__c,
                        CreatedDate,
                        Id,
                        IsDeleted,
                        IsPricingXmod__c,
                        IsPublishedXmod__c,
                        Name,
                        Published_Xmod__c,
                        State_Code__c,
                        Xmod__c,
                        XmodDate__c,
                        XmodStatus__c,
                        Year__c
                FROM PricingXmod__c
                WHERE ClientPricingScenario__c = :recordId
                AND   IsPublishedXmod__c != TRUE
                AND   IsPricingXmod__c != TRUE
                ORDER BY Year__c DESC, XmodDate__c DESC, State_Code__c
                LIMIT : maximumRows];
        System.debug('getXmodHistory OUT: ' + results.size() + ', ' + results);
        return results;
    }

    @AuraEnabled
    public static PricingXmod__c[] getRenewalYearXmods(String recordId)
    {
        PricingXmod__c[] results = [
                SELECT
                        ClientPricingScenario__c,
                        CreatedDate,
                        Id,
                        IsDeleted,
                        IsPricingXmod__c,
                        IsPublishedXmod__c,
                        Name,
                        Published_Xmod__c,
                        State_Code__c,
                        Xmod__c,
                        XmodDate__c,
                        XmodStatus__c,
                        Year__c
                FROM PricingXmod__c
                WHERE ClientPricingScenario__c = :recordId
                AND   IsPricingXmod__c = TRUE
                ORDER BY State_Code__c, Year__c DESC, XmodDate__c DESC];
        return results;
    }

    @AuraEnabled
    public static void saveRenewalXmods(PricingXmod__c[] xmodList)
    {
        Database.SaveResult[] srList;
        Database.Error[] errList = new List<Database.Error>();

        srList = Database.update(xmodList, false);
        for (Database.SaveResult sr : srList) {
            if (!sr.isSuccess()){
                errList.addAll(sr.getErrors());
            }
        }
        if(errList.size() > 0){
            System.debug('Xmod Error List: ' + errList);
        }
    }

    @AuraEnabled
    public static XmodRecommended__c[] getXmodRecommended(String recordId)
    {
        ClientPricingScenario__c cps = [
                SELECT Id, ClientId__c, IsProspect__c
                FROM ClientPricingScenario__c
                WHERE Id = :recordId
                LIMIT 1
        ];

        XmodRecommended__c[] recommendedXmods = [
                SELECT  Id, Name, Client__c, Client__r.External_ID__c, Client_Info__c, Effective_Date__c, Notes__c,
                        Policy_Number__c, State_Code__c, Work_Comp_Policy__c, Work_Comp_Policy__r.Id, Xmod__c
                FROM XmodRecommended__c
                WHERE Client_Info__c = :cps.ClientId__c
                ORDER BY Effective_Date__c DESC
        ];

        return recommendedXmods;
    }
}