import { LightningElement, api, track, wire } from 'lwc';
import { getRecord, updateRecord } from 'lightning/uiRecordApi';

import { ShowToastEvent } from 'lightning/platformShowToastEvent';
import getTasks from '@salesforce/apex/SOFDisconnectPanelController.getTasks';
import initiateDisconnect from '@salesforce/apex/SOFDisconnectPanelController.initiateDisconnect';

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
            this.contractStatus = this.record.fields.Service_End_Reason__c.value;
            this.custReqDiscoDate = this.record.fields.Customer_Requested_Disconnect_Date__c.value;
            const contactName = this.record.fields.Disconnect_Contact__r.value;
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
            this.discoContact = contactName.fields.Name.value ;
            console.log( 'this.discoContact', this.discoContact );
            console.log( 'this.discoReqRecievedDate', this.discoReqRecievedDate );
            console.log( 'this.endReasonNotes', this.endReasonNotes );
            console.log( 'this.equipPickupForDisco', this.equipPickupForDisco );
            console.log( 'this.proceedDisco', this.proceedDisco );
            console.log( 'this.serviceEndReason', this.serviceEndReason );
            console.log( 'this.status', this.status );
            console.log( 'this.subReasons', this.subReasons );            
            
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

    // funtion for the disconnect button
    initiateDisconnect() {
        
        this.isLoading = true;
        const fields = {};
        const outputID = this.recordId;
        fields.Id = this.recordId;
        fields.Status = 'Disconnect in Progress';
        fields.Service_End_Reason__c = 'Draft';
        // Format the selected date to 'YYYY-MM-DD'
        let date = new Date( this.selectedDate );
        let formattedDate = date.toISOString().split( 'T' )[ 0 ];
        fields.Customer_Requested_Disconnect_Date__c = formattedDate;
        const recordInput = { fields };
        
        if ( this.hasChildSOF ) {
            this.isLoading = true;
            setTimeout( () => {
                initiateDisconnect( { recordId: outputID } )
                    .then( result => {
                        console.log( 'initiateDisconnect result', result );
                        this.getTasks();
                        this.showToast( 'Disconnect Process Started', 'The disconnect process has been started.', 'success' );
                        this.isLoading = false;
                    } )
                    .catch( error => {
                        console.log( 'initiateDisconnect error', error );
                        this.showToast( 'Unable To Start Disconnect Process', 'The disconnect process has not been started.', 'error' );
                        this.isLoading = false;
                    } );
            }, 5000 );
        } else {
            this.isLoading = true;
            
            updateRecord( recordInput )
                .then( result => {
                    setTimeout( () => {
                        console.log( 'updateRecord result', result );
                        this.getTasks();
                        this.showToast( 'Record Updated', 'The record has been updated.', 'success' );
                        this.isLoading = false;
                    }, 5000 );
                } )
                .catch( error => {
                    console.log( 'updateRecord error', error );
                    this.showToast( 'Record Update Failed', 'The record has not been updated.', 'error' );
                    this.isLoading = false;
                } );
            
        }
        
    }
    
    // function to get the tasks
    getTasks() {
        this.isLoading = true;
        const outputID = this.recordId
        const updateTrys = 5;
        getTasks( { recordId: outputID } )
            .then( result => {
                console.log( 'getTasks ' );
                console.log( { result } );
                this.result = result;
                if ( result != null ) {
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