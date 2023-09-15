/**
 * @description       : 
 * @author            : clabelle@everstream.net
 * @group             : 
 * @last modified on  : 12-05-2022
 * @last modified by  : nbratton@everstream.net
**/
public class PurchaseOrderController {
    public Purchase_Order_Detail__c po { get; set; }
    public List<WrapPurchaseOrderLines> purOrderLines { get; set; }
    public String headerTitle { get; set; }
    public Integer count { get; set; }
    public Integer index { get; set; }
    public String itemId { get; set; }
    public String param { get; set; }
    public String PurchaseObId { get; set; }
    public ApexPages.StandardController sc;
    public Boolean canEditEvenIfLocked { get; set; }
    public Boolean approvalLockInPlace { get; set; }
    public Boolean isButtonVis { get; set; }
    public Boolean newPurchaseOrder  { get; set; }
    public Boolean canEditFields  { get; set; }
 

    
    public PurchaseOrderController(ApexPages.StandardController controller) {
        canEditEvenIfLocked = false;
        approvalLockInPlace = false;
        
        sc = controller;
        PurchaseObId = controller.getId();
        count = 0;
        
        if (PurchaseObId != null && PurchaseObId != '') {
            headerTitle = 'Purchase Order Edit';
            newPurchaseOrder = false;
            po = [
                    select id,Authorized_by_Procurement_Manager__c,Department__c,Account__c,PO_Type__c,Purchase_Order_Number__c,S_H__c,Others__c,Purchase_Order_Approver__c,
                            Purchase_Order_2nd_Approver__c,Purchase_Order_Amount__c, BAN__C, Project__c,
                            X1st_Level_Approval__c,X2nd_Level_Approval__c, Requisitioner__c,Ship_VIA__c,Date__c,F_O_B__c,Expected_Delivery_Date__c,
                            Recipient_Name__c,Recipient_Address__c,Recipient_Email__c,Tax_Rate__c,Shipping_Terms__c,
                            Procurement_Approver_Override__c,Manager_Approver__c,Director_Approver__c,RVP_VP_Approver__c,CXO_EVP_Approver__c,
                            Comment_or_Special_Instruction__c,Internal_Comment__c,Internal_Comments__c,OSP_ROI__c,(select id,Product_Item__r.Name,Product_Item__c,
                            Description__c, Purchase_Order_Product__c, Purchase_Order_Detail__c,Quantity__c,Unit_Price__c,Total__c
                            from Purchase_Order_Lines__r),Sales_Cost_Estimate__c,IMPLEMENTATION__c, Service_Order_Agreement_PO__c, Entity_new__c, Dimension_4__c, PO_Closed__c, Approved_For_Close__c
                    from Purchase_Order_Detail__c
                    where id = :PurchaseObId
            ];

            purOrderLines = new List<WrapPurchaseOrderLines>();
            for (Purchase_Order_Line__c a: po.Purchase_Order_Lines__r) {
                if (a != null) {


                    purOrderLines.add(new WrapPurchaseOrderLines(a, count));
                    count++;
                }
            }
        } else {
            canEditFields = true;
            po = new Purchase_Order_Detail__c();
            headerTitle = 'New Purchase Order';
            newPurchaseOrder = true;
            purOrderLines = new List<WrapPurchaseOrderLines>();
        }
        
        PermissionSetAssignment[] psa = [SELECT PermissionSetId FROM PermissionSetAssignment 
                                         WHERE AssigneeId = :UserInfo.getUserId() 
                                         AND PermissionSet.Name = 'Manual_Edit_of_Purchase_Order_Lines_After_Approval' LIMIT 1];
        if (psa != NULL && psa.size() > 0) {
            canEditEvenIfLocked = true;
        }
    }

