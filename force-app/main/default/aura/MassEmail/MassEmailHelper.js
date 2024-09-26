({
	// setup - Retrieve the initial information.
	//
	setup : function(component) {
		var action = component.get("c.setup");

		action.setCallback(this,
			function (response) {
				component.set("v.isSpinning", false);
				component.set("v.header", null);
				component.set("v.fileError", null);

				if (response.getState() === "SUCCESS") {
					var result = response.getReturnValue();

					component.set("v.optionFolders", result.optionFolders);
				} else {
					var errorMessage = "Failed to initialize component";
					var errors = response.getError();

					if (errors) {
						if (errors[0] && errors[0].message) {
							errorMessage = errors[0].message;
						}
					}

					component.set("v.header", "<b>ERROR: </b> " + errorMessage);
				}
			}
		);

		component.set("v.isSpinning", true);
		$A.enqueueAction(action);
	},

	// readFolder reads the list of email templates in a folder.
	//
	readFolder : function(component, idFolder) {
		var action = component.get("c.readFolder");

		action.setParam("idFolder", idFolder);
		action.setCallback(this,
			function (response) {
				component.set("v.isSpinning", false);
				component.set("v.header", null);
				component.set("v.fileError", null);

				if (response.getState() === "SUCCESS") {
					var result = response.getReturnValue();

					component.set("v.optionTemplates", result.optionTemplates);
					this.checkRequired(component);
				} else {
					var errorMessage = "Failed to read the folder";
					var errors = response.getError();

					if (errors) {
						if (errors[0] && errors[0].message) {
							errorMessage = errors[0].message;
						}
					}

					component.set("v.fileError", "<b>ERROR: </b> " + errorMessage);
				}
			}
		);

		component.set("v.isSpinning", true);
		$A.enqueueAction(action);
	},

	// readFile reads the list of accounts or contact emails from the given file.
	//
	readFile : function(component, idFile) {
		component.set("v.fileId", idFile);

		var action = component.get("c.readData");

		action.setParam("idFile", idFile);
		action.setCallback(this,
			function (response) {
				component.set("v.isSpinning", false);
				component.set("v.header", null);
				component.set("v.fileError", null);

				if (response.getState() === "SUCCESS") {
					var result = response.getReturnValue();

					var type = result.typeFile;
					component.set("v.fileDataType", type);

					var persons = result.persons;
					var selected = [];

					var count = persons.length;

					var identifier;
					for (var i = 0; i < count; ++i) {
						if (persons[i].allowSend) {
							identifier = persons[i].identifier;
							selected.push( identifier );
						}
					}

					component.set("v.clientData", persons);
					component.set("v.selected", selected);
					component.set("v.showFilePicker", false);

					this.checkRequired(component);
				} else {
					var errorMessage = "Failed to read the file";
					var errors = response.getError();

					if (errors) {
						if (errors[0] && errors[0].message) {
							errorMessage = errors[0].message;
						}
					}

					component.set("v.fileError", "<b>ERROR: </b> " + errorMessage);
				}
			}
		);

		component.set("v.isSpinning", true);
		$A.enqueueAction(action);
	},

	// send sends emails to the selected people.
	//
	send : function(component) {
		var idFile = component.get("v.fileId");
		var idTemplate = component.get("v.selectedTemplate");
		var clientData = component.get("v.clientData");
		var selected = component.get("v.selected");
		var sender = component.get("v.sender");
		var fileDataType = component.get("v.fileDataType");
		var carbonCopy = component.get("v.selectedCC");
		var task = component.get("v.selectedTask");

		var action = component.get("c.sendEmails");

		action.setParam("action", "NO ACTION");
		action.setParam("idFile", idFile);
		action.setParam("idTemplate", idTemplate);
		action.setParam("persons", clientData);
		action.setParam("selected", selected);
		action.setParam("typeFile", fileDataType);
		action.setParam("sender", sender);
		action.setParam("carbonCopy", carbonCopy);
		action.setParam("typeTask", task);

		action.setCallback(this,
			function () {
				component.set("v.isSpinning", false);
				this.clear(component, false);

				// TODO: LATER: Fire an event
				window.location.reload();
			}
		);

		component.set("v.isSpinning", true);
		$A.enqueueAction(action);
	},

	clear : function(component, removeFile) {
		if (removeFile === true) {
			this.deleteFile(component);
		}

		var emptyList = [];

		component.set("v.header", null);

		component.set("v.isSpinning", false);

		component.set("v.selectedFolder", "");
		component.set("v.selectedTemplate", "");

		component.set("v.clientData", emptyList);
		component.set("v.selectedPersonIds", emptyList);

		component.set("v.sender", "");
		component.set("v.selectedCC", "");
		component.set("v.haveRequired", false);

		component.set("v.fileId", "");
		component.set("v.fileError", null);
		component.set("v.showFilePicker", true);
		component.set("v.selected", "[]");
	},

	// deleteFile deletes the current file
	//
	deleteFile : function(component) {
		var fileId = component.get("v.fileId");

		if (fileId) {
			var action = component.get("c.deleteFile");

			action.setParam("idFile", fileId);

			action.setCallback(this,
				function () {
					component.set("v.isSpinning", false);
				}
			);

			component.set("v.isSpinning", true);
			$A.enqueueAction(action);
		}
	},

	// checkRequired determines if there is enough information to send email(s).
	//
	checkRequired : function(component) {
		var haveTemplate = Boolean(component.get("v.selectedTemplate"));
		var haveSender = Boolean(component.get("v.sender"));
		var selectedPersonIds = component.get("v.selected");
		var haveSelectedPersons = (selectedPersonIds && 0 < selectedPersonIds.length);

		// alert("haveTemplate: " + haveTemplate + "\nhaveSender: " + haveSender + "\nhaveSelectedPersons: " + haveSelectedPersons);

		component.set("v.haveRequired", haveTemplate && haveSender && haveSelectedPersons);
	},
})