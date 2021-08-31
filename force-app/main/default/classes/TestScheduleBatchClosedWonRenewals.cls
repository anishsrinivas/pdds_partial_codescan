/*
 Description : Test class for the Batch Class 'ScheduleBatchClosedWonRenewals' 

 Author      : Ramana 

 Created Date: 08/17/2020
*/
@Istest
Private class TestScheduleBatchClosedWonRenewals{   
    @Istest
     Private static void TestclosewinRenewals(){
         
         Test.startTest();
         Product2 prod = new Product2();
        prod.name='TestProd';
        prod.ProductCode = '12345';
        Insert prod;
        
        Account acc = new Account();
        acc.Name='Test';
        Insert acc;
        

        Integer i=0;
        list<Opportunity> opplist=new list<Opportunity>();
        List<Opportunity> bookOpps = new List<Opportunity>();
        for(i=1;i<5;i++) {
        
            Opportunity bookOpp = new Opportunity();
            bookOpp.RecordTypeId=Schema.SObjectType.Opportunity.getRecordTypeInfosByName().get('Booking').getRecordTypeId();
            bookOpp.name = 'Booking Opportunity' + i;
            bookOpp.StageName = 'Investigating';
            bookOpp.CloseDate = System.today();
            bookOpp.AccountId = acc.Id;
            bookOpps.add(bookOpp);
        
        }
        
        insert bookOpps;
        
        for(i=1;i<5;i++) {
        Opportunity opp = new Opportunity();
        opp.RecordTypeId=Schema.SObjectType.Opportunity.getRecordTypeInfosByName().get('Billing').getRecordTypeId();
        opp.name='Testopp'+i;
        opp.Stagename='Investigating';
        opp.closeDate=System.today();
        opp.AccountId=acc.Id;
        opp.DDS_OID__c='101';
        opp.DDS_Practice_Location__c='Test';
        opp.ia_crm__Change_Type__c='New MRR';
        opp.SBQQ__Renewal__c=true;
        opp.Linked_Booking_Opportunity__c = bookOpps[0].Id;
        opplist.add(opp);
         }
        Insert opplist;
         
        
        list<SBQQ__Quote__c> QuoteList = new list<SBQQ__Quote__c>();
         for(Opportunity op: opplist){
        SBQQ__Quote__c Quote =  new SBQQ__Quote__c();
        Quote.SBQQ__Account__c=acc.Id;
        Quote.SBQQ__Opportunity2__c=op.Id;
        Quote.SBQQ__Primary__c=True;
        QuoteList.add(Quote);
         }
        insert QuoteList;
        
        list<SBQQ__Quoteline__c> Qllist = new list<SBQQ__Quoteline__c>();
        for(SBQQ__Quote__c qt :QuoteList){
        SBQQ__Quoteline__c Quoteline =  new SBQQ__Quoteline__c();
        Quoteline.SBQQ__Quote__c=qt.Id;
        Quoteline.SBQQ__Product__c=prod.Id;
        Quoteline.SBQQ__Quantity__c=1;
        Qllist.add(Quoteline);
         }
        
         Insert Qllist;
        
        
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
         
        list<OpportunityLineItem> opllist = new list<OpportunityLineItem>();
        for(Opportunity op: opplist){
        OpportunityLineItem opl = new OpportunityLineItem();
        opl.OpportunityId=op.id;
        opl.Product2Id=prod.Id;
        opl.Quantity=1;
        opl.UnitPrice=50;
        opl.PricebookEntryId=prbe.Id;
        opl.DDS_Net_Unit_Price_Monthly__c = 34.0;
        opllist.add(opl);
        }
        Insert opllist;
          
        ScheduleBatchClosedWonRenewals schedule=new ScheduleBatchClosedWonRenewals();
        string cronExp='0 30 23 L * ? *' ;
        Id jobId=system.schedule('Close Win Open Renewal Opps', cronExp, schedule);

        

        Test.stopTest();

        cronTrigger ct =[select id,cronExpression from cronTrigger where id=:jobId];
        System.assertEquals(cronExp, ct.cronExpression);

    }
}