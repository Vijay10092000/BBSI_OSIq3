@isTest
public class TestFactoryTask {
    /**
* @description createTask creates a new Task record in the database.
* @param  recordType       recordType of the Task
* @param  fldMap 		additional field values for the Task
* @return Task
*/
    
    public static Task createTask(String recordType, Map<String, Object> fldMap) {
        Task testTask = makeTask(recordType, fldMap);
        insert testTask;
        return testTask;
    }
    
    /**
* @description makeTask makes a new Task record in the database.
* @param  recordType       recordType of the Task
* @param  fldMap 		additional field values for the Task
* @return Task
*/
    public static Task makeTask(String recordType, Map<String, Object> fldMap) {        
        Task testTask = new Task();
        if(String.isNotBlank(recordType)){
            Id idrtTask = RecordTypeService.getId('Task', recordType);
            testTask.RecordTypeId = idrtTask;
        }        
        if (fldMap != null) {
            testTask = (Task) TestFactory.assignFields(fldMap, testTask);
        }
        return testTask;
    }
    
}