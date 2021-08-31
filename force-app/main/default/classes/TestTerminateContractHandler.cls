@Istest
public class TestTerminateContractHandler {
    @Istest
    public static void call(){
        Product2 prod = new Product2();
        prod.name='TestProd';
        prod.ProductCode = '12345';
        Insert prod;
        
        Account acc = new Account();
        acc.Name='Test';
        Insert acc;
        
        Opportunity opp1 = new Opportunity();
        opp1.RecordTypeId=Schema.SObjectType.Opportunity.getRecordTypeInfosByName().get('Billing').getRecordTypeId();
        opp1.name='Testopp';
        opp1.Stagename='Investigating';
        opp1.closeDate=System.today();
        opp1.AccountId=acc.Id;
        opp1.DDS_OID__c='101';
        opp1.DDS_Practice_Location__c='Test';
        opp1.ia_crm__Change_Type__c='New MRR';
        Insert opp1;
        
        SBQQ__Quote__c Quote1 =  new SBQQ__Quote__c();
        Quote1.SBQQ__Account__c=acc.Id;
        Quote1.SBQQ__Opportunity2__c=opp1.Id;
        Quote1.SBQQ__Primary__c=True;
        insert Quote1;
        
        
        SBQQ__Quoteline__c Quoteline1 =  new SBQQ__Quoteline__c();
        Quoteline1.SBQQ__Quote__c=Quote1.Id;
        Quoteline1.SBQQ__Product__c=prod.Id;
        Quoteline1.SBQQ__Quantity__c=1;
        Insert Quoteline1;
        
        Contract con = new Contract();
        con.AccountId=acc.ID;
        con.SBQQ__Opportunity__c=opp1.Id;
        Insert con;
        
        SBQQ__Subscription__c sub = new SBQQ__Subscription__c();
        sub.SBQQ__Account__c=acc.Id;
        sub.SBQQ__Contract__c=con.Id;
        sub.SBQQ__Product__c=prod.Id;
        sub.SBQQ__Quantity__c=1;
        sub.SBQQ__QuoteLine__c=Quoteline1.Id;
        sub.SBQQ__TerminatedDate__c=System.today();
        Insert sub;
        
        
        Opportunity opp = new Opportunity();
        opp.RecordTypeId=Schema.SObjectType.Opportunity.getRecordTypeInfosByName().get('Billing').getRecordTypeId();
        opp.name='Testopp';
        opp.Stagename='Investigating';
        opp.closeDate=System.today();
        opp.AccountId=acc.Id;
        opp.DDS_OID__c='101';
        opp.DDS_Practice_Location__c='Test';
        opp.ia_crm__Change_Type__c='New MRR';
        opp.SBQQ__AmendedContract__c=con.Id;
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
        
       Opportunity op = [select StageName from opportunity where id=:opp.Id];
       op.StageName='Closed Won';
       update op;
       
    }
        
}