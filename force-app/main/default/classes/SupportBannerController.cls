public without sharing class SupportBannerController {

    @AuraEnabled
    public static Map<String, Support_Banner_Setting__mdt> getBannerSettings() {
        Map<String, Support_Banner_Setting__mdt> bannerSettings = new Map<String, Support_Banner_Setting__mdt>();
        
        for (Support_Banner_Setting__mdt sbs: [SELECT Id, DeveloperName, Banner_Message__c FROM Support_Banner_Setting__mdt Limit 1]) {
           bannerSettings.put(sbs.DeveloperName, sbs); 
        }
       
        System.debug('apex method. value of bannerSettings: ' + bannerSettings);
        return bannerSettings;
    }     
}