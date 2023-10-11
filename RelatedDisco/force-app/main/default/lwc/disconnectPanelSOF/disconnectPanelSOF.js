import { LightningElement, api, track, wire } from 'lwc';
import { getRecord, updateRecord } from 'lightning/uiRecordApi';

import CONTACT from '@salesforce/schema/Contact';
import CONTRACT_STATUS from '@salesforce/schema/Order.Service_End_Reason__c';
import CUST_REQ_DISCO_DATE from '@salesforce/schema/Order.Customer_Requested_Disconnect_Date__c';
import DISCO_CONTACT from '@salesforce/schema/Order.Disconnect_Contact__c';
import DISCO_CONTACT_FULLNAME from '@salesforce/schema/Order.Disconnect_Contact__r.Name';
import DISO_REQ_RECIEVED_DATE from '@salesforce/schema/Order.Disconnect_Request_Received_Date__c';
import END_REASON_NOTES from '@salesforce/schema/Order.End_Reason_Notes__c';
import EQUIP_PICKUP_FOR_DISCO from '@salesforce/schema/Order.Equipment_Pickup_Needed__c';
import PROCEED_DISCO from '@salesforce/schema/Order.Proceed_with_Disconnect__c';
import SERVICE_END_REASON from '@salesforce/schema/Order.Service_End_Reasons__c';
import STATUS from '@salesforce/schema/Order.Status';
import SUB_REASONS from '@salesforce/schema/Order.ServiceEndSub_Reasons__c';
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
        'Order.Proceed_with_Disconnect__c',
        'Order.Service_End_Reasons__c',
        'Order.ServiceEndSub_Reasons__c',
    ];
    // fields = [
    //     DISCO_CONTACT,
    //     DISO_REQ_RECIEVED_DATE,
    //     CONTRACT_STATUS,
    //     CUST_REQ_DISCO_DATE,
    //     END_REASON_NOTES,
    //     EQUIP_PICKUP_FOR_DISCO,
    //     PROCEED_DISCO,
    //     SERVICE_END_REASON,
    //     STATUS,
    //     SUB_REASONS,
    //     DISCO_CONTACT_FULLNAME
    // ];

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

    //~ the new new way of doing the data table
    // handleCheckboxChange(event) {
    //     event.preventDefault();
    //     this.isCheckboxLoading = true;
        
    //     const fields = {};
    //     const checkBox = event.target.dataset.field;
    //     const taskId = event.target.dataset.id;
    //     const isChecked = event.target.checked;

    //     // Immediately update the local state
    //     const taskIndex = this.taskData.findIndex(task => task.Id === taskId);
    //     if (taskIndex !== -1) {
    //         this.taskData[taskIndex][checkBox] = isChecked;
    //     }
        
    //     // Prepare fields for update
    //     if (checkBox === 'MPM4_BASE__Complete__c') {
    //         fields.Id = taskId;
    //         fields.MPM4_BASE__Complete__c = isChecked;
    //     } else if (checkBox === 'Not_Applicable__c') {
    //         fields.Id = taskId;
    //         fields.Not_Applicable__c = isChecked;
    //     }

    //     const recordInput = { fields };
    //         this.retryUpdateRecord( recordInput )
    //             .then( result => {
    //                 this.isCheckboxLoading = false;
    //                 this.showToast( 'Record Updated', 'The record has been updated.', 'brand' );
    //                 this.getTasks();
    //             } )
    //             .catch( error => {
    //                 // Revert local state change if update fails
    //                 if ( taskIndex !== -1 ) {
    //                     this.taskData[ taskIndex ][ checkBox ] = !isChecked;
    //                 }
    //                 this.isCheckboxLoading = false;
    //                 this.showToast( 'Record Update Failed', 'The record has not been updated.', 'error' );
    //                 this.getTasks();
    //             } );
    // }

    
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