/*******************************************************************************************
* @author           Demandblue
* @version          1.0 
* @Status           Completed
* @Class Name       UpdateAutoWithDrawBatch
* @Dependent        UpdateAutoWithDrawSchedulable,UpdateAutoWithDrawBatchTest
* @description      This class return for update the value as Autowithdraw in opportunity if it is inactive for more than 30days. 
*********************************************************************************************
Version     Date        Team       	Comments
*********************************************************************************************
* 1    	26-NOV-2019	  Demandblue   Initial created 
*********************************************************************************************/


global class UpdateAutoWithDrawBatch implements Database.Batchable<sObject> {
    
    string query;
    List<Opportunity> Opplist1 = new List<Opportunity>();
    
    global Database.querylocator start(Database.BatchableContext BC){
        string Role = 'BDR';
        string Stage= 'Investigating';
        string Stage1= 'Demo completed';
     
        Integer numbers = Integer.valueOf(system.label.LastModifiedDate);
        system.debug('numbers ---> '+numbers);
        //Query to get the inactive opportunity reocrd for update 
        //Query = 'SELECT Id, Name,StageName, LastModifiedDate,LastActivityDate,Last_Activity_Count__c,Last_Modified_Count__c,CreatedBy.UserRole.Name FROM opportunity Where CreatedBy.UserRole.Name = \'BDR\' AND (StageName = \'Stage\' OR StageName = \'Stage1\') AND Last_Activity_Count__c >= '+numbers+' and Last_Modified_Count__c >= '+numbers;
        Query = 'SELECT Id, Name,StageName, LastModifiedDate,LastActivityDate,Last_Activity_Count__c,Last_Modified_Count__c,CreatedBy.UserRole.Name FROM opportunity Where CreatedBy.UserRole.Name = \'BDR\' AND (StageName = \'Investigating\' OR StageName = \'Demo completed\') AND Last_Activity_Count__c >= '+numbers+' and Last_Modified_Count__c >= '+numbers;
        system.debug('Query--> '+Query);
        return Database.getQueryLocator(Query);
    }
    
    global void execute(Database.BatchableContext BC, List<Opportunity> oppList){
        system.debug('@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@'+oppList);
        List<Opportunity> Opplistrec = new List<Opportunity>();
        
        if(!oppList.isEmpty())
        {
            for(Opportunity p : oppList){
                system.debug('@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@'+p.StageName);    
                //Updating the record.
                p.StageName = 'AutoWithdrawn';
                Opplistrec.add(p);
            }
            if(!Opplistrec.isEmpty()){
                Update Opplistrec;
            }
        }
        
    }
    
    global void finish(Database.BatchableContext BC){
    }
}