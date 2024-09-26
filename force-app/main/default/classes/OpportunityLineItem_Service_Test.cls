/**
 * @description OpportunityLineItem_Service_Test contains tests for the OpportunityLineItem_Service class.
 */
@IsTest
@SuppressWarnings('PMD.ApexAssertionsShouldIncludeMessage')
public without sharing class OpportunityLineItem_Service_Test {
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

		client = TestFactoryAccount.createClient('TEST CLIENT', null, null);
		/*
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
		);*/
         Product2 product1 = TestFactoryProduct2.createProduct2(PRODUCT_NAME_ONE,'Test Product Entry 1','302541',true);
         Product2 product2 = TestFactoryProduct2.createProduct2(PRODUCT_NAME_TWO,'Test Product Entry 2','302562',true);
		//insert new List<Product2>{ product1, product2 };
		/*
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
		);*/
        pbe1 = TestFactoryPriceBookEntry.makePricebookentry(product1.Id,idPriceBook,247,true);
        pbe2 = TestFactoryPriceBookEntry.makePricebookentry(product2.Id,idPriceBook,123,true);
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
		opp = [SELECT Id, Name, Products__c FROM Opportunity WHERE Name = 'TEST OPP - CLIENT' LIMIT 1];
		
		product1 = [SELECT Id, Name FROM Product2 WHERE Name = :PRODUCT_NAME_ONE LIMIT 1];
		product2 = [SELECT Id, Name FROM Product2 WHERE Name = :PRODUCT_NAME_TWO LIMIT 1];

		pbe1 = [SELECT Id, Pricebook2Id FROM PriceBookEntry WHERE Product2Id = :product1.Id LIMIT 1];
		pbe2 = [SELECT Id, Pricebook2Id FROM PriceBookEntry WHERE Product2Id = :product2.Id LIMIT 1];
		idPricebook = pbe1.Pricebook2Id;
	}

	@IsTest
	public static void test_LineItem_Add() {
		loadData();

		Assert.areEqual(null, opp.Products__c);

		Test.startTest();
		/*
		OpportunityLineItem lineItem1 = new OpportunityLineItem(
			OpportunityId = opp.Id,
			PricebookEntryId = pbe1.Id,
			Quantity = 1,
			UnitPrice = 1.11
		);
		insert lineItem1;

		OpportunityLineItem lineItem2 = new OpportunityLineItem(
			OpportunityId = opp.Id,
			PricebookEntryId = pbe2.Id,
			Quantity = 2,
			UnitPrice = 2.22
		);
		insert lineItem2;
		*/
		OpportunityLineItem lineItem1 = TestFactoryOpportunityLineItem.createOpportunityLineItem(opp.Id,pbe1.Id,1,1.11);
		OpportunityLineItem lineItem2 = TestFactoryOpportunityLineItem.createOpportunityLineItem(opp.Id,pbe2.Id,2,2.22);
		Test.stopTest();

		opp = [SELECT Id, Name, Products__c FROM Opportunity WHERE AccountId = :client.Id LIMIT 1];

		Assert.areNotEqual(null, opp.Products__c);
		Assert.isTrue(opp.Products__c.contains(PRODUCT_NAME_ONE));
		Assert.isTrue(opp.Products__c.contains(PRODUCT_NAME_TWO));
	}

	@IsTest
	public static void test_LineItem_Remove() {
		loadData();

		Assert.areEqual(null, opp.Products__c);

		/*OpportunityLineItem lineItem1 = new OpportunityLineItem(
			OpportunityId = opp.Id,
			PricebookEntryId = pbe1.Id,
			Quantity = 1,
			UnitPrice = 1.11
		);
		insert lineItem1;

		OpportunityLineItem lineItem2 = new OpportunityLineItem(
			OpportunityId = opp.Id,
			PricebookEntryId = pbe2.Id,
			Quantity = 2,
			UnitPrice = 2.22
		);
		insert lineItem2;*/
		OpportunityLineItem lineItem1 = TestFactoryOpportunityLineItem.createOpportunityLineItem(opp.Id,pbe1.Id,1,1.11);
		OpportunityLineItem lineItem2 = TestFactoryOpportunityLineItem.createOpportunityLineItem(opp.Id,pbe2.Id,2,2.22);
		opp = [SELECT Id, Name, Products__c FROM Opportunity WHERE AccountId = :client.Id LIMIT 1];

		Assert.areNotEqual(null, opp.Products__c);
		Assert.isTrue(opp.Products__c.contains(PRODUCT_NAME_ONE));
		Assert.isTrue(opp.Products__c.contains(PRODUCT_NAME_TWO));

		Test.startTest();

		delete lineItem1;

		opp = [SELECT Id, Name, Products__c FROM Opportunity WHERE AccountId = :client.Id LIMIT 1];

		Assert.areNotEqual(null, opp.Products__c);
		Assert.isFalse(opp.Products__c.contains(PRODUCT_NAME_ONE));
		Assert.isTrue(opp.Products__c.contains(PRODUCT_NAME_TWO));

		delete lineItem2;

		Test.stopTest();

		opp = [SELECT Id, Name, Products__c FROM Opportunity WHERE AccountId = :client.Id LIMIT 1];

		Assert.areEqual(null, opp.Products__c);
	}
}