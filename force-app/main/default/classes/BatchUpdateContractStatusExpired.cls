/*
 Description : This Batch class is Scheduled to run on 1st of Every Month at 12.00 AM PST to update the Status
               of Contract which are activated and has endDate before SystemDate on 1st of every month on the
                Date of this Batch Run.
               
 Author      : Ramana 

 Created Date: 07/30/2020
*/
global class BatchUpdateContractStatusExpired implements Database.Batchable<sObject> {
    List<String> contractIds=new List<String>();
    global BatchUpdateContractStatusExpired(List<String> contractIds){
        this.contractIds= contractIds;
    }

    global database.QueryLocator Start(database.BatchableContext bc){
        Date todayDate =System.today();
        String query ='SELECT id ,Status FROM Contract where Status=\'Activated\' and Enddate<:todayDate'; 
       if(contractIds!=null && !contractIds.IsEmpty())
          query=query+' and Id IN :contractIds';
        RETURN database.getQueryLocator(query);
    }
    global void execute(Database.BatchableContext bc, List<Contract> con){
        for(Contract c:con){
         
            c.Status='Expired';
            
        }
        UPDATE con;
        
    }
    global void finish(database.BatchableContext bc){
        
    AsyncApexJob job=[select id,JobItemsProcessed,Completeddate ,status,NumberOfErrors FROM AsyncApexJob where Id=:bc.getJobId()];
    Messaging.SingleEmailMessage msg = new Messaging.SingleEmailMessage();
    String[] toadd = new String[]{'planetddscpq@demandblue.com'};	  	
    msg.setSubject('Batch Operation for Contracts Expiration '+job.Status);
    msg.setToAddresses(toadd);
    msg.setPlainTextBody('The Batch Apex job processed '+job.JobItemsProcessed+' Items with '+job.NumberOfErrors+' Errors');
    msg.setSenderDisplayName('System Admin');
    List<Messaging.SingleEmailMessage> emails =new List<Messaging.SingleEmailMessage>{msg};
    Messaging.sendEmail(emails);

    }
}