import {  LightningElement, wire, api, track} from 'lwc';
import { ShowToastEvent } from 'lightning/platformShowToastEvent';
import { getBarcodeScanner } from 'lightning/mobileCapabilities';
import FORM_FACTOR from '@salesforce/client/formFactor';
import getWarehouses from '@salesforce/apex/InventoryGlobalController.getWarehouses';
import getRacksFromWarehouse from '@salesforce/apex/InventoryGlobalController.getRacksFromWarehouse';
import getBaysFromRack from '@salesforce/apex/InventoryGlobalController.getBaysFromRack';
import getShelvesFromBay from '@salesforce/apex/InventoryGlobalController.getShelvesFromBay';


import getEverythingFromScannedShelf from '@salesforce/apex/InventoryGlobalController.getEverythingFromScannedShelf';



import ConnectAssetToWarehouse from '@salesforce/apex/InventoryGlobalController.ConnectAssetToWarehouse';
import createAssetController from '@salesforce/apex/InventoryGlobalController.createAsset';
import LightningModal from 'lightning/modal';
import POLines from '@salesforce/apex/InventoryGlobalController.POLines';

//https://developer.salesforce.com/docs/component-library/documentation/en/lwc/lwc.use_barcodescanner

const columns = [
    { label: 'Name', fieldName: 'name' },
    { label: 'From', fieldName: 'from'  },
    { label: 'To', fieldName: 'to' },
];
export default class InventoryScanToLocation extends LightningElement {

    
    /*=======================================================================
    -------------------------| vars, tracks & wires |------------------------
    ========================================================================*/
    sessionScanner;
    scanButtonDisabled = false;
    scannedBarcode = '';
    isMobile = FORM_FACTOR == 'Large' ? false : true;
    isShowcreateAssetModal = false;
    selectedPO = '';
    selectedPOLines = [];
    ChosenPoLine = '';
    ChosenPoName = '';
    ChosenPoDesc = '';
    ChosenPoQuant = '';
    generalModalLoader = false;
    createAssetLoader = false;

    quantityToMoveVal;

    myScanner;


    @track inputVal = '';
    @track ScannedAssestsList = [];

    //warehouses
    @track warehouses = [];
    WarehouseVal = '';
    @track chosenWarehouse = '';


    //racks
    @track racks = []
    @track chosenRack = '';
    @track rackVal = '';
    showRacks = false;


    //bays
    @track bays = []
    @track chosenBay = '';
    @track bayVal = '';
    showBays = false;


    @track shelves = [];
    @track chosenShelf = '';
    @track shelfVal = '';
    showShelves = false;


    @track scannedShelfTag;


    @track vendorValue = '';
    @track minStockQty = '';
    @track quantityVal = 1;

    @track shoechangingLoader = false;



    
    @wire(getWarehouses)
    wiredWarehouses({ error, data }){
        if( data ) {

            data.map((e) => {
                this.warehouses = [...this.warehouses ,{value: e.Id , label: e.Name} ];
            });
 
        } else if (error) {
            console.log(error);
        }
    }

    /************************************************************************/



    /*=======================================================================
    --------------------------| On Load, render |--------------------------
    ========================================================================*/
    /**
     * connectedCallback
     * 
     * on load init scanner
     */
    connectedCallback() {
        this.myScanner = getBarcodeScanner();
        if (this.myScanner == null || !this.myScanner.isAvailable()) {
            this.scanButtonDisabled = true;
        }
    }
    
    /**
     * renderedCallback
     * 
     * on render focus on input field
     */
    renderedCallback() {
        /*let elem = this.template.querySelector("lightning-input[data-fieldname='Amount']");
        setTimeout(() => elem.focus());*/
    }
    /************************************************************************/


    /**
     * warehouseOptions()
     * 
     * getter to return selected dropdown value
     */
    get warehouseOptions() {
        return this.warehouses;
    }

    get rackOptions() {
        return this.racks;
    }

    get bayOptions() {
        return this.bays;
    }

    get shelfOptions() {
        return this.shelves;
    }
    

