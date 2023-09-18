@isTest
private class TestPurchaseOrderController {

    static testMethod void doTestAP() {
        Account acc = new Account(Name = 'Test Account AP', Type = 'Vendor');
        insert acc;

        Purchase_Order_Detail__c a = new Purchase_Order_Detail__c(
                Purchase_Order_Amount__c = 700,
                Account__c = acc.Id,
                Status__c = 'New',
                Purchase_Order_Number__c = '12345'

        );
        insert a;

        Product_Item__c p = new Product_Item__c(
                Unit_Price__c = 700,
                Quantity__c = 2,
                Description__c = 'New',
                Vendor_Account__c = acc.id

        );
        insert p;


        Purchase_Order_Line__c po = new Purchase_Order_Line__c();
        po.Purchase_Order_Detail__c = a.id;
        po.Product_Item__c = p.id;
        po.Unit_Price__c = 700;
        po.Quantity__c = 2;
        po.Description__c = 'New';
        insert po;

        Apexpages.currentPage().getParameters().put('id', a.Id);
        PurchaseOrderController poc = new PurchaseOrderController(new Apexpages.standardController(a));
        poc.index = 0;

        poc.fechItemDetails();
        poc.doSave();
        poc.doSaveNew();
        poc.addNewOrderLines();
        poc.getItems();
        poc.removeNewLines();
        poc.newInvoiceLine();
        poc.doCancel();
        poc.doRedirect();
        poc.checkLineItemAddBtn();
        poc.doDiscard();
    }


}