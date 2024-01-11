import {  LightningElement, wire, api, track} from 'lwc';
import { ShowToastEvent } from 'lightning/platformShowToastEvent';
import getStaticText from '@salesforce/apex/InventoryGlobalController.getStaticText';
import { loadScript } from 'lightning/platformResourceLoader';
import DYMO_TEST from '@salesforce/resourceUrl/DymoConnect';
import { getRecord, getFieldValue} from 'lightning/uiRecordApi';
import getWarehouseShelfTagInfo from '@salesforce/apex/InventoryGlobalController.getWarehouseShelfTagInfo';
import getWarehouseAsseTagInfo from '@salesforce/apex/InventoryGlobalController.getWarehouseAsseTagInfo';

import getShelvesFromWarehouse from '@salesforce/apex/InventoryGlobalController.getShelvesFromWarehouse';
import createShelveFromWarehouse from '@salesforce/apex/InventoryGlobalController.createShelveFromWarehouse';

import NAME from '@salesforce/schema/Warehouse__c.Name';


export default class InventoryPrintSingleTagFromObject extends LightningElement {




    /******************************************************
     * --------------------| APIS |-------------------------
     ******************************************************/
    @api recordId;
    /*--------------------------------------------------------*/

    @track isShelf = false;
    @track shelfData = [];

    @track isAsset= false;
    @track AssetTagData = [];

    @track printerVal = '';
    @track  printers = [];
    @track allowPrint = false;
    @track numLabelsPerTagVal = 1;

    @track isVehicleOrWarehouse = false;
    @track vehicleTagData = [];

    @track showLoader = false;


    //get dymo pritner single label params in xml formant
    @wire(getStaticText, { staticObjName: 'DymoPrintOneParamXML'})
    DymoPrintOneParamXML({ error, data }) {
         if (data) {
            //console.log('have data')
            //console.log(data)
            this.DymoPrintOneParamXML = data;
         } else if (error) {
            console.log(error)
         }
     }    

    //get dymo pritner double label params in xml formant
     @wire(getStaticText, { staticObjName: 'DymoPrintTwoParamXML'})
     DymoPrintTwoParamXML({ error, data }) {
         if (data) {
            this.DymoPrintTwoParamXML = data;
         } else if (error) {
            console.log(error)
         }
     }    

     //get shelf tag label static resoirce in xml format
     @wire(getStaticText, { staticObjName: 'Dymo_Shelf_Tag_Durable_Label'})
     Dymo_Shelf_Tag_Durable_Label({ error, data }) {
         if (data) {
            this.Dymo_Shelf_Tag_Durable_Label = data;
         } else if (error) {
            console.log(error)
         }
     }    

     //get large asset tag tag label static resoirce in xml format
     @wire(getStaticText, { staticObjName: 'Dymo_Asset_Tag_Durable_Label'})
     Dymo_Asset_Tag_Durable_Label({ error, data }) {
         if (data) {
            this.Dymo_Asset_Tag_Durable_Label = data;

            var previewLabel = dymo.label.framework.openLabelXml(this.Dymo_Asset_Tag_Durable_Label);
            var pngData = previewLabel.render();
            this.PreviewImageSrc = "data:image/png;base64," + pngData;
         } else if (error) {
            console.log(error)
         }
     }    

    //get small asset tag tag label static resoirce in xml format
     @wire(getStaticText, { staticObjName: 'Dymo_Asset_Tag_Small_Label'})
     Dymo_Asset_Tag_Small_Label({ error, data }) {
         if (data) {
            this.Dymo_Asset_Tag_Small_Label = data;
         } else if (error) {
            console.log(error)
         }
     }    


     @wire(getStaticText, { staticObjName: 'NOC_Phone_Number'})
     NOC_Phone_Number({ error, data }) {
         if (data) {
            this.NOC_Phone_Number = data;
         } else if (error) {
            console.log(error)
         }
     } 

