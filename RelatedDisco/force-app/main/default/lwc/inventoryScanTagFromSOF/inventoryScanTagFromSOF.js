import { LightningElement, wire, api, track  } from 'lwc';
import { CurrentPageReference } from 'lightning/navigation';
import { getBarcodeScanner } from 'lightning/mobileCapabilities';
import FORM_FACTOR from '@salesforce/client/formFactor';//screen size
import moveAssetFromSOFTwo from '@salesforce/apex/InventoryGlobalController.moveAssetFromSOFTwo'; 
import { ShowToastEvent } from 'lightning/platformShowToastEvent';
export default class InventoryScanTagFromSOF extends LightningElement {

    /******************************************************
     * -------------------| vars |------------------------
     ******************************************************/  
    isMobile = FORM_FACTOR == 'Large' ? false : true;  
    scanButtonDisabled = false;
    inputVal;
    @track inputValSOF;
    @track inputValSOFAlt;
    QuanityVal;
    currentScannedTag = '';
    generalModalLoader = true;
    isSOFSet = false;
    ScannedAssestsList = [];


    /******************************************************
     * -------------------| wires |------------------------
     ******************************************************/
    @wire(CurrentPageReference)
    currentPageReference
    

    /******************************************************
     * -------------------| OnLoad |------------------------
     ******************************************************/
    /**
     * @see https://salesforce.stackexchange.com/questions/347055/is-recordid-passed-to-lwc-in-a-quick-action/347058?noredirect=1#comment508705_347058
     */
    renderedCallback() {
        
        if ( this.currentPageReference.state.c__recordId  && !this.isSOFSet) {
            this.inputValSOF = this.currentPageReference.state.c__recordId;
            this.isSOFSet = true
        } 
        console.log('Render: ' + this.inputValSOF )
    
    }    

    connectedCallback() {
        this.myScanner = getBarcodeScanner();
        if (this.myScanner == null || !this.myScanner.isAvailable()) {
            this.scanButtonDisabled = true;
        }
        console.log('connectedCallback: ' + this.inputValSOF )
    }


    /**
     * 
     * @param {*} e 
     */
    inputValChange = (e) => {
        this.inputVal = e.target.value
    }

    inputValChangeSOF = (e) => {
        this.inputValSOF = e.target.value;//overwritte
        console.log('change inputValChangeSOF to: ' + e.target.value );

        this.inputValSOFAlt = e.target.value;
    }




    /**
     * 
     * @param {*} e 
     */
       inputValChangeQuanity = (e) => {
        this.QuanityVal = e.target.value
    }

 


        /**
     * 
     * @param {*} event 
     */
        handleEnter(event){
            if(event.keyCode === 13){
             
               this.currentScannedTag = event.target.value;
               this.inputVal = event.target.value;
               this.submitScannedItem();
             }
         }

         
    handleBeginScanClick(event) {
        // Reset scannedBarcode to empty string before starting new scan
        this.currentScannedTag = '';
    
        // Make sure BarcodeScanner is available before trying to use it
        // Note: We _also_ disable the Scan button if there's no BarcodeScanner
        if (this.myScanner != null && this.myScanner.isAvailable()) {
            const scanningOptions = {
                barcodeTypes: [this.myScanner.barcodeTypes.QR],
                instructionText: 'Scan a QR Code',
                successText: 'Scanning complete.'
            };
            this.myScanner
                .beginCapture(scanningOptions)
                .then((result) => {
                    console.log(result);
    
    
    
                    this.currentScannedTag = result.value;
                    
                })
                .catch((error) => {
                    // Handle cancellation and unexpected errors here
                    console.error(error);
    
                    if (error.code == 'userDismissedScanner') {
                        // User clicked Cancel
                        this.dispatchEvent(
                            new ShowToastEvent({
                                title: 'Scanning Cancelled',
                                message:
                                    'You cancelled the scanning session.',
                                mode: 'sticky'
                            })
                        );
                    }
                    else { 
                        // Inform the user we ran into something unexpected
                        this.dispatchEvent(
                            new ShowToastEvent({
                                title: 'Barcode Scanner Error',
                                message:
                                    'There was a problem scanning the barcode: ' +
                                    error.message,
                                variant: 'error',
                                mode: 'sticky'
                            })
                        );
                    }
                })
                .finally(() => {
                    console.log('#finally');
    
                    // Clean up by ending capture,
                    // whether we completed successfully or had an error
                    this.myScanner.endCapture();
                });
        } else {
            // BarcodeScanner is not available
            // Not running on hardware with a camera, or some other context issue
            console.log(
                'Scan Barcode button should be disabled and unclickable.'
            );
            console.log('Somehow it got clicked: ');
            console.log(event);
    
            // Let user know they need to use a mobile phone with a camera
            this.dispatchEvent(
                new ShowToastEvent({
                    title: 'Barcode Scanner Is Not Available',
                    message:
                        'Try again from the Salesforce app on a mobile device.',
                    variant: 'error'
                })
            );
        }
    }
    


    hideModalLoader = () => {
        this.generalModalLoader = false;
    }


    /**
     * 
     * @param {*} e 
     */
    submitScannedItem(e) {
        this.generalModalLoader = true;
        console.log('assetName: ' + this.currentScannedTag);
        console.log('orderID: ' + this.inputValSOF);
        console.log('quantity: ' + this.QuanityVal);

        if( this.QuanityVal ) {
            moveAssetFromSOFTwo({ assetName: this.currentScannedTag,  orderID:  this.inputValSOF, quantity: this.QuanityVal })
            .then(result => {   
                console.log(JSON.stringify(result)); 

                this.ScannedAssestsList.unshift(result);


                console.log(result.success); 

                this.generalModalLoader = false;

                if( result.success) {
                    console.log('success')

                    this.dispatchEvent(
                        new ShowToastEvent({
                            title: 'Success',
                            message: '' + result.success + '',
                            variant: 'success'
                        })
                    );
                } else {
                    console.log('error')
                   this.dispatchEvent(
                        new ShowToastEvent({
                            title: 'Error',
                            message:'' + result.error + '',
                            variant: 'error'
                        })
                    );
                }


            })
            .catch(error => {
                this.generalModalLoader = false;
                console.log('there was an error');
                this.dispatchEvent(
                    new ShowToastEvent({
                        title: 'Error',
                        message:'' + error + '',
                        variant: 'error'
                    })
                );
                console.log(error);     
            });
        } else {
            this.generalModalLoader = false;
            console.log('there was an error');
            this.dispatchEvent(
                new ShowToastEvent({
                    title: 'Error',
                    message:'Quantity Required',
                    variant: 'error'
                })
            );
            console.log(error);   
        }
    
    }


}