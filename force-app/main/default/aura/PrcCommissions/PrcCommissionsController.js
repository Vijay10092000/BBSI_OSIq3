/*
 * Copyright (c) 2018. Barrett Business Services, Inc. All Rights Reserved
 */
({
    init: function (cmp, event, helper) {
        helper.init(cmp);
        helper.initCustomDataset(cmp);
    },

    handleSaveTable: function (cmp, event, helper) {
        var draftValues = event.getParam("draftValues");
        helper.setCommRateState(cmp, draftValues);
    },

    handleRowAction: function (cmp, event, helper) {

    },

    onAppEvent: function(cmp, event, helper){
        var appData = event.getParam("context");
        switch(appData.type){
            case "recordId":
                helper.changeRecordId(cmp, event, appData.value);
                break;
            case "dataChange":
                helper.loadData(cmp, event);
                break;
            case "isProspect":
                helper.setIsProspect(cmp, appData.value);
                break;
            case "summaryUpdate":
                console.log(new Date().getTime() + " " + cmp.get("v.containerName") + " " + appData.type + ": " + appData.value);
                helper.updateFooterTotals(cmp, event, appData.value);
                break;
        }
    },

    handleNoReferralPartner: function (cmp, event, helper) {
        let useReferralPartner = !cmp.get("v.noReferralPartner");
        helper.saveUseReferralPartner(cmp, useReferralPartner);
    },

    handleNoBdm: function (cmp, event, helper) {
        let useBdm = !cmp.get("v.noBdm");
        helper.saveUseBdm(cmp, useBdm);
    }
});