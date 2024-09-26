/*
	Flux Container code from an article on Medium.com by Jeffery Shivers
	https://medium.com/@jefferyshivers/flux-and-lightning-components-5ce975027bef

 */
({
    setState : function (cmp, containerName, state, callback) {
        var res = {
                unavailable_attributes: []
            },
            updates = [];

        for (var param in state) {
            var attr = "v." + param;
            var val = state[param];

            if (cmp.get(attr)) {
                cmp.set(attr, val);
                updates.push({
                    attribute: attr,
                    value: val
                });
            } else {
                res.unavailable_attributes.push(param);
            }
        }

        // post the update as an application event
        if (updates.length > 0) {
            var updateEvent =
                cmp.getEvent("e.c:FluxContainer_getState");
            updateEvent.setParams({
                containerName: containerName,
                state: updates
            });
            updateEvent.fire();
        }

        // call the optional callback
        callback && callback(res);
    }
})