     @wire(getWarehouseShelfTagInfo, { ShelfId: '$recordId' })
     WarehouseShelfData({error, data}) {
         if(data) {
             console.log(JSON.stringify(data));
             if( data.length ) {
                    this.isShelf = true;
                    this.shelfData = data; 
             }

         }  else {
            console.log(error);
         }
     };
 

     @wire(getWarehouseAsseTagInfo, { AssetId: '$recordId' })
     getAssetTagData({error, data}) {
         if(data) {
             console.log(JSON.stringify(data));
             if( data.length ) {
                this.isAsset = true;
                this.AssetTagData = data;
             }
         }  else {
            console.log(error);
         }
     };

     @wire(getShelvesFromWarehouse, { warehouseId: '$recordId'})
     getShelfTagDataFromWarehouse({error, data}) {
        if(data) {
            console.log('getShelfTagDataFromWarehouse: -- ' + JSON.stringify(data));
            if( data.length ) {
               this.isVehicleOrWarehouse = true;
               this.vehicleTagData = data;
            }
        }  else {
           console.log('getShelfTagDataFromWarehouseError: ' + JSON.stringify(error));
        }
    };


    @wire(getRecord, { recordId:  '$recordId', fields: [NAME] })
    getWarehouseInfo({ data, error }) {
        console.log('--------------------------------- | wire getRecord')
        console.log('accountRecord => ', data, error);

        if( data ) {
            if( data.apiName == 'Warehouse__c' ) {
                this.isVehicleOrWarehouse = true;
            }
        }
      
    }
     
     


    /*==============================================================
     ----------------------------|on load|----------------------------
    ===============================================================*/
    connectedCallback() {
        //load the dymo static asset library
        loadScript(this, DYMO_TEST)
        .then(() => {
            console.log('****************************************');
            //set printers
            var dymoPrinters = dymo.label.framework.getPrinters();
            if (dymoPrinters.length == 0) {
                alert("No DYMO printers are installed. Install DYMO printers.");
            } else {

            this.printerVal = dymoPrinters[0].name; 

            dymoPrinters.map((e) => {
                //console.log(e.printerType)
                this.printers = [...this.printers ,{value: e.name , label: e.name} ];
              });

            }
            console.log('****************************************');

            
        })
        .catch(error => {
            // Handle the error.
            console.log(error)
            console.log(JSON.stringify(error))
        });

    }


    get printerOptions() {
        return this.printers;
    }

    handlePrinterChange(e) {
        this.printerVal = e.detail.value;
        this.chosenPrinter = e.detail.value;
    }


    numLabelsPerTagChange(e) {
        if(  e.detail.value > 2 ) {
            this.numLabelsPerTagVal = 2;
        }
        if(  e.detail.value < 2 ) {
            this.numLabelsPerTagVal = 1;
        }

     
    }

