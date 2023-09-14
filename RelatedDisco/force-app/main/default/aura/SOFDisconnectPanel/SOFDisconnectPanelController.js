({
    doInit : function(component, event, helper) {
        component.set('v.columns', [
            {label: 'Milestone Name', fieldName: 'Milestone_Name__c', type: 'text'},
            {label: 'Task Name', fieldName: 'Name', type: 'text'},
            {label: 'Complete', fieldName: 'MPM4_BASE__Complete__c', type: 'boolean', editable: true},
            {label: 'Not Needed', fieldName: 'Not_Applicable__c', type: 'boolean', editable: true},
            {label: 'Resource', fieldName: 'Resource_Name__c', type: 'text', editable: true}
        ]);

        helper.getTasks(component);
        helper.getSofDetails(component);
    },

    initiateDisconnect : function(component, event, helper) {
        helper.initiateDisconnect(component);
    },

    handleSaveEdition: function (cmp, event, helper) {
        var draftValues = event.getParam('draftValues');

        helper.saveEdition(cmp, draftValues);
    },
    
    handleCancelEdition: function (cmp) {
        // do nothing for now...
    }
})