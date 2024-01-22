/**
 * InventoryGlobalController
 * 
 * Global class for all things inventory related
 * 
 */
global without sharing class InventoryGlobalController {

    /**
     * getWarehouseShelfTagInfo()
     *  
     * gets fields for Warehouse_Shelf__c being passed in 
     * @param       ShelfId     String      Id of Warehouse_Shelf__c
     * @see         /lwc/inventoryPrintSingleTagFromObject/inventoryPrintSingleTagFromObject.js
     * @see     /lwc/inventoryPrintSingleTagFromObject/inventoryPrintSingleTagFromObject.js
     * @return      List<Warehouse_Shelf__c>
     */
    @AuraEnabled(cacheable=true)
    public static List<Warehouse_Shelf__c> getWarehouseShelfTagInfo(String ShelfId)  {
        Warehouse_Shelf__c[] shelfTagInfo  = [SELECT Id, Name__c, QR_Code__c, Warehouse_Bay_Name__c, Warehouse_Rack_Name__c, Warehouse_Name__c, Shelf_Tag_Name__c FROM Warehouse_Shelf__c where id = :ShelfId LIMIT 1 ];
        return shelfTagInfo;
    }
    /*---------------------------------------------------*/


 

    /**
     * getWarehouseAsseTagInfo()
     * 
     * Gets feilds for asset by Id
     * @param       AssetId     String      Id of Asset
     * @see         /lwc/inventoryPrintSingleTagFromObject/inventoryPrintSingleTagFromObject.js
     * @see         /lwc/inventoryPrintSingleTagFromObject/inventoryPrintSingleTagFromObject.js
     * @return      List<Asset>
     */
    @AuraEnabled(cacheable=true)
    public static List<Asset> getWarehouseAsseTagInfo(String AssetId)  {
        Asset[] assetTagInfo  = [SELECT Id, Name  FROM Asset where id = :AssetId LIMIT 1 ];
        return assetTagInfo;
    }
    /*---------------------------------------------------*/




    /**
     * getWarehouses()
     * 
     * Gets all warehouses
     * 
     * @see         /lwc/inventoryScanToLocation/inventoryScanToLocation.js
     * @return      List<Warehouse__c>
     */
    @AuraEnabled(cacheable=true)
    public static List<Warehouse__c> getWarehouses()  {
        Warehouse__c[] warehouses  = [SELECT Id, Name FROM Warehouse__c ORDER BY Name ASC];
        return warehouses;
    }
    /*---------------------------------------------------*/




    /**
     * getRacksFromWarehouse()
     * 
     * returns racks for a Warehouse__c Id passed in
     * @param       warehouse       String      Id of Warehouse__c
     * @see         /lwc/inventoryScanToLocation/inventoryScanToLocation.js
     * @see         /lwc/inventoryCreateTags/inventoryCreateTags.js
     * @return      List<Warehouse__c>
     */
    @AuraEnabled(cacheable=true)
    public static Map<String,Object> getRacksFromWarehouse(String warehouse)  {
        
        Map<String, Object> returnMap = new Map<String, Object>();
        Warehouse__c[] location  = [SELECT Id, Name FROM Warehouse__c where Id = :warehouse  LIMIT 1];
        if(location != null && location.size() > 0 ) {
            //get racks
            Warehouse_Rack__c[] racks = [SELECT Id, Name__c FROM Warehouse_Rack__c where Warehouse__c = :location[0].Id ];
            Map<String,Warehouse_Rack__c> rackMap = new Map<String,Warehouse_Rack__c>();
            if( racks != null && racks.size() > 0 ) {
                for( Warehouse_Rack__c r : racks ) {
                    rackMap.put(r.Name__c, r);
                }
            }
            returnMap.put('racks', racks);
        }
        return returnMap;
    }
    /*---------------------------------------------------*/




    /**
     * getBaysFromRack()
     * 
     * Gets list of Warehouse_Bay__c via Warehouse_Rack__c Id passed in
     * @param       rack        String      Id of Warehouse_Rack__c
     * @see         /lwc/inventoryScanToLocation/inventoryScanToLocation.js
     * @see         /lwc/inventoryCreateTags/inventoryCreateTags.js
     * @return      Map<String, Warehouse_Bay__c>
     */
    @AuraEnabled(cacheable=true)
    public static Map<String,Object> getBaysFromRack(String rack)  {
        Map<String, Object> returnMap = new Map<String, Object>();
        Warehouse_Rack__c[] rackLocation  = [SELECT Id, Name__c FROM Warehouse_Rack__c where Id = :rack  LIMIT 1];
        if(rackLocation != null && rackLocation.size() > 0 ) {
            //get Bays
            Warehouse_Bay__c[] bays = [SELECT Id, Name__c FROM Warehouse_Bay__c where Warehouse_Rack__c  = :rackLocation[0].Id ];
            Map<String,Warehouse_Bay__c> bayMap = new Map<String,Warehouse_Bay__c>();
            if( bays != null && bays.size() > 0 ) {
                for( Warehouse_Bay__c r : bays ) {
                    bayMap.put( String.valueOf(r.Name__c), r);
                }
            }
            returnMap.put('bays', bays);
        }
        return returnMap;
    }
    /*---------------------------------------------------*/






    /**
     * getShelvesFromBay()
     * 
     * Gets List of Warehouse_Shelf__c by passed in Warehouse_Bay__c Id
     * 
     * @param       bay     String      Id of Warehouse_Bay__c
     * @see         /lwc/inventoryScanToLocation/inventoryScanToLocation.js
     * @return      Map<String, Warehouse_Shelf__c>
     */
    @AuraEnabled(cacheable=false)
    public static Map<String,Object> getShelvesFromBay(String bay)  {
        Map<String, Object> returnMap = new Map<String, Object>();
        Warehouse_Bay__c[] bayLocation  = [SELECT Id, Name__c FROM Warehouse_Bay__c where Id = :bay  LIMIT 1];
        if(bayLocation != null && bayLocation.size() > 0 ) {
            //get Bays
            Warehouse_Shelf__c[] shelves = [SELECT Id, Name__c FROM Warehouse_Shelf__c where Warehouse_Bay__c  = :bayLocation[0].Id ];
            Map<String,Warehouse_Shelf__c> shelfMap = new Map<String,Warehouse_Shelf__c>();
            if( shelves != null && shelves.size() > 0 ) {
                for( Warehouse_Shelf__c r : shelves ) {
                    shelfMap.put(r.Name__c, r);
                }
            }
            returnMap.put('shelves', shelves);
        }
        return returnMap;
    } 
    /*---------------------------------------------------*/




    /**
     * getEverythingFromScannedShelf()
     * 
     * Gets Warehouse_Bay__c, Warehouse_Rack__c, Warehouse_Shelf__c via passed in shelf name
     * 
     * @param       shelfName       String      Name of shelf tag
     * @see         /lwc/inventoryScanToLocation/inventoryScanToLocation.js
     * @see         /lwc/inventoryCreateTags/inventoryCreateTags.js
     * @return      Map<String, Object> JSON to lwc
     */
    @AuraEnabled(cacheable=false)
    public static Map<String,Object> getEverythingFromScannedShelf(String shelfName)  {
        Map<String, Object> returnMap = new Map<String, Object>();


            Warehouse_Shelf__c[] shelf = [select Id, Name__c, Warehouse__c, Warehouse_Name__c,  Warehouse_Bay__c, Warehouse_Bay__r.Name__c, Warehouse_Bay__r.Warehouse_Rack__c, Warehouse_Bay__r.Warehouse_Rack__r.Name__c, Warehouse_Bay__r.Warehouse_Rack__r.Warehouse__c, Warehouse_Bay__r.Warehouse_Rack__r.Warehouse__r.Name FROM Warehouse_Shelf__c where Shelf_Tag_Name__c = :shelfName LIMIT 1 ];


              if(shelf != null && shelf.size() > 0 ) {
                for( Warehouse_Shelf__c s : shelf ) {
                    returnMap.put('message', 'success');
                    Map<String, Object> bayMap = new Map<String, Object>();
                    bayMap.put('Id', s.Warehouse_Bay__c);
                    bayMap.put('Name', s.Warehouse_Bay__r.Name__c);
                    returnMap.put('bay', bayMap);


                    Map<String, Object> rackMap = new Map<String, Object>();
                    rackMap.put('Id', s.Warehouse_Bay__r.Warehouse_Rack__c);
                    rackMap.put('Name', s.Warehouse_Bay__r.Warehouse_Rack__r.Name__c );
                    returnMap.put('rack', rackMap); 

                    Map<String, Object> warehousekMap = new Map<String, Object>();
                    warehousekMap.put('Id', s.Warehouse__c);
                    warehousekMap.put('Name', s.Warehouse_Name__c);
                    returnMap.put('warehouse', warehousekMap);


                    Map<String, Object> shelfMap = new Map<String, Object>();
                    shelfMap.put('Id', s.Id);
                    shelfMap.put('Name', s.Name__c);
                    returnMap.put('shelf', shelfMap);  
        
                }
            }
      
        return returnMap;
    }
    /*---------------------------------------------------*/    



    @AuraEnabled(cacheable=false)
    public static Map<String,Object> getShelvesFromRack( string rack) {
        System.debug('getting shelves from: ' + rack );
        Map<String, Object> returnMap = new Map<String, Object>();

        Warehouse_Rack__c[] rackLocation  = [SELECT Id, Name__c FROM Warehouse_Rack__c where Id = :rack  LIMIT 1];//aH9540000000160CAA
        Warehouse_Bay__c[] bays = [SELECT Id, Name__c FROM Warehouse_Bay__c where Warehouse_Rack__c  = :rackLocation[0].Id ];

        if( bays != null && bays.size() > 0 ) {
            //get shelves
             Warehouse_Shelf__c[] shelves = [SELECT Id, Shelf_Tag_Name__c,  Name__c, Warehouse_Bay_Name__c, Warehouse_Rack_Name__c, Warehouse__r.Name FROM Warehouse_Shelf__c where Warehouse_Bay__c  in :bays ];


             if( shelves != null && shelves.size() > 0 ) {
                //get shelf tags
                returnMap.put('shelves', shelves);
             }
             
        }

        System.debug(returnMap);
        return returnMap;


    }        


    @AuraEnabled(cacheable=true)
    public static List<Warehouse_Shelf__c> getShelvesFromWarehouse( string warehouseId) {
        Warehouse_Shelf__c[] location  = [select Id, Name__c, Warehouse__c, Warehouse_Name__c, Shelf_Tag_Name__c FROM Warehouse_Shelf__c where Warehouse__c = :warehouseId  LIMIT 1];


        System.debug(location);
        return location;
    }

    @AuraEnabled(cacheable=false)
    public static List<Warehouse_Shelf__c> createShelveFromWarehouse( string warehouseId ){
            CreateErrorRecord er = new CreateErrorRecord();
            Boolean upadated = false;
            List<Warehouse_Shelf__c> location = new List<Warehouse_Shelf__c>();

            Warehouse_Shelf__c w = new Warehouse_Shelf__c();
            w.Warehouse__c = warehouseId;

            try {

                insert w;
                location =  [select Id, Name__c, Warehouse__c, Warehouse_Name__c, Shelf_Tag_Name__c FROM Warehouse_Shelf__c where Id = :w.Id  LIMIT 1];
                System.debug('Inserted: ' + w.Id );
                System.debug('location: ' + location );
                upadated = true;
                
            } catch (Exception e) {
                System.debug( 'The Following excedption occured ' + e );
                er.create('InventoryGlobalController', '', e.getMessage(), e.getTypeName(), e.getLineNumber(), e.getStackTraceString(), false, true);
    
                
                throw e;
            }    

            return location;
 
    }




    /**
     * ConnectAssetToWarehouse()
     * 
     * Connects a passed in Asset to a Warehouse__c location
     * 
     * @param       warehouse       String      Id of Warehouse__c
     * @param       assetTag        String      name of Asset
     * @see         /lwc/inventoryScanToLocation/inventoryScanToLocation.js
     * @return       Map<String,Object> JSON for lwc
     */
    @AuraEnabled(cacheable=false)
    public static Map<String,Object> ConnectAssetToWarehouse( String warehouse, string assetTag, String shelf, Integer quantity ) {


        System.debug('Warehouse ' + warehouse);
        System.debug('AssetTag ' + assetTag);
        System.debug('quantity -- ' + quantity);

        Map<String, Object> returnMap = new Map<String, Object>();
        Boolean isAsset = assetTag.contains('EV-'); 
        

        if( isAsset ) {
            
            Asset[] a = [SELECT Id, Warehouse__c, Warehouse__r.Name,  Name, Quantity, Description FROM Asset where Name = :assetTag LIMIT 1 ];

            System.debug('is asset found ' + a[0].Id);

            //returnMap = ConnectAssetToWarehouseHelper(a, warehouse, assetTag, shelf, quantity );
            returnMap = ConnectAssetToWarehouseHelperNew(a, warehouse, assetTag, shelf, quantity );

        } else {
            Asset[] cereal = [SELECT Id, Warehouse__c, Warehouse__r.Name,  Name, SerialNumber, Quantity, Description  FROM Asset where SerialNumber = :assetTag LIMIT 1 ];

           // System.debug('is asset with serial # ' + cereal[0].Id);
             //returnMap = ConnectAssetToWarehouseHelper(cereal, warehouse, assetTag, shelf, quantity );
             returnMap = ConnectAssetToWarehouseHelperNew(cereal, warehouse, assetTag, shelf, quantity );

        }
        

        System.debug(returnMap);
        return returnMap;
    }
    /*---------------------------------------------------*/

    public static Map<String,Object> ConnectAssetToWarehouseHelperNew( List<Asset> a, String warehouse, String assetTag, String shelf, Integer quantity  ) {
        System.debug('ConnectAssetToWarehouseHelper');
        System.debug('warehouse: ' + warehouse );
        System.debug('assetTag: ' + assetTag );
        System.debug('shelf: ' + shelf );
        System.debug('quantity: ' + quantity );
        
        Map<String, Object> returnMap = new Map<String, Object>();//init a return map
        CreateErrorRecord er = new CreateErrorRecord(); //init an error record
        Boolean isAsset = assetTag.contains('EV-'); //check if scanned tag is an asset
        Account[] returnID = [SELECT Id   FROM Account  WHERE Name = 'Everstream' ORDER BY CreatedDate LIMIT  1]; //get default everstream id - dont ask you will need it.
        List<String> errors = new List<String>(); //init list of errors to track
        List<Asset_Movement_History__c> mvmnthistorys =  new List<Asset_Movement_History__c>();//init movment history
        Savepoint sp = Database.setSavepoint();//init a savepoint


        //check errors
        if(a?.size() < 1) {
            System.debug('No Asset Fount need to insert');
            errors.add('No Asset Fount need to insert');
        }



        if( errors.size() < 1 ) {
            
            Warehouse_Shelf__c[] shelfDestination = [SELECT Id, Warehouse__c, Warehouse__r.Id, Warehouse__r.Location_Type__c, Warehouse_Name__c FROM Warehouse_Shelf__c where Id = :shelf LIMIT 1 ];

            for( Asset assett :a ) {
    
                Warehouse__c chosenWarehouse = new Warehouse__c();

                //if warehouse is avaible from shelf else soql query
                if( shelfDestination != null && shelfDestination.size() > 0 ) {
                    
                    for( Warehouse_Shelf__c w : shelfDestination ) {
                        System.debug('get shelf and  warehouse from shelf '  + w.Warehouse__r.Id );
                        chosenWarehouse.Id = w.Warehouse__r.Id;
                        chosenWarehouse.Name = w.Warehouse_Name__c;
                        chosenWarehouse.Location_Type__c = w.Warehouse__r.Location_Type__c;
                    }

                } else {
                    //get warehouse
                    System.debug('get warehouse: ' );
                    Warehouse__c[] warhs = [SELECT Id, Name, Location_Type__c FROM Warehouse__c where id = :warehouse  limit 1];
                    if( warhs != null && warhs.size() > 0 ) {
                        for( Warehouse__c ww : warhs ) {
                            chosenWarehouse.Id = ww.Id;
                            chosenWarehouse.Name = ww.Name;
                            chosenWarehouse.Location_Type__c = ww.Location_Type__c;
                        }
                    }

                }
                //check if warehouse is a fixed warehouse or a vehivle location
                Boolean IsDestinationFixedWarehouse  = chosenWarehouse.Location_Type__c == 'Fixed' ? true : false;
                System.debug(chosenWarehouse);
                System.debug(IsDestinationFixedWarehouse);

              try {
                    if( quantity == null || quantity < 1 || quantity == assett.Quantity ) {
                        System.debug('quantity not passed in so move whole thing' );
                        assett.Warehouse__c = warehouse;

                        if( warehouse == 'aHM3g0000008OIKGA2') {
                            assett.Warehouse_Shelf__c = null;
                        } else {
                            if( shelf != '' ) {
                                assett.Warehouse_Shelf__c = shelf;
                            } else {
                                assett.Warehouse_Shelf__c = null;
                            } 
                        }

                        
                        Asset_Movement_History__c assetHistoyThree = new Asset_Movement_History__c();
                        assetHistoyThree.Asset__c = assett.Id;
                        assetHistoyThree.Transfer_Date__c = Date.today();
                        assetHistoyThree.Starting_Warehouse__c = assett.Warehouse__c;
                        assetHistoyThree.Destination_Warehouse__c = warehouse;
                        assetHistoyThree.note__c = assett.Name + ' Moved From ' + assett.Warehouse__c + ' to ' + warehouse;
                        mvmnthistorys.add(assetHistoyThree);
    
                    } else {
                        System.debug('quantity passed in' );
    
                        //set the new quantiy level
                        Decimal newQty = assett.Quantity - quantity;
                        assett.Quantity = newQty;
    
                        if(IsDestinationFixedWarehouse) {
                            System.debug('moving to a fixed warehouse' );
                            // fixed -> fixed = clone and update quantity

                            //create a new tag for the clone
                            Asset_Tag__c assetTagi = new Asset_Tag__c();
                            insert assetTagi;
        
                            //clone current/exising asset and set name to asset tag created above
                            Asset cloneAsset = assett.clone(false, true, false, false);
                            Asset_Tag__c[] insertedAssetTAgs = [SELECT Id, Name FROM Asset_Tag__c WHERE Id = :assetTagi.Id LIMIT 1 ];

                            if( insertedAssetTAgs != null && insertedAssetTAgs.size() > 0 ) {
                                for(Asset_Tag__c iat :insertedAssetTAgs ) {
                                    cloneAsset.Name = iat.Name;
                                }
                            }
                            cloneAsset.Quantity = quantity;
                            cloneAsset.Warehouse__c= warehouse; 
                            cloneAsset.AccountId = returnID[0].Id;
                            cloneAsset.Cloned_From__c = assett.Id;
                            cloneAsset.Description = assett.Description;


                            //if deployed cleare out shelf on cloned asset
                            if( warehouse == 'aHM3g0000008OIKGA2') {
                                cloneAsset.Warehouse_Shelf__c =  null;
                            } else {
                                if( shelf != '' ) {
                                    cloneAsset.Warehouse_Shelf__c = shelf;
                                }                
                            }

                            
                            insert cloneAsset;

                            System.debug('**************************************');
                            System.debug(cloneAsset);

                            Asset_Movement_History__c assetHistoyOne = new Asset_Movement_History__c();
                            assetHistoyOne.Asset__c = assett.Id;
                            assetHistoyOne.Transfer_Date__c = Date.today();
                            assetHistoyOne.Starting_Warehouse__c = assett.Warehouse__c;
                            assetHistoyOne.Destination_Warehouse__c = warehouse;
                            assetHistoyOne.Quantity__c = quantity;
                            assetHistoyOne.note__c = assett.Name + 'cloned and added to ' + warehouse + ' as ' + cloneAsset.Name;
                            mvmnthistorys.add(assetHistoyOne);
        
    
                        } else {
                            System.debug('moving to a vehicle location' );
                            // fixed -> mobile = update quantity and create mvmnt record
                            //quantity is update alerady

                            Asset_Movement_History__c assetHistoyTwo = new Asset_Movement_History__c();
                            assetHistoyTwo.Asset__c = assett.Id;
                            assetHistoyTwo.Transfer_Date__c = Date.today();
                            assetHistoyTwo.Starting_Warehouse__c = assett.Warehouse__c;
                            assetHistoyTwo.Destination_Warehouse__c = warehouse;
                            assetHistoyTwo.Quantity__c = quantity;
                            assetHistoyTwo.note__c = assett.Name + ' moved from ' + assett.Warehouse__c + ' to vehicle location: ' + warehouse;
                            mvmnthistorys.add(assetHistoyTwo);
    
                        }
                    }

                    //insert movment history
                    if( mvmnthistorys != null && mvmnthistorys.size() > 0 ) {
                        insert mvmnthistorys;
                    }

                    //update the initial asset
                    update a;
                    returnMap.put('status', 'success');
                    System.debug('Updated Asset');
    
                    //set return json here
                     if(  String.isBlank(assett.Warehouse__c)  ) {
                        System.debug('assign new warehouse');
    
                        //set message for toast
                        if(isAsset) {
                            returnMap.put('message', 'Asset ' + assetTag + ' assigned to warehouse ' + chosenWarehouse.Name + ''); 
                        } else {
                            returnMap.put('message', 'Asset ' + assetTag + ' (Serial #: ' + assett.SerialNumber + ' ) assigned to warehouse ' + chosenWarehouse.Name + '');
                        }
                    
                        returnMap.put('to', chosenWarehouse.Name);
                        returnMap.put('isMove', 'false');
                        returnMap.put('message', 'assigned to warehouse');
                        if( quantity != null || quantity > 0 ) {
                            returnMap.put('quantity', quantity);
                        }
                        
                        if(!isAsset) {
                            returnMap.put('serial', assett.SerialNumber );
                        }
    
                    } else {
                        //has warehouse already
                        returnMap.put('from', assett.Warehouse__r.Name);
                        returnMap.put('to', chosenWarehouse.Name);
                        returnMap.put('isMove', 'true');
                        if(!isAsset) {
                            returnMap.put('serial', assett.SerialNumber );
                        }
                        if( quantity != null || quantity > 0 ) {
                            returnMap.put('quantity', quantity);
                        }
                    
                    }       
    
                    returnMap.put('name', assett.Name);
    
    
                } catch (Exception e) {
                    Database.rollback(sp);//rollback if insert error
                    System.debug( 'The Following excedption occured ' + e );
                    er.create('InventoryGlobalController', '', e.getMessage(), e.getTypeName(), e.getLineNumber(), e.getStackTraceString(), false, true);
                    returnMap.put('status', 'error');
                    returnMap.put('message', 'there was an error' + e);
                    throw e;
                } 

            }

        } else  {           
            if( errors.size() > 0 ) {
                returnMap.put('errors', errors );
            }
        }
        System.debug(returnMap);
        return returnMap;
    }
    


/*
    public static Map<String,Object> ConnectAssetToWarehouseHelper( List<Asset> a, String warehouse, String assetTag, String shelf, Integer quantity  ) {

        System.debug('ConnectAssetToWarehouseHelper');
        System.debug('warehouse: ' + warehouse );
        System.debug('assetTag: ' + assetTag );
        System.debug('shelf: ' + shelf );
        System.debug('quantity: ' + quantity );

        Map<String, Object> returnMap = new Map<String, Object>();
        CreateErrorRecord er = new CreateErrorRecord();

        Boolean isAsset = assetTag.contains('EV-');
        Account[] returnID = [SELECT Id   FROM Account  WHERE Name = 'Everstream' ORDER BY CreatedDate LIMIT 1];

        if( a != null && a.size() > 0 ) {

            Warehouse_Shelf__c[] shelfDestination = [SELECT Id, Warehouse__c, Warehouse__r.Id,  Warehouse_Name__c FROM Warehouse_Shelf__c where Id = :shelf LIMIT 1 ];

            Warehouse__c chosenWarehouse = new Warehouse__c();

            if( shelfDestination != null && shelfDestination.size() > 0 ) {
                System.debug('get shelf and  warehouse from shelf '  + shelfDestination[0].Warehouse__r.Id );
                chosenWarehouse.Id = shelfDestination[0].Warehouse__r.Id;
                chosenWarehouse.Name = shelfDestination[0].Warehouse_Name__c;
            } else {
                //get warehouse
                System.debug('get warehouse: ' );
                Warehouse__c[] w = [SELECT Id, Name FROM Warehouse__c where id = :warehouse  limit 1];
                chosenWarehouse.Id = w[0].Id;
                chosenWarehouse.Name = w[0].name;
            }
 
            //update
            try {

                //check quantity
                if( quantity == null || quantity < 1 || quantity == a[0].Quantity ) {

                    System.debug('quantity not passed in so move whole thing' );
                    a[0].Warehouse__c = warehouse;

                    if( warehouse == 'aHM3g0000008OIKGA2') {
                        a[0].Warehouse_Shelf__c = null;
                    } else {
                        if( shelf != '' ) {
                            a[0].Warehouse_Shelf__c = shelf;
                        } else {
                            a[0].Warehouse_Shelf__c = null;
                        } 
                    }



                } else {
                    System.debug('quantity passed update quantity on old and and set on new clone after clone' );
                    
                    Decimal newQty = a[0].Quantity - quantity;
                    a[0].Quantity = newQty;

                    //genereate new asset tag and get the ev-######
                    Asset_Tag__c assetTagi = new Asset_Tag__c();
                    insert assetTagi;

                    //clone current asset and set name to asset tag created above
                 /*   Asset cloneAsset = a[0].clone(false, true, false, false);
                    Asset_Tag__c[] insertedAssetTAgs = [SELECT Id, Name FROM Asset_Tag__c WHERE Id = :assetTagi.Id LIMIT 1 ];
                    cloneAsset.Name = insertedAssetTAgs[0].Name;
                    cloneAsset.Quantity = quantity;
                    cloneAsset.Warehouse__c= warehouse; 
                    cloneAsset.AccountId = returnID[0].Id;
                    cloneAsset.Cloned_From__c = a[0].Id;
                    cloneAsset.Description = a[0].Description;*/

                    //if deployed cleare out shelf on cloned asset
                   /* if( warehouse == 'aHM3g0000008OIKGA2') {
                        cloneAsset.Warehouse_Shelf__c =  null;

                    } else {
                        if( shelf != '' ) {
                            cloneAsset.Warehouse_Shelf__c = shelf;
                        }                
                   // }*/
                    

                   // insert cloneAsset;

                    //System.debug('**************************************');
                    //System.debug(cloneAsset);
             
                    //see if movement history is alreday created, if so update the source and destination field
                    /*
                }

                update a;
                returnMap.put('status', 'success');
                System.debug('Updated Asset');


                //set return json here
                 if(  String.isBlank(a[0].Warehouse__c)  ) {
                    System.debug('assign new warehouse');

                    //set message for toast
                    if(isAsset) {
                        returnMap.put('message', 'Asset ' + assetTag + ' assigned to warehouse ' + chosenWarehouse.Name + ''); 
                    } else {
                        returnMap.put('message', 'Asset ' + assetTag + ' (Serial #: ' + a[0].SerialNumber + ' ) assigned to warehouse ' + chosenWarehouse.Name + '');
                    }
                
                    returnMap.put('to', chosenWarehouse.Name);
                    returnMap.put('isMove', 'false');
                    returnMap.put('message', 'assigned to warehouse');
                    if( quantity != null || quantity > 0 ) {
                        returnMap.put('quantity', quantity);
                    }
                    
                    if(!isAsset) {
                        returnMap.put('serial', a[0].SerialNumber );
                    }

                } else {
                    //has warehouse already
                    returnMap.put('from', a[0].Warehouse__r.Name);
                    returnMap.put('to', chosenWarehouse.Name);
                    returnMap.put('isMove', 'true');
                    if(!isAsset) {
                        returnMap.put('serial', a[0].SerialNumber );
                    }
                    if( quantity != null || quantity > 0 ) {
                        returnMap.put('quantity', quantity);
                    }
                
                }       

                returnMap.put('name', a[0].Name);






            } catch (Exception e) {
                System.debug( 'The Following excedption occured ' + e );
                er.create('InventoryGlobalController', '', e.getMessage(), e.getTypeName(), e.getLineNumber(), e.getStackTraceString(), false, true);
                returnMap.put('status', 'error');
                returnMap.put('message', 'there was an error' + e);
                
                throw e;
            }    


        } else {
            System.debug('No Asset Fount need to insert');
            returnMap.put('status', 'notfound');
            returnMap.put('notcreated', 'true');


        }



        return returnMap;
    }

*/











    /**
     * createAsset()
     * 
     * Creates Asset
     * 
     * @param       PO          String      Id of Purchase_Order__c
     * @param       POLine      String      Id of Purchase_Order_Line__c
     * @param       tagName     String      Name of asset/shelf tag that will be created
     * @see         /lwc/inventoryScanToLocation/inventoryScanToLocation.js
     * @see         /lwc/receiveAssets/receiveAssets.js
     * @return      Map<String,Object>
     * 
     * LEFT OFF HERE
     */
    @AuraEnabled(cacheable=false)
    public static Map<String,Object> createAsset(  String PO, String warehouse, String POLine, String tagName, String vendor, Integer quantity, Integer minStockQuantity ) {
        CreateErrorRecord er = new CreateErrorRecord();
        Map<String, Object> returnMap = new Map<String, Object>();


        Boolean isAsset = tagName.contains('EV-');

        Receiving__c rec = new Receiving__c();
        if( PO != '' ) {
            rec.Purchase_Order__c = PO;
        }
        rec.Warehouse__c = warehouse;
        

        Purchase_Order_Line__c[] p = [SELECT Id, Name, Quantity__c, Description__c, Unit_Price__c, Purchase_Order_Detail__c FROM Purchase_Order_Line__c where Id = :POLine LIMIT 1  ];
        Account[] returnID = [SELECT Id   FROM Account  WHERE Name = 'Everstream' ORDER BY CreatedDate LIMIT 1];
        Warehouse__c[] w = [SELECT Id, Name FROM Warehouse__c where id = :warehouse  limit 1];

        //create reciving record
        try {
            insert rec;
            System.debug('inserted: ' + rec.Id );


        //create asset record
            Asset assetttt = new Asset();
                assetttt.Name = tagName;
                assetttt.AccountId = returnID[0].Id;
                assetttt.Purchase_Order_Line__c = POLine;
                assetttt.Receiving__c = rec.Id;
                assetttt.Tag_Number__c = tagName;
                assetttt.Warehouse__c = warehouse;

                if(p != null && p.size() > 0 ) {
                    assetttt.Description = p[0].Description__c;
                    assetttt.Purchase_Order_Price__c = p[0].Unit_Price__c;
                    assetttt.Related_Purchase_Order__c = p[0].Purchase_Order_Detail__c;
                }

                assetttt.Quantity = 1;

                if( !isAsset ) {
                    assetttt.SerialNumber = tagName;
                }

                if(vendor != '')  {
                    assetttt.Vendor_Account__c =  vendor;
                }

                
                if( minStockQuantity != null  ) {
                    assetttt.minimum_stock_quantity__c = minStockQuantity;
                }

                
            
                    try {
                        //insert the assetttt
                        insert assetttt;
                        System.debug('Successfully inserted assetttt ' + assetttt.Id );
                        returnMap.put('status', 'success');
                        returnMap.put('success', 'created asset record: ' + tagName);
                        returnMap.put('to', w[0].Name);
                        returnMap.put('isMove', 'false');
                        returnMap.put('message', 'assigned to warehouse' + w[0].Name);
                        returnMap.put('name', tagName);
                    } catch (Exception e) {
                        System.debug( 'The Following excedption occured on inventoryScanToLocation when creating asset: ' + e );
                        er.create('InventoryGlobalController', '', e.getMessage(), e.getTypeName(), e.getLineNumber(), e.getStackTraceString(), false, true);
                        throw e;
                    }   

    





            
        } catch (Exception e) {
            System.debug(e);
        }




        

        return returnMap;
    }
    /*---------------------------------------------------*/
  


    /**
     * POLines()
     * 
     * gets a list of Purchase_Order_Line__c by Purchase_Order_Detail__c Id
     * 
     * @param       POID        String      Id of Purchase_Order_Detail__c
     * @see         /lwc/inventoryScanToLocation/inventoryScanToLocation.js
     * @return      List<Purchase_Order_Line__c>
     */
    @AuraEnabled(cacheable=false)
    public static List<Purchase_Order_Line__c> POLines(String POID) {
        List<Purchase_Order_Line__c> polinesToRetrun = new List<Purchase_Order_Line__c>();

        Purchase_Order_Line__c[] polines = [SELECT Id, Name, Quantity__c, Description__c FROM Purchase_Order_Line__c where Purchase_Order_Detail__c = :POID  ];

        if(polines != null && polines.size() > 0 ) {
            for(Purchase_Order_Line__c p : polines ) {
                polinesToRetrun.add(p);
            }
        }
        return polinesToRetrun;

    }
    /*---------------------------------------------------*/



    /**
     * insertTags()
     * 
     * Inserts Asset/Shelf_Tag__c, creates Warehouse_Shelf__c if Shelf_Tag__c is created
     * 
     * @param       Quantity        Integer     number of tags to create
     * @param       TagType         String      type of tag to create: asset/shelf
     * @param       Bay             String      Id of Warehouse_Bay__c
     * @param       Rack            String      Id of Warehouse_Rack__c
     * @param       Warehouse       String      Id of Warehouse__c
     * 
     * @see         /lwc/inventoryCreateTags/inventoryCreateTags.js
     * @return      List<Object> JSON for LWC
     */
    @AuraEnabled(cacheable=false)
    global static List<Object> insertTags( Integer Quantity, String TagType, String Bay, String Rack, String Warehouse, String ShelfName  ) {
        CreateErrorRecord er = new CreateErrorRecord();
        System.debug('quantity: ' + Quantity);
        System.debug('tagType: ' + TagType);
        System.debug('Bay: ' + Bay);
        System.debug('Rack: ' + Rack);   
        System.debug('Warehouse: ' + Warehouse);        

        List<Object> returnList = new List<Object>();
        List<Asset_Tag__c> assetTagsToInsert = new List<Asset_Tag__c>();
        List<Shelf_Tag__c> shelfTagsToInsert = new List<Shelf_Tag__c>();
        Warehouse_Bay__c chosenBay = new Warehouse_Bay__c(); 
        
        List<Warehouse_Shelf__c> ShelvesToInsert = new List<Warehouse_Shelf__c>();

        

        Boolean shelfExits = false; 
        List<Warehouse_Shelf__c> shelfTagExisting = new List<Warehouse_Shelf__c>();
        



        if(TagType == 'Asset') {
            for (Integer i = 0; i < Quantity; i++) {
                Asset_Tag__c assetTagi = new Asset_Tag__c();
                assetTagsToInsert.add(assetTagi);
                //System.debug('adding ' + i );
            }
            System.debug(assetTagsToInsert);
        } else {

            //check for existing
            shelfTagExisting = [SELECT Id, Name__c, Warehouse_Bay__c, QR_Code__c, Warehouse_Name__c, Warehouse_Bay_Name__c, Shelf_Tag_Name__c, Warehouse_Rack_Name__c from Warehouse_Shelf__c where Warehouse_Bay__c = :Bay AND Name__c = :ShelfName];
            if(shelfTagExisting != null && shelfTagExisting.size() > 0 ) {
                shelfExits = true;
            }
            
            System.debug('Make a shelve ' );
            Warehouse_Bay__c[]  getBay = [SELECT Id, Name__c FROM Warehouse_Bay__c WHERE Id = : bay LIMIT 1 ];

            

            if( getBay != null && getBay.size() > 0 ) {
                chosenBay.Id = getBay[0].Id;
                chosenBay.Name__c = getBay[0].Name__c;
            }
            for (Integer i = 0; i < Quantity; i++) {
                Shelf_Tag__c shelfTag = new Shelf_Tag__c();
                shelfTagsToInsert.add(shelfTag);
            }
            System.debug(shelfTagsToInsert);

        }


        try {



            if(assetTagsToInsert != null && assetTagsToInsert.size() > 0 ) {
                System.debug(assetTagsToInsert);
               insert assetTagsToInsert; 
                Asset_Tag__c[] insertedAssTags = [SELECT Id, Name, Asset_Tag_QR_Code__c FROM Asset_Tag__c where Id in :assetTagsToInsert ];

                if( insertedAssTags != null && insertedAssTags.size() > 0 ) {
                    for (Asset_Tag__c a : insertedAssTags) {
                            System.debug('inserted' + a.Id);
                            Map<String, Object> tagMap = new Map<String, Object>();
                    
                            tagMap.put('name', a.Name);
                            tagMap.put('qrcode', a.Asset_Tag_QR_Code__c);
                            tagMap.put('Id', a.Id);
                            returnList.add(tagMap);
                    }
                }

            }

            //create new shelf
            if(shelfTagsToInsert != null && shelfTagsToInsert.size() > 0  && !shelfExits ) {
               insert shelfTagsToInsert;
     
               Shelf_Tag__c[] insertedShelfTags = [SELECT Id, Name FROM Shelf_Tag__c where Id in :shelfTagsToInsert ];



                if( insertedShelfTags != null && insertedShelfTags.size() > 0 ) {
                    for (Shelf_Tag__c a : insertedShelfTags) {
                        System.debug('inserted: ShelfTag ' + a.Id);
                        System.debug(chosenBay.Id);

                        //create the actual shelf at this point and set the bay, warehouse and rack
                        Warehouse_Shelf__c ws = new Warehouse_Shelf__c();
                        //if(chosenBay.Id != '') {ws.Warehouse_Bay__c = chosenBay.Id;}
                        if( chosenBay.Id != null) {   ws.Warehouse_Bay__c = chosenBay.Id; }
                        ws.Warehouse__c = Warehouse;
                        ws.Shelf_Tag_Lookup__c = a.Id;

                        if(ShelfName != '' ) {
                            ws.Name__c = ShelfName;
                        } else {
                            ws.Name__c  = 'A';
                        }
                        

                        
                        ShelvesToInsert.add(ws);

                    }
                    try {
                        insert ShelvesToInsert;
                        System.debug('inserted shelves');

                        Warehouse_Shelf__c[] insertedShelves = [SELECT Id,  Name, Warehouse_Name__c, Warehouse_Bay_Name__c,  Warehouse_Bay__c, Name__c, Warehouse_Rack_Name__c, QR_Code__c, Shelf_Tag_Name__c  FROM  Warehouse_Shelf__c where Id in :ShelvesToInsert ];



                        if(insertedShelves != null && insertedShelves.size() > 0 ) {
                            for (Warehouse_Shelf__c a : insertedShelves) {
                                    Map<String, Object> tagMap = new Map<String, Object>();
                                    System.debug('inserted shelf' + a.Id);
                                    tagMap.put('qrcode', a.QR_Code__c );
                                    tagMap.put('autoname', a.Shelf_Tag_Name__c);

                                    //now you can recalc the formula
                                    Formula.recalculateFormulas(new List<Warehouse_Shelf__c> { a });

                                    System.debug( a.Warehouse_Bay_Name__c);
                                    
                                    tagMap.put('warehouse', a.Warehouse_Name__c != null ? a.Warehouse_Name__c : '' );
                                    tagMap.put('bay', a.Warehouse_Bay_Name__c != null  ? a.Warehouse_Bay_Name__c : '' );
                                    tagMap.put('rack', a.Warehouse_Rack_Name__c != null  ? a.Warehouse_Rack_Name__c : '' );
                                    tagMap.put('name', a.Name__c);
                                    
                             
                                    returnList.add(tagMap);
                            }
                        }
                        
                        

                    } catch (Exception e ) {
                        System.debug(e.getMessage());
                    }
                }


            } else {
             
                if(shelfTagExisting != null && shelfTagExisting.size() > 0 ) {
                    Map<String, Object> tagMap = new Map<String, Object>();
                    tagMap.put('qrcode', shelfTagExisting[0].QR_Code__c );
                    tagMap.put('autoname', shelfTagExisting[0].Shelf_Tag_Name__c);
                    tagMap.put('warehouse', shelfTagExisting[0].Warehouse_Name__c != null ? shelfTagExisting[0].Warehouse_Name__c : '' );
                    tagMap.put('bay', shelfTagExisting[0].Warehouse_Bay_Name__c != null  ? shelfTagExisting[0].Warehouse_Bay_Name__c : '' );
                    tagMap.put('rack', shelfTagExisting[0].Warehouse_Rack_Name__c != null  ? shelfTagExisting[0].Warehouse_Rack_Name__c : '' );
                    tagMap.put('name', shelfTagExisting[0].Name__c);
                    
                    returnList.add(tagMap);
                }

            }
        
            
        } catch (Exception e) {
            er.create('InventoryGlobalController', '', e.getMessage(), e.getTypeName(), e.getLineNumber(), e.getStackTraceString(), false, true);
            //errror
            System.debug(e.getMessage());
        }



        System.debug(     returnList );    
        return returnList;
    }
    /*---------------------------------------------------*/



    /**
     * getStaticText()
     * 
     * Goes and gets the static resource and returns the xml value for LWC
     * 
     * @param       staticObjName       String      name of static resource to get xml value
     * @see         /lwc/inventoryCreateTags/inventoryCreateTags.js
     * @see         /lwc/inventoryPrintSingleTagFromObject/inventoryPrintSingleTagFromObject.js
     * @return      String
     */
    @AuraEnabled(cacheable=true)
    public static String getStaticText(String staticObjName) {
        String initValue = ''; 

        try {
            StaticResource sr = [select Body from StaticResource where Name = :staticObjName ];

            initValue = sr.Body.toString();
            initValue = initValue.replaceAll('(\\r|\\n)+', '').replaceAll('\\t+', '').replaceAll('\ufeff', '');
        } catch (Exception e) {
            initValue = '';
            // System.debug('****************************** getStaticText Issue ***********');
            // System.debug('Static Object Name: ' + staticObjName);
            System.debug(e.getMessage());
        }
        System.debug(initValue);
        return initValue;
    }
    /*---------------------------------------------------*/



    /**
     * POLinesRecId()
     * 
     * Gets PO lines for a Receiving__c object
     * 
     * @param        RecId       String      Id of Receiving__c
     * @see          /lwc/receiveAssets/receiveAssets.js
     * @return       List<Purchase_Order_Line__c>
     */
    @AuraEnabled(cacheable=true)
    public static List<Purchase_Order_Line__c> POLinesRecId(String RecId) {

        System.debug(RecId);
        List<Purchase_Order_Line__c> polinesToRetrun = new List<Purchase_Order_Line__c>();

        //get rec po
        Receiving__c[] rec = [SELECT Id, Purchase_Order__c FROM Receiving__c where Id = :RecId LIMIT 1 ];



        if( rec != null && rec.size() > 0 ) {
            for(Receiving__c r: rec ) {
                //get po lines from po above
                Purchase_Order_Line__c[] polines = [SELECT Id, Name, Quantity__c, Description__c FROM Purchase_Order_Line__c where Purchase_Order_Detail__c = :r.Purchase_Order__c  ];

                if(polines != null && polines.size() > 0 ) {
                    for(Purchase_Order_Line__c p : polines ) {
                        polinesToRetrun.add(p);
                    }
                }

            }
        }


        //return po lines to lwc
        return polinesToRetrun;
    }
    /*---------------------------------------------------*/



    /**
     * 
     * createAssetRec()
     * 
     *  @param       RecId       String      Id of Receiving__c
     *  @param       RecId       String      Id of Receiving__c
     *  @param       RecId       String      Id of Receiving__c
     *  @param       RecId       String      Id of Receiving__c
     *  @see         /lwc/receiveAssets/receiveAssets.js
     */
    //InventoryGlobalController.createAssetRec( 'aH7540000008OOWCA2', 'EV-12789', 'aAH3g000000TQS4GAO', '', 1, 100, '123456'  );
   @AuraEnabled(cacheable=false)
    public static Map<String,Object> createAssetRec( String RecId, String AssetTagNum, String ChosenPoLineId, String vendor, Integer quantity, Integer minStockQuantity, String serialNumber, String manualDesc, boolean skipError ) {

        System.debug('===============================================: ' + quantity );
        System.debug('skipError: ' + skipError );
        Map<String,Object> returnMap = new Map<String,Object>(); 
        Double assetPOLCount;
        CreateErrorRecord er = new CreateErrorRecord();
        Boolean isAsset = AssetTagNum.contains('EV-');

        List<Purchase_Order_Line__c> poline = new List<Purchase_Order_Line__c>();


        Receiving__c[] rec = [SELECT Id, Purchase_Order__c, Warehouse__c, Name FROM Receiving__c where Id = :RecId LIMIT 1 ];
        Account[] returnID = [SELECT Id   FROM Account  WHERE Name = 'Everstream' ORDER BY CreatedDate LIMIT 1];
        Asset[] assetCheck = [ SELECT Id   FROM Asset WHERE Tag_Number__c = :AssetTagNum ];

        List<Purchase_Order_Line__c> polinesToUpdate = new List<Purchase_Order_Line__c>();
        //Integer errors = 0;
        List<String> errors = new List<String>();
        List<String> duplicateSerial = new List<String>();
        Boolean isAssetTag = false;
        Asset_Tag__c[] insertedTag;


        

        //get record type for bulk asset
        // Id BulkAssetRecordTypeId = Schema.SObjectType.Asset.getRecordTypeInfosByName().get('Bulk').getRecordTypeId();
        Id BulkAssetRecordTypeId = '0123J000000MJgvQAG';

        //init a savepoint if need roll back
        Savepoint sp = Database.setSavepoint();
        

        //check reciving record
        if( rec != null && rec.size() > 0  ) {

            if( rec[0].Purchase_Order__c != null ) {
                Boolean isPOLocked = Approval.isLocked(rec[0].Purchase_Order__c); 
            }
              
        
            if( rec[0].Warehouse__c == null){
                System.debug('The Receiving is not related to a Warehouse.');
                errors.add('The Receiving is not related to a Warehouse.');
            }

            //check for existing
            if(!String.isBlank(AssetTagNum) ) {
                System.debug('asset tag not empty: ' + AssetTagNum );
                isAssetTag = true;
                if( assetCheck != null && assetCheck.size() > 0  ) {
                    System.debug('An Asset having Tag Number ['+AssetTagNum+'] already exists on an asset.');
                    errors.add('An Asset having Tag Number ['+AssetTagNum+'] already exists on an asset.');
                }
            } 

            if( ChosenPoLineId != ''  ) {
                poline = [SELECT Id, Name, Quantity__c, Description__c, Unit_Price__c, Purchase_Order_Detail__c, Quantity_Received__c, Purchase_Order_Product__c FROM Purchase_Order_Line__c where Id = :ChosenPoLineId LIMIT 1  ];
            }

       /*     //check serial number
        System.debug('serialNumber' + serialNumber + '::' + systemSNCount(serialNumber) );
        if(serialNumber != null && skipError == false ){
                    Integer serialNoCount = systemSNCount(serialNumber);
                    if ( serialNoCount>0 ) {
                        System.debug('Serial Number:['+serialNumber+'] already in use.');
                        duplicateSerial.add('Serial Number:['+serialNumber+'] already in use.');
                    }
            }*/

            if(ChosenPoLineId == '' && !String.isBlank(rec[0].Purchase_Order__c) ) {
                errors.add('This PO Line cannot be empty if there is a Purchase Order being Recieved ');
            }

            if( ChosenPoLineId != ''  ) {
                //check quantity

                assetPOLCount = assetPOLineCount( ChosenPoLineId );
                System.debug(assetPOLCount);
                System.debug('ID' + ChosenPoLineId);

                if ( assetPOLCount >= poline[0].Quantity__c ){
                    errors.add('This PO Line already has an asset count that matches the PO Line quantity');
                }

            } else {
                assetPOLCount = 0;
            }


        //if no errors then recieve asset
        if(  errors.size() < 1  ) {
        System.debug('no errors');
                if(  duplicateSerial.size() < 1 || skipError == true ) {  
                    System.debug(' duplicateSerial.size() < 1 || skipError == true :: ' + skipError);
                    try {
                        //scanned a serial #
                        if( !isAssetTag  ) {
                            System.debug('no tag number, checking for serial numbers ');
                            if( serialNumber != null || serialNumber != '' ) {
                                System.debug('has serial number creating asset and assigning to serial # ');
                                Asset_Tag__c assTagInsert = new Asset_Tag__c();
                                insert assTagInsert;

                                insertedTag = [SELECT Id, Name FROM Asset_Tag__c WHERE Id = :assTagInsert.Id limit 1 ];

                            } else {
                                returnMap.put('error','The barcode may not be blank.');
                            }
                        }

                         //build the asset
                        if( rec != null && rec.size() > 0 ) {
                            for( Receiving__c r : rec ) {
                                Asset assettt = new Asset();
                                assettt.AccountId = returnID[0].Id;
                                assettt.Warehouse__c = rec[0].Warehouse__c;
                                assettt.SerialNumber = serialNumber;

                                if( quantity > 1 ) {
                                    assettt.RecordTypeId = BulkAssetRecordTypeId;
                                }

                                //if is serial # only
                                if( !isAssetTag ) {
                                    if(insertedTag != null && insertedTag.size() > 0 ) {
                                        
                                        assettt.Receiving__c = RecId;
                                        assettt.Asset_Tag_Lookup__c = insertedTag[0].Id;
                                        assettt.Name = insertedTag[0].Name;
                                        assettt.Tag_Number__c = insertedTag[0].Name;
                                    } else {
                                        returnMap.put('error','error inserting asset tag');
                                    }
                                } else {
                                    assettt.Receiving__c = RecId;
                                    assettt.Name = AssetTagNum;
                                    assettt.Tag_Number__c = AssetTagNum;
                                    
                                }


                                if(vendor != '')  { 
                                    assettt.Vendor_Account__c =  vendor;
                                }
                                
                                assettt.Quantity = quantity;
        
                                //no PO so manual description
                                if( String.isBlank(rec[0].Purchase_Order__c) ) {
                                    System.debug(manualDesc);
                                    assettt.Description = manualDesc;
                                }

                                if( poline != null && poline.size() > 0 ) {
                                    assettt.Purchase_Order_Line__c = ChosenPoLineId;
                                    assettt.Description = poline[0].Description__c;
                                    assettt.Purchase_Order_Price__c = poline[0].Unit_Price__c;
                                    assettt.Related_Purchase_Order__c = poline[0].Purchase_Order_Detail__c;
                                    assettt.Purchase_Order_Product__c = poline[0].Purchase_Order_Product__c;
            
                                    if(serialNumber != '' ) {
                                        assettt.SerialNumber = serialNumber;
                                    }
            
                                    if(poline[0].Quantity_Received__c != null ) {
                                        poline[0].Quantity_Received__c = poline[0].Quantity_Received__c + quantity;
                                    } else {
                                        poline[0].Quantity_Received__c =  quantity;
                                    }
                                    polinesToUpdate.add(poline[0]);
                                }
                        
                                if( minStockQuantity != null  ) {
                                    assettt.minimum_stock_quantity__c = minStockQuantity;
                                }
                        
                                
                                try {
                                    if( polinesToUpdate != null && polinesToUpdate.size() > 0 ) {

                                       /* if( isPOLocked ) {
                                            Approval.unlock(rec[0].Purchase_Order__c);
                                            update polinesToUpdate;
                                            Approval.unlock(rec[0].Purchase_Order__c);
                                        } else {*/
                                           update polinesToUpdate;
                                        //}
                                        

                                    }
                        
                                    //inser the assettt
                                    insert assettt;
                                    System.debug('Successfully inserted assettt ' + assettt.Id );
                        
                            
                                    Asset[] InseredAssets = [SELECT Id, Name FROM Asset where Id = :assettt.Id  ];
                        
                                    if(InseredAssets != null && InseredAssets.size() > 0 ) {
                                        for( Asset aa : InseredAssets ) {
                                            String prefix = URL.getSalesforceBaseURL().toExternalForm().replace('https://', '').split('\\.')[0];
                                            prefix = prefix.removeEnd('--c');
                                            returnMap.put('name', aa.Name );
                                            returnMap.put('asseturl', 'https://' + prefix.toLowerCase() + '.lightning.force.com/' + assettt.Id );
                                            returnMap.put('quantity', quantity );
                                        }
                                    }

                        
                                } catch (Exception error) {
                                    System.debug( 'The Following excedption occured on ReceiveAssetsControllerLWCr when creating asset: ' + error );

                                    Database.rollback(sp);//rollback if insert error
                                    System.debug( 'rolling back ' + error );
                        
                                    returnMap.put('error', error );
                                    er.create('InventoryGlobalController', '', error.getMessage(), error.getTypeName(), error.getLineNumber(), error.getStackTraceString(), false, true);
                                    throw error;
                                }    
                        
                            }
                        }  

                    } catch (Exception error) {
                        System.debug( 'The Following excedption occured on ReceiveAssetsControllerLWCr when creating asset: ' + error );
            
                        returnMap.put('error', error );
                        er.create('InventoryGlobalController', '', error.getMessage(), error.getTypeName(), error.getLineNumber(), error.getStackTraceString(), false, true);
                        throw error;
                    }  

            } else {
                if( duplicateSerial.size() > 0 ) {
                    returnMap.put('duplicateSerial', duplicateSerial );
                }
            }

            } else {
                //send error list to front end
                if( errors.size() > 0 ) {
                    returnMap.put('errors', errors );
                }

            }
    }

        System.debug(returnMap);
        return returnMap;
    }
    /*---------------------------------------------------*/


    


    @AuraEnabled(cacheable=false)
    public static Map<String,Object> AddToBulkAsset(  String AssetTagNum,  Integer quantity, String recId ) {

        Map<String,Object> returnMap = new Map<String,Object>(); 
        CreateErrorRecord er = new CreateErrorRecord();
        Boolean isAsset = AssetTagNum.contains('EV-');
        List<Asset> AssetsToUpdate = new List<Asset>();
        List<String> errors = new List<String>();

        // Id BulkAssetRecordTypeId = Schema.SObjectType.Asset.getRecordTypeInfosByName().get('Bulk').getRecordTypeId();
        Id BulkAssetRecordTypeId = '0123J000000MJgvQAG';

        List<Asset_Movement_History__c> mvmnthistorys =  new List<Asset_Movement_History__c>();
        
        //error handling
        if( quantity < 1 ) {
            System.debug('Quantity must be greater than 0');
            errors.add('Quantity must be greater than 0.');
        }
        if( !isAsset ) {
            System.debug('Tag Scanned in is not an asset');
            errors.add('Tag Scanned in is not an asset.');
        }



        if(  errors.size() < 1  ) {  


            // Asset[] assets = [SELECT Id, Name, Bulk_Asset__c, Quantity, RecordTypeId, Receiving__c, Receiving__r.Name, Warehouse__c  FROM Asset where Name = :AssetTagNum LIMIT 1 ];
            Asset[] assets = [SELECT Id, Name, Bulk_Asset__c, Quantity, RecordTypeId, Receiving__c, Receiving__r.Name, Warehouse__c  FROM Asset where Name = :AssetTagNum AND Bulk_Asset__c = true LIMIT 1 ];
            if( assets != null && assets.size() > 0  ) {
                for( Asset a : assets ) {
                    System.debug('asset id:'+ a.Id);
                    System.debug('asset name:'+ a.Name);
                    System.debug('asset quantity:'+ a.Quantity);
                    System.debug('asset bulk asset:'+ a.Bulk_Asset__c);
                    // if( a.RecordTypeId == BulkAssetRecordTypeId && a.Quantity > 1 ) {
                    if( a.Bulk_Asset__c == true && a.Quantity > 1 ) {
                        System.debug('asset id:'+ a.Id);
                        System.debug('asset name:'+ a.Name);
                        System.debug('asset quantity:'+ a.Quantity);

                        Decimal newQty;
                        newQty = a.Quantity + quantity;
                        a.Quantity = newQty;
                        a.Receiving__c = recId;
                        AssetsToUpdate.add(a);
                    } else {
                        returnMap.put('error','Asset Entered is not a bulk asset');
                    }

                    Asset_Movement_History__c assetHistoy = new Asset_Movement_History__c();
                    assetHistoy.Asset__c = a.Id;
                    assetHistoy.note__c = quantity + ' of Bulk Asset ' + a.Name + ' Received to ' + a.Receiving__r.Name;
                    assetHistoy.Transfer_Date__c = Date.today();
                    assetHistoy.Starting_Warehouse__c = a.Warehouse__c;
                    assetHistoy.Quantity__c = quantity;
                    mvmnthistorys.add(assetHistoy);

                }
            } else {
                returnMap.put('error','Existing Bulk Asset Not Found');
            }


            if( AssetsToUpdate != null && AssetsToUpdate.size() > 0 ) {

                try {
                    update AssetsToUpdate;
                    System.debug('succefully updated bulk asset');
                    for( Asset a : AssetsToUpdate ) {
                        String prefix = URL.getSalesforceBaseURL().toExternalForm().replace('https://', '').split('\\.')[0];
                        prefix = prefix.removeEnd('--c');
                        returnMap.put('name', a.Name );
                        returnMap.put('asseturl', 'https://' + prefix.toLowerCase() + '.lightning.force.com/' + a.Id );
                        returnMap.put('isBulk', 'true' );
                        returnMap.put('updatedquantity', a.Quantity );
                        returnMap.put('oldquantity', quantity);
                        returnMap.put('message', 'Succefully added to bulk asset' );
                    }

                    if( mvmnthistorys.size() > 0 ) {
                        System.debug('==========================================');
                        System.debug(mvmnthistorys);
                        System.debug('==========================================');
                        insert mvmnthistorys;
                    }
                    
    
                } catch (Exception error) {
                    System.debug( 'The Following excedption occured on ReceiveAssetsControllerLWCr when creating asset: ' + error );
    
                    returnMap.put('error', error );
                    er.create('InventoryGlobalController', '', error.getMessage(), error.getTypeName(), error.getLineNumber(), error.getStackTraceString(), false, true);
                    throw error;
                } 
            }




        } else {
            if( errors.size() > 0 ) {
                returnMap.put('errors', errors );
            }
        }



        System.debug(returnMap);
        return returnMap;
    }





    private static Double assetPOLineCount(Id POLineId){
        Double assetCount = 0;
        List<Asset> countAsset = new List<Asset>();
        countAsset = [
            SELECT id
            FROM Asset 
            WHERE Purchase_Order_Line__c = :POLineId
        ];

        assetCount = countAsset.size();
        return assetCount;
    }

    private static Integer assetSNCount(Id POLineId, String serialNo){
        Integer assetCount = 0;
        List<Asset> countAsset = new List<Asset>();
        serialNo = serialNo.trim();
        //countAsset = [ SELECT id FROM Asset  WHERE Purchase_Order_Line__c = :POLineId and SerialNumber = :serialNo];
        countAsset = [ SELECT id FROM Asset  WHERE SerialNumber = :serialNo];
        assetCount = countAsset.size();
        return assetCount;
    }



    @AuraEnabled(cacheable=false)
    public static Integer systemSNCount(String serialNo) {
        Asset[] a = [SELECT Id, SerialNumber FROM Asset where SerialNumber = :serialNo ];
    
        return a.size();
    }


    /**
     * moveAssetFromSOFTwo();
     * 
     */
    @AuraEnabled(cacheable=false)
    public static Map<String,String> moveAssetFromSOFTwo(  String assetName, String orderID, Integer quantity ) {

 
        Boolean isAsset = assetName.contains('EV-'); 
        System.debug('order = : ' + orderID);
        System.debug('quantity = : ' + quantity);
        System.debug('assetName = : ' + assetName);
        CreateErrorRecord er = new CreateErrorRecord();
        Map<String, String>  returnMap = new Map<String, String>();

        if ( quantity == null ) {
            quantity = 0;
        }

        if( isAsset ) {
            Asset[] assetTagInfo  = [SELECT Id, Name, Warehouse__c,  Warehouse__r.Name, Warehouse_Shelf__c, Quantity, AccountId, minimum_stock_quantity__c, Service_Order_Agreement__c, InstallDate, Order_Name__c, Dimension_4_Market__c, Description  FROM Asset where Name = :assetName LIMIT 1 ];
            returnMap =  moveAssetFromSOFTwoHelper( assetTagInfo, orderID, quantity );
         } else {
            Asset[] cereal = [SELECT Id, Warehouse__c, Warehouse__r.Name,  Name, SerialNumber, Quantity, AccountId, Warehouse_Shelf__c, minimum_stock_quantity__c, Service_Order_Agreement__c, InstallDate, Order_Name__c, Dimension_4_Market__c, Description  FROM Asset where SerialNumber = :assetName LIMIT 1 ];
            returnMap =  moveAssetFromSOFTwoHelper( cereal, orderID, quantity );
         }

         System.debug(returnMap);
         return returnMap;

    }

    /**
     * moveAssetFromSOFTwoHelper();
     * 
     * Helper function for the scan/move asset to sof
     * 
     * @param       assetTagInfo         List<Asset>        list of asset tag names passed in
     * @param       orderID              String             Id of SOF
     * @param       quantity             Integer            Quantity set by user in LWC
     * 
     */
    public static Map<String,String> moveAssetFromSOFTwoHelper( List<Asset> assetTagInfo, String orderID, Integer quantity ) {

        CreateErrorRecord er = new CreateErrorRecord();
        Map<String, String>  returnMap = new Map<String, String>();

        Order[] ord = [SELECT Id, Dimension_4_Market__c, AccountId, OrderNumber FROM Order where Id = :orderID LIMIT 1 ];
        List<Asset> assetsToUpdate = new  List<Asset>();
        //List<Asset> clonedAssetsToInsert = new  List<Asset>();
        List<Asset_Movement_History__c> mvmnthistorys =  new List<Asset_Movement_History__c>();
        Warehouse__c deploymentWarehouse = [SELECT Id FROM Warehouse__c WHERE Name = 'Deployment' limit 1 ];


        System.debug(ord);
        if( assetTagInfo != null && assetTagInfo.size() > 0 ) {
            for(Asset a : assetTagInfo ) {

                if( quantity == 0 ) {
                    quantity = 1; 
                }
        
                
                if( quantity > a.Quantity || a.Quantity == 0 ) {
                    //throw an error
                    returnMap.put('error', 'Quantity  on this asset is empty or you requested more than what is available');
                } else {


                    //need to clone the asset if the asset is being moved with more than 1 quanity
                  /*  if( quantity  > 1  && quantity != a.Quantity ) {
                        System.debug('cloning asset because of quantity ');
                        //update clone
                        Asset cloneAsset = a.clone(false, true, false, false);
                        cloneAsset.Name = a.Name;
                        cloneAsset.Quantity = quantity;
                        //cloneAsset.Warehouse__c= a.Warehouse__c; 
                        cloneAsset.InstallDate = Date.today();
                        cloneAsset.Status = 'In Service';
                        cloneAsset.Service_Order_Agreement__c = orderID;
                        cloneAsset.Cloned_From__c = a.Id;
                        cloneAsset.Warehouse__c = deploymentWarehouse.Id;
                        cloneAsset.Warehouse_Shelf__c = null; 
                        cloneAsset.Description = a.Description;

                        if( ord != null && ord.size() > 0 ) {
                            cloneAsset.Dimension_4_Market__c = ord[0].Dimension_4_Market__c;
                            //cloneAsset.AccountId = ord[0].AccountId;
                        }

                        clonedAssetsToInsert.add(cloneAsset);

                    } else {*/
                    //update origina asset
                    System.debug('updating original asset ');
                        
                        if( ord != null && ord.size() > 0 ) {
                            a.Dimension_4_Market__c = ord[0].Dimension_4_Market__c;
                           // a.AccountId = ord[0].AccountId;
                        }
                    
                        a.Service_Order_Agreement__c = orderID;
                        a.InstallDate = Date.today();
                        a.Status = 'In Service';
                        


                   // }

                    //update the asset or old asset quantity
                    Decimal newQty;
                    if(a.Quantity != null ) {
                        newQty = a.Quantity - quantity;
                        a.Quantity = newQty;
                    }

                    //remove from shelf if 0 left
                    if(  newQty == 0 ) {
                        a.Warehouse__c = deploymentWarehouse.Id;
                        a.Warehouse_Shelf__c = null; 
                    }
                    
                    assetsToUpdate.add(a);
                    returnMap.put('success', 'Moved asset  to SOF');
                    returnMap.put('name',  a.Name ); 
                    returnMap.put('message', 'Asset ' + a.Name + ' assigned to SOF ' + a.Order_Name__c + ''); 
                    returnMap.put('isMoveQuantity', 'false');
                    returnMap.put('to', '' + a.Order_Name__c + '');

                }
                

            }

           try {
                update assetsToUpdate;

                //insert clonedAssetsToInsert;

                ////update  movemnt historys for cloned assets
              /*  if(clonedAssetsToInsert != null && clonedAssetsToInsert.size() > 0 ) {
                    Asset[] InsertedClonedAssets = [SELECT Id, Name, Warehouse__r.Name, Warehouse__c, Service_Order_Agreement__c, Order_Name__c, Quantity FROM Asset where Id in :clonedAssetsToInsert ];
                    if(InsertedClonedAssets != null && InsertedClonedAssets.size() > 0 ) {
                        for(Asset a :InsertedClonedAssets ) {
                            Asset_Movement_History__c assetHistoyOne = new Asset_Movement_History__c();
                            assetHistoyOne.Asset__c = a.Id;
                            assetHistoyOne.Transfer_Date__c = Date.today();
                            assetHistoyOne.source__c = a.Warehouse__r.Name;
                            assetHistoyOne.Destination__c = a.Order_Name__c;
                            assetHistoyOne.Starting_Warehouse__c = a.Warehouse__c;
                            mvmnthistorys.add(assetHistoyOne);
                            returnMap.put('message', 'Asset ' + a.Name + ' assigned to SOF ' + a.Order_Name__c + ''); 
                            returnMap.put('name',  a.Name ); 
                            returnMap.put('isMoveQuantity', 'true');
                            returnMap.put('quantity', '' + a.Quantity + '');
                            returnMap.put('to', '' + a.Order_Name__c + '');
                        }
                    }
                }

                if(assetsToUpdate != null && assetsToUpdate.size() > 0 ) {
                    Asset[] InsertedClonedAssets = [SELECT Id, Name, Warehouse__r.Name, Warehouse__c, Service_Order_Agreement__c, Order_Name__c, Quantity FROM Asset where Id in :assetsToUpdate ];
                    if(InsertedClonedAssets != null && InsertedClonedAssets.size() > 0 ) {
                        for(Asset a :InsertedClonedAssets ) {
                            
                            Asset_Movement_History__c assetHistoyOne = new Asset_Movement_History__c();
                            assetHistoyOne.Asset__c = a.Id;
                            assetHistoyOne.Transfer_Date__c = Date.today();
                            assetHistoyOne.source__c = a.Warehouse__r.Name;
                            assetHistoyOne.Destination__c = a.Order_Name__c;
                            assetHistoyOne.Starting_Warehouse__c = a.Warehouse__c;
                            mvmnthistorys.add(assetHistoyOne);

                        }
                    }
                }*/

                //insert movemnt historys
                if( mvmnthistorys.size() > 0 ) {
                    System.debug('==========================================');
                    System.debug(mvmnthistorys);
                    System.debug('==========================================');
                    insert mvmnthistorys;
                }



                
            } catch (Exception e) {
                System.debug( 'The Following excedption occured on inventoryScanToLocation when adding asset to SOF: ' + e );
                er.create('InventoryGlobalController', '', e.getMessage(), e.getTypeName(), e.getLineNumber(), e.getStackTraceString(), false, true);
                returnMap.put('error', '' + e + '');
                throw e;
            }


        } else {
            returnMap.put('error', 'Asset Not Found');
        }

        System.debug(returnMap);
        return returnMap;
    }


    public Warehouse__c warehouse { get; set; }
    public String warehouseObId { get; set; }
    public String qrCode {get; set; }

    //visual force page qr_code
    public InventoryGlobalController(ApexPages.StandardController controller) {
        warehouseObId = controller.getId();

        System.debug(warehouseObId);

        if (warehouseObId != null && warehouseObId != '') {

            warehouse = [select id  from Warehouse__c where id = :warehouseObId];
            Warehouse_Shelf__c[] location  = [select Id, Name__c, Warehouse__c, Warehouse_Name__c, Shelf_Tag_Name__c, QR_Code__c FROM Warehouse_Shelf__c where Warehouse__c = :warehouseObId  LIMIT 1];

            if( location != null && location.size() > 0 ) {
                qrCode = location[0].QR_Code__c;
            }

            


        } else {
            warehouse = new Warehouse__c();
        }
    }



























































    @AuraEnabled(cacheable=true)
    global static String getOrgBaseURL(  ) {
        String prefix = URL.getSalesforceBaseURL().toExternalForm().replace('https://', '').split('\\.')[0];
        prefix = prefix.removeEnd('--c');
        return 'https://' + prefix.toLowerCase() + '.lightning.force.com';

    } 
















/**
 * 
MMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMM
MMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMWNX0kdoc,'...              ......''''''''''''''.....              ....';loxOKXWMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMM
MMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMWNX0koc;'.          ...,;:ccloodxkO0KKXXXXXXXXXXXXXXXKK00Okdooolc:;;'..          ..,:lxOKXWWMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMM
MMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMNXOdl;...       ..,:coxk0KXXNNWWMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMWWWNNXK0Okdlc;'..       ..,:ok0NWMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMM
MMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMWNKkl:'.       .,:cox0KNWWWMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMWWWNXKkdlc;'.       .,cdOKNWMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMM
MMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMWN0xl,.      .';ldOKXNWMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMWNX0ko:,..     ..:oOXWMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMM
MMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMWKko;.     ..;cdOXNWMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMWWNKko:'.     .':d0XWMMMMMMMMMMMMMMMMMMMMMMMMMMMMMM
MMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMN0xc'.     .;okKNWMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMWX0xc,.     .,oOXWMMMMMMMMMMMMMMMMMMMMMMMMMMM
MMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMNKx:.     .;lxKNWMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMWN0d:'.    .'lOXWMMMMMMMMMMMMMMMMMMMMMMMM
MMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMWXkc.     .:d0NWMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMWKkl,.    .,o0NMMMMMMMMMMMMMMMMMMMMMM
MMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMN0o,.    .cxKWWMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMWXOo;.    .:xKWMMMMMMMMMMMMMMMMMMM
MMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMWXx:.    .;dKNMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMWXOl'.   .'o0NMMMMMMMMMMMMMMMMM
MMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMWXx,.   .,o0NWMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMWXkc.    .cONMMMMMMMMMMMMMMM
MMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMWKd,.   .;xKWMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMN0l'    .cONMMMMMMMMMMMMM
MMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMNx,    .:kNWMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMWKo'    .c0WMMMMMMMMMMM
MMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMNOc.   .:kNWMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMWKo'    'dXWMMMMMMMMM
MMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMWKo.   .;xNMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMWKl.   .;kNMMMMMMMM
MMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMNO;.   'dXWMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMNOc.   .oXWMMMMMM
MMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMWNXXXXXXXXXXXXXXNNXXXXXXXXXXNNNNNNNNNNNNNNNNNWMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMXx'    :0WMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMXx'   .:0WMMMMM
MMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMWXOkkd:'''.....''''''''''''''''''',,,,,,,,,,;;;:::oO000KNWWWMMWXKWMMMMMMMMMMMMMMMMMMMMMMMMMMKl.   .oKMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMWO:.   ,kNMMMM
MMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMWNXXXklllcc,.                                .............',;::cclxkdokXNOkXWWWMWWMMMMMMMMMMMMMMMMMMWKl.   'kNMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMWKl.   'xNMMM
MMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMWKkxd:''..                                          ..........',,;::cllllccooc:lx0NWNNMMMMMMMMMMMMMMMMMWKc.   ,OWMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMXo.   'xNMM
MMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMWNXOdlc'.                                                     ......'',;:ccccllccc:;,'.;lodOXXNWMMMMMMMMMMMMMKl.   ,OWMMMMMMMMMMXkolcccccd0WMMMMMMMMW0x0WMMMMMMMMMWX0xdooxOKNMWXOONMMMMMNOx0NKxddlcccclkXMMMMMMMMMMMMWN0xolokXN0kKWMMMMMWXO0NMMMMNKOxooox0XWMMMMMNKOxoodk0XWMMMMMMMMMMMMMMXo.   'kNM
MMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMW0ko,..                                                          ......',;;:cccccccc::;,'......'';ok0WMMMMMMMMMNd.   ,OWMMMMMMMMMMWKd:'. .,;l0WMMMMMMMMXo'lXWMMMMMMWKo,';;;;;,'l0N0:,xNMMMNd',kXd..,;,,,,:xXMMMMMMMMMMWXx:,,;,.;k0:'dNMMMMMNd'cKWMNOc',;;;;;,,dXMMNOc,,;;;;;,,dXMMMMMMMMMMMMMWXo.   ,OW
MMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMWNOd:.                                                               ......',;:cclllllcc::;,'.....    ...clkXXWMMMWk,   'xNMMMMMMMMMMMMMWN0;.oXWWMMMMMMMMMMXl.lXMMMMMMWk;.:kXWWWNO;.:KXl.;0MMNx,'xNNd.,xKKKKXXWMMMMMMMMMMWOc';xXWN00X0,.oKXXXXXO:.lXWXd'.l0NWWWXd'.oNXd'.l0NWWWXd'.oNMMMMMMMMMMMMMWKc.  .lK
MMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMWKkd;.                                                                 .......',;:clllllllcc::;,'....         .:dkXMWXc   .oXMMMMMMMMMMMMMMMW0;'dNMMMMMMMMMMMMXl.lXMMMMMW0;.lKMMMMMMXl.,0W0:.oNWO;'dXMNo. .....'l0WMMMMMMMMWO;.lKWMMMMMM0, ........ .oXNx''xNMMMMMM0;.cKx''xNMMMMMM0;.cXMMMMMMMMMMMMMMWO,   .x
MMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMWNKd'                                                                    ........',;::ccccllllcc::;,'....         ...,lol'   ;0WMMMMMMMMMMMMMMMW0;'xNMMMMMMMMMMMMKc.oXMMMMMNk''kWMMMMMW0;.:KMWx.,kOc'lXMMXl.'coooodkXMMMMMMMMMXl.:KWMMMMMMM0,.;loooooc..oNXl.:KWMMMMMWx..dKl.:KWMMMMMWx..dNMMMMMMMMMMMMMMMNd.  .:
MMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMNx;.                                                                            ...........'',,;;:::;,,.....           'l;.   lNMMMMMMMMMMMMMMMMW0;'xNMMMMMMMMMMMWK:.oNMMMMMWO,.l0WWMWNO:.:0WMMXl.',.cKWMMXl.lXMMMMMMMMMMMMMMMMXl.;0WMWNX0XWO,,OWMMMMMKc.oNNd.'dXWMMWXx,.lXNd.'dXWMMWXx,.lXMMMMMMMMMMMMMMMMW0'   .
MMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMWOlc;.                                                                                        .........,;;,,'....          ,d,   'kWMMMMMMMMMMMMMMNOl;..':cxXWMMMMMMMW0:.':ccccoOXk;.,:ccc;,,oKWMMMW0; .:0WMMMNd.'coolllxXMMMMMMMMMWO:',:cc:;:kXO,;OWMMMMMXl'oXWXd'.;ccc:;';xXMMXd'.;:cc:;';xXMMMMMMMMMMMMMMMMMMX:    
MMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMNOo'                                                                                                     ............        ,l.   :KWMMMMMMMMMMMMMMXx:,,,,,;oKWMMMMMMMMNOl;,,,,,:xNWNOxoc:cokKWMMMMMMW0ddKWMMMMMXkoc:;;:lxXMMMMMMMMMMWXOoc:ldkKNWKxkXMMMMMMNOdONMMWXOdl::ldOXWMMMMWXOdl::ldOXWMMMMMMMMMMMMMMMMMMMNx.   
MMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMWXko;.                                                                                                             .......       ,c.  .lXMMMMMMMMMMMMMMMMWWWWWWWWWMMMMMMMMMMMMWWWWWWWWWMMMMMWWWWMMMMMMMMMMMMMWMMMMMMMMMWWWWWWWMMMMMMMMMMMMMMMMWWWMMMMMMMMMMMMMMMMMWMMMMMMMMWWWWMMMMMMMMMMMMWWWWMMMMMMMMMMMMMMMMMMMMMMMWO,   
MMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMWKo,.                                                                                                                          ....'c.  .oXMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMW0;   
MMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMWKd'                                                                                                                             ....'c.  .oXMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMW0;   
MMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMM0;                                                                                                    .                              ,c.  .lKMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMWk,   
MMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMWNXk;.                                                                                               ........                            ,o'   ;OWMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMNo.   
MMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMKc'.                                                                        .............      .................                         ,x:   .dWMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMK;   .
MMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMWKd;.                                                                      .........................''',,,,,,,'''............ ..            .;;.   cXMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMWNNNNWWMWWWMMMMMMMWWWMMMMMMWWNNNNWWMMMMMMMMWWNNNNWWMMMMMMMMWWNNNWWMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMWO'   '
MMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMNx,                                                                       .....'''''',,,'''....',,;;::ccccccccc::;;;,'.............           .:,   'kNMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMWXkl;,,;oKKdoKWMMMMMNklkNMMMN0dc;,,;cd0NMMMMN0dc;,,;cd0NMMMMNOdc;,;lkXMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMXl.  .l
MMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMWNk;.                                                                      ...''',,,,,;;;:;;,,,,;:ccllllloolooooooolllc:,''......''....          .lc.   ;KMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMNx;';loc;c0O;,OWMMMMMO' lNMW0l,,clooo:''oXMW0l,,clooo:''oXMWOc';looodONMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMWx.   ,O
MMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMXl.                                                                       ..',,,,;;;;::::::::::clllooooooooddddddddddolc:;;;;;;;;;,'''...         .;;   .oXMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMWKl.,xXWMWNNNO,.lxkkkkkc. oWNk,.l0WMMMMNd.,OXO,.l0WMMMMNd.,OWNl..cxkO0XNMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMWO;   .dN
MMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMWOl:.                                                                       ..,,;;;::::::cccccclllooooooooddddddxxxxxxxdddollllccccc:;;;,,'...    .   .,.   .dXMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMKc.;OWMMMMMMWO, .......  .xWK:.cKMMMMMMWk',kO:.cKMMMMMMWk',kWW0l:,...',ckNMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMW0:    cKM
MMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMNx'                                                                         .';;::::ccccccclllllloooooooooddddddxxxxxxxxxxddddddooooollllcc:;'...  ..   'c'   .dNMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMWO'.dNMMMMMMMNk''d000000l.'kW0,.oXMMMMMW0:.:KO,.oXMMMMMW0:.:KNXXNNXK00k:..kWMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMW0:    :0WM
MMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMNk'                                                                         .';::ccccccccccllllooooooodddddddddxxxxxxxxxxxxxxxxxxxxdddddddoolc:;,'.      .;;.   .oXMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMM0;.:OXXKOkkKXx.,0MMMMMWx..xWXl.'o0KXXKx;.:OWXl.'o0XXXKx;.:OWKc;d0XXX0k:.'kWMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMW0:.   :0WMM
MMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMW0c.                                                                         .';:cloolcccccclllloooooddddddddddddxxxxxxxxxxkkkxxxxxxxxxxxxddddoolcc;'...     ...   .l0WMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMW0c'''',;:dKXd,cKMMMMMMO'.dWMNkc;,,'',,:xXWMMNkc;,''',,:xXWMNx:,,'',,;;lONMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMNk,   .:0WMMM
MMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMNx'                                                                          ..,:odxdlc:cccclllllooooddddddddddddxxxxxxxkkkkkkkkkkkkkkxxxxxxxxddooool:,..      .,.    ;kNMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMNKOxxOKNWMWX0KWMMMMMMN00XMMMMWX0kxkOKNWMMMMMMWX0kxkOKNWMMMMWN0OxxO0KNWMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMXo.   .cKWMMMM
MMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMNx.                                                                           .';ldkxoc::cccclllloooooddddddddddddxxxxxxkkkkkkkkkkkkkkkkkxxxxxxxdddddolc;'.      .:,.   .oKWMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMW0:.   .dXMMMMMM
MMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMXo.                                                                           ..';lddoc:::ccccllllloooooddddddddddxxxxxxkkkkkkkkkkkOkkkkkkkxxxxxxxdddddolc;.       ..,.   .;kNMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMWKo.   .;OWMMMMMMM
MMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMWd.                                                                           ...';coolc::ccccclllloooooooodddddddxxxxxxkkkkkkOOOOOOOOOkkkkkkkxxxxxdddddoolc,.        ,l;.   .:ONMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMXx,    .oKWMMMMMMMM
MMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMNd'                                                                          .....',:llcc:::cccllllllooooooooodddddxxxxxkkkkkOOOOOOOOOOOOOkkkkkkkxxxxddddoooc;.         .;;.    .cONMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMWXx;.   .cONMMMMMMMMMM
MMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMNx.                                                                           ....',;:ccc:::ccccclllllooooooodddddddxxxxxkkkOOOOOOOOOOOOOOOOkkkkkkxxxxxddddooc;.           .',.    .cONMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMWXx,    .;kNMMMMMMMMMMMM
MMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMWx.                                                                             ...',;::::::::cccllllllooooooddddddddxxkkkkkkOOOOOOOOOOOOOOOkkkkkkkkxxxxdddoolc,.             .',.    .:xXWMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMN0o,    .;xXWMMMMMMMMMMMMM
MMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMWx.                                                                             ...',;;;:;;::::::ccccllllooooodddddddxxxkkkkkkOOOOOOOOOOOOOOOkkkkkkkkxxxxdddolc:'.               .',.    .'o0NMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMWXkc.    .:kXWMMMMMMMMMMMMMMM
MMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMNk,                                                                              ..',;;;:;;;;,,,,;;::cccllloooddddddddxxkkkkkkkkOOOOOOOkOOOOkkkkkkkkkkkxxxddoolc;..                 .,:,.    .:OWMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMWXOl'.   .'cONMMMMMMMMMMMMMMMMMM
MMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMK:                                                                              ..',,;;;,'.......'',,;;:ccllloooddddddxxkxxkkkkkkkkkOOOOOkkkkkkkkkkkkkkxxxdoolc;,..                   .;l:.   'xWMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMWXkl,.    .:xKWMMMMMMMMMMMMMMMMMMMM
MMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMXd.                                                                              ..,,,,'...      .....',,;::ccllooddddxxxxxxxxkkkkkkkkkOOOkkkkkkkkkkkkkkxxddool:,...             ..     .,c.   cKWMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMWNKxc'.    .,oONWMMMMMMMMMMMMMMMMMMMMMM
MMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMO'                                                                              ..,;;'...           ......',;;:loooddddxxxxxxxkkkkkkkkkkkkkkkkkkkkkxxxxxxddoooc;'..             ...     ;o,   .dNMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMNKOo;.     .,lOXWMMMMMMMMMMMMMMMMMMMMMMMMM
MMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMWO;.                                                                              .';;,'......             ...'',:looodddxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxddooooc,....           .....    ;c.   ;0MMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMWWNKko;..    ..:oONWMMMMMMMMMMMMMMMMMMMMMMMMMMMM
MMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMWo.                                                                  .....       ..,;,'..............       ....';:lloodddxxxxddooooolllcccllooooooodddxxdddoool:'....           .....  ..'.   ,OWMMMMMMMMMMMMMMMWX0kkOXNWMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMWNKkdc,.      .,ckKNWMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMM
MMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMNx'                                                                  .'''..       .,;;,'''...........         ....,;cclooooddddolc::;,,,,'''',,,;;;;;:clldddooool:,.....         .........;'   .dNMMMMMMMMMMWNX0kl:,.  .';cdk0XNWWMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMWWNNK0xo:,.      ..,cd0NWMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMM
MMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMK;                                                                  .'.....      .';;;,'''...  ...    .        ...',:cclllooddol:;''.................'',,:cooooolc:'.....       ........';.   .oXMMMMMMMWX0xo:'.             .';coxkOKNNWMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMWNXKOxdl:,..       .';lkKNWMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMM
MMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMWO,                                                                 ....  .      .';::;,,'..........  .......    ...';:cloooooolc;'........................';cloool:,.....       .......''.   .oXMMMWNKkoc,.       ..;lol;'..        ..,;codxk0KKXNNNWWWWWWMMMMMMMMMMMMMMMMMMWWWWWWNNXXK0Okxol:;'.         ..,cok0XWWMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMM
MMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMM0;.                                                                 .........   ..,:::;;,,,,,,'''''......,,'....  ..',:lodddddol:;,''''........''''''''...''';cloolc,.....      .....,:l,.   'dXNKkdl;.      ..'.',..:XMWNX0kdc;'...         .....,;:ccllooddxxxxxxxxxxxxxdddoollc::;'....          ..',:oxOKXWMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMM
MMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMk.                                                                  ..........  .';::::;;;;;;,,,,;;;,,,,;,,'........';cldxxxxdolc:;,'''........',;:cccc::;;;,;clool:,.... .     .....;c'    'oxo:.       ..,cc,,.    ;KMMMMMMMWWNK0kdlc;'...                                               ...',:coxO0XNWWMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMM
MMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMk.                                                                  ..........  .,;;::::::::::::;::::::::;;,''......,:lodxkkxxdocc:;,'.....  ......';:lllllc;,:lool:'.....      ...,,..     ...     ..'';,....       ;KMMMMMMMMMMMMMMWWNXXKOkxdol:;,,''..........................',,,;cldxkO0KXNWWMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMM
MMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMk.                                                                   .......   ..,;;::::ccclllcccccccccc::;;,'''...';codxkkkxxdooooc::,,:;'. ....,,..',:clooc::lool:'.....      .,;,.           ..;l:,'.             .lKMMMMMMMMMMMMMMMMMMMMMMMWWWWWNNXKK000OOOOOOOOOOOOOOO000KKXNNWWWWWMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMM
MMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMk.                                                                   .......  ..',;:cccccclllllllllllllc:::;;;,,,'';:lodxkkkxxdddddolc:;;;,'...';cc:'',;ccodooooool:'.....    ..;,.        ..'',.....                 .kMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMM
MMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMk.                                                                    .....  ..'',;:cccccllllllllllllllcccc:::;;;;;:clodxkkkxxxxdddollcccc::ccllooooolcclldxxxddddo:'.....  ..,,.       .,:;,,.                       .kMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMM
MMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMk.                                                                    ...... ..'',:cccccclllloooooollllllccc::;;;:::cldxxkkkxxxxxxddoollllloooddddddddddddxxxxxxddo:'.  ..,''..    .,;,.....                          .kMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMM
MMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMk.                                                                     .........,,;:cccccclllooooooooollllc:::::::cccodxxkkxxxxxxxxxxxddoooodddddddddxxxxxxxxxxddol;....,cc,.  .';;;:,....                            .kMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMM
MMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMk.                                                                     ....''...,,;;::::cclllooooooolllcc::;;;;;:ccclodxxkxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxddoc,..';,...,;:;:c;.......                            .kMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMM
MMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMk.                                                                      ..','..',,,,;;;::ccllllloooollc;;;;;,,,:cccllodxxxxxxxxxxxxxxxxxxxxxxxxxxxkkkkxxxxxxxxddoolc:,;,;clddl::c:'......                             .kMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMM
MMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMk.                                                                       .''...'''',,,;;::cclllllllllc;'',;:;,;ccclloddxxxxxddddxxxxxxxxxxxxxxxkkkkkkkkkxxxxxdxxxdolc:loxkxxolclc;........                            .kMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMM
MMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMk.                                                                        .....''''',,,;;::ccclllllc:;'.',;:;;:cccloddxkkxxxddddddddddxxxxxxxkkkkkkkkkkxxxxxxxkkkdlol::ldxxdoool:.........                            .kMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMM
MMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMk.                                                                          ...'''''''',,;;::ccccc::;,....',,;;::clodxkkkxxxdddddddoooodddxxkkkOOkkkkkxxxkOKK0kdooooolcloxxdodo:'.........                            .kMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMM
MMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMk.                                                                            .''''....',;;;;;;;;;,,''........',:clodxxkxxxdddxxxdoollllllodxkkkkkkkkkxxxkOOOkdooloddolodxxddl:'..........                            .kMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMM
MMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMk.                                                                            .'..''''',,,,''',,'''''......  ...':cloodddddddddddoooollccllodxxxkkkxxxxxxxddddooolldxddddddoc,.............                           .kMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMM
MMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMk.                                                                            ......'',;,,'..'''''''.........  ..',;:clllcc::cclooddoollccclodxxxxxxxxxxdddddooolloxxxdddol;'..............                           .kMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMM
MMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMk.                                                                            .......';cc;,........................',;;;::::ccllooddoolcc::clodddddddddddddddollloxxxddol:,................                           .kMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMM
MMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMk.                                                                             ......';ccc;,'..........'''''''''',,,,,;:cllooooooddddolc::;:clloooddddddoddoooollodxddlc,'.................                           .kMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMM
MMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMk.                                                                             .......,:cc:;;,''..........',,,;;::ccccclloooooodddoodoolc:;,;:lloooodddddddooollloddl:,....................                           .kMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMM
MMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMk.                                                                             ........,:c:;;;,,''........'''',;;::clllooooodddddooooolllc:;,,;clodooddooooooolcclc:,......................                          .oXMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMM
MMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMk.                                                                              ........,;;;;;,,'''''''',,,;;;;:::::clllllllllllllccllcc:;,,,',:looddoooooooolc;''..........................                         ;KMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMM
MMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMO'                                                                              .........',,,''''''''''',,;:cccllllloddddoooolcccc:cccccc:;,,;;clooooooooooolc:'............................                         ;KMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMM
MMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMWk'                                                                              .........''''...''',,,,,,,,;::cclllooddddddoooooooooooool:::ccloooolllooolll:,..............................                        ;KMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMM
MMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMK;                                                                              ...........''...'',,;;;;;;;;;;;::cccloooooddddddddddddoolcclllolllllllllllc:,'..............................                       ,kNMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMM
MMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMNx'                                                                            ..''........''''.'',,;;;::::c:::::ccclooddddddddddddddooollllllllllllllllcll:'................................                     .oWMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMM
MMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMNl.                                                                   ........,'.'''......''''''',,,;;::::ccllclloooddddxxdxxdddddddoolllllllllllllllccloxd:'..................................                  .dWMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMM
MMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMNo.                                                        ........'',,,,,;;,,'...''.......''''''',,;;:::ccclloooooodddddddddddoooolllccllllllllllccclloxOkl,............................    ..                 .lKWMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMM
MMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMW0:.                                      ...........''',,;;::ccccccc:;;;::;,.....'''.......'''''',,,,;;:cccllloooooooddooddddooolllllllllllllllllllldxkOOkd:'......................                            .kMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMM
MMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMM0;                                ....',;:::cccccccccclllllllllc:;,'',::;,......''..........''''',,,;;:clllolloolooooooooodooooooooolllllllllllllodkOO0OOko;.....................                            .:KMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMM
MMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMWO,                           ..';:ccllloooooolllllllllllllc:;,'..',:c:;,'......'...''.........''',,;:ccccllllllooooooolooooooolllollllllllllllldkOOO0OOOOxc'....................                            ;KMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMM
MMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMK;                       ..';:clooooolloollllccccclllccc:;,'....,:ccc;,'.... ..'...'''.........'',,;;::::::cllllooooollooooooollllllllllccllloxOO000OOOO0Od;....................                           'xNMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMM
MMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMNk,                  ..',:cllooolllllccccc:::::::::::::;,'....';clcc:;,'....  .....''''.........'',,;;:::;;:cclllllllllloooollcclllllccllllodkO00OO0OO0000Ol'.....................                       .;kWMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMM
MMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMWo               ..';clloooollllllccc::;;;;;;;;;;;;;;,'....';clllcc:;,,'...  .....''''............',,;;;,,;:cccclllllllllllcccccccccllllldkO0000OOOO00000Od:.......................                     .kWMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMM
MMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMW0:.           ..,clllolloollllllcc::;;,,;;;,,,,,;;;,'....,:lllllc:;;,,''..  .....'''''.............'''''',,;:::ccccccccccc::cccccllllldxOO00000OOOO000000Oxc,......................                    ,OMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMM
MMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMK:.        ..;cloollllllllllccc::;;;;,;;;,,,,;;;;,'...,:llooollcc::;,,''.   .....''''..................'''',;;;;:::::::::::ccccllcldkO000000000OO00000000Oko;.......................                .l0WMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMM
MMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMXl.     .';clllllllllllllccc::;;;;;;;;;,,;;::;,''..',;;;:clllllcc::;;,'.   ......'''................''''',,,,;;;;;;;;:::ccclcclodkOOO0000000000000000000OOkdc,.......................             .lNMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMM
MMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMWXl.  .';cllllllllllllcccc::::;;;;;;;;;;;:::;,'....'......';cllllc::;,'.   ......''''......'''''''''',,,;;;;;;;;;;;::::ccccloodxkkkOOO0000000000000KK0000Oxxxd:'......................            ,kWMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMM
MMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMWXo'.,cllllllcccccccccc::::::::;;;;;;;::::;,'.............':ooollcc:;'.   .......''''''''',,,,,,,,,;;;;;;;:::::::::::::cloxkkkkOOOOOOOOO0000000000KKKKK00kddkko:'.....................          .kWMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMM
MMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMKoccllllllcccccccccccc::::::::::;;;::::;,''..............;looollc:;,.   ........''''''',,;;;;;;;;;;;;;:::::::::::::cldxOOO00OOO0OO0000OO0000000000KKK00OkddkOxo;........................   ..;c0MMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMM
MMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMWKxlllllccccclllccccc:::::::::;;:::::;,,''...''.........'coooolc::,..  .........''''',,;;;;,,,,,,;,;;::::::;;;;:ldxkO000000OOO0OO0000OOO000O000000000OOOdcokkkxl;.........................cdkXMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMM
MMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMWWWW0ollccccccccccccccc::::::::;;::::;;,,,'''',''..........,loolllc:;,.. ............'',,;;;;;,,,;;;;;;;;;;;,,;codkO000KK0000OOOOOOOOOOOOOO00O0000000OOkOOkdcokkOkxl,......................;ONKKWMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMM
MMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMNNWMWXOoccccccccccccccc:::::::;::::::;;,,,',,,,'....'''.....;odoolccc:,. .............'',,;;;;;;;;;;::;;;;,,;coxkkO0KKKKKK00OOOOOOOOOOOOOOOOOOO00000OkkkOOOkolokOOOkxc,...................;xKNWNWMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMM
MMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMWXKXkllcccccccccccccc:::::;::::::;;;,,,,;;,,'''',,'.......;loollllc;. ....'.........',,,;;;;;;;;;;;,,;;:lodxxkOO00KKKKKK0000OOOOOOOOO00OOO000000OkkkO000OkoldkOOOOkdc,................:OWWWWMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMM
MMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMWXkocccccccccccccc::::::cc:::;;;,;;;;;,,',;;;,.........,cloooll:.......'....'''',,,,,,,,,,,,,,,;clodxxkkkkOO000KKKKKKKKK0000OOOOOO00000O000OxxkO0K00OOxooxkOOOOOkdc,...........;ox0WMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMM
MMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMWKl;cccllcccccc:::::cccc:::;;;::::;;;;;::;,'.........',:odoooc,......''....'''',,,,,,,,''',;codxkOOOOOOO000000KKKKKKKKKKK00000OOO000000OkxxO00000OOOOdldkOOOOOOOko:,.........:KMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMM
MMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMWKkl::clllcccc::::ccccc:::;;;:c::::;::c:;,''........,'.':odddoc'.....'''.......'''''''',,:ldxxkO00000OOOOOO0000KKKKKKKKKKKK00000000000OkxxkOO000OO000xooxkOOOOOOOOko:,....'':ONMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMM
MMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMWWWNOoccllccc::::ccccc::;;;:cccc:::ccc:;,,''''.....,,'..':oxxdd:.....'''............';:coxxxxO00KK00OOkkkkkkkOO00KKKKKKKKKKKKK0000000OkxkOOO000O0000OkxodkkOOOOOOOOkxdc'.;kKNMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMM
MMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMN0dcccc:::cccccc::;;:ccccccccccc::;;,,''''...,;,'....:oxxdl,....''''...'..'',::coddolc::cdk0000OOkkkkxkkkkOO00KKKKKKKKKKKKKK00OkxdkOO0000000000OkxodxkOOOOOOOOOOOOkllOWMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMM
MMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMN0dc:::cccccc::;:cclccccccccc:::;;,,,,,''',;;,'.....;odxdc'...''''',cccccloooooc::;''..',;ldk000000OOOOOOOO0000KKKKKKKKKKKKOxodxkkkOOO000OO0OOkdodxOO00OOOOOO0KXWWNNWMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMM
MMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMN0o:cllccc:;:ccllllllllcccc::::;;;,,,,,,;:;;,'.....;oddo;....''',:ccccccllccc:;;,'''......,lxO0000000OOOO0000KKKKKKKKKKK0xxxkOOkOOOO00OkO00OkxddxkO00OOO00XNXNWMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMM
MMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMW0xooc:c::::clllllllllccccccc::;;;;;;,;:c::;;,''...':oddl,...'';clooolloollcc:;;,,,''.......',cdO00000OOOOO000KKKKKKKKKOxdkkOOkkO0000000OO00OkddxkkOO000XNWK0NMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMM
MMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMNO0WNOl:;:cllllllcccccccccccc:::::::;::cccc::;;,''.',:ldl;'.''';oxxdddddollc:::;;;,,'''........':oxOOOOkOOkOO000KKKKKKOxdxkkkxxk00OOOOOOO000OkxdxkkOOxd0WMMWWMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMM
MMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMNOl::lccclllcccccccccc:::::::::ccccllcc::;,''''';llc,.'',cdxxxdoollccccc::;;;,,;;,,,''......,cdkOOOkkkkOOO00KKKOxdxkOOkxkO00OOOkOOOO0OkkxdxkOkood0WMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMM
MMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMNkolccccccccclllccc::::::ccccccllllllc::;,,,,'';c:,..':odoooolllccllccc:;;;::cc:;;;,,'.......;lxkOOkkkkkO000OodkkkkkxxkO00OOOkOOO0OkkkxxxdOKKNWMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMM
MMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMNX0d:;ccccccllccc::::::ccccccllollllcc::;;;;,';;,.';looollllllllllc:::ccccclcc::::,''''''....,:okOOOkkkOOxooxkkxdddxO00000OkxkOOxkOOx0XXWMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMM
MMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMW0dlc:cccccc:::ccccllllclllooooolllcc:;::;,',;;cllooooolooollolc:cllllllollc:::;,,;;;;;;;,'.';ldkOOOOdcldOOkxddxk000000OxxxxkkxOKKNMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMM
MMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMWXKkodc:cc::ccclllllllllooooooolllcc::;;;;:lloooooooooooollccccodddooooollc:::::cclcclccc:,'.,:odxdlcokOOkdodxO00000OkxdddO0OKWMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMM
MMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMWNWMXOxl:cccllllllllllllllloooolllccccccllodddddoooddoooolcclooddxddoooolclclllloooooddddoc::cccloolldxkkxodxk0K0OOOOkxdx0WMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMM
MMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMWWWMWNWNK0xddclllllllllllllllllllccllooddddddxddddoodooolcloddddxxddooolloooddddddddxkkkxxdddxxdddloxxkkxoodkk000kdOXNNNNMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMM
MMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMWWKOOdcllclllllccccccc::cldddxkxddoddddddddolcccodxxxdxxdoooooodddddxdodxxxkkkkxddxkxdolldkkxdoloddx0XXKOXMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMM
MMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMNNWMNX0dlddl:ccccc::;;coddddxxxxddddodddoolcccodxkkxxddoooddoodxddddoodxxxxxxkxddxkxolcokOkdlcddllxXMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMM
MMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMWNNNOkxccll::;:oxkxddxxxxxddddddollc:codxxkxdoodddddxddxxxddoloxkkxxkkkkxxxkdlcoxk000kOXKKNWMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMM
MMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMNK0Kk:c:,:oxxddddxxxdddddolcc:codddxdoooodddodddddxxoooodkOkkxxkkkxdxOOkkKO0NWWMWNWMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMM
MMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMN0X0ddodd:,;cloolooolccc:cldxxdddodddddoloddddxdollodkOOkkxOXXKKOkXWMMMMMMMMWNWMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMM
MMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMWNWNNXOl:ccccclxkxxxxxxkO0OOOOOO0OkkOkkO00OOOkkkk0XNWNNNWMMMMNXNMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMM
MMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMWWWWWWWWWWWWWWWMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMM
MMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMM




 */

}