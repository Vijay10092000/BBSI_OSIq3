/*
 * Copyright (c) 2018. Barrett Business Services, Inc. All Rights Reserved
 */
({
    init: function(cmp, event, helper){
        cmp.set("v.columns", [
            {label: "State", fieldName: "State_Code__c", type: "text", initialWidth: 70, cellAttributes: {alignment:"left"}},
            {label: "WC Code", fieldName: "WC_Code__c", type: "text", cellAttributes: {alignment:"center"}},
            {label: "% of Payroll in Code", fieldName: "PercentOfPayroll__c", type: "number", typeAttributes: {minimumFractionDigits: "2", maximumFractionDigits: "2" }, cellAttributes: {alignment:"right"}},
            {label: "FTE", fieldName: "FTEInCode__c", type: "number", initialWidth: 70, typeAttributes: {minimumFractionDigits: "1", maximumFractionDigits: "1"}},
            {label: "* Margin $ Per Head", fieldName: "MarginPerHeadInCode__c", type: "currency", initialWidth: 140, editable: true}, //, cellAttributes: {iconName: "utility:edit_form"}
            {label: "* Net Margin", fieldName: "DesiredMarginDollars__c", type: "currency", initialWidth: 150, editable: true},
            {label: "Tax Burden %", fieldName: "TaxBurdenPercentInCode__c", type: "number", typeAttributes: {minimumFractionDigits: "2", maximumFractionDigits: "2"}},
            {label: "Modified WC Rate", fieldName: "Modified_WC_Rate__c", type: "number", typeAttributes: {minimumFractionDigits: "4", maximumFractionDigits: "4"}},
            {label: "* Markup %", fieldName: "Markup__c", type: "number", editable: true, typeAttributes: {minimumFractionDigits: "3", maximumFractionDigits: "3"}},
            {label: "* OT %", fieldName: "Markup_OverTime__c", type: "number", min: 0, editable: true, typeAttributes: {minimumFractionDigits: "3", maximumFractionDigits: "3"}},
            {label: "* DT %", fieldName: "Markup_DoubleTime__c", type: "number", min: 0, editable: true, typeAttributes: {minimumFractionDigits: "3", maximumFractionDigits: "3"}}]);
        cmp.find("grossMarginInput").set("v.value", 0);

        cmp.set("v.bhColumns", [
            {label: "WC Code", fieldName: "WC_Code__c", type: "text", initialWidth: 100, cellAttributes: {alignment:"left"}},
            {label: "Markup %", fieldName: "Bundled_Rate__c", type: "percent", initialWidth: 110, typeAttributes: {minimumFractionDigits: "2", maximumFractionDigits: "2" }, cellAttributes: {alignment:"right"}},
            {label: "Pay Code", fieldName: "Pay_Code__c", type: "text", initialWidth: 600, cellAttributes: {alignment:"left"}}
        ]);
    },

    validateCellInput: function(cmp, event, helper){
        cmp.set("v.errors", "");
        let draftValues = event.getParam("draftValues");

        for (let i = 0; i < draftValues.length; i++) {
            if (draftValues[i].DesiredMarginDollars__c === 0) { continue; }
            helper.validateMarginInput(cmp, event, draftValues[i]);
        }
    },

    handleSaveTable: function(cmp, event, helper){
        if(cmp.get("v.errors") === ""){
            let draftValues = event.getParam("draftValues");
            let markupData = JSON.stringify(draftValues);

            let hasMarkup = markupData.includes("Markup__c");
            let hasMarkupOt = markupData.includes("Markup_OverTime__c");
            let hasMarkupDt = markupData.includes("Markup_DoubleTime__c");
            let hasNetMargin = markupData.includes("DesiredMarginDollars__c");
            let hasMarginPerHead = markupData.includes("MarginPerHeadInCode__c");
            if (hasMarkup) {
                if (!helper.validateEditMarkupPercent(cmp, draftValues)) {
                    helper.showToast(cmp, "Attention", "Cannot set Markup Percentage lower than Modified WC Rate", "warning", "dismissable" );
                    cmp.find("markupTable").set("v.draftValues", null); // clear the Cancel & Save buttons
                    return;
                }
                if (hasNetMargin || hasMarginPerHead || hasMarkupOt || hasMarkupDt) {
                    helper.showToast(cmp, "Attention", "Modifying Markup % will recalculate and overwrite other edits for all rows", "warning", "dismissable");
                }
                helper.saveMarkupPercent(cmp, draftValues, true);
            }
            else if (hasNetMargin) {
                if (hasMarginPerHead || hasMarkupOt || hasMarkupDt) {
                    helper.showToast(cmp, "Attention", "Modifying Net Margin will recalculate and overwrite other edits for all rows", "warning", "dismissable");
                }
                helper.saveNetMargin(cmp, draftValues);
            }
            else if (hasMarginPerHead) {
                if (hasMarkupOt || hasMarkupDt) {
                    helper.showToast(cmp, "Attention", "Modifying Margin $ Per Head will recalculate and overwrite other edits for all rows", "warning", "dismissable");
                }
                helper.saveMarginPerHead(cmp, draftValues);
            }
            else if (hasMarkupOt || hasMarkupDt) {
                helper.saveMarkupPercent(cmp, draftValues, false);
            }
        }
        else{
            helper.showToast(cmp, "Error", "Please fix any errors and try again", "error", "sticky");
        }
    },

    handleGrossMarginChange: function (cmp, event, helper) {
        // can do input validation here
    },

    handleSubmitGrossMargin: function (cmp, event, helper) {
        let marginVal = cmp.find("grossMarginInput").get("v.value");
        let option = cmp.find("applyMarginGroup").get("v.value");
        helper.applyTotalGrossMargin(cmp, marginVal, option);
    },

    handleGrossMarginApplyType: function (cmp, event, helper) {
    },

    onAppEvent: function(cmp, event, helper) {
        let appData = event.getParam("context");
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
            case "dataChange":
                if( appData.value === "wcCodes"){
                    console.log(new Date().getTime() + " " + cmp.get("v.containerName") + " " + appData.type + ": " + appData.value);
                    helper.loadData(cmp);
                }
                break;
        }
    },

    openBillingHistory: function(cmp, event, helper) {
        helper.getBillingHistory(cmp, event);
    },

    closeBillingHistory: function(cmp) {
        cmp.set("v.isBillingHistoryOpen", false);
    }
});