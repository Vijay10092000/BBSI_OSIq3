({
	COLUMNS: [
		{
			label: "Namespace",
			fieldName: "namespace",
			type: "text",
			sortable: true,
			initialWidth:120
		},
		{
			label: "Name",
			fieldName: "link",
			type: "url",
			sortable: true,
			typeAttributes: {
				label: { fieldName: "name" },
				target: "_blank",
			}
		},
		{ 
			label: "Type", 
			fieldName: "type", 
			type: "text", 
			sortable: true,
			initialWidth:80
		},
		{
			label: "Coverage",
			fieldName: "textPercentLineCoverage",
			type: "String",
			sortable: true,
			initialWidth:100,
			cellAttributes: { alignment: 'center' },
		},
		{
			label: "API Version",
			fieldName: "apiVersion",
			type: "text",
			sortable: true,
			initialWidth:110,
			cellAttributes: { alignment: 'center' },
		},
	],
	    
    setColumns: function(cmp) {
        cmp.set('v.columns', this.COLUMNS);
    },

	setData: function (component) {
		component.set("v.isLoading", true);

		let action = component.get("c.getData");

		action.setCallback(this, function (response) {
			if (response.getState() === "SUCCESS") {
				let results = response.getReturnValue();
				
				component.set("v.records", results.listAllFiles);
		
				component.set(
					"v.header", 
					"Classes: <b>" + results.totalClasses + "</b>" +
					"&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;Triggers: <b>" + results.totalTriggers + "</b>" +
					"&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;Overall Coverage: <b>" + results.textTotalPercentCoverage + "%</b>" + 
					"&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;Character Usage: <b>" + results.totalCharactersUsed + "</b> of 6000000 (" + results.textPercentCharactersUsed + "%)"
				);
		
				component.set(
					"v.footer", 
					"<b>WARNING:</b> Coverage percentages may be inaccurate." +
					"&nbsp;&nbsp;For best results run all tests with Code Coverage before reviewing this table."
				);
			} else {
				component.set("v.records", null);
				component.set("v.header", "<b>ERROR:</b> Failed to read the Apex Class and Trigger data.");
				component.set("v.footer", "");
			}

			component.set("v.isLoading", false);
		});

		$A.enqueueAction(action);
	},

	sort: function (component, fieldName, direction) {
		if (fieldName == "link") {
			fieldName = "name";
		}

		var dir = (direction == "asc") ? 1 : -1;
		var records = component.get("v.records");

		records.sort(
			function (a, b) {
				return dir * ((a[fieldName] > b[fieldName]) - (b[fieldName] > a[fieldName]));
			}
		);

		component.set("v.records", records);
	},

	convertListToCsvText: function (listObjects) {
		if (listObjects == null || listObjects.length == 0) {
			return null;
		}

		// CSV file parameters.
		var columnEnd = ",";
		var lineEnd = "\n";

		// Get the CSV header from the list.
		var keys = new Set();
		listObjects.forEach(function (record) {
			Object.keys(record).forEach(function (key) {
				keys.add(key);
			});
		});

		keys = Array.from(keys);

		var textCSV = "";
		textCSV += keys.join(columnEnd);
		textCSV += lineEnd;

		for (var i = 0; i < listObjects.length; i++) {
            var columns = [];

			for (var sTempkey in keys) {
				var skey = keys[sTempkey];

				var value = listObjects[i][skey];

                if (value === undefined || value == null) {
					value = "";
                }

                columns.push('"' + value + '"');
			}

			textCSV += columns.join(columnEnd);
            textCSV += lineEnd;
		}

		return textCSV;
	},
	
	writeCsvFile: function(textCSV) {
		// This code may not work on all browsers
		if (textCSV != null) {
			var downloadLink = document.createElement('a');
			downloadLink.href = "data:text/csv;charset=utf-8," + encodeURI(textCSV);
			downloadLink.target = "_self";
			downloadLink.download = "ApexInformation.csv";
			document.body.appendChild(downloadLink);
			downloadLink.click();
			
			$A.get('e.force:refreshView').fire();
		}
	},
});