@isTest(SeeAllData=true)
public with sharing class SOFDisconnectPanelControllerTEST {
    public SOFDisconnectPanelControllerTEST() {
    }

    @isTest
    static void testGetTasks() {

        Order soa = [SELECT Id, Service_Order_Agreement_MRC_Amortized__c, Contract_End_Date_Est__c, Customer_Requested_Disconnect_Date__c,
                   Billing_Start_Date__c, PDF_Document_Comments__c,Disconnect_Date__c, Quoted_ETF__c, Status, Reported_Disconnect_Date__c
                   FROM Order WHERE Id ='8010B0000005yJgQAI' LIMIT 1];

        // Call the getTasks method from your controller
        List<MPM4_BASE__Milestone1_Task__c> result = SOFDisconnectPanelController.getTasks(soa.Id);

        // Assert that the result contains the expected tasks
        System.assertEquals(15, result.size()); // Expecting 15 task 
        //System.assertEquals('Task 1', result[0].Name); // Expecting Task 1 in the result
    }

}