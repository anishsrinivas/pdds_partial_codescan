// ---> Batch class to Copy Amount to 'Old MRR amount'  for all closed Won Opportunities.

//---->Author: Ramana 

//---->Date : 19/05/2020
Public class Update_Old_MRR_Amount implements Database.Batchable<sObject> {
    Public List<string> opportunityIds =new List<Id>();
    Public Update_Old_MRR_Amount(List<String> opportunityIds){
        this.opportunityIds= opportunityIds;
    }

    public database.QueryLocator Start(database.BatchableContext bc){
        String query ='SELECT Amount,Old_MRR_amount__c from Opportunity  Where Stagename=\'Closed Won\''; 
        if(opportunityIds!=null && !opportunityIds.IsEmpty())
          query=query+' and Id IN :opportunityIds';
        
        RETURN database.getQueryLocator(query);
    }
    public void execute(Database.BatchableContext bc, List<Opportunity> opp){
        for(Opportunity o:opp){
            if(o.Amount!=null){
                o.Old_MRR_amount__c=o.Amount;
            
                  }
             }
        UPDATE opp;
        
   
    }
    public void finish(database.BatchableContext bc){}
}