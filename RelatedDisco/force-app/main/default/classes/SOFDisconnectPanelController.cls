/**
 * @description       :
 * @author            : clabelle@everstream.net
 * @group             :
 * @last modified on  : 08-11-2023
 * @last modified by  : clabelle@everstream.net
 **/
public without sharing class SOFDisconnectPanelController{
    @AuraEnabled
    public static List<MPM4_BASE__Milestone1_Task__c> getTasks(String recordId){
        List<MPM4_BASE__Milestone1_Task__c> tasks = new List<MPM4_BASE__Milestone1_Task__c>();
        tasks = [SELECT ID, Name, Milestone_Name__c, MPM4_BASE__Complete__c, Not_Applicable__c, Resource_Name__c
                 FROM MPM4_BASE__Milestone1_Task__c
                 WHERE Service_Order_Agreement__c = :recordId AND MPM4_BASE__Project_Lookup__r.Primary_Project__c = TRUE AND MPM4_BASE__Project_Lookup__r.Initial_Project_Template_Chosen__c LIKE '%Disconnect%'];


        if (tasks.size() > 0){
            System.debug(tasks);
            return tasks;
        } else{
            System.debug('No tasks found');
            return null;
        }
    }

    @AuraEnabled
    public static void updateMilestone1Tasks(List<MPM4_BASE__Milestone1_Task__c> tasks){
        System.debug('updateMilestone1Tasks');
        System.debug(tasks);
        if (tasks.size() > 0){
            update tasks;
        }
    }
    @AuraEnabled
    public static void updateMilestone1Task(MPM4_BASE__Milestone1_Task__c task){
        MPM4_BASE__Milestone1_Task__c taskToUpdate = new MPM4_BASE__Milestone1_Task__c();
        taskToUpdate.Id = task.Id;
        taskToUpdate.MPM4_BASE__Complete__c = task.MPM4_BASE__Complete__c;
        taskToUpdate.Not_Applicable__c = task.Not_Applicable__c;

        System.debug('updateMilestone1Task');
        System.debug(task);
        if (task != null && task.Id != null){
            System.debug('update task: ' + taskToUpdate);
            update taskToUpdate;
        }
    }

    @AuraEnabled
    public static Order getSofDetails(String recordId){
        return [SELECT ID, OrderNumber, Status
                FROM Order
                WHERE Id = :recordId];
    }

    @AuraEnabled
    public static Boolean initiateDisconnect(String recordId){
        //public static Boolean initiateDisconnect(String recordId, Date customerRequestedDiscoDate) {
        System.debug('initiateDisconnect');
        Boolean isSuccess = false;

        update new Order(Id = recordId, Status = 'Disconnect in Progress', Reported_Disconnect_Date__c = System.today());
        //update new Order(Id = recordId, Status = 'Disconnect in Progress', Reported_Disconnect_Date__c = System.today(), Customer_Requested_Disconnect_Date__c = customerRequestedDiscoDate);
        isSuccess = true;

        return isSuccess;
    }

}