/**
* @description TestFactoryRenewal_Link contains methods to create test Renewal Link .
*/
@isTest
public class TestFactoryRenewal_Link {
    /**
    * @description createRenewalLink creates a new Renewal Link record in the database.
    * @param  Fein          Fein of the Renewal Link
    * @param  description   description for the Renewal Link
    * @return Renewal_Link__c
    */
    
    public static Renewal_Link__c createRenewalLink(String Fein,String description) {
        Renewal_Link__c renlink = makeRenewalLink(Fein, description);
        insert renlink;
        return renlink;        
    }
    /**
    * @description makeRenewalLink creates a new Renewal Link record in the database.
    * @param  Fein          Fein of the Renewal Link
    * @param  description   description for the Renewal Link
    * @return Renewal_Link__c
    */
    public static Renewal_Link__c makeRenewalLink(String Fein,String description) {
        Renewal_Link__c renlink = new Renewal_Link__c();
        renlink.FEIN__c = Fein;
        renlink.Description__c = description;        
        return renlink;
    }
}