    public PageReference doRedirect() {
        canEditEvenIfLocked = false;
        approvalLockInPlace = false;
        
        try {
            Purchase_Order_Detail__c po = [SELECT Purchase_Order_Approver__c,Purchase_Order_2nd_Approver__c,
                                              CXO_EVP_Approver__c, Director_Approver__c, Manager_Approver__c,
                                              RVP_VP_Approver__c
                                           FROM Purchase_Order_Detail__c
                                           WHERE ID = :sc.getId()];
            
          //  Boolean isUserApprover = po != null &&
          //          (UserInfo.getUserId() == po.Purchase_Order_Approver__c || UserInfo.getUserId() == po.Purchase_Order_2nd_Approver__c);
            Boolean isUserApprover = po != null &&
                    (UserInfo.getUserId() == po.CXO_EVP_Approver__c || UserInfo.getUserId() == po.Director_Approver__c
                            || UserInfo.getUserId() == po.Manager_Approver__c|| UserInfo.getUserId() == po.RVP_VP_Approver__c
                            || UserInfo.getUserId() == po.Purchase_Order_Approver__c || UserInfo.getUserId() == po.Purchase_Order_2nd_Approver__c);  
            
            PermissionSetAssignment[] psa = [SELECT PermissionSetId FROM PermissionSetAssignment 
                                             WHERE AssigneeId = :UserInfo.getUserId() 
                                             AND PermissionSet.Name = 'Manual_Edit_of_Purchase_Order_Lines_After_Approval' LIMIT 1];
            if (psa != NULL && psa.size() > 0 || isUserApprover) {
                canEditEvenIfLocked = true;
            }
            approvalLockInPlace = Approval.isLocked(sc.getId());
            
            System.debug('canEditEvenIfLocked='+canEditEvenIfLocked);
            System.debug('Approval.isLocked(sc.getId())='+Approval.isLocked(sc.getId()));
            System.debug('approvalLockInPlace='+approvalLockInPlace);
            System.debug('isUserApprover='+canEditEvenIfLocked);
            

            
            /*if (Approval.isLocked(sc.getId()) && !isUserApprover) {
                if (!canEditEvenIfLocked) {
                    return new PageReference('/' + sc.getId()); //redirect back to the the object becuase the edit view is locked.
                }
            }*/

            if(canEditEvenIfLocked == true ||  approvalLockInPlace == false) {
                canEditFields = true;
            } 

            
        } catch (Exception e) {
            //pass
        }
        
        return null;
    }

