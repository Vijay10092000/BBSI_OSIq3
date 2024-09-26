({
	invoke : function(component, event, helper) {
		var navService = component.find("navService");
		var objectName = component.get("v.objectName");
		var recordId = component.get("v.recordId");

		var reference = {
			type: "standard__recordPage",
			attributes: {
				recordId: recordId,
				objectApiName: objectName,
				actionName: "view"
			}
		};

        navService.generateUrl(reference)
			.then(
				$A.getCallback(function (url) {                
					window.open(url, "_self");
				}),
				$A.getCallback(function (error) {
					cmp.set("v.url", "#");
				})
			);
	}
})