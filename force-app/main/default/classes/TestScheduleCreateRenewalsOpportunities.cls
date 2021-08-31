/*
 Description : Test class for the Schedule Class 'Schedule_Create_Renewals_Opportunities'

 Author      : Ramana 

 Created Date: 07/17/2020
*/
@Istest
Private class TestScheduleCreateRenewalsOpportunities {   
    @Istest
    
     Private static void TestScheduleRenewals(){

        Account acc=new Account();
        acc.Name='Test ';
        acc.Notes__c='test Notes';
        acc.Description='test desc';
        acc.SBQQ__RenewalModel__c='Contract Based';
        acc.SBQQ__RenewalPricingMethod__c='Uplift';
        insert acc;
        
        Contact c = new Contact();
        c.AccountId=acc.Id;
        c.LastName='test';
        insert c;
        
        Product2 prod = new Product2();
        prod.name='TestProd';
        prod.ProductCode = '12345';
        prod.SBQQ__SubscriptionPricing__c='Fixed Price';
        Insert prod;
       
       Contract con = new Contract();
       con.AccountId=acc.Id;
       con.Status='Draft';
       con.StartDate= date.parse('7/25/2019');
       con.EndDate= date.parse('7/24/2020');
       con.SBQQ__RenewalOpportunityRecordTypeId__c=Schema.SObjectType.Opportunity.getRecordTypeInfosByName().get('Billing').getRecordTypeId();
       con.SBQQ__AmendmentOpportunityRecordTypeId__c=Schema.SObjectType.Opportunity.getRecordTypeInfosByName().get('Billing').getRecordTypeId();
       con.SBQQ__RenewalTerm__c=12;
       con.SBQQ__RenewalQuoted__c=False;
       con.SBQQ__PreserveBundleStructureUponRenewals__c=true;     
      
       
        Test.startTest();
        
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
         
        Insert sub;
         
         Contract cn =[select id,status from  Contract where id=:con.Id ];
         cn.Status='Activated';
         update cn;
         
        Schedule_Create_Renewals_Opportunities schedule=new Schedule_Create_Renewals_Opportunities();
        string cronExp='0 0 00 3 * ? *'  ;
        Id jobId=system.schedule('Renewal Opportunity Creation', cronExp, schedule);

        
        Test.stopTest();
         
        cronTrigger ct =[select id,cronExpression from cronTrigger where id=:jobId];
        System.assertEquals(cronExp, ct.cronExpression);




    }
}