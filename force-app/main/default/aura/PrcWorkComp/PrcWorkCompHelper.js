/*
 * Copyright (c) 2018. Barrett Business Services, Inc. All Rights Reserved
 */
({
    loadData: function(cmp){
        cmp.set("v.isLoading", true);
        let action = cmp.get("c.getPricingWcCodes");
        action.setParams({"recordId":cmp.get("v.clientPricScenId")});
        action.setCallback(this, function(response){
            cmp.set("v.isLoading", false);
            if(response.getState() === "SUCCESS"){
                cmp.set("v.data", response.getReturnValue() );
                this.afterLoadData(cmp);
            }
            else {
                console.error("Get Pricing Scenario: ", response.getError());
            }
        });
        $A.enqueueAction(action);
    },

    afterLoadData: function (cmp){
        // sum values for table footer
        let dataSet = cmp.get("v.data");
        let sumPayInCode = 0;
        let sumPremPayInCode = 0;
        let sumWcPremiums = 0;
        let sumMaxSi = 0;
        for(let i = 0; i < dataSet.length; i++){
            let taxablePayInCode = Number(dataSet[i].AnnualTaxablePayInCode__c);
            sumPayInCode += taxablePayInCode ;
            sumPremPayInCode += Number(dataSet[i].AnnualPremPayInCode__c);
            if (taxablePayInCode != 0) {
                sumWcPremiums += Number(dataSet[i].WcPremiumEquivalent__c);
            }
            if(dataSet[i].SIEligible__c){
                sumMaxSi += Number(dataSet[i].SI_Max__c);
            }
        }
        // set attributes
        cmp.set("v.annualPay", sumPayInCode);
        cmp.set("v.annualPremPay", sumPremPayInCode);
        cmp.set("v.totalWcPremiums", sumWcPremiums);
        cmp.set("v.totalMaxSi", sumMaxSi);
    },

    changeRecordId: function (cmp, event, recId){
        cmp.set("v.clientPricScenId", recId);
        this.loadData(cmp, event);
    },

    saveWcValues: function (cmp, event, wcData){
        cmp.set("v.isLoading", true);
        let action = cmp.get("c.savePricingWcCodes");
        let wcDataJSON = JSON.stringify(wcData);
        action.setParams({"wcCodes": wcDataJSON});
        action.setCallback(this, function (response) {
            if(response.getState() === "SUCCESS"){
                cmp.find("workCompTable").set("v.draftValues", null); // clear the Cancel & Save buttons
                this.fireComponentEvent(cmp, "saveWc", "");
            }else{
                cmp.set("v.isLoading", false);
                this.showToast(cmp, "Sorry to interrupt you", "An error occurred while saving work comp data", "error", "sticky");
            }
        });
        $A.enqueueAction(action);
    },

    setXmodMapValues: function (cmp, event, xmodList){
        let xmodMap = {};
        if(xmodList){
            for (let i = 0; i < xmodList.length; i++) {
                xmodMap[xmodList[i].State_Code__c] = xmodList[i];
            }
        }
        cmp.set("v.xmodMap", xmodMap);
    },

    reconcileAndSaveSiRates: function(cmp, draftValues){
        // User has modified EITHER % of Premium rate
        // OR % of Payroll rate for calculating Max SI.
        // We must "null" the rate that was NOT edited
        // so the parent object will know which one needs
        // to be *recalculated*
        let dataSet = cmp.get("v.data");
        let dataRow = null;
        for (let i = 0; i < draftValues.length; i++) {
            dataRow = null;
            for (let j = 0; j < dataSet.length; j++) {
                if(dataSet[j].Id === draftValues[i].Id){
                    dataRow = dataSet[j];
                    break;
                }
            }
            if (!dataRow) { continue; }
            if (draftValues[i].SI_Percent_of_Premium__c){
                draftValues[i].SI_Percent_of_Payroll__c = 0;
            } else if (draftValues[i].SI_Percent_of_Payroll__c){
                draftValues[i].SI_Percent_of_Premium__c = 0;
            }
        }
        this.saveWcValues(cmp, event, draftValues);
    },

    updateFooterTotals: function (cmp, event, sumData){
        cmp.set("v.annualPay", sumData.YendPayrollTaxable__c);
        cmp.set("v.annualPremPay", sumData.PremiumBasedPayroll__c);
        cmp.set("v.totalWcPremiums", sumData.YendWcPrem__c);
        cmp.set("v.totalMaxSi", sumData.YendMaxSI__c);
    },

    fireComponentEvent : function(cmp, type, data){
        let compName = cmp.get("v.containerName");
        let compEvent = cmp.getEvent("setState");

        compEvent.setParams({
            "newState": {
                "component": compName,
                "type": type,
                "value": data
            }
        });
        compEvent.fire();
    },

    showToast: function (cmp, title, message, variant, mode){
        cmp.find("notifLib").showToast({"title": title, "message": message, "variant": variant, "mode": mode});
    },

    showNotice: function (cmp, title, message, variant, mode){
        cmp.find("notifLib").showNotice({"title": title, "message": message, "variant": variant, "mode": mode});
    },

    openSimpleDelete: function(cmp){
        cmp.set("v.isSimpleDeleteOpen", true);
    },

    closeSimpleDelete: function(cmp){
        cmp.set("v.isSimpleDeleteOpen", false);
        cmp.set("v.row", null);
    },

    openTransferDelete: function(cmp){
        cmp.set("v.isTransferDeleteOpen", true);
    },

    closeTransferDelete: function(cmp){
        cmp.set("v.isTransferDeleteOpen", false);
        cmp.set("v.row", null);
        cmp.set("v.selectedWorkComp", null);
    },

    deleteWorkComp: function (cmp, event){
        let row = cmp.get("v.row");
        if(!row)
        {
            this.showToast(cmp, "Error in finding the work comp.");
            return;
        }

        cmp.set("v.isLoading", true);
        let wc = JSON.stringify(row);
        let action = cmp.get("c.deleteWorkComp");
        action.setParams({"wc": wc});
        action.setCallback(this, function(response){
            cmp.set("v.isLoading", false);
            if(response.getState() === "SUCCESS"){
                this.loadData(cmp, event);
                this.fireComponentEvent(cmp, "deleteWc", "");
            } else {
                this.showToast(cmp,"Sorry to interrupt you", "Unable to delete work comp", "error", "sticky");
            }
            this.closeSimpleDelete(cmp, event);
        });
        $A.enqueueAction(action);
    },

    transferAndDeleteWorkComp: function (cmp){
        let source = cmp.get("v.row");
        let target = cmp.get("v.selectedWorkComp");

        this.closeTransferDelete(cmp);
        if (!source){
            this.showToast(cmp, "Unable to find the work comp to transfer and delete.");
            return;
        }
        if (!target){
            this.showToast(cmp, "Please select (1) Work Comp option to transfer the payroll dollars before deletion.");
            return;
        }
        if(source.Name === target.Name){
            this.showToast(cmp, "Source and target Work Comp codes are equal, please select a different Work Comp code to transfer payroll dollars.")
            return;
        }

        cmp.set("v.isLoading", true);
        let action = cmp.get("c.transferAndDeletePricingWcCode");
        action.setParams({
            "source": JSON.stringify(source),
            "target": JSON.stringify(target)
        });
        action.setCallback(this, function(response){
            if(response.getState() === "SUCCESS"){
                this.fireComponentEvent(cmp, "transferWc", "");
            }
            else{
                cmp.set("v.isLoading", false);
                this.showToast(cmp,"Sorry to interrupt you", "Unable to delete and transfer work comp", "error", "sticky");
            }
        });
        $A.enqueueAction(action);
    },

    getTemplateWorkCompCodes: function (cmp) {
        let wcTemplateRates = cmp.get("v.wcTemplateRates");
        if(!wcTemplateRates || wcTemplateRates.length === 0) {
            cmp.set("v.isLoading", true);
            let action = cmp.get("c.getPricingTemplateWcCodes");
            action.setParams({"recordId":cmp.get("v.clientPricScenId")});
            action.setCallback(this, function(response){
                cmp.set("v.isLoading", false);
                if(response.getState() === "SUCCESS"){
                    let map  = new Map();
                    let templates = response.getReturnValue();
                    for (let i = 0; i < templates.length; ++i) {
                        let key = templates[i].State_Code__c;
                        let value = templates[i];
                        if(key in map) {
                            map[key].push(value);
                        } else {
                            map[key] = [value];
                        }
                    }
                    cmp.set("v.wcTemplateRates", map);
                    this.setupAddWorkComp(cmp);
                    cmp.set("v.showAddWorkComp", true);
                }
                else{
                    this.showToast(cmp, "Sorry to interrupt you", "Unable to find work comp template rates", "error", "sticky");
                }
            });
            $A.enqueueAction(action);
        }
        else {
            this.cancelWorkComp(cmp);
            this.setupAddWorkComp(cmp);
            cmp.set("v.showAddWorkComp", true);
        }
    },

    setupAddWorkComp: function (cmp) {
        let wcTemplateRates = cmp.get("v.wcTemplateRates");
        let states = Object.keys(wcTemplateRates);
        let defaultState = states[0];
        if(states.length === 1) {
            cmp.set("v.initialState", defaultState);
            cmp.set("v.selectedState", defaultState);
            cmp.set("v.wcStates", null);
            cmp.set("v.wcCodes", wcTemplateRates[defaultState]);
        }
        else {
            cmp.set("v.initialState", "Select a state");
            cmp.set("v.wcStates", states);
            cmp.set("v.wcCodes", []);
        }
        cmp.set("v.showAddWorkComp", false);
    },

    addWorkComp: function (cmp, event, state, code, rate, siEligible) {
        cmp.set("v.isLoading", true);
        let action = cmp.get("c.addPricingWcCode");
        action.setParams({
            "recordId": cmp.get("v.clientPricScenId"),
            "state": state,
            "code": code,
            "rate": rate,
            "siEligible": siEligible
        });
        action.setCallback(this, function(response){
            cmp.set("v.isLoading", false);
            this.cancelWorkComp(cmp);
            if(response.getState() === "SUCCESS") {
                this.fireComponentEvent(cmp, "addWc", "");
                this.loadData(cmp);
            }
            else {
                if(response.getError()[0].message === "Error: Add an existing work comp") {
                    this.showToast(cmp, "Sorry to interrupt you", "Unable to add an existing Work Comp", "error", "sticky");
                }
                else {
                    this.showToast(cmp, "Sorry to interrupt you", "Unable to add a new Work Comp", "error", "sticky");
                }
            }
        });
        $A.enqueueAction(action);
    },

    cancelWorkComp: function (cmp) {
        cmp.set("v.showAddWorkComp", false);
        cmp.set("v.siEligible", false);
        cmp.set("v.selectedState", "");
        cmp.set("v.selectedWcCode", "");
        cmp.set("v.selectedWcRate", "");
        cmp.set("v.wcCodes", []);
    }
});