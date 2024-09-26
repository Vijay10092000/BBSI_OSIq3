@isTest
public class String_Services_Test {
	static testMethod void test_getDefaultValue() {
		String testDefaultString;
		String testOtherString = 'Other string';

		Test.startTest();

		String testReturnString1 = String_Services.getDefaultValue(testDefaultString, testOtherString);

		testDefaultString = 'Default String';
		String testReturnString2 = String_Services.getDefaultValue(testDefaultString, testOtherString);

		Test.stopTest();

		System.assertEquals(testOtherString, testReturnString1);
		System.assertEquals(testDefaultString, testReturnString2);
	}

	@SuppressWarnings('PMD.EmptyCatchBlock')
	static testMethod void test_replaceRepeat() {
		System.assertEquals('ABCDEFG', String_Services.replaceRepeat('A B C D   E F   G', ' ', ''));
		System.assertEquals('%  %%  %%  %% ', String_Services.replaceRepeat('%    %  %    %  %    %  % ', ' %', '%', 2));
		System.assertEquals('%%%%%%  %', String_Services.replaceRepeat('%  %  %  %  %  %     % ', '% ', '%', 3));
		System.assertEquals('%%% %', String_Services.replaceRepeat('%% %%   %% ', ' %% ', '%', 10));
		System.assertEquals('', String_Services.replaceRepeat('', ' %% ', '%', 10));

		try {
			String_Services.replaceRepeat('%% %%  %% ', ' %% ', '%', 0);
			System.assert(false, 'Exception should have been thrown.');
		} catch (Exception e) {
		}

		try {
			String_Services.replaceRepeat('%% %%  %% ', ' %% ', '%', 101);
			System.assert(false, 'Exception should have been thrown.');
		} catch (Exception e) {
		}
	}

	static testMethod void test_truncateWithDots() {
		String numbers = '123456789';

		System.assertEquals('123456789', String_Services.truncateWithDots(numbers, 16));
		System.assertEquals('12345...', String_Services.truncateWithDots(numbers, 8));
		System.assertEquals('...', String_Services.truncateWithDots(numbers, 3));
		System.assertEquals('.', String_Services.truncateWithDots(numbers, 1));

		try {
			String_Services.truncateWithDots(numbers, 0);
			System.assert(false, 'Exception should have been thrown');
		} catch (Exception e) {
			System.assert(true, 'Exception should have been thrown');
		}
	}

	static testMethod void test_toString_ListObjects() {
		Account a = TestFactory.createAccountClient('Client', true);

		String text = String_Services.toString( new List<Account>{ a } );

		System.assertNotEquals(null, text);
		System.assert(text.contains(':'));
		System.assert(text.contains(a.Id));
	}

	static testMethod void test_toString_MapIdObjects() {
		Account a = TestFactory.createAccountClient('Client', true);

		String text = String_Services.toString( new Map<Id, Account>{ a.Id => a } );

		System.assertNotEquals(null, text);
		System.assert(text.contains('=>'));
		System.assert(text.contains(a.Id));
	}

	static testMethod void test_toString_MapStringObjects() {
		Account a = TestFactory.createAccountClient('Client', true);

		String text = String_Services.toString( new Map<String, Account>{ a.Name => a } );

		System.assertNotEquals(null, text);
		System.assert(text.contains('=>'));
		System.assert(text.contains(a.Name));
	}

	/**
	 * @description test_method
	 */
	@IsTest
	public static void test_removeWords() {
		Set<String> blockedWords = new Set<String>{
			'a', 'b', 'c'
		};

		Set<String> result;

		result = String_Services.removeWords(null, blockedWords);
		System.assertEquals(0, result.size());

		List<String> test1 = new List<String>{ };
		result = String_Services.removeWords(test1, blockedWords);
		System.assertEquals(0, result.size());

		List<String> test2 = new List<String>{ '1', '2', 'c', '5', 'd' };
		result = String_Services.removeWords(test2, null);
		System.assertEquals(0, result.size());

		result = String_Services.removeWords(test2, blockedWords);
		System.assertEquals(4, result.size());
		System.assert(result.contains('1'));
		System.assert(result.contains('2'));
		System.assert(result.contains('5'));
		System.assert(result.contains('d'));

		List<String> test3 = new List<String>{ '1', '2', '3' };
		result = String_Services.removeWords(test3, blockedWords);
		System.assertEquals(3, result.size());
		System.assert(result.contains('1'));
		System.assert(result.contains('2'));
		System.assert(result.contains('3'));
	}
}