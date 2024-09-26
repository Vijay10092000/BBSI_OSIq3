/*
 * Copyright (c) 2018. Barrett Business Services, Inc. All Rights Reserved
 */
({
    loadData: function(cmp, event){
        cmp.set("v.isLoading", true);
        this.loadNonProfit(cmp, event);
        this.loadFed(cmp, event);
        this.loadStateAndOthers(cmp, event);
        // cmp.set("v.isLoading", false);
    },

    loadNonProfit: function(cmp, event) {
        var action = cmp.get("c.getClientPricingScenario");
        action.setParams({"recordId": cmp.get("v.clientPricScenId")});
        action.setCallback(this, function (data) {
            if (data.getState() === "SUCCESS") {
                cmp.set("v.nonProfit", data.getReturnValue().Non_Profit__c);
            } else {
                this.showToast(cmp, "Sorry to interrupt you", "An error occurred while loading the Non-Profit info", "error", "sticky");
            }
        });
        $A.enqueueAction(action);
    },

    loadFed: function(cmp, event){
        var action = cmp.get("c.getPricingFederalTaxes");
        action.setParams({"recordId":cmp.get("v.clientPricScenId")});
        action.setCallback(this, function(response) {
            var state = response.getState();
            if(state === "SUCCESS"){
                cmp.set("v.fedData", response.getReturnValue());
            }else{
                this.showToast(cmp, "Sorry to interrupt you", "An error occurred while loading Tax Rate data", "error", "sticky");
            }
        });
        $A.enqueueAction(action);
    },

    loadStateAndOthers: function(cmp, event){
        var action = cmp.get("c.getPricingStateAndOthersTaxes");
        action.setParams({"recordId":cmp.get("v.clientPricScenId")});
        action.setCallback(this, function(response) {
            cmp.set("v.isLoading", false);
            var state = response.getState();
            if(state === "SUCCESS"){
                cmp.set("v.stateAndOthersData", response.getReturnValue());
            }else{
                this.showToast(cmp, "Sorry to interrupt you", "An error occurred while loading Tax Rate data", "error", "sticky");
            }
        });
        $A.enqueueAction(action);
    },

    saveTaxValues: function (cmp, event, taxData){
        cmp.set("v.isLoading", true);
        var action = cmp.get("c.savePricingTaxes");
        var taxDataJSON = JSON.stringify(taxData);
        action.setParams({"taxes": taxDataJSON});
        action.setCallback(this, function (response) {
            cmp.set("v.isLoading", false);
            if(response.getState() === "SUCCESS"){
                cmp.set("v.isLoading", false);
                this.clearChanges(cmp, event);
                this.fireComponentEvent(cmp, "dataSaved", "");
                this.loadData(cmp, event);
            }else{
                this.showToast(cmp, "Sorry to interrupt you", "An error occurred while modifying State and Local tax item(s)", "error", "sticky");
            }
        });
        $A.enqueueAction(action);
    },

    clearChanges: function (cmp, event) {
        // clear the Cancel & Save buttons
        cmp.find("fedTaxesTable").set("v.draftValues", null);
        cmp.find("otherTaxesTable").set("v.draftValues", null);
    },

    changeRecordId: function (cmp, event, recId) {
        cmp.set("v.clientPricScenId", recId);
        this.loadData(cmp, event);
    },

    initNewTax: function (cmp, event){
        var dataSet = cmp.get("v.stateAndOthersData");
        if (dataSet.length === 0) {
            dataSet = cmp.get("v.fedData");
        }
        var newTax = dataSet[0];
        newTax.Id = null;
        newTax.Limit__c = 0;
        newTax.Non_Profit__c = false;
        newTax.PrimaryPricingWcCode__c = "";
        newTax.State_Code__c = "";
        newTax.Rate__c = 0;
        newTax.IsOwner__c = false;
        newTax.Tax_Type__c = "";
        cmp.set("v.newTaxItem", newTax);
    },

    saveNewTaxItem: function (cmp, event, newTax){
        var action = cmp.get("c.addTaxItem");
        action.setParams({
            "newTaxItem":newTax
        });
        action.setCallback(this, function(response) {
            var state = response.getState();
            cmp.set("v.isShowingAddform", false);
            if(state === "SUCCESS"){
                this.fireComponentEvent(cmp, "dataSaved", "");
                this.loadData(cmp, event);
            } else{
                this.showToast(cmp, "Sorry to interrupt you", "Unable to save new tax item", "error", "sticky");
            }
        });
        $A.enqueueAction(action);
    },

    deleteTaxItem : function(cmp, event, row) {
        var taxToDel = JSON.stringify(row);
        var action = cmp.get("c.deleteTaxItem");
        action.setParams({"taxToDelete": taxToDel});
        action.setCallback(this, function(response) {
            var state = response.getState();
            if(state === "SUCCESS"){
                // reload data
                this.fireComponentEvent(cmp, "dataSaved", "");
                this.loadData(cmp, event);
            } else{
                this.showToast(cmp,"Sorry to interrupt you", "Unable to delete tax", "error", "sticky");
            }
        });
        $A.enqueueAction(action);
    },

    initStateCodes: function(cmp, event) {
        var stateCodes = [{"stateCode":"AL","label":"Alabama"},{"stateCode":"AK","label":"Alaska"},{"stateCode":"AZ","label":"Arizona"},{"stateCode":"AR","label":"Arkansas"},{"stateCode":"CA","label":"California"},{"stateCode":"CO","label":"Colorado"},{"stateCode":"CT","label":"Connecticut"},{"stateCode":"DE","label":"Delaware"},{"stateCode":"DC","label":"District of Columbia"},{"stateCode":"FL","label":"Florida"},{"stateCode":"GA","label":"Georgia"},{"stateCode":"HI","label":"Hawaii"},{"stateCode":"ID","label":"Idaho"},{"stateCode":"IL","label":"Illinois"},{"stateCode":"IN","label":"Indiana"},{"stateCode":"IA","label":"Iowa"},{"stateCode":"KS","label":"Kansas"},{"stateCode":"KY","label":"Kentucky"},{"stateCode":"LA","label":"Louisiana"},{"stateCode":"ME","label":"Maine"},{"stateCode":"MT","label":"Montana"},{"stateCode":"NE","label":"Nebraska"},{"stateCode":"NV","label":"Nevada"},{"stateCode":"NH","label":"New Hampshire"},{"stateCode":"NJ","label":"New Jersey"},{"stateCode":"NM","label":"New Mexico"},{"stateCode":"NY","label":"New York"},{"stateCode":"NC","label":"North Carolina"},{"stateCode":"ND","label":"North Dakota"},{"stateCode":"OH","label":"Ohio"},{"stateCode":"OK","label":"Oklahoma"},{"stateCode":"OR","label":"Oregon"},{"stateCode":"MD","label":"Maryland"},{"stateCode":"MA","label":"Massachusetts"},{"stateCode":"MI","label":"Michigan"},{"stateCode":"MN","label":"Minnesota"},{"stateCode":"MS","label":"Mississippi"},{"stateCode":"MO","label":"Missouri"},{"stateCode":"PA","label":"Pennsylvania"},{"stateCode":"RI","label":"Rhode Island"},{"stateCode":"SC","label":"South Carolina"},{"stateCode":"SD","label":"South Dakota"},{"stateCode":"TN","label":"Tennessee"},{"stateCode":"TX","label":"Texas"},{"stateCode":"UT","label":"Utah"},{"stateCode":"VT","label":"Vermont"},{"stateCode":"VA","label":"Virginia"},{"stateCode":"WA","label":"Washington"},{"stateCode":"WV","label":"West Virginia"},{"stateCode":"WI","label":"Wisconsin"},{"stateCode":"WY","label":"Wyoming"}];
        cmp.set("v.stateCodes", stateCodes);
        cmp.set("v.taxTypes", [{"type" : "LOCAL"}, {"type" : "OTHER"}]);
    },

    updateFooterTotals: function (cmp, event, sumData) {
        cmp.set("v.taxBurdenPercent", sumData.YendTaxBurden_Percent__c);
        cmp.set("v.taxBurdenPercentNoOwner", sumData.YendTaxBurden_PercentNo1k__c);
    },

    fireComponentEvent : function(cmp, type, data) {
        var compName = cmp.get("v.containerName");
        var compEvent = cmp.getEvent("setState");
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
        // variants: info, success, warning, error
        // modes; dismissable, pester, sticky
        cmp.find("notifLib").showToast({
            "title": title,
            "message": message,
            "variant": variant,
            "mode": mode
        });
    },

    saveNonProfit: function (cmp, nonProfit) {
        this.fireComponentEvent(cmp, "nonProfit", nonProfit);
    },

    saveTaxAndNonProfit: function(cmp, nonProfit) {
        cmp.set("v.isLoading", true);
        var draftValues = [];
        var fedData = cmp.get("v.fedData");
        for (var j = 0; j < fedData.length; ++j) {
            var tableRow = fedData[j];
            if (tableRow.State_Code__c === "FED" && tableRow.Tax_Type__c === "FUTA") {
                tableRow.Rate__c = tableRow.Default_Rate__c;
                draftValues.push(tableRow);
            }
        }

        var action = cmp.get("c.savePricingTaxes");
        var taxDataJSON = JSON.stringify(draftValues);
        action.setParams({"taxes": taxDataJSON});
        action.setCallback(this, function (response) {
            cmp.set("v.isLoading", false);
            if (response.getState() === "SUCCESS"){
                this.saveNonProfit(cmp, nonProfit);
                this.loadFed(cmp, event);
            } else {
                this.showToast(cmp, "Sorry to interrupt you", "An error occurred while modifying tax item(s)", "error", "sticky");
            }
        });
        $A.enqueueAction(action);
    }
});