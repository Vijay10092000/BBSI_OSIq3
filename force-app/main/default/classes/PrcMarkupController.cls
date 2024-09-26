/*
 * Copyright (c) 2018. Barrett Business Services, Inc. All Rights Reserved
 * Created by agoganian on 10/9/2018
 */
public without sharing class PrcMarkupController {
    @AuraEnabled
    public static PricingWcCode__c[] getPricingWcCodes(String recordId)
    {
        return PrcWorkCompController.getPricingWcCodesWithPayroll(recordId);
    }

    @AuraEnabled
    public static void savePricingWcCodes(PricingWcCode__c[] wcCodes)
    {
        Database.SaveResult[] srList = Database.update(wcCodes, false);
        Database.SaveResult[] errorList = new List<Database.SaveResult>();

        for(Database.SaveResult sr :srList){
            if (!sr.isSuccess()){
                errorList.add(sr);
            }
        }
        if(errorList.size() > 0){
            System.debug('Save Pricing WC Codes Errors: ' + errorList);
        }
    }

    @AuraEnabled
    public static Billing_History__c[] getBillingHistories(String clientId)
    {
        Billing_History__c[] result = new List<Billing_History__c>();
        Account account = [
                SELECT Price_Info__c
                FROM Account
                WHERE External_ID__c = :clientId
                LIMIT 1
        ];

        if(account == null || account.Price_Info__c == null || account.Price_Info__c.length() == 0) {
            return result;
        }

        Map<Integer, Billing_History__c> billingMap = new Map<Integer, Billing_History__c>();
        String[] entries = account.Price_Info__c.split('\n');

        for(String entry : entries) {
            String[] s = entry.split('-');

            if(s.size() != 4) {
                continue;
            }

            Integer index = Integer.valueOf(s[0]);
            String wcCode = s[1];
            String payCode = s[2];
            Decimal billingRate = s[3] == '' ? 0 : Double.valueOf(s[3]) / 100;

            if(!billingMap.containsKey(index)) {
                Billing_History__c newBillingHistory = new Billing_History__c();
                newBillingHistory.WC_Code__c = wcCode;
                newBillingHistory.Pay_Code__c = payCode;
                newBillingHistory.Bundled_Rate__c = billingRate;
                billingMap.put(index, newBillingHistory);
            }
            else {
                Billing_History__c current = billingMap.get(index);
                current.Pay_Code__c += ', ' + payCode;
                billingMap.put(index, current);
            }
        }

        result.addAll(billingMap.values());
        return result;
    }

    @AuraEnabled
    public static Map<String, String> getSafetyIncentives(String clientId)
    {
        Map<String, String> result = new Map<String, String>();
        Account account = [
                SELECT Safety_Incentive_Info__c
                FROM Account
                WHERE External_ID__c = :clientId
                LIMIT 1
        ];

        if(account == null || account.Safety_Incentive_Info__c == null || account.Safety_Incentive_Info__c.length() == 0) {
            return result;
        }

        String[] entries = account.Safety_Incentive_Info__c.split('\n');
        for(String entry : entries) {
            String[] si = entry.split('-');
            if(si.size() != 2) {
                continue;
            }
            String code = si[0].trim().leftPad(4, '0');
            String value = si[1].trim();
            if(!result.containsKey(code)) {
                result.put(code, value);
            }
        }
        return result;
    }
}