import { LightningElement, api, track, wire } from 'lwc';
import { getRecord, updateRecord } from 'lightning/uiRecordApi';

import CUST_REQ_DISCO_DATE from '@salesforce/schema/Order.Customer_Requested_Disconnect_Date__c';
import STATUS from '@salesforce/schema/Order.Status';
import { ShowToastEvent } from 'lightning/platformShowToastEvent';
import getTasks from '@salesforce/apex/SOFDisconnectPanelController.getTasks';
import initiateDisconnect from '@salesforce/apex/SOFDisconnectPanelController.initiateDisconnect';

export default class SOFDisconnectPanel extends LightningElement {
    @api recordId;
    @api hasChildSOF= false;
    @track draftValues = [];
    @track taskData = [];
    @api isDiscoInProg;
    sofStatus = '';
    @track milestoneTasks = {};
    @track record = {};
    @track selectedDate;

    @wire( getRecord, { recordId: '$recordId', fields: [ STATUS,CUST_REQ_DISCO_DATE ] } )
    getRecordData( { error, data } ) {
        if ( data ) {
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
        if ( this.selectedDate == '' ) {
            const evt = new ShowToastEvent( {
                title: 'You must select a date',
                message: 'There must be a customer requested disconnect date',
                variant: 'warning',
            } );
            this.dispatchEvent( evt );
        } else {
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
                        console.log( 'result', result );
                        this.getTasks();
                    }
                    )
                    .catch( error => {
                        console.log( 'error', error );
                    }
                    );
            }
        
        
            updateRecord( recordInput )
                .then( result => {
                    console.log( 'result', result );
                    this.getTasks(); 
                    
                }
            )
                .catch( error => {
                    console.log( 'error', error );
                }
            );
        }
        
    }
    
    getTasks() {
        const outputID = this.recordId
        getTasks( { recordId: outputID } )
            .then( result => {
                console.log( { result} );
                this.taskData = result;
                if ( this.taskData.length > 0 ) {
                        this.isDiscoInProg = true;
                    }
            }
        )
            .catch( error => {
                console.log( 'error', error );
            }
        );
    }

    handleCellChange( event ) {
        // Extract the changed cell's information
        // const updatedCell = { ...event.detail.draftValues[ 0 ] };
        // console.log( { updatedCell } );
        // const fields = {}
        // fields.Id = updatedCell.Id;
        // fields.MPM4_BASE__Complete__c = updatedCell.MPM4_BASE__Complete__c;
        // fields.Not_Applicable__c = updatedCell.Not_Applicable__c;
        // fields.Resource_Name__c = updatedCell.Resource_Name__c;
        // this.milestoneTasks = { fields };
        
        // console.log( updatedCell.MPM4_BASE__Complete__c );        
        // console.log(  updatedCell.Not_Applicable__c );
        
    }

    handleSaveCellChanges( event ) {
        const recordInputs = event.detail.draftValues.slice().map( draft => {
            // console.log( 'draft', draft);
            const fields = { ...draft };
            return { fields };
        } );
        console.log( 'recordInputs', recordInputs );
        recordInputs.forEach( recordInput => {
            updateRecord( recordInput )
                .then( result => {
                    console.log( 'result', result );
                    this.getTasks();
                }
            )
                .catch( error => {
                    console.log( 'error', error );
                }
            );
        } );
        
    }
        
    handleDateChange( event ) {
        this.selectedDate = event.target.value;
        console.log( 'selectedDate', this.selectedDate );
    }
        
}