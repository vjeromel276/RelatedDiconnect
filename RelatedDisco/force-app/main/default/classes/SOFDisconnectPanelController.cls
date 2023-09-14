/**
 * @description       : 
 * @author            : clabelle@everstream.net
 * @group             : 
 * @last modified on  : 08-11-2023
 * @last modified by  : clabelle@everstream.net
**/
public without sharing class SOFDisconnectPanelController {
    @AuraEnabled(cacheable=true)
    public static List<MPM4_BASE__Milestone1_Task__c> getTasks(String recordId) {
        List<MPM4_BASE__Milestone1_Task__c> tasks = new List<MPM4_BASE__Milestone1_Task__c>();
        tasks = [SELECT ID, Name, Milestone_Name__c, MPM4_BASE__Complete__c, Not_Applicable__c, Resource_Name__c 
                 FROM MPM4_BASE__Milestone1_Task__c 
                 WHERE Service_Order_Agreement__c = :recordId 
                 AND MPM4_BASE__Project_Lookup__r.Primary_Project__c = TRUE 
                 AND MPM4_BASE__Project_Lookup__r.Initial_Project_Template_Chosen__c LIKE '%Disconnect%'];
        
        return tasks;
    }

    @AuraEnabled(cacheable=true)
    public static Order getSofDetails(String recordId) {
        return [SELECT ID, OrderNumber, Status FROM Order WHERE Id = :recordId];
    }

    @AuraEnabled(cacheable=true)
    public static Boolean initiateDisconnect(String recordId) {
        //public static Boolean initiateDisconnect(String recordId, Date customerRequestedDiscoDate) {
            System.debug('initiateDisconnect');
        Boolean isSuccess = false;
        
        update new Order(Id = recordId, Status = 'Disconnect in Progress', Reported_Disconnect_Date__c = System.today());
        //update new Order(Id = recordId, Status = 'Disconnect in Progress', Reported_Disconnect_Date__c = System.today(), Customer_Requested_Disconnect_Date__c = customerRequestedDiscoDate);
        isSuccess = true;

        return isSuccess;
    }
}