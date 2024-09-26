({
    setup : function(component) {
		var recordId = this.readRecordId(component);

		component.set("v.idRecord", recordId);

        var action = component.get("c.setup");        
		action.setParam("idRecord", recordId);

		action.setCallback(this,
			function (response) {
				component.set("v.isSpinning", false);
				component.set("v.error", null);

				if (response.getState() === "SUCCESS") {
                   var result = response.getReturnValue();

					var all = result['optionsAll'];
					var selected = result["optionsSelected"];

					component.set("v.title", result["title"]);
					component.set("v.typeRecord", result["typeRecord"]);
					component.set("v.nameRecord", result["nameRecord"]);
					component.set("v.listOptions", all);
					component.set("v.defaultOptions", selected);

					component.set("v.selectedOptions", selected);
				} else {
					var errorMessage = "Failed to initialize component";
					var errors = response.getError();

					if (errors) {
						if (errors[0] && errors[0].message) {
							errorMessage = errors[0].message;
						}
					}

					component.set("v.error", "<b>ERROR: </b> " + errorMessage);
				}
			}
		);

		component.set("v.isSpinning", true);
		$A.enqueueAction(action);
    },

    shutdown : function (component) {
		var idRecord = component.get("v.idRecord");

		var pageReference = {
			type: 'standard__recordPage',
			attributes: {
				recordId: idRecord,
				actionName: 'view'
			}
		};

		var navService = component.find("serviceNAV");
		navService.navigate(pageReference);
	},

    save : function (component) {
		var recordId = component.get("v.idRecord");

        var selected = component.get("v.selectedOptions");

		var action = component.get("c.onSave");
		action.setParam("idRecord", recordId);      
		action.setParam("idPlans", selected);

		action.setCallback(this,
			function (response) {
				component.set("v.isSpinning", false);
				component.set("v.error", null);
				component.set("v.fileError", null);

				var idRecord = component.get("v.idRecord");

				var pageReference = {
					type: 'standard__recordPage',
					attributes: {
						recordId: idRecord,
						actionName: 'view'
					}
				};

				var navService = component.find("serviceNAV");
				navService.navigate(pageReference);
			}
		);

		component.set("v.isSpinning", true);
		$A.enqueueAction(action);
    },

	readRecordId : function(component) {		
		var ref = component.get("v.pageReference");
		var state = ref.state; 
		var context = state.inContextOfRef;

		if (context.startsWith("1\.")) {
			context = context.substring(2);

			var addressableContext = JSON.parse(window.atob(context));

			return addressableContext["attributes"]["recordId"];
		}

		return "";
	}
})