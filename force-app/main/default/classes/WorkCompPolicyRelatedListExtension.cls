/**
 * @description WorkCompPolicyRelatedListExtension is the controller for the
 * Visualforce page WorkCompPolicyRelatedList.
 */
public without sharing class WorkCompPolicyRelatedListExtension {
	// Account being displayed on the page
	public Account workingAccount;

	/**
	 * @description wcPolicies gets and sets the Policies in this controller
	 */
	public List<Work_Comp_Policy__c> wcPolicies { get; private set; }

	/**
	 * @description wcPolicies gets and sets the Related Policies in this controller
	 */
	public Map<Id, String> relatedPolicies { get; private set; }

	/**
	 * @description WorkCompPolicyRelatedListExtension controller constructor.
	 * @param  controller base controller
	 */
	public WorkCompPolicyRelatedListExtension(ApexPages.StandardController controller) {
		workingAccount = (Account) controller.getRecord();
		relatedPolicies = getRelatedPolicies();
		wcPolicies = getPolicies(relatedPolicies.keySet());
	}

	/**
	 * @description getRelatedPolicies retrieves a map relating Accounts to Work Comp Policies.
	 * @return A map relating Accounts to Work Comp Policies.
	 */
	private Map<Id, String> getRelatedPolicies() {
		Map<Id, String> relatedPolicies = new Map<Id, String>();

		for (WorkCompPolicyAccount__c wcpa : [
			SELECT Work_Comp_Policy__c, Name
			FROM WorkCompPolicyAccount__c
			WHERE Client__c = :workingAccount.Id
		]) {
			relatedPolicies.put(wcpa.Work_Comp_Policy__c, wcpa.Name);
		}

		return relatedPolicies;
	}

	/**
	 * @description getPolicies retrieves the policies based on the related ids.
	 * @param relatedPolicyIds List of policies to get WC Policies for
	 * @return A list of Work Comp Policies.
	 */
	private List<Work_Comp_Policy__c> getPolicies(Set<Id> relatedPolicyIds) {
		return [
			SELECT Name, External_Id__c, Effective_Date__c, Term_Date__c, XMod_Date__c
			FROM Work_Comp_Policy__c
			WHERE Id IN :relatedPolicyIds
			ORDER BY Term_Date__c DESC
		];
	}
}