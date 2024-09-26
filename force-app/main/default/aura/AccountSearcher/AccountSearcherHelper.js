({
	COLUMNS: [
		{
			label: "Name",
			fieldName: "accountName",
			type: "text",
			wrapText: true
		},
		{
			label: "DBA",
			fieldName: "nameDBA",
			type: "text",
			wrapText: true
		},
		{
			label: "Client Id",
			fieldName: "clientId",
			type: "text"
		},
		{
			label: "Branch",
			fieldName: "branchURL",
			type: "url",
			wrapText: true,
			typeAttributes: {
				label: { fieldName: "branchName" },
				target: "_blank"
			}
		},
		{
			label: "Owner",
			fieldName: "ownerContactURL",
			type: "url",
			wrapText: true,
			typeAttributes: {
				label: { fieldName: "ownerName" },
				target: "_blank"
			}
		},
		{
			label: "Payroll Specialist",
			fieldName: "payrollSpecialistURL",
			type: "url",
			wrapText: true,
			typeAttributes: {
				label: { fieldName: "payrollSpecialist" },
				target: "_blank"
			}
		}
	],

	setColumns: function (component) {
		component.set("v.columns", this.COLUMNS);
	},

	searchAccounts: function (component) {
		let searchText = component.get("v.searchText");
		let countAccounts = component.get("v.countAccounts");
		let typeSelection = "ProspectsClientsTerminated";

		let allowSelection = component.get("v.allowTypeSelection");
		if (allowSelection) {
			typeSelection = component.get("v.accountType");
		}

		if (searchText && searchText.length > 0) {
			this.callForAccounts(component, searchText, countAccounts, typeSelection);
		} else {
			component.set("v.listAccounts", null);
			component.set("v.footer", "No search value given");
		}
	},

	callForAccounts: function (component, searchText, countAccounts, typeSelection) {
		component.set("v.isLoading", true);

		let callback = function (response) {
			component.set("v.isLoading", false);

			if (response.getState() === "SUCCESS") {
				component.set("v.listAccounts", response.getReturnValue().accounts);
				component.set("v.footer", response.getReturnValue().footer);
			} else {
				var errors = response.getError();
                if (errors) {
                    if (errors[0] && errors[0].message) {
						component.set("v.footer", "Callout error: " + errors[0].message);
                    }
                } else {
					component.set("v.footer", "Unknown callout error");
                }

				component.set("v.listAccounts", null);
				component.set("v.footer", "FAILURE");
			}
		};

		let action = component.get("c.queryAccounts");

		action.setCallback(this, callback);

		action.setParam("searchText", searchText);
		action.setParam("countAccounts", countAccounts);
		action.setParam("typeSelection", !typeSelection);

		$A.enqueueAction(action);
	}
});