public class updateAccountcntrctExpDate {
    public static boolean isFirstTime=true;
    
    public static void UpdateDirectContractEndDateForActiveContracts(set<Id> AccountIds,set<Id> EndCustomerAccountIds)
    {
        system.debug('New method');
        Set<Id> accIdSet = new Set<Id>();//to capture account ids
        Set<Id> AccountHavingNoContracts = new Set<Id>();
        map<id,Date> AccountContractsMap=new map<Id,Date>();
        
        List<AggregateResult> ContractsList=[SELECT Account.id ID,Max(EndDate) EndDate
                                             FROM Contract WHERE Status='Activated'and (Account.id IN: AccountIds or Account.id IN:EndCustomerAccountIds)
                                             Group By Account.id];
        
        system.debug('ContractsList-->'+ ContractsList);
        
        List<AggregateResult> EndCustomerContractsList=[SELECT ia_crm__End_Customer__c ID,Max(EndDate) EndDate
                                                        FROM Contract WHERE Status='Activated'
                                                        and (ia_crm__End_Customer__r.id IN: EndCustomerAccountIds or ia_crm__End_Customer__r.id  IN: AccountIds)
                                                        Group By ia_crm__End_Customer__c];
        
        system.debug('EndCustomerContractsList-->'+ EndCustomerContractsList);
        
        if(ContractsList.size()>0)
        {
            for(AggregateResult aggregateset : ContractsList)
            {
                AccountContractsMap.put((Id)aggregateset.get('ID'),(Date)aggregateset.get('EndDate'));
                accIdSet.add((Id)aggregateset.get('ID'));
            }
        }
        
        if(EndCustomerContractsList.size()>0)
        {
            for(AggregateResult EndCustomerAggregateset : EndCustomerContractsList)
            {
                if(!AccountContractsMap.containskey((Id)EndCustomerAggregateset.get('ID')))
                {
                    AccountContractsMap.put((Id)EndCustomerAggregateset.get('ID'),(Date)EndCustomerAggregateset.get('EndDate'));
                    accIdSet.add((Id)EndCustomerAggregateset.get('ID'));
                }
                else if((Date)EndCustomerAggregateset.get('EndDate') > AccountContractsMap.get((Id)EndCustomerAggregateset.get('ID')))
                {
                    AccountContractsMap.put((Id)EndCustomerAggregateset.get('ID'),(Date)EndCustomerAggregateset.get('EndDate'));
                }     
            }
        }       
        
        system.debug('AccountContractsMap-->'+ AccountContractsMap);
        
        List<Account> AccountsToUpdate = [SELECT id, DirectContractEndDate__c FROM Account WHERE id IN: accIdSet];
        
        if(AccountsToUpdate.size()>0)
        {
            for(Account accounttoupdate :AccountsToUpdate)
            {
                if(AccountContractsMap.containskey(accounttoupdate.id))
                {
                    accounttoupdate.DirectContractEndDate__c=AccountContractsMap.get(accounttoupdate.id);
                }
            }
        }
        
        for(Id AccId: AccountIds){
            if(!accIdSet.contains(AccId))
            {
                AccountHavingNoContracts.add(AccId);
            }               
        }
        
        for(Id EndAccId: EndCustomerAccountIds){
            if(!accIdSet.contains(EndAccId))
            {
                AccountHavingNoContracts.add(EndAccId);
            }               
        }
        List<Account> AccountsHaveNoDirectContractEndDate = [SELECT id, DirectContractEndDate__c FROM Account WHERE id IN: AccountHavingNoContracts];
        for(Account AccountHaveNoDirectContractEndDate: AccountsHaveNoDirectContractEndDate){
        	AccountHaveNoDirectContractEndDate.DirectContractEndDate__c=NULL;
            AccountsToUpdate.add(AccountHaveNoDirectContractEndDate);
        }
        system.debug('AccountsToUpdate-->'+ AccountsToUpdate);
        
        try
        {
            update AccountsToUpdate;
        }
        catch(exception ex){
            system.debug('error is '+ex.getMessage());
        }      
        
    }
}