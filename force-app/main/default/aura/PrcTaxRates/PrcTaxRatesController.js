/*
 * Copyright (c) 2018. Barrett Business Services, Inc. All Rights Reserved
 */
({
    init: function (cmp, event, helper) {
        helper.initStateCodes(cmp, helper);
        // cmp.set("v.columns", [
        //     {label: "State", fieldName: "State_Code__c", type: "text"},
        //     {label: "Tax Type", fieldName: "Tax_Type__c", type: "text", editable: false},
        //     {label: "Non-Profit", fieldName: "Non_Profit__c", type: "boolean", editable: true, cellAttributes:{alignment:"center"}},
        //     {label: "Tax Rate %", fieldName: "Rate__c", type: "number", typeAttributes:{minimumFractionDigits: "3",maximumFractionDigits: "3" }, editable: true},
        //     {label: "Limit", fieldName: "Limit__c", type: "number", typeAttributes:{maximumFractionDigits: "0" }, editable: true},
        //     {label: "", type: "button", initialWidth: 50, cellAttributes:{alignment:"center"}, typeAttributes:
        //         { label: { fieldName: "actionLabel"},variant:"base", title: "Delete", name: "delete_tax", iconName: "action:delete"}} ]
        // );
        cmp.set("v.fedColumns", [
            {label: "", fieldName: "State_Code__c", type: "text"},
            {label: "Tax Type", fieldName: "Tax_Type__c", type: "text", editable: false},
            {label: "Tax Rate %", fieldName: "Rate__c", type: "number", typeAttributes:{minimumFractionDigits: "3", maximumFractionDigits: "3" }, editable: true},
            {label: "Limit", fieldName: "Limit__c",  type: "number", typeAttributes:{maximumFractionDigits: "0" }},
            {label: "", type: "text", initialWidth: 50, cellAttributes:{alignment:"center"}}
        ]);

        cmp.set("v.stateAndOthersColumns", [
            {label: "State", fieldName: "State_Code__c", type: "text"},
            {label: "Tax Type", fieldName: "Tax_Type__c", type: "text", editable: false},
            {label: "* Tax Rate %", fieldName: "Rate__c", type: "number", typeAttributes:{minimumFractionDigits: "3",maximumFractionDigits: "3" }, editable: true},
            {label: "* Limit", fieldName: "Limit__c", type: "number", typeAttributes:{maximumFractionDigits: "0" }, editable: true},
            {label: "", type: "button", initialWidth: 50, cellAttributes:{alignment:"center"},
                typeAttributes: { label: { fieldName: "actionLabel"}, variant:"base", title: "Delete", name: "delete_tax", iconName: "action:delete"}}
        ]);
    },

    handleRowAction: function(cmp, event, helper){
        var action = event.getParam("action");
        var row = event.getParam("row");
        if(action.name === "delete_tax"){
            // only taxes local and other tax types can be deleted
            if(row.Tax_Type__c === "LOCAL" || row.Tax_Type__c === "OTHER"){
                if (window.confirm("Delete tax? (this cannot be undone)")) {
                    helper.deleteTaxItem(cmp, event, row);
                }
            } else{
                helper.showToast(cmp, "Attention", "Only LOCAL or OTHER taxes may be deleted", "warning", "dismissable");
            }
        } else{
            //alert("Other Row Action");
        }
    },

    handleFedSaveTable: function(cmp, event, helper) {
        var nonProfit = cmp.get("v.nonProfit");
        if(nonProfit === true) {
            var draftValues = event.getParam("draftValues");
            var fedData = cmp.get("v.fedData");
            for(var i=0; i<draftValues.length; ++i) {
                var draftRow = draftValues[i];
                for(var j=0; j<fedData.length; ++j) {
                    var tableRow = fedData[j];
                    if(draftRow.Id === tableRow.Id) {
                        draftRow.State_Code__c = tableRow.State_Code__c;
                        draftRow.Tax_Type__c = tableRow.Tax_Type__c;
                        j = fedData.length;
                        if(draftRow.State_Code__c === "FED" && draftRow.Tax_Type__c !== "FUTA") {
                            helper.clearChanges(cmp, event);
                            helper.showToast(cmp, "Attention", "Federal non FUTA Tax Rates cannot be edited", "warning", "dismissable" );
                            return;
                        }
                    }
                }
            }
            helper.saveTaxValues(cmp, event, draftValues);
        } else {
            helper.clearChanges(cmp, event);
            helper.showToast(cmp, "Attention", "Federal Tax Rates cannot be edited", "warning", "dismissable");
        }
    },

    handleSaveTable: function(cmp, event, helper){
        var draftValues = event.getParam("draftValues");
        helper.saveTaxValues(cmp, event, draftValues);
    },

    onOpenAddform: function(cmp, event, helper){
        helper.initNewTax(cmp, event);
        cmp.set("v.isShowingAddform", true);
    },

    onCreateTax: function(cmp, event, helper){
        var allValid = cmp.find("taxform").reduce(function (validSoFar, inputCmp) {
            inputCmp.showHelpMessageIfInvalid();
            return validSoFar && inputCmp.get("v.validity").valid;
        }, true);
        if(allValid){
            var newTax = cmp.get("v.newTaxItem");
            helper.saveNewTaxItem(cmp, event, newTax);
        } else {
            helper.showToast(cmp, "Attention", "Please update any invalid form entries and try again", "warning", "dismissable" );
        }
    },

    onCancelTax: function(cmp, event, helper){
        cmp.set("v.isShowingAddform", false);
    },

    onAppEvent: function(cmp, event, helper){
        var appData = event.getParam("context");
        switch(appData.type){
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
            case "dataChange":
                if(appData.value === "nonProfit") {
                    console.log(new Date().getTime() + " " + cmp.get("v.containerName") + " " + appData.type + ": " + appData.value);
                    helper.loadNonProfit(cmp, event);
                }
        }
    },

    handleNonProfit: function(cmp, event, helper) {
        var nonProfit = cmp.get("v.nonProfit");
        if(nonProfit === true) {
            helper.saveNonProfit(cmp, nonProfit);
        } else {
            helper.saveTaxAndNonProfit(cmp, nonProfit);
        }
    }
});