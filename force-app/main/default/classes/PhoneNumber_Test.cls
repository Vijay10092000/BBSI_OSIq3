/**
 * @description PhoneNumber_Test contains tests for the PhoneNumber class.
 */
@SuppressWarnings('PMD.ApexAssertionsShouldIncludeMessage')
@IsTest
public without sharing class PhoneNumber_Test {
	@IsTest
	static void isValid() {
		Assert.isTrue(PhoneNumber.isValid('360-789-0000', false));
		Assert.isTrue(PhoneNumber.isValid('1360.789.0001 ABC', false));
		Assert.isTrue(PhoneNumber.isValid('360-789-0000 ext.89', true));
		Assert.isTrue(PhoneNumber.isValid('360-789-0000', true));
		Assert.isTrue(PhoneNumber.isValid('360-789-0000 ABC', true));

		Assert.isTrue(PhoneNumber.isValid('360/789/0000 ABC', true));
		Assert.isTrue(PhoneNumber.isValid('360.789.0000 ABC', true));
		Assert.isTrue(PhoneNumber.isValid('360-789-0000ABC', true));

		Assert.isFalse(PhoneNumber.isValid(null, false));
		Assert.isFalse(PhoneNumber.isValid('', false));
		Assert.isFalse(PhoneNumber.isValid('1 360.789.000 ABC', false));
	}

	@IsTest
	static void fixPhoneNumber() {
		Assert.areEqual(
			'360-789-0000 ext 89',
			PhoneNumber.fixPhoneNumber('1360./789/0000 ext.89'),
			'Fix periods and slashes'
		);
		Assert.areEqual('360-789-0000', PhoneNumber.fixPhoneNumber('1.360.789.0000'), 'Fix periods');
		Assert.areEqual('360-789-0000 ex 801', PhoneNumber.fixPhoneNumber('1 360/789/0000 ex 801'), 'Fix slashes');

		try {
			PhoneNumber.fixPhoneNumber('360./789/09');
			Assert.fail('Exception should have been thrown - Invalid Phone number');
		} catch (Exception e) {
			Assert.isTrue(true, 'Exception thrown');
		}

		try {
			String phone = PhoneNumber.fixPhoneNumber('360./789/09', true, true);
			Assert.areEqual('360./789/09', phone, 'Value should not change');
		} catch (Exception e) {
			Assert.fail('Exception should NOT have been throw');
		}
	}

	@IsTest
	static void forcePhoneNumber() {
		Assert.areEqual(
			'360-789-0000 ext 89',
			PhoneNumber.forcePhoneNumber('1360./789/0000 ext.89', true),
			'Fix periods and slashes'
		);
		Assert.areEqual(
			'360-789-0000 ex 801',
			PhoneNumber.forcePhoneNumber('1 360/789/0000 ex 801', true),
			'Fix slashes'
		);
		Assert.areEqual('360-789-0000', PhoneNumber.forcePhoneNumber('1.360.789.0000 ext.89', false), 'Fix periods');
		Assert.areEqual(
			'360-789-0000 ex 801',
			PhoneNumber.forcePhoneNumber('1 360/789/0000 ex 801', true),
			'Fix slashes'
		);

		Assert.isNull(PhoneNumber.forcePhoneNumber('360./789/09', false), 'Invalid Phone number');
	}

	@IsTest
	static void test_formatUS_success() {
		String result;

		result = PhoneNumber.formatUS('999 555 1234', '.', true);
		Assert.areEqual('999.555.1234', result, 'Produced wrong format');

		result = PhoneNumber.formatUS('999.555.1234x123', '-', true);
		Assert.areEqual('999-555-1234 x123', result, 'Produced wrong format');

		result = PhoneNumber.formatUS('(999)555-1234 ex4', '--', true);
		Assert.areEqual('999--555--1234 ex4', result, 'Produced wrong format');

		result = PhoneNumber.formatUS('9995551234 ', ' ', true);
		Assert.areEqual('999 555 1234', result, 'Produced wrong format');

		result = PhoneNumber.formatUS('99955512347890', '-', true);
		Assert.areEqual('999-555-1234 7890', result, 'Produced wrong format');

		result = PhoneNumber.formatUS('1 999/555/1234  123', '.', true);
		Assert.areEqual('999.555.1234 123', result, 'Produced wrong format');

		result = PhoneNumber.formatUS('1 (999)-555-1234  +987  ', ',', true);
		Assert.areEqual('999,555,1234 +987', result, 'Produced wrong format');

		result = PhoneNumber.formatUS('011 49 7612 87330', '/', true);
		Assert.areEqual('011 49 7612 87330', result, 'Leading 0 (international) numbers should not change');
	}

	@IsTest
	static void test_formatUS_failure() {
		try {
			PhoneNumber.formatUS(null, '-', true);
			Assert.fail('Should have thrown Exception - null String');
		} catch (Exception e) {
			Assert.isTrue(true, 'Exception thrown');
		}

		try {
			PhoneNumber.formatUS('', '-', true);
			Assert.fail('Should have thrown Exception - no digits');
		} catch (Exception e) {
			Assert.isTrue(true, 'Exception thrown');
		}

		try {
			PhoneNumber.formatUS('999.555.123', '-', true);
			Assert.fail('Should have thrown Exception - not enough digits');
		} catch (Exception e) {
			Assert.isTrue(true, 'Exception thrown');
		}

		try {
			PhoneNumber.formatUS('1999555123', '-', true);
			Assert.fail('Should have thrown Exception - not enough digits after removing the leading 1');
		} catch (Exception e) {
			Assert.isTrue(true, 'Exception thrown');
		}

		try {
			PhoneNumber.formatUS('555.1234', '-', true);
			Assert.fail('Should have thrown Exception - not enough digits');
		} catch (Exception e) {
			Assert.isTrue(true, 'Exception thrown');
		}

		try {
			PhoneNumber.formatUS('555.1234 ext400', '-', true);
			Assert.fail('Should have thrown Exception - not enough digits before first alpha');
		} catch (Exception e) {
			Assert.isTrue(true, 'Exception thrown');
		}

		try {
			PhoneNumber.formatUS('1366A8989222', '-', true);
			Assert.fail('Should have thrown Exception - Invalid Phone number.');
		} catch (Exception e) {
			Assert.isTrue(true, 'Exception thrown');
		}

		try {
			PhoneNumber.formatUS(null, '-', true);
			Assert.fail('Should have thrown Exception - Invalid Phone number. It is blank or null.');
		} catch (Exception e) {
			Assert.isTrue(true, 'Exception thrown');
		}
	}
}