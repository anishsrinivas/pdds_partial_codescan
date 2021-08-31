@istest (SeeAllData=false)
public class Batch_NotificationOnAssetConversionTest {
    @testsetup
    public  static void testasset()
    {
        
        Reseller_Portal_Values__c resellerPortalValues = new Reseller_Portal_Values__c();
        resellerPortalValues.Reseller_Portal_Name__c = 'Planet DDS Reseller Portal';
        resellerPortalValues.Reseller_Portal_Org_wide_Address__c = 'orders@planetdds.com';
        resellerPortalValues.Name = 'Reseller Portal Defaults';
        
        Insert resellerPortalValues;
        
        Account accountobject=new account();
        accountobject.name='Test Account';
        accountobject.AccountSource='Reseller';
        accountobject.Description='Test Description';
        accountobject.Notes__c='Test Notes';
        accountobject.BillingStreet = 'test';
        accountobject.BillingCity = 'Irvine';
        accountobject.BillingCountry = 'USA';
        accountobject.BillingState = 'CA';
        accountobject.BillingPostalCode = '560123';
        accountobject.PGID__c = 2244;                                                                
        accountobject.PGID_OID__c = '2244-888';                                                         
        accountobject.DBA__c = '2CP Demo Account';                                                      
        accountobject.ia_crm__IntacctID__c = '2244-000';                                                
        accountobject.ia_crm__Email_ID__c = 'sfadmin@demandblue.com';   
        
        insert accountobject;
        
        Account endcustomer =new account();
        endcustomer.name='Test EC Account';
        endcustomer.AccountSource='Partner';
        endcustomer.Description='Test Description';
        endcustomer.Notes__c='Test Notes';
        insert endcustomer;
        
        
        BillingOppsAutomation__c billingobject = new BillingOppsAutomation__c();
        billingobject.name='Automation';
        billingobject.IsActive__c=true;
        Insert billingobject;
        
        
        Contact contactobject=new contact();
        contactobject.LastName='Test Contact';
        contactobject.AccountId=accountobject.id;
        contactobject.Email='test@test.com';
        contactobject.Phone = '1234567895';
        contactobject.MobilePhone = '1234567895';
        insert contactobject;
        
        ia_crm__Intacct_Entity__c ia = new ia_crm__Intacct_Entity__c();
        ia.Name = 'Test';
        ia.ia_crm__Status__c = True;
        Insert ia;
        
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
            contactId = contactobject.Id);
        Insert partnerUser;
        
        Id pricebookId = Test.getStandardPricebookId();        
        
        Product2 prod = new Product2(
            Name = 'Product X',
            ProductCode = 'Pro-X',
            Family = 'Image Conversions',
            isActive = true
        );
        insert prod;
        
