public without sharing class PricingReportService {
    // Billing History Map
    // When current markup line contains REG, blank or SAL, the order of priority is the following:
    // 1. REG
    // 2. blank line
    // 3. SAL
    @AuraEnabled
    public static Map<String, Decimal> buildBillingHistoryMap(Billing_History__c [] billingHistories)
    {
        Map<String, Decimal> billingMap = new Map<String, Decimal>();
        for(Billing_History__c bh : billingHistories) {
            String wcCode = bh.WC_Code__c.trim();
            Decimal rate = bh.Bundled_Rate__c == null ? 0 : bh.Bundled_Rate__c;
            String payCode = bh.Pay_Code__c;
            
            if (payCode.contains('REG')) {
                billingMap.put(wcCode + '.REG', (rate * 100).setScale(2));
            }

            if (payCode.length() == 0) {
                billingMap.put(wcCode + '.<blank>', (rate * 100).setScale(2));
            }

            if (payCode.contains('SAL')) {
                billingMap.put(wcCode + '.SAL', (rate * 100).setScale(2));
            }

            if (payCode.contains('OT') && !payCode.contains('OTH')) {
                billingMap.put(wcCode + '.OT', (rate * 100).setScale(2));
            }

            if (payCode.contains('DT')) {
                billingMap.put(wcCode + '.DT', (rate * 100).setScale(2));
            }
        }
        return billingMap;
    }
}