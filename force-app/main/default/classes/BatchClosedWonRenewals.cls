/*
 Description : This Batch class is Scheduled to run on last day of Every Month at 11.30 PM PST to Close Won
               the Open Renewal Opportunities 
               
 Author      : Ramana 

 Created Date: 08/17/2020
*/
global class BatchClosedWonRenewals implements Database.Batchable<sObject> {
     List<string> opportunityIds =new List<string>();
    global BatchClosedWonRenewals(List<String> opportunityIds){
        this.opportunityIds= opportunityIds;
    }

    global database.QueryLocator Start(database.BatchableContext bc){
        String query ='SELECT Id,StageName from Opportunity  Where SBQQ__Renewal__c = true and SBQQ__PrimaryQuote__c!=Null and DDS_ProductCount__c !=0 and Stagename!=\'Closed Won\' and Stagename!=\'Closed Lost\' and  Stagename!=\'AutoWithdrawn\''; 
        if(opportunityIds!=null && !opportunityIds.IsEmpty())
          query=query+' and Id IN :opportunityIds';
        
        RETURN database.getQueryLocator(query);
    }
    global void execute(Database.BatchableContext bc, List<Opportunity> opp){
        for(Opportunity o:opp){
            
                o.StageName='Closed Won';
            
        }
        UPDATE opp;
        
    }
    global void finish(database.BatchableContext bc){
        
        
    }
}