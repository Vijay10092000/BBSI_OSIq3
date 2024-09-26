({
    showNotice: function (cmp, title, message, variant, mode){
        cmp.find("notifLib").showNotice({"title": title, "message": message, "variant": variant, "mode": mode});
    }, 

    loadData : function(cmp) {
        this.getProspectClient(cmp);
        this.getPricingScenarios(cmp);
    },

    loadPolicies : function(cmp) {
        let action = cmp.get("c.getPolicies");
        action.setCallback(this, function(response) {
            let state = response.getState();
            if (state === "SUCCESS") {
                cmp.set("v.wcPolicies", response.getReturnValue());
            }
            else {
                if (cmp.get("v.isProspect")) {
                    console.error("Get Work Comp Policies: " + response.getError());
                    this.showToast(cmp, "Sorry to interrupt you", "Unable to get W/C Policies", "error", "sticky");
                }
            }
        });
        $A.enqueueAction(action);
    },

    loadRates: function (cmp) {
        cmp.set("v.isLoading", true);
        let action = cmp.get("c.getWorkCompRateMap");
        action.setCallback(this, function(response) {
            cmp.set("v.isLoading", false);
            let state = response.getState();
            if (state === "SUCCESS") {
                cmp.set("v.wcMap", response.getReturnValue());
                this.createRenewal(cmp);
            }
            else {
                console.error("Get Work Comp Policy Codes and Rates: " + response.getError());
                this.showToast(cmp, "Sorry to interrupt you", "Unable to get W/C Policies with Codes and Rates", "error", "sticky");
            }
        });
        $A.enqueueAction(action);
    },

    loadStateRates: function (cmp, state) {
        cmp.set("v.isLoading", true);
        let action = cmp.get("c.getWorkCompRateByState");
        action.setParams({"state": state});
        action.setCallback(this, function(response) {
            cmp.set("v.isLoading", false);
            let state = response.getState();
            if (state === "SUCCESS") {
                let result = response.getReturnValue();
                let wcMap = cmp.get("v.wcMap");
                let wcStates = cmp.get("v.wcStates");
                if (wcStates.length === 0) {
                    return this.showToast(cmp, "Error: State info is missing from the policy", "Please ", "error", "sticky");
                }
                let wcState = wcStates[0];
                let policy = 'No HRP Policy: ' + wcState;
                wcMap[policy] = result;
            }
            else {
                console.error("Get Work Comp Policy Codes and Rates: " + response.getError());
                this.showToast(cmp, "Sorry to interrupt you", "Unable to get W/C Policies with Codes and Rates", "error", "sticky");
            }
        });
        $A.enqueueAction(action);
    },

    loadPolicyCodeRate : function(cmp) {
        cmp.set("v.isLoading", true);
        let action = cmp.get("c.getWorkCompRateMap");
        action.setCallback(this, function(response) {
            cmp.set("v.isLoading", false);
            let state = response.getState();
            if (state === "SUCCESS") {
                cmp.set("v.wcMap", response.getReturnValue());
                cmp.set("v.openNewPricingDialog", true);
            }
            else {
                cmp.set("v.openNewPricingDialog", false);
                console.error("Get Work Comp Policy Codes and Rates: " + response.getError());
                this.showToast(cmp, "Sorry to interrupt you", "Unable to get W/C Policies with Codes and Rates", "error", "sticky");
            }
        });
        $A.enqueueAction(action);
    },

    getProspectClient: function (cmp) {
        cmp.set("v.isProspect", false);
        let action = cmp.get("c.getProspectClient");
        action.setParams({"opportunityId": cmp.get("v.recordId")});
        action.setCallback(this, function(response) {
            let state = response.getState();
            if (state === "SUCCESS") {
                let client = response.getReturnValue();
                if (client && client.RecordType && client.RecordType.Name) {
                    cmp.set("v.isProspect", response.getReturnValue().RecordType.Name === 'Prospect');
                }
            }
            else {
                console.error("Get Work Comp Policy Codes and Rates: " + response.getError());
                // this.showToast(cmp, "Sorry to interrupt you", "Unable to get Prospect Client", "error", "sticky");
            }
        });
        $A.enqueueAction(action);
    },

    initDataEntry: function (cmp, event) {
        cmp.set("v.selectedWcState", "");
        cmp.set("v.selectedWcCode", "");
        cmp.set("v.payrollDollars", 0);
        cmp.set("v.fteCount", 0);
    },
    
    addNewWorkComp: function (cmp, event) {
        let wcCodeData = cmp.get("v.wcCodeData");
        if (!wcCodeData) { wcCodeData = []; }

        let policy = cmp.get("v.selectedWcPolicy");
        if (!policy || policy === "initial") {
            return this.showNotice(cmp, "Warning", "Please specify a W/C Policy", "warning", "dismissable");
        }

        let state = cmp.get("v.selectedWcState");
        if (!state || state === "initial" || state.length !== 2) {
            return this.showNotice(cmp, "Warning", "Please specify a state", "warning", "dismissable");
        }

        let wcCode = cmp.get("v.selectedWcCode");
        if (!wcCode || wcCode === "initial") {
            return this.showNotice(cmp, "Warning", "Please specify a W/C Code", "warning", "dismissable");
        }

        let payrollDollars = cmp.get("v.payrollDollars");
        if (payrollDollars.toString().length === 0) {
            return;
        }

        let fteCount = cmp.get("v.fteCount");
        if (fteCount.toString().length === 0) {
            return;
        }

        let code = wcCode.substring(0,4);
        let rate = wcCode.substring(5);
        wcCodeData.push({State: state, Code: code, Rate: rate, PayrollDollars: payrollDollars, FteCount: fteCount, Id: new Date().getTime().toString()});
        cmp.set("v.wcCodeData", wcCodeData);

        this.initDataEntry(cmp, event);
    },

    createRenewal: function (cmp) {
        let action = cmp.get("c.createRenewal");
        action.setParams({"opportunityId": cmp.get("v.recordId")});
        action.setCallback(this, function(response) {
            cmp.set("v.isLoading", false);
            let state = response.getState();
            let message = response.getReturnValue();
            if (state === "SUCCESS") {
                cmp.set("v.openNewPricingDialog", true);
            }
            else {
                console.error("Create New Client Pricing: " + response.getError());
                this.showToast(cmp, "Sorry to interrupt you", "Unable to create pricing scenario - " + message, "error", "sticky");
            }
        });
        $A.enqueueAction(action);
    },

    createNewPricing: function (cmp, jsonData) {
        cmp.set("v.isLoading", true);

        if (!jsonData || jsonData === '[]') {
            //MOCK DATA
            let wcCodeData = [];
            wcCodeData.push({Code: '0005', State: 'CA', Rate: 4.5000, FteCount: 0.0, PayrollDollars: 100000});
            wcCodeData.push({Code: '8100', State: 'CA', Rate: 5.5500, FteCount: 1.0, PayrollDollars: 100000});
            jsonData = JSON.stringify(wcCodeData);
            cmp.set("v.selectedWcPolicy", "BBSI");
            //END of MOCK DATA
        }

        let wcMap = cmp.get("v.wcMap");
        let wcPolicy = cmp.get("v.selectedWcPolicy");
        let wcPolicyData = wcMap[wcPolicy];
        let states = Object.keys(wcPolicyData);
        let wcCodes = [];
        for (let i = 0; i < states.length; ++i ) {
            let state = states[i];
            wcCodes.push({"State" : state, "WorkCompRates": wcMap[wcPolicy][state]});
        }

        let action = cmp.get("c.newClientPricingScenario");
        action.setParams({"opportunityId": cmp.get("v.recordId"), "scenarioName": cmp.get("v.scenarioName"), "rows": jsonData, "templateWcCodes": JSON.stringify(wcCodes)});
        action.setCallback(this, function(response) {
            cmp.set("v.isLoading", false);
            cmp.set("v.scenarioName", "");
            let state = response.getState();
            let message = response.getReturnValue();
            if (state === "SUCCESS" && message === "OK") {
                this.getPricingScenarios(cmp);
            }
            else {
                console.error("Create New Client Pricing: " + response.getError());
                this.showToast(cmp, "Sorry to interrupt you", "Unable to create pricing scenario - " + message, "error", "sticky");
            }
        });
        $A.enqueueAction(action);
    },

    getPricingScenarios: function (cmp) {
        let action = cmp.get("c.getPricingScenarios");
        action.setParams({"opportunityId": cmp.get("v.recordId")});
        action.setCallback(this, function(response) {
            let state = response.getState();
            if (state === "SUCCESS") {
                let data = response.getReturnValue();
                for (let i = 0; i < data.length; ++i ) {
                    data[i].Name = data[i].ScenarioName__c;
                    data[i].Link = "/lightning/r/PricingScenario__c/" + data[i].Id + "/view";
                    data[i].Date = $A.localizationService.formatDate(data[i].CreatedDate__c, "MM/dd/yyyy hh:mm a");
                }
                cmp.set("v.scenarioData", data);
            }
            else {
                if (cmp.get("v.isProspect")) {
                    console.error("Get Pricing Scenarios : " + response.getError());
                    this.showToast(cmp, "Sorry to interrupt you", "Unable to get Pricing Scenarios", "error", "sticky");
                }
            }
        });
        $A.enqueueAction(action);
    },

    deletePricingScenario: function (cmp, pricingScenarioId) {
        cmp.set("v.isLoading", true);

        let action = cmp.get("c.deletePricingScenario");
        action.setParams({"pricingScenarioId": pricingScenarioId});
        action.setCallback(this, function(response) {
            cmp.set("v.isLoading", false);
            let state = response.getState();
            if (state === "SUCCESS") {
                this.getPricingScenarios(cmp);
            }
            else {
                console.error("Delete Pricing Scenario: " + response.getError());
                this.showToast(cmp, "Sorry to interrupt you", "Unable to delete Pricing Scenario", "error", "sticky");
            }
        });
        $A.enqueueAction(action);
    },

    clonePricingScenario: function (cmp, scenarioName) {
        cmp.set("v.isLoading", true);

        let cloneScenarioName = 'Copy of ' + scenarioName;
        let action = cmp.get("c.clonePricingScenario");
        action.setParams({"scenarioName": scenarioName, "opportunityId": cmp.get("v.recordId"), "cloneScenarioName": cloneScenarioName});
        action.setCallback(this, function(response) {
            cmp.set("v.isLoading", false);
            if (response.getState() === "SUCCESS" && response.getReturnValue() === "OK") {
                this.getPricingScenarios(cmp);
            }
            else {
                console.error("Clone Pricing Scenario: " + response.getError());
                let errorMessage = "Unable to Clone Pricing Scenario";
                if (response.getReturnValue()) {
                    errorMessage = response.getReturnValue();
                }
                this.showToast(cmp, "Sorry to interrupt you", errorMessage, "error", "sticky");
            }
        });
        $A.enqueueAction(action);
    },

    showToast: function (cmp, title, message, variant, mode){
        cmp.find("notifLib").showToast({"title": title, "message": message, "variant": variant, "mode": mode});
    },

    showNotice: function (cmp, title, message, variant, mode){
        cmp.find("notifLib").showNotice({"title": title, "message": message, "variant": variant, "mode": mode});
    }
})