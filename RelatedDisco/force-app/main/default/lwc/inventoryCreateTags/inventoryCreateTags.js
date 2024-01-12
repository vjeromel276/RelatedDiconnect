import {  LightningElement, wire, api, track} from 'lwc';
import { ShowToastEvent } from 'lightning/platformShowToastEvent';
import getStaticText from '@salesforce/apex/InventoryGlobalController.getStaticText';
import { loadScript } from 'lightning/platformResourceLoader';
import DYMO_TEST from '@salesforce/resourceUrl/DymoConnect';
import getWarehouses from '@salesforce/apex/InventoryGlobalController.getWarehouses';
import getRacksFromWarehouse from '@salesforce/apex/InventoryGlobalController.getRacksFromWarehouse';
import getBaysFromRack from '@salesforce/apex/InventoryGlobalController.getBaysFromRack';
import insertTags from '@salesforce/apex/InventoryGlobalController.insertTags';  
import getShelvesFromRack from '@salesforce/apex/InventoryGlobalController.getShelvesFromRack'; 

export default class InventoryCreateTags extends LightningElement {

    /*==============================================================
     ----------------------------|vars|----------------------------
    ===============================================================*/

    @track printerVal = '';
    @track  printers = [];
    @track chosenPrinter = '';
    @track chosenPrinterAlt;

    @track TagTypeVal = '';

    @track ShowPreview= '';
    @track PreviewImageSrc = '';

    //warehouses
    @track warehouses = [];
    WarehouseVal = '';
    @track chosenWarehouse = '';
    showWarehouse = false;

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




    @track allowPrint = false;

    @track numLabelsVal = 1;
    @track numLabelsPerTagVal = 1;


    @track isWebServicePresent;
    @track isFrameworkInstalled;
    @track isBrowserSupported;
    @track showDymoChecks = false;

    @track quantityVal = 1;

    @track chosenShelfName;

    @track shoechangingLoader = false;

    @track showShelfNameSelect = false;

    @track  generalModalLoader = true;
    
    
    
    //@track DymoPrintOneParamXML = '';
    //@track DymoPrintTwoParamXML = '';
    //@track Dymo_Shelf_Tag_Durable_Label = '';
    //@track Dymo_Asset_Tag_Durable_Label = '';
    //@track Dymo_Asset_Tag_Small_Label = '';

