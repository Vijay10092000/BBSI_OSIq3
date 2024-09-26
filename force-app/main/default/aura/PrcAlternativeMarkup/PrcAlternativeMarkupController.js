/**
 * Created by CElim on 4/26/2019.
 */
({
    init: function (cmp, event, helper) {
        cmp.set("v.columns", [
            {label: "State", fieldName: "State_Code__c", type: "text", initialWidth: 70, cellAttributes: {alignment:"left"}},
            {label: "WC Code", fieldName: "WC_Code__c", type: "text", initialWidth: 100, cellAttributes: {alignment:"left"}},
            {label: "Net Margin", fieldName: "DesiredMarginDollars__c", type: "currency", initialWidth: 120, typeAttributes: {minimumFractionDigits: "2", maximumFractionDigits: "2"}},
            {label: "Modified WC Rate", fieldName: "Modified_WC_Rate__c", type: "number", typeAttributes: {minimumFractionDigits: "4", maximumFractionDigits: "4"}},
            {label: "Payroll in Code", fieldName: "AnnualTaxablePayInCode__c", type: "currency", typeAttributes: {minimumFractionDigits: "2", maximumFractionDigits: "2"}},
            {label: "Premium Based Payroll", fieldName: "AnnualPremPayInCode__c", type: "currency", typeAttributes: {minimumFractionDigits: "2", maximumFractionDigits: "2"}},
            {label: "WC Premium", fieldName: "WcPremiumBlended__c", type: "currency", typeAttributes: {minimumFractionDigits: "2", maximumFractionDigits: "2"}},
            {label: "WC Premium % of Payroll", fieldName: "WcPremiumBlendedPercentOfPayroll__c", type: "number", typeAttributes: {minimumFractionDigits: "2", maximumFractionDigits: "2"}},
            {label: "Blended Markup %", fieldName: "Markup_Blended__c", type: "number", typeAttributes: {minimumFractionDigits: "3", maximumFractionDigits: "3"}, cellAttributes: {alignment:"center"}},
            {label: "Premium Max Safety Incentive", fieldName: "SI_Max_Blended__c", type: "currency", typeAttributes: {minimumFractionDigits: "2", maximumFractionDigits: "2"}}
        ]);
    },

    onAppEvent: function (cmp, event, helper) {
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
                break;
            case "dataChange":
                if( appData.value === "wcCodes"){
                    console.log(new Date().getTime() + " " + cmp.get("v.containerName") + " " + appData.type + ": " + appData.value);
                    helper.loadData(cmp, event);
                }
                break;
        }
    }
});