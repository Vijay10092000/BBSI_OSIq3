@isTest
public class TestFactoryBusinessBlueprint {
    
	/**
	 * @description createBusinessBlueprint creates a Business Blueprint object and inserts it.
	 * @param  name    Business Blueprint Name
	 * @param  account Account related to Business Blueprint
	 * @param  status  Status of Business Blueprint
	 * @param  fldMap  Additional fields to set on Business Blueprint
	 * @return Business_Blueprint__c
	 */
	public static Business_Blueprint__c createBusinessBlueprint(String name, Account account, String status, Map<String,Object> fldMap) {

        Business_Blueprint__c blueprint = makeBusinessBlueprint(name, account, status, fldMap);
        insert blueprint;
        return blueprint;
    }

	/**
	 * @description makeBusinessBlueprint creates a Business Blueprint object.
	 * @param  name    Business Blueprint Name
	 * @param  account Account related to Business Blueprint
	 * @param  status  Status of Business Blueprint
	 * @param  fldMap  Additional fields to set on Business Blueprint
	 * @return Business_Blueprint__c
	 */
    public static Business_Blueprint__c makeBusinessBlueprint(String name, Account account, String status, Map<String,Object> fldMap) {
        Business_Blueprint__c blueprint = new Business_Blueprint__c(
			RecordTypeId = RecordTypeService.getId('Business_Blueprint__c', 'Business_Blueprint'),
			Name = name,
			Client__c = ((account == null) ? null : account.Id),
			Status__c = status
		);

		if (fldMap != null) {
			blueprint = (Business_Blueprint__c) TestFactory.assignFields(fldMap, blueprint);
		}

		return blueprint;
    }
}