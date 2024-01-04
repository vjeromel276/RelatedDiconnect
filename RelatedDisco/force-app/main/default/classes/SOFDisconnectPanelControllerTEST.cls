@isTest(SeeAllData=true)
public with sharing class SOFDisconnectPanelControllerTEST {
    public SOFDisconnectPanelControllerTEST() {
    }

    @isTest
    static void testGetTasks() {
        
        /* Order o = [SELECT Id
                     FROM Order
                     WHERE Id ='8013g000000UQvQAAW'
                     LIMIT 1]; */

        // Call the getTasks method from your controller
        // List<MPM4_BASE__Milestone1_Task__c> result = SOFDisconnectPanelController.getTasks(o.Id);
        List<MPM4_BASE__Milestone1_Task__c> result = SOFDisconnectPanelController.getTasks('8013g000000UQvQAAW');

        // Assert that the result contains the expected tasks
        System.assertEquals(0, result.size()); // Expecting 15 task
        //System.assertEquals('Task 1', result[0].Name); // Expecting Task 1 in the result
    }

}