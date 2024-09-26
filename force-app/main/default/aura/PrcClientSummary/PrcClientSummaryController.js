/*
 * Copyright (c) 2018. Barrett Business Services, Inc. All Rights Reserved
 */
({
    init: function (cmp, event, helper) {
        helper.init(cmp);
    },

    onAppEvent: function(cmp, event, helper){
        var appData = event.getParam("context");
        switch(appData.type){
            case "recordId":
                helper.changeRecordId(cmp, event, appData.value);
                break;
            case "isProspect":
                helper.setIsProspect(cmp, appData.value);
                break;
            case "summaryUpdate":
                console.log(new Date().getTime() + " " + cmp.get("v.containerName") + " " + appData.type + ": " + appData.value);
                helper.loadData(cmp, event);
                break;
        }
    }
});