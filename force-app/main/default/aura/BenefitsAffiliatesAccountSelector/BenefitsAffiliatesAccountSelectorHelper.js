({
	///
	/// performInit reads the initial information about the Benefits Affiliate
	/// idRecord is the Benefits Affiliates identifier
	///
	performInit : function(component, idRecord) {
		var callback = function (response) {
			var state = response.getState();

			if (state === "SUCCESS") {
				var result = response.getReturnValue();

				var pickable = [];
				var selected = [];
				var required = [];

				for (var i = 0; i < result.length; i++) {
					pickable.push({
						"label": result[i].label,
						"value": result[i].value
					});

					selected.push(
						result[i].value
					);

					if (result[i].required === true) {
						required.push(result[i].value);
					}
				}

				component.set("v.pickable", pickable);
				component.set("v.selected", selected);
				component.set("v.required", required);
			}
		};

		var action = component.get("c.getSelected");
		action.setCallback(this, callback);
		action.setParam("idRecord", idRecord);

		$A.enqueueAction(action);
	},

	///
	/// performSearch pulls account data based on the filter.
	/// filter is text which is at the start of a client account name
	/// selected is the list of account identifiers currently picked
	///
	performSearch : function(component, filter, selected) {
		var callback = function (response) {
			var state = response.getState();

			if (state === "SUCCESS") {
				var result = response.getReturnValue();

				var pickable = [];

				for (var i = 0; i < result.length; i++) {
					pickable.push({
						"label": result[i].label,
						"value": result[i].value
					});
				}

				component.set("v.pickable", pickable);
			}
		};

		var action = component.get("c.getAccounts");
		action.setCallback(this, callback);
		action.setParam("filter", filter);
		action.setParam("idAccounts", selected);

		$A.enqueueAction(action);
	},

	///
	/// performOK handles the updates and removals the accounts.
	/// idRecord is the Benefits Affiliates identifier
	/// selected is the list of account identifiers currently picked
	///
	performOK : function(component, idRecord, selected) {
		var callback = function (response) {
			var state = response.getState();
			var result = response.getReturnValue();

			if (state === "SUCCESS") {
				if (result === null) {
          $A.get("e.force:closeQuickAction").fire();
					$A.get("e.force:refreshView").fire();
				} else {
					alert('ERROR:' + result);
				}
			}
	};

		var action = component.get("c.setSelected");
		action.setCallback(this, callback);
		action.setParam("idRecord", idRecord);
		action.setParam("idAccounts", selected);

		$A.enqueueAction(action);
	},

	///
	/// performClose closes the dialog
	///
	performClose : function() {
		$A.get("e.force:closeQuickAction").fire();
		$A.get("e.force:refreshView").fire();
	}
})