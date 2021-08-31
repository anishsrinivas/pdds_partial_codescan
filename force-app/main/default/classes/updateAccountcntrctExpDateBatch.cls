/*******************************************************************************************
* @author           Demandblue
* @version          1.0 
* @Status           Development Completed
* @description      This schedule class is used  to process accountcontract records. 
*********************************************************************************************
Version    	Date        	Team    	Comments
*********************************************************************************************
* 1    		13 Jan 2020    	Pradeep    	Initial Development 
*********************************************************************************************/
global class updateAccountcntrctExpDateBatch implements Database.Batchable<sObject> {
    
    global Database.QueryLocator start(Database.BatchableContext bc)
    {
        string contractStatus = 'Activated';
        Date todaysdate=Date.today();
        
        string query ='SELECT id,startDate,AccountId  FROM contract  WHERE Status=:contractStatus AND startDate=:todaysdate AND  AccountId != null';
        system.debug('test'+database.getQueryLocator(query));
        return database.getQueryLocator(query);
        
    }
    
    global void execute(Database.batchablecontext bc, List<Contract> scope)
    {
        
        
        try{
            
        Set<id> accountid=new set<id>();
        for(Contract contractloop:scope)
        {
           
            accountid.add(contractloop.AccountId);
        }
        
        updateAccountcntrctExpDate.updateParentAccountforActivedContracts(accountid);
        
        
    }
    catch(Exception e)
    {
        system.debug('Error'+e);
    }
}
    
    global void finish (Database.batchablecontext bc)
   {
      
       /*AsyncApexJob job=[select id,JobItemsProcessed,Completeddate ,status,NumberOfErrors FROM AsyncApexJob where Id=:bc.getJobId()];
    Messaging.SingleEmailMessage msg = new Messaging.SingleEmailMessage();
    String[] toadd = new String[]{'planetddscpq@demandblue.com'};	  	
    msg.setSubject('Batch Operation for updating AccountContract expiration date '+job.Status);
    msg.setToAddresses(toadd);
    msg.setPlainTextBody('The Batch Apex job processed '+job.JobItemsProcessed+' Items with '+job.NumberOfErrors+' Errors');
    msg.setSenderDisplayName('System Admin');
    List<Messaging.SingleEmailMessage> emails =new List<Messaging.SingleEmailMessage>{msg};
    Messaging.sendEmail(emails); 
      */ 
       
    }
}