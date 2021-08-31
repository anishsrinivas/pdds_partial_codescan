global class Batch_UpdateSupportEndDate implements Database.Batchable<sObject>,Database.Stateful {
   global Map<Id,Date> accountIdAndEnDateMap; 
   global Map<Id,Date> accountIdAndEnDateNotificationMap = new Map<Id,Date>();
    
    global Database.QueryLocator start(Database.BatchableContext BC){
        String query = 'Select Id,SBQQ__Account__c,End_Customer_Ship_To_Account__c From SBQQ__Subscription__c Where SBQQ__Contract__r.Status = \'Activated\'';
        return Database.getQueryLocator(query); 
    }
    
    global void execute(Database.BatchableContext BC,List<SBQQ__Subscription__c> subList){
        Set<Id> subIdSet= new Set<Id>();
        Set<Id> accountIdSet= new Set<Id>();
        Set<Id> endCustomerAccountIdSet= new Set<Id>();
        
        for(SBQQ__Subscription__c sb: subList){
            subIdSet.add(sb.Id);
            if(sb.SBQQ__Account__c !=null)
                accountIdSet.add(sb.SBQQ__Account__c);
            if(sb.End_Customer_Ship_To_Account__c != null)
                endCustomerAccountIdSet.add(sb.End_Customer_Ship_To_Account__c);
        }
        
        system.debug('subIdSet-->'+subIdSet);
        system.debug('accountIdSet-->'+accountIdSet);
        system.debug('endCustomerAccountIdSet-->'+endCustomerAccountIdSet);
        
        accountIdAndEnDateMap = UpdateSupportEndDate_Controller.getSubscription(subIdSet, accountIdSet, endCustomerAccountIdSet);
        system.debug('accountIdAndEnDateMap-->'+accountIdAndEnDateMap.size());
        accountIdAndEnDateNotificationMap.putAll(accountIdAndEnDateMap);
        system.debug('accountIdAndEnDateNotificationMap-->'+accountIdAndEnDateNotificationMap.size());
    
    }
    
    global void finish(Database.BatchableContext BC){
        
        AsyncApexJob job = [SELECT Id, Status, NumberOfErrors, 
                                JobItemsProcessed,
                                TotalJobItems, CreatedBy.Email
                                FROM AsyncApexJob
                                WHERE Id = :bc.getJobId()];
        String attName = 'PLAN 964' + system.now().format('YYYYMMDDhhmm') + '.csv';
        String finalstr = 'AccountId,MaxEndDate\n';
        Messaging.EmailFileAttachment efa = new Messaging.EmailFileAttachment();
        Messaging.EmailFileAttachment[] emailAttList = new List<Messaging.EmailFileAttachment>();
        for(Id accid:accountIdAndEnDateNotificationMap.keySet()){
            string recordString = '"'+accid+'","'+accountIdAndEnDateNotificationMap.get(accid)+'"\n';
            finalstr = finalstr +recordString;
        }       
        efa.setFileName(attName);
        efa.setBody(Blob.valueOf(finalstr));
        emailAttList.add(efa);
        Messaging.SingleEmailMessage email = new Messaging.SingleEmailMessage();
        email.setSubject( 'PDDS PLAN 964 Batch Run' );
        email.setToAddresses( new String[] {'planetddscpq@demandblue.com'} );
        email.setHtmlBody( '<html>PFA - Accounts and Support End Date</html>');
        if(!emailAttList.isEmpty()){
            email.setFileAttachments(emailAttList);}
        
        // Sends the email
        Messaging.SendEmailResult [] r =Messaging.sendEmail(new Messaging.SingleEmailMessage[] {email});
        
        
    }
}