@IsTest
public class TestFactoryBusinessUnitContact {

    public static Business_Unit_Contact__c createBusinessUnitContact(Business_Unit__c bu, boolean active, String role, Contact contactRec) {
		Business_Unit_Contact__c buc = makeBusinessUnitContact(bu, active, role, contactRec);
        insert buc;
        return buc;
    }

    public static Business_Unit_Contact__c createBusinessUnitContact(Business_Unit__c bu, Boolean active, String role) {
		Business_Unit_Contact__c buc = makeBusinessUnitContact(bu, active, role, null);
        insert buc;
        return buc;
    }
    
    public static Business_Unit_Contact__c makeBusinessUnitContact(Business_Unit__c bu, Boolean active, String role, Contact contactRec) {
        Business_Unit_Contact__c buc = new Business_Unit_Contact__c();

        buc.Active__c = active;
        buc.Role__c = role;
        buc.Business_Unit__c = bu.ID;
        if (contactRec != null) buc.BU_Member__c = contactRec.ID;
        if (active) {
            buc.Active_Date__c = System.Today();
        }
        else {
            buc.Inactive_Date__c = System.Today();
        }

        return buc;
    }

}