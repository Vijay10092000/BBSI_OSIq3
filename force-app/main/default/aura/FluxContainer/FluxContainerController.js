/*
	Flux Container code from an article on Medium.com by Jeffery Shivers
	https://medium.com/@jefferyshivers/flux-and-lightning-components-5ce975027bef

 */
({
    setState: function (cmp, event, helper) {
        var update = event.getParam("update");

        if (
            update.containerName &&
            cmp.get("v.containerName") &&
            update.containerName === cmp.get("v.containerName")
        ) {
            helper.setState(
                cmp,
                update.containerName,
                update.state,
                update.callback
            );
        } else {
            console.error("There was a problem pairing containerNames.");
        }
    }
})