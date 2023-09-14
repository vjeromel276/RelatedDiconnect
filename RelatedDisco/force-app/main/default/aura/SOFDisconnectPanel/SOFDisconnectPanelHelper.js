({
    getTasks: function (component) {
        var action = component.get("c.getTasks");
        action.setParams({ 'recordId': component.get('v.recordId') });
        action.setCallback(this, function(response) {
            var state = response.getState();
            if (state === "SUCCESS" ) {
                component.set("v.projectTasks", response.getReturnValue());
            }
        });
        
        $A.enqueueAction(action);
    },

    getSofDetails: function (component) {
        var action = component.get("c.getSofDetails");
        action.setParams({ 'recordId': component.get('v.recordId') });
        action.setCallback(this, function(response) {
            var state = response.getState();
            if (state === "SUCCESS" ) {
                component.set("v.orderInfo", response.getReturnValue());
            }
        });
        
        $A.enqueueAction(action);
    },

    initiateDisconnect: function (component) {
        var action = component.get("c.initiateDisconnect");
        //action.setParams({ 'recordId': component.get('v.recordId'),
        //                   'customerRequestedDiscoDate': component.get('v.customerRequestedDiscoDate')});
        action.setParams({ 'recordId': component.get('v.recordId')});
        action.setCallback(this, function(response) {
            var state = response.getState();
            if (state === "SUCCESS" ) {
                //component.set("v.orderInfo", response.getReturnValue());
                var toastEvent = $A.get("e.force:showToast");
                toastEvent.setParams({
                    "title": "Disconnect Initiated",
                    "message": "The disconnect has been initiated."
                });
                toastEvent.fire();
            }
        });
        
        $A.enqueueAction(action);
    },

    saveEdition: function (cmp, draftValues) {
        /*var self = this;
        // simulates a call to the server, similar to an apex controller.
        this
            .server
            .updateOpportunities(draftValues)
            .then($A.getCallback(function (response) {
                var state = response.state;

                if (state === "SUCCESS") {
                    var returnValue = response.returnValue;

                    if (Object.keys(returnValue.errors).length > 0) {
                        // the draft values have some errors, setting them will show it on the table
                        cmp.set('v.errors', returnValue.errors);
                    } else {
                        // Yay! success, initialize everything back
                        cmp.set('v.errors', []);
                        cmp.set('v.draftValues', []);
                        self.fetchData(cmp);
                    }
                } else if (state === "ERROR") {
                    var errors = response.error;
                    console.error(errors);
                }
            }));*/
    }
})