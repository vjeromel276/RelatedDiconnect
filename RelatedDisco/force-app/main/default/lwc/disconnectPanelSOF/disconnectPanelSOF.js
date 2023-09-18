import { LightningElement, api, track, wire } from 'lwc';
import { getRecord, updateRecord } from 'lightning/uiRecordApi';

import CUST_REQ_DISCO_DATE from '@salesforce/schema/Order.Customer_Requested_Disconnect_Date__c';
import STATUS from '@salesforce/schema/Order.Status';
import { ShowToastEvent } from 'lightning/platformShowToastEvent';
import getTasks from '@salesforce/apex/SOFDisconnectPanelController.getTasks';
import initiateDisconnect from '@salesforce/apex/SOFDisconnectPanelController.initiateDisconnect';
import updateMilestone1Tasks from '@salesforce/apex/SOFDisconnectPanelController.updateMilestone1Tasks';

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

    @wire( getRecord, { recordId: '$recordId', fields: [ STATUS,CUST_REQ_DISCO_DATE ] } )
    getRecordData( { error, data } ) {
        this.isLoading = true;
        if ( data ) {
            this.isLoading = false;
            console.log( 'data', data );
            this.record = data;
            this.sofStatus = this.record.fields.Status.value;
            this.selectedDate = this.record.fields.Customer_Requested_Disconnect_Date__c;
            const date = JSON.parse( JSON.stringify( this.selectedDate ) );
            this.selectedDate = date.displayValue;
            // can add multiple if statements to check for different statuses
            if( this.sofStatus == 'Disconnect in Progress' ) {
                this.getTasks();
            }
        } else if ( error ) {
            console.log( 'error', error );
        }
    }
    
    connectedCallback() {
        console.log( 'recordId', this.recordId );
        // can add multiple if statements to check for different statuses
        if( this.sofStatus == 'Disconnect in Progress' ) {
                this.getTasks();
            }
    }

    columns = [
        { label: 'Milestone Name', fieldName: 'Milestone_Name__c', type: 'text' },
        { label: 'Task Name', fieldName: 'Name', type: 'text' },
        { label: 'Complete', fieldName: 'MPM4_BASE__Complete__c', type: 'boolean', editable: true },
        { label: 'Not Needed', fieldName: 'Not_Applicable__c', type: 'boolean', editable: true },
        { label: 'Resource', fieldName: 'Resource_Name__c', type: 'text', editable: true }
    ];

    initiateDisconnect() {
        if ( this.selectedDate == ''|| this.selectedDate == null ) {
            const evt = new ShowToastEvent( {
                title: 'You must select a date',
                message: 'There must be a customer requested disconnect date',
                variant: 'warning',
            } );
            this.dispatchEvent( evt );
        } else {
            this.isLoading = true;
            const fields = {}
            const outputID = this.recordId
            fields.Id = this.recordId
            fields.Status = 'Disconnect in Progress';
            fields.Service_End_Reason__c = 'Draft';
            fields.Customer_Requested_Disconnect_Date__c = this.selectedDate;
            const recordInput = { fields };
            
            if ( this.hasChildSOF ) {
                initiateDisconnect( { recordId: outputID } )
                    .then( result => {
                        console.log( 'initiateDisconnect result', result );
                        this.getTasks();
                        const evt = new ShowToastEvent( {
                            title: 'Record Updated',
                            message: 'The record has been updated.',
                            variant: 'brand',
                        } );
                        this.dispatchEvent( evt );
                        this.isLoading = false;
                    } )
                    .catch( error => {
                        console.log( 'initiateDisconnect error', error );
                        const evt = new ShowToastEvent( {
                            title: 'Record Update Failed',
                            message: 'The record has not been updated.',
                            variant: 'error',
                        } );
                        this.dispatchEvent( evt );
                        this.isLoading = false;
                    } );
            } else {
                this.isLoading = true;     
                updateRecord( recordInput )                    
                    .then( result => {
                        console.log( 'updateRecord result', result );
                        this.getTasks();
                        const evt = new ShowToastEvent( {
                            title: 'Record Updated',
                            message: 'The record has been updated.',
                            variant: 'brand',
                        } );
                        this.dispatchEvent( evt );
                        this.isLoading = false;
                    }
                    )
                    .catch( error => {
                        console.log( 'updateRecord error', error );
                        const evt = new ShowToastEvent( {
                            title: 'Record Update Failed',
                            message: 'The record has not been updated.',
                            variant: 'error',
                        } );
                        this.dispatchEvent( evt );
                        this.isLoading = false;
                    }
                    );
            }
        }
        
    }
    
    getTasks() {
        this.isLoading = true;
        const outputID = this.recordId
        getTasks( { recordId: outputID } )
            .then( result => {
                console.log( 'getTasks ' );
                console.log( { result } );
                this.taskData = result;
                if ( this.taskData.length > 0 ) {
                    this.isDiscoInProg = true;
                    const evt = new ShowToastEvent( {
                        title: 'Disconnect Process Started',
                        message: 'The disconnect process has been started.',
                        variant: 'warning',
                    } );
                    this.dispatchEvent( evt );
                    this.isLoading = false;
                    }
            }
        )
            .catch( error => {
                console.log( 'getTasks error', error );
                const evt = new ShowToastEvent( {
                        title: 'Unable To Start Disconnect Process',
                        message: 'The disconnect process has not been started.',
                        variant: 'error',
                    } );
                this.dispatchEvent( evt );
                this.isLoading = false;
            }
        );
    }

    onCellChange( event ) {
        console.log( 'event.detail.draftValues', event.detail.draftValues[0] );
        this.draftValues = event.detail.draftValues;
         // Loop through each draft value
        this.draftValues.forEach( draft => {
            // Find the index of the task in the taskData array that has the same Id as the draft
            let index = this.taskData.findIndex( task => task.Id === draft.Id );

            // If a task with the same Id is found, update it with the draft values
            if ( index !== -1 ) {
                this.taskData[ index ] = { ...this.taskData[ index ], ...draft };
            }
        } );
        // console.log( 'this.taskData', this.taskData );
        this.draftValues = [];
        this.taskData = [ ...this.taskData ];
        this.hasTasks = true;
        
    }
    
    updateTasks( event ) {
        event.preventDefault();
        const records = JSON.stringify( JSON.parse( JSON.stringify( this.taskData ) ) );
        console.log( 'taskRecords', records );
        this.isLoading = true;
        updateMilestone1Tasks( { tasks: records } )
            .then( result => {
                console.log( 'updateMilestone1Tasks result', result );
                this.getTasks();
                this.hasTasks = false;
                const evt = new ShowToastEvent( {
                    title: 'Milestone1 Tasks Updated',
                    message: 'The record has been updated.',
                    variant: 'brand',
                } );
                this.dispatchEvent( evt );
                this.isLoading = false;
            } )
            .catch( error => {
                console.log( 'updateMilestone1Tasks error', error );
                this.hasTasks = false;
                const evt = new ShowToastEvent( {
                    title: 'Milestone1 Tasks Update Failed',
                    message: 'The record has not been updated. Try again.',
                    variant: 'error',
                } );
                this.dispatchEvent( evt );                
                this.getTasks();
                this.isLoading = false;
            } );
        // End of updateMilestone1Tasks
    }

    handleCancel(event) {
        event.preventDefault();
        this.getTasks();
        this.draftValues = [];
        this.hasTasks = false;
        this.isLoading = false;
    }
    
    handleDateChange( event ) {
        this.selectedDate = event.target.value;
        console.log( 'selectedDate', this.selectedDate );
    }
        
}