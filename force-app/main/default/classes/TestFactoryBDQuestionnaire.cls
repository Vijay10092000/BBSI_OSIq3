/**
 * @description TestFactoryBDQuestionnaire contains methods to create test Benefits Discovery Questionnaire.
 */
@IsTest
public without sharing class TestFactoryBDQuestionnaire {
    /**
	 * @description createBDQuestionnaire creates a new Benefits_Discovery_Questionnaire__c record in the database.
	 * @param  OpportunityId     Opportunity Id of the BDQuestionnaire
	 * @param  Commonownership     Common owner ship of the BDQuestionnaire
	 * @param  havbenefits     have benefits of the BDQuestionnaire
	 * @param  Plantype     Plan type of the BDQuestionnaire
	 * @return Benefits_Discovery_Questionnaire__c
	 */
    public static Benefits_Discovery_Questionnaire__c createBDQuestionnaire(String OpportunityId,String Commonownership,String havbenefits,String Plantype){
        Benefits_Discovery_Questionnaire__c bdq = makeBDQuestionnaire(OpportunityId,Commonownership,havbenefits,Plantype);
        insert bdq;
        return bdq;
    }
	/**
	 * @description createBDQuestionnaire creates a new Benefits_Discovery_Questionnaire__c record in the database.
	 * @param  OpportunityId     Opportunity Id of the BDQuestionnaire
	 * @return Benefits_Discovery_Questionnaire__c
	 */
	public static Benefits_Discovery_Questionnaire__c createBDQuestionnaire(String OpportunityId) {
        Benefits_Discovery_Questionnaire__c bdq = makeBDQuestionnaire(OpportunityId);
        insert bdq;
        return bdq;
	}

	/**
	 * @description makeBDQuestionnaire creates a Benefits_Discovery_Questionnaire__c object.
     * @param  OpportunityId     Opportunity Id of the BDQuestionnaire
	 * @return Benefits_Discovery_Questionnaire__c
	 */
	public static Benefits_Discovery_Questionnaire__c makeBDQuestionnaire(String OpportunityId) {
		Benefits_Discovery_Questionnaire__c bdq = new Benefits_Discovery_Questionnaire__c(
            OpportunityId__c = OpportunityId
        );
       return bdq;
	}
    /**
	 * @description makeBDQuestionnaire creates a Benefits_Discovery_Questionnaire__c object.
     * @param  OpportunityId     Opportunity Id of the BDQuestionnaire
	 * @param  Commonownership     Common owner ship of the BDQuestionnaire
	 * @param  havbenefits     have benefits of the BDQuestionnaire
	 * @param  Plantype     Plan type of the BDQuestionnaire
	 * @return Benefits_Discovery_Questionnaire__c
	 */
    public static Benefits_Discovery_Questionnaire__c makeBDQuestionnaire(String OpportunityId, String Commonownership, String havbenefits, String Plantype){
        Benefits_Discovery_Questionnaire__c bdq = new Benefits_Discovery_Questionnaire__c(
            OpportunityId__c = OpportunityId,
            Have_Common_Ownership__c = Commonownership,
            Plan_Types__c = Plantype,
            Have_Benefits__c = havbenefits
        );
       return bdq;
   }   
}