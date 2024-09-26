({
    acceptSolution : function(component, event, helper) {
    	var cmpInstance = component.find("staticField");
    	[].concat(cmpInstance).forEach(
    			cmp => {
                    if(!$A.util.isEmpty(cmp.get("v.value"))) {
                    	if(!$A.util.isUndefined(cmp.get("v.value"))){
    						component.set("v.simpleRecord.Comment__c", cmp.get("v.value"));
                		}
                	}
    			}
    	);
        component.set("v.simpleRecord.Status", "Closed");
        component.find("recordEditor").saveRecord($A.getCallback(function(saveResult) {
            if (saveResult.state === "SUCCESS" || saveResult.state === "DRAFT") {
                console.log('recordSaved');
                $A.get("e.force:refreshView").fire();
                }else if (saveResult.state === "ERROR") {
                    var errors = "";
                    for (var i = 0; saveResult.error.length > i; i++){
                        errors = errors + saveResult.error[i].message;
                    }            
                    var resultsToast = $A.get("e.force:showToast");
                    resultsToast.setParams({
                        "type":"error",
                        "title": "Error!",
                        "message": errors                        
                    });
                    resultsToast.fire();
                }
        }));
    },
    declineSolution : function(component, event, helper) {
    	var allValid = true;
    	var cmpInstance = component.find("staticField");
    	[].concat(cmpInstance).forEach(
    			cmp => {
                    if(!$A.util.isEmpty("v.value")) {
                    	if(!$A.util.isUndefined(cmp.get("v.value"))){
    						component.set("v.simpleRecord.Comment__c", cmp.get("v.value"));
                		}else{
                			allValid = false;
                			var errorMessage = "Comment is required.";
		  					component.set("v.showError",true);
		  					component.set("v.errorMessage",errorMessage);
                		}
                	}else{
                		allValid = false;
                		var errorMessage = "Comment is required.";
		  				component.set("v.showError",true);
		  				component.set("v.errorMessage",errorMessage);
                	}
    			}
    	);
    	if(allValid) {
        	// do nothing
        }else{
        	return;
        }
        component.set("v.simpleRecord.Status", "In Progress");
        component.set("v.simpleRecord.Sub_Status__c", "Rejected");
        component.find("recordEditor").saveRecord($A.getCallback(function(saveResult) {
            if (saveResult.state === "SUCCESS" || saveResult.state === "DRAFT") {
                console.log('recordSaved');
                $A.get("e.force:refreshView").fire();
            }else if (saveResult.state === "ERROR") {
                    var errors = "";
                    for (var i = 0; saveResult.error.length > i; i++){
                        errors = errors + saveResult.error[i].message;
                    }            
                    var resultsToast = $A.get("e.force:showToast");
                    resultsToast.setParams({
                        "type":"error",
                        "title": "Error!",
                        "message": errors                        
                    });
                    resultsToast.fire();
                }
        }));
    }    
})