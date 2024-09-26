({
	init: function (component, event, helper) {
		helper.init(component);
	},

	createReport : function(component, event, helper) {
		helper.createReport(component);
	},

	createAdvancedReport : function(component, event, helper) {
		helper.createAdvancedReport(component);
		helper.showDialog(component, false);
	},

	handleChangeBranches: function (component, event, helper) {
		helper.changeBranches(component, event);
	},

	handleChangeBDMs: function (component, event, helper) {
		helper.changeBDMs(component, event);
	},

	openDialog : function(component, event, helper) {
		helper.showDialog(component, true);
	},

	closeDialog : function(component, event, helper) {
		helper.showDialog(component, false);
	},
})