/**
 * @description       : 
 * @author            : dbaty@everstream.net
 * @group             : 
 * @last modified on  : 09-27-2023
 * @last modified by  : clabelle@everstream.net
**/
global without sharing  class NMS_alerts_controller {




    /******************************************************
     * ------------| get all alerts |------------
     *****************************************************
     not being used*/   
    @AuraEnabled(cacheable=true)
    public static List<NMS_Alert__c> getAllAlerts() {

        NMS_Alert__c[] alerts = [SELECT 
        Id, open__c, closed__c, ignored__c,  Name, Alert_Name__c, Message__c, CreatedDate, AlertType__c, Status__c,  Source__c, 
        IP_Address__c, Interface_ID__c, Instigator__c, Increment_Alert_Count__c, Input_Parameters__c, 
        Identifier__c, Device_ID__c, ClosedDate__c, Alert_URL__c, Acknowledged_Date_Time__c, Acknowledged_By__c, 
        Acknowledged__c, Acknowledge_URL__c, Service_ID__c, Times_Alert_Received__c, URL__c, Support_Ticket__c, Case_URL__c, alertExpanded__c, is_outage__c, Support_Ticket_Name__c, Last_Time_Alert_Recieved__c
        
        FROM NMS_Alert__c  ORDER BY CreatedDate desc limit 5];
        return alerts;
    }  
    /*--------------------------------------------------------*/






    @AuraEnabled(cacheable=true)
    public static List<NMS_Alert__c> getSingleAlert(String Id) {

        System.debug('Get Single Alert CAlled');

        NMS_Alert__c[] alerts = [SELECT Id, open__c, closed__c, ignored__c,  Name, Alert_Name__c, Message__c, CreatedDate, AlertType__c, Status__c,  Source__c, 
        IP_Address__c, Interface_ID__c, Instigator__c, Increment_Alert_Count__c, Input_Parameters__c, 
        Identifier__c, Device_ID__c, ClosedDate__c, Alert_URL__c, Acknowledged_Date_Time__c, Acknowledged_By__c, 
        Acknowledged__c, Acknowledge_URL__c, Service_ID__c, Times_Alert_Received__c, URL__c, Support_Ticket__c, Case_URL__c, alertExpanded__c, is_outage__c, Support_Ticket_Name__c, Last_Time_Alert_Recieved__c, MultipleRecieved__c
                
        FROM NMS_Alert__c WHERE Id = :Id ];
        System.debug(alerts);
        return alerts;
    }  












    /******************************************************
     * --------| get all alerts for infinite loader |--------
     ******************************************************/   
    /**
     * getAllAlertsLazy()
     * 
     * gets all alerts for infinite scroll, takes in query limit and record offset as params
     * this function utilizes org cache so as not to query the DB incase of governer limits
     * 
     * @param   limitSize   Integer     The limit of rows to return
     * @param   offset      Integer     Where to offset the records at, for inifnite loading
     */
    @AuraEnabled(cacheable=false)
    public static List<NMS_Alert__c> getAllAlertsLazy( Integer limitSize, Integer offset, String source, String opencloseFilter ) {

       /* String  source = 'NOC - MSP';
        Integer offset = 0;
        Integer limitSize = 2;
        String opencloseFilter = 'All';*/
        System.debug('**********************');
        System.debug(opencloseFilter);
        System.debug('**********************');
        
        List<String> sources = new List<String>();
                sources.add(source);
        
                if (sources != NULL && sources.size() > 0) {
                    for (String src : sources) {
                        if (src.contains('NOC - MSP')) {
                            sources.add('Meraki');
                            sources.add('Mist');
                            sources.add('Solarwinds - MSP');
                            sources.add('Solarwinds - Lightbound');
                            break;
                        } else if (src.contains('NOC - Enterprise')) {
                            sources.add('Solarwinds');
                            sources.add('Celestis');
                            break;
                        }
                    }
                }


                //this is fuckey but it adds quotes to all items in the sources list so the soql statment can read it
                string t ='(\''+String.join(sources,'\',\'')+'\')';

               List<NMS_Alert__c> alerts = new List<NMS_Alert__c>();
        
        
                Boolean FilterBySource = false;
                String filterByOpenClose = 'All';
        
                if(sources != null && sources.size() > 0 && !sources.contains('All')) {
                    FilterBySource = true;
                }
        
                switch on opencloseFilter {
                    when  'Open'  {
                        filterByOpenClose = 'Open';
                    }
                    when 'Closed' {
                        filterByOpenClose = 'Closed';
                    }
                    when else {
                        filterByOpenClose = 'All';
                    }            
                }
        
        
                String soql = 'SELECT Id, open__c, closed__c, ignored__c,  Name, Alert_Name__c, Message__c, CreatedDate, AlertType__c, Status__c,  Source__c,  IP_Address__c, Interface_ID__c, Instigator__c, Increment_Alert_Count__c, Input_Parameters__c,  Identifier__c, Device_ID__c, ClosedDate__c, Alert_URL__c, Acknowledged_Date_Time__c, Acknowledged_By__c,  Acknowledged__c, Acknowledge_URL__c, Service_ID__c, Times_Alert_Received__c, URL__c, Support_Ticket__c, Case_URL__c, alertExpanded__c, is_outage__c, Support_Ticket_Name__c, Last_Time_Alert_Recieved__c, MultipleRecieved__c FROM NMS_Alert__c ';
        
        
                if(FilterBySource || filterByOpenClose != 'All') {
                    soql += ' WHERE ';
        
                    if(FilterBySource) {
                        soql += 'Source__c IN ' + t + '';
                    }
            
                    if(FilterBySource && filterByOpenClose != 'All') {
                        soql += ' AND ';
                    }
                    if(filterByOpenClose == 'Open') {
                        soql += ' open__c = TRUE ';
                    }
                    if(filterByOpenClose == 'closed') {
                        soql += ' closed__C = TRUE';
                    }            
                }
        
        
                
                //execute that beotch
                soql +=  ' ORDER BY CreatedDate desc LIMIT ' + limitSize + ' OFFSET ' +  offset + '';
        
                System.debug(soql);
            alerts = Database.query(soql);



/*

        if(sources != null && sources.size() > 0 && sources.contains('All')) {
            System.debug('retrieving unfiltered alerts');
            alerts = [SELECT Id, open__c, closed__c, ignored__c,  Name, Alert_Name__c, Message__c, CreatedDate, AlertType__c, Status__c,  Source__c, 
            IP_Address__c, Interface_ID__c, Instigator__c, Increment_Alert_Count__c, Input_Parameters__c, 
            Identifier__c, Device_ID__c, ClosedDate__c, Alert_URL__c, Acknowledged_Date_Time__c, Acknowledged_By__c, 
            Acknowledged__c, Acknowledge_URL__c, Service_ID__c, Times_Alert_Received__c, URL__c, Support_Ticket__c, Case_URL__c, alertExpanded__c, is_outage__c, Support_Ticket_Name__c, Last_Time_Alert_Recieved__c, MultipleRecieved__c
                    
            FROM NMS_Alert__c ORDER BY CreatedDate desc LIMIT :limitSize OFFSET :offset];


        } else {
            System.debug('retrieving filtered alerts: ' + sources );
            alerts = [SELECT Id, open__c, closed__c, ignored__c,  Name, Alert_Name__c, Message__c, CreatedDate, AlertType__c, Status__c,  Source__c, 
            IP_Address__c, Interface_ID__c, Instigator__c, Increment_Alert_Count__c, Input_Parameters__c, 
            Identifier__c, Device_ID__c, ClosedDate__c, Alert_URL__c, Acknowledged_Date_Time__c, Acknowledged_By__c, 
            Acknowledged__c, Acknowledge_URL__c, Service_ID__c, Times_Alert_Received__c, URL__c, Support_Ticket__c, Case_URL__c, alertExpanded__c, is_outage__c, Support_Ticket_Name__c, Last_Time_Alert_Recieved__c, MultipleRecieved__c
                    
            FROM NMS_Alert__c WHERE Source__c IN :sources ORDER BY CreatedDate desc LIMIT :limitSize OFFSET :offset];
        }
*/

        System.debug(alerts);
        
        return alerts;
    }
    /*--------------------------------------------------------*/    

    
    /******************************************************
     * ---------------| get number of alerts |--------------
     ******************************************************/ 
    /**
     * alertCount()
     * 
     * Function to stricly return the number of alerts available, a seriouse waste of a soql query, open to ideas on this
     * */      
    @AuraEnabled(cacheable=true)
    public static String alertCount() {
        Integer alertCount = [Select count() from NMS_Alert__c ];

        List<String> args = new String[]{'0','number','###,###,##0.00'};
        String s = String.format(alertCount.format(), args);

        return s;

    }
    /*--------------------------------------------------------*/        





    @AuraEnabled(cacheable=false)
    global static Boolean SingleAlertAction( String action, String alertId ) {
    Boolean updated = false;
    CreateErrorRecord er = new CreateErrorRecord();
    try {
        NMS_Alert__c[] alert = [SELECT Id, closed__c, open__c, Support_Ticket__c, ClosedDate__c,  Acknowledge_URL__c, Acknowledged__c, Acknowledged_By__c, Acknowledged_Date_Time__c, Alert_URL__c, AlertType__c, CreatedDate, Device_ID__c, Identifier__c, Increment_Alert_Count__c, Input_Parameters__c, Instigator__c, Interface_ID__c, IP_Address__c, Message__c, Alert_Name__c, Service_ID__c, Source__c, Status__c, Times_Alert_Received__c, URL__c  FROM NMS_Alert__c WHERE Id = :alertId LIMIT 1 ];

            



        
        Boolean updateTicket = false;
        Boolean updateOpenClose = false;


        List<NMS_Alert__c> alertsToUpdate = new List<NMS_Alert__c>();

        switch on action {
            when 'acknowledge'  {
                if(alert!=null && !alert.isEmpty()) {
                    for(NMS_Alert__c a : alert ) {
                        a.Acknowledged__c = true;
                        alertsToUpdate.add(a);
                    } 
                }
            }
            when 'unacknowledge'  {
                System.debug('unacknowledge alert');
                if(alert!=null && !alert.isEmpty()) {
                    for(NMS_Alert__c a : alert ) {
                        a.Acknowledged__c = false;
                        a.Acknowledge_URL__c = null;
                        a.Acknowledged_By__c = null;
                        a.Acknowledged_Date_Time__c = null;
                        a.Status__c = 'Open';
                        alertsToUpdate.add(a);
                    } 
                }
            } 
            when 'open'  {
                System.debug('open alert');
                if(alert!=null && !alert.isEmpty()) {
                    for(NMS_Alert__c a : alert ) {
                        //a.open__c = true;
                        //a.closed__c = false;
                        a.Status__c = 'Open';
                        alertsToUpdate.add(a);
                        updateOpenClose = true;
                    } 
                }             
            }
            when 'close'  {
                if(alert!=null && !alert.isEmpty()) {
                    for(NMS_Alert__c a : alert ) {
                        //a.closed__c = true;
                        //a.open__c = false;
                        a.Status__c = 'Closed';
                        a.ClosedDate__c = System.now();
                        alertsToUpdate.add(a);
                        updateTicket = true;
                        updateOpenClose = true;
                    } 
                }
            } 
            when 'ignore'  {
                System.debug('ignore alert');
                if(alert!=null && !alert.isEmpty()) {
                    for(NMS_Alert__c a : alert ) {
                        //a.ignored__c = true;
                        a.Status__c = 'Ignored';
                        alertsToUpdate.add(a);
                    } 
                }               
            }
        }
        
        if( updateTicket && alert[0].Support_Ticket__c != null) {
            //update the ticket because close
            Case[] ticket = [SELECT Id, AlertID__c FROM Case WHERE AlertID__c = :alert[0].Id LIMIT 1 ];

            List<CaseComment> newCaseComments = new List<CaseComment>();

            CaseComment newComment = new CaseComment();
            User currentUser = [Select TimeZoneSidKey from User where id =: USerInfo.getUserId()];

            DateTime dt = DateTime.now();
            String dateTimeStr = '' + dt.format('MM/dd/yyyy hh:mm a') + ' ' + currentUser.TimeZoneSidKey + '';

            newComment.CommentBody = 'ODIN closed alert at ' + dateTimeStr + '';

            if(ticket != null && ticket.size() > 0 ){
                newComment.ParentId = ticket[0].Id;
                newComment.IsPublished = FALSE;
                newCaseComments.add(newComment);                
            }

        

            if (newCaseComments != NULL && newCaseComments.size() > 0) {
                try {
                    insert newCaseComments;
                    System.debug('Updated Ticket');
                } catch (Exception e) {
                    System.debug( 'The Following excedption occured on NMS Alerts Controller when creating case comments: ' + e );
                    er.create('NMS_alerts_controller', alertId, e.getMessage(), e.getTypeName(), e.getLineNumber(), e.getStackTraceString(), false, true);
                    throw e;
                }       
            }
        }

        if(alertsToUpdate!=null && !alertsToUpdate.isEmpty()) {
            try {
                System.debug('UPDATEING');
                //update alertsToUpdate;
                //updated = true;
                List<Database.SaveResult> results = Database.update(alertsToUpdate, false);
                for (Database.SaveResult result : results) {
                    if (result.isSuccess()){
                        System.debug('succeful save alert');
                        updated = true;
                    }
                }
            } catch (Exception e) {
                System.debug( 'The Following excedption occured on NMS Alerts Controller when acknologing an alert: ' + e );
                er.create('NMS_alerts_controller', alertId, e.getMessage(), e.getTypeName(), e.getLineNumber(), e.getStackTraceString(), false, true);
                throw e;
            }
        }

        if( updateOpenClose  && updated  ) {
            System.debug('send filtered platform event');
            if(alert!=null && !alert.isEmpty()) {
                for(NMS_Alert__c a : alert ) {
                    Record_Creation__e pe = new Record_Creation__e();
                    Formula.recalculateFormulas(new List<NMS_Alert__c> { a });
                    pe.Record_Id__c = a.Id;
                    pe.Acknowledge_URL_c__c = a.Acknowledge_URL__c;
                    pe.Acknowledged_c__c = a.Acknowledged__c;
                    pe.Acknowledged_By_c__c = a.Acknowledged_By__c;
                    pe.Acknowledged_Date_Time_c__c = a.Acknowledged_Date_Time__c;
                    pe.Alert_URL_c__c = a.Alert_URL__c;
                    pe.AlertType_c__c = a.AlertType__c;
                    pe.ClosedDate_c__c = a.ClosedDate__c;
                    pe.CreatedDate__c = a.CreatedDate;
                    pe.Device_ID_c__c = a.Device_ID__c;
                    pe.Identifier_c__c = a.Identifier__c;
                    pe.Increment_Alert_Count_c__c = a.Increment_Alert_Count__c;
                    pe.Input_Parameters_c__c = a.Input_Parameters__c;
                    pe.Instigator_c__c = a.Instigator__c;
                    pe.Interface_ID_c__c = a.Interface_ID__c;
                    pe.IP_Address_c__c = a.IP_Address__c;
                    pe.Message__c = a.Message__c;
                    pe.Record_Name__c = a.Alert_Name__c;
                    pe.Service_ID_c__c = a.Service_ID__c;
                    pe.Source_c__c = a.Source__c;
                    pe.Status_c__c = a.Status__c;
                    pe.Times_Alert_Received_c__c = a.Times_Alert_Received__c;
                    pe.URL__c = a.URL__c;
                    pe.isUpdate__c = true;
                    //Database.SaveResult sr = EventBus.publish(pe);   
                    
                    
                    PlatformEventListner eventListener = new PlatformEventListner();
                    EventBus.publish(pe, eventListener);
          
                }
            }
     
        }

    } catch (Exception e) {
        System.debug(e);
        er.create('NMS_alerts_controller', alertId, e.getMessage(), e.getTypeName(), e.getLineNumber(), e.getStackTraceString(), false, true);
    }

        return updated;
    }







    
    @AuraEnabled(cacheable=false)
    global static Boolean createAlertTicketAlt( List<Id> alertIds ) {

        NMS_Alert__c[] alerts = [SELECT  Id, Name,Asset__c,  Alert_Name__c, URL__c, Message__c, CreatedDate, Support_Ticket__c,Service_ID__c, ignored__c, open__c, closed__c, Case_URL__c, AlertType__c, Status__c,  Source__c, IP_Address__c, Interface_ID__c, Instigator__c, Increment_Alert_Count__c, Input_Parameters__c, Identifier__c, Device_ID__c, ClosedDate__c, Alert_URL__c, Acknowledged_Date_Time__c, Acknowledged_By__c, Acknowledged__c, Acknowledge_URL__c FROM NMS_Alert__c WHERE Id = :alertIds ];

        Boolean created = false;

        List<Case> ticketsToCreate = new List<Case>();
        List<CaseComment> newCaseComments = new List<CaseComment>();
        Map<NMS_Alert__c, Id> updatedAlertsRef = new Map<NMS_Alert__c, Id>();
        List<Id> alertsIdToUpdate  = new List<Id>();
        Map<Case, List<NMS_Alert__c>> caseAlertMap = new Map<Case, List<NMS_Alert__c>>();

        if(alerts!=null && !alerts.isEmpty()) {
            for(NMS_Alert__c a : alerts ) {

                alertsIdToUpdate.add(a.Id);
                

                // get account info from alert by id, see GetAlertAccountOrderInfo() below
                Map<String, String> t = GetAlertAccountOrderInfo(a.Device_ID__c, a.Service_ID__c); 

                //init some vars
                String accountId;
                String accountName;
                String assetId;
                String sofId;
                String market;
                String identifier;

                //set vars from map values of GetAlertAccountOrderInfo
                if(t != null && t.size() > 0 ) {
                    accountId = t.get('accountId');
                    accountName = t.get('accountName');
                    assetId = t.get('assetId');
                    sofId = t.get('sofId');
                    market = t.get('market');
                    identifier = t.get('identifier');        
                }

                System.debug('***********accountId = ' + accountId);
                System.debug('***********accountName = ' + accountName);
                System.debug('***********assetId = ' + assetId);
                System.debug('***********sofId = ' + sofId);
                System.debug('***********market = ' + market);
                System.debug('***********identifier = ' + identifier);

                //build the Subject
                String Subject = '';
                if(market != null && market != '') {Subject = '' + market  + '|';}
                if(accountName != null && accountName != '') {Subject += '' + accountName + '|';}
                //if(type != null && type != '') {Subject += '' + type + '|'}
                if(a.Alert_Name__c != null && a.Alert_Name__c != '') {Subject += a.Alert_Name__c;}

                
                
                
                Case ticket = new Case();
                ticket.RecordTypeId = 	'012U0000000DpFKIA0';
                if(Subject == '') {
                    ticket.Subject = '' + a.Alert_Name__c + ' - ' + a.Id + '';
                } else {
                    ticket.Subject = Subject;
                }
                ticket.Origin = 'Proactive';
                ticket.AlertId__c = a.Id;
                ticket.Initial_Alert_Time__c = a.CreatedDate;
                //ticket.Request_Type__c = 'Support';


                switch on a.Source__c {
                    when 'Solarwinds - MSP' {
                        ticket.NOC_Ticket_Assigment__c = 'MSP NOC';
                    }
                    when 'Solarwinds - Lightbound' {
                        ticket.NOC_Ticket_Assigment__c = 'MSP NOC';
                    }                  
                    when 'Meraki' {
                        ticket.NOC_Ticket_Assigment__c = 'MSP NOC';
                    }
                    when 'Mist' {
                        ticket.NOC_Ticket_Assigment__c = 'MSP NOC';
                    }   
                    when 'Cisco Meraki' {
                        ticket.NOC_Ticket_Assigment__c = 'MSP NOC';
                    }   
                    when 'Juniper Mist' {
                        ticket.NOC_Ticket_Assigment__c = 'MSP NOC';
                    }                                                                                
                    when else {
                        ticket.NOC_Ticket_Assigment__c = 'NOC I';
                    }
                }

                ticket.AccountId = accountId;
                ticket.Related_Service_Order__c = sofId;
                ticket.Dimension_4_Market__c = market;

                ticketsToCreate.add(ticket);
            }

            if(ticketsToCreate!=null && !ticketsToCreate.isEmpty()) {
                try {
                    insert ticketsToCreate;

                    if( ticketsToCreate != null && ticketsToCreate.size() > 0 )  {
                        //build map to update case comments by attaching the ticket id to them
                        for( Case c : ticketsToCreate) {
                            
                            //LinkAlert(alertsIdToUpdate, c.Id, false, true );

                            for( NMS_Alert__c alert : alerts ) {
                                if (alert.Id.equals(c.AlertId__c)) {
                                    LinkAlert(new List<Id>{alert.Id}, c.Id, false, true );

                                    System.debug('putting alert: ' + alert.Id  + 'ticket: ' + c.Id + 'into a map for later');
                                    alert.Support_Ticket__c = c.Id;
                                    //alertsToUpdate.add(alert);
                                    updatedAlertsRef.put(alert, c.Id );

                                    Date alertDate;
                                    if(alert.ClosedDate__c != null) {
                                        alertDate = alert.ClosedDate__c.date();
                                    }
                                    String caseUrl = URL.getSalesforceBaseUrl().toExternalForm() + '/' + c.Id;


                                    System.debug('*************************************' );
                                    System.debug('caseUrl: ' + caseUrl);
                                    System.debug(' alert.Support_Ticket__c: ' +  alert.Support_Ticket__c);
                                    System.debug('*************************************' );
                                    
                                    getrefreshEveryonesScreens(alert.Id, alert.Acknowledged__c, caseUrl, alertDate, alert.ignored__c, alert.open__c, alert.Support_Ticket__c, alert.closed__c, 'Created ticket(s) ' + alert.Alert_Name__c, 'createTicket', false );
                                }
                            }
                        }
                        created = true;
                    }

                    //System.debug('iterating map' );
                    //System.debug(updatedAlertsRef);

                    for( NMS_Alert__c alert : updatedAlertsRef.keySet() ) {
                        System.debug('map of alert' + alert.Id );
                        Id ticketId = updatedAlertsRef.get(alert);
                        CaseComment newComment = new CaseComment();
                        newComment.CommentBody = 'INITIAL ALERT DATA\r\n';
                        newComment.CommentBody += 'AlertTime: ' + alert.CreatedDate + '\r\n';
                        newComment.CommentBody += 'AlertName: ' + alert.Alert_Name__c + '\r\n';
                        newComment.CommentBody += 'AssetIdentifier: ' + alert.Identifier__c + '\r\n';
                        newComment.CommentBody += 'AssetID: ' + alert.Asset__c + '\r\n';
                        newComment.CommentBody += 'IP: ' + alert.IP_Address__c + '\r\n';
                        newComment.CommentBody += 'URL: ' + alert.URL__c + '\r\n';
                        newComment.CommentBody += 'Source: ' + alert.Source__c + '\r\n';
                        newComment.ParentId = ticketId;
                        newComment.IsPublished = FALSE;
                        newCaseComments.add(newComment);
                    }

                    if (newCaseComments != NULL && newCaseComments.size() > 0) {
                        try {
                            insert newCaseComments;
                        } catch (Exception e) {
                            System.debug( 'The Following excedption occured on NMS Alerts Controller when creating case comments: ' + e );
                        }       
                    }



                } catch (Exception e) {
                    System.debug( 'The Following excedption occured on NMS Alerts Controller when creating tickets: ' + e );
                }
            }
                
        }
        return created;

    }





    //get all alerts
    //













    /******************************************************
     * --------| get alert account/order info |--------------
     ******************************************************/  
    /**
     * GetAlertAccountOrderInfo()
     * 
     * gets  account info related to this alert via the passed in service ID or device id, tries to query the order if service id available, if not it tries to get to the asset
     * 
     * @param       identifier       String      the device id passsed from the NMS
     * @param       serviceId       String       the service id passsed from the NMS
     */
    public static Map<String, String> GetAlertAccountOrderInfo( String identifier, String serviceId ) {
        System.debug('identifier = ' + identifier);
        System.debug('serviceId = ' + serviceId);
        
        Map<String, String> returnList = new Map<String, String>();

        Boolean foundSOF = false;
        String outputText = '';

        //check for service
        if( identifier != null || serviceId != null) {
            if (identifier != null) {
                String everstreamCircuitRegEx = '(EVM|EV|1C)[-,/](ETHS|ETHc|COL|DWDM|INT|IRU|CLDS|MDU|ETH)[-,/](O(N|F)|FBR|INT|RES)[-,/][0-9]{5}';
                String tmoCircuitRegEx = '[A-Z]{3}.[0-9]{10}..MI';
                String lumenRegEx = '[A-Z]{2}[-,/][A-Z]{4}[-,/][0-9]{6}[-,/][0-9]{3}[-,/][A-Z]{3}[-,/][0-9]{3}';
                String atntRegEx = '[0-9]{2}[-,/][A-Z]{4}[-,/][0-9]{6}[-,/]{2}[A-Z]{3}';
                String moreEverstreamCircuits = '(VDS3|OC12|FBR|DS3|DIA|10GENNI|10GW|1GE|1GENNI|BDW|DS1).[0-9]{10}..(MI|WI|IL|MN|VA|MA)';
                
                
                List<String> mylist = new List<String>();
                mylist.add(everstreamCircuitRegEx);
                mylist.add(tmoCircuitRegEx);
                mylist.add(lumenRegEx);
                mylist.add(atntRegEx);
                mylist.add(moreEverstreamCircuits);
                
                for( String l : mylist ) {
                    List<String> match = patterMatch(l,identifier);
                    
                    if( match != null && match.size() > 0 ) {
                        outputText += match[0];
                    }
                }
            
                System.debug('outputText = ' + outputText);

                //try service id
                if( outputText != '') {
                    System.debug('Finding SOF by Device ID');
                    String lke = '%'+outputText+'%';
                    Order[] ord = [SELECT AccountId, Account.Name, Dimension_4_Market__c,Id FROM Order WHERE Service_ID__c LIKE :lke AND Status = 'Activated' AND Billing_Start_Date__c != NULL LIMIT 1 ];
                
                    if( ord != null && ord.size() > 0 ) {
                        foundSOF = TRUE;

                        for( Order o : ord ) {
                            returnList.put('accountName', o.Account.Name);
                            //returnList.put('assetId', '');
                            returnList.put('accountId', o.AccountId);
                            returnList.put('sofId', o.Id);
                            returnList.put('market', o.Dimension_4_Market__c);
                            returnList.put('identifier', identifier);
                        }
                    }

                //try device lookup
                } else {
                    System.debug('Finding Asset by Device ID');
                    Asset[] ass = [SELECT AccountId, Account.Name, Id, Service_Order_Agreement__c, Dimension_4_Market__c FROM Asset WHERE Name = :identifier limit 1 ];
                    
                    if( ass != null && ass.size() > 0 ) {
                        for( Asset a: ass ) {
                            if (a.Service_Order_Agreement__c != NULL) {
                                foundSOF = TRUE;
                            }

                            returnList.put('accountName', a.Account.Name);
                            returnList.put('assetId', a.Id);
                            returnList.put('accountId', a.AccountId);
                            returnList.put('sofId', a.Service_Order_Agreement__c);
                            returnList.put('market', a.Dimension_4_Market__c);
                            returnList.put('identifier', identifier);
                        }
                    }
                }
            }

            if (!foundSOF && serviceId != NULL) {
                System.debug('Finding SOF by Service ID');
                Order[] ord = [SELECT AccountId, Account.Name, Dimension_4_Market__c,Id FROM Order WHERE Service_ID__c LIKE :serviceId AND Status = 'Activated' AND Billing_Start_Date__c != NULL LIMIT 1 ];
            
                if( ord != null && ord.size() > 0 ) {
                    for( Order o : ord ) {
                        returnList.put('accountName', o.Account.Name);
                        //returnList.put('assetId', '');
                        returnList.put('accountId', o.AccountId);
                        returnList.put('sofId', o.Id);
                        returnList.put('market', o.Dimension_4_Market__c);
                        returnList.put('identifier', identifier);
                    }
                }
            }
        }

        System.debug(returnList);
        return returnList;

    }



    
    /******************************************************
     * ---------------| regex shit |--------------
     ******************************************************/  
    public static List<String> patterMatch(String patternValue,String text){
        
        Pattern patternObj = Pattern.compile(patternValue);
        Matcher matcher = patternObj.matcher(text);

        List<String> matches = new List<String>();
        while (matcher.find()) {
            String groupValue = matcher.group();
            matches.add(groupValue);
        }
        return matches;
    }
     /*--------------------------------------------------------*/  

    /******************************************************
     * ---------------| Link alert to ticket |--------------
     ******************************************************/  

    @AuraEnabled(cacheable=false)
    global static Boolean LinkAlert( List<Id> alerts,  Id ticketId, Boolean isOutageSent, Boolean isCreateTicket ) {

        Boolean updated = false;

        //Case ticket = [SELECT Id, CaseNumber FROM Case where CaseNumber = :ticketNumber limit 1 ];
        Case ticket = [SELECT Id, CaseNumber FROM Case where Id = :ticketId limit 1 ];
        List<NMS_Alert__c> alertsToUpdate = [select Id, Support_Ticket__c, Acknowledged__c,  open__c, closed__c, ignored__c, ClosedDate__c, Case_URL__c, is_outage__c, Alert_Name__c  from NMS_Alert__c where Id in :alerts];
        

        if(ticket != null ) {
            if(alertsToUpdate!=null && !alertsToUpdate.isEmpty()) {
                for(NMS_Alert__c a : alertsToUpdate ) {
                    a.Support_Ticket__c = ticket.Id;
                } 
                try {
                    System.debug('UPDATEING');
                    //update alertsToUpdate;
                    //updated = true;
                    List<Database.SaveResult> results = Database.update(alertsToUpdate, false);
                    for (Database.SaveResult result : results) {
                        if (result.isSuccess()){
                            System.debug('succeful linked to ticket');
                            updated = true;
                        }
                    }
                } catch (Exception e) {
                    System.debug( 'The Following excedption occured on NMS Alerts Controller when acknologing an alert: ' + e );
                }            
            }
        } 
        if(updated) {
            for(NMS_Alert__c a : alertsToUpdate) {
                Date alertDate;
                if(a.ClosedDate__c != null) {
                    alertDate = a.ClosedDate__c.date();
                }


                if(!isCreateTicket) {
                    String caseUrl = URL.getSalesforceBaseUrl().toExternalForm() + '/' + ticketId;
                    getrefreshEveryonesScreens(a.Id, a.Acknowledged__c, caseUrl, alertDate, a.ignored__c, a.open__c, a.Support_Ticket__c, a.closed__c, 'linked ticket(s) ' + a.Alert_Name__c, 'linkTicket', isOutageSent );
                } 
                
            }
        }

        return updated;



    }
    /*--------------------------------------------------------*/          







    /******************************************************
     * ---------------| create outage ticket |--------------
     ******************************************************/  
    @AuraEnabled(cacheable=false)
    global static Boolean createAlertOutageTicket( List<Id> alerts, String Subject, String Description ) {
        //System.debug(alerts);
        //System.debug(Subject);
        //System.debug(Description);
        String ParentTicketID = '';
        try {
            Case parentticket = new Case();
            parentticket.RecordTypeId = '012U0000000DpFKIA0';
            parentticket.Type__c = 'Outage';
            parentticket.Origin = 'Proactive';
            //parentticket.Request_Type__c = 'Support';
            parentticket.NOC_Ticket_Assigment__c = 'NOC I';
            parentticket.subject = Subject;
            parentticket.Origin ='Proactive';
            parentticket.Description = Description;

            insert parentticket;

            if( parentticket.Id != null ) {
                System.debug('created parent ticket' + parentticket.Id);
                ParentTicketID = parentticket.Id;
                System.debug('ParentTicketID' + ParentTicketID);
            }


        } catch (Exception e) {
            System.debug( 'The Following excedption occured on NMS Alerts Controller creating outage' + e );  
        }          


        Boolean createdTicket = false;
        Boolean updatedAlerts = false;
        String Type = 'outage';


        List<NMS_Alert__c> alertsFromFrontEnd = [select Id, Alert_Name__c, Device_ID__c, Support_Ticket__c, Service_ID__c, Acknowledged__c,  open__c, closed__c, ignored__c, ClosedDate__c, Case_URL__c, is_outage__c from NMS_Alert__c WHERE  Id  in :alerts];
        
        List<Case> ticketsToCreate = new List<Case>();
        Map<Id, Id> alertsToUpdateMaps = new Map<Id, Id>();
        List<NMS_Alert__c> updatedAlertsList = new List<NMS_Alert__c>();
        
        //crate parent ticket
        
        //create ticket and add to create ticket list
        if(alertsFromFrontEnd!=null && !alertsFromFrontEnd.isEmpty()) {
            for( NMS_Alert__c a : alertsFromFrontEnd ) {

                Map<String, String> t = GetAlertAccountOrderInfo(a.Device_ID__c, a.Service_ID__c); 

                //init some vars
                String accountId;
                String accountName;
                String assetId;
                String sofId;
                String market;
                String identifier;

                //set vars from map values of GetAlertAccountOrderInfo
                if(t != null && t.size() > 0 ) {
                    accountId = t.get('accountId');
                    accountName = t.get('accountName');
                    assetId = t.get('assetId');
                    sofId = t.get('sofId');
                    market = t.get('market');
                    identifier = t.get('identifier');        
                }


                Case ticket = new Case();
                ticket.RecordTypeId = 	'012U0000000DpFKIA0';
                ticket.Type__c = 'Outage';
                ticket.Origin = 'Proactive';
                //ticket.Request_Type__c = 'Support';
                ticket.NOC_Ticket_Assigment__c = 'NOC I';
                ticket.subject = '' + market + '|' + accountName + '|' + a.Alert_Name__c + '';
                ticket.Origin ='Proactive';
                ticket.Description = Description;
                ticket.AlertID__c = a.Id;
                ticket.ParentId = ParentTicketID;
                ticket.Related_Service_Order__c = sofId;
                ticketsToCreate.add(ticket);
            }
        }
        
        //insert the ticket
        if( ticketsToCreate != null && !ticketsToCreate.isEmpty()) {
            try {    
                System.debug('insert the ticket');
                Database.SaveResult[] results = Database.insert(ticketsToCreate, false);
                for (Database.SaveResult result : results) {   
                    if (result.isSuccess()) {
                           System.debug('case Successfully inserted, case Id is: ' + result.getId());
                        createdTicket = true;
                    } else {
                        for(Database.Error error : result.getErrors()) {
                            System.debug(error.getStatusCode() + ': ' + error.getMessage() + ' Fields that affected the error: ' + error.getFields());
                        }  
                        createdTicket = false;
                        //create error record;
                        return false;
                    }
                }
                if(createdTicket) {
                    for( case c : ticketsToCreate ) {
                        alertsToUpdateMaps.put(c.AlertID__c, c.Id);
                    }
                }
            } catch (Exception e) {
                System.debug( 'The Following excedption occured on NMS Alerts Controller creating outage' + e );  
            }  
        }

        //[{alertid, caseid},]
        
        //update the alerts
        //if(alertsToUpdateMaps?.size() > 0 ) {
        if (alertsToUpdateMaps != null || !alertsToUpdateMaps.isEmpty()) {

            //System.debug(alertsToUpdateMaps);
            List<NMS_Alert__c> alertsToUpdate = [select Id, Support_Ticket__c, Acknowledged__c, Service_ID__c, open__c, closed__c, ignored__c, ClosedDate__c, Case_URL__c, is_outage__c, Service_Order_Agreement__c, Outage_Support_Ticket__c, Device_ID__c  from NMS_Alert__c where Id in :alertsToUpdateMaps.keySet()];
            //System.debug(alertsToUpdate);
            
            if( alertsToUpdate != null && alertsToUpdate.size() > 0 ) {


                    try {
                        //set the alert fields
                        for( NMS_Alert__c a : alertsToUpdate ) {



                            // get account info from alert by id, see GetAlertAccountOrderInfo() below
                            Map<String, String> t = GetAlertAccountOrderInfo(a.Device_ID__c, a.Service_ID__c); 

                            //init some vars
                            String accountId;
                            String accountName;
                            String assetId;
                            String sofId;
                            String market;
                            String identifier;

                            //set vars from map values of GetAlertAccountOrderInfo
                            if(t != null && t.size() > 0 ) {
                                accountId = t.get('accountId');
                                accountName = t.get('accountName');
                                assetId = t.get('assetId');
                                sofId = t.get('sofId');
                                market = t.get('market');
                                identifier = t.get('identifier');        
                            }

                            System.debug('***********accountId = ' + accountId);
                            System.debug('***********accountName = ' + accountName);
                            System.debug('***********assetId = ' + assetId);
                            System.debug('***********sofId = ' + sofId);
                            System.debug('***********market = ' + market);
                            System.debug('***********identifier = ' + identifier);


                            //id of ticket
                            Id ticket = alertsToUpdateMaps.get(a.Id);
                            //System.debug(alertsToUpdateMaps.get(a.Id));
                            a.Acknowledged__c = true;
                            a.Outage_Support_Ticket__c = ticket;
                            a.Support_Ticket__c = ticket;
                            a.Service_Order_Agreement__c = sofId;
                        }


                        List<Database.SaveResult> results = Database.update(alertsToUpdate, false);
                        for (Database.SaveResult result : results) {
                            if (result.isSuccess()) {
                                //Successfully inserted
                                //Handle insertion
                                System.debug('Successfully updated alert: ' + result.getId());
                                updatedAlerts = true;
                            } else {
                                //Error ecountered              
                                for(Database.Error error : result.getErrors()) {
                                    //Handle error
                                     System.debug(error.getStatusCode() + ': ' + error.getMessage() + ' Fields that affected the error: ' + error.getFields());
                                }
                                updatedAlerts = false;
                                //create error record;
                                return false;                        
                            }
                        } 
                        
                        for( NMS_Alert__c a : alertsToUpdate ) {
                            updatedAlertsList.add(a);
                        }
                        
                        
                    } catch (Exception e) {
                        System.debug( 'The Following excedption occured on NMS Alerts Controller creating outage' + e );  
                    }        
            }
             
        }
        //sned platform
        if(updatedAlerts && createdTicket && updatedAlertsList != null && updatedAlertsList.size() > 0) {
            for(NMS_Alert__c a : updatedAlertsList) {
                Formula.recalculateFormulas(new List<NMS_Alert__c> { a });
                Date alertDate;
                
                if(a.ClosedDate__c != null) {
                    alertDate = a.ClosedDate__c.date();
                }
                getrefreshEveryonesScreens(a.Id, a.Acknowledged__c, a.Case_URL__c, alertDate, a.ignored__c, a.open__c, a.Support_Ticket__c, a.closed__c, 'initiated an outage ' + a.Id, type, true );
            }
            return true;

        } else {
            return false;
        }
    }
    /*--------------------------------------------------------*/     



    
    /******************************************************
     * ---------------| create outage ticket |--------------
     ******************************************************/  
   /* @AuraEnabled(cacheable=false)
    global static Boolean createAlertOutageTicketBack( List<Id> alerts, String Subject, String Description ) {
        System.debug(alerts);
        System.debug(Subject);
        System.debug(Description);

        Boolean createdTicket = false;
        Boolean updatedAlerts = false;
        String Type = 'outage';
    

        List<Case> ticketsToCreate = new List<Case>();
        List<NMS_Alert__c> alertsToUpdate = [select Id, Support_Ticket__c, Acknowledged__c,  open__c, closed__c, ignored__c, ClosedDate__c, Case_URL__c, is_outage__c  from NMS_Alert__c where Id in :alerts];

        
        if(alerts!=null && !alerts.isEmpty()) {

            Case ticket = new Case();
            ticket.RecordTypeId = 	'012U0000000DpFKIA0';
            ticket.Type__c = 'Outage';
            ticket.Origin = 'Proactive';
            ticket.Request_Type__c = 'Support';
            ticket.NOC_Ticket_Assigment__c = 'NOC I';
            ticket.OwnerId = '00GU0000001x9owMAA';
            ticket.subject = Subject;
            ticket.Origin ='Proactive';
            ticket.Description = Description;

            ticketsToCreate.add(ticket);

        }

        if( ticketsToCreate != null && !ticketsToCreate.isEmpty()) {
            try {

                insert ticketsToCreate;

                if( ticketsToCreate != null && ticketsToCreate.size() > 0 ) {
                    for( Case c : ticketsToCreate) {
                        System.debug('created ticket:' + c.Id );

                        for(NMS_Alert__c a : alertsToUpdate) {
                            a.Support_Ticket__c = c.Id;
    
                        }
                        createdTicket = true;
                    }
                    System.debug('UPDATEING');
                    List<Database.SaveResult> results = Database.update(alertsToUpdate, false);
                    for (Database.SaveResult result : results) {
                        if (result.isSuccess()){
                            System.debug('succeful save alert');
                            updatedAlerts = true;
                        }
                    }
                }
                
            } catch (Exception e) {
                System.debug( 'The Following excedption occured on NMS Alerts Controller creating outage' + e );
            }
        }

        

        if(updatedAlerts && createdTicket) {
            for(NMS_Alert__c a : alertsToUpdate) {
                Date alertDate;
                if(a.ClosedDate__c != null) {
                    alertDate = a.ClosedDate__c.date();
                }
                getrefreshEveryonesScreens(a.Id, a.Acknowledged__c, a.Case_URL__c, alertDate, a.ignored__c, a.open__c, a.Support_Ticket__c, a.closed__c, 'initiated an outage ' + a.Id, type, true );
                //( String alertId, Boolean Acknowledged, String CaseURL, Date ClosedDate, Boolean ignored, Boolean open, String SupportTicket, Boolean closed, String action)
            }
            return true;

        } else {
            return false;
        }

    }*/
    /*--------------------------------------------------------*/     







    


    
    /******************************************************
     * --------| update single alert from action |--------------
     ******************************************************/  
    /**
     * getrefreshEveryonesScreens()
     * 
     * when an alert has an action occur like open, close, upon succesfull save this method is called which creates a platform event to update all screens showing the nms alert manager
     * 
     * @param { alertId        String      Id of the alert }  
     * @param { Acknowledged    Boolean     Checkbox if alert is acknowledged }  
     * @param { CaseURL         String      URL of the case associated with the alert }  
     * @param { ClosedDate      Date        Close date of the alert }  
     * @param { ignored         Boolean     is alert ignored }  
     * @param { open            Boolean     Is alert open }  
     * @param { SupportTicket   String      Support ticket Id related }  
     * @param { closed          Boolean     Is alert closed }  
     * @param { action          String      Long text area or message describing the action taken place, for the toast alert }  
     */

    @AuraEnabled(cacheable=false)
    public static Boolean getrefreshEveryonesScreens( String alertId, Boolean Acknowledged, String CaseURL, Date ClosedDate, Boolean ignored, Boolean open, String SupportTicket, Boolean closed, String action, String type, Boolean is_outage ) {

        //pseter noc with a message
        //NMS_alerts_controller.getrefreshEveryonesScreens('aGW2300000007h2GAA', true, '', system.today(), false, false, '', false, 'This is a toast message that pops up on the nms alert manager page' );
        //with great power comes great responsibility
        //NMS_alerts_controller.getrefreshEveryonesScreens('aGWR00000008Rr8OAE', false, 'https://everstream--uat.sandbox.lightning.force.com/lightning/r/Case/500R000000FI8fvIAD/view', system.today(), false, false, '00552964', false, 'hello', 'outage', true );
            String newActionMessage = UserInfo.getFirstName() + ' ' + UserInfo.getLastName() + ' ' + action;

          List<nmsAction__e> inkEvents = new List<nmsAction__e>();
          inkEvents.add(new nmsAction__e(Id__c=alertId, Acknowledged__c = Acknowledged, Case_URL__c = CaseURL, ClosedDate_c__c = ClosedDate, ignored__c = ignored, open__c = open, Support_Ticket__c = SupportTicket, closed__c = closed, action__c = newActionMessage, Type__c = type, is_outage__c = is_outage ));




          PlatformEventListner eventListener = new PlatformEventListner();
          EventBus.publish(inkEvents, eventListener);






            // Call method to publish events
          //List<Database.SaveResult> results = EventBus.publish(inkEvents);
          
            // Inspect publishing result for each event
           /* for (Database.SaveResult sr : results) {
                if (sr.isSuccess()) {
                    System.debug('Successfully published event.');
                } else {
                    for(Database.Error err : sr.getErrors()) {
                        System.debug('Error returned: ' +
                                    err.getStatusCode() +
                                    ' - ' +
                                    err.getMessage());
                    }
                }       
            }     */
    
        return true;
    }





    /******************************************************
     * ---------------| Bulk Shit |--------------
     ******************************************************/  
    /**
     * BulkAction();
     * 
     * Pass in a list of alert Ids and an action such as acknowledge, unacknowlege, ignore, open, close
     * 
    */
/*    List<Id> i = new List<Id>();
    i.add('aGWR00000008Rlt');
    NMS_alerts_controller.BulkAction('acknowledge', i );*/
    @AuraEnabled(cacheable=false)
    global static Boolean BulkAction( String action, List<Id> accArray ) {

        Boolean updated = false;
        List<NMS_Alert__c> alertsToUpdate = [select Id, Status__c, Support_Ticket__c, Acknowledged__c,  open__c, closed__c, ignored__c, ClosedDate__c, Case_URL__c, is_outage__c, Alert_Name__c  from NMS_Alert__c where Id in :accArray];

        List<Id> openIDs = new List<Id>();
        List<Id> closedIDs = new List<Id>();
        List<Id> ignoredIDs = new List<Id>();


        String type;
        switch on action {
            when 'acknowledge'  {
                System.debug('acknowledge alerts');
                if(alertsToUpdate!=null && !alertsToUpdate.isEmpty()) {
                    for(NMS_Alert__c a : alertsToUpdate ) {
                        a.Acknowledged__c = true;
                        type = 'acknowledged';
                    }
                }
            }
            when 'unacknowledge'  {
                System.debug('unacknowledge alerts');
                if(alertsToUpdate!=null && !alertsToUpdate.isEmpty()) {
                    for(NMS_Alert__c a : alertsToUpdate ) {
                        a.Acknowledged__c = false;
                        type = 'unacknowledged';
                    }
                }
            } 
            when 'open'  {
                System.debug('open alerts');
                if(alertsToUpdate!=null && !alertsToUpdate.isEmpty()) {
                    for(NMS_Alert__c a : alertsToUpdate ) {
                        a.Status__c = 'Open';
                        openIDs.add(a.Id);
                        type = 'open';
                    }
                }                
            }
            when 'close'  {
                if(alertsToUpdate!=null && !alertsToUpdate.isEmpty()) {
                    for(NMS_Alert__c a : alertsToUpdate ) {
                        //a.open__c = false;
                        //a.closed__c = true;
                        a.Status__c = 'Closed';
                        closedIDs.add(a.Id);
                        type = 'close';
                    }
                }     
            } 
            when 'ignore'  {
                System.debug('ignore alerts');
                if(alertsToUpdate!=null && !alertsToUpdate.isEmpty()) {
                    for(NMS_Alert__c a : alertsToUpdate ) {
                        //a.ignored__c = true;
                        a.Status__c = 'Ignored';
                        ignoredIDs.add(a.Id);
                        type = 'ignore';
                    }
                }                  
            }
        }


        if(alertsToUpdate!=null && !alertsToUpdate.isEmpty()) {
            try {
                System.debug('UPDATEING');
                List<Database.SaveResult> results = Database.update(alertsToUpdate, false);
                for (Database.SaveResult result : results) {
                    if (result.isSuccess()){
                        System.debug(result);
                        updated = true;
                    }
                }
            } catch (Exception e) {
                System.debug( 'The Following excedption occured on NMS Alerts Controller when acknologing an alert: ' + e );
            }
        }

        if(updated) {



            for(NMS_Alert__c a : alertsToUpdate) {

                Date alertDate;
                 if(a.ClosedDate__c != null) {
                     alertDate = a.ClosedDate__c.date();
                 }


                 switch on type {
                    when  'open' {
                        getrefreshEveryonesScreens(a.Id, a.Acknowledged__c, a.Case_URL__c, alertDate, false, true, a.Support_Ticket__c, false, '' + action + 'd Alert ' + a.Alert_Name__c, type, a.is_outage__c );
                    }
                    when  'close' {
                        getrefreshEveryonesScreens(a.Id, a.Acknowledged__c, a.Case_URL__c, alertDate, false, false, a.Support_Ticket__c, true, '' + action + 'd Alert ' + a.Alert_Name__c, type, a.is_outage__c );
                    }
                    when  'ignore' {
                        getrefreshEveryonesScreens(a.Id, a.Acknowledged__c, a.Case_URL__c, alertDate, true, false, a.Support_Ticket__c, false, '' + action + 'd Alert ' + a.Alert_Name__c, type, a.is_outage__c );
                    }
                    when else {
                        getrefreshEveryonesScreens(a.Id, a.Acknowledged__c, a.Case_URL__c, alertDate, a.ignored__c, a.open__c, a.Support_Ticket__c, a.closed__c, '' + action + 'd Alert ' + a.Alert_Name__c, type, a.is_outage__c );
                    }

                 }

            }



        }
       

        return updated;
    }


    /*--------------------------------------------------------*/    


    

    @AuraEnabled(cacheable=true)
    global static String getOrgURL(  ) {
        String prefix = URL.getSalesforceBaseURL().toExternalForm().replace('https://', '').split('\\.')[0];
        prefix = prefix.removeEnd('--c');
        return 'https://' + prefix.toLowerCase() + '.lightning.force.com/lightning/n/NMS_Alerts';

    } 



    @AuraEnabled(cacheable=true)
    global static String getOrgBaseURL(  ) {
        String prefix = URL.getSalesforceBaseURL().toExternalForm().replace('https://', '').split('\\.')[0];
        prefix = prefix.removeEnd('--c');
        return 'https://' + prefix.toLowerCase() + '.lightning.force.com';

    } 




    @AuraEnabled(cacheable=false)
    global static Map<String,String> getCurrentUserSavedPreferences() {
        //set return
        Map<String,String> prefernces = new  Map<String,String>();
        NMS_Manager_Preference__c[] GetPrefs = [SELECT ID, Pinned_Source_Filter__c, Pinned_Open_Close_Filter__c FROM NMS_Manager_Preference__c WHERE User__c = :UserInfo.getUserId()];

        if( GetPrefs != null && GetPrefs.size() > 0 ) {
            //System.debug(GetPrefs[0].Pinned_Source_Filter__c);
            for(NMS_Manager_Preference__c p : GetPrefs) {
                //System.debug(p.Pinned_Source_Filter__c);
                prefernces.put('URL', NMS_alerts_controller.getOrgBaseURL() + '/' + p.Id);
                prefernces.put('SourceFilter',p.Pinned_Source_Filter__c);
                prefernces.put('OpenCloseFilter',p.Pinned_Open_Close_Filter__c);
            } 
        }
        return prefernces;
    }



    @AuraEnabled(cacheable=false)
    global static Boolean setCurrentUserSavedPreferences() {
        //set return
        Boolean updated = false;


        return updated;
    }






    @AuraEnabled(cacheable=false)
    global static String getCurrentUserPinnedFilter() {
        String pinnedValue = 'All';
        NMS_Manager_Preference__c[] pref = [SELECT ID, Pinned_Source_Filter__c FROM NMS_Manager_Preference__c WHERE User__c = :UserInfo.getUserId()];
        if (pref != NULL && pref.size() > 0) {
            pinnedValue = pref[0].Pinned_Source_Filter__c;
        }

        return pinnedValue;
    }



    @AuraEnabled(cacheable=false)
    global static Boolean setCurrentUserPinnedFilter(String filterval) {
        Boolean updated = false;
        NMS_Manager_Preference__c[] pref = [SELECT ID, Pinned_Source_Filter__c FROM NMS_Manager_Preference__c WHERE User__c = :UserInfo.getUserId()];
        if (pref != NULL && pref.size() > 0) {
            pref[0].Pinned_Source_Filter__c = filterval;
            try {

                System.debug('updated pinned list for: ' + UserInfo.getUserId());
                update pref[0];

                updated = true;
            } catch (Exception e) {
                System.debug( 'The Following excedption occured on NMS Alerts Controller when creating a NMS_Manager_Preference__c record ' + e );
            }
            

            
            updated = true;
        } else {
            NMS_Manager_Preference__c  nm = new NMS_Manager_Preference__c();
            nm.Pinned_Source_Filter__c = filterval;
            nm.User__c = UserInfo.getUserId();

            try {
                insert nm;
                System.debug('created pinned list for: ' + UserInfo.getUserId());
                updated = true;
            } catch (Exception e) {
                System.debug( 'The Following excedption occured on NMS Alerts Controller when creating a NMS_Manager_Preference__c record ' + e );
            }
            
        }


        
        return updated;
    }







    @AuraEnabled(cacheable=false)
    global static Boolean setCurrentUserFilters(String filterval, String OpenCloseFilterVal) {
        Boolean updated = false;
        NMS_Manager_Preference__c[] pref = [SELECT ID, Pinned_Source_Filter__c FROM NMS_Manager_Preference__c WHERE User__c = :UserInfo.getUserId()];
        if (pref != NULL && pref.size() > 0) {
            pref[0].Pinned_Source_Filter__c = filterval;
            pref[0].Pinned_Open_Close_Filter__c = OpenCloseFilterVal;

            try {

                System.debug('updated pinned list for: ' + UserInfo.getUserId());
                update pref[0];

                updated = true;
            } catch (Exception e) {
                System.debug( 'The Following excedption occured on NMS Alerts Controller when creating a NMS_Manager_Preference__c record ' + e );
            }
            
        } else {
            NMS_Manager_Preference__c  nm = new NMS_Manager_Preference__c();
            nm.Pinned_Source_Filter__c = filterval;
            nm.Pinned_Open_Close_Filter__c = OpenCloseFilterVal;
            nm.User__c = UserInfo.getUserId();

            try {
                insert nm;
                System.debug('created pinned list for: ' + UserInfo.getUserId());
                updated = true;
            } catch (Exception e) {
                System.debug( 'The Following excedption occured on NMS Alerts Controller when creating a NMS_Manager_Preference__c record ' + e );
            }
        }
        return updated;
    }




}