/**
 * @description TestFactoryProducerBusinessBlueprint contains methods to create test ProducerBusinessBlueprint (Producer_Business_Blueprint__c).
 */
@IsTest
public class TestFactoryProducerBusinessBlueprint {

    
    /**
	 * @description makeProducerBusinessBlueprint creates a Producer_Business_Blueprint__c object without saving.
	 * @param  name         Producer_Business_Blueprint Name
	 * @param  contact      Producer Contact for Producer_Business_Blueprint
	 * @param  businessUnit Business Unit for Producer_Business_Blueprint
	 * @return Producer_Business_Blueprint__c
	 */
    public static Producer_Business_Blueprint__c makeProducerBusinessBlueprint
        	(String name, Contact contact, Business_Unit__c businessUnit, Map<String, Object> fldMap) {
        
        Producer_Business_Blueprint__c b = new Producer_Business_Blueprint__c();

        b.name = name;
        b.Producer__c = contact.iD;
		b.Business_Unit__c = businessUnit.Id;
        
        if (fldMap != null) {
			b = (Producer_Business_Blueprint__c) TestFactory.assignFields(fldMap, b);
		}
        
        return b;
    }
    
    /**
	 * @description createProducerBusinessBlueprint creates a Producer_Business_Blueprint__c in the database.
	 * @param  name         Producer_Business_Blueprint Name
	 * @param  contact      Producer Contact for Producer_Business_Blueprint
	 * @param  businessUnit Business Unit for Producer_Business_Blueprint
	 * @return Producer_Business_Blueprint__c
	 */
    public static Producer_Business_Blueprint__c createProducerBusinessBlueprint
        	(String name, Contact contact, Business_Unit__c businessUnit, Map<String, Object> fldMap) {
                
        Producer_Business_Blueprint__c b = makeProducerBusinessBlueprint(name, contact, businessUnit, fldMap);
        insert b;
        return b;
    }
}