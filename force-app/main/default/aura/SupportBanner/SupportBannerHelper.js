({
	getBannerSupportSetting : function(component, event, helper) {
		var settings = component.get("c.getBannerSettings");
        
        settings.setCallback(this, function(response) {

	        var state = response.getState();

	        if (component.isValid() && state == 'SUCCESS') {               
                var results = response.getReturnValue()
                component.set("v.settingsMap", results);
                console.log('setting: ' + results);
	        } else {
	            console.log('Failed with state: ' + state);
	        }
	    });

	    $A.enqueueAction(settings);
	}
})