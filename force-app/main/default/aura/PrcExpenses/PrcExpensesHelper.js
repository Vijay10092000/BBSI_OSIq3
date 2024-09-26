/*
 * Copyright (c) 2018. Barrett Business Services, Inc. All Rights Reserved
 */
({
    loadData: function(cmp, event, message){
        cmp.set("v.isLoading", true);
        var action = cmp.get("c.getPricingExpenses");
        action.setParams({"recordId": cmp.get("v.clientPricScenId")});
        action.setCallback(this, function(response) {
            cmp.set("v.isLoading", false);
            var state = response.getState();
            if(state === "SUCCESS"){
                cmp.set("v.data", response.getReturnValue() );
                this.loadClientInvestments(cmp, event, message);
            }else{
                console.error("Get Pricing Scenario: ", response.getError());
            }
        });
        $A.enqueueAction(action);
    },

    loadClientInvestments: function(cmp, event, message){
        cmp.set("v.isLoading", true);
        var action = cmp.get("c.getPricingClientInvestments");
        action.setParams({"recordId": cmp.get("v.clientPricScenId")});
        action.setCallback(this, function(response) {
            cmp.set("v.isLoading", false);
            var state = response.getState();
            if(state === "SUCCESS"){
                cmp.set("v.dataClientInvestments", response.getReturnValue() );
                this.recalculateTotals(cmp, event);
                if(message === "notifyParent"){
                    this.fireComponentEvent(cmp, "dataSaved", cmp.get("v.totalClientInvestment"));
                }
            }else{
                console.error("Get Pricing Scenario: ", response.getError());
            }
        });
        $A.enqueueAction(action);
    },

    recalculateTotals: function (cmp, event) {
        var totalInvestmentByUnit = 0;
        var totalInvestmentByPercentage = 0;
        var data = cmp.get("v.data");
        var dataClientInvestments = cmp.get("v.dataClientInvestments");
        if(data && data.length > 0) {
            for(var i = 0; i < data.length; i++){
                data[i].Total__c = Number(data[i].Quantity__c) * Number(data[i].Cost_Each__c);
                data[i].totalcal__c = data[i].Total__c;
                totalInvestmentByUnit += Number(data[i].Total__c);
            }
        }
        if(dataClientInvestments && dataClientInvestments.length > 0) {
            for (var j = 0; j < dataClientInvestments.length; j++) {
                totalInvestmentByPercentage += Number(dataClientInvestments[j].Total_Cost__c);
            }
        }
        cmp.set("v.data", data);
        cmp.set("v.dataClientInvestments", dataClientInvestments);
        cmp.set("v.totalInvestmentByUnit", totalInvestmentByUnit);
        cmp.set("v.totalInvestmentByPercentage", totalInvestmentByPercentage);
        cmp.set("v.totalClientInvestment", Number(totalInvestmentByUnit + totalInvestmentByPercentage));
    },

    saveExpense: function(cmp, event, data){
        cmp.set("v.isLoading", true);
        var action = cmp.get("c.savePricingExpenses");
        var dataJson = JSON.stringify(data);
        action.setParams({"expenses": dataJson});
        action.setCallback(this, function (response) {
            cmp.set("v.isLoading", false);
            var state = response.getState();
            if(state === "SUCCESS") {
                cmp.find("expensesTable").set("v.draftValues", null);
                this.loadData(cmp, event, "notifyParent");
            }else{
                this.showToast(cmp, "Sorry to interrupt you", "An error occurred while saving investment by unit", "error", "sticky");
            }
        });
        $A.enqueueAction(action);
    },

    saveClientInvestment: function(cmp, event, data){
        cmp.set("v.isLoading", true);
        var action = cmp.get("c.savePricingClientInvestments");
        var dataJson = JSON.stringify(data);
        action.setParams({"investments": dataJson});
        action.setCallback(this, function (response) {
            cmp.set("v.isLoading", false);
            var state = response.getState();
            if(state === "SUCCESS"){
                cmp.find("clientInvestmentsTable").set("v.draftValues", null);
                if(response.getReturnValue() == true){
                    this.loadData(cmp, event, "notifyParent");
                } else {
                    this.showToast(cmp, "Prohibited", "Cannot edit default Client Investment item rate", "error", "sticky");
                }
            }else{
                this.showToast(cmp, "Sorry to interrupt you", "An error occurred while saving investment by %", "error", "sticky");
            }
        });
        $A.enqueueAction(action);
    },

    saveNewExpenseItem: function (cmp, event, newExpense){
        newExpense.Total__c = Number(newExpense.Quantity__c) * Number(newExpense.Cost_Each__c);
        var action = cmp.get("c.addExpenseItem");
        action.setParams({
            "newExpenseItem": newExpense
        });
        action.setCallback(this, function(response) {
            var state = response.getState();
            cmp.set("v.isShowingAddExpenseForm", false);
            if(state === "SUCCESS"){
                this.loadData(cmp, event, "notifyParent");
            } else{
                this.showToast(cmp, "Sorry to interrupt you", "Unable to save new expense item", "error", "sticky");
            }
        });
        $A.enqueueAction(action);
    },

    saveNewInvestmentItem: function (cmp, event, newInvestmentItem){
        var action = cmp.get("c.addClientInvestmentItem");
        action.setParams({
            "newInvestmentItem": newInvestmentItem
        });
        action.setCallback(this, function(response) {
            var state = response.getState();
            cmp.set("v.isShowingAddClientInvestmentForm", false);
            if(state === "SUCCESS"){
                this.loadData(cmp, event, "notifyParent");
            } else{
                this.showToast(cmp, "Sorry to interrupt you", "Unable to save new expense item", "error", "sticky");
            }
        });
        $A.enqueueAction(action);
    },

    deleteExpenseItem: function (cmp, event, item){
        var expenseItem = JSON.stringify(item);
        var action = cmp.get("c.deleteExpenseItem");
        action.setParams({"expenseItem": expenseItem});
        action.setCallback(this, function(response) {
            var state = response.getState();
            if(state === "SUCCESS"){
                this.loadData(cmp, event, "notifyParent");
            } else{
                this.showToast(cmp,"Sorry to interrupt you", "Unable to delete client investment by unit item", "error", "sticky");
            }
        });
        $A.enqueueAction(action);
    },

    deleteClientInvestmentItem: function(cmp, event, item) {
        var investmentItem = JSON.stringify(item);
        var action = cmp.get("c.deleteClientInvestmentItem");
        action.setParams({"investmentItem": investmentItem});
        action.setCallback(this, function(response) {
            var state = response.getState();
            if(state === "SUCCESS"){
                if(response.getReturnValue() === true){
                    this.loadData(cmp, event, "notifyParent");
                } else {
                    this.showToast(cmp,"Prohibited", "Cannot delete default Client Investment item", "error", "sticky");
                }
            } else {
                this.showToast(cmp,"Sorry to interrupt you", "Unable to delete client investment by % item", "error", "sticky");
            }
        });
        $A.enqueueAction(action);
    },

    initNewExpense: function (cmp, event){
        var newExpense = {Id: null, ClientPricingScenario__c: cmp.get("v.clientPricScenId"), Category__c: "", Description__c: "", Quantity__c: 0, Cost_Each__c: 0};
        cmp.set("v.newExpenseItem", newExpense);
    },

    initNewClientInvestment: function (cmp, event){
        var newInvestment = {Id: null, ClientPricingScenario__c: cmp.get("v.clientPricScenId"), Description__c: "", Method__c: "% of Payroll", Rate__c: 0, Cost_Each__c: 0};
        cmp.set("v.newInvestmentItem", newInvestment);
    },

    changeRecordId: function (cmp, event, recId) {
        cmp.set("v.clientPricScenId", recId);
        this.loadData(cmp, event, "none");
    },

    updateFooterTotals: function(cmp, event, sumData){
        cmp.set("v.clientInvestmentPercent", sumData.YendExpenses_Percent__c);
        this.loadClientInvestments(cmp, event);
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
        cmp.find("notifLib").showToast({
            "title": title,
            "message": message,
            "variant": variant,
            "mode": mode
        });
    }
});