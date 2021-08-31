@Istest
public class TestResellerBookingOpps {
    
    @testsetup
    public static void CreateBookingOpps(){
    
        //create account
      
        Account acc = new Account();
        acc.Name='test';
        acc.Notes__c='test data';
        acc.Description='test description';
        acc.ordertype__c='Reseller';
        Insert acc;
        
        Contact partnerContact = new Contact (LastName='TestContact',
                                              AccountId = acc.Id,
                                              MobilePhone='0987654323',
                                              Phone='8967452312',
                                              LID__LinkedIn_Company_Id__c='987654677');
        Insert partnerContact;
        
        BillingOppsAutomation__c bcs = new BillingOppsAutomation__c();
        bcs.name='Automation';
        bcs.IsActive__c=false;
        insert bcs;
        
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
        
        Reseller_Portal_Values__c resellerPortalValues = new Reseller_Portal_Values__c();
        resellerPortalValues.Reseller_Portal_Name__c = 'Reseller Partner Portal';
        resellerPortalValues.Reseller_Portal_Org_wide_Address__c ='sfadmin@demandblue.com';
        resellerPortalValues.SF_Admin__c = 'sfadmin@demandblue.com';
        resellerPortalValues.Name = 'Reseller Portal Defaults';
        
        System.runAs(testUser){
            Insert resellerPortalValues;
            //Insert bcs;
       } 
        
        
        Id pricebookId = Test.getStandardPricebookId();
        
        ///list<Product2> prodlist = new list<Product2>();
        //for( integer i=1;i<=2;i++){
            Product2 prod = new Product2();
            prod.Name = 'Testp';
            prod.ProductCode = 'TP';
            prod.isActive = true;
           // prodlist.add(prod);
        //}
        
        insert prod;
        
        ///list<PricebookEntry> pbelist = new list<PricebookEntry>();
        
        //for(Product2 pd :prodlist){
            
            PricebookEntry pbEntry = new PricebookEntry();
            pbEntry.Pricebook2Id = pricebookId;
            pbEntry.Product2Id = prod.Id;
            pbEntry.UnitPrice = 100.00;
            pbEntry.IsActive = true;
            //pbelist.add(pbEntry);
            
       // }
        
        insert pbEntry;
        
        //create opportunity
        Test.startTest(); 
        Id bookingRecordTypeId = Schema.SObjectType.Opportunity.getRecordTypeInfosByName().get('Booking').getRecordTypeId();
        Opportunity op = new Opportunity();
        op.RecordTypeId=bookingRecordTypeId;
        op.AccountId=acc.Id;
        op.Name='Test Opp';
        op.closeDate=system.today()+90;
        op.stagename='Investigating';
        op.Type='New Business';
        op.DDS_Proposal_Notes__c='Notes';
        op.Current_Imaging_Solution_Software__c='Apteryx DrSuni *';
        op.Services_Performed__c='Dentist';
        op.Other_Notes_for_Onboarding__c='testing imp';
        op.LeadSource='Refferal';
        //op.Sales_Qualified_Appointment__c=true;
        op.Reseller_Opp__c=true;
        op.Pricebook2Id=pricebookId;
         
        Insert op;
        
        
        //create current software
        
        Current_Software__c cs= new Current_Software__c();
        cs.Current__c='ACE';
        cs.Quantity__c=1;
        cs.Opportunities__c=op.Id;
        Insert cs;
        
        //create primary quote
         
        SBQQ__Quote__c Quote =  new SBQQ__Quote__c();
        Quote.SBQQ__Account__c=acc.Id;
        Quote.SBQQ__Opportunity2__c=op.Id;
        Quote.SBQQ__StartDate__c=System.today();
        Quote.SBQQ__Type__c='Draft';
        Quote.SBQQ__SubscriptionTerm__c=12;
        Quote.SBQQ__Primary__c=True;
        Quote.SBQQ__PricebookId__c=pricebookId;
        Quote.SBQQ__PriceBook__c=pricebookId;
        insert Quote;
         Test.stopTest(); 
      
        OpportunityLineItem oli = new OpportunityLineItem(
            OpportunityId = op.Id,
            Quantity = 5.0,
            Product2Id=prod.Id,
            PricebookEntryId = pbEntry.Id,
            TotalPrice = 5 * pbEntry.UnitPrice
        );
        insert oli;
        
       
        
        
        
        
        
        
       
       
        
    }
    
    @istest
    public static void testingopportunity()
    {
        Opportunity opp=[select id ,name,stagename from opportunity where name='Test Opp'];
        Test.startTest();
        opp.stagename='Closed Won';
        update opp;
        
        List<Id> updatedOppId = new  List<Id>();
        for(opportunity o: [select id ,name,stagename from opportunity where name='Test Opp']){
            updatedOppId.add(o.Id);
        }
        
        NotificationOnResellerBookingOpp.sendEmailNotification(updatedOppId);
        Test.stopTest();
        
    }
    
}