/**
 * Created by CElim on 1/25/2019.
 */
({
    loadData: function(cmp, event){
        cmp.set("v.isLoading", true);
        var action = cmp.get("c.getPricingSummaryHistoryRows");
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
        // this.loadData(cmp, event);
    },
    showToast: function (cmp, title, message, variant, mode){
        cmp.find("notifLib").showToast({
            "title": title,
            "message": message,
            "variant": variant,
            "mode": mode
        });
    }
})