/**
 * Created by CElim on 4/26/2019.
 */
({
    loadData: function (cmp, event) {
        cmp.set("v.isLoading", true);
        let action = cmp.get("c.getPricingWcCodes");
        action.setParams({"recordId":cmp.get("v.clientPricScenId")});
        action.setCallback(this, function(response) {
            cmp.set("v.isLoading", false);
            if(response.getState() === "SUCCESS"){
                cmp.set("v.data", response.getReturnValue());
                this.afterLoadData(cmp, event);
            }else{
                console.error("Get Pricing Scenario: ", response.getError());
            }
        });
        $A.enqueueAction(action);
    },

    afterLoadData: function (cmp, event) {
        let data = cmp.get("v.data");
        let netMargin = 0;
        let totalPayroll = 0;
        let totalPremiumBasedPayroll = 0;
        let totalWcPremium = 0;
        let totalSiMax = 0;
        for (let i = 0; i< data.length; ++i) {
            let row = data[i];
            netMargin +=  row.DesiredMarginDollars__c;
            totalPayroll += row.AnnualTaxablePayInCode__c;
            totalPremiumBasedPayroll += row.AnnualPremPayInCode__c;
            totalWcPremium += row.WcPremiumBlended__c;
            totalSiMax += row.SI_Max_Blended__c;
        }
        cmp.set("v.netMargin", netMargin);
        cmp.set("v.totalPayroll", totalPayroll);
        cmp.set("v.totalPremiumBasedPayroll", totalPremiumBasedPayroll);
        cmp.set("v.totalWcPremium", totalWcPremium);
        cmp.set("v.totalSiMax", totalSiMax);
    },

    updateFooterTotals: function (cmp, event, sumData) {
    },

    fireComponentEvent : function(cmp, type, data) {
        let compEvent = cmp.getEvent("setState");
        compEvent.setParams({
            "newState": {
                "component": cmp.get("v.containerName"),
                "type": type,
                "value": data
            }
        });
        compEvent.fire();
    },

    changeRecordId: function (cmp, event, recId) {
        cmp.set("v.clientPricScenId", recId);
        this.loadData(cmp, event);
    },

    showToast: function (cmp, title, message, variant, mode){
        cmp.find("notifLib").showToast({
            "title": title,
            "message": message,
            "variant": variant,
            "mode": mode
        });
    }
});