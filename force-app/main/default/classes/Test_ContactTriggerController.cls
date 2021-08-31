/******************************************************************************************************************************
* @author           Demandblue
* @version          1.0 
* @Name             Test_ContactTriggerController
* @Description      If Partner Contacts Accounts are updated to another Partner Account,
                    then copy the EndCustomers of new account to updated contact's Related Accounts. 
                    Also delete the Old Account's EndCustomers which are saved as Related Accounts.
********************************************************************************************************************************
Version     Date               Team          Comments
********************************************************************************************************************************
* 1         01 Feb 2021     Jeromia     Initial Development 
********************************************************************************************************************************/


@istest
public class Test_ContactTriggerController {
    
    // Create Reseller Accounts,Contacts and convert them as partner user
    @testSetup
    public static void createTestRecords(){
        List<Account> resellerAccountsInsert = new List<Account>();
        List<Contact> resellerContactsInsert = new List<Contact>();
        
        
        for(integer i=1;i<4;i++){
            Account a = new Account();
            a.Name = 'Reseller Account'+i;
            a.ordertype__c = 'Reseller';
            resellerAccountsInsert.add(a);
        }
        
        Insert resellerAccountsInsert;
        
        for(Account a: resellerAccountsInsert){
            Contact c = new Contact();
            c.LastName = a.Name+'Contact';
            c.AccountId = a.Id;
            c.MobilePhone = '1234567892';
            c.Phone = '1234567895';
            resellerContactsInsert.add(c);
        }
        
        Insert resellerContactsInsert;
        
        Profile p = [select Id,name from Profile where Name='Reseller Partner Community'];
        User newUser1 = new User(profileId = p.id,
                                 username = 'PartnerUserContact1test@test.com',
                                 email = 'test123@test.com',
                                 emailencodingkey = 'UTF-8',
                                 localesidkey = 'en_US',
                                 languagelocalekey = 'en_US',
                                 timezonesidkey = 'America/Los_Angeles',
                                 alias='test',
                                 lastname='PartnerUser1',
                                 contactId = resellerContactsInsert[0].Id);
        
        Insert newUser1;
        
        User newUser2 = new User(profileId = p.id,
                                 username = 'PartnerUserContact2test@test.com',
                                 email = 'test124563@test.com',
                                 emailencodingkey = 'UTF-8',
                                 localesidkey = 'en_US',
                                 languagelocalekey = 'en_US',
                                 timezonesidkey = 'America/Los_Angeles',
                                 alias='test',
                                 lastname='PartnerUser2',
                                 contactId = resellerContactsInsert[1].Id);
        
        Insert newUser2;
        
        User newUser3 = new User(profileId = p.id,
                                 username = 'PartnerUserContact3test@test.com',
                                 email = 'test12389789@test.com',
                                 emailencodingkey = 'UTF-8',
                                 localesidkey = 'en_US',
                                 languagelocalekey = 'en_US',
                                 timezonesidkey = 'America/Los_Angeles',
                                 alias='test',
                                 lastname='PartnerUser3',
                                 contactId = resellerContactsInsert[2].Id);
        
        Insert newUser3;
        
    }
    
