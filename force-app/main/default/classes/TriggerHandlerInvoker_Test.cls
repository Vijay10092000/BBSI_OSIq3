/**
 * This Test class Updated For US-69176
 * @description TriggerHandlerInvoker_Test contains the tests for the TriggerHandlerInvoker.
 */
@IsTest
@SuppressWarnings('PMD.AvoidHardcodingId, PMD.ApexAssertionsShouldIncludeMessage')
public class TriggerHandlerInvoker_Test {
	private static final String FAKE_LEAD_ID = '00Q000000000t75';

	public static Integer callCount = 0;
	public static String lastMethodCalled = '';

	private static Boolean throwException = false;

	/**
	 * @description BaseTriggerHandler_Test is used in the tests to access the base TriggerHandler class methods.
	 */
	@SuppressWarnings('PMD.EmptyStatementBlock')
	public class BaseTriggerHandler_Test extends TriggerHandlerInvoker.TriggerHandler_Abstract {
	}

	/**
	 * @description TriggerHandler_Test is the trigger handler used for the tests.
	 * Adds counts to each trigger event type.
	 */
	public class TriggerHandler_Test extends TriggerHandlerInvoker.TriggerHandler_Abstract {
		override public void beforeInsert(List<sObject> listNew) {
			TriggerHandlerInvoker_Test.lastMethodCalled = 'beforeInsert';
			++TriggerHandlerInvoker_Test.callCount;

			if (TriggerHandlerInvoker_Test.throwException) {
				throw new IllegalArgumentException('Test Exception');
			}
		}

		override public void afterInsert(Map<Id, sObject> mapNew) {
			TriggerHandlerInvoker_Test.lastMethodCalled = 'afterInsert';
			++TriggerHandlerInvoker_Test.callCount;

			if (TriggerHandlerInvoker_Test.throwException) {
				throw new IllegalArgumentException('Test Exception');
			}
		}

		override public void beforeUpdate(Map<Id, sObject> mapOld, Map<Id, sObject> mapNew) {
			TriggerHandlerInvoker_Test.lastMethodCalled = 'beforeUpdate';
			++TriggerHandlerInvoker_Test.callCount;
		}

		override public void afterUpdate(Map<Id, sObject> mapOld, Map<Id, sObject> mapNew) {
			TriggerHandlerInvoker_Test.lastMethodCalled = 'afterUpdate';
			++TriggerHandlerInvoker_Test.callCount;
		}

		override public void beforeDelete(Map<Id, sObject> mapOld) {
			TriggerHandlerInvoker_Test.lastMethodCalled = 'beforeDelete';
			++TriggerHandlerInvoker_Test.callCount;

			if (TriggerHandlerInvoker_Test.throwException) {
				throw new IllegalArgumentException('Test Exception');
			}
		}

		override public void afterDelete(Map<Id, sObject> mapOld) {
			TriggerHandlerInvoker_Test.lastMethodCalled = 'afterDelete';
			++TriggerHandlerInvoker_Test.callCount;

			if (TriggerHandlerInvoker_Test.throwException) {
				throw new IllegalArgumentException('Test Exception');
			}
		}

		override public void afterUndelete(Map<Id, sObject> mapNew) {
			TriggerHandlerInvoker_Test.lastMethodCalled = 'afterUndelete';
			++TriggerHandlerInvoker_Test.callCount;

			if (TriggerHandlerInvoker_Test.throwException) {
				throw new IllegalArgumentException('Test Exception');
			}
		}
	}

	/**
	 * @description baseTriggerHandler is just a code coverage test.  The methods in the abstract class
	 * TriggerHandlerInvoker_Test.BaseTriggerHandler_Test perform no actions.
	 */
	@SuppressWarnings('PMD.ApexUnitTestClassShouldHaveAsserts')
	@IsTest
	public static void baseTriggerHandler() {
		TriggerHandlerInvoker_Test.BaseTriggerHandler_Test handler = new TriggerHandlerInvoker_Test.BaseTriggerHandler_Test();

		handler.beforeInsert(null);
		handler.afterInsert(null);
		handler.beforeUpdate(null, null);
		handler.afterUpdate(null, null);
		handler.beforeDelete(null);
		handler.afterDelete(null);
		handler.afterUndelete(null);
	}