        PricebookEntry pbEntry = new PricebookEntry(
            Pricebook2Id = pricebookId,
            Product2Id = prod.Id,
            UnitPrice = 100.00,
            IsActive = true
        );
        insert pbEntry;
        
        
    }
    
    
    public static testmethod void NotificationOnAssetConversionHandlerFail()
    {
        Account accounttoinsert=[select id,name from Account where name='Test Account'];
        Account endaccountcustomertoinsert=[select id,name from Account where name='Test EC Account'];
        Product2 producttoinsert=[select id,name from Product2 where name='Product X'];
        
        Opportunity op = new Opportunity();
        op.RecordTypeId=Schema.SObjectType.Opportunity.getRecordTypeInfosByName().get('Booking').getRecordTypeId();
        op.Pricebook2Id = Test.getStandardPricebookId();
        op.Name='Test Opp';
        op.closeDate=system.today();
        op.stagename='Investigating';
        op.Type='New Business';
        op.DDS_Proposal_Notes__c='Notes';
        op.Current_Imaging_Solution_Software__c='Apteryx DrSuni *';
        op.Services_Performed__c='Dentist';
        op.Other_Notes_for_Onboarding__c='testing imp';
        //op.OwnerId=partnerusertoinsert.id;   
        op.AccountId=accounttoinsert.id;
        op.LeadSource='Refferal';
        op.Sales_Qualified_Appointment__c=true;
        op.Is_Created_By_Batch__c = true;
        op.End_Customer_Ship_To_Account__c = endaccountcustomertoinsert.id;
        Insert op;
        
        List<Asset> Assetlist=new list<Asset>();
        Asset assetobject=new asset();
        assetobject.Product2Id=producttoinsert.id;
        assetobject.name='Product X';
        assetobject.AccountId=accounttoinsert.id;
        assetobject.End_Customer_Ship_To_Account__c=endaccountcustomertoinsert.id;
        assetobject.Linked_Booking_Opportunity__c=op.id;
        assetobject.Status='Shipped';
        assetobject.Price=789999;
        assetobject.Quantity=45;
        assetobject.SerialNumber='1233456';
        Assetlist.add(assetobject);
        insert Assetlist;
        
        Test.startTest();
        Batch_NotificationOnAssetConversion bc = new Batch_NotificationOnAssetConversion();
        Id batchId = Database.executeBatch(bc);
        //NotificationOnAssetConversionHandler.getAssetsOfBookingOpportunity(Assetlist);
        Test.stopTest();
        
        
    }
    
    
    public static testmethod void  NotificationOnAssetConversionHandlerSuccess()
    {
        Account accounttoinsert=[select id,name from Account where name='Test Account'];
        Account endaccountcustomertoinsert=[select id,name from Account where name='Test EC Account'];
        User partnerusertoinsert=[select id,email from User where email='test@test.com'];
        Product2 producttoinsert=[select id,name from Product2 where name='Product X'];
        
        
        Opportunity op = new Opportunity();
        op.RecordTypeId=Schema.SObjectType.Opportunity.getRecordTypeInfosByName().get('Booking').getRecordTypeId();
        op.Pricebook2Id = Test.getStandardPricebookId();
        op.Name='Test Opp';
        op.closeDate=system.today();
        op.stagename='Investigating';
        op.Type='New Business';
        op.DDS_Proposal_Notes__c='Notes';
        op.Current_Imaging_Solution_Software__c='Apteryx DrSuni *';
        op.Services_Performed__c='Dentist';
        op.Other_Notes_for_Onboarding__c='testing imp';
        op.OwnerId=partnerusertoinsert.id;   
        op.AccountId=accounttoinsert.id;
        op.LeadSource='Refferal';
        op.Sales_Qualified_Appointment__c=true;
        op.Is_Created_By_Batch__c = true;
        op.End_Customer_Ship_To_Account__c = endaccountcustomertoinsert.id;
        Insert op;
        
        NotificationToResellerController nrc = new NotificationToResellerController();
        nrc.getPreTaxSubTotal();
        nrc.getTextMessage();
        List<Asset> Assetlist=new list<Asset>();
        for( integer i=0;i<400;i++)
        {
            Asset assetobject=new asset();
            assetobject.Product2Id=producttoinsert.id;
            assetobject.name='Product X'+i;
            assetobject.AccountId=accounttoinsert.id;
            assetobject.End_Customer_Ship_To_Account__c=endaccountcustomertoinsert.id;
            assetobject.Linked_Booking_Opportunity__c=op.id;
            assetobject.Price=789999;
            assetobject.Quantity=45;
            assetobject.Status='Shipped';
            assetobject.SerialNumber='1233456'+i;
            Assetlist.add(assetobject);
        }
        
        insert Assetlist;
        
        List<Opportunity> Opportunitylist=new list<Opportunity>();
        for( integer i=0;i<=5;i++)
        {
            Opportunity op2 = new Opportunity();
            op2.RecordTypeId=Schema.SObjectType.Opportunity.getRecordTypeInfosByName().get('Booking').getRecordTypeId();
            op2.Pricebook2Id = Test.getStandardPricebookId();
            op2.Name='Test Opp'+i;
            op2.closeDate=system.today();
            op2.stagename='Investigating';
            op2.Type='New Business';
            op2.DDS_Proposal_Notes__c='Notes';
            op2.Current_Imaging_Solution_Software__c='Apteryx DrSuni *';
            op2.Services_Performed__c='Dentist';
            op2.Other_Notes_for_Onboarding__c='testing imp';
            op2.OwnerId=partnerusertoinsert.id;   
            op2.AccountId=accounttoinsert.id;
            op2.LeadSource='Refferal';
            op2.Sales_Qualified_Appointment__c=true;
            op2.Is_Created_By_Batch__c = true;
            op2.End_Customer_Ship_To_Account__c = endaccountcustomertoinsert.id;
            Opportunitylist.add(op2);   
        }
        //insert Opportunitylist;
        
        List<Asset> Assetlistdifferent=new list<Asset>();
        
        for( integer i=0;i<=5;i++)
        {
            Asset assetobject=new asset();
            assetobject.Product2Id=producttoinsert.id;
            assetobject.name='Product Y'+i;
            assetobject.AccountId=accounttoinsert.id;
            assetobject.End_Customer_Ship_To_Account__c=endaccountcustomertoinsert.id;
            assetobject.Price=789999;
            assetobject.Quantity=45;  
            
            
            assetobject.Linked_Booking_Opportunity__c=op.id;
            
            assetobject.Status='Shipped';
            assetobject.SerialNumber='1233456'+i;
            Assetlistdifferent.add(assetobject);
            system.debug('assetobject'+assetobject) ; 
        }
        
        insert Assetlistdifferent;
        Test.startTest();
        Batch_NotificationOnAssetConversion bc = new Batch_NotificationOnAssetConversion();
        Id batchId = Database.executeBatch(bc,200);
        
        Test.stopTest();
        
    }
    
    Public static testMethod void testschedule(){
        
        Test.StartTest();
        Account accounttoinsert=[select id,name from Account where name='Test Account'];
        Account endaccountcustomertoinsert=[select id,name from Account where name='Test EC Account'];
        User partnerusertoinsert=[select id,email from User where email='test@test.com'];
        Product2 producttoinsert=[select id,name from Product2 where name='Product X'];
        
        
        Opportunity op = new Opportunity();
        op.RecordTypeId=Schema.SObjectType.Opportunity.getRecordTypeInfosByName().get('Booking').getRecordTypeId();
        op.Pricebook2Id = Test.getStandardPricebookId();
        op.Name='Test Opp';
        op.closeDate=system.today();
        op.stagename='Investigating';
        op.Type='New Business';
        op.DDS_Proposal_Notes__c='Notes';
        op.Current_Imaging_Solution_Software__c='Apteryx DrSuni *';
        op.Services_Performed__c='Dentist';
        op.Other_Notes_for_Onboarding__c='testing imp';
        op.OwnerId=partnerusertoinsert.id;   
        op.AccountId=accounttoinsert.id;
        op.LeadSource='Refferal';
        op.Sales_Qualified_Appointment__c=true;
        op.Is_Created_By_Batch__c = true;
        op.End_Customer_Ship_To_Account__c = endaccountcustomertoinsert.id;
        Insert op;
        
        Asset assetobject=new asset();
        assetobject.Product2Id=producttoinsert.id;
        assetobject.name='Product Y';
        assetobject.AccountId=accounttoinsert.id;
        assetobject.End_Customer_Ship_To_Account__c=endaccountcustomertoinsert.id;
        assetobject.Price=789999;
        assetobject.Quantity=45;  
        assetobject.Linked_Booking_Opportunity__c=op.id;
        assetobject.Status='Shipped';
        assetobject.SerialNumber='1233456';
        insert assetobject;
        
        ScheduleNotificationOfAssetBatch shedule = new ScheduleNotificationOfAssetBatch();
        String sch =  '0 0 * * * ?';
        Id jobId = system.schedule('Test', sch, shedule);
        Test.stopTest(); 
        cronTrigger ct =[select id,cronExpression from cronTrigger where id=:jobId];
        
    }
}