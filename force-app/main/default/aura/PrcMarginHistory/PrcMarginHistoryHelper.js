/*
 * Copyright (c) 2018. Barrett Business Services, Inc. All Rights Reserved
 */
({
    loadData: function(cmp, event){
        cmp.set("v.isLoading", true);
        var action = cmp.get("c.getPricingSummaryHistories");
        action.setParams({"recordId":cmp.get("v.clientPricScenId")});
        action.setCallback(this, function(response) {
            cmp.set("v.isLoading", false);
            var state = response.getState();
            if(state === "SUCCESS"){
                cmp.set("v.data", response.getReturnValue() );
            }else{
                console.error("Get Pricing Scenario: ", response.getError());
            }
        });
        $A.enqueueAction(action);
    },

    changeRecordId: function (cmp, event, recId) {
        cmp.set("v.clientPricScenId", recId);
        this.loadData(cmp, event);
    },

    init: function (cmp) {
        cmp.set("v.columns", [
            {label: "Start Date", fieldName: "PeriodStartDate__c", type: "date-local", editable: false, cellAttributes:{alignment:"left"}},
            {label: "Period", fieldName: "PeriodType__c", type: "text", editable: false, cellAttributes:{alignment:"center"}},
            {label: "End Date", fieldName: "PeriodEndDate__c", type: "date-local", editable: false, cellAttributes:{alignment:"right"}},
            {label: "Billing", fieldName: "YendBillingNet__c", type: "currency" },
            {label: "Payroll", fieldName: "YendPayroll__c", type: "currency" },
            {label: "Tax", fieldName: "YendErTaxes__c", type: "currency" },
            {label: "WC Premium", fieldName: "YendWcPrem__c", type: "currency" },
            {label: "Commissions", fieldName: "YendCommsTotal__c", type: "currency" },
            {label: "Client Investment", fieldName: "YendExpenses__c", type: "currency"},
            {label: "Net Margin", fieldName: "YendMargin__c", type: "currency" },
            {label: "BU Min 3x", fieldName: "BUHours3x__c", type: "number", typeAttributes:{minimumFractionDigits: "1", maximumFractionDigits: "1"}},
            {label: "BU Max 5x", fieldName: "BUHours5x__c", type: "number", typeAttributes:{minimumFractionDigits: "1", maximumFractionDigits: "1"}},
        ]);
    },

    initProspect: function (cmp) {
        cmp.set("v.columns", [
            {label: "Create Date", fieldName: "PeriodStartDate__c", type: "date-local", editable: false, cellAttributes:{alignment:"left"}},
            {label: "Billing", fieldName: "YendBillingNet__c", type: "currency" },
            {label: "Payroll", fieldName: "YendPayroll__c", type: "currency" },
            {label: "Tax", fieldName: "YendErTaxes__c", type: "currency" },
            {label: "WC Premium", fieldName: "YendWcPrem__c", type: "currency" },
            {label: "Commissions", fieldName: "YendCommsTotal__c", type: "currency" },
            {label: "Client Investment", fieldName: "YendExpenses__c", type: "currency"},
            {label: "Net Margin", fieldName: "YendMargin__c", type: "currency" },
            {label: "BU Min 3x", fieldName: "BUHours3x__c", type: "number", typeAttributes:{minimumFractionDigits: "1", maximumFractionDigits: "1"}},
            {label: "BU Max 5x", fieldName: "BUHours5x__c", type: "number", typeAttributes:{minimumFractionDigits: "1", maximumFractionDigits: "1"}},
        ]);
    },

    setIsProspect: function (cmp, isProspect) {
        cmp.set("v.isProspect", isProspect);
        if (isProspect) {
            this.initProspect(cmp);
        } else {
            this.init(cmp);
        }
    },

    showToast: function (cmp, title, message, variant, mode){
        cmp.find("notifLib").showToast({
            "title": title,
            "message": message,
            "variant": variant,
            "mode": mode
        });
    },

});