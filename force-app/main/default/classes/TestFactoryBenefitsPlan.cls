/**
 * @description TestFactoryBenefitsPlan contains methods to create test BenefitsPlan.
 */
@isTest
public class TestFactoryBenefitsPlan {
    /**
	 * @description createUser creates a BenefitsPlan in the database.
	 * @param  Name    Name For BenefitsPlan    
	 * @param  Product  Product
	 * @param  PlanName  PlanName
	 * @return Benefits_Plan__c
	 */
     public static Benefits_Plan__c createBenefitsPlan( String Name,String Product,String PlanName){
        Benefits_Plan__c benplan = makeBenefitsPlan(Name,Product,PlanName);
        insert benplan;
        return benplan;
    }

    /**
	 * @description makeBenefitsPlan makes a BenefitsPlan in the database.
	 * @param  Name    Name For BenefitsPlan    
	 * @param  Product  Product
	 * @param  PlanName  PlanName
	 * @return Benefits_Plan__c
	 */
    public static Benefits_Plan__c makeBenefitsPlan(String Name,String Product,String PlanName){
         Benefits_Plan__c benplan = new Benefits_Plan__c();
        benplan.Name = Name;
        benplan.Product__c=Product;
        benplan.Plan_Name__c=PlanName;
        return benplan;
    }

}