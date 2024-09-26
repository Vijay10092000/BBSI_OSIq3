({
	onInit: function(component, event, helper) {
		var id = component.get("v.recordId");

		helper.performInit(component, id);
	},

	onSearch : function(component, event, helper) {
		var filter = component.find("filter").get("v.value");
		var selected = component.get("v.selected");

		helper.performSearch(component, filter, selected);
	},

	onOK : function(component, event, helper) {
		var id = component.get("v.recordId");
		var selected = component.get("v.selected");

		helper.performOK(component, id, selected);
	},

	onCancel : function(component, event, helper) {
		helper.performClose();
	},
})