	/**
	 * @description notExecutingTrigger tests the exception thrown when TriggerHandlerInvoker
	 * is executed without a Trigger Event.
	 */
	@IsTest
	static void notExecutingTrigger() {
		try {
			TriggerHandlerInvoker.execute(null);
			Assert.fail('Should have thrown exception: Trigger Not Executing');
		} catch (TriggerHandlerInvoker.TriggerHandlerInvokerException e) {
			Assert.isTrue(true, 'Exception thrown');
		}
	}

	/**
	 * @description invalidTriggerHandler tests the exception thrown when TriggerHandlerInvoker
	 * is executed with an invalid Trigger Handler name.
	 */
	@IsTest
	static void invalidTriggerHandler() {		
		List<Lead> leads = new List<Lead>{ new Lead(FirstName = 'Test', LastName = 'Lead') };
		try {
			TriggerHandlerInvoker.execute(null);
			Assert.fail('Should have thrown exception: Create Handler Failed');
		} catch (TriggerHandlerInvoker.TriggerHandlerInvokerException e) {
			Assert.isTrue(true, 'Exception thrown');
		}
	}

	/**
	 * @description beforeInsert tests a Before Insert Trigger Event.
	 */
	@IsTest
	static void beforeInsert() {
		List<Lead> leads = new List<Lead>{ new Lead(FirstName = 'Test', LastName = 'Lead') };

		TriggerHandlerInvoker_Test.lastMethodCalled = '';
		TriggerHandlerInvoker.executeInternal(new TriggerHandlerInvoker_Test.TriggerHandler_Test(), System.TriggerOperation.BEFORE_INSERT, null, null, leads);
		Assert.areEqual(
			'beforeInsert',
			TriggerHandlerInvoker_Test.lastMethodCalled,
			'Last method should be test_beforeInsert'
		);
	}

	/**
	 * @description beforeInsert tests an After Insert Trigger Event.
	 */
	@IsTest
	static void afterInsert() {
		List<Lead> leads = new List<Lead>{ new Lead(FirstName = 'Test', LastName = 'Lead') };

		TriggerHandlerInvoker_Test.lastMethodCalled = '';
		TriggerHandlerInvoker.executeInternal(new TriggerHandlerInvoker_Test.TriggerHandler_Test(), System.TriggerOperation.AFTER_INSERT, null, null, leads);
		Assert.areEqual(
			'afterInsert',
			TriggerHandlerInvoker_Test.lastMethodCalled,
			'Last method should be afterInsert'
		);
	}

	/**
	 * @description beforeUpdate tests a Before Update Trigger Event.
	 */
	@IsTest
	static void beforeUpdate() {
		List<Lead> leads = new List<Lead>{ new Lead(FirstName = 'Test', LastName = 'Lead') };

		TriggerHandlerInvoker_Test.lastMethodCalled = '';
		TriggerHandlerInvoker.executeInternal(new TriggerHandlerInvoker_Test.TriggerHandler_Test(), System.TriggerOperation.BEFORE_UPDATE, null, null, leads);
		Assert.areEqual(
			'beforeUpdate',
			TriggerHandlerInvoker_Test.lastMethodCalled,
			'Last method should be beforeUpdate'
		);
	}

	/**
	 * @description afterUpdate tests an After Update Trigger Event.
	 */
	@IsTest
	static void afterUpdate() {
		List<Lead> leads = new List<Lead>{ new Lead(FirstName = 'Test', LastName = 'Lead') };

		TriggerHandlerInvoker_Test.lastMethodCalled = '';
		TriggerHandlerInvoker.executeInternal(new TriggerHandlerInvoker_Test.TriggerHandler_Test(), System.TriggerOperation.AFTER_UPDATE, null, null, leads);
		Assert.areEqual(
			'afterUpdate',
			TriggerHandlerInvoker_Test.lastMethodCalled,
			'Last method should be afterUpdate'
		);
	}

