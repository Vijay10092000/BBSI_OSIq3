({
    callInitialize : function(component, idLead) {
		var action = component.get("c.getDuplicates");

		action.setParams({ "idLead": idLead });

		action.setCallback(this, function(response) {
			var state = response.getState();
			var dups = null;
			var count = 0;
			var numFound = "";

			if (state === "SUCCESS") {
				dups = response.getReturnValue();
				component.set("v.duplicates", dups);
				count = dups.length;

				if (500 <= count) {
					numFound = "500+";
				} else if (1 < count) {
					numFound = "" + count;
				} else {
					numFound = "0";
				}
			}
			else {
				console.error(response.error);
				component.set("v.duplicates", null);
				numFound = "Failed to retrieve duplicates";
			}

			var title = "Possible Duplicates (" + numFound + ")";

			component.set("v.title", title);
			component.set("v.showTable", (0 < count));

			component.set("v.isLoading", false);
		});

		component.set("v.isLoading", true);
		$A.enqueueAction(action);
    }
})