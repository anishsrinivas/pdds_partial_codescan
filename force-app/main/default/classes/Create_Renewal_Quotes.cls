/*
 Description : This Batch class is Scheduled to run on 3rd of Every Month at 4.00 AM PST to update Renewal Quoted To True 
               for Contracts which are activated and Ending in the Current Month and has Renewals Opportunities 
               Created.
                              
 Author      : Ramana 

 Created Date: 07/17/2020
*/

global class Create_Renewal_Quotes implements Database.Batchable<sObject> {
    List<String> contractIds=new List<String>();
    global Create_Renewal_Quotes(List<String> contractIds){
        this.contractIds= contractIds;
    }

    global database.QueryLocator Start(database.BatchableContext bc){
        String query ='SELECT id ,SBQQ__RenewalQuoted__c FROM Contract where Current_Month__c =true and SBQQ__RenewalOpportunity__c !=NULL and SBQQ__RenewalQuoted__c =false and Status=\'Activated\''; 
       if(contractIds!=null && !contractIds.IsEmpty())
          query=query+' and Id IN :contractIds';
        RETURN database.getQueryLocator(query);
    }
    global void execute(Database.BatchableContext bc, List<Contract> con){
        for(Contract c:con){
            

                c.SBQQ__RenewalQuoted__c = true;

        }
        UPDATE con;
        
    }
    global void finish(database.BatchableContext bc){
        
    AsyncApexJob job=[select id,JobItemsProcessed,Completeddate ,status,NumberOfErrors FROM AsyncApexJob where Id=:bc.getJobId()];
    Messaging.SingleEmailMessage msg = new Messaging.SingleEmailMessage();
    String[] toadd = new String[]{'planetddscpq@demandblue.com'};	  	
    msg.setSubject('Batch Operation for Creating Renewals Quotes '+job.Status);
    msg.setToAddresses(toadd);
    msg.setPlainTextBody('The Batch Apex job processed '+job.JobItemsProcessed+' items with '+job.NumberOfErrors+' Errors');
    msg.setSenderDisplayName('System Admin');
    List<Messaging.SingleEmailMessage> emails =new List<Messaging.SingleEmailMessage>{msg};
    Messaging.sendEmail(emails);
        
    }

}