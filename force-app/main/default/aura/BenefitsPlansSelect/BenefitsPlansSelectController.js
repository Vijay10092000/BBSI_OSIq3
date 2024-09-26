({
    handleInit: function (component, event, helper) {
        helper.setup(component);
    },

    handleSave: function(component, event, helper) {
        helper.save(component);
    },

    handleCancel: function(component, event, helper) {
        helper.shutdown(component);
    },

    handleChange: function (component, event, helper) { 
        var selected = event.getParam("value");
        component.set("v.selectedOptions", selected);
    },
})