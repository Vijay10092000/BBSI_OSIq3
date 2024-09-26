/**
 * @description TestFactoryUser contains methods to create test BusinessUnits (Business_Unit__c).
 */
@IsTest
public class TestFactoryBusinessUnit {

    /**
	 * @description createBusinessUnit creates a BusinessUnit in the database.
	 * @param  name    Business Unit Name
	 * @param  brachId     Account Id related to Business Unit
	 * @return Business_Unit__c
	 */
	public static Business_Unit__c createBusinessUnit(String name, String brachId) {
		Business_Unit__c bu = makeBusinessUnit(name, brachId);
		insert bu;
		return bu;
	}
    
    /**
	 * @description createBusinessUnit creates a BusinessUnit object.
	 * @param  name    Business Unit Name
	 * @param  brachId     Account Id related to Business Unit
	 * @return Business_Unit__c
	 */
    public static Business_Unit__c makeBusinessUnit(String name, String brachId) {
        Business_Unit__c bu =  new Business_Unit__c();
        bu.name = name;
        bu.BBSI_Branch__c = brachId;
        return bu;
    }

    /**
	 * @description createBusinessUnit creates a BusinessUnit in the database.
	 * @param  name    Business Unit Name
	 * @param  a     Account related to Business Unit
	 * @return Business_Unit__c
	 */
	public static Business_Unit__c createBusinessUnit(String name, Account a) {
		Business_Unit__c bu = makeBusinessUnit(name, a);
		insert bu;
		return bu;
	}
    
    /**
	 * @description createBusinessUnit creates a BusinessUnit object.
	 * @param  name    Business Unit Name
	 * @param  a     Account related to Business Unit
	 * @return Business_Unit__c
	 */
    public static Business_Unit__c makeBusinessUnit(String name, Account a) {
        Business_Unit__c bu =  new Business_Unit__c();

        bu.name = name;
        bu.BBSI_Branch__c = a.id;

        return bu;
    }

    /**
	 * @description createBusinessUnit creates a BusinessUnit in the database.
	 * @param  name    Business Unit Name
	 * @return Business_Unit__c
	 */
	public static Business_Unit__c createBusinessUnit(String name) {
		Business_Unit__c bu = makeBusinessUnit(name);
		insert bu;
		return bu;
	}
    
    /**
	 * @description createBusinessUnit creates a BusinessUnit object.
	 * @param  name    Business Unit Name
	 * @return Business_Unit__c
	 */
    public static Business_Unit__c makeBusinessUnit(String name) {
        Business_Unit__c bu =  new Business_Unit__c();
        bu.name = name;
        return bu;
    }
}