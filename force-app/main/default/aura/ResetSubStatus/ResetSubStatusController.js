({
    saveRecordCntrlr : function(component, event, helper) {
        component.set("v.simpleRecord.Sub_Status__c", "");
        component.find("recordEditor").saveRecord($A.getCallback(function(saveResult) {
            if (saveResult.state === "SUCCESS" || saveResult.state === "DRAFT") {
                console.log('recordSaved');
                $A.get("e.force:refreshView").fire();
            }
        }));
    }
})