({
	doInit : function(component, event, helper) {
    console.log('doInit start');
	var action = component.get("c.getDupesLightning");
    var vleadId = component.get("v.recordId");
    var archive = component.get("v.archive");
    console.log('archive ' + archive);
    console.log('vleadid ' + vleadId);

    action.setParams({"leadId":vleadId,
                      "archive": archive});
    console.log('after actionp');
    action.setCallback(this, function(response) {
      var state = response.getState();
      if (state === "SUCCESS") {
       console.log('Success');
       console.log(response.getReturnValue());
       component.set("v.duplicates", response.getReturnValue());
      }
      else if (state === "INCOMPLETE") {
        console.log('INCOMPLETE');
      }
      else if (state === "ERROR") {
          var errors = response.getError();
          if (errors) {
              if (errors[0] && errors[0].message) {
                  console.log("Error message: " + 
                           errors[0].message);
              }
          } else {
              console.log("Unknown error");
          }
      }
    });

    $A.enqueueAction(action);
    
  },
  navigateToDupePage : function(component,event,helper){
    var vleadId = component.get("v.recordId");
    var url = '/apex/DupeCatcherPage?Type=New&id=' + vleadId;
    console.log('url ' + url);
    var urlEvent = $A.get("e.force:navigateToURL");
    urlEvent.setParams({"url":url});
    urlEvent.fire();
  },
  updateDupestatus : function(component,event,helper){
    var vleadid = component.get("v.recordId");
    var saveEvent = component.get("c.saveLead");
    saveEvent.setParams({"leadID":vleadid});
    saveEvent.setCallback(this,function(response){
      var state = response.getState();
      console.log('state: ' + state);
      if(state == 'SUCCESS'){
        $A.get('e.force:refreshView').fire();
      }
    });
    $A.enqueueAction(saveEvent);
  },
})