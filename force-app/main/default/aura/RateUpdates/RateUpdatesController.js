({/** DELETE AS PART OF RPC PHASE 4
	doInit : function(component, event, helper) {
        var actionReferralPartner = component.get("c.getReferralPartnerById");
        actionReferralPartner.setParam(
            "recordId", component.get("v.recordId")
        );
        actionReferralPartner.setCallback(this, function(response) {  
            var rpsRecord = response.getReturnValue();
            
            if (rpsRecord == null) {
                alert('No Referral Source found');
                helper.closeWindow(component);
            }
			component.set("v.rpsRecord", rpsRecord);
            component.set('v.commissionType', rpsRecord.Referral_Partner_Commission_Type__c);
            
            var rate = rpsRecord.Commission_Rate__c;
//            if (rpsRecord.Referral_Partner_Commission_Type__c.toString().startsWith('%')) {
//                rate = rate * 100;
//            }
            component.set('v.commissionRate', rate);
        });                           
    	$A.enqueueAction(actionReferralPartner); 
        
        var actionPicklist = component.get("c.getCommissionTypes");
        actionPicklist.setParams({
            objectType: "Referral_Partner__c",
            selectedField: "Referral_Partner_Commission_Type__c"
        });
        actionPicklist.setCallback(this, function(response) {
            var list = response.getReturnValue();
            component.set("v.typePickValues", list);
        });
        $A.enqueueAction(actionPicklist);
	},
    
    onSave : function(component, event, helper) {        
        if (helper.validateInputFields(component)) {
//            var rate = component.set('v.commissionRate');
//            var type = component.set('v.commissionType');
//            if (type.startsWith('%')) {
//                rate = rate / 100;
//            }
            helper.saveRecord(component, helper);
        }                         
    },
    
    onCancel : function(component, event, helper) {
        helper.closeWindow(component);
    }, 
    
    updateType : function(component, event, helper){
        component.set("v.commissionType", component.find("pickType").get("v.value"));
    }**/
})