global class BatchAutoMsaContractRenewal implements Database.Batchable<sObject>, Schedulable, Database.Stateful {
    global Integer recordsParsed = 0;
    global Integer recordsUpdated = 0;
    global Database.QueryLocator start(Database.BatchableContext bc) {

        //initial launch
        String soql = 'SELECT Id, Service_Order_Agreement_Replacing__c, AccountId, Contract_End_Date_Est__c, Service_End_Date__c, Contract.Id, Contract.Auto_Renewal_Term__c FROM Order WHERE Contract_End_Date_Est__c >= TODAY AND Contract_End_Date_Est__c <=  NEXT_N_DAYS:30 and Contract.Auto_Renewal__c = true and Contract.Auto_Renewal_Term__c != \'Month to Month\' AND Contract.Auto_Renewal_Term__c != \'none\' AND Contract.Auto_Renewal_Term__c != \'1\' AND Service_Order_Agreement_Replacing__c = null AND Opportunity.Id != Null AND autoMsaRenewed__c = false AND Status = \'Activated\'  and Has_Successor__c = false ';


        if ( Test.isRunningTest() ) {
            soql = 'SELECT Id, Service_Order_Agreement_Replacing__c, AccountId, Contract_End_Date_Est__c, Service_End_Date__c, Contract.Id, Contract.Auto_Renewal_Term__c FROM Order WHERE Contract_End_Date_Est__c >= TODAY AND Contract_End_Date_Est__c <=  NEXT_N_DAYS:30 and Contract.Auto_Renewal__c = true and Contract.Auto_Renewal_Term__c != \'Month to Month\' AND Contract.Auto_Renewal_Term__c != \'none\' AND Contract.Auto_Renewal_Term__c != \'1\' AND Service_Order_Agreement_Replacing__c = null AND Opportunity.Id != Null AND autoMsaRenewed__c = false AND Status = \'Activated\' LIMIT 1';
        }

        return Database.getQueryLocator(soql);
    }

    global void execute(Database.BatchableContext bc, List<Order> scope) {


        System.debug('scope=' + scope);
        try {
            if ( !scope.isEmpty() ) {
                recordsParsed = scope.size();


                //check for child orders that have already been processed
                Order[] childOrds = [SELECT Id, Service_Order_Agreement_Replacing__c
                                     FROM Order
                                     WHERE Service_Order_Agreement_Replacing__c IN:scope AND Auto_Created_By_MSA_Renewal__c = true];


                Set<Id> IdsOfOrdersAlreadyProcessed = new Set<Id>();
                if ( childOrds != null && childOrds.size() > 0 ) {
                    System.debug('===============================================');
                    System.debug('msa child orders found');
                    System.debug('===============================================');
                    for ( Order o : childOrds ) {
                        IdsOfOrdersAlreadyProcessed.add(o.Service_Order_Agreement_Replacing__c);
                    }
                }


                for ( Order o : scope ) {

                    Boolean result = IdsOfOrdersAlreadyProcessed.contains(o.Id);

                    if ( !result ) {
                        System.debug('===============================================');
                        System.debug('no child orders going to deep clone');
                        System.debug('===============================================');
                        ApexPages.StandardController ctlr = new ApexPages.StandardController( o );
                        DeepCloneOrderAndProducts controller = new DeepCloneOrderAndProducts(ctlr);
                        controller.AutoCloneOrderAndProducts(o);
                    }
                    else {
                        System.debug('===============================================');
                        System.debug('skipped deep clone cause child');
                        System.debug('===============================================');
                    }


                    recordsUpdated++;
                }

            }

        }
        catch ( Exception e ) {
            System.debug(e);
            CreateErrorRecord er = new CreateErrorRecord();
            er.create('BatchAutoMsaContractRenewal', null, scope + '  |  ' + e.getMessage(), e.getTypeName(), e.getLineNumber(), e.getStackTraceString(), false, false);
        }
    }

    global void finish(Database.BatchableContext bc) {

        System.debug(recordsUpdated + ' records updated.');

        String soql = 'SELECT Id, ApexClass.Name, MethodName, JobType, Status, NumberOfErrors, JobItemsProcessed, TotalJobItems, ExtendedStatus, CreatedBy.Email FROM AsyncApexJob ';

        if ( bc != NULL ) {
            soql = soql + 'WHERE Id = \'' + bc.getJobId() + '\'';
        }
        else {
            soql = soql + ' ORDER BY CreatedDate DESC LIMIT 1';
        }

        AsyncApexJob job = Database.query(soql);
        EmailUtils em = new EmailUtils();
        em.sendMessage(job, recordsUpdated, recordsParsed);
    }

    global void execute(SchedulableContext SC) {
        Database.executeBatch(new BatchAutoMsaContractRenewal(), 1);
    }

    global static void start(Integer hour) {
        /*
         * To schedule this, run the below command using Anonymous Apex:
         *
         *    - immediately submits the batch job
         *        BatchAutoMsaContractRenewal.start();
         *    - schedules the batch job to run every @param hrs.
         *        BatchAutoMsaContractRenewal.start(1);
         *
         */

        String jobName = 'BatchAutoMsaContractRenewal';
        if ( hour == 0 ) {
            Database.executebatch(new BatchAutoMsaContractRenewal(), 1);
        }
        else {

            BatchAutoMsaContractRenewal p = new BatchAutoMsaContractRenewal();
            String cron = '0 0 * * * ?';
            system.schedule(jobName, cron, p);
        }
    }

}

/**
 * TODO
 *
 *
 *
 * Order o = new Order();
 o.Id = '8014P000000j44WQAQ';

 ApexPages.StandardController ctlr = new ApexPages.StandardController(o);

 DeepCloneOrderAndProducts controller= new DeepCloneOrderAndProducts(ctlr);

 controller.AutoCloneOrderAndProducts(o);
 *
 * soql view msa renewed or old orders:
 * SELECT Id, autoMsaRenewed__c FROM Order where autoMsaRenewed__c = true
 *
 * soql new msa renewed orders
 * SELECT Id, Service_Order_Agreement_Replacing__c, AccountId, Contract_End_Date_Est__c,   Service_End_Date__c, Contract.Id, Contract.Auto_Renewal_Term__c FROM Order WHERE Service_End_Date__c >= TODAY AND Service_End_Date__c <=  NEXT_N_DAYS:30 and Contract.Auto_Renewal__c = true and Contract.Auto_Renewal_Term__c != 'Month to Month' AND Contract.Auto_Renewal_Term__c != 'none' AND Service_Order_Agreement_Replacing__c = null AND Opportunity.Id != Null AND autoMsaRenewed__c = false LIMIT 1
 *

 *  copoado
 *  classes
 *      -Batchautomsacontractrenewal
 *      -BatchautomsacontractrenewalTest
 *      -deepcloneorderandproducts
 *      -deepcloneorderandproductstest
 * fields
 *      - autoMsaRenewed__c on order
 *      - Order_Term__c on order(formula updated)
 *          - org: IF( ISBLANK(Order_Term_Override__c), SBQQ__Quote__r.PDF_Term__c, Order_Term_Override__c )
 *
 */