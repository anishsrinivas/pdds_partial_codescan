/******************************************************************************************************************************
* @author           Demandblue
* @version          1.0 
* @Name             Test_LeadTriggerController
* @description      Test Class for Lead Trigger and Handler
********************************************************************************************************************************
Version     Date               Team          Comments
********************************************************************************************************************************
* 1         26 Nov 2020     Jeromia     Initial Development 
*********************************************************************************************************************************************/

@istest
public class Test_LeadTriggerController {
    
    // Create Account,Contact and Portal User
    @testsetup
    public static void createTestRecords(){
        
        List<Lead> leadListInsert = new List<Lead>();
        
        Account portalUserAccount = new Account (Name ='Test',ordertype__c='Reseller');
        Insert portalUserAccount;
        
        Contact partnerContact = new Contact (LastName='TestContact',AccountId = portalUserAccount.Id);
        Insert partnerContact;
        
        
        Profile p = [select Id,name from Profile where Name='Reseller Partner Community'];
        User partnerUser = new User(
            profileId = p.id,
            username = 'Test123PartnerUsertest@test.com',
            email = 'test@test.com',
            emailencodingkey = 'UTF-8',
            localesidkey = 'en_US',
            languagelocalekey = 'en_US',
            timezonesidkey = 'America/Los_Angeles',
            alias='test',
            lastname='partnerUser',
            contactId = partnerContact.Id);
        Insert partnerUser;
        Profile p1 = [select Id,name from Profile where Name='System Administrator'];
        User testUser = new User(
            profileId = p1.id,
            username = 'Test123SFUsertest@test.com',
            email = 'testSF@test.com',
            emailencodingkey = 'UTF-8',
            localesidkey = 'en_US',
            languagelocalekey = 'en_US',
            timezonesidkey = 'America/Los_Angeles',
            alias='testSF',
            lastname='SFUser');
        Insert testUser;
        for(integer i=0;i<10;i++){
            Lead ld = new Lead(LastName='TestLead'+i,Company='Test Company'+i,Budget__c ='Yes',Budget_month__c='$500',LeadSource='Reseller');
            leadListInsert.add(ld);
        }
        // Create lead as a Portal User
        
        System.runas(partnerUser){
            Insert leadListInsert;
        }
        
        
        Reseller_Portal_Values__c resellerPortalValues = new Reseller_Portal_Values__c();
        resellerPortalValues.Reseller_Portal_Name__c = 'Planet DDS Reseller Portal';
        resellerPortalValues.Reseller_Portal_Org_wide_Address__c = 'orders@planetdds.com';
        resellerPortalValues.Name = 'Reseller Portal Defaults';
        System.runAs(testUser){
            Insert resellerPortalValues;
        }
    }
    
    
    
    
    // Test converting leads with exsisting account with any junction record
    public testmethod static void convertLeadWithExistingAccountIdandJunctionRecords(){
        Account resellerAccount = new Account(Name='resellerAccount',ordertype__c='Reseller');
        Insert resellerAccount;
        Contact resellerContact = new Contact (LastName='partnerContact',AccountId=resellerAccount.Id);
        Insert resellerContact;
                
        Profile p = [select Id,name from Profile where Name='Reseller Partner Community'];
        User partnerUser2 = new User(
            profileId = p.id,
            username = 'Test12345PartnerUsertesting@test.com',
            email = 'test@test.com',
            emailencodingkey = 'UTF-8',
            localesidkey = 'en_US',
            languagelocalekey = 'en_US',
            timezonesidkey = 'America/Los_Angeles',
            alias='test',
            lastname='partnerUser',
            contactId = resellerContact.Id);
        
        Test.startTest();
        Insert partnerUser2;
        Test.stopTest(); 
        
        Account endCustomerAccount = new Account(Name='endCustomerAccount');
        Insert endCustomerAccount;  
        
        Reseller_End_Customer_Rel__c rec = new Reseller_End_Customer_Rel__c();
        rec.Regular_Account__c = endCustomerAccount.Id;
        rec.Reseller_Account__c = resellerAccount.Id;
        
        Insert rec;
        
        List<Lead> leadList = [Select Id,LastName,Company,IsConverted From Lead Limit 2];
        
        list<Database.LeadConvert> leadConverts = new list<Database.LeadConvert>();
        
        for(Lead l:leadList){
            Database.LeadConvert lc = new database.LeadConvert();
            lc.leadid = l.id;
            lc.convertedStatus = 'Converted to SQL';
            lc.setDoNotCreateOpportunity(true);
            lc.accountid = endCustomerAccount.id;
            
            leadConverts.add(lc);
        }
        Database.LeadConvertResult[] lcrList = Database.convertLead(leadConverts, false);
        
        for( Database.LeadConvertResult res:lcrList){
            if(!res.isSuccess()){
                system.debug('errorr-->'+res.getErrors());
            }
        }
        
        // 2 leads are converted
        system.assertEquals(2, [Select Id from Lead Where IsConverted=True].size(),'Leads not Converted');
        // 6 ACR are created for 6 Contacts (1 Default+1 resellerContact + 2 on conversion + 1 exisiting JR + 1 added from conversion )
        system.assertEquals(6, [Select Id from AccountContactRelation].size(),'ACR not created for conveted accounts');
        
        
    }
    
