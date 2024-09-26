/**
 * @description OpportunityProducts_TestEnv builds data for testing Opportunit';'s
 * Addtional Products.
 */
@IsTest
public with sharing class OpportunityProducts_TestEnv {
	public static final String PRODUCT_NAME_ONE = 'Test Product ONE';
	public static final String PRODUCT_NAME_TWO = 'Test Product TWO';

	public static User userTest;
	public Contact contactUser;
	public Contact contactClient;
	public Account branch;
	public Account client;
	public Opportunity opp;
	public Product2 productBbsiU;
	public Product2 productLms;
	public Product2 productTimeCo;
	public Product2 productTimeClockPlus;
	public Product2 productTimenet;
	public PriceBookEntry pbeBbsiU;
	public PriceBookEntry pbeLms;
	public PriceBookEntry pbeTimeCo;
	public PriceBookEntry pbeTimeClockPlus;
	public PriceBookEntry pbeTimenet;

	public Map<Id, Account> relatedAccounts;
	public Map<Id, Contact> relatedContacts;
	public Map<Id, List<OpportunityLineItem>> relatedLineItems;
	public Map<Id, List<Id>> relatedFileIds;
	public List<OpportunityContactRole> relatedContactRoles;

	/**
	 * @description create creates the test data.
	 */
	public void create() {
		Id idPriceBook = Test.getStandardPricebookId();

		branch = TestFactoryAccount.createBranch('TEST BRANCH', '9000', null, null);

		userTest = TestFactoryUser.createUser('TEST', 'USER', 'BBSI Standard', '9000');

		client = TestFactoryAccount.makeClient('TEST CLIENT A', null, null);
		client.Prospect_Branch__c = branch.Id;
		client.External_Id__c = 'AAAAAA';
		client.OwnerId = userTest.Id;

		contactUser = TestFactoryContact.makeEmployee(userTest.Id, 'TEST', 'USER', null);
		contactClient = TestFactoryContact.makeClient('TEST', 'CLIENT', client.Id);
		insert new List<Contact>{ contactUser, contactClient };

		insert new List<Account>{ client };

		opp = TestFactoryOpportunity.createAdditionalProducts(
			'TEST OPP - CLIENT',
			client.Id,
			System.today(),
			'Product Evaluation'
		);
		opp.BBSIU_for_Clients_Request_Demo_Access__c = true;


		OpportunityContactRole ocr = new OpportunityContactRole(
			ContactId = contactClient.Id,
			OpportunityId = opp.Id,
			Role = 'BBSIU Contact'
		);
		insert ocr;

		Product2 productBbsiU = new Product2(
			Name = PRODUCT_NAME_ONE,
			Family = OpportunityProductCases.FAMILY_TYPE_BBSIU,
			Description = 'Test Product BBSIU',
			productCode = '302541',
			isActive = true
		);

		Product2 productLms = new Product2(
			Name = PRODUCT_NAME_TWO,
			Family = OpportunityProductCases.FAMILY_TYPE_LMS,
			Description = 'Test Product LMS',
			productCode = '302562',
			isActive = true
		);

		Product2 productTimeCo = new Product2(
			Name = PRODUCT_NAME_TWO,
			Family = OpportunityProductCases.FAMILY_TYPE_TIMECO,
			Description = 'Test Product TIMECO',
			productCode = '302563',
			isActive = true
		);

		Product2 productTimeClockPlus = new Product2(
			Name = PRODUCT_NAME_TWO,
			Family = OpportunityProductCases.FAMILY_TYPE_TIMECLOCKPLUS,
			Description = 'Test Product TIMECO',
			productCode = '302564',
			isActive = true
		);

		Product2 productTimenet = new Product2(
			Name = PRODUCT_NAME_TWO,
			Family = OpportunityProductCases.FAMILY_TYPE_TIMENET,
			Description = 'Test Product TIMECO',
			productCode = '302564',
			isActive = true
		);
		insert new List<Product2>{ productBbsiU, productLms, productTimeCo, productTimeClockPlus, productTimenet};

		pbeBbsiU = new PriceBookEntry(
			Product2Id = productBbsiU.Id,
			Pricebook2Id = idPriceBook,
			UnitPrice = 111,
			isActive = true
		);

		pbeLms = new PriceBookEntry(
			Product2Id = productLms.Id,
			Pricebook2Id = idPriceBook,
			UnitPrice = 222,
			isActive = true
		);

		pbeTimeCo = new PriceBookEntry(
			Product2Id = productTimeCo.Id,
			Pricebook2Id = idPriceBook,
			UnitPrice = 123,
			isActive = true
		);

		pbeTimeClockPlus = new PriceBookEntry(
			Product2Id = productTimeClockPlus.Id,
			Pricebook2Id = idPriceBook,
			UnitPrice = 123,
			isActive = true
		);

		pbeTimenet = new PriceBookEntry(
			Product2Id = productTimenet.Id,
			Pricebook2Id = idPriceBook,
			UnitPrice = 123,
			isActive = true
		);

		insert new List<PriceBookEntry>{ pbeBbsiU, pbeLms, pbeTimeCo, pbeTimeClockPlus,  pbeTimenet};

		OpportunityLineItem lineItem1 = new OpportunityLineItem(
			OpportunityId = opp.Id,
			PricebookEntryId = pbeBbsiU.Id,
			Quantity = 1,
			UnitPrice = 111.00
		);

		OpportunityLineItem lineItem2 = new OpportunityLineItem(
			OpportunityId = opp.Id,
			PricebookEntryId = pbeLms.Id,
			Quantity = 1,
			UnitPrice = 222.00
		);

		OpportunityLineItem lineItem3 = new OpportunityLineItem(
			OpportunityId = opp.Id,
			PricebookEntryId = pbeTimeCo.Id,
			Quantity = 1,
			UnitPrice = 123.00
		);

		OpportunityLineItem lineItem4 = new OpportunityLineItem(
			OpportunityId = opp.Id,
			PricebookEntryId = pbeTimeClockPlus.Id,
			Quantity = 1,
			UnitPrice = 123.00
		);

		OpportunityLineItem lineItem5 = new OpportunityLineItem(
			OpportunityId = opp.Id,
			PricebookEntryId = pbeTimenet.Id,
			Quantity = 1,
			UnitPrice = 123.00
		);
		insert new List<OpportunityLineItem>{ lineItem1, lineItem2, lineItem3, lineItem4, lineItem5 };
	}

	/**
	 * @description load loads the created test data.
	 */
	public void load() {
		client = [
			SELECT Id, Name, OwnerId, External_Id__c, Prospect_Branch__r.Name
			FROM Account
			WHERE Name = 'TEST CLIENT A'
			LIMIT 1
		];
		userTest = [SELECT Id, Name FROM User WHERE Name = 'TEST USER' LIMIT 1];
		contactUser = [SELECT Id, Name FROM Contact WHERE Name = 'TEST USER' LIMIT 1];
		contactClient = [SELECT Id, Name FROM Contact WHERE Name = 'TEST CLIENT' LIMIT 1];
		opp = [
			SELECT Id, Name, AccountId, RecordTypeId, CloseDate, IsClosed,
				BBSIU_for_Clients_Request_Demo_Access__c, TIMECO_Setup_Fee_Waived__c,
				TIMENET_Setup_Fee_Waived__c, TIMECLOCKPLUS_Setup_Fee_Waived__c, 
				Billing_Frequency__c, Number_of_Subscribers__c, HR_Seats__c,
				Risk_Seats__c, Leadership_Seats__c,  Pro_Skills_Seats__c, Total_BBSIU_Seats__c,
				Notes_Additional_Products__c
			FROM Opportunity
			WHERE Name = 'TEST OPP - CLIENT'
			LIMIT 1
		];

		relatedAccounts = new Map<Id, Account>();
		relatedAccounts.put(client.Id, client);

		relatedContacts = new Map<Id, Contact>();
		relatedContacts.put(client.Id, contactUser);

		relatedLineItems = new Map<Id, List<OpportunityLineItem>>();
		List<OpportunityLineItem> items = [
			SELECT Id, Name, Quantity, UnitPrice, OpportunityId, Product2Id, Product2.Family, Product2.Name
			FROM OpportunityLineItem
			WHERE OpportunityId = :opp.Id
		];
		relatedLineItems.put(opp.Id, items);

		relatedFileIds = new Map<Id, List<Id>>();

		relatedContactRoles = [
			SELECT Id, ContactId, OpportunityId, IsPrimary, Role
			FROM OpportunityContactRole
			WHERE OpportunityId = :opp.Id
		];
	}
}