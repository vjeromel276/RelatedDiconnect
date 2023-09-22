import { LightningElement, api, track, wire } from 'lwc';
import { getRecord, updateRecord } from 'lightning/uiRecordApi';

import CUST_REQ_DISCO_DATE from '@salesforce/schema/Order.Customer_Requested_Disconnect_Date__c';
import STATUS from '@salesforce/schema/Order.Status';
import { ShowToastEvent } from 'lightning/platformShowToastEvent';
import getTasks from '@salesforce/apex/SOFDisconnectPanelController.getTasks';
import initiateDisconnect from '@salesforce/apex/SOFDisconnectPanelController.initiateDisconnect';
import updateMilestone1Task from '@salesforce/apex/SOFDisconnectPanelController.updateMilestone1Task';

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
    result ;

    @wire( getRecord, { recordId: '$recordId', fields: [ STATUS,CUST_REQ_DISCO_DATE ] } )
    getRecordData( { error, data } ) {
        this.isLoading = true;
        if ( data ) {
            this.isLoading = false;
            console.log( 'data', data );
            this.record = data;
            this.useNewTable = true;
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

    columns = [
        { label: 'Milestone Name', fieldName: 'Milestone_Name__c', type: 'text' },
        { label: 'Task Name', fieldName: 'recordLink', type: 'url', typeAttributes: { label: { fieldName: 'Name' }, target: '_blank' } },
        { label: 'Complete', fieldName: 'MPM4_BASE__Complete__c', type: 'boolean', editable: true },
        { label: 'Not Needed', fieldName: 'Not_Applicable__c', type: 'boolean', editable: true },
    ];

    // funtion for the disconnect button
    initiateDisconnect() {
        if ( this.selectedDate == '' || this.selectedDate == null ) {
            this.showToast( 'You must select a date', 'There must be a customer requested disconnect date', 'warning' );
        } else {
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
                                this.showToast( 'Record Updated', 'The record has been updated.', 'brand' );
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
                    this.showToast( 'Disconnect Process Started', 'The disconnect process has been started.', 'warning' );
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
        // updateRecord( recordInput )
        //     .then( result => {
        //         console.log( 'updateRecord result', result );
        //         this.getTasks();
        //         this.showToast( 'Record Updated', 'The record has been updated.', 'brand' );
        //         this.isLoading = false;
        //     } )
        //     .catch( error => {
        //         console.log( 'updateRecord error', error );
        //         this.getTasks();
        //         this.showToast( 'Record Update Failed', 'The record has not been updated.', 'error' );
        //         this.isLoading = false;
        //     } );
        
        try {
            const result = this.retryUpdateRecord( recordInput );
            console.log( 'updateRecord result', result);
            this.getTasks();
            this.isLoading = false;
        } catch (error) {
            console.log( 'updateRecord error', error );
            this.getTasks();
            this.isLoading = false;
        }
        
    }
    //& Commented out this is for the old sale
    // handleRowAction( event ) {
    //     const actionName = event.detail.action.name;
    //     const row = event.detail.row;
    //     switch (actionName) {
    //         case 'view_details':
    //             this[ NavigationMixin.Navigate ]( {
    //                 type: 'standard__recordPage',
    //                 attributes: {
    //                     recordId: row.Id,
    //                     actionName: 'view'
    //                 }
    //             }, true ); // Set true to open in a new tab, false to open in the same tab
    //             break;
    //         default:
    //     }
    // }

    // onCellChange( event ) {
    //     console.log( 'event.detail.draftValues', event.detail.draftValues[0] );
    //     this.draftValues = event.detail.draftValues;
    //      // Loop through each draft value
    //     this.draftValues.forEach( draft => {
    //         // Find the index of the task in the taskData array that has the same Id as the draft
    //         let index = this.taskData.findIndex( task => task.Id === draft.Id );

    //         // If a task with the same Id is found, update it with the draft values
    //         if ( index !== -1 ) {
    //             this.taskData[ index ] = { ...this.taskData[ index ], ...draft };
    //         }
    //         this.isLoading = true;
    //     } );
            
    //     // console.log( 'this.taskData', this.taskData );
    //     this.draftValues = [];
    //     this.taskData = [ ...this.taskData ];
    //     this.hasTasks = true;
    //     this.isLoading = false;
    // }
    
    // updateTasks( event ) {
    //     event.preventDefault();
        
    //     setTimeout( () => {
        
    //         const records = JSON.stringify( JSON.parse( JSON.stringify( this.taskData ) ) );
    //         console.log( 'taskRecords', records );
    //         this.isLoading = true;
    //         updateMilestone1Tasks( { tasks: records } )
    //             .then( result => {
    //                 console.log( 'updateMilestone1Tasks result', result );
    //                 this.getTasks();
    //                 this.hasTasks = false;
    //                 const evt = new ShowToastEvent( {
    //                     title: 'Milestone1 Tasks Updated',
    //                     message: 'The record has been updated.',
    //                     variant: 'brand',
    //                 } );
    //                 this.dispatchEvent( evt );
    //                 this.isLoading = false;
    //             } )
    //             .catch( error => {
    //                 console.log( 'updateMilestone1Tasks error', error );
    //                 this.hasTasks = false;
    //                 const evt = new ShowToastEvent( {
    //                     title: 'Milestone1 Tasks Update Failed',
    //                     message: 'The record has not been updated. Try again.',
    //                     variant: 'error',
    //                 } );
    //                 this.dispatchEvent( evt );
    //                 this.getTasks();
    //                 this.isLoading = false;
    //             } );
    //     }, 100 );
    // }

    // handleCancel(event) {
    //     event.preventDefault();
    //     this.getTasks();
    //     this.draftValues = [];
    //     this.hasTasks = false;
    //     this.isLoading = false;
    // }
    //& End of old data table handlers 

    async retryUpdateRecord( recordInput, retries = 5, delay = 200 ) {
        while ( retries > 0 ) {
            this.isLoading = true;
            console.log('retries', retries);
            try {
                const result = await updateRecord( recordInput );
                this.showToast( 'Record Updated', 'The record has been updated.', 'brand' );
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
                await new Promise( resolve => setTimeout( resolve, delay ) );
            }
        }
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