/**
 * @description       :
 * @author            : clabelle@everstream.net
 * @group             :
 * @last modified on  : 11-16-2023
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
    // public static Boolean initiateDisconnect(String recordId){//need to also pull in the requested disconnect date into this method and save it below
    public static Boolean initiateDisconnect(String recordId, Date customerRequestedDiscoDate) {
        System.debug('initiateDisconnect');
        System.debug(recordId);
        System.debug(customerRequestedDiscoDate);
        Boolean isSuccess = false;

        //get the SOF details to calculate out the ETL if applicable
        Order o = [SELECT ID, Contract.Termination_Liability__c, Service_Order_Agreement_MRC_Amortized__c, Contract_End_Date_Est__c, 
                   Billing_Start_Date__c, PDF_Document_Comments__c
                   FROM Order WHERE ID = :recordId];
        
        if (o.Billing_Start_Date__c != NULL && o.Contract_End_Date_Est__c != NULL && o.Service_Order_Agreement_MRC_Amortized__c != NULL && o.Service_Order_Agreement_MRC_Amortized__c > 0) {
            if (o.PDF_Document_Comments__c == NULL && o.Contract != NULL && o.Contract.Termination_Liability__c != NULL && o.Contract.Termination_Liability__c.equals('Standard')) {
                if (o.Contract_End_Date_Est__c < System.today()) {
                    Integer monthsLeft = System.today().monthsBetween(o.Contract_End_Date_Est__c);
                    Decimal etl = monthsLeft * o.Service_Order_Agreement_MRC_Amortized__c;

                    o.Quoted_ETF__c = etl;
                }
            }
        }
        
        o.Status = 'Disconnect in Progress';
        o.Reported_Disconnect_Date__c = System.today();
        o.Disconnect_Date__c = System.today().addDays(30);

        if (customerRequestedDiscoDate != NULL) {
            o.Customer_Requested_Disconnect_Date__c = customerRequestedDiscoDate;
        }

        if (System.today().addDays(30) > o.Customer_Requested_Disconnect_Date__c) {
            o.Disconnect_Date__c = System.today().addDays(30);
        } else {
           o.Disconnect_Date__c = customerRequestedDiscoDate.addDays(30);
        }

        update o;

        isSuccess = true;

        return isSuccess;
    }

}