/******************************************************************************************************************************
* @author           Demandblue
* @version          1.0 
* @Name      		AccountTriggerController
* @description 		This class is Handler of Account Trigger...
********************************************************************************************************************************
Version    	Date        	   Team    	     Comments
********************************************************************************************************************************
* 1    		24 Nov 2020    	Jeromia    	Initial Development 
********************************************************************************************************************************/


public without sharing class AccountTriggerController {
    
    /* This method creates Account Contact Relationship for merged reseller accounts.
* Master Account's Portal Contacts will be created with ACR of EndCustomer Accounts.
* Also,to delete if any duplicate junction records are created during merge operation.
*/ 
    
    Public static void deleteDuplicateRelationship(Set<Id> masteraccountids){
        
        Map<Id,Reseller_End_Customer_Rel__c> masterresellerendcustomermap = getRelationshipRecords(masteraccountids);
        Set<Id> victimduplicaterelationshiprecords = new Set<Id>();
        Set<String> victimduplicaterelationshipstring = new Set<String>();
        try{
            for(Reseller_End_Customer_Rel__c rec:masterresellerendcustomermap.values()){
                
                // Identify any duplicate relationship is created at the time of account merging
                
                String rr = rec.Regular_Account__c+','+rec.Reseller_Account__c;
                if(victimduplicaterelationshipstring.contains(rr)){
                    victimduplicaterelationshiprecords.add(rec.Id);
                }else{
                    victimduplicaterelationshipstring.add(rr); 
                }
            }
            
            // Delete if any duplicate junctionrecords are created during merge operation.
            if(!victimduplicaterelationshiprecords.isEmpty()){
                Delete [Select Id,Regular_Account__c,Reseller_Account__c
                        From Reseller_End_Customer_Rel__c
                        Where Id=:victimduplicaterelationshiprecords
                       ];
                
            }
            
            // Create Related Accounts for End-Customer Accounts
            createACRforMergedAccounts(masteraccountids);
        }catch(Exception e){
            system.debug('ERROR-->'+e);
        }
    }
    
    // Create Related Accounts for End-Customer Accounts
    public static void createACRforMergedAccounts(Set<Id> masteraccountids){
        
        Map<Id,Reseller_End_Customer_Rel__c> masterresellerendcustomermap = getRelationshipRecords(masteraccountids);
        // Get ACR of Master record
        try{
            
            List<AccountContactRelation> masterrelatedaccountslist =[Select Id,AccountId,ContactId,Contact.AccountId
                                                                     From AccountContactRelation Where AccountId=:masteraccountids OR
                                                                     Contact.AccountId=:masteraccountids
                                                                     WITH SECURITY_ENFORCED];
            
            Map<Id,Set<Id>> mastereselleraccountandrelatedaccounts = new Map<Id,Set<Id>>();
            
            // Map reseller account and corresponding endcustomers
            for(AccountContactRelation acr:masterrelatedaccountslist){
                if(mastereselleraccountandrelatedaccounts.containsKey(acr.Contact.AccountId)){
                    Set<Id> relatedaccountid = mastereselleraccountandrelatedaccounts.get(acr.Contact.AccountId);
                    relatedaccountid.add(acr.AccountId);
                    mastereselleraccountandrelatedaccounts.put(acr.Contact.AccountId,relatedaccountid);
                }else{
                    mastereselleraccountandrelatedaccounts.put(acr.Contact.AccountId,new Set<Id>{acr.AccountId});
                }
            }
            
            // Identify junctions records withour ACR relationship
            Set<Id> victimrelationshiprecords = new Set<Id>();
            
            for(Reseller_End_Customer_Rel__c rec:masterresellerendcustomermap.values()){
                if(mastereselleraccountandrelatedaccounts.containsKey(rec.Reseller_Account__c)){
                    if(!mastereselleraccountandrelatedaccounts.get(rec.Reseller_Account__c).contains(rec.Regular_Account__c)){
                        victimrelationshiprecords.add(rec.Id);
                    }
                }
            }
            
            // Create ACR for junction records without ACR relationship
            ResellerEndCustomerController.createEndUserAccountsAsRelatedAccounts([Select Id,Regular_Account__c,Reseller_Account__c
                                                                                  From Reseller_End_Customer_Rel__c
                                                                                  Where Id=:victimrelationshiprecords
                                                                                  WITH SECURITY_ENFORCED]);
        }catch(Exception e){
            system.debug('ERROR-->'+e);
        }        
    }
    
    // Get Relationship Records of Survivour Accounts
    Private static Map<Id,Reseller_End_Customer_Rel__c> getRelationshipRecords(Set<Id> masteraccountids){
        Map<Id,Reseller_End_Customer_Rel__c> masterresellerendcustomermap = new  Map<Id,Reseller_End_Customer_Rel__c>([Select Id,Regular_Account__c,Reseller_Account__c
                                                                                                                       From Reseller_End_Customer_Rel__c 
                                                                                                                       Where Regular_Account__c=: masteraccountids OR
                                                                                                                       Reseller_Account__c=: masteraccountids
                                                                                                                       WITH SECURITY_ENFORCED]);
        
        return masterresellerendcustomermap;
    }
    
}