/******************************************************************************************************************************
* @author           Demandblue
* @version          1.0 
* @Name             ContactTriggerController
* @Description      If Partner Contacts Accounts are updated to another Partner Account,
then copy the EndCustomers of new account to updated contact's Related Accounts. 
Also delete the Old Account's EndCustomers which are saved as Related Accounts.
********************************************************************************************************************************
Version     Date               Team          Comments
********************************************************************************************************************************
* 1         29 JAN 2021     Jeromia     Initial Development 
********************************************************************************************************************************/


public without sharing class ContactTriggerController {
    
    //Get Contact records if only account's are updated
    public static void getContactRecords(Map<Contact,Contact> oldNewContactRecordsMap){
        try{
            List<Contact> getContactswithOldValues = new  List<Contact> (); 
            List<Contact> getContactswithNewValues = new  List<Contact> (); 
            
            for(Contact con: oldNewContactRecordsMap.keySet()){    
                getContactswithOldValues.add(con);
            }
            
            for(Contact con: oldNewContactRecordsMap.Values()){
                getContactswithNewValues.add(con);
            }
            
            //Pass Old Account Id and delete only the related accounts that match with Old Account's EndCustomer Records
            deleteOldRelatedAccounts(getContactswithOldValues);
            //Now Pass the new Account Id and get New EndCustomer records and Create them as Related Accounts
            insertNewEndCustomersAsRelatedAccounts(getContactswithNewValues,oldNewContactRecordsMap);
            
        }Catch(Exception e){
            System.debug('ERROR-->'+e.getLineNumber()+' '+e.getMessage());
        }
    }
    
    //Get New EndCustomer Accounts and created them as Related Accounts.
    Public static void insertNewEndCustomersAsRelatedAccounts(List<Contact> contactswithNewValues,Map<Contact,Contact> oldNewContactRecordsMap){
        Set<Id> newResellerAccountIds = new Set<Id>();
        
        List<AccountContactRelation> insertACR = new List<AccountContactRelation>();
        
        try{
            
            Map<Id,User> partnerUsersMap = new  Map<Id,User>([Select Id,ContactId 
                                                              From User Where ContactId =:oldNewContactRecordsMap.keySet()  
                                                              And IsActive=True
                                                              WITH SECURITY_ENFORCED]);
            
            Set<Id> resellerPartnerContactsIds = new Set<Id>();
            for(Id u: partnerUsersMap.KeySet()){
                resellerPartnerContactsIds.add(partnerUsersMap.get(u).ContactId);
            }
            
            List<Contact> resellerPartnerContactswithNewValues = [Select Id,LastName,AccountId From Contact 
                                                     Where ID =:resellerPartnerContactsIds
                                                     WITH SECURITY_ENFORCED];
            
            for(Contact c: resellerPartnerContactswithNewValues){
                newResellerAccountIds.add(c.AccountId);
            }
            
            // Get EndCustomers of Reseller Accounts
            List<Reseller_End_Customer_Rel__c> resellerEndCustomersList = [Select Regular_Account__c,Reseller_Account__c 
                                                                           FROM Reseller_End_Customer_Rel__c
                                                                           WHERE Reseller_Account__c=:newResellerAccountIds
                                                                           WITH SECURITY_ENFORCED];
            
            // Map Reseller and corresponding EndCustomers in Map
            if(!resellerEndCustomersList.isEmpty()){
                Map<Id,Set<Id>> resellerEndCustomerIdsMap = resellerEndCustomerListToMap(resellerEndCustomersList);
                
                // For each updated contact, get endcustomers and create a related account.
                for(Contact c: oldNewContactRecordsMap.values()){
                    if(resellerEndCustomerIdsMap.containsKey(c.AccountId)){
                        for(Id endcustomerid: resellerEndCustomerIdsMap.get(c.AccountId)){
                            AccountContactRelation acr = new AccountContactRelation();
                            acr.AccountId = endcustomerid;
                            acr.ContactId = c.Id;
                            insertACR.add(acr);
                        }
                    }
                }
                
                if(!insertACR.isEmpty() &&  Schema.sObjectType.AccountContactRelation.isCreateable()){
                    Insert insertACR;
                }
            }
        }Catch(Exception e){
            System.debug('ERROR-->'+e.getLineNumber()+' '+e.getMessage());
        }
    }    
    
    //Delete Related Accounts that match with EndCustomers of Old AccountId
    Public Static  Void deleteOldRelatedAccounts(List<Contact> contactswithOldValues){
        
        Set<Id> oldResellerAccountIds = new Set<Id> ();
        Set<Id> contactIds = new Set<Id> ();
        
        try{
            for(Contact c: contactswithOldValues){
                oldResellerAccountIds.add(c.AccountId);
                contactIds.add(c.id);
            }
            
            List<Reseller_End_Customer_Rel__c> resellerEndCustomersList = [Select Regular_Account__c,Reseller_Account__c 
                                                                           FROM Reseller_End_Customer_Rel__c
                                                                           WHERE Reseller_Account__c=:oldResellerAccountIds
                                                                           WITH SECURITY_ENFORCED];
            Set<Id> endCustomerIds = new  Set<Id>();
            if(!resellerEndCustomersList.isEmpty()){
                for(Reseller_End_Customer_Rel__c rec: resellerEndCustomersList){
                    endCustomerIds.add(rec.Regular_Account__c);
                }
            }
            
            if(!endCustomerIds.isEmpty()){
                List<AccountContactRelation> resellerRelatedAccountsList = [Select AccountId,ContactId,Contact.AccountId
                                                                            From AccountContactRelation
                                                                            WHERE (ContactId=:contactIds AND AccountId=:endCustomerIds)
                                                                            WITH SECURITY_ENFORCED];
                
                
                
                if(!resellerRelatedAccountsList.isEmpty() && Schema.sObjectType.AccountContactRelation.isDeletable()){
                    
                    Delete resellerRelatedAccountsList;
                }
            }
            List<AccountContactRelation> oldResellerRelatedAccountsList = [Select AccountId,ContactId,Contact.AccountId
                                                                           From AccountContactRelation
                                                                           WHERE ContactId=:contactIds AND AccountId=:oldResellerAccountIds
                                                                           WITH SECURITY_ENFORCED];
            if(!oldResellerRelatedAccountsList.isEmpty() && Schema.sObjectType.AccountContactRelation.isDeletable()){
                
                Delete oldResellerRelatedAccountsList;
            }
        }
        Catch(Exception e){
            System.debug('ERROR-->'+e.getLineNumber()+' '+e.getMessage());
        }
    }
    
    public static  Map<Id,Set<Id>> resellerEndCustomerListToMap(List<Reseller_End_Customer_Rel__c> resellerEndCustomersList){
        Map<Id,Set<Id>> resellerEndCustomerIdsMap = new  Map<Id,Set<Id>>();
        for(Reseller_End_Customer_Rel__c rec : resellerEndCustomersList){
            if(resellerEndCustomerIdsMap.containskey(rec.Reseller_Account__c)){
                Set<id> accountId = resellerEndCustomerIdsMap.get(rec.Reseller_Account__c);
                accountId.add(rec.Regular_Account__c);
                resellerEndCustomerIdsMap.put(rec.Reseller_Account__c,accountId);
            }else{
                resellerEndCustomerIdsMap.put(rec.Reseller_Account__c,new Set<Id>{rec.Regular_Account__c});
            }
        }  
        
        return resellerEndCustomerIdsMap;
    }
}