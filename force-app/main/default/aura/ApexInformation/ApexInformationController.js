({
	init: function (component, event, helper) {
		helper.setColumns(component);
	},

	refresh: function (component, event, helper) {
		helper.setData(component);
	},

	toCsv: function (component, event, helper) {
		var listRecords = component.get("v.records");
		var textCSV = helper.convertListToCsvText(listRecords);
		helper.writeCsvFile(textCSV);
	},

	handleSort: function (component, event, helper) {
		var sortBy = event.getParam("fieldName");
		var sortDirection = event.getParam("sortDirection");

		component.set("v.sortBy", sortBy);
		component.set("v.sortDirection", sortDirection);

		helper.sort(component, sortBy, sortDirection);
	}
});