	/**
	 * @description beforeDelete tests an Before Delete Trigger Event.
	 */
	@IsTest
	static void beforeDelete() {
		Map<Id, Lead> leads = new Map<Id, Lead>();
		leads.put(FAKE_LEAD_ID, new Lead(FirstName = 'Test', LastName = 'Lead'));

		TriggerHandlerInvoker_Test.lastMethodCalled = '';
		TriggerHandlerInvoker.executeInternal(new TriggerHandlerInvoker_Test.TriggerHandler_Test(), System.TriggerOperation.BEFORE_DELETE, leads, null, null);
		Assert.areEqual(
			'beforeDelete',
			TriggerHandlerInvoker_Test.lastMethodCalled,
			'Last method should be beforeDelete'
		);
	}

	/**
	 * @description afterDelete tests an After Delete Trigger Event.
	 */
	@IsTest
	static void afterDelete() {
		Map<Id, Lead> leads = new Map<Id, Lead>();
		leads.put(FAKE_LEAD_ID, new Lead(FirstName = 'Test', LastName = 'Lead'));

		TriggerHandlerInvoker_Test.lastMethodCalled = '';
		TriggerHandlerInvoker.executeInternal(new TriggerHandlerInvoker_Test.TriggerHandler_Test(), System.TriggerOperation.AFTER_DELETE, leads, null, null);
		Assert.areEqual(
			'afterDelete',
			TriggerHandlerInvoker_Test.lastMethodCalled,
			'Last method should be afterDelete'
		);
	}

	/**
	 * @description afterUndelete tests an After Undelete Trigger Event.
	 */
	@IsTest
	static void afterUndelete() {
		List<Lead> leads = new List<Lead>{ new Lead(FirstName = 'Test', LastName = 'Lead') };

		TriggerHandlerInvoker_Test.lastMethodCalled = '';
		TriggerHandlerInvoker.executeInternal(new TriggerHandlerInvoker_Test.TriggerHandler_Test(), System.TriggerOperation.AFTER_UNDELETE, null, null, leads);
		Assert.areEqual(
			'afterUndelete',
			TriggerHandlerInvoker_Test.lastMethodCalled,
			'Last method should be afterUndelete'
		);
	}

	/**
	 * @description logException tests the Log record on exception
	 */
	@IsTest
	static void test_logException() {
		DateTime now = DateTime.now();

		TriggerHandlerInvoker.logException('BEFORE_INSERT', null, new Set<Id>());
		TriggerHandlerInvoker.logException('AFTER_DELETE', null, new Set<Id>{ FAKE_LEAD_ID });

		List<Log__c> logs = Log_Test.recentLogs(now);

		Assert.areEqual(2, logs.size(), 'Number of Log records written');
		Log__c log0 = logs.get(0);
		Log__c log1 = logs.get(1);

		Assert.areEqual('error', log0.Severity__c.toLowerCase(), 'Incorrect Severity');
		Assert.areEqual('TriggerHandler', log0.Scope__c, 'Incorrect Bundle');
		Assert.isTrue(log0.Subject__c.contains('BEFORE_INSERT'));

		Assert.areEqual('error', log1.Severity__c.toLowerCase(), 'Incorrect Severity');
		Assert.areEqual('TriggerHandler', log1.Scope__c, 'Incorrect Bundle');
		Assert.isTrue(log1.Subject__c.contains('AFTER_DELETE'));
	}

	/**
	 * @description exceptionTriggerHandler tests an exception thrown during an operation.
	 */
	@IsTest
	static void exceptionTriggerHandler_1() {
		TriggerHandlerInvoker_Test.throwException = true;
		List<Lead> leads = new List<Lead>{ new Lead(FirstName = 'Test', LastName = 'Lead') };

		DateTime now = DateTime.now();

		try {
			TriggerHandlerInvoker.executeInternal(new TriggerHandlerInvoker_Test.TriggerHandler_Test(), System.TriggerOperation.BEFORE_INSERT, null, null, leads);
			Assert.fail('Should have thrown exception: Create Handler Failed');
		} catch (IllegalArgumentException iae) {
			Assert.isTrue(true, 'Exception thrown');
		} catch (Exception e) {
			Assert.fail('Wrong exception thrown' + e);
		}

		List<Log__c> logs = Log_Test.recentLogs(now);

		System.assertEquals(1, logs.size(), 'Number of Log records written');
		Log__c log0 = logs.get(0);

		System.assertEquals('error', log0.Severity__c.toLowerCase(), 'Incorrect Severity');
		System.assertEquals('TriggerHandler', log0.Scope__c, 'Incorrect Bundle');
		Assert.isTrue(log0.Subject__c.contains('BEFORE_INSERT'));
	}

