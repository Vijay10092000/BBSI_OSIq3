({
	// Set the initial values
	init: function (component, event, helper) {
		helper.setup(component);
	},

	// Erase the current data and file
	clearData : function(component, event, helper) {
		helper.clear(component, true);
	},

	// Read the input file
	readFile : function(component, event, helper) {
		var uploadedFiles = event.getParam("files");
		var documentId = uploadedFiles[0].documentId;

		helper.readFile(component, documentId);
	},

	// Check if have enough for sending the emails
	checkRequired : function(component, event, helper) {
		helper.checkRequired(component);
	},

	handleChangeFolder : function(component, event, helper) {
		var id = component.find("pickFolder").get("v.value");

		helper.readFolder(component, id);
	},

	handleChangePerson : function(component, event, helper) {
		var selectedRows = event.getParam('selectedRows');

    	var currentSelectedRows = [];

		for ( var i = 0; i < selectedRows.length; i++ ) {
			currentSelectedRows.push(selectedRows[i].identifier);
		}

    	component.set("v.selected", currentSelectedRows);

		helper.checkRequired(component);
	},

	// Send the emails
	send : function(component, event, helper) {
		helper.send(component);
	},
})