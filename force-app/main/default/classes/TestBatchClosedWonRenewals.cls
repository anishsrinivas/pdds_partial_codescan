/*
 Description : Test class for the Batch Class 'BatchClosedWonRenewals' 

 Author      : Ramana 

 Created Date: 08/17/2020
*/
@Istest
Private class TestBatchClosedWonRenewals {   
    @Istest
     Private static void TestclosewinRenewals(){
         
         
         Product2 prod = new Product2();
        prod.name='TestProd';
        prod.ProductCode = '12345';
        Insert prod;
        
        Account acc = new Account();
        acc.Name='Test';
        Insert acc;
         
        Contact c = new Contact();
        c.AccountId=acc.Id;
        c.LastName='test';
        insert c;
        
        Opportunity bookOpp = new Opportunity();
        bookOpp.RecordTypeId=Schema.SObjectType.Opportunity.getRecordTypeInfosByName().get('Booking').getRecordTypeId();
        bookOpp.Name = 'Booking Opp';
        bookOpp.Stagename='Investigating';
        bookOpp.closeDate=System.today();
        bookOpp.AccountId=acc.Id;
        insert bookOpp;

        Opportunity opp = new Opportunity();
        opp.RecordTypeId=Schema.SObjectType.Opportunity.getRecordTypeInfosByName().get('Billing').getRecordTypeId();
        opp.name='Testopp';
        opp.Stagename='Investigating';
        opp.closeDate=System.today();
        opp.AccountId=acc.Id;
        opp.DDS_OID__c='101';
        opp.DDS_Practice_Location__c='Test';
        opp.ia_crm__Change_Type__c='New MRR';
        opp.SBQQ__Renewal__c=true;
        opp.Linked_Booking_Opportunity__c = bookOpp.Id;
   
        Insert opp;
         
           
        SBQQ__Quote__c Quote =  new SBQQ__Quote__c();
        Quote.SBQQ__Account__c=acc.Id;
        Quote.SBQQ__Opportunity2__c=opp.Id;
        Quote.SBQQ__Primary__c=True;
         
        insert Quote;
        

        SBQQ__Quoteline__c Quoteline =  new SBQQ__Quoteline__c();
        Quoteline.SBQQ__Quote__c=Quote.Id;
        Quoteline.SBQQ__Product__c=prod.Id;
        Quoteline.SBQQ__Quantity__c=1;
        
         Insert Quoteline;
        
        
        Pricebook2 standardPricebook = new Pricebook2(
        Id = Test.getStandardPricebookId(),
        IsActive = true);
        
        update standardPricebook;
        
        standardPricebook = [SELECT IsStandard FROM Pricebook2 WHERE Id = :standardPricebook.Id];
        
        PricebookEntry prbe = new PricebookEntry();
        prbe.pricebook2id=standardPricebook.id;
        prbe.product2id = prod.id;
        prbe.unitprice=1.0;
        prbe.isActive=true;
        Insert prbe;
         

        OpportunityLineItem opl = new OpportunityLineItem();
        opl.OpportunityId=opp.id;
        opl.Product2Id=prod.Id;
        opl.Quantity=1;
        opl.UnitPrice=50;
        opl.PricebookEntryId=prbe.Id;
        opl.DDS_Net_Unit_Price_Monthly__c = 34.0;

        Insert opl;
          
         
      Test.startTest();
         
      database.executeBatch(new BatchClosedWonRenewals(new List<String>()),1);
        

        Test.stopTest();
         
         
    Opportunity OppQ=[select Stagename from Opportunity where id= :opp.Id];    

     System.assertEquals('Closed Won', OppQ.StageName); 
     
     
    }
}