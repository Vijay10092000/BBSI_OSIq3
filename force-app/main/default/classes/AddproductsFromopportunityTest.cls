@isTest
private class AddproductsFromopportunityTest {

    private static final String PRODUCT_NAME_ONE = 'Test Product ONE';
    private static final String PRODUCT_NAME_TWO = 'Test Product TWO';

    private static Account client;
    private static Opportunity opp;
    private static Product2 product1;
    private static Product2 product2;
    private static PriceBookEntry pbe1;
    private static PriceBookEntry pbe2;
    private static Id idPriceBook;
    @TestSetup
	static void makeData() {
		idPriceBook = Test.getStandardPricebookId();
        Pricebook2 standardPricebook = new Pricebook2(Id = idPriceBook, IsActive = true);
        update standardPricebook;

		client = TestFactoryAccount.createClient('TEST CLIENT', null, null);

		Product2 product1 = new Product2(
			Name = PRODUCT_NAME_ONE,
			Description = 'Test Product Entry 1',
			productCode = '302541',
			isActive = true
		);

		Product2 product2 = new Product2(
			Name = PRODUCT_NAME_TWO,
			Description = 'Test Product Entry 2',
			productCode = '302562',
			isActive = true
		);
		insert new List<Product2>{ product1, product2 };

		pbe1 = new PriceBookEntry(
			Product2Id = product1.Id,
			Pricebook2Id = idPriceBook,
			UnitPrice = 247,
			isActive = true
		);

		pbe2 = new PriceBookEntry(
			Product2Id = product2.Id,
			Pricebook2Id = idPriceBook,
			UnitPrice = 123,
			isActive = true
		);
		insert new List<PriceBookEntry>{ pbe1, pbe2 };

		opp = TestFactoryOpportunity.createAdditionalProducts(
			'TEST OPP - CLIENT',
			client.Id,
			System.today(),
			'Product Evaluation'
		);
	}

	static void loadData() {
		client = [SELECT Id, Name FROM Account WHERE Name = 'TEST CLIENT' LIMIT 1];
		opp = [SELECT Id, Name, Products__c, Pricebook2Id, Pricebook2.Name FROM Opportunity WHERE Name = 'TEST OPP - CLIENT' LIMIT 1];

		product1 = [SELECT Id, Name FROM Product2 WHERE Name = :PRODUCT_NAME_ONE LIMIT 1];
		product2 = [SELECT Id, Name FROM Product2 WHERE Name = :PRODUCT_NAME_TWO LIMIT 1];

		pbe1 = [SELECT Id, Pricebook2Id FROM PriceBookEntry WHERE Product2Id = :product1.Id LIMIT 1];
		pbe2 = [SELECT Id, Pricebook2Id FROM PriceBookEntry WHERE Product2Id = :product2.Id LIMIT 1];
		idPricebook = pbe1.Pricebook2Id;
	}

    @isTest
    static void testGetPicklistValues(){
        Test.startTest();
        Map<String, String> picklistValues = AddproductsFromopportunity.getPicklistValues('Product2', 'Family');
        Test.stopTest();
        System.assertNotEquals(null, picklistValues, 'Picklist values map should not be null');
        System.assertNotEquals(0, picklistValues.size(), 'Picklist values map should not be empty');
    }

    @isTest
    static void testCreateOpportunityLineItems() {
        loadData();
        // Create test data
        List<OpportunityLineItem> lineItems = new List<OpportunityLineItem>();
        for (Integer i = 0; i < 5; i++) {
            lineItems.add(TestFactoryOpportunityLineItem.makeOpportunityLineItem(opp.Id, pbe1.id, 2, 100));
        }
        
        // Call the method to test
        Test.startTest();
            lineItems = AddproductsFromopportunity.createOpportunityLineItems(lineItems);
        Test.stopTest();
        
        // Verify that the line items were inserted
        List<OpportunityLineItem> insertedLineItems = [SELECT Id FROM OpportunityLineItem];
        System.assertEquals(5, insertedLineItems.size());

         // Test the fetchOLIData method

        Map<String, Object> result = AddproductsFromopportunity.fetchOLIData(opp.Id);
        System.debug('result' +result);

        opp = [SELECT Id, Name, Products__c, Pricebook2Id, Pricebook2.Name FROM Opportunity WHERE Name = 'TEST OPP - CLIENT' LIMIT 1];

        // Assertions
        System.assertEquals(opp.Pricebook2Id, result.get('priceBookId'));
        System.assertEquals(opp.Pricebook2.Name, result.get('priceBookName'));

        // Additional assertions based on your specific use case
        System.assertEquals(1, ((Map<Id, Product2>) result.get('products')).size()); // Assuming you created 2 products
        System.assertEquals(AddproductsFromopportunity.getUserPermissionSetNames(), result.get('userPermissionSetNames'));
        System.assertEquals(AddproductsFromopportunity.getUserProfileName(), result.get('userProfileName'));
    }
    
    @isTest
    public static void testUpdateOpportunityLineItems() {
        loadData();
        // Create test 
        List<OpportunityLineItem> lineItems = new List<OpportunityLineItem>();
        for (Integer i = 0; i < 5; i++) {
            lineItems.add(TestFactoryOpportunityLineItem.makeOpportunityLineItem(opp.Id, pbe1.id, 2, 100));
        }
        insert lineItems;
        List<OpportunityLineItem> updateItems = new List<OpportunityLineItem>();
        List<OpportunityLineItem> deleteItems = new List<OpportunityLineItem>();
        lineItems[0].TotalPrice = 200;
        updateItems.add(lineItems[0]);
        deleteItems.add(lineItems[1]);
        // Call the method to test
        Test.startTest();
        AddproductsFromopportunity.updateOpportunityLineItems(updateItems, deleteItems);
        Test.stopTest();
        // Verify the results
        List<OpportunityLineItem> updatedItems = [SELECT Id, TotalPrice FROM OpportunityLineItem WHERE OpportunityId = :opp.Id];
        System.assertEquals(200, updatedItems[0].TotalPrice);
    }
    
    @isTest
    static void testFetchProductDataWithOpportunity() {
        // Create test data: Opportunity
        loadData();
        // Call fetchProductData method with opportunityId
        Map<String, Object> result = AddproductsFromopportunity.fetchProductData(opp.Id);
        List<LWC_DataTable_Config__mdt> configs = (List<LWC_DataTable_Config__mdt>)result.get('configs');
        List<Product2> products = (List<Product2>)result.get('products');

        // Assert the changes to the List and Map returned by the method
        System.assertNotEquals(null, configs);
        System.assertNotEquals(null, products);
        Test.startTest();
        opp.Pricebook2Id = idPriceBook;
        update opp;
        result = AddproductsFromopportunity.fetchProductData(opp.Id);
        products = (List<Product2>)result.get('products');
        System.assertNotEquals(null, products);
        Test.StopTest();
    }
}