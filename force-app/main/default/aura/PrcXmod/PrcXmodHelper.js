/*
 * Copyright (c) 2018. Barrett Business Services, Inc. All Rights Reserved
 */
({
    loadData: function(cmp, event){
        this.loadDataPublished(cmp, event);
        this.loadDataRenewalYear(cmp, event);
        this.loadDataHistory(cmp, event);
        this.loadDataRecommended(cmp, event);
    },

    loadDataPublished: function(cmp, event){
        cmp.set("v.isLoading", true);
        var action = cmp.get("c.getPublishedXmods");
        action.setParams({
            "recordId":cmp.get("v.clientPricScenId"),
            "maxRows":"5"
        });
        action.setCallback(this, function(response) {
            cmp.set("v.isLoading", false);
            var state = response.getState();
            if(state === "SUCCESS"){
                cmp.set("v.dataPublished", response.getReturnValue() );
                if(response.getReturnValue().length == 0){
                    cmp.set("v.hasPublishedXmod", false);
                }
                this.afterLoadDataPublished(cmp, event);
            }else{
                console.error("Error loading Published Xmod data: ", response.getError());
            }
        });
        $A.enqueueAction(action);
    },

    loadDataRenewalYear: function(cmp, event){
        cmp.set("v.isLoading", true);
        var action = cmp.get("c.getRenewalYearXmods");
        action.setParams({
            "recordId": cmp.get("v.clientPricScenId")
        });
        action.setCallback(this, function(response) {
            cmp.set("v.isLoading", false);
            var state = response.getState();
            if(state === "SUCCESS"){
                cmp.set("v.dataRenewalYear", response.getReturnValue() );
            }else{
                console.error("Error loading Renewal Year Xmod data: ", response.getError());
            }
        });
        $A.enqueueAction(action);
    },

    loadDataHistory: function(cmp, event){
        cmp.set("v.isLoading", true);
        var action = cmp.get("c.getXmodHistory");
        action.setParams({
            "recordId": cmp.get("v.clientPricScenId"),
            "maxRows":"5"
        });
        action.setCallback(this, function(response) {
            cmp.set("v.isLoading", false);
            var state = response.getState();
            if(state === "SUCCESS"){
                cmp.set("v.dataHistory", response.getReturnValue() );
            }else{
                console.error("Error loading History Xmod data: ", response.getError());
            }
        });
        $A.enqueueAction(action);
    },

    loadDataRecommended: function(cmp, event){
        cmp.set("v.isLoading", true);
        var action = cmp.get("c.getXmodRecommended");
        action.setParams({"recordId": cmp.get("v.clientPricScenId")});
        action.setCallback(this, function(response) {
            cmp.set("v.isLoading", false);
            var state = response.getState();
            if(state === "SUCCESS"){
                cmp.set("v.dataRecommended", response.getReturnValue() );
                if(response.getReturnValue().length === 0){
                    cmp.set("v.hasRecommendedXmod", false);
                }else{
                    cmp.set("v.hasRecommendedXmod", true);
                }
            }else{
                console.error("Error loading Recommended Xmod data: ", response.getError());
            }
        });
        $A.enqueueAction(action);
    },

    afterLoadDataPublished: function(cmp, event){
        var burUrl = "";
        var burLabel = "";
        var pubData = cmp.get("v.dataPublished");
        if(pubData && pubData.length > 0){
            if(pubData[0].ClientPricingScenario__r.BureauReportUrl__c && pubData[0].ClientPricingScenario__r.BureauReportUrl__c.length > 0){
                burUrl = pubData[0].ClientPricingScenario__r.BureauReportUrl__c;
                burLabel = "https://exmod.com/" + burUrl.substring(burUrl.indexOf("=", 0) + 1);
            }
        }
        cmp.set("v.BureauReportUrl", burUrl);
        cmp.set("v.BureauReportUrlLabel", burLabel);
    },

    saveXmod: function(cmp, event, xmodData){
        cmp.set("v.isLoading", true);
        var action = cmp.get("c.saveRenewalXmods");
        var xmodDataJSON = JSON.stringify(xmodData);
        action.setParams({"xmodList": xmodDataJSON});
        action.setCallback(this, function (response) {
            cmp.set("v.isLoading", false);
            var state = response.getState();
            if(state === "SUCCESS"){
                // clear the Cancel & Save buttons
                cmp.find("xmodRenewalTable").set("v.draftValues", null);
                this.fireComponentEvent(cmp, "dataSaved", xmodData);
                this.loadDataRenewalYear(cmp, event);
            }else{
                this.showToast(cmp, "Sorry to interrupt you", "An error occurred while saving the Xmod value", "error", "sticky");
            }
        });
        $A.enqueueAction(action);
    },

    changeRecordId: function (cmp, event, recId) {
        cmp.set("v.clientPricScenId", recId);
        this.loadData(cmp, event);
    },

    setIsProspect: function (cmp, isProspect) {
        cmp.set("v.isProspect", isProspect);
    },

    fireComponentEvent : function(cmp, type, data) {
        var compName = cmp.get("v.containerName");
        var compEvent = cmp.getEvent("setState");

        compEvent.setParams({
            "newState": {
                "component": compName,
                "type": type,
                "value": data
            }
        });
        compEvent.fire();
    },

    showToast: function (cmp, title, message, variant, mode) {
        cmp.find("notifLib").showToast({"title": title, "message": message, "variant": variant, "mode": mode});
    }
});