	/**
	 * @description exceptionTriggerHandler tests an exception thrown during an operation.
	 */
	@IsTest
	static void exceptionTriggerHandler_2() {
		TriggerHandlerInvoker_Test.throwException = true;

		Map<Id, Lead> leads = new Map<Id, Lead>{ FAKE_LEAD_ID => new Lead(FirstName = 'Test', LastName = 'Lead', Id = FAKE_LEAD_ID) };

		DateTime now = DateTime.now();

		try {
			TriggerHandlerInvoker.executeInternal(new TriggerHandlerInvoker_Test.TriggerHandler_Test(), System.TriggerOperation.AFTER_UNDELETE, null, leads, new List<Lead>(leads.values()));
			Assert.fail('Should have thrown exception: Create Handler Failed');
		} catch (IllegalArgumentException iae) {
			Assert.isTrue(true, 'Exception thrown');
		} catch (Exception e) {
			Assert.fail('Wrong exception thrown' + e + ' : ' + e.getStackTraceString());
		}

		List<Log__c> logs = Log_Test.recentLogs(now);

		System.assertEquals(1, logs.size(), 'Number of Log records written');
		Log__c log0 = logs.get(0);

		System.assertEquals('error', log0.Severity__c.toLowerCase(), 'Incorrect Severity');
		System.assertEquals('TriggerHandler', log0.Scope__c, 'Incorrect Bundle');
		Assert.isTrue(log0.Subject__c.contains('AFTER_UNDELETE'));
	}

	/**
	 * @description exceptionTriggerHandler tests an exception thrown during an operation.
	 */
	@IsTest
	static void exceptionTriggerHandler_3() {
		TriggerHandlerInvoker_Test.throwException = true;

		Map<Id, Lead> leads = new Map<Id, Lead>{ FAKE_LEAD_ID => new Lead(FirstName = 'Test', LastName = 'Lead', Id = FAKE_LEAD_ID) };

		DateTime now = DateTime.now();

		try {
			TriggerHandlerInvoker.executeInternal(new TriggerHandlerInvoker_Test.TriggerHandler_Test(), System.TriggerOperation.BEFORE_DELETE, leads, null, null);
			Assert.fail('Should have thrown exception: Create Handler Failed');
		} catch (IllegalArgumentException iae) {
			Assert.isTrue(true, 'Exception thrown');
		} catch (Exception e) {
			Assert.fail('Wrong exception thrown' + e + ' : ' + e.getStackTraceString());
		}

		List<Log__c> logs = Log_Test.recentLogs(now);

		System.assertEquals(1, logs.size(), 'Number of Log records written');
		Log__c log0 = logs.get(0);

		System.assertEquals('error', log0.Severity__c.toLowerCase(), 'Incorrect Severity');
		System.assertEquals('TriggerHandler', log0.Scope__c, 'Incorrect Bundle');
		Assert.isTrue(log0.Subject__c.contains('BEFORE_DELETE'));
	}

	/**
	 * @description exceptionTriggerHandler tests an exception thrown during an operation.
	 */
	@IsTest
	static void test_Blocking() {
		System.assertEquals(false, TriggerHandlerInvoker.isBlocked);
		TriggerHandlerInvoker.blockTriggers();
		System.assertEquals(true, TriggerHandlerInvoker.isBlocked);
		TriggerHandlerInvoker.unblockTriggers();
		System.assertEquals(false, TriggerHandlerInvoker.isBlocked);
	}
}