({
    doSelectChange : function(component, event) {
    	component.set("v.showDynamic", false);
    	var cmpInstance = component.find("dynamicField");
    	var depInstance = component.find("otherDependent");
    	var sectionList = component.get("v.fieldsStatic");
    	if (!cmpInstance) return;
    	//if (!depInstance) return;
    	// Enable only appropriate child picklists of Category
    	var dynamicSelections = [];
    	var dependentSelections = [];
    	var dynamicData = component.get("v.dynamicData");
    	if(!dynamicData) dynamicData = {};
    	var x = 0;
    	var changed = false;
    	[].concat(cmpInstance).forEach(
  			cmp => {
    			dynamicSelections[x] = cmp.get("v.value");
    			var fieldName = cmp.get("v.name");
    			if(dynamicData[fieldName]) {
    				var oldValue = dynamicData[fieldName];
    				if(changed) {
    					dynamicSelections[x] = '';
    					dynamicData[fieldName] = '';
    				}else{
    					if(oldValue != dynamicSelections[x]) {
    						changed = true;
    						dynamicData[fieldName] = dynamicSelections[x];
    					}
    				}
    			}else{
    				dynamicData[fieldName] = dynamicSelections[x];
    			}
    			// populate the type and subtype picklist with correct picklist values
    			// also disable those picklists with no picklist values
    			if(x > 0) {
    				for(var i = 0; i < sectionList.length; i++) {
    					// Handle dependent picklists
    					for(var j = 0; j < sectionList[i].fieldList.length; j++) {
    						if(fieldName == sectionList[i].fieldList[j].fieldPath) {
    							var foundKey = false;
    							for(var key in sectionList[i].fieldList[j].dependentPicklistValues) {
    								if(key == dynamicSelections[x-1]) {
    									foundKey = true;
    									sectionList[i].fieldList[j].picklistValues = sectionList[i].fieldList[j].dependentPicklistValues[key];						
    									if(!sectionList[i].fieldList[j].picklistValues) {
    										sectionList[i].fieldList[j].disabled = true;
    									}else{
    										if(sectionList[i].fieldList[j].picklistValues.length > 0) {
    											sectionList[i].fieldList[j].disabled = false;
    										}else{
    											sectionList[i].fieldList[j].disabled = true;
    										}
    									}
    								}
    							}
    							if(!foundKey){
    								sectionList[i].fieldList[j].disabled = true;
    							}
    						}
    					}
    				}
    			}
    			x = x + 1;
    		}
    	);
    	// Enable only appropriate child picklists of non-dynamic picklists
    	[].concat(depInstance).forEach(
  			cmp => {
    			var fieldName = cmp.get("v.name");
    			// blank out child picklist if parent picklist was blanked out
    			var parentField = '';
    			// find parent field for this child picklist
    			for(var i = 0; i < sectionList.length; i++) {
    				for(var j = 0; j < sectionList[i].fieldList.length; j++) {
    					if(fieldName == sectionList[i].fieldList[j].fieldPath) {
    						parentField = sectionList[i].fieldList[j].parentField;
    					}
    				}
    			}
    			// blank out child if parent is blank
    			if(parentField != '') {
    				if(dynamicData[parentField] == '') {
    					cmp.set("v.value",'');
    				}
    			}
    			// populate the type and subtype picklist with correct picklist values
    			// also disable those picklists with no picklist values
    			for(var i = 0; i < sectionList.length; i++) {
    				// Handle dependent picklists
    				for(var j = 0; j < sectionList[i].fieldList.length; j++) {
    					if(fieldName == sectionList[i].fieldList[j].fieldPath) {
    						var parentFieldName = sectionList[i].fieldList[j].parentField;
    						var foundKey = false;
    						for(var key in sectionList[i].fieldList[j].dependentPicklistValues) {
    							if(key == dynamicData[parentFieldName]) {
    								foundKey = true;
    								sectionList[i].fieldList[j].picklistValues = sectionList[i].fieldList[j].dependentPicklistValues[key];						
    								if(!sectionList[i].fieldList[j].picklistValues) {
    									sectionList[i].fieldList[j].disabled = true;
    								}else{
    									if(sectionList[i].fieldList[j].picklistValues.length > 0) {
    										sectionList[i].fieldList[j].disabled = false;
    									}else{
    										sectionList[i].fieldList[j].disabled = true;
    									}
    								}
    							}
    						}
    						if(!foundKey){
    							sectionList[i].fieldList[j].disabled = true;
    						}
    					}
    				}
    			}
    		}
    	);
    	
        var objectApiName = "Form__c";
        var action = component.get("c.getDynamicFields");
        action.setParams({typeName: objectApiName, dynamicValues: dynamicSelections});
        action.setCallback(this, function(a) {
        	var fieldList = a.getReturnValue();
        	if(fieldList) {
        		component.set("v.fieldsDynamic", fieldList);
        		component.set("v.showDynamic", true);
            }else{
            	component.set("v.showDynamic", false);
            }
            component.set("v.fieldsStatic", sectionList);
            component.set("v.dynamicData",dynamicData);
            [].concat(cmpInstance).forEach(
            		cmp => {
            			var fieldName2 = cmp.get("v.name");
            			if(dynamicData[fieldName2]){
            				var value = dynamicData[fieldName2];
            				if(value == '') {
            					cmp.set("v.value",value);
            				}else{
            					cmp.set("v.value",value);
            				}
            			}else{
            				var value = dynamicData[fieldName2];
            				cmp.set("v.value",value);
            			}
            		});
			this.hideSpinner(component);
		});
		this.showSpinner(component);
        $A.enqueueAction(action);
	},
	
    saveRecord : function(component, event) {
    	event.getSource().set("v.disabled", true);
        var allValid = true;
        var cmpInstance1_0 = component.find("staticField");
        var cmpInstance1_1 = component.find("dynamicField");
        var cmpInstance1_2 = component.find("otherDependent");
		var sectionList = component.get("v.fieldsStatic");
		
        if (!cmpInstance1_0) {
		}
		else {
			[].concat(cmpInstance1_0).forEach(
				cmp => {
					if(!cmp.get("v.value")) {
						if(cmp.get("v.required")) {
							// if field is required but blank, then show error
							allValid = false;
							var errorMessage = cmp.get("v.label") + " is required.";
							component.set("v.showError",true);
							component.set("v.errorMessage",errorMessage);
							event.getSource().set("v.disabled", false);
							window.scroll(0,0);
						}
					}
				}
			);
		}
		
        if (allValid) {
        	// do nothing
		}
		else {
        	return;
		}
		
	    if (!cmpInstance1_1) {
		}
		else {
			[].concat(cmpInstance1_1).forEach(
				cmp => {
					if (!cmp.get("v.value")) {
						if (cmp.get("v.required")) {
							// if field is required but blank, then show error
							if (allValid) {
								var parentField = '';
								var picklistValuesPresent = false;
								var fieldName = cmp.get("v.name");
								// check if field is dependent picklist
								for (var i = 0; i < sectionList.length; i++) {
									for (var j = 0; j < sectionList[i].fieldList.length; j++) {
										if (fieldName == sectionList[i].fieldList[j].fieldPath) {
											parentField = sectionList[i].fieldList[j].parentField;
											if ($A.util.isEmpty(sectionList[i].fieldList[j].picklistValues)) {
												picklistValuesPresent = false;
											}
											else {
												picklistValuesPresent = true;
											}
										}
									}
								}

								// if field is dependent picklist then validate if its filled out
								if (parentField != '') {
									if(picklistValuesPresent) {
										var errorMessage = cmp.get("v.label") + " is required.";
										component.set("v.showError",true);
										component.set("v.errorMessage",errorMessage);
										event.getSource().set("v.disabled", false);
										window.scroll(0,0);
										allValid = false;
									}else{
										allValid = true;
									}
								}
								else {
									var errorMessage = cmp.get("v.label") + " is required.";
									component.set("v.showError",true);
									component.set("v.errorMessage",errorMessage);
									event.getSource().set("v.disabled", false);
									window.scroll(0,0);
									allValid = false;
								}
							}
						}
					}
				}
			);
		}
		
        if (allValid) {
        	// do nothing
		}
		else {
        	return;
		}
		
        if (!cmpInstance1_2) {
		}
		else {
			[].concat(cmpInstance1_2).forEach(
				cmp => {
					if(!cmp.get("v.value")) {
						if(cmp.get("v.required")) {
							// if field is required but blank, then show error
							if(allValid){
								var parentField = '';
								var picklistValuesPresent = false;
								var fieldName = cmp.get("v.name");
								// check if field is dependent picklist
								for(var i = 0; i < sectionList.length; i++) {
									for(var j = 0; j < sectionList[i].fieldList.length; j++) {
										if(fieldName == sectionList[i].fieldList[j].fieldPath) {
											parentField = sectionList[i].fieldList[j].parentField;
											if($A.util.isEmpty(sectionList[i].fieldList[j].picklistValues)) {
												picklistValuesPresent = false;
											}else{
												picklistValuesPresent = true;
											}
										}
									}
								}
								// if field is dependent picklist then validate if its filled out
								if(parentField != '') {
									if(picklistValuesPresent) {
										var errorMessage = cmp.get("v.label") + " is required.";
										component.set("v.showError",true);
										component.set("v.errorMessage",errorMessage);
										event.getSource().set("v.disabled", false);
										window.scroll(0,0);
										allValid = false;
									}else{
										allValid = true;
									}
								}else{
									var errorMessage = cmp.get("v.label") + " is required.";
									component.set("v.showError",true);
									component.set("v.errorMessage",errorMessage);
									event.getSource().set("v.disabled", false);
									window.scroll(0,0);
									allValid = false;
								}
							}
						}
					}
				}
			);
		}
		    
        if (allValid) {
        	// do nothing
		}
		else{
        	return;
		}
		
    if (allValid) {
	    	var mapToSend = {}
			var mapToSend2 = {}
			
	    	var cmpInstance3 = component.find("formField");
	    	if (!cmpInstance3) {
			} 
			else {
		    	[].concat(cmpInstance3).forEach(
		  			cmp => {
		  				if (!cmp.get("v.value")) {
		  					// Do nothing
						}
						else {
							mapToSend2[cmp.get("v.label")] = cmp.get("v.value");
		    			}
		    		}
		    	);
			}

			var cmpDynamicField = component.find("dynamicField");
			
	    	if (!cmpDynamicField) {
			}
			else {
		    	[].concat(cmpDynamicField).forEach(
		  			cmp => {
		  				if (!cmp.get("v.value")) {
		  					// Do nothing
						  }
						  else {
		  					mapToSend[cmp.get("v.label")] = cmp.get("v.value");
		    			}
		    		}
		    	);
			}
		
	    	var cmpStaticField = component.find("staticField");
	    	if (!cmpStaticField) {
			}
			else {
		    	[].concat(cmpStaticField).forEach(
		  			cmp => {
		  				if (!cmp.get("v.value")) {
		  					if (!cmp.get("v.checked")) {
		  						// Do nothing
							}
							else {
		  						mapToSend[cmp.get("v.label")] = cmp.get("v.checked");
		  					}
						}
						else {
		  					mapToSend[cmp.get("v.label")] = cmp.get("v.value");
		    			}
		    		}
		    	);
			}
				
	    	var cmpOtherDependent = component.find("otherDependent");
	    	if (!cmpOtherDependent) {
			}
			else {
		    	[].concat(cmpOtherDependent).forEach(
		  			cmp => {
		  				if (!cmp.get("v.value")) {
		  					// Do nothing
						  }
						  else {
		  					mapToSend[cmp.get("v.label")] = cmp.get("v.value");
		    			}
		    		}
		    	);
			}
			
	    	var cmpInstance4 = component.find("sectionField");
	    	var recordType = '';
	    	if (!cmpInstance4) {
	    		recordType = '';
			}
			else {
	    		[].concat(cmpInstance4).forEach(
		  			cmp => {
		  				if (!cmp.get("v.value")) {
		  					// Do nothing
						}
						else {
		  					recordType = cmp.get("v.value");
                        }
		    		}
	    		);
			}
			
	    	var upsertObject = component.get('c.doUpsertObjects');
	    	var accountId = component.get("v.recordId");
	        upsertObject.setParams({
	            "caseValues" :  mapToSend,
	            "formValues" :  mapToSend2,
	            "fileHolderId" : component.get('v.fileHolderId'),
	            "accountId" : accountId,
	            "formRecordType": recordType
			});
			
	        upsertObject.setCallback(this, function(response) {
	        	var state = response.getState();
	        	if (state == "SUCCESS") {
	        		var navEvt = $A.get("e.force:navigateToSObject");
	        		navEvt.setParams({
	        			"recordId": response.getReturnValue()
	        		});
	        		navEvt.fire();
	        	} else if (state == "ERROR") {
	        		var errors = response.getError();
	        		component.set("v.showError",true);
	        		component.set("v.errorMessage",errors[0].message);
	        		event.getSource().set("v.disabled", false);
					window.scroll(0,0);
	        	}
				this.hideSpinner(component);
			});
			
			this.showSpinner(component);
	        $A.enqueueAction(upsertObject);
        }
    },

	showSpinner : function(component) {
        component.set("v.isSpinning", true);
    },
    
	hideSpinner : function(component) {
		component.set("v.isSpinning", false);
	}
})