/**
 * @description Option_Test contains tests for the Option class.
 */
@IsTest
public with sharing class Option_Test {
	@IsTest
    static void test_Constructors() {
		Option option;

		option = new Option('Value');
		System.assertEquals('Value', option.value);
		System.assertEquals('Value', option.label);
		System.assertEquals(false, option.selected);

		option = new Option('Value', true);
		System.assertEquals('Value', option.value);
		System.assertEquals('Value', option.label);
		System.assertEquals(true, option.selected);

		option = new Option('Value', 'Label', false);
		System.assertEquals('Value', option.value);
		System.assertEquals('Label', option.label);
		System.assertEquals(false, option.selected);
    }
}