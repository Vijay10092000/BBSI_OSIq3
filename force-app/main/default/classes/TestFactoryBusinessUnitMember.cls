@isTest
public class TestFactoryBusinessUnitMember {
    public static Business_Unit_Member__c createBusinessUnitMember(Business_Unit_Contact__c buc, Account a){
        Business_Unit_Member__c bum = makeBusinessUnitMember(buc, a);
        insert bum;
        return bum;
    }
    public static Business_Unit_Member__c makeBusinessUnitMember(Business_Unit_Contact__c buc, Account a){
         Business_Unit_Member__c bum = new Business_Unit_Member__c();

        bum.Business_Unit_Member__c = buc.ID;
        bum.Client__c = a.ID;

        return bum;
    }

}