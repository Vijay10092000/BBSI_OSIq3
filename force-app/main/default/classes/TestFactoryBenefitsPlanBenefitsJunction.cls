/**
 * @description TestFactoryBenefitsPlanBenefitsJunction contains methods to create test Benefits_Plan_Benefits_Junction__c.
 */
@isTest
public class TestFactoryBenefitsPlanBenefitsJunction {
	/**
	 * @description createBenefitsPlanBenJunction create a BenefitsPlan & Benefits Junction record in the database.
	 * @param  Benefits    Benefits Id    
	 * @param  Benefitsplan  Benefitsplan Id
	 * @return Benefits_Plan_Benefits_Junction__c
	 */
    public static Benefits_Plan_Benefits_Junction__c createBenefitsPlanBenJunction( ID Benefits,ID Benefitsplan){
       Benefits_Plan_Benefits_Junction__c benplanben = makeBenefitsPlanBenJunction(Benefits,Benefitsplan);
        insert benplanben;
        return benplanben;
    }

    /**
	 * @description createBenefitsPlanBenJunction makes a BenefitsPlan & Benefits Junction record in the database.
	 * @param  Benefits    Benefits Id    
	 * @param  Benefitsplan  Benefitsplan Id
	 * @return Benefits_Plan_Benefits_Junction__c
	 */
    public static Benefits_Plan_Benefits_Junction__c makeBenefitsPlanBenJunction(ID Benefits,ID Benefitsplan){
         Benefits_Plan_Benefits_Junction__c benplanben = new Benefits_Plan_Benefits_Junction__c();

        benplanben.Benefits__c = Benefits;
        benplanben.Benefits_Plan__c=Benefitsplan;
        
        

        return benplanben;
    }

}