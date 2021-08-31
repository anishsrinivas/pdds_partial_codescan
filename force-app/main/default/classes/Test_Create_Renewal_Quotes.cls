/*
 Description : Test class for the Batch Class 'Create_Renewal_Quotes' 

 Author      : Ramana 

 Created Date: 07/17/2020
*/
@Istest
Private class Test_Create_Renewal_Quotes {   
    @Istest
    
    Private static void Method1(){
      
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
       con.StartDate= date.parse('8/29/2019');
       con.EndDate= date.parse('8/28/2020');
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
         
         Insert sub;

        
        Test.startTest();

        database.executeBatch(new Create_Renewal_Quotes(new List<String>()),1);
        
        Test.stopTest();
        
      

    }
}