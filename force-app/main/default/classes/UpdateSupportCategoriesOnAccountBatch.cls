global class UpdateSupportCategoriesOnAccountBatch implements Database.Batchable<sObject>{
    
    Set<String> accountIdSet = new Set<String>();
    public String getAllAccountsQuery = '';
    
    global UpdateSupportCategoriesOnAccountBatch(){ 
        Set<String> assetSet = new Set<String>();
        //AsyncApexJob job =[SELECT CompletedDate FROM AsyncApexJob WHERE status='Completed' and ApexClassId='01pP000000AwIfrIAF' order by CompletedDate desc limit 1];
        for(Asset currAsset : [select AccountId,Account.Name, Name from Asset where LastModifiedDate IN( TODAY, YESTERDAY)]){ 
            assetSet.add(currAsset.AccountId);
        }
        Set<String> subscriptionSet = new Set<String>();
        for(SBQQ__Subscription__c currSub : [SELECT SBQQ__Account__c FROM SBQQ__Subscription__c WHERE LastModifiedDate IN( TODAY, YESTERDAY)]){
            subscriptionSet.add(currSub.SBQQ__Account__c);
        }
        accountIdSet.addAll(assetSet);
        accountIdSet.addAll(subscriptionSet);
        getAllAccountsQuery = 'SELECT ID FROM ACCOUNT WHERE ID in :accountIdSet';
        
    }
    
    global Iterable<sObject> start(Database.BatchableContext bc){
        GetAllAccountsForSuppLicenseCatg obj = new GetAllAccountsForSuppLicenseCatg();
        List<Account> lsAcctToUpdate = obj.getAllAccounts();
        return lsAcctToUpdate;
    }
    
    global void execute(Database.BatchableContext bc, List<Account> acctList){
        update acctList;
    }
    
    global void finish(Database.BatchableContext bc){
        AsyncApexJob job=[select id,JobItemsProcessed,Completeddate ,status,NumberOfErrors FROM AsyncApexJob where Id=:bc.getJobId()];
        Messaging.SingleEmailMessage msg = new Messaging.SingleEmailMessage();
        String[] toadd = new String[]{'planetddscpq@demandblue.com'};	  	
        msg.setSubject('Batch Operation for updating Support Category on Accounts '+job.Status);
        msg.setToAddresses(toadd);
        msg.setPlainTextBody('The Batch Apex job processed '+job.JobItemsProcessed+' items with '+job.NumberOfErrors+' Errors');
        msg.setSenderDisplayName('System Admin');
        List<Messaging.SingleEmailMessage> emails =new List<Messaging.SingleEmailMessage>{msg};
        Messaging.sendEmail(emails);
    }
    
    
}