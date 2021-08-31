/******************************************************************************************************************************
* @author           Demandblue
* @version          1.0 
* @Name      		Test_ResellerEndCustomer
* @description 		Test Class for ResellerEndCustomer Trigger and Handler
********************************************************************************************************************************
Version    	Date        	   Team    	     Comments
********************************************************************************************************************************
* 1    		26 Nov 2020    	Jeromia    	Initial Development 
**************************************************************************************************************************************/
@istest
public class Test_ResellerEndCustomer {
    
    // Create Test EndCustomer and Reseller accounts, Poratl Users
    
    @testsetup
    Public static void createTestdata(){
        List<Account> resellerAccountsInsert = new List<Account>();
        List<Account> endCustomerAccountsInsert = new List<Account>();
        List<Contact> resellerContactsInsert = new List<Contact>();
        
        for(integer i=1;i<11;i++){
            Account a = new Account();
            a.Name = 'EndCustomer Account'+i;
            endCustomerAccountsInsert.add(a);
        }
        
        for(integer i=1;i<11;i++){
            Account a = new Account();
            a.Name = 'Reseller Account'+i;
            a.ordertype__c = 'Reseller';
            resellerAccountsInsert.add(a);
        }
        
        Insert endCustomerAccountsInsert;
        Insert resellerAccountsInsert;
        
        for(Account a: resellerAccountsInsert){
            Contact c = new Contact();
            c.LastName = a.Name+'Contact';
            c.AccountId = a.Id;
            resellerContactsInsert.add(c);
        }
        
        Insert resellerContactsInsert;
        
        Profile p = [select Id,name from Profile where Name='Reseller Partner Community'];
        List<User> partnerUsers = new List<User>();
        for(Integer i=0;i<10;i++){
            User newUser = new User(
                profileId = p.id,
                username = i+'PartnerUsertest@test.com',
                email = i+'test@test.com',
                emailencodingkey = 'UTF-8',
                localesidkey = 'en_US',
                languagelocalekey = 'en_US',
                timezonesidkey = 'America/Los_Angeles',
                alias='test',
                lastname='PartnerUser'+i,
                contactId = resellerContactsInsert[i].Id);
            partnerUsers.add(newUser);
        }
        Insert partnerUsers;
        
        
    }
    
    
    // Insert multiple resellers to one EndCustomer
   Public testmethod Static void insertResellerAccountstoEndCustomers(){
        
        List<Reseller_End_Customer_Rel__c> insertresellerJunctionRecords = new  List<Reseller_End_Customer_Rel__c>();
        List<Account> resellerAccounts = [Select Id,Name From Account Where ordertype__c ='Reseller' Limit 5];
        
        Account endCustomerAccount = [Select Id,Name From Account Where ordertype__c !='Reseller' Limit 1];
        
        for(Account a:resellerAccounts){
            Reseller_End_Customer_Rel__c rec = new Reseller_End_Customer_Rel__c();
            rec.Regular_Account__c = endCustomerAccount.Id;
            rec.Reseller_Account__c = a.Id;
            insertresellerJunctionRecords.add(rec);
        }
        
        Insert insertresellerJunctionRecords;
        
       // Direct Relation 10 and 5 new EndCustomers added (10+5)
        System.assertEquals(15,[Select Id From AccountContactRelation].size(),'ACR not Created');
    }
    
        // Insert multiple EndCustomers  to one reseller

    Public testmethod Static void insertEndCustomerstoResellerAccounts(){
        
        List<Reseller_End_Customer_Rel__c> insertEndCustomersJunctionRecords = new  List<Reseller_End_Customer_Rel__c>();
        List<Account> endCustomerAccounts = [Select Id,Name From Account Where ordertype__c !='Reseller' Limit 5];
        
        Account resellerAccount = [Select Id,Name From Account Where ordertype__c ='Reseller' Limit 1];
        
        for(Account a:endCustomerAccounts){
            Reseller_End_Customer_Rel__c rec = new Reseller_End_Customer_Rel__c();
            rec.Regular_Account__c = a.Id;
            rec.Reseller_Account__c = resellerAccount.Id;
            insertEndCustomersJunctionRecords.add(rec);
        }
        
        Insert insertEndCustomersJunctionRecords;
          // Direct Relation 10 and 5 new EndCustomers added (10+5)
        System.assertEquals(15,[Select Id From AccountContactRelation].size(),'ACR not Created');
        
    }
    
    // Insert duplicate records insertion when there is no existing relationship to validate error message
    Public testmethod Static void testAlertMessagewithZeroExisitingRecords(){
        List<Reseller_End_Customer_Rel__c> insertSameReseller = new List<Reseller_End_Customer_Rel__c>();
        
        Account endCustomerAccount = [Select Id,Name From Account Where ordertype__c !='Reseller' Limit 1];
        Account resellerAccount = [Select Id,Name From Account Where ordertype__c ='Reseller' Limit 1];
        
        for(Integer i=0;i<3;i++)
        {
            Reseller_End_Customer_Rel__c rec = new Reseller_End_Customer_Rel__c();
            rec.Regular_Account__c = endCustomerAccount.Id;
            rec.Reseller_Account__c = resellerAccount.Id;
            insertSameReseller.add(rec);
        } 
        Try{ 
            Insert insertSameReseller;
            // 1 default and 1 new relationship
            system.assertEquals(2, [Select Id From Reseller_End_Customer_Rel__c].size(),'Junction records not created');
        }Catch(Exception e){
            // duplicate relationship
            system.assert(e.getMessage().contains('End-Customer/Reseller Account Relationship Already Exists'),'Duplicate Junction record Created');
        }
        
        
    }
    
