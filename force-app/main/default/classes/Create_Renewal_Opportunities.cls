/*
 Description : This Batch class is Scheduled to run on 3rd of Every Month at 12.00 AM PST to update Renewal Forecast to True to
               Create Renewal Opportunities and Renewal Uplift to 4% for Historical Contracts which are activated and Ending 
               in the Current Month.
               
 Author      : Ramana 

 Created Date: 07/17/2020
*/
global class Create_Renewal_Opportunities implements Database.Batchable<sObject> {
    List<String> contractIds=new List<String>();
    global Create_Renewal_Opportunities(List<String> contractIds){
        this.contractIds= contractIds;
    }

    global database.QueryLocator Start(database.BatchableContext bc){ 
        String query ='SELECT id ,Status,SBQQ__RenewalForecast__c,SBQQ__RenewalUpliftRate__c   FROM Contract where SBQQ__Opportunity__c =NULL and Current_Month__c =true  and  SBQQ__RenewalForecast__c = false AND Do_Not_Renew__c = False  and Status=\'Activated\''; 
       if(contractIds!=null && !contractIds.IsEmpty())
          query=query+' and Id IN :contractIds';
        RETURN database.getQueryLocator(query);
    }
    global void execute(Database.BatchableContext bc, List<Contract> con){
        for(Contract c:con){
            
             c.SBQQ__RenewalForecast__c = true;
            if(c.SBQQ__RenewalUpliftRate__c==NULL){
                
            c.SBQQ__RenewalUpliftRate__c = 4;
                
             }
            
        }
        UPDATE con;
        
    }
    global void finish(database.BatchableContext bc){
        
    AsyncApexJob job=[select id,JobItemsProcessed,Completeddate ,status,NumberOfErrors FROM AsyncApexJob where Id=:bc.getJobId()];
    Messaging.SingleEmailMessage msg = new Messaging.SingleEmailMessage();
    String[] toadd = new String[]{'planetddscpq@demandblue.com'};	  	
    msg.setSubject('Batch Operation for Creating Opportunities '+job.Status);
    msg.setToAddresses(toadd);
    msg.setPlainTextBody('The Batch Apex job processed '+job.JobItemsProcessed+'Items with '+job.NumberOfErrors+' Errors');
    msg.setSenderDisplayName('System Admin');
    List<Messaging.SingleEmailMessage> emails =new List<Messaging.SingleEmailMessage>{msg};
    Messaging.sendEmail(emails);
        
       // database.executeBatch(new Create_Renewal_Quotes(new List<String>()),1);
    }
}