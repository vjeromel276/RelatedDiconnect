import { LightningElement, api, track, wire } from 'lwc';
import { getRecord, updateRecord } from 'lightning/uiRecordApi';

import { ShowToastEvent } from 'lightning/platformShowToastEvent';
import getTasks from '@salesforce/apex/SOFDisconnectPanelController.getTasks';

export default class SOFDisconnectPanel extends LightningElement {
    @api recordId;
    @api hasChildSOF= false;
    draftValues = [];
    @track taskData = [];
    @api isDiscoInProg;
    sofStatus = '';
    @track milestoneTasks = {};
    @track record = {};
    @track taskRecords = {};
    @track selectedDate;
    @api hasTasks = false;
    @track isLoading = false;
    @track tasksFetchError = false;
    @track useNewTable = false;
    @track isCheckboxLoading = false;
    contractStatus = '';
    custReqDiscoDate = '';
    discoContact = [];
    discoContactName = {};
    discoReqRecievedDate = '';
    endReasonNotes = '';
    equipPickupForDisco = '';
    proceedDisco = '';
    serviceEndReason = '';
    status = '';
    subReasons = '';    
    result;
    
    fields = [
        'Order.Id',
        'Order.Status',
        'Order.Service_End_Reason__c',
        'Order.Customer_Requested_Disconnect_Date__c',
        'Order.Disconnect_Contact__c',
        'Order.Disconnect_Contact__r.Name',
        'Order.Disconnect_Request_Received_Date__c',
        'Order.End_Reason_Notes__c',
        'Order.Equipment_Pickup_Needed__c',
        'Order.Has_Successor__c',
        'Order.Proceed_with_Disconnect__c',
        'Order.Service_End_Reasons__c',
        'Order.ServiceEndSub_Reasons__c',
    ];

    @wire( getRecord, { recordId: '$recordId', fields:'$fields' } )
    getRecordData( { error, data } ) {
        this.isLoading = true;
        if ( data ) {
            this.isLoading = false;
            console.log( 'data', data );
            this.record = data;
            this.useNewTable = true;
            this.sofStatus = this.record.fields.Status.value;
            this.hasChildSOF = this.record.fields.Has_Successor__c.value;
            this.contractStatus = this.record.fields.Service_End_Reason__c.value;
            this.custReqDiscoDate = this.record.fields.Customer_Requested_Disconnect_Date__c.value;
            this.discoContact = this.record.fields.Disconnect_Contact__c.value;
            this.discoContactName = this.record.fields.Disconnect_Contact__r.value;
            this.discoReqRecievedDate = this.record.fields.Disconnect_Request_Received_Date__c.value;
            this.endReasonNotes = this.record.fields.End_Reason_Notes__c.value;
            this.equipPickupForDisco = this.record.fields.Equipment_Pickup_Needed__c.value;
            this.proceedDisco = this.record.fields.Proceed_with_Disconnect__c.value;
            this.serviceEndReason = this.record.fields.Service_End_Reasons__c.value;
            this.status = this.record.fields.Status.value;
            this.subReasons = this.record.fields.ServiceEndSub_Reasons__c.value;
            console.log( 'this.sofStatus', this.sofStatus );
            console.log( 'this.contractStatus', this.contractStatus );
            console.log( 'this.custReqDiscoDate', this.custReqDiscoDate );
            console.log( 'this.discoContact', this.discoContact );
                        
            
            // can add multiple if statements to check for different statuses
            if( this.sofStatus == 'Disconnect in Progress' ) {
                this.getTasks();
            }
        } else if ( error ) {
            console.log( 'error', error );
        }
    }

    columns = [
        { label: 'Milestone Name', fieldName: 'Milestone_Name__c', type: 'text' },
        { label: 'Task Name', fieldName: 'recordLink', type: 'url', typeAttributes: { label: { fieldName: 'Name' }, target: '_blank' } },
        { label: 'Complete', fieldName: 'MPM4_BASE__Complete__c', type: 'boolean', editable: true },
        { label: 'Not Needed', fieldName: 'Not_Applicable__c', type: 'boolean', editable: true },
    ];

    /**
     * initiateDisconnect()
     * This function is used to initiate the disconnect process
     * 
     * @param       {object}            event           The event object
     * @return      {void}                              This function doesn't return anything
     * 
     * @uses        updateRecord()                      To update the record
     * @uses        showToast()                         To show a toast message
     * @uses        getTasks()                          To get the tasks
     * 
     */
    initiateDisconnect() {
        console.log( 'initiateDisconnect');
        this.isLoading = true;
        const fields = {};
        fields.Id = this.recordId;
        fields.Status = 'Disconnect in Progress';
        fields.Service_End_Reason__c = 'Draft';
        // Format the selected date to 'YYYY-MM-DD'
        if ( this.selectedDate != null ) {
            let date = new Date( this.selectedDate );
            let formattedDate = date.toISOString().split( 'T' )[ 0 ];
            fields.Customer_Requested_Disconnect_Date__c = formattedDate;
        }
        
        const recordInput = { fields };
        
        updateRecord( recordInput )
            .then( result => {
                setTimeout( () => {
                    console.log( 'updateRecord result', result );
                    this.getTasks();
                    this.showToast( 'Record Updated', 'The record has been updated.', 'success' );
                    this.isLoading = false;
                }, 100 );
            } )
            .catch( error => {
                console.log( 'updateRecord error', error );
                this.showToast( 'Record Update Failed', 'The record has not been updated.', 'error' );
                this.isLoading = false;
            } );
    }
    
