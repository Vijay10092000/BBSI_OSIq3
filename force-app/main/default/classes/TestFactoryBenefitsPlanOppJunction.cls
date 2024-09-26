/**
 * @description TestFactoryBenefitsPlanOppJunction contains methods to create test Benefits_Plan_Opp_Junction__c.
 */
@isTest
public class TestFactoryBenefitsPlanOppJunction {
    /**
	 * @description createBenefitsPlanOppJunction creates BenefitsPlan & Opportunity Junction record in the database.
	 * @param  Opportunity  Opportunity Id
	 * @param  Benefitsplan Benefitsplan Id
	 * @return Benefits_Plan_Opp_Junction__c
	 */
    public static Benefits_Plan_Opp_Junction__c createBenefitsPlanOppJunction( ID Opportunity,ID Benefitsplan){
       Benefits_Plan_Opp_Junction__c benplanopp = makeBenefitsPlanOppJunction(Opportunity,Benefitsplan);
        insert benplanopp;
        return benplanopp;
    }

    /**
	 * @description createBenefitsPlanOppJunction makes BenefitsPlan & Opportunity Junction record in the database.
	 * @param  Opportunity  Opportunity Id
	 * @param  Benefitsplan Benefitsplan Id
	 * @return Benefits_Plan_Opp_Junction__c
	 */
    public static Benefits_Plan_Opp_Junction__c makeBenefitsPlanOppJunction(ID Opportunity,ID Benefitsplan){
        Benefits_Plan_Opp_Junction__c benplanopp = new Benefits_Plan_Opp_Junction__c();
        benplanopp.Opportunity__c = Opportunity;
        benplanopp.Benefits_Plan__c=Benefitsplan;
        return benplanopp;
    }
}