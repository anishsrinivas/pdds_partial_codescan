/******************************************************************************************************************************
* @author           Demandblue
* @version          1.0 
* @Name      		UserTriggerHandler
* @description 		This Controller Create a Related Accounts if any End Customer Accounts available for the Reseller Account.
********************************************************************************************************************************
Version    	Date        	   Team    	     Comments
********************************************************************************************************************************
* 1    		06 Nov 2020    	Jeromia    	Initial Development 
********************************************************************************************************************************/


public without sharing class UserTriggerHandler {
    
    /* Whenever a contact is converted as a Portal User,Check if the account is added as a Reseller of any End Customer Accounts.
* If yes then create those end customer accounts as Related accounts to this user's Contact.
* This method is written in future, because User and AccountContactRelationship Objects are Standard Objects- which lead to Mixed DML Exception.
*/
    
    @future
    Public Static void insertEndUserAccounts(Set<Id> userIds){
        try{
            List<User> userList = [Select Id,ContactId,Contact.Name,AccountId From User 
                                   Where Id=:userIds
                                   WITH SECURITY_ENFORCED];
            Set<Id> resellerAccountId = new Set<Id>();
            for(User u: userList){
                resellerAccountId.add(u.AccountId);
            }
            
            // Query JuctionRecords with this Reseller Account
            Map<Id,List<Id>> resellerEndCustomerMap = getRelationshipRecords(resellerAccountId);
            // If junctionrecords are found, create End Customer Accounts as Related Accounts to that User's Contact.
            
            List<AccountContactRelation> ACRInsert = new List<AccountContactRelation>();
            for(User u: userList){
                if(resellerEndCustomerMap.containsKey(u.AccountId)){
                    for(Id regularId: resellerEndCustomerMap.get(u.AccountId)){
                        system.debug('ACR-->'+regularId+'   '+u.Contact.Name);
                        AccountContactRelation acr = new AccountContactRelation();
                        acr.AccountId = regularId;
                        acr.ContactId = u.ContactId;
                        ACRInsert.add(acr);
                    }
                }
            }
            
            if(!ACRInsert.isEmpty() && Schema.sObjectType.AccountContactRelation.isCreateable()){
                Insert ACRInsert;
            }
        }catch(Exception e){
            system.debug('ERROR-->'+e);
        }
    }
    
    // get Junction Records of the Reseller Account
    Private static  Map<Id,List<Id>> getRelationshipRecords( Set<Id> resellerAccountId ){
        Map<Id,List<Id>> resellerEndCustomerMap = new Map<Id,List<Id>>();
        try{
            List<Reseller_End_Customer_Rel__c> resellerEndCustomerList = [Select Id,Reseller_Account__c,Regular_Account__c,Regular_Account__r.Name,Reseller_Account__r.Name 
                                                                          From Reseller_End_Customer_Rel__c 
                                                                          Where Reseller_Account__c =: resellerAccountId
                                                                          WITH SECURITY_ENFORCED];
            
            
            
            for(Reseller_End_Customer_Rel__c rec : resellerEndCustomerList){
                if(resellerEndCustomerMap.containskey(rec.Reseller_Account__c)){
                    List<id> accountId = resellerEndCustomerMap.get(rec.Reseller_Account__c);
                    accountId.add(rec.Regular_Account__c);
                    resellerEndCustomerMap.put(rec.Reseller_Account__c,accountId);
                }else{
                    resellerEndCustomerMap.put(rec.Reseller_Account__c,new List<Id>{rec.Regular_Account__c});
                }
            }  
            
            return resellerEndCustomerMap;
        }catch(Exception e){
            system.debug('ERROR-->'+e);
            return resellerEndCustomerMap;
        }
    }   
}