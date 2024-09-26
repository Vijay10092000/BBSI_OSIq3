/**
 * @description TriggerHandlerInvoker is creates and executes trigger handlers.  This code
 * hides calls to the Trigger object, making it so no code outside of this class should
 * access the Trigger object.
 *
 * Trigger handlers must extend the abstract class: TriggerHandlerInvoker.TriggerHandler_Abstract.
 * Only the methods being used by the Trigger Handler need to be overwritten in the
 * handler's class.
 */
public without sharing class TriggerHandlerInvoker {
	private static final LoggingLevel logLevel = LoggingLevel.FINEST;

	// The possible reasons for a TriggerHandlerInvokerException
	private static final String CREATE_HANDLER_FAILED = 'Failed to create trigger handler: {0} for SObject {1}.';
	private static final String TRIGGER_NOT_EXECUTING = 'A Trigger event is not currently executing.';

	@TestVisible
	private static String nameSObject;

	@TestVisible
	private static Boolean isBlocked = false;

	/**
	 * @description TriggerHandlerInvokerException is used for exceptions from the TriggerHandlerInvoker.
	 */
	public class TriggerHandlerInvokerException extends Exception {
	}

	/**
	 * @description TriggerHandler_Abstract is the interface for a trigger handler.  It has methods
	 * for each of the trigger actions.  In your Trigger handler override those methods
	 * needed.
	 */
	@SuppressWarnings('PMD.EmptyStatementBlock')
	public abstract class TriggerHandler_Abstract {
		/**
		 * @description name holds the name of the Trigger Handler.
		 */
		public String name { get; private set; }

		/**
		 * @description beforeInsert performs actions on the mapNew sObjects before the insert happens.
		 * NOTE: Before Insert records have no Id, so are not be able to use Map<>.
		 * @param listNew is the list of new sObjects
		 */
		virtual public void beforeInsert(List<SObject> listNew) {
		}

		/**
		 * @description afterInsert performs actions on related objects to the mapNew sObjects after
		 * the insert.
		 * @param mapNew is the map of sObjects after being saved
		 */
		virtual public void afterInsert(Map<Id, SObject> mapNew) {
		}

		/**
		 * @description beforeUpdate performs actions on the mapNew sObjects before the update happens.
		 * @param mapOld is the map of sObjects before the new changes
		 * @param mapNew is the map of sObjects with the changes
		 */
		virtual public void beforeUpdate(Map<Id, SObject> mapOld, Map<Id, SObject> mapNew) {
		}

		/**
		 * @description afterUpdate performs actions on related objects to the mapNew sObjects after
		 * the update.
		 * @param mapOld is the map of sObjects before the new changes
		 * @param mapNew is the map of sObjects with the saved changes
		 */
		virtual public void afterUpdate(Map<Id, SObject> mapOld, Map<Id, SObject> mapNew) {
		}

		/**
		 * @description beforeDelete performs actions on the mapOld sObjects before the delete happens.
		 * @param mapOld is the map of sObjects before deletion
		 */
		virtual public void beforeDelete(Map<Id, SObject> mapOld) {
		}

		/**
		 * @description afterDelete performs actions on related to the mapOld sObjects after
		 * the delete.
		 * @param mapOld is the map of sObjects which have been deleted
		 */
		virtual public void afterDelete(Map<Id, SObject> mapOld) {
		}

		/**
		 * @description beforeUpdate performs actions on the mapNew sObjects after the undelete happens.
		 *
		 * @param mapNew is the map of sObjects which have been undeleted
		 */
		virtual public void afterUndelete(Map<Id, SObject> mapNew) {
		}
	}

	/**
	 * @description execute performs the Trigger event for the given handler.
	 * @param  handler  TriggerHandler
	 */
	public static void execute(TriggerHandler_Abstract handler) {
		if (!Trigger.isExecuting) {
			throw new TriggerHandlerInvokerException(TRIGGER_NOT_EXECUTING);
		}

		if (isBlocked) {
			return;
		}

		executeInternal(handler, Trigger.operationType, Trigger.oldMap, Trigger.newMap, Trigger.new); //Added For US-69176
	}

	/**
	 * Added For US-69176
	 * @description executeInternal determines the trigger event to perform and calls
	 * the TriggerHandler_Interface appropriate method.  If an exception occurs, it is
	 * logged and rethrown.
	 * @param  handler  TriggerHandler
	 * @param operation System.TriggerOperation being performed
	 * @param mapOld is a Id keyed map of how the objects looked
	 * @param mapNew is a Id keyed map of how the objects will look
	 * @param listNew is an ordered list of how the objects will look
	 * @throws TriggerHandlerInvoker.TriggerHandlerInvokerException on invalid trigger
	 *         event or creation error
	 */
	@SuppressWarnings('PMD.ExcessiveParameterList, PMD.CognitiveComplexity')
	@TestVisible
	private static void executeInternal(
		TriggerHandler_Abstract handler,
		System.TriggerOperation operation,
		Map<Id, SObject> mapOld,
		Map<Id, SObject> mapNew,
		List<SObject> listNew
	) {
		if (!isBlocked) {
			String nameOperation = operation.name();

			System.debug(logLevel, 'TRIGGER HANDLER: START: ' + handler.name + ' ' + nameOperation);
			Timer timer = new Timer(true);

			try {
						switch on operation {
							when BEFORE_INSERT {
								handler.beforeInsert(listNew);
							}
							when AFTER_INSERT {
								handler.afterInsert(mapNew);
							}
							when BEFORE_UPDATE {
								handler.beforeUpdate(mapOld, mapNew);
							}
							when AFTER_UPDATE {
								handler.afterUpdate(mapOld, mapNew);
							}
							when BEFORE_DELETE {
								handler.beforeDelete(mapOld);
							}
							when AFTER_DELETE {
								handler.afterDelete(mapOld);
							}
							when AFTER_UNDELETE {
								handler.afterUndelete(mapNew);
							}
						}

			} catch (Exception e) {
				Set<Id> ids;

				if (operation == System.TriggerOperation.BEFORE_INSERT) {
					ids = new Set<Id>();
				} else if (operation == System.TriggerOperation.BEFORE_DELETE ||
					operation == System.TriggerOperation.AFTER_DELETE) {
					ids = mapOld.keySet();
				} else {
					ids = mapNew.keySet();
				}

				logException(nameOperation, e, ids);
				throw e;
			}

			timer.stop();
			System.debug(logLevel, 'TRIGGER HANDLER: COMPLETE: ' + handler.name + ' ' + nameOperation + ' - ' + timer.elapsed() + 'ms');
		}
	}

	/**
	 * @description blockTriggers block all Triggers from running.
	 */
	public static void blockTriggers() {
		isBlocked = true;
	}

	/**
	 * @description unblockTriggers unblock all Triggers.
	 */
	public static void unblockTriggers() {
		isBlocked = false;
	}

	/**
	 * Updated For US-69176
	 * @description logException creates a new Log record.
	 * @param  nameSObject    Name of SObject trigger is for
	 * @param  nameOperation  Name of Operation failing
	 * @param  e              An Exception
	 * @param  ids            Set of Ids for operation
	 */
	@TestVisible
	private static void logException(String nameOperation, Exception e, Set<Id> ids) {
		Log.error(
			'TriggerHandler',
			'Exception during ' + nameOperation,
			'IDENTIFIERS\n  ' + String.join(new List<Id>(ids), '\n  '),
			e
		);
	}
}