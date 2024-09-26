/*
 * Copyright (c) 2018. Barrett Business Services, Inc. All Rights Reserved
 */
({
    init: function (cmp, event, helper) {
        cmp.set("v.columnsRenewalYear", [
            {label: "State", fieldName: "State_Code__c", type: "text"},
            {label: "* Xmod", fieldName: "Xmod__c", type: "number", initialWidth: 150, typeAttributes: {minimumFractionDigits: "4", maximumFractionDigits: "4"}, editable: true}
        ]);
        
        cmp.set("v.columnsHistory", [
            {label: "State", fieldName: "State_Code__c", type: "text"},
            {label: "Effective Date", fieldName: "XmodDate__c", type: "date-local"},
            {label: "Xmod", fieldName: "Xmod__c", type: "number", initialWidth: 100, typeAttributes: {minimumFractionDigits: "4", maximumFractionDigits: "4"}}
        ]);

        cmp.set("v.columnsPublished", [
            {label: "State", fieldName: "State_Code__c", type: "text"},
            {label: "Year", fieldName: "Year__c", type: "text"},
            {label: "Calculated Date", fieldName: "XmodDate__c", initialWidth: 160, type: "date-local"},
            {label: "Xmod", fieldName: "Xmod__c", type: "number", initialWidth: 100, typeAttributes: {minimumFractionDigits: "4", maximumFractionDigits: "4"}, initialWidth: 100}
        ]);

        cmp.set("v.columnsRecommended", [
            {label: "State", fieldName: "State_Code__c", type: "text"},
            {label: "Effective Date", fieldName: "Effective_Date__c", type: "date-local"},
            {label: "Policy Number", fieldName: "Policy_Number__c", type: "text"},
            {label: "Notes", fieldName: "Notes__c", type: "text"},
            {label: "Xmod", fieldName: "Xmod__c", type: "number", initialWidth: 100, typeAttributes: {minimumFractionDigits: "4", maximumFractionDigits: "4"}, initialWidth: 100}
        ]);
    },

    handleSaveTable: function(cmp, event, helper){
        var draftValues = event.getParam("draftValues");
        helper.saveXmod(cmp, event, draftValues);
    },

    onAppEvent: function(cmp, event, helper){
        var appData = event.getParam("context");
        switch(appData.type){
            case "recordId":
                helper.changeRecordId(cmp, event, appData.value);
                break;
            case "isProspect":
                helper.setIsProspect(cmp, appData.value);
                break;
        }
    }
});