    /**
     * handleWarehouseChange()
     * 
     * on warehouse select dropdown set selected warehouse vars,also has validation
     * @param {*} e 
     */
    handleWarehouseChange(e) {

        this.clearStuff();

        this.shoechangingLoader = true;

        this.WarehouseVal = e.detail.value;
        this.chosenWarehouse = e.detail.value;

        var inputCmp = this.template.querySelector('.inputCmp');
        var value = inputCmp.value;

        //go get all of the warehouse data to preopulate the selectboxes
        getRacksFromWarehouse({"warehouse": e.detail.value})
        .then(result => {   
            console.log(JSON.stringify(result)); 
            //console.log(result.racks); 
            this.shoechangingLoader = false;
            if( result.racks.length ) {
                this.showRacks = true;
                result.racks.map((e) => {
                    this.racks = [...this.racks ,{value: e.Id , label: e.Name__c} ];//{Id: 'aH93g000000CaRICA0', Name: 'E4 - Facilities'}
                });
            }

        })
        .catch(error => {
            this.shoechangingLoader = false;
            console.log('there was an error');
            console.log(error);     
        });


        // is input valid text?
        if (value === '') {
            inputCmp.setCustomValidity('A warehouse needs to be selected');
        } else {
            inputCmp.setCustomValidity(''); // if there was a custom error before, reset it
        }
        inputCmp.reportValidity(); // Tells lightning-input to show the error right away without needing interaction
    }


    handleRackChange(e) {
        this.rackVal = e.detail.value;
        this.chosenRack = e.detail.value;

        this.shoechangingLoader = true;

        
        //go get all of the warehouse data to preopulate the selectboxes
        getBaysFromRack({"rack": e.detail.value})
        .then(result => {   
            //console.log(JSON.stringify(result)); 
            //console.log(result.racks); 
            this.shoechangingLoader = false;
            if( result.bays.length ) {
                this.showBays = true;
                result.bays.map((e) => {
                    this.bays = [...this.bays ,{value: e.Id , label: e.Name__c} ];//{Id: 'aH93g000000CaRICA0', Name: 'E4 - Facilities'}
                });
            }

        })
        .catch(error => {
            this.shoechangingLoader = false;
            console.log('there was an error');
            console.log(error);     
        });
        //set validility

        //get the bays for the chosenRack in the WarehouseData object and populate the options for the bays
    }


    handleBayChange(e) {
        this.bayVal = e.detail.value;
        this.chosenBay = e.detail.value;

        this.shoechangingLoader = true;

        
        getShelvesFromBay({"bay": e.detail.value})
        .then(result => {   
            this.shoechangingLoader = false;
            if( result.shelves.length ) {
                this.showShelves = true;
                result.shelves.map((e) => {
                    this.shelves = [...this.shelves ,{value: e.Id , label: e.Name__c} ];//{Id: 'aH93g000000CaRICA0', Name: 'E4 - Facilities'}
                });
            }

        })
        .catch(error => {
            this.shoechangingLoader = false;
            console.log('there was an error');
            console.log(error);     
        });
    }

    handleShelfChange(e) {
        this.shelfVal = e.detail.value;
        this.chosenShelf = e.detail.value;   
    }
  
    clearStuff() {
        this.showRacks = false;
        this.showBays = false;
        this.showShelves = false;
        this.rackVal = '';
        this.bayVal = '';
        this.shelfVal = '';
        this.racks = [];
        this.bays = [];
        this.shelves = [];
        this.shoechangingLoader = false;
    }
    

    handleQuantityChange(e) {
        this.quantityToMoveVal = e.detail.value;
    }

    handlescannedShelfTagChange(e) {
        this.scannedShelfTag = e.detail.value;
    }

    handlescannedShelfTagEnter(event) {
        if(event.keyCode === 13  ){
            this.handlescannedShelfTagEnterHelper();
        }
    }

    /**
     * 
     * this is a ghelper function that goes to the back end because this is called from js on front end and needs to be called within this file as well.
     */
    handlescannedShelfTagEnterHelper() {
        getEverythingFromScannedShelf({ shelfName:  this.scannedShelfTag  })
        .then(data => {  
            console.log(JSON.stringify(data)); 

            console.log('message: ' + data.message ); 
            console.log('bay: ' + data.bay.Id ); 
            console.log('rack: ' + data.rack ); 
            console.log('warehouse: ' + data.warehouse ); 



            this.racks = [...this.racks ,{value: data.rack.Id , label: data.rack.Name} ];
            this.bays = [...this.bays ,{value: data.bay.Id , label: data.bay.Name} ];
            this.shelves =  [...this.shelves ,{value: data.shelf.Id , label: data.shelf.Name} ];

            this.showBays = true;
            this.showRacks = true;
            this.showShelves = true;

            this.WarehouseVal = data.warehouse.Id;
            this.chosenWarehouse = data.warehouse.Id;
            this.bayVal = data.bay.Id;
            this.rackVal = data.rack.Id;
            this.shelfVal = data.shelf.Id;

            this.scannedShelfTag = '';


       
        })
        .catch(error => {
            console.log('there was an error');
            console.log(error);     
            this.dispatchEvent(
                new ShowToastEvent({
                    title: 'An error occured',
                    message: 'error creating asset' + error,
                    variant: 'error'
                })
            );
            this.dispatchEvent(evt);
        }); 
    }


 






    
    /*=======================================================================
    ---------------------| Scanner Shit |------------------------------
    ========================================================================*/


