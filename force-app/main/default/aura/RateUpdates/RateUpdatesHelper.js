({/** DELETE AS PART OF RPC PHASE 4
	validateInputFields : function(component) {
        var allValid = component.find('inputField').reduce(function (validSoFar, inputCmp) {
            inputCmp.reportValidity();
            return validSoFar && inputCmp.checkValidity();
        }, true);
        
        // TODO FUTURE: If % number only has upto 1 digit after decimal point
        // TODO FUTURE: If $ number only has 2 digits after decimal point
        
        return allValid;
	},
      
    saveRecord : function(component, helper) {
        helper.showToast('success', 'Approval Started', 'A request to change the rate or type has been made.');
        helper.closeWindow(component);
        $A.get('e.force:refreshView').fire();                
    },
    
    closeWindow : function(component) {            
 		var action = $A.get("e.force:closeQuickAction");        
        action.fire();            
	},
        
    showToast : function(type, title, message) {
        var resultsToast = $A.get("e.force:showToast");
        if (resultsToast) {
            resultsToast.setParams({
                "type"	  : type,
                "title"   : title,
                "message" : message
            });
            resultsToast.fire(); 
        }
	}     **/   
})