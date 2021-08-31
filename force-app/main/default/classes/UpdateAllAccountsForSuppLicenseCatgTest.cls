@isTest
public class UpdateAllAccountsForSuppLicenseCatgTest {

    @isTest
    public static void testAllAccountsUpdate(){
		        BillingOppsAutomation__c bcs = new BillingOppsAutomation__c();
        bcs.name='Automation';
        bcs.IsActive__c=True;
        Insert bcs;
	List<Account> lsAcct = new List<Account>();
        List<Product2> lsProd = new List<Product2>();
        List<Asset> lsAsset = new List<Asset>();
        List<PriceBookEntry> lsPbs = new List<PriceBookEntry>();
        
     Id pricebookId = Test.getStandardPricebookId();
        Account acc = new Account();
        acc.Name='Test';
        acc.Notes__c = 'Test';
        acc.Description = 'Test';
        //Insert acc;
        lsAcct.add(acc);
        
         Account acc1 = new Account();
        acc1.Name='Test1';
        acc1.Notes__c = 'Test1';
        acc1.Description = 'Test1';
        lsAcct.add(acc1);
        
         Account acc2 = new Account();
        acc2.Name='Test2';
        acc2.Notes__c = 'Test2';
        acc2.Description = 'Tes2t';
        lsAcct.add(acc2);
        
         insert lsAcct;
        
        Product2 prod = new Product2();
        prod.name='TestProd';
        prod.ProductCode = '12345';
        prod.IsActive = true;
        prod.Product_License_Categories__c = 'XVLite';
        lsProd.add(prod);
        
        Product2 prod1 = new Product2();
        prod1.name='TestProd1';
        prod1.ProductCode = '12345';
        prod1.IsActive = true;
        prod1.Product_License_Categories__c = 'XV3';
        lsProd.add(prod1);
        
        Product2 prod2 = new Product2();
        prod2.name='TestProd2';
        prod2.ProductCode = '12345';
        prod2.IsActive = true;
        prod2.Product_License_Categories__c = 'XV4';
        lsProd.add(prod2);
          insert lsProd;
        
        
        PriceBookEntry pbEntry = new PriceBookEntry();
        pbEntry.Pricebook2Id = pricebookId;
        pbEntry.IsActive = True;
        pbEntry.Product2Id =prod.Id;
        pbEntry.UnitPrice = 20;
        lsPbs.add(pbEntry);
        
        PriceBookEntry pbEntry1 = new PriceBookEntry();
        pbEntry1.Pricebook2Id = pricebookId;
        pbEntry1.IsActive = True;
        pbEntry1.Product2Id =prod1.Id;
        pbEntry1.UnitPrice = 20;
        lsPbs.add(pbEntry1);
        
        PriceBookEntry pbEntry2 = new PriceBookEntry();
        pbEntry2.Pricebook2Id = pricebookId;
        pbEntry2.IsActive = True;
        pbEntry2.Product2Id =prod2.Id;
        pbEntry2.UnitPrice = 20;
        lsPbs.add(pbEntry2);
        
        insert lsPbs;
        Asset asset = new Asset();
        asset.AccountId = acc.Id;
        asset.Name = 'Test Asset';
        asset.Product2Id = prod.Id;
        lsAsset.add(asset);
        
        Asset asset1 = new Asset();
        asset1.AccountId = acc1.Id;
        asset1.Name = 'Test Asset1';
        asset1.Product2Id = prod1.Id;
        lsAsset.add(asset1);
        
        Asset asset2 = new Asset();
        asset2.AccountId = acc2.Id;
        asset2.Name = 'Test Asset2';
        asset2.Product2Id = prod2.Id;
        lsAsset.add(asset2);
        
       
        insert lsAsset;
        
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
      
         
        
        // Insert con;
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
        UpdateAllAccountsForSuppLicenseCatg batchClass = new UpdateAllAccountsForSuppLicenseCatg();
        batchClass.getAllAccounts();
        Test.stopTest();
      
    }

    
}