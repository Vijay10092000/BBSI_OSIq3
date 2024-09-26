({
    doInit : function(component, event, helper) {
        component.set("v.userId", $A.get("$SObjectType.CurrentUser.Id"));
        var parentRecordId = component.get("v.recordId");
    
        var actionInit = component.get("c.isAllowed");
        actionInit.setParams({
                parentRecordId: parentRecordId,
                recordTypeDevName: component.get("v.recordTypeDevName"),
                recordTypeId: component.get("v.pageReference.state.recordTypeId")
		});
		
        actionInit.setCallback(this, function(a) {
        	if (a.getState() === "SUCCESS") {
        		var allow = a.getReturnValue();
        		component.set("v.showOnlyWarning", allow);
            }
            helper.hideSpinner(component);
		});
		
        helper.showSpinner(component);
        $A.enqueueAction(actionInit);
    
        var action1 = component.get("c.getStaticFields");
        action1.setParams({
                parentRecordId: parentRecordId,
                recordTypeDevName: component.get("v.recordTypeDevName"),
                recordTypeId: component.get("v.pageReference.state.recordTypeId")
        });
        action1.setCallback(this, function(a) {
        	if (a.getState() === "SUCCESS") {
        		var sectionList = a.getReturnValue();
        		component.set("v.fieldsStatic", sectionList);
                component.set("v.showDynamic", false);
            }
            helper.hideSpinner(component);
        });
        helper.showSpinner(component);
        $A.enqueueAction(action1);

        var action2 = component.get("c.getDynamicAfter");
        action2.setParams(
            {
                parentRecordId: parentRecordId,
                recordTypeDevName: component.get("v.recordTypeDevName"),
                recordTypeId: component.get("v.pageReference.state.recordTypeId")
            }
        );
        action2.setCallback(this, function(a) {
        	if (a.getState() === "SUCCESS") {
        		var dynamicAfter = a.getReturnValue();
        		component.set("v.dynamicAfter", dynamicAfter);
            }
            helper.hideSpinner(component);
        });
        helper.showSpinner(component);
        $A.enqueueAction(action2);

        if (parentRecordId == null) {
            var action3 = component.get("c.activeContactAccountId");
            action3.setCallback(this, function(a) {
                if (a.getState() === "SUCCESS") {
                    component.set("v.recordId", a.getReturnValue());
                }
            });
            $A.enqueueAction(action3);
        }

        var action4 = component.get("c.createFileHolder");
        action4.setCallback(this, function(a) {
        	if (a.getState() === "SUCCESS") {
        		var fhId = a.getReturnValue();
        		component.set("v.fileHolderId", fhId);
            }
            helper.hideSpinner(component);
        });

        helper.showSpinner(component);
        $A.enqueueAction(action4);
    },

    attachedFiles : function (component) {
        var action = component.get("c.uploadedFiles");
        action.setParams({  
            "recordId": component.get("v.fileHolderId")  
        });      
        action.setCallback(this,function(response) {  
            var state = response.getState();  
            if (state=='SUCCESS') {  
                var result = response.getReturnValue();           
                component.set("v.files", result);  
            }  
        });  
        $A.enqueueAction(action); 
    },
    
    removeFile : function(component, event, helper) {
        var documentId = event.currentTarget.id;        
        var action = component.get("c.deleteFile");           
        action.setParams({
            "documentId": documentId,
            "recordId": component.get("v.fileHolderId")
        });
        action.setCallback(this,function(response) {   
            var state = response.getState();  
            if (state=='SUCCESS') {  
                var result = response.getReturnValue();           
                component.set("v.files", result);  
            }  
        });
        $A.enqueueAction(action); 
    },

    doSelectChange : function(component, event, helper) {
    	helper.doSelectChange(component, event);
    },

    saveRecord : function(component, event, helper) {
        helper.saveRecord(component, event);
    },

    cancel : function(component, event, helper) {
    },

    handleFilesChange : function (cmp, event) {
        var files = event.getSource().get("v.files");
        alert(files.length + ' files !!');
    },

	showSpinner : function(component, event, helper) {
        helper.showSpinner(component);
    },
    
	hideSpinner : function(component, event, helper) {
        helper.hideSpinner(component);
	},
    
	previousPage : function(component, event, helper) {
        window.history.back();
	},
	
	onPageReferenceChanged: function (component, event, helper) {
        $A.get('e.force:refreshView').fire();
    }
})