    /*==============================================================
     ----------------------------|wires|----------------------------
    ===============================================================*/
    //get all warehouses for selectbox
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
        this.generalModalLoader = false;
        console.log('Dymo_Asset_Tag_Durable_Label wire' + typeof dymo)
         if (data) {
            this.Dymo_Asset_Tag_Durable_Label = data;
            if (typeof dymo != "undefined") {
                
                console.log('===================== has dymo'  );
                let previewLabel = dymo.label.framework.openLabelXml(data);
                let pngData = previewLabel.render();
                this.PreviewImageSrc = "data:image/png;base64," + pngData;
                this.generalModalLoader = false;
            }
            //call load this example
            //

            
            
         } else if (error) {
            console.log(JSON.stringify(error))
         }
     }    




     //get large asset tag tag label static resoirce in xml format
     @wire(getStaticText, { staticObjName: 'Dymo_Asset_Tag_Durable_Label_double'})
     Dymo_Asset_Tag_Durable_Label_double({ error, data }) {
        this.generalModalLoader = false;
        console.log('Dymo_Asset_Tag_Durable_Label_double wire' + typeof dymo)
         if (data) {
            this.Dymo_Asset_Tag_Durable_Label_double = data;
            
         } else if (error) {
            console.log(JSON.stringify(error))
         }
     }    




     //check if dymo available, if not recursivly attempt until it is. weird but it works, you need to do this cause wire runs before the connected callback function but the static asset is needed  and can only be returned via wire and needs the dymo framework loaded via connected callback
     /*loadDymoAssetExample(data) {
        console.log('loadDymoAssetExample function')
        this.Dymo_Asset_Tag_Durable_Label = data;
        
        //if( Object.keys(dymo).length  && dymo.constructor === Object) {
        if (typeof dymo != "undefined") {
            console.log('===================== has dymo');
            console.log('===================== has dymno' );
            var previewLabel = dymo.label.framework.openLabelXml(this.Dymo_Asset_Tag_Durable_Label);
            var pngData = previewLabel.render();
            this.PreviewImageSrc = "data:image/png;base64," + pngData;
            this.generalModalLoader = false;
        } else {
            console.log('===================== no dymo');
            setTimeout(loadDymoAssetExample, 250);
        }
     }*/





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

            
        })
        .catch(error => {
            // Handle the error.
            console.log(error)
            console.log(JSON.stringify(error))
        });

        let opts = [
            { label: 'asset', value: 'Asset' },
            { label: 'shelf/scannable location', value: 'Shelf' },
        ];
        this.TagTypeVal = opts[0].value;



    }

    renderedCallback() {



        //set selectbox default vals
        //this.TagTypeVal = 'asset';
        //this.numLabelsPerTagVal = '1';
    }



    /*==============================================================
     --------------------|select boxes|--------------------------
    ===============================================================*/
    get warehouseOptions() {
        return this.warehouses;
    }

    handleWarehouseChange(e) {
        this.clearStuff(); 
        this.WarehouseVal = e.detail.value;
        this.chosenWarehouse = e.detail.value;
        this.shoechangingLoader = true;

                //go get all of the warehouse data to preopulate the selectboxes
                getRacksFromWarehouse({"warehouse": e.detail.value})
                .then(result => {   
                    this.shoechangingLoader = false;
                    //console.log(JSON.stringify(result)); 
                    //console.log(result.racks); 
                    
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

    }



    get rackOptions() {
        return this.racks;
    }

    handleRackChange(e) {
     
        this.rackVal = e.detail.value;
        this.chosenRack = e.detail.value;
        this.shoechangingLoader = true;
        
                //go get all of the warehouse data to preopulate the selectboxes
            getBaysFromRack({"rack": e.detail.value})
                .then(result => {   
                    
                    //console.log(result.racks); 
                    this.shoechangingLoader = false;
                    
                    if( result.bays.length ) {
                        
                        this.showBays = true;
                        this.showShelfNameSelect = true;
                        result.bays.map((e) => {
                            this.bays = [...this.bays ,{value: e.Id , label: e.Name__c.toString()} ];//{Id: 'aH93g000000CaRICA0', Name: 'E4 - Facilities'}
                        });
                        console.log(JSON.stringify(this.bays)); 
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



    get bayOptions() {
        return this.bays;
    }

    handleBayChange(e) {
        
        
        this.bayVal = e.detail.value;
        this.chosenBay = e.detail.value;
        console.log('bay val: ' + e.detail.value )




    }



    get getTagTypeOptions() {
        return [
            { label: 'Asset', value: 'Asset' },
            { label: 'Shelf/Scannable Location', value: 'Shelf' },
        ];
    }

    handleTagTypeChange(e) {
        this.clearStuff(); 
        this.TagTypeVal = e.detail.value;
        console.log(e.detail.value)
        if(e.detail.value.toLowerCase() == 'shelf') {
            this.showWarehouse = true;

            //this.showShelfNameSelect = true;

            var label = dymo.label.framework.openLabelXml(this.Dymo_Shelf_Tag_Durable_Label);
            var labelleSet = new dymo.label.framework.LabelSetBuilder();
                var record =labelleSet.addRecord();
                record.setText('BAY', 'Bay: ' + this.chosenBay + '' );
                record.setText('SHELF', 'Shelf: SHELF 0001' );
                record.setText('WAREHOUSE_NAME', this.chosenWarehouse);
                record.setText('Asset_Tag_QR', [e.name]  )                            
            
    
            var pngData = label.render();
            this.PreviewImageSrc = "data:image/png;base64," + pngData;
        } else {
            this.showShelfNameSelect = false;
            this.showWarehouse = false;
            var previewLabel = dymo.label.framework.openLabelXml(this.Dymo_Asset_Tag_Durable_Label);
            var pngData = previewLabel.render();
            this.PreviewImageSrc = "data:image/png;base64," + pngData;
        }
    }


    get printerOptions() {
        return this.printers;
    }

    handlePrinterChange(e) {
        this.printerVal = e.detail.value;
        this.chosenPrinter = e.detail.value;
    }


/*
    get numLabelsPerTagOptions() {
        return [
            { label: '1', value: '1' },
            { label: '2', value: '2' },
        ];
    }*/

    numLabelsPerTagChange(e) {
        if(  e.detail.value > 2 ) {
            this.numLabelsPerTagVal = 2;
        }
        if(  e.detail.value < 2 ) {
            this.numLabelsPerTagVal = 1;
        }

     
    }
    

    quantityChange(e) {
        this.quantityVal = e.detail.value;
    }




    shelfNameChange(e) {
       this.chosenShelfName =   e.detail.value;
    }

    /**
     * checkSupport()
     * 
     * checks if dymo is installed correctly and lists printers
     */
    checkSupport() {
        var result = dymo.label.framework.checkEnvironment();

        this.isBrowserSupported = result.isBrowserSupported;
        this. isFrameworkInstalled = result.isFrameworkInstalled;
        if(dymo.label.framework.init){
            this.isWebServicePresent  =  result.isWebServicePresent;
        }

        this.showDymoChecks = true;
    }



    /**
     * handleClick()
     * 
     * print those bitches
     * 
     * @param {*} e 
     */
    handleClick(e) {

        try {
       
          insertTags({"Quantity": this.quantityVal, "TagType": this.TagTypeVal,  Bay: this.bayVal,  Rack: this.rackVal,  Warehouse: this.WarehouseVal, ShelfName: this.chosenShelfName })
            .then(result => {   
    
                console.log(JSON.stringify(result));
           

                    if( this.TagTypeVal == 'Asset' ) {

                        //var label = dymo.label.framework.openLabelXml(this.Dymo_Asset_Tag_Durable_Label);
                        var label = dymo.label.framework.openLabelXml(this.Dymo_Asset_Tag_Durable_Label_double);
                        //var label = dymo.label.framework.openLabelXml(this.Dymo_Asset_Tag_Durable_Label);
                        var labelleSet = new dymo.label.framework.LabelSetBuilder();


                        result.map((e) => {
                            var record =labelleSet.addRecord();
                            record.setText('TEXT_TOP_SMALL', [e.name]);
                            record.setText('GRAPHIC_top', [e.name] )  
                            record.setText('Asset_Tag_Name_Text', [e.name]);
                            record.setText('NOC_Info', [e.name]);
                            record.setText('Asset_Tag_QR', [e.name] )                            
                        })
    
                        if( this.numLabelsPerTagVal == 1 ) {
                            label.print(this.printerVal,  this.DymoPrintOneParamXML, labelleSet );
                        } else {
                            label.print(this.printerVal,  this.DymoPrintTwoParamXML, labelleSet );
                        }
                        
                        

    
                        console.log(label.isValidLabel())
                    } else {
                        console.log('shelf')
                        var label = dymo.label.framework.openLabelXml(this.Dymo_Shelf_Tag_Durable_Label);
                        var labelleSet = new dymo.label.framework.LabelSetBuilder();


                        result.map((e) => {
                            console.log( JSON.stringify(e) );
                            var record =labelleSet.addRecord();
                            record.setText('RACK-BAY-Shelf', e.rack + ' - ' + e.bay + ' - ' + e.name + ' ');
                            record.setText('WAREHOUSE_NAME', e.warehouse);
                            record.setText('Asset_Tag_QR', [e.autoname]  )                            
                        })
                        
    
                        if( this.numLabelsPerTagVal == 1 ) {
                            label.print(this.printerVal,  this.DymoPrintOneParamXML, labelleSet );
                        } else {
                            label.print(this.printerVal,  this.DymoPrintTwoParamXML, labelleSet );
                        }

                    }


    
            })
            .catch(error => {
                console.log('there was an error' );
                console.log(error);     
            });
        
            
        }
        catch (e) {
            alert(e.message);
        }


    }



    hanlePrintTagsForRack() {
        console.log('get shelves' + this.chosenRack);
        this.shoechangingLoader = true;
        getShelvesFromRack({"rack": this.chosenRack})
        .then(result => {   
            console.log(JSON.stringify(result)); 
            this.shoechangingLoader = false;
            
            var label = dymo.label.framework.openLabelXml(this.Dymo_Shelf_Tag_Durable_Label);
            var labelleSet = new dymo.label.framework.LabelSetBuilder();


            result["shelves"].map((e) => {
                var record =labelleSet.addRecord();
                record.setText('RACK-BAY-Shelf', e.Warehouse_Rack_Name__c + ' - ' + e.Warehouse_Bay_Name__c + ' - ' + e.Name__c + ' ');
                record.setText('WAREHOUSE_NAME', e. Warehouse__r.Name);
                record.setText('Asset_Tag_QR', [e.Shelf_Tag_Name__c]  )                            
            })

            if( this.numLabelsPerTagVal == 1 ) {
                label.print(this.printerVal,  this.DymoPrintOneParamXML, labelleSet );
            } else {
                label.print(this.printerVal,  this.DymoPrintTwoParamXML, labelleSet );
            }     

        })
        .catch(error => {
            //this.shoechangingLoader = false;
            console.log('there was an error');
            console.log(error);     
        });
    }
    clearStuff() {

        this.bayVal = '';
        this.rackVal = '';
        this.showBays = false;
        this.showRacks = false;
        this.shoechangingLoader = false;
       
    }


}