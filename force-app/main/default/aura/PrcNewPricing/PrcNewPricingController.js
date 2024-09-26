({
    init : function(cmp, event, helper) {
        cmp.set("v.scenarioColumns", [
            {label: "Name", fieldName: "Link", type: "url", typeAttributes: {label: { fieldName: "Name" }, target: "_blank"}, cellAttributes: {alignment:"left"}},
            {label: "Create Date", fieldName: "Date", type: "text", initialWidth: 180}, //date-local
            {label: "Del", type: "button", initialWidth: 50, cellAttributes: {alignment:"center"}, typeAttributes: {label: {fieldName: "actionLabel"}, variant:"base", title: "Delete", name: "deleteScenario", iconName: "action:delete"}},
            {label: "Clone", type: "button", initialWidth: 65, cellAttributes: {alignment:"center"}, typeAttributes: {label: {fieldName: "actionLabel"}, variant:"base", title: "Clone", name: "cloneScenario", iconName: "action:clone"}},
        ]);

        cmp.set("v.wcCodeColumns", [
            {label: "State", fieldName: "State", type: "text", cellAttributes: {alignment:"center"}},
            {label: "W/C Code", fieldName: "Code", type: "text", cellAttributes: {alignment:"center"}},
            {label: "Payroll $", fieldName: "PayrollDollars", type: "currency", cellAttributes: {alignment:"right"}},
            {label: "FTE Count", fieldName: "FteCount", type: "number", cellAttributes: {alignment:"right"}, typeAttributes: {minimumFractionDigits: "1", maximumFractionDigits: "1" }},
            {label: "", type: "button", initialWidth: 50, cellAttributes: {alignment:"center"}, typeAttributes: {label: {fieldName: "actionLabel"}, variant:"base", title: "Delete", name: "deleteRow", iconName: "action:delete"}},
        ]);
        helper.loadData(cmp);
    },

    onCreateNewScenario: function (cmp, event, helper) {
        let scenarioName = cmp.get("v.scenarioName");
        if (!scenarioName || scenarioName.length === 0) {
            return helper.showNotice(cmp, "Warning", "Please specify a Scenario Name", "", "");
        }

        let scenarios = cmp.get("v.scenarioData");
        if (scenarios) {
            for (let i = 0; i < scenarios.length; ++i) {
                if (scenarioName.toString().toLowerCase() === scenarios[i].ScenarioName__c.toLowerCase()) {
                    return helper.showNotice(cmp, "Warning", "This Scenario name is already in use, please try again", "", "");
                }
            }
        }

        cmp.set("v.wcCodeData", []);
        let wcMap = cmp.get("v.wcMap");
        if (!wcMap) {
            helper.loadPolicies(cmp);
            helper.loadRates(cmp);
        }
        else {
            helper.createRenewal(cmp);
        }
    },

    onCancelNewPricingDialog: function (cmp, event, helper) {
        cmp.set("v.openNewPricingDialog", false);
    }, 

    onCreateNewPricing: function (cmp, event, helper) {
        cmp.set("v.openNewPricingDialog", false);
        let data = JSON.stringify(cmp.get("v.wcCodeData"));
        helper.createNewPricing(cmp, data);
    },

    onChangeWcPolicy: function (cmp, event, helper) {
        cmp.set("v.wcStates", []);
        cmp.set("v.wcCodes", []);
        cmp.set("v.wcCodeData", []);

        helper.initDataEntry(cmp, event);

        let policy = event.getSource().get("v.value");
        if (policy === "initial") {
            return;
        }
        if (!policy) {
            return helper.showNotice(cmp, "Warning", "Please specify a W/C Policy", "warning", "dismissable");
        }

        let wcMap = cmp.get("v.wcMap");
        let wcStates = [];

        if (policy.length >= 17 && policy.substring(0, 13).toLowerCase() == 'No HRP Policy'.toLowerCase()) {
            let state = policy.substring(15, 17);
            if (!wcMap[policy]) {
                wcStates.push(state);
                cmp.set("v.wcStates", wcStates);
                return helper.loadStateRates(cmp, state);
            }
        }

        if (!wcMap[policy]) {
            return helper.showNotice(cmp, "Warning", "Unable to find WC Codes on the Policy specified", "warning", "dismissable");
        }

        let states = Array.from(Object.entries(wcMap[policy]));
        for(let i = 0; i < states.length; ++i) {
            wcStates.push(states[i][0]);
        }

        cmp.set("v.wcStates", wcStates);
    },

    onChangeWcState: function (cmp, event, helper) {
        cmp.set("v.selectedWcCode", "");
        cmp.set("v.wcCodes", []);

        let state = event.getSource().get("v.value");
        if (state === "initial") {
            return;
        }
        if (!state) {
            return helper.showNotice(cmp, "Warning", "Please specify a State", "warning", "dismissable");
        }

        let wcCodes = [];
        let wcMap = cmp.get("v.wcMap");
        let policy = cmp.get("v.selectedWcPolicy");
        for (let i = 0; i < wcMap[policy][state].length; ++i) {
            let code = wcMap[policy][state][i];
            wcCodes.push({Label: code.Code__c + '-' + code.Rate__c, Policy: code.Policy__c, Code: code.Code__c, Rate: code.Rate__c});
        }
        cmp.set("v.wcCodes", wcCodes);
    }, 

    onChangeWcCode: function (cmp, event, helper) {
        
    },

    onAddNewWorkComp: function (cmp, event, helper) {
        helper.addNewWorkComp(cmp, event);
    },

    handleRowAction: function(cmp, event, helper){
        let action = event.getParam("action");
        let row = event.getParam("row");
        if (action.name === "deleteRow") {
            let wcCodeData = cmp.get("v.wcCodeData");
            for (let i = 0; i < wcCodeData.length; ++i) {
                if (wcCodeData[i].Id === row.Id) {
                    wcCodeData.splice(i, 1);
                }
            }
            cmp.set("v.wcCodeData", wcCodeData);
        }

        if (action.name === "cloneScenario") {
            helper.clonePricingScenario(cmp, row.Name);
        }

        if (action.name === "deleteScenario") {
            helper.deletePricingScenario(cmp, row.Id);
        }
    },
})