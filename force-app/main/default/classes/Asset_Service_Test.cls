/**
 * @description Asset_Service_Test contains tests for the Asset_Service class.
 */
@IsTest
@SuppressWarnings('PMD.ApexAssertionsShouldIncludeMessage')
public with sharing class Asset_Service_Test {
	private static final String FAKE_ACCOUNT_ID = '0015600000k8xT7AAI';
	private static final String FAKE_PRODUCT_ID = '01t5600000BlhisLAR';

	@IsTest
	public static void test_method() {
		Date today = Date.today();

		OpportunityLineItem item = new OpportunityLineItem(
			Product2Id = FAKE_PRODUCT_ID,
			UnitPrice = 3.00,
			Quantity = 3
		);

		Test.startTest();

		Asset asset = Asset_Service.createAsset(
			item,
			FAKE_ACCOUNT_ID,
			today,
			'TEST PRODUCT'
		);

		Test.stopTest();

		Assert.areEqual('Purchased', asset.Status);
		Assert.areEqual(FAKE_ACCOUNT_ID, asset.AccountId);
		Assert.areEqual(today, asset.PurchaseDate);
		Assert.areEqual(FAKE_PRODUCT_ID, asset.Product2Id);
		Assert.areEqual('TEST PRODUCT', asset.Name);
		Assert.areEqual(3.00, asset.Price);
		Assert.areEqual(3, asset.Quantity);
	}
}