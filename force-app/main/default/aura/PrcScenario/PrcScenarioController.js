/*
 * Copyright (c) 2018. Barrett Business Services, Inc. All Rights Reserved
 */

({
    init: function (cmp, event, helper) {
        helper.init(cmp);
        helper.loadData(cmp, event);
    },

    handleClientChange: function(cmp, event, helper){
        let scenId = cmp.find("selectClient").get("v.value");
        helper.pushChildClientScenarioRecordId(cmp, event, scenId);
    },

    handleLoad: function(cmp, event, helper){
    },

    handleChange: function(cmp, event, helper){
        cmp.set("v.disabled", false);
    },

    handleSuccess: function (cmp, event, helper) {
        cmp.set("v.disabled", true);
    },

    handleSubmit: function (cmp, event, helper) {
        event.preventDefault(); // stop form submission
        let eventFields = event.getParam("fields");
        cmp.set("v.scenarioName", eventFields.ScenarioName__c);
        cmp.find("pricingScenarioForm").submit(eventFields);
    },

    downloadExcel: function(cmp, event, helper){
        helper.createClientWorksheetSummary(cmp, event);
    },

    createReport: function(cmp, event, helper){
        helper.createPdf(cmp, event);
    }
});