    public PageReference doSave() {

        try {
            upsert po;
            List<Purchase_Order_Line__c> itemList = new List<Purchase_Order_Line__c>();

            for (WrapPurchaseOrderLines wItem :purOrderLines) {
                if (wItem.poLine != null) {
                    if (wItem.poLine.Id == null) {
                        wItem.poLine.Purchase_Order_Detail__c = po.Id;
                    }
                    itemList.add(wItem.poLine);
                }
            }

            if (itemList.size() > 0) {
                upsert itemList;
            }
            return new Pagereference('/' + po.Id);
        } catch (Exception e) {
            ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.ERROR, e.getMessage()));
        }

        return null;


    }


    public PageReference doSaveNew() {
        try {
            doSave();
            String keyPrefix = Purchase_Order_Detail__c.sObjectType.getDescribe().getKeyPrefix();
            return new Pagereference('/' + keyPrefix + '/e');
        } catch (Exception e) {
            ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.ERROR, e.getMessage()));
        }

        return null;
    }


    public Pagereference doCancel() {
        if (po.Id != null) {
            return new Pagereference('/' + po.Id);
        } else if (ApexPages.currentPage().getParameters().get('retURL') != null) {
            return new PageReference(ApexPages.currentPage().getParameters().get('retURL'));
        }
        return new PageReference('/home/home.jsp');
    }


    public void addNewOrderLines() {
        purOrderLines.add(new WrapPurchaseOrderLines(null, count));
        count++;
    }

    public Pagereference fechItemDetails() {
        List<WrapPurchaseOrderLines> temp = new List<WrapPurchaseOrderLines>();

        temp = purOrderLines;

        Set<id> ids = new Set<id>();
        for (WrapPurchaseOrderLines s:purOrderLines) {

            ids.add(s.poLine.Product_Item__c);

        }

        System.debug('ids' + ids);
        System.debug('Account' + po.Account__c);


        List<Product_Item__c> sList = [
                select id,Unit_Price__c,UOM__c,Quantity__c,Description__c,Category__c
                from Product_Item__c
                where id IN :ids
        ];
        purOrderLines = new List<WrapPurchaseOrderLines>();
        for (WrapPurchaseOrderLines wrapper:temp) {
            for (Product_Item__c p:sList) {
                if (wrapper != null && wrapper.poLine != null && wrapper.poLine.Product_Item__c != null && wrapper.poLine.Product_Item__c.equals(p.id)) {
                    Purchase_Order_Line__c pl = new Purchase_Order_Line__c();
                    if (wrapper.poLine.id != null) {
                        pl.id = wrapper.poLine.id;
                    }
                    pl.Description__c = p.Description__c;
                    pl.Quantity__c = p.Quantity__c;
                    pl.Unit_Price__c = p.Unit_Price__c;
                    pl.Product_Item__c = p.id;
                    purOrderLines.add(new WrapPurchaseOrderLines(pl, wrapper.index));

                }
            }

        }
        System.debug('fetchList' + purOrderLines.size());
        System.debug('fetch' + purOrderLines);

        return null;
    }


    //Method to remove existing Vendor Invoice Line Item 
    public Pagereference removeNewLines() {
        System.debug('========= index:' + index);
        if (index != null) {
            try {
                System.debug('========= itemId :' + itemId);
                System.debug('============ purOrderLines ' + purOrderLines .get(index));
                if (itemId != null && itemId != '') {
                    delete [Select Id from Purchase_Order_Line__c where Id = :itemId];
                }
                purOrderLines.remove(index);
                count = 0;
                for (WrapPurchaseOrderLines wItem :purOrderLines) {
                    wItem.index = count;
                    count++;
                }
            } catch (Exception e) {
                ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.ERROR, e.getMessage()));
            }
        }
        index = null;
        return null;
    }

    public Pagereference newInvoiceLine() {

        return new Pagereference('/apex/EditPurchaseOrderLine?id=' + PurchaseObId);
    }


    public class WrapPurchaseOrderLines {
        public Purchase_Order_Line__c poLine { get; set; }
        public Integer index { get; set; }

        public WrapPurchaseOrderLines(Purchase_Order_Line__c a, Integer index) {
            this.index = index;
            if (a != null) {
                this.poLine = a;

            } else {
                this.poLine = new Purchase_Order_Line__c();
            }

        }
    }


    public List<SelectOption> getItems() {

        List<SelectOption> options = new List<SelectOption>();

        options.add(new SelectOption('', '--None--'));
        for (Product_Item__c p: [select id,name from Product_Item__c where Vendor_Account__c = :po.Account__c LIMIT 999]) { // SF limit of 1000

            options.add(new SelectOption(p.id, p.name));
        }


        return options;

    }
    
    public PageReference doDiscard() {
        try {
            PermissionSetAssignment[] psa = [SELECT PermissionSetId FROM PermissionSetAssignment 
                                             WHERE AssigneeId = :UserInfo.getUserId() 
                                             AND PermissionSet.Name = 'Manual_Edit_of_Purchase_Order_Lines_After_Approval' LIMIT 1];
            if (psa != NULL && psa.size() > 0) {
                canEditEvenIfLocked = true;
            }
            
            po = [SELECT ID, Status__c FROM Purchase_Order_Detail__c WHERE ID = :po.Id];
            
            if (canEditEvenIfLocked || po.Status__c.equals('New')) {
                po.Status__c = 'Discarded';
                update po;
                
                ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.CONFIRM, 'The Purchase Order Was Discarded.'));
            } else {
                ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.WARNING, 'You cannot discard this PO.'));
            }
        } catch (Exception e) {
            ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.ERROR, e.getMessage()));
        }
        
        return null;
    }

    public PageReference doClosePO() {
        try {
            po = [SELECT ID, Status__c, PO_Closed__c FROM Purchase_Order_Detail__c WHERE ID = :po.Id];
            if (canEditEvenIfLocked){
                if (po.PO_Closed__c = true) {
                    po.PO_Closed__c = false;
                } else {
                    po.PO_Closed__c = true;
                }

                update po;
                
                ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.CONFIRM, 'The Purchase Order Closed Checkbox Was Changed.'));
            } else {
                ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.WARNING, 'You cannot change the Closed checkbox of this PO.'));
            }
        } catch (Exception e) {
            ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.ERROR, e.getMessage()));
        }
        
        return null;
    }

    public void checkLineItemAddBtn(){
        canEditEvenIfLocked = false;
        approvalLockInPlace = false;
        isButtonVis = false;
        PermissionSetAssignment[] psa = [SELECT PermissionSetId FROM PermissionSetAssignment 
                                             WHERE AssigneeId = :UserInfo.getUserId() 
                                             AND PermissionSet.Name = 'Manual_Edit_of_Purchase_Order_Lines_After_Approval' LIMIT 1];
        if (psa != NULL && psa.size() > 0) {
            canEditEvenIfLocked = true;
        }
        approvalLockInPlace = Approval.isLocked(sc.getId());
        if (canEditEvenIfLocked || !approvalLockInPlace){
            isButtonVis = true;
        } else {
            isButtonVis = false;
        }
    }

}