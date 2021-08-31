/************************************************************************************************************************
* @author           Demandblue
* @version          1.0 
* @Status           Development Completed
* @description      Test class for 'CreateContractHeader' Class


***************************************************************************************************************************
Version      Date          Team      Comments
***************************************************************************************************************************
* 1         19 Jan 2021     Ramana     Test Class for 'CreateContractHeader' Class
***************************************************************************************************************************/
@Istest
public class TestCreateContractHeader {
    
    @testsetup
    public Static Void createdata(){
        
        Account acc = new Account();
        acc.Name ='Test Acc';
        Insert acc;
        
        BillingOppsAutomation__c bcs = new BillingOppsAutomation__c();
        bcs.name='Automation';
        bcs.IsActive__c=false;
        Insert bcs;
        
        Id pricebookId = Test.getStandardPricebookId();
        
        Product2 prod = new Product2();
        prod.Name = 'Testp';
        prod.ProductCode = 'TP';
        prod.isActive = true;
        prod.SBQQ__SubscriptionType__c='One-time';
        prod.SBQQ__AssetConversion__c='One per quote line';
        insert prod;
        
        
        PricebookEntry pbEntry = new PricebookEntry();
        pbEntry.Pricebook2Id = pricebookId;
        pbEntry.Product2Id = prod.Id;
        pbEntry.UnitPrice = 100.00;
        pbEntry.IsActive = true;
        //pbelist.add(pbEntry);
        
        
        insert pbEntry;
        
        
        Id billingRecordTypeId = Schema.SObjectType.Opportunity.getRecordTypeInfosByName().get('Billing').getRecordTypeId();      
        Opportunity op = new Opportunity();
        op.RecordTypeId=billingRecordTypeId;
        op.AccountId=acc.Id;
        op.Name='Test Opp';
        op.closeDate=system.today();
        op.stagename='Investigating';
        op.Sales_Qualified_Appointment__c=true;
        op.DDS_Practice_Location__c='Test Loc';
        op.DDS_OID__c='101';
        op.ia_crm__Change_Type__c='New MRR';
        op.Pricebook2Id=pricebookId;
        Insert op;
        
        
        
        SBQQ__Quote__c Quote =  new SBQQ__Quote__c();
        Quote.SBQQ__Account__c=acc.Id;
        Quote.SBQQ__Opportunity2__c=op.Id;
        Quote.SBQQ__StartDate__c=System.today();
        //Date today =System.today();
        Quote.SBQQ__SubscriptionTerm__c=12;
        Quote.SBQQ__EndDate__c=Quote.SBQQ__StartDate__c.ADDMONTHS(11);
        Quote.SBQQ__Primary__c=True;
        Quote.SBQQ__PricebookId__c=pricebookId;
        Quote.SBQQ__PriceBook__c=pricebookId;
        insert Quote;
        
        SBQQ__QuoteLine__c ql = new SBQQ__QuoteLine__c();
        ql.SBQQ__Quote__c = Quote.Id;
        ql.SBQQ__Product__c = prod.Id;
        
        Test.startTest(); 
        Insert ql;
        
               
        OpportunityLineItem oli = new OpportunityLineItem(
            OpportunityId = op.Id,
            Product2Id=prod.Id,
            SBQQ__SubscriptionType__c='One-time',
            Quantity = 5.0,
            PricebookEntryId = pbEntry.Id,
            TotalPrice = 5 * (pbEntry.UnitPrice)
        );
        insert oli;
        
        Test.stopTest();
        
        
    }
    @Istest
    public static void Createcon(){
        Test.startTest(); 
        Opportunity opp = [select id,recordtypeId,stagename,SBQQ__Contracted__c from opportunity where name='Test Opp' LIMIT 1];
        opp.stagename='Closed Won';
         
        Update opp;
        Test.stopTest();
    }
    
}