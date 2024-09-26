/*
 * Copyright (c) 2018. Barrett Business Services, Inc. All Rights Reserved
 */

({
    init: function (cmp, event, helper) {
        cmp.set("v.expenseCategories", [
            {label: "Time Clocks"},
            {label: "Payroll Services/Corporate Support"},
            {label: "New Employee"}]);
        cmp.set("v.clientInvestmentMethods", [
            {label: "% of Payroll"},
            {label: "% of WC Premium"},
            {label: "% of Margin"}]);
        cmp.set("v.columns", [
            {label: "Category", fieldName: "Category__c", type: "text"},
            {label: "*Description", fieldName: "Description__c", type: "text", editable: true},
            {label: "*Units", fieldName: "Quantity__c", type: "number", editable: true, typeAttributes: {minimumIntegerDigits: "1"}, cellAttributes: {alignment:"center"}},
            {label: "*Cost Per Unit", fieldName: "Cost_Each__c", type: "currency", editable: true},
            {label: "Total Cost", fieldName: "Total__c", type: "currency"},
            {label: "", type: "button", initialWidth: 50, cellAttributes:{alignment:"center"}, typeAttributes:
                    { label: { fieldName: "actionLabel"},variant:"base", title: "Delete", name: "delete_expense", iconName: "action:delete"}}]);
        cmp.set("v.columnsClientInvestments",[
            {label: "Description", fieldName: "Description__c", type: "text", editable: true},
            {label: "Method", fieldName: "Method__c", type: "text"},
            {label: "*Rate", fieldName: "Rate__c", type: "number", editable: true, step:0.01, typeAttributes: {minimumIntegerDigits: "1"}},
            {label: "Total Cost", fieldName: "Total_Cost__c", type: "currency"},
            {label: "", type: "button", initialWidth: 50, cellAttributes:{alignment:"center"}, typeAttributes:
                    { label: { fieldName: "actionLabel"},variant:"base", title: "Delete", name: "delete_expense", iconName: "action:delete"}}]);
    },

    handleExpenseRowAction: function(cmp, event, helper){
        var action = event.getParam("action");
        var row = event.getParam("row");
        if(action.name === "delete_expense"){
            /*
              *  TODO USE MODAL LIGHTNING FORM
              *  https://lightningdesignsystem.com/components/modals/#site-main-content
              *
               */
            if (window.confirm("Delete client investment by unit item? (this cannot be undone)")) {
                helper.deleteExpenseItem(cmp, event, row);
            }
        }
    },

    handleClientInvestmentRowAction: function(cmp, event, helper){
        var action = event.getParam("action");
        var row = event.getParam("row");
        if(action.name === "delete_expense"){
            /*
              *  TODO USE MODAL LIGHTNING FORM
              *  https://lightningdesignsystem.com/components/modals/#site-main-content
              *
               */
            if (window.confirm("Delete client investment by % item? (this cannot be undone)")) {
                helper.deleteClientInvestmentItem(cmp, event, row);
            }
        }
    },

    handleSaveExpenseTable: function(cmp, event, helper){
        var draftValues = event.getParam("draftValues");
        helper.saveExpense(cmp, event, draftValues);
    },

    handleSaveClientInvestmentTable: function(cmp, event, helper){
        var draftValues = event.getParam("draftValues");
        helper.saveClientInvestment(cmp, event, draftValues);
    },

    onOpenAddExpenseForm: function(cmp, event, helper){
        helper.initNewExpense(cmp, event);
        cmp.set("v.isShowingAddExpenseForm", true);
    },

    onOpenAddClientInvestmentForm: function(cmp, event, helper){
        helper.initNewClientInvestment(cmp, event);
        cmp.set("v.isShowingAddClientInvestmentForm", true);
    },

    onCreateExpense: function(cmp, event, helper){
        var allValid = cmp.find("expenseForm").reduce(function (validSoFar, inputCmp) {
            inputCmp.showHelpMessageIfInvalid();
            return validSoFar && inputCmp.get("v.validity").valid;
        }, true);
        if(allValid){
            var newExpense = cmp.get("v.newExpenseItem");
            helper.saveNewExpenseItem(cmp, event, newExpense);
        } else {
            helper.showToast(cmp, "Attention", "Please update any invalid form entries and try again", "warning", "dismissable" );
        }
    },

    onCancelExpense: function(cmp, event, helper){
        cmp.set("v.isShowingAddExpenseForm", false);
    },

    onCreateClientInvestment: function(cmp, event, helper){
        var allValid = cmp.find("investmentForm").reduce(function (validSoFar, inputCmp) {
            inputCmp.showHelpMessageIfInvalid();
            return validSoFar && inputCmp.get("v.validity").valid;
        }, true);
        if(allValid){
            var newInvestmentItem = cmp.get("v.newInvestmentItem");
            helper.saveNewInvestmentItem(cmp, event, newInvestmentItem);
        } else {
            helper.showToast(cmp, "Attention", "Please update any invalid form entries and try again","warning", "dismissable" );
        }
    },

    onCancelClientInvestment: function(cmp, event, helper){
        cmp.set("v.isShowingAddClientInvestmentForm", false);
    },

    onAppEvent: function(cmp, event, helper){
        var appData = event.getParam("context");
        switch(appData.type) {
            case "recordId":
                helper.changeRecordId(cmp, event, appData.value);
                break;
            case "isProspect":
                cmp.set("v.isProspect", appData.value);
                break;
            case "summaryUpdate":
                console.log(new Date().getTime() + " " + cmp.get("v.containerName") + " " + appData.type + ": " + appData.value);
                helper.updateFooterTotals(cmp, event, appData.value);
                break;
        }
    }
});