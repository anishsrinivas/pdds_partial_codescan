global class RestweeklyscoreBatch implements Database.Batchable<sObject>, Database.AllowsCallouts {          
    global Database.QueryLocator start(Database.BatchableContext BC) {
        return Database.getQueryLocator('SELECT Id, Weekly_account_score__c FROM Account ');
    }
    global void execute(Database.BatchableContext BC, List<Account> scope) {
        try {
            List < Account > updteAccountRecList = new List < Account > ();
            Account AccountRecUpdte;
            for(Account AccountRecord:scope)
            {
             system.debug('~~~~~~~~~~'+AccountRecord.Id);
                AccountRecUpdte = new Account(Id = AccountRecord.Id);
                AccountRecUpdte.Weekly_account_score__c = 0;
                
                updteAccountRecList.add(AccountRecUpdte);
            }
        if (updteAccountRecList.size() > 0 && !updteAccountRecList.isEmpty()){
                system.debug('DatatoUpdate@@@@'+updteAccountRecList);
                update updteAccountRecList;
            }
        }
        catch(Exception e) {
            System.debug(e);
        }
    }
    global void finish(Database.BatchableContext BC) {
        
    }
}