import { LightningElement, api, track, wire } from 'lwc';
import { getRecord, updateRecord } from 'lightning/uiRecordApi';

import STATUS from '@salesforce/schema/Order.Status';
import { ShowToastEvent } from 'lightning/platformShowToastEvent';
import getTasks from '@salesforce/apex/SOFDisconnectPanelController.getTasks';

export default class SOFDisconnectPanel extends LightningElement {
    @api recordId
    taskData = [];
    @api isDiscoInProg = false;
    sofStatus = '';
    @track record = {};
    @track selectedDate = '';

    @wire( getRecord, { recordId: '$recordId', fields: [ STATUS ] } )
    getRecordData( { error, data } ) {
        if ( data ) {
            console.log( 'data', data );
            this.record = data;
            this.sofStatus = this.record.fields.Status.value;
            if( this.sofStatus == 'Disconnect in Progress' ) {
                this.getTasks();
            }
        } else if ( error ) {
            console.log( 'error', error );
        }
    }
    
    connectedCallback() {
        console.log( 'recordId', this.recordId );
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
        const { fieldName, value } = event.detail;

    // Log the changed field name and its new value
        console.log( `Field '${ fieldName }' changed to: ${ value }` );
    
    // You can access the old value as well, if needed
        const { rowKeyValue, oldValue } = event.detail;
        console.log( `Old value for field '${ fieldName }' with key '${ rowKeyValue }': ${ oldValue }` );
    
    }

    handleDateChange( event ) {
        this.selectedDate = event.target.value;
        console.log( 'selectedDate', this.selectedDate );
    }
        
}