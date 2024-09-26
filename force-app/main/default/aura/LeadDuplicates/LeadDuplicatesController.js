({
	onInit : function(component, event, helper) {
		var idLead = component.get("v.recordId");

		helper.callInitialize(component, idLead);
	},

	onRefresh : function(component, event, helper) {
		var idLead = component.get("v.recordId");

		helper.callInitialize(component, idLead);
	},
})