@istest
public class TestPracticeProfileTriggerHandler {

     @testsetup
    public static void CreateBookingOpps(){
        BillingOppsAutomation__c bcs = new BillingOppsAutomation__c();
        bcs.name='Automation';
        bcs.IsActive__c=true;
        bcs.Product_Codes__c='Test Product Code';
        Insert bcs;
        
        List<Account> acclist = new List<Account>();
        Account acc = new Account();
        acc.Name='Test';
        acc.BillingStreet = 'Burlington';
        acc.BillingCity = 'Miami';
        acc.BillingState = 'Florida';
        acc.BillingPostalCode = '12345';
        acc.BillingCountry ='US';
        acc.Practice_Type__c = 'Solo';
        acclist.add(acc);

        Account acc2 = new Account();
        acc2.Name='Test acc2';
        acc2.BillingStreet = 'Burlington';
        acc2.BillingCity = 'Miami';
        acc2.BillingState = 'Florida';
        acc2.BillingPostalCode = '12345';
        acc2.BillingCountry ='US';
          acc2.Practice_Type__c = 'Solo';
        acclist.add(acc2);
        Insert acclist;
       //Test.startTest();
        Opportunity opp = new Opportunity();
        opp.RecordTypeId=Schema.SObjectType.Opportunity.getRecordTypeInfosByName().get('Booking').getRecordTypeId();
        opp.name='Testopp1';
        opp.Stagename='Investigating';
        opp.closeDate=System.today();
        opp.AccountId=acc.Id;
        opp.DDS_OID__c='102';
        opp.DDS_Practice_Location__c='Test';
        opp.Current_Imaging_Solution_Software__c = 'Apteryx *';
        opp.Services_Performed__c = 'Dentist';
        opp.Other_Notes_for_Onboarding__c = 'Test';
        opp.DDS_Proposal_Notes__c = 'Test Proposal';
        opp.Type = 'New Business';
        Insert opp;
        
        Current_Software__c cs = new Current_Software__c();
        cs.Current__c = 'ACE';
        cs.Opportunities__c = opp.Id;
        cs.Quantity__c = 123;
        insert cs;
        
        Test.startTest();
        SBQQ__Quote__c Quote =  new SBQQ__Quote__c();
        Quote.SBQQ__Account__c=acc.Id;
        Quote.SBQQ__Opportunity2__c=opp.Id;
        Quote.SBQQ__Primary__c=True;
        Quote.SBQQ__StartDate__c=system.today();
        insert Quote;
        
       
        SBQQ__QuoteDocument__c quoteDoc = new SBQQ__QuoteDocument__c();
        quoteDoc.Name = 'Test Quote Document';
        quoteDoc.SBQQ__Quote__c = quote.id;
        quoteDoc.SBQQ__Version__c = 1;
        quoteDoc.SBQQ__SignatureStatus__c = 'Completed';
        insert quoteDoc;
        
         ContentVersion contentVersion = new ContentVersion(
            Title = 'Penguins',
            PathOnClient = 'Penguins.jpg',
            VersionData = Blob.valueOf('Test Content'),
            IsMajorVersion = true
        );
        insert contentVersion;    
        List<ContentDocument> documents = [SELECT Id, Title, LatestPublishedVersionId FROM ContentDocument];
        
        //create ContentDocumentLink  record 
        ContentDocumentLink cdl = New ContentDocumentLink();
        cdl.LinkedEntityId = quoteDoc.id;
        cdl.ContentDocumentId = documents[0].Id;
        cdl.shareType = 'V';
        insert cdl;
        
       // List<Current_Software__c> currentSoftwares = new List<Current_Software__c>();
        Current_Software__c cs1 = new Current_Software__c();
        cs1.Current__c  = 'ACE';
        cs1.Opportunities__c = opp.Id;
        //cs1.Other_PMS_Detail__c = 'Other1';
        cs1.Quantity__c = 100;
        Insert cs1;
               
        List<Contact> Conlist= new List<Contact>();
        Contact con1 = new Contact();
        con1.FirstName = 'Test1';
        con1.LastName = 'DB';
        con1.Email = 'abcd@gmail.com';
        con1.Phone = '1289999999,1289999998';
        con1.MobilePhone='1289001234';
        con1.Title='Manager,RM';
        con1.AccountId = acc.Id;
        Conlist.add(con1);
        Contact con2 = new Contact();
        con2.FirstName = 'Test3,Test4';
        con2.LastName = 'DB,test';
        con2.Email = 'abcd@gmail.com';
        con2.Phone = '1289001234,999999';
        con2.MobilePhone='1289001234';
        con2.Title='Manager,RM';
        con2.AccountId = acc.Id;
        Conlist.add(con2);
        Insert Conlist;
        
        List<AccountContactRelation> acrList = new List<AccountContactRelation>();
        AccountContactRelation acr = new AccountContactRelation();
        acr.AccountId=acclist[1].Id;
        acr.ContactId=Conlist[0].Id;
        acrList.add(acr);
        AccountContactRelation acr2 = new AccountContactRelation();
        acr2.AccountId=acclist[1].Id;
        acr2.ContactId=Conlist[1].Id;
        acrList.add(acr2);
        Insert acrList;

        
        Id pricebookId = Test.getStandardPricebookId();
        
        //Create your product
        Product2 prod = new Product2(
             Name = 'Product X',
             ProductCode = 'Pro-X',
             isActive = true
        );
        insert prod;
        
        //Create your pricebook entry
        PricebookEntry pbEntry = new PricebookEntry(
             Pricebook2Id = pricebookId,
             Product2Id = prod.Id,
             UnitPrice = 100.00,
             IsActive = true
        );
        insert pbEntry;
        
       //  Test.startTest();
        //create your opportunity line item.  This assumes you already have an opportunity created, called opp
        OpportunityLineItem oli = new OpportunityLineItem(
             OpportunityId = opp.Id,
             Quantity = 5.0,
             PricebookEntryId = pbEntry.Id,
            
             TotalPrice = 5 * (pbEntry.UnitPrice)
        );
        insert oli;
        
            Test.stopTest();   
        
    }
    @isTest
    public static void InsertQuoteandPracticeFilesTest(){
        
 
        Opportunity op = [select StageName,RecordTypeId,SBQQ__PrimaryQuote__c from opportunity 
                          where name=:'Testopp1' Limit 1];
        SBQQ__Quote__c quote=[select id from SBQQ__Quote__c Limit 1];
        op.SBQQ__PrimaryQuote__c = quote.id;
        op.Stagename='Closed Won';
        op.Needs_Implementation__c='Yes';
        op.Sales_Qualified_Appointment__c=true;
        op.Was_there_a_Sensor_s_Sale__c = 'Yes';
        op.How_Many_Sensors_were_Sold__c = 2;
        RecursiveTriggerHandler.isFirstTime=true;
        op.Type = 'New Business';
        op.RecordTypeId=Schema.SObjectType.Opportunity.getRecordTypeInfosByName().get('Booking').getRecordTypeId();
        //op.Claw_Back__c = false;
        Test.startTest();
        update op;

        Test.stopTest();
    
        
    }
}