    // Convert Leads in Bulk
    public testmethod static void convertLeads(){
        
        List<Lead> leadList = [Select Id,LastName,Company,IsConverted From Lead];
        
        User testuser = [Select Id From User Where Profile.Name = 'System Administrator' AND UserName='Test123SFUsertest@test.com' 
                         Limit 1];
        
        list<Database.LeadConvert> leadConverts = new list<Database.LeadConvert>();
        
        for(Lead l:leadList){
            Database.LeadConvert lc = new database.LeadConvert();
            lc.leadid = l.id;
            lc.convertedStatus = 'Converted to SQL';
            lc.setDoNotCreateOpportunity(true);
            leadConverts.add(lc);
        }
        
        Test.startTest();
        system.runAs(testuser){
            
            Database.LeadConvertResult[] lcrList=   Database.convertLead(leadConverts, false);
            
            for( Database.LeadConvertResult res:lcrList){
                if(!res.isSuccess()){
                    system.debug('errorr-->'+res.getErrors());
                }
            }
        }
        Test.stopTest();
        
        
        
        // Converted leads = 10
        system.assertEquals(10, [Select Id from Lead Where IsConverted=True].size(),'Leads not Converted');
        // 21 ACR's are created for 21 Contacts (1 created from above method+ 10 created on conversion+ 10 juction records)
        system.assertEquals(21, [Select Id from AccountContactRelation].size(),'ACR not created for conveted accounts');
        
        
    }
    
    // Test converting leads with exsisting account without any junction record
    public testmethod static void convertLeadWithExistingAccountId(){
        Account endCustomerAccount = new Account(Name='Test EndCustomer');
        Insert endCustomerAccount;
        
        List<Lead> leadList = [Select Id,LastName,Company,IsConverted From Lead Limit 2];
        
        list<Database.LeadConvert> leadConverts = new list<Database.LeadConvert>();
        
        for(Lead l:leadList){
            Database.LeadConvert lc = new database.LeadConvert();
            lc.leadid = l.id;
            lc.convertedStatus = 'Converted to SQL';
            lc.setDoNotCreateOpportunity(true);
            lc.accountid = endCustomerAccount.id;
            
            leadConverts.add(lc);
        }
        
        Database.LeadConvertResult[] lcrList = Database.convertLead(leadConverts, false);
        
        // 2 leads are converted
        system.assertEquals(2, [Select Id from Lead Where IsConverted=True].size(),'Leads not Converted');
        // 4 ACR created for 4 contacts (1 Default+2 created on lead conversion + 1 endcustomer account from trigger)
        system.assertEquals(4, [Select Id from AccountContactRelation].size(),'ACR not created for conveted accounts');
        
        
    }
    
    
}