    /**
     * handleClick()
     * 
     * print those bitches
     * 
     * @param {*} e 
     */
    handleClick(e) {
        this.showLoader = true;

        try {

            if( this.isShelf ) {
                console.log(JSON.stringify(this.shelfData))
        

    
                var label = dymo.label.framework.openLabelXml(this.Dymo_Shelf_Tag_Durable_Label);
                var labelleSet = new dymo.label.framework.LabelSetBuilder();

            
                var record =labelleSet.addRecord();
                //record.setText('BAY', 'Bay: ' + this.shelfData[0].Warehouse_Bay_Name__c + '' );
                record.setText('RACK-BAY-Shelf', this.shelfData[0].Warehouse_Rack_Name__c + ' - ' + this.shelfData[0].Warehouse_Bay_Name__c + ' - ' + this.shelfData[0].Name__c + ' ');
                record.setText('WAREHOUSE_NAME', this.shelfData[0].Warehouse_Name__c); 
                record.setText('Asset_Tag_QR', [this.shelfData[0].Shelf_Tag_Name__c]  )    
            

                if( this.numLabelsPerTagVal == 1 ) {
                    label.print(this.printerVal,  this.DymoPrintOneParamXML, labelleSet );
                } else {
                    label.print(this.printerVal,  this.DymoPrintTwoParamXML, labelleSet );
                }
            }



            if( this.isAsset ) {
                console.log(JSON.stringify(this.AssetTagData))
              
                var label = dymo.label.framework.openLabelXml(this.Dymo_Asset_Tag_Durable_Label);
                var labelleSet = new dymo.label.framework.LabelSetBuilder();


                var record =labelleSet.addRecord();
                record.setText('Asset_Tag_Name_Text', [this.AssetTagData[0].Name]);
                record.setText('Asset_Tag_QR', [this.AssetTagData[0].Name] )                            
                        
    
                if( this.numLabelsPerTagVal == 1 ) {
                    label.print(this.printerVal,  this.DymoPrintOneParamXML, labelleSet );
                } else {
                    label.print(this.printerVal,  this.DymoPrintTwoParamXML, labelleSet );
                }

            }

            if( this.isVehicleOrWarehouse ) {
               
                if( !this.vehicleTagData.length ) {


                    console.log('no vehicle data:' + this.recordId);
                    createShelveFromWarehouse({ warehouseId: this.recordId})
                    .then(data => {   
                        console.log(data);
                        console.log(JSON.stringify(data));

                        console.log('Warehouse_Name__c ' + data[0].Warehouse_Name__c);
                        console.log('Shelf_Tag_Name__c: ' + data[0].Shelf_Tag_Name__c);

                        if( data.length ) {
                            //this.vehicleTagData = data[0];
                     
                            var label = dymo.label.framework.openLabelXml(this.Dymo_Shelf_Tag_Durable_Label);
                            var labelleSet = new dymo.label.framework.LabelSetBuilder();
        
                        
                            var record =labelleSet.addRecord();
                            record.setText('RACK-BAY-Shelf', ' ');
                            record.setText('WAREHOUSE_NAME', data[0].Warehouse_Name__c); 
                            record.setText('Asset_Tag_QR', [data[0].Shelf_Tag_Name__c]  )    
                        
        
                            if( this.numLabelsPerTagVal == 1 ) {
                                label.print(this.printerVal,  this.DymoPrintOneParamXML, labelleSet );
                            } else {
                                label.print(this.printerVal,  this.DymoPrintTwoParamXML, labelleSet );
                            }
                         } 
                         
                        this.showLoader = false;
                    })
                    .catch(error => {
                        console.log('there was an error');
                        console.log(error);  
                        this.showLoader = false;   
                    });
                }

                if( this.vehicleTagData.length ) {
                    console.log('has vehicle location data')
                    console.log(JSON.stringify(this.vehicleTagData));
                    var label = dymo.label.framework.openLabelXml(this.Dymo_Shelf_Tag_Durable_Label);
                    var labelleSet = new dymo.label.framework.LabelSetBuilder();

                
                    var record =labelleSet.addRecord();
                    //record.setText('BAY', 'Bay: ' + this.shelfData[0].Warehouse_Bay_Name__c + '' );
                    record.setText('RACK-BAY-Shelf', ' ');
                    record.setText('WAREHOUSE_NAME', this.vehicleTagData[0].Warehouse_Name__c); 
                    record.setText('Asset_Tag_QR', [this.vehicleTagData[0].Shelf_Tag_Name__c]  )    
                

                    if( this.numLabelsPerTagVal == 1 ) {
                        label.print(this.printerVal,  this.DymoPrintOneParamXML, labelleSet );
                    } else {
                        label.print(this.printerVal,  this.DymoPrintTwoParamXML, labelleSet );
                    }
                 }
                
                

            }

            this.showLoader = false;
        }
        catch (e) {
            alert(e.message);
            this.showLoader = false;
        }

    }





}