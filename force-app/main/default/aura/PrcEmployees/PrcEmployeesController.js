/*
 * Copyright (c) 2018. Barrett Business Services, Inc. All Rights Reserved
 */
({
    init: function(cmp, event, helper){
        cmp.set("v.columns", [
            {label: "* Qty", fieldName: "Qty__c", type: "number", typeAttributes: {maximumFractionDigits: "1" }, initialWidth: 75, editable: true, sortable: true, cellAttributes:{alignment:"center"}},
            {label: "* Owner", fieldName: "IsOwner__c", type: "boolean", initialWidth: 75, editable: true, sortable: true, cellAttributes:{alignment:"center"}},
            {label: "* Name", fieldName: "Employee_Name__c", type: "text", editable: true, sortable: true },
            {label: "WC Code (Primary)", fieldName: "Primary_WC_Code__c", type: "text", sortable: true, cellAttributes:{alignment:"center"}},
            {label: "Tax State", fieldName: "State_Code__c", type: "text", initialWidth: 75, sortable: true, cellAttributes:{alignment:"center"}},
            {label: "* Active", fieldName: "IsActive__c", type: "boolean",  editable: true, sortable: true, cellAttributes:{alignment:"center"}},
            {label: "Hourly Rate (Estimated)", fieldName: "HourlyRate__c", type: "currency", sortable: true},
            {label: "* Hours (Annual)", fieldName: "AnnualHours__c", type: "number", typeAttributes: {minimumFractionDigits: "1", maximumFractionDigits: "1"}, editable: true, sortable: true, cellAttributes:{alignment:"center"}},
            {label: "Payroll (Annual)", fieldName: "AnnualTaxablePay__c", type: "currency", sortable: true},
            {label: "Employer Taxes (Estimated)", fieldName: "EstimatedERTax__c", type: "currency", sortable: true},
            {label: "", type: "button", initialWidth: 20, cellAttributes: {alignment:"center"}, typeAttributes: {label: {fieldName: "actionLabel"}, variant:"base", title: "Delete", name: "delete_employee", iconName: "action:delete"}}
        ]);

        cmp.set("v.wcSummaryColumns", [
            {label: "State", fieldName: "State_Code__c", type: "text", cellAttributes: {alignment:"center"}},
            {label: "WC Code", fieldName: "WC_Code__c", type: "text", cellAttributes: {alignment:"center"}},
            {label: "Tax Burden %", fieldName: "TaxBurdenPercentInCode__c", type: "number", 
                typeAttributes: {minimumFractionDigits: "2", maximumFractionDigits: "2"},
                cellAttributes: {alignment:"center"}},
            {label: "Employees In Code", fieldName: "TotalEmployeesInCode__c", type: "number"},
            {label: "FTE", fieldName: "FTEInCode__c", type: "number", typeAttributes: {minimumFractionDigits: "1", maximumFractionDigits: "1"}},
            {label: "Annual Hours", fieldName: "AnnualHoursInCode__c", type: "number", typeAttributes: {minimumFractionDigits: "1", maximumFractionDigits: "1"}},
            {label: "Annual Payroll", fieldName: "AnnualTaxablePayInCode__c", type: "currency"},
            {label: "Estimated Employer Taxes", fieldName: "EstimatedErTaxInCode__c", type: "currency"}
        ]);
    },

    handleRowAction: function(cmp, event, helper){
        let action = event.getParam("action");
        let row = event.getParam("row");
        if(action.name === "delete_employee") {
            /*
              *  USE MODAL LIGHTNING FORM
              *  https://lightningdesignsystem.com/components/modals/#site-main-content
              *
               */
            if (window.confirm("Delete employee? (this cannot be undone)")) {
                helper.deleteEmployee(cmp, event, row);
            }
        }
    },

    handleSaveTable: function(cmp, event, helper){
        let draftValues = event.getParam("draftValues");
        helper.saveEmployees(cmp, event, draftValues);
    },

    onOpenAddEmployeeForm: function(cmp, event, helper){
        helper.initNewEmployee(cmp, event);
        cmp.set("v.showAddEmployee", true);
    },

    onOpenModifyWorkCompForm: function (cmp, event, helper) {
        helper.initNewWc(cmp, event);
        cmp.set("v.showModifyByWcCode", true);
    },

    onCreateEE: function(cmp, event, helper){
        let allValid = cmp.find("employeeform").reduce(function (validSoFar, inputCmp) {
            inputCmp.showHelpMessageIfInvalid();
            return validSoFar && inputCmp.get("v.validity").valid;
        }, true);

        if(!allValid) {
            return helper.showNotice(cmp, "Attention", "Please update any invalid form entries and try again", "warning", "dismissable");
        }

        let newEE = cmp.get("v.newEmployee");
        if (newEE.PrimaryPricingWcCode__c === "") {
            return helper.showNotice(cmp, "Attention", "Please specify the required WC Code", "warning", "dismissable");
        }

        let projFactor = cmp.get("v.projFactor");
        newEE.AnnualHours__c = Number(newEE.AnnualHours__c / projFactor);
        let annualPay = Number(newEE.AnnualPay__c / projFactor);
        newEE.AnnualPay__c  = annualPay;
        newEE.AnnualPremPay__c = annualPay;
        newEE.AnnualTaxablePay__c = annualPay;
        newEE.IsUpdate__c = false;

        let wcCodes = cmp.get("v.wcCodeList");
        // copy values to Primary_WC_Code__c and State_Code__c
        for (let i = 0; i < wcCodes.length; i++){
            if (wcCodes[i].Id === newEE.PrimaryPricingWcCode__c ){
                newEE.Primary_WC_Code__c = wcCodes[i].WC_Code__c;
                newEE.State_Code__c = wcCodes[i].State_Code__c;
                break;
            }
        }
        helper.saveNewEmployee(cmp, event, newEE);
    },

    onModifyWcCode: function (cmp, event, helper) {
        // cmp.set("v.showModifyByWcCode", false);
        let allValid = cmp.find("modifyWcForm").reduce(function (validSoFar, inputCmp) {
            inputCmp.showHelpMessageIfInvalid();
            return validSoFar && inputCmp.get("v.validity").valid;
        }, true);

        if(!allValid) {
            return helper.showNotice(cmp, "Attention", "Please update any invalid form entries and try again", "warning", "dismissable");
        }

        let newWc = cmp.get("v.newWc");
        if (newWc.PrimaryPricingWcCode__c === "") {
            return helper.showNotice(cmp, "Attention", "Please specify the required WC Code", "warning", "dismissable");
        }

        if (newWc.Qty__c !== 0) {
            newWc.AnnualHours__c = Number(newWc.AnnualHours__c / newWc.Qty__c);
            newWc.AnnualPay__c = Number(newWc.AnnualPay__c / newWc.Qty__c);
            newWc.IsActive__c = true;
        }
        else {
            newWc.IsActive__c = false;
        }

        newWc.AnnualPremPay__c = newWc.AnnualPay__c;
        newWc.AnnualTaxablePay__c = newWc.AnnualPay__c;
        newWc.IsUpdate__c = true;

        let wcCodes = cmp.get("v.wcCodeList");
        // copy values to Primary_WC_Code__c and State_Code__c
        for (let i = 0; i < wcCodes.length; i++){
            if (wcCodes[i].Id === newWc.PrimaryPricingWcCode__c ){
                newWc.Primary_WC_Code__c = wcCodes[i].WC_Code__c;
                newWc.State_Code__c = wcCodes[i].State_Code__c;
                break;
            }
        }

        newWc.Employee_Name__c = newWc.State_Code__c + "." + newWc.Primary_WC_Code__c + " Update";
        helper.saveNewEmployee(cmp, event, newWc);
    },

    modifyNumberOfEmployees: function (cmp, event, helper) {
        let newWc = cmp.get("v.newWc");
        newWc.AnnualHours__c = newWc.Qty__c * 2080;
        cmp.set("v.newWc", newWc);
    },

    onCancelEE: function(cmp, event, helper){
        cmp.set("v.showAddEmployee", false);
    },

    onCancelWcCode: function (cmp, event, helper) {
        cmp.set("v.showModifyByWcCode", false);
    },

    handleColumnSorting: function(cmp, event, helper){
        let fieldName = event.getParam("fieldName");
        let sortDirection = event.getParam("sortDirection");
        cmp.set("v.sortedBy", fieldName);
        cmp.set("v.sortedDirection", sortDirection);
        helper.sortData(cmp, fieldName, sortDirection);
    },

    onAppEvent: function(cmp, event, helper){
        let appData = event.getParam("context");
        switch(appData.type){
            case "recordId":
                helper.changeRecordId(cmp, event, appData.value);
                break;
            case "isProspect":
                cmp.set("v.isProspect", appData.value);
                break;
            case "dataChange":
                if( appData.value === "employees"){
                    console.log(new Date().getTime() + " " + cmp.get("v.containerName") + " " + appData.type + ": " + appData.value);
                    helper.loadData(cmp, event);
                }
                break;
            case "summaryUpdate":
                console.log(new Date().getTime() + " " + cmp.get("v.containerName") + " " + appData.type + ": " + appData.value);
                helper.updateFooterTotals(cmp, event, appData.value);
                break;
            case "empTableHeight":
                helper.setEmpTableHeight(cmp, appData.value);
                break;
        }
    }
});