/******************************************************************************************************************************
* @author           Demandblue
* @version          1.0 
* @Name      		Test_AccountTriggerController
* @description 		Test class for AccountTrigger and handler.
********************************************************************************************************************************
Version    	Date        	   Team    	     Comments
********************************************************************************************************************************
* 1    		26 Nov 2020    	Jeromia    	Initial Development 
********************************************************************************************************************************/

@istest
public class Test_AccountTriggerController {
    
    // Create Master Account,Victim Accounts,Master Contact and Portal User
    @testsetup
    public static void createTestRecords(){
     
        
        Account masterreselleraccountsinsert = new Account(Name = 'Master Account',ordertype__c = 'Reseller');
        Insert masterreselleraccountsinsert;
        Contact masterportalcontact = new Contact(LastName = 'MasterPortalContact',AccountId=masterreselleraccountsinsert.Id);
        Insert masterportalcontact;
        Profile p = [select Id,name from Profile where Name='Reseller Partner Community'];
        User masterportalcontactuser = new User(
            profileId = p.id,
            username = 'masterportalcontactuser@test.com',
            email = 'test@test.com',
            emailencodingkey = 'UTF-8',
            localesidkey = 'en_US',
            languagelocalekey = 'en_US',
            timezonesidkey = 'America/Los_Angeles',
            alias='test',
            lastname='PartnerUser',
            contactId = masterportalcontact.Id);
        Insert masterportalcontactuser;
        
        List<Account> victimreselleraccountsinsert = new List<Account>();
        
        for(integer i=1;i<11;i++){
            
            Account a1 = new Account();
            a1.Name = 'Victim Account'+i;
            a1.ordertype__c = 'Reseller';
            victimreselleraccountsinsert.add(a1);
        }
        
        Insert victimreselleraccountsinsert;   
        
    }

    // Test Merge Accounts
    Public testmethod static void mergeAccounts(){
        
        Account masteraccount = [Select Id from Account Where Name LIKE 'Master%' Limit 1];
        List<Account> victimaccounts = [Select Id from Account Where Name LIKE 'Victim%' Limit 2];
        List<Account> relationshipaccount = new List<Account>{new account(Name ='Test1'),new account(Name ='Test2')};
            
        Insert relationshipaccount;
        
        Reseller_End_Customer_Rel__c rec1 = new Reseller_End_Customer_Rel__c(Regular_Account__c=relationshipaccount[0].Id,Reseller_Account__c=victimaccounts[0].Id);
        Insert rec1;
        Reseller_End_Customer_Rel__c rec2 = new Reseller_End_Customer_Rel__c(Regular_Account__c=relationshipaccount[1].Id,Reseller_Account__c=victimaccounts[1].Id);
        Insert rec2;
        Reseller_End_Customer_Rel__c rec3 = new Reseller_End_Customer_Rel__c(Regular_Account__c=relationshipaccount[1].Id,Reseller_Account__c=masteraccount.Id);
        Insert rec3;
        
        Database.MergeResult[] mergeResult = Database.merge(masteraccount, victimaccounts, false);
        // After merge victim accounts will be deleted.
        System.assertEquals(0, [Select Id from Account Where Name LIKE 'Victim%' AND MasterRecordId != null].size(),'Some Error in Merging');
        // After merge child records will be transferred to master and account trigger will create ACR records 
        system.assertEquals(3,[Select Id From AccountContactRelation].size(),'Related Accounts are not created');
        
    }
    
    // Test deletion of junction records message before account is deleted
    Public testmethod Static void deleteAccountsandChildRecords(){
        
        List<Reseller_End_Customer_Rel__c> insertresellerJunctionRecords = new  List<Reseller_End_Customer_Rel__c>();
        List<Account> resellerAccounts = [Select Id,Name From Account Where ordertype__c ='Reseller' Limit 5];
        
        Account endCustomerAccount = new Account(Name='endCustomerAccount');
        Insert endCustomerAccount;
        
        for(Account a:resellerAccounts){
            Reseller_End_Customer_Rel__c rec = new Reseller_End_Customer_Rel__c();
            rec.Regular_Account__c = endCustomerAccount.Id;
            rec.Reseller_Account__c = a.Id;
            insertresellerJunctionRecords.add(rec);
        }
        
        Insert insertresellerJunctionRecords;
        // After deletion of account junction records will be deleted by account trigger.
        try{
        Delete endCustomerAccount;
        }Catch(Exception e){
            system.assert(e.getMessage().Contains('it is associated with the following reseller-end customer rel'),'Account Deleted without deleting related records');
        }
    } 
  
}