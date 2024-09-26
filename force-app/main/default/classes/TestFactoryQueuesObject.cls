/**
 * @description TestFactoryQueuesObject contains methods to create test QueuesObject.
 */
@isTest
public class TestFactoryQueuesObject {
    /**
	 * @description createQueuesObject create a QueuesObject in the database.
	 * @param  SObjectType    SObjectType QueuesObject    
	 * @param  QueueId    QueueId For QueuesObject
	 * @return QueuesObject
	 */
    public static QueuesObject createQueuesObject(String SObjectType,String QueueId){
        QueuesObject que = makeQueuesObject(SObjectType, QueueId);
        insert que;
        return que;
    }

    /**
	 * @description makeQueuesObject makes a QueuesObject in the database.
	 * @param  SObjectType    SObjectType QueuesObject    
	 * @param  QueueId    QueueId For QueuesObject
	 * @return QueuesObject
	 */
    public static QueuesObject makeQueuesObject(String SObjectType,String QueueId){
        return new QueuesObject(SObjectType = SObjectType, QueueId = QueueId);
    }
}