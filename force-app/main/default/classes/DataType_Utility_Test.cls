/**
 * @description DataType_Utility_Test contains tests for DataType_Utility.
 */
@IsTest
@SuppressWarnings('PMD.ApexAssertionsShouldIncludeMessage, PMD.AvoidHardcodingId')
public without sharing class DataType_Utility_Test {
	@IsTest
    static void test_onNull() {
		Assert.areEqual('Test', DataType_Utility.onNull(null, 'Test'));
		Assert.areEqual('Test', DataType_Utility.onNull('Test', 'Other'));

		Assert.areEqual(0.0, DataType_Utility.onNull((Decimal) null, (Decimal) 0.0));
		Assert.areEqual(0.0, DataType_Utility.onNull((Decimal) 0.0, (Decimal) 100.0));

		Assert.areEqual(0.0, DataType_Utility.onNull((Double) null, (Double) 0.0));
		Assert.areEqual(0.0, DataType_Utility.onNull((Double) 0.0, (Double) 100.0));

		Assert.areEqual(0, DataType_Utility.onNull((Long) null, (Long) 0));
		Assert.areEqual(0, DataType_Utility.onNull((Long) 0, (Long) 100));

		Assert.areEqual(0, DataType_Utility.onNull((Integer) null, (Integer) 0));
		Assert.areEqual(0, DataType_Utility.onNull((Integer) 0, (Integer) 100));

		Assert.areEqual(true, DataType_Utility.onNull((Boolean) null, true));
		Assert.areEqual(true, DataType_Utility.onNull(true, false));

		Date today = Date.today();
		Assert.areEqual(today, DataType_Utility.onNull((Date) null, today));
		Assert.areEqual(today, DataType_Utility.onNull(today, null));

		DateTime now = DateTime.now();
		Assert.areEqual(now, DataType_Utility.onNull((DateTime) null, now));
		Assert.areEqual(now, DataType_Utility.onNull(now, null));

		Time test = Time.newInstance(1, 1, 1, 1);
		Assert.areEqual(test, DataType_Utility.onNull((Time) null, test));
		Assert.areEqual(test, DataType_Utility.onNull(test, null));

		Account acc = new Account();
		Assert.areEqual(acc, DataType_Utility.onNull((Time) null, acc));
		Assert.areEqual(acc, DataType_Utility.onNull(acc, null));

		Id idFake = Id.valueOf('00Q500000148cYGEAY');
		Assert.areEqual(idFake, DataType_Utility.onNull((Id) null, idFake));
		Assert.areEqual(idFake, DataType_Utility.onNull(idFake, null));

		Blob testBlob = Blob.valueOf('TEST');
		Assert.areEqual(testBlob, DataType_Utility.onNull((Id) null, testBlob));
		Assert.areEqual(testBlob, DataType_Utility.onNull(testBlob, null));
	}
}