    handleBeginScanClick(event) {
        // Reset scannedBarcode to empty string before starting new scan
        this.scannedBarcode = '';

        // Make sure BarcodeScanner is available before trying to use it
        // Note: We _also_ disable the Scan button if there's no BarcodeScanner
        if (this.myScanner != null && this.myScanner.isAvailable()) {
            const scanningOptions = {
                barcodeTypes: [this.myScanner.barcodeTypes.QR,  this.myScanner.barcodeTypes.PDF_417],
                instructionText: 'Scan a Shelf Tag',
                successText: 'Scanning complete.'
            };
            this.myScanner
                .beginCapture(scanningOptions)
                .then((result) => {
                    console.log(result);

                    this.scannedBarcode = result.value;


                    if( this.scannedBarcode.startsWith('SH')) {

                        //set scanned shelf tag and go to back end
                        this.scannedShelfTag = result.value;
                        this.handlescannedShelfTagEnterHelper();


                    } else {
                    

                            //do the thing that moves assets beotch

                            this.moveAsset(result.value ); 
   
                   
                    }


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

    /************************************************************************/







































    /*=======================================================================
    ---------------------| Create Asset Stuff |------------------------------
    ========================================================================*/
    /**
     * quantityChange()
     * 
     * 
    */
    @api async quantityChange(e) {
        this.quantityVal = e.target.value
    }

    handleVendorChange = (e) => {
        this.vendorValue = e.target.value
    }

    handleMINQuantityChage =  (e) => {
        this.minStockQty = e.target.value;
    }

    /**
     * opencreateAssetModal()
     * 
     * sets var to open a modal and turns on loader
     * @param {*} e 
     */
    opencreateAssetModal(e) {
        this.isShowcreateAssetModal= true;
        this.generalModalLoader = true;
     }


    /**
     * selectedPOChange()
     * 
     * on po select set var, go to apex and get the associated PO lines
     * @param {*} event 
     */
    selectedPOChange = (event) => {
        this.selectedPO = event.target.value;
        this.getPOOLines();
    }

    /**
     * getPOOLines()
     * 
     * go to apex conteoller and get PO Lines
     */
    getPOOLines() {
        POLines({ POID:  this.selectedPO,   })
        .then(data => {  
            console.log('Heard Back'); 
            console.log(data);  
            this.selectedPOLines = data;
        })
        .catch(error => {
            console.log('there was an error');
            console.log(error);     
        });        
    }


    /**
     * selectPoLine()
     * 
     * when a selected po line is chosen, set vars
     * @param {*} e 
     */
    @api async selectPoLine(e)  {
        var rID = e.currentTarget.dataset.recordId;
        var rName = e.currentTarget.dataset.recordName;
        var rDesc = e.currentTarget.dataset.recordDescription;
        var rQ = '1';
        this.ChosenPoLine = rID;
        this.ChosenPoName = rName;
        this.ChosenPoDesc = rDesc;
        this.ChosenPoQuant = rQ;

 
       // this.setFocusOnElement("lightning-input.scanTagInput");
    }


    /**
     * hidecreateAssetModal
     * 
     * closes modal, loader and clears chosen PO vars as well as chosen PO line vars
     */
    hidecreateAssetModal() {  
        this.isShowcreateAssetModal = false;
        this.selectedPO = '';
        this.selectedPOLines = [];
        this.ChosenPoLine = '';
        this.ChosenPoName = '';
        this.ChosenPoDesc = '';
        this.ChosenPoQuant = '';
    }


    /**
     * hideModalLoader()
     * 
     * close loader
     */
    hideModalLoader() {
        this.generalModalLoader = false;
    }

    /**
     * reset()
     * 
     * resets chosen PO line vars
     * @param {*} e 
     */
    @api async reset(e) {
        this.ChosenPoLine = '';
        this.ChosenPoName = '';
        this.ChosenPoDesc = '';
        this.ChosenPoQuant = '';
        this.inputVal = '';
        //this.currentScannedTag = '';
    }

    /**
     * createAsset()
     * 
     * goes to apex back end to create asset
     * @param {*} e 
     */
    @api async createAsset(e){
        createAssetController({ PO: this.selectedPO, warehouse:  this.WarehouseVal,  POLine: this.ChosenPoLine, tagName: this.inputVal, vendor: this.vendorValue, quantity: this.quantityVal, minStockQuantity: this.minStockQty  })
        .then(result => {
            console.log('*************************************');
            console.log(JSON.stringify(result));
            console.log('*************************************');

            if(result.status == 'success' || result.status == 'notfound' ) {
                console.loh('found success');
                this.ScannedAssestsList.unshift(result);
                this.dispatchEvent(
                    new ShowToastEvent({
                        title: 'sucess',
                        message: 'created asset',
                        variant: 'success'
                    })
                );
                this.dispatchEvent(evt);


                this.hidecreateAssetModal();

            } else {
                this.dispatchEvent(
                    new ShowToastEvent({
                        title: 'An error occured',
                        message: 'error creating asset',
                        variant: 'error'
                    })
                );
                this.dispatchEvent(evt);
            }
        })
        .catch( error => {
            console.log(JSON.stringify(error));
        });
    }


    /**
     * handleCreateAssetEnter()
     * 
     * on enter creates asset
     * @param {*} event 
     */
    handleCreateAssetEnter(event) {
        if(event.keyCode === 13){
            if(this.WarehouseVal && this.ChosenPoLine && this.selectedPO ) {
                this.createAsset();
            } else {
                this.dispatchEvent(
                    new ShowToastEvent({
                        title: 'An error occured',
                        message: 'errror scanning asset tag',
                        variant: 'error'
                    })
                );
                this.dispatchEvent(evt);
            }
        }
    }
    /************************************************************************/



    /**
     * handleEnter()
     * On Keypress enter go to back end to move asset
     * @param {*} event 
     */
    handleEnter(event){
        if(event.keyCode === 13 && !this.ChosenPoName ){
            if( this.WarehouseVal ) {
                const tag = event.target.value;
                if(tag) {

                    var tagInputcmp = this.template.querySelector('.tagInputcmp');
                    var value = tagInputcmp.value;
                    // is input valid text?
                    if (value === '') {
                        tagInputcmp.setCustomValidity('No asset Tag entered ');
                    } else {
                        tagInputcmp.setCustomValidity(''); // if there was a custom error before, reset it
                    }
                    tagInputcmp.reportValidity(); // Tells lightning-input to show the error right away without needing interaction




                    this.moveAsset(tag);



                } else {

                    var tagInputcmp = this.template.querySelector('.tagInputcmp');
                    var value = tagInputcmp.value;
                    // is input valid text?
                    if (value === '') {
                        tagInputcmp.setCustomValidity('No asset Tag entered ');
                    } else {
                        tagInputcmp.setCustomValidity(''); // if there was a custom error before, reset it
                    }
                    tagInputcmp.reportValidity(); // Tells lightning-input to show the error right away without needing interaction
                }
            } else {
                //warehouse not selected
                var inputCmp = this.template.querySelector('.inputCmp');
                var value = inputCmp.value;
                // is input valid text?
                if (value === '') {
                    inputCmp.setCustomValidity('A warehouse needs to be selected');
                } else {
                    inputCmp.setCustomValidity(''); // if there was a custom error before, reset it
                }
                inputCmp.reportValidity(); // Tells lightning-input to show the error right away without needing interaction

            }
        }
    }
    





    moveAsset(tag ) {
        console.log('move asset')
        console.log('quanity to move ' + this.quantityToMoveVal );
        this.generalLoader = true;
        //run it through the back end first
        ConnectAssetToWarehouse({ warehouse: this.chosenWarehouse, assetTag: tag.replace(/\s/g, ""), shelf: this.shelfVal, quantity: this.quantityToMoveVal })
        .then(result => {   
            console.log('******************************************');
            console.log(JSON.stringify(result));
            console.log('******************************************');                             
            if(result.status == 'success' || result.status == 'notfound' ) {
                //this.ScannedAssestsList.unshift(tag);
                this.ScannedAssestsList.unshift(result);    
                this.generalLoader = false;
            } else {
                this.dispatchEvent(
                    new ShowToastEvent({
                        title: 'An error occured',
                        message: 'errror scanning asset tag',
                        variant: 'error'
                    })
                );
                this.dispatchEvent(evt);
                this.generalLoader = false;
            }
        })
        .catch(error => {
            console.log(error);     
            this.generalLoader = false;
        });              
        this.inputVal = '';
    }

    /**
     * inputValChange()
     * 
     * on scanned value input change set var
     * @param {*} e 
     */
    inputValChange = (e) => {
        this.inputVal = e.target.value
    }

    /**
     * ClearScannedItems()
     * 
     * clears scanned items arr
     */
    ClearScannedItems = () => {
        this.inputVal = '';
        this.ScannedAssestsList = [];
    }


    






}