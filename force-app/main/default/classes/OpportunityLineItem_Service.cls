/**
 * @description OpportunityLineItem_Service contains methods to aid in handling OpportunityLineItem records.
 */
public with sharing class OpportunityLineItem_Service {
	/**
	 * @description updateOpportunityProducts updates the products field on the related
	 * Opportunities.
	 * @param lineItems  OpportunityLineItems changed
	 */
	public static void updateOpportunityProducts(List<OpportunityLineItem> lineItems) {
		Set<Id> idOpps = new Set<Id>();
		Map<Id, String> newProducts = new Map<Id, String>();
		Map<Id, Set<String>> newProductFamilies = new Map<Id, Set<String>>();

		for (OpportunityLineItem lineItem : lineItems) {
			idOpps.add(lineItem.OpportunityId);
			newProducts.put(lineItem.OpportunityId, '');
			newProductFamilies.put(lineItem.OpportunityId, new Set<String>());
		}

		Map<Id, Opportunity> opps = new Map<Id, Opportunity>(
			[
				SELECT Id, Name, Products__c, Product_Family__c 
				FROM Opportunity
				WHERE Id IN :idOpps
			]
		);

		for (Opportunity opp : opps.values()) {
			opp.Products__c = '';
			opp.Product_Family__c = '';
		}

		List<OpportunityLineItem> allItems = [
			SELECT Id, Name, Quantity, UnitPrice, OpportunityId, Product2Id, Product2.Family, Product2.Name
			FROM OpportunityLineItem
			WHERE OpportunityId IN :idOpps
			ORDER BY Name ASC
		];

		String text;
		Set<String> ProductFamilies = new Set<String>();
		for (OpportunityLineItem lineItem : allItems) {
			text = newProducts.get(lineItem.OpportunityId);
			ProductFamilies = newProductFamilies.get(lineItem.OpportunityId);
			if (!String.isBlank(text)) {
				text += ', ';
			}

			text += lineItem.Product2.Name;
			ProductFamilies.add(lineItem.Product2.Family);
			newProducts.put(lineItem.OpportunityId, text);
			newProductFamilies.put(lineItem.OpportunityId, ProductFamilies);
		}

		for (Id id : newProducts.keySet()) {
			Opportunity opp = opps.get(id);
			opp.Products__c = newProducts.get(id).left(255);
			opp.Product_Family__c = String.join(new List<String>(newProductFamilies.get(id)), ', ').left(255);
		}

		update opps.values();
	}
}