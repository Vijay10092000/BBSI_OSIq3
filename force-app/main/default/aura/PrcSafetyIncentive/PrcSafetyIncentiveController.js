/**
 * Created by CElim on 1/25/2019.
 */
({
    init: function (cmp, event, helper) {
        var actions = [
            { label: "Delete", name: "delete" }
        ];
        cmp.set("v.columns", [
            {label: "Start Date", fieldName: "PeriodStartDate__c", type: "date-local", cellAttributes:{alignment:"left"}},
            {label: "Period", fieldName: "PeriodType__c", type: "text", cellAttributes:{alignment:"left"}},
            {label: "End Date", fieldName: "PeriodEndDate__c", type: "date-local", cellAttributes:{alignment:"left"}},
            {label: "Max Safety Incentive", fieldName: "YendMaxSI__c", type: "currency" },
            {label: "Claims", fieldName: "TotalClaims__c", type: "number", typeAttributes:{maximumFractionDigits: "0" }},
            {label: "Ultimate Expected", fieldName: "UltimateExpected__c", type: "currency" }
        ]);
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
                helper.loadData(cmp, event);
                break;
        }
    }
})