        // Insert duplicate records insertion when there is existing relationship to validate error message
         
    Public testmethod Static void testAlertMessagewithExisitingRecords(){
        List<Reseller_End_Customer_Rel__c> insertSameReseller = new List<Reseller_End_Customer_Rel__c>();
        
        Account endCustomerAccount = [Select Id,Name From Account Where ordertype__c !='Reseller' Limit 1];
        Account resellerAccount = [Select Id,Name From Account Where ordertype__c ='Reseller' Limit 1];
        Reseller_End_Customer_Rel__c rec = new Reseller_End_Customer_Rel__c();
        
        rec.Regular_Account__c = endCustomerAccount.Id;
        rec.Reseller_Account__c = resellerAccount.Id;
        Insert rec;
        
        for(Integer i=0;i<3;i++)
        {
            Reseller_End_Customer_Rel__c recdup = new Reseller_End_Customer_Rel__c();
            recdup.Regular_Account__c = endCustomerAccount.Id;
            recdup.Reseller_Account__c = resellerAccount.Id;
            insertSameReseller.add(recdup);
        } 
        Try{ 
            Insert insertSameReseller;
            system.assertEquals(2, [Select Id From Reseller_End_Customer_Rel__c].size(),'Junction Records not Created');
        }Catch(Exception e){
            
            system.assert(e.getMessage().contains('End-Customer/Reseller Account Relationship Already Exists'),'Duplicate Junction record Created');
        }
    }
    
    // Delete the junctionRecords and verify the count of ACR
    Public testmethod static void deleteJunctionRecords(){
        List<Reseller_End_Customer_Rel__c> insertresellerJunctionRecords = new  List<Reseller_End_Customer_Rel__c>();
        List<Account> resellerAccounts = [Select Id,Name From Account Where ordertype__c ='Reseller' Limit 5];
        
        Account endCustomerAccount = [Select Id,Name From Account Where ordertype__c !='Reseller' Limit 1];
        
        for(Account a:resellerAccounts){
            Reseller_End_Customer_Rel__c rec = new Reseller_End_Customer_Rel__c();
            rec.Regular_Account__c = endCustomerAccount.Id;
            rec.Reseller_Account__c = a.Id;
            insertresellerJunctionRecords.add(rec);
        }
        
        Insert insertresellerJunctionRecords;
        
        List<Reseller_End_Customer_Rel__c> recordstoDelete = [Select Id,Regular_Account__c,Reseller_Account__c 
                                                              From Reseller_End_Customer_Rel__c Limit 5];
        Delete recordstoDelete;
        
        system.assertEquals(10, [Select Id From AccountContactRelation].size(),'ACR not Created');
        
    }
    
    // Update the junctionRecords and verify the ACR Count
    
    Public testmethod static void updateResellerJunctionRecords(){
        List<Reseller_End_Customer_Rel__c> insertEndCustomersJunctionRecords = new  List<Reseller_End_Customer_Rel__c>();
        List<Account> endCustomerAccounts = [Select Id,Name From Account Where ordertype__c !='Reseller' Limit 5];
        
        Account resellerAccount = [Select Id,Name From Account Where ordertype__c ='Reseller' Limit 1];
        for(Account a:endCustomerAccounts){
            Reseller_End_Customer_Rel__c rec = new Reseller_End_Customer_Rel__c();
            rec.Regular_Account__c = a.Id;
            rec.Reseller_Account__c = resellerAccount.Id;
            insertEndCustomersJunctionRecords.add(rec);
        }
        
        Insert insertEndCustomersJunctionRecords;
        
        Account resellerforUpdate = new Account (Name ='resellerforUpdate',ordertype__c='Reseller');
        Insert resellerforUpdate;
        
       Contact resellerContact = new Contact (LastName='ResellerContactUpdate',AccountId = resellerforUpdate.Id);
        Insert resellerContact;
        
        
         Profile p = [select Id,name from Profile where Name='Reseller Partner Community'];
            User newUser = new User(
                profileId = p.id,
                username = 'Test123PartnerUsertest123@test.com',
                email = 'test@test.com',
                emailencodingkey = 'UTF-8',
                localesidkey = 'en_US',
                languagelocalekey = 'en_US',
                timezonesidkey = 'America/Los_Angeles',
                alias='test',
                lastname='PartnerUser',
                contactId = resellerContact.Id);
        
        Test.startTest();
        Insert newUser;
        Test.stopTest();
        

        
        List<Reseller_End_Customer_Rel__c> updateEndCustomersJunctionRecords = [Select Id,Reseller_Account__c,Regular_Account__c
                                                                               From Reseller_End_Customer_Rel__c];
        for(Reseller_End_Customer_Rel__c rec:updateEndCustomersJunctionRecords){
            rec.Reseller_Account__c = resellerforUpdate.Id;
        }
        Update updateEndCustomersJunctionRecords;
                
        
        system.assertEquals(16,[Select Id From AccountContactRelation].size(),'ACR not Created');
    }
    
    
}