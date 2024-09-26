/*
 * Copyright (c) 2018. Barrett Business Services, Inc. All Rights Reserved
 */
({
    init: function(cmp) {
        cmp.set("v.columns", [
            {label: "State", fieldName: "State_Code__c", initialWidth: 75, type: "text", cellAttributes: {alignment:"left"}},
            {label: "WC Code", fieldName: "WC_Code__c", initialWidth: 100, type: "text", cellAttributes: {alignment:"left"}},
            {label: "Payroll in Code", fieldName: "AnnualTaxablePayInCode__c", type: "currency"},
            {label: "WC Rate", fieldName: "WC_Rate__c", type: "number", typeAttributes: {minimumFractionDigits: "4",maximumFractionDigits: "4" } },
            {label: "Modified WC Rate", fieldName: "Modified_WC_Rate__c", type: "number", typeAttributes: {minimumFractionDigits: "4",maximumFractionDigits: "4" } },
            {label: "WC Premium", fieldName: "WcPremiumEquivalent__c", type: "currency"},
            {label: "* Eligible for Safety Incentive", fieldName: "SIEligible__c", type: "boolean", editable: true, cellAttributes: {alignment:"right"}},
            {label: "* % of Premium Eligible for Safety Incentive", fieldName: "SI_Percent_of_Premium__c", type: "number", editable: true, typeAttributes: {minimumFractionDigits: "2",maximumFractionDigits: "2"}},
            {label: "* % of Payroll Eligible for Safety Incentive", fieldName: "SI_Percent_of_Payroll__c", type: "number", editable: true, typeAttributes: {minimumFractionDigits: "2",maximumFractionDigits: "2"}},
            {label: "Max Safety Incentive", fieldName: "SI_Max__c", type: "currency"},
            {label: "", type: "button", initialWidth: 20, cellAttributes:{alignment:"center"}, typeAttributes:
                    { label: { fieldName: "actionLabel"},variant:"base", title: "Delete", name: "delete_wc_code", iconName: "action:delete"}}
        ]);
    },

    handleRowAction: function(cmp, event, helper) {
        let action = event.getParam("action");
        let row = event.getParam("row");
        if(action.name === "delete_wc_code"){
            cmp.set("v.row", row);
            if(row.AnnualTaxablePayInCode__c === 0) {
                helper.openSimpleDelete(cmp);
            }
            else {
                helper.openTransferDelete(cmp);
            }
        }
    },

    handleSaveTable: function(cmp, event, helper) {
        let draftValues = event.getParam("draftValues");
        helper.reconcileAndSaveSiRates(cmp, draftValues);
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
            case "xmodsRenewalYear":
                console.log(new Date().getTime() + " " + cmp.get("v.containerName") + " " + appData.type + ": " + appData.value);
                helper.setXmodMapValues(cmp, event, appData.value);
                break;
            case "summaryUpdate":
                console.log(new Date().getTime() + " " + cmp.get("v.containerName") + " " + appData.type + ": " + appData.value);
                helper.updateFooterTotals(cmp, event, appData.value);
                break;
            case "dataChange":
                if( appData.value === "wcCodes") {
                    console.log(new Date().getTime() + " " + cmp.get("v.containerName") + " " + appData.type + ": " + appData.value);
                    helper.loadData(cmp);
                }
                break;
        }
    },

    closeSimpleDelete: function(cmp, event, helper) {
        helper.closeSimpleDelete(cmp);
    },

    okSimpleDelete: function (cmp, event, helper) {
        helper.deleteWorkComp(cmp, event);
    },

    closeTransferDelete: function(cmp, event, helper) {
        helper.closeTransferDelete(cmp);
    },

    submitTransferDelete: function (cmp, event, helper) {
        helper.transferAndDeleteWorkComp(cmp);
    },

    onCheckboxChange: function (cmp, event) {
        let availableCheckboxes = cmp.find("rowSelectionCheckboxId");
        let resetCheckboxValue = false;

        if(Array.isArray(availableCheckboxes)) {
            availableCheckboxes.forEach(function(checkbox) {
                checkbox.set("v.value", resetCheckboxValue);
            });
        } else {
            availableCheckboxes.set("v.value", resetCheckboxValue);
        }

        let source = event.getSource();
        source.set("v.value", true);
        cmp.set("v.selectedWorkComp", source.get("v.text"));
    },

    onOpenWorkCompForm: function (cmp, event, helper) {
        cmp.set("v.showAddWorkComp", false);
        helper.getTemplateWorkCompCodes(cmp);
    },

    onAddWorkComp: function (cmp, event, helper) {
        let selectedState = cmp.get("v.selectedState");
        if(!selectedState) {
            return helper.showNotice(cmp, "Attention", "Please select a state", "warning", "dismissable" );
        }

        let selectedWcInfo = cmp.get("v.selectedWcCode");
        let wcInfo = selectedWcInfo.split(' ');
        if(!wcInfo || wcInfo.length !== 3) {
            return helper.showNotice(cmp, "Attention", "Please select a WC Code", "warning", "dismissable" );
        }

        let state = wcInfo[0];
        let code = wcInfo[1];
        let rate = wcInfo[2];
        let siEligible = (cmp.get("v.siEligible") === true);

        let data = cmp.get("v.data");
        for (let i = 0; i < data.length; ++i) {
            if(data[i].State_Code__c === state && data[i].WC_Code__c === code) {
                return helper.showToast(cmp, "Error", "You have selected to add an existing Work Comp. Please select a new work comp code", "warning", "dismissable" );
            }
        }

        helper.addWorkComp(cmp, event, state, code, rate, siEligible);
    },
    
    onCancelWorkComp: function (cmp, event, helper) {
        helper.cancelWorkComp(cmp);
    },

    onChangeState: function (cmp, event, helper) {
        cmp.set("v.selectedWcCode", "");
        cmp.set("v.selectedWcRate", "");
        cmp.set("v.wcCodes", []);

        let state = event.getSource().get("v.value");
        let wcTemplateRates = cmp.get("v.wcTemplateRates");
        if(wcTemplateRates[state]) {
            cmp.set("v.wcCodes", wcTemplateRates[state]);
        }
    },

    onChangeWcCode: function (cmp, event, helper) {
        cmp.set("v.selectedWcRate", "");
        let selectedWcInfo = event.getSource().get("v.value");
        if(selectedWcInfo === "initial") { return; }

        let wcInfo = selectedWcInfo.split(' ');
        if(!wcInfo || wcInfo.length !== 3) {
            return helper.showToast(cmp, "Attention", "Please select a WC Code", "warning", "dismissable" );
        }

        cmp.set("v.selectedWcRate", wcInfo[2]);
    }
});