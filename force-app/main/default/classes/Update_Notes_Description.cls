// ---> Batch class to Populate Account Notes and Description to all related Open Opportunities.

//---->Author: Ramana 

//---->Date : 30/04/2020

Public class Update_Notes_Description implements Database.Batchable<sObject> {
    Public List<string> opportunityIds =new List<Id>();
    Public Update_Notes_Description(List<String> opportunityIds){
        this.opportunityIds= opportunityIds;
    }

    public database.QueryLocator Start(database.BatchableContext bc){
        String query ='SELECT Account.Notes__c,Account.Description,DDS_Notes__c,DDS_Description__c from Opportunity  Where Stagename!=\'Closed Won\' and Stagename!=\'Closed Lost\' and  Stagename!=\'AutoWithdrawn\''; 
        if(opportunityIds!=null && !opportunityIds.IsEmpty())
          query=query+' and Id IN :opportunityIds';
        
        RETURN database.getQueryLocator(query);
    }
    public void execute(Database.BatchableContext bc, List<Opportunity> opp){
        for(Opportunity o:opp){
            if(o.Account.Description!=null && o.Account.Description!=''){
                o.DDS_Description__c=o.Account.Description;
            }
            if(o.Account.Notes__c!=null && o.Account.Notes__c!=''){
                o.DDS_Notes__c= o.Account.Notes__c;
            }
            
        }
        UPDATE opp;
        
    }
    public void finish(database.BatchableContext bc){}
}