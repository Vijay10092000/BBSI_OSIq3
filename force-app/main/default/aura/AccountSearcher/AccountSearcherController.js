({
	init: function (component, event, helper) {
		helper.setColumns(component);
	},

	search: function (component, event, helper) {
		helper.searchAccounts(component);
	},

	checkIfEnter: function(component, event, helper) {
		if (event.which == 13) {
			helper.searchAccounts(component);
		}
	}
});