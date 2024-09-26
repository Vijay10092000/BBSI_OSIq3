/**
 * @description XmodRecommendedController handles server-side calls from the XmodRecommended component
 * Created by CElim on 2/21/2019.
 */
public with sharing class XmodRecommendedController {
	@AuraEnabled
	public static List<WorkCompPolicyAccount__c> getWorkCompPolicies(List<String> policies) {
		return [
			SELECT Client__r.External_Id__c, Work_Comp_Policy__c, Client__c, Work_Comp_Policy__r.External_Id__c
			FROM WorkCompPolicyAccount__c
			WHERE Work_Comp_Policy__r.External_Id__c IN :policies
			ORDER BY Work_Comp_Policy__r.External_Id__c
		];
	}

	@AuraEnabled
	public static Map<String, List<WorkCompPolicyAccount__c>> getWorkCompMap(List<XmodRecommended__c> records) {
		List<String> policies = new List<String>();

		for (XmodRecommended__c x : records) {
			policies.add(x.Policy_Number__c);
		}
		policies.add('');

		List<WorkCompPolicyAccount__c> wcs = getWorkCompPolicies(policies);

		Map<String, List<WorkCompPolicyAccount__c>> wcMap = new Map<String, List<WorkCompPolicyAccount__c>>();
		for (WorkCompPolicyAccount__c wc : wcs) {
			String key = wc.Work_Comp_Policy__r.External_Id__c;

			if (!wcMap.containsKey(key)) {
				wcMap.put(key, new List<WorkCompPolicyAccount__c>());
			}

			wcMap.get(key).add(wc);
		}

		return wcMap;
	}

	@AuraEnabled
	public static List<XmodRecommended__c> getXmodRecommended() {
		return [
			SELECT
				Id, Name, Client__c, Client__r.External_Id__c, Client_Info__c, Effective_Date__c, Notes__c,
				Policy_Number__c, State_Code__c, Work_Comp_Policy__c, Xmod__c, Work_Comp_Policy__r.Id
			FROM XmodRecommended__c
			ORDER BY Client__r.External_Id__c DESC
		];
	}

	@AuraEnabled
	public static Map<String, XmodRecommended__c> getXmodRecommendedMap() {
		Map<String, XmodRecommended__c> xmodMap = new Map<String, XmodRecommended__c>();

		for (XmodRecommended__c x : getXmodRecommended()) {
			xmodMap.put(x.Client__r.External_Id__c + '-' + x.State_Code__c, x);
		}

		return xmodMap;
	}

	/**
	 * @description saveXmodRecommended make changes or new XmodRecommended__c records based on the given ones.
	 * @param  records  XmodRecommended__c records to update or create
	 * @return List<String> of failed records
	 */
	@AuraEnabled
	public static List<String> saveXmodRecommended(List<XmodRecommended__c> records) {
		return XmodRecommendedWriter.perform(
			records,
			getXmodRecommendedMap(),
			getWorkCompMap(records)
		);
	}

	@AuraEnabled
	public static List<WorkCompPolicyDisplayName__c> getWorkCompPolicyDisplayNameMappings() {
		return WorkCompController.getWorkCompPolicyDisplayNameMappings();
	}

	@AuraEnabled
	public static void addWorkCompPolicyDisplayNameMappings(List<WorkCompPolicyDisplayName__c> policies) {
		WorkCompController.addWorkCompPolicyDisplayNameMappings(policies);
	}

	@AuraEnabled
	public static void saveWorkCompPolicyDisplayNameMappings(List<WorkCompPolicyDisplayName__c> policies) {
		WorkCompController.saveWorkCompPolicyDisplayNameMappings(policies);
	}
}