    /**
     * getTasks()
     * This function is used to get the tasks
     * 
     * @param       {object}            event           The event object
     * @return      {void}                              This function doesn't return anything
     * 
     * @uses        getTasks()                          To get the tasks
     * @uses        showToast()                         To show a toast message
     * 
     * TODO: possibly add a retry function to retry the getTasks() function if it fails
     * 
     */
    getTasks() {
        this.isLoading = true;
        const outputID = this.recordId
        const updateTrys = 5;
        getTasks( { recordId: outputID } )
            .then( result => {
                console.log( 'getTasks ' );
                console.log( { result } );
                // this.result = result;
                if ( result != null ) {
                    //!LAST CHANGE
                    this.result = result;
                    this.taskData = result.map( task => {
                        return {
                            ...task,
                            
                            recordLink: `/lightning/r/MPM4_BASE__Milestone1_Task__c/${ task.Id }/view`
                        };
                    } );
                    this.isDiscoInProg = true;
                    this.showToast( 'Disconnect Process Started', 'The disconnect process has been started.', 'success' );
                    this.tasksFetchError = false;
                } else {
                    this.isDiscoInProg = true;
                    this.tasksFetchError = true;
                    
                }
                this.isLoading = false;
            }
            )
            .catch( error => {
                console.log( 'getTasks error', error );
                this.showToast( 'Unable To Start Disconnect Process', 'The disconnect process has not been started.', 'error' );
                this.isLoading = false;
            }
            );
    }

    

   

    
    //~ old new way of doing the data table
    handleCheckboxChange( event ) {
        event.preventDefault();
        this.isLoading = true;
        const fields = {};
        const checkBox = event.target.dataset.field;
        console.log( 'checkBox', checkBox );
        if ( checkBox === 'MPM4_BASE__Complete__c' ) {
            fields.Id = event.target.dataset.id;
            fields.MPM4_BASE__Complete__c = event.target.checked;
        } else if ( checkBox === 'Not_Applicable__c' ) {
            fields.Id = event.target.dataset.id;
            fields.Not_Applicable__c = event.target.checked;
        }
        
        const thisTaskList = this.result;
        console.log( 'thisTaskList', thisTaskList );   
        const recordInput = { fields };
        console.log( 'recordInput', recordInput );
        //~ normal salesforce lwc api updateRecord
        updateRecord( recordInput )
            .then( result => {
                console.log( 'updateRecord result', result );
                this.getTasks();
                this.showToast( 'Record Updated', 'The record has been updated.', 'success' );
                this.isLoading = false;
            } )
            .catch( error => {
                console.log( 'updateRecord error', error );
                this.getTasks();
                this.showToast( 'Record Update Failed', 'The record has not been updated.', 'error' );
                this.isLoading = false;
            } );
        
        // try {
        //     const result = this.retryUpdateRecord( recordInput );
        //     console.log( 'updateRecord result', result);
        //     this.getTasks();
        // } catch (error) {
        //     console.log( 'updateRecord error', error );
        //     this.getTasks();
        // }
        
    }
   

    


    retryUpdateRecord( recordInput, retries = 5, delay = 20 ) {
        this.isCheckboxLoading = true;  // Start loading
        while ( retries > 0 ) {
            
            console.log('retries', retries);
            try {
                const result = updateRecord( recordInput );
                this.showToast( 'Record Updated', 'The record has been updated.', 'success' );
                this.getTasks();
                this.isLoading = false;
                return result;
            } catch ( error ) {
                retries -= 1;
                if ( retries === 0 ) {
                    this.showToast( 'Record Update Failed', 'The record has not been updated.', 'error' );
                    this.getTasks();
                    this.isLoading = false;
                    throw error;
                }
                // waits 1 second
                new Promise( resolve => setTimeout( resolve, delay ) );
            }
        }
        this.isCheckboxLoading = false;  // End loading
    }
    
    handleDateChange( event ) {
        this.selectedDate = event.target.value;
        console.log( 'selectedDate', this.selectedDate );
    }

    // toast message helper function
    showToast(title, message, variant) {
        const evt = new ShowToastEvent({
            title: title,
            message: message,
            variant: variant,
        });
        this.dispatchEvent(evt);
    }        
}