/*
 * Copyright (c) 2018. Barrett Business Services, Inc. All Rights Reserved
 * Created by agoganian on 10/18/2018.
 */
({
    loadData: function(cmp, event) {
        cmp.set("v.isLoading", true);
        var action = cmp.get("c.getPricingSummaryRows");
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

    initProspect: function (cmp) {
        cmp.set("v.columns", [
            {label: "XMOD", fieldName: "Xmod__c",
                type: "number",
                typeAttributes:{minimumFractionDigits: "4", maximumFractionDigits: "4" },
                initialWidth: 75},
            {label: "Margin % of Billing", fieldName: "MarginPercent__c", type: "number", typeAttributes:{minimumFractionDigits: "2", maximumFractionDigits: "2" }},
            {label: "Margin % of Payroll", fieldName: "MarginPercentPayroll__c", type: "number", typeAttributes:{minimumFractionDigits: "2", maximumFractionDigits: "2" }},
            {label: "Margin $ Per Head", fieldName: "MarginPerHead__c", type: "currency"},
            {label: "FTE", fieldName: "FTE__c",
                type: "number",
                typeAttributes:{minimumFractionDigits: "1", maximumFractionDigits: "1" },
                initialWidth: 75},
            {label: "Turnover %", fieldName: "Turnover__c", type: "number", typeAttributes:{maximumFractionDigits: "0" }}
        ]);
    },

    init: function (cmp) {
        cmp.set("v.columns", [
            {label: "Period", fieldName: "PeriodType__c", type: "text" },
            {label: "XMOD", fieldName: "Xmod__c",
                type: "number",
                typeAttributes:{minimumFractionDigits: "4", maximumFractionDigits: "4" },
                initialWidth: 75},
            {label: "Margin % of Billing", fieldName: "MarginPercent__c", type: "number", typeAttributes:{minimumFractionDigits: "2", maximumFractionDigits: "2" }},
            {label: "Margin % of Payroll", fieldName: "MarginPercentPayroll__c", type: "number", typeAttributes:{minimumFractionDigits: "2", maximumFractionDigits: "2" }},
            {label: "Margin $ Per Head", fieldName: "MarginPerHead__c", type: "currency"},
            {label: "FTE", fieldName: "FTE__c",
                type: "number",
                typeAttributes:{minimumFractionDigits: "1", maximumFractionDigits: "1" },
                initialWidth: 75},
            {label: "Turnover %", fieldName: "Turnover__c", type: "number", typeAttributes:{maximumFractionDigits: "0" }}
        ]);
    },
    
    showToast: function (cmp, title, message, variant, mode) {
        cmp.find("notifLib").showToast({"title": title, "message": message, "variant": variant, "mode": mode});
    },
    
    setIsProspect: function (cmp, isProspect) {
        cmp.set("v.isProspect", isProspect);
        if (isProspect) {
            this.initProspect(cmp); 
        } else {
            this.init(cmp);
        }
    }
});