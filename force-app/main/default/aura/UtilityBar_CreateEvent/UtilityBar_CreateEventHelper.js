({
	///
	/// registerUtilityClickHandler sets up a callback when the Event Utility Bar
	/// is clicked.  The callback closes the Event Utility Bar area and starts the
	/// Event creation.
	///
	registerUtilityClickHandler : function(component) {
		var createEvent = function(response) {
			var utilityBar = component.find("utilityBar");
			utilityBar.minimizeUtility();

			var navService = component.find("navService");
	
			var pageReference = {
				"type": "standard__objectPage",
				"attributes": {
					objectApiName: "Event__c",
					actionName: "new"
				},
				"state": {
					count: "1",
					useRecordTypeCheck: 1
				}
			};
			
			navService.navigate(pageReference);			
		}

        var utilityAPI = component.find('utilityBar');

		utilityAPI.getAllUtilityInfo().then(
			function(response) {
				if (typeof response !=='undefined') {
					utilityAPI.getEnclosingUtilityId()
					.then(
						function(utilityId) {
							utilityAPI.onUtilityClick({ 
								eventHandler: createEvent
							})
							.catch(function(error) {
								console.log('EventUtilityBar:getAllUtilityInfo: eventHandler error: ' + error);
							});                    
						}
					)
					.catch(function(error) {
						console.error('EventUtilityBar:getAllUtilityInfo FAILED: ' + error);
					});
				} else {
					console.error('EventUtilityBar:getAllUtilityInfo is undefined');
				}
			}
		);
	},
})