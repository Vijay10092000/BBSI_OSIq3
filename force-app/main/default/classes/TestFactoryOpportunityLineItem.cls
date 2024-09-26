@isTest
public class TestFactoryOpportunityLineItem {

 public static OpportunityLineItem createOpportunityLineItem(Id opportunity,Id pricebookentry, decimal quantity,decimal unitprice) {
        OpportunityLineItem oppitem = makeOpportunityLineItem(opportunity, pricebookentry,quantity,unitprice);
        insert oppitem;
        return oppitem;
    }
	public static OpportunityLineItem makeOpportunityLineItem(Id opportunity,Id pricebookentry, decimal quantity,decimal unitprice) {        
        OpportunityLineItem oppitem = new OpportunityLineItem(
		OpportunityId = opportunity,
		PricebookEntryId = pricebookentry,
		Quantity = quantity,
		UnitPrice = unitprice
		);
            
        
        return oppitem;
    }

 
}