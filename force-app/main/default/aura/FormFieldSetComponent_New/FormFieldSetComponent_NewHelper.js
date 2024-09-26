({
    getFieldApiList : function(component) {
        var action = component.get("c.fieldList");
        var recordId = component.get("v.recordId");

        action.setParams({
            idCase : recordId
        });
        
        //Setting the Callback
        action.setCallback(this,function(a){
            //get the response state
            var state = a.getState();
            
            //check if result is successfull
            if(state == "SUCCESS"){
                
              //  alert(a.getReturnValue());
                //Perform Action after the result
                let result = a.getReturnValue();
               // alert(result);
                if(result != null)
                {
                    component.set("v.fieldsAPIList",result.listApi);
                    component.set("v.formrecordId",result.formId);
                    component.set("v.flag",false);
                }
                
            } else if(state == "ERROR"){
               
            }
        });
        
        //adds the server-side action to the queue        
        $A.enqueueAction(action);
        
    }
})