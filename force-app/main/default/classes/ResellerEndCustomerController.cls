/******************************************************************************************************************************
* @author           Demandblue
* @version          1.0 
* @Name             ResellerEndCustomerController
* @description      This controller creates,deletes and throw alert on various actions of ResellerEndCustomer Custom Object.
Regular Accounts denotes End-Customer / Resellers denotes Resellers.
********************************************************************************************************************************
Version     Date               Team          Comments
********************************************************************************************************************************
* 1         04 Nov 2020     Jeromia     Initial Development 
********************************************************************************************************************************/

public without sharing class ResellerEndCustomerController {
    
    /* This method throws an alert if a duplicate End-Customer/Reseller Relationship is added.*/
    
    Public Static void throwErrorOnDuplicateRelationship(List<Reseller_End_Customer_Rel__c> resellerEndCustomerList){
        try{
            Set<Id> resellerIds = new Set<Id>();
            for(Reseller_End_Customer_Rel__c rec : resellerEndCustomerList){
                resellerIds.add(rec.Reseller_Account__c);
            }
            
            // Query Existing Junction records for this reseller, irrespective of inserted record is Reseller(or)EndCustomer. 
            List<Reseller_End_Customer_Rel__c> existingResellerEndCustomerList = [Select Id,Reseller_Account__c,Regular_Account__c 
                                                                                  From Reseller_End_Customer_Rel__c 
                                                                                  Where Reseller_Account__c =: resellerIds
                                                                                  WITH SECURITY_ENFORCED];
            
            //Map EndCustomer and Reseller
            Map<Id,List<Id>> endCustomerResellerMap = endCustomerReselleListToMap(existingResellerEndCustomerList);
            
            
            /*Check whether newly added Reseller is already a reseller? for the EndCustomer Account.
*Also called as to check whether new added record is a unique relationship.If not, thow an Error*/
            throwErrorOnCreationofDuplicateRel(resellerEndCustomerList,endCustomerResellerMap);
            
            
            // Add an error if Duplicate exisit on bulk of record insertion.
            throwErrorOnDuplicationRelOnBulkInsertion(resellerEndCustomerList);
        }Catch(Exception e){
            System.debug('ERROR--->'+e);
        }
    }
    
    /* Whenever a new junctionRecord is created,add junctionRecord EndCustomer Account as a Related Account 
* to the Portal Contacts of junctionRecord Reseller Account.*/
    
    Public Static Void createEndUserAccountsAsRelatedAccounts(List<Reseller_End_Customer_Rel__c> resellerEndCustomerList){
        try{ 
            Set<Id> resellerAccountIds = new Set<Id>();
            for(Reseller_End_Customer_Rel__c rec:resellerEndCustomerList){
                resellerAccountIds.add(rec.Reseller_Account__c);
            }
            system.debug('resellerEndCustomerList--->'+resellerEndCustomerList.size());
            //Map End-Customer and Resellers
            Map<Id,List<Id>> regularResellerIdsMap = endCustomerReselleListToMap(resellerEndCustomerList);
            
            // Get Portal Contacts of Reseller Accounts
            Map<Id,List<Contact>> contactResellerAccountIdsMap =  getPortalContactsofResellerAccounts(resellerAccountIds);
            
            // Map junctionRecord Regular Accounts and junctionRecord Reseller Account's Portal Contacts
            Map<Id,List<Contact>> regularAccountContactIdsMap = new Map<Id,List<Contact>>();
            for(Id regularAccountId: regularResellerIdsMap.KeySet()){
                for(Id resellerId :regularResellerIdsMap.get(regularAccountId)){
                    if(contactResellerAccountIdsMap.containsKey(resellerId)){
                        for(Contact c: contactResellerAccountIdsMap.get(resellerId)){
                            if(regularAccountContactIdsMap.containsKey(regularAccountId)){
                                List<Contact> conlist = regularAccountContactIdsMap.get(regularAccountId);
                                conlist.add(c);
                                regularAccountContactIdsMap.put(regularAccountId,conlist);
                            }else{
                                regularAccountContactIdsMap.put(regularAccountId,new List<Contact>{c});
                            }
                        }
                    }
                }
            }
            
            if(!regularAccountContactIdsMap.isEmpty()){
                // For each Regular Account create a Related Account Record for each Poratl Contacts of Reseller Accounts
                insertACRRelationship(regularAccountContactIdsMap);
            }
        }Catch(Exception e){
            System.debug('ERROR--->'+e);
        }
    }
    
    //Delete Related Account Record whenever a EndCustomer/Reseller relationship is deleted or Updated.
    
    Public Static void deleteEndUserAccountsInRelatedAccounts(List<Reseller_End_Customer_Rel__c> resellerEndCustomerListOld){
        try{
            Set<Id> oldRegularAccountIds = new Set<Id>();
            for(Reseller_End_Customer_Rel__c recold:resellerEndCustomerListOld){
                oldRegularAccountIds.add(recold.Regular_Account__c);
            }
            
            List<AccountContactRelation> relatedAccountContactRelationListOld = [Select Id,AccountId,Account.Name,Contact.Name,ContactId,Contact.AccountId
                                                                                 From AccountContactRelation 
                                                                                 Where AccountId=:oldRegularAccountIds
                                                                                 WITH SECURITY_ENFORCED];
            Set<Id> ACRDeleteSet = new Set<Id>();
            if(!relatedAccountContactRelationListOld.isEmpty()){
                for(Reseller_End_Customer_Rel__c recold:resellerEndCustomerListOld){
                    for(AccountContactRelation acr:relatedAccountContactRelationListOld){
                        if(recold.Reseller_Account__c == acr.Contact.AccountId && acr.Contact.AccountId !=acr.AccountId ){
                            //AccountContactRelation ACRDelete = new AccountContactRelation();
                            // ACRDelete.Id = acr.Id;
                            ACRDeleteSet.add(acr.Id);
                        }
                    }
                    
                }
            }
            List<AccountContactRelation> ACRDeleteList = [Select Id From AccountContactRelation 
                                                          Where Id=:ACRDeleteSet
                                                          WITH SECURITY_ENFORCED];
            if(!ACRDeleteList.isEmpty() && Schema.sObjectType.AccountContactRelation.isDeletable()){
                Delete ACRDeleteList;
            }   
        }Catch(Exception e){
            System.debug('ERROR--->'+e);
        }
    }
    
    //Map End-Customers and Resellers
    Private static  Map<Id,List<Id>> endCustomerReselleListToMap(List<Reseller_End_Customer_Rel__c> endCustomerResellerList){
        
        Map<Id,List<Id>> endCustomerResellerMap = new Map<Id,List<Id>>();
        try{
            for(Reseller_End_Customer_Rel__c rec : endCustomerResellerList){
                if(endCustomerResellerMap.containskey(rec.Regular_Account__c)){
                    List<id> accountId = endCustomerResellerMap.get(rec.Regular_Account__c);
                    accountId.add(rec.Reseller_Account__c);
                    endCustomerResellerMap.put(rec.Regular_Account__c,accountId);
                }else{
                    endCustomerResellerMap.put(rec.Regular_Account__c,new List<Id>{rec.Reseller_Account__c});
                }
            }  
            return endCustomerResellerMap; 
        }Catch(Exception e){
            System.debug('ERROR-->'+e);
            return endCustomerResellerMap; 
        }
    } 
    
    /*Check whether newly added Reseller is already a reseller? for the EndCustomer Account.
*Also called as to check whether new added record is a unique relationship.If not, thow an Error*/
    
    Private static void throwErrorOnCreationofDuplicateRel (List<Reseller_End_Customer_Rel__c> resellerEndCustomerList,Map<Id,List<Id>> endCustomerResellerMap){
        
        try{
            for(Reseller_End_Customer_Rel__c rec : resellerEndCustomerList){
                for(Id recmap : endCustomerResellerMap.KeySet()){
                    if(endCustomerResellerMap.containsKey(rec.Regular_Account__c)){
                        for(Id resellerID : endCustomerResellerMap.get(recmap)){
                            if(resellerID == rec.Reseller_Account__c && recmap == rec.Regular_Account__c){
                                rec.adderror('End-Customer/Reseller Account Relationship Already Exists');
                            }
                        }
                    }
                }
            }
        }Catch(Exception e){
            System.debug('ERROR--->'+e);
        }
    }
    
    // Add an error if Duplicate exisit on bulk of record insertion.    
    Private static void throwErrorOnDuplicationRelOnBulkInsertion(List<Reseller_End_Customer_Rel__c> resellerEndCustomerList){
        try{
            Set<String> regularResellerString = new Set<String>();
            for(Reseller_End_Customer_Rel__c rec : resellerEndCustomerList){
                String rr = rec.Regular_Account__c+','+rec.Reseller_Account__c;
                if(regularResellerString.contains(rr)){
                    rec.adderror('End-Customer/Reseller Account Relationship Already Exists');
                }else{
                    regularResellerString.add(rr);
                }
                
            }
        }Catch(Exception e){
            System.debug('ERROR--->'+e);
        }
    }
    
    // Insert End-Customer Accounts as Related Accounts to Portal Contacts
    Private static void insertACRRelationship(Map<Id,List<Contact>> regularAccountContactIdsMap){
        try{
            List<AccountContactRelation> ACRtoInsert = new List<AccountContactRelation>();
            
            for(Id regularAccountId :regularAccountContactIdsMap.KeySet()){
                
                for(Contact c: regularAccountContactIdsMap.get(regularAccountId)){
                    AccountContactRelation acr = new AccountContactRelation();
                    acr.AccountId = regularAccountId;
                    acr.ContactId = c.Id;
                    ACRtoInsert.add(acr);
                }
            }
            
            if(!ACRtoInsert.isEmpty() &&  Schema.sObjectType.AccountContactRelation.isCreateable()){
                Insert ACRtoInsert;
            }
        }Catch(Exception e){
            System.debug('ERROR--->'+e);
        }
    }
    
    // Get Portal Contacts of Reseller Accounts   
    Private static Map<Id,List<Contact>> getPortalContactsofResellerAccounts(Set<Id> resellerAccountIds){
        Map<Id,List<Contact>> contactResellerAccountIdsMap = new Map<Id,List<Contact>>();
        try{
            //Query all Contacts of junctionRecord Reseller Account.
            Map<Id,Contact> resellerContactsMap = new  Map<Id,Contact>([Select Id,LastName,AccountId 
                                                                        From Contact 
                                                                        Where AccountId =:resellerAccountIds
                                                                        WITH SECURITY_ENFORCED]);
            
            // Check whether any portal users available for junctionRecord Reseller Account's Contacts
            Map<Id,User> partnerUsersMap = new  Map<Id,User>([Select Id,ContactId 
                                                              From User Where ContactId =:resellerContactsMap.keySet()  
                                                              And IsActive=True
                                                              WITH SECURITY_ENFORCED]);
            
            Set<Id> resellerPartnerContactsIds = new Set<Id>();
            for(Id u: partnerUsersMap.KeySet()){
                resellerPartnerContactsIds.add(partnerUsersMap.get(u).ContactId);
            }
            
            List<Contact> resellerPartnerContacts = [Select Id,LastName,AccountId From Contact 
                                                     Where ID =:resellerPartnerContactsIds
                                                     WITH SECURITY_ENFORCED];
            
            
            // Map Reseller Account and related Portal Contacts
            for(Contact c: resellerPartnerContacts){
                if(contactResellerAccountIdsMap.containsKey(c.AccountId)){
                    List<Contact> conlist = contactResellerAccountIdsMap.get(c.AccountId);
                    conlist.add(c);
                    contactResellerAccountIdsMap.put(c.AccountId,conlist);
                    
                }else{
                    contactResellerAccountIdsMap.put(c.AccountId,new List<Contact>{c});
                }
            }    
            return contactResellerAccountIdsMap;   
            
        }Catch(Exception e){
            System.debug('ERROR--->'+e);
            return contactResellerAccountIdsMap;   
        }
    }
}