/******************************************************************************************************************************
* @author           Demandblue
* @version          1.0 
* @Name      		Test_UserTriggerHandler
* @description 		Test Class for User Trigger and Handler
********************************************************************************************************************************
Version    	Date        	   Team    	     Comments
********************************************************************************************************************************
* 1    		25 Nov 2020    	Jeromia    	Initial Development 
**********************************************************************************************************************************/
@istest
public class Test_UserTriggerHandler {
    
    Public testmethod static void enableContactasPoratlUsers(){
        
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
       /* Insert partnerUsers;
        Set<Id> userIds = new Set<Id>();
        for(User u: partnerUsers){
            userIds.add(u.Id);
        }
        */
        Test.startTest();
         Insert partnerUsers;
       // UserTriggerHandler.insertEndUserAccounts(userIds);
        Test.stopTest();
        System.assertEquals(15,[Select Id From AccountContactRelation].size(),'ACR not created');
    }
    
}