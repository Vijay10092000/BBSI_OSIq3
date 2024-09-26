/*
 * Copyright (c) 2018. Barrett Business Services, Inc. All Rights Reserved
 */

({
    init: function (cmp, event, helper) {
        cmp.set("v.zeroPayrollColumns", [
            {label: "State", fieldName: "State_Code__c", type: "text", cellAttributes: {alignment:"left"}},
            {label: "WC Code", fieldName: "WC_Code__c", type: "text", cellAttributes: {alignment:"left"}},
            {label: "* Markup", fieldName: "Markup__c", type: "number", cellAttributes: {alignment:"right"}, editable: true},
            {label: "* OT %", fieldName: "Markup_OverTime__c", type: "number", cellAttributes: {alignment:"right"}, editable: true},
            {label: "* DT %", fieldName: "Markup_DoubleTime__c", type: "number", cellAttributes: {alignment:"right"}, editable: true}
            // {label: "SI Rate", fieldName: "SI_Rate__c", type: "number", cellAttributes: {alignment:"right"}, editable: true}
        ]);
    },

    onRecordIdChange: function (cmp, event, helper) {
        var params = event.getParam("arguments");
        cmp.set("v.recordId", params.param1);
        helper.loadData(cmp, event);
        helper.sendClientId(cmp, event);
    },

    onRenewalDateChange: function (cmp, event, helper) {
        var params = event.getParam("arguments");
        var renewalDate = params.param1;
        cmp.set("v.renewalDate", renewalDate);
    },

    handleSetState: function(cmp, event, helper) {
        var newStateData = event.getParam("newState");
        console.log(new Date().getTime() + " :PRICING: handleSetState: " + newStateData.component + ", " + JSON.stringify(newStateData));
        switch(newStateData.component) {
            case "commissions":
                helper.handleCommissions(cmp, event, newStateData);
                break;
            case "employees":
            case "markup":
            case "workComp":
                helper.loadDataEmployeesAndWorkComps(cmp, event, newStateData);
                break;
            case "expenses":
                helper.loadExpenses(cmp, event, newStateData);
                break;
            case "taxRates":
                helper.loadDataTaxRates(cmp, event, newStateData);
                break;
            case "xmod":
                helper.loadDataXmods(cmp, event, newStateData);
                break;
            default :
                break;
        }
    },

    onStateChange: function (cmp, event, helper){
        var eAction = cmp.getEvent("getState");
        eAction.setParams({
            containerName: cmp.get("v.containerName"),
            state: [
                {
                    attribute: "recordId",
                    value: cmp.get("v.recordId")
                }
            ]
        });
        eAction.fire();
    },

    onMarkupValuesChange: function(cmp, event, helper) {

    },

    handleEmpHeightSelect: function(cmp, event, helper) {
        var val = event.getParam("value");
        helper.sendEmpTableHeight(cmp, event, val);
    },

    handleSectionToggle: function(cmp, event, helper) {

    },

    // handleSaveTable for the ZeroPayroll table
    // 1. validation on Markup__c cannot be lower than Modified_WC_Rate__c
    // 2. create function to save work comps
    handleSaveTable: function (cmp, event, helper) {
        let draftValues = event.getParam("draftValues");
        let workComps = cmp.get("v.prcWorkComps");

        if (helper.isMarkupValidated(cmp, draftValues, workComps)) {
            return helper.saveZeroPayrollWcCodes(cmp, event, draftValues);
        }
    },

    onCreateWorksheetSummary: function(cmp, event, helper) {
        helper.getSummaryWorksheet(cmp, event);
    },

    onCreatePdf: function(cmp, event, helper) {
        let report = event.getParam("arguments").selectedReport;
        cmp.set("v.selectedReport", report);
        cmp.set("v.includeSi", report.includes("with S/I") || report.includes("with SI"));
        cmp.set("v.isClientAddendumReport", report.includes("Client Addendum"));
        cmp.set("v.includeNotes", report === "Pricing Summary Report");
        helper.initReportSetting(cmp);
    },

    createPdf: function(cmp, event, helper) {
        helper.saveSettingsAndCreateReport(cmp, event);
    },

    cancelNotes: function(cmp, event, helper) {
        helper.cancelPdf(cmp, event);
    }
});