    //Update Contacts 1 and 2 Accounts with Account3(Account3 has EC Accounts).
    public testmethod static void updateAccountwithEndCustomers(){
        List<Account> endCustomerAccountsInsert = new List<Account>();
         List<Account> endCustomerAccountsforUpdatedAccounts = new List<Account>();
        List<Reseller_End_Customer_Rel__c> insertEndCustomersJunctionRecordsOldAccount = new  List<Reseller_End_Customer_Rel__c>();
        List<Reseller_End_Customer_Rel__c> insertEndCustomersJunctionRecordsNewAccount = new  List<Reseller_End_Customer_Rel__c>();

        Account resellerAccount1 = [Select Id,Name From Account Where ordertype__c ='Reseller' and Name= 'Reseller Account1' Limit 1];
        Account resellerAccount3 = [Select Id,Name From Account Where ordertype__c ='Reseller' and Name= 'Reseller Account3' Limit 1];
        
        
        for(integer i=1;i<11;i++){
            Account a = new Account();
            a.Name = 'EndCustomer Account'+i;
            endCustomerAccountsInsert.add(a);
        }
        Insert endCustomerAccountsInsert;
        
          for(Account a: endCustomerAccountsInsert){
            Reseller_End_Customer_Rel__c rec = new Reseller_End_Customer_Rel__c();
            rec.Regular_Account__c = a.Id;
            rec.Reseller_Account__c = resellerAccount1.Id;
            insertEndCustomersJunctionRecordsOldAccount.add(rec);
        }  
        
        Insert insertEndCustomersJunctionRecordsOldAccount;
        
        
        for(integer i=1;i<11;i++){
            Account a = new Account();
            a.Name = 'EndCustomer Account Test'+i;
            endCustomerAccountsforUpdatedAccounts.add(a);
        }
        Insert endCustomerAccountsforUpdatedAccounts;
        
        for(Account a: endCustomerAccountsforUpdatedAccounts){
            Reseller_End_Customer_Rel__c rec = new Reseller_End_Customer_Rel__c();
            rec.Regular_Account__c = a.Id;
            rec.Reseller_Account__c = resellerAccount3.Id;
            insertEndCustomersJunctionRecordsNewAccount.add(rec);
        }  
        
        Insert insertEndCustomersJunctionRecordsNewAccount;
        //3 Reseller Accounts+10 EndCustomer Accounts of Account1 + 10 EndCustomer Accounts of Account3
        System.assertEquals(23,[Select Id From AccountContactRelation].size(),'ACR not Created');
        
        List<Contact> updateContactAccountName = new  List<Contact>();
        for(Contact con : [Select Id,Name From Contact Where Account.Name= 'Reseller Account1' OR Account.Name= 'Reseller Account2']){
            
            con.AccountId = resellerAccount3.Id;
            con.Id = con.Id;
            updateContactAccountName.add(con);
        }
        Update updateContactAccountName;
        
        for(AccountContactRelation acr: [Select Id,AccountId,Account.Name,ContactId,Contact.Name From AccountContactRelation]){
            system.debug('ACR-->'+acr.Account.Name+'   '+acr.Contact.Name);
        }
        //3 Reseller Accounts + 10 EC's of A3 Copied to C1 +10 EC's of A3 Copied to C2 +10 EC's of A3 Copied to C3 
        System.assertEquals(33,[Select Id From AccountContactRelation].size(),'ACR not Updated'); 
        
        
        
    }
    
       //Update Contacts 1 and 2 Accounts with Account3(Account3 has no EC Accounts).
    Public testmethod Static void updateAccountwithZeroEndCustomers(){
        
        List<Account> endCustomerAccountsInsert = new List<Account>();
        List<Reseller_End_Customer_Rel__c> insertEndCustomersJunctionRecords = new  List<Reseller_End_Customer_Rel__c>();
        
        Account resellerAccount = [Select Id,Name From Account Where ordertype__c ='Reseller' and Name= 'Reseller Account1' Limit 1];
        
        
        for(integer i=1;i<11;i++){
            Account a = new Account();
            a.Name = 'EndCustomer Account'+i;
            endCustomerAccountsInsert.add(a);
        }
        Insert endCustomerAccountsInsert;
        
        for(Account a: endCustomerAccountsInsert){
            Reseller_End_Customer_Rel__c rec = new Reseller_End_Customer_Rel__c();
            rec.Regular_Account__c = a.Id;
            rec.Reseller_Account__c = resellerAccount.Id;
            insertEndCustomersJunctionRecords.add(rec);
        }   
        
        Insert insertEndCustomersJunctionRecords;
        // 3 Reseller Acc+ 10 EC of Account1
        System.assertEquals(13,[Select Id From AccountContactRelation].size(),'ACR not Created');
        List<Contact> updateContactAccountName = new  List<Contact>();
        Account resellerAccount3 = [Select Id,Name From Account Where ordertype__c ='Reseller' and Name= 'Reseller Account3' Limit 1];
        for(Contact con : [Select Id,Name From Contact Where Account.Name= 'Reseller Account1' OR Account.Name= 'Reseller Account2']){
            con.AccountId = resellerAccount3.Id;
            con.Id = con.Id;
            updateContactAccountName.add(con);
        }
        Update updateContactAccountName;
        //3 Reseller Acc (Acc3 has no EC so no related accounts are created)
        System.assertEquals(3,[Select Id From AccountContactRelation].size(),'ACR not Updated');
    }
    
}