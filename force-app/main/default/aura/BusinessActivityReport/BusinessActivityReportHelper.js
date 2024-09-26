({
	init : function(component) {
		component.set("v.isSpinning", true);

		let callback = function (response) {
			component.set("v.isSpinning", false);
			component.set("v.header", null);

			if (response.getState() === "SUCCESS") {
				let result = response.getReturnValue();

				component.set("v.userName", result["userName"]);
				component.set("v.userId", result["userId"]);
				component.set("v.selectedAdvYear", result["year"]);
				component.set("v.selectedAdvQuarter", result["quarter"]);
				component.set("v.isBDM", result["isBDM"]);
				component.set("v.allowSelection", result["allowSelection"]);
				component.set("v.optionBDMs", result["optionBDMs"]);
				component.set("v.optionBranches", result["optionBranches"]);
				component.set("v.optionYears", result["optionYears"]);
				component.set("v.optionQuarters", result["optionQuarters"]);
				component.set("v.optionAdvBDMs", result["optionAdvBDMs"]);
				component.set("v.optionAdvBranches", result["optionAdvBranches"]);
				component.set("v.selectedAdvBDMs", result["selectedAdvBDMs"]);
				component.set("v.sssBDMs", result["selectedAdvBDMs"]);
				component.set("v.selectedAdvBranches", result["selectedAdvBranches"]);
				component.set("v.sssBranches", result["selectedAdvBranches"]);
				component.set("v.allBDMs", result["allBDMs"]);
				component.set("v.allBranches", result["allBranches"]);

				if (result.isBDM) {
					component.set("v.pickBDM", result.userId);
				}
			} else {
				let errorMessage = "Failed to initialize";
				let errors = response.getError();

				if (errors) {
					if (errors[0] && errors[0].message) {
						errorMessage = errors[0].message;
					}
				}

				component.set("v.header", "<b>ERROR: </b> " + errorMessage);
			}
		};

		let action = component.get("c.setup");
		action.setCallback(this, callback);
		$A.enqueueAction(action);
	},

	showDialog : function(component, visible) {
		component.set("v.header", null);
		component.set("v.isModalOpen", visible);
	},

	callCreateReport : function(component, filename, idBDMs, idBranches, year, quarter, includeAllRecords, includeAllBDMs, includeAllBranches) {
		/* Used for debugging.
		alert(
			"callCreateReport" +
			"\nFilename: " + filename +
			"\nYear: " + year +
			"\nQuarter: " + quarter +
			"\nBDM Ids: " + idBDMs +
			"\nBranches Ids: " + idBranches +
			"\nInclude 'All Records'? " + includeAllRecords +
			"\nInclude 'All BDMs'? " + includeAllBDMs +
			"\nInclude 'All Branches'? " + includeAllBranches
		);
		*/

		component.set("v.isSpinning", true);

		let callback = function (response) {
			component.set("v.isSpinning", false);

			if (response.getState() === "SUCCESS") {
				let link = document.createElement("a");
				link.href = "data:application/vnd.ms-excel;charset=utf-8," + escape(response.getReturnValue());
				link.download = filename;
				link.click();

				component.set("v.header", null);
			} else {
				let errorMessage = "Failed to write the file.";
				let errors = action.getError();

				if (errors) {
					if (errors[0] && errors[0].message) {
						errorMessage = errors[0].message;
					}
				}

				component.set("v.header", "<b>ERROR:</b> " + errorMessage);
			}
		};

		let action = component.get("c.buildReport");
		action.setCallback(this, callback);
		action.setParam("idBDMs", idBDMs);
		action.setParam("idBranches", idBranches);
		action.setParam("year", year);
		action.setParam("quarter", quarter);
		action.setParam("includeAllRecords", includeAllRecords);
		action.setParam("includeAllBDMs", includeAllBDMs);
		action.setParam("includeAllBranches", includeAllBranches);

		$A.enqueueAction(action);
	},

	createReport : function(component) {
		var idBDM;
		let pickBDM = component.find("pickBDM");
		if (pickBDM == null) {
			idBDM = component.get("v.userId");
		} else {
			idBDM = pickBDM.get("v.value");
		}

		if (idBDM) {
			let idBranches = component.get("v.allBranches");
			let options = component.get("v.optionBDMs");
			let index = options.findIndex(item => item.value == idBDM);
			let nameBDM = (index >= 0) ? options[index].label : "";
			let year = component.find("pickYear").get("v.value");
			let quarter =  component.find("pickQuarter").get("v.value");

			let filename = nameBDM.replace(/\s/g, "-") + "__BusinessActivityReport_" + year;
			if (quarter == 0) {
				filename = filename + "FullYear.xls";
			} else {
				filename = filename + "Q" +  quarter + ".xls";
			}

			this.callCreateReport(component, filename, idBDM, idBranches, year, quarter, false, false, true);
		} else {
			component.set("v.header", "Please select a BDM");
		}
	},

	createAdvancedReport : function(component) {
		let year = component.find("advpickYear").get("v.value");
		let quarter =  component.find("advpickQuarter").get("v.value");

		let filename = "BusinessActivityReport_" + year;
		if (quarter == 0) {
			filename = filename + "FullYear.xls";
		} else {
			filename = filename + "Q" +  quarter + ".xls";
		}

		let idBDMs;
		let selectBdms = component.find("selectBDMs");
		if (selectBdms) {
			idBDMs = selectBdms.get("v.value");
		} else {
			idBDMs = [ component.get("v.userId") ];
		}

		let includeAllBDMs = idBDMs.includes("0");
		let includeAllRecords = idBDMs.includes("1");

		if (includeAllRecords) {
			idBDMs = component.get("v.allBDMs");
		}

		let idBranches = component.find("selectBranches").get("v.value");
		let includeAllBranches = idBranches.includes("0");

		if (includeAllBranches) {
			idBranches = component.get("v.allBranches");
		}

		this.callCreateReport(component, filename, idBDMs, idBranches, year, quarter, includeAllRecords, includeAllBDMs, includeAllBranches);
	},

	changeBranches: function(component, event) {
		let branches = component.find("selectBranches").get("v.value");
		let selectedBranchs = component.get("v.sssBranches");

		let oldIndexAll = selectedBranchs.indexOf("0");
		let oldLength = selectedBranchs.length;

		let newIndexAll = branches.indexOf("0");
		let newLength = branches.length;

		if (oldIndexAll == -1) {
			if (newIndexAll > -1) {
				// Old did not have "All Branches", but new does
				branches = ["0"];
				component.find("selectBranches").set("v.value", branches);
			}
		} else if (oldIndexAll > -1) {
			if (newLength > 1) {
				// Old has "All Branches" and new has more values
				branches.splice(oldIndexAll, 1);
				component.find("selectBranches").set("v.value", branches);
			}
		}

		component.set("v.sssBranches", branches);
	},

	changeBDMs: function(component, event) {
		let bdms = component.find("selectBDMs").get("v.value");
		let selectedBDMs = component.get("v.sssBDMs");

		let oldIndexAllBDMs = selectedBDMs.indexOf("0");
		let oldIndexAllRecords = selectedBDMs.indexOf("1");

		let newIndexAllBDMs = bdms.indexOf("0");
		let newIndexAllRecords = bdms.indexOf("1");
		let newLength = bdms.length;

		/* Used for debugging.
		alert(
			"oldIndexAllBDMs: " + oldIndexAllBDMs +
			"\oldIndexAllRecords: " + oldIndexAllRecords
		);
		alert(
			"newIndexAllBDMs: " + newIndexAllBDMs +
			"\nnewIndexAllRecords: " + newIndexAllRecords +
			"\nnewLength: " + newLength +
			"\nbdms: " + bdms
		);
		*/

		if (oldIndexAllBDMs == -1) {
			if (newIndexAllBDMs > -1) {
				// Old did not have "All BDMs", but new does
				bdms = ["0"];
				component.find("selectBDMs").set("v.value", bdms);
			}
		} else if (oldIndexAllBDMs > -1) {
			if (newIndexAllRecords > -1) {
				// Old has ALL BDMS and new has ALL Records
				bdms = ["1"];
				component.find("selectBDMs").set("v.value", bdms);
			} else {
				// Old has "All BDMs" and new has more values
				bdms.splice(oldIndexAllBDMs, 1);
				component.find("selectBDMs").set("v.value", bdms);
			}
		}

		if (oldIndexAllRecords == -1) {
			if (newIndexAllRecords > -1) {
				// Old did not have "All BDMs", but new does
				bdms = ["1"];
				component.find("selectBDMs").set("v.value", bdms);
			}
		} else if (oldIndexAllRecords > -1) {
			if (newIndexAllBDMs > -1) {
				// Old has ALL RECORDS and new has ALL BDMs
				bdms = ["0"];
				component.find("selectBDMs").set("v.value", bdms);
			} else {
				// Old has "All RECORDS" and new has more values
				bdms.splice(oldIndexAllRecords, 1);
				component.find("selectBDMs").set("v.value", bdms);
			}
		}

		component.set("v.sssBDMs", bdms);
	},
})