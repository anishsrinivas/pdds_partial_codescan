@isTest
public class TestScheduleUpdateSuppCatgOnAcct {
    
    @isTest
    public static void testSchedule(){
		
        	        BillingOppsAutomation__c bcs = new BillingOppsAutomation__c();
        bcs.name='Automation';
        bcs.IsActive__c=True;
        Insert bcs;

        
       Id pricebookId = Test.getStandardPricebookId();
        Account acc = new Account();
        acc.Name='Test';
        acc.Notes__c = 'Test';
        acc.Description = 'Test';
        Insert acc;
        
        Product2 prod = new Product2();
        prod.name='TestProd';
        prod.ProductCode = '12345';
        prod.IsActive = true;
        prod.Product_License_Categories__c = 'XVLite';
        Insert prod;
        
        PriceBookEntry pbEntry = new PriceBookEntry();
        pbEntry.Pricebook2Id = pricebookId;
        pbEntry.IsActive = True;
        pbEntry.Product2Id =prod.Id;
        pbEntry.UnitPrice = 20;
        Insert pbEntry;
        
        Asset asset = new Asset();
        asset.AccountId = acc.Id;
        asset.Name = 'Test Asset1';
        asset.Product2Id = prod.Id;
         
         Contract con = new Contract();
       con.AccountId=acc.Id;
       con.Status='Draft';
       con.StartDate= date.parse('7/25/2019');
       con.EndDate= date.parse('05/31/2021');
       con.SBQQ__RenewalOpportunityRecordTypeId__c=Schema.SObjectType.Opportunity.getRecordTypeInfosByName().get('Billing').getRecordTypeId();
       con.SBQQ__AmendmentOpportunityRecordTypeId__c=Schema.SObjectType.Opportunity.getRecordTypeInfosByName().get('Billing').getRecordTypeId();
       con.SBQQ__RenewalTerm__c=12;
       con.SBQQ__RenewalQuoted__c=False;
       con.SBQQ__PreserveBundleStructureUponRenewals__c=true;     
      
         
        
         Insert con;
         SBQQ__Subscription__c sub = new SBQQ__Subscription__c();
        sub.SBQQ__Account__c=acc.Id;
        sub.SBQQ__Contract__c=con.Id;
        sub.SBQQ__Bundled__c=false;
        sub.SBQQ__CustomerPrice__c=0;
        sub.SBQQ__HasConsumptionSchedule__c=false;
        sub.SBQQ__ListPrice__c=0;
        sub.SBQQ__NetPrice__c=0;
        sub.SBQQ__Number__c=1;
        sub.SBQQ__PricingMethod__c='List';
        sub.SBQQ__ProductSubscriptionType__c='Renewable';
        sub.SBQQ__ProrateMultiplier__c=12;
        sub.SBQQ__RenewalQuantity__c=1;
        sub.SBQQ__RegularPrice__c=0;
        sub.SBQQ__Quantity__c=1;
        sub.SBQQ__SpecialPrice__c=0;
        sub.SBQQ__SubscriptionType__c='Renewable';
        sub.DDS_Product_Category__c='Subscription Items';
        sub.SBQQ__Product__c=prod.Id;
         
         
         
        
        Test.startTest();
        insert asset;
        Insert sub;
         Schedule_UpdateSuppCatgOnAccount schedule=new Schedule_UpdateSuppCatgOnAccount();
         string cronExp='0 56 15 8 * ? *'  ;
         Id jobId=system.schedule('Update Support Catg', cronExp, schedule);
        
        Test.stopTest();
        
        cronTrigger ct =[select id,cronExpression from cronTrigger where id=:jobId];
        System.assertEquals(cronExp, ct.cronExpression);
     }

}