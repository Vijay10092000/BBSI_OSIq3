/**
 * @description Asset_Service methods to aid handling Assets.
 */
public without sharing class Asset_Service {
	/**
	 * @description createAsset creates an Asset object.
	 * @param  item         OpportunityLineItem changing to Asset
	 * @param  idAccount    Account identifier
	 * @param  dateClosed   Date Opportunity was Closed Won
	 * @param  nameProduct  Product name
	 * @return Asset
	 */
	public static Asset createAsset(
		OpportunityLineItem item,
		Id idAccount,
		Date dateClosed,
		String nameProduct
	) {
		return new Asset(
			Status = 'Purchased',
			AccountId = idAccount,
			PurchaseDate = dateClosed,
			Product2Id = item.Product2Id,
			Name = nameProduct,
			Price = item.UnitPrice,
			Quantity = item.Quantity
		);
	}
}