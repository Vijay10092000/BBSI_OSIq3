@isTest
public class TestFactoryPriceBookEntry {
	public static PricebookEntry createPricebookentry(Id Product2Id, Id Pricebook2Id,Decimal unitprice,Boolean active) {
        PricebookEntry testpricebook = makePricebookentry(Product2Id, Pricebook2Id,unitprice,active);
        insert testpricebook;
        return testpricebook;
    }
	public static PricebookEntry makePricebookentry(Id Product2Id, Id Pricebook2Id,Decimal unitprice,Boolean active) {        
        PricebookEntry testpricebook = new PricebookEntry(
		Product2Id = Product2Id,
		Pricebook2Id = Pricebook2Id,
		UnitPrice = unitprice,
		IsActive = active
		);
            
        